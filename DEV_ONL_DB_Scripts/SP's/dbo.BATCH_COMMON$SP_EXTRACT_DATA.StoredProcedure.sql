/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_EXTRACT_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_EXTRACT_DATA
Programmer Name		: IMP Team
Description			: This procedure extracts the data from the global temporary table and creates the specified output file.
Frequency			: 
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_EXTRACT_DATA]
 @As_FileLocation_TEXT     VARCHAR(80),
 @As_File_NAME             VARCHAR(60),
 @As_Query_TEXT            VARCHAR(2000),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccessS_CODE CHAR(1) = 'S',
          @Lc_StatusFailedF_CODE  CHAR(1) = 'F',
          @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_EXTRACT_DATA',
          @Ls_Sql_TEXT            VARCHAR(100) = ' ',
          @Ls_Sqldata_TEXT        VARCHAR(1000) = ' ';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_BcpCommand_TEXT       VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';
  DECLARE @Output_P1			TABLE (Line_TEXT VARCHAR(8000));
  BEGIN TRY
   SET @Ls_Sql_TEXT = 'ACTIVE TRANSACTION CHECK';
   SET @Ls_Sqldata_TEXT ='Trancount = ' + CAST(@@TRANCOUNT AS VARCHAR);

   IF @@TRANCOUNT > 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ACTIVE TRANSACTION SHOULD BE COMMITTED BEFORE EXTRACT PROCESS';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@As_FileLocation_TEXT) IS NULL
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE LOCATION';

     RAISERROR (50001,16,1);
    END

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@As_File_NAME) IS NULL
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME';

     RAISERROR (50001,16,1);
    END

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@As_Query_TEXT) IS NULL
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID QUERY';

     RAISERROR (50001,16,1);
    END

   -- Delete previous output information
   SET @Ls_Sql_TEXT = 'DELETE @Output_P1';
   SET @Ls_Sqldata_TEXT ='';
   DELETE FROM @Output_P1;
    
   SET @Ls_BcpCommand_TEXT = 'bcp " ' + @As_Query_TEXT + '" QUERYOUT ' + @As_FileLocation_TEXT + @As_File_NAME + ' -c -t, -T -S ' + @@SERVERNAME + ' -d ' + +DB_NAME();
   -- Execute the BCP command and receive the output to show errors
   SET @Ls_Sql_TEXT = 'EXEC XP_CMDSHELL';
   SET @Ls_Sqldata_TEXT ='@Ls_BcpCommand_TEXT = ' + @Ls_BcpCommand_TEXT;
   
   INSERT INTO @Output_P1 
				(Line_TEXT)	
		EXEC XP_CMDSHELL @Ls_BcpCommand_TEXT;
	IF EXISTS (SELECT 1 FROM @Output_P1 WHERE Line_TEXT LIKE '%Error%')
	BEGIN
	    SET @Ls_Sql_TEXT = 'ASSINING ERROR';
	    SET @Ls_Sqldata_TEXT = '';
	    
		SELECT @Ls_ErrorMessage_TEXT = COALESCE(@Ls_ErrorMessage_TEXT + ',', '') + Line_TEXT
		FROM @Output_P1 WHERE Line_TEXT IS NOT NULL;
	    RAISERROR (50001,16,1);
	END
   SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailedF_CODE;
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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
  END CATCH;
 END


GO
