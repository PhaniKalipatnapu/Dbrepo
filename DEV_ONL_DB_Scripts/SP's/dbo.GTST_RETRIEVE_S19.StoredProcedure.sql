/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S19]  
(
     @An_Case_IDNO            NUMERIC(6)         ,
     @Ac_TypeTest_CODE        CHAR(1)      OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : GTST_RETRIEVE_S19
 *     DESCRIPTION       : This sp is used to get the type of test for the particular case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ac_TypeTest_CODE = NULL;

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
        
        SELECT TOP 1 @Ac_TypeTest_CODE = a.TypeTest_CODE
        FROM  GTST_Y1 a
        WHERE a.Case_IDNO        = @An_Case_IDNO 
        AND   a.EndValidity_DATE = @Ld_High_DATE;

                  
END     -- End of GTST_RETRIEVE_S19;


GO
