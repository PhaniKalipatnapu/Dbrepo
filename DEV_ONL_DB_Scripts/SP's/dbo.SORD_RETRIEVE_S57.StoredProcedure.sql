/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S57]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S57] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @An_OrderSeq_NUMB         NUMERIC(2, 0) OUTPUT,
 @An_Order_IDNO            NUMERIC(15, 0) OUTPUT,
 @Ac_File_ID               CHAR(10) OUTPUT,
 @Ac_CejFips_CODE          CHAR(7) OUTPUT,
 @Ac_IssuingOrderFips_CODE CHAR(7) OUTPUT,
 @Ad_OrderEffective_DATE   DATE OUTPUT,
 @Ac_InsOrdered_CODE       CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SORD_RETRIEVE_S57
  *     DESCRIPTION       : Fetches the Order sequence number for the given case id number
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11/15/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  SELECT @An_Order_IDNO = NULL,
         @Ac_File_ID = NULL,
         @Ac_CejFips_CODE = NULL,
         @Ac_IssuingOrderFips_CODE = NULL,
         @Ad_OrderEffective_DATE = NULL,
         @Ac_InsOrdered_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_OrderSeq_NUMB = S.OrderSeq_NUMB,
         @An_Order_IDNO = S.Order_IDNO,
         @Ac_File_ID = S.File_ID,
         @Ac_CejFips_CODE = S.CejFips_CODE,
         @Ac_IssuingOrderFips_CODE = S.IssuingOrderFips_CODE,
         @Ad_OrderEffective_DATE = S.OrderEffective_DATE,
         @Ac_InsOrdered_CODE = s.InsOrdered_CODE
    FROM SORD_Y1 S
   WHERE S.Case_IDNO = @An_Case_IDNO
     AND S.EndValidity_DATE = @Ld_High_DATE;
 END


GO
