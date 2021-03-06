/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S157]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S157](
      @Ad_Batch_DATE		DATE,
      @Ac_SourceBatch_CODE		 CHAR(3),  
      @An_Batch_NUMB             NUMERIC(4,0),
      @An_SeqReceipt_NUMB		 NUMERIC(6,0),  
      @Ac_SourceReceipt_CODE		 CHAR(2),     
      @Ac_TypeRemittance_CODE		 CHAR(3), 
      @An_Case_IDNO		 NUMERIC(6,0),   
      @An_PayorMCI_IDNO		 NUMERIC(10,0), 
      @Ac_CheckNo_TEXT		 CHAR(18), 
      @Ad_ReceiptFrom_DATE       DATE,
      @Ad_ReceiptTo_DATE         DATE,
      @Ac_StatusReceipt_CODE CHAR(2) , 
      @Ac_ReasonStatus_CODE      CHAR(4), 
      @Ac_SourceBatchIn_CODE     CHAR(3),
      @Ac_SortOrder_TEXT              CHAR(1),     
      @Ac_SortBy_TEXT               CHAR(13), 
      @Ai_RowFrom_NUMB           INT=1,
      @Ai_RowTo_NUMB             INT=10  
   )
   AS 
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S157 
 *     DESCRIPTION       :It Retrieve the all identified/held/unidentified receipts AND it gives further more details as to whether the receipt is fully distributed,
                          partially distributed, fully held, partially held, released to an other party,refunded to NCP etc. The worker can filter the receipts by date range, NCP DCN,
                          Case ID, Status, Receipt Number, or Check Number.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/     
   
