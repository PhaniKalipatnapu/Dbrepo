/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S4] 
( 
	@Ad_ReviewFrom_DATE			DATE,
	@Ad_ReviewTo_DATE			DATE,
	@An_SampleSize_QNTY			NUMERIC(7,0)
)   
AS
/*
 *     PROCEDURE NAME    : UCASE_RETRIEVE_S4
 *     DESCRIPTION       : This procedure is used to retrieve the case details according to Enforcement of support order.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	

	DECLARE @Li_Zero_NUMB					SMALLINT	= 0,
			@Li_One_NUMB					INT			= 1,
			@Ld_High_DATE					DATE		= '12/31/9999',
			@Lc_TypeCaseH_CODE				CHAR(1)     = 'H',
		    @Lc_StatusCaseO_CODE			CHAR(1)     = 'O';
		    
	 SELECT x.Case_IDNO, 
			x.StatusCase_CODE, 
			x.TypeCase_CODE, 
			x.RespondInit_CODE,
            x.County_IDNO, 
            x.Office_IDNO, 
            x.CaseTitle_NAME, 
            x.Worker_ID,
            x.RsnStatusCase_CODE, 
            x.BeginValidity_DATE, 
            x.WorkerUpdate_ID, 
            x.Update_DTTM,
            x.Row_NUMB,
            x.RowCount_NUMB
      FROM ( SELECT b.Case_IDNO, 
					b.StatusCase_CODE, 
					b.TypeCase_CODE, 
					b.RespondInit_CODE,
					b.County_IDNO, 
					b.Office_IDNO, 
					b.CaseTitle_NAME, 
					b.Worker_ID,
					b.RsnStatusCase_CODE, 
					b.BeginValidity_DATE, 
					b.WorkerUpdate_ID, 
					b.Update_DTTM,
					ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
					COUNT (1) OVER () AS RowCount_NUMB
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
							 ) AS CaseTitle_NAME,
							 a.Worker_ID, 
							 a.RsnStatusCase_CODE,
							 a.BeginValidity_DATE, 
							 a.WorkerUpdate_ID, 
							 a.Update_DTTM, 
							 ROW_NUMBER () OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB DESC) CaseRow_NUMB
						FROM UCASE_V1 a 
					   WHERE a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
						 AND a.StatusCase_CODE = @Lc_StatusCaseO_CODE
						 AND a.BeginValidity_DATE <= @Ad_ReviewTo_DATE
						 AND a.EndValidity_DATE > @Ad_ReviewFrom_DATE
						 AND EXISTS(SELECT 1
							   FROM OBLE_Y1 x
							  WHERE x.Case_IDNO = a.Case_IDNO
								AND x.EndValidity_DATE = @Ld_High_DATE
								AND x.BeginObligation_DATE <= @Ad_ReviewTo_DATE
								AND x.EndObligation_DATE > @Ad_ReviewFrom_DATE
								AND (x.Periodic_AMNT > @Li_Zero_NUMB
								 OR ExpectToPay_AMNT > @Li_Zero_NUMB))
					) b
			 WHERE CaseRow_NUMB = @Li_One_NUMB)x
  WHERE X.Row_NUMB <= @An_SampleSize_QNTY;
                      
END;  --END OF UCASE_RETRIEVE_S4


GO
