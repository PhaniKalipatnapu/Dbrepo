/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_SELECT_CASE_TYPE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICES$SP_SELECT_CASE_TYPE
Programmer Name		: IMP Team
Description 	    : This procedure is used to get the case type Details.
Frequency			:
Developed On		: 01/20/2011
Called By			: BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On	        : 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_SELECT_CASE_TYPE]
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_CaseStatusOpen_CODE CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE  CHAR(1)= 'S',
          @Lc_StatusFailed_CODE   CHAR(1)= 'F',
          @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_SELECT_CASE_TYPE';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 ';
   SET @Ls_Sqldata_TEXT = '  Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');
   
   IF (@An_Case_IDNO IS NOT NULL
       AND @An_Case_IDNO <> 0)
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(100), CURR_IVD_TANF_INDC) CURR_IVD_TANF_CODE,
                     CONVERT(VARCHAR(100), CURR_FOSTERCARE_INDC) CURR_FOSTERCARE_CODE,
                     CONVERT(VARCHAR(100), CURR_IVD_NPA_INDC) CURR_IVD_NPA_CODE,
                     CONVERT(VARCHAR(100), CURR_MEDICAID_ONLY_INDC) CURR_MEDICAID_ONLY_CODE,
                     CONVERT(VARCHAR(100), CURR_NON_IVD_INDC) CURR_NON_IVD_CODE,
                     CONVERT(VARCHAR(100), NEVER_ASSISTANCE_INDC) NEVER_ASSISTANCE_CODE,
                     CONVERT(VARCHAR(100), FORMER_ASSISTANCE_INDC) FORMER_ASSISTANCE_CODE,
                     CONVERT(VARCHAR(100), CURR_IVD_INDC) CURR_IVD_INDC
                FROM (SELECT CASE
                              WHEN TypeCase_CODE = 'A'
                               THEN 'X'
                              ELSE ''
                             END CURR_IVD_TANF_INDC,
                             CASE
                              WHEN TypeCase_CODE = 'N'
                               THEN 'X'
                              ELSE ''
                             END CURR_IVD_NPA_INDC,
                             CASE
                              WHEN TypeCase_CODE IN ('F', 'J')
                               THEN 'X'
                              ELSE ''
                             END CURR_FOSTERCARE_INDC,
                             CASE
                              WHEN TypeCase_CODE = 'H'
                               THEN 'X'
                              ELSE ''
                             END CURR_NON_IVD_INDC,
                             CASE
                              WHEN TypeCase_CODE = 'N'
                                   AND CaseCategory_CODE = 'MO'
                               THEN 'X'
                              ELSE ''
                             END CURR_MEDICAID_ONLY_INDC,
                             CASE
                              WHEN TypeCase_CODE = 'N'
                                   AND NOT EXISTS (SELECT 1
                                                     FROM MHIS_Y1 a
                                                    WHERE a.Case_IDNO = c.Case_IDNO
                                                      AND a.TypeWelfare_CODE IN ('A', 'F', 'J'))
                               THEN 'X'
                              ELSE ''
                             END NEVER_ASSISTANCE_INDC,
                             CASE
                              WHEN TypeCase_CODE = 'N'
                                   AND EXISTS (SELECT 1
                                                 FROM MHIS_Y1 m
                                                WHERE m.Case_IDNO = c.Case_IDNO
                                                  AND m.TypeWelfare_CODE IN ('A', 'F', 'J'))
                               THEN 'X'
                              ELSE ''
                             END FORMER_ASSISTANCE_INDC,
                             CASE
                              WHEN TypeCase_CODE <> 'H'
                               THEN 'X'
                              ELSE ''
                             END CURR_IVD_INDC
                        FROM CASE_Y1 c
                       WHERE c.Case_IDNO = @An_Case_IDNO
                         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE) a)up UNPIVOT (tag_value FOR tag_name IN ( CURR_IVD_TANF_CODE, CURR_FOSTERCARE_CODE, CURR_IVD_NPA_CODE, CURR_MEDICAID_ONLY_CODE, CURR_NON_IVD_CODE, NEVER_ASSISTANCE_CODE, FORMER_ASSISTANCE_CODE,CURR_IVD_INDC )) AS pvt);
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
