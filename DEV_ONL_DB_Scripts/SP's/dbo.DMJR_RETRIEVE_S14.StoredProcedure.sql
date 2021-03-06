/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S14] (
 @An_Case_IDNO          NUMERIC(6),
 @An_MajorIntSeq_NUMB   NUMERIC(5),
 @Ac_TypeReference_CODE CHAR(5) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S14
  *     DESCRIPTION       : Retrieve the Type Reference Code for a Case Idno, Appointment Number associated with the Major Activity.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  
  SELECT @Ac_TypeReference_CODE = CAST(MAX(d.TypeReference_CODE) AS CHAR(5))
    FROM DMJR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
 END; -- End of DMJR_RETRIEVE_S14


GO
