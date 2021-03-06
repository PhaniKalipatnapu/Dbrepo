/****** Object:  StoredProcedure [dbo].[BATCH_PORTAL_UPDATE$SP_CPORTAL_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_PORTAL_UPDATE$SP_CPORTAL_UPDATE
Programmer Name	:	IMP Team.
Description		:	This batch will be used to update DECSS database tables with information provided by the Customer Service Portal 
					  (CPortal) during maintenance hours.
Frequency		:	'DAILY'
Developed On	:	6/1/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_PORTAL_UPDATE$SP_CPORTAL_UPDATE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusAlertRequested_CODE  CHAR(1) = 'B',
          @Lc_StatusPending_CODE         CHAR(1) = 'P',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_ErrorTypeE_CODE			 CHAR(1) = 'E',
          @Lc_SuccessStatus_CODE         CHAR(1) = 'S',
          @Lc_Note_INDC                  CHAR(1) = 'N',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_StatusAbnormalend_CODE     CHAR(1) = 'A',
          @Lc_TypeMessageMail_CODE       CHAR(1) = 'A',
          @Lc_ModeBatch_CODE             CHAR(1) = 'B',
          @Lc_ModeOnline_CODE            CHAR(1) = 'O',
          @Lc_CsSubsystem_CODE           CHAR(3) = 'CS',
          @Lc_CaseMajorActivity_CODE     CHAR(4) = 'CASE',
          @Lc_RcwsuActivityMinor_CODE    CHAR(5) = 'RCWSU',
          @Lc_RcwibActivityMinor_CODE    CHAR(5) = 'RCWIB',
          @Lc_RcwixActivityMinor_CODE    CHAR(5) = 'RCWIX',
          @Lc_ErrorE1424_CODE            CHAR(5) = 'E1424',
          @Lc_ErrorNoRecords_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                     CHAR(7) = 'DEB9021',          
          @Lc_DescriptionModeOnline_TEXT CHAR(15) = 'ONLINE CPORTAL',
          @Lc_Successful_TEXT            CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT          CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME             VARCHAR(60) = 'SP_CPORTAL_UPDATE',
          @Ls_Process_NAME               VARCHAR(100) = 'BATCH_PORTAL_UPDATE',
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Ld_Low_DATE                   DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB                  NUMERIC,
          @Ln_ErrorLine_NUMB              NUMERIC,
          @Ln_Rowcount_QNTY               NUMERIC,
          @Ln_FetchStatus_QNTY            NUMERIC,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_Line_NUMB                   NUMERIC(10),
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_Cursor_QNTY                 NUMERIC(10) = 0,
          @Ln_CursorCcadd_QNTY            NUMERIC(10) = 0,
          @Ln_CursorCcoti_QNTY            NUMERIC(10) = 0,
          @Ln_CursorCcedt_QNTY            NUMERIC(10) = 0,
          @Ln_CursorCmsgs_QNTY            NUMERIC(10) = 0,
          @Ln_CursorCapcs_QNTY            NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Lc_Empty_TEXT                  CHAR = '',
          @Lc_TypeError_CODE              CHAR(1),
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_BateError_CODE              CHAR(5),
          @Lc_ActivityMinor_CODE          CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ln_CportalCur_Case_IDNO                NUMERIC(6),
          @Ln_CportalCur_MemberMCI_IDNO           NUMERIC(10),
          @Ln_CportalCur_WorkPhone_NUMB           NUMERIC(15),
          @Ln_CportalCur_HomePhone_NUMB           NUMERIC(15),
          @Ln_CportalCur_PagerCell_NUMB           NUMERIC(15),
          @Ln_CportalCur_Phone_NUMB               NUMERIC(15),
          @Ln_CportalCur_EventGlobalSeq_NUMB      NUMERIC(19),
          @Ln_CportalCur_MessageReplySeq_NUMB     NUMERIC(19),
          @Lc_CportalCur_InfoGivenBy_CODE         CHAR(1),
          @Lc_CportalCur_Status_CODE              CHAR(1),
          @Lc_CportalCur_TypeMessage_CODE         CHAR(1),
          @Lc_CportalCur_MessageStatus_CODE       CHAR(1),
          @Lc_CportalCur_Reason_CODE              CHAR(2),
          @Lc_CportalCur_State_ADDR               CHAR(2),
          @Lc_CportalCur_Country_ADDR             CHAR(2),
          @Lc_CportalCur_TypeEmployment_CODE      CHAR(2),
          @Lc_CportalCur_Zip_ADDR                 CHAR(15),
          @Lc_CportalCur_City_ADDR                CHAR(28),
          @Lc_CportalCur_IamUser_ID               CHAR(30),
          @Lc_CportalCur_WorkerUpdate_ID          CHAR(30),
          @Lc_CportalCur_Employer_NAME            CHAR(40),
          @Lc_CportalCur_Attn_ADDR                CHAR(40),
          @Lc_CportalCur_MessageSendFrom_NAME     CHAR(40),
          @Ls_CportalCur_Line1_ADDR               VARCHAR(50),
          @Ls_CportalCur_Line2_ADDR               VARCHAR(50),
          @Ls_CportalCur_DescriptionSubject_TEXT  VARCHAR(50),
          @Ls_CportalCur_DescriptionReason_TEXT   VARCHAR(70),
          @Ls_CportalCur_Contact_EML              VARCHAR(100),
          @Ls_CportalCur_DescriptionComments_TEXT VARCHAR(1000),
          @Ls_CportalCur_DescriptionMessage_TEXT  VARCHAR(2000),
          @Ld_CportalCur_Create_DATE              DATE,
          @Ld_CportalCur_BeginValidity_DATE       DATE,
          @Ld_CportalCur_BeginEmployment_DATE     DATE,
          @Ld_CportalCur_Update_DTTM              DATETIME2,
          @Ls_CportalSql_TEXT                     VARCHAR(100),
          @Ls_CportalSqldata_TEXT                 VARCHAR(1000),
          @Ln_CportalError_NUMB                   NUMERIC,
          @Ln_CportalErrorLine_NUMB               NUMERIC,
          @Lc_CportalMsg_CODE                     CHAR(5);

  BEGIN TRY
   BEGIN TRANSACTION CPORTAL_UPDATE;

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
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   -- Check if the procedure executed properly	
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ld_LastRun_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF @Ld_LastRun_DATE > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END
    
   -- Select records from CCADD_Y1 table where status code is 'B-ALERT REQUESTED'.
   DECLARE Ccadd_CUR INSENSITIVE CURSOR FOR
    SELECT a.MemberMCI_IDNO,
           a.IamUser_ID,
           a.Case_IDNO,
           a.InfoGivenBy_CODE,
           a.Line1_ADDR,
           a.Line2_ADDR,
           a.City_ADDR,
           a.State_ADDR,
           a.Zip_ADDR,
           a.Country_ADDR,
           a.DescriptionComments_TEXT,
           a.Status_CODE,
           a.Reason_CODE,
           a.DescriptionReason_TEXT,
           a.Create_DATE,
           a.WorkerUpdate_ID,
           a.BeginValidity_DATE,
           a.Update_DTTM,
           a.EventGlobalSeq_NUMB
      FROM CCADD_Y1 a
     WHERE a.Status_CODE = @Lc_StatusAlertRequested_CODE

   
   SET @Ls_Sql_TEXT = 'OPEN Ccadd_CUR-1';
   SET @Ls_Sqldata_TEXT = '';
   
   OPEN Ccadd_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Ccadd_CUR-1';
   SET @Ls_Sqldata_TEXT = '';


   FETCH NEXT FROM Ccadd_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_IamUser_ID, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_InfoGivenBy_CODE, @Ls_CportalCur_Line1_ADDR, @Ls_CportalCur_Line2_ADDR, @Lc_CportalCur_City_ADDR, @Lc_CportalCur_State_ADDR, @Lc_CportalCur_Zip_ADDR, @Lc_CportalCur_Country_ADDR, @Ls_CportalCur_DescriptionComments_TEXT, @Lc_CportalCur_Status_CODE, @Lc_CportalCur_Reason_CODE, @Ls_CportalCur_DescriptionReason_TEXT, @Ld_CportalCur_Create_DATE, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;
   
   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
    
   --WHILE LOOP FOR CCADD_Y1 TABLE
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION CPORTAL_UPDATE_SAVE_CCADD;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorCcadd_QNTY = @Ln_Cursor_QNTY;
      SET @Ln_Topic_IDNO = 0;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', InfoGivenBy_CODE = ' + ISNULL(@Lc_CportalCur_InfoGivenBy_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_CportalCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_CportalCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(CAST(@Lc_CportalCur_City_ADDR AS VARCHAR), '') + ', State_ADDR = ' + ISNULL(@Lc_CportalCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(CAST(@Lc_CportalCur_Zip_ADDR AS VARCHAR), '') + ', Country_ADDR = ' + ISNULL(@Lc_CportalCur_Country_ADDR, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionComments_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_CportalCur_Status_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_CportalCur_Reason_CODE, '') + ', DescriptionReason_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionReason_TEXT, '') + ', Create_DATE = ' + ISNULL(CAST(@Ld_CportalCur_Create_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Lc_CportalCur_WorkerUpdate_ID AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_CportalCur_BeginValidity_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_CportalCur_Update_DTTM AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_EventGlobalSeq_NUMB AS VARCHAR), '');
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT ';
      SET @Ls_Sqldata_TEXT = 'TransactionMode_CODE = ' + @Lc_ModeBatch_CODE + ', IamUser_ID = ' + @Lc_CportalCur_IamUser_ID
          
      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_Note_INDC,
       @An_EventFunctionalSeq_NUMB = 0,
       @An_TransactionEventSeq_NUMB= @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY_1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_CaseMajorActivity_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_RcwsuActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_CsSubsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '')

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @An_MemberMci_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_CaseMajorActivity_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_RcwsuActivityMinor_CODE,
       @Ac_Subsystem_CODE           = @Lc_CsSubsystem_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

	  SET @Ls_Sql_TEXT = 'BATCH_CPORTAL_UPDATE$SP_CUSTOMER_ADDRESS_UPDATE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '') + ', InfoGivenBy_CODE = ' + ISNULL(CAST(@Lc_CportalCur_InfoGivenBy_CODE AS VARCHAR), '')      
      + ', Status_CODE = ' + ISNULL(CAST(@Lc_CportalCur_Status_CODE AS VARCHAR), '') + ', Reason_CODE = ' + ISNULL(CAST(@Lc_CportalCur_Reason_CODE AS VARCHAR), '') + ', Create_DATE = ' + ISNULL(CAST(@Ld_CportalCur_Create_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Lc_CportalCur_WorkerUpdate_ID AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '')
      
      -- Address Update function on CPORTAL Database.
      EXECUTE BATCH_CPORTAL_UPDATE$SP_CUSTOMER_ADDRESS_UPDATE
       @An_MemberMCI_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_IamUser_ID               = @Lc_CportalCur_IamUser_ID,
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @Ac_InfoGivenBy_CODE         = @Lc_CportalCur_InfoGivenBy_CODE,
       @As_Line1_ADDR               = @Ls_CportalCur_Line1_ADDR,
       @As_Line2_ADDR               = @Ls_CportalCur_Line2_ADDR,
       @Ac_City_ADDR                = @Lc_CportalCur_City_ADDR,
       @Ac_State_ADDR               = @Lc_CportalCur_State_ADDR,
       @Ac_Zip_ADDR                 = @Lc_CportalCur_Zip_ADDR,
       @Ac_Country_ADDR             = @Lc_CportalCur_Country_ADDR,
       @As_DescriptionComments_TEXT = @Ls_CportalCur_DescriptionComments_TEXT,
       @Ac_Status_CODE              = @Lc_CportalCur_Status_CODE,
       @Ac_Reason_CODE              = @Lc_CportalCur_Reason_CODE,
       @As_DescriptionReason_TEXT   = @Ls_CportalCur_DescriptionReason_TEXT,
       @Ad_Create_DATE              = @Ld_CportalCur_Create_DATE,
       @Ac_WorkerUpdate_ID          = @Lc_CportalCur_WorkerUpdate_ID,
       @Ad_BeginValidity_DATE       = @Ld_CportalCur_BeginValidity_DATE,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ad_Update_DTTM              = @Ld_CportalCur_Update_DTTM,
       @An_EventGlobalSeq_NUMB      = @Ln_CportalCur_EventGlobalSeq_NUMB,      
       @As_ErrorMessage_TEXT        = @Ls_DescriptionError_TEXT OUTPUT,
       @As_Sql_TEXT                 = @Ls_CportalSql_TEXT OUTPUT,
       @As_Sqldata_TEXT             = @Ls_CportalSqldata_TEXT OUTPUT,
       @An_Error_NUMB               = @Ln_CportalError_NUMB OUTPUT,
       @An_ErrorLine_NUMB           = @Ln_CportalErrorLine_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_CportalMsg_CODE OUTPUT;


      IF(@Lc_CportalMsg_CODE <> @Lc_SuccessStatus_CODE)
       BEGIN        
        SET @Ls_Sql_TEXT = @Ls_CportalSql_TEXT;        
        SET @Ls_Sqldata_TEXT = @Ls_CportalSqldata_TEXT;        
        SET @Ln_Error_NUMB = @Ln_CportalError_NUMB;        
        SET @Ln_ErrorLine_NUMB = @Ln_CportalErrorLine_NUMB;
        RAISERROR (50001,16,1);
       END
       
     END TRY

     BEGIN CATCH
      -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION CPORTAL_UPDATE_SAVE_CCADD;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
         RAISERROR( 50001,16,1);
        END
        
      IF CURSOR_STATUS ('VARIABLE', 'Ccadd_CUR') IN (0, 1)
       BEGIN
        CLOSE Ccadd_CUR;

        DEALLOCATE Ccadd_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
	   
	   IF @Lc_Msg_CODE = @Lc_ErrorTypeE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
                
     END CATCH
     
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY != 0
      BEGIN
       COMMIT TRANSACTION CPORTAL_UPDATE;

       BEGIN TRANSACTION CPORTAL_UPDATE;

       SET @Ln_CommitFreq_QNTY = 0;
      END
       
	 SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION CPORTAL_UPDATE;
       
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END
	 
     SET @Ls_Sql_TEXT = 'FETCH Ccadd_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ccadd_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_IamUser_ID, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_InfoGivenBy_CODE, @Ls_CportalCur_Line1_ADDR, @Ls_CportalCur_Line2_ADDR, @Lc_CportalCur_City_ADDR, @Lc_CportalCur_State_ADDR, @Lc_CportalCur_Zip_ADDR, @Lc_CportalCur_Country_ADDR, @Ls_CportalCur_DescriptionComments_TEXT, @Lc_CportalCur_Status_CODE, @Lc_CportalCur_Reason_CODE, @Ls_CportalCur_DescriptionReason_TEXT, @Ld_CportalCur_Create_DATE, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Ccadd_CUR';
   SET @Ls_Sqldata_TEXT = '';

   CLOSE Ccadd_CUR;

   DEALLOCATE Ccadd_CUR;   
    
   IF @Ln_CursorCcadd_QNTY = 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) IN Ccadd_CUR TO PROCESS';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
      @An_Line_NUMB                = @Ln_CursorCcadd_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
    -- End Of the Customer Address Update function
    
   -- Select records from CCOTI_Y1 table where status code is 'B-ALERT REQUESTED'.
   DECLARE Ccoti_CUR INSENSITIVE CURSOR FOR
    SELECT a.MemberMCI_IDNO,
           a.IamUser_ID,
           a.Case_IDNO,
           a.InfoGivenBy_CODE,
           a.WorkPhone_NUMB,
           a.HomePhone_NUMB,
           a.PagerCell_NUMB,
           a.Contact_EML,
           a.DescriptionComments_TEXT,
           a.Status_CODE,
           a.Reason_CODE,
           a.DescriptionReason_TEXT,
           a.Create_DATE,
           a.WorkerUpdate_ID,
           a.BeginValidity_DATE,
           a.Update_DTTM,
           a.EventGlobalSeq_NUMB
      FROM CCOTI_Y1 a
     WHERE a.Status_CODE = @Lc_StatusAlertRequested_CODE

  
   SET @Ls_Sql_TEXT = 'OPEN Ccoti_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Ccoti_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Ccoti_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Ccoti_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_IamUser_ID, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_InfoGivenBy_CODE, @Ln_CportalCur_WorkPhone_NUMB, @Ln_CportalCur_HomePhone_NUMB, @Ln_CportalCur_PagerCell_NUMB, @Ls_CportalCur_Contact_EML, @Ls_CportalCur_DescriptionComments_TEXT, @Lc_CportalCur_Status_CODE, @Lc_CportalCur_Reason_CODE, @Ls_CportalCur_DescriptionReason_TEXT, @Ld_CportalCur_Create_DATE, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   --WHILE LOOP FOR CCOTI_Y1 TABLE
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION CPORTAL_UPDATE_SAVE_CCOTI;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorCcoti_QNTY = @Ln_Cursor_QNTY;
      SET @Ln_Topic_IDNO = 0;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', InfoGivenBy_CODE = ' + ISNULL(@Lc_CportalCur_InfoGivenBy_CODE, '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_WorkPhone_NUMB AS VARCHAR), '') + ', HomePhone_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_HomePhone_NUMB AS VARCHAR), '') + ', PagerCell_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_PagerCell_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Ls_CportalCur_Contact_EML, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionComments_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_CportalCur_Status_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_CportalCur_Reason_CODE, '') + ', DescriptionReason_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionReason_TEXT, '') + ', Create_DATE = ' + ISNULL(CAST(@Ld_CportalCur_Create_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Lc_CportalCur_WorkerUpdate_ID AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_CportalCur_BeginValidity_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_CportalCur_Update_DTTM AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_EventGlobalSeq_NUMB AS VARCHAR), '');
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT ';
      SET @Ls_Sqldata_TEXT = 'TransactionMode_CODE = ' + @Lc_ModeBatch_CODE + ', IamUser_ID = ' + @Lc_CportalCur_IamUser_ID

	  EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_Note_INDC,
       @An_EventFunctionalSeq_NUMB = 0,
       @An_TransactionEventSeq_NUMB= @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY_2';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_CaseMajorActivity_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_RcwsuActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_CsSubsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @An_MemberMci_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_CaseMajorActivity_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_RcwsuActivityMinor_CODE,
       @Ac_Subsystem_CODE           = @Lc_CsSubsystem_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

	  SET @Ls_Sql_TEXT = 'BATCH_CPORTAL_UPDATE$SP_CUSTOMER_OTHER_INFORMATION_UPDATE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '');
      
      EXECUTE BATCH_CPORTAL_UPDATE$SP_CUSTOMER_OTHER_INFORMATION_UPDATE
       @An_MemberMCI_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_IamUser_ID               = @Lc_CportalCur_IamUser_ID,
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @Ac_InfoGivenBy_CODE         = @Lc_CportalCur_InfoGivenBy_CODE,
       @An_WorkPhone_NUMB           = @Ln_CportalCur_WorkPhone_NUMB,
       @An_HomePhone_NUMB           = @Ln_CportalCur_HomePhone_NUMB,
       @An_PagerCell_NUMB           = @Ln_CportalCur_PagerCell_NUMB,
       @As_Contact_EML              = @Ls_CportalCur_Contact_EML,
       @As_DescriptionComments_TEXT = @Ls_CportalCur_DescriptionComments_TEXT,
       @Ac_Status_CODE              = @Lc_CportalCur_Status_CODE,
       @Ac_Reason_CODE              = @Lc_CportalCur_Reason_CODE,
       @As_DescriptionReason_TEXT   = @Ls_CportalCur_DescriptionReason_TEXT,
       @Ad_Create_DATE              = @Ld_CportalCur_Create_DATE,
       @Ac_WorkerUpdate_ID          = @Lc_CportalCur_WorkerUpdate_ID,
       @Ad_BeginValidity_DATE       = @Ld_CportalCur_BeginValidity_DATE,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ad_Update_DTTM              = @Ld_CportalCur_Update_DTTM,
       @An_EventGlobalSeq_NUMB      = @Ln_CportalCur_EventGlobalSeq_NUMB,       
       @As_ErrorMessage_TEXT        = @Ls_DescriptionError_TEXT OUTPUT,
       @As_Sql_TEXT                 = @Ls_CportalSql_TEXT OUTPUT,
       @As_Sqldata_TEXT             = @Ls_CportalSqldata_TEXT OUTPUT,
       @An_Error_NUMB               = @Ln_CportalError_NUMB OUTPUT,
       @An_ErrorLine_NUMB           = @Ln_CportalErrorLine_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_CportalMsg_CODE OUTPUT;

      IF(@Lc_CportalMsg_CODE <> @Lc_SuccessStatus_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = @Ls_CportalSql_TEXT;
        SET @Ls_Sqldata_TEXT = @Ls_CportalSqldata_TEXT;
        SET @Ln_Error_NUMB = @Ln_CportalError_NUMB;
        SET @Ln_ErrorLine_NUMB = @Ln_CportalErrorLine_NUMB;

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
     
     -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION CPORTAL_UPDATE_SAVE_CCOTI;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
         RAISERROR( 50001,16,1);
        END
        
      IF CURSOR_STATUS ('VARIABLE', 'Ccoti_CUR') IN (0, 1)
       BEGIN
        CLOSE Ccoti_CUR;

        DEALLOCATE Ccoti_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_ErrorTypeE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;         
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
              
     END CATCH

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY != 0
      BEGIN
       COMMIT TRANSACTION CPORTAL_UPDATE;

       BEGIN TRANSACTION CPORTAL_UPDATE;

       SET @Ln_CommitFreq_QNTY = 0;
      END

	 SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'FETCH Ccoti_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ccoti_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_IamUser_ID, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_InfoGivenBy_CODE, @Ln_CportalCur_WorkPhone_NUMB, @Ln_CportalCur_HomePhone_NUMB, @Ln_CportalCur_PagerCell_NUMB, @Ls_CportalCur_Contact_EML, @Ls_CportalCur_DescriptionComments_TEXT, @Lc_CportalCur_Status_CODE, @Lc_CportalCur_Reason_CODE, @Ls_CportalCur_DescriptionReason_TEXT, @Ld_CportalCur_Create_DATE, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Ccadd_CUR';
   SET @Ls_Sqldata_TEXT = '';

   CLOSE Ccoti_CUR;

   DEALLOCATE Ccoti_CUR;   

   IF(@Ln_CursorCcoti_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) IN Ccoti_CUR TO PROCESS';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
      @An_Line_NUMB                = @Ln_CursorCcoti_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
    
   -- Select records from CCEDT_Y1 table where status code is 'B-ALERT REQUESTED'.
   DECLARE Ccedt_CUR INSENSITIVE CURSOR FOR
    SELECT a.MemberMCI_IDNO,
           a.IamUser_ID,
           a.Case_IDNO,
           a.InfoGivenBy_CODE,
           a.TypeEmployment_CODE,
           a.Employer_NAME,
           a.Attn_ADDR,
           a.Line1_ADDR,
           a.Line2_ADDR,
           a.City_ADDR,
           a.State_ADDR,
           a.Zip_ADDR,
           a.Country_ADDR,
           a.Phone_NUMB,
           a.BeginEmployment_DATE,
           a.DescriptionComments_TEXT,
           a.Status_CODE,
           a.Reason_CODE,
           a.DescriptionReason_TEXT,
           a.Create_DATE,
           a.WorkerUpdate_ID,
           a.BeginValidity_DATE,
           a.Update_DTTM,
           a.EventGlobalSeq_NUMB
      FROM CCEDT_Y1 a
     WHERE a.Status_CODE = @Lc_StatusAlertRequested_CODE

   
   SET @Ls_Sql_TEXT = 'OPEN Ccedt_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Ccedt_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Ccedt_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Ccedt_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_IamUser_ID, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_InfoGivenBy_CODE, @Lc_CportalCur_TypeEmployment_CODE, @Lc_CportalCur_Employer_NAME, @Lc_CportalCur_Attn_ADDR, @Ls_CportalCur_Line1_ADDR, @Ls_CportalCur_Line2_ADDR, @Lc_CportalCur_City_ADDR, @Lc_CportalCur_State_ADDR, @Lc_CportalCur_Zip_ADDR, @Lc_CportalCur_Country_ADDR, @Ln_CportalCur_Phone_NUMB, @Ld_CportalCur_BeginEmployment_DATE, @Ls_CportalCur_DescriptionComments_TEXT, @Lc_CportalCur_Status_CODE, @Lc_CportalCur_Reason_CODE, @Ls_CportalCur_DescriptionReason_TEXT, @Ld_CportalCur_Create_DATE, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   --WHILE LOOP FOR CCEDT_Y1 TABLE
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
     
      SAVE TRANSACTION CPORTAL_UPDATE_SAVE_CCEDT;
      
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorCcedt_QNTY = @Ln_Cursor_QNTY;
      SET @Ln_Topic_IDNO = 0;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', InfoGivenBy_CODE = ' + ISNULL(@Lc_CportalCur_InfoGivenBy_CODE, '') + ', TypeEmployment_CODE = ' + ISNULL(@Lc_CportalCur_TypeEmployment_CODE, '') + ', Employer_NAME = ' + ISNULL(CAST(@Lc_CportalCur_Employer_NAME AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(CAST(@Lc_CportalCur_Attn_ADDR AS VARCHAR), '') + ', Line1_ADDR = ' + ISNULL(@Ls_CportalCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_CportalCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(CAST(@Lc_CportalCur_City_ADDR AS VARCHAR), '') + ', State_ADDR = ' + ISNULL(@Lc_CportalCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(CAST(@Lc_CportalCur_Zip_ADDR AS VARCHAR), '') + ', Country_ADDR = ' + ISNULL(@Lc_CportalCur_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_Phone_NUMB AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_CportalCur_BeginEmployment_DATE AS VARCHAR), '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionComments_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_CportalCur_Status_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_CportalCur_Reason_CODE, '') + ', DescriptionReason_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionReason_TEXT, '') + ', Create_DATE = ' + ISNULL(CAST(@Ld_CportalCur_Create_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Lc_CportalCur_WorkerUpdate_ID AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_CportalCur_BeginValidity_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_CportalCur_Update_DTTM AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_EventGlobalSeq_NUMB AS VARCHAR), '');
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT ';
      SET @Ls_Sqldata_TEXT = 'TransactionMode_CODE = ' + @Lc_ModeBatch_CODE + ', IamUser_ID = ' + @Lc_CportalCur_IamUser_ID
      
	  EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_Note_INDC,
       @An_EventFunctionalSeq_NUMB = 0,
       @An_TransactionEventSeq_NUMB= @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY_3';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_CaseMajorActivity_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_RcwsuActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_CsSubsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '')

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @An_MemberMci_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_CaseMajorActivity_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_RcwsuActivityMinor_CODE,
       @Ac_Subsystem_CODE           = @Lc_CsSubsystem_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

	  SET @Ls_Sql_TEXT = 'BATCH_CPORTAL_UPDATE$SP_CUSTOMER_EMPLOYER_UPDATE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '') + ', InfoGivenBy_CODE = ' + ISNULL(CAST(@Lc_CportalCur_InfoGivenBy_CODE AS VARCHAR), '');
      
      EXECUTE BATCH_CPORTAL_UPDATE$SP_CUSTOMER_EMPLOYER_UPDATE
       @An_MemberMCI_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_IamUser_ID               = @Lc_CportalCur_IamUser_ID,
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @Ac_InfoGivenBy_CODE         = @Lc_CportalCur_InfoGivenBy_CODE,
       @Ac_TypeEmployment_CODE      = @Lc_CportalCur_TypeEmployment_CODE,
       @Ac_Employer_NAME            = @Lc_CportalCur_Employer_NAME,
       @Ac_Attn_ADDR                = @Lc_CportalCur_Attn_ADDR,
       @As_Line1_ADDR               = @Ls_CportalCur_Line1_ADDR,
       @As_Line2_ADDR               = @Ls_CportalCur_Line2_ADDR,
       @Ac_City_ADDR                = @Lc_CportalCur_City_ADDR,
       @Ac_State_ADDR               = @Lc_CportalCur_State_ADDR,
       @Ac_Zip_ADDR                 = @Lc_CportalCur_Zip_ADDR,
       @Ac_Country_ADDR             = @Lc_CportalCur_Country_ADDR,
       @An_Phone_NUMB               = @Ln_CportalCur_Phone_NUMB,
       @Ad_BeginEmployment_DATE     = @Ld_CportalCur_BeginEmployment_DATE,
       @As_DescriptionComments_TEXT = @Ls_CportalCur_DescriptionComments_TEXT,
       @Ac_Status_CODE              = @Lc_CportalCur_Status_CODE,
       @Ac_Reason_CODE              = @Lc_CportalCur_Reason_CODE,
       @As_DescriptionReason_TEXT   = @Ls_CportalCur_DescriptionReason_TEXT,
       @Ad_Create_DATE              = @Ld_CportalCur_Create_DATE,
       @Ac_WorkerUpdate_ID          = @Lc_CportalCur_WorkerUpdate_ID,
       @Ad_BeginValidity_DATE       = @Ld_CportalCur_BeginValidity_DATE,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ad_Update_DTTM              = @Ld_CportalCur_Update_DTTM,
       @An_EventGlobalSeq_NUMB      = @Ln_CportalCur_EventGlobalSeq_NUMB,      
       @As_ErrorMessage_TEXT        = @Ls_DescriptionError_TEXT OUTPUT,
       @As_Sql_TEXT                 = @Ls_CportalSql_TEXT OUTPUT,
       @As_Sqldata_TEXT             = @Ls_CportalSqldata_TEXT OUTPUT,
       @An_Error_NUMB               = @Ln_CportalError_NUMB OUTPUT,
       @An_ErrorLine_NUMB           = @Ln_CportalErrorLine_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_CportalMsg_CODE OUTPUT;

      IF(@Lc_CportalMsg_CODE <> @Lc_SuccessStatus_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = @Ls_CportalSql_TEXT;
        SET @Ls_Sqldata_TEXT = @Ls_CportalSqldata_TEXT;
        SET @Ln_Error_NUMB = @Ln_CportalError_NUMB;
        SET @Ln_ErrorLine_NUMB = @Ln_CportalErrorLine_NUMB;

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
     
      -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION CPORTAL_UPDATE_SAVE_CCEDT;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
         RAISERROR( 50001,16,1);
		END
        
      IF CURSOR_STATUS ('VARIABLE', 'Ccedt_CUR') IN (0, 1)
       BEGIN
        CLOSE Ccedt_CUR;

        DEALLOCATE Ccedt_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_ErrorTypeE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
        
     END CATCH

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY != 0
      BEGIN
       COMMIT TRANSACTION CPORTAL_UPDATE;

       BEGIN TRANSACTION CPORTAL_UPDATE;

       SET @Ln_CommitFreq_QNTY = 0;
      END

	 SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'FETCH Ccedt_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ccedt_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_IamUser_ID, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_InfoGivenBy_CODE, @Lc_CportalCur_TypeEmployment_CODE, @Lc_CportalCur_Employer_NAME, @Lc_CportalCur_Attn_ADDR, @Ls_CportalCur_Line1_ADDR, @Ls_CportalCur_Line2_ADDR, @Lc_CportalCur_City_ADDR, @Lc_CportalCur_State_ADDR, @Lc_CportalCur_Zip_ADDR, @Lc_CportalCur_Country_ADDR, @Ln_CportalCur_Phone_NUMB, @Ld_CportalCur_BeginEmployment_DATE, @Ls_CportalCur_DescriptionComments_TEXT, @Lc_CportalCur_Status_CODE, @Lc_CportalCur_Reason_CODE, @Ls_CportalCur_DescriptionReason_TEXT, @Ld_CportalCur_Create_DATE, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Ccedt_CUR';
   SET @Ls_Sqldata_TEXT = '';

   CLOSE Ccedt_CUR;

   DEALLOCATE Ccedt_CUR;

   IF(@Ln_CursorCcedt_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) IN Ccedt_CUR TO PROCESS';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
      @An_Line_NUMB                = @Ln_CursorCcedt_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   -- Select records from CMSGS_Y1 table where status code is 'B-ALERT REQUESTED'.
   DECLARE Cmsgs_CUR INSENSITIVE CURSOR FOR
    SELECT a.MemberMci_IDNO,
           a.MessageSendFrom_NAME,
           a.Case_IDNO,
           a.IamUser_ID,
           a.TypeMessage_CODE,
           a.DescriptionSubject_TEXT,
           a.DescriptionMessage_TEXT,
           a.MessageStatus_CODE,
           a.MessageReplySeq_NUMB,
           a.WorkerUpdate_ID,
           a.BeginValidity_DTTM,
           a.Update_DTTM,
           a.EventGlobalSeq_NUMB
      FROM CMSGS_Y1 a
     WHERE a.MessageStatus_CODE = @Lc_StatusAlertRequested_CODE

  
   SET @Ls_Sql_TEXT = 'OPEN Cmsgs_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Cmsgs_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Cmsgs_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Cmsgs_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_MessageSendFrom_NAME, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_IamUser_ID, @Lc_CportalCur_TypeMessage_CODE, @Ls_CportalCur_DescriptionSubject_TEXT, @Ls_CportalCur_DescriptionMessage_TEXT, @Lc_CportalCur_MessageStatus_CODE, @Ln_CportalCur_MessageReplySeq_NUMB, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-4';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   --WHILE LOOP FOR CMSGS_Y1 TABLE
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
     
      SAVE TRANSACTION CPORTAL_UPDATE_SAVE_CMSGS;
     
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorCmsgs_QNTY = @Ln_Cursor_QNTY;
      SET @Ln_Topic_IDNO = 0;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', MessageSendFrom_NAME = ' + ISNULL(@Lc_CportalCur_MessageSendFrom_NAME, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '') + ', TypeMessage_CODE = ' + ISNULL(@Lc_CportalCur_TypeMessage_CODE, '') + ', DescriptionSubject_TEXT = ' + ISNULL(@Ls_CportalCur_DescriptionSubject_TEXT, '') + ', DescriptionMessage_TEXT, = ' + ISNULL(@Ls_CportalCur_DescriptionMessage_TEXT, '') + ', MessageStatus_CODE = ' + ISNULL(@Lc_CportalCur_MessageStatus_CODE, '') + ', MessageReplySeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_MessageReplySeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Lc_CportalCur_WorkerUpdate_ID AS VARCHAR), '') + ', BeginValidity_DTTM = ' + ISNULL(CAST(@Ld_CportalCur_BeginValidity_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_CportalCur_Update_DTTM AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_EventGlobalSeq_NUMB AS VARCHAR), '');
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT ';
      SET @Ls_Sqldata_TEXT = 'TransactionMode_CODE = ' + @Lc_ModeBatch_CODE + ', IamUser_ID = ' + @Lc_CportalCur_IamUser_ID
       
	 EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_Note_INDC,
       @An_EventFunctionalSeq_NUMB = 0,
       @An_TransactionEventSeq_NUMB= @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;       

      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      IF(@Lc_CportalCur_TypeMessage_CODE = @Lc_TypeMessageMail_CODE)
       BEGIN
        --If the Message Type is Mail
        SET @Lc_ActivityMinor_CODE = @Lc_RcwibActivityMinor_CODE;
       END
      ELSE
       BEGIN
        --If the Message Type is Feedback
        SET @Lc_ActivityMinor_CODE = @Lc_RcwixActivityMinor_CODE;
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY_4';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_CaseMajorActivity_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_CsSubsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '')

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_CportalCur_Case_IDNO,
       @An_MemberMci_IDNO           = @Ln_CportalCur_MemberMCI_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_CaseMajorActivity_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
       @Ac_Subsystem_CODE           = @Lc_CsSubsystem_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
       

      IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

	  SET @Ls_Sql_TEXT = 'BATCH_CPORTAL_UPDATE$SP_CUSTOMER_MESSAGES_UPDATE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CportalCur_MemberMCI_IDNO AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_CportalCur_EventGlobalSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '')

      EXECUTE BATCH_CPORTAL_UPDATE$SP_CUSTOMER_MESSAGES_UPDATE
       @An_MemberMCI_IDNO          = @Ln_CportalCur_MemberMCI_IDNO,
       @An_Case_IDNO               = @Ln_CportalCur_Case_IDNO,
       @Ad_Run_DATE                = @Ld_Run_DATE, 
       @An_EventGlobalSeq_NUMB     = @Ln_CportalCur_EventGlobalSeq_NUMB,
       @As_ErrorMessage_TEXT       = @Ls_DescriptionError_TEXT OUTPUT,
       @As_Sql_TEXT                = @Ls_CportalSql_TEXT OUTPUT,
       @As_Sqldata_TEXT            = @Ls_CportalSqldata_TEXT OUTPUT,
       @An_Error_NUMB              = @Ln_CportalError_NUMB OUTPUT,
       @An_ErrorLine_NUMB          = @Ln_CportalErrorLine_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_CportalMsg_CODE OUTPUT;

      IF(@Lc_CportalMsg_CODE <> @Lc_SuccessStatus_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = @Ls_CportalSql_TEXT;
        SET @Ls_Sqldata_TEXT = @Ls_CportalSqldata_TEXT;
        SET @Ln_Error_NUMB = @Ln_CportalError_NUMB;
        SET @Ln_ErrorLine_NUMB = @Ln_CportalErrorLine_NUMB;

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
     
     
      -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION CPORTAL_UPDATE_SAVE_CMSGS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
         RAISERROR( 50001,16,1);
        END
        
      IF CURSOR_STATUS ('VARIABLE', 'Cmsgs_CUR') IN (0, 1)
       BEGIN
        CLOSE Cmsgs_CUR;

        DEALLOCATE Cmsgs_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       

      IF @Lc_Msg_CODE = @Lc_ErrorTypeE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
        
     END CATCH

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY != 0
      BEGIN
       COMMIT TRANSACTION CPORTAL_UPDATE;

       BEGIN TRANSACTION CPORTAL_UPDATE;

       SET @Ln_CommitFreq_QNTY = 0;
      END

	 SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'FETCH Cmsgs_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Cmsgs_CUR INTO @Ln_CportalCur_MemberMCI_IDNO, @Lc_CportalCur_MessageSendFrom_NAME, @Ln_CportalCur_Case_IDNO, @Lc_CportalCur_IamUser_ID, @Lc_CportalCur_TypeMessage_CODE, @Ls_CportalCur_DescriptionSubject_TEXT, @Ls_CportalCur_DescriptionMessage_TEXT, @Lc_CportalCur_MessageStatus_CODE, @Ln_CportalCur_MessageReplySeq_NUMB, @Lc_CportalCur_WorkerUpdate_ID, @Ld_CportalCur_BeginValidity_DATE, @Ld_CportalCur_Update_DTTM, @Ln_CportalCur_EventGlobalSeq_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Cmsgs_CUR';
   SET @Ls_Sqldata_TEXT = '';

   CLOSE Cmsgs_CUR;

   DEALLOCATE Cmsgs_CUR;

   IF(@Ln_CursorCmsgs_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) IN Cmsgs_CUR TO PROCESS';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
      @An_Line_NUMB                = @Ln_CursorCmsgs_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
    
   -- Select records from CAPCS_Y1 table to insert into DECSS Tables.
   DECLARE Capcs_CUR INSENSITIVE CURSOR FOR
    SELECT a.IamUser_ID
      FROM CAPCS_Y1 a
     WHERE a.Application_IDNO != 0

   SET @Ls_Sql_TEXT = 'OPEN Capcs_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Capcs_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Capcs_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Capcs_CUR INTO @Lc_CportalCur_IamUser_ID;

   SET @Ln_FetchStatus_QNTY=@@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-5';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;   

   --WHILE LOOP FOR CAPCS_Y1 TABLE
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY      
     
	  SAVE TRANSACTION CPORTAL_UPDATE_SAVE_CAPCS;
	  SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorCapcs_QNTY = @Ln_Cursor_QNTY;
      SET @Ls_Sql_TEXT = 'BATCH_CPORTAL_CSI_UPDATE_DECSS$SP_PROCESS_CSI_UPDATE_DECSS';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', IamUser_ID = ' + ISNULL(CAST(@Lc_CportalCur_IamUser_ID AS VARCHAR), '');

      EXECUTE BATCH_CPORTAL_CSI_UPDATE_DECSS$SP_PROCESS_CSI_UPDATE_DECSS
       @An_TransactionEventSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
       @Ac_BatchRunUser_TEXT        = @Lc_BatchRunUser_TEXT,
       @Ac_IamUser_ID               = @Lc_CportalCur_IamUser_ID,
       @Ad_EffectiveRun_DATE        = @Ld_Run_DATE,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      -- Check if the query executed properly
      IF @Lc_Msg_CODE <> @Lc_SuccessStatus_CODE
       BEGIN
        SET @Lc_TypeError_CODE=@Lc_ErrorTypeE_CODE;
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
     
      -- Rollback the save point.
      IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION CPORTAL_UPDATE_SAVE_CAPCS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END
        
      
      IF CURSOR_STATUS ('VARIABLE', 'Capcs_CUR') IN (0, 1)
       BEGIN
        CLOSE Capcs_CUR;

        DEALLOCATE Capcs_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
      IF @Lc_Msg_CODE = @Lc_ErrorTypeE_CODE
        BEGIN         
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
        
     END CATCH

     
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY != 0
      BEGIN
       COMMIT TRANSACTION CPORTAL_UPDATE;

       BEGIN TRANSACTION CPORTAL_UPDATE;

       SET @Ln_CommitFreq_QNTY = 0;
      END
	
	 SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Capcs_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Capcs_CUR INTO @Lc_CportalCur_IamUser_ID;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Capcs_CUR';
   SET @Ls_Sqldata_TEXT = '';

   CLOSE Capcs_CUR;

   DEALLOCATE Capcs_CUR;

   IF(@Ln_CursorCapcs_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorNoRecords_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) IN Ccadd_CUR TO PROCESS';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeE_CODE,
      @An_Line_NUMB                = @Ln_CursorCapcs_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
    

   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   --Upon successful completion, update the last run date in PARM_Y1 with the current run date.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   --Log the error encountered or successful completion in BSTL/BSTL_Y1 for future references.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_SuccessStatus_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');
   

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_SuccessStatus_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION CPORTAL_UPDATE;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CPORTAL_UPDATE;
    END;
  
   IF (CURSOR_STATUS ('VARIABLE', 'Ccadd_CUR') IN (0, 1))
    BEGIN
     CLOSE Ccadd_CUR;

     DEALLOCATE Ccadd_CUR;
    END

   IF(CURSOR_STATUS ('VARIABLE', 'Ccoti_CUR')IN (0, 1))
    BEGIN
     CLOSE Ccoti_CUR;

     DEALLOCATE Ccoti_CUR;
    END

   IF(CURSOR_STATUS ('VARIABLE', 'Ccedt_CUR')IN (0, 1))
    BEGIN
     CLOSE Ccedt_CUR;

     DEALLOCATE Ccedt_CUR;
    END

   IF(CURSOR_STATUS ('VARIABLE', 'Cmsgs_CUR')IN (0, 1))
    BEGIN
     CLOSE Cmsgs_CUR;

     DEALLOCATE Cmsgs_CUR;
    END

   IF(CURSOR_STATUS ('VARIABLE', 'Capcs_CUR')IN (0, 1))
    BEGIN
     CLOSE Capcs_CUR;

     DEALLOCATE Capcs_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   --Log the Error encountered in the Batch Status Log (BSTL) screen/Batch Status Log (BSTL_Y1) table for future references
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
