/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S67]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S67] 
(
     @Ad_BatchOrig_DATE					DATE,
     @An_BatchOrig_NUMB					NUMERIC(4,0),
     @Ac_SourceBatchOrig_CODE			CHAR(3),
     @An_SeqReceiptOrig_NUMB			NUMERIC(6,0),
     @Ai_RowFrom_NUMB					INT = 1,
     @Ai_RowTo_NUMB						INT = 10                
)
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S67
 *     DESCRIPTION       : Procedure To Retrieve The Receipt Repost informations
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
     
		DECLARE

			@Ld_High_DATE	DATE = '12/31/9999', 
			@Li_Zero_AMNT	SMALLINT = 0;

		SELECT Z.Batch_DATE , 
			Z.SourceBatch_CODE , 
			Z.Batch_NUMB , 
			Z.SeqReceipt_NUMB , 
			Z.SourceReceipt_CODE , 
			Z.SourceReceiptOld_CODE , 
			Z.CasePayorMCIReposted_CODE , 
			Z.Case_IDNO,
			Z.PayorMCI_IDNO , 
			Z.Receipt_AMNT , 
			Z.Fips_CODE , 
			Z.Fee_AMNT , 
			Z.Receipt_DATE , 
			Z.StatusReceipt_CODE , 
			Z.ReasonStatus_CODE , 
			Z.Tanf_CODE , 
			Z.TaxJoint_CODE , 
			Z.TaxJoint_NAME , 
			Z.ReasonRePost_CODE , 
			Z.EventGlobalUrct_SEQ , 
			Z.EventGlobalRcth_SEQ , 
			Z.EventGlobalRctr_SEQ , 
			Z.Worker_ID , 
			Z.DistributeRep_DATE , 
			Z.RowCount_NUMB 
		FROM (SELECT Y.Batch_DATE, 
               Y.SourceBatch_CODE, 
               Y.Batch_NUMB, 
               Y.SeqReceipt_NUMB, 
               Y.SourceReceipt_CODE, 
               Y.SourceReceiptOld_CODE, 
               Y.CasePayorMCIReposted_CODE,
               Y.Case_IDNO, 
               Y.PayorMCI_IDNO, 
               Y.Receipt_AMNT, 
               Y.Fips_CODE, 
               Y.Fee_AMNT, 
               Y.Receipt_DATE, 
               Y.StatusReceipt_CODE, 
               Y.ReasonStatus_CODE, 
               Y.Tanf_CODE, 
               Y.TaxJoint_CODE, 
               Y.TaxJoint_NAME, 
               Y.ReasonRePost_CODE, 
               Y.EventGlobalUrct_SEQ, 
               Y.EventGlobalRcth_SEQ, 
               Y.EventGlobalRctr_SEQ, 
               Y.Worker_ID, 
               Y.DistributeRep_DATE, 
               Y.RowCount_NUMB, 
               Y.ORD_ROWNUM 
            FROM (SELECT a.Batch_DATE , 
                    a.SourceBatch_CODE , 
                    a.Batch_NUMB , 
                    a.SeqReceipt_NUMB , 
                    a.SourceReceipt_CODE , 
                    a.SourceReceipt_CODE AS SourceReceiptOld_CODE, 
                    a.TypePosting_CODE   AS CasePayorMCIReposted_CODE,
                    a.Case_IDNO,
                    a.PayorMCI_IDNO,
                    a.Receipt_AMNT , 
                    a.Fips_CODE , 
                    a.Fee_AMNT , 
                    a.Receipt_DATE , 
                    a.StatusReceipt_CODE , 
                    a.ReasonStatus_CODE , 
                    a.Tanf_CODE , 
                    a.TaxJoint_CODE , 
                    a.TaxJoint_NAME , 
                    x.ReasonRePost_CODE , 
                    c.EventGlobalBeginSeq_NUMB AS EventGlobalUrct_SEQ, 
                    a.EventGlobalBeginSeq_NUMB AS EventGlobalRcth_SEQ, 
                    x.EventGlobalBeginSeq_NUMB AS EventGlobalRctr_SEQ, 
                    d.Worker_ID , 
                    dbo.BATCH_COMMON$SF_DT_DISTRIBUTE(a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS DistributeRep_DATE, 
                    COUNT(1) OVER() AS RowCount_NUMB, 
                    -- 13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - START -
                    ROW_NUMBER() OVER(
                       ORDER BY a.Batch_NUMB DESC, a.SeqReceipt_NUMB DESC) AS ORD_ROWNUM
                    -- 13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - END -   
				FROM (SELECT b.Batch_DATE, 
                        b.SourceBatch_CODE, 
                        b.Batch_NUMB, 
                        b.SeqReceipt_NUMB, 
                        b.StatusMatch_CODE, 
                        b.ReasonRePost_CODE, 
                        b.EventGlobalBeginSeq_NUMB
					FROM  RCTR_Y1  b
					WHERE b.BatchOrig_DATE = @Ad_BatchOrig_DATE 
					AND   b.SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE 
					AND   b.BatchOrig_NUMB = @An_BatchOrig_NUMB 
					AND   b.SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB 
					AND   b.EndValidity_DATE = @Ld_High_DATE
                     )  x 
					LEFT OUTER JOIN 
                    URCT_Y1   c 
					  ON c.Batch_DATE = x.Batch_DATE 
						AND c.SourceBatch_CODE = x.SourceBatch_CODE 
						AND c.Batch_NUMB = x.Batch_NUMB 
						AND c.SeqReceipt_NUMB = x.SeqReceipt_NUMB 
						AND c.EndValidity_DATE = @Ld_High_DATE 
					JOIN
						RCTH_Y1  a  
					  ON  a.Batch_DATE = x.Batch_DATE 
						AND a.SourceBatch_CODE = x.SourceBatch_CODE 
						AND a.Batch_NUMB = x.Batch_NUMB 
						AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB
					JOIN 
						GLEV_Y1  d
					  ON  d.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB 
					 AND a.EventGlobalBeginSeq_NUMB =(SELECT MAX(e.EventGlobalBeginSeq_NUMB)
										 FROM RCTH_Y1  e
										WHERE e.Batch_DATE = x.Batch_DATE 
										AND e.SourceBatch_CODE = x.SourceBatch_CODE 
										AND e.Batch_NUMB = x.Batch_NUMB 
										AND e.SeqReceipt_NUMB = x.SeqReceipt_NUMB 
										AND e.Receipt_AMNT > @Li_Zero_AMNT 
										AND e.EndValidity_DATE = @Ld_High_DATE
							)
               )  Y
				WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )  Z
		WHERE Z.ORD_ROWNUM >= @Ai_RowFrom_NUMB
		ORDER BY ORD_ROWNUM;
                  
END; --End Of Procedure RCTH_RETRIEVE_S67 


GO
