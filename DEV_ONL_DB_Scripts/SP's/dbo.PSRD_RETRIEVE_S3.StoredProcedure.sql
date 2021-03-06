/****** Object:  StoredProcedure [dbo].[PSRD_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PSRD_RETRIEVE_S3]  (
	@An_Case_IDNO		NUMERIC(6,0),
	@Ac_Process_CODE	CHAR(1),
	@Ai_Count_QNTY      INT         OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : PSRD_RETRIEVE_S3
 *     DESCRIPTION       : Fetches the Support Order details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN 
     SET @Ai_Count_QNTY = NULL;
  
  SELECT @Ai_Count_QNTY = COUNT(1)
	FROM PSRD_Y1  p
   WHERE p.Process_CODE IN (@Ac_Process_CODE) 
	 AND P.Case_IDNO = @An_Case_IDNO;
          
END; --END OF PSRD_RETRIEVE_S3 


GO
