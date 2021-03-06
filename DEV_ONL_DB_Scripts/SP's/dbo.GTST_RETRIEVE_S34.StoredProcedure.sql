/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S34] (
 @An_Case_IDNO     NUMERIC(6, 0),
 @Ac_TypeTest_CODE CHAR(1),
 @Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : GTST_RETRIEVE_S34
  *     DESCRIPTION       : Retrieve the Row Count for a Case ID and the type of test where the result of the genetic test is scheduled, end date validity is high date, and the type of genetic test conducted is not equal to the given test type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_TestResultS_CODE CHAR(1) = 'S';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM GTST_Y1 g
   WHERE g.Case_IDNO = @An_Case_IDNO
     AND g.TestResult_CODE = @Lc_TestResultS_CODE
     AND g.EndValidity_DATE = @Ld_High_DATE
     AND g.TypeTest_CODE != @Ac_TypeTest_CODE;
 END; --END OF GTST_RETRIEVE_S34


GO
