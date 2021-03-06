/****** Object:  StoredProcedure [dbo].[BATCH_FIN_COLLECTIONS$SP_LOAD_IRS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_COLLECTIONS$SP_LOAD_IRS
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_LOAD_IRS reads the collections data received from IRS and 
					  loads into temporary tables LCIRS_Y1 for further processing. If the detail record count does not matchs 
					  with the trailer count,an error message will be written into Batch Status_CODE Log 
					  (BSTL screen/BSTL_Y1 table) and the file processing will be terminated.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_COLLECTIONS$SP_LOAD_IRS]
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
           @Lc_StatusFailed_CODE           CHAR(1) = 'F',
           @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
           @Lc_Space_TEXT                  CHAR(1) = ' ',
           @Lc_RecExist_INDC               CHAR(1) = 'N',
           @Lc_TrailerExist_INDC           CHAR(1) = 'N',
           @Lc_ProcessN_INDC               CHAR(1) = 'N',
           @Lc_ProcessY_INDC               CHAR(1) = 'Y',
           @Lc_TypePrimaryP_CODE		   CHAR(1) = 'P',           
           @Lc_TypePrimaryI_CODE		   CHAR(1) = 'I',
           @Lc_Zero_TEXT				   CHAR(1) = '0',
           @Lc_SourceReceiptAR_CODE		   CHAR(2) = 'AR',
           @Lc_SourceReceiptSC_CODE		   CHAR(2) = 'SC',
           @Lc_SourceReceiptAV_CODE		   CHAR(2) = 'AV',
           @Lc_SourceReceiptAS_CODE		   CHAR(2) = 'AS',
           @Lc_TypeRemittance_CODE         CHAR(3) = 'EFT',
		   @Lc_OffsetTypeRet_CODE          CHAR(3) = 'RET',
		   @Lc_OffsetTypeTax_CODE          CHAR(3) = 'TAX',
		   @Lc_OffsetTypeVEN_CODE          CHAR(3) = 'VEN',
		   @Lc_OffsetTypeSAL_CODE          CHAR(3) = 'SAL',   
           @Lc_BatchSeqNumbDefault000_TEXT CHAR(3) = '000',
		   @Lc_BatchItemNumbDefault001_TEXT CHAR(3) = '001',
		   @Lc_SourceBatchSpc_CODE			CHAR(3) = 'SPC',
		   @Lc_BatchNumbDefault0000_TEXT   CHAR(4) = '0000',		           
		   @Lc_DateDefault0101_TEXT		   CHAR(4) = '0101',
           @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
           @Lc_Job_ID                      CHAR(7) = 'DEB7010',
		   -- Defect 13702 - Load IRS job should assign Batch Number in the range of 7000-7499 i.e.) Excluding reposted IRS receipt for run date - Fix - Start --
           @Lc_CollProcessJobDEB0540_ID    CHAR(7) = 'DEB0540',
		   -- Defect 13702 - Load IRS job should assign Batch Number in the range of 7000-7499 i.e.) Excluding reposted IRS receipt for run date - Fix - Start --           
           @Lc_AdjustDefaultAmount_TEXT	   CHAR(11) = '00000000000',
           @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
           @Ls_ParmDateProblem_TEXT        VARCHAR(100) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME              VARCHAR(100) = 'SP_LOAD_IRS',
           @Ls_Process_NAME                VARCHAR(100) = 'BATCH_FIN_COLLECTIONS',
           @Ls_IrsDescriptionError01_TEXT  VARCHAR(200) = 'RECORD ALREADY EXIST IN LCIRS_Y1',
           @Ls_IrsDescriptionError02_TEXT  VARCHAR(200) = 'RECORD ALREADY EXIST IN LNADJ_Y1',
           @Ls_IrsDescriptionError03_TEXT  VARCHAR(200) = 'FILE DETAIL RECORD NOT FOUND',
           @Ls_IrsDescriptionError04_TEXT  VARCHAR(200) = 'FILE TRAILER RECORD NOT FOUND',
           @Ls_IrsDescriptionError05_TEXT  VARCHAR(200) = 'DETAIL RECORD COUNT MISMATCH WITH TRAILER RECORD COUNT',
           @Ls_IrsDescriptionError06_TEXT  VARCHAR(200) = 'INSERT INTO LOADIRSRECEIPTS TABLE NOT SUCCESSFUL',
           @Ls_IrsDescriptionError07_TEXT  VARCHAR(200) = 'INSERT INTO LOADNEGATIVEADJUSTMENT TABLE NOT SUCCESSFUL',
		   @Ls_IrsDescriptionError08_TEXT  VARCHAR(200) = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARM_Y1 TABLE',           
		   @Ls_IrsDescriptionError09_TEXT  VARCHAR(200) = 'DETAIL COLLECTION SUM AMOUNT MISMATCH WITH TRAILER COLLECTION SUM AMOUNT',
		   @Ls_IrsDescriptionError10_TEXT  VARCHAR(200) = 'DETAIL ADJUSTMENT SUM AMOUNT MISMATCH WITH TRAILER ADJUSTMENT SUM AMOUNT',
		   @Ls_IrsDescriptionError11_TEXT  VARCHAR(200) = 'RECORD NOT FOUND',		   
           @Ld_High_DATE                   DATE = '12/31/9999';
           
  DECLARE  @Ln_CommitFreqParm_QNTY          NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
           @Ln_ProcessedRecordCount_QNTY  NUMERIC(6) = 0,
           @Ln_RowCount_QNTY            NUMERIC(7) = 0,
           @Ln_RecExists_NUMB           NUMERIC(10) = 0,
           @Ln_Rec_NUMB                 NUMERIC(10) = 0,
           @Ln_DetailRecord_QNTY        NUMERIC(10) = 0,
           @Ln_FileLength_NUMB          NUMERIC(10) = 0,
           @Ln_Batch_NUMB				NUMERIC(10) = 0,
           @Ln_Rcth_Batch_NUMB			NUMERIC(10) = 0,
           @Ln_Lcirs_Batch_NUMB			NUMERIC(10) = 0,
           @Ln_BatchSeq_NUMB            NUMERIC(10) = 0,
           @Ln_Tradjustments_NUMB       NUMERIC(10) = 0,
           @Ln_Trcollections_NUMB       NUMERIC(10) = 0,
           @Ln_TrailerRecord_QNTY       NUMERIC(10) = 0,
           @Ln_Error_NUMB               NUMERIC(11),
           @Ln_ErrorLine_NUMB           NUMERIC(11),
           @Ln_Receipt_AMNT             NUMERIC(11,2) = 0,
           @Ln_DetTotCollections_AMNT   NUMERIC(11,2) = 0,           
           @Ln_Adjust_AMNT              NUMERIC(11,2) = 0,
           @Ln_DetTotAdjust_AMNT        NUMERIC(11,2) = 0,           
           @Ln_CertifiedArrearage_AMNT  NUMERIC(11) = 0,
           @Ln_Tradjustments_AMNT       NUMERIC(11,2) = 0,
           @Ln_Trcollections_AMNT       NUMERIC(11,2) = 0,
           @Li_FetchStatus_QNTY         SMALLINT,
           @Lc_Msg_CODE                 CHAR(1),
           @Lc_St_TEXT                  CHAR(2),
           @Lc_SourceReceipt_CODE		CHAR(2),
           @Lc_Batch_DATE               CHAR(8),
           @Lc_Payor_IDNO               CHAR(10),
           @Lc_City_TEXT                CHAR(23),
           @Lc_CitySt_TEXT              CHAR(25),
           @Ls_FileName_TEXT            VARCHAR(50),
           @Ls_FileLocation_TEXT        VARCHAR(80),
           @Ls_Sql_TEXT                 VARCHAR(100) = '',
           @Ls_FileSource_TEXT          VARCHAR(130),
           @Ls_SqlStatement_TEXT        VARCHAR(200) = '',
           @Ls_CursorLocation_TEXT      VARCHAR(200),
           @Ls_Sqldata_TEXT             VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT        VARCHAR(4000),
           @Ls_DescriptionError_TEXT    VARCHAR(4000),
           @Ld_Run_DATE                 DATE,
           @Ld_LastRun_DATE             DATE,           
           @Ld_Start_DATE               DATETIME2;

  DECLARE  @Ln_LoadIrsCur_Seq_IDNO        NUMERIC(19),
		   @Ls_LoadIrsCur_Record_TEXT     VARCHAR(240);

  BEGIN TRY
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   --Start the transaction
   BEGIN TRANSACTION LoadIrsTran;

   -- Selecting date run, date last run, commit freq, exception threshold details --
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_TEXT OUTPUT,
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
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_FileName_TEXT)) + '';

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError08_TEXT;

     RAISERROR (50001,16,1);
    END
   -- File reading and loading into Temporary load table
   -- Loading IRS input file into temporary table
   SET @Ls_SqlStatement_TEXT = 'BULK INSERT ULIRS_V1 FROM  ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_Sql_TEXT = 'BULK INSERT ULIRS_V1';
   SET @Ls_Sqldata_TEXT = 'SqlStatement_TEXT' + ISNULL(@Ls_SqlStatement_TEXT,'');

   EXECUTE (@Ls_SqlStatement_TEXT);

   SET @Ln_Rec_NUMB = 0;
   SET @Ln_DetailRecord_QNTY = 0;
   DECLARE LoadIrs_CUR INSENSITIVE CURSOR FOR
   SELECT Seq_IDNO,
		  Record_TEXT
         FROM LTIRS_Y1 a
         WHERE LTRIM(RTRIM(Record_TEXT)) <> ''
        ORDER BY 1;
       
   SET @Ls_Sql_TEXT = 'OPEN LoadIrs_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN LoadIrs_CUR;

   SET @Ls_Sql_TEXT = 'FETCH LoadIrs_CUR -1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM LoadIrs_CUR INTO @Ln_LoadIrscur_Seq_IDNO, @Ls_LoadIrsCur_Record_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE 1';
   SET @Ls_Sqldata_TEXT = '';
   -- Irs loop started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_FileLength_NUMB = 0;
     SET @Ln_Rec_NUMB = @Ln_Rec_NUMB + 1;
     SET @Ls_CursorLocation_TEXT = 'IRS - CURSOR COUNT - ' + CAST (@Ln_Rec_NUMB AS VARCHAR);
     SET @Ln_FileLength_NUMB = LEN (@Ls_LoadIrsCur_Record_TEXT);

     -- FILE LENGTH VALIDATION Start
     IF @Ln_FileLength_NUMB > 200
      BEGIN
       SET @Ln_DetailRecord_QNTY = @Ln_DetailRecord_QNTY + 1;
       SET @Lc_RecExist_INDC = @Lc_ProcessY_INDC;
       SET @Ln_Receipt_AMNT = 0;
       SET @Ln_Adjust_AMNT = 0;
       SET @Ln_CertifiedArrearage_AMNT = 0;

	   SET @Ls_Sql_TEXT = 'WHILE 1 - ArrearageCertified_AMNT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'ArrearageCertified_AMNT = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 65, 11);
       SET @Ln_CertifiedArrearage_AMNT = ISNULL (dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 65, 11)), 0);
	   SET @Ls_Sql_TEXT = 'WHILE 1 - Receipt_AMNT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'Receipt_AMNT = ' + (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 76, 11));
       SET @Ln_Receipt_AMNT = ISNULL ((dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 76, 11))/100), 0);
	   SET @Ls_Sql_TEXT = 'WHILE 1 - Adjustment_AMNT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'Adjustment_AMNT = ' + (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11));
       SET @Ln_Adjust_AMNT = ISNULL ((dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11))/100), 0);
	   
	   SET @Ln_DetTotCollections_AMNT = @Ln_DetTotCollections_AMNT + @Ln_Receipt_AMNT;
	   SET @Ln_DetTotAdjust_AMNT = @Ln_DetTotAdjust_AMNT + @Ln_Adjust_AMNT;
	   
       IF @Ln_Receipt_AMNT > 0
        BEGIN

         IF @Ln_Rec_NUMB <= 25
          BEGIN
           SELECT @Lc_SourceReceipt_CODE = CASE SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 217, 3)
                                                WHEN @Lc_OffsetTypeRet_CODE
                                                 THEN @Lc_SourceReceiptAR_CODE
                                                WHEN @Lc_OffsetTypeTax_CODE
                                                 THEN @Lc_SourceReceiptSC_CODE
                                                WHEN @Lc_OffsetTypeVEN_CODE
                                                 THEN @Lc_SourceReceiptAV_CODE
                                                WHEN @Lc_OffsetTypeSAL_CODE
                                                 THEN @Lc_SourceReceiptAS_CODE
                                                ELSE @Lc_Space_TEXT
                                               END;

           SET @Ls_Sql_TEXT = 'EXISTANCE CHECKING IN LCIRS_Y1 USING KEY VALUE';
           SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9) + ', SourceReceipt_CODE = ' + @Lc_SourceReceipt_CODE + ', Receipt_AMNT = ' + CAST(@Ln_Receipt_AMNT AS VARCHAR) + ', CheckNo_TEXT = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 227, 10) + ', Tanf_CODE = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 107, 1) + ', TaxJoint_CODE = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 106, 1);
			
           --Getting the existing contents
           SELECT @Ln_RecExists_NUMB = COUNT (1)
             FROM LCIRS_Y1 a
            WHERE MemberSsn_NUMB = SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9)
              AND SourceReceipt_CODE = @Lc_SourceReceipt_CODE
              AND Receipt_AMNT = (RIGHT (@Lc_AdjustDefaultAmount_TEXT + CAST (@Ln_Receipt_AMNT AS VARCHAR), 11))
              AND CheckNo_TEXT = SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 227, 10)
              AND Tanf_CODE = SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 107, 1)
              AND TaxJoint_CODE = SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 106, 1);

           IF @Ln_RecExists_NUMB > 0
            BEGIN
             SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError01_TEXT;

             -- 'RECORD ALREADY EXIST IN LCIRS_Y1'
             RAISERROR (50001,16,1);
            END
          END
        END
       ELSE IF @Ln_Adjust_AMNT > 0
        BEGIN

         IF @Ln_Rec_NUMB <= 25
          BEGIN
           SET @Ls_Sql_TEXT = 'EXISTANCE CHECKING IN LNADJ_Y1 USING KEY VALUE';
           SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9) + ', Adjust_AMNT = ' + CAST (@Ln_Adjust_AMNT AS VARCHAR) + ', TopTraceNo_TEXT = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 227, 9);

           --Getting the existing contents
           SELECT @Ln_RecExists_NUMB = COUNT (1)
             FROM LNADJ_Y1 a
            WHERE MemberSsn_NUMB = SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9)
              AND a.Adjust_AMNT = (RIGHT (@Lc_AdjustDefaultAmount_TEXT + CAST (@Ln_Adjust_AMNT AS VARCHAR), 11))
              AND CheckNo_TEXT = SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 227, 9);

           IF @Ln_RecExists_NUMB > 0
            BEGIN
             SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError02_TEXT;
             -- 'RECORD ALREADY EXIST IN LNADJ_Y1';
             RAISERROR (50001,16,1);
            END;
          END;
        END
      END
     ELSE IF @Ln_FileLength_NUMB < 200
      -- Trailer record validation
      BEGIN
       SET @Lc_TrailerExist_INDC = @Lc_ProcessY_INDC;
       SET @Ln_Tradjustments_NUMB = CAST (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 35, 15) AS NUMERIC (15));
       SET @Ln_Trcollections_NUMB = CAST (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 50, 15) AS NUMERIC (15));
       SET @Ln_TrailerRecord_QNTY = @Ln_Tradjustments_NUMB + @Ln_Trcollections_NUMB;
	   SET @Ls_Sql_TEXT = 'Trcollections_AMNT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'Trcollections_AMNT = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 76, 11);       
       SET @Ln_Trcollections_AMNT = ISNULL (dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 76, 11))/100, 0);
	   SET @Ls_Sql_TEXT = 'Trcollections_AMNT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'Tradjustments_AMNT = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11);       
       SET @Ln_Tradjustments_AMNT = ISNULL (dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11))/100, 0);
       
       SET @Ls_Sql_TEXT = 'DETAIL RECORD COUNT MISMATCH WITH TRAILER RECORD COUNT';
	   SET @Ls_Sqldata_TEXT = 'Detail Record Count = ' + CAST(@Ln_DetailRecord_QNTY AS VARCHAR) + ', Trailer Record Count = ' + CAST(@Ln_TrailerRecord_QNTY AS VARCHAR);
       IF @Ln_DetailRecord_QNTY <> @Ln_TrailerRecord_QNTY
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError05_TEXT;
         RAISERROR (50001, 16, 1);
       END

       SET @Ls_Sql_TEXT = 'DETAIL COLLECTION SUM AMOUNT MISMATCH WITH TRAILER COLLECTION SUM AMOUNT';
	   SET @Ls_Sqldata_TEXT = 'Detail Record Collection Amount = ' + CAST(@Ln_DetTotCollections_AMNT AS VARCHAR) + ', Trailer Record Collection Amount = ' + CAST(@Ln_Trcollections_AMNT AS VARCHAR);
       IF  @Ln_DetTotCollections_AMNT <> @Ln_Trcollections_AMNT
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError09_TEXT;
         RAISERROR (50001, 16, 1);
       END

       SET @Ls_Sql_TEXT = 'DETAIL COLLECTION SUM AMOUNT MISMATCH WITH TRAILER COLLECTION SUM AMOUNT';
	   SET @Ls_Sqldata_TEXT = 'Detail Record Adjust Amount = ' + CAST(@Ln_DetTotAdjust_AMNT AS VARCHAR) + ', Trailer Record Adjust Amount = ' + CAST(@Ln_Tradjustments_AMNT AS VARCHAR);
       IF  @Ln_DetTotAdjust_AMNT <> @Ln_Tradjustments_AMNT
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError10_TEXT;
         RAISERROR (50001, 16, 1);
       END

      END

     -- Get the next row from the cursor
     SET @Ls_Sql_TEXT = 'FETCH LoadIrs_CUR-2';
     SET @Ls_Sqldata_TEXT = '';
     FETCH NEXT FROM LoadIrs_CUR INTO @Ln_LoadIrsCur_Seq_IDNO, @Ls_LoadIrsCur_Record_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LoadIrs_CUR;

   DEALLOCATE LoadIrs_CUR;

   -- Validating the trailer record
     SET @Ls_Sql_TEXT = 'RECORD NOT FOUND';
     SET @Ls_Sqldata_TEXT = 'File Detail Record Count= ' + CAST(@Ln_DetailRecord_QNTY AS VARCHAR) + ', File Trailer Record Count = ' + CAST(@Ln_TrailerRecord_QNTY AS VARCHAR);
   IF @Ln_DetailRecord_QNTY = 0 AND @Ln_TrailerRecord_QNTY = 0 
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError11_TEXT;

     RAISERROR (50001,16,1);
    END


     SET @Ls_Sql_TEXT = 'IRS DETAILED RECORD EXISTS CHECK';
     SET @Ls_Sqldata_TEXT = 'File Detail Record Count= ' + CAST(@Ln_DetailRecord_QNTY AS VARCHAR);
   IF @Ln_DetailRecord_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError03_TEXT;

     RAISERROR (50001,16,1);
    END


   SET @Ls_Sql_TEXT = 'IRS TRAILER RECORD EXISTS CHECK';
   SET @Ls_Sqldata_TEXT = 'File Trailer Record Count = ' + CAST(@Ln_TrailerRecord_QNTY AS VARCHAR);
   IF @Ln_TrailerRecord_QNTY = 0 
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError04_TEXT;

     RAISERROR (50001,16,1);
    END

   -- Delete processed records from LCIRS_Y1 table
   SET @Ls_Sql_TEXT = 'DELETE LCIRS_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_CODE = ' + ISNULL(@Lc_ProcessY_INDC,'');
   DELETE FROM LCIRS_Y1
    WHERE Process_CODE = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LNADJ_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'');
   DELETE FROM LNADJ_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ln_Batch_NUMB = 7000;
   SET @Ln_BatchSeq_NUMB = 0;
   SET @Ln_Rec_NUMB = 0;
   
   -- Defect 13164 - Loading more than one IRS file for the same date - Fix - Start -- 
   -- If more than one IRS file is loaded on same day then New Batch number will be generated
   
   SET @Ls_Sql_TEXT = 'SELECT LCIRS_Y1 - MAX(Batch_NUMB)';
   SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
      
   SELECT @Ln_Lcirs_Batch_NUMB = MAX(Batch_NUMB) 
   FROM LCIRS_Y1 a
   WHERE FileLoad_DATE = @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 - MAX(Batch_NUMB)';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SourceBatchSpc_CODE;
      
   SELECT @Ln_Rcth_Batch_NUMB = MAX(Batch_NUMB) 
   FROM RCTH_Y1 a, GLEV_Y1 b
   WHERE a.Batch_DATE = @Ld_Run_DATE
     AND a.SourceBatch_CODE = @Lc_SourceBatchSpc_CODE
     -- Defect 13702 - Load IRS job should assign Batch Number in the range of 7000-7499 i.e.) Excluding reposted IRS receipt for run date - Fix - Start --
     AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalSeq_NUMB
     AND b.Process_ID = @Lc_CollProcessJobDEB0540_ID
     -- Defect 13702 - Load IRS job should assign Batch Number in the range of 7000-7499 i.e.) Excluding reposted IRS receipt for run date - Fix - End --
     AND a.EndValidity_DATE = @Ld_High_DATE;
   
   IF @Ln_Lcirs_Batch_NUMB <> 0 OR @Ln_Rcth_Batch_NUMB <> 0
   BEGIN 
		SET @Ls_Sql_TEXT = 'SELECT New Batch_NUMB';
		SET @Ls_Sqldata_TEXT = '@Ln_Lcirs_Batch_NUMB = ' + CAST(@Ln_Lcirs_Batch_NUMB AS VARCHAR) + ', @Ln_Rcth_Batch_NUMB = ' + CAST(@Ln_Rcth_Batch_NUMB AS VARCHAR);
   
		SELECT @Ln_Batch_NUMB = MAX(Batch_NUMB) + 1
		FROM (
				SELECT @Ln_Lcirs_Batch_NUMB Batch_NUMB
				UNION ALL
				SELECT @Ln_Rcth_Batch_NUMB Batch_NUMB
			 )a;
   END 
   -- Defect 13164 - Loading more than one IRS file for the same date - Fix - End -- 
   
   DECLARE LoadIrs_CUR INSENSITIVE CURSOR FOR
   SELECT Seq_IDNO,
			  Record_TEXT
         FROM LTIRS_Y1 a
        WHERE LEN (Record_TEXT) > 200; -- Detail record identifier
        
   SET @Ls_Sql_TEXT = 'OPEN LOAD IRS CURSOR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN LoadIrs_CUR;

   SET @Ls_Sql_TEXT = 'FETCH LOAD IRS CURSOR';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM LoadIrs_CUR INTO @Ln_LoadIrsCur_Seq_IDNO, @Ls_LoadIrsCur_Record_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Convert the batch run date into yyyymmdd Format_CODE
   SET @Lc_Batch_DATE = CONVERT (VARCHAR, @Ld_Run_DATE, 112);
   SET @Ls_Sql_TEXT = 'WHILE 2';
   SET @Ls_Sqldata_TEXT = '';
   -- Loop started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Rec_NUMB = @Ln_Rec_NUMB + 1;
     SET @Ln_FileLength_NUMB = LEN (@Ls_LoadIrsCur_Record_TEXT);
     SET @Ls_CursorLocation_TEXT = 'IRS - CURSOR COUNT - ' + CAST (@Ln_Rec_NUMB AS VARCHAR);
     SET @Ln_Receipt_AMNT = 0;
     SET @Ln_Adjust_AMNT = 0;
     SET @Ln_CertifiedArrearage_AMNT = 0;
	 SET @Ls_Sql_TEXT = 'WHILE 2 - ArrearageCertified_AMNT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'ArrearageCertified_AMNT = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 65, 11);
     SET @Ln_CertifiedArrearage_AMNT = ISNULL (dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 65, 11)), 0);
	 SET @Ls_Sql_TEXT = 'WHILE 2 - Receipt_AMNT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'Receipt_AMNT = ' + (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 76, 11));
     SET @Ln_Receipt_AMNT = ISNULL ((dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 76, 11))/100), 0);
	 SET @Ls_Sql_TEXT = 'WHILE 2 - Adjustment_AMNT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'Adjustment_AMNT = ' + (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11));
     SET @Ln_Adjust_AMNT = ISNULL ((dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11))/100), 0);

     SELECT @Lc_SourceReceipt_CODE = CASE SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 217, 3)
                                                WHEN @Lc_OffsetTypeRet_CODE
                                                 THEN @Lc_SourceReceiptAR_CODE
                                                WHEN @Lc_OffsetTypeTax_CODE
                                                 THEN @Lc_SourceReceiptSC_CODE
                                                WHEN @Lc_OffsetTypeVEN_CODE
                                                 THEN @Lc_SourceReceiptAV_CODE
                                                WHEN @Lc_OffsetTypeSAL_CODE
                                                 THEN @Lc_SourceReceiptAS_CODE
                                                ELSE @Lc_Space_TEXT
                                               END;

     IF @Ln_Receipt_AMNT > 0
      --Load the data Into IRS Receipts Table When the Tax Intercept Value_AMNT > 0
      BEGIN
       SET @Ln_BatchSeq_NUMB = @Ln_BatchSeq_NUMB + 1;

       -- if the sequence number is greater than 999, reset the sequence number
       -- to 1 and increment the batch number by 1
       IF @Ln_BatchSeq_NUMB > 999
        BEGIN
         SET @Ln_BatchSeq_NUMB = 1;
         SET @Ln_Batch_NUMB = @Ln_Batch_NUMB + 1;
        END;

       SET @Lc_CitySt_TEXT = @Lc_Space_TEXT;
       SET @Lc_City_TEXT = @Lc_Space_TEXT;
       SET @Lc_St_TEXT = @Lc_Space_TEXT;
       SET @Lc_CitySt_TEXT = ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 183, 25), @Lc_Space_TEXT);

       IF (LEN (RTRIM (@Lc_CitySt_TEXT)) != 0)
        BEGIN
         SET @Lc_St_TEXT = RIGHT (RTRIM (@Lc_CitySt_TEXT), 2);
         SET @Lc_City_TEXT = SUBSTRING (RTRIM (@Lc_CitySt_TEXT), 0, (LEN (RTRIM (@Lc_CitySt_TEXT)) - 2));
        END

       SET @Ls_Sql_TEXT = 'INSERT INTO LCIRS_Y1';
       SET @Ls_Sqldata_TEXT = 'BATCH DATE = ' + CAST(@Lc_Batch_DATE AS VARCHAR) + ', BATCH NUMBER = ' + CAST (@Ln_Batch_NUMB AS VARCHAR) + ', SEQ NUMBER = ' + CAST (@Ln_BatchSeq_NUMB AS VARCHAR) + ', Record_TEXT = ' + @Ls_LoadIrsCur_Record_TEXT + 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_CODE = ' + ISNULL(@Lc_ProcessN_INDC,'');

       INSERT INTO LCIRS_Y1
                   (Batch_DATE,
                    Batch_NUMB,
                    BatchSeq_NUMB,
                    BatchItem_NUMB,
                    SourceBatch_CODE,
                    StateSubmit_CODE,
                    Local_CODE,
                    MemberSsn_NUMB,
                    ReferenceIrs_IDNO,
                    ObligorLast_NAME,
                    ObligorFirst_NAME,
                    ArrearageCertified_AMNT,
                    Receipt_AMNT,
                    Adjustment_AMNT,
                    AdjustmentYear_NUMB,
                    OffsetYear_NUMB,
                    TaxJoint_CODE,
                    Tanf_CODE,
                    StateTransfer_CODE,
                    LocalTransfer_CODE,
                    Payment_NAME,
                    PaymentLine1_ADDR,
                    PaymentCity_ADDR,
                    PaymentState_ADDR,
                    PaymentZip_ADDR,
                    TypeOffset_CODE,
                    Fee_AMNT,
                    InjuredSpouse_INDC,
                    ZeroBalanceDel_INDC,
                    CheckNo_TEXT,
                    SourceReceipt_CODE,
                    TypeRemittance_CODE,
                    Receipt_DATE,
                    FileLoad_DATE,
                    Process_CODE)
            VALUES ( (ISNULL (@Lc_Batch_DATE, CONVERT (VARCHAR, @Ld_Run_DATE, 112))), -- Batch_DATE
                     (RIGHT (@Lc_BatchNumbDefault0000_TEXT + CAST(@Ln_Batch_NUMB AS VARCHAR), 4)), -- Batch_NUMB
                     (RIGHT (@Lc_BatchSeqNumbDefault000_TEXT + CAST(@Ln_BatchSeq_NUMB AS VARCHAR), 3)), -- BatchSeq_NUMB
                     (@Lc_BatchItemNumbDefault001_TEXT), -- BatchItem_NUMB
                     (@Lc_SourceBatchSpc_CODE), -- SourceBatch_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 1, 2), @Lc_Space_TEXT)), -- StateSubmit_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 3, 3), @Lc_Space_TEXT)), -- Local_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9), @Lc_Space_TEXT)), -- MemberSsn_NUMB
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 15, 15), @Lc_Space_TEXT)), -- ReferenceIrs_IDNO
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 30, 20), @Lc_Space_TEXT)), -- ObligorLast_NAME
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 50, 15), @Lc_Space_TEXT)), -- ObligorFirst_NAME
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 65, 11), @Lc_Zero_TEXT)), -- ArrearageCertified_AMNT
                     (RIGHT (@Lc_AdjustDefaultAmount_TEXT + CAST (@Ln_Receipt_AMNT AS VARCHAR), 11)), -- Receipt_AMNT
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 87, 11), @Lc_Zero_TEXT)), -- Adjustment_AMNT
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 98, 4), @Lc_Space_TEXT)), -- AdjustmentYear_NUMB
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 102, 4), @Lc_Space_TEXT)), -- OffsetYear_NUMB
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 106, 1), @Lc_Space_TEXT)), -- TaxJoint_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 107, 1), @Lc_Space_TEXT)), -- Tanf_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 108, 2), @Lc_Space_TEXT)), -- StateTransfer_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 110, 3), @Lc_Space_TEXT)), -- LocalTransfer_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 113, 35), @Lc_Space_TEXT)), -- Payment_NAME
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 148, 35), @Lc_Space_TEXT)), -- PaymentLine1_ADDR
                     (ISNULL (@Lc_City_TEXT, @Lc_Space_TEXT)), -- PaymentCity_ADDR
                     (ISNULL (@Lc_St_TEXT, @Lc_Space_TEXT)), -- PaymentState_ADDR
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 208, 9), @Lc_Space_TEXT)), -- PaymentZip_ADDR
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 217, 3), @Lc_Space_TEXT)), -- TypeOffset_CODE
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 220, 5), @Lc_Zero_TEXT)), -- Fee_AMNT
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 225, 1), @Lc_Space_TEXT)), -- InjuredSpouse_INDC
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 226, 1), @Lc_Space_TEXT)), -- ZeroBalanceDel_INDC
                     (ISNULL (SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 227, 10), @Lc_Space_TEXT)), -- CheckNo_TEXT
                     (ISNULL (@Lc_SourceReceipt_CODE, @Lc_Space_TEXT)),-- SourceReceipt_CODE
                     (ISNULL (@Lc_TypeRemittance_CODE, @Lc_Space_TEXT)), -- TypeRemittance_CODE
                     (ISNULL (@Lc_Batch_DATE, @Lc_Space_TEXT)), -- Receipt_DATE
                     @Ld_Run_DATE, -- FileLoad_DATE
                     @Lc_ProcessN_INDC -- Process_CODE
                     );

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError06_TEXT;

         -- 'Insert into LoadIrsreceipt table not successful'
         RAISERROR (50001,16,1);
        END;
      END
     ELSE
      BEGIN
       --Load the data Into Negative Adjustment table When Adjustment Value_AMNT > 0
       IF (@Ln_Adjust_AMNT) > 0
        BEGIN
         
         SET @Ls_Sql_TEXT = 'SELECT MemberMci_IDNO FROM MSSN_Y1';
         SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9) + 'Enumeration_CODE = ' + ISNULL(@Lc_ProcessY_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT @Lc_Payor_IDNO = a.MemberMci_IDNO
           FROM MSSN_Y1 a
          WHERE a.MemberSsn_NUMB = CAST(SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9) AS NUMERIC)
            AND a.TypePrimary_CODE IN (@Lc_TypePrimaryP_CODE, @Lc_TypePrimaryI_CODE)
            AND a.Enumeration_CODE = @Lc_ProcessY_INDC
            AND a.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Lc_Payor_IDNO = SPACE (10);
          END
         ELSE
          BEGIN
           IF @Ln_RowCount_QNTY > 1
            BEGIN
             SET @Lc_Payor_IDNO = SPACE (10);
            END
          END

         SET @Ls_Sql_TEXT = 'INSERT INTO LNADJ_Y1';
         SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(@Lc_Payor_IDNO,'')+ ', FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

         INSERT INTO LNADJ_Y1
                     (PayorMCI_IDNO,
                      Adjust_AMNT,
                      MemberSsn_NUMB,
                      CheckNo_TEXT,
                      Adjust_DATE,
                      Tanf_CODE,
                      TaxJoint_CODE,
                      TaxJoint_NAME,
                      FileLoad_DATE,
                      Process_INDC)
              VALUES ( @Lc_Payor_IDNO,-- PayorMCI_IDNO
                       (RIGHT (@Lc_AdjustDefaultAmount_TEXT + CAST (@Ln_Adjust_AMNT AS VARCHAR), 11)),-- Adjust_AMNT
                       SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 6, 9),-- MemberSsn_NUMB
                       SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 227, 9),-- CheckNo_TEXT
                       @Lc_DateDefault0101_TEXT + SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 98, 4),-- Adjust_DATE
                       SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 107, 1),-- Tanf_CODE
                       SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 106, 1),-- TaxJoint_CODE
                       SUBSTRING (@Ls_LoadIrsCur_Record_TEXT, 113, 35),-- TaxJoint_NAME
                       @Ld_Run_DATE,-- FileLoad_DATE
                       (@Lc_ProcessN_INDC) -- Process_INDC
					);

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = @Ls_IrsDescriptionError07_TEXT;

           -- 'Insert inot Load NegativeAdjustment table not successful'
           RAISERROR (50001,16,1);
          END;
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH LOAD IRS CURSOR-2';
     SET @Ls_Sqldata_TEXT = '';
     FETCH NEXT FROM LoadIrs_CUR INTO @Ln_LoadIrsCur_Seq_IDNO, @Ls_LoadIrsCur_Record_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LoadIrs_CUR;

   DEALLOCATE LoadIrs_CUR;

   -- Delete the records from the LTIRS_Y1 table 
   SET @Ls_Sql_TEXT = 'DELETE LTIRS_Y1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM LTIRS_Y1;

   SET @Ls_Sql_TEXT = 'SELECT LCIRS_Y1';
   SET @Ls_Sqldata_TEXT = '';   
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM LCIRS_Y1 a;

   --Update the parameter table with the job run date as the current system date
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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @LC_Successful_TEXT,
    @As_ListKey_TEXT          = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION LoadIrsTran;

  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LoadIrsTran;
    END

   IF CURSOR_STATUS ('LOCAL', 'LoadIrs_CUR') IN (0, 1)
    BEGIN
     CLOSE LoadIrs_CUR;

     DEALLOCATE LoadIrs_CUR;
    END

   DELETE FROM LTIRS_Y1;

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
