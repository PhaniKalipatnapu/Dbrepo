/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S48]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S48] (  
 @Ac_Worker_ID  CHAR(30),  
 @Ad_Start_DATE DATE,  
 @Ad_End_DATE   DATE  
 )  
AS  
 /*                                                                                                                                                                                                                            
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S48                                                                                                                                                                                   
  *     DESCRIPTION       : Retrieve Schedule number,Scheduled date, Start Time and end time from which the location is available for given date  
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                         
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                                        
  *     MODIFIED BY       :                                                                                                                                                                                                    
  *     MODIFIED ON       :                                                                                                                                                                                                    
  *     VERSION NO        : 1                                                                                                                                                                                                  
 */  
 BEGIN  
   
  DECLARE  
    @Lc_ActivityMinorAdmin_CODE  CHAR(5) = 'ADMIN',  
    @Lc_ActivityMinorPrsnl_CODE  CHAR(5) = 'PRSNL',  
    @Lc_ActivityMinorVacation_CODE  CHAR(5) = 'VACTN',  
    @Lc_ProcessMcal_ID  CHAR(4) = 'MCAL',
    @Lc_ApptStatusSc_CODE  CHAR(2) = 'SC';
   
    
  SELECT S.Schedule_NUMB,  
         S.Schedule_DATE,  
         S.ActivityMinor_CODE,  
         S.BeginSch_DTTM,  
         S.EndSch_DTTM,  
         S.TransactionEventSeq_NUMB,  
         R.Type_CODE  
    FROM SWKS_Y1 S  
     LEFT OUTER JOIN   
     RESF_Y1 R  
     ON (S.ActivityMinor_CODE =  R.Reason_CODE  
   AND R.Process_ID = @Lc_ProcessMcal_ID)  
   WHERE S.Schedule_DATE BETWEEN @Ad_Start_DATE AND @Ad_End_DATE  
     AND S.Worker_ID = @Ac_Worker_ID  
     AND S.ActivityMinor_CODE IN (@Lc_ActivityMinorAdmin_CODE, @Lc_ActivityMinorPrsnl_CODE, @Lc_ActivityMinorVacation_CODE)
     AND S.ApptStatus_CODE  = @Lc_ApptStatusSc_CODE; 
    
       
 END; --END OF  SWKS_RETRIEVE_S48                                                                                                                                                                                                                          
  

GO
