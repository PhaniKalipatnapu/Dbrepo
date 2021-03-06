/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_EIWO$SP_PROCESS_EIWO_SETUP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_EIWO$SP_PROCESS_EIWO_SETUP
Programmer Name	:	IMP Team.
Description		:	The batch procedure reads the employers enrolled to process income withholdings electronically from the temporary table and 
					updates the electronic IWO indicator in the system
Frequency		:	
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS ,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_UPDATE_PARM_DATE,
                    BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_EIWO$SP_PROCESS_EIWO_SETUP]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_FetchStatus_QNTY       SMALLINT = 0,
          @Li_RowsCount_QNTY         SMALLINT = 0,
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_EmployerOthpType_CODE  CHAR(1) = 'E',
          @Lc_EmployerInsures_CODE   CHAR(1) = 'I',
          @Lc_PensionOthp_CODE       CHAR(1) = 'P',
          @Lc_SocialOthp_CODE        CHAR(1) = 'S',
          @Lc_SuccessStatus_CODE     CHAR(1) = 'S',
          @Lc_WorkerOthpType_CODE    CHAR(1) = 'W',
          @Lc_TypeErrorW_CODE        CHAR(1) = 'W',
          @Lc_UnionsOthpType_CODE    CHAR(1) = 'U',
          @Lc_MilitaryOthpType_CODE  CHAR(1) = 'M',
          @Lc_TypeErrorE_CODE        CHAR(1) = 'E',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_StatusActive_CODE      CHAR(1) = 'A',
          @Lc_StatusInActive_CODE    CHAR(1) = 'I',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE    CHAR(5) = 'E0944',
          @Lc_BateErrorE1424_CODE    CHAR(5) = 'E1424',
          @Lc_Job_ID                 CHAR(7) = 'DEB6480',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_ErrorE0944_TEXT        VARCHAR(50) = 'NO RECORDS(S) TO PROCESS',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_EIWO_SETUP',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_INCOMING_EIWO',
          @Ls_BateError_TEXT         VARCHAR(4000) = ' ',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                        NUMERIC = 0,
          @Ln_RecCount_NUMB                    NUMERIC = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC(6) = 0,
          @Ln_Error_NUMB                       NUMERIC(11),
          @Ln_ErrorLine_NUMB                   NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB         NUMERIC(19),
          @Lc_Null_TEXT                        CHAR(1) = '',
          @Lc_Msg_CODE                         CHAR(5),
          @Lc_BateError_CODE                   CHAR(5),
          @Ls_Sql_TEXT                         VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200),
          @Ls_BateRecord_TEXT                  VARCHAR(200),
          @Ls_Sqldata_TEXT                     VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(4000),
          @Ld_Run_DATE                         DATE,
          @Ld_Start_DATE                       DATETIME2,
          @Ld_LastRun_DATE                     DATETIME2;
  DECLARE @Ln_EiwoFeinCur_Fein_IDNO NUMERIC(9),
          @Lc_EiwoFeinCur_Eiwn_INDC CHAR(1);

  SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
  SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  BEGIN TRY
   -- Selecting date run, date last run, commit freq, exception threshold details --
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
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
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR(50001,16,1);
    END

   --CURSOR Declaration --CR0299 Code Fix.
   DECLARE EiwoFein_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           l.Fein_IDNO,
           CASE l.FeinStatus_CODE
            WHEN @Lc_StatusActive_CODE
             THEN @Lc_Yes_INDC
            ELSE @Lc_No_INDC
           END AS Eiwn_INDC
      FROM OTHP_Y1 o,
           LEEMP_Y1 l
     WHERE o.TypeOthp_CODE IN(@Lc_EmployerOthpType_CODE, @Lc_EmployerInsures_CODE, @Lc_SocialOthp_CODE, @Lc_WorkerOthpType_CODE,
                              @Lc_PensionOthp_CODE, @Lc_UnionsOthpType_CODE, @Lc_MilitaryOthpType_CODE)
       AND o.EndValidity_DATE = @Ld_High_DATE
       AND ISNUMERIC(l.Fein_IDNO) = 1
       AND o.Fein_IDNO = l.Fein_IDNO
       AND ((l.FeinStatus_CODE = @Lc_StatusActive_CODE
             AND o.Eiwn_INDC = @Lc_No_INDC)
             OR (l.FeinStatus_CODE = @Lc_StatusInActive_CODE
                 AND o.Eiwn_INDC = @Lc_Yes_INDC))
       AND l.Process_INDC = @Lc_No_INDC;

   BEGIN TRANSACTION EiwoEmployersTran;

   SET @Ls_Sql_TEXT = 'OPEN EiwoFein_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN EiwoFein_CUR;

   SET @Ls_Sql_TEXT = 'FETCH EiwoFein_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM EiwoFein_CUR INTO @Ln_EiwoFeinCur_Fein_IDNO, @Lc_EiwoFeinCur_Eiwn_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
     SET @Ls_BateError_TEXT = @Ls_ErrorE0944_TEXT;
    END;

   -- Cursor loop Started                                                                               
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION EiwoEmployersTranSave;

      SET @Ls_BateRecord_TEXT = 'Fein_IDNO = ' + ISNULL(CAST(@Ln_EiwoFeinCur_Fein_IDNO AS VARCHAR), '') + ', Eiwn_INDC = ' + ISNULL(@Lc_EiwoFeinCur_Eiwn_INDC, '');
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ls_CursorLocation_TEXT = 'EIWO Employers - CURSOR COUNT - ' + CAST(@Ln_RecCount_NUMB AS VARCHAR);
      -- To get the next value in the sequence                                                                                 
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
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
       END

      SET @Ls_Sql_TEXT = 'Update OTHP_Y1';
      SET @Ls_Sqldata_TEXT = 'Fein_IDNO = ' + ISNULL(CAST(@Ln_EiwoFeinCur_Fein_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

      UPDATE OTHP_Y1
         SET Eiwn_INDC = @Lc_EiwoFeinCur_Eiwn_INDC,
             BeginValidity_DATE = @Ld_Run_DATE,
             WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
             Update_DTTM = @Ld_Start_DATE,
             TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
      OUTPUT deleted.OtherParty_IDNO,
             deleted.TypeOthp_CODE,
             deleted.OtherParty_NAME,
             deleted.Aka_NAME,
             deleted.Attn_ADDR,
             deleted.Line1_ADDR,
             deleted.Line2_ADDR,
             deleted.City_ADDR,
             deleted.Zip_ADDR,
             deleted.State_ADDR,
             deleted.Fips_CODE,
             deleted.Country_ADDR,
             deleted.DescriptionContactOther_TEXT,
             deleted.Phone_NUMB,
             deleted.Fax_NUMB,
             deleted.ReferenceOthp_IDNO,
             deleted.NewOtherParty_IDNO,
             deleted.Fein_IDNO,
             deleted.Contact_EML,
             deleted.ParentFein_IDNO,
             deleted.InsuranceProvided_INDC,
             deleted.Sein_IDNO,
             deleted.County_IDNO,
             deleted.DchCarrier_IDNO,
             deleted.Nsf_INDC,
             deleted.Verified_INDC,
             deleted.Note_INDC,
             deleted.Eiwn_INDC,
             deleted.Enmsn_INDC,
             deleted.NmsnGen_INDC,
             deleted.NmsnInst_INDC,
             deleted.Tribal_CODE,
             deleted.Tribal_INDC,
             deleted.BeginValidity_DATE,
             @Ld_Run_DATE AS EndValidity_DATE,
             deleted.WorkerUpdate_ID,
             deleted.Update_DTTM,
             deleted.TransactionEventSeq_NUMB,
             deleted.SendShort_INDC,
             deleted.PpaEiwn_INDC,
             deleted.DescriptionNotes_TEXT,
             deleted.Normalization_CODE,
             deleted.EportalSubscription_INDC,
             deleted.BarAtty_NUMB,
             deleted.ReceivePaperForms_INDC
      INTO OTHP_Y1
       WHERE Fein_IDNO = @Ln_EiwoFeinCur_Fein_IDNO
         AND TypeOthp_CODE IN(@Lc_EmployerOthpType_CODE, @Lc_EmployerInsures_CODE, @Lc_SocialOthp_CODE, @Lc_WorkerOthpType_CODE,
                              @Lc_PensionOthp_CODE, @Lc_UnionsOthpType_CODE, @Lc_MilitaryOthpType_CODE)
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Li_RowsCount_QNTY = @@ROWCOUNT;

      IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE OTHP_Y1 FAILED';
        SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;

        RAISERROR(50001,16,1);
       END
     END TRY

     BEGIN CATCH
      -- Committable transaction checking and Rolling back Save point
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EiwoEmployersTranSave
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      -- Check for Exception information to log the description text based on the error
      SET @Ln_Error_NUMB = ERROR_NUMBER ();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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

      SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_CommitFreq_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LEEMP_Y1';
     SET @Ls_Sqldata_TEXT = 'Fein_IDNO = ' + ISNULL(CAST(@Ln_EiwoFeinCur_Fein_IDNO AS VARCHAR), '');

     UPDATE LEEMP_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Fein_IDNO = @Ln_EiwoFeinCur_Fein_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE LEEMP_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowsCount_QNTY;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       COMMIT TRANSACTION EiwoEmployersTran;

       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       BEGIN TRANSACTION EiwoEmployersTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_RecCount_NUMB;

       COMMIT TRANSACTION EiwoEmployersTran;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH EiwoFein_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM EiwoFein_CUR INTO @Ln_EiwoFeinCur_Fein_IDNO, @Lc_EiwoFeinCur_Eiwn_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_BateError_TEXT;
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorW_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sqldata_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE EiwoFein_CUR;

   DEALLOCATE EiwoFein_CUR;

   --Update the Process_INDC in the Load table with 'Y' for non matched records as the file is FULL volume file.
   SET @Ls_Sql_TEXT = 'UPDATE LEEMP_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE LEEMP_Y1
      SET Process_INDC = @Lc_Yes_INDC
    WHERE Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Null_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_SuccessStatus_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Null_TEXT,
    @Ac_Status_CODE               = @Lc_SuccessStatus_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION EiwoEmployersTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EiwoEmployersTran;
    END

   --Close the Cursor
   IF CURSOR_STATUS ('local', 'EiwoFein_CUR') IN (0, 1)
    BEGIN
     CLOSE EiwoFein_CUR;

     DEALLOCATE EiwoFein_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
