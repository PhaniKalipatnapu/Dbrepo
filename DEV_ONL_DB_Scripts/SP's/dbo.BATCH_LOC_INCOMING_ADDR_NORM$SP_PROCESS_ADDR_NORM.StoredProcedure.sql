/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_ADDR_NORM$SP_PROCESS_ADDR_NORM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_INCOMING_ADDR_NORM$SP_PROCESS_ADDR_NORM

Programmer Name 	: IMP Team

Description			: This process reads the temporary normalized address load table (LADRN_Y1) and overlays the member’s 
					  address on the Member Address History (AHIS_Y1) table or the Other Party address on the Other Party Information (OTHP_Y1) table. 

Frequency			: 'Weekly'

Developed On		: 

Called BY			: None

Called On			: 
------------------------------------------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0	
------------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_ADDR_NORM$SP_PROCESS_ADDR_NORM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',                                                                                         
          @Lc_TypeRecordA_CODE            CHAR(1) = 'A',
          @Lc_TypeRecordO_CODE            CHAR(1) = 'O',
          @Lc_Normalized_CODE             CHAR(1) = 'N',                    
          @Lc_No_INDC                     CHAR(1) = 'N',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_ErrorTypeError_CODE         CHAR(1) = 'E',                              
          @Lc_ErrorE0944_CODE             CHAR(5) = 'E0944',
          @Lc_ErrorE0085_CODE             CHAR(5) = 'E0085',
          @Lc_ErrorE0485_CODE             CHAR(5) = 'E0485',
          @Lc_ErrorE0907_CODE             CHAR(5) = 'E0907',
          @Lc_ErrorE0606_CODE             CHAR(5) = 'E0606',
          @Lc_ErrorE0702_CODE             CHAR(5) = 'E0702',
          @Lc_ErrorE0542_CODE             CHAR(5) = 'E0542',
          @Lc_ErrorE0520_CODE             CHAR(5) = 'E0520',
          @Lc_ErrorE0997_CODE             CHAR(5) = 'E0997',
          @Lc_ErrorE1089_CODE             CHAR(5) = 'E1089',
          @Lc_ErrorE1424_CODE             CHAR(5) = 'E1424',          
          @Lc_Job_ID                      CHAR(7) = 'DEB9012',
          @Lc_BatchRunUser_TEXT           CHAR(10) = 'BATCH',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT                CHAR(30) = 'UPDATE NOT SUCCESSFUL',         
          @Lc_Attn_ADDR                   CHAR(40) = ' ',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_LOC_INCOMING_ADDR_NORM',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_PROCESS_NORM',
          @Ls_DescriptionComments_TEXT    VARCHAR(1000) = ' ',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                        NUMERIC(1) = 0,
          @Ln_Office_IDNO                      NUMERIC(3),
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5),
          @Ln_ExceptionThreshold_NUMB          NUMERIC(5, 0) = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_ExcpThreshold_QNTY               NUMERIC(5, 0) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                 NUMERIC(5, 0) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY      NUMERIC(6) = 0,
          @Ln_Fein_IDNO                        NUMERIC(9, 0),
          @Ln_Line_NUMB                        NUMERIC(10),
          @Ln_Cursor_QNTY                      NUMERIC (10) = 0,
          @Ln_CursorRecord_QNTY                NUMERIC (10) = 0,
          @Ln_RecordCount_QNTY                 NUMERIC(10, 0) = 0,
          @Ln_Error_NUMB                       NUMERIC(11),
          @Ln_ErrorLine_NUMB                   NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB         NUMERIC(18, 0),
          @Ln_RowsCount_QNTY                   NUMERIC,
          @Li_Rowcount_QNTY                    SMALLINT,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Lc_Msg_CODE                         CHAR(1) = '',
          @Lc_Space_TEXT                       CHAR(1) = '',
          @Lc_TypeError_CODE                   CHAR(1),
          @Lc_BateError_CODE                   CHAR(5),
          @Ls_FileLocation_TEXT                VARCHAR(50) = '',
          @Ls_File_NAME                        VARCHAR(50) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200) = '',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_Sql_TEXT                         VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(4000),
          @Ls_BateRecord_TEXT                  VARCHAR(4000),
          @Ls_Sqldata_TEXT                     VARCHAR(5000) = '',
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2;
  DECLARE @Ln_AddrNormCur_Seq_IDNO                 NUMERIC,
          @Lc_AddrNormCur_Normalization_CODE       CHAR(1),
          @Lc_AddrNormCur_TypeRecord_CODE          CHAR(1),
          @Lc_AddrNormCur_AddrOthpType_CODE        CHAR(1),
          @Lc_AddrNormCur_State_ADDR               CHAR(2),
          @Lc_AddrNormCur_Country_ADDR             CHAR(2),
          @Lc_AddrNormCur_OtherParty_IDNO          CHAR(9),
          @Lc_AddrNormCur_MemberMci_IDNO           CHAR(10),
          @Lc_AddrNormCur_Zip_ADDR                 CHAR(15),
          @Lc_AddrNormCur_TransactionEventSeq_NUMB CHAR(19),
          @Lc_AddrNormCur_City_ADDR                CHAR(28),
          @Ls_AddrNormCur_Line1_ADDR               VARCHAR(50),
          @Ls_AddrNormCur_Line2_ADDR               VARCHAR(50);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
   /*Get the current run date and last run date from the Parameter (PARM_Y1) table, and validate that the batch program was not executed for the current run date. 
   Otherwise, an error message to that effect will be written into the Batch Status Log (BSTL_Y1) table, and the process will terminate.*/
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

   SET @Ld_LastRun_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF @Ld_LastRun_DATE > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECK RESTART KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_Line_NUMB = ISNULL(CAST(r.RestartKey_TEXT AS NUMERIC(11)), 0)
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND r.Run_DATE = @Ld_Run_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ln_Cursor_QNTY = 0;
     SET @Ln_Line_NUMB = 0;
    END
   ELSE
    BEGIN
     SET @Ln_Cursor_QNTY = @Ln_Line_NUMB;
    END

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE_Y1 RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR) + ', Line_NUMB = ' + CAST (@Ln_Cursor_QNTY AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_Cursor_QNTY;

   DECLARE AddrNorm_CUR INSENSITIVE CURSOR FOR
    SELECT a.Seq_IDNO,
           a.TypeRecord_CODE,
           a.MemberMci_IDNO,
           a.OtherParty_IDNO,
           a.AddrOthpType_CODE,
           a.TransactionEventSeq_NUMB,
           a.Line1_ADDR,
           a.Line2_ADDR,
           a.City_ADDR,
           a.State_ADDR,
           a.Zip_ADDR,
           a.Country_ADDR,
           a.Normalization_CODE
      FROM LADRN_Y1 a
     WHERE a.TypeRecord_CODE IN (@Lc_TypeRecordA_CODE, @Lc_TypeRecordO_CODE)
       AND a.Normalization_CODE = @Lc_Normalized_CODE
       AND Process_INDC = @Lc_No_INDC;

   BEGIN TRANSACTION ADDRNORM_PROCESS;

   -- OPEN AddrNorm_CUR	
   SET @Ls_Sql_TEXT = 'OPEN AddrNorm_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN AddrNorm_CUR;

   --FETCH AddrNorm_CUR
   SET @Ls_Sql_TEXT = 'FETCH AddrNorm_CUR';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM AddrNorm_CUR INTO @Ln_AddrNormCur_Seq_IDNO, @Lc_AddrNormCur_TypeRecord_CODE, @Lc_AddrNormCur_MemberMci_IDNO, @Lc_AddrNormCur_OtherParty_IDNO, @Lc_AddrNormCur_AddrOthpType_CODE, @Lc_AddrNormCur_TransactionEventSeq_NUMB, @Ls_AddrNormCur_Line1_ADDR, @Ls_AddrNormCur_Line2_ADDR, @Lc_AddrNormCur_City_ADDR, @Lc_AddrNormCur_State_ADDR, @Lc_AddrNormCur_Zip_ADDR, @Lc_AddrNormCur_Country_ADDR, @Lc_AddrNormCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      -- Incrementing the cursor count and the commit count for each record being processed.
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CursorRecord_QNTY = @Ln_CursorRecord_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_AddrNormCur_Seq_IDNO AS VARCHAR) + ', TypeRecord_CODE = ' + @Lc_AddrNormCur_TypeRecord_CODE + ', MemberMci_IDNO = ' + @Lc_AddrNormCur_MemberMci_IDNO + ', OtherParty_IDNO = ' + @Lc_AddrNormCur_OtherParty_IDNO + ', AddrOthpType_CODE = ' + @Lc_AddrNormCur_AddrOthpType_CODE + ', TransactionEventSeq_NUMB = ' + @Lc_AddrNormCur_TransactionEventSeq_NUMB + ', Line1_ADDR = ' + @Ls_AddrNormCur_Line1_ADDR + ', Line2_ADDR = ' + @Ls_AddrNormCur_Line2_ADDR + ', City_ADDR = ' + @Lc_AddrNormCur_City_ADDR + ', State_ADDR = ' + @Lc_AddrNormCur_State_ADDR + ', Zip_ADDR = ' + @Lc_AddrNormCur_Zip_ADDR + ', Country_ADDR = ' + @Lc_AddrNormCur_Country_ADDR + ', Normalization_CODE = ' + @Lc_AddrNormCur_Normalization_CODE;
      SET @Ls_CursorLocation_TEXT = 'CursorLocation_TEXT = ' + CAST(@Ln_CursorRecord_QNTY AS VARCHAR);

      /*If the REC-TYPE is ‘A’ and normalization code is equal to ‘N’, overlay Address Line 1, Address Line 2, City, State, Zip, Country, and Normalization Code 
      on AHIS_Y1 where the Member Client Index (MCI) number, Address Type, and Transaction Event Sequence Number match.*/
      IF(@Lc_AddrNormCur_TypeRecord_CODE = @Lc_TypeRecordA_CODE)
       BEGIN
        UPDATE AHIS_Y1
           SET Line1_ADDR = @Ls_AddrNormCur_Line1_ADDR,
               Line2_ADDR = @Ls_AddrNormCur_Line2_ADDR,
               City_ADDR = @Lc_AddrNormCur_City_ADDR,
               State_ADDR = @Lc_AddrNormCur_State_ADDR,
               Zip_ADDR = @Lc_AddrNormCur_Zip_ADDR,
               Country_ADDR = @Lc_AddrNormCur_Country_ADDR,
               Normalization_CODE = @Lc_AddrNormCur_Normalization_CODE
         WHERE MemberMci_IDNO = @Lc_AddrNormCur_MemberMci_IDNO
           AND TypeAddress_CODE = @Lc_AddrNormCur_AddrOthpType_CODE
           AND TransactionEventSeq_NUMB = @Lc_AddrNormCur_TransactionEventSeq_NUMB;

        SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

        IF @Ln_RowsCount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Lc_Err0002_TEXT;

          RAISERROR (50001,16,1);
         END
       END
      ELSE IF(@Lc_AddrNormCur_TypeRecord_CODE = @Lc_TypeRecordO_CODE)
       BEGIN
        UPDATE OTHP_Y1
           SET Line1_ADDR = @Ls_AddrNormCur_Line1_ADDR,
               Line2_ADDR = @Ls_AddrNormCur_Line2_ADDR,
               City_ADDR = @Lc_AddrNormCur_City_ADDR,
               State_ADDR = @Lc_AddrNormCur_State_ADDR,
               Zip_ADDR = @Lc_AddrNormCur_Zip_ADDR,
               Country_ADDR = @Lc_AddrNormCur_Country_ADDR,
               Normalization_CODE = @Lc_AddrNormCur_Normalization_CODE
         WHERE OtherParty_IDNO = @Lc_AddrNormCur_OtherParty_IDNO
           AND TypeOthp_CODE = @Lc_AddrNormCur_AddrOthpType_CODE
           AND TransactionEventSeq_NUMB = @Lc_AddrNormCur_TransactionEventSeq_NUMB;

        SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

        IF @Ln_RowsCount_QNTY = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

          RAISERROR (50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      -- Process unknown errors
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

      SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_ErrorMessage_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      -- Check if the procedure ran properly
      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
     END CATCH

     -- Updating process indicator to Y
     SET @Ls_Sql_TEXT = 'UPDATING LADRN_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Seq_IDNO = ' + CAST(@Ln_AddrNormCur_Seq_IDNO AS VARCHAR)

     UPDATE LADRN_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Process_INDC = @Lc_No_INDC
        AND Seq_IDNO = @Ln_AddrNormCur_Seq_IDNO

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE LADRN_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     -- If the commit frequency is attained, Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreq_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Cursor_QNTY = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cursor_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       --	Begin, Commit & Rollback Transaction Implementation for INPUT FILE PROCESS Main Procedure:
       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

       COMMIT TRANSACTION ADDRNORM_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

       BEGIN TRANSACTION ADDRNORM_PROCESS;

       -- After Transaction is commited and again began set the commit frequencey to 0                        
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'REACHED THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', CURSOR_CNT = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), @Lc_Space_TEXT) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     -- Raise error if the exception threshold value is reached.
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'REACHED THRESHOLD';

       RAISERROR (50001,16,1);
      END

     --FETCH AddrNorm_CUR
     SET @Ls_Sql_TEXT = 'FETCH AddrNorm_CUR';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM AddrNorm_CUR INTO @Ln_AddrNormCur_Seq_IDNO, @Lc_AddrNormCur_TypeRecord_CODE, @Lc_AddrNormCur_MemberMci_IDNO, @Lc_AddrNormCur_OtherParty_IDNO, @Lc_AddrNormCur_AddrOthpType_CODE, @Lc_AddrNormCur_TransactionEventSeq_NUMB, @Ls_AddrNormCur_Line1_ADDR, @Ls_AddrNormCur_Line2_ADDR, @Lc_AddrNormCur_City_ADDR, @Lc_AddrNormCur_State_ADDR, @Lc_AddrNormCur_Zip_ADDR, @Lc_AddrNormCur_Country_ADDR, @Lc_AddrNormCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE AddrNorm_CUR;

   DEALLOCATE AddrNorm_CUR;

   --If no record found then write error in BATE_Y1 table ‘E0944 – No Record(s) to Process’
   IF(@Ln_Cursor_QNTY = 0)
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
     SET @Ls_Sql_TEXT = 'NO RECORD(S) IN CURSOR TO PROCESS';
     SET @Ls_ErrorMessage_TEXT = @Ls_Sql_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   -- Update the last run date in the PARM_Y1 table with the current run date upon successful completion.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the error encountered or successful completion in BSTL_Y1 for future references.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Commit the transaction
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   COMMIT TRANSACTION ADDRNORM_PROCESS;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ADDRNORM_PROCESS;
    END

   -- Check if cursor is opened, closed and deallocate it.
   IF CURSOR_STATUS ('local', 'AddrNorm_CUR') IN (0, 1)
    BEGIN
     CLOSE AddrNorm_CUR;

     DEALLOCATE AddrNorm_CUR;
    END

   -- Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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

   -- Update Status in Batch Log Table
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
