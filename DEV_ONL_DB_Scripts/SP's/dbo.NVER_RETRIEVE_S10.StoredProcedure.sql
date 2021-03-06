/****** Object:  StoredProcedure [dbo].[NVER_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_RETRIEVE_S10] (
 @Ac_Notice_ID          CHAR(8),
 @An_NoticeVersion_NUMB NUMERIC(5, 0),
 @Ac_NoticeOut_ID       CHAR(8) OUTPUT,
 @As_XslTemplate_TEXT   VARCHAR(MAX) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve the Version of Notice and XSL boilerplate form for a given Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @As_XslTemplate_TEXT = NULL,
         @Ac_NoticeOut_ID = NULL;

  SELECT @Ac_NoticeOut_ID = N.Notice_ID,
         @As_XslTemplate_TEXT = N.XslTemplate_TEXT
    FROM NVER_Y1 N
   WHERE N.Notice_ID = @Ac_Notice_ID
     AND N.NoticeVersion_NUMB = @An_NoticeVersion_NUMB;
 END; -- END OF NVER_RETRIEVE_S10


GO
