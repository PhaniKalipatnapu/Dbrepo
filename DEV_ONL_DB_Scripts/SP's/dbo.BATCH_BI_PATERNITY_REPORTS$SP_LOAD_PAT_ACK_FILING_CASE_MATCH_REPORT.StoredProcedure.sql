/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_PAT_ACK_FILING_CASE_MATCH_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_PAT_ACK_FILING_CASE_MATCH_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get the number of paternity acknowledgments in DECSS and the time it takes to find a match to a child in DECSS upto the particular month.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_PAT_ACK_FILING_CASE_MATCH_REPORT]
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Li_One_NUMB                INT = 1,
			@Li_Zero_NUMB               INT = 0,
			@Li_RowCount_QNTY			INT = 0,
			@Lc_Space_TEXT              CHAR(1) = ' ',
			@Lc_TypeError_CODE			CHAR(1) = 'E',
			@Lc_StatusFailedF_CODE      CHAR(1) = 'F',
			@Lc_StatusSuccessS_CODE		CHAR(1) = 'S',
			@Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
			@Lc_TypeDocumentVAP_CODE	CHAR(3) = 'VAP',
			@Lc_BateError_CODE			CHAR(5) = 'E0944',
			@Lc_DateFormatYyyymm_CODE	CHAR(6) = 'YYYYMM',
			@Lc_Job_ID                  CHAR(7) = 'DEB0022',
			@Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT       CHAR(30) = 'BATCH',
			@Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_PAT_ACK_FILING_CASE_MATCH_REPORT',
			@Ls_Process_NAME            VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS',
			@Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Ld_Low_DATE				DATE = '01/01/0001';
			
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
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END
      
    BEGIN TRANSACTION PATCASEMATCH_LOAD;
      
  	SET @Ls_Sql_TEXT   = 'DELETE BPACM_Y1';
  	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');  
  	     
    DELETE FROM BPACM_Y1;
 
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 	 
 	 SET @Ls_Sql_TEXT   = 'INSERT INTO BPACM_Y1 TABLE';
 	 SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ln_RunDate_NUMB AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(1 AS VARCHAR),'');
 	 
 	 INSERT INTO BPACM_Y1(
 					UnMatchNoOfOccurencesAck_NUMB,
 					UnMatchPercentageOfAllAck_NUMB,
 					NoOfOccurencesAck0To12_NUMB,
 					NoOfOccurencesAck13To24_NUMB,
 					NoOfOccurencesAck25To36_NUMB,
 					NoOfOccurencesAck37To48_NUMB,
 					NoOfOccurencesAckGreater48_NUMB,
 					PercentageOfAllAck0TO12_NUMB,
 					PercentageOfAllAck13TO24_NUMB,
 					PercentageOfAllAck25TO36_NUMB,
 					PercentageOfAllAck37TO48_NUMB,
 					PercentageOfAllAckGreater48_NUMB,
 					AverageTimeToMatch0To12_NUMB,
 					AverageTimeToMatch13To24_NUMB,
 					AverageTimeToMatch25To36_NUMB,
 					AverageTimeToMatch37To48_NUMB,
 					AverageTimeToMatchGreater48_NUMB,
 					Generate_DATE,
 					TransactionEventSeq_NUMB)
      SELECT UnMatchNoOfOccurencesAck_NUMB,
             UnMatchPercentageOfAllAck_NUMB,
			 NoOfOccurencesAck0To12_NUMB,
			 NoOfOccurencesAck13To24_NUMB,
			 NoOfOccurencesAck25To36_NUMB,
			 NoOfOccurencesAck37To48_NUMB,
			 NoOfOccurencesAckGreater48_NUMB,
			(cast(NoOfOccurencesAck0To12_NUMB as float)/TotalRecord_QNTY) * 100 AS PercentageOfAllAck0TO12_NUMB,
			(cast(NoOfOccurencesAck13To24_NUMB as float)/TotalRecord_QNTY) * 100 AS PercentageOfAllAck13TO24_NUMB,
			(cast(NoOfOccurencesAck25To36_NUMB as float)/TotalRecord_QNTY) * 100 AS PercentageOfAllAck25TO36_NUMB,
			(cast(NoOfOccurencesAck37To48_NUMB as float)/TotalRecord_QNTY) * 100 AS PercentageOfAllAck37TO48_NUMB,
			(cast(NoOfOccurencesAckGreater48_NUMB as float)/TotalRecord_QNTY) * 100 AS PercentageOfAllAckGreater48_NUMB,
			CASE WHEN NoOfOccurencesAck0To12_NUMB = 0 THEN 0 ELSE (SumOfOccurencesAck0To12_NUMB/NoOfOccurencesAck0To12_NUMB) END AverageTimeToMatch0To12_NUMB,
			CASE WHEN NoOfOccurencesAck13To24_NUMB = 0 THEN 0 ELSE (SumOfOccurencesAck13To24_NUMB/NoOfOccurencesAck13To24_NUMB)END AverageTimeToMatch13To24_NUMB,
			CASE WHEN NoOfOccurencesAck25To36_NUMB = 0 THEN 0 ELSE (SumOfOccurencesAck25To36_NUMB/NoOfOccurencesAck25To36_NUMB) END AverageTimeToMatch25To36_NUMB,
			CASE WHEN NoOfOccurencesAck37To48_NUMB = 0 THEN 0 ELSE (SumOfOccurencesAck37To48_NUMB/NoOfOccurencesAck37To48_NUMB)END AverageTimeToMatch37To48_NUMB,
			CASE WHEN NoOfOccurencesAckGreater48_NUMB = 0 THEN 0 ELSE (SumOfOccurencesAckGreater48_NUMB/NoOfOccurencesAckGreater48_NUMB)END AverageTimeToMatchGreater48_NUMB,
			@Ld_Current_DATE AS Generate_DATE,
			1 AS TransactionEventSeq_NUMB
       FROM(
      SELECT DISTINCT UnMatchNoOfOccurencesAck_NUMB,
             (cast(UnMatchNoOfOccurencesAck_NUMB as float)/TotalRecord_QNTY)*100 AS UnMatchPercentageOfAllAck_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 0 AND 12 THEN  @Li_One_NUMB ELSE @Li_Zero_NUMB END)OVER() AS NoOfOccurencesAck0To12_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 13 AND 24 THEN @Li_One_NUMB ELSE @Li_Zero_NUMB END)OVER() AS NoOfOccurencesAck13To24_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 25 AND 36 THEN @Li_One_NUMB ELSE @Li_Zero_NUMB END)OVER() AS NoOfOccurencesAck25To36_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 37 AND 48 THEN @Li_One_NUMB ELSE @Li_Zero_NUMB END)OVER() AS NoOfOccurencesAck37To48_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB > 48 THEN @Li_One_NUMB ELSE @Li_Zero_NUMB END)OVER() AS NoOfOccurencesAckGreater48_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 0  AND 12 THEN MonthsTakenToMatch_NUMB ELSE @Li_Zero_NUMB END)OVER() AS SumOfOccurencesAck0To12_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 13 AND 24 THEN MonthsTakenToMatch_NUMB ELSE @Li_Zero_NUMB END)OVER() AS SumOfOccurencesAck13To24_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 25 AND 36 THEN MonthsTakenToMatch_NUMB ELSE @Li_Zero_NUMB END)OVER() AS SumOfOccurencesAck25To36_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB BETWEEN 37 AND 48 THEN MonthsTakenToMatch_NUMB ELSE @Li_Zero_NUMB END)OVER() AS SumOfOccurencesAck37To48_NUMB,
             SUM(CASE WHEN MonthsTakenToMatch_NUMB > 48 THEN MonthsTakenToMatch_NUMB ELSE @Li_Zero_NUMB END)OVER() AS SumOfOccurencesAckGreater48_NUMB,
			 TotalRecord_QNTY
	FROM(
		SELECT x.TotalRecord_QNTY,
			   x.MonthsTakenToMatch_NUMB,
			   x.DerivedEndValidity_Date,
			   x.UnMatchNoOfOccurencesAck_NUMB, 
			   COUNT(1) OVER() AS total_without_low_date
	      FROM(  
				SELECT COUNT(1) OVER() AS  TotalRecord_QNTY,	
					   ROUND(dbo.BATCH_COMMON_SCALAR$SF_MONTHS_BETWEEN (DerivedBeginValidity_DATE ,DerivedEndValidity_Date),0) AS MonthsTakenToMatch_NUMB,
					   DerivedEndValidity_Date,
                       SUM(CASE 
							WHEN DerivedEndValidity_Date =  @Ld_Low_DATE
                                THEN 1
                            ELSE 0
								END) OVER() AS UnMatchNoOfOccurencesAck_NUMB 
				  FROM(
						SELECT DISTINCT x.ChildBirthCertificate_ID, 
										MAX(CASE 
												WHEN x.IndFirst_Record = @Li_One_NUMB 
													THEN x.BeginValidity_DATE 
														END) 
										OVER(PARTITION BY ChildBirthCertificate_ID)DerivedBeginValidity_DATE,
										MAX(CASE 
												WHEN x.IndLast_Record = @Li_One_NUMB 
													THEN x.Match_DATE
														END) 
										OVER(PARTITION BY x.ChildBirthCertificate_ID)DerivedEndValidity_Date 
					      FROM(  
								SELECT x.ChildBirthCertificate_ID,
									   x.BeginValidity_DATE,
									   x.Match_DATE,
									   x.TransactionEventSeq_NUMB,
									   ROW_NUMBER() OVER(PARTITION BY ChildBirthCertificate_ID ORDER BY TransactionEventSeq_NUMB) IndFirst_Record,
									   ROW_NUMBER() OVER(PARTITION BY ChildBirthCertificate_ID ORDER BY TransactionEventSeq_NUMB DESC) IndLast_Record                                                                        
							      FROM(
										SELECT v.ChildBirthCertificate_ID,
											   v.BeginValidity_DATE,
											   v.Match_DATE,
											   v.TransactionEventSeq_NUMB 
									      FROM VAPP_Y1 v
     								     WHERE v.TypeDocument_CODE = @Lc_TypeDocumentVAP_CODE 
									  UNION
									    SELECT h.ChildBirthCertificate_ID,
											   h.BeginValidity_DATE,
											   h.Match_DATE,
											   h.TransactionEventSeq_NUMB 
							              FROM HVAPP_Y1 h
									     WHERE h.TypeDocument_CODE = @Lc_TypeDocumentVAP_CODE 
						            ) x
				           ) x
		           ) x
           ) x
      WHERE DerivedEndValidity_Date != @Ld_Low_DATE
) x
) x;

	 SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF (@Li_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BPACM_Y1';
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

	  COMMIT TRANSACTION PATCASEMATCH_LOAD;      
END TRY 
    
BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PATCASEMATCH_LOAD;
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
