/****** Object:  StoredProcedure [dbo].[UASM_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_UPDATE_S3](
 @Ac_Worker_ID                   CHAR(30),
 @Ad_Expire_DATE				 DATE,
 @An_NewTransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID           CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : UASM_UPDATE_S3
  *     DESCRIPTION       : Logically delete all the valid record for a Worker ID, and Unique Sequence Number where end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/04/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

  UPDATE UASM_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
  OUTPUT Deleted.Worker_ID,
         Deleted.Office_IDNO,
         Deleted.WorkPhone_NUMB,
         Deleted.Effective_DATE,
         ISNULL(@Ad_Expire_DATE,@Ld_High_DATE),
         @Ld_Current_DATE AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @An_NewTransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
         @Ld_Current_DTTM AS Update_DTTM,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID
  INTO UASM_Y1
   WHERE Worker_ID = @Ac_Worker_ID
	 AND Expire_DATE >= @Ad_Expire_DATE
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
