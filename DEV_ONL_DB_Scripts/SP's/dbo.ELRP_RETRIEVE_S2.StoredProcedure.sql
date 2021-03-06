/****** Object:  StoredProcedure [dbo].[ELRP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELRP_RETRIEVE_S2]                                                              
(
   @Ad_From_DATE			DATE,                                           
   @Ad_To_DATE				DATE,                                             
   @Ac_ReasonBackOut_CODE	CHAR(2),                                               
   @Ac_Worker_ID		 	CHAR(30),                                                   
   @An_ReceiptCnt_QNTY      NUMERIC(11)  OUTPUT,                                           
   @An_Receipt_AMNT		 	NUMERIC(11,2) OUTPUT,                                          
   @An_DisbCnt_QNTY         NUMERIC(11)  OUTPUT,                                           
   @An_Disburse_AMNT         NUMERIC(11,2) OUTPUT,                                          
   @An_NcpHoldCnt_QNTY      NUMERIC(11)  OUTPUT,                                           
   @An_NcpHold_AMNT         NUMERIC(11,2) OUTPUT,                                          
   @An_DisbHoldCnt_QNTY     NUMERIC(11)  OUTPUT,                                           
   @An_DisbHold_AMNT        NUMERIC(11,2) OUTPUT,                                          
   @An_UrctCnt_QNTY         NUMERIC(11)  OUTPUT,                                           
   @An_Urct_AMNT            NUMERIC(11,2) OUTPUT                               
)

AS  

/*
 *     PROCEDURE NAME    : ELRP_RETRIEVE_S2
 *     DESCRIPTION       : This sp is used to display the following details Receipt Reversed Count,Receipt Reversed  Amount,Disbursements Reversed Count,Disbursements Reversed Amount,
                           Distributions Reversed Count,Distributions Reversed Amount,Disbursement Holds  Reversed Count,Disbursement Holds ReversedAmount 
						  ,Unidentified Receipt Reversed  Count and Unidentified Receipts Reversed Amount
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

	DECLARE 
		@Ld_High_DATE DATE = '12/31/9999',
		@Lc_CaseRelationshipA_CODE CHAR(1) = 'A',
	 	@Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
	 	@Lc_StatusReceiptU_CODE	CHAR(1) = 'U',
	 	@Lc_BackOutY_INDC	CHAR(1) = 'Y',
	 	@Lc_BackOutN_INDC	CHAR(1) = 'N',
	 	@Lc_StatusCheckVN_CODE CHAR(2) = 'VN',
	 	@Lc_StatusCheckSN_CODE CHAR(2) = 'SN',
	 	@Lc_StatusCheckVR_CODE CHAR(2) = 'VR',
	 	@Lc_StatusCheckSR_CODE CHAR(2) = 'SR',
	 	@Lc_StatusCheckRE_CODE CHAR(2) = 'RE',
	 	@Lc_StatusReceiptH_CODE	CHAR(1) = 'H',
	 	@Lc_StatusReceiptI_CODE	CHAR(1) = 'I',
	 	@Lc_SourceBatchDCR_CODE	CHAR(3) = 'DCR',
	 	@Lc_StatusB_CODE	CHAR(1) = 'B';
	 	
    --13698 - RRAR - receiving Timeout Expired system error - Start 	
	
	WITH rtab AS                                                                               
              (                                                                               
                 SELECT a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB,                       
                        a.SeqReceipt_NUMB, a.EventGlobalBeginSeq_NUMB,                            
                        a.BeginValidity_DATE, amt_unidentified, Receipt_AMNT                  
                 FROM (SELECT r.Batch_DATE, r.SourceBatch_CODE, r.Batch_NUMB,               
                                r.SeqReceipt_NUMB, r.EventGlobalBeginSeq_NUMB,                    
                                r.BeginValidity_DATE,                      
                                r.StatusReceipt_CODE,                                         
                                CASE                                                          
                                   WHEN r.StatusReceipt_CODE =                                
                                                            @Lc_StatusReceiptU_CODE                           
                                      THEN r.Receipt_AMNT                                     
                                   ELSE 0                                                     
  								END amt_unidentified,                          
                                Receipt_AMNT                                                  
                        FROM RCTH_Y1 r                                          
                        WHERE EXISTS ( SELECT 1
										FROM  ELRP_Y1 e
									  WHERE r.Batch_DATE = e.BatchOrig_DATE                              
										AND r.SourceBatch_CODE = e.SourceBatchOrig_CODE                   
										AND r.Batch_NUMB = e.BatchOrig_NUMB                                
										AND r.SeqReceipt_NUMB = e.SeqReceiptOrig_NUMB                        
										AND r.EventGlobalBeginSeq_NUMB =e.EventGlobalBackOutSeq_NUMB  ) 
                            AND r.BeginValidity_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE        
                            AND r.BackOut_INDC = @Lc_BackOutY_INDC                                          
                            AND r.EndValidity_DATE = @Ld_High_DATE  
                            AND ISNULL(@Ac_ReasonBackOut_CODE, r.ReasonBackOut_CODE) = r.ReasonBackOut_CODE ) a         
                  WHERE @Ac_Worker_ID IS NULL
							OR EXISTS ( SELECT 1 
										  FROM GLEV_Y1 g 
										  WHERE g.Worker_ID = @Ac_Worker_ID
											AND a.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB )                                                                    
						) 

	--13698 - RRAR - receiving Timeout Expired system error - End						                                                                 
	
	SELECT 
		@An_Disburse_AMNT		 = ISNULL (ABS (SUM (x.ds_amt)), 0),                          
   		@An_DisbCnt_QNTY	 = ISNULL (SUM (CASE WHEN x.ds_amt = 0 THEN  0 ELSE 1 END ), 0),           
   		@An_NcpHold_AMNT	 = ISNULL (ABS (SUM (x.he_amt)), 0),                                       
   		@An_NcpHoldCnt_QNTY	 = ISNULL (SUM (CASE WHEN x.he_amt= 0 THEN 0 ELSE 1 END), 0),              
   		@An_DisbHold_AMNT	 = ISNULL (ABS (SUM (x.dh_amt)), 0),                         
   		@An_DisbHoldCnt_QNTY = ISNULL (SUM (CASE WHEN x.dh_amt= 0 THEN 0 ELSE 1 END), 0),              
   		@An_Urct_AMNT		 = ISNULL (ABS (SUM (x.un_amt)), 0),                                       
   		@An_UrctCnt_QNTY	 = ISNULL (SUM (CASE WHEN x.un_amt= 0 THEN 0 ELSE 1 END), 0),              
   		@An_Receipt_AMNT	 = ISNULL (ABS (SUM (x.tot_amt)), 0),                                      
   		@An_ReceiptCnt_QNTY	 = ISNULL (SUM (CASE WHEN x.tot_amt=0 THEN 0 ELSE 1 END), 0)               
    FROM 
    	(SELECT 
    		ISNULL (ds.amt, 0) + ISNULL (pf.amt, 0) ds_amt,                       
            ISNULL (he.amt, 0) he_amt, ISNULL (dh.amt, 0) dh_amt,                 
            ISNULL (r.amt_unidentified, 0) un_amt,                                
            r.Receipt_AMNT tot_amt                                                
         FROM 
         	rtab r 
         	LEFT OUTER JOIN                                                               
            (SELECT   
           		ds.Batch_DATE, 
           		ds.SourceBatch_CODE, 
           		ds.Batch_NUMB,          
                ds.SeqReceipt_NUMB,                                         
                ISNULL (SUM (ds.Disburse_AMNT), 0) amt                       
            FROM 
            	DSBL_Y1 ds, 
            	rtab r                                          
            WHERE 
            	  ds.Batch_DATE = r.Batch_DATE                                
              AND ds.SourceBatch_CODE = r.SourceBatch_CODE                    
              AND ds.Batch_NUMB = r.Batch_NUMB                                
              AND ds.SeqReceipt_NUMB = r.SeqReceipt_NUMB                      
              AND 
              	NOT EXISTS
              		  (                                                
                       SELECT 1                                                 
                       FROM 
                       	 DSBH_Y1 bc                                        
                       WHERE 
                       		ds.CheckRecipient_ID = bc.CheckRecipient_ID            
                        AND ds.CheckRecipient_CODE = bc.CheckRecipient_CODE            
                        AND ds.Disburse_DATE = bc.Disburse_DATE               
                        AND ds.DisburseSeq_NUMB = bc.DisburseSeq_NUMB                 
                        AND StatusCheck_CODE 
                        			IN (@Lc_StatusCheckVN_CODE, @Lc_StatusCheckSN_CODE, @Lc_StatusCheckVR_CODE, @Lc_StatusCheckSR_CODE, @Lc_StatusCheckRE_CODE)              
                        AND EndValidity_DATE = @Ld_High_DATE                
                        AND bc.EventGlobalBeginSeq_NUMB < r.EventGlobalBeginSeq_NUMB
                        )            
              AND 
                 NOT EXISTS 
                 	(                                                
                     SELECT 1                                                 
                     FROM 
                     	DSBC_Y1 bc                                        
                      WHERE 
                      		ds.CheckRecipient_ID = bc.CheckRecipientOrig_ID            
                        AND ds.CheckRecipient_CODE = bc.CheckRecipientOrig_ID            
                        AND ds.Disburse_DATE = bc.DisburseOrig_DATE          
                        AND ds.DisburseSeq_NUMB = bc.DisburseOrigSeq_NUMB
                     )            
        	  AND 
        		NOT EXISTS 
        			(                                                
                     SELECT 1                                                 
                     FROM 
                     	DHLD_Y1 bc                                        
                     WHERE ds.CheckRecipient_ID =bc.CheckRecipient_ID    
                        AND ds.CheckRecipient_CODE =bc.CheckRecipient_CODE    
                        AND ds.Disburse_DATE = bc.Disburse_DATE               
                        AND ds.DisburseSeq_NUMB = bc.DisburseSeq_NUMB                 
                        AND ds.Batch_DATE = bc.Batch_DATE                     
                        AND ds.SourceBatch_CODE = bc.SourceBatch_CODE            
                        AND ds.Batch_NUMB = bc.Batch_NUMB                     
                        AND ds.SeqReceipt_NUMB = bc.SeqReceipt_NUMB           
                        AND ds.Case_IDNO = bc.Case_IDNO                       
                        AND ds.OrderSeq_NUMB = bc.OrderSeq_NUMB                       
                        AND ds.ObligationSeq_NUMB = bc.ObligationSeq_NUMB             
                        AND ds.TypeDisburse_CODE = bc.TypeDisburse_CODE            
                        AND ds.EventGlobalSupportSeq_NUMB = bc.EventGlobalSupportSeq_NUMB
                     )              
              GROUP BY ds.Batch_DATE,                                              
                                  ds.SourceBatch_CODE,                                        
                                  ds.Batch_NUMB,                                              
                                  ds.SeqReceipt_NUMB) ds    
              ON
              (ds.Batch_DATE = r.Batch_DATE                                       
              AND ds.SourceBatch_CODE = r.SourceBatch_CODE                           
              AND ds.Batch_NUMB = r.Batch_NUMB                                       
              AND ds.SeqReceipt_NUMB = r.SeqReceipt_NUMB )       
              LEFT OUTER JOIN                                  
              (SELECT   
              	he.Batch_DATE, 
              	he.SourceBatch_CODE, 
              	he.Batch_NUMB,          
                he.SeqReceipt_NUMB,                                         
                ISNULL (SUM (he.ToDistribute_AMNT), 0) amt                  
                FROM 
                	RCTH_Y1 he, rtab r                                          
                WHERE 
                	he.Batch_DATE = r.Batch_DATE                                
                AND he.SourceBatch_CODE = r.SourceBatch_CODE                    
                AND he.Batch_NUMB = r.Batch_NUMB                                
                AND he.SeqReceipt_NUMB = r.SeqReceipt_NUMB                      
                              AND he.StatusReceipt_CODE IN (@Lc_StatusReceiptH_CODE, @Lc_StatusReceiptI_CODE)                         
                              AND (   he.StatusReceipt_CODE = @Lc_StatusReceiptH_CODE                            
                                   OR r.SourceBatch_CODE = @Lc_SourceBatchDCR_CODE                              
                                   OR (    he.Distribute_DATE = r.BeginValidity_DATE            
                                       AND StatusReceipt_CODE = @Lc_StatusReceiptI_CODE                           
                                       AND NOT EXISTS (                                       
                                              SELECT 1                                        
        										FROM DHLD_Y1 ld                               
                                               WHERE ld.Batch_DATE = r.Batch_DATE             
                                                 AND ld.SourceBatch_CODE = r.SourceBatch_CODE            
                                                 AND ld.Batch_NUMB = r.Batch_NUMB             
                                                 AND ld.SeqReceipt_NUMB =                     
                                                                    r.SeqReceipt_NUMB)        
                                      )                                                       
                                  )                                                           
                              AND he.BackOut_INDC = @Lc_BackOutN_INDC                                       
                              AND he.BeginValidity_DATE > @Ad_To_DATE                           
                         GROUP BY he.Batch_DATE,                                              
                                  he.SourceBatch_CODE,                                        
                                  he.Batch_NUMB,                                              
                                  he.SeqReceipt_NUMB) he    
                                  ON(he.Batch_DATE = r.Batch_DATE                                       
                        AND he.SourceBatch_CODE = r.SourceBatch_CODE                           
                        AND he.Batch_NUMB = r.Batch_NUMB                                       
                        AND he.SeqReceipt_NUMB = r.SeqReceipt_NUMB)     
                        LEFT OUTER JOIN                                   
                        (SELECT   dh.Batch_DATE, dh.SourceBatch_CODE, dh.Batch_NUMB,          
                                  dh.SeqReceipt_NUMB,                                         
                                  ISNULL (SUM (dh.Transaction_AMNT), 0) amt                    
                             FROM DHLD_Y1 dh, rtab r                                          
                            WHERE dh.Batch_DATE = r.Batch_DATE                                
                              AND dh.SourceBatch_CODE = r.SourceBatch_CODE                    
                              AND dh.Batch_NUMB = r.Batch_NUMB                                
                              AND dh.SeqReceipt_NUMB = r.SeqReceipt_NUMB                      
                              AND dh.BeginValidity_DATE >= r.BeginValidity_DATE               
                              AND (   dh.EventGlobalEndSeq_NUMB =                                
                                                           r.EventGlobalBeginSeq_NUMB             
                                   OR dh.Status_CODE = @Lc_StatusB_CODE                                      
                                  )                                                           
                         GROUP BY dh.Batch_DATE,                                              
                                  dh.SourceBatch_CODE,                                        
                                  dh.Batch_NUMB,                                              
                                  dh.SeqReceipt_NUMB) dh     
                                  ON( dh.Batch_DATE = r.Batch_DATE                                       
                        AND dh.SourceBatch_CODE = r.SourceBatch_CODE                           
                        AND dh.Batch_NUMB = r.Batch_NUMB                                       
                        AND dh.SeqReceipt_NUMB = r.SeqReceipt_NUMB )      
                        LEFT OUTER JOIN                                   
                        (SELECT   pf.Batch_DATE, pf.SourceBatch_CODE, pf.Batch_NUMB,          
                                  pf.SeqReceipt_NUMB,                                         
                                  SUM (CASE WHEN SIGN (RecOverpay_AMNT)= 1 THEN RecOverpay_AMNT ELSE 0 END) amt                                                   
                             FROM POFL_Y1 pf, rtab r                                          
                            WHERE pf.Batch_DATE = r.Batch_DATE                                
                              AND pf.SourceBatch_CODE = r.SourceBatch_CODE                    
                              AND pf.Batch_NUMB = r.Batch_NUMB                                
                              AND pf.SeqReceipt_NUMB = r.SeqReceipt_NUMB                      
                         GROUP BY pf.Batch_DATE,                                              
                                  pf.SourceBatch_CODE,                                        
                                  pf.Batch_NUMB,                                              
                                  pf.SeqReceipt_NUMB) pf      
                                  ON(pf.Batch_DATE = r.Batch_DATE                                       
                    AND pf.SourceBatch_CODE = r.SourceBatch_CODE                           
                    AND pf.Batch_NUMB = r.Batch_NUMB                                       
                    AND pf.SeqReceipt_NUMB = r.SeqReceipt_NUMB)                                    
                  ) x;                         

END -- END OF ELRP_RETRIEVE_S2

GO
