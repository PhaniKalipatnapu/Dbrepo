/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S9] (
 @An_Case_IDNO                      NUMERIC(6),
 @An_OrderSeq_NUMB                  NUMERIC(2),
 @An_ObligationSeq_NUMB             NUMERIC(2),
 @Ac_TypeDebt_CODE                  CHAR(2),
 @Ad_ReceiptFrom_DATE               DATE,
 @Ad_ReceiptTo_DATE                 DATE,
 @An_TotDisbursementXIXAgency_AMNT  NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S9
  *     DESCRIPTION       : Retrieves the total disburse amount for the given case id, receipt date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  
  DECLARE @Li_Zero_NUMB					 INT		= 0,	
		  @Lc_Yes_INDC                   CHAR(1)	= 'Y',
          @Lc_CheckRecipient999999982_ID CHAR(10)	= '999999982',
          @Ld_High_DATE                  DATE		= '12/31/9999';
          
  SELECT @An_TotDisbursementXIXAgency_AMNT = SUM (a.Disburse_AMNT)
    FROM DSBL_Y1 a
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
                        AND z.backout_indc = @Lc_Yes_INDC
                        AND z.EndValidity_DATE = @Ld_High_DATE)
     AND a.CheckRecipient_ID = @Lc_CheckRecipient999999982_ID;
 END; --End of DSBL_RETRIEVE_S9


GO