BEGIN   

 

   DECLARE
        
      @Lc_From_DATE            CHAR(11),
      @Lc_To_DATE              CHAR(11),
      @Lc_StatusReceipt_CODE    CHAR(2),
      @Ls_Select_TEXT             VARCHAR(MAX) = ' ',
      @Ls_Where_TEXT              VARCHAR(MAX) = ' ',
      @Ls_Order_TEXT              VARCHAR(MAX) = ' ',
      @Ls_SelectDflt_TEXT        VARCHAR(MAX) = ' ',
      @Ls_SelectCase_TEXT        VARCHAR(MAX) = ' ',
      @Ls_SelectOthp_TEXT        VARCHAR(MAX) = ' ',
      @Ls_Where3mts_TEXT         VARCHAR(MAX) = ' ',
      @Ls_WhereReceiptDATE_TEXT VARCHAR(MAX) = ' ',
     
      @Ls_WhereAllCases_TEXT    VARCHAR(MAX) = ' ',
      @Ls_WhereRcpno_TEXT        VARCHAR(MAX) = ' ',
      @Ls_WherePayor_TEXT        VARCHAR(MAX) = ' ',
      @Ls_WhereCheck_TEXT        VARCHAR(MAX) = ' ',
      @Ls_WhereStatus_TEXT       VARCHAR(MAX) = ' ',
      @Ls_WhereRemitType_TEXT   VARCHAR(MAX) = ' ',
      @Ls_WhereDepSrc_TEXT      VARCHAR(MAX) = ' ',
      @Ls_WhereRcptSrc_TEXT     VARCHAR(MAX) = ' ',
      @Ls_WhereUdc_TEXT          VARCHAR(MAX) = ' ',
      @Ls_SortSeqrctA_TEXT      VARCHAR(MAX) = ' ',
      @Ls_SortDtrctA_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortPayorA_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortTxndtA_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortSeqrctD_TEXT      VARCHAR(MAX) = ' ',
      @Ls_SortDtrctD_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortPayorD_TEXT       VARCHAR(MAX) = ' ',
      @Ls_SortTxndtD_TEXT       VARCHAR(MAX) = ' ',
      @Lc_CaseFlag_CODE          CHAR(1)         = 'N',
      @Lc_OthpFlag_CODE          CHAR(1)         = 'N',
      @Ls_PageSelect_TEXT        VARCHAR(MAX) = ' ',
      @Ls_PageWhere_TEXT         VARCHAR(MAX) = ' ',
      @Lc_PayorMCI_IDNO      CHAR(11)    = '0',
      @Lc_Case_IDNO          CHAR(6)= ' ',
      @Ls_SortDefuA_TEXT        VARCHAR(MAX) = ' ',
      @Ls_SortDefuD_TEXT        VARCHAR(MAX) = ' ',
      @Ld_High_DATE CHAR(10)='12/31/9999', 
	  @Ld_Low_DATE  CHAR(10)='01/01/0001',
	  @Lc_CaseRelationshipA_CODE CHAR(1)='A',
	  @Lc_CaseRelationshipP_CODE CHAR(1)='P',
	  @Lc_CaseMemberStatusA_CODE CHAR(1)='A',
	  @Lc_TypeRecordO_CODE 		CHAR='O',
	  @Li_ManuallyDistributeReceipt1810_NUMB INT=1810,
	  @Li_ReceiptDistributed1820_NUMB INT=1820,
	  @Li_ReceiptReversed1250_NUMB INT=1250,
	  @Lc_Yes_INDC			CHAR(1)='Y',
	  @Lc_StatusReceiptA_CODE      CHAR(1)='A',
	  @Lc_StatusReceiptD_CODE      CHAR(1)='D',
	  @Lc_StatusReceiptH_CODE      CHAR(1)='H',
	  @Lc_StatusReceiptN_CODE      CHAR(1)= 'N',
	  @Lc_StatusReceiptP_CODE      CHAR(1)= 'P',
	  @Lc_StatusReceiptL_CODE      CHAR(1)= 'L',
	  @Lc_StatusReceiptB_CODE       CHAR(1)= 'B',
	  @Lc_StatusReceiptE_CODE   CHAR(1)='E',    
      @Lc_SortTypeSeqrect_TEXT   CHAR(8)= 'SEQ_RECT',
      @Lc_SortOrderD_CODE CHAR(1)='D',
      @Lc_SortOrderA_CODE CHAR(1)='A',
      @Lc_SortOrderDtrect_CODE CHAR(7)='DT_RECT',
      @Lc_SortOrderIdpayor_CODE CHAR(8) ='ID_PAYOR',
      @Lc_SortOrderDtdistr_CODE CHAR(13) ='DT_DISTRIBUTE',
      @Lc_Space_TEXT CHAR(1)=' ' ,
      @Lc_StatusReceiptI_CODE       CHAR(1)= 'I',
      @Lc_StatusReceiptY_CODE       CHAR(1)= 'Y',
      @Lc_PayorMCI3_IDNO             CHAR(1)='3',
      @Lc_TypeDisburseRothp_CODE   CHAR(5)='ROTHP',
      
      @Lc_StatusReceiptAo_CODE	CHAR(2)='AO';
    
	SET @Lc_Case_IDNO  = @An_Case_IDNO;
	SET @Ls_SortDefuD_TEXT = ', a.Batch_DATE desc, a.SourceBatch_CODE desc, a.Batch_NUMB desc, a.SeqReceipt_NUMB desc, a.EventGlobalBeginSeq_NUMB DESC';
	SET @Ls_SortDefuA_TEXT = ', a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB, a.EventGlobalBeginSeq_NUMB';
	    
	 
	    
	    
IF @An_Case_IDNO IS NOT NULL AND @An_PayorMCI_IDNO IS NULL 
   BEGIN
            SELECT TOP 1 @Lc_PayorMCI_IDNO=N.MemberMci_IDNO
               
              FROM CMEM_Y1 N
             WHERE N.Case_IDNO = @An_Case_IDNO
               AND N.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE,@Lc_CaseRelationshipP_CODE)
               AND N.CaseMemberStatus_CODE =@Lc_CaseMemberStatusA_CODE;
   END;
ELSE
  BEGIN
    SET @Lc_PayorMCI_IDNO= @An_PayorMCI_IDNO;
  END; 


                                
IF @Ad_ReceiptFrom_DATE IS NOT NULL 
   BEGIN
       SET @Lc_From_DATE = CONVERT (VARCHAR(10),@Ad_ReceiptFrom_DATE,101);
   END;                                 


