/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_NOTICE_XML_RECIPIENT_COUNT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_NOTICE_XML_RECIPIENT_COUNT
Programmer Name		: Protech Solutions, Inc.
Description     	: Used to get the receipient count
Frequency			:
Developed On		: 04/12/2011
Called By			: BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA
Called On       	: 
----------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_NOTICE_XML_RECIPIENT_COUNT]
 @Ai_Notice_Counter_NUMB   INT,
 @Ai_Recipient_Count_NUMB  INT OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 CREATE TABLE #RecipientCount_P1
  (
    Recipient_Count INT
  );

 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lx_Notice_XML           XML,
          @Ls_Node_TEXT            VARCHAR(MAX),
          @Ls_Sql_TEXT             VARCHAR(MAX),
          @Ls_Err_Description_TEXT VARCHAR(4000),
          @Lc_Space_TEXT           CHAR = ' ',
          @Lc_StatusFailed_CODE    CHAR = 'F',
          @Lc_StatusSuccess_CODE   CHAR = 'S';

  BEGIN TRY
   SET @Ls_Node_TEXT ='notices/notice[' + CONVERT(VARCHAR, @Ai_Notice_Counter_NUMB) + ']/recipients/recipient';
   SET @Ls_Sql_TEXT = 'DECLARE @Recipient_Count INT,
								@Lx_Notice_XML XML;
			
			SET @Lx_Notice_XML = (SELECT Data_XML FROM #NoticeXmlInputData_P1)
			
		    SELECT @Recipient_Count = COUNT(*) FROM (SELECT t.c.exist(''recipient'') AS id  
			FROM @Lx_Notice_XML.nodes(''' + @Ls_Node_TEXT + ''') t(c)) a
									
			INSERT INTO #RecipientCount_P1 (Recipient_Count)
			VALUES(@Recipient_Count)';

   EXEC (@Ls_Sql_TEXT);

   SELECT @Ai_Recipient_Count_NUMB = Recipient_Count
     FROM #RecipientCount_P1;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF OBJECT_ID('tempdb..#RecipientCount_P1') IS NOT NULL
    BEGIN
     DROP TABLE #RecipientCount_P1;
    END

   SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
