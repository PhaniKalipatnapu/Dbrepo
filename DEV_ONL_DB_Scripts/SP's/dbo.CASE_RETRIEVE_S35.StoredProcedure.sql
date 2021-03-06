/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S35](
 @An_Application_IDNO NUMERIC(15),
 @An_Case_IDNO        NUMERIC(6) OUTPUT,
 @Ac_StatusCase_CODE  CHAR(1) OUTPUT,
 @Ac_File_ID          CHAR(10) OUTPUT,
 @An_County_IDNO      NUMERIC(3, 0) OUTPUT,
 @Ad_Opened_DATE      DATE OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S35  
  *     DESCRIPTION       : Retrieves the case details for a respective application Id.
  *     DEVELOPED BY      : IMP TEAM  
  *     DEVELOPED ON      : 20_SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @An_Case_IDNO = NULL,
         @Ac_StatusCase_CODE = NULL,
         @Ac_File_ID = NULL,
         @An_County_IDNO = NULL,
         @Ad_Opened_DATE = NULL;

  SELECT @An_Case_IDNO = C.Case_IDNO,
         @Ac_File_ID = C.File_ID,
         @Ac_StatusCase_CODE = C.StatusCase_CODE,
         @An_County_IDNO = C.County_IDNO,
         @Ad_Opened_DATE = C.Opened_DATE
    FROM CASE_Y1 C
   WHERE C.Application_IDNO = @An_Application_IDNO;
 END; -- End Of CASE_RETRIEVE_S35  

GO
