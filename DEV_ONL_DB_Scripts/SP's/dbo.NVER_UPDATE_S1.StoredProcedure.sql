/****** Object:  StoredProcedure [dbo].[NVER_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_UPDATE_S1] (
 @Ac_Notice_ID                CHAR(8),
 @As_XslTemplate_TEXT         VARCHAR(MAX),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_UPDATE_S1
  *     DESCRIPTION       : Update the Transaction sequence and  XSL Boilerplate Form for a respective Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Li_Zero_NUMB         SMALLINT = 0,
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE NVER_Y1
     SET XslTemplate_TEXT = @As_XslTemplate_TEXT,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
   WHERE Notice_ID = @Ac_Notice_ID
     AND NoticeVersion_NUMB = @Li_Zero_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of NVER_UPDATE_S1

GO
