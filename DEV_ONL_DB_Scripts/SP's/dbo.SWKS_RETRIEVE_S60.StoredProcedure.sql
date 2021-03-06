/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S60]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S60]  
(    
 @Ac_Worker_ID     CHAR(30),  
 @Ac_Exists_INDC   CHAR(1)  OUTPUT
 )    
AS    
 /*    
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S60   
  *     DESCRIPTION       : This sp is used to retrieve the data which is schedule for the particular worker id.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */    
 BEGIN    
    
  DECLARE @Lc_ApptStatusRescheduled_CODE  CHAR(2) = 'RS',    
          @Lc_ApptStatusScheduled_CODE    CHAR(2) = 'SC',    
          @Lc_ActivityMinorAdmin_CODE     CHAR(5) = 'ADMIN',      
          @Lc_ActivityMinorPrsnl_CODE     CHAR(5) = 'PRSNL',      
          @Lc_ActivityMinorVacation_CODE  CHAR(5) = 'VACTN',
          @Ld_High_DATE 		          DATE    = '12/31/9999',
          @Ld_Current_DATE                DATE    = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_Yes_TEXT                    CHAR(1) = 'Y',  
          @Lc_No_TEXT                     CHAR(1) = 'N';      
          
      SET @Ac_Exists_INDC = @Lc_No_TEXT;  
    
  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT 
    FROM SWKS_Y1 S    
   WHERE S.Worker_id = @Ac_Worker_ID    
     AND S.ApptStatus_CODE IN (@Lc_ApptStatusRescheduled_CODE, @Lc_ApptStatusScheduled_CODE)    
     AND S.ActivityMinor_CODE NOT IN(@Lc_ActivityMinorAdmin_CODE,@Lc_ActivityMinorPrsnl_CODE,@Lc_ActivityMinorVacation_CODE) 
     AND S.Schedule_DATE BETWEEN @Ld_Current_DATE AND @Ld_High_DATE;    
    
    
 END; --END OF SWKS_RETRIEVE_S60  
     
    
    
  

GO
