/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S55]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
 
CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S55] (  
 @Ac_Worker_ID          CHAR(30),  
 @Ad_Schedule_DATE      DATE,  
 @Ad_BeginSch_DTTM      DATETIME2,  
 @Ad_EndSch_DTTM        DATETIME2,  
 @Ai_Count_QNTY         INT OUTPUT  
 )  
AS  
 /*  
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S55  
  *     DESCRIPTION       : Check whether vactn, prsnl, admin activity exists in the scheduled time.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 20-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  DECLARE @Lc_ActivityMinorPrsnl_CODE  CHAR(5) = 'PRSNL',  
    @Lc_ActivityMinorAdmin_CODE  CHAR(5) = 'ADMIN',  
    @Lc_ActivityMinorVactn_CODE  CHAR(5) = 'VACTN',
    @Lc_ApptStatusSc_CODE       CHAR(2) = 'SC';    
   
  SELECT @Ai_Count_QNTY = COUNT(Schedule_Date)  
  FROM SWKS_Y1 s  
  WHERE s.Worker_ID = @Ac_Worker_ID  
  AND s.Schedule_DATE = @Ad_Schedule_DATE  
  AND s.ActivityMinor_CODE IN (@Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorAdmin_CODE,@Lc_ActivityMinorVactn_CODE)  
  AND (@Ad_BeginSch_DTTM BETWEEN s.BeginSch_DTTM AND s.EndSch_DTTM  
       OR @Ad_EndSch_DTTM BETWEEN s.BeginSch_DTTM   AND s.EndSch_DTTM  
       OR s.BeginSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM  
       OR s.EndSch_DTTM BETWEEN @Ad_BeginSch_DTTM AND @Ad_EndSch_DTTM)
  AND s.ApptStatus_CODE  = @Lc_ApptStatusSc_CODE;     
   
   
 END --END OF SWKS_RETRIEVE_S55  
    

GO
