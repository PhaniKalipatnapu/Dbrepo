/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_PENDING_NOTICES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_PENDING_NOTICES
Programmer Name	:	IMP Team.
Description		:	This Procedure is used to retrieve the pending central print notices
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_PENDING_NOTICES]
AS
	BEGIN
		SET NOCOUNT ON;
		
		DECLARE @Lt_NmrqNxmlData_TAB TABLE
		(
			Notice_ID					CHAR(8),
			Case_IDNO					NUMERIC(6,0),
			Recipient_ID				CHAR(10),
			Barcode_NUMB				NUMERIC(12,0),
			NoticeVersion_NUMB			NUMERIC(5,0),
			StatusNotice_CODE			CHAR(1),
			Copies_QNTY					NUMERIC(5,0),
			TransactionEventSeq_NUMB	NUMERIC(19,0),
			PrintMethod_CODE			CHAR(2),
			Xml_TEXT					VARCHAR(MAX)
		);
		
		DECLARE
			@Ln_RestartLine_NUMB            NUMERIC(5,0) = 0,
			@Li_Error_NUMB					INT = NULL,
			@Li_ErrorLine_NUMB				INT = NULL,
			@Lc_StatusSuccess_CODE			CHAR (1) = 'S',
			@Lc_StatusFailed_CODE			CHAR (1) = 'F',
			@Lc_TypeError_CODE				CHAR (1) = 'E',
			@Lc_NoDataFound_CODE			CHAR (1) = 'N',
			@Lc_StatusAbnormalend_CODE      CHAR (1) = 'A',
			@Lc_StatusNoticeGenerate_CODE	CHAR (1) = 'G',
			@Lc_StatusNoticeFailed_CODE		CHAR (1) = 'F',
			@Lc_PrintMethodCentral_CODE		CHAR (1) = 'C',
			@Lc_Space_TEXT					CHAR (1) = ' ',
			@Lc_WorkerPrinter_ID			CHAR (30) = 'BATCH',
			@Lc_Job_ID						CHAR (7) = 'DEB0960',
			@Lc_ErrorE0944_CODE				CHAR (5) = 'E0944',
			@Lc_BateErrorUnknown_CODE		CHAR (5) = 'E0500',
			@Lc_Successful_TEXT				CHAR(20) = 'SUCCESSFUL',
			@Ls_Procedure_NAME				VARCHAR(100) = 'SP_GET_PENDING_NOTICES',
			@Ls_Process_NAME                VARCHAR (100) = 'Dhss.Ivd.Decss.Batch.CentralPrint',
			@Ld_Start_DATE                  DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		
		DECLARE
			@Ln_NoticeXmlCur_Barcode_NUMB				NUMERIC(12,0),
			@Ln_NoticeXmlCur_NoticeVersion_NUMB			NUMERIC(5,0),
			@Ln_NoticeXmlCur_Case_IDNO					NUMERIC(6,0),
			@Ln_NoticeXmlCur_Copies_QNTY				NUMERIC(5,0),
			@Ln_NoticeXmlCur_TransactionEventSeq_NUMB	NUMERIC(19,0),
			@Lc_NoticeXmlCur_Notice_ID					CHAR(8),
			@Lc_NoticeXmlCur_Recipient_ID				CHAR(10),
			@Lc_NoticeXmlCur_Recipient_CODE				CHAR(2),
			@Lc_NoticeXmlCur_StatusNotice_CODE			CHAR(1),			
			@Lc_NoticeXmlCur_PrintMethod_CODE			CHAR(2),
			@Ls_NoticeXmlCur_Xml_TEXT					VARCHAR(MAX)
			
		DECLARE
			@Ln_Cursor_QNTY						NUMERIC (11) = 0,
			@Ln_CommitFreqParm_QNTY				NUMERIC (5),
			@Ln_ExceptionThresholdParm_QNTY		NUMERIC (5),
			@Li_FetchStatus_QNTY				SMALLINT,
			@Lc_Msg_CODE						CHAR (1),
			@Ls_ErrorMessage_TEXT				VARCHAR (4000),
			@Ls_Sql_TEXT						VARCHAR (1000),
			@Ls_Sqldata_TEXT					VARCHAR (4000),
			@Ls_DescriptionError_TEXT			VARCHAR (4000),
			@Ls_CursorLocation_TEXT				VARCHAR (1000) = '',
			@Ls_BateRecord_TEXT					VARCHAR (4000) = '',
			@Ls_MaskedNoticeXml_TEXT			VARCHAR (4000),
			@Ld_Run_DATE						DATE,
			@Ld_LastRun_DATE					DATE;
			
		BEGIN TRY
			SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_PENDING_NOTICES';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
			EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
				@Ac_Job_ID                  = @Lc_Job_ID,
				@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
				@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
				@An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
				@An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
				@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				RAISERROR (50001,16,1);
			END
			
			SET @Ls_Sql_TEXT = 'SELECT PENDING N0TICES';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
			
			DECLARE NoticeXml_CUR INSENSITIVE CURSOR FOR
			SELECT
				N.Notice_ID,
				N.Case_IDNO,
				N.Recipient_ID,
				N.Recipient_CODE,
				N.Barcode_NUMB,
				N.NoticeVersion_NUMB,
				N.StatusNotice_CODE,
				N.Copies_QNTY,
				N.TransactionEventSeq_NUMB,
				N.PrintMethod_CODE,
				X.Xml_TEXT
			FROM
				NMRQ_Y1 N
				JOIN
				NXML_Y1 X
				ON X.Barcode_NUMB = N.Barcode_NUMB
			WHERE
				N.StatusNotice_CODE IN (@Lc_StatusNoticeGenerate_CODE, @Lc_StatusNoticeFailed_CODE) AND
				N.PrintMethod_CODE = @Lc_PrintMethodCentral_CODE
			
			SET @Ls_Sql_TEXT = 'OPEN NoticeXml_CUR';
			SET @Ls_Sqldata_TEXT = '';
			
			OPEN NoticeXml_CUR;

			SET @Ls_Sql_TEXT = 'FETCH NoticeXml_CUR';
			SET @Ls_Sqldata_TEXT = '';

			FETCH NEXT FROM NoticeXml_CUR INTO
				@Lc_NoticeXmlCur_Notice_ID,
				@Ln_NoticeXmlCur_Case_IDNO,
				@Lc_NoticeXmlCur_Recipient_ID,
				@Lc_NoticeXmlCur_Recipient_CODE,
				@Ln_NoticeXmlCur_Barcode_NUMB,
				@Ln_NoticeXmlCur_NoticeVersion_NUMB,
				@Lc_NoticeXmlCur_StatusNotice_CODE,
				@Ln_NoticeXmlCur_Copies_QNTY,
				@Ln_NoticeXmlCur_TransactionEventSeq_NUMB,
				@Lc_NoticeXmlCur_PrintMethod_CODE,
				@Ls_NoticeXmlCur_Xml_TEXT;
			
			SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			
			WHILE @Li_FetchStatus_QNTY = 0
			BEGIN
				BEGIN TRY
					SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
					
					SET @Ls_CursorLocation_TEXT = +', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR);
					SET @Ls_Sqldata_TEXT= 'Case_IDNO = ' + CAST(@Ln_NoticeXmlCur_Case_IDNO AS VARCHAR) + ', Notice_ID = ' + CAST(@Lc_NoticeXmlCur_Notice_ID AS VARCHAR) +
											'@Ac_Recipient_ID = ' + CAST(@Lc_NoticeXmlCur_Recipient_ID AS VARCHAR) + ', Barcode_NUMB = ' + CAST(@Ln_NoticeXmlCur_Barcode_NUMB AS VARCHAR)
					SET @Ls_BateRecord_TEXT = @Ls_Sqldata_TEXT;
					
					EXECUTE BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV
						@An_Case_IDNO				= @Ln_NoticeXmlCur_Case_IDNO,
						@Ac_Notice_ID				= @Lc_NoticeXmlCur_Notice_ID,
						@Ac_Recipient_CODE			= @Lc_NoticeXmlCur_Recipient_CODE,
						@Ac_Recipient_ID			= @Lc_NoticeXmlCur_Recipient_ID,
						@As_XmlInput_TEXT			= @Ls_NoticeXmlCur_Xml_TEXT,
						@As_XmlOut_TEXT				= @Ls_MaskedNoticeXml_TEXT OUTPUT,
						@Ac_Msg_CODE				= @Lc_Msg_CODE OUTPUT,
						@As_DescriptionError_TEXT	= @Ls_DescriptionError_TEXT OUTPUT;
					
					IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
						RAISERROR (50001,16,1);
					END
					
					SET @Ls_Sql_TEXT = 'INSERT @Lt_NmrqNxmlData_TAB';
					
					INSERT @Lt_NmrqNxmlData_TAB
					(
						Notice_ID,
						Case_IDNO,
						Recipient_ID,
						Barcode_NUMB,
						NoticeVersion_NUMB,
						StatusNotice_CODE,
						Copies_QNTY,
						TransactionEventSeq_NUMB,
						PrintMethod_CODE,
						Xml_TEXT
					)
					VALUES
					(
						@Lc_NoticeXmlCur_Notice_ID,
						@Ln_NoticeXmlCur_Case_IDNO,
						@Lc_NoticeXmlCur_Recipient_ID,
						@Ln_NoticeXmlCur_Barcode_NUMB,
						@Ln_NoticeXmlCur_NoticeVersion_NUMB,
						@Lc_NoticeXmlCur_StatusNotice_CODE,
						@Ln_NoticeXmlCur_Copies_QNTY,
						@Ln_NoticeXmlCur_TransactionEventSeq_NUMB,
						@Lc_NoticeXmlCur_PrintMethod_CODE,
						@Ls_NoticeXmlCur_Xml_TEXT
					)
					
				END TRY
				BEGIN CATCH
					SET @Li_Error_NUMB = ERROR_NUMBER();
					SET @Li_ErrorLine_NUMB = ERROR_LINE();

					IF @Li_Error_NUMB <> 50001
					BEGIN
						SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
					END

					EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
						@As_Procedure_NAME        = @Ls_Procedure_NAME,
						@As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
						@As_Sql_TEXT              = @Ls_Sql_TEXT,
						@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
						@An_Error_NUMB            = @Li_Error_NUMB,
						@An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
						@As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

					SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
					SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + 
									', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeError_CODE + ', CursorLocation_TEXT = ' + @Ls_CursorLocation_TEXT + 
									', BateError_CODE = ' + @Lc_BateErrorUnknown_CODE + ', DescriptionError_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

					EXECUTE BATCH_COMMON$SP_BATE_LOG
						@As_Process_NAME             = @Ls_Process_NAME,
						@As_Procedure_NAME           = @Ls_Procedure_NAME,
						@Ac_Job_ID                   = @Lc_Job_ID,
						@Ad_Run_DATE                 = @Ld_Run_DATE,
						@Ac_TypeError_CODE           = @Lc_TypeError_CODE,
						@An_Line_NUMB                = @Ln_Cursor_QNTY,
						@Ac_Error_CODE               = @Lc_BateErrorUnknown_CODE,
						@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
						@As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
						@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						@As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

					IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
						RAISERROR (50001,16,1);
					END
				END CATCH
				
				SET @Ls_Sql_TEXT = 'FETCH NoticeXml_CUR';
				SET @Ls_Sqldata_TEXT = '';
				
				FETCH NEXT FROM NoticeXml_CUR INTO
					@Lc_NoticeXmlCur_Notice_ID,
					@Ln_NoticeXmlCur_Case_IDNO,
					@Lc_NoticeXmlCur_Recipient_ID,
					@Lc_NoticeXmlCur_Recipient_CODE,
					@Ln_NoticeXmlCur_Barcode_NUMB,
					@Ln_NoticeXmlCur_NoticeVersion_NUMB,
					@Lc_NoticeXmlCur_StatusNotice_CODE,
					@Ln_NoticeXmlCur_Copies_QNTY,
					@Ln_NoticeXmlCur_TransactionEventSeq_NUMB,
					@Lc_NoticeXmlCur_PrintMethod_CODE,
					@Ls_NoticeXmlCur_Xml_TEXT;
				
				SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			END
			
			CLOSE NoticeXml_CUR;
			DEALLOCATE NoticeXml_CUR;
			
			SET @Ls_Sql_TEXT = 'SELECT @Lt_NmrqNxmlData_TAB';
			SELECT
				D.Notice_ID,
				D.Case_IDNO,
				D.Recipient_ID,
				D.Barcode_NUMB,
				D.NoticeVersion_NUMB,
				D.StatusNotice_CODE,
				D.Copies_QNTY,
				D.TransactionEventSeq_NUMB,
				D.PrintMethod_CODE,
				D.Xml_TEXT
			FROM
				@Lt_NmrqNxmlData_TAB D
				
		END TRY
		BEGIN CATCH
			SET @Li_Error_NUMB		= ERROR_NUMBER ();
			SET @Li_ErrorLine_NUMB	= ERROR_LINE ();
			
			IF (@Li_Error_NUMB <> 50001)
            BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END
            
            EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
				@As_Procedure_NAME			= @Ls_Procedure_NAME,
				@As_ErrorMessage_TEXT		= @Ls_DescriptionError_TEXT,
                @As_Sql_TEXT				= @Ls_Sql_TEXT,
                @As_Sqldata_TEXT			= @Ls_SqlData_TEXT,
                @An_Error_NUMB				= @Li_Error_NUMB,
                @An_ErrorLine_NUMB			= @Li_ErrorLine_NUMB,
                @As_DescriptionError_TEXT	= @Ls_DescriptionError_TEXT OUTPUT ;
			
			EXECUTE BATCH_COMMON$SP_BSTL_LOG
				@Ad_Run_DATE                  = @Ld_Run_DATE,
				@Ad_Start_DATE                = @Ld_Start_DATE,
				@Ac_Job_ID                    = @Lc_Job_ID,
				@As_Process_NAME              = @Ls_Process_NAME,
				@As_Procedure_NAME            = @Ls_Procedure_NAME,
				@As_CursorLocation_TEXT       = @Lc_Space_TEXT,
				@As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
				@As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
				@An_ProcessedRecordCount_QNTY = 0,
				@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
				@Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
				@Ac_Worker_ID                 = @Lc_WorkerPrinter_ID;
		END CATCH
	END

GO
