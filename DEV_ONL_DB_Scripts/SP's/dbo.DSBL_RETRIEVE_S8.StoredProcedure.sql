/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S8] (
 @An_Case_IDNO               NUMERIC(6),
 @An_OrderSeq_NUMB           NUMERIC(2),
 @An_ObligationSeq_NUMB      NUMERIC(2),
 @Ac_TypeDebt_CODE           CHAR(2),
 @Ad_ReceiptFrom_DATE        DATE,
 @Ad_ReceiptTo_DATE          DATE,
 @An_TotDisbursementCp_AMNT  NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S8
  *     DESCRIPTION       : Retrieves the total disburse amount for the given case id, receipt date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Li_Zero_NUMB						INT			= 0,
		  @Lc_CaseMemberStatusActive_CODE	CHAR(1)		= 'A',
          @Lc_CaseRelationshipC_CODE		CHAR(1)		= 'C',
          @Lc_CheckRecipientFips_CODE		CHAR(1)		= '2',
          @Lc_Yes_INDC						CHAR(1)		= 'Y',
          @Lc_StatusCheckVn_CODE			CHAR(2)		= 'VN',
          @Lc_StatusCheckSn_CODE			CHAR(2)		= 'SN',
          @Ld_High_DATE						DATE		= '12/31/9999';
          

  SELECT @An_TotDisbursementCp_AMNT = SUM(A.Disburse_AMNT)
    FROM DSBL_Y1 A
   WHERE A.Case_IDNO = @An_Case_IDNO
     AND A.OrderSeq_NUMB IN (@An_OrderSeq_NUMB, @Li_Zero_NUMB)
     AND A.ObligationSeq_NUMB = ISNULL(@An_ObligationSeq_NUMB, A.ObligationSeq_NUMB)
     AND EXISTS (SELECT 1
                    FROM OBLE_Y1 o
                   WHERE o.Case_IDNO = @An_Case_IDNO
                     AND o.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE, o.TypeDebt_CODE)
                     AND o.ObligationSeq_NUMB = ISNULL(@An_ObligationSeq_NUMB, o.ObligationSeq_NUMB)
                     AND o.EndValidity_DATE = @Ld_High_DATE)
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
	AND EXISTS (SELECT 1
				   FROM DSBH_Y1 H
				  WHERE H.Disburse_DATE = A.Disburse_DATE 
				    AND H.DisburseSeq_NUMB = A.DisburseSeq_NUMB 
				    AND H.checkrecipient_id = A.checkrecipient_id 
				    AND H.EndValidity_date = @Ld_High_DATE
				    AND H.StatusCheck_CODE NOT IN (@Lc_StatusCheckVn_CODE,@Lc_StatusCheckSn_CODE)
				     ) 
     AND ( A.CheckRecipient_CODE = @Lc_CheckRecipientFips_CODE
			OR
			EXISTS (SELECT 1 
                   FROM CMEM_Y1 z
                  WHERE z.Case_IDNO = @An_Case_IDNO
                    AND z.MemberMci_IDNO = A.CheckRecipient_ID
                    AND z.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                    AND z.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE));
 END; --End of DSBL_RETRIEVE_S8


GO
