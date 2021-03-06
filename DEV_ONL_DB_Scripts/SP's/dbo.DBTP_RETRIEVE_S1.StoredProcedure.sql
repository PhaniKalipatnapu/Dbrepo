/****** Object:  StoredProcedure [dbo].[DBTP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBTP_RETRIEVE_S1] (
 @Ac_TypeDebt_CODE      CHAR(2),
 @Ac_Interstate_INDC    CHAR(1),
 @Ac_SourceReceipt_CODE CHAR(2),
 @Ac_TypeWelfare_CODE   CHAR(1)
 )
AS
 /*        
 *     PROCEDURE NAME     : DBTP_RETRIEVE_S1        
  *     DESCRIPTION       : Retrieves distribution priority for the current support and arrears buckets.       
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011        
  *     MODIFIED BY       :         
  *     MODIFIED ON       :         
  *     VERSION NO        : 1        
 */
 BEGIN
  DECLARE @Ld_High_DATE                             DATE = '12/31/9999',
          @Lc_ArrearCurrentSupport_CODE             CHAR(5) = 'C',
          @Lc_ArrearExpectPayAmount_CODE            CHAR(5) = 'E',
          @Lc_ArrearConditionallyAssigned_CODE      CHAR(5) = 'ACAA',
          @Lc_ArrearIvef_CODE                       CHAR(5) = 'AIVEF',
          @Lc_ArrearMedicaid_CODE                   CHAR(5) = 'AMEDI',
          @Lc_ArrearNeverAssigned_CODE              CHAR(5) = 'ANAA',
          @Lc_ArrearNffc_CODE                       CHAR(5) = 'ANFFC',
          @Lc_ArrearNonIvd_CODE                     CHAR(5) = 'ANIVD',
          @Lc_ArrearPermanentlyAssigned_CODE        CHAR(5) = 'APAA',
          @Lc_ArrearTemporarilyAssigned_CODE        CHAR(5) = 'ATAA',
          @Lc_ArrearUnassignedDuringAssistance_CODE CHAR(5) = 'AUDA',
          @Lc_ArrearUnassignedPriorAssistance_CODE  CHAR(5) = 'AUPA';

  SELECT a.SourceReceipt_CODE,
         a.Interstate_INDC,
         a.TypeWelfare_CODE,
         a.PrDistribute_QNTY AS PrDistributeC1_QNTY,
         b.PrDistribute_QNTY AS PrDistributeE1_QNTY,
         c.PrDistribute_QNTY AS PrDistributePa_QNTY,
         d.PrDistribute_QNTY AS PrDistributeUda_QNTY,
         e.PrDistribute_QNTY AS PrDistributeTa_QNTY,
         f.PrDistribute_QNTY AS PrDistributeCa_QNTY,
         g.PrDistribute_QNTY AS PrDistributeUpa_QNTY,
         h.PrDistribute_QNTY AS PrDistributeNa_QNTY,
         i.PrDistribute_QNTY AS PrDistributeIvef_QNTY,
         l.PrDistribute_QNTY AS PrDistributeNffc_QNTY,
         m.PrDistribute_QNTY AS PrDistributeNonIvd_QNTY,
         j.PrDistribute_QNTY AS PrDistributeMedi_QNTY,
         a.TransactionEventSeq_NUMB AS TransactionEventC1Seq_NUMB,
         b.TransactionEventSeq_NUMB AS TransactionEventE1Seq_NUMB,
         c.TransactionEventSeq_NUMB AS TransactionEventPaSeq_NUMB,
         d.TransactionEventSeq_NUMB AS TransactionEventUdaSeq_NUMB,
         e.TransactionEventSeq_NUMB AS TransactionEventTaSeq_NUMB,
         f.TransactionEventSeq_NUMB AS TransactionEventCaSeq_NUMB,
         g.TransactionEventSeq_NUMB AS TransactionEventUpaSeq_NUMB,
         h.TransactionEventSeq_NUMB AS TransactionEventNaSeq_NUMB,
         i.TransactionEventSeq_NUMB AS TransactionEventIvefSeq_NUMB,
         l.TransactionEventSeq_NUMB AS TransactionEventNffcSeq_NUMB,
         m.TransactionEventSeq_NUMB AS TransactionEventNonIvdSeq_NUMB,
         j.TransactionEventSeq_NUMB AS TransactionEventMediSeq_NUMB
    FROM DBTP_Y1 a
         JOIN DBTP_Y1 b
          ON b.TypeDebt_CODE = a.TypeDebt_CODE
             AND b.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND b.EndValidity_DATE = a.EndValidity_DATE
             AND b.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND b.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 c
          ON c.TypeDebt_CODE = a.TypeDebt_CODE
             AND c.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND c.EndValidity_DATE = a.EndValidity_DATE
             AND c.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND c.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 d
          ON d.TypeDebt_CODE = a.TypeDebt_CODE
             AND d.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND d.EndValidity_DATE = a.EndValidity_DATE
             AND d.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND d.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 e
          ON e.TypeDebt_CODE = a.TypeDebt_CODE
             AND e.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND e.EndValidity_DATE = a.EndValidity_DATE
             AND e.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND e.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 f
          ON f.TypeDebt_CODE = a.TypeDebt_CODE
             AND f.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND f.EndValidity_DATE = a.EndValidity_DATE
             AND f.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND f.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 g
          ON g.TypeDebt_CODE = a.TypeDebt_CODE
             AND g.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND g.EndValidity_DATE = a.EndValidity_DATE
             AND g.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND g.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 h
          ON h.TypeDebt_CODE = a.TypeDebt_CODE
             AND h.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND h.EndValidity_DATE = a.EndValidity_DATE
             AND h.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND h.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 i
          ON i.TypeDebt_CODE = a.TypeDebt_CODE
             AND i.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND i.EndValidity_DATE = a.EndValidity_DATE
             AND i.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND i.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 j
          ON j.TypeDebt_CODE = a.TypeDebt_CODE
             AND j.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND j.EndValidity_DATE = a.EndValidity_DATE
             AND j.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND j.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 l
          ON l.TypeDebt_CODE = a.TypeDebt_CODE
             AND l.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND l.EndValidity_DATE = a.EndValidity_DATE
             AND l.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND l.Interstate_INDC = a.Interstate_INDC
         JOIN DBTP_Y1 m
          ON m.TypeDebt_CODE = a.TypeDebt_CODE
             AND m.SourceReceipt_CODE = a.SourceReceipt_CODE
             AND m.EndValidity_DATE = a.EndValidity_DATE
             AND m.TypeWelfare_CODE = a.TypeWelfare_CODE
             AND m.Interstate_INDC = a.Interstate_INDC
         JOIN DEBT_Y1 k
          ON k.TypeDebt_CODE = a.TypeDebt_CODE
             AND k.Interstate_INDC = a.Interstate_INDC
             AND k.EndValidity_DATE = a.EndValidity_DATE
   WHERE a.TypeBucket_CODE = @Lc_ArrearCurrentSupport_CODE
     AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.Interstate_INDC = ISNULL(@Ac_Interstate_INDC, a.Interstate_INDC)
     AND a.TypeWelfare_CODE = ISNULL(@Ac_TypeWelfare_CODE, a.TypeWelfare_CODE)
     AND a.SourceReceipt_CODE = ISNULL(@Ac_SourceReceipt_CODE, a.SourceReceipt_CODE)
     AND b.TypeBucket_CODE = @Lc_ArrearExpectPayAmount_CODE
     AND c.TypeBucket_CODE = @Lc_ArrearPermanentlyAssigned_CODE
     AND d.TypeBucket_CODE = @Lc_ArrearUnassignedDuringAssistance_CODE
     AND e.TypeBucket_CODE = @Lc_ArrearTemporarilyAssigned_CODE
     AND f.TypeBucket_CODE = @Lc_ArrearConditionallyAssigned_CODE
     AND g.TypeBucket_CODE = @Lc_ArrearUnassignedPriorAssistance_CODE
     AND h.TypeBucket_CODE = @Lc_ArrearNeverAssigned_CODE
     AND i.TypeBucket_CODE = @Lc_ArrearIvef_CODE
     AND l.TypeBucket_CODE = @Lc_ArrearNffc_CODE
     AND m.TypeBucket_CODE = @Lc_ArrearNonIvd_CODE
     AND j.TypeBucket_CODE = @Lc_ArrearMedicaid_CODE
   ORDER BY a.SourceReceipt_CODE,
            a.TypeWelfare_CODE;
 END; --End of DBTP_RETRIEVE_S1

GO
