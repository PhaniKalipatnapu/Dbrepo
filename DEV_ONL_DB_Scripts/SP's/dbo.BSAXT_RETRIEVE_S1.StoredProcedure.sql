/****** Object:  StoredProcedure [dbo].[BSAXT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_RETRIEVE_S1] 
(
	@Ad_ReviewFrom_DATE			DATE,
	@Ad_ReviewTo_DATE			DATE,
	@Ac_TypeComponent_CODE		CHAR(4),
	@Ai_Count_QNTY   			INT  	OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSAXT_RETRIEVE_S1
 *     DESCRIPTION       : Checks whether the record exist or not in case closure.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

	   SET @Ai_Count_QNTY = NULL;

	SELECT @Ai_Count_QNTY = COUNT(1) 
	  FROM BSAXT_Y1 a
	 WHERE a.ReviewFrom_date	= @Ad_ReviewFrom_DATE
	   AND a.ReviewTo_DATE		= @Ad_ReviewTo_DATE
	   AND a.TypeComponent_code = @Ac_TypeComponent_CODE;
       
END  --END OF BSAXT_RETRIEVE_S1


GO
