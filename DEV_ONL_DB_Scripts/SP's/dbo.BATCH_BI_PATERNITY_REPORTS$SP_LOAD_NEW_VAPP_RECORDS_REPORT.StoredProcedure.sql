/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_NEW_VAPP_RECORDS_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_NEW_VAPP_RECORDS_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get the new vap records for the particular month.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_NEW_VAPP_RECORDS_REPORT]
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Li_RowCount_QNTY			INT = 0,
			@Li_Zero_NUMB               INT = 0,
			@Lc_Space_TEXT              CHAR(1) = ' ',
			@Lc_StatusFailedF_CODE      CHAR(1) = 'F',
			@Lc_TypeError_CODE			CHAR(1) = 'E',
			@Lc_StatusSuccessS_CODE		CHAR(1) = 'S',
			@Lc_StatusAbnormalend_CODE	CHAR(1) = 'A',
			@Lc_BateError_CODE			CHAR(5) = 'E0944',
			@Lc_DateFormatYyyymm_CODE	CHAR(6) = 'YYYYMM',
			@Lc_Job_ID                  CHAR(7) = 'DEB0020',
			@Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH', 
			@Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_NEW_VAPP_RECORDS_REPORT',
			@Ls_Process_NAME            VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS',
			@Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
			
	DECLARE @Ln_CommitFreq_QNTY             NUMERIC(5),
            @Ln_ExceptionThresholdParm_QNTY	NUMERIC(5),
			@Ln_RunDate_NUMB				NUMERIC(6,0),
			@Ln_Error_NUMB					NUMERIC(11),
            @Ln_ErrorLine_NUMB				NUMERIC(11),
            @Lc_Msg_CODE                    CHAR(5),
            @Ls_Sql_TEXT					VARCHAR(100),
            @Ls_Sqldata_TEXT				VARCHAR(200),
            @Ls_ErrorMessage_TEXT			VARCHAR(2000),
            @Ls_DescriptionError_TEXT		VARCHAR(4000),
            @Ld_Run_DATE					DATE,
            @Ld_LastRun_DATE				DATE,
            @Ld_Start_DATE					DATETIME2;
            
    BEGIN TRY
    
    SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
    
    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');

	EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' +  CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END
       
  BEGIN TRANSACTION NEWVAPP_LOAD;
       
  	SET @Ls_Sql_TEXT   = 'DELETE BNVAP_Y1';
  	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');  
  	     
    DELETE FROM BNVAP_Y1;
 
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 	 
 	 SET @Ls_Sql_TEXT   = 'INSERT INTO BNVAP_Y1 TABLE';
 	 SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ld_Current_DATE AS VARCHAR ),'');
 	 
    INSERT INTO BNVAP_Y1(
				 ChildBirthCertificate_ID,
				 ChildLast_NAME,
				 ChildFirst_NAME,
				 ChildBirth_DATE,
				 MotherLast_NAME,
				 MotherFirst_NAME,
				 MotherBirth_DATE,
				 FatherLast_NAME,
				 FatherFirst_NAME,
				 FatherBirth_DATE,
				 Entered_DATE,
				 ResponsibleWorker_ID,
				 RecordType_CODE,
 	             Generate_DATE,
 	             TransactionEventSeq_NUMB)	
 	SELECT A.ChildBirthCertificate_ID,
		   A.ChildLast_NAME,
		   A.ChildFirst_NAME,
           A.ChildBirth_DATE,
           A.MotherLast_NAME,
           A.MotherFirst_NAME,
           A.MotherBirth_DATE,
           A.FatherLast_NAME,
           A.FatherFirst_NAME,
           A.FatherBirth_DATE,
           A.Entered_DATE,
           A.ResponsibleWorker_ID,
           A.RecordType_CODE,
           A.Generate_DATE,
           ROW_NUMBER() OVER(ORDER BY A.ChildBirthCertificate_ID,A.RecordType_CODE) AS TransactionEventSeq_NUMB		 
	  FROM (SELECT V.ChildBirthCertificate_ID,
			   V.ChildLast_NAME,
			   V.ChildFirst_NAME,
			   V.ChildBirth_DATE,
			   V.MotherLast_NAME,
			   V.MotherFirst_NAME,
			   V.MotherBirth_DATE,
			   V.FatherLast_NAME,
			   V.FatherFirst_NAME,
			   V.FatherBirth_DATE,
			   ISNULL(H.BeginValidity_DATE,V.BeginValidity_DATE) Entered_DATE,
			   ISNULL(H.WorkerUpdate_ID,V.WorkerUpdate_ID) ResponsibleWorker_ID,
			   V.TypeDocument_CODE  AS RecordType_CODE,
			   @Ld_Current_DATE AS Generate_DATE,
			   CASE WHEN H.BeginValidity_DATE IS NULL 
					THEN 1
				    ELSE ROW_NUMBER() OVER(PARTITION BY H.ChildBirthCertificate_ID ORDER BY H.BeginValidity_DATE) 
			   END Row_NUMB
		FROM VAPP_Y1 V
		LEFT OUTER JOIN HVAPP_Y1 H 
		ON V.ChildBirthcertificate_ID = H.ChildBirthcertificate_ID ) A
	WHERE A.Row_NUMB = 1
	  AND CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(A.Entered_DATE,@Lc_DateFormatYyyymm_CODE) AS NUMERIC) = @Ln_RunDate_NUMB;
					 
	SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF (@Li_RowCount_QNTY = 0)
      BEGIN
      SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BNVAP_Y1';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Line_NUMB = ' + ISNULL(CAST( @Li_RowCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Li_RowCount_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        
			IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
			BEGIN
			SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_BATE_LOG FAILED';
			RAISERROR(50001,16,1);
			END 
        
      END 
		
		SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
     RAISERROR(50001,16,1);
    END
    
    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';

		   EXECUTE BATCH_COMMON$SP_BSTL_LOG
			@Ad_Run_DATE              = @Ld_Run_DATE,
			@Ad_Start_DATE            = @Ld_Start_DATE,
			@Ac_Job_ID                = @Lc_Job_ID,
			@As_Process_NAME          = @Ls_Process_NAME,
			@As_Procedure_NAME        = @Ls_Procedure_NAME,
			@As_CursorLocation_TEXT   = @Lc_Space_TEXT,
			@As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
			@As_ListKey_TEXT          = @Lc_Successful_TEXT,
			@As_DescriptionError_TEXT = @Lc_Space_TEXT,
			@Ac_Status_CODE           = @Lc_StatusSuccessS_CODE,
			@Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
			@An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;
			
	COMMIT TRANSACTION NEWVAPP_LOAD;        
END TRY 
    
BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NEWVAPP_LOAD;
    END

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
      @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
      @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
      @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
      @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
      @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
      @An_ProcessedRecordCount_QNTY = @Li_Zero_NUMB;
      
	  RAISERROR (@Ls_DescriptionError_TEXT,16,1);
   END CATCH;
					  
END;
GO
