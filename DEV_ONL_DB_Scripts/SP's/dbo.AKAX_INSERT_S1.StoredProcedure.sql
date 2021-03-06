/****** Object:  StoredProcedure [dbo].[AKAX_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_INSERT_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeAlias_CODE           CHAR(1),
 @Ac_LastAlias_NAME           CHAR(20),
 @Ac_FirstAlias_NAME          CHAR(16),
 @Ac_MiddleAlias_NAME         CHAR(20),
 @Ac_TitleAlias_NAME          CHAR(8),
 @Ac_MaidenAlias_NAME         CHAR(20),
 @Ac_SuffixAlias_NAME         CHAR(4),
 @Ac_Source_CODE              CHAR(2),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_Sequence_NUMB            NUMERIC(11, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : AKAX_INSERT_S1
  *     DESCRIPTION       : Insert Member Alias Names details with new Sequence Event Transaction and retrieved sequence number into Member Alias Names table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2=DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE='12/31/9999';

  INSERT AKAX_Y1
         (MemberMci_IDNO,
          TypeAlias_CODE,
          LastAlias_NAME,
          FirstAlias_NAME,
          MiddleAlias_NAME,
          TitleAlias_NAME,
          MaidenAlias_NAME,
          SuffixAlias_NAME,
          Source_CODE,
          BeginValidity_DATE,
          EndValidity_DATE,
          Update_DTTM,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Sequence_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @Ac_TypeAlias_CODE,
           @Ac_LastAlias_NAME,
           @Ac_FirstAlias_NAME,
           @Ac_MiddleAlias_NAME,
           @Ac_TitleAlias_NAME,
           @Ac_MaidenAlias_NAME,
           @Ac_SuffixAlias_NAME,
           @Ac_Source_CODE,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @An_Sequence_NUMB );
 END; --End of AKAX_INSERT_S1


GO
