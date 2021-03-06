/****** Object:  StoredProcedure [dbo].[BSAOE_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAOE_RETRIEVE_S4] 
(
	@An_EfficiencyRate_NUMB		NUMERIC(3,0)	OUTPUT
)
AS 
/*
 *     PROCEDURE NAME    : BSAOE_RETRIEVE_S4
 *     DESCRIPTION       : Retrieves the efficiency rate of Previous year establishment of paternity & child support order details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
 
		SET @An_EfficiencyRate_NUMB  = NULL;
		
	DECLARE @Li_One_NUMB			INT     = 1,
		    @Li_Zero_NUMB			INT     = 0,
		    @Li_Hundred_NUMB		INT		= 100,
			@Lc_Yes_INDC			CHAR(1) = 'Y',
		    @Ld_High_DATE			DATE    = '12/31/9999';
			  
	SELECT @An_EfficiencyRate_NUMB = CEILING(ROUND(((CONVERT(DECIMAL(5),SUM(c.Compliance_INDC)) * @Li_Hundred_NUMB ) / CONVERT(DECIMAL(5),COUNT(c.Case_IDNO))),@Li_Zero_NUMB))
	  FROM (SELECT a.Case_IDNO,
				   CASE
					  WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
						ELSE @Li_Zero_NUMB
				   END AS Compliance_INDC
			  FROM BSACS_Y1 b JOIN BSAOE_Y1 a
				ON b.Case_IDNO			= a.Case_IDNO
			   AND b.Review_DATE		= a.Review_DATE
			 WHERE a.EndValidity_DATE	= @Ld_High_DATE) c;

END  --END OF BSAOE_RETRIEVE_S4


GO
