/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Programmer Name		 : IMP Team
Description			 : The process reads the data from temporary tables
                       and updates FCR Response Details in the system.
Frequency			 : Daily
Developed On		 : 04/6/2011
Called By			 : None
Called On			 : BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_PROACTIVE_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_FPLS_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_SVES_PRISONER
					   BATCH_LOC_INCOMING_FCR$SP_SVES_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_NDNH_UIB_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_NDNH_W4_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_NDNH_QW_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_MSFIDM_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_DMDC_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_NCOADDRESS_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS
					   BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE]
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE  @Lc_StatusFailed_CODE				CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE				CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE			CHAR(1) = 'A',
           @Lc_Job_ID							CHAR(7) = 'DEB0480',
           @Lc_Successful_TEXT					CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT				CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME					VARCHAR(60) = 'SP_PROCESS_FCR_RESPONSE',
           @Ls_Process_NAME						VARCHAR(100) = 'BATCH_LOC_INCOMING_FCR',
           @Ls_CursorLocation_TEXT				VARCHAR(200) = ' ',
           @Ls_DescriptionError_TEXT			VARCHAR(4000) = ' ';
  DECLARE  @Ln_Zero_NUMB						NUMERIC(1) = 0,
		   @Ln_CommitFreqParm_QNTY				NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY		NUMERIC(5),
           @Ln_ProcessedRecordCount_QNTY		NUMERIC(6) = 0,
           @Ln_ProcessedRecordTotalCount_QNTY	NUMERIC(6) = 0,
           @Ln_Error_NUMB						NUMERIC(11),
           @Ln_ErrorLine_NUMB					NUMERIC(11),
           @Lc_Space_TEXT						CHAR(1) = '',
           @Lc_Msg_CODE							CHAR(5),
           @Ls_Sql_TEXT							VARCHAR(100),
           @Ls_Sqldata_TEXT						VARCHAR(1000),
           @Ls_ErrorMessage_TEXT				VARCHAR(4000),
           @Ld_Run_DATE							DATE,
           @Ld_LastRun_DATE						DATE,
           @Ld_Start_DATE						DATETIME2;
  
  BEGIN TRY
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   -- Selecting the Batch Start date 
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ld_Run_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');

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
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH RUN DATE AND LAST RUN DATE ARE SAME';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');

   EXECUTE BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT; 

     RAISERROR(50001,16,1);
    END
      
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING PERSON ACK PROCESS BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');

   EXECUTE BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
      
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING PROACTIVE DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_PROACTIVE_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_PROACTIVE_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
   
   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
       
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING FPLS DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_FPLS_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_FPLS_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING SVES PRISONER DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_SVES_PRISONER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_SVES_PRISONER
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING SVES DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_SVES_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_SVES_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
    
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING NDNH UIB DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_NDNH_UIB_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_NDNH_UIB_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING NDNH W4 DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_NDNH_W4_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_NDNH_W4_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
      
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING NDNH QW DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_NDNH_QW_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_NDNH_QW_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT; 

     RAISERROR(50001,16,1);
    END
    
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING MSFIDM DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_MSFIDM_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_MSFIDM_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
     
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING DMDC DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_DMDC_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_DMDC_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
      
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING NCOA ADDRESS DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_NCOADDRESS_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_NCOADDRESS_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
  
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'CALLING INSURANCE MATCH DETAILS PROCESS BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
   EXECUTE BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE,
    @As_Process_NAME            = @Ls_Process_NAME,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END
   
   --Update the Parameter Table with the Job Run Date as the current system date
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR(50001,16,1);
    END

   -- --Update the Log in BSTL_Y1 as the Job is suceeded
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY;

   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID , '');
       
  END TRY

  BEGIN CATCH
   SET @Ln_ProcessedRecordTotalCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY + @Ln_ProcessedRecordCount_QNTY;
   
   --Set Error Description
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
  
   --Update the Log in BSTL_Y1 as the Job is failed.
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordTotalCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
