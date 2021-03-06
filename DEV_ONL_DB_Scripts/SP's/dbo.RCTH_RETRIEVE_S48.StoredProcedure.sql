/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S48]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S48] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_TotDistHeld_AMNT NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S48
  *     DESCRIPTION       : Retrieve Total Distribute Amount for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TotDistHeld_AMNT = NULL;

  DECLARE @Lc_CaseRelationshipNcp_CODE    CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_StatusReceiptHeld_CODE      CHAR(1) = 'H',
          @Lc_TypePostingCase_CODE        CHAR(1) = 'C',
          @Lc_TypePostingPayor_CODE       CHAR(1) = 'P',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_DistributeLow_DATE          DATE = '01/01/0001';

  SELECT @An_TotDistHeld_AMNT = ISNULL(SUM(R.ToDistribute_AMNT), 0)
    FROM RCTH_Y1 R
         JOIN CMEM_Y1 M
          ON M.MemberMci_IDNO = R.PayorMCI_IDNO
         JOIN CASE_Y1 C
          ON M.Case_IDNO = C.Case_IDNO
             AND (R.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                   OR (R.TypePosting_CODE = @Lc_TypePostingCase_CODE
                       AND R.Case_IDNO = C.Case_IDNO))
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND R.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
     AND R.Distribute_DATE = @Ld_DistributeLow_DATE
     AND R.EndValidity_DATE = @Ld_High_DATE
     AND M.Case_IDNO = C.Case_IDNO
     AND M.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
     AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --End of RCTH_RETRIEVE_S48 

GO
