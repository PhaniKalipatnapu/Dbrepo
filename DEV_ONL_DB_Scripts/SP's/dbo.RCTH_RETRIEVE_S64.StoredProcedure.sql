/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S64]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S64]  
    (
     @Ad_Batch_DATE					DATE				   ,
     @Ac_SourceBatch_CODE		 	CHAR(3)				   ,
     @An_Batch_NUMB                 NUMERIC(4,0)           ,
     @An_SeqReceipt_NUMB		 	NUMERIC(6,0)		   ,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)		   ,
     @Ac_TypeRemittance_CODE		CHAR(3)	 		 OUTPUT,     
     @Ac_TypePosting_CODE		 	CHAR(1)	 		 OUTPUT,
     @An_Case_IDNO		 			NUMERIC(6,0)	 OUTPUT,
     @An_Fee_AMNT		 			NUMERIC(11,2)	 OUTPUT,
     @An_Employer_IDNO		 		NUMERIC(9,0)	 OUTPUT,
     @Ac_Fips_CODE		 			CHAR(7)	 		 OUTPUT,
     @Ad_Check_DATE					DATE	 		 OUTPUT, 
     @Ac_CheckNo_TEXT		 		CHAR(18)	 	 OUTPUT,
     @Ac_Tanf_CODE					CHAR(1)	 		 OUTPUT,
     @Ac_TaxJoint_CODE				CHAR(1)	 		 OUTPUT,
     @Ac_TaxJoint_NAME		 		CHAR(35)	 	 OUTPUT,
     @Ac_ReasonBackOut_CODE		 	CHAR(2)	 		 OUTPUT,
     @Ad_Refund_DATE				DATE	 		 OUTPUT,
	 @Ac_StatusReceipt_CODE		 	CHAR(1)	 		 OUTPUT,
	 @An_PayorMCI_IDNO		 		NUMERIC(10,0) 	 OUTPUT,
     @Ad_Receipt_DATE				DATE	 		 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S64
 *     DESCRIPTION       : Retrieves the posting details for a receipt
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 30-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      SELECT 
             @Ac_TypeRemittance_CODE	= NULL,
             @Ac_TypePosting_CODE		= NULL,
             @An_Case_IDNO				= NULL,
             @An_Fee_AMNT				= NULL,
             @An_Employer_IDNO			= NULL,
             @Ac_Fips_CODE				= NULL, 
             @Ad_Check_DATE				= NULL,
             @Ac_CheckNo_TEXT			= NULL,
             @Ac_Tanf_CODE				= NULL,
             @Ac_TaxJoint_CODE			= NULL,
             @Ac_TaxJoint_NAME			= NULL,
             @Ac_ReasonBackOut_CODE		= NULL, 
             @Ad_Refund_DATE			= NULL,
			 @Ad_Receipt_DATE			= NULL,
       		 @Ac_StatusReceipt_CODE		= NULL,
			 @An_PayorMCI_IDNO		    = NULL;             

      DECLARE
         @Ld_High_DATE 	DATE = '12/31/9999';
        
        SELECT @Ac_TypeRemittance_CODE = A.TypeRemittance_CODE, 
         @Ac_TypePosting_CODE = A.TypePosting_CODE, 
         @An_Case_IDNO = A.Case_IDNO,
         @An_Fee_AMNT = A.Fee_AMNT,  
         @An_Employer_IDNO = A.Employer_IDNO, 
         @Ac_Fips_CODE = A.Fips_CODE, 
         @Ad_Check_DATE = A.Check_DATE, 
         @Ac_CheckNo_TEXT = A.CheckNo_TEXT, 
         @Ac_TaxJoint_CODE = A.TaxJoint_CODE, 
         @Ac_Tanf_CODE = A.Tanf_CODE,          
         @Ac_TaxJoint_NAME = A.TaxJoint_NAME, 
         @Ac_ReasonBackOut_CODE = A.ReasonBackOut_CODE, 
         @Ad_Refund_DATE = A.Refund_DATE,
		 @Ac_StatusReceipt_CODE = A.StatusReceipt_CODE,
		 @Ad_Receipt_DATE = A.Receipt_DATE,
		 @An_PayorMCI_IDNO =A.PayorMCI_IDNO
      FROM RCTH_Y1 A
      WHERE 
         A.Batch_DATE = @Ad_Batch_DATE  
      AND A.SourceBatch_CODE = @Ac_SourceBatch_CODE  
      AND A.Batch_NUMB = @An_Batch_NUMB  
      AND A.SeqReceipt_NUMB = @An_SeqReceipt_NUMB  
      AND A.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB  
      AND A.EndValidity_DATE = @Ld_High_DATE;
                  
END  -- End of RCTH_RETRIEVE_S64


GO
