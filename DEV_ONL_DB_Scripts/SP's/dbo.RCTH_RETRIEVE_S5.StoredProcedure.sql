/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S5] 
(
     @Ad_Batch_DATE					DATE,
     @An_Batch_NUMB					NUMERIC(4,0),
     @Ac_SourceBatch_CODE			CHAR(3),
     @An_SeqReceipt_NUMB			NUMERIC(6,0),
	 @Ac_Exists_INDC				CHAR(1)  OUTPUT
)

AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S5
 *     DESCRIPTION       : Returns 'Y' if the receipt is fully refunded and disbursed(not in hold)
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 01-20-2015
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
     
	 DECLARE @Lc_No_INDC						CHAR(1)	= 'N',
			 @Lc_YES_INDC						CHAR(1)	= 'Y',
			 @Ld_StatusReceiptRefund_CODE		CHAR(1)	= 'R',
			 @Ld_StatusHold_CODE				CHAR(1)	= 'H',
			 @Ld_High_DATE						DATE	= '12/31/9999',
			 @Ld_Low_DATE						DATE	= '01/01/0001';

	 SET @Ac_Exists_INDC = @Lc_No_INDC ;
     
	 SELECT @Ac_Exists_INDC = @Lc_YES_INDC 
	 FROM RCTH_Y1 r
	 WHERE r.Batch_DATE = @Ad_Batch_DATE
	 AND r.Batch_NUMB = @An_Batch_NUMB     
	 AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
	 AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
	 AND r.EndValidity_DATE = @Ld_High_DATE
	 AND r.StatusReceipt_CODE = @Ld_StatusReceiptRefund_CODE
	 AND r.Refund_DATE <> @Ld_Low_DATE
	 AND r.ToDistribute_AMNT = r.Receipt_AMNT
	 AND NOT EXISTS(
	 SELECT 1 FROM DHLD_Y1 d
	 WHERE d.Batch_DATE = r.Batch_DATE
	 AND d.Batch_NUMB = r.Batch_NUMB     
	 AND d.SourceBatch_CODE = r.SourceBatch_CODE
	 AND d.SeqReceipt_NUMB = r.SeqReceipt_NUMB
	 AND d.EndValidity_DATE = @Ld_High_DATE
	 AND d.Status_CODE=@Ld_StatusHold_CODE
	 );

END; --End Of Procedure RCTH_RETRIEVE_S5 


GO
