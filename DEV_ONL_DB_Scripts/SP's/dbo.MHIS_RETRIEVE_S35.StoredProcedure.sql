/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S35] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S35
  *     DESCRIPTION       : Retrieves the Case Welfare ID for the respective case from MemberWelfareDetails.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_TypeWelfareFosterCare_CODE CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE   CHAR(1) = 'M',
          @Lc_TypeWelfareNonIve_CODE     CHAR(1) = 'F',
          @Lc_TypeWelfareTanf_CODE       CHAR(1) = 'A';

  SELECT DISTINCT M.CaseWelfare_IDNO
    FROM MHIS_Y1 M
   WHERE M.Case_IDNO = @An_Case_IDNO
     AND M.TypeWelfare_CODE IN (@Lc_TypeWelfareTanf_CODE, @Lc_TypeWelfareNonIve_CODE, @Lc_TypeWelfareFosterCare_CODE, @Lc_TypeWelfareMedicaid_CODE)
     AND LTRIM(RTRIM(M.CaseWelfare_IDNO))IS NOT NULL;
 END; --End Of MHIS_RETRIEVE_S35

GO
