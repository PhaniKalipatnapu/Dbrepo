/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S167]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S167]
(
	@An_Case_IDNO			NUMERIC(6,0),
	@An_MemberMci_IDNO		NUMERIC(10, 0),
	@Ad_From_DATE			DATE, 
	@Ad_To_DATE 			DATE 
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S167                                            
  *     DESCRIPTION       : This procedure is used to retrieve the NCP payment details related to the case.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/13/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN 
 
	DECLARE @Lc_BackOutYes_INDC					CHAR(1) = 'Y',
			@Lc_BackOutNo_INDC					CHAR(1) = 'N',
			@Lc_StatusReceiptI_CODE				CHAR(1) = 'I',
			@Lc_TypeRecordO_CODE				CHAR(1) = 'O',
			@Li_Zero_NUMB						SMALLINT = 0,
			@Ln_EventFunctionalSeq1810_NUMB		INT = 1810,
			@Ln_EventFunctionalSeq1820_NUMB		INT = 1820,
			@Ld_High_DATE						DATE = '12/31/9999',
			@Ld_Low_DATE						DATE = '01/01/0001';
 
	SELECT MemberMci_IDNO,
				Case_IDNO, 
				Receipt_DATE, 
				ToDistribute_AMNT,
				SeqReceipt_NUMB,
				Batch_NUMB,
				SourceBatch_CODE,
				Batch_DATE,
				SourceReceipt_CODE,
				COUNT(1) OVER() RowCount_NUMB
	FROM (SELECT DISTINCT A.PayorMCI_IDNO AS MemberMci_IDNO,
									 A.Case_IDNO AS Case_IDNO,
									 A.Receipt_DATE AS Receipt_DATE,
									 ISNULL(SUM(A.ToDistribute_AMNT) OVER(PARTITION BY A.SeqReceipt_NUMB, A.Batch_NUMB, A.SourceBatch_CODE, A.Batch_DATE),0) AS ToDistribute_AMNT,
									 A.SeqReceipt_NUMB, 
									 A.Batch_NUMB, 
									 A.SourceBatch_CODE,
									 A.Batch_DATE, 
									 A.SourceReceipt_CODE
					 FROM RCTH_Y1 A
	WHERE ( A.Case_IDNO = @An_Case_IDNO
				  OR 
			A.PayorMCI_IDNO = @An_MemberMci_IDNO )
		   AND A.StatusReceipt_CODE = @Lc_StatusReceiptI_CODE
		   AND A.Distribute_DATE > @Ld_Low_DATE
		   AND A.EndValidity_DATE = @Ld_High_DATE
		   AND A.Receipt_AMNT > @Li_Zero_NUMB
		   AND A.Receipt_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
		   AND EXISTS(SELECT 1
							  FROM LSUP_Y1 B
							 WHERE A.Batch_DATE = B.Batch_DATE
							   AND A.Batch_NUMB = B.Batch_NUMB
							   AND A.SeqReceipt_NUMB = B.SeqReceipt_NUMB
							   AND A.SourceBatch_CODE = B.SourceBatch_CODE
							   AND B.TypeRecord_CODE = @Lc_TypeRecordO_CODE
							   AND B.EventFunctionalSeq_NUMB IN (@Ln_EventFunctionalSeq1810_NUMB, @Ln_EventFunctionalSeq1820_NUMB))
		   AND NOT EXISTS( SELECT 1
							  FROM RCTH_Y1 B
							 WHERE A.Batch_DATE = B.Batch_DATE
							   AND A.Batch_NUMB = B.Batch_NUMB
							   AND A.SeqReceipt_NUMB = B.SeqReceipt_NUMB
							   AND A.SourceBatch_CODE = B.SourceBatch_CODE
							   AND B.BackOut_INDC = @Lc_BackOutYes_INDC
							   AND B.EndValidity_DATE = @Ld_High_DATE)
		   AND ( (NOT EXISTS( SELECT 1
									 FROM RCTR_Y1 B
									WHERE A.Batch_DATE = B.Batch_DATE
										AND A.Batch_NUMB = B.Batch_NUMB
										AND A.SeqReceipt_NUMB = B.SeqReceipt_NUMB
										AND A.SourceBatch_CODE = B.SourceBatch_CODE
										AND B.EndValidity_DATE = @Ld_High_DATE))
				  OR (EXISTS( SELECT 1
									 FROM RCTR_Y1 B, RCTH_Y1 C, RCTH_Y1 D
										WHERE  A.Batch_DATE = B.Batch_DATE
										AND A.Batch_NUMB = B.Batch_NUMB
										AND A.SeqReceipt_NUMB = B.SeqReceipt_NUMB
										AND A.SourceBatch_CODE = B.SourceBatch_CODE
										AND B.EndValidity_DATE = @Ld_High_DATE
										AND B.BatchOrig_DATE = C.Batch_DATE
										AND B.BatchOrig_NUMB = C.Batch_NUMB
										AND B.SeqReceiptOrig_NUMB = C.SeqReceipt_NUMB
										AND B.SourceBatchOrig_CODE = C.SourceBatch_CODE
										AND A.BeginValidity_DATE = C.BeginValidity_DATE
										AND C.EndValidity_DATE = @Ld_High_DATE
										AND C.BackOut_INDC = @Lc_BackOutYes_INDC
										AND B.BatchOrig_DATE = D.Batch_DATE
										AND B.BatchOrig_NUMB = D.Batch_NUMB
										AND B.SeqReceiptOrig_NUMB = D.SeqReceipt_NUMB
										AND B.SourceBatchOrig_CODE = D.SourceBatch_CODE
										AND D.EventGlobalBeginSeq_NUMB = (SELECT MIN(X.EventGlobalBeginSeq_NUMB)
																					FROM RCTH_Y1 X
																					WHERE D.Batch_DATE = X.Batch_DATE
																					 AND D.Batch_NUMB = X.Batch_NUMB
																					 AND D.SeqReceipt_NUMB = X.SeqReceipt_NUMB
																					 AND D.SourceBatch_CODE = X.SourceBatch_CODE)
										AND A.BeginValidity_DATE = D.BeginValidity_DATE
										AND D.BackOut_INDC = @Lc_BackOutNo_INDC)))) AS T
	ORDER BY T.Batch_DATE DESC, 
            T.Batch_NUMB, 
            T.SeqReceipt_NUMB                                            
 
END --End Of Procedure RCTH_RETRIEVE_S167
 

GO
