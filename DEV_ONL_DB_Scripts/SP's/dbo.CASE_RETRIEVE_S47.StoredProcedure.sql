/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S47] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S47
  *     DESCRIPTION       : Retrieve the Docket Idno for a Case Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 25-AUG-2011   
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT C.File_ID
    FROM CASE_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO;
 END; --END OF CASE_RETRIEVE_S47 


GO
