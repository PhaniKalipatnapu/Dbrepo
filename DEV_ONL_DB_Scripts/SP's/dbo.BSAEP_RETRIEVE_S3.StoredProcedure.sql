/****** Object:  StoredProcedure [dbo].[BSAEP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAEP_RETRIEVE_S3] 
AS 
/*
 *     PROCEDURE NAME    : BSAEP_RETRIEVE_S3
 *     DESCRIPTION       : Retrieves the effective rate of Expedited Process details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
   DECLARE @Li_One_NUMB			INT     = 1,
		   @Li_Zero_NUMB		INT     = 0,
		   @Li_Hundred_NUMB		INT		= 100,
		   @Lc_Yes_INDC			CHAR(1) = 'Y',
		   @Ld_High_DATE		DATE    = '12/31/9999';    

	SELECT d.County_IDNO, 
		   d.Row_NUMB,
		   d.County_NAME,
		   d.CaseReviewed_QNTY,
		   d.SixMonthCompliance_QNTY, 
		   d.TwelveMonthCompliance_QNTY, 
		   d.EfficiencyRate_NUMB
	  FROM (SELECT c.County_IDNO, 
				   c.County_NAME,
				   COUNT(c.Case_IDNO) AS CaseReviewed_QNTY,
				   SUM(c.SixMonthCompliance_QNTY) AS SixMonthCompliance_QNTY,
				   SUM(c.TwelveMonthCompliance_QNTY) AS TwelveMonthCompliance_QNTY,
				   CEILING(ROUND(((CONVERT(DECIMAL(5),SUM(c.Compliance_INDC)) * @Li_Hundred_NUMB ) / CONVERT(DECIMAL(5),COUNT(c.Case_IDNO))),@Li_Zero_NUMB)) AS EfficiencyRate_NUMB,
				   ROW_NUMBER() OVER(PARTITION BY c.County_IDNO ORDER BY c.County_NAME) Row_NUMB
			  FROM (SELECT b.County_IDNO, 
						   b.County_Name,
						   a.Case_IDNO,
						   CASE
							  WHEN a.QuestionEP1_INDC  = @Lc_Yes_INDC THEN @Li_One_NUMB
							  ELSE @Li_Zero_NUMB
						    END AS SixMonthCompliance_QNTY,
						    CASE
								WHEN a.QuestionEP2_INDC  = @Lc_Yes_INDC  AND QuestionEP1_INDC <> @Lc_Yes_INDC 
									THEN @Li_One_NUMB
								ELSE @Li_Zero_NUMB
							END TwelveMonthCompliance_QNTY,
						   CASE
							  WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
							  ELSE @Li_Zero_NUMB
						   END AS Compliance_INDC
					  FROM BSACS_Y1 b  JOIN  BSAEP_Y1 a
					    ON b.Case_IDNO			= a.Case_IDNO
					   AND b.Review_DATE		= a.Review_DATE
					 WHERE a.EndValidity_DATE	= @Ld_High_DATE) c 
				  GROUP BY c.County_IDNO, c.County_NAME )d ;
	
END -- END OF BSAEP_RETRIEVE_S3


GO
