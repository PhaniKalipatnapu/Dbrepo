/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S47] (  
 @Ad_Schedule_DATE DATE,  
 @Ac_Worker_ID     CHAR(30)  
 )  
AS  
 /*                                                                                                                                            
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S47                                                                                                  
  *     DESCRIPTION       : Retrieve unavailability date for the Worker.                                                                                                                                                              
  *     DEVELOPED BY      : IMP Team                                                                                             
  *     DEVELOPED ON      : 06-JUN-2011                                                                                                        
  *     MODIFIED BY       :                                                                                                                    
  *     MODIFIED ON       :                                                                                                                    
  *     VERSION NO        : 1                                                                                                                  
 */  
 BEGIN  
  DECLARE @Lc_ActivityMinorAdmin_CODE CHAR(5)= 'ADMIN',  
          @Lc_ActivityMinorPrsnl_CODE CHAR(5)= 'PRSNL',  
          @Lc_ActivityMinorVactn_CODE CHAR(5)= 'VACTN',
          @Lc_ApptStatusSc_CODE       CHAR(2) = 'SC';  
  
  SELECT Schedule_DATE,  
         a.BeginSch_DTTM,  
         a.EndSch_DTTM  
    FROM SWKS_Y1 a  
   WHERE a.Schedule_DATE = @Ad_Schedule_DATE  
     AND a.Worker_ID = @Ac_Worker_ID  
     AND a.ActivityMinor_CODE IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVactn_CODE)
     AND a.ApptStatus_CODE  = @Lc_ApptStatusSc_CODE;   
 END; --END OF SWKS_RETRIEVE_S47                                                                                                                                           
  
  

GO
