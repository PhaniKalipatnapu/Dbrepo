/****** Object:  StoredProcedure [dbo].[INCM_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INCM_UPDATE_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeIncome_CODE          CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : INCM_UPDATE_S1
  *     DESCRIPTION       : Update End Validity Date to current date for given member Idno, Source of Income Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DATE      DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10, 0) = 0;

  UPDATE INCM_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND TypeIncome_CODE = @Ac_TypeIncome_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SELECT @Ln_RowsAffected_NUMB;
 END; --End of INCM_UPDATE_S1


GO
