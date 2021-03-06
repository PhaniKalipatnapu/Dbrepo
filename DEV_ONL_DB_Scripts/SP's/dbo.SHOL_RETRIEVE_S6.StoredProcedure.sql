/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S6] (
 @Ad_Holiday_DATE DATE
 )
AS
 /*  
  *     PROCEDURE NAME    : SHOL_RETRIEVE_S6  
  *     DESCRIPTION       : Returns Transaction Sequence no for the given holiday date.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 01-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
 
  DECLARE @Li_One_NUMB SMALLINT = -1;

  SELECT TransactionEventSeq_NUMB
  		FROM SHOL_Y1 S
  		WHERE S.Holiday_DATE = @Ad_Holiday_DATE
   		AND   S.OthpLocation_IDNO  <> @Li_One_NUMB;
  
 END; -- END OF  SHOL_RETRIEVE_S6


GO
