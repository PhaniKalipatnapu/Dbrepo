/****** Object:  StoredProcedure [dbo].[SHOL_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_DELETE_S1] (
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : SHOL_DELETE_S1
  *     DESCRIPTION       : Deletes the record for the given unique event sequence number
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  DELETE SHOL_Y1
   WHERE TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF SHOL_DELETE_S1


GO
