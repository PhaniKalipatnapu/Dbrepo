/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_IVA_REFERRALS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_IVA_REFERRALS
Programmer Name	:	IMP Team.
Description		:	This process reads the data from IV-A[DCIS II Tables] and loads the data into the temporary table.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
					BATCH_COMMON$SP_BATE_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_UPDATE_IVA_REFERRALS]
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  -- Common Variables
  DECLARE @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE       CHAR(1) = 'W',
          @Lc_ProcessN_CODE               CHAR(1) = 'N',
          @Lc_ProcessY_CODE               CHAR(1) = 'Y',
          @Lc_ProcessS_CODE               CHAR(1) = 'S',
          @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_SubProgramA_CODE            CHAR(1) = 'A',
          @Lc_SubProgramF_CODE            CHAR(1) = 'F',
          @Lc_SubProgramI_CODE            CHAR(1) = 'I',
          @Lc_SubProgramC_CODE            CHAR(1) = 'C',
          @Lc_SubProgramY_CODE            CHAR(1) = 'Y',
          @Lc_AgPayeeSwitch_INDC          CHAR(1) = 'Y',
          @Lc_CurrentEligIndc1_CODE       CHAR(1) = '1',
          @Lc_CurrentEligIndc9_CODE       CHAR(1) = '9',
          @Lc_AgStatus_CODE               CHAR(1) = 'O',
          @Lc_SexM_CODE                   CHAR(1) = 'M',
          @Lc_SexF_CODE                   CHAR(1) = 'F',
          @Lc_WelfareCaseCounty1_IDNO     CHAR(1) = '1',
          @Lc_WelfareCaseCounty3_IDNO     CHAR(1) = '3',
          @Lc_WelfareCaseCounty5_IDNO     CHAR(1) = '5',
          @Lc_PaymentTypeSDU_CODE         CHAR(1) = 'S',
          @Lc_AddrNormalizationU_CODE     CHAR(1) = 'U',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_ProgramCc_CODE              CHAR(2) = 'CC',
          @Lc_TriggerTypeIndcNumb_TEXT    CHAR(2) = '10',
          @Lc_PartStatus_CODE             CHAR(2) = 'EC',
          @Lc_PartStatusCA_CODE           CHAR(2) = 'CA',
          @Lc_PartStatusEA_CODE           CHAR(2) = 'EA',
          @Lc_ProgramMao_CODE             CHAR(3) = 'MAO',
          @Lc_ProgramMpv_CODE             CHAR(3) = 'MPV',
          @Lc_ProgramMrm_CODE             CHAR(3) = 'MRM',
		  --13486 - CR0388 Inclusion of MAGI Codes 20140527 -START-
		  @Lc_ProgramMgi_CODE             CHAR(3) = 'MGI',
		  --13486 - CR0388 Inclusion of MAGI Codes 20140527 -END-
          @Lc_ProgramAbc_CODE             CHAR(3) = 'ABC',
          @Lc_RelationshipToChildMtr_CODE CHAR(3) = 'MTR',
          @Lc_RelationshipToChildFtr_CODE CHAR(3) = 'FTR',
          @Lc_LinkedServer_CODE           CHAR(3) = 'DB2',
          @Lc_RefmTable_ID                CHAR(4) = 'TANF',
          @Lc_RefmTableSub_ID             CHAR(4) = 'SKIP',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_Job_ID                      CHAR(7) = 'DEB9901',
          @Lc_LowDate_TEXT                CHAR(8) = '00010101',
          @Lc_UnknownMciIdno_TEXT         CHAR(10) = '0000999995',
          @Lc_ErrorE0944_CODE             CHAR(18) = 'E0944',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT        VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_LOAD_UPDATE_IVA_REFERRALS',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = ' ',
          @Lc_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Ln_ProcessedTriggerCount_QNTY  NUMERIC(19) = 0,
          @Li_NumberOfDays_QNTY           SMALLINT = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Lc_LinkedServerQualifier_TEXT  CHAR(8) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Select_TEXT                 VARCHAR(200) = '',
          @Ls_OrderBy_TEXT                VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_OpenQuery_TEXT              NVARCHAR(MAX),
          @Ls_TransactionSql_TEXT         NVARCHAR(MAX),
          @Ld_Run_DATE                    DATE,
          @Ld_LastDayCurrentMonth_DATE    DATE,
          @Ld_LastDayPreviousMonth_DATE   DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_LastRun_DATE                DATETIME2,
          @Lb_GetDetailsInTrigger_BIT     BIT = 0,
          @Lb_GetDetailsNotInTrigger_BIT  BIT = 0;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'SELECT Linked Server Qualifier';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Lc_LinkedServerQualifier_TEXT = e.Database_NAME
     FROM ENVG_Y1 e;

   IF ISNULL(@Lc_LinkedServerQualifier_TEXT, '') = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'Invalid Linked Server Qualifier';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LinkedServerQualifier_TEXT = ' + ISNULL(@Lc_LinkedServerQualifier_TEXT, '') + ', LinkedServer_CODE = ' + ISNULL(@Lc_LinkedServer_CODE, '');

     RAISERROR (50001,16,1);
    END

   -- Selecting Date Run, Date Last Run, Commit Freq, Exception Threshold details
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

   -- Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   -- Transaction begins
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVAREFERRALS_LOAD;

   -- Get the number of days quantity to delete the skipped records.
   SET @Ls_Sql_TEXT = 'SELECT #OF DAYS TO DELETE SKIPPED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Li_NumberOfDays_QNTY = ISNULL(CAST(Value_CODE AS NUMERIC), 0)
     FROM REFM_Y1
    WHERE Table_ID = @Lc_RefmTable_ID
      AND TableSub_ID = @Lc_RefmTableSub_ID;

   -- Delete Processed Records in LOAD job:
   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS FROM LIVAR_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_CODE = ' + ISNULL(@Lc_ProcessY_CODE, '');

   DELETE LIVAR_Y1
    WHERE Process_CODE = @Lc_ProcessY_CODE
       OR (Process_CODE = @Lc_ProcessS_CODE
           AND FileLoad_DATE < DATEADD(DD, -@Li_NumberOfDays_QNTY, @Ld_Run_DATE));

   SET @Ld_LastDayCurrentMonth_DATE = DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @Ld_Run_DATE) + 1, 0));
   SET @Ld_LastDayPreviousMonth_DATE = DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @Ld_Run_DATE), 0));
   SET @Ls_Select_TEXT = 'SELECT * FROM (';
   SET @Ls_OrderBy_TEXT = ') a ORDER BY 
				CASE 
					WHEN a.Program_CODE LIKE ''A%'' THEN ''A''
					WHEN a.Program_CODE LIKE ''M%'' THEN ''M''
					WHEN a.Program_CODE LIKE ''C%'' THEN ''N''
				END';
   SET @Ls_OpenQuery_TEXT = 'SELECT DISTINCT 
									CAST(CaseWelfare_IDNO AS VARCHAR) AS CaseWelfare_IDNO,
									CAST(CpMci_IDNO AS VARCHAR) AS CpMci_IDNO,
									CAST(NcpMci_IDNO AS VARCHAR) AS NcpMci_IDNO,
									CAST(AgSequence_NUMB AS VARCHAR) AS AgSequence_NUMB,
									''' + @Lc_StatusCaseOpen_CODE + ''' AS StatusCase_CODE,
									CAST(ChildMci_IDNO AS VARCHAR) AS ChildMci_IDNO,
									REPLACE(Program_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS Program_CODE,
									REPLACE(SubProgram_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS SubProgram_CODE,
									REPLACE(IntactFamilyStatus_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS IntactFamilyStatus_CODE,
									ISNULL(CONVERT(VARCHAR, ChildElig_DATE,112),''' + @Lc_Space_TEXT + ''') AS ChildElig_DATE,
									CAST(WelfareCaseCounty_IDNO AS VARCHAR) AS WelfareCaseCounty_IDNO,
									REPLACE(ChildFirst_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS ChildFirst_NAME,
									REPLACE(ChildMiddle_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS ChildMiddle_NAME,
									REPLACE(ChildLast_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS ChildLast_NAME,
									REPLACE(ChildSuffix_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') ChildSuffix_NAME,
									ISNULL(CONVERT(VARCHAR, ChildBirth_DATE,112),''' + @Lc_Space_TEXT + ''') AS ChildBirth_DATE,
									CAST(ChildSsn_NUMB AS VARCHAR) AS ChildSsn_NUMB,
									REPLACE(ChildSex_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS ChildSex_CODE,
									REPLACE(ChildRace_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS ChildRace_CODE,
									REPLACE(ChildPaternityStatus_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS ChildPaternityStatus_CODE,
									REPLACE(CpRelationshipToChild_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpRelationshipToChild_CODE,
									NcpRelationshipToChild_CODE AS NcpRelationshipToChild_CODE,
									''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
									''' + @Lc_ProcessN_CODE + ''' AS Process_CODE
								FROM OPENQUERY(' + @Lc_LinkedServer_CODE + ',''';
   --13486 - CR0388 Inclusion of MAGI Codes 20140527 -START-
   SET @Ls_TransactionSql_TEXT = 'SELECT DISTINCT 
					a.CASE_NUM "CaseWelfare_IDNO", 
					c.MCI_NUM "CpMci_IDNO", 
					CASE 
						WHEN b.AP_SEQ_NUM = 0 OR b.AP_SEQ_NUM IS NULL OR h.AP_MCI_NUM IS NULL THEN 0
						WHEN b.AP_SEQ_NUM != 0 AND h.AP_MCI_NUM = 0 THEN ' + @Lc_UnknownMciIdno_TEXT + '
						ELSE h.AP_MCI_NUM
					END "NcpMci_IDNO", 
					COALESCE(a.AG_SEQ_NUM,0) "AgSequence_NUMB",	
					a.MCI_NUM "ChildMci_IDNO",
					COALESCE(STRIP(a.PROGRAM_CD),''''' + @Lc_Space_TEXT + ''''') "Program_CODE",
					COALESCE(STRIP(a.SUBPROGRAM_CD),''''' + @Lc_Space_TEXT + ''''') "SubProgram_CODE",
					CASE (SELECT 1 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG x 
							WHERE x.CASE_NUM = a.CASE_NUM 
							AND x.PROGRAM_CD = a.PROGRAM_CD
							AND x.SUBPROGRAM_CD = a.SUBPROGRAM_CD
							AND x.AG_SEQ_NUM = a.AG_SEQ_NUM
							AND x.MCI_NUM = h.AP_MCI_NUM 
							AND x.AG_STS_CD = a.AG_STS_CD
						    AND x.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
						    AND x.PART_STS_CD = ''''' + @Lc_PartStatusEA_CODE + '''''
						    AND x.PAYMENT_END_DT > ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
							FETCH FIRST 1 ROW ONLY)
						WHEN 1 THEN ''''' + @Lc_ProcessY_CODE + '''''
						ELSE ''''' + @Lc_ProcessN_CODE + '''''  
					END  "IntactFamilyStatus_CODE",
					a.PAYMENT_BEGIN_DT "ChildElig_DATE",
					CASE
						WHEN e.COUNTY_NUM NOT IN (' + @Lc_WelfareCaseCounty1_IDNO + ',' + @Lc_WelfareCaseCounty5_IDNO + ',' + @Lc_WelfareCaseCounty3_IDNO + ') THEN ' + @Lc_WelfareCaseCounty3_IDNO + '
						ELSE e.COUNTY_NUM 
					END "WelfareCaseCounty_IDNO",
					COALESCE(STRIP(d.FST_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildFirst_NAME",
					COALESCE(STRIP(d.MID_INIT_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildMiddle_NAME",
					COALESCE(STRIP(d.LST_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildLast_NAME",
					COALESCE(STRIP(d.SUF_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildSuffix_NAME",
					d.BIRTH_DT "ChildBirth_DATE", 
					COALESCE(d.SOC_SEC_NUM, 0 )"ChildSsn_NUMB",
					COALESCE(STRIP(d.SEX_CD),''''' + @Lc_Space_TEXT + ''''') "ChildSex_CODE",
					COALESCE(STRIP(d.ETHNIC_CD),''''' + @Lc_Space_TEXT + ''''') "ChildRace_CODE",
					COALESCE(STRIP(m.DIV_PAT_IND),''''' + @Lc_Space_TEXT + ''''') "ChildPaternityStatus_CODE",
					COALESCE(STRIP(hr.REL_CD),''''' + @Lc_Space_TEXT + ''''') "CpRelationshipToChild_CODE",
					CASE 
						WHEN i.SEX_CD = ''''' + @Lc_SexM_CODE + ''''' THEN ''''' + @Lc_RelationshipToChildFtr_CODE + '''''
						WHEN i.SEX_CD = ''''' + @Lc_SexF_CODE + ''''' THEN ''''' + @Lc_RelationshipToChildMtr_CODE + '''''
						ELSE ''''' + @Lc_Space_TEXT + '''''
					END "NcpRelationshipToChild_CODE"
			 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
			INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0692_CS_AP_CHILD b ON a.CASE_NUM = b.CASE_NUM AND a.MCI_NUM = b.CHILD_MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT d ON a.MCI_NUM = d.MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0001_CASE e ON e.CASE_NUM = a.CASE_NUM
			 LEFT JOIN (SELECT REFERENCE_MCI_NUM, REL_CD, SOURCE_MCI_NUM, CASE_NUM
			              FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0116_CS_IN_HH_REL xy
						 WHERE xy.HISTORY_SEQ_NUM = (SELECT MAX(HISTORY_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0116_CS_IN_HH_REL x
													  WHERE x.CASE_NUM = xy.CASE_NUM
														AND x.REFERENCE_MCI_NUM = xy.REFERENCE_MCI_NUM
														AND x.SOURCE_MCI_NUM = xy.SOURCE_MCI_NUM )
						   AND xy.HISTORY_CD = 0) hr ON hr.CASE_NUM = a.CASE_NUM AND hr.REFERENCE_MCI_NUM = a.MCI_NUM AND hr.SOURCE_MCI_NUM = c.MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0032_AP_DEMO_INFO h ON h.AP_SEQ_NUM = b.AP_SEQ_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT i ON i.MCI_NUM = h.AP_MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0034_AP_COURT_ORD m ON m.AP_SEQ_NUM = b.AP_SEQ_NUM AND b.AP_SEQ_NUM <> 0
			WHERE a.CASE_NUM IN 
				  (SELECT DISTINCT CASE_NUM FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0354_IVA_IVD_TRIG
					WHERE TRIGGER_TYPE_IND = ''''' + @Lc_TriggerTypeIndcNumb_TEXT + '''''
					  AND TRIG_REQ_DT > ''''' + CAST(@Ld_LastRun_DATE AS VARCHAR(10)) + '''''
					  AND TRIG_REQ_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
					  AND ((PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''')))
			  AND ((a.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
					   OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
					   OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND a.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
					   OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
					   OR (a.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
					   OR (a.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + '''''))
			  AND a.AG_SEQ_NUM = (SELECT MAX(AG_SEQ_NUM) 
			                        FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
								   WHERE a.CASE_NUM = b.CASE_NUM
									 AND b.PROGRAM_CD = a.PROGRAM_CD 
									 AND b.SUBPROGRAM_CD = a.SUBPROGRAM_CD
									 AND a.MCI_NUM = b.MCI_NUM
									 AND b.AG_STS_CD = a.AG_STS_CD
									 AND b.PAYMENT_END_DT = a.PAYMENT_END_DT)
			  AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
			  AND a.AG_STS_CD = ''''' + @Lc_AgStatus_CODE + '''''
			  AND a.PART_STS_CD = ''''' + @Lc_PartStatus_CODE + '''''
			  AND ((a.PAYMENT_BEGIN_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' AND a.PAYMENT_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''')
					OR
				   (a.PAYMENT_BEGIN_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' AND a.PAYMENT_END_DT = ''''' + CAST(@Ld_LastDayCurrentMonth_DATE AS VARCHAR(10)) + '''''
					 AND EXISTS (SELECT 1
								   FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG x 
								  WHERE a.CASE_NUM = x.CASE_NUM 
									AND a.PROGRAM_CD = x.PROGRAM_CD 
									AND a.SUBPROGRAM_CD = x.SUBPROGRAM_CD
									AND a.MCI_NUM = x.MCI_NUM
									AND x.AG_SEQ_NUM = a.AG_SEQ_NUM
									AND x.PAYMENT_BEGIN_DT > ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' 
									AND x.PAYMENT_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''')))
			  AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitch_INDC + '''''
			  AND (d.DEATH_DT IS NULL OR d.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR d.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
			  AND (i.DEATH_DT IS NULL OR i.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR i.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
			  AND c.SUBPROGRAM_CD = a.SUBPROGRAM_CD
			  AND c.AG_SEQ_NUM = a.AG_SEQ_NUM
			  AND c.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
			  AND c.AG_STS_CD = a.AG_STS_CD
			  AND c.PROGRAM_CD = a.PROGRAM_CD
			  AND c.PAYMENT_BEGIN_DT = a.PAYMENT_BEGIN_DT
			  AND c.PAYMENT_END_DT = a.PAYMENT_END_DT
			  AND c.PART_STS_CD IN ( ''''' + @Lc_PartStatusEA_CODE + ''''', ''''' + @Lc_PartStatusCA_CODE + ''''')
			  AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitch_INDC + ''''' '')';
   --13486 - CR0388 Inclusion of MAGI Codes 20140527 -END-
   -- Insert the data into LIVAR_Y1 Load table
   SET @Ls_Sql_TEXT = 'INSERT LIVAR_Y1 CASE IN TRIGGER ';
   SET @Ls_Sqldata_TEXT = '';

   INSERT LIVAR_Y1
          (CaseWelfare_IDNO,
           CpMci_IDNO,
           NcpMci_IDNO,
           AgSequence_NUMB,
           StatusCase_CODE,
           ChildMci_IDNO,
           Program_CODE,
           SubProgram_CODE,
           IntactFamilyStatus_CODE,
           ChildElig_DATE,
           WelfareCaseCounty_IDNO,
           ChildFirst_NAME,
           ChildMiddle_NAME,
           ChildLast_NAME,
           ChildSuffix_NAME,
           ChildBirth_DATE,
           ChildSsn_NUMB,
           ChildSex_CODE,
           ChildRace_CODE,
           ChildPaternityStatus_CODE,
           CpRelationshipToChild_CODE,
           NcpRelationshipToChild_CODE,
           FileLoad_DATE,
           Process_CODE)
   EXECUTE (@Ls_Select_TEXT + @Ls_OpenQuery_TEXT+@Ls_TransactionSql_TEXT + @Ls_OrderBy_TEXT);

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     SET @Lb_GetDetailsInTrigger_BIT = 1;
    END

   --13486 - CR0388 Inclusion of MAGI Codes 20140527 -START-
   SET @Ls_TransactionSql_TEXT = 'SELECT DISTINCT 
					a.CASE_NUM "CaseWelfare_IDNO", 
					c.MCI_NUM "CpMci_IDNO", 
					CASE 
						WHEN b.AP_SEQ_NUM = 0 OR b.AP_SEQ_NUM IS NULL OR h.AP_MCI_NUM IS NULL THEN 0
						WHEN b.AP_SEQ_NUM != 0 AND h.AP_MCI_NUM = 0 THEN ' + @Lc_UnknownMciIdno_TEXT + '
						ELSE h.AP_MCI_NUM
					END "NcpMci_IDNO", 
					COALESCE(a.AG_SEQ_NUM,0) "AgSequence_NUMB",
					a.MCI_NUM "ChildMci_IDNO",
					COALESCE(STRIP(a.PROGRAM_CD),''''' + @Lc_Space_TEXT + ''''') "Program_CODE",
					COALESCE(STRIP(a.SUBPROGRAM_CD),''''' + @Lc_Space_TEXT + ''''') "SubProgram_CODE", 
					CASE (SELECT 1 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG x 
							WHERE x.CASE_NUM = a.CASE_NUM 
							AND x.PROGRAM_CD = a.PROGRAM_CD
							AND x.SUBPROGRAM_CD = a.SUBPROGRAM_CD
							AND x.AG_SEQ_NUM = a.AG_SEQ_NUM
							AND x.MCI_NUM = h.AP_MCI_NUM 
							AND x.AG_STS_CD = a.AG_STS_CD
						    AND x.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
						    AND x.PART_STS_CD = ''''' + @Lc_PartStatusEA_CODE + '''''
						    AND x.PAYMENT_END_DT > ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
							FETCH FIRST 1 ROW ONLY)
						WHEN 1 THEN ''''' + @Lc_ProcessY_CODE + '''''
						ELSE ''''' + @Lc_ProcessN_CODE + '''''  
					END  "IntactFamilyStatus_CODE",
					a.PAYMENT_BEGIN_DT "ChildElig_DATE",
					CASE
						WHEN e.COUNTY_NUM NOT IN (' + @Lc_WelfareCaseCounty1_IDNO + ',' + @Lc_WelfareCaseCounty5_IDNO + ',' + @Lc_WelfareCaseCounty3_IDNO + ') THEN ' + @Lc_WelfareCaseCounty3_IDNO + '
						ELSE e.COUNTY_NUM 
					END "WelfareCaseCounty_IDNO",
					COALESCE(STRIP(d.FST_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildFirst_NAME",
					COALESCE(STRIP(d.MID_INIT_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildMiddle_NAME",
					COALESCE(STRIP(d.LST_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildLast_NAME",
					COALESCE(STRIP(d.SUF_NAM),''''' + @Lc_Space_TEXT + ''''') "ChildSuffix_NAME",
					d.BIRTH_DT "ChildBirth_DATE", 
					COALESCE(d.SOC_SEC_NUM, 0 )"ChildSsn_NUMB",
					COALESCE(STRIP(d.SEX_CD),''''' + @Lc_Space_TEXT + ''''') "ChildSex_CODE",
					COALESCE(STRIP(d.ETHNIC_CD),''''' + @Lc_Space_TEXT + ''''') "ChildRace_CODE",
					COALESCE(STRIP(m.DIV_PAT_IND),''''' + @Lc_Space_TEXT + ''''') "ChildPaternityStatus_CODE",
					COALESCE(STRIP(hr.REL_CD),''''' + @Lc_Space_TEXT + ''''') "CpRelationshipToChild_CODE",
					CASE 
						WHEN i.SEX_CD = ''''' + @Lc_SexM_CODE + ''''' THEN ''''' + @Lc_RelationshipToChildFtr_CODE + '''''
						WHEN i.SEX_CD = ''''' + @Lc_SexF_CODE + ''''' THEN ''''' + @Lc_RelationshipToChildMtr_CODE + '''''
						ELSE ''''' + @Lc_Space_TEXT + '''''
					END "NcpRelationshipToChild_CODE"
			 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
			INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0692_CS_AP_CHILD b ON a.CASE_NUM = b.CASE_NUM AND a.MCI_NUM = b.CHILD_MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT d ON a.MCI_NUM = d.MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0001_CASE e ON e.CASE_NUM = a.CASE_NUM
			 LEFT JOIN (SELECT REFERENCE_MCI_NUM, REL_CD, SOURCE_MCI_NUM, CASE_NUM FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0116_CS_IN_HH_REL xy 
							 WHERE xy.HISTORY_SEQ_NUM = (SELECT MAX(HISTORY_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0116_CS_IN_HH_REL x 
															WHERE x.CASE_NUM = xy.CASE_NUM
															AND x.REFERENCE_MCI_NUM = xy.REFERENCE_MCI_NUM 
															AND x.SOURCE_MCI_NUM = xy.SOURCE_MCI_NUM )
							 AND xy.HISTORY_CD = 0) hr ON hr.CASE_NUM = a.CASE_NUM AND hr.REFERENCE_MCI_NUM = a.MCI_NUM AND hr.SOURCE_MCI_NUM = c.MCI_NUM 				
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0032_AP_DEMO_INFO h ON h.AP_SEQ_NUM = b.AP_SEQ_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT i ON i.MCI_NUM = h.AP_MCI_NUM
			 LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0034_AP_COURT_ORD m ON m.AP_SEQ_NUM = b.AP_SEQ_NUM AND b.AP_SEQ_NUM <> 0
			WHERE a.CASE_NUM NOT IN 
				 ( SELECT DISTINCT CASE_NUM FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0354_IVA_IVD_TRIG
					WHERE TRIGGER_TYPE_IND = ''''' + @Lc_TriggerTypeIndcNumb_TEXT + '''''
					  AND TRIG_REQ_DT > ''''' + CAST(@Ld_LastRun_DATE AS VARCHAR(10)) + '''''
					  AND TRIG_REQ_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
					  AND ((PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
						    OR (PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''')))
		      AND ((a.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
					 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
					 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND a.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
					 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
					 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
					 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + '''''))
			  AND a.AG_SEQ_NUM = (SELECT MAX(AG_SEQ_NUM) 
			                        FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
								   WHERE a.CASE_NUM = b.CASE_NUM
									 AND b.PROGRAM_CD = a.PROGRAM_CD 
									 AND b.SUBPROGRAM_CD = a.SUBPROGRAM_CD
									 AND a.MCI_NUM = b.MCI_NUM
									 AND b.AG_STS_CD = a.AG_STS_CD
									 AND b.PAYMENT_END_DT = a.PAYMENT_END_DT)
			  AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
			  AND a.AG_STS_CD = ''''' + @Lc_AgStatus_CODE + '''''
			  AND a.PART_STS_CD = ''''' + @Lc_PartStatus_CODE + '''''
			  AND (a.PAYMENT_BEGIN_DT = ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' AND a.PAYMENT_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + '''''
				    AND NOT EXISTS (SELECT 1
									  FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG x 
									 WHERE a.CASE_NUM = x.CASE_NUM 
									   AND a.PROGRAM_CD = x.PROGRAM_CD 
									   AND a.SUBPROGRAM_CD = x.SUBPROGRAM_CD
									   AND a.MCI_NUM = x.MCI_NUM
									   AND x.AG_SEQ_NUM = a.AG_SEQ_NUM
									   AND x.PAYMENT_BEGIN_DT < ''''' + CAST(@Ld_LastDayPreviousMonth_DATE AS VARCHAR(10)) + ''''' 
									   AND x.PAYMENT_END_DT = ''''' + CAST(@Ld_LastDayPreviousMonth_DATE AS VARCHAR(10)) + '''''))
			  AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitch_INDC + '''''
			  AND (d.DEATH_DT IS NULL OR d.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR d.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
			  AND (i.DEATH_DT IS NULL OR i.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR i.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
			  AND c.SUBPROGRAM_CD = a.SUBPROGRAM_CD
			  AND c.AG_SEQ_NUM = a.AG_SEQ_NUM
			  AND c.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
			  AND c.AG_STS_CD = a.AG_STS_CD
			  AND c.PROGRAM_CD = a.PROGRAM_CD
			  AND c.PAYMENT_BEGIN_DT = a.PAYMENT_BEGIN_DT
			  AND c.PAYMENT_END_DT = a.PAYMENT_END_DT
			  AND c.PART_STS_CD IN ( ''''' + @Lc_PartStatusEA_CODE + ''''', ''''' + @Lc_PartStatusCA_CODE + ''''')
			  AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitch_INDC + ''''' '')';
   --13486 - CR0388 Inclusion of MAGI Codes 20140527 -END-
   -- Insert the data into LIVAR_Y1 Load table
   SET @Ls_Sql_TEXT = 'INSERT LIVAR_Y1 CASE NOT IN TRIGGER ';
   SET @Ls_Sqldata_TEXT = '';

   INSERT LIVAR_Y1
          (CaseWelfare_IDNO,
           CpMci_IDNO,
           NcpMci_IDNO,
           AgSequence_NUMB,
           StatusCase_CODE,
           ChildMci_IDNO,
           Program_CODE,
           SubProgram_CODE,
           IntactFamilyStatus_CODE,
           ChildElig_DATE,
           WelfareCaseCounty_IDNO,
           ChildFirst_NAME,
           ChildMiddle_NAME,
           ChildLast_NAME,
           ChildSuffix_NAME,
           ChildBirth_DATE,
           ChildSsn_NUMB,
           ChildSex_CODE,
           ChildRace_CODE,
           ChildPaternityStatus_CODE,
           CpRelationshipToChild_CODE,
           NcpRelationshipToChild_CODE,
           FileLoad_DATE,
           Process_CODE)
   EXECUTE (@Ls_Select_TEXT + @Ls_OpenQuery_TEXT+@Ls_TransactionSql_TEXT + @Ls_OrderBy_TEXT);

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_ProcessedRecordCount_QNTY <> 0
    BEGIN
     SET @Lb_GetDetailsNotInTrigger_BIT = 1;
    END

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM LIVAR_Y1
                                         WHERE FileLoad_DATE = @Ld_Run_DATE);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     -- Zero records to load.
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     -- Delete Processed Records in LOAD job:
     SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS FROM LIVAD_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = '';

     DELETE LIVAD_Y1
      WHERE Process_CODE = @Lc_ProcessY_CODE
         OR (Process_CODE = @Lc_ProcessS_CODE
             AND FileLoad_DATE < DATEADD(DD, -@Li_NumberOfDays_QNTY, @Ld_Run_DATE));

     SET @Ls_OpenQuery_TEXT = 'SELECT DISTINCT 
	CAST(CaseWelfare_IDNO AS VARCHAR) AS CaseWelfare_IDNO,
	CAST(CpMci_IDNO AS VARCHAR) AS CpMci_IDNO,
	CAST(NcpMci_IDNO AS VARCHAR) AS NcpMci_IDNO,
	CAST(AgSequence_NUMB AS VARCHAR) AS AgSequence_NUMB,
	CAST(ApSequence_NUMB AS VARCHAR) AS ApSequence_NUMB,
	
	REPLACE(CpFirst_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpFirst_NAME,
	REPLACE(CpMiddle_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpMiddle_NAME,
	REPLACE(CpLast_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpLast_NAME,
	REPLACE(CpSuffix_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') CpSuffix_NAME,
	ISNULL(CONVERT(VARCHAR, CpBirth_DATE,112),''' + @Lc_Space_TEXT + ''') AS CpBirth_DATE,
	CAST(CpSsn_NUMB AS VARCHAR) AS CpSsn_NUMB,
	REPLACE(CpSex_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpSex_CODE,
	REPLACE(CpRace_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpRace_CODE,
	
	''' + @Lc_AddrNormalizationU_CODE + ''' AS CpAddrNormalization_CODE,
	CASE
		WHEN RTRIM(LTRIM(REPLACE(ST_NUMBER_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(UNIT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(DIRECTION_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(ST_RURAL_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(SUFFIX_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(QUADRANT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(APARTMENT_ADR,CHAR(0),''' + @Lc_Space_TEXT + '''))) = '''' THEN ''' + @Lc_Space_TEXT + '''
		ELSE SUBSTRING(RTRIM(LTRIM(REPLACE(ST_NUMBER_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(UNIT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(DIRECTION_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(ST_RURAL_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(SUFFIX_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(QUADRANT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(APARTMENT_ADR,CHAR(0),''' + @Lc_Space_TEXT + '''))),1,50)
	END AS CpLine1_ADDR,
	REPLACE(LINE_2_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpLine2_ADDR,
	REPLACE(CITY_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpCity_ADDR,
	REPLACE(STATE_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpState_ADDR,
	REPLACE(ZIP_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpZip_ADDR,
	
	REPLACE(CpEmployer_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpEmployer_NAME,
	LEFT(CAST(CpEmployerFEIN_IDNO AS VARCHAR),9) AS CpEmployerFEIN_IDNO,
	''' + @Lc_AddrNormalizationU_CODE + ''' AS CpEmpAddrNormalization_CODE,
	REPLACE(CpEmployerLine1_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpEmployerLine1_ADDR,
	REPLACE(CpEmployerLine2_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpEmployerLine2_ADDR,
	REPLACE(CpEmployerCity_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpEmployerCity_ADDR,
	REPLACE(CpEmployerState_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpEmployerState_ADDR,
	REPLACE(CpEmployerZip_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpEmployerZip_ADDR,
	
	REPLACE(NcpFirst_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpFirst_NAME,
	REPLACE(NcpMiddle_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpMiddle_NAME,
	REPLACE(NcpLast_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpLast_NAME,
	REPLACE(NcpSuffix_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') NcpSuffix_NAME,
	ISNULL(CONVERT(VARCHAR, NcpBirth_DATE,112),''' + @Lc_Space_TEXT + ''') AS NcpBirth_DATE,
	CAST(NcpSsn_NUMB AS VARCHAR) AS NcpSsn_NUMB,
	REPLACE(NcpSex_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpSex_CODE,
	REPLACE(NcpRace_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpRace_CODE,
	
	''' + @Lc_AddrNormalizationU_CODE + ''' AS NcpAddrNormalization_CODE,
	CASE
		WHEN RTRIM(LTRIM(REPLACE(AP_ST_NUMBER_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_UNIT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_DIRECTION_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_ST_RURAL_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_SUFFIX_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_QUADRANT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_APARTMENT_ADR,CHAR(0),''' + @Lc_Space_TEXT + '''))) = '''' THEN ''' + @Lc_Space_TEXT + '''
		ELSE SUBSTRING(RTRIM(LTRIM(REPLACE(AP_ST_NUMBER_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_UNIT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_DIRECTION_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_ST_RURAL_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_SUFFIX_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_QUADRANT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(AP_APARTMENT_ADR,CHAR(0),''' + @Lc_Space_TEXT + '''))),1,50)
	END AS NcpLine1_ADDR,
	REPLACE(AP_LINE_2_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpLine2_ADDR,
	REPLACE(AP_CITY_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''')	AS NcpCity_ADDR,
	REPLACE(AP_STATE_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpState_ADDR,
	REPLACE(AP_ZIP_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpZip_ADDR,
	
	REPLACE(NcpEmployer_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpEmployer_NAME,
	0 AS NcpEmployerFEIN_IDNO,
	''' + @Lc_AddrNormalizationU_CODE + ''' AS NcpEmpAddrNormalization_CODE,
	REPLACE(NcpEmployerLine1_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpEmployerLine1_ADDR,
	REPLACE(NcpEmployerLine2_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpEmployerLine2_ADDR,
	REPLACE(NcpEmployerCity_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpEmployerCity_ADDR,
	REPLACE(NcpEmployerState_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpEmployerState_ADDR,
	REPLACE(NcpEmployerZip_ADDR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpEmployerZip_ADDR,
	
	REPLACE(NcpInsuranceProvider_NAME,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpInsuranceProvider_NAME,
	REPLACE(NcpPolicyInsNo_TEXT,CHAR(0),''' + @Lc_Space_TEXT + ''') AS NcpPolicyInsNo_TEXT,
	
	CAST(OrderSeq_NUMB AS VARCHAR) AS OrderSeq_NUMB,
	ISNULL(CONVERT(VARCHAR, OrderIssued_DATE,112),''' + @Lc_Space_TEXT + ''') AS OrderIssued_DATE,
	CAST(Order_AMNT AS VARCHAR) AS Order_AMNT,
	REPLACE(FreqPay_CODE,CHAR(0),''' + @Lc_Space_TEXT + ''') AS FreqPay_CODE,
	''' + @Lc_PaymentTypeSDU_CODE + ''' AS PaymentType_CODE,
	CAST(PaymentLastReceived_AMNT AS VARCHAR) AS PaymentLastReceived_AMNT,
	ISNULL(CONVERT(VARCHAR, PaymentLastReceived_DATE,112),''' + @Lc_Space_TEXT + ''') AS PaymentLastReceived_DATE,
	0 AS TotalArrears_AMNT,
	''' + @Lc_LowDate_TEXT + ''' AS PaymentDue_DATE,
	''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
	''' + @Lc_ProcessN_CODE + ''' AS Process_CODE
FROM OPENQUERY(' + @Lc_LinkedServer_CODE + ',''';

     IF @Lb_GetDetailsInTrigger_BIT = 1
      BEGIN
       --13486 - CR0388 Inclusion of MAGI Codes 20140527 -START-
	   SET @Ls_TransactionSql_TEXT = 'SELECT DISTINCT
	a.CASE_NUM "CaseWelfare_IDNO",
	c.MCI_NUM "CpMci_IDNO",
	CASE WHEN b.AP_SEQ_NUM = 0 OR b.AP_SEQ_NUM IS NULL OR h.AP_MCI_NUM IS NULL THEN 0
		 WHEN b.AP_SEQ_NUM != 0 AND h.AP_MCI_NUM = 0 THEN ' + @Lc_UnknownMciIdno_TEXT + '
	 ELSE h.AP_MCI_NUM
	END "NcpMci_IDNO",
	a.AG_SEQ_NUM "AgSequence_NUMB",
	COALESCE(b.AP_SEQ_NUM,0) "ApSequence_NUMB",

	COALESCE(STRIP(j.FST_NAM),''''' + @Lc_Space_TEXT + ''''') "CpFirst_NAME",
	COALESCE(STRIP(j.MID_INIT_NAM),''''' + @Lc_Space_TEXT + ''''') "CpMiddle_NAME",
	COALESCE(STRIP(j.LST_NAM),''''' + @Lc_Space_TEXT + ''''') "CpLast_NAME",
	COALESCE(STRIP(j.SUF_NAM),''''' + @Lc_Space_TEXT + ''''') "CpSuffix_NAME",
	j.BIRTH_DT "CpBirth_DATE",
	COALESCE(j.SOC_SEC_NUM, 0) "CpSsn_NUMB",
	COALESCE(STRIP(j.SEX_CD),''''' + @Lc_Space_TEXT + ''''') "CpSex_CODE",
	COALESCE(STRIP(j.ETHNIC_CD),''''' + @Lc_Space_TEXT + ''''') "CpRace_CODE",

	COALESCE(STRIP(e.ST_NUMBER_ADR),''''' + @Lc_Space_TEXT + ''''') "ST_NUMBER_ADR",
	COALESCE(STRIP(e.UNIT_ADR),''''' + @Lc_Space_TEXT + ''''') "UNIT_ADR",
	COALESCE(STRIP(e.DIRECTION_ADR),''''' + @Lc_Space_TEXT + ''''') "DIRECTION_ADR",
	COALESCE(STRIP(e.ST_RURAL_ADR),''''' + @Lc_Space_TEXT + ''''') "ST_RURAL_ADR",
	COALESCE(STRIP(e.SUFFIX_ADR),''''' + @Lc_Space_TEXT + ''''') "SUFFIX_ADR",
	COALESCE(STRIP(e.QUADRANT_ADR),''''' + @Lc_Space_TEXT + ''''') "QUADRANT_ADR",
	COALESCE(STRIP(e.APARTMENT_ADR),''''' + @Lc_Space_TEXT + ''''') "APARTMENT_ADR",
	COALESCE(STRIP(e.LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "LINE_2_ADR",
	COALESCE(STRIP(e.CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "CITY_ADR",
	COALESCE(STRIP(e.STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "STATE_ADR",
	COALESCE(STRIP(e.ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "ZIP_ADR",

	COALESCE(STRIP(l.EMPLOYER_NAM),''''' + @Lc_Space_TEXT + ''''') "CpEmployer_NAME",
	COALESCE(l.EMP_FEDERAL_ID,0) "CpEmployerFEIN_IDNO",
	COALESCE(STRIP(l.EMP_ADDRESS_TXT),''''' + @Lc_Space_TEXT + ''''') "CpEmployerLine1_ADDR",
	COALESCE(STRIP(l.EMPLOYER_LINE2_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerLine2_ADDR",
	COALESCE(STRIP(l.EMPLOYER_CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerCity_ADDR",
	COALESCE(STRIP(l.EMPLOYER_STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerState_ADDR",
	COALESCE(STRIP(l.EMPLOYER_ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerZip_ADDR",

	COALESCE(STRIP(i.FST_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpFirst_NAME",
	COALESCE(STRIP(i.MID_INIT_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpMiddle_NAME",
	COALESCE(STRIP(i.LST_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpLast_NAME",
	COALESCE(STRIP(i.SUF_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpSuffix_NAME",
	i.BIRTH_DT "NcpBirth_DATE",
	COALESCE(i.SOC_SEC_NUM, 0) "NcpSsn_NUMB",
	COALESCE(STRIP(i.SEX_CD),''''' + @Lc_Space_TEXT + ''''') "NcpSex_CODE",
	COALESCE(STRIP(i.ETHNIC_CD),''''' + @Lc_Space_TEXT + ''''') "NcpRace_CODE",

	COALESCE(STRIP(h.AP_ST_NUMBER_ADR),''''' + @Lc_Space_TEXT + ''''')  "AP_ST_NUMBER_ADR",
	COALESCE(STRIP(h.AP_UNIT_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_UNIT_ADR",
	COALESCE(STRIP(h.AP_DIRECTION_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_DIRECTION_ADR",
	COALESCE(STRIP(h.AP_ST_RURAL_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_ST_RURAL_ADR",
	COALESCE(STRIP(h.AP_SUFFIX_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_SUFFIX_ADR",
	COALESCE(STRIP(h.AP_QUADRANT_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_QUADRANT_ADR",
	COALESCE(STRIP(h.AP_APARTMENT_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_APARTMENT_ADR",
	COALESCE(STRIP(h.AP_LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_LINE_2_ADR",
	COALESCE(STRIP(h.AP_CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_CITY_ADR",
	COALESCE(STRIP(h.AP_STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_STATE_ADR",
	COALESCE(STRIP(h.AP_ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_ZIP_ADR",

	COALESCE(STRIP(k.EMP_CONTACT_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpEmployer_NAME",
	COALESCE(STRIP(k.EMP_LINE_1_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerLine1_ADDR",
	COALESCE(STRIP(k.EMP_LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerLine2_ADDR",
	COALESCE(STRIP(k.EMP_CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerCity_ADDR",
	COALESCE(STRIP(k.EMP_STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerState_ADDR",
	COALESCE(STRIP(k.EMP_ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerZip_ADDR",

	COALESCE(m.ORDER_SEQ_NUM,0) "OrderSeq_NUMB",
	m.CS_ORDER_DT "OrderIssued_DATE",
	COALESCE(m.CS_AMT,0) "Order_AMNT",
	COALESCE(STRIP(m.CS_FREQUENCY_CD),''''' + @Lc_Space_TEXT + ''''') "FreqPay_CODE",
	COALESCE(m.CS_LAST_AMT,0) "PaymentLastReceived_AMNT",
	m.CS_LAST_DT "PaymentLastReceived_DATE",

	COALESCE(STRIP(n.OTR_INS_COMP_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpInsuranceProvider_NAME",
	COALESCE(STRIP(n.OTR_INS_POLICY_NUM),''''' + @Lc_Space_TEXT + ''''') "NcpPolicyInsNo_TEXT"

FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0692_CS_AP_CHILD b ON a.CASE_NUM = b.CASE_NUM AND a.MCI_NUM = b.CHILD_MCI_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0001_CASE e ON e.CASE_NUM = a.CASE_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0032_AP_DEMO_INFO h ON h.AP_SEQ_NUM = b.AP_SEQ_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT i ON i.MCI_NUM = h.AP_MCI_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT j ON j.MCI_NUM = c.MCI_NUM
LEFT JOIN (SELECT MCI_NUM, EMPLOYER_NAM,EMP_FEDERAL_ID,EMP_ADDRESS_TXT,EMPLOYER_LINE2_ADR,EMPLOYER_CITY_ADR,EMPLOYER_STATE_ADR,EMPLOYER_ZIP_ADR
		FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0078_IN_EMP_INC a1 
	   WHERE a1.HISTORY_CD = 0                        
		 AND a1.SEQ_NUM =  (SELECT MAX(SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0078_IN_EMP_INC WHERE MCI_NUM = a1.MCI_NUM )
		 AND a1.HISTORY_SEQ_NUM = (SELECT MAX(HISTORY_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0078_IN_EMP_INC 
							WHERE MCI_NUM = a1.MCI_NUM AND SEQ_NUM =  a1.SEQ_NUM )) l ON l.MCI_NUM = c.MCI_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0034_AP_COURT_ORD m ON m.AP_SEQ_NUM = b.AP_SEQ_NUM AND b.AP_SEQ_NUM <> 0
LEFT JOIN (SELECT DISTINCT AP_SEQ_NUM, EMP_CONTACT_NAM,EMP_LINE_1_ADR,EMP_LINE_2_ADR,EMP_CITY_ADR,EMP_STATE_ADR,EMP_ZIP_ADR 
		FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0033_EMPL_INFO a1 
	   WHERE a1.EMP_SEQ_NUM =  ( SELECT MAX(e.EMP_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0033_EMPL_INFO e WHERE e.AP_SEQ_NUM = a1.AP_SEQ_NUM )
	  ) k ON k.AP_SEQ_NUM = b.AP_SEQ_NUM AND b.AP_SEQ_NUM <> 0
LEFT JOIN (	SELECT DISTINCT MCI_NUM,OTR_INS_COMP_NAM, OTR_INS_POLICY_NUM
		FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0642_MED_INFO a1 
	   WHERE a1.OTR_INS_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + '''''
		 AND a1.SEQUENCE_NUM =  ( SELECT MAX(m.SEQUENCE_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0642_MED_INFO m WHERE m.MCI_NUM = a1.MCI_NUM AND m.OTR_INS_END_DT = a1.OTR_INS_END_DT )
	  ) n ON n.MCI_NUM = h.AP_MCI_NUM AND b.AP_SEQ_NUM <> 0 AND h.AP_MCI_NUM <> 0
WHERE a.CASE_NUM IN 
 (SELECT DISTINCT CASE_NUM FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0354_IVA_IVD_TRIG
   WHERE TRIGGER_TYPE_IND = ''''' + @Lc_TriggerTypeIndcNumb_TEXT + '''''
	 AND TRIG_REQ_DT > ''''' + CAST(@Ld_LastRun_DATE AS VARCHAR(10)) + '''''
	 AND TRIG_REQ_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
	 AND ((PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
	      OR (PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
		  OR (PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
		  OR (PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
		  OR (PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
		  OR (PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''')))
AND ((a.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND a.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + '''''))
AND a.AG_SEQ_NUM = (SELECT MAX(AG_SEQ_NUM)
                      FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
					 WHERE a.CASE_NUM = b.CASE_NUM
					   AND b.PROGRAM_CD = a.PROGRAM_CD
					   AND b.SUBPROGRAM_CD = a.SUBPROGRAM_CD
					   AND a.MCI_NUM = b.MCI_NUM
					   AND b.AG_STS_CD = a.AG_STS_CD
					   AND b.PAYMENT_END_DT = a.PAYMENT_END_DT)
AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
AND a.AG_STS_CD = ''''' + @Lc_AgStatus_CODE + '''''
AND a.PART_STS_CD = ''''' + @Lc_PartStatus_CODE + '''''
AND ((a.PAYMENT_BEGIN_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' AND a.PAYMENT_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''')
	OR (a.PAYMENT_BEGIN_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' AND a.PAYMENT_END_DT = ''''' + CAST(@Ld_LastDayCurrentMonth_DATE AS VARCHAR(10)) + '''''
         AND EXISTS (SELECT 1
		               FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG x 
					  WHERE a.CASE_NUM = x.CASE_NUM
						AND a.PROGRAM_CD = x.PROGRAM_CD
						AND a.SUBPROGRAM_CD = x.SUBPROGRAM_CD
						AND a.MCI_NUM = x.MCI_NUM
						AND x.AG_SEQ_NUM = a.AG_SEQ_NUM
						AND x.PAYMENT_BEGIN_DT > ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
						AND x.PAYMENT_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''')))
AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitch_INDC + '''''
AND (i.DEATH_DT IS NULL OR i.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR i.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
AND (j.DEATH_DT IS NULL OR j.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR j.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
AND c.SUBPROGRAM_CD = a.SUBPROGRAM_CD
AND c.AG_SEQ_NUM = a.AG_SEQ_NUM
AND c.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
AND c.AG_STS_CD = a.AG_STS_CD
AND c.PROGRAM_CD = a.PROGRAM_CD
AND c.PAYMENT_BEGIN_DT = a.PAYMENT_BEGIN_DT
AND c.PAYMENT_END_DT = a.PAYMENT_END_DT
AND c.PART_STS_CD IN ( ''''' + @Lc_PartStatusEA_CODE + ''''', ''''' + @Lc_PartStatusCA_CODE + ''''')
AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitch_INDC + '''''
ORDER BY a.CASE_NUM '')';
       --13486 - CR0388 Inclusion of MAGI Codes 20140527 -END-

	   -- Inserting the data into details load table.
       SET @Ls_Sql_TEXT = 'INSERT LIVAD_Y1 CASE IN TRIGGER ';
       SET @Ls_Sqldata_TEXT = '';

       INSERT LIVAD_Y1
              (CaseWelfare_IDNO,
               CpMci_IDNO,
               NcpMci_IDNO,
               AgSequence_NUMB,
               ApSequence_NUMB,
               CpFirst_NAME,
               CpMiddle_NAME,
               CpLast_NAME,
               CpSuffix_NAME,
               CpBirth_DATE,
               CpSsn_NUMB,
               CpSex_CODE,
               CpRace_CODE,
               CpAddrNormalization_CODE,
               CpLine1_ADDR,
               CpLine2_ADDR,
               CpCity_ADDR,
               CpState_ADDR,
               CpZip_ADDR,
               CpEmployer_NAME,
               CpEmployerFein_IDNO,
               CpEmpAddrNormalization_CODE,
               CpEmployerLine1_ADDR,
               CpEmployerLine2_ADDR,
               CpEmployerCity_ADDR,
               CpEmployerState_ADDR,
               CpEmployerZip_ADDR,
               NcpFirst_NAME,
               NcpMiddle_NAME,
               NcpLast_NAME,
               NcpSuffix_NAME,
               NcpBirth_DATE,
               NcpSsn_NUMB,
               NcpSex_CODE,
               NcpRace_CODE,
               NcpAddrNormalization_CODE,
               NcpLine1_ADDR,
               NcpLine2_ADDR,
               NcpCity_ADDR,
               NcpState_ADDR,
               NcpZip_ADDR,
               NcpEmployer_NAME,
               NcpEmployerFEIN_IDNO,
               NcpEmpAddrNormalization_CODE,
               NcpEmployerLine1_ADDR,
               NcpEmployerLine2_ADDR,
               NcpEmployerCity_ADDR,
               NcpEmployerState_ADDR,
               NcpEmployerZip_ADDR,
               NcpInsuranceProvider_NAME,
               NcpPolicyInsNo_TEXT,
               OrderSeq_NUMB,
               OrderIssued_DATE,
               Order_AMNT,
               FreqPay_CODE,
               PaymentType_CODE,
               PaymentLastReceived_AMNT,
               PaymentLastReceived_DATE,
               TotalArrears_AMNT,
               PaymentDue_DATE,
               FileLoad_DATE,
               Process_CODE)
       EXECUTE (@Ls_OpenQuery_TEXT+@Ls_TransactionSql_TEXT);
      END

     IF @Lb_GetDetailsNotInTrigger_BIT = 1
      BEGIN
       --13486 - CR0388 Inclusion of MAGI Codes 20140527 -START-
	   SET @Ls_TransactionSql_TEXT = 'SELECT DISTINCT
	a.CASE_NUM "CaseWelfare_IDNO", 
	c.MCI_NUM "CpMci_IDNO", 
	CASE 
		WHEN b.AP_SEQ_NUM = 0 OR b.AP_SEQ_NUM IS NULL OR h.AP_MCI_NUM IS NULL THEN 0
		WHEN b.AP_SEQ_NUM != 0 AND h.AP_MCI_NUM = 0 THEN ' + @Lc_UnknownMciIdno_TEXT + '
		ELSE h.AP_MCI_NUM
		END "NcpMci_IDNO", 
	a.AG_SEQ_NUM "AgSequence_NUMB",
	COALESCE(b.AP_SEQ_NUM,0) "ApSequence_NUMB",
	
	COALESCE(STRIP(j.FST_NAM),''''' + @Lc_Space_TEXT + ''''') "CpFirst_NAME",
	COALESCE(STRIP(j.MID_INIT_NAM),''''' + @Lc_Space_TEXT + ''''') "CpMiddle_NAME",
	COALESCE(STRIP(j.LST_NAM),''''' + @Lc_Space_TEXT + ''''') "CpLast_NAME",
	COALESCE(STRIP(j.SUF_NAM),''''' + @Lc_Space_TEXT + ''''') "CpSuffix_NAME",
	j.BIRTH_DT "CpBirth_DATE", 
	COALESCE(j.SOC_SEC_NUM, 0) "CpSsn_NUMB",
	COALESCE(STRIP(j.SEX_CD),''''' + @Lc_Space_TEXT + ''''') "CpSex_CODE",
	COALESCE(STRIP(j.ETHNIC_CD),''''' + @Lc_Space_TEXT + ''''') "CpRace_CODE",
	
	COALESCE(STRIP(e.ST_NUMBER_ADR),''''' + @Lc_Space_TEXT + ''''') "ST_NUMBER_ADR",
	COALESCE(STRIP(e.UNIT_ADR),''''' + @Lc_Space_TEXT + ''''') "UNIT_ADR",
	COALESCE(STRIP(e.DIRECTION_ADR),''''' + @Lc_Space_TEXT + ''''') "DIRECTION_ADR",
	COALESCE(STRIP(e.ST_RURAL_ADR),''''' + @Lc_Space_TEXT + ''''') "ST_RURAL_ADR",
	COALESCE(STRIP(e.SUFFIX_ADR),''''' + @Lc_Space_TEXT + ''''') "SUFFIX_ADR",
	COALESCE(STRIP(e.QUADRANT_ADR),''''' + @Lc_Space_TEXT + ''''') "QUADRANT_ADR",
	COALESCE(STRIP(e.APARTMENT_ADR),''''' + @Lc_Space_TEXT + ''''') "APARTMENT_ADR",
	COALESCE(STRIP(e.LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "LINE_2_ADR",
	COALESCE(STRIP(e.CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "CITY_ADR",
	COALESCE(STRIP(e.STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "STATE_ADR",
	COALESCE(STRIP(e.ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "ZIP_ADR",
	
	COALESCE(STRIP(l.EMPLOYER_NAM),''''' + @Lc_Space_TEXT + ''''') "CpEmployer_NAME",
	COALESCE(l.EMP_FEDERAL_ID,0) "CpEmployerFEIN_IDNO",
	COALESCE(STRIP(l.EMP_ADDRESS_TXT),''''' + @Lc_Space_TEXT + ''''') "CpEmployerLine1_ADDR",
	COALESCE(STRIP(l.EMPLOYER_LINE2_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerLine2_ADDR",
	COALESCE(STRIP(l.EMPLOYER_CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerCity_ADDR",
	COALESCE(STRIP(l.EMPLOYER_STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerState_ADDR",
	COALESCE(STRIP(l.EMPLOYER_ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "CpEmployerZip_ADDR",
	
	COALESCE(STRIP(i.FST_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpFirst_NAME",
	COALESCE(STRIP(i.MID_INIT_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpMiddle_NAME",
	COALESCE(STRIP(i.LST_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpLast_NAME",
	COALESCE(STRIP(i.SUF_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpSuffix_NAME",
	i.BIRTH_DT "NcpBirth_DATE", 
	COALESCE(i.SOC_SEC_NUM, 0) "NcpSsn_NUMB",
	COALESCE(STRIP(i.SEX_CD),''''' + @Lc_Space_TEXT + ''''') "NcpSex_CODE",
	COALESCE(STRIP(i.ETHNIC_CD),''''' + @Lc_Space_TEXT + ''''') "NcpRace_CODE",
	
	COALESCE(STRIP(h.AP_ST_NUMBER_ADR),''''' + @Lc_Space_TEXT + ''''')  "AP_ST_NUMBER_ADR",
	COALESCE(STRIP(h.AP_UNIT_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_UNIT_ADR",
	COALESCE(STRIP(h.AP_DIRECTION_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_DIRECTION_ADR",
	COALESCE(STRIP(h.AP_ST_RURAL_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_ST_RURAL_ADR",
	COALESCE(STRIP(h.AP_SUFFIX_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_SUFFIX_ADR",
	COALESCE(STRIP(h.AP_QUADRANT_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_QUADRANT_ADR",
	COALESCE(STRIP(h.AP_APARTMENT_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_APARTMENT_ADR",
	COALESCE(STRIP(h.AP_LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_LINE_2_ADR",
	COALESCE(STRIP(h.AP_CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_CITY_ADR",
	COALESCE(STRIP(h.AP_STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_STATE_ADR",
	COALESCE(STRIP(h.AP_ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "AP_ZIP_ADR",
	
	COALESCE(STRIP(k.EMP_CONTACT_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpEmployer_NAME",
	COALESCE(STRIP(k.EMP_LINE_1_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerLine1_ADDR",
	COALESCE(STRIP(k.EMP_LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerLine2_ADDR",
	COALESCE(STRIP(k.EMP_CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerCity_ADDR",
	COALESCE(STRIP(k.EMP_STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerState_ADDR",
	COALESCE(STRIP(k.EMP_ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "NcpEmployerZip_ADDR",
	
	COALESCE(m.ORDER_SEQ_NUM,0) "OrderSeq_NUMB",
	m.CS_ORDER_DT "OrderIssued_DATE",
	COALESCE(m.CS_AMT,0) "Order_AMNT",
	COALESCE(STRIP(m.CS_FREQUENCY_CD),''''' + @Lc_Space_TEXT + ''''') "FreqPay_CODE",
	COALESCE(m.CS_LAST_AMT,0) "PaymentLastReceived_AMNT",
	m.CS_LAST_DT "PaymentLastReceived_DATE",
	
	COALESCE(STRIP(n.OTR_INS_COMP_NAM),''''' + @Lc_Space_TEXT + ''''') "NcpInsuranceProvider_NAME",
	COALESCE(STRIP(n.OTR_INS_POLICY_NUM),''''' + @Lc_Space_TEXT + ''''') "NcpPolicyInsNo_TEXT"
FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
INNER JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG c ON a.CASE_NUM = c.CASE_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0692_CS_AP_CHILD b ON a.CASE_NUM = b.CASE_NUM AND a.MCI_NUM = b.CHILD_MCI_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0001_CASE e ON e.CASE_NUM = a.CASE_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0032_AP_DEMO_INFO h ON h.AP_SEQ_NUM = b.AP_SEQ_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT i ON i.MCI_NUM = h.AP_MCI_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0540_CLIENT j ON j.MCI_NUM = c.MCI_NUM
LEFT JOIN (SELECT MCI_NUM, EMPLOYER_NAM,EMP_FEDERAL_ID,EMP_ADDRESS_TXT,EMPLOYER_LINE2_ADR,EMPLOYER_CITY_ADR,EMPLOYER_STATE_ADR,EMPLOYER_ZIP_ADR 
	FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0078_IN_EMP_INC a1 
	WHERE a1.HISTORY_CD = 0                        
	AND a1.SEQ_NUM = ( SELECT MAX(SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0078_IN_EMP_INC WHERE MCI_NUM = a1.MCI_NUM )
	AND a1.HISTORY_SEQ_NUM = (SELECT MAX(HISTORY_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0078_IN_EMP_INC 
								WHERE MCI_NUM = a1.MCI_NUM AND SEQ_NUM =  a1.SEQ_NUM )) l ON l.MCI_NUM = c.MCI_NUM
LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0034_AP_COURT_ORD m ON m.AP_SEQ_NUM = b.AP_SEQ_NUM AND b.AP_SEQ_NUM <> 0
LEFT JOIN ( SELECT DISTINCT 
			AP_SEQ_NUM, EMP_CONTACT_NAM,EMP_LINE_1_ADR,EMP_LINE_2_ADR,EMP_CITY_ADR,EMP_STATE_ADR,EMP_ZIP_ADR 
		FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0033_EMPL_INFO a1 
		WHERE a1.EMP_SEQ_NUM =  ( SELECT MAX(e.EMP_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0033_EMPL_INFO e WHERE e.AP_SEQ_NUM = a1.AP_SEQ_NUM )
	  ) k ON k.AP_SEQ_NUM = b.AP_SEQ_NUM AND b.AP_SEQ_NUM <> 0
LEFT JOIN (	SELECT DISTINCT 
			MCI_NUM,OTR_INS_COMP_NAM, OTR_INS_POLICY_NUM
		FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0642_MED_INFO a1 
		WHERE a1.OTR_INS_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + '''''
		AND a1.SEQUENCE_NUM =  ( SELECT MAX(m.SEQUENCE_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0642_MED_INFO m WHERE m.MCI_NUM = a1.MCI_NUM AND m.OTR_INS_END_DT = a1.OTR_INS_END_DT)
	  ) n ON n.MCI_NUM = h.AP_MCI_NUM AND b.AP_SEQ_NUM <> 0 AND h.AP_MCI_NUM <> 0
WHERE a.CASE_NUM NOT IN 
 ( SELECT DISTINCT CASE_NUM FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0354_IVA_IVD_TRIG
	WHERE TRIGGER_TYPE_IND = ''''' + @Lc_TriggerTypeIndcNumb_TEXT + '''''
	  AND TRIG_REQ_DT > ''''' + CAST(@Ld_LastRun_DATE AS VARCHAR(10)) + '''''
	  AND TRIG_REQ_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
	  AND ((PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
		    OR (PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
			OR (PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
			OR (PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
			OR (PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
			OR (PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''')))
AND ((a.PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' AND a.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' AND a.SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
	 OR (a.PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + '''''))
AND a.AG_SEQ_NUM = (SELECT MAX(AG_SEQ_NUM) FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG b
					 WHERE a.CASE_NUM = b.CASE_NUM
					   AND b.PROGRAM_CD = a.PROGRAM_CD 
					   AND b.SUBPROGRAM_CD = a.SUBPROGRAM_CD
					   AND a.MCI_NUM = b.MCI_NUM
					   AND b.AG_STS_CD = a.AG_STS_CD
					   AND b.PAYMENT_END_DT = a.PAYMENT_END_DT)
AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
AND a.AG_STS_CD = ''''' + @Lc_AgStatus_CODE + '''''
AND a.PART_STS_CD = ''''' + @Lc_PartStatus_CODE + '''''
AND (a.PAYMENT_BEGIN_DT = ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + ''''' AND a.PAYMENT_END_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + '''''
	  AND NOT EXISTS (SELECT 1
						FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG x 
					   WHERE a.CASE_NUM = x.CASE_NUM 
						 AND a.PROGRAM_CD = x.PROGRAM_CD 
						 AND a.SUBPROGRAM_CD = x.SUBPROGRAM_CD
						 AND a.MCI_NUM = x.MCI_NUM
						 AND x.AG_SEQ_NUM = a.AG_SEQ_NUM
						 AND x.PAYMENT_BEGIN_DT < ''''' + CAST(@Ld_LastDayPreviousMonth_DATE AS VARCHAR(10)) + ''''' 
						 AND x.PAYMENT_END_DT = ''''' + CAST(@Ld_LastDayPreviousMonth_DATE AS VARCHAR(10)) + '''''))
AND a.AG_PAYEE_SW <> ''''' + @Lc_AgPayeeSwitch_INDC + '''''
AND (i.DEATH_DT IS NULL OR i.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR i.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
AND (j.DEATH_DT IS NULL OR j.DEATH_DT = ''''' + CAST(@Lc_High_DATE AS VARCHAR(10)) + ''''' OR j.DEATH_DT = ''''' + CAST(CAST(@Lc_LowDate_TEXT AS DATE) AS VARCHAR(10)) + ''''')
AND c.SUBPROGRAM_CD = a.SUBPROGRAM_CD
AND c.AG_SEQ_NUM = a.AG_SEQ_NUM
AND c.CURRENT_ELIG_IND = a.CURRENT_ELIG_IND
AND c.AG_STS_CD = a.AG_STS_CD
AND c.PROGRAM_CD = a.PROGRAM_CD
AND c.PAYMENT_BEGIN_DT = a.PAYMENT_BEGIN_DT
AND c.PAYMENT_END_DT = a.PAYMENT_END_DT
AND c.PART_STS_CD IN ( ''''' + @Lc_PartStatusEA_CODE + ''''', ''''' + @Lc_PartStatusCA_CODE + ''''')
AND c.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitch_INDC + '''''
ORDER BY a.CASE_NUM '')';
       --13486 - CR0388 Inclusion of MAGI Codes 20140527 -END-
	   -- Inserting the data into details load table.
       SET @Ls_Sql_TEXT = 'INSERT LIVAD_Y1 CASE NOT IN TRIGGER ';
       SET @Ls_Sqldata_TEXT = '';

       INSERT LIVAD_Y1
              (CaseWelfare_IDNO,
               CpMci_IDNO,
               NcpMci_IDNO,
               AgSequence_NUMB,
               ApSequence_NUMB,
               CpFirst_NAME,
               CpMiddle_NAME,
               CpLast_NAME,
               CpSuffix_NAME,
               CpBirth_DATE,
               CpSsn_NUMB,
               CpSex_CODE,
               CpRace_CODE,
               CpAddrNormalization_CODE,
               CpLine1_ADDR,
               CpLine2_ADDR,
               CpCity_ADDR,
               CpState_ADDR,
               CpZip_ADDR,
               CpEmployer_NAME,
               CpEmployerFein_IDNO,
               CpEmpAddrNormalization_CODE,
               CpEmployerLine1_ADDR,
               CpEmployerLine2_ADDR,
               CpEmployerCity_ADDR,
               CpEmployerState_ADDR,
               CpEmployerZip_ADDR,
               NcpFirst_NAME,
               NcpMiddle_NAME,
               NcpLast_NAME,
               NcpSuffix_NAME,
               NcpBirth_DATE,
               NcpSsn_NUMB,
               NcpSex_CODE,
               NcpRace_CODE,
               NcpAddrNormalization_CODE,
               NcpLine1_ADDR,
               NcpLine2_ADDR,
               NcpCity_ADDR,
               NcpState_ADDR,
               NcpZip_ADDR,
               NcpEmployer_NAME,
               NcpEmployerFEIN_IDNO,
               NcpEmpAddrNormalization_CODE,
               NcpEmployerLine1_ADDR,
               NcpEmployerLine2_ADDR,
               NcpEmployerCity_ADDR,
               NcpEmployerState_ADDR,
               NcpEmployerZip_ADDR,
               NcpInsuranceProvider_NAME,
               NcpPolicyInsNo_TEXT,
               OrderSeq_NUMB,
               OrderIssued_DATE,
               Order_AMNT,
               FreqPay_CODE,
               PaymentType_CODE,
               PaymentLastReceived_AMNT,
               PaymentLastReceived_DATE,
               TotalArrears_AMNT,
               PaymentDue_DATE,
               FileLoad_DATE,
               Process_CODE)
       EXECUTE (@Ls_OpenQuery_TEXT+@Ls_TransactionSql_TEXT);
      END

     SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                            FROM LIVAD_Y1
                                           WHERE FileLoad_DATE = @Ld_Run_DATE);

     IF @Ln_ProcessedRecordCount_QNTY = 0
      BEGIN
       -- Zero records to load.
       SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD IN LIVAD_Y1 ';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
        @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
        @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
    END

   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Get the total number of records loaded in both the load tables.
   SET @Ls_Sql_TEXT = 'GET TOTAL COUNT FROM BOTH LOAD TABLES';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Ln_ProcessedRecordCount_QNTY = SUM(X.C1)
     FROM (SELECT COUNT(1) AS C1
             FROM LIVAD_Y1 l
            WHERE l.FileLoad_DATE = @Ld_Run_DATE
           UNION ALL
           SELECT COUNT(1) AS C1
             FROM LIVAR_Y1 l
            WHERE l.FileLoad_DATE = @Ld_Run_DATE)X;

   -- Get the total number Trigger records processed.
   SET @Ls_Sql_TEXT = 'GET TOTAL COUNT OF PROCESSED TRIGGERS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   --13128 - CR0344 PFA and Case Assignment Issues 20131226 -START-
   SET @Ls_TransactionSql_TEXT = N'SELECT @Out = Trigger_QNTY
									 FROM OPENQUERY(' + @Lc_LinkedServer_CODE + ',
									 ''SELECT COUNT(1) "Trigger_QNTY" 
										 FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0354_IVA_IVD_TRIG
									    WHERE TRIGGER_TYPE_IND = ''''' + @Lc_TriggerTypeIndcNumb_TEXT + '''''
									      AND TRIG_REQ_DT > ''''' + CAST(@Ld_LastRun_DATE AS VARCHAR(10)) + '''''
					                      AND TRIG_REQ_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
									      AND 
									       (
										    (PROGRAM_CD = ''''' + @Lc_ProgramMao_CODE + ''''' 
												AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))
										    OR
										    ((PROGRAM_CD = ''''' + @Lc_ProgramMpv_CODE + ''''' OR PROGRAM_CD = ''''' + @Lc_ProgramMgi_CODE + ''''' )
												AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramI_CODE + ''''',''''' + @Lc_SubProgramC_CODE + ''''',''''' + @Lc_SubProgramY_CODE + '''''))                    
										    OR
										    (PROGRAM_CD = ''''' + @Lc_ProgramMrm_CODE + ''''' 
												AND SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + ''''')     
										    OR
										    (PROGRAM_CD = ''''' + @Lc_ProgramAbc_CODE + ''''' 
												AND SUBPROGRAM_CD IN (''''' + @Lc_SubProgramA_CODE + ''''',''''' + @Lc_SubProgramF_CODE + '''''))     
										    OR
										    (PROGRAM_CD = ''''' + @Lc_ProgramCc_CODE + ''''')     
									       )'')';

   --13128 - CR0344 PFA and Case Assignment Issues 20131226 -END-
   EXEC SP_EXECUTESQL
    @Ls_TransactionSql_TEXT,
    N'@Out NUMERIC(19) OUTPUT',
    @Out = @Ln_ProcessedTriggerCount_QNTY OUTPUT;

   SET @Ls_DescriptionError_TEXT = 'Processed Trigger Count = ' + ISNULL(CAST(@Ln_ProcessedTriggerCount_QNTY AS VARCHAR), '0');
   -- Update the Log in BSTL_Y1 as the Job is succeeded.
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

   -- Transaction Ends
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   COMMIT TRANSACTION IVAREFERRALS_LOAD;

   --Delete the Triggers from the T0354_IVA_IVD_TRIG table with trigger type 10.
   SET @Ls_Sql_TEXT = 'DELETE ' + @Lc_LinkedServer_CODE + '.T0354_IVA_IVD_TRIG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ls_TransactionSql_TEXT = 'DELETE 
								    FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0354_IVA_IVD_TRIG 
								   WHERE TRIGGER_TYPE_IND = ''' + @Lc_TriggerTypeIndcNumb_TEXT + ''' ';

   EXECUTE (@Ls_TransactionSql_TEXT) AT DB2;

   IF @Ln_ProcessedRecordCount_QNTY != 0
      AND @@ROWCOUNT = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'DELETE TRIGGER TABLE FAILED';

     RAISERROR (50001,16,1);
    END
  END TRY

  -- Exception Begins
  BEGIN CATCH
   -- If Transaction is not committed, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVAREFERRALS_LOAD;
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

   -- Update the Log in BSTL_Y1 as the Job is failed.
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
