/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DOL_QW$SP_LOAD_DOL_QW]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_INCOMING_DOL_QW$SP_LOAD_DOL_QW
Programmer Name	:	IMP Team.
Description		:	This process loads the incoming quarterly wage (State QW) file to a temporary Quarterly Wage LSQWA_Y1 table
Frequency		:	QUARTERLY
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DOL_QW$SP_LOAD_DOL_QW]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY          INT = 0,
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_Process_INDC           CHAR(1) = 'N',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeWarning_CODE       CHAR(1) = 'W',
          @Lc_TypeInfoError_CODE     CHAR(1) = 'I',
          @Lc_TrailerRecordTQ_TEXT   CHAR(2) = 'TQ',
          @Lc_HeaderRecordHQ_TEXT    CHAR(2) = 'HQ',
          @Lc_DetailRecordQW_TEXT    CHAR(2) = 'QW',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE    CHAR(5) = 'E0944',
          @Lc_BateErrorE0293_CODE    CHAR(5) = 'E0293',
          @Lc_Job_ID                 CHAR(7) = 'DEB6070',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_DOL_QW',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_LOC_INCOMING_DOL_QW';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_TrailerRecordCount_NUMB     NUMERIC(10, 0),
          @Ln_RecordCount_NUMB            NUMERIC(10, 0),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_FileName_TEXT               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   CREATE TABLE #LoadDol_P1
    (
      InputRecord_TEXT VARCHAR (747)
    );

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_TEXT OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_FileSource_TEXT = '' + LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_SqlData_TEXT = 'FILE SOURCE = ' + ISNULL(@Ls_FileSource_TEXT, '') + ', FILE NAME = ' + ISNULL(@Ls_FileName_TEXT, '');
     SET @Ls_DescriptionError_TEXT ='BULK INSERT INTO LOAD TABLE';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadDol_P1 FROM ''' + @Ls_FileSource_TEXT + '''';
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'INSERT #LoadDol_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);

   BEGIN TRANSACTION DolLoad;

   BEGIN
    SET @Ls_Sql_TEXT = 'Read Trailer Record Count';
    SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

    IF ISNUMERIC((SELECT SUBSTRING(LD.InputRecord_TEXT, 3, 11)
                    FROM #LoadDol_P1 LD
                   WHERE LEFT (LD.InputRecord_TEXT, 2) = @Lc_TrailerRecordTQ_TEXT)) = 1
     BEGIN
      SELECT @Ln_TrailerRecordCount_NUMB = CAST(SUBSTRING(LD.InputRecord_TEXT, 3, 11) AS NUMERIC)
        FROM #LoadDol_P1 LD
       WHERE LEFT (LD.InputRecord_TEXT, 2) = @Lc_TrailerRecordTQ_TEXT;

      --Trailer Record includes the count of Header and Trailer which results in 2 rows.
      SET @Ln_TrailerRecordCount_NUMB = @Ln_TrailerRecordCount_NUMB - 2;
     END
    ELSE
     BEGIN
      SET @Ln_TrailerRecordCount_NUMB = 0;
     END

    SET @Ls_Sql_TEXT = 'Read Record Count';
    SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

    SELECT @Ln_RecordCount_NUMB = COUNT (1)
      FROM #LoadDol_P1 LD
     WHERE LEFT (LD.InputRecord_TEXT, 2) IN (@Lc_DetailRecordQW_TEXT);

    IF @Ln_TrailerRecordCount_NUMB != @Ln_RecordCount_NUMB
     BEGIN
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
      SET @Ls_DescriptionError_TEXT = 'Trailer and Detail Record Count Mismatch due to Invalid Special Characters'
      SET @Ls_Sqldata_TEXT = @Ls_DescriptionError_TEXT + ', TrailerRecordCount_NUMB = ' + CAST(ISNULL(@Ln_TrailerRecordCount_NUMB, 0) AS VARCHAR) + ', RecordCount_NUMB = ' + CAST(ISNULL(@Ln_RecordCount_NUMB, 0) AS VARCHAR)

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeInfoError_CODE,
       @An_Line_NUMB                = @Ln_Zero_NUMB,
       @Ac_Error_CODE               = @Lc_BateErrorE0293_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END
     END

    IF @Ln_RecordCount_NUMB = 0
     BEGIN
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
       @An_Line_NUMB                = @Ln_Zero_NUMB,
       @Ac_Error_CODE               = @Lc_BateErrorE0944_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END
     END

    SET @Ls_Sql_TEXT = 'DELETE FROM TABLE LSQWA_Y1';
    SET @Ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

    DELETE FROM LSQWA_Y1
     WHERE Process_INDC = 'Y';

    SET @Ls_Sql_TEXT = 'INSERT INTO LSQWA_Y1';
    SET @ls_SqlData_TEXT = 'Job_ID = ' + @Lc_Job_ID;

    INSERT INTO LSQWA_Y1
                (Rec_ID,
                 MemberSsn_NUMB,
                 First_NAME,
                 Middle_NAME,
                 Last_NAME,
                 Wage_AMNT,
                 YearQtr_NUMB,
                 Fein_IDNO,
                 Sein_IDNO,
                 Employer_NAME,
                 EmployerLine1Old_ADDR,
                 EmployerLine2Old_ADDR,
                 EmployerLine3Old_ADDR,
                 EmployerCityOld_ADDR,
                 EmployerStateOld_ADDR,
                 EmployerZip1Old_ADDR,
                 EmployerZip2Old_ADDR,
                 ForeignEmployerCountry_ADDR,
                 ForeignEmployer_NAME,
                 ForeignEmployerZip_ADDR,
                 EmployerOptionalLine1_ADDR,
                 EmployerOptionalLine2_ADDR,
                 EmployerOptionalLine3_ADDR,
                 EmployerOptionalCity_ADDR,
                 EmployerOptionalState_ADDR,
                 EmployerOptionalZip1_ADDR,
                 EmployerOptionalZip2_ADDR,
                 EmployerOptionalCountry_ADDR,
                 ForeignEmployerOptional_NAME,
                 ForeignEmployerOptionalZip_ADDR,
                 LocationNormalization_CODE,
                 EmployerLine1_ADDR,
                 EmployerLine2_ADDR,
                 EmployerLine3_ADDR,
                 EmployerCity_ADDR,
                 EmployerState_ADDR,
                 EmployerZip1_ADDR,
                 EmployerZip2_ADDR,
                 Process_INDC,
                 FileLoad_DATE)
    SELECT (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,-- Rec_ID,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 3, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- MemberSsn_NUMB,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 12, 16), @Lc_Space_TEXT))) AS First_NAME,-- First_NAME,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 28, 16), @Lc_Space_TEXT))) AS Middle_NAME,-- Middle_NAME,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 44, 30), @Lc_Space_TEXT))) AS Last_NAME,-- Last_NAME,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 74, 11), @Lc_Space_TEXT))) AS Wage_AMNT,-- Wage_AMNT,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 85, 5), @Lc_Space_TEXT))) AS YearQtr_NUMB,-- YearQtr_NUMB,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 90, 9), @Lc_Space_TEXT))) AS Fein_IDNO,-- Fein_IDNO,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 99, 12), @Lc_Space_TEXT))) AS Sein_IDNO,-- Sein_IDNO,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 111, 45), @Lc_Space_TEXT))) AS Employer_NAME,-- Employer_NAME,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 156, 40), @Lc_Space_TEXT))) AS EmployerLine1Old_ADDR,-- EmployerLine1Old_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 196, 40), @Lc_Space_TEXT))) AS EmployerLine2Old_ADDR,-- EmployerLine2Old_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 236, 40), @Lc_Space_TEXT))) AS EmployerLine3Old_ADDR,-- EmployerLine3Old_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 276, 25), @Lc_Space_TEXT))) AS EmployerCityOld_ADDR,-- EmployerCityOld_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 301, 2), @Lc_Space_TEXT))) AS EmployerStateOld_ADDR,-- EmployerStateOld_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 303, 5), @Lc_Space_TEXT))) AS EmployerZip1Old_ADDR,-- EmployerZip1Old_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 308, 4), @Lc_Space_TEXT))) AS EmployerZip2Old_ADDR,-- EmployerZip2Old_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 312, 2), @Lc_Space_TEXT))) AS ForeignEmployerCountry_ADDR,-- ForeignEmployerCountry_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 314, 25), @Lc_Space_TEXT))) AS ForeignEmployer_NAME,-- ForeignEmployer_NAME,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 339, 15), @Lc_Space_TEXT))) AS ForeignEmployerZip_ADDR,-- ForeignEmployerZip_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 354, 40), @Lc_Space_TEXT)))AS EmployerOptionalLine1_ADDR,-- EmployerOptionalLine1_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 394, 40), @Lc_Space_TEXT))) AS EmployerOptionalLine2_ADDR,-- EmployerOptionalLine2_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 434, 40), @Lc_Space_TEXT))) AS EmployerOptionalLine3_ADDR,-- EmployerOptionalLine3_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 474, 25), @Lc_Space_TEXT))) AS EmployerOptionalCity_ADDR,-- EmployerOptionalCity_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 499, 2), @Lc_Space_TEXT))) AS EmployerOptionalState_ADDR,-- EmployerOptionalState_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 501, 5), @Lc_Space_TEXT))) AS EmployerOptionalZip1_ADDR,-- EmployerOptionalZip1_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 506, 4), @Lc_Space_TEXT))) AS EmployerOptionalZip2_ADDR,-- EmployerOptionalZip2_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 510, 2), @Lc_Space_TEXT))) AS EmployerOptionalCountry_ADDR,-- EmployerOptionalCountry_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 512, 25), @Lc_Space_TEXT))) AS ForeignEmployerOptional_NAME,-- ForeignEmployerOptional_NAME,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 537, 15), @Lc_Space_TEXT))) AS ForeignEmployerOptionalZip_ADDR,-- ForeignEmployerOptionalZip_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 602, 1), @Lc_Space_TEXT))) AS LocationNormalization_CODE,-- LocationNormalization_CODE,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 603, 50), @Lc_Space_TEXT))) AS EmployerLine1_ADDR,-- EmployerLine1_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 653, 50), @Lc_Space_TEXT)))AS EmployerLine2_ADDR,-- EmployerLine2_ADDR,  
           @Lc_Space_TEXT AS EmployerLine3_ADDR,-- EmployerLine3_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 703, 28), @Lc_Space_TEXT))) AS EmployerCity_ADDR,-- EmployerCity_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 731, 2), @Lc_Space_TEXT))) AS EmployerState_ADDR,-- EmployerState_ADDR,  
           (RTRIM (ISNULL (SUBSTRING (InputRecord_TEXT, 733, 15), @Lc_Space_TEXT))) AS EmployerZip1_ADDR,-- EmployerZip1_ADDR,  
           @Lc_Space_TEXT AS EmployerZip2_ADDR,-- EmployerZip2_ADDR,  
           @Lc_Process_INDC AS Process_INDC,--Process_INDC  
           @Ld_Run_DATE AS FileLoad_DATE --FileLoad_DATE  
      FROM #LoadDol_P1 LD
     WHERE SUBSTRING (LD.InputRecord_TEXT, 1, 2) = @Lc_DetailRecordQW_TEXT;

    SET @Li_RowCount_QNTY = @@ROWCOUNT;

    IF(@Li_RowCount_QNTY = 0)
     BEGIN
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 3';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
       @An_Line_NUMB                = @Ln_Zero_NUMB,
       @Ac_Error_CODE               = @Lc_BateErrorE0944_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END
     END
   END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_Date = ' + CAST(@Ld_Start_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   DROP TABLE #LoadDol_P1;

   COMMIT TRANSACTION DolLoad;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DolLoad;
    END

   IF OBJECT_ID('tempdb..#LoadDol_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDol_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
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
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END 

GO
