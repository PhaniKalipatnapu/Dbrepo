/****** Object:  StoredProcedure [dbo].[DCRS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[DCRS_RETRIEVE_S2]  
    	(
     		@Ac_CheckRecipient_ID	CHAR(10),
     		@Ai_Count_QNTY       	INT		OUTPUT
        )
AS

/*
*     PROCEDURE NAME    : DCRS_RETRIEVE_S2
 *     DESCRIPTION       : Retrieves row count for the given check recipient ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE              DATE = '12/31/9999',
         @Lc_ActiveSent_CODE  CHAR(1)='A';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
      FROM DCRS_Y1 d
      WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND d.Status_CODE = @Lc_ActiveSent_CODE 
      AND d.EndValidity_DATE = @Ld_High_DATE;

                  
END; -- End of DCRS_RETRIEVE_S2


GO
