/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S11] (
 @Ac_CheckRecipient_ID       CHAR(10),
 @Ad_ReceiptFrom_DATE        DATE,
 @Ad_ReceiptTo_DATE          DATE,
 @An_TotDisburseNcp_AMNT     NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S11
  *     DESCRIPTION       : Retrieves the total disburse amount for the given case id, receipt date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TotDisburseNcp_AMNT = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Li_Zero_NUMB              SMALLINT = 0,
          @Lc_TypeDisburseRefnd_CODE CHAR(5) = 'REFND',
          @Lc_Yes_INDC               CHAR(1) = 'Y';

  SELECT @An_TotDisburseNcp_AMNT = ISNULL (SUM (a.Disburse_AMNT), @Li_Zero_NUMB)
    FROM DSBL_Y1 a
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
 END; -- End of DSBL_RETRIEVE_S11


GO
