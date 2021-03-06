/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S5] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_Topic_IDNO               NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Category_CODE            CHAR(2) OUTPUT,
 @Ac_Subject_CODE             CHAR(5) OUTPUT,
 @Ad_Start_DATE               DATE OUTPUT,
 @An_EventGlobalSeq_NUMB      NUMERIC(19, 0) OUTPUT,
 @An_TotalReplies_QNTY        NUMERIC(10, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve the Notes details for  given a Case  Topic .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ad_Start_DATE = NULL,
         @An_TotalReplies_QNTY = NULL,
         @An_EventGlobalSeq_NUMB = NULL,
         @Ac_Category_CODE = NULL,
         @Ac_Subject_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ad_Start_DATE = n.Start_DATE,
         @An_TotalReplies_QNTY = n.TotalReplies_QNTY,
         @Ac_Subject_CODE = n.Subject_CODE,
         @An_EventGlobalSeq_NUMB = n.EventGlobalSeq_NUMB,
         @Ac_Category_CODE = n.Category_CODE
    FROM NOTE_Y1 N
         JOIN (SELECT MAX (a.Post_IDNO) AS Post_IDNO
                 FROM NOTE_Y1 A
                WHERE A.Case_IDNO = @An_Case_IDNO
                  AND A.Topic_IDNO = @An_Topic_IDNO
                  AND A.EndValidity_DATE = @Ld_High_DATE) b
          ON N.Post_IDNO = b.Post_IDNO
   WHERE N.Case_IDNO = @An_Case_IDNO
     AND N.Topic_IDNO = @An_Topic_IDNO
     AND N.EndValidity_DATE = @Ld_High_DATE
     AND N.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; -- END OF NOTE_RETRIEVE_S5


GO
