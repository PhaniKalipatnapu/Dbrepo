/****** Object:  StoredProcedure [dbo].[RDHRR_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

       
CREATE PROCEDURE  
	[dbo].[RDHRR_RETRIEVE_S5]  
		(  
			 @An_Case_IDNO			NUMERIC(6,0)	,       
			 @An_PayorMCI_IDNO		NUMERIC(10,0)	,       
			 @Ac_ReasonStatus_CODE	CHAR(4)			,  
			 @Ad_From_DATE			DATE			,       
			 @Ai_RowFrom_NUMB     	INT =1			,       
			 @Ai_RowTo_NUMB       	INT =10     
		)                                    
AS    
    
/*    
 *     PROCEDURE NAME    : RDHRR_RETRIEVE_S5    
 *     DESCRIPTION       : Retrieve Ncp Disbursement Receipt Information for caseid,payor id and reason status  
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-OCT-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
*/    
    
   BEGIN  
    
      DECLARE    
         @Lc_StatusBatchUnreconciled_CODE    CHAR(1) = 'U', 
         @Lc_No_INDC                         CHAR(1) = 'N',   
         @Lc_StatusReceiptHeld_CODE          CHAR(1) = 'H',     
         @Lc_StatusReceiptIdentified_CODE    CHAR(1) = 'I',     
         @Lc_Yes_INDC                        CHAR(1) = 'Y',    
         @Lc_Empty_TEXT						 CHAR(1) = '',     
         @Ld_High_DATE						 DATE	 = '12/31/9999',     
         @Lc_SourceBatchDcs_CODE			 CHAR(3) = 'DCS',     
         @Lc_SourceBatchDcr_CODE			 CHAR(3) = 'DCR',     
         @Lc_ReasonStatusSnip_CODE           CHAR(4) = 'SNIP', 
         @Lc_HoldLevelDistribute_CODE        CHAR(4) = 'DIST',     
         @Lc_RefmTableRcth_CODE              CHAR(4) = 'RCTH',
         @Li_Zero_NUMB						 SMALLINT= 0  ;      
            
       SELECT f.Batch_DATE, 
              f.SourceBatch_CODE, 
              f.Batch_NUMB, 
              f.SeqReceipt_NUMB ,        
              f.TypePosting_CODE , 
              f.Case_IDNO ,       
              f.PayorMCI_IDNO ,   
              f.ToDistribute_AMNT , 
              f.Receipt_DATE ,   
              f.ReasonStatus_CODE, 
              f.BeginValidity_DATE , 
              f.Release_DATE ,   
              f.Worker_ID ,     
              f.MemberSsn_NUMB ,     
              f.OtherCounty_IDNO ,    
              dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME(f.PayorMCI_IDNO) AS NcpName_TEXT,
              f.CountTotal_QNTY ,       
              f.Total_AMNT ,       
              f.RowCount_NUMB         
           FROM  (
            SELECT e.Batch_DATE, 
	               e.SourceBatch_CODE, 
	               e.Batch_NUMB, 
	               e.SeqReceipt_NUMB ,   
	               e.TypePosting_CODE,
	               e.Case_IDNO,
	               e.PayorMCI_IDNO, 
	               e.ToDistribute_AMNT, 
	               e.Receipt_DATE,
	               e.ReasonStatus_CODE, 
	               e.BeginValidity_DATE,   
	               e.Release_DATE ,
	               e.Worker_ID,    
	               e.MemberSsn_NUMB,     
	               e.OtherCounty_IDNO,   
	               e.CountTotal_QNTY,     
	               e.Total_AMNT,     
	               e.ORD_ROWNUM AS rnm,     
	               e.CountTotal_QNTY AS RowCount_NUMB    
            FROM (
              SELECT x.Batch_DATE, 
                     x.SourceBatch_CODE, 
                     x.Batch_NUMB, 
                     x.SeqReceipt_NUMB ,   
                     x.TypePosting_CODE,
                     x.Case_IDNO,  
                     x.PayorMCI_IDNO,                             
                     x.ToDistribute_AMNT,   
                     x.Receipt_DATE,
                     x.ReasonStatus_CODE,
                     x.BeginValidity_DATE, 
                     x.Release_DATE ,
                     x.EventGlobalBeginSeq_NUMB,      
                     x.Worker_ID,    
                     x.MemberSsn_NUMB ,     
                     x.OtherCounty_IDNO,                                                      
                     COUNT(1) OVER() AS CountTotal_QNTY,     
                     SUM(x.ToDistribute_AMNT) OVER() AS Total_AMNT,         
                     ROW_NUMBER() OVER(ORDER BY     
                           x.Worker_ID, 
                           x.Release_DATE DESC , 
                           x.Case_IDNO,       
                           x.Batch_DATE, 
                           x.SourceBatch_CODE, 
                           x.Batch_NUMB, 
                           x.SeqReceipt_NUMB ,   
                           x.EventGlobalBeginSeq_NUMB)  ORD_ROWNUM    
                  FROM (
                    SELECT a.Batch_DATE, 
                           a.SourceBatch_CODE, 
                           a.Batch_NUMB, 
                           a.SeqReceipt_NUMB ,
                           a.TypePosting_CODE,
                           a.Case_IDNO,     
                           a.PayorMCI_IDNO,
                           a.ToDistribute_AMNT,
                           a.Receipt_DATE, 
                           a.ReasonStatus_CODE,
                           a.BeginValidity_DATE,  
                           a.Release_DATE , 
                           a.Worker_ID,     
                           a.MemberSsn_NUMB,     
                           a.OtherCounty_IDNO,     
                           a.EventGlobalBeginSeq_NUMB,     
                           ROW_NUMBER() OVER(PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB    
                              ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS MaxSeqReceipt_NUMB    
                        FROM RDHRR_Y1   a    
                        WHERE  a.BeginValidity_DATE = @Ad_From_DATE      
	                      AND  a.EndValidity_DATE > @Ad_From_DATE      
	                      AND  a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE      
	                      AND  a.BackOut_INDC = @Lc_No_INDC      
                          AND (   a.SourceBatch_CODE NOT IN ( @Lc_SourceBatchDcr_CODE, @Lc_SourceBatchDcs_CODE ) 
                               OR (a.SourceBatch_CODE = @Lc_SourceBatchDcs_CODE AND EXISTS     
                           (SELECT 1    
                              FROM RCTR_Y1   b    
                              WHERE a.Batch_DATE = b.Batch_DATE      
                                AND a.Batch_NUMB = b.Batch_NUMB      
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB      
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE      
                                AND b.BeginValidity_DATE <= @Ad_From_DATE      
                                AND b.EndValidity_DATE > @Ad_From_DATE    
                           ))) 
                          AND a.Distribute_DATE = @Ad_From_DATE 
                          AND EXISTS     
                           (    
                              SELECT 1    
                              FROM RDHRR_Y1  b    
                              WHERE a.Batch_DATE = b.Batch_DATE      
                                AND a.Batch_NUMB = b.Batch_NUMB      
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB      
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE      
								AND b.BeginValidity_DATE < @Ad_From_DATE    
                           ) 
                         AND NOT EXISTS     
                           (SELECT 1    
                              FROM RBAT_Y1   b    
                              WHERE a.Batch_DATE = b.Batch_DATE      
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE      
                                AND a.Batch_NUMB = b.Batch_NUMB      
                                AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE      
                                AND b.EndValidity_DATE > @Ad_From_DATE    
                           )      
                          AND NOT EXISTS     
                           ( SELECT 1    
                              FROM RDHRR_Y1   b    
                              WHERE a.Batch_DATE = b.Batch_DATE      
                                AND a.Batch_NUMB = b.Batch_NUMB      
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB      
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE      
                                AND b.BackOut_INDC = @Lc_Yes_INDC      
                                AND b.BeginValidity_DATE <= @Ad_From_DATE      
                                AND b.EndValidity_DATE > @Ad_From_DATE    
                           )      
                         AND  EXISTS     
                           (SELECT 1    
                              FROM RDHRR_Y1   b    
                              WHERE a.Batch_DATE = b.Batch_DATE      
                                AND a.Batch_NUMB = b.Batch_NUMB      
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB      
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE      
                                AND b.EventGlobalBeginSeq_NUMB =     
                                 (    
                                    SELECT MAX(c.EventGlobalBeginSeq_NUMB)    
                                    FROM RDHRR_Y1  c    
                                    WHERE a.Batch_DATE = c.Batch_DATE      
                                      AND a.Batch_NUMB = c.Batch_NUMB      
                                      AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB      
                                      AND a.SourceBatch_CODE = c.SourceBatch_CODE      
                                      AND c.BeginValidity_DATE < @Ad_From_DATE      
                                      AND c.EndValidity_DATE = @Ad_From_DATE    
                                 ) 
                              AND (  (	b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE 
									AND b.ReasonStatus_CODE != @Lc_ReasonStatusSnip_CODE) 
                                   OR (b.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE))    
                           )      
                           AND a.ReasonStatus_CODE = ISNULL(@Ac_ReasonStatus_CODE,@Lc_Empty_TEXT) 
                           AND a.Case_IDNO = ISNULL( @An_Case_IDNO,a.Case_IDNO)
						   AND a.PayorMCI_IDNO = ISNULL(@An_PayorMCI_IDNO,a.PayorMCI_IDNO)   
                     )    x     
                        LEFT OUTER JOIN UCAT_Y1  y     
                        ON     
                             y.Udc_CODE = x.ReasonStatus_CODE      
                         AND y.Table_ID = @Lc_RefmTableRcth_CODE      
                         AND y.TableSub_ID = @Lc_RefmTableRcth_CODE      
                         AND y.HoldLevel_CODE = @Lc_HoldLevelDistribute_CODE      
                         AND y.EndValidity_DATE = @Ld_High_DATE    
               )   e    
            WHERE  e.ORD_ROWNUM <= @Ai_RowTo_NUMB 
                  OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB    
         )   f    
      WHERE (f.rnm >= @Ai_RowFrom_NUMB) 
           OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)    
ORDER BY RNM;    
    
                      
END; --END OF RDHRR_RETRIEVE_S5  
    
    
GO
