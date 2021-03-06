/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE  [dbo].[POFL_RETRIEVE_S3] (    
 @Ac_CheckRecipient_ID		CHAR(10), 
 @Ac_CheckRecipient_CODE	CHAR(1),    
 @An_Case_IDNO		 		NUMERIC(6,0),  
 @Ad_TransactionFrom_DATE	DATE,    
 @Ad_TransactionTo_DATE  	DATE,    
 @Ai_RowFrom_NUMB        	INT = 1, 
 @Ai_RowTo_NUMB          	INT = 10 
 )                                                        
AS        
 /*        
  *     PROCEDURE NAME    : POFL_RETRIEVE_S3        
  *     DESCRIPTION       : Retrieve to get recoupemnt detials from vpofl table and display it in the main grid        
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-NOV-2011        
  *     MODIFIED BY       :         
  *     MODIFIED ON       :         
  *     VERSION NO        : 1        
 */        
 BEGIN       
  DECLARE @Ld_Current_DATE   	   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),    
       	  @Lc_TransactionChpv_CODE CHAR(4) = 'CHPV',    
       	  @Lc_TransactionChav_CODE CHAR(4) = 'CHAV',    
       	  @Lc_TransactionBkrr_CODE CHAR(4) = 'BKRR',    
       	  @Lc_TransactionBkpe_CODE CHAR(4) = 'BKPE',    
       	  @Lc_TransactionRdpe_CODE CHAR(4) = 'RDPE',    
       	  @Lc_TransactionInpe_CODE CHAR(4) = 'INPE',    
       	  @Lc_TransactionRepe_CODE CHAR(4) = 'REPE',    
       	  @Lc_TransactionConv_CODE CHAR(4) = 'CONV',    
       	  @Lc_TransactionBkrc_CODE CHAR(4) = 'BKRC',    
       	  @Lc_TransactionRdrc_CODE CHAR(4) = 'RDRC',    
       	  @Lc_TransactionInrc_CODE CHAR(4) = 'INRC',         
       	  @Lc_TransactionAppe_CODE CHAR(4) = 'APPE',    
       	  @Lc_TransactionSrec_CODE CHAR(4) = 'SREC',     
       	  @Lc_TransactionChsw_CODE CHAR(4) = 'CHSW',     
       	  @Lc_TransactionChwp_CODE CHAR(4) = 'CHWP',    
       	  @Lc_TransactionCmul_CODE CHAR(4) = 'CMUL',    
       	  @Lc_Space_TEXT  		  CHAR(1) = '',    
       	  @Ld_Low_DATE    		  DATE	= '01/01/0001',       
       	  @Li_Zero_NUMB   		  SMALLINT = 0,    
       	  @Li_One_NUMB    		  SMALLINT = 1,    
       	  @Li_Two_NUMB    		  SMALLINT = 2,    
       	  @Li_Three_NUMB  		  SMALLINT = 3,    
       	  @Li_Four_NUMB   		  SMALLINT = 4;    
              
  SELECT Transaction_DATE,         
         Action_CODE,     
         Action_TEXT ,         
         Batch_DATE,     
   		 SourceBatch_CODE,     
    	 Batch_NUMB,     
   		 SeqReceipt_NUMB,     
         Case_IDNO ,         
         Reason_CODE ,         
         Transaction_AMNT,         
         Worker_ID ,         
          (        
            SELECT u.DescriptionNote_TEXT        
              FROM UNOT_Y1 u        
             WHERE u.EventGlobalSeq_NUMB = Z.EventGlobalSeq_NUMB      
            UNION   
            SELECT DescriptionNote_TEXT 
              FROM UNOT_Y1 a 
                   JOIN 
                   ELRP_Y1 b   
                   ON 
                   a.EventGlobalSeq_NUMB =  b.EventglobalRrepSeq_numb    
             WHERE b.EventGlobalBackoutSeq_NUMB = Z.EventGlobalSeq_NUMB   
     
          ) AS DescriptionNote_TEXT,         
         RowCount_NUMB        
    FROM (        
          SELECT Transaction_DATE,     
                 Action_CODE,         
                 Action_TEXT,         
                 Batch_DATE,     
     		     SourceBatch_CODE,     
     		     Batch_NUMB,     
     		     SeqReceipt_NUMB,    
                 Case_IDNO,         
                 Reason_CODE,         
                 Transaction_AMNT,         
                 Worker_ID,         
                 EventGlobalSeq_NUMB,         
                 Y.ORD_ROWNUM ,         
                 Y.RowCount_NUMB,         
                 RecoupmentPayee_CODE        
         FROM (        
               SELECT X.Transaction_DATE,      
                      X.Action_CODE,       
                      X.Action_TEXT,         
                      X.Batch_DATE,           
                      X.SourceBatch_CODE,     
                      X.Batch_NUMB,           
                      X.SeqReceipt_NUMB,      
                      X.Case_IDNO,         
                      X.Reason_CODE,         
                      X.Transaction_AMNT,         
                      X.Worker_ID,         
                      X.EventGlobalSeq_NUMB,         
                      X.RecoupmentPayee_CODE,         
                      COUNT(1) OVER() AS RowCount_NUMB,         
                      ROW_NUMBER() OVER(ORDER BY X.Transaction_DATE DESC, X.EventGlobalSeq_NUMB DESC, X.Batch_DATE DESC, X.SourceBatch_CODE DESC, X.Batch_NUMB DESC, X.SeqReceipt_NUMB DESC) AS ORD_ROWNUM        
                  FROM (        
                        SELECT l.Transaction_DATE ,         
                           ISNULL(        
                              CASE a.rn        
                                 WHEN @Li_One_NUMB THEN l.Transaction_CODE        
                                 WHEN @Li_Two_NUMB THEN @Lc_TransactionChpv_CODE        
                                 WHEN @Li_Three_NUMB THEN @Lc_TransactionChav_CODE        
                                 WHEN @Li_Four_NUMB THEN @Lc_TransactionBkrr_CODE        
                              END, @Lc_Space_TEXT) AS Action_CODE,    
                           ISNULL(dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('CREC', 'DESC',         
                              CASE a.rn        
                                 WHEN @Li_One_NUMB  THEN l.Transaction_CODE        
                                 WHEN @Li_Two_NUMB  THEN @Lc_TransactionChpv_CODE        
                                 WHEN @Li_Three_NUMB THEN @Lc_TransactionChav_CODE        
                                 WHEN @Li_Four_NUMB THEN @Lc_TransactionBkrr_CODE        
                              END), @Lc_Space_TEXT) AS Action_TEXT,         
                           l.Batch_DATE,     
                           l.SourceBatch_CODE,     
                           l.Batch_NUMB,     
                           l.SeqReceipt_NUMB,    
                           l.Case_IDNO ,         
                           l.Reason_CODE ,         
                           CASE a.rn        
                              WHEN @Li_One_NUMB THEN CASE         
                                 WHEN l.Transaction_CODE IN (         
                                    @Lc_TransactionBkpe_CODE,         
                                    @Lc_TransactionRdpe_CODE,         
                                    @Lc_TransactionInpe_CODE,         
                                    @Lc_TransactionRepe_CODE,         
                                    @Lc_TransactionChpv_CODE,         
                                    @Lc_TransactionConv_CODE ) THEN l.PendOffset_AMNT        
                                 WHEN l.Transaction_CODE IN (         
                                    @Lc_TransactionBkrc_CODE,         
                                    @Lc_TransactionRdrc_CODE,         
                                    @Lc_TransactionInrc_CODE,         
                                    @Lc_TransactionAppe_CODE,         
                                    @Lc_TransactionChav_CODE ) THEN l.AssessOverpay_AMNT        
                                 WHEN l.Transaction_CODE IN ( @Lc_TransactionSrec_CODE, @Lc_TransactionChsw_CODE, @Lc_TransactionChwp_CODE ) THEN l.RecOverpay_AMNT        
                              END        
                              WHEN @Li_Two_NUMB THEN l.PendOffset_AMNT        
                              WHEN @Li_Three_NUMB THEN l.AssessOverpay_AMNT        
                              WHEN @Li_Four_NUMB THEN l.RecOverpay_AMNT        
                           END AS Transaction_AMNT,         
                            g.Worker_ID ,         
                            l.EventGlobalSeq_NUMB ,         
                            l.RecoupmentPayee_CODE         
                      FROM POFL_Y1 l,
                           GLEV_Y1 g,
                           (        
                              SELECT @Li_One_NUMB AS rn        
                               UNION ALL        
                              SELECT @Li_Two_NUMB AS rn        
                               UNION ALL        
                              SELECT @Li_Three_NUMB AS rn        
                               UNION ALL        
                              SELECT @Li_Four_NUMB AS rn        
                           ) a        
                      WHERE l.EventGlobalSeq_NUMB = g.EventGlobalSeq_NUMB
                                
                        AND ( (	a.rn = @Li_One_NUMB
                        
                           	 	AND l.Transaction_CODE NOT IN (  @Lc_TransactionCmul_CODE ) 
                           	 	AND (( l.Transaction_CODE = @Lc_TransactionBkpe_CODE 
                           	 	         AND l.PendOffset_AMNT > @Li_Zero_NUMB ) 
                           	 	      OR (l.Transaction_CODE = @Lc_TransactionBkrc_CODE 
                           	 	         AND l.AssessOverpay_AMNT > @Li_Zero_NUMB) 
                           	 	      OR (l.Transaction_CODE NOT IN ( @Lc_TransactionBkpe_CODE, @Lc_TransactionBkrc_CODE ))
                           	 	    )
                           	   ) 
                           	     OR( a.rn = @Li_Two_NUMB 
                           	 	AND l.Transaction_CODE = @Lc_TransactionCmul_CODE 
                           	 	AND l.PendOffset_AMNT < @Li_Zero_NUMB )
                           	 	 
                           	     OR( a.rn = @Li_Three_NUMB 
                           	 	AND l.Transaction_CODE = @Lc_TransactionCmul_CODE 
                           	 	AND l.AssessOverpay_AMNT < @Li_Zero_NUMB ) 
                           	 	
                           	     OR( a.rn = @Li_Four_NUMB 
                           	 	AND l.Transaction_CODE IN ( @Lc_TransactionBkpe_CODE, @Lc_TransactionBkrc_CODE ) 
                           	 	AND l.RecOverpay_AMNT < @Li_Zero_NUMB )
                            ) 
                        AND l.CheckRecipient_ID = @Ac_CheckRecipient_ID     
                        AND l.CheckRecipient_CODE = @Ac_CheckRecipient_CODE     
                        AND l.Transaction_DATE BETWEEN ISNULL(@Ad_TransactionFrom_DATE, @Ld_Low_DATE) AND ISNULL(@Ad_TransactionTo_DATE, @Ld_Current_DATE)     
                        AND l.Case_IDNO = ISNULL(@An_Case_IDNO, l.Case_IDNO)     
                    ) X        
               )  Y       
            WHERE (Y.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
               OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)        
         )   Z        
   WHERE Z.ORD_ROWNUM >= @Ai_RowFrom_NUMB 
      OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB);        
                          
END;  --END OF POFL_RETRIEVE_S3 


GO
