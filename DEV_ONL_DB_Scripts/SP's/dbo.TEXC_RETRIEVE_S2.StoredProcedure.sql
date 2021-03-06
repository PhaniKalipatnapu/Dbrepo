/****** Object:  StoredProcedure [dbo].[TEXC_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[TEXC_RETRIEVE_S2]    
    (
     @Ai_RowFrom_NUMB   INT=1,  
     @Ai_RowTo_NUMB     INT=10,  
     @An_Case_IDNO		NUMERIC(6,0),  
     @An_MemberMci_IDNO	NUMERIC(10,0)
    )                
AS  
  
/*  
 *     PROCEDURE NAME    : TEXC_RETRIEVE_S2  
 *     DESCRIPTION       : Retrieves exclusion code for the respective membermci_idno & case_idno.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 03-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
 
      SELECT K.MemberMci_IDNO,   
             K.Case_IDNO,   
             K.Effective_DATE,   
             K.End_DATE,   
             K.Transaction_DATE,   
             K.ExcludeIrs_INDC,   
             K.ExcludeFin_INDC,   
             K.ExcludePas_INDC,   
             K.ExcludeRet_INDC,   
             K.ExcludeSal_INDC,   
             K.ExcludeVen_INDC,   
             K.ExcludeIns_INDC,   
             K.ExcludeState_CODE,   
             K.WorkerUpdate_ID,   
             K.TransactionEventSeq_NUMB,   
             K.row_count AS RowCount_NUMB  
        FROM (  SELECT  X.MemberMci_IDNO,   
						X.Case_IDNO,   
						X.Effective_DATE,   
						X.End_DATE,   
						X.Transaction_DATE,   
						X.ExcludeIrs_INDC,   
						X.ExcludeFin_INDC,   
						X.ExcludePas_INDC,   
						X.ExcludeRet_INDC,   
						X.ExcludeSal_INDC,      
						X.ExcludeVen_INDC,   
						X.ExcludeIns_INDC,   
						X.ExcludeState_CODE,   
						X.WorkerUpdate_ID,   
						X.TransactionEventSeq_NUMB,   
						X.row_count,   
						X.ORD_ROWNUM AS rnm  
				   FROM (  SELECT T.MemberMci_IDNO,   
									T.Case_IDNO,   
									T.Effective_DATE,   
									T.End_DATE,   
									T.Update_DTTM AS Transaction_DATE,   
									T.ExcludeIrs_INDC,   
									T.ExcludeFin_INDC,   
									T.ExcludePas_INDC,   
									T.ExcludeRet_INDC,   
									T.ExcludeSal_INDC,    
									T.ExcludeVen_INDC,   
									T.ExcludeIns_INDC,   
									T.ExcludeState_CODE,   
									T.WorkerUpdate_ID,   
									T.TransactionEventSeq_NUMB,   
									COUNT(1) OVER() AS row_count,   
									ROW_NUMBER() OVER(  
									ORDER BY T.Update_DTTM DESC, T.TransactionEventSeq_NUMB DESC) AS ORD_ROWNUM  
					  FROM TEXC_Y1 T
                     WHERE T.MemberMci_IDNO = @An_MemberMci_IDNO 
                       AND T.Case_IDNO      = @An_Case_IDNO  
                  ) X  
             WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB  
           ) K  
      WHERE K.rnm >= @Ai_RowFrom_NUMB  
   ORDER BY RNM; 
END;  --END OF TEXC_RETRIEVE_S2

GO
