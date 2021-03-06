/****** Object:  StoredProcedure [dbo].[UCASE_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCASE_RETRIEVE_S5] 
( 
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@An_SampleSize_QNTY		NUMERIC(7,0)
)  
AS
/*
 *     PROCEDURE NAME    : UCASE_RETRIEVE_S5
 *     DESCRIPTION       : This procedure is used to retrieve the case details for disbursement of collections.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 07-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	DECLARE @Li_One_NUMB					INT		= 1,
			@Ld_High_DATE					DATE    = '12/31/9999',
			@Ld_Low_DATE					DATE    = '01/01/0001',
			@Lc_BackOutY_INDC				CHAR(1) = 'Y',
			@Lc_StatusReceiptO_CODE			CHAR(1) = 'O', 
			@Lc_StatusReceiptR_CODE			CHAR(1) = 'R',
			@Lc_CaseMemberStatusA_CODE		CHAR(1) = 'A',
			@Lc_CaseRelationshipA_CODE		CHAR(1) = 'A',
			@Lc_CaseRelationshipPF_CODE		CHAR(1) = 'P',
			@Lc_StatusCaseO_CODE			CHAR(1) = 'O',
			@Lc_StatusCaseC_CODE			CHAR(1) = 'C',
			@Lc_TypeOrderV_CODE				CHAR(1) = 'V',
			@Lc_TypeCaseH_CODE				CHAR(1) = 'H',
			@Lc_TypeDebtGT_CODE				CHAR(2) = 'GT',
			@Lc_SourceReceiptRE_CODE		CHAR(2) = 'RE',
			@Lc_SourceReceiptEW_CODE		CHAR(2) = 'EW',
			@Lc_SourceReceiptFF_CODE		CHAR(2) = 'FF',
			@Lc_SourceReceiptUC_CODE		CHAR(2) = 'UC',
			@Lc_SourceReceiptWC_CODE		CHAR(2) = 'WC',
			@Lc_SourceReceiptF4_CODE		CHAR(2) = 'F4',
			@Lc_SourceReceiptQR_CODE		CHAR(2) = 'QR',
			@Lc_SourceReceiptDB_CODE		CHAR(2) = 'DB',
			@Lc_WorkerIdConversion_CODE		CHAR(30)= 'CONVERSION';
			
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
	  FROM ( SELECT y.Case_IDNO, 
					y.StatusCase_CODE, 
					y.TypeCase_CODE, 
					y.RespondInit_CODE,
					y.County_IDNO, 
					y.Office_IDNO, 
					y.CaseTitle_NAME, 
					y.Worker_ID,
					y.RsnStatusCase_CODE, 
					y.Opened_DATE, 
					y.WorkerUpdate_ID,
					y.Update_DTTM, 
					ROW_NUMBER () OVER (ORDER BY NEWID()) Row_NUMB,
					COUNT (1) OVER () AS RowCount_NUMB
			   FROM (SELECT x.Case_IDNO, 
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
							x.MemberMci_IDNO
					   FROM (SELECT a.Case_IDNO,
									a.StatusCase_CODE,
									a.TypeCase_CODE,
									a.RespondInit_CODE,
									a.County_IDNO,
									a.Office_IDNO,
									(SELECT d.CaseTitle_NAME
									   FROM UDCKT_V1 d
									  WHERE d.File_ID = a.File_ID
										AND d.EndValidity_DATE = @Ld_High_DATE) AS CaseTitle_NAME,
									a.Worker_ID,
									a.RsnStatusCase_CODE,
									CASE a.WorkerUpdate_ID 
										WHEN @Lc_WorkerIdConversion_CODE
											THEN a.Opened_DATE 
										ELSE a.Update_DTTM
									END Opened_DATE,
									a.File_ID,
									a.WorkerUpdate_ID,
									a.Update_DTTM,
									ncp.MemberMci_IDNO,
									ROW_NUMBER() OVER (PARTITION BY a.Case_IDNO ORDER BY a.TransactionEventSeq_NUMB) AS case_RowNum
							   FROM UCASE_V1 a  JOIN (SELECT e.Case_IDNO,
															 e.MemberMci_IDNO
														FROM CMEM_Y1 e
													   WHERE e.CaseRelationship_CODE IN(@Lc_CaseRelationshipA_CODE,	@Lc_CaseRelationshipPF_CODE	)
														 AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE) ncp
								 ON a.Case_IDNO = ncp.Case_IDNO
							  WHERE a.StatusCase_CODE = @Lc_StatusCaseO_CODE
								AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
								AND CASE a.WorkerUpdate_ID
										WHEN @Lc_WorkerIdConversion_CODE
											THEN a.Opened_DATE 
										ELSE a.Update_DTTM
									END <= @Ad_End_DATE
								AND CASE a.WorkerUpdate_ID
										WHEN @Lc_WorkerIdConversion_CODE
											THEN a.Opened_DATE 
										ELSE a.Update_DTTM
									END >=(SELECT ISNULL(MAX(u.StatusCurrent_DATE),@Ld_Low_DATE)
											 FROM UCASE_V1 u
											WHERE u.Case_IDNO = a.Case_IDNO
											  AND u.StatusCase_CODE = @Lc_StatusCaseC_CODE
											  AND u.Update_DTTM < @Ad_End_DATE)
											  AND NOT EXISTS (SELECT 1
																FROM UCASE_V1 v
															   WHERE v.Case_IDNO = a.Case_IDNO
																 AND v.StatusCase_CODE = @Lc_StatusCaseC_CODE
																 AND v.StatusCurrent_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE)) x
					  WHERE case_RowNum = @Li_One_NUMB) y
				   WHERE EXISTS (SELECT 1
								   FROM SORD_Y1 b JOIN OBLE_Y1 o
								     ON o.Case_IDNO = b.Case_IDNO
									AND o.OrderSeq_NUMB = b.OrderSeq_NUMB
								  WHERE b.Case_IDNO = y.Case_IDNO
								    AND b.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
									AND CASE b.WorkerUpdate_ID
											WHEN @Lc_WorkerIdConversion_CODE 
												THEN b.OrderEffective_DATE
											ELSE b.BeginValidity_DATE
										END <= @Ad_End_DATE
									AND b.EventGlobalBeginSeq_NUMB =(SELECT MIN (s.EventGlobalBeginSeq_NUMB)
																  FROM SORD_Y1 s
																 WHERE s.Case_IDNO = b.Case_IDNO
																   AND s.OrderSeq_NUMB = b.OrderSeq_NUMB
																   AND CASE y.WorkerUpdate_ID
																			WHEN @Lc_WorkerIdConversion_CODE
																				THEN s.OrderEffective_DATE
																			ELSE s.BeginValidity_DATE
																	   END >= CASE y.WorkerUpdate_ID
																				 WHEN @Lc_WorkerIdConversion_CODE
																					 THEN y.Opened_DATE 
																				 ELSE y.Update_DTTM
																			  END )
									AND CASE y.WorkerUpdate_ID
											WHEN @Lc_WorkerIdConversion_CODE
												THEN o.BeginObligation_DATE
											ELSE o.BeginValidity_DATE
										END >= CASE y.WorkerUpdate_ID
													WHEN @Lc_WorkerIdConversion_CODE
														THEN b.OrderEffective_DATE
													ELSE b.BeginValidity_DATE
											   END
									AND o.EndValidity_DATE = @Ld_High_DATE
									AND o.TypeDebt_CODE <> @Lc_TypeDebtGT_CODE
									AND o.EndObligation_DATE >= @Ad_End_DATE)
									AND EXISTS(SELECT 1
												 FROM RCTH_Y1 c
												WHERE (c.Case_IDNO		 = y.Case_IDNO
													  OR c.PayorMCI_IDNO = y.MemberMci_IDNO )
												  AND c.Receipt_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
												  AND c.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptO_CODE,@Lc_StatusReceiptR_CODE )
												  AND NOT EXISTS(SELECT 1
																   FROM RCTH_Y1 z
																  WHERE z.Batch_DATE		= c.Batch_DATE
																	AND z.SourceBatch_CODE	= c.SourceBatch_CODE
																	AND z.Batch_NUMB		= c.Batch_NUMB
																	AND z.SeqReceipt_NUMB	= c.SeqReceipt_NUMB
																	AND z.BackOut_INDC		= @Lc_BackOutY_INDC
																	AND z.EndValidity_DATE	= @Ld_High_DATE)
												  AND c.SourceReceipt_CODE IN (@Lc_SourceReceiptRE_CODE,@Lc_SourceReceiptEW_CODE,@Lc_SourceReceiptFF_CODE,@Lc_SourceReceiptUC_CODE,	@Lc_SourceReceiptWC_CODE,@Lc_SourceReceiptF4_CODE,@Lc_SourceReceiptQR_CODE,	@Lc_SourceReceiptDB_CODE )
												  AND c.EndValidity_DATE = @Ld_High_DATE))m
								 WHERE m.Row_NUMB <= @An_SampleSize_QNTY;
	                  
END; -- END OF UCASE_RETRIEVE_S5
 

GO
