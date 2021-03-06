/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_CALC_CASE_ARREAR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_CALC_CASE_ARREAR
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_CALC_CASE_ARREAR 
					  is to calculate arrears for all eligible cases
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_CALC_CASE_ARREAR]
 @Ad_Run_DATE              DATE,
 @An_TaxYear_NUMB          NUMERIC(04),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_One_NUMB                       NUMERIC = 1,
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
          @Lc_RelationshipCaseCp_TEXT        CHAR(1) = 'C',
          @Lc_RelationshipCaseDep_TEXT       CHAR(1) = 'D',
          @Lc_CaseStatusClosed_CODE          CHAR(1) = 'C',
          @Lc_CaseTypeNonIvd_CODE            CHAR(1) = 'H',
          @Lc_DebtTypeGeneticTest_CODE       CHAR(2) = 'GT',
          @Lc_DebtTypeNcpNsfFee_CODE         CHAR(2) = 'NF',
          @Lc_DebtTypeSpousalSupport_CODE    CHAR(2) = 'SS',
          @Lc_MajorActivityImiw_CODE         CHAR(4) = 'IMIW',
          @Lc_RemedyStatusStart_CODE         CHAR(4) = 'STRT',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_CALC_CASE_ARREAR',
          @Ld_Run_DATE                       DATE = @Ad_Run_DATE,
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_Empty_DATE                     DATE = '01/01/1900',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                      NUMERIC = 0,
          @Ln_SupportYearMonth_NUMB          NUMERIC(6),
          @Ln_Error_NUMB                     NUMERIC(11),
          @Ln_ErrorLine_NUMB                 NUMERIC(11),
          @Li_FetchStatus_QNTY               SMALLINT,
          @Lc_Empty_TEXT                     CHAR = '',
          @Lc_TypeTransactionA_CODE          CHAR(1),
          @Lc_TypeTransactionN_CODE          CHAR(1),
          @Ls_Sql_TEXT                       VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT              VARCHAR(200),
          @Ls_SqlData_TEXT                   VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT          VARCHAR(4000),
          @Ld_SubmitLastA_DATE               DATE,
          @Ld_SubmitLastN_DATE               DATE,
          @Ld_PreviousSubmitLastA_DATE       DATE,
          @Ld_PreviousSubmitLastN_DATE       DATE,
          @Lc_PrevTypeTransactionA_CODE      CHAR(1),
          @Lc_PrevTypeTransactionN_CODE      CHAR(1),
          @Ld_LastNoticeSubmitLastA_DATE     DATE,
          @Ld_LastNoticeSubmitLastN_DATE     DATE,
          @Ld_PrevLastNoticeSubmitLastA_DATE DATE,
          @Ld_PrevLastNoticeSubmitLastN_DATE DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SET MonthSupport_NUMB';
   SET @Ls_SqlData_TEXT = '';
   SET @Ln_SupportYearMonth_NUMB = CONVERT(VARCHAR(6), @Ld_Run_DATE, 112);
   SET @Ls_Sql_TEXT = 'CREATE #Temp2_P1';

   CREATE TABLE #Temp2_P1
    (
      MemberMci_IDNO           NUMERIC(10),
      Case_IDNO                NUMERIC(06),
      ActualTanfArrear_AMNT    NUMERIC(11, 2),
      ActualNonTanfArrear_AMNT NUMERIC(11, 2),
      TanfArrear_AMNT          NUMERIC(11, 2),
      NonTanfArrear_AMNT       NUMERIC(11, 2),
      Iwn_INDC                 CHAR(1)
    );

   SET @Ls_Sql_TEXT = 'INSERT #Temp2_P1';
   SET @Ls_SqlData_TEXT = '';

   INSERT #Temp2_P1
          (MemberMci_IDNO,
           Case_IDNO,
           ActualTanfArrear_AMNT,
           ActualNonTanfArrear_AMNT,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           Iwn_INDC)
   SELECT q.MemberMci_IDNO,
          q.Case_IDNO,
          q.TanfArrear_AMNT AS ActualTanfArrear_AMNT,
          q.NonTanfArrear_AMNT AS ActualNonTanfArrear_AMNT,
          @Ln_Zero_NUMB AS TanfArrear_AMNT,
          @Ln_Zero_NUMB AS NonTanfArrear_AMNT,
          CASE
           WHEN (q.Iwn_INDC = @Lc_Yes_TEXT
                 AND q.cur_supp >= (q.TanfArrear_AMNT + q.NonTanfArrear_AMNT))
            THEN @Lc_Yes_TEXT
           ELSE @Lc_No_TEXT
          END AS Iwn_INDC
     FROM (SELECT z.MemberMci_IDNO,
                  z.Case_IDNO,
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
                             FROM #GetEligibleCases_P1 p,
                                  OBLE_Y1 o,
                                  CMEM_Y1 c,
                                  CASE_Y1 a
                            WHERE c.MemberMci_IDNO = p.MemberMci_IDNO
                              AND c.Case_IDNO = p.Case_IDNO
                              AND o.Case_IDNO = c.Case_IDNO
                              AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                              AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                              AND o.EndValidity_DATE = @Ld_High_DATE
                              AND o.TypeDebt_CODE NOT IN (@Lc_DebtTypeGeneticTest_CODE, @Lc_DebtTypeNcpNsfFee_CODE)
                              AND a.Case_IDNO = o.Case_IDNO
                              AND a.StatusCase_CODE <> @Lc_CaseStatusClosed_CODE
                              AND a.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE) b,
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

   SET @Ls_Sql_TEXT = 'UPDATE #Temp2_P1';
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
             FROM #Temp2_P1 a)a;

   SET @Ls_Sql_TEXT = 'CREATE #Temp3_P1';

   CREATE TABLE #Temp3_P1
    (
      MemberMci_IDNO     NUMERIC(10),
      Case_IDNO          NUMERIC(06),
      TanfArrear_AMNT    NUMERIC(11, 2),
      NonTanfArrear_AMNT NUMERIC(11, 2)
    );

   SET @Ls_Sql_TEXT = 'INSERT #Temp3_P1';
   SET @Ls_SqlData_TEXT = '';

   INSERT #Temp3_P1
          (MemberMci_IDNO,
           Case_IDNO,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT)
   SELECT A.MemberMci_IDNO,
          A.Case_IDNO,
          SUM(A.TanfArrear_AMNT) AS TanfArrear_AMNT,
          SUM(A.NonTanfArrear_AMNT) AS NonTanfArrear_AMNT
     FROM #Temp2_P1 A,
          #GetEligibleCases_P1 B
    WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
      AND B.Case_IDNO = A.Case_IDNO
    GROUP BY A.MemberMci_IDNO,
             A.Case_IDNO
   UNION
   SELECT A.MemberMci_IDNO,
          A.Case_IDNO,
          @Ln_Zero_NUMB AS TanfArrear_AMNT,
          @Ln_Zero_NUMB AS NonTanfArrear_AMNT
     FROM #GetEligibleCases_P1 A
    WHERE NOT EXISTS (SELECT 1
                        FROM #Temp2_P1 X
                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                         AND X.Case_IDNO = A.Case_IDNO)
    GROUP BY A.MemberMci_IDNO,
             A.Case_IDNO
    ORDER BY A.MemberMci_IDNO,
             A.Case_IDNO;

   SET @Ls_Sql_TEXT = 'UPDATE #Temp3_P1';
   SET @Ls_SqlData_TEXT = '';

   UPDATE #Temp3_P1
      SET TanfArrear_AMNT = 0
    WHERE TanfArrear_AMNT < 0;

   SET @Ls_SqlData_TEXT = '';

   UPDATE #Temp3_P1
      SET NonTanfArrear_AMNT = 0
    WHERE NonTanfArrear_AMNT < 0;

   SET @Ls_Sql_TEXT = 'CREATE #Temp4_P1';

   CREATE TABLE #Temp4_P1
    (
      MemberMci_IDNO            NUMERIC(10),
      Case_IDNO                 NUMERIC(06),
      TanfArrear_AMNT           NUMERIC(11, 2),
      NonTanfArrear_AMNT        NUMERIC(11, 2),
      NonTanfManualExclude_INDC CHAR(01),
      TanfManualExclude_INDC    CHAR(01),
      NonTanfCertified_INDC     CHAR(01),
      TanfCertified_INDC        CHAR(01),
      Notice_DATE               DATE
    );

   SET @Ls_Sql_TEXT = 'INSERT #Temp4_P1';
   SET @Ls_SqlData_TEXT = '';

   INSERT #Temp4_P1
          (MemberMci_IDNO,
           Case_IDNO,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           NonTanfManualExclude_INDC,
           TanfManualExclude_INDC,
           NonTanfCertified_INDC,
           TanfCertified_INDC,
           Notice_DATE)
   SELECT A.MemberMci_IDNO,
          A.Case_IDNO,
          A.TanfArrear_AMNT,
          A.NonTanfArrear_AMNT,
          'N' AS NonTanfManualExclude_INDC,
          'N' AS TanfManualExclude_INDC,
          ISNULL((SELECT TOP 1 'Y'
                    FROM ISTX_Y1 B
                   WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.Case_IDNO = A.Case_IDNO
                     AND B.TypeArrear_CODE = 'N'
                     AND B.TypeTransaction_CODE IN ('I', 'C')
                     AND B.SubmitLast_DATE = (SELECT TOP 1 MAX(C.SubmitLast_DATE)
                                                FROM ISTX_Y1 C
                                               WHERE C.MemberMci_IDNO = B.MemberMci_IDNO
                                                 AND C.Case_IDNO = B.Case_IDNO
                                                 AND C.TypeArrear_CODE = B.TypeArrear_CODE)), 'N') AS NonTanfCertified_INDC,
          ISNULL((SELECT TOP 1 'Y'
                    FROM ISTX_Y1 B
                   WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.Case_IDNO = A.Case_IDNO
                     AND B.TypeArrear_CODE = 'A'
                     AND B.TypeTransaction_CODE IN ('I', 'C')
                     AND B.SubmitLast_DATE = (SELECT TOP 1 MAX(C.SubmitLast_DATE)
                                                FROM ISTX_Y1 C
                                               WHERE C.MemberMci_IDNO = B.MemberMci_IDNO
                                                 AND C.Case_IDNO = B.Case_IDNO
                                                 AND C.TypeArrear_CODE = B.TypeArrear_CODE)), 'N') AS TanfCertified_INDC,
          @Ld_High_DATE AS Notice_DATE
     FROM #Temp3_P1 A
    ORDER BY A.MemberMci_IDNO,
             A.Case_IDNO;

   DECLARE @Ln_Enf26GenDtCur_MemberMci_IDNO NUMERIC(10),
           @Ln_Enf26GenDtCur_Case_IDNO      NUMERIC(6)
   DECLARE Enf26GenDt_CUR INSENSITIVE CURSOR FOR
    SELECT A.MemberMci_IDNO,
           A.Case_IDNO
      FROM #Temp4_P1 A
     ORDER BY A.MemberMci_IDNO,
              A.Case_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN Enf26GenDt_CUR';

   OPEN Enf26GenDt_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Enf26GenDt_CUR - 1';

   FETCH NEXT FROM Enf26GenDt_CUR INTO @Ln_Enf26GenDtCur_MemberMci_IDNO, @Ln_Enf26GenDtCur_Case_IDNO

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'CHECK AND SET MANUAL EXCLUSION INDICATOR';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_Enf26GenDtCur_MemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_Enf26GenDtCur_Case_IDNO AS VARCHAR)

     UPDATE A
        SET A.NonTanfManualExclude_INDC = 'Y',
            A.TanfManualExclude_INDC = 'Y'
       FROM #Temp4_P1 A
      WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
        AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
        AND EXISTS (SELECT 1
                      FROM TEXC_Y1 X
                     WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                       AND X.Case_IDNO = A.Case_IDNO
                       AND X.EndValidity_DATE = '12/31/9999'
                       AND @Ld_Run_DATE BETWEEN X.Effective_DATE AND X.End_DATE
                       AND X.ExcludeState_CODE = 'Y')

     SET @Ls_Sql_TEXT = 'CHECK AND SET NOTICE LAST GENERATED DATE';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_Enf26GenDtCur_MemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_Enf26GenDtCur_Case_IDNO AS VARCHAR)

     IF NOT EXISTS(SELECT 1
                     FROM ISTX_Y1 A
                    WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                      AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      AND A.WorkerUpdate_ID <> 'CONVERSION')
      BEGIN
       SET @Ls_Sql_TEXT = 'ONLY CONVERSION RECORD';
       SET @Ls_SqlData_TEXT = '';

       IF NOT EXISTS(SELECT 1
                       FROM ISTX_Y1 A
                      WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                        AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                        AND A.TypeTransaction_CODE = 'L'
                        AND A.WorkerUpdate_ID = 'CONVERSION')
        BEGIN
         UPDATE #Temp4_P1
            SET Notice_DATE = ISNULL((SELECT TOP 1 MIN(A.SubmitLast_DATE)
                                        FROM ISTX_Y1 A
                                       WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                         AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                         AND A.WorkerUpdate_ID = 'CONVERSION'), '12/31/9999')
          WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
            AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
        END
       ELSE
        BEGIN
         UPDATE A
            SET A.Notice_DATE = ISNULL((SELECT TOP 1 MAX(A.SubmitLast_DATE)
                                          FROM ISTX_Y1 A
                                         WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                           AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                           AND A.TypeTransaction_CODE = 'L'
                                           AND A.WorkerUpdate_ID = 'CONVERSION'), '12/31/9999'),
                A.NonTanfCertified_INDC = ISNULL((SELECT TOP 1 'Y'
                                                    FROM ISTX_Y1 B
                                                   WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                     AND B.Case_IDNO = A.Case_IDNO
                                                     AND B.TypeArrear_CODE = 'N'
                                                     AND B.TypeTransaction_CODE IN ('I', 'C')
                                                     AND B.WorkerUpdate_ID = 'CONVERSION'), 'N'),
                A.TanfCertified_INDC = ISNULL((SELECT TOP 1 'Y'
                                                 FROM ISTX_Y1 B
                                                WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                  AND B.Case_IDNO = A.Case_IDNO
                                                  AND B.TypeArrear_CODE = 'A'
                                                  AND B.TypeTransaction_CODE IN ('I', 'C')
                                                  AND B.WorkerUpdate_ID = 'CONVERSION'), 'N')
           FROM #Temp4_P1 A
          WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
            AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
        END
      END
     ELSE
      BEGIN
       SELECT @Ld_SubmitLastA_DATE = @Ld_Low_DATE,
              @Ld_SubmitLastN_DATE = @Ld_Low_DATE,
              @Lc_TypeTransactionA_CODE = '',
              @Lc_TypeTransactionN_CODE = '',
              @Ld_LastNoticeSubmitLastA_DATE = @Ld_Low_DATE,
              @Ld_LastNoticeSubmitLastN_DATE = @Ld_Low_DATE,
              @Ld_PrevLastNoticeSubmitLastA_DATE = @Ld_Low_DATE,
              @Ld_PrevLastNoticeSubmitLastN_DATE = @Ld_Low_DATE,
              @Lc_PrevTypeTransactionA_CODE = '',
              @Lc_PrevTypeTransactionN_CODE = '';

       SELECT @Ld_SubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                               FROM ISTX_Y1 X
                                              WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                AND X.TypeArrear_CODE = 'A'), '12/31/9999')

       SELECT @Ld_SubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                               FROM ISTX_Y1 X
                                              WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                AND X.TypeArrear_CODE = 'N'), '12/31/9999')

       SELECT @Lc_TypeTransactionA_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                    FROM ISTX_Y1 A
                                                   WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                     AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                     AND A.TypeArrear_CODE = 'A'
                                                     AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                FROM ISTX_Y1 X
                                                                               WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                 AND X.Case_IDNO = A.Case_IDNO
                                                                                 AND X.TypeArrear_CODE = 'A')), '')

       SELECT @Lc_TypeTransactionN_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                    FROM ISTX_Y1 A
                                                   WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                     AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                     AND A.TypeArrear_CODE = 'N'
                                                     AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                FROM ISTX_Y1 X
                                                                               WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                 AND X.Case_IDNO = A.Case_IDNO
                                                                                 AND X.TypeArrear_CODE = 'N')), '')

       IF @Lc_TypeTransactionA_CODE IN ('D', '')
          AND @Lc_TypeTransactionN_CODE IN ('D', '')
        BEGIN
         SET @Ls_Sql_TEXT = 'ALL ARREAR TYPES FOR THE CASE BECAME D';
         SET @Ls_SqlData_TEXT = '';

         UPDATE #Temp4_P1
            SET Notice_DATE = '12/31/9999'
          WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
            AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
        END
       ELSE IF NOT EXISTS(SELECT 1
                       FROM ISTX_Y1 A
                      WHERE A.TypeTransaction_CODE = 'L'
                        AND A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                        AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO)
        BEGIN
         SET @Ls_Sql_TEXT = 'NO L RECORD';
         SET @Ls_SqlData_TEXT = '';

         UPDATE #Temp4_P1
            SET Notice_DATE = ISNULL((SELECT TOP 1 MIN(A.SubmitLast_DATE)
                                        FROM ISTX_Y1 A
                                       WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                         AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO), '12/31/9999')
          WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
            AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
        END
       ELSE IF @Lc_TypeTransactionA_CODE = 'L'
          AND @Lc_TypeTransactionN_CODE = 'L'
        BEGIN
         SET @Ls_Sql_TEXT = 'BOTH ARREAR TYPES ARE L';
         SET @Ls_SqlData_TEXT = '';

         IF @Lc_TypeTransactionA_CODE = 'L'
          BEGIN
           SELECT @Ld_PrevLastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'A'
                                                                  AND X.TypeTransaction_CODE = 'L'
                                                                  AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastA_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
            BEGIN
             SELECT @Ld_PrevLastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                                   FROM ISTX_Y1 X
                                                                  WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                    AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                    AND X.TypeArrear_CODE = 'A'
                                                                    AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')
            END

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastA_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
              AND NOT EXISTS(SELECT 1
                               FROM ISTX_Y1 A
                              WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                AND A.TypeArrear_CODE = 'A'
                                AND A.TypeTransaction_CODE = 'D'
                                AND A.SubmitLast_DATE BETWEEN @Ld_PrevLastNoticeSubmitLastA_DATE AND @Ld_SubmitLastA_DATE)
              AND DATEDIFF(D, @Ld_PrevLastNoticeSubmitLastA_DATE, @Ld_SubmitLastA_DATE) >= 365
            BEGIN
             SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR A RECORD WHEN BOTH ARREAR TYPES ARE L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET TanfCertified_INDC = 'Y',
                    NonTanfCertified_INDC = 'Y'
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
          END

         IF @Lc_TypeTransactionN_CODE = 'L'
          BEGIN
           SELECT @Ld_PrevLastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'N'
                                                                  AND X.TypeTransaction_CODE = 'L'
                                                                  AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastN_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
            BEGIN
             SELECT @Ld_PrevLastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                                   FROM ISTX_Y1 X
                                                                  WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                    AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                    AND X.TypeArrear_CODE = 'N'
                                                                    AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')
            END

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastN_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
              AND NOT EXISTS(SELECT 1
                               FROM ISTX_Y1 A
                              WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                AND A.TypeArrear_CODE = 'N'
                                AND A.TypeTransaction_CODE = 'D'
                                AND A.SubmitLast_DATE BETWEEN @Ld_PrevLastNoticeSubmitLastN_DATE AND @Ld_SubmitLastN_DATE)
              AND DATEDIFF(D, @Ld_PrevLastNoticeSubmitLastN_DATE, @Ld_SubmitLastN_DATE) >= 365
            BEGIN
             SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR N RECORD WHEN BOTH ARREAR TYPES ARE L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET NonTanfCertified_INDC = 'Y',
                    TanfCertified_INDC = 'Y'
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
          END

         IF @Ld_SubmitLastA_DATE <> '12/31/9999'
            AND @Ld_SubmitLastN_DATE = '12/31/9999'
          BEGIN
           UPDATE #Temp4_P1
              SET Notice_DATE = @Ld_SubmitLastA_DATE
            WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
              AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
          END
         ELSE IF @Ld_SubmitLastN_DATE <> '12/31/9999'
            AND @Ld_SubmitLastA_DATE = '12/31/9999'
          BEGIN
           UPDATE #Temp4_P1
              SET Notice_DATE = @Ld_SubmitLastN_DATE
            WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
              AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
          END
         ELSE IF @Ld_SubmitLastA_DATE <> '12/31/9999'
            AND @Ld_SubmitLastN_DATE <> '12/31/9999'
          BEGIN
           IF @Ld_SubmitLastA_DATE > @Ld_SubmitLastN_DATE
              AND DATEDIFF(D, @Ld_SubmitLastN_DATE, @Ld_SubmitLastA_DATE) < 365
              AND EXISTS (SELECT 1
                            FROM ISTX_Y1 A
                           WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                             AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                             AND A.TypeTransaction_CODE = 'D'
                             AND A.TypeArrear_CODE = 'N'
                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                        FROM ISTX_Y1 B
                                                       WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                         AND B.Case_IDNO = A.Case_IDNO
                                                         AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                         AND B.SubmitLast_DATE BETWEEN @Ld_SubmitLastN_DATE AND @Ld_SubmitLastA_DATE))
            BEGIN
             SET @Ls_Sql_TEXT = 'N RECORD DELETED WHEN NOTICE LAST SENT FOR A RECORD WHEN BOTH ARREAR TYPES ARE L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET Notice_DATE = @Ld_SubmitLastA_DATE
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
           ELSE IF @Ld_SubmitLastN_DATE > @Ld_SubmitLastA_DATE
              AND DATEDIFF(D, @Ld_SubmitLastA_DATE, @Ld_SubmitLastN_DATE) < 365
              AND EXISTS (SELECT 1
                            FROM ISTX_Y1 A
                           WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                             AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                             AND A.TypeTransaction_CODE = 'D'
                             AND A.TypeArrear_CODE = 'A'
                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                        FROM ISTX_Y1 B
                                                       WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                         AND B.Case_IDNO = A.Case_IDNO
                                                         AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                         AND B.SubmitLast_DATE BETWEEN @Ld_SubmitLastA_DATE AND @Ld_SubmitLastN_DATE))
            BEGIN
             SET @Ls_Sql_TEXT = 'A RECORD DELETED WHEN NOTICE LAST SENT FOR N RECORD WHEN BOTH ARREAR TYPES ARE L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET Notice_DATE = @Ld_SubmitLastN_DATE
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
           ELSE
            BEGIN
             IF @Ld_SubmitLastA_DATE >= @Ld_SubmitLastN_DATE
              BEGIN
               IF DATEDIFF(D, @Ld_SubmitLastN_DATE, @Ld_SubmitLastA_DATE) >= 365
                BEGIN
                 SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN BOTH ARREAR TYPES ARE L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET NonTanfCertified_INDC = 'Y',
                        TanfCertified_INDC = 'Y',
                        Notice_DATE = @Ld_SubmitLastA_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE
                BEGIN
                 SET @Ls_Sql_TEXT = 'N RECORD HAS LESS DATE WHEN BOTH ARREAR TYPES ARE L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_SubmitLastN_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
              END
             ELSE IF @Ld_SubmitLastN_DATE >= @Ld_SubmitLastA_DATE
              BEGIN
               IF DATEDIFF(D, @Ld_SubmitLastA_DATE, @Ld_SubmitLastN_DATE) >= 365
                BEGIN
                 SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN BOTH ARREAR TYPES ARE L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET NonTanfCertified_INDC = 'Y',
                        TanfCertified_INDC = 'Y',
                        Notice_DATE = @Ld_SubmitLastN_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE
                BEGIN
                 SET @Ls_Sql_TEXT = 'A RECORD HAS LESS DATE WHEN BOTH ARREAR TYPES ARE L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_SubmitLastA_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
              END
            END
          END
        END
       ELSE IF @Lc_TypeTransactionA_CODE <> 'L'
          AND @Lc_TypeTransactionN_CODE <> 'L'
        BEGIN
         SET @Ls_Sql_TEXT = 'BOTH ARREAR TYPES ARE <> L';
         SET @Ls_SqlData_TEXT = '';

         SELECT @Ld_LastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                           FROM ISTX_Y1 X
                                                          WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                            AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                            AND X.TypeArrear_CODE = 'A'
                                                            AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

         SELECT @Ld_LastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                           FROM ISTX_Y1 X
                                                          WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                            AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                            AND X.TypeArrear_CODE = 'N'
                                                            AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

         IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
            AND @Ld_LastNoticeSubmitLastN_DATE = '12/31/9999'
          BEGIN
           UPDATE #Temp4_P1
              SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
            WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
              AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
          END
         ELSE IF @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
            AND @Ld_LastNoticeSubmitLastA_DATE = '12/31/9999'
          BEGIN
           UPDATE #Temp4_P1
              SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
            WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
              AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
          END
         ELSE IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
            AND @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
          BEGIN
           IF @Ld_LastNoticeSubmitLastA_DATE > @Ld_LastNoticeSubmitLastN_DATE
              AND DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) < 365
              AND EXISTS (SELECT 1
                            FROM ISTX_Y1 A
                           WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                             AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                             AND A.TypeTransaction_CODE = 'D'
                             AND A.TypeArrear_CODE = 'N'
                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                        FROM ISTX_Y1 B
                                                       WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                         AND B.Case_IDNO = A.Case_IDNO
                                                         AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                         AND B.SubmitLast_DATE BETWEEN @Ld_LastNoticeSubmitLastN_DATE AND @Ld_LastNoticeSubmitLastA_DATE))
            BEGIN
             SET @Ls_Sql_TEXT = 'N RECORD DELETED WHEN NOTICE LAST SENT FOR A RECORD WHEN BOTH ARREAR TYPES ARE <> L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
           ELSE IF @Ld_LastNoticeSubmitLastN_DATE > @Ld_LastNoticeSubmitLastA_DATE
              AND DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) < 365
              AND EXISTS (SELECT 1
                            FROM ISTX_Y1 A
                           WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                             AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                             AND A.TypeTransaction_CODE = 'D'
                             AND A.TypeArrear_CODE = 'A'
                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                        FROM ISTX_Y1 B
                                                       WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                         AND B.Case_IDNO = A.Case_IDNO
                                                         AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                         AND B.SubmitLast_DATE BETWEEN @Ld_LastNoticeSubmitLastA_DATE AND @Ld_LastNoticeSubmitLastN_DATE))
            BEGIN
             SET @Ls_Sql_TEXT = 'A RECORD DELETED WHEN NOTICE LAST SENT FOR N RECORD WHEN BOTH ARREAR TYPES ARE <> L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
           ELSE
            BEGIN
             IF @Ld_LastNoticeSubmitLastA_DATE >= @Ld_LastNoticeSubmitLastN_DATE
              BEGIN
               IF DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) >= 365
                BEGIN
                 SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN BOTH ARREAR TYPES ARE <> L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET NonTanfCertified_INDC = 'Y',
                        TanfCertified_INDC = 'Y',
                        Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE
                BEGIN
                 SET @Ls_Sql_TEXT = 'N RECORD HAS LESS DATE WHEN BOTH ARREAR TYPES ARE <> L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
              END
             ELSE IF @Ld_LastNoticeSubmitLastN_DATE >= @Ld_LastNoticeSubmitLastA_DATE
              BEGIN
               IF DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) >= 365
                BEGIN
                 SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN BOTH ARREAR TYPES ARE <> L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET NonTanfCertified_INDC = 'Y',
                        TanfCertified_INDC = 'Y',
                        Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE
                BEGIN
                 SET @Ls_Sql_TEXT = 'A RECORD HAS LESS DATE WHEN BOTH ARREAR TYPES ARE <> L';
                 SET @Ls_SqlData_TEXT = '';

                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
              END
            END
          END
        END
       ELSE IF @Lc_TypeTransactionA_CODE = 'L'
           OR @Lc_TypeTransactionN_CODE = 'L'
        BEGIN
         SET @Ls_Sql_TEXT = 'ONLY 1 ARREAR TYPE IS L';
         SET @Ls_SqlData_TEXT = '';

         IF @Lc_TypeTransactionA_CODE = 'L'
          BEGIN
           SELECT @Ld_PrevLastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'A'
                                                                  AND X.TypeTransaction_CODE = 'L'
                                                                  AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastA_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
            BEGIN
             SELECT @Ld_PrevLastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                                   FROM ISTX_Y1 X
                                                                  WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                    AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                    AND X.TypeArrear_CODE = 'A'
                                                                    AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')
            END

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastA_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
              AND NOT EXISTS(SELECT 1
                               FROM ISTX_Y1 A
                              WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                AND A.TypeArrear_CODE = 'A'
                                AND A.TypeTransaction_CODE = 'D'
                                AND A.SubmitLast_DATE BETWEEN @Ld_PrevLastNoticeSubmitLastA_DATE AND @Ld_SubmitLastA_DATE)
              AND DATEDIFF(D, @Ld_PrevLastNoticeSubmitLastA_DATE, @Ld_SubmitLastA_DATE) >= 365
            BEGIN
             SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR A RECORD WHEN ONLY 1 ARREAR TYPE IS L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET TanfCertified_INDC = 'Y',
                    Notice_DATE = @Ld_SubmitLastA_DATE
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
           ELSE
            BEGIN
             SELECT @Lc_PrevTypeTransactionA_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                              FROM ISTX_Y1 A
                                                             WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                               AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                               AND A.TypeArrear_CODE = 'A'
                                                               AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                          FROM ISTX_Y1 X
                                                                                         WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                           AND X.Case_IDNO = A.Case_IDNO
                                                                                           AND X.TypeArrear_CODE = 'A'
                                                                                           AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE)), '')

             SELECT @Lc_PrevTypeTransactionN_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                              FROM ISTX_Y1 A
                                                             WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                               AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                               AND A.TypeArrear_CODE = 'N'
                                                               AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                          FROM ISTX_Y1 X
                                                                                         WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                           AND X.Case_IDNO = A.Case_IDNO
                                                                                           AND X.TypeArrear_CODE = 'N'
                                                                                           AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE)), '')

             IF @Lc_PrevTypeTransactionA_CODE IN ('D', '')
                AND @Lc_PrevTypeTransactionN_CODE IN ('D', '')
              BEGIN
               SET @Ls_Sql_TEXT = 'ALL ARREAR TYPES FOR THE CASE BECAME D WHEN ONLY A RECORD IS L';
               SET @Ls_SqlData_TEXT = '';

               UPDATE #Temp4_P1
                  SET Notice_DATE = @Ld_SubmitLastA_DATE
                WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                  AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
              END
             ELSE
              BEGIN
               SELECT @Ld_LastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'A'
                                                                  AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

               SELECT @Ld_LastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'N'
                                                                  AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

               IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
                  AND @Ld_LastNoticeSubmitLastN_DATE = '12/31/9999'
                BEGIN
                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE IF @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
                  AND @Ld_LastNoticeSubmitLastA_DATE = '12/31/9999'
                BEGIN
                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
                  AND @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
                BEGIN
                 IF @Ld_LastNoticeSubmitLastA_DATE > @Ld_LastNoticeSubmitLastN_DATE
                    AND DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) < 365
                    AND EXISTS (SELECT 1
                                  FROM ISTX_Y1 A
                                 WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                   AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                   AND A.TypeTransaction_CODE = 'D'
                                   AND A.TypeArrear_CODE = 'N'
                                   AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                              FROM ISTX_Y1 B
                                                             WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                               AND B.Case_IDNO = A.Case_IDNO
                                                               AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                               AND B.SubmitLast_DATE BETWEEN @Ld_LastNoticeSubmitLastN_DATE AND @Ld_LastNoticeSubmitLastA_DATE))
                  BEGIN
                   SET @Ls_Sql_TEXT = 'N RECORD DELETED WHEN NOTICE LAST SENT FOR A RECORD WHEN ONLY A RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   UPDATE #Temp4_P1
                      SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                    WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                      AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                  END
                 ELSE IF @Ld_LastNoticeSubmitLastN_DATE > @Ld_LastNoticeSubmitLastA_DATE
                    AND DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) < 365
                    AND EXISTS (SELECT 1
                                  FROM ISTX_Y1 A
                                 WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                   AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                   AND A.TypeTransaction_CODE = 'D'
                                   AND A.TypeArrear_CODE = 'A'
                                   AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                              FROM ISTX_Y1 B
                                                             WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                               AND B.Case_IDNO = A.Case_IDNO
                                                               AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                               AND B.SubmitLast_DATE BETWEEN @Ld_LastNoticeSubmitLastA_DATE AND @Ld_LastNoticeSubmitLastN_DATE))
                  BEGIN
                   SET @Ls_Sql_TEXT = 'A RECORD DELETED WHEN NOTICE LAST SENT FOR N RECORD WHEN ONLY A RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   UPDATE #Temp4_P1
                      SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                    WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                      AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                  END
                 ELSE
                  BEGIN
                   IF @Ld_LastNoticeSubmitLastA_DATE >= @Ld_LastNoticeSubmitLastN_DATE
                    BEGIN
                     IF DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) >= 365
                      BEGIN
                       SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN ONLY A RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET TanfCertified_INDC = 'Y',
                              Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                     ELSE
                      BEGIN
                       SET @Ls_Sql_TEXT = 'N RECORD HAS LESS DATE WHEN ONLY A RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                    END
                   ELSE IF @Ld_LastNoticeSubmitLastN_DATE >= @Ld_LastNoticeSubmitLastA_DATE
                    BEGIN
                     IF DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) >= 365
                      BEGIN
                       SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN ONLY A RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET NonTanfCertified_INDC = 'Y',
                              Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                     ELSE
                      BEGIN
                       SET @Ls_Sql_TEXT = 'A RECORD HAS LESS DATE WHEN ONLY A RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                    END
                  END
                END
              END
            END
          END
         ELSE IF @Lc_TypeTransactionN_CODE = 'L'
          BEGIN
           SELECT @Ld_PrevLastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'N'
                                                                  AND X.TypeTransaction_CODE = 'L'
                                                                  AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastN_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
            BEGIN
             SELECT @Ld_PrevLastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                                   FROM ISTX_Y1 X
                                                                  WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                    AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                    AND X.TypeArrear_CODE = 'N'
                                                                    AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')
            END

           IF ISNULL(@Ld_PrevLastNoticeSubmitLastN_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
              AND NOT EXISTS(SELECT 1
                               FROM ISTX_Y1 A
                              WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                AND A.TypeArrear_CODE = 'N'
                                AND A.TypeTransaction_CODE = 'D'
                                AND A.SubmitLast_DATE BETWEEN @Ld_PrevLastNoticeSubmitLastN_DATE AND @Ld_SubmitLastN_DATE)
              AND DATEDIFF(D, @Ld_PrevLastNoticeSubmitLastN_DATE, @Ld_SubmitLastN_DATE) >= 365
            BEGIN
             SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR N RECORD WHEN ONLY 1 ARREAR TYPE IS L';
             SET @Ls_SqlData_TEXT = '';

             UPDATE #Temp4_P1
                SET NonTanfCertified_INDC = 'Y',
                    Notice_DATE = @Ld_SubmitLastN_DATE
              WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
            END
           ELSE
            BEGIN
             SELECT @Lc_PrevTypeTransactionA_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                              FROM ISTX_Y1 A
                                                             WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                               AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                               AND A.TypeArrear_CODE = 'A'
                                                               AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                          FROM ISTX_Y1 X
                                                                                         WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                           AND X.Case_IDNO = A.Case_IDNO
                                                                                           AND X.TypeArrear_CODE = 'A'
                                                                                           AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE)), '')

             SELECT @Lc_PrevTypeTransactionN_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                              FROM ISTX_Y1 A
                                                             WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                               AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                               AND A.TypeArrear_CODE = 'N'
                                                               AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                          FROM ISTX_Y1 X
                                                                                         WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                           AND X.Case_IDNO = A.Case_IDNO
                                                                                           AND X.TypeArrear_CODE = 'N'
                                                                                           AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE)), '')

             IF @Lc_PrevTypeTransactionA_CODE IN ('D', '')
                AND @Lc_PrevTypeTransactionN_CODE IN ('D', '')
              BEGIN
               SET @Ls_Sql_TEXT = 'ALL ARREAR TYPES FOR THE CASE BECAME D WHEN ONLY N RECORD IS L';
               SET @Ls_SqlData_TEXT = '';

               UPDATE #Temp4_P1
                  SET Notice_DATE = @Ld_SubmitLastN_DATE
                WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                  AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
              END
             ELSE
              BEGIN
               SELECT @Ld_LastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'A'
                                                                  AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

               SELECT @Ld_LastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                 FROM ISTX_Y1 X
                                                                WHERE X.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                                                  AND X.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                                                  AND X.TypeArrear_CODE = 'N'
                                                                  AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

               IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
                  AND @Ld_LastNoticeSubmitLastN_DATE = '12/31/9999'
                BEGIN
                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE IF @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
                  AND @Ld_LastNoticeSubmitLastA_DATE = '12/31/9999'
                BEGIN
                 UPDATE #Temp4_P1
                    SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                  WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                    AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                END
               ELSE IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
                  AND @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
                BEGIN
                 IF @Ld_LastNoticeSubmitLastA_DATE > @Ld_LastNoticeSubmitLastN_DATE
                    AND DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) < 365
                    AND EXISTS (SELECT 1
                                  FROM ISTX_Y1 A
                                 WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                   AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                   AND A.TypeTransaction_CODE = 'D'
                                   AND A.TypeArrear_CODE = 'N'
                                   AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                              FROM ISTX_Y1 B
                                                             WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                               AND B.Case_IDNO = A.Case_IDNO
                                                               AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                               AND B.SubmitLast_DATE BETWEEN @Ld_LastNoticeSubmitLastN_DATE AND @Ld_LastNoticeSubmitLastA_DATE))
                  BEGIN
                   SET @Ls_Sql_TEXT = 'N RECORD DELETED WHEN NOTICE LAST SENT FOR A RECORD WHEN ONLY N RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   UPDATE #Temp4_P1
                      SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                    WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                      AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                  END
                 ELSE IF @Ld_LastNoticeSubmitLastN_DATE > @Ld_LastNoticeSubmitLastA_DATE
                    AND DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) < 365
                    AND EXISTS (SELECT 1
                                  FROM ISTX_Y1 A
                                 WHERE A.MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                                   AND A.Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                                   AND A.TypeTransaction_CODE = 'D'
                                   AND A.TypeArrear_CODE = 'A'
                                   AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(B.SubmitLast_DATE)
                                                              FROM ISTX_Y1 B
                                                             WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                                                               AND B.Case_IDNO = A.Case_IDNO
                                                               AND B.TypeArrear_CODE = A.TypeArrear_CODE
                                                               AND B.SubmitLast_DATE BETWEEN @Ld_LastNoticeSubmitLastA_DATE AND @Ld_LastNoticeSubmitLastN_DATE))
                  BEGIN
                   SET @Ls_Sql_TEXT = 'A RECORD DELETED WHEN NOTICE LAST SENT FOR N RECORD WHEN ONLY N RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   UPDATE #Temp4_P1
                      SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                    WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                      AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                  END
                 ELSE
                  BEGIN
                   IF @Ld_LastNoticeSubmitLastA_DATE >= @Ld_LastNoticeSubmitLastN_DATE
                    BEGIN
                     IF DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) >= 365
                      BEGIN
                       SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN ONLY N RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET TanfCertified_INDC = 'Y',
                              Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                     ELSE
                      BEGIN
                       SET @Ls_Sql_TEXT = 'N RECORD HAS LESS DATE WHEN ONLY N RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                    END
                   ELSE IF @Ld_LastNoticeSubmitLastN_DATE >= @Ld_LastNoticeSubmitLastA_DATE
                    BEGIN
                     IF DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) >= 365
                      BEGIN
                       SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN ONLY N RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET NonTanfCertified_INDC = 'Y',
                              Notice_DATE = @Ld_LastNoticeSubmitLastN_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                     ELSE
                      BEGIN
                       SET @Ls_Sql_TEXT = 'A RECORD HAS LESS DATE WHEN ONLY N RECORD IS L';
                       SET @Ls_SqlData_TEXT = '';

                       UPDATE #Temp4_P1
                          SET Notice_DATE = @Ld_LastNoticeSubmitLastA_DATE
                        WHERE MemberMci_IDNO = @Ln_Enf26GenDtCur_MemberMci_IDNO
                          AND Case_IDNO = @Ln_Enf26GenDtCur_Case_IDNO
                      END
                    END
                  END
                END
              END
            END
          END
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CURSOR Enf26GenDt_CUR - 2';

     FETCH NEXT FROM Enf26GenDt_CUR INTO @Ln_Enf26GenDtCur_MemberMci_IDNO, @Ln_Enf26GenDtCur_Case_IDNO

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Enf26GenDt_CUR';

   CLOSE Enf26GenDt_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Enf26GenDt_CUR';

   DEALLOCATE Enf26GenDt_CUR;

   SET @Ls_Sql_TEXT = 'UPDATE #Temp4_P1';
   SET @Ls_SqlData_TEXT = 'TanfManualExclude_INDC = ' + ISNULL('Y', '');

   UPDATE #Temp4_P1
      SET TanfArrear_AMNT = 0
    WHERE TanfManualExclude_INDC = 'Y';

   SET @Ls_SqlData_TEXT = 'NonTanfManualExclude_INDC = ' + ISNULL('Y', '');

   UPDATE #Temp4_P1
      SET NonTanfArrear_AMNT = 0
    WHERE NonTanfManualExclude_INDC = 'Y';

   SET @Ls_Sql_TEXT = 'UPDATE #Temp4_P1';
   SET @Ls_SqlData_TEXT = '';

   UPDATE #Temp4_P1
      SET TanfArrear_AMNT = 0,
          NonTanfArrear_AMNT = 0
     FROM #Temp4_P1 A
    WHERE A.TanfCertified_INDC = 'N'
      AND A.NonTanfCertified_INDC = 'N'
      AND ((A.TanfArrear_AMNT + A.NonTanfArrear_AMNT) < 150
            OR ((A.TanfArrear_AMNT + A.NonTanfArrear_AMNT) < dbo.BATCH_COMMON$SF_GET_OBLIGATION_AMT(A.Case_IDNO, @Ld_Run_DATE)
                 OR EXISTS (SELECT 1
                              FROM SORD_Y1 X
                             WHERE X.Case_IDNO = A.Case_IDNO
                               AND DATEDIFF(D, X.OrderIssued_DATE, @Ld_Run_DATE) < 45
                               AND X.EventGlobalBeginSeq_NUMB = (SELECT MIN(Y.EventGlobalBeginSeq_NUMB)
                                                                   FROM SORD_Y1 Y
                                                                  WHERE Y.Case_IDNO = X.Case_IDNO
                                                                    AND Y.EndValidity_DATE = @Ld_High_DATE)
                               AND X.EndValidity_DATE = @Ld_High_DATE)));

   SET @Ls_Sql_TEXT = 'INSERT #CalculateCaseArrears_P1';
   SET @Ls_SqlData_TEXT = 'Create_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   INSERT #CalculateCaseArrears_P1
          (MemberMci_IDNO,
           Case_IDNO,
           TanfArrear_AMNT,
           NonTanfArrear_AMNT,
           NonTanfManualExclude_INDC,
           TanfManualExclude_INDC,
           NonTanfCertified_INDC,
           TanfCertified_INDC,
           Notice_DATE,
           Create_DATE)
   SELECT A.MemberMci_IDNO,
          A.Case_IDNO,
          A.TanfArrear_AMNT,
          A.NonTanfArrear_AMNT,
          A.NonTanfManualExclude_INDC,
          A.TanfManualExclude_INDC,
          A.NonTanfCertified_INDC,
          A.TanfCertified_INDC,
          A.Notice_DATE,
          @Ld_Run_DATE AS Create_DATE
     FROM #Temp4_P1 A
    ORDER BY A.MemberMci_IDNO,
             A.Case_IDNO;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END;

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
 END;


GO
