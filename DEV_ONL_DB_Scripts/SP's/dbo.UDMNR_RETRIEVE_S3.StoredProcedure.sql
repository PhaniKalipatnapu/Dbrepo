/****** Object:  StoredProcedure [dbo].[UDMNR_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDMNR_RETRIEVE_S3] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB NUMERIC(5, 0) OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : UDMNR_RETRIEVE_S3      
  *     DESCRIPTION       : Retrieve the maximum of the Minor Sequence for a given Case and Major Sequence. 
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 17-AUG-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SET @An_MinorIntSeq_NUMB = NULL;

  DECLARE @Li_One_NUMB SMALLINT = 1;

  SELECT @An_MinorIntSeq_NUMB = MAX (U.MinorIntSeq_NUMB) + @Li_One_NUMB
    FROM UDMNR_V1 U
   WHERE U.Case_IDNO = @An_Case_IDNO
     AND U.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
 END; -- End of UDMNR_RETRIEVE_S3  

GO
