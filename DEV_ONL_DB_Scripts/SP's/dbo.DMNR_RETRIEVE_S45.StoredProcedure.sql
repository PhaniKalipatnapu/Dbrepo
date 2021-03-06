/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S45] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @An_Topic_IDNO         NUMERIC(10, 0),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0) OUTPUT,
 @An_MinorIntSeq_NUMB   NUMERIC(5, 0) OUTPUT,
 @An_OrderSeq_NUMB      NUMERIC(2, 0) OUTPUT,
 @Ad_Due_DATE           DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S45
  *     DESCRIPTION       : Retrieve Minor Activity details for a given Case Topic .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT =0;

  SELECT @Ad_Due_DATE = NULL,
         @An_MajorIntSeq_NUMB = NULL,
         @An_MinorIntSeq_NUMB = NULL,
         @An_OrderSeq_NUMB = NULL;

  SELECT @An_MajorIntSeq_NUMB = D.MajorIntSeq_NUMB,
         @An_MinorIntSeq_NUMB = D.MinorIntSeq_NUMB,
         @Ad_Due_DATE = D.Due_DATE,
         @An_OrderSeq_NUMB = D.OrderSeq_NUMB
    FROM DMNR_Y1 D
   WHERE D.MinorIntSeq_NUMB != @Li_Zero_NUMB
     AND D.Topic_IDNO = @An_Topic_IDNO
     AND D.Case_IDNO = @An_Case_IDNO
     AND D.ActivityMinor_CODE = @Ac_ActivityMinor_CODE;
 END; --END OF  DMNR_RETRIEVE_S45

GO
