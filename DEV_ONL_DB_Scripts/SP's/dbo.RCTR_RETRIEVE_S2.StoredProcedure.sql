/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S2] (
 @Ad_BatchOrig_DATE       DATE,
 @An_BatchOrig_NUMB       NUMERIC(4, 0),
 @Ac_SourceBatchOrig_CODE CHAR(3),
 @An_SeqReceiptOrig_NUMB  NUMERIC(6, 0),
 @An_ReceiptCurrent_AMNT  NUMERIC(11, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_RETRIEVE_S2
  *     DESCRIPTION       : Procedure To Retrieve The Receipt Current Ammount, By Using RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 18-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_ReceiptCurrent_AMNT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_AMNT SMALLINT = 0;

  SELECT @An_ReceiptCurrent_AMNT = ISNULL(SUM(r.ReceiptCurrent_AMNT), @Li_Zero_AMNT)
    FROM RCTR_Y1 r
   WHERE r.BatchOrig_DATE = @Ad_BatchOrig_DATE
     AND r.SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE
     AND r.BatchOrig_NUMB = @An_BatchOrig_NUMB
     AND r.SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB
     AND r.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of Procedure RCTR_RETRIEVE_S2

GO
