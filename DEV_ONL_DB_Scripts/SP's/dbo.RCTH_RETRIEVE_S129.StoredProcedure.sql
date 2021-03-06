/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S129]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S129](
     @An_Case_IDNO		 NUMERIC(6,0), 
     @Ad_ReceiptFrom_DATE          DATE,  
     @Ad_ReceiptTo_DATE            DATE, 
     @Ac_SortOrder_TEXT              CHAR(1),     
     @Ac_SortBy_TEXT               CHAR(13), 
     @Ai_RowFrom_NUMB              INT=1       ,  
     @Ai_RowTo_NUMB                INT=10    
    )              
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S129  
 *     DESCRIPTION       : It Retrieves the Payment History Details.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
      
  
      DECLARE  
        
         @Lc_RelationshipCaseNcp_CODE       CHAR(1)      = 'A',   
         @Lc_RelationshipCasePutFather_CODE CHAR(1)      = 'P',   
         @Lc_StatusCaseMemberActive_CODE    CHAR(1)      = 'A',   
         @Lc_TypeRecordOriginal_CODE        CHAR(1)      = 'O',   
         @Ld_High_DATE                  DATE = '12/31/9999',   
         @Lc_IndBackOutYes_INDC             CHAR(1)      = 'Y',   
         @Li_ReceiptDistributed1820_NUMB     INT=1820 ,
         @Li_ManuallyDistributeReceipt1810_NUMB     INT=1810 ,
         @Li_ReceiptReversed1250_NUMB     INT=1250 ,
          @Ls_Select_TEXT                 VARCHAR(MAX),
          @Ls_Where_TEXT                  VARCHAR(MAX),
          @Ls_SelectOrder_TEXT			VARCHAR(MAX),
          @Ls_Order_TEXT                  VARCHAR(MAX),
          
          
        @Lc_SortTypeSeqrect_TEXT	CHAR(8)= 'SEQ_RECT',
        @Lc_SortOrderDtrect_CODE	CHAR(7)='DT_RECT',
		@Lc_SortOrderIdpayor_CODE	CHAR(8) ='ID_PAYOR',
		@Lc_SortOrderDtdistr_CODE	CHAR(13) ='DT_DISTRIBUTE',
		@Ls_SortSeqrctA_TEXT      VARCHAR(MAX) = ' ',
      @Ls_SortDtrctA_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortPayorA_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortTxndtA_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortSeqrctD_TEXT      VARCHAR(MAX) = ' ',
      @Ls_SortDtrctD_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortPayorD_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortTxndtD_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortDefuD_TEXT        VARCHAR(MAX) = ' ',
      @Ls_SortDefuA_TEXT        VARCHAR(MAX) = ' ',
		@Lc_StatusReceiptE_CODE   CHAR(1)='E', 
		@Lc_StatusReceiptH_CODE      CHAR(1)='H',
		@Lc_SortOrderD_CODE CHAR(1)='D',
      @Lc_SortOrderA_CODE CHAR(1)='A';
		
	  SET @Ls_SortDefuD_TEXT = ', a.Batch_DATE desc, a.SourceBatch_CODE desc, a.Batch_NUMB desc, a.SeqReceipt_NUMB desc, a.EventGlobalBeginSeq_NUMB DESC';
	  SET @Ls_SortDefuA_TEXT = ', a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.EventGlobalBeginSeq_NUMB';
	
		
	
	  SET @Ls_SortSeqrctA_TEXT       = ' ORDER BY a.Batch_DATE, a.Batch_NUMB, a.SeqReceipt_NUMB ';
      SET @Ls_SortDtrctA_TEXT        = ' ORDER BY a.Receipt_DATE ';
      SET @Ls_SortPayorA_TEXT        = ' ORDER BY a.PayorMCI_IDNO ';
      SET @Ls_SortTxndtA_TEXT        =
            ' ORDER BY CASE a.StatusReceipt_CODE WHEN
                                                                        '''
         + @Lc_StatusReceiptE_CODE   
         + ''' THEN a.BeginValidity_DATE WHEN 
                                                                        '''
         + @Lc_StatusReceiptH_CODE      
         + ''' THEN a.BeginValidity_DATE ELSE a.Distribute_DATE  END ';
         
      SET @Ls_SortSeqrctD_TEXT       = ' ORDER BY a.Batch_DATE DESC, a.Batch_NUMB DESC, a.SeqReceipt_NUMB DESC ';
      SET @Ls_SortDtrctD_TEXT        = ' ORDER BY a.Receipt_DATE DESC ';
      SET @Ls_SortPayorD_TEXT        = ' ORDER BY a.PayorMCI_IDNO DESC ';
      SET @Ls_SortTxndtD_TEXT        =
            ' ORDER BY CASE a.StatusReceipt_CODE WHEN 
                                                                        '''
         + @Lc_StatusReceiptE_CODE   
         + ''' THEN a.BeginValidity_DATE  WHEN 
                                                                        '''
         +@Lc_StatusReceiptH_CODE      
         + '''THEN a.BeginValidity_DATE ELSE a.Distribute_DATE END DESC  ';
         
         
          IF @Ac_SortBy_TEXT IS NOT NULL 
    BEGIN
         IF @Ac_SortBy_TEXT = @Lc_SortTypeSeqrect_TEXT   
          BEGIN
            IF @Ac_SortOrder_TEXT = @Lc_SortOrderD_CODE 
               BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortSeqrctD_TEXT +@Ls_SortDefuD_TEXT;
               END;
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
              BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortSeqrctA_TEXT +@Ls_SortDefuA_TEXT ;
              END; 
                  END;
                  
              ELSE IF @Ac_SortBy_TEXT = @Lc_SortOrderDtrect_CODE  
          BEGIN
            IF @Ac_SortOrder_TEXT = @Lc_SortOrderD_CODE 
              BEGIN
              SET  @Ls_Order_TEXT    = @Ls_SortDtrctD_TEXT+@Ls_SortDefuD_TEXT ;
              END; 
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
              BEGIN
              SET  @Ls_Order_TEXT    = @Ls_SortDtrctA_TEXT + @Ls_SortDefuA_TEXT;
              END; 
          END;
          
          ELSE IF @Ac_SortBy_TEXT = @Lc_SortOrderIdpayor_CODE 
         BEGIN
            IF @Ac_SortOrder_TEXT = @Lc_SortOrderD_CODE 
              BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortPayorD_TEXT +@Ls_SortDefuD_TEXT;
              END; 
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
              BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortPayorA_TEXT+@Ls_SortDefuA_TEXT ;
              END; 
         END;
             
             ELSE IF @Ac_SortBy_TEXT = @Lc_SortOrderDtdistr_CODE 
         BEGIN
            IF @Ac_SortOrder_TEXT = @Lc_SortOrderD_CODE 
             BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortTxndtD_TEXT +@Ls_SortDefuD_TEXT ;
             END;  
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
            BEGIN 
              SET  @Ls_Order_TEXT    = @Ls_SortTxndtA_TEXT + @Ls_SortDefuA_TEXT;
            END;
        END;     
              
         
             END;
           
         
         
   SET @Ls_Select_TEXT=      
      'SELECT 
       Y.Batch_DATE, 
       Y.SourceBatch_CODE,
        Y.Batch_NUMB, 
        Y.SeqReceipt_NUMB,      
         Y.Receipt_DATE,   
         Y.SourceBatch_CODE,   
         Y.SourceReceipt_CODE,   
         Y.PayorMCI_IDNO,   
         Y.Case_IDNO,   
         Y.Fips_CODE,
         
         (  
                           SELECT  TOP 1   
                              z.ReasonBackOut_CODE 
                           FROM RCTH_Y1 z  
                           WHERE   
                              z.Batch_DATE = Y.Batch_DATE AND   
                              z.SourceBatch_CODE = Y.SourceBatch_CODE AND   
                              z.Batch_NUMB = Y.Batch_NUMB AND   
                              z.SeqReceipt_NUMB = Y.SeqReceipt_NUMB AND   
                              z.BackOut_INDC ='''+ @Lc_IndBackOutYes_INDC+''' AND   
                              z.EndValidity_DATE = '''+CONVERT(VARCHAR,@Ld_High_DATE)+'''  
          ) AS ReasonBackOut_CODE,
         Y.ReasonStatus_CODE,
         Y.CheckNo_Text,   
         Y.Receipt_AMNT,
         dbo.BATCH_COMMON$SF_AMT_DISTRIBUTE(  
                           '+CONVERT(VARCHAR,@An_Case_IDNO)+',   
                           Y.Batch_DATE,   
                           Y.SourceBatch_CODE,   
                           Y.Batch_NUMB,   
                           Y.SeqReceipt_NUMB,   
                           Y.BackOut_INDC,   
                           Y.EventGlobalBeginSeq_NUMB 
                          )  AS Distribute_AMNT,
         Y.ToDistribute_AMNT,
         dbo.BATCH_COMMON$SF_RECEIPT_STATUS(  
                        Y.Batch_DATE,   
                        Y.SourceBatch_CODE,   
                        Y.Batch_NUMB,   
                        Y.SeqReceipt_NUMB,
                        Y.StatusReceipt_CODE,   
                        Y.Receipt_AMNT 
                        
                        ) AS DistStatus_CODE,
                        
         Y.StatusReceipt_CODE,
          Y.Distribute_DATE ,
          Y.BeginValidity_DATE ,
          Y.TypePosting_CODE,
          Y.TypeRemittance_CODE,
          Y.ReferenceIrs_IDNO,
        Y.Rapid_IDNO,
        Y.RapidEnvelope_NUMB,
        Y.RapidReceipt_NUMB ,
        Y.PaidBy_NAME,
        Y.PaidBy_ID, 
        Y.RowCount_NUMB  
      FROM   
         (  
            SELECT  
               X.Receipt_DATE,
               X.Batch_DATE,   
               X.SourceBatch_CODE,
               X.Batch_NUMB,
               X.SeqReceipt_NUMB,   
               X.SourceReceipt_CODE,   
               X.PayorMCI_IDNO,   
               X.Case_IDNO,   
               X.Fips_CODE,
               X.StatusReceipt_CODE,
               X.BeginValidity_DATE,
               X.ReasonStatus_CODE,   
               X.CheckNo_Text,
               X.BackOut_INDC,
               X.EventGlobalBeginSeq_NUMB,   
               X.Receipt_AMNT,   
               X.ToDistribute_AMNT,   
               X.Distribute_DATE,   
               X.TypePosting_CODE,   
               X.TypeRemittance_CODE,
               X.ReferenceIrs_IDNO,
               R.Rapid_IDNO,
               R.RapidEnvelope_NUMB,
               R.RapidReceipt_NUMB ,
               R.PaidBy_NAME,
               R.PaidBy_ID,   
               X.RowCount_NUMB,   
               X.ORD_ROWNUM 
            FROM   
               (  
                  SELECT 
                     a.Receipt_DATE, 
                     a.Batch_DATE, 
                     a.SourceBatch_CODE, 
                     a.Batch_NUMB,
                     a.SeqReceipt_NUMB,  
                     a.SourceReceipt_CODE,   
                     a.PayorMCI_IDNO,   
                     a.Case_IDNO,   
                     a.Fips_CODE,
                     a.StatusReceipt_CODE,
                     a.ReasonStatus_CODE,
                     a.CheckNo_Text,   
                     a.Receipt_AMNT,   
                     a.BackOut_INDC, 
                     a.EventGlobalBeginSeq_NUMB,
                     a.Distribute_DATE,
                     a.ToDistribute_AMNT,
                     a.BeginValidity_DATE, 
                     a.TypePosting_CODE,   
                     a.TypeRemittance_CODE,
                     a.ReferenceIrs_IDNO,';
                     
         SET   @Ls_SelectOrder_TEXT = '         
                     
                     COUNT(1) OVER() AS RowCount_NUMB,   
                     ROW_NUMBER() OVER( '+@Ls_Order_TEXT+' 
                       
                        ) AS ORD_ROWNUM  ';
                 
         SET   @Ls_Where_TEXT  =
         '
                  FROM RCTH_Y1 a  
                  WHERE   
                     a.EndValidity_DATE = '''+CONVERT(VARCHAR,@Ld_High_DATE)+''' AND   
                     a.Receipt_DATE BETWEEN '''+CONVERT(VARCHAR,@Ad_ReceiptFrom_DATE)+''' AND '''+ CONVERT(VARCHAR,@Ad_ReceiptTo_DATE )+'''AND   
                     a.PayorMCI_IDNO IN   
                     (  
                        SELECT C.MemberMci_IDNO  
                        FROM CMEM_Y1 C  
                        WHERE   
                           C.Case_IDNO = '''+CONVERT(VARCHAR,@An_Case_IDNO)+''' AND   
                           C.CaseRelationship_CODE IN ('''+@Lc_RelationshipCaseNcp_CODE+''','''+@Lc_RelationshipCasePutFather_CODE+''') AND   
                           C.CaseMemberStatus_CODE = '''+@Lc_StatusCaseMemberActive_CODE+'''  
                     )  
               )  AS X  LEFT OUTER JOIN RSDU_Y1 R  
                           ON(X.Batch_DATE=R.Batch_DATE AND
                              X.SourceBatch_CODE=R.SourceBatch_CODE AND
                              X.Batch_NUMB=R.Batch_NUMB AND
                              X.SeqReceipt_NUMB=R.SeqReceipt_NUMB) 
            WHERE X.ORD_ROWNUM <= '''+CONVERT(VARCHAR,@Ai_RowTo_NUMB)+'''  
         )  AS Y  
      WHERE Y.ORD_ROWNUM >= '''+CONVERT(VARCHAR,@Ai_RowFrom_NUMB)+'''  
ORDER BY ORD_ROWNUM; ' ;
EXEC ( @Ls_Select_TEXT +' '+ @Ls_SelectOrder_TEXT+' '+@Ls_Where_TEXT);
print @Ls_Select_TEXT +' '+ @Ls_SelectOrder_TEXT+' '+@Ls_Where_TEXT;
  
END; --End of RCTH_RETRIEVE_S129   
  

GO
