/****** Object:  StoredProcedure [dbo].[UCAT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UCAT_UPDATE_S1](   
 @Ac_Udc_CODE		          CHAR(4),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @An_NumDaysHold_QNTY		  NUMERIC(9,0),
 @An_Hold_AMNT		          NUMERIC(11,2),
 @An_NumDaysRefund_QNTY		  NUMERIC(9,0),
 @Ac_ManualBackOut_INDC		  CHAR(1),
 @Ac_ManualRelease_INDC		  CHAR(1),
 @Ac_AutomaticRelease_INDC	  CHAR(1),
 @Ac_ManualRefund_INDC		  CHAR(1),
 @Ac_AutomaticRefund_INDC	  CHAR(1),
 @Ac_ExtendResearch_INDC	  CHAR(1),
 @An_ErDuration_QNTY		  NUMERIC(9,0),
 @An_NumUdcLine_IDNO		  NUMERIC(4,0),
 @Ac_Alert_INDC		          CHAR(1),
 @An_AlertDuration_QNTY		  NUMERIC(9,0),
 @Ac_SignedOnWorker_ID		  CHAR(30)
)            
AS                                                              
                                                            
/*                                                          
*     PROCEDURE NAME    : UCAT_UPDATE_S1                    
*     DESCRIPTION       : Update the valid record for the given udc code.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

BEGIN
      DECLARE @Ld_Current_DTTM      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
    	      @Ld_High_DATE         DATE = '12/31/9999',
    	      @Ln_RowsAffected_NUMB	NUMERIC(10);
    	 
      UPDATE UCAT_Y1
         SET NumDaysHold_QNTY=@An_NumDaysHold_QNTY,         
             Hold_AMNT=@An_Hold_AMNT,                
             NumDaysRefund_QNTY=@An_NumDaysRefund_QNTY,
             ManualBackOut_INDC=@Ac_ManualBackOut_INDC,       
             ManualRelease_INDC=@Ac_ManualRelease_INDC,       
             AutomaticRelease_INDC= @Ac_AutomaticRelease_INDC,    
             ManualRefund_INDC=@Ac_ManualRefund_INDC,        
             AutomaticRefund_INDC=@Ac_AutomaticRefund_INDC,     
             ExtendResearch_INDC=@Ac_ExtendResearch_INDC,      
             ErDuration_QNTY=@An_ErDuration_QNTY,          
             NumUdcLine_IDNO=@An_NumUdcLine_IDNO,          
             Alert_INDC=@Ac_Alert_INDC,               
             AlertDuration_QNTY=@An_AlertDuration_QNTY,       
             WorkerUpdate_ID=@Ac_SignedOnWorker_ID,        
             BeginValidity_DATE=@Ld_Current_DTTM,      
             TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB, 
             Update_DTTM=@Ld_Current_DTTM
      OUTPUT DELETED.Udc_CODE, 
             DELETED.TypeHold_CODE, 
             DELETED.HoldLevel_CODE, 
             DELETED.Initiate_CODE, 
             DELETED.Table_ID, 
             DELETED.TableSub_ID, 
             DELETED.NumDaysHold_QNTY, 
             DELETED.Hold_AMNT, 
             DELETED.NumDaysRefund_QNTY, 
             DELETED.ManualDistribution_INDC, 
             DELETED.ManualBackOut_INDC, 
             DELETED.ManualRelease_INDC, 
             DELETED.AutomaticRelease_INDC, 
             DELETED.ManualRefund_INDC, 
             DELETED.AutomaticRefund_INDC, 
             DELETED.ExtendResearch_INDC, 
             DELETED.ErDuration_QNTY, 
             DELETED.NumUdcLine_IDNO, 
             DELETED.Alert_INDC, 
             DELETED.AlertDuration_QNTY, 
             DELETED.WorkerUpdate_ID, 
             DELETED.BeginValidity_DATE, 
             @Ld_Current_DTTM AS EndValidity_DATE, 
             DELETED.TransactionEventSeq_NUMB, 
             DELETED.Update_DTTM     	
     INTO  UCAT_Y1
     WHERE Udc_CODE = @Ac_Udc_CODE 
       AND EndValidity_DATE = @Ld_High_DATE;
      
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
      
      SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
      
END;--End Of UCAT_UPDATE_S1


GO
