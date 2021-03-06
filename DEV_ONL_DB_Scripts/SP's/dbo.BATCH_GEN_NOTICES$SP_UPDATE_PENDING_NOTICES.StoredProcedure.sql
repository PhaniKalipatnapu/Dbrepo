/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_UPDATE_PENDING_NOTICES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_UPDATE_PENDING_NOTICES
Programmer Name	:	IMP Team.
Description		:	This Procedure is used to update the pending central print notices status after moving the record to NRRQ table
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_UPDATE_PENDING_NOTICES]
	@As_NoticeStatus_TEXT		VARCHAR(MAX),
	@Ad_Start_DATE				DATETIME2,
	@Ac_Msg_CODE				CHAR(5)	OUTPUT,
	@As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE
			@Li_Error_NUMB					INT = NULL,
			@Li_ErrorLine_NUMB				INT = NULL,
			@Li_DocumentHandle_NUMB			INT = NULL,
			@Lc_StatusSuccess_CODE			CHAR (1) = 'S',
			@Lc_StatusFailed_CODE			CHAR (1) = 'F',
			@Lc_StatusAbnormalend_CODE      CHAR (1) = 'A',
			@Lc_StatusNoticeGenerate_CODE	CHAR (1) = 'G',
			@Lc_StatusNoticePrinted_CODE	CHAR (1) = 'P',
			@Lc_PrintMethodCentral_CODE		CHAR (1) = 'C',
			@Lc_Space_TEXT					CHAR (1) = ' ',
			@Lc_WorkerPrinter_ID			CHAR (30) = 'BATCH',
			@Lc_BateErrorE0085_CODE			CHAR (5) = 'E0085',
			
			@Lc_BateErrorUnknown_CODE		CHAR (5) = 'E0500',
			@Lc_Job_ID						CHAR (7) = 'DEB0960',
			@Lc_TypeError_CODE				CHAR (1) = 'E',
			@Ls_Procedure_NAME              VARCHAR (100) = 'SP_UPDATE_PENDING_NOTICES',
			@Ls_Process_NAME                VARCHAR (100) = 'Dhss.Ivd.Decss.Batch.CentralPrint',
			@Lc_Successful_TEXT				CHAR(20) = 'SUCCESSFUL',
			@Ld_Start_DATE                  DATETIME2 = @Ad_Start_DATE,
			@Ld_SystemDate_DATE				DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
			
		DECLARE
			@Lc_NoticeStatusCur_Notice_ID				CHAR(8),
			@Ln_NoticeStatusCur_Case_IDNO				NUMERIC(6, 0),
			@Lc_NoticeStatusCur_Recipient_ID			CHAR(10),
			@Ln_NoticeStatusCur_Barcode_NUMB			NUMERIC(12, 0),
			@Lc_NoticeStatusCur_PrintStatus_CODE		CHAR(1),
			@Lc_NoticeStatusCur_DescriptionErrorCode	VARCHAR(4000);
		
		DECLARE
			@Ln_CommitFreq_QNTY					NUMERIC (5) = 0,
			@Ln_Cursor_QNTY						NUMERIC (11) = 0,
			@Ln_ProcessedRecordCount_QNTY		NUMERIC (11) = 0,
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
			@Ld_Run_DATE						DATE,
			@Ld_LastRun_DATE					DATE;
		
		BEGIN TRY
			SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_UPDATE_PENDING_NOTICES';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
			EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
				@Ac_Job_ID                  = @Lc_Job_ID,
				@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
				@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
				@An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
				@An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
				@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				RAISERROR (50001,16,1);
			END
			
			SET @Ld_SystemDate_DATE = @Ld_Run_DATE;

			EXEC SP_XML_PREPAREDOCUMENT @Li_DocumentHandle_NUMB OUTPUT, @As_NoticeStatus_TEXT;

			DECLARE NoticeStatus_CUR INSENSITIVE CURSOR FOR
			SELECT
				XmlDocument.NoticeId,
				XmlDocument.CaseIdno,
				XmlDocument.RecipientID,
				XmlDocument.BarcodeNumb,
				XmlDocument.PrintStatusCode,
				XmlDocument.DescriptionErrorCode
			FROM 
				OPENXML(@Li_DocumentHandle_NUMB, 'ArrayOfStatus/Status', 2)   
				WITH (
						NoticeId				CHAR(8),
						CaseIdno				NUMERIC(6, 0),
						RecipientID				CHAR(10),
						BarcodeNumb				NUMERIC(12, 0),
						PrintStatusCode			CHAR(1),
						DescriptionErrorCode	VARCHAR(4000)
					) XmlDocument 
			
			SET @Ls_Sql_TEXT = 'OPEN NoticeStatus_CUR';
			SET @Ls_Sqldata_TEXT = '';
			
			OPEN NoticeStatus_CUR;

			SET @Ls_Sql_TEXT = 'FETCH NoticeStatus_CUR';
			SET @Ls_Sqldata_TEXT = '';

			FETCH NEXT FROM NoticeStatus_CUR INTO
				@Lc_NoticeStatusCur_Notice_ID,
				@Ln_NoticeStatusCur_Case_IDNO,
				@Lc_NoticeStatusCur_Recipient_ID,
				@Ln_NoticeStatusCur_Barcode_NUMB,
				@Lc_NoticeStatusCur_PrintStatus_CODE,
				@Lc_NoticeStatusCur_DescriptionErrorCode;
			
			SET @Li_FetchStatus_QNTY =@@FETCH_STATUS;
			
			BEGIN TRANSACTION UpdateNoticeStatus
			
			WHILE @Li_FetchStatus_QNTY = 0
			BEGIN
				BEGIN TRY
					SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
					SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;

					SET @Ls_CursorLocation_TEXT = +', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR);
					SET @Ls_Sqldata_TEXT= 'Case_IDNO = ' + CAST(@Ln_NoticeStatusCur_Case_IDNO AS VARCHAR) + ', Notice_ID = ' + CAST(@Lc_NoticeStatusCur_Notice_ID AS VARCHAR) +
										'@Ac_Recipient_ID = ' + CAST(@Lc_NoticeStatusCur_Recipient_ID AS VARCHAR) + ', Barcode_NUMB = ' + CAST(@Ln_NoticeStatusCur_Barcode_NUMB AS VARCHAR)
					SET @Ls_BateRecord_TEXT = @Ls_Sqldata_TEXT;

					IF @Lc_NoticeStatusCur_PrintStatus_CODE = @Lc_StatusSuccess_CODE
					BEGIN
						SET @Ls_Sql_TEXT = 'INSERT PROCESSED RECORD IN NRRQ';
						--Move the processed record from NMRQ to NRRQ
						INSERT NRRQ_Y1
							(
								Notice_ID,
								Case_IDNO,
								Recipient_ID,
								Barcode_NUMB,
								Recipient_CODE,
								NoticeVersion_NUMB,
								StatusNotice_CODE,
								WorkerRequest_ID,
								WorkerPrinted_ID,
								Generate_DTTM,
								Job_ID,
								Copies_QNTY,
								TransactionEventSeq_NUMB,
								Update_DTTM,
								File_ID,
								LoginWrkOficAttn_ADDR,
								LoginWorkersOffice_NAME,
								LoginWrkOficLine1_ADDR,
								LoginWrkOficLine2_ADDR,
								LoginWrkOficCity_ADDR,
								LoginWrkOficState_ADDR,
								LoginWrkOficZip_ADDR,
								LoginWorkerOfficeCountry_ADDR,
								RecipientAttn_ADDR,
								Recipient_NAME,
								RecipientLine1_ADDR,
								RecipientLine2_ADDR,
								RecipientCity_ADDR,
								RecipientState_ADDR,
								RecipientZip_ADDR,
								RecipientCountry_ADDR,
								PrintMethod_CODE,
								TypeService_CODE,
								Request_DTTM
							)
							SELECT 
								N.Notice_ID,
								N.Case_IDNO,
								N.Recipient_ID,
								N.Barcode_NUMB,
								N.Recipient_CODE,
								N.NoticeVersion_NUMB,
								@Lc_StatusNoticeGenerate_CODE,
								N.WorkerRequest_ID,
								@Lc_WorkerPrinter_ID,
								@Ld_SystemDate_DATE,
								N.Job_ID,
								N.Copies_QNTY,
								N.TransactionEventSeq_NUMB,
								@Ld_SystemDate_DATE,
								N.File_ID,
								N.LoginWrkOficAttn_ADDR,
								N.LoginWorkersOffice_NAME,
								N.LoginWrkOficLine1_ADDR,
								N.LoginWrkOficLine2_ADDR,
								N.LoginWrkOficCity_ADDR,
								N.LoginWrkOficState_ADDR,
								N.LoginWrkOficZip_ADDR,
								N.LoginWorkerOfficeCountry_ADDR,
								N.RecipientAttn_ADDR,
								N.Recipient_NAME,
								N.RecipientLine1_ADDR,
								N.RecipientLine2_ADDR,
								N.RecipientCity_ADDR,
								N.RecipientState_ADDR,
								N.RecipientZip_ADDR,
								N.RecipientCountry_ADDR,
								N.PrintMethod_CODE,
								N.TypeService_CODE,
								N.Request_DTTM
							FROM NMRQ_Y1 N
							WHERE
								N.Notice_ID = @Lc_NoticeStatusCur_Notice_ID AND
								N.Case_IDNO = @Ln_NoticeStatusCur_Case_IDNO AND
								N.Recipient_ID = @Lc_NoticeStatusCur_Recipient_ID AND
								N.Barcode_NUMB = @Ln_NoticeStatusCur_Barcode_NUMB AND
								N.StatusNotice_CODE IN (@Lc_StatusNoticeGenerate_CODE, @Lc_StatusFailed_CODE) AND
								N.PrintMethod_CODE = @Lc_PrintMethodCentral_CODE

						SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORD IN NMRQ';
						-- Delete the processed record from NMRQ
						DELETE NMRQ_Y1
						WHERE
							Notice_ID = @Lc_NoticeStatusCur_Notice_ID AND
							Case_IDNO = @Ln_NoticeStatusCur_Case_IDNO AND
							Recipient_ID = @Lc_NoticeStatusCur_Recipient_ID AND
							Barcode_NUMB = @Ln_NoticeStatusCur_Barcode_NUMB AND
							StatusNotice_CODE IN (@Lc_StatusNoticeGenerate_CODE,@Lc_StatusFailed_CODE) AND
							PrintMethod_CODE = @Lc_PrintMethodCentral_CODE
						
						SET @Ls_Sql_TEXT = 'INSERT PROCESSED RECORD IN AXML';
						-- Move the processed record from NXML to AXML
						INSERT AXML_Y1
							(
								Barcode_NUMB,
								Xml_TEXT
							)
							SELECT
								N.Barcode_NUMB,
								N.Xml_TEXT
							FROM NXML_Y1 N
							WHERE N.Barcode_NUMB = @Ln_NoticeStatusCur_Barcode_NUMB
						
						SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORD FROM NXML';
						-- Delete the processed record from NXML
						DELETE NXML_Y1
							WHERE Barcode_NUMB = @Ln_NoticeStatusCur_Barcode_NUMB
					END
					ELSE
					BEGIN
						SET @Ls_Sql_TEXT = 'UPDATE PROCESSED RECORD IN NMRQ FOR FAILED RECORDS';
						-- Update the status Print in NMRQ_Y1
						UPDATE NMRQ_Y1
							SET
								StatusNotice_CODE = @Lc_StatusFailed_CODE,
								Update_DTTM = @Ld_SystemDate_DATE
						WHERE
							Notice_ID = @Lc_NoticeStatusCur_Notice_ID AND
							Case_IDNO = @Ln_NoticeStatusCur_Case_IDNO AND
							Recipient_ID = @Lc_NoticeStatusCur_Recipient_ID AND
							Barcode_NUMB = @Ln_NoticeStatusCur_Barcode_NUMB AND
							StatusNotice_CODE IN (@Lc_StatusNoticeGenerate_CODE, @Lc_StatusFailed_CODE) AND
							PrintMethod_CODE = @Lc_PrintMethodCentral_CODE

						SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
						
						EXECUTE BATCH_COMMON$SP_BATE_LOG
							@As_Process_NAME             = @Ls_Process_NAME,
							@As_Procedure_NAME           = @Ls_Procedure_NAME,
							@Ac_Job_ID                   = @Lc_Job_ID,
							@Ad_Run_DATE                 = @Ld_Run_DATE,
							@Ac_TypeError_CODE           = @Lc_TypeError_CODE,
							@An_Line_NUMB                = 0,
							@Ac_Error_CODE               = @Lc_BateErrorE0085_CODE,
							@As_DescriptionError_TEXT    = @Lc_NoticeStatusCur_DescriptionErrorCode,
							@As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
							@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
							@As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

						IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
						BEGIN
							RAISERROR (50001,16,1);
						END
					END
				END TRY
				BEGIN CATCH
					SET @Li_Error_NUMB = ERROR_NUMBER();
					SET @Li_ErrorLine_NUMB = ERROR_LINE();

					IF @Li_Error_NUMB <> 50001
					BEGIN
						SET @Lc_TypeError_CODE = @Lc_TypeError_CODE;
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
				
				SET @Ls_Sql_TEXT = 'FETCH NoticeStatus_CUR';
				SET @Ls_Sqldata_TEXT = '';

				FETCH NEXT FROM NoticeStatus_CUR INTO
					@Lc_NoticeStatusCur_Notice_ID,
					@Ln_NoticeStatusCur_Case_IDNO,
					@Lc_NoticeStatusCur_Recipient_ID,
					@Ln_NoticeStatusCur_Barcode_NUMB,
					@Lc_NoticeStatusCur_PrintStatus_CODE,
					@Lc_NoticeStatusCur_DescriptionErrorCode;
			
				SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			END
			
			CLOSE NoticeStatus_CUR;
			DEALLOCATE NoticeStatus_CUR;
			
			EXEC SP_XML_REMOVEDOCUMENT @Li_DocumentHandle_NUMB
			SET @Li_DocumentHandle_NUMB = NULL;
			
			-- Update the last run date for the procedure with the run date in the PARM_Y1 table
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

			EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
				@Ac_Job_ID                = @Lc_Job_ID,
				@Ad_Run_DATE              = @Ld_Run_DATE,
				@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				RAISERROR (50001,16,1);
			END

			SET @Ln_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + 
								@Ls_Procedure_NAME + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', BatchRunUser_TEXT = ' + 
								@Lc_WorkerPrinter_ID +', ProcessedRecordCount_QNTY = '+ CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

			-- Updating the log with the Result_TEXT
			EXECUTE BATCH_COMMON$SP_BSTL_LOG
				@Ad_Run_DATE                  = @Ld_Run_DATE,
				@Ad_Start_DATE                = @Ld_Start_DATE,
				@Ac_Job_ID                    = @Lc_Job_ID,
				@As_Process_NAME              = @Ls_Process_NAME,
				@As_Procedure_NAME            = @Ls_Procedure_NAME,
				@As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
				@As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
				@As_ListKey_TEXT              = @Lc_Successful_TEXT,
				@An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
				@As_DescriptionError_TEXT     = @Lc_Space_TEXT,
				@Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
				@Ac_Worker_ID                 = @Lc_WorkerPrinter_ID;

			COMMIT TRANSACTION UpdateNoticeStatus
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE; 
		END TRY
		BEGIN CATCH
			IF CURSOR_STATUS ('LOCAL', 'NoticeStatus_CUR') IN (0, 1)
			BEGIN
				CLOSE NoticeStatus_CUR;
				DEALLOCATE NoticeStatus_CUR;
			END
			
			-- Check if active transaction exists for this session then rollback the transaction
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION UpdateNoticeStatus;
			END
			
			IF @Li_DocumentHandle_NUMB IS NOT NULL
			BEGIN
				EXEC SP_XML_REMOVEDOCUMENT @Li_DocumentHandle_NUMB
			END
			
			SET @Ac_Msg_CODE		= @Lc_StatusFailed_CODE;
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
			
			SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
		END CATCH
	END

GO
