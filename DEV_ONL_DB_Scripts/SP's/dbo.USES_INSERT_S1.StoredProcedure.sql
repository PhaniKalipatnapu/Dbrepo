/****** Object:  StoredProcedure [dbo].[USES_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USES_INSERT_S1](
 @Ac_Worker_ID                CHAR(30),
 @As_ESignature_BIN			  VARCHAR(4000),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*  
  *     PROCEDURE NAME    : USES_INSERT_S1  
  *     DESCRIPTION       : Insert Electronic Signature details with the provided values.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/07/2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT USES_Y1
         (Worker_ID,
          ESignature_BIN,
          BeginValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @Ac_Worker_ID,
           CONVERT(VARBINARY(4000),@As_ESignature_BIN),
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @An_TransactionEventSeq_NUMB);
 END


GO
