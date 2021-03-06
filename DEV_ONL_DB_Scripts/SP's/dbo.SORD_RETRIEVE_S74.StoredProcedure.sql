/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S74]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S74]
(
	@An_Case_IDNO			NUMERIC(6,0),
	@Ad_ReviewFrom_DATE		DATE,
	@Ad_ReviewTo_DATE		DATE,
	@Ac_Iiwo_CODE			CHAR(2) OUTPUT,
	@Ad_OrderIssued_DATE	DATE	OUTPUT
)
AS
 
/*																		              
  *     PROCEDURE NAME    : SORD_RETRIEVE_S74                                          
  *     DESCRIPTION       : This procedure is used to retrieve the Income Withholding details.
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 03/07/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
BEGIN

	 SELECT @Ac_Iiwo_CODE			= NULL,
			@Ad_OrderIssued_DATE	= NULL;

	DECLARE @Lc_TypeWelfareA_CODE	CHAR(1) = 'A';
 
	 SELECT @Ac_Iiwo_CODE = s.Iiwo_CODE,
			@Ad_OrderIssued_DATE = s.OrderIssued_DATE
	   FROM SORD_Y1 s JOIN MHIS_Y1 m
		 ON s.Case_IDNO			  = m.Case_IDNO
	  WHERE s.Case_IDNO			  = @An_Case_IDNO
		AND s.OrderEffective_DATE  >= @Ad_ReviewFrom_DATE
		AND s.OrderEffective_DATE  <= @Ad_ReviewTo_DATE
		AND m.TypeWelfare_CODE	  = @Lc_TypeWelfareA_CODE;
 
END --End Of Procedure SORD_RETRIEVE_S74
 

GO
