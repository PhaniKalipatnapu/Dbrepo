/****** Object:  StoredProcedure [dbo].[ACEN_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_RETRIEVE_S7] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_StatusEnforce_CODE CHAR(1),
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ACEN_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve the Row Count for a Case Id with an Exempt Enforcement Status.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ACEN_Y1 a
   WHERE a.EndValidity_DATE = @Ld_High_DATE
     AND a.Case_IDNO = @An_Case_IDNO
     AND a.StatusEnforce_CODE = @Ac_StatusEnforce_CODE;
 END; --End of ACEN_RETRIEVE_S7


GO
