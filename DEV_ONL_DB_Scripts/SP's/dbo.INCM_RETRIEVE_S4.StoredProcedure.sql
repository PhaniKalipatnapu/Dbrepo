/****** Object:  StoredProcedure [dbo].[INCM_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INCM_RETRIEVE_S4] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @Ac_TypeIncome_CODE          CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Exists_INDC              CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : INCM_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve record count for a Member Idno, Income Expense Code, Source of Income Expense Code, Transaction Event Sequence and Validity End Date.
  *     DEVELOPED BY      : IMP Team.
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Lc_Yes_INDC  CHAR(1)='Y',
          @Lc_No_INDC   CHAR(1)='N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM INCM_Y1 i
   WHERE i.MemberMci_IDNO = @An_MemberMci_IDNO
     AND i.TypeIncome_CODE = @Ac_TypeIncome_CODE
     AND i.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND i.EndValidity_DATE = @Ld_High_DATE;
 END; --End of INCM_RETRIEVE_S4


GO
