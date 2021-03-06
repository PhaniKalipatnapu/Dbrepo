/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S163]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S163]
(
	@An_Case_IDNO			NUMERIC(6,0),
	@An_MemberMci_IDNO		NUMERIC(10,0),
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@Ac_SourceReceipt_CODE	CHAR(2)			OUTPUT,
	@Ad_Receipt_DATE		DATE			OUTPUT,
	@Ad_Batch_DATE			DATE			OUTPUT,
	@Ac_SourceBatch_CODE	CHAR(3)			OUTPUT,
	@An_Batch_NUMB			NUMERIC(4,0)	OUTPUT,
	@An_SeqReceipt_NUMB		NUMERIC(6,0)	OUTPUT
)
AS
/*                                                                                   
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S163                                          
  *     DESCRIPTION       : This procedure is used to retrieve the receipt details
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 07/MAR/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
BEGIN 
	 SELECT @Ac_SourceReceipt_CODE		= NULL,
			@Ad_Receipt_DATE			= NULL,
			@Ad_Batch_DATE				= NULL,
			@Ac_SourceBatch_CODE		= NULL,
			@An_Batch_NUMB				= NULL,
			@An_SeqReceipt_NUMB			= NULL;
 
	DECLARE @Ld_High_DATE				DATE    = '12/31/9999',
			@Lc_BackOutY_CODE			CHAR(1) = 'Y',
			@Lc_StatusReceiptO_CODE		CHAR(1)	= 'O',
			@Lc_StatusReceiptR_CODE		CHAR(1) = 'R',
			@Lc_SourceReceiptDB_CODE	CHAR(2) = 'DB',
			@Lc_SourceReceiptEW_CODE	CHAR(2)	= 'EW',
			@Lc_SourceReceiptF4_CODE	CHAR(2)	= 'F4',
			@Lc_SourceReceiptFF_CODE	CHAR(2) = 'FF',
			@Lc_SourceReceiptQR_CODE	CHAR(2) = 'QR',
			@Lc_SourceReceiptRE_CODE	CHAR(2) = 'RE',
			@Lc_SourceReceiptUC_CODE	CHAR(2) = 'UC',
			@Lc_SourceReceiptWC_CODE	CHAR(2) = 'WC';
 
	 SELECT TOP 1 @Ac_SourceReceipt_CODE	= a.SourceReceipt_CODE, 
			@Ad_Receipt_DATE		= a.Receipt_DATE,
			@Ad_Batch_DATE			= a.Batch_DATE,
            @Ac_SourceBatch_CODE	= a.SourceBatch_CODE, 
            @An_Batch_NUMB			= a.Batch_NUMB, 
            @An_SeqReceipt_NUMB		= a.SeqReceipt_NUMB
       FROM (SELECT q.SourceReceipt_CODE,
					q.Receipt_DATE,
					q.Batch_DATE,
					q.SourceBatch_CODE, 
					q.Batch_NUMB, 
					q.SeqReceipt_NUMB
               FROM RCTH_Y1 q
              WHERE (q.Case_IDNO = @An_Case_IDNO
                     OR q.PayorMCI_IDNO = @An_MemberMci_IDNO 
                    )
                AND q.Receipt_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
                AND q.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptO_CODE, @Lc_StatusReceiptR_CODE )
                AND NOT EXISTS (SELECT 1
                                  FROM RCTH_Y1 z
                                 WHERE z.Batch_DATE			= q.Batch_DATE
                                   AND z.SourceBatch_CODE	= q.SourceBatch_CODE
                                   AND z.Batch_NUMB			= q.Batch_NUMB
                                   AND z.SeqReceipt_NUMB	= q.SeqReceipt_NUMB
                                   AND z.BackOut_INDC		= @Lc_BackOutY_CODE
                                   AND z.EndValidity_DATE	= @Ld_High_DATE)
                AND q.SourceReceipt_CODE IN (@Lc_SourceReceiptRE_CODE,@Lc_SourceReceiptEW_CODE,@Lc_SourceReceiptFF_CODE,@Lc_SourceReceiptUC_CODE,@Lc_SourceReceiptWC_CODE,@Lc_SourceReceiptF4_CODE,@Lc_SourceReceiptQR_CODE,@Lc_SourceReceiptDB_CODE )
                AND q.EndValidity_DATE = @Ld_High_DATE) a
                ORDER BY a.Receipt_DATE DESC;
 
END --End Of Procedure RCTH_RETRIEVE_S163
 

GO
