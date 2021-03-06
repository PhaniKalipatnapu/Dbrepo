/****** Object:  StoredProcedure [dbo].[UDMNR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UDMNR_RETRIEVE_S1] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_Topic_IDNO         NUMERIC(10, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : UDMNR_RETRIEVE_S1      
  *     DESCRIPTION       : Retrieve the Row Count for a Case , Topic Number, and Minor Activity. 
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 16-AUG-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM UDMNR_V1 U
   WHERE U.Case_IDNO = @An_Case_IDNO
     AND U.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND U.Topic_IDNO = @An_Topic_IDNO;
 END; -- End of UDMNR_RETRIEVE_S1    

GO
