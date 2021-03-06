/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_LOAD_IVE_REFERRAL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_LOAD_IVE_REFERRAL
Programmer Name		 : Imp Team
Description			 : The procedure BATCH_FIN_IVE_REFERRAL$SP_LOAD_IVE_REFERRAL reads the data file received from the  IV-E for all new referrals 
					   and loads the data into the temporary table (LIREF_Y1) for futher processing.
Frequency			 : Daily
Developed On		 : 06/08/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
-----------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_LOAD_IVE_REFERRAL]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
  DECLARE  @Lc_ValueNo_INDC					CHAR(1) = 'N',
           @Lc_StatusFailed_CODE			CHAR(1) = 'F',
           @Lc_Yes_INDC						CHAR(1) = 'Y',
           @Lc_ErrorTypeError_CODE			CHAR(1) = 'E',
           @Lc_ErrorTypeWarning_CODE		CHAR(1) = 'W',
           @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE		CHAR(1) = 'A',
           @Lc_IveDetailedRec_CODE			CHAR(1) = 'D',
           @Lc_IveHeaderRec_CODE			CHAR(1) = 'H',
           @Lc_IveTrailerRec_CODE			CHAR(1) = 'T',
           @Lc_JobLoadIveReferral_ID		CHAR(7) = 'DEB1330',
           @Lc_Job_ID						CHAR(7) = 'DEB8065',
           @Lc_ErrorTe001_CODE				CHAR(18) = 'TE001',
           @Lc_ErrorE0944_CODE				CHAR(18) = 'E0944',
           @Lc_Successful_TEXT				CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT			CHAR(30) = 'BATCH',
           @Lc_Parmdateproblem_TEXT			CHAR(30) = 'PARM DATE PROBLEM',
           @Ls_ErrordescRec_TEXT			VARCHAR(100) = 'UNKNOWN RECORD TYPE FROM IVE FOR REFERRAL',
           @Ls_Process_NAME					VARCHAR(100) = 'BATCH_FIN_IVE_REFERRAL',
           @Ls_Procedure_NAME				VARCHAR(100) = 'SP_LOAD_IVE_REFERRAL',
           @Ls_NoRecordsInFile_TEXT			VARCHAR(100) = 'NO RECORDS IN THE FILE ',
           @Ls_CursorLoc_TEXT				VARCHAR(200) = ' ',
           @Ls_IveReferalCur_Record_TEXT	VARCHAR(1500) = ' '; 
  DECLARE  @Ln_CommitFreqParm_QNTY			NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY	NUMERIC(5),
           @Ln_ProcessedRecordCount_QNTY	NUMERIC(6) = 0,
           @Ln_UnknownRec_QNTY				NUMERIC(8) = 0,
           @Ln_FcUnidentifiedRec_QNTY		NUMERIC(8) = 0,
           @Ln_IveReferralRec_QNTY			NUMERIC(8) = 0,
           @Ln_Rec_QNTY						NUMERIC(10) = 0,
           @Ln_Error_NUMB					NUMERIC(11) = 0,
           @Ln_ErrorLine_NUMB				NUMERIC(11) = 0,
           @Li_FetchStatus_QNTY				SMALLINT,
           @Li_RowCount_QNTY				SMALLINT,
           @Lc_Space_TEXT					CHAR(1) = '',
           @Lc_Msg_CODE						CHAR(1) = '',
           @Ls_FileName_TEXT				VARCHAR(50) = '',
           @Ls_FileLocation_TEXT			VARCHAR(80) = '',
           @Ls_Sql_TEXT						VARCHAR(100) = '',
           @Ls_FileSource_TEXT				VARCHAR(130) = '',
           @Ls_SqlStmnt_TEXT				VARCHAR(200) = '',
           @Ls_Sqldata_TEXT					VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT		VARCHAR(4000) = '',
           @Ls_ErrorDescription_TEXT		VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			VARCHAR(4000) = '',
           @Ld_Run_DATE						DATE,
           @Ld_Start_DATE					DATETIME2,
           @Ld_LastRun_DATE					DATETIME2;
  
  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE FROM COMMON PROCEDURE ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
   
   --Creating Temperory Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE #LoadIvereferral_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE #LoadIvereferral_P1
    (
      Record_TEXT VARCHAR (2417)
    );

   SET @Lc_Job_ID = @Lc_JobLoadIveReferral_ID; 
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   -- Selecting date run, date last run, commit freq, exception threshold details --
  
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
     RAISERROR(50001,16,1);
    END

   -- Validation 1:Check Whether the Job ran already on same day   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_Parmdateproblem_TEXT;

     RAISERROR(50001,16,1);
    END

   --Assign the Source File Location
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ls_FileSource_TEXT = '' + LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
    
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;
   
   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadIvereferral_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);
  
   -- Transaction begins 
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   BEGIN TRANSACTION IVEREFERRAL_BATCH_LOAD;

   -- Delete all the processed records
   
   SET @Ls_Sql_TEXT = 'DELETE FROM LIREF_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   DELETE LIREF_Y1
    WHERE LIREF_Y1.Process_INDC = @Lc_Yes_INDC;
  
   SET @Ln_IveReferralRec_QNTY = 0;
   SET @Ln_ProcessedRecordCount_QNTY = 0;
   SET @Ln_Rec_QNTY = 0;
   SET @Ln_UnknownRec_QNTY = 0;

   -- Check the record count for IVE referral records in the file 
   SET @Ls_Sql_TEXT = 'CHECK DETAILED RECORD COUNT FROM THE LOAD TABLE ';
   SET @Ls_Sqldata_TEXT = 'DetailedRecord_TYPE = ' + @Lc_IveDetailedRec_CODE;
   SELECT @Ln_IveReferralRec_QNTY = COUNT(1)
     FROM #LoadIvereferral_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 1) IN (@Lc_IveDetailedRec_CODE);

   --Check the record count for any unknown records in the file 
   SET @Ls_Sql_TEXT = 'CHECK UNKNOWN RECORD COUNT FROM THE LOAD TABLE ';
   SET @Ls_Sqldata_TEXT = 'DetailedRecord_TYPE = UNKNOWN' ;
   SELECT @Ln_UnknownRec_QNTY = COUNT(1)
     FROM #LoadIvereferral_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 1) NOT IN (@Lc_IveDetailedRec_CODE, @Lc_IveHeaderRec_CODE, @Lc_IveTrailerRec_CODE);
   
   -- If any detailed records exists in the file insert them into the table LIREF_Y1 
   SET @Ls_Sql_TEXT = 'INSERT THE DATA INOT LIREF_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   IF @Ln_IveReferralRec_QNTY <> 0
    BEGIN
     INSERT LIREF_Y1
            (Rec_ID,
             Application_DATE,
             APPROVED_DATE,
             IveCaseStatus_CODE,
             ApplicationCounty_IDNO,
             CourtOrder_INDC,
             File_ID,
             CourtOrder_DATE,
             CourtOrderCity_NAME,
             CourtOrderState_CODE,
             CourtOrder_AMNT,
             CourtOrderFrequency_CODE,
             CourtOrderEffective_INDC,
             CourtPaymentType_CODE,
             MotherInformation_INDC,
             Mother_NAME,
             MotherMCI_IDNO,
             MotherPid_IDNO,
             MotherPrimarySsn_NUMB,
             MotherOtherSsn_NUMB,
             MotherAlias_NAME,
             MotherIveCase_IDNO,
             MotherDeath_DATE,
             MotherHealthIns_INDC,
             MotherIns_NAME,
             MotherInsPolicy_ID,
             MotherAddress_CODE,
             MotherLine1Old_ADDR,
             MotherLine2Old_ADDR,
             MotherApno_ADDR,
             MotherCityOld_ADDR,
             MotherStateOld_ADDR,
             MotherZipOld_ADDR,
             MotherBirth_DATE,
             MotherRace_CODE,
             MotherSex_CODE,
             MotherEmpl_CODE,
             MotherEmpl_NAME,
             MotherEmplLine1Old_ADDR,
             MotherEmplLine2Old_ADDR,
             MotherEmplCityOld_ADDR,
             MotherEmplStateOld_ADDR,
             MotherEmplZipOld_ADDR,
             MotherLastPayment_DATE,
             MotherLastPayment_AMNT,
             MotherArrearage_AMNT,
             MotherPaymentDue_DATE,
             FatherInformation_INDC,
             Father_NAME,
             FatherMCI_IDNO,
             FatherPid_IDNO,
             FatherPrimarySsn_NUMB,
             FatherOtherSsn_NUMB,
             FatherAlias_NAME,
             FatherIveCase_IDNO, 
             FatherDeath_DATE, 
             FatherHealthIns_INDC, 
             FatherIns_NAME, 
             FatherInsPolicy_ID, 
             FatherAddress_CODE, 
             FatherLine1Old_ADDR, 
             FatherLine2Old_ADDR, 
             FatherApno_ADDR, 
             FatherCityOld_ADDR, 
             FatherStateOld_ADDR, 
             FatherZipOld_ADDR, 
             FatherBirth_DATE, 
             FatherRace_CODE, 
             FatherSex_CODE, 
             FatherEmpl_CODE, 
             FatherEmpl_NAME, 
             FatherEmplLine1Old_ADDR, 
             FatherEmplLine2Old_ADDR, 
             FatherEmplCityOld_ADDR, 
             FatherEmplStateOld_ADDR, 
             FatherEmplZipOld_ADDR, 
             FatherLastPayment_DATE, 
             FatherLastPayment_AMNT, 
             FatherArrearage_AMNT, 
             FatherPaymentDue_DATE, 
             Child1Mci_IDNO, 
             Child1Pid_IDNO, 
             Child1Ssn_NUMB, 
             Child1IveCase_IDNO, 
             Child1_NAME, 
             Child1Birth_DATE, 
             Child1FedFunded_INDC, 
             Child1PaternityEst_INDC, 
             Child1Father_NAME, 
             Child1FatherIveCase_IDNO, 
             Child1Mother_NAME, 
             Child1MotherIveCase_IDNO, 
             Child1MotherIns_INDC, 
             Child1FatherIns_INDC, 
             Child1FosterCareBegin_DATE, 
             Child1Monthly_AMNT, 
             Child2Mci_IDNO, 
             Child2Pid_IDNO, 
             Child2Ssn_NUMB, 
             Child2IveCase_IDNO, 
             Child2_NAME, 
             Child2Birth_DATE, 
             Child2FedFunded_INDC, 
             Child2PaternityEst_INDC, 
             Child2Father_NAME, 
             Child2FatherIveCase_IDNO, 
             Child2Mother_NAME, 
             Child2MotherIveCase_IDNO, 
             Child2MotherIns_INDC, 
             Child2FatherIns_INDC, 
             Child2FosterCareBegin_DATE, 
             Child2Monthly_AMNT, 
             Child3Mci_IDNO, 
             Child3Pid_IDNO, 
             Child3Ssn_NUMB, 
             Child3IveCase_IDNO, 
             Child3_NAME, 
             Child3Birth_DATE, 
             Child3FedFunded_INDC, 
             Child3PaternityEst_INDC, 
             Child3Father_NAME, 
             Child3FatherIveCase_IDNO, 
             Child3Mother_NAME, 
             Child3MotherIveCase_IDNO, 
             Child3MotherIns_INDC, 
             Child3FatherIns_INDC, 
             Child3FosterCareBegin_DATE, 
             Child3Monthly_AMNT, 
             Child4Mci_IDNO, 
             Child4Pid_IDNO, 
             Child4Ssn_NUMB, 
             Child4IveCase_IDNO, 
             Child4_NAME, 
             Child4Birth_DATE, 
             Child4FedFunded_INDC, 
             Child4PaternityEst_INDC, 
             Child4Father_NAME, 
             Child4FatherIveCase_IDNO, 
             Child4Mother_NAME, 
             Child4MotherIveCase_IDNO, 
             Child4MotherIns_INDC, 
             Child4FatherIns_INDC, 
             Child4FosterCareBegin_DATE, 
             Child4Monthly_AMNT, 
             Child5Mci_IDNO, 
             Child5Pid_IDNO, 
             Child5Ssn_NUMB, 
             Child5IveCase_IDNO, 
             Child5_NAME, 
             Child5Birth_DATE, 
             Child5FedFunded_INDC, 
             Child5PaternityEst_INDC, 
             Child5Father_NAME, 
             Child5FatherIveCase_IDNO, 
             Child5Mother_NAME, 
             Child5MotherIveCase_IDNO, 
             Child5MotherIns_INDC, 
             Child5FatherIns_INDC, 
             Child5FosterCareBegin_DATE, 
             Child5Monthly_AMNT, 
             Child6Mci_IDNO, 
             Child6Pid_IDNO, 
             Child6Ssn_NUMB, 
             Child6IveCase_IDNO, 
             Child6_NAME, 
             Child6Birth_DATE, 
             Child6FedFunded_INDC, 
             Child6PaternityEst_INDC, 
             Child6Father_NAME, 
             Child6FatherIveCase_IDNO, 
             Child6Mother_NAME, 
             Child6MotherIveCase_IDNO, 
             Child6MotherIns_INDC, 
             Child6FatherIns_INDC, 
             Child6FosterCareBegin_DATE, 
             Child6Monthly_AMNT, 
             WorkerLast_NAME, 
             MotherAddressNormalization_CODE, 
             MotherLine1_ADDR, 
             MotherLine2_ADDR, 
             MotherCity_ADDR, 
             MotherState_ADDR, 
             MotherZip_ADDR, 
             MotherEmplAddressNormalization_CODE, 
             MotherEmplLine1_ADDR, 
             MotherEmplLine2_ADDR, 
             MotherEmplCity_ADDR, 
             MotherEmplState_ADDR, 
             MotherEmplZip_ADDR, 
             FatherAddressNormalization_CODE, 
             FatherLine1_ADDR, 
             FatherLine2_ADDR, 
             FatherCity_ADDR, 
             FatherState_ADDR, 
             FatherZip_ADDR, 
             FatherEmplAddressNormalization_CODE, 
             FatherEmplLine1_ADDR, 
             FatherEmplLine2_ADDR, 
             FatherEmplCity_ADDR, 
             FatherEmplState_ADDR, 
             FatherEmplZip_ADDR, 
             FileLoad_DATE, 
             Process_INDC)  
     SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 1), @Lc_Space_TEXT))) AS Rec_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2, 8), @Lc_Space_TEXT))) AS Application_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 10, 8), @Lc_Space_TEXT))) AS APPROVED_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 18, 1), @Lc_Space_TEXT))) AS IveCaseStatus_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 19, 1), @Lc_Space_TEXT))) AS ApplicationCounty_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 1), @Lc_Space_TEXT))) AS CourtOrder_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 21, 10), @Lc_Space_TEXT))) AS File_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 31, 8), @Lc_Space_TEXT))) AS CourtOrder_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 39, 15), @Lc_Space_TEXT))) AS CourtOrderCity_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 54, 2), @Lc_Space_TEXT))) AS CourtOrderState_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 56, 10), @Lc_Space_TEXT))) AS CourtOrder_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 66, 5), @Lc_Space_TEXT))) AS CourtOrderFrequency_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 71, 1), @Lc_Space_TEXT))) AS CourtOrderEffective_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 72, 1), @Lc_Space_TEXT))) AS CourtPaymentType_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 73, 1), @Lc_Space_TEXT))) AS MotherInformation_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 74, 24), @Lc_Space_TEXT))) AS Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 98, 10), @Lc_Space_TEXT))) AS MotherMCI_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 108, 10), @Lc_Space_TEXT))) AS MotherPid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 118, 9), @Lc_Space_TEXT))) AS MotherPrimarySsn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 127, 9), @Lc_Space_TEXT))) AS MotherOtherSsn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 136, 24), @Lc_Space_TEXT))) AS MotherAlias_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 160, 10), @Lc_Space_TEXT))) AS MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 170, 8), @Lc_Space_TEXT))) AS MotherDeath_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 178, 1), @Lc_Space_TEXT))) AS MotherHealthIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 179, 15), @Lc_Space_TEXT))) AS MotherIns_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 194, 15), @Lc_Space_TEXT))) AS MotherInsPolicy_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 209, 1), @Lc_Space_TEXT))) AS MotherAddress_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 210, 31), @Lc_Space_TEXT))) AS MotherLine1Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 241, 31), @Lc_Space_TEXT))) AS MotherLine2Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 272, 5), @Lc_Space_TEXT))) AS MotherApno_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 277, 16), @Lc_Space_TEXT))) AS MotherCityOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 293, 2), @Lc_Space_TEXT))) AS MotherStateOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 295, 9), @Lc_Space_TEXT))) AS MotherZipOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 304, 8), @Lc_Space_TEXT))) AS MotherBirth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 312, 2), @Lc_Space_TEXT))) AS MotherRace_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 314, 1), @Lc_Space_TEXT))) AS MotherSex_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 315, 1), @Lc_Space_TEXT))) AS MotherEmpl_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 316, 35), @Lc_Space_TEXT)))AS MotherEmpl_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 351, 31), @Lc_Space_TEXT))) AS MotherEmplLine1Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 382, 31), @Lc_Space_TEXT))) AS MotherEmplLine2Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 413, 16), @Lc_Space_TEXT))) AS MotherEmplCityOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 429, 2), @Lc_Space_TEXT))) AS MotherEmplStateOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 431, 9), @Lc_Space_TEXT))) AS MotherEmplZipOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 440, 8), @Lc_Space_TEXT))) AS MotherLastPayment_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 448, 5), @Lc_Space_TEXT))) AS MotherLastPayment_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 453, 5), @Lc_Space_TEXT))) AS MotherArrearage_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 458, 8), @Lc_Space_TEXT))) AS MotherPaymentDue_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 466, 1), @Lc_Space_TEXT))) AS FatherInformation_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 467, 24), @Lc_Space_TEXT))) AS Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 491, 10), @Lc_Space_TEXT))) AS FatherMCI_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 501, 10), @Lc_Space_TEXT))) AS FatherPid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 511, 9), @Lc_Space_TEXT)))  AS FatherPrimarySsn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 520, 9), @Lc_Space_TEXT))) AS FatherOtherSsn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 529, 24), @Lc_Space_TEXT))) AS FatherAlias_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 553, 10), @Lc_Space_TEXT))) AS FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 563, 8), @Lc_Space_TEXT))) AS FatherDeath_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 571, 1), @Lc_Space_TEXT))) AS FatherHealthIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 572, 15), @Lc_Space_TEXT))) AS FatherIns_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 587, 15), @Lc_Space_TEXT))) AS FatherInsPolicy_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 602, 1), @Lc_Space_TEXT))) AS FatherAddress_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 603, 31), @Lc_Space_TEXT))) AS FatherLine1Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 634, 31), @Lc_Space_TEXT))) AS FatherLine2Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 665, 5), @Lc_Space_TEXT))) AS FatherApno_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 670, 16), @Lc_Space_TEXT))) AS FatherCityOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 686, 2), @Lc_Space_TEXT))) AS FatherStateOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 688, 9), @Lc_Space_TEXT))) AS FatherZipOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 697, 8), @Lc_Space_TEXT))) AS FatherBirth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 705, 2), @Lc_Space_TEXT))) AS FatherRace_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 707, 1), @Lc_Space_TEXT))) AS FatherSex_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 708, 1), @Lc_Space_TEXT))) AS FatherEmpl_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 709, 35), @Lc_Space_TEXT))) AS FatherEmpl_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 744, 31), @Lc_Space_TEXT))) AS FatherEmplLine1Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 775, 31), @Lc_Space_TEXT))) AS FatherEmplLine2Old_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 806, 16), @Lc_Space_TEXT))) AS FatherEmplCityOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 822, 2), @Lc_Space_TEXT)))  AS FatherEmplStateOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 824, 9), @Lc_Space_TEXT))) AS FatherEmplZipOld_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 833, 8), @Lc_Space_TEXT))) AS FatherLastPayment_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 841, 5), @Lc_Space_TEXT))) AS FatherLastPayment_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 846, 5), @Lc_Space_TEXT))) AS FatherArrearage_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 851, 8), @Lc_Space_TEXT))) AS FatherPaymentDue_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 859, 10), @Lc_Space_TEXT))) AS Child1Mci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 869, 10), @Lc_Space_TEXT))) AS Child1Pid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 879, 9), @Lc_Space_TEXT))) AS Child1Ssn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 888, 10), @Lc_Space_TEXT))) AS Child1IveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 898, 24), @Lc_Space_TEXT))) AS Child1_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 922, 8), @Lc_Space_TEXT))) AS Child1Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 930, 1), @Lc_Space_TEXT))) AS Child1FedFunded_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 931, 1), @Lc_Space_TEXT))) AS Child1PaternityEst_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 932, 24), @Lc_Space_TEXT))) AS Child1Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 956, 10), @Lc_Space_TEXT))) AS Child1FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 966, 24), @Lc_Space_TEXT))) AS Child1Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 990, 10), @Lc_Space_TEXT))) AS Child1MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1000, 1), @Lc_Space_TEXT))) AS Child1MotherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1001, 1), @Lc_Space_TEXT))) AS Child1FatherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1002, 8), @Lc_Space_TEXT))) AS Child1FosterCareBegin_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1010, 10), @Lc_Space_TEXT))) AS Child1Monthly_AMNT ,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1020, 10), @Lc_Space_TEXT))) AS Child2Mci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1030, 10), @Lc_Space_TEXT))) AS Child2Pid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1040, 9), @Lc_Space_TEXT))) AS Child2Ssn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1049, 10), @Lc_Space_TEXT))) AS Child2IveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1059, 24), @Lc_Space_TEXT))) AS Child2_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1083, 8), @Lc_Space_TEXT))) AS Child2Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1091, 1), @Lc_Space_TEXT))) AS Child2FedFunded_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1092, 1), @Lc_Space_TEXT))) AS Child2PaternityEst_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1093, 24), @Lc_Space_TEXT))) AS Child2Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1117, 10), @Lc_Space_TEXT))) AS Child2FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1127, 24), @Lc_Space_TEXT))) AS Child2Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1151, 10), @Lc_Space_TEXT))) AS Child2MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1161, 1), @Lc_Space_TEXT))) AS Child2MotherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1162, 1), @Lc_Space_TEXT))) AS Child2FatherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1163, 8), @Lc_Space_TEXT))) AS Child2FosterCareBegin_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1171, 10), @Lc_Space_TEXT))) AS Child2Monthly_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1181, 10), @Lc_Space_TEXT))) AS Child3Mci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1191, 10), @Lc_Space_TEXT))) AS Child3Pid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1201, 9), @Lc_Space_TEXT))) AS Child3Ssn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1210, 10), @Lc_Space_TEXT))) AS Child3IveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1220, 24), @Lc_Space_TEXT))) AS Child3_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1244, 8), @Lc_Space_TEXT))) AS Child3Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1252, 1), @Lc_Space_TEXT))) AS Child3FedFunded_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1253, 1), @Lc_Space_TEXT))) AS Child3PaternityEst_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1254, 24), @Lc_Space_TEXT))) AS Child3Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1278, 10), @Lc_Space_TEXT))) AS Child3FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1288, 24), @Lc_Space_TEXT))) AS Child3Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1312, 10), @Lc_Space_TEXT))) AS Child3MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1322, 1), @Lc_Space_TEXT))) AS Child3MotherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1323, 1), @Lc_Space_TEXT))) AS Child3FatherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1324, 8), @Lc_Space_TEXT))) AS Child3FosterCareBegin_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1332, 10), @Lc_Space_TEXT))) AS Child3Monthly_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1342, 10), @Lc_Space_TEXT))) AS Child4Mci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1352, 10), @Lc_Space_TEXT))) AS Child4Pid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1362, 9), @Lc_Space_TEXT))) AS Child4Ssn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1371, 10), @Lc_Space_TEXT))) AS Child4IveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1381, 24), @Lc_Space_TEXT))) AS Child4_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1405, 8), @Lc_Space_TEXT))) AS Child4Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1413, 1), @Lc_Space_TEXT))) AS Child4FedFunded_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1414, 1), @Lc_Space_TEXT))) AS Child4PaternityEst_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1415, 24), @Lc_Space_TEXT))) AS Child4Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1439, 10), @Lc_Space_TEXT))) AS Child4FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1449, 24), @Lc_Space_TEXT))) AS Child4Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1473, 10), @Lc_Space_TEXT))) AS Child4MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1483, 1), @Lc_Space_TEXT))) AS Child4MotherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1484, 1), @Lc_Space_TEXT))) AS Child4FatherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1485, 8), @Lc_Space_TEXT))) AS Child4FosterCareBegin_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1493, 10), @Lc_Space_TEXT))) AS Child4Monthly_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1503, 10), @Lc_Space_TEXT))) AS Child5Mci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1513, 10), @Lc_Space_TEXT))) AS Child5Pid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1523, 9), @Lc_Space_TEXT))) AS Child5Ssn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1532, 10), @Lc_Space_TEXT))) AS Child5IveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1542, 24), @Lc_Space_TEXT))) AS Child5_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1566, 8), @Lc_Space_TEXT))) AS Child5Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1574, 1), @Lc_Space_TEXT))) AS Child5FedFunded_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1575, 1), @Lc_Space_TEXT))) AS Child5PaternityEst_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1576, 24), @Lc_Space_TEXT))) AS Child5Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1600, 10), @Lc_Space_TEXT))) AS Child5FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1610, 24), @Lc_Space_TEXT))) AS Child5Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1634, 10), @Lc_Space_TEXT))) AS Child5MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1644, 1), @Lc_Space_TEXT))) AS Child5MotherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1645, 1), @Lc_Space_TEXT))) AS Child5FatherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1646, 8), @Lc_Space_TEXT))) AS Child5FosterCareBegin_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1654, 10), @Lc_Space_TEXT))) AS Child5Monthly_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1664, 10), @Lc_Space_TEXT))) AS Child6Mci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1674, 10), @Lc_Space_TEXT))) AS Child6Pid_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1684, 9), @Lc_Space_TEXT))) AS Child6Ssn_NUMB,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1693, 10), @Lc_Space_TEXT))) AS Child6IveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1703, 24), @Lc_Space_TEXT))) AS Child6_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1727, 8), @Lc_Space_TEXT))) AS Child6Birth_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1735, 1), @Lc_Space_TEXT))) AS Child6FedFunded_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1736, 1), @Lc_Space_TEXT))) AS Child6PaternityEst_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1737, 24), @Lc_Space_TEXT))) AS Child6Father_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1761, 10), @Lc_Space_TEXT))) AS Child6FatherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1771, 24), @Lc_Space_TEXT))) AS Child6Mother_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1795, 10), @Lc_Space_TEXT))) AS Child6MotherIveCase_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1805, 1), @Lc_Space_TEXT))) AS Child6MotherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1806, 1), @Lc_Space_TEXT))) AS Child6FatherIns_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1807, 8), @Lc_Space_TEXT))) AS Child6FosterCareBegin_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1815, 10), @Lc_Space_TEXT))) AS Child6Monthly_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1825, 9), @Lc_Space_TEXT))) AS WorkerLast_NAME,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1834, 1), @Lc_Space_TEXT))) AS MotherAddressNormalization_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1835, 50), @Lc_Space_TEXT))) AS MotherLine1_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1885, 50), @Lc_Space_TEXT))) AS MotherLine2_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1935, 28), @Lc_Space_TEXT))) AS MotherCity_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1963, 2), @Lc_Space_TEXT))) AS MotherState_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1965, 15), @Lc_Space_TEXT))) AS MotherZip_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1980, 1), @Lc_Space_TEXT))) AS MotherEmplAddressNormalization_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1981, 50), @Lc_Space_TEXT))) AS MotherEmplLine1_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2031, 50), @Lc_Space_TEXT))) AS MotherEmplLine2_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2081, 28), @Lc_Space_TEXT))) AS MotherEmplCity_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2109, 2), @Lc_Space_TEXT))) AS MotherEmplState_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2111, 15), @Lc_Space_TEXT))) AS MotherEmplZip_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2126, 1), @Lc_Space_TEXT))) AS FatherAddressNormalization_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2127, 50), @Lc_Space_TEXT))) AS FatherLine1_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2177, 50), @Lc_Space_TEXT))) AS FatherLine2_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2227, 28), @Lc_Space_TEXT))) AS FatherCity_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2255, 2), @Lc_Space_TEXT))) AS FatherState_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2257, 15), @Lc_Space_TEXT))) AS FatherZip_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2272, 1), @Lc_Space_TEXT))) AS FatherEmplAddressNormalization_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2273, 50), @Lc_Space_TEXT))) AS FatherEmplLine1_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2323, 50), @Lc_Space_TEXT))) AS FatherEmplLine2_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2373, 28), @Lc_Space_TEXT))) AS FatherEmplCity_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2401, 2), @Lc_Space_TEXT))) AS FatherEmplState_ADDR,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 2403, 15), @Lc_Space_TEXT))) AS FatherEmplZip_ADDR,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_ValueNo_INDC AS Process_INDC
       FROM #LoadIvereferral_P1 a 
      WHERE SUBSTRING (Record_TEXT, 1, 1) = @Lc_IveDetailedRec_CODE;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;
    
     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LIREF_Y1';

       RAISERROR(50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Li_RowCount_QNTY;
       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowCount_QNTY;
      END
    END

   -- Check for unknown interface type and write an entry into the BATE_Y1 table 
   IF @Ln_UnknownRec_QNTY <> 0
    BEGIN
     DECLARE IveReferal_CUR INSENSITIVE CURSOR FOR
      SELECT Record_TEXT
        FROM #LoadIvereferral_P1 a
       WHERE SUBSTRING (Record_TEXT, 1, 1) NOT IN (@Lc_IveDetailedRec_CODE, @Lc_IveHeaderRec_CODE, @Lc_IveTrailerRec_CODE);

     OPEN IveReferal_CUR;

     SET @Ln_FcUnidentifiedRec_QNTY = 0;

     FETCH NEXT FROM IveReferal_CUR INTO @Ls_IveReferalCur_Record_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     -- Process unknown interface record types
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_FcUnidentifiedRec_QNTY = @Ln_FcUnidentifiedRec_QNTY + 1;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG ';
       SET @Ls_Sqldata_TEXT = 'IVERECORD_TYPE = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1, 1) + ', IVEAPPLICATION_DATE = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 2, 8) + ', IVEAPPROVAL_DATE = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 10, 8) + ', IVECASESTATUS_CODE = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 18, 1) + ', IVEAPPLICATIONCOUNTY_CODE = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 19, 1) + ', IVEORDERDATA_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 20, 52) + ', IVEMOTHERINFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 73, 393) + ', FATHERINFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 466, 393) + ', CHILD1INFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 859, 161) + ', CHILD2INFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1020, 161) + ', CHILD3INFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1181, 161) + ', CHILD4INFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1342, 161) + ', CHILD5INFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1503, 161) + ', CHILD6INFO_TEXT = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1664, 161) + ', WORKERLAST_NAME = ' + SUBSTRING(@Ls_IveReferalCur_Record_TEXT, 1825, 9);
       
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME          = @Ls_Process_NAME,
        @As_Procedure_NAME        = @Ls_Procedure_NAME,
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_TypeError_CODE        = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB             = @Ln_FcUnidentifiedRec_QNTY,
        @Ac_Error_CODE            = @Lc_ErrorTe001_CODE,
        @As_DescriptionError_TEXT = @Ls_ErrordescRec_TEXT,
        @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_ErrorDescription_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
        
         RAISERROR(50001,16,1);
        END

       FETCH NEXT FROM IveReferal_CUR INTO @Ls_IveReferalCur_Record_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ln_Rec_QNTY = @Ln_Rec_QNTY + @Ln_FcUnidentifiedRec_QNTY;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_FcUnidentifiedRec_QNTY;

     CLOSE IveReferal_Cur;

     DEALLOCATE IveReferal_Cur;
    END
      
   -- Update the BATE_Y1 table, if there are no records in the input file 
   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME          = @Ls_Process_NAME,
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_TypeError_CODE        = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB             = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE            = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT = @Ls_NoRecordsInFile_TEXT,
      @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       RAISERROR(50001,16,1);
      END
    END

   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop Temperory Table
   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = '+ISNULL(@Lc_Job_ID, '');
   DROP TABLE #LoadIvereferral_P1; 
   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = '+ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION IVEREFERRAL_BATCH_LOAD;
   
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', 'IveReferal_CUR') IN (0, 1)
    BEGIN
     CLOSE IveReferal_CUR;

     DEALLOCATE IveReferal_CUR;
    END
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVEREFERRAL_BATCH_LOAD;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadIvereferral_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadIvereferral_P1;
    END

   --Set Error Description
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
