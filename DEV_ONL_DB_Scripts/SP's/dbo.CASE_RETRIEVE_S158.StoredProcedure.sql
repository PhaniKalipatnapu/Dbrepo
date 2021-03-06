/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S158]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S158]
(
     @Ac_File_ID		 CHAR(10),
     @An_Case_IDNO       NUMERIC(6,0) OUTPUT
)     
AS

/*
 *     PROCEDURE NAME    : CASE_RETRIEVE_S158
 *     DESCRIPTION       : Retrieve the top first case for the given file id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

BEGIN

	SELECT TOP 1 @An_Case_IDNO = C.Case_IDNO 
	FROM CASE_Y1 C
	WHERE C.File_ID = @Ac_File_ID ;

END; --End Of Procedure CASE_RETRIEVE_S158

GO
