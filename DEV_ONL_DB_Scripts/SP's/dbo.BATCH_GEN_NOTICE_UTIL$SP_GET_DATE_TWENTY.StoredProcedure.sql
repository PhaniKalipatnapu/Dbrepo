/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_TWENTY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_TWENTY
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Next date after 20 days from System date.
Frequency		:	
Developed On	:	3/16/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_TWENTY]
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
AS
 BEGIN
  DECLARE @Lc_StatusSuccess_CODE   CHAR = 'S',
          @Lc_StatusFailed_CODE    CHAR = 'F',
          @Ls_DoubleSpace_TEXT     VARCHAR(2) = '  ',
          @Ls_Routine_TEXT         VARCHAR(100) = 'BATCH_GEN_NOTICE_UTIL.BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_TWENTY',
          @Ld_Next_DATE            DATETIME2,
          @Ls_Sql_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(400)

  BEGIN TRY
   SET @Ld_Next_DATE = NULL
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_DATE_TWENTY'
   SET @Ls_Sqldata_TEXT = 'Run_DATE=' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(MAX)), '')
   SET @Ld_Next_DATE = DATEADD(D, 20, @Ad_Run_DATE)

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
        VALUES('TWENTY_DAYS_AFTER_SYSDATE',
               CONVERT(VARCHAR, @Ld_Next_DATE, 101))

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE=@Lc_StatusFailed_CODE
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END



GO
