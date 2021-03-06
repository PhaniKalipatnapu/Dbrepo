/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S9]  
	(
     @Ad_Batch_DATE		               DATE,
     @An_Batch_NUMB                    NUMERIC(4,0),
     @Ac_SourceBatch_CODE		       CHAR(3),
     @An_SeqReceipt_NUMB		       NUMERIC(6,0),
     @Ac_TaxJoint_CODE		           CHAR(1)	        OUTPUT,
     @Ac_StatusReceipt_CODE		       CHAR(1)	        OUTPUT,
     @Ac_Tanf_CODE		               CHAR(1)	        OUTPUT,
     @Ad_Receipt_DATE		           DATE	            OUTPUT,
     @An_Fee_AMNT		               NUMERIC(11,2)	OUTPUT,
     @An_Receipt_AMNT		           NUMERIC(11,2)	OUTPUT,
     @Ac_ReasonBackOut_CODE		       CHAR(2)			OUTPUT,
     @Ac_ReasonStatus_CODE             CHAR(4)          OUTPUT,
     @Ac_SourceReceipt_CODE		       CHAR(2)			OUTPUT,
     @Ac_TypeRemittance_CODE		   CHAR(3)			OUTPUT,
     @An_CasePayorMCI_IDNO		       NUMERIC(10,0)	OUTPUT,
     @Ac_Fips_CODE		               CHAR(7)			OUTPUT,
     @Ac_SignedOnWorker_ID             CHAR(30)			OUTPUT,
     @Ac_TaxJoint_NAME		           CHAR(35)			OUTPUT,
     @As_Ncp_NAME		               VARCHAR(60)		OUTPUT,
     @Ac_CheckNo_TEXT		           CHAR(18)			OUTPUT,
     @Ac_TypePosting_CODE              CHAR(1)			OUTPUT,
     @An_Case_IDNO					   NUMERIC(6,0)     OUTPUT,
     @An_PayorMCI_IDNO				   NUMERIC(10,0)    OUTPUT     
	)
	AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S9
 *     DESCRIPTION       : Procedure To Retrieve The Details about Receipts, Based On EventGlobalSeqNUMB By
                           Joining Two Tables RCTH_Y1 And GLEV_Y1 
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 15-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

	 SELECT @Ac_TaxJoint_CODE		= NULL,
			@Ac_StatusReceipt_CODE	= NULL,
			@Ac_Tanf_CODE			= NULL,
			@Ad_Receipt_DATE		= NULL,
			@An_Fee_AMNT			= NULL,
			@An_Receipt_AMNT		= NULL,
			@Ac_ReasonBackOut_CODE	= NULL,
			@Ac_ReasonStatus_CODE	= NULL,
			@Ac_SourceReceipt_CODE	= NULL,
			@Ac_TypeRemittance_CODE = NULL,
			@An_CasePayorMCI_IDNO	= NULL,
			@Ac_Fips_CODE			= NULL,
			@Ac_SignedOnWorker_ID	= NULL,
			@Ac_TaxJoint_NAME		= NULL,
			@As_Ncp_NAME			= NULL,
			@Ac_CheckNo_TEXT		= NULL,
			@Ac_TypePosting_CODE	= NULL,
			@An_Case_IDNO			= NULL,
			@An_PayorMCI_IDNO		= NULL;
		
		DECLARE
        	@Lc_Yes_INDC  CHAR(1) = 'Y', 
			@Ld_High_DATE DATE	  = '12/31/9999';
        
	 SELECT @Ad_Receipt_DATE		= a.Receipt_DATE, 
			@Ac_TypePosting_CODE	= a.TypePosting_CODE,
			@An_Case_IDNO			= a.Case_IDNO,
			@An_PayorMCI_IDNO		= a.PayorMCI_IDNO,
			@An_Receipt_AMNT		= ABS(a.Receipt_AMNT), 
			@Ac_CheckNo_TEXT		= a.CheckNo_TEXT, 
			@Ac_StatusReceipt_CODE	= a.StatusReceipt_CODE, 
			@Ac_ReasonStatus_CODE	= a.ReasonStatus_CODE, 
			@Ac_SourceReceipt_CODE	= a.SourceReceipt_CODE, 
			@Ac_TaxJoint_NAME		= a.TaxJoint_NAME, 
			@Ac_Fips_CODE			= a.Fips_CODE, 
			@An_Fee_AMNT			= a.Fee_AMNT, 
			@Ac_Tanf_CODE			= a.Tanf_CODE, 
			@Ac_TaxJoint_CODE		= a.TaxJoint_CODE, 
			@Ac_SignedOnWorker_ID	= b.Worker_ID, 
			@Ac_TypeRemittance_CODE = a.TypeRemittance_CODE, 
			@Ac_ReasonBackOut_CODE	= a.ReasonBackOut_CODE
	   FROM RCTH_Y1  a 
	   JOIN GLEV_Y1  b
		 ON a.EventGlobalBeginSeq_NUMB  = b.EventGlobalSeq_NUMB
	  WHERE a.Batch_DATE			    = @Ad_Batch_DATE 
		AND a.SourceBatch_CODE			= @Ac_SourceBatch_CODE 
		AND a.Batch_NUMB				= @An_Batch_NUMB 
		AND a.SeqReceipt_NUMB			= @An_SeqReceipt_NUMB 
		AND a.EndValidity_DATE			= @Ld_High_DATE 
		AND a.BackOut_INDC				= @Lc_Yes_INDC;
                 
END; --End Of Procedure RCTH_RETRIEVE_S9


GO
