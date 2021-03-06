/****** Object:  StoredProcedure [dbo].[BATCH_FIN_TANF_GRANT$SP_LOAD_TANF_GRANT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_TANF_GRANT$SP_LOAD_TANF_GRANT
Programmer Name   :	IMP Team
Description       :	This bathc loads the TanF grant data into the temporary table.
Frequency         :	Monthly.
Developed On      :	12/28/2011
Called By         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
					BATCH_COMMON$SP_BATE_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_TANF_GRANT$SP_LOAD_TANF_GRANT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE     CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE      CHAR(1) = 'W',
          @Lc_ProcessN_INDC              CHAR(1) = 'N',
          @Lc_ProcessY_INDC              CHAR(1) = 'Y',
          @Lc_AgStsCdO_CODE              CHAR(1) = 'O',
          @Lc_AgPayeeSwY_CODE            CHAR(1) = 'Y',
          @Lc_SubProgramA_CODE           CHAR(1) = 'A',
          @Lc_SubProgramF_CODE           CHAR(1) = 'F',
          @Lc_BiCashAccIndC_CODE         CHAR(1) = 'C',
          @Lc_BiCashAccIndR_CODE         CHAR(1) = 'R',
          @Lc_BiCashAccIndM_CODE         CHAR(1) = 'M',
          @Lc_BenfTypeIn_CODE            CHAR(2) = 'IN',
          @Lc_BenfTypeMn_CODE            CHAR(2) = 'MN',
          @Lc_BenfTypeSp_CODE            CHAR(2) = 'SP',
          @Lc_BenfTypeCs_CODE            CHAR(2) = 'CS',
          @Lc_AfBenDispIndIs_CODE        CHAR(2) = 'IS',
          @Lc_AfBenDispIndRc_CODE        CHAR(2) = 'RC',
          @Lc_AfBenDispIndCc_CODE        CHAR(2) = 'CC',
          @Lc_ProgramAbc_CODE            CHAR(3) = 'ABC',
          @Lc_BenfRsnInb_CODE            CHAR(3) = 'INB',
          @Lc_BenfRsnRmb_CODE            CHAR(3) = 'RMB',
          @Lc_BenfRsnAbc_CODE            CHAR(3) = 'ABC',
          @Lc_BenfRsnIpb_CODE            CHAR(3) = 'IPB',
          @Lc_BenfRsnCsd_CODE            CHAR(3) = 'CSD',
          @Lc_LinkedServerDb2_CODE		 CHAR(3) = 'DB2',
          @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE            CHAR(5) = 'E0944',
          @Lc_Job_ID                     CHAR(7) = 'DEB0240',
          @Lc_Successful_TEXT            CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT       VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_LOAD_TANF_GRANT',
          @Ls_Process_NAME               VARCHAR(100) = 'BATCH_FIN_TANF_GRANT',
          @Ls_CursorLocation_TEXT        VARCHAR(200) = ' ',
          @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_LinkedServerQualifier_TEXT  CHAR(8) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_OpenQuery_TEXT              VARCHAR(8000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_BenefitFrom_DATE            DATE,
          @Ld_BenefitTo_DATE              DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
      
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   SET @Ls_Sql_TEXT = 'SELECT DATABASE NAME TO LINKED SERVER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');   
   
   SELECT @Lc_LinkedServerQualifier_TEXT = e.Database_NAME
	 FROM ENVG_Y1 e;

   IF ISNULL(@Lc_LinkedServerQualifier_TEXT, '') = ''
    BEGIN 
      SET @Ls_Sql_TEXT = 'Invalid Linked Server Qualifier';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LinkedServerQualifier_TEXT = ' + ISNULL(@Lc_LinkedServerQualifier_TEXT, '');
      
      RAISERROR (50001,16,1);
    END 
	 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
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
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION TANFGRANT_LOAD;

   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LTGRA_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_INDC = ' + @Lc_ProcessY_INDC;

   DELETE LTGRA_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   --13347 - Assing Last run date to "Benefit from date", (Run date - 1 day) to "Benefit to date" -START-
   SET @Ld_BenefitFrom_DATE = @Ld_LastRun_DATE
   SET @Ld_BenefitTo_DATE = DATEADD(DAY, -1, @Ld_Run_DATE);
   --13347 - Assing Last run date to "Benefit from date", (Run date - 1 day) to "Benefit to date" -END-   
      
   SET @Ls_Sql_TEXT = 'SELECT STATEMENT TO INSERT DEFRA PAYMENT DATA INTO LTGRA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   
   --13347 - Checking the records between "Benefit from date" and "Benefit to date" -START-
   SELECT @Ls_OpenQuery_TEXT = 'SELECT 
									 CASE_NUM AS CaseWelfare_IDNO, 
									 '' '' GrantYearMonth_NUMB,
									 0 Grant_AMNT,
									 CAST(MCI_NUM AS VARCHAR) AS MemberMci_IDNO, 
									 CAST(DfraYear_NUMB AS CHAR(4)) + RIGHT(''0'' + LTRIM(RTRIM(CAST(DfraMonth_NUMB AS CHAR(2)))), 2) AS DefraYearMonth_NUMB,
									 ISNULL(Defra_AMNT,0) AS Defra_AMNT,
									 ''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
									 ''' + @Lc_ProcessN_INDC + ''' AS Process_INDC
									 FROM OPENQUERY (' + @Lc_LinkedServerDb2_CODE + ',
	   								''SELECT 
									y.CASE_NUM,
									y.MCI_NUM,
									y.DfraYear_NUMB,
									y.DfraMonth_NUMB,
									y.Defra_AMNT
									FROM 
									(SELECT c.CASE_NUM,
										    c.MCI_NUM,
										    Year(c.BI_BEN_ISS_PRD_DT) DfraYear_NUMB,
										    Month(c.BI_BEN_ISS_PRD_DT) DfraMonth_NUMB,										    
										    SUM(c.AF_ISSUANCE_AMT * CASE WHEN AF_BEN_DISP_IND IN (''''' + @Lc_AfBenDispIndIs_CODE + ''''',''''' + @Lc_AfBenDispIndRc_CODE + ''''') THEN 1 
																		 WHEN AF_BEN_DISP_IND = ''''' + @Lc_AfBenDispIndCc_CODE + ''''' THEN -1  
																	END) AS Defra_AMNT
									 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0205_BI_CASH_DISB c
									 WHERE  c.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + '''''
									  AND c.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''', ''''' + @Lc_SubProgramF_CODE + ''''')
									  AND c.AF_BEN_RSN_CD = ''''' + @Lc_BenfRsnCsd_CODE + '''''
									  AND (
											(c.AF_BEN_ISS_DT BETWEEN ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' AND ''''' + CAST(@Ld_BenefitTo_DATE AS VARCHAR) + '''''
											 AND c.AF_BEN_DISP_IND IN (''''' + @Lc_AfBenDispIndIs_CODE + ''''',''''' + @Lc_AfBenDispIndRc_CODE + ''''')
											) 
											OR
									  		(c.AF_DISP_STS_DT BETWEEN ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' AND ''''' + CAST(@Ld_BenefitTo_DATE AS VARCHAR) + '''''
											 AND c.AF_BEN_DISP_IND IN (''''' + @Lc_AfBenDispIndCc_CODE + ''''')
											 AND c.AF_BEN_ISS_DT < ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + '''''
											) 
									     )
									  AND c.AF_ISSUANCE_AMT > 0   	
									  AND c.AF_BEN_TYP_CD = ''''' + @Lc_BenfTypeCs_CODE + '''''
									  AND c.BI_CASH_ACC_IND = ''''' + @Lc_BiCashAccIndC_CODE + '''''
									  AND EXISTS (SELECT 1 
								 				    FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG d
												   WHERE d.CASE_NUM =  c.CASE_NUM 
												   AND d.MCI_NUM = c.MCI_NUM
												   AND d.AG_SEQ_NUM = c.AG_SEQ_NUM
												   AND d.AG_STS_CD = ''''' + @Lc_AgStsCdO_CODE + ''''' 
												   AND d.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwY_CODE + '''''
												   AND d.PAYMENT_END_DT > d.PAYMENT_BEGIN_DT
												   AND (d.PAYMENT_BEGIN_DT BETWEEN ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' AND ''''' + CAST(@Ld_BenefitTo_DATE AS VARCHAR) + '''''
												      OR ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' BETWEEN d.PAYMENT_BEGIN_DT AND d.PAYMENT_END_DT)) 
									  GROUP BY c.CASE_NUM,
									   		   c.MCI_NUM,
									   		   Year(c.BI_BEN_ISS_PRD_DT), 
									   		   Month(c.BI_BEN_ISS_PRD_DT)
									) y									
									
									'')';
   --13347 - Checking the records between "Benefit from date" and "Benefit to date" -END-
   
   SET @Ls_Sql_TEXT = 'INSERT DEFRA AMOUNT INTO LTGRA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
 
   INSERT INTO LTGRA_Y1
               (CaseWelfare_IDNO,
                GrantYearMonth_NUMB,
                Grant_AMNT,
                MemberMci_IDNO,
                DefraYearMonth_NUMB,
                Defra_AMNT,
                FileLoad_DATE,
                Process_INDC)
   EXECUTE (@Ls_OpenQuery_TEXT);
 
   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   SET @Ls_Sql_TEXT = 'SELECT STATEMENT TO INSERT GRANT PAYMENT DATA INTO LTGRA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   
   --13347 - Case statement to pick up Grant year month based on AF_BEN_DISP_IND value -START-
   SELECT @Ls_OpenQuery_TEXT = 'SELECT 
									 CASE_NUM AS CaseWelfare_IDNO, 
									 CAST(GrantYear_NUMB AS CHAR(4)) + RIGHT(''0'' + LTRIM(RTRIM(CAST(GrantMonth_NUMB AS CHAR(2)))), 2) AS GrantYearMonth_NUMB,
									 Grant_AMNT,
									 CAST(MCI_NUM AS VARCHAR) AS MemberMci_IDNO, 
									 '' '' DefraYearMonth_NUMB, 
									 0 Defra_AMNT,
									 ''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
									 ''' + @Lc_ProcessN_INDC + ''' AS Process_INDC
									 FROM OPENQUERY (' + @Lc_LinkedServerDb2_CODE + ',
	   								''SELECT 
									x.CASE_NUM,
									x.Grant_AMNT,
									x.MCI_NUM,
									x.GrantYear_NUMB,
									x.GrantMonth_NUMB
									FROM 
									(SELECT c.CASE_NUM,
										    c.MCI_NUM,
                                            Year(c.BI_BEN_ISS_PRD_DT) AS GrantYear_NUMB, 
                                            MONTH(c.BI_BEN_ISS_PRD_DT) AS GrantMonth_NUMB,
										    SUM(c.AF_ISSUANCE_AMT * CASE WHEN AF_BEN_DISP_IND IN (''''' + @Lc_AfBenDispIndIs_CODE + ''''',''''' + @Lc_AfBenDispIndRc_CODE + ''''') THEN 1 
																		 WHEN AF_BEN_DISP_IND = ''''' + @Lc_AfBenDispIndCc_CODE + ''''' THEN -1  
																	END) AS Grant_AMNT
									 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0205_BI_CASH_DISB c
									 WHERE c.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + '''''
									  AND c.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''', ''''' + @Lc_SubProgramF_CODE + ''''')
									  AND (
											(c.AF_BEN_ISS_DT BETWEEN ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' AND ''''' + CAST(@Ld_BenefitTo_DATE AS VARCHAR) + '''''
											 AND c.AF_BEN_DISP_IND IN (''''' + @Lc_AfBenDispIndIs_CODE + ''''',''''' + @Lc_AfBenDispIndRc_CODE + ''''')
											) 
											OR
										  	(c.AF_DISP_STS_DT BETWEEN ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' AND ''''' + CAST(@Ld_BenefitTo_DATE AS VARCHAR) + '''''
											 AND c.AF_BEN_DISP_IND IN (''''' + @Lc_AfBenDispIndCc_CODE + ''''')
											 AND c.AF_BEN_ISS_DT < ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + '''''
											) 
										  )	
									  AND (
										   (c.AF_BEN_TYP_CD = ''''' + @Lc_BenfTypeIn_CODE + '''''
											AND c.AF_BEN_RSN_CD = ''''' + @Lc_BenfRsnInb_CODE + ''''')
										   OR
										   (c.AF_BEN_TYP_CD = ''''' + @Lc_BenfTypeMn_CODE + ''''' 
											AND c.AF_BEN_RSN_CD = ''''' + @Lc_BenfRsnRmb_CODE + '''''	)
										   OR
										   (c.AF_BEN_TYP_CD = ''''' + @Lc_BenfTypeSp_CODE + '''''
											AND c.AF_BEN_RSN_CD IN (''''' + @Lc_BenfRsnAbc_CODE + ''''' ,''''' + @Lc_BenfRsnIpb_CODE + '''''))
										 )
									
									  AND c.BI_CASH_ACC_IND IN (''''' + @Lc_BiCashAccIndR_CODE + ''''', ''''' + @Lc_BiCashAccIndM_CODE + ''''')										 
									  AND c.AF_ISSUANCE_AMT > 0
									  AND EXISTS (SELECT 1 
												  FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG d
												 WHERE d.CASE_NUM =  c.CASE_NUM 
												 AND d.MCI_NUM = c.MCI_NUM
												 AND d.AG_SEQ_NUM = c.AG_SEQ_NUM
												 AND d.AG_STS_CD = ''''' + @Lc_AgStsCdO_CODE + ''''' 
												 AND d.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwY_CODE + '''''
												 AND d.PAYMENT_END_DT > d.PAYMENT_BEGIN_DT
												 AND (d.PAYMENT_BEGIN_DT BETWEEN ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' AND ''''' + CAST(@Ld_BenefitTo_DATE AS VARCHAR) + '''''
												      OR ''''' + CAST(@Ld_BenefitFrom_DATE AS VARCHAR) + ''''' BETWEEN d.PAYMENT_BEGIN_DT AND d.PAYMENT_END_DT)) 
									GROUP BY c.CASE_NUM,
											 c.MCI_NUM,
											 Year(c.BI_BEN_ISS_PRD_DT),
                                             MONTH(c.BI_BEN_ISS_PRD_DT)
									) x 
									'')';
   --13347 - Case statement to pick up Grant year month based on AF_BEN_DISP_IND value -END-
   
   SET @Ls_Sql_TEXT = 'INSERT GRANT AMOUNT INTO LTGRA_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
 
   INSERT INTO LTGRA_Y1
               (CaseWelfare_IDNO,
                GrantYearMonth_NUMB,
                Grant_AMNT,
                MemberMci_IDNO,
                DefraYearMonth_NUMB,
                Defra_AMNT,
                FileLoad_DATE,
                Process_INDC)
   EXECUTE (@Ls_OpenQuery_TEXT);
  
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @@ROWCOUNT;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION TANFGRANT_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TANFGRANT_LOAD;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
