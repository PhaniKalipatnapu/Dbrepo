/****** Object:  StoredProcedure [dbo].[ISTX_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE  [dbo].[ISTX_RETRIEVE_S2]        
(      
     @Ad_SubmitLast_DATE	DATE, 
     @Ai_RowFrom_NUMB       INT=1,      
     @Ai_RowTo_NUMB         INT=10  ,
     @An_MemberMci_IDNO		NUMERIC(10,0)
)                      
AS      
      
/*      
 *     PROCEDURE NAME    : ISTX_RETRIEVE_S2      
 *     DESCRIPTION       : This procedure is used to display the soil information history details according to member_mci.In this procedure
                           we are showing the case level information using the table vistx.      
 *     DEVELOPED BY      : IMP TEAM      
 *     DEVELOPED ON      : 02-SEP-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
*/      
BEGIN      
   SELECT X1.Case_IDNO ,       
          X1.SubmitLast_DATE ,       
          X1.CountyFips_CODE ,       
          X1.Transaction_AMNT ,       
          X1.TypeArrear_CODE ,       
          X1.ExcludeState_CODE ,       
          X1.row_count AS RowCount_NUMB     
     FROM (      
           SELECT	X.Case_IDNO,       
					X.SubmitLast_DATE,       
					X.CountyFips_CODE,       
					X.Transaction_AMNT,       
					X.TypeArrear_CODE,      
					X.ExcludeState_CODE,       
					X.row_count,       
					X.ORD_ROWNUM AS rnm      
             FROM (      
                   SELECT   a.Case_IDNO,       
							a.SubmitLast_DATE,       
							a.CountyFips_CODE ,       
							a.Transaction_AMNT,       
							a.TypeArrear_CODE,      
							a.ExcludeState_CODE,       
							COUNT(1) OVER() AS row_count,       
							ROW_NUMBER() OVER(      
							ORDER BY a.Transaction_AMNT DESC) AS ORD_ROWNUM      
                     FROM   ISTX_Y1 a      
                    WHERE   a.MemberMci_IDNO	= @An_MemberMci_IDNO  
                      AND   a.SubmitLast_DATE	= @Ad_SubmitLast_DATE      
               )  X      
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB      
         )  X1      
      WHERE X1.rnm >= @Ai_RowFrom_NUMB      
ORDER BY RNM;           
END;--End of ISTX_RETRIEVE_S2   

GO
