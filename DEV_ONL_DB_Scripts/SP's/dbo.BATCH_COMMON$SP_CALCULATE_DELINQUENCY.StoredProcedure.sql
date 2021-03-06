/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CALCULATE_DELINQUENCY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CALCULATE_DELINQUENCY
Programmer Name		: IMP Team
Description			: This procedure is to reset the Delinquency amount (Unpaid MSO + Expect To Pay Amount) if case gets closed or Credit reporting chain closed in the current month.
					  It also creates or appends Delinquency amount of the current month for all obligation created cases where unpaid MSO or Expect to pay amount exists.
Frequency			: 
Developed On		: 02/25/2014
Called By			: BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_MONTHLY
Called On			: BATCH_COMMON$SP_GENERATE_SEQ 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CALCULATE_DELINQUENCY]
 @Ad_Run_DATE				DATE,
 @Ad_LastRun_DATE			DATE,
 @Ac_Msg_CODE				CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000)	OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_StatusSuccess_CODE           CHAR(1)			= 'S',
           @Lc_StatusFailed_CODE            CHAR(1)			= 'F',
           @Lc_No_INDC						CHAR(1)			= 'N',
           @Lc_StatusCaseClose_CODE			CHAR(1)			= 'C',
           @Lc_OrderTypeVoluntary_CODE      CHAR(1)			= 'V',
           @Lc_CaseTypeNonIvd_CODE			CHAR(1)			= 'H',
           @Lc_TypeDebtChildSupp_CODE		CHAR(2)			= 'CS',
           @Lc_TypeDebtSpousalSupp_CODE		CHAR(2)			= 'SS',
           @Lc_TypeDebtMedicalSupp_CODE		CHAR(2)			= 'MS',
		   @Lc_ActivityMajorCrpt_CODE		CHAR(4)			= 'CRPT',
           @Lc_StatusComplete_CODE			CHAR(4)			= 'COMP',
           @Lc_StatusStart_CODE				CHAR(4)			= 'STRT',
           @Lc_BatchRunUser_TEXT            CHAR(5)			= 'BATCH', 
           @Lc_ActionUpdate_TEXT			CHAR(6)			= 'UPDATE',
           @Lc_Job_ID                       CHAR(7)			= 'DEB7600',
		   @Ls_Procedure_NAME               CHAR(38)		= 'BATCH_COMMON$SP_CALCULATE_DELINQUENCY',
           @Ld_High_DATE                    DATE			= '12/31/9999';
  DECLARE  @Ln_RowCount_QNTY                NUMERIC(7),
           @Ln_Error_NUMB					NUMERIC(11),
           @Ln_ErrorLine_NUMB				NUMERIC(11),
           @Ln_EventGlobalSeq_NUMB			NUMERIC(19),
           @Lc_Msg_CODE                     CHAR(5),
           @Ls_Sql_TEXT						VARCHAR(100),
           @Ls_Sqldata_TEXT					VARCHAR(1000)	= '',
           @Ls_DescriptionError_TEXT		VARCHAR(4000)	= '';

	BEGIN TRY
		
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
		SET @Ls_Sqldata_TEXT = 'Process_ID = ' + @Lc_Job_ID+ ', EffectiveEvent_DATE = ' + CAST( @Ad_Run_DATE AS CHAR(10) );
		EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
		@An_EventFunctionalSeq_NUMB = 0,
		@Ac_Process_ID              = @Lc_Job_ID,
		@Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
		@Ac_Note_INDC               = @Lc_No_INDC,
		@Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
		@An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
		@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

		IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END;

		SET @Ls_Sql_TEXT = 'SELECT UMSO_Y1, ENSD_Y1, DMJR_Y1';
		SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST( @Ad_Run_DATE AS CHAR(10) ) + ', LastRun_DATE = ' + CAST( @Ad_LastRun_DATE AS CHAR(10) )+ ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR);
		-- Reset the Delinquency amount to 0 when either case is closed or CRPT chain is closed the current month
		IF EXISTS ( SELECT 1
					  FROM UMSO_Y1 u
					 WHERE u.Delinquency_AMNT > 0
					   AND EXISTS ( SELECT 1
									  FROM ENSD_Y1 e
									 WHERE e.Case_IDNO = u.Case_IDNO
									   AND e.StatusCase_CODE = @Lc_StatusCaseClose_CODE
									 UNION
									SELECT 1
									  FROM DMJR_Y1 j
									 WHERE j.Case_IDNO = u.Case_IDNO
									   AND j.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
									   AND j.Status_CODE = @Lc_StatusComplete_CODE
									   AND j.Status_DATE > @Ad_LastRun_DATE
									   AND j.Status_DATE <= @Ad_Run_DATE ) )

		BEGIN
			SET @Ls_Sql_TEXT = 'UPDATE UMSO_Y1';
			-- Resets the Delinquency amount if the CRPT chain or Case gets closed in the current month. 
			UPDATE u
			   SET u.Delinquency_AMNT = 0,
				   u.Begin_DATE = @Ad_Run_DATE,
				   u.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB
			OUTPUT DELETED.Case_IDNO,
				   DELETED.Delinquency_AMNT,
				   DELETED.Begin_DATE,
				   DELETED.EventGlobalSeq_NUMB,
				   @Ad_Run_DATE EndValidity_DATE
			  INTO HUMSO_Y1
			  FROM UMSO_Y1 u
			 WHERE u.Delinquency_AMNT > 0
			   AND EXISTS ( SELECT 1
							  FROM ENSD_Y1 e
							 WHERE e.Case_IDNO = u.Case_IDNO
							   AND e.StatusCase_CODE = @Lc_StatusCaseClose_CODE
							 UNION 
							SELECT 1
							  FROM DMJR_Y1 j
							 WHERE j.Case_IDNO = u.Case_IDNO
							   AND j.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
							   AND j.Status_CODE = @Lc_StatusComplete_CODE
							   AND j.Status_DATE > @Ad_LastRun_DATE
							   AND j.Status_DATE <= @Ad_Run_DATE );
			 
			SET @Ln_RowCount_QNTY = @@ROWCOUNT;
				
			IF @Ln_RowCount_QNTY = 0
			BEGIN
				SET @Ls_Sql_TEXT = 'UPDATE UMSO_Y1 FOR RESET FAILED';
				RAISERROR(50001,16,1);
			END
		END
		
		SET @Ls_Sql_TEXT = 'INSERT/UPDATE UMSO_Y1';
		-- Create/Append the current month Delinquency amount (Unpaid MSO and Expect to Pay amount) for all elgible open and Non IVD cases 
		-- with active Support Order and doesn't have open CRPT chain. 
		INSERT INTO HUMSO_Y1 
		SELECT t.Case_IDNO, 
			   t.Delinquency_AMNT,
			   t.Begin_DATE,
			   t.EventGlobalSeq_NUMB,
			   t.EndValidity_DATE
		  FROM ( MERGE INTO UMSO_Y1 u 
				 USING (SELECT Case_IDNO, 
							  ISNULL( ( SELECT SUM(MtdCurSupOwed_AMNT - AppTotCurSup_AMNT) + SUM(OweTotExptPay_AMNT - AppTotExptPay_AMNT) 
										  FROM LSUP_Y1 l
										 WHERE l.Case_IDNO = e.Case_IDNO
										   AND l.SupportYearMonth_NUMB = SUBSTRING(CONVERT(CHAR(6),@Ad_Run_DATE,112),1,6)
										   AND l.EventGlobalSeq_NUMB = ( SELECT MAX(EventGlobalSeq_NUMB)
																		  FROM LSUP_Y1 s
																		 WHERE s.Case_IDNO = l.Case_IDNO
																		   AND s.OrderSeq_NUMB = l.OrderSeq_NUMB
																		   AND s.ObligationSeq_NUMB = l.ObligationSeq_NUMB
																		   AND s.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB )
											AND EXISTS ( SELECT 1
															 FROM OBLE_Y1 o
															WHERE o.Case_IDNO = l.Case_IDNO
															  AND o.OrderSeq_NUMB = l.OrderSeq_NUMB
															  AND o.ObligationSeq_NUMB = l.ObligationSeq_NUMB
															  AND o.EndValidity_DATE = @Ld_High_DATE
															  AND o.TypeDebt_CODE IN ( @Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE ) ) 
									  ), 0.00) Delinquency_AMNT
						 FROM ENSD_Y1 e
						WHERE e.StatusCase_CODE != @Lc_StatusCaseClose_CODE
						  AND e.OrderEnd_DATE > @Ad_Run_DATE
						  AND e.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
						  AND e.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
						  AND NOT EXISTS ( SELECT 1
											 FROM DMJR_Y1 j
											WHERE j.Case_IDNO = e.Case_IDNO
											  AND j.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
											  AND j.Status_CODE = @Lc_StatusStart_CODE )
						  AND EXISTS ( SELECT 1
										 FROM OBLE_Y1 o
										WHERE o.Case_IDNO = e.Case_IDNO
										  AND o.EndValidity_DATE = @Ld_High_DATE
										  AND o.TypeDebt_CODE IN ( @Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE ) ) ) t 
				   ON ( u.Case_IDNO = t.Case_IDNO ) 
				WHEN MATCHED AND t.Delinquency_AMNT != 0 
				THEN UPDATE 
						SET u.Delinquency_AMNT = CASE WHEN ( u.Delinquency_AMNT + t.Delinquency_AMNT ) < 0
													  THEN 0
													  ELSE u.Delinquency_AMNT + t.Delinquency_AMNT
												 END,
							u.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB
				WHEN NOT MATCHED 
				THEN INSERT ( Case_IDNO, 
							  Delinquency_AMNT,
							  Begin_DATE,
							  EventGlobalSeq_NUMB
							) 
					 VALUES ( t.Case_IDNO,
							  CASE WHEN t.Delinquency_AMNT < 0
								   THEN 0
								   ELSE t.Delinquency_AMNT
							  END,
							  @Ad_Run_DATE,
							  @Ln_EventGlobalSeq_NUMB
							)
				 OUTPUT $action,
						DELETED.Case_IDNO,
						DELETED.Delinquency_AMNT,
						DELETED.Begin_DATE,
						DELETED.EventGlobalSeq_NUMB,
						@Ad_Run_DATE ) 
				AS t (Action, Case_IDNO, Delinquency_AMNT, Begin_DATE, EventGlobalSeq_NUMB, EndValidity_DATE)
				WHERE t.Action = @Lc_ActionUpdate_TEXT
				  AND t.EventGlobalSeq_NUMB != @Ln_EventGlobalSeq_NUMB;
 				
					  
		SET @Ln_RowCount_QNTY = @@ROWCOUNT;
				
		IF @Ln_RowCount_QNTY = 0
		BEGIN
			SET @Ls_DescriptionError_TEXT = 'INSERT/UPDATE UMSO_Y1 FAILED';
			RAISERROR(50001,16,1);
		END
		
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
		SET @As_DescriptionError_TEXT = '';
	END TRY

	BEGIN CATCH
		SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		SET @Ln_Error_NUMB = ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE();
		
		IF @Ln_Error_NUMB <> 50001
		BEGIN
			SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200)+ ' ' + ISNULL(@Ls_DescriptionError_TEXT,'');
		END

		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
		@As_Sql_TEXT              = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
		@An_Error_NUMB            = @Ln_Error_NUMB,
		@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
		@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
	END CATCH
 END


GO
