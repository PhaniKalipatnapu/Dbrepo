/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S25] (
 @An_Petition_IDNO NUMERIC(7, 0),
 @An_Case_IDNO     NUMERIC(6, 0) OUTPUT,
 @Ac_File_ID       CHAR(10) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FDEM_RETRIEVE_S25
  *     DESCRIPTION       : Retrieve the Petition idno for the given file id and case id.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-oct-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Case_IDNO = F.Case_IDNO,
         @Ac_File_ID = F.File_ID
    FROM FDEM_Y1 F
   WHERE F.Petition_IDNO = @An_Petition_IDNO
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FDEM_RETRIEVE_S25


GO
