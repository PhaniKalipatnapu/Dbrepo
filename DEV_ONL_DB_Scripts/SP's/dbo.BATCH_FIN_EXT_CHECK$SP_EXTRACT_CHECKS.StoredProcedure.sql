/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_CHECK$SP_EXTRACT_CHECKS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_EXT_CHECK$SP_EXTRACT_CHECKS
Programmer Name	:	IMP Team.
Description		:	The process extracts the checks from the Disbursement View (DSBV) screen/ Disbursement Header Log (DSBH_Y1) table 
					and generates an output file to the bank.
Frequency		:	DAILY
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_CHECK$SP_EXTRACT_CHECKS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_DetailRecord_ID               CHAR(1) = 'D',
          @Lc_HeaderRecord_ID               CHAR(1) = 'H',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_TrailerRecord_CODE            CHAR(1) = 'T',
          @Lc_ErrorTypeWarning_CODE         CHAR(1) = 'W',
          @Lc_DisburseMediumCpCheck_CODE    CHAR(1) = 'C',
          @Lc_CheckRecipientCpNcp_CODE      CHAR(1) = '1',
          @Lc_CheckRecipientFips_CODE       CHAR(1) = '2',
          @Lc_CheckRecipientOtherParty_CODE CHAR(1) = '3',
          @Lc_RecordTypeVOid_CODE           CHAR(1) = 'V',
          @Lc_RecordTypeIssue_CODE          CHAR(1) = 'I',
          @Lc_StatusCheckOutstanding_CODE   CHAR(2) = 'OU',
          @Lc_StatusCheckVoidNoRessue_CODE  CHAR(2) = 'VN',
          @Lc_StatusCheckVoidRessue_CODE    CHAR(2) = 'VR',
          @Lc_ReasonStatusSC_CODE           CHAR(2) = 'SC',
          @Lc_AddressTypeState_CODE         CHAR(3) = 'STA',
          @Lc_AddressSubTypeSdu_CODE        CHAR(3) = 'SDU',
          @Lc_AddressTypeInt_CODE           CHAR(3) = 'INT',
          @Lc_AddressSubTypeFrc_CODE        CHAR(3) = 'FRC',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_ErrorNoDataFound_CODE         CHAR(5) = 'E0944',
          @Lc_Job_ID                        CHAR(7) = 'DEB0650',
          @Lc_StaleChecksJob_ID             CHAR(7) = 'DEB0680',
          @Lc_DefaultAccount_NUMB           CHAR(10) = '5699245046',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_Client_NAME                   CHAR(25) = 'DECSS - AUTOMATED',
          @Lc_Process_NAME                  CHAR(30) = 'BATCH_FIN_EXT_CHECK',
          @Lc_Procedure_NAME                CHAR(30) = 'SP_EXTRACT_CHECKS',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Start_DATE                    DATETIME2(0) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_FetchStatus_QNTY            NUMERIC(1),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RowCount_QNTY               NUMERIC(7),
          @Ln_Error_NUMB                  NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(10),
          @Ln_DetailRecordCount_QNTY      NUMERIC(10) =0,
          @Ln_TotalCheck_AMNT             NUMERIC(12),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_Payee_ID                    CHAR(15),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_StaleChecksRun_DATE         DATE;
  DECLARE @Lc_CheckCur_CheckRecipient_ID   CHAR(10),
          @Lc_CheckCur_CheckRecipient_CODE CHAR(1),
          @Ln_CheckCur_DisburseSeq_NUMB    NUMERIC(4),
          @Ld_CheckCur_Disburse_DATE       DATE,
          @Lc_CheckCur_Account_NUMB        CHAR(10),
          @Ln_CheckCur_Check_NUMB          NUMERIC(19),
          @Ln_CheckCur_Disburse_AMNT       NUMERIC(11, 2),
          @Ld_CheckCur_Issue_DATE          DATE,
          @Lc_CheckCur_RecordType_CODE     CHAR(1);

  BEGIN TRY
   SET @Ls_Sql_TEXT ='CREATE TEMPORARY TABLE';
   SET @Ls_Sqldata_TEXT= '';

   CREATE TABLE ##ExtractCheck_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT CHAR(80)
    );

   BEGIN TRANSACTION ExtractCHK;

   SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT= 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   /*
   	Get the current run date and last run date from Parameters (PARM_Y1 )table, and validate that the batch program 
   	was not executed for the current run date, by ensuring that the run date is different from the last run date in 
   	the PARM_Y1 table
   */
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'STALE CHECK RUN DATE';
   SET @Ls_Sqldata_TEXT = 'StaleChecksJob_ID = ' + @Lc_StaleChecksJob_ID + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

   -- To get the latest rundate for batch_fin_stale_checks
   SELECT @Ld_StaleChecksRun_DATE = p.Run_DATE
     FROM PARM_Y1 p
    WHERE p.JOB_ID = @Lc_StaleChecksJob_ID
      AND p.EndValidity_DATE = @Ld_High_DATE;

   --Delete all the records from EXCHK_Y1
   SET @Ls_Sql_TEXT='DELETE FROM EXCHK_Y1';
   SET @Ls_Sqldata_TEXT= '';

   DELETE FROM EXCHK_Y1;

   --Insert the Header Record into the Table
   SET @Ls_Sql_TEXT='INSERT HEADER';
   SET @Ls_Sqldata_TEXT= '';

   INSERT INTO ##ExtractCheck_P1
               (Record_TEXT)
        VALUES ( @Lc_HeaderRecord_ID + @Lc_DefaultAccount_NUMB + REPLACE(CONVERT(CHAR(10), @Ld_Run_DATE, 101), '/', '') + CONVERT(CHAR(25), @Lc_Client_NAME) + REPLICATE(@Lc_Space_TEXT, 36)--Record_TEXT 
   );

   -- Check Cursor Declaration  
   -- To get the Case updates in the System for IVE cases.
   /*
   Select all current Check disbursements and create a file with Header, Detail and Footer sections, each record will be inserted into this file
   */
   DECLARE Check_CUR INSENSITIVE CURSOR FOR
    SELECT a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.DisburseSeq_NUMB,
           a.Disburse_DATE,
           @Lc_DefaultAccount_NUMB AS Account_NUMB,
           a.Check_NUMB,
           a.Disburse_AMNT,
           a.Issue_DATE,
           CASE
            WHEN a.StatusCheck_CODE IN (@Lc_StatusCheckVoidNoRessue_CODE, @Lc_StatusCheckVoidRessue_CODE)
             THEN @Lc_RecordTypeVOid_CODE
            ELSE @Lc_RecordTypeIssue_CODE
           END AS RecordType_CODE
      FROM DSBH_Y1 a
     WHERE a.MediumDisburse_CODE = @Lc_DisburseMediumCpCheck_CODE
       AND a.Check_NUMB <> 0
       AND a.Disburse_DATE <= @Ld_Run_DATE
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND ((a.StatusCheck_CODE IN (@Lc_StatusCheckOutstanding_CODE)
             AND a.Issue_DATE = @Ld_Run_DATE)
             OR (a.StatusCheck_CODE IN (@Lc_StatusCheckVoidNoRessue_CODE, @Lc_StatusCheckVoidRessue_CODE)
                 AND ((a.StatusCheck_DATE BETWEEN @Ld_StaleChecksRun_DATE AND @Ld_Run_DATE)
                      AND a.ReasonStatus_CODE IN(@Lc_ReasonStatusSC_CODE)
                       OR (a.StatusCheck_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE))));

   -- Case Cursor
   SET @Ls_Sql_TEXT = 'Open Check_CUR - 1';
   SET @Ls_Sqldata_TEXT= '';

   OPEN Check_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Check_CUR - 1';
   SET @Ls_Sqldata_TEXT= '';

   FETCH NEXT FROM Check_CUR INTO @Lc_CheckCur_CheckRecipient_ID, @Lc_CheckCur_CheckRecipient_CODE, @Ln_CheckCur_DisburseSeq_NUMB, @Ld_CheckCur_Disburse_DATE, @Lc_CheckCur_Account_NUMB, @Ln_CheckCur_Check_NUMB, @Ln_CheckCur_Disburse_AMNT, @Ld_CheckCur_Issue_DATE, @Lc_CheckCur_RecordType_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   --Extract details into EXCHK_Y1 table
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_CursorLocation_TEXT = 'CheckRecipient_ID = ' + CAST(ISNULL(@Lc_CheckCur_CheckRecipient_ID, '') AS VARCHAR) + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckCur_CheckRecipient_CODE, '') + ', DisburseSeq_NUMB = ' + CAST(ISNULL(@Ln_CheckCur_DisburseSeq_NUMB, '') AS VARCHAR) + ', Disburse_DATE = ' + CAST(ISNULL(@Ld_CheckCur_Disburse_DATE, '') AS VARCHAR) + ', Account_NUMB = ' + ISNULL(@Lc_CheckCur_Account_NUMB, '') + ', Check_NUMB = ' + CAST(ISNULL(@Ln_CheckCur_Check_NUMB, '') AS VARCHAR) + ', Disburse_AMNT = ' + CAST(ISNULL(@Ln_CheckCur_Disburse_AMNT, '') AS VARCHAR) + ', Issue_DATE = ' + CAST(ISNULL(@Ld_CheckCur_Issue_DATE, '') AS VARCHAR) + ', RecordType_CODE = ' + ISNULL(@Lc_CheckCur_RecordType_CODE, '');

     IF @Lc_CheckCur_CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1';
       SET @Ls_Sqldata_TEXT='CheckRecipient_ID = ' + CAST(ISNULL(@Lc_CheckCur_CheckRecipient_ID, '') AS VARCHAR);

       SELECT @Lc_Payee_ID = CASE a.MemberSsn_NUMB
                              WHEN 0
                               THEN ''
                              ELSE CAST(a.MemberSsn_NUMB AS VARCHAR)
                             END + LTRIM(RTRIM(a.Last_NAME))
         FROM DEMO_Y1 a
        WHERE a.MemberMci_IDNO = @Lc_CheckCur_CheckRecipient_ID;
      END
     ELSE IF @Lc_CheckCur_CheckRecipient_CODE = @Lc_CheckRecipientFips_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1';
       SET @Ls_Sqldata_TEXT='CheckRecipient_ID = ' + CAST(ISNULL(@Lc_CheckCur_CheckRecipient_ID, '') AS VARCHAR) + ', AddressTypeState_CODE = ' + @Lc_AddressTypeState_CODE + ', AddressSubTypeSdu_CODE = ' + @Lc_AddressSubTypeSdu_CODE + ', AddressTypeInt_CODE = ' + @Lc_AddressTypeInt_CODE + ', AddressSubTypeFrc_CODE = ' + @Lc_AddressSubTypeFrc_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT @Lc_Payee_ID = a.Fips_NAME
         FROM FIPS_Y1 a
        WHERE a.Fips_CODE = CAST(@Lc_CheckCur_CheckRecipient_ID AS CHAR)
          AND ((a.TypeAddress_CODE = @Lc_AddressTypeState_CODE
                AND a.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE)
                OR (a.TypeAddress_CODE = @Lc_AddressTypeInt_CODE
                    AND a.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE))
          AND a.EndValidity_DATE = @Ld_High_DATE;
      END
     ELSE IF @Lc_CheckCur_CheckRecipient_CODE = @Lc_CheckRecipientOtherParty_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
       SET @Ls_Sqldata_TEXT='CheckRecipient_ID = ' + CAST(ISNULL(@Lc_CheckCur_CheckRecipient_ID, '') AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT @Lc_Payee_ID = a.OtherParty_NAME
         FROM OTHP_Y1 a
        WHERE a.OtherParty_IDNO = @Lc_CheckCur_CheckRecipient_ID
          AND a.EndValidity_DATE = @Ld_High_DATE;
      END

     --Insert the EXCHK_Y1 into the Table
     SET @Ls_Sql_TEXT='INSERT EXCHK_Y1';
     SET @Ls_Sqldata_TEXT = 'Account_NUMB = ' + ISNULL(@Lc_CheckCur_Account_NUMB, '') + ', RecordType_CODE = ' + @Lc_CheckCur_RecordType_CODE + ', Issue_DATE = ' + ISNULL(CAST(@Ld_CheckCur_Issue_DATE AS VARCHAR), '') + ', Disburse_AMNT = ' + ISNULL(CAST(@Ln_CheckCur_Disburse_AMNT AS VARCHAR), '') + ', Check_NUMB = ' + CAST(@Ln_CheckCur_Check_NUMB AS VARCHAR) + ', Payee_ID = ' + @Lc_Payee_ID;

     INSERT INTO EXCHK_Y1
                 (Account_NUMB,
                  Rec_ID,
                  IssueVoid_DATE,
                  Check_NUMB,
                  CheckDisburse_AMNT,
                  Payee_ID)
          VALUES( @Lc_CheckCur_Account_NUMB,--Account_NUMB
                  @Lc_CheckCur_RecordType_CODE,--Rec_ID
                  REPLACE(CONVERT(CHAR(10), @Ld_CheckCur_Issue_DATE, 101), '/', ''),-- MMDDCCYY format,		--IssueVoid_DATE
                  @Ln_CheckCur_Check_NUMB,--Check_NUMB
                  CAST(CAST(ROUND(ISNULL(@Ln_CheckCur_Disburse_AMNT, 0), 2) * 100 AS BIGINT)AS CHAR(12)),--CheckDisburse_AMNT
                  CONVERT(CHAR(15), @Lc_Payee_ID) ); --Payee_ID

     --Rowcount information to append that to the file footer with record type
     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     --If rowcount is Zero insert into Bate 
     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT RECORD FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Check_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Check_CUR INTO @Lc_CheckCur_CheckRecipient_ID, @Lc_CheckCur_CheckRecipient_CODE, @Ln_CheckCur_DisburseSeq_NUMB, @Ld_CheckCur_Disburse_DATE, @Lc_CheckCur_Account_NUMB, @Ln_CheckCur_Check_NUMB, @Ln_CheckCur_Disburse_AMNT, @Ld_CheckCur_Issue_DATE, @Lc_CheckCur_RecordType_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Check_CUR;

   DEALLOCATE Check_CUR;

   -- Detail Record Process
   SET @Ls_Sql_TEXT = 'INSERT ##ExtractCheck_P1';
   SET @Ls_Sqldata_TEXT ='DetailRecord_ID = ' + @Lc_DetailRecord_ID;

   INSERT INTO ##ExtractCheck_P1
               (Record_TEXT)
   SELECT @Lc_DetailRecord_ID + CONVERT(CHAR(10), a.Account_NUMB) + CONVERT(CHAR(1), a.Rec_ID) + CONVERT(CHAR(8), a.IssueVoid_DATE) + RIGHT(('0000000000' + LTRIM(RTRIM(a.Check_NUMB))), 10) + RIGHT(('000000000000' + LTRIM(RTRIM(a.CheckDisburse_AMNT))), 12) + CONVERT(CHAR(15), a.Payee_ID) + REPLICATE(' ', 23) AS Record_TEXT
     FROM EXCHK_Y1 a;

   --Rowcount information to append that to the file footer with record type
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   --If rowcount is Zero insert into Bate 
   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS FOUND';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeWarning_CODE, '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorNoDataFound_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_ErrorNoDataFound_CODE,
      @As_DescriptionError_TEXT    = @Ls_SqlData_TEXT,
      @As_ListKey_TEXT             = @Ls_Sql_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END

   SET @Ls_Sql_TEXT = 'SELECT DETAIL RECORD COUNT';
   SET @Ls_Sqldata_TEXT = 'Detail Record Identifier = ' + CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR);

   -- Total Detail Count  
   SELECT @Ln_DetailRecordCount_QNTY = COUNT(1)
     FROM EXCHK_Y1 a;

   -- Total Detail Amt  
   SET @Ln_TotalCheck_AMNT = (ISNULL((SELECT SUM(CAST(a.CheckDisburse_AMNT AS NUMERIC))
                                        FROM EXCHK_Y1 a), 0));
   SET @Ls_Sql_TEXT ='INSERT ##ExtractIVE_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'TrailerRecord_CODE = ' + @Lc_TrailerRecord_CODE + ', DefaultAccount_NUMB = ' + @Lc_DefaultAccount_NUMB + ', DetailRecordCount_QNTY = ' + CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR) + ', TotalCheck_AMNT = ' + CAST(@Ln_TotalCheck_AMNT AS VARCHAR);

   --Trailer Record			         
   INSERT INTO ##ExtractCheck_P1
               (Record_TEXT)
        VALUES ( @Lc_TrailerRecord_CODE + @Lc_DefaultAccount_NUMB + REPLICATE(@Lc_Space_TEXT, 7) + RIGHT(('0000000000' + LTRIM(RTRIM(@Ln_DetailRecordCount_QNTY))), 10) + RIGHT(('000000000000' + LTRIM(RTRIM(@Ln_TotalCheck_AMNT))), 12) + REPLICATE(' ', 40) --Record_TEXT
   );

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractCheck_P1 order by Seq_IDNO';

   COMMIT TRANSACTION ExtractCHK;

   SET @Ls_Sql_TEXT='BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_Query_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION ExtractCHK;

   /*
   Update last run date in the PARM_Y1 table with the run date, upon successful completion
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_DetailRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_DetailRecordCount_QNTY;

   COMMIT TRANSACTION ExtractCHK;

   --Drop temperoray Table
   SET @Ls_Sql_TEXT = 'DROP ##ExtractCheck_P1 TABLE';
   SET @Ls_Sqldata_TEXT ='';

   DROP TABLE ##ExtractCheck_P1;
  END TRY

  BEGIN CATCH
   --Commit the Transaction 		
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractCHK;
    END

   IF CURSOR_STATUS ('LOCAL', 'Check_CUR') IN (0, 1)
    BEGIN
     CLOSE Check_CUR;

     DEALLOCATE Check_CUR;
    END

   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..##ExtractCheck_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractCheck_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
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
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_DetailRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
