/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S75]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S75](
     @Ad_Batch_DATE		DATE, 
     @Ac_SourceBatch_CODE		 CHAR(3), 
     @An_Batch_NUMB               NUMERIC(4,0),  
     @An_SeqReceipt_NUMB		 NUMERIC(6,0)
     )                
AS  
  
/*  
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S75  
 *     DESCRIPTION       : It Retrieve the Distributed Detail for the Process R-Reposted.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
     
  
      DECLARE  
                    
         @Lc_TypeRecordOriginal_CODE     CHAR(1)       = 'O',            
         @Lc_WelfareTypeFosterCare_CODE  CHAR(1)       = 'J',            
         @Lc_WelfareTypeMedicaid_CODE    CHAR(1)       = 'M',            
         @Lc_WelfareTypeNonIvd_CODE      CHAR(1)       = 'H',            
         @Lc_WelfareTypeNonIve_CODE      CHAR(1)       = 'F',            
         @Lc_WelfareTypeNonTanf_CODE     CHAR(1)       = 'N',            
         @Lc_WelfareTypeTanf_CODE        CHAR(1)       = 'A',            
         @Ld_High_DATE               DATE          = '12/31/9999',   
         @Li_Zero_NUMB                   SMALLINT      = 0,              
         @Lc_DebtTypeMedicalSupp_CODE    CHAR(2)    = 'MS',        
		 @Li_ReceiptReversed1820_NUMB	INT = 1820,
         @Lc_Ca_CODE                     CHAR(2)    = 'CA',           
         @Lc_Current_CODE                CHAR(7)    = 'CURRENT',      
         @Lc_Expt_CODE                   CHAR(4)    = 'EXPT',         
         @Lc_Future_CODE                 CHAR(6)    = 'FUTURE',       
         @Lc_Ivef_CODE                   CHAR(4)    = 'IVEF',         
         @Lc_Medi_CODE                   CHAR(4)    = 'MEDI',         
         @Lc_Na_CODE                     CHAR(2)    = 'NA',           
         @Lc_Nffc_CODE                   CHAR(4)    = 'NFFC',         
         @Lc_NonIvd_CODE                 CHAR(4)    = 'NIVD',         
         @Lc_Pa_CODE                     CHAR(2)    = 'PA',           
         @Lc_Ta_CODE                     CHAR(2)    = 'TA',           
         @Lc_Uda_CODE                    CHAR(3)    = 'UDA',          
         @Lc_Upa_CODE                    CHAR(3)    = 'UPA';          
          
        SELECT 
         @Lc_Current_CODE AS DistributedAs_CODE,   
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.TransactionCurSup_AMNT) AS Distribute_AMNT,
         X.Distribute_DATE,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO ,     
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME
          
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE, 
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
                 
               l.TransactionCurSup_AMNT  
            FROM LSUP_Y1 l 
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            
            JOIN
             SORD_Y1 s
             ON
             l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
               
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionCurSup_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)   
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO 
      GROUP BY
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME   
       UNION  
      SELECT   
         @Lc_Expt_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.TransactionExptPay_AMNT),  
         X.Distribute_DATE,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO ,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME 
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE, 
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
              
               l.TransactionExptPay_AMNT   
            FROM LSUP_Y1 l 
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB 
            JOIN
            SORD_Y1 s
            ON
            l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
              
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionExptPay_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY 
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,  
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME   
       UNION  
      SELECT   
         @Lc_Na_CODE AS DistributedAs_CODE, 
         X.Case_IDNO,
         X.TypeWelfare_CODE,   
         SUM(X.Distribute_AMNT),
         X.Distribute_DATE,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,    
         X.Order_IDNO ,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,   
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
               
               ISNULL(l.TransactionNaa_AMNT, @Li_Zero_NUMB) - CASE l.TypeWelfare_CODE  
                  WHEN @Lc_WelfareTypeNonTanf_CODE THEN l.TransactionCurSup_AMNT  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  WHEN @Lc_WelfareTypeMedicaid_CODE THEN l.TransactionCurSup_AMNT  
                  ELSE @Li_Zero_NUMB  
               END AS Distribute_AMNT  
            FROM LSUP_Y1 l 
            JOIN 
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
             SORD_Y1 s
             ON
             l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB  
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               ISNULL(l.TransactionNaa_AMNT, @Li_Zero_NUMB) -   
               CASE l.TypeWelfare_CODE  
                  WHEN @Lc_WelfareTypeNonTanf_CODE THEN l.TransactionCurSup_AMNT  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  WHEN @Lc_WelfareTypeMedicaid_CODE THEN l.TransactionCurSup_AMNT  
                  ELSE @Li_Zero_NUMB  
               END != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)  
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO 
      GROUP BY 
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,    
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Ta_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE, 
         SUM(X.TransactionTaa_AMNT),  
         X.Distribute_DATE, 
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.Order_IDNO ,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME 
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,  
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
              
               l.TransactionTaa_AMNT 
            FROM LSUP_Y1 l
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
            SORD_Y1 s 
            ON
             l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionTaa_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY  
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,   
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME   
       UNION  
      SELECT   
         @Lc_Pa_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.Distribute_AMNT),
         X.Distribute_DATE,      
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME 
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,     
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
               
               ISNULL(l.TransactionPaa_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  ELSE CASE l.TypeWelfare_CODE  
                     WHEN @Lc_WelfareTypeTanf_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                     ELSE @Li_Zero_NUMB  
                  END  
               END AS Distribute_AMNT  
            FROM LSUP_Y1 l
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
            SORD_Y1 s  
            ON
            l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               ISNULL(l.TransactionPaa_AMNT, @Li_Zero_NUMB) -   
               CASE o.TypeDebt_CODE  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  ELSE   
                     CASE l.TypeWelfare_CODE  
                        WHEN @Lc_WelfareTypeTanf_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                        ELSE @Li_Zero_NUMB  
                     END  
               END != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)  
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO 
      GROUP BY  
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,  
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Ca_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.TransactionCaa_AMNT),   
         X.Distribute_DATE,  
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.Order_IDNO,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
      FROM   
         (  
            SELECT  
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,  
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
                
               l.TransactionCaa_AMNT   
            FROM LSUP_Y1 l 
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
            SORD_Y1 s
            ON
            l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
              
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionCaa_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)   
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY  
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,   
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME   
       UNION  
      SELECT   
         @Lc_Upa_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.TransactionUpa_AMNT), 
         X.Distribute_DATE, 
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME 
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,  
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
                
               l.TransactionUpa_AMNT   
            FROM LSUP_Y1 l 
            JOIN
            OBLE_Y1 o 
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB 
            JOIN
            SORD_Y1 s
            ON
            l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB  
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionUpa_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE) 
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO 
      GROUP BY 
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,    
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Uda_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.TransactionUda_AMNT),
         X.Distribute_DATE,      
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME   
      FROM   
         (  
            SELECT  
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,  
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
                 
               l.TransactionUda_AMNT  
            FROM LSUP_Y1 l
            JOIN
             OBLE_Y1 o 
             ON
             l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
               JOIN
              SORD_Y1 s  
              ON
              l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionUda_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)  
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY  
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,    
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Ivef_CODE AS DistributedAs_CODE, 
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.Distribute_AMNT),
         X.Distribute_DATE,   
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.Order_IDNO,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,   
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
                
               ISNULL(l.TransactionIvef_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  ELSE CASE l.TypeWelfare_CODE  
                     WHEN @Lc_WelfareTypeNonIve_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                     ELSE @Li_Zero_NUMB  
                  END  
               END AS Distribute_AMNT  
            FROM LSUP_Y1 l
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
           SORD_Y1 s 
           ON
            l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               ISNULL(l.TransactionIvef_AMNT, @Li_Zero_NUMB) -   
               CASE l.TypeWelfare_CODE  
                  WHEN @Lc_WelfareTypeNonIve_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                  ELSE @Li_Zero_NUMB  
               END != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)  
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY 
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,  
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Medi_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.Distribute_AMNT),
         X.Distribute_DATE,  
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME   
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,  
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
                
               l.TransactionMedi_AMNT - CASE   
                  WHEN o.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE AND l.TypeWelfare_CODE IN ( @Lc_WelfareTypeMedicaid_CODE, @Lc_WelfareTypeTanf_CODE ) THEN l.TransactionCurSup_AMNT  
                  ELSE @Li_Zero_NUMB  
               END AS Distribute_AMNT  
            FROM LSUP_Y1 l
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
             SORD_Y1 s
             ON
             l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB  
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionMedi_AMNT -   
               CASE   
                  WHEN o.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE AND l.TypeWelfare_CODE IN ( @Lc_WelfareTypeMedicaid_CODE, @Lc_WelfareTypeTanf_CODE ) THEN l.TransactionCurSup_AMNT  
                  ELSE @Li_Zero_NUMB  
               END != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE) 
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY  
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,   
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Nffc_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,
         SUM(X.Distribute_AMNT),
         X.Distribute_DATE,     
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,
         X.Order_IDNO ,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME 
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE, 
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
               
               ISNULL(l.TransactionNffc_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  ELSE CASE l.TypeWelfare_CODE  
                     WHEN @Lc_WelfareTypeFosterCare_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                     ELSE @Li_Zero_NUMB  
                  END  
               END AS Distribute_AMNT  
            FROM LSUP_Y1 l
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB 
            JOIN
            SORD_Y1 s 
            ON
             l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               ISNULL(l.TransactionNffc_AMNT, @Li_Zero_NUMB) -   
               CASE l.TypeWelfare_CODE  
                  WHEN @Lc_WelfareTypeFosterCare_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                  ELSE @Li_Zero_NUMB  
               END != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)   
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY 
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,    
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_NonIvd_CODE AS DistributedAs_CODE,
         X.Case_IDNO,
         X.TypeWelfare_CODE,   
         SUM(X.Distribute_AMNT),
         X.Distribute_DATE,   
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.Order_IDNO  ,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME 
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE,   
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
               
               ISNULL(l.TransactionNonIvd_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE  
                  WHEN @Lc_DebtTypeMedicalSupp_CODE THEN @Li_Zero_NUMB  
                  ELSE CASE l.TypeWelfare_CODE  
                     WHEN @Lc_WelfareTypeNonIvd_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                     ELSE @Li_Zero_NUMB  
                  END  
               END AS Distribute_AMNT  
            FROM LSUP_Y1 l 
            JOIN
            OBLE_Y1 o
            ON
            l.Case_IDNO = o.Case_IDNO AND   
               l.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
               l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
            JOIN
            SORD_Y1 s 
            ON
            l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB
             
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               ISNULL(l.TransactionNonIvd_AMNT, @Li_Zero_NUMB) -   
               CASE l.TypeWelfare_CODE  
                  WHEN @Lc_WelfareTypeNonIvd_CODE THEN ISNULL(l.TransactionCurSup_AMNT, @Li_Zero_NUMB)  
                  ELSE @Li_Zero_NUMB  
               END != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)   
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY   
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE,    
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
       UNION  
      SELECT   
         @Lc_Future_CODE AS DistributedAs_CODE, 
         X.Case_IDNO,
         X.TypeWelfare_CODE, 
         SUM(X.TransactionFuture_AMNT),
         X.Distribute_DATE,   
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.Order_IDNO ,
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME  
      FROM   
         (  
            SELECT   
               l.Case_IDNO,
               s.Order_IDNO,
               o.MemberMci_IDNO,
               o.TypeDebt_CODE,
               o.Fips_CODE, 
               l.TypeWelfare_CODE,   
               l.Distribute_DATE,   
               l.TransactionFuture_AMNT   
            FROM LSUP_Y1 l
            JOIN
             OBLE_Y1 o
             ON
              o.Case_IDNO = l.Case_IDNO AND   
               o.OrderSeq_NUMB = l.OrderSeq_NUMB AND   
               o.ObligationSeq_NUMB = l.ObligationSeq_NUMB 
             JOIN
              SORD_Y1 s
              ON
              l.Case_IDNO = s.Case_IDNO AND   
               l.OrderSeq_NUMB = s.OrderSeq_NUMB  
            WHERE   
               l.Batch_DATE = @Ad_Batch_DATE AND   
               l.SourceBatch_CODE = @Ac_SourceBatch_CODE AND   
               l.Batch_NUMB = @An_Batch_NUMB AND   
               l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB AND   
               l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE AND   
               l.TransactionFuture_AMNT != @Li_Zero_NUMB AND   
               l.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1820_NUMB AND   
               o.EndValidity_DATE = @Ld_High_DATE AND   
               s.EndValidity_DATE = @Ld_High_DATE AND   
               o.EndObligation_DATE =   
               (  
                  SELECT MAX(b.EndObligation_DATE)   
                  FROM OBLE_Y1 b  
                  WHERE   
                     b.Case_IDNO = o.Case_IDNO AND   
                     b.OrderSeq_NUMB = o.OrderSeq_NUMB AND   
                     b.ObligationSeq_NUMB = o.ObligationSeq_NUMB AND   
                     b.EndValidity_DATE = @Ld_High_DATE  
               )  
         )  AS X  LEFT OUTER JOIN DEMO_Y1 d 
             ON
             d.MemberMci_IDNO =x.MemberMci_IDNO
      GROUP BY   
         X.Case_IDNO,
         X.Order_IDNO,
         X.MemberMci_IDNO,
         X.TypeDebt_CODE,
         X.Fips_CODE, 
         X.TypeWelfare_CODE,   
         X.Distribute_DATE,   
         d.Last_NAME, 
         d.Suffix_NAME, 
         d.First_NAME,
         d.Middle_NAME ;  
  
                    
END;--End of LSUP_RETRIEVE_S75  
  

GO
