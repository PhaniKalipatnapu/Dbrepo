/****** Object:  StoredProcedure [dbo].[RBAT_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_RETRIEVE_S8] (
 @Ad_BatchOrig_DATE           DATE,
 @An_BatchOrig_NUMB           NUMERIC(4, 0),
 @Ac_SourceBatchOrig_CODE     CHAR(3),
 @An_SeqReceiptOrig_NUMB      NUMERIC(6, 0),
 @Ad_Batch_DATE               DATE OUTPUT,
 @An_Batch_NUMB               NUMERIC(4, 0) OUTPUT,
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_StatusMatch_CODE         CHAR(1) OUTPUT,
 @Ac_StatusBatch_CODE         CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RBAT_RETRIEVE_S8
  *     DESCRIPTION       : Procedure To Retrieve The Bacth Date, Batch number And EventGlobalBeginSeq number Based
                  		   On Batchdate,SourceBatchCode and Batch_NUMB By Joining Two Tables RCTR_Y1 And RBAT_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 15-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_Batch_DATE = NULL,
         @An_Batch_NUMB = NULL,
         @An_EventGlobalBeginSeq_NUMB = NULL,
         @Ac_StatusMatch_CODE = NULL,
         @Ad_Batch_DATE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_StatusMatch_CODE = a.StatusMatch_CODE,
               @Ac_StatusBatch_CODE = b.StatusBatch_CODE,
               @Ad_Batch_DATE = b.Batch_DATE,
               @An_Batch_NUMB = b.Batch_NUMB,
               @An_EventGlobalBeginSeq_NUMB = b.EventGlobalBeginSeq_NUMB
    FROM RCTR_Y1 a
         JOIN RBAT_Y1 b
          ON b.Batch_DATE = a.Batch_DATE
             AND b.SourceBatch_CODE = a.SourceBatch_CODE
             AND b.Batch_NUMB = a.Batch_NUMB
   WHERE a.BatchOrig_DATE = @Ad_BatchOrig_DATE
     AND a.SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE
     AND a.BatchOrig_NUMB = @An_BatchOrig_NUMB
     AND a.SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE
     -- 13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - START -
     ORDER BY b.Batch_NUMB DESC
     -- 13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - END -
 END; -- End Of RBAT_RETRIEVE_S8

GO
