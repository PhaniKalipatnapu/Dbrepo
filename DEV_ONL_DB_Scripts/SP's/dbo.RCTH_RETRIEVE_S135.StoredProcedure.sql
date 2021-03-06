/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S135]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S135]( 
     @An_Case_IDNO		 NUMERIC(6,0),     
     @An_PayorMCI_IDNO		 NUMERIC(10,0),    
     @Ad_ReceiptFrom_DATE          DATE,      
     @Ad_ReceiptTo_DATE            DATE,    
     @Ac_ReasonStatus_CODE         CHAR(4)  ,      
     @An_County_IDNO		 NUMERIC(3,0),     
     @Ai_RowFrom_NUMB              INT=1       ,      
     @Ai_RowTo_NUMB                INT=10                                  
   )                                                                                                 
 AS                                  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S135 
 *     DESCRIPTION       : It Retrieve the escheatable receipts.The records from the URCT with the status of PE will be selected. Further filter will be applied with the payor Id, Case Id,
                           County and UDC Code
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/     
                                                                                                     
BEGIN                                                       
   DECLARE      
      @Lc_StatusReceiptU_CODE CHAR(1)     ='U',       
      @Ld_High_DATE                  CHAR(10) ='12/31/9999',
      @Li_Zero_NUMB				     INT=0,   
      @Lc_ReasonSdna_CODE            CHAR(4)  ='SDNA',
      @Lc_ReasonSdpe_CODE            CHAR(4)  ='SDPE',
      @Lc_ReasonUmdf_CODE            CHAR(4)  ='UMDF',
      
	  @Lc_ReasonUmpe_CODE			 CHAR(4)  ='UMPE',
	  @Lc_ReasonUspe_CODE			 CHAR(4)  ='USPE',
	  @Lc_ReasonUsrp_CODE			 CHAR(4)  ='USRP',
      @Ld_From_DATE                   CHAR(10),                                                                             
      @Ld_To_DATE                     CHAR(10),                                        
      @Ld_Prev60month_CODE               CHAR(10),                                           
      @Ls_OuterSelect_TEXT              VARCHAR(MAX),                                                 
      @Ls_SelectRcth_TEXT               VARCHAR(MAX),                                                
      @Ls_SelectRcth1_TEXT              VARCHAR(MAX),                                                
      @Ls_WhereRcth_TEXT                VARCHAR(MAX)=' ',                                                 
      @Ls_SelectDhld_TEXT               VARCHAR(MAX),                                                 
      @Ls_SelectDhld1_TEXT              VARCHAR(MAX),                                                
      @Ls_WhereDhld_TEXT                VARCHAR(MAX)=' ',                                                
      @Ls_OrderBy_TEXT                  VARCHAR(MAX),                                                   
      @Ls_WhereRownum_TEXT              VARCHAR(MAX);
    
            
     SET @Ls_OuterSelect_TEXT=                                                                            
         '        SELECT 
                   F.Batch_DATE, F.SourceBatch_CODE, F.Batch_NUMB, F.SeqReceipt_NUMB, '+ 
                 'F.Receipt_DATE, 
                  F.Receipt_AMNT, 
                  F.PayorMCI_IDNO,  '+                                            
                 'dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME(F.PayorMCI_IDNO) AS PayorName_TEXT, '+               
                 'F.Case_IDNO, 
                  F.County_IDNO, 
                  F.StatusReceipt_CODE, 
                  F.ReasonStatus_CODE, 
                  F.BeginValidity_DATE, '+                      
                 'F.ToDistribute_AMNT, 
                  F.RowCount_NUMB  '+                                                    
           '
           FROM (SELECT 
                         Z.Receipt_DATE, 
                         Z.Receipt_AMNT, 
                         Z.PayorMCI_IDNO, 
                         Z.Case_IDNO, 
                         Z.County_IDNO, '+                
                        'Z.StatusReceipt_CODE, 
                         Z.ReasonStatus_CODE, 
                         Z.BeginValidity_DATE, 
                         Z.ToDistribute_AMNT, '+                    
                        'Z.SourceBatch_CODE, 
                         Z.Batch_NUMB, 
                         Z.SeqReceipt_NUMB,
                         Z.Batch_DATE, '+                        
                        'Z.ORD_ROWNUM,Z.RowCount_NUMB  '+                                              
                   '
           FROM (SELECT 
                                 G.Receipt_DATE, 
                                 G.Receipt_AMNT, 
                                 G.PayorMCI_IDNO, '+                              
                                'G.Case_IDNO, 
                                 G.County_IDNO, 
                                 G.StatusReceipt_CODE, 
                                 G.ReasonStatus_CODE, '+                         
                                'G.BeginValidity_DATE, 
                                 G.ToDistribute_AMNT, 
                                 G.SourceBatch_CODE, 
                                 G.Batch_NUMB, '+   
                                'G.SeqReceipt_NUMB,Batch_DATE, 
                                 COUNT(1) OVER() AS RowCount_NUMB ,
                                 ROW_NUMBER() OVER(      
                        ORDER BY       
                           G.Receipt_DATE,       
                           G.Batch_DATE,       
                           G.SourceBatch_CODE,       
                           G.Batch_NUMB,       
                           G.SeqReceipt_NUMB,       
                           G.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM '
                           + ' 
           FROM ( ';                                                                 
                  
   SET @Ls_SelectRcth1_TEXT ='
                          h.Receipt_DATE, 
                          h.Receipt_AMNT, 
                          h.PayorMCI_IDNO, 
                          h.Case_IDNO, '+                  
                          'CONVERT(CHAR, c.County_IDNO) AS County_IDNO, 
                          h.StatusReceipt_CODE , '+             
                         'h.ReasonStatus_CODE, 
                          h.BeginValidity_DATE, '+         
                         'h.ToDistribute_AMNT , 
                          h.EventGlobalBeginSeq_NUMB,  '+            
                         'h.SourceBatch_CODE, 
                          h.Batch_NUMB, 
                          h.SeqReceipt_NUMB, 
                          h.Batch_DATE '+                 
                  'FROM URCT_Y1 x LEFT OUTER JOIN CASE_Y1 c ON(c.Case_IDNO = x.CaseIdent_IDNO) 
                  JOIN  RCTH_Y1 h  ON '+  
                  '
                    x.Batch_DATE = h.Batch_DATE '+                                                  
                   '
                   AND x.SourceBatch_CODE = h.SourceBatch_CODE '+                                    
                   '
                   AND x.Batch_NUMB = h.Batch_NUMB '+                                                  
                   '
                   AND x.SeqReceipt_NUMB = h.SeqReceipt_NUMB '+ 
                                                                         
                 '
                 WHERE x.IdentificationStatus_CODE = '''+                                              
                           @Lc_StatusReceiptU_CODE+''' ' +                   
                                                              
                   '
                   AND x.EndValidity_DATE = '''+@Ld_High_DATE+''' ' +                
                   '
                   AND h.EndValidity_DATE = '''+@Ld_High_DATE+''' ' +  
                   '
                   AND h.ReasonStatus_CODE IN ('''+@Lc_ReasonUmdf_CODE+''','''+@Lc_ReasonUmpe_CODE+''' ,'''+@Lc_ReasonUspe_CODE+''' ,'''+@Lc_ReasonUsrp_CODE+''')' ; 
    SET @Ls_SelectDhld1_TEXT =' 
                            r.Receipt_DATE, 
                            r.Receipt_AMNT, 
                            r.PayorMCI_IDNO,  '+                             
                           'b.Case_IDNO,  
                           CONVERT(CHAR, c.County_IDNO) AS County_IDNO,
                            b.Status_CODE,  '+                       
                           'b.ReasonStatus_CODE , 
                            b.Transaction_DATE , '+                  
                           'b.Transaction_AMNT , 
                            r.EventGlobalBeginSeq_NUMB,  '+                      
                           'r.SourceBatch_CODE, 
                            r.Batch_NUMB, 
                            r.SeqReceipt_NUMB, 
                            r.Batch_DATE  '+                        
          '
          FROM  DHLD_Y1 b LEFT OUTER JOIN CASE_Y1 c ON(b.Case_IDNO = c.Case_IDNO) 
          JOIN 
          RCTH_Y1 r
          ON '+ 
          '
            b.Batch_DATE = r.Batch_DATE '+                                                          
           '
           AND b.SourceBatch_CODE = r.SourceBatch_CODE '+                                            
           '
           AND b.Batch_NUMB = r.Batch_NUMB '+                                                          
           '
           AND b.SeqReceipt_NUMB = r.SeqReceipt_NUMB '+                                                       
         '
         WHERE 
            b.ReasonStatus_CODE IN ('''+@Lc_ReasonSdpe_CODE+''')'+                                 
           '
           AND b.EndValidity_DATE = '''+@Ld_High_DATE+''' ' +                                          
                                                             
           '
           AND r.EndValidity_DATE ='''+@Ld_High_DATE+''' ' +                        
           '
           AND r.EventGlobalBeginSeq_NUMB = '+                                                         
                  '(SELECT MAX(c.EventGlobalBeginSeq_NUMB) '+                                           
                     '
                                            FROM RCTH_Y1 c '+                                                               
                    '
                                          WHERE c.Batch_DATE = r.Batch_DATE '+                                               
                      '
                                            AND c.SourceBatch_CODE = r.SourceBatch_CODE '+                                 
                      '
                                            AND c.Batch_NUMB = r.Batch_NUMB '+                                               
                      '
                                            AND c.SeqReceipt_NUMB = r.SeqReceipt_NUMB '+                                         
                      '
                                            AND c.EndValidity_DATE = '''+@Ld_High_DATE+''' ) ';              
                                                                                                     
                                                                                                              
       IF @Ad_ReceiptFrom_DATE IS NOT NULL AND @Ad_ReceiptTo_DATE IS NOT NULL  
       BEGIN                                                                                             
     SET @Ls_WhereRcth_TEXT = 'AND h.Receipt_DATE BETWEEN '''+CONVERT (VARCHAR(10), @Ad_ReceiptFrom_DATE, 101)+''' AND '''+CONVERT (VARCHAR(10),  @Ad_ReceiptTo_DATE, 101)+''' ';                 
                                                                
                                                                                                     
     SET @Ls_WhereDhld_TEXT = 'AND r.Receipt_DATE BETWEEN '''+CONVERT (VARCHAR(10), @Ad_ReceiptFrom_DATE, 101)+''' AND '''+CONVERT (VARCHAR(10),  @Ad_ReceiptTo_DATE, 101)+''' ';                
       END                                     
       
        
          SET  @Ls_SelectRcth_TEXT  =' 
                  SELECT ';                                                          
          SET @Ls_SelectDhld_TEXT  =' 
                  SELECT ';                                        
                                                                                                     
     IF   @Ac_ReasonStatus_CODE IS NOT NULL   
      BEGIN                                                        
        SET @Ls_WhereRcth_TEXT =  @Ls_WhereRcth_TEXT + ' 
          AND h.ReasonStatus_CODE = '''+@Ac_ReasonStatus_CODE +''''; 
        SET @Ls_WhereDhld_TEXT =  @Ls_WhereDhld_TEXT + ' 
          AND b.ReasonStatus_CODE = '''+@Ac_ReasonStatus_CODE +''''; 
      END                                                                                    
                                                                                                     
    IF @An_County_IDNO IS NOT NULL 
     BEGIN                                                          
       SET @Ls_WhereRcth_TEXT =  @Ls_WhereRcth_TEXT + ' 
          AND c.County_IDNO = '''+CAST(@An_County_IDNO AS VARCHAR)+'''';
       SET @Ls_WhereDhld_TEXT =  @Ls_WhereDhld_TEXT + ' 
          AND c.County_IDNO  = '''+CAST(@An_County_IDNO AS VARCHAR)+'''';       
      END                                                                                   
                                                                                                     
    IF @An_Case_IDNO IS NOT NULL                     
             
     BEGIN                                                          
        SET @Ls_WhereRcth_TEXT =  @Ls_WhereRcth_TEXT + ' 
          AND h.Case_IDNO = '''+CAST(@An_Case_IDNO AS VARCHAR)+'''';            
        SET @Ls_WhereDhld_TEXT =  @Ls_WhereDhld_TEXT + ' 
          AND b.Case_IDNO = '''+CAST(@An_Case_IDNO AS VARCHAR)+'''';            
     END                                                                                     
                                                                                                     
  IF   @An_PayorMCI_IDNO IS NOT NULL  
    BEGIN                        
                                                                   
       SET @Ls_WhereRcth_TEXT =  @Ls_WhereRcth_TEXT + ' 
          AND h.PayorMCI_IDNO = '''+CAST(@An_PayorMCI_IDNO AS VARCHAR) +'''';         
       SET @Ls_WhereDhld_TEXT =  @Ls_WhereDhld_TEXT + ' 
          AND r.PayorMCI_IDNO = '''+CAST(@An_PayorMCI_IDNO AS VARCHAR) +'''';         
    END                                                                                   
                                                                                                     
         SET @Ls_OrderBy_TEXT     = ' )AS G
          ) AS Z ';                             
         SET @Ls_WhereRownum_TEXT = ' 
    WHERE ORD_ROWNUM <= '+CONVERT(VARCHAR(10),@Ai_RowTo_NUMB,101)+ ' OR '+ CONVERT(VARCHAR,@Ai_RowFrom_NUMB)+ '= '+CONVERT(VARCHAR,@Li_Zero_NUMB)+')  AS F 
WHERE ORD_ROWNUM >= '+CONVERT(VARCHAR(10),@Ai_RowFrom_NUMB,101)+ ' OR '+ CONVERT(VARCHAR,@Ai_RowFrom_NUMB)+ '= '+CONVERT(VARCHAR,@Li_Zero_NUMB);               
                                                                                              
      EXECUTE(@Ls_OuterSelect_TEXT +' '+                                                                
              @Ls_SelectRcth_TEXT  +' '+                                                                
              @Ls_SelectRcth1_TEXT +' '+                                                                
              @Ls_WhereRcth_TEXT   +                                                                     
              '
              UNION ALL '+                                                                         
              @Ls_SelectDhld_TEXT  +' '+                                                                
              @Ls_SelectDhld1_TEXT +' '+                                                                
              @Ls_WhereDhld_TEXT   +' '+                                                                
              @Ls_OrderBy_TEXT     +' '+                                                                
              @Ls_WhereRownum_TEXT ); 
   
      
                   
END; --End of RCTH_RETRIEVE_S135                                                          
                                                                                                     

GO
