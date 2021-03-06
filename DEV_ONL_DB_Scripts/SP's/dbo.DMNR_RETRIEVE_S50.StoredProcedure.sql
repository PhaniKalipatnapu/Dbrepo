/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S50]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S50] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_Topic_IDNO         NUMERIC(10, 0),
 @Ac_ActivityMinor_CODE CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S50
  *     DESCRIPTION       : Retrieve the Minor Acitivity details for a  given Case Topic and Minor Acitivity. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT D.Case_IDNO,
         D.OrderSeq_NUMB,
         D.MajorIntSeq_NUMB,
         D.MemberMci_IDNO,
         D.Schedule_NUMB,
         D.Forum_IDNO,
         D.Topic_IDNO,
         D.TotalReplies_QNTY,
         D.TotalViews_QNTY,
         D.PostLastPoster_IDNO,
         D.UserLastPoster_ID,
         D.LastPost_DTTM,
         D.ActivityMajor_CODE,
         D.Subsystem_CODE
    FROM DMNR_Y1 D
   WHERE D.Case_IDNO = @An_Case_IDNO
     AND D.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND D.Topic_IDNO = @An_Topic_IDNO;
 END; -- End of DMNR_RETRIEVE_S50


GO
