/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S38]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S38] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S38
  *     DESCRIPTION       : Retrieve Minor Activity Diary details for a Case Idno, Minor Activity.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_RemedyStatusStart_CODE  CHAR(4) = 'STRT',
          @Lc_ActivityMinorMsc02_CODE CHAR(5) = 'MSC02',
          @Lc_ActivityMinorMsc03_CODE CHAR(5) = 'MSC03',
          @Lc_ActivityMinorMsc12_CODE CHAR(5) = 'MSC12',
          @Lc_ActivityMinorMsc13_CODE CHAR(5) = 'MSC13',
          @Lc_ActivityMinorMsc14_CODE CHAR(5) = 'MSC14',
          @Lc_ActivityMinorMsc4a_CODE CHAR(5) = 'MSC4A',
          @Lc_ActivityMinorMsc4b_CODE CHAR(5) = 'MSC4B',
          @Lc_SubsystemIn_CODE        CHAR(2) = 'IN';

  SELECT DISTINCT d.ActivityMinor_CODE
    FROM DMNR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.ActivityMinor_CODE IN (@Lc_ActivityMinorMsc02_CODE,@Lc_ActivityMinorMsc03_CODE,@Lc_ActivityMinorMsc4a_CODE,@Lc_ActivityMinorMsc4b_CODE,@Lc_ActivityMinorMsc12_CODE,@Lc_ActivityMinorMsc13_CODE,@Lc_ActivityMinorMsc14_CODE)
     AND d.Subsystem_CODE = @Lc_SubsystemIn_CODE
     AND d.Status_CODE = @Lc_RemedyStatusStart_CODE;
 END; -- END OF DMNR_RETRIEVE_S38

GO
