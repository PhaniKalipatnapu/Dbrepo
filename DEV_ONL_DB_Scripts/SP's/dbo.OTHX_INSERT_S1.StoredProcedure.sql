/****** Object:  StoredProcedure [dbo].[OTHX_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHX_INSERT_S1] (
 @An_OtherParty_IDNO          NUMERIC(9, 0),
 @Ac_TypeAddr_CODE            CHAR(2),
 @An_AddrOthp_IDNO            NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ad_EndValidity_DATE         DATE,
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : OTHX_INSERT_S1
  *     DESCRIPTION       : INSERT details INTO Other Party ADDRESS X Reference TABLE.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT OTHX_Y1
         (OtherParty_IDNO,
          TypeAddr_CODE,
          AddrOthp_IDNO,
          TransactionEventSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM)
  VALUES ( @An_OtherParty_IDNO,
           @Ac_TypeAddr_CODE,
           @An_AddrOthp_IDNO,
           @An_TransactionEventSeq_NUMB,
           @Ld_Current_DATE,
           @Ad_EndValidity_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM );
 END; -- END OF OTHX_INSERT_S1



GO
