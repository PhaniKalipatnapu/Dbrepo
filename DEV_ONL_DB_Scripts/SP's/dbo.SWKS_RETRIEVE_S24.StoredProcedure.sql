/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S24] (  
 @Ac_Worker_ID    CHAR(30),  
 @Ad_Schedule_DATE  DATE  
   
 )  
AS  
 /*        
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S24        
  *     DESCRIPTION       : Retrieve Holiday Date for a column value or Schedule Date for a Worker Idno and column value or Day Code for a Worker Idno and column value where column value is retrieved from Gtemp_Spro_T1 table.        
  *     DEVELOPED BY      : IMP Team        
  *     DEVELOPED ON      : 02-MAR-2011        
  *     MODIFIED BY       :         
  *     MODIFIED ON       :         
  *     VERSION NO        : 1        
 */  
 BEGIN  
  DECLARE @Lc_IndAvailable_CODE       CHAR(1) = 'A',  
          @Lc_IndHoliday_CODE         CHAR(1) = 'H',  
          @Lc_ActivityMinorAdmin_CODE CHAR(5) = 'ADMIN',  
          @Lc_ActivityMinorPrsnl_CODE CHAR(5) = 'PRSNL',  
          @Lc_ActivityMinorVactn_CODE CHAR(5) = 'VACTN',  
          @Lc_IndUnavailable_CODE     CHAR(1) = 'U',  
          @Li_One_NUMB                SMALLINT = 1,  
          @Li_MinusOne_NUMB           SMALLINT = -1,  
          @Li_MinusTwo_NUMB           SMALLINT = -2,  
          @Lc_Screen_INDC             CHAR(1)  = 'M',   
          @Lc_Day_TEXT                CHAR(4)  = '/01/',
          @Lc_ApptStatusSc_CODE       CHAR(2) = 'SC';    
            
  DECLARE @Ld_Start_DATE DATE = CONVERT(VARCHAR, MONTH(@Ad_Schedule_DATE)) + @Lc_Day_TEXT + CONVERT(VARCHAR, YEAR(@Ad_Schedule_DATE));  
  DECLARE @Ld_End_DATE   DATE = DATEADD(d, @Li_MinusOne_NUMB, DATEADD(m, @Li_One_NUMB, @Ld_Start_DATE));  
  
  SELECT X.Available_DATE AS Schedule_DATE,  
         CASE  
          WHEN X.Available_DATE = (SELECT SH.Holiday_DATE  
                                   FROM SHOL_Y1 SH  
                                  WHERE SH.Holiday_DATE = X.Available_DATE  
                                    AND SH.OthpLocation_IDNO = @Li_MinusOne_NUMB)  
           THEN @Lc_IndHoliday_CODE  
          WHEN X.Available_DATE = (SELECT TOP 1 S.Schedule_DATE  
                                   FROM SWKS_Y1 S  
                                  WHERE S.Worker_ID = @Ac_Worker_ID  
                                    AND S.Schedule_DATE = X.Available_DATE  
                                    AND S.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVactn_CODE)
                                    AND S.ApptStatus_CODE  = @Lc_ApptStatusSc_CODE)  
           THEN @Lc_IndAvailable_CODE  
          WHEN  ISNULL(   
      (
		SELECT SUM(TotalScheduledcalendar_Time) TotalScheduledcalendar_Time  
         FROM (
               SELECT  S1.Schedule_DATE, 
                  DATEDIFF(MI,S1.BEGINSCH_DTTM,S1.EndSch_DTTM) AS TotalScheduledcalendar_Time  
             FROM SWKS_Y1 S1  
             WHERE S1.Schedule_DATE = x.Available_DATE  
             AND S1.ActivityMinor_CODE IN ( @Lc_ActivityMinorPrsnl_CODE,@Lc_ActivityMinorAdmin_CODE,@Lc_ActivityMinorVactn_CODE)
                AND S1.ApptStatus_CODE  = @Lc_ApptStatusSc_CODE)a  
      GROUP BY Schedule_DATE) ,@Li_MinusOne_NUMB)  
    <  
    ISNULL((SELECT DATEDIFF(MI,S2.BeginWork_DTTM, S2.EndWork_DTTM) AS TotalWork_Time  
      FROM SWRK_Y1 S2    
      WHERE S2.Worker_ID = @Ac_Worker_ID  
      AND S2.Day_CODE = DATEPART(DW,X.Available_DATE) ) , @Li_MinusTwo_NUMB)   
     THEN @Lc_IndAvailable_CODE        
          ELSE @Lc_IndUnavailable_CODE  
         END AS Availability_INDC  
    FROM (SELECT Available_DATE  
           FROM dbo.BATCH_COMMON$SF_GET_AVAILABLE_SCHEDULE_DATE(-1,@Ld_Start_DATE,@Ld_End_DATE,@Lc_Screen_INDC)) AS X  
   ORDER BY Schedule_DATE;  
 END; --END OF SWKS_RETRIEVE_S24       
  
  
  

GO
