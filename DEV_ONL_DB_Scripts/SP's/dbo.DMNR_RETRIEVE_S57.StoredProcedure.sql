/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S57]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S57] (
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_Schedule_NUMB NUMERIC(10, 0),
 @Ac_Status_CODE   CHAR(4) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S57
  *     DESCRIPTION       : Retrieve the Status for Schedule Number and Case Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 31-AUG-2011  
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Status_CODE = NULL;

  SELECT @Ac_Status_CODE = D.Status_CODE
    FROM DMNR_Y1 D
   WHERE D.Schedule_NUMB = @An_Schedule_NUMB
     AND D.Case_IDNO = @An_Case_IDNO;
 END; --END OF DMNR_RETRIEVE_S57


GO
