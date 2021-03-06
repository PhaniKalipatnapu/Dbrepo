/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CASE_WORKER_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_CASE_WORKER_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/10/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CASE_WORKER_DTLS](
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_CasePrefix_TEXT    CHAR(4) = 'CASE';
  DECLARE @Lc_Worker_ID            CHAR(30),
          @Ls_Sql_TEXT             VARCHAR(100),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = ' ';
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_CASE_WORKER_DTLS';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + +ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   IF @An_Case_IDNO IS NOT NULL
      AND @An_Case_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT USEM_Y1';
     SET @Lc_Worker_ID = dbo.BATCH_COMMON_GETS$SF_GET_CASEWORKER(@An_Case_IDNO, @Ad_Run_DATE, NULL);
    END

   IF @Lc_Worker_ID IS NOT NULL
      AND @Lc_Worker_ID <> ' '
    BEGIN
     EXECUTE BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS
      @Ac_Worker_ID             = @Lc_Worker_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Lc_CasePrefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
