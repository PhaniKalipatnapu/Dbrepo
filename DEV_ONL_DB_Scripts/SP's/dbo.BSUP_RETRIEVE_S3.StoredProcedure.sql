/****** Object:  StoredProcedure [dbo].[BSUP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSUP_RETRIEVE_S3] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY	INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : BSUP_RETRIEVE_S3
  *     DESCRIPTION       : Check weather the given case is in billing suppression .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE	@Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
  			@Ld_High_DATE 		DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM BSUP_Y1 b
   WHERE b.Case_IDNO = @An_Case_IDNO
     AND b.End_DATE < @Ld_Current_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF BSUP_RETRIEVE_S3


GO
