/****** Object:  StoredProcedure [dbo].[BATCH_CM_INCOMING_ICR$SP_PROCESS_ICR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_INCOMING_ICR$SP_PROCESS_ICR
Programmer Name	:	IMP Team.
Description		:	This process reads the temporary ICR response table LIGCR_Y1 and updates the out-of-state
     					case ID on Intergovermental case (ICAS_Y1) and update SSN on member SSN table (MSSN_Y1).
Frequency		:	DAILY
Developed On	:	5/10/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2 ,
                     BATCH_COMMON$BATE_LOG,  
                     BATCH_COMMON$BSTL_LOG,
                     BATCH_COMMON$SP_UPDATE_PARM_DATE,
 					 BATCH_COMMON$SP_BATCH_RESTART_UPDATE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_INCOMING_ICR$SP_PROCESS_ICR]
AS
 
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_ProcessY_INDC           CHAR(1) = 'Y',
          @Lc_ProcessN_INDC           CHAR(1) = 'N',
          @Lc_Note_INDC				  CHAR(1) = 'N',
          @Lc_EnumerationPending_CODE CHAR(1) = 'P',
          @Lc_PrimarySsnType_CODE	  CHAR(1) = 'P',
          @Lc_SecondarySsnType_CODE	  CHAR(1) = 'S',
          @Lc_TypeErrorE_CODE         CHAR(1) = 'E',
          @Lc_CaseStatusO_CODE        CHAR(1) = 'O',
          @Lc_CaseStatusC_CODE        CHAR(1) = 'C',
          @Lc_Reason7_CODE            CHAR(2) = '07',
          @Lc_Reason8_CODE            CHAR(2) = '08',
          @Lc_CaseRelationshipCP_CODE CHAR(2) = 'CP',
          @Lc_Reason02_CODE           CHAR(2) = '02',
          @Lc_ErrorE1419_CODE         CHAR(5) = 'E1419',
          @Lc_ErrorE0113_CODE         CHAR(5) = 'E0113',
          @Lc_ErrorE1424_CODE         CHAR(5) = 'E1424',
          @Lc_ErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_ErrorE0085_CODE         CHAR(5) = 'E0085',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_Job_ID                  CHAR(7) = 'DEB9305',
          @Lc_Successful_INDC         CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME          VARCHAR(50) = 'SP_PROCESS_ICR',
          @Ls_Process_NAME            VARCHAR(80) = 'BATCH_CM_INCOMING_ICR',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_MemberSsn_NUMB              NUMERIC(9) = 0,
          @Ln_Error_NUMB                  NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(10) = 0,
          @Ln_CursorCount_NUMB            NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(10) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_IcrrFirstReason_CODE        CHAR(2),
          @Lc_IcrrSecondReason_CODE       CHAR(2),
          @Lc_IcrrThirdReason_CODE        CHAR(2),
          @Lc_IcrrFourthReason_CODE       CHAR(2),
          @Lc_IcrrFifthReason_CODE        CHAR(2),
          @Lc_IcrrSixthReason_CODE        CHAR(2),
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_BateError_CODE              CHAR(5) = '',
          @Ls_Sql_TEXT                    VARCHAR(200),
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_BateRecord_TEXT             VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ln_ProcessIcrCur_Seq_IDNO				 NUMERIC(19),
		  @Lc_ProcessIcrCur_CaseIdno_TEXT            CHAR(6),
          @Lc_ProcessIcrCur_MemberSsnNumb_TEXT       CHAR(9),
          @Lc_ProcessIcrCur_MemberMciIdno_TEXT       CHAR(10),
          @Lc_ProcessIcrCur_StatusCase_CODE			 CHAR(2),
          @Lc_ProcessIcrCur_SentStateFips_CODE		 CHAR(2),
          @Lc_ProcessIcrCur_SentStateCaseId_TEXT	 CHAR(15),
          @Lc_ProcessIcrCur_IVDOutOfStateFips_CODE   CHAR(2),
          @Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT CHAR(15),
          @Lc_ProcessIcrCur_IcrrFirstReason_CODE     CHAR(2),
          @Lc_ProcessIcrCur_IcrrSecondReason_CODE    CHAR(2),
          @Lc_ProcessIcrCur_IcrrThirdReason_CODE     CHAR(2),
          @Lc_ProcessIcrCur_IcrrFourthReason_CODE    CHAR(2),
          @Lc_ProcessIcrCur_IcrrFifthReason_CODE     CHAR(2),
          @Lc_ProcessIcrCur_IcrrSixthReason_CODE     CHAR(2),
          @Lc_ProcessIcrCur_CaseRelationship_CODE    CHAR(2),
          @Lc_ProcessIcrCur_CpMatch_INDC             CHAR(1),
          @Lc_ProcessIcrCur_NcpMatch_INDC            CHAR(1),
          @Lc_ProcessIcrCur_SsnVerification_INDC     CHAR(1);
          
  DECLARE @Ln_ProcessIcrCurCase_IDNO	 			 NUMERIC(10),
		  @Ln_ProcessIcrCurMemberMci_IDNO			 NUMERIC(10),
		  @Ln_ProcessIcrCurMemberSsn_NUMB			 NUMERIC(9);
          
  DECLARE ProcessIcr_CUR INSENSITIVE CURSOR FOR
   SELECT L.Seq_IDNO,
		  L.Case_IDNO,
          L.MemberSsn_NUMB,
          L.MemberMci_IDNO,
          L.StatusCase_CODE,
          L.SentIVDOutOfStateCase_IDNO,
		  L.SentIVDOutOfStateFips_CODE,
          L.ReceivedIVDOutOfStateCase_IDNO,
          L.ReceivedIVDOutOfStateFips_CODE,
          L.Reason1_CODE,
          L.Reason2_CODE,
          L.Reason3_CODE,
          L.Reason4_CODE,
          L.Reason5_CODE,
          L.Reason6_CODE,
          L.CaseRelationship_CODE,
          L.CpMatched_INDC,
          L.NcpMatched_INDC,
          L.ReceivedSsnVerification_INDC
     FROM LIGCR_Y1 L
    WHERE Process_INDC = @Lc_ProcessN_INDC
 
  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ' RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR(50001,16,1);
    END

   BEGIN TRANSACTION IcrTran;

   SET @Ls_Sql_TEXT = 'OPEN ProcessIcr_CUR';

   OPEN ProcessIcr_CUR;

   FETCH NEXT FROM ProcessIcr_CUR INTO @Ln_ProcessIcrCur_Seq_IDNO, @Lc_ProcessIcrCur_CaseIdno_TEXT, @Lc_ProcessIcrCur_MemberSsnNumb_TEXT, @Lc_ProcessIcrCur_MemberMciIdno_TEXT, @Lc_ProcessIcrCur_StatusCase_CODE, @Lc_ProcessIcrCur_SentStateCaseId_TEXT, @Lc_ProcessIcrCur_SentStateFips_CODE, @Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT, @Lc_ProcessIcrCur_IVDOutOfStateFips_CODE, @Lc_ProcessIcrCur_IcrrFirstReason_CODE, @Lc_ProcessIcrCur_IcrrSecondReason_CODE, @Lc_ProcessIcrCur_IcrrThirdReason_CODE, @Lc_ProcessIcrCur_IcrrFourthReason_CODE, @Lc_ProcessIcrCur_IcrrFifthReason_CODE, @Lc_ProcessIcrCur_IcrrSixthReason_CODE, @Lc_ProcessIcrCur_CaseRelationship_CODE, @Lc_ProcessIcrCur_CpMatch_INDC, @Lc_ProcessIcrCur_NcpMatch_INDC, @Lc_ProcessIcrCur_SsnVerification_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Fetch the data from cursor
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVEICRTRAN;

      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_MemberSsn_NUMB = 0;
      
      IF ISNUMERIC(@Lc_ProcessIcrCur_CaseIdno_TEXT) = 1 
       AND ISNUMERIC(@Lc_ProcessIcrCur_MemberMciIdno_TEXT) = 1
       BEGIN
		  SET @Ln_ProcessIcrCurCase_IDNO = CAST(@Lc_ProcessIcrCur_CaseIdno_TEXT AS NUMERIC);
		  SET @Ln_ProcessIcrCurMemberMci_IDNO = CAST(@Lc_ProcessIcrCur_MemberMciIdno_TEXT AS NUMERIC);

       END
      ELSE
       BEGIN
		  SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

		  RAISERROR (50001,16,1);       
       END 
      
      SET @Ln_CursorCount_NUMB = @Ln_CursorCount_NUMB + 1; 
      SET @Ls_CursorLocation_TEXT = 'FNFD - CURSOR COUNT - ' + CAST(@Ln_CursorCount_NUMB AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_ProcessIcrCur_Seq_IDNO AS VARCHAR) + ', Case_IDNO = ' + @Lc_ProcessIcrCur_CaseIdno_TEXT + ', MemberSsn_NUMB = ' + @Lc_ProcessIcrCur_MemberSsnNumb_TEXT + ', MemberMci_IDNO = ' + @Lc_ProcessIcrCur_MemberMciIdno_TEXT + ', StatusCase_CODE = ' + @Lc_ProcessIcrCur_StatusCase_CODE + ', SentStateCaseId_TEXT = ' + @Lc_ProcessIcrCur_SentStateCaseId_TEXT + ', SentStateFips_CODE = ' + @Lc_ProcessIcrCur_SentStateFips_CODE + ', IVDOutOfStateCaseId_TEXT = ' + @Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT + ', IVDOutOfStateFips_CODE = ' + @Lc_ProcessIcrCur_IVDOutOfStateFips_CODE + ', IcrrFirstReason_CODE = ' + @Lc_ProcessIcrCur_IcrrFirstReason_CODE + ', IcrrSecondReason_CODE = ' + @Lc_ProcessIcrCur_IcrrSecondReason_CODE + ', IcrrThirdReason_CODE = ' + @Lc_ProcessIcrCur_IcrrThirdReason_CODE + ', IcrrFourthReason_CODE = ' + @Lc_ProcessIcrCur_IcrrFourthReason_CODE + ', IcrrFifthReason_CODE = ' + @Lc_ProcessIcrCur_IcrrFifthReason_CODE + ', IcrrSixthReason_CODE = ' + @Lc_ProcessIcrCur_IcrrSixthReason_CODE + ', CaseRelationship_CODE = ' + @Lc_ProcessIcrCur_CaseRelationship_CODE + ', IcrCur_CpMatch_INDC = ' + @Lc_ProcessIcrCur_CpMatch_INDC + ', NcpMatch_INDC = ' + @Lc_ProcessIcrCur_NcpMatch_INDC + ', SsnVerification_INDC = ' + @Lc_ProcessIcrCur_SsnVerification_INDC;

      IF @Lc_ProcessIcrCur_IcrrFirstReason_CODE = @Lc_Reason02_CODE
         AND @Lc_ProcessIcrCur_CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE
       BEGIN
        IF EXISTS (SELECT 1
                     FROM ICAS_Y1 I
                    WHERE I.Case_IDNO = @Ln_ProcessIcrCurCase_IDNO
                      AND I.IVDOutOfStateFips_CODE = @Lc_ProcessIcrCur_SentStateFips_CODE
                      AND I.IVDOutOfStateCase_ID = @Lc_ProcessIcrCur_SentStateCaseId_TEXT
                      AND I.Status_CODE = @Lc_CaseStatusO_CODE
                      AND I.EndValidity_DATE = @Ld_High_DATE)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') + ', Note_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

          EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_Note_INDC,
           @An_EventFunctionalSeq_NUMB  = 0,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'Update ICAS Open record - 1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ProcessIcrCurCase_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_ProcessIcrCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

          UPDATE ICAS_Y1
             SET IVDOutOfStateCase_ID = @Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT,
                 IVDOutOfStateFips_CODE = @Lc_ProcessIcrCur_SentStateFips_CODE,
                 TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                 Update_DTTM = @Ld_Start_DATE
          OUTPUT Deleted.Case_IDNO,
                 Deleted.IVDOutOfStateCase_ID,
                 Deleted.IVDOutOfStateFips_CODE,
                 Deleted.IVDOutOfStateOfficeFips_CODE,
                 Deleted.IVDOutOfStateCountyFips_CODE,
                 Deleted.Status_CODE,
                 Deleted.Effective_DATE,
                 Deleted.End_DATE,
                 Deleted.RespondInit_CODE,
                 Deleted.ControlByCrtOrder_INDC,
                 Deleted.ContOrder_DATE,
                 Deleted.ContOrder_ID,
                 Deleted.IVDOutOfStateFile_ID,
                 Deleted.Petitioner_NAME,
                 Deleted.ContactFirst_NAME,
                 Deleted.Respondent_NAME,
                 Deleted.ContactLast_NAME,
                 Deleted.ContactMiddle_NAME,
                 Deleted.PhoneContact_NUMB,
                 Deleted.Referral_DATE,
                 Deleted.Contact_EML,
                 Deleted.FaxContact_NUMB,
                 Deleted.File_ID,
                 Deleted.County_IDNO,
                 Deleted.IVDOutOfStateTypeCase_CODE,
                 Deleted.Create_DATE,
                 Deleted.Worker_ID,
                 Deleted.Update_DTTM,
                 Deleted.WorkerUpdate_ID,
                 Deleted.TransactionEventSeq_NUMB,
                 @Ld_Run_DATE,
                 Deleted.BeginValidity_DATE,
                 Deleted.Reason_CODE,
                 Deleted.RespondentMci_IDNO,
                 Deleted.PetitionerMci_IDNO,
                 Deleted.DescriptionComments_TEXT
          INTO ICAS_Y1
           WHERE Case_IDNO = @Ln_ProcessIcrCurCase_IDNO
             AND IVDOutOfStateFips_CODE = @Lc_ProcessIcrCur_SentStateFips_CODE
             AND IVDOutOfStateCase_ID = @Lc_ProcessIcrCur_SentStateCaseId_TEXT
             AND Status_CODE = @Lc_CaseStatusO_CODE
             AND EndValidity_DATE = @Ld_High_DATE;
         END
      
       IF EXISTS (SELECT 1
                     FROM ICAS_Y1 I
                    WHERE I.Case_IDNO = @Ln_ProcessIcrCurCase_IDNO
                      AND I.IVDOutOfStateFips_CODE = @Lc_ProcessIcrCur_SentStateFips_CODE
                      AND I.IVDOutOfStateCase_ID = @Lc_ProcessIcrCur_SentStateCaseId_TEXT
                      AND I.Status_CODE = @Lc_CaseStatusC_CODE
                      AND I.EndValidity_DATE = @Ld_High_DATE)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 2';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') + ', Note_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

          EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_Note_INDC,
           @An_EventFunctionalSeq_NUMB  = 0,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'Update ICAS Close record -2';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ProcessIcrCurCase_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_ProcessIcrCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

          UPDATE ICAS_Y1
             SET IVDOutOfStateCase_ID = @Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT,
                 IVDOutOfStateFips_CODE = @Lc_ProcessIcrCur_SentStateFips_CODE,
                 TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                 Update_DTTM = @Ld_Start_DATE
          OUTPUT Deleted.Case_IDNO,
                 Deleted.IVDOutOfStateCase_ID,
                 Deleted.IVDOutOfStateFips_CODE,
                 Deleted.IVDOutOfStateOfficeFips_CODE,
                 Deleted.IVDOutOfStateCountyFips_CODE,
                 Deleted.Status_CODE,
                 Deleted.Effective_DATE,
                 Deleted.End_DATE,
                 Deleted.RespondInit_CODE,
                 Deleted.ControlByCrtOrder_INDC,
                 Deleted.ContOrder_DATE,
                 Deleted.ContOrder_ID,
                 Deleted.IVDOutOfStateFile_ID,
                 Deleted.Petitioner_NAME,
                 Deleted.ContactFirst_NAME,
                 Deleted.Respondent_NAME,
                 Deleted.ContactLast_NAME,
                 Deleted.ContactMiddle_NAME,
                 Deleted.PhoneContact_NUMB,
                 Deleted.Referral_DATE,
                 Deleted.Contact_EML,
                 Deleted.FaxContact_NUMB,
                 Deleted.File_ID,
                 Deleted.County_IDNO,
                 Deleted.IVDOutOfStateTypeCase_CODE,
                 Deleted.Create_DATE,
                 Deleted.Worker_ID,
                 Deleted.Update_DTTM,
                 Deleted.WorkerUpdate_ID,
                 Deleted.TransactionEventSeq_NUMB,
                 @Ld_Run_DATE,
                 Deleted.BeginValidity_DATE,
                 Deleted.Reason_CODE,
                 Deleted.RespondentMci_IDNO,
                 Deleted.PetitionerMci_IDNO,
                 Deleted.DescriptionComments_TEXT
          INTO ICAS_Y1
           WHERE Case_IDNO = @Ln_ProcessIcrCurCase_IDNO
             AND IVDOutOfStateFips_CODE = @Lc_ProcessIcrCur_SentStateFips_CODE
             AND IVDOutOfStateCase_ID = @Lc_ProcessIcrCur_SentStateCaseId_TEXT
             AND Status_CODE = @Lc_CaseStatusC_CODE
             AND EndValidity_DATE = @Ld_High_DATE;
         END
       END
       
    IF LEN(@Lc_ProcessIcrCur_MemberSsnNumb_TEXT) > 1 
		 BEGIN 
		    IF ISNUMERIC(@Lc_ProcessIcrCur_MemberSsnNumb_TEXT) = 1 
		     BEGIN
			   SET @Ln_ProcessIcrCurMemberSsn_NUMB = CAST(@Lc_ProcessIcrCur_MemberSsnNumb_TEXT AS NUMERIC);
		     END 
		    ELSE
		     BEGIN 
		       SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

			   RAISERROR (50001,16,1);
		     END 

      IF (@Lc_ProcessIcrCur_IcrrFirstReason_CODE = @Lc_Reason7_CODE
           OR @Lc_ProcessIcrCur_IcrrSecondReason_CODE = @Lc_Reason7_CODE
           OR @Lc_ProcessIcrCur_IcrrThirdReason_CODE = @Lc_Reason7_CODE
           OR @Lc_ProcessIcrCur_IcrrFourthReason_CODE = @Lc_Reason7_CODE
           OR @Lc_ProcessIcrCur_IcrrFifthReason_CODE = @Lc_Reason7_CODE
           OR @Lc_ProcessIcrCur_IcrrSixthReason_CODE = @Lc_Reason7_CODE)
         AND @Lc_ProcessIcrCur_CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE
         AND @Lc_ProcessIcrCur_CpMatch_INDC = @Lc_ProcessY_INDC
         AND @Lc_ProcessIcrCur_NcpMatch_INDC = @Lc_ProcessY_INDC
       BEGIN
        SET @Ln_MemberSsn_NUMB = ISNULL((SELECT M.MemberSsn_NUMB
                                     FROM MSSN_Y1 M
                                    WHERE M.MemberMci_IDNO = @Ln_ProcessIcrCurMemberMci_IDNO
                                      AND M.EndValidity_DATE = @Ld_High_DATE),0);

        IF @Ln_MemberSsn_NUMB = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_MSSN - 1';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_ProcessIcrCurMemberMci_IDNO AS VARCHAR(10)) + ', MemberSsn = ' + CAST(@Ln_ProcessIcrCurMemberSsn_NUMB AS VARCHAR(9)) + ', EnumerationCode = ' + @Lc_EnumerationPending_CODE + ', TyepPrimaryCode = ' + @Lc_SecondarySsnType_CODE + ', SourceVerifyCode = ' + @Lc_Space_TEXT + ', Run Date = ' + CAST(@Ld_Run_DATE AS VARCHAR(20)) + ', Job Id = ' + @Lc_Job_ID + ', WorkerUpdate_ID = ' + @Lc_BatchRunUser_TEXT + ', SignedOnWorker_ID = ' + @Lc_Space_TEXT + ', TransactionEventSeqNumb = ' + CAST(@Ln_Zero_NUMB AS VARCHAR);

          EXEC BATCH_COMMON$SP_UPDATE_MSSN
           @An_MemberMci_IDNO           = @Ln_ProcessIcrCurMemberMci_IDNO,
           @An_MemberSsn_NUMB           = @Ln_ProcessIcrCurMemberSsn_NUMB,
           @Ac_Enumeration_CODE         = @Lc_EnumerationPending_CODE,
           @Ac_TypePrimary_CODE         = @Lc_PrimarySsnType_CODE,
           @Ac_SourceVerify_CODE        = @Lc_Space_TEXT,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_SignedOnWorker_ID        = @Lc_Space_TEXT,
           @An_TransactionEventSeq_NUMB = 0,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'ADD NOT SUCCESSFUL';
            SET @Lc_BateError_CODE = @Lc_ErrorE0113_CODE;

            RAISERROR(50001,16,1);
           END;
         END
       END
    END 
   
      IF (@Lc_IcrrFirstReason_CODE = @Lc_Reason7_CODE
           OR @Lc_IcrrSecondReason_CODE = @Lc_Reason7_CODE
           OR @Lc_IcrrThirdReason_CODE = @Lc_Reason7_CODE
           OR @Lc_IcrrFourthReason_CODE = @Lc_Reason7_CODE
           OR @Lc_IcrrFifthReason_CODE = @Lc_Reason7_CODE
           OR @Lc_IcrrSixthReason_CODE = @Lc_Reason7_CODE)
         AND @Lc_ProcessIcrCur_CpMatch_INDC = @Lc_ProcessN_INDC
         AND @Lc_ProcessIcrCur_NcpMatch_INDC = @Lc_ProcessN_INDC
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'RECORD NOT PROCESSED AS CP OR NCP DID NOT MATCH = ' + @Lc_ProcessIcrCur_CaseIdno_TEXT;
        SET @Lc_BateError_CODE = @Lc_ErrorE1419_CODE;

        RAISERROR(50001,16,1);
       END

      IF @Lc_IcrrFirstReason_CODE = @Lc_Reason8_CODE
          OR @Lc_IcrrSecondReason_CODE = @Lc_Reason8_CODE
          OR @Lc_IcrrThirdReason_CODE = @Lc_Reason8_CODE
          OR @Lc_IcrrFourthReason_CODE = @Lc_Reason8_CODE
          OR @Lc_IcrrFifthReason_CODE = @Lc_Reason8_CODE
          OR @Lc_IcrrSixthReason_CODE = @Lc_Reason8_CODE
       BEGIN
        SET @Ln_MemberSsn_NUMB = ISNULL((SELECT M.MemberSsn_NUMB
                                     FROM MSSN_Y1 M
                                    WHERE M.MemberMci_IDNO = @Ln_ProcessIcrCurMemberMci_IDNO
                                      AND M.EndValidity_DATE = @Ld_High_DATE),0);

        IF @Ln_MemberSsn_NUMB <> 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_MSSN - 2';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO  = ' + CAST(@Ln_ProcessIcrCurMemberMci_IDNO AS VARCHAR(10)) + ', MemberSsn = ' + CAST(@Ln_ProcessIcrCurMemberSsn_NUMB AS VARCHAR(9)) + ', EnumerationCode = ' + @Lc_EnumerationPending_CODE + ', TyepPrimaryCode = ' + @Lc_SecondarySsnType_CODE + ', SourceVerifyCode = ' + @Lc_Space_TEXT + ', Run Date = ' + CAST(@Ld_Run_DATE AS VARCHAR(20)) + ', Job Id = ' + @Lc_Job_ID + ', WorkerUpdate_ID = ' + @Lc_BatchRunUser_TEXT + ', SignedOnWorker_ID = ' + @Lc_Space_TEXT + ', TransactionEventSeqNumb = ' + CAST(@Ln_Zero_NUMB AS VARCHAR);

          EXEC BATCH_COMMON$SP_UPDATE_MSSN
           @An_MemberMci_IDNO           = @Ln_ProcessIcrCurMemberMci_IDNO,
           @An_MemberSsn_NUMB           = @Ln_ProcessIcrCurMemberSsn_NUMB,
           @Ac_Enumeration_CODE         = @Lc_EnumerationPending_CODE,
           @Ac_TypePrimary_CODE         = @Lc_SecondarySsnType_CODE,
           @Ac_SourceVerify_CODE        = @Lc_Space_TEXT,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_SignedOnWorker_ID        = @Lc_Space_TEXT,
           @An_TransactionEventSeq_NUMB = 0,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'ADD NOT SUCCESSFUL';
            SET @Lc_BateError_CODE = @Lc_ErrorE0113_CODE;

            RAISERROR(50001,16,1);
           END;
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEICRTRAN;
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END
      END

      IF @Lc_BateError_CODE = ''
       BEGIN 
         SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE
       END 
       
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR (20)), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_RestartLine_NUMB,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
      ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LIGCR_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_ProcessIcrCur_Seq_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_ProcessIcrCurMemberMci_IDNO AS VARCHAR);

     UPDATE LIGCR_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_ProcessIcrCur_Seq_IDNO;

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @@ROWCOUNT;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       COMMIT TRANSACTION IcrTran;

       BEGIN TRANSACTION IcrTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION IcrTran;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH ProcessIcr_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH ProcessIcr_CUR INTO @Ln_ProcessIcrCur_Seq_IDNO, @Lc_ProcessIcrCur_CaseIdno_TEXT, @Lc_ProcessIcrCur_MemberSsnNumb_TEXT, @Lc_ProcessIcrCur_MemberMciIdno_TEXT, @Lc_ProcessIcrCur_StatusCase_CODE, @Lc_ProcessIcrCur_SentStateCaseId_TEXT, @Lc_ProcessIcrCur_SentStateFips_CODE, @Lc_ProcessIcrCur_IVDOutOfStateCaseId_TEXT, @Lc_ProcessIcrCur_IVDOutOfStateFips_CODE, @Lc_ProcessIcrCur_IcrrFirstReason_CODE, @Lc_ProcessIcrCur_IcrrSecondReason_CODE, @Lc_ProcessIcrCur_IcrrThirdReason_CODE, @Lc_ProcessIcrCur_IcrrFourthReason_CODE, @Lc_ProcessIcrCur_IcrrFifthReason_CODE, @Lc_ProcessIcrCur_IcrrSixthReason_CODE, @Lc_ProcessIcrCur_CaseRelationship_CODE, @Lc_ProcessIcrCur_CpMatch_INDC, @Lc_ProcessIcrCur_NcpMatch_INDC, @Lc_ProcessIcrCur_SsnVerification_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE ProcessIcr_CUR;

   DEALLOCATE ProcessIcr_CUR;

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_ErrorMessage_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_ErrorMessage_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION IcrTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IcrTran;
    END

   IF CURSOR_STATUS ('local', 'ProcessIcr_CUR') IN (0, 1)
    BEGIN
     CLOSE ProcessIcr_CUR;

     DEALLOCATE ProcessIcr_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @ls_sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_ErrorMessage_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
