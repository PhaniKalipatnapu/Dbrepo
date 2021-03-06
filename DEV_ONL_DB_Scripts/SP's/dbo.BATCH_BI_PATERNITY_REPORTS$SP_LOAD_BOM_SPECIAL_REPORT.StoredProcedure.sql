/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_BOM_SPECIAL_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_BOM_SPECIAL_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get born of marriage details of all the dependents as of the particular month.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_BOM_SPECIAL_REPORT]
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Li_One_NUMB                        INT = 1,
			@Li_Zero_NUMB                       INT = 0,
			@Li_RowCount_QNTY					INT = 0,
			@Lc_Space_TEXT                      CHAR(1) = ' ',
			@Lc_TypeError_CODE					CHAR(1) = 'E',
			@Lc_Yes_INDC						CHAR(1)	= 'Y',
			@Lc_CaseRelationshipD_CODE			CHAR(1) = 'D',
			@Lc_CaseRelationshipA_CODE			CHAR(1) = 'A',
			@Lc_CaseRelationshipP_CODE			CHAR(1) = 'P',
			@Lc_CaseRelationshipC_CODE          CHAR(1) = 'C',
			@Lc_BornOfMarriageN_CODE			CHAR(1) = 'N',
			@Lc_BornOfMarriageY_CODE			CHAR(1) = 'Y',
			@Lc_CaseMemberStatusI_CODE			CHAR(1) = 'I',
			@Lc_StatusFailedF_CODE				CHAR(1) = 'F',
			@Lc_StatusSuccessS_CODE				CHAR(1) = 'S',
			@Lc_CaseMemberStatusA_CODE          CHAR(1) = 'A',
			@Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
			@Lc_ReasonMemberStatusX_CODE        CHAR(1) = 'X',
			@Lc_RelationshipToChildMTR_CODE		CHAR(3) = 'MTR',
			@Lc_RelationshipToChildFTR_CODE		CHAR(3) = 'FTR',
			@Lc_BateError_CODE					CHAR(5) = 'E0944',
			@Lc_DateFormatYyyymm_CODE			CHAR(6) = 'YYYYMM',
			@Lc_Job_ID							CHAR(7) = 'DEB0028',
			@Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
			@Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
			@Ls_Procedure_NAME					VARCHAR(100) = 'SP_LOAD_BOM_SPECIAL_REPORT',
            @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS',
			@Ld_Current_DATE					DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			@Ld_Low_DATE						DATE = '01/01/0001',
			@Ld_High_DATE						DATE = '12/31/9999';
			
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
    
    BEGIN TRANSACTION BORNOFMARRIAGE_LOAD;
    
  	SET @Ls_Sql_TEXT   = 'DELETE BBOMA_Y1';
  	SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');  
  	     
    DELETE FROM BBOMA_Y1;
 
    SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE,@Lc_DateFormatYyyymm_CODE ) AS NUMERIC); 
 	 
 	 SET @Ls_Sql_TEXT   = 'INSERT INTO BBOMA_Y1 TABLE';
 	 SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ld_Current_DATE AS VARCHAR ),'');
 	 
 	 INSERT INTO BBOMA_Y1(
 					ChildLast_NAME,
					ChildFirst_NAME,
					ChildMemberMci_IDNO,
					ChildBirth_DATE,
					Case_IDNO,
					BornOfMarriage_CODE,
 					PaternityStatus_CODE,
 					ChildParentMarriage_DATE,
 					ChildParentDivorce_DATE,
 					ChildBirthBetweenMarrDivorce_INDC,
 					ChildBirthBeforeMarriage_INDC,
 					ChildBirthAfterDivorce_INDC,
 					ChildParentsSameLastName_INDC,
 					NcpExcluded_INDC,
 					ResponsibleWorker_ID,
 					Generate_DATE,
 					TransactionEventSeq_NUMB)
	 SELECT R.Last_NAME,
			R.First_NAME,
			R.MemberMci_IDNO,
			R.Birth_DATE,
			R.Case_IDNO,
			R.BornOfMarriage_CODE,
			R.PaternityStatus_CODE,
			R.LastMarriage_DATE,
			R.LastDivorce_DATE,
			R.ChildBirthBetweenMarrDivorce_INDC,
			R.ChildBirthBeforeMarriage_INDC,
			R.ChildBirthAfterDivorce_INDC,
			R.ChildParentsSameLastName_INDC,
			R.NcpExcluded_INDC,			
			R.ResponsibleWorker_ID, 
			R.Generate_DATE,
			ROW_NUMBER() OVER(ORDER BY R.Case_IDNO) AS TransactionEventSeq_NUMB
 			FROM(		
	 SELECT z.Last_NAME,
			z.First_NAME,
			m.MemberMci_IDNO,
			z.Birth_DATE,
			e.Case_IDNO,
			a.BornOfMarriage_CODE,
			a.StatusEstablish_CODE AS PaternityStatus_CODE,
			W.LastMarriage_DATE,
			W.LastDivorce_DATE,
		    CASE 
				WHEN Z.Birth_DATE BETWEEN W.LastMarriage_DATE AND W.LastDivorce_DATE 
					THEN @Lc_Yes_INDC 
					ELSE @Lc_Space_TEXT 
				END AS ChildBirthBetweenMarrDivorce_INDC,
			CASE 
				WHEN Z.Birth_DATE < W.LastMarriage_DATE AND W.LastMarriage_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
					THEN @Lc_Yes_INDC 
					ELSE @Lc_Space_TEXT 
				END AS ChildBirthBeforeMarriage_INDC,
			CASE 
				WHEN Z.Birth_DATE > W.LastDivorce_DATE AND W.LastDivorce_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
					THEN @Lc_Yes_INDC 
					ELSE @Lc_Space_TEXT 
				END AS ChildBirthAfterDivorce_INDC,
			CASE 
				WHEN X.MemberMci_IDNO IS NOT NULL 
					THEN @Lc_Yes_INDC 
					ELSE @Lc_Space_TEXT 
				END AS ChildParentsSameLastName_INDC,
			CASE 
				WHEN Q.MemberMci_IDNO IS NOT NULL 
					THEN @Lc_Yes_INDC 
					ELSE @Lc_Space_TEXT 
				END AS NcpExcluded_INDC,			
			e.Worker_ID	 AS ResponsibleWorker_ID, 
			@Ld_Current_DATE AS Generate_DATE,
			CASE 
				WHEN Q.MemberMci_IDNO IS NOT NULL OR X.MemberMci_IDNO IS NOT NULL OR P.Case_IDNO IS NOT NULL
					THEN @Lc_Yes_INDC
					ELSE @Lc_Space_TEXT
				END AS ReportCondition_INDC
	   FROM CASE_Y1 E
	   JOIN CMEM_Y1 m 
	     ON E.Case_IDNO = m.Case_IDNO
	   JOIN DEMO_Y1 z
		 ON z.MemberMci_IDNO = m.MemberMci_IDNO
	   JOIN MPAT_Y1 a
	     ON a.MemberMci_IDNO		 = m.MemberMci_IDNO
	   JOIN (SELECT a.case_idno,
					a.MemberMci_IDNO,
					d.LastMarriage_DATE,
					d.LastDivorce_DATE
			   FROM CMEM_Y1 a, CMEM_Y1 b, DEMO_Y1 d
			  WHERE a.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
			    AND a.Case_IDNO = b.Case_IDNO
			    AND ( CASE  WHEN a.CpRelationshipToChild_CODE = @Lc_RelationshipToChildMTR_CODE AND b.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE 
								THEN b.MemberMci_IDNO
						    WHEN a.NcpRelationshipToChild_CODE = @Lc_RelationshipToChildMTR_CODE AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE ,@Lc_CaseRelationshipP_CODE)
								THEN b.MemberMci_IDNO
							ELSE NULL
						END 
			         ) = b.MemberMci_IDNO
			  AND b.MemberMci_IDNO = d.MemberMci_IDNO       
			 ) W
		 ON a.MemberMci_IDNO = W.MemberMci_IDNO	 AND W.case_idno = E.case_idno 
	     LEFT OUTER JOIN 
	     (
	        SELECT n.MemberMci_IDNO
	          FROM CMEM_Y1 n
	         WHERE n.CaseRelationship_CODE  = @Lc_CaseRelationshipD_CODE
			   AND n.CaseMemberStatus_CODE  = @Lc_CaseMemberStatusA_CODE
			   AND n.CpRelationshipToChild_CODE  = @Lc_RelationshipToChildMTR_CODE
			   AND n.NcpRelationshipToChild_CODE = @Lc_RelationshipToChildFTR_CODE
			   AND n.MemberMci_IDNO IN (  
										SELECT t.MemberMci_IDNO 
										  FROM MPAT_Y1 t
										 WHERE t.BornOfMarriage_CODE = @Lc_BornOfMarriageN_CODE
							            )
			   AND (SELECT COUNT(DISTINCT y.Last_NAME) 
					  FROM DEMO_Y1 y
					 WHERE y.MemberMci_IDNO IN (SELECT x.MemberMci_IDNO 
												  FROM CMEM_Y1 x
												 WHERE x.Case_IDNO = n.Case_IDNO
												   AND x.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE,@Lc_CaseRelationshipP_CODE,@Lc_CaseRelationshipC_CODE) --NEED TO DOUBLE CHECK
												)
					) = @Li_One_NUMB
		) X
	   ON M.MemberMci_IDNO	= X.MemberMci_IDNO
	   LEFT OUTER JOIN
	    (
	      SELECT x.Case_IDNO,
				 D.MemberMci_IDNO,
				 D.LastMarriage_DATE,
				 D.LastDivorce_DATE 
  			FROM DEMO_Y1 d, CMEM_Y1 x
  		   WHERE D.MemberMci_IDNO = X.MemberMci_IDNO
    		 AND x.CaseRelationship_CODE  <> @Lc_CaseRelationshipD_CODE
    		 AND d.LastMarriage_DATE <> @Ld_Low_DATE 
			 AND d.LastDivorce_DATE  <> @Ld_Low_DATE
		 ) P
		ON M.Case_IDNO	= P.Case_IDNO
	   LEFT OUTER JOIN
	     (     
		   SELECT n.Case_IDNO,n.MemberMci_IDNO
	         FROM CMEM_Y1 n
		    WHERE N.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE	 
	          AND N.MemberMci_IDNO IN (SELECT p.MemberMci_IDNO 
								         FROM MPAT_Y1 p
								        WHERE p.BornOfMarriage_CODE = @Lc_BornOfMarriageY_CODE
							           )
              AND N.Case_IDNO IN (SELECT DISTINCT c.Case_IDNO
								         FROM CMEM_Y1 c
								        WHERE c.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE,@Lc_CaseRelationshipP_CODE)
									      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusI_CODE
									      AND c.ReasonMemberStatus_CODE = @Lc_ReasonMemberStatusX_CODE
								       )
		  ) Q
	      ON M.MemberMci_IDNO = Q.MemberMci_IDNO AND M.Case_IDNO	 = Q.Case_IDNO
	   WHERE M.CaseRelationship_CODE  = @Lc_CaseRelationshipD_CODE ) R
	   WHERE ReportCondition_INDC = @Lc_Yes_INDC;
	   
	   SET @Li_RowCount_QNTY = @@ROWCOUNT;
		
     IF (@Li_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BBOMA_Y1';
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

	    COMMIT TRANSACTION BORNOFMARRIAGE_LOAD;
	        
END TRY 
    
BEGIN CATCH

  IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION BORNOFMARRIAGE_LOAD;
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
--BATCH_BI_PATERNITY_REPORTS$SP_LOAD_BOM_SPECIAL_REPORT	 
GO
