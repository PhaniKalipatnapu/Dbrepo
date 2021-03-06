/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S49]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S49] (
 @Ac_File_ID CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S49
  *     DESCRIPTION       : Retrieve the case for the given file id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 27-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT C.Case_IDNO
    FROM CASE_Y1 C
   WHERE C.File_ID = @Ac_File_ID;
 END;


GO
