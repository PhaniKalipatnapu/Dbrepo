/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_NOTICE_XML_ADDR_TYPE_COUNT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_NOTICE_XML_ADDR_TYPE_COUNT
Programmer Name		: Protech Solutions, Inc.
Description     	: Used to get the address count
Frequency			:
Developed On		: 04/12/2011
Called By			: BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA
Called On         	: 
-------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_NOTICE_XML_ADDR_TYPE_COUNT]
 @Ai_Notice_Counter_NUMB   INT,
 @Ai_Recipient_Count_NUMB  INT,
 @Ai_Addr_Type_Count_NUMB  INT OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  CREATE TABLE #AddrTypeCount_P1
   (
     Addr_Type_Count INT
   /*TODO: Column (Name,datatype,length) need to analyzed and changed Manually*/
   );

  DECLARE @Ls_Err_Description_TEXT VARCHAR(4000),
          @Ls_Node_TEXT            VARCHAR(MAX),
          @Lc_Space_TEXT           CHAR = ' ',
          @Lc_StatusFailed_CODE    CHAR = 'F',
          @Lc_StatusSuccess_CODE   CHAR = 'S',
          @Ls_SQL_TEXT             NVARCHAR(MAX);

  BEGIN TRY
   SET @Ls_Node_TEXT ='notices/notice[' + CONVERT(VARCHAR, @Ai_Notice_Counter_NUMB) + ']/recipients/recipient[' + CONVERT(VARCHAR, @Ai_Recipient_Count_NUMB) + ']/addresses[1]/typeaddress_code';
   SET @Ls_SQL_TEXT = 'DECLARE @Addr_Type_Count INT,
							@Notice_XML XML;
					
					SET @Notice_XML = (SELECT Data_XML FROM #NoticeXmlInputData_P1);
					
					SELECT @Addr_Type_Count = COUNT(*) FROM (SELECT t.c.exist(''typeaddress_code'') AS id  
					FROM @Notice_XML.nodes(''' + @Ls_Node_TEXT + ''') t(c)) a
											
					INSERT INTO #AddrTypeCount_P1 (Addr_Type_Count)
					VALUES(@Addr_Type_Count)';

   EXEC (@Ls_SQL_TEXT);

   SELECT @Ai_Addr_Type_Count_NUMB = Addr_Type_Count
     FROM #AddrTypeCount_P1;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF OBJECT_ID('tempdb..#AddrTypeCount_P1') IS NOT NULL
    BEGIN
     DROP TABLE #AddrTypeCount_P1;
    END

   SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
