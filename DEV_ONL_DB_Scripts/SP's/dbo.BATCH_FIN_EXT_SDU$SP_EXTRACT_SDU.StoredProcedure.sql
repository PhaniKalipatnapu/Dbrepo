/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_SDU$SP_EXTRACT_SDU]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_EXT_SDU$SP_EXTRACT_SDU
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_EXT_SDU$SP_EXTRACT_SDU reads the data From CMEM_Y1 and ENSD_Y1 Tables 
					  and create a TEXT file to be sent to SDU for daily submission of the entire case load.
Frequency			: 'DAILY'
Developed On		: 01/09/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_SDU$SP_EXTRACT_SDU]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_FosterCareMci_IDNO			 NUMERIC(6)= 999998,
		  @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE         CHAR(1) = 'A',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusCaseOpen_CODE            CHAR(1) = 'O',
          @Lc_StatusCaseClosed_CODE          CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
		  @Lc_TypeErrorWarning_CODE			 CHAR(1) = 'W',
		  @Lc_CheckRecipientTypeCpNcp_CODE   CHAR(1) = '1',
		  @Lc_TypeRecoupmentRegular_CODE     CHAR(1) = 'R',
          @Lc_RecordTypeDetail05_CODE        CHAR(2) = '05',
          @Lc_RecordTypeTrailer10_CODE       CHAR(2) = '10',
          @Lc_StateFips10_CODE               CHAR(2) = '10',
          @Lc_CountyDefault_TEXT             CHAR(3) = '000',
          @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
		  @Lc_ErrorNoRecordsE0944_CODE		 CHAR(5) = 'E0944',
          @Lc_Job_ID                         CHAR(7) = 'DEB0750',
          @Lc_TrailerDefaultCount_TEXT       CHAR(7) = '0000000',
		  @Lc_ZeroSsn_TEXT                   CHAR(9) = '000000000',
          @Lc_ZeroMci_IDNO                   CHAR(10) = '0000000000',
          @Lc_Successful_TEXT                CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT           VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_FIN_EXT_SDU',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_EXTRACT_SDU';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RowCount_QNTY               NUMERIC(7),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_FileTotRecCount_TEXT        CHAR(7),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   -- The Batch start time to use while inserting into the batch log
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   -- Temp Table Creation for Extract
   SET @Ls_Sql_TEXT = 'CREATE ##ExtSdu_P1';
   SET @Ls_Sqldata_TEXT = '';
   CREATE TABLE ##ExtSdu_P1
    (
      Seq_IDNO NUMERIC IDENTITY(1, 1),
      Record_TEXT VARCHAR(188)
    );

   -- Begin the transaction to extract data
   BEGIN TRANSACTION ExtSduTran;

   -- Get date run, date last run, commit freq, exception threshold details
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

   -- Procedure execution status check
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   -- RUN DATE AND LAST RUN DATE VALIDATION
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;
     RAISERROR (50001,16,1);
    END;

   -- Delete the data from the table EXSDU_Y1 from the previous run
   SET @Ls_Sql_TEXT = 'DELETE EXSDU_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM EXSDU_Y1;

   -- Extract and NCP records for all cases into EXSDU_Y1 table 
   SET @Ls_Sql_TEXT = 'INSERT EXSDU_Y1 - NCP';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO EXSDU_Y1
               (County_IDNO,
                MemberMci_IDNO,
                File_ID,
                MemberSsn_NUMB,
                First_NAME,
                Middle_NAME,
                Last_NAME,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Country_ADDR,
                Zip1_ADDR,
                Zip2_ADDR,
                Case_IDNO)
   SELECT RIGHT(@Lc_CountyDefault_TEXT + CAST (A.County_IDNO AS VARCHAR), 3) AS County_IDNO,
          RIGHT(@Lc_ZeroMci_IDNO + CAST (C.MemberMci_IDNO AS VARCHAR), 10) AS MemberMci_IDNO,
          LTRIM(RTRIM(A.File_ID)) AS File_ID,
          A.VerifiedltinNcpOrpfSsn_NUMB AS MemberSsn_NUMB,
          LTRIM(RTRIM(A.FirstNcp_NAME)) AS First_NAME,
          LEFT(LTRIM(RTRIM(A.MiddleNcp_NAME)), 1) AS Middle_NAME,
          LTRIM(RTRIM(A.LastNcp_NAME)) AS Last_NAME,
          LEFT(LTRIM(RTRIM(A.Line1Ncp_ADDR)), 25) AS Line1_ADDR,
          LEFT(LTRIM(RTRIM(A.Line2Ncp_ADDR)), 25) AS Line2_ADDR,
          LEFT(LTRIM(RTRIM(A.CityNcp_ADDR)), 20) AS City_ADDR,
          LTRIM(RTRIM(A.StateNcp_ADDR)) AS State_ADDR,
          LTRIM(RTRIM(A.CountryNcp_ADDR)) AS Country_ADDR,
          LEFT(A.ZipNcp_ADDR, 5) AS Zip1_ADDR,
          SUBSTRING (A.ZipNcp_ADDR, 6, 4) AS Zip2_ADDR,
          A.Case_IDNO
     FROM ENSD_Y1 A,
          CMEM_Y1 C
    WHERE (A.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
            OR (A.StatusCase_CODE = @Lc_StatusCaseClosed_CODE
                AND A.ArrearsReg_AMNT > 0))
      AND A.NcpPf_IDNO <> 0
      AND A.Case_IDNO = C.Case_IDNO
      AND A.NcpPf_IDNO = C.MemberMci_IDNO
      AND C.MemberMci_IDNO <>  @Ln_FosterCareMci_IDNO   
      AND C.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
      AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
    ORDER BY A.Case_IDNO;

   -- Extract and Insert the CP records into EXSDU_Y1 table 
   SET @Ls_Sql_TEXT = 'INSERT EXSDU_Y1 - CP';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO EXSDU_Y1
               (County_IDNO,
                MemberMci_IDNO,
                File_ID,
                MemberSsn_NUMB,
                First_NAME,
                Middle_NAME,
                Last_NAME,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Country_ADDR,
                Zip1_ADDR,
                Zip2_ADDR,
                Case_IDNO)
   SELECT RIGHT(@Lc_CountyDefault_TEXT + CAST (A.County_IDNO AS VARCHAR), 3) AS County_IDNO,
          RIGHT(@Lc_ZeroMci_IDNO + CAST (C.MemberMci_IDNO AS VARCHAR), 10) AS MemberMci_IDNO,
          LTRIM(RTRIM(A.File_ID)) AS File_ID,
          A.VerifiedItinCpSsn_NUMB AS MemberSsn_NUMB,
          LTRIM(RTRIM(A.FirstCp_NAME)) AS First_NAME,
          LEFT(LTRIM(RTRIM(A.MiddleCp_NAME)), 1) AS Middle_NAME,
          LTRIM(RTRIM(A.LastCp_NAME)) AS Last_NAME,
          LEFT(LTRIM(RTRIM(A.Line1Cp_ADDR)), 25) AS Line1_ADDR,
          LEFT(LTRIM(RTRIM(A.Line2Cp_ADDR)), 25) AS Line2_ADDR,
          LEFT(LTRIM(RTRIM(A.CityCp_ADDR)), 20) AS City_ADDR,
          LTRIM(RTRIM(A.StateCp_ADDR)) AS State_ADDR,
          LTRIM(RTRIM(A.CountryCp_ADDR)) AS Country_ADDR,
          LEFT(A.ZipCp_ADDR, 5) AS Zip1_ADDR,
          SUBSTRING (A.ZipCp_ADDR, 6, 4) AS Zip2_ADDR,
          A.Case_IDNO
     FROM ENSD_Y1 A,
          CMEM_Y1 C
    WHERE A.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND A.CpMci_IDNO <> 0
      AND A.Case_IDNO = C.Case_IDNO
      AND C.MemberMci_IDNO = A.CpMci_IDNO
      AND C.MemberMci_IDNO <>  @Ln_FosterCareMci_IDNO
      AND C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
      AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      -- CR0293 - Modified SDU participant file to include only CPs with active recoupment balance or pednig recoupment balance
      AND EXISTS (
		   SELECT 1
			 FROM POFL_Y1 d
			WHERE d.CheckRecipient_ID = CAST(A.CpMci_IDNO AS VARCHAR)
			  AND d.CheckRecipient_CODE = @Lc_CheckRecipientTypeCpNcp_CODE 
			  AND d.TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE
			  AND d.Unique_IDNO = (SELECT MAX (e.Unique_IDNO)
									 FROM POFL_Y1 e
									WHERE e.CheckRecipient_ID = d.CheckRecipient_ID
									  AND e.CheckRecipient_CODE = d.CheckRecipient_CODE
									  AND e.TypeRecoupment_CODE = d.TypeRecoupment_CODE
									  AND e.RecoupmentPayee_CODE = d.RecoupmentPayee_CODE
								  )
			 HAVING (SUM(d.PendTotOffset_AMNT) > 0) OR (SUM(d.AssessTotOverpay_AMNT - d.RecTotOverpay_AMNT) > 0)
		 )     
    ORDER BY A.Case_IDNO;

   -- Insert the data into the Temporary table by concatinating the information in the file writing format
   SET @Ls_Sql_TEXT = 'INSERT ##ExtSdu_P1';
   SET @Ls_Sqldata_TEXT = '';
   
   INSERT INTO ##ExtSdu_P1
               (Record_TEXT)
   SELECT (@Lc_RecordTypeDetail05_CODE + @Lc_StateFips10_CODE + CONVERT (CHAR(3), County_IDNO) + RIGHT ((@Lc_ZeroMci_IDNO + LTRIM(RTRIM(MemberMci_IDNO))), 10) + CONVERT (CHAR(11), File_ID) + RIGHT (@Lc_ZeroSsn_TEXT + CAST(LTRIM(RTRIM(MemberSsn_NUMB)) AS VARCHAR),9) + CONVERT(CHAR(20), First_NAME) + CONVERT(CHAR(1), Middle_NAME) + CONVERT(CHAR(20), Last_NAME) + CONVERT(CHAR(25), Line1_ADDR) + CONVERT(CHAR(25), Line2_ADDR) + CONVERT(CHAR(20), City_ADDR) + CONVERT(CHAR(2), State_ADDR) + CONVERT(CHAR(20), Country_ADDR) + CONVERT(CHAR(5), Zip1_ADDR) + CONVERT(CHAR(4), Zip2_ADDR) + CONVERT(CHAR(6), Case_IDNO) + REPLICATE(@Lc_Space_TEXT, 3))
     FROM EXSDU_Y1 a
    ORDER BY Case_IDNO,
             MemberMci_IDNO;

   --Rowcount information to append that to the file footer with record type
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
   SET @Lc_FileTotRecCount_TEXT = RIGHT((@Lc_TrailerDefaultCount_TEXT + LTRIM(RTRIM(@Ln_RowCount_QNTY))), 7);
   SET @Ls_Sql_TEXT = 'INSERT ##ExtSdu_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'RECORD TYPE = ' + @Lc_RecordTypeTrailer10_CODE + ', FILE RECORD COUNT = ' + @Lc_FileTotRecCount_TEXT;

   INSERT INTO ##ExtSdu_P1
               (Record_TEXT)
        VALUES ( @Lc_RecordTypeTrailer10_CODE + @Lc_FileTotRecCount_TEXT + REPLICATE(@Lc_Space_TEXT, 179) );

   COMMIT TRANSACTION ExtSduTran;
   
   SET @Ls_Sql_TEXT = 'SELECT COUNT EXSDU_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM EXSDU_Y1 a;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL('0','')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorNoRecordsE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_ErrorNoRecordsE0944_CODE,
      @As_DescriptionError_TEXT	   = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   -- Data Extraction to a File
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtSdu_P1 ORDER BY Seq_IDNO ASC';
   SET @Ls_Sqldata_TEXT ='FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME =  ' + @Ls_File_NAME + ', Query_TEXT =  ' + @Ls_Query_TEXT + '';

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   -- Procedure execution status check
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Update the run date information
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   -- Procedure execution status check
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Log the batch execution information
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop the temporary table used to store data
   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtSdu_P1 - 2';

   DROP TABLE ##ExtSdu_P1;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtSduTran;
    END

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..##ExtSdu_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtSdu_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
	   SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END
   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
