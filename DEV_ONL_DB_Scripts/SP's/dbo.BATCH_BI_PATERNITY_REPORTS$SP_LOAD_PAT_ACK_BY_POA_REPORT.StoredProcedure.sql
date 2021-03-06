/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_PAT_ACK_BY_POA_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_PAT_ACK_BY_POA_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get all the places an acknowledgment can be signed and how many acknowledgments have been filed with that place of acknowledgment, 
					  number of acknowledgments that have been matched a child, and average days to file for the given place for the particular month.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_PAT_ACK_BY_POA_REPORT]
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Li_One_NUMB				INT = 1,
			@Li_Zero_NUMB               INT = 0,
			@Li_RowCount_QNTY			INT = 0,
			@Lc_Space_TEXT              CHAR(1) = ' ',
			@Lc_TypeError_CODE			CHAR(1) = 'E',
			@Lc_StatusFailedF_CODE      CHAR(1) = 'F',
			@Lc_StatusSuccessS_CODE		CHAR(1) = 'S',
			@Lc_No_INDC					CHAR(1) = 'N',
			@Lc_Yes_INDC				CHAR(1)	= 'Y',
			@Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
			@Lc_DayDifferent_TEXT		CHAR(1) = 'D',
			@Lc_TypeDocumentVAP_CODE	CHAR(3) = 'VAP',
			@Lc_BateError_CODE			CHAR(5) = 'E0944',
			@Lc_DateFormatYyyymm_CODE	CHAR(6) = 'YYYYMM',
			@Lc_Job_ID                  CHAR(7) = 'DEB0025',
			@Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH', 
			@Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_PAT_ACK_BY_POA_REPORT',
			@Ls_Process_NAME            VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS',
			@Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Ld_Low_DATE				DATE = '01/01/0001',
			@Ld_High_DATE				DATE = '12/31/9999';
			
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
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END
    
    BEGIN TRANSACTION PATACK_LOAD;
     
  	SET @Ls_Sql_TEXT   = 'DELETE BPPOA_Y1';
  	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');  
  	     
    DELETE FROM BPPOA_Y1;
 
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 	 
 	 SET @Ls_Sql_TEXT   = 'INSERT INTO BPPOA_Y1 TABLE';
 	 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
 	 
 	 INSERT INTO BPPOA_Y1(
 					PlaceOfAck_CODE,
 					PlaceOfAck_NAME,
 					TotalAcks_NUMB,
 					TotalMatchedAcks_NUMB,
 					AverageDaysToFileAck_NUMB,
 					Generate_DATE,
 					TransactionEventSeq_NUMB)
 	  SELECT x.PlaceOfAck_CODE,
 			 x.PlaceOfAck_NAME,
 			 x.TotalRecord_NUMB AS TotalAcks_NUMB,
 			 x.MatchedRecord_NUMB AS TotalMatchedAcks_NUMB,
 			 x.AverageDaysToFileAck_NUMB,
		     @Ld_Current_DATE AS Generate_DATE, 
		     ROW_NUMBER() OVER(ORDER BY PlaceOfAck_CODE) AS TransactionEventSeq_NUMB
	   FROM(
			SELECT x.PlaceOfAck_CODE,
				   x.PlaceOfAck_NAME,
				   COUNT(1) AS TotalRecord_NUMB,
				   SUM(CASE WHEN DerivedEndValidity_Date != @Ld_Low_DATE THEN @Li_One_NUMB ELSE @Li_Zero_NUMB END) AS MatchedRecord_NUMB,
		           SUM(Days_NUMB)/COUNT(1) AS AverageDaysToFileAck_NUMB
		      FROM(
					SELECT x.ChildBirthCertificate_ID,
						   X.PlaceOfAck_CODE,
						   X.PlaceOfAck_NAME,
						   X.DerivedBeginValidity_DATE,
						   X.DerivedEndValidity_Date,
						   X.ValidRecord_INDC,
						   X.Signature_DATE,
						   dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF (@Lc_DayDifferent_TEXT, Signature_DATE, DerivedBeginValidity_DATE) Days_NUMB
					  FROM(
							SELECT DISTINCT x.ChildBirthCertificate_ID, 
										    PlaceOfAck_CODE,
										    PlaceOfAck_NAME, 
										    MAX(CASE 
													WHEN x.IndFirst_Record = @Li_One_NUMB 
														THEN x.BeginValidity_DATE 
															END) 
											OVER(PARTITION BY ChildBirthCertificate_ID)DerivedBeginValidity_DATE,
											MAX(CASE 
													WHEN x.IndLast_Record = @Li_One_NUMB 
														THEN x.Match_DATE
															END) 
											OVER(PARTITION BY x.ChildBirthCertificate_ID)DerivedEndValidity_Date ,
											ValidRecord_INDC,
											 CASE WHEN MotherSignature_DATE > FatherSignature_DATE 
												 THEN MotherSignature_DATE
							 						 ELSE FatherSignature_DATE
											END  Signature_DATE 
							  FROM (  
									 SELECT x.ChildBirthCertificate_ID,
											x.PlaceOfAck_CODE,
											x.PlaceOfAck_NAME,
											x.BeginValidity_DATE,
											x.Match_DATE,
											x.TransactionEventSeq_NUMB,
											x.ValidRecord_INDC,
											x.MotherSignature_DATE,
											x.FatherSignature_DATE,
											ROW_NUMBER() OVER(PARTITION BY ChildBirthCertificate_ID ORDER BY TransactionEventSeq_NUMB) AS IndFirst_Record,
											ROW_NUMBER() OVER(PARTITION BY ChildBirthCertificate_ID ORDER BY TransactionEventSeq_NUMB DESC) AS IndLast_Record                                                                        
									   FROM(
											 SELECT v.ChildBirthCertificate_ID,
													v.PlaceOfAck_CODE,
													(
													  SELECT z.DescriptionValue_TEXT 
													    FROM REFM_Y1 z
													   WHERE z.Table_ID = 'VAPP'
														 AND z.TableSub_ID = 'PLOA'
														 AND z.Value_CODE = v.PlaceOfAck_CODE) AS PlaceOfAck_NAME,
													v.BeginValidity_DATE,
													v.Match_DATE,
													v.TransactionEventSeq_NUMB, 
													@Lc_Yes_INDC AS ValidRecord_INDC,
													v.MotherSignature_DATE,
													v.FatherSignature_DATE 
											   FROM VAPP_Y1 v
											  WHERE v.TypeDocument_CODE = @Lc_TypeDocumentVAP_CODE 
											UNION
											 SELECT h.ChildBirthCertificate_ID,
													h.PlaceOfAck_CODE,
													(
													  SELECT z.DescriptionValue_TEXT 
														FROM REFM_Y1 z
													   WHERE z.Table_ID = 'VAPP'
														 AND z.TableSub_ID = 'PLOA'
														 AND z.Value_CODE  = h.PlaceOfAck_CODE) AS PlaceOfAck_NAME,
													h.BeginValidity_DATE,
													h.Match_DATE,
													h.TransactionEventSeq_NUMB, 
													@Lc_No_INDC AS ValidRecord_INDC,
													h.MotherSignature_DATE,
													h.FatherSignature_DATE 
											   FROM HVAPP_Y1 h
											  WHERE h.TypeDocument_CODE = @Lc_TypeDocumentVAP_CODE 
						                  ) x
				                  ) x								   
						  ) X
					 WHERE ValidRecord_INDC = @Lc_Yes_INDC
					   AND Signature_DATE != @Ld_Low_DATE 
					   AND Signature_DATE != @Ld_High_DATE
					   AND Signature_DATE <= DerivedBeginValidity_DATE
			      ) x
		  GROUP BY x.PlaceOfAck_CODE,x.PlaceOfAck_NAME
		) x;
   
		SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF (@Li_RowCount_QNTY = 0)
      BEGIN
      SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BPPOA_Y1';
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
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
			
	 COMMIT TRANSACTION PATACK_LOAD; 
	       
END TRY 
    
BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PATACK_LOAD;
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
