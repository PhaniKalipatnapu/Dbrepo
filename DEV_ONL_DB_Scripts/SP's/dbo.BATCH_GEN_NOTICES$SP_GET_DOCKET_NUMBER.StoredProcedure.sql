/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DOCKET_NUMBER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_DOCKET_NUMBER
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get File_ID
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DOCKET_NUMBER]
 @An_Case_IDNO             NUMERIC(6),
 @Ac_File_ID               CHAR(15) OUTPUT,
 @Ac_Msg_CODE              VARCHAR(4) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 DECLARE @Lc_StatusSuccess_CODE   CHAR,
         @Ls_Routine_TEXT         VARCHAR(60) ='BATCH_GEN_NOTICES$SP_GET_DOCKET_NUMBER',
         @Ls_Sql_TEXT             VARCHAR(1000),
         @Ls_Sqldata_TEXT         VARCHAR(400),
         @Lc_StatusFailed_CODE    CHAR,
         @Ls_Err_Description_TEXT VARCHAR(4000)

 SET @Lc_StatusFailed_CODE = 'F'
 SET @Lc_StatusSuccess_CODE = 'S'

 BEGIN
  BEGIN TRY
   IF @An_Case_IDNO != 0
    SET @Ac_File_ID =(SELECT File_ID
                        FROM CASE_Y1
                       WHERE Case_IDNO = @An_Case_IDNO);

   INSERT INTO #MemberDetails_P1
        VALUES('File_ID',
               @Ac_File_ID )

   IF @Ac_File_ID = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CASE_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' File_ID : ' + ISNULL(@Ac_File_ID, '');
     SET @As_DescriptionError_TEXT ='No Data Found'

     RAISERROR(50001,16,1)
    END

   SET @Ac_Msg_CODE=@Lc_StatusSuccess_CODE
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