IF @Ad_ReceiptTo_DATE IS NOT NULL 
    BEGIN  
        SET @Lc_To_DATE    = CONVERT (VARCHAR(10),@Ad_ReceiptTo_DATE,101);
    END;
    
SET @Ls_Where3mts_TEXT          = ' AND a.Receipt_DATE BETWEEN CONVERT (VARCHAR(10),DATEADD(D,-1,DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() ),101) AND CONVERT(VARCHAR (10),DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() ,101) ';
SET @Ls_WhereReceiptDATE_TEXT  = ' AND a.Receipt_DATE BETWEEN '
                                + ''''
                                + @Lc_From_DATE
                                + ''' AND '
                                + ''''
                                + @Lc_To_DATE
                                + ''' ';
      

IF @Ac_CheckNo_TEXT IS NOT NULL OR @Ac_SourceBatch_CODE IS NOT NULL 
         BEGIN
            SET @Ls_Where_TEXT    = NULL;
         END
ELSE IF @Lc_PayorMCI_IDNO IS NOT NULL OR @Lc_Case_IDNO IS NOT NULL 
   BEGIN
           IF @Ad_ReceiptFrom_DATE IS NOT NULL AND @Ad_ReceiptTo_DATE IS NOT NULL AND @Ad_ReceiptFrom_DATE<>@Ld_Low_DATE AND @Ad_ReceiptTo_DATE<>@Ld_Low_DATE
               BEGIN
                  SET @Ls_Where_TEXT    = @Ls_WhereReceiptDATE_TEXT;
               END
           ELSE
              BEGIN
                 SET @Ls_Where_TEXT    = NULL;
              END
    END  
ELSE IF @Ad_ReceiptFrom_DATE IS NOT NULL AND @Ad_ReceiptTo_DATE IS NOT NULL AND @Ad_ReceiptFrom_DATE<>@Ld_Low_DATE AND @Ad_ReceiptTo_DATE<>@Ld_Low_DATE
        BEGIN
           SET @Ls_Where_TEXT    = @Ls_WhereReceiptDATE_TEXT;
        END
      ELSE 
        BEGIN
           SET @Ls_Where_TEXT    = @Ls_Where3mts_TEXT;
        END;


