/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_W4NEWHIRE$SP_PROCESS_NEWHIRE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_W4NEWHIRE$SP_PROCESS_NEWHIRE
Programmer Name   :	IMP Team
Description       : The purpose of W4NewHire response process is to update member address history and his employment 
				    history in the system with the addresses received from W4NewHire. 
Frequency         :	Daily.
Developed On      :	11/02/2011
Called By         :	None
Called On		  :	
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_W4NEWHIRE$SP_PROCESS_NEWHIRE]
AS
 BEGIN
  SET NOCOUNT ON;
  
   DECLARE @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE            CHAR(1) = 'A',
           @Lc_MailingTypeAddress_CODE           CHAR(1) = 'M',
           @Lc_PendingStatus_CODE                CHAR(1) = 'P',
           @Lc_ConformedGoodStatus_CODE          CHAR(1) = 'Y',
           @Lc_IndNote_TEXT                      CHAR(1) = 'N',
           @Lc_TypeErrorE_CODE                    CHAR(1) = 'E',
           @Lc_TypeErrorWarning_CODE             CHAR(1) = 'W',
           @Lc_TypeAddressMailing_CODE           CHAR(1) = 'M',
           @Lc_TypeAddressResidence_CODE         CHAR(1) = 'R',
           @Lc_ActiveCaseMemberStatus_CODE       CHAR(1) = 'A',
           @Lc_OpenStatusCase_CODE               CHAR(1) = 'O',
           @Lc_ProcessY_INDC                     CHAR(1) = 'Y',
           @Lc_ProcessN_INDC                     CHAR(1) = 'N',
           @Lc_StatusCaseOpen_CODE               CHAR(1) = 'O',
           @Lc_StatusCaseClose_CODE              CHAR(1) = 'C',
           @Lc_CaseRelationshipNcp_CODE          CHAR(1) = 'A',
           @Lc_CaseRelationshipPutative_CODE     CHAR(1) = 'P',
           @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
           @Lc_TypeOthpEmployer_CODE             CHAR(1) = 'E',
           @Lc_SourceLocConf_CODE                CHAR(1) = 'A',
           @Lc_SourceVerifiedA_CODE			     CHAR(1) = 'A',
           @Lc_Country_ADDR                      CHAR(2) = 'US',
           @Lc_TypeIncomeEm_CODE                 CHAR(2) = 'EM',
           @Lc_RsnStatusCaseUc_CODE              CHAR(2) = 'UC',
           @Lc_RsnStatusCaseUb_CODE              CHAR(2) = 'UB',
           @Lc_SourceLocation_CODE               CHAR(3) = 'SNH',
           @Lc_Subsystem_CODE                    CHAR(3) = 'LO',
           @Lc_ActivityMajor_CODE                CHAR(4) = 'CASE',
           @Lc_TypeReference_IDNO                CHAR(4) = ' ',
           @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
           @Lc_WorkerUpdate_ID                   CHAR(5) = 'BATCH',
           @Lc_BateError_CODE                    CHAR(5) = ' ',
           @Lc_ErrorE0944_CODE                   CHAR(5) = 'E0944',
           @Lc_ErrorE0907_CODE                   CHAR(5) = 'E0907',
           @Lc_ErrorE0085_CODE                   CHAR(5) = 'E0085',
           @Lc_ErrorE1405_CODE                   CHAR(5) = 'E1405',
           @Lc_ErrorE0962_CODE                   CHAR(5) = 'E0962',
           @Lc_ErrorE0886_CODE                   CHAR(5) = 'E0886',
		   @Lc_ErrorE1424_CODE					 CHAR(5) = 'E1424',
		   @Lc_ErrorE1089_CODE				     CHAR(5) = 'E1089',
           @Lc_MinorActivityLocac_CODE           CHAR(5) = 'LOCAC',
           @Lc_MinorActivityRcona_CODE           CHAR(5) = 'RCONA',
           @Lc_MinorActivityRunca_CODE           CHAR(5) = 'RUNCA',
           @Lc_Fips_CODE                         CHAR(7) = ' ',
           @Lc_Job_ID                            CHAR(7) = 'DEB0470',
           @Lc_Process_ID                        CHAR(10) = 'DEB0470',
           @Lc_Successful_TEXT                   CHAR(20) = 'SUCCESSFUL',
           @Lc_DescriptionContactOther_TEXT      CHAR(30) = ' ',
           @Lc_Error0002_TEXT                    CHAR(30) = 'UPDATE NOT SUCCESSFUL',
           @Lc_WorkerDelegate_ID                 CHAR(30) = ' ',
           @Lc_Reference_ID                      CHAR(30) = ' ',
           @Lc_Attn_ADDR                         CHAR(40) = ' ',
           @Ls_ParmDateProblem_TEXT              VARCHAR(50) = 'PARM DATE PROBLEM',
           @Ls_Process_NAME                      VARCHAR(100) = 'BATCH_LOC_INCOMING_W4NEWHIRE',
           @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_PROCESS_NEWHIRE',
           @Ls_DescriptionComments_TEXT          VARCHAR(1000) = ' ',
           @Ls_DescriptionServiceDirection_TEXT  VARCHAR(1000) = ' ',
           @Ls_XmlTextIn_TEXT                    VARCHAR(8000) = ' ',
           @Ld_Low_DATE                          DATE = '01/01/0001',
           @Ld_High_DATE                         DATE = '12/31/9999';
  DECLARE  @Ln_TopicIn_IDNO                 NUMERIC = 0,
		   @Ln_CommitFreq_QNTY              NUMERIC(5) = 0,
		   @Ln_CommitFreqParm_QNTY          NUMERIC(5) = 0,
		   @Ln_ExceptionThreshold_QNTY      NUMERIC(5) = 0,
		   @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5) = 0,
           @Ln_Office_IDNO                  NUMERIC(5) = 0,
           @Ln_Zero_NUMB                    NUMERIC(5) = 0,
           @Ln_RestartLine_NUMB             NUMERIC(5) = 0,
           @Ln_MajorIntSeq_NUMB             NUMERIC(5) = 0,
           @Ln_MinorIntSeq_NUMB             NUMERIC(5) = 0,
           @Ln_DchCarrier_IDNO              NUMERIC(8) = 0,
           @Ln_ReferenceOthp_IDNO           NUMERIC(9) = 0,
           @Ln_OtherParty_IDNO              NUMERIC(9) = 0,
           @Ln_OthpSource_IDNO              NUMERIC(9) = 0,
           @Ln_OthpLocation_IDNO            NUMERIC(9,0),
           @Ln_RecordCount_QNTY             NUMERIC(10) = 0,
           @Ln_BarAtty_NUMB                 NUMERIC(10) = 0,
           @Ln_Schedule_NUMB                NUMERIC(10) = 0,
           @Ln_Topic_IDNO                   NUMERIC(10) = 0,
           @Ln_MemberMci_IDNO               NUMERIC(10) = 0,
           @Ln_Error_NUMB                   NUMERIC(11) = 0,
           @Ln_ErrorLine_NUMB               NUMERIC(11) = 0,
           @Ln_Sein_IDNO                    NUMERIC(12) = 0,
           @Ln_TransactionEventSeq_NUMB     NUMERIC(18) = 0,
           @Ln_ProcessedRecordCount_QNTY    NUMERIC(19) = 0,
           @Ln_ProcessedRecordsCommit_QNTY  NUMERIC(19) = 0,
           @Li_FetchStatus_QNTY             SMALLINT,
           @Li_RowsCount_QNTY               SMALLINT,
           @Lc_Space_TEXT                   CHAR(1) = '',
           @Lc_Status_CODE                  CHAR(1) = '',
           @Lc_OthStateFips_CODE            CHAR(2) = '',
           @Lc_ReasonStatus_CODE            CHAR(2) = '',
           @Lc_AhisMinorActivity_CODE       CHAR(5) = '',
           @Lc_Msg_CODE                     CHAR(5) = '',
           @Lc_Notice_ID                    CHAR(8) = '',
           @Lc_Schedule_Member_IDNO         CHAR(10) = '',
           @Lc_Schedule_Worker_IDNO         CHAR(30) = '',
           @Ls_Contact_EML                  VARCHAR(60) = '',
           @Ls_CursorLocation_TEXT          VARCHAR(200) = '',
           @Ls_Sql_TEXT                     VARCHAR(2000) = '',
           @Ls_ErrorMessage_TEXT            VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT        VARCHAR(4000),
           @Ls_BateRecord_TEXT              VARCHAR(4000),
           @Ls_BateRecord1_TEXT             VARCHAR(4000),
           @Ls_Sqldata_TEXT                 VARCHAR(5000) = '',
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
           @Ld_Start_DATE                   DATETIME2,
           @Ld_BeginSch_DTTM                DATETIME2,
           @Lb_ErrorExpection_CODE          BIT = 0,
           @Lb_AhisCaseJournal_CODE         BIT = 0,
           @Lb_EhisCaseJournal_CODE         BIT = 0,
           @Lb_EhisHireDate_CODE	        BIT = 0;

  DECLARE NewHire_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
			a.Rec_ID,
			a.Last_Name,
			a.First_NAME,
			a.Middle_NAME,
			a.MemberSsn_NUMB,
			a.Hire_DATE,
			a.LeftEmpTemp_INDC,
			a.Birth_DATE,
			a.MemberSex_CODE,
			a.StateHire_CODE,
			a.Employer_Name,
			a.Fein_IDNO,
			a.FederalTaxType_CODE,
			a.FederalTaxVerification_CODE,
			a.Batch_NUMB,
			a.EmployeeCountry_CODE,
			a.EmployeeCountry_NAME,
			a.EmployeeCountryZip_CODE,
			a.EmployerCountry_CODE,
			a.EmployerCountry_NAME,
			a.EmployerCountryZip_CODE,
			a.Normalization_CODE,
			a.Line1_ADDR,
			a.Line2_ADDR,
			a.City_ADDR,
			a.State_ADDR,
			a.Zip_ADDR,
			a.NormalizationEmployer_CODE,
			a.EmployerLine1_ADDR,
			a.EmployerLine2_ADDR,
			a.EmployerCity_ADDR,
			a.EmployerState_ADDR,
			a.EmployerZip_ADDR
       FROM LW4NH_Y1 a 
      WHERE a.Process_INDC = @Lc_ProcessN_INDC
	  ORDER BY a.Seq_IDNO;
   
  DECLARE @Ln_NewHireCur_Seq_IDNO						NUMERIC(19),			 
		  @Lc_NewHireCur_Rec_ID							CHAR(1),
		  @Lc_NewHireCur_Last_NAME						CHAR(15),
		  @Lc_NewHireCur_First_NAME						CHAR(15),
		  @Lc_NewHireCur_Middle_NAME					CHAR(1),
		  @Lc_NewHireCur_MemberSsnNumb_TEXT				CHAR(9),
		  @Lc_NewHireCur_HireDate_TEXT					CHAR(8),
		  @Lc_NewHireCur_LeftEmpTemp_INDC				CHAR(1),
		  @Lc_NewHireCur_BirthDate_TEXT						CHAR(8),
		  @Lc_NewHireCur_MemberSex_CODE					CHAR(1),
		  @Lc_NewHireCur_StateHire_CODE					CHAR(2),
		  @Lc_NewHireCur_Employer_NAME					CHAR(30),
		  @Lc_NewHireCur_FeinIdno_TEXT					CHAR(9),
		  @Lc_NewHireCur_FederalTaxType_CODE			CHAR(1),
		  @Lc_NewHireCur_FederalTaxVerification_CODE	CHAR(1),
		  @Lc_NewHireCur_BatchNumb_TEXT						CHAR(9),
		  @Lc_NewHireCur_EmployeeCountry_CODE 			CHAR(2),
		  @Lc_NewHireCur_EmployeeCountry_NAME 			CHAR(25),
		  @Lc_NewHireCur_EmployeeCountryZip_CODE 		CHAR(15),
		  @Lc_NewHireCur_EmployerCountry_CODE 			CHAR(2),
		  @Lc_NewHireCur_EmployerCountry_NAME 			CHAR(25),
		  @Lc_NewHireCur_EmployerCountryZip_CODE 		CHAR(15),
		  @Lc_NewHireCur_Normalization_CODE 			CHAR(1),
		  @Ls_NewHireCur_Line1_ADDR 					VARCHAR(50),
		  @Ls_NewHireCur_Line2_ADDR 					VARCHAR(50),
		  @Lc_NewHireCur_City_ADDR 						CHAR(28),
		  @Lc_NewHireCur_State_ADDR 					CHAR(2),
		  @Lc_NewHireCur_Zip_ADDR 						CHAR(15),
		  @Lc_NewHireCur_NormalizedEmp_CODE 			CHAR(1),
		  @Ls_NewHireCur_EmployerLine1_ADDR 			VARCHAR(50),
		  @Ls_NewHireCur_EmployerLine2_ADDR 			VARCHAR(50),
		  @Lc_NewHireCur_EmployerCity_ADDR 				CHAR(28),
		  @Lc_NewHireCur_EmployerState_ADDR 			CHAR(2),
		  @Lc_NewHireCur_EmployerZip_ADDR				CHAR(15),
		  @Ln_CaseMemberCur_Case_IDNO					NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO				NUMERIC(10);
  
  DECLARE @Ln_NewHireCurMemberSsn_NUMB NUMERIC(9),
		  @Ln_NewHireCurFein_IDNO	   NUMERIC(9),
		  @Ld_NewHireCurHire_DATE	   DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION NEWHIRE_PROCESS;
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
  
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 a
    WHERE Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Line Number = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN NewHire_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   OPEN NewHire_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NewHire_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   FETCH NEXT FROM NewHire_CUR INTO @Ln_NewHireCur_Seq_IDNO, @Lc_NewHireCur_Rec_ID, @Lc_NewHireCur_Last_NAME, @Lc_NewHireCur_First_NAME,@Lc_NewHireCur_Middle_NAME, @Lc_NewHireCur_MemberSsnNumb_TEXT, @Lc_NewHireCur_HireDate_TEXT, @Lc_NewHireCur_LeftEmpTemp_INDC, @Lc_NewHireCur_BirthDate_TEXT, @Lc_NewHireCur_MemberSex_CODE, @Lc_NewHireCur_StateHire_CODE, @Lc_NewHireCur_Employer_NAME, @Lc_NewHireCur_FeinIdno_TEXT, @Lc_NewHireCur_FederalTaxType_CODE, @Lc_NewHireCur_FederalTaxVerification_CODE, @Lc_NewHireCur_BatchNumb_TEXT, @Lc_NewHireCur_EmployeeCountry_CODE, @Lc_NewHireCur_EmployeeCountry_NAME, @Lc_NewHireCur_EmployeeCountryZip_CODE, @Lc_NewHireCur_EmployerCountry_CODE, @Lc_NewHireCur_EmployerCountry_NAME, @Lc_NewHireCur_EmployerCountryZip_CODE, @Lc_NewHireCur_Normalization_CODE, @Ls_NewHireCur_Line1_ADDR, @Ls_NewHireCur_Line2_ADDR, @Lc_NewHireCur_City_ADDR, @Lc_NewHireCur_State_ADDR, @Lc_NewHireCur_Zip_ADDR, @Lc_NewHireCur_NormalizedEmp_CODE, @Ls_NewHireCur_EmployerLine1_ADDR, @Ls_NewHireCur_EmployerLine2_ADDR, @Lc_NewHireCur_EmployerCity_ADDR, @Lc_NewHireCur_EmployerState_ADDR, @Lc_NewHireCur_EmployerZip_ADDR;
   
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;
   -- Fetches each record to process.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

      SAVE TRANSACTION SAVENEWHIRE_PROCESS;
      
	  SET @Ls_BateRecord_TEXT = 'Sequence Id = ' + CAST(@Ln_NewHireCur_Seq_IDNO AS VARCHAR) + ', Record Id = ' + @Lc_NewHireCur_Rec_ID + ', Last Name = ' + @Lc_NewHireCur_Last_NAME + ', First Name = ' + @Lc_NewHireCur_First_NAME + ', Middle Name = ' +@Lc_NewHireCur_Middle_NAME + ', Member SSN = ' + @Lc_NewHireCur_MemberSsnNumb_TEXT + ', Hire Date = ' + @Lc_NewHireCur_HireDate_TEXT + ', Left Emp Tmp = ' + @Lc_NewHireCur_LeftEmpTemp_INDC + ', Birth Date = ' + @Lc_NewHireCur_BirthDate_TEXT + ', Member Sex Code = ' + @Lc_NewHireCur_MemberSex_CODE + ', State Hire Date = ' + @Lc_NewHireCur_StateHire_CODE + ', Employer Name = ' + @Lc_NewHireCur_Employer_NAME + ', Fein Id = ' + @Lc_NewHireCur_FeinIdno_TEXT + ', Federal Tax Type Code = ' + @Lc_NewHireCur_FederalTaxType_CODE + ', Federal Tax Verification Code = ' + @Lc_NewHireCur_FederalTaxVerification_CODE + ', Batch Numb = ' + @Lc_NewHireCur_BatchNumb_TEXT + ', Employee Country Code = ' + @Lc_NewHireCur_EmployeeCountry_CODE + ', Employee Country Name = ' + @Lc_NewHireCur_EmployeeCountry_NAME + ', Employee Country Zip Code = ' + @Lc_NewHireCur_EmployeeCountryZip_CODE + ', Employer Country Code = ' + @Lc_NewHireCur_EmployerCountry_CODE + ', Employer Country Name = ' + @Lc_NewHireCur_EmployerCountry_NAME + ', Employer Country Zip Code = ' + @Lc_NewHireCur_EmployerCountryZip_CODE + ', Member Address Normalization Code = ' + @Lc_NewHireCur_Normalization_CODE + ', Line 1 Address = ' + @Ls_NewHireCur_Line1_ADDR + ', Line 2 Address = ' + @Ls_NewHireCur_Line2_ADDR + ', City Address = ' + @Lc_NewHireCur_City_ADDR + ', State Address = ' + @Lc_NewHireCur_State_ADDR + ', Zip Code Address = ' + @Lc_NewHireCur_Zip_ADDR + ', Employer Address Normalization Code = ' + @Lc_NewHireCur_NormalizedEmp_CODE + ', Employer Line 1 Address = ' + @Ls_NewHireCur_EmployerLine1_ADDR + ', Employer Line 2 Address = ' + @Ls_NewHireCur_EmployerLine2_ADDR + ', Employer City Address = ' + @Lc_NewHireCur_EmployerCity_ADDR + ', Employer State Address = ' + @Lc_NewHireCur_EmployerState_ADDR + ', Employer Zip Code Address = ' + @Lc_NewHireCur_EmployerZip_ADDR;
      SET @Ls_BateRecord1_TEXT = @Ls_BateRecord_TEXT;     
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
	  SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'NEWHIRE - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Lb_EhisCaseJournal_CODE = 0;
      SET @Lb_AhisCaseJournal_CODE = 0;
      SET @Lb_ErrorExpection_CODE = 0;
      SET @Lb_EhisHireDate_CODE = 0;
      SET @Ln_MemberMci_IDNO = 0;
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '')+ ', SSN = ' + @Lc_NewHireCur_MemberSsnNumb_TEXT;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_NewHireCur_MemberSsnNumb_TEXT))) = 1
        AND ISNUMERIC(ISNULL(LTRIM(RTRIM(@Lc_NewHireCur_FeinIdno_TEXT)),0)) = 1
       BEGIN
        SET @Ln_NewHireCurMemberSsn_NUMB = CAST(LTRIM(RTRIM(@Lc_NewHireCur_MemberSsnNumb_TEXT)) AS NUMERIC);
        SET @Ln_NewHireCurFein_IDNO = CAST(ISNULL(LTRIM(RTRIM(@Lc_NewHireCur_FeinIdno_TEXT)),0) AS NUMERIC);
        
        IF ISDATE(@Lc_NewHireCur_HireDate_TEXT) = 1
		  BEGIN
			SET @Ld_NewHireCurHire_DATE = CAST(@Lc_NewHireCur_HireDate_TEXT AS DATE);
			SET @Lb_EhisHireDate_CODE = 1;
          END
       END
      ELSE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
    
        RAISERROR (50001,16,1);
       END
      
      IF EXISTS (SELECT 1
                       FROM DEMO_Y1
                      WHERE MemberSsn_NUMB = @Ln_NewHireCurMemberSsn_NUMB)
       BEGIN
        IF NOT EXISTS (SELECT 1
                       FROM DEMO_Y1
                      WHERE LEFT(Last_NAME, 5) = LEFT(@Lc_NewHireCur_Last_NAME, 5)
					    AND MemberSsn_NUMB = @Ln_NewHireCurMemberSsn_NUMB)
		  BEGIN
			SET @Lc_BateError_CODE = @Lc_ErrorE0886_CODE;
	     
			RAISERROR (50001,16,1);
		  END;
        ELSE IF EXISTS (SELECT 1 
					   FROM DEMO_Y1 
					  WHERE MemberSsn_NUMB = @Ln_NewHireCurMemberSsn_NUMB
					  HAVING COUNT(1) > 1)	
		 BEGIN
		  SET @Lc_BateError_CODE = @Lc_ErrorE0962_CODE;
		
		  RAISERROR (50001,16,1);
         END;			  
        ELSE IF NOT EXISTS (SELECT 1
                       FROM CASE_Y1 C
                            JOIN CMEM_Y1 M
                             ON C.Case_IDNO = M.Case_IDNO
                            JOIN DEMO_Y1 D
                             ON D.MemberMci_IDNO = M.MemberMci_IDNO
                      WHERE C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                        AND M.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE 
                        AND D.MemberSsn_NUMB = @Ln_NewHireCurMemberSsn_NUMB
                        AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE))
        AND NOT EXISTS (SELECT 1
                           FROM CASE_Y1 C
                                JOIN CMEM_Y1 M
                                 ON C.CASE_IDNO = M.CASE_IDNO
                                JOIN DEMO_Y1 D
                                 ON D.MemberMci_IDNO = M.MemberMci_IDNO
                          WHERE C.StatusCase_CODE = @Lc_StatusCaseClose_CODE
							AND M.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE 
                            AND C.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseUc_CODE, @Lc_RsnStatusCaseUb_CODE)
                            AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
                            AND D.MemberSsn_NUMB = @Ln_NewHireCurMemberSsn_NUMB)
         BEGIN
			SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;
		
			RAISERROR (50001,16,1);
		 END;
		   
        ELSE
         BEGIN
			SET @Ln_MemberMci_IDNO = (SELECT MemberMci_IDNO
										FROM DEMO_Y1
									   WHERE MemberSsn_NUMB = @Ln_NewHireCurMemberSsn_NUMB
										 AND LEFT(Last_NAME, 5) = LEFT(@Lc_NewHireCur_Last_NAME, 5));
         END;
	   
      
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
      SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');

      EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Lc_Process_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
       @Ac_Note_INDC                = @Lc_IndNote_TEXT,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

	  IF EXISTS (SELECT 1 FROM AHIS_Y1 a WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO 
				AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE 
				AND a.TypeAddress_CODE IN (@Lc_TypeAddressMailing_CODE,@Lc_TypeAddressResidence_CODE) 
				AND Status_CODE = @Lc_ConformedGoodStatus_CODE)
		BEGIN
		 SET @Lc_AhisMinorActivity_CODE = @Lc_MinorActivityRunca_CODE;
		 SET @Lc_Status_CODE = @Lc_PendingStatus_CODE ;
		
		END		
	  ELSE
		BEGIN
		 SET @Lc_AhisMinorActivity_CODE = @Lc_MinorActivityRcona_CODE;
		 SET @Lc_Status_CODE =  @Lc_ConformedGoodStatus_CODE;
		END	

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE - 1';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE,'')+ ', Begin_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', End_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR,'')+ ', Line1_ADDR = ' + ISNULL(@Ls_NewHireCur_Line1_ADDR,'')+ ', Line2_ADDR = ' + ISNULL(@Ls_NewHireCur_Line2_ADDR,'')+ ', City_ADDR = ' + ISNULL(@Lc_NewHireCur_City_ADDR,'')+ ', State_ADDR = ' + ISNULL(@Lc_NewHireCur_State_ADDR,'')+ ', Zip_ADDR = ' + ISNULL(@Lc_NewHireCur_Zip_ADDR,'')+ ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR,'')+ ', Phone_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE,'')+ ', SourceReceived_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Status_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_Status_CODE,'')+ ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedA_CODE,'')+ ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT,'')+ ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', OfficeSignedOn_IDNO = ' + ISNULL(CAST( @Ln_Office_IDNO AS VARCHAR ),'')+ ', Normalization_CODE = ' + ISNULL(@Lc_NewHireCur_Normalization_CODE,'');

	IF @Ls_NewHireCur_Line1_ADDR <> @Lc_Space_TEXT
	OR @Ls_NewHireCur_Line2_ADDR <> @Lc_Space_TEXT
	OR @Lc_NewHireCur_City_ADDR <> @Lc_Space_TEXT
	OR @Lc_NewHireCur_State_ADDR <> @Lc_Space_TEXT
	OR @Lc_NewHireCur_Zip_ADDR <> @Lc_Space_TEXT
	  BEGIN
      EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
       @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
       @Ad_Run_DATE                         = @Ld_Run_DATE,
       @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
       @Ad_Begin_DATE                       = @Ld_Run_DATE,
       @Ad_End_DATE                         = @Ld_High_DATE,
       @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
       @As_Line1_ADDR                       = @Ls_NewHireCur_Line1_ADDR,
       @As_Line2_ADDR                       = @Ls_NewHireCur_Line2_ADDR,
       @Ac_City_ADDR                        = @Lc_NewHireCur_City_ADDR,
       @Ac_State_ADDR                       = @Lc_NewHireCur_State_ADDR,
       @Ac_Zip_ADDR                         = @Lc_NewHireCur_Zip_ADDR,
       @Ac_Country_ADDR                     = @Lc_Country_ADDR,
       @An_Phone_NUMB                       = @Ln_Zero_NUMB,
       @Ac_SourceLoc_CODE                   = @Lc_SourceLocation_CODE,
       @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
       @Ad_Status_DATE                      = @Ld_Run_DATE,
       @Ac_Status_CODE                      = @Lc_Status_CODE,
       @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
       @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
       @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
       @Ac_Process_ID                       = @Lc_Process_ID,
       @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
       @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
       @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
       @Ac_Normalization_CODE               = @Lc_NewHireCur_Normalization_CODE,
       @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;
  	
  	  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		  RAISERROR (50001,16,1);
		END;
	  ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
       BEGIN
        SET @Lb_AhisCaseJournal_CODE = 1;        
       END;	
      ELSE  IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
		BEGIN
		   SET @Ls_BateRecord_TEXT = 'Error = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
		   SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_RestartLine_NUMB AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_Msg_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

		   EXECUTE BATCH_COMMON$SP_BATE_LOG
			@As_Process_NAME             = @Ls_Process_NAME,
			@As_Procedure_NAME           = @Ls_Procedure_NAME,
			@Ac_Job_ID                   = @Lc_Job_ID,
			@Ad_Run_DATE                 = @Ld_Run_DATE,
			@Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
			@An_Line_NUMB                = @Ln_RestartLine_NUMB,
			@Ac_Error_CODE               = @Lc_Msg_CODE,
			@As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
			@As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		   IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
			BEGIN
			 SET @Lb_ErrorExpection_CODE = 1;
			END
		   ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END
   		END
      END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
      SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Fein_IDNO = ' + ISNULL(CAST( @Ln_NewHireCurFein_IDNO AS VARCHAR ),'')+ ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpEmployer_CODE,'')+ ', OtherParty_NAME = ' + ISNULL(@Lc_NewHireCur_Employer_NAME,'')+ ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR,'')+ ', Line1_ADDR = ' + ISNULL(@Ls_NewHireCur_EmployerLine1_ADDR,'')+ ', Line2_ADDR = ' + ISNULL(@Ls_NewHireCur_EmployerLine2_ADDR,'')+ ', City_ADDR = ' + ISNULL(@Lc_NewHireCur_EmployerCity_ADDR,'')+ ', Zip_ADDR = ' + ISNULL(@Lc_NewHireCur_EmployerZip_ADDR,'')+ ', State_ADDR = ' + ISNULL(@Lc_NewHireCur_EmployerState_ADDR,'')+ ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE,'')+ ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR,'')+ ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_DescriptionContactOther_TEXT,'')+ ', Phone_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', Fax_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', Contact_EML = ' + ISNULL(@Ls_Contact_EML,'')+ ', ReferenceOthp_IDNO = ' + ISNULL(CAST( @Ln_ReferenceOthp_IDNO AS VARCHAR ),'')+ ', BarAtty_NUMB = ' + ISNULL(CAST( @Ln_BarAtty_NUMB AS VARCHAR ),'')+ ', Sein_IDNO = ' + ISNULL(CAST( @Ln_Sein_IDNO AS VARCHAR ),'')+ ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE,'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID,'')+ ', DchCarrier_IDNO = ' + ISNULL(CAST( @Ln_DchCarrier_IDNO AS VARCHAR ),'')+ ', Normalization_CODE = ' + ISNULL(@Lc_NewHireCur_NormalizedEmp_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'');

      EXECUTE BATCH_COMMON$SP_GET_OTHP 
       @Ad_Run_DATE                     = @Ld_Run_DATE,
       @An_Fein_IDNO                    = @Ln_NewHireCurFein_IDNO,
       @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_CODE  ,
       @As_OtherParty_NAME              = @Lc_NewHireCur_Employer_NAME, 
       @Ac_Aka_NAME                     = @Lc_Space_TEXT,
       @Ac_Attn_ADDR                    = @Lc_Attn_ADDR,
       @As_Line1_ADDR                   = @Ls_NewHireCur_EmployerLine1_ADDR,
       @As_Line2_ADDR                   = @Ls_NewHireCur_EmployerLine2_ADDR,
       @Ac_City_ADDR                    = @Lc_NewHireCur_EmployerCity_ADDR,
       @Ac_Zip_ADDR                     = @Lc_NewHireCur_EmployerZip_ADDR ,
       @Ac_State_ADDR                   = @Lc_NewHireCur_EmployerState_ADDR,
       @Ac_Fips_CODE                    = @Lc_Fips_CODE,
       @Ac_Country_ADDR                 = @Lc_Country_ADDR,
       @Ac_DescriptionContactOther_TEXT = @Lc_DescriptionContactOther_TEXT,
       @An_Phone_NUMB                   = @Ln_Zero_NUMB ,
       @An_Fax_NUMB                     = @Ln_Zero_NUMB,
       @As_Contact_EML                  = @Ls_Contact_EML,
       @An_ReferenceOthp_IDNO           = @Ln_ReferenceOthp_IDNO,
       @An_BarAtty_NUMB                 = @Ln_BarAtty_NUMB,
       @An_Sein_IDNO                    = @Ln_Sein_IDNO,
       @Ac_SourceLoc_CODE               = @Lc_SourceLocation_CODE,
       @Ac_WorkerUpdate_ID              = @Lc_WorkerUpdate_ID,
       @An_DchCarrier_IDNO              = @Ln_DchCarrier_IDNO,
       @Ac_Normalization_CODE           = @Lc_NewHireCur_NormalizedEmp_CODE,
       @Ac_Process_ID                   = @Lc_Process_ID,
       @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
       @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;
   		  
	  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		  RAISERROR (50001,16,1);
		END
   	  ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		BEGIN
		  SET @Ls_BateRecord_TEXT = 'Error = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
		  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
		  SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_RestartLine_NUMB AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_Msg_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
		  
		  EXECUTE BATCH_COMMON$SP_BATE_LOG @As_Process_NAME             = @Ls_Process_NAME,
										   @As_Procedure_NAME           = @Ls_Procedure_NAME,
										   @Ac_Job_ID                   = @Lc_Job_ID,
										   @Ad_Run_DATE                 = @Ld_Run_DATE,
										   @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
										   @An_Line_NUMB                = @Ln_RestartLine_NUMB,
										   @Ac_Error_CODE               = @Lc_Msg_CODE,
										   @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
										   @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
										   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
										   @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		   IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
			BEGIN
			 SET @Lb_ErrorExpection_CODE = 1;
			END
		   ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END
		  
		END	
	  ELSE IF @Lb_EhisHireDate_CODE = 1
		BEGIN
		  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
		  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST( @Ln_OtherParty_IDNO AS VARCHAR ),'')+ ', SourceReceived_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_ConformedGoodStatus_CODE,'')+ ', Status_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeEm_CODE,'')+ ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceLocConf_CODE,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', BeginEmployment_DATE = ' + ISNULL(CAST( @Ld_NewHireCurHire_DATE AS VARCHAR ),'')+ ', EndEmployment_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', IncomeGross_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', IncomeNet_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE,'')+ ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EligCoverage_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', CostInsurance_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', PlsLastSearch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', OfficeSignedOn_IDNO = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'');		  

		  EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE 
		   @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
		   @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
		   @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
		   @Ac_Status_CODE                = @Lc_ConformedGoodStatus_CODE ,
		   @Ad_Status_DATE                = @Ld_Run_DATE,
		   @Ac_TypeIncome_CODE            = @Lc_TypeIncomeEm_CODE,
		   @Ac_SourceLocConf_CODE         = @Lc_SourceLocConf_CODE,
		   @Ad_Run_DATE                   = @Ld_Run_DATE,
		   @Ad_BeginEmployment_DATE       = @Ld_NewHireCurHire_DATE,
		   @Ad_EndEmployment_DATE         = @Ld_High_DATE,
		   @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
		   @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
		   @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
		   @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
		   @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
		   @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
		   @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
		   @Ac_SourceLoc_CODE             = @Lc_SourceLocation_CODE,
		   @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
		   @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
		   @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
		   @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
		   @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
		   @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
		   @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
		   @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
		   @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
		   @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
		   @Ac_Process_ID                 = @Lc_Process_ID,
		   @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
		   @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
		   @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

		  IF @Lc_Msg_CODE=@Lc_StatusSuccess_CODE
			BEGIN
			  SET @Lb_EhisCaseJournal_CODE = 1;
			END
		  ELSE IF @Lc_Msg_CODE=@Lc_StatusFailed_CODE 
			BEGIN
			  RAISERROR (50001,16,1);
			END
		  ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		    BEGIN
			  SET @Ls_BateRecord_TEXT = 'Error = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
			  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 3 ';
			  SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_RestartLine_NUMB AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_Msg_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
			  
			  EXECUTE BATCH_COMMON$SP_BATE_LOG @As_Process_NAME             = @Ls_Process_NAME,
											   @As_Procedure_NAME           = @Ls_Procedure_NAME,
											   @Ac_Job_ID                   = @Lc_Job_ID,
											   @Ad_Run_DATE                 = @Ld_Run_DATE,
											   @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
											   @An_Line_NUMB                = @Ln_RestartLine_NUMB,
											   @Ac_Error_CODE               = @Lc_Msg_CODE,
											   @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
											   @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
											   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
											   @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		   IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
			BEGIN
			 SET @Lb_ErrorExpection_CODE = 1;
			END
		   ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END
			  	
		  END	  
		END
	  ELSE IF @Lb_EhisHireDate_CODE = 0
	    BEGIN
			SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
    
			RAISERROR (50001,16,1);
	    END 	
      IF @Lb_AhisCaseJournal_CODE = 1 OR @Lb_EhisCaseJournal_CODE = 1
       BEGIN
        DECLARE CaseMember_Cur INSENSITIVE CURSOR FOR
         SELECT a.Case_IDNO,
                a.MemberMci_IDNO
           FROM CMEM_Y1 a,
                CASE_Y1 b
          WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND a.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
			AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
            AND a.Case_IDNO = b.Case_IDNO
            AND b.StatusCase_CODE = @Lc_OpenStatusCase_CODE;

        SET @Ls_Sql_TEXT = 'OPEN CaseMember_Cur';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

        OPEN CaseMember_Cur;

        SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 1';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR);

        FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
		-- Case journal entry for each case.
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          IF @Lb_AhisCaseJournal_CODE = 1
            BEGIN
			  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 1 ';
			  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseMemberCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_AhisMinorActivity_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID,'')+ ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO,'')+ ', Reference_ID = ' + ISNULL(@Lc_Reference_ID,'')+ ', Notice_ID = ' + ISNULL(@Lc_Notice_ID,'')+ ', TopicIn_IDNO = ' + ISNULL(CAST( @Ln_TopicIn_IDNO AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT,'')+ ', MajorIntSeq_NUMB = ' + ISNULL(CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR ),'')+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', Schedule_NUMB = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', Schedule_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', BeginSch_DTTM = ' + ISNULL(CAST( @Ld_BeginSch_DTTM AS VARCHAR ),'')+ ', OthpLocation_IDNO = ' + ISNULL(CAST( @Ln_OthpLocation_IDNO AS VARCHAR ),'')+ ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO,'')+ ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO,'')+ ', OthpSource_IDNO = ' + ISNULL(CAST( @Ln_OthpSource_IDNO AS VARCHAR ),'')+ ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE,'')+ ', TransHeader_IDNO = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', BarcodeIn_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'');

			  EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
			    @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
				@An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
				@Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
				@Ac_ActivityMinor_CODE       = @Lc_AhisMinorActivity_CODE,
				@Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
				@As_DescriptionNote_TEXT     = @Lc_Space_TEXT,
				@Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
				@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				@Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
				@Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
				@Ac_SignedonWorker_ID        = @Lc_Space_TEXT,
				@Ad_Run_DATE                 = @Ld_Run_DATE,
				@Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
				@Ac_Reference_ID             = @Lc_Reference_ID,
				@Ac_Notice_ID                = @Lc_Notice_ID,
				@An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
				@Ac_Job_ID                   = @Lc_Job_ID,
				@As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
				@An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
				@An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
				@An_Schedule_NUMB            = @Ln_Schedule_NUMB,
				@Ad_Schedule_DATE            = @Ld_Low_DATE,
				@Ad_BeginSch_DTTM            = @Ld_BeginSch_DTTM,
				@An_OthpLocation_IDNO        = @Ln_OthpLocation_IDNO,
				@Ac_ScheduleWorker_ID        = @Lc_Schedule_Worker_IDNO,
				@As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
				@An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
				@Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
				@An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
				@An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
				@An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
				@An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

			  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
			    
				RAISERROR (50001,16,1);
			   END;
			END
	
          IF @Lb_EhisCaseJournal_CODE = 1
            BEGIN
         	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 2 ';
			  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseMemberCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityLocac_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID,'')+ ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO,'')+ ', Reference_ID = ' + ISNULL(@Lc_Reference_ID,'')+ ', Notice_ID = ' + ISNULL(@Lc_Notice_ID,'')+ ', TopicIn_IDNO = ' + ISNULL(CAST( @Ln_TopicIn_IDNO AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT,'')+ ', MajorIntSeq_NUMB = ' + ISNULL(CAST( @Ln_MajorIntSeq_NUMB AS VARCHAR ),'')+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @Ln_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', Schedule_NUMB = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', Schedule_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', BeginSch_DTTM = ' + ISNULL(CAST( @Ld_BeginSch_DTTM AS VARCHAR ),'')+ ', OthpLocation_IDNO = ' + ISNULL(CAST( @Ln_OthpLocation_IDNO AS VARCHAR ),'')+ ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO,'')+ ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO,'')+ ', OthpSource_IDNO = ' + ISNULL(CAST( @Ln_OthpSource_IDNO AS VARCHAR ),'')+ ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE,'')+ ', TransHeader_IDNO = ' + ISNULL(CAST( @Ln_Schedule_NUMB AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', BarcodeIn_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'');

			  EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
			   @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
			   @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
			   @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
			   @Ac_ActivityMinor_CODE       = @Lc_MinorActivityLocac_CODE ,
			   @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
			   @As_DescriptionNote_TEXT     = @Lc_Space_TEXT,
			   @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
			   @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
			   @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
			   @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
			   @Ac_SignedonWorker_ID        = @Lc_Space_TEXT,
			   @Ad_Run_DATE                 = @Ld_Run_DATE,
			   @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
			   @Ac_Reference_ID             = @Lc_Reference_ID,
			   @Ac_Notice_ID                = @Lc_Notice_ID,
			   @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
			   @Ac_Job_ID                   = @Lc_Job_ID,
			   @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
			   @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
			   @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
			   @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
			   @Ad_Schedule_DATE            = @Ld_Low_DATE,
			   @Ad_BeginSch_DTTM            = @Ld_BeginSch_DTTM,
			   @An_OthpLocation_IDNO        = @Ln_OthpLocation_IDNO,
			   @Ac_ScheduleWorker_ID        = @Lc_Schedule_Worker_IDNO,
			   @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
			   @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
			   @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
			   @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
			   @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
			   @An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
			   @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
			   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

			  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
			    
				RAISERROR (50001,16,1);
			   END;
			END			
			
          SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 2';
          SET @Ls_Sqldata_TEXT = 'Cursor CaseMember_Cur Previous Record Case_IDNO = ' + CAST (@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR);
          
          FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END;

        CLOSE CaseMember_Cur;

        DEALLOCATE CaseMember_Cur;
       
	 END

	  IF @Lb_ErrorExpection_CODE = 1
	   BEGIN
		SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
	   END
     END
    END TRY

    BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVENEWHIRE_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
        BEGIN
         CLOSE CaseMember_Cur;

         DEALLOCATE CaseMember_Cur;
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
	       
	   IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 4';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Member SSN = ' + RTRIM(@Lc_NewHireCur_MemberSsnNumb_TEXT );
       
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
		@As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
		@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
    END CATCH
    
     SET @Ls_Sql_TEXT = 'UPDATE LW4NH_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_NewHireCur_Seq_IDNO  AS VARCHAR);
     
     UPDATE LW4NH_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_NewHireCur_Seq_IDNO;
      
     SET @Li_RowsCount_QNTY = @@ROWCOUNT;
     
     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Error0002_TEXT;
	   	
       RAISERROR (50001,16,1);
      END
      
	 SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS NVARCHAR (MAX)), '') + ', RESTART KEY = ' + ISNULL (CAST (@Ln_RecordCount_QNTY AS NVARCHAR (MAX)), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       COMMIT TRANSACTION NEWHIRE_PROCESS;

	   SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
	   
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
       
       BEGIN TRANSACTION NEWHIRE_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
	   SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
       COMMIT TRANSACTION NEWHIRE_PROCESS;
       
       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
	   
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH NewHire_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT,1,970);

     FETCH NEXT FROM NewHire_CUR INTO @Ln_NewHireCur_Seq_IDNO, @Lc_NewHireCur_Rec_ID, @Lc_NewHireCur_Last_NAME, @Lc_NewHireCur_First_NAME,@Lc_NewHireCur_Middle_NAME, @Lc_NewHireCur_MemberSsnNumb_TEXT, @Lc_NewHireCur_HireDate_TEXT, @Lc_NewHireCur_LeftEmpTemp_INDC, @Lc_NewHireCur_BirthDate_TEXT, @Lc_NewHireCur_MemberSex_CODE, @Lc_NewHireCur_StateHire_CODE, @Lc_NewHireCur_Employer_NAME, @Lc_NewHireCur_FeinIdno_TEXT, @Lc_NewHireCur_FederalTaxType_CODE, @Lc_NewHireCur_FederalTaxVerification_CODE, @Lc_NewHireCur_BatchNumb_TEXT, @Lc_NewHireCur_EmployeeCountry_CODE, @Lc_NewHireCur_EmployeeCountry_NAME, @Lc_NewHireCur_EmployeeCountryZip_CODE, @Lc_NewHireCur_EmployerCountry_CODE, @Lc_NewHireCur_EmployerCountry_NAME, @Lc_NewHireCur_EmployerCountryZip_CODE, @Lc_NewHireCur_Normalization_CODE, @Ls_NewHireCur_Line1_ADDR, @Ls_NewHireCur_Line2_ADDR, @Lc_NewHireCur_City_ADDR, @Lc_NewHireCur_State_ADDR, @Lc_NewHireCur_Zip_ADDR, @Lc_NewHireCur_NormalizedEmp_CODE, @Ls_NewHireCur_EmployerLine1_ADDR, @Ls_NewHireCur_EmployerLine2_ADDR, @Lc_NewHireCur_EmployerCity_ADDR, @Lc_NewHireCur_EmployerState_ADDR, @Lc_NewHireCur_EmployerZip_ADDR;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_RestartLine_NUMB AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
     
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    
     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
	   BEGIN
		RAISERROR (50001,16,1);
	   END
   END
    
   CLOSE NewHire_CUR;
   DEALLOCATE NewHire_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job ID = ' +@Lc_Job_ID +  ', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE BATCH PARM DATE FAILED';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
     
     RAISERROR (50001,16,1);
    END
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 3';
   SET @Ls_Sqldata_TEXT = 'Job ID = ' +@Lc_Job_ID +  ', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR);
   
   COMMIT TRANSACTION NEWHIRE_PROCESS;

  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NEWHIRE_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'NewHire_CUR') IN (0, 1)
    BEGIN
     CLOSE NewHire_CUR;

     DEALLOCATE NewHire_CUR;
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
