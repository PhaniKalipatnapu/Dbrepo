/****** Object:  StoredProcedure [dbo].[AMJR_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_INSERT_S1] (
 @Ac_ActivityMajor_CODE           CHAR(4),
 @Ac_Subsystem_CODE               CHAR(2),
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0),
 @As_DescriptionActivity_TEXT     VARCHAR(75),
 @Ac_MultipleActiveInstance_INDC  CHAR(1), 
 @Ac_Stop_INDC                    CHAR(1),
 @Ac_SignedOnWorker_ID            CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_INSERT_S1
  *     DESCRIPTION       : Inserts a new record with new Sequence Event Transaction for the given Major Activity Code and Subsystem Code
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT AMJR_Y1
         (ActivityMajor_CODE,
          Subsystem_CODE,
          DescriptionActivity_TEXT,
          MultipleActiveInstance_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          Stop_INDC)
  VALUES (@Ac_ActivityMajor_CODE,
           @Ac_Subsystem_CODE,
           @As_DescriptionActivity_TEXT,
           @Ac_MultipleActiveInstance_INDC,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ac_Stop_INDC );
 END; --End Of AMJR_INSERT_S1

GO
