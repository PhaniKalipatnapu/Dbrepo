/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DPR$SP_LOAD_DPR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_INCOMING_DPR$SP_LOAD_DPR
Programmer Name	:	IMP Team.
Description		:	This Batch Loads the Input file from Dpr agency
Frequency		:	
Developed On	:	5/10/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
                       BATCH_COMMON$BSTL_LOG,
                       BATCH_COMMON$SP_UPDATE_PARM_DATE,
                       BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DPR$SP_LOAD_DPR]
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE  @Li_RowCount_QNTY			  INT = 0,
           @Lc_Space_TEXT                 CHAR(1) = ' ',
           @Lc_StatusAbnormalend_CODE     CHAR(1) = 'A',
           @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
           @Lc_StatusFailed_CODE          CHAR(1) = 'F',
           @Lc_Process_No_INDC            CHAR(1) = 'N',
           @Lc_Yes_INDC                   CHAR(1) = 'Y',
           @Lc_TrailerT_CODE              CHAR(1) = 'T',
           @Lc_HeaderH_CODE               CHAR(1) = 'H',           
           @Lc_TypeError_CODE			  CHAR(1) = 'E',
           @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
           @Lc_BateErrorE0293_CODE        CHAR(5) = 'E0293',
           @Lc_BateErrorE0944_CODE        CHAR(5) = 'E0944',
           @Lc_Job_ID                     CHAR(7) = 'DEB8097',  
           @Lc_Successful_TEXT            CHAR(10) = 'SUCCESSFUL',
           @Lc_ParmDateProblem_TEXT       CHAR(30) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME             VARCHAR(100) = 'SP_LOAD_DPR',
           @Ls_Process_NAME               VARCHAR(100) = 'BATCH_LOC_INCOMING_DPR';
 DECLARE   @Ln_Zero_NUMB                   NUMERIC(1),  
           @Ln_CommitFreqParm_QNTY         NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
           @Ln_RecordCount_QNTY            NUMERIC(6),
           @Ln_TrailerRecCount_QNTY        NUMERIC(6),
           @Ln_BatchHeaderCount_QNTY       NUMERIC(6),
           @Ln_BatchTrailerCount_QNTY      NUMERIC(6),
           @Ln_Error_NUMB                  NUMERIC(11),
           @Ln_ErrorLine_NUMB              NUMERIC(11),           
           @Lc_Msg_CODE                    CHAR(1),
           @Ls_File_NAME                   VARCHAR(50),
           @Ls_FileLocation_TEXT           VARCHAR(100),
           @Ls_FileSource_TEXT             VARCHAR(130),
           @Ls_SqlStmnt_TEXT               VARCHAR(200),
           @Ls_CursorLoc_TEXT              VARCHAR(200),
           @Ls_Sql_TEXT                    VARCHAR(4000),
           @Ls_SqlData_TEXT                VARCHAR(4000),
           @Ls_DescriptionError_TEXT       VARCHAR(4000),
           @Ls_ErrorMessage_TEXT           VARCHAR(4000),
           @Ld_LastRun_DATE                DATE,
           @Ld_Run_DATE                    DATE,
           @Ld_Start_DATE                  DATETIME2(0);
           
  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_SqlData_TEXT = '';
   
   CREATE TABLE #LoadDpr_P1
    (
      Record_TEXT VARCHAR (475)
    );
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

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
   SET @Ls_SqlData_TEXT = 'LAST RUN DATE : ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + 'RUN DATE : ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;
   
   SET @Ls_FileSource_TEXT =  LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_File_NAME));
  
   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_SqlData_TEXT = 'FILE SOURCE = ' + ISNULL(@Ls_FileSource_TEXT,'') + ', FILE NAME = ' + ISNULL(@Ls_File_NAME,'') ;
     SET @Ls_DescriptionError_TEXT ='BULK INSERT INTO LOAD TABLE';

     RAISERROR (50001,16,1);
    END;
   
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadDpr_P1 FROM  ''' + @Ls_FileSource_TEXT + '''';
   
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_SqlData_TEXT = 'INSERT #LoadDpr_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';  

   EXEC (@Ls_SqlStmnt_TEXT);
      
   SET @Ls_Sql_TEXT = 'CHECK FOR HEADER RECORD';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   SELECT @Ln_BatchHeaderCount_QNTY = COUNT(1)
     FROM #LoadDpr_P1 LD
    WHERE SUBSTRING(LD.Record_TEXT, 1, 1) = @Lc_HeaderH_CODE;

   IF @Ln_BatchHeaderCount_QNTY != 1
    BEGIN
     SET @Ls_Sql_TEXT = 'HEADER RECORD NOT FOUND OR DUPLICATE RECORDS FOUND';
     SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECK FOR TRAILER RECORD';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_BatchTrailerCount_QNTY = COUNT(1)
     FROM #LoadDpr_P1 LD
    WHERE SUBSTRING(LD.Record_TEXT, 1, 1) = @Lc_TrailerT_CODE;

   IF @Ln_BatchTrailerCount_QNTY != 1
    BEGIN
     SET @Ls_Sql_TEXT = 'TRAILER RECORD NOT FOUND OR DUPLICATE RECORDS FOUND';
     SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT #LOADDPR_P1 - TRAILER COUNT';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   SELECT @Ln_TrailerRecCount_QNTY = CAST(SUBSTRING(LD.Record_TEXT, 10,9) AS NUMERIC)
     FROM #LoadDpr_P1 LD
    WHERE SUBSTRING (LD.Record_TEXT, 1, 1) = @Lc_TrailerT_CODE;

   SET @Ls_Sql_TEXT = 'SELECT #LOADDPR_P1 - DETAILS COUNT';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   SELECT @Ln_RecordCount_QNTY = COUNT (1)
     FROM #LoadDpr_P1 LD
    WHERE SUBSTRING (LD.Record_TEXT, 1, 1) NOT IN (@Lc_TrailerT_CODE, @Lc_HeaderH_CODE);   
   
   IF @Ln_RecordCount_QNTY != @Ln_TrailerRecCount_QNTY
    BEGIN
      SET @Ls_ErrorMessage_TEXT = 'INVALID RECORD COUNT';
	   
	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION';
      SET @Ls_SqlData_TEXT = 'Procedure_NAME = ' + @Ls_Procedure_NAME + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Error_NUMB = ' + CAST(@Ln_Error_NUMB AS VARCHAR)+ ', ErrorLine_NUMB = ' + CAST(@Ln_ErrorLine_NUMB AS VARCHAR);
       
      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
	   @As_Procedure_NAME        = @Ls_Procedure_NAME,
	   @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
	   @As_Sql_TEXT              = @Ls_Sql_TEXT,
	   @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
	   @An_Error_NUMB            = @Ln_Error_NUMB,
	   @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
	   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
	  SET @Ls_SqlData_TEXT = 'BateError_CODE = ' + @Lc_BateErrorE0293_CODE;

	  EXECUTE BATCH_COMMON$SP_BATE_LOG
	   @As_Process_NAME             = @Ls_Process_NAME,
	   @As_Procedure_NAME           = @Ls_Procedure_NAME,
	   @Ac_Job_ID                   = @Lc_Job_ID,
	   @Ad_Run_DATE                 = @Ld_Run_DATE,
	   @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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

   BEGIN TRANSACTION LoadDprTran;
   
   SET @Ls_Sql_TEXT = 'DELETE FROM TABLE LDPRL_Y1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   DELETE FROM LDPRL_Y1 
    WHERE Process_INDC = @Lc_Yes_INDC;

   SET @Ls_Sql_TEXT = 'INSERT INTO LDPRL_Y1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   INSERT INTO LDPRL_Y1
               (Profession_CODE,
                TypeLicense_CODE,
                LicenseNo_TEXT,
                MemberSsn_NUMB,
                LicenseStatus_CODE,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                Suffix_NAME,
                MemberSex_CODE,
                Birth_DATE,
                Line1Old_ADDR,
                Line2Old_ADDR,
                Line3Old_ADDR,
                CityOld_ADDR,
                StateOld_ADDR,
                ZipOld_ADDR,
                Normalization_CODE,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                FileLoad_DATE,
                Process_INDC)
   SELECT ISNULL (SUBSTRING(LD.Record_TEXT, 1, 2), @Lc_Space_TEXT) AS Profession_CODE,
          ISNULL (SUBSTRING(LD.Record_TEXT, 3, 5), @Lc_Space_TEXT) AS TypeLicense_CODE,
          ISNULL (SUBSTRING(LD.Record_TEXT, 8, 16), @Lc_Space_TEXT) AS LicenseNo_TEXT,
          ISNULL (SUBSTRING(LD.Record_TEXT, 24, 9), @Lc_Space_TEXT) AS MemberSsn_NUMB,
          ISNULL (SUBSTRING(LD.Record_TEXT, 33, 4), @Lc_Space_TEXT) AS LicenseStatus_CODE,
          ISNULL (SUBSTRING(LD.Record_TEXT, 40, 50), @Lc_Space_TEXT) AS Last_NAME,
          ISNULL (SUBSTRING(LD.Record_TEXT, 90, 30), @Lc_Space_TEXT) AS First_NAME,
          ISNULL (SUBSTRING(LD.Record_TEXT, 120, 30), @Lc_Space_TEXT) AS Middle_NAME,
          ISNULL (SUBSTRING(LD.Record_TEXT, 150, 10), @Lc_Space_TEXT) AS Suffix_NAME,
          ISNULL (SUBSTRING(LD.Record_TEXT, 160, 1), @Lc_Space_TEXT) AS MemberSex_CODE,
          ISNULL (SUBSTRING(LD.Record_TEXT, 161, 8), @Lc_Space_TEXT) AS Birth_DATE,
          ISNULL (SUBSTRING(LD.Record_TEXT, 169, 35), @Lc_Space_TEXT) AS Line1Old_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 204, 35), @Lc_Space_TEXT) AS Line2Old_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 239, 35), @Lc_Space_TEXT) AS Line3Old_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 274, 20), @Lc_Space_TEXT) AS CityOld_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 294, 2), @Lc_Space_TEXT) AS StateOld_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 296, 5), @Lc_Space_TEXT) AS ZipOld_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 321, 1), @Lc_Space_TEXT) AS Normalization_CODE,
          ISNULL (SUBSTRING(LD.Record_TEXT, 322, 50), @Lc_Space_TEXT) AS Line1_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 372, 50), @Lc_Space_TEXT) AS Line2_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 422, 28), @Lc_Space_TEXT) AS City_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 450, 2), @Lc_Space_TEXT) AS State_ADDR,
          ISNULL (SUBSTRING(LD.Record_TEXT, 452, 15), @Lc_Space_TEXT) AS Zip_ADDR,
          @Ld_Run_DATE AS FileLoad_DATE,
          @Lc_Process_No_INDC AS Process_INDC
     FROM #LoadDpr_P1 LD
    WHERE SUBSTRING(LD.Record_TEXT, 1, 1) NOT IN (@Lc_HeaderH_CODE, @Lc_TrailerT_CODE);
  
   SET @Li_RowCount_QNTY = @@ROWCOUNT;
  
   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO RECORD(S) TO PROCESS';
	   
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION';
     SET @Ls_SqlData_TEXT = 'Procedure_NAME = ' + @Ls_Procedure_NAME + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Error_NUMB = ' + CAST(@Ln_Error_NUMB AS VARCHAR)+ ', ErrorLine_NUMB = ' + CAST(@Ln_ErrorLine_NUMB AS VARCHAR);
       
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
	  @As_Procedure_NAME        = @Ls_Procedure_NAME,
	  @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
	  @As_Sql_TEXT              = @Ls_Sql_TEXT,
	  @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
	  @An_Error_NUMB            = @Ln_Error_NUMB,
	  @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
	  @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
	 SET @Ls_SqlData_TEXT = 'BateError_CODE = ' + @Lc_BateErrorE0944_CODE;

	 EXECUTE BATCH_COMMON$SP_BATE_LOG
	  @As_Process_NAME             = @Ls_Process_NAME,
	  @As_Procedure_NAME           = @Ls_Procedure_NAME,
	  @Ac_Job_ID                   = @Lc_Job_ID,
	  @Ad_Run_DATE                 = @Ld_Run_DATE,
	  @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
   
   SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

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

   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Li_RowCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT ,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   DROP TABLE #LoadDpr_P1;

   COMMIT TRANSACTION LoadDprTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION LoadDprTran;
    END;
   
   IF OBJECT_ID('tempdb..#LoadDpr_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadDpr_P1;
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
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
