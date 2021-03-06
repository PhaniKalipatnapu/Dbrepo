/****** Object:  StoredProcedure [dbo].[PARM_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                                        
                                                                                                        
CREATE PROCEDURE [dbo].[PARM_UPDATE_S1](
 @Ac_Job_ID                   CHAR(7),
 @An_ResponseTime_QNTY        NUMERIC(6, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @Ac_SignedOnWorker_ID		  CHAR(30)               
)                                                                                                  
AS                                                                                                      
                                                                                                        
/*                                                                                                      
*     PROCEDURE NAME    : PARM_UPDATE_S1                                                                
*     DESCRIPTION       : Update,insert the ref job details for a given JobID.
*     DEVELOPED BY      : IMP Team                                                                      
*     DEVELOPED ON      : 02-AUG-2011                                                                   
*     MODIFIED BY       :                                                                               
*     MODIFIED ON       :                                                                               
*     VERSION NO        : 1                                                                             
*/                                                                                                      
                                                                                                        
   BEGIN                                                                                                
   DECLARE @Ld_Current_DTTM      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),                         
    	   @Ld_High_DATE         DATE = '12/31/9999',                                                       
    	   @Ln_RowsAffected_NUMB NUMERIC(10);                                                                
    	                                                                                                   
      UPDATE PARM_Y1                                                                                    
         SET ResponseTime_QNTY=@An_ResponseTime_QNTY, 
			 BeginValidity_DATE=@Ld_Current_DTTM,
			 TransactionEventSeq_NUMB=@An_TransactionEventSeq_NUMB,        
			 WorkerUpdate_ID=@Ac_SignedOnWorker_ID,
			 Update_DTTM=@Ld_Current_DTTM                              
     OUTPUT 
			DELETED.Job_ID, 
			DELETED.Process_NAME,             
			DELETED.Procedure_NAME,           
			DELETED.DescriptionJob_TEXT,      
			DELETED.JobFreq_CODE,             
			DELETED.Run_DATE,                 
			DELETED.CommitFreq_QNTY,          
			DELETED.DayRun_CODE,              
			DELETED.ExceptionThreshold_QNTY,  
			DELETED.FileIo_CODE,              
			DELETED.File_NAME,                
			DELETED.Server_NAME,              
			DELETED.ServerPath_NAME,          
			DELETED.Thread_NUMB,              
			DELETED.StartSeq_NUMB,            
			DELETED.TotalSeq_QNTY,                   
			DELETED.TransactionEventSeq_NUMB,
			DELETED.BeginValidity_DATE,
			@Ld_Current_DTTM AS EndValidity_DATE,
			DELETED.Update_DTTM,           
			DELETED.ResponseTime_QNTY,   
			DELETED.WorkerUpdate_ID,
			DELETED.DescriptionMisc_TEXT                                            
     INTO PARM_Y1                                                                                        
     WHERE Job_ID = @Ac_Job_ID
       AND EndValidity_DATE = @Ld_High_DATE;   
                                                                                                        
      SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;                                                           
                                                                                                        
      SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;                                                
                                                                                                        
END;   -- END OF PARM_UPDATE_S1                                                                         
                                                                                                        

GO
