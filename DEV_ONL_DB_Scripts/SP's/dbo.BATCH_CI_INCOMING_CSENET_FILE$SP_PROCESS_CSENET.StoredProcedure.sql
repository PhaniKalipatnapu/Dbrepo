/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_PROCESS_CSENET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_PROCESS_CSENET
Programmer Name	:	IMP Team.
Description		:	This process loads the inbound CSENET transaction into tables according to the data blocks in the file.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_PROCESS_CSENET]
AS
 BEGIN
  SET NOCOUNT ON;

  --Cursor Variable declaration after SET NOCOUNT ON
  DECLARE @Lc_ActionRequest_CODE         CHAR = 'R',
          @Lc_ActionUpdate_CODE          CHAR = 'U',
          @Lc_StatusSuccess_CODE         CHAR = 'S',
          @Lc_StatusAbnormalend_CODE     CHAR = 'A',
          @Lc_ActionProvide_CODE         CHAR(1) = 'P',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_No_INDC                    CHAR(1) = 'N',
          @Lc_DuplicateExclude_CODE      CHAR(1) = 'X',
          @Lc_Assist_CODE                CHAR(1) = 'A',
          @Lc_Referral_CODE              CHAR(1) = 'R',
          @Lc_Enumerationverpending_CODE CHAR(1) = 'P',
          @Lc_ExchangeMode_CODE          CHAR(1) = 'C',
          @Lc_TypeErrorE_CODE            CHAR(1) = 'E',
          @Lc_TypeErrorW_CODE            CHAR(1) = 'W',
          @Lc_TypeRejectReason_CODE      CHAR(2) = 'RT',
          @Lc_Subsystem_CODE             CHAR(2) = 'IN',
          @Lc_HostRejectReason_CODE      CHAR(2) = 'HE',
          @Lc_DuplRejectReason_CODE      CHAR(2) = 'DF',
          @Lc_TransStatusSr_CODE         CHAR(2) = 'SR',
          @Lc_FunctionCasesummary_CODE   CHAR(3) = 'CSI',
          @Lc_FunctionQuickLocate_CODE   CHAR(3) = 'LO1',
          @Lc_ErrorE0944_CODE            CHAR(5) = 'E0944',
          @Lc_WorkerUpdate_ID            CHAR(5) = 'BATCH',
          @Lc_RejectReason_CODE          CHAR(5) = 'RJ',
          @Lc_Job_ID                     CHAR(7) = 'DEB0490',
          @Lc_Success_TEXT               CHAR(10) = 'SUCCESSFUL',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_PROCESS_CSENET',
          @Ls_Process_NAME               VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE',
          @Ls_Sql_TEXT                   VARCHAR(4000) = 'START PROCESS',
          @Ld_Low_DATE                   DATE = '01/01/0001',
          @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_FetchStatus_QNTY            NUMERIC,
          @Ln_RowCount_QNTY               NUMERIC,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(9) = 0,
          @Ln_LoopCount_QNTY              NUMERIC(9) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransHeader_IDNO            NUMERIC(12) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Li_Zero_NUMB                   INT = 0,
          @Li_Error_NUMB                  INT,
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_SourceCsenet_CODE           CHAR(3) = '',
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_Sqldata_TEXT                VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  --Cursor Variable Naming:
  DECLARE @Ln_DupCur_TransHeader_IDNO       NUMERIC(12),
          @Lc_DupCur_Action_CODE            CHAR(1),
          @Lc_DupCur_IVDOutOfStateFips_CODE CHAR(2),
          @Lc_DupCur_Function_CODE          CHAR(3),
          @Lc_DupCur_Reason_CODE            CHAR(5),
          @Lc_DupCur_Case_IDNO              CHAR(6),
          @Lc_DupCur_Transaction_DATE       CHAR(8);
  DECLARE @Ln_LdHeadCur_TransHeader_IDNO       NUMERIC(12),
          @Lc_LdHeadCur_IVDOutOfStateFips_CODE CHAR(2),
          @Lc_LdHeadCur_CsenetVersion_ID       CHAR(3),
          @Lc_LdHeadCur_Case_IDNO              CHAR(6),
          @Lc_LdHeadCur_StoredDate_TEXT        CHAR(8),
          @Ld_LdHeadCur_Received_DATE          DATE,
          @Ld_LdHeadCur_AttachDue_DATE         DATE,
          @Ld_LdHeadCur_Transaction_DATE       DATE,
          @Ld_LdHeadCur_ActionResolution_DATE  DATE;
  DECLARE @Lc_HeadCur_Action_CODE                  CHAR(1),
          @Lc_HeadCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_HeadCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_HeadCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_HeadCur_Function_CODE                CHAR(3),
          @Lc_HeadCur_Reason_CODE                  CHAR(5),
          @Lc_HeadCur_RejectReason_CODE            CHAR(5),
          @Lc_HeadCur_TransHeader_IDNO             CHAR(12),
          @Ld_HeadCur_Transaction_DATE             DATE;

  BEGIN TRANSACTION PROCESS_CSENET;

  BEGIN TRY
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
    END;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE TRANSACTION UPDATE';

   DECLARE Dup_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           a.Transaction_DATE,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           a.Function_CODE,
           a.Action_CODE,
           a.Reason_CODE
      FROM LTHBL_Y1 a
     WHERE a.Process_INDC = @Lc_No_INDC
       AND EXISTS (SELECT TransHeader_IDNO,
                          Transaction_DATE,
                          IVDOutOfStateFips_CODE
                     FROM CTHB_Y1 b
                    WHERE b.TransHeader_IDNO = a.TransHeader_IDNO
                      AND b.Transaction_DATE = CONVERT(DATE, a.Transaction_DATE, 112)
                      AND b.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE);

   OPEN Dup_CUR;

   FETCH NEXT FROM Dup_CUR INTO @Ln_DupCur_TransHeader_IDNO, @Lc_DupCur_Transaction_DATE, @Lc_DupCur_IVDOutOfStateFips_CODE, @Lc_DupCur_Case_IDNO, @Lc_DupCur_Function_CODE, @Lc_DupCur_Action_CODE, @Lc_DupCur_Reason_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ln_LoopCount_QNTY = 0;

   -- Update the duplicate records, so as not to process the duplicate records.
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ln_LoopCount_QNTY = @Ln_LoopCount_QNTY + 1;
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_DupCur_Case_IDNO, '') + ', Function_CODE = ' + ISNULL(@Lc_DupCur_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_DupCur_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_DupCur_Reason_CODE, '');
      SET @Ls_Sql_TEXT = 'UPDATE LTHBL_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '');

      UPDATE LTHBL_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF (@Ln_RowCount_QNTY <= 0)
       BEGIN
        RAISERROR(50001,16,1);
       END;

      SET @Ls_Sql_TEXT = 'UPDATE LIBLK_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LIBLK_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      SET @Ls_Sql_TEXT = 'UPDATE LCBLK_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LCBLK_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      SET @Ls_Sql_TEXT = 'UPDATE LOBLK_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LOBLK_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      SET @Ls_Sql_TEXT = 'UPDATE LPBLK_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LPBLK_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      SET @Ls_Sql_TEXT = 'UPDATE LNLBL_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LNLBL_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      SET @Ls_Sql_TEXT = 'UPDATE LNBLK_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LNBLK_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      SET @Ls_Sql_TEXT = 'UPDATE LCDBL_Y1 FOR DUPLICATE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_DupCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_DupCur_Transaction_DATE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_DupCur_IVDOutOfStateFips_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

      UPDATE LCDBL_Y1
         SET Process_INDC = @Lc_DuplicateExclude_CODE
       WHERE TransHeader_IDNO = @Ln_DupCur_TransHeader_IDNO
         AND Transaction_DATE = @Lc_DupCur_Transaction_DATE
         AND IVDOutOfStateFips_CODE = @Lc_DupCur_IVDOutOfStateFips_CODE
         AND Process_INDC = @Lc_No_INDC;

      IF @Ln_CommitFreqParm_QNTY != 0
         AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
       BEGIN
        COMMIT TRANSACTION PROCESS_CSENET;

        BEGIN TRANSACTION PROCESS_CSENET;

        SET @Ln_CommitFreq_QNTY = 0;
       END;
     END TRY

     BEGIN CATCH
      IF @@TRANCOUNT > 0
       BEGIN
        ROLLBACK TRANSACTION PROCESS_CSENET;

        BEGIN TRANSACTION PROCESS_CSENET;
       END;

      SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
      SET @Li_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();
      SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

      IF (LTRIM(@Ls_DescriptionError_TEXT) = @Lc_Empty_TEXT)
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();

        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = @Li_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       END;

      IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
       BEGIN
        RAISERROR(50001,16,1);
       END;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_LoopCount_QNTY,
       @Ac_Error_CODE               = @Lc_Empty_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     END CATCH;

     FETCH NEXT FROM Dup_CUR INTO @Ln_DupCur_TransHeader_IDNO, @Lc_DupCur_Transaction_DATE, @Lc_DupCur_IVDOutOfStateFips_CODE, @Lc_DupCur_Case_IDNO, @Lc_DupCur_Function_CODE, @Lc_DupCur_Action_CODE, @Lc_DupCur_Reason_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Dup_CUR') IN (0, 1)
    BEGIN
     CLOSE Dup_CUR;

     DEALLOCATE Dup_CUR;
    END;

   --Validate duplicate row in the file
   SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_VALIDATE_DUP_ROWS_IN_FILE';
   SET @Ls_Sqldata_TEXT = 'Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', JobProcess_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_VALIDATE_DUP_ROWS_IN_FILE
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_JobProcess_IDNO       = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   -- VALIDATE CSENET REJECT - Start
   SET @Ls_Sql_TEXT = 'VALIDATE DUPLICATE TRANSACTION/MISSING BLOCK';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE LTHBL_Y1
      SET RejectReason_CODE = @Lc_HostRejectReason_CODE
     FROM LTHBL_Y1 AS a
    WHERE NOT EXISTS (SELECT 1
                        FROM CFAR_Y1 b
                       WHERE b.Function_CODE = a.Function_CODE
                         AND b.Action_CODE = a.Action_CODE
                         AND b.Reason_CODE = a.Reason_CODE)
      AND LTRIM(a.RejectReason_CODE) = @Lc_Empty_TEXT
      AND a.Process_INDC = @Lc_No_INDC;

   -- VALIDATE CSENET REJECT - End
   SET @Ls_Sql_TEXT = 'REQUIRED FIELD VALIDATION';

   DECLARE LdHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.Case_IDNO,
           a.Stored_DATE,
           a.Received_DATE,
           a.AttachDue_DATE,
           a.Transaction_DATE,
           a.ActionResolution_DATE,
           a.CsenetVersion_ID
      FROM LTHBL_Y1 a
     WHERE LTRIM(a.RejectReason_CODE) = @Lc_Empty_TEXT
       AND a.Process_INDC = @Lc_No_INDC
       AND a.Case_IDNO = @Lc_Empty_TEXT
       AND NOT (a.Function_CODE IN (@Lc_FunctionCasesummary_CODE, @Lc_FunctionQuickLocate_CODE)
                AND a.Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionUpdate_CODE))
       AND EXISTS (SELECT 1
                     FROM CFAR_Y1 b
                    WHERE b.Function_CODE = a.Function_CODE
                      AND b.Action_CODE = a.Action_CODE
                      AND b.Reason_CODE = a.Reason_CODE
                      AND b.RefAssist_CODE NOT IN (@Lc_Assist_CODE, @Lc_Referral_CODE));

   OPEN LdHead_CUR;

   FETCH NEXT FROM LdHead_CUR INTO @Ln_LdHeadCur_TransHeader_IDNO, @Lc_LdHeadCur_IVDOutOfStateFips_CODE, @Lc_LdHeadCur_Case_IDNO, @Lc_LdHeadCur_StoredDate_TEXT, @Ld_LdHeadCur_Received_DATE, @Ld_LdHeadCur_AttachDue_DATE, @Ld_LdHeadCur_Transaction_DATE, @Ld_LdHeadCur_ActionResolution_DATE, @Lc_LdHeadCur_CsenetVersion_ID;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ln_LoopCount_QNTY = 0;

   -- Reject the transaction that are not Assist/Referral and not LO1, CSI. 
   -- The rejected transaction will be handled differently.
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ln_LoopCount_QNTY = @Ln_LoopCount_QNTY + 1;
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_LdHeadCur_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_LdHeadCur_IVDOutOfStateFips_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_LdHeadCur_Case_IDNO, '') + ', Stored_DATE = ' + ISNULL(@Lc_LdHeadCur_StoredDate_TEXT, '') + ', Received_DATE = ' + ISNULL(CAST(@Ld_LdHeadCur_Received_DATE AS VARCHAR), '') + ', AttachDue_DATE = ' + ISNULL(CAST(@Ld_LdHeadCur_AttachDue_DATE AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_LdHeadCur_Transaction_DATE AS VARCHAR), '') + ', ActionResolution_DATE = ' + ISNULL(CAST(@Ld_LdHeadCur_ActionResolution_DATE AS VARCHAR), '') + ', CsenetVersion_ID = ' + ISNULL(@Lc_LdHeadCur_CsenetVersion_ID, '');
      SET @Ls_Sql_TEXT = 'DUPLICATE DATA IN FILE';
      SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_LdHeadCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_LdHeadCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_LdHeadCur_IVDOutOfStateFips_CODE, '');

      UPDATE a
         SET RejectReason_CODE = @Lc_TypeRejectReason_CODE
        FROM LTHBL_Y1 a
       WHERE a.TransHeader_IDNO = @Ln_LdHeadCur_TransHeader_IDNO
         AND a.Transaction_DATE = @Ld_LdHeadCur_Transaction_DATE
         AND a.IVDOutOfStateFips_CODE = @Lc_LdHeadCur_IVDOutOfStateFips_CODE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF (@Ln_RowCount_QNTY > 0)
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE LTHBL_Y1 - FAILED';

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_LoopCount_QNTY,
         @Ac_Error_CODE               = @Lc_Empty_TEXT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       END;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END;

      IF @Ln_CommitFreqParm_QNTY != 0
         AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
       BEGIN
        COMMIT TRANSACTION PROCESS_CSENET;

        BEGIN TRANSACTION PROCESS_CSENET;

        SET @Ln_CommitFreq_QNTY = 0;
       END;
     END TRY

     BEGIN CATCH
      IF @@TRANCOUNT > 0
       BEGIN
        ROLLBACK TRANSACTION PROCESS_CSENET;

        BEGIN TRANSACTION PROCESS_CSENET;
       END;

      SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
      SET @Li_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();
      SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

      IF (LTRIM(@Ls_DescriptionError_TEXT) = @Lc_Empty_TEXT)
       BEGIN
        SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();

        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = @Li_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       END;

      IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
       BEGIN
        RAISERROR(50001,16,1);
       END;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_LoopCount_QNTY,
       @Ac_Error_CODE               = @Lc_Empty_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     END CATCH;

     FETCH NEXT FROM LdHead_CUR INTO @Ln_LdHeadCur_TransHeader_IDNO, @Lc_LdHeadCur_IVDOutOfStateFips_CODE, @Lc_LdHeadCur_Case_IDNO, @Lc_LdHeadCur_StoredDate_TEXT, @Ld_LdHeadCur_Received_DATE, @Ld_LdHeadCur_AttachDue_DATE, @Ld_LdHeadCur_Transaction_DATE, @Ld_LdHeadCur_ActionResolution_DATE, @Lc_LdHeadCur_CsenetVersion_ID;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'LdHead_CUR') IN (0, 1)
    BEGIN
     CLOSE LdHead_CUR;

     DEALLOCATE LdHead_CUR;
    END;

   -- PROCESS CSIANDLO1 - Start
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_WorkerUpdate_ID,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_INDC,
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSPR_Y1 FOR CSI AND LO1';
   SET @Ls_Sqldata_TEXT = 'ExchangeMode_INDC = ' + ISNULL(@Lc_ExchangeMode_CODE, '') + ', Form_ID = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', FormWeb_URL = ' + ISNULL(@Lc_Space_TEXT, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionProvide_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', CaseFormer_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsCarrier_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', File_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '');

   INSERT CSPR_Y1
          (Generated_DATE,
           Case_IDNO,
           IVDOutOfStateFips_CODE,
           IVDOutOfStateCountyFips_CODE,
           IVDOutOfStateOfficeFips_CODE,
           IVDOutOfStateCase_ID,
           ExchangeMode_INDC,
           StatusRequest_CODE,
           Form_ID,
           FormWeb_URL,
           TransHeader_IDNO,
           Function_CODE,
           Action_CODE,
           Reason_CODE,
           DescriptionComments_TEXT,
           CaseFormer_ID,
           InsCarrier_NAME,
           InsPolicyNo_TEXT,
           Hearing_DATE,
           Dismissal_DATE,
           GeneticTest_DATE,
           Attachment_INDC,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           File_ID,
           PfNoShow_DATE,
           RespondentMci_IDNO,
           ArrearComputed_DATE,
           TotalInterestOwed_AMNT,
           TotalArrearsOwed_AMNT)
   SELECT CONVERT(DATE, a.Transaction_DATE, 112) AS Generated_DATE,
          CAST((CASE LTRIM(a.Case_IDNO)
                 WHEN @Lc_Empty_TEXT
                  THEN '0'
                 ELSE a.Case_IDNO
                END) AS NUMERIC) AS Case_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.IVDOutOfStateCountyFips_CODE)), 3) AS IVDOutOfStateCountyFips_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateOfficeFips_CODE)), 2) AS IVDOutOfStateOfficeFips_CODE,
          a.IVDOutOfStateCase_ID,
          @Lc_ExchangeMode_CODE AS ExchangeMode_INDC,
          'PN' AS StatusRequest_CODE,
          @Li_Zero_NUMB AS Form_ID,
          @Lc_Space_TEXT AS FormWeb_URL,
          CAST(a.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
          a.Function_CODE,
          @Lc_ActionProvide_CODE AS Action_CODE,
          CASE a.Function_CODE
           WHEN @Lc_FunctionCasesummary_CODE
            THEN 'FSINF'
           WHEN @Lc_FunctionQuickLocate_CODE
            THEN 'LSALL'
          END AS Reason_CODE,
          @Lc_Space_TEXT AS DescriptionComments_TEXT,
          @Lc_Space_TEXT AS CaseFormer_ID,
          @Lc_Space_TEXT AS InsCarrier_NAME,
          @Lc_Space_TEXT AS InsPolicyNo_TEXT,
          @Ld_Low_DATE AS Hearing_DATE,
          @Ld_Low_DATE AS Dismissal_DATE,
          @Ld_Low_DATE AS GeneticTest_DATE,
          @Lc_No_INDC AS Attachment_INDC,
          @Ld_Start_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          @Lc_WorkerUpdate_ID AS WorkerUpdate_ID,
          @Ld_Start_DATE AS Update_DTTM,
          @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
          @Lc_Space_TEXT AS File_ID,
          @Ld_Low_DATE AS PfNoShow_DATE,
          0 AS RespondentMci_IDNO,
          @Ld_Low_DATE AS ArrearComputed_DATE,
          0 AS TotalInterestOwed_AMNT,
          0 AS TotalArrearsOwed_AMNT
     FROM LTHBL_Y1 a
    WHERE a.RejectReason_CODE NOT IN (@Lc_DuplRejectReason_CODE, @Lc_TypeRejectReason_CODE)
      AND a.Function_CODE IN (@Lc_FunctionCasesummary_CODE, @Lc_FunctionQuickLocate_CODE)
      AND a.Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionUpdate_CODE)
      AND a.Process_INDC <> @Lc_DuplicateExclude_CODE;

   IF EXISTS (SELECT 1
                FROM LTHBL_Y1 a
               WHERE a.Process_INDC = @Lc_No_INDC)
    BEGIN
     -- PROCESS CSIANDLO1 - End
     SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_TRANSACTION_DATA';
     SET @Ls_Sqldata_TEXT = 'ExchangeMode_CODE = ' + ISNULL(@Lc_ExchangeMode_CODE, '') + ', TranStatus_CODE = ' + ISNULL(@Lc_TransStatusSr_CODE, '') + ', RejectReason_CODE = ' + ISNULL(@Lc_RejectReason_CODE, '') + ', JobProcess_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '');

     EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_TRANSACTION_DATA
      @Ac_ExchangeMode_CODE     = @Lc_ExchangeMode_CODE,
      @Ac_TranStatus_CODE       = @Lc_TransStatusSr_CODE,
      @Ac_RejectReason_CODE     = @Lc_RejectReason_CODE,
      @Ac_JobProcess_IDNO       = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_WorkerUpdate_ID       = @Lc_WorkerUpdate_ID,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'HEAD CURSOR TO UPDATE TRANSACTION DATA';

     DECLARE Head_CUR INSENSITIVE CURSOR FOR
      SELECT a.TransHeader_IDNO,
             a.IVDOutOfStateFips_CODE,
             a.IVDOutOfStateCountyFips_CODE,
             a.IVDOutOfStateOfficeFips_CODE,
             a.Function_CODE,
             a.Action_CODE,
             a.Reason_CODE,
             a.RejectReason_CODE,
             CONVERT(DATE, a.Transaction_DATE, 112)
        FROM LTHBL_Y1 a
       WHERE a.Action_CODE = 'P'
         AND a.RejectReason_CODE = ' '
         AND a.Process_INDC <> @Lc_DuplicateExclude_CODE
       ORDER BY a.TransHeader_IDNO,
                a.Transaction_DATE,
                a.IVDOutOfStateFips_CODE;

     OPEN Head_CUR;

     FETCH NEXT FROM Head_CUR INTO @Lc_HeadCur_TransHeader_IDNO, @Lc_HeadCur_IVDOutOfStateFips_CODE, @Lc_HeadCur_IVDOutOfStateCountyFips_CODE, @Lc_HeadCur_IVDOutOfStateOfficeFips_CODE, @Lc_HeadCur_Function_CODE, @Lc_HeadCur_Action_CODE, @Lc_HeadCur_Reason_CODE, @Lc_HeadCur_RejectReason_CODE, @Ld_HeadCur_Transaction_DATE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ln_LoopCount_QNTY = 0;

     -- Update the Transaction tables with the data Provided from other state
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SET @Ln_LoopCount_QNTY = @Ln_LoopCount_QNTY + 1;
        SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ln_TransHeader_IDNO = CAST(@Lc_HeadCur_TransHeader_IDNO AS NUMERIC);
        SET @Ls_Sql_TEXT = 'UPDATE TRANSACTION DATA FOR ACTION_TEXT P';
        SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeadCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeadCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_HeadCur_IVDOutOfStateCountyFips_CODE, '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_HeadCur_IVDOutOfStateOfficeFips_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_HeadCur_Reason_CODE, '') + ', Enumeration_CODE = ' + ISNULL(@Lc_Enumerationverpending_CODE, '') + ', RowCount_NUMB = ' + ISNULL(CAST(@Ln_RowCount_QNTY AS VARCHAR), '') + ', JobProcess_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceCsenet_CODE, '') + ', TranStatus_CODE = ' + ISNULL(@Lc_TransStatusSr_CODE, '');

        EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_UPDATE_TRANSACTION_DATA
         @An_Transaction_IDNO             = @Ln_TransHeader_IDNO,
         @Ad_Transaction_DATE             = @Ld_HeadCur_Transaction_DATE,
         @Ac_IVDOutOfStateFips_CODE       = @Lc_HeadCur_IVDOutOfStateFips_CODE,
         @Ac_IVDOutOfStateCountyFips_CODE = @Lc_HeadCur_IVDOutOfStateCountyFips_CODE,
         @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_HeadCur_IVDOutOfStateOfficeFips_CODE,
         @Ac_Reason_CODE                  = @Lc_HeadCur_Reason_CODE,
         @Ac_Enumeration_CODE             = @Lc_Enumerationverpending_CODE,
         @Ai_RowCount_NUMB                = @Ln_RowCount_QNTY,
         @Ac_JobProcess_IDNO              = @Lc_Job_ID,
         @Ac_BatchRunUser_TEXT            = @Lc_WorkerUpdate_ID,
         @Ad_Run_DATE                     = @Ld_Run_DATE,
         @Ac_SourceLoc_CODE               = @Lc_SourceCsenet_CODE,
         @Ac_TranStatus_CODE              = @Lc_TransStatusSr_CODE,
         @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END;

        IF @Ln_CommitFreqParm_QNTY != 0
           AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
         BEGIN
          COMMIT TRANSACTION PROCESS_CSENET;

          BEGIN TRANSACTION PROCESS_CSENET;

          SET @Ln_CommitFreq_QNTY = 0;
         END;
       END TRY

       BEGIN CATCH
        IF @@TRANCOUNT > 0
         BEGIN
          ROLLBACK TRANSACTION PROCESS_CSENET;

          BEGIN TRANSACTION PROCESS_CSENET;
         END;

        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        SET @Li_Error_NUMB = ERROR_NUMBER();
        SET @Ln_ErrorLine_NUMB = ERROR_LINE();
        SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

        IF (LTRIM(@Ls_DescriptionError_TEXT) = @Lc_Empty_TEXT)
         BEGIN
          SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();

          EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
           @As_Procedure_NAME        = @Ls_Procedure_NAME,
           @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
           @As_Sql_TEXT              = @Ls_Sql_TEXT,
           @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
           @An_Error_NUMB            = @Li_Error_NUMB,
           @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
           @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
         END;

        IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
         BEGIN
          RAISERROR(50001,16,1);
         END;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_LoopCount_QNTY,
         @Ac_Error_CODE               = @Lc_Empty_TEXT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       END CATCH;

       FETCH NEXT FROM Head_CUR INTO @Lc_HeadCur_TransHeader_IDNO, @Lc_HeadCur_IVDOutOfStateFips_CODE, @Lc_HeadCur_IVDOutOfStateCountyFips_CODE, @Lc_HeadCur_IVDOutOfStateOfficeFips_CODE, @Lc_HeadCur_Function_CODE, @Lc_HeadCur_Action_CODE, @Lc_HeadCur_Reason_CODE, @Lc_HeadCur_RejectReason_CODE, @Ld_HeadCur_Transaction_DATE;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     IF CURSOR_STATUS('LOCAL', 'Head_CUR') IN (0, 1)
      BEGIN
       CLOSE Head_CUR;

       DEALLOCATE Head_CUR;
      END;

     SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS';
     SET @Ls_Sqldata_TEXT = 'RejectReason_CODE = ' + ISNULL(@Lc_TypeRejectReason_CODE, '') + ', ExchangeMode_INDC = ' + ISNULL(@Lc_ExchangeMode_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', JobProcess_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_WorkerUpdate_ID, '');

     EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_REJECTED_TRANS
      @Ac_RejectReason_CODE     = @Lc_TypeRejectReason_CODE,
      @Ac_ExchangeMode_INDC     = @Lc_ExchangeMode_CODE,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ad_Start_DATE            = @Ld_Start_DATE,
      @Ac_JobProcess_IDNO       = @Lc_Job_ID,
      @Ac_BatchRunUser_TEXT     = @Lc_WorkerUpdate_ID,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     --INSERT ALERT
     SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_WorkerUpdate_ID, '');

     EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_INSERT_ALERT
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Subsystem_CODE        = @Lc_Subsystem_CODE,
      @Ac_BatchRunUser_TEXT     = @Lc_WorkerUpdate_ID,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_TRANSMITTAL2PARTY';
     SET @Ls_Sqldata_TEXT = 'JobProcess_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '');

     EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_TRANSMITTAL2PARTY
      @Ac_JobProcess_IDNO       = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_BatchRunUser_TEXT     = @Lc_WorkerUpdate_ID,
      @Ac_Subsystem_CODE        = @Lc_Subsystem_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END
   ELSE
    BEGIN
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorW_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_LoopCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
      @An_Line_NUMB                = @Ln_LoopCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'UPDATE BSTL_Y1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Success_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Success_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Success_TEXT,
    @As_ListKey_TEXT              = @Lc_Success_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_WorkerUpdate_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS';

   COMMIT TRANSACTION PROCESS_CSENET;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PROCESS_CSENET;
    END;

   IF CURSOR_STATUS('LOCAL', 'Dup_CUR') IN (0, 1)
    BEGIN
     CLOSE Dup_CUR;

     DEALLOCATE Dup_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'LdHead_CUR') IN (0, 1)
    BEGIN
     CLOSE LdHead_CUR;

     DEALLOCATE LdHead_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'Head_CUR') IN (0, 1)
    BEGIN
     CLOSE Head_CUR;

     DEALLOCATE Head_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

   IF (LTRIM(@Ls_DescriptionError_TEXT) = @Lc_Empty_TEXT)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Li_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_WorkerUpdate_ID,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
