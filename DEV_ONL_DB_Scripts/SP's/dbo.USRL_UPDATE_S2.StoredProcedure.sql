/****** Object:  StoredProcedure [dbo].[USRL_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_UPDATE_S2](
 @Ac_Worker_ID                   CHAR(30),
 @An_Office_IDNO                 NUMERIC(3) = NULL,
 @Ad_Expire_DATE                 DATE,
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_NewTransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_UPDATE_S2
  *     DESCRIPTION       : Update End Validity  Worker roles in the given office or all offices .
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
     SET EndValidity_DATE = @Ld_Current_DATE
  OUTPUT Deleted.Worker_ID,
         Deleted.Office_IDNO,
         Deleted.Role_ID,
         Deleted.Effective_DATE,
         @Ad_Expire_DATE AS Expire_DATE,
         @Ld_Current_DATE AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @An_NewTransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
         @Ld_Update_DTTM AS Update_DTTM,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
         Deleted.AlphaRangeFrom_CODE,
         Deleted.AlphaRangeTo_CODE,
         Deleted.WorkerSub_ID,
         Deleted.Supervisor_ID,
         Deleted.CasesAssigned_QNTY
  INTO USRL_Y1
   WHERE Worker_ID = @Ac_Worker_ID
     AND Office_IDNO = ISNULL(@An_Office_IDNO, Office_IDNO)
     AND Expire_DATE >= @Ld_Current_DATE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
