/****** Object:  StoredProcedure [dbo].[MSSN_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_INSERT_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_MemberSsn_NUMB           NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Enumeration_CODE         CHAR(1),
 @Ac_TypePrimary_CODE         CHAR(1),
 @Ac_SourceVerify_CODE        CHAR(3),
 @Ad_Status_DATE              DATE,
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : MSSN_INSERT_S1
  *     DESCRIPTION       : Insert Member SSN details into Member SSN table with new Sequence Event Transaction.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT MSSN_Y1
         (MemberMci_IDNO,
          MemberSsn_NUMB,
          Enumeration_CODE,
          TypePrimary_CODE,
          SourceVerify_CODE,
          Status_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  VALUES ( @An_MemberMci_IDNO,
           @An_MemberSsn_NUMB,
           @Ac_Enumeration_CODE,
           @Ac_TypePrimary_CODE,
           @Ac_SourceVerify_CODE,
           @Ad_Status_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM );
 END; -- END of  MSSN_INSERT_S1


GO
