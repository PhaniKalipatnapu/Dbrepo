/****** Object:  StoredProcedure [dbo].[SWKS_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SWKS_UPDATE_S4] (  
 @An_Schedule_NUMB              NUMERIC(10, 0),  
 @Ac_SignedOnWorker_ID          CHAR(30),  
 @An_TransactionEventSeq_NUMB   NUMERIC(19, 0),  
 @Ac_TypeFamisProceeding_CODE   CHAR(5),
 @Ac_SchedulingUnit_CODE        CHAR(2)  
 )  
AS  
 /*                                                                                                                                                                                                                       
  *     PROCEDURE NAME    : SWKS_UPDATE_S4                                                                                                                                                                              
  *     DESCRIPTION       : Update Schedule table with Proceeding Type, Begin Validity date to Today's date, Worker Idno who modified the record and Transaction Sequence Number for a  Unique Scheduled Sequence Number  
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                     
  *     DEVELOPED ON      : 09-AUG-2011                                                                                                                                                                                    
  *     MODIFIED BY       :                                                                                                                                                                                               
  *     MODIFIED ON       :                                                                                                                                                                                               
  *     VERSION NO        : 1                                                                                                                                                                                             
 */  
 BEGIN  
  DECLARE @Ld_Systemdate_DTTM   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),  
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);  
  
  UPDATE SWKS_Y1  
     SET WorkerUpdate_ID = @Ac_SignedOnWorker_ID,  
         BeginValidity_DATE = @Ld_Systemdate_DTTM,  
         Update_DTTM = @Ld_Systemdate_DTTM,  
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,  
         TypeFamisProceeding_CODE = @Ac_TypeFamisProceeding_CODE,
         SchedulingUnit_CODE = @Ac_SchedulingUnit_CODE 
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
 END; --End of SWKS_UPDATE_S4      
GO
