/****** Object:  StoredProcedure [dbo].[USRL_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_UPDATE_S1](
 @Ac_Worker_ID                   CHAR(30),
 @An_Office_IDNO                 NUMERIC(3),
 @Ac_Role_ID                     CHAR(10),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @Ac_AlphaRangeFrom_CODE         CHAR(5),
 @Ac_AlphaRangeTo_CODE           CHAR(5),
 @An_NewTransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_UPDATE_S1
  *     DESCRIPTION       : Update End Validity date for Worker Idno, Office, Role Idno, and Transaction sequence.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),        
		  @Ld_SystemTime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE USRL_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
  OUTPUT Deleted.Worker_ID,
         Deleted.Office_IDNO,
         Deleted.Role_ID,
         @Ld_Current_DATE AS Effective_DATE,
         Deleted.Expire_DATE,
         Deleted.BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @An_NewTransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
         @Ld_SystemTime_DTTM AS Update_DTTM,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
         @Ac_AlphaRangeFrom_CODE AS AlphaRangeFrom_CODE,
         @Ac_AlphaRangeTo_CODE AS AlphaRangeTo_CODE,
         Deleted.WorkerSub_ID,
         Deleted.Supervisor_ID,
         Deleted.CasesAssigned_QNTY
  INTO USRL_Y1
   WHERE Worker_ID = @Ac_Worker_ID
     AND Office_IDNO = @An_Office_IDNO
     AND Role_ID = @Ac_Role_ID
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
