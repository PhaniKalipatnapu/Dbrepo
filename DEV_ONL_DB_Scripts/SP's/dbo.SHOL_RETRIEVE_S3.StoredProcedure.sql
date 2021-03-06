/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S3]  
(
	@An_TransactionEventSeq_NUMB		 NUMERIC(19,0),
    @Ai_Count_QNTY                       INT	OUTPUT
)

AS

/*
 *     PROCEDURE NAME    : SHOL_RETRIEVE_S3
 *     DESCRIPTION       : Returns count if record exists for the given unique event sequence number.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

      SET @Ai_Count_QNTY = NULL;

      SELECT @Ai_Count_QNTY = COUNT(1)
      	FROM SHOL_Y1 S
      	WHERE S.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
                  
END; -- END OF SHOL_RETRIEVE_S3




GO
