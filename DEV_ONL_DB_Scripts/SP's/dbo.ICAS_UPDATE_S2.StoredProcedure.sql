/****** Object:  StoredProcedure [dbo].[ICAS_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_UPDATE_S2] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @Ac_Reason_CODE              CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_RespondentMci_IDNO       NUMERIC(10, 0)
 )
AS
 /*
 *      PROCEDURE NAME    : ICAS_UPDATE_S2
  *     DESCRIPTION       : Logically delete the record in Interstate Cases table for the IVD Open (O) Case and Reason.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE ICAS_Y1
     SET EndValidity_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE Case_IDNO = @An_Case_IDNO
     AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND Reason_CODE = @Ac_Reason_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND RespondentMci_IDNO=@An_RespondentMci_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF ICAS_UPDATE_S2

GO
