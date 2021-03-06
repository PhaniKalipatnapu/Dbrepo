/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S79]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S79](
     @An_Case_IDNO				NUMERIC(6,0),
     @Ad_BeginObligation_DATE	DATE	 OUTPUT
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S79
 *     DESCRIPTION       : Retrieve minimum obligation start date of the case for prorating the Grant start
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
       SET @Ad_BeginObligation_DATE = NULL;

       DECLARE
          @Ld_High_DATE		 DATE = '12/31/9999',
          @Ld_Current_DATE   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT @Ad_BeginObligation_DATE = MIN(O.BeginObligation_DATE)
			FROM OBLE_Y1 O
		WHERE O.Case_IDNO = @An_Case_IDNO 
		AND   O.BeginObligation_DATE <= dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Current_DATE) 
		AND   O.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S79


GO
