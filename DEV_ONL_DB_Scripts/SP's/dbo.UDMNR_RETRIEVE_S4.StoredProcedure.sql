/****** Object:  StoredProcedure [dbo].[UDMNR_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDMNR_RETRIEVE_S4] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @An_MajorIntSeq_NUMB NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB NUMERIC(5, 0) OUTPUT
 )
AS
 /*      
 *     PROCEDURE NAME    : UDMNR_RETRIEVE_S4      
  *     DESCRIPTION       : Retrieve the maximum of system generated number for every new Minor Activity within the same SEQ_MAJOR_INT for a Case ID and system generated major sequence number.      
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 24-AUG-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SET @An_MinorIntSeq_NUMB = NULL;

  SELECT @An_MinorIntSeq_NUMB = MAX(UD.MinorIntSeq_NUMB)
    FROM UDMNR_V1 UD
   WHERE UD.Case_IDNO = @An_Case_IDNO
     AND UD.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
 END; --End of UDMNR_RETRIEVE_S4     


GO
