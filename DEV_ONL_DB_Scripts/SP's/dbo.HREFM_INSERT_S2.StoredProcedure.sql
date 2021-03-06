/****** Object:  StoredProcedure [dbo].[HREFM_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HREFM_INSERT_S2] (
 @Ac_Table_ID                 CHAR(4),
 @Ac_TableSub_ID              CHAR(4),
 @Ac_Value_CODE               CHAR(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : HREFM_INSERT_S2
  *     DESCRIPTION       : Insert RefMaintenance Details into History table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdate_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT HREFM_Y1
         (Table_ID,
          TableSub_ID,
          DescriptionTable_TEXT,
          Value_CODE,
          DescriptionValue_TEXT,
          DispOrder_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  SELECT R.Table_ID,
         R.TableSub_ID,
         R.DescriptionTable_TEXT,
         R.Value_CODE,
         R.DescriptionValue_TEXT,
         R.DispOrder_NUMB,
         R.BeginValidity_DATE,
         @Ld_Systemdate_DTTM,
         @Ac_SignedOnWorker_ID,
         @An_TransactionEventSeq_NUMB,
         R.Update_DTTM
    FROM REFM_Y1 R
   WHERE R.Table_ID = @Ac_Table_ID
     AND R.TableSub_ID = @Ac_TableSub_ID
     AND R.Value_CODE = @Ac_Value_CODE;
 END; --End of HREFM_INSERT_S2

GO
