/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S166]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S166]
(
	@An_Case_IDNO				NUMERIC(6,0),
	@An_MemberMci_IDNO			NUMERIC(10, 0),
	@An_Receipt_AMNT			NUMERIC(11, 2) OUTPUT,
	@Ad_Receipt_DATE 			DATE OUTPUT
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S166                                            
  *     DESCRIPTION       : This procedure is used to retrieve the last payment amount and date for case.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/13/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN 
		SET @An_Receipt_AMNT 			= NULL;
		SET @Ad_Receipt_DATE 			= NULL;
 
	DECLARE @Lc_BackOutYes_INDC					CHAR(1) = 'Y',
			@Lc_StatusReceiptI_CODE				CHAR(1) = 'I',
			@Lc_TypeRecordO_CODE				CHAR(1) = 'O',
			@Li_Zero_NUMB						SMALLINT = 0,
			@Ln_EventFunctionalSeq1810_NUMB		INT = 1810,
			@Ln_EventFunctionalSeq1820_NUMB		INT = 1820,
			@Ln_EventFunctionalSeq1250_NUMB		INT = 1250,
			@Ld_High_DATE						DATE = '12/31/9999',
			@Ld_Low_DATE						DATE = '01/01/0001';
 
	SELECT TOP 1 @An_Receipt_AMNT = T.Receipt_AMNT, 
			@Ad_Receipt_DATE = T.Receipt_DATE
	FROM RCTH_Y1 T
    WHERE EXISTS ( SELECT  1 
				FROM LSUP_Y1 C
				WHERE C.Case_IDNO =  @An_Case_IDNO
					AND C.TypeRecord_CODE = @Lc_TypeRecordO_CODE
					AND C.EventFunctionalSeq_NUMB IN (@Ln_EventFunctionalSeq1810_NUMB, @Ln_EventFunctionalSeq1820_NUMB, @Ln_EventFunctionalSeq1250_NUMB)
					AND T.Batch_DATE = C.Batch_DATE
					AND T.SourceBatch_CODE = C.SourceBatch_CODE
					AND T.Batch_NUMB = C.Batch_NUMB
					AND T.SeqReceipt_NUMB = C.SeqReceipt_NUMB
					AND T.EndValidity_DATE = @Ld_High_DATE
					AND C.EventGlobalSeq_NUMB = (SELECT TOP 1 Max(EventGlobalSeq_NUMB)
												  FROM  LSUP_Y1 L
												  WHERE L.Case_IDNO = @An_Case_IDNO
												  AND L.TypeRecord_CODE = @Lc_TypeRecordO_CODE
												  AND L.EventFunctionalSeq_NUMB IN (@Ln_EventFunctionalSeq1810_NUMB, @Ln_EventFunctionalSeq1820_NUMB, @Ln_EventFunctionalSeq1250_NUMB)      
					AND NOT EXISTS ( SELECT 1 
									FROM RCTH_Y1 R
									  WHERE L.Batch_DATE = R.Batch_DATE
									  AND   L.Batch_NUMB = R.Batch_NUMB
									  AND   L.SourceBatch_CODE = R.SourceBatch_CODE
									  AND   L.SeqReceipt_NUMB = R.SeqReceipt_NUMB
									  AND   R.BackOut_INDC = @Lc_BackOutYes_INDC
									  AND   R.EndValidity_DATE = @Ld_High_DATE)))
		AND T.StatusReceipt_CODE = @Lc_StatusReceiptI_CODE
		AND T.Distribute_DATE > @Ld_Low_DATE
		AND T.Receipt_AMNT > @Li_Zero_NUMB
		AND T.EndValidity_DATE = @Ld_High_DATE
		AND (T.Case_IDNO = @An_Case_IDNO
			OR 
			T.PayorMCI_IDNO = @An_MemberMci_IDNO
			AND T.Case_IDNO = @Li_Zero_NUMB)                                             
 
END --End Of Procedure RCTH_RETRIEVE_S166
 

GO
