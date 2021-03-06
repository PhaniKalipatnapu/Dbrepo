/****** Object:  StoredProcedure [dbo].[BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_PAYMENT_ON_ARREARS_ADJUSTMENTS_REPORT]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_PAYMENT_ON_ARREARS_ADJUSTMENTS_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get the payment arrear adjustment amount for the particular month.
Frequency		:	
Developed On	:	4/27/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_FINANCIAL_REPORTS$SP_LOAD_PAYMENT_ON_ARREARS_ADJUSTMENTS_REPORT]
 AS
 BEGIN
 SET NOCOUNT ON;
    DECLARE @Ln_EventFunctionalSeq1010_NUMB		  NUMERIC(4,0)=1010,
            @Ln_ProcessedRecordCount_QNTY         NUMERIC(6) = 0,
            @Lc_CaseRelationshipNCP_CODE          CHAR(1) = 'A',
            @Lc_CaseRelationshipPF_CODE           CHAR(1) = 'P',
            @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
			@Lc_StatusSuccess_CODE				  CHAR(1) = 'S',
			@Lc_StatusAbnormalend_CODE            CHAR(1) = 'A',
			@Lc_Space_TEXT						  CHAR(1) = '',
			@Lc_ErrorE0664_CODE				      CHAR(5) = 'E0664',
			@Lc_DateFormatYyyymm_CODE             CHAR(6) ='YYYYMM',
            @Lc_Job_ID							  CHAR(7) = 'DEB0006',
            @Lc_Successful_TEXT                   CHAR(20) = 'SUCCESSFUL',
            @Lc_BatchRunUser_TEXT                 CHAR(30) = 'BATCH',
            @Ls_Process_NAME                      VARCHAR(100) = 'BATCH_BI_FINANCIAL_REPORTS',
            @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_LOAD_PAYMENT_ON_ARREARS_ADJUSTMENTS_REPORT',
            @Ls_CursorLocation_TEXT               VARCHAR(200) = '',
            @Ld_High_DATE                         DATE ='12/31/9999';

    DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
			@Ln_ExceptionThresholdParm_QNTY NUMERIC(5),	
			@Ln_RunDate_NUMB				NUMERIC(6,0),
			@Ln_Error_NUMB					NUMERIC(11),
			@Ln_ErrorLine_NUMB				NUMERIC(11),
			@Li_Rowcount_QNTY               SMALLINT,
			@Lc_Msg_CODE                    CHAR(5),
			@Ls_Sql_TEXT					VARCHAR(100),
			@Ls_Sqldata_TEXT				VARCHAR(200),
			@Ls_ErrorMessage_TEXT			VARCHAR(2000),
			@Ls_DescriptionError_TEXT		VARCHAR(4000),
			@Ls_BateRecord_TEXT             VARCHAR(4000),
			@Ld_Run_DATE					DATE,
			@Ld_LastRun_DATE				DATE,
			@Ld_Start_DTTM					DATETIME2;
    BEGIN TRY 
    
     SET @Ld_Start_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    
    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');

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
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END
    
     BEGIN TRANSACTION PaymentOnArrearAdjustmentTran;
     
    SET @Ls_Sql_TEXT   = 'DELETE_BPMAA_Y1';  
    
    DELETE FROM BPMAA_Y1;
    
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE) AS NUMERIC); 

 	SET @Ls_Sql_TEXT   = 'INSERT_BPMAA_Y1';  	
 	INSERT INTO BPMAA_Y1(
            Case_IDNO,
			File_ID,
			Ncp_NAME,
			ObligationKey_TEXT,
			Distribute_DATE,
			AdjustedPayment_AMNT,
			TypeAdjustment_CODE,
			Frequency_CODE,
			ReasonChange_CODE,
			WorkerUpdate_ID,
			Worker_ID,
			TransactionEventSeq_NUMB)
		SELECT A.CASE_IDNO,
			   C.FILE_ID,
			   E.Last_NAME AS NCP_NAME, 
               A.TypeDebt_CODE + CAST(A.MemberMCI_IDNO AS VARCHAR(10)) + A.FIPS_CODE AS ObligationKey_TEXT,
               A.BeginValidity_DATE AS Distribute_DATE,            
               A.ExpectToPay_AMNT AS AdjustedPayment_AMNT,
               A.ExpectToPay_CODE AS TypeAdjustment_CODE, --typedebt_code
               A.FreqPeriodic_CODE AS Frequency_CODE,
               A.ReasonChange_CODE,
               B.Worker_ID AS WorkerUpdate_ID,
               C.Worker_ID AS WORKER_ID,
               ROW_NUMBER() OVER (ORDER BY B.Worker_ID, A.BeginValidity_DATE, A.Case_IDNO) AS TransactionEventSeq_NUMB
 	 	  FROM OBLE_Y1 A
 	 	       JOIN
			   GLEV_Y1 B
			ON A.EventGlobalBeginSeq_NUMB = B.EventGlobalSeq_NUMB			   
			   JOIN
			   CASE_Y1 C
			ON A.CASE_IDNO = C.CASE_IDNO
			   JOIN
			   CMEM_Y1 D
			ON A.CASE_IDNO = D.CASE_IDNO	
			   JOIN
			   DEMO_Y1 E
			ON D.MEMBERMCI_IDNO = E.MEMBERMCI_IDNO
			   JOIN
			   OBLE_Y1 F
			ON A.CASE_IDNO           = F.CASE_IDNO
		   AND A.OrderSeq_NUMB       = F.OrderSeq_NUMB
           AND A.ObligationSeq_NUMB  = F.ObligationSeq_NUMB
           AND A.ExpectToPay_AMNT <> F.ExpectToPay_AMNT	
           AND A.EventGlobalBeginSeq_NUMB = F.EventGlobalEndSeq_NUMB
	     WHERE A.EndValidity_DATE = @Ld_High_DATE 
 	       AND @Ln_RunDate_NUMB   BETWEEN CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(A.BEGINOBLIGATION_DATE,@Lc_DateFormatYyyymm_CODE) AS NUMERIC) AND CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(A.ENDOBLIGATION_DATE,@Lc_DateFormatYyyymm_CODE) AS NUMERIC)
           AND B.EventFunctionalSeq_NUMB <> @Ln_EventFunctionalSeq1010_NUMB
           AND D.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCP_CODE, @Lc_CaseRelationshipPF_CODE);
       
           	
      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
      SET @Ln_ProcessedRecordCount_QNTY = @Li_Rowcount_QNTY;
      
 
  IF (@Li_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT BPMAA_Y1 FAILED';
       SET @Ls_BateRecord_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Li_RowCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0664_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'')+ ', Msg_CODE = ' + ISNULL(@Lc_Msg_CODE,'')+ ', DescriptionErrorOut_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_Space_TEXT,
        @An_Line_NUMB                = @Li_RowCount_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorE0664_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        
  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_BATE_LOG FAILED';
     RAISERROR(50001,16,1);
    END
        
      END 
      
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
       SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
       RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DTTM,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION PaymentOnArrearAdjustmentTran; -- 1
  END TRY

  BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PaymentOnArrearAdjustmentTran;
    END

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
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END;
GO
