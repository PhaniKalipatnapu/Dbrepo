/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S32]  
     (
     @An_OtherParty_IDNO		NUMERIC(9,0),
     @Ai_Count_QNTY             INT			OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : OFIC_RETRIEVE_S32
 *     DESCRIPTION       : This procedure is used to return the count for the otherparty id FROM OFIC_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE      DATE	= '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM OFIC_Y1 a
       WHERE a.OtherParty_IDNO  = @An_OtherParty_IDNO 
         AND a.EndValidity_DATE = @Ld_High_DATE;

END;--End of OFIC_RETRIEVE_S32 


GO
