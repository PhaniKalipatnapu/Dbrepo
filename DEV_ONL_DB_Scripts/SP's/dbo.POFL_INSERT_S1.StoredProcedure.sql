/****** Object:  StoredProcedure [dbo].[POFL_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_INSERT_S1] (
 @Ac_CheckRecipient_ID			CHAR(10),
 @Ac_CheckRecipient_CODE		CHAR(1),
 @An_Case_IDNO		 			NUMERIC(6,0),
 @An_OrderSeq_NUMB		 		NUMERIC(2,0),
 @An_ObligationSeq_NUMB		 	NUMERIC(2,0),
 @Ac_Transaction_CODE		 	CHAR(4),
 @Ac_TypeDisburse_CODE		 	CHAR(5),
 @Ac_Reason_CODE           		CHAR(2),
 @An_PendOffset_AMNT		 	NUMERIC(11,2),
 @An_PendTotOffset_AMNT		 	NUMERIC(11,2),
 @An_RecAdvance_AMNT		 	NUMERIC(11,2),
 @An_RecTotAdvance_AMNT		 	NUMERIC(11,2),
 @An_AssessOverpay_AMNT		 	NUMERIC(11,2),
 @An_AssessTotOverpay_AMNT		NUMERIC(11,2),
 @An_RecOverpay_AMNT		 	NUMERIC(11,2),
 @An_RecTotOverpay_AMNT		 	NUMERIC(11,2),
 @Ad_Batch_DATE					DATE,
 @Ac_SourceBatch_CODE		 	CHAR(3),
 @An_Batch_NUMB            		NUMERIC(4,0),
 @An_SeqReceipt_NUMB		 	NUMERIC(6,0),
 @An_EventGlobalSeq_NUMB		NUMERIC(19,0),
 @An_EventGlobalSupportSeq_NUMB	NUMERIC(19,0),
 @Ac_TypeRecoupment_CODE		CHAR(1)
 )
AS

/*
 *     PROCEDURE NAME    : POFL_INSERT_S1
 *     DESCRIPTION       : Insert the PayeeOffsetLog details for provided values.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 01-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
  DECLARE @Ld_Current_DATE        		DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
  		  @Lc_RecoupmentPayeeState_CODE	CHAR(1) = 'S';
   
      INSERT POFL_Y1
      		(CheckRecipient_ID,        
         	 CheckRecipient_CODE,        
         	 Case_IDNO,                  
         	 OrderSeq_NUMB,                  
         	 ObligationSeq_NUMB,             
         	 Transaction_CODE,           
         	 Transaction_DATE,           
         	 TypeDisburse_CODE,          
         	 Reason_CODE,                
         	 PendOffset_AMNT,            
         	 PendTotOffset_AMNT,         
         	 RecAdvance_AMNT,            
         	 RecTotAdvance_AMNT,         
         	 AssessOverpay_AMNT,         
         	 AssessTotOverpay_AMNT,      
         	 RecOverpay_AMNT,            
         	 RecTotOverpay_AMNT,         
         	 Batch_DATE,                 
         	 SourceBatch_CODE,           
         	 Batch_NUMB,                 
         	 SeqReceipt_NUMB,            
         	 EventGlobalSeq_NUMB,            
         	 EventGlobalSupportSeq_NUMB,     
         	 TypeRecoupment_CODE,        
         	 RecoupmentPayee_CODE )       
     VALUES ( @Ac_CheckRecipient_ID, 
              @Ac_CheckRecipient_CODE, 
              @An_Case_IDNO, 
              @An_OrderSeq_NUMB, 
              @An_ObligationSeq_NUMB, 
              @Ac_Transaction_CODE, 
              @Ld_Current_DATE, 
              @Ac_TypeDisburse_CODE, 
              @Ac_Reason_CODE, 
              @An_PendOffset_AMNT, 
              @An_PendTotOffset_AMNT, 
              @An_RecAdvance_AMNT, 
              @An_RecTotAdvance_AMNT, 
              @An_AssessOverpay_AMNT, 
              @An_AssessTotOverpay_AMNT, 
              @An_RecOverpay_AMNT, 
              @An_RecTotOverpay_AMNT, 
              @Ad_Batch_DATE, 
              @Ac_SourceBatch_CODE, 
              @An_Batch_NUMB, 
              @An_SeqReceipt_NUMB, 
              @An_EventGlobalSeq_NUMB, 
              @An_EventGlobalSupportSeq_NUMB, 
              @Ac_TypeRecoupment_CODE, 
              @Lc_RecoupmentPayeeState_CODE );

END;  -- END OF POFL_INSERT_S1


GO
