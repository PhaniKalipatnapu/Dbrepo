/****** Object:  StoredProcedure [dbo].[REFM_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_INSERT_S1] (
 @Ac_Table_ID                 CHAR(4),
 @Ac_TableSub_ID              CHAR(4),
 @Ac_Value_CODE               CHAR(10),
 @Ac_DescriptionTable_TEXT    CHAR(30),
 @As_DescriptionValue_TEXT    VARCHAR(70),
 @An_DispOrder_NUMB           NUMERIC(3, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_INSERT_S1
  *     DESCRIPTION       : Insert RefMaintenance records into REFM table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME ();

  INSERT REFM_Y1
         (Table_ID,
          TableSub_ID,
          DescriptionTable_TEXT,
          Value_CODE,
          DescriptionValue_TEXT,
          DispOrder_NUMB,
          BeginValidity_DATE,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB,
          Update_DTTM)
  VALUES ( @Ac_Table_ID,
           @Ac_TableSub_ID,
           @Ac_DescriptionTable_TEXT,
           @Ac_Value_CODE,
           @As_DescriptionValue_TEXT,
           @An_DispOrder_NUMB,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB,
           @Ld_Systemdatetime_DTTM );
 END; --End of REFM_INSERT_S1

GO
