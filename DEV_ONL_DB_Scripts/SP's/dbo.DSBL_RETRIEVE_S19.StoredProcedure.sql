/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S19] (
 @Ac_CheckRecipient_ID CHAR(10),
 @Ai_Count_QNTY        SMALLINT OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S19    
  *     DESCRIPTION       : Check Record Exist in DSBL
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-FEB-2011
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SET @Ai_Count_QNTY= NULL;

  SELECT TOP 1 @Ai_Count_QNTY = 1
    FROM DSBL_Y1 DS
   WHERE DS.CheckRecipient_ID = @Ac_CheckRecipient_ID;
 END


GO
