/****** Object:  StoredProcedure [dbo].[LWEL_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LWEL_RETRIEVE_S22] (
 @An_MemberMci_IDNO               NUMERIC(10, 0),
 @Ad_ReceiptFrom_DATE             DATE,
 @Ad_ReceiptTo_DATE               DATE,
 @An_TotDistributeCurGrant_AMNT   NUMERIC(15, 2) OUTPUT,
 @An_TotDisburseIvaAgency_AMNT    NUMERIC(15, 2) OUTPUT,
 @An_TotDistributeUrpaCur_AMNT    NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : LWEL_RETRIEVE_S22
  *     DESCRIPTION       : Retrieves grant total of current, Excess over current and URPA_current welfare distributes for the given membermci id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_TotDistributeCurGrant_AMNT = NULL,
         @An_TotDisburseIvaAgency_AMNT = NULL,
         @An_TotDistributeUrpaCur_AMNT = NULL;

  DECLARE @Ld_High_DATE                   DATE = '12/31/9999',
          @Li_Zero_NUMB                   SMALLINT = 0,
          @Lc_CaseRelationshipA_CODE      CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_CaseMemberStatusC_CODE      CHAR(1) = 'C',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_TypeDisburseCgpaa_CODE      CHAR(5) = 'CGPAA',
          @Lc_TypeDisburseRgmso_CODE      CHAR(5) = 'RGMSO',
          @Lc_TypeDisburseUamso_CODE      CHAR(5) = 'UAMSO',
          @Lc_TypeDisburse4amso_CODE      CHAR(5) = '4AMSO',
          @Lc_TypeDisburseFcmso_CODE      CHAR(5) = 'FCMSO',
          @Lc_TypeDisburseCgive_CODE      CHAR(5) = 'CGIVE',
          @Lc_TypeDisbursePgpaa_CODE      CHAR(5) = 'PGPAA',
          @Lc_TypeDisburseAgpaa_CODE      CHAR(5) = 'AGPAA',
          @Lc_TypeDisburseAgcaa_CODE      CHAR(5) = 'AGCAA',
          @Lc_TypeDisburseAgtaa_CODE      CHAR(5) = 'AGTAA',
          @Lc_TypeDisburseRgpaa_CODE      CHAR(5) = 'RGPAA',
          @Lc_TypeDisburseUapaa_CODE      CHAR(5) = 'UAPAA',
          @Lc_TypeDisburseRgpai_CODE      CHAR(5) = 'RGPAI',
          @Lc_TypeDisburseUapai_CODE      CHAR(5) = 'UAPAI',
          @Lc_TypeDisburseXxxxx_CODE      CHAR(5) = 'XXXXX',
          @Lc_TypeDisburseRgxxx_CODE      CHAR(5) = 'RGXXX',
          @Lc_TypeDisburseUaxxx_CODE      CHAR(5) = 'UAXXX',
          @Lc_TypeDisburseAgive_CODE      CHAR(5) = 'AGIVE',
          @Lc_TypeDisburseFc4ea_CODE      CHAR(5) = 'FC4EA',
          @Lc_TypeDisburseFc4ei_CODE      CHAR(5) = 'FC4EI',
          @Lc_TypeDisburseGf4ep_CODE      CHAR(5) = 'GF4EP';

  SELECT @An_TotDistributeCurGrant_AMNT = SUM(CASE a.TypeDisburse_CODE
                               WHEN @Lc_TypeDisburseCgpaa_CODE
                                THEN a.Distribute_AMNT
                               WHEN @Lc_TypeDisburseRgmso_CODE
                                THEN a.Distribute_AMNT
                               WHEN @Lc_TypeDisburseUamso_CODE
                                THEN a.Distribute_AMNT
                               WHEN @Lc_TypeDisburse4amso_CODE
                                THEN a.Distribute_AMNT
                               WHEN @Lc_TypeDisburseFcmso_CODE
                                THEN a.Distribute_AMNT
                               WHEN @Lc_TypeDisburseCgive_CODE
                                THEN a.Distribute_AMNT
                               ELSE @Li_Zero_NUMB
                              END),
         @An_TotDisburseIvaAgency_AMNT = SUM(CASE a.TypeDisburse_CODE
                                  WHEN @Lc_TypeDisbursePgpaa_CODE
                                   THEN a.Distribute_AMNT
                                  ELSE @Li_Zero_NUMB
                                 END),
         @An_TotDistributeUrpaCur_AMNT = SUM(CASE a.TypeDisburse_CODE
                                    WHEN @Lc_TypeDisburseAgpaa_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseAgcaa_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseAgtaa_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseRgpaa_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseUapaa_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseRgpai_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseUapai_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseXxxxx_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseRgxxx_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseUaxxx_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseAgive_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseFc4ea_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseFc4ei_CODE
                                     THEN a.Distribute_AMNT
                                    WHEN @Lc_TypeDisburseGf4ep_CODE
                                     THEN a.Distribute_AMNT
                                    ELSE @Li_Zero_NUMB
                                   END)
    FROM LWEL_Y1 a
   WHERE A.Case_IDNO IN (SELECT DISTINCT z.Case_IDNO
                           FROM CMEM_Y1 z
                          WHERE z.MemberMci_IDNO = @An_MemberMci_IDNO
                            AND z.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                            AND (z.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                  OR (z.CaseMemberStatus_CODE = @Lc_CaseMemberStatusC_CODE
                                      AND NOT EXISTS (SELECT 1
                                                        FROM CMEM_Y1 l
                                                       WHERE z.Case_IDNO = l.Case_IDNO
                                                         AND z.MemberMci_IDNO != l.MemberMci_IDNO
                                                         AND l.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                                                         AND l.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))))
     AND EXISTS (SELECT 1
                   FROM RCTH_Y1 z
                  WHERE z.Batch_DATE = a.Batch_DATE
                    AND z.Batch_NUMB = a.Batch_NUMB
                    AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                    AND z.SourceBatch_CODE = a.SourceBatch_CODE
                    AND z.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE
                    AND z.EndValidity_DATE = @Ld_High_DATE)
     AND NOT EXISTS (SELECT 1
                       FROM RCTH_Y1 z
                      WHERE z.Batch_DATE = a.Batch_DATE
                        AND z.Batch_NUMB = a.Batch_NUMB
                        AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                        AND z.SourceBatch_CODE = a.SourceBatch_CODE
                        AND z.BackOut_INDC = @Lc_Yes_INDC
                        AND z.EndValidity_DATE = @Ld_High_DATE);
 END; --End of LWEL_RETRIEVE_S22


GO
