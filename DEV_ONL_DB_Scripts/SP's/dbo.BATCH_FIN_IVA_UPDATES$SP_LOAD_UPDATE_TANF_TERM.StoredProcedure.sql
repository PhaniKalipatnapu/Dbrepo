/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_TANF_TERM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_TANF_TERM
Programmer Name   :	IMP Team
Description       :	This process retrive the data from DCIS II tables where TAN F eligibility has be terminated 
					moves the data to the temporary table.
Frequency         :	Monthly.
Developed On      :	02/15/2012
Called By         :	None
Called On         :	BATCH_COMMON$SP_GET_BATCH_DETAILS,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
					BATCH_COMMON$SP_BATE_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_TANF_TERM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE     CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE      CHAR(1) = 'W',
          @Lc_ProcessN_INDC              CHAR(1) = 'N',
          @Lc_ProcessY_INDC              CHAR(1) = 'Y',
          @Lc_SubProgramA_CODE           CHAR(1) = 'A',
          @Lc_SubProgramC_CODE           CHAR(1) = 'C',
          @Lc_SubProgramF_CODE           CHAR(1) = 'F',
          @Lc_SubProgramI_CODE           CHAR(1) = 'I',
          @Lc_SubProgramY_CODE           CHAR(1) = 'Y',
          @Lc_AgPayeeSwitchY_INDC        CHAR(1) = 'Y',
          @Lc_CurrentEligIndc1_CODE      CHAR(1) = '1',
          @Lc_CurrentEligIndc9_CODE      CHAR(1) = '9',
          @Lc_AgStatusO_CODE             CHAR(1) = 'O',
          @Lc_AgStatusC_CODE             CHAR(1) = 'C',
          @Lc_AgStatusD_CODE             CHAR(1) = 'D',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_PartStatusEc_CODE          CHAR(2) = 'EC',
          @Lc_PartStatusXc_CODE          CHAR(2) = 'XC',
          @Lc_ProgramCc_CODE             CHAR(2) = 'CC',
          @Lc_ProgramAbc_CODE            CHAR(3) = 'ABC',
          @Lc_ProgramMao_CODE            CHAR(3) = 'MAO',
          @Lc_ProgramMpv_CODE            CHAR(3) = 'MPV',
          @Lc_ProgramMrm_CODE            CHAR(3) = 'MRM',
          --13486 - CR0388 Inclusion of MAGI Codes -START-
          @Lc_ProgramMgi_CODE			 CHAR(3) = 'MGI',
          --13486 - CR0388 Inclusion of MAGI Codes -END-
          @Lc_LinkedServerDb2_CODE       CHAR(3) = 'DB2',
          @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE            CHAR(5) = 'E0944',
          @Lc_Job_ID                     CHAR(7) = 'DEB8113',
          @Lc_UnknownMci_IDNO            CHAR(10) = '9999995',
          @Lc_Successful_TEXT            CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT       VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_LOAD_UPDATE_TANF_TERM',
          @Ls_Process_NAME               VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_CursorLocation_TEXT        VARCHAR(200) = ' ',
          @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
		  @Lc_LinkedServerQualifier_TEXT  CHAR(8) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_OpenQuery_TEXT              VARCHAR(8000),
          @Ld_Run_DATE                    DATE,
          @Ld_PaymentEndFrom_DATE         DATE,
          @Ld_PaymentEndTo_DATE           DATE,
          @Ld_PaymentBeginFrom_DATE		  DATE,
		  @Ld_PaymentBeginTo_DATE		  DATE, 
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB_ID = ' + @Lc_Job_ID;
   
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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION TANFTERMINATION_LOAD;

   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LTNFT_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE LTNFT_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ld_PaymentEndFrom_DATE = DATEADD(DAY, -(DAY(@Ld_Run_DATE) - 1), @Ld_Run_DATE);

   IF DATEPART(DAY, @Ld_Run_DATE) < 25
    BEGIN
     SET @Ld_PaymentEndFrom_DATE =DATEADD(MONTH, -1, @Ld_PaymentEndFrom_DATE);
    END

   SET @Ld_PaymentEndTo_DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @Ld_PaymentEndFrom_DATE));
   SET @Ld_PaymentBeginFrom_DATE = DATEADD(MONTH, 1, @Ld_PaymentEndFrom_DATE);
   SET @Ld_PaymentBeginTo_DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @Ld_PaymentBeginFrom_DATE));   
   
   SET @Ls_Sql_TEXT = 'SELECT STATEMENT TO INSERT TANF TERMINATION DATA INTO LTNFT_Y1 - 1 WHERE MEDICAID TYPE IS ACTIVE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   --13486 - CR0388 Inclusion of MAGI Codes -START-
   SET @Ls_OpenQuery_TEXT = 'SELECT	CaseWelfare_IDNO,
											CpMci_IDNO,
											0 AS NcpMci_IDNO,
											ChildMci_IDNO,
											Program_CODE,
											SubProgram_CODE,											
											0 AS AgSequence_NUMB,
											''' + CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE,112) + '''  AS ChildElig_DATE,
											3 AS WelfareCaseCounty_IDNO,
											''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
											''' + @Lc_ProcessN_INDC + ''' AS Process_INDC
									   FROM OPENQUERY(' + @Lc_LinkedServerDb2_CODE + ',''
									  SELECT DISTINCT 
									  a.CASE_NUM "CaseWelfare_IDNO", 
									  c.MCI_NUM "CpMci_IDNO", 
									  a.MCI_NUM "ChildMci_IDNO",
									  a.PROGRAM_CD "Program_CODE",
									  a.SUBPROGRAM_CD "SubProgram_CODE"
					FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
					INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG h ON a.CASE_NUM = h.CASE_NUM AND a.MCI_NUM = h.MCI_NUM 
					INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM AND h.CASE_NUM = c.CASE_NUM AND c.PROGRAM_CD = h.PROGRAM_CD AND c.SUBPROGRAM_CD = h.SUBPROGRAM_CD AND c.AG_SEQ_NUM = h.AG_SEQ_NUM  AND c.AG_STS_CD = h.AG_STS_CD AND c.CURRENT_ELIG_IND = h.CURRENT_ELIG_IND
					WHERE a.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
						AND a.PART_STS_CD = ''''' + @Lc_PartStatusEc_CODE + '''''
						AND a.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginTo_DATE, 111), '/', '-') + '''''
						AND a.PAYMENT_END_DT >= a.PAYMENT_BEGIN_DT
						AND h.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' 
						AND h.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + ''''')
						AND c.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
						AND h.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
						AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
						AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
						AND
						 (
						    (h.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
						     AND h.PAYMENT_END_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						     AND h.PAYMENT_END_DT >= h.PAYMENT_BEGIN_DT
						    )
						    OR
						    (h.AG_STS_CD IN (''''' + @Lc_AgStatusC_CODE + ''''', ''''' + @Lc_AgStatusD_CODE + ''''')
						     AND h.PAYMENT_END_DT = ''''' + CAST(@Ld_High_DATE AS VARCHAR) + '''''
						     AND h.UPDATED_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						    )
						 )
						AND 
						  (
								(a.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
								OR
								(a.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))                    
								OR
								(a.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND a.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')   
								OR 
								(a.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
						  )  
						AND NOT EXISTS (SELECT 1 
											FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG f
										   WHERE a.CASE_NUM = f.CASE_NUM
										    AND a.MCI_NUM = f.MCI_NUM
										    AND f.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
											AND f.PART_STS_CD = ''''' + @Lc_PartStatusEc_CODE + '''''
											AND f.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
											AND f.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginTo_DATE, 111), '/', '-') + '''''
											AND f.PAYMENT_END_DT >= f.PAYMENT_BEGIN_DT
											AND f.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' 
											AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + ''''')
											AND f.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
										  )
						  AND a.AG_SEQ_NUM = (SELECT MAX(AG_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
										   WHERE b.PAYMENT_END_DT = a.PAYMENT_END_DT
											 AND b.AG_STS_CD = a.AG_STS_CD
											 AND a.CASE_NUM = b.CASE_NUM
											 AND a.MCI_NUM = b.MCI_NUM
											 AND 
											  (
												(b.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND b.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
												OR
												(b.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND b.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))                    
												OR
												(b.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND b.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')  
												OR
												(b.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND b.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
											   ) 
											 AND b.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
											 )
					'')';
   --13486 - CR0388 Inclusion of MAGI Codes -END-
   
   SET @Ls_Sql_TEXT = 'INSERT INTO LTNFT_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO LTNFT_Y1
               (CaseWelfare_IDNO,
                CpMci_IDNO,
                NcpMci_IDNO,
                ChildMci_IDNO,
                Program_CODE,
                SubProgram_CODE,
                AgSequence_NUMB,
                ChildEligibility_DATE,
                WelfareCaseCounty_IDNO,
                FileLoad_DATE,
                Process_INDC)
   EXECUTE (@Ls_OpenQuery_TEXT);  

   SET @Ls_Sql_TEXT = 'SELECT STATEMENT TO INSERT TANF TERMINATION DATA INTO LTNFT_Y1 - 2 WHERE CC TYPE IS ACTIVE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   --13486 - CR0388 Inclusion of MAGI Codes -START-
   SET @Ls_OpenQuery_TEXT = 'SELECT	CaseWelfare_IDNO,
										CpMci_IDNO,
										0 AS NcpMci_IDNO,
										ChildMci_IDNO,
										''CC'' Program_CODE,
										'' '' SubProgram_CODE,										
										0 AS AgSequence_NUMB,
										''' + CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE,112) + '''  AS ChildElig_DATE,
										3 AS WelfareCaseCounty_IDNO,
										''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
										''' + @Lc_ProcessN_INDC + ''' AS Process_INDC
								   FROM OPENQUERY(' + @Lc_LinkedServerDb2_CODE + ',''
									  SELECT DISTINCT 
									  a.CASE_NUM "CaseWelfare_IDNO", 
									  c.MCI_NUM "CpMci_IDNO", 
									  a.MCI_NUM "ChildMci_IDNO"
					FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
					INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG h ON a.CASE_NUM = h.CASE_NUM AND a.MCI_NUM = h.MCI_NUM 
					INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM AND h.CASE_NUM = c.CASE_NUM AND c.PROGRAM_CD = h.PROGRAM_CD AND c.SUBPROGRAM_CD = h.SUBPROGRAM_CD AND c.AG_SEQ_NUM = h.AG_SEQ_NUM  AND c.AG_STS_CD = h.AG_STS_CD AND c.CURRENT_ELIG_IND = h.CURRENT_ELIG_IND
					WHERE a.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
						  AND a.PART_STS_CD = ''''' + @Lc_PartStatusEc_CODE + '''''
						  AND a.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginTo_DATE, 111), '/', '-') + '''''
						  AND a.PAYMENT_END_DT >= a.PAYMENT_BEGIN_DT
						  AND h.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' 
						  AND h.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + ''''')
						  AND c.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						  AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
						  AND a.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''' 
						  AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
						  AND h.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
						  AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
						  AND
						 (
						    (h.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
						     AND h.PAYMENT_END_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						     AND h.PAYMENT_END_DT >= h.PAYMENT_BEGIN_DT
						     )
						    OR
						    (h.AG_STS_CD IN (''''' + @Lc_AgStatusC_CODE + ''''', ''''' + @Lc_AgStatusD_CODE + ''''')
						     AND h.PAYMENT_END_DT = ''''' + CAST(@Ld_High_DATE AS VARCHAR) + '''''
						     AND h.UPDATED_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						    )
						 )
						  AND NOT EXISTS(SELECT 1 
										   FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG f
										  WHERE a.CASE_NUM = f.CASE_NUM
										    AND a.MCI_NUM = f.MCI_NUM
										    AND f.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
											AND f.PART_STS_CD = ''''' + @Lc_PartStatusEc_CODE + '''''
											AND f.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
										    AND f.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginTo_DATE, 111), '/', '-') + '''''
											AND f.PAYMENT_END_DT >= f.PAYMENT_BEGIN_DT
											AND (
											    (f.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))                    
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND f.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')  
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
												)
											AND f.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
										  )
						  AND a.AG_SEQ_NUM = (SELECT MAX(ag_seq_num) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
										   WHERE b.PAYMENT_END_DT = a.PAYMENT_END_DT
											 AND b.AG_STS_CD = a.AG_STS_CD
											 AND a.CASE_NUM = b.CASE_NUM
											 AND a.MCI_NUM = b.MCI_NUM
											 AND b.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + '''''
											 AND b.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
											 )
					'') 
					';
   --13486 - CR0388 Inclusion of MAGI Codes -END-
   SET @Ls_Sql_TEXT = 'INSERT INTO LTNFT_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
 
   INSERT INTO LTNFT_Y1
               (CaseWelfare_IDNO,
                CpMci_IDNO,
                NcpMci_IDNO,
                ChildMci_IDNO,
                Program_CODE,
                SubProgram_CODE,
                AgSequence_NUMB,
                ChildEligibility_DATE,
                WelfareCaseCounty_IDNO,
                FileLoad_DATE,
                Process_INDC)
   EXECUTE (@Ls_OpenQuery_TEXT);
  
   SET @Ls_Sql_TEXT = 'SELECT STATEMENT TO INSERT TANF TERMINATION DATA INTO LTNFT_Y1 - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   --13486 - CR0388 Inclusion of MAGI Codes -START-
   SET @Ls_OpenQuery_TEXT = 'SELECT	CaseWelfare_IDNO,
											CpMci_IDNO,
											0 AS NcpMci_IDNO,
											ChildMci_IDNO,
											''ABC'' Program_CODE,
											''A'' SubProgram_CODE,											
											0 AS AgSequence_NUMB,
											''' + CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE,112) + '''  AS ChildElig_DATE,
											3 AS WelfareCaseCounty_IDNO,
											''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
											''' + @Lc_ProcessN_INDC + ''' AS Process_INDC
									   FROM OPENQUERY(' + @Lc_LinkedServerDb2_CODE + ',''
									  SELECT DISTINCT 
									  a.CASE_NUM "CaseWelfare_IDNO", 
									  c.MCI_NUM "CpMci_IDNO", 
									  a.MCI_NUM "ChildMci_IDNO"
					FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
					INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM AND c.PROGRAM_CD = a.PROGRAM_CD AND c.SUBPROGRAM_CD = a.SUBPROGRAM_CD AND c.AG_SEQ_NUM = a.AG_SEQ_NUM AND c.AG_STS_CD = a.AG_STS_CD AND c.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
					WHERE a.PART_STS_CD IN (''''' + @Lc_PartStatusEc_CODE + ''''', ''''' + @Lc_PartStatusXc_CODE + ''''')
					      AND a.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' 
						  AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + ''''')
						  AND c.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
						  AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
 						  AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
 						  AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
					      AND 
					       ( 
					        (a.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + '''''
					           AND a.PAYMENT_END_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
							   AND a.PAYMENT_END_DT >= a.PAYMENT_BEGIN_DT
							)   
					        OR
					        (a.AG_STS_CD IN ( ''''' + @Lc_AgStatusC_CODE + ''''' , ''''' + @Lc_AgStatusD_CODE + ''''')
					           AND a.PAYMENT_END_DT = ''''' + CAST(@Ld_High_DATE AS VARCHAR) + '''''
					           AND a.UPDATED_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentEndTo_DATE, 111), '/', '-') + '''''
					        )
					       )					
						  AND NOT EXISTS (SELECT 1 
											FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG f
										   WHERE  a.CASE_NUM = f.CASE_NUM
										    AND a.MCI_NUM = f.MCI_NUM
										    AND f.AG_STS_CD = ''''' + @Lc_AgStatusO_CODE + ''''' 
											AND f.PART_STS_CD = ''''' + @Lc_PartStatusEc_CODE + '''''
											AND f.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitchY_INDC + '''''
										    AND f.PAYMENT_BEGIN_DT BETWEEN ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginFrom_DATE, 111), '/', '-') + ''''' AND ''''' + REPLACE(CONVERT(VARCHAR, @Ld_PaymentBeginTo_DATE, 111), '/', '-') + '''''
											AND f.PAYMENT_END_DT >= f.PAYMENT_BEGIN_DT
											AND (
											    (f.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))                    
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND f.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')  
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND f.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
												OR
												(f.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''')
												)
											AND f.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
										  )
						  AND a.AG_SEQ_NUM = (SELECT MAX(ag_seq_num) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
										   WHERE b.PAYMENT_END_DT = a.PAYMENT_END_DT
											 AND b.AG_STS_CD = a.AG_STS_CD
											 AND a.CASE_NUM = b.CASE_NUM
											 AND a.MCI_NUM = b.MCI_NUM
											 AND b.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' 
											 AND b.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + ''''') 
											 AND b.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
											 )
						 					 
					'')';
   --13486 - CR0388 Inclusion of MAGI Codes -END-
   SET @Ls_Sql_TEXT = 'INSERT INTO LTNFT_Y1 - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO LTNFT_Y1
               (CaseWelfare_IDNO,
                CpMci_IDNO,
                NcpMci_IDNO,
                ChildMci_IDNO,
                Program_CODE,
                SubProgram_CODE,
                AgSequence_NUMB,
                ChildEligibility_DATE,
                WelfareCaseCounty_IDNO,
                FileLoad_DATE,
                Process_INDC)
   EXECUTE (@Ls_OpenQuery_TEXT); 

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM LTNFT_Y1
                                         WHERE Process_INDC = @Lc_ProcessN_INDC
                                           AND FileLoad_DATE = @Ld_Run_DATE);

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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION TANFTERMINATION_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TANFTERMINATION_LOAD;
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
