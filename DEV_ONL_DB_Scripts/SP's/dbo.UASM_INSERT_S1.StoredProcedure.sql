/****** Object:  StoredProcedure [dbo].[UASM_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_INSERT_S1](
 @Ac_Worker_ID                CHAR(30),
 @An_Office_IDNO              NUMERIC(3),
 @An_WorkPhone_NUMB           NUMERIC(15),
 @Ad_Effective_DATE           DATE,
 @Ad_Expire_DATE              DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : UASM_INSERT_S1
  *     DESCRIPTION       : Insert User Office details with the provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 19/10/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_High_DATE DATE ='12/31/9999';

  INSERT UASM_Y1
         (Worker_ID,
          Office_IDNO,
          WorkPhone_NUMB,
          Effective_DATE,
          Expire_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          WorkerUpdate_ID)
  VALUES ( @Ac_Worker_ID,
           @An_Office_IDNO,
           @An_WorkPhone_NUMB,
           @Ad_Effective_DATE,
           @Ad_Expire_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID);
 END


GO
