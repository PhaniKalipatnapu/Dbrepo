/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S175]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S175] 
( 
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@An_SampleSize_QNTY		NUMERIC(7,0)
)   
AS
/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S175
 *     DESCRIPTION       : This procedure is used to get the case details for Medical support 
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	

   DECLARE @Li_Zero_NUMB						INT = 0,
		   @Ld_High_DATE						DATE		 = '12/31/9999',
		   @Lc_TypeCaseH_CODE					CHAR(1)      = 'H',
		   @Lc_StatusCaseO_CODE					CHAR(1)      = 'O',
		   @Lc_TypeOrderJ_CODE					CHAR(1)		 = 'J',
		   @Lc_InsOrderedN_CODE					CHAR(1)		 = 'N',
           @Lc_TypeDebtCS_CODE					CHAR(2)		 = 'CS',
           @Lc_TypeDebtMS_CODE					CHAR(2)		 = 'MS',
           @Lc_WorkerUpdateCONVERSION_CODE		CHAR(10) = 'CONVERSION';
		   
	  SELECT m.Case_IDNO, 
			 m.StatusCase_CODE, 
			 m.TypeCase_CODE,
			 m.RespondInit_CODE, 
			 m.County_IDNO, 
			 m.Office_IDNO,
             m.CaseTitle_NAME,
             m.Worker_ID, 
             m.RsnStatusCase_CODE, 
             m.Opened_DATE, 
             m.WorkerUpdate_ID, 
             m.Update_DTTM,
             m.Row_NUMB,
             m.RowCount_NUMB
       FROM (SELECT a.Case_IDNO, 
					a.StatusCase_CODE, 
					a.TypeCase_CODE,
					a.RespondInit_CODE, 
					a.County_IDNO, 
					a.Office_IDNO,
					(SELECT c.CaseTitle_NAME
					   FROM UDCKT_V1 c
					  WHERE c.File_ID = a.File_ID
						AND c.EndValidity_DATE = @Ld_High_DATE) AS CaseTitle_NAME,
					 a.Worker_ID, 
					 a.RsnStatusCase_CODE, 
					 a.Opened_DATE, 
					 a.WorkerUpdate_ID, 
					 a.Update_DTTM,
					 ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
					 COUNT (1) OVER () AS RowCount_NUMB
				FROM UCASE_V1 a
			   WHERE EXISTS (SELECT 1
							   FROM UCASE_V1 z
							  WHERE z.Case_IDNO = a.Case_IDNO
								AND z.TypeCase_CODE <> @Lc_TypeCaseH_CODE
								AND z.StatusCase_CODE = @Lc_StatusCaseO_CODE
								AND z.EndValidity_DATE > @Ad_Begin_DATE
								AND z.BeginValidity_DATE <= @Ad_End_DATE
								AND EXISTS(SELECT 1
											 FROM SORD_Y1 x JOIN OBLE_Y1 b
											   ON b.Case_IDNO = x.Case_IDNO
											WHERE x.Case_IDNO = z.Case_IDNO
											  AND x.OrderEnd_DATE = @Ld_High_DATE 
											  AND x.TypeOrder_CODE = @Lc_TypeOrderJ_CODE
											  AND x.EndValidity_DATE = @Ld_High_DATE
											  AND x.InsOrdered_CODE <> @Lc_InsOrderedN_CODE
											  AND b.BeginObligation_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE	
											  AND b.TypeDebt_CODE IN (@Lc_TypeDebtCS_CODE, @Lc_TypeDebtMS_CODE)		
											  AND ((b.Periodic_AMNT >  @Li_Zero_NUMB 
												   AND b.ExpectToPay_AMNT > = @Li_Zero_NUMB) 
													OR (b.Periodic_AMNT = @Li_Zero_NUMB 
														AND b.ExpectToPay_AMNT = @Li_Zero_NUMB))
											  AND b.EndValidity_DATE = @Ld_High_DATE
											  AND x.EventGlobalBeginSeq_NUMB =(SELECT MIN (s.EventGlobalBeginSeq_NUMB)
																FROM SORD_Y1 s
															   WHERE s.Case_IDNO = x.Case_IDNO
																 AND s.OrderSeq_NUMB = x.OrderSeq_NUMB
																 AND CASE a.WorkerUpdate_ID
																			 WHEN @Lc_WorkerUpdateCONVERSION_CODE 
																				THEN s.OrderEffective_DATE
																			 ELSE s.BeginValidity_DATE
																	  END >= CASE a.WorkerUpdate_ID
																					WHEN @Lc_WorkerUpdateCONVERSION_CODE  
																						THEN a.Opened_DATE
																					ELSE a.Update_DTTM
																				END)
											)
							)
				)m
           WHERE m.Row_NUMB <= @An_SampleSize_QNTY;
                      
END;  --END OF CASE_RETRIEVE_S175


GO
