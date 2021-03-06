/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_BATE_LOG]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_BATE_LOG
Programmer Name		: IMP Team
Description			: This procedure is used to insert the unprocessed record error codes into BATE_Y1 table.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_BATE_LOG]
 @As_Process_NAME             VARCHAR(100),
 @As_Procedure_NAME           VARCHAR(100),
 @Ac_Job_ID                   CHAR(7),
 @Ad_Run_DATE                 DATE,
 @Ac_TypeError_CODE           CHAR(1),
 @An_Line_NUMB                NUMERIC(10),
 @Ac_Error_CODE               CHAR(18),
 @As_DescriptionError_TEXT    VARCHAR(4000),
 @As_ListKey_TEXT             VARCHAR(1000),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionErrorOut_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  SET @As_DescriptionError_TEXT = ISNULL(@As_DescriptionError_TEXT, ' ');

  SET @As_DescriptionError_TEXT = REPLACE(@As_DescriptionError_TEXT, CHAR(0), ' ');
  SET @As_ListKey_TEXT = REPLACE(@As_ListKey_TEXT, CHAR(0), ' ');

  DECLARE @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_TypeErrorE_CODE    CHAR(1) = 'E',
          @Ls_Routine_TEXT       VARCHAR(100) = 'BATCH_COMMON$SP_BATE_LOG';
  DECLARE @Ln_Error_NUMB        NUMERIC,
          @Ln_RowCount_QNTY     NUMERIC,
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Ls_Sql_TEXT          VARCHAR(50),
          @Ls_Sqldata_TEXT      VARCHAR(200),
          @Ls_ErrorMessage_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_TypeError_CODE = dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Ac_Error_CODE);

   IF @Ac_Error_CODE = 'E0944'
    BEGIN
     SET @As_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';
    END

   SET @Ls_Sql_TEXT = 'INSERT BATE_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@As_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@As_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveRun_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Create_DTTM = ' + ISNULL(CAST(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Ac_TypeError_CODE, @Lc_Space_TEXT) + ', Line_NUMB = ' + ISNULL(CAST(@An_Line_NUMB AS VARCHAR), '0') + ', Error_CODE = ' + ISNULL(@Ac_Error_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@As_DescriptionError_TEXT, '') + ', ListKey_TEXT ' + ISNULL(@As_ListKey_TEXT, @Lc_Space_TEXT);

   INSERT BATE_Y1
          (Process_NAME,
           Procedure_NAME,
           Job_ID,
           EffectiveRun_DATE,
           Create_DTTM,
           TypeError_CODE,
           Line_NUMB,
           Error_CODE,
           DescriptionError_TEXT,
           ListKey_TEXT)
   VALUES ( @As_Process_NAME,-- Process_NAME
            @As_Procedure_NAME,-- Procedure_NAME
            @Ac_Job_ID,-- Job_ID
            @Ad_Run_DATE,-- EffectiveRun_DATE
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),-- Create_DTTM
            ISNULL(@Ac_TypeError_CODE, @Lc_Space_TEXT),-- TypeError_CODE
            ISNULL(@An_Line_NUMB, 0),-- Line_NUMB
            @Ac_Error_CODE,-- Error_CODE
            @As_DescriptionError_TEXT,-- DescriptionError_TEXT
            ISNULL(@As_ListKey_TEXT, @Lc_Space_TEXT)); -- ListKey_TEXT
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT BATE_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   IF @Ac_TypeError_CODE = @Lc_TypeErrorE_CODE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_TypeErrorE_CODE;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END

   SET @As_DescriptionErrorOut_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    SET @Ln_Error_NUMB = ERROR_NUMBER();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE();

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Routine_TEXT,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionErrorOut_TEXT OUTPUT;
   END
  END CATCH
 END


GO
