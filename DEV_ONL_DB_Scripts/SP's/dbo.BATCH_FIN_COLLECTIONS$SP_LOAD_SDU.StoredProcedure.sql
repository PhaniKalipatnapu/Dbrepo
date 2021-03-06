/****** Object:  StoredProcedure [dbo].[BATCH_FIN_COLLECTIONS$SP_LOAD_SDU]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_COLLECTIONS$SP_LOAD_SDU
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_LOAD_SDU reads the data received from SDU file
					  and loads into table LCSDU_Y1 for further processing. IF the counts and amounts in the 
					  header/trailer record types do not match with the counts and Amount totals of the detail record types,
					  an error message will be written into Batch Status_CODE Log (BSTL screen/BSTL table) and the file
					  processing will be terminated.
Frequency			: 'DAILY'
Developed On		: 12/05/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_COLLECTIONS$SP_LOAD_SDU]
AS
 BEGIN
  SET NOCOUNT ON;
 
  DECLARE  @Lc_StatusFailed_CODE           CHAR(1) = 'F',
           @Lc_ProcessN_INDC               CHAR(1) = 'N',
           @Lc_ProcessY_INDC               CHAR(1) = 'Y',
           @Lc_StatusA_CODE                CHAR(1) = 'A',
           @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
           @Lc_Space_TEXT                  CHAR(1) = ' ',
           @Lc_Zero_TEXT				   CHAR(1) = '0',
           @Lc_SourceReceipt_CODE          CHAR(2) = ' ',
           @Lc_SourceReceiptFF_CODE		   CHAR(2) = 'FF',	
		   @Lc_FileHeaderRecType01_CODE    CHAR(2) = '01',
		   @Lc_BatchHeaderRecType02_CODE   CHAR(2) = '02',
		   @Lc_BatchDetailRecType05_CODE   CHAR(2) = '05',
		   @Lc_BatchTrailerRecType08_CODE  CHAR(2) = '08',
		   @Lc_FileTrailerRecType10_CODE   CHAR(2) = '10',         
           @Lc_TypeRemittance_CODE         CHAR(3) = ' ',
           @Lc_TypeRemittanceEft_CODE      CHAR(3) = 'EFT',
           @Lc_TypeRemittanceCrd_CODE      CHAR(3) = 'CRD',
           @Lc_TypeRemittanceChk_CODE      CHAR(3) = 'CHK',
           @Lc_TypeRemittanceTrs_CODE      CHAR(3) = 'TRS',
           @Lc_TypeRemittanceCtf_CODE      CHAR(3) = 'CTF',
           @Lc_TypeRemittanceMno_CODE      CHAR(3) = 'MNO',
           @Lc_TypeRemittanceCsh_CODE      CHAR(3) = 'CSH',
           @Lc_TypeRemittanceXls_CODE      CHAR(3) = 'XLS',           
           @Lc_BatchSeqNumbDefault000_TEXT CHAR(3) = '000',
		   @Lc_BatchItemNumbDefault001_TEXT CHAR(3) = '001',
		   @Lc_BatchNumbDefault0000_TEXT   CHAR(4) = '0000',
		   @Lc_SduColPymyMethodAch_TEXT	   CHAR(5) = 'ACH',
		   @Lc_SduColPymyMethodWeb_TEXT	   CHAR(5) = 'WEB',
		   @Lc_SduColPymyMethodPchk_TEXT   CHAR(5) = 'PCHK',
		   @Lc_SduColPymyMethodTchk_TEXT   CHAR(5) = 'TCHK',
		   @Lc_SduColPymyMethodCchk_TEXT   CHAR(5) = 'CCHK',
		   @Lc_SduColPymyMethodSchk_TEXT   CHAR(5) = 'SCHK',
		   @Lc_SduColPymyMethodBchk_TEXT   CHAR(5) = 'BCHK',
		   @Lc_SduColPymyMethodMo_TEXT	   CHAR(5) = 'MO',
		   @Lc_SduColPymyMethodCash_TEXT   CHAR(5) = 'CASH',
		   @Lc_SduColPymyMethodXls_TEXT	   CHAR(5) = 'XLS',
           @Lc_Job_ID                      CHAR(7) = 'DEB0190',
           @Lc_ReceiptFeeAmntDefault_TEXT  CHAR(15) = '000000000000.00',
           @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT           CHAR(30) = 'BATCH',
           @Ls_Process_NAME                VARCHAR(100) = 'BATCH_FIN_COLLECTIONS',           
           @Ls_Procedure_NAME              VARCHAR(100) = 'SP_LOAD_SDU',
           @Ls_SduDescriptionError00_TEXT  VARCHAR(200) = 'INSERT NOT SUCCESSFUL',
           @Ls_SduDescriptionError01_TEXT  VARCHAR(200) = 'RECORD ALREADY EXIST IN LCSDU_Y1 TABLE',
           @Ls_SduDescriptionError02_TEXT  VARCHAR(200) = 'PARM DATE PROBLEM',
           @Ls_SduDescriptionError03_TEXT  VARCHAR(200) = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARM_Y1 TABLE',
           @Ls_SduDescriptionError04_TEXT  VARCHAR(200) = 'FILE CREATE DATE IS NOT SAME AS THE RUN DATE',
           @Ls_SduDescriptionError05_TEXT  VARCHAR(200) = 'FILE HEADER RECORD NOT FOUND',
           @Ls_SduDescriptionError06_TEXT  VARCHAR(200) = 'FILE TRAILER RECORD NOT FOUND',
           @Ls_SduDescriptionError07_TEXT  VARCHAR(200) = 'NO OF BATCH HEADER RECORDS AND NO OF BATCH TRAILER RECORDS ARE NOT MATCHING',
           @Ls_SduDescriptionError08_TEXT  VARCHAR(200) = 'TOTAL NUMBER OF RECORDS IN THE FILE ARE NOT MATCHING WITH THE NUMBER OF DIFFERENT RECORD TYPES IN THE FILE',
           @Ls_SduDescriptionError09_TEXT  VARCHAR(200) = 'TRAILER COUNT AND RECORD COUNT IN FILE ARE NOT MATCHING',
           @Ls_SduDescriptionError10_TEXT  VARCHAR(200) = 'BATCH DETAIL SUM AMOUNT MISMATCH WITH BATCH TRAILER SUM AMOUNT',
           @Ls_SduDescriptionError11_TEXT  VARCHAR(200) = 'BATCH TRAILER SUM AMOUNT MISMATCH WITH FILE TRAILER SUM AMOUNT',
           @Ls_SduDescriptionError12_TEXT  VARCHAR(200) = 'RECORD NOT FOUND';
           
  DECLARE  @Ln_BatchSeq_NUMB              NUMERIC(4),
           @Ln_Batch_NUMB                 NUMERIC(4),
           @Ln_CommitFreqParm_QNTY        NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
           @Ln_FileTotalRec_QNTY          NUMERIC(5),
           @Ln_FileHeaderRec_QNTY         NUMERIC(5),
           @Ln_FileTrailerRec_QNTY        NUMERIC(5),
           @Ln_FileBatchHeaderRec_QNTY    NUMERIC(5),
           @Ln_FileBatchTrailerRec_QNTY   NUMERIC(5),
           @Ln_FileBatchDetailRec_QNTY    NUMERIC(5),
           @Ln_Rec_NUMB                   NUMERIC(5),
           @Ln_TrailerRec_QNTY            NUMERIC(5),
           @Ln_ProcessedRecordCount_QNTY  NUMERIC(6) = 0,
           @Ln_RecExists_QNTY             NUMERIC(10) = 0,
           @Ln_Error_NUMB                 NUMERIC(11),
           @Ln_ErrorLine_NUMB             NUMERIC(11),
           @Ln_Batch_ID                   NUMERIC(12) = 0,
           @Ln_BatchDetailSum_AMNT        NUMERIC(13,2) = 0,
           @Ln_BatchTrailer_AMNT          NUMERIC(13,2) = 0,
           @Ln_FileTrailer_AMNT           NUMERIC(13,2) = 0,
           @Ln_BatchTrailerSum_AMNT       NUMERIC(13,2) = 0,
           @Li_Rowcount_QNTY              SMALLINT,
           @Li_FetchStatus_QNTY           SMALLINT,
           @Lc_Msg_CODE                   CHAR(1),
           @Lc_Batch_DATE                 CHAR(8),
           @Ls_File_NAME                  VARCHAR(50),
           @Ls_Sql_TEXT                   VARCHAR(100) = '',
           @Ls_FileSource_TEXT            VARCHAR(130),
           @Ls_SqlStatement_TEXT          VARCHAR(200) = '',
           @Ls_CursorLocation_TEXT        VARCHAR(200),
           @Ls_FileLocation_TEXT          VARCHAR(200),
           @Ls_SqlData_TEXT               VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT          VARCHAR(4000),
           @Ls_DescriptionError_TEXT      VARCHAR(4000),
           @Ld_Run_DATE                   DATE,
           @Ld_LastRun_DATE               DATE,
           @Ld_FileCreate_DATE			  DATE,
           @Ld_Start_DATE                 DATETIME2;

  DECLARE  @Ln_LoadSduCur_Seq_IDNO        NUMERIC(19),
           @Ls_LoadSduCur_Record_TEXT     VARCHAR(700);

  BEGIN TRY
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   BEGIN TRANSACTION LoadSduTran;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError02_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME)) + '';

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError03_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Lc_Batch_DATE = CONVERT (VARCHAR, @Ld_Run_DATE, 112);
   SET @Ls_SqlStatement_TEXT = 'BULK INSERT ULSDU_V1 FROM  ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_Sql_TEXT = 'BULK INSERT ULSDU_V1';
   SET @Ls_Sqldata_TEXT = 'BULK INSERT = ' + @Ls_SqlStatement_TEXT;

   EXECUTE (@Ls_SqlStatement_TEXT);

   -- File validations 
   SET @Ls_Sql_TEXT = 'Validation 1 - File Create Date, Run Date Match-1';
   SET @Ls_SqlData_TEXT ='';
   SELECT @Ls_Sqldata_TEXT = 'FileCreate_DATE = ' + SUBSTRING(Record_TEXT, 3, 10)
     FROM LTSDU_Y1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_FileHeaderRecType01_CODE;
    
   SET @Ls_Sql_TEXT = 'Validation 1 - File Create Date, Run Date Match-2';
   SET @Ls_SqlData_TEXT = 'SqlData_TEXT' + @Ls_Sqldata_TEXT;
   SELECT @Ld_FileCreate_DATE = SUBSTRING(Record_TEXT, 3, 10)
     FROM LTSDU_Y1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_FileHeaderRecType01_CODE;

   SET @Ls_Sql_TEXT = 'Validation 1 - File Create Date, Run Date Match-3';
   SET @Ls_Sqldata_TEXT = 'FileCreate_DATE = ' + CAST(@Ld_FileCreate_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF @Ld_FileCreate_DATE <> @Ld_Run_DATE
    BEGIN
     -- 'FILE CREATE DATE IS NOT SAME AS THE RUN DATE'
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError04_TEXT;

     RAISERROR (50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'Total Record Quantity';
   SET @Ls_SqlData_TEXT = '';
   SELECT @Ln_FileTotalRec_QNTY = COUNT(1)
     FROM LTSDU_Y1 a;
   
   SET @Ls_Sql_TEXT = 'File Header Record Quantity';
   SET @Ls_SqlData_TEXT = '';
   SELECT @Ln_FileHeaderRec_QNTY = COUNT(1)
     FROM LTSDU_Y1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_FileHeaderRecType01_CODE;
   
   SET @Ls_Sql_TEXT = 'File Trailer Record Quantity';
   SET @Ls_SqlData_TEXT = '';	
   SELECT @Ln_FileTrailerRec_QNTY = COUNT(1)
     FROM LTSDU_Y1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_FileTrailerRecType10_CODE;
    
   SET @Ls_Sql_TEXT = 'File Batch Header Record Quantity';
   SET @Ls_SqlData_TEXT = ''; 
   SELECT @Ln_FileBatchHeaderRec_QNTY = COUNT(1)
     FROM LTSDU_Y1 a 
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchHeaderRecType02_CODE;
   
   SET @Ls_Sql_TEXT = 'File Batch Trailer Record Quantity';
   SET @Ls_SqlData_TEXT = '';	
   SELECT @Ln_FileBatchTrailerRec_QNTY = COUNT(1)
     FROM LTSDU_Y1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchTrailerRecType08_CODE;
   
   SET @Ls_Sql_TEXT = 'File Batch Detail Record Quantity';
   SET @Ls_SqlData_TEXT = '';
   SELECT @Ln_FileBatchDetailRec_QNTY = COUNT(1)
     FROM LTSDU_Y1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchDetailRecType05_CODE;

   SET @Ls_Sql_TEXT = 'Validation 1.1 - File Record Not Found';
   SET @Ls_Sqldata_TEXT = 'File Header Record Count= ' + CAST(@Ln_FileHeaderRec_QNTY AS VARCHAR) + ', File Trailer Record Count = ' + CAST(@Ln_FileTrailerRec_QNTY AS VARCHAR) + ', Batch Detail Record Count = ' + CAST(@Ln_FileBatchDetailRec_QNTY AS VARCHAR);
   IF @Ln_FileHeaderRec_QNTY = 0 AND @Ln_FileTrailerRec_QNTY = 0 AND @Ln_FileBatchDetailRec_QNTY = 0
    BEGIN
     -- RECORD NOT FOUND
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError12_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'Validation 2 - File Header Record Count';
   SET @Ls_Sqldata_TEXT = 'File Header Record Count = ' + CAST(@Ln_FileHeaderRec_QNTY AS VARCHAR);
   IF @Ln_FileHeaderRec_QNTY = 0
    BEGIN
     -- FILE HEADER RECORD NOT FOUND
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError05_TEXT;

     RAISERROR (50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'Validation 3 - File Trailer Record Count';
   SET @Ls_Sqldata_TEXT = 'File Trailer Record Count = ' + CAST(@Ln_FileTrailerRec_QNTY AS VARCHAR);
   IF @Ln_FileTrailerRec_QNTY = 0
    BEGIN
     -- 'FILE TRAILER RECORD NOT FOUND'
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError06_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'Validation 4 - Batch Header Count and Batch Trailer Count Match';
   SET @Ls_Sqldata_TEXT = 'Batch Header Record Qnty = ' + CAST(@Ln_FileBatchHeaderRec_QNTY AS VARCHAR) + ', Batch Trailer Record Qnty = ' + CAST(@Ln_FileBatchTrailerRec_QNTY AS VARCHAR);
   IF @Ln_FileBatchHeaderRec_QNTY <> @Ln_FileBatchTrailerRec_QNTY
    BEGIN
    -- 'NO OF BATCH HEADER RECORDS AND NO OF BATCH TRAILER RECORDS ARE NOT MATCHING'
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError07_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'Validation 5 - Total Records Count And File Total Records Count Match';
   SET @Ls_Sqldata_TEXT = 'FILE Total Records = ' + CAST(@Ln_FileTotalRec_QNTY AS VARCHAR) + ', File Header Records = ' + CAST(@Ln_FileHeaderRec_QNTY AS VARCHAR) + ', File Trailer Records = ' + CAST(@Ln_FileTrailerRec_QNTY AS VARCHAR) + ', Batch Header Records = ' + CAST(@Ln_FileBatchHeaderRec_QNTY AS VARCHAR) + ', Batch Trailer Records = ' + CAST(@Ln_FileBatchTrailerRec_QNTY AS VARCHAR) + ', Batch Detail Records = ' + CAST(@Ln_FileBatchDetailRec_QNTY AS VARCHAR);

   IF (@Ln_FileTotalRec_QNTY <> (@Ln_FileHeaderRec_QNTY + @Ln_FileTrailerRec_QNTY + @Ln_FileBatchHeaderRec_QNTY + @Ln_FileBatchTrailerRec_QNTY + @Ln_FileBatchDetailRec_QNTY))
    BEGIN
     --'TOTAL NUMBER OF RECORDS IN THE FILE ARE NOT MATCHING WITH THE NUMBER OF DIFFERENT RECORD TYPES IN THE FILE'
     SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError08_TEXT;

     RAISERROR (50001,16,1);
    END

   BEGIN
    SET @Ls_Sql_TEXT = 'Validation 6 - File Trailer Record Count And File Total Records Count Match';
	SET @Ls_Sqldata_TEXT = 'FileTrailerRecType_CODE = ' + @Lc_FileTrailerRecType10_CODE;
    SELECT @Ln_TrailerRec_QNTY = (SUBSTRING(Record_TEXT, 3, 7))
      FROM LTSDU_Y1 a
     WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_FileTrailerRecType10_CODE;
	
	SET @Ls_Sql_TEXT = 'Validation 6 - File Record Count And File Total Records Count Match';
	SET @Ls_Sqldata_TEXT = 'FileTrailerRecType_CODE = ' + @Lc_FileTrailerRecType10_CODE;
    SELECT @Ln_Rec_NUMB = COUNT(1)
      FROM LTSDU_Y1 a
     WHERE SUBSTRING(Record_TEXT, 1, 2) <> @Lc_FileTrailerRecType10_CODE;

	SET @Ls_Sql_TEXT = 'Validation 6 - File Trailer Record Count And File Total Records Count Match';
	SET @Ls_Sqldata_TEXT = 'File Trailer Count = ' + CAST(@Ln_TrailerRec_QNTY AS VARCHAR) + ', File Record Count = ' + CAST(@Ln_Rec_NUMB AS VARCHAR);
    IF @Ln_Rec_NUMB <> @Ln_TrailerRec_QNTY
     BEGIN
      -- 'TRAILER COUNT AND RECORD COUNT IN FILE ARE NOT MATCHING'
      SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError09_TEXT;

      RAISERROR (50001,16,1);
     END
   END

   BEGIN
    SET @Ls_Sql_TEXT = 'Validation 7 - Batch Detail Sum Amount and Batch Trailer Sum Amount Match';
	SET @Ls_SqlData_TEXT = '';
    SELECT @Ln_Batch_ID = A.Batch_Id,
           @Ln_BatchDetailSum_AMNT = a.Batch_Detail_AMNT,
           @Ln_BatchTrailer_AMNT = b.Batch_Trailer_AMNT
      FROM (SELECT SUBSTRING(Record_TEXT, 3, 12) Batch_Id,
                   SUM(CAST(SUBSTRING(Record_TEXT, 129, 15) AS NUMERIC(11, 2))) AS Batch_Detail_AMNT
              FROM LTSDU_Y1 A
             WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchDetailRecType05_CODE
             GROUP BY SUBSTRING(Record_TEXT, 3, 12)) a,
           (SELECT SUBSTRING(Record_TEXT, 23, 12) Batch_Id,
                   CAST(SUBSTRING(Record_TEXT, 8, 15)AS NUMERIC(11, 2)) Batch_Trailer_AMNT
              FROM LTSDU_Y1 A
             WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchTrailerRecType08_CODE) b
     WHERE a.Batch_Id = b.Batch_Id
       AND a.Batch_Detail_AMNT <> b.Batch_Trailer_AMNT;

    SET @Ls_Sql_TEXT = 'Validation 7 - Batch Detail Sum Amount and Batch Trailer Sum Amount Match'; 
    SET @Ls_Sqldata_TEXT = 'Batch_ID = ' + CAST(@Ln_Batch_ID AS VARCHAR) + ', Batch Detail Sum Amt = ' + CAST(@Ln_BatchDetailSum_AMNT AS VARCHAR) + ', Batch Trailer Amt = ' + CAST(@Ln_BatchTrailer_AMNT AS VARCHAR);
    IF @Ln_BatchDetailSum_AMNT <> @Ln_BatchTrailer_AMNT
     BEGIN
      -- 'BATCH DETAIL SUM AMOUNT MISMATCH WITH BATCH TRAILER SUM AMOUNT'
      SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError10_TEXT;
      RAISERROR (50001,16,1);
     END
   END

    SET @Ls_Sql_TEXT = 'Validation 8 - Batch Trailer Sum Amount and File Trailer Sum Amount Match';
	SET @Ls_SqlData_TEXT = '';
    SELECT @Ln_BatchTrailerSum_AMNT = SUM(CAST(SUBSTRING (Record_TEXT, 8, 15) AS NUMERIC(11, 2)))
      FROM LTSDU_Y1 a
     WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchTrailerRecType08_CODE;
	
	SET @Ls_Sql_TEXT = 'Validation 8 - Batch Trailer Amount and File Trailer Sum Amount Match';
	SET @Ls_SqlData_TEXT = '';
    SELECT @Ln_FileTrailer_AMNT = SUBSTRING(Record_TEXT, 10, 15)
      FROM LTSDU_Y1 a
     WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_FileTrailerRecType10_CODE;

    SET @Ls_Sql_TEXT = '@Ln_FileTrailer_AMNT <> @Ln_BatchTrailerSum_AMNT';
    SET @Ls_Sqldata_TEXT = 'File Trailer Amount = ' + CAST(@Ln_FileTrailer_AMNT AS VARCHAR) + ', Batch Trailer Sum Amount = ' + CAST(@Ln_BatchTrailerSum_AMNT  AS VARCHAR);
    IF @Ln_FileTrailer_AMNT <> @Ln_BatchTrailerSum_AMNT
     BEGIN
      -- 'BATCH TRAILER SUM AMOUNT MISMATCH WITH FILE TRAILER SUM AMOUNT'
      SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError11_TEXT;

      RAISERROR (50001,16,1);
     END

   -- Validation 9 Check for the first 25 detailed records in the file are same in the table 
   -- If they are same, the file is a duplicate of the previous day's processed file, raise an exception and stop the process
  DECLARE LoadSdu_CUR INSENSITIVE CURSOR FOR
	SELECT Seq_IDNO,
              Record_TEXT
         FROM LTSDU_Y1 a
        WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchDetailRecType05_CODE
        ORDER BY Seq_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN LoadSdu_CUR-1';
   SET @Ls_SqlData_TEXT = '';		
   OPEN LoadSdu_CUR;

   SET @Ln_Rec_NUMB = 0;
   SET @Ls_Sql_TEXT = 'FETCH LoadSdu_CUR-1';
   SET @Ls_Sqldata_TEXT = '';
         
   FETCH NEXT FROM LoadSdu_CUR INTO @Ln_LoadSduCur_Seq_IDNO, @Ls_LoadSduCur_Record_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-1';
   SET @Ls_Sqldata_TEXT = '';
   -- Load Sdu Loop started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Rec_NUMB = @Ln_Rec_NUMB + 1;
     SET @Ls_CursorLocation_TEXT = 'SDU - CURSOR COUNT - ' + CAST(@Ln_Rec_NUMB AS VARCHAR);

     IF @Ln_Rec_NUMB <= 25
      BEGIN
       SET @Ls_Sql_TEXT = 'EXISTANCE CHECK IN LCSDU_Y1 USING THE KEY VALUES';
       SET @Ls_Sqldata_TEXT = 'Batch_ID = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 3, 12) + ', Rapid_IDNO = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 15, 7) + ', RapidEnvelope_NUMB = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 22, 10) + ', RapidReceipt_NUMB = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 32, 10) + ', PayorMCI_IDNO = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 42, 10) + ', PayorSsn_NUMB = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 52, 9) + ', Receipt_AMNT = ' + SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 129, 15);

       SELECT @Ln_RecExists_QNTY = COUNT(1)
         FROM LCSDU_Y1 a
        WHERE Batch_ID = SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 3, 12)
          AND Rapid_IDNO = SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 15, 7)
          AND RapidEnvelope_NUMB = SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 22, 10)
          AND RapidReceipt_NUMB = SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 32, 10)
          AND PayorMCI_IDNO = SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 42, 10)
          AND PayorSsn_NUMB = SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 52, 9)
          AND Receipt_AMNT = CAST(SUBSTRING (@Ls_LoadSduCur_Record_TEXT, 129, 15) AS NUMERIC (11, 2));

       IF @Ln_RecExists_QNTY > 0
        BEGIN
         --'RECORD ALREADY EXIST IN LCSDU_Y1 TABLE'
         SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError01_TEXT;
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH LoadSdu_CUR-2';
     SET @Ls_Sqldata_TEXT = '';
     FETCH NEXT FROM LoadSdu_CUR INTO @Ln_LoadSduCur_Seq_IDNO, @Ls_LoadSduCur_Record_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LoadSdu_CUR;

   DEALLOCATE LoadSdu_CUR;

   -- Delete the processed records from the LCSDU_Y1 table 
   SET @Ls_Sql_TEXT = 'DELETE LCSDU_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'');
   DELETE FROM LCSDU_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   -- INSERT DATA 
   SET @Ln_Batch_NUMB = 0001;
   SET @Ln_BatchSeq_NUMB = 0;
   
   DECLARE LoadSdu_CUR INSENSITIVE CURSOR FOR
   SELECT Seq_IDNO,
              Record_TEXT
         FROM LTSDU_Y1 a
        WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_BatchDetailRecType05_CODE
        ORDER BY Seq_IDNO;
                
   SET @Ls_Sql_TEXT = 'OPEN LoadSdu_CUR-2';
   SET @Ls_Sqldata_TEXT = '';
   OPEN LoadSdu_CUR;

   SET @Ln_Rec_NUMB = 0;
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ls_Sql_TEXT = 'FETCH LoadSdu_CUR-3';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM LoadSdu_CUR INTO @Ln_LoadSduCur_Seq_IDNO, @Ls_LoadSduCur_Record_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE-2';
   SET @Ls_Sqldata_TEXT = '';
   -- Load sdu cursor started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Rec_NUMB = @Ln_Rec_NUMB + 1;
     SET @Ls_CursorLocation_TEXT = 'SDU - CURSOR COUNT - ' + CAST(@Ln_Rec_NUMB AS VARCHAR);
     SET @Ln_BatchSeq_NUMB = @Ln_BatchSeq_NUMB + 1;

     -- If the batch sequence number is greater than 999, reset the sequence number to 1 
     -- and increment the batch number by 1 
     IF (@Ln_BatchSeq_NUMB > 999)
      BEGIN
       SET @Ln_BatchSeq_NUMB = 1;
       SET @Ln_Batch_NUMB = @Ln_Batch_NUMB + 1;
      END

	 SET @Lc_SourceReceipt_CODE = SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 164, 5);

	 -- TypeRemittance_CODE derivation 
     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodAch_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceEft_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodWeb_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceCrd_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodPchk_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceChk_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodTchk_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceTrs_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodCchk_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceCtf_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodSchk_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceChk_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodBchk_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceChk_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodMo_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceMno_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodCash_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceCsh_CODE;
      END

     IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_SduColPymyMethodXls_TEXT)
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceXls_CODE;
      END
      
      IF (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) = @Lc_Space_TEXT
         OR (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5) NOT IN (@Lc_SduColPymyMethodAch_TEXT, @Lc_SduColPymyMethodWeb_TEXT, @Lc_SduColPymyMethodPchk_TEXT, @Lc_SduColPymyMethodTchk_TEXT,
                                                                    @Lc_SduColPymyMethodCchk_TEXT, @Lc_SduColPymyMethodSchk_TEXT, @Lc_SduColPymyMethodBchk_TEXT, @Lc_SduColPymyMethodMo_TEXT,
                                                                    @Lc_SduColPymyMethodCash_TEXT, @Lc_SduColPymyMethodXls_TEXT)))
      BEGIN
       SET @Lc_TypeRemittance_CODE = @Lc_TypeRemittanceChk_CODE;
      END

     SET @Ls_Sql_TEXT = 'INSERT INTO LCSDU_Y1 - 1';
	 
	 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + (ISNULL (@Lc_Batch_DATE, @Lc_Space_TEXT)) + ', Batch_NUMB = ' + (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4)) + ', Batch_NUMB = ' + (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4))  + ', BatchSeq_NUMB = ' + (RIGHT (@Lc_BatchSeqNumbDefault000_TEXT + CAST(@Ln_BatchSeq_NUMB AS VARCHAR), 3))  + ', BatchItem_NUMB = ' + @Lc_BatchItemNumbDefault001_TEXT + ', Batch_ID = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 3, 12), @Lc_Space_TEXT))  + ', Rapid_IDNO = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 15, 7), @Lc_Space_TEXT)) + ', RapidEnvelope_NUMB = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 22, 10), @Lc_Space_TEXT)) + ', RapidReceipt_NUMB = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 32, 10), @Lc_Space_TEXT)) + ', PayorMCI_IDNO = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 42, 10), @Lc_Space_TEXT)) + ', PayorSsn_NUMB = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 52, 9), @Lc_Space_TEXT)) + ', PayorLast_Name = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 61, 25), @Lc_Space_TEXT)) + ', PayorFirst_NAME = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 86, 20), @Lc_Space_TEXT)) + ', PayorMiddle_NAME = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 106, 20), @Lc_Space_TEXT)) + ', PayorSuffix_NAME = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 126, 3), @Lc_Space_TEXT)) + ', Receipt_AMNT = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 129, 15), @Lc_Zero_TEXT)) + ', ReceiptFee_AMNT = ' +  @Lc_ReceiptFeeAmntDefault_TEXT + ', PaymentMethod_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5), @Lc_Space_TEXT)) + ', PaymentType_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 164, 5), @Lc_Space_TEXT)) + ', PaymentSourceSdu_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 169, 3), @Lc_Space_TEXT)) + ', Receipt_DATE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 172, 8), @Lc_Space_TEXT)) + ', Release_DATE = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 180, 8), @Lc_Space_TEXT)) + ', SuspendPayment_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 188, 1), @Lc_Space_TEXT)) + ', CheckNo_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 189, 18), @Lc_Space_TEXT)) + ', PaymentInstruction1_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 207, 76), @Lc_Space_TEXT)) + ', PaymentInstruction2_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 283, 76), @Lc_Space_TEXT)) + ', PaymentInstruction3_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 359, 76), @Lc_Space_TEXT)) + ', PaidBy_NAME = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 607, 50), @Lc_Space_TEXT)) + ', PaidBy_ID = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 657, 15), @Lc_Space_TEXT)) + ', FileLoad_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', SourceReceipt_CODE = ' + (ISNULL (@Lc_SourceReceipt_CODE, @Lc_Space_TEXT)) + ', TypeRemittance_CODE = ' + (ISNULL (@Lc_TypeRemittance_CODE, @Lc_Space_TEXT)) + ',  CollectionOrig_AMNT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 129, 15), @Lc_Space_TEXT)) + ',  CollectionFeeOrig_AMNT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15), @Lc_Space_TEXT));

     INSERT INTO LCSDU_Y1
                 (Batch_DATE,
                  Batch_NUMB,
                  BatchSeq_NUMB,
                  BatchItem_NUMB,
                  Batch_ID,
                  Rapid_IDNO,
                  RapidEnvelope_NUMB,
                  RapidReceipt_NUMB,
                  PayorMCI_IDNO,
                  PayorSsn_NUMB,
                  PayorLast_Name,
                  PayorFirst_NAME,
                  PayorMiddle_NAME,
                  PayorSuffix_NAME,
                  Receipt_AMNT,
                  ReceiptFee_AMNT,
                  PaymentMethod_CODE,
                  PaymentType_CODE,
                  PaymentSourceSdu_CODE,
                  Receipt_DATE,
                  Release_DATE,
                  SuspendPayment_CODE,
                  CheckNo_TEXT,
                  PaymentInstruction1_TEXT,
                  PaymentInstruction2_TEXT,
                  PaymentInstruction3_TEXT,
                  PaidBy_NAME,
                  PaidBy_ID,
                  FileLoad_DATE,
                  SourceReceipt_CODE,
                  TypeRemittance_CODE,
                  CollectionOrig_AMNT,
                  CollectionFeeOrig_AMNT,
                  Process_INDC)
          VALUES ( (ISNULL (@Lc_Batch_DATE, @Lc_Space_TEXT)), -- Batch_DATE
                   (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4)), -- Batch_NUMB
                   (RIGHT (@Lc_BatchSeqNumbDefault000_TEXT + CAST(@Ln_BatchSeq_NUMB AS VARCHAR), 3)), -- BatchSeq_NUMB
                   (@Lc_BatchItemNumbDefault001_TEXT), -- BatchItem_NUMB
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 3, 12), @Lc_Space_TEXT)), -- Batch_ID
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 15, 7), @Lc_Space_TEXT)), -- Rapid_IDNO
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 22, 10), @Lc_Space_TEXT)), -- RapidEnvelope_NUMB
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 32, 10), @Lc_Space_TEXT)), -- RapidReceipt_NUMB
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 42, 10), @Lc_Space_TEXT)), -- PayorMCI_IDNO
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 52, 9), @Lc_Space_TEXT)), -- PayorSsn_NUMB
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 61, 25), @Lc_Space_TEXT)),-- PayorLast_Name
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 86, 20), @Lc_Space_TEXT)),-- PayorFirst_NAME
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 106, 20), @Lc_Space_TEXT)),-- PayorMiddle_NAME
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 126, 3), @Lc_Space_TEXT)), -- PayorSuffix_NAME
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 129, 15), @Lc_Zero_TEXT)), -- Receipt_AMNT
                   (@Lc_ReceiptFeeAmntDefault_TEXT), -- ReceiptFee_AMNT
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5), @Lc_Space_TEXT)), -- PaymentMethod_CODE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 164, 5), @Lc_Space_TEXT)), -- PaymentType_CODE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 169, 3), @Lc_Space_TEXT)), -- PaymentSourceSdu_CODE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 172, 8), @Lc_Space_TEXT)), -- Receipt_DATE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 180, 8), @Lc_Space_TEXT)), -- Release_DATE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 188, 1), @Lc_Space_TEXT)), -- SuspendPayment_CODE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 189, 18), @Lc_Space_TEXT)), -- CheckNo_TEXT
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 207, 76), @Lc_Space_TEXT)), -- PaymentInstruction1_TEXT
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 283, 76), @Lc_Space_TEXT)), -- PaymentInstruction2_TEXT
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 359, 76), @Lc_Space_TEXT)), -- PaymentInstruction3_TEXT
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 607, 50), @Lc_Space_TEXT)), -- PaidBy_NAME
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 657, 15), @Lc_Space_TEXT)), -- PaidBy_ID
                   (@Ld_Run_DATE), -- FileLoad_DATE
                   (ISNULL (@Lc_SourceReceipt_CODE, @Lc_Space_TEXT)), -- SourceReceipt_CODE
                   (ISNULL (@Lc_TypeRemittance_CODE, @Lc_Space_TEXT)), -- TypeRemittance_CODE
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 129, 15), @Lc_Space_TEXT)), -- CollectionOrig_AMNT
                   (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15), @Lc_Space_TEXT)), -- CollectionFeeOrig_AMNT
                   (@Lc_ProcessN_INDC)); -- Process_INDC

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       -- INSERT NOT SUCCESSFUL
       SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError00_TEXT;
       RAISERROR (50001,16,1);
      END;

     -- If the fee Value_AMNT in the row is greater than zeros, insert another with fee Value_AMNT
     -- moved the collections Value_AMNT and the RCTH_Y1 source AS 'FF'
     IF SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15) <> @Lc_ReceiptFeeAmntDefault_TEXT
      BEGIN
       SET @Ln_BatchSeq_NUMB = @Ln_BatchSeq_NUMB + 1;

       IF (@Ln_BatchSeq_NUMB > 999)
        BEGIN
         SET @Ln_BatchSeq_NUMB = 1;
         SET @Ln_Batch_NUMB = @Ln_Batch_NUMB + 1;
        END
		
       SET @Lc_SourceReceipt_CODE = @Lc_SourceReceiptFF_CODE;
       SET @Ls_Sql_TEXT = 'INSERT INTO LCSDU_Y1 - 2';
       
	   SET @Ls_Sqldata_TEXT = 'Batch_ID = ' + (ISNULL (@Lc_Batch_DATE, @Lc_Space_TEXT)) + ', Batch_NUMB = ' + (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4)) + ', Batch_NUMB = ' + (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4))  + ', BatchSeq_NUMB = ' + (RIGHT (@Lc_BatchSeqNumbDefault000_TEXT + CAST(@Ln_BatchSeq_NUMB AS VARCHAR), 3))  + ', BatchItem_NUMB = ' + @Lc_BatchItemNumbDefault001_TEXT + ', Batch_ID = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 3, 12), @Lc_Space_TEXT))  + ', Rapid_IDNO = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 15, 7), @Lc_Space_TEXT)) + ', RapidEnvelope_NUMB = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 22, 10), @Lc_Space_TEXT)) + ', RapidReceipt_NUMB = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 32, 10), @Lc_Space_TEXT)) + ', PayorMCI_IDNO = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 42, 10), @Lc_Space_TEXT)) + ', PayorSsn_NUMB = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 52, 9), @Lc_Space_TEXT)) + ', PayorLast_Name = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 61, 25), @Lc_Space_TEXT)) + ', PayorFirst_NAME = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 86, 20), @Lc_Space_TEXT)) + ', PayorMiddle_NAME = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 106, 20), @Lc_Space_TEXT)) + ', PayorSuffix_NAME = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 126, 3), @Lc_Space_TEXT)) + ', Receipt_AMNT = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15), @Lc_Zero_TEXT)) + ', ReceiptFee_AMNT = ' +  @Lc_ReceiptFeeAmntDefault_TEXT + ', PaymentMethod_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5), @Lc_Space_TEXT)) + ', PaymentType_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 164, 5), @Lc_Space_TEXT)) + ', PaymentSourceSdu_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 169, 3), @Lc_Space_TEXT)) + ', Receipt_DATE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 172, 8), @Lc_Space_TEXT)) + ', Release_DATE = ' +  (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 180, 8), @Lc_Space_TEXT)) + ', SuspendPayment_CODE = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 188, 1), @Lc_Space_TEXT)) + ', CheckNo_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 189, 18), @Lc_Space_TEXT)) + ', PaymentInstruction1_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 207, 76), @Lc_Space_TEXT)) + ', PaymentInstruction2_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 283, 76), @Lc_Space_TEXT)) + ', PaymentInstruction3_TEXT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 359, 76), @Lc_Space_TEXT)) + ', PaidBy_NAME = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 607, 50), @Lc_Space_TEXT)) + ', PaidBy_ID = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 657, 15), @Lc_Space_TEXT)) + ', FileLoad_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', SourceReceipt_CODE = ' + (ISNULL (@Lc_SourceReceipt_CODE, @Lc_Space_TEXT)) + ', TypeRemittance_CODE = ' + (ISNULL (@Lc_TypeRemittance_CODE, @Lc_Space_TEXT)) + ',  CollectionOrig_AMNT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 129, 15), @Lc_Space_TEXT)) + ',  CollectionFeeOrig_AMNT = ' + (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15), @Lc_Space_TEXT)) + ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC,'');
	   
       INSERT INTO LCSDU_Y1
                   (Batch_DATE,
                    Batch_NUMB,
                    BatchSeq_NUMB,
                    BatchItem_NUMB,
                    Batch_ID,
                    Rapid_IDNO,
                    RapidEnvelope_NUMB,
                    RapidReceipt_NUMB,
                    PayorMCI_IDNO,
                    PayorSsn_NUMB,
                    PayorLast_Name,
                    PayorFirst_NAME,
                    PayorMiddle_NAME,
                    PayorSuffix_NAME,
                    Receipt_AMNT,
                    ReceiptFee_AMNT,
                    PaymentMethod_CODE,
                    PaymentType_CODE,
                    PaymentSourceSdu_CODE,
                    Receipt_DATE,
                    Release_DATE,
                    SuspendPayment_CODE,
                    CheckNo_TEXT,
                    PaymentInstruction1_TEXT,
                    PaymentInstruction2_TEXT,
                    PaymentInstruction3_TEXT,
                    PaidBy_NAME,
                    PaidBy_ID,
                    FileLoad_DATE,
                    SourceReceipt_CODE,
                    TypeRemittance_CODE,
                    CollectionOrig_AMNT,
                    CollectionFeeOrig_AMNT,
                    Process_INDC)
            VALUES ( (ISNULL (@Lc_Batch_DATE, @Lc_Space_TEXT)), -- Batch_DATE
                     (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4)), -- Batch_NUMB
                     (RIGHT (@Lc_BatchSeqNumbDefault000_TEXT + CAST(@Ln_BatchSeq_NUMB AS VARCHAR), 3)), -- BatchSeq_NUMB
                     (@Lc_BatchItemNumbDefault001_TEXT), -- BatchItem_NUMB
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 3, 12), @Lc_Space_TEXT)), -- Batch_ID
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 15, 7), @Lc_Space_TEXT)), -- Rapid_IDNO
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 22, 10), @Lc_Space_TEXT)), -- RapidEnvelope_NUMB
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 32, 10), @Lc_Space_TEXT)), -- RapidReceipt_NUMB
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 42, 10), @Lc_Space_TEXT)), -- PayorMCI_IDNO
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 52, 9), @Lc_Space_TEXT)), -- PayorSsn_NUMB
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 61, 25), @Lc_Space_TEXT)), -- PayorLast_Name
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 86, 20), @Lc_Space_TEXT)), -- PayorFirst_NAME
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 106, 20), @Lc_Space_TEXT)), -- PayorMiddle_NAME
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 126, 3), @Lc_Space_TEXT)), -- PayorSuffix_NAME
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15), @Lc_Zero_TEXT)), -- Receipt_AMNT
                     (@Lc_ReceiptFeeAmntDefault_TEXT), -- ReceiptFee_AMNT
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 159, 5), @Lc_Space_TEXT)), -- PaymentMethod_CODE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 164, 5), @Lc_Space_TEXT)), -- PaymentType_CODE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 169, 3), @Lc_Space_TEXT)), -- PaymentSourceSdu_CODE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 172, 8), @Lc_Space_TEXT)), -- Receipt_DATE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 180, 8), @Lc_Space_TEXT)), -- Release_DATE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 188, 1), @Lc_Space_TEXT)), -- SuspendPayment_CODE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 189, 18), @Lc_Space_TEXT)), -- CheckNo_TEXT
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 207, 76), @Lc_Space_TEXT)), -- PaymentInstruction1_TEXT
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 283, 76), @Lc_Space_TEXT)), -- PaymentInstruction2_TEXT
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 359, 76), @Lc_Space_TEXT)), -- PaymentInstruction3_TEXT
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 607, 50), @Lc_Space_TEXT)), -- PaidBy_NAME
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 657, 15), @Lc_Space_TEXT)), -- PaidBy_ID
                     (ISNULL (@Ld_Run_DATE, @Lc_Space_TEXT)), -- FileLoad_DATE
                     (ISNULL (@Lc_SourceReceipt_CODE, @Lc_Space_TEXT)), -- SourceReceipt_CODE
                     (ISNULL (@Lc_TypeRemittance_CODE, @Lc_Space_TEXT)), -- TypeRemittance_CODE
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 129, 15), @Lc_Space_TEXT)), -- CollectionOrig_AMNT
                     (ISNULL (SUBSTRING(@Ls_LoadSduCur_Record_TEXT, 144, 15), @Lc_Space_TEXT)), -- CollectionFeeOrig_AMNT
                     @Lc_ProcessN_INDC); -- Process_INDC

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         -- 'INSERT NOT SUCCESSFUL'
         SET @Ls_ErrorMessage_TEXT = @Ls_SduDescriptionError00_TEXT;
         RAISERROR (50001,16,1);
        END;
      END

     SET @Ls_Sql_TEXT = 'FETCH LoadSdu_CUR-4';
	 SET @Ls_Sqldata_TEXT = '';
     FETCH NEXT FROM LoadSdu_CUR INTO @Ln_LoadSduCur_Seq_IDNO, @Ls_LoadSduCur_Record_TEXT;
	 
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LoadSdu_CUR;

   DEALLOCATE LoadSdu_CUR;

   -- Delete the records from the LTSDU_Y1 table 
   SET @Ls_Sql_TEXT = 'DELETE LTSDU_Y1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM LTSDU_Y1;

   SET @Ls_Sql_TEXT = 'SELECT LCSDU_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM LCSDU_Y1 a;

   --Update the parameter table with the job run date AS the current system date
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

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION LoadSduTran;
   
  END TRY
  BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LoadSduTran;
    END

   IF CURSOR_STATUS ('LOCAL', 'LoadSdu_CUR') IN (0, 1)
    BEGIN
     CLOSE LoadSdu_CUR;

     DEALLOCATE LoadSdu_CUR;
    END

   DELETE FROM LTSDU_Y1;
   
   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusA_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;

GO
