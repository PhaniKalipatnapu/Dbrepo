/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_W4NEWHIRE$SP_LOAD_NEWHIRE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_W4NEWHIRE$SP_LOAD_NEWHIRE
Programmer Name   :	IMP Team
Description       :	This process reads the incoming file provided by State New Hire and loads them 
					into a temporary match table (LW4NH_Y1).
Frequency         :	Daily.
Developed On      :	11/01/2011
Called By         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_W4NEWHIRE$SP_LOAD_NEWHIRE]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
           @Lc_StatusFailed_CODE       CHAR(1) = 'F',
           @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
           @Lc_TypeErrorWarning_CODE   CHAR(1) = 'W',
           @Lc_DetailRecordType_CODE   CHAR(1) = '2',
           @Lc_Space_TEXT              CHAR(1) = ' ',
           @Lc_ProcessN_INDC           CHAR(1) = 'N',
           @Lc_ProcessY_INDC           CHAR(1) = 'Y',
           @Lc_HeaderRecordType_CODE   CHAR(2) = '1',
           @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
           @Lc_Job_ID                  CHAR(7) = 'DEB0280',
           @Lc_ErrorE0944_CODE         CHAR(18) = 'E0944',
           @Lc_Successful_INDC         CHAR(20) = 'SUCCESSFUL',
           @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_NEWHIRE',
           @Ls_Process_NAME            VARCHAR(100) = 'BATCH_LOC_INCOMING_W4NEWHIRE';
  DECLARE  @Ln_Zero_NUMB					  NUMERIC(1) = 0,
           @Ln_CommitFreqParm_QNTY				  NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY    NUMERIC(5),
           @Ln_ProcessedRecordCount_QNTY  NUMERIC(10),
           @Ln_Error_NUMB                 NUMERIC(11),
           @Ln_ErrorLine_NUMB             NUMERIC(11),
           @Lc_Msg_CODE                   CHAR(1) = '',
           @Ls_File_NAME                  VARCHAR(60),
           @Ls_FileLocation_TEXT          VARCHAR(80),
           @Ls_FileSource_TEXT            VARCHAR(130),
           @Ls_SqlStmnt_TEXT              VARCHAR(200) = '',
           @Ls_Sql_TEXT                   VARCHAR(200) = '',
           @Ls_CursorLocation_TEXT        VARCHAR(200),
           @Ls_Sqldata_TEXT               VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT      VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT          VARCHAR(4000) = '',
           @Ld_Run_DATE                   DATE,
           @Ld_LastRun_DATE               DATE,
           @Ld_Start_DATE                 DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;
   
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadNewhire_P1
    (
      Record_TEXT VARCHAR (676)
    );

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAME ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadNewhire_P1 FROM ''' + @Ls_FileSource_TEXT + '''';
   
   EXECUTE (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION NEWHIRE_LOAD;
       SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS FROM LW4NH_Y1 TABLE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_INDC = ' + @Lc_ProcessY_INDC;

       DELETE LW4NH_Y1
        WHERE Process_INDC = @Lc_ProcessY_INDC;
       
   SET @Ls_Sql_TEXT = 'RECORD DETAILS COUNT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = '+ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_ProcessedRecordCount_QNTY=COUNT (1)
     FROM #LoadNewhire_P1 a
    WHERE SUBSTRING(Record_TEXT, 1, 1)=@Lc_DetailRecordType_CODE;
 
   IF @Ln_ProcessedRecordCount_QNTY <> 0
     BEGIN
       SET @Ls_Sql_TEXT = 'INSERT LW4NH_Y1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       INSERT INTO LW4NH_Y1
                 (Rec_ID,
				  Last_Name,
				  First_NAME,
				  Middle_NAME,
				  Line1Old_ADDR,
				  Line2Old_ADDR,
				  CityOld_ADDR,
				  StateOld_ADDR,
				  Zip1Old_ADDR,
				  Zip2Old_ADDR,
				  MemberSsn_NUMB,
				  Hire_DATE,
				  LeftEmpTemp_INDC,
				  Birth_DATE,
				  MemberSex_CODE,
				  StateHire_CODE,
				  Employer_Name,
				  EmployerLine1Old_ADDR,
				  EmployerLine2Old_ADDR,
				  EmployerCityOld_ADDR,
				  EmployerStateOld_ADDR,
				  EmployerZip1Old_ADDR,
				  EmployerZip2Old_ADDR,
				  Fein_IDNO,
				  FederalTaxType_CODE,
				  FederalTaxVerification_CODE,
				  Batch_NUMB,
				  EmployeeCountry_CODE,
				  EmployeeCountry_NAME,
				  EmployeeCountryZip_CODE,
				  EmployerCountry_CODE,
				  EmployerCountry_NAME,
				  EmployerCountryZip_CODE,
				  Normalization_CODE,
				  Line1_ADDR,
				  Line2_ADDR,
				  City_ADDR,
				  State_ADDR,
				  Zip_ADDR,
				  NormalizationEmployer_CODE,
				  EmployerLine1_ADDR,
				  EmployerLine2_ADDR,
				  EmployerCity_ADDR,
				  EmployerState_ADDR,
				  EmployerZip_ADDR,
				  FileLoad_DATE,
				  Process_INDC                 
                 )
		 SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1,  1), @Lc_Space_TEXT))) AS Rec_ID,  --Rec_ID
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 2, 15), @Lc_Space_TEXT))) AS Last_Name,  --Last_Name
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 17,15), @Lc_Space_TEXT))) AS First_NAME,  --First_NAME
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 32, 1), @Lc_Space_TEXT))) AS Middle_NAME,  --Middle_NAME
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 33, 30), @Lc_Space_TEXT))) AS Line1Old_ADDR,  --Line1Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 63, 30), @Lc_Space_TEXT))) AS Line2Old_ADDR,  --Line2Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 93, 15), @Lc_Space_TEXT))) AS CityOld_ADDR,  --CityOld_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 108, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,  --StateOld_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 110, 5), @Lc_Space_TEXT))) AS Zip1Old_ADDR,  --Zip1Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 115, 4), @Lc_Space_TEXT))) AS Zip2Old_ADDR,  --Zip2Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 119, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,  --MemberSsn_NUMB
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 128, 8), @Lc_Space_TEXT))) AS Hire_DATE,  --Hire_DATE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 136, 1), @Lc_Space_TEXT))) AS LeftEmpTemp_INDC,  --LeftEmpTemp_INDC
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 137, 8), @Lc_Space_TEXT))) AS Birth_DATE,  --Birth_DATE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 145, 1), @Lc_Space_TEXT))) AS MemberSex_CODE,  --MemberSex_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 146, 2), @Lc_Space_TEXT))) AS StateHire_CODE,  --StateHire_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 148, 30), @Lc_Space_TEXT))) AS Employer_Name,  --Employer_Name
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 178, 30), @Lc_Space_TEXT))) AS EmployerLine1Old_ADDR,  --EmployerLine1Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 208, 30), @Lc_Space_TEXT))) AS EmployerLine2Old_ADDR,  --EmployerLine2Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 238, 15), @Lc_Space_TEXT))) AS EmployerCityOld_ADDR,  --EmployerCityOld_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 253, 2), @Lc_Space_TEXT))) AS EmployerStateOld_ADDR,  --EmployerStateOld_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 255, 5), @Lc_Space_TEXT))) AS EmployerZip1Old_ADDR,  --EmployerZip1Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 260, 4), @Lc_Space_TEXT))) AS EmployerZip2Old_ADDR,  --EmployerZip2Old_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 264, 9), @Lc_Space_TEXT))) AS Fein_IDNO,  --Fein_IDNO
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 273, 1), @Lc_Space_TEXT))) AS FederalTaxType_CODE,  --FederalTaxType_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 274, 1), @Lc_Space_TEXT))) AS FederalTaxVerification_CODE,  --FederalTaxVerification_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 273, 9), @Lc_Space_TEXT))) AS Batch_NUMB,  --Batch_NUMB
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 301, 2), @Lc_Space_TEXT))) AS EmployeeCountry_CODE,  --EmployeeCountry_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 303,25), @Lc_Space_TEXT))) AS EmployeeCountry_NAME,  --EmployeeCountry_NAME
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 328,15), @Lc_Space_TEXT))) AS EmployeeCountryZip_CODE,  --EmployeeCountryZip_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 343, 2), @Lc_Space_TEXT))) AS EmployerCountry_CODE,  --EmployerCountry_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 345,25), @Lc_Space_TEXT))) AS EmployerCountry_NAME,  --EmployerCountry_NAME
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 370,15), @Lc_Space_TEXT))) AS EmployerCountryZip_CODE,  --EmployerCountryZip_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 385, 1), @Lc_Space_TEXT))) AS Normalization_CODE,  --Normalization_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 386,50), @Lc_Space_TEXT))) AS Line1_ADDR,  --Line1_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 436,50), @Lc_Space_TEXT))) AS Line2_ADDR,  --Line2_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 486,28), @Lc_Space_TEXT))) AS City_ADDR,  --City_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 514, 2), @Lc_Space_TEXT))) AS State_ADDR,  --State_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 516,15), @Lc_Space_TEXT))) AS Zip_ADDR,  --Zip_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 531, 1), @Lc_Space_TEXT))) AS NormalizationEmployer_CODE,  --NormalizationEmployer_CODE
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 532,50), @Lc_Space_TEXT))) AS EmployerLine1_ADDR,  --EmployerLine1_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 582,50), @Lc_Space_TEXT))) AS EmployerLine2_ADDR,  --EmployerLine2_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 632,28), @Lc_Space_TEXT))) AS EmployerCity_ADDR,  --EmployerCity_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 660, 2), @Lc_Space_TEXT))) AS EmployerState_ADDR,  --EmployerState_ADDR
				(RTRIM(ISNULL(SUBSTRING(Record_TEXT, 662,15), @Lc_Space_TEXT))) AS EmployerZip_ADDR,  --EmployerZip_ADDR
				@Ld_Run_DATE AS FileLoad_DATE,
				@Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadNewhire_P1 a
      WHERE (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1,  1), @Lc_Space_TEXT))) = @Lc_DetailRecordType_CODE;
      END
   ELSE
     BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

	   EXECUTE BATCH_COMMON$SP_BATE_LOG
	    @As_Process_NAME             = @Ls_Process_NAME,
	    @As_Procedure_NAME           = @Ls_Procedure_NAME,
	    @Ac_Job_ID                   = @Lc_Job_ID,
	    @Ad_Run_DATE                 = @Ld_Run_DATE,
	    @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
	    @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
	    @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
	    @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
	    @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
	    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
	    @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_INDC,
    @As_ListKey_TEXT          = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #LoadNewhire_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION NEWHIRE_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NEWHIRE_LOAD;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadNewhire_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadNewhire_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
