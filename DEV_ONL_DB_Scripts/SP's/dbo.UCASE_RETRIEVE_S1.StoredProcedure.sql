/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S1] 
( 
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@An_SampleSize_QNTY		NUMERIC(7,0)
)
     
AS

/*
 *     PROCEDURE NAME    : UCASE_RETRIEVE_S1
 *     DESCRIPTION       : This procedure is used to retrive the cases that are satisfies the caseclosure conditions
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 01-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	
	DECLARE @Ld_High_DATE				DATE    = '12/31/9999',
			@Lc_TypeCaseH_CODE			CHAR(1) = 'H',
			@Lc_StatusCaseC_CODE		CHAR(1) = 'C',
			@Lc_StatusCaseO_CODE		CHAR(1) = 'O',
			@Lc_Space_TEXT				CHAR(1) = ' ',                  
			@Lc_RsnStatusCaseEX_CODE	CHAR(2) = 'EX';
	 
	SELECT x.Case_IDNO, 
		   x.StatusCase_CODE, 
		   x.TypeCase_CODE,
		   x.RespondInit_CODE, 
		   x.County_IDNO, 
		   x.Office_IDNO,
		   x.CaseTitle_NAME,
		   x.Worker_ID, 
		   x.RsnStatusCase_CODE AS RsnClosure_CODE, 
		   x.StatusCurrent_DATE AS Closed_DATE,
		   x.WorkerUpdate_ID, 
		   x.Update_DTTM, 
		   x.Row_NUMB,
		   x.RowCount_NUMB
	  FROM ( SELECT a.Case_IDNO, 
					a.StatusCase_CODE, 
					a.TypeCase_CODE,
					a.RespondInit_CODE, 
					a.County_IDNO, 
					a.Office_IDNO,
					(SELECT c.CaseTitle_NAME
					   FROM UDCKT_V1 c
					  WHERE c.File_ID = a.File_ID
						AND c.EndValidity_DATE = @Ld_High_DATE
				   )AS CaseTitle_NAME,
				   a.Worker_ID, 
				   a.RsnStatusCase_CODE, 
				   a.StatusCurrent_DATE,
				   a.WorkerUpdate_ID, 
				   a.Update_DTTM, 
				   ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
				   COUNT (1) OVER () AS RowCount_NUMB
			  FROM UCASE_V1 a
			 WHERE a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
			   AND a.StatusCase_CODE = @Lc_StatusCaseC_CODE
			   AND a.StatusCurrent_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
			   AND a.RsnStatusCase_CODE NOT IN(@Lc_RsnStatusCaseEX_CODE, @Lc_Space_TEXT)
			   AND EXISTS ( SELECT 1
							  FROM UCASE_V1 c
							 WHERE c.Case_IDNO = a.Case_IDNO
							   AND c.StatusCase_CODE = @Lc_StatusCaseO_CODE
							   AND c.BeginValidity_DATE <= a.StatusCurrent_DATE)
			   AND a.TransactionEventSeq_NUMB = (SELECT MIN (b.TransactionEventSeq_NUMB)
											  FROM UCASE_V1 b
											 WHERE b.Case_IDNO = a.Case_IDNO
											   AND b.TypeCase_CODE <> @Lc_TypeCaseH_CODE
											   AND b.StatusCase_CODE = a.StatusCase_CODE
											   AND b.StatusCurrent_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE))x
	WHERE X.Row_NUMB <= @An_SampleSize_QNTY; 
                  
END; -- END OF UCASE_RETRIEVE_S1
 

GO
