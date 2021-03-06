/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_DEPUTY_DIRECTORY_ESGIN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_WORKER$SP_GET_DEPUTY_DIRECTORY_ESGIN
Programmer Name	:	IMP Team.
Description		:	This Procedure used to get Deputy Director E-Signature and Name
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_DEPUTY_DIRECTORY_ESGIN] (
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_Empty_TEXT            CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_commaSpace_TEXT       CHAR(2) = ', ',
          @Lc_Role_IDNO          CHAR(5) = 'RS022',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICE_WORKER$SP_GET_DEPUTY_DIRECTORY_ESGIN',
          @Ld_Highdate_DATE      DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' SELECT USEM_Y1 USRL_Y1 USES_Y1';
   SET @Ls_Sqldata_TEXT = 'ROLE_ID = ' + @Lc_Role_IDNO;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CAST(x.DEP_DIR_ESIGN AS VARCHAR(100)) esign_ivd_dep_dir_text,
                   CAST(x.DEP_DIR_NAME AS VARCHAR(100)) dep_dir_name
              FROM (SELECT ISNULL(c.TransactionEventSeq_NUMB, 0) AS DEP_DIR_ESIGN,
                           dbo.BATCH_COMMON$SF_GET_TITLECASE((RTRIM(a.First_NAME) + @Lc_Space_TEXT + RTRIM(ISNULL(a.Middle_NAME, @Lc_Empty_TEXT)) + @Lc_Space_TEXT + RTRIM(a.Last_NAME) + CASE
                                                                                                                                                                                           WHEN RTRIM(ISNULL(a.Suffix_NAME, @Lc_Empty_TEXT)) != @Lc_Empty_TEXT
                                                                                                                                                                                            THEN @Lc_commaSpace_TEXT + RTRIM(ISNULL(a.Suffix_NAME, @Lc_Empty_TEXT))
                                                                                                                                                                                           ELSE @Lc_Empty_TEXT
                                                                                                                                                                                          END)) AS DEP_DIR_NAME
                      FROM USEM_Y1 a
                           LEFT OUTER JOIN USRL_Y1 b
                            ON a.Worker_ID = b.Worker_ID
                           LEFT OUTER JOIN USES_Y1 c
                            ON c.Worker_ID = b.Worker_ID
                     WHERE b.Role_ID = @Lc_Role_IDNO
                       AND @Ad_Run_DATE BETWEEN a.BeginEmployment_DATE AND a.EndEmployment_DATE
                       AND @Ad_Run_DATE BETWEEN b.Effective_DATE AND b.Expire_DATE
                       AND b.EndValidity_DATE = @Ld_Highdate_DATE
                       AND a.EndValidity_DATE = @Ld_Highdate_DATE
                       AND LTRIM(RTRIM(c.ESignature_BIN)) IS NOT NULL)x) up UNPIVOT (Element_VALUE FOR Element_NAME IN (esign_ivd_dep_dir_text, dep_dir_name)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT =SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
