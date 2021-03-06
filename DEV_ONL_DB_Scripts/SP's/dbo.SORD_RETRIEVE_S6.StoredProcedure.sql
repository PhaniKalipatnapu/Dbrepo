/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S6] (
 @An_Case_IDNO     NUMERIC(6, 0),
 @Ac_File_ID       CHAR(15) OUTPUT,
 @An_Order_IDNO    NUMERIC(15, 0) OUTPUT,
 @An_OrderSeq_NUMB NUMERIC(2, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SORD_RETRIEVE_S6
  *     DESCRIPTION       : Retrieves the support Order details for the respective Case Id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_OrderSeq_NUMB = NULL,
         @An_Order_IDNO = NULL,
         @Ac_File_ID = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_OrderSeq_NUMB = S.OrderSeq_NUMB,
         @An_Order_IDNO = S.Order_IDNO,
         @Ac_File_ID = S.File_ID
    FROM SORD_Y1 S
   WHERE S.Case_IDNO = @An_Case_IDNO
     AND S.EndValidity_DATE = @Ld_High_DATE
     AND S.OrderSeq_NUMB = (SELECT MIN(S.OrderSeq_NUMB)
                              FROM SORD_Y1 S
                             WHERE S.Case_IDNO = @An_Case_IDNO
                               AND S.EndValidity_DATE = @Ld_High_DATE);
 END; -- End Of SORD_RETRIEVE_S6

GO
