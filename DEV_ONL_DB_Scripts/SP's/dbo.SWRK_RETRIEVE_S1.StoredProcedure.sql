/****** Object:  StoredProcedure [dbo].[SWRK_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SWRK_RETRIEVE_S1] (
 @Ac_Worker_ID      CHAR(30),
 @Ad_Schedule_DATE  DATE,
 @Ad_BeginWork_DTTM DATETIME2 OUTPUT,
 @Ad_EndWork_DTTM   DATETIME2 OUTPUT,
 @An_MaxLoad_QNTY   NUMERIC(3,0) OUTPUT
 )
AS
 /*                                                                                                                                                                                                                                           
  *     PROCEDURE NAME    : SWRK_RETRIEVE_S1                                                                                                                                                                                                   
  *     DESCRIPTION       : Retrieve the Start Time from which the Worker is available for the day and Time Up to which the worker is available for the day for a Worker Idno and Weekday on which the worker is available.                   
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                        
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                                                       
  *     MODIFIED BY       :                                                                                                                                                                                                                   
  *     MODIFIED ON       :                                                                                                                                                                                                                   
  *     VERSION NO        : 1                                                                                                                    
 */
 BEGIN
  SELECT @Ad_BeginWork_DTTM = NULL,
         @Ad_EndWork_DTTM = NULL;

  DECLARE @Ld_High_DATE         DATE    = '12/31/9999';

  SELECT @Ad_BeginWork_DTTM = S.BeginWork_DTTM,
         @Ad_EndWork_DTTM = S.EndWork_DTTM,
         @An_MaxLoad_QNTY = S.MaxLoad_QNTY
    FROM SWRK_Y1 S
   WHERE S.Worker_ID = @Ac_Worker_ID
     AND S.Day_CODE = DATEPART(DW,@Ad_Schedule_DATE)
     AND S.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF SWRK_RETRIEVE_S1                                                                                                                                                                                                                                          


GO
