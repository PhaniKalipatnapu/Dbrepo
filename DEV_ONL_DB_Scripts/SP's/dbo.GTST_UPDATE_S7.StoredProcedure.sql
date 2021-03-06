/****** Object:  StoredProcedure [dbo].[GTST_UPDATE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_UPDATE_S7]       
(    
     @An_Case_IDNO                   NUMERIC(6,0),    
     @An_MemberMci_IDNO      		 NUMERIC(10,0) ,      
     @An_Schedule_NUMB               NUMERIC(9) ,
     @Ad_Test_DATE                   DATE,    
     @Ac_SignedOnWorker_ID           CHAR(30),  
     @Ac_TypeTest_CODE               CHAR(1),         
     @Ac_TestResult_CODE             CHAR(1),    
     @Ad_ResultsReceived_DATE        DATE,
     @An_Probability_PCT             NUMERIC(5,2) ,        
     @An_TransactionEventSeq_NUMB    NUMERIC(19,0)    
    )      
     
AS    
    
/*    
*      PROCEDURE NAME    : GTST_UPDATE_S7   
 *     DESCRIPTION       : This sp will update AND insert the details of GTST_Y1 table.    
  *    DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 02-AUG-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
*/    
   BEGIN    
       
     DECLARE @Ld_High_DATE                       DATE    = '12/31/9999',    
             @Ld_Systemdatetime_DTTM             DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),     
             @Ln_RowsAffected_NUMB               NUMERIC(10) ,
             @Lc_TestReslutCancel_CODE           CHAR(1) = 'C',    
             @Lc_TestReslutFailedToAppear_CODE   CHAR(1) = 'F'   ;        
          
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
     @Ad_ResultsReceived_DATE AS ResultsReceived_DATE,    
     @Ac_TestResult_CODE AS TestResult_CODE,    
     @An_Probability_PCT AS Probability_PCT    
     INTO GTST_Y1    
      WHERE Case_IDNO       = @An_Case_IDNO     
       AND  MemberMci_IDNO  = @An_MemberMci_IDNO     
       AND  TypeTest_CODE   = @Ac_TypeTest_CODE
       AND Schedule_NUMB   != @An_Schedule_NUMB 
       AND  Test_DATE       = @Ad_Test_DATE
       AND  EndValidity_DATE  = @Ld_High_DATE
       AND  TestResult_CODE NOT IN (@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE);    
           
    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;    
    
 SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;     
END --END OF GTST_UPDATE_S7   
    

GO
