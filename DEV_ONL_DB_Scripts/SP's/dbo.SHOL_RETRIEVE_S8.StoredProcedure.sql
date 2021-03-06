/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S8] ( 

     @Ad_Holiday_DATE		DATE,
     @Ai_Count_QNTY		 	INT	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : SHOL_RETRIEVE_S8
 *     DESCRIPTION       : Checks whether the given date is the holiday date.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL;

      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM SHOL_Y1 S
      WHERE S.Holiday_DATE = @Ad_Holiday_DATE;

                  
  END; -- End Of SHOL_RETRIEVE_S8


GO
