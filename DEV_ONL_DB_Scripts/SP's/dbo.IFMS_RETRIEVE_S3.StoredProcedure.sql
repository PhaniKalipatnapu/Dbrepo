/****** Object:  StoredProcedure [dbo].[IFMS_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IFMS_RETRIEVE_S3]      
(    
     @Ac_TypeArrear_CODE		 CHAR(1),    
     @Ac_TypeTransaction_CODE	 CHAR(1),    
     @Ad_SubmitLast_DATE		 DATE  ,
     @Ai_RowFrom_NUMB            INT =1 ,    
     @Ai_RowTo_NUMB              INT=10  , 
     @An_MemberMci_IDNO		     NUMERIC(10,0)
 )         
AS    
    
/*    
 *     PROCEDURE NAME    : IFMS_RETRIEVE_S3    
 *     DESCRIPTION       : This procedure is used to display the federal tax offset information history details according to membermci.
                           In this procedure showing the case level information by the member.In vifms table we
                           storing the case level records for each member.    
 *     DEVELOPED BY      : IMP TEAM    
 *     DEVELOPED ON      : 02-SEP-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
*/    
BEGIN         
   SELECT X2.Case_IDNO ,     
          X2.SubmitLast_DATE ,
          X2.CountyFips_CODE, 
          X2.Transaction_AMNT ,     
          X2.TypeArrear_CODE ,     
          X2.ExcludeIrs_CODE ,     
          X2.ExcludeRet_CODE ,     
          X2.ExcludeVen_CODE ,
          X2.ExcludeSal_CODE ,     
          X2.ExcludeFin_CODE ,     
          X2.ExcludePas_CODE ,     
          X2.ExcludeIns_CODE ,    
          X2.row_count AS RowCount_NUMB    
    FROM (  
          SELECT X1.Case_IDNO,     
                 X1.SubmitLast_DATE,
                 X1.CountyFips_CODE,
                 X1.Transaction_AMNT,     
                 X1.TypeArrear_CODE,     
                 X1.ExcludeIrs_CODE,     
                 X1.ExcludeRet_CODE,     
                 X1.ExcludeVen_CODE,     
                 X1.ExcludeSal_CODE,     
                 X1.ExcludeFin_CODE,     
                 X1.ExcludePas_CODE,     
                 X1.ExcludeIns_CODE,   
                 X1.row_count,     
                 X1.ORD_ROWNUM AS rnm    
            FROM  (    
                   SELECT X.Case_IDNO,     
						  X.SubmitLast_DATE,  
						  X.CountyFips_CODE,   
						  X.Transaction_AMNT,     
						  X.TypeArrear_CODE,     
						  X.ExcludeIrs_CODE,     
						  X.ExcludeRet_CODE,     
						  X.ExcludeVen_CODE,     
						  X.ExcludeSal_CODE,     
						  X.ExcludeFin_CODE,     
						  X.ExcludePas_CODE,     
						  X.ExcludeIns_CODE,    
						  COUNT(1) OVER() AS row_count,     
						  ROW_NUMBER() OVER(    
                          ORDER BY X.Transaction_AMNT DESC) AS ORD_ROWNUM    
                  FROM (    
                        SELECT  a.Case_IDNO,     
								a.SubmitLast_DATE, 
								a.CountyFips_CODE,     
								a.Transaction_AMNT,     
								a.TypeArrear_CODE,     
								a.ExcludeIrs_CODE,     
								a.ExcludeRet_CODE,     
								a.ExcludeVen_CODE,     
								a.ExcludeSal_CODE,                                
								a.ExcludeFin_CODE,     
								a.ExcludePas_CODE,     
								a.ExcludeIns_CODE   
						   FROM IFMS_Y1 a    
                          WHERE  a.MemberMci_IDNO		= @An_MemberMci_IDNO     
                            AND  a.TypeArrear_CODE		= @Ac_TypeArrear_CODE      
                            AND  a.TypeTransaction_CODE = @Ac_TypeTransaction_CODE      
                            AND  a.SubmitLast_DATE		= @Ad_SubmitLast_DATE    
                         UNION    
                        SELECT  b.Case_IDNO,     
								b.SubmitLast_DATE,  
								b.CountyFips_CODE ,   
								b.Transaction_AMNT,     
								b.TypeArrear_CODE,     
								b.ExcludeIrs_CODE,     
								b.ExcludeRet_CODE,     
								b.ExcludeVen_CODE,     
								b.ExcludeSal_CODE,     
								b.ExcludeFin_CODE,     
								b.ExcludePas_CODE,     
								b.ExcludeIns_CODE   
                         FROM	HIFMS_Y1  b    
                        WHERE   b.MemberMci_IDNO		= @An_MemberMci_IDNO      
						  AND	b.TypeArrear_CODE		= @Ac_TypeArrear_CODE      
						  AND	b.TypeTransaction_CODE  = @Ac_TypeTransaction_CODE      
						  AND	b.SubmitLast_DATE		= @Ad_SubmitLast_DATE    
                     ) X    
               )  X1    
            WHERE X1.ORD_ROWNUM <= @Ai_RowTo_NUMB    
         ) X2    
      WHERE X2.rnm >= @Ai_RowFrom_NUMB    
ORDER BY RNM;         
END;--End of  IFMS_RETRIEVE_S3

GO
