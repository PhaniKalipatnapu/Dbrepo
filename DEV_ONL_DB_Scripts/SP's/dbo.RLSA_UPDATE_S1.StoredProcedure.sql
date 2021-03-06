/****** Object:  StoredProcedure [dbo].[RLSA_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RLSA_UPDATE_S1](
 @Ac_Screen_ID                   CHAR(4),
 @Ac_Role_ID                     CHAR(10),
 @Ac_ScreenFunction_CODE         CHAR(10),
 @Ac_Access_INDC                 CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_NewTransactionEventSeq_NUMB    NUMERIC(19),
 @Ac_SignedOnWorker_ID           CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME   : RLSA_UPDATE_S1
  *     DESCRIPTION       : Update the End Validity Date for a Role Idno, Screen Idno, Screen Function, and Transaction Event.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/12/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;
  DECLARE @Ld_High_DATE DATE ='12/31/9999';


  UPDATE RLSA_Y1
     SET Access_INDC              = @Ac_Access_INDC              ,
         WorkerUpdate_ID          = @Ac_SignedOnWorker_ID        ,
         Update_DTTM              = @Ld_Current_DTTM             ,
         TransactionEventSeq_NUMB = @An_NewTransactionEventSeq_NUMB
     OUTPUT Deleted.Screen_ID , 
				Deleted.Role_ID , 
				Deleted.ScreenFunction_CODE , 
				Deleted.Access_INDC , 
				Deleted.BeginValidity_DATE , 
				@Ld_Current_DATE AS EndValidity_DATE , 
				Deleted.TransactionEventSeq_NUMB , 
				Deleted.Update_DTTM , 
				Deleted.WorkerUpdate_ID  
      INTO  RLSA_Y1       
   WHERE Screen_ID                = @Ac_Screen_ID
     AND Role_ID                  = @Ac_Role_ID
     AND ScreenFunction_CODE      = @Ac_ScreenFunction_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE         = @Ld_High_DATE;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
