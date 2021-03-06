/****** Object:  StoredProcedure [dbo].[BNKR_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BNKR_UPDATE_S1] (
 @An_MemberMci_IDNO					NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB		NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : BNKR_UPDATE_S1
  *     DESCRIPTION       : Logically update the record in Member Bankruptcy table for Unique Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE BNKR_Y1
     SET EndValidity_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
	 AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END of BNKR_UPDATE_S1


GO