IF @Lc_Case_IDNO IS NOT NULL 
    BEGIN
         IF     @Ac_SourceBatch_CODE IS NULL AND @Ac_CheckNo_TEXT IS NULL 
           BEGIN
           SET  @Ls_WhereAllCases_TEXT    =
                  ' AND a.PayorMCI_IDNO = '
               + ''''
               + @Lc_PayorMCI_IDNO
               + '''
                AND ((a.Case_IDNO IS NULL
                AND       EXISTS ( SELECT 1 FROM LSUP_Y1 b
                                                    WHERE b.Case_IDNO = '
               + ''''
               + CONVERT(VARCHAR,@Lc_Case_IDNO)
               + '''
                                                    AND b.Batch_DATE       = a.Batch_DATE
                                                    AND b.SourceBatch_CODE = a.SourceBatch_CODE
                                                    AND b.Batch_NUMB       = a.Batch_NUMB
                                                    AND b.SeqReceipt_NUMB  = a.SeqReceipt_NUMB
                                                    AND b.TypeRecord_CODE  = '''
               + @Lc_TypeRecordO_CODE
               + '''
                                                    AND b.EventFunctionalSeq_NUMB IN ('
               + CONVERT(VARCHAR,@Li_ReceiptDistributed1820_NUMB)
               + ', '
               + CONVERT(VARCHAR,@Li_ManuallyDistributeReceipt1810_NUMB)
               + ', '
               + CONVERT(VARCHAR,@Li_ReceiptReversed1250_NUMB)
               + ')))
                OR        a.Case_IDNO = '
               + ''''
               + CONVERT(VARCHAR,@Lc_Case_IDNO)
               + ''') ';
           SET  @Lc_CaseFlag_CODE          = @Lc_Yes_INDC;
           SET  @Ls_Where_TEXT              = ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereAllCases_TEXT;
           END
   END
  
IF @Ac_SourceBatch_CODE IS NOT NULL 
   BEGIN
        SET  @Ls_WhereRcpno_TEXT    =
               '    AND     a.Batch_DATE                   = '
            + ''''
            + CONVERT (VARCHAR(10),@Ad_Batch_DATE,101)
            + '''
                AND        a.SourceBatch_CODE        = '
            + ''''
            + @Ac_SourceBatch_CODE
            + '''
                AND        a.Batch_NUMB                   = '
            + ''''
            + CAST (@An_Batch_NUMB AS VARCHAR)
            + '''
                AND        a.SeqReceipt_NUMB             like '
            + ''''
            + CAST(@An_SeqReceipt_NUMB AS VARCHAR)
            + ''' ';
         SET @Ls_Where_TEXT          = ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereRcpno_TEXT;
   END;
      
IF @Lc_PayorMCI_IDNO IS NOT NULL 
   BEGIN
         IF @Ac_StatusReceipt_CODE=@Lc_StatusReceiptAo_CODE
         BEGIN
               SET @Lc_OthpFlag_CODE    = @Lc_Yes_INDC;
         END
         
   ELSE
   BEGIN
           SET @Ls_WherePayor_TEXT =    ' AND   a.PayorMCI_IDNO  = '
                                 + ''''
                                 + @Lc_PayorMCI_IDNO
                                 + ''' ';
           SET   @Ls_Where_TEXT = ISNULL(@Ls_Where_TEXT,'') + @Ls_WherePayor_TEXT;
            END
   END

IF @Ac_CheckNo_TEXT IS NOT NULL 
      BEGIN
             SET  @Ls_WhereCheck_TEXT    =    ' AND   a.CheckNo_TEXT   = '
                              + ''''
                              + CAST(@Ac_CheckNo_TEXT AS VARCHAR)
                              + ''' ';
              SET  @Ls_Where_TEXT          = ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereCheck_TEXT;
      END

IF @Ac_StatusReceipt_CODE IS NOT NULL 
    BEGIN
       IF SUBSTRING(@Ac_StatusReceipt_CODE, 1, 1) = @Lc_StatusReceiptA_CODE 
          BEGIN
           SET  @Lc_StatusReceipt_CODE    = SUBSTRING(@Ac_StatusReceipt_CODE, 2, 1);
           SET  @Ls_WhereStatus_TEXT       =    ' AND a.StatusReceipt_CODE = '
                                     + ''''
                                     + @Lc_StatusReceipt_CODE
                                     + '''	';
          END                           
      ELSE IF @Ac_StatusReceipt_CODE IN(@Lc_StatusReceiptD_CODE,
                                    @Lc_StatusReceiptH_CODE,
                                    @Lc_StatusReceiptN_CODE,
                                    @Lc_StatusReceiptP_CODE,
                                    @Lc_StatusReceiptL_CODE
                                   ) 
            BEGIN                                   
           SET  @Lc_StatusReceipt_CODE    = @Ac_StatusReceipt_CODE;
           SET  @Ls_WhereStatus_TEXT       =
                  '    AND    SUBSTRING(dbo.BATCH_COMMON$SF_RECEIPT_STATUS
                                                                                    (a.Batch_DATE, a.SourceBatch_CODE,a.Batch_NUMB,a.SeqReceipt_NUMB,
                                                                                    a.StatusReceipt_CODE, a.Receipt_AMNT),1,1)
                                                                                    = '
               + ''''
               + @Lc_StatusReceipt_CODE
               + '''    ';
            END   
      ELSE IF @Ac_StatusReceipt_CODE = @Lc_StatusReceiptB_CODE 
           BEGIN
            SET @Lc_StatusReceipt_CODE = @Ac_StatusReceipt_CODE;
            SET @Ls_WhereStatus_TEXT    =    '    AND a.BackOut_INDC = '''
                                     + @Lc_Yes_INDC
                                     + '''    ';
           END                                     
      ELSE
           BEGIN
            SET @Lc_StatusReceipt_CODE    = @Ac_StatusReceipt_CODE;
            SET @Ls_WhereStatus_TEXT       =    ' AND a.StatusReceipt_CODE = '
                                     + ''''
                                     + @Lc_StatusReceipt_CODE
                                     + '''    ';
            END

         SET @Ls_Where_TEXT= ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereStatus_TEXT;
   END
      
      
IF @Ac_TypeRemittance_CODE IS NOT NULL 
   BEGIN
         SET @Ls_WhereRemitType_TEXT    =    ' AND   a.TypeRemittance_CODE  = '
                                   + ''''
                                   + @Ac_TypeRemittance_CODE
                                   + ''' ';
         SET @Ls_Where_TEXT               =ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereRemitType_TEXT;
   END;

IF @Ac_SourceBatchIn_CODE IS NOT NULL
   BEGIN 
         SET @Ls_WhereDepSrc_TEXT    =    ' AND   a.SourceBatch_CODE   = '
                                + ''''
                                + @Ac_SourceBatchIn_CODE
                                + ''' ';
         SET @Ls_Where_TEXT            = ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereDepSrc_TEXT;
   END;
      
IF @Ac_SourceReceipt_CODE IS NOT NULL 
   BEGIN
        SET @Ls_WhereRcptSrc_TEXT=    ' AND   a.SourceReceipt_CODE   = '
                                 + ''''
                                 + @Ac_SourceReceipt_CODE
                                 + ''' ';
        SET @Ls_Where_TEXT = ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereRcptSrc_TEXT;
   END;

IF @Ac_ReasonStatus_CODE IS NOT NULL 
   BEGIN
         SET @Ls_WhereUdc_TEXT =    ' AND   a.ReasonStatus_CODE  = '
                            + ''''
                            + @Ac_ReasonStatus_CODE
                            + ''' ';
         SET @Ls_Where_TEXT = ISNULL(@Ls_Where_TEXT,'') + @Ls_WhereUdc_TEXT;
   END

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
               SET @Ls_Order_TEXT    = @Ls_SortSeqrctD_TEXT + @Ls_SortDefuD_TEXT;
               END;
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
              BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortSeqrctA_TEXT + @Ls_SortDefuA_TEXT;
              END;  
          END;
         ELSE IF @Ac_SortBy_TEXT = @Lc_SortOrderDtrect_CODE  
          BEGIN
            IF @Ac_SortOrder_TEXT = @Lc_SortOrderD_CODE 
              BEGIN
              SET  @Ls_Order_TEXT    = @Ls_SortDtrctD_TEXT + @Ls_SortDefuD_TEXT;
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
               SET @Ls_Order_TEXT    = @Ls_SortPayorD_TEXT + @Ls_SortDefuD_TEXT;
              END; 
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
              BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortPayorA_TEXT + @Ls_SortDefuA_TEXT;
              END; 
         END;
         ELSE IF @Ac_SortBy_TEXT = @Lc_SortOrderDtdistr_CODE 
         BEGIN
            IF @Ac_SortOrder_TEXT = @Lc_SortOrderD_CODE 
             BEGIN
               SET @Ls_Order_TEXT    = @Ls_SortTxndtD_TEXT + @Ls_SortDefuD_TEXT;
             END;  
            ELSE IF @Ac_SortOrder_TEXT = @Lc_SortOrderA_CODE 
            BEGIN 
              SET  @Ls_Order_TEXT    = @Ls_SortTxndtA_TEXT + @Ls_SortDefuA_TEXT;
            END;
        END;    
    END;
  ELSE
    BEGIN
         IF (@Ac_SourceBatch_CODE IS NULL AND @Lc_PayorMCI_IDNO IS NULL AND @Lc_Case_IDNO IS NULL AND @Ac_CheckNo_TEXT IS NULL) 
          BEGIN  
            SET @Ls_Order_TEXT    =  @Lc_Space_TEXT;
          END;  
         ELSE
           BEGIN
            SET @Ls_Order_TEXT    = @Ls_SortSeqrctD_TEXT + @Ls_SortDefuD_TEXT;
           END;
    END;
    
IF (@Ac_SourceBatch_CODE IS NULL AND @Lc_PayorMCI_IDNO IS NULL AND @Lc_Case_IDNO IS NULL AND @Ac_CheckNo_TEXT IS NULL)
  BEGIN    
       SET   @Ls_SelectDflt_TEXT=
               'SELECT        		a.Receipt_DATE,
                                    a.SourceBatch_CODE ,
                                    a.SourceReceipt_CODE ,
                                    a.PayorMCI_IDNO,
                                    a.Case_IDNO,
                                    a.Fips_CODE,
                                    a.ReasonStatus_CODE,
									a.CheckNo_TEXT,
                                    a.Receipt_AMNT,
                                    a.ToDistribute_AMNT,
                                    a.Distribute_DATE,
                                    a.TypePosting_CODE  ,
                                    a.SeqReceipt_NUMB, 
                                    a.Batch_NUMB, 
                                    a.Batch_DATE,
                                    a.StatusReceipt_CODE, 
                                    a.EventGlobalBeginSeq_NUMB, 
                                    a.BeginValidity_DATE, 
                                    a.TypeRemittance_CODE,
                                    a.ReferenceIrs_IDNO,
									COUNT (1) OVER () RowCount_NUMB,'+'ROW_NUMBER() OVER( '+@Ls_Order_TEXT+' ) AS RNM
                FROM  RCTH_Y1 a
                WHERE    a.EndValidity_DATE = '''+ @Ld_High_DATE+''' ';
            
  END       
ELSE
  BEGIN
      SET @Ls_SelectDflt_TEXT= 'SELECT 
                                    a.Receipt_DATE,
                                    a.SourceBatch_CODE ,
                                    a.SourceReceipt_CODE ,
                                    a.PayorMCI_IDNO,
                                    a.Case_IDNO,
                                    a.Fips_CODE,
                                    a.ReasonStatus_CODE,
                                    a.CheckNo_TEXT,
                                    a.Receipt_AMNT,
                                    a.ToDistribute_AMNT,
                                    a.Distribute_DATE,
                                    a.TypePosting_CODE ,
									a.SeqReceipt_NUMB, 
									a.Batch_NUMB, 
									a.Batch_DATE,
									a.StatusReceipt_CODE, 
									a.EventGlobalBeginSeq_NUMB, 
									a.BeginValidity_DATE,
                                    a.TypeRemittance_CODE,
                                    a.ReferenceIrs_IDNO, 
                                    COUNT (1) OVER () RowCount_NUMB,'+'ROW_NUMBER() OVER( '+@Ls_Order_TEXT+' ) AS RNM
                FROM  RCTH_Y1 a
                WHERE a.EndValidity_DATE ='''+ @Ld_High_DATE+''' ';
            
  END 
     SET  @Ls_SelectCase_TEXT = 'SELECT             
                                a.Receipt_DATE,
                                a.SourceBatch_CODE ,
                                a.SourceReceipt_CODE ,
                                a.PayorMCI_IDNO,
                                a.Case_IDNO,
                                a.Fips_CODE,
                                a.ReasonStatus_CODE,
                                a.CheckNo_TEXT,
                                a.Receipt_AMNT,
                                CASE WHEN a.Distribute_DATE != '''
         + @Ld_Low_DATE
         + ''''
         +'AND a.StatusReceipt_CODE = '''
         +@Lc_StatusReceiptI_CODE
         +'''
           AND a.BackOut_INDC <>'''
         + @Lc_StatusReceiptY_CODE
         +'''
            THEN dbo.BATCH_COMMON$SF_AMT_DISTRIBUTE('
         + ''''
         + @Lc_Case_IDNO
         + ''',
                                                                a.Batch_DATE,
                                                                a.SourceBatch_CODE,
                                                                a.Batch_NUMB,
                                                                a.SeqReceipt_NUMB,
                                                                a.BackOut_INDC,
                                                                a.EventGlobalBeginSeq_NUMB)
                                    ELSE a.ToDistribute_AMNT
                                END ToDistribute_AMNT,
                                a.Distribute_DATE,
                                a.TypePosting_CODE ,
								a.SeqReceipt_NUMB, 
								a.Batch_NUMB, 
								a.Batch_DATE, 
								a.StatusReceipt_CODE,  
								a.EventGlobalBeginSeq_NUMB, 
								a.BeginValidity_DATE,
                                a.TypeRemittance_CODE,
                                a.ReferenceIrs_IDNO, 
                                COUNT (1) OVER () RowCount_NUMB,'+'ROW_NUMBER() OVER( '+@Ls_Order_TEXT+' ) AS RNM
              FROM RCTH_Y1 a
              WHERE a.EndValidity_DATE = '''+ @Ld_High_DATE+ '''';
                
     SET  @Ls_SelectOthp_TEXT = 'SELECT
                                    a.Receipt_DATE,
                                    a.SourceBatch_CODE ,
                                    a.SourceReceipt_CODE ,
                                    a.PayorMCI_IDNO,
                                    a.Case_IDNO,
                                    a.Fips_CODE,
                                    a.ReasonStatus_CODE,
                                    a.CheckNo_TEXT,
                                    a.Receipt_AMNT,
                                    a.ToDistribute_AMNT,
                                    a.Distribute_DATE,
                                    a.TypePosting_CODE ,
									                  a.SeqReceipt_NUMB, 
									                  a.Batch_NUMB, 
									                  a.Batch_DATE, 
									                  a.StatusReceipt_CODE, 
									                  a.EventGlobalBeginSeq_NUMB, 
									                  a.BeginValidity_DATE,
                                    a.TypeRemittance_CODE,
                                    a.ReferenceIrs_IDNO,  COUNT (1) OVER () RowCount_NUMB,'+'ROW_NUMBER() OVER( '+@Ls_Order_TEXT+' ) AS RNM 
                               FROM  RCTH_Y1 a, 
												(SELECT DISTINCT 
													l.CheckRecipient_ID,
													l.Batch_DATE,
													l.SourceBatch_CODE, 
													l.Batch_NUMB, 
													l.SeqReceipt_NUMB
                                                FROM DSBL_Y1 l
                                                WHERE l.CheckRecipient_ID = '
         + ''''
         + @Lc_PayorMCI_IDNO
         + '''
                                                AND l.CheckRecipient_CODE = '''
         + @Lc_PayorMCI3_IDNO             
         + '''
                                                AND l.TypeDisburse_CODE = '''
         + @Lc_TypeDisburseRothp_CODE   
         + '''
                                                AND NOT EXISTS (SELECT 1
                                                                                FROM DSBC_Y1 C
                                                                                WHERE c.CheckRecipientOrig_ID = l.CheckRecipient_ID
                                                                                AND c.CheckRecipientOrig_CODE = l.CheckRecipient_CODE
                                                                                AND c.DisburseOrig_DATE     = l.Disburse_DATE
                                                                                AND c.DisburseOrigSeq_NUMB     = l.DisburseSeq_NUMB)) B
                WHERE a.EndValidity_DATE = ''' + @Ld_High_DATE + '''
                AND a.Batch_DATE = b.Batch_DATE
                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                AND a.Batch_NUMB = b.Batch_NUMB
                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB  ';

   
IF @Lc_CaseFlag_CODE = @Lc_Yes_INDC
   BEGIN
         SET @Ls_Select_TEXT    = @Ls_SelectCase_TEXT;
   END; 
ELSE IF @Lc_OthpFlag_CODE = @Lc_Yes_INDC
   BEGIN
        SET @Ls_Select_TEXT    = @Ls_SelectOthp_TEXT;
   END; 
ELSE
   BEGIN
        SET @Ls_Select_TEXT    = @Ls_SelectDflt_TEXT;
   END;

    SET  @Ls_PageSelect_TEXT         = 'SELECT 
    
                           p.Batch_DATE,
                           p.SourceBatch_CODE,
                           p.Batch_NUMB,
                           p.SeqReceipt_NUMB,
                          
                          p.Receipt_DATE,
                          p.SourceBatch_CODE,
                          p.SourceReceipt_CODE,
                          p.PayorMCI_IDNO,
                          p.Case_IDNO,
                          p.Fips_CODE,';
    SET  @Ls_PageSelect_TEXT = @Ls_PageSelect_TEXT
            + ' (SELECT z.ReasonBackOut_CODE'
            
            + '
												FROM  RCTH_Y1 z
												WHERE z.Batch_DATE = p.Batch_DATE
												AND   z.SourceBatch_CODE = p.SourceBatch_CODE
												AND   z.Batch_NUMB = p.Batch_NUMB
												AND   z.SeqReceipt_NUMB = p.SeqReceipt_NUMB
												AND   z.BackOut_INDC = '''
            + @Lc_Yes_INDC
            + '''
												AND   z.EndValidity_DATE = '''
            + @Ld_High_DATE+''' ) AS ReasonBackOut_CODE,


			
			p.ReasonStatus_CODE,
			p.StatusReceipt_CODE,
			p.CheckNo_TEXT,
			p.Receipt_AMNT,
			p.ToDistribute_AMNT,
			dbo.BATCH_COMMON$SF_RECEIPT_STATUS(p.Batch_DATE, p.SourceBatch_CODE,p.Batch_NUMB,p.SeqReceipt_NUMB,	p.StatusReceipt_CODE, p.Receipt_AMNT)AS DistStatus_CODE,
			CASE WHEN p.StatusReceipt_CODE IN ('''
            + @Lc_StatusReceiptE_CODE   
            + ''','''
            + @Lc_StatusReceiptH_CODE      
            + ''')
                                         THEN CONVERT(DATE,CONVERT (VARCHAR(10), p.BeginValidity_DATE, 101))
                                         ELSE  CONVERT(DATE,CONVERT (VARCHAR(10), p.Distribute_DATE, 101)) 
 			END	AS Distribute_DATE,
 			p.TypePosting_CODE, 
 			p.TypeRemittance_CODE,
 			p.ReferenceIrs_IDNO,
 			p.Rapid_IDNO,
 			p.RapidEnvelope_NUMB,
	        p.RapidReceipt_NUMB, 
 			p.PaidBy_NAME,
 			p.PaidBy_ID, 
 			RowCount_NUMB FROM ( ' ;

    SET @Ls_PageSelect_TEXT= @Ls_PageSelect_TEXT + ' SELECT x.Receipt_DATE,
														x.SourceBatch_CODE,
														x.SourceReceipt_CODE,
														x.PayorMCI_IDNO,
														x.Case_IDNO,
														x.Fips_CODE, ';
    
    SET  @Ls_PageSelect_TEXT= @Ls_PageSelect_TEXT + 'x.ReasonStatus_CODE,
													x.CheckNo_TEXT,
													x.Receipt_AMNT,
													x.ToDistribute_AMNT,
													x.Distribute_DATE,
													x.TypePosting_CODE,
													x.SeqReceipt_NUMB, 
													x.Batch_NUMB, 
													x.Batch_DATE, 
													x.StatusReceipt_CODE,  
													x.EventGlobalBeginSeq_NUMB, 
													x.BeginValidity_DATE, 
													x.TypeRemittance_CODE,
													x.ReferenceIrs_IDNO,
													Y.Rapid_IDNO,
													Y.RapidEnvelope_NUMB,
													Y.RapidReceipt_NUMB,
													Y.PaidBy_NAME, 
													Y.PaidBy_ID,
													RowCount_NUMB,rnm FROM (';
            
IF @Ai_RowFrom_NUMB = 0 
  BEGIN
     SET @Ls_PageWhere_TEXT = ') ) p';
  END;
ELSE
   BEGIN
      SET  @Ls_PageWhere_TEXT =')AS X LEFT OUTER JOIN RSDU_Y1  Y  
                            ON(X.Batch_DATE=Y.Batch_DATE AND
                              X.SourceBatch_CODE=Y.SourceBatch_CODE AND
                              X.Batch_NUMB=Y.Batch_NUMB AND
                              X.SeqReceipt_NUMB=Y.SeqReceipt_NUMB)  WHERE RNM <='
                                + CONVERT(VARCHAR(10),@Ai_RowTo_NUMB)
                                + ')AS p WHERE rnm >='
                                +CONVERT(VARCHAR(10),@Ai_RowFrom_NUMB);
   END;

EXEC(@Ls_PageSelect_TEXT+ ' '+ @Ls_Select_TEXT+ ' '+ @Ls_Where_TEXT+ ' '+ @Ls_PageWhere_TEXT);
 
END;--RCTH_RETRIEVE_S157; 

GO
