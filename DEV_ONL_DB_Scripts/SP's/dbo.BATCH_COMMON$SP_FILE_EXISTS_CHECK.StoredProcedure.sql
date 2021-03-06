/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_FILE_EXISTS_CHECK]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*    
-----------------------------------------------------------------------------------------------------------------    
Procedure Name		: BATCH_COMMON$SP_FILE_EXISTS_CHECK 
Programmer Name		: IMP Team    
Description			: This procedure is used to check the input file exists or not in input folder
Frequency			: 
Developed On		: 07/12/2012
Called By			:   
Called On			:      
--------------------------------------------------------------------------------------------------------------------      
Modified By			:   
Modified On			:  
Version No			: 0.01    
-----------------------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_FILE_EXISTS_CHECK]
 @As_File_NAME             VARCHAR(60),
 @As_FileLocation_TEXT     VARCHAR(80),
 @Ab_FileExists_BIT        BIT OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS

 BEGIN
  SET NOCOUNT ON;
  
  DECLARE  @Ls_Procedure_TEXT  VARCHAR(100) = 'SP_FILE_EXISTS_CHECK';
  DECLARE  @Ln_Error_NUMB         NUMERIC(11),
           @Ln_ErrorLine_NUMB     NUMERIC(11),
           @Ls_Sql_TEXT           VARCHAR(200),
           @Ls_Sqldata_TEXT       VARCHAR(200),
           @Ls_Query_TEXT         VARCHAR(8000),
           @Ls_ErrorMessage_TEXT  VARCHAR(8000);

  BEGIN TRY
   SET @Ab_FileExists_BIT = 0;

   IF @As_File_NAME <> ''
      AND @As_FileLocation_TEXT <> ''
    BEGIN
     SET @Ls_Query_TEXT = 'dir /B /S ' + @As_FileLocation_TEXT;
     
     SET @Ls_Sql_TEXT = 'CREATION OF TEMP TABLE';
	 SET @Ls_Sqldata_TEXT ='';
	 
     CREATE TABLE #ListofFiles_P1
      (
        List_of_Files VARCHAR(8000)
      );

     SET @Ls_Sql_TEXT = 'INSERTION INTO TEMP TABLE';
     SET @Ls_Sqldata_TEXT ='Query_TEXT = ' + @Ls_Query_TEXT;

     INSERT INTO #ListofFiles_P1
                 (List_of_Files)
     EXECUTE XP_CMDSHELL @Ls_Query_TEXT;

     SET @Ls_Sql_TEXT = 'CHECKING IN FILE EXISTS IN TEMP TABLE OR NOT';
     SET @Ls_Sqldata_TEXT ='';

     IF EXISTS (SELECT 1
                  FROM #ListofFiles_P1
                 WHERE List_of_Files LIKE '%' + @As_File_NAME + '%')
      BEGIN           
		SET @Ab_FileExists_BIT = 1;
      END
     ELSE
      BEGIN
		SET @Ab_FileExists_BIT = 0;
      END
		
     DROP TABLE #ListofFiles_P1;
    END
   ELSE
    BEGIN
     SET @Ab_FileExists_BIT = 0;
    END

   SET @Ac_Msg_CODE = 'S';
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ab_FileExists_BIT = 0;
   SET @Ac_Msg_CODE = 'F';
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();   
    
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END 
GO
