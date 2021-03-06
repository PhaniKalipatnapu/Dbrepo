/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S78]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S78](
     @An_Case_IDNO		 NUMERIC(6,0),  
     @An_SupportYearMonthFrom_NUMB         NUMERIC(6,0)        ,  
     @An_SupportYearMonthTo_NUMB           NUMERIC(6,0)        ,  
     @An_TotPayments_AMNT         NUMERIC(11,2) OUTPUT 
     ) 
AS  
  
/*  
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S78  
 *     DESCRIPTION       : It Retrieves the total payment for the case id ,supported year & month.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
    BEGIN  
  
    
      SET 
        @An_TotPayments_AMNT = NULL;  
  
      DECLARE  
         @Lc_TypeRecordOriginal_CODE			CHAR(1)= 'O',   
         @Li_ReceiptReversed1250_NUMB			INT = 1250,   
         @Li_ManuallyDistributeReceipt1810_NUMB INT = 1810,   
         @Li_ReceiptDistributed1820_NUMB		INT = 1820;  
  
     SELECT @An_TotPayments_AMNT = SUM(  L.TransactionNaa_AMNT  
                                       +   
                                      L.TransactionPaa_AMNT  
                                       +   
                                      L.TransactionTaa_AMNT  
                                       +   
                                      L.TransactionCaa_AMNT  
                                       +   
                                      L.TransactionUpa_AMNT  
                                       +   
                                      L.TransactionUda_AMNT  
                                       +   
                                      L.TransactionIvef_AMNT  
                                       +   
                                      L.TransactionNffc_AMNT  
                                       +   
                                      L.TransactionNonIvd_AMNT  
                                       +   
                                      L.TransactionMedi_AMNT
                                      )  
     FROM	LSUP_Y1 L  
     WHERE	L.Case_IDNO = @An_Case_IDNO 
       AND  L.SupportYearMonth_NUMB BETWEEN @An_SupportYearMonthFrom_NUMB AND @An_SupportYearMonthTo_NUMB 
       AND  L.EventFunctionalSeq_NUMB IN ( @Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB ) 
       AND  L.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE; 
         
END;-- End of LSUP_RETRIEVE_S78  
  


GO
