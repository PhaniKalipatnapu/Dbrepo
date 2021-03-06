/****** Object:  StoredProcedure [dbo].[SWKS_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SWKS_UPDATE_S2] (    
 @An_Schedule_NUMB            NUMERIC(10, 0),    
 @Ac_ActivityMinor_CODE       CHAR(5),    
 @Ac_ApptStatus_CODE          CHAR(2),    
 @Ac_SignedOnWorker_ID        CHAR(30),    
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)    
 )    
AS    
 /*      
  *     PROCEDURE NAME    : SWKS_UPDATE_S2      
  *     DESCRIPTION       : Update Worker details for a Given Schedule no.      
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 02-MAR-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */    
 BEGIN    
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),    
          @Ld_Update_DTTM       DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_Space_TEXT        CHAR(1) = '';
    
  UPDATE SWKS_Y1    
     SET ActivityMinor_CODE = ( SELECT CASE  @Ac_ActivityMinor_CODE   
                                 WHEN  @Lc_Space_TEXT  THEN  ActivityMinor_CODE
                                 ELSE @Ac_ActivityMinor_CODE  END),    
         ApptStatus_CODE = @Ac_ApptStatus_CODE,    
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,    
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,    
         Update_DTTM = @Ld_Update_DTTM    
     OUTPUT
     	Deleted.Schedule_NUMB,  
		Deleted.Case_IDNO,  
		Deleted.Worker_ID,  
		Deleted.MemberMci_IDNO,  
		Deleted.OthpLocation_IDNO,  
		Deleted.ActivityMajor_CODE,  
		Deleted.ActivityMinor_CODE,  
		Deleted.TypeActivity_CODE,  
		Deleted.WorkerDelegateTo_ID,  
		Deleted.Schedule_DATE,  
		Deleted.BeginSch_DTTM,  
		Deleted.EndSch_DTTM,  
		Deleted.ApptStatus_CODE,  
		Deleted.SchParent_NUMB,  
		Deleted.SchPrev_NUMB,  
		Deleted.WorkerUpdate_ID,  
		Deleted.BeginValidity_DATE,  
		@Ld_Current_DATE AS EndValidity_DATE,  
		Deleted.Update_DTTM,  
		Deleted.TransactionEventSeq_NUMB,  
		Deleted.TypeFamisProceeding_CODE,  
		Deleted.ReasonAdjourn_CODE,  
		Deleted.Worker_NAME,  
		Deleted.SchedulingUnit_CODE  
	INTO HSWKS_Y1
   WHERE Schedule_NUMB = @An_Schedule_NUMB;    
    
  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;    
    
  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;    
 END; -- END OF SWKS_UPDATE_S2      
    
GO
