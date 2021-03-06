/****** Object:  StoredProcedure [dbo].[USRL_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_UPDATE_S4](
 @Ac_Worker_ID                   CHAR(30),
 @An_Office_IDNO                 NUMERIC(3) = NULL,
 @Ac_Role_ID                     CHAR(10),
 @Ad_Effective_DATE              DATE,
 @Ad_Expire_DATE                 DATE,
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_TransactionEventSeq_NUMB    NUMERIC(19),
 @An_NewTransactionEventSeq_NUMB NUMERIC(19),
 @Ac_AlphaRangeFrom_CODE         CHAR(5),
 @Ac_AlphaRangeTo_CODE           CHAR(5),
 @Ac_WorkerSub_ID                CHAR(30),
 @Ac_Supervisor_ID               CHAR(30),
 @An_CasesAssigned_QNTY          NUMERIC(10)
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_UPDATE_S4
  *     DESCRIPTION       : End Validity Worker roles in the given office or all offices .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Li_RowsAffected_NUMB INT,
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Update_DTTM       DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Update_DTTM;

  UPDATE USRL_Y1
     SET Worker_ID = @Ac_Worker_ID,
         Office_IDNO = @An_Office_IDNO,
         Role_ID = @Ac_Role_ID,
         Effective_DATE = @Ad_Effective_DATE,
         Expire_DATE = @Ad_Expire_DATE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         BeginValidity_DATE = @Ld_Current_DATE,
         EndValidity_DATE = @Ld_High_DATE,
         TransactionEventSeq_NUMB = @An_NewTransactionEventSeq_NUMB,
         AlphaRangeFrom_CODE = @Ac_AlphaRangeFrom_CODE,
         AlphaRangeTo_CODE = @Ac_AlphaRangeTo_CODE,
         WorkerSub_ID = @Ac_WorkerSub_ID,
         Supervisor_ID = @Ac_Supervisor_ID,
         CasesAssigned_QNTY = @An_CasesAssigned_QNTY
  OUTPUT Deleted.Worker_ID,
         Deleted.Office_IDNO,
         Deleted.Role_ID,
         Deleted.Effective_DATE,
         Deleted.Expire_DATE,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.Update_DTTM,
         Deleted.WorkerUpdate_ID,
         Deleted.AlphaRangeFrom_CODE,
         Deleted.AlphaRangeTo_CODE,
         Deleted.WorkerSub_ID,
         Deleted.Supervisor_ID,
         Deleted.CasesAssigned_QNTY
  INTO USRL_Y1
   WHERE Worker_ID = @Ac_Worker_ID
     AND Office_IDNO = ISNULL(@An_Office_IDNO, Office_IDNO)
     AND Role_ID = ISNULL(@Ac_Role_ID, Role_ID)
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
