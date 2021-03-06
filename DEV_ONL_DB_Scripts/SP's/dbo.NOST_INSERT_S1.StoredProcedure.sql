/****** Object:  StoredProcedure [dbo].[NOST_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOST_INSERT_S1](
 @Ac_Worker_ID         CHAR(30),
 @As_Line1_TEXT        VARCHAR(100),
 @As_Line2_TEXT        VARCHAR(100),
 @As_Line3_TEXT        VARCHAR(100),
 @Ad_Expiry_DATE       DATE,
 @As_Pin_TEXT          VARCHAR(64),
 @Ac_SignedOnWorker_ID CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*  
  *     PROCEDURE NAME    : NOST_INSERT_S1  
  *     DESCRIPTION       : Insert Notary details with the provided values.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/28/2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Update_DTTM DATETIME2 = DATEADD(D,-1,@Ld_Systemdatetime_DTTM);

  INSERT NOST_Y1
        ( Worker_ID,
          Line1_TEXT,
          Line2_TEXT,
          Line3_TEXT,
          Expiry_DATE,
          Pin_TEXT,
          BeginValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB )
  VALUES ( @Ac_Worker_ID,
           @As_Line1_TEXT,
           @As_Line2_TEXT,
           @As_Line3_TEXT,
           @Ad_Expiry_DATE,
           @As_Pin_TEXT,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ld_Update_DTTM,
           @An_TransactionEventSeq_NUMB );
 END


GO
