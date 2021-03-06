/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S32]  
(                                                             
     @Ad_Batch_DATE					DATE,
     @An_Batch_NUMB          		NUMERIC(4,0),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @An_SeqReceipt_NUMB		 	NUMERIC(6,0),
     @Ac_SourceBatch_CODE		 	CHAR(3),
     @Ac_SourceReceipt_CODE		 	CHAR(2)	 		OUTPUT,
     @Ac_TypeRemittance_CODE		CHAR(3)	 		OUTPUT,
     @Ac_TypePosting_CODE		 	CHAR(1)	 		OUTPUT,
     @An_Case_IDNO		 			NUMERIC(6,0)	OUTPUT,
     @An_PayorMCI_IDNO		 		NUMERIC(10,0)	OUTPUT,
     @Ac_RefundRecipient_CODE		CHAR(1)	 		OUTPUT,
     @An_Receipt_AMNT		 		NUMERIC(11,2)	OUTPUT,
     @An_Fee_AMNT		 			NUMERIC(11,2)	OUTPUT,
     @An_Employer_IDNO		 		NUMERIC(9,0)	OUTPUT,
     @Ac_Fips_CODE		 			CHAR(7)	 		OUTPUT,
     @Ad_Check_DATE					DATE	 		OUTPUT,
     @Ac_CheckNo_TEXT		 		CHAR(18)	 	OUTPUT,
     @Ad_Receipt_DATE				DATE	 		OUTPUT,
     @Ac_Tanf_CODE		 			CHAR(1)	 		OUTPUT,
     @Ac_TaxJoint_CODE		 		CHAR(1)	 		OUTPUT,
     @Ac_TaxJoint_NAME		 		CHAR(35)	 	OUTPUT,
     @Ad_Refund_DATE				DATE	 		OUTPUT,
     @An_ReferenceIrs_IDNO		 	NUMERIC(15,0)	OUTPUT,     
     @Ac_RefundRecipient_ID		 	CHAR(10)	 	OUTPUT
 )                           	             	        
AS

/*
*     PROCEDURE NAME    : RCTH_RETRIEVE_S32
*     DESCRIPTION       : Retrieve Receipt details from the RCTH table.
*     DEVELOPED BY      : IMP TEAM
*     DEVELOPED ON      : 02-OCT-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
   BEGIN

      SELECT @Ac_SourceReceipt_CODE = NULL,
      		@Ac_TypeRemittance_CODE = NULL,
      		@Ac_TypePosting_CODE = NULL,
      		@An_Case_IDNO = NULL,
      		@An_PayorMCI_IDNO = NULL,
      		@Ac_RefundRecipient_CODE = NULL,
      		@An_Receipt_AMNT = NULL,
      		@An_Fee_AMNT  = NULL,
      		@An_Employer_IDNO = NULL,
      		@Ac_Fips_CODE = NULL,
      		@Ad_Check_DATE = NULL,
      		@Ac_CheckNo_TEXT = NULL,
      		@Ad_Receipt_DATE = NULL,
      		@Ac_Tanf_CODE  = NULL,
      		@Ac_TaxJoint_CODE = NULL,
      		@Ac_TaxJoint_NAME = NULL,
      		@Ad_Refund_DATE = NULL,
      		@An_ReferenceIrs_IDNO = NULL,
      		@Ac_RefundRecipient_ID= NULL;

      DECLARE
         @Lc_StatusReceiptHeld_CODE CHAR(1) = 'H', 
         @Ld_High_DATE 				DATE = '12/31/9999';
        
        SELECT @Ac_SourceReceipt_CODE = R.SourceReceipt_CODE,
         @Ac_TypeRemittance_CODE = R.TypeRemittance_CODE,  
         @Ac_TypePosting_CODE = R.TypePosting_CODE, 
         @An_Case_IDNO = R.Case_IDNO, 
         @An_PayorMCI_IDNO = R.PayorMCI_IDNO,
         @Ac_RefundRecipient_CODE = R.RefundRecipient_CODE, 
         @An_Receipt_AMNT = R.Receipt_AMNT, 
         @An_Fee_AMNT = R.Fee_AMNT,
         @An_Employer_IDNO = R.Employer_IDNO, 
         @Ac_Fips_CODE = R.Fips_CODE,  
         @Ad_Check_DATE = R.Check_DATE,
         @Ac_CheckNo_TEXT = R.CheckNo_TEXT,  
         @Ad_Receipt_DATE = R.Receipt_DATE,
         @Ac_Tanf_CODE = R.Tanf_CODE, 
         @Ac_TaxJoint_CODE = R.TaxJoint_CODE, 
         @Ac_TaxJoint_NAME = R.TaxJoint_NAME,
         @Ad_Refund_DATE = R.Refund_DATE,
         @An_ReferenceIrs_IDNO = R.ReferenceIrs_IDNO, 
         @Ac_RefundRecipient_ID = R.RefundRecipient_ID
      FROM RCTH_Y1 R
      WHERE 
         R.Batch_DATE = @Ad_Batch_DATE  
         AND R.SourceBatch_CODE = @Ac_SourceBatch_CODE  
         AND R.Batch_NUMB = @An_Batch_NUMB  
         AND R.SeqReceipt_NUMB = @An_SeqReceipt_NUMB  
         AND R.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB  
         AND R.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE  
         AND R.EndValidity_DATE = @Ld_High_DATE;

                  
END;  --END of RCTH_RETRIEVE_S32


GO
