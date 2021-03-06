/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY gets first day and last day of previous month.
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY]
 @Ad_Run_DATE              DATETIME2,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_ErrorDesc_TEXT        VARCHAR(4000),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_ErrorMesg_TEXT        VARCHAR(4000),
          @Lc_Error_CODE            CHAR(4),
          @Ls_Errorproc_NAME        VARCHAR(75),
          @Ls_Format_CODE_ssn       VARCHAR(10),
          @Ls_Format_CODE_test      VARCHAR(10),
          @Lc_StatusFailed_CODE     CHAR(1),
          @Lc_StatusSuccess_CODE    CHAR(1);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT DATE';
   SET @Ls_Sqldata_TEXT = 'DATE = ' + CAST(ISNULL(@Ad_Run_DATE, '') AS CHAR);

   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), PREVIOUS_MONTH_FIRST_DATE) PREVIOUS_MONTH_FIRST_DATE,
                   CONVERT(VARCHAR(100), PREVIOUS_MONTH_LAST_DATE) PREVIOUS_MONTH_LAST_DATE
              FROM (SELECT CONVERT(VARCHAR(10), (DATEADD(MONTH, DATEDIFF(MONTH, -1, @Ad_Run_DATE) - 2, -1) + 1), 101) AS PREVIOUS_MONTH_FIRST_DATE,
                           CONVERT(VARCHAR(10), (DATEADD(MONTH, DATEDIFF(MONTH, -1, @Ad_Run_DATE) - 1, -1)), 101) AS PREVIOUS_MONTH_LAST_DATE)a) up UNPIVOT (tag_value FOR tag_name IN (PREVIOUS_MONTH_FIRST_DATE, PREVIOUS_MONTH_LAST_DATE )) AS pvt);
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY '

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE(), 'BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY') + ' PROCEDURE' + '. Error DESC - ' + @Ls_ErrorDesc_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICE_UTIL$SP_PREV_MTH_FIRSTDAY_LASTDAY') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
