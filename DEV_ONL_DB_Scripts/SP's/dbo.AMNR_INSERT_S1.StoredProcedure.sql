/****** Object:  StoredProcedure [dbo].[AMNR_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_INSERT_S1] (
 @Ac_ActivityMinor_CODE       CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeActivity_CODE        CHAR(1),
 @As_DescriptionActivity_TEXT VARCHAR(75),
 @An_DayToComplete_QNTY       NUMERIC(3, 0),
 @Ac_ActionAlert_CODE         CHAR(1),
 @Ac_Element_ID				  CHAR(10),
 @An_DayAlertWarn_QNTY        NUMERIC(3, 0),
 @Ac_MemberCombinations_CODE  CHAR(1),
 @Ac_TypeLocation1_CODE       CHAR(1),
 @Ac_TypeLocation2_CODE       CHAR(1),
 @Ac_ScreenFunction_CODE      CHAR(10),
 @Ac_BusinessDays_INDC        CHAR(1),
 @Ac_CaseJournal_INDC         CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : AMNR_INSERT_S1
  *     DESCRIPTION       : Inserts a new record with new Sequence Event Transaction for the given Minor Activity Code 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT AMNR_Y1
         (ActivityMinor_CODE,
          TypeActivity_CODE,
          DescriptionActivity_TEXT,
          DayToComplete_QNTY,
          ActionAlert_CODE,
          Element_ID,
          DayAlertWarn_QNTY,
          MemberCombinations_CODE,
          TypeLocation1_CODE,
          TypeLocation2_CODE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          ScreenFunction_CODE,
          BusinessDays_INDC,
          CaseJournal_INDC)
  VALUES ( @Ac_ActivityMinor_CODE,
           @Ac_TypeActivity_CODE,
           @As_DescriptionActivity_TEXT,
           @An_DayToComplete_QNTY,
           @Ac_ActionAlert_CODE,
           @Ac_Element_ID,
           @An_DayAlertWarn_QNTY,
           @Ac_MemberCombinations_CODE,
           @Ac_TypeLocation1_CODE,
           @Ac_TypeLocation2_CODE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ac_ScreenFunction_CODE,
           @Ac_BusinessDays_INDC,
           @Ac_CaseJournal_INDC );
 END; --End Of AMNR_INSERT_S1

GO
