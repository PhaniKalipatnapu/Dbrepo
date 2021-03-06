/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S62]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S62] (
 @An_Case_IDNO         NUMERIC(6, 0),
 @Ac_StatusCase_CODE   CHAR(1) OUTPUT,
 @Ac_TypeCase_CODE     CHAR(1) OUTPUT,
 @An_County_IDNO       NUMERIC(3, 0) OUTPUT,
 @Ac_RespondInit_CODE  CHAR(1) OUTPUT,
 @Ac_Restricted_INDC   CHAR(1) OUTPUT,
 @Ac_CaseCategory_CODE CHAR(2) OUTPUT,
 @Ai_Count_QNTY        INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S62
  *     DESCRIPTION       : Retrieving Case Status, Case Type, County Id, Respond Init Code, Restricted Case Indicator, 
 							Case Category, County Name and Special Alert Count for a give a Case Id
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_StatusCase_CODE = NULL,
         @Ac_TypeCase_CODE = NULL,
         @An_County_IDNO = NULL,
         @Ac_RespondInit_CODE = NULL,
         @Ac_Restricted_INDC = NULL,
         @Ac_CaseCategory_CODE = NULL,
         @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CategorySP_CODE CHAR(2) = 'SP',
          @Ld_High_DATE       DATE = '12/31/9999';

  SELECT @Ac_StatusCase_CODE = C.StatusCase_CODE,
         @Ac_TypeCase_CODE = C.TypeCase_CODE,
         @An_County_IDNO = C.County_IDNO,
         @Ac_RespondInit_CODE = C.RespondInit_CODE,
         @Ac_Restricted_INDC = C.Restricted_INDC,
         @Ac_CaseCategory_CODE = C.CaseCategory_CODE,
         @Ai_Count_QNTY = (SELECT COUNT(1)
                             FROM NOTE_Y1 N
                            WHERE N.Category_CODE = @Lc_CategorySP_CODE
                              AND N.EndValidity_DATE = @Ld_High_DATE
                              AND N.Case_IDNO = @An_Case_IDNO)
    FROM CASE_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO;
 END; --End of CASE_RETRIEVE_S62 

GO
