/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_NCP_MOM_PAT_EST_WITH_CHILD_ON_CASE_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_NCP_MOM_PAT_EST_WITH_CHILD_ON_CASE_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get all the dependents whose NCP relationship as mother with paternity status established and the dependent present in only 1 case in DECSS as of the particular month.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_NCP_MOM_PAT_EST_WITH_CHILD_ON_CASE_REPORT]
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Li_One_NUMB                        INT	= 1,
			@Li_RowCount_QNTY					INT = 0,
			@Li_Zero_NUMB                       INT = 0,
			@Lc_CaseRelationshipD_CODE			CHAR(1) = 'D',
			@Lc_Space_TEXT                      CHAR(1) = ' ',
			@Lc_TypeError_CODE					CHAR(1) = 'E',
			@Lc_StatusEstablishE_CODE			CHAR(1) = 'E',
			@Lc_StatusFailedF_CODE				CHAR(1) = 'F',
			@Lc_StatusSuccessS_CODE				CHAR(1) = 'S',
			@Lc_CaseMemberStatusA_CODE          CHAR(1) = 'A',
			@Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
			@Lc_RelationshipToChildMTR_CODE		CHAR(3) = 'MTR',
			@Lc_BateError_CODE					CHAR(5) = 'E0944',
			@Lc_DateFormatYyyymm_CODE			CHAR(6) = 'YYYYMM',
			@Lc_Job_ID							CHAR(7) = 'DEB0029',
			@Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
			@Ls_Procedure_NAME					VARCHAR(100) = 'SP_LOAD_NCP_MOM_PAT_EST_WITH_CHILD_ON_CASE_REPORT',
			@Ls_Process_NAME                    VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS',
			@Ld_Current_DATE					DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
			
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
    
    BEGIN TRANSACTION PATCHILD_LOAD;
    
  	SET @Ls_Sql_TEXT   = 'DELETE BNPEC_Y1';
  	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');  
  	     
    DELETE FROM BNPEC_Y1;
 
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 	 
 	 SET @Ls_Sql_TEXT   = 'INSERT INTO BNPEC_Y1 TABLE';
 	 SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ld_Current_DATE AS VARCHAR ),'');
 	 
 	 INSERT INTO BNPEC_Y1(
 					Case_IDNO,
 					ChildMemberMci_IDNO,
 					ChildLast_NAME,
					ChildFirst_NAME,
					ChildBirth_DATE,
					BornOfMarriage_CODE,
 					PaternityStatus_CODE,
 					Intergovernmental_CODE,
 					ResponsibleWorker_ID,
 					Generate_DATE,
 					TransactionEventSeq_NUMB)
    SELECT m.Case_IDNO,
			d.MemberMci_IDNO,
			d.Last_NAME,
			d.First_NAME,
			d.Birth_DATE,
			p.BornOfMarriage_CODE,
			p.StatusEstablish_CODE AS PaternityStatus_CODE,
			c.RespondInit_CODE AS Intergovernmental_CODE,
			c.Worker_ID AS ResponsibleWorker_ID, 
			@Ld_Current_DATE AS Generate_DATE,  --
			ROW_NUMBER() OVER(ORDER BY m.Case_IDNO,d.MemberMci_IDNO) AS TransactionEventSeq_NUMB  
       FROM CMEM_Y1 m JOIN DEMO_Y1 d
         ON d.MemberMci_IDNO = m.MemberMci_IDNO
       JOIN CASE_Y1 c
         ON c.Case_IDNO = m.Case_IDNO
       JOIN MPAT_Y1 p
         ON p.MemberMci_IDNO = m.MemberMci_IDNO
	  WHERE m.CaseRelationship_CODE		  = @Lc_CaseRelationshipD_CODE
	    AND m.CaseMemberStatus_CODE       = @Lc_CaseMemberStatusA_CODE
		AND m.NcpRelationshipToChild_CODE = @Lc_RelationshipToChildMTR_CODE
		AND m.MemberMci_IDNO IN (  
								 SELECT t.MemberMci_IDNO
								   FROM MPAT_Y1 t
								  WHERE t.StatusEstablish_CODE = @Lc_StatusEstablishE_CODE
							    )
	    AND (SELECT COUNT(n.Case_IDNO) 
			   FROM CMEM_Y1 n
			  WHERE m.MemberMci_IDNO = n.MemberMci_IDNO
		    ) = @Li_One_NUMB;
		    
   SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF (@Li_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BNPEC_Y1';
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

	    COMMIT TRANSACTION PATCHILD_LOAD;
	        
END TRY 
    
BEGIN CATCH

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PATCHILD_LOAD;
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
