/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S108]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S108]  
	(
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ac_Exists_INDC     CHAR(1)            OUTPUT
	)
AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S108
 *     DESCRIPTION       : This procedure is used to check the case id is valid and it's in open status 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

          SET @Ac_Exists_INDC  = 'N';

      DECLARE @Lc_StatusCaseOpen_CODE       CHAR(1) = 'O';
        
       SELECT @Ac_Exists_INDC  = 'Y'
		 FROM CASE_Y1 C
        WHERE C.Case_IDNO		 = @An_Case_IDNO 
          AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
                  
END; --END OF CASE_RETRIEVE_S108


GO
