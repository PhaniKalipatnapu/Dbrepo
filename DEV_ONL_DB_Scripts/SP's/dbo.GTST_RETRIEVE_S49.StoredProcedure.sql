/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S49]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S49] (
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_Schedule_NUMB NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : GTST_RETRIEVE_S49
  *     DESCRIPTION       : Retrieve the Record Count for a Genetic Test Number of a Case and Test Result .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE  @Lc_TestResultScheduled_CODE		CHAR(1)	= 'S',
		   @Ld_High_DATE					DATE	= '12/31/9999';

  SELECT g.Case_IDNO,
         g.MemberMci_IDNO,
         c.CaseRelationship_CODE,
         g.Schedule_NUMB,
         g.Test_DATE,
         g.Test_AMNT,
         g.OthpLocation_IDNO,
         g.PaidBy_NAME,
         g.Lab_NAME,
         g.LocationState_CODE,
         g.Location_NAME,
         g.CountyLocation_IDNO,
         g.TypeTest_CODE,
         g.ResultsReceived_DATE,
         g.Probability_PCT
    FROM GTST_Y1 g
	JOIN CMEM_Y1 c
	  ON c.Case_IDNO = g.Case_IDNO
	 AND c.MemberMci_IDNO = g.MemberMci_IDNO
   WHERE g.Case_IDNO = @An_Case_IDNO
     AND g.Schedule_NUMB = @An_Schedule_NUMB
     AND g.TestResult_CODE = @Lc_TestResultScheduled_CODE
     AND g.EndValidity_DATE = @Ld_High_DATE;
 END; --End of GTST_RETRIEVE_S49


GO
