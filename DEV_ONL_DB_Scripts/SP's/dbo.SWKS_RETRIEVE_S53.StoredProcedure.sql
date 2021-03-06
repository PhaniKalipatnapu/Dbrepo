/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S53]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S53] (
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ai_Count_QNTY               INT OUTPUT
 )
AS
 /*                                                                                                                                                                                                                                                             
  * PROCEDURE NAME    : SWKS_RETRIEVE_S53                                                                                                                                                                                                                       
  * DESCRIPTION       : Returns no of count if  any record exists for the given schedule number and transaction event.
  * DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                
  * DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                                                                             
  * MODIFIED BY       :                                                                                                                                                                                                                                         
  * MODIFIED ON       :                                                                                                                                                                                                                                         
  * VERSION NO        : 1                                                                                                                                                                                                                                       
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SWKS_Y1 S
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB
     AND S.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; -- END OF SWKS_RETRIEVE_S53                                                                                                                                                                                                                               


GO
