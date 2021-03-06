/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S42](  
     @An_Case_IDNO					NUMERIC(6),
     @An_EventGlobalSeq_NUMB		NUMERIC(19),
     @Ac_CheckRecipient_CODE		CHAR(1),
     @Ac_CheckRecipient_ID		    CHAR(10),
     @Ad_Batch_DATE					DATE,
     @Ac_SourceBatch_CODE			CHAR(3),
     @An_Batch_NUMB					NUMERIC(4),
     @An_SeqReceipt_NUMB			NUMERIC(6)
   )           
AS
/*
 *     PROCEDURE NAME    : POFL_RETRIEVE_S42
 *     DESCRIPTION       : This Procedure is used to populate data for 'Reverse And Repost' pop up.
						   This Pop up will show reversals and all associated events which occur as a result
						   of the reversal transaction, as a single event identified as 'Reverse and Repost'.
						   Balance will display the actual balance because of reversing all the receipts as
					       part of this bulk reversal.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

      DECLARE
         @Li_One_NUMB						INT     = 1,
         @Li_Two_NUMB						INT     = 2,
         @Li_Zero_NUMB                      SMALLINT=  0,
         @Lc_TransactionBkpe_CODE			CHAR(4) = 'BKPE', 
         @Lc_TransactionBankruptcy_CODE		CHAR(4) = 'BKRC', 
         @Lc_TransactionBkrr_CODE			CHAR(4) = 'BKRR', 
         @Lc_TransactionMrec_CODE			CHAR(4) = 'MREC', 
         @Lc_TransactionSrec_CODE			CHAR(4) = 'SREC';
         
        SELECT X.Transaction_DATE, 
         X.Transaction_CODE, 
         X.Case_IDNO , 
         X.Batch_DATE, 
         X.SourceBatch_CODE, 
         X.Batch_NUMB, 
         X.SeqReceipt_NUMB, 
         X.Reason_CODE , 
         X.Worker_ID, 
         SUM(X.Transaction_AMNT) AS Transaction_AMNT, 
        (SELECT UN.DescriptionNote_TEXT
      	   FROM UNOT_Y1 UN
      	  WHERE UN.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB) AS DescriptionNote_TEXT,  
         X.CheckRecipient_ID, 
         X.CheckRecipient_CODE , 
         X.TypeRecoupment_CODE 
      FROM (SELECT l.Transaction_DATE , 
                 CASE a.Row_NUMB
                     WHEN 1 THEN l.Transaction_CODE
                     WHEN 2 THEN @Lc_TransactionBkrr_CODE
                  END AS Transaction_CODE, 
               l.Case_IDNO , 
               l.Batch_DATE, 
               l.SourceBatch_CODE, 
               l.Batch_NUMB, 
               l.SeqReceipt_NUMB, 
               l.Reason_CODE ,
               g.Worker_ID, 
               CASE a.Row_NUMB
                  WHEN 1 THEN CASE 
                     WHEN l.Transaction_CODE = @Lc_TransactionBkpe_CODE THEN l.PendOffset_AMNT
                     WHEN l.Transaction_CODE = @Lc_TransactionBankruptcy_CODE THEN l.AssessOverpay_AMNT
                     WHEN l.Transaction_CODE IN ( @Lc_TransactionMrec_CODE, @Lc_TransactionSrec_CODE ) THEN l.RecOverpay_AMNT
                  END
                  WHEN 2 THEN l.RecOverpay_AMNT
               END AS Transaction_AMNT, 
               l.CheckRecipient_ID, 
               l.CheckRecipient_CODE, 
               a.Row_NUMB,  
               l.TypeRecoupment_CODE 
            FROM POFL_Y1 l 
               LEFT OUTER  JOIN ELRP_Y1 e
                   ON l.EventGlobalSeq_NUMB =e.EventGlobalBackOutSeq_NUMB 
               LEFT OUTER  JOIN GLEV_Y1 g    
                 ON E.EventGlobalRrepSeq_NUMB = g.EventGlobalSeq_NUMB  
               CROSS JOIN dbo.BATCH_COMMON$SF_GET_NUMBERS(1,2) a
           WHERE ((@Ac_CheckRecipient_ID IS NOT NULL  
                   AND l.CheckRecipient_ID = @Ac_CheckRecipient_ID 
                   AND l.CheckRecipient_CODE = @Ac_CheckRecipient_CODE) 
                   OR (@Ad_Batch_DATE IS NOT NULL 
                       AND l.Batch_DATE = @Ad_Batch_DATE 
                       AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE 
                       AND l.Batch_NUMB = @An_Batch_NUMB 
                       AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB))
            AND (l.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                 OR  E.EventGlobalRrepSeq_NUMB = @An_EventGlobalSeq_NUMB)
            AND l.Case_IDNO = @An_Case_IDNO
		     AND ((a.Row_NUMB = @Li_One_NUMB 
		           AND ((l.Transaction_CODE = @Lc_TransactionBkpe_CODE 
		                 AND l.PendOffset_AMNT > @Li_Zero_NUMB) 
                        OR(l.Transaction_CODE = @Lc_TransactionBankruptcy_CODE 
                       AND l.AssessOverpay_AMNT > @Li_Zero_NUMB)
                        OR(l.Transaction_CODE NOT IN ( @Lc_TransactionBkpe_CODE, @Lc_TransactionBankruptcy_CODE )))) 
                        OR(a.Row_NUMB = @Li_Two_NUMB 
                       AND l.RecOverpay_AMNT < @Li_Zero_NUMB))) X
      GROUP BY 
         X.Transaction_DATE, 
         X.Transaction_CODE, 
         X.Reason_CODE, 
         X.Worker_ID, 
         X.Case_IDNO, 
         X.Batch_DATE, X.SourceBatch_CODE, X.Batch_NUMB, X.SeqReceipt_NUMB, 
         X.CheckRecipient_ID, 
         X.CheckRecipient_CODE, 
         X.Row_NUMB, 
         X.TypeRecoupment_CODE
      ORDER BY X.Case_IDNO, X.CheckRecipient_CODE, X.CheckRecipient_ID;

END; --End Of Procedure POFL_RETRIEVE_S42 


GO
