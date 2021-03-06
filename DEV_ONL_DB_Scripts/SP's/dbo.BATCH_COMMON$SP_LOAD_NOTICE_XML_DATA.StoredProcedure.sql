/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 --------------------------------------------------------------------------------------------------------------------
 Procedure Name   : BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA
 Programmer Name  : IMP Team.
 Description      : This procedure is used to insert the Notice XML into the temp tables
 Frequency        :
 Developed On     :	04/12/2011
 Called By        : BATCH_COMMON$SP_INSERT_ACTIVITY
 Called On        : 
---------------------------------------------------------------------------------------------------------------------------------
 Modified By      :
 Modified On      :
 Version No       : 1.0
--------------------------------------------------------------------------------------------------------------------
 */

CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA] 
(
 @As_Notice_XML                     VARCHAR(MAX),
 @Ac_Msg_CODE                       CHAR(1)			OUTPUT,
 @As_DescriptionError_TEXT          VARCHAR(4000)	OUTPUT
)
AS
BEGIN
	DECLARE @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
            @Lc_Space_TEXT						CHAR(1)			= ' ',
            @Lc_StatusFailed_CODE				CHAR(1)			= 'F',
            @Li_Error_NUMB						NUMERIC(11),
            @Li_ErrorLine_NUMB					NUMERIC(11),
            @Ls_Procedure_NAME					VARCHAR(40)		= 'BATCH_COMMON$SP_LOAD_NOTICE_XML_DATA',
            @Ls_Sql_TEXT						VARCHAR(4000),
            @Ls_Sqldata_TEXT					VARCHAR(4000),
            @Ls_Err_Description_TEXT			VARCHAR(4000),
            @Lx_Notice_XML						XML;
            
	BEGIN TRY
		 
		 SET @Ls_Sqldata_TEXT = '@As_Notice_XML = '+@As_Notice_XML;
		 SET @Ls_Sql_TEXT = 'CAST Input XML';
		 SET @Lx_Notice_XML = CAST(@As_Notice_XML AS XML);
		 
		 SET @Ls_Sql_TEXT = 'INSERT #NoticeInput_P1 FROM Input XML';
		 SET @Ls_Sqldata_TEXT = '@As_Notice_XML = '+@As_Notice_XML;
		 INSERT INTO #NoticeInput_P1
         SELECT notice.value('notice_id[1]','VARCHAR(8)') Notice_ID,
				-- 13609 - FIN-19 recipient information isn't getting retrieved correctly - Start
				recipient.value('recipient_code[1]','CHAR(4)') Recipient_CODE,
				-- 13609 - FIN-19 recipient information isn't getting retrieved correctly - End
				recipient.value('recipient_id[1]','CHAR(10)') Recipient_ID,
				recipient.value('typeservice_code[1]','CHAR(1)') TypeService_CODE, 
				recipient.value('printmethod_code[1]','CHAR(1)') PrintMethod_CODE,
				address.value('.','CHAR(1)') Addr_Type_CODE,
				ISNULL(notice.value('barcode_numb[1]','VARCHAR(19)'),'0') Barcode_Numb,
				REPLACE(CAST(notices.notice.query('inputparameters') AS VARCHAR(MAX)),'''', '~~') Input_Parameters_TEXT 
			FROM @Lx_Notice_XML.nodes('notices/notice' ) notices(notice)
			CROSS APPLY notice.nodes('recipients/recipient' ) recipients(recipient) 
			CROSS APPLY recipient.nodes('addresses/typeaddress_code' ) addresses(address)
		ORDER BY 1,2;
		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @As_DescriptionError_TEXT = 'INSERT #NoticeInput_P1 from XML Parsing Failed';
			RAISERROR(50001,16,1);
		END
		
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

         SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
	END TRY
    BEGIN CATCH
		SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		SET @Li_Error_NUMB = ERROR_NUMBER();
		SET @Li_ErrorLine_NUMB = ERROR_LINE();

		IF @Li_Error_NUMB <> 50001
		BEGIN
			SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
		END
		
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
		@As_Sql_TEXT              = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
		@An_Error_NUMB            = @Li_Error_NUMB,
		@An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
		@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
		
	END CATCH
END

GO
