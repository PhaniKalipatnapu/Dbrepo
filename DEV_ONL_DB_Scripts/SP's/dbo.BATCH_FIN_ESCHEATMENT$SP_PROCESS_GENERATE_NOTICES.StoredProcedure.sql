/****** Object:  StoredProcedure [dbo].[BATCH_FIN_ESCHEATMENT$SP_PROCESS_GENERATE_NOTICES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 --------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_FIN_ESCHEATMENT$SP_PROCESS_GENERATE_NOTICES
 Programmer Name	: IMP Team
 Description		: This purpose of this batch is to find the receipts which are in pending escheatment status with
					  the UDC codes of 'UMPE', 'USPE' and 'SDPE' and the disbursement date is equal to or greater than
					  1825 days or five years from the batch run date and sends requests for the escheatment notice
					  generation to the funds recipient 
 Frequency			: Annually
 Developed On		: 3/22/2012
 Called By			: None
 Called On			: 
 --------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 1.0
 --------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_ESCHEATMENT$SP_PROCESS_GENERATE_NOTICES]
AS
 BEGIN
  SET NOCOUNT ON;
  
	DECLARE @Li_PendingEscheatment2270_NUMB               INT = 2270,
          @Lc_TypeErrorError_CODE						CHAR(1) = 'E',
          @Lc_ErrorTypeWarning_CODE                     CHAR(1) = 'W',
          @Lc_StatusFailed_CODE                         CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                        CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE                    CHAR(1) = 'A',
          @Lc_No_INDC                                   CHAR(1) = 'N',
          @Lc_Space_TEXT                                CHAR(1) = ' ',
          @Lc_ReasonSystemPendingEscheatment_CODE       CHAR(4) = 'USPE',
          @Lc_ReasonManualPendingEscheatment_CODE       CHAR(4) = 'UMPE',
          @Lc_SystemDisbursementPendingEscheatment_CODE CHAR(4) = 'SDPE',
          @Lc_NoRecordsToProcess_CODE                   CHAR(5) = 'E0944',
          @Lc_BateErrorUnknown_CODE						CHAR(5) = 'E1424',
          @Lc_Job_ID                                    CHAR(7) = 'DEB8600',
          @Lc_Successful_TEXT                           CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                         CHAR(30) = 'BATCH',
          @Lc_Process_NAME                              CHAR(30) = 'BATCH_FIN_ESCHEATMENT',
          @Lc_Procedure_NAME                            CHAR(30) = 'SP_PROCESS_MAKE_READY_FOR_ESCHEAT',
          @Ld_High_DATE                                 DATE = '12/31/9999',
          @Ld_Start_DATE                                DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY	  NUMERIC(5),	
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_RcthCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_DhldCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY	  NUMERIC(11)= 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_TypeError_CODE              CHAR(1),
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_BateError_CODE              CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT			  VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT		  VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_Prev5Year_DATE              DATE,
          @Ld_LastRun_DATE                DATE;
     
    DECLARE @Ln_DhldCur_Case_IDNO                  NUMERIC(6),
          @Ln_DhldCur_OrderSeq_NUMB              NUMERIC(2),
          @Ln_DhldCur_ObligationSeq_NUMB         NUMERIC(2),
          @Ld_DhldCur_Batch_DATE                 DATE,
          @Lc_DhldCur_SourceBatch_CODE           CHAR(3),
          @Ln_DhldCur_Batch_NUMB                 NUMERIC(4),
          @Ln_DhldCur_SeqReceipt_NUMB            NUMERIC(6),
          @Ln_DhldCur_Transaction_AMNT           NUMERIC(11, 2),
          @Lc_DhldCur_ProcessOffset_INDC         CHAR(1),
          @Ln_DhldCur_EventGlobalSupportSeq_NUMB NUMERIC(19),
          @Ld_DhldCur_Disburse_DATE              DATE,
          @Ln_DhldCur_DisburseSeq_NUMB           NUMERIC(4),
          @Ld_DhldCur_Transaction_DATE           DATE,
          @Ln_DhldCur_Unique_IDNO                NUMERIC(19);
  
  BEGIN TRY
   BEGIN TRANSACTION ESCHEAT;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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

   /*
	 Get the run date and last run date from Parameter (PARM_Y1) table and validate that the batch program was not 
	 executed for the run date, by ensuring that the run date is different from the last run date in the PARM_Y1 table
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;
    SET @Ld_Prev5Year_DATE = DATEADD(yy, -5, @Ld_Run_DATE);
    /*
    This process finds the receipts in DHLD_Y1 which are in pending escheatment status with the UDC codes of ‘UMPE’, ‘USPE’ and ‘SDPE’ and the disbursement date is equal to or greater than 1825 days or five years from batch run date.
    */
     DECLARE Dhld_CUR INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.Transaction_AMNT,
           a.ProcessOffset_INDC,
           a.EventGlobalSupportSeq_NUMB,
           a.Disburse_DATE,
           a.DisburseSeq_NUMB,
           a.Transaction_DATE,
           a.Unique_IDNO
      FROM DHLD_Y1 a
     WHERE a.Disburse_DATE <= @Ld_Prev5Year_DATE
		   AND a.ReasonStatus_CODE IN (@Lc_ReasonSystemPendingEscheatment_CODE,@Lc_ReasonManualPendingEscheatment_CODE,@Lc_SystemDisbursementPendingEscheatment_CODE)
           AND a.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN Dhld_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Dhld_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_ProcessOffset_INDC, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Unique_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
  
   SET @Ls_Sql_TEXT = 'WHILE-2';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '');
   --While loop for generating Notice of Escheatment
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SET @Ln_DhldCursorIndex_QNTY = @Ln_DhldCursorIndex_QNTY + 1;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_CursorLocation_TEXT = ' DhldCursorIndex_QNTY = ' + ISNULL(CAST(@Ln_DhldCursorIndex_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '');
     SET @Ls_BateRecord_TEXT ='Case_IDNO = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '');
     
     SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ DHLD_Y1';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PendingEscheatment2270_NUMB AS VARCHAR), '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '')+', Note_INDC = '+ @Lc_No_INDC + ', Worker_ID = '+ @Lc_BatchRunUser_TEXT +', Job_ID = '+@Lc_Job_ID;

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_PendingEscheatment2270_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
      
     
IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION ESCHEAT;

       BEGIN TRANSACTION ESCHEAT;
	   SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY +@Ln_DhldCursorIndex_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END
	  END TRY
	  BEGIN CATCH
	  SET @Ln_Error_NUMB = ERROR_NUMBER();
        SET @Ln_ErrorLine_NUMB = ERROR_LINE();

        IF @Ln_Error_NUMB <> 50001
         BEGIN
          SET @Lc_TypeError_CODE=@Lc_TypeErrorError_CODE;
          SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
          SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
         END

        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Lc_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = @Ln_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;
		
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
		SET @Ls_Sqldata_TEXT = 'Process_NAME = '+@Lc_Process_NAME+', Procedure_NAME = '+@Lc_Procedure_NAME+', Job_ID = '+@Lc_Job_ID+', Run_DATE = '+CAST(@Ld_Run_DATE AS VARCHAR)+', TypeError_CODE = '+@Lc_TypeError_CODE+', CursorLocation_TEXT = '+@Ls_CursorLocation_TEXT+', BateError_CODE = '+@Lc_BateError_CODE+', DescriptionError_TEXT = '+@Ls_ErrorMessage_TEXT+ ', BateRecord_TEXT = '+@Ls_BateRecord_TEXT;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Lc_Process_NAME,
         @As_Procedure_NAME           = @Lc_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
         @An_Line_NUMB                = @Ls_CursorLocation_TEXT,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END CATCH

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'REACHED THRESHOLD';

         RAISERROR (50001,16,1);
	   END
     SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR-1';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_ProcessOffset_INDC, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Unique_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Dhld_CUR;

   DEALLOCATE Dhld_CUR;

   IF @Ln_DhldCursorIndex_QNTY = 0
      AND @Ln_RcthCursorIndex_QNTY = 0
    BEGIN
	 SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_BATE_LOG 1';
	 SET @Ls_Sqldata_TEXT =' Process_NAME = '+@Lc_Process_NAME +', Procedure_NAME = '+@Lc_Procedure_NAME +', Job_ID = '+@Lc_Job_ID+', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR)+', ErrorTypeWarning_CODE = '+@Lc_ErrorTypeWarning_CODE+', RcthCursorIndex_QNTY = '+ CAST(@Ln_RcthCursorIndex_QNTY AS VARCHAR)+', @Lc_NoRecordsToProcess_CODE = '+@Lc_NoRecordsToProcess_CODE+', Sqldata_TEXT = '+@Ls_Sqldata_TEXT;
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Ln_RcthCursorIndex_QNTY,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID +', Run_DATE = ' +CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   SET @Ln_ProcessedRecordCount_QNTY =@Ln_RcthCursorIndex_QNTY +@Ln_DhldCursorIndex_QNTY;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Start_DATE = '+ CAST(@Ld_Start_DATE AS VARCHAR) + ', Run_DATE = ' +CAST(@Ld_Run_DATE AS VARCHAR) +', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = '+@Lc_Procedure_NAME+ ', Successful_TEXT = ' +@Lc_Successful_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', StatusSuccess_CODE = ' +@Lc_StatusSuccess_CODE + ', BatchRunUser_TEXT = ' +@Lc_BatchRunUser_TEXT +', Space_TEXT = '+@Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                 = @Ld_Run_DATE,
    @Ad_Start_DATE               = @Ld_Start_DATE,
    @Ac_Job_ID                   = @Lc_Job_ID,
    @As_Process_NAME             = @Lc_Process_NAME,
    @As_Procedure_NAME           = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT      = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT        = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY= @Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT             = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
    @Ac_Status_CODE              = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT;

    COMMIT TRANSACTION ESCHEAT;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ESCHEAT;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Dhld_CUR') IN (0, 1)
    BEGIN
     CLOSE Dhld_CUR;

     DEALLOCATE Dhld_CUR;
    END

   --Check for Exception information to log the description text based on the error
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH 
  
 END

GO
