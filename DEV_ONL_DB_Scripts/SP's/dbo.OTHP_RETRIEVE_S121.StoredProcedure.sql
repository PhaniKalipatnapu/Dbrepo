/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S121]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S121] (
 @An_Fein_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY   INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S121
  *     DESCRIPTION       : Retrieve the row count for Fein_IDNO Existence of Employer.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 13-JAN-2014
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;
  
  DECLARE @Lc_TypeOthpE_CODE CHAR(1) ='E',
  @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM OTHP_Y1 O
   WHERE O.Fein_IDNO = @An_Fein_IDNO
	 AND O.TypeOthp_CODE = @Lc_TypeOthpE_CODE
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF OTHP_RETRIEVE_S121 


GO
