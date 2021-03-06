/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_PETITIONER_REPONDENT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_PETITIONER_REPONDENT_DETAILS
Programmer Name	:	IMP Team.
Description		:	Gets petitioner and respondent details based on Typecase_Code from CASE_Y1 table.
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_PETITIONER_REPONDENT_DETAILS] (
 @An_Case_IDNO             NUMERIC(6),
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_TypeCaseF_CODE      CHAR(1) = 'F',
          @Lc_TypeCaseJ_CODE      CHAR(1) = 'J',
          @Lc_StatusCaseOpen_CODE CHAR(1) = 'O',
          @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_PETITIONER_REPONDENT_DETAILS';
  DECLARE @Lc_RespondentObligor_CODE    CHAR(1) = '',
          @Lc_RespondentObligee_CODE    CHAR(1) = '',
          @Lc_RespondentFosterCare_CODE CHAR(1) = '',
          @Lc_RespondentCaretaker_CODE  CHAR(1) = '',
          @Lc_PetitionerObligee_CODE    CHAR(1) = '',
          @Lc_PetitionerObligor_CODE    CHAR(1) = '',
          @Lc_PetitionerFosterCare_CODE CHAR(1) = '',
          @Lc_PetitionerCaretaker_CODE  CHAR(1) = '',
          @Ls_Sql_TEXT                  VARCHAR(200) = '',
          @Ls_SqlData_TEXT              VARCHAR(400),
          @Ls_DescriptionError_TEXT     VARCHAR(4000);

  BEGIN TRY
   SELECT @Lc_PetitionerFosterCare_CODE = CASE
                                           WHEN a.TypeCase_CODE IN (@Lc_TypeCaseF_CODE, @Lc_TypeCaseJ_CODE)
                                            THEN 'X'
                                           ELSE ''
                                          END
     FROM CASE_Y1 a
    WHERE Case_IDNO = @An_Case_IDNO
      AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE;

   IF @Lc_PetitionerFosterCare_CODE IS NULL
       OR @Lc_PetitionerFosterCare_CODE = ''
    BEGIN
     SET @Lc_PetitionerObligee_CODE ='X';
     SET @Lc_PetitionerObligor_CODE ='';
     SET @Lc_PetitionerFosterCare_CODE ='';
     SET @Lc_PetitionerCaretaker_CODE ='';
    END
   ELSE
    BEGIN
     SET @Lc_PetitionerObligee_CODE ='';
     SET @Lc_PetitionerObligor_CODE ='';
     SET @Lc_PetitionerFosterCare_CODE ='X';
     SET @Lc_PetitionerCaretaker_CODE ='';
    END

   IF @An_NcpMemberMci_IDNO IS NOT NULL
      AND @An_NcpMemberMci_IDNO != 0
    BEGIN
     SET @Lc_RespondentObligor_CODE ='X';
     SET @Lc_RespondentObligee_CODE ='';
     SET @Lc_RespondentFosterCare_CODE ='';
     SET @Lc_RespondentCaretaker_CODE ='';
    END
   ELSE
    BEGIN
     SET @Lc_RespondentObligor_CODE ='';
     SET @Lc_RespondentObligee_CODE ='';
     SET @Lc_RespondentFosterCare_CODE ='';
     SET @Lc_RespondentCaretaker_CODE ='';
    END
   SET @Ls_Sql_TEXT = 'SELECT #NoticeElementsData_P1';
   SET @Ls_SqlData_TEXT = 'Element_NAME = ' ;
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(100), RespondentObligor_CODE) RespondentObligor_CODE,
                   CONVERT(VARCHAR(100), RespondentObligee_CODE) RespondentObligee_CODE,
                   CONVERT(VARCHAR(100), RespondentFosterCare_CODE) RespondentFosterCare_CODE,
                   CONVERT(VARCHAR(100), RespondentCaretaker_CODE) RespondentCaretaker_CODE,
                   CONVERT(VARCHAR(100), PetitionerObligee_CODE) PetitionerObligee_CODE,
                   CONVERT(VARCHAR(100), PetitionerObligor_CODE) PetitionerObligor_CODE,
                   CONVERT(VARCHAR(100), PetitionerFosterCare_CODE) PetitionerFosterCare_CODE,
                   CONVERT(VARCHAR(100), PetitionerCaretaker_CODE) PetitionerCaretaker_CODE
              FROM (SELECT @Lc_RespondentObligor_CODE AS RespondentObligor_CODE,
                           @Lc_RespondentObligee_CODE AS RespondentObligee_CODE,
                           @Lc_RespondentFosterCare_CODE AS RespondentFosterCare_CODE,
                           @Lc_RespondentCaretaker_CODE AS RespondentCaretaker_CODE,
                           @Lc_PetitionerObligee_CODE AS PetitionerObligee_CODE,
                           @Lc_PetitionerObligor_CODE AS PetitionerObligor_CODE,
                           @Lc_PetitionerFosterCare_CODE AS PetitionerFosterCare_CODE,
                           @Lc_PetitionerCaretaker_CODE AS PetitionerCaretaker_CODE) h)up UNPIVOT (Element_Value FOR Element_NAME IN ( RespondentObligor_CODE, RespondentObligee_CODE, RespondentFosterCare_CODE, RespondentCaretaker_CODE, PetitionerObligee_CODE, PetitionerObligor_CODE, PetitionerFosterCare_CODE, PetitionerCaretaker_CODE)) AS pvt);
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
