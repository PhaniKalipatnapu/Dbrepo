/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S49]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S49] (
 @An_MemberMci_IDNO          NUMERIC(10, 0),
 @Ad_ReceiptFrom_DATE        DATE,
 @Ad_ReceiptTo_DATE          DATE,
 @An_TotRecOverPayCp_AMNT    NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : POFL_RETRIEVE_S49
  *     DESCRIPTION       : Retrieves sum of over pay amount for the given member mci id.
  *     DEVELOPED BY      :IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TotRecOverPayCp_AMNT = NULL;

  DECLARE @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_CaseRelationshipA_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipD_CODE      CHAR(1) = 'D',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_CaseMemberStatusC_CODE      CHAR(1) = 'C',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_CheckRecipient999999982_ID  CHAR(10) = '999999982',
          @Lc_CheckRecipient999999993_ID  CHAR(10) = '999999993';

  SELECT @An_TotRecOverPayCp_AMNT = SUM(a.RecOverpay_AMNT)
    FROM POFL_Y1 a
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
                        AND z.EndValidity_DATE = @Ld_High_DATE)
     AND a.CheckRecipient_ID NOT IN (@Lc_CheckRecipient999999982_ID, @Lc_CheckRecipient999999993_ID)
     AND EXISTS (SELECT 1
                   FROM CMEM_Y1 y
                  WHERE y.Case_IDNO = a.Case_IDNO
                    AND y.MemberMci_IDNO = a.CheckRecipient_ID
                    AND y.CaseRelationship_CODE NOT IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipD_CODE));
 END; --End of POFL_RETRIEVE_S49


GO
