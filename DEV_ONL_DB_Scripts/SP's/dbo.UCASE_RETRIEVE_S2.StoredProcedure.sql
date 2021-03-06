/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S2] 
( 
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_StatusCurrent_DATE			DATE,
	@Ad_Opened_DATE					DATE OUTPUT
)
     
AS

/*
 *     PROCEDURE NAME    : UCASE_RETRIEVE_S2
 *     DESCRIPTION       : This procedure is used to retrieve the Open date.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	
	   SET @Ad_Opened_DATE = NULL;
	   
   DECLARE @Li_One_NUMB					INT		 = 1,
		   @Ld_Low_DATE					DATE     = '01/01/0001',
		   @Lc_StatusCaseC_CODE			CHAR(1)  = 'C',
		   @Lc_StatusCaseO_CODE			CHAR(1)  = 'O',
		   @Lc_WorkerIdConversion_CODE	CHAR(30) = 'CONVERSION';
	
	SELECT @Ad_Opened_DATE = d.Opened_DATE
	  FROM (SELECT CASE c.WorkerUpdate_ID 
					  WHEN @Lc_WorkerIdConversion_CODE 
						THEN c.Opened_DATE 
					  ELSE c.Update_DTTM
				   END Opened_DATE,
				   c.ORD_ROWNUM
			  FROM (SELECT a.WorkerUpdate_ID, 
						   a.Opened_DATE,
						   a.Update_DTTM,
						   ROW_NUMBER() OVER(ORDER BY a.TransactionEventSeq_NUMB) AS ORD_ROWNUM
					  FROM UCASE_V1 a
					 WHERE a.Case_IDNO = @An_Case_IDNO
					   AND a.StatusCase_CODE = @Lc_StatusCaseO_CODE
					   AND CASE a.WorkerUpdate_ID
							   WHEN @Lc_WorkerIdConversion_CODE 
								   THEN a.Opened_DATE     
							   ELSE a.Update_DTTM
						   END <= @Ad_StatusCurrent_DATE
					   AND CASE a.WorkerUpdate_ID
							   WHEN @Lc_WorkerIdConversion_CODE
									THEN a.Opened_DATE
							   ELSE a.Update_DTTM
						   END >= (SELECT ISNULL(MAX (StatusCurrent_DATE), @Ld_Low_DATE )
									 FROM UCASE_V1 b
									WHERE b.Case_IDNO = a.Case_IDNO
									  AND b.StatusCase_CODE = @Lc_StatusCaseC_CODE
									  AND b.Update_DTTM < @Ad_StatusCurrent_DATE)) c
			 WHERE c.ORD_ROWNUM <= @Li_One_NUMB)d;
                      
END;  --END OF UCASE_RETRIEVE_S2


GO
