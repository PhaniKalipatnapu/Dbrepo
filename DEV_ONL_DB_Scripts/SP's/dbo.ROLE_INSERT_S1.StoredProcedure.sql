/****** Object:  StoredProcedure [dbo].[ROLE_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROLE_INSERT_S1] (
 @Ac_Role_ID                  CHAR(10),
 @As_Role_NAME                VARCHAR(50),
 @Ac_RoleSpecialist_INDC      CHAR(1),
 @Ad_Effective_DATE           DATE,
 @Ad_Expire_DATE              DATE,
 @Ac_StateRole_INDC           CHAR(1),
 @Ac_SupervisorRole_INDC      CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*  
 *     PROCEDURE NAME    : ROLE_INSERT_S1  
  *     DESCRIPTION       : Insert details into Roles Reference table.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 10/12/2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_High_DATE DATE ='12/31/9999';

  INSERT ROLE_Y1
         (Role_ID,
          Role_NAME,
          RoleSpecialist_INDC,
          Effective_DATE,
          Expire_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          WorkerUpdate_ID,
          StateRole_INDC,
          SupervisorRole_INDC)
  SELECT   @Ac_Role_ID,
           @As_Role_NAME,
           @Ac_RoleSpecialist_INDC,
           @Ad_Effective_DATE,
           @Ad_Expire_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ac_StateRole_INDC,
           @Ac_SupervisorRole_INDC 
           WHERE NOT EXISTS (SELECT 1 
								FROM ROLE_Y1 R WITH ( READUNCOMMITTED ) 
								WHERE R.Role_ID = @Ac_Role_ID
								--AND R.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
								);
 END


GO
