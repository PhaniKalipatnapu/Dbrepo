/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S2](
 @An_Application_IDNO NUMERIC(15, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APMH_RETRIEVE_S2
  *     DESCRIPTION       : Checks whether the given PA type end date for the resord is greater than Current date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 29-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Ld_Low_DATE        DATE = '01/01/0001',
          @Ld_Systemdate_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APMH_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND EXISTS (SELECT A.End_DATE
                   FROM APMH_Y1 A
                  WHERE A.Application_IDNO = @An_Application_IDNO
                    AND A.End_DATE <> @Ld_Low_DATE
                    AND A.End_DATE < @Ld_Systemdate_DATE);
 END; -- End Of APMH_RETRIEVE_S2

GO
