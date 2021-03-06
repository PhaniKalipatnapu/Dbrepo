/****** Object:  StoredProcedure [dbo].[GTST_UPDATE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GTST_UPDATE_S8]           
(        
     @An_Case_IDNO            NUMERIC(6)           ,  
     @An_Schedule_NUMB        NUMERIC(10)          ,  
     @Ac_SignedOnWorker_ID    CHAR(30)             ,      
     @An_TransactionEventSeq_NUMB    NUMERIC(19,0)   
    )          
         
AS        
        
/*        
*      PROCEDURE NAME    : GTST_UPDATE_S8       
 *     DESCRIPTION       : This sp will update AND insert the details of GTST_Y1 table.        
  *    DEVELOPED BY      : IMP Team        
 *     DEVELOPED ON      : 02-AUG-2011        
 *     MODIFIED BY       :         
 *     MODIFIED ON       :         
 *     VERSION NO        : 1        
*/        
   BEGIN        
              
    DECLARE   
           @Ld_High_DATE                     DATE    = '12/31/9999',        
             @Ld_Systemdatetime_DTTM           DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),         
       @Ln_RowsAffected_NUMB             NUMERIC(10)  ,  
       @Lc_TestReslutScheduled_CODE CHAR(1) = 'S',  
           @Lc_CaseRealtionshipDep_CODE  CHAR(1) ='D',  
           @Lc_CaseMemberStatusActive_CODE  CHAR(1) ='A',  
            @Lc_TestReslutConducted_CODE CHAR(1) = 'K',    
         @Lc_TestReslutCancel_CODE    CHAR(1) = 'C',    
         @Lc_TestReslutFailedToAppear_CODE    CHAR(1) = 'F', 
           @Lc_TestResult_CODE CHAR(1)='D' ;            
      
    UPDATE GTST_Y1      
        SET EndValidity_DATE =  @Ld_Systemdatetime_DTTM         
     OUTPUT     
     Deleted.Case_IDNO,           
     Deleted.MemberMci_IDNO,           
     Deleted.Schedule_NUMB,        
     Deleted.Test_DATE,           
     Deleted.Test_AMNT,           
     Deleted.OthpLocation_IDNO,           
     Deleted.PaidBy_NAME,           
     @Ld_Systemdatetime_DTTM AS BeginValidity_DATE,           
     @Ld_High_DATE    AS EndValidity_DATE,           
     @Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,           
     @Ld_Systemdatetime_DTTM AS Update_DTTM,           
     @An_TransactionEventSeq_NUMB  AS TransactionEventSeq_NUMB,           
     Deleted.Lab_NAME,           
     Deleted.LocationState_CODE,         
     Deleted.Location_NAME,        
     Deleted.CountyLocation_IDNO,          
     Deleted.TypeTest_CODE,          
     Deleted.ResultsReceived_DATE,        
     @Lc_TestResult_CODE AS TestResult_CODE,        
     Deleted.Probability_PCT        
     INTO GTST_Y1    
      WHERE Case_IDNO       = @An_Case_IDNO         
       AND  Schedule_NUMB   = @An_Schedule_NUMB         
       AND  MemberMci_IDNO  IN (SELECT Membermci_idno   
										 FROM cmem_y1   
										 WHERE Case_idno =@An_Case_IDNO  
										 AND caserelationship_code=@Lc_CaseRealtionshipDep_CODE  
										 AND casememberstatus_code=@Lc_CaseMemberStatusActive_CODE )  
       AND  EndValidity_DATE  = @Ld_High_DATE
      AND TestResult_CODE NOT IN (@Lc_TestReslutConducted_CODE,@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE)  
        ;        
               
    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;        
        
 SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;         
END --END OF GTST_UPDATE_S8       
GO
