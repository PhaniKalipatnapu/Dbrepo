/****** Object:  StoredProcedure [dbo].[RCTR_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_UPDATE_S3] (
 @Ad_BatchOrig_DATE              DATE,
 @Ac_SourceBatchOrig_CODE        CHAR(3),
 @An_BatchOrig_NUMB              NUMERIC(4, 0),
 @An_SeqReceiptOrig_NUMB         NUMERIC(6, 0),
 @Ac_StatusMatch_CODE            CHAR(1),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_UPDATE_S3
  *     DESCRIPTION       : Procedure To Update The Receipt Repost Details based on Original receipt Details
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 19-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE    DATE ='12/31/9999',
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  --13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - START -
  UPDATE RCTR_Y1
     SET StatusMatch_CODE = @Ac_StatusMatch_CODE,
         BeginValidity_DATE = @Ld_Current_DATE,
         EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
  OUTPUT DELETED.Batch_DATE,
         DELETED.SourceBatch_CODE,
         DELETED.Batch_NUMB,
         DELETED.SeqReceipt_NUMB,
         DELETED.BatchOrig_DATE,
         DELETED.SourceBatchOrig_CODE,
         DELETED.BatchOrig_NUMB,
         DELETED.SeqReceiptOrig_NUMB,
         DELETED.StatusMatch_CODE,
         DELETED.RePost_DATE,
         DELETED.ReasonRePost_CODE,
         DELETED.ReceiptCurrent_AMNT,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         DELETED.EventGlobalBeginSeq_NUMB,
         @An_EventGlobalBeginSeq_NUMB AS EventGlobalEndSeq_NUMB
  INTO RCTR_Y1
   WHERE BatchOrig_DATE = @Ad_BatchOrig_DATE
     AND SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE
     AND BatchOrig_NUMB = @An_BatchOrig_NUMB
     AND SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB
     AND EndValidity_DATE = @Ld_High_DATE
     AND StatusMatch_CODE NOT IN ('V','A');
  --13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - END -

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB;
 END; --End Of Procedure RCTR_UPDATE_S3	

GO
