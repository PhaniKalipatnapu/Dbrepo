/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S29](
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @An_EventGlobalSeq_NUMB NUMERIC(19, 0),
 @An_AssessOverpay_AMNT  NUMERIC(11, 2) OUTPUT,
 @An_RecOverpay_AMNT     NUMERIC(11, 2) OUTPUT
 )
AS
 /*                                                                                                                                                                                                                                                 
  *     PROCEDURE NAME    : POFL_RETRIEVE_S29                                                                                                                                                                                                        
  *     DESCRIPTION       : This procedure used to display the details on overpayment and recoupment popup  
  *                         To Get the Before columns                                                                                                                                                                                                                      
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                              
  *     DEVELOPED ON      : 29/11/2011                                                                                                                                                                                                      
  *     MODIFIED BY       :                                                                                                                                                                                                                         
  *     MODIFIED ON       :                                                                                                                                                                                                                         
  *     VERSION NO        : 1                                                                                                                                                                                                                       
  */
 BEGIN
  SELECT @An_AssessOverpay_AMNT = NULL,
         @An_RecOverpay_AMNT    = NULL;

  DECLARE @Lc_TypeRecoupmentRegular_CODE CHAR(1) = 'R';

  SELECT @An_AssessOverpay_AMNT = ((PO.AssessTotOverpay_AMNT + PO.PendTotOffset_AMNT) - (PO.AssessOverpay_AMNT + PO.PendOffset_AMNT)),
         @An_RecOverpay_AMNT    = (PO.RecTotOverpay_AMNT - PO.RecOverpay_AMNT)
    FROM POFL_Y1 PO
   WHERE PO.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND PO.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND PO.Unique_IDNO = (SELECT MIN(P.Unique_IDNO)
                             FROM POFL_Y1 P
                            WHERE P.CheckRecipient_ID   = @Ac_CheckRecipient_ID
                              AND P.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
                              AND P.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                              AND P.TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE)
     AND PO.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
     AND PO.TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE;
     
 END; --END Of Procedure POFL_RETRIEVE_S29 


GO
