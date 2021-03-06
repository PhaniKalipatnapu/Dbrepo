/****** Object:  StoredProcedure [dbo].[GTST_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_UPDATE_S6]  
(                                   
	 @An_Case_IDNO         NUMERIC(6)    ,
     @An_MemberMci_IDNO	   NUMERIC(10)   ,   
     @An_Schedule_NUMB     NUMERIC(10,0) ,  
     @Ad_Test_DATE         DATE          ,
     @Ac_SignedOnWorker_ID    CHAR(30)    ,
     @An_TransactionEventSeq_NUMB    NUMERIC(19,0)  
          
 ) 
AS
 /*
  *     PROCEDURE NAME    : GTST_UPDATE_S6
  *     DESCRIPTION       : Update the Staus Date for a given Recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 2-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
   BEGIN
   
     DECLARE @Ld_High_DATE 		                  DATE    = '12/31/9999',
             @Lc_TestResultScheduled_CODE	      CHAR(1) = 'S',
             @Ld_Systemdatetime_DTTM              DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),	
    	     @Ln_RowsAffected_NUMB	              NUMERIC(10) ,
    	     @Lc_TestResultcancelled_CODE         CHAR(1) = 'C';
    	  
      UPDATE GTST_Y1 
       SET  EndValidity_DATE = @Ld_Systemdatetime_DTTM 
       OUTPUT
                	Deleted.Case_IDNO,   
					Deleted.MemberMci_IDNO,   
					Deleted.Schedule_NUMB,
					Deleted.Test_DATE,   
					Deleted.Test_AMNT,   
					Deleted.OthpLocation_IDNO,   
					Deleted.PaidBy_NAME,   
					@Ld_Systemdatetime_DTTM AS BeginValidity_DATE,   
					@Ld_High_DATE           AS EndValidity_DATE,   
					@Ac_SignedOnWorker_ID   AS WorkerUpdate_ID,   
					@Ld_Systemdatetime_DTTM AS Update_DTTM,   
					@An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,   
					Deleted.Lab_NAME,   
					Deleted.LocationState_CODE, 
					Deleted.Location_NAME,
					Deleted.CountyLocation_IDNO,  
					Deleted.TypeTest_CODE,
					Deleted.ResultsReceived_DATE,
					@Lc_TestResultcancelled_CODE AS TestResult_CODE,
					Deleted.Probability_PCT
					INTO GTST_Y1	
      WHERE Case_IDNO      = @An_Case_IDNO 
      AND   MemberMci_IDNO = @An_MemberMci_IDNO 
      AND   Schedule_NUMB  = @An_Schedule_NUMB 
      AND   Test_DATE      = @Ad_Test_DATE 
      AND   TestResult_CODE  = @Lc_TestResultScheduled_CODE 
      AND   EndValidity_DATE = @Ld_High_DATE;
	         
   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

	SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB; 
	
END; --END OF GTST_UPDATE_S6



GO
