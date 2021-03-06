/****** Object:  StoredProcedure [dbo].[SWKS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_INSERT_S1] (
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_Worker_ID                CHAR(30),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_OthpLocation_IDNO        NUMERIC(9, 0),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_WorkerDelegateTo_ID      CHAR(30),
 @Ac_TypeActivity_CODE        CHAR(1),
 @Ad_Schedule_DATE            DATE,
 @Ad_BeginSch_DTTM            DATETIME2,
 @Ad_EndSch_DTTM              DATETIME2,
 @Ac_ApptStatus_CODE          CHAR(2),
 @An_SchParent_NUMB           NUMERIC(10, 0),
 @An_SchPrev_NUMB             NUMERIC(10, 0),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeFamisProceeding_CODE  CHAR(5),
 @Ac_ReasonAdjourn_CODE       CHAR(3),
 @As_Worker_NAME              VARCHAR(78),
 @Ac_SchedulingUnit_CODE      CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : SWKS_INSERT_S1
  *     DESCRIPTION       : Insert details into Schedule table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT SWKS_Y1
         (Schedule_NUMB,
          Case_IDNO,
          Worker_ID,
          MemberMci_IDNO,
          OthpLocation_IDNO,
          ActivityMajor_CODE,
          ActivityMinor_CODE,
          WorkerDelegateTo_ID,
          TypeActivity_CODE,
          Schedule_DATE,
          BeginSch_DTTM,
          EndSch_DTTM,
          ApptStatus_CODE,
          SchParent_NUMB,
          SchPrev_NUMB,
          WorkerUpdate_ID,
          BeginValidity_DATE,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          TypeFamisProceeding_CODE,
          ReasonAdjourn_CODE,
          Worker_NAME,
          SchedulingUnit_CODE)
  VALUES ( @An_Schedule_NUMB,
           @An_Case_IDNO,
           @Ac_Worker_ID,
           @An_MemberMci_IDNO,
           @An_OthpLocation_IDNO,
           @Ac_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE,
           @Ac_WorkerDelegateTo_ID,
           @Ac_TypeActivity_CODE,
           @Ad_Schedule_DATE,
           @Ad_BeginSch_DTTM,
           @Ad_EndSch_DTTM,
           @Ac_ApptStatus_CODE,
           @An_SchParent_NUMB,
           @An_SchPrev_NUMB,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ac_TypeFamisProceeding_CODE,
           @Ac_ReasonAdjourn_CODE,
           @As_Worker_NAME,
           @Ac_SchedulingUnit_CODE );
 END; --End of SWKS_INSERT_S1

GO
