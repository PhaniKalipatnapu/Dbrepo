/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S2] (
 @Ac_HolidayDate_TEXT  CHAR(4),
 @An_OthpLocation_IDNO NUMERIC(9, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : SHOL_RETRIEVE_S2
  *     DESCRIPTION       : Retrieves the holidays list for Common holidays and location specific holidays depending upon the input
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

  SELECT S.Holiday_DATE,
         S.DescriptionHoliday_TEXT,
         S.TransactionEventSeq_NUMB
    FROM SHOL_Y1 S
   WHERE DATEPART(YEAR, S.HOLIDAY_DATE) = @Ac_HolidayDate_TEXT
     AND S.OthpLocation_IDNO = @An_OthpLocation_IDNO
   ORDER BY S.Holiday_DATE;
 END; -- END OF SHOL_RETRIEVE_S2


GO
