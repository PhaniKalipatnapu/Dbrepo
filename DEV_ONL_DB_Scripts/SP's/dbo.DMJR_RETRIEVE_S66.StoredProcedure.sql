/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S66]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S66] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0),
 @Ad_Entered_DATE     DATE OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : DMJR_RETRIEVE_S66
  *     DESCRIPTION       : Retrieve the date on which the Remedy has been initiated for a Case ID and Sequence Number for the Remedy and Case / Order combination.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ad_Entered_DATE = NULL;

  SELECT @Ad_Entered_DATE = d.Entered_DATE
    FROM DMJR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
 END; --End of DMJR_RETRIEVE_S66


GO
