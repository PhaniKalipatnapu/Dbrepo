/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_WARRANT_CAPIAS_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name      :BATCH_GEN_NOTICE_EST_ENF$SP_GET_WARRANT_CAPIAS_DTLS
 Programmer Name     : IMP Team
 Description         :This procedure is used to get warrant or capias details like Enforcement Status and and it's description.
 Frequency           :
 Developed On        :02-08-2011
 Called By           :BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On           :
---------------------------------------------------------
 Modified By         :
 Modified On         :
 Version No          : 1.0 
---------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_WARRANT_CAPIAS_DTLS](
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusCaseOpen_CODE    CHAR(1) = 'O',
          @Lc_CheckBoxValue_TEXT     CHAR(1) = 'X',
          @Lc_Empty_TEXT            CHAR(1) = ' ',
          @Lc_StatusEnforceYes_CODE CHAR(1) = ' ',
          @Lc_StatusEnforceNo_CODE  CHAR(1) = ' ',
          @Lc_TableCcrt_ID           CHAR(4) = 'CCRT',
          @Lc_TableSubEnst_ID        CHAR(4) = 'ENST',
          @Lc_StatusEnforceWcap_CODE CHAR(4) = 'WCAP',
          @Lc_StatusEnforce_CODE    CHAR(4) = ' ',
          @Ls_Sql_TEXT              VARCHAR(200) = 'SELECT CASE_Y1',
          @Ls_SqlData_TEXT          VARCHAR(400) = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR);
  DECLARE @Ls_StatusEnforce_Desc_TEXT    VARCHAR(70),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@An_Case_IDNO IS NOT NULL)
    BEGIN
     SELECT @Lc_StatusEnforce_CODE = c.StatusEnforce_CODE,
            @Ls_StatusEnforce_Desc_TEXT = dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_TableCcrt_ID, @Lc_TableSubEnst_ID, C.StatusEnforce_CODE)
       FROM CASE_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO
        AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;

     IF (@Lc_StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE)
      BEGIN
       SET @Lc_StatusEnforceYes_CODE = @Lc_CheckBoxValue_TEXT;
       SET @Ls_StatusEnforce_Desc_TEXT = @Ls_StatusEnforce_Desc_TEXT ;
      END
     ELSE
      BEGIN
       SET @Lc_StatusEnforceNo_CODE = @Lc_CheckBoxValue_TEXT;
       SET @Ls_StatusEnforce_Desc_TEXT= @Lc_Empty_TEXT;
      END
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT Element_NAME,
             Element_Value
        FROM (SELECT CONVERT(VARCHAR(100), @Lc_StatusEnforceYes_CODE) AS ncp_capias_status_enforce_yes_code,
                     CONVERT(VARCHAR(100), @Lc_StatusEnforceNo_CODE) AS ncp_capias_status_enforce_no_code,
                     CONVERT(VARCHAR(100), @Ls_StatusEnforce_Desc_TEXT) AS ncp_capias_status_text) up UNPIVOT (Element_Value FOR Element_NAME IN (ncp_capias_status_enforce_yes_code, ncp_capias_status_enforce_no_code, ncp_capias_status_text)) AS pvt);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
