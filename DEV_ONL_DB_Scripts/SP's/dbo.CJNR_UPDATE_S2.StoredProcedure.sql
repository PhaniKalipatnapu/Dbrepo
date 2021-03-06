/****** Object:  StoredProcedure [dbo].[CJNR_UPDATE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CJNR_UPDATE_S2] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @An_Topic_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CJNR_UPDATE_S2
  *     DESCRIPTION       : Update Post ID of the Last Post, User who posted the Last Post and Last post date-time for a Case ID, Topic ID for the Forum and system generated number for major & minor sequence.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Li_One_NUMB SMALLINT = 1;
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE CJNR_Y1
     SET TotalViews_QNTY = TotalViews_QNTY + @Li_One_NUMB
   WHERE Case_IDNO = @An_Case_IDNO
     AND Topic_IDNO = @An_Topic_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END --End of CJNR_UPDATE_S2

GO
