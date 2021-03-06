/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT
Programmer Name		: IMP Team
Description			:
Frequency			:
Developed On		:	04/12/2011
Called By			:
Called On       	:
------------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No          :1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT]
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @An_CpMci_IDNO            NUMERIC(10),
 @An_DEBMemberMci_IDNO	   NUMERIC(10) = 0,
 @Ad_Start_DATE            DATE,
 @An_WelfareYearMonth_NUMB NUMERIC(6),
 @An_LtdExpend_AMNT        NUMERIC (11, 2) OUTPUT,
 @An_LtdRecoup_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_LtdUrg_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_MtdExpend_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_MtdRecoup_AMNT        NUMERIC(11, 2) OUTPUT,
 @An_MtdUrg_AMNT           NUMERIC(11, 2) OUTPUT,
 @Ad_Run_DATE              DATE,
 @Ac_Process_INDC          CHAR(1) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @PrtlTmp_P1 TABLE (
   PrDistribute_QNTY   NUMERIC(5) NOT NULL,
   PrArrToBePaid_AMNT  NUMERIC(11, 2),
   CumArrToBePaid_AMNT NUMERIC(11, 2),
   Case_IDNO           NUMERIC(6) NOT NULL );
  DECLARE @MembTmp_P1 TABLE (
   Case_IDNO         NUMERIC(6) NULL,
   MemberMci_IDNO    NUMERIC(10) NULL,
   MemberStatus_INDC CHAR(1) NULL,
   ArrExists_INDC    CHAR(1) NULL );
  DECLARE @PratTmp_P1 TABLE (
   PrDistribute_QNTY        NUMERIC(5) NULL,
   MemberMci_IDNO           NUMERIC(10) NULL,
   Case_IDNO                NUMERIC(6) NULL,
   OrderSeq_NUMB            NUMERIC(2) NULL,
   ObligationSeq_NUMB       NUMERIC(2) NULL,
   TypeBucket_CODE          CHAR(5) NULL,
   CaseWelfare_IDNO         NUMERIC(10) NULL,
   ArrToBePaid_AMNT         NUMERIC(11, 2),
   PerMemberProrated_AMNT   NUMERIC(11, 2),
   PerMemberRecoupment_AMNT NUMERIC(11, 2),
   MemberUnreimbGrant_AMNT  NUMERIC(11, 2));
  DECLARE @BumpCur_PrDistribute_QNTY NUMERIC (5, 0),
          @BumpCur_Pr_AMNT           NUMERIC (11, 2),
          @Ln_Row_QNTY               NUMERIC (5) = 0,
		  @Ln_MemberCur_QNTY         NUMERIC (5) = 0,
          @Ln_CurrentRow_NUMB        NUMERIC (5) = 1;
  DECLARE @Lc_StatusCaseMemberActive_INDC  CHAR(1) = 'A',
          @Lc_WelfareTypeTanf_CODE         CHAR (1) = 'A',
          @Lc_CaseRelationshipCp_CODE      CHAR (1) = 'C',
          @Lc_CaseRelationshipDp_CODE      CHAR (1) = 'D',
          @Lc_TypeDebtChildSupp_CODE       CHAR (2) = 'CS',
          @Lc_TypeDebtSpousalSupp_CODE     CHAR (2) = 'SS',
          @Lc_TypeDebtIntChildSupp_CODE    CHAR (2) = 'CI',
          @Lc_TypeDebtIntSpousalSupp_CODE  CHAR (2) = 'SI',
          @Lc_DeStateFips_CODE             CHAR (2) = '10',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Lc_DateFormatYyyymm_TEXT        CHAR(6) = 'YYYYMM',
          @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Lc_StatusReceiptRefunded_CODE   CHAR (1) = 'R',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_TypeBucketC_CODE             CHAR (7) = 'C',
          @Lc_TypeBucketApaa_CODE          CHAR (7) = 'APAA',
          @Lc_DebtInterest_CODE            CHAR (1) = 'I',
          @Lc_TypeBucketAtaa_CODE          CHAR (7) = 'ATAA',
          @Lc_TypeBucketAcaa_CODE          CHAR (7) = 'ACAA',
          @Lc_DebtSupport_CODE             CHAR (1) = 'S',
          @Ls_Sql_TEXT                     VARCHAR(100),
          @Ls_Sqldata_TEXT                 VARCHAR(1000),
          @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT',
          @Ln_Temp_NUMB                    NUMERIC (5, 0),
          @Ln_PerMemberOble_AMNT           NUMERIC (11, 2)= 0,
          @Ln_Oble_QNTY                    NUMERIC (2) = 0,
          @Ln_Adjust_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_PerRcpOble_AMNT              NUMERIC (11, 2) = 0,
          @Ln_AdjustRcp_AMNT               NUMERIC (11, 2) = 0,
          @Ln_Loop_QNTY                    NUMERIC (3) = 0,
          @Ln_TotArrears_AMNT              NUMERIC (11, 2),
          @Ln_Member_QNTY                  NUMERIC (3) = 0,
          @Ln_MemberMtd_QNTY               NUMERIC (3) = 0,
          @Ln_Diff_AMNT                    NUMERIC (11, 2) = 0,
          @Ln_Maxseq_NUMB                  NUMERIC (3) = 0,
          @Ln_UrgPerMemberOble_AMNT        NUMERIC (11, 2) = 0,
          @Ln_CentUrgMtd_AMNT              NUMERIC (11, 2)= 0,
          @Ln_Cum_AMNT                     NUMERIC (11, 2) = 0,
          @Ln_Val_AMNT                     NUMERIC (11, 2) = 0,
          @Ls_ErrorMessage_TEXT            VARCHAR(4000),
          @Ln_Error_NUMB                   NUMERIC(11),
          @Ln_ErrorLine_NUMB               NUMERIC(11),
          @Ln_MemberCur_Case_IDNO          NUMERIC(6),
          @Ln_MemberCur_OrderSeq_NUMB      NUMERIC(2),
          @Ln_MemberCur_ObligationSeq_NUMB NUMERIC(2),
          @Ln_MemberCur_CaseWelfare_IDNO   NUMERIC(10),
          @Ln_MemberCur_ArrToBePaid_AMNT   NUMERIC(11, 2);
  DECLARE @BumpCur_P1 TABLE (
   PrDistribute_QNTY NUMERIC(5) NOT NULL,
   Pr_AMNT           NUMERIC (11, 2) NOT NULL,
   Row_NUMB          NUMERIC (5) IDENTITY );
  DECLARE @MemberCur_P1 TABLE (
   Case_IDNO          NUMERIC(6) NOT NULL,
   OrderSeq_NUMB      NUMERIC(2) NOT NULL,
   ObligationSeq_NUMB NUMERIC(2) NOT NULL,
   CaseWelfare_IDNO   NUMERIC(10) NOT NULL,
   ArrToBePaid_AMNT   NUMERIC(11, 2) NOT NULL,
   Row_NUMB           NUMERIC (5) NOT NULL );

  BEGIN TRY
   SET @Ad_Run_DATE = ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Ac_Process_INDC = '';

   SELECT @Ac_Msg_CODE = '',
          @As_DescriptionError_TEXT = '',
          @Ls_Sql_TEXT = '',
          @Ls_Sqldata_TEXT = ''

   SET @Ls_Sql_TEXT = 'INSERT_TMP_MEMBER';
   SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO ' + ISNULL (CAST(@An_CaseWelfare_IDNO AS VARCHAR), '');



      
   INSERT INTO @MembTmp_P1
               (Case_IDNO,
                MemberMci_IDNO)
   SELECT DISTINCT
          b.Case_IDNO,
          b.MemberMci_IDNO
     FROM MHIS_Y1 AS b
    WHERE b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
      AND b.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
      AND ((@An_DEBMemberMci_IDNO = 0) OR (b.MemberMci_IDNO = @An_DEBMemberMci_IDNO))
      AND EXISTS (SELECT 1 AS expr
                    FROM CMEM_Y1 AS c,
                         CASE_Y1 AS d
                   WHERE b.Case_IDNO = c.Case_IDNO
                     AND b.MemberMci_IDNO = c.MemberMci_IDNO
                     AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipDp_CODE)
                     AND c.Case_IDNO = d.Case_IDNO)
      AND EXISTS (SELECT 1 AS expr
                    FROM IVMG_Y1 AS c,
                         CMEM_Y1 AS d
                   WHERE c.CpMci_IDNO = @An_CpMci_IDNO
                     AND c.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                     AND c.CpMci_IDNO = d.MemberMci_IDNO
                     AND d.CaseRelationship_CODE = 'C'
                     AND d.Case_IDNO = b.Case_IDNO)
      AND EXISTS (SELECT 1 AS expr
                    FROM OBLE_Y1 AS a
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND a.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtIntChildSupp_CODE, @Lc_TypeDebtIntSpousalSupp_CODE)
                     AND dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.Fips_CODE, 1, 2) = @Lc_DeStateFips_CODE
                     AND a.EndValidity_DATE = @Ld_High_DATE);


   SET @Ls_Sql_TEXT = 'UPDATE TMEMB_Y1 ACTIVE';

   UPDATE @MembTmp_P1
      SET MemberStatus_INDC = @Lc_StatusCaseMemberActive_INDC
    WHERE MemberMci_IDNO IN (SELECT DISTINCT
                                    a.MemberMci_IDNO
                               FROM @MembTmp_P1 AS a,
                                    MHIS_Y1 AS b
                              WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                AND b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                                AND dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (@Ad_Start_DATE, @Lc_DateFormatYyyymm_TEXT) BETWEEN dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (b.Start_DATE, @Lc_DateFormatYyyymm_TEXT) AND dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (b.End_DATE, @Lc_DateFormatYyyymm_TEXT)
                                AND b.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE);

   SET @Ls_Sql_TEXT = 'UPDATE TMEMB_Y1 NOT ACTIVE';

   UPDATE @MembTmp_P1
      SET MemberStatus_INDC = @Lc_No_INDC
    WHERE MemberMci_IDNO NOT IN (SELECT DISTINCT
                                        a.MemberMci_IDNO
                                   FROM @MembTmp_P1 AS a,
                                        MHIS_Y1 AS b
                                  WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                    AND b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                                    AND dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (@Ad_Start_DATE, @Lc_DateFormatYyyymm_TEXT) BETWEEN dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (b.Start_DATE, @Lc_DateFormatYyyymm_TEXT) AND dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE (b.End_DATE, @Lc_DateFormatYyyymm_TEXT)
                                    AND b.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE);

   SELECT @Ln_Member_QNTY = COUNT (1)
     FROM @MembTmp_P1;

   IF @Ln_Member_QNTY = 0
    BEGIN
     SET @Ac_Process_INDC = @Lc_No_INDC;

     RETURN;
    END;

   SET @Ac_Process_INDC = @Lc_Yes_INDC;

   SELECT @Ln_MemberMtd_QNTY = COUNT (1)
     FROM @MembTmp_P1 AS t
    WHERE t.MemberStatus_INDC = @Lc_StatusCaseMemberActive_INDC;

   IF @Ln_MemberMtd_QNTY = 0
    BEGIN
     SET @An_LtdExpend_AMNT = @An_LtdExpend_AMNT + @An_MtdExpend_AMNT;
     SET @An_LtdRecoup_AMNT = @An_LtdRecoup_AMNT + @An_MtdRecoup_AMNT;
     SET @An_LtdUrg_AMNT = @An_LtdUrg_AMNT + @An_MtdUrg_AMNT;
     SET @An_MtdExpend_AMNT = 0;
     SET @An_MtdRecoup_AMNT = 0;
     SET @An_MtdUrg_AMNT = 0;
    END;

   SET @Ls_Sql_TEXT = 'INSERT_TMP_PRORATE';
   SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO ' + ISNULL (CAST(@An_CaseWelfare_IDNO AS VARCHAR), '');

   INSERT @PratTmp_P1
          (PrDistribute_QNTY,
           MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           TypeBucket_CODE,
           CaseWelfare_IDNO,
           ArrToBePaid_AMNT,
           PerMemberProrated_AMNT,
           PerMemberRecoupment_AMNT,
           MemberUnreimbGrant_AMNT)
   SELECT CASE TypeBucket_CODE
           WHEN @Lc_TypeBucketApaa_CODE
            THEN
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtInterest_CODE
              THEN 1
             ELSE 4
            END
           WHEN @Lc_TypeBucketAtaa_CODE
            THEN
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtInterest_CODE
              THEN 2
             ELSE 5
            END
           WHEN @Lc_TypeBucketAcaa_CODE
            THEN
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtInterest_CODE
              THEN 3
             ELSE 6
            END
           ELSE
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtSupport_CODE
              THEN 1
             ELSE 2
            END
          END,
          a.MemberMci_IDNO,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          c.TypeBucket_CODE,
          @An_CaseWelfare_IDNO,
          CASE TypeBucket_CODE
           WHEN @Lc_TypeBucketApaa_CODE
            THEN OweTotPaa_AMNT - AppTotPaa_AMNT
           -- UDA should not move back to Paa_AMNT when Status_CODE changes to Tanf
           -- So UDA should not be considered for proration
           -- + OweTotUda_AMNT - AppTotUda_AMNT,
           WHEN @Lc_TypeBucketAtaa_CODE
            THEN OweTotTaa_AMNT - AppTotTaa_AMNT
           WHEN @Lc_TypeBucketAcaa_CODE
            THEN OweTotCaa_AMNT - AppTotCaa_AMNT + OweTotUpa_AMNT - AppTotUpa_AMNT
           WHEN @Lc_TypeBucketC_CODE
            THEN
            CASE b.SupportYearMonth_NUMB
             WHEN @An_WelfareYearMonth_NUMB
              THEN b.MtdCurSupOwed_AMNT
             ELSE 0
            END
          END AS ArrToBePaid_AMNT,
          @An_LtdExpend_AMNT,
          @An_LtdRecoup_AMNT,
          @An_LtdUrg_AMNT
     FROM LSUP_Y1 AS b,
          DBTP_Y1 AS c,
          (SELECT f.MemberMci_IDNO AS MemberMci_IDNO,
                  g.Case_IDNO,
                  g.OrderSeq_NUMB,
                  g.ObligationSeq_NUMB,
                  g.TypeDebt_CODE
             FROM OBLE_Y1 AS g,
                  (SELECT DISTINCT
                          m.Case_IDNO,
                          m.MemberMci_IDNO
                     FROM MHIS_Y1 AS m
                    WHERE m.CaseWelfare_IDNO = @An_CaseWelfare_IDNO) AS f
            WHERE g.Case_IDNO = f.Case_IDNO
              AND g.MemberMci_IDNO = f.MemberMci_IDNO
              AND g.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtIntChildSupp_CODE, @Lc_TypeDebtIntSpousalSupp_CODE)
              AND dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (g.Fips_CODE, 1, 2) = @Lc_DeStateFips_CODE
              AND g.BeginObligation_DATE = (SELECT MAX (o.BeginObligation_DATE) AS expr
                                              FROM OBLE_Y1 AS o
                                             WHERE o.Case_IDNO = g.Case_IDNO
                                               AND o.OrderSeq_NUMB = g.OrderSeq_NUMB
                                               AND o.ObligationSeq_NUMB = g.ObligationSeq_NUMB
                                               AND o.BeginObligation_DATE <= @Ad_Run_DATE
                                               AND o.EndValidity_DATE = @Ld_High_DATE)
              AND g.EndValidity_DATE = @Ld_High_DATE
              AND EXISTS (SELECT 1 AS expr
                            FROM @MembTmp_P1 AS t
                           WHERE t.MemberMci_IDNO = f.MemberMci_IDNO)) AS a,
          @MembTmp_P1 AS d
    WHERE b.Case_IDNO = a.Case_IDNO
      AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
      AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
      AND b.SupportYearMonth_NUMB = (SELECT MAX (l.SupportYearMonth_NUMB) AS expr
                                       FROM LSUP_Y1 AS l
                                      WHERE l.Case_IDNO = b.Case_IDNO
                                        AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
                                        AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                        AND l.SupportYearMonth_NUMB <= @An_WelfareYearMonth_NUMB)
      AND b.EventGlobalSeq_NUMB = (SELECT MAX (l.EventGlobalSeq_NUMB) AS expr
                                     FROM LSUP_Y1 AS l
                                    WHERE l.Case_IDNO = b.Case_IDNO
                                      AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
                                      AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                      AND l.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)
      AND c.TypeDebt_CODE = @Lc_TypeDebtChildSupp_CODE
      AND c.SourceReceipt_CODE = @Lc_StatusReceiptRefunded_CODE
      AND c.Interstate_INDC = @Lc_No_INDC
      AND c.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
      AND c.TypeBucket_CODE IN (@Lc_TypeBucketApaa_CODE, @Lc_TypeBucketAtaa_CODE, @Lc_TypeBucketAcaa_CODE, @Lc_TypeBucketC_CODE)
      AND c.EndValidity_DATE = @Ld_High_DATE
      AND d.MemberMci_IDNO = a.MemberMci_IDNO
      AND d.Case_IDNO = a.Case_IDNO
   UNION
   SELECT CASE TypeBucket_CODE
           WHEN @Lc_TypeBucketApaa_CODE
            THEN
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtInterest_CODE
              THEN 1
             ELSE 4
            END
           WHEN @Lc_TypeBucketAtaa_CODE
            THEN
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtInterest_CODE
              THEN 2
             ELSE 5
            END
           WHEN @Lc_TypeBucketAcaa_CODE
            THEN
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtInterest_CODE
              THEN 3
             ELSE 6
            END
           ELSE
            CASE dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (a.TypeDebt_CODE, 2, 1)
             WHEN @Lc_DebtSupport_CODE
              THEN 1
             ELSE 2
            END
          END,
          a.MemberMci_IDNO,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          c.TypeBucket_CODE,
          @An_CaseWelfare_IDNO,
          0 AS ArrToBePaid_AMNT,
          @An_LtdExpend_AMNT,
          @An_LtdRecoup_AMNT,
          @An_LtdUrg_AMNT
     FROM WEMO_Y1 AS w,
          DBTP_Y1 AS c,
          (SELECT f.MemberMci_IDNO AS MemberMci_IDNO,
                  g.Case_IDNO,
                  g.OrderSeq_NUMB,
                  g.ObligationSeq_NUMB,
                  g.TypeDebt_CODE
             FROM OBLE_Y1 AS g,
                  (SELECT DISTINCT
                          m.Case_IDNO,
                          m.MemberMci_IDNO
                     FROM MHIS_Y1 AS m
                    WHERE m.CaseWelfare_IDNO = @An_CaseWelfare_IDNO) AS f
            WHERE g.Case_IDNO = f.Case_IDNO
              AND g.MemberMci_IDNO = f.MemberMci_IDNO
              AND g.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtIntChildSupp_CODE, @Lc_TypeDebtIntSpousalSupp_CODE)
              AND dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (g.Fips_CODE, 1, 2) = @Lc_DeStateFips_CODE
              AND g.BeginObligation_DATE = (SELECT MAX (o.BeginObligation_DATE) AS expr
                                              FROM OBLE_Y1 AS o
                                             WHERE o.Case_IDNO = g.Case_IDNO
                                               AND o.OrderSeq_NUMB = g.OrderSeq_NUMB
                                               AND o.ObligationSeq_NUMB = g.ObligationSeq_NUMB
                                               AND o.BeginObligation_DATE <= @Ad_Run_DATE
                                               AND o.EndValidity_DATE = @Ld_High_DATE)
              AND g.EndValidity_DATE = @Ld_High_DATE
              AND EXISTS (SELECT 1 AS expr
                            FROM @MembTmp_P1 AS t
                           WHERE t.MemberMci_IDNO = f.MemberMci_IDNO)) AS a,
          @MembTmp_P1 AS d
    WHERE w.Case_IDNO = a.Case_IDNO
      AND w.OrderSeq_NUMB = a.OrderSeq_NUMB
      AND w.ObligationSeq_NUMB = a.ObligationSeq_NUMB
      AND w.WelfareYearMonth_NUMB = @An_WelfareYearMonth_NUMB
      AND w.EndValidity_DATE = @Ld_High_DATE
      AND c.TypeDebt_CODE = @Lc_TypeDebtChildSupp_CODE
      AND c.SourceReceipt_CODE = @Lc_StatusReceiptRefunded_CODE
      AND c.Interstate_INDC = @Lc_No_INDC
      AND c.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
      AND c.TypeBucket_CODE IN (@Lc_TypeBucketApaa_CODE, @Lc_TypeBucketAtaa_CODE, @Lc_TypeBucketAcaa_CODE, @Lc_TypeBucketC_CODE)
      AND c.EndValidity_DATE = @Ld_High_DATE
      AND d.MemberMci_IDNO = a.MemberMci_IDNO
      AND d.Case_IDNO = a.Case_IDNO
      AND NOT EXISTS (SELECT 1 AS expr
                        FROM LSUP_Y1 AS b
                       WHERE b.Case_IDNO = a.Case_IDNO
                         AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                         AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                         AND b.SupportYearMonth_NUMB = (SELECT MAX (l.SupportYearMonth_NUMB) AS expr
                                                          FROM LSUP_Y1 AS l
                                                         WHERE l.Case_IDNO = b.Case_IDNO
                                                           AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                           AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                           AND l.SupportYearMonth_NUMB <= @An_WelfareYearMonth_NUMB)
                         AND b.EventGlobalSeq_NUMB = (SELECT MAX (l.EventGlobalSeq_NUMB) AS expr
                                                        FROM LSUP_Y1 AS l
                                                       WHERE l.Case_IDNO = b.Case_IDNO
                                                         AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                         AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                         AND l.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB));

   SET @Ls_Sql_TEXT = 'INSERT_bump_cur';
   SET @Ln_Cum_AMNT = 0;

   INSERT INTO @BumpCur_P1
   SELECT a.PrDistribute_QNTY,
          SUM (a.ArrToBePaid_AMNT)
     FROM @PratTmp_P1 AS a
    WHERE a.ArrToBePaid_AMNT > 0
      AND a.TypeBucket_CODE <> 'C'
    GROUP BY a.PrDistribute_QNTY
    ORDER BY a.PrDistribute_QNTY;

   SELECT @Ln_Row_QNTY = COUNT (a.Row_NUMB)
     FROM @BumpCur_P1 AS a;

   WHILE @Ln_CurrentRow_NUMB <= @Ln_Row_QNTY
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT @BumpCur_P1'

     SELECT @BumpCur_PrDistribute_QNTY = a.PrDistribute_QNTY,
            @BumpCur_Pr_AMNT = a.Pr_AMNT
       FROM @BumpCur_P1 AS a
      WHERE a.Row_NUMB = @Ln_CurrentRow_NUMB;

     SET @Ls_Sql_TEXT = 'INSERT_VPRTL'

     INSERT @PrtlTmp_P1
            (Case_IDNO,
             PrDistribute_QNTY,
             PrArrToBePaid_AMNT,
             CumArrToBePaid_AMNT)
     VALUES (dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR (@An_CaseWelfare_IDNO, 1, 6),
             @BumpCur_PrDistribute_QNTY,
             @BumpCur_Pr_AMNT,
             @Ln_Cum_AMNT);

     SET @Ln_Cum_AMNT = @Ln_Cum_AMNT + @BumpCur_Pr_AMNT;
     SET @Ln_CurrentRow_NUMB = @Ln_CurrentRow_NUMB + 1;
    END;

   SET @Ls_Sql_TEXT = 'SELECT @PratTmp_P1'

   SELECT @Ln_Val_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0)
     FROM @PratTmp_P1 AS a
    WHERE a.ArrToBePaid_AMNT > 0
      AND a.TypeBucket_CODE <> @Lc_TypeBucketC_CODE;

   SET @Ls_Sql_TEXT = 'INSERT_TMP_PAID - 1';

   DELETE FROM #TPRCP_P1;

   INSERT INTO #TPRCP_P1
               (Seq_IDNO,
                MemberMci_IDNO,
                Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                TypeBucket_CODE,
                CaseWelfare_IDNO,
                ArrPaid_AMNT,
                ArrRecoup_AMNT,
                ArrPaidUrg_AMNT,
                Rounded_AMNT,
                RoundedRecoup_AMNT,
                ArrToBePaid_AMNT,
                ArrPaidMtd_AMNT,
                ArrRecoupMtd_AMNT,
                ArrPaidMtdUrg_AMNT)
   SELECT ROW_NUMBER () OVER (ORDER BY a.MemberMci_IDNO) AS Seq_IDNO,
          a.MemberMci_IDNO,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.TypeBucket_CODE,
          @An_CaseWelfare_IDNO AS CaseWelfare_IDNO,
          dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID_GRANT (PerMemberProrated_AMNT, e.CumArrToBePaid_AMNT, e.PrArrToBePaid_AMNT, ArrToBePaid_AMNT, @Ln_Val_AMNT) AS ArrPaid_AMNT,
          dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID_GRANT (PerMemberRecoupment_AMNT, e.CumArrToBePaid_AMNT, e.PrArrToBePaid_AMNT, ArrToBePaid_AMNT, @Ln_Val_AMNT) AS ArrRecoup_AMNT,
          dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID_GRANT (MemberUnreimbGrant_AMNT, e.CumArrToBePaid_AMNT, e.PrArrToBePaid_AMNT, ArrToBePaid_AMNT, @Ln_Val_AMNT) AS ArrPaid_AMNT,
          dbo.BATCH_COMMON_DIST_FN$SF_CAL_ROUND (PerMemberProrated_AMNT, ISNULL (e.CumArrToBePaid_AMNT, 0), ISNULL (e.PrArrToBePaid_AMNT, 0), ArrToBePaid_AMNT) AS Rounded_AMNT,
          dbo.BATCH_COMMON_DIST_FN$SF_CAL_ROUND (PerMemberRecoupment_AMNT, ISNULL (e.CumArrToBePaid_AMNT, 0), ISNULL (e.PrArrToBePaid_AMNT, 0), ArrToBePaid_AMNT) AS Rounded_AMNT,
          a.ArrToBePaid_AMNT,
          0,
          0,
          0
     FROM @PratTmp_P1 AS a,
          @PrtlTmp_P1 AS e
    WHERE a.PrDistribute_QNTY = e.PrDistribute_QNTY
      AND a.TypeBucket_CODE <> @Lc_TypeBucketC_CODE
      AND EXISTS (SELECT 1
                    FROM @PratTmp_P1 AS f
                   WHERE f.ArrToBePaid_AMNT > 0
                     AND f.TypeBucket_CODE <> @Lc_TypeBucketC_CODE);

   BEGIN
    SELECT TOP 1 @Ln_Temp_NUMB = 1
      FROM @PratTmp_P1 AS f
     WHERE f.ArrToBePaid_AMNT > 0
       AND f.TypeBucket_CODE <> @Lc_TypeBucketC_CODE;

    SET @Ln_Row_QNTY = @@ROWCOUNT

    IF @Ln_Row_QNTY = 0
     BEGIN
      SELECT @Ln_Oble_QNTY = COUNT (1)
        FROM @PratTmp_P1 AS f
       WHERE f.ArrToBePaid_AMNT <= 0
         AND f.TypeBucket_CODE = @Lc_TypeBucketApaa_CODE;

      IF @Ln_Oble_QNTY > 0
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT_TMP_PAID - 2';

        INSERT #TPRCP_P1
               (Seq_IDNO,
                MemberMci_IDNO,
                Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                TypeBucket_CODE,
                CaseWelfare_IDNO,
                ArrPaid_AMNT,
                ArrPaidUrg_AMNT,
                ArrRecoup_AMNT,
                Rounded_AMNT,
                RoundedRecoup_AMNT,
                ArrToBePaid_AMNT,
                ArrPaidMtd_AMNT,
                ArrRecoupMtd_AMNT,
                ArrPaidMtdUrg_AMNT)
        SELECT ROW_NUMBER () OVER (ORDER BY f.MemberMci_IDNO) AS Seq_IDNO,
               f.MemberMci_IDNO,
               f.Case_IDNO,
               f.OrderSeq_NUMB,
               f.ObligationSeq_NUMB,
               @Lc_TypeBucketApaa_CODE,
               @An_CaseWelfare_IDNO AS CaseWelfare_IDNO,
               dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID_VOL (PerMemberProrated_AMNT, @Ln_Oble_QNTY),
               dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID_VOL (MemberUnreimbGrant_AMNT, @Ln_Oble_QNTY) AS ArrPaidUrg_AMNT,
               dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID_VOL (PerMemberRecoupment_AMNT, @Ln_Oble_QNTY),
               .01,
               .01,
               0,
               0,
               0,
               0
          FROM @PratTmp_P1 AS f
         WHERE f.TypeBucket_CODE = @Lc_TypeBucketApaa_CODE;
       END
     END;
   END;

   /* ---------------------------<< Adjust Cent For Expnd Value_AMNT >>--------------------------------- */
   SET @Ln_Diff_AMNT = 0;
   SET @Ln_Maxseq_NUMB = 0;

   SELECT @Ln_Diff_AMNT = (@An_LtdExpend_AMNT - SUM (f.ArrPaid_AMNT))
     FROM #TPRCP_P1 AS f;

   IF @Ln_Diff_AMNT != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE TPRCP_Y1 PAID';

     UPDATE TOP (1) #TPRCP_P1
        SET ArrPaid_AMNT = ArrPaid_AMNT + @Ln_Diff_AMNT
      WHERE ABS (ArrPaid_AMNT) > ABS (@Ln_Diff_AMNT);
    END

   /* ---------------------------<< Adjust Cent For Recoup Value_AMNT >>--------------------------------- */
   SET @Ln_Diff_AMNT = 0;
   SET @Ln_Maxseq_NUMB = 0;

   SELECT @Ln_Diff_AMNT = (@An_LtdRecoup_AMNT - SUM (p.ArrRecoup_AMNT))
     FROM #TPRCP_P1 AS p;

   IF @Ln_Diff_AMNT != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE TPRCP_Y1 RECOUP';

     UPDATE TOP (1) #TPRCP_P1
        SET ArrRecoup_AMNT = ArrRecoup_AMNT + @Ln_Diff_AMNT
      WHERE ABS (ArrRecoup_AMNT) > ABS (@Ln_Diff_AMNT);
    END

   /* ---------------------------<< Adjust Cent For URG Value_AMNT >>--------------------------------- */
   SET @Ln_Diff_AMNT = 0;
   SET @Ln_Maxseq_NUMB = 0;

   SELECT @Ln_Diff_AMNT = (@An_LtdUrg_AMNT - SUM (p.ArrPaidUrg_AMNT))
     FROM #TPRCP_P1 AS p;

   IF @Ln_Diff_AMNT != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE TPRCP_Y1 URG';

     UPDATE TOP (1) #TPRCP_P1
        SET ArrPaidUrg_AMNT = ArrPaidUrg_AMNT + @Ln_Diff_AMNT
      WHERE ArrPaidUrg_AMNT > ABS (@Ln_Diff_AMNT);
    END

   SET @Ln_Loop_QNTY = 0;
   SET @Ln_Oble_QNTY = 0;

   SELECT @Ln_TotArrears_AMNT = ISNULL (SUM (a.ArrToBePaid_AMNT), 0),
          @Ln_Oble_QNTY = COUNT (1)
     FROM @PratTmp_P1 AS a
    WHERE a.TypeBucket_CODE = @Lc_TypeBucketC_CODE
      AND a.ArrToBePaid_AMNT > 0
      AND EXISTS (SELECT 1 AS expr
                    FROM @MembTmp_P1 AS b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.MemberStatus_INDC = @Lc_StatusCaseMemberActive_INDC);

   IF @Ln_Oble_QNTY > 0
    BEGIN
     SET @Ln_Adjust_AMNT = 0;
     SET @Ln_AdjustRcp_AMNT = 0;
     SET @Ln_CentUrgMtd_AMNT = 0;

     BEGIN
      INSERT INTO @MemberCur_P1
      SELECT a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             a.CaseWelfare_IDNO,
             a.ArrToBePaid_AMNT,
             ROW_NUMBER () OVER (ORDER BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.CaseWelfare_IDNO)
        FROM @PratTmp_P1 AS a
       WHERE a.TypeBucket_CODE = 'C'
         AND a.ArrToBePaid_AMNT > 0
         AND EXISTS (SELECT 1 AS expr
                       FROM @MembTmp_P1 AS b
                      WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                        AND b.MemberStatus_INDC = 'A');

      SET @Ln_Row_QNTY = 0;
      SET @Ln_CurrentRow_NUMB = 1;

      SELECT @Ln_MemberCur_QNTY = MAX (m.Row_NUMB)
        FROM @MemberCur_P1 AS m;

      WHILE @Ln_CurrentRow_NUMB <= @Ln_MemberCur_QNTY
       BEGIN
        SELECT @Ln_MemberCur_Case_IDNO = m.Case_IDNO,
               @Ln_MemberCur_OrderSeq_NUMB = m.OrderSeq_NUMB,
               @Ln_MemberCur_ObligationSeq_NUMB = m.ObligationSeq_NUMB,
               @Ln_MemberCur_CaseWelfare_IDNO = m.CaseWelfare_IDNO,
               @Ln_MemberCur_ArrToBePaid_AMNT = m.ArrToBePaid_AMNT
          FROM @MemberCur_P1 AS m
         WHERE Row_NUMB = @Ln_CurrentRow_NUMB;

        SET @Ln_Loop_QNTY = @Ln_Loop_QNTY + 1

        IF @Ln_Loop_QNTY = @Ln_Oble_QNTY
         BEGIN
          SET @Ln_PerMemberOble_AMNT = @An_MtdExpend_AMNT - @Ln_Adjust_AMNT;
          SET @Ln_PerRcpOble_AMNT = @An_MtdRecoup_AMNT - @Ln_AdjustRcp_AMNT;
          SET @Ln_UrgPerMemberOble_AMNT = @An_MtdUrg_AMNT - @Ln_CentUrgMtd_AMNT;
          SET @Ln_Adjust_AMNT = 0;
          SET @Ln_AdjustRcp_AMNT = 0;
          SET @Ln_CentUrgMtd_AMNT = 0;
         END
        ELSE
         BEGIN
          SET @Ln_PerMemberOble_AMNT = ROUND (@Ln_MemberCur_ArrToBePaid_AMNT * @An_MtdExpend_AMNT / @Ln_TotArrears_AMNT, 2);
          SET @Ln_PerRcpOble_AMNT = ROUND (@Ln_MemberCur_ArrToBePaid_AMNT * @An_MtdRecoup_AMNT / @Ln_TotArrears_AMNT, 2);
          SET @Ln_UrgPerMemberOble_AMNT = ROUND (@Ln_MemberCur_ArrToBePaid_AMNT * @An_MtdUrg_AMNT / @Ln_TotArrears_AMNT, 2);
          SET @Ln_Adjust_AMNT = @Ln_Adjust_AMNT + @Ln_PerMemberOble_AMNT;
          SET @Ln_AdjustRcp_AMNT = @Ln_AdjustRcp_AMNT + @Ln_PerRcpOble_AMNT;
          SET @Ln_CentUrgMtd_AMNT = @Ln_CentUrgMtd_AMNT + @Ln_UrgPerMemberOble_AMNT;
         END;

        SET @Ls_Sql_TEXT = 'UPDATE TPRCP_P1';

        UPDATE #TPRCP_P1
           SET ArrPaidMtd_AMNT = @Ln_PerMemberOble_AMNT,
               ArrRecoupMtd_AMNT = @Ln_PerRcpOble_AMNT,
               ArrPaidMtdUrg_AMNT = @Ln_UrgPerMemberOble_AMNT
         WHERE Case_IDNO = @Ln_MemberCur_Case_IDNO
           AND OrderSeq_NUMB = @Ln_MemberCur_OrderSeq_NUMB
           AND ObligationSeq_NUMB = @Ln_MemberCur_ObligationSeq_NUMB
           AND CaseWelfare_IDNO = @Ln_MemberCur_CaseWelfare_IDNO
           AND TypeBucket_CODE = @Lc_TypeBucketC_CODE

        SET @Ln_Row_QNTY = @@ROWCOUNT

        IF @Ln_Row_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT TPRCP_P1';
          SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO ' + ISNULL (CAST(@Ln_MemberCur_CaseWelfare_IDNO AS VARCHAR), '') + 'Case_IDNO ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + 'OrderSeq_NUMB ' + ISNULL (CAST(CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR) AS VARCHAR (6)), '') + 'ObligationSeq_NUMB ' + ISNULL (CAST(@Ln_MemberCur_ObligationSeq_NUMB AS VARCHAR(2)), '')

          INSERT #TPRCP_P1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  CaseWelfare_IDNO,
                  ArrPaid_AMNT,
                  ArrPaidUrg_AMNT,
                  ArrRecoup_AMNT,
                  Rounded_AMNT,
                  RoundedRecoup_AMNT,
                  ArrToBePaid_AMNT,
                  ArrPaidMtd_AMNT,
                  ArrRecoupMtd_AMNT,
                  ArrPaidMtdUrg_AMNT)
          VALUES (@Ln_MemberCur_Case_IDNO,
                  @Ln_MemberCur_OrderSeq_NUMB,
                  @Ln_MemberCur_ObligationSeq_NUMB,
                  @Ln_MemberCur_CaseWelfare_IDNO,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  @Ln_PerMemberOble_AMNT,
                  @Ln_PerRcpOble_AMNT,
                  @Ln_UrgPerMemberOble_AMNT);
         END

        SET @Ln_CurrentRow_NUMB = @Ln_CurrentRow_NUMB + 1;
       END;
     END;
    END;
   ELSE
    BEGIN
     SELECT @Ln_Oble_QNTY = COUNT (1)
       FROM @PratTmp_P1 AS a
      WHERE a.TypeBucket_CODE = @Lc_TypeBucketC_CODE
        AND a.PrDistribute_QNTY = 1
        AND EXISTS (SELECT 1 AS expr
                      FROM @MembTmp_P1 AS b
                     WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                       AND b.MemberStatus_INDC = @Lc_StatusCaseMemberActive_INDC);

     IF @Ln_Oble_QNTY > 0
      BEGIN
       SET @Ln_PerMemberOble_AMNT = ROUND (@An_MtdExpend_AMNT / @Ln_Oble_QNTY, 2);
       SET @Ln_Adjust_AMNT = @An_MtdExpend_AMNT - (@Ln_PerMemberOble_AMNT * @Ln_Oble_QNTY);
       SET @Ln_PerRcpOble_AMNT = ROUND (@An_MtdRecoup_AMNT / @Ln_Oble_QNTY, 2);
       SET @Ln_AdjustRcp_AMNT = @An_MtdRecoup_AMNT - (@Ln_PerRcpOble_AMNT * @Ln_Oble_QNTY);
       SET @Ln_UrgPerMemberOble_AMNT = ROUND (@An_MtdUrg_AMNT / @Ln_Oble_QNTY, 2);
       SET @Ln_CentUrgMtd_AMNT = @An_MtdUrg_AMNT - (@Ln_UrgPerMemberOble_AMNT * @Ln_Oble_QNTY);
       SET @Ls_Sql_TEXT = 'UPDATE TPRCP_P1 2';

       UPDATE #TPRCP_P1
          SET ArrPaidMtd_AMNT = @Ln_PerMemberOble_AMNT,
              ArrRecoupMtd_AMNT = @Ln_PerRcpOble_AMNT,
              ArrPaidMtdUrg_AMNT = @Ln_UrgPerMemberOble_AMNT
         FROM #TPRCP_P1 AS a
        WHERE a.TypeBucket_CODE = @Lc_TypeBucketC_CODE
          AND EXISTS (SELECT 1 AS expr
                        FROM @MembTmp_P1 AS b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.MemberStatus_INDC = @Lc_StatusCaseMemberActive_INDC);

       SET @Ln_Row_QNTY = @@ROWCOUNT

       IF @Ln_Row_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT TPRCP2';

         INSERT #TPRCP_P1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 CaseWelfare_IDNO,
                 ArrPaid_AMNT,
                 ArrPaidUrg_AMNT,
                 ArrRecoup_AMNT,
                 Rounded_AMNT,
                 RoundedRecoup_AMNT,
                 ArrToBePaid_AMNT,
                 ArrPaidMtd_AMNT,
                 ArrRecoupMtd_AMNT,
                 ArrPaidMtdUrg_AMNT,
                 TypeBucket_CODE)
         SELECT a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB,
                a.CaseWelfare_IDNO,
                0,
                0,
                0,
                0,
                0,
                0,
                @Ln_PerMemberOble_AMNT,
                @Ln_PerRcpOble_AMNT,
                @Ln_UrgPerMemberOble_AMNT,
                @Lc_TypeBucketC_CODE
           FROM @PratTmp_P1 AS a
          WHERE a.TypeBucket_CODE = @Lc_TypeBucketC_CODE
            AND a.PrDistribute_QNTY = 1
            AND EXISTS (SELECT 1 AS expr
                          FROM @MembTmp_P1 AS b
                         WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                           AND b.MemberStatus_INDC = @Lc_StatusCaseMemberActive_INDC);
        END

       IF @Ln_Adjust_AMNT != 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE TPRCP_Y1 PAID_MTD';

         UPDATE TOP (1) #TPRCP_P1
            SET ArrPaidMtd_AMNT = ArrPaidMtd_AMNT + @Ln_Adjust_AMNT
          WHERE TypeBucket_CODE = @Lc_TypeBucketC_CODE
            AND ABS (ArrPaidMtd_AMNT) > ABS (@Ln_Adjust_AMNT);
        END

       IF @Ln_AdjustRcp_AMNT != 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE TPRCP_Y1 RECOUP_MTD';

         UPDATE TOP (1) #TPRCP_P1
            SET ArrRecoupMtd_AMNT = ArrRecoupMtd_AMNT + @Ln_AdjustRcp_AMNT
          WHERE TypeBucket_CODE = @Lc_TypeBucketC_CODE
            AND ABS (ArrRecoupMtd_AMNT) > ABS (@Ln_AdjustRcp_AMNT);
        END

       IF @Ln_CentUrgMtd_AMNT != 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE TPRCP_Y1 MTD_URG';

         UPDATE TOP (1) #TPRCP_P1
            SET ArrPaidMtdUrg_AMNT = ArrPaidMtdUrg_AMNT + @Ln_CentUrgMtd_AMNT
          WHERE TypeBucket_CODE = @Lc_TypeBucketC_CODE
            AND ABS (ArrPaidMtdUrg_AMNT) > ABS (@Ln_CentUrgMtd_AMNT);
        END
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END


GO
