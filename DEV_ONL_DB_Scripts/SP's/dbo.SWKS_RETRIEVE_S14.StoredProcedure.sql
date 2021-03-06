/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S14] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_Schedule_NUMB      NUMERIC(10, 0),
 @Ac_ActivityMinor_CODE CHAR(5) OUTPUT
 )
AS
 /*                                                                                                                                           
  *     PROCEDURE NAME    : SWKS_RETRIEVE_S14                                                                                                  
  *     DESCRIPTION       : Retrieve Minor Activity for which the appointment has been Scheduled for a Case  and Schedule Sequence Number.
  *     DEVELOPED BY      : IMP Team                                                                                                      
  *     DEVELOPED ON      : 27-AUG-2011                                                                                                       
  *     MODIFIED BY       :                                                                                                                   
  *     MODIFIED ON       :                                                                                                                   
  *     VERSION NO        : 1                                                                                                                 
 */
 BEGIN
  SET @Ac_ActivityMinor_CODE = NULL;

  SELECT TOP 1 @Ac_ActivityMinor_CODE = S.ActivityMinor_CODE
    FROM SWKS_Y1 S
   WHERE S.Schedule_NUMB = @An_Schedule_NUMB
     AND S.Case_IDNO = @An_Case_IDNO;
 END; --END OF SWKS_RETRIEVE_S14                                                                                                                                         


GO
