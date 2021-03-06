/****** Object:  StoredProcedure [dbo].[ROLE_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*     PROCEDURE NAME    : ROLE_UPDATE_S1
 *     DESCRIPTION       : Update the End Validity Date for a Role Idno.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10/12/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
CREATE PROCEDURE [dbo].[ROLE_UPDATE_S1]( 
     @Ac_Role_ID                     CHAR(10),
     @Ac_StateRole_INDC              CHAR(1) ,
     @An_TransactionEventSeq_NUMB NUMERIC(19) ,
     @An_NewTransactionEventSeq_NUMB    NUMERIC(19),
     @Ac_SignedOnWorker_ID          CHAR(30)
    )             
AS
  BEGIN
      DECLARE @Ld_Current_DTTM   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
      DECLARE @Ld_Current_DATE  DATE      = @Ld_Current_DTTM,
              @Ld_High_DATE     DATE      = '12/31/9999'; 
        
      UPDATE ROLE_Y1
         SET StateRole_INDC           = @Ac_StateRole_INDC ,
             TransactionEventSeq_NUMB = @An_NewTransactionEventSeq_NUMB ,
             WorkerUpdate_ID          = @Ac_SignedOnWorker_ID ,
             Update_DTTM              = @Ld_Current_DTTM
         OUTPUT Deleted.Role_ID , 
				Deleted.Role_NAME , 
				Deleted.RoleSpecialist_INDC , 
				Deleted.Effective_DATE , 
				Deleted.Expire_DATE , 
				Deleted.BeginValidity_DATE , 
				@Ld_Current_DATE AS EndValidity_DATE , 
				Deleted.TransactionEventSeq_NUMB , 
				Deleted.Update_DTTM , 
				Deleted.WorkerUpdate_ID , 
				Deleted.StateRole_INDC , 
				Deleted.SupervisorRole_INDC  
          INTO ROLE_Y1
       WHERE   Role_ID                   = @Ac_Role_ID 
           AND TransactionEventSeq_NUMB  = @An_TransactionEventSeq_NUMB
           AND EndValidity_DATE          = @Ld_High_DATE ;
      
      DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT ;
      SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB ;
END


GO
