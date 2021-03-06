/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_VAP_MATCH_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_VAP_MATCH_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get all the VAPP records that have been matched to a child record for the particular year.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_VAP_MATCH_REPORT]
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Li_Zero_NUMB					INT			= 0,
			@Li_RowCount_QNTY				INT			= 0,
			@Lc_Space_TEXT					CHAR(1)		= ' ',
			@Lc_TypeError_CODE				CHAR(1)		= 'E',
			@Lc_StatusFailedF_CODE			CHAR(1)		= 'F',
			@Lc_StatusSuccessS_CODE			CHAR(1)		= 'S',
			@Lc_CaseRelationshipD_CODE		CHAR(1)		= 'D',
			@Lc_StatusAbnormalend_CODE		CHAR(1)		= 'A',
			@Lc_ActivityMinorCcrct_CODE		CHAR(5)		= 'CCRCT',
			@Lc_ActivityMinorCcrce_CODE		CHAR(5)		= 'CCRCE',
			@Lc_BateError_CODE				CHAR(5)		= 'E0944',
			@Lc_DateFormatYyyymm_CODE		CHAR(6)		= 'YYYYMM',
			@Lc_Job_ID						CHAR(7)		= 'DEB0026',
			@Lc_Successful_TEXT				CHAR(20)	= 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT			CHAR(30)	= 'BATCH',
			@Ls_Procedure_NAME				VARCHAR(50)	= 'SP_LOAD_VAP_MATCH_REPORT',
			@Ls_Process_NAME				VARCHAR(50)	= 'BATCH_BI_PATERNITY_REPORTS',
			@Ld_Low_DATE					DATE		= '01/01/0001',
			@Ld_High_DATE					DATE		= '12/31/9999';
			
	DECLARE @Ln_CommitFreq_QNTY             NUMERIC(5),
            @Ln_ExceptionThresholdParm_QNTY	NUMERIC(5),
			@Ln_RunDate_NUMB				NUMERIC(6),
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
    
    BEGIN TRANSACTION VAPMATCH_LOAD;
    
  	SET @Ls_Sql_TEXT   = 'DELETE BVAPM_Y1';
  	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');  
  	     
    DELETE FROM BVAPM_Y1;
 
     SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 	 
 	 SET @Ls_Sql_TEXT   = 'INSERT INTO BVAPM_Y1 TABLE';
 	 SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');
 	 
 	 INSERT INTO BVAPM_Y1(
 					ChildMemberMci_IDNO,
					ChildLast_NAME,
					ChildFirst_NAME,
					Case_IDNO,
					ChildBirth_DATE,
					ChildMemberSsn_NUMB,
					BornOfMarriage_CODE,
 					PaternityStatus_CODE,
 					Establishment_DATE,
 					Match_DATE,
 					JournalEntry_TEXT,
 					JournalEntry_DATE,
 					ChildBirthCertificate_ID,
 					CaseStatus_CODE,
 					StatusEffective_DATE,
 					Generate_DATE,
 					TransactionEventSeq_NUMB)
	 SELECT A.ChildMemberMci_IDNO,
		    A.ChildLast_NAME,
		    A.ChildFirst_NAME,
            B.Case_IDNO,
            A.ChildBirth_DATE,
		    A.ChildMemberSsn_NUMB,
            P.BornOfMarriage_CODE,
		    P.StatusEstablish_CODE,
		    P.PaternityEst_DATE,
            A.Match_DATE,
            ISNULL(V.JournalEntry_TEXT,@Lc_Space_TEXT),
            ISNULL(V.Status_DATE,@Ld_Low_DATE) AS JournalEntry_DATE,
            P.BirthCertificate_ID AS ChildBirthCertificate_ID,
            C.StatusCase_CODE,
            C.StatusCurrent_DATE,
            @Ld_Run_DATE AS Generate_DATE,
            ROW_NUMBER() OVER(ORDER BY ChildMemberMci_IDNO) AS TransactionEventSeq_NUMB
       FROM VAPP_Y1 A
       JOIN CMEM_Y1 B
		 ON B.MemberMci_IDNO = A.ChildMemberMci_IDNO
        AND B.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
       JOIN CASE_Y1 C
		 ON B.CASE_IDNO = C.CASE_IDNO
	   JOIN MPAT_Y1 p 
         ON P.MemberMci_IDNO = A.ChildMemberMci_IDNO
       LEFT OUTER JOIN ( SELECT z.Case_IDNO, 
							(SELECT y.DescriptionActivity_TEXT 
							   FROM AMNR_Y1 y
							  WHERE y.EndValidity_DATE = @Ld_High_DATE
								AND y.ActivityMinor_CODE = z.ActivityMinor_CODE) JournalEntry_TEXT,
							z.Status_DATE  
						   FROM DMNR_Y1 z
						  WHERE z.ActivityMinor_CODE IN (@Lc_ActivityMinorCcrct_CODE,@Lc_ActivityMinorCcrce_CODE)   
						) V
        ON B.CASE_IDNO = V.CASE_IDNO
      WHERE A.Match_DATE BETWEEN DATEADD(DAY,1,DATEADD(YEAR,-1,@Ld_Run_DATE)) AND @Ld_Run_DATE;
      
	 SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF (@Li_RowCount_QNTY = 0)
      BEGIN
        SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BVAPM_Y1';
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

	    COMMIT TRANSACTION VAPMATCH_LOAD;
	        
END TRY 
    
BEGIN CATCH

  IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION VAPMATCH_LOAD;
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
