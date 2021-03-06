/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIMEMBER]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIMEMBER
Programmer Name	:	IMP Team.
Description		:	This process loads member details for all cases.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIMEMBER]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_DaysInyear_NUMB                  NUMERIC(6, 2) = 365.25,
          @Li_RowCount_QNTY                    INT = 0,
          @Lc_StatusCaseMemberActive_CODE      CHAR(1) = 'A',
          @Lc_Space_TEXT                       CHAR(1) = ' ',
          @Lc_RelationshipCaseDp_TEXT          CHAR(1) = 'D',
          @Lc_SsnTypePrimary_CODE              CHAR(1) = 'P',
          @Lc_DisburseMediumDirectDeposit_TEXT CHAR(1) = 'D',
          @Lc_RecipientTypeCpNcp_CODE          CHAR(1) = '1',
          @Lc_DisbursementSvc_TEXT             CHAR(1) = 'B',
          @Lc_Yes_TEXT                         CHAR(1) = 'Y',
          @Lc_No_TEXT                          CHAR(1) = 'N',
          @Lc_One_TEXT                         CHAR(1) = '1',
          @Lc_Two_TEXT                         CHAR(1) = '2',
          @Lc_Three_TEXT                       CHAR(1) = '3',
          @Lc_Four_TEXT                        CHAR(1) = '4',
          @Lc_TypeError_CODE                   CHAR(1) = 'E',
          @Lc_RelationshipCaseNcp_TEXT         CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT   CHAR(1) = 'P',
          @Lc_CaseStatusOpen_CODE              CHAR(1) = 'O',
          @Lc_StatusCaseMemberInactive_CODE    CHAR(1) = 'I',
          @Lc_ChildOrdStatEmancipated_TEXT     CHAR(1) = 'E',
          @Lc_ChildOrdStatNonCourt_TEXT        CHAR(1) = 'N',
          @Lc_ChildOrdStatCourt_TEXT           CHAR(1) = 'C',
          @Lc_ResultExcluded_TEXT              CHAR(1) = 'X',
          @Lc_SystemExclusion_TEXT             CHAR(1) = 'S',
          @Lc_Success_CODE                     CHAR(1) = 'S',
          @Lc_Failed_CODE                      CHAR(1) = 'F',
          @Lc_DateFormatDd_TEXT                CHAR(2) = 'DD',
          @Lc_RevrsnInsufficientfunds_TEXT     CHAR(2) = 'NF',
          @Lc_BateError_CODE                   CHAR(5) = 'E0944',
          @Lc_Job_ID                           CHAR(7) = 'DEB0836',
          @Lc_Process_NAME                     CHAR(14) = 'BATCH_BI_MAPCM',
          @Lc_Procedure_NAME                   CHAR(19) = 'SP_PROCESS_BIMEMBER',
          @Ld_Highdate_DATE                    DATE = '12/31/9999',
          @Ld_Lowdate_DATE                     DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ls_Sql_TEXT = 'DELETE FROM BPMEMB_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPMEMB_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPMEMB_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPMEMB_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           CaseRelationship_CODE,
           CaseMemberStatus_CODE,
           PaternityEst_CODE,
           StatusLocate_CODE,
           StatusChildOrder_CODE,
           MediumDisburse_CODE,
           Birth_DATE,
           Age_QNTY,
           NcpNsfBalance_AMNT,
           BornOfMarriage_INDC,
           FamilyViolenceIndc_CODE,
           NcpNsf_CODE,
           Ssn_CODE,
           ExcludeIrs_CODE,
           ExcludePas_CODE,
           ExcludeFin_CODE,
           ExcludeIns_CODE,
           ExcludeVen_CODE,
           ExcludeRet_CODE,
           ExcludeSal_CODE,
           ExcludeDebt_CODE,
           InsResonable_CODE,
           StatusLocate_DATE,
           MethodDisestablish_CODE)
   SELECT DISTINCT
          a.Case_IDNO,
          a.MemberMci_IDNO,
          a.CaseRelationship_CODE,
          CASE
           WHEN a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                AND f.Deceased_DATE NOT IN (@Ld_Highdate_DATE, @Ld_Lowdate_DATE)
            THEN @Lc_StatusCaseMemberActive_CODE
           WHEN a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberInactive_CODE
                AND f.Deceased_DATE NOT IN (@Ld_Highdate_DATE, @Ld_Lowdate_DATE)
            THEN @Lc_StatusCaseMemberInactive_CODE
           ELSE a.CaseMemberStatus_CODE
          END AS CaseMemberStatus_CODE,
          ISNULL(f.PaternityEst_CODE, @Lc_Space_TEXT) AS PaternityEst_CODE,
          ISNULL(e.StatusLocate_CODE, @Lc_Space_TEXT) AS StatusLocate_CODE,
          CASE
           WHEN (a.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                 AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberInactive_CODE
                 AND a.ReasonMemberStatus_CODE = @Lc_ChildOrdStatEmancipated_TEXT)
            THEN @Lc_ChildOrdStatEmancipated_TEXT
           ELSE @Lc_Space_TEXT
          END AS StatusChildOrder_CODE,
          ISNULL(d.MediumDisburse_CODE, @Lc_Space_TEXT) AS MediumDisburse_CODE,
          @Ld_Lowdate_DATE AS Birth_DATE,
          ISNULL(f.Age_QNTY, -1) AS Age_QNTY,
          @Ln_Zero_NUMB AS NcpNsfBalance_AMNT,
          ISNULL(f.BornOfMarriage_CODE, @Lc_Space_TEXT) AS BornOfMarriage_INDC,
          ISNULL(f.FamilyViolence_INDC, @Lc_Space_TEXT) AS FamilyViolenceIndc_CODE,
          @Lc_Space_TEXT AS NcpNsf_CODE,
          ISNULL(c.Enumeration_CODE, @Lc_Space_TEXT) AS Ssn_CODE,
          @Lc_Space_TEXT AS ExcludeIrs_CODE,
          @Lc_Space_TEXT AS ExcludePas_CODE,
          @Lc_Space_TEXT AS ExcludeFin_CODE,
          @Lc_Space_TEXT AS ExcludeIns_CODE,
          @Lc_Space_TEXT AS ExcludeVen_CODE,
          @Lc_Space_TEXT AS ExcludeRet_CODE,
          @Lc_Space_TEXT AS ExcludeSal_CODE,
          @Lc_Space_TEXT AS ExcludeDebt_CODE,
          ISNULL(b.InsReasonable_INDC, @Lc_Space_TEXT) AS InsResonable_CODE,
          ISNULL(e.StatusLocate_DATE, @Ld_Highdate_DATE) AS StatusLocate_DATE,
          ISNULL(f.MethodDisestablish_CODE, @Lc_Space_TEXT) AS MethodDisestablish_CODE
     FROM CMEM_Y1 a
          LEFT OUTER JOIN (SELECT x.MemberMci_IDNO,
                                  MAX(x.InsReasonable_INDC) AS InsReasonable_INDC
                             FROM EHIS_Y1 x
                            WHERE x.EndEmployment_DATE = @Ld_Highdate_DATE
                            GROUP BY x.MemberMci_IDNO) AS b
           ON b.MemberMci_IDNO = a.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT fci.MemberMci_IDNO,
                                  fci.Enumeration_CODE
                             FROM (SELECT z.MemberMci_IDNO,
                                          z.Enumeration_CODE,
                                          ROW_NUMBER() OVER(PARTITION BY z.MemberMci_IDNO ORDER BY z.TransactionEventSeq_NUMB DESC) AS rnm
                                     FROM MSSN_Y1 z
                                    WHERE z.TypePrimary_CODE = @Lc_SsnTypePrimary_CODE
                                      AND z.EndValidity_DATE = @Ld_Highdate_DATE) AS fci
                            WHERE fci.rnm = 1) AS c
           ON c.MemberMci_IDNO = a.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT DISTINCT
                                  b.CheckRecipient_ID AS MemberMci_IDNO,
                                  @Lc_DisburseMediumDirectDeposit_TEXT AS MediumDisburse_CODE
                             FROM EFTR_Y1 b
                            WHERE b.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                              AND b.EndValidity_DATE = @Ld_Highdate_DATE
                           UNION ALL
                           (SELECT b.CheckRecipient_ID,
                                   @Lc_DisbursementSvc_TEXT
                              FROM DCRS_Y1 b
                             WHERE b.EndValidity_DATE = @Ld_Highdate_DATE
                            EXCEPT
                            SELECT b.CheckRecipient_ID,
                                   @Lc_DisbursementSvc_TEXT
                              FROM EFTR_Y1 b
                             WHERE b.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                               AND b.EndValidity_DATE = @Ld_Highdate_DATE)) AS d
           ON d.MemberMci_IDNO = a.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT z.MemberMci_IDNO,
                                  z.StatusLocate_CODE,
                                  z.StatusLocate_DATE
                             FROM LSTT_Y1 z
                            WHERE z.EndValidity_DATE = @Ld_Highdate_DATE
                              AND z.StatusLocate_DATE IN (SELECT MAX(x.StatusLocate_DATE)
															FROM LSTT_Y1 x
														   WHERE x.MemberMci_IDNO = z.MemberMci_IDNO
														     AND x.EndValidity_DATE = @Ld_Highdate_DATE)) AS e
           ON e.MemberMci_IDNO = a.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT y.MemberMci_IDNO,
                                  ISNULL((SELECT z.PaternityEst_CODE 
                                            FROM MPAT_Y1 z 
                                           WHERE z.MemberMci_IDNO = y.MemberMci_IDNO), @Lc_Space_TEXT) AS PaternityEst_CODE,
                                  y.Emancipation_DATE,
                                  y.Birth_DATE,
                                  CASE
                                   WHEN y.Birth_DATE IN (@Ld_Lowdate_DATE, @Ld_Highdate_DATE)
                                    THEN 0
                                   WHEN y.Birth_DATE IS NULL
                                    THEN 0
                                   ELSE CAST(ABS(DATEDIFF(DD, y.Birth_DATE, @Ld_Start_DATE) / @Ln_DaysInyear_NUMB) AS NUMERIC)
                                  END AS Age_QNTY,
                                  ISNULL((SELECT CASE
                                           WHEN z.BornOfMarriage_CODE = @Lc_Yes_TEXT
                                            THEN @Lc_No_TEXT
                                           ELSE
                                            CASE
                                             WHEN z.BornOfMarriage_CODE = @Lc_No_TEXT
                                              THEN @Lc_Yes_TEXT
                                            END
                                          END AS BornOfMarriage_CODE
                                     FROM MPAT_Y1 z WHERE z.MemberMci_IDNO = y.MemberMci_IDNO), @Lc_Space_TEXT) AS BornOfMarriage_CODE,
                                  MAX(x.FamilyViolence_INDC) FamilyViolence_INDC,
                                  ISNULL((SELECT z.MethodDisestablish_CODE 
                                            FROM MPAT_Y1 z 
                                           WHERE z.MemberMci_IDNO = y.MemberMci_IDNO), @Lc_Space_TEXT) AS MethodDisestablish_CODE,
                                  y.Deceased_DATE
                             FROM DEMO_Y1 y,                                  
                                  CMEM_Y1 x
                            WHERE x.MemberMci_IDNO = y.MemberMci_IDNO
                              AND x.TransactionEventSeq_NUMB IN (SELECT MAX(TransactionEventSeq_NUMB)
                                                                   FROM CMEM_Y1 a
                                                                  WHERE a.MemberMci_IDNO = x.MemberMci_IDNO
                                                                    AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
                            GROUP BY y.MemberMci_IDNO, y.Emancipation_DATE, y.Birth_DATE, y.Deceased_DATE) AS f
           ON f.MemberMci_IDNO = a.MemberMci_IDNO
    WHERE EXISTS (SELECT 1
                    FROM BPCASE_Y1 c
                   WHERE c.Case_IDNO = a.Case_IDNO);
      

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'UPDATE Age_QNTY IN BPMEMB_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET Age_QNTY = 200
    WHERE Age_QNTY > 200;

   SET @Ls_Sql_TEXT = 'UPDATE EXCLUDED MEMBER Status_CODE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET CaseMemberStatus_CODE = CASE
                                   WHEN a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                    THEN @Lc_Three_TEXT
                                   WHEN a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberInactive_CODE
                                    THEN @Lc_Four_TEXT
                                   ELSE a.CaseMemberStatus_CODE
                                  END
     FROM BPMEMB_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM GTST_Y1 b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.TestResult_CODE = @Lc_ResultExcluded_TEXT
                     AND b.EndValidity_DATE = @Ld_Highdate_DATE);

   SET @Ls_Sql_TEXT = 'UPDATE BPMEMB_Y1-NOT COURT ORDER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET StatusChildOrder_CODE = @Lc_ChildOrdStatNonCourt_TEXT
     FROM BPMEMB_Y1 a
    WHERE a.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
      AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND a.StatusChildOrder_CODE != @Lc_ChildOrdStatEmancipated_TEXT
      AND NOT EXISTS (SELECT 1
                        FROM OBLE_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndObligation_DATE <= @Ld_Start_DATE);

   SET @Ls_Sql_TEXT = 'UPDATE BPMEMB_Y1-ON COURT ORDER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET StatusChildOrder_CODE = @Lc_ChildOrdStatCourt_TEXT
     FROM BPMEMB_Y1 a
    WHERE a.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
      AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND a.StatusChildOrder_CODE NOT IN (@Lc_ChildOrdStatNonCourt_TEXT, @Lc_ChildOrdStatEmancipated_TEXT)
      AND EXISTS (SELECT 1
                    FROM OBLE_Y1 b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.EndObligation_DATE = @Ld_Highdate_DATE);

   SET @Ls_Sql_TEXT = 'UPDATE BPMEMB_Y1-NON SUFFICIENT FUNDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET NcpNsf_CODE = CASE
                         WHEN EXISTS (SELECT 1
                                        FROM BCHK_Y1 c
                                       WHERE c.MemberMci_IDNO = a.MemberMci_IDNO)
                          THEN @Lc_Yes_TEXT
                         ELSE @Lc_No_TEXT
                        END
     FROM BPMEMB_Y1 a
    WHERE a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT);

   SET @Ls_Sql_TEXT = 'UPDATE BPMEMB_Y1 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET ExcludeIrs_CODE = z.ExcludeIrs_CODE,
          ExcludeFin_CODE = z.ExcludeFin_CODE,
          ExcludePas_CODE = z.ExcludePas_CODE,
          ExcludeRet_CODE = z.ExcludeRet_CODE,
          ExcludeSal_CODE = z.ExcludeSal_CODE,
          ExcludeDebt_CODE = z.ExcludeDebt_CODE,
          ExcludeVen_CODE = z.ExcludeVen_CODE,
          ExcludeIns_CODE = z.ExcludeIns_CODE
     FROM (SELECT TOP 1 a.MemberMci_IDNO,
                        a.Case_IDNO,
                        (CASE b.ExcludeIrs_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeIrs_CODE
                         END) ExcludeIrs_CODE,
                        (CASE b.ExcludeFin_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeFin_CODE
                         END) ExcludeFin_CODE,
                        (CASE b.ExcludePas_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludePas_CODE
                         END) ExcludePas_CODE,
                        (CASE b.ExcludeRet_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeRet_CODE
                         END) ExcludeRet_CODE,
                        (CASE b.ExcludeSal_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeSal_CODE
                         END) ExcludeSal_CODE,
                        (CASE b.ExcludeDebt_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeDebt_CODE
                         END) ExcludeDebt_CODE,
                        (CASE b.ExcludeVen_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeVen_CODE
                         END) ExcludeVen_CODE,
                        (CASE b.ExcludeIns_CODE
                          WHEN @Lc_SystemExclusion_TEXT
                           THEN @Lc_Yes_TEXT
                          ELSE b.ExcludeIns_CODE
                         END) ExcludeIns_CODE
             FROM IFMS_Y1 b,
                  BPCASE_Y1 z,
                  BPMEMB_Y1 a
            WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
              AND b.Case_IDNO = a.Case_IDNO
              AND a.Case_IDNO = z.Case_IDNO
              AND z.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
              AND b.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                  FROM IFMS_Y1 c
                                                 WHERE c.Case_IDNO = b.Case_IDNO
                                                   AND c.MemberMci_IDNO = b.MemberMci_IDNO)) AS z
    WHERE EXISTS (SELECT 1
                    FROM IFMS_Y1 b
                   WHERE b.Case_IDNO = z.Case_IDNO
                     AND b.MemberMci_IDNO = z.MemberMci_IDNO);

   SET @Ls_Sql_TEXT = 'UPDATE BPMEMB_Y1 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET ExcludeIrs_CODE = z.ExcludeIrs_CODE,
          ExcludeFin_CODE = z.ExcludeFin_CODE,
          ExcludePas_CODE = z.ExcludePas_CODE,
          ExcludeRet_CODE = z.ExcludeRet_CODE,
          ExcludeSal_CODE = z.ExcludeSal_CODE,
          ExcludeDebt_CODE = z.ExcludeDebt_CODE,
          ExcludeVen_CODE = z.ExcludeVen_CODE,
          ExcludeIns_CODE = z.ExcludeIns_CODE
     FROM (SELECT b.Case_IDNO,
                  b.MemberMci_IDNO,
                  CASE
                   WHEN b.ExcludeIrs_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeIrs_CODE,
                  CASE
                   WHEN b.ExcludeFin_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeFin_CODE,
                  CASE
                   WHEN b.ExcludePas_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludePas_CODE,
                  CASE
                   WHEN b.ExcludeRet_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeRet_CODE,
                  CASE
                   WHEN b.ExcludeSal_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeSal_CODE,
                  CASE
                   WHEN b.ExcludeDebt_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeDebt_CODE,
                  CASE
                   WHEN b.ExcludeVen_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeVen_CODE,
                  CASE
                   WHEN b.ExcludeIns_INDC = @Lc_Yes_TEXT
                    THEN b.ExcludeIrs_INDC
                   ELSE @Lc_No_TEXT
                  END AS ExcludeIns_CODE
             FROM TEXC_Y1 AS b
                  LEFT OUTER JOIN (SELECT s.Case_IDNO,
                                          s.MemberMci_IDNO,
                                          s.ExcludeIrs_CODE,
                                          s.ExcludeAdm_CODE,
                                          s.ExcludeFin_CODE,
                                          s.ExcludePas_CODE,
                                          s.ExcludeRet_CODE,
                                          s.ExcludeSal_CODE,
                                          s.ExcludeDebt_CODE,
                                          s.ExcludeVen_CODE,
                                          s.ExcludeIns_CODE
                                     FROM IFMS_Y1 s
                                    WHERE s.TransactionEventSeq_NUMB = (SELECT MAX(t.TransactionEventSeq_NUMB)
                                                                          FROM IFMS_Y1 AS t
                                                                         WHERE t.Case_IDNO = s.Case_IDNO
                                                                           AND t.MemberMci_IDNO = s.MemberMci_IDNO)) AS a
                   ON b.Case_IDNO = a.Case_IDNO
                      AND b.MemberMci_IDNO = a.MemberMci_IDNO
                      AND a.ExcludeIrs_CODE = @Lc_No_TEXT
                      AND a.ExcludeAdm_CODE = @Lc_No_TEXT
                      AND a.ExcludeFin_CODE = @Lc_No_TEXT
                      AND a.ExcludePas_CODE = @Lc_No_TEXT
                      AND a.ExcludeRet_CODE = @Lc_No_TEXT
                      AND a.ExcludeSal_CODE = @Lc_No_TEXT
                      AND a.ExcludeDebt_CODE = @Lc_No_TEXT
                      AND a.ExcludeVen_CODE = @Lc_No_TEXT
                      AND a.ExcludeIns_CODE = @Lc_No_TEXT,
                  BPCASE_Y1 z
            WHERE b.MemberMci_IDNO = z.MemberMci_IDNO
              AND b.Case_IDNO = z.Case_IDNO
              AND z.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
              AND (b.ExcludeIrs_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeAdm_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeFin_INDC = @Lc_Yes_TEXT
                    OR b.ExcludePas_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeRet_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeSal_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeDebt_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeVen_INDC = @Lc_Yes_TEXT
                    OR b.ExcludeIns_INDC = @Lc_Yes_TEXT)
              AND b.End_DATE > @Ld_Start_DATE
              AND b.EndValidity_DATE = @Ld_Highdate_DATE) AS z,
          BPMEMB_Y1 x
    WHERE z.Case_IDNO = x.Case_IDNO
      AND z.MemberMci_IDNO = x.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'UPDATE BPMEMB_Y1 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE BPMEMB_Y1
      SET NcpNsfBalance_AMNT = ISNULL((SELECT SUM(ABS(a.ToDistribute_AMNT)) AS NcpNsfBalance_AMNT
                                         FROM RCTH_Y1 a
                                        WHERE y.MemberMci_IDNO = a.PayorMCI_IDNO
                                          AND (a.Case_IDNO = @Ln_Zero_NUMB
                                                OR y.Case_IDNO = a.Case_IDNO)
                                          AND a.BackOut_INDC = @Lc_Yes_TEXT
                                          AND a.ReasonBackOut_CODE = @Lc_RevrsnInsufficientfunds_TEXT
                                          AND a.EndValidity_DATE = @Ld_Highdate_DATE), @Ln_Zero_NUMB)
     FROM BPMEMB_Y1 y
    WHERE y.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
      AND y.NcpNsf_CODE = @Lc_Yes_TEXT;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_Failed_CODE;
    SET @An_RecordCount_NUMB = 0;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Lc_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END 

GO
