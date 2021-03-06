/****** Object:  StoredProcedure [dbo].[CSEP_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSEP_INSERT_S1] (
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @Ac_Function_CODE            CHAR(3),
 @Ac_CertMode_INDC            CHAR(1),
 @Ad_EndValidity_DATE         DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *	PROCEDURE NAME    : CSEP_INSERT_S1
  *  DESCRIPTION       : Inserting State details and CSENet Function details.
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 03-AUG-2011
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT CSEP_Y1
         (IVDOutOfStateFips_CODE,
          Function_CODE,
          CertMode_INDC,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  VALUES ( @Ac_IVDOutOfStateFips_CODE,
           @Ac_Function_CODE,
           @Ac_CertMode_INDC,
           @Ld_Current_DATE,
           @Ad_EndValidity_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM );
 END; -- END OF CSEP_INSERT_S1 


GO
