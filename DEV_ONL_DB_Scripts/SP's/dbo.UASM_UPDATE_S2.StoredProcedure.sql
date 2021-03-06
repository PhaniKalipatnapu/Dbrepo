/****** Object:  StoredProcedure [dbo].[UASM_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_UPDATE_S2](
 @Ac_Worker_ID                   CHAR(30),
 @An_Office_IDNO                 NUMERIC(3) = NULL,
 @An_WorkPhone_NUMB              NUMERIC(15),
 @Ad_Effective_DATE              DATE,
 @Ad_Expire_DATE                 DATE,
 @An_TransactionEventSeq_NUMB    NUMERIC(19),
 @An_NewTransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID           CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : UASM_UPDATE_S2
  *     DESCRIPTION       : Logically delete the valid record for a Worker ID, Unique Office code and Unique Sequence Number where end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/04/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

  UPDATE UASM_Y1
     SET Worker_ID = @Ac_Worker_ID,
         Office_IDNO = @An_Office_IDNO,
         WorkPhone_NUMB = @An_WorkPhone_NUMB,
         Effective_DATE = @Ad_Effective_DATE,
         Expire_DATE = @Ad_Expire_DATE,
         BeginValidity_DATE = @Ld_Current_DATE,
         EndValidity_DATE = @Ld_High_DATE,
         TransactionEventSeq_NUMB = @An_NewTransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Current_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID
  OUTPUT Deleted.Worker_ID,
         Deleted.Office_IDNO,
         Deleted.WorkPhone_NUMB,
         Deleted.Effective_DATE,
         Deleted.Expire_DATE,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.Update_DTTM,
         Deleted.WorkerUpdate_ID
  INTO UASM_Y1
   WHERE Worker_ID = @Ac_Worker_ID
     AND Office_IDNO = ISNULL(@An_Office_IDNO, Office_IDNO)
     AND EndValidity_DATE = @Ld_High_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
