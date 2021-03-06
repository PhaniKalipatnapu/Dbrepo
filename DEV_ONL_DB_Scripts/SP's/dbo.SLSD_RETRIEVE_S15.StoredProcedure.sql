/****** Object:  StoredProcedure [dbo].[SLSD_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_RETRIEVE_S15] (
 @An_OthpLocation_IDNO NUMERIC(9, 0),
 @Ac_Day_CODE          CHAR(1),
 @Ac_TypeActivity_CODE CHAR(1),
 @Ad_BeginSch_DTTM     DATETIME2,
 @Ad_EndSch_DTTM       DATETIME2,
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SLSD_RETRIEVE_S15
  *     DESCRIPTION       : Retrieve the Row Count for a Day and Location Number, Activity Type and where the given Start Time of an Appointment is between Start Time from which the location is available for the day and Time up to which the location is available for the day.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 25-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM SLSD_Y1 S
   WHERE S.Day_CODE = @Ac_Day_CODE
     AND S.OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND S.TypeActivity_CODE = @Ac_TypeActivity_CODE
     AND @Ad_BeginSch_DTTM BETWEEN S.BeginWork_DTTM AND S.EndWork_DTTM
     AND @Ad_EndSch_DTTM BETWEEN S.BeginWork_DTTM AND S.EndWork_DTTM
     AND S.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF  SLSD_RETRIEVE_S15



GO
