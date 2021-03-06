/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S75]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S75] (
 @An_Case_IDNO                NUMERIC(6),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @Ac_ActivityMinor_CODE       CHAR(5) OUTPUT,
 @An_Topic_IDNO               NUMERIC(10) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S75
  *     DESCRIPTION       : Retrieve Minor Activity Code and Topic ID for a Case ID, Major & Minor Sequence and Unique Sequence Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_ActivityMinor_CODE = NULL,
         @An_Topic_IDNO = NULL;

  SELECT @Ac_ActivityMinor_CODE = d.ActivityMinor_CODE,
         @An_Topic_IDNO = d.Topic_IDNO,
         @An_TransactionEventSeq_NUMB = d.TransactionEventSeq_NUMB
    FROM DMNR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND d.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB;
 END; --END OF DMNR_RETRIEVE_S75


GO
