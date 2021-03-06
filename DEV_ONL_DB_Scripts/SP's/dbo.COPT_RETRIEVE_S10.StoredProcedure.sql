/****** Object:  StoredProcedure [dbo].[COPT_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COPT_RETRIEVE_S10] (
	@An_County_IDNO		NUMERIC(3,0),
	@Ac_County_NAME		CHAR(40)	 OUTPUT
)
     
AS

/*
 *     PROCEDURE NAME    : COPT_RETRIEVE_S10
 *     DESCRIPTION       : Retrieves the county name.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 27-FEB-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

       SET @Ac_County_NAME = NULL;

	SELECT TOP 1 @Ac_County_NAME = C.County_NAME
	  FROM COPT_Y1 C
	 WHERE C.County_IDNO = @An_County_IDNO;
                  
END; -- End Of COPT_RETRIEVE_S10


GO
