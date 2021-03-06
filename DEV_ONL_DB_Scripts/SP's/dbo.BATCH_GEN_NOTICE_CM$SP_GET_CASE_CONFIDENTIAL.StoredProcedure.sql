/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CASE_CONFIDENTIAL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_CASE_CONFIDENTIAL
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CASE_CONFIDENTIAL] (
 @An_Case_IDNO             NUMERIC (6),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusCaseMemberActive_CODE CHAR (1) = 'A',
          @Lc_Yes_TEXT                    CHAR (1) = 'Y',
          @Lc_StatusSuccess_CODE          CHAR (1) = 'S',
          @Lc_StatusFailed_CODE           CHAR (1) = 'F',
          @Lc_CheckBoxX1_TEXT             CHAR (1) = 'X',
          @Ls_Procedure_NAME              VARCHAR (100) = 'BATCH_GEN_NOTICE_CM$SP_GET_CASE_CONFIDENTIAL';          
 DECLARE  @Lc_Restricted_INDC             CHAR (1) = '',
          @Ls_Sql_TEXT                    VARCHAR (200) = '',
          @Ls_Sqldata_TEXT                VARCHAR (400) = '',
          @Ls_DescriptionError_TEXT       VARCHAR (4000) = '';

  BEGIN TRY
   SET @Lc_Restricted_INDC = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' SELECT DEMO_Y1 ';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR);
   SET @Lc_Restricted_INDC = '';

   IF EXISTS (SELECT 1
                FROM DEMO_Y1 D
                     JOIN CMEM_Y1 CM
                      ON CM.MemberMci_IDNO = D.MemberMci_IDNO
               WHERE CM.Case_IDNO = @An_Case_IDNO
                 AND CM.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                 AND D.Restricted_INDC = @Lc_Yes_TEXT)
    BEGIN
     SET @Lc_Restricted_INDC = @Lc_CheckBoxX1_TEXT;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
        VALUES ('CASE_CONFIDENTIAL_INDC',
                @Lc_Restricted_INDC);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Li_Error_NUMB = ERROR_NUMBER (),
          @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF ERROR_NUMBER () <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
