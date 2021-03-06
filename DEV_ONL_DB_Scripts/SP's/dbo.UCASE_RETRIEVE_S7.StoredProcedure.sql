/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S7] 
(
	@Ad_End_DATE			DATE,
	@An_SampleSize_QNTY		NUMERIC(7,0)
)
AS
/*                                                                                   
  *     PROCEDURE NAME    : UCASE_RETRIEVE_S7                                          
  *     DESCRIPTION       : This procedure is used to retrieve the cases that are associated with Review and Adjustment of order.
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 03/07/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
BEGIN
 
	DECLARE @Li_Zero_NUMB					INT		= 0,
			@Li_One_NUMB					INT		= 1,
			@Ld_Low_DATE					DATE	= '01/01/0001',
			@Ld_High_DATE					DATE	= '12/31/9999',
			@Lc_StatusCaseC_CODE			CHAR(1) = 'C',
			@Lc_StatusCaseO_CODE			CHAR(1) = 'O',
			@Lc_TypeCaseH_CODE				CHAR(1) = 'H',
			@Lc_TypeOrderV_CODE				CHAR(1) = 'V',
			@Lc_TypeDebtGT_CODE				CHAR(2) = 'GT',
			@Lc_WorkerUpdateCONVERSION_CODE CHAR(10) = 'CONVERSION',
			@Ld_ThreeYrsOld_DATE			DATE = DATEADD(MM,-36,@Ad_End_DATE);
	
	SELECT m.Case_IDNO, 
		   m.StatusCase_CODE, 
		   m.TypeCase_CODE, 
		   m.RespondInit_CODE,
		   m.County_IDNO, 
		   m.Office_IDNO, 
		   m.Casetitle_NAME, 
		   m.Worker_ID,
		   m.RsnStatusCase_CODE, 
		   m.StatusCurrent_DATE,
		   m.Opened_DATE, 
		   m.WorkerUpdate_ID, 
		   m.Update_DTTM,
		   m.Row_NUMB,
		   m.RowCount_NUMB
	 FROM ( SELECT y.Case_IDNO, 
				   y.StatusCase_CODE, 
				   y.TypeCase_CODE, 
				   y.RespondInit_CODE,
				   y.County_IDNO, 
				   y.Office_IDNO, 
				   y.Casetitle_NAME, 
				   y.Worker_ID,
				   y.RsnStatusCase_CODE, 
				   y.StatusCurrent_DATE,
				   y.Opened_DATE, 
				   y.WorkerUpdate_ID, 
				   y.Update_DTTM,
				   ROW_NUMBER() OVER (ORDER BY NEWID()) Row_NUMB,
				   COUNT(1) OVER () AS RowCount_NUMB
			  FROM (SELECT         a.Case_IDNO,
								   a.StatusCase_CODE,
								   a.TypeCase_CODE,
								   a.RespondInit_CODE,
								   a.County_IDNO,
								   a.Office_IDNO,
								   (SELECT d.Casetitle_NAME
									  FROM UDCKT_V1 d
									 WHERE d.File_id = a.File_ID
									   AND d.EndValidity_DATE = @Ld_High_DATE
									)AS Casetitle_NAME,
								   a.Worker_ID,
								   a.RsnStatusCase_CODE,
								   a.StatusCurrent_DATE,
								   CASE a.WorkerUpdate_ID
										 WHEN @Lc_WorkerUpdateCONVERSION_CODE 
											  THEN a.Opened_DATE
										 ELSE a.Update_DTTM
									END Opened_DATE,
								   a.file_ID,
								   a.WorkerUpdate_ID,
								   a.Update_DTTM,
								   CASE ROW_NUMBER() OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB)
								         WHEN @Li_One_NUMB
								         THEN ROW_NUMBER() OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB)
								   END Case_RowNum
							  FROM UCASE_V1 a
							 WHERE a.StatusCase_CODE = @Lc_StatusCaseO_CODE
							   AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
							   AND CASE a.WorkerUpdate_ID 
										 WHEN @Lc_WorkerUpdateCONVERSION_CODE 
											 THEN a.Opened_DATE
										 ELSE a.Update_DTTM
									END <= @Ad_End_DATE
								AND CASE a.WorkerUpdate_ID
										  WHEN @Lc_WorkerUpdateCONVERSION_CODE 
											  THEN a.Opened_DATE
										  ELSE a.Update_DTTM
									 END >=(SELECT ISNULL(MAX(u.StatusCurrent_DATE),@Ld_Low_DATE)
											   FROM UCASE_V1 u
											  WHERE u.Case_IDNO = a.Case_IDNO
												AND u.StatusCase_CODE = @Lc_StatusCaseC_CODE
												AND u.Update_DTTM < @Ld_ThreeYrsOld_DATE
												AND NOT EXISTS(SELECT 1
																 FROM UCASE_V1 v
																WHERE v.Case_IDNO = a.Case_IDNO
																  AND v.StatusCase_CODE = @Lc_StatusCaseC_CODE
																  AND v.StatusCurrent_DATE BETWEEN @Ld_ThreeYrsOld_DATE AND @Ad_End_DATE)
															   )
					 ) y
			 WHERE EXISTS(SELECT 1
							FROM SORD_Y1 b JOIN OBLE_Y1 c
							  ON c.Case_IDNO = b.Case_IDNO
							 AND c.OrderSeq_NUMB = b.OrderSeq_NUMB
						   WHERE b.Case_IDNO = y.Case_IDNO
						     AND b.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
							 AND  CASE b.WorkerUpdate_ID
									  WHEN @Lc_WorkerUpdateCONVERSION_CODE 
											 THEN b.OrderEffective_DATE
									  ELSE b.OrderIssued_DATE 
								  END <= @Ld_ThreeYrsOld_DATE
							 AND b.OrderEnt_DATE <= @Ld_ThreeYrsOld_DATE 
							 AND b.LastReview_DATE < (SELECT MAX(OrderEnt_DATE) 
														FROM SORD_Y1 n
													   WHERE n.Case_IDNO = b.Case_IDNO)
							 AND b.EventGlobalBeginSeq_NUMB =(SELECT MIN (s.EventGlobalBeginSeq_NUMB)
																FROM SORD_Y1 s
															   WHERE s.Case_IDNO = b.Case_IDNO
																 AND s.OrderSeq_NUMB = b.OrderSeq_NUMB
																 AND CASE y.WorkerUpdate_ID
																			 WHEN @Lc_WorkerUpdateCONVERSION_CODE 
																				THEN s.OrderEffective_DATE
																			 ELSE s.BeginValidity_DATE
																	  END >= CASE y.WorkerUpdate_ID
																					WHEN @Lc_WorkerUpdateCONVERSION_CODE  
																						THEN y.Opened_DATE
																					ELSE y.Update_DTTM
																				END)
							 AND c.Periodic_AMNT > @Li_Zero_NUMB
							 AND CASE y.WorkerUpdate_ID
									 WHEN @Lc_WorkerUpdateCONVERSION_CODE 
										 THEN c.BeginObligation_DATE
									 ELSE c.BeginValidity_DATE
								  END >= CASE y.WorkerUpdate_ID
											 WHEN @Lc_WorkerUpdateCONVERSION_CODE  
												 THEN  b.OrderEffective_DATE
											 ELSE b.BeginValidity_DATE
										  END 
							 AND c.EndValidity_DATE = @Ld_High_DATE
							 AND c.TypeDebt_CODE <> @Lc_TypeDebtGT_CODE
							 AND c.EndObligation_DATE >= @Ad_End_DATE))m
			    WHERE m.Row_NUMB <= @An_SampleSize_QNTY;
	 
END --End Of Procedure UCASE_RETRIEVE_S7
 

GO
