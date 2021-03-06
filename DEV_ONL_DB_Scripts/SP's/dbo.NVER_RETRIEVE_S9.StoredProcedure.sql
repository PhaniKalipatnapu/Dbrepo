/****** Object:  StoredProcedure [dbo].[NVER_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NVER_RETRIEVE_S9] (
 @Ac_Notice_ID          CHAR(8),
 @Ac_NoticeOut_ID       CHAR(8) OUTPUT,
 @An_NoticeVersion_NUMB NUMERIC(5, 0) OUTPUT,
 @As_XslTemplate_TEXT   VARCHAR(MAX) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NVER_RETRIEVE_S9
  *     DESCRIPTION       : Retrieve the Version of Notice and XSL boilerplate form for Notice Idno with the Latest Notice Version number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT = 0;

  SELECT @Ac_NoticeOut_ID = NULL,
         @An_NoticeVersion_NUMB = NULL,
         @As_XslTemplate_TEXT = NULL;

  SELECT @Ac_NoticeOut_ID = N1.Notice_ID,
         @An_NoticeVersion_NUMB = N1.NoticeVersion_NUMB,
         @As_XslTemplate_TEXT = N1.XslTemplate_TEXT
    FROM NVER_Y1 N1
   WHERE N1.Notice_ID = @Ac_Notice_ID
     AND N1.NoticeVersion_NUMB != @Li_Zero_NUMB
     AND N1.NoticeVersion_NUMB = (SELECT MAX(N2.NoticeVersion_NUMB)
                                    FROM NVER_Y1 N2
                                   WHERE N2.Notice_ID = N1.Notice_ID
                                     AND N2.NoticeVersion_NUMB != @Li_Zero_NUMB);
 END; -- END OF NVER_RETRIEVE_S9

GO
