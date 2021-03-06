/****** Object:  StoredProcedure [dbo].[RCTR_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_INSERT_S1] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4, 0),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @Ad_BatchOrig_DATE           DATE,
 @Ac_SourceBatchOrig_CODE     CHAR(3),
 @An_BatchOrig_NUMB           NUMERIC(4, 0),
 @An_SeqReceiptOrig_NUMB      NUMERIC(6, 0),
 @Ac_StatusMatch_CODE         CHAR(1),
 @Ad_RePost_DATE              DATE,
 @Ac_ReasonRePost_CODE        CHAR(2),
 @An_ReceiptCurrent_AMNT      NUMERIC(11, 2),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_INSERT_S1
  *     DESCRIPTION       : Procedure To Insert The Receipt Repost Details Into RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 17-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Ld_Current_DATE           DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Li_EventGlobalEndSeq_NUMB SMALLINT = 0;

  INSERT RCTR_Y1
         (Batch_DATE,
          SourceBatch_CODE,
          Batch_NUMB,
          SeqReceipt_NUMB,
          BatchOrig_DATE,
          SourceBatchOrig_CODE,
          BatchOrig_NUMB,
          SeqReceiptOrig_NUMB,
          StatusMatch_CODE,
          RePost_DATE,
          ReasonRePost_CODE,
          ReceiptCurrent_AMNT,
          BeginValidity_DATE,
          EndValidity_DATE,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB)
  VALUES ( @Ad_Batch_DATE,-- Batch_DATE		
           @Ac_SourceBatch_CODE,-- SourceBatch_CODE
           @An_Batch_NUMB,-- Batch_NUMB
           @An_SeqReceipt_NUMB,-- SeqReceipt_NUMB
           @Ad_BatchOrig_DATE,-- BatchOrig_DATE
           @Ac_SourceBatchOrig_CODE,-- SourceBatchOrig_CODE
           @An_BatchOrig_NUMB,-- BatchOrig_NUMB
           @An_SeqReceiptOrig_NUMB,-- SeqReceiptOrig_NUMB		
           @Ac_StatusMatch_CODE,-- StatusMatch_CODE
           @Ad_RePost_DATE,-- RePost_DATE
           @Ac_ReasonRePost_CODE,-- ReasonRePost_CODE	
           @An_ReceiptCurrent_AMNT,-- ReceiptCurrent_AMNT
           @Ld_Current_DATE,-- BeginValidity_DATE
           @Ld_High_DATE,-- EndValidity_DATE		
           @An_EventGlobalBeginSeq_NUMB,-- EventGlobalBeginSeq_NUMB
           @Li_EventGlobalEndSeq_NUMB -- EventGlobalEndSeq_NUMB
  );
 END; --End Of Procedure RCTR_INSERT_S1 

GO
