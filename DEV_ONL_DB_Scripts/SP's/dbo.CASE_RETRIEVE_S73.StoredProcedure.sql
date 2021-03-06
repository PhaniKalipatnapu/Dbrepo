/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S73]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S73] (
 @An_Case_IDNO  NUMERIC(6, 0),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : CASE_RETRIEVE_S73
  *     DESCRIPTION       : Retrieve the Row Count for a Case Idno, Case Type, and Case Category.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_TypeCaseFosterCare_CODE   CHAR(1) = 'F',
          @Lc_TypeCaseNonPa_CODE        CHAR(1) = 'N',
          @Lc_TypeCasePaTanf_CODE       CHAR(1) = 'A',
          @Lc_CaseCategoryMedicaid_CODE CHAR(2) = 'MO',
          @Lc_TypeCaseMedicaid_CODE     CHAR(1) = 'M',
          @Lc_TypeCaseNonFederalFosterCare_CODE     CHAR(1) = 'J',
          @Lc_TypeCaseNonIVD_CODE     CHAR(1) = 'H';
        

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CASE_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND (c.TypeCase_CODE IN (@Lc_TypeCasePaTanf_CODE, @Lc_TypeCaseFosterCare_CODE,
                              @Lc_TypeCaseMedicaid_CODE, @Lc_TypeCaseNonFederalFosterCare_CODE,@Lc_TypeCaseNonIVD_CODE)
           OR (c.TypeCase_CODE = @Lc_TypeCaseNonPa_CODE
               AND c.CaseCategory_CODE = @Lc_CaseCategoryMedicaid_CODE));
 END; -- END OF CASE_RETRIEVE_S73

GO
