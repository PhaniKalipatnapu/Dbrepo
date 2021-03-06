/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CASE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_CASE_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Case Details CASE_Y1
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CASE_DETAILS](
 @An_Case_IDNO             NUMERIC (6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_Empty_TEXT		   CHAR(1) = '';
  DECLARE @Lc_StatusFailed_CODE    CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
          @Lc_CaseStatusOpen_CODE  CHAR(1) = 'O',
          @Lc_RespondInitN_CODE	   CHAR(1) = 'N',	
          @Lc_CheckBox_CODE		   CHAR(1) = 'X',
          @Ls_Procedure_NAME       VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CASE_DETAILS',
          @Ls_Sql_TEXT             VARCHAR (200) = 'SELECT OTHP',
          @Ls_Sqldata_TEXT         VARCHAR (400) = 'Case IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), @Lc_Empty_TEXT);
  DECLARE @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT pvt.Element_NAME,
          pvt.Element_VALUE
          -- ENF-17 Criminal Non Support field mapping Fix - Start
     FROM (SELECT (CASE
                    WHEN RespondInit_CODE <> @Lc_RespondInitN_CODE
                     THEN @Lc_CheckBox_CODE
                    ELSE @Lc_Empty_TEXT
                   END)opt_int_case_yes_indc,                   
                  (CASE
                    WHEN RespondInit_CODE = @Lc_RespondInitN_CODE 
                     THEN @Lc_CheckBox_CODE
                    ELSE @Lc_Empty_TEXT
                   END)opt_int_case_no_indc
          -- ENF-17 Criminal Non Support field mapping Fix - End
             FROM CASE_Y1 C
            WHERE C.Case_IDNO = @An_Case_IDNO
              AND C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE) z UNPIVOT (Element_VALUE FOR Element_NAME IN (opt_int_case_yes_indc, opt_int_case_no_indc)) AS pvt;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_Err_Description_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Err_Description_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
