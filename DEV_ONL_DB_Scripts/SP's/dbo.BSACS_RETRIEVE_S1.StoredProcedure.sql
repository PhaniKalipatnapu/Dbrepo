/****** Object:  StoredProcedure [dbo].[BSACS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSACS_RETRIEVE_S1] (
	@An_Case_IDNO		NUMERIC(6,0),
	@Ad_Review_DATE		DATE,
	@Ai_Count_QNTY		INT OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSACS_RETRIEVE_S1
 *     DESCRIPTION       : Check whether the records are exists or not in case table for the given review date 
						   and case id.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 27-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	
	SELECT @Ai_Count_QNTY = COUNT(1)
      FROM BSACS_Y1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.Review_DATE = @Ad_Review_DATE;
       
END -- END OF BSACS_RETRIEVE_S1


GO
