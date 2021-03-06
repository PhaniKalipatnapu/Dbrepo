/****** Object:  StoredProcedure [dbo].[SLST_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
 CREATE PROCEDURE  [dbo].[SLST_RETRIEVE_S1]        
    (  
     @Ac_TypeArrear_CODE	CHAR(1),      
     @An_MemberMci_IDNO		NUMERIC(10,0)
    )                    
AS      
      
/*      
 *     PROCEDURE NAME    : SLST_RETRIEVE_S1      
 *     DESCRIPTION       : Retrieves the latest transaction of state tax programs information using membermci_idno.      
 *     DEVELOPED BY      : IMP Team      
 *     DEVELOPED ON      : 02-DEC-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
*/      
 BEGIN      
      
      DECLARE 
             @Li_One_NUMB               INT     = 1,      
             @Lc_Yes_INDC				CHAR(1) = 'Y',       
             @Lc_TypeTransactionI_CODE	CHAR(1) = 'I',
             @Lc_Record3_CODE			CHAR(1) = '3';      
              
      SELECT z.MemberMci_IDNO,       
             z.SubmitLast_DATE,       
             z.CountyFips_CODE,       
             z.TypeTransaction_CODE AS TypeTransactionState_CODE,       
             z.Arrears_AMNT,       
             z.TypeArrear_CODE,       
             z.PopUpFlag_INDC      
        FROM(SELECT h.MemberMci_IDNO,       
                   h.SubmitLast_DATE,       
                   h.CountyFips_CODE,       
                   h.TypeTransaction_CODE,       
                   h.Arrears_AMNT,       
                   h.TypeArrear_CODE,              
                   h.PopUpFlag_INDC,       
                   h.TransactionEventSeq_NUMB,       
                   ROW_NUMBER() OVER(PARTITION BY h.MemberMci_IDNO, h.TypeArrear_CODE      
									ORDER BY h.TransactionEventSeq_NUMB DESC) AS rn      
              FROM(SELECT a.MemberMci_IDNO,       
                          a.SubmitLast_DATE,       
                          a.CountyFips_CODE,       
						  CASE       
							WHEN a.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE  
							AND  RTRIM(LTRIM(a.Record_ID)) = @Lc_Record3_CODE 
								THEN @Lc_Record3_CODE      
							ELSE a.TypeTransaction_CODE      
						  END AS TypeTransaction_CODE,       
                          a.Arrears_AMNT,       
                          a.TypeArrear_CODE,              
                          @Lc_Yes_INDC AS PopUpFlag_INDC,       
                          a.TransactionEventSeq_NUMB      
                     FROM SLST_Y1 a      
                    WHERE a.MemberMci_IDNO  = @An_MemberMci_IDNO 
                      AND a.TypeArrear_CODE = ISNULL(@Ac_TypeArrear_CODE, a.TypeArrear_CODE) 
                      AND a.SubmitLast_DATE =       
                                            (      
                                             SELECT MAX(c.SubmitLast_DATE)      
                                               FROM SLST_Y1 c      
                                              WHERE c.TypeArrear_CODE = a.TypeArrear_CODE 
                                                AND c.MemberMci_IDNO  = a.MemberMci_IDNO      
                                            )       
                 ) h      
           ) z      
      WHERE z.rn = @Li_One_NUMB      
   ORDER BY SubmitLast_DATE DESC, TypeArrear_CODE, TypeTransactionState_CODE;      
      
END; --END OF  SLST_RETRIEVE_S1

GO
