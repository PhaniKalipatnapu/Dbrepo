/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_NPA_COLLECTIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_NPA_COLLECTIONS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_NPA_COLLECTIONS batch process is to 
					  match the IV-D cases in DECSS to Food Stamps eligible cases in DCIS II 
					  and sends the monthly collections amounts along with excess over URA 
					  and any disbursements for unassigned arrears on these cases to IV-A.
Frequency		:	'MONTHLY'
Developed On	:	2/17/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_NPA_COLLECTIONS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_LinkedServerDb2_CODE   CHAR(3) = 'DB2',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_BateErrorE1424_CODE    CHAR(5) = 'E1424',
          @Lc_Job_ID                 CHAR(7) = 'DEB6345',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_NPA_COLLECTIONS',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_EXT_TO_IVA',
          @Ls_BateError_TEXT         VARCHAR(4000) = 'NO RECORD(S) TO PROCESS';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5, 0) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_LinkedServerQualifier_TEXT  CHAR(8) = '',
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_OpenQuery_TEXT              VARCHAR(MAX),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_ProcessingMonthBegin_DATE   DATE,
          @Ld_NextRun_DATE                DATE,
          @Ld_ProcessingMonthEnd_DATE     DATE,
          @Ld_High_DATE                   DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##FinExtractToIvaNpac_P1';
   SET @Ls_SqlData_TEXT = '';

   CREATE TABLE ##FinExtractToIvaNpac_P1
    (
      Record_TEXT CHAR(257)
    );

   SET @Ls_Sql_TEXT = 'GET DATABASE NAME FROM ENVG_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Lc_LinkedServerQualifier_TEXT = e.Database_NAME
     FROM ENVG_Y1 e;

   SET @Ls_Sql_TEXT = 'CHECK LINKED SERVER QUALIFIER';
   SET @Ls_Sqldata_TEXT = 'LinkedServerQualifier_TEXT = ' + ISNULL(@Lc_LinkedServerQualifier_TEXT, '');

   IF LEN(LTRIM(RTRIM(ISNULL(@Lc_LinkedServerQualifier_TEXT, '')))) = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID LINKED SERVER QUALIFIER';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_NPAC';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_NPAC;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME;
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_FileName_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE ENPAC_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM ENPAC_Y1;

   SET @Ld_ProcessingMonthBegin_DATE = DATEADD(D, -(DATEPART(D, @Ld_Run_DATE) - 1), @Ld_Run_DATE);
   SET @Ld_NextRun_DATE = DATEADD(M, 1, @Ld_Run_DATE);
   SET @Ld_ProcessingMonthEnd_DATE = DATEADD(D, -(DATEPART(D, @Ld_NextRun_DATE)), @Ld_NextRun_DATE);
   SET @Ld_High_DATE = CAST('12/31/9999' AS DATE);
   /*
   	Prepare ODBC Query to get all the NPA cases for the processing month. 
   */
   SET @Ls_Sql_TEXT = 'PREPARE OPEN QUERY';
   SET @Ls_SqlData_TEXT = '';
   SET @Ls_OpenQuery_TEXT = '
SELECT 
	CASE_NUM AS CaseWelfare_IDNO,
	MCI_NUM AS MemberMci_IDNO,
	PROGRAM_CD AS Program_CODE,
	SUBPROGRAM_CD AS SubProgram_CODE,
	YEARMONTH_NUM AS YearMonth_NUMB,
	AG_SEQ_NUM AS AssistanceGroupSeq_NUMB,
	CAG_ELIG_SEQ_NUM AS CaseAssistanceGroupEligSeq_NUMB,
	REG_USER_ID AS Worker_ID,
	POOL_NUM AS Pool_NUMB	
	INTO ##NpaCasesFromIva_P1
