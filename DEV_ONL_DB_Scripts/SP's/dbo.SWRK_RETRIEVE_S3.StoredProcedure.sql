/****** Object:  StoredProcedure [dbo].[SWRK_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWRK_RETRIEVE_S3] (
 @Ac_Worker_ID          CHAR(30),
 @Ad_Schedule_DATE      DATE,
 @Ad_BeginSch_DTTM		DATETIME2,
 @Ad_EndSch_DTTM		DATETIME2,
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SWRK_RETRIEVE_S3
  *     DESCRIPTION       : Checks for the worker available for the day
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 	SET @Ai_Count_QNTY = NULL;
 	
 	DECLARE @Ld_High_DATE DATE = '12/31/9999'; 	
 	
 	SELECT @Ai_Count_QNTY = COUNT(Day_CODE)
 	FROM SWRK_Y1 s
 	WHERE s.Worker_ID = @Ac_Worker_ID
 	AND S.Day_CODE = DATEPART(DW,@Ad_Schedule_DATE)
 	AND @Ad_BeginSch_DTTM BETWEEN s.BeginWork_DTTM  AND s.EndWork_DTTM
 	AND @Ad_EndSch_DTTM BETWEEN s.BeginWork_DTTM  AND s.EndWork_DTTM
 	AND S.EndValidity_DATE = @Ld_High_DATE;
 END

GO
