/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S23] (
 @An_Schedule_NUMB NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : GTST_RETRIEVE_S23
  *     DESCRIPTION       : Retrieve Genetic Testing details for a Schedule Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 g.Case_IDNO,
               g.Schedule_NUMB,
               g.Test_DATE,
               g.OthpLocation_IDNO,
               g.Lab_NAME,
               g.LocationState_CODE,
               g.Location_NAME,
               g.CountyLocation_IDNO,
               g.TypeTest_CODE
    FROM GTST_Y1 g
   WHERE g.Schedule_NUMB = @An_Schedule_NUMB
     AND g.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of GTST_RETRIEVE_S23


GO
