/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S26] (
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ad_ReceiptFrom_DATE         DATE,
 @Ad_ReceiptTo_DATE           DATE,
 @An_TotDisbursementCp_AMNT   NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S26
  *     DESCRIPTION       : Retrieves the total disburse amount for the given memberm id, receipt date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Lc_CaseRelationshipA_CODE		CHAR(1) = 'A',
          @Lc_CaseRelationshipC_CODE		CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A',
          @Lc_CaseMemberStatusC_CODE		CHAR(1) = 'C',
          @Lc_CheckRecipientFips_CODE		CHAR(1) = '2',
          @Lc_Yes_INDC						CHAR(1) = 'Y',
          @Ld_High_DATE						DATE	= '12/31/9999';
          

  SELECT @An_TotDisbursementCp_AMNT = SUM(A.Disburse_AMNT)
    FROM DSBL_Y1 A
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
                   FROM RCTH_Y1 Z
                  WHERE Z.Batch_DATE = A.Batch_DATE
                    AND Z.Batch_NUMB = A.Batch_NUMB
                    AND Z.SeqReceipt_NUMB = A.SeqReceipt_NUMB
                    AND Z.SourceBatch_CODE = A.SourceBatch_CODE
                    AND Z.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE
                    AND Z.EndValidity_DATE = @Ld_High_DATE)
     AND NOT EXISTS (SELECT 1
                       FROM RCTH_Y1 Z
                      WHERE Z.Batch_DATE = A.Batch_DATE
                        AND Z.Batch_NUMB = A.Batch_NUMB
                        AND Z.SeqReceipt_NUMB = A.SeqReceipt_NUMB
                        AND Z.SourceBatch_CODE = A.SourceBatch_CODE
                        AND Z.BackOut_INDC = @Lc_Yes_INDC
                        AND Z.EndValidity_DATE = @Ld_High_DATE)
                        
     AND ( A.CheckRecipient_CODE = @Lc_CheckRecipientFips_CODE
			OR
			 EXISTS (SELECT 1 
                   FROM CMEM_Y1 z
                  WHERE z.Case_IDNO = A.Case_IDNO
                    AND z.MemberMci_IDNO = A.CheckRecipient_ID
                    AND z.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                    AND z.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE));
 END; --End of DSBL_RETRIEVE_S26


GO
