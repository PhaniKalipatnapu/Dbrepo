/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_UPDATE_S1] ( 
     @Ad_Batch_DATE						DATE,   
     @Ac_SourceBatch_CODE				CHAR(3),    
     @An_Batch_NUMB						NUMERIC(4,0) ,   
     @An_SeqReceipt_NUMB				NUMERIC(6,0),
     @An_EventGlobalBeginSeq_NUMB		NUMERIC(19,0),
     @An_Case_IDNO						NUMERIC(6,0),  
     @An_ToDistribute_AMNT				NUMERIC(11,2), 
     @Ac_StatusReceipt_CODE				CHAR(1),    
     @Ac_ReasonStatus_CODE				CHAR(4)   ,   
     @Ad_Release_DATE					DATE,   
     @An_EventGlobalBeginSeqFile_NUMB	NUMERIC(19,0)   
     )                  
AS                                                                       

/*
 *     PROCEDURE NAME    : RCTH_UPDATE_S1
 *     DESCRIPTION       : THIS UPDATE PROCEDURE IS USED TO APPROVE THE IDENTIFICATION OF RECEIPTS BASED ON DISTRIBUTION DATE AND END VALIDITY DATE.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
   DECLARE 
      	@Ld_High_DATE			DATE	 = '12/31/9999',
        @Ld_Low_DATE			DATE	 = '01/01/0001', 
        @Ld_Current_DATE		DATE	 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
        @Li_Zero_NUMB		  	SMALLINT = 0,
        @Ln_RowsAffected_NUMB 	NUMERIC(10);
        
      UPDATE RCTH_Y1  
         SET EndValidity_DATE			= @Ld_Current_DATE, 
            EventGlobalEndSeq_NUMB		= @An_EventGlobalBeginSeqFile_NUMB           
		OUTPUT		
			 Deleted.Batch_DATE , 
			 Deleted.SourceBatch_CODE , 
			 Deleted.Batch_NUMB , 
			 Deleted.SeqReceipt_NUMB , 
			 Deleted.SourceReceipt_CODE , 
			 Deleted.TypeRemittance_CODE , 
			 Deleted.TypePosting_CODE, 
			 @An_Case_IDNO	, 
			 Deleted.PayorMCI_IDNO , 
			 Deleted.Receipt_AMNT , 
			 @An_ToDistribute_AMNT	, 
			 Deleted.Fee_AMNT , 
			 Deleted.Employer_IDNO , 
			 Deleted.Fips_CODE , 
			 Deleted.Check_DATE , 
			 Deleted.CheckNo_Text , 
			 Deleted.Receipt_DATE , 
			 @Ld_Low_DATE AS Distribute_DATE, 
			 Deleted.Tanf_CODE , 
			 Deleted.TaxJoint_CODE , 
			 Deleted.TaxJoint_NAME , 
			 @Ac_StatusReceipt_CODE  , 
			 @Ac_ReasonStatus_CODE	, 
			 Deleted.BackOut_INDC, 
			 Deleted.ReasonBackOut_CODE, 
			 Deleted.Refund_DATE , 
			 @Ad_Release_DATE	,
			 Deleted.ReferenceIrs_IDNO , 
			 Deleted.RefundRecipient_ID	,
			 Deleted.RefundRecipient_CODE , 
			 @Ld_Current_DATE	AS BeginValidity_DATE, 
			 @Ld_High_DATE	 AS EndValidity_DATE, 
			 @An_EventGlobalBeginSeqFile_NUMB AS EventGlobalBeginSeq_NUMB , 
			 @Li_Zero_NUMB AS EventGlobalEndSeq_NUMB  		
	  INTO
			 RCTH_Y1 
      WHERE         
			Batch_DATE					= @Ad_Batch_DATE  
			AND SourceBatch_CODE			= @Ac_SourceBatch_CODE  
			AND Batch_NUMB					= @An_Batch_NUMB  
			AND SeqReceipt_NUMB				= @An_SeqReceipt_NUMB  
			AND Distribute_DATE				= @Ld_Low_DATE  
			AND EventGlobalBeginSeq_NUMB	= @An_EventGlobalBeginSeq_NUMB  
			AND EndValidity_DATE			= @Ld_High_DATE;
		
      SET 
		@Ln_RowsAffected_NUMB = @@ROWCOUNT;
		
	  SELECT 
		@Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
		
END; --END OF RCTH_UPDATE_S1


GO
