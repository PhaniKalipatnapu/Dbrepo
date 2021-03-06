/****** Object:  StoredProcedure [dbo].[DCRS_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[DCRS_RETRIEVE_S12]  
    	(
     		@Ac_CheckRecipient_ID	CHAR(10),
     		@An_DebitCard_NUMB      NUMERIC(16,0)		OUTPUT
        )
AS
/*
*     PROCEDURE NAME    : DCRS_RETRIEVE_S12
 *     DESCRIPTION       : Retrieves row count for the given check recipient ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/   BEGIN

      DECLARE
         @Ld_High_DATE              DATE = '12/31/9999';
        SELECT @An_DebitCard_NUMB = d.DebitCard_NUMB
      FROM DCRS_Y1 d
      WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
        AND d.EndValidity_DATE = @Ld_High_DATE;                  
END; -- End of DCRS_RETRIEVE_S12


GO
