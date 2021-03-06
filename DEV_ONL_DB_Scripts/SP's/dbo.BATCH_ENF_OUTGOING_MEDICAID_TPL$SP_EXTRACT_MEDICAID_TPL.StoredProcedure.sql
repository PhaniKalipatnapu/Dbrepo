/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_MEDICAID_TPL$SP_EXTRACT_MEDICAID_TPL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_MEDICAID_TPL$SP_EXTRACT_MEDICAID_TPL
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_MEDICAID_TPL$SP_EXTRACT_MEDICAID_TPL batch process is to 
					  extract the active members who have health insurance ordered and insurance details available 
					  from the system's database to send file to Medicaid
Frequency		:	'MONTHLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_MEDICAID_TPL$SP_EXTRACT_MEDICAID_TPL]
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
          @Lc_Job_ID                 CHAR(7) = 'DEB6370',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_MEDICAID_TPL',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_OUTGOING_MEDICAID_TPL',
          @Ls_BateError_TEXT         VARCHAR(4000) = 'NO RECORD(S) TO PROCESS',
          @Ld_High_DATE              DATE = '12/31/9999',
          @Ld_Low_DATE               DATE = '01/01/0001';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
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
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   CREATE TABLE ##ExtractTpl_P1
    (
      Record_TEXT CHAR(1400)
    );

   BEGIN TRANSACTION OUTGOING_MEDICAID_TPL;

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
     SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME;
   SET @Ls_FileSource_TEXT = @Lc_Empty_TEXT + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_FileName_NAME));

   IF @Ls_FileSource_TEXT = @Lc_Empty_TEXT
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   DELETE FROM EMTPL_Y1;

   SET @Ls_Sql_TEXT = 'GET ALL ACTIVE DEPENDANTS FROM INS ORDERED OPEN IV-D CASES';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          C.MemberMci_IDNO AS ChildMCI_IDNO
     INTO #ActiveChildrenInOpenIvDCases_P1
     FROM CASE_Y1 A,
          ENSD_Y1 B,
          CMEM_Y1 C
    WHERE A.StatusCase_CODE = 'O'
      AND A.TypeCase_CODE <> 'H'
      AND B.Case_IDNO = A.Case_IDNO
      AND B.InsOrdered_CODE <> 'N'
      AND EXISTS (SELECT 1
                    FROM SORD_Y1 X
                   WHERE X.Case_IDNO = B.Case_IDNO
                     AND @Ld_Run_DATE BETWEEN X.OrderEffective_DATE AND X.OrderEnd_DATE
                     AND X.EndValidity_DATE = @Ld_High_DATE)
      AND C.Case_IDNO = A.Case_IDNO
      AND C.CaseRelationship_CODE = 'D'
      AND C.CaseMemberStatus_CODE = 'A';

   SET @Ls_Sql_TEXT = 'GET CHILDREN INFO THAT ARE IN DINS';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          C.MemberMci_IDNO,
          C.ChildMCI_IDNO,
          D.PolicyHolderRelationship_CODE,
          C.OthpInsurance_IDNO,
          C.PolicyInsNo_TEXT,
          C.InsuranceGroupNo_TEXT
     INTO #ChildrenInDins_P1
     FROM #ActiveChildrenInOpenIvDCases_P1 A,
          CMEM_Y1 B,
          DINS_Y1 C,
          MINS_Y1 D
    WHERE B.Case_IDNO = A.Case_IDNO
      AND B.CaseRelationship_CODE IN ('C', 'A')
      AND B.CaseMemberStatus_CODE = 'A'
      AND C.MemberMci_IDNO = B.MemberMci_IDNO
      AND C.ChildMCI_IDNO = A.ChildMCI_IDNO
      AND ISNULL(C.OthpInsurance_IDNO, 0) > 0
      AND (LEN(LTRIM(RTRIM(ISNULL(C.PolicyInsNo_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(C.InsuranceGroupNo_TEXT, '')))) > 0)
      AND @Ld_Run_DATE BETWEEN C.Begin_DATE AND C.End_DATE
      AND C.EndValidity_DATE = @Ld_High_DATE
      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                          FROM DINS_Y1 X
                                         WHERE X.MemberMci_IDNO = C.MemberMci_IDNO
                                           AND X.ChildMCI_IDNO = C.ChildMCI_IDNO
                                           AND X.OthpInsurance_IDNO = C.OthpInsurance_IDNO
                                           AND X.InsuranceGroupNo_TEXT = C.InsuranceGroupNo_TEXT
                                           AND X.PolicyInsNo_TEXT = C.PolicyInsNo_TEXT
                                           AND @Ld_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                                           AND X.EndValidity_DATE = @Ld_High_DATE)
      AND D.MemberMci_IDNO = C.MemberMci_IDNO
      AND D.OthpInsurance_IDNO = C.OthpInsurance_IDNO
      AND D.InsuranceGroupNo_TEXT = C.InsuranceGroupNo_TEXT
      AND D.PolicyInsNo_TEXT = C.PolicyInsNo_TEXT
      AND @Ld_Run_DATE BETWEEN D.Begin_DATE AND D.End_DATE
      AND D.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #DinsInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          X.Case_IDNO,
          X.ChildMCI_IDNO,
          X.InsHolderMemberMci_IDNO,
          X.CaseRelationship_CODE,
          X.CaseMemberStatus_CODE,
          X.PolicyHolderRelationship_CODE,
          X.OthpInsurance_IDNO,
          X.PolicyInsNo_TEXT,
          X.InsuranceGroupNo_TEXT
     INTO #DinsInfo_P1
     FROM (SELECT DISTINCT
                  A.Case_IDNO,
                  A.ChildMCI_IDNO,
                  ISNULL(B.MemberMci_IDNO, 0) AS InsHolderMemberMci_IDNO,
                  CASE
                   WHEN ISNULL(B.MemberMci_IDNO, 0) > 0
                    THEN C.CaseRelationship_CODE
                   ELSE ''
                  END AS CaseRelationship_CODE,
                  CASE
                   WHEN ISNULL(B.MemberMci_IDNO, 0) > 0
                    THEN C.CaseMemberStatus_CODE
                   ELSE 'X'
                  END AS CaseMemberStatus_CODE,
                  ISNULL(B.PolicyHolderRelationship_CODE, '') AS PolicyHolderRelationship_CODE,
                  ISNULL(B.OthpInsurance_IDNO, 0) AS OthpInsurance_IDNO,
                  ISNULL(B.PolicyInsNo_TEXT, '') AS PolicyInsNo_TEXT,
                  ISNULL(B.InsuranceGroupNo_TEXT, '') AS InsuranceGroupNo_TEXT
             FROM #ActiveChildrenInOpenIvDCases_P1 A
                  LEFT OUTER JOIN #ChildrenInDins_P1 B
                   ON B.ChildMCI_IDNO = A.ChildMCI_IDNO
                  LEFT OUTER JOIN CMEM_Y1 C
                   ON C.MemberMci_IDNO = B.MemberMci_IDNO
                      AND C.Case_IDNO = A.Case_IDNO
                      AND C.CaseRelationship_CODE IN ('A', 'C')) X
    WHERE X.CaseMemberStatus_CODE <> 'I'
    ORDER BY X.Case_IDNO,
             X.ChildMCI_IDNO;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #ChildDemoInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          B.MemberMci_IDNO AS InsuredMemberMci_IDNO,
          B.Last_NAME AS LastInsured_NAME,
          B.First_NAME AS FirstInsured_NAME,
          B.Middle_NAME AS MiddleInsured_NAME,
          B.Suffix_NAME AS SuffixInsured_NAME,
          B.MemberSsn_NUMB AS InsuredMemberSsn_NUMB,
          B.Birth_DATE AS BirthInsured_DATE,
          B.MemberSex_CODE AS InsuredMemberSex_CODE
     INTO #ChildDemoInfo_P1
     FROM #DinsInfo_P1 A,
          DEMO_Y1 B
    WHERE B.MemberMci_IDNO = A.ChildMCI_IDNO;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #CpNcpDemoInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          B.CpMci_IDNO,
          C.FullDisplay_NAME AS CpFull_NAME,
          B.LastCp_NAME,
          B.FirstCp_NAME,
          B.MiddleCp_NAME,
          B.SuffixCp_NAME,
          B.VerifiedItinCpSsn_NUMB AS CpSsn_NUMB,
          B.BirthCp_DATE,
          C.MemberSex_CODE AS CpSex_CODE,
          B.NcpPf_IDNO AS NcpMci_IDNO,
          D.FullDisplay_NAME AS NcpFull_NAME,
          B.LastNcp_NAME,
          B.FirstNcp_NAME,
          B.MiddleNcp_NAME,
          B.SuffixNcp_NAME,
          B.VerifiedltinNcpOrpfSsn_NUMB AS NcpSsn_NUMB,
          B.BirthNcp_DATE,
          D.MemberSex_CODE AS NcpSex_CODE
     INTO #CpNcpDemoInfo_P1
     FROM #DinsInfo_P1 A,
          ENSD_Y1 B,
          DEMO_Y1 C,
          DEMO_Y1 D
    WHERE B.Case_IDNO = A.Case_IDNO
      AND C.MemberMci_IDNO = B.CpMci_IDNO
      AND D.MemberMci_IDNO = B.NcpPf_IDNO
    ORDER BY A.Case_IDNO,
             A.ChildMCI_IDNO;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #CpAddrInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          E.Case_IDNO,
          E.ChildMCI_IDNO,
          E.MemberMci_IDNO AS CpMci_IDNO,
          E.AddressHierarchyOrder_CODE,
          E.TypeAddress_CODE,
          E.Status_CODE,
          E.Begin_DATE,
          E.End_DATE,
          E.Line1_ADDR AS Line1Cp_ADDR,
          E.Line2_ADDR AS Line2Cp_ADDR,
          E.City_ADDR AS CityCp_ADDR,
          E.State_ADDR AS StateCp_ADDR,
          LTRIM(RTRIM(REPLACE(ISNULL(E.Zip_ADDR, ''), '-', ''))) AS ZipCpFull_ADDR,
          CASE LEN(LTRIM(RTRIM(REPLACE(ISNULL(E.Zip_ADDR, ''), '-', ''))))
           WHEN 5
            THEN LTRIM(RTRIM(E.Zip_ADDR)) + '0000'
           WHEN 9
            THEN LTRIM(RTRIM(REPLACE(ISNULL(E.Zip_ADDR, ''), '-', '')))
           ELSE '0'
          END AS ZipCp_ADDR
     INTO #CpAddrInfo_P1
     FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY D.Case_IDNO, D.ChildMCI_IDNO, D.MemberMci_IDNO ORDER BY D.Case_IDNO, D.ChildMCI_IDNO, D.MemberMci_IDNO, D.AddressHierarchyOrder_CODE ),
                  D.Case_IDNO,
                  D.ChildMCI_IDNO,
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
                          A.Case_IDNO,
                          A.ChildMCI_IDNO,
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
                             ELSE 7
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
                     FROM #DinsInfo_P1 A,
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

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #NcpAddrInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          E.Case_IDNO,
          E.ChildMCI_IDNO,
          E.MemberMci_IDNO AS NcpMci_IDNO,
          E.AddressHierarchyOrder_CODE,
          E.TypeAddress_CODE,
          E.Status_CODE,
          E.Begin_DATE,
          E.End_DATE,
          E.Line1_ADDR AS Line1Ncp_ADDR,
          E.Line2_ADDR AS Line2Ncp_ADDR,
          E.City_ADDR AS CityNcp_ADDR,
          E.State_ADDR AS StateNcp_ADDR,
          LTRIM(RTRIM(REPLACE(ISNULL(E.Zip_ADDR, ''), '-', ''))) AS ZipNcpFull_ADDR,
          CASE LEN(LTRIM(RTRIM(REPLACE(ISNULL(E.Zip_ADDR, ''), '-', ''))))
           WHEN 5
            THEN LTRIM(RTRIM(E.Zip_ADDR)) + '0000'
           WHEN 9
            THEN LTRIM(RTRIM(REPLACE(ISNULL(E.Zip_ADDR, ''), '-', '')))
           ELSE '0'
          END AS ZipNcp_ADDR
     INTO #NcpAddrInfo_P1
     FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY D.Case_IDNO, D.ChildMCI_IDNO, D.MemberMci_IDNO ORDER BY D.Case_IDNO, D.ChildMCI_IDNO, D.MemberMci_IDNO, D.AddressHierarchyOrder_CODE ),
                  D.Case_IDNO,
                  D.ChildMCI_IDNO,
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
                          A.Case_IDNO,
                          A.ChildMCI_IDNO,
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
                             ELSE 7
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
                     FROM #DinsInfo_P1 A,
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
                      AND B.CaseRelationship_CODE = 'A'
                      AND B.CaseMemberStatus_CODE = 'A') D) E
    WHERE E.Row_NUMB = 1;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #CpEmplInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          B.MemberMci_IDNO AS CpMci_IDNO,
          ISNULL(C.OthpPartyEmpl_IDNO, 0) AS OthpPartyEmpl_IDNO,
          ISNULL(D.OtherParty_NAME, '') AS CpEmployer_NAME,
          ISNULL(D.Line1_ADDR, '') AS CpEmpLine1_ADDR,
          ISNULL(D.Line2_ADDR, '') AS CpEmpLine2_ADDR,
          ISNULL(D.City_ADDR, '') AS CpEmpCity_ADDR,
          ISNULL(D.State_ADDR, '') AS CpEmpState_ADDR,
          LTRIM(RTRIM(REPLACE(ISNULL(D.Zip_ADDR, ''), '-', ''))) AS CpEmpZipFull_ADDR
     INTO #CpEmplInfo_P1
     FROM #DinsInfo_P1 A,
          CMEM_Y1 B
          LEFT OUTER JOIN EHIS_Y1 C
           ON C.MemberMci_IDNO = B.MemberMci_IDNO
              AND C.EmployerPrime_INDC = 'Y'
              AND ((C.SourceLoc_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                    AND C.Status_CODE IN ('Y', 'P'))
                    OR (C.SourceLoc_CODE IN ('NDH', 'IRS', 'FID', 'FCR')
                        AND C.SourceLocConf_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                        AND C.Status_CODE = 'Y'))
              AND @Ld_Run_DATE BETWEEN C.BeginEmployment_DATE AND C.EndEmployment_DATE
          LEFT OUTER JOIN OTHP_Y1 D
           ON D.OtherParty_IDNO = C.OthpPartyEmpl_IDNO
              AND D.TypeOthp_CODE = 'E'
              AND D.EndValidity_DATE = @Ld_High_DATE
    WHERE B.Case_IDNO = A.Case_IDNO
      AND B.CaseRelationship_CODE = 'C'
      AND B.CaseMemberStatus_CODE = 'A';

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #NcpEmplInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          B.MemberMci_IDNO AS NcpMci_IDNO,
          ISNULL(C.OthpPartyEmpl_IDNO, 0) AS OthpPartyEmpl_IDNO,
          ISNULL(D.OtherParty_NAME, '') AS NcpEmployer_NAME,
          ISNULL(D.Line1_ADDR, '') AS NcpEmpLine1_ADDR,
          ISNULL(D.Line2_ADDR, '') AS NcpEmpLine2_ADDR,
          ISNULL(D.City_ADDR, '') AS NcpEmpCity_ADDR,
          ISNULL(D.State_ADDR, '') AS NcpEmpState_ADDR,
          LTRIM(RTRIM(REPLACE(ISNULL(D.Zip_ADDR, ''), '-', ''))) AS NcpEmpZipFull_ADDR
     INTO #NcpEmplInfo_P1
     FROM #DinsInfo_P1 A,
          CMEM_Y1 B
          LEFT OUTER JOIN EHIS_Y1 C
           ON C.MemberMci_IDNO = B.MemberMci_IDNO
              AND C.EmployerPrime_INDC = 'Y'
              AND ((C.SourceLoc_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                    AND C.Status_CODE IN ('Y', 'P'))
                    OR (C.SourceLoc_CODE IN ('NDH', 'IRS', 'FID', 'FCR')
                        AND C.SourceLocConf_CODE NOT IN ('NDH', 'IRS', 'FID', 'FCR')
                        AND C.Status_CODE = 'Y'))
              AND @Ld_Run_DATE BETWEEN C.BeginEmployment_DATE AND C.EndEmployment_DATE
          LEFT OUTER JOIN OTHP_Y1 D
           ON D.OtherParty_IDNO = C.OthpPartyEmpl_IDNO
              AND D.TypeOthp_CODE = 'E'
              AND D.EndValidity_DATE = @Ld_High_DATE
    WHERE B.Case_IDNO = A.Case_IDNO
      AND B.CaseRelationship_CODE = 'A'
      AND B.CaseMemberStatus_CODE = 'A';

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #PolicyInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          A.InsHolderMemberMci_IDNO,
          A.CaseRelationship_CODE,
          A.OthpInsurance_IDNO,
          A.PolicyInsNo_TEXT,
          A.InsuranceGroupNo_TEXT,
          ISNULL(B.Begin_DATE, '') AS Begin_DATE,
          ISNULL(B.End_DATE, '') AS End_DATE,
          ISNULL(C.OtherParty_NAME, '') AS InsCarrier_NAME
     INTO #PolicyInfo_P1
     FROM #DinsInfo_P1 A
          LEFT OUTER JOIN DINS_Y1 B
           ON B.MemberMci_IDNO = A.InsHolderMemberMci_IDNO
              AND B.ChildMCI_IDNO = A.ChildMCI_IDNO
              AND B.OthpInsurance_IDNO = A.OthpInsurance_IDNO
              AND B.PolicyInsNo_TEXT = A.PolicyInsNo_TEXT
              AND B.InsuranceGroupNo_TEXT = A.InsuranceGroupNo_TEXT
              AND @Ld_Run_DATE BETWEEN B.Begin_DATE AND B.End_DATE
              AND B.EndValidity_DATE = @Ld_High_DATE
              AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                                  FROM DINS_Y1 X
                                                 WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                                                   AND X.ChildMCI_IDNO = B.ChildMCI_IDNO
                                                   AND X.OthpInsurance_IDNO = B.OthpInsurance_IDNO
                                                   AND X.PolicyInsNo_TEXT = B.PolicyInsNo_TEXT
                                                   AND X.InsuranceGroupNo_TEXT = B.InsuranceGroupNo_TEXT
                                                   AND @Ld_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                                                   AND X.EndValidity_DATE = @Ld_High_DATE)
          LEFT OUTER JOIN OTHP_Y1 C
           ON C.OtherParty_IDNO = B.OthpInsurance_IDNO
              AND C.TypeOthp_CODE = 'I'
              AND C.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #InsHolderInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          A.InsHolderMemberMci_IDNO,
          A.OthpInsurance_IDNO,
          A.PolicyInsNo_TEXT,
          A.InsuranceGroupNo_TEXT,
          A.CaseRelationship_CODE,
          ISNULL(B.PolicyHolderRelationship_CODE, '') AS PolicyHolderRelationship_CODE,
          ISNULL(B.PolicyHolder_NAME, '') AS PolicyHolder_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(B.PolicyHolder_NAME, '')))) = 0
            THEN ''
           WHEN CHARINDEX(',', B.PolicyHolder_NAME) > 0
            THEN
            CASE
             WHEN CHARINDEX(' ', LEFT(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) - 1))) > 0
              THEN LTRIM(RTRIM(LEFT(B.PolicyHolder_NAME, CHARINDEX(' ', B.PolicyHolder_NAME))))
             ELSE LTRIM(RTRIM(LEFT(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) - 1))))
            END
           WHEN CHARINDEX(' ', B.PolicyHolder_NAME) > 0
            THEN LTRIM(RTRIM(LEFT(B.PolicyHolder_NAME, CHARINDEX(' ', B.PolicyHolder_NAME))))
           ELSE LTRIM(RTRIM(B.PolicyHolder_NAME))
          END AS PolicyHolderLast_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(B.PolicyHolder_NAME, '')))) = 0
            THEN ''
           WHEN CHARINDEX(',', B.PolicyHolder_NAME) > 0
            THEN
            CASE
             WHEN CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) > 0
              THEN LEFT(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME)))), CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) - 1)
             ELSE LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))
            END
           ELSE ''
          END AS PolicyHolderFirst_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(B.PolicyHolder_NAME, '')))) = 0
            THEN ''
           WHEN CHARINDEX(',', B.PolicyHolder_NAME) > 0
            THEN
            CASE
             WHEN CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) > 0
              THEN
              CASE
               WHEN CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME)))), (CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) + 1), LEN(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) - CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))))))) > 0
                THEN LEFT(LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME)))), (CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) + 1), LEN(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) - CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME)))))))), CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME)))), (CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) + 1), LEN(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) - CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))))))) - 1)
               ELSE LTRIM(RTRIM(SUBSTRING(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME)))), (CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) + 1), LEN(LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))) - CHARINDEX(' ', LTRIM(RTRIM(SUBSTRING(B.PolicyHolder_NAME, (CHARINDEX(',', B.PolicyHolder_NAME) + 1), LEN(B.PolicyHolder_NAME) - CHARINDEX(',', B.PolicyHolder_NAME))))))))
              END
             ELSE ''
            END
           ELSE ''
          END AS PolicyHolderMiddle_NAME,
          ISNULL(B.PolicyHolderSsn_NUMB, '0') AS PolicyHolderSsn_NUMB,
          ISNULL(B.BirthPolicyHolder_DATE, '') AS BirthPolicyHolder_DATE
     INTO #InsHolderInfo_P1
     FROM #DinsInfo_P1 A
          LEFT OUTER JOIN MINS_Y1 B
           ON B.MemberMci_IDNO = A.InsHolderMemberMci_IDNO
              AND B.OthpInsurance_IDNO = A.OthpInsurance_IDNO
              AND B.PolicyInsNo_TEXT = A.PolicyInsNo_TEXT
              AND B.InsuranceGroupNo_TEXT = A.InsuranceGroupNo_TEXT
              AND @Ld_Run_DATE BETWEEN B.Begin_DATE AND B.End_DATE
              AND B.EndValidity_DATE = @Ld_High_DATE
              AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                                  FROM MINS_Y1 X
                                                 WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                                                   AND X.OthpInsurance_IDNO = B.OthpInsurance_IDNO
                                                   AND X.PolicyInsNo_TEXT = B.PolicyInsNo_TEXT
                                                   AND X.InsuranceGroupNo_TEXT = B.InsuranceGroupNo_TEXT
                                                   AND @Ld_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                                                   AND X.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #InsHolderEmplInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          A.InsHolderMemberMci_IDNO,
          A.OthpInsurance_IDNO,
          A.PolicyInsNo_TEXT,
          A.InsuranceGroupNo_TEXT,
          A.CaseRelationship_CODE,
          ISNULL(B.OthpEmployer_IDNO, 0) AS OthpEmployer_IDNO,
          ISNULL(C.OtherParty_NAME, '') AS InsHolderEmployer_NAME,
          ISNULL(C.Line1_ADDR, '') AS InsHolderEmpLine1_ADDR,
          ISNULL(C.Line2_ADDR, '') AS InsHolderEmpLine2_ADDR,
          ISNULL(C.City_ADDR, '') AS InsHolderEmpCity_ADDR,
          ISNULL(C.State_ADDR, '') AS InsHolderEmpState_ADDR,
          LTRIM(RTRIM(REPLACE(ISNULL(C.Zip_ADDR, ''), '-', ''))) AS InsHolderEmpZipFull_ADDR
     INTO #InsHolderEmplInfo_P1
     FROM #DinsInfo_P1 A
          LEFT OUTER JOIN MINS_Y1 B
           ON B.MemberMci_IDNO = A.InsHolderMemberMci_IDNO
              AND B.OthpInsurance_IDNO = A.OthpInsurance_IDNO
              AND B.PolicyInsNo_TEXT = A.PolicyInsNo_TEXT
              AND B.InsuranceGroupNo_TEXT = A.InsuranceGroupNo_TEXT
              AND @Ld_Run_DATE BETWEEN B.Begin_DATE AND B.End_DATE
              AND B.EndValidity_DATE = @Ld_High_DATE
              AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                                  FROM MINS_Y1 X
                                                 WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                                                   AND X.OthpInsurance_IDNO = B.OthpInsurance_IDNO
                                                   AND X.PolicyInsNo_TEXT = B.PolicyInsNo_TEXT
                                                   AND X.InsuranceGroupNo_TEXT = B.InsuranceGroupNo_TEXT
                                                   AND @Ld_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                                                   AND X.EndValidity_DATE = @Ld_High_DATE)
          LEFT OUTER JOIN OTHP_Y1 C
           ON C.OtherParty_IDNO = B.OthpEmployer_IDNO
              AND C.TypeOthp_CODE = 'E'
              AND C.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #OtherInfo_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          A.Case_IDNO,
          A.ChildMCI_IDNO,
          ISNULL(CASE
                  WHEN B.TypeWelfare_CODE = 'A'
                   THEN ISNULL(B.CaseWelfare_IDNO, 0)
                  ELSE '0'
                 END, 0) AS CaseWelfare_IDNO,
          ISNULL(CASE
                  WHEN B.TypeWelfare_CODE = 'F'
                   THEN ISNULL(B.CaseWelfare_IDNO, 0)
                  ELSE '0'
                 END, 0) AS IveCase_IDNO,
          ISNULL(CASE
                  WHEN B.TypeWelfare_CODE = 'M'
                   THEN ISNULL(B.CaseWelfare_IDNO, 0)
                  ELSE '0'
                 END, 0) AS XixCase_IDNO,
          ISNULL(CASE
                  WHEN B.TypeWelfare_CODE = 'M'
                   THEN (SELECT SUM(ISNULL(E.Disburse_AMNT, 0))
                           FROM OBLE_Y1 C,
                                SORD_Y1 D,
                                DSBL_Y1 E
                          WHERE C.Case_IDNO = B.Case_IDNO
                            AND C.MemberMci_IDNO = B.MemberMci_IDNO
                            AND C.TypeDebt_CODE = 'MS'
                            AND C.EndValidity_DATE = @Ld_High_DATE
                            AND D.Case_IDNO = C.Case_IDNO
                            AND D.OrderSeq_NUMB = C.OrderSeq_NUMB
                            AND D.EndValidity_DATE = @Ld_High_DATE
                            AND E.Case_IDNO = C.Case_IDNO
                            AND E.OrderSeq_NUMB = C.OrderSeq_NUMB
                            AND E.ObligationSeq_NUMB = C.ObligationSeq_NUMB
                            AND E.TypeDisburse_CODE IN ('CZNAA', 'AZNAA'))
                  ELSE '0'
                 END, 0) AS Disburse_AMNT,
          ISNULL(CASE
                  WHEN B.TypeWelfare_CODE = 'M'
                   THEN (SELECT MAX(ISNULL(E.Disburse_DATE, ' '))
                           FROM OBLE_Y1 C,
                                SORD_Y1 D,
                                DSBL_Y1 E
                          WHERE C.Case_IDNO = B.Case_IDNO
                            AND C.MemberMci_IDNO = B.MemberMci_IDNO
                            AND C.TypeDebt_CODE = 'MS'
                            AND C.EndValidity_DATE = @Ld_High_DATE
                            AND D.Case_IDNO = C.Case_IDNO
                            AND D.OrderSeq_NUMB = C.OrderSeq_NUMB
                            AND D.EndValidity_DATE = @Ld_High_DATE
                            AND E.Case_IDNO = C.Case_IDNO
                            AND E.OrderSeq_NUMB = C.OrderSeq_NUMB
                            AND E.ObligationSeq_NUMB = C.ObligationSeq_NUMB
                            AND E.TypeDisburse_CODE IN ('CZNAA', 'AZNAA'))
                  ELSE ' '
                 END, ' ') AS Payment_DATE
     INTO #OtherInfo_P1
     FROM #DinsInfo_P1 A,
          MHIS_Y1 B
    WHERE B.MemberMci_IDNO = A.ChildMCI_IDNO
      AND B.Case_IDNO = A.Case_IDNO
      AND @Ld_Run_DATE BETWEEN B.Start_DATE AND B.End_DATE;

   SET @Ls_Sql_TEXT = 'CREATING AND INSERTING INTO #EnfOutgoingMedicaidTpl_P1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT DISTINCT
          DinsInfo.Case_IDNO,
          DinsInfo.ChildMCI_IDNO,
          DinsInfo.InsHolderMemberMci_IDNO,
          DinsInfo.CaseRelationship_CODE,
          DinsInfo.OthpInsurance_IDNO,
          'LD' AS TypeRecord_CODE,
          ChildDemoInfo.InsuredMemberMci_IDNO,
          ChildDemoInfo.LastInsured_NAME,
          ChildDemoInfo.FirstInsured_NAME,
          ChildDemoInfo.MiddleInsured_NAME,
          ChildDemoInfo.SuffixInsured_NAME,
          ChildDemoInfo.InsuredMemberSsn_NUMB,
          ChildDemoInfo.BirthInsured_DATE,
          ChildDemoInfo.InsuredMemberSex_CODE,
          CpAddrInfo.Line1Cp_ADDR,
          CpAddrInfo.Line2Cp_ADDR,
          CpAddrInfo.CityCp_ADDR,
          CpAddrInfo.StateCp_ADDR,
          CpAddrInfo.ZipCp_ADDR,
          PolicyInfo.PolicyInsNo_TEXT,
          PolicyInfo.InsuranceGroupNo_TEXT,
          ' ' AS Coverage_CODE,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpNcpDemoInfo.LastCp_NAME
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN CpNcpDemoInfo.LastNcp_NAME
            END
           ELSE InsHolderInfo.PolicyHolderLast_NAME
          END AS InsHolderLast_NAME,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpNcpDemoInfo.FirstCp_NAME
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN CpNcpDemoInfo.FirstNcp_NAME
            END
           ELSE InsHolderInfo.PolicyHolderFirst_NAME
          END AS InsHolderFirst_NAME,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpNcpDemoInfo.MiddleCp_NAME
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN CpNcpDemoInfo.MiddleNcp_NAME
            END
           ELSE
            CASE
             WHEN LEN(LTRIM(RTRIM(InsHolderInfo.PolicyHolderMiddle_NAME))) > 0
              THEN LEFT(LTRIM(RTRIM(InsHolderInfo.PolicyHolderMiddle_NAME)), 1)
             ELSE ' '
            END
          END AS InsHolderMiddle_NAME,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN '0'
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpNcpDemoInfo.CpSsn_NUMB
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN CpNcpDemoInfo.NcpSsn_NUMB
            END
           ELSE InsHolderInfo.PolicyHolderSsn_NUMB
          END AS InsHolderMemberSsn_NUMB,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpAddrInfo.Line1Cp_ADDR
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN NcpAddrInfo.Line1Ncp_ADDR
            END
           ELSE ' '
          END AS InsHolderLine1_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpAddrInfo.Line2Cp_ADDR
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN NcpAddrInfo.Line2Ncp_ADDR
            END
           ELSE ' '
          END AS InsHolderLine2_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpAddrInfo.CityCp_ADDR
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN NcpAddrInfo.CityNcp_ADDR
            END
           ELSE ' '
          END AS InsHolderCity_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpAddrInfo.StateCp_ADDR
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN NcpAddrInfo.StateNcp_ADDR
            END
           ELSE ' '
          END AS InsHolderState_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN '0'
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpAddrInfo.ZipCp_ADDR
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN NcpAddrInfo.ZipNcp_ADDR
            END
           ELSE '0'
          END AS InsHolderZip_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ''
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpNcpDemoInfo.BirthCp_DATE
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN CpNcpDemoInfo.BirthNcp_DATE
            END
           ELSE InsHolderInfo.BirthPolicyHolder_DATE
          END AS InsHolderBirth_DATE,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN LEN(LTRIM(RTRIM(ISNULL(DinsInfo.CaseRelationship_CODE, '')))) = 0
              THEN ' '
             WHEN DinsInfo.CaseRelationship_CODE = 'C'
              THEN CpNcpDemoInfo.CpSex_CODE
             WHEN DinsInfo.CaseRelationship_CODE = 'A'
              THEN CpNcpDemoInfo.NcpSex_CODE
            END
           ELSE ' '
          END AS InsHolderSex_CODE,
          PolicyInfo.Begin_DATE,
          PolicyInfo.End_DATE,
          'C' AS Origin_CODE,
          'A' AS StatusRecord_CODE,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE InsHolderEmplInfo.InsHolderEmployer_NAME
            END
           ELSE ' '
          END AS InsHolderEmployer_NAME,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE InsHolderEmplInfo.InsHolderEmpLine1_ADDR
            END
           ELSE ' '
          END AS InsHolderEmpLine1_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE InsHolderEmplInfo.InsHolderEmpLine2_ADDR
            END
           ELSE ' '
          END AS InsHolderEmpLine2_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE InsHolderEmplInfo.InsHolderEmpCity_ADDR
            END
           ELSE ' '
          END AS InsHolderEmpCity_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE InsHolderEmplInfo.InsHolderEmpState_ADDR
            END
           ELSE ' '
          END AS InsHolderEmpState_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE InsHolderEmplInfo.InsHolderEmpZipFull_ADDR
            END
           ELSE '0'
          END AS InsHolderEmpZipFull_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE
              CASE LEN(LTRIM(RTRIM(ISNULL(InsHolderEmplInfo.InsHolderEmpZipFull_ADDR, ''))))
               WHEN 0
                THEN '0'
               ELSE SUBSTRING(LTRIM(RTRIM(InsHolderEmplInfo.InsHolderEmpZipFull_ADDR)), 1, 5)
              END
            END
           ELSE '0'
          END AS InsHolderEmpZip_ADDR,
          CASE
           WHEN LTRIM(RTRIM(ISNULL(DinsInfo.PolicyHolderRelationship_CODE, ''))) <> 'OT'
            THEN
            CASE
             WHEN InsHolderEmplInfo.OthpEmployer_IDNO <= 0
              THEN ' '
             ELSE
              CASE LEN(LTRIM(RTRIM(ISNULL(InsHolderEmplInfo.InsHolderEmpZipFull_ADDR, ''))))
               WHEN 9
                THEN SUBSTRING(LTRIM(RTRIM(InsHolderEmplInfo.InsHolderEmpZipFull_ADDR)), 6, 4)
               ELSE '0'
              END
            END
           ELSE '0'
          END AS InsHolderEmpZipSuffix_ADDR,
          PolicyInfo.InsCarrier_NAME,
          CpNcpDemoInfo.LastCp_NAME,
          CpNcpDemoInfo.FirstCp_NAME,
          CpNcpDemoInfo.MiddleCp_NAME,
          CpNcpDemoInfo.CpSsn_NUMB,
          CpNcpDemoInfo.BirthCp_DATE,
          CpNcpDemoInfo.CpSex_CODE,
          CpEmplInfo.CpEmployer_NAME,
          CpEmplInfo.CpEmpLine1_ADDR,
          CpEmplInfo.CpEmpLine2_ADDR,
          CpEmplInfo.CpEmpCity_ADDR,
          CpEmplInfo.CpEmpState_ADDR,
          CpEmplInfo.CpEmpZipFull_ADDR,
          CASE LEN(LTRIM(RTRIM(ISNULL(CpEmplInfo.CpEmpZipFull_ADDR, ''))))
           WHEN 0
            THEN '0'
           ELSE SUBSTRING(LTRIM(RTRIM(CpEmplInfo.CpEmpZipFull_ADDR)), 1, 5)
          END AS CpEmpZip_ADDR,
          CASE LEN(LTRIM(RTRIM(ISNULL(CpEmplInfo.CpEmpZipFull_ADDR, ''))))
           WHEN 9
            THEN SUBSTRING(LTRIM(RTRIM(CpEmplInfo.CpEmpZipFull_ADDR)), 6, 4)
           ELSE '0'
          END AS CpEmpZipSuffix_ADDR,
          CpNcpDemoInfo.LastNcp_NAME,
          CpNcpDemoInfo.FirstNcp_NAME,
          CpNcpDemoInfo.MiddleNcp_NAME,
          CpNcpDemoInfo.NcpSsn_NUMB,
          NcpAddrInfo.Line1Ncp_ADDR,
          NcpAddrInfo.Line2Ncp_ADDR,
          NcpAddrInfo.CityNcp_ADDR,
          NcpAddrInfo.StateNcp_ADDR,
          NcpAddrInfo.ZipNcp_ADDR,
          NcpEmplInfo.NcpEmployer_NAME,
          NcpEmplInfo.NcpEmpLine1_ADDR,
          NcpEmplInfo.NcpEmpLine2_ADDR,
          NcpEmplInfo.NcpEmpCity_ADDR,
          NcpEmplInfo.NcpEmpState_ADDR,
          NcpEmplInfo.NcpEmpZipFull_ADDR,
          CASE LEN(LTRIM(RTRIM(ISNULL(NcpEmplInfo.NcpEmpZipFull_ADDR, ''))))
           WHEN 0
            THEN '0'
           ELSE SUBSTRING(LTRIM(RTRIM(NcpEmplInfo.NcpEmpZipFull_ADDR)), 1, 5)
          END AS NcpEmpZip_ADDR,
          CASE LEN(LTRIM(RTRIM(ISNULL(NcpEmplInfo.NcpEmpZipFull_ADDR, ''))))
           WHEN 9
            THEN SUBSTRING(LTRIM(RTRIM(NcpEmplInfo.NcpEmpZipFull_ADDR)), 6, 4)
           ELSE '0'
          END AS NcpEmpZipSuffix_ADDR,
          OtherInfo.CaseWelfare_IDNO,
          OtherInfo.IveCase_IDNO,
          OtherInfo.XixCase_IDNO,
          'N' AS NonCooperation_INDC,
          CASE
           WHEN OtherInfo.Disburse_AMNT > 0
            THEN 'Y'
           ELSE 'N'
          END AS Payment_INDC,
          OtherInfo.Disburse_AMNT,
          OtherInfo.Payment_DATE
     INTO #EnfOutgoingMedicaidTpl_P1
     FROM #DinsInfo_P1 DinsInfo,
          #ChildDemoInfo_P1 ChildDemoInfo,
          #CpNcpDemoInfo_P1 CpNcpDemoInfo,
          #CpAddrInfo_P1 CpAddrInfo,
          #NcpAddrInfo_P1 NcpAddrInfo,
          #CpEmplInfo_P1 CpEmplInfo,
          #NcpEmplInfo_P1 NcpEmplInfo,
          #PolicyInfo_P1 PolicyInfo,
          #InsHolderInfo_P1 InsHolderInfo,
          #InsHolderEmplInfo_P1 InsHolderEmplInfo,
          #OtherInfo_P1 OtherInfo
    WHERE ChildDemoInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND ChildDemoInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND CpNcpDemoInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND CpNcpDemoInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND CpAddrInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND CpAddrInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND NcpAddrInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND NcpAddrInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND CpEmplInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND CpEmplInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND NcpEmplInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND NcpEmplInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND PolicyInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND PolicyInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND PolicyInfo.InsHolderMemberMci_IDNO = DinsInfo.InsHolderMemberMci_IDNO
      AND PolicyInfo.OthpInsurance_IDNO = DinsInfo.OthpInsurance_IDNO
      AND PolicyInfo.PolicyInsNo_TEXT = DinsInfo.PolicyInsNo_TEXT
      AND PolicyInfo.InsuranceGroupNo_TEXT = DinsInfo.InsuranceGroupNo_TEXT
      AND InsHolderInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND InsHolderInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND InsHolderInfo.InsHolderMemberMci_IDNO = DinsInfo.InsHolderMemberMci_IDNO
      AND InsHolderInfo.OthpInsurance_IDNO = DinsInfo.OthpInsurance_IDNO
      AND InsHolderInfo.PolicyInsNo_TEXT = DinsInfo.PolicyInsNo_TEXT
      AND InsHolderInfo.InsuranceGroupNo_TEXT = DinsInfo.InsuranceGroupNo_TEXT
      AND InsHolderEmplInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND InsHolderEmplInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO
      AND InsHolderEmplInfo.InsHolderMemberMci_IDNO = DinsInfo.InsHolderMemberMci_IDNO
      AND InsHolderEmplInfo.OthpInsurance_IDNO = DinsInfo.OthpInsurance_IDNO
      AND InsHolderEmplInfo.PolicyInsNo_TEXT = DinsInfo.PolicyInsNo_TEXT
      AND InsHolderEmplInfo.InsuranceGroupNo_TEXT = DinsInfo.InsuranceGroupNo_TEXT
      AND OtherInfo.Case_IDNO = DinsInfo.Case_IDNO
      AND OtherInfo.ChildMCI_IDNO = DinsInfo.ChildMCI_IDNO;

   SET @Ls_Sql_TEXT = 'INSERTING EXTRACT DATA INTO EMTPL_Y1 TABLE';
   SET @Ls_Sqldata_TEXT =' Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO EMTPL_Y1
               (TypeRecord_CODE,
                InsuredMemberMci_IDNO,
                LastInsured_NAME,
                FirstInsured_NAME,
                MiddleInsured_NAME,
                SuffixInsured_NAME,
                InsuredMemberSsn_NUMB,
                BirthInsured_DATE,
                InsuredMemberSex_CODE,
                Line1Cp_ADDR,
                Line2Cp_ADDR,
                CityCp_ADDR,
                StateCp_ADDR,
                ZipCp_ADDR,
                PolicyInsNo_TEXT,
                InsuranceGroupNo_TEXT,
                Coverage_CODE,
                InsHolderLast_NAME,
                InsHolderFirst_NAME,
                InsHolderMiddle_NAME,
                InsHolderMemberSsn_NUMB,
                InsHolderLine1_ADDR,
                InsHolderLine2_ADDR,
                InsHolderCity_ADDR,
                InsHolderState_ADDR,
                InsHolderZip_ADDR,
                InsHolderBirth_DATE,
                InsHolderSex_CODE,
                Begin_DATE,
                End_DATE,
                Origin_CODE,
                StatusRecord_CODE,
                InsHolderEmployer_NAME,
                InsHolderEmpLine1_ADDR,
                InsHolderEmpLine2_ADDR,
                InsHolderEmpCity_ADDR,
                InsHolderEmpState_ADDR,
                InsHolderEmpZip_ADDR,
                InsHolderEmpZipSuffix_ADDR,
                InsCarrier_NAME,
                LastCp_NAME,
                FirstCp_NAME,
                MiddleCp_NAME,
                CpSsn_NUMB,
                BirthCp_DATE,
                CpSex_CODE,
                CpEmployer_NAME,
                CpEmpLine1_ADDR,
                CpEmpLine2_ADDR,
                CpEmpCity_ADDR,
                CpEmpState_ADDR,
                CpEmpZip_ADDR,
                CpEmpZipSuffix_ADDR,
                LastNcp_NAME,
                FirstNcp_NAME,
                MiddleNcp_NAME,
                NcpSsn_NUMB,
                Line1Ncp_ADDR,
                Line2Ncp_ADDR,
                CityNcp_ADDR,
                StateNcp_ADDR,
                ZipNcp_ADDR,
                NcpEmployer_NAME,
                NcpEmpLine1_ADDR,
                NcpEmpLine2_ADDR,
                NcpEmpCity_ADDR,
                NcpEmpState_ADDR,
                NcpEmpZip_ADDR,
                NcpEmpZipSuffix_ADDR,
                CaseWelfare_IDNO,
                IveCase_IDNO,
                XixCase_IDNO,
                NonCooperation_INDC,
                Payment_INDC,
                Disburse_AMNT,
                Payment_DATE)
   SELECT DISTINCT
          A.TypeRecord_CODE,
          RIGHT(('0000000000' + LTRIM(RTRIM(A.InsuredMemberMci_IDNO))), 10) AS InsuredMemberMci_IDNO,
          CONVERT(CHAR(30), A.LastInsured_NAME) AS LastInsured_NAME,
          CONVERT(CHAR(20), A.FirstInsured_NAME) AS FirstInsured_NAME,
          CONVERT(CHAR(1), A.MiddleInsured_NAME) AS MiddleInsured_NAME,
          CONVERT(CHAR(4), A.SuffixInsured_NAME) AS SuffixInsured_NAME,
          RIGHT(('000000000' + LTRIM(RTRIM(A.InsuredMemberSsn_NUMB))), 9) AS InsuredMemberSsn_NUMB,
          ISNULL(CONVERT(VARCHAR(8), A.BirthInsured_DATE, 112), REPLICATE(@Lc_Space_TEXT, 8)) AS BirthInsured_DATE,
          CONVERT(CHAR(1), A.InsuredMemberSex_CODE) AS InsuredMemberSex_CODE,
          CONVERT(CHAR(25), A.Line1Cp_ADDR) AS Line1Cp_ADDR,
          CONVERT(CHAR(25), A.Line2Cp_ADDR) AS Line2Cp_ADDR,
          CONVERT(CHAR(20), A.CityCp_ADDR) AS CityCp_ADDR,
          CONVERT(CHAR(2), A.StateCp_ADDR) AS StateCp_ADDR,
          CONVERT(CHAR(9), A.ZipCp_ADDR) AS ZipCp_ADDR,
          CONVERT(CHAR(18), A.PolicyInsNo_TEXT) AS PolicyInsNo_TEXT,
          CONVERT(CHAR(17), A.InsuranceGroupNo_TEXT) AS InsuranceGroupNo_TEXT,
          CONVERT(CHAR(3), A.Coverage_CODE) AS Coverage_CODE,
          CONVERT(CHAR(30), A.InsHolderLast_NAME) AS InsHolderLast_NAME,
          CONVERT(CHAR(20), A.InsHolderFirst_NAME) AS InsHolderFirst_NAME,
          CONVERT(CHAR(1), A.InsHolderMiddle_NAME) AS InsHolderMiddle_NAME,
          RIGHT(('000000000' + LTRIM(RTRIM(A.InsHolderMemberSsn_NUMB))), 9) AS InsHolderMemberSsn_NUMB,
          CONVERT(CHAR(25), A.InsHolderLine1_ADDR) AS InsHolderLine1_ADDR,
          CONVERT(CHAR(25), A.InsHolderLine2_ADDR) AS InsHolderLine2_ADDR,
          CONVERT(CHAR(20), A.InsHolderCity_ADDR) AS InsHolderCity_ADDR,
          CONVERT(CHAR(2), A.InsHolderState_ADDR) AS InsHolderState_ADDR,
          RIGHT(('000000000' + LTRIM(RTRIM(A.InsHolderZip_ADDR))), 9) AS InsHolderZip_ADDR,
          (CASE
            WHEN LTRIM(RTRIM(A.InsHolderBirth_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
             THEN REPLICATE(@Lc_Space_TEXT, 8)
            ELSE ISNULL(CONVERT(VARCHAR(8), A.InsHolderBirth_DATE, 112), REPLICATE(@Lc_Space_TEXT, 8))
           END) AS InsHolderBirth_DATE,
          CONVERT(CHAR(25), A.InsHolderSex_CODE) AS InsHolderSex_CODE,
          (CASE
            WHEN LTRIM(RTRIM(A.Begin_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
             THEN REPLICATE(@Lc_Space_TEXT, 8)
            ELSE ISNULL(CONVERT(VARCHAR(8), A.Begin_DATE, 112), REPLICATE(@Lc_Space_TEXT, 8))
           END) AS Begin_DATE,
          (CASE
            WHEN LTRIM(RTRIM(A.End_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
             THEN REPLICATE(@Lc_Space_TEXT, 8)
            ELSE ISNULL(CONVERT(VARCHAR(8), A.End_DATE, 112), REPLICATE(@Lc_Space_TEXT, 8))
           END) AS End_DATE,
          A.Origin_CODE,
          A.StatusRecord_CODE,
          CONVERT(CHAR(25), A.InsHolderEmployer_NAME) AS InsHolderEmployer_NAME,
          CONVERT(CHAR(25), A.InsHolderEmpLine1_ADDR) AS InsHolderEmpLine1_ADDR,
          CONVERT(CHAR(25), A.InsHolderEmpLine2_ADDR) AS InsHolderEmpLine2_ADDR,
          CONVERT(CHAR(20), A.InsHolderEmpCity_ADDR) AS InsHolderEmpCity_ADDR,
          CONVERT(CHAR(2), A.InsHolderEmpState_ADDR) AS InsHolderEmpState_ADDR,
          RIGHT(('00000' + LTRIM(RTRIM(A.InsHolderEmpZip_ADDR))), 5) AS InsHolderEmpZip_ADDR,
          RIGHT(('0000' + LTRIM(RTRIM(A.InsHolderEmpZipSuffix_ADDR))), 4) AS InsHolderEmpZipSuffix_ADDR,
          CONVERT(CHAR(45), A.InsCarrier_NAME) AS InsCarrier_NAME,
          CONVERT(CHAR(30), A.LastCp_NAME) AS LastCp_NAME,
          CONVERT(CHAR(20), A.FirstCp_NAME) AS FirstCp_NAME,
          CONVERT(CHAR(1), A.MiddleCp_NAME) AS MiddleCp_NAME,
          RIGHT(('000000000' + LTRIM(RTRIM(A.CpSsn_NUMB))), 9) AS CpSsn_NUMB,
          ISNULL(CONVERT(VARCHAR(8), A.BirthCp_DATE, 112), REPLICATE(@Lc_Space_TEXT, 8)) AS BirthCp_DATE,
          CONVERT(CHAR(1), A.CpSex_CODE) AS CpSex_CODE,
          CONVERT(CHAR(25), A.CpEmployer_NAME) AS CpEmployer_NAME,
          CONVERT(CHAR(25), A.CpEmpLine1_ADDR) AS CpEmpLine1_ADDR,
          CONVERT(CHAR(25), A.CpEmpLine2_ADDR) AS CpEmpLine2_ADDR,
          CONVERT(CHAR(20), A.CpEmpCity_ADDR) AS CpEmpCity_ADDR,
          CONVERT(CHAR(2), A.CpEmpState_ADDR) AS CpEmpState_ADDR,
          RIGHT(('00000' + LTRIM(RTRIM(A.CpEmpZip_ADDR))), 5) AS CpEmpZip_ADDR,
          RIGHT(('0000' + LTRIM(RTRIM(A.CpEmpZipSuffix_ADDR))), 4) AS CpEmpZipSuffix_ADDR,
          CONVERT(CHAR(30), A.LastNcp_NAME) AS LastNcp_NAME,
          CONVERT(CHAR(20), A.FirstNcp_NAME) AS FirstNcp_NAME,
          CONVERT(CHAR(1), A.MiddleNcp_NAME) AS MiddleNcp_NAME,
          RIGHT(('000000000' + LTRIM(RTRIM(A.NcpSsn_NUMB))), 9) AS NcpSsn_NUMB,
          CONVERT(CHAR(25), A.Line1Ncp_ADDR) AS Line1Ncp_ADDR,
          CONVERT(CHAR(25), A.Line2Ncp_ADDR) AS Line2Ncp_ADDR,
          CONVERT(CHAR(20), A.CityNcp_ADDR) AS CityNcp_ADDR,
          CONVERT(CHAR(2), A.StateNcp_ADDR) AS StateNcp_ADDR,
          RIGHT(('000000000' + LTRIM(RTRIM(A.ZipNcp_ADDR))), 9) AS ZipNcp_ADDR,
          CONVERT(CHAR(25), A.NcpEmployer_NAME) AS NcpEmployer_NAME,
          CONVERT(CHAR(25), A.NcpEmpLine1_ADDR) AS NcpEmpLine1_ADDR,
          CONVERT(CHAR(25), A.NcpEmpLine2_ADDR) AS NcpEmpLine2_ADDR,
          CONVERT(CHAR(20), A.NcpEmpCity_ADDR) AS NcpEmpCity_ADDR,
          CONVERT(CHAR(2), A.NcpEmpState_ADDR) AS NcpEmpState_ADDR,
          RIGHT(('00000' + LTRIM(RTRIM(A.NcpEmpZip_ADDR))), 5) AS NcpEmpZip_ADDR,
          RIGHT(('0000' + LTRIM(RTRIM(A.NcpEmpZipSuffix_ADDR))), 4) AS NcpEmpZipSuffix_ADDR,
          RIGHT(('0000000000' + LTRIM(RTRIM(A.CaseWelfare_IDNO))), 10) AS CaseWelfare_IDNO,
          RIGHT(('0000000000' + LTRIM(RTRIM(A.IveCase_IDNO))), 10) AS IveCase_IDNO,
          RIGHT(('0000000000' + LTRIM(RTRIM(A.XixCase_IDNO))), 10) AS XixCase_IDNO,
          NonCooperation_INDC,
          Payment_INDC,
          RIGHT(('00000000000' + LTRIM(RTRIM(A.Disburse_AMNT))), 10) AS Disburse_AMNT,
          (CASE
            WHEN LTRIM(RTRIM(Payment_DATE)) IN (@Ld_Low_DATE, '1900-01-01')
             THEN REPLICATE(@Lc_Space_TEXT, 8)
            ELSE ISNULL(CONVERT(VARCHAR(8), A.Payment_DATE, 112), REPLICATE(@Lc_Space_TEXT, 8))
           END) AS Payment_DATE
     FROM #EnfOutgoingMedicaidTpl_P1 A
    ORDER BY 2;

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'BateError_TEXT = ' + @Ls_BateError_TEXT;

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
       RAISERROR (50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'INSERT ##ExtractTpl_P1';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractTpl_P1
               (Record_TEXT)
   SELECT 'HD' + CONVERT(CHAR(50), 'TPL LEAD HEADER FROM CHILD SUPPORT') + CONVERT(CHAR(8), 'TPXP600') + CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 1332)
   UNION ALL
   SELECT A.TypeRecord_CODE + A.InsuredMemberMci_IDNO + A.LastInsured_NAME + A.FirstInsured_NAME + A.MiddleInsured_NAME + A.SuffixInsured_NAME + REPLICATE(@Lc_Space_TEXT, 12) + A.InsuredMemberSsn_NUMB + A.BirthInsured_DATE + A.InsuredMemberSex_CODE + A.Line1Cp_ADDR + A.Line2Cp_ADDR + A.CityCp_ADDR + A.StateCp_ADDR + A.ZipCp_ADDR + REPLICATE(@Lc_Space_TEXT, 11) + A.PolicyInsNo_TEXT + A.InsuranceGroupNo_TEXT + A.Coverage_CODE + REPLICATE(@Lc_Space_TEXT, 140) + A.InsHolderLast_NAME + A.InsHolderFirst_NAME + A.InsHolderMiddle_NAME + A.InsHolderMemberSsn_NUMB + A.InsHolderLine1_ADDR + A.InsHolderLine2_ADDR + A.InsHolderCity_ADDR + A.InsHolderState_ADDR + A.InsHolderZip_ADDR + A.InsHolderBirth_DATE + A.InsHolderSex_CODE + A.Begin_DATE + A.End_DATE + REPLICATE(@Lc_Space_TEXT, 55) + A.Origin_CODE + REPLICATE(@Lc_Space_TEXT, 9) + A.StatusRecord_CODE + A.InsHolderEmployer_NAME + REPLICATE(@Lc_Space_TEXT, 7) + A.InsHolderEmpLine1_ADDR + A.InsHolderEmpLine2_ADDR + A.InsHolderEmpCity_ADDR + A.InsHolderEmpState_ADDR + A.InsHolderEmpZip_ADDR + A.InsHolderEmpZipSuffix_ADDR + REPLICATE(@Lc_Space_TEXT, 11) + A.InsCarrier_NAME + REPLICATE(@Lc_Space_TEXT, 116) + A.LastCp_NAME + A.FirstCp_NAME + A.MiddleCp_NAME + A.CpSsn_NUMB + A.BirthCp_DATE + A.CpSex_CODE + A.CpEmployer_NAME + A.CpEmpLine1_ADDR + A.CpEmpLine2_ADDR + A.CpEmpCity_ADDR + A.CpEmpState_ADDR + A.CpEmpZip_ADDR + A.CpEmpZipSuffix_ADDR + A.LastNcp_NAME + A.FirstNcp_NAME + A.MiddleNcp_NAME + A.NcpSsn_NUMB + A.Line1Ncp_ADDR + A.Line2Ncp_ADDR + A.CityNcp_ADDR + A.StateNcp_ADDR + A.ZipNcp_ADDR + A.NcpEmployer_NAME + A.NcpEmpLine1_ADDR + A.NcpEmpLine2_ADDR + A.NcpEmpCity_ADDR + A.NcpEmpState_ADDR + A.NcpEmpZip_ADDR + A.NcpEmpZipSuffix_ADDR + A.CaseWelfare_IDNO + A.IveCase_IDNO + A.XixCase_IDNO + A.NonCooperation_INDC + A.Payment_INDC + A.Disburse_AMNT + A.Payment_DATE + REPLICATE(@Lc_Space_TEXT, 43)
     FROM EMTPL_Y1 A
   UNION ALL
   SELECT 'TR' + CONVERT(CHAR(50), 'TPL LEAD TRAILER FROM CHILD SUPPORT') + RIGHT(('00000000' + LTRIM(RTRIM((@Ln_ProcessedRecordCount_QNTY + 2)))), 8) + REPLICATE(@Lc_Space_TEXT, 1340);

   COMMIT TRANSACTION OUTGOING_MEDICAID_TPL;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractTpl_P1 ORDER BY LEFT(Record_TEXT, 2) ASC';
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
     RAISERROR (50001,16,1);
    END;

   BEGIN TRANSACTION OUTGOING_MEDICAID_TPL;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job Id = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
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

   COMMIT TRANSACTION OUTGOING_MEDICAID_TPL;

   DROP TABLE ##ExtractTpl_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_MEDICAID_TPL;
    END;

   IF OBJECT_ID('tempdb..##ExtractTpl_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractTpl_P1;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
