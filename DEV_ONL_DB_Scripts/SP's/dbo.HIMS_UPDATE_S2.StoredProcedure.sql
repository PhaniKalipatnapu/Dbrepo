/****** Object:  StoredProcedure [dbo].[HIMS_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[HIMS_UPDATE_S2](   
 @Ac_SourceReceipt_CODE		 	CHAR(2),
 @An_TransactionEventSeq_NUMB   NUMERIC(19,0),
 @Ac_SignedOnWorker_ID		 	CHAR(30)  
)            
AS                                                              
                                                            
/*                                                          
*     PROCEDURE NAME    : HIMS_UPDATE_S2                    
*     DESCRIPTION       : Update the Hold Instruction Details for the given Source Receipt and High Date.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

BEGIN
   DECLARE @Ld_Current_DTTM       DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
    	   @Ld_High_DATE          DATE = '12/31/9999',
    	   @Ln_RowsAffected_NUMB	NUMERIC(10);
    	 
      UPDATE HIMS_Y1
         SET WorkerUpdate_ID = @Ac_SignedOnWorker_ID, 
             BeginValidity_DATE = @Ld_Current_DTTM,
             Update_DTTM = @Ld_Current_DTTM, 
             TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
      OUTPUT DELETED.SourceReceipt_CODE,
             DELETED.DistNonIvd_INDC,
     	     DELETED.UdcDistNonIvd_CODE,
     	     DELETED.CaseHold_INDC,
     	     DELETED.UdcCaseHold_CODE,
     	     DELETED.WorkerUpdate_ID,
     	     DELETED.BeginValidity_DATE,
     	     @Ld_Current_DTTM AS EndValidity_DATE,
     	     DELETED.Update_DTTM,
     	     DELETED.TransactionEventSeq_NUMB,
     	     DELETED.TypePosting_CODE
      INTO HIMS_Y1
     WHERE SourceReceipt_CODE = @Ac_SourceReceipt_CODE 
       AND EndValidity_DATE = @Ld_High_DATE;
      
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
      
      SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
      
END;--End Of HIMS_UPDATE_S2


GO
