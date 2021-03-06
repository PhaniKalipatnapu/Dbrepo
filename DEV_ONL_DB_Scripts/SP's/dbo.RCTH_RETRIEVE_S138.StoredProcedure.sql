/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S138]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S138](
     @An_Case_IDNO		 NUMERIC(6,0),  
     @An_SupportYearMonthFrom_NUMB          NUMERIC(6,0),  
     @An_SupportYearMonthTo_NUMB            NUMERIC(6,0)
     )               
AS  
  
/*  
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S138  
 *     DESCRIPTION       : It Retrieve the receipt transaction details to be displayed on the payment history report.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
    
   
      DECLARE  
         @Lc_RelationshipCaseNcp_CODE           CHAR(1)      = 'A',   
         @Lc_RelationshipCasePutFather_CODE     CHAR(1)      = 'P',   
         @Lc_StatusCaseMemberActive_CODE        CHAR(1)      = 'A',   
         @Lc_TypeRecordOriginal_CODE            CHAR(1)      = 'O',   
         @Ld_High_DATE                      DATE = '12/31/9999',   
         @Ld_Low_DATE                       DATE = '01/01/0001',   
         @Li_DirectPayCredit1040_NUMB        INT = 1040,   
         @Li_ReceiptReversed1250_NUMB        INT = 1250,   
         @Li_ManuallyDistributeReceipt1810_NUMB        INT = 1810,   
         @Li_ReceiptDistributed1820_NUMB        INT = 1820,   
         @Lc_DescriptionTransactionMonChar_CODE CHAR(16)  = 'Monthly Charges',   
         @Li_Zero_NUMB                      SMALLINT =0,
         @Lc_TypeDebtI_CODE                 CHAR(1)='I';
        
          
      SELECT X.Batch_DATE, 
               X.SourceBatch_CODE, 
               X.Batch_NUMB, 
               X.SeqReceipt_NUMB  ,
         X.TypeRemittance_CODE,   
         X.CheckNo_Text,   
         X.Receipt_DATE,
         X.SourceReceipt_CODE ,  
         X.TypeDebt_CODE,   
         X.Charging_AMNT,   
         X.Payment_AMNT 
      FROM(  
            SELECT a.Receipt_DATE ,  
               a.SourceReceipt_CODE, 
               NULL AS TypeDebt_CODE,   
               @Li_Zero_NUMB AS Charging_AMNT,   
               CASE   
                  WHEN a.Distribute_DATE != @Ld_Low_DATE THEN dbo.BATCH_COMMON$SF_AMT_DISTRIBUTE(  
                     @An_Case_IDNO,   
                     a.Batch_DATE,   
                     a.SourceBatch_CODE,   
                     a.Batch_NUMB,   
                     a.SeqReceipt_NUMB,   
                     a.BackOut_INDC,   
                     a.EventGlobalBeginSeq_NUMB)  
                  ELSE a.ToDistribute_AMNT  
               END AS Payment_AMNT, 
               a.Batch_DATE, 
               a.SourceBatch_CODE, 
               a.Batch_NUMB, 
               a.SeqReceipt_NUMB , 
               a.TypeRemittance_CODE,   
               a.CheckNo_Text  
            FROM RCTH_Y1 a  
            WHERE a.PayorMCI_IDNO IN   
               (  
                  SELECT C.MemberMci_IDNO  
                  FROM CMEM_Y1 C  
                  WHERE   
                     C.Case_IDNO = @An_Case_IDNO    
                   AND  C.CaseRelationship_CODE IN ( @Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE )    
                   AND  C.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE  
               ) 
               AND a.StatusReceipt_CODE='I'                  
               AND EXISTS   
               (  
                  SELECT 1  
                  FROM LSUP_Y1 b  
                  WHERE   
                     b.Case_IDNO = @An_Case_IDNO    
                    AND b.SupportYearMonth_NUMB BETWEEN @An_SupportYearMonthFrom_NUMB AND @An_SupportYearMonthTo_NUMB    
                    AND b.EventFunctionalSeq_NUMB IN ( @Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB, @Li_DirectPayCredit1040_NUMB )    
                    AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE    
                    AND b.Batch_DATE = a.Batch_DATE    
                    AND b.Batch_NUMB = a.Batch_NUMB    
                    AND b.SourceBatch_CODE = a.SourceBatch_CODE    
                    AND b.SeqReceipt_NUMB = a.SeqReceipt_NUMB  
               )    
              AND a.EndValidity_DATE = @Ld_High_DATE  
            UNION ALL  
            SELECT  
             CONVERT(DATE, CAST( CAST(a.SupportYearMonth_NUMB AS VARCHAR)+'01' AS DATETIME))AS Transaction_DATE,              
               @Lc_DescriptionTransactionMonChar_CODE AS SourceReceipt_CODE,   
               b.TypeDebt_CODE,   
               CASE WHEN b.TypeDebt_CODE='NF' THEN SUM(a.OweTotNaa_AMNT)  
               ELSE SUM(a.MtdCurSupOwed_AMNT) END AS Charging_AMNT,  
               @Li_Zero_NUMB AS Payment_AMNT,
               NULL AS Batch_DATE, 
               NULL AS SourceBatch_CODE, 
               NULL AS Batch_NUMB,
               NULL AS SeqReceipt_NUMB, 
               NULL AS TypeRemittance_CODE,   
               NULL AS CheckNo_Text  
            FROM LSUP_Y1 a 
            JOIN
             OBLE_Y1 b 
             ON 
             b.Case_IDNO = a.Case_IDNO    
             AND  b.OrderSeq_NUMB = a.OrderSeq_NUMB    
             AND  b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              
            WHERE   
               a.Case_IDNO = @An_Case_IDNO    
              AND a.SupportYearMonth_NUMB BETWEEN @An_SupportYearMonthFrom_NUMB AND @An_SupportYearMonthTo_NUMB    
               
             AND  b.BeginObligation_DATE =   
               (  
                  SELECT MAX(o.BeginObligation_DATE)   
                  FROM OBLE_Y1 o  
                  WHERE   
                     a.Case_IDNO = o.Case_IDNO    
                   AND  a.OrderSeq_NUMB = o.OrderSeq_NUMB    
                   AND  a.ObligationSeq_NUMB = o.ObligationSeq_NUMB    
                   AND  o.EndValidity_DATE = @Ld_High_DATE  
               )    
             AND  SUBSTRING(b.TypeDebt_CODE, 2, 1) != @Lc_TypeDebtI_CODE    
             AND  b.EndValidity_DATE = @Ld_High_DATE    
             AND  a.EventGlobalSeq_NUMB =   
               (  
                  SELECT MAX(c.EventGlobalSeq_NUMB)   
                  FROM LSUP_Y1 c  
                  WHERE   
                     c.Case_IDNO = a.Case_IDNO    
                    AND c.OrderSeq_NUMB = a.OrderSeq_NUMB    
                    AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB    
                   AND  c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB  
               )  
            GROUP BY b.TypeDebt_CODE, a.SupportYearMonth_NUMB  
         )  AS X  
      ORDER BY Receipt_DATE;
      
END;--End of RCTH_RETRIEVE_S138 
  


GO
