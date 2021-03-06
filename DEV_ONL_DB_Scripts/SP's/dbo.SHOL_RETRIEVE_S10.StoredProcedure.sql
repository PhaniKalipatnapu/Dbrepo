/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S10] (
 @Ad_Schedule_DATE	DATE,
 @Ai_Count_QNTY 	INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SHOL_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve the Row Count of Holiday date where Holiday Date is between the Appointment Scheduled Date and Current Date where Day of the Holiday is not equal to Sunday.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE
  		  @Ld_Current_DATE 		DATE     = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
  		  @Li_One_NUMB			SMALLINT = 1,
  		  @Li_MinusOne_NUMB     SMALLINT = -1 ;

  SELECT @Ai_Count_QNTY = COUNT(S.Holiday_DATE)
    FROM SHOL_Y1 S
   WHERE S.Holiday_DATE BETWEEN @Ld_Current_DATE AND @Ad_Schedule_DATE
     AND S.OthpLocation_IDNO = @Li_MinusOne_NUMB
     AND DATEPART(DW,S.Holiday_DATE) != @Li_One_NUMB ;
 END; --END OF SHOL_RETRIEVE_S10


GO
