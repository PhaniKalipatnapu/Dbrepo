/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S64]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S64] (
 @An_Case_IDNO           NUMERIC(6, 0),
 @An_OrderSeq_NUMB       NUMERIC(2, 0) OUTPUT,
 @Ad_OrderEffective_DATE DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SORD_RETRIEVE_S64
  *     DESCRIPTION       : Retrieves Sequence Order and Order Effective Date for a Case ID and Order Type is not Voluntary.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_OrderSeq_NUMB = NULL,
         @Ad_OrderEffective_DATE = NULL;

  DECLARE @Lc_TypeOrderVoluntary_CODE CHAR(1) = 'V',
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT @An_OrderSeq_NUMB = S.OrderSeq_NUMB,
         @Ad_OrderEffective_DATE = S.OrderEffective_DATE
    FROM SORD_Y1 S
   WHERE S.Case_IDNO = @An_Case_IDNO
     AND S.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
     AND S.EndValidity_DATE = @Ld_High_DATE
     AND CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN S.OrderEffective_DATE AND S.OrderEnd_DATE;
 END; --END OF SORD_RETRIEVE_S64


GO
