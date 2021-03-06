/****** Object:  StoredProcedure [dbo].[GTST_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_INSERT_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ad_Test_DATE                DATE,
 @An_Test_AMNT                NUMERIC(11, 2),
 @An_OthpLocation_IDNO        NUMERIC(9, 0),
 @As_PaidBy_NAME              VARCHAR(60),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @As_Lab_NAME                 VARCHAR(60),
 @Ac_LocationState_CODE       CHAR(2),
 @As_Location_NAME            VARCHAR(100),
 @An_CountyLocation_IDNO      NUMERIC(3, 0),
 @Ac_TypeTest_CODE            CHAR(1),
 @Ad_ResultsReceived_DATE     DATE,
 @Ac_TestResult_CODE          CHAR(1),
 @An_Probability_PCT          NUMERIC(5, 2)
 )
AS
 /*                                                                                                    
  *     PROCEDURE NAME    : GTST_INSERT_S1                                                              
  *     DESCRIPTION       : Insert details into Genetic Testing table.                                                             
  *     DEVELOPED BY      : IMP Team                                                                 
  *     DEVELOPED ON      : 02-AUG-2011                                                                
  *     MODIFIED BY       :                                                                            
  *     MODIFIED ON       :                                                                            
  *     VERSION NO        : 1                                                                          
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT GTST_Y1
         (Case_IDNO,
          MemberMci_IDNO,
          Schedule_NUMB,
          TransactionEventSeq_NUMB,
          Test_DATE,
          Test_AMNT,
          OthpLocation_IDNO,
          PaidBy_NAME,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          Lab_NAME,
          LocationState_CODE,
          Location_NAME,
          CountyLocation_IDNO,
          TypeTest_CODE,
          ResultsReceived_DATE,
          TestResult_CODE,
          Probability_PCT)
  VALUES ( @An_Case_IDNO,
           @An_MemberMci_IDNO,
           @An_Schedule_NUMB,
           @An_TransactionEventSeq_NUMB,
           @Ad_Test_DATE,
           @An_Test_AMNT,
           @An_OthpLocation_IDNO,
           @As_PaidBy_NAME,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdatetime_DTTM,
           @As_Lab_NAME,
           @Ac_LocationState_CODE,
           @As_Location_NAME,
           @An_CountyLocation_IDNO,
           @Ac_TypeTest_CODE,
           @Ad_ResultsReceived_DATE,
           @Ac_TestResult_CODE,
           @An_Probability_PCT );
 END; -- END OF GTST_INSERT_S1                                                                          


GO
