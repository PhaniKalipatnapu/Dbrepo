/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S37] (
 @Ac_Worker_ID                CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S37
  *     DESCRIPTION       : Retrieve the record count for a Worker ID and Unique Sequence Number where end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/20/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM USEM_Y1 U
   WHERE U.Worker_ID = @Ac_Worker_ID
     AND U.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
