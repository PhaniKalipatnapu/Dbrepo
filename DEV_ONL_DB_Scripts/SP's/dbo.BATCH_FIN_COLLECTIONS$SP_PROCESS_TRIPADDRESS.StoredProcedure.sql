/****** Object:  StoredProcedure [dbo].[BATCH_FIN_COLLECTIONS$SP_PROCESS_TRIPADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_COLLECTIONS$SP_PROCESS_TRIPADDRESS
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_PROCESS_TRIPADDRESS takes data (TRIP address) from the 
					  temporary load table (LCIRS_Y1) and update the TADR_Y1 table in DECSS.
					  TRIP - Tax Refund Interception Program
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
CREATE PROCEDURE [dbo].[BATCH_FIN_COLLECTIONS$SP_PROCESS_TRIPADDRESS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_NoSpace_TEXT           CHAR(1) = '',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_TypeErrorE_CODE        CHAR(1) = 'E',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ErrorE1424_CODE        CHAR(5) = 'E1424',
          @Lc_ErrorE0085_CODE		 CHAR(5) = 'E0085',
          @Lc_ErrorE0113_CODE		 CHAR(5) = 'E0113',
          @Lc_Job_ID				 CHAR(7) = 'DEB0541',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT      CHAR(30) = 'BATCH',
          @Ls_ParmDateProblem_TEXT   VARCHAR(100) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_COLLECTIONS',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_TRIPADDRESS';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
		  @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
          @Ln_CursorRecordCount_QNTY      NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_Rowcount_QNTY               SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_BateError_CODE              CHAR(18),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Lc_TripAddrCur_BatchDate_TEXT        CHAR(8),
          @Lc_TripAddrCur_BatchNumb_TEXT        CHAR(4),
          @Lc_TripAddrCur_BatchSeqNumb_TEXT     CHAR(4),
          @Lc_TripAddrCur_BatchItemNumb_TEXT    CHAR(3),
          @Lc_TripAddrCur_SourceBatch_CODE      CHAR(3),
          @Lc_TripAddrCur_MemberSsnNumb_TEXT    CHAR(9),
          @Lc_TripAddrCur_MemberMciIdno_TEXT    CHAR(15),
          @Lc_TripAddrCur_AddrAttnName_TEXT     CHAR(35),
          @Lc_TripAddrCur_PayorLine1Addr_TEXT   CHAR(25),
          @Lc_TripAddrCur_PayorLine2Addr_TEXT   CHAR(25),
          @Lc_TripAddrCur_PayorCityAddr_TEXT    CHAR(20),
          @Lc_TripAddrCur_PayorStateAddr_TEXT   CHAR(2),
          @Lc_TripAddrCur_PayorZipAddr_TEXT     CHAR(15),
          @Lc_TripAddrCur_PayorCountryAddr_TEXT CHAR(2),
          @Lc_TripAddrCur_InjuredSpouseINDC_TEXT CHAR(1),
          @Ld_TripAddrCur_Batch_DATE            DATE,
          @Ln_TripAddrCur_Batch_NUMB            NUMERIC(4) = 0,
          @Ln_TripAddrCur_BatchSeq_NUMB         NUMERIC(4) = 0,
          @Ln_TripAddrCur_BatchItem_NUMB        NUMERIC(3) = 0,
          @Ln_TripAddrCur_MemberMci_IDNO         NUMERIC(10) = 0,
          @Ln_TripAddrCur_MemberSsn_NUMB        NUMERIC(9);
  -- Collections Cursor
  DECLARE TripAddr_CUR INSENSITIVE CURSOR FOR
   SELECT a.Batch_DATE,
          a.Batch_NUMB,
          a.BatchSeq_NUMB,
          a.BatchItem_NUMB,
          'SPC' AS SourceBatch_CODE,
          a.MemberSsn_NUMB MemberSsn_NUMB,
          a.ReferenceIrs_IDNO Member_IDNO,
          a.Payment_NAME Attn_ADDR,
          PaymentLine1_ADDR AS Line1_ADDR,
          ' ' AS Line2_ADDR,
          PaymentCity_ADDR AS City_ADDR,
          PaymentState_ADDR AS State_ADDR,
          PaymentZip_ADDR AS Zip_ADDR,
          'US' Country_ADDR,
          InjuredSpouse_INDC
     FROM LCIRS_Y1 a
    WHERE a.Process_CODE = 'P'
    ORDER BY Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;

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
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION TripAddrTran; -- 1
   SET @Ls_Sql_TEXT = 'OPEN TripAddr_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN TripAddr_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TripAddr_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM TripAddr_CUR INTO @Lc_TripAddrCur_BatchDate_TEXT, @Lc_TripAddrCur_BatchNumb_TEXT, @Lc_TripAddrCur_BatchSeqNumb_TEXT, @Lc_TripAddrCur_BatchItemNumb_TEXT, @Lc_TripAddrCur_SourceBatch_CODE, @Lc_TripAddrCur_MemberSsnNumb_TEXT, @Lc_TripAddrCur_MemberMciIdno_TEXT, @Lc_TripAddrCur_AddrAttnName_TEXT, @Lc_TripAddrCur_PayorLine1Addr_TEXT, @Lc_TripAddrCur_PayorLine2Addr_TEXT, @Lc_TripAddrCur_PayorCityAddr_TEXT, @Lc_TripAddrCur_PayorStateAddr_TEXT, @Lc_TripAddrCur_PayorZipAddr_TEXT, @Lc_TripAddrCur_PayorCountryAddr_TEXT,@Lc_TripAddrCur_InjuredSpouseINDC_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- WHILE LOOP START
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN 
     BEGIN TRY

	  SAVE TRANSACTION SaveTripAddrTran;
	  
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
      SET @Ls_ErrorMessage_TEXT = '';
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_TripAddrCur_BatchDate_TEXT;

      IF ISDATE(LTRIM(RTRIM(@Lc_TripAddrCur_BatchDate_TEXT))) = 1
	   BEGIN 
		SET @Ld_TripAddrCur_Batch_DATE = CONVERT (DATE, @Lc_TripAddrCur_BatchDate_TEXT, 112);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END	

      SET @Ls_Sql_TEXT = 'BatchNumb_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'BatchNumb_TEXT = ' + @Lc_TripAddrCur_BatchNumb_TEXT;
      
      IF ISNUMERIC(LTRIM(RTRIM(@Lc_TripAddrCur_BatchNumb_TEXT))) = 1
	   BEGIN 
		SET @Ln_TripAddrCur_Batch_NUMB = CAST(@Lc_TripAddrCur_BatchNumb_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END
	   	
      SET @Ls_Sql_TEXT = 'BatchSeqNumb_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'BatchSeqNumb_TEXT = ' + @Lc_TripAddrCur_BatchSeqNumb_TEXT;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_TripAddrCur_BatchSeqNumb_TEXT))) = 1
	   BEGIN 
		SET @Ln_TripAddrCur_BatchSeq_NUMB = CAST(@Lc_TripAddrCur_BatchSeqNumb_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END
	   
      SET @Ls_Sql_TEXT = 'BatchItemNumb_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'BatchItemNumb_TEXT = ' + @Lc_TripAddrCur_BatchItemNumb_TEXT;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_TripAddrCur_BatchItemNumb_TEXT))) = 1
	   BEGIN 
		SET @Ln_TripAddrCur_BatchItem_NUMB = CAST(@Lc_TripAddrCur_BatchItemNumb_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END

      SET @Ls_Sql_TEXT = 'ReferenceIrs_IDNO - MemberMciIdno_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'ReferenceIrs_IDNO - PayorMCIIdno_TEXT = ' + @Lc_TripAddrCur_MemberMciIdno_TEXT;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_TripAddrCur_MemberMciIdno_TEXT))) = 1
	   BEGIN 
		SET @Ln_TripAddrCur_MemberMci_IDNO = CAST(@Lc_TripAddrCur_MemberMciIdno_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END

      SET @Ls_Sql_TEXT = 'MemberSsnNumb_TEXT - Conversion';
      SET @Ls_Sqldata_TEXT = 'MemberSsnNumb_TEXT = ' + @Lc_TripAddrCur_MemberSsnNumb_TEXT;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_TripAddrCur_MemberSsnNumb_TEXT))) = 1
	   BEGIN 
		SET @Ln_TripAddrCur_MemberSsn_NUMB = CAST(@Lc_TripAddrCur_MemberSsnNumb_TEXT AS NUMERIC);
	   END
	  ELSE
	   BEGIN
		-- INVALID VALUE
		SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
		RAISERROR (50001, 16, 1);
	   END
	   
      SET @Ls_CursorLocation_TEXT = 'TRIP Address - CURSOR COUNT - ' + ISNULL (CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR), '');
      SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_TripAddrCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_TripAddrCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_TripAddrCur_Batch_NUMB AS VARCHAR), '') + ', BatchSeq_NUMB  = ' + ISNULL (CAST(@Ln_TripAddrCur_BatchSeq_NUMB AS VARCHAR), '') + ', BatchItem_NUMB = ' + ISNULL (CAST(@Ln_TripAddrCur_BatchItem_NUMB AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_TripAddrCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB  = ' + ISNULL (CAST(@Lc_TripAddrCur_MemberSsnNumb_TEXT AS VARCHAR), '') + ', Payor_NAME = ' + ISNULL (@Lc_TripAddrCur_AddrAttnName_TEXT, '') + ', Line1_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorLine1Addr_TEXT, '') + ', Line2_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorLine2Addr_TEXT, '') + ', City_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorCityAddr_TEXT, '') + ', State_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorStateAddr_TEXT, '') + ', Zip_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorZipAddr_TEXT, '') + ', Country_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorCountryAddr_TEXT, '') + ', InjuredSpouse_INDC = ' + ISNULL(@Lc_TripAddrCur_InjuredSpouseINDC_TEXT, '');
      SET @Ls_Sql_TEXT = 'INSERT INTO TADR_Y1';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Ld_TripAddrCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_TripAddrCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_TripAddrCur_Batch_NUMB AS VARCHAR), '') + ', BatchSeq_NUMB  = ' + ISNULL (CAST(@Ln_TripAddrCur_BatchSeq_NUMB AS VARCHAR), '') + ', BatchItem_NUMB = ' + ISNULL (CAST(@Ln_TripAddrCur_BatchItem_NUMB AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_TripAddrCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB  = ' + ISNULL (CAST(@Lc_TripAddrCur_MemberSsnNumb_TEXT AS VARCHAR), '') + ', Payor_NAME = ' + ISNULL (@Lc_TripAddrCur_AddrAttnName_TEXT, '') + ', Line1_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorLine1Addr_TEXT, '') + ', Line2_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorLine2Addr_TEXT, '') + ', City_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorCityAddr_TEXT, '') + ', State_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorStateAddr_TEXT, '') + ', Zip_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorZipAddr_TEXT, '') + ', Country_ADDR = ' + ISNULL (@Lc_TripAddrCur_PayorCountryAddr_TEXT, '') + ', InjuredSpouse_INDC = ' + ISNULL(@Lc_TripAddrCur_InjuredSpouseINDC_TEXT, '');

      INSERT INTO TADR_Y1
                  (Batch_DATE,
                   SourceBatch_CODE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   MemberMci_IDNO,
                   Attn_ADDR,
                   Line1_ADDR,
                   Line2_ADDR,
                   City_ADDR,
                   State_ADDR,
                   Zip_ADDR,
                   Country_ADDR,
                   InjuredSpouse_INDC)
           VALUES ( @Ld_TripAddrCur_Batch_DATE,-- Batch_DATE
                    @Lc_TripAddrCur_SourceBatch_CODE,-- SourceBatch_CODE
                    @Ln_TripAddrCur_Batch_NUMB,-- Batch_NUMB
                    CAST(ISNULL(ISNULL (CAST(LTRIM(RTRIM(@Lc_TripAddrCur_BatchSeqNumb_TEXT)) AS VARCHAR), '') + ISNULL (CAST(LTRIM(RTRIM(@Lc_TripAddrCur_BatchItemNumb_TEXT)) AS VARCHAR), ''), 0) AS NUMERIC),-- SeqReceipt_NUMB
                    @Ln_TripAddrCur_MemberMci_IDNO,-- MemberMci_IDNO
                    @Lc_TripAddrCur_AddrAttnName_TEXT,-- Attn_ADDR
                    @Lc_TripAddrCur_PayorLine1Addr_TEXT,-- Line1_ADDR
                    @Lc_TripAddrCur_PayorLine2Addr_TEXT,-- Line2_ADDR
                    @Lc_TripAddrCur_PayorCityAddr_TEXT,-- City_ADDR
                    @Lc_TripAddrCur_PayorStateAddr_TEXT,-- State_ADDR
                    @Lc_TripAddrCur_PayorZipAddr_TEXT,-- Zip_ADDR
                    @Lc_TripAddrCur_PayorCountryAddr_TEXT, -- Country_ADDR		
                    @Lc_TripAddrCur_InjuredSpouseINDC_TEXT -- InjuredSpouse_INDC
				   );

      IF @Li_Rowcount_QNTY = 0
       BEGIN
        -- INSERT NOT SUCCESSFUL
        SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';
        SET @Lc_BateError_CODE = @Lc_ErrorE0113_CODE;
        RAISERROR (50001,16,1);
       END;
     END TRY

     BEGIN CATCH
     
      IF XACT_STATE() = 1
        BEGIN
           ROLLBACK TRANSACTION SaveTripAddrTran;
        END
      ELSE
        BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
            RAISERROR( 50001 ,16,1);
        END
        
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

      SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateError_CODE = ' + @Lc_BateError_CODE + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
      
      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
      
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LCIRS_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST(@Lc_TripAddrCur_BatchDate_TEXT AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (@Lc_TripAddrCur_BatchNumb_TEXT, '') + ', BatchSeq_NUMB = ' + ISNULL (@Lc_TripAddrCur_BatchSeqNumb_TEXT, '') + ', BatchItem_NUMB = ' + ISNULL (@Lc_TripAddrCur_BatchItemNumb_TEXT, '');

     UPDATE LCIRS_Y1
        SET Process_CODE = @Lc_Yes_INDC
      WHERE Batch_DATE = @Lc_TripAddrCur_BatchDate_TEXT
        AND Batch_NUMB = @Lc_TripAddrCur_BatchNumb_TEXT
        AND BatchSeq_NUMB = @Lc_TripAddrCur_BatchSeqNumb_TEXT
        AND BatchItem_NUMB = @Lc_TripAddrCur_BatchItemNumb_TEXT;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       -- 'Update not successful'
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     -- If the commit frequency is attained, the following is done.
     -- Reset the commit COUNT, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION TripAddrTran; -- 1
	   
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
	   
       BEGIN TRANSACTION TripAddrTran; -- 2

       SET @Ln_CommitFreq_QNTY = 0;
      END
     
     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION TripAddrTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       -- 'Reached Threshold'
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH TripAddrCur - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TripAddr_CUR INTO @Lc_TripAddrCur_BatchDate_TEXT, @Lc_TripAddrCur_BatchNumb_TEXT, @Lc_TripAddrCur_BatchSeqNumb_TEXT, @Lc_TripAddrCur_BatchItemNumb_TEXT, @Lc_TripAddrCur_SourceBatch_CODE, @Lc_TripAddrCur_MemberSsnNumb_TEXT, @Lc_TripAddrCur_MemberMciIdno_TEXT, @Lc_TripAddrCur_AddrAttnName_TEXT, @Lc_TripAddrCur_PayorLine1Addr_TEXT, @Lc_TripAddrCur_PayorLine2Addr_TEXT, @Lc_TripAddrCur_PayorCityAddr_TEXT, @Lc_TripAddrCur_PayorStateAddr_TEXT, @Lc_TripAddrCur_PayorZipAddr_TEXT, @Lc_TripAddrCur_PayorCountryAddr_TEXT,@Lc_TripAddrCur_InjuredSpouseINDC_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END -- WHILE LOOP END
   CLOSE TripAddr_CUR;

   DEALLOCATE TripAddr_CUR;

   COMMIT TRANSACTION TripAddrTran; -- 2
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;
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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_NoSpace_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_NoSpace_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TripAddrTran;
    END

   IF CURSOR_STATUS ('local', 'TripAddr_CUR') IN (0, 1)
    BEGIN
     CLOSE TripAddr_CUR;

     DEALLOCATE TripAddr_CUR;
    END

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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
