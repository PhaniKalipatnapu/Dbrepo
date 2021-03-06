/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_CALCULATE_NCP_ARREARS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_CALCULATE_NCP_ARREARS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_CALCULATE_NCP_ARREARS is 
					  to calculate the NCP's arrears.
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_CALCULATE_NCP_ARREARS] (
 @Ad_Run_DATE              DATE,
 @As_RestartKey_TEXT       VARCHAR(200),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_One_NUMB                       NUMERIC = 1,
          @Lc_Space_TEXT                     CHAR = ' ',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',
          @Lc_No_TEXT                        CHAR(1) = 'N',
          @Lc_WelfareTypeTanf_CODE           CHAR(1) = 'A',
          @Lc_WelfareTypeFosterCare_CODE     CHAR(1) = 'J',
          @Lc_WelfareTypeNonIve_CODE         CHAR(1) = 'F',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_TEXT       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT CHAR(1) = 'P',
          @Lc_TypePrimaryP_CODE              CHAR(1) = 'P',
          @Lc_TypePrimaryI_CODE              CHAR(1) = 'I',
          @Lc_EnumerationY_CODE              CHAR(1) = 'Y',
          @Lc_EnumerationP_CODE              CHAR(1) = 'P',
          @Lc_CaseStatusClosed_CODE          CHAR(1) = 'C',
          @Lc_CaseTypeNonIvd_CODE            CHAR(1) = 'H',
          @Lc_RespondInitR_CODE              CHAR(1) = 'R',
          @Lc_RespondInitS_CODE              CHAR(1) = 'S',
          @Lc_RespondInitY_CODE              CHAR(1) = 'Y',
          @Lc_DebtTypeGeneticTest_CODE       CHAR(2) = 'GT',
          @Lc_DebtTypeNcpNsfFee_CODE         CHAR(2) = 'NF',
          @Lc_PreexclusionsCs_TEXT           CHAR(2) = 'CS',
          @Lc_MajorActivityImiw_CODE         CHAR(4) = 'IMIW',
          @Lc_RemedyStatusStart_CODE         CHAR(4) = 'STRT',
          @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
          @Lc_Job_ID                         CHAR(7) = 'DEB5310',
          @Lc_RestartKeyArc1_CODE            CHAR(10) = 'ARC1',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_CALCULATE_NCP_ARREARS',
          @Ld_Run_DATE                       DATE = @Ad_Run_DATE,
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB             NUMERIC = 0,
          @Ln_SupportYearMonth_NUMB NUMERIC(6),
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_FetchStatus_QNTY      NUMERIC(11),
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);
  DECLARE @Ln_VerSsnCur_MemberSsn_NUMB NUMERIC(9),
          @Ln_VerSsnCur_MemberMci_IDNO NUMERIC(10);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ln_SupportYearMonth_NUMB = CONVERT(VARCHAR(6), @Ld_Run_DATE, 112);

   IF @As_RestartKey_TEXT = @Lc_RestartKeyArc1_CODE
    BEGIN
     GOTO ARC1;
    END

   SET @Ls_Sql_TEXT = 'INSERT PMCAR_Y1 - 1';
   SET @Ls_SqlData_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   INSERT PMCAR_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           MemberSsn_NUMB,
           County_IDNO,
           TypeCase_CODE,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           Iwn_INDC)
   SELECT q.MemberMci_IDNO,
          q.Case_IDNO,
          @Ln_Zero_NUMB AS MemberSsn_NUMB,
          q.County_IDNO,
          q.TypeCase_CODE,
          q.TanfArrear_AMNT,
          q.NonTanfArrear_AMNT,
          CASE
           WHEN (q.Iwn_INDC = @Lc_Yes_TEXT
                 AND q.cur_supp >= (q.TanfArrear_AMNT + q.NonTanfArrear_AMNT))
            THEN @Lc_Yes_TEXT
           ELSE @Lc_No_TEXT
          END AS Iwn_INDC
     FROM (SELECT z.MemberMci_IDNO,
                  z.Case_IDNO,
                  MAX(z.County_IDNO) AS County_IDNO,
                  MAX(z.TypeCase_CODE) AS TypeCase_CODE,
                  SUM(l.OweTotPaa_AMNT - l.AppTotPaa_AMNT + l.OweTotTaa_AMNT - l.AppTotTaa_AMNT + l.OweTotIvef_AMNT - l.AppTotIvef_AMNT + l.OweTotCaa_AMNT - l.AppTotCaa_AMNT + l.OweTotNffc_AMNT - l.AppTotNffc_AMNT - CASE
                                                                                                                                                                                                                         WHEN l.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeFosterCare_CODE, @Lc_WelfareTypeNonIve_CODE)
                                                                                                                                                                                                                          THEN l.OweTotCurSup_AMNT - l.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                            WHEN l.MtdCurSupOwed_AMNT < l.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                             THEN l.AppTotCurSup_AMNT - l.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                            ELSE @Ln_Zero_NUMB
                                                                                                                                                                                                                                                                           END
                                                                                                                                                                                                                         ELSE @Ln_Zero_NUMB
                                                                                                                                                                                                                        END) AS TanfArrear_AMNT,
                  SUM(l.OweTotNaa_AMNT - l.AppTotNaa_AMNT + l.OweTotMedi_AMNT - l.AppTotMedi_AMNT + l.OweTotUpa_AMNT - l.AppTotUpa_AMNT + l.OweTotUda_AMNT - l.AppTotUda_AMNT + l.OweTotNonIvd_AMNT - l.AppTotNonIvd_AMNT - CASE
                                                                                                                                                                                                                             WHEN l.TypeWelfare_CODE NOT IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeFosterCare_CODE, @Lc_WelfareTypeNonIve_CODE)
                                                                                                                                                                                                                              THEN l.OweTotCurSup_AMNT - l.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                WHEN l.MtdCurSupOwed_AMNT < l.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                 THEN l.AppTotCurSup_AMNT - l.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                ELSE @Ln_Zero_NUMB
                                                                                                                                                                                                                                                                               END
                                                                                                                                                                                                                             ELSE @Ln_Zero_NUMB
                                                                                                                                                                                                                            END) AS NonTanfArrear_AMNT,
                  MAX(z.Iwn_INDC) AS Iwn_INDC,
                  SUM(l.MtdCurSupOwed_AMNT) AS cur_supp
             FROM LSUP_Y1 l,
                  (SELECT DISTINCT
                          b.Case_IDNO,
                          b.OrderSeq_NUMB,
                          b.ObligationSeq_NUMB,
                          b.MemberMci_IDNO,
                          b.County_IDNO,
                          b.TypeCase_CODE,
                          CASE
                           WHEN (SELECT COUNT(1)
                                   FROM DMJR_Y1
                                  WHERE DMJR_Y1.Case_IDNO = b.Case_IDNO
                                    AND DMJR_Y1.ActivityMajor_CODE = @Lc_MajorActivityImiw_CODE
                                    AND DMJR_Y1.Status_CODE = @Lc_RemedyStatusStart_CODE) > @Ln_Zero_NUMB
                            THEN @Lc_Yes_TEXT
                           ELSE @Lc_No_TEXT
                          END AS Iwn_INDC,
                          lspk.lsup_Case_IDNO,
                          lspk.lsup_EventGlobalSeq_NUMB,
                          lspk.lsup_ObligationSeq_NUMB,
                          lspk.lsup_OrderSeq_NUMB,
                          lspk.lsup_SupportYearMonth_NUMB
                     FROM (SELECT o.Case_IDNO,
                                  o.OrderSeq_NUMB,
                                  o.ObligationSeq_NUMB,
                                  c.MemberMci_IDNO,
                                  a.County_IDNO,
                                  a.TypeCase_CODE
                             FROM OBLE_Y1 o,
                                  CMEM_Y1 c,
                                  CASE_Y1 a
                            WHERE o.Case_IDNO = c.Case_IDNO
                              AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                              AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                              AND o.EndValidity_DATE = @Ld_High_DATE
                              AND o.TypeDebt_CODE NOT IN (@Lc_DebtTypeGeneticTest_CODE, @Lc_DebtTypeNcpNsfFee_CODE)
                              AND a.Case_IDNO = o.Case_IDNO
                              AND a.StatusCase_CODE <> @Lc_CaseStatusClosed_CODE
                              AND a.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
                              AND a.RespondInit_CODE NOT IN (@Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE)) b,
                          (SELECT x.Case_IDNO,
                                  x.OrderSeq_NUMB,
                                  x.ObligationSeq_NUMB,
                                  x.lsup_Case_IDNO,
                                  x.lsup_EventGlobalSeq_NUMB,
                                  x.lsup_ObligationSeq_NUMB,
                                  x.lsup_OrderSeq_NUMB,
                                  x.lsup_SupportYearMonth_NUMB
                             FROM (SELECT lpk.Case_IDNO,
                                          lpk.OrderSeq_NUMB,
                                          lpk.ObligationSeq_NUMB,
                                          Case_IDNO AS lsup_Case_IDNO,
                                          EventGlobalSeq_NUMB AS lsup_EventGlobalSeq_NUMB,
                                          ObligationSeq_NUMB AS lsup_ObligationSeq_NUMB,
                                          OrderSeq_NUMB AS lsup_OrderSeq_NUMB,
                                          SupportYearMonth_NUMB AS lsup_SupportYearMonth_NUMB,
                                          lpk.SupportYearMonth_NUMB,
                                          lpk.EventGlobalSeq_NUMB,
                                          ROW_NUMBER() OVER(PARTITION BY lpk.Case_IDNO, lpk.OrderSeq_NUMB, lpk.ObligationSeq_NUMB ORDER BY lpk.SupportYearMonth_NUMB DESC, lpk.EventGlobalSeq_NUMB DESC) AS rn
                                     FROM LSUP_Y1 lpk
                                    WHERE lpk.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB) x
                            WHERE x.rn = @Ln_One_NUMB) lspk
                    WHERE lspk.Case_IDNO = b.Case_IDNO
                      AND lspk.OrderSeq_NUMB = b.OrderSeq_NUMB
                      AND lspk.ObligationSeq_NUMB = b.ObligationSeq_NUMB) z
            WHERE l.Case_IDNO = z.lsup_Case_IDNO
              AND l.EventGlobalSeq_NUMB = z.lsup_EventGlobalSeq_NUMB
              AND l.ObligationSeq_NUMB = z.lsup_ObligationSeq_NUMB
              AND l.OrderSeq_NUMB = z.lsup_OrderSeq_NUMB
              AND l.SupportYearMonth_NUMB = lsup_SupportYearMonth_NUMB
            GROUP BY z.MemberMci_IDNO,
                     z.Case_IDNO) q
    WHERE dbo.BATCH_ENF_OUTGOING_TAX_OFFSET$SF_CASE_HAS_ONLY_SPOUSAL_SUPPORT_ARREARS (@Ld_Run_DATE, q.Case_IDNO) = 'N';

   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART';
   SET @Ls_SqlData_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyArc1_CODE, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyArc1_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END

   ARC1:

   SET @Ls_Sql_TEXT = 'UPDATE IRSA_Y1 - 1';
   SET @Ls_SqlData_TEXT = '';

   UPDATE IRSA_Y1
      SET TanfArrear_AMNT = @Ln_Zero_NUMB,
          NonTanfArrear_AMNT = @Ln_Zero_NUMB,
          Iwn_INDC = @Lc_No_TEXT,
          ActualTanfArrear_AMNT = @Ln_Zero_NUMB,
          ActualNonTanfArrear_AMNT = @Ln_Zero_NUMB,
          PreEdit_CODE = @Lc_Space_TEXT,
          Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
     FROM IRSA_Y1 d;

   SET @Ls_Sql_TEXT = 'UPDATE IRSA_Y1 FOR EXISTING RECORDS FROM PMCAR_Y1';
   SET @Ls_SqlData_TEXT = '';

   UPDATE a
      SET ActualTanfArrear_AMNT = TanfArrear_AMNT,
          ActualNonTanfArrear_AMNT = NonTanfArrear_AMNT,
          CountyIrsa_IDNO = CountyPmcar_IDNO
     FROM (SELECT a.ActualTanfArrear_AMNT,
                  b.TanfArrear_AMNT,
                  a.ActualNonTanfArrear_AMNT,
                  b.NonTanfArrear_AMNT,
                  a.County_IDNO AS CountyIrsa_IDNO,
                  b.County_IDNO AS CountyPmcar_IDNO
             FROM IRSA_Y1 a,
                  PMCAR_Y1 b
            WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
              AND b.Case_IDNO = a.Case_IDNO
              AND b.Iwn_INDC = @Lc_No_TEXT) a;

   SET @Ls_Sql_TEXT = 'INSERT IRSA_Y1 - 1';
   SET @Ls_SqlData_TEXT = 'TanfArrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', NonTanfArrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', PreEdit_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   INSERT IRSA_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           MemberSsn_NUMB,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           ActualTanfArrear_AMNT,
           ActualNonTanfArrear_AMNT,
           Iwn_INDC,
           PreEdit_CODE,
           County_IDNO,
           WorkerUpdate_ID,
           Update_DTTM)
   SELECT l.MemberMci_IDNO,
          l.Case_IDNO,
          @Ln_Zero_NUMB AS MemberSsn_NUMB,
          @Ln_Zero_NUMB AS TanfArrear_AMNT,
          @Ln_Zero_NUMB AS NonTanfArrear_AMNT,
          l.TanfArrear_AMNT,
          l.NonTanfArrear_AMNT,
          l.Iwn_INDC,
          @Lc_Space_TEXT AS PreEdit_CODE,
          l.County_IDNO,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM
     FROM PMCAR_Y1 l
    WHERE NOT EXISTS (SELECT 1
                        FROM IRSA_Y1 la
                       WHERE la.MemberMci_IDNO = l.MemberMci_IDNO
                         AND la.Case_IDNO = l.Case_IDNO);

   SET @Ls_Sql_TEXT = 'UPDATE IRSA_Y1 - 2';
   SET @Ls_SqlData_TEXT = '';

   UPDATE a
      SET TanfArrear_AMNT = QualifiedTanfArrear_AMNT,
          NonTanfArrear_AMNT = QualifiedNonTanfArrear_AMNT
     FROM (SELECT a.TanfArrear_AMNT,
                  CASE
                   WHEN (a.ActualTanfArrear_AMNT + a.ActualNonTanfArrear_AMNT) > @Ln_Zero_NUMB
                        AND a.ActualTanfArrear_AMNT > @Ln_Zero_NUMB
                    THEN
                    CASE
                     WHEN a.ActualNonTanfArrear_AMNT < @Ln_Zero_NUMB
                      THEN a.ActualTanfArrear_AMNT + a.ActualNonTanfArrear_AMNT
                     ELSE a.ActualTanfArrear_AMNT
                    END
                   ELSE @Ln_Zero_NUMB
                  END QualifiedTanfArrear_AMNT,
                  a.NonTanfArrear_AMNT,
                  CASE
                   WHEN (a.ActualTanfArrear_AMNT + a.ActualNonTanfArrear_AMNT) > @Ln_Zero_NUMB
                        AND a.ActualNonTanfArrear_AMNT > @Ln_Zero_NUMB
                    THEN
                    CASE
                     WHEN a.ActualTanfArrear_AMNT < @Ln_Zero_NUMB
                      THEN a.ActualNonTanfArrear_AMNT + a.ActualTanfArrear_AMNT
                     ELSE a.ActualNonTanfArrear_AMNT
                    END
                   ELSE @Ln_Zero_NUMB
                  END QualifiedNonTanfArrear_AMNT
             FROM IRSA_Y1 a)a;

   SET @Ls_Sql_TEXT = 'INSERT IRSA_Y1 - 2';
   SET @Ls_SqlData_TEXT = 'TanfArrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', NonTanfArrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', ActualTanfArrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', ActualNonTanfArrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Iwn_INDC = ' + ISNULL(@Lc_No_TEXT, '') + ', PreEdit_CODE = ' + ISNULL(@Lc_PreexclusionsCs_TEXT, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   INSERT IRSA_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           MemberSsn_NUMB,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           ActualTanfArrear_AMNT,
           ActualNonTanfArrear_AMNT,
           Iwn_INDC,
           PreEdit_CODE,
           County_IDNO,
           WorkerUpdate_ID,
           Update_DTTM)
   SELECT q.MemberMci_IDNO,
          q.Case_IDNO,
          @Ln_Zero_NUMB AS MemberSsn_NUMB,
          @Ln_Zero_NUMB AS TanfArrear_AMNT,
          @Ln_Zero_NUMB AS NonTanfArrear_AMNT,
          @Ln_Zero_NUMB AS ActualTanfArrear_AMNT,
          @Ln_Zero_NUMB AS ActualNonTanfArrear_AMNT,
          @Lc_No_TEXT AS Iwn_INDC,
          @Lc_PreexclusionsCs_TEXT AS PreEdit_CODE,
          q.County_IDNO,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM
     FROM (SELECT b.MemberMci_IDNO,
                  b.Case_IDNO,
                  a.County_IDNO
             FROM CASE_Y1 a,
                  CMEM_Y1 b
            WHERE a.Case_IDNO = b.Case_IDNO
              AND a.StatusCase_CODE <> @Lc_CaseStatusClosed_CODE
              AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
              AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
              AND (a.TypeCase_CODE = @Lc_CaseTypeNonIvd_CODE
                    OR a.RespondInit_CODE IN (@Lc_RespondInitR_CODE, @Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE)))AS q
    WHERE NOT EXISTS(SELECT 1
                       FROM IRSA_Y1 la
                      WHERE la.MemberMci_IDNO = q.MemberMci_IDNO
                        AND la.Case_IDNO = q.Case_IDNO);

   SET @Ls_Sql_TEXT = 'DECLARE VerSsn_CUR';

   DECLARE VerSsn_CUR INSENSITIVE CURSOR FOR
    SELECT d.MemberMCI_IDNO,
           d.Derived_MemberSsn_NUMB
      FROM(SELECT a.MemberMCI_IDNO,
                  a.MemberSsn_NUMB,
                  ISNULL((SELECT TOP 1 c.MemberSsn_NUMB
                            FROM (SELECT b.MemberMci_IDNO,
                                         b.MemberSsn_NUMB,
                                         b.TypePrimary_CODE,
                                         b.Enumeration_CODE,
                                         b.TransactionEventSeq_NUMB
                                    FROM MSSN_Y1 b
                                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                     AND b.TypePrimary_CODE IN ('P', 'I')
                                     AND b.Enumeration_CODE = 'Y'
                                     AND b.EndValidity_DATE = @Ld_High_DATE) AS c
                           ORDER BY c.TypePrimary_CODE DESC,
                                    c.Enumeration_CODE DESC,
                                    c.TransactionEventSeq_NUMB DESC), 0) Derived_MemberSsn_NUMB
             FROM IRSA_Y1 a) d
     WHERE d.MemberSsn_NUMB <> d.Derived_MemberSsn_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN VerSsn_CUR';

   OPEN VerSsn_CUR;

   SET @Ls_Sql_TEXT = 'FETCH VerSsn_CUR - 1';

   FETCH NEXT FROM VerSsn_CUR INTO @Ln_VerSsnCur_MemberMci_IDNO, @Ln_VerSsnCur_MemberSsn_NUMB;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VerSsnCur_MemberMci_IDNO AS VARCHAR), '');

     UPDATE IRSA_Y1
        SET MemberSsn_NUMB = @Ln_VerSsnCur_MemberSsn_NUMB
      WHERE MemberMci_IDNO = @Ln_VerSsnCur_MemberMci_IDNO
        AND MemberSsn_NUMB <> @Ln_VerSsnCur_MemberSsn_NUMB;

     SET @Ls_Sql_TEXT = 'FETCH VerSsn_CUR - 2';

     FETCH NEXT FROM VerSsn_CUR INTO @Ln_VerSsnCur_MemberMci_IDNO, @Ln_VerSsnCur_MemberSsn_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE VerSsn_CUR;

   DEALLOCATE VerSsn_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'VerSsn_CUR') IN (0, 1)
    BEGIN
     CLOSE VerSsn_CUR;

     DEALLOCATE VerSsn_CUR;
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
