/****** Object:  StoredProcedure [dbo].[RDHRR_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

      
CREATE PROCEDURE  
	[dbo].[RDHRR_RETRIEVE_S7]
		 (  
			 @An_Case_IDNO			NUMERIC(6,0)	,   
			 @An_PayorMCI_IDNO		NUMERIC(10,0)	,   
			 @Ac_ReasonStatus_CODE	CHAR(4)			, 
			 @Ad_From_DATE			DATE			,   
			 @Ai_RowFrom_NUMB		INT =1			, 
			 @Ai_RowTo_NUMB			INT =10            
		  )              
AS  
  
/*  
 *     PROCEDURE NAME    : RDHRR_RETRIEVE_S7  
 *     DESCRIPTION       : Retrieve Disbursement Hold Information for caseid,payor id and reason status  
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-OCT-2011    
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
  
      DECLARE  
         @Lc_StatusReceiptHeld_CODE			CHAR(1) = 'H',   
         @Lc_StatusReceiptIdentified_CODE	CHAR(1) = 'I',   
         @Lc_Yes_INDC						CHAR(1) = 'Y',   
         @Ld_High_DATE						DATE	= '12/31/9999',
         @Li_Zero_NUMB						SMALLINT= 0 , 
         @Li_One_NUMB						SMALLINT= 1 ,         
         @Lc_HoldLevelDistribute_CODE		CHAR(4) = 'DIST',   
         @Lc_RefmTableRcth_ID               CHAR(4) = 'RCTH';  
          
        SELECT c.ReasonStatus_CODE ,   
               c.CountHold_QNTY  ,   
               c.Hold_AMNT ,   
               c.Total_AMNT  ,   
               c.CountTotal_QNTY  ,   
               c.RowCount_NUMB   
      FROM (
        SELECT b.ReasonStatus_CODE,   
               b.hold_count AS CountHold_QNTY,   
               b.Hold_AMNT,   
               b.Total_AMNT,   
               b.CountTotal_QNTY,   
               b.RowCount_NUMB,   
               b.ORD_ROWNUM AS row_num  
            FROM  (
              SELECT x.ReasonStatus_CODE ,   
                     SUM(ISNULL(x.Count_QNTY, @Li_Zero_NUMB)) AS hold_count,   
                     SUM(ISNULL(x.ToDistribute_AMNT, @Li_Zero_NUMB)) AS Hold_AMNT,   
                     SUM(SUM(ISNULL(x.ToDistribute_AMNT, @Li_Zero_NUMB))) OVER() AS Total_AMNT,   
                     SUM(SUM(ISNULL(x.Count_QNTY, @Li_Zero_NUMB))) OVER() AS CountTotal_QNTY,   
                     COUNT(1) OVER() AS RowCount_NUMB,   
                     ROW_NUMBER() OVER(  
                        ORDER BY x.ReasonStatus_CODE ASC) ORD_ROWNUM  
                  FROM  (
                    SELECT a.ToDistribute_AMNT,   
                           CASE a.ToDistribute_AMNT  
                              WHEN @Li_Zero_NUMB THEN @Li_One_NUMB  
                              ELSE @Li_One_NUMB  
                           END AS Count_QNTY,   
                           a.ReasonStatus_CODE,   
                           a.DescriptionReason_TEXT,   
                           ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB  
                              ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS max_seq_rcpt  
                        FROM RDHRR_Y1   a  
                        WHERE a.BeginValidity_DATE = @Ad_From_DATE    
                          AND a.StatusReceipt_CODE IN ( @Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptIdentified_CODE)    
                          AND a.EndValidity_DATE > a.BeginValidity_DATE    
                          AND NOT EXISTS   
                           (  
                              SELECT 1  
                              FROM RDHRR_Y1   x  
                              WHERE a.Batch_DATE = x.Batch_DATE    
                                AND a.Batch_NUMB = x.Batch_NUMB    
                                AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB    
                                AND a.SourceBatch_CODE = x.SourceBatch_CODE    
                                AND x.BackOut_INDC = @Lc_Yes_INDC    
                                AND x.BeginValidity_DATE = a.BeginValidity_DATE  
                           )    
                         AND a.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE,a.ReasonStatus_CODE) 
                         AND a.Case_IDNO = ISNULL( @An_Case_IDNO,a.Case_IDNO)
						 AND a.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO,a.PayorMCI_IDNO)  
                     )   x   
                        LEFT OUTER JOIN UCAT_Y1  y   
                        ON   
                           	  y.Udc_CODE = x.ReasonStatus_CODE    
                          AND y.Table_ID = @Lc_RefmTableRcth_ID    
                          AND y.TableSub_ID = @Lc_RefmTableRcth_ID    
                          AND y.HoldLevel_CODE = @Lc_HoldLevelDistribute_CODE    
                          AND y.EndValidity_DATE = @Ld_High_DATE 
                  GROUP BY x.ReasonStatus_CODE, x.DescriptionReason_TEXT  
  
               )   b  
            WHERE b.ORD_ROWNUM <= @Ai_RowTo_NUMB 
            	OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB  
         )   c  
      WHERE (c.row_num >= @Ai_RowFrom_NUMB) 
      	OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)  
ORDER BY ROW_NUM;  
  
                    
END; --END OF RDHRR_RETRIEVE_S7 
  
  
  
GO
