/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S3] 
( 
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@An_SampleSize_QNTY		NUMERIC(7,0)
)  
AS
/*
 *     PROCEDURE NAME    : UCASE_RETRIEVE_S3
 *     DESCRIPTION       : This is used to retrieve the cases corresponding to the establishment of paternity and support order.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 03-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	
    DECLARE @Li_One_NUMB					INT		= 1,
		    @Ld_High_DATE					DATE    = '12/31/9999',
		    @Lc_StatusCaseO_CODE			CHAR(1) = 'O',
		    @Lc_TypeCaseH_CODE				CHAR(1) = 'H';
		    
	 SELECT x.Case_IDNO, 
			x.StatusCase_CODE, 
			x.TypeCase_CODE,
			x.RespondInit_CODE, 
			x.County_IDNO, 
			x.Office_IDNO,
			x.CaseTitle_NAME, 
			x.Worker_ID,
			x.RsnStatusCase_CODE, 
			x.Opened_DATE,
			x.WorkerUpdate_ID, 
			x.Update_DTTM,
			x.Row_NUMB,
			x.RowCount_NUMB
	   FROM (SELECT b.Case_IDNO, 
					b.StatusCase_CODE, 
					b.TypeCase_CODE,
					b.RespondInit_CODE, 
					b.County_IDNO, 
					b.Office_IDNO,
					b.CaseTitle_NAME, 
					b.Worker_ID,
					b.RsnStatusCase_CODE, 
					b.Opened_DATE,
					b.WorkerUpdate_ID, 
					b.Update_DTTM,
					ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
					COUNT (1) OVER () AS RowCount_NUMB
			   FROM (SELECT a.Case_IDNO, 
							a.StatusCase_CODE,
							a.TypeCase_CODE,
							a.RespondInit_CODE,
							a.County_IDNO, 
							a.Office_IDNO,
							(SELECT c.CaseTitle_NAME
							   FROM UDCKT_V1 c 
							  WHERE c.File_ID = a.File_ID
								AND c.EndValidity_DATE = @Ld_High_DATE
							 ) AS CaseTitle_NAME,
							a.Worker_ID,
							a.RsnStatusCase_CODE,
							a.Opened_DATE,
							a.File_ID,
							a.WorkerUpdate_ID,
							a.Update_DTTM,
							ROW_NUMBER () OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB)AS CaseRow_NUMB
					   FROM UCASE_V1 a
					  WHERE a.StatusCase_CODE = @Lc_StatusCaseO_CODE
						AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
						AND a.Opened_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
					) b
			  WHERE CaseRow_NUMB = @Li_One_NUMB)x
   WHERE X.Row_NUMB <= @An_SampleSize_QNTY;
	                      
END;  --END OF UCASE_RETRIEVE_S3


GO
