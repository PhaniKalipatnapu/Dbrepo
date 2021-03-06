/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S77]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S77]
(
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_LastReview_DATE			DATE OUTPUT,
	@Ad_OrderIssued_DATE		DATE OUTPUT
)
AS
 
/*                                                                                   
  *     PROCEDURE NAME    : SORD_RETRIEVE_S77                                          
  *     DESCRIPTION       : Retrieves the last review date and order issued date for case.
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 03/07/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
BEGIN
 
	 SELECT @Ad_LastReview_DATE = NULL;
	 SELECT @Ad_OrderIssued_DATE = NULL;
 
	DECLARE @Ld_High_DATE	DATE = '12/31/9999',
			@Ld_Low_DATE	DATE = '01/01/0001';
			 
	SELECT @Ad_LastReview_DATE = ISNULL(MAX(D.LastReview_DATE), @Ld_Low_DATE),
		@Ad_OrderIssued_DATE = ISNULL(MAX(OrderIssued_DATE), @Ld_Low_DATE)
	FROM  SORD_Y1 D 
	WHERE D.Case_IDNO  = @An_Case_IDNO
		AND D.EndValidity_DATE = @Ld_High_DATE;

 
END --End Of Procedure SORD_RETRIEVE_S77
 

GO
