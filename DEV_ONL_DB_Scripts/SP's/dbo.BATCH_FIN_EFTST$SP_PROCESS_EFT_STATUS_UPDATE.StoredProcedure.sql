/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EFTST$SP_PROCESS_EFT_STATUS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_EFTST$SP_PROCESS_EFT_STATUS_UPDATE
Programmer Name	:	IMP Team.
Description		:	This batch process updates the status of Pre-Notes sent to PNC bank from 'Pre-Note Generated'
					  to 'Activated' when there is no rejects in the BATCH_FIN_EFT_SVC_PNOTE_REJECT batch for 3 
					  business days.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EFTST$SP_PROCESS_EFT_STATUS_UPDATE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ElectronicFundInstruction2150_NUMB INT = 2150,
          @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
          @Lc_FunctionUnidentified_CODE          CHAR (1) = 'U',
          @Lc_StatusA_CODE						 CHAR (1) = 'A',
          @Lc_StatusInactive_CODE                CHAR (1) = 'I',
          @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
          @Lc_NoteN_INDC                         CHAR (1) = 'N',
          @Lc_StatusCaseMemberActive_CODE        CHAR (1) = 'A',
          @Lc_TypeErrorE_CODE                    CHAR (1) = 'E',
          @Lc_CaseStatusOpen_CODE                CHAR (1) = 'O',
          @Lc_TypeOrderV_CODE                    CHAR (1) = 'V',
          @Lc_CaseRelationshipCp_CODE			 CHAR (1) = 'C',
          @Lc_SubSystemFm_CODE                   CHAR (2) = 'FM',
          @Lc_StatusEftActiveprenotegen_CODE     CHAR (2) = 'PG',
          @Lc_StatusEftActive_CODE               CHAR (2) = 'AC',
          @Lc_ActivityMajorCase_CODE             CHAR (4) = 'CASE',
          @Lc_BateErrorE1424_CODE                CHAR (5) = 'E1424',
          @Lc_ActivityMinorGdidn_CODE            CHAR (5) = 'GDIDN',
          @Lc_NoticeFin26_ID                     CHAR (6) = 'FIN-26',
          @Lc_Job_ID                             CHAR (7) = 'DEB0590',
          @Lc_Successful_TEXT                    CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                  CHAR (30) = 'BATCH',
          @Ls_Procedure_NAME                     VARCHAR (100) = 'SP_PROCESS_EFT_STATUS_UPDATE',
          @Ls_Process_NAME                       VARCHAR (100) = 'BATCH_FIN_EFTST',
          @Ld_High_DATE                          DATE = '12/31/9999';
  DECLARE @Ln_ExceptionThreshold_QNTY          NUMERIC (5) = 0,
		  @Ln_CommitFreq_QNTY				   NUMERIC (5),
          @Ln_CommitFreqParm_QNTY              NUMERIC (5),
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC (5),
          @Ln_ProcessRecordsCount_QNTY         NUMERIC (6) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
          @Ln_QNTY                             NUMERIC (10),
          @Ln_MemberMci_IDNO                   NUMERIC (10),
          @Ln_Error_NUMB                       NUMERIC (11),
          @Ln_ErrorLine_NUMB                   NUMERIC (11),
          @Ln_Topic_IDNO                       NUMERIC (11),
          @Ln_EventGlobalBeginSeq_NUMB         NUMERIC (19),
          @Ln_TransactionEventSeq_NUMB		   NUMERIC(19),
          @Ln_Rowcount_QNTY                    NUMERIC (19),
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Li_FetchStatusCaseCur_QNTY          SMALLINT,
          @Lc_Empty_TEXT                       CHAR (1) = '',
          @Lc_Msg_CODE                         CHAR (5),
          @Lc_BateError_CODE                   CHAR (5),
          @Ls_CursorLoc_TEXT                   VARCHAR (200),
          @Ls_BateRecord_TEXT                  VARCHAR (4000),
          @Ls_Sql_TEXT                         VARCHAR (4000),
          @Ls_Sqldata_TEXT                     VARCHAR (4000),
          @Ls_DescriptionError_TEXT            VARCHAR (4000),
          @Ls_ErrorMessage_TEXT                VARCHAR (4000),
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2;
  DECLARE @Lc_EftrCur_CheckRecipient_ID        CHAR(10),
          @Lc_EftrCur_CheckRecipient_CODE      CHAR(1),
          @Ln_EftrCur_RoutingBank_NUMB         NUMERIC(9),
          @Lc_EftrCur_AccountBankNo_TEXT       CHAR(17),
          @Lc_EftrCur_TypeAccount_CODE         CHAR(1),
          @Ld_EftrCur_PreNote_DATE             DATE,
          @Ld_EftrCur_FirstTransfer_DATE       DATE,
          @Ld_EftrCur_EftStatus_DATE           DATE,
          @Lc_EftrCur_StatusEft_CODE           CHAR(2),
          @Lc_EftrCur_Reason_CODE              CHAR(5),
          @Lc_EftrCur_Function_CODE            CHAR(3),
          @Lc_EftrCur_Misc_ID                  CHAR(11),
          @Ln_EftrCur_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Ln_EftrCur_EventGlobalEndSeq_NUMB   NUMERIC(19),
          @Ld_EftrCur_BeginValidity_DATE       DATE,
          @Ld_EftrCur_EndValidity_DATE         DATE;
  DECLARE @Ln_CaseCur_Case_IDNO NUMERIC(6);

  BEGIN TRY
   SET @Ld_Start_DATE  = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   /*
    	Get the current run date and last run date from PARM_Y1 (Parameters table), and validate 
    	that the batch program was not executed for the current run date, by ensuring that the run date 
    	is different from the last run date in the PARM_Y1 table.  Otherwise, an error message will be 
    	written into the Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) table, and the 
    	process will terminate.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Process_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(d, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ElectronicFundInstruction2150_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + @Lc_NoteN_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ElectronicFundInstruction2150_NUMB,
    @Ac_Process_ID              = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    @Ac_Note_INDC               = @Lc_NoteN_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalBeginSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   /*
   	Find the CP's EFT instruction, which is ten business days past the date of 
   	generation of pre-note in the Manage EFT Instructions (EFTI) screen/Electronic Fund Transfer (EFTR_Y1) table
   	EFT Status Date + 3 business days shuld be less than the process date and EFT Status code equal to 'PG'
   */
   DECLARE Eftr_CUR INSENSITIVE CURSOR FOR
    SELECT a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.RoutingBank_NUMB,
           a.AccountBankNo_TEXT,
           a.TypeAccount_CODE,
           a.PreNote_DATE,
           a.FirstTransfer_DATE,
           a.EftStatus_DATE,
           a.StatusEft_CODE,
           a.Reason_CODE,
           a.Function_CODE,
           a.Misc_ID,
           a.EventGlobalBeginSeq_NUMB,
           a.EventGlobalEndSeq_NUMB,
           a.BeginValidity_DATE,
           a.EndValidity_DATE
      FROM EFTR_Y1 a
     WHERE dbo.BATCH_COMMON$SF_CALCULATE_BUSINESS_DAYS(a.EftStatus_DATE, @Ld_Run_DATE, '1') > 3
       AND a.StatusEft_CODE = @Lc_StatusEftActiveprenotegen_CODE
       AND a.EndValidity_DATE = @Ld_High_DATE
     ORDER BY CheckRecipient_ID,
			  CheckRecipient_CODE,
              EventGlobalBeginSeq_NUMB;

   BEGIN TRANSACTION EftrStatus;

   SET @Ls_Sql_TEXT = 'OPEN Eftr_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Eftr_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Eftr_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Eftr_CUR INTO @Lc_EftrCur_CheckRecipient_ID, @Lc_EftrCur_CheckRecipient_CODE, @Ln_EftrCur_RoutingBank_NUMB, @Lc_EftrCur_AccountBankNo_TEXT, @Lc_EftrCur_TypeAccount_CODE, @Ld_EftrCur_PreNote_DATE, @Ld_EftrCur_FirstTransfer_DATE, @Ld_EftrCur_EftStatus_DATE, @Lc_EftrCur_StatusEft_CODE, @Lc_EftrCur_Reason_CODE, @Lc_EftrCur_Function_CODE, @Lc_EftrCur_Misc_ID, @Ln_EftrCur_EventGlobalBeginSeq_NUMB, @Ln_EftrCur_EventGlobalEndSeq_NUMB, @Ld_EftrCur_BeginValidity_DATE, @Ld_EftrCur_EndValidity_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    -- Cursor loop Started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
      BEGIN TRY
       SAVE TRANSACTION EftrStatusSave;
       SET @Ls_ErrorMessage_TEXT = '';
       SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
	   SET @Ln_MemberMci_IDNO = CAST(@Lc_EftrCur_CheckRecipient_ID AS NUMERIC);
       SET @Ls_BateRecord_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_EftrCur_CheckRecipient_ID, '0') + ', CheckRecipient_CODE = ' + @Lc_EftrCur_CheckRecipient_CODE + ', RoutingBank_NUMB = ' + ISNULL(CAST(@Ln_EftrCur_RoutingBank_NUMB AS VARCHAR), '0') + ', AccountBankNo_TEXT = ' + @Lc_EftrCur_AccountBankNo_TEXT + ', TypeAccount_CODE = ' + @Lc_EftrCur_TypeAccount_CODE + ', PreNote_DATE = ' + CAST(@Ld_EftrCur_PreNote_DATE AS VARCHAR) + ', TypeAccount_CODE = ' + @Lc_EftrCur_TypeAccount_CODE + ', FirstTransfer_DATE = ' + CAST(@Ld_EftrCur_FirstTransfer_DATE AS VARCHAR) + ', EftStatus_DATE = ' + CAST(@Ld_EftrCur_EftStatus_DATE AS VARCHAR) + ', StatusEft_CODE = ' + @Lc_EftrCur_StatusEft_CODE + ', Reason_CODE = ' + @Lc_EftrCur_Reason_CODE + ', Function_CODE = ' + @Lc_EftrCur_Function_CODE + ', Misc_ID = ' + @Lc_EftrCur_Misc_ID + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EftrCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '0') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST(@Ln_EftrCur_EventGlobalEndSeq_NUMB AS VARCHAR), '0') + ', BeginValidity_DATE = ' + CAST(@Ld_EftrCur_BeginValidity_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_EftrCur_EndValidity_DATE AS VARCHAR);
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
       -- End date the record received in the above cursor.
       SET @Ls_Sql_TEXT = 'END DATE EFTR_Y1 RECORD';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_EftrCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_EftrCur_CheckRecipient_CODE, '') + ', StatusEft_CODE = ' + ISNULL(@Lc_StatusEftActiveprenotegen_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE EFTR_Y1
          SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB,
              EndValidity_DATE = @Ld_Run_DATE
         FROM EFTR_Y1
        WHERE CheckRecipient_ID = @Lc_EftrCur_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_EftrCur_CheckRecipient_CODE
          AND StatusEft_CODE = @Lc_StatusEftActiveprenotegen_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE EFTR_Y1 FAILED ';

         RAISERROR(50001,16,1);
        END

       /*
       	Insert a new record with the same information except change the Status which will be  
       	'AC' - Active EFT instructions records in EFTI/EFTR_Y1.
       */
       SET @Ls_Sql_TEXT = 'INSERT DCRS_Y1 WITH ACTIVE STATUS CODE';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_EftrCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_EftrCur_CheckRecipient_CODE, '') + ', RoutingBank_NUMB = ' + CAST(@Ln_EftrCur_RoutingBank_NUMB AS VARCHAR) + ', AccountBankNo_TEXT = ' + @Lc_EftrCur_AccountBankNo_TEXT + ', TypeAccount_CODE = ' + @Lc_EftrCur_TypeAccount_CODE + ', PreNote_DATE = ' + CAST(@Ld_EftrCur_PreNote_DATE AS VARCHAR) + ', FirstTransfer_DATE = ' + CAST(@Ld_EftrCur_FirstTransfer_DATE AS VARCHAR) + ', EftStatus_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', StatusEftActive_CODE = ' + @Lc_StatusEftActive_CODE + ', Reason_CODE = ' + @Lc_EftrCur_Reason_CODE + ', Function_CODE = ' + @Lc_FunctionUnidentified_CODE + ', Misc_ID = ' + @Lc_EftrCur_Misc_ID + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', EventGlobalEndSeq_NUMB = ' + CAST('0' AS VARCHAR) + ', BeginValidity_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       INSERT EFTR_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               RoutingBank_NUMB,
               AccountBankNo_TEXT,
               TypeAccount_CODE,
               PreNote_DATE,
               FirstTransfer_DATE,
               EftStatus_DATE,
               StatusEft_CODE,
               Reason_CODE,
               Function_CODE,
               Misc_ID,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               BeginValidity_DATE,
               EndValidity_DATE)
       VALUES ( @Lc_EftrCur_CheckRecipient_ID,--CheckRecipient_ID
                @Lc_EftrCur_CheckRecipient_CODE,--CheckRecipient_CODE
                @Ln_EftrCur_RoutingBank_NUMB,--RoutingBank_NUMB
                @Lc_EftrCur_AccountBankNo_TEXT,--AccountBankNo_TEXT
                @Lc_EftrCur_TypeAccount_CODE,--TypeAccount_CODE
                @Ld_EftrCur_PreNote_DATE,--PreNote_DATE
                @Ld_EftrCur_FirstTransfer_DATE,--FirstTransfer_DATE
                @Ld_Run_DATE,-- EftStatus_DATE
                @Lc_StatusEftActive_CODE,--StatusEft_CODE
                @Lc_EftrCur_Reason_CODE,--Reason_CODE
                @Lc_FunctionUnidentified_CODE,--Function_CODE
                @Lc_EftrCur_Misc_ID,--Misc_ID
                @Ln_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
                0,-- EventGlobalEndSeq_NUMB
                @Ld_Run_DATE,-- BeginValidity_DATE 
                @Ld_High_DATE); -- EndValidity_DATE

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT EFTR_Y1 FAILED ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         -- Select the cases associate with this check recipient id then passs to BATCH_COMMON$SP_INSERT_ACTIVITY
         SET @Ls_Sql_TEXT = 'SELECT CASE ID FOR CHECK RECIPIENT';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR);

         DECLARE Case_CUR INSENSITIVE CURSOR FOR
          SELECT a.Case_IDNO
            FROM CMEM_Y1 a,
                 CASE_Y1 b
           WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
             AND a.Case_IDNO = b.Case_IDNO
             AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
             AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
             -- Support order should exist
             AND EXISTS (SELECT 1
                           FROM SORD_Y1 s
                          WHERE s.Case_IDNO = b.Case_IDNO
                            AND s.TypeOrder_CODE != @Lc_TypeOrderV_CODE
                            AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
                            AND s.EndValidity_DATE = @Ld_High_DATE);

         SET @Ls_Sql_TEXT = 'OPEN Case_CUR';
         SET @Ls_Sqldata_TEXT = '';

         OPEN Case_CUR;

         SET @Ls_Sql_TEXT = 'FETCH Case_CUR - 1';
         SET @Ls_Sqldata_TEXT = '';

         FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

         SET @Li_FetchStatusCaseCur_QNTY = @@FETCH_STATUS;

         BEGIN
         -- Notice cursor started
          WHILE @Li_FetchStatusCaseCur_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
			SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_NoteN_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');
		    
			EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			 @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
			 @Ac_Process_ID               = @Lc_Job_ID,
			 @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
			 @Ac_Note_INDC                = @Lc_NoteN_INDC,
			 @An_EventFunctionalSeq_NUMB  = @Li_ElectronicFundInstruction2150_NUMB,
			 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
			 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			 @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			 BEGIN
			  RAISERROR(50001,16,1);
			 END
            /*
            When the status changes to 'AC' - Active EFT, a forms generation procedure invoked with the Form ID of 'FIN-26'. 
            This will result in the creation of records in the Notice Message Queue (NMRQ_Y1) table to be processed by a subsequent batch 
            notices printing process. If there is an error while calling common routine to print notices, write the same in BATE_Y1 
            table with error code 'E1081 - Insufficient Data. Not able to generate Notice'
            */
            SET @Ls_Sql_TEXT = 'GENERATE NOTICE FOR CP :: BATCH_COMMON$SP_INSERT_ACTIVITY';
            SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '0') + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorGdidn_CODE + ', ReasonStatus_CODE = ' + ''+ ', Subsystem_CODE = ' + @Lc_SubSystemFm_CODE + ', WorkerUpdate_ID = ' + @Lc_BatchRunUser_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Notice_ID = ' + @Lc_NoticeFin26_ID + ', Job_ID = ' + @Lc_Job_ID + ', TransactionEventSeq_NUMB = ' + CAST('0' AS VARCHAR);
            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
             @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorGdidn_CODE,
             @Ac_ReasonStatus_CODE        = '',
             @Ac_Subsystem_CODE           = @Lc_SubSystemFm_CODE,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_Notice_ID                = @Lc_NoticeFin26_ID,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;
             
			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
             BEGIN
              SET @Lc_BateError_CODE = @Lc_Msg_CODE;
              RAISERROR (50001,16,1);
             END
			
			SET @Ls_Sql_TEXT = 'FETCH Case_CUR - 2';
            SET @Ls_Sqldata_TEXT = ''; 
            FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

            SET @Li_FetchStatusCaseCur_QNTY = @@FETCH_STATUS;
           END
         END
        END

       CLOSE Case_CUR;

       DEALLOCATE Case_CUR;

       -- EFT and SVC Status both cannot be active 
       -- Making SVC account inactive when EFT becomes active
       SET @Ls_Sql_TEXT = 'SELECT DCRS_Y1 RECORD QUANTITY';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + @Lc_EftrCur_CheckRecipient_ID + ', Status_CODE = ' + @Lc_StatusA_CODE + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);
       SELECT @Ln_QNTY = COUNT(1)
         FROM DCRS_Y1 e
        WHERE e.CheckRecipient_ID = @Lc_EftrCur_CheckRecipient_ID
          AND e.Status_CODE = @Lc_StatusA_CODE
          AND e.EndValidity_DATE = @Ld_High_DATE;

       IF @Ln_QNTY > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'END DATE DCRS_Y1 RECORD';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + @Lc_EftrCur_CheckRecipient_ID + ', Status_CODE = ' + @Lc_StatusA_CODE + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

         UPDATE DCRS_Y1
            SET EndValidity_DATE = @Ld_Run_DATE,
                EventGlobalEndSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB
           FROM DCRS_Y1 e
          WHERE e.CheckRecipient_ID = @Lc_EftrCur_CheckRecipient_ID
            AND e.Status_CODE = @Lc_StatusA_CODE
            AND e.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

         IF @Ln_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT DCRS FAILED';

           RAISERROR(50001,16,1);
          END

         /*
         	In addition, the batch will convert the Stored Value Card Information (SVCI) screen Status 
         	(Status_CODE of the Debit Card Recipients (DCRS_Y1) table) to 'I-Inactive' 
         	when the EFT Status (StatusEft_CODE of the Electronic File Transfer (EFTR_Y1) table) 
         	is changed to 'AC-Active' for a recipient.
         */
         SET @Ls_Sql_TEXT = 'INSERT DCRS_Y1 WITH INACTIVE STATUS CODE';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + CAST(@Lc_EftrCur_CheckRecipient_ID AS VARCHAR) + ', Status_CODE = ' + @Lc_StatusA_CODE + ', EndValidity_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_EventGlobalBeginSeq_NUMB AS VARCHAR);
         INSERT DCRS_Y1
                (CheckRecipient_ID,
                 RoutingBank_NUMB,
                 AccountBankNo_TEXT,
                 Status_DATE,
                 Status_CODE,
                 Reason_CODE,
                 ManualInitFlag_INDC,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 DebitCard_NUMB)
         SELECT e.CheckRecipient_ID,
                e.RoutingBank_NUMB,
                e.AccountBankNo_TEXT,
                @Ld_Run_DATE AS Status_DATE,
                @Lc_StatusInactive_CODE AS Status_CODE,
                e.Reason_CODE,
                e.ManualInitFlag_INDC,
                @Ln_EventGlobalBeginSeq_NUMB AS EventGlobalBeginSeq_NUMB,
                0 AS EventGlobalEndSeq_NUMB,
                @Ld_Run_DATE AS BeginValidity_DATE,
                @Ld_High_DATE AS EndValidity_DATE,
                e.DebitCard_NUMB
           FROM DCRS_Y1 e
          WHERE e.CheckRecipient_ID = @Lc_EftrCur_CheckRecipient_ID
            AND e.Status_CODE = @Lc_StatusA_CODE
            AND e.EndValidity_DATE = @Ld_Run_DATE
            AND e.EventGlobalEndSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB;

         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

         IF @Ln_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT INTO DCRS_Y1 FAILED ';

           RAISERROR(50001,16,1);
          END
        END
        
      END TRY

      BEGIN CATCH
     
        -- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	    BEGIN
	   	   ROLLBACK TRANSACTION EftrStatusSave
		END
		ELSE
		BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		END
		
       -- Check if cursor is open close and deallocate it
       IF CURSOR_STATUS('LOCAL', 'Case_CUR') IN (0, 1)
        BEGIN
         CLOSE Case_CUR;

         DEALLOCATE Case_CUR;
        END

       -- Check for Exception information to log the description text based on the error
       SET @Ln_Error_NUMB = ERROR_NUMBER ();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

       IF @Ln_Error_NUMB <> 50001
        BEGIN
         SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
        END

       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = @Ls_Procedure_NAME,
        @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = @Ln_Error_NUMB,
        @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_ErrorMessage_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_CommitFreq_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END CATCH

      SET @Ln_ProcessRecordsCount_QNTY = @Ln_ProcessRecordsCount_QNTY + 1;
	  
	  SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK';
	  SET @Ls_Sqldata_TEXT = 'CommitFreq_QNTY = ' + ISNULL(CAST(@Ln_CommitFreq_QNTY AS VARCHAR),'') + ', CommitFreqParm_QNTY = ' + ISNULL(CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR),'');
      IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
       BEGIN
        COMMIT TRANSACTION EftrStatus;

        SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;

        BEGIN TRANSACTION EftrStatus;

        SET @Ln_CommitFreq_QNTY = 0;
       END

	  SET @Ls_Sql_TEXT = 'THRESHOLD COUNT CHECK';
	  SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + ISNULL(CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR),'') + ', ExceptionThresholdParm_QNTY = ' + ISNULL(CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR),'');
      IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
       BEGIN
        COMMIT TRANSACTION EftrStatus;
        SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessRecordsCount_QNTY;
        SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'FETCH Eftr_CUR - 2';
      
      SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_EftrCur_CheckRecipient_ID, '0') + ', CheckRecipient_CODE = ' + @Lc_EftrCur_CheckRecipient_CODE + ', RoutingBank_NUMB = ' + ISNULL(CAST(@Ln_EftrCur_RoutingBank_NUMB AS VARCHAR), '0') + ', AccountBankNo_TEXT = ' + @Lc_EftrCur_AccountBankNo_TEXT + ', TypeAccount_CODE = ' + @Lc_EftrCur_TypeAccount_CODE + ', PreNote_DATE = ' + CAST(@Ld_EftrCur_PreNote_DATE AS VARCHAR) + ', TypeAccount_CODE = ' + @Lc_EftrCur_TypeAccount_CODE + ', FirstTransfer_DATE = ' + CAST(@Ld_EftrCur_FirstTransfer_DATE AS VARCHAR) + ', EftStatus_DATE = ' + CAST(@Ld_EftrCur_EftStatus_DATE AS VARCHAR) + ', StatusEft_CODE = ' + @Lc_EftrCur_StatusEft_CODE + ', Reason_CODE = ' + @Lc_EftrCur_Reason_CODE + ', Function_CODE = ' + @Lc_EftrCur_Function_CODE + ', Misc_ID = ' + @Lc_EftrCur_Misc_ID + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EftrCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '0') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST(@Ln_EftrCur_EventGlobalEndSeq_NUMB AS VARCHAR), '0') + ', BeginValidity_DATE = ' + CAST(@Ld_EftrCur_BeginValidity_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_EftrCur_EndValidity_DATE AS VARCHAR);

      FETCH NEXT FROM Eftr_CUR INTO @Lc_EftrCur_CheckRecipient_ID, @Lc_EftrCur_CheckRecipient_CODE, @Ln_EftrCur_RoutingBank_NUMB, @Lc_EftrCur_AccountBankNo_TEXT, @Lc_EftrCur_TypeAccount_CODE, @Ld_EftrCur_PreNote_DATE, @Ld_EftrCur_FirstTransfer_DATE, @Ld_EftrCur_EftStatus_DATE, @Lc_EftrCur_StatusEft_CODE, @Lc_EftrCur_Reason_CODE, @Lc_EftrCur_Function_CODE, @Lc_EftrCur_Misc_ID, @Ln_EftrCur_EventGlobalBeginSeq_NUMB, @Ln_EftrCur_EventGlobalEndSeq_NUMB, @Ld_EftrCur_BeginValidity_DATE, @Ld_EftrCur_EndValidity_DATE;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Eftr_CUR;

   DEALLOCATE Eftr_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Ls_CursorLoc_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Empty_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessRecordsCount_QNTY AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessRecordsCount_QNTY;

   COMMIT TRANSACTION EftrStatus;
  END TRY

  BEGIN CATCH
  
  -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EftrStatus;
    END
   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS('LOCAL', 'Case_CUR') IN (0, 1)
    BEGIN
     CLOSE Case_CUR;

     DEALLOCATE Case_CUR;
    END

   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS('LOCAL', 'Eftr_CUR') IN (0, 1)
    BEGIN
     CLOSE Eftr_CUR;

     DEALLOCATE Eftr_CUR;
    END

   -- Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusA_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
