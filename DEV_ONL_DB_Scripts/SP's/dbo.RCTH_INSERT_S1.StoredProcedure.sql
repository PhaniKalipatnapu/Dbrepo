/****** Object:  StoredProcedure [dbo].[RCTH_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_INSERT_S1] ( 

     @Ad_Batch_DATE					DATE,
     @An_Batch_NUMB					NUMERIC(4,0), 
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @An_SeqReceipt_NUMB			NUMERIC(6,0),
     @Ac_SourceBatch_CODE			CHAR(3),    
     @Ac_SourceReceipt_CODE			CHAR(2),    
     @Ac_TypeRemittance_CODE		CHAR(3),    
     @Ac_TypePosting_CODE			CHAR(1),    
     @An_Case_IDNO					NUMERIC(6,0),   
     @An_PayorMCI_IDNO				NUMERIC(10,0),
     @An_Receipt_AMNT				NUMERIC(11,2),    
     @An_ToDistribute_AMNT			NUMERIC(11,2),     
     @An_Fee_AMNT					NUMERIC(11,2),    
     @An_Employer_IDNO				NUMERIC(9,0),   
     @Ac_Fips_CODE					CHAR(7),   
     @Ad_Check_DATE					DATE,   
     @Ac_CheckNo_TEXT				CHAR(18),   
     @Ad_Receipt_DATE				DATE,   
     @Ad_Distribute_DATE			DATE,   
     @Ac_Tanf_CODE					CHAR(1),    
     @Ac_TaxJoint_CODE				CHAR(1),     
     @Ac_TaxJoint_NAME				CHAR(35),      
     @Ac_StatusReceipt_CODE			CHAR(1),    
     @Ac_ReasonStatus_CODE			CHAR(4),    
     @Ac_BackOut_INDC				CHAR(1),    
     @Ac_ReasonBackOut_CODE			CHAR(2),    
     @Ad_Refund_DATE				DATE,   
     @Ad_Release_DATE				DATE,
     @An_ReferenceIrs_IDNO			NUMERIC(15,0),
     @Ac_RefundRecipient_ID		    CHAR(10),        
     @Ac_RefundRecipient_CODE		CHAR(1),    
     @An_EventGlobalEndSeq_NUMB		NUMERIC(19,0)
     )            
AS

/*
 *     PROCEDURE NAME    : RCTH_INSERT_S1
 *     DESCRIPTION       : Insert the Receipt Information in RCTH_Y1 table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
      DECLARE 
      	@Ld_High_DATE     DATE = '12/31/9999',
        @Ld_Current_DATE  DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
             
      INSERT RCTH_Y1(
         Batch_DATE, 
         SourceBatch_CODE, 
         Batch_NUMB, 
         SeqReceipt_NUMB, 
         SourceReceipt_CODE, 
         TypeRemittance_CODE, 
         TypePosting_CODE, 
         Case_IDNO, 
         PayorMCI_IDNO, 
         Receipt_AMNT, 
         ToDistribute_AMNT, 
         Fee_AMNT, 
         Employer_IDNO, 
         Fips_CODE, 
         Check_DATE, 
         CheckNo_TEXT, 
         Receipt_DATE, 
         Distribute_DATE, 
         Tanf_CODE, 
         TaxJoint_CODE, 
         TaxJoint_NAME, 
         StatusReceipt_CODE, 
         ReasonStatus_CODE, 
         BackOut_INDC, 
         ReasonBackOut_CODE, 
         Refund_DATE, 
         Release_DATE,
         ReferenceIrs_IDNO,
         RefundRecipient_ID, 
         RefundRecipient_CODE, 
         BeginValidity_DATE,
         EndValidity_DATE,
         EventGlobalBeginSeq_NUMB, 
         EventGlobalEndSeq_NUMB)
         VALUES (@Ad_Batch_DATE, 
            @Ac_SourceBatch_CODE, 
			@An_Batch_NUMB, 
            @An_SeqReceipt_NUMB, 
            @Ac_SourceReceipt_CODE, 
            @Ac_TypeRemittance_CODE, 
            @Ac_TypePosting_CODE, 
            @An_Case_IDNO, 
            @An_PayorMCI_IDNO, 
            @An_Receipt_AMNT, 
            @An_ToDistribute_AMNT, 
            @An_Fee_AMNT, 
            @An_Employer_IDNO, 
            @Ac_Fips_CODE, 
            @Ad_Check_DATE, 
            @Ac_CheckNo_TEXT, 
            @Ad_Receipt_DATE, 
            @Ad_Distribute_DATE, 
            @Ac_Tanf_CODE, 
            @Ac_TaxJoint_CODE, 
            @Ac_TaxJoint_NAME, 
            @Ac_StatusReceipt_CODE, 
            @Ac_ReasonStatus_CODE, 
            @Ac_BackOut_INDC, 
            @Ac_ReasonBackOut_CODE, 
            @Ad_Refund_DATE, 
            @Ad_Release_DATE, 
            @An_ReferenceIrs_IDNO,
            @Ac_RefundRecipient_ID,	 
            @Ac_RefundRecipient_CODE, 
            @Ld_Current_DATE, 
            @Ld_High_DATE, 
            @An_EventGlobalBeginSeq_NUMB, 
            @An_EventGlobalEndSeq_NUMB);
                  
END; -- END OF RCTH_INSERT_S1


GO
