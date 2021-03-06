/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S25] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_TypeActivity_CODE CHAR(1),
 @Ad_Schedule_DATE     DATE
 
 )
AS
 /*                                                                                                                                                                                                                                                             
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S25                                                                                                                                                                                                                    
  *     DESCRIPTION       : Retrieve Holiday Date for a column value or Schedule Date for a Location Idno, Activity Type, and column value or Day Code for a Location Idno, Activity Type, and column value where column value is retrieved from Gtemp_Spro_T1 table.                                                                                                                                                                                                                                                          
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                          
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                                                                         
  *     MODIFIED BY       :                                                                                                                                                                                                                                     
  *     MODIFIED ON       :                                                                                                                                                                                                                                     
  *     VERSION NO        : 1                                                                                                                                                                                                                                   
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Lc_IndAvailable_CODE   CHAR(1) = 'A',
          @Lc_IndHoliday_CODE     CHAR(1) = 'H',
          @Lc_IndUnavailable_CODE CHAR(1) = 'U',
          @Lc_Day_TEXT            CHAR(4)  = '/01/',
          @Li_MinusOne_NUMB       SMALLINT = -1,
          @Lc_Screen_INDC         CHAR(1)  = 'M', 
          @Li_One_NUMB            SMALLINT = 1;
          
  DECLARE @Ld_Start_DATE DATE = CONVERT(VARCHAR, MONTH(@Ad_Schedule_DATE)) + @Lc_Day_TEXT + CONVERT(VARCHAR, YEAR(@Ad_Schedule_DATE));
  DECLARE @Ld_End_DATE   DATE = DATEADD(d, @Li_MinusOne_NUMB, DATEADD(m, @Li_One_NUMB, @Ld_Start_DATE));

  SELECT X.Available_DATE AS Schedule_DATE,
         CASE
         WHEN X.Available_DATE = (SELECT S.Holiday_DATE
                                   FROM SHOL_Y1 S
                                  WHERE S.Holiday_DATE = X.Available_DATE
                                    AND S.OthpLocation_IDNO = @Li_MinusOne_NUMB )
		   THEN @Lc_IndHoliday_CODE                                    
          WHEN X.Available_DATE = (SELECT S.Holiday_DATE
                                   FROM SHOL_Y1 S
                                  WHERE S.Holiday_DATE = X.Available_DATE
                                    AND S.OthpLocation_IDNO = @An_OthpLocation_IDNO )
           THEN @Lc_IndHoliday_CODE
          WHEN X.Available_DATE = (SELECT TOP 1 SW.Schedule_DATE
                                   FROM SWKS_Y1 SW
                                  WHERE SW.OthpLocation_IDNO = @An_OthpLocation_IDNO
                                    AND SW.TypeActivity_CODE = @Ac_TypeActivity_CODE
                                    AND SW.Schedule_DATE = X.Available_DATE)
           THEN @Lc_IndAvailable_CODE
          WHEN DATEPART(DW,X.Available_DATE) = (SELECT SL.Day_CODE
                                               FROM SLSD_Y1 SL
                                               WHERE SL.OthpLocation_IDNO = @An_OthpLocation_IDNO
                                                 AND SL.TypeActivity_CODE = @Ac_TypeActivity_CODE
                                                 AND SL.Day_CODE = DATEPART(DW,X.Available_DATE)
                                                 AND SL.EndValidity_DATE = @Ld_High_DATE)
           THEN @Lc_IndAvailable_CODE
          ELSE @Lc_IndUnavailable_CODE
         END AS Availability_INDC
    FROM (SELECT Available_DATE
           FROM dbo.BATCH_COMMON$SF_GET_AVAILABLE_SCHEDULE_DATE(@An_OthpLocation_IDNO,@Ld_Start_DATE,@Ld_End_DATE,@Lc_Screen_INDC )) AS X
   ORDER BY Schedule_DATE;
 END; --END OF SWKS_RETRIEVE_S25                                                                                                                                                                                                                                                           



GO
