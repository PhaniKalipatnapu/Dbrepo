/****** Object:  StoredProcedure [dbo].[USEM_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_UPDATE_S2](
 @Ac_Worker_ID                   CHAR(30),
 @Ac_First_NAME                  CHAR(16),
 @Ac_Middle_NAME                 CHAR(20),
 @Ac_Last_NAME                   CHAR(20),
 @Ac_Suffix_NAME                 CHAR(4),
 @Ac_WorkerTitle_CODE            CHAR(2),
 @Ac_WorkerSubTitle_CODE         CHAR(2),
 @Ac_Organization_NAME           CHAR(25),
 @As_Contact_EML                 VARCHAR(100),
 @Ad_BeginEmployment_DATE        DATE,
 @Ad_EndEmployment_DATE          DATE,
 @An_TransactionEventSeq_NUMB    NUMERIC(19),
 @An_NewTransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID           CHAR(30)
 )
AS
 /*    
   *     PROCEDURE NAME    : USEM_UPDATE_S2    
   *     DESCRIPTION       : Logically delete the valid record for a Worker ID and Unique Sequence Number 
                                           where end date validity is high date.    
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 10/20/2011
   *     MODIFIED BY       :     
   *     MODIFIED ON       :     
   *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE    DATE ='12/31/9999';
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

  UPDATE USEM_Y1
     SET First_NAME = @Ac_First_NAME,
         Middle_NAME = @Ac_Middle_NAME,
         Last_NAME = @Ac_Last_NAME,
         Suffix_NAME = @Ac_Suffix_NAME,
         Contact_EML = @As_Contact_EML,
         WorkerTitle_CODE = @Ac_WorkerTitle_CODE,
         WorkerSubTitle_CODE = @Ac_WorkerSubTitle_CODE,
         Organization_NAME = @Ac_Organization_NAME,
         BeginEmployment_DATE = @Ad_BeginEmployment_DATE,
         EndEmployment_DATE = @Ad_EndEmployment_DATE,
         BeginValidity_DATE = @Ld_Current_DATE,
         EndValidity_DATE = @Ld_High_DATE,
         TransactionEventSeq_NUMB = @An_NewTransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Current_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID
  OUTPUT Deleted.Worker_ID,
         Deleted.First_NAME,
         Deleted.Middle_NAME,
         Deleted.Last_NAME,
         Deleted.Suffix_NAME,
         Deleted.Contact_EML,
         Deleted.WorkerTitle_CODE,
         Deleted.WorkerSubTitle_CODE,
         Deleted.Organization_NAME,
         Deleted.BeginEmployment_DATE,
         Deleted.EndEmployment_DATE,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.TransactionEventSeq_NUMB,
         Deleted.Update_DTTM,
         Deleted.WorkerUpdate_ID
  INTO USEM_Y1
   WHERE Worker_ID = @Ac_Worker_ID
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
