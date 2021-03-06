/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S30]  
(
     @Ad_Batch_DATE				DATE,
     @An_Batch_NUMB         	NUMERIC(4,0) ,
     @Ac_SourceBatch_CODE		CHAR(3),
     @An_SeqReceipt_NUMB		NUMERIC(6,0),
     @An_EventGlobalEndSeq_NUMB	NUMERIC(19,0)

 )                          	
AS

/*
*     PROCEDURE NAME    : RCTH_RETRIEVE_S30
*     DESCRIPTION       : Procedure is used to get the receipt details.
*     DEVELOPED BY      : IMP Team.
*     DEVELOPED ON      : 02-OCT-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
   BEGIN


      DECLARE
        
         @Ld_Current_DATE 	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      SELECT R.Batch_DATE             ,
         R.SourceBatch_CODE       ,
         R.Batch_NUMB             ,
         R.SeqReceipt_NUMB        ,
         R.SourceReceipt_CODE     ,
         R.TypeRemittance_CODE    ,
         R.TypePosting_CODE       ,
         R.Case_IDNO              ,
         R.PayorMCI_IDNO          ,
         R.Receipt_AMNT           ,
         R.Fee_AMNT               ,
         R.Employer_IDNO          ,
         R.Fips_CODE              ,
         R.Check_DATE             ,
         R.CheckNo_Text           ,
         R.Receipt_DATE           ,
         R.Tanf_CODE              ,
         R.TaxJoint_CODE          ,
         R.TaxJoint_NAME          ,
         R.StatusReceipt_CODE     ,
         R.ReasonStatus_CODE      ,
         R.BackOut_INDC           ,
         R.ReasonBackOut_CODE     ,
         R.Release_DATE           ,
         R.Refund_DATE            ,
         R.ReferenceIrs_IDNO      ,
         R.RefundRecipient_ID     ,
         R.RefundRecipient_CODE           
      FROM RCTH_Y1 R              
      WHERE 
         R.Batch_DATE = @Ad_Batch_DATE  
      AND R.SourceBatch_CODE = @Ac_SourceBatch_CODE 
      AND R.Batch_NUMB = @An_Batch_NUMB  
      AND R.SeqReceipt_NUMB = @An_SeqReceipt_NUMB  
      AND R.EndValidity_DATE = @Ld_Current_DATE  
      AND R.EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB;

                  
END;--End of RCTH_RETRIEVE_S30


GO
