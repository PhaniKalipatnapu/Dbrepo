/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S12] (
 @Ad_Batch_DATE           DATE,
 @An_Batch_NUMB           NUMERIC(4, 0),
 @Ac_SourceBatch_CODE     CHAR(3),
 @Ad_BatchOrig_DATE       DATE OUTPUT,
 @Ac_SourceBatchOrig_CODE CHAR(3) OUTPUT,
 @An_BatchOrig_NUMB       NUMERIC(4, 0) OUTPUT,
 @An_SeqReceiptOrig_NUMB  NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_RETRIEVE_S12
  *     DESCRIPTION       : Procedure To Generate The Orginal Receipt Number, By Using RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 19-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_BatchOrig_DATE = NULL,
         @Ac_SourceBatchOrig_CODE = NULL,
         @An_BatchOrig_NUMB = NULL,
         @An_SeqReceiptOrig_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ad_BatchOrig_DATE = r.BatchOrig_DATE,
               @Ac_SourceBatchOrig_CODE = r.SourceBatchOrig_CODE,
               @An_BatchOrig_NUMB = r.BatchOrig_NUMB,
               @An_SeqReceiptOrig_NUMB = r.SeqReceiptOrig_NUMB
    FROM RCTR_Y1 r
   WHERE r.Batch_DATE = @Ad_Batch_DATE
     AND r.Batch_NUMB = @An_Batch_NUMB
     AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND r.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of Procedure RCTR_RETRIEVE_S12

GO
