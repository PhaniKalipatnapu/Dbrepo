/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S65] (
 @An_Forum_IDNO    NUMERIC(10),
 @An_DateDiff_NUMB NUMERIC(10) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : DMJR_RETRIEVE_S65
  *     DESCRIPTION       : Retrieve current date minus date on which the Remedy has been initiated for a Forum ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_DateDiff_NUMB = NULL;

  SELECT @An_DateDiff_NUMB = CAST(DATEDIFF(d, d.Entered_DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) AS NUMERIC(10))
    FROM DMJR_Y1 d
   WHERE d.Forum_IDNO = @An_Forum_IDNO;
 END; --End of DMJR_RETRIEVE_S65


GO
