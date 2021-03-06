/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S153]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S153] (                                                                                                
       @Ac_ReasonStatus_CODE         CHAR(4),
       @Ac_RefundRecipient_CODE      CHAR(1),                                                                     
       @Ad_From_DATE     			 DATE	,                                                                            
       @Ad_To_DATE      			 DATE	,                                                                           
       @Ac_SortOrder_TEXT            CHAR(1),                                                                                           
       @Ac_SortBy_TEXT             CHAR(7),                                                                 
       @Ai_RowFrom_NUMB              INT =1 ,                                                                                         
       @Ai_RowTo_NUMB                INT =10
    )                                                                                                                                     
  AS            
/*          
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S153          
 *     DESCRIPTION       : Retrieve Receipt details for a Case Id in a Descending Order of Release Date.          
 *     DEVELOPED BY      : IMP TEAM          
 *     DEVELOPED ON      : 22-SEP-2011          
 *     MODIFIED BY       :           
 *     MODIFIED ON       :           
 *     VERSION NO        : 1          
 */           
  BEGIN          
  DECLARE                                                                                                                              
       @Ld_From_DATE     							DATE        ,                                                                                                     
       @Ld_To_DATE       							DATE        ,                                                                                                    
       @Ls_OuterSelect_TEXT    						VARCHAR(MAX),                                                                                        
       @Ls_SelectRcth_TEXT    						VARCHAR (MAX),                                                                                       
       @Ls_WhereRcth_TEXT     						VARCHAR (MAX)='',                                                                                        
       @Ls_WhereBatch_DATE    						VARCHAR (MAX),                                                                                        
       @Ls_WhereRownum_TEXT    						VARCHAR (MAX),                                                                                          
       @Ls_Order_TEXT     	 						VARCHAR (MAX),                                                        
       @Ls_SortDateBegvA_TEXT    					VARCHAR (MAX),                                                        
       @Ls_SortDateBegvD_TEXT    					VARCHAR (MAX),                                                        
       @Ls_SortIdWrkrA_TEXT     					VARCHAR (MAX),                                                        
       @Ls_SortIdWrkrD_TEXT     					VARCHAR (MAX),           
       @Ls_Query_TEXT     							VARCHAR(MAX),          
       @Lc_ReasonStatusSNRP_CODE  					CHAR(4) ='SNRP',          
       @Lc_ReasonStatusUSRP_CODE  					CHAR(4) ='USRP',          
       @Lc_StatusReceiptUnidentified_CODE   		CHAR(1) ='U',          
       @Lc_StatusReceiptHeld_CODE   				CHAR(1) ='H',                 
       @Ld_Low_DATE      							DATE    ='01/01/0001',          
       @Ld_High_DATE     							DATE    ='12/31/9999',
       @Lc_SortOrderAscending_TEXT					CHAR(1) ='A',
       @Lc_SortOrderDescending_TEXT					CHAR(1) ='D',
       @Lc_SortTypeBeginv_TEXT						CHAR(7) ='DT_BEGV',
       @Lc_SortTypeWorkerId_TEXT        			CHAR(7) ='ID_WRKR';
                                                  
       SET @Ls_SortDateBegvA_TEXT = ' ORDER BY r.BeginValidity_DATE ASC ';                                                                             
       SET @Ls_SortIdWrkrA_TEXT = ' ORDER BY g.Worker_ID ASC ';                                                                                   
       SET @Ls_SortDateBegvD_TEXT = ' ORDER BY r.BeginValidity_DATE DESC ';                                                                            
       SET @Ls_SortIdWrkrD_TEXT = ' ORDER BY g.Worker_ID DESC ';                                                                                  
                                                                                                                                          
       IF @Ac_SortBy_TEXT IS NOT NULL                                                                                                        
       BEGIN                                                                                                                               
          IF @Ac_SortBy_TEXT = @Lc_SortTypeBeginv_TEXT                                                                                                    
          BEGIN                                                                                                                            
             IF @Ac_SortOrder_TEXT = @Lc_SortOrderDescending_TEXT                                                                                               
             BEGIN                                                                                                                         
               SET @Ls_Order_TEXT = @Ls_SortDateBegvD_TEXT;           
               END                                                                                           
             ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderAscending_TEXT                                                                                            
             BEGIN                                                                                                                         
              SET  @Ls_Order_TEXT = @Ls_SortDateBegvA_TEXT;                                                                                            
             END   
             END;                                                                                                                      
          ELSE IF @Ac_SortBy_TEXT = @Lc_SortTypeWorkerId_TEXT                                                                                                  
          BEGIN                                                                                                                            
             IF @Ac_SortOrder_TEXT = @Lc_SortOrderDescending_TEXT                                                                                                
             BEGIN                                                                   
               SET @Ls_Order_TEXT = @Ls_SortIdWrkrD_TEXT;           
               END                                                                                           
             ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderAscending_TEXT                                                               
             BEGIN                                                                                                                         
                SET @Ls_Order_TEXT = @Ls_SortIdWrkrA_TEXT;                                                                                            
             END ;                                                                                                                      
          END ;                                                                                                                         
                                                                                                                                          
          SET @Ls_Order_TEXT =                                                                                            
                @Ls_Order_TEXT                                                             
             + ', Batch_DATE,SourceBatch_CODE,Batch_NUMB,SeqReceipt_NUMB,EventGlobalBeginSeq_NUMB ';             
             END                                               
       ELSE     
       BEGIN                                                                                                                            
         SET @Ls_Order_TEXT =                                                                                                                     
             ' ORDER BY r.BeginValidity_DATE DESC, Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, EventGlobalBeginSeq_NUMB ';                   
       END ;              
 
   SET @Ls_OuterSelect_TEXT = 'SELECT           
    	  X.Batch_DATE,                                    
          X.SourceBatch_CODE,          
          X.Batch_NUMB,          
          X.SeqReceipt_NUMB,                                                                             
          X.ReasonStatus_CODE,          
          X.BeginValidity_DATE,
          X.RefundRecipient_CODE,                                                                                          
          X.RefundRecipient_ID,          
          X.ToDistribute_AMNT,                                                                                     
          X.DescriptionNote_TEXT,          
          X.Worker_ID, 
		  X.EventGlobalBeginSeq_NUMB,         
          dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(X.RefundRecipient_ID,X.RefundRecipient_CODE)AS Recipient_name,                           
          X.RowCount_NUMB                                                                                                                  
          FROM           
   (SELECT Z.Batch_DATE,          
    Z.SourceBatch_CODE,          
    Z.Batch_NUMB,          
    Z.SeqReceipt_NUMB,          
    Z.ReasonStatus_CODE,          
    Z.BeginValidity_DATE,          
    Z.RefundRecipient_CODE,           
    Z.RefundRecipient_ID,          
    Z.ToDistribute_AMNT,                                                                                     
    Z.DescriptionNote_TEXT,          
    Z.Worker_ID,
	Z.EventGlobalBeginSeq_NUMB,           
    Z.RowCount_NUMB,           
    Z.ROWNUM                                                                  
           FROM           
           (SELECT           
             Y.Batch_DATE,          
             Y.SourceBatch_CODE,          
             Y.Batch_NUMB,          
             Y.SeqReceipt_NUMB,           
             Y.ReasonStatus_CODE,           
             Y.BeginValidity_DATE,                            
             Y.RefundRecipient_CODE,           
             Y.RefundRecipient_ID,           
             Y.ToDistribute_AMNT,                                                                           
             Y.DescriptionNote_TEXT,           
             Y.Worker_ID,           
             Y.EventGlobalBeginSeq_NUMB,
			 Y.ROWNUM,                                                                            
			 Y.RowCount_NUMB                                                                                              
          FROM ( ';                                                                                                                   
         SET  @Ls_SelectRcth_TEXT =            
        'SELECT r.Batch_DATE,          
        r.SourceBatch_CODE,          
        r.Batch_NUMB,          
        r.SeqReceipt_NUMB,                                                                      
        r.ReasonStatus_CODE,          
        r.BeginValidity_DATE,          
        r.RefundRecipient_CODE,                                                                   
        r.RefundRecipient_ID,
        r.ToDistribute_AMNT,                                                                                     
        s.DescriptionNote_TEXT,
        g.Worker_ID, 
        r.EventGlobalBeginSeq_NUMB,       
        ROW_NUMBER() OVER ('+@Ls_Order_TEXT+' )ROWNUM  ,                                                               
        COUNT(1) OVER() AS RowCount_NUMB                                                                                                  
        FROM           
          RCTH_Y1 r,           
          UNOT_Y1 s,           
          GLEV_Y1 g,           
          (SELECT DISTINCT Worker_ID 
		     FROM UASM_Y1 
			WHERE EndValidity_DATE = '''+ CONVERT(VARCHAR, @Ld_High_DATE)+''')u                                                                                   
        WHERE s.EventGlobalSeq_NUMB  = r.EventGlobalBeginSeq_NUMB                                                                       
        AND g.EventGlobalSeq_NUMB = r.EventGlobalBeginSeq_NUMB                    
        AND u.Worker_ID = g.Worker_ID                                                                                             
        AND r.StatusReceipt_CODE IN ( '''+ @Lc_StatusReceiptHeld_CODE + ''',          
        ''' +@Lc_StatusReceiptUnidentified_CODE +''')                                                                                                                        
        AND r.Distribute_DATE = '''+ CONVERT(VARCHAR, @Ld_Low_DATE)+'''                                                                                                  
        AND r.EndValidity_DATE = '''+ CONVERT(VARCHAR, @Ld_High_DATE)+'''';                                                                                                                        
                                                                                                                                          
       IF @Ad_From_DATE IS NOT NULL AND @Ad_To_DATE IS NOT NULL                                                                       
       BEGIN                                                                                                                               
         SET @Ld_From_DATE = @Ad_From_DATE;                                                                                                  
         SET @Ld_To_DATE = @Ad_To_DATE;                                                                                                      
         SET @Ls_WhereBatch_DATE =                                                                                                            
                'AND r.BeginValidity_DATE BETWEEN ''' + CONVERT(VARCHAR,@Ld_From_DATE) +                                                           
              ''' AND '''  +                                                                                                             
            CONVERT (VARCHAR, @Ld_To_DATE) +                                                            
             '''';                                                                                                                     
       END ;                                                              
                                                                                                                                          
       IF @Ac_ReasonStatus_CODE IS NOT NULL     
  		BEGIN          
         SET @Ls_WhereRcth_TEXT =                                                                                                                
                @Ls_WhereRcth_TEXT  +                                                                                                           
              ' AND r.ReasonStatus_CODE = ''' + @Ac_ReasonStatus_CODE +                                                                                         
              '''' ; 
        END                                                                                                                    
       ELSE            
       BEGIN                                                                                                                             
          SET @Ls_WhereRcth_TEXT =                                                                                                                
                @Ls_WhereRcth_TEXT  +                                                                                                           
              ' AND r.ReasonStatus_CODE IN (''' +                                                                                         
             @Lc_ReasonStatusSNRP_CODE  +''',           
             ''' + @Lc_ReasonStatusUSRP_CODE  + ''')';                                                                                                                    
       END ;                                                                                                                            
                                          
       IF @Ad_From_DATE IS NOT NULL AND @Ad_To_DATE IS NOT NULL                                                                       
       BEGIN                              
        SET  @Ls_WhereRcth_TEXT = @Ls_WhereRcth_TEXT + @Ls_WhereBatch_DATE;                                                                            
       END ;                                                                                                                            
                                                                                                                                  
       IF @Ac_RefundRecipient_CODE IS NOT NULL                                                                                              
        BEGIN                                                                                                                               
  			SET @Ls_WhereRcth_TEXT =                                                                                                             
                   @Ls_WhereRcth_TEXT  +                                                                                                        
                ' AND r.RefundRecipient_CODE = '''                                                                                      
               + @Ac_RefundRecipient_CODE                                                                                                 
                + '''';                                                                                                                  
        END;                                                                                                                            
             SET @Ls_WhereRcth_TEXT = @Ls_WhereRcth_TEXT + ' )';  
                                       
   	  SET @Ls_WhereRownum_TEXT =                                                                                                                 
        ' Y WHERE ROWNUM <= ' + CONVERT(VARCHAR, @Ai_RowTo_NUMB) + ' OR ' + CONVERT(VARCHAR,@Ai_RowFrom_NUMB )          
        + '= 0 )Z '                                                           
          + 'WHERE ( ROWNUM >=' + CONVERT(VARCHAR,@Ai_RowFrom_NUMB) + ') OR ( ' + CONVERT(VARCHAR,@Ai_RowFrom_NUMB) +' = 0))X '
		  + 'ORDER BY ROWNUM';                                                  
                                                                                                                                          
      SET @Ls_Query_TEXT =    @Ls_OuterSelect_TEXT           
                                       + @Ls_SelectRcth_TEXT           
                                      + @Ls_WhereRcth_TEXT                                                                                    
                                       + @Ls_WhereRownum_TEXT;                                                                                  
      EXEC (@Ls_Query_TEXT);          

END	-- End of RCTH_RETRIEVE_S153
  

GO
