/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S34] (
 @An_MemberMci_IDNO             NUMERIC(10),
 @Ad_ReceiptFrom_DATE           DATE,
 @Ad_ReceiptTo_DATE             DATE,
 @An_TotDisbursementHeld_AMNT NUMERIC(15, 2) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S34  
  *     DESCRIPTION       : Retrieves the total transaction amount for the given membermci id.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 14-SEP-2011  
  *     MODIFIED BY       :  
  *     MODIFIED ON       :  
  *     VERSION NO        : 1  
 */
 BEGIN

  DECLARE @Lc_CaseRelationshipA_CODE      CHAR(1)	= 'A',
          @Lc_CaseRelationshipD_CODE      CHAR(1)	= 'D',
          @Lc_Yes_INDC                    CHAR(1)	= 'Y',
          @Lc_CaseMemberStatusActive_CODE CHAR(1)	= 'A',
          @Lc_CaseMemberStatusI_CODE      CHAR(1)	= 'I',
          @Lc_CheckRecipient999999982_ID  CHAR(10)	= '999999982',
          @Lc_CheckRecipient999999993_ID  CHAR(10)	= '999999993',
          @Ld_High_DATE                   DATE		= '12/31/9999';
          

  SELECT @An_TotDisbursementHeld_AMNT = SUM(a.Transaction_AMNT)
    FROM DHLD_Y1 a
   WHERE A.Case_IDNO IN (SELECT DISTINCT z.Case_IDNO
                           FROM CMEM_Y1 z
                          WHERE z.MemberMci_IDNO = @An_MemberMci_IDNO
                            AND z.CaseRelationship_CODE = @Lc_CaseRelationshipA_CODE
                            AND (z.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                  OR (z.CaseMemberStatus_CODE = @Lc_CaseMemberStatusI_CODE
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
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End of DHLD_RETRIEVE_S34


GO
