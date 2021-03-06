/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S89]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S89] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB   NUMERIC(5, 0),
 @Ac_ActivityMinor_CODE CHAR(5) OUTPUT,
 @Ac_WorkerDelegate_ID  CHAR(30) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S89
  *     DESCRIPTION       : Retrieve Activity Minor Code and Worker ID to whom the Activity has been Delegated to for Updating the Status of the Activity for a Case ID, Major and Minor Sequence Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_ActivityMinor_CODE = NULL,
         @Ac_WorkerDelegate_ID = NULL;

  SELECT @Ac_ActivityMinor_CODE = d.ActivityMinor_CODE,
         @Ac_WorkerDelegate_ID = d.WorkerDelegate_ID
    FROM DMNR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND d.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB;
 END; --END OF DMNR_RETRIEVE_S89


GO
