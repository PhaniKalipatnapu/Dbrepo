/****** Object:  StoredProcedure [dbo].[ACEN_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_INSERT_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ad_BeginEnforcement_DATE    DATE,
 @Ac_StatusEnforce_CODE       CHAR(1),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @Ad_BeginExempt_DATE         DATE,
 @Ad_EndExempt_DATE           DATE,
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : ACEN_INSERT_S1
  *     DESCRIPTION       : Insert Active Enforcement details with the provided values.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_SystemDateTime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT ACEN_Y1
         (Case_IDNO,
          OrderSeq_NUMB,
          TransactionEventSeq_NUMB,
          BeginEnforcement_DATE,
          StatusEnforce_CODE,
          ReasonStatus_CODE,
          BeginExempt_DATE,
          EndExempt_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM)
  VALUES ( @An_Case_IDNO,--Case_IDNO
           @An_OrderSeq_NUMB,--OrderSeq_NUMB
           @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
           @Ad_BeginEnforcement_DATE,--BeginEnforcement_DATE
           @Ac_StatusEnforce_CODE,--StatusEnforce_CODE
           @Ac_ReasonStatus_CODE,--ReasonStatus_CODE
           @Ad_BeginExempt_DATE,--BeginExempt_DATE
           @Ad_EndExempt_DATE,--EndExempt_DATE
           @Ld_SystemDateTime_DTTM,--BeginValidity_DATE
           @Ld_High_DATE,--EndValidity_DATE
           @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
           @Ld_SystemDateTime_DTTM --Update_DTTM
  );
 END; --End of ACEN_INSERT_S1


GO
