/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S98]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S98] (
 @An_BarAtty_NUMB NUMERIC(10, 0),
 @Ai_Count_QNTY   INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S98
  *     DESCRIPTION       : Retrieve the row count for an Attorney's Bar number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM OTHP_Y1 O
   WHERE O.BarAtty_NUMB = @An_BarAtty_NUMB
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF OTHP_RETRIEVE_S98 


GO
