/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S26]        
(      
     @Ad_Batch_DATE				DATE,      
     @An_Batch_NUMB            	NUMERIC(4,0),      
     @An_SeqReceipt_NUMB		NUMERIC(6,0),
     @Ac_SourceBatch_CODE		CHAR(3),
     @Ac_SourceReceipt_CODE		CHAR(2),
     @Ac_TypeRemittance_CODE	CHAR(3), 
     @An_Case_IDNO		 		NUMERIC(6,0),      
     @An_PayorMCI_IDNO		 	NUMERIC(10,0),     
     @Ac_ReasonStatus_CODE     	CHAR(4)  ,
     @Ac_SourceBatchIn_CODE	CHAR(3),
     @Ai_RowFrom_NUMB          	INT,      
     @Ai_RowTo_NUMB            	INT         
 )                                                
AS      
      
/*      
*     PROCEDURE NAME     : RCTH_RETRIEVE_S26      
*     DESCRIPTION       : This procedure is used to get the display the pre-distribution receipts
               				that have been release from hold, fully or partially, but not yet processed
          					by the distribution batch program. 
*     DEVELOPED BY      : IMP TEAM      
*     DEVELOPED ON      : 02-OCT-2011      
*     MODIFIED BY       :       
*     MODIFIED ON       :       
*     VERSION NO        : 1      
*/      
BEGIN      
DECLARE
	@Ld_High_DATE 			DATE='12/31/9999',
	@Ld_Low_DATE  			DATE='01/01/0001',
	@Lc_StatusReceiptI_CODE CHAR(1)='I',
	@Lc_Yes_INDC 			CHAR(1)='Y',
	@Ld_Current_DATE		DATE	 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	 
       SELECT Y.Batch_DATE,
         Y.Batch_NUMB,
         Y.SeqReceipt_NUMB,    
         Y.SourceReceipt_CODE ,       
         Y.Receipt_AMNT ,       
         Y.Receipt_DATE ,       
         Y.ToDistribute_AMNT ,
         Y.TypePosting_CODE ,       
         Y.Case_IDNO ,       
         Y.BeginValidity_DATE , 
         Y.Release_DATE ,       
         Y.Worker_ID ,       
         Y.EventGlobalBeginSeq_NUMB ,
         Y.DescriptionNote_TEXT ,       
         Y.NumDaysHold_QNTY ,       
         Y.PayorMCI_IDNO ,       
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,              	
         Y.RowCount_NUMB ,       
         Y.Total_AMNT ,       
         Y.TypeRemittance_CODE,       
         Y.SourceBatch_CODE , 
         R.Rapid_IDNO ,
         R.RapidEnvelope_NUMB   ,
         R.RapidReceipt_NUMB    
      FROM (      
            SELECT X.Batch_DATE,
               X.Batch_NUMB,
               X.SeqReceipt_NUMB,       
               X.SourceReceipt_CODE,       
               X.Receipt_AMNT,       
               X.Receipt_DATE,       
               X.ToDistribute_AMNT,
               X.TypePosting_CODE,       
               X.Case_IDNO,       
               X.BeginValidity_DATE,       
               X.Release_DATE,       
               X.Worker_ID ,       
               X.EventGlobalBeginSeq_NUMB,
               X.DescriptionNote_TEXT,       
               X.NumDaysHold_QNTY,       
               X.PayorMCI_IDNO,       
               X.Last_NAME,
               X.Suffix_NAME,
               X.First_NAME,
               X.Middle_NAME,      
               X.RowCount_NUMB,       
               X.Total_AMNT,       
               X.TypeRemittance_CODE,       
               X.SourceBatch_CODE,  
               X.ORD_ROWNUM AS rnum
            FROM(      
                   SELECT R.Batch_DATE,
                     R.Batch_NUMB,
                     R.SeqReceipt_NUMB,
                     R.SourceReceipt_CODE,       
                     R.Receipt_AMNT,       
                     R.Receipt_DATE,     
                     R.ToDistribute_AMNT ,
                     R.TypePosting_CODE,       
                     R.Case_IDNO,       
                     R.BeginValidity_DATE ,     
                     R.Release_DATE,       
                     G.Worker_ID ,       
                     R.EventGlobalBeginSeq_NUMB,      
                     N.DescriptionNote_TEXT,       
                     U.NumDaysHold_QNTY,       
                     R.PayorMCI_IDNO,       
                     d.Last_NAME,
                     d.Suffix_NAME,
                     d.First_NAME,
                     d.Middle_NAME,       
                     COUNT(1) OVER()  RowCount_NUMB,       
                     SUM(R.ToDistribute_AMNT) OVER() AS Total_AMNT,       
                     R.TypeRemittance_CODE,       
                     R.SourceBatch_CODE,
                     ROW_NUMBER() OVER(      
                        ORDER BY R.Receipt_DATE DESC)  ORD_ROWNUM 
                  FROM RCTH_Y1   R       
                        LEFT OUTER JOIN UNOT_Y1   N       
                        ON N.EventGlobalSeq_NUMB = R.EventGlobalBeginSeq_NUMB       
                        LEFT OUTER JOIN UCAT_Y1   U       
                        ON R.ReasonStatus_CODE = U.Udc_CODE 
                           AND U.EndValidity_DATE = @Ld_High_DATE
                        JOIN      
                     	GLEV_Y1   G
                     	ON R.EventGlobalBeginSeq_NUMB = G.EventGlobalSeq_NUMB
                     	JOIN         
                     	DEMO_Y1   D
                     	ON d.MemberMci_IDNO = R.PayorMCI_IDNO
                  WHERE       
                     R.StatusReceipt_CODE = @Lc_StatusReceiptI_CODE        
                     AND R.Distribute_DATE = @Ld_Low_DATE        
                     AND R.Release_DATE >= @Ld_Current_DATE        
                     AND R.EndValidity_DATE = @Ld_High_DATE       
                     AND NOT EXISTS       
                     (      
                        SELECT 1      
                        FROM RCTH_Y1  T      
                        WHERE       
                           R.Batch_DATE = T.Batch_DATE        
                           AND R.SourceBatch_CODE = T.SourceBatch_CODE        
                           AND R.Batch_NUMB = T.Batch_NUMB       
                           AND R.SeqReceipt_NUMB = T.SeqReceipt_NUMB       
                           AND R.PayorMCI_IDNO = T.PayorMCI_IDNO        
                           AND T.BackOut_INDC = @Lc_Yes_INDC        
                           AND T.EndValidity_DATE = @Ld_High_DATE      
                     )        
                     AND R.EventGlobalBeginSeq_NUMB = G.EventGlobalSeq_NUMB        
                     AND R.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO, R.PayorMCI_IDNO)        
                     AND ((      
                     @Ad_Batch_DATE IS NOT NULL        
                     AND R.Batch_DATE = @Ad_Batch_DATE        
                     AND R.SourceBatch_CODE = @Ac_SourceBatch_CODE        
                     AND R.Batch_NUMB = @An_Batch_NUMB        
                     AND R.SeqReceipt_NUMB = @An_SeqReceipt_NUMB) OR (@Ad_Batch_DATE IS NULL))       
                     AND R.Case_IDNO = ISNULL(@An_Case_IDNO, R.Case_IDNO)        
                     AND R.SourceReceipt_CODE = ISNULL(@Ac_SourceReceipt_CODE, R.SourceReceipt_CODE)        
                     AND R.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE, R.ReasonStatus_CODE)        
                     AND R.TypeRemittance_CODE = ISNULL(@Ac_TypeRemittance_CODE, R.TypeRemittance_CODE)        
                    AND R.SourceBatch_CODE = ISNULL(@Ac_SourceBatchIn_CODE, R.SourceBatch_CODE)      
               )   X      
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB      
         )   Y    LEFT OUTER JOIN  RSDU_Y1 r 
                      ON R.Batch_DATE = Y.Batch_DATE 
                      AND R.SourceBatch_CODE = Y.SourceBatch_CODE
                      AND R.Batch_NUMB = Y.Batch_NUMB
                      AND R.SeqReceipt_NUMB = Y.SeqReceipt_NUMB 
      WHERE Y.rnum >= @Ai_RowFrom_NUMB      
ORDER BY RNUM;      
      
                        
END; --End of RCTH_RETRIEVE_S26      


GO
