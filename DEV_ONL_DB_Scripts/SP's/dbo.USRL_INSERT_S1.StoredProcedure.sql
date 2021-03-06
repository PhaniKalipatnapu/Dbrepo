/****** Object:  StoredProcedure [dbo].[USRL_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_INSERT_S1](
 @Ac_Worker_ID                CHAR(30),
 @An_Office_IDNO              NUMERIC(3),
 @Ac_Role_ID                  CHAR(10),
 @Ad_Effective_DATE           DATE,
 @Ad_Expire_DATE              DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_AlphaRangeFrom_CODE      CHAR(5),
 @Ac_AlphaRangeTo_CODE        CHAR(5),
 @Ac_WorkerSub_ID             CHAR(30),
 @Ac_Supervisor_ID            CHAR(30),
 @An_CasesAssigned_QNTY       NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_INSERT_S1
  *     DESCRIPTION       : Insert User Office Roles with the provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_SystemTime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_BeginValidity_DATE DATE = @Ld_SystemTime_DTTM;
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  INSERT USRL_Y1
         (Worker_ID,
          Office_IDNO,
          Role_ID,
          Effective_DATE,
          Expire_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          WorkerUpdate_ID,
          AlphaRangeFrom_CODE,
          AlphaRangeTo_CODE,
          WorkerSub_ID,
          Supervisor_ID,
          CasesAssigned_QNTY)
  VALUES ( @Ac_Worker_ID,
           @An_Office_IDNO,
           @Ac_Role_ID,
           @Ad_Effective_DATE,
           @Ad_Expire_DATE,
           @Ld_BeginValidity_DATE,
           @Ld_High_DATE,
           @An_TransactionEventSeq_NUMB,
           @Ld_SystemTime_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ac_AlphaRangeFrom_CODE,
           @Ac_AlphaRangeTo_CODE,
           @Ac_WorkerSub_ID,
           @Ac_Supervisor_ID,
           @An_CasesAssigned_QNTY);
 END


GO
