/****** Object:  StoredProcedure [dbo].[MDET_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MDET_UPDATE_S1] (
 @An_MemberMci_IDNO					NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB		NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : MDET_UPDATE_S1
  *     DESCRIPTION       : Logically delete the record in Member Detention table for Unique System generated Id for the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE MDET_Y1
     SET EndValidity_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
	 AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END of MDET_UPDATE_S1


GO
