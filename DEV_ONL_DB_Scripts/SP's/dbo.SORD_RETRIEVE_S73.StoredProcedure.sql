/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S73]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S73] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_Begin_DATE				DATE,
	@Ad_End_DATE				DATE,
	@Ad_Order_DATE				DATE		OUTPUT,
	@Ac_InsuranceOrdered_CODE	CHAR(1)		OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S73
 *     DESCRIPTION       : This procedure is used to retrieve the Medical support details according to the given input.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	
	 SELECT @Ad_Order_DATE				= NULL,
			@Ac_InsuranceOrdered_CODE	= NULL;

				 SELECT TOP 1 @Ad_Order_DATE		= a.OrderIssued_DATE,
					@Ac_InsuranceOrdered_CODE	= a.InsOrdered_CODE
			   FROM SORD_Y1 a 
			  WHERE a.Case_IDNO			= @An_Case_IDNO
			    AND a.OrderEnt_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE;
                      
END;  --END OF SORD_RETRIEVE_S73


GO
