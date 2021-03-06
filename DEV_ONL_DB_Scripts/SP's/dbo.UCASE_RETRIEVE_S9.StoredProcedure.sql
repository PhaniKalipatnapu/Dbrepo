/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S9] 
(
	@An_Case_IDNO  NUMERIC(6,0),
	@Ai_Count_QNTY INT OUTPUT
)
AS
 
/*                                                                                   
  *     PROCEDURE NAME    : UCASE_RETRIEVE_S9                                          
  *     DESCRIPTION       : This procedure is used to check the whether the closed case is exits or not.
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 03/07/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
 
BEGIN
 
		SET @Ai_Count_QNTY = NULL;
 
	DECLARE @Lc_StatusCaseC_CODE CHAR(1) = 'C';
 
	 SELECT @Ai_Count_QNTY = COUNT (1)
	   FROM UCASE_V1 C
	  WHERE C.Case_IDNO			= @An_Case_IDNO
	    AND C.StatusCase_CODE   = @Lc_StatusCaseC_CODE;
	 
END --End Of Procedure UCASE_RETRIEVE_S9
 

GO
