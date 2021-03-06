/****** Object:  StoredProcedure [dbo].[FEDH_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
 CREATE PROCEDURE  [dbo].[FEDH_RETRIEVE_S8]      
    (
     @Ac_TypeArrear_CODE	CHAR(1),    
     @Ai_RowFrom_NUMB       INT=1,    
     @Ai_RowTo_NUMB         INT=10,    
     @An_TaxYear_NUMB		NUMERIC(4,0),    
     @An_MemberSsn_NUMB		NUMERIC(9,0)
    )                   
AS    
    
/*    
 *     PROCEDURE NAME    : FEDH_RETRIEVE_S8    
 *     DESCRIPTION       : Retrieve federal tax information for previous transaction using memberssn_numb.    
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 02-DEC-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
*/    
 BEGIN       
    
      DECLARE    
             @Lc_No_INDC	CHAR(1) = 'N',
             @Lc_Yes_INDC	CHAR(1) = 'Y';    
            
      SELECT Z.MemberMci_IDNO,       
             Z.SubmitLast_DATE,         
             Z.TypeTransaction_CODE,     
             Z.Arrear_AMNT,     
             Z.TypeArrear_CODE,     
             Z.ExcludeIrs_CODE,     
             Z.ExcludeRet_CODE,     
             Z.ExcludeVen_CODE,     
             Z.ExcludeSal_CODE,     
             Z.ExcludeFin_CODE,     
             Z.ExcludePas_CODE,     
             Z.ExcludeIns_CODE,         
             Z.row_count AS RowCount_NUMB    
        FROM(SELECT Y.MemberMci_IDNO,          
                   Y.SubmitLast_DATE,         
                   Y.TypeTransaction_CODE,     
                   Y.Arrear_AMNT,     
                   Y.TypeArrear_CODE,     
                   Y.ExcludeIrs_CODE,     
                   Y.ExcludeRet_CODE,     
                   Y.ExcludeVen_CODE,     
                   Y.ExcludeSal_CODE,     
                   Y.ExcludeFin_CODE,     
                   Y.ExcludePas_CODE,     
                   Y.ExcludeIns_CODE,          
                   Y.row_count,     
                   Y.ORD_ROWNUM AS rnm    
              FROM(SELECT X.MemberMci_IDNO,          
                         X.SubmitLast_DATE,         
                         X.TypeTransaction_CODE,     
                         X.Arrear_AMNT,     
                         X.TypeArrear_CODE,     
                         X.ExcludeIrs_CODE,     
                         X.ExcludeRet_CODE,     
                         X.ExcludeVen_CODE,     
                         X.ExcludeSal_CODE,     
                         X.ExcludeFin_CODE,     
                         X.ExcludePas_CODE,     
                         X.ExcludeIns_CODE,         
                         COUNT(1) OVER() AS row_count,     
                         ROW_NUMBER() OVER(ORDER BY X.SubmitLast_DATE DESC,
											 X.TypeArrear_CODE, X.TypeTransaction_CODE) AS ORD_ROWNUM    
                    FROM(SELECT a.MemberMci_IDNO,         
                               a.SubmitLast_DATE,         
							   a.TypeTransaction_CODE,     
							   a.Arrear_AMNT,     
							   a.TypeArrear_CODE,     
							   a.ExcludeIrs_CODE,     
							   a.ExcludeRet_CODE,     
							   a.ExcludeVen_CODE,     
							   a.ExcludeSal_CODE,     
							   a.ExcludeFin_CODE,     
							   a.ExcludePas_CODE,     
							   a.ExcludeIns_CODE       
                          FROM FEDH_Y1 a    
                         WHERE a.MemberSsn_NUMB  = @An_MemberSsn_NUMB 
                           AND a.TypeArrear_CODE = ISNULL(@Ac_TypeArrear_CODE, a.TypeArrear_CODE) 
                           AND a.TaxYear_NUMB    = @An_TaxYear_NUMB 
                           AND a.RejectInd_INDC  = @Lc_No_INDC 
                           AND a.TransactionEventSeq_NUMB !=     
                                                           (    
                                                            SELECT MAX(d.TransactionEventSeq_NUMB)    
                                                              FROM FEDH_Y1 d    
                                                             WHERE d.MemberMci_IDNO  = a.MemberMci_IDNO 
                                                               AND d.TypeArrear_CODE = a.TypeArrear_CODE 
                                                               AND d.TaxYear_NUMB    = a.TaxYear_NUMB 
                                                    AND NOT EXISTS     
                                                              (    
                                                               SELECT 1    
                                                                 FROM HFEDH_Y1 l    
                                                                WHERE l.MemberMci_IDNO  = d.MemberMci_IDNO 
                                                                  AND l.TypeArrear_CODE = d.TypeArrear_CODE 
                                                                  AND l.TypeTransaction_CODE = d.TypeTransaction_CODE 
                                                                  AND l.SubmitLast_DATE = d.SubmitLast_DATE 
                                                                  AND l.TaxYear_NUMB    = d.TaxYear_NUMB 
                                                                  AND l.RejectInd_INDC  = @Lc_Yes_INDC    
                                                              )    
                                                           )    
                        UNION    
                       SELECT a.MemberMci_IDNO,         
                              a.SubmitLast_DATE,        
							  a.TypeTransaction_CODE,     
							  a.Arrear_AMNT,     
							  a.TypeArrear_CODE,     
						      a.ExcludeIrs_CODE,     
							  a.ExcludeRet_CODE,     
							  a.ExcludeVen_CODE,     
							  a.ExcludeSal_CODE,     
							  a.ExcludeFin_CODE,     
							  a.ExcludePas_CODE,     
							  a.ExcludeIns_CODE        
                         FROM HFEDH_Y1 a    
                        WHERE a.MemberSsn_NUMB  = @An_MemberSsn_NUMB 
                          AND a.TypeArrear_CODE = ISNULL(@Ac_TypeArrear_CODE, a.TypeArrear_CODE) 
                          AND a.TaxYear_NUMB    = @An_TaxYear_NUMB 
                          AND (a.RejectInd_INDC = @Lc_No_INDC 
                                AND NOT EXISTS     
                                         (  
                                          SELECT 1    
                                            FROM HFEDH_Y1 l    
                                           WHERE l.MemberMci_IDNO  = a.MemberMci_IDNO 
                                             AND l.TypeArrear_CODE = a.TypeArrear_CODE 
                                             AND l.TypeTransaction_CODE = a.TypeTransaction_CODE 
                                             AND l.SubmitLast_DATE = a.SubmitLast_DATE 
                                             AND l.TaxYear_NUMB    = a.TaxYear_NUMB 
                                             AND l.RejectInd_INDC  = @Lc_Yes_INDC    
                                         ) 
                                AND NOT EXISTS     
                                         (    
                                          SELECT 1    
                                            FROM FEDH_Y1 t    
                                           WHERE t.MemberMci_IDNO  = a.MemberMci_IDNO 
                                             AND t.TypeArrear_CODE = a.TypeArrear_CODE 
                                             AND t.TypeTransaction_CODE = a.TypeTransaction_CODE 
                                             AND t.SubmitLast_DATE = a.SubmitLast_DATE 
                                             AND t.TaxYear_NUMB    = a.TaxYear_NUMB 
                                             AND t.RejectInd_INDC  = @Lc_Yes_INDC   
                                         ))    
                       ) X    
                 ) Y    
            WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB    
           ) Z    
      WHERE Z.rnm >= @Ai_RowFrom_NUMB    
   ORDER BY RNM;    
    
END;  --END OF FEDH_RETRIEVE_S8

GO
