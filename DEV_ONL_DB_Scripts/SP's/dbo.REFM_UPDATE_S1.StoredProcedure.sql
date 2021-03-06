/****** Object:  StoredProcedure [dbo].[REFM_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_UPDATE_S1] (
 @Ac_Table_ID                 CHAR(4),
 @Ac_TableSub_ID              CHAR(4),
 @Ac_Value_CODE               CHAR(10),
 @As_DescriptionValue_TEXT    VARCHAR(70),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_UPDATE_S1
  *     DESCRIPTION       : Update RefMaintenance details for Table Indo, Sub Table Idno, and Value Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_Systemdate_DTTM   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE REFM_Y1
     SET DescriptionValue_TEXT = @As_DescriptionValue_TEXT,
         BeginValidity_DATE = @Ld_Systemdate_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Systemdate_DTTM
   WHERE Table_ID = @Ac_Table_ID
     AND TableSub_ID = @Ac_TableSub_ID
     AND Value_CODE = @Ac_Value_CODE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End Of REFM_UPDATE_S1

GO
