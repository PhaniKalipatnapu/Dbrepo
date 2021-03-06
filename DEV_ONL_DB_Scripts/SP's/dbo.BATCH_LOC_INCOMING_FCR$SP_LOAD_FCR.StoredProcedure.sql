/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_LOAD_FCR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_LOAD_FCR
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_LOC_INCOMING_FCR$SP_LOAD_FCR reads the data file received from FCR 
					   and loads the data into the temporary tables for further processing based on the record type 
					   identifier values in the file. 
					   Record type FD - Case Acknowledgement records, data will be loaded into the 
										Temporary table LFCAD_Y1 
								   FS - Member/Person Acknowledgement records, data will be loaded into the 
										Temporary table LFPAD_Y1 
								   FT - Proactive response records, data will be loaded into the 
										Temporary table LFPDE_Y1
								   FF - Locate response records, data will be loaded into the 
										Temporary table LFLFP_Y1
								   FN - NDNH locate records, data will be loaded into the 
										Temporary table LFNQW_Y1,
										LFNWD_Y1, LFNUI_Y1 
								   FK - SVES records, data will be loaded into the 
										Temporary table LFSDE_Y1, LFSPR_Y1 
								   FW - DMDC records, data will be loaded into the 
										Temporary table LFDMD_Y1 
								   MC - MSFIDM records, data will be loaded into the 
										Temporary table LFMFD_Y1 
								   NC - NCOA records, data will be loaded into the 
										Temporary table LFNCA_Y1  
								   IM - Insurance match records, data will be loaded into the 
										Temporary table LFIMD_Y1, LFIMA_Y1
