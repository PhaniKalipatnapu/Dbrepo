/****** Object:  StoredProcedure [dbo].[SLST_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[SLST_RETRIEVE_S3]      
    (
     @Ac_TypeArrear_CODE	CHAR(1),    
     @Ai_RowFrom_NUMB       INT=1,    
     @Ai_RowTo_NUMB         INT=10,    
     @An_MemberMci_IDNO		NUMERIC(10,0)
    )                  
AS    
    
/*    
 *     PROCEDURE NAME    : SLST_RETRIEVE_S3    
 *     DESCRIPTION       : Retrieves the previous transaction of state tax programs information using membermci_idno.    
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 03-DEC-2011    
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
            
      SELECT K.MemberMci_IDNO,     
             K.SubmitLast_DATE,     
             K.CountyFips_CODE,     
             K.TypeTransaction_CODE AS TypeTransactionState_CODE,     
             K.Arrears_AMNT,     
             K.TypeArrear_CODE,     
             K.PopUpFlag_INDC,     
             K.row_count AS RowCount_NUMB    
        FROM(SELECT Y.MemberMci_IDNO,     
                   Y.SubmitLast_DATE,     
                   Y.CountyFips_CODE,     
				   Y.TypeTransaction_CODE,     
                   Y.Arrears_AMNT,     
                   Y.TypeArrear_CODE,         
                   Y.PopUpFlag_INDC,     
                   Y.row_count,     
                   Y.ORD_ROWNUM AS rnm    
              FROM(SELECT X.MemberMci_IDNO,     
                         X.SubmitLast_DATE,     
                         X.CountyFips_CODE,     
                         X.TypeTransaction_CODE,     
                         X.Arrears_AMNT,     
                         X.TypeArrear_CODE,          
                         X.PopUpFlag_INDC,     
                         COUNT(1) OVER() AS row_count,     
                         ROW_NUMBER() OVER(    
									ORDER BY X.SubmitLast_DATE DESC, X.TypeArrear_CODE) AS ORD_ROWNUM    
                    FROM(SELECT z.MemberMci_IDNO,     
                                z.SubmitLast_DATE,     
                                z.CountyFips_CODE,     
                                z.TypeTransaction_CODE,     
                                z.Arrears_AMNT,     
                                z.TypeArrear_CODE,          
                                z.PopUpFlag_INDC,     
                                z.rn    
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
												 WHEN a.TypeTransaction_CODE   = @Lc_TypeTransactionI_CODE 
												 AND RTRIM(LTRIM(a.Record_ID)) = @Lc_Record3_CODE 
													THEN @Lc_Record3_CODE    
													ELSE a.TypeTransaction_CODE    
											  END AS TypeTransaction_CODE,     
											  a.Arrears_AMNT,     
											  a.TypeArrear_CODE,        
                                              @Lc_Yes_INDC AS PopUpFlag_INDC,     
											  a.TransactionEventSeq_NUMB    
										 FROM SLST_Y1 a    
                                        WHERE a.MemberMci_IDNO   = @An_MemberMci_IDNO 
                                          AND a.TypeArrear_CODE  = ISNULL(@Ac_TypeArrear_CODE, a.TypeArrear_CODE)   
                                     ) h    
                              )z    
                         WHERE z.rn != @Li_One_NUMB    
                       ) X    
                ) Y    
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB    
           ) K    
      WHERE K.rnm >= @Ai_RowFrom_NUMB    
   ORDER BY RNM;    
    
END; --END OF SLST_RETRIEVE_S3 

GO
