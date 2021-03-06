/****** Object:  StoredProcedure [dbo].[ROLE_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ROLE_RETRIEVE_S6](
 @Ac_Role_ID                  CHAR(10),
 @As_Role_NAME                VARCHAR(50) OUTPUT,
 @Ac_RoleSpecialist_INDC      CHAR(1) OUTPUT,
 @Ad_Effective_DATE           DATE OUTPUT,
 @Ad_Expire_DATE              DATE OUTPUT,
 @Ad_BeginValidity_DATE       DATE OUTPUT,
 @Ac_StateRole_INDC           CHAR(1) OUTPUT,
 @Ac_SupervisorRole_INDC      CHAR(1) OUTPUT,
 @Ad_Update_DTTM              DATETIME2 OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ROLE_RETRIEVE_S6
  *     DESCRIPTION       : Retrive Role Data
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/11/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_Role_NAME = R.Role_NAME,
         @Ac_RoleSpecialist_INDC = R.RoleSpecialist_INDC,
         @Ad_Effective_DATE = R.Effective_DATE,
         @Ad_Expire_DATE = R.Expire_DATE,
         @Ad_BeginValidity_DATE = R.BeginValidity_DATE,
         @Ac_StateRole_INDC = R.StateRole_INDC,
         @Ac_SupervisorRole_INDC = R.SupervisorRole_INDC,
         @Ad_Update_DTTM = R.Update_DTTM,
         @Ac_WorkerUpdate_ID = R.WorkerUpdate_ID,
         @An_TransactionEventSeq_NUMB = R.TransactionEventSeq_NUMB
    FROM ROLE_Y1 R
   WHERE R.Role_ID = @Ac_Role_ID
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END


GO