FROM 
	OPENQUERY
	(
		' + @Lc_LinkedServerDb2_CODE + ',
		''
		SELECT
			B.CASE_NUM,
			B.MCI_NUM,
			B.PROGRAM_CD,
			B.SUBPROGRAM_CD,
			B.YEARMONTH_NUM,
			B.AG_SEQ_NUM,
			B.CAG_ELIG_SEQ_NUM,
			C.REG_USER_ID,
			D.POOL_NUM
		FROM
			(
				SELECT 
					ROW_NUMBER() 
					OVER 
					(
						PARTITION BY
							A.CASE_NUM,
							A.MCI_NUM,
							A.PROGRAM_CD,
							A.SUBPROGRAM_CD			
						ORDER BY
							A.CASE_NUM,
							A.MCI_NUM,
							A.PROGRAM_CD,
							A.SUBPROGRAM_CD,
							A.AG_SEQ_NUM DESC,
							A.CAG_ELIG_SEQ_NUM DESC
					) AS ROW_NUM,
					A.CASE_NUM,
					A.MCI_NUM,
					A.PROGRAM_CD,
					A.SUBPROGRAM_CD,
					''''' + SUBSTRING(CONVERT(VARCHAR(8), @Ld_Run_DATE, 112), 1, 6) + ''''' AS YEARMONTH_NUM,					
					A.AG_SEQ_NUM,
					A.CAG_ELIG_SEQ_NUM
				FROM 
					' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG A
				WHERE
					(
						A.PROGRAM_CD IN (''''CC'''',''''FS'''',''''GA'''',''''RCA'''',''''ABC'''')
						OR A.PROGRAM_CD LIKE ''''M%''''
					)
					AND A.AG_PAYEE_SW <> ''''Y''''
					AND A.AG_STS_CD = ''''O''''
					AND A.PART_STS_CD IN (''''EC'''', ''''EA'''')
					AND A.CURRENT_ELIG_IND IN (''''1'''', ''''9'''')
					AND A.PAYMENT_BEGIN_DT <= ''''' + CAST(@Ld_Run_DATE AS VARCHAR) + '''''
					AND A.PAYMENT_END_DT >= ''''' + CAST(@Ld_Run_DATE AS VARCHAR) + '''''
					AND A.PAYMENT_END_DT >= A.PAYMENT_BEGIN_DT
			) B,
			' + @Lc_LinkedServerQualifier_TEXT + '.T0001_CASE C,
			' + @Lc_LinkedServerQualifier_TEXT + '.T0007_WORKER D
		WHERE
			B.ROW_NUM = 1 AND
			C.CASE_NUM = B.CASE_NUM
			AND D.USER_ID = C.REG_USER_ID	
		''
	)				
';
   /*
   	Execute ODBC Query to get all the NPA cases for the processing month. 
   */
   SET @Ls_Sql_TEXT = 'EXECUTE OPEN QUERY';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE(@Ls_OpenQuery_TEXT);

   /*
   	Get all the IVD cases from DECSS for the NPA cases retrieved from IVA for the processing month
   */
   SET @Ls_Sql_TEXT = 'GET IVD CASES FROM DECSS';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          A.CaseWelfare_IDNO,
          B.Case_IDNO,
          C.MemberMci_IDNO,
          B.TypeWelfare_CODE,
          D.StatusCase_CODE,
          D.TypeCase_CODE,
          D.CaseCategory_CODE,
          D.County_IDNO,
          C.CaseRelationship_CODE,
          C.CaseMemberStatus_CODE
     INTO #NpaCasesInDecss_P1
     FROM ##NpaCasesFromIva_P1 A,
          MHIS_Y1 B,
          CMEM_Y1 C,
          CASE_Y1 D
    WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
      AND B.TypeWelfare_CODE <> 'A'
      AND @Ld_Run_DATE BETWEEN B.Start_DATE AND B.End_DATE
      AND C.Case_IDNO = B.Case_IDNO
      AND C.MemberMci_IDNO = B.MemberMci_IDNO
      AND C.CaseRelationship_CODE = 'D'
      AND C.CaseMemberStatus_CODE = 'A'
      AND D.Case_IDNO = C.Case_IDNO
      AND D.StatusCase_CODE = 'O'
      AND D.TypeCase_CODE <> 'H'
    ORDER BY A.CaseWelfare_IDNO,
             B.Case_IDNO,
             C.MemberMci_IDNO;

   /*
   	Get data for the Child from DSBL_Y1 for each NPA Case retrieved from IVA for the processing month
   */
   SET @Ls_Sql_TEXT = 'GET CHILD DATA FROM DSBL_Y1';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          C.CaseWelfare_IDNO,
          C.Case_IDNO,
          C.MemberMci_IDNO,
          E.OrderSeq_NUMB,
          E.ObligationSeq_NUMB,
          CASE
           WHEN F.TypeDisburse_CODE IN ('AZUDA', 'CXPAA', 'AXPAA')
            THEN 'XS'
           ELSE E.TypeDebt_CODE
          END AS TypeDebt_CODE,
          F.CheckRecipient_CODE,
          CASE
           WHEN F.TypeDisburse_CODE IN ('AZUDA', 'CXPAA', 'AXPAA')
            THEN 'XS'
           ELSE F.TypeDisburse_CODE
          END AS TypeDisburse_CODE,
          F.Disburse_DATE,
          F.Batch_DATE, F.SourceBatch_CODE, F.Batch_NUMB, F.SeqReceipt_NUMB,
          F.Disburse_AMNT
     INTO #ChildInfoInDsbl_P1
     FROM #NpaCasesInDecss_P1 C,
          OBLE_Y1 E,
          DSBL_Y1 F
    WHERE E.Case_IDNO = C.Case_IDNO
      AND E.MemberMci_IDNO = C.MemberMci_IDNO
      AND E.TypeDebt_CODE IN ('CS', 'MS')
      AND E.EndValidity_DATE IN (@Ld_High_DATE, '12/31/2099')
      AND F.Case_IDNO = E.Case_IDNO
      AND F.OrderSeq_NUMB = E.OrderSeq_NUMB
      AND F.ObligationSeq_NUMB = E.ObligationSeq_NUMB
      AND F.CheckRecipient_CODE = '1'
      AND F.TypeDisburse_CODE IN ('CZNAA', 'AZNAA', 'AZUDA', 'CXPAA', 'AXPAA')
      AND F.Disburse_DATE BETWEEN @Ld_ProcessingMonthBegin_DATE AND @Ld_ProcessingMonthEnd_DATE
    ORDER BY C.CaseWelfare_IDNO,
             C.Case_IDNO,
             C.MemberMci_IDNO;

   /*
   	Calculate the collection amount for the child on the NPA case
   */
   SET @Ls_Sql_TEXT = 'CALCULATE CHILD COLLECTED AMOUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.MemberMci_IDNO,
          A.TypeDebt_CODE,
          A.TypeDisburse_CODE,
          SUM(ISNULL(A.Disburse_AMNT, 0)) AS ChildCollected_AMNT
     INTO #ChildCollectedAmount_P1
     FROM #ChildInfoInDsbl_P1 A
    GROUP BY A.CaseWelfare_IDNO,
             A.Case_IDNO,
             A.MemberMci_IDNO,
             A.TypeDebt_CODE,
             A.TypeDisburse_CODE;

   /*
   	Get data for the CP from DSBL_Y1 for each NPA Case retrieved from IVA for the processing month
   */
   SET @Ls_Sql_TEXT = 'GET CP DATA FROM DSBL_Y1';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.MemberMci_IDNO,
          ISNULL(D.OrderSeq_NUMB, '0') AS OrderSeq_NUMB,
          ISNULL(D.ObligationSeq_NUMB, '0') AS ObligationSeq_NUMB,
          B.MemberMci_IDNO AS CpMci_IDNO,
          CASE
           WHEN ISNULL(C.TypeDisburse_CODE, ' ') IN ('AZUDA', 'CXPAA', 'AXPAA')
            THEN 'XS'
           ELSE ISNULL(D.TypeDebt_CODE, ' ')
          END AS TypeDebt_CODE,
          ISNULL(C.CheckRecipient_CODE, ' ') AS CheckRecipient_CODE,
          CASE
           WHEN ISNULL(C.TypeDisburse_CODE, ' ') IN ('AZUDA', 'CXPAA', 'AXPAA')
            THEN 'XS'
           ELSE ISNULL(C.TypeDisburse_CODE, ' ')
          END AS TypeDisburse_CODE,
          ISNULL(C.Disburse_DATE, ' ') AS Disburse_DATE,
          ISNULL(C.Disburse_AMNT, '0') AS Disburse_AMNT
     INTO #CpInfoInDsbl_P1
     FROM #NpaCasesInDecss_P1 A,
          CMEM_Y1 B
          LEFT OUTER JOIN OBLE_Y1 D
           ON D.Case_IDNO = B.Case_IDNO
              AND D.MemberMci_IDNO = B.MemberMci_IDNO
              AND D.TypeDebt_CODE IN ('SS', 'MS')
              AND D.EndValidity_DATE IN (@Ld_High_DATE, '12/31/2099')
          LEFT OUTER JOIN DSBL_Y1 C
           ON C.Case_IDNO = D.Case_IDNO
              AND C.OrderSeq_NUMB = D.OrderSeq_NUMB
              AND C.ObligationSeq_NUMB = D.ObligationSeq_NUMB
              AND C.CheckRecipient_CODE = '1'
              AND C.TypeDisburse_CODE IN ('CZNAA', 'AZNAA', 'AZUDA', 'CXPAA', 'AXPAA')
              AND C.Disburse_DATE BETWEEN @Ld_ProcessingMonthBegin_DATE AND @Ld_ProcessingMonthEnd_DATE
    WHERE B.Case_IDNO = A.Case_IDNO
      AND B.CaseRelationship_CODE = 'C'
      AND B.CaseMemberStatus_CODE = 'A'
    ORDER BY A.CaseWelfare_IDNO,
             A.Case_IDNO,
             A.MemberMci_IDNO;

   /*
   	Calculate the collection amount for the CP on the NPA case
   */
   SET @Ls_Sql_TEXT = 'CALCULATE CP COLLECTED AMOUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.MemberMci_IDNO,
          A.CpMci_IDNO,
          A.TypeDebt_CODE,
          A.TypeDisburse_CODE,
          SUM(ISNULL(A.Disburse_AMNT, 0)) AS CpCollected_AMNT
     INTO #CpCollectedAmount_P1
     FROM #CpInfoInDsbl_P1 A
    GROUP BY A.CaseWelfare_IDNO,
             A.Case_IDNO,
             A.MemberMci_IDNO,
             A.CpMci_IDNO,
             A.TypeDebt_CODE,
             A.TypeDisburse_CODE;

   /*
   	Divide the sum of collections 
   		by the total number of children 
   			on the case 
   		to get the collection amount 
   			per child, 
   		and add that amount 
   			to the existing collection amount 
   				on each child record.
   */
   SET @Ls_Sql_TEXT = 'CALCULATE CHILD COLLECTED AMOUNT FROM CP';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.MemberMci_IDNO,
          A.CpMci_IDNO,
          A.TypeDebt_CODE,
          A.TypeDisburse_CODE,
          A.CpCollected_AMNT,
          B.ActiveChildrenCount_QNTY,
          B.OpenObligationsCount_QNTY,
          (CAST((A.CpCollected_AMNT / B.OpenObligationsCount_QNTY) AS DECIMAL(10, 2))) AS ChildCollectedFromCp_AMNT
     INTO #ChildCollectedAmountFromCp_P1
     FROM #CpCollectedAmount_P1 A,
          (SELECT A.CaseWelfare_IDNO,
                  A.Case_IDNO,
                  COUNT(DISTINCT(ISNULL(B.MemberMci_IDNO, 0))) AS ActiveChildrenCount_QNTY,
                  COUNT(DISTINCT(ISNULL(C.MemberMci_IDNO, 0))) AS OpenObligationsCount_QNTY
             FROM #NpaCasesInDecss_P1 A
                  LEFT OUTER JOIN CMEM_Y1 B
                   ON B.Case_IDNO = A.Case_IDNO
                      AND B.CaseRelationship_CODE = 'D'
                      AND B.CaseMemberStatus_CODE = 'A'
                  LEFT OUTER JOIN OBLE_Y1 C
                   ON C.Case_IDNO = A.Case_IDNO
                      AND C.TypeDebt_CODE IN ('CS', 'MS')
                      AND C.EndValidity_DATE IN (@Ld_High_DATE, '12/31/2099')
            GROUP BY A.CaseWelfare_IDNO,
                     A.Case_IDNO) B
    WHERE B.CaseWelfare_IDNO = A.CaseWelfare_IDNO
      AND B.Case_IDNO = A.Case_IDNO
    ORDER BY A.CaseWelfare_IDNO,
             A.Case_IDNO,
             A.MemberMci_IDNO,
             A.CpMci_IDNO,
             A.TypeDebt_CODE,
             A.TypeDisburse_CODE;

   /*
   	Get all valid Child collected amount and Child collected amount from CP
   */
   SET @Ls_Sql_TEXT = 'GET ALL VALID CHILD COLLECTED AMOUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.MemberMci_IDNO,
          A.TypeDebt_CODE,
          A.TypeDisburse_CODE,
          A.ChildCollected_AMNT AS Collected_AMNT
     INTO #CollectedAmount_P1
     FROM #ChildCollectedAmount_P1 A
    WHERE A.ChildCollected_AMNT > 0
   UNION
   SELECT A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.MemberMci_IDNO,
          A.TypeDebt_CODE,
          A.TypeDisburse_CODE,
          A.ChildCollectedFromCp_AMNT
     FROM #ChildCollectedAmountFromCp_P1 A
    WHERE A.ChildCollectedFromCp_AMNT > 0;

   /*
   	Get Child DEMO info
   */
   SET @Ls_Sql_TEXT = 'GET CHILD DEMO INFO';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          A.CaseWelfare_IDNO,
          A.Case_IDNO,
          B.MemberMci_IDNO AS ChildMci_IDNO,
          C.FullDisplay_NAME AS ChildFull_NAME,
          C.Last_NAME AS LastChild_NAME,
          C.First_NAME AS FirstChild_NAME,
          C.Middle_NAME AS MiddleChild_NAME,
          C.Suffix_NAME AS SuffixChild_NAME
     INTO #ChildDemoInfo_P1
     FROM #CollectedAmount_P1 A,
          CMEM_Y1 B,
          DEMO_Y1 C
    WHERE B.Case_IDNO = A.Case_IDNO
      AND B.MemberMci_IDNO = A.MemberMci_IDNO
      AND C.MemberMci_IDNO = B.MemberMci_IDNO;

   /*
   	Get CP and NCP DEMO info
   */
   SET @Ls_Sql_TEXT = 'GET CP AND NCP DEMO INFO';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          A.CaseWelfare_IDNO,
          A.Case_IDNO,
          B.CpMci_IDNO,
          B.LastCp_NAME,
          B.FirstCp_NAME,
          B.MiddleCp_NAME,
          B.SuffixCp_NAME,
          CASE
           WHEN EXISTS(SELECT 1
                         FROM MSSN_Y1 X
                        WHERE X.MemberSsn_NUMB = B.VerifiedItinCpSsn_NUMB
                          AND X.SourceVerify_CODE = 'S'
                          AND X.Enumeration_CODE <> 'Y'
                          AND X.EndValidity_DATE = @Ld_High_DATE)
            THEN '0'
           ELSE B.VerifiedItinCpSsn_NUMB
          END AS MemberSsn_NUMB,
          B.NcpPf_IDNO AS NcpMci_IDNO,
          B.LastNcp_NAME,
          B.FirstNcp_NAME,
          B.MiddleNcp_NAME,
          B.SuffixNcp_NAME
     INTO #CpNcpDemoInfo_P1
     FROM #ChildDemoInfo_P1 A,
          ENSD_Y1 B,
          DEMO_Y1 C,
          DEMO_Y1 D
    WHERE B.Case_IDNO = A.Case_IDNO
      AND C.MemberMci_IDNO = B.CpMci_IDNO
      AND D.MemberMci_IDNO = B.NcpPf_IDNO
    ORDER BY A.CaseWelfare_IDNO,
             A.Case_IDNO;

   /*
   	Get CP Address info using Address Hierarchy
   */
   SET @Ls_Sql_TEXT = 'GET CP ADDRESS INFO';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          E.CaseWelfare_IDNO,
          E.Case_IDNO,
          E.MemberMci_IDNO AS CpMci_IDNO,
          E.AddressHierarchyOrder_CODE,
          E.TypeAddress_CODE,
          E.Status_CODE,
          E.Begin_DATE,
          E.End_DATE,
          E.Line1_ADDR,
          E.Line2_ADDR,
          E.City_ADDR,
          E.State_ADDR,
          E.Zip_ADDR AS ZipCpFull_ADDR
     INTO #CpAddressInfo_P1
     FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY D.CaseWelfare_IDNO, D.Case_IDNO, D.MemberMci_IDNO ORDER BY D.CaseWelfare_IDNO, D.Case_IDNO, D.MemberMci_IDNO, D.AddressHierarchyOrder_CODE ),
                  D.CaseWelfare_IDNO,
                  D.Case_IDNO,
                  D.MemberMci_IDNO,
                  D.AddressHierarchyOrder_CODE,
                  D.TypeAddress_CODE,
                  D.Status_CODE,
                  D.Begin_DATE,
                  D.End_DATE,
                  D.Line1_ADDR,
                  D.Line2_ADDR,
                  D.City_ADDR,
                  D.State_ADDR,
                  D.Zip_ADDR
             FROM (SELECT DISTINCT
                          A.CaseWelfare_IDNO,
                          B.Case_IDNO,
                          B.MemberMci_IDNO,
                          CASE
                           WHEN ISNULL(C.MemberMci_IDNO, 0) = 0
                            THEN 0
                           --M - Y, R - Y, M - P, R - P
                           WHEN @Ld_Run_DATE BETWEEN C.Begin_DATE AND C.End_DATE
                            THEN
                            CASE
                             WHEN C.TypeAddress_CODE = 'M'
                                  AND C.Status_CODE = 'Y'
                              THEN 1
                             WHEN C.TypeAddress_CODE = 'R'
                                  AND C.Status_CODE = 'Y'
                              THEN 2
                             WHEN C.TypeAddress_CODE = 'M'
                                  AND C.Status_CODE = 'P'
                              THEN 3
                             WHEN C.TypeAddress_CODE = 'R'
                                  AND C.Status_CODE = 'P'
                              THEN 4
                            END
                           --Most Recent End Dated Mailing Address
                           WHEN C.End_DATE NOT IN (@Ld_High_DATE, '12/31/2099')
                                AND @Ld_Run_DATE > C.End_DATE
                            THEN
                            CASE
                             WHEN C.TypeAddress_CODE = 'M'
                                  AND C.Status_CODE = 'Y'
                              THEN 5
                             WHEN C.TypeAddress_CODE = 'M'
                                  AND C.Status_CODE = 'P'
                              THEN 6
                            END
                          END AS AddressHierarchyOrder_CODE,
                          ISNULL(C.TypeAddress_CODE, '') AS TypeAddress_CODE,
                          ISNULL(C.Status_CODE, '') AS Status_CODE,
                          ISNULL(C.Begin_DATE, '') AS Begin_DATE,
                          ISNULL(C.End_DATE, '') AS End_DATE,
                          ISNULL(C.Line1_ADDR, '') AS Line1_ADDR,
                          ISNULL(C.Line2_ADDR, '') AS Line2_ADDR,
                          ISNULL(C.City_ADDR, '') AS City_ADDR,
                          ISNULL(C.State_ADDR, '') AS State_ADDR,
                          ISNULL(C.Zip_ADDR, '') AS Zip_ADDR
                     FROM #ChildDemoInfo_P1 A,
                          CMEM_Y1 B
                          LEFT OUTER JOIN AHIS_Y1 C
                           ON C.MemberMci_IDNO = B.MemberMci_IDNO
                              AND C.TypeAddress_CODE IN ('M', 'R')
                              AND ((C.SourceLoc_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                                    AND C.Status_CODE IN ('Y', 'P'))
                                    OR (C.SourceLoc_CODE IN ('NDH', 'IRS', 'FID', 'FCR')
                                        AND C.SourceVerified_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                                        AND C.Status_CODE = 'Y'))
                              AND C.End_DATE = (SELECT MAX(X.End_DATE)
                                                  FROM AHIS_Y1 X
                                                 WHERE X.MemberMci_IDNO = C.MemberMci_IDNO
                                                   AND X.TypeAddress_CODE = C.TypeAddress_CODE
                                                   AND X.Status_CODE = C.Status_CODE
                                                 GROUP BY X.MemberMci_IDNO,
                                                          X.TypeAddress_CODE,
                                                          X.Status_CODE)
                              AND (@Ld_Run_DATE BETWEEN C.Begin_DATE AND C.End_DATE
                                    OR (C.End_DATE NOT IN (@Ld_High_DATE, '12/31/2099')
                                        AND @Ld_Run_DATE > C.End_DATE))
                    WHERE B.Case_IDNO = A.Case_IDNO
                      AND B.CaseRelationship_CODE = 'C'
                      AND B.CaseMemberStatus_CODE = 'A') D) E
    WHERE E.Row_NUMB = 1;

   /*
   	Prepare retrieved data to load into ENPAC_Y1
   */
   SET @Ls_Sql_TEXT = 'PREPARE RETRIEVED DATA TO LOAD INTO ENPAC_Y1';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          NpaCasesFromIva.CaseWelfare_IDNO AS IvaCase_IDNO,
          NpaCasesInDecss.Case_IDNO AS IvdCase_IDNO,
          NpaCasesInDecss.MemberMci_IDNO,
          ChildDemoInfo.ChildMci_IDNO,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(ChildDemoInfo.LastChild_NAME, '')))) <= 0
            THEN ''
           WHEN LEN(LTRIM(RTRIM(ISNULL(ChildDemoInfo.FirstChild_NAME, '')))) <= 0
            THEN LTRIM(RTRIM(ChildDemoInfo.LastChild_NAME))
           WHEN LEN(LTRIM(RTRIM(ISNULL(ChildDemoInfo.MiddleChild_NAME, '')))) <= 0
            THEN LTRIM(RTRIM(ChildDemoInfo.LastChild_NAME)) + ', ' + LTRIM(RTRIM(ChildDemoInfo.FirstChild_NAME))
           ELSE LTRIM(RTRIM(ChildDemoInfo.LastChild_NAME)) + ', ' + LTRIM(RTRIM(ChildDemoInfo.FirstChild_NAME)) + ' ' + LEFT(LTRIM(RTRIM(ChildDemoInfo.MiddleChild_NAME)), 1)
          END AS Child_NAME,
          CpNcpDemoInfo.NcpMci_IDNO,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(CpNcpDemoInfo.LastNcp_NAME, '')))) <= 0
            THEN ''
           WHEN LEN(LTRIM(RTRIM(ISNULL(CpNcpDemoInfo.FirstNcp_NAME, '')))) <= 0
            THEN LTRIM(RTRIM(CpNcpDemoInfo.LastNcp_NAME))
           WHEN LEN(LTRIM(RTRIM(ISNULL(CpNcpDemoInfo.MiddleNcp_NAME, '')))) <= 0
            THEN LTRIM(RTRIM(CpNcpDemoInfo.LastNcp_NAME)) + ', ' + LTRIM(RTRIM(CpNcpDemoInfo.FirstNcp_NAME))
           ELSE LTRIM(RTRIM(CpNcpDemoInfo.LastNcp_NAME)) + ', ' + LTRIM(RTRIM(CpNcpDemoInfo.FirstNcp_NAME)) + ' ' + LEFT(LTRIM(RTRIM(CpNcpDemoInfo.MiddleNcp_NAME)), 1)
          END AS Ncp_NAME,
          CollectedAmount.Collected_AMNT,
          NpaCasesFromIva.CaseWelfare_IDNO,
          NpaCasesFromIva.Program_CODE,
          NpaCasesFromIva.SubProgram_CODE,
          NpaCasesFromIva.AssistanceGroupSeq_NUMB,
          NpaCasesFromIva.CaseAssistanceGroupEligSeq_NUMB,
          CpNcpDemoInfo.CpMci_IDNO,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(CpNcpDemoInfo.LastCp_NAME, '')))) <= 0
            THEN ''
           WHEN LEN(LTRIM(RTRIM(ISNULL(CpNcpDemoInfo.FirstCp_NAME, '')))) <= 0
            THEN LTRIM(RTRIM(CpNcpDemoInfo.LastCp_NAME))
           WHEN LEN(LTRIM(RTRIM(ISNULL(CpNcpDemoInfo.MiddleCp_NAME, '')))) <= 0
            THEN LTRIM(RTRIM(CpNcpDemoInfo.LastCp_NAME)) + ', ' + LTRIM(RTRIM(CpNcpDemoInfo.FirstCp_NAME))
           ELSE LTRIM(RTRIM(CpNcpDemoInfo.LastCp_NAME)) + ', ' + LTRIM(RTRIM(CpNcpDemoInfo.FirstCp_NAME)) + ' ' + LEFT(LTRIM(RTRIM(CpNcpDemoInfo.MiddleCp_NAME)), 1)
          END AS Cp_NAME,
          CpAddressInfo.Line1_ADDR,
          CpAddressInfo.Line2_ADDR,
          ' ' AS Line3_ADDR,
          CpAddressInfo.City_ADDR,
          CpAddressInfo.State_ADDR,
          CpAddressInfo.ZipCpFull_ADDR,
          CASE LEN(LTRIM(RTRIM(REPLACE(ISNULL(CpAddressInfo.ZipCpFull_ADDR, ''), '-', ''))))
           WHEN 0
            THEN ' '
           ELSE SUBSTRING(LTRIM(RTRIM(CpAddressInfo.ZipCpFull_ADDR)), 1, 5)
          END AS Zip_ADDR,
          CASE LEN(LTRIM(RTRIM(REPLACE(ISNULL(CpAddressInfo.ZipCpFull_ADDR, ''), '-', ''))))
           WHEN 9
            THEN SUBSTRING(LTRIM(RTRIM(REPLACE(CpAddressInfo.ZipCpFull_ADDR, '-', ''))), 6, 4)
           ELSE ' '
          END AS ZipSuffix_ADDR,
          NpaCasesInDecss.County_IDNO,
          NpaCasesFromIva.Worker_ID,
          NpaCasesInDecss.Case_IDNO,
          NpaCasesFromIva.Pool_NUMB,
          CpNcpDemoInfo.MemberSsn_NUMB,
          CASE
           WHEN CollectedAmount.TypeDebt_CODE = 'CS'
                AND CollectedAmount.TypeDisburse_CODE = 'CZNAA'
            THEN 'C'
           WHEN CollectedAmount.TypeDebt_CODE = 'CS'
                AND CollectedAmount.TypeDisburse_CODE = 'AZNAA'
            THEN 'A'
           WHEN CollectedAmount.TypeDebt_CODE = 'SS'
                AND CollectedAmount.TypeDisburse_CODE = 'CZNAA'
            THEN 'S'
           WHEN CollectedAmount.TypeDebt_CODE = 'SS'
                AND CollectedAmount.TypeDisburse_CODE = 'AZNAA'
            THEN 'B'
           WHEN CollectedAmount.TypeDebt_CODE = 'MS'
                AND CollectedAmount.TypeDisburse_CODE = 'CZNAA'
            THEN 'M'
           WHEN CollectedAmount.TypeDebt_CODE = 'MS'
                AND CollectedAmount.TypeDisburse_CODE = 'AZNAA'
            THEN 'D'
           WHEN CollectedAmount.TypeDebt_CODE = 'XS'
                AND CollectedAmount.TypeDisburse_CODE = 'XS'
            THEN 'X'
          END AS TypeRecord_CODE
     INTO #FinExtractToIvaNpa_P1
     FROM #ChildDemoInfo_P1 ChildDemoInfo,
          ##NpaCasesFromIva_P1 NpaCasesFromIva,
          #NpaCasesInDecss_P1 NpaCasesInDecss,
          #CollectedAmount_P1 CollectedAmount,
          #CpNcpDemoInfo_P1 CpNcpDemoInfo,
          #CpAddressInfo_P1 CpAddressInfo
    WHERE NpaCasesFromIva.CaseWelfare_IDNO = ChildDemoInfo.CaseWelfare_IDNO
      AND NpaCasesFromIva.MemberMci_IDNO = ChildDemoInfo.ChildMci_IDNO
      AND NpaCasesInDecss.CaseWelfare_IDNO = ChildDemoInfo.CaseWelfare_IDNO
      AND NpaCasesInDecss.Case_IDNO = ChildDemoInfo.Case_IDNO
      AND NpaCasesInDecss.MemberMci_IDNO = ChildDemoInfo.ChildMci_IDNO
      AND CollectedAmount.CaseWelfare_IDNO = ChildDemoInfo.CaseWelfare_IDNO
      AND CollectedAmount.Case_IDNO = ChildDemoInfo.Case_IDNO
      AND CollectedAmount.MemberMci_IDNO = ChildDemoInfo.ChildMci_IDNO
      AND CpNcpDemoInfo.CaseWelfare_IDNO = ChildDemoInfo.CaseWelfare_IDNO
      AND CpNcpDemoInfo.Case_IDNO = ChildDemoInfo.Case_IDNO
      AND CpAddressInfo.CaseWelfare_IDNO = ChildDemoInfo.CaseWelfare_IDNO
      AND CpAddressInfo.Case_IDNO = ChildDemoInfo.Case_IDNO;

   SET @Ls_Sql_TEXT = 'INSERT ENPAC_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ENPAC_Y1
               (ChildMci_IDNO,
                Child_NAME,
                NcpMci_IDNO,
                Ncp_NAME,
                Collected_AMNT,
                CaseWelfare_IDNO,
                Program_CODE,
                SubProgram_CODE,
                AssistanceGroupSeq_NUMB,
                CaseAssistanceGroupEligSeq_NUMB,
                CpMci_IDNO,
                Cp_NAME,
                Line1_ADDR,
                Line2_ADDR,
                Line3_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                ZipSuffix_ADDR,
                County_IDNO,
                Worker_ID,
                Case_IDNO,
                Pool_NUMB,
                MemberSsn_NUMB,
                TypeRecord_CODE)
   SELECT (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.ChildMci_IDNO)), 10)) AS ChildMci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child_NAME)) + REPLICATE(' ', 24)), 24) AS CHAR(24)), REPLICATE(@Lc_Space_TEXT, 24))) AS Child_NAME,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.NcpMci_IDNO)), 10)) AS NcpMci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Ncp_NAME)) + REPLICATE(' ', 24)), 24) AS CHAR(24)), REPLICATE(@Lc_Space_TEXT, 24))) AS Ncp_NAME,
          (RIGHT(REPLICATE('0', 10) + REPLACE(LTRIM(RTRIM(A.Collected_AMNT)), '.', ''), 10)) AS Collected_AMNT,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.CaseWelfare_IDNO)), 10)) AS CaseWelfare_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Program_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) AS Program_CODE,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SubProgram_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS SubProgram_CODE,
          (RIGHT(REPLICATE('0', 4) + LTRIM(RTRIM(A.AssistanceGroupSeq_NUMB)), 4)) AS AssistanceGroupSeq_NUMB,
          (RIGHT(REPLICATE('0', 4) + LTRIM(RTRIM(A.CaseAssistanceGroupEligSeq_NUMB)), 4)) AS CaseAssistanceGroupEligSeq_NUMB,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.CpMci_IDNO)), 10)) AS CpMci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Cp_NAME)) + REPLICATE(' ', 24)), 24) AS CHAR(24)), REPLICATE(@Lc_Space_TEXT, 24))) AS Cp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Line1_ADDR)) + REPLICATE(' ', 31)), 31) AS CHAR(31)), REPLICATE(@Lc_Space_TEXT, 31))) AS Line1_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Line2_ADDR)) + REPLICATE(' ', 31)), 31) AS CHAR(31)), REPLICATE(@Lc_Space_TEXT, 31))) AS Line2_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Line3_ADDR)) + REPLICATE(' ', 5)), 5) AS CHAR(5)), REPLICATE(@Lc_Space_TEXT, 5))) AS Line3_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.City_ADDR)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) AS City_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.State_ADDR)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) AS State_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Zip_ADDR)) + REPLICATE(' ', 5)), 5) AS CHAR(5)), REPLICATE(@Lc_Space_TEXT, 5))) AS Zip_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.ZipSuffix_ADDR)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS ZipSuffix_ADDR,
          (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(A.County_IDNO)), 3)) AS County_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Worker_ID)) + REPLICATE(' ', 7)), 7) AS CHAR(7)), REPLICATE(@Lc_Space_TEXT, 7))) AS Worker_ID,
          (RIGHT(REPLICATE('0', 6) + LTRIM(RTRIM(A.Case_IDNO)), 6)) AS Case_IDNO,
          (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(A.Pool_NUMB)), 3)) AS Pool_NUMB,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MemberSsn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) AS MemberSsn_NUMB,
          A.TypeRecord_CODE
     FROM #FinExtractToIvaNpa_P1 A
    ORDER BY A.CaseWelfare_IDNO,
             A.Case_IDNO,
             A.ChildMci_IDNO,
             A.TypeRecord_CODE;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR (50001,16,1);
      END;
    END;
   ELSE IF @Li_RowCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT ##FinExtractToIvaNpac_P1';
     SET @Ls_SqlData_TEXT = '';

     INSERT INTO ##FinExtractToIvaNpac_P1
                 (Record_TEXT)
     SELECT (A.ChildMci_IDNO + A.Child_NAME + A.NcpMci_IDNO + A.Ncp_NAME + A.Collected_AMNT + A.CaseWelfare_IDNO + A.Program_CODE + A.SubProgram_CODE + A.AssistanceGroupSeq_NUMB + A.CaseAssistanceGroupEligSeq_NUMB + A.CpMci_IDNO + A.Cp_NAME + A.Line1_ADDR + A.Line2_ADDR + A.Line3_ADDR + A.City_ADDR + A.State_ADDR + A.Zip_ADDR + A.ZipSuffix_ADDR + A.County_IDNO + A.Worker_ID + A.Case_IDNO + A.Pool_NUMB + A.MemberSsn_NUMB + A.TypeRecord_CODE) AS Record_TEXT
       FROM ENPAC_Y1 A
      ORDER BY A.CaseWelfare_IDNO,
               A.Case_IDNO,
               A.ChildMci_IDNO,
               A.TypeRecord_CODE;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
       SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO ##FinExtractToIvaNpac_P1 FAILED';

       RAISERROR(50001,16,1);
      END;
     ELSE
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;
      END;
    END;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_NPAC';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_NPAC;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##FinExtractToIvaNpac_P1';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_NPAC';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_NPAC;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Status_CODE = ' + @Lc_StatusSuccess_CODE;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = '',
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = '',
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_NPAC';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_NPAC;

   SET @Ls_Sql_TEXT = 'DROP ALL TEMPORARY TABLES';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE ##FinExtractToIvaNpac_P1;

   DROP TABLE ##NpaCasesFromIva_P1;

   DROP TABLE #NpaCasesInDecss_P1;

   DROP TABLE #ChildInfoInDsbl_P1;

   DROP TABLE #ChildCollectedAmount_P1;

   DROP TABLE #CpInfoInDsbl_P1;

   DROP TABLE #CpCollectedAmount_P1;

   DROP TABLE #ChildCollectedAmountFromCp_P1;

   DROP TABLE #CollectedAmount_P1;

   DROP TABLE #ChildDemoInfo_P1;

   DROP TABLE #CpNcpDemoInfo_P1;

   DROP TABLE #CpAddressInfo_P1;

   DROP TABLE #FinExtractToIvaNpa_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FIN_EXTRACT_TO_IVA_NPAC;
    END;

   IF OBJECT_ID('tempdb..##FinExtractToIvaNpac_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##FinExtractToIvaNpac_P1;
    END;

   IF OBJECT_ID('tempdb..##NpaCasesFromIva_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##NpaCasesFromIva_P1;
    END

   IF OBJECT_ID('tempdb..#NpaCasesInDecss_P1') IS NOT NULL
    BEGIN
     DROP TABLE #NpaCasesInDecss_P1;
    END

   IF OBJECT_ID('tempdb..#ChildInfoInDsbl_P1') IS NOT NULL
    BEGIN
     DROP TABLE #ChildInfoInDsbl_P1;
    END

   IF OBJECT_ID('tempdb..#ChildCollectedAmount_P1') IS NOT NULL
    BEGIN
     DROP TABLE #ChildCollectedAmount_P1;
    END

   IF OBJECT_ID('tempdb..#CpInfoInDsbl_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CpInfoInDsbl_P1;
    END

   IF OBJECT_ID('tempdb..#CpCollectedAmount_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CpCollectedAmount_P1;
    END

   IF OBJECT_ID('tempdb..#ChildCollectedAmountFromCp_P1') IS NOT NULL
    BEGIN
     DROP TABLE #ChildCollectedAmountFromCp_P1;
    END

   IF OBJECT_ID('tempdb..#CollectedAmount_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CollectedAmount_P1;
    END

   IF OBJECT_ID('tempdb..#ChildDemoInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #ChildDemoInfo_P1;
    END

   IF OBJECT_ID('tempdb..#CpNcpDemoInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CpNcpDemoInfo_P1;
    END

   IF OBJECT_ID('tempdb..#CpAddressInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CpAddressInfo_P1;
    END

   IF OBJECT_ID('tempdb..#FinExtractToIvaNpa_P1') IS NOT NULL
    BEGIN
     DROP TABLE #FinExtractToIvaNpa_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = '',
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
