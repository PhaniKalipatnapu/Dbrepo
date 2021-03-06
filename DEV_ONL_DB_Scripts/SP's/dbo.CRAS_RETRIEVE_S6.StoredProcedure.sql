/****** Object:  StoredProcedure [dbo].[CRAS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*     PROCEDURE NAME    : CRAS_RETRIEVE_S6
*     DESCRIPTION       : Retrieve the Row Count for an Office, Role Idno, Request Type, and where Status Code is Pending Request.
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 10-SEP-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/
CREATE PROCEDURE [dbo].[CRAS_RETRIEVE_S6](
 @An_Office_IDNO      NUMERIC(3),
 @Ac_Role_ID          CHAR(10) = NULL,
 @Ac_TypeRequest_CODE CHAR(1),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_No_TEXT CHAR(1) = 'N';

  SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)
    FROM CRAS_Y1 CR
   WHERE CR.Office_IDNO = @An_Office_IDNO
     AND CR.Role_ID = ISNULL(@Ac_Role_ID, CR.Role_ID)
     AND CR.Status_CODE = @Lc_No_TEXT
     AND CR.TypeRequest_CODE = @Ac_TypeRequest_CODE;
 END


GO
