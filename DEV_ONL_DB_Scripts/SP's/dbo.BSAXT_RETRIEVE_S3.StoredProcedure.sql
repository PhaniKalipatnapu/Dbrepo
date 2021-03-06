/****** Object:  StoredProcedure [dbo].[BSAXT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_RETRIEVE_S3] 
(
	@Ac_TypeComponent_CODE			CHAR(4),	
	@Ai_Count_QNTY   				INT  	OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSAXT_RETRIEVE_S3
 *     DESCRIPTION       : Checks whether the record exist or not in extract table.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

	   SET @Ai_Count_QNTY = NULL;
   DECLARE @Ld_High_DATE				DATE    = '12/31/9999';

	SELECT @Ai_Count_QNTY = COUNT (1)
      FROM BSAXT_Y1  a
     WHERE a.TypeComponent_CODE = @Ac_TypeComponent_CODE
       AND a.EndValidity_DATE   = @Ld_High_DATE;
       
END  --END OF BSAXT_RETRIEVE_S3


GO
