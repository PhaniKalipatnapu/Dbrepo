/****** Object:  StoredProcedure [dbo].[SWRK_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWRK_RETRIEVE_S2] (
 @Ac_Worker_ID CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : SWRK_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve column value, Holiday Indicator, Start Time from which the location is available for the day, and Time up to which the location is available for the day for a Day Code and Worker Idno. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Day_Code,
         BeginWork_DTTM,
         EndWork_DTTM
    FROM SWRK_Y1 S
   WHERE S.Worker_ID = @Ac_Worker_ID
     AND S.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF SWRK_RETRIEVE_S2


GO
