/****** Object:  StoredProcedure [dbo].[APDI_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDI_RETRIEVE_S1](
 @An_Application_IDNO NUMERIC(15, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : APDI_RETRIEVE_S1      
  *     DESCRIPTION       : Retrieves the medicaid and insurance details for the respective application and member.
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 12-AUG-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APDI_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO;
 END; -- End Of APDI_RETRIEVE_S1

GO
