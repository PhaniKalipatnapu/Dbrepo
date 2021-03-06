/****** Object:  StoredProcedure [dbo].[AKAX_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_UPDATE_S1] (
 @An_MemberMci_IDNO					NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB		NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB	NUMERIC(19, 0),
 @Ac_TypeAlias_CODE					CHAR(1),
 @Ac_LastAlias_NAME					CHAR(20),
 @Ac_FirstAlias_NAME				CHAR(16),
 @Ac_MiddleAlias_NAME				CHAR(20),
 @Ac_TitleAlias_NAME				CHAR(8),
 @Ac_SuffixAlias_NAME				CHAR(4),
 @Ac_Source_CODE					CHAR(2),
 @Ac_SignedOnWorker_ID				CHAR(30),
 @An_Sequence_NUMB					NUMERIC(11, 0)
 )
AS
 /*                                                          
 *     PROCEDURE NAME    : AKAX_UPDATE_S1                    
 *     DESCRIPTION       : Logically upadate the record in Member Alias Names table for Unique Number Assigned by the System to the Member and sequence number.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DTTM      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE AKAX_Y1
     SET TypeAlias_CODE = @Ac_TypeAlias_CODE,
         LastAlias_NAME = @Ac_LastAlias_NAME,
         FirstAlias_NAME = @Ac_FirstAlias_NAME,
         MiddleAlias_NAME = @Ac_MiddleAlias_NAME,
         TitleAlias_NAME = @Ac_TitleAlias_NAME,
         SuffixAlias_NAME = @Ac_SuffixAlias_NAME,
         Source_CODE = @Ac_Source_CODE,
         BeginValidity_DATE = @Ld_Current_DTTM,
         Update_DTTM = @Ld_Current_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
  OUTPUT DELETED.MemberMci_IDNO,
         DELETED.TypeAlias_CODE,
         DELETED.LastAlias_NAME,
         DELETED.FirstAlias_NAME,
         DELETED.MiddleAlias_NAME,
         DELETED.TitleAlias_NAME,
         DELETED.MaidenAlias_NAME,
         DELETED.SuffixAlias_NAME,
         DELETED.Source_CODE,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DTTM AS EndValidity_DATE,
         DELETED.Update_DTTM,
         DELETED.WorkerUpdate_ID,
         DELETED.TransactionEventSeq_NUMB,
         DELETED.Sequence_NUMB
  INTO AKAX_Y1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND Sequence_NUMB = @An_Sequence_NUMB
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of AKAX_UPDATE_S1

GO
