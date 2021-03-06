/****** Object:  StoredProcedure [dbo].[GTST_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_UPDATE_S4] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Schedule_NUMB            NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : GTST_UPDATE_S4
  *     DESCRIPTION       : Update End Date Validity to Today's Date for a Case Idno, Genetic Test Number, Transaction Sequence Number, and Result of the Genetic Test is Scheduled, and End Date Validity is High Date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE                DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB        NUMERIC(10),
          @Ld_Systemdatetime_DTTM      DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE GTST_Y1
     SET EndValidity_DATE = @Ld_Systemdatetime_DTTM
   WHERE Schedule_NUMB = @An_Schedule_NUMB
     AND EndValidity_DATE = @Ld_High_DATE
     AND Case_IDNO = @An_Case_IDNO
     AND TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of GTST_UPDATE_S4   


GO
