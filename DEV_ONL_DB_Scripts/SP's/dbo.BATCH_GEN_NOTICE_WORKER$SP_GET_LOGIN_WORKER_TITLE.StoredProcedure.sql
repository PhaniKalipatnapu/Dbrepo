/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_TITLE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_TITLE
Programmer Name	:	IMP Team.
Description		:	This Procedure used to get Login worker title information
Frequency		:	
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_TITLE] (
 @Ac_Worker_ID             CHAR (30),
 @Ad_Run_DATE              DATE,
 @An_Case_IDNO             NUMERIC (6),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Lc_DagRole_ID         CHAR (5) = 'RA001',
          @Ls_Procedure_NAME     VARCHAR (100) = 'BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_TITLE',
          @Ld_Highdate_DATE      DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC (11),
          @Ln_ErrorLine_NUMB        NUMERIC (11),
          @Ls_Sql_TEXT              VARCHAR (200),
          @Ls_Sqldata_TEXT          VARCHAR (400),
          @Ls_DescriptionError_TEXT VARCHAR (4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT USEM_Y1,USES_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR(6)), '') + ', ROLE = ' + ISNULL (@Lc_DagRole_ID, '');

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CONVERT (VARCHAR (100), ESIGN_LOGIN_WORKER_TITLE) ESIGN_LOGIN_WORKER_TITLE
              FROM (SELECT CASE
                            WHEN COUNT(1) = 1
                             THEN 'Deputy Attorney General'
                            ELSE 'Child Support Specialist'
                           END ESIGN_LOGIN_WORKER_TITLE
                      FROM USEM_Y1 u
                           JOIN USES_Y1 c
                            ON u.Worker_ID = c.Worker_ID
                           JOIN USRL_Y1 r
                            ON r.Worker_ID = u.Worker_ID
                               AND r.EndValidity_DATE = @Ld_Highdate_DATE
                           JOIN CASE_Y1 CS
                            ON CS.County_IDNO = R.Office_IDNO
                     WHERE CS.Case_IDNO = @An_Case_IDNO
                       AND u.Worker_ID = @Ac_Worker_ID
                       AND @Ad_Run_DATE BETWEEN u.BeginEmployment_DATE AND u.EndEmployment_DATE
                       AND u.EndValidity_DATE = @Ld_Highdate_DATE
                       AND c.ESignature_BIN != ''
                       AND r.Role_ID = @Lc_DagRole_ID
                       AND @Ad_Run_DATE BETWEEN r.Effective_DATE AND r.Expire_DATE)a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (ESIGN_LOGIN_WORKER_TITLE)) AS pvt);

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
 END


GO
