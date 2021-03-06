/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_EFT_NOTICE$SP_PROCESS_GENERATE_EFT_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_EFT_NOTICE$SP_PROCESS_GENERATE_EFT_NOTICE
Programmer Name		: IMP Team
Description			: This process generates the FIN-25 (DD/SVC) notice for eligible Custodial Parents (CPs) and 
					  inserts a SCV instruction record in the SVCI screen/ DCRS table.
Frequency			: 'DAILY'
Developed On		: 09/12/2011
Called By			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_EFT_NOTICE$SP_PROCESS_GENERATE_EFT_NOTICE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_StoredValueCardProcess3500_NUMB INT = 3500,
		  @Lc_TypeErrorE_CODE				  CHAR(1) = 'E',
          @Lc_OpenCaseStatus_CODE             CHAR(1) = 'O',
          @Lc_VoluntaryTypeOrder_CODE         CHAR(1) = 'V',
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_RespondInitI_CODE				  CHAR(1) = 'I',
          @Lc_RespondInitC_CODE				  CHAR(1) = 'C',
          @Lc_RespondInitT_CODE				  CHAR(1) = 'T',                    
          @Lc_RespondInitN_CODE				  CHAR(1) = 'N',
          @Lc_NonTanfWelfareType_CODE         CHAR(1) = 'N',
          @Lc_CpRelationshipCase_CODE         CHAR(1) = 'C',
          @Lc_ActiveCaseMemberStatus_CODE     CHAR(1) = 'A',
          @Lc_FailedStatus_CODE               CHAR(1) = 'F',
          @Lc_ErrorTypeError_CODE             CHAR(1) = 'E',
          @Lc_No_TEXT                         CHAR(1) = 'N',
          @Lc_NoticesentStatus_CODE           CHAR(1) = 'N',
          @Lc_SuccessStatus_CODE              CHAR(1) = 'S',
          @Lc_AbnormalendStatus_CODE          CHAR(1) = 'A',
          @Lc_Note_INDC                       CHAR(1) = 'N',
          @Lc_StatusInactive_CODE             CHAR(1) = 'I',
          @Lc_TypeCaseNonIVD_CODE			  CHAR(1) = 'H',
          @Lc_MediumDisburseCheck_CODE		  CHAR(1) = 'C',
          @Lc_CheckRecipientOne_CODE		  CHAR(1) = '1',
          @Lc_TypeAddressMailing_CODE		  CHAR(1) = 'M',
          @Lc_StatusConfirmedGood_CODE		  CHAR(1) = 'Y',
          @Lc_StatusEftCancelled_CODE         CHAR(2) = 'CA',
          @Lc_StatusCheckOutstanding_CODE	  CHAR(2) = 'OU',
          @Lc_StatusCheckCashed_CODE		  CHAR(2) = 'CA',
          @Lc_CaseCategoryDP_CODE			  CHAR(2) = 'DP',
          @Lc_DebtTypeChildSupport_CODE		  CHAR(2) = 'CS',
          @Lc_DebtTypeMedicalSupport_CODE	  CHAR(2) = 'MS',
          @Lc_DebtTypeSpousalSupport_CODE	  CHAR(2) = 'SS',
          @Lc_FmSubsystem_CODE                CHAR(3) = 'FM',
          @Lc_CaseMajorActivity_CODE          CHAR(4) = 'CASE',
          @Lc_ErrorNoRecords_CODE             CHAR(5) = 'E0944',
          @Lc_ErrorE1424_CODE                 CHAR(5) = 'E1424',
          @Lc_GdidnActivityMinor_CODE         CHAR(5) = 'GDIDN',
          @Lc_Job_ID						  CHAR(7) = 'DEB0800',
          @Lc_FIN25Notice_ID                  CHAR(8) = 'FIN-25',
          @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
          @Lc_NoRecordsToProcess_TEXT		  CHAR(30) = 'NO RECORD(S) TO PROCESS',
          @Ls_Procedure_NAME                  VARCHAR(60) = 'SP_PROCESS_GENERATE_EFT_NOTICE',
          @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_GENERATE_EFT_NOTICE',
          @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB                  NUMERIC,
          @Ln_ErrorLine_NUMB              NUMERIC,
          @Ln_FetchStatus_QNTY            NUMERIC,
          @Ln_RowsCount_QNTY              NUMERIC,
          @Ln_CursorRecordCount_QNTY      NUMERIC = 0,
          @Ln_Value_QNTY                  NUMERIC(3),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0, 
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,                   
          @Ln_CheckRecipient_ID           NUMERIC(10),          
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Lc_TypeError_CODE              CHAR(1),
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_BateError_CODE              CHAR(5),
          @Lc_Notice_ID                   CHAR(8),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_ErrorDesc_TEXT              VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_SixMnthsOld_DATE            DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ln_CaseCurCase_IDNO            NUMERIC(6),
          @Ln_NoticeCur_MemberMci_IDNO	  NUMERIC(10);

  BEGIN TRY   
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;   

   /*Get the current run date and last run date from PARM_Y1 (Parameters table), and validate that the batch program was not executed for the current run date, 
   by ensuring that the run date is different from the last run date in the PARM table. Otherwise, an error message will be written into the Batch Status Log (BSTL) 
   screen/Batch Status Log (BSTL_Y1) table and the process terminate will terminate.*/
  
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ld_LastRun_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF @Ld_LastRun_DATE > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   -- Get Restart Key Details
   BEGIN
    SET @Ls_Sql_TEXT = 'GET RESTART KEY DETAILS';
    SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

    SELECT @Ln_CheckRecipient_ID = CAST((SUBSTRING(r.RestartKey_TEXT, 1, 10)) AS NUMERIC)
      FROM RSTL_Y1 r
     WHERE r.Job_ID = @Lc_Job_ID
       AND r.Run_DATE = @Ld_Run_DATE;

    SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

    IF @Ln_RowsCount_QNTY = 0
     BEGIN
      SET @Ln_CheckRecipient_ID = 0;
     END
   END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_StoredValueCardProcess3500_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_TEXT,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');
   
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_StoredValueCardProcess3500_NUMB,
    @Ac_Process_ID              = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    @Ac_Note_INDC               = @Lc_No_TEXT,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
  
   SET @Ld_SixMnthsOld_DATE = DATEADD(MONTH, -6, @Ld_Run_DATE);

   DECLARE Notice_Cur INSENSITIVE CURSOR FOR
    SELECT DISTINCT	
           e.CpMci_IDNO AS CheckRecipient_ID
      FROM ENSD_Y1 e           
     WHERE e.CpMci_IDNO > @Ln_CheckRecipient_ID
           --The CP has an open IV-D (Never Assistance or Former Assistance case) or Non IV-D case (Exclude the Current Assistance Cases and Non-IV-D Direct Pay Cases).
           AND e.StatusCase_CODE = @Lc_OpenCaseStatus_CODE
           AND e.RespondInit_CODE IN(@Lc_RespondInitN_CODE, @Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
           AND (e.TypeCase_CODE = @Lc_NonTanfWelfareType_CODE
                 OR (e.TypeCase_CODE = @Lc_TypeCaseNonIVD_CODE
                     AND e.CaseCategory_CODE <> @Lc_CaseCategoryDP_CODE))
           --Exclude all cases that have only a voluntary order associated with the CP by checking the Order Type in the Support Order (SORD) screen/Support Order (SORD_Y1) table.
           AND e.TypeOrder_CODE <> @Lc_VoluntaryTypeOrder_CODE          				
           AND EXISTS(
			SELECT 1
           FROM SORD_Y1 a
           WHERE Case_IDNO = e.Case_IDNO
			AND TypeOrder_CODE != @Lc_VoluntaryTypeOrder_CODE
			AND @Ld_Run_DATE BETWEEN OrderEffective_DATE AND OrderEnd_DATE
			AND EndValidity_DATE = @Ld_High_DATE
           )
           --At least one charging Order for a CP who resides in DE.				           
           AND EXISTS (
					  SELECT 1
					    FROM OBLE_Y1 o
					   WHERE o.Case_IDNO = e.Case_IDNO
					     AND o.TypeDebt_CODE IN (@Lc_DebtTypeChildSupport_CODE, @Lc_DebtTypeMedicalSupport_CODE, @Lc_DebtTypeSpousalSupport_CODE)
					     AND o.Periodic_AMNT > 0
					     AND @Ld_Run_DATE BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE
					     AND o.EndValidity_DATE = @Ld_High_DATE)
           /*Validating the CP that does not exist in EFTR_Y1 with EFT Status equal to AC - ACTIVE, EX - EXEMPT, PG - PRE-NOTE GENERATED, PP - PRE-NOTE PENDING, 
           PR - PRE-NOTE REJECTED excluding CA - CANCELLED*/                     
           AND NOT EXISTS (
                          SELECT CheckRecipient_ID
                             FROM EFTR_Y1 t
                            WHERE t.CheckRecipient_ID = e.CpMci_IDNO
                              AND t.StatusEft_CODE <> @Lc_StatusEftCancelled_CODE
                              AND t.EndValidity_DATE = @Ld_High_DATE)
		   /*Validating the CP that does not exist in DCRS_Y1 with SVC Status equal to A - ACTIVE, E - EXEMPT, N - NOTICE SENT, R - REQUEST
		   excluding I - INACTIVE*/                              		                          
           AND NOT EXISTS (
                          SELECT CheckRecipient_ID
                             FROM DCRS_Y1 c
                            WHERE c.CheckRecipient_ID = e.CpMci_IDNO
                              AND c.Status_CODE <> @Lc_StatusInactive_CODE
                              AND c.EndValidity_DATE = @Ld_High_DATE)
           AND EXISTS (--There exists a verified good mailing address for the CP.
                       SELECT 1
                         FROM AHIS_Y1 a
                        WHERE e.CpMci_IDNO = a.MemberMci_IDNO
                          AND a.Status_CODE = @Lc_StatusConfirmedGood_CODE
                          AND a.TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
                          AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE)
           AND									
           	EXISTS
           	(	--CP has received 3 or more check disbursements within the last six months.
						SELECT COUNT(1)
						  FROM DSBH_Y1 s
						 WHERE s.CheckRecipient_ID = CAST(e.CpMci_IDNO AS CHAR) 
						   AND s.MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE 
						   AND s.StatusCheck_CODE IN (@Lc_StatusCheckOutstanding_CODE, @Lc_StatusCheckCashed_CODE) 
						   AND s.CheckRecipient_CODE = @Lc_CheckRecipientOne_CODE
						   AND s.EndValidity_DATE = @Ld_High_DATE 
						   AND s.Disburse_DATE BETWEEN @Ld_SixMnthsOld_DATE AND @Ld_Run_DATE							
						HAVING COUNT(1) >= 3
           	)
           AND e.CpMci_IDNO <> 0
     ORDER BY CheckRecipient_ID;

   BEGIN TRANSACTION EftNoticeTran;

   SET @Ls_Sql_TEXT = 'OPEN Notice_Cur-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Notice_Cur;

   SET @Ls_Sql_TEXT = 'FETCH Notice_Cur-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Notice_Cur INTO @Ln_NoticeCur_MemberMci_IDNO;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   /*When these conditions are met, a forms generation component is invoked with the Form ID of 'FIN-25'. This will result in the creation of records 
   in the Notice Message Queue (NMRQ_Y1) table to be processed by a subsequent batch notices printing process. If there is an error while calling common routine 
   to print notices, write the same in BATE_Y1 table with error code 'E1081 - Insufficient Data. Not able to generate Notice'*/
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
     
	  SAVE TRANSACTION SaveEftNoticeTran;
     			
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') ;
      
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ls_ErrorMessage_TEXT = '';
      -- Cursor variable validation
      SET @Ls_Sql_TEXT = 'Cursor Variables Validation';
      SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') ;

      SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Cursor_QNTY = ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_TopicIn_IDNO = 0;
      SET @Ln_Topic_IDNO = 0;

      DECLARE Case_Cur INSENSITIVE CURSOR FOR
       SELECT c.Case_IDNO
         FROM CASE_Y1 c,
              CMEM_Y1 e,
              ENSD_Y1 n
        WHERE e.MemberMci_IDNO = @Ln_NoticeCur_MemberMci_IDNO
          AND e.CaseRelationship_CODE = @Lc_CpRelationshipCase_CODE
          AND e.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
          AND e.Case_IDNO = c.Case_IDNO
          AND c.StatusCase_CODE = @Lc_OpenCaseStatus_CODE
          AND (c.TypeCase_CODE = @Lc_NonTanfWelfareType_CODE                 
           OR (c.TypeCase_CODE = @Lc_TypeCaseNonIVD_CODE
          AND c.CaseCategory_CODE <> @Lc_CaseCategoryDP_CODE))
          AND e.Case_IDNO = n.Case_IDNO
          AND n.TypeOrder_CODE <> @Lc_VoluntaryTypeOrder_CODE        
          AND EXISTS(
			SELECT 1
           FROM SORD_Y1 a
           WHERE Case_IDNO = e.Case_IDNO
			AND TypeOrder_CODE != @Lc_VoluntaryTypeOrder_CODE
			AND @Ld_Run_DATE BETWEEN OrderEffective_DATE AND OrderEnd_DATE
			AND EndValidity_DATE = @Ld_High_DATE
           )
          AND c.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitN_CODE);

      SET @Ls_Sql_TEXT = 'OPEN Case_Cur-1';
      SET @Ls_Sqldata_TEXT = '';

      OPEN Case_Cur;

      SET @Ls_Sql_TEXT = 'FETCH Case_Cur-1';
      SET @Ls_Sqldata_TEXT = '';

      FETCH NEXT FROM Case_Cur INTO @Ln_CaseCurCase_IDNO;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

      -- Run the logic only if a valid record exists in the cursor
      WHILE @Ln_FetchStatus_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
        SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_Note_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');
	    
        EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_Note_INDC,
         @An_EventFunctionalSeq_NUMB  = 0,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

        -- Check if the procedure ran properly
        IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END

        IF @Ln_TopicIn_IDNO = 0
         BEGIN
          SET @Lc_Notice_ID = @Lc_FIN25Notice_ID;
         END
        ELSE
         BEGIN
          SET @Lc_Notice_ID = @Lc_Space_TEXT;
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCurCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_CaseMajorActivity_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_GdidnActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_FmSubsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')  + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '')  + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '');

        EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @Ln_CaseCurCase_IDNO,
         @An_MemberMci_IDNO           = @Ln_NoticeCur_MemberMci_IDNO,
         @Ac_ActivityMajor_CODE       = @Lc_CaseMajorActivity_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_GdidnActivityMinor_CODE,
         @Ac_Subsystem_CODE           = @Lc_FmSubsystem_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_Notice_ID                = @Lc_Notice_ID,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
         @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
             BEGIN
              SET @Lc_TypeError_CODE=@Lc_ErrorTypeError_CODE;
              SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;

              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
             BEGIN
              SET @Lc_TypeError_CODE =@Lc_ErrorTypeError_CODE;
              SET @Lc_BateError_CODE = @Lc_Msg_CODE;

              RAISERROR (50001,16,1);
             END

        SET @Ln_TopicIn_IDNO = @Ln_Topic_IDNO;

        FETCH NEXT FROM Case_Cur INTO @Ln_CaseCurCase_IDNO;
		
        SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE Case_Cur;

      DEALLOCATE Case_Cur;

      SET @Ls_Sql_TEXT = 'SELECT DCRS_Y1 TABLE';
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST( @Ln_NoticeCur_MemberMci_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      SELECT @Ln_Value_QNTY = COUNT(1)
        FROM DCRS_Y1 d
       WHERE d.CheckRecipient_ID = @Ln_NoticeCur_MemberMci_IDNO
         AND d.EndValidity_DATE = @Ld_High_DATE;

      IF @Ln_Value_QNTY > 0
       BEGIN
        SET @Ls_Sql_TEXT = 'UPDATE RECORDS DCRS_Y1 TABLE';
        SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST( @Ln_NoticeCur_MemberMci_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'') + 'EventGlobalEndSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', RUN DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

        UPDATE DCRS_Y1
           SET EndValidity_DATE = @Ld_Run_DATE,
               EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
         WHERE CheckRecipient_ID = @Ln_NoticeCur_MemberMci_IDNO
           AND EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

        IF @Ln_RowsCount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'UPDATE DCRS_Y1 FAILED';

          RAISERROR(50001,16,1);
         END
       END

      SET @Ls_Sql_TEXT = 'INSERT RECORDS INTO DCRS TABLE';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') + ', Account_NUMB = ' + CAST(0 AS VARCHAR) + ', DebitCard_NUMB = ' + CAST(0 AS VARCHAR) + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_NoticesentStatus_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', ManualInitFlag_INDC = ' + ISNULL(@Lc_No_TEXT, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + CAST(0 AS VARCHAR) + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

      INSERT DCRS_Y1
             (CheckRecipient_ID,
              AccountBankNo_TEXT,
              RoutingBank_NUMB,
              DebitCard_NUMB,
              Status_DATE,
              Status_CODE,
              Reason_CODE,
              ManualInitFlag_INDC,
              EventGlobalBeginSeq_NUMB,
              EventGlobalEndSeq_NUMB,
              BeginValidity_DATE,
              EndValidity_DATE)
      VALUES ( @Ln_NoticeCur_MemberMci_IDNO,--CheckRecipient_ID
               0,--AccountBankNo_TEXT
               0,--RoutingBank_NUMB
               0,--DebitCard_NUMB
               @Ld_Run_DATE,--Status_DATE
               @Lc_NoticesentStatus_CODE,--Status_CODE 
               @Lc_Space_TEXT,--Reason_CODE 
               @Lc_No_TEXT,--ManualInitFlag_INDC 
               @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB 
               0,--EventGlobalEndSeq_NUMB 
               @Ld_Run_DATE,--BeginValidity_DATE 
               @Ld_High_DATE--EndValidity_DATE
      );

      SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

      -- Check if the Insert query executed properly
      IF @Ln_RowsCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT DCRS_Y1 FAILED';

        RAISERROR(50001,16,1);
       END

      IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
         AND @Ln_CommitFreqParm_QNTY != 0
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
	    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(CAST( @Ln_NoticeCur_MemberMci_IDNO AS VARCHAR ),'');
        
        EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
         @Ac_Job_ID                = @Lc_Job_ID,
         @Ad_Run_DATE              = @Ld_Run_DATE,
         @As_RestartKey_TEXT       = @Ln_NoticeCur_MemberMci_IDNO,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END

        COMMIT TRANSACTION EftNoticeTran;
		SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
        BEGIN TRANSACTION EftNoticeTran;

        SET @Ln_CommitFreq_QNTY = 0;
       END
     END TRY

     BEGIN CATCH   
	  IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SaveEftNoticeTran;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
        RAISERROR( 50001 ,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();     

	   IF CURSOR_STATUS ('local', 'Case_Cur') IN (0, 1)
		BEGIN
		 CLOSE Case_Cur;

		 DEALLOCATE Case_Cur;
		END
      
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     
      SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateError_CODE = ' + @Lc_BateError_CODE + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;
	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
		
      IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
		
      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
		SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END

     END CATCH

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT =  'ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION EftNoticeTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM Notice_Cur INTO @Ln_NoticeCur_MemberMci_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   CLOSE Notice_Cur;

   DEALLOCATE Notice_Cur;

	IF(@Ln_CursorRecordCount_QNTY = 0)
	BEGIN			
		SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;		
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
		SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_CursorRecordCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_NoRecordsToProcess_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
		
		EXECUTE BATCH_COMMON$SP_BATE_LOG	 
		 @As_Process_NAME			  = @Ls_Process_NAME,
		 @As_Procedure_NAME           = @Ls_Procedure_NAME,
		 @Ac_Job_ID                   = @Lc_Job_ID,
		 @Ad_Run_DATE                 = @Ld_Run_DATE,
		 @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
		 @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
		 @Ac_Error_CODE               = @Lc_BateError_CODE,
		 @As_DescriptionError_TEXT    = @Lc_NoRecordsToProcess_TEXT,
		 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
		 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
		 @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;
		
		IF @Lc_Msg_CODE=@Lc_FailedStatus_CODE
		BEGIN
		  RAISERROR (50001,16,1);
		END
	END

   --Upon successful completion, update the last run date in PARM_Y1 with the current run date.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_FailedStatus_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   --Log the error encountered or successful completion in BSTL/BSTL_Y1 for future references.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_SuccessStatus_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_SuccessStatus_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION EftNoticeTran;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EftNoticeTran;
    END;

   -- CURSOR_STATUS implementation:
   IF CURSOR_STATUS ('local', 'Notice_Cur') IN (0, 1)
    BEGIN
     CLOSE Notice_Cur;

     DEALLOCATE Notice_Cur;
    END

   -- CURSOR_STATUS implementation:
   IF CURSOR_STATUS ('local', 'Case_Cur') IN (0, 1)
    BEGIN
     CLOSE Case_Cur;

     DEALLOCATE Case_Cur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   --Set Error Description		
   IF ERROR_NUMBER() = 50001
    BEGIN
     SET @Ls_ErrorDesc_TEXT = @Ls_DescriptionError_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorDesc_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Process_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   --Update the Log in BSTL_Y1 as the Job is failed.
  
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_AbnormalEndStatus_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
