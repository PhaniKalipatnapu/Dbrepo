/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S106]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S106] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @An_County_IDNO NUMERIC(3, 0) OUTPUT,
 @Ac_County_NAME CHAR(40) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S106
  *     DESCRIPTION       : Retrieve the County Code and County Name for a Case Idno. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_County_IDNO = NULL,
         @Ac_County_NAME = NULL;

  SELECT @An_County_IDNO = C.County_IDNO,
         @Ac_County_NAME = C1.County_NAME
    FROM CASE_Y1 C
         JOIN COPT_Y1 C1
          ON C.County_IDNO = C1.County_IDNO
   WHERE C.Case_IDNO = @An_Case_IDNO;
 END; --End Of Procedure CASE_RETRIEVE_S106

GO
