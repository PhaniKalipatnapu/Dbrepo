/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S123]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S123]
(
	 @An_Case_IDNO         		 NUMERIC(6,0) ,
	 @An_OrderSeq_NUMB     		 NUMERIC(2,0) ,
	 @An_ObligationSeq_NUMB		 NUMERIC(2,0) ,
     @An_SupportYearMonth_NUMB   NUMERIC(6,0) ,
     @Ac_TypeDebt_CODE     		 CHAR(2)      ,
     @An_MemberMci_IDNO          NUMERIC(10,0),  
     @Ad_ReceiptFrom_DATE        DATE         ,  
     @Ad_ReceiptTo_DATE          DATE         ,
     @Ai_RowFrom_NUMB      		 INT =1       ,
     @Ai_RowTo_NUMB        		 INT =10
)
AS

/*
*     PROCEDURE NAME    : LSUP_RETRIEVE_S123
 *     DESCRIPTION       : Retrieves log support for all the arrear records along with begin and end transaction amount of a particular program type, case id, fips code for the given case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/

   BEGIN

   DECLARE
   		@Ld_High_DATE                                           DATE = '12/31/9999',
   		@Lc_Yes_INDC                                            CHAR(1)='Y',
   		@Lc_StatusReceiptHeld_CODE                              CHAR(1) = 'H',
   		@Li_Zero_NUMB                                           SMALLINT = 0,
   		@Li_Hundred_NUMB                                        INT = 100,
   		@Lc_DescriptionBucketCur_TEXT                           CHAR(11)= 'CURRENT DUE',
   		@Lc_DescriptionBucketNa_TEXT                            CHAR(10) = 'NA ARREARS',
   		@Lc_DescriptionBucketPa_TEXT                            CHAR(10) = 'PA ARREARS',
   		@Lc_DescriptionBucketTa_TEXT                            CHAR(10) = 'TA ARREARS',
   		@Lc_DescriptionBucketCa_TEXT                            CHAR(10) = 'CA ARREARS',
   		@Lc_DescriptionBucketUpa_TEXT                           CHAR(11) = 'UPA ARREARS',
   		@Lc_DescriptionBucketUda_TEXT                           CHAR(11) = 'UDA ARREARS',
   		@Lc_DescriptionBucketIvef_TEXT                          CHAR(17) = 'Ivef_AMNT ARREARS',
   		@Lc_DescriptionBucketMedi_TEXT                          CHAR(12) = 'MEDI ARREARS',
   		@Lc_DescriptionBucketNffc_TEXT                          CHAR(12)= 'NFFC ARREARS',
   		@Lc_DescriptionBucketNivd_TEXT                          CHAR(12) = 'NIVD ARREARS',
   		@Lc_DescriptionBucketFutures_TEXT                       CHAR(7) = 'FUTURES',
   		@Li_ObligationCreation1010_NUMB                         INT = 1010,
		@Li_ObligationModification1020_NUMB                     INT = 1020,
		@Li_ArrearAdjustment1030_NUMB                           INT = 1030,
		@Li_DirectPayCredit1040_NUMB                            INT = 1040,
		@Li_Accrual1050_NUMB                                    INT = 1050,
		@Li_CircularRuleRecord1070_NUMB                         INT = 1070,
		@Li_ChangeLsupForParticipantTanfStatusChange1080_NUMB	INT = 1080,
		@Li_ReceiptReversed1250_NUMB                            INT = 1250,
		@Li_ReceiptOnHold1420_NUMB                              INT = 1420,
		@Li_ManuallyDistributeReceipt1810_NUMB                  INT = 1810,
		@Li_ReceiptDistributed1820_NUMB                         INT = 1820,
		@Li_FutureHoldRelease1825_NUMB                          INT = 1825,
		@Li_TanfGrantSplit2730_NUMB                             INT = 2730,
		@Li_InterestAssessed3150_NUMB                           INT = 3150,
		@Li_AssessedInterestRevoked3180_NUMB                    INT = 3180,
		@Li_InterestReassessed3190_NUMB                         INT = 3190,
		@Li_AssessedInterestRevokedArrear500OrLess3200_NUMB     INT = 3200,
		@Li_AssessedInterestRevokedMinimumPaid3210_NUMB         INT = 3210,
   		@Ln_SeqEventFn1031_NUMB                                 NUMERIC(4, 0) = 1031,
   		@Ln_SeqEventFn1051_NUMB                                 NUMERIC(4, 0) = 1051,
   		@Ln_SeqEventFn3050_NUMB                                 NUMERIC(4, 0) = 3050,
   		@Ls_DescriptionBucketCd_TEXT                            VARCHAR(100) = 'CURRENT DUE',
   		@Ls_DescriptionEventAccrual_TEXT                        VARCHAR(100) = 'ACCRUAL',
   		@Ls_DescriptionEventAdj_TEXT                            VARCHAR(100) = 'ADJUSTMENT',
   		@Ls_DescriptionEventCaseCl_TEXT                         VARCHAR(100) = 'CASE CLOSURE',
   		@Ls_DescriptionEventCirRule_TEXT                        VARCHAR(100) = 'CIRCULAR RULE',
   		@Ls_DescriptionEventConversionErr_TEXT                  VARCHAR(100) = 'CONVERSION ERROR CORRECTION',
   		@Ls_DescriptionEventCrdRefund_TEXT                      VARCHAR(100) = 'CREDIT/REFUND',
   		@Ls_DescriptionEventFutures_TEXT                        VARCHAR(100) = 'FUTURES',
   		@Ls_DescriptionEventFutRelease_TEXT                     VARCHAR(100) = 'FUTURE RELEASE',
   		@Ls_DescriptionEventGrantSplit_TEXT                     VARCHAR(100) = 'GRANT SPLIT',
   		@Ls_DescriptionEventHeldRcpts_TEXT                      VARCHAR(100) = 'HELD RECEIPTS',
   		@Ls_DescriptionEventIntAssd_TEXT                        VARCHAR(100) = 'INTEREST ASSESSED',
   		@Ls_DescriptionEventIntReassd_TEXT                      VARCHAR(100) = 'INTEREST REASSESSED',
   		@Ls_DescriptionEventIntRevkd_TEXT                       VARCHAR(100) = 'INTEREST REVOKED',
   		@Ls_DescriptionEventIntRevkAr_TEXT                      VARCHAR(100) = 'INTEREST REVOKED ARREAR < $501',
   		@Ls_DescriptionEventIntRevkMn_TEXT                      VARCHAR(100) = 'INTEREST REVOKED MIN PAID',
   		@Ls_DescriptionEventModify_TEXT                         VARCHAR(100) = 'MODIFICATION',
   		@Ls_DescriptionEventPayment_TEXT                        VARCHAR(100) = 'PAYMENT',
   		@Ls_DescriptionEventRetAdj_TEXT                         VARCHAR(100) = 'RETRO ADJUSTMENT',
   		@Ls_DescriptionEventRetCrdRefund_TEXT                   VARCHAR(100) = 'RETRO CREDIT/REFUND',
   		@Ls_DescriptionEventRetFutRelease_TEXT                  VARCHAR(100) = 'RETRO FUTURE RELEASE',
   		@Ls_DescriptionEventRetIntAssd_TEXT                     VARCHAR(100) = 'RETRO INTEREST ASSESSED',
   		@Ls_DescriptionEventRetIntReassd_TEXT                   VARCHAR(100) = 'RETRO INTEREST REASSESSED',
   		@Ls_DescriptionEventRetIntRevkd_TEXT                    VARCHAR(100) = 'RETRO INTEREST REVOKED',
   		@Ls_DescriptionEventRetIntRevkAr_TEXT                   VARCHAR(100) = 'RETRO INTEREST REVOKED ARREAR < $501',
   		@Ls_DescriptionEventRetIntRevkMn_TEXT                   VARCHAR(100) = 'RETRO INTEREST REVOKED MIN PAID',
   		@Ls_DescriptionEventRetModify_TEXT                      VARCHAR(100) = 'RETRO MODIFICATION',
   		@Ls_DescriptionEventRetPayment_TEXT                     VARCHAR(100) = 'RETRO PAYMENT',
   		@Ls_DescriptionEventRetReversal_TEXT                    VARCHAR(100) = 'RETRO REVERSAL',
   		@Ls_DescriptionEventReversal_TEXT                       VARCHAR(100) = 'REVERSAL',
   		@Ls_DescriptionEventStatusChng_TEXT                     VARCHAR(100) = 'Status_CODE CHANGE',
   		@Lc_Null_TEXT                                           CHAR(1) = '',
   		@Lc_Space_TEXT                                          CHAR(1) = ' ',
   		@Lc_TypeRecordOriginal_CODE                             CHAR(1) = 'O';


WITH Lsup_WITH AS(
  SELECT a.EventFunctionalSeq_NUMB
         , a.Distribute_DATE,
         c.Case_IDNO ,
         d.Order_IDNO ,
         c.TypeDebt_CODE,c.MemberMci_IDNO, c.Fips_CODE,
         d.File_ID,
         a.TypeWelfare_CODE ,
         a.TypeRecord_CODE ,
         a.EventGlobalSeq_NUMB ,
         a.TransactionCurSup_AMNT ,
        a.OweTotCurSup_AMNT , a.AppTotCurSup_AMNT,
        a.TransactionNaa_AMNT,a.OweTotNaa_AMNT,a.AppTotNaa_AMNT,
         a.TransactionPaa_AMNT,a.OweTotPaa_AMNT,a.AppTotPaa_AMNT,
          a.TransactionTaa_AMNT,a.OweTotTaa_AMNT,a.AppTotTaa_AMNT,
          a.TransactionCaa_AMNT,a.OweTotCaa_AMNT,a.AppTotCaa_AMNT,
             a.TransactionUpa_AMNT,a.OweTotUpa_AMNT,a.AppTotUpa_AMNT,
             a.TransactionUda_AMNT,a.OweTotUda_AMNT,a.AppTotUda_AMNT,
             a.TransactionIvef_AMNT,a.OweTotIvef_AMNT,a.AppTotIvef_AMNT,
             a.TransactionMedi_AMNT,a.OweTotMedi_AMNT,a.AppTotMedi_AMNT,
             a.TransactionNonIvd_AMNT,a.OweTotNonIvd_AMNT,a.AppTotNonIvd_AMNT,
             a.TransactionFuture_AMNT,a.AppTotFuture_AMNT,
        a.OrderSeq_NUMB,a.ObligationSeq_NUMB,a.TransactionNffc_AMNT,
        a.OweTotNffc_AMNT , a.AppTotNffc_AMNT
         FROM LSUP_Y1   a
         JOIN
         OBLE_Y1   c
         ON
         c.Case_IDNO = a.Case_IDNO AND
         c.OrderSeq_NUMB = a.OrderSeq_NUMB AND
         c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
         JOIN
         SORD_Y1   d
         ON
         d.Case_IDNO = a.Case_IDNO AND
         d.OrderSeq_NUMB = a.OrderSeq_NUMB
      WHERE
         a.SupportYearMonth_NUMB =@An_SupportYearMonth_NUMB AND
         c.BeginObligation_DATE =
         (
            SELECT MAX(e.BeginObligation_DATE)
            FROM OBLE_Y1   e
            WHERE
               e.Case_IDNO = a.Case_IDNO AND
               e.OrderSeq_NUMB = a.OrderSeq_NUMB AND
               e.ObligationSeq_NUMB = a.ObligationSeq_NUMB AND
               e.EndValidity_DATE = @Ld_High_DATE
         ) AND
         c.EndValidity_DATE = @Ld_High_DATE AND
         d.EndValidity_DATE = @Ld_High_DATE AND
         a.Case_IDNO=@An_Case_IDNO AND
         a.OrderSeq_NUMB=@An_OrderSeq_NUMB
		AND( a.ObligationSeq_NUMB IN
         (
           SELECT DISTINCT ObligationSeq_NUMB
            FROM OBLE_Y1 o
            WHERE
               o.Case_IDNO =@An_Case_IDNO AND
               o.OrderSeq_NUMB = @An_OrderSeq_NUMB AND
               o.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE,o.TypeDebt_CODE) AND
               o.ObligationSeq_NUMB = ISNULL(@An_ObligationSeq_NUMB,o.ObligationSeq_NUMB) AND
               o.EndValidity_DATE = @Ld_High_DATE
         ))               
     )
SELECT Z.Event_DATE,
         Z.EventFunctionalSeq_NUMB ,
            Z.DescriptionEvent_TEXT,
            Z.ObligationKey_TEXT,
            Z.ProgramType_CODE,
            Z.Transaction_AMNT,
            Z.DescriptionBucket_TEXT,
            Z.Begin_AMNT,
            Z.End_AMNT ,
            Z.RowCount_NUMB
       FROM (SELECT Y.Event_DATE, Y.EventFunctionalSeq_NUMB, Y.DescriptionEvent_TEXT,
                    Y.ObligationKey_TEXT, Y.ProgramType_CODE, Y.Transaction_AMNT,
                    Y.DescriptionBucket_TEXT, Y.End_AMNT, Y.Begin_AMNT,
                    Y.ORD_ROWNUM AS rnm, Y.RowCount_NUMB
               FROM (SELECT X.Event_DATE, X.EventFunctionalSeq_NUMB,
                            X.DescriptionEvent_TEXT, X.ObligationKey_TEXT,
                            X.ProgramType_CODE, X.Transaction_AMNT,
                            X.DescriptionBucket_TEXT, X.End_AMNT, X.Begin_AMNT,
                            X.ORD_ROWNUM, COUNT (1) OVER () AS RowCount_NUMB
                       FROM (SELECT a.Event_DATE, a.EventFunctionalSeq_NUMB,
                                    CASE a.EventFunctionalSeq_NUMB
                                       WHEN @Li_ObligationCreation1010_NUMB
                                          THEN CASE RTRIM(LTRIM(a.DescriptionBucket_TEXT))
                                                 WHEN @Ls_DescriptionBucketCd_TEXT
                                                    THEN @Ls_DescriptionEventModify_TEXT
                                                 ELSE @Ls_DescriptionEventRetModify_TEXT
                                              END
                                       WHEN @Li_ObligationModification1020_NUMB
                                          THEN CASE RTRIM(LTRIM(a.DescriptionBucket_TEXT))
                                                 WHEN @Ls_DescriptionBucketCd_TEXT
                                                    THEN @Ls_DescriptionEventModify_TEXT
                                                 ELSE @Ls_DescriptionEventRetModify_TEXT
                                              END
                                       WHEN @Li_ArrearAdjustment1030_NUMB
                                          THEN CASE RTRIM(LTRIM(a.DescriptionBucket_TEXT))
                                                 WHEN @Lc_Null_TEXT
                                                    THEN @Ls_DescriptionEventAdj_TEXT
                                                 ELSE CASE (SELECT MIN
                                                                      (b.SupportYearMonth_NUMB
                                                                      )
                                                              FROM LSUP_Y1 b
                                                             WHERE b.Case_IDNO =
                                                                        a.Case_IDNO
                                                               AND b.EventGlobalSeq_NUMB =
                                                                      a.EventGlobalSeq_NUMB)
                                                 WHEN @An_SupportYearMonth_NUMB
                                                    THEN @Ls_DescriptionEventAdj_TEXT
                                                 ELSE @Ls_DescriptionEventRetAdj_TEXT
                                              END
                                              END
                                       WHEN @Ln_SeqEventFn1031_NUMB
                                          THEN @Ls_DescriptionEventAdj_TEXT
                                       WHEN @Li_DirectPayCredit1040_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventCrdRefund_TEXT
                                                 ELSE @Ls_DescriptionEventRetCrdRefund_TEXT
                                       END
                                       WHEN @Li_Accrual1050_NUMB
                                          THEN @Ls_DescriptionEventAccrual_TEXT
                                     WHEN @Ln_SeqEventFn1051_NUMB
                                          THEN @Ls_DescriptionEventModify_TEXT
                                       WHEN @Li_CircularRuleRecord1070_NUMB
                                          THEN @Ls_DescriptionEventCirRule_TEXT
                                       WHEN @Li_ChangeLsupForParticipantTanfStatusChange1080_NUMB
                                          THEN @Ls_DescriptionEventStatusChng_TEXT
                                       WHEN @Li_ReceiptReversed1250_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventReversal_TEXT
                                                 ELSE @Ls_DescriptionEventRetReversal_TEXT
                                              END
                                       WHEN @Li_ManuallyDistributeReceipt1810_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventPayment_TEXT
                                                 ELSE @Ls_DescriptionEventRetPayment_TEXT
                                              END
                                       WHEN @Li_ReceiptDistributed1820_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventPayment_TEXT
                                                 ELSE @Ls_DescriptionEventRetPayment_TEXT
                                              END
                                       WHEN @Li_FutureHoldRelease1825_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventFutRelease_TEXT
                                                 ELSE @Ls_DescriptionEventRetFutRelease_TEXT
                                              END
                                       WHEN @Li_TanfGrantSplit2730_NUMB
                                          THEN @Ls_DescriptionEventGrantSplit_TEXT
                                       WHEN @Ln_SeqEventFn3050_NUMB
                                          THEN @Ls_DescriptionEventCaseCl_TEXT
                                       WHEN @Li_InterestAssessed3150_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                              THEN @Ls_DescriptionEventIntAssd_TEXT
                                                 ELSE @Ls_DescriptionEventRetIntAssd_TEXT
                                              END
                                       WHEN @Li_AssessedInterestRevoked3180_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventIntRevkd_TEXT
                                                 ELSE @Ls_DescriptionEventRetIntRevkd_TEXT
                                              END
 									   WHEN @Li_InterestReassessed3190_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventIntReassd_TEXT
                                                 ELSE @Ls_DescriptionEventRetIntReassd_TEXT
                                              END
                                       WHEN @Li_AssessedInterestRevokedArrear500OrLess3200_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventIntRevkAr_TEXT
                                                 ELSE @Ls_DescriptionEventRetIntRevkAr_TEXT
                                              END
                                       WHEN @Li_AssessedInterestRevokedMinimumPaid3210_NUMB
                                          THEN CASE a.TypeRecord_CODE
                                                 WHEN @Lc_TypeRecordOriginal_CODE
                                                    THEN @Ls_DescriptionEventIntRevkMn_TEXT
                                                 ELSE @Ls_DescriptionEventRetIntRevkMn_TEXT
                                              END
                                       WHEN @Li_ReceiptOnHold1420_NUMB
                                          THEN @Ls_DescriptionEventHeldRcpts_TEXT
                                       ELSE @Ls_DescriptionEventConversionErr_TEXT
                                    END AS DescriptionEvent_TEXT,
                                      ISNULL (CONVERT(VARCHAR,a.Case_IDNO),
                                              @Lc_Null_TEXT
                                             ) +
                                     @Lc_Space_TEXT +
                                     ISNULL (a.ObligationKey_TEXT, @Lc_Null_TEXT)+
                                     @Lc_Space_TEXT +
                           ISNULL (CONVERT(VARCHAR,a.File_ID), @Lc_Null_TEXT)
                                                             AS ObligationKey_TEXT,
                                    a.TypeWelfare_CODE AS ProgramType_CODE,
                                    a.Transaction_AMNT, a.DescriptionBucket_TEXT,
                                    a.EndingBalance_AMNT AS End_AMNT,
                                    CASE a.EventFunctionalSeq_NUMB
                                       WHEN @Li_ObligationCreation1010_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_ObligationModification1020_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_ArrearAdjustment1030_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Ln_SeqEventFn1031_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_DirectPayCredit1040_NUMB
                                          THEN   a.EndingBalance_AMNT
                                                - a.Transaction_AMNT
                                       WHEN @Li_Accrual1050_NUMB
                                          THEN   a.EndingBalance_AMNT
                              - a.Transaction_AMNT
                                       WHEN @Ln_SeqEventFn1051_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_CircularRuleRecord1070_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_ChangeLsupForParticipantTanfStatusChange1080_NUMB
                                          THEN   a.EndingBalance_AMNT
                     - a.Transaction_AMNT
                                       WHEN @Li_ReceiptReversed1250_NUMB
                                          THEN CASE a.DescriptionBucket_TEXT
                                                 WHEN @Ls_DescriptionEventFutures_TEXT
                                                    THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                                 ELSE   a.EndingBalance_AMNT
                                                      + a.Transaction_AMNT
                                              END
                                       WHEN @Li_ManuallyDistributeReceipt1810_NUMB
                                          THEN CASE a.DescriptionBucket_TEXT
                                                 WHEN @Ls_DescriptionEventFutures_TEXT
                                                    THEN   a.EndingBalance_AMNT
                                                         - a.Transaction_AMNT
                                                 ELSE   a.EndingBalance_AMNT
                                                     +  a.Transaction_AMNT
                                              END
                                       WHEN @Li_ReceiptDistributed1820_NUMB
                                          THEN CASE a.DescriptionBucket_TEXT
                                                 WHEN @Ls_DescriptionEventFutures_TEXT
                                                    THEN   a.EndingBalance_AMNT
                                                         - a.Transaction_AMNT
                                                 ELSE   a.EndingBalance_AMNT
                                                      + a.Transaction_AMNT
                                              END
                                       WHEN @Li_FutureHoldRelease1825_NUMB
                                          THEN CASE a.DescriptionBucket_TEXT
                                                 WHEN @Ls_DescriptionEventFutures_TEXT
                                                    THEN   a.EndingBalance_AMNT
                                                         - a.Transaction_AMNT
                                                 ELSE   a.EndingBalance_AMNT
                                                      + a.Transaction_AMNT
                                              END
                                       WHEN @Li_TanfGrantSplit2730_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Ln_SeqEventFn3050_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_InterestAssessed3150_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                         WHEN @Li_AssessedInterestRevoked3180_NUMB
                              THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_InterestReassessed3190_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_AssessedInterestRevokedArrear500OrLess3200_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_AssessedInterestRevokedMinimumPaid3210_NUMB
                                          THEN   a.EndingBalance_AMNT
                                               - a.Transaction_AMNT
                                       WHEN @Li_ReceiptOnHold1420_NUMB
                                          THEN @Li_Zero_NUMB
                                       ELSE   a.EndingBalance_AMNT
                                            - a.Transaction_AMNT
                                    END AS Begin_AMNT,
                                ROW_NUMBER() OVER(ORDER BY a.Event_DATE, a.EventGlobalSeq_NUMB)  AS ORD_ROWNUM
                                FROM (
         SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO ,
         a.Order_IDNO ,
         ISNULL(a.TypeDebt_CODE,'' ) + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE, '') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE,
         a.TypeRecord_CODE ,
         a.EventGlobalSeq_NUMB ,
         0 AS BeginBalance_AMNT,
         a.TransactionCurSup_AMNT AS Transaction_AMNT,
         @Lc_DescriptionBucketCur_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH a
      WHERE
       a.TransactionCurSup_AMNT != 0
 UNION
 SELECT
                CASE a.EventFunctionalSeq_NUMB
                   WHEN  @Li_Hundred_NUMB  THEN
                      (
                         SELECT g.EffectiveEvent_DATE
                         FROM GLEV_Y1   g
                         WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
                      )
                   ELSE a.Distribute_DATE
                END AS Event_DATE,
                a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
                a.Case_IDNO,
                a.Order_IDNO ,
                ISNULL(a.TypeDebt_CODE,'') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE,'' ) AS ObligationKey_TEXT,
                a.File_ID,
                a.TypeWelfare_CODE,
                a.TypeRecord_CODE ,
                a.EventGlobalSeq_NUMB ,
                0 AS BeginBalance_AMNT,
                (a.TransactionNaa_AMNT - CASE a.TypeDebt_CODE
                   WHEN 'DS' THEN 0
                   ELSE CASE a.TypeWelfare_CODE
                      WHEN 'N' THEN a.TransactionCurSup_AMNT
                      WHEN 'M' THEN a.TransactionCurSup_AMNT
                      ELSE 0
                   END
                END) AS Transaction_AMNT,
                @Lc_DescriptionBucketNa_TEXT AS DescriptionBucket_TEXT,
                (a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) AS EndingBalance_AMNT
             FROM Lsup_WITH a
             WHERE
                (a.TransactionNaa_AMNT -
                CASE a.TypeDebt_CODE
                   WHEN 'DS' THEN 0
             ELSE  CASE a.TypeWelfare_CODE
                         WHEN 'N' THEN a.TransactionCurSup_AMNT
                         WHEN 'M' THEN a.TransactionCurSup_AMNT
                         ELSE 0
                      END
                END) != 0
 UNION
 SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO AS Case_IDNO,
         a.Order_IDNO AS Order_IDNO,
        ISNULL(a.TypeDebt_CODE,'') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE,'') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE AS TypeWelfare_CODE,
         a.TypeRecord_CODE AS TypeRecord_CODE,
         a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
         0 AS BeginBalance_AMNT,
         (a.TransactionPaa_AMNT - CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE CASE a.TypeWelfare_CODE
               WHEN 'A' THEN a.TransactionCurSup_AMNT
               ELSE 0
            END
         END) AS Transaction_AMNT,
         @Lc_DescriptionBucketPa_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH  a
      WHERE
         (a.TransactionPaa_AMNT -
         CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE CASE a.TypeWelfare_CODE
                  WHEN 'A' THEN a.TransactionCurSup_AMNT
                  ELSE 0
               END
         END) != 0
         UNION
         SELECT
           CASE a.EventFunctionalSeq_NUMB
              WHEN  @Li_Hundred_NUMB  THEN
                 (
                    SELECT g.EffectiveEvent_DATE
                    FROM GLEV_Y1   g
                    WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
                 )
              ELSE a.Distribute_DATE
           END AS Event_DATE,
           a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
           a.Case_IDNO AS Case_IDNO,
           a.Order_IDNO AS Order_IDNO,
           ISNULL(a.TypeDebt_CODE,'') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE,'') AS ObligationKey_TEXT,
           a.File_ID,
           a.TypeWelfare_CODE AS TypeWelfare_CODE,
           a.TypeRecord_CODE AS TypeRecord_CODE,
           a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
           0 AS BeginBalance_AMNT,
           a.TransactionTaa_AMNT ,
           @Lc_DescriptionBucketTa_TEXT AS DescriptionBucket_TEXT,
           (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) AS EndingBalance_AMNT
        FROM Lsup_WITH  a
        WHERE
           a.TransactionTaa_AMNT != 0
           UNION
SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO AS Case_IDNO,
         a.Order_IDNO AS Order_IDNO,
        ISNULL(a.TypeDebt_CODE, '') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE, '') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE AS TypeWelfare_CODE,
         a.TypeRecord_CODE AS TypeRecord_CODE,
         a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
         0 AS BeginBalance_AMNT,
         a.TransactionCaa_AMNT AS Transaction_AMNT,
         @Lc_DescriptionBucketCa_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH  a
      WHERE
         a.TransactionCaa_AMNT != 0
         UNION
         SELECT
             CASE a.EventFunctionalSeq_NUMB
                WHEN  @Li_Hundred_NUMB  THEN
                   (
                      SELECT g.EffectiveEvent_DATE
                      FROM GLEV_Y1   g
                      WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
                   )
                ELSE a.Distribute_DATE
             END AS Event_DATE,
             a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
             a.Case_IDNO AS Case_IDNO,
             a.Order_IDNO AS Order_IDNO,
             ISNULL(a.TypeDebt_CODE,'') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE,'') AS ObligationKey_TEXT,
             a.File_ID,
             a.TypeWelfare_CODE AS TypeWelfare_CODE,
             a.TypeRecord_CODE AS TypeRecord_CODE,
             a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
             0 AS BeginBalance_AMNT,
             a.TransactionUpa_AMNT ,
             @Lc_DescriptionBucketUpa_TEXT AS DescriptionBucket_TEXT,
             (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) AS EndingBalance_AMNT
          FROM Lsup_WITH  a
          WHERE
             a.TransactionUpa_AMNT != 0
             UNION
             SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO AS Case_IDNO,
         a.Order_IDNO AS Order_IDNO,
         ISNULL(a.TypeDebt_CODE,'' ) + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') + ISNULL(a.Fips_CODE,'') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE AS TypeWelfare_CODE,
         a.TypeRecord_CODE AS TypeRecord_CODE,
         a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
         0 AS BeginBalance_AMNT,
         a.TransactionUda_AMNT ,
         @Lc_DescriptionBucketUda_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotUda_AMNT - a.AppTotUda_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH  a
      WHERE
         a.TransactionUda_AMNT != 0
              UNION
              SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB,
         a.Case_IDNO,
         a.Order_IDNO,
         ISNULL(a.TypeDebt_CODE, '') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO), '') + ISNULL(a.Fips_CODE, '') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE,
         a.TypeRecord_CODE,
         a.EventGlobalSeq_NUMB,
         0 AS BeginBalance_AMNT,
         (a.TransactionIvef_AMNT - CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE CASE a.TypeWelfare_CODE
               WHEN 'F' THEN a.TransactionCurSup_AMNT
               ELSE 0
            END
         END) AS Transaction_AMNT,
         @Lc_DescriptionBucketIvef_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH  a
      WHERE
         (a.TransactionIvef_AMNT -
         CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE
               CASE a.TypeWelfare_CODE
                  WHEN 'F' THEN a.TransactionCurSup_AMNT
                  ELSE 0
               END
         END) != 0
         UNION
SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO,
         a.Order_IDNO,
         ISNULL(a.TypeDebt_CODE,'') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'') +  ISNULL(a.Fips_CODE,'') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE,
         a.TypeRecord_CODE ,
         a.EventGlobalSeq_NUMB ,
         0 AS BeginBalance_AMNT,
         (a.TransactionMedi_AMNT - CASE a.TypeDebt_CODE
            WHEN 'DS' THEN a.TransactionCurSup_AMNT
            ELSE 0
         END) AS Transaction_AMNT,
         @Lc_DescriptionBucketMedi_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH  a
      WHERE
         (a.TransactionMedi_AMNT -
         CASE a.TypeDebt_CODE
            WHEN 'DS' THEN a.TransactionCurSup_AMNT
            ELSE 0
         END) != 0
         UNION
  SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO,
         a.Order_IDNO ,
         ISNULL(a.TypeDebt_CODE, '') + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'' )+ ISNULL(a.Fips_CODE,'' ) AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE,
         a.TypeRecord_CODE,
         a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
         0 AS BeginBalance_AMNT,
  (a.TransactionNffc_AMNT - CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE CASE a.TypeWelfare_CODE
               WHEN 'J' THEN a.TransactionCurSup_AMNT
               ELSE 0
            END
         END) AS Transaction_AMNT,
         @Lc_DescriptionBucketNffc_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) AS EndingBalance_AMNT
      FROM Lsup_WITH  a
      WHERE
         (a.TransactionNffc_AMNT -
         CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE  CASE a.TypeWelfare_CODE
                  WHEN 'J' THEN a.TransactionCurSup_AMNT
                  ELSE 0
               END
         END) != 0
    UNION

   SELECT
         CASE a.EventFunctionalSeq_NUMB
            WHEN  @Li_Hundred_NUMB  THEN
               (
                  SELECT g.EffectiveEvent_DATE
                  FROM GLEV_Y1   g
                  WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
               )
            ELSE a.Distribute_DATE
         END AS Event_DATE,
         a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
         a.Case_IDNO,
         a.Order_IDNO,
         ISNULL(a.TypeDebt_CODE,'' ) + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO),'' ) + ISNULL(a.Fips_CODE,'') AS ObligationKey_TEXT,
         a.File_ID,
         a.TypeWelfare_CODE,
         a.TypeRecord_CODE,
         a.EventGlobalSeq_NUMB,
         0 AS BeginBalance_AMNT,
         (a.TransactionNonIvd_AMNT - CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE CASE a.TypeWelfare_CODE
               WHEN 'H' THEN a.TransactionCurSup_AMNT
               ELSE 0
            END
         END) AS Transaction_AMNT,
         @Lc_DescriptionBucketNivd_TEXT AS DescriptionBucket_TEXT,
         (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) AS EndingBalance_AMNT
		FROM Lsup_WITH  a
      WHERE
         (a.TransactionNonIvd_AMNT -
         CASE a.TypeDebt_CODE
            WHEN 'DS' THEN 0
            ELSE  CASE a.TypeWelfare_CODE
                  WHEN 'H' THEN a.TransactionCurSup_AMNT
                  ELSE 0
               END
         END) != 0

         UNION

         SELECT
              CASE a.EventFunctionalSeq_NUMB
                 WHEN  @Li_Hundred_NUMB  THEN
                    (
                       SELECT g.EffectiveEvent_DATE
                       FROM GLEV_Y1   g
                       WHERE g.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
                    )
                 ELSE a.Distribute_DATE
              END AS Event_DATE,
              a.EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
              a.Case_IDNO AS Case_IDNO,
              a.Order_IDNO AS Order_IDNO,
              ISNULL(a.TypeDebt_CODE,'' ) + ISNULL(CONVERT(VARCHAR,a.MemberMci_IDNO), '') + ISNULL(a.Fips_CODE,'' ) AS ObligationKey_TEXT,
              a.File_ID,
              a.TypeWelfare_CODE AS TypeWelfare_CODE,
              a.TypeRecord_CODE AS TypeRecord_CODE,
              a.EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
              0 AS BeginBalance_AMNT,
              a.TransactionFuture_AMNT ,
              @Lc_DescriptionBucketFutures_TEXT AS DescriptionBucket_TEXT,
              a.AppTotFuture_AMNT AS EndingBalance_AMNT
           FROM Lsup_WITH  a
           WHERE
              a.TransactionFuture_AMNT != 0
               UNION  
SELECT  
         aa.Batch_DATE AS Event_DATE,  
         @Li_ReceiptOnHold1420_NUMB AS EventFunctionalSeq_NUMB,  
         ISNULL(aa.Case_IDNO,'') AS Case_IDNO,  
         @Li_Zero_NUMB AS Order_IDNO,  
         @Lc_Space_TEXT AS ObligationKey_TEXT,  
         @Lc_Space_TEXT AS File_ID,
         @Lc_Space_TEXT AS TypeWelfare_CODE,  
         @Lc_Space_TEXT AS TypeRecord_CODE,  
         @Li_Zero_NUMB AS EventGlobalSeq_NUMB,  
         @Li_Zero_NUMB AS BeginBalance_AMNT,  
         SUM(aa.ToDistribute_AMNT) AS Transaction_AMNT,  
         @Lc_Space_TEXT AS DescriptionBucket_TEXT,  
         @Li_Zero_NUMB AS EndingBalance_AMNT  
      FROM RCTH_Y1   aa  
      WHERE  
         aa.PayorMCI_IDNO = @An_MemberMci_IDNO AND  
         aa.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE AND  
         aa.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE AND  
         aa.EndValidity_DATE = @Ld_High_DATE  AND  
         NOT EXISTS  
         (  
            SELECT 1   
            FROM RCTH_Y1   z  
            WHERE  
               z.Batch_DATE = aa.Batch_DATE AND  
               z.Batch_NUMB = aa.Batch_NUMB AND  
               z.SeqReceipt_NUMB = aa.SeqReceipt_NUMB AND  
               z.SourceBatch_CODE = aa.SourceBatch_CODE AND  
               z.BackOut_INDC = @Lc_Yes_INDC AND  
               z.EndValidity_DATE = @Ld_High_DATE)  
      GROUP BY aa.Batch_DATE, aa.Case_IDNO
      ) AS a
) X) Y
              WHERE (ORD_ROWNUM <= @Ai_RowTo_NUMB) OR (@Ai_RowTo_NUMB = @Li_Zero_NUMB) )Z
      WHERE (Z.rnm >= @Ai_RowFrom_NUMB) OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB);


  END; --End of LSUP_RETRIEVE_S123

GO
