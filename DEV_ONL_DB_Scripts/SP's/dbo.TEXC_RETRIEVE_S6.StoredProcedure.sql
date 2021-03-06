/****** Object:  StoredProcedure [dbo].[TEXC_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROCEDURE [dbo].[TEXC_RETRIEVE_S6]    
    (
      @An_County_IDNO	NUMERIC(3,0),
      @Ai_RowFrom_NUMB	INT=1,  
      @Ai_RowTo_NUMB    INT=10
    )                 
AS  
  
/*  
 *     PROCEDURE NAME    : TEXC_RETRIEVE_S6  
 *     DESCRIPTION       : Retrieves manual exclusions report for both Federal and State.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 03-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN 
  
      DECLARE @Li_Zero_NUMB             INT     = 0,
			  @Lc_Yes_INDC				CHAR(1) = 'Y',
              @Lc_No_INDC				CHAR(1) = 'N',
              @Lc_SystemExcluded_INDC	CHAR(1) = 'S',
              @Ld_High_DATE				DATE    = '12/31/9999';  
     
      SELECT  X.Case_IDNO,   
			  X.Effective_DATE,   
			  X.County_IDNO,   
			  X.ExcludeIrs_INDC,   
			  X.ExcludeFin_INDC,   
			  X.ExcludePas_INDC,   
			  X.ExcludeRet_INDC,   
			  X.ExcludeSal_INDC,      
			  X.ExcludeVen_INDC,   
			  X.ExcludeIns_INDC,   
			  X.ExcludeState_CODE,   
			  X.Row_NUMB ,   
			  X.RowCount_NUMB  
        FROM( SELECT a.Case_IDNO,   
					 a.Effective_DATE,   
					 b.County_IDNO,   
					 a.ExcludeIrs_INDC,   
					 a.ExcludeFin_INDC,   
					 a.ExcludePas_INDC,   
					 a.ExcludeRet_INDC,   
					 a.ExcludeSal_INDC,      
					 a.ExcludeVen_INDC,   
					 a.ExcludeIns_INDC,   
					 a.ExcludeState_CODE,   
					 COUNT(1) OVER() AS RowCount_NUMB,   
					 ROW_NUMBER() OVER(ORDER BY a.Case_IDNO) AS Row_NUMB  
				FROM TEXC_Y1 a JOIN CASE_Y1 b  
                  ON a.Case_IDNO   = b.Case_IDNO 
               WHERE b.County_IDNO = @An_County_IDNO 
                 AND (a.ExcludeIrs_INDC        = @Lc_Yes_INDC 
                       OR  a.ExcludePas_INDC   = @Lc_Yes_INDC 
                       OR  a.ExcludeFin_INDC   = @Lc_Yes_INDC 
                       OR  a.ExcludeIns_INDC   = @Lc_Yes_INDC 
                       OR  a.ExcludeVen_INDC   = @Lc_Yes_INDC 
                       OR  a.ExcludeRet_INDC   = @Lc_Yes_INDC 
                       OR  a.ExcludeSal_INDC   = @Lc_Yes_INDC 
                       OR  a.ExcludeState_CODE = @Lc_Yes_INDC 
						) 
				 AND (a.ExcludeIrs_INDC     IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC) 
                      OR a.ExcludePas_INDC  IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC) 
                      OR a.ExcludeFin_INDC  IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC) 
                      OR a.ExcludeIns_INDC  IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC) 
                      OR a.ExcludeVen_INDC  IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC)
                      OR a.ExcludeRet_INDC  IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC) 
                      OR a.ExcludeSal_INDC  IN( @Lc_No_INDC,@Lc_SystemExcluded_INDC)
                      OR a.ExcludeState_CODE IN(@Lc_No_INDC,@Lc_SystemExcluded_INDC)
                        ) 
                     AND a.EndValidity_DATE  = @Ld_High_DATE  
                 ) X  
            WHERE ((X.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB)
                   OR(@Ai_RowFrom_NUMB = @Li_Zero_NUMB 
                       AND @Ai_RowTo_NUMB = @Li_Zero_NUMB))  
       ORDER BY Row_NUMB; 
END;  --END OF TEXC_RETRIEVE_S6

GO
