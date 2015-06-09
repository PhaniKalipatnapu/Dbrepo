/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S23] (
 @Ac_Misc_ID    CHAR(11),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S21
  *     DESCRIPTION       : Checks whether the misc Id exists in the Disbursement Header table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DSBH_Y1 D
   WHERE D.Misc_ID = @Ac_Misc_ID;
 END;


GO
