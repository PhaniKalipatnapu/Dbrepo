/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_ADDR_NORM$SP_EXTRACT_ADDR_NORM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	/*
-----------------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_OUTGOING_ADDR_NORM$SP_EXTRACT_ADDR_NORM

Programmer Name 	: IMP Team

Description			: The procedure BATCH_LOC_OUTGOING_ADDR_NORM$SP_EXTRACT_ADDR_NORM extracts all addresses in the Member Address History (AHIS_Y1) 
					  table and the Other Party Information (OTHP_Y1) table, which were entered by a user into the system since the last execution 
					  of this process for address normalization.If the detail record count does not match with the trailer count,an error message 
					  will be written into Batch Status_CODE Log(BSTL screen/BSTL_Y1 table) and the file processing will be terminated.

Frequency			: 'QUATERLY'

Developed On		: 

Called BY			: None

Called On			: 
-----------------------------------------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
-----------------------------------------------------------------------------------------------------------------------------------------------------
*/
	CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_ADDR_NORM$SP_EXTRACT_ADDR_NORM]
	AS
	BEGIN
	SET NOCOUNT ON;

	DECLARE  @Lc_Space_TEXT                   CHAR(1) = ' ',
		   @Lc_Zero_TEXT					  CHAR(1) = '0',
		   @Lc_TypeErrorWarning_CODE          CHAR(1) = 'W',
		   @Lc_StatusFailed_CODE              CHAR(1) = 'F',
		   @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
		   @Lc_StatusAbnormalend_CODE         CHAR(1) = 'A',		 
		   @Lc_TypeRecordAhis_CODE			  CHAR(1) = 'A',
		   @Lc_TypeRecordOthp_CODE			  CHAR(1) = 'O',		   		   
		   @Lc_RecordHeader_CODE              CHAR(1) = 'H',		   
		   @Lc_RecordTrailer_CODE             CHAR(1) = 'T',
		   @Lc_TypeAddressMailing_CODE		  CHAR(1) = 'M',
		   @Lc_TypeAddressResidential_CODE    CHAR(1) = 'R',
		   @Lc_Job_ID                         CHAR(7) = 'DEB9000',		   		   		   
		   @Lc_ErrorE0944_CODE                CHAR(18) = 'E0944',
		   @Lc_Successful_TEXT                CHAR(20) = 'SUCCESSFUL',
		   @Lc_WorkerUpdateConv_ID			  CHAR(30) = 'CONVERSION',
		   @Lc_UserBatch_ID                   CHAR(30) = 'BATCH',		   		   
		   @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_LOC_OUTGOING_ADDRNORM',
		   @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_EXTRACT_ADDR_NORM',
		   @Ld_High_DATE					  DATE = '12/31/9999';		   
	DECLARE  @Ln_Zero_NUMB                  NUMERIC(1) = 0,
		   @Ln_CommitFreqParm_QNTY            NUMERIC(5),
		   @Ln_ExceptionThresholdParm_QNTY    NUMERIC(5),
		   @Ln_ProcessedRecordCount_QNTY  NUMERIC(9) = 0,
		   @Ln_Error_NUMB                 NUMERIC(11),
		   @Ln_ErrorLine_NUMB             NUMERIC(11),
		   @Lc_Msg_CODE                   CHAR(1) = '',		   
		   @Lc_FileTotRecCount_TEXT       CHAR(9)='',		   		   
		   @Ls_File_NAME                  VARCHAR(50) = '', 
		   @Ls_FileLocation_TEXT          VARCHAR(80) = '', 
		   @Ls_Sql_TEXT                   VARCHAR(100) = '',
		   @Ls_Query_TEXT                 VARCHAR(1000) = '',
		   @Ls_Sqldata_TEXT               VARCHAR(1000) = '',
		   @Ls_ErrorMessage_TEXT          VARCHAR(4000) = '',
		   @Ls_DescriptionError_TEXT      VARCHAR(4000) = '',		   
		   @Ld_Run_DATE                   DATE,
		   @Ld_LastRun_DATE               DATE,
		   @Ld_Start_DATE                 DATETIME2;
		   	       
	BEGIN TRY
		--Global temprary table creation
		
		SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractAddrNorm_P1';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
		
		--Drop temporary table if exists
		IF OBJECT_ID('tempdb..##ExtractAddrNorm_P1') IS NOT NULL
		BEGIN
			DROP TABLE ##ExtractAddrNorm_P1;
		END
		
		CREATE TABLE ##ExtractAddrNorm_P1
		(
		  Detail_TEXT VARCHAR(180)
		);

		--Begin the transaction to extract data 
		SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
		SET @Ls_Sqldata_TEXT = 'Job_ID = '  + @Lc_Job_ID;
		
		BEGIN TRANSACTION OUTGOING_ADDRNORM;

			--The Batch start time to use while inserting into the batch log
			SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
			SET @Ld_Start_DATE =  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();				
						
   			/*Get the current run date and last run date from the Parameter (PARM_Y1) table, 
   			and validate that the batch program was not executed for the current run date. 
   			Otherwise, an error message to that effect will be written into the Batch Status 
   			Log (BSTL_Y1) table, and the process will terminate.*/					    					
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
						
			EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
				@Ac_Job_ID                  = @Lc_Job_ID,
				@Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
				@Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
				@An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
				@An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
				@As_File_NAME               = @Ls_File_NAME OUTPUT,
				@As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
				@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END;

			 SET @Ld_LastRun_DATE = DATEADD(D, 1, @Ld_LastRun_DATE);
			 SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
			 SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
			 IF @Ld_LastRun_DATE > @Ld_Run_DATE
			 BEGIN
				SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
				RAISERROR(50001,16,1);
			 END

			--DELETE the data from table EADRN_Y1 from the previous run
			SET @Ls_Sql_TEXT = 'DELETE EADRN_Y1';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
			DELETE FROM EADRN_Y1;

			/*Extract all open addresses (those end-dated with a high date) on AHIS_Y1 where the 
			Normalization Code equals spaces and the Worker Update ID is not ‘BATCH’ or ‘CONVERSION’.
			Extract all open addresses (those that are end-dated with a low date) on OTHP_Y1 where 
			the Normalization Code equals spaces and the Worker Update ID is not ‘BATCH’ or ‘CONVERSION’.*/									
			SET @Ls_Sql_TEXT = 'INSERT INTO EADRN_Y1';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

			INSERT EADRN_Y1
				  (TypeRecord_CODE,
				   MemberMci_IDNO,
				   OtherParty_IDNO,
				   AddrOthpType_CODE,
				   TransactionEventSeq_NUMB,
				   Line1_ADDR,
				   Line2_ADDR,
				   City_ADDR,
				   State_ADDR,
				   Zip_ADDR,
				   Country_ADDR,
				   Normalization_CODE)
			SELECT  
				@Lc_TypeRecordAhis_CODE TypeRecord_CODE, 
				a.MemberMci_IDNO, 
				@Lc_Zero_TEXT OtherParty_IDNO, 
				a.TypeAddress_CODE AddrOthpType_CODE, 
				a.TransactionEventSeq_NUMB, 
				a.Line1_ADDR, 
				a.Line2_ADDR, 
				a.City_ADDR, 
				a.State_ADDR, 
				a.Zip_ADDR, 
				a.Country_ADDR, 
				@Lc_Space_TEXT Normalization_CODE
			FROM AHIS_Y1 a
			WHERE 
				a.End_DATE = @Ld_High_DATE
			AND a.Normalization_CODE = @Lc_Space_TEXT
			AND a.TypeAddress_CODE IN (@Lc_TypeAddressMailing_CODE,@Lc_TypeAddressResidential_CODE)
			AND a.WorkerUpdate_ID NOT IN (@Lc_WorkerUpdateConv_ID, @Lc_UserBatch_ID)
			UNION 
			SELECT  
				@Lc_TypeRecordOthp_CODE TypeRecord_CODE, 
				@Lc_Zero_TEXT MemberMci_IDNO,
				o.OtherParty_IDNO, 
				o.TypeOthp_CODE AddrOthpType_CODE,
				o.TransactionEventSeq_NUMB,  
				o.Line1_ADDR, 
				o.Line2_ADDR, 
				o.City_ADDR, 
				o.State_ADDR, 
				o.Zip_ADDR,
				o.Country_ADDR, 
				@Lc_Space_TEXT Normalization_CODE
			FROM OTHP_Y1 o
			WHERE 
				o.EndValidity_DATE = @Ld_High_DATE
			AND o.Normalization_CODE = @Lc_Space_TEXT
			AND o.WorkerUpdate_ID NOT IN (@Lc_WorkerUpdateConv_ID, @Lc_UserBatch_ID);
			
			--Get count of the processsed records	
			SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
												  FROM EADRN_Y1 e
												 WHERE e.TypeRecord_CODE IN (@Lc_TypeRecordAhis_CODE,@Lc_TypeRecordOthp_CODE));
												 
			IF @Ln_ProcessedRecordCount_QNTY = 0
			BEGIN
			 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
			 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
			 SET @Ls_ErrorMessage_TEXT = 'NO RECORDS TO PROCESS';
			 
			 EXECUTE BATCH_COMMON$SP_BATE_LOG
			  @As_Process_NAME             = @Ls_Process_NAME,
			  @As_Procedure_NAME           = @Ls_Procedure_NAME,
			  @Ac_Job_ID                   = @Lc_Job_ID,
			  @Ad_Run_DATE                 = @Ld_Run_DATE,
			  @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
			  @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
			  @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
			  @As_DescriptionError_TEXT	   = @Ls_ErrorMessage_TEXT,
			  @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
			  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			  @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

			 IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			  BEGIN
			   RAISERROR (50001,16,1);
			  END
			END
			ELSE
			BEGIN			   		   			   			   
			   
			   --Write the ADDRESS-EXTRACT header record 			   
			   SET @Ls_Sql_TEXT = 'INSERT HEADER RECORD';
			   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

			   INSERT INTO ##ExtractAddrNorm_P1
						   (Detail_TEXT)
					VALUES ( @Lc_RecordHeader_CODE -- REC-TYPE
					+ CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) --REC-DATE
					+ REPLICATE(@Lc_Space_TEXT, 171) --FILLER 
					);
					 			   		   			   
			   /*Write to the ADDRESS-EXTRACT file with the REC-TYPE equal to ‘A’ (AHIS address), 
			   Member Client Index (MCI) number, Address Type, Transaction Event Sequence Number, 
			   Address Line 1, Line 2, City State, Zip, and Country from AHIS_Y1.*/	
			   SET @Ls_Sql_TEXT = 'INSERT AHIS DETAIL RECORDS';
			   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

			   INSERT INTO ##ExtractAddrNorm_P1
						   (Detail_TEXT)
			   SELECT  LTRIM(RTRIM(a.TypeRecord_CODE)) --REC-TYPE
			   + RIGHT (('0000000000' + LTRIM(RTRIM(a.MemberMci_IDNO))), 10)--MemberMci-NUMB 
			   + LTRIM(RTRIM(a.AddrOthpType_CODE)) --TypeAddress-CODE
			   + RIGHT(('0000000000000000000' + LTRIM(RTRIM(a.TransactionEventSeq_NUMB))),19) --TransactionEventSeq_NUMB
			   + CAST(a.Line1_ADDR AS CHAR(50)) --Line1_ADDR
			   + CAST(a.Line2_ADDR AS CHAR(50)) --Line2_ADDR
			   + CONVERT(CHAR(28), a.City_ADDR) --City_ADDR
			   + CONVERT(CHAR(2), a.State_ADDR) --State_ADDR
			   + CONVERT(CHAR(15), a.Zip_ADDR) --Zip_ADDR
			   + CONVERT(CHAR(2), a.Country_ADDR) --Country_ADDR
			   + CONVERT(CHAR(1), a.Normalization_CODE) --Normalization CODE
			   + REPLICATE(@Lc_Space_TEXT, 1) --FILLER
				 FROM EADRN_Y1 a
				WHERE a.TypeRecord_CODE = @Lc_TypeRecordAhis_CODE;
					
			   /*Write to the ADDRESS-EXTRACT file with the REC-TYPE equal to ‘O’ (OTHP address), 
			   Other Party Identification Number (IDNO), Other Party Type, Transaction Event Sequence Number, 
			   Address Line 1, Address Line 2, City, State, Zip, and Country from OTHP_Y1.*/						
			   SET @Ls_Sql_TEXT = 'INSERT OTHP DETAIL RECORDS';
			   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

			   INSERT INTO ##ExtractAddrNorm_P1
						   (Detail_TEXT)
			   SELECT  LTRIM(RTRIM(o.TypeRecord_CODE)) --REC-TYPE
			   + RIGHT(('000000000' + LTRIM(RTRIM(o.OtherParty_IDNO))), 9) --OTHP_IDNO
			   + REPLICATE(@Lc_Space_TEXT, 1) --FILLER
			   + LTRIM(RTRIM(o.AddrOthpType_CODE)) --TypeOTHP-CODE
			   + RIGHT(('0000000000000000000' + LTRIM(RTRIM(o.TransactionEventSeq_NUMB))),19) --TransactionEventSeq_NUMB
			   + CAST(o.Line1_ADDR AS CHAR(50)) --Line1_ADDR
			   + CAST(o.Line2_ADDR AS CHAR(50)) --Line2_ADDR
			   + CONVERT(CHAR(28), o.City_ADDR) --City_ADDR
			   + CONVERT(CHAR(2), o.State_ADDR) --State_ADDR
			   + CONVERT(CHAR(15), o.Zip_ADDR) --Zip_ADDR
			   + CONVERT(CHAR(2), o.Country_ADDR) --Country_ADDR 
			   + CONVERT(CHAR(1), o.Normalization_CODE) --Normalization CODE
			   + REPLICATE(@Lc_Space_TEXT, 1) --FILLER
				 FROM EADRN_Y1 o
				WHERE o.TypeRecord_CODE = @Lc_TypeRecordOthp_CODE;
			   		   			   
			   /*Write the ADDRESS-EXTRACT trailer record with the Record Count equal to the total 
			   number of records written to the file. */			   
			   SET @Lc_FileTotRecCount_TEXT = RIGHT(('000000000' + LTRIM(RTRIM(@Ln_ProcessedRecordCount_QNTY))), 9);						
			   SET @Ls_Sql_TEXT = 'INSERT TRAILER RECORD';
			   SET @Ls_Sqldata_TEXT = 'Rec_TYPE = ' + @Lc_RecordTrailer_CODE + ', Rec_COUNT = ' + @Lc_FileTotRecCount_TEXT;			   			   
			   
			   INSERT INTO ##ExtractAddrNorm_P1
					VALUES (@Lc_RecordTrailer_CODE --REC-TYPE
					+ CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) --REC-DATE
					+ @Lc_FileTotRecCount_TEXT  --REC-COUNT
					+ REPLICATE(@Lc_Space_TEXT, 162) --FILLER 
					); 
					
			   --Commit the transaction
			   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
			   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;		
			     			   
			   COMMIT TRANSACTION OUTGOING_ADDRNORM;
			   
		   --Extracting data from #temp table into file		  
		   SET @Ls_Query_TEXT = 'SELECT Detail_TEXT FROM ##ExtractAddrNorm_P1';
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
		   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;
		   
		   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
			@As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
			@As_File_NAME             = @Ls_File_NAME,
			@As_Query_TEXT            = @Ls_Query_TEXT,
			@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
			
		   --Procedure execution status check				
		   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END;	
			
			SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
			SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

			BEGIN TRANSACTION OUTGOING_ADDRNORM;	   
		END			  		  		
		
		--Update the last run date in the PARM_Y1 table with the current run date upon successful completion.
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
		SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

		EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
		@Ac_Job_ID                = @Lc_Job_ID,
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
		
		--Procedure execution status check
		IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		 RAISERROR (50001,16,1);
		END

		--Log the error encountered or successful completion in BSTL_Y1 for future references.
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', WorkerUpdate_ID = ' + @Lc_UserBatch_ID;

		EXECUTE BATCH_COMMON$SP_BSTL_LOG
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@Ad_Start_DATE            = @Ld_Start_DATE,
		@Ac_Job_ID                = @Lc_Job_ID,
		@As_Process_NAME          = @Ls_Process_NAME,
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_CursorLocation_TEXT   = @Lc_Space_TEXT,
		@As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
		@As_ListKey_TEXT          = @Lc_Successful_TEXT,
		@As_DescriptionError_TEXT = @Lc_Space_TEXT,
		@Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
		@Ac_Worker_ID             = @Lc_UserBatch_ID,
		@An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

		--Drop the temporary table used to store data
		SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractAddrNorm_P1 - 2';
		SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

		DROP TABLE ##ExtractAddrNorm_P1;		

		--Commit the transaction
		SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
		SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

		COMMIT TRANSACTION OUTGOING_ADDRNORM;
	END TRY

	BEGIN CATCH
		--Check if active transaction exists for this session then rollback the transaction
		IF @@TRANCOUNT > 0
		BEGIN
		 ROLLBACK TRANSACTION OUTGOING_ADDRNORM;
		END;

		--Check if temporary table exists drop the table
		IF OBJECT_ID('tempdb..##ExtractAddrNorm_P1') IS NOT NULL
		BEGIN
		 DROP TABLE ##ExtractAddrNorm_P1;
		END

		--Check for Exception information to log the description text based on the error
		SET @Ln_Error_NUMB = ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE();		

		IF @Ln_Error_NUMB <> 50001
		BEGIN
		 SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
		END

		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
		@As_Sql_TEXT              = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
		@An_Error_NUMB            = @Ln_Error_NUMB,
		@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		EXECUTE BATCH_COMMON$SP_BSTL_LOG
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@Ad_Start_DATE            = @Ld_Start_DATE,
		@Ac_Job_ID                = @Lc_Job_ID,
		@As_Process_NAME          = @Ls_Process_NAME,
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_CursorLocation_TEXT   = @Lc_Space_TEXT,
		@As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
		@As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
		@Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
		@Ac_Worker_ID             = @Lc_UserBatch_ID,
		@An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

		RAISERROR (@Ls_DescriptionError_TEXT,16,1);
	END CATCH
	END

GO
