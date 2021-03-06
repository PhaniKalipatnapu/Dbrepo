/****** Object:  StoredProcedure [dbo].[ACEN_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_UPDATE_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ad_EndExempt_DATE           DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 **     PROCEDURE NAME    : ACEN_UPDATE_S1
  *     DESCRIPTION       : Logically delete the valid record for a Case ID, Unique Sequence Number when end validity date is equal to high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
  DECLARE @Ld_High_DATE  DATE = '12/31/9999',
          @Ld_Today_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE ACEN_Y1
     SET EndExempt_DATE = @Ad_EndExempt_DATE,
         EndValidity_DATE = @Ld_Today_DATE
   WHERE Case_IDNO = @An_Case_IDNO
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END --End of ACEN_UPDATE_S1


GO
