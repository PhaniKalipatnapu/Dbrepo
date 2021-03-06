/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S71]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S71] (
 @Ad_Batch_DATE       DATE,
 @An_Batch_NUMB       NUMERIC(4, 0),
 @Ac_SourceBatch_CODE CHAR(3),
 @An_SeqReceipt_NUMB  NUMERIC(6, 0),
 @An_Receipt_AMNT     NUMERIC(11, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S71
  *     DESCRIPTION       : Procedure To Retrieve The Receipt Ammount, Based On BatchDate,SeqReceiptNUMB And 
                            EndValidityDate By Using RCTH_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 17-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_Receipt_AMNT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_AMNT SMALLINT = 0;

  SELECT TOP 1 @An_Receipt_AMNT = r.Receipt_AMNT
    FROM RCTH_Y1 r
   WHERE r.Batch_DATE = @Ad_Batch_DATE
     AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND r.Batch_NUMB = @An_Batch_NUMB
     AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND r.Receipt_AMNT > @Li_Zero_AMNT
     AND r.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of Procedure RCTH_RETRIEVE_S71 

GO
