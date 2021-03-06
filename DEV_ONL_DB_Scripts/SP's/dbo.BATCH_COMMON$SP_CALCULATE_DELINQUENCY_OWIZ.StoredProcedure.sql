/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CALCULATE_DELINQUENCY_OWIZ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CALCULATE_DELINQUENCY_OWIZ
Programmer Name		: IMP Team
Description			: Procedure which calculates delinquency amount for given case, except for current month, when an 
						obligation is added or modified
Developed On		: 02/20/2015
Called By			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CALCULATE_DELINQUENCY_OWIZ]
(
	@An_Case_IDNO               NUMERIC(6),
	@An_EventGlobalSeq_NUMB     NUMERIC(19),
	@Ac_Msg_CODE                CHAR(1) OUTPUT,
	@As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE
		@Lc_StatusFailed_CODE				CHAR(1)			= 'F',
		@Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
		@Lc_StatusCaseOpen_CODE				CHAR(1)			= 'O',
		@Lc_CaseTypeNonIvd_CODE				CHAR(1)			= 'H',
		@Lc_OrderTypeVoluntary_CODE			CHAR(1)			= 'V',
		@Lc_TypeDebtChildSupp_CODE			CHAR(2)			= 'CS',
        @Lc_TypeDebtSpousalSupp_CODE		CHAR(2)			= 'SS',
        @Lc_TypeDebtMedicalSupp_CODE		CHAR(2)			= 'MS',
		@Lc_ActivityMajorCrpt_CODE	    	CHAR(4)			= 'CRPT',
		@Lc_StatusStart_CODE				CHAR(4)			= 'STRT',	
		@Lc_StatusComplete_CODE				CHAR(4)			= 'COMP',
		@Ls_Routine_TEXT					VARCHAR(50)		= 'BATCH_COMMON$SP_CALCULATE_DELINQUENCY_OWIZ',
		@Ld_High_DATE						DATE			= '12/31/9999';

	DECLARE
		@Ln_RowsAffected_NUMB				INT,
		@Ln_Zero_NUMB						NUMERIC(1)		= 0,
		@Ln_MaxSupportYearMonthBegin_NUMB	NUMERIC(6),
		@Ln_Error_NUMB						NUMERIC(11)		= 0,
        @Ln_ErrorLine_NUMB					NUMERIC(11)		= 0,
        @Ln_Delinquency_AMNT				NUMERIC(11,2),
        @Ls_Sql_TEXT						VARCHAR(400)	= '',
        @Ls_Sqldata_TEXT					VARCHAR(1000)	= '',
		@Ls_DescriptionError_TEXT			VARCHAR(4000)	= '',
		@Ld_MaxBegin_DATE					DATE,
		@Ld_Current_DATE					DATETIME		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	BEGIN TRY
		
		--Checks whether the record exist in UMSO for the given case otherwise no need to update the delinquency amount 
		IF NOT EXISTS (SELECT 1 
						 FROM UMSO_Y1 
						WHERE Case_IDNO = @An_Case_IDNO)
		BEGIN
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			RETURN;
		END
		
		SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1, DMJR_Y1, CASE_Y1 - @Ld_MaxBegin_DATE and @Ln_MaxSupportYearMonthBegin_NUMB';
		SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '');
		
		--Selecting the begin date from which Unpaid mso need to be considered to calculate delinquency amount
		SELECT
			@Ld_MaxBegin_DATE = MAX(x.Begin_DATE),
			@Ln_MaxSupportYearMonthBegin_NUMB = SUBSTRING(CONVERT(CHAR(6),MAX(Begin_DATE),112),1,6)
			FROM (
				--To Select Minimum begin date of obligation of type CS, SS, MS for the given case 
				SELECT MIN(o.BeginValidity_DATE) AS Begin_DATE  
				FROM OBLE_Y1 o 
				WHERE 
					o.Case_IDNO = @An_Case_IDNO
					AND o.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE)
				UNION
				--To Select Minimum begin obligation date of type CS, SS, MS for the given case 
				SELECT MIN(o.BeginObligation_DATE) AS Begin_DATE  
				FROM OBLE_Y1 o
				WHERE 
					o.Case_IDNO = @An_Case_IDNO
					AND o.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE)
					AND o.EndValidity_DATE = @Ld_High_DATE
				UNION
				--Selecting CRPT chain completed date for the given case
				SELECT MAX(d.Status_DATE) AS Begin_DATE 
				FROM DMJR_Y1 d 
				WHERE 
					d.Case_IDNO = @An_Case_IDNO
					AND d.Status_CODE = @Lc_StatusComplete_CODE
					AND d.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
				UNION
				--Case Opened Date
				SELECT c.Opened_DATE AS Begin_DATE
				FROM CASE_Y1 c
				WHERE
					c.Case_IDNO = @An_Case_IDNO
					AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
					AND c.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
				) AS x
		
		SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1 - Delinquency_AMNT';
		SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', EventGlobalSeq_NUMB = '  + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR(19)), '');
		SELECT 
			--To Exclude negative current support owed amount
			@Ln_Delinquency_AMNT = 			
				(CASE WHEN SUM(y.MtdCurSup_Balance_AMNT+ y.MtdExptPay_Balance_AMNT) < @Ln_Zero_NUMB THEN @Ln_Zero_NUMB 
					ELSE SUM(y.MtdCurSup_Balance_AMNT+ y.MtdExptPay_Balance_AMNT) 
				END)
		FROM
		(
			SELECT 
				Case_IDNO,
				SupportYearMonth_NUMB,
				OrderSeq_NUMB,
				ObligationSeq_NUMB,
				SUM(a.MtdCurSupOwed_AMNT - a.AppTotCurSup_AMNT) AS MtdCurSup_Balance_AMNT,
				SUM(a.OweTotExptPay_AMNT - a.AppTotExptPay_AMNT)AS MtdExptPay_Balance_AMNT
			FROM 
				LSUP_Y1 a
			WHERE  
				a.Case_IDNO = @An_Case_IDNO
				--Latest log support record for given Case, support year month, order and obligation
				AND EXISTS (SELECT 1 FROM LSUP_Y1 b 
									WHERE a.Case_IDNO = b.Case_IDNO
									AND a.EventGlobalSeq_NUMB = (SELECT MAX (EventGlobalSeq_NUMB)
																  FROM LSUP_Y1 d
																 WHERE d.Case_IDNO = a.Case_IDNO
																   AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
																   AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
																   AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB)
																   )
				
				--Support Order should exist and order type should not voluntary order
				AND EXISTS (SELECT 1 FROM SORD_Y1 s
								 WHERE s.Case_IDNO = a.Case_IDNO
								  AND s.OrderSeq_NUMB = a.OrderSeq_NUMB
								  AND @Ld_Current_DATE BETWEEN S.OrderEffective_DATE AND S.OrderEnd_DATE
								  AND s.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
								  AND s.EndValidity_DATE = @Ld_High_DATE)
				
				--Case should not have CRPT Chain started
				AND NOT EXISTS (SELECT 1 FROM DMJR_Y1 j
									 WHERE j.Case_IDNO = a.Case_IDNO
									 AND j.ActivityMajor_CODE =@Lc_ActivityMajorCrpt_CODE
									 AND j.Status_CODE = @Lc_StatusStart_CODE
									 AND j.Status_DATE = @Ld_High_DATE)		
				
				--Case must be Open	Non-IVD Case					 
				AND EXISTS (SELECT 1 FROM CASE_Y1 c
								 WHERE c.Case_IDNO = a.Case_IDNO
								 AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
								 AND c.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE)	
				
				--No need to calculate Unpaid mso for current month as the month end batch is going to calculate.
				AND a.SupportYearMonth_NUMB < SUBSTRING(CONVERT(VARCHAR(6),@Ld_Current_DATE,112),1,6)
				--Unpaid mso need to be calculated from least begin validity of case or If CRPT closed chain date exist then consider maximum Status Date
				AND a.SupportYearMonth_NUMB >= @Ln_MaxSupportYearMonthBegin_NUMB
				
				GROUP BY a.Case_IDNO,a.SupportYearMonth_NUMB,a.OrderSeq_NUMB,a.ObligationSeq_NUMB
			) AS y 
            GROUP By Case_IDNO
		
				
		SET @Ls_Sql_TEXT = 'UPDATE HUMSO_Y1 - Delinquency_AMNT';
		SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '') + 
								' @Ln_Delinquency_AMNT = ' + ISNULL(CAST(@Ln_Delinquency_AMNT AS VARCHAR(20)), '') + 
								' @Ld_Current_DATE = ' + ISNULL(CAST(@Ld_Current_DATE AS VARCHAR(10)), '') +
								', EventGlobalSeq_NUMB = '  + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR(19)), '');
		--Updating UMSO with the latest Delinquency amount after moving the existing record to History
		UPDATE UMSO_Y1 
			SET
				Delinquency_AMNT = @Ln_Delinquency_AMNT,
				EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
			OUTPUT
				DELETED.Case_IDNO,
				DELETED.Delinquency_AMNT,
				DELETED.Begin_DATE,
				DELETED.EventGlobalSeq_NUMB,
				@Ld_Current_DATE
			INTO HUMSO_Y1
			WHERE Case_IDNO = @An_Case_IDNO
		
		SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
		
		IF @Ln_RowsAffected_NUMB = 0
		BEGIN
			SET @Ls_DescriptionError_TEXT = @Ls_Sql_TEXT + ' FAILED';
			RAISERROR(50001,16,1);
		END;
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
	END TRY
	BEGIN CATCH
		SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		SET @Ln_Error_NUMB = ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE();

		IF @Ln_Error_NUMB <> 50001
		BEGIN
			SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
		END

		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
			@As_Procedure_NAME        = @Ls_Routine_TEXT,
			@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
			@As_Sql_TEXT              = @Ls_Sql_TEXT,
			@As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
			@An_Error_NUMB            = @Ln_Error_NUMB,
			@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
			@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
	END CATCH
END

GO
