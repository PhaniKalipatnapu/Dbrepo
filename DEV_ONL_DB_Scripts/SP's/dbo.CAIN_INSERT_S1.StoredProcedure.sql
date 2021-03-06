/****** Object:  StoredProcedure [dbo].[CAIN_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_INSERT_S1](
 @An_TransHeader_IDNO         NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @Ad_Transaction_DATE         DATE,
 @Ac_Notice_ID                CHAR(8),
 @Ac_Received_INDC            CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_Barcode_NUMB             NUMERIC(12, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : CAIN_INSERT_S1  
  *     DESCRIPTION       : Insert details into Csenet Attachment Info table.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 21-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT CAIN_Y1
         (TransHeader_IDNO,
          IVDOutOfStateFips_CODE,
          Transaction_DATE,
          Notice_ID,
          Received_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          Barcode_NUMB)
  VALUES (@An_TransHeader_IDNO,
          @Ac_IVDOutOfStateFips_CODE,
          @Ad_Transaction_DATE,
          @Ac_Notice_ID,
          @Ac_Received_INDC,
          @Ld_Systemdatetime_DTTM,
          @Ld_High_DATE,
          @Ac_SignedOnWorker_ID,
          @An_TransactionEventSeq_NUMB,
          @Ld_Systemdatetime_DTTM,
          @An_Barcode_NUMB);
 END; -- End of CAIN_INSERT_S1   


GO
