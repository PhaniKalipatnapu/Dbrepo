/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S158]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S158]  
(       
     @Ac_ReasonBackOut_CODE   CHAR(2),      
     @Ad_From_DATE  DATE,      
     @Ad_To_DATE  DATE,      
     @Ac_Worker_ID   CHAR(30),    
     @Ai_RowFrom_NUMB INT = 1,      
     @Ai_RowTo_NUMB     INT = 10  
)  
AS  
       
 /*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S158  
 *     DESCRIPTION       : This sp is uded to display the detail infromation about the amounts given
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 06-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/   
  
BEGIN  
  
 DECLARE   
  @Li_Zero_NUMB SMALLINT 		  = 0,  
  @Ld_High_DATE DATE 			  = '12/31/9999',  
  @Lc_SourceBatchIRS_CODE CHAR(3) = 'IRS',  
  @Lc_SourceBatchSDU_CODE CHAR(3) = 'SDU',  
  @Lc_BackOutY_INDC CHAR(1) 	  = 'Y',   
  @Lc_StatusReceiptU_CODE CHAR(1) = 'U',  
  @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
  @Lc_SourceReceiptBN_CODE CHAR(2) = 'BN' , 
  @Lc_SourceReceiptSQ_CODE CHAR(2) = 'SQ' , 
  @Lc_SourceReceiptPM_CODE CHAR(2) = 'PM' , 
  @Lc_SourceReceiptQR_CODE CHAR(2) = 'QR' , 
  @Lc_SourceReceiptVN_CODE CHAR(2) = 'VN' , 
  @Lc_SourceReceiptFC_CODE CHAR(2) = 'FC' ,
  @Lc_empty_CODE CHAR(1) ='';  
    
   
 SELECT x.Batch_DATE,      
        x.SourceBatch_CODE,      
        x.Batch_NUMB,      
        x.SeqReceipt_NUMB,      
        x.OrigReceipt_AMNT,   
        x.OrigCase_IDNO,   
        x.RePost_DATE,      
        x.Batch1_DATE,      
        x.SourceBatch1_CODE,      
        x.Batch1_NUMB,      
        x.SeqReceipt1_NUMB,      
  		x.RepostReceipt_AMNT,   
  		x.RepostCase_IDNO,      
        x.StatusReceipt_CODE,   
        x.Receipt_DATE,   
        x.Reversal_DATE,      
        d1.Last_NAME,  
    	d1.Suffix_NAME,  
    	d1.First_NAME,  
    	d1.Middle_NAME,   
        ReasonRePost_CODE,      
        d2.Last_NAME 	AS Last1_NAME,  
    	d2.Suffix_NAME 	AS Suffix1_NAME,  
    	d2.First_NAME 	AS First1_NAME,  
    	d2.Middle_NAME 	AS Middle1_NAME,   
        x.ReasonBackOut_CODE,      
        x.RepostPayorMci_IDNO,   
        x.OrigNcpMci_IDNO,      
        x.Worker_ID,  
        U.Last_NAME 	AS Last2_NAME,  
       	U.Suffix_NAME 	AS Suffix2_NAME,  
       	U.First_NAME 	AS First2_NAME,  
       	U.Middle_NAME 	AS Middle2_NAME,   
        x.RowCount_NUMB,      
              (SELECT TOP 1 Supervisor_ID      
           				FROM USRL_Y1 U     
          				WHERE U.Worker_ID = x.Worker_ID      
            			AND U.EndValidity_DATE = @Ld_High_DATE      
            			AND U.Expire_DATE > @Ld_Current_DATE       
            			AND RTRIM(U.Supervisor_ID) > @Lc_empty_CODE) AS	Supervisor_ID      
      FROM  (SELECT y.Batch_DATE,   
         		y.SourceBatch_CODE,      
                y.Batch_NUMB,   
                y.SeqReceipt_NUMB,  
                y.OrigReceipt_AMNT,   
                y.OrigCase_IDNO,      
                y.RePost_DATE,      
                y.Batch1_DATE,      
                y.SourceBatch1_CODE,      
                y.Batch1_NUMB,      
                y.SeqReceipt1_NUMB,      
                y.RepostReceipt_AMNT,      
                y.RepostCase_IDNO,   
                y.StatusReceipt_CODE,   
                y.Receipt_DATE,      
                y.Reversal_DATE,   
                y.PayorMCI_IDNO,      
                y.ReasonRePost_CODE,      
                y.ReasonBackOut_CODE,      
                y.RepostPayorMci_IDNO,   
                y.OrigNcpMci_IDNO,   
                y.Worker_ID,      
                COUNT(1) OVER() RowCount_NUMB,  
                ROW_NUMBER() OVER(ORDER BY Batch_DATE, SourceBatch_CODE, Batch_NUMB,      
                SeqReceipt_NUMB) ORD_ROWNUM      
                        FROM (SELECT r.Batch_DATE,
                        			r.SourceBatch_CODE,      
                                    r.Batch_NUMB, 
                                    r.SeqReceipt_NUMB,      
                                    ABS(r.Receipt_AMNT) OrigReceipt_AMNT,      
                                    CASE WHEN r.StatusReceipt_CODE = @Lc_StatusReceiptU_CODE   
                                    	THEN @Li_Zero_NUMB
                                    	ELSE r.Case_IDNO
                                    END AS OrigCase_IDNO,  
                                    rr.RePost_DATE,      
                                  	rr.Batch_DATE      AS Batch1_DATE,      
                                    rr.SourceBatch_CODE AS SourceBatch1_CODE,      
                                    rr.Batch_NUMB 		AS Batch1_NUMB,      
                                    rr.SeqReceipt_NUMB 	AS SeqReceipt1_NUMB,      
                                    rr.ReceiptCurrent_AMNT AS RepostReceipt_AMNT,      
                                    (SELECT TOP 1 Case_IDNO      
                                             FROM RCTH_Y1 e      
                                          	 WHERE e.Batch_DATE =rr.Batch_DATE      
                                              AND e.Batch_NUMB = rr.Batch_NUMB      
                                              AND e.SourceBatch_CODE = rr.SourceBatch_CODE      
                                              AND e.SeqReceipt_NUMB = rr.SeqReceipt_NUMB      
                                              AND e.EndValidity_DATE = @Ld_High_DATE )     AS RepostCase_IDNO,      
                                    r.StatusReceipt_CODE AS StatusReceipt_CODE, 
                                    CASE WHEN r.StatusReceipt_CODE = @Lc_StatusReceiptU_CODE   
                                    	THEN ' ' 
                                    	ELSE (SELECT TOP 1 SourceBatch_CODE      
                                             FROM RCTH_Y1 f      
                                             WHERE f.SourceBatch_CODE IN (@Lc_SourceBatchIRS_CODE,@Lc_SourceBatchSDU_CODE )      
                                              AND f.Batch_DATE = rr.Batch_DATE      
                                              AND f.Batch_NUMB = rr.Batch_NUMB      
                                              AND f.SourceBatch_CODE = rr.SourceBatch_CODE      
                                              AND f.SeqReceipt_NUMB = rr.SeqReceipt_NUMB      
                                              AND f.EndValidity_DATE =@Ld_High_DATE)       
                                    END AS recoupment_payee,      
                                    r.Receipt_DATE Receipt_DATE,      
                                    r.BeginValidity_DATE AS Reversal_DATE,      
                                    r.PayorMCI_IDNO,      
                                    rr.ReasonRePost_CODE AS ReasonRePost_CODE,      
                                    r.ReasonBackOut_CODE AS ReasonBackOut_CODE,      
                                    (SELECT TOP 1 PayorMCI_IDNO      
                                             FROM RCTH_Y1 e      
                                             WHERE e.Batch_DATE = rr.Batch_DATE      
                                              AND e.Batch_NUMB = rr.Batch_NUMB      
                                              AND e.SourceBatch_CODE =rr.SourceBatch_CODE      
                                              AND e.SeqReceipt_NUMB = rr.SeqReceipt_NUMB      
                                              AND e.EndValidity_DATE =@Ld_High_DATE 
                                              AND e.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptBN_CODE,@Lc_SourceReceiptSQ_CODE,@Lc_SourceReceiptPM_CODE,@Lc_SourceReceiptQR_CODE,@Lc_SourceReceiptVN_CODE,@Lc_SourceReceiptFC_CODE) )AS RepostPayorMci_IDNO,      
                                    CASE WHEN r.StatusReceipt_CODE = @Lc_StatusReceiptU_CODE   
                                    	THEN @Li_Zero_NUMB
                                    	ELSE r.PayorMCI_IDNO
                                    END AS OrigNcpMci_IDNO,   
                                    g.Worker_ID      
                                     			FROM RCTH_Y1 r WITH (INDEX(RCTH_DT_BEG_VALIDITY_I1)) 
                                     			LEFT OUTER JOIN RCTR_Y1 rr       
                                     			ON( r.Batch_DATE = rr.BatchOrig_DATE AND r.Batch_NUMB = rr.BatchOrig_NUMB      
                      								AND r.SourceBatch_CODE = rr.SourceBatchOrig_CODE  AND r.SeqReceipt_NUMB = rr.SeqReceiptOrig_NUMB      
                                      				AND r.EndValidity_DATE = rr.EndValidity_DATE), 
                                      			GLEV_Y1 g      
                                    			WHERE r.BeginValidity_DATE BETWEEN @Ad_From_DATE  AND @Ad_To_DATE      
                                      			AND r.BackOut_INDC = @Lc_BackOutY_INDC      
                                      			AND r.EndValidity_DATE =@Ld_High_DATE    
                                      			AND r.EventGlobalBeginSeq_NUMB =g.EventGlobalSeq_NUMB      
                                      			      
                                      			AND (   (    @Ac_ReasonBackOut_CODE IS NULL      
                                      			         AND r.ReasonBackOut_CODE =      
                                      			                       r.ReasonBackOut_CODE      
                                      			        )      
                                      			     OR (    @Ac_ReasonBackOut_CODE IS NOT NULL      
                                      			         AND r.ReasonBackOut_CODE =      
                                      			                      @Ac_ReasonBackOut_CODE      
                                      			        )      
                                      			    )      
                                      			AND (   (    @Ac_Worker_ID IS NULL      
                                      			         AND g.Worker_ID = g.Worker_ID      
                                      			        )      
                                      			     OR (    @Ac_Worker_ID IS NOT NULL      
                                      			         AND g.Worker_ID = @Ac_Worker_ID      
                                      			        )      
                                      			   )  )Y)x   
                                          LEFT OUTER JOIN  
                                          DEMO_Y1 d1   
                                          ON d1.MemberMci_IDNO = x.RepostPayorMci_IDNO  
                                          LEFT OUTER JOIN  
                                          DEMO_Y1 d2   
                                          ON d2.MemberMci_IDNO = x.PayorMCI_IDNO  
                                          LEFT OUTER JOIN  
                                          USEM_Y1 U  
               ON U.Worker_ID = x.Worker_ID  
                AND U.EndValidity_DATE = @Ld_High_DATE  
                 WHERE ((x.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
                    OR (@Ai_RowFrom_NUMB=@Li_Zero_NUMB)) 
                   AND ((x.ORD_ROWNUM >= @Ai_RowFrom_NUMB) 
                    OR (@Ai_RowFrom_NUMB=@Li_Zero_NUMB));       
                    
END -- END OF RCTH_RETRIEVE_S158  

GO
