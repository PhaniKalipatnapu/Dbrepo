/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S9]
	(
	 @An_Case_IDNO	NUMERIC(6,0),
     @Ai_Count_QNTY INT			OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S9
 *     DESCRIPTION       : This procedure returns the count of support order for given Case.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
			@Ld_High_DATE DATE = '12/31/9999',
			@Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();        
      
      SELECT @Ai_Count_QNTY = COUNT(1)
		FROM SORD_Y1  a
      WHERE a.Case_IDNO = @An_Case_IDNO 
      AND   a.OrderEnd_DATE > @Ld_Current_DATE 
      AND   a.EndValidity_DATE = @Ld_High_DATE;
                  
END; --end of SORD_RETRIEVE_S9


GO
