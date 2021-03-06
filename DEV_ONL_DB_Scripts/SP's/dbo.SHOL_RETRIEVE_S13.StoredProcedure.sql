/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S13] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ad_Start_DATE        DATE,
 @Ad_End_DATE          DATE
 )
AS
 /*      
  *     PROCEDURE NAME    : SHOL_RETRIEVE_S13      
  *     DESCRIPTION       : Retrieves the Date for the given start date and end date with othp location id.
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 02-MAR-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  SELECT S.Holiday_DATE
    FROM SHOL_Y1 S
   WHERE S.Holiday_DATE BETWEEN @Ad_Start_DATE AND @Ad_End_DATE
     AND S.OthpLocation_IDNO = @An_OthpLocation_IDNO;
           
 END; --END OF SHOL_RETRIEVE_S13      



GO
