/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_ENF18_INITITATED_DT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
---------------------------------------------------------
 Procedure Name   :BATCH_GEN_NOTICES$SP_GET_ENF18_INITITATED_DT
 Programmer Name  : IMP Team
 Description      :The procedure BATCH_GEN_NOTICES$SP_GET_ENF18_INITITATED_DT is used to obtain the Enforcement 18 initiated date.
 Frequency        :
 Developed On     :01/20/2011
 Called By        :
 Called On        :
---------------------------------------------------------
 Modified By      :
 Modified On      :
 Version No       : 1.0 
---------------------------------------------------------
*/   
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_ENF18_INITITATED_DT] (
 @An_Case_IDNO             NUMERIC (6),
 @Ac_Notice_ID             CHAR (8),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE    CHAR (1) = 'S',
          @Lc_StatusFailed_CODE     CHAR (1) = 'F',
          @Ls_Procedure_NAME        VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_ENF18_INITITATED_DT';
          
  DECLARE @Ln_Error_NUMB          NUMERIC (11),
          @Ln_ErrorLine_NUMB      NUMERIC (11),
          @Ls_Sql_TEXT            VARCHAR (100),
          @Ls_Sqldata_TEXT        VARCHAR (400),
          @Ls_DescriptionError_TEXT VARCHAR (4000) = '',
          @Ld_enf18generated_DATE DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (6)), '');

   SELECT @Ld_enf18generated_DATE = MAX (n.Generate_DTTM)
     FROM NRRQ_Y1 n
    WHERE n.Notice_ID = 'ENF-18'
      AND n.Case_IDNO = @An_Case_IDNO;

   IF @Ld_enf18generated_DATE IS NULL
       OR @Ld_enf18generated_DATE = ''
    BEGIN
     SELECT @Ld_enf18generated_DATE = MAX (n.Request_DTTM)
       FROM NMRQ_Y1 n
      WHERE n.Notice_ID = 'ENF-18'
        AND n.Case_IDNO = @An_Case_IDNO;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT 'enf18_sent_date' AS Element_NAME,
          @Ld_enf18generated_DATE AS Element_VALUE;

   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
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
