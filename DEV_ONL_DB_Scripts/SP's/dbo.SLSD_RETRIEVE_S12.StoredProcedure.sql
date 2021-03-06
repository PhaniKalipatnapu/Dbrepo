/****** Object:  StoredProcedure [dbo].[SLSD_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SLSD_RETRIEVE_S12] (
 @An_OthpLocation_IDNO  NUMERIC(9, 0),
 @Ac_TypeActivity_CODE  CHAR(1),
 @Ac_Day_CODE			CHAR(1),
 @Ad_BeginWork_DTTM     DATETIME2     OUTPUT,
 @Ad_EndWork_DTTM       DATETIME2     OUTPUT,
 @An_MaxLoad_QNTY       NUMERIC(3, 0) OUTPUT
 )
AS
 /*                                                                                                                                                                                                                                          
  *     PROCEDURE NAME    : SLSD_RETRIEVE_S12                                                                                                                                                                                                 
  *     DESCRIPTION       : Retrieve the Start Time from which the Worker is available for the day and Time Up to which the worker is available for the day for a Location Idno, Weekday on which the worker is available, and Activity Type.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                      
  *     DEVELOPED ON      : 05-SEP-2011                                                                                                                                                                                                      
  *     MODIFIED BY       :                                                                                                                                                                                                                  
  *     MODIFIED ON       :                                                                                                                                                                                                                  
  *     VERSION NO        : 1                                                                                                                                                                                                                
 */
 BEGIN
  SELECT @Ad_BeginWork_DTTM = NULL,
         @Ad_EndWork_DTTM = NULL,
         @An_MaxLoad_QNTY = NULL;

  DECLARE @Ld_High_DATE        DATE = '12/31/9999';

  SELECT @Ad_BeginWork_DTTM = S.BeginWork_DTTM,
         @Ad_EndWork_DTTM = S.EndWork_DTTM,
         @An_MaxLoad_QNTY = S.MaxLoad_QNTY
    FROM SLSD_Y1 S
   WHERE S.OthpLocation_IDNO = @An_OthpLocation_IDNO
     AND S.Day_CODE = @Ac_Day_CODE
     AND S.TypeActivity_CODE = @Ac_TypeActivity_CODE
     AND S.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF SLSD_RETRIEVE_S12                                                                                                                                                                                                                                        


GO
