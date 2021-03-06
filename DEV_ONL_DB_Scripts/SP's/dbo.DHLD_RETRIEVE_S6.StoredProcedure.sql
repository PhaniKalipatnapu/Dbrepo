/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S6]  
(
     @An_Unique_IDNO		 		NUMERIC(19,0),  
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @Ai_Count_QNTY                 INT           OUTPUT
)     
AS                                                                     

/*
*     PROCEDURE NAME    : DHLD_RETRIEVE_S6
*     DESCRIPTION       : Retrieves Count for the given LogDisbursementHold Details.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/

BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
      FROM DHLD_Y1 D
      WHERE D.Unique_IDNO = @An_Unique_IDNO 
      AND D.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
      AND D.EndValidity_DATE = @Ld_High_DATE;

                  
END; --End of DHLD_RETRIEVE_S6

GO
