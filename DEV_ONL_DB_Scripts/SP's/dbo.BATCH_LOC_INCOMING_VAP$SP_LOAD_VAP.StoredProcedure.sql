/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_VAP$SP_LOAD_VAP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_INCOMING_VAP$SP_LOAD_VAP
Programmer Name 	: IMP Team
Description         : The procedure BATCH_LOC_INCOMING_VAP$SP_LOAD_VAP receives the Voluntary Acknowledgement of Paternity (VAP) data 
					  and Denial of Paternity (DOP) from the Office of Vital Statistics (OVS), and loads the data into a temporary table for processing. 
					  The process then reads the temporary table and loads the data into the VAPP â€“ Voluntary Acknowledgment of Paternity Process tables.
Frequency			: 'WEEKLY'
Developed On		: 07/11/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_VAP$SP_LOAD_VAP]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE CHAR(1) = 'A',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_Job_ID                 CHAR(7) = 'DEB9301',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT   CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_VAP',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_VAP';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_BulkInsertSql_TEXT          VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(2000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE #LoadVapp_P1';

   CREATE TABLE #LoadVapp_P1
    (
      Record_TEXT CHAR(1929)
    );

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_LOAD_VAP';

   BEGIN TRANSACTION TXN_LOAD_VAP;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF LEN(@Ls_FileSource_TEXT) = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_BulkInsertSql_TEXT = 'BULK INSERT #LoadVapp_P1 FROM ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_SqlData_TEXT = '';

   EXEC (@Ls_BulkInsertSql_TEXT);

   SET @Ls_Sql_TEXT = 'SELECT FROM #LoadVapp_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM #LoadVapp_P1 A;

   SET @Ls_Sql_TEXT='DELETE LVAPP_Y1';
   SET @Ls_SqlData_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE FROM LVAPP_Y1
    WHERE Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO LOAD INTO LVAPP_Y1';

   IF @Ln_RecordCount_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT LVAPP_Y1';
     SET @Ls_SqlData_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '');

     INSERT INTO LVAPP_Y1
                 (ChildBirth_DATE,
                  ChildFirst_NAME,
                  ChildMiddle_NAME,
                  ChildLast_NAME,
                  ChildSex_CODE,
                  ChildBirthCity_NAME,
                  ChildCountyBirth_IDNO,
                  ChildBirth_CODE,
                  ChildBirthFacility_CODE,
                  ChildBirthFacility_NAME,
                  ChildBirthCertificate_ID,
                  MotherFirst_NAME,
                  MotherMiddle_NAME,
                  MotherLast_NAME,
                  MotherMaiden_NAME,
                  MotherSsn_NUMB,
                  MotherBirth_DATE,
                  MotherRace_CODE,
                  MotherEducationLevel_CODE,
                  MotherBirthState_CODE,
                  MotherResideCounty_IDNO,
                  MotherResideLocation_NAME,
                  MotherLine1Old_ADDR,
                  MotherZipOld_ADDR,
                  MotherCityLimit_INDC,
                  FatherFirst_NAME,
                  FatherMiddle_NAME,
                  FatherLast_NAME,
                  FatherSsn_NUMB,
                  FatherBirth_DATE,
                  FatherBirthState_CODE,
                  FatherRace_CODE,
                  FatherEducationLevel_CODE,
                  StateFiled_DATE,
                  TypePlaceAckSigned_CODE,
                  PlaceAckSigned_NAME,
                  AcknowledgementSignedCity_NAME,
                  ChildBirthState_CODE,
                  MotherCityOld_ADDR,
                  MotherStateOld_ADDR,
                  FatherEmplLine1Old_ADDR,
                  FatherEmplZipOld_ADDR,
                  MotherPhone_NUMB,
                  MotherEmployer_NAME,
                  MotherEmplCity_NAME,
                  MotherEmplState_NAME,
                  OccupationMother_TEXT,
                  MotherHispanicOrigin_CODE,
                  MotherHispanicOriginLit_NAME,
                  MotherMedicalInsurance_NAME,
                  MotherMedicalPolicyInsNo_TEXT,
                  MotherMarried_INDC,
                  FatherPhone_NUMB,
                  FatherEmployer_NAME,
                  FatherEmplCityOld_ADDR,
                  FatherEmplStateOld_ADDR,
                  FatherOccupation_TEXT,
                  FatherTypeBusiness_NAME,
                  FatherMedicalInsurance_NAME,
                  FatherMedicalPolicyInsNo_TEXT,
                  FatherHispanicOrigin_CODE,
                  FatherHispanicOriginLit_NAME,
                  FatherLine1Old_ADDR,
                  FatherLine2Old_ADDR,
                  FatherStateOld_ADDR,
                  FatherCityOld_ADDR,
                  FatherZipOld_ADDR,
                  MotherAddressNormalization_CODE,
                  MotherLine1_ADDR,
                  MotherLine2_ADDR,
                  MotherCity_ADDR,
                  MotherState_ADDR,
                  MotherZip_ADDR,
                  FatherEmplAddressNormalization_CODE,
                  FatherEmplLine1_ADDR,
                  FatherEmplLine2_ADDR,
                  FatherEmplCity_ADDR,
                  FatherEmplState_ADDR,
                  FatherEmplZip_ADDR,
                  FatherAddressNormalization_CODE,
                  FatherLine1_ADDR,
                  FatherLine2_ADDR,
                  FatherCity_ADDR,
                  FatherState_ADDR,
                  FatherZip_ADDR,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (SUBSTRING(A.Record_TEXT, 1, 8)) AS ChildBirth_DATE,
            (SUBSTRING(A.Record_TEXT, 9, 15)) AS ChildFirst_NAME,
            (SUBSTRING(A.Record_TEXT, 24, 15)) AS ChildMiddle_NAME,
            (SUBSTRING(A.Record_TEXT, 39, 20)) AS ChildLast_NAME,
            (SUBSTRING(A.Record_TEXT, 59, 1)) AS ChildSex_CODE,
            (SUBSTRING(A.Record_TEXT, 60, 20)) AS ChildBirthCity_NAME,
            (SUBSTRING(A.Record_TEXT, 80, 2)) AS ChildCountyBirth_IDNO,
            (SUBSTRING(A.Record_TEXT, 82, 1)) AS ChildBirth_CODE,
            (SUBSTRING(A.Record_TEXT, 83, 4)) AS ChildBirthFacility_CODE,
            (SUBSTRING(A.Record_TEXT, 87, 50)) AS ChildBirthFacility_NAME,
            (SUBSTRING(A.Record_TEXT, 137, 6)) AS ChildBirthCertificate_ID,
            (SUBSTRING(A.Record_TEXT, 143, 15)) AS MotherFirst_NAME,
            (SUBSTRING(A.Record_TEXT, 158, 15)) AS MotherMiddle_NAME,
            (SUBSTRING(A.Record_TEXT, 173, 20)) AS MotherLast_NAME,
            (SUBSTRING(A.Record_TEXT, 193, 30)) AS MotherMaiden_NAME,
            (SUBSTRING(A.Record_TEXT, 223, 9)) AS MotherSsn_NUMB,
            (SUBSTRING(A.Record_TEXT, 232, 8)) AS MotherBirth_DATE,
            (SUBSTRING(A.Record_TEXT, 240, 16)) AS MotherRace_CODE,
            (SUBSTRING(A.Record_TEXT, 256, 2)) AS MotherEducationLevel_CODE,
            (SUBSTRING(A.Record_TEXT, 258, 2)) AS MotherBirthState_CODE,
            (SUBSTRING(A.Record_TEXT, 260, 2)) AS MotherResideCounty_IDNO,
            (SUBSTRING(A.Record_TEXT, 262, 15)) AS MotherResideLocation_NAME,
            (SUBSTRING(A.Record_TEXT, 277, 30)) AS MotherLine1Old_ADDR,
            (SUBSTRING(A.Record_TEXT, 307, 9)) AS MotherZipOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 316, 1)) AS MotherCityLimit_INDC,
            (SUBSTRING(A.Record_TEXT, 317, 15)) AS FatherFirst_NAME,
            (SUBSTRING(A.Record_TEXT, 332, 15)) AS FatherMiddle_NAME,
            (SUBSTRING(A.Record_TEXT, 347, 20)) AS FatherLast_NAME,
            (SUBSTRING(A.Record_TEXT, 367, 9)) AS FatherSsn_NUMB,
            (SUBSTRING(A.Record_TEXT, 376, 8)) AS FatherBirth_DATE,
            (SUBSTRING(A.Record_TEXT, 384, 2)) AS FatherBirthState_CODE,
            (SUBSTRING(A.Record_TEXT, 386, 16)) AS FatherRace_CODE,
            (SUBSTRING(A.Record_TEXT, 402, 2)) AS FatherEducationLevel_CODE,
            (SUBSTRING(A.Record_TEXT, 404, 8)) AS StateFiled_DATE,
            (SUBSTRING(A.Record_TEXT, 412, 1)) AS TypePlaceAckSigned_CODE,
            (SUBSTRING(A.Record_TEXT, 413, 50)) AS PlaceAckSigned_NAME,
            (SUBSTRING(A.Record_TEXT, 463, 50)) AS AcknowledgementSignedCity_NAME,
            (SUBSTRING(A.Record_TEXT, 513, 2)) AS ChildBirthState_CODE,
            (SUBSTRING(A.Record_TEXT, 515, 50)) AS MotherCityOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 565, 2)) AS MotherStateOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 567, 50)) AS FatherEmplLine1Old_ADDR,
            (SUBSTRING(A.Record_TEXT, 617, 11)) AS FatherEmplZipOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 628, 30)) AS MotherPhone_NUMB,
            (SUBSTRING(A.Record_TEXT, 658, 50)) AS MotherEmployer_NAME,
            (SUBSTRING(A.Record_TEXT, 708, 50)) AS MotherEmplCity_NAME,
            (SUBSTRING(A.Record_TEXT, 758, 50)) AS MotherEmplState_NAME,
            (SUBSTRING(A.Record_TEXT, 808, 50)) AS OccupationMother_TEXT,
            (SUBSTRING(A.Record_TEXT, 858, 2)) AS MotherHispanicOrigin_CODE,
            (SUBSTRING(A.Record_TEXT, 860, 20)) AS MotherHispanicOriginLit_NAME,
            (SUBSTRING(A.Record_TEXT, 880, 50)) AS MotherMedicalInsurance_NAME,
            (SUBSTRING(A.Record_TEXT, 930, 50)) AS MotherMedicalPolicyInsNo_TEXT,
            (SUBSTRING(A.Record_TEXT, 980, 1)) AS MotherMarried_INDC,
            (SUBSTRING(A.Record_TEXT, 981, 30)) AS FatherPhone_NUMB,
            (SUBSTRING(A.Record_TEXT, 1011, 50)) AS FatherEmployer_NAME,
            (SUBSTRING(A.Record_TEXT, 1061, 50)) AS FatherEmplCityOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 1111, 50)) AS FatherEmplStateOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 1161, 30)) AS FatherOccupation_TEXT,
            (SUBSTRING(A.Record_TEXT, 1191, 50)) AS FatherTypeBusiness_NAME,
            (SUBSTRING(A.Record_TEXT, 1241, 50)) AS FatherMedicalInsurance_NAME,
            (SUBSTRING(A.Record_TEXT, 1291, 50)) AS FatherMedicalPolicyInsNo_TEXT,
            (SUBSTRING(A.Record_TEXT, 1341, 2)) AS FatherHispanicOrigin_CODE,
            (SUBSTRING(A.Record_TEXT, 1343, 20)) AS FatherHispanicOriginLit_NAME,
            (SUBSTRING(A.Record_TEXT, 1363, 50)) AS FatherLine1Old_ADDR,
            (SUBSTRING(A.Record_TEXT, 1413, 10)) AS FatherLine2Old_ADDR,
            (SUBSTRING(A.Record_TEXT, 1423, 30)) AS FatherStateOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 1453, 30)) AS FatherCityOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 1483, 9)) AS FatherZipOld_ADDR,
            (SUBSTRING(A.Record_TEXT, 1492, 1)) AS MotherAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 1493, 50)) AS MotherLine1_ADDR,
            (SUBSTRING(A.Record_TEXT, 1543, 50)) AS MotherLine2_ADDR,
            (SUBSTRING(A.Record_TEXT, 1593, 28)) AS MotherCity_ADDR,
            (SUBSTRING(A.Record_TEXT, 1621, 2)) AS MotherState_ADDR,
            (SUBSTRING(A.Record_TEXT, 1623, 15)) AS MotherZip_ADDR,
            (SUBSTRING(A.Record_TEXT, 1638, 1)) AS FatherEmplAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 1639, 50)) AS FatherEmplLine1_ADDR,
            (SUBSTRING(A.Record_TEXT, 1689, 50)) AS FatherEmplLine2_ADDR,
            (SUBSTRING(A.Record_TEXT, 1739, 28)) AS FatherEmplCity_ADDR,
            (SUBSTRING(A.Record_TEXT, 1767, 2)) AS FatherEmplState_ADDR,
            (SUBSTRING(A.Record_TEXT, 1769, 15)) AS FatherEmplZip_ADDR,
            (SUBSTRING(A.Record_TEXT, 1784, 1)) AS FatherAddressNormalization_CODE,
            (SUBSTRING(A.Record_TEXT, 1785, 50)) AS FatherLine1_ADDR,
            (SUBSTRING(A.Record_TEXT, 1835, 50)) AS FatherLine2_ADDR,
            (SUBSTRING(A.Record_TEXT, 1885, 28)) AS FatherCity_ADDR,
            (SUBSTRING(A.Record_TEXT, 1913, 2)) AS FatherState_ADDR,
            (SUBSTRING(A.Record_TEXT, 1915, 15)) AS FatherZip_ADDR,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ProcessN_INDC AS Process_INDC
       FROM #LoadVapp_P1 A;

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_LOAD_VAP';

   COMMIT TRANSACTION TXN_LOAD_VAP;

   SET @Ls_Sql_TEXT = 'DROP #LoadVapp_P1';

   DROP TABLE #LoadVapp_P1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_LOAD_VAP;
    END;

   DROP TABLE #LoadVapp_P1;

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
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
