/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_GAA_REFERRALS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_LOAD_GAA_REFERRALS
Programmer Name	:	IMP Team.
Description		:	This process reads the data from IV-A[DCIS II Tables] and loads the data into the temporary table
					for general assistance referrals.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
					BATCH_COMMON$SP_BATE_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_LOAD_GAA_REFERRALS]
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  -- Common Variables
  DECLARE @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE   CHAR(1) = 'W',
          @Lc_ProcessN_CODE           CHAR(1) = 'N',
          @Lc_ProcessY_CODE           CHAR(1) = 'Y',
          @Lc_SubProgramA_CODE        CHAR(1) = 'A',
          @Lc_AgPayeeSwitch_INDC      CHAR(1) = 'Y',
          @Lc_CurrentEligIndc1_CODE   CHAR(1) = '1',
          @Lc_CurrentEligIndc9_CODE   CHAR(1) = '9',
          @Lc_AgStatus_CODE           CHAR(1) = 'O',
          @Lc_AddrNormalizationU_CODE CHAR(1) = 'U',
          @Lc_CaseMemberStatusA_CODE  CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE     CHAR(1) = 'O',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_PartStatusEA_CODE       CHAR(2) = 'EA',
          @Lc_ProgramGa_CODE          CHAR(2) = 'GA',
          @Lc_LinkedServer_CODE       CHAR(3) = 'DB2',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_Job_ID                  CHAR(7) = 'DEB9903',
          @Lc_ErrorE0944_CODE         CHAR(18) = 'E0944',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_GAA_REFERRALS',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_CursorLocation_TEXT     VARCHAR(200) = ' ';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Lc_LinkedServerQualifier_TEXT  CHAR(8) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_OpenQuery_TEXT              NVARCHAR(MAX),
          @Ls_TransactionSql_TEXT         NVARCHAR(MAX),
          @Ld_Run_DATE                    DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_LastRun_DATE                DATETIME2;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'SELECT QUALIFIER';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   SELECT @Lc_LinkedServerQualifier_TEXT = e.Database_NAME
     FROM ENVG_Y1 e;

   IF ISNULL(@Lc_LinkedServerQualifier_TEXT, '') = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'Invalid Linked Server Qualifier';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LinkedServerQualifier_TEXT = ' + ISNULL(@Lc_LinkedServerQualifier_TEXT, '') + ', LinkedServer_CODE = ' + ISNULL(@Lc_LinkedServer_CODE, '');

     RAISERROR (50001,16,1);
    END

   -- Selecting Date Run, Date Last Run, Commit Freq, Exception Threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
    END;

   --Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   -- Transaction begins
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION GADT_LOAD;

   --Delete Processed Records in LOAD job:
   SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LGADT_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_CODE, '');

   DELETE LGADT_Y1
    WHERE Process_INDC = @Lc_ProcessY_CODE;

   SET @Ls_OpenQuery_TEXT = 'SELECT DISTINCT
									CAST(CpMci_IDNO AS VARCHAR) AS CpMci_IDNO,
									''' + @Lc_AddrNormalizationU_CODE + ''' AS AddrNormalization_CODE,
									SUBSTRING(RTRIM(LTRIM(REPLACE(ST_NUMBER_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(UNIT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(DIRECTION_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(ST_RURAL_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(SUFFIX_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(QUADRANT_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') + ''' + @Lc_Space_TEXT + ''' + REPLACE(APARTMENT_ADR,CHAR(0),''' + @Lc_Space_TEXT + '''))),1,50) AS CpLine1_ADDR,
									REPLACE(LINE_2_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpLine2_ADDR,
									REPLACE(CITY_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpCity_ADDR,
									REPLACE(STATE_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpState_ADDR,
									REPLACE(ZIP_ADR,CHAR(0),''' + @Lc_Space_TEXT + ''') AS CpZip_ADDR,
									''' + CAST(@Ld_Run_DATE AS VARCHAR) + ''' AS FileLoad_DATE,
									''' + @Lc_ProcessN_CODE + ''' AS Process_INDC
							  FROM OPENQUERY(' + @Lc_LinkedServer_CODE + ',''';
   SET @Ls_TransactionSql_TEXT = 'SELECT DISTINCT
						      				a.MCI_NUM "CpMci_IDNO",
						      				COALESCE(STRIP(e.ST_NUMBER_ADR),''''' + @Lc_Space_TEXT + ''''') "ST_NUMBER_ADR",
						      				COALESCE(STRIP(e.UNIT_ADR),''''' + @Lc_Space_TEXT + ''''') "UNIT_ADR",
						      				COALESCE(STRIP(e.DIRECTION_ADR),''''' + @Lc_Space_TEXT + ''''') "DIRECTION_ADR",
						      				COALESCE(STRIP(e.ST_RURAL_ADR),''''' + @Lc_Space_TEXT + ''''') "ST_RURAL_ADR",
						      				COALESCE(STRIP(e.SUFFIX_ADR),''''' + @Lc_Space_TEXT + ''''') "SUFFIX_ADR",
						      				COALESCE(STRIP(e.QUADRANT_ADR),''''' + @Lc_Space_TEXT + ''''') "QUADRANT_ADR",
						      				COALESCE(STRIP(e.APARTMENT_ADR),''''' + @Lc_Space_TEXT + ''''') "APARTMENT_ADR",
						      				COALESCE(STRIP(e.LINE_2_ADR),''''' + @Lc_Space_TEXT + ''''') "LINE_2_ADR",
						      				COALESCE(STRIP(e.CITY_ADR),''''' + @Lc_Space_TEXT + ''''') "CITY_ADR",
						      				COALESCE(STRIP(e.STATE_ADR),''''' + @Lc_Space_TEXT + ''''') "STATE_ADR",
						      				COALESCE(STRIP(e.ZIP_ADR),''''' + @Lc_Space_TEXT + ''''') "ZIP_ADR"
									   FROM ' + @Lc_LinkedServerQualifier_TEXT + '.T0265_AG_IN_ELIG a
									   LEFT JOIN ' + @Lc_LinkedServerQualifier_TEXT + '.T0001_CASE e ON e.CASE_NUM = a.CASE_NUM
									  WHERE a.AG_STS_CD = ''''' + @Lc_AgStatus_CODE + '''''
									    AND a.PROGRAM_CD = ''''' + @Lc_ProgramGa_CODE + ''''' 
									    AND a.SUBPROGRAM_CD = ''''' + @Lc_SubProgramA_CODE + '''''
									    AND a.PART_STS_CD = ''''' + @Lc_PartStatusEA_CODE + '''''
									    AND a.CURRENT_ELIG_IND IN (''''' + @Lc_CurrentEligIndc1_CODE + ''''',''''' + @Lc_CurrentEligIndc9_CODE + ''''')
									    AND a.AG_PAYEE_SW = ''''' + @Lc_AgPayeeSwitch_INDC + '''''
									    AND a.PAYMENT_BEGIN_DT BETWEEN ''''' + CAST(DATEADD(D, 1, @Ld_LastRun_DATE) AS VARCHAR(10)) + ''''' AND ''''' + CAST(@Ld_Run_DATE AS VARCHAR(10)) + '''''
									    AND a.PAYMENT_END_DT > a.PAYMENT_BEGIN_DT
									  ORDER BY a.MCI_NUM '') 
								   WHERE EXISTS (SELECT 1 
								                FROM DEMO_Y1 d,
												     CMEM_Y1 m,
													 CASE_Y1 c
									           WHERE d.MemberMci_IDNO = CpMci_IDNO
											     AND d.MemberMci_IDNO = m.MemberMci_IDNO
												 AND m.Case_IDNO = c.Case_IDNO
												 AND m.CaseMemberStatus_CODE = ''' + @Lc_CaseMemberStatusA_CODE + '''
												 AND c.StatusCase_CODE = ''' + @Lc_StatusCaseOpen_CODE + ''')';
   SET @Ls_Sql_TEXT = 'INSERT LGADT_Y1 CASE IN TRIGGER ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT LGADT_Y1
          (MemberMci_IDNO,
           AddrNormalization_CODE,
           Line1_ADDR,
           Line2_ADDR,
           City_ADDR,
           State_ADDR,
           Zip_ADDR,
           FileLoad_DATE,
           Process_INDC)
   EXECUTE (@Ls_OpenQuery_TEXT+@Ls_TransactionSql_TEXT);

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     -- Zero records to load.
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Update the Log in BSTL_Y1 as the Job is succeeded.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrorMessage_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Transaction Ends
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION GADT_LOAD;
  END TRY

  --Exception Begins
  BEGIN CATCH
   ---If Transaction is not committed, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION GADT_LOAD;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   --Update the Log in BSTL_Y1 as the Job is failed.
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
