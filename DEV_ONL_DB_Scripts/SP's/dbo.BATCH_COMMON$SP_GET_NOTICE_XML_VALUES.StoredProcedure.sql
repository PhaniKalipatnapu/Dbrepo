/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_NOTICE_XML_VALUES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_NOTICE_XML_VALUES
Programmer Name		: Protech Solutions, Inc.
Description     	: 
Frequency			:
Developed On		: 04/12/2011
Called By			: BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA
Called On           : 
--------------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_NOTICE_XML_VALUES]
 @Ai_Notice_NUMB           INT,
 @Ai_Recipient_NUMB        INT,
 @Ai_Address_NUMB          INT,
 @As_Input_Values_TEXT     VARCHAR(MAX),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(400) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_Node_TEXT            VARCHAR(4000),
          @Ls_RecipientNode_TEXT   VARCHAR(4000),
          @Ls_AddrTypeNode_TEXT    VARCHAR(4000),
          @Lc_StatusSuccess_CODE   CHAR = 'S',
          @Lc_Space_TEXT           CHAR = ' ',
          @Lc_StatusFailed_CODE    CHAR = 'F',
          @Ls_Err_Description_TEXT VARCHAR (4000),
          @Ls_Sql_TEXT             VARCHAR(MAX);

  BEGIN TRY
   SET @Ls_Node_TEXT = 'notices/notice[' + CONVERT(VARCHAR, @Ai_Notice_NUMB) + ']';
   SET @Ls_RecipientNode_TEXT = 'notices/notice[' + CONVERT(VARCHAR, @Ai_Notice_NUMB) + ']/recipients/recipient[' + CONVERT (VARCHAR, @Ai_Recipient_NUMB) + ']';
   SET @Ls_AddrTypeNode_TEXT = 'notices/notice[' + CONVERT(VARCHAR, @Ai_Notice_NUMB) + ']/recipients/recipient[' + CONVERT(VARCHAR, @Ai_Recipient_NUMB) + ']/addresses[1]';
   SET @As_Input_Values_TEXT = REPLACE(@As_Input_Values_TEXT, '''', '~~');
   SET @Ls_Sql_TEXT = 'DECLARE 
					@Notice_XML XML,
					@Notice_ID VARCHAR(8),
					@Barcode_Numb VARCHAR(20),
					@Recipient_CODE VARCHAR(4),
					@Recipient_ID CHAR(10),
					@TypeService_CODE VARCHAR(2),
					@PrintMethod_CODE VARCHAR(2),
					@Addr_Type_CODE VARCHAR(2);
					
				SET @Notice_XML = (SELECT Data_XML FROM #NoticeXmlInputData_P1);
				
				SELECT  @Notice_ID = x.value(''notice_id[1]'',''VARCHAR(20)''),
						@Barcode_Numb = x.value(''barcode_numb[1]'',''VARCHAR(20)''),
						@Recipient_CODE = (SELECT Y.value(''recipient_code[1]'',''VARCHAR(20)'')
											 FROM @Notice_XML.nodes(''' + @Ls_RecipientNode_TEXT + ''') a(Y)),
						@Recipient_ID = (SELECT Y.value(''recipient_id[1]'',''VARCHAR(20)'')
											 FROM @Notice_XML.nodes(''' + @Ls_RecipientNode_TEXT + ''') a(Y)),
						@TypeService_CODE = (SELECT Y.value(''typeservice_code[1]'',''VARCHAR(20)'')
											   FROM @Notice_XML.nodes(''' + @Ls_RecipientNode_TEXT + ''') a(Y)),
						@PrintMethod_CODE = (SELECT Y.value(''printmethod_code[1]'',''VARCHAR(20)'')
											   FROM @Notice_XML.nodes(''' + @Ls_RecipientNode_TEXT + ''') a(Y)),
						@Addr_Type_CODE =(SELECT Y.value(''typeaddress_code[' + CONVERT(VARCHAR, @Ai_Address_NUMB) + ']'',''VARCHAR(20)'') 
											FROM @Notice_XML .nodes(''' + @Ls_AddrTypeNode_TEXT + ''') a(Y))
				FROM @Notice_XML.nodes(''' + @Ls_Node_TEXT + ''') a(x)
				
				INSERT INTO #NoticeInput_P1(Notice_ID, Recipient_CODE, Recipient_ID, TypeService_CODE, PrintMethod_CODE, Addr_Type_CODE, Barcode_Numb, Input_Parameters_TEXT)
				VALUES(@Notice_ID, @Recipient_CODE, @Recipient_ID, @TypeService_CODE, @PrintMethod_CODE, @Addr_Type_CODE, @Barcode_Numb, ''' + @As_Input_Values_TEXT + ''')';

   EXEC (@Ls_Sql_TEXT);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
