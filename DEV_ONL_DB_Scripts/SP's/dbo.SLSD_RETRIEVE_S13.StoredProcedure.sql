/****** Object:  StoredProcedure [dbo].[SLSD_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_RETRIEVE_S13] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_TypeActivity_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : SLSD_RETRIEVE_S13
  *     DESCRIPTION       : Retrieve column value, Holiday Indicator, Start Time from which the location is available for the day, and Time up to which the location is available for the day for a Day Code, Location Idno, and Activity Type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Day_CODE,
         BeginWork_DTTM,
         EndWork_DTTM
    FROM SLSD_Y1 S
   WHERE S.OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND S.TypeActivity_CODE = @Ac_TypeActivity_CODE
     AND S.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF SLSD_RETRIEVE_S13



GO
