/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S33]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S33] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : ICAS_RETRIEVE_S33
  *     DESCRIPTION       : To Check whether other state Case id is available for a Given Case and state fips code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE 
		@Lc_StatusOpen_CODE	CHAR(1) = 'O' ,
		@Ld_High_DATE		DATE	= '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ICAS_Y1 I
   WHERE I.Case_IDNO = @An_Case_IDNO
     AND I.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
	 AND I.Status_CODE		= @Lc_StatusOpen_CODE
     AND RTRIM(LTRIM(I.IVDOutOfStateCase_ID)) <> ''
     AND EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S33

GO
