/****** Object:  StoredProcedure [dbo].[CPNO_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPNO_RETRIEVE_S1]( 
 @Ac_CheckRecipient_CODE	CHAR(1),
 @Ac_CheckRecipient_ID		CHAR(10),
 @Ai_Count_QNTY		 		INT	 OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CPNO_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the Row count for the given Recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
  BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE	DATE = '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM CPNO_Y1 a
       WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID 
         AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE  
         AND a.StatusUpdate_DATE = @Ld_High_DATE;
                  
END; --END OF CPNO_RETRIEVE_S1


GO
