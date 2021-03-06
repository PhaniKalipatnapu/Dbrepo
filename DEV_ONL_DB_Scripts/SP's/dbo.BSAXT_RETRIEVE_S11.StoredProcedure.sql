/****** Object:  StoredProcedure [dbo].[BSAXT_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[BSAXT_RETRIEVE_S11]
(
	@Ac_TypeComponent_CODE		CHAR(4),
	@Ai_Count_QNTY				INT OUTPUT
)
AS
 
/*                                                                                     
  *     PROCEDURE NAME    : BSAXT_RETRIEVE_S11                                            
  *     DESCRIPTION       : This procedure is used to lock or unlock cases belonging to a component in Worker screen function.  
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/09/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN 
 
		SET @Ai_Count_QNTY = NULL;
 
	DECLARE @Lc_SummaryN_CODE CHAR(1) = 'N',
			@Ld_High_DATE DATE = '12/31/9999';
 
	SELECT @Ai_Count_QNTY = COUNT(1)
	  FROM BSAXT_Y1 a
	 WHERE a.TypeComponent_CODE = @Ac_TypeComponent_CODE
	   AND a.SummaryGenerated_INDC = @Lc_SummaryN_CODE
	   AND a.EndValidity_DATE = @Ld_High_DATE;
 
END --End Of Procedure BSAXT_RETRIEVE_S11
 

GO
