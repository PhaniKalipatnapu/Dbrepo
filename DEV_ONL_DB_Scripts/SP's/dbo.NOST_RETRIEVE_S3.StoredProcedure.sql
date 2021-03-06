/****** Object:  StoredProcedure [dbo].[NOST_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOST_RETRIEVE_S3]
 @Ac_Worker_ID  CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19,0),
 @Ai_Count_QNTY INT OUTPUT
AS
 /*  
  *     PROCEDURE NAME    : NOST_RETRIEVE_S3  
  *     DESCRIPTION       : Retrieve record count for a Unique Worker ID and the transaction sequence number.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/21/2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM NOST_Y1 N
   WHERE N.Worker_ID = @Ac_Worker_ID
	 AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
   
 END


GO
