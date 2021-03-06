/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S8] (
 @An_CaseWelfare_IDNO             NUMERIC(10),
 @An_WelfareYearMonth_NUMB        NUMERIC(6),
 @Ac_WelfareElig_CODE             CHAR(1),
 @An_CurrentWelfareYearMonth_NUMB NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S8
  *     DESCRIPTION       : Retrieves the most recent Welfare date associated with the given Welfare case, Welfare eligibility, and Welfare month/year.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_CurrentWelfareYearMonth_NUMB = NULL;

  SELECT @An_CurrentWelfareYearMonth_NUMB = ISNULL(MAX(A.WelfareYearMonth_NUMB), @An_WelfareYearMonth_NUMB)
    FROM IVMG_Y1 A
   WHERE A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND A.WelfareElig_CODE = @Ac_WelfareElig_CODE
     AND A.WelfareYearMonth_NUMB >= @An_WelfareYearMonth_NUMB;
 END; -- End of IVMG_RETRIEVE_S8


GO
