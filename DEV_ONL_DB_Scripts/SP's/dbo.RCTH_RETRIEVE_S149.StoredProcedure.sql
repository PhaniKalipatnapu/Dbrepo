/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S149]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S149](    
 @Ad_Batch_DATE          DATE,    
 @Ac_SourceBatch_CODE    CHAR(3),    
 @An_Batch_NUMB          NUMERIC(4),    
 @An_SeqReceipt_NUMB     NUMERIC(6),    
 @Ad_Receipt_DATE        DATE           OUTPUT,    
 @An_PayorMCI_IDNO       NUMERIC(10)    OUTPUT,    
 @Ac_SourceReceipt_CODE  CHAR(2)        OUTPUT,    
 @An_Receipt_AMNT        NUMERIC(11,2)  OUTPUT ,
 @Ac_TypeRemittance_CODE  CHAR(3)       OUTPUT,
 @An_ToDistribute_AMNT    NUMERIC(11,2) OUTPUT, 
 @An_Fee_AMNT             NUMERIC(11,2) OUTPUT, 
 @An_Employer_IDNO        NUMERIC(9,0)  OUTPUT, 
 @Ac_Fips_CODE            CHAR(7)       OUTPUT, 
 @Ad_Check_DATE           DATE          OUTPUT, 
 @Ac_CheckNo_TEXT         CHAR(18)      OUTPUT,
 @Ac_Tanf_CODE            CHAR(1)       OUTPUT, 
 @Ac_TaxJoint_CODE        CHAR(1)       OUTPUT, 
 @Ac_ReasonStatus_CODE    CHAR(4)       OUTPUT, 
 @Ac_TaxJoint_NAME        CHAR(35)      OUTPUT     
 )    
AS    
 /*                                                                                                                                                                                                 
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S149                                                                                                                                                       
  *     DESCRIPTION       : This Procedure populates the data for 'Receipts on Hold Details ' pop up.    
          This pop up displays the  Receipts on Hold Details pop-up view displays all    
       receipts on hold associated with the Case ID entered for inquiry.                                                                                                                                                                        
  *     DEVELOPED BY      : IMP Team                                                                                                                                                              
  *     DEVELOPED ON      : 30/10/2011                                                                                                                                                            
  *     MODIFIED BY       :                                                                                                                                                                         
  *     MODIFIED ON       :                                                                                                                                                                         
  *     VERSION NO        : 1                                                                                                                                                                       
 */    
 BEGIN    
  SELECT @Ad_Receipt_DATE  = NULL,    
         @An_Receipt_AMNT       = NULL,    
         @Ac_SourceReceipt_CODE = NULL,    
         @An_PayorMCI_IDNO      = NULL,
         @Ac_TypeRemittance_CODE = NULL,
		 @An_Employer_IDNO = NULL,
		 @Ac_Fips_CODE = NULL,           
		 @An_ToDistribute_AMNT = NULL, 
		 @Ad_Check_DATE =  NULL,        
		 @Ac_CheckNo_TEXT = NULL,       
		 @Ac_TaxJoint_NAME = NULL,      
		 @An_Fee_AMNT = NULL,           
		 @Ac_Tanf_CODE = NULL,          
		 @Ac_TaxJoint_CODE = NULL,      
		 @Ac_ReasonStatus_CODE =NULL;      
    
  DECLARE @Ld_High_DATE DATE = '12/31/9999';    
    
  SELECT @Ac_SourceReceipt_CODE = R.SourceReceipt_CODE,    
         @An_Receipt_AMNT = R.Receipt_AMNT,    
         @Ad_Receipt_DATE = R.Receipt_DATE,    
         @An_PayorMCI_IDNO = R.PayorMCI_IDNO,
         @Ac_TypeRemittance_CODE = R.TypeRemittance_CODE,                     
		 @An_Employer_IDNO = R.Employer_IDNO,                                 
		 @Ac_Fips_CODE = R.Fips_CODE, 
		 @An_ToDistribute_AMNT = R.ToDistribute_AMNT, 
		 @Ad_Check_DATE = R.Check_DATE,                     
		 @Ac_CheckNo_TEXT = R.CheckNo_Text,                 
		 @Ac_TaxJoint_NAME = R.TaxJoint_NAME,               
		 @An_Fee_AMNT = R.Fee_AMNT,                         
		 @Ac_Tanf_CODE = R.Tanf_CODE,                       
		 @Ac_TaxJoint_CODE = R.TaxJoint_CODE,
		 @Ac_ReasonStatus_CODE = R.ReasonStatus_CODE        
    FROM RCTH_Y1 R    
   WHERE R.Batch_DATE = @Ad_Batch_DATE    
     AND R.SourceBatch_CODE = @Ac_SourceBatch_CODE    
     AND R.Batch_NUMB = @An_Batch_NUMB    
     AND R.SeqReceipt_NUMB = @An_SeqReceipt_NUMB     
     AND R.EndValidity_DATE = @Ld_High_DATE;    
         
 END; --End Of Procedure RCTH_RETRIEVE_S149    
     
GO
