/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_PUDM$SP_LOAD_PUDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_PUDM$SP_LOAD_PUDM
Programmer Name   :	IMP Team
Description       :	This process is to read incoming files from public utilities and loads them into a LPUDM_Y1
Frequency         :	The job will be run when the file is received from the public utlity companies
Developed On      :	05/23/2011
Called By         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$SP_BSTL_LOG
					BATCH_COMMON$SP_UPDATE_PARM_DATE
---------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
---------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_PUDM$SP_LOAD_PUDM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeErrorWarning_CODE  CHAR(1) = 'W',
          @Lc_ProcessN_INDC          CHAR(1) = 'N',
          @Lc_ProcessY_INDC          CHAR(1) = 'Y',
          @Lc_HeaderRecordType_TEXT  CHAR(2) = '03',
          @Lc_DetailRecordType_TEXT  CHAR(2) = '04',
          @Lc_TrailerRecordType_TEXT CHAR(2) = '05',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_JobDeb8071_ID          CHAR(7) = 'DEB8071',
          @Lc_JobDeb8089_ID          CHAR(7) = 'DEB8089',
          @Lc_JobDeb8090_ID          CHAR(7) = 'DEB8090',
          @Lc_ErrorE0994_CODE        CHAR(18) = 'E0944',
          @Lc_Successful_INDC        CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT   VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_PUDM',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_PUDM';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_TrailerRecordCount_QNTY     NUMERIC(10, 0),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Li_LoadFilesCount_QNTY         SMALLINT,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Lc_Job_ID                      CHAR(7) = '',
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Lb_FileExists8071_BIT          BIT = 0,
          @Lb_FileExists8089_BIT          BIT = 0,
          @Lb_FileExists8090_BIT          BIT = 0,
          @Lb_FileExists_BIT              BIT = 0;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Li_LoadFilesCount_QNTY = 1;

   -- Total number of files we recieve is 3.
   WHILE (@Li_LoadFilesCount_QNTY <= 3)
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      CREATE TABLE #LoadPudmFile_P1
       (
         Record_TEXT VARCHAR (845)
       );

      SET @Lc_Job_ID = CASE
                        WHEN @Li_LoadFilesCount_QNTY = 1
                         THEN @Lc_JobDeb8071_ID
                        WHEN @Li_LoadFilesCount_QNTY = 2
                         THEN @Lc_JobDeb8089_ID
                        WHEN @Li_LoadFilesCount_QNTY = 3
                         THEN @Lc_JobDeb8090_ID
                       END;
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_FILE_EXISTS_CHECK';
      SET @Ls_Sqldata_TEXT = 'File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '');

      EXECUTE BATCH_COMMON$SP_FILE_EXISTS_CHECK
       @As_File_NAME             = @Ls_File_NAME,
       @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
       @Ab_FileExists_BIT        = @Lb_FileExists_BIT OUTPUT,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END;

      IF @Lb_FileExists_BIT = 1
       BEGIN
        IF @Lc_Job_ID = @Lc_JobDeb8071_ID
         BEGIN
          SET @Lb_FileExists8071_BIT = 1;
         END
        ELSE IF @Lc_Job_ID = @Lc_JobDeb8089_ID
         BEGIN
          SET @Lb_FileExists8089_BIT = 1;
         END
        ELSE IF @Lc_Job_ID = @Lc_JobDeb8090_ID
         BEGIN
          SET @Lb_FileExists8090_BIT = 1;
         END

        SET @Ls_Sql_TEXT = 'Run_DATE AND LAST Run_DATE VALIDATION';
        SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
         BEGIN
          SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

          RAISERROR (50001,16,1);
         END;

        SET @Ls_FileSource_TEXT = LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

        IF @Ls_FileSource_TEXT = ''
         BEGIN
          SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
          SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
          SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

          RAISERROR (50001,16,1);
         END;

        SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
        SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
        SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadPudmFile_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

        EXECUTE (@Ls_SqlStmnt_TEXT);

        SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

        BEGIN TRANSACTION PUDM_LOAD;

        SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LPUDM_Y1';
        SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

        DELETE LPUDM_Y1
         WHERE Process_INDC = @Lc_ProcessY_INDC;

        SET @Ls_Sql_TEXT = 'DELETE PROCESSED RECORDS IN LHPUD_Y1';
        SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

        DELETE FROM LHPUD_Y1
         WHERE Process_INDC = @Lc_ProcessY_INDC;

        SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                               FROM #LoadPudmFile_P1
                                              WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_DetailRecordType_TEXT);

        IF @Ln_ProcessedRecordCount_QNTY <> 0
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT TMP_LOAD_PUDM_TABLE - TRAILER COUNT';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

          SELECT @Ln_TrailerRecordCount_QNTY = (SUBSTRING(Record_TEXT, 3, 6))
            FROM #LoadPudmFile_P1 a
           WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_TrailerRecordType_TEXT;

          SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

          IF @Ln_ProcessedRecordCount_QNTY != @Ln_TrailerRecordCount_QNTY
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'NUMBER OF RECORDS IN TRAILER DOESNT MATCH WITH SUM OF DETAIL RECORDS, DETAIL RECORD COUNT = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', TRAILER RECORD COUNT = ' + CAST(@Ln_TrailerRecordCount_QNTY AS VARCHAR);

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'INSERT INTO LHPUD_Y1 ';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

          INSERT INTO LHPUD_Y1
                      (Rec_ID,
                       Fein_IDNO,
                       PublicUtility_NAME,
                       PublicUtilityLine1_ADDR,
                       PublicUtilityCity_ADDR,
                       PublicUtilityState_ADDR,
                       PublicUtilityZip_ADDR,
                       PublicUtilityGenerated_DATE,
                       FileLoad_DATE,
                       Process_INDC)
          SELECT @Lc_HeaderRecordType_TEXT AS Rec_ID,
                 SUBSTRING(Record_TEXT, 3, 9) AS Fein_IDNO,
                 SUBSTRING(Record_TEXT, 12, 40) AS PublicUtility_NAME,
                 SUBSTRING(Record_TEXT, 52, 40) AS PublicUtilityLine1_ADDR,
                 SUBSTRING(Record_TEXT, 92, 16) AS PublicUtilityCity_ADDR,
                 SUBSTRING(Record_TEXT, 108, 2) AS PublicUtilityState_ADDR,
                 SUBSTRING(Record_TEXT, 110, 9) AS PublicUtilityZip_ADDR,
                 SUBSTRING(Record_TEXT, 119, 8) AS PublicUtilityGenerated_DATE,
                 @Ld_Run_DATE AS FileLoad_DATE,
                 @Lc_ProcessN_INDC AS Process_INDC
            FROM #LoadPudmFile_P1 a
           WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_HeaderRecordType_TEXT;

          SET @Ls_Sql_TEXT = 'INSERT LPUDM_Y1';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

          INSERT INTO LPUDM_Y1
                      (HeaderSeq_IDNO,
                       Rec_ID,
                       MemberSsn_NUMB,
                       MemberMci_IDNO,
                       Last_NAME,
                       First_NAME,
                       Middle_NAME,
                       Title_NAME,
                       ServiceLine1Old_ADDR,
                       ServiceAptNoOld_ADDR,
                       ServiceLine2Old_ADDR,
                       ServiceCityOld_ADDR,
                       ServiceStateOld_ADDR,
                       ServiceZipOld_ADDR,
                       Phone_NUMB,
                       Billing_NAME,
                       BillingLine1Old_ADDR,
                       BillingAptOld_ADDR,
                       BillingLine2Old_ADDR,
                       BillingCityOld_ADDR,
                       BillingStateOld_ADDR,
                       BillingZipOld_ADDR,
                       BillingPhone_NUMB,
                       Employer_NAME,
                       EmployerLine1Old_ADDR,
                       EmployerLine2Old_ADDR,
                       EmployerCityOld_ADDR,
                       EmployerStateOld_ADDR,
                       EmployerZipOld_ADDR,
                       EmployerPhone_NUMB,
                       ServiceAddressNormalization_CODE,
                       ServiceLine1_ADDR,
                       ServiceLine2_ADDR,
                       ServiceCity_ADDR,
                       ServiceState_ADDR,
                       ServiceZip_ADDR,
                       BillingAddressNormalization_CODE,
                       BillingLine1_ADDR,
                       BillingLine2_ADDR,
                       BillingCity_ADDR,
                       BillingState_ADDR,
                       BillingZip_ADDR,
                       EmployerAddressNormalization_CODE,
                       EmployerLine1_ADDR,
                       EmployerLine2_ADDR,
                       EmployerCity_ADDR,
                       EmployerState_ADDR,
                       EmployerZip_ADDR,
                       FileLoad_DATE,
                       Process_INDC)
          SELECT (SELECT MAX(Seq_IDNO)
                    FROM LHPUD_Y1 a) AS HeaderSeq_IDNO,--HeaderSeq_IDNO
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,--Record type
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 3, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- OwnerMemberSsn_NUMB
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 12, 10), @Lc_Space_TEXT))) AS MemberMci_IDNO,-- OwnerMemberMci_IDNO
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 22, 13), @Lc_Space_TEXT))) AS Last_NAME,-- OwnerLast_NAME
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 35, 9), @Lc_Space_TEXT))) AS First_NAME,-- OwnerFirst_NAME
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 44, 1), @Lc_Space_TEXT))) AS Middle_NAME,-- OwnerMi_NAME
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 45, 1), @Lc_Space_TEXT))) AS Title_NAME,-- OwnerTitle_Name
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 46, 31), @Lc_Space_TEXT))) AS ServiceLine1Old_ADDR,-- OwnerSerLine1Old_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 77, 5), @Lc_Space_TEXT))) AS ServiceAptNoOld_ADDR,-- OwnerSerAptNoOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 82, 31), @Lc_Space_TEXT))) AS ServiceLine2Old_ADDR,-- OwnerSerLine2Old_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 113, 16), @Lc_Space_TEXT))) AS ServiceCityOld_ADDR,-- OwnerSerCityOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 129, 2), @Lc_Space_TEXT))) AS ServiceStateOld_ADDR,-- OwnerSerStateOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 131, 9), @Lc_Space_TEXT))) AS ServiceZipOld_ADDR,-- OwnerSerZipOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 140, 10), @Lc_Space_TEXT))) AS Phone_NUMB,-- OwnerPhone_NUMB                       
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 150, 24), @Lc_Space_TEXT))) AS Billing_NAME,-- OwnerBill_NAME
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 174, 31), @Lc_Space_TEXT))) AS BillingLine1Old_ADDR,-- OwnerBill1Old_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 205, 5), @Lc_Space_TEXT))) AS BillingAptOld_ADDR,-- OwnerBillAptOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 210, 31), @Lc_Space_TEXT))) AS BillingLine2Old_ADDR,-- OwnerBill2Old_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 241, 16), @Lc_Space_TEXT))) AS BillingCityOld_ADDR,-- OwnerBillCityOld_ADDR                       
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 257, 2), @Lc_Space_TEXT))) AS BillingStateOld_ADDR,-- OwnerBillStateOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 259, 9), @Lc_Space_TEXT))) AS BillingZipOld_ADDR,-- OwnerBillZipOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 268, 10), @Lc_Space_TEXT))) AS BillingPhone_NUMB,-- OwnerBillPhone_NUMB
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 278, 31), @Lc_Space_TEXT))) AS Employer_NAME,-- OwnerEmpl_NAME
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 309, 31), @Lc_Space_TEXT))) AS EmployerLine1Old_ADDR,-- OwnerEmpl1Old_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 340, 31), @Lc_Space_TEXT))) AS EmployerLine2Old_ADDR,-- OwnerEmpl2Old_ADDR                       
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 371, 16), @Lc_Space_TEXT))) AS EmployerCityOld_ADDR,-- OwnerEmplCityOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 387, 2), @Lc_Space_TEXT))) AS EmployerStateOld_ADDR,-- OwnerEmplStateOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 389, 9), @Lc_Space_TEXT))) AS EmployerZipOld_ADDR,-- OwnerEmplZipOld_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 398, 10), @Lc_Space_TEXT))) AS EmployerPhone_NUMB,-- OwnerEmplPhone_NUMB
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 408, 1), @Lc_Space_TEXT))) AS ServiceAddressNormalization_CODE,-- Service Address Normalized Code
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 409, 50), @Lc_Space_TEXT))) AS ServiceLine1_ADDR,-- OwnerSerLine1_ADDR                      
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 459, 50), @Lc_Space_TEXT))) AS ServiceLine2_ADDR,-- OwnerSerLine2_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 509, 28), @Lc_Space_TEXT))) AS ServiceCity_ADDR,-- OwnerSerCity_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 537, 2), @Lc_Space_TEXT))) AS ServiceState_ADDR,-- OwnerSerState_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 539, 15), @Lc_Space_TEXT))) AS ServiceZip_ADDR,-- OwnerSerZip_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 554, 1), @Lc_Space_TEXT))) AS BillingAddressNormalization_CODE,-- Service Address Normalized Code
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 555, 50), @Lc_Space_TEXT))) AS BillingLine1_ADDR,-- OwnerBill1_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 605, 50), @Lc_Space_TEXT))) AS BillingLine2_ADDR,-- OwnerBill2_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 655, 28), @Lc_Space_TEXT))) AS BillingCity_ADDR,-- OwnerCity_ADDR                       
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 683, 2), @Lc_Space_TEXT))) AS BillingState_ADDR,-- OwnerState_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 685, 15), @Lc_Space_TEXT))) AS BillingZip_ADDR,-- OwnerZip_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 700, 1), @Lc_Space_TEXT))) AS EmployerAddressNormalization_CODE,-- Service Address Normalized Code
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 701, 50), @Lc_Space_TEXT))) AS EmployerLine1_ADDR,-- OwnerEmpl1_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 751, 50), @Lc_Space_TEXT))) AS EmployerLine2_ADDR,-- OwnerEmpl2_ADDR                       
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 801, 28), @Lc_Space_TEXT))) AS EmployerCity_ADDR,-- OwnerEmplCity_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 829, 2), @Lc_Space_TEXT))) AS EmployerState_ADDR,-- OwnerEmplState_ADDR
                 (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 831, 15), @Lc_Space_TEXT))) AS EmployerZip_ADDR,-- OwnerEmplZip_ADDR
                 @Ld_Run_DATE AS FileLoad_DATE,
                 @Lc_ProcessN_INDC AS Process_INDC
            FROM #LoadPudmFile_P1 a
           WHERE SUBSTRING(Record_TEXT, 1, 2) = @Lc_DetailRecordType_TEXT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
          SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0994_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

          EXECUTE BATCH_COMMON$SP_BATE_LOG
           @As_Process_NAME             = @Ls_Process_NAME,
           @As_Procedure_NAME           = @Ls_Procedure_NAME,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
           @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
           @Ac_Error_CODE               = @Lc_ErrorE0994_CODE,
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
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

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
        SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

        EXECUTE BATCH_COMMON$SP_BSTL_LOG
         @Ad_Run_DATE                  = @Ld_Run_DATE,
         @Ad_Start_DATE                = @Ld_Start_DATE,
         @Ac_Job_ID                    = @Lc_Job_ID,
         @As_Process_NAME              = @Ls_Process_NAME,
         @As_Procedure_NAME            = @Ls_Procedure_NAME,
         @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
         @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
         @As_ListKey_TEXT              = @Lc_Successful_INDC,
         @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
         @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
         @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
         @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
       END

      SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      DROP TABLE #LoadPudmFile_P1;

      IF @Lb_FileExists_BIT = 1
       BEGIN
        SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

        COMMIT TRANSACTION PUDM_LOAD;
       END
     END TRY

     BEGIN CATCH
      IF @@TRANCOUNT > 0
       BEGIN
        ROLLBACK TRANSACTION PUDM_LOAD;
       END

      IF OBJECT_ID('tempdb..#LoadPudmFile_P1') IS NOT NULL
       BEGIN
        DROP TABLE #LoadPudmFile_P1;
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
     END CATCH

     SET @Li_LoadFilesCount_QNTY = @Li_LoadFilesCount_QNTY + 1;

     IF @Li_LoadFilesCount_QNTY = 4
      BEGIN
       BREAK;
      END
    END

   IF @Lb_FileExists8071_BIT = 0
      AND @Lb_FileExists8089_BIT = 0
      AND @Lb_FileExists8090_BIT = 0
    BEGIN
     RAISERROR (50001,16,1);
    END
  END TRY

  BEGIN CATCH
   SET @Ls_Sql_TEXT = 'NO INPUT FILE FOUND';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobDeb8071_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Sql_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobDeb8071_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_Zero_NUMB;

   SET @Ls_Sql_TEXT = 'NO INPUT FILE FOUND';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobDeb8089_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Sql_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobDeb8089_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_Zero_NUMB;

   SET @Ls_Sql_TEXT = 'NO INPUT FILE FOUND';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobDeb8090_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Sql_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobDeb8090_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY =@Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
