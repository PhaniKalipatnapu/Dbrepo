/****** Object:  StoredProcedure [dbo].[NVER_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_UPDATE_S3] (
 @Ac_Notice_ID                   CHAR(8),
 @As_XslTemplate_TEXT            VARCHAR(MAX),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID           CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_UPDATE_S3
  *     DESCRIPTION       : Update the Transaction sequence and  XSL Boilerplate Form for a respective Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10),
          @Li_Zero_NUMB         SMALLINT = 0;

  UPDATE NVER_Y1
     SET NoticeVersion_NUMB = (SELECT MAX(N.NoticeVersion_NUMB) + 1
                                 FROM NVER_Y1 N
                                WHERE N.Notice_ID = @Ac_Notice_ID),
         XslTemplate_TEXT = @As_XslTemplate_TEXT,
         Effective_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         End_DATE = @Ld_High_DATE,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
   WHERE Notice_ID = @Ac_Notice_ID
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB
     AND NoticeVersion_NUMB = @Li_Zero_NUMB
     AND CONVERT (DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN Effective_DATE AND End_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of NVER_UPDATE_S3 

GO