Frequency			 : Daily
Developed On		 : 03/28/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE
-----------------------------------------------------------------------------------------------------------------------					   
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_LOAD_FCR]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
  DECLARE  @Lc_Space_TEXT                                   CHAR(1) = ' ',
		   @Lc_ErrorTypeError_CODE							CHAR(1) = 'E',
		   @Lc_ErrorTypeWarning_CODE						CHAR(1)	= 'W',
           @Lc_StatusFailed_CODE                            CHAR(1) = 'F',
           @Lc_Yes_INDC                                     CHAR(1) = 'Y',
           @Lc_ProcessY_INDC                                CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE                           CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE                       CHAR(1) = 'A',
           @Lc_Empty_CODE                                   CHAR(1) = ' ',
           @Lc_WritetoReject_TEXT                           CHAR(1) = 'N',
           @Lc_RecPersonAcknowledgement_ID                  CHAR(2) = 'FS',
           @Lc_RecProactive_ID                              CHAR(2) = 'FT',
           @Lc_RecLocFpls_ID                                CHAR(2) = 'FF',
           @Lc_RecNdnh_ID                                   CHAR(2) = 'FN',
           @Lc_RecNcoa_ID                                   CHAR(2) = 'NC',
           @Lc_RecInsMatch_ID                               CHAR(2) = 'IM',
           @Lc_RecSves_ID                                   CHAR(2) = 'FK',
           @Lc_RecDmdc_ID                                   CHAR(2) = 'FW',
           @Lc_RecMsFidm_ID                                 CHAR(2) = 'MC',
           @Lc_LocRespAgencyNdnhUnemploymentInsurance_TEXT  CHAR(3) = 'H97',
           @Lc_LocRespAgencyNdnhQuarterlyWage_TEXT          CHAR(3) = 'H98',
           @Lc_LocRespAgencyNdnhW4_TEXT                     CHAR(3) = 'H99',
           @Lc_LocRespAgencyPrisoner_TEXT                   CHAR(3) = 'E07',
           @Lc_ErrorH1_CODE                                 CHAR(4) = NULL,
           @Lc_ErrorH2_CODE                                 CHAR(4) = NULL,
           @Lc_ErrorH3_CODE                                 CHAR(4) = NULL,
           @Lc_ErrorH4_CODE                                 CHAR(4) = NULL,
           @Lc_ErrorH5_CODE                                 CHAR(4) = NULL,
           @Lc_ValueN_CODE                                  CHAR(5) = 'N',
           @Lc_RecCaseAcknowledgement_ID                    CHAR(6) = 'FD',
           @Lc_JobLoadFcrResp_IDNO                          CHAR(7) = 'DEB0300',
           @Lc_Job_ID                                       CHAR(7) = 'DEB0300',
           @Lc_ErrorE0058_CODE                              CHAR(18) = 'E0058',
           @Lc_ErrorTe001_CODE                              CHAR(18) = 'TE001',
           @Lc_ErrorE0944_CODE                              CHAR(18) = 'E0944',
           @Lc_ErrorE1172_CODE                              CHAR(18) = 'E1172',
           @Lc_Successful_TEXT                              CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT                            CHAR(30) = 'BATCH',
           @Lc_Parmdateproblem_TEXT                         CHAR(30) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME                               VARCHAR(100) = 'SP_LOAD_FCR',
           @Ls_ErrordescNdnh_TEXT                           VARCHAR(100) = 'LOCATE SOURCE RESPONSE AGENCY CODE -H01 - NDNH DATA NOT AVAILABLE',
           @Ls_ErrordescRec_IDNO                            VARCHAR(100) = 'INVALID RECORD IDENTIFIER',
           @Ls_Process_NAME                                 VARCHAR(100) = 'BATCH_LOC_INCOMING_FCR',
           @Ls_CursorLoc_TEXT                               VARCHAR(200) = ' ',
           @Ls_Record_TEXT                                  VARCHAR(1500) = ' ';
  DECLARE  @Ln_Zero_NUMB									NUMERIC(1) = 0,
		   @Ln_HeaderError_QNTY								NUMERIC(2) = 0,
           @Ln_Header_QNTY									NUMERIC(2) = 0,
           @Ln_Trailer_QNTY									NUMERIC(2) = 0,
           @Ln_CommitFreqParm_QNTY							NUMERIC(5) = 0,
           @Ln_ExceptionThresholdParm_QNTY					NUMERIC(5) = 0,
           @Ln_NndnhHo1Rec_QNTY								NUMERIC(8) = 0,
           @Ln_FcrUnidentifiedRec_QNTY						NUMERIC(8) = 0,
           @Ln_PersonAckRec_QNTY							NUMERIC(8) = 0,
           @Ln_CaseAckRec_QNTY								NUMERIC(8) = 0,
           @Ln_ProactiveRec_QNTY							NUMERIC(8) = 0,
           @Ln_FplsRec_QNTY									NUMERIC(8) = 0,
           @Ln_NdnhUiRec_QNTY								NUMERIC(8) = 0,
           @Ln_NdnhQwRec_QNTY								NUMERIC(8) = 0,
           @Ln_NdnhW4Rec_QNTY								NUMERIC(8) = 0,
           @Ln_SvesPrisnorRec_QNTY							NUMERIC(8) = 0,
           @Ln_SvesDetailsRec_QNTY							NUMERIC(8) = 0,
           @Ln_DmdcRec_QNTY									NUMERIC(8) = 0,
           @Ln_MsfidmRec_QNTY								NUMERIC(8) = 0,
           @Ln_NcoaRec_QNTY									NUMERIC(8) = 0,
           @Ln_ImPart1Rec_QNTY								NUMERIC(8) = 0,
           @Ln_ImPart2Rec_QNTY								NUMERIC(8) = 0,
           @Ln_Rec_QNTY										NUMERIC(10) = 0,
           @Ln_ResponseRec_QNTY								NUMERIC(10) = 0,
           @Ln_Error_NUMB									NUMERIC(11),
           @Ln_ErrorLine_NUMB								NUMERIC(11),
           @Li_FetchStatus_QNTY								SMALLINT,
           @Li_RowCount_QNTY								INT,
           @Lc_Msg_CODE										CHAR(1) = '',
           @Ls_FileName_TEXT								VARCHAR(50) = '',
           @Ls_FileLocation_TEXT							VARCHAR(80) = '',
           @Ls_Sql_TEXT										VARCHAR(100) = '',
           @Ls_FileSource_TEXT								VARCHAR(130) = '',
           @Ls_SqlStmnt_TEXT								VARCHAR(200) = '',
           @Ls_Sqldata_TEXT									VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT						VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT							VARCHAR(4000),
           @Ld_Run_DATE										DATE,
           @Ld_Start_DATE									DATETIME2,
           @Ld_LastRun_DATE									DATETIME2;
  DECLARE @Ls_LoadFcrCur_TEXT								VARCHAR(1500) = '',
		  @Ls_LoadFcrUkCur_TEXT								VARCHAR(1500);

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   --Creating Temperory Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   CREATE TABLE #LoadFcrDetails_P1
    (
      Record_TEXT VARCHAR (1212)
    ); 
   
   SET @Lc_Job_ID = @Lc_JobLoadFcrResp_IDNO;
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   
   -- Selecting date run, date last run, commit freq, exception threshold details 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');

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
     RAISERROR(50001,16,1);
    END

   -- Validation 1:Check Whether the Job ran already on same day   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_Parmdateproblem_TEXT;

     RAISERROR(50001,16,1);
    END
   
   --Assign the Source File Location
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';   SET @Ls_FileSource_TEXT = '' + LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   IF @Ls_FileSource_TEXT = ''
    BEGIN
     
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadFcrDetails_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   SET @Ls_Sqldata_TEXT = '';

   EXEC (@Ls_SqlStmnt_TEXT);

   -- Transaction begins 
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   BEGIN TRANSACTION FCR_BATCH_LOAD;

   -- Delete all the processed records
   SET @Ls_Sql_TEXT = 'DELETE FROM LFCAD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED CASE ACK DETAILS FROM LOAD TABLE';

   DELETE LFCAD_Y1
    WHERE LFCAD_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFPAD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED PERSON ACK DETAILS FROM LOAD TABLE';

   DELETE LFPAD_Y1
    WHERE LFPAD_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFPDE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED PROACTIVE MATCH DETAILS FROM LOAD TABLE';

   DELETE LFPDE_Y1
    WHERE LFPDE_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFLFP_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED LOCATE FPLS DETAILS FROM LOAD TABLE';

   DELETE LFLFP_Y1
    WHERE LFLFP_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFNUI_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED NDNH UNEMPPLOYMENT DETAILS FROM LOAD TABLE';

   DELETE LFNUI_Y1
    WHERE LFNUI_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFNQW_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED NDNH QUARTERLY WAGE DETAILS FROM LOAD TABLE';

   DELETE LFNQW_Y1
    WHERE LFNQW_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFNWD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED NDNH W4 DETAILS FROM LOAD TABLE';

   DELETE LFNWD_Y1
    WHERE LFNWD_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFSDE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED SVES DETAILS FROM LOAD TABLE';

   DELETE LFSDE_Y1
    WHERE LFSDE_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFSPR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED SVES PRISONER DETAILS FROM LOAD TABLE';

   DELETE LFSPR_Y1
    WHERE LFSPR_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFDMD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED DMDC DETAILS FROM LOAD TABLE';

   DELETE LFDMD_Y1
    WHERE LFDMD_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFMFD_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED MSFIDM DETAILS FROM LOAD TABLE';

   DELETE LFMFD_Y1
    WHERE LFMFD_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LFNCA_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Message = ' + ', DELETING PROCESSED NCA DETAILS FROM LOAD TABLE';

   DELETE LFNCA_Y1
    WHERE LFNCA_Y1.Process_INDC = @Lc_ProcessY_INDC;
      
   SET @Ls_Sql_TEXT = 'DELETE FROM LFIMD_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', DELETING PROCESSED INSURANCE MATCH PART1 DETAILS FROM LOAD TABLE';

   DELETE LFIMD_Y1
    WHERE LFIMD_Y1.Process_INDC = @Lc_ProcessY_INDC;
    
   SET @Ls_Sql_TEXT = 'DELETE FROM LFIMA_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', DELETING PROCESSED INSURANCE MATCH PART2 DETAILS FROM LOAD TABLE';

   DELETE LFIMA_Y1
    WHERE LFIMA_Y1.Process_INDC = @Lc_ProcessY_INDC;
      
   -- Check for the transimission error codes in the header records and stop the load process if error exists
   SET @Lc_WritetoReject_TEXT = @Lc_ValueN_CODE;
   SET @Ln_HeaderError_QNTY = 0;

   SET @Ls_Sql_TEXT = 'READING HEADER RECORD ERROR COUNT IN THE FILE';   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_HeaderError_QNTY = COUNT(1)
     FROM #LoadFcrDetails_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 2) IN ('FE', 'FB')
      AND (SUBSTRING (Record_TEXT, 24, 4) IN ('5000', '5001', '5002', '5003',
											 '5004', '5005', '5006', '5007',
											 '5008', '5009')
      OR SUBSTRING (Record_TEXT, 28, 4) IN ('5000', '5001', '5002', '5003',
											 '5004', '5005', '5006', '5007',
                                             '5008', '5009')
      OR SUBSTRING (Record_TEXT, 32, 4) IN ('5000', '5001', '5002', '5003',
											 '5004', '5005', '5006', '5007',
											 '5008', '5009')
      OR SUBSTRING (Record_TEXT, 36, 4) IN ('5000', '5001', '5002', '5003',
											 '5004', '5005', '5006', '5007',
											 '5008', '5009')
      OR SUBSTRING (Record_TEXT, 40, 4) IN ('5000', '5001', '5002', '5003',
											 '5004', '5005', '5006', '5007',
											 '5008', '5009'));

   IF @Ln_HeaderError_QNTY <> 0
    BEGIN
     SET @Lc_WritetoReject_TEXT = @Lc_Yes_INDC;

     SET @Ls_Sql_TEXT = 'READING HEADER RECORD ERROR COUNT IN THE FILE';     SET @Ls_Sqldata_TEXT = '';

     SELECT TOP 1 @Ls_Record_TEXT = Record_TEXT
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) IN ('FE', 'FB')
        AND (SUBSTRING (Record_TEXT, 24, 4) IN ('5000', '5001', '5002', '5003',
											   '5004', '5005', '5006', '5007',
											   '5008', '5009')
        OR SUBSTRING (Record_TEXT, 28, 4) IN ('5000', '5001', '5002', '5003',
											   '5004', '5005', '5006', '5007',
                                               '5008', '5009')
        OR SUBSTRING (Record_TEXT, 32, 4) IN ('5000', '5001', '5002', '5003',
                                               '5004', '5005', '5006', '5007',
                                               '5008', '5009')
        OR SUBSTRING (Record_TEXT, 36, 4) IN ('5000', '5001', '5002', '5003',
                                               '5004', '5005', '5006', '5007',
                                               '5008', '5009')
        OR SUBSTRING (Record_TEXT, 40, 4) IN ('5000', '5001', '5002', '5003',
                                               '5004', '5005', '5006', '5007',
                                               '5008', '5009'));

     SET @Lc_ErrorH1_CODE = SUBSTRING(@Ls_Record_TEXT, 24, 4);
     SET @Lc_ErrorH2_CODE = SUBSTRING(@Ls_Record_TEXT, 28, 4);
     SET @Lc_ErrorH3_CODE = SUBSTRING(@Ls_Record_TEXT, 32, 4);
     SET @Lc_ErrorH4_CODE = SUBSTRING(@Ls_Record_TEXT, 36, 4);
     SET @Lc_ErrorH5_CODE = SUBSTRING(@Ls_Record_TEXT, 40, 4);
     SET @Ls_DescriptionError_TEXT = 'REGULAR BATCH HEADER WITH CRITICAL ERRORS';

     GOTO load_error_file;
    END

   /*   Check for the header record count and trailer count are the same 
        Check for the detailed record count and total number records in the trailer record are the same
   	 If either of the above checks are true, raise an error exception  
   */
   SET @Ln_Rec_QNTY = 0;
   
   SET @Ls_Sql_TEXT = 'READING RECORD COUNT IN THE TEMPORARY TABLE';   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Rec_QNTY = COUNT(1)
     FROM #LoadFcrDetails_P1 a ;

   SET @Ls_Sql_TEXT = 'RECORD_COUNT = ' + CAST(@Ln_Rec_QNTY AS CHAR(8));
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_ResponseRec_QNTY = (SELECT SUM(CAST(SUBSTRING(Record_TEXT, 131, 11) AS NUMERIC (8)))
                                    FROM #LoadFcrDetails_P1 a
                                   WHERE SUBSTRING(Record_TEXT, 1, 2) = 'FX');

   SET @Ls_Sql_TEXT = 'READING HEADER RECORD COUNT IN THE TEMPORARY TABLE';   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Header_QNTY = COUNT(1)
     FROM #LoadFcrDetails_P1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) IN ('FB', 'FE', 'FL');

   SET @Ls_Sql_TEXT = 'READING TRAILER RECORD COUNT IN THE TEMPORARY TABLE';   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Trailer_QNTY = COUNT(1)
     FROM #LoadFcrDetails_P1 a
    WHERE SUBSTRING(Record_TEXT, 1, 2) = 'FX';

   IF @Ln_Header_QNTY <> @Ln_Trailer_QNTY
       OR @Ln_ResponseRec_QNTY <> @Ln_Rec_QNTY
    BEGIN
     SET @Ls_Sql_TEXT = 'RECORD_COUNT_IN_FILE = ' + CAST(@Ln_Rec_QNTY AS CHAR(8)) + ', TRAILER_COUNT = ' + CAST(@Ln_ResponseRec_QNTY AS CHAR(8));     SET @Ls_DescriptionError_TEXT = 'DETAIL RECORD COUNT IN FILE NOT MATCHES WITH TRAILER COUNT';

     RAISERROR(50001,16,1);
    END

   -- Add the trailer and header record count to the record number field
   SET @Ln_Rec_QNTY = 0;
   
   -- Load the case acknowledgement data into the table temporary LFCAD_Y1
   SET @Ln_CaseAckRec_QNTY = 0;
   SET @Ls_Sql_TEXT = 'INSERT INTO LFCAD_Y1';
   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_CaseAckRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = 'FD';

     IF @Ln_CaseAckRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFCAD_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFCAD_Y1
              (Rec_ID,
               Action_CODE,
               Case_IDNO,
               TypeCase_CODE,
               Order_INDC,
               CountyFips_CODE,
               CaseUserField_NUMB,
               CasePrev_IDNO,
               Batch_NUMB,
               CaseAcknowledgement_CODE,
               Error1_CODE,
               Error2_CODE,
               Error3_CODE,
               Error4_CODE,
               Error5_CODE,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 1), @Lc_Space_TEXT))) AS Action_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 4, 15), @Lc_Space_TEXT))) AS Case_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 1), @Lc_Space_TEXT))) AS TypeCase_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 1), @Lc_Space_TEXT))) AS Order_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 21, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 26, 15), @Lc_Space_TEXT))) AS CaseUserField_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 41, 15), @Lc_Space_TEXT))) AS CasePrev_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 641, 6), @Lc_Space_TEXT))) AS Batch_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 647, 5), @Lc_Space_TEXT))) AS CaseAcknowledgement_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 652, 5), @Lc_Space_TEXT))) AS Error1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 657, 5), @Lc_Space_TEXT))) AS Error2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 662, 5), @Lc_Space_TEXT))) AS Error3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 667, 5), @Lc_Space_TEXT))) AS Error4_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 672, 5), @Lc_Space_TEXT))) AS Error5_CODE,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a 
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecCaseAcknowledgement_ID; 
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         
         SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LFCAD_Y1';

         RAISERROR(50001,16,1);
        END
       ELSE
		 BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Load the Person acknowledgement data into the temporary table LFCAD_Y1
   SET @Ls_Sql_TEXT = 'INSERT INTO LFPAD_Y1';   SET @Ln_PersonAckRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_PersonAckRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = 'FS';

     IF @Ln_PersonAckRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFPAD_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFPAD_Y1
              (Rec_ID,
               Action_CODE,
               Case_IDNO,
               FcrReserved_CODE,
               UserField_NAME,
               CountyFips_CODE,
               TypeLocRequest_CODE,
               BundleResult_INDC,
               TypeParticipant_CODE,
               FamilyViolence_CODE,
               MemberMci_IDNO,
               MemberSex_CODE,
               Birth_DATE,
               MemberSsn_NUMB,
               PreviousMemberSsn_NUMB,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               BirthCity_NAME,
               BirthStCountry_CODE,
               FirstFather_NAME,
               MiddleFather_NAME,
               LastFather_NAME,
               FirstMother_NAME,
               MiddleMother_NAME,
               LastMother_NAME,
               IrsU1Ssn_NUMB,
               Additional1Ssn_NUMB,
               Additional2Ssn_NUMB,
               FirstAlias1_NAME,
               MiddleAlias1_NAME,
               LastAlias1_NAME,
               FirstAlias2_NAME,
               MiddleAlias2_NAME,
               LastAlias2_NAME,
               FirstAlias3_NAME,
               MiddleAlias3_NAME,
               LastAlias3_NAME,
               FirstAlias4_NAME,
               MiddleAlias4_NAME,
               LastAlias4_NAME,
               NewMemberMci_IDNO,
               Irs1099_INDC,
               LocateSource1_CODE,
               LocateSource2_CODE,
               LocateSource3_CODE,
               LocateSource4_CODE,
               LocateSource5_CODE,
               LocateSource6_CODE,
               LocateSource7_CODE,
               LocateSource8_CODE,
               Enumeration_CODE,
               CorrectedSsn_NUMB,
               Multiple1Ssn_NUMB,
               Multiple2Ssn_NUMB,
               Multiple3Ssn_NUMB,
               DateBirthSsa_INDC,
               Batch_NUMB,
               Death_DATE,
               ZipLastResiSsa_CODE,
               ZipOfPaymentSsa_CODE,
               PrimarySsn_NUMB,
               FirstPrimary_NAME,
               MiddlePrimary_NAME,
               LastPrimary_NAME,
               Acknowledge_CODE,
               Error1_CODE,
               Error2_CODE,
               Error3_CODE,
               Error4_CODE,
               Error5_CODE,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 1), @Lc_Space_TEXT))) AS Action_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 4, 15), @Lc_Space_TEXT))) AS Case_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS FcrReserved_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 21, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 36, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 41, 2), @Lc_Space_TEXT))) AS TypeLocRequest_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 43, 1), @Lc_Space_TEXT))) AS BundleResult_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 44, 2), @Lc_Space_TEXT))) AS TypeParticipant_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 46, 2), @Lc_Space_TEXT))) AS FamilyViolence_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 48, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 63, 1), @Lc_Space_TEXT))) AS MemberSex_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 8), @Lc_Space_TEXT))) AS Birth_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 72, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 81, 9), @Lc_Space_TEXT))) AS PreviousMemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 90, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 106, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 122, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 152, 16), @Lc_Space_TEXT))) AS BirthCity_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 168, 4), @Lc_Space_TEXT))) AS BirthStCountry_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 172, 16), @Lc_Space_TEXT))) AS FirstFather_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 188, 1), @Lc_Space_TEXT))) AS MiddleFather_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 189, 16), @Lc_Space_TEXT))) AS LastFather_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 205, 16), @Lc_Space_TEXT))) AS FirstMother_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 221, 1), @Lc_Space_TEXT))) AS MiddleMother_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 222, 16), @Lc_Space_TEXT))) AS LastMother_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 238, 9), @Lc_Space_TEXT))) AS IrsU1Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 247, 9), @Lc_Space_TEXT))) AS Additional1Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 256, 9), @Lc_Space_TEXT))) AS Additional2Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 265, 16), @Lc_Space_TEXT))) AS FirstAlias1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 281, 16), @Lc_Space_TEXT))) AS MiddleAlias1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 297, 30), @Lc_Space_TEXT))) AS LastAlias1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 327, 16), @Lc_Space_TEXT))) AS FirstAlias2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 343, 16), @Lc_Space_TEXT))) AS MiddleAlias2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 359, 30), @Lc_Space_TEXT))) AS LastAlias2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 389, 16), @Lc_Space_TEXT))) AS FirstAlias3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 405, 16), @Lc_Space_TEXT))) AS MiddleAlias3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 421, 30), @Lc_Space_TEXT))) AS LastAlias3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 451, 16), @Lc_Space_TEXT))) AS FirstAlias4_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 467, 16), @Lc_Space_TEXT))) AS MiddleAlias4_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 483, 30), @Lc_Space_TEXT))) AS LastAlias4_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 513, 15), @Lc_Space_TEXT))) AS NewMemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 528, 1), @Lc_Space_TEXT))) AS Irs1099_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 529, 3), @Lc_Space_TEXT))) AS LocateSource1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 532, 3), @Lc_Space_TEXT))) AS LocateSource2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 535, 3), @Lc_Space_TEXT))) AS LocateSource3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 538, 3), @Lc_Space_TEXT))) AS LocateSource4_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 541, 3), @Lc_Space_TEXT))) AS LocateSource5_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 544, 3), @Lc_Space_TEXT))) AS LocateSource6_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 547, 3), @Lc_Space_TEXT))) AS LocateSource7_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 550, 3), @Lc_Space_TEXT))) AS LocateSource8_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 641, 1), @Lc_Space_TEXT))) AS Enumeration_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 642, 9), @Lc_Space_TEXT))) AS CorrectedSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 651, 9), @Lc_Space_TEXT))) AS Multiple1Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 660, 9), @Lc_Space_TEXT))) AS Multiple2Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 669, 9), @Lc_Space_TEXT))) AS Multiple3Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 678, 1), @Lc_Space_TEXT))) AS DateBirthSsa_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 679, 6), @Lc_Space_TEXT))) AS Batch_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 685, 8), @Lc_Space_TEXT))) AS Death_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 693, 5), @Lc_Space_TEXT))) AS ZipLastResiSsa_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 698, 5), @Lc_Space_TEXT))) AS ZipOfPaymentSsa_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 703, 9), @Lc_Space_TEXT))) AS PrimarySsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 712, 16), @Lc_Space_TEXT))) AS FirstPrimary_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 728, 16), @Lc_Space_TEXT))) AS MiddlePrimary_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 744, 30), @Lc_Space_TEXT))) AS LastPrimary_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 774, 5), @Lc_Space_TEXT))) AS Acknowledge_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 779, 5), @Lc_Space_TEXT))) AS Error1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 784, 5), @Lc_Space_TEXT))) AS Error2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 789, 5), @Lc_Space_TEXT))) AS Error3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 794, 5), @Lc_Space_TEXT))) AS Error4_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 799, 5), @Lc_Space_TEXT))) AS Error5_CODE,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecPersonAcknowledgement_ID; 	    

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         
         SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LFPAD_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Load the FCR proactive match details data into the temporary table LFPDE_Y1
   SET @Ls_Sql_TEXT = 'INSERT INTO LFPDE_Y1';   SET @Ln_ProactiveRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_ProactiveRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecProactive_ID;

     IF @Ln_ProactiveRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFPDE_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFPDE_Y1
              (Rec_ID,
               TerritoryFips_CODE,
               TypeAction_CODE,
               UserField_NAME,
               CountyFips_CODE,
               Batch_NUMB,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               MatchedSubmittedSsn_NUMB,
               MemberMci_IDNO,
               --FcrSsnLast_INDC, 
               CaseSubmitted_IDNO,
               Response_CODE,
               CaseMatched_IDNO,
               StateCaseMatched_CODE,
               TypeCaseMatched_CODE,
               CountyFcrMatched_IDNO,
               RegistrationMatched_DATE,
               OrderCaseMatched_INDC,
               TypeParticipantMatched_CODE,
               MatchedMemberMci_IDNO,
               DeathMatched_DATE,
               F1AddtlMatched1_NAME,
               M1AddtlMatched1_NAME,
               L1AddtlMatched1_NAME,
               F1AddtlMatched2_NAME,
               M1AddtlMatched2_NAME,
               L1AddtlMatched2_NAME,
               F1AddtlMatched3_NAME,
               M1AddtlMatched3_NAME,
               L1AddtlMatched3_NAME,
               F1AddtlMatched4_NAME,
               M1AddtlMatched4_NAME,
               L1AddtlMatched4_NAME,
               MemberAssociated1Ssn_NUMB,
               F1Associated1_NAME,
               M1Associated1_NAME,
               L1Associated1_NAME,
               MemberSexAssociated1_CODE,
               TypePartAssociated1_CODE,
               MemberMciAssociated1_IDNO,
               BirthAssociated1_DATE,
               DeathAssociated1_DATE,
               MemberAssociated2Ssn_NUMB,
               F1Associated2_NAME,
               M1Associated2_NAME,
               L1Associated2_NAME,
               MemberSexAssociated2_CODE,
               TypePartAssociated2_CODE,
               MemberMciAssociated2_IDNO,
               BirthAssociated2_DATE,
               DeathAssociated2_DATE,
               MemberAssociated3Ssn_NUMB,
               F1Associated3_NAME,
               M1Associated3_NAME,
               L1Associated3_NAME,
               MemberSexAssociated3_CODE,
               TypePartAssociated3_CODE,
               MemberMciAssociated3_IDNO,
               BirthAssociated3_DATE,
               DeathAssociated3_DATE,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 2), @Lc_Space_TEXT))) AS TerritoryFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 5, 1), @Lc_Space_TEXT))) AS TypeAction_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 6, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 21, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 26, 6), @Lc_Space_TEXT))) AS Batch_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 32, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 48, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 94, 9), @Lc_Space_TEXT))) AS MatchedSubmittedSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 103, 10), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 118, 6), @Lc_Space_TEXT))) AS CaseSubmitted_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 133, 2), @Lc_Space_TEXT))) AS Response_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 135, 15), @Lc_Space_TEXT))) AS CaseMatched_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 150, 2), @Lc_Space_TEXT))) AS StateCaseMatched_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 152, 1), @Lc_Space_TEXT))) AS TypeCaseMatched_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 153, 3), @Lc_Space_TEXT))) AS CountyFcrMatched_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 158, 8), @Lc_Space_TEXT))) AS RegistrationMatched_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 166, 1), @Lc_Space_TEXT))) AS OrderCaseMatched_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 167, 2), @Lc_Space_TEXT))) AS TypeParticipantMatched_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 169, 15), @Lc_Space_TEXT))) AS MatchedMemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 184, 8), @Lc_Space_TEXT))) AS DeathMatched_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 192, 16), @Lc_Space_TEXT))) AS F1AddtlMatched1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 208, 16), @Lc_Space_TEXT))) AS M1AddtlMatched1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 224, 30), @Lc_Space_TEXT))) AS L1AddtlMatched1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 254, 16), @Lc_Space_TEXT))) AS F1AddtlMatched2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 270, 16), @Lc_Space_TEXT))) AS M1AddtlMatched2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 286, 30), @Lc_Space_TEXT))) AS L1AddtlMatched2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 316, 16), @Lc_Space_TEXT))) AS F1AddtlMatched3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 332, 16), @Lc_Space_TEXT))) AS M1AddtlMatched3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 348, 30), @Lc_Space_TEXT))) AS L1AddtlMatched3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 378, 16), @Lc_Space_TEXT))) AS F1AddtlMatched4_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 394, 16), @Lc_Space_TEXT))) AS M1AddtlMatched4_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 410, 30), @Lc_Space_TEXT))) AS L1AddtlMatched4_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 440, 9), @Lc_Space_TEXT))) AS MemberAssociated1Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 449, 16), @Lc_Space_TEXT))) AS F1Associated1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 465, 16), @Lc_Space_TEXT))) AS M1Associated1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 481, 30), @Lc_Space_TEXT))) AS L1Associated1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 511, 1), @Lc_Space_TEXT))) AS MemberSexAssociated1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 512, 2), @Lc_Space_TEXT))) AS TypePartAssociated1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 514, 15), @Lc_Space_TEXT))) AS MemberMciAssociated1_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 529, 8), @Lc_Space_TEXT))) AS BirthAssociated1_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 537, 8), @Lc_Space_TEXT))) AS DeathAssociated1_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 545, 9), @Lc_Space_TEXT))) AS MemberAssociated2Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 554, 16), @Lc_Space_TEXT))) AS F1Associated2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 570, 16), @Lc_Space_TEXT))) AS M1Associated2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 586, 30), @Lc_Space_TEXT))) AS L1Associated2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 616, 1), @Lc_Space_TEXT))) AS MemberSexAssociated2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 617, 2), @Lc_Space_TEXT))) AS TypePartAssociated2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 619, 15), @Lc_Space_TEXT))) AS MemberMciAssociated2_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 634, 8), @Lc_Space_TEXT))) AS BirthAssociated2_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 642, 8), @Lc_Space_TEXT))) AS DeathAssociated2_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 650, 9), @Lc_Space_TEXT))) AS MemberAssociated3Ssn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 659, 16), @Lc_Space_TEXT))) AS F1Associated3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 675, 16), @Lc_Space_TEXT))) AS M1Associated3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 691, 30), @Lc_Space_TEXT))) AS L1Associated3_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 721, 1), @Lc_Space_TEXT))) AS MemberSexAssociated3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 722, 2), @Lc_Space_TEXT))) AS TypePartAssociated3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 724, 15), @Lc_Space_TEXT))) AS MemberMciAssociated3_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 739, 8), @Lc_Space_TEXT))) AS BirthAssociated3_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 747, 8), @Lc_Space_TEXT))) AS DeathAssociated3_DATE,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecProactive_ID; 	    
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO LFPDE_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for locate response record             
   -- Load the FCR FPLS Loacte Response Details into the temporary table LFLFP_Y1
   SET @Ls_Sql_TEXT = 'INSERT INTO LFLFP_Y1';   SET @Ln_FplsRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_FplsRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a 
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecLocFpls_ID;

     IF @Ln_FplsRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFLFP_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFLFP_Y1
              (Rec_ID,
               StateTerr_CODE,
               LocSourceResp_CODE,
               NameSent_CODE,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               FirstAddl1_NAME,
               MiddleAddl1_NAME,
               LastAddl1_NAME,
               FirstAddl2_NAME,
               MiddleAddl2_NAME,
               LastAddl2_NAME,
               NameReturned_CODE,
               Returned_NAME,
               MemberSsn_NUMB,
               MemberMci_IDNO,
               UserField_NAME,
               CountyFips_CODE,
               LocReqType_CODE,
               AddrLocDate_CODE,
               LocAddress_DATE,
               LocStatusResp_CODE,
               Employer_NAME,
               AddrLocFmt_CODE,
               Returned_ADDR,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrScrub3_CODE,
               FcrDodData_TEXT,
               FcrReservedFuture1_CODE,
               FcrReservedFuture2_CODE,
               FcrReservedFuture3_CODE,
               FcrSortState_CODE,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateTerr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 61, 3), @Lc_Space_TEXT))) AS LocSourceResp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 1), @Lc_Space_TEXT))) AS NameSent_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 65, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 81, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 97, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 16), @Lc_Space_TEXT))) AS FirstAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 143, 16), @Lc_Space_TEXT))) AS MiddleAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 159, 30), @Lc_Space_TEXT))) AS LastAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 189, 16), @Lc_Space_TEXT))) AS FirstAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 205, 16), @Lc_Space_TEXT))) AS MiddleAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 221, 30), @Lc_Space_TEXT))) AS LastAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 251, 1), @Lc_Space_TEXT))) AS NameReturned_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 252, 62), @Lc_Space_TEXT))) AS Returned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 338, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 356, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 2), @Lc_Space_TEXT))) AS LocReqType_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 366, 1), @Lc_Space_TEXT))) AS AddrLocDate_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 367, 8), @Lc_Space_TEXT))) AS LocAddress_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 375, 2), @Lc_Space_TEXT))) AS LocStatusResp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 45), @Lc_Space_TEXT))) AS Employer_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 432, 1), @Lc_Space_TEXT))) AS AddrLocFmt_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 433, 234), @Lc_Space_TEXT))) AS Returned_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 667, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 669, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 671, 2), @Lc_Space_TEXT))) AS AddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 701, 212), @Lc_Space_TEXT))) AS FcrDodData_TEXT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 913, 2), @Lc_Space_TEXT))) AS FcrReservedFuture1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 915, 2), @Lc_Space_TEXT))) AS FcrReservedFuture2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 917, 2), @Lc_Space_TEXT))) AS FcrReservedFuture3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS FcrSortState_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 15), @Lc_Space_TEXT))) AS Zip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecLocFpls_ID; 	    
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO LFLFP_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for NDNH locate response record             
   -- Load the FCR NDNH Loacte Response Details into the temporary table LFNUI_Y1, 
   -- if the source is Unemployment Insurance
   SET @Ls_Sql_TEXT = 'INSERT INTO LFNUI_Y1 ';   SET @Ln_NdnhUiRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_NdnhUiRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a 
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNdnh_ID
        AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyNdnhUnemploymentInsurance_TEXT;

     IF @Ln_NdnhUiRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFNUI_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFNUI_Y1
              (Rec_ID,
               TypeMatchNdnh_CODE,
               StateTerr_CODE,
               LocSourceRespAgency_CODE,
               NameSendMatched_CODE,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               FirstAddl1_NAME,
               MiddleAddl1_NAME,
               LastAddl1_NAME,
               FirstAddl2_NAME,
               MiddleAddl2_NAME,
               LastAddl2_NAME,
               NameReturned_CODE,
               FirstReturned_NAME,
               MiddleReturned_NAME,
               LastReturned_NAME,
               MemberReturnedSsn_NUMB,
               MemberMci_IDNO,
               UserField_NAME,
               CountyFips_CODE,
               LocateRequestType_CODE,
               AddressFormat_CODE,
               OfAddress_DATE,
               LocResponse_CODE,
               CorrectedMultiSsn_NUMB,
               Employer_NAME,
               Line1Old_ADDR,
               Line2Old_ADDR,
               Line3Old_ADDR,
               Line4Old_ADDR,
               CityOld_ADDR,
               StateOld_ADDR,
               ZipOld_ADDR,
               ForeignCountry_CODE,
               ForeignCountry_NAME,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrScrub3_CODE,
               StateReporting_CODE,
               Benefit_AMNT,
               SsnMatch_CODE,
               QtrReporting_CODE,
               TypeParticipant_CODE,
               StateSort_CODE,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 1), @Lc_Space_TEXT))) AS TypeMatchNdnh_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateTerr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 61, 3), @Lc_Space_TEXT))) AS LocSourceRespAgency_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 1), @Lc_Space_TEXT))) AS NameSendMatched_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 65, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 81, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 97, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 16), @Lc_Space_TEXT))) AS FirstAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 143, 16), @Lc_Space_TEXT))) AS MiddleAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 159, 30), @Lc_Space_TEXT))) AS LastAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 189, 16), @Lc_Space_TEXT))) AS FirstAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 205, 16), @Lc_Space_TEXT))) AS MiddleAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 221, 30), @Lc_Space_TEXT))) AS LastAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 251, 1), @Lc_Space_TEXT))) AS NameReturned_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 252, 16), @Lc_Space_TEXT))) AS FirstReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 268, 16), @Lc_Space_TEXT))) AS MiddleReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 284, 30), @Lc_Space_TEXT))) AS LastReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS MemberReturnedSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 338, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 356, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 2), @Lc_Space_TEXT))) AS LocateRequestType_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 366, 1), @Lc_Space_TEXT))) AS AddressFormat_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 367, 8), @Lc_Space_TEXT))) AS OfAddress_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 375, 2), @Lc_Space_TEXT))) AS LocResponse_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 377, 9), @Lc_Space_TEXT))) AS CorrectedMultiSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 45), @Lc_Space_TEXT))) AS Employer_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 433, 40), @Lc_Space_TEXT))) AS Line1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 473, 40), @Lc_Space_TEXT))) AS Line2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 513, 40), @Lc_Space_TEXT))) AS Line3Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 553, 40), @Lc_Space_TEXT))) AS Line4Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 593, 30), @Lc_Space_TEXT))) AS CityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 623, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 625, 15), @Lc_Space_TEXT))) AS ZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 640, 2), @Lc_Space_TEXT))) AS ForeignCountry_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 642, 25), @Lc_Space_TEXT))) AS ForeignCountry_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 667, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 669, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 671, 2), @Lc_Space_TEXT))) AS AddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 701, 2), @Lc_Space_TEXT))) AS StateReporting_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 703, 11), @Lc_Space_TEXT))) AS Benefit_AMNT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 725, 1), @Lc_Space_TEXT))) AS SsnMatch_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 726, 5), @Lc_Space_TEXT))) AS QtrReporting_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 911, 2), @Lc_Space_TEXT))) AS TypeParticipant_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS StateSort_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 15), @Lc_Space_TEXT))) AS Zip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNdnh_ID
          AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyNdnhUnemploymentInsurance_TEXT;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO LoadFcrNdnhUnemploymentInsuranceDetails_T1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for NDNH record             
   -- Load the FCR NDNH Quarterly Wage Details into the temporary table LFNQW_Y1, 
   -- if the source is Quarterly Wage  
   SET @Ls_Sql_TEXT = 'INSERT INTO LFNQW_Y1';   SET @Ln_NdnhQwRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_NdnhQwRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a 
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNdnh_ID
        AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyNdnhQuarterlyWage_TEXT;

     IF @Ln_NdnhQwRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFNQW_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFNQW_Y1
              (Rec_ID,
               TypeMatchNdnh_CODE,
               StateTerr_CODE,
               LocSourceRespAgency_CODE,
               NameSendMatched_CODE,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               FirstAddl1_NAME,
               MiddleAddl1_NAME,
               LastAddl1_NAME,
               FirstAddl2_NAME,
               MiddleAddl2_NAME,
               LastAddl2_NAME,
               NameReturned_CODE,
               FirstReturned_NAME,
               MiddleReturned_NAME,
               LastReturned_NAME,
               MemberReturnedSsn_NUMB,
               MemberMci_IDNO,
               UserField_NAME,
               CountyFips_CODE,
               LocateRequestType_CODE,
               AddressFormat_CODE,
               OfAddress_DATE,
               LocResponse_CODE,
               CorrectedMultiSsn_NUMB,
               Employer_NAME,
               Line1Old_ADDR,
               Line2Old_ADDR,
               Line3Old_ADDR,
               Line4Old_ADDR,
               CityOld_ADDR,
               StateOld_ADDR,
               ZipOld_ADDR,
               ForeignCountry_CODE,
               ForeignCountry_NAME,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrScrub3_CODE,
               StateReporting_CODE,
               TypeAddress_CODE,
               Wage_AMNT,
               FederalEin_IDNO,
               SsnMatch_CODE,
               QtrReporting_CODE,
               AgencyReporting_NAME,
               DodAgencyStatus_CODE,
               StateEin_IDNO,
               TypeParticipant_CODE,
               StateSort_CODE,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 1), @Lc_Space_TEXT))) AS TypeMatchNdnh_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateTerr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 61, 3), @Lc_Space_TEXT))) AS LocSourceRespAgency_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 1), @Lc_Space_TEXT))) AS NameSendMatched_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 65, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 81, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 97, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 16), @Lc_Space_TEXT))) AS FirstAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 143, 16), @Lc_Space_TEXT))) AS MiddleAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 159, 30), @Lc_Space_TEXT))) AS LastAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 189, 16), @Lc_Space_TEXT))) AS FirstAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 205, 16), @Lc_Space_TEXT))) AS MiddleAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 221, 30), @Lc_Space_TEXT))) AS LastAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 251, 1), @Lc_Space_TEXT))) AS NameReturned_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 252, 16), @Lc_Space_TEXT))) AS FirstReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 268, 16), @Lc_Space_TEXT))) AS MiddleReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 284, 30), @Lc_Space_TEXT))) AS LastReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS MemberReturnedSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 338, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 356, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 2), @Lc_Space_TEXT))) AS LocateRequestType_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 366, 1), @Lc_Space_TEXT))) AS AddressFormat_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 367, 8), @Lc_Space_TEXT))) AS OfAddress_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 375, 2), @Lc_Space_TEXT))) AS LocResponse_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 377, 9), @Lc_Space_TEXT))) AS CorrectedMultiSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 45), @Lc_Space_TEXT))) AS Employer_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 433, 40), @Lc_Space_TEXT))) AS Line1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 473, 40), @Lc_Space_TEXT))) AS Line2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 513, 40), @Lc_Space_TEXT))) AS Line3Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 553, 40), @Lc_Space_TEXT))) AS Line4Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 593, 30), @Lc_Space_TEXT))) AS CityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 623, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 625, 15), @Lc_Space_TEXT))) AS ZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 640, 2), @Lc_Space_TEXT))) AS ForeignCountry_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 642, 25), @Lc_Space_TEXT))) AS ForeignCountry_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 667, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 669, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 671, 2), @Lc_Space_TEXT))) AS AddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 701, 2), @Lc_Space_TEXT))) AS StateReporting_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 703, 1), @Lc_Space_TEXT))) AS TypeAddress_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 704, 11), @Lc_Space_TEXT))) AS Wage_AMNT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 715, 9), @Lc_Space_TEXT))) AS FederalEin_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 725, 1), @Lc_Space_TEXT))) AS SsnMatch_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 726, 5), @Lc_Space_TEXT))) AS QtrReporting_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 731, 9), @Lc_Space_TEXT))) AS AgencyReporting_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 740, 1), @Lc_Space_TEXT))) AS DodAgencyStatus_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 741, 12), @Lc_Space_TEXT))) AS StateEin_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 911, 2), @Lc_Space_TEXT))) AS TypeParticipant_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS StateSort_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 10), @Lc_Space_TEXT))) AS Zip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNdnh_ID
          AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyNdnhQuarterlyWage_TEXT;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO LFNQW_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for NDNH record             
   -- Load the FCR NDNH W4 Details into the temporary table LFNWD_Y1, 
   -- if the source is W4  
   SET @Ls_Sql_TEXT = 'INSERT INTO LFNWD_Y1';   SET @Ln_NdnhW4Rec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_NdnhW4Rec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNdnh_ID
        AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyNdnhW4_TEXT;

     IF @Ln_NdnhW4Rec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFNWD_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFNWD_Y1
              (Rec_ID,
               TypeMatchNdnh_CODE,
               StateTerr_CODE,
               LocSourceRespAgency_CODE,
               NameSendMatched_CODE,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               FirstAddl1_NAME,
               MiddleAddl1_NAME,
               LastAddl1_NAME,
               FirstAddl2_NAME,
               MiddleAddl2_NAME,
               LastAddl2_NAME,
               NameReturned_CODE,
               FirstReturned_NAME,
               MiddleReturned_NAME,
               LastReturned_NAME,
               MemberReturnedSsn_NUMB,
               MemberMci_IDNO,
               UserField_NAME,
               CountyFips_CODE,
               LocateRequestType_CODE,
               AddressFormat_CODE,
               OfAddress_DATE,
               LocResponse_CODE,
               CorrectedMultiSsn_NUMB,
               Employer_NAME,
               Line1Old_ADDR,
               Line2Old_ADDR,
               Line3Old_ADDR,
               Line4Old_ADDR,
               CityOld_ADDR,
               StateOld_ADDR,
               ZipOld_ADDR,
               ForeignCountry_CODE,
               ForeignCountry_NAME,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrScrub3_CODE,
               StateReporting_CODE,
               TypeAddress_CODE,
               Birth_DATE,
               Hire_DATE,
               FederalEin_IDNO,
               SsnMatch_CODE,
               AgencyReporting_NAME,
               DodAgencyStatus_CODE,
               StateEin_IDNO,
               StateHire_CODE,
               TypeParticipant_CODE,
               StateSort_CODE,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 1), @Lc_Space_TEXT))) AS TypeMatchNdnh_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateTerr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 61, 3), @Lc_Space_TEXT))) AS LocSourceRespAgency_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 1), @Lc_Space_TEXT))) AS NameSendMatched_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 65, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 81, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 97, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 16), @Lc_Space_TEXT))) AS FirstAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 143, 16), @Lc_Space_TEXT))) AS MiddleAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 159, 30), @Lc_Space_TEXT))) AS LastAddl1_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 189, 16), @Lc_Space_TEXT))) AS FirstAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 205, 16), @Lc_Space_TEXT))) AS MiddleAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 221, 30), @Lc_Space_TEXT))) AS LastAddl2_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 251, 1), @Lc_Space_TEXT))) AS NameReturned_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 252, 16), @Lc_Space_TEXT))) AS FirstReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 268, 16), @Lc_Space_TEXT))) AS MiddleReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 284, 30), @Lc_Space_TEXT))) AS LastReturned_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS MemberReturnedSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 338, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 356, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 2), @Lc_Space_TEXT))) AS LocateRequestType_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 366, 1), @Lc_Space_TEXT))) AS AddressFormat_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 367, 8), @Lc_Space_TEXT))) AS OfAddress_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 375, 2), @Lc_Space_TEXT))) AS LocResponse_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 377, 9), @Lc_Space_TEXT))) AS CorrectedMultiSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 45), @Lc_Space_TEXT))) AS Employer_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 433, 40), @Lc_Space_TEXT))) AS Line1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 473, 40), @Lc_Space_TEXT))) AS Line2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 513, 40), @Lc_Space_TEXT))) AS Line3Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 553, 40), @Lc_Space_TEXT))) AS Line4Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 593, 30), @Lc_Space_TEXT))) AS CityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 623, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 625, 15), @Lc_Space_TEXT))) AS ZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 640, 2), @Lc_Space_TEXT))) AS ForeignCountry_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 642, 25), @Lc_Space_TEXT))) AS ForeignCountry_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 667, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 669, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 671, 2), @Lc_Space_TEXT))) AS AddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 701, 2), @Lc_Space_TEXT))) AS StateReporting_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 703, 1), @Lc_Space_TEXT))) AS TypeAddress_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 704, 8), @Lc_Space_TEXT))) AS Birth_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 712, 8), @Lc_Space_TEXT))) AS Hire_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 720, 9), @Lc_Space_TEXT))) AS FederalEin_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 729, 1), @Lc_Space_TEXT))) AS SsnMatch_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 730, 9), @Lc_Space_TEXT))) AS AgencyReporting_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 739, 1), @Lc_Space_TEXT))) AS DodAgencyStatus_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 740, 12), @Lc_Space_TEXT))) AS StateEin_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 752, 2), @Lc_Space_TEXT))) AS StateHire_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 911, 2), @Lc_Space_TEXT))) AS TypeParticipant_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS StateSort_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 10), @Lc_Space_TEXT))) AS Zip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNdnh_ID
          AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyNdnhW4_TEXT; 

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO LFNWD_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for the NDNH records whose source is not Unemployment Insurance or Quarterly Wage or W4 and
   -- insert these records into BATE_Y1 table 
   
   DECLARE LoadFcr_CUR INSENSITIVE CURSOR FOR
    SELECT Record_TEXT
      FROM #LoadFcrDetails_P1 a
     WHERE SUBSTRING(Record_TEXT, 1, 2) = 'FN'
       AND SUBSTRING(Record_TEXT, 61, 3) NOT IN ('H97', 'H98', 'H99');

   OPEN LoadFcr_CUR;

   SET @Ln_NndnhHo1Rec_QNTY = 0;

   FETCH NEXT FROM LoadFcr_CUR INTO @Ls_LoadFcrCur_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process NDNH records whose source is not UI, QW or W4
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     --Write to BATE_Y1 
     SET @Ln_NndnhHo1Rec_QNTY = @Ln_NndnhHo1Rec_QNTY + 1;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG ';     
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_NndnhHo1Rec_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0058_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrordescNdnh_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Ln_NndnhHo1Rec_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0058_CODE,
      @As_DescriptionError_TEXT    = @Ls_ErrordescNdnh_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';
       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM LoadFcr_CUR INTO @Ls_LoadFcrCur_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LoadFcr_CUR;

   DEALLOCATE LoadFcr_CUR;

   -- Check for SVES record              
   -- Load the FCR SVES Details into the temporary table LFSPR_Y1, 
   -- if the source is prisoner information  
   SET @Ls_Sql_TEXT = 'INSERT INTO LFSPR_Y1';   SET @Ln_SvesPrisnorRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_SvesPrisnorRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecSves_ID  
        AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyPrisoner_TEXT; 
     IF @Ln_SvesPrisnorRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFSPR_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFSPR_Y1
              (Rec_ID,
               StateTerritory_CODE,
               LocSourceResp_CODE,
               PrisonUsedMemberSsn_NUMB,
               FirstPr_NAME,
               MiddlePr_NAME,
               LastPr_NAME,
               SuffixPr_NAME,
               SexPr_CODE,
               BirthPr_DATE,
               FirstSubmitted_NAME,
               MiddleSubmitted_NAME,
               LastSubmitted_NAME,
               SubmittedMemberSsn_NUMB,
               SubmittedMemberMci_IDNO,
               UserField_NAME,
               LocClosed_INDC,
               CountyFips_CODE,
               TypeLocReq_CODE,
               MultiSsn_CODE,
               MultiSsn_NUMB,
               NumberPr_IDNO,
               ConfinedPr_DATE,
               ReleasePr_DATE,
               ReporterPr_NAME,
               ReportPr_DATE,
               TypeFacility_CODE,
               Facility_NAME,
               FacilityOld1_ADDR,
               FacilityOld2_ADDR,
               FacilityOld3_ADDR,
               FacilityOld4_ADDR,
               CityFacilityOld_ADDR,
               StFacilityOld_ADDR,
               ZipFacilityOld_ADDR,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrAcrub3_CODE,
               ContactFacility_NAME,
               PhoneFacility_NUMB,
               FaxFacility_NUMB,
               StateSort_CODE,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateTerritory_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 61, 3), @Lc_Space_TEXT))) AS LocSourceResp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 9), @Lc_Space_TEXT))) AS PrisonUsedMemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 73, 15), @Lc_Space_TEXT))) AS FirstPr_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 88, 15), @Lc_Space_TEXT))) AS MiddlePr_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 103, 20), @Lc_Space_TEXT))) AS LastPr_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 123, 4), @Lc_Space_TEXT))) AS SuffixPr_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 1), @Lc_Space_TEXT))) AS SexPr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 128, 8), @Lc_Space_TEXT))) AS BirthPr_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 274, 12), @Lc_Space_TEXT))) AS FirstSubmitted_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 286, 1), @Lc_Space_TEXT))) AS MiddleSubmitted_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 287, 19), @Lc_Space_TEXT))) AS LastSubmitted_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS SubmittedMemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS SubmittedMemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 338, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 353, 1), @Lc_Space_TEXT))) AS LocClosed_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 356, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 2), @Lc_Space_TEXT))) AS TypeLocReq_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 377, 1), @Lc_Space_TEXT))) AS MultiSsn_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 378, 9), @Lc_Space_TEXT))) AS MultiSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 10), @Lc_Space_TEXT))) AS NumberPr_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 397, 8), @Lc_Space_TEXT))) AS ConfinedPr_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 405, 8), @Lc_Space_TEXT))) AS ReleasePr_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 413, 60), @Lc_Space_TEXT))) AS ReporterPr_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 473, 8), @Lc_Space_TEXT))) AS ReportPr_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 481, 2), @Lc_Space_TEXT))) AS TypeFacility_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 483, 60), @Lc_Space_TEXT))) AS Facility_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 543, 40), @Lc_Space_TEXT))) AS FacilityOld1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 583, 40), @Lc_Space_TEXT))) AS FacilityOld2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 623, 40), @Lc_Space_TEXT))) AS FacilityOld3_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 663, 40), @Lc_Space_TEXT))) AS FacilityOld4_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 703, 19), @Lc_Space_TEXT))) AS CityFacilityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 722, 2), @Lc_Space_TEXT))) AS StFacilityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 724, 9), @Lc_Space_TEXT))) AS ZipFacilityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 733, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 735, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 737, 2), @Lc_Space_TEXT))) AS AddrAcrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 739, 35), @Lc_Space_TEXT))) AS ContactFacility_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 774, 10), @Lc_Space_TEXT))) AS PhoneFacility_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 784, 10), @Lc_Space_TEXT))) AS FaxFacility_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS StateSort_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 10), @Lc_Space_TEXT))) AS Zip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecSves_ID
          AND SUBSTRING (Record_TEXT, 61, 3) = @Lc_LocRespAgencyPrisoner_TEXT; 	    
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFSPR_Y1 ';
         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for SVES record              
   -- Load the FCR SVES Loading SVES Title II and Title XVI records into Temporary Table LFSDE_Y1, 
   -- if the locate source response codes 'E05','E06','E10'
   SET @Ls_Sql_TEXT = 'INSERT INTO LFSDE_Y1';   SET @Ln_SvesDetailsRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_SvesDetailsRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecSves_ID 
        AND SUBSTRING (Record_TEXT, 61, 3) IN ('E05', 'E06', 'E10'); 
     IF @Ln_SvesDetailsRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFSDE_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFSDE_Y1
              (Rec_ID,
               StateTerritory_CODE,
               LocSourceResp_CODE,
               Data1Sves_TEXT,
               Line1Old_ADDR,
               Line2Old_ADDR,
               Line3Old_ADDR,
               CityOld_ADDR,
               StateOld_ADDR,
               ZipOld_ADDR,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrScrub3_CODE,
               FirstSubmitted_NAME,
               MiddleSubmitted_NAME,
               LastSubmitted_NAME,
               BirthSubmitted_DATE,
               SubmittedMemberSsn_NUMB,
               SubmittedMemberMci_IDNO,
               CountyFips_CODE,
               MultiSsn_CODE,
               MultiSsn_NUMB,
               Data2Sves_TEXT,
               Data3Sves_TEXT,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateTerritory_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 61, 3), @Lc_Space_TEXT))) AS LocSourceResp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 55), @Lc_Space_TEXT))) AS Data1Sves_TEXT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 119, 40), @Lc_Space_TEXT))) AS Line1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 159, 40), @Lc_Space_TEXT))) AS Line2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 199, 40), @Lc_Space_TEXT))) AS Line3Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 239, 16), @Lc_Space_TEXT))) AS CityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 255, 2), @Lc_Space_TEXT))) AS StateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 257, 9), @Lc_Space_TEXT))) AS ZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 266, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 268, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 270, 2), @Lc_Space_TEXT))) AS AddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 274, 12), @Lc_Space_TEXT))) AS FirstSubmitted_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 286, 1), @Lc_Space_TEXT))) AS MiddleSubmitted_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 287, 19), @Lc_Space_TEXT))) AS LastSubmitted_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 306, 8), @Lc_Space_TEXT))) AS BirthSubmitted_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS SubmittedMemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS SubmittedMemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 356, 3), @Lc_Space_TEXT))) AS CountyFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 377, 1), @Lc_Space_TEXT))) AS MultiSsn_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 378, 9), @Lc_Space_TEXT))) AS MultiSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 189), @Lc_Space_TEXT))) AS Data2Sves_TEXT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 576, 16), @Lc_Space_TEXT))) AS Data3Sves_TEXT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 10), @Lc_Space_TEXT))) AS Zip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecSves_ID
          AND SUBSTRING (Record_TEXT, 61, 3) IN ('E05', 'E06', 'E10');  
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFSDE_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for DMDC record 
   -- Loading DMDC records into Temporary Table LFDMD_Y1 
   SET @Ls_Sql_TEXT = 'INSERT INTO LFDMD_Y1';   SET @Ln_DmdcRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_DmdcRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecDmdc_ID;

     --'FW' 
     IF @Ln_DmdcRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFDMD_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFDMD_Y1
              (Rec_ID,
               StateTransmitter_CODE,
               County_IDNO,
               Case_IDNO,
               Order_INDC,
               FirstCh_NAME,
               MiddledCh_NAME,
               LastCh_NAME,
               ChildSsn_NUMB,
               SsnVerifiedCh_INDC,
               ChildMCI_IDNO,
               DeathCh_INDC,
               MedCoverageCh_INDC,
               MedCoverageSponsorCh_INDC,
               BeginCoverageCh_DATE,
               EndCoverageCh_DATE,
               FirstNcp_NAME,
               MiddleNcp_NAME,
               LastNcp_NAME,
               NcpSsn_NUMB,
               SsnVerifiedNcp_INDC,
               NcpMci_IDNO,
               DeathNcp_INDC,
               MedCoverageNcp_INDC,
               FirstPf_NAME,
               MiddlePf_NAME,
               LastPf_NAME,
               PfSsn_NUMB,
               SsnVerifiedPf_INDC,
               PfMci_IDNO,
               DeathPf_INDC,
               MedCoveragePf_INDC,
               FirstCp_NAME,
               MiddleCp_NAME,
               LastCp_NAME,
               CpSsn_NUMB,
               SsnVerifiedCp_INDC,
               CpMci_IDNO,
               DeathCp_INDC,
               MedCoverageCp_INDC,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 2), @Lc_Space_TEXT))) AS StateTransmitter_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 21, 3), @Lc_Space_TEXT))) AS County_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 32, 15), @Lc_Space_TEXT))) AS Case_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 47, 1), @Lc_Space_TEXT))) AS Order_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 48, 16), @Lc_Space_TEXT))) AS FirstCh_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 16), @Lc_Space_TEXT))) AS MiddledCh_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 80, 30), @Lc_Space_TEXT))) AS LastCh_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 110, 9), @Lc_Space_TEXT))) AS ChildSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 119, 1), @Lc_Space_TEXT))) AS SsnVerifiedCh_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 120, 15), @Lc_Space_TEXT))) AS ChildMCI_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 135, 1), @Lc_Space_TEXT))) AS DeathCh_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 136, 1), @Lc_Space_TEXT))) AS MedCoverageCh_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 137, 1), @Lc_Space_TEXT))) AS MedCoverageSponsorCh_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 138, 8), @Lc_Space_TEXT))) AS BeginCoverageCh_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 146, 8), @Lc_Space_TEXT))) AS EndCoverageCh_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 179, 16), @Lc_Space_TEXT))) AS FirstNcp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 195, 16), @Lc_Space_TEXT))) AS MiddleNcp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 211, 30), @Lc_Space_TEXT))) AS LastNcp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 241, 9), @Lc_Space_TEXT))) AS NcpSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 250, 1), @Lc_Space_TEXT))) AS SsnVerifiedNcp_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 251, 15), @Lc_Space_TEXT))) AS NcpMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 266, 1), @Lc_Space_TEXT))) AS DeathNcp_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 267, 1), @Lc_Space_TEXT))) AS MedCoverageNcp_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 293, 16), @Lc_Space_TEXT))) AS FirstPf_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 309, 16), @Lc_Space_TEXT))) AS MiddlePf_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 325, 30), @Lc_Space_TEXT))) AS LastPf_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 355, 9), @Lc_Space_TEXT))) AS PfSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 1), @Lc_Space_TEXT))) AS SsnVerifiedPf_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 365, 15), @Lc_Space_TEXT))) AS PfMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 380, 1), @Lc_Space_TEXT))) AS DeathPf_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 381, 1), @Lc_Space_TEXT))) AS MedCoveragePf_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 407, 16), @Lc_Space_TEXT))) AS FirstCp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 423, 16), @Lc_Space_TEXT))) AS MiddleCp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 439, 30), @Lc_Space_TEXT))) AS LastCp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 469, 9), @Lc_Space_TEXT))) AS CpSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 478, 1), @Lc_Space_TEXT))) AS SsnVerifiedCp_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 479, 15), @Lc_Space_TEXT))) AS CpMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 494, 1), @Lc_Space_TEXT))) AS DeathCp_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 495, 1), @Lc_Space_TEXT))) AS MedCoverageCp_INDC,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecDmdc_ID;  
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFDMD_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for MSFIDM record 
   -- Loading MSFIDM records into Temporary Table LFMFD_Y1
   SET @Ls_Sql_TEXT = 'INSERT INTO LFMFD_Y1';   SET @Ln_MsfidmRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_MsfidmRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecMsFidm_ID; 
     IF @Ln_MsfidmRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFMFD_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFMFD_Y1
              (Rec_ID,
               Tin_NUMB,
               Match_DATE,
               Fi_NAME,
               StreetFiOld_ADDR,
               CityFiOld_ADDR,
               StateFiOld_ADDR,
               ZipFiOld_ADDR,
               ForeignCountryFi_CODE,
               ResponseFidm_DATE,
               LastNcp_NAME,
               MemberSsn_NUMB,
               AcctFi_NUMB,
               DescriptionAcctTitle_NUMB,
               AcctForeignCnty_CODE,
               NameAcct_NUMB,
               NameAcctOther_NUMB,
               --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – START -
               Line1NcpOld_ADDR,
               CityNcpOld_ADDR,
               StateNcpOld_ADDR,
               ZipNcpOld_ADDR,
               --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – END -
               AcctLocState_NUMB,
               AcctBal_AMNT,
               NameMatchFlag_CODE,
               TrustFund_CODE,
               Balance_CODE,
               BirthNcp_DATE,
               TypeAccount_CODE,
               Case_IDNO,
               Ncp_CODE,
               SsnPrimaryAcct_NUMB,
               SsnSecondAcct_NUMB,
               LastFederalOffset_NAME,
               FirstFederalOffset_NAME,
               LocalFederalOffset_CODE,
               AddrScrub1_CODE,
               AddrScrub2_CODE,
               AddrScrub3_CODE,
               AddrScrub1Ncp_CODE,
               AddrScrub2Ncp_CODE,
               AddrScrub3Ncp_CODE,
               StateFips_CODE,
               Normalization_CODE,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – START -
               AddressNormalizationNcp_CODE,
               Line1Ncp_ADDR,
               Line2Ncp_ADDR,
               CityNcp_ADDR,
               StateNcp_ADDR,
               ZipNcp_ADDR,
               --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – END -
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 9), @Lc_Space_TEXT))) AS Tin_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 12, 6), @Lc_Space_TEXT))) AS Match_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 18, 40), @Lc_Space_TEXT))) AS Fi_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 58, 40), @Lc_Space_TEXT))) AS StreetFiOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 98, 29), @Lc_Space_TEXT))) AS CityFiOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 2), @Lc_Space_TEXT))) AS StateFiOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 129, 9), @Lc_Space_TEXT))) AS ZipFiOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 138, 1), @Lc_Space_TEXT))) AS ForeignCountryFi_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 139, 8), @Lc_Space_TEXT))) AS ResponseFidm_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 147, 4), @Lc_Space_TEXT))) AS LastNcp_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 154, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 163, 20), @Lc_Space_TEXT))) AS AcctFi_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 183, 100), @Lc_Space_TEXT))) AS DescriptionAcctTitle_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 283, 1), @Lc_Space_TEXT))) AS AcctForeignCnty_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 284, 40), @Lc_Space_TEXT))) AS NameAcct_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 324, 40), @Lc_Space_TEXT))) AS NameAcctOther_NUMB,
              --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – START -
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 364, 40), @Lc_Space_TEXT))) AS Line1NcpOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 404, 29), @Lc_Space_TEXT))) AS CityNcpOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 433, 2), @Lc_Space_TEXT))) AS StateNcpOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 435, 9), @Lc_Space_TEXT))) AS ZipNcpOld_ADDR,
              --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – END -
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 444, 2), @Lc_Space_TEXT))) AS AcctLocState_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 449, 7), @Lc_Space_TEXT))) AS AcctBal_AMNT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 456, 1), @Lc_Space_TEXT))) AS NameMatchFlag_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 457, 1), @Lc_Space_TEXT))) AS TrustFund_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 458, 1), @Lc_Space_TEXT))) AS Balance_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 459, 8), @Lc_Space_TEXT))) AS BirthNcp_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 467, 2), @Lc_Space_TEXT))) AS TypeAccount_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 469, 15), @Lc_Space_TEXT))) AS Case_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 485, 1), @Lc_Space_TEXT))) AS Ncp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 486, 1), @Lc_Space_TEXT))) AS SsnPrimaryAcct_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 495, 9), @Lc_Space_TEXT))) AS SsnSecondAcct_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 504, 20), @Lc_Space_TEXT))) AS LastFederalOffset_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 524, 15), @Lc_Space_TEXT))) AS FirstFederalOffset_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 539, 3), @Lc_Space_TEXT))) AS LocalFederalOffset_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 542, 2), @Lc_Space_TEXT))) AS AddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 544, 2), @Lc_Space_TEXT))) AS AddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 546, 2), @Lc_Space_TEXT))) AS AddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 548, 2), @Lc_Space_TEXT))) AS AddrScrub1Ncp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 550, 2), @Lc_Space_TEXT))) AS AddrScrub2Ncp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 552, 2), @Lc_Space_TEXT))) AS AddrScrub3Ncp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS StateFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS Line1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS Line2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS City_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS State_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 10), @Lc_Space_TEXT))) AS Zip_ADDR,
              --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – START -
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1067, 1), @Lc_Space_TEXT))) AS AddressNormalizationNcp_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1068, 50), @Lc_Space_TEXT))) AS Line1Ncp_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1118, 50), @Lc_Space_TEXT))) AS Line2Ncp_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1168, 28), @Lc_Space_TEXT))) AS CityNcp_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1196, 2), @Lc_Space_TEXT))) AS StateNcp_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1198, 10), @Lc_Space_TEXT))) AS ZipNcp_ADDR,
              --13529 -  Update Member Address with FCR MSFIDM Account Holder Address – END -
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecMsFidm_ID; 
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
        
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFDMD_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for National change of address record  
   -- Loading National change of address records into the  Temporary Table LFNCA_Y1    
   SET @Ls_Sql_TEXT = 'INSERT INTO LFNCA_Y1';   SET @Ln_NcoaRec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_NcoaRec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNcoa_ID; 
     IF @Ln_NcoaRec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFNCA_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFNCA_Y1
              (Rec_ID,
               Ncoa_CODE,
               StateFips_CODE,
               First_NAME,
               Middle_NAME,
               Last_NAME,
               SubLine1_ADDR,
               SubLine2_ADDR,
               SubCity_ADDR,
               SubState_ADDR,
               SubZip_ADDR,
               MemberSsn_NUMB,
               MemberMci_IDNO,
               UserField_NAME,
               NcoaResponse_CODE,
               ReturnLine1_ADDR,
               ReturnLine2_ADDR,
               ReturnLine3_ADDR,
               ReturnCity_ADDR,
               ReturnState_ADDR,
               ReturnZip_ADDR,
               ReturnDeliveryPoint_CODE,
               ReturnCheck_CODE,
               ReturnRoute_CODE,
               ReturnLineTravel_CODE,
               ReturnSort_CODE,
               NewReturnNcoa_CODE,
               AddressChangeEffYearMonth_NUMB,
               MoveType_CODE,
               LocAddConvSys_CODE,
               ComMailRecvAgen_INDC,
               CoaLine1Old_ADDR,
               CoaLine2Old_ADDR,
               CoaLine3Old_ADDR,
               CoaCityOld_ADDR,
               CoaStateOld_ADDR,
               CoaZipOld_ADDR,
               CoaDelPoint_CODE,
               CoaCheck_CODE,
               CoaRoute_CODE,
               CoaLineTravel_CODE,
               CoaReturnSort_CODE,
               CoaRetSt_CODE,
               CoaNormalization_CODE,
               CoaLine1_ADDR,
               CoaLine2_ADDR,
               CoaCity_ADDR,
               CoaState_ADDR,
               CoaZip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 1), @Lc_Space_TEXT))) AS Ncoa_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 2), @Lc_Space_TEXT))) AS StateFips_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 65, 16), @Lc_Space_TEXT))) AS First_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 81, 16), @Lc_Space_TEXT))) AS Middle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 97, 30), @Lc_Space_TEXT))) AS Last_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 161, 40), @Lc_Space_TEXT))) AS SubLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 201, 40), @Lc_Space_TEXT))) AS SubLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 241, 20), @Lc_Space_TEXT))) AS SubCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 261, 2), @Lc_Space_TEXT))) AS SubState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 263, 9), @Lc_Space_TEXT))) AS SubZip_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 323, 15), @Lc_Space_TEXT))) AS MemberMci_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 338, 15), @Lc_Space_TEXT))) AS UserField_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 375, 2), @Lc_Space_TEXT))) AS NcoaResponse_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 387, 50), @Lc_Space_TEXT))) AS ReturnLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 437, 50), @Lc_Space_TEXT))) AS ReturnLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 487, 50), @Lc_Space_TEXT))) AS ReturnLine3_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 537, 30), @Lc_Space_TEXT))) AS ReturnCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 567, 2), @Lc_Space_TEXT))) AS ReturnState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 569, 9), @Lc_Space_TEXT))) AS ReturnZip_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 578, 2), @Lc_Space_TEXT))) AS ReturnDeliveryPoint_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 580, 1), @Lc_Space_TEXT))) AS ReturnCheck_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 581, 4), @Lc_Space_TEXT))) AS ReturnRoute_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 585, 4), @Lc_Space_TEXT))) AS ReturnLineTravel_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 589, 1), @Lc_Space_TEXT))) AS ReturnSort_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 612, 2), @Lc_Space_TEXT))) AS NewReturnNcoa_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 614, 6), @Lc_Space_TEXT))) AS AddressChangeEffYearMonth_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 620, 1), @Lc_Space_TEXT))) AS MoveType_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 621, 1), @Lc_Space_TEXT))) AS LocAddConvSys_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 622, 1), @Lc_Space_TEXT))) AS ComMailRecvAgen_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 623, 50), @Lc_Space_TEXT))) AS CoaLine1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 673, 50), @Lc_Space_TEXT))) AS CoaLine2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 723, 50), @Lc_Space_TEXT))) AS CoaLine3Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 773, 30), @Lc_Space_TEXT))) AS CoaCityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 803, 2), @Lc_Space_TEXT))) AS CoaStateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 805, 9), @Lc_Space_TEXT))) AS CoaZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 814, 2), @Lc_Space_TEXT))) AS CoaDelPoint_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 816, 1), @Lc_Space_TEXT))) AS CoaCheck_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 817, 4), @Lc_Space_TEXT))) AS CoaRoute_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 821, 4), @Lc_Space_TEXT))) AS CoaLineTravel_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 825, 1), @Lc_Space_TEXT))) AS CoaReturnSort_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS CoaRetSt_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS CoaNormalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS CoaLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS CoaLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS CoaCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS CoaState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 10), @Lc_Space_TEXT))) AS CoaZip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecNcoa_ID; 
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFNCA_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for Insurance match  part1 record 
   -- Loading Insurance match records part 1 details into the  Temporary Table LFIMD_Y1
   SET @Ls_Sql_TEXT = 'INSERT INTO LFIMD_Y1';   SET @Ln_ImPart1Rec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_ImPart1Rec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecInsMatch_ID 
        AND SUBSTRING(Record_TEXT, 23, 1) = '1';

     IF @Ln_ImPart1Rec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFIMD_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFIMD_Y1
              (Rec_ID,
               InsMatchObligorSsn_NUMB,
               RecordCreation_DATE,
               RecordSequence_NUMB,
               SubRecord_NUMB,
               Case_IDNO,
               ObligorFirst_NAME,
               ObligorLast_NAME,
               MemberSsn_NUMB,
               Tin_IDNO,
               Processed_DATE,
               ClaimUpdate_CODE,
               Insurer_NAME,
               InsContactFirst_NAME,
               InsContactLast_NAME,
               InsPhone_NUMB,
               InsPhoneExt_NUMB,
               InsFax_NUMB,
               InsEmail_ADDR,
               InsLine1Old_ADDR,
               InsLine2Old_ADDR,
               InsCityOld_ADDR,
               InsStateOld_ADDR,
               InsZipOld_ADDR,
               InsForeignAddr_CODE,
               ForeignCountry_NAME,
               InsAddrScrub1_CODE,
               InsAddrScrub2_CODE,
               InsAddrScrub3_CODE,
               InsClaim_NUMB,
               ClaimType_CODE,
               ClaimState_CODE,
               ClaimLoss_DATE,
               ClaimBeneficiary_INDC,
               ClaimReport_DATE,
               ClaimStatus_CODE,
               ClaimFreq_CODE,
               ObligorMatch_CODE,
               SsnVerification_CODE,
               ClaimantFirst_NAME,
               ClaimantMiddle_NAME,
               ClaimantLast_NAME,
               MemberItin_IDNO,
               ClaimantBirth_DATE,
               ClaimantMemberSex_CODE,
               ClaimantHomePhone_NUMB,
               ClaimantWorkPhone_NUMB,
               ClaimantWorkPhoneExt_NUMB,
               ClaimantCellPhone_NUMB,
               DriverLicense_NUMB,
               LicenseState_CODE,
               Occupation_TEXT,
               ProfLicense_NUMB,
               ClaimantLine1Old_ADDR,
               ClaimantOldLine2Old_ADDR,
               ClaimantOldCityOld_ADDR,
               ClaimantOldStateOld_ADDR,
               ClaimantOldZipOld_ADDR,
               ClaimantForeignAddr_CODE,
               ClaimantCountry_ADDR,
               ClaimantAddrScrub1_CODE,
               ClaimantAddrScrub2_CODE,
               ClaimantAddrScrub3_CODE,
               SortState_CODE,
               Normalization_CODE,
               ClaimantLine1_ADDR,
               ClaimantLine2_ADDR,
               ClaimantCity_ADDR,
               ClaimantState_ADDR,
               ClaimantZip_ADDR,
               InsuranceNormalization_CODE,
               InsLine1_ADDR,
               InsLine2_ADDR,
               InsCity_ADDR,
               InsState_ADDR,
               InsZip_ADDR,
               FileLoad_DATE,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 9), @Lc_Space_TEXT))) AS InsMatchObligorSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 12, 8), @Lc_Space_TEXT))) AS RecordCreation_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 3), @Lc_Space_TEXT))) AS RecordSequence_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 23, 1), @Lc_Space_TEXT))) AS SubRecord_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 44, 15), @Lc_Space_TEXT))) AS Case_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 59, 15), @Lc_Space_TEXT))) AS ObligorFirst_NAME, 
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 74, 20), @Lc_Space_TEXT))) AS ObligorLast_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 94, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 103, 9), @Lc_Space_TEXT))) AS Tin_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 112, 8), @Lc_Space_TEXT))) AS Processed_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 120, 1), @Lc_Space_TEXT))) AS ClaimUpdate_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 121, 45), @Lc_Space_TEXT))) AS Insurer_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 166, 20), @Lc_Space_TEXT))) AS InsContactFirst_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 186, 30), @Lc_Space_TEXT))) AS InsContactLast_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 216, 10), @Lc_Space_TEXT))) AS InsPhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 226, 6), @Lc_Space_TEXT))) AS InsPhoneExt_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 232, 10), @Lc_Space_TEXT))) AS InsFax_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 242, 40), @Lc_Space_TEXT))) AS InsEmail_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 282, 40), @Lc_Space_TEXT))) AS InsLine1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 322, 40), @Lc_Space_TEXT))) AS InsLine2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 362, 30), @Lc_Space_TEXT))) AS InsCityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 392, 2), @Lc_Space_TEXT))) AS InsStateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 394, 15), @Lc_Space_TEXT))) AS InsZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 409, 1), @Lc_Space_TEXT))) AS InsForeignAddr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 410, 25), @Lc_Space_TEXT))) AS ForeignCountry_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 435, 2), @Lc_Space_TEXT))) AS InsAddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 437, 2), @Lc_Space_TEXT))) AS InsAddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 439, 2), @Lc_Space_TEXT))) AS InsAddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 441, 30), @Lc_Space_TEXT))) AS InsClaim_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 471, 2), @Lc_Space_TEXT))) AS ClaimType_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 473, 2), @Lc_Space_TEXT))) AS ClaimState_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 475, 8), @Lc_Space_TEXT))) AS ClaimLoss_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 483, 1), @Lc_Space_TEXT))) AS ClaimBeneficiary_INDC,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 484, 8), @Lc_Space_TEXT))) AS ClaimReport_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 492, 1), @Lc_Space_TEXT))) AS ClaimStatus_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 493, 1), @Lc_Space_TEXT))) AS ClaimFreq_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 494, 1), @Lc_Space_TEXT))) AS ObligorMatch_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 496, 1), @Lc_Space_TEXT))) AS SsnVerification_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 506, 20), @Lc_Space_TEXT))) AS ClaimantFirst_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 526, 16), @Lc_Space_TEXT))) AS ClaimantMiddle_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 542, 30), @Lc_Space_TEXT))) AS ClaimantLast_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 572, 9), @Lc_Space_TEXT))) AS MemberItin_IDNO,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 581, 8), @Lc_Space_TEXT))) AS ClaimantBirth_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 589, 1), @Lc_Space_TEXT))) AS ClaimantMemberSex_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 590, 10), @Lc_Space_TEXT))) AS ClaimantHomePhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 600, 10), @Lc_Space_TEXT))) AS ClaimantWorkPhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 610, 6), @Lc_Space_TEXT))) AS ClaimantWorkPhoneExt_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 616, 10), @Lc_Space_TEXT))) AS ClaimantCellPhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 626, 20), @Lc_Space_TEXT))) AS DriverLicense_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 646, 2), @Lc_Space_TEXT))) AS LicenseState_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 648, 40), @Lc_Space_TEXT))) AS Occupation_TEXT,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 688, 15), @Lc_Space_TEXT))) AS ProfLicense_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 703, 40), @Lc_Space_TEXT))) AS ClaimantLine1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 743, 40), @Lc_Space_TEXT))) AS ClaimantOldLine2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 783, 30), @Lc_Space_TEXT))) AS ClaimantOldCityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 813, 2), @Lc_Space_TEXT))) AS ClaimantOldStateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 815, 15), @Lc_Space_TEXT))) AS ClaimantOldZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 830, 1), @Lc_Space_TEXT))) AS ClaimantForeignAddr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 831, 25), @Lc_Space_TEXT))) AS ClaimantCountry_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 856, 2), @Lc_Space_TEXT))) AS ClaimantAddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 858, 2), @Lc_Space_TEXT))) AS ClaimantAddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 860, 2), @Lc_Space_TEXT))) AS ClaimantAddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS SortState_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS ClaimantLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS ClaimantLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS ClaimantCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS ClaimantState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 15), @Lc_Space_TEXT))) AS ClaimantZip_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1067, 1), @Lc_Space_TEXT))) AS InsuranceNormalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1068, 50), @Lc_Space_TEXT))) AS InsLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1118, 50), @Lc_Space_TEXT))) AS InsLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1168, 28), @Lc_Space_TEXT))) AS InsCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1196, 2), @Lc_Space_TEXT))) AS InsState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1198, 15), @Lc_Space_TEXT))) AS InsZip_ADDR,
              @Ld_Run_DATE AS FileLoad_DATE,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecInsMatch_ID 
          AND SUBSTRING(Record_TEXT, 23, 1) = '1';

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFIMD_Y1';
         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- Check for Insurance match  part2 record 
   -- Loading Insurance match records part 2 details into the  Temporary Table LFIMA_Y1    
   SET @Ls_Sql_TEXT = 'INSERT INTO LFIMA_Y1';   SET @Ln_ImPart2Rec_QNTY = 0;

   IF @Lc_WritetoReject_TEXT <> @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_ImPart2Rec_QNTY = COUNT(1)
       FROM #LoadFcrDetails_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecInsMatch_ID 
        AND SUBSTRING(Record_TEXT, 23, 1) = '2';

     IF @Ln_ImPart2Rec_QNTY <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERTING THE DATA INTO LFIMA_Y1 TABLE';       SET @Ls_Sqldata_TEXT = 'FileLoad_Date = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ValueN_CODE,'');

       INSERT LFIMA_Y1
              (Rec_ID,
               InsMatchObligorSsn_NUMB,
               RecordCreation_DATE,
               RecordSequence_NUMB,
               SubRecord_NUMB,
               AttorneyFirst_NAME,
               AttorneyLast_NAME,
               AttorneyPhone_NUMB,
               AttorneyPhoneExt_NUMB,
               AttorneyLine1Old_ADDR,
               AttorneyLine2Old_ADDR,
               AttorneyCityOld_ADDR,
               AttorneyStateOld_ADDR,
               AttorneyZipOld_ADDR,
               AttorneyForeignAddr_CODE,
               AttorneyCountry_ADDR,
               AttorneyAddrScrub1_CODE,
               AttorneyAddrScrub2_CODE,
               AttorneyAddrScrub3_CODE,
               TpaCompany_NAME,
               TpaContactFirst_NAME,
               TpaContactLast_NAME,
               TpaPhone_NUMB,
               TpaPhoneExt_NUMB,
               TpaLine1_ADDR,
               TpaLine2_ADDR,
               TpaCity_ADDR,
               TpaState_ADDR,
               TpaZip_ADDR,
               TpaForeignAddr_CODE,
               TpaCountry_NAME,
               TpaAddrScrub1_CODE,
               TpaAddrScrub2_CODE,
               TpaAddrScrub3_CODE,
               Employer_NAME,
               EmployerPhone_NUMB,
               EmployerPhoneExt_NUMB,
               EmployerLine1_ADDR,
               EmployerLine2_ADDR,
               EmployerCity_ADDR,
               EmployerState_ADDR,
               EmployerZip_ADDR,
               EmployerForeignAddr_CODE,
               EmployerCountry_NAME,
               EmployerAddrScrub1_CODE,
               EmployerAddrScrub2_CODE,
               EmployerAddrScrub3_CODE,
               SortState_CODE,
               Normalization_CODE,
               AttorneyLine1_ADDR,
               AttorneyLine2_ADDR,
               AttorneyCity_ADDR,
               AttorneyState_ADDR,
               AttorneyZip_ADDR,
               FileLoad_Date,
               Process_INDC)
       SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Space_TEXT))) AS Rec_ID,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 9), @Lc_Space_TEXT))) AS InsMatchObligorSsn_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 12, 8), @Lc_Space_TEXT))) AS RecordCreation_DATE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 3), @Lc_Space_TEXT))) AS RecordSequence_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 23, 1), @Lc_Space_TEXT))) AS SubRecord_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 44, 20), @Lc_Space_TEXT))) AS AttorneyFirst_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 30), @Lc_Space_TEXT))) AS AttorneyLast_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 94, 10), @Lc_Space_TEXT))) AS AttorneyPhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 104, 6), @Lc_Space_TEXT))) AS AttorneyPhoneExt_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 110, 40), @Lc_Space_TEXT))) AS AttorneyLine1Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 150, 40), @Lc_Space_TEXT))) AS AttorneyLine2Old_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 190, 30), @Lc_Space_TEXT))) AS AttorneyCityOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 220, 2), @Lc_Space_TEXT))) AS AttorneyStateOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 222, 15), @Lc_Space_TEXT))) AS AttorneyZipOld_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 237, 1), @Lc_Space_TEXT))) AS AttorneyForeignAddr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 238, 25), @Lc_Space_TEXT))) AS AttorneyCountry_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 263, 2), @Lc_Space_TEXT))) AS AttorneyAddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 265, 2), @Lc_Space_TEXT))) AS AttorneyAddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 267, 2), @Lc_Space_TEXT))) AS AttorneyAddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 269, 40), @Lc_Space_TEXT))) AS TpaCompany_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 309, 20), @Lc_Space_TEXT))) AS TpaContactFirst_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 329, 30), @Lc_Space_TEXT))) AS TpaContactLast_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 359, 10), @Lc_Space_TEXT))) AS TpaPhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 369, 6), @Lc_Space_TEXT))) AS TpaPhoneExt_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 375, 40), @Lc_Space_TEXT))) AS TpaLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 415, 40), @Lc_Space_TEXT))) AS TpaLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 455, 30), @Lc_Space_TEXT))) AS TpaCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 485, 2), @Lc_Space_TEXT))) AS TpaState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 487, 15), @Lc_Space_TEXT))) AS TpaZip_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 502, 1), @Lc_Space_TEXT))) AS TpaForeignAddr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 503, 25), @Lc_Space_TEXT))) AS TpaCountry_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 528, 2), @Lc_Space_TEXT))) AS TpaAddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 530, 2), @Lc_Space_TEXT))) AS TpaAddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 532, 2), @Lc_Space_TEXT))) AS TpaAddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 534, 40), @Lc_Space_TEXT))) AS Employer_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 574, 10), @Lc_Space_TEXT))) AS EmployerPhone_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 584, 6), @Lc_Space_TEXT))) AS EmployerPhoneExt_NUMB,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 590, 40), @Lc_Space_TEXT))) AS EmployerLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 630, 40), @Lc_Space_TEXT))) AS EmployerLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 670, 30), @Lc_Space_TEXT))) AS EmployerCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 700, 2), @Lc_Space_TEXT))) AS EmployerState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 702, 15), @Lc_Space_TEXT))) AS EmployerZip_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 717, 1), @Lc_Space_TEXT))) AS EmployerForeignAddr_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 718, 25), @Lc_Space_TEXT))) AS EmployerCountry_NAME,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 743, 2), @Lc_Space_TEXT))) AS EmployerAddrScrub1_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 745, 2), @Lc_Space_TEXT))) AS EmployerAddrScrub2_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 747, 2), @Lc_Space_TEXT))) AS EmployerAddrScrub3_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 919, 2), @Lc_Space_TEXT))) AS SortState_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 921, 1), @Lc_Space_TEXT))) AS Normalization_CODE,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 50), @Lc_Space_TEXT))) AS AttorneyLine1_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 972, 50), @Lc_Space_TEXT))) AS AttorneyLine2_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1022, 28), @Lc_Space_TEXT))) AS AttorneyCity_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1050, 2), @Lc_Space_TEXT))) AS AttorneyState_ADDR,
              (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1052, 15), @Lc_Space_TEXT))) AS AttorneyZip_ADDR,
              @Ld_Run_DATE AS FileLoad_Date,
              @Lc_ValueN_CODE AS Process_INDC
         FROM #LoadFcrDetails_P1 a 
        WHERE SUBSTRING (Record_TEXT, 1, 2) = @Lc_RecInsMatch_ID 
          AND SUBSTRING(Record_TEXT, 23, 1) = '2';

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INSERT INTO LFIMA_Y1 ';

         RAISERROR(50001,16,1);
        END
       ELSE
        BEGIN
         SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
        END
      END
    END

   -- If the input record is not identified, write exception into the BATE_Y1 table
   
   DECLARE LoadFcrUk_CUR INSENSITIVE CURSOR FOR
    SELECT Record_TEXT
      FROM #LoadFcrDetails_P1 a
     WHERE ((SUBSTRING(Record_TEXT, 1, 2)  NOT IN ('FB', 'FE', 'FL', 'FX',
												'FD', 'FS', 'FT', 'FK',
												'FF', 'FN', 'FW', 'MC',
												'NC', 'IM'))
			 OR
			 (SUBSTRING(Record_TEXT, 1, 2) = 'FK' 
			 AND SUBSTRING(Record_TEXT, 61, 3) NOT IN ('E05', 'E06', 'E07', 'E10')));

   OPEN LoadFcrUk_CUR;

   SET @Ln_FcrUnidentifiedRec_QNTY = 0;

   FETCH NEXT FROM LoadFcrUk_CUR INTO @Ls_LoadFcrUkCur_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Process unknown record types
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     --Write to BATE_Y1
     SET @Ln_FcrUnidentifiedRec_QNTY = @Ln_FcrUnidentifiedRec_QNTY + 1;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG ';    
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_FcrUnidentifiedRec_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorTe001_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrordescRec_IDNO,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Ln_FcrUnidentifiedRec_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorTe001_CODE,
      @As_DescriptionError_TEXT    = @Ls_ErrordescRec_IDNO,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM LoadFcrUk_CUR INTO @Ls_LoadFcrUkCur_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE LoadFcrUk_CUR;

   DEALLOCATE LoadFcrUk_CUR;

   IF @Ln_Rec_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_Rec_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Rec_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';

       RAISERROR(50001,16,1);
      END
    END

   LOAD_ERROR_FILE:;

   IF @Lc_WritetoReject_TEXT = @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO LFREJ_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT INTO LFREJ_Y1
                 (Rec_ID,
                  DescriptionDetail_TEXT,
                  FileLoad_DATE,
                  Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 2), @Lc_Empty_CODE))) AS Rec_ID, 
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 3, 918), @Lc_Empty_CODE))) AS DescriptionDetail_TEXT,
            @Ld_Run_DATE  AS FileLoad_DATE,
            @Lc_Yes_INDC AS Process_INDC
       FROM #LoadFcrDetails_P1 a;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LFREJ_Y1 ';

       RAISERROR(50001,16,1);
      END
     SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG -TRANSMISSION ERRORS RECEIVED FCR FILE';     
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_Rec_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE1172_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = @Ln_Rec_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE1172_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Ln_FcrUnidentifiedRec_QNTY;
   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR(50001,16,1);
    END

   -- --Update the Log in BSTL_Y1 as the Job is suceeded
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_Rec_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @LC_Successful_TEXT,
    @As_ListKey_TEXT          = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Rec_QNTY;

   -- Transaction ends 
   
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   COMMIT TRANSACTION FCR_BATCH_LOAD;

   --Drop Temperory Table
   DROP TABLE #LoadFcrDetails_P1;
  END TRY

  BEGIN CATCH
   --If Trasaction is not committed, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCR_BATCH_LOAD;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadFcrDetails_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadFcrDetails_P1;
    END
   -- Check the cursor is open, then close and deallocate the cursor 	
   IF CURSOR_STATUS ('VARIABLE', 'LoadFcr_CUR') IN (0, 1)
    BEGIN
     CLOSE LoadFcr_Cur;

     DEALLOCATE LoadFcr_Cur;
    END
    
   -- Check the cursor is open, then close and deallocate the cursor 	
   IF CURSOR_STATUS ('VARIABLE', 'LoadFcrUk_CUR') IN (0, 1)
    BEGIN
     CLOSE LoadFcrUk_CUR;

     DEALLOCATE LoadFcrUk_CUR;
    END 
   
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
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
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
