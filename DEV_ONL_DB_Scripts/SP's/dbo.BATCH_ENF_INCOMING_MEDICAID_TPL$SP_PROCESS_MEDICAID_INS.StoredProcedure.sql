/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_INS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_INS
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_INS 
					  reads the insurance providers information from the temporary table LIPRO_Y1 
					  and updates the Other Party (OTHP_Y1) table
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_MEDICAID_TPL$SP_PROCESS_MEDICAID_INS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_TypeErrorE_CODE        CHAR(1) = 'E',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeOthpI_CODE         CHAR(1) = 'I',
          @Lc_Country_ADDR           CHAR(2) = 'US',
          @Lc_SourceLocMed_CODE      CHAR(3) = 'MED',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE    CHAR(5) = 'E0944',
          @Lc_BateErrorE0958_CODE    CHAR(5) = 'E0958',
          @Lc_BateErrorE0620_CODE    CHAR(5) = 'E0620',
          @Lc_BateErrorE1424_CODE    CHAR(5) = 'E1424',
          @Lc_Job_ID                 CHAR(7) = 'DEB9101',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_MEDICAID_TPL',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_MEDICAID_INS';
  DECLARE @Ln_Zero_NUMB                       NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY     NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY       NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_OtherParty_IDNO                 NUMERIC(9) = 0,
          @Ln_RecordCount_QNTY                NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB                  NUMERIC(11) = 0,
          @Ln_Error_NUMB                      NUMERIC(11),
          @Li_FetchStatus_QNTY                SMALLINT,
          @Li_RowCount_QNTY                   SMALLINT,
          @Lc_Empty_TEXT                      CHAR = '',
          @Lc_Msg_CODE                        CHAR(5),
          @Lc_BateError_CODE                  CHAR(5),
          @Ls_Sql_TEXT                        VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT             VARCHAR(200),
          @Ls_SqlData_TEXT                    VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT               VARCHAR(2000),
          @Ls_DescriptionError_TEXT           VARCHAR(4000),
          @Ls_BateRecord_TEXT                 VARCHAR(4000),
          @Ld_Run_DATE                        DATE,
          @Ld_LastRun_DATE                    DATE,
          @Ld_Start_DATE                      DATETIME2;
  DECLARE @Ln_MptCur_Seq_IDNO                NUMERIC(19),
          @Lc_MptCur_InsCompanyCarrier_CODE  CHAR(5),
          @Lc_MptCur_InsCompanyLocation_CODE CHAR(4),
          @Lc_MptCur_Phone_NUMB              CHAR(10),
          @Lc_MptCur_Normalization_CODE      CHAR(1) = 'N',
          @Ls_MptCur_Employer_NAME           VARCHAR(45),
          @Ls_MptCur_Line1_ADDR              VARCHAR(50),
          @Ls_MptCur_Line2_ADDR              VARCHAR(50),
          @Lc_MptCur_City_ADDR               CHAR(28),
          @Lc_MptCur_State_ADDR              CHAR(2),
          @Lc_MptCur_Zip_ADDR                CHAR(15),
          @Lc_MptCur_Process_INDC            CHAR(1);
  DECLARE @Ln_MptCur_Phone_NUMB NUMERIC(15);
  DECLARE Mpt_CUR INSENSITIVE CURSOR FOR
   SELECT Seq_IDNO,
          Employer_NAME,
          InsCompanyCarrier_CODE,
          InsCompanyLocation_CODE,
          Phone_NUMB,
          Normalization_CODE,
          Line1_ADDR,
          Line2_ADDR,
          City_ADDR,
          State_ADDR,
          Zip_ADDR,
          Process_INDC
     FROM LIPRO_Y1
    WHERE Process_INDC = @Lc_ProcessN_INDC
    ORDER BY Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_MEDICAID_INS';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_PROCESS_MEDICAID_INS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO PROCESS FROM LIPRO_Y1';
   SET @Ls_SqlData_TEXT = '';

   IF EXISTS (SELECT 1
                FROM LIPRO_Y1 A
               WHERE A.Process_INDC = @Lc_ProcessN_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'OPEN Mpt_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN Mpt_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Mpt_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM Mpt_CUR INTO @Ln_MptCur_Seq_IDNO, @Ls_MptCur_Employer_NAME, @Lc_MptCur_InsCompanyCarrier_CODE, @Lc_MptCur_InsCompanyLocation_CODE, @Lc_MptCur_Phone_NUMB, @Lc_MptCur_Normalization_CODE, @Ls_MptCur_Line1_ADDR, @Ls_MptCur_Line2_ADDR, @Lc_MptCur_City_ADDR, @Lc_MptCur_State_ADDR, @Lc_MptCur_Zip_ADDR, @Lc_MptCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH Mpt_CUR';
     SET @Ls_SqlData_TEXT = '';

     --Process incoming records
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SAVE TRANSACTION SAVE_PROCESS_MEDICAID_INS;

        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
        SET @Ls_ErrorMessage_TEXT = '';
        SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
        SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ls_CursorLocation_TEXT = 'Mpt - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
        SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_MptCur_Seq_IDNO AS VARCHAR) + ', Employer_NAME = ' + @Ls_MptCur_Employer_NAME + ', InsCompanyCarrier_CODE = ' + @Lc_MptCur_InsCompanyCarrier_CODE + ', InsCompanyLocation_CODE = ' + @Lc_MptCur_InsCompanyLocation_CODE + ', Phone_NUMB = ' + @Lc_MptCur_Phone_NUMB + ', Normalization_CODE = ' + @Lc_MptCur_Normalization_CODE + ', Line1_ADDR = ' + @Ls_MptCur_Line1_ADDR + ', Line2_ADDR = ' + @Ls_MptCur_Line2_ADDR + ', City_ADDR = ' + @Lc_MptCur_City_ADDR + ', State_ADDR = ' + @Lc_MptCur_State_ADDR + ', Zip_ADDR = ' + @Lc_MptCur_Zip_ADDR + ', Process_INDC = ' + @Lc_MptCur_Process_INDC;
        SET @Ls_Sql_TEXT = 'CHECK INCOMING CARRIER CODE AND LOCATION CODE';
        SET @Ls_SqlData_TEXT = 'Carrier_CODE = ' + @Lc_MptCur_InsCompanyCarrier_CODE + ', Location_CODE = ' + @Lc_MptCur_InsCompanyLocation_CODE;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_MptCur_InsCompanyCarrier_CODE, @Lc_Empty_TEXT)))) = @Ln_Zero_NUMB
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_MptCur_InsCompanyLocation_CODE, @Lc_Empty_TEXT)))) = @Ln_Zero_NUMB
         BEGIN
          SET @Lc_BateError_CODE = @Lc_BateErrorE0958_CODE;
          SET @Ls_ErrorMessage_TEXT = 'KEY DATA NOT FOUND';

          RAISERROR(50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INCOMING PHONE #';
        SET @Ls_SqlData_TEXT = 'Phone_NUMB = ' + @Lc_MptCur_Phone_NUMB;

        IF LEN(LTRIM(RTRIM(ISNULL(@Lc_MptCur_Phone_NUMB, @Lc_Empty_TEXT)))) = @Ln_Zero_NUMB
            OR ISNUMERIC(LTRIM(RTRIM(ISNULL(@Lc_MptCur_Phone_NUMB, @Lc_Empty_TEXT)))) = 0
         BEGIN
          SET @Ln_MptCur_Phone_NUMB = @Ln_Zero_NUMB;
         END;
        ELSE
         BEGIN
          SET @Ln_MptCur_Phone_NUMB = CAST(@Lc_MptCur_Phone_NUMB AS NUMERIC);
         END;

        SET @Ls_Sql_TEXT = 'CHECK INCOMING CARRIER CODE AND LOCATION CODE EXISTS IN OTHR REFERENCE TABLE';
        SET @Ls_SqlData_TEXT = '';

        IF NOT EXISTS (SELECT 1
                         FROM OTHR_Y1 X
                        WHERE UPPER(LTRIM(RTRIM(ISNULL(X.InsCompanyCarrier_CODE, @Lc_Empty_TEXT)))) = UPPER(LTRIM(RTRIM(@Lc_MptCur_InsCompanyCarrier_CODE)))
                          AND UPPER(LTRIM(RTRIM(ISNULL(X.InsCompanyLocation_CODE, @Lc_Empty_TEXT)))) = UPPER(LTRIM(RTRIM(@Lc_MptCur_InsCompanyLocation_CODE))))
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
          SET @Ls_SqlData_TEXT = 'OtherParty_NAME = ' + LTRIM(RTRIM(@Ls_MptCur_Employer_NAME)) + ', Phone_NUMB = ' + CAST(@Ln_MptCur_Phone_NUMB AS VARCHAR) + ', Normalization_CODE = ' + LTRIM(RTRIM(@Lc_MptCur_Normalization_CODE)) + ', Line1_ADDR = ' + LTRIM(RTRIM(@Ls_MptCur_Line1_ADDR)) + ', Line2_ADDR = ' + LTRIM(RTRIM(@Ls_MptCur_Line2_ADDR)) + ', City_ADDR = ' + LTRIM(RTRIM(@Lc_MptCur_City_ADDR)) + ', State_ADDR = ' + LTRIM(RTRIM(@Lc_MptCur_State_ADDR)) + ', Zip_ADDR = ' + LTRIM(RTRIM(@Lc_MptCur_Zip_ADDR));

          EXECUTE BATCH_COMMON$SP_GET_OTHP
           @Ad_Run_DATE                     = @Ld_Run_DATE,
           @An_Fein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_TypeOthp_CODE                = @Lc_TypeOthpI_CODE,
           @As_OtherParty_NAME              = @Ls_MptCur_Employer_NAME,
           @Ac_Aka_NAME                     = @Lc_Space_TEXT,
           @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
           @As_Line1_ADDR                   =@Ls_MptCur_Line1_ADDR,
           @As_Line2_ADDR                   =@Ls_MptCur_Line2_ADDR,
           @Ac_City_ADDR                    =@Lc_MptCur_City_ADDR,
           @Ac_State_ADDR                   =@Lc_MptCur_State_ADDR,
           @Ac_Zip_ADDR                     =@Lc_MptCur_Zip_ADDR,
           @Ac_Fips_CODE                    = @Lc_Space_TEXT,
           @Ac_Country_ADDR                 = @Lc_Country_ADDR,
           @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
           @An_Phone_NUMB                   = @Ln_MptCur_Phone_NUMB,
           @An_Fax_NUMB                     = @Ln_Zero_NUMB,
           @As_Contact_EML                  = @Lc_Space_TEXT,
           @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
           @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
           @An_Sein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE               = @Lc_SourceLocMed_CODE,
           @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
           @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
           @Ac_Normalization_CODE           = @Lc_MptCur_Normalization_CODE,
           @Ac_Process_ID                   = @Lc_Job_ID,
           @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
           @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
             AND ISNULL(@Ln_OtherParty_IDNO, 0) <= @Ln_Zero_NUMB
           BEGIN
            SET @Lc_BateError_CODE = @Lc_BateErrorE0620_CODE;
            SET @Ls_ErrorMessage_TEXT = 'OTHER PARTY ID RETURNED FROM OTHP IS INVALID';

            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'INSERT OTHR REFERENCE TABLE';
          SET @Ls_SqlData_TEXT = 'Carrier_CODE = ' + @Lc_MptCur_InsCompanyCarrier_CODE + ', Location_CODE = ' + @Lc_MptCur_InsCompanyLocation_CODE + ', OtherParty_IDNO = ' + CAST(@Ln_OtherParty_IDNO AS VARCHAR);

          INSERT INTO OTHR_Y1
                      (InsCompanyCarrier_CODE,
                       InsCompanyLocation_CODE,
                       OtherParty_IDNO)
               VALUES ( @Lc_MptCur_InsCompanyCarrier_CODE,
                        @Lc_MptCur_InsCompanyLocation_CODE,
                        @Ln_OtherParty_IDNO );

          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'INSERT INTO OTHR_Y1 FAILED';

            RAISERROR(50001,16,1);
           END;
         END;
       END TRY

       BEGIN CATCH
        IF XACT_STATE() = 1
         BEGIN
          ROLLBACK TRANSACTION SAVE_PROCESS_MEDICAID_INS;
         END
        ELSE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

          RAISERROR(50001,16,1);
         END

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
         @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
         @An_Error_NUMB            = @Ln_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
        SET @Ls_SqlData_TEXT = '';

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_RecordCount_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;

        IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
         BEGIN
          SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
         END
       END CATCH;

       SET @Ls_Sql_TEXT = 'UPDATE LIPRO_Y1';
       SET @Ls_SqlData_TEXT = 'Seq_IDNO : ' + CAST(@Ln_MptCur_Seq_IDNO AS VARCHAR);

       UPDATE LIPRO_Y1
          SET Process_INDC = @Lc_ProcessY_INDC
        WHERE Seq_IDNO = @Ln_MptCur_Seq_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LIPRO_Y1 FAILED';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
       SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

       IF @Ln_CommitFreq_QNTY <> 0
          AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_MEDICAID_INS';
         SET @Ls_SqlData_TEXT = '';

         COMMIT TRANSACTION TXN_PROCESS_MEDICAID_INS;

         SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
         SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_MEDICAID_INS';
         SET @Ls_SqlData_TEXT = '';

         BEGIN TRANSACTION TXN_PROCESS_MEDICAID_INS;

         SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_CommitFreq_QNTY = 0;
        END;

       SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
       SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         COMMIT TRANSACTION TXN_PROCESS_MEDICAID_INS;

         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
         SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Mpt_CUR - 2';
       SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

       FETCH NEXT FROM Mpt_CUR INTO @Ln_MptCur_Seq_IDNO, @Ls_MptCur_Employer_NAME, @Lc_MptCur_InsCompanyCarrier_CODE, @Lc_MptCur_InsCompanyLocation_CODE, @Lc_MptCur_Phone_NUMB, @Lc_MptCur_Normalization_CODE, @Ls_MptCur_Line1_ADDR, @Ls_MptCur_Line2_ADDR, @Lc_MptCur_City_ADDR, @Lc_MptCur_State_ADDR, @Lc_MptCur_Zip_ADDR, @Lc_MptCur_Process_INDC;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     SET @Ls_Sql_TEXT = 'CLOSE Mpt_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE Mpt_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Mpt_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE Mpt_CUR;
    END;
   ELSE
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_MEDICAID_INS';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_PROCESS_MEDICAID_INS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_MEDICAID_INS;
    END;

   IF CURSOR_STATUS('Local', 'Mpt_CUR') IN (0, 1)
    BEGIN
     CLOSE Mpt_CUR;

     DEALLOCATE Mpt_CUR;
    END;

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
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
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
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
