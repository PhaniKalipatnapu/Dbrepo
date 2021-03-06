/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_CASE_UPDATES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_CASE_UPDATES
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_CASE_UPDATES batch process is to 
					  identify TANF, Medicaid, or Purchase of Care cases on DECSS where a change has been made 
					  to case or member data, and extracts the case and member information about these cases 
					  from DECSS to be sent to DSS.
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_TO_IVA$SP_EXTRACT_CASE_UPDATES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_BateErrorE1424_CODE    CHAR(5) = 'E1424',
          @Lc_Job_ID                 CHAR(7) = 'DEB6343',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_CASE_UPDATES',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_FIN_EXT_TO_IVA',
          @Ls_BateError_TEXT         VARCHAR(4000) = 'NO RECORD(S) TO PROCESS',
          @Ld_Low_DATE               DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_RecordCount_QNTY            NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5, 0) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Empty_TEXT                  CHAR = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_High_DATE                   DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##FinExtractToIvaCupd_P1';
   SET @Ls_SqlData_TEXT = '';

   CREATE TABLE ##FinExtractToIvaCupd_P1
    (
      Record_TEXT CHAR(697)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_CUPD';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_CUPD;

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
   SET @Ls_FileSource_TEXT = @Lc_Empty_TEXT + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_FileName_NAME));

   IF @Ls_FileSource_TEXT = @Lc_Empty_TEXT
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE EIVDC_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EIVDC_Y1;

   SET @Ld_High_DATE = CAST('12/31/9999' AS DATE);
   /*
   Extract all TANF, Medicaid, and Purchase of Care cases from DECSS 
   for which there exists one or more of the following case journal entries 
   (minor activities in the â€œCompletedâ€ status) with the update date set to batch run date. 
   
   Also select a case 
   when there is a payment in  DSBL_Y1 table where a payment with Disbursement Type code of CXPAA is posted to the case on the batch execution date. 
   when a dependentâ€™s paternity status has been added or updated in the MPAT_Y1 table.
   when a Support Order record has been added or modified in SORD_Y1.
   when an obligation record has been added or modified in the OBLE_Y1 table
   
   Include the address where the address source is NDNH, FCR, FIDM or IRS 
   only if the address status is confirmed good, 
   and the address verification source is other than NDNH, FCR, FIDM or IRS.    	
   
   	Select the case and member information for these cases 
   */
   SET @Ls_Sql_TEXT = 'GET CASE UPDATES INFO';
   SET @Ls_SqlData_TEXT = '';

   SELECT ISNULL ((SELECT TOP 1 ISNULL(Y.CaseWelfare_IDNO, 0)
                     FROM MHIS_Y1 Y
                    WHERE Y.Case_IDNO = D.Case_IDNO
                      AND Y.End_DATE >= @Ld_Run_DATE
                      AND EXISTS(SELECT 1
                                   FROM CMEM_Y1 Z
                                  WHERE Z.Case_IDNO = Y.Case_IDNO
                                    AND Z.MemberMci_IDNO = Y.MemberMci_IDNO
                                    AND Z.CaseRelationship_CODE = 'D')
                      AND Y.CaseWelfare_IDNO > 0), 0) AS CaseWelfare_IDNO,
          D.Case_IDNO,
          CASE
           WHEN ISNULL(D.Distribute_AMNT, '0') > 0
            THEN @Ld_Run_DATE
           ELSE ''
          END AS Distribute_DATE,
          D.Distribute_AMNT,
          E.StatusCase_CODE,
          E.TypeCase_CODE,
          E.CaseCategory_CODE,
          F.County_IDNO,
          E.NonCoop_CODE,
          E.NonCoop_DATE,
          E.GoodCause_CODE,
          E.GoodCause_DATE,
          F.CpMci_IDNO,
          F.FirstCp_NAME,
          F.MiddleCp_NAME,
          F.LastCp_NAME,
          F.SuffixCp_NAME,
          F.NcpPf_IDNO AS NcpMci_IDNO,
          F.FirstNcp_NAME,
          F.MiddleNcp_NAME,
          F.LastNcp_NAME,
          F.SuffixNcp_NAME,
          CASE
           WHEN EXISTS (SELECT 1
                          FROM ENSD_Y1 X
                         WHERE X.Case_IDNO = F.Case_IDNO
                           AND (LEN (LTRIM(RTRIM(ISNULL(X.Line1Ncp_ADDR, ''))) + LTRIM(RTRIM(ISNULL(X.CityNcp_ADDR, ''))) + LTRIM(RTRIM(ISNULL(X.StateNcp_ADDR, ''))) + LTRIM(RTRIM(ISNULL(X.ZipNcp_ADDR, '')))) > 0
                                AND LEN (LTRIM(RTRIM(ISNULL(F.Line1Cp_ADDR, ''))) + LTRIM(RTRIM(ISNULL(F.CityCp_ADDR, ''))) + LTRIM(RTRIM(ISNULL(F.StateCp_ADDR, ''))) + LTRIM(RTRIM(ISNULL(F.ZipCp_ADDR, '')))) > 0)
                           AND (UPPER(LTRIM(RTRIM(X.Line1Ncp_ADDR))) = UPPER(LTRIM(RTRIM(F.Line1Cp_ADDR)))
                                AND UPPER(LTRIM(RTRIM(X.CityNcp_ADDR))) = UPPER(LTRIM(RTRIM(F.CityCp_ADDR)))
                                AND UPPER(LTRIM(RTRIM(X.StateNcp_ADDR))) = UPPER(LTRIM(RTRIM(F.StateCp_ADDR)))
                                AND 'Y' = (CASE
                                            WHEN LEN(LTRIM(RTRIM(X.ZipNcp_ADDR))) >= 5
                                                 AND LEN(LTRIM(RTRIM(F.ZipCp_ADDR))) >= 5
                                             THEN
                                             CASE
                                              WHEN SUBSTRING(LTRIM(RTRIM(X.ZipNcp_ADDR)), 1, 5) = SUBSTRING(LTRIM(RTRIM(F.ZipCp_ADDR)), 1, 5)
                                               THEN 'Y'
                                              ELSE 'N'
                                             END
                                            ELSE 'N'
                                           END)))
            THEN 'Y'
           ELSE 'N'
          END AS NcpResideStatus_INDC,
          F.Mso_AMNT,
          F.FreqLeastOble_CODE,
          F.PaymentLastReceived_AMNT,
          F.ReceiptLast_DATE,
          ISNULL(G.TypeAddress_CODE, '') AS TypeAddress_CODE,
          ISNULL(G.Status_CODE, '') AS Status_CODE,
          ISNULL(G.Line1_ADDR, '') AS Line1Cp_ADDR,
          ISNULL(G.Line2_ADDR, '') AS Line2Cp_ADDR,
          ISNULL(G.City_ADDR, '') AS CityCp_ADDR,
          ISNULL(G.State_ADDR, '') AS StateCp_ADDR,
          ISNULL(G.Zip_ADDR, '0') AS Zip_ADDR,
          CASE LEN(LTRIM(RTRIM(REPLACE(ISNULL(G.Zip_ADDR, ''), '-', ''))))
           WHEN 5
            THEN LTRIM(RTRIM(G.Zip_ADDR)) + '0000'
           WHEN 9
            THEN LTRIM(RTRIM(REPLACE(G.Zip_ADDR, '-', '')))
           ELSE '0'
          END AS ZipCp_ADDR
     INTO #CaseUpdatesInfo_P1
     FROM (SELECT B.Case_IDNO,
                  ISNULL ((SELECT SUM(ISNULL(Y.Disburse_AMNT, '0'))
                             FROM DSBL_Y1 Y
                            WHERE Y.Case_IDNO = B.Case_IDNO
                              AND Y.TypeDisburse_CODE = 'CXPAA'
                              AND Y.Disburse_DATE = @Ld_Run_DATE), '0') AS Distribute_AMNT
             FROM (SELECT DISTINCT
                          A.Case_IDNO
                     FROM (SELECT DISTINCT
                                  X.Case_IDNO
                             FROM CASE_Y1 X
                            WHERE (X.TypeCase_CODE = 'A'
                                    OR (X.TypeCase_CODE = 'N'
                                        AND X.CaseCategory_CODE IN ('MO', 'PO')))
                              AND ISNULL ((SELECT TOP 1 ISNULL(Y.CaseWelfare_IDNO, 0)
                                             FROM MHIS_Y1 Y
                                            WHERE Y.Case_IDNO = X.Case_IDNO
                                              AND Y.End_DATE >= @Ld_Run_DATE
                                              AND EXISTS(SELECT 1
                                                           FROM CMEM_Y1 Z
                                                          WHERE Z.Case_IDNO = Y.Case_IDNO
                                                            AND Z.MemberMci_IDNO = Y.MemberMci_IDNO
                                                            AND Z.CaseRelationship_CODE = 'D')
                                              AND Y.CaseWelfare_IDNO > 0), 0) > 0) A
                    WHERE (EXISTS (SELECT 1
                                     FROM UDMNR_V1 X
                                    WHERE X.Case_IDNO = A.Case_IDNO
                                      AND (X.ActivityMinor_CODE IN ('RCONA', 'UMHIS', 'CCRCE', 'CCRCG',
                                                                    'CCRCR', 'CCRCT', 'CCRND', 'MEMNM')
                                            OR (X.ActivityMinor_CODE = 'CMASW'
                                                AND EXISTS (SELECT 1
                                                              FROM DMNR_Y1 Y
                                                             WHERE Y.Case_IDNO = X.Case_IDNO
                                                               AND Y.ActivityMinor_CODE = X.ActivityMinor_CODE
                                                               AND Y.Status_CODE = 'COMP'
                                                               AND CONVERT(VARCHAR(10), Y.Update_DTTM, 101) = CONVERT(VARCHAR(10), @Ld_Run_DATE, 101)
                                                               AND EXISTS (SELECT 1
                                                                             FROM CMEM_Y1 Z
                                                                            WHERE Z.Case_IDNO = Y.Case_IDNO
                                                                              AND Z.MemberMci_IDNO = Y.MemberMci_IDNO
                                                                              AND Z.CaseRelationship_CODE = 'C'
                                                                              AND Z.CaseMemberStatus_CODE = 'A'))))
                                      AND X.Status_CODE = 'COMP'
                                      AND CONVERT(VARCHAR(10), X.Update_DTTM, 101) = CONVERT(VARCHAR(10), @Ld_Run_DATE, 101))
                        OR EXISTS (SELECT 1
                                     FROM CMEM_Y1 X
                                    WHERE X.Case_IDNO = A.Case_IDNO
                                      AND X.CaseRelationship_CODE = 'D'
                                      AND X.CaseMemberStatus_CODE = 'A'
                                      AND (EXISTS (SELECT 1
                                                     FROM MPAT_Y1 Y
                                                    WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                      AND Y.BeginValidity_DATE = @Ld_Run_DATE
                                                      AND NOT EXISTS (SELECT 1
                                                                        FROM HMPAT_Y1 Z
                                                                       WHERE Z.MemberMci_IDNO = Y.MemberMci_IDNO
                                                                         AND Z.EndValidity_DATE = @Ld_Run_DATE))
                                            OR EXISTS (SELECT 1
                                                         FROM HMPAT_Y1 Y
                                                        WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                          AND Y.EndValidity_DATE = @Ld_Run_DATE
                                                          AND EXISTS (SELECT 1
                                                                        FROM MPAT_Y1 Z
                                                                       WHERE Z.MemberMci_IDNO = Y.MemberMci_IDNO
                                                                         AND Z.BeginValidity_DATE = @Ld_Run_DATE))))
                        OR (EXISTS (SELECT 1
                                      FROM SORD_Y1 X
                                     WHERE X.Case_IDNO = A.Case_IDNO
                                       AND X.BeginValidity_DATE = @Ld_Run_DATE
                                       AND X.EndValidity_DATE = @Ld_High_DATE
                                       AND NOT EXISTS (SELECT 1
                                                         FROM SORD_Y1 Y
                                                        WHERE Y.Case_IDNO = X.Case_IDNO
                                                          AND Y.EndValidity_DATE = @Ld_Run_DATE))
                             OR EXISTS (SELECT 1
                                          FROM SORD_Y1 X
                                         WHERE X.Case_IDNO = A.Case_IDNO
                                           AND X.BeginValidity_DATE = @Ld_Run_DATE
                                           AND X.EndValidity_DATE = @Ld_High_DATE
                                           AND EXISTS (SELECT 1
                                                         FROM SORD_Y1 Y
                                                        WHERE Y.Case_IDNO = X.Case_IDNO
                                                          AND Y.EndValidity_DATE = @Ld_Run_DATE)))
                        OR (EXISTS (SELECT 1
                                      FROM OBLE_Y1 X
                                     WHERE X.Case_IDNO = A.Case_IDNO
                                       AND X.BeginValidity_DATE = @Ld_Run_DATE
                                       AND X.EndValidity_DATE = @Ld_High_DATE
                                       AND NOT EXISTS (SELECT 1
                                                         FROM OBLE_Y1 Y
                                                        WHERE Y.Case_IDNO = X.Case_IDNO
                                                          AND Y.EndValidity_DATE = @Ld_Run_DATE))
                             OR EXISTS (SELECT 1
                                          FROM OBLE_Y1 X
                                         WHERE X.Case_IDNO = A.Case_IDNO
                                           AND X.BeginValidity_DATE = @Ld_Run_DATE
                                           AND X.EndValidity_DATE = @Ld_High_DATE
                                           AND EXISTS (SELECT 1
                                                         FROM OBLE_Y1 Y
                                                        WHERE Y.Case_IDNO = X.Case_IDNO
                                                          AND Y.EndValidity_DATE = @Ld_Run_DATE)))
                        OR (EXISTS (SELECT 1
                                      FROM DSBL_Y1 X
                                     WHERE X.Case_IDNO = A.Case_IDNO
                                       AND X.TypeDisburse_CODE = 'CXPAA'
                                       AND x.Disburse_DATE = @Ld_Run_DATE)))) B) D,
          CASE_Y1 E,
          ENSD_Y1 F
          LEFT OUTER JOIN AHIS_Y1 G
           ON G.MemberMci_IDNO = F.CpMci_IDNO
              AND G.TypeAddress_CODE = 'M'
              AND G.End_DATE = @Ld_High_DATE
              AND ((G.SourceLoc_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                    AND G.Status_CODE = 'Y')
                    OR (G.SourceLoc_CODE IN ('NDH', 'IRS', 'FID', 'FCR')
                        AND G.SourceVerified_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                        AND G.Status_CODE = 'Y'))
    WHERE E.Case_IDNO = D.Case_IDNO
      AND F.Case_IDNO = E.Case_IDNO
    ORDER BY D.Case_IDNO;

   /*
   	Get Children Info on each case
   */
   SET @Ls_Sql_TEXT = 'GET CHILDREN INFO';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.Case_IDNO,
          Row_NUMB = ROW_NUMBER() OVER (PARTITION BY B.Case_IDNO ORDER BY B.Case_IDNO, C.Birth_DATE),
          C.Birth_DATE,
          B.MemberMci_IDNO
     INTO #ChildrenInfo_P1
     FROM #CaseUpdatesInfo_P1 A,
          CMEM_Y1 B,
          DEMO_Y1 C
    WHERE B.Case_IDNO = A.Case_IDNO
      AND B.CaseRelationship_CODE = 'D'
      AND C.MemberMci_IDNO = B.MemberMci_IDNO;

   /*
   	Get Case Member Info
   */
   SET @Ls_Sql_TEXT = 'GET CASE AND MEMBER INFO';
   SET @Ls_SqlData_TEXT = '';

   SELECT DISTINCT
          A.CaseWelfare_IDNO,
          A.Case_IDNO,
          A.Distribute_DATE,
          A.Distribute_AMNT,
          A.StatusCase_CODE,
          A.TypeCase_CODE,
          A.CaseCategory_CODE,
          A.County_IDNO,
          A.NonCoop_CODE,
          A.NonCoop_DATE,
          A.GoodCause_CODE,
          A.GoodCause_DATE,
          A.CpMci_IDNO,
          A.FirstCp_NAME,
          A.MiddleCp_NAME,
          A.LastCp_NAME,
          A.SuffixCp_NAME,
          A.NcpMci_IDNO,
          A.FirstNcp_NAME,
          A.MiddleNcp_NAME,
          A.LastNcp_NAME,
          A.SuffixNcp_NAME,
          A.NcpResideStatus_INDC,
          A.Mso_AMNT,
          A.FreqLeastOble_CODE,
          A.PaymentLastReceived_AMNT,
          A.ReceiptLast_DATE,
          A.TypeAddress_CODE,
          A.Status_CODE,
          A.Line1Cp_ADDR,
          A.Line2Cp_ADDR,
          A.CityCp_ADDR,
          A.StateCp_ADDR,
          A.Zip_ADDR,
          A.ZipCp_ADDR,
          ISNULL((SELECT ISNULL(X.MemberMci_IDNO, '')
                    FROM #ChildrenInfo_P1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 1), '0') AS Child1Mci_IDNO,
          ISNULL((SELECT ISNULL(Y.First_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 1
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS FirstChild1_NAME,
          ISNULL((SELECT ISNULL(Y.Middle_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 1
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS MiddleChild1_NAME,
          ISNULL((SELECT ISNULL(Y.Last_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 1
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS LastChild1_NAME,
          ISNULL((SELECT ISNULL(Y.Suffix_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 1
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS SuffixChild1_NAME,
          ISNULL((SELECT ISNULL(Y.PaternityEst_INDC, '')
                    FROM #ChildrenInfo_P1 X,
                         MPAT_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 1
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS Child1PaternityEst_INDC,
          ISNULL((SELECT ISNULL(X.MemberMci_IDNO, '')
                    FROM #ChildrenInfo_P1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 2), '0') AS Child2Mci_IDNO,
          ISNULL((SELECT ISNULL(Y.First_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 2
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS FirstChild2_NAME,
          ISNULL((SELECT ISNULL(Y.Middle_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 2
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS MiddleChild2_NAME,
          ISNULL((SELECT ISNULL(Y.Last_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 2
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS LastChild2_NAME,
          ISNULL((SELECT ISNULL(Y.Suffix_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 2
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS SuffixChild2_NAME,
          ISNULL((SELECT ISNULL(Y.PaternityEst_INDC, '')
                    FROM #ChildrenInfo_P1 X,
                         MPAT_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 2
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS Child2PaternityEst_INDC,
          ISNULL((SELECT ISNULL(X.MemberMci_IDNO, '')
                    FROM #ChildrenInfo_P1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 3), '0') AS Child3Mci_IDNO,
          ISNULL((SELECT ISNULL(Y.First_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 3
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS FirstChild3_NAME,
          ISNULL((SELECT ISNULL(Y.Middle_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 3
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS MiddleChild3_NAME,
          ISNULL((SELECT ISNULL(Y.Last_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 3
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS LastChild3_NAME,
          ISNULL((SELECT ISNULL(Y.Suffix_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 3
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS SuffixChild3_NAME,
          ISNULL((SELECT ISNULL(Y.PaternityEst_INDC, '')
                    FROM #ChildrenInfo_P1 X,
                         MPAT_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 3
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS Child3PaternityEst_INDC,
          ISNULL((SELECT ISNULL(X.MemberMci_IDNO, '')
                    FROM #ChildrenInfo_P1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 4), '0') AS Child4Mci_IDNO,
          ISNULL((SELECT ISNULL(Y.First_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 4
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS FirstChild4_NAME,
          ISNULL((SELECT ISNULL(Y.Middle_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 4
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS MiddleChild4_NAME,
          ISNULL((SELECT ISNULL(Y.Last_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 4
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS LastChild4_NAME,
          ISNULL((SELECT ISNULL(Y.Suffix_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 4
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS SuffixChild4_NAME,
          ISNULL((SELECT ISNULL(Y.PaternityEst_INDC, '')
                    FROM #ChildrenInfo_P1 X,
                         MPAT_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 4
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS Child4PaternityEst_INDC,
          ISNULL((SELECT ISNULL(X.MemberMci_IDNO, '')
                    FROM #ChildrenInfo_P1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 5), '0') AS Child5Mci_IDNO,
          ISNULL((SELECT ISNULL(Y.First_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 5
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS FirstChild5_NAME,
          ISNULL((SELECT ISNULL(Y.Middle_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 5
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS MiddleChild5_NAME,
          ISNULL((SELECT ISNULL(Y.Last_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 5
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS LastChild5_NAME,
          ISNULL((SELECT ISNULL(Y.Suffix_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 5
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS SuffixChild5_NAME,
          ISNULL((SELECT ISNULL(Y.PaternityEst_INDC, '')
                    FROM #ChildrenInfo_P1 X,
                         MPAT_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 5
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS Child5PaternityEst_INDC,
          ISNULL((SELECT ISNULL(X.MemberMci_IDNO, '')
                    FROM #ChildrenInfo_P1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 6), '0') AS Child6Mci_IDNO,
          ISNULL((SELECT ISNULL(Y.First_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 6
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS FirstChild6_NAME,
          ISNULL((SELECT ISNULL(Y.Middle_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 6
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS MiddleChild6_NAME,
          ISNULL((SELECT ISNULL(Y.Last_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 6
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS LastChild6_NAME,
          ISNULL((SELECT ISNULL(Y.Suffix_NAME, '')
                    FROM #ChildrenInfo_P1 X,
                         DEMO_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 6
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS SuffixChild6_NAME,
          ISNULL((SELECT ISNULL(Y.PaternityEst_INDC, '')
                    FROM #ChildrenInfo_P1 X,
                         MPAT_Y1 Y
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND X.Row_NUMB = 6
                     AND Y.MemberMci_IDNO = X.MemberMci_IDNO), '') AS Child6PaternityEst_INDC
     INTO #CaseMemberInfo_P1
     FROM #CaseUpdatesInfo_P1 A,
          #ChildrenInfo_P1 B
    WHERE B.Case_IDNO = A.Case_IDNO
    ORDER BY A.Case_IDNO;

   /*
   	Prepare retrieved data to load into EIVDC_Y1
   */
   SET @Ls_Sql_TEXT = 'PREPARE RETRIEVED DATA TO LOAD INTO EIVDC_Y1';
   SET @Ls_SqlData_TEXT = '';

   SELECT A.Case_IDNO,
          A.CaseWelfare_IDNO,
          A.County_IDNO,
          A.NonCoop_CODE,
          A.NonCoop_DATE,
          A.GoodCause_CODE,
          A.GoodCause_DATE,
          A.CpMci_IDNO,
          A.FirstCp_NAME,
          A.MiddleCp_NAME,
          A.LastCp_NAME,
          A.SuffixCp_NAME,
          A.Line1Cp_ADDR,
          A.Line2Cp_ADDR,
          A.CityCp_ADDR,
          A.StateCp_ADDR,
          A.ZipCp_ADDR,
          A.NcpMci_IDNO,
          A.FirstNcp_NAME,
          A.MiddleNcp_NAME,
          A.LastNcp_NAME,
          A.SuffixNcp_NAME,
          A.NcpResideStatus_INDC,
          A.Mso_AMNT,
          A.FreqLeastOble_CODE,
          'S' AS SupportOrderPaymentMode_CODE,
          A.PaymentLastReceived_AMNT,
          A.ReceiptLast_DATE,
          A.Distribute_AMNT,
          A.Distribute_DATE,
          A.Child1Mci_IDNO,
          A.FirstChild1_NAME,
          A.MiddleChild1_NAME,
          A.LastChild1_NAME,
          A.SuffixChild1_NAME,
          A.Child1PaternityEst_INDC,
          CASE
           WHEN A.Child1Mci_IDNO > 0
            THEN 'Y'
           ELSE 'N'
          END AS Child1ResideStatus_INDC,
          A.Child2Mci_IDNO,
          A.FirstChild2_NAME,
          A.MiddleChild2_NAME,
          A.LastChild2_NAME,
          A.SuffixChild2_NAME,
          A.Child2PaternityEst_INDC,
          CASE
           WHEN A.Child2Mci_IDNO > 0
            THEN 'Y'
           ELSE 'N'
          END AS Child2ResideStatus_INDC,
          A.Child3Mci_IDNO,
          A.FirstChild3_NAME,
          A.MiddleChild3_NAME,
          A.LastChild3_NAME,
          A.SuffixChild3_NAME,
          A.Child3PaternityEst_INDC,
          CASE
           WHEN A.Child3Mci_IDNO > 0
            THEN 'Y'
           ELSE 'N'
          END AS Child3ResideStatus_INDC,
          A.Child4Mci_IDNO,
          A.FirstChild4_NAME,
          A.MiddleChild4_NAME,
          A.LastChild4_NAME,
          A.SuffixChild4_NAME,
          A.Child4PaternityEst_INDC,
          CASE
           WHEN A.Child4Mci_IDNO > 0
            THEN 'Y'
           ELSE 'N'
          END AS Child4ResideStatus_INDC,
          A.Child5Mci_IDNO,
          A.FirstChild5_NAME,
          A.MiddleChild5_NAME,
          A.LastChild5_NAME,
          A.SuffixChild5_NAME,
          A.Child5PaternityEst_INDC,
          CASE
           WHEN A.Child5Mci_IDNO > 0
            THEN 'Y'
           ELSE 'N'
          END AS Child5ResideStatus_INDC,
          A.Child6Mci_IDNO,
          A.FirstChild6_NAME,
          A.MiddleChild6_NAME,
          A.LastChild6_NAME,
          A.SuffixChild6_NAME,
          A.Child6PaternityEst_INDC,
          CASE
           WHEN A.Child6Mci_IDNO > 0
            THEN 'Y'
           ELSE 'N'
          END AS Child6ResideStatus_INDC
     INTO #FinExtractToIvaCupd_P1
     FROM #CaseMemberInfo_P1 A
    ORDER BY A.Case_IDNO;

   SET @Ls_Sql_TEXT = 'INSERT EIVDC_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO EIVDC_Y1
               (Case_IDNO,
                CaseWelfare_IDNO,
                County_IDNO,
                NonCoop_CODE,
                NonCoop_DATE,
                GoodCause_CODE,
                GoodCause_DATE,
                CpMci_IDNO,
                FirstCp_NAME,
                MiddleCp_NAME,
                LastCp_NAME,
                SuffixCp_NAME,
                Line1Cp_ADDR,
                Line2Cp_ADDR,
                CityCp_ADDR,
                StateCp_ADDR,
                ZipCp_ADDR,
                NcpMci_IDNO,
                FirstNcp_NAME,
                MiddleNcp_NAME,
                LastNcp_NAME,
                SuffixNcp_NAME,
                NcpResideStatus_INDC,
                Mso_AMNT,
                FreqLeastOble_CODE,
                SupportOrderPaymentMode_CODE,
                PaymentLastReceived_AMNT,
                ReceiptLast_DATE,
                Distribute_AMNT,
                Distribute_DATE,
                Child1Mci_IDNO,
                FirstChild1_NAME,
                MiddleChild1_NAME,
                LastChild1_NAME,
                SuffixChild1_NAME,
                Child1PaternityEst_INDC,
                Child1ResideStatus_INDC,
                Child2Mci_IDNO,
                FirstChild2_NAME,
                MiddleChild2_NAME,
                LastChild2_NAME,
                SuffixChild2_NAME,
                Child2PaternityEst_INDC,
                Child2ResideStatus_INDC,
                Child3Mci_IDNO,
                FirstChild3_NAME,
                MiddleChild3_NAME,
                LastChild3_NAME,
                SuffixChild3_NAME,
                Child3PaternityEst_INDC,
                Child3ResideStatus_INDC,
                Child4Mci_IDNO,
                FirstChild4_NAME,
                MiddleChild4_NAME,
                LastChild4_NAME,
                SuffixChild4_NAME,
                Child4PaternityEst_INDC,
                Child4ResideStatus_INDC,
                Child5Mci_IDNO,
                FirstChild5_NAME,
                MiddleChild5_NAME,
                LastChild5_NAME,
                SuffixChild5_NAME,
                Child5PaternityEst_INDC,
                Child5ResideStatus_INDC,
                Child6Mci_IDNO,
                FirstChild6_NAME,
                MiddleChild6_NAME,
                LastChild6_NAME,
                SuffixChild6_NAME,
                Child6PaternityEst_INDC,
                Child6ResideStatus_INDC)
   SELECT (RIGHT(REPLICATE('0', 6) + LTRIM(RTRIM(A.Case_IDNO)), 6)) AS Case_IDNO,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.CaseWelfare_IDNO)), 10)) AS CaseWelfare_IDNO,
          (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(A.County_IDNO)), 3)) AS County_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.NonCoop_CODE)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) AS NonCoop_CODE,
          CASE
           WHEN LTRIM(RTRIM(A.NonCoop_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
            THEN REPLICATE(@Lc_Space_TEXT, 8)
           ELSE ISNULL(CAST(LEFT((LTRIM(RTRIM(CONVERT(VARCHAR(8), A.NonCoop_DATE, 112))) + REPLICATE(' ', 8)), 8) AS CHAR(8)), REPLICATE(@Lc_Space_TEXT, 8))
          END AS NonCoop_DATE,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.GoodCause_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS GoodCause_CODE,
          CASE
           WHEN LTRIM(RTRIM(A.GoodCause_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
            THEN REPLICATE(@Lc_Space_TEXT, 8)
           ELSE ISNULL(CAST(LEFT((LTRIM(RTRIM(CONVERT(VARCHAR(8), A.GoodCause_DATE, 112))) + REPLICATE(' ', 8)), 8) AS CHAR(8)), REPLICATE(@Lc_Space_TEXT, 8))
          END AS GoodCause_DATE,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.CpMci_IDNO)), 10)) AS CpMci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstCp_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstCp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleCp_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleCp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastCp_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastCp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixCp_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixCp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Line1Cp_ADDR)) + REPLICATE(' ', 25)), 25) AS CHAR(25)), REPLICATE(@Lc_Space_TEXT, 25))) AS Line1Cp_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Line2Cp_ADDR)) + REPLICATE(' ', 25)), 25) AS CHAR(25)), REPLICATE(@Lc_Space_TEXT, 25))) AS Line2Cp_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.CityCp_ADDR)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS CityCp_ADDR,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.StateCp_ADDR)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) AS StateCp_ADDR,
          (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(A.ZipCp_ADDR)), 9)) AS ZipCp_ADDR,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.NcpMci_IDNO)), 10)) AS NcpMci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstNcp_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstNcp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleNcp_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleNcp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastNcp_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastNcp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixNcp_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixNcp_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.NcpResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS NcpResideStatus_INDC,
          (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(A.Mso_AMNT)), 9)) AS Mso_AMNT,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FreqLeastOble_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS FreqLeastOble_CODE,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SupportOrderPaymentMode_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS SupportOrderPaymentMode_CODE,
          (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(A.PaymentLastReceived_AMNT)), 9)) AS PaymentLastReceived_AMNT,
          CASE
           WHEN LTRIM(RTRIM(A.ReceiptLast_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
            THEN REPLICATE(@Lc_Space_TEXT, 8)
           ELSE ISNULL(CAST(LEFT((LTRIM(RTRIM(CONVERT(VARCHAR(8), A.ReceiptLast_DATE, 112))) + REPLICATE(' ', 8)), 8) AS CHAR(8)), REPLICATE(@Lc_Space_TEXT, 8))
          END AS ReceiptLast_DATE,
          (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(A.Distribute_AMNT)), 9)) AS Distribute_AMNT,
          CASE
           WHEN LTRIM(RTRIM(A.Distribute_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
            THEN REPLICATE(@Lc_Space_TEXT, 8)
           ELSE ISNULL(CAST(LEFT((LTRIM(RTRIM(CONVERT(VARCHAR(8), A.Distribute_DATE, 112))) + REPLICATE(' ', 8)), 8) AS CHAR(8)), REPLICATE(@Lc_Space_TEXT, 8))
          END AS Distribute_DATE,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.Child1Mci_IDNO)), 10)) AS Child1Mci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstChild1_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstChild1_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleChild1_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleChild1_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastChild1_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastChild1_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixChild1_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixChild1_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child1PaternityEst_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child1PaternityEst_INDC,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child1ResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child1ResideStatus_INDC,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.Child2Mci_IDNO)), 10)) AS Child2Mci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstChild2_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstChild2_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleChild2_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleChild2_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastChild2_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastChild2_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixChild2_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixChild2_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child2PaternityEst_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child2PaternityEst_INDC,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child2ResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child2ResideStatus_INDC,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.Child3Mci_IDNO)), 10)) AS Child3Mci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstChild3_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstChild3_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleChild3_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleChild3_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastChild3_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastChild3_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixChild3_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixChild3_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child3PaternityEst_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child3PaternityEst_INDC,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child3ResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child3ResideStatus_INDC,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.Child4Mci_IDNO)), 10)) AS Child4Mci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstChild4_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstChild4_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleChild4_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleChild4_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastChild4_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastChild4_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixChild4_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixChild4_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child4PaternityEst_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child4PaternityEst_INDC,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child4ResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child4ResideStatus_INDC,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.Child5Mci_IDNO)), 10)) AS Child5Mci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstChild5_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstChild5_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleChild5_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleChild5_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastChild5_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastChild5_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixChild5_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixChild5_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child5PaternityEst_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child5PaternityEst_INDC,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child5ResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child5ResideStatus_INDC,
          (RIGHT(REPLICATE('0', 10) + LTRIM(RTRIM(A.Child6Mci_IDNO)), 10)) AS Child6Mci_IDNO,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.FirstChild6_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) AS FirstChild6_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.MiddleChild6_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS MiddleChild6_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.LastChild6_NAME)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) AS LastChild6_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.SuffixChild6_NAME)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) AS SuffixChild6_NAME,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child6PaternityEst_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child6PaternityEst_INDC,
          (ISNULL(CAST(LEFT((LTRIM(RTRIM(A.Child6ResideStatus_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) AS Child6ResideStatus_INDC
     FROM #FinExtractToIvaCupd_P1 A
    ORDER BY A.Case_IDNO;

   SET @Ln_RecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_RecordCount_QNTY = 0
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

   SET @Ls_Sql_TEXT = 'INSERT HEADER RECORD';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##FinExtractToIvaCupd_P1
               (Record_TEXT)
   SELECT 'H' + CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 688);

   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT DETAIL RECORD';
     SET @Ls_SqlData_TEXT = '';

     INSERT INTO ##FinExtractToIvaCupd_P1
                 (Record_TEXT)
     SELECT (A.Case_IDNO + A.CaseWelfare_IDNO + A.County_IDNO + A.NonCoop_CODE + A.NonCoop_DATE + A.GoodCause_CODE + A.GoodCause_DATE + A.CpMci_IDNO + A.FirstCp_NAME + A.MiddleCp_NAME + A.LastCp_NAME + A.SuffixCp_NAME + A.Line1Cp_ADDR + A.Line2Cp_ADDR + A.CityCp_ADDR + A.StateCp_ADDR + A.ZipCp_ADDR + A.NcpMci_IDNO + A.FirstNcp_NAME + A.MiddleNcp_NAME + A.LastNcp_NAME + A.SuffixNcp_NAME + A.NcpResideStatus_INDC + A.Mso_AMNT + A.FreqLeastOble_CODE + A.SupportOrderPaymentMode_CODE + A.PaymentLastReceived_AMNT + A.ReceiptLast_DATE + A.Distribute_AMNT + A.Distribute_DATE + A.Child1Mci_IDNO + A.FirstChild1_NAME + A.MiddleChild1_NAME + A.LastChild1_NAME + A.SuffixChild1_NAME + A.Child1PaternityEst_INDC + A.Child1ResideStatus_INDC + A.Child2Mci_IDNO + A.FirstChild2_NAME + A.MiddleChild2_NAME + A.LastChild2_NAME + A.SuffixChild2_NAME + A.Child2PaternityEst_INDC + A.Child2ResideStatus_INDC + A.Child3Mci_IDNO + A.FirstChild3_NAME + A.MiddleChild3_NAME + A.LastChild3_NAME + A.SuffixChild3_NAME + A.Child3PaternityEst_INDC + A.Child3ResideStatus_INDC + A.Child4Mci_IDNO + A.FirstChild4_NAME + A.MiddleChild4_NAME + A.LastChild4_NAME + A.SuffixChild4_NAME + A.Child4PaternityEst_INDC + A.Child4ResideStatus_INDC + A.Child5Mci_IDNO + A.FirstChild5_NAME + A.MiddleChild5_NAME + A.LastChild5_NAME + A.SuffixChild5_NAME + A.Child5PaternityEst_INDC + A.Child5ResideStatus_INDC + A.Child6Mci_IDNO + A.FirstChild6_NAME + A.MiddleChild6_NAME + A.LastChild6_NAME + A.SuffixChild6_NAME + A.Child6PaternityEst_INDC + A.Child6ResideStatus_INDC) AS Record_TEXT
       FROM EIVDC_Y1 A
      ORDER BY A.CaseWelfare_IDNO,
               A.Case_IDNO;

     SET @Ln_RecordCount_QNTY = @@ROWCOUNT;

     IF @Ln_RecordCount_QNTY = 0
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
       SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
       SET @Ls_ErrorMessage_TEXT = 'INSERT DETAIL RECORD INTO ##FinExtractToIvaCupd_P1 FAILED';

       RAISERROR(50001,16,1);
      END;
     ELSE
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY += @Ln_RecordCount_QNTY;
      END;
    END;

   SET @Ls_Sql_TEXT = 'INSERT TRAILER RECORD';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##FinExtractToIvaCupd_P1
               (Record_TEXT)
   SELECT 'T' + (RIGHT(REPLICATE('0', 8) + LTRIM(RTRIM(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR))), 8)) + REPLICATE(@Lc_Space_TEXT, 688);

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_CUPD';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_CUPD;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##FinExtractToIvaCupd_P1';
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

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_CUPD';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION FIN_EXTRACT_TO_IVA_CUPD;

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
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_CUPD';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION FIN_EXTRACT_TO_IVA_CUPD;

   SET @Ls_Sql_TEXT = 'DROP ALL TEMPORARY TABLES';
   SET @Ls_SqlData_TEXT = '';

   DROP TABLE ##FinExtractToIvaCupd_P1;

   DROP TABLE #CaseUpdatesInfo_P1;

   DROP TABLE #ChildrenInfo_P1;

   DROP TABLE #CaseMemberInfo_P1;

   DROP TABLE #FinExtractToIvaCupd_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FIN_EXTRACT_TO_IVA_CUPD;
    END;

   IF OBJECT_ID('tempdb..##FinExtractToIvaCupd_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##FinExtractToIvaCupd_P1;
    END;

   IF OBJECT_ID('tempdb..#CaseUpdatesInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CaseUpdatesInfo_P1;
    END

   IF OBJECT_ID('tempdb..#ChildrenInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #ChildrenInfo_P1;
    END

   IF OBJECT_ID('tempdb..#CaseMemberInfo_P1') IS NOT NULL
    BEGIN
     DROP TABLE #CaseMemberInfo_P1;
    END

   IF OBJECT_ID('tempdb..#FinExtractToIvaCupd_P1') IS NOT NULL
    BEGIN
     DROP TABLE #FinExtractToIvaCupd_P1;
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
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
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
