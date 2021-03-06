/****** Object:  StoredProcedure [dbo].[NVER_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_RETRIEVE_S1] (
 @Ac_Notice_ID                CHAR(8),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @As_XslTemplate_TEXT         VARCHAR(MAX) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve XSL Boilerplate Form for a respective Notice and Transaction sequence.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_XslTemplate_TEXT = NULL;

  SELECT @As_XslTemplate_TEXT = N.XslTemplate_TEXT
    FROM NVER_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; -- End Of NVER_RETRIEVE_S1

GO
