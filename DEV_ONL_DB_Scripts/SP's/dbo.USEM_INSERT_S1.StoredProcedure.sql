/****** Object:  StoredProcedure [dbo].[USEM_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_INSERT_S1] (
 @Ac_Worker_ID                CHAR(30),
 @Ac_First_NAME               CHAR(16),
 @Ac_Middle_NAME              CHAR(20),
 @Ac_Last_NAME                CHAR(20),
 @Ac_Suffix_NAME              CHAR(4),
 @Ac_WorkerTitle_CODE         CHAR(2),
 @Ac_WorkerSubTitle_CODE      CHAR(2),
 @Ac_Organization_NAME        CHAR(25),
 @As_Contact_EML              VARCHAR(100),
 @Ad_BeginEmployment_DATE     DATE,
 @Ad_EndEmployment_DATE       DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*  
  *     PROCEDURE NAME    : USEM_INSERT_S1  
  *     DESCRIPTION       : Insert User Master details with the provided values.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/18/2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_High_DATE DATE ='12/31/9999';

  INSERT USEM_Y1
         (Worker_ID,
          First_NAME,
          Middle_NAME,
          Last_NAME,
          Suffix_NAME,
          Contact_EML,
          WorkerTitle_CODE,
          WorkerSubTitle_CODE,
          Organization_NAME,
          BeginEmployment_DATE,
          EndEmployment_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          TransactionEventSeq_NUMB,
          Update_DTTM,
          WorkerUpdate_ID)
  VALUES ( @Ac_Worker_ID,
           @Ac_First_NAME,
           @Ac_Middle_NAME,
           @Ac_Last_NAME,
           @Ac_Suffix_NAME,
           @As_Contact_EML,
           @Ac_WorkerTitle_CODE,
           @Ac_WorkerSubTitle_CODE,
           @Ac_Organization_NAME,
           @Ad_BeginEmployment_DATE,
           ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE),
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID );
 END


GO
