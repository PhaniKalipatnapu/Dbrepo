/****** Object:  StoredProcedure [dbo].[NOST_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NOST_UPDATE_S2](  
 @Ac_Worker_ID         CHAR(30),  
 @As_Pin_TEXT          VARCHAR(64),  
 @Ac_SignedOnWorker_ID CHAR(30),  
 @An_TransactionEventSeq_NUMB NUMERIC(19)  
 )  
AS  
  /*      
   *     PROCEDURE NAME    : NOST_UPDATE_S2      
   *     DESCRIPTION       : Logically delete the valid record for a Worker ID and Unique Sequence Number   
                                           where end date validity is high date.      
   *     DEVELOPED BY      : IMP Team  
   *     DEVELOPED ON      : 10/20/2011  
   *     MODIFIED BY       :       
   *     MODIFIED ON       :       
   *     VERSION NO        : 1.0  
   */  
 BEGIN  
  DECLARE @Ld_Current_DTTM DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;  
  
  UPDATE NOST_Y1  
     SET Pin_TEXT = @As_Pin_TEXT,  
         BeginValidity_DATE = @Ld_Current_DATE,  
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,  
         Update_DTTM = @Ld_Current_DTTM,  
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB  
   OUTPUT   
            Deleted.Worker_ID ,   
            Deleted.Line1_TEXT ,   
            Deleted.Line2_TEXT ,   
            Deleted.Line3_TEXT ,   
            Deleted.Expiry_DATE ,   
            Deleted.Pin_TEXT ,   
            Deleted.BeginValidity_DATE ,   
            Deleted.WorkerUpdate_ID ,   
            Deleted.Update_DTTM ,   
            @Ld_Current_DATE AS EndValidity_DATE ,  
            Deleted.TransactionEventSeq_NUMB  
      INTO HNOST_Y1  
   WHERE Worker_ID = @Ac_Worker_ID;  
     
 DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;  
  
 SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;  
   
 END -- END OF NOST_UPDATE_S2  
GO
