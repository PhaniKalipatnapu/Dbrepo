/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S16] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @Ad_ReceiptFrom_DATE         DATE,
 @Ad_ReceiptTo_DATE           DATE,
 @An_TotRecOverPayNcp_AMNT    NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : POFL_RETRIEVE_S16
  *     DESCRIPTION       : Retrieves sum of over pay amount for the given check recipient id.
  *     DEVELOPED BY      :IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TotRecOverPayNcp_AMNT = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_TypeDisburseRefnd_CODE CHAR(5) = 'REFND',
          @Li_Zero_NUMB              SMALLINT = 0,
          @Lc_Yes_INDC               CHAR(1) = 'Y';

  SELECT @An_TotRecOverPayNcp_AMNT = ISNULL(SUM(a.RecOverpay_AMNT), @Li_Zero_NUMB)
    FROM POFL_Y1 a
   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefnd_CODE
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
 END; --End of  POFL_RETRIEVE_S16

GO
