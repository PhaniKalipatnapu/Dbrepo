/****** Object:  StoredProcedure [dbo].[SWKS_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_UPDATE_S6] (
 @An_Schedule_NUMB				NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID			CHAR(30),
 @An_TransactionEventSeq_NUMB	NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_UPDATE_S6
  *     DESCRIPTION       : Update Worker Delegate ID and Transaction Sequence Number, Worker Idno, Begin Validity Date and Update DateTime to Today's Date for a Schedule Sequence Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
		  @Ld_Current_DATE	DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
		  @Ld_Update_DTTM   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE SWKS_Y1
     SET WorkerDelegateTo_ID = @Ac_SignedOnWorker_ID,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         BeginValidity_DATE = @Ld_Current_DATE,
         Update_DTTM = @Ld_Update_DTTM,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
	OUTPUT
		DELETED.Schedule_NUMB,
		DELETED.Case_IDNO,
		DELETED.Worker_ID,
		DELETED.MemberMci_IDNO,
		DELETED.OthpLocation_IDNO,
		DELETED.ActivityMajor_CODE,
		DELETED.ActivityMinor_CODE,
		DELETED.TypeActivity_CODE,
		DELETED.WorkerDelegateTo_ID,
		DELETED.Schedule_DATE,
		DELETED.BeginSch_DTTM,
		DELETED.EndSch_DTTM,
		DELETED.ApptStatus_CODE,
		DELETED.SchParent_NUMB,
		DELETED.SchPrev_NUMB,
		DELETED.WorkerUpdate_ID,
		DELETED.BeginValidity_DATE,
		@Ld_Current_DATE AS EndValidity_DATE,
		DELETED.Update_DTTM,
		DELETED.TransactionEventSeq_NUMB,
		DELETED.TypeFamisProceeding_CODE,
		DELETED.ReasonAdjourn_CODE,
		DELETED.Worker_NAME,
		DELETED.SchedulingUnit_CODE
	INTO
		HSWKS_Y1
   WHERE Schedule_NUMB = @An_Schedule_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of SWKS_UPDATE_S5   

GO
