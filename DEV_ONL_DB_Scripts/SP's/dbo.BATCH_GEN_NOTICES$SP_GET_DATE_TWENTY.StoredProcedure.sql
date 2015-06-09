/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DATE_TWENTY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_DATE_TWENTY
Programmer Name	:	IMP Team.
Description		:	This procedure returns twenty days after the run date
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DATE_TWENTY] (
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB         INT = NULL,
          @Li_ErrorLine_NUMB     INT = NULL,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_DATE_TWENTY';
  DECLARE @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Next_DATE             DATE;

  BEGIN TRY
   SET @Ld_Next_DATE = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT Run_Date 20';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(10)), '');
   SET @Ld_Next_DATE = DATEADD(D, 20, @Ad_Run_DATE);

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
        VALUES('TWENTY_DAYS_AFTER_RUN_DATE',
               CONVERT(VARCHAR(10), @Ld_Next_DATE, 101));

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
