/****** Object:  StoredProcedure [dbo].[RDHRR_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    
CREATE PROCEDURE  
	[dbo].[RDHRR_RETRIEVE_S8]  
		(  
			 @An_Case_IDNO			NUMERIC(6,0)	, 
			 @An_PayorMCI_IDNO		NUMERIC(10,0)	, 
			 @Ac_ReasonStatus_CODE	CHAR(4)			, 
			 @Ad_From_DATE			DATE			, 
			 @Ai_RowFrom_NUMB		INT=1			,
			 @Ai_RowTo_NUMB			INT=10     
		)                     
AS  
  
/*  
 *     PROCEDURE NAME    : RDHRR_RETRIEVE_S8  
 *     DESCRIPTION       : Retrieve Ncp Disbursement Hold ReceiptSummary Information for caseid,payor id and reason status  
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-OCT-2011    
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
   
      DECLARE  
         @Lc_StatusReceiptHeld_CODE		CHAR(1) = 'H',   
         @Lc_Yes_INDC					CHAR(1) = 'Y',   
         @Ld_High_DATE					DATE    ='12/31/9999',     
         @Lc_HoldLevelDistribute_CODE	CHAR(4) = 'DIST', 
         @Li_Zero_NUMB					SMALLINT= 0 , 
         @Li_One_NUMB					SMALLINT= 1 ,           
         @Lc_RefmTableRcth_ID			CHAR(4) = 'RCTH';  
          
        SELECT d.Udc_CODE,   
               d.CountHold_QNTY,   
               d.Hold_AMNT ,   
               d.Total_AMNT ,   
               d.CountTotal_QNTY ,   
               d.RowCount_NUMB  
      FROM  (
        SELECT e.Udc_CODE,   
               e.hold_count AS CountHold_QNTY,   
               e.Hold_AMNT,   
               e.Total_AMNT,   
               e.CountTotal_QNTY,   
               e.RowCount_NUMB,   
               e.ORD_ROWNUM AS row_num  
            FROM (
              SELECT y.Udc_CODE ,   
                     SUM(ISNULL(x.Count_QNTY, @Li_Zero_NUMB)) AS hold_count,   
                     SUM(ISNULL(x.ToDistribute_AMNT, @Li_Zero_NUMB)) AS Hold_AMNT,   
                     SUM(SUM(ISNULL(x.ToDistribute_AMNT, @Li_Zero_NUMB))) OVER() AS Total_AMNT,   
                     SUM(SUM(ISNULL(x.Count_QNTY, @Li_Zero_NUMB))) OVER() AS CountTotal_QNTY,   
                     COUNT(1) OVER() AS RowCount_NUMB,   
                     ROW_NUMBER() OVER(  
                        ORDER BY y.Udc_CODE )  ORD_ROWNUM  
                  FROM (
                    SELECT a.ToDistribute_AMNT,   
                           CASE a.ToDistribute_AMNT  
                              WHEN @Li_Zero_NUMB THEN @Li_One_NUMB  
                              ELSE @Li_One_NUMB  
                           END AS Count_QNTY,   
                           a.ReasonStatus_CODE,   
                           a.DescriptionReason_TEXT,   
                           ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB  
                              ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS max_seq_rcpt  
                        FROM RDHRR_Y1  a  
                        WHERE a.BeginValidity_DATE = @Ad_From_DATE    
                          AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE    
                          AND a.EndValidity_DATE > a.BeginValidity_DATE    
                          AND NOT EXISTS   
                           (SELECT 1  
                              FROM RDHRR_Y1  x  
                              WHERE a.Batch_DATE = x.Batch_DATE    
                                AND a.Batch_NUMB = x.Batch_NUMB    
                                AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB    
                                AND a.SourceBatch_CODE = x.SourceBatch_CODE    
                                AND x.BackOut_INDC = @Lc_Yes_INDC    
                                AND x.BeginValidity_DATE = a.BeginValidity_DATE  
                           )    
                         AND NOT EXISTS   
                          (SELECT 1  
                              FROM RDHRR_Y1  x  
                              WHERE x.Batch_DATE = a.Batch_DATE    
                                AND x.Batch_NUMB = a.Batch_NUMB    
                                AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB    
                                AND x.SourceBatch_CODE = a.SourceBatch_CODE    
                                AND x.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE    
                                AND x.BeginValidity_DATE < a.BeginValidity_DATE    
                                AND x.EventGlobalBeginSeq_NUMB =   
                                 ( SELECT MAX(c.EventGlobalBeginSeq_NUMB)  
                                    FROM RDHRR_Y1  c  
                                    WHERE c.Batch_DATE = a.Batch_DATE    
                                      AND c.SourceBatch_CODE = a.SourceBatch_CODE    
                                      AND c.Batch_NUMB = a.Batch_NUMB    
                                      AND c.SeqReceipt_NUMB = a.SeqReceipt_NUMB    
                                      AND c.BeginValidity_DATE < a.BeginValidity_DATE    
                                      AND c.EndValidity_DATE = a.BeginValidity_DATE  
                                 )  
                           )    
                           AND a.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE,a.ReasonStatus_CODE) 
                           AND a.Case_IDNO = ISNULL( @An_Case_IDNO,a.Case_IDNO)
						   AND a.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO,a.PayorMCI_IDNO)  
                     )   x
                     JOIN
						UCAT_Y1  y  
							ON 
								y.Udc_CODE = x.ReasonStatus_CODE    
                  WHERE y.Udc_CODE = ISNULL(@Ac_ReasonStatus_CODE, y.Udc_CODE)   
                    AND y.Table_ID = @Lc_RefmTableRcth_ID    
                    AND y.TableSub_ID = @Lc_RefmTableRcth_ID    
                    AND y.HoldLevel_CODE = @Lc_HoldLevelDistribute_CODE    
                    AND y.EndValidity_DATE = @Ld_High_DATE  
                  GROUP BY y.Udc_CODE, x.DescriptionReason_TEXT  
               )   e 
            WHERE e.ORD_ROWNUM <= @Ai_RowTo_NUMB 
            	OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB  
         )   d  
      WHERE (d.row_num >= @Ai_RowFrom_NUMB) 
      	OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)  
ORDER BY ROW_NUM;  
  
                    
END; --END OF RDHRR_RETRIEVE_S8 
  
  
  
GO
