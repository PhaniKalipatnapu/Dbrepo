/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_ORDR$SP_LOAD_ORDER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_EST_INCOMING_FC_ORDR$SP_LOAD_ORDER
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_EST_INCOMING_FC_ORDR$SP_LOAD_ORDER reads the data file received from the  Family Court's 
					   System (FAMIS) and loads the data into the temporary tables for futher processing based on the record idenifier
					   values in the file. 
					   Record type ORDR - Order information records, data will be loaded into the tamporary table LFORD_Y1
					               EMPL - Member employer information records, data will be loaded into the temporary table 
					               LFEMP_Y1
Frequency			 : Daily
Developed On		 : 05/02/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_BATE_LOG,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE
---------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_ORDR$SP_LOAD_ORDER]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
    DECLARE  
           @Lc_Space_TEXT                   CHAR(1) = ' ',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_ProcessY_INDC                CHAR(1) = 'Y',
           @Lc_ErrorTypeError_CODE          CHAR(1) = 'E',
           @Lc_ErrorTypeWarning_CODE        CHAR(1) = 'W',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE       CHAR(1) = 'A',
           @Lc_OrderRec_ID                  CHAR(4) = 'ORDR',
           @Lc_EmployerRec_ID               CHAR(4) = 'EMPL',
           @Lc_Value_CODE                   CHAR(5) = 'N',
           @Lc_JobLoadFcOrdr_ID             CHAR(7) = 'DEB8060',
           @Lc_Job_ID                       CHAR(7) = 'DEB8060',
           @Lc_ErrorE1376_CODE              CHAR(18) = 'E1376',
           @Lc_ErrorE0944_CODE              CHAR(18) = 'E0944',
           @Lc_Successful_TEXT              CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT            CHAR(30) = 'BATCH',
           @Lc_Parmdateproblem_TEXT         CHAR(30) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME               VARCHAR(100) = 'SP_LOAD_ORDER',
           @Ls_ErrorDescriptionRecord_TEXT  VARCHAR(100) = 'UNKNOWN INTERFACE TYPE',
           @Ls_Process_NAME                 VARCHAR(100) = 'BATCH_EST_INCOMING_FC_ORDR',
           @Ls_NoRecordsInFile_TEXT         VARCHAR(100) = 'NO RECORDS IN THE FILE ',
           @Ls_CursorLocation_TEXT          VARCHAR(200) = ' ';
          
  DECLARE  @Ln_CommitFreqParm_QNTY			NUMERIC(5) = 0,
		   @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5) = 0,
		   @Ln_ProcessedRecordCount_QNTY    NUMERIC(6) = 0,
		   @Ln_UnknownRecord_QNTY			NUMERIC(8) = 0,
           @Ln_OrderRecord_QNTY				NUMERIC(8) = 0,
           @Ln_EmployerRecord_QNTY			NUMERIC(8) = 0,
           @Ln_FcUnidentifiedRecord_QNTY	NUMERIC(8) = 0,
           @Ln_Error_NUMB					NUMERIC(11),
           @Ln_ErrorLine_NUMB				NUMERIC(11),
           @Li_FetchStatus_QNTY				SMALLINT,
           @Li_RowCount_QNTY				SMALLINT,
           @Lc_TypeError_CODE				CHAR(1) = '',
           @Lc_Msg_CODE						CHAR(1),
           @Ls_File_NAME					VARCHAR(50) = '',
           @Ls_FileLocation_TEXT			VARCHAR(80),
           @Ls_Sql_TEXT						VARCHAR(100) = '',
           @Ls_FileSource_TEXT				VARCHAR(130) = '',
           @Ls_SqlStmnt_TEXT				VARCHAR(200) = '',
           @Ls_Sqldata_TEXT					VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT		VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			VARCHAR(4000),
           @Ld_Run_DATE						DATE,
           @Ld_Start_DATE					DATETIME2,
           @Ld_LastRun_DATE					DATETIME2;
  DECLARE @Ls_FcOrderCur_TEXT				VARCHAR(4447);
  
  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   --Creating Temperory Table
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = '';

   CREATE TABLE #LoadFcOrder_P1
    (
      Record_TEXT VARCHAR (4447)
    );

   SET @Lc_Job_ID = @Lc_JobLoadFcOrdr_ID;
   
   SET @Ls_CursorLocation_TEXT = @Lc_Space_TEXT;
   
   -- Selecting date run, date last run, commit freq, exception threshold details --
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY =  @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
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
   SET @Ls_FileSource_TEXT = '' + LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadFcOrder_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);

   -- Transaction begins 
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   BEGIN TRANSACTION FCORDR_BATCH_LOAD;

   -- Delete all the processed records
   SET @Ls_Sql_TEXT = 'DELETE FROM LoadFcOrderDetails_T1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   DELETE LFORD_Y1
    WHERE LFORD_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE FROM LoadFcEmployerDetails_T1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   DELETE LFEMP_Y1
    WHERE LFEMP_Y1.Process_INDC = @Lc_ProcessY_INDC;

   SET @Ln_OrderRecord_QNTY = 0;
   SET @Ln_EmployerRecord_QNTY = 0;
   SET @Ln_UnknownRecord_QNTY = 0;

   -- Check the record count for order records in the file 
   SELECT @Ln_OrderRecord_QNTY = COUNT(1)
     FROM #LoadFcOrder_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 4) = @Lc_OrderRec_ID; --'ORDR'
   --Check the record count for employer records in the file 
   SELECT @Ln_EmployerRecord_QNTY = COUNT(1)
     FROM #LoadFcOrder_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 4) = @Lc_EmployerRec_ID;

   -- Check the record count for unknown records in the file
   SELECT @Ln_UnknownRecord_QNTY = COUNT(1)
     FROM #LoadFcOrder_P1 a
    WHERE SUBSTRING (Record_TEXT, 1, 4) NOT IN (@Lc_EmployerRec_ID, @Lc_OrderRec_ID);

   -- If any order records exists in the file insert them into the table LFORD_Y1
   IF @Ln_OrderRecord_QNTY <> 0
    BEGIN
     INSERT LFORD_Y1
            (Rec_ID,
             Petition_IDNO,
             PetitionSequence_IDNO,
             Case_IDNO,
             PetitionType_CODE,
             PetitionAction_DATE,
             FamilyCourtFile_ID,
             SupportOrder_IDNO,
             HearingOfficer_ID,
             Hearing_DATE,
             ObligeeMCI_IDNO,
             ObligorMci_IDNO,
             Form_ID,
             OrderStatus_CODE,
             PermanentOrder_INDC,
             DefaultOrder_INDC,
             IvdCase_INDC,
             WageAttachment_INDC,
             Payment_INDC,
             Contempt_INDC,
             EmployerProgam_INDC,
             Credit_CODE,
             Arrears_CODE,
             DocCommit_CODE,
             HealthInsurance_CODE,
             CalculationDeviation_CODE,
             CountyEmployerProgram_IDNO,
             CurrentSupport_AMNT,
             Arrears_AMNT,
             MedicalSupport_AMNT,
             SpousalSupport_AMNT,
             GeneticTest_AMNT,
             TotalObligation_AMNT,
             ArrearsBalance_AMNT,
             TotalCredit_AMNT,
             ObligationEffective_DATE,
             ArrearsEffective_DATE,
             BalanceAsOf_DATE,
             CreditEffective_DATE,
             OutOfStateAgency_IDNO,
             ApprovedBy_ID,
             Approved_DATE,
             GeneticTestBalance_AMNT,
             MedicalBalance_AMNT,
             SpousalBalance_AMNT,
             RelatedPetition_IDNO,
             Other_AMNT,
             OtherAmountPurpose_TEXT,
             Detailed_TEXT,
             FileLoad_DATE,
             Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 4), @Lc_Space_TEXT))) AS Rec_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 5, 7), @Lc_Space_TEXT))) AS Petition_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 12, 2), @Lc_Space_TEXT))) AS PetitionSequence_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 14, 6), @Lc_Space_TEXT))) AS Case_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 4), @Lc_Space_TEXT))) AS PetitionType_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 25, 8), @Lc_Space_TEXT))) AS PetitionAction_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 33, 10), @Lc_Space_TEXT))) AS FamilyCourtFile_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 45, 7), @Lc_Space_TEXT))) AS SupportOrder_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 52, 7), @Lc_Space_TEXT))) AS HearingOfficer_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 59, 8), @Lc_Space_TEXT))) AS Hearing_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 67, 10), @Lc_Space_TEXT))) AS ObligeeMCI_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 77, 10), @Lc_Space_TEXT))) AS ObligorMci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 87, 3), @Lc_Space_TEXT))) AS Form_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 90, 1), @Lc_Space_TEXT))) AS OrderStatus_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 91, 1), @Lc_Space_TEXT))) AS PermanentOrder_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 92, 1), @Lc_Space_TEXT))) AS DefaultOrder_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 93, 1), @Lc_Space_TEXT))) AS IvdCase_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 94, 1), @Lc_Space_TEXT))) AS WageAttachment_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 95, 1), @Lc_Space_TEXT))) AS Payment_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 96, 1), @Lc_Space_TEXT))) AS Contempt_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 97, 1), @Lc_Space_TEXT))) AS EmployerProgam_INDC,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 98, 1), @Lc_Space_TEXT))) AS Credit_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 99, 1), @Lc_Space_TEXT))) AS Arrears_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 100, 1), @Lc_Space_TEXT)))AS DocCommit_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 101, 1), @Lc_Space_TEXT))) AS HealthInsurance_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 102, 2), @Lc_Space_TEXT))) AS CalculationDeviation_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 104, 1), @Lc_Space_TEXT))) AS CountyEmployerProgram_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 105, 9), @Lc_Space_TEXT))) AS CurrentSupport_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 114, 9), @Lc_Space_TEXT))) AS Arrears_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 123, 9), @Lc_Space_TEXT))) AS MedicalSupport_AMNT ,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 132, 9), @Lc_Space_TEXT))) AS SpousalSupport_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 141, 9), @Lc_Space_TEXT))) AS GeneticTest_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 150, 10), @Lc_Space_TEXT))) AS TotalObligation_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 160, 9), @Lc_Space_TEXT))) AS ArrearsBalance_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 169, 9), @Lc_Space_TEXT))) AS TotalCredit_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 178, 8), @Lc_Space_TEXT))) AS ObligationEffective_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 186, 8), @Lc_Space_TEXT))) AS ArrearsEffective_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 194, 8), @Lc_Space_TEXT))) AS BalanceAsOf_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 202, 8), @Lc_Space_TEXT))) AS CreditEffective_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 210, 12), @Lc_Space_TEXT))) AS OutOfStateAgency_IDNO ,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 222, 7), @Lc_Space_TEXT))) AS ApprovedBy_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 229, 8), @Lc_Space_TEXT))) AS Approved_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 237, 9), @Lc_Space_TEXT))) AS GeneticTestBalance_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 246, 9), @Lc_Space_TEXT))) AS MedicalBalance_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 255, 9), @Lc_Space_TEXT)))AS SpousalBalance_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 264, 7), @Lc_Space_TEXT))) AS RelatedPetition_IDNO ,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 271, 9), @Lc_Space_TEXT))) AS Other_AMNT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 280, 40), @Lc_Space_TEXT))) AS OtherAmountPurpose_TEXT,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 320, 4000), @Lc_Space_TEXT)))AS Detailed_TEXT,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_Value_CODE AS Process_INDC
       FROM #LoadFcOrder_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 4) = @Lc_OrderRec_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LoadFcOrderDetails_T1';

       RAISERROR(50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowCount_QNTY;
      END
    END

   -- If any employer records exists in the file insert them into the table LFEMP_Y1 
   
   SET @Ls_Sql_TEXT = 'INSERTING DATA INTO LFEMP_Y1 TABLE ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   IF @Ln_EmployerRecord_QNTY <> 0
    BEGIN
     INSERT LFEMP_Y1
            (Rec_ID,
             Petition_IDNO,
             PetitionSequence_IDNO,
             Case_IDNO,
             PetitionType_CODE,
             PetitionAction_DATE,
             FamilyCourtFile_ID,
             MemberMci_IDNO,
             EmployerOthp_IDNO,
             EmployerEin_IDNO,
             FileLoad_DATE,
             Process_INDC)
     SELECT (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 1, 4), @Lc_Space_TEXT))) AS Rec_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 5, 7), @Lc_Space_TEXT))) AS Petition_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 12, 2), @Lc_Space_TEXT))) AS PetitionSequence_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 14, 6), @Lc_Space_TEXT))) AS Case_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 20, 4), @Lc_Space_TEXT))) AS PetitionType_CODE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 25, 8), @Lc_Space_TEXT))) AS PetitionAction_DATE,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 33, 10), @Lc_Space_TEXT))) AS FamilyCourtFile_ID,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 45, 10), @Lc_Space_TEXT))) AS MemberMci_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 55, 9), @Lc_Space_TEXT))) AS EmployerOthp_IDNO,
            (RTRIM (ISNULL (SUBSTRING (Record_TEXT, 64, 9), @Lc_Space_TEXT))) AS EmployerEin_IDNO,
            @Ld_Run_DATE AS FileLoad_DATE,
            @Lc_Value_CODE AS Process_INDC
       FROM #LoadFcOrder_P1 a
      WHERE SUBSTRING (Record_TEXT, 1, 4) = @Lc_EmployerRec_ID; 
     SET @Li_RowCount_QNTY = @@ROWCOUNT;
    
     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT FAILED LoadFcEmployerDetails_T1';

       RAISERROR(50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowCount_QNTY;
      END
    END

   -- Check for unknown interface type and write an entry into the BATE_Y1 table 
   IF @Ln_UnknownRecord_QNTY <> 0
    BEGIN
     DECLARE FcOrder_Cur INSENSITIVE CURSOR  FOR
      SELECT Record_TEXT
        FROM #LoadFcOrder_P1 a
       WHERE SUBSTRING (Record_TEXT, 1, 4) NOT IN (@Lc_EmployerRec_ID, @Lc_OrderRec_ID);

     OPEN FcOrder_Cur;

     SET @Ln_FcUnidentifiedRecord_QNTY = 0;

     FETCH NEXT FROM FcOrder_Cur INTO @Ls_FcOrderCur_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	 -- Add the unknown records to the batch error table
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_FcUnidentifiedRecord_QNTY = @Ln_FcUnidentifiedRecord_QNTY + 1;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG ';
       SET @Ls_Sqldata_TEXT = 'RECORD_TYPE = ' + SUBSTRING(@Ls_FcOrderCur_TEXT, 1, 4) + ', FAMILYCOURT_PETITION_IDNO = ' + SUBSTRING(@Ls_FcOrderCur_TEXT, 5, 7) + ', Case_IDNO = ' + SUBSTRING(@Ls_FcOrderCur_TEXT, 14, 6) + ', PETITION_TYPE = ' + SUBSTRING(@Ls_FcOrderCur_TEXT, 20, 4) + ', Action_DATE = ' + SUBSTRING(@Ls_FcOrderCur_TEXT, 25, 8) + ', FAMILYCOURT_FILE_ID = ' + SUBSTRING(@Ls_FcOrderCur_TEXT, 33, 10);
       SET @Ls_DescriptionError_TEXT = @Ls_ErrorDescriptionRecord_TEXT;
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_FcUnidentifiedRecord_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorE1376_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';

         RAISERROR(50001,16,1);
        END

       FETCH NEXT FROM FcOrder_Cur INTO @Ls_FcOrderCur_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_FcUnidentifiedRecord_QNTY;

     CLOSE FcOrder_Cur;

     DEALLOCATE FcOrder_Cur;
    END

   -- Update the BATE_Y1 table, if there are no records in the input file 
   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A';
     SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
     SET @Lc_TypeError_CODE = @Lc_ErrorTypeWarning_CODE;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_NoRecordsInFile_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG A FAILED';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
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
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @LC_Successful_TEXT,
    @As_ListKey_TEXT          = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY  = @Ln_ProcessedRecordCount_QNTY;

   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   COMMIT TRANSACTION FCORDR_BATCH_LOAD;

   --Drop Temperory Table
   DROP TABLE #LoadFcOrder_P1;
  END TRY

  BEGIN CATCH
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCORDR_BATCH_LOAD;
    END

   --Drop Temperory Table
   IF OBJECT_ID('tempdb..#LoadFcOrder_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadFcOrder_P1;
    END
   
   --Close and deallocate the cursor
   IF CURSOR_STATUS ('VARIABLE', 'FcOrder_Cur') IN (0, 1)
    BEGIN
     CLOSE FcOrder_Cur;

     DEALLOCATE FcOrder_Cur;
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
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY  = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
