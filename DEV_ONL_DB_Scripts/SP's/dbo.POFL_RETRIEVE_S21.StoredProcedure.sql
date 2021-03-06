/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S21] (
 @An_EventGlobalSeq_NUMB NUMERIC(19, 0),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ai_RowFrom_NUMB        INT =1,
 @Ai_RowTo_NUMB          INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : POFL_RETRIEVE_S21
  *     DESCRIPTION       : Retrieves the recoupment details for a recipient.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB                             SMALLINT	=	0,
          @Li_One_NUMB								SMALLINT	=	1,
		  @Li_Two_NUMB								SMALLINT	=	2,
		  @Li_Three_NUMB							SMALLINT	=	3,
		  @Li_Four_NUMB								SMALLINT	=	4,
          @Lc_PfolEstablishedRecoupmentReason_TEXT_CODE CHAR(2) = 'AV',
          @Lc_PfolPendingRecoupmentReason_CODE          CHAR(2) = 'PV',
          @Lc_PfolRemovedRecoupReason_CODE              CHAR(2) = 'SW',
          @Lc_PfolReplacedRecoupmentReason_CODE         CHAR(2) = 'WP',
          @Lc_RemovedRecoup_TEXT                        CHAR(25) = 'REMOVED RECOUPED RECEIPT',
          @Lc_ReplacedRecoup_TEXT                       CHAR(26) = 'REPLACED RECOUPED RECEIPT',
	      @Lc_EstbRecoup_TEXT                           CHAR(32) = 'ESTABLISHED RECOUPMENT ADJUSTED',
          @Lc_PendRecoup_TEXT                           CHAR(28) = 'PENDING RECOUPMENT ADJUSTED';

  SELECT Action_TEXT,
         X.Batch_DATE,
         X.SourceBatch_CODE,
         X.Batch_NUMB,
         X.SeqReceipt_NUMB,
         X.Case_IDNO,
         Transaction_CODE,
         Reason_CODE,
         txn_amount AS Transaction_AMNT,
         row_count AS RowCount_NUMB
    FROM (SELECT X.Action_TEXT,
                 X.Batch_DATE,
                 X.SourceBatch_CODE,
                 X.Batch_NUMB,
                 X.SeqReceipt_NUMB,
                 X.Case_IDNO,
                 X.Reason_CODE,
                 X.Transaction_CODE,
                 X.txn_amount,
                 X.row_count,
                 X.ORD_ROWNUM
            FROM (SELECT CASE a.rn
                          WHEN 1
                           THEN @Lc_PendRecoup_TEXT
                          WHEN 2
                           THEN @Lc_EstbRecoup_TEXT
                          WHEN 3
                           THEN @Lc_RemovedRecoup_TEXT
                          WHEN 4
                           THEN @Lc_ReplacedRecoup_TEXT
                         END AS Action_TEXT,
                         PF.Batch_DATE,
                         PF.SourceBatch_CODE,
                         PF.Batch_NUMB,
                         PF.SeqReceipt_NUMB,
                         PF.Case_IDNO,
                         PF.Transaction_CODE,
                         CASE a.rn
                          WHEN 1
                           THEN PF.Reason_CODE
                          WHEN 2
                           THEN PF.Reason_CODE
                          WHEN 3
                           THEN PF.Reason_CODE
                          WHEN 4
                           THEN PF.Reason_CODE
                         END AS Reason_CODE,
                         CASE a.rn
                          WHEN 1
                           THEN PF.PendOffset_AMNT
                          WHEN 2
                           THEN PF.AssessOverpay_AMNT
                          WHEN 3
                           THEN PF.RecOverpay_AMNT
                          WHEN 4
                           THEN PF.RecOverpay_AMNT
                         END AS txn_amount,
                         COUNT(1) OVER() AS row_count,
                         ROW_NUMBER() OVER( ORDER BY a.RN) AS ORD_ROWNUM
                    FROM POFL_Y1 PF,
                         (SELECT 1 AS rn
                          UNION ALL
                          SELECT 2 AS rn
                          UNION ALL
                          SELECT 3 AS rn
                          UNION ALL
                          SELECT 4 AS rn) AS a
                   WHERE PF.CheckRecipient_ID = @Ac_CheckRecipient_ID
                     AND PF.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
                     AND PF.EventGlobalSeq_NUMB = ISNULL(@An_EventGlobalSeq_NUMB  ,0)
                     AND ((a.rn = @Li_One_NUMB
                           AND PF.PendOffset_AMNT != @Li_Zero_NUMB
                           AND PF.Reason_CODE = @Lc_PfolPendingRecoupmentReason_CODE)
                           OR (a.rn = @Li_Two_NUMB
                               AND PF.AssessOverpay_AMNT != @Li_Zero_NUMB
                               AND PF.Reason_CODE = @Lc_PfolEstablishedRecoupmentReason_TEXT_CODE)
                           OR (a.rn = @Li_Three_NUMB
                               AND PF.RecOverpay_AMNT != @Li_Zero_NUMB
                               AND PF.Reason_CODE = @Lc_PfolRemovedRecoupReason_CODE)
                           OR (a.rn = @Li_Four_NUMB
                               AND PF.RecOverpay_AMNT != @Li_Zero_NUMB
                               AND PF.Reason_CODE = @Lc_PfolReplacedRecoupmentReason_CODE))) X
           WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB))) X
   WHERE (X.ORD_ROWNUM >= @Ai_RowFrom_NUMB OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB))
   ORDER BY ORD_ROWNUM;
 END


GO
