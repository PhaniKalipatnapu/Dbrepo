/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S1] (
 @Ad_BatchOrig_DATE       DATE,
 @An_BatchOrig_NUMB       NUMERIC(4, 0),
 @Ac_SourceBatchOrig_CODE CHAR(3),
 @An_SeqReceiptOrig_NUMB  NUMERIC(6, 0),
 @Ai_Count_QNTY           INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_RETRIEVE_S1
  *     DESCRIPTION       : Procedure To Check Whether DML Operation Can Able To Perform, Depends Upon The Receipt Distribute_DATE And Highdate, By Joing Of Two
                            Tables RCTH_Y1 And RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 18-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Ld_Low_DATE  DATE = '01/01/0001';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM RCTH_Y1 a
         JOIN (SELECT TOP 1 r.Batch_DATE,
                            r.Batch_NUMB,
                            r.SourceBatch_CODE
                 FROM RCTR_Y1 r
                WHERE r.BatchOrig_DATE = @Ad_BatchOrig_DATE
                  AND r.SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE
                  AND r.BatchOrig_NUMB = @An_BatchOrig_NUMB
                  AND r.SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB
                  AND r.EndValidity_DATE = @Ld_High_DATE
                  -- 13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - START -
                  ORDER BY r.Batch_NUMB DESC) b
                  -- 13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - END -
          ON a.Batch_DATE = b.Batch_DATE
             AND a.SourceBatch_CODE = b.SourceBatch_CODE
             AND a.Batch_NUMB = b.Batch_NUMB
   WHERE a.Distribute_DATE != @Ld_Low_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of Procedure RCTR_RETRIEVE_S1

GO
