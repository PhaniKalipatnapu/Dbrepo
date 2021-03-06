/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S140]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S140] (
 @An_Case_IDNO           NUMERIC(6, 0),
 @An_PayorMCI_IDNO       NUMERIC(10, 0),
 @An_TotalDirectPay_AMNT NUMERIC(19, 2) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S140  
  *     DESCRIPTION       : Retrieves the total receipt amount associated with the given case and member.
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 25-FEB-2012  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @An_TotalDirectPay_AMNT = NULL;

  DECLARE @Ld_High_DATE                               DATE = '12/31/9999',
          @Lc_ChildSrcDirectPayCreditSourceBatch_CODE CHAR(3) = 'DCR';

  SELECT @An_TotalDirectPay_AMNT = SUM(R.Receipt_AMNT)
    FROM RCTH_Y1 R
   WHERE R.Case_IDNO = @An_Case_IDNO
     AND R.SourceBatch_CODE = @Lc_ChildSrcDirectPayCreditSourceBatch_CODE
     AND R.PayorMCI_IDNO = @An_PayorMCI_IDNO
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END --END OF RCTH_RETRIEVE_S140

GO
