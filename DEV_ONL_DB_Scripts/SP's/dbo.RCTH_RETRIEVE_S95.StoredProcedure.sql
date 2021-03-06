/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S95]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S95] (
 @An_PayorMCI_IDNO        NUMERIC(10, 0),
 @Ad_ReceiptFrom_DATE     DATE,
 @Ad_ReceiptTo_DATE       DATE,
 @An_TotDisburseNcp_AMNT  NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S95
  *     DESCRIPTION       : Retrieves sum of distribute amount for the given  payor id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TotDisburseNcp_AMNT = NULL;

  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Lc_StatusReceiptR_CODE CHAR(2) = 'R',
          @Lc_Yes_INDC            CHAR(1) = 'Y',
          @Li_Zero_NUMB           SMALLINT = 0;

  SELECT @An_TotDisburseNcp_AMNT = ISNULL(SUM(a.ToDistribute_AMNT), @Li_Zero_NUMB)
    FROM RCTH_Y1 a
   WHERE a.PayorMCI_IDNO = @An_PayorMCI_IDNO
     AND a.StatusReceipt_CODE = @Lc_StatusReceiptR_CODE
     AND a.Receipt_DATE BETWEEN @Ad_ReceiptFrom_DATE AND @Ad_ReceiptTo_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND NOT EXISTS (SELECT 1
                       FROM RCTH_Y1 z
                      WHERE z.Batch_DATE = a.Batch_DATE
                        AND z.Batch_NUMB = a.Batch_NUMB
                        AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                        AND z.SourceBatch_CODE = a.SourceBatch_CODE
                        AND z.BackOut_INDC = @Lc_Yes_INDC
                        AND z.EndValidity_DATE = @Ld_High_DATE);
 END; --End of RCTH_RETRIEVE_S95

GO
