/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_SVES_PRISONER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_SVES_PRISONER
Programmer Name		 : IMP Team
Description			 : The procedure reads the SVES (State Verification
                       Exchange System) Prisoner Data details from
                       LOAD_FCR_SVES_PRISONER table and updates DEMT_V1
                       (member detention) table.
Frequency			 : Daily
Developed On		 : 04/08/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
					   
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_SVES_PRISONER]
 @Ac_Job_ID                  CHAR(7),
 @Ad_Run_DATE                DATE,
 @As_Process_NAME            VARCHAR(100),
 @An_CommitFreq_QNTY         NUMERIC(5),
 @An_ExceptionThreshold_QNTY NUMERIC(5),
 @An_ProcessedRecordCount_QNTY NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE                CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE @Lc_StatusCaseMemberActive_CODE		CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE		CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE				CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE				CHAR(1) = 'E',
           @Lc_ProcessY_INDC					CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE				CHAR(1) = 'S',
           @Lc_TypeOthpJail_CODE				CHAR(1) = 'J',
           @Lc_TypeInst1_CODE					CHAR(1) = '1',
           @Lc_Note_INDC						CHAR(1) = 'N',
           @Lc_RelationshipCaseCp_TEXT			CHAR(1) = 'C',
           @Lc_RelationshipCaseNcp_TEXT			CHAR(1) = 'A',
           @Lc_RelationshipCasePf_TEXT			CHAR(1) = 'P',
           @Lc_StatusCaseO_CODE					CHAR(1) = 'O',
           @Lc_SubsystemLoc_CODE				CHAR(3) = 'LO',
           @Lc_MajorActivityCase_CODE			CHAR(4) = 'CASE',
           @Lc_MinorActivityRrfcr_CODE			CHAR(5) = 'RRFCR',
           @Lc_ErrorE0907_CODE					CHAR(5) = 'E0907',
           @Lc_ErrorE0145_CODE					CHAR(5) = 'E0145',
           @Lc_ErrorE0540_CODE					CHAR(5) = 'E0540',
           @Lc_ErrorE0152_CODE					CHAR(5) = 'E0152',
           @Lc_BateErrorE1424_CODE				CHAR(5) = 'E1424',
           @Lc_Job_ID							CHAR(7) = 'DEB0480',
           @Lc_DateFormatYyyymmdd_TEXT			CHAR(8) = 'YYYYMMDD',
           @Lc_BatchRunUser_TEXT				CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME					VARCHAR(60) = 'SP_SVES_PRISONER',
           @Ls_BateRecord_TEXT					VARCHAR(4000) = ' ',
           @Ld_High_DATE						DATE = '12/31/9999',
           @Ld_Low_DATE							DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB						NUMERIC(1) = 0,
           @Ln_Exists_NUMB						NUMERIC(2) = 0,
           @Ln_CommitFreq_QNTY					NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY			NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY		NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY	NUMERIC(6) = 0,
           @Ln_Institution_IDNO					NUMERIC(9) = 0,
           @Ln_OtherParty_IDNO					NUMERIC(9) = 0,
           @Ln_EventFunctionalSeq_NUMB			NUMERIC(10) = 0,
           @Ln_Topic_IDNO						NUMERIC(10) = 0,
           @Ln_Cur_QNTY							NUMERIC(10,0) = 0,
           @Ln_MemberMci_IDNO					NUMERIC(10) = 0,
           @Ln_Error_NUMB						NUMERIC(11),
           @Ln_ErrorLine_NUMB					NUMERIC(11),
           @Ln_Inmate_NUMB						NUMERIC(15) = 0,
           @Ln_TransactionEventSeq_NUMB			NUMERIC(19),
           @Li_RowCount_QNTY					SMALLINT,
           @Li_FetchStatus_QNTY					SMALLINT,
           @Lc_Space_TEXT						CHAR(1) = '',
           @Lc_TypeError_CODE					CHAR(1) = '',
           @Lc_TypeFacility_CODE				CHAR(2),
           @Lc_Msg_CODE							CHAR(5),
           @Lc_BateError_CODE					CHAR(5) = '',
           @Ls_Sql_TEXT							VARCHAR(100),
           @Ls_CursorLoc_TEXT					VARCHAR(200),
           @Ls_Sqldata_TEXT						VARCHAR(1000),
           @Ls_ErrorMessage_TEXT				VARCHAR(4000),
           @Ls_DescriptionError_TEXT			VARCHAR(4000),
           @Ls_ErrorDesc_TEXT					VARCHAR(4000),
           @Ld_ConfinedPr_DATE					DATE,
           @Ld_ReleasePr_DATE					DATE,
           @Ld_Release_DATE						DATE,
           @Ld_Confined_DATE					DATE,
           @Ld_Start_DATE						DATETIME2;

  DECLARE
  
  FcrSvesPr_CUR INSENSITIVE CURSOR FOR
   SELECT s.Seq_IDNO,
          s.Rec_ID,
          s.StateTerritory_CODE,
          s.LocSourceResp_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(s.PrisonUsedMemberSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE s.PrisonUsedMemberSsn_NUMB
          END AS PrisonUsedMemberSsn_NUMB,
          s.FirstPr_NAME,
          s.MiddlePr_NAME,
          LTRIM(RTRIM(s.LastPr_NAME)) AS LastPr_NAME,
          s.SuffixPr_NAME,
          s.SexPr_CODE,
          s.BirthPr_DATE,
          s.FirstSubmitted_NAME,
          s.MiddleSubmitted_NAME,
          s.LastSubmitted_NAME AS Last_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(s.SubmittedMemberSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE s.SubmittedMemberSsn_NUMB
          END AS SubmittedMemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(s.SubmittedMemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE s.SubmittedMemberMci_IDNO
          END AS SubmittedMemberMci_IDNO,
          s.UserField_NAME,
          s.LocClosed_INDC,
          s.CountyFips_CODE,
          s.MultiSsn_CODE,
          s.MultiSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(s.NumberPr_IDNO, '')))) = 0
            THEN '0'
           ELSE s.NumberPr_IDNO
          END AS NumberPr_IDNO,
          LTRIM(RTRIM(s.ConfinedPr_DATE)) AS ConfinedPr_DATE,
          LTRIM(RTRIM(s.ReleasePr_DATE)) AS ReleasePr_DATE,
          LTRIM(RTRIM(s.ReporterPr_NAME)) AS ReporterPr_NAME,
          LTRIM(RTRIM(s.ReportPr_DATE)) AS ReportPr_DATE,
          LTRIM(RTRIM(s.TypeFacility_CODE)) AS TypeFacility_CODE,
          LTRIM(RTRIM(s.Facility_NAME)) AS Facility_NAME,
          LTRIM(RTRIM(s.Line1_ADDR)) AS addr1_facility,
          LTRIM(RTRIM(s.Line2_ADDR)) AS addr2_facility,
          s.FacilityOld3_ADDR,
          s.FacilityOld4_ADDR,
          LTRIM(RTRIM(UPPER(s.City_ADDR))) AS addr_city_facility,
          LTRIM(RTRIM(s.State_ADDR)) AS addr_st_facility,
          LTRIM(RTRIM(s.Zip_ADDR)) AS addr_zip_facility,
          s.AddrScrub1_CODE,
          s.AddrScrub2_CODE,
          s.AddrAcrub3_CODE,
          LTRIM(RTRIM(s.ContactFacility_NAME)) AS ContactFacility_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(s.PhoneFacility_NUMB, '')))) = 0
            THEN '0'
           ELSE s.PhoneFacility_NUMB
          END ASPhoneFacility_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(s.FaxFacility_NUMB, '')))) = 0
            THEN '0'
           ELSE s.FaxFacility_NUMB
          END AS FaxFacility_NUMB,
          s.StateSort_CODE,
          s.Normalization_CODE
     FROM LFSPR_Y1  s
    WHERE s.Process_INDC = 'N';
    
  DECLARE @Ln_FcrSvesPrCur_Seq_IDNO                 NUMERIC(19),
          @Lc_FcrSvesPrCur_Rec_ID                   CHAR(2),
          @Lc_FcrSvesPrCur_StateTerritory_CODE      CHAR(2),
          @Lc_FcrSvesPrCur_LocSourceResp_CODE       CHAR(3),
          @Lc_FcrSvesPrCur_PrisonUsedMemberSsnNumb_TEXT CHAR(9),
          @Lc_FcrSvesPrCur_FirstPr_NAME             CHAR(15),
          @Lc_FcrSvesPrCur_MiPr_NAME                CHAR(15),
          @Lc_FcrSvesPrCur_LastPr_NAME              CHAR(20),
          @Lc_FcrSvesPrCur_SuffixPr_NAME            CHAR(4),
          @Lc_FcrSvesPrCur_SexPr_CODE               CHAR(1),
          @Lc_FcrSvesPrCur_BirthPr_DATE             CHAR(8),
          @Lc_FcrSvesPrCur_FirstSubmitted_NAME      CHAR(12),
          @Lc_FcrSvesPrCur_MiSubmitted_NAME         CHAR(1),
          @Lc_FcrSvesPrCur_Last_NAME                CHAR(19),
          @Lc_FcrSvesPrCur_MemberSsnNumb_TEXT       CHAR(9),
          @Lc_FcrSvesPrCur_MemberMciIdno_TEXT       CHAR(10),
          @Lc_FcrSvesPrCur_UserField_NAME           CHAR(15),
          @Lc_FcrSvesPrCur_LocClosed_INDC           CHAR(1),
          @Lc_FcrSvesPrCur_CountyFips_CODE          CHAR(3),
          @Lc_FcrSvesPrCur_MultiSsn_CODE            CHAR(1),
          @Lc_FcrSvesPrCur_MultiSsn_NUMB            CHAR(9),
          @Lc_FcrSvesPrCur_NumberPrIdno_TEXT        CHAR(10),
          @Lc_FcrSvesPrCur_ConfinedPr_DATE          CHAR(8),
          @Lc_FcrSvesPrCur_ReleasePr_DATE           CHAR(8),
          @Ls_FcrSvesPrCur_ReporterPr_NAME          VARCHAR(60),
          @Lc_FcrSvesPrCur_ReportPr_DATE            CHAR(8),
          @Lc_FcrSvesPrCur_TypeFacility_CODE        CHAR(2),
          @Ls_FcrSvesPrCur_Facility_NAME            VARCHAR(60),
          @Ls_FcrSvesPrCur_addr1Facility_TEXT       VARCHAR(50),
          @Ls_FcrSvesPrCur_addr2Facility_TEXT       VARCHAR(50),
          @Lc_FcrSvesPrCur_FacilityOld3_ADDR        CHAR(40),
          @Lc_FcrSvesPrCur_FacilityOld4_ADDR        CHAR(40),
          @Lc_FcrSvesPrCur_addr_cityFacility_TEXT   CHAR(28),
          @Lc_FcrSvesPrCur_addr_stFacility_TEXT     CHAR(2),
          @Lc_FcrSvesPrCur_addr_zipFacility_TEXT    CHAR(10),
          @Lc_FcrSvesPrCur_AddrScrub1_CODE          CHAR(2),
          @Lc_FcrSvesPrCur_AddrScrub2_CODE          CHAR(2),
          @Lc_FcrSvesPrCur_AddrAcrub3_CODE          CHAR(2),
          @Lc_FcrSvesPrCur_ContactFacility_NAME     CHAR(35),
          @Lc_FcrSvesPrCur_PhoneFacilityNumb_TEXT   CHAR(10),
          @Lc_FcrSvesPrCur_FaxFacilityNumb_TEXT     CHAR(10),
          @Lc_FcrSvesPrCur_StateSort_CODE           CHAR(2),
          @Lc_FcrSvesPrCur_Normalization_CODE       CHAR(1),
          
          @Ln_FcrSvesPrCur_PrisonUsedMemberSsn_NUMB NUMERIC(9),
          @Ln_FcrSvesPrCur_MemberSsn_NUMB			NUMERIC(9),
          @Ln_FcrSvesPrCur_MemberMci_IDNO			NUMERIC(10),
          @Ln_FcrSvesPrCur_NumberPr_IDNO			NUMERIC(10);
  
  -- Cursor variables
  DECLARE @Ln_OpenCasesCur_Case_IDNO     NUMERIC(6);
          
  BEGIN TRY
   BEGIN TRANSACTION SVES_PRISONER;

   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL(@An_ExceptionThreshold_QNTY, 0);
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL(@An_CommitFreq_QNTY, 0);
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_ErrorDesc_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = 0;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  
   SET @Ls_Sql_TEXT = 'SVES PRISONER  OPEN CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   OPEN FcrSvesPr_CUR;

   SET @Ls_Sql_TEXT = 'SVES PRISONER  FETCH CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Ac_Job_ID;

   FETCH NEXT FROM FcrSvesPr_CUR INTO @Ln_FcrSvesPrCur_Seq_IDNO, @Lc_FcrSvesPrCur_Rec_ID, @Lc_FcrSvesPrCur_StateTerritory_CODE, @Lc_FcrSvesPrCur_LocSourceResp_CODE, @Lc_FcrSvesPrCur_PrisonUsedMemberSsnNumb_TEXT, @Lc_FcrSvesPrCur_FirstPr_NAME, @Lc_FcrSvesPrCur_MiPr_NAME, @Lc_FcrSvesPrCur_LastPr_NAME, @Lc_FcrSvesPrCur_SuffixPr_NAME, @Lc_FcrSvesPrCur_SexPr_CODE, @Lc_FcrSvesPrCur_BirthPr_DATE, @Lc_FcrSvesPrCur_FirstSubmitted_NAME, @Lc_FcrSvesPrCur_MiSubmitted_NAME, @Lc_FcrSvesPrCur_Last_NAME, @Lc_FcrSvesPrCur_MemberSsnNumb_TEXT, @Lc_FcrSvesPrCur_MemberMciIdno_TEXT, @Lc_FcrSvesPrCur_UserField_NAME, @Lc_FcrSvesPrCur_LocClosed_INDC, @Lc_FcrSvesPrCur_CountyFips_CODE, @Lc_FcrSvesPrCur_MultiSsn_CODE, @Lc_FcrSvesPrCur_MultiSsn_NUMB, @Lc_FcrSvesPrCur_NumberPrIdno_TEXT, @Lc_FcrSvesPrCur_ConfinedPr_DATE, @Lc_FcrSvesPrCur_ReleasePr_DATE, @Ls_FcrSvesPrCur_ReporterPr_NAME, @Lc_FcrSvesPrCur_ReportPr_DATE, @Lc_FcrSvesPrCur_TypeFacility_CODE, @Ls_FcrSvesPrCur_Facility_NAME, @Ls_FcrSvesPrCur_addr1Facility_TEXT, @Ls_FcrSvesPrCur_addr2Facility_TEXT, @Lc_FcrSvesPrCur_FacilityOld3_ADDR, @Lc_FcrSvesPrCur_FacilityOld4_ADDR, @Lc_FcrSvesPrCur_addr_cityFacility_TEXT, @Lc_FcrSvesPrCur_addr_stFacility_TEXT, @Lc_FcrSvesPrCur_addr_zipFacility_TEXT, @Lc_FcrSvesPrCur_AddrScrub1_CODE, @Lc_FcrSvesPrCur_AddrScrub2_CODE, @Lc_FcrSvesPrCur_AddrAcrub3_CODE, @Lc_FcrSvesPrCur_ContactFacility_NAME, @Lc_FcrSvesPrCur_PhoneFacilityNumb_TEXT, @Lc_FcrSvesPrCur_FaxFacilityNumb_TEXT, @Lc_FcrSvesPrCur_StateSort_CODE, @Lc_FcrSvesPrCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process SVES prisoner records
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVESVES_PRISONER;
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Lc_TypeError_CODE = '';
     SET @Ln_Exists_NUMB = 0;
     
     IF ISNUMERIC (@Lc_FcrSvesPrCur_PrisonUsedMemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrSvesPrCur_PrisonUsedMemberSsn_NUMB = @Lc_FcrSvesPrCur_PrisonUsedMemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrSvesPrCur_PrisonUsedMemberSsn_NUMB = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrSvesPrCur_MemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrSvesPrCur_MemberSsn_NUMB = @Lc_FcrSvesPrCur_MemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrSvesPrCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrSvesPrCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrSvesPrCur_MemberMci_IDNO = @Lc_FcrSvesPrCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrSvesPrCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrSvesPrCur_NumberPrIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrSvesPrCur_NumberPr_IDNO = @Lc_FcrSvesPrCur_NumberPrIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrSvesPrCur_NumberPr_IDNO = @Ln_Zero_NUMB;
		END
		
     SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrSvesPrCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), 0);
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcrSvesPrCur_Rec_ID, '') + ', StateTerritory_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_StateTerritory_CODE, '') + ', LocSourceResp_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_LocSourceResp_CODE, '') + ', PrisonUsedMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_PrisonUsedMemberSsn_NUMB AS VARCHAR (9)), 0) + ', FirstPr_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_FirstPr_NAME, '') + ', MiPr_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_MiPr_NAME, '') + ', LastPr_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_LastPr_NAME, '') + ', SuffixPr_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_SuffixPr_NAME, '') + ', SexPr_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_SexPr_CODE, '') + ', BirthPr_DATE = ' + ISNULL(@Lc_FcrSvesPrCur_BirthPr_DATE, '') + ', FirstSubmitted_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_FirstSubmitted_NAME, '') + ', MiSubmitted_NAME = ' + ISNULL (@Lc_FcrSvesPrCur_MiSubmitted_NAME, '') + ', LastSubmitted_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_Last_NAME, '') + ', SubmittedMemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', SubmittedMemberMci_IDNO = ' + ISNULL (CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', UserField_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_UserField_NAME, '') + ', LocClosed_INDC = ' + ISNULL(@Lc_FcrSvesPrCur_LocClosed_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_CountyFips_CODE, '') + ', MultiSsn_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_MultiSsn_CODE, '') + ', MultiSsn_NUMB = ' + ISNULL (@Lc_FcrSvesPrCur_MultiSsn_NUMB, '') + ', NumberPr_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_NumberPr_IDNO AS VARCHAR(10)), 0) + ', ConfinedPr_DATE = ' + ISNULL(@Lc_FcrSvesPrCur_ConfinedPr_DATE, '') + ', ReleasePr_DATE = ' + ISNULL(@Lc_FcrSvesPrCur_ReleasePr_DATE, '') + ', ReporterPr_NAME = ' + ISNULL(@Ls_FcrSvesPrCur_ReporterPr_NAME, '') + ', ReportPr_DATE = ' + ISNULL (@Lc_FcrSvesPrCur_ReportPr_DATE, '') + ', TypeFacility_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_TypeFacility_CODE, '') + ', Facility_NAME = ' + ISNULL(@Ls_FcrSvesPrCur_Facility_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrSvesPrCur_addr1Facility_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FcrSvesPrCur_addr2Facility_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrSvesPrCur_addr_cityFacility_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrSvesPrCur_addr_stFacility_TEXT, '') + ', Zip_ADDR = ' + ISNULL (@Lc_FcrSvesPrCur_addr_zipFacility_TEXT, '') + ', AddrScrub1_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_AddrScrub1_CODE, '') + ', AddrScrub2_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_AddrScrub2_CODE, '') + ', AddrAcrub3_CODE = ' + ISNULL (@Lc_FcrSvesPrCur_AddrAcrub3_CODE, '') + ', ContactFacility_NAME = ' + ISNULL (@Lc_FcrSvesPrCur_ContactFacility_NAME, '') + ', PhoneFacility_NUMB = ' + ISNULL(@Lc_FcrSvesPrCur_PhoneFacilityNumb_TEXT, 0) + ', FaxFacility_NUMB = ' + ISNULL(@Lc_FcrSvesPrCur_FaxFacilityNumb_TEXT, 0) + ', StateSort_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_StateSort_CODE, '') + ', Normalization_CODE = ' + ISNULL(@Lc_FcrSvesPrCur_Normalization_CODE, '');
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', CaseMemberStatus_CODE = ' + @Lc_StatusCaseMemberActive_CODE;
          
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrSvesPrCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MemberMci_IDNO DEMO_Y1,MSSN_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_Last_NAME, '');
       
       SELECT @Li_RowCount_QNTY = COUNT(DISTINCT m.MemberMci_IDNO)
         FROM DEMO_Y1 d,
              MSSN_Y1 m
        WHERE m.MemberSsn_NUMB = @Ln_FcrSvesPrCur_MemberSsn_NUMB
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE
          AND d.MemberMci_IDNO = m.MemberMci_IDNO
          AND UPPER (SUBSTRING(d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrSvesPrCur_Last_NAME, 1, 5);

       IF @Li_RowCount_QNTY = 0
        BEGIN
         -- Member not found 
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0907_CODE;

         GOTO lx_exception;
        END
       ELSE IF @Li_RowCount_QNTY > 1
        BEGIN
         -- Duplicate record exists 
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

         GOTO lx_exception;
        END
       ELSE
        BEGIN
         -- Gte member MCI number 
         SET @Ls_Sql_TEXT = 'SELECT MemberMci_IDNO DEMO_Y1,MSSN_Y1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_Last_NAME, '');
         SELECT DISTINCT
                @Ln_MemberMci_IDNO = m.MemberMci_IDNO
           FROM DEMO_Y1 d,
                MSSN_Y1 m
          WHERE m.MemberSsn_NUMB = @Ln_FcrSvesPrCur_MemberSsn_NUMB
            AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
            AND m.EndValidity_DATE = @Ld_High_DATE
            AND d.MemberMci_IDNO = m.MemberMci_IDNO
            AND UPPER (SUBSTRING(d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrSvesPrCur_Last_NAME, 1, 5);
        END
      END
     ELSE
      BEGIN
      
       SET @Ln_MemberMci_IDNO = @Ln_FcrSvesPrCur_MemberMci_IDNO;
      END

     SET @Ls_Sql_TEXT = 'GET OTHER PARTY Seq_IDNO';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeOthp_CODE = J -JAIL' + ', Facility_NAME = ' + ISNULL(@Ls_FcrSvesPrCur_Facility_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrSvesPrCur_addr1Facility_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrSvesPrCur_addr_cityFacility_TEXT, '') + ', State_ADDR  ' + ISNULL(@Lc_FcrSvesPrCur_addr_stFacility_TEXT, '') + ', Zip_ADDR = ' + ISNULL (@Lc_FcrSvesPrCur_addr_zipFacility_TEXT, '');
     
     SELECT @Li_RowCount_QNTY = COUNT(o.OtherParty_IDNO)
       FROM OTHP_Y1 o
      WHERE o.TypeOthp_CODE = @Lc_TypeOthpJail_CODE
        AND SUBSTRING(o.OtherParty_NAME, 1, 1) = SUBSTRING(@Ls_FcrSvesPrCur_Facility_NAME, 1, 1)
        AND o.Line1_ADDR = @Ls_FcrSvesPrCur_addr1Facility_TEXT
        AND o.Line2_ADDR = @Ls_FcrSvesPrCur_addr2Facility_TEXT
        AND o.City_ADDR = @Lc_FcrSvesPrCur_addr_cityFacility_TEXT
        AND o.State_ADDR = @Lc_FcrSvesPrCur_addr_stFacility_TEXT
        AND SUBSTRING(o.Zip_ADDR, 1, 5) = SUBSTRING(@Lc_FcrSvesPrCur_addr_zipFacility_TEXT, 1, 5)
        AND o.EndValidity_DATE = @Ld_High_DATE;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       -- Member not found 
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0540_CODE;

       GOTO lx_exception;
      END
     ELSE IF @Li_RowCount_QNTY > 1
      BEGIN
       -- Duplicate record exists 
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

       GOTO lx_exception;
      END
     ELSE
      BEGIN
       -- Gte member MCI number 
       SET @Ls_Sql_TEXT = 'SELECT MemberMci_IDNO DEMO_Y1,MSSN_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrSvesPrCur_Last_NAME, '');
       SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
         FROM OTHP_Y1 o
        WHERE o.TypeOthp_CODE = @Lc_TypeOthpJail_CODE
          AND SUBSTRING(o.OtherParty_NAME, 1, 1) = SUBSTRING(@Ls_FcrSvesPrCur_Facility_NAME, 1, 1)
          AND o.City_ADDR = @Lc_FcrSvesPrCur_addr_cityFacility_TEXT
          AND o.State_ADDR = @Lc_FcrSvesPrCur_addr_stFacility_TEXT
          AND SUBSTRING(o.Zip_ADDR, 1, 5) = SUBSTRING(@Lc_FcrSvesPrCur_addr_zipFacility_TEXT, 1, 5)
          AND o.EndValidity_DATE = @Ld_High_DATE;
      END
        
     SET @Ld_ConfinedPr_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_FcrSvesPrCur_ConfinedPr_DATE, 112), 1 , 8);

     IF (ISNULL (@Ld_ConfinedPr_DATE, '')) = ' '
      BEGIN
       SET @Ld_ConfinedPr_DATE = @Ad_Run_DATE;
      END
   
     SET @Ld_ReleasePr_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_FcrSvesPrCur_ReleasePr_DATE, 112), 1 , 8) ;

     IF (ISNULL(@Ld_ReleasePr_DATE, ' ')) = ' ' 
      BEGIN
       SET @Ld_ReleasePr_DATE = @Ld_High_DATE;
      END
     
     SET @Lc_TypeFacility_CODE = @Lc_FcrSvesPrCur_TypeFacility_CODE;
     SET @Ln_Exists_NUMB = 0;

     SET @Ls_Sql_TEXT = 'CHECK FOR MemberMci_IDNO IN MDET_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM MDET_Y1 m
      WHERE m.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND m.EndValidity_DATE = @Ld_High_DATE;
    
     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = @Lc_Note_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

         GOTO lx_exception;
        END
       
	   SET @Ls_Sql_TEXT = 'INSERT INTO VMDET1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Institution_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);
       
       INSERT MDET_Y1
              (MemberMci_IDNO,
               Institution_IDNO,
               Institution_NAME,
               TypeInst_CODE,
               PoliceDept_IDNO,
               Institutionalized_DATE,
               Incarceration_DATE,
               Release_DATE,
               EligParole_DATE,
               MoveType_CODE,
               Inmate_NUMB,
               ParoleReason_CODE,
               InstSbin_IDNO,
               InstFbin_IDNO,
               ParoleOfficer_NAME,
               PhoneParoleOffice_NUMB,
               DescriptionHold_TEXT,
               Sentence_CODE,
               WorkerUpdate_ID,
               TransactionEventSeq_NUMB,
               Update_DTTM,
               BeginValidity_DATE,
               EndValidity_DATE,
               ProbationOfficer_NAME,
               MaxRelease_DATE,--
               OthpPartyProbation_IDNO,
               WorkRelease_INDC,
               InstitutionStatus_CODE,
               ReleaseReason_CODE)
       VALUES ( @Ln_MemberMci_IDNO, -- MemberMci_IDNO
                @Ln_OtherParty_IDNO, -- Institution_IDNO
                SUBSTRING(ISNULL(@Ls_FcrSvesPrCur_Facility_NAME, @Lc_Space_TEXT), 1, 30), -- Institution_NAME
                ISNULL(@Lc_TypeFacility_CODE, @Lc_TypeInst1_CODE), -- TypeInst_CODE
                @Ln_Zero_NUMB,--PoliceDept_IDNO 
                @Ld_Low_DATE, -- Institutionalized_DATE
                ISNULL(@Ld_ConfinedPr_DATE, @Ad_Run_DATE), -- Incarceration_DATE
                ISNULL(@Ld_ReleasePr_DATE, @Ld_High_DATE), -- Release_DATE
                @Ld_High_DATE, -- EligParole_DATE
                @Lc_Space_TEXT, -- MoveType_CODE
                ISNULL(@Ln_FcrSvesPrCur_NumberPr_IDNO, @Ln_Zero_NUMB),--Inmate_NUMB
                @Lc_Space_TEXT, -- ParoleReason_CODE
                @Ln_Zero_NUMB, -- InstSbin_IDNO 
                @Ln_Zero_NUMB, -- InstFbin_IDNO 
                @Lc_Space_TEXT, -- ParoleOfficer_NAME
                @Ln_Zero_NUMB,--PhoneParoleOffice_NUMB 
                @Lc_Space_TEXT, -- DescriptionHold_TEXT
                @Lc_Space_TEXT, -- Sentence_CODE
                @Lc_BatchRunUser_TEXT, -- WorkerUpdate_ID
                @Ln_TransactionEventSeq_NUMB, --TransactionEventSeq_NUMB
                @Ld_Start_DATE, -- Update_DTTM
                @Ad_Run_DATE, -- BeginValidity_DATE
                @Ld_High_DATE, -- EndValidity_DATE
                @Lc_Space_TEXT, -- -- ProbationOfficer_NAME
                @Ld_High_DATE, --MaxRelease_DATE
                @Ln_Zero_NUMB, --OthpPartyProbation_IDNO
                @Lc_Space_TEXT, -- WorkRelease_INDC
                @Lc_Space_TEXT, -- InstitutionStatus_CODE
                @Lc_Space_TEXT); -- ReleaseReason_CODE

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT FAILED VMDET1';

         RAISERROR(50001,16,1);
        END
       -- 10827 Create Case journal entry RRFCR for all the cases where member is active cp or pf or ncp 
       DECLARE OpenCases_CUR INSENSITIVE CURSOR FOR
         SELECT a.Case_idno
           FROM CMEM_Y1 a,
                CASE_Y1 b
          WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
            AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePf_TEXT,@Lc_RelationshipCaseCp_TEXT)
            AND a.Case_IDNO = b.Case_IDNO
            AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE;
            
       OPEN OpenCases_CUR;
       FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO;
       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       -- Create RRFCR Case Journal entry 
	   WHILE @Li_FetchStatus_QNTY = 0
		BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 1';
		 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL (CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR), '') + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityRrfcr_CODE, '');
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityRrfcr_CODE,
            @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            @Ac_WorkerUpdate_ID		     = @Lc_BatchRunUser_TEXT,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_Job_ID                   = @Ac_Job_ID,
            @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		    BEGIN
			 SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			 SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			 RAISERROR (50001,16,1);
		    END
         ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
               BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
               END
         FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO;
         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END
       
       CLOSE OpenCases_CUR;
       DEALLOCATE OpenCases_CUR;
       -- 10827 
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MDET_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Institution_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(10)), 0) + ', Inmate_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_NumberPr_IDNO AS VARCHAR(10)), 0);

       -- check for id_member in MDET_Y1
       -- Get id_member details from MDET_Y1
       SELECT TOP 1 @Ln_Institution_IDNO = Institution_IDNO,
                    @Ln_Inmate_NUMB = Inmate_NUMB,
                    @Ld_Release_DATE = CASE
                                        WHEN Release_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
                                         THEN Release_DATE
                                        ELSE ISNULL(Release_DATE, @Ld_High_DATE)
                                       END,
                    @Ld_Confined_DATE = Incarceration_DATE
         FROM MDET_Y1 m
        WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
     
       IF (@Ln_Institution_IDNO = @Ln_OtherParty_IDNO
           AND @Ln_Inmate_NUMB = @Ln_FcrSvesPrCur_NumberPr_IDNO
           AND @Ld_ReleasePr_DATE <> @Ld_High_DATE
           AND @Ld_Release_DATE <> @Ld_ReleasePr_DATE)
           OR (@Ln_Institution_IDNO <> @Ln_OtherParty_IDNO
               AND @Ld_Release_DATE < @Ad_Run_DATE
               AND @Ld_Confined_DATE <> @Ld_ConfinedPr_DATE
               AND @Ld_Release_DATE <> @Ld_ReleasePr_DATE)
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE MDET_Y1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Institution_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);

         UPDATE MDET_Y1
            SET EndValidity_DATE = @Ad_Run_DATE
          WHERE MDET_Y1.MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND MDET_Y1.EndValidity_DATE = @Ld_High_DATE;

         SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 2';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

         EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
          @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
          @Ac_Process_ID               = @Lc_Job_ID,
          @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
          @Ac_Note_INDC                = @Lc_Note_INDC,
          @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
          
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

           GOTO lx_exception;
          END

         SET @Ls_Sql_TEXT = 'INSERT INTO VMDET2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Institution_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);
         
         INSERT MDET_Y1
                (MemberMci_IDNO,
                 Institution_IDNO,
                 Institution_NAME,
                 TypeInst_CODE,
                 PoliceDept_IDNO,
                 Institutionalized_DATE,
                 Incarceration_DATE,
                 Release_DATE,
                 EligParole_DATE,
                 MoveType_CODE,
                 Inmate_NUMB,
                 ParoleReason_CODE,
                 InstSbin_IDNO,
                 InstFbin_IDNO,
                 ParoleOfficer_NAME,
                 PhoneParoleOffice_NUMB,
                 DescriptionHold_TEXT,
                 Sentence_CODE,
                 WorkerUpdate_ID,
                 TransactionEventSeq_NUMB,
                 Update_DTTM,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 ProbationOfficer_NAME,
                 MaxRelease_DATE,--
                 OthpPartyProbation_IDNO,
                 WorkRelease_INDC,
                 InstitutionStatus_CODE,
                 ReleaseReason_CODE)
         VALUES ( @Ln_MemberMci_IDNO, -- MemberMci_IDNO
                  @Ln_OtherParty_IDNO, -- Institution_IDNO
                  SUBSTRING(ISNULL(@Ls_FcrSvesPrCur_Facility_NAME, @Lc_Space_TEXT), 1, 30), -- Institution_NAME
                  ISNULL(@Lc_TypeFacility_CODE, @Lc_TypeInst1_CODE), -- TypeInst_CODE
                  @Ln_Zero_NUMB, --PoliceDept_IDNO 
                  @Ld_Low_DATE, -- Institutionalized_DATE
                  ISNULL(@Ld_ConfinedPr_DATE, @Ad_Run_DATE), -- Incarceration_DATE
                  ISNULL(@Ld_ReleasePr_DATE, @Ld_High_DATE), -- Release_DATE
                  @Ld_High_DATE, -- EligParole_DATE
                  @Lc_Space_TEXT, -- MoveType_CODE
                  ISNULL(@Ln_FcrSvesPrCur_NumberPr_IDNO, @Ln_Zero_NUMB),--Inmate_NUMB
                  @Lc_Space_TEXT, -- ParoleReason_CODE
                  @Ln_Zero_NUMB,--InstSbin_IDNO 
                  @Ln_Zero_NUMB,--InstFbin_IDNO 
                  @Lc_Space_TEXT, -- ParoleOfficer_NAME
                  @Ln_Zero_NUMB,--PhoneParoleOffice_NUMB
                  @Lc_Space_TEXT, -- DescriptionHold_TEXT
                  @Lc_Space_TEXT, -- Sentence_CODE
                  @Lc_BatchRunUser_TEXT, -- WorkerUpdate_ID
                  @Ln_TransactionEventSeq_NUMB, -- TransactionEventSeq_NUMB
                  @Ld_Start_DATE, -- Update_DTTM
                  @Ad_Run_DATE,	-- BeginValidity_DATE
                  @Ld_High_DATE, -- EndValidity_DATE
                  @Lc_Space_TEXT, -- ProbationOfficer_NAME
                  @Ld_High_DATE,--MaxRelease_DATE
                  @Ln_Zero_NUMB,--OthpPartyProbation_IDNO
                  @Lc_Space_TEXT, -- WorkRelease_INDC
                  @Lc_Space_TEXT, -- InstitutionStatus_CODE
                  @Lc_Space_TEXT); -- ReleaseReason_CODE
         
         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'INSERT FAILED VMDET2';

           RAISERROR(50001,16,1);
          END
         -- 10827 Create Case journal entry RRFCR for all the cases where member is active cp or pf or ncp 
         DECLARE OpenCases_CUR INSENSITIVE CURSOR FOR
         SELECT a.Case_idno
           FROM CMEM_Y1 a,
                CASE_Y1 b
          WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
            AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePf_TEXT,@Lc_RelationshipCaseCp_TEXT)
            AND a.Case_IDNO = b.Case_IDNO
            AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE;
            
         OPEN OpenCases_CUR;
         FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO;
         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       -- Create RRFCR Case Journal entry 
	     WHILE @Li_FetchStatus_QNTY = 0
		  BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 1';
		   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL (CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR), '') + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityRrfcr_CODE, '');
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityRrfcr_CODE,
            @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            @Ac_WorkerUpdate_ID		     = @Lc_BatchRunUser_TEXT,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_Job_ID                   = @Ac_Job_ID,
            @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		    BEGIN
			 SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			 SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			 RAISERROR (50001,16,1);
		    END
           ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
               BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
               END
           FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO;
           SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
          END
         
         CLOSE OpenCases_CUR;
         DEALLOCATE OpenCases_CUR;
         -- 10827 
        END
       ELSE
        ---- Record already exists
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0152_CODE;

         GOTO lx_exception;
        END
      END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
              
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-9';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @As_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO BATE-9 FAILED FOR ';

         RAISERROR(50001,16,1);
        END
       
       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END 
      END
    END TRY
    
    BEGIN CATCH
      BEGIN 
		SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
		-- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	     BEGIN
	   	   ROLLBACK TRANSACTION SAVESVES_PRISONER;
		 END
		ELSE
		 BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + '' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		 END 
		      
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
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
                
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesPrCur_MemberMci_IDNO AS VARCHAR), 0) ;

        SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @As_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Ac_Job_ID,
         @Ad_Run_DATE                 = @Ad_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
         @An_Line_NUMB                = @Ln_Cur_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
         @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
       
      END
	END CATCH
	
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1 ;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATE LFSPR_Y1';
     SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID;

     UPDATE LFSPR_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrSvesPrCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFSPR_Y1';

       RAISERROR(50001,16,1);
      END
     
     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT :' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID;

     IF @An_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @An_CommitFreq_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Ac_Job_ID,
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cur_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         
         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION SVES_PRISONER; 
       BEGIN TRANSACTION SVES_PRISONER; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY >= @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION SVES_PRISONER;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrSvesPr_CUR INTO @Ln_FcrSvesPrCur_Seq_IDNO, @Lc_FcrSvesPrCur_Rec_ID, @Lc_FcrSvesPrCur_StateTerritory_CODE, @Lc_FcrSvesPrCur_LocSourceResp_CODE, @Lc_FcrSvesPrCur_PrisonUsedMemberSsnNumb_TEXT, @Lc_FcrSvesPrCur_FirstPr_NAME, @Lc_FcrSvesPrCur_MiPr_NAME, @Lc_FcrSvesPrCur_LastPr_NAME, @Lc_FcrSvesPrCur_SuffixPr_NAME, @Lc_FcrSvesPrCur_SexPr_CODE, @Lc_FcrSvesPrCur_BirthPr_DATE, @Lc_FcrSvesPrCur_FirstSubmitted_NAME, @Lc_FcrSvesPrCur_MiSubmitted_NAME, @Lc_FcrSvesPrCur_Last_NAME, @Lc_FcrSvesPrCur_MemberSsnNumb_TEXT, @Lc_FcrSvesPrCur_MemberMciIdno_TEXT, @Lc_FcrSvesPrCur_UserField_NAME, @Lc_FcrSvesPrCur_LocClosed_INDC, @Lc_FcrSvesPrCur_CountyFips_CODE, @Lc_FcrSvesPrCur_MultiSsn_CODE, @Lc_FcrSvesPrCur_MultiSsn_NUMB, @Lc_FcrSvesPrCur_NumberPrIdno_TEXT, @Lc_FcrSvesPrCur_ConfinedPr_DATE, @Lc_FcrSvesPrCur_ReleasePr_DATE, @Ls_FcrSvesPrCur_ReporterPr_NAME, @Lc_FcrSvesPrCur_ReportPr_DATE, @Lc_FcrSvesPrCur_TypeFacility_CODE, @Ls_FcrSvesPrCur_Facility_NAME, @Ls_FcrSvesPrCur_addr1Facility_TEXT, @Ls_FcrSvesPrCur_addr2Facility_TEXT, @Lc_FcrSvesPrCur_FacilityOld3_ADDR, @Lc_FcrSvesPrCur_FacilityOld4_ADDR, @Lc_FcrSvesPrCur_addr_cityFacility_TEXT, @Lc_FcrSvesPrCur_addr_stFacility_TEXT, @Lc_FcrSvesPrCur_addr_zipFacility_TEXT, @Lc_FcrSvesPrCur_AddrScrub1_CODE, @Lc_FcrSvesPrCur_AddrScrub2_CODE, @Lc_FcrSvesPrCur_AddrAcrub3_CODE, @Lc_FcrSvesPrCur_ContactFacility_NAME, @Lc_FcrSvesPrCur_PhoneFacilityNumb_TEXT, @Lc_FcrSvesPrCur_FaxFacilityNumb_TEXT, @Lc_FcrSvesPrCur_StateSort_CODE, @Lc_FcrSvesPrCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrSvesPr_CUR;

   DEALLOCATE FcrSvesPr_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   -- Transaction ends 
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
   
   COMMIT TRANSACTION SVES_PRISONER;
  END TRY

  BEGIN CATCH
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
  
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrSvesPr_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrSvesPr_CUR;

     DEALLOCATE FcrSvesPr_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION SVES_PRISONER;
    END

   --Set Error Description
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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   
  END CATCH
 END


GO
