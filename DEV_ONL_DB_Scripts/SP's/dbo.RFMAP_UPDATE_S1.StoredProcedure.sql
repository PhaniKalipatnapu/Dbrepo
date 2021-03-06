/****** Object:  StoredProcedure [dbo].[RFMAP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RFMAP_UPDATE_S1] (
 @Ad_Begin_DATE                  DATE,
 @An_TransactionEventSeqOld_NUMB NUMERIC(19, 0),
 @An_Amount_PCT                  NUMERIC(5, 2),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RFMAP_UPDATE_S1
  *     DESCRIPTION       : This procedure updates the Federal Medical Percentage
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE RFMAP_Y1
     SET Amount_PCT = @An_Amount_PCT,
         BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
         EndValidity_DATE = @Ld_High_DATE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         Update_DTTM = @Ld_Systemdatetime_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT Deleted.Begin_DATE,
         Deleted.End_DATE,
         Deleted.Amount_PCT,
         Deleted.BeginValidity_DATE,
         @Ld_Systemdatetime_DTTM AS EndValidity_DATE,
         Deleted.WorkerUpdate_ID,
         Deleted.Update_DTTM,
         Deleted.TransactionEventSeq_NUMB
  INTO RFMAP_Y1
   WHERE Begin_DATE = @Ad_Begin_DATE
     AND End_DATE = @Ld_High_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB;
 END; --END OF RFMAP_UPDATE_S1

GO
