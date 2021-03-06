/****** Object:  StoredProcedure [dbo].[BSASW_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[BSASW_RETRIEVE_S1]
(
	@Ac_TypeComponent_CODE	CHAR(4),
	@Ai_Count_QNTY			INT OUTPUT
)
AS
 
/*                                                                                     
  *     PROCEDURE NAME    : BSASW_RETRIEVE_S1                                            
  *     DESCRIPTION       : This procedure is used to check whether the summary is generated or not.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/22/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
 
BEGIN
 
		SET @Ai_Count_QNTY = NULL;
 
	DECLARE @Ld_High_DATE					DATE = '12/31/9999',
			@Lc_StatewideSummaryY_INDC		CHAR(1) = 'Y';
			
 
	  SELECT @Ai_Count_QNTY = COUNT(1)
        FROM BSASW_Y1 s
       WHERE s.TypeComponent_CODE =  @Ac_TypeComponent_CODE
         AND s.StatewideSummary_INDC = @Lc_StatewideSummaryY_INDC
         AND s.StatusRequest_DATE = @Ld_High_DATE;
 
END --End Of Procedure BSASW_RETRIEVE_S1
 

GO
