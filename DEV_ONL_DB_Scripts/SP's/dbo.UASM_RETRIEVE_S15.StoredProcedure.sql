/****** Object:  StoredProcedure [dbo].[UASM_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_RETRIEVE_S15] (
 @An_Office_IDNO NUMERIC(3),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : UASM_RETRIEVE_S15
  *     DESCRIPTION       : Retrieve the office count for a Unique Identification Code for each Office 
  *						   when end validity date is equal to high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/13/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM UASM_Y1 U
   WHERE U.Office_IDNO = @An_Office_IDNO
     AND U.EndValidity_DATE = @Ld_High_DATE;
 END


GO
