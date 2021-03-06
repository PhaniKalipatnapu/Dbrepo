/****** Object:  StoredProcedure [dbo].[RDHRR_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

       
CREATE PROCEDURE  
	[dbo].[RDHRR_RETRIEVE_S10] 
		(  
			 @An_Case_IDNO			NUMERIC(6,0)	, 
			 @An_PayorMCI_IDNO		NUMERIC(10,0)	, 
			 @Ac_ReasonStatus_CODE	CHAR(4)			,
			 @Ad_From_DATE			DATE			,
			 @Ai_RowFrom_NUMB     	INT	=1			,
			 @Ai_RowTo_NUMB       	INT	=10   
		)                                
AS  
  
/*  
 *     PROCEDURE NAME    : RDHRR_RETRIEVE_S10  
 *     DESCRIPTION       : Retrieve Ncp Disbursement Hold Information for caseid,payor id and reason status  
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-OCT-2011    
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
  
      DECLARE  
         @Lc_StatusBatchUnreconciled_CODE	CHAR(1) = 'U',   
         @Lc_No_INDC						CHAR(1) = 'N',   
         @Lc_StatusReceiptHeld_CODE			CHAR(1) = 'H',   
         @Lc_StatusReceiptIdentified_CODE	CHAR(1) = 'I',   
         @Lc_Yes_INDC						CHAR(1) = 'Y',   
         @Ld_High_DATE						DATE    = '12/31/9999',  
         @Li_Zero_NUMB						SMALLINT= 0 , 
         @Li_One_NUMB						SMALLINT= 1 ,          
         @Lc_SourceBatchDcs_CODE			CHAR(3) = 'DCS',   
         @Lc_SourceBatchDcr_CODE			CHAR(3) = 'DCR',   
         @Lc_ReasonStatusSnip_CODE			CHAR(4) = 'SNIP',     
         @Lc_HoldLevelDistribute_CODE		CHAR(4) = 'DIST',   
         @Lc_RefmTableRcth_ID				CHAR(4) = 'RCTH';  
          
        SELECT f.ReasonStatus_CODE ,   
               f.CountHold_QNTY,   
               f.Hold_AMNT ,   
               f.Total_AMNT ,   
               f.CountTotal_QNTY ,   
               f.RowCount_NUMB   
        FROM  ( 
         SELECT e.ReasonStatus_CODE,   
			    e.CountHold_QNTY ,   
			    e.Hold_AMNT,   
			    e.Total_AMNT,   
			    e.CountTotal_QNTY,   
			    e.RowCount_NUMB,   
			    e.ORD_ROWNUM AS row_num  
            FROM (
              SELECT x.ReasonStatus_CODE ,   
                     SUM(ISNULL(x.Count_QNTY, @Li_Zero_NUMB)) AS CountHold_QNTY,   
                     SUM(ISNULL(x.ToDistribute_AMNT, @Li_Zero_NUMB)) AS Hold_AMNT,   
                     SUM(SUM(ISNULL(x.ToDistribute_AMNT, @Li_Zero_NUMB))) OVER() AS Total_AMNT,   
                     SUM(SUM(ISNULL(x.Count_QNTY, @Li_Zero_NUMB))) OVER() AS CountTotal_QNTY,   
                     COUNT(1) OVER() AS RowCount_NUMB,   
                     ROW_NUMBER() OVER(  
                        ORDER BY x.ReasonStatus_CODE ASC) AS ORD_ROWNUM  
                  FROM ( 
                    SELECT a.ToDistribute_AMNT,   
                           CASE a.ToDistribute_AMNT  
                              WHEN @Li_Zero_NUMB THEN @Li_One_NUMB  
                              ELSE @Li_One_NUMB  
                           END AS Count_QNTY,   
                           a.ReasonStatus_CODE,   
                           a.DescriptionReason_TEXT,   
                           ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB  
                              ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS MaxSeqReceipt_NUMB  
                        FROM RDHRR_Y1   a  
                        WHERE a.BeginValidity_DATE = @Ad_From_DATE    
                          AND a.EndValidity_DATE > @Ad_From_DATE    
                          AND a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE    
                          AND a.BackOut_INDC = @Lc_No_INDC    
                          AND (a.SourceBatch_CODE NOT IN ( @Lc_SourceBatchDcr_CODE, @Lc_SourceBatchDcs_CODE ) 
                             OR (a.SourceBatch_CODE = @Lc_SourceBatchDcs_CODE  
                          AND EXISTS   
                           (SELECT 1  
                              FROM RCTR_Y1  b  
                              WHERE a.Batch_DATE = b.Batch_DATE    
                                AND a.Batch_NUMB = b.Batch_NUMB    
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB    
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE    
                                AND b.BeginValidity_DATE <= @Ad_From_DATE    
                                AND b.EndValidity_DATE > @Ad_From_DATE  
                           )))    
                          AND a.Distribute_DATE = @Ad_From_DATE    
                          AND EXISTS   
                           (SELECT 1  
                              FROM RDHRR_Y1  b  
                              WHERE a.Batch_DATE = b.Batch_DATE    
                                AND a.Batch_NUMB = b.Batch_NUMB    
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB    
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE    
                                AND b.BeginValidity_DATE < @Ad_From_DATE  
                           )    
                          AND NOT EXISTS   
                           (SELECT 1  
                              FROM RBAT_Y1  b  
                              WHERE a.Batch_DATE = b.Batch_DATE    
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE    
                                AND a.Batch_NUMB = b.Batch_NUMB    
                                AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE    
                                AND b.EndValidity_DATE > @Ad_From_DATE  
                           )    
                          AND NOT EXISTS   
                           (SELECT 1  
                              FROM RDHRR_Y1   b  
                              WHERE a.Batch_DATE = b.Batch_DATE    
                                AND a.Batch_NUMB = b.Batch_NUMB    
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB    
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE    
                                AND b.BackOut_INDC = @Lc_Yes_INDC    
                                AND b.BeginValidity_DATE <= @Ad_From_DATE    
                                AND b.EndValidity_DATE > @Ad_From_DATE  
                           )    
                          AND EXISTS   
                           (SELECT 1  
                              FROM RDHRR_Y1  b  
                              WHERE a.Batch_DATE = b.Batch_DATE    
                                AND a.Batch_NUMB = b.Batch_NUMB    
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB    
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE    
                                AND b.EventGlobalBeginSeq_NUMB =   
                                 (SELECT MAX(c.EventGlobalBeginSeq_NUMB)  
                                    FROM RDHRR_Y1  c  
                                    WHERE a.Batch_DATE = c.Batch_DATE    
                                      AND a.Batch_NUMB = c.Batch_NUMB    
                                      AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB    
                                      AND a.SourceBatch_CODE = c.SourceBatch_CODE    
                                      AND c.BeginValidity_DATE < @Ad_From_DATE    
                                      AND c.EndValidity_DATE = @Ad_From_DATE  
                                 ) 
                                 AND((		b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE 
										AND b.ReasonStatus_CODE != @Lc_ReasonStatusSnip_CODE) 
										OR (b.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE)))    
                           AND a.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE,a.ReasonStatus_CODE) 
                           AND a.Case_IDNO = ISNULL( @An_Case_IDNO,a.Case_IDNO)
						   AND a.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO,a.PayorMCI_IDNO)   
                     )   x   
                        LEFT OUTER JOIN UCAT_Y1   y   
                        ON   
                           	  y.Udc_CODE = x.ReasonStatus_CODE    
                          AND y.Table_ID = @Lc_RefmTableRcth_ID    
                          AND y.TableSub_ID = @Lc_RefmTableRcth_ID    
                          AND y.HoldLevel_CODE = @Lc_HoldLevelDistribute_CODE    
                          AND y.EndValidity_DATE = @Ld_High_DATE  
                  GROUP BY x.ReasonStatus_CODE, x.DescriptionReason_TEXT  
  
               )   e  
            WHERE e.ORD_ROWNUM <= @Ai_RowTo_NUMB 
				OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB  
         )   f  
      WHERE (f.row_num >= @Ai_RowFrom_NUMB) 
		OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)  
ORDER BY ROW_NUM;  
  
                    
END; --END OF RDHRR_RETRIEVE_S10 
  
  
  
GO
