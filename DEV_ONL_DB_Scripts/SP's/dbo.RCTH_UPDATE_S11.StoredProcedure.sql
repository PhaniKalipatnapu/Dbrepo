/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RCTH_UPDATE_S11] ( 
 
     @Ad_Batch_DATE		         DATE,
     @An_Batch_NUMB              NUMERIC(4,0),
     @An_SeqReceipt_NUMB		 NUMERIC(6,0),
     @Ac_SourceBatch_CODE		 CHAR(3),
     @An_EventGlobalEndSeq_NUMB  NUMERIC(19,0),  
     @Ac_ReasonBackOut_CODE		 CHAR(2),
     @Ac_RefundRecipient_ID		 CHAR(10),
     @Ac_RefundRecipient_CODE	 CHAR(1)
     
  ) AS
  
/*
 * PROCEDURE NAME    : RCTH_UPDATE_S11
 * DESCRIPTION       : Updates the Receipts table for given receipt 
 * DEVELOPED BY      : IMP Team
 * DEVELOPED ON      : 02-AUG-2011
 * MODIFIED BY       : 
 * MODIFIED ON       : 
 * VERSION NO        : 1
*/
   BEGIN 
   
    DECLARE
     @Ld_High_DATE							DATE = '12/31/9999',
     @Ld_Current_DATE						DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
     @Ln_RowsAffected_NUMB					NUMERIC(10),
     @Ld_Low_DATE							DATE ='01/01/0001',
     @Lc_StatusReceiptUnidentified_CODE		CHAR(1)='U',
	 @Lc_ReasonStatusUsrp_CODE				CHAR(4)='USRP',
	 @Lc_TypeRemittanceCsh_CODE				CHAR(3)='CSH',
	 @Li_Zero_NUMB							SMALLINT = 0; 
     
	UPDATE RCTH_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
		 EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
     OUTPUT
		 @Ad_Batch_DATE AS Batch_DATE,
		 @Ac_SourceBatch_CODE AS SourceBatch_CODE,
		 @An_Batch_NUMB AS Batch_NUMB,
		 @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
		 DELETED.SourceReceipt_CODE, 
         DELETED.TypeRemittance_CODE, 
         DELETED.TypePosting_CODE, 
         DELETED.Case_IDNO, 
         DELETED.PayorMCI_IDNO, 
         DELETED.Receipt_AMNT, 
         DELETED.ToDistribute_AMNT, 
         DELETED.Fee_AMNT, 
         DELETED.Employer_IDNO, 
         DELETED.Fips_CODE, 
         DELETED.Check_DATE, 
         DELETED.CheckNo_TEXT, 
         DELETED.Receipt_DATE,
         @Ld_Low_DATE AS Distribute_DATE, 
         DELETED.Tanf_CODE, 
         DELETED.TaxJoint_CODE, 
         DELETED.TaxJoint_NAME,
         @Lc_StatusReceiptUnidentified_CODE AS StatusReceipt_CODE,
         @Lc_ReasonStatusUsrp_CODE AS ReasonStatus_CODE,
         DELETED.BackOut_INDC, 
         @Ac_ReasonBackOut_CODE AS ReasonBackOut_CODE,
         Deleted.Refund_DATE, 
         @Ld_High_DATE AS Release_DATE,
         DELETED.ReferenceIrs_IDNO,
         @Ac_RefundRecipient_ID AS RefundRecipient_ID,
         @Ac_RefundRecipient_CODE AS RefundRecipient_CODE,
         @Ld_Current_DATE AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @An_EventGlobalEndSeq_NUMB AS EventGlobalBeginSeq_NUMB,
         @Li_Zero_NUMB AS EventGlobalEndSeq_NUMB
      INTO RCTH_Y1
      WHERE Batch_DATE = @Ad_Batch_DATE 
       AND  Batch_NUMB = @An_Batch_NUMB 
       AND  SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
       AND  SourceBatch_CODE = @Ac_SourceBatch_CODE 
       AND  EndValidity_DATE = @Ld_High_DATE
	   AND  TypeRemittance_CODE != @Lc_TypeRemittanceCsh_CODE ;     
     
   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;   
       
     
END; -- END OF RCTH_UPDATE_S11    
     

GO
