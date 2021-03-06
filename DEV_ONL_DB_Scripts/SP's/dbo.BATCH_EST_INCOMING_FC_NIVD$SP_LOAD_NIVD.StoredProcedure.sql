/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_NIVD$SP_LOAD_NIVD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-----------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_EST_INCOMING_FC_NIVD$SP_LOAD_NIVD
Programmer Name   :	IMP Team
Description       :	This process loads the Non IV-D data file into the temporary table for matching processing.
Frequency         :	Daily
Developed On      :	06/07/2011
Called By         :	None
Called on		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE
--------------------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_NIVD$SP_LOAD_NIVD]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE    CHAR(1) = 'A',
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_ErrrorTypeW_CODE          CHAR(1) = 'W',
          @Lc_ProcessN_INDC             CHAR(1) = 'N',
          @Lc_ProcessY_INDC             CHAR(1) = 'Y',
          @Lc_TypeError_IDNO            CHAR(1) = 'E',
          @Lc_DetailRecordTypeCase_TEXT CHAR(4) = 'CASE',
          @Lc_DetailRecordTypePart_TEXT CHAR(4) = 'PART',
          @Lc_BatchRunUser_TEXT         CHAR(5) = 'BATCH',
          @Lc_ErrrorE0944_CODE          CHAR(5) = 'E0944',
          @Lc_BateErrorE1376_CODE       CHAR(5) = 'E1376',
          @Lc_Job_ID                    CHAR(7) = 'DEB8074',
          @Lc_Successful_INDC           CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT      VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_LOAD_NIVD',
          @Ls_Process_NAME              VARCHAR(100) = 'BATCH_EST_INCOMING_FC_NIVD';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_CaseRecord_NUMB             NUMERIC(10) = 0,
          @Ln_PartRecord_NUMB             NUMERIC(10) = 0,
          @Ln_ErrorRecords_NUMB           NUMERIC(10) = 0,
          @Ln_FetchStatus_QNTY            NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(60),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ls_UnmatchCur_Record_TEXT VARCHAR(752);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadFcNonIvd_P1
    (
      Record_TEXT VARCHAR (752)
    );

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

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE PROCESSES RECORDS IN CASE LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'ProcessIndicator_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE LFCNC_Y1
    WHERE ProcessIndicator_INDC = @Lc_ProcessY_INDC;

   SET @Ls_Sql_TEXT = 'DELETE PROCESSES RECORDS IN PARTICIPANT LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'ProcessIndicator_INDC = ' + ISNULL(@Lc_ProcessY_INDC, '');

   DELETE LFCNP_Y1
    WHERE ProcessIndicator_INDC = @Lc_ProcessY_INDC;

   SET @Ls_FileSource_TEXT = '' + LTRIM(RTRIM(@Ls_FileLocation_TEXT)) + LTRIM(RTRIM(@Ls_File_NAME));

   IF @Ls_FileSource_TEXT = ''
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadFcNonIvd_P1  FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXECUTE (@Ls_SqlStmnt_TEXT);

   SET @Ln_CaseRecord_NUMB = (SELECT COUNT (1)
                                FROM #LoadFcNonIvd_P1 a
                               WHERE SUBSTRING(Record_TEXT, 1, 4) = @Lc_DetailRecordTypeCase_TEXT);
   SET @Ln_PartRecord_NUMB = (SELECT COUNT (1)
                                FROM #LoadFcNonIvd_P1 b
                               WHERE SUBSTRING(Record_TEXT, 1, 4) = @Lc_DetailRecordTypePart_TEXT);
   SET @Ln_ErrorRecords_NUMB = (SELECT COUNT (1)
                                  FROM #LoadFcNonIvd_P1 c
                                 WHERE SUBSTRING(Record_TEXT, 1, 4) NOT IN (@Lc_DetailRecordTypeCase_TEXT, @Lc_DetailRecordTypePart_TEXT, @Lc_Space_TEXT));
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION FCNONIVD_LOAD;

   IF @Ln_CaseRecord_NUMB <> 0
      AND @Ln_PartRecord_NUMB <> 0
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_CaseRecord_NUMB + @Ln_PartRecord_NUMB;
     SET @Ls_Sql_TEXT = 'INSERT LFCNC_Y1 CASE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     INSERT LFCNC_Y1
            (Rec_ID,
             Petition_IDNO,
             RelatedSeq_NUMB,
             Case_IDNO,
             PetitionType_CODE,
             Action_DATE,
             FamilyCrtFile_ID,
             CpMci_IDNO,
             NcpMci_IDNO,
             IVDType_CODE,
             County_IDNO,
             InterStateStatus_CODE,
             InterStateState_CODE,
             FileLoad_DATE,
             ProcessIndicator_INDC)
     SELECT RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 4), @Lc_Space_TEXT)) AS Rec_ID,-- Rec_ID
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 5, 7), @Lc_Space_TEXT))) AS Petition_IDNO,-- Petition_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 12, 2), @Lc_Space_TEXT))) AS RelatedSeq_NUMB,-- RelatedSeq_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 14, 6), @Lc_Space_TEXT))) AS Case_IDNO,-- FciiCaseNumber_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 20, 4), @Lc_Space_TEXT))) AS PetitionType_CODE,-- FciiPetitionType_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 25, 8), @Lc_Space_TEXT))) AS Action_DATE,-- FciiAction_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 33, 10), @Lc_Space_TEXT))) AS FamilyCrtFile_ID,-- FciiFamilyCrtFile_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 43, 10), @Lc_Space_TEXT))) AS CpMci_IDNO,-- CpMci_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 53, 10), @Lc_Space_TEXT))) AS NcpMci_IDNO,-- NcpMci_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 65, 4), @Lc_Space_TEXT))) AS IVDType_CODE,-- FciiCaseIVDType_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 69, 3), @Lc_Space_TEXT))) AS County_IDNO,-- FciiCaseCounty_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 72, 1), @Lc_Space_TEXT))) AS InterStateStatus_CODE,-- FciiCaseInterState_STAT
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 73, 2), @Lc_Space_TEXT))) AS InterStateState_CODE,-- FciiCaseInterStateSt_CODE
            @Ld_Run_DATE FileLoad_DATE,
            @Lc_ProcessN_INDC ProcessIndicator_INDC
       FROM #LoadFcNonIvd_P1 a
      WHERE SUBSTRING(Record_TEXT, 1, 4) = @Lc_DetailRecordTypeCase_TEXT;

     SET @Ls_Sql_TEXT = 'INSERT LFCNP_Y1 PARTICIPANT';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     INSERT LFCNP_Y1
            (Rec_ID,
             Petition_IDNO,
             Action_DATE,
             FamilyCrtFile_ID,
             MemberMci_IDNO,
             MemberType_CODE,
             Relationship_CODE,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             MemberSsn_NUMB,
             Birth_DATE,
             MemberSex_CODE,
             Race_CODE,
             ColorEyes_CODE,
             ColorHair_CODE,
             DescriptionHeightFt_TEXT,
             DescriptionHeightInches_TEXT,
             DescriptionWeightLbs_TEXT,
             HomePhone_NUMB,
             MailLine1Old_ADDR,
             MailLine2Old_ADDR,
             MailCityOld_ADDR,
             MailStateOld_ADDR,
             MailZipOld_ADDR,
             CellPhone_NUMB,
             OthrLine1Old_ADDR,
             OthrLine2Old_ADDR,
             OthrCityOld_ADDR,
             OthrStateOld_ADDR,
             OthrZipOld_ADDR,
             OthpId_IDNO,
             OthrEmployer_IDNO,
             MailAddrNorm_CODE,
             MailLine1_ADDR,
             MailLine2_ADDR,
             MailCity_ADDR,
             MailState_ADDR,
             MailZip_ADDR,
             OthrAddrNorm_CODE,
             OthrLine1_ADDR,
             OthrLine2_ADDR,
             OthrCity_ADDR,
             OthrState_ADDR,
             OthrZip_ADDR,
             FileLoad_DATE,
             ProcessIndicator_INDC)
     SELECT (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 1, 4), @Lc_Space_TEXT))) AS Rec_ID,-- Record Type_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 5, 7), @Lc_Space_TEXT))) AS Petition_IDNO,-- Petition_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 25, 8), @Lc_Space_TEXT))) AS Action_DATE,-- FciiAction_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 33, 10), @Lc_Space_TEXT))) AS FamilyCrtFile_ID,-- FciiFamilyCrtFile_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 65, 10), @Lc_Space_TEXT))) AS MemberMci_IDNO,-- FciiPartMci_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 75, 4), @Lc_Space_TEXT))) AS MemberType_CODE,-- FciiPartType_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 79, 4), @Lc_Space_TEXT))) AS Relationship_CODE,-- FciiPartRelate_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 83, 17), @Lc_Space_TEXT))) AS Last_NAME,-- FciiPartLast_NAME
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 100, 11), @Lc_Space_TEXT))) AS First_NAME,-- FciiPartFirst_NAME
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 111, 1), @Lc_Space_TEXT))) AS Middle_NAME,-- FciiPartMiddlle_NAME
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 112, 9), @Lc_Space_TEXT))) AS MemberSsn_NUMB,-- FciiPart_SSN
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 121, 8), @Lc_Space_TEXT))) AS Birth_DATE,-- FciiPartDateofBirth_DATE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 129, 1), @Lc_Space_TEXT))) AS MemberSex_CODE,-- FciiPartSex_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 130, 1), @Lc_Space_TEXT))) AS Race_CODE,-- Race_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 131, 3), @Lc_Space_TEXT))) AS ColorEyes_CODE,-- FciiPartEyeColor_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 134, 3), @Lc_Space_TEXT))) AS ColorHair_CODE,-- FciiPartHairColor_CODE		
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 137, 1), @Lc_Space_TEXT))) AS DescriptionHeightFt_TEXT,-- FciiPartHeightFt_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 139, 2), @Lc_Space_TEXT))) AS DescriptionHeightInches_TEXT,-- FciiPartHeightInches_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 141, 4), @Lc_Space_TEXT))) AS DescriptionWeightLbs_TEXT,-- FciiPartWeight_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 145, 10), @Lc_Space_TEXT))) AS HomePhone_NUMB,-- FciiPartMailPhone_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 155, 31), @Lc_Space_TEXT))) AS MailLine1Old_ADDR,-- FciiPartMailLine1_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 186, 31), @Lc_Space_TEXT))) AS MailLine2Old_ADDR,-- FciiPartMailLine2_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 217, 16), @Lc_Space_TEXT))) AS MailCityOld_ADDR,-- FciiPartMailCity_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 233, 2), @Lc_Space_TEXT))) AS MailStateOld_ADDR,-- FciiPartMailState_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 235, 9), @Lc_Space_TEXT))) AS MailZipOld_ADDR,-- FciiPartMailZip_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 244, 10), @Lc_Space_TEXT))) AS CellPhone_NUMB,-- FciiPartOthrPhone_NUMB
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 254, 31), @Lc_Space_TEXT))) AS OthrLine1Old_ADDR,-- FciiPartOthrLine1_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 285, 31), @Lc_Space_TEXT))) AS OthrLine2Old_ADDR,-- FciiPartOthrLine2_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 316, 16), @Lc_Space_TEXT))) AS OthrCityOld_ADDR,-- FciiPartOthrCity_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 332, 2), @Lc_Space_TEXT))) AS OthrStateOld_ADDR,-- FciiPartOthrState_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 334, 9), @Lc_Space_TEXT))) AS OthrZipOld_ADDR,-- FciiPartOthrZIP_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 343, 9), @Lc_Space_TEXT))) AS OthpId_IDNO,-- FciiPartOthrId_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 352, 9), @Lc_Space_TEXT))) AS OthrEmployer_IDNO,-- FciiPartOthrEmployer_IDNO
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 461, 1), @Lc_Space_TEXT))) AS MailAddrNorm_CODE,-- FciiPartMailAddrNorm_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 462, 50), @Lc_Space_TEXT))) AS MailLine1_ADDR,-- FciiPartMailLine1N_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 512, 50), @Lc_Space_TEXT))) AS MailLine2_ADDR,-- FciiPartMailLine2N_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 562, 28), @Lc_Space_TEXT))) AS MailCity_ADDR,-- FciiPartMailCityN_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 590, 2), @Lc_Space_TEXT))) AS MailState_ADDR,-- FciiPartMailStateN_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 592, 15), @Lc_Space_TEXT))) AS MailZip_ADDR,-- FciiPartMailZipN_ADDR		        
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 607, 1), @Lc_Space_TEXT))) AS OthrAddrNorm_CODE,-- FciiPartOthrAddrNorm_CODE
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 608, 50), @Lc_Space_TEXT))) AS OthrLine1_ADDR,-- FciiPartOthrLine1N_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 658, 50), @Lc_Space_TEXT))) AS OthrLine2_ADDR,-- FciiPartOthrLine2N_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 708, 28), @Lc_Space_TEXT))) AS OthrCity_ADDR,-- FciiPartOthrCityN_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 736, 2), @Lc_Space_TEXT))) AS OthrState_ADDR,-- FciiPartOthrStateN_ADDR
            (RTRIM(ISNULL(SUBSTRING(Record_TEXT, 738, 15), @Lc_Space_TEXT))) AS OthrZip_ADDR,-- FciiPartOthrZIPN_ADDR
            @Ld_Run_DATE FileLoad_DATE,
            @Lc_ProcessN_INDC ProcessIndicator_INDC
       FROM #LoadFcNonIvd_P1 b
      WHERE SUBSTRING(Record_TEXT, 1, 4) = @Lc_DetailRecordTypePart_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrrorTypeW_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrrorTypeW_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   IF @Ln_ErrorRecords_NUMB > 0
    BEGIN
     DECLARE Unmatch_Cur INSENSITIVE CURSOR FOR
      SELECT a.Record_TEXT
        FROM #LoadFcNonIvd_P1 a
       WHERE SUBSTRING(Record_TEXT, 1, 4) NOT IN (@Lc_DetailRecordTypeCase_TEXT, @Lc_DetailRecordTypePart_TEXT, @Lc_Space_TEXT);

     SET @Ls_Sql_TEXT = 'OPEN Unmatch_Cur';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

     OPEN Unmatch_Cur;

     SET @Ls_Sql_TEXT = 'FETCH Unmatch_Cur - 1';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

     FETCH NEXT FROM Unmatch_Cur INTO @Ls_UnmatchCur_Record_TEXT;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     --Cursor to process each record in Participant table LFCNP_Y1
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_BateRecord_TEXT = 'Record Type = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 1, 4), @Lc_Space_TEXT) + ', Petition Number = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 5, 7), @Lc_Space_TEXT) + ', Related Sequence Number = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 12, 2), @Lc_Space_TEXT) + ', Case Number = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 14, 6), @Lc_Space_TEXT) + ', Petition Type Code = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 20, 4), @Lc_Space_TEXT) + ', Action Date = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 25, 8), @Lc_Space_TEXT) + ', File Number = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 33, 10), @Lc_Space_TEXT) + ', Cp Mci Number = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 43, 10), @Lc_Space_TEXT) + ', Ncp Mci Number = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 53, 10), @Lc_Space_TEXT) + ', Remaing Record Text = ' + ISNULL(SUBSTRING(@Ls_UnmatchCur_Record_TEXT, 65, 396), @Lc_Space_TEXT);
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_IDNO, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateErrorE1376_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '');
       SET @Ls_DescriptionError_TEXT = 'UNKNOWN INTERFACE TYPE';

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_IDNO,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_BateErrorE1376_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       FETCH NEXT FROM Unmatch_Cur INTO @Ls_UnmatchCur_Record_TEXT;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE Unmatch_Cur;

     DEALLOCATE Unmatch_Cur;
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

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE IF EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DROP TABLE #LoadFcNonIvd_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION FCNONIVD_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCNONIVD_LOAD;
    END

   IF OBJECT_ID('tempdb..#LoadFcNonIvd_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadFcNonIvd_P1;
    END

   IF CURSOR_STATUS('Local', 'Unmatch_Cur') IN (0, 1)
    BEGIN
     CLOSE Unmatch_Cur;

     DEALLOCATE Unmatch_Cur;
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

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
