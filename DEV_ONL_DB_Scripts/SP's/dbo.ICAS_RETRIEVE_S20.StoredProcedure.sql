/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S20] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Status_CODE CHAR(1),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : ICAS_RETRIEVE_S20
  *     DESCRIPTION       : To check whether a Valid ISIN Record exists for given status
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ICAS_Y1 i
   WHERE i.Case_IDNO = @An_Case_IDNO
     AND i.Status_CODE = @Ac_Status_CODE
     AND i.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF ICAS_RETRIEVE_S20


GO
