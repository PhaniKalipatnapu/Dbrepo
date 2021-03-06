/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S49]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S49] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_TotFuture_AMNT NUMERIC(15, 2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S49
  *     DESCRIPTION       : Retrieve Total Future Amount for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TotFuture_AMNT = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_ReasonStatusHold_CODE  CHAR(4) = 'SNFX',
          @Lc_StatusReceiptHold_CODE CHAR(1) = 'H';

  SELECT @An_TotFuture_AMNT = ISNULL(SUM(I.ToDistribute_AMNT), 0)
    FROM CASE_Y1 H
         JOIN RCTH_Y1 I
          ON I.Case_IDNO = H.Case_IDNO
   WHERE H.Case_IDNO = @An_Case_IDNO
     AND I.StatusReceipt_CODE = @Lc_StatusReceiptHold_CODE
     AND I.ReasonStatus_CODE = @Lc_ReasonStatusHold_CODE
     AND I.EndValidity_DATE = @Ld_High_DATE;
 END; --End of RCTH_RETRIEVE_S49 

GO
