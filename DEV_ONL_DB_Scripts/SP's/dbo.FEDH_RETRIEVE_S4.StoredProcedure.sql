/****** Object:  StoredProcedure [dbo].[FEDH_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
 CREATE PROCEDURE [dbo].[FEDH_RETRIEVE_S4]        
    (  
     @Ac_TypeArrear_CODE	CHAR(1),      
     @An_TaxYear_NUMB		NUMERIC(4,0),      
     @An_MemberSsn_NUMB		NUMERIC(9,0) 
    )                    
AS      
      
/*      
 *     PROCEDURE NAME    : FEDH_RETRIEVE_S4      
 *     DESCRIPTION       : Retrive federal tax offset information for the latest transaction & arrear type using memberssn_numb.      
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
               
      SELECT h.MemberMci_IDNO,          
             h.SubmitLast_DATE,              
             h.TypeTransaction_CODE,       
             h.Arrear_AMNT,       
             h.TypeArrear_CODE,       
             h.ExcludeIrs_CODE,       
             h.ExcludeRet_CODE,       
             h.ExcludeVen_CODE,       
             h.ExcludeSal_CODE,       
             h.ExcludeFin_CODE,       
             h.ExcludePas_CODE,       
             h.ExcludeIns_CODE            
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
                AND a.TransactionEventSeq_NUMB =       
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
               AND(a.RejectInd_INDC  = @Lc_No_INDC 
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
							 )) 
    AND NOT EXISTS       
                 (      
                  SELECT 1      
                    FROM FEDH_Y1 b      
                   WHERE b.MemberMci_IDNO  = a.MemberMci_IDNO 
                     AND b.TypeArrear_CODE = a.TypeArrear_CODE 
                     AND b.TaxYear_NUMB    = a.TaxYear_NUMB 
                     AND b.RejectInd_INDC  = @Lc_No_INDC 
          AND NOT EXISTS       
                       (      
                        SELECT 1      
                          FROM HFEDH_Y1 j      
                         WHERE j.MemberMci_IDNO  = b.MemberMci_IDNO
                           AND j.TypeArrear_CODE = b.TypeArrear_CODE 
                           AND j.TypeTransaction_CODE = b.TypeTransaction_CODE 
                           AND j.SubmitLast_DATE = b.SubmitLast_DATE 
                           AND j.TaxYear_NUMB    = b.TaxYear_NUMB 
                           AND j.RejectInd_INDC  = @Lc_Yes_INDC      
                       )      
                 ) 
    AND NOT EXISTS       
                 (      
                  SELECT 1      
                    FROM FEDH_Y1 f      
                   WHERE f.MemberMci_IDNO  = a.MemberMci_IDNO 
                     AND f.TypeArrear_CODE = a.TypeArrear_CODE 
                     AND f.TaxYear_NUMB    = a.TaxYear_NUMB 
                     AND f.RejectInd_INDC  = @Lc_No_INDC      
                 ) 
               AND a.TransactionEventSeq_NUMB =       
                                               (      
                                                SELECT MAX(d.TransactionEventSeq_NUMB)      
                                                  FROM HFEDH_Y1 d      
                                                 WHERE d.MemberMci_IDNO  = a.MemberMci_IDNO 
                                                   AND d.TypeArrear_CODE = a.TypeArrear_CODE 
                                                   AND d.TaxYear_NUMB    = a.TaxYear_NUMB 
                                        AND NOT EXISTS       
                                                     (      
                                                      SELECT 1      
                                                        FROM HFEDH_Y1 k      
                                                       WHERE k.MemberMci_IDNO  = d.MemberMci_IDNO 
                                                         AND k.TypeArrear_CODE = d.TypeArrear_CODE 
                                                         AND k.TypeTransaction_CODE = d.TypeTransaction_CODE 
                                                         AND k.SubmitLast_DATE = d.SubmitLast_DATE 
                                                         AND k.TaxYear_NUMB    = d.TaxYear_NUMB 
                                                         AND k.RejectInd_INDC  = @Lc_Yes_INDC      
                                                      ) 
                                        AND NOT EXISTS       
                                                     (      
                                                      SELECT 1      
                                                        FROM FEDH_Y1 c      
                                                       WHERE c.MemberMci_IDNO  = d.MemberMci_IDNO 
                                                         AND c.TypeArrear_CODE = d.TypeArrear_CODE 
                                                         AND c.TypeTransaction_CODE = d.TypeTransaction_CODE 
                                                         AND c.SubmitLast_DATE = d.SubmitLast_DATE 
                                                         AND c.TaxYear_NUMB    = d.TaxYear_NUMB 
                                                         AND c.RejectInd_INDC  = @Lc_Yes_INDC      
                                                      )      
                                               )      
            ) h      
    ORDER BY SubmitLast_DATE DESC, TypeArrear_CODE, TypeTransaction_CODE;      
      
END;   --END OF FEDH_RETRIEVE_S4   

GO
