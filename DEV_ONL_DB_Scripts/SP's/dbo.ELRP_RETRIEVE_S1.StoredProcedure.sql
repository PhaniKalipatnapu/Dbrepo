/****** Object:  StoredProcedure [dbo].[ELRP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELRP_RETRIEVE_S1]
( 
      @An_EventGlobalRrepSeq_NUMB	 NUMERIC(19)            
)
AS
/*
 *     PROCEDURE NAME    : ELRP_RETRIEVE_S1
 *     DESCRIPTION       : This service is used to display the list of reversed receipts and their repost information.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN
     
   WITH ElogRrep_CTE
   AS
      (SELECT  EL.EventGlobalRrepSeq_NUMB, 
               EL.EventGlobalBackOutSeq_NUMB, 
               EL.EventGlobalRePostSeq_NUMB, 
               EL.EventGlobalRefundSeq_NUMB, 
               EL.BatchOrig_DATE, 
               EL.SourceBatchOrig_CODE, 
               EL.BatchOrig_NUMB, 
               EL.SeqReceiptOrig_NUMB, 
               EL.RePost_INDC, 
               EL.Refund_INDC, 
               EL.MultiCase_INDC, 
               EL.ClosedCase_INDC, 
               EL.MultiCounty_INDC
            FROM  ELRP_Y1 EL
           WHERE  EL.EventGlobalRrepSeq_NUMB = @An_EventGlobalRrepSeq_NUMB
       ) 
      SELECT 
         RP.BatchOrig_DATE, 
         RP.SourceBatchOrig_CODE, 
         RP.BatchOrig_NUMB, 
         RP.SeqReceiptOrig_NUMB, 
         ORR.Case_IDNO,
         ORR.PayorMCI_IDNO, 
         DE.Last_NAME,
         DE.Suffix_NAME,
         DE.First_NAME,
         DE.Middle_NAME,
         (ORR.Receipt_AMNT * -1) AS Receipt_AMNT, 
          d.Batch_DATE			 AS RepBatch_DATE ,
          d.SourceBatch_CODE     AS RepSourceBatch_CODE,
          d.Batch_NUMB           AS RepBatch_NUMB,
          d.SeqReceipt_NUMB      AS RepSeqReceipt_NUMB, 
           (SELECT  CASE WHEN e.Case_IDNO > 0 THEN e.Case_IDNO
                            ELSE  e.PayorMCI_IDNO
                        END     
               FROM RCTH_Y1   e
              WHERE e.Batch_DATE		= d.Batch_DATE 
                AND e.SourceBatch_CODE	= d.SourceBatch_CODE 
                AND e.Batch_NUMB		= d.Batch_NUMB 
                AND e.SeqReceipt_NUMB	= d.SeqReceipt_NUMB 
                AND e.EventGlobalBeginSeq_NUMB = RP.EventGlobalRePostSeq_NUMB
            ) AS RepCaseNcp_IDNO, 
         RP.MultiCase_INDC  , 
         RP.ClosedCase_INDC , 
         RP.EventGlobalBackOutSeq_NUMB, 
         RP.RePost_INDC,
         RP.Refund_INDC
      FROM  ElogRrep_CTE RP
         JOIN  RCTH_Y1 ORR
           ON  RP.EventGlobalBackOutSeq_NUMB = ORR.EventGlobalBeginSeq_NUMB 
          AND  RP.BatchOrig_DATE			 = ORR.Batch_DATE 
          AND  RP.SourceBatchOrig_CODE       = ORR.SourceBatch_CODE 
          AND  RP.BatchOrig_NUMB			 = ORR.Batch_NUMB 
          AND  RP.SeqReceiptOrig_NUMB	     = ORR.SeqReceipt_NUMB
               LEFT OUTER JOIN DEMO_Y1 DE 
           ON  DE.MemberMci_IDNO = ORR.PayorMCI_IDNO    
               LEFT OUTER JOIN RCTR_Y1  d 
           ON  RP.BatchOrig_DATE       = d.BatchOrig_DATE 
          AND  RP.SourceBatchOrig_CODE = d.SourceBatchOrig_CODE 
          AND  RP.BatchOrig_NUMB       = d.BatchOrig_NUMB 
          AND  RP.SeqReceiptOrig_NUMB  = d.SeqReceiptOrig_NUMB 
          AND  RP.EventGlobalRePostSeq_NUMB = d.EventGlobalBeginSeq_NUMB
      ORDER BY 
         RP.BatchOrig_DATE, 
         RP.SourceBatchOrig_CODE, 
         RP.BatchOrig_NUMB, 
         RP.SeqReceiptOrig_NUMB;
                  
END; --End Of Procedure ELRP_RETRIEVE_S1


GO
