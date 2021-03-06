/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S55]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S55] (
 @An_CaseWelfare_IDNO NUMERIC(10),
 @Ad_Last_DATE        DATETIME2(0),
 @Ai_Count_QNTY		  INT OUTPUT
 )
AS
 /*
   *     PROCEDURE NAME    : MHIS_RETRIEVE_S54
   *     DESCRIPTION       : Check if record exists for the given welfare id and date.
   *     DEVELOPED BY      : IMP TEAM
   *     DEVELOPED ON      : 02-AUG-2011
   *     MODIFIED BY       : 
   *     MODIFIED ON       : 
   *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_WelfareTypeTanf_TEXT CHAR(1) = 'A';

  SELECT TOP 1 @Ai_Count_QNTY = COUNT(1)
    FROM MHIS_Y1 M
   WHERE M.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND M.TypeWelfare_CODE = @Lc_WelfareTypeTanf_TEXT
     AND @Ad_Last_DATE BETWEEN M.Start_DATE AND M.End_DATE;
 END; -- End of MHIS_RETRIEVE_S55


GO
