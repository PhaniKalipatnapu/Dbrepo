/****** Object:  StoredProcedure [dbo].[USES_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USES_UPDATE_S1](
 @Ac_Worker_ID                CHAR(30),
 @As_ESignature_BIN			  VARCHAR(4000),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*    
  *     PROCEDURE NAME    : HUSES_INSERT_S1    
  *     DESCRIPTION       : Logically delete the valid record for a Worker ID and Unique Sequence Number 
 							where end date validity is high date.    
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/07/2011
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_Current_DTTM DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

  UPDATE USES_Y1
     SET ESignature_BIN = CONVERT(VARBINARY(4000),@As_ESignature_BIN),
         BeginValidity_DATE = @Ld_Current_DATE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         Update_DTTM = @Ld_Current_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT Deleted.Worker_ID,
         Deleted.ESignature_BIN,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.Update_DTTM,
         DELETED.TransactionEventSeq_NUMB
  INTO HUSES_Y1
   WHERE Worker_ID = @Ac_Worker_ID;
  
  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
  
 END -- END OF USES_UPDATE_S1


GO
