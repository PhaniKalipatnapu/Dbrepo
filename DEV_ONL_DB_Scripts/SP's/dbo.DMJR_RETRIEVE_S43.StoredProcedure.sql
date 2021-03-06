/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S43] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME     : DMJR_RETRIEVE_S43
  *     DESCRIPTION       : Retrieve the new sequence number for the Major Activity for the a Case ID
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_MajorIntSEQ_NUMB = NULL;

  SELECT @An_MajorIntSeq_NUMB = MAX(d.MajorIntSeq_NUMB)
    FROM DMJR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO;
 END; --End of DMJR_RETRIEVE_S43

GO
