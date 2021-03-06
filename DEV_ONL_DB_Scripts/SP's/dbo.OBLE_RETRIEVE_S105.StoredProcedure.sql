/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S105]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S105]  (
     @An_Case_IDNO				NUMERIC(6,0),
     @Ad_BeginObligation_DATE	DATE	 OUTPUT,
     @Ad_EndObligation_DATE		DATE	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S105
 *     DESCRIPTION       : Retrives the obligation begin and end date.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/29/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

   BEGIN
      SET @Ad_BeginObligation_DATE = NULL;
      SET @Ad_EndObligation_DATE = NULL;
      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
        
        SELECT @Ad_EndObligation_DATE = MAX(O.EndObligation_DATE), 
			   @Ad_BeginObligation_DATE = MIN(O.BeginObligation_DATE)
		  FROM OBLE_Y1 O
		 WHERE O.Case_IDNO = @An_Case_IDNO 
		   AND O.EndValidity_DATE = @Ld_High_DATE;
END


GO
