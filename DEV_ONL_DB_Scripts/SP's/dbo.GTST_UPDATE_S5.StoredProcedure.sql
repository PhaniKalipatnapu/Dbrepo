/****** Object:  StoredProcedure [dbo].[GTST_UPDATE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 
CREATE PROCEDURE [dbo].[GTST_UPDATE_S5]       
(    
     @An_Case_IDNO                  NUMERIC(6,0),    
     @An_MemberMci_IDNO      		NUMERIC(10,0) ,       
     @An_Schedule_NUMB              NUMERIC(10,0),    
     @An_TransactionEventSeq_NUMB   NUMERIC(19,0),    
     @Ad_Test_DATE     				DATE,  
     @An_Test_AMNT                  NUMERIC(11, 2),    
     @As_PaidBy_NAME                VARCHAR(60),    
     @Ac_SignedOnWorker_ID          CHAR(30),  
     @Ac_TypeTest_CODE            	CHAR(1),      
     @Ad_ResultsReceived_DATE       DATE,    
     @Ac_TestResult_CODE                 CHAR(1),    
     @An_Probability_PCT                 NUMERIC(5,2) ,        
     @An_NewTransactionEventSeq_NUMB     NUMERIC(19,0)    
    )      
     
AS    
    
/*    
*      PROCEDURE NAME    : GTST_UPDATE_S5    
 *     DESCRIPTION       : This sp will update AND insert the details of GTST_Y1 table.    
  *    DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 02-AUG-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
*/    
   BEGIN    
       
     DECLARE @Ld_High_DATE                     DATE    = '12/31/9999',    
             @Ld_Systemdatetime_DTTM           DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),     
			 @Ln_RowsAffected_NUMB             NUMERIC(10) ;        
          
    UPDATE GTST_Y1     
        SET EndValidity_DATE =  @Ld_Systemdatetime_DTTM     
        OUTPUT      Deleted.Case_IDNO,       
     Deleted.MemberMci_IDNO,       
     Deleted.Schedule_NUMB,    
     Deleted.Test_DATE,       
     @An_Test_AMNT AS Test_AMNT,       
     Deleted.OthpLocation_IDNO,       
     @As_PaidBy_NAME AS PaidBy_NAME,       
     @Ld_Systemdatetime_DTTM AS BeginValidity_DATE,       
     @Ld_High_DATE    AS EndValidity_DATE,       
     @Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,       
     @Ld_Systemdatetime_DTTM AS Update_DTTM,       
     @An_NewTransactionEventSeq_NUMB  AS TransactionEventSeq_NUMB,       
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
       AND  Schedule_NUMB   = @An_Schedule_NUMB     
       AND  MemberMci_IDNO  = @An_MemberMci_IDNO     
       AND  TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB     
       AND  TypeTest_CODE   = @Ac_TypeTest_CODE    
       AND  Test_DATE 		= @Ad_Test_DATE
       AND  EndValidity_DATE  = @Ld_High_DATE;    
           
    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;    
    
 SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;     
END --END OF GTST_UPDATE_S5    
    

GO
