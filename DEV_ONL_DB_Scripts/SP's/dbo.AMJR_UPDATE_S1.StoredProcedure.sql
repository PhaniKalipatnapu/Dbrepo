/****** Object:  StoredProcedure [dbo].[AMJR_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_UPDATE_S1] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Subsystem_CODE           CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_UPDATE_S1
  *     DESCRIPTION       : Logically deletes the valid record  for the given Major Activity Code and Subsystem Code 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE           DATE = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB   NUMERIC(10);

  UPDATE AMJR_Y1
     SET EndValidity_DATE = @Ld_Systemdatetime_DTTM
   WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND Subsystem_CODE = @Ac_Subsystem_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End Of AMJR_UPDATE_S1


GO
