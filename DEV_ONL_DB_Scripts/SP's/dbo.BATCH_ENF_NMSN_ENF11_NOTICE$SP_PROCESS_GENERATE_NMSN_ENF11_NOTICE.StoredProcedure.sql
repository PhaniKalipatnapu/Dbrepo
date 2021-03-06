/****** Object:  StoredProcedure [dbo].[BATCH_ENF_NMSN_ENF11_NOTICE$SP_PROCESS_GENERATE_NMSN_ENF11_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_NMSN_ENF11_NOTICE$SP_PROCESS_GENERATE_NMSN_ENF11_NOTICE
Programmer Name 	: IMP Team.
Description			: This batch program generates one time annual notice to employers suggesting them to contact
					  DCSE with regarding to any changes in Insurance Coverage Plan.
Frequency			: ANNUAL
Developed On		: 01/05/2012
Called By			: 
Called Procedures	: BATCH_COMMON$SP_GET_BATCH_DETAILS , BATCH_COMMON$BATE_LOG, BATCH_COMMON$BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_NMSN_ENF11_NOTICE$SP_PROCESS_GENERATE_NMSN_ENF11_NOTICE]
AS
 BEGIN
   DECLARE @Lc_InsOrderedA_CODE                         CHAR(1)			= 'A',
           @Lc_InsOrderedU_CODE                         CHAR(1)			= 'U',
           @Lc_InsOrderedC_CODE                         CHAR(1)			= 'C',
           @Lc_InsOrderedO_CODE                         CHAR(1)			= 'O',
           @Lc_InsOrderedB_CODE                         CHAR(1)			= 'B',
           @Lc_InsOrderedD_CODE                         CHAR(1)			= 'D',
           @Lc_TypeErrorE_CODE                          CHAR(1)			= 'E',
           @Lc_TypeErrorW_CODE                          CHAR(1)			= 'W',
           @Lc_StatusCaseOpen_CODE                      CHAR(1)			= 'O',
           @Lc_CaseMemberStatusActive_CODE              CHAR(1)			= 'A',
           @Lc_CaseRelationshipNcp_CODE                 CHAR(1)			= 'A',
           @Lc_CaseRelationshipCp_CODE                  CHAR(1)			= 'C',
           @Lc_CaseRelationshipPf_CODE                  CHAR(1)			= 'P',
           @Lc_RespondInitInstate_CODE					CHAR(1)			= 'N',
           @Lc_RespondInitRespondingState_CODE          CHAR(1)			= 'R',
           @Lc_RespondInitRespondingTribal_CODE         CHAR(1)			= 'S',
           @Lc_RespondInitRespondingInternational_CODE  CHAR(1)			= 'Y',
           @Lc_TypeCaseNonIvd_CODE                      CHAR(1)			= 'H',
           @Lc_Yes_INDC                                 CHAR(1)			= 'Y',
           @Lc_No_INDC                                  CHAR(1)			= 'N',
           @Lc_StatusSuccess_CODE                       CHAR(1)			= 'S',
           @Lc_StatusFailed_CODE                        CHAR(1)			= 'F',
           @Lc_StatusAbnormalend_CODE                   CHAR(1)			= 'A',
           @Lc_StatusNoticeCancel_CODE                  CHAR(1)			= 'C',
           @Lc_TypeIncomeUA_CODE                        CHAR(2)			= 'UA',
           @Lc_TypeIncomeML_CODE                        CHAR(2)			= 'ML',
           @Lc_SubsystemEnforcement_CODE                CHAR(3)			= 'EN',
           @Lc_ActivityMajorCase_CODE                   CHAR(4)			= 'CASE',
           @Lc_Table8670_ID                             CHAR(4)			= '8670',
           @Lc_TableSub8670_ID                          CHAR(4)			= '8670',
           @Lc_ReasonErfso_CODE                         CHAR(5)			= 'ERFSO',
           @Lc_ReasonErfsm_CODE                         CHAR(5)			= 'ERFSM',
           @Lc_ReasonErfss_CODE                         CHAR(5)			= 'ERFSS',
           @Lc_NoticePrintEnf11_ID						CHAR(5)			= 'NOPRI',
           @Lc_ErrorE0944_CODE                          CHAR(5)			= 'E0944',
           @Lc_ErrorBatch_CODE                          CHAR(5)			= 'E1424',
           @Lc_Job_ID                                   CHAR(7)			= 'DEB9303',
           @Lc_NoticeEnf11_ID                           CHAR(8)			= 'ENF-11',
           @Lc_Successful_TEXT                          CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT                        CHAR(30)		= 'BATCH',
           @Ls_Procedure_NAME                           VARCHAR(60)		= 'SP_PROCESS_GENERATE_NMSN_ENF11_NOTICE',
           @Ls_Process_NAME                             VARCHAR(100)	= 'BATCH_ENF_NMSN_ENF11_NOTICE',
           @Ld_High_DATE                                DATE			= '12/31/9999';           
  DECLARE  @Li_Error_NUMB								INT				= 0,
           @Li_ErrorLine_NUMB							INT				= 0,
           @Ln_FetchStatus_QNTY							NUMERIC(2),
           @Ln_NoCommitFreq_QNTY						NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY				NUMERIC(5)		= 0,
           @Ln_CommitFreq_NUMB							NUMERIC(5)		= 0,
           @Ln_CursorCount_NUMB							NUMERIC(10)		= 0,
           @Ln_ExceptionThreshold_QNTY					NUMERIC(10)		= 0,
           @Ln_Topic_IDNO								NUMERIC(10),
           @Ln_TransactionEventSeq_NUMB					NUMERIC(19),
           @Lc_Null_TEXT								CHAR(1)			= '',
           @Lc_Msg_CODE									CHAR(5),
           @Ls_CursorLoc_TEXT							VARCHAR(200),
           @Ls_Sql_TEXT									VARCHAR(400),
           @Ls_Sqldata_TEXT								VARCHAR(1000),
           @Ls_DescriptionError_TEXT					VARCHAR(MAX),
           @Ld_Run_DATE									DATE,
           @Ld_LastRun_DATE								DATE,
           @Ld_Current_DTTM								DATETIME2		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	           
 DECLARE   @NmsnCur_Rec$Case_IDNO						NUMERIC(6),
		   @NmsnCur_Rec$MemberMci_IDNO					NUMERIC(10),
		   @NmsnCur_Rec$OthpPartyEmpl_IDNO				NUMERIC(9),
		   @NmsnCur_Rec$InsOrdered_CODE					CHAR(1),
		   @NmsnCur_Rec$CaseRelationship_CODE			CHAR(1);
			   
   BEGIN TRY

   BEGIN TRANSACTION Main_Transaction;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS'
   SET @Ls_Sqldata_TEXT = 'Job_ID : ' + ISNULL(@Lc_Job_ID, '') + ' Run_DATE : ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR(10)), '')

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_NoCommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

	IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			 SET @Ls_DescriptionError_TEXT = 'BATCH_EST_GEN_TEST$GET_BATCH_DETAILS2';
			 RAISERROR(50001,16,1);
		END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

	IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
		BEGIN
			SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
			RAISERROR(50001,16,1);
		END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				@Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				@Ac_Process_ID               = @Lc_Job_ID,
				@Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
				@Ac_Note_INDC                = @Lc_No_INDC,
				@An_EventFunctionalSeq_NUMB  = 0,
				@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

	IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
			RAISERROR(50001,16,1);
		END

   DECLARE NmsnNotice_Cur CURSOR LOCAL FORWARD_ONLY FOR
    SELECT t.Case_IDNO,
           t.MemberMci_IDNO,
           t.InsOrdered_CODE,
           t.CaseRelationship_CODE,
           t.OthpPartyEmpl_IDNO
      FROM (SELECT t.Case_IDNO,
				   t.MemberMci_IDNO,
				   t.InsOrdered_CODE,
				   t.CaseRelationship_CODE,
				   t.OthpPartyEmpl_IDNO,
				   ROW_NUMBER() OVER(PARTITION BY t.OthpPartyEmpl_IDNO ORDER BY t.Case_IDNO DESC) Row_NUMB
			  FROM (SELECT a.Case_IDNO,
						   c.MemberMci_IDNO,
						   a.InsOrdered_CODE,
						   c.CaseRelationship_CODE,
						   e.OthpPartyEmpl_IDNO
					  FROM (SELECT c.Case_IDNO,
								   c.MemberMci_IDNO,
								   c.CaseRelationship_CODE,
								   @Lc_InsOrderedC_CODE AS InsOrdered_CODE
							  FROM CMEM_Y1 AS c
							 WHERE c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
							   AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
							UNION
							SELECT c.Case_IDNO,
								   c.MemberMci_IDNO,
								   c.CaseRelationship_CODE,
								   @Lc_InsOrderedA_CODE AS InsOrdered_CODE
							  FROM CMEM_Y1 AS c
							 WHERE c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
							   AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
							UNION
							SELECT c.Case_IDNO,
								   c.MemberMci_IDNO,
								   c.CaseRelationship_CODE,
								   @Lc_InsOrderedB_CODE AS InsOrdered_CODE
							  FROM CMEM_Y1 AS c
							 WHERE c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
							   AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)) AS c,
						   (SELECT b.Case_IDNO,
								   CASE
									WHEN b.InsOrdered_CODE IN (@Lc_InsOrderedA_CODE, @Lc_InsOrderedU_CODE)
									 THEN @Lc_InsOrderedA_CODE
									WHEN b.InsOrdered_CODE IN (@Lc_InsOrderedC_CODE, @Lc_InsOrderedO_CODE)
									 THEN @Lc_InsOrderedC_CODE
									WHEN b.InsOrdered_CODE IN (@Lc_InsOrderedB_CODE, @Lc_InsOrderedD_CODE)
									 THEN @Lc_InsOrderedB_CODE
								   END InsOrdered_CODE
							  FROM ENSD_Y1 b
							 WHERE b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
								/* Case is not marked initiating intergovernmental or if it is marked responding intergovernmental the referral type 
									is not 'Registration for Modification Only' */
								AND ( b.RespondInit_CODE = @Lc_RespondInitInstate_CODE
										OR (b.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
											   AND NOT EXISTS(SELECT 1
																FROM ICAS_Y1 x
															   WHERE x.Case_IDNO = b.Case_IDNO
																 AND x.RespondInit_CODE = b.RespondInit_CODE
																 AND x.Status_CODE = @Lc_StatusCaseOpen_CODE
																 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
																 AND x.EndValidity_DATE = @Ld_High_DATE)))
							   -- Open IV-D cases      
							   AND b.TypeCase_CODE != @Lc_TypeCaseNonIvd_CODE
							   --Non end-dated support order record
							   AND @Ld_Run_DATE BETWEEN b.OrderEffective_DATE AND b.OrderEnd_DATE
							   --Insurance Ordered field is NOT ‘N – Not Ordered’
							   AND b.InsOrdered_CODE IN (SELECT Value_CODE
														   FROM REFM_Y1
														  WHERE Table_ID = @Lc_Table8670_ID
															AND TableSub_ID = @Lc_TableSub8670_ID)) AS a,
							EHIS_Y1 e
						 WHERE a.Case_IDNO = c.Case_IDNO
						   AND a.InsOrdered_CODE = c.InsOrdered_CODE
						   AND e.MemberMci_IDNO = c.MemberMci_IDNO
						   AND e.EmployerPrime_INDC = @Lc_Yes_INDC
						   --Non-End dated employers
						   AND @Ld_Current_DTTM BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
						   AND e.Status_CODE = @Lc_Yes_INDC
						   AND e.TypeIncome_CODE NOT IN (@Lc_TypeIncomeUA_CODE,@Lc_TypeIncomeML_CODE)
						   AND EXISTS 
							   (
           						SELECT 1
           							FROM OTHP_Y1 o
           							WHERE o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
           								AND o.EndValidity_DATE = @Ld_High_DATE
							   )
						   /*if record found and there are match on the OTHP ID and Notice ID then escape */	   
						   AND NOT EXISTS
							   (
								SELECT 1
									FROM NRRQ_Y1 r
								   WHERE r.Notice_ID = @Lc_NoticeEnf11_ID
									 AND ISNUMERIC(r.Recipient_ID)			= 1 
									 AND CAST(r.Recipient_ID AS NUMERIC)= e.OthpPartyEmpl_IDNO
								)
							/*if record found and there are match on the OTHP ID and Notice ID then escape */	   
							AND NOT EXISTS
							   (
								SELECT 1
									FROM NMRQ_Y1 m
								  WHERE m.Notice_ID = @Lc_NoticeEnf11_ID
									 AND ISNUMERIC(m.Recipient_ID)			= 1 
									 AND CAST(m.Recipient_ID AS NUMERIC)			= e.OthpPartyEmpl_IDNO
									 AND m.StatusNotice_CODE != @Lc_StatusNoticeCancel_CODE
								)
					) AS t
				) AS t
		  WHERE t.Row_NUMB = 1;

   OPEN NmsnNotice_Cur

   BEGIN
    FETCH NEXT FROM NmsnNotice_Cur INTO @NmsnCur_Rec$Case_IDNO, @NmsnCur_Rec$MemberMci_IDNO, @NmsnCur_Rec$InsOrdered_CODE, @NmsnCur_Rec$CaseRelationship_CODE, @NmsnCur_Rec$OthpPartyEmpl_IDNO
	SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS
		WHILE @Ln_FetchStatus_QNTY = 0
			BEGIN	
				SET @Ln_CursorCount_NUMB  = @Ln_CursorCount_NUMB  + 1;
				SET @Ln_CommitFreq_NUMB = @Ln_CommitFreq_NUMB + 1;
				SET @Lc_Msg_CODE = @Lc_ErrorBatch_CODE;
				BEGIN TRY
					SAVE TRANSACTION Cursor_Transaction;
					  
					SET @Ln_CommitFreq_NUMB = @Ln_CommitFreq_NUMB + 1;
					SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_INSERT_ACTIVITY '
					SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(CAST(@NmsnCur_Rec$Case_IDNO AS VARCHAR(6)), '') 
										 + ' MemberMci_IDNO ' + ISNULL(CAST(@NmsnCur_Rec$MemberMci_IDNO AS VARCHAR(10)), '') 
										 + ' InsOrdered_CODE ' + ISNULL(@NmsnCur_Rec$InsOrdered_CODE, '') 
										 + ' CaseRelationship_CODE ' + ISNULL(@NmsnCur_Rec$CaseRelationship_CODE, '') 
										 + ' OthpPartyEmpl_IDNO' + ISNULL (CAST(@NmsnCur_Rec$OthpPartyEmpl_IDNO AS VARCHAR(10)), '');
					
					EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
					 @An_Case_IDNO                = @NmsnCur_Rec$Case_IDNO,
					 @An_MemberMci_IDNO           = @NmsnCur_Rec$MemberMci_IDNO,
					 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
					 @Ac_ActivityMinor_CODE       = @Lc_NoticePrintEnf11_ID,
					 @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
					 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
					 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
					 @Ad_Run_DATE                 = @Ld_Run_DATE,
					 @Ac_Notice_ID                = @Lc_NoticeEnf11_ID,
					 @An_OthpSource_IDNO          = @NmsnCur_Rec$OthpPartyEmpl_IDNO,
					 @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
					 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
					 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

					IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
					 BEGIN
					  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY FAILED';
					  RAISERROR(50001,16,1);
					 END
				 END TRY
				 BEGIN CATCH
					IF XACT_STATE()	= 1
						BEGIN
						   ROLLBACK TRANSACTION Cursor_Transaction;
						END
					ELSE
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
							RAISERROR( 50001 ,16,1);
						END
						
					SAVE TRANSACTION Cursor_Transaction;
					
					SET @Li_Error_NUMB = ERROR_NUMBER ();
					SET @Li_ErrorLine_NUMB = ERROR_LINE ();

					IF @Li_Error_NUMB <> 50001
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
						END
						
					EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
					  @As_Procedure_NAME        = @Ls_Procedure_NAME,
					  @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
					  @As_Sql_TEXT              = @Ls_Sql_TEXT,
					  @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
					  @An_Error_NUMB            = @Li_Error_NUMB,
					  @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
					  @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
							
					 EXECUTE BATCH_COMMON$SP_BATE_LOG
					  @As_Process_NAME             = @Ls_Process_NAME,
					  @As_Procedure_NAME           = @Ls_Procedure_NAME,
					  @Ac_Job_ID                   = @Lc_Job_ID,
					  @Ad_Run_DATE                 = @Ld_Run_DATE,
					  @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
					  @An_Line_NUMB                = @Ln_CursorCount_NUMB,
					  @Ac_Error_CODE               = @Lc_Msg_CODE, 
					  @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT, 
					  @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
					  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
					  @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	
							
					IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					  BEGIN
						   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 1 FAILED';
						   RAISERROR (50001,16,1);
					  END
					 ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
					  BEGIN
							SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
					  END	
				 END CATCH
				
				   
				-- When the commit frequency is attained, Commit the transaction completed until now and Reset the commit count
				IF @Ln_NoCommitFreq_QNTY <> 0 AND @Ln_CommitFreq_NUMB >= @Ln_NoCommitFreq_QNTY
					 BEGIN
						COMMIT TRANSACTION Main_Transaction;
						BEGIN TRANSACTION Main_Transaction;
						SET @Ln_CommitFreq_NUMB = 0;
					 END
				--If the Erroneous Exceptions are more than the threshold, then we need to abend the program. The commit will ensure that the records processed so far without any problems are committed. Also the exception entries are committed so that it will be easy to determine the error records.	
				IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
				   AND @Ln_ExceptionThresholdParm_QNTY > 0
				 BEGIN
				  COMMIT TRANSACTION Main_Transaction;
				  SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
				  SET @Ls_Sqldata_TEXT = ' EXCP_COUNT = ' + ISNULL(CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR(9)), '') + ', @Ln_ExceptionThresholdParm_QNTY = ' + ISNULL(CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR(19)), '');
				  SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
				  RAISERROR (50001,16,1);
				 END 

			SET @Ls_Sql_TEXT = 'FETCH NmsnNotice_Cur - 2';
			SET @Ls_Sqldata_TEXT = '';
			
			FETCH NmsnNotice_Cur INTO @NmsnCur_Rec$Case_IDNO, @NmsnCur_Rec$MemberMci_IDNO, @NmsnCur_Rec$InsOrdered_CODE, @NmsnCur_Rec$CaseRelationship_CODE, @NmsnCur_Rec$OthpPartyEmpl_IDNO;
			SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
		 END
   END

   CLOSE NmsnNotice_Cur
   DEALLOCATE NmsnNotice_Cur

    IF @Ln_CursorCount_NUMB = 0
		BEGIN
			SET @Ls_Sql_TEXT = 'NO RECORDS TO PROCESS';
			 EXECUTE BATCH_COMMON$SP_BATE_LOG
			  @As_Process_NAME             = @Ls_Process_NAME,
			  @As_Procedure_NAME           = @Ls_Procedure_NAME,
			  @Ac_Job_ID                   = @Lc_Job_ID,
			  @Ad_Run_DATE                 = @Ld_Run_DATE,
			  @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
			  @An_Line_NUMB                = 0,
			  @Ac_Error_CODE               = @Lc_ErrorE0944_CODE, 
			  @As_DescriptionError_TEXT    = @Ls_Sql_TEXT, 
			  @As_ListKey_TEXT             = ' ',
			  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			  @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	
							  
			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			  BEGIN
				SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 2 FAILED';
			   RAISERROR (50001,16,1);
			  END										  
								  
		END


   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'ID_JOB: ' + ISNULL(@Lc_Job_ID, '') + ' DT_RUN: ' + ISNULL(CAST(@Ld_Run_DATE AS NVARCHAR (10)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
		RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG 1'
   
    EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE                  = @Ld_Run_DATE,
			@Ad_Start_DATE                = @Ld_Current_DTTM,
			@Ac_Job_ID                    = @Lc_Job_ID,
			@As_Process_NAME              = @Ls_Process_NAME,
			@As_Procedure_NAME            = @Ls_Procedure_NAME,
			@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
			@As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
			@As_ListKey_TEXT              = @Lc_Successful_TEXT,
			@As_DescriptionError_TEXT     = @Lc_Null_TEXT,
			@Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
			@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
			@An_ProcessedRecordCount_QNTY = @Ln_CursorCount_NUMB;
			
	IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION Main_Transaction;
		END
  END TRY

  BEGIN CATCH
  
	  IF @@TRANCOUNT > 0
		BEGIN
		 ROLLBACK TRANSACTION Main_Transaction;
		END
	  
	  IF CURSOR_STATUS('Local', 'NmsnNotice_Cur') IN (0, 1)
		BEGIN
		 CLOSE NmsnNotice_Cur;
		 DEALLOCATE NmsnNotice_Cur;
		END
    
	SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
	SET @Li_Error_NUMB = ERROR_NUMBER ();
	SET @Li_ErrorLine_NUMB = ERROR_LINE ();

	IF (@Li_Error_NUMB <> 50001)
		BEGIN
			SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
		END
    
    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
				@As_Procedure_NAME        = @Ls_Procedure_NAME,
				@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
				@As_Sql_TEXT              = @Ls_Sql_TEXT,
				@As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
				@An_Error_NUMB            = @Li_Error_NUMB,
				@An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
				@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
				
				
	 EXECUTE BATCH_COMMON$SP_BSTL_LOG
					@Ad_Run_DATE                  = @Ld_Run_DATE,
					@Ad_Start_DATE                = @Ld_Current_DTTM,
					@Ac_Job_ID                    = @Lc_Job_ID,
					@As_Process_NAME              = @Ls_Process_NAME,
					@As_Procedure_NAME            = @Ls_Procedure_NAME,
					@As_CursorLocation_TEXT       = @Lc_Null_TEXT,
					@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
					@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
					@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
					@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
					@Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
					@An_ProcessedRecordCount_QNTY = @Ln_CursorCount_NUMB;				
				
     RAISERROR (@Ls_DescriptionError_TEXT,16,1);
     
  END CATCH
 END


GO
