/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S2] (    
 @Ac_CheckRecipient_ID		CHAR(10),              
 @Ac_CheckRecipient_CODE	CHAR(1)
 )                
AS    
 /*    
  *     PROCEDURE NAME    : POFL_RETRIEVE_S2    
  *     DESCRIPTION       : Retrieve to get the Payee Offset balance details used to display in the recoupment payee grid.   
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-DEC-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */    
 BEGIN  
  DECLARE @Lc_RecoupmentPayeeState_CODE	CHAR(1) = 'S';     
            
      SELECT l.PendTotOffset_AMNT ,     
         	 l.RecTotAdvance_AMNT ,     
         	 l.AssessTotOverpay_AMNT ,     
         	 l.RecTotOverpay_AMNT ,     
         	 (l.PendTotOffset_AMNT + l.AssessTotOverpay_AMNT) AS TotToRecover_AMNT,     
         	 (l.RecTotAdvance_AMNT + l.RecTotOverpay_AMNT) AS TotRecovered_AMNT,     
         	 ((l.PendTotOffset_AMNT - l.RecTotAdvance_AMNT) + (l.AssessTotOverpay_AMNT - l.RecTotOverpay_AMNT)) AS TotBalanceDue_AMNT,     
         	 (l.PendTotOffset_AMNT - l.RecTotAdvance_AMNT) AS PendingBalanceDue_AMNT,     
         	 (l.AssessTotOverpay_AMNT - l.RecTotOverpay_AMNT) AS ActiveBalanceDue_AMNT,     
         	 l.RecoupmentPayee_CODE ,     
         	 l.EventGlobalSeq_NUMB     
        FROM POFL_Y1 l 
          JOIN ( SELECT MAX(m.Unique_IDNO) AS Unique_IDNO 
         		   FROM POFL_Y1 m    
         		  WHERE m.CheckRecipient_ID = @Ac_CheckRecipient_ID 
         		    AND m.CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
         		    AND m.RecoupmentPayee_CODE = @Lc_RecoupmentPayeeState_CODE 
         		) r
         	ON l.Unique_IDNO = r.Unique_IDNO
       WHERE l.CheckRecipient_ID = @Ac_CheckRecipient_ID 
         AND l.CheckRecipient_CODE = @Ac_CheckRecipient_CODE ;
         					 
END; --END OF POFL_RETRIEVE_S2   

GO
