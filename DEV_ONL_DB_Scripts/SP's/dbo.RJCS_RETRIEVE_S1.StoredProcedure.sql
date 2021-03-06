/****** Object:  StoredProcedure [dbo].[RJCS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[RJCS_RETRIEVE_S1] (
			 @An_MemberMci_IDNO		 NUMERIC(10,0),
			 @Ac_TypeArrear_CODE	 CHAR(1),    
			 @Ai_RowFrom_NUMB        INT = 1,    
			 @Ai_RowTo_NUMB          INT =10                
				)              
AS                                                                          
/*    
 *     PROCEDURE NAME    : RJCS_RETRIEVE_S1    
 *     DESCRIPTION       : This Procedure is used to populate the rejected record history details.    
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN    
			DECLARE @Ld_High_DATE DATE  =  '12/31/9999';
            
			 SELECT Y.Case_IDNO, 
					Y.Arrear_AMNT,
					Y.ExcludeIrs_CODE,
					Y.ExcludeAdm_CODE,
					Y.ExcludeFin_CODE,
					Y.ExcludePas_CODE,
					Y.ExcludeRet_CODE,
					Y.ExcludeSal_CODE,
					Y.ExcludeDebt_CODE,
					Y.ExcludeVen_CODE,
					Y.ExcludeIns_CODE, 
					Y.County_IDNO,
					Y.row_count AS RowCount_NUMB
			   FROM	(
					 SELECT X.Case_IDNO, 
							X.Arrear_AMNT, 
							X.ExcludeIrs_CODE,
							X.ExcludeAdm_CODE, 
							X.ExcludeFin_CODE, 
							X.ExcludePas_CODE,
							X.ExcludeRet_CODE, 
							X.ExcludeSal_CODE, 
							X.ExcludeDebt_CODE,
							X.ExcludeVen_CODE, 
							X.ExcludeIns_CODE, 
							X.County_IDNO,
							X.ORD_ROWNUM AS RNM, 
							X.row_count
					   FROM (
							 SELECT a.Case_IDNO, 
									a.Arrear_AMNT, 
									a.ExcludeIrs_CODE,
									a.ExcludeAdm_CODE, 
									a.ExcludeFin_CODE,
									a.ExcludePas_CODE, 
									a.ExcludeRet_CODE,
									a.ExcludeSal_CODE, 
									a.ExcludeDebt_CODE,
									a.ExcludeVen_CODE, 
									a.ExcludeIns_CODE, 
									a.County_IDNO,
									a.Update_DTTM, 
									COUNT (1) OVER () AS row_count,
									ROW_NUMBER () OVER (ORDER BY a.Update_DTTM DESC) AS ORD_ROWNUM
							   FROM RJCS_Y1 a
							  WHERE a.MemberMci_IDNO	= @An_MemberMci_IDNO
								AND a.TypeArrear_CODE	= @Ac_TypeArrear_CODE
								AND a.EndValidity_DATE = @Ld_High_DATE) X
					  WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) Y
			  WHERE Y.RNM >= @Ai_RowFrom_NUMB 
		   ORDER BY RNM;

END;   --End of RJCS_RETRIEVE_S1.    

GO
