/****** Object:  StoredProcedure [dbo].[NREP_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_RETRIEVE_S4] (
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NREP_RETRIEVE_S4
  *     DESCRIPTION       : Checks whether the record exists for a respective notice and recipient.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM NREP_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND N.Recipient_CODE = @Ac_Recipient_CODE
     AND N.EndValidity_DATE = @Ld_High_DATE;
 END; -- END Of NREP_RETRIEVE_S4

GO
