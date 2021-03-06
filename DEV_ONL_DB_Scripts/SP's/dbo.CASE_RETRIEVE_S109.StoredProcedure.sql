/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S109]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S109]  
(
     @An_Case_IDNO			 NUMERIC(6,0),
     @Ac_TypeCase_CODE		 CHAR(1)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S109
 *     DESCRIPTION       : This procedure returns case type FROM CASE_Y1 for case ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

		SET @Ac_TypeCase_CODE = NULL;

		DECLARE
		   @Lc_StatusCaseOpen_CODE      CHAR(1) = 'O';
        
        SELECT @Ac_TypeCase_CODE = C.TypeCase_CODE
		  FROM CASE_Y1 C
         WHERE C.Case_IDNO		 = @An_Case_IDNO 
           AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
                  
END; --END OF CASE_RETRIEVE_S109


GO
