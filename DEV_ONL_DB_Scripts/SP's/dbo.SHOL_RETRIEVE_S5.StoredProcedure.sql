/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S5] (
 @Ad_Holiday_DATE             DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : SHOL_RETRIEVE_S5  
  *     DESCRIPTION       : Returns 1 if the event sequence number is not updated by others for the specific date.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 01-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
 
  SET @Ai_Count_QNTY = NULL;

  
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SHOL_Y1 S
   WHERE S.Holiday_DATE = @Ad_Holiday_DATE
     AND S.TransactionEventSeq_NUMB <> @An_TransactionEventSeq_NUMB;
 END; -- END OF SHOL_RETRIEVE_S5  


GO
