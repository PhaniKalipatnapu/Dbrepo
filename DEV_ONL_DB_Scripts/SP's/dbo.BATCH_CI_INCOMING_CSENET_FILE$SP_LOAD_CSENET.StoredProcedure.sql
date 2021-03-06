/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_LOAD_CSENET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_LOAD_CSENET
Programmer Name	:	IMP Team.
Description		:	This process loads the inbound CSENET transaction into tables according to the data blocks in the file
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
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_LOAD_CSENET]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_CaseBlkLength_NUMB      INT = 351,
          @Li_NcpBlkLength_NUMB       INT = 181,
          @Li_NcpLocateBlkLength_NUMB INT = 1421,
          @Li_PartBlkLength_NUMB      INT = 341,
          @Li_OrderBlkLength_NUMB     INT = 254,
          @Li_CollBlkLength_NUMB      INT = 70,
          @Li_InfoBlkLength_NUMB      INT = 416,
          @Li_Loop_NUMB               INT = 1,
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_No_INDC                 CHAR(1) = 'N',
          @Lc_StringZero_TEXT         CHAR(1) = '0',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_InputDirection_TEXT     CHAR(1) = 'I',
          @Lc_UnNormalized_CODE       CHAR(1) = 'U',
          @Lc_BateError_CODE          CHAR(5) = ' ',
          @Lc_ErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_Job_ID                  CHAR(7) = 'DEB0330',
          @Lc_Success_TEXT            CHAR(10) = 'SUCCESSFUL',
          @Lc_BatchWorker_IDNO        CHAR(30) = 'BATCH',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_CSENET';
  DECLARE @Ln_CommitFreq_QNTY            NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY    NUMERIC(5),
          @Ln_StartPos_NUMB              NUMERIC(5),
          @Ln_LoopPos_NUMB               NUMERIC(5),
          @Ln_NormalizationStartPos_NUMB NUMERIC(6),
          @Ln_MemberMci_IDNO             NUMERIC(10),
          @Ln_Rec_QNTY                   NUMERIC(10) = 0,
          @Ln_TransHeader_IDNO           NUMERIC(12),
          @Li_Tbsn_NUMB                  INT = 0,
          @Li_Error_NUMB                 INT,
          @Li_ErrorLine_NUMB             INT,
          @Li_Zero_NUMB                  SMALLINT = 0,
          @Li_CaseBlk_QNTY               SMALLINT,
          @Li_NcpBlk_QNTY                SMALLINT,
          @Li_NcplocBlk_QNTY             SMALLINT,
          @Li_OrderBlk_QNTY              SMALLINT,
          @Li_InfoBlk_QNTY               SMALLINT,
          @Li_PartBlk_QNTY               SMALLINT,
          @Li_CollBlk_QNTY               SMALLINT,
          @Li_FetchStatus_NUMB           SMALLINT,
          @Li_RowCount_QNTY              SMALLINT,
          @Lc_FipsOthState_CODE          CHAR(2),
          @Lc_Msg_CODE                   CHAR(5),
          @Lc_Case_IDNO                  CHAR(6),
          @Lc_TransactionDate_TEXT       CHAR(8),
          @Ls_CnLoadCur_LineData_TEXT    VARCHAR(MAX) = '',
          @Ls_File_NAME                  VARCHAR(50),
          @Ls_FileLocation_TEXT          VARCHAR(80),
          @Ls_FileSource_TEXT            VARCHAR(100),
          @Ls_CursorLoc_TEXT             VARCHAR(100),
          @Ls_SqlStmnt_TEXT              VARCHAR(400),
          @Ls_DescriptionError_TEXT      VARCHAR(1000),
          @Ls_Sql_TEXT                   VARCHAR(4000),
          @Ls_Sqldata_TEXT               VARCHAR(4000),
          @Ls_BufferTxt_TEXT             VARCHAR(4000),
          @Ls_ErrorMessage_TEXT          VARCHAR(4000),
          @Ld_Run_DATE                   DATE,
          @Ld_LastRun_DATE               DATETIME2,
          @Ld_Start_DATE                 DATETIME2;

  BEGIN TRANSACTION LOAD_CSENET;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'SELECT BATCH DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXEC BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE FROM LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LTHBL_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LCDBL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LCDBL_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LNBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LNBLK_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LNLBL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LNLBL_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LPBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LPBLK_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LOBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LOBLK_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LCBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LCBLK_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'DELETE FROM LIBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE LIBLK_Y1
    WHERE Process_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'CREATE LOCAL TEMPORARY TABLE';

   CREATE TABLE #LoadCsenet_P1
    (
      Record_TEXT VARCHAR(MAX)
    );

   --Load data into temp table
   SET @Ls_Sql_TEXT = 'LOAD TO LOCAL TEMPORARY TABLE';
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadCsenet_P1 FROM  ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_Sqldata_TEXT = 'SqlStmnt_TEXT = ' + ISNULL(@Ls_SqlStmnt_TEXT, '');

   EXEC (@Ls_SqlStmnt_TEXT);

   SET @Ln_Rec_QNTY = @Li_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'LOAD DATA';

   DECLARE CnLoad_CUR INSENSITIVE CURSOR FOR
    SELECT a.Record_TEXT
      FROM #LoadCsenet_P1 a;

   OPEN CnLoad_CUR;

   FETCH NEXT FROM CnLoad_CUR INTO @Ls_CnLoadCur_LineData_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   --When no records are selected to process.
   IF @Li_FetchStatus_NUMB <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   -- Load all the records from incoming file to appropriate tables and blocks
   WHILE (@Li_FetchStatus_NUMB = 0)
    BEGIN
     SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + 1;
     SET @Ls_Sql_TEXT = 'VALUES READING FROM TEXT FILE';
     SET @Ls_CursorLoc_TEXT = ' RECORD # = ' + ISNULL(CAST(@Ln_Rec_QNTY AS VARCHAR), '');

     IF (@Ls_CnLoadCur_LineData_TEXT IS NOT NULL
         AND LTRIM(@Ls_CnLoadCur_LineData_TEXT) != '')
      BEGIN
       SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, 1, 121);
       SET @Lc_TransactionDate_TEXT = SUBSTRING(@Ls_BufferTxt_TEXT, 38, 8);
       SET @Ln_TransHeader_IDNO = SUBSTRING(@Ls_BufferTxt_TEXT, 18, 12);
       SET @Lc_FipsOthState_CODE = RIGHT(REPLICATE('0', 2) + SUBSTRING(@Ls_BufferTxt_TEXT, 8, 2), 2);
       SET @Lc_Case_IDNO = LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, 46, 15)));
       SET @Ln_StartPos_NUMB = @Li_Zero_NUMB;

       IF (ISNUMERIC(@Lc_Case_IDNO) = 0)
        BEGIN
         SET @Lc_Case_IDNO = '0';
        END;

       IF (@Lc_Case_IDNO = '')
        BEGIN
         SET @Lc_Case_IDNO = '0';
        END;

       SET @Ls_Sql_TEXT = 'LOADING DATA TO LTHBL_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Message_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', IoDirection_CODE = ' + ISNULL(@Lc_InputDirection_TEXT, '') + ', Case_IDNO = ' + ISNULL(@Lc_Case_IDNO, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchWorker_IDNO, '') + ', RejectReason_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', End_DATE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

       INSERT LTHBL_Y1
              (TransHeader_IDNO,
               Message_ID,
               IoDirection_CODE,
               StateFips_CODE,
               CountyFips_CODE,
               OfficeFips_CODE,
               IVDOutOfStateCase_ID,
               IVDOutOfStateFips_CODE,
               IVDOutOfStateCountyFips_CODE,
               IVDOutOfStateOfficeFips_CODE,
               CsenetTran_ID,
               Function_CODE,
               Action_CODE,
               Reason_CODE,
               Case_IDNO,
               Stored_DATE,
               CsenetVersion_ID,
               TranStatus_CODE,
               ErrorReason_CODE,
               Received_DATE,
               Received_DTTM,
               ReceivedYearMonth_NUMB,
               AttachDue_DATE,
               SntToStHost_CODE,
               ProcComplete_CODE,
               InterstateFrmsPrint_CODE,
               WorkerUpdate_ID,
               Transaction_DATE,
               ActionResolution_DATE,
               Attachments_INDC,
               CaseData_QNTY,
               Ncp_QNTY,
               NcpLoc_QNTY,
               Participant_QNTY,
               Order_QNTY,
               Collection_QNTY,
               Info_QNTY,
               RejectReason_CODE,
               End_DATE,
               Process_INDC,
               FileLoad_DATE)
       VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                @Lc_Space_TEXT,--Message_ID
                @Lc_InputDirection_TEXT,--IoDirection_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 1, 2),--StateFips_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 3, 3),--CountyFips_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 6, 2),--OfficeFips_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 61, 15),--IVDOutOfStateCase_ID
                RIGHT(REPLICATE('0', 2) + SUBSTRING(@Ls_BufferTxt_TEXT, 8, 2), 2),--IVDOutOfStateFips_CODE
                RIGHT(REPLICATE('0', 3) + SUBSTRING(@Ls_BufferTxt_TEXT, 10, 3), 3),--IVDOutOfStateCountyFips_CODE
                RIGHT(REPLICATE('0', 2) + SUBSTRING(@Ls_BufferTxt_TEXT, 13, 2), 2),--IVDOutOfStateOfficeFips_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 18, 12),--CsenetTran_ID
                SUBSTRING(@Ls_BufferTxt_TEXT, 35, 3),--Function_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 34, 1),--Action_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 76, 5),--Reason_CODE
                @Lc_Case_IDNO,--Case_IDNO
                CONVERT(VARCHAR(10), @Ld_Run_DATE, 112),--Stored_DATE
                SUBSTRING(@Ls_BufferTxt_TEXT, 15, 3),--CsenetVersion_ID
                SUBSTRING(@Ls_BufferTxt_TEXT, 32, 2),--TranStatus_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 30, 2),--ErrorReason_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 97, 8),--Received_DATE
                SUBSTRING(@Ls_BufferTxt_TEXT, 105, 6),--Received_DTTM
                SUBSTRING(@Ls_BufferTxt_TEXT, 97, 6),--ReceivedYearMonth_NUMB
                SUBSTRING(@Ls_BufferTxt_TEXT, 112, 8),--AttachDue_DATE
                SUBSTRING(@Ls_BufferTxt_TEXT, 120, 1),--SntToStHost_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 111, 1),--ProcComplete_CODE
                SUBSTRING(@Ls_BufferTxt_TEXT, 121, 1),--InterstateFrmsPrint_CODE
                @Lc_BatchWorker_IDNO,--WorkerUpdate_ID
                SUBSTRING(@Ls_BufferTxt_TEXT, 38, 8),--Transaction_DATE
                SUBSTRING(@Ls_BufferTxt_TEXT, 81, 8),--ActionResolution_DATE
                SUBSTRING(@Ls_BufferTxt_TEXT, 89, 1),--Attachments_INDC
                SUBSTRING(@Ls_BufferTxt_TEXT, 90, 1),--CaseData_QNTY
                SUBSTRING(@Ls_BufferTxt_TEXT, 91, 1),--Ncp_QNTY
                SUBSTRING(@Ls_BufferTxt_TEXT, 92, 1),--NcpLoc_QNTY
                SUBSTRING(@Ls_BufferTxt_TEXT, 93, 1),--Participant_QNTY
                SUBSTRING(@Ls_BufferTxt_TEXT, 94, 1),--Order_QNTY
                SUBSTRING(@Ls_BufferTxt_TEXT, 95, 1),--Collection_QNTY
                SUBSTRING(@Ls_BufferTxt_TEXT, 96, 1),--Info_QNTY
                @Lc_Space_TEXT,--RejectReason_CODE
                @Lc_Space_TEXT,--End_DATE
                @Lc_No_INDC,--Process_INDC
                @Ld_Run_DATE --FileLoad_DATE
       );

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = @Li_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LTHBL_Y1 TABLE';

         RAISERROR(50001,16,1);
        END;

       SET @Ln_StartPos_NUMB = 121;
       SET @Li_CaseBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 90, 1) AS NUMERIC);
       SET @Li_NcpBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 91, 1) AS NUMERIC);
       SET @Li_NcplocBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 92, 1) AS NUMERIC);
       SET @Li_OrderBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 94, 1) AS NUMERIC);
       SET @Li_InfoBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 96, 1) AS NUMERIC);
       SET @Li_PartBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 93, 1) AS NUMERIC);
       SET @Li_CollBlk_QNTY = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, 95, 1) AS NUMERIC);
       SET @Ls_Sql_TEXT = 'LOADING DATA TO LCDBL_Y1';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;
       -- For Delaware, the input file will always have 8600 columns in a row. The Normalization will be from 8601.
       SET @Ln_NormalizationStartPos_NUMB = 8601;

       --SET @Ln_NormalizationStartPos_NUMB = (121 + (@Li_CaseBlk_QNTY * @Li_CaseBlkLength_NUMB) + (@Li_NcpBlk_QNTY * @Li_NcpBlkLength_NUMB) + (@Li_NcplocBlk_QNTY * @Li_NcpLocateBlkLength_NUMB) + (@Li_PartBlk_QNTY * @Li_PartBlkLength_NUMB) + (@Li_OrderBlk_QNTY * @Li_OrderBlkLength_NUMB) + (@Li_CollBlk_QNTY * @Li_CollBlkLength_NUMB) + (@Li_InfoBlk_QNTY * @Li_InfoBlkLength_NUMB)) + 1;
       IF @Li_CaseBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_CaseBlkLength_NUMB * @Li_CaseBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + @Li_CaseBlkLength_NUMB * @Li_CaseBlk_QNTY;
        END;

       SET @Ls_Sql_TEXT = 'LOADING DATA TO LCDBL_Y1';
       SET @Li_Loop_NUMB = 1;

       -- Insert all the Case details from input file to the Case block table
       WHILE @Li_Loop_NUMB <= @Li_CaseBlk_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'LOADING DATA TO LCDBL_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

         INSERT LCDBL_Y1
                (TransHeader_IDNO,
                 Transaction_DATE,
                 IVDOutOfStateFips_CODE,
                 TypeCase_CODE,
                 StatusCase_CODE,
                 PaymentLine1Old_ADDR,
                 PaymentLine2Old_ADDR,
                 PaymentCityOld_ADDR,
                 PaymentStateOld_ADDR,
                 PaymentZipOld_ADDR,
                 Last_NAME,
                 First_NAME,
                 Middle_NAME,
                 Suffix_NAME,
                 ContactLine1Old_ADDR,
                 ContactLine2Old_ADDR,
                 ContactCityOld_ADDR,
                 ContactStateOld_ADDR,
                 ContactZipOld_ADDR,
                 ContactPhone_NUMB,
                 PhoneExtensionCount_NUMB,
                 RespondingFile_ID,
                 Fax_NUMB,
                 Contact_EML,
                 InitiatingFile_ID,
                 AcctSendPaymentsBankNo_TEXT,
                 SendPaymentsRouting_ID,
                 StateWithCej_CODE,
                 PayFipsSt_CODE,
                 PayFipsCnty_CODE,
                 PayFipsSub_CODE,
                 NondisclosureFinding_INDC,
                 Process_INDC,
                 Normalization_CODE,
                 PaymentLine1_ADDR,
                 PaymentLine2_ADDR,
                 PaymentCity_ADDR,
                 PaymentState_ADDR,
                 PaymentZip_ADDR,
                 CountCdNormalization_QNTY,
                 ContactLine1_ADDR,
                 ContactLine2_ADDR,
                 ContactCity_ADDR,
                 ContactState_ADDR,
                 ContactZip_ADDR,
                 FileLoad_DATE)
         VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                  @Lc_TransactionDate_TEXT,--Transaction_DATE
                  @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 1),--TypeCase_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 2), 1),--StatusCase_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 3), 25),--PaymentLine1Old_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 28), 25),--PaymentLine2Old_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 53), 18),--PaymentCityOld_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 71), 2),--PaymentStateOld_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 73), 5) + SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 78), 4),--PaymentZipOld_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 82), 21),--Last_NAME
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 103), 16),--First_NAME
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 119), 16),--Middle_NAME
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 135), 3),--Suffix_NAME
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 138), 25),--ContactLine1Old_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 163), 25),--ContactLine2Old_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 188), 18),--ContactCityOld_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 206), 2),--ContactStateOld_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 208), 5) + SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 213), 4),--ContactZipOld_ADDR
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 217), 10),--ContactPhone_NUMB
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 227), 6),--PhoneExtensionCount_NUMB
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 233), 17),--RespondingFile_ID
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 250), 10),--Fax_NUMB
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 260), 35),--Contact_EML
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 295), 17),--InitiatingFile_ID
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 312), 20),--AcctSendPaymentsBankNo_TEXT
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 332), 10),--SendPaymentsRouting_ID
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 342), 2),--StateWithCej_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 344), 2),--PayFipsSt_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 346), 3),--PayFipsCnty_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 349), 2),--PayFipsSub_CODE
                  SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 351), 1),--NondisclosureFinding_INDC
                  @Lc_No_INDC,--Process_INDC
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB), 1), @Lc_UnNormalized_CODE),--Normalization_CODE
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1), 50), @Lc_Space_TEXT),--PaymentLine1_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 51), 50), @Lc_Space_TEXT),--PaymentLine2_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 101), 28), @Lc_Space_TEXT),--PaymentCity_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 129), 2), @Lc_Space_TEXT),--PaymentState_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 131), 15), @Lc_Space_TEXT),--PaymentZip_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 146), 1), @Lc_UnNormalized_CODE),--CountCdNormalization_QNTY
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 147), 50), @Lc_Space_TEXT),--ContactLine1_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 197), 50), @Lc_Space_TEXT),--ContactLine2_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 247), 28), @Lc_Space_TEXT),--ContactCity_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 275), 2), @Lc_Space_TEXT),--ContactState_ADDR
                  ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 277), 15), @Lc_Space_TEXT),--ContactZip_ADDR
                  @Ld_Run_DATE --FileLoad_DATE
         );

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LCDBL_Y1 TABLE';

           RAISERROR(50001,16,1);
          END;

         SET @Ln_LoopPos_NUMB = @Li_CaseBlkLength_NUMB * @Li_Loop_NUMB;
         SET @Ln_NormalizationStartPos_NUMB = @Ln_NormalizationStartPos_NUMB + 292;
         SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
        END;

       IF @Li_NcpBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_NcpBlkLength_NUMB * @Li_NcpBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + (@Li_NcpBlkLength_NUMB * @Li_NcpBlk_QNTY);
        END;

       SET @Ls_Sql_TEXT = 'LOADING DATA TO LNBLK_Y1';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;

       BEGIN
        SET @Li_Loop_NUMB = 1;

        -- Insert all the NCP details from input file to the NCP block table
        WHILE @Li_Loop_NUMB <= @Li_NcpBlk_QNTY
         BEGIN
          SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;

          IF (RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 57), 9)) != '')
           BEGIN
            SET @Ls_Sqldata_TEXT = '';

            SELECT TOP 1 @Ln_MemberMci_IDNO = a.MemberMci_IDNO
              FROM DEMO_Y1 a
             WHERE a.MemberSsn_NUMB = CAST(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 57), 9) AS NUMERIC);
           END;

          SET @Ls_Sql_TEXT = 'LOADING DATA TO LNBLK_Y1';
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

          INSERT LNBLK_Y1
                 (TransHeader_IDNO,
                  Transaction_DATE,
                  IVDOutOfStateFips_CODE,
                  MemberMci_IDNO,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Suffix_NAME,
                  MemberSsn_NUMB,
                  Birth_DATE,
                  Race_CODE,
                  MemberSex_CODE,
                  PlaceOfBirth_NAME,
                  FtHeight_TEXT,
                  InHeight_TEXT,
                  DescriptionWeightLbs_TEXT,
                  ColorHair_CODE,
                  ColorEyes_CODE,
                  DistinguishingMarks_TEXT,
                  Alias1Ssn_NUMB,
                  Alias2Ssn_NUMB,
                  PossiblyDangerous_INDC,
                  Maiden_NAME,
                  FatherOrMomMaiden_NAME,
                  Process_INDC,
                  FileLoad_DATE)
          VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                   @Lc_TransactionDate_TEXT,--Transaction_DATE
                   @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                   CAST((CASE LTRIM(@Ln_MemberMci_IDNO)
                          WHEN ''
                           THEN @Lc_StringZero_TEXT
                          ELSE @Ln_MemberMci_IDNO
                         END) AS NUMERIC),--MemberMci_IDNO
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 21),--Last_NAME
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 22), 16),--First_NAME
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 38), 16),--Middle_NAME
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 54), 3),--Suffix_NAME
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 57), 9),--MemberSsn_NUMB
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 66), 8),--Birth_DATE
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 74), 1),--Race_CODE
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 75), 1),--MemberSex_CODE
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 76), 15),--PlaceOfBirth_NAME
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 91), 1),--FtHeight_TEXT
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 92), 2),--InHeight_TEXT
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 94), 3),--DescriptionWeightLbs_TEXT
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 97), 2),--ColorHair_CODE
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 99), 2),--ColorEyes_CODE
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 101), 20),--DistinguishingMarks_TEXT
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 121), 9),--Alias1Ssn_NUMB
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 130), 9),--Alias2Ssn_NUMB
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 139), 1),--PossiblyDangerous_INDC
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 140), 21),--Maiden_NAME
                   SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 161), 21),--FatherOrMomMaiden_NAME
                   @Lc_No_INDC,--Process_INDC
                   @Ld_Run_DATE --FileLoad_DATE
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = @Li_Zero_NUMB
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LNBLK_Y1 TABLE';

            RAISERROR(50001,16,1);
           END;

          SET @Ln_LoopPos_NUMB = @Li_NcpBlkLength_NUMB * @Li_Loop_NUMB;
          SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
         END;
       END;

       IF @Li_NcplocBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_NcpLocateBlkLength_NUMB * @Li_NcplocBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + (@Li_NcpLocateBlkLength_NUMB * @Li_NcplocBlk_QNTY);
        END;

       SET @Ls_Sql_TEXT = 'LOADING DATA TO LNLBL_Y1 TABLE';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;

       BEGIN
        SET @Li_Loop_NUMB = 1;

        -- Insert all the NCP Locate details from input file to the NCP Locate block table
        WHILE @Li_Loop_NUMB <= @Li_NcplocBlk_QNTY
         BEGIN
          SET @Ls_Sql_TEXT = 'LOADING DATA TO LNLBL_Y1';
          SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

          INSERT LNLBL_Y1
                 (TransHeader_IDNO,
                  Transaction_DATE,
                  IVDOutOfStateFips_CODE,
                  ResidentialLine1Old_ADDR,
                  ResidentialLine2Old_ADDR,
                  ResidentialCityOld_ADDR,
                  ResidentialStateOld_ADDR,
                  ResidentialZip1Old_ADDR,
                  ResidentialZip2Old_ADDR,
                  MailingLine1Old_ADDR,
                  MailingLine2Old_ADDR,
                  MailingCityOld_ADDR,
                  MailingStateOld_ADDR,
                  MailingZip1Old_ADDR,
                  MailingZip2Old_ADDR,
                  EffectiveResidential_DATE,
                  EndResidential_DATE,
                  ResidentialConfirmed_CODE,
                  EffectiveMailing_DATE,
                  EndMailing_DATE,
                  MailingConfirmed_CODE,
                  HomePhone_NUMB,
                  WorkPhone_NUMB,
                  DriversLicenseState_CODE,
                  DriversLicenseNo_TEXT,
                  Alias1First_NAME,
                  Alias1Middle_NAME,
                  Alias1Last_NAME,
                  Alias1Suffix_NAME,
                  Alias2First_NAME,
                  Alias2Middle_NAME,
                  Alias2Last_NAME,
                  Alias2Suffix_NAME,
                  Alias3First_NAME,
                  Alias3Middle_NAME,
                  Alias3Last_NAME,
                  Alias3Suffix_NAME,
                  SpouseLast_NAME,
                  SpouseFirst_NAME,
                  SpouseMiddle_NAME,
                  SpouseSuffix_NAME,
                  Occupation_TEXT,
                  EmployerEin_ID,
                  Employer_NAME,
                  EmployerLine1Old_ADDR,
                  EmployerLine2Old_ADDR,
                  EmployerCityOld_ADDR,
                  EmployerStateOld_ADDR,
                  EmployerZip1Old_ADDR,
                  EmployerZip2Old_ADDR,
                  EmployerPhone_NUMB,
                  EffectiveEmployer_DATE,
                  EndEmployer_DATE,
                  EmployerConfirmed_INDC,
                  WageQtr_CODE,
                  WageYear_NUMB,
                  Wage_AMNT,
                  InsCarrier_NAME,
                  PolicyInsNo_TEXT,
                  LastResLine1Old_ADDR,
                  LastResLine2Old_ADDR,
                  LastResCityOld_ADDR,
                  LastResStateOld_ADDR,
                  LastResZip1Old_ADDR,
                  LastResZip2Old_ADDR,
                  LastResAddress_DATE,
                  LastMailLine1Old_ADDR,
                  LastMailLine2Old_ADDR,
                  LastMailCityOld_ADDR,
                  LastMailStateOld_ADDR,
                  LastMailZip1Old_ADDR,
                  LastMailZip2Old_ADDR,
                  LastMailAddress_DATE,
                  LastEmployer_NAME,
                  LastEmployer_DATE,
                  LastEmployerLine1Old_ADDR,
                  LastEmployerLine2Old_ADDR,
                  LastEmployerCityOld_ADDR,
                  LastEmployerStateOld_ADDR,
                  LastEmployerZip1Old_ADDR,
                  LastEmployerZip2Old_ADDR,
                  LastEmployerEffective_DATE,
                  Employer2Ein_ID,
                  Employer2_NAME,
                  Employer2Line1Old_ADDR,
                  Employer2Line2Old_ADDR,
                  Employer2CityOld_ADDR,
                  Employer2StateOld_ADDR,
                  Employer2Zip1Old_ADDR,
                  Employer2Zip2Old_ADDR,
                  Employer2Phone_NUMB,
                  EffectiveEmployer2_DATE,
                  EndEmployer2_DATE,
                  Employer2Confirmed_INDC,
                  Wage2Qtr_CODE,
                  Wage2Year_NUMB,
                  Wage2_AMNT,
                  Employer3Ein_ID,
                  Employer3_NAME,
                  Employer3Line1Old_ADDR,
                  Employer3Line2Old_ADDR,
                  Employer3CityOld_ADDR,
                  Employer3StateOld_ADDR,
                  Employer3Zip1Old_ADDR,
                  Employer3Zip2Old_ADDR,
                  Employer3Phone_NUMB,
                  EffectiveEmployer3_DATE,
                  EndEmployer3_DATE,
                  Employer3Confirmed_INDC,
                  Wage3Qtr_CODE,
                  Wage3Year_NUMB,
                  Wage3_AMNT,
                  ProfessionalLicenses_TEXT,
                  Process_INDC,
                  ResNormalization_CODE,
                  ResidentialLine1_ADDR,
                  ResidentialLine2_ADDR,
                  ResidentialCity_ADDR,
                  ResidentialState_ADDR,
                  ResidentialZip_ADDR,
                  MailNormalization_CODE,
                  MailingLine1_ADDR,
                  MailingLine2_ADDR,
                  MailingCity_ADDR,
                  MailingState_ADDR,
                  MailingZip_ADDR,
                  EmpNormalization_CODE,
                  EmployerLine1_ADDR,
                  EmployerLine2_ADDR,
                  EmployerCity_ADDR,
                  EmployerState_ADDR,
                  EmployerZip_ADDR,
                  LastResNormalization_CODE,
                  LastResidentialLine1_ADDR,
                  LastResidentialLine2_ADDR,
                  LastResidentialCity_ADDR,
                  LastResidentialState_ADDR,
                  LastResZip_ADDR,
                  LastMailNormalization_CODE,
                  LastMailLine1_ADDR,
                  LastMailLine2_ADDR,
                  LastMailCity_ADDR,
                  LastMailState_ADDR,
                  LastMailZip_ADDR,
                  LastEmpNormalization_CODE,
                  LastEmployerLine1_ADDR,
                  LastEmployerLine2_ADDR,
                  LastEmployerCity_ADDR,
                  LastEmployerState_ADDR,
                  LastEmployerZip_ADDR,
                  Emp2Normalization_CODE,
                  Employer2Line1_ADDR,
                  Employer2Line2_ADDR,
                  Employer2City_ADDR,
                  Employer2State_ADDR,
                  Employer2Zip_ADDR,
                  Emp3Normalization_CODE,
                  Employer3Line1_ADDR,
                  Employer3Line2_ADDR,
                  Employer3City_ADDR,
                  Employer3State_ADDR,
                  Employer3Zip_ADDR,
                  FileLoad_DATE)
          VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                   @Lc_TransactionDate_TEXT,--Transaction_DATE
                   @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 25))),--ResidentialLine1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 26), 25))),--ResidentialLine2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 51), 18))),--ResidentialCityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 69), 2))),--ResidentialStateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 71), 5))),--ResidentialZip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 76), 4))),--ResidentialZip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 80), 25))),--MailingLine1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 105), 25))),--MailingLine2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 130), 18))),--MailingCityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 148), 2))),--MailingStateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 150), 5))),--MailingZip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 155), 4))),--MailingZip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 159), 8))),--EffectiveResidential_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 167), 8))),--EndResidential_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 175), 1))),--ResidentialConfirmed_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 176), 8))),--EffectiveMailing_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 184), 8))),--EndMailing_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 192), 1))),--MailingConfirmed_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 193), 10))),--HomePhone_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 203), 10))),--WorkPhone_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 213), 2))),--DriversLicenseState_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 215), 20))),--DriversLicenseNo_TEXT
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 235), 16))),--Alias1First_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 251), 16))),--Alias1Middle_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 267), 21))),--Alias1Last_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 288), 3))),--Alias1Suffix_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 291), 16))),--Alias2First_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 307), 16))),--Alias2Middle_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 323), 21))),--Alias2Last_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 344), 3))),--Alias2Suffix_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 347), 16))),--Alias3First_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 363), 16))),--Alias3Middle_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 379), 21))),--Alias3Last_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 400), 3))),--Alias3Suffix_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 403), 21))),--SpouseLast_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 424), 16))),--SpouseFirst_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 440), 16))),--SpouseMiddle_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 456), 3))),--SpouseSuffix_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 459), 32))),--Occupation_TEXT
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 491), 9))),--EmployerEin_ID
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 500), 40))),--Employer_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 540), 25))),--EmployerLine1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 565), 25))),--EmployerLine2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 590), 18))),--EmployerCityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 608), 2))),--EmployerStateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 610), 5))),--EmployerZip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 615), 4))),--EmployerZip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 619), 10))),--EmployerPhone_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 629), 8))),--EffectiveEmployer_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 637), 8))),--EndEmployer_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 645), 1))),--EmployerConfirmed_INDC
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 646), 1))),--WageQtr_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 647), 4))),--WageYear_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 651), 12))),--Wage_AMNT
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 663), 36))),--InsCarrier_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 699), 20))),--PolicyInsNo_TEXT
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 719), 25))),--LastResLine1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 744), 25))),--LastResLine2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 769), 18))),--LastResCityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 787), 2))),--LastResStateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 789), 5))),--LastResZip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 794), 4))),--LastResZip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 798), 8))),--LastResAddress_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 806), 25))),--LastMailLine1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 831), 25))),--LastMailLine2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 856), 18))),--LastMailCityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 874), 2))),--LastMailStateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 876), 5))),--LastMailZip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 881), 4))),--LastMailZip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 885), 8))),--LastMailAddress_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 893), 40))),--LastEmployer_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 933), 8))),--LastEmployer_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 941), 25))),--LastEmployerLine1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 966), 25))),--LastEmployerLine2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 991), 18))),--LastEmployerCityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1009), 2))),--LastEmployerStateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1011), 5))),--LastEmployerZip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1016), 4))),--LastEmployerZip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1020), 8))),--LastEmployerEffective_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1028), 9))),--Employer2Ein_ID
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1037), 40))),--Employer2_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1077), 25))),--Employer2Line1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1102), 25))),--Employer2Line2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1127), 18))),--Employer2CityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1145), 2))),--Employer2StateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1147), 5))),--Employer2Zip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1152), 4))),--Employer2Zip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1156), 10))),--Employer2Phone_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1166), 8))),--EffectiveEmployer2_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1174), 8))),--EndEmployer2_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1182), 1))),--Employer2Confirmed_INDC
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1183), 1))),--Wage2Qtr_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1184), 4))),--Wage2Year_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1188), 12))),--Wage2_AMNT
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1200), 9))),--Employer3Ein_ID
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1209), 40))),--Employer3_NAME
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1249), 25))),--Employer3Line1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1274), 25))),--Employer3Line2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1299), 18))),--Employer3CityOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1317), 2))),--Employer3StateOld_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1319), 5))),--Employer3Zip1Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1324), 4))),--Employer3Zip2Old_ADDR
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1328), 10))),--Employer3Phone_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1338), 8))),--EffectiveEmployer3_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1346), 8))),--EndEmployer3_DATE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1354), 1))),--Employer3Confirmed_INDC
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1355), 1))),--Wage3Qtr_CODE
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1356), 4))),--Wage3Year_NUMB
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1360), 12))),--Wage3_AMNT
                   LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1372), 50))),--ProfessionalLicenses_TEXT
                   @Lc_No_INDC,--Process_INDC
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB), 1), @Lc_UnNormalized_CODE),--ResNormalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1), 50), @Lc_Space_TEXT),--ResidentialLine1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 51), 50), @Lc_Space_TEXT),--ResidentialLine2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 101), 28), @Lc_Space_TEXT),--ResidentialCity_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 129), 2), @Lc_Space_TEXT),--ResidentialState_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 131), 15), @Lc_Space_TEXT),--ResidentialZip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 146), 1), @Lc_UnNormalized_CODE),--MailNormalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 147), 50), @Lc_Space_TEXT),--MailingLine1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 197), 50), @Lc_Space_TEXT),--MailingLine2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 247), 28), @Lc_Space_TEXT),--MailingCity_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 275), 2), @Lc_Space_TEXT),--MailingState_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 277), 15), @Lc_Space_TEXT),--MailingZip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 292), 1), @Lc_UnNormalized_CODE),--EmpNormalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 293), 50), @Lc_Space_TEXT),--EmployerLine1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 343), 50), @Lc_Space_TEXT),--EmployerLine2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 393), 28), @Lc_Space_TEXT),--EmployerCity_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 421), 2), @Lc_Space_TEXT),--EmployerState_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 423), 15), @Lc_Space_TEXT),--EmployerZip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 438), 1), @Lc_UnNormalized_CODE),--LastResNormalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 439), 50), @Lc_Space_TEXT),--LastResidentialLine1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 489), 50), @Lc_Space_TEXT),--LastResidentialLine2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 539), 28), @Lc_Space_TEXT),--LastResidentialCity_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 567), 2), @Lc_Space_TEXT),--LastResidentialState_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 569), 15), @Lc_Space_TEXT),--LastResZip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 584), 1), @Lc_UnNormalized_CODE),--LastMailNormalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 585), 50), @Lc_Space_TEXT),--LastMailLine1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 635), 50), @Lc_Space_TEXT),--LastMailLine2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 685), 28), @Lc_Space_TEXT),--LastMailCity_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 713), 2), @Lc_Space_TEXT),--LastMailState_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 715), 15), @Lc_Space_TEXT),--LastMailZip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 730), 1), @Lc_UnNormalized_CODE),--LastEmpNormalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 731), 50), @Lc_Space_TEXT),--LastEmployerLine1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 781), 50), @Lc_Space_TEXT),--LastEmployerLine2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 831), 28), @Lc_Space_TEXT),--LastEmployerCity_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 859), 2), @Lc_Space_TEXT),--LastEmployerState_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 861), 15), @Lc_Space_TEXT),--LastEmployerZip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 876), 1), @Lc_UnNormalized_CODE),--Emp2Normalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 877), 50), @Lc_Space_TEXT),--Employer2Line1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 927), 50), @Lc_Space_TEXT),--Employer2Line2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 977), 28), @Lc_Space_TEXT),--Employer2City_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1005), 2), @Lc_Space_TEXT),--Employer2State_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1007), 15), @Lc_Space_TEXT),--Employer2Zip_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1022), 1), @Lc_UnNormalized_CODE),--Emp3Normalization_CODE
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1023), 50), @Lc_Space_TEXT),--Employer3Line1_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1073), 50), @Lc_Space_TEXT),--Employer3Line2_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1123), 28), @Lc_Space_TEXT),--Employer3City_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1151), 2), @Lc_Space_TEXT),--Employer3State_ADDR
                   ISNULL(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1153), 15), @Lc_Space_TEXT),--Employer3Zip_ADDR
                   @Ld_Run_DATE --FileLoad_DATE
          );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = @Li_Zero_NUMB
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LNLBL_Y1 TABLE';

            RAISERROR(50001,16,1);
           END;

          SET @Ln_LoopPos_NUMB = @Li_NcpLocateBlkLength_NUMB * @Li_Loop_NUMB;
          SET @Ln_NormalizationStartPos_NUMB = @Ln_NormalizationStartPos_NUMB + 1168;
          SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
         END;
       END;

       IF @Li_PartBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_PartBlkLength_NUMB * @Li_PartBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + (@Li_PartBlkLength_NUMB * @Li_PartBlk_QNTY);
        END

       SET @Li_Tbsn_NUMB = @Li_Zero_NUMB;
       SET @Ls_Sql_TEXT = 'LOADING DATA TO LPBLK_Y1 TABLE';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;
       SET @Li_Loop_NUMB = 1;

       -- Insert all the Participant details from input file to the Participant block table
       WHILE @Li_Loop_NUMB <= @Li_PartBlk_QNTY
        BEGIN
         SET @Li_Tbsn_NUMB = @Li_Tbsn_NUMB + 1;
         SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;

         IF (RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 65), 9)) != '')
          BEGIN
           SET @Ls_Sqldata_TEXT = '';

           SELECT TOP 1 @Ln_MemberMci_IDNO = MemberMci_IDNO
             FROM DEMO_Y1 a
            WHERE a.MemberSsn_NUMB = SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 65), 9);
          END;

         SET @Ls_Sql_TEXT = 'LOADING DATA TO LPBLK_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', BlockSeq_NUMB = ' + ISNULL(CAST(@Li_Tbsn_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

         INSERT LPBLK_Y1
                (TransHeader_IDNO,
                 Transaction_DATE,
                 IVDOutOfStateFips_CODE,
                 BlockSeq_NUMB,
                 MemberMci_IDNO,
                 Last_NAME,
                 First_NAME,
                 Middle_NAME,
                 Suffix_NAME,
                 Birth_DATE,
                 MemberSsn_NUMB,
                 MemberSex_CODE,
                 Race_CODE,
                 Relationship_CODE,
                 ParticipantStatus_CODE,
                 ChildRelationshipNcp_CODE,
                 ParticipantLine1Old_ADDR,
                 ParticipantLine2Old_ADDR,
                 ParticipantCityOld_ADDR,
                 ParticipantStateOld_ADDR,
                 ParticipantZip1Old_ADDR,
                 ParticipantZip2Old_ADDR,
                 Employer_NAME,
                 EmployerLine1Old_ADDR,
                 EmployerLine2Old_ADDR,
                 EmployerCityOld_ADDR,
                 EmployerStateOld_ADDR,
                 EmployerZip1Old_ADDR,
                 EmployerZip2Old_ADDR,
                 EinEmployer_ID,
                 ConfirmedAddress_INDC,
                 ConfirmedAddress_DATE,
                 ConfirmedEmployer_INDC,
                 ConfirmedEmployer_DATE,
                 WorkPhone_NUMB,
                 PlaceOfBirth_NAME,
                 ChildStateResidence_CODE,
                 ChildPaternityStatus_CODE,
                 Process_INDC,
                 PartNormalization_CODE,
                 ParticipantLine1_ADDR,
                 ParticipantLine2_ADDR,
                 ParticipantCity_ADDR,
                 ParticipantState_ADDR,
                 ParticipantZip_ADDR,
                 EmpNormalization_CODE,
                 EmployerLine1_ADDR,
                 EmployerLine2_ADDR,
                 EmployerCity_ADDR,
                 EmployerState_ADDR,
                 EmployerZip_ADDR,
                 FileLoad_DATE)
         VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                  @Lc_TransactionDate_TEXT,--Transaction_DATE
                  @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                  @Li_Tbsn_NUMB,--BlockSeq_NUMB
                  @Ln_MemberMci_IDNO,--MemberMci_IDNO
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 21))),--Last_NAME
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 22), 16))),--First_NAME
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 38), 16))),--Middle_NAME
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 54), 3))),--Suffix_NAME
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 57), 8))),--Birth_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 65), 9))),--MemberSsn_NUMB
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 74), 1))),--MemberSex_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 75), 1))),--Race_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 76), 1))),--Relationship_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 77), 1))),--ParticipantStatus_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 78), 1))),--ChildRelationshipNcp_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 79), 25))),--ParticipantLine1Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 104), 25))),--ParticipantLine2Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 129), 18))),--ParticipantCityOld_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 147), 2))),--ParticipantStateOld_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 149), 5))),--ParticipantZip1Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 154), 4))),--ParticipantZip2Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 158), 40))),--Employer_NAME
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 198), 25))),--EmployerLine1Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 223), 25))),--EmployerLine2Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 248), 18))),--EmployerCityOld_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 266), 2))),--EmployerStateOld_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 268), 5))),--EmployerZip1Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 273), 4))),--EmployerZip2Old_ADDR
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 277), 9))),--EinEmployer_ID
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 286), 1))),--ConfirmedAddress_INDC
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 287), 8))),--ConfirmedAddress_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 295), 1))),--ConfirmedEmployer_INDC
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 296), 8))),--ConfirmedEmployer_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 304), 10))),--WorkPhone_NUMB
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 314), 25))),--PlaceOfBirth_NAME
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 339), 2))),--ChildStateResidence_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 341), 1))),--ChildPaternityStatus_CODE
                  @Lc_No_INDC,--Process_INDC
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB), 1))), @Lc_UnNormalized_CODE),--PartNormalization_CODE
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 1), 50))), @Lc_Space_TEXT),--ParticipantLine1_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 51), 50))), @Lc_Space_TEXT),--ParticipantLine2_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 101), 28))), @Lc_Space_TEXT),--ParticipantCity_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 129), 2))), @Lc_Space_TEXT),--ParticipantState_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 131), 15))), @Lc_Space_TEXT),--ParticipantZip_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 146), 1))), @Lc_UnNormalized_CODE),--EmpNormalization_CODE
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 147), 50))), @Lc_Space_TEXT),--EmployerLine1_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 197), 50))), @Lc_Space_TEXT),--EmployerLine2_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 247), 28))), @Lc_Space_TEXT),--EmployerCity_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 275), 2))), @Lc_Space_TEXT),--EmployerState_ADDR
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_NormalizationStartPos_NUMB + 277), 15))), @Lc_Space_TEXT),--EmployerZip_ADDR
                  @Ld_Run_DATE --FileLoad_DATE
         );

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LPBLK_Y1 TABLE';

           RAISERROR(50001,16,1);
          END;

         SET @Ln_LoopPos_NUMB = @Li_PartBlkLength_NUMB * @Li_Loop_NUMB;
         SET @Ln_NormalizationStartPos_NUMB = @Ln_NormalizationStartPos_NUMB + 292;
         SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
        END;

       IF @Li_OrderBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_OrderBlkLength_NUMB * @Li_OrderBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + (@Li_OrderBlkLength_NUMB * @Li_OrderBlk_QNTY);
        END;

       SET @Li_Tbsn_NUMB = @Li_Zero_NUMB;
       SET @Ls_Sql_TEXT = 'LOADING DATA TO LOBLK_Y1 ';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;
       SET @Li_Loop_NUMB = 1;

       -- Insert all the Order details from input file to the Order block table
       WHILE @Li_Loop_NUMB <= @Li_OrderBlk_QNTY
        BEGIN
         SET @Li_Tbsn_NUMB = @Li_Tbsn_NUMB + 1;
         SET @Ls_Sql_TEXT = 'LOADING DATA TO LOBLK_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', BlockSeq_NUMB = ' + ISNULL(CAST(@Li_Tbsn_NUMB AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

         INSERT LOBLK_Y1
                (TransHeader_IDNO,
                 Transaction_DATE,
                 IVDOutOfStateFips_CODE,
                 BlockSeq_NUMB,
                 StFipsOrder_CODE,
                 CntyFipsOrder_CODE,
                 SubFipsOrder_CODE,
                 Order_IDNO,
                 FilingOrder_DATE,
                 TypeOrder_CODE,
                 DebtType_CODE,
                 OrderFreq_CODE,
                 OrderFreq_AMNT,
                 OrderEffective_DATE,
                 OrderEnd_DATE,
                 OrderCancel_DATE,
                 FreqOrderArrears_CODE,
                 FreqOrderArrears_AMNT,
                 OrderArrearsTotal_AMNT,
                 ArrearsAfdcFrom_DATE,
                 ArrearsAfdcThru_DATE,
                 ArrearsAfdc_AMNT,
                 ArrearsNonAfdcFrom_DATE,
                 ArrearsNonAfdcThru_DATE,
                 ArrearsNonAfdc_AMNT,
                 FosterCareFrom_DATE,
                 FosterCareThru_DATE,
                 FosterCare_AMNT,
                 MedicalFrom_DATE,
                 MedicalThru_DATE,
                 Medical_AMNT,
                 MedicalOrdered_INDC,
                 TribunalCaseNo_TEXT,
                 OfLastPayment_DATE,
                 ControllingOrderFlag_CODE,
                 NewOrderFlag_INDC,
                 File_ID,
                 Process_INDC,
                 FileLoad_DATE)
         VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                  @Lc_TransactionDate_TEXT,--Transaction_DATE
                  @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                  @Li_Tbsn_NUMB,--BlockSeq_NUMB
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 2))),--StFipsOrder_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 3), 3))),--CntyFipsOrder_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 6), 2))),--SubFipsOrder_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 8), 17))),--Order_IDNO
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 25), 8))),--FilingOrder_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 33), 1))),--TypeOrder_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 34), 2))),--DebtType_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 36), 1))),--OrderFreq_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 37), 12))),--OrderFreq_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 49), 8))),--OrderEffective_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 57), 8))),--OrderEnd_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 65), 8))),--OrderCancel_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 73), 1))),--FreqOrderArrears_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 74), 12))),--FreqOrderArrears_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 86), 12))),--OrderArrearsTotal_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 98), 8))),--ArrearsAfdcFrom_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 106), 8))),--ArrearsAfdcThru_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 114), 12))),--ArrearsAfdc_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 126), 8))),--ArrearsNonAfdcFrom_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 134), 8))),--ArrearsNonAfdcThru_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 142), 12))),--ArrearsNonAfdc_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 154), 8))),--FosterCareFrom_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 162), 8))),--FosterCareThru_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 170), 12))),--FosterCare_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 182), 8))),--MedicalFrom_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 190), 8))),--MedicalThru_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 198), 12))),--Medical_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 210), 1))),--MedicalOrdered_INDC
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 211), 17))),--TribunalCaseNo_TEXT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 228), 8))),--OfLastPayment_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 236), 1))),--ControllingOrderFlag_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 237), 1))),--NewOrderFlag_INDC
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 238), 17))),--File_ID
                  @Lc_No_INDC,--Process_INDC
                  @Ld_Run_DATE --FileLoad_DATE
         );

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LOBLK_Y1 TABLE';

           RAISERROR(50001,16,1);
          END;

         SET @Ln_LoopPos_NUMB = @Li_OrderBlkLength_NUMB * @Li_Loop_NUMB;
         SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
        END;

       IF @Li_CollBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_CollBlkLength_NUMB * @Li_CollBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + (@Li_CollBlkLength_NUMB * @Li_CollBlk_QNTY);
        END;

       SET @Li_Tbsn_NUMB = @Li_Zero_NUMB;
       SET @Ls_Sql_TEXT = 'LOADING DATA TO LCBLK_Y1 ';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;
       SET @Li_Loop_NUMB = 1;

       -- Insert all the Collection details from input file to the Collection block table
       WHILE @Li_Loop_NUMB <= @Li_CollBlk_QNTY
        BEGIN
         SET @Li_Tbsn_NUMB = @Li_Tbsn_NUMB + 1;
         SET @Ls_Sql_TEXT = 'LOADING DATA TO LCBLK_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', BlockSeq_NUMB = ' + ISNULL(CAST(@Li_Tbsn_NUMB AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

         INSERT LCBLK_Y1
                (TransHeader_IDNO,
                 Transaction_DATE,
                 IVDOutOfStateFips_CODE,
                 BlockSeq_NUMB,
                 Collection_DATE,
                 Posting_DATE,
                 Payment_AMNT,
                 PaymentSource_CODE,
                 PaymentMethod_CODE,
                 Rdfi_ID,
                 RdfiAcctNo_TEXT,
                 Process_INDC,
                 FileLoad_DATE)
         VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                  @Lc_TransactionDate_TEXT,--Transaction_DATE
                  @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                  @Li_Tbsn_NUMB,--BlockSeq_NUMB
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 8))),--Collection_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 9), 8))),--Posting_DATE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 17), 12))),--Payment_AMNT
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 29), 1))),--PaymentSource_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 30), 1))),--PaymentMethod_CODE
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 31), 20))),--Rdfi_ID
                  LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 51), 20))),--RdfiAcctNo_TEXT
                  @Lc_No_INDC,--Process_INDC
                  @Ld_Run_DATE --FileLoad_DATE
         );

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LCBLK_Y1 TABLE';

           RAISERROR(50001,16,1);
          END;

         SET @Ln_LoopPos_NUMB = @Li_CollBlkLength_NUMB * @Li_Loop_NUMB;
         SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
        END;

       IF @Li_InfoBlk_QNTY > @Li_Zero_NUMB
        BEGIN
         SET @Ls_BufferTxt_TEXT = SUBSTRING(@Ls_CnLoadCur_LineData_TEXT, (@Ln_StartPos_NUMB + 1), (@Li_InfoBlkLength_NUMB * @Li_InfoBlk_QNTY));
         SET @Ln_StartPos_NUMB = @Ln_StartPos_NUMB + (@Li_InfoBlkLength_NUMB * @Li_InfoBlk_QNTY);
        END;

       SET @Ls_Sql_TEXT = 'LOADING DATA TO LIBLK_Y1';
       SET @Ln_LoopPos_NUMB = @Li_Zero_NUMB;
       SET @Li_Loop_NUMB = 1;

       -- Insert all the Information from input file to the Information block table
       WHILE @Li_Loop_NUMB <= @Li_InfoBlk_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'LOADING DATA TO LIBLK_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(@Lc_TransactionDate_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FipsOthState_CODE, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

         INSERT LIBLK_Y1
                (TransHeader_IDNO,
                 Transaction_DATE,
                 IVDOutOfStateFips_CODE,
                 StatusChange_CODE,
                 CaseNew_ID,
                 InfoLine1_TEXT,
                 InfoLine2_TEXT,
                 InfoLine3_TEXT,
                 InfoLine4_TEXT,
                 InfoLine5_TEXT,
                 Process_INDC,
                 FileLoad_DATE)
         VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                  @Lc_TransactionDate_TEXT,--Transaction_DATE
                  @Lc_FipsOthState_CODE,--IVDOutOfStateFips_CODE
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 1), 1))), ' '),--StatusChange_CODE
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 2), 15))), ' '),--CaseNew_ID
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 17), 80))), ' '),--InfoLine1_TEXT
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 97), 80))), ' '),--InfoLine2_TEXT
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 177), 80))), ' '),--InfoLine3_TEXT
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 257), 80))), ' '),--InfoLine4_TEXT
                  ISNULL(LTRIM(RTRIM(SUBSTRING(@Ls_BufferTxt_TEXT, (@Ln_LoopPos_NUMB + 337), 80))), ' '),--InfoLine5_TEXT
                  @Lc_No_INDC,--Process_INDC
                  @Ld_Run_DATE --FileLoad_DATE
         );

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'RECORDS NOT INSERTED INTO LIBLK_Y1 TABLE';

           RAISERROR(50001,16,1);
          END;

         SET @Ln_LoopPos_NUMB = @Li_InfoBlkLength_NUMB * @Li_Loop_NUMB;
         SET @Li_Loop_NUMB = @Li_Loop_NUMB + 1;
        END;
      END;

     FETCH NEXT FROM CnLoad_CUR INTO @Ls_CnLoadCur_LineData_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = 'E',
      @An_Line_NUMB                = 0,
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

   IF CURSOR_STATUS('LOCAL', 'CnLoad_CUR') IN (0, 1)
    BEGIN
     CLOSE CnLoad_CUR;

     DEALLOCATE CnLoad_CUR;
    END;

   -- Drop  temporary table after successful process 
   DROP TABLE #LoadCsenet_P1;

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'UPDATE PARM FAILED';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Success_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Success_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchWorker_IDNO, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_Rec_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Success_TEXT,
    @As_ListKey_TEXT              = @Lc_Success_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchWorker_IDNO,
    @An_ProcessedRecordCount_QNTY = @Ln_Rec_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION LOAD_CSENET;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LOAD_CSENET;
    END;

   IF CURSOR_STATUS('LOCAL', 'CnLoad_CUR') IN (0, 1)
    BEGIN
     CLOSE CnLoad_CUR;

     DEALLOCATE CnLoad_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Ls_DescriptionError_TEXT = ''
        OR @Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Li_Error_NUMB,
      @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END;

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
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchWorker_IDNO,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
