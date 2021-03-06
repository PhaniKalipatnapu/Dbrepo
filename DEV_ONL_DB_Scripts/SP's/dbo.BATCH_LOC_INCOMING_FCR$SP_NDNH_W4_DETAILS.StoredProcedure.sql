/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_NDNH_W4_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_NDNH_W4_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the W4 details from the
                       temporary table LOAD_FCR_NDNH_QW_DETAILS and update
                       the member's address in AHIS_Y1.
                       In addition, the member's employment information in
                       EHIS_Y1 will also be updated.
Frequency			 : Daily
Developed On		 : 04/10/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_GET_OTHP
					   BATCH_COMMON$SP_EMPLOYER_UPDATE
					   BATCH_COMMON$SP_ADDRESS_UPDATE
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_NDNH_W4_DETAILS]
 @Ac_Job_ID                  CHAR(7),
 @Ad_Run_DATE                DATE,
 @As_Process_NAME            VARCHAR(100),
 @An_CommitFreq_QNTY         NUMERIC(5),
 @An_ExceptionThreshold_QNTY NUMERIC(5),
 @An_ProcessedRecordCount_QNTY NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE     CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_TypeAddressM_CODE               CHAR(1) = 'M',
           @Lc_VerificationStatusPending_CODE  CHAR(1) = 'P',
           @Lc_RelationshipCaseNcp_TEXT		   CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_TEXT  CHAR(1) = 'P',
           @Lc_RelationshipCaseClient_TEXT	   CHAR(1) = 'C',
           @Lc_CaseStatusOpen_CODE			   CHAR(1) = 'O',
           @Lc_ErrorTypeError_CODE             CHAR(1) = 'E',
           @Lc_ProcessY_INDC                   CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_NameSendMatch1_CODE             CHAR(1) = '1',
           @Lc_NameSendMatch2_CODE             CHAR(1) = '2',
           @Lc_NameSendMatch3_CODE             CHAR(1) = '3',
           @Lc_NameReturned2_CODE              CHAR(1) = '2',
           @Lc_AddressEmployer_CODE            CHAR(1) = '1',
           @Lc_AddressEmployerOpt_CODE         CHAR(1) = '3',
           @Lc_TypeOthpEmployer_ID             CHAR(1) = 'E',
           @Lc_AddressEmployee_CODE            CHAR(1) = '2',
           @Lc_Note_INDC					   CHAR(1) = 'N',
           @Lc_StateInState_CODE               CHAR(2) = 'DE',
           @Lc_IncomeTypeEmployer_CODE         CHAR(2) = 'EM',
           @Lc_SubsystemLoc_CODE			   CHAR(3) = 'LO',
           @Lc_CountyFips000_CODE              CHAR(3) = '000',
           @Lc_CountyFips005_CODE              CHAR(3) = '005',
           @Lc_LocateSourceNdh_CODE            CHAR(3) = 'NDH',
           @Lc_SourceVerifiedNdh_CODE          CHAR(3) = 'NDH',
           @Lc_MajorActivityCase_CODE		   CHAR(4) = 'CASE',
           @Lc_ErrorE0907_CODE                 CHAR(5) = 'E0907',
           @Lc_ErrorE0145_CODE                 CHAR(5) = 'E0145',
           @Lc_ErrorTw018_CODE                 CHAR(5) = 'TW018',
           @Lc_ErrorE0620_CODE                 CHAR(5) = 'E0620',
           @Lc_ErrorE0085_CODE                 CHAR(5) = 'E0085',
           @Lc_ErrorE1089_CODE                 CHAR(5) = 'E1089',
           @Lc_ErrorE1175_CODE                 CHAR(5) = 'E1175',
           @Lc_BateErrorE1424_CODE             CHAR(5) = 'E1424',
           @Lc_MinorActivityRrfcr_CODE		   CHAR(5) = 'RRFCR',
           @Lc_DateFormatYyyymmdd_TEXT         CHAR(8) = 'YYYYMMDD',
           @Lc_ProcessFcrNdnh_ID               CHAR(8) = 'FW4_NDNH',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR(60) = 'SP_NDNH_W4_DETAILS',
           @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE  @Ln_Zero_NUMB					   NUMERIC(1) = 0,
           @Ln_Exists_NUMB					   NUMERIC(2) = 0,
           @Ln_CommitFreq_QNTY				   NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY		   NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY	   NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
           @Ln_OtherParty_IDNO				   NUMERIC(9),
           @Ln_Cur_QNTY						   NUMERIC(10,0) = 0,
           @Ln_EventFunctionalSeq_NUMB		   NUMERIC(10) = 0,
           @Ln_Topic_IDNO					   NUMERIC(10) = 0,
           @Ln_MemberMci_IDNO				   NUMERIC(10),
           @Ln_Error_NUMB					   NUMERIC(11),
           @Ln_ErrorLine_NUMB				   NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB		   NUMERIC(19),
           @Li_FetchStatus_QNTY				   SMALLINT,
           @Li_RowCount_QNTY				   SMALLINT,
           @Lc_Space_TEXT					   CHAR(1) = '',
           @Lc_TypeError_CODE				   CHAR(1) = '',
           @Lc_Msg_CODE						   CHAR(5),
           @Lc_BateError_CODE				   CHAR(5) = '',
           @Ls_Line1_ADDR					   VARCHAR(50),
           @Ls_Line2_ADDR					   VARCHAR(50),
           @Ls_Sql_TEXT						   VARCHAR(100),
           @Ls_CursorLoc_TEXT				   VARCHAR(200),
           @Ls_Sqldata_TEXT					   VARCHAR(1000),
           @Ls_BateRecord_TEXT                 VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT		   VARCHAR(4000),
           @Ls_ErrorMessage_TEXT			   VARCHAR(4000),
           @Ld_Hire_DATE					   DATE,
           @Ld_BeginEmployment_DATE			   DATE;

  DECLARE FcrNdnhw_CUR INSENSITIVE CURSOR FOR
   SELECT w.Seq_IDNO,
          w.Rec_ID,
          LTRIM(RTRIM(w.TypeMatchNdnh_CODE)) AS TypeMatchNdnh_CODE,
          w.StateTerr_CODE,
          w.LocSourceRespAgency_CODE,
          LTRIM(RTRIM(w.NameSendMatched_CODE)) AS NameSendMatched_CODE,
          w.First_NAME,
          w.Middle_NAME,
          w.Last_NAME,
          w.FirstAddl1_NAME,
          w.MiddleAddl1_NAME,
          w.LastAddl1_NAME,
          w.FirstAddl2_NAME,
          w.MiddleAddl2_NAME,
          w.LastAddl2_NAME,
          LTRIM(RTRIM(w.NameReturned_CODE)) AS NameReturned_CODE,
          w.FirstReturned_NAME,
          w.MiddleReturned_NAME,
          w.LastReturned_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(w.MemberReturnedSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE w.MemberReturnedSsn_NUMB
          END AS MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(w.MemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE w.MemberMci_IDNO
          END AS MemberMci_IDNO,
          w.UserField_NAME,
          LTRIM(RTRIM(w.CountyFips_CODE)) AS CountyFips_CODE,
          w.LocateRequestType_CODE,
          w.AddressFormat_CODE,
          w.OfAddress_DATE,
          LTRIM(RTRIM(w.LocResponse_CODE)) AS LocResponse_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(w.CorrectedMultiSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE w.CorrectedMultiSsn_NUMB
          END AS CorrectedMultiSsn_NUMB,
          LTRIM(RTRIM(w.Employer_NAME)) AS Employer_NAME,
          LTRIM(RTRIM(w.Line1_ADDR)) AS Line1_ADDR,
          LTRIM(RTRIM(w.Line2_ADDR)) AS Line2_ADDR,
          LTRIM(RTRIM(w.City_ADDR)) AS City_ADDR,
          w.State_ADDR,
          LTRIM(RTRIM(w.Zip_ADDR)) AS Zip_ADDR,
          w.ForeignCountry_CODE,
          w.ForeignCountry_NAME,
          w.AddrScrub1_CODE,
          w.AddrScrub2_CODE,
          w.AddrScrub3_CODE,
          LTRIM(RTRIM(w.StateReporting_CODE)) AS StateFips_CODE,
          LTRIM(RTRIM(w.TypeAddress_CODE)) AS TypeAddress_CODE,
          w.Birth_DATE,
          LTRIM(RTRIM(w.Hire_DATE)) AS Hire_DATE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(w.FederalEin_IDNO, '')))) = 0
            THEN '0'
           ELSE w.FederalEin_IDNO
          END AS FederalEin_IDNO,
          w.SsnMatch_CODE,
          w.AgencyReporting_NAME,
          w.DodAgencyStatus_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(w.StateEin_IDNO, '')))) = 0
            THEN '0'
           ELSE w.StateEin_IDNO
          END AS StateEin_IDNO,
          w.StateHire_CODE,
          w.TypeParticipant_CODE,
          w.StateSort_CODE,
          w.Normalization_CODE
     FROM LFNWD_Y1 w
    WHERE w.Process_INDC = 'N';
    
  DECLARE @Ln_FcrNdnhwCur_Seq_IDNO                 NUMERIC(19),
          @Lc_FcrNdnhwCur_Rec_ID                   CHAR(2),
          @Lc_FcrNdnhwCur_TypeMatchNdnh_CODE       CHAR(1),
          @Lc_FcrNdnhwCur_StateTerr_CODE           CHAR(2),
          @Lc_FcrNdnhwCur_LocSourceRespAgency_CODE CHAR(3),
          @Lc_FcrNdnhwCur_NameSendMatched_CODE     CHAR(1),
          @Lc_FcrNdnhwCur_First_NAME               CHAR(16),
          @Lc_FcrNdnhwCur_Middle_NAME              CHAR(16),
          @Lc_FcrNdnhwCur_Last_NAME                CHAR(30),
          @Lc_FcrNdnhwCur_FirstAddl1_NAME          CHAR(16),
          @Lc_FcrNdnhwCur_MiAddl1_NAME             CHAR(16),
          @Lc_FcrNdnhwCur_LastAddl1_NAME           CHAR(30),
          @Lc_FcrNdnhwCur_FirstAddl2_NAME          CHAR(16),
          @Lc_FcrNdnhwCur_MiAddl2_NAME             CHAR(16),
          @Lc_FcrNdnhwCur_LastAddl2_NAME           CHAR(30),
          @Lc_FcrNdnhwCur_NameReturned_CODE        CHAR(1),
          @Lc_FcrNdnhwCur_FirstReturned_NAME       CHAR(16),
          @Lc_FcrNdnhwCur_MiReturned_NAME          CHAR(16),
          @Lc_FcrNdnhwCur_LastReturned_NAME        CHAR(30),
          @Lc_FcrNdnhwCur_MemberSsnNumb_TEXT       CHAR(9),
          @Lc_FcrNdnhwCur_MemberMciIdno_TEXT       CHAR(10),
          @Lc_FcrNdnhwCur_UserField_NAME           CHAR(15),
          @Lc_FcrNdnhwCur_CountyFips_CODE          CHAR(3),
          @Lc_FcrNdnhwCur_LocateRequestType_CODE   CHAR(2),
          @Lc_FcrNdnhwCur_AddressFormat_CODE       CHAR(1),
          @Lc_FcrNdnhwCur_OfAddress_DATE           CHAR(8),
          @Lc_FcrNdnhwCur_LocResponse_CODE         CHAR(2),
          @Lc_FcrNdnhwCur_CorrectedMultiSsnNumb_TEXT   CHAR(9),
          @Ls_FcrNdnhwCur_Employer_NAME            VARCHAR(45),
          @Ls_FcrNdnhwCur_Line1_ADDR               VARCHAR(50),
          @Ls_FcrNdnhwCur_Line2_ADDR               VARCHAR(50),
          @Lc_FcrNdnhwCur_City_ADDR                CHAR(28),
          @Lc_FcrNdnhwCur_State_ADDR               CHAR(2),
          @Lc_FcrNdnhwCur_Zip_ADDR                 CHAR(10),
          @Lc_FcrNdnhwCur_ForeignCountry_CODE      CHAR(2),
          @Lc_FcrNdnhwCur_ForeignCountry_NAME      CHAR(25),
          @Lc_FcrNdnhwCur_AddrScrub1_CODE          CHAR(2),
          @Lc_FcrNdnhwCur_AddrScrub2_CODE          CHAR(2),
          @Lc_FcrNdnhwCur_AddrScrub3_CODE          CHAR(2),
          @Lc_FcrNdnhwCur_StateFips_CODE           CHAR(2),
          @Lc_FcrNdnhwCur_TypeAddress_CODE         CHAR(1),
          @Lc_FcrNdnhwCur_Birth_DATE               CHAR(8),
          @Lc_FcrNdnhwCur_Hire_DATE                CHAR(8),
          @Lc_FcrNdnhwCur_FeinIdno_TEXT            CHAR(9),
          @Lc_FcrNdnhwCur_SsnMatch_CODE            CHAR(1),
          @Lc_FcrNdnhwCur_AgencyReporting_NAME     CHAR(9),
          @Lc_FcrNdnhwCur_DodAgencyStatus_CODE     CHAR(1),
          @Lc_FcrNdnhwCur_SeinIdno_TEXT            CHAR(12),
          @Lc_FcrNdnhwCur_StateHire_CODE           CHAR(2),
          @Lc_FcrNdnhwCur_TypeParticipant_CODE     CHAR(2),
          @Lc_FcrNdnhwCur_StateSort_CODE           CHAR(2),
          @Lc_FcrNdnhwCur_Normalization_CODE       CHAR(1),
          
          @Ln_CaseMemberCur_Case_IDNO              NUMERIC(6),
          @Ln_FcrNdnhwCur_MemberSsn_NUMB		   NUMERIC(9),
          @Ln_FcrNdnhwCur_MemberMci_IDNO		   NUMERIC(10),
          @Ln_FcrNdnhwCur_Fein_IDNO				   NUMERIC(9);

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL(@An_ExceptionThreshold_QNTY, 0);
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL(@An_CommitFreq_QNTY, 0);
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_CommitFreq_QNTY = @Ln_Zero_NUMB;
   SET @Ln_Cur_QNTY = 0;

   BEGIN TRANSACTION NDNHW4_DETAILS;

   OPEN FcrNdnhw_CUR;

   FETCH NEXT FROM FcrNdnhw_CUR INTO @Ln_FcrNdnhwCur_Seq_IDNO, @Lc_FcrNdnhwCur_Rec_ID, @Lc_FcrNdnhwCur_TypeMatchNdnh_CODE, @Lc_FcrNdnhwCur_StateTerr_CODE, @Lc_FcrNdnhwCur_LocSourceRespAgency_CODE, @Lc_FcrNdnhwCur_NameSendMatched_CODE, @Lc_FcrNdnhwCur_First_NAME, @Lc_FcrNdnhwCur_Middle_NAME, @Lc_FcrNdnhwCur_Last_NAME, @Lc_FcrNdnhwCur_FirstAddl1_NAME, @Lc_FcrNdnhwCur_MiAddl1_NAME, @Lc_FcrNdnhwCur_LastAddl1_NAME, @Lc_FcrNdnhwCur_FirstAddl2_NAME, @Lc_FcrNdnhwCur_MiAddl2_NAME, @Lc_FcrNdnhwCur_LastAddl2_NAME, @Lc_FcrNdnhwCur_NameReturned_CODE, @Lc_FcrNdnhwCur_FirstReturned_NAME, @Lc_FcrNdnhwCur_MiReturned_NAME, @Lc_FcrNdnhwCur_LastReturned_NAME, @Lc_FcrNdnhwCur_MemberSsnNumb_TEXT, @Lc_FcrNdnhwCur_MemberMciIdno_TEXT, @Lc_FcrNdnhwCur_UserField_NAME, @Lc_FcrNdnhwCur_CountyFips_CODE, @Lc_FcrNdnhwCur_LocateRequestType_CODE, @Lc_FcrNdnhwCur_AddressFormat_CODE, @Lc_FcrNdnhwCur_OfAddress_DATE, @Lc_FcrNdnhwCur_LocResponse_CODE, @Lc_FcrNdnhwCur_CorrectedMultiSsnNumb_TEXT, @Ls_FcrNdnhwCur_Employer_NAME, @Ls_FcrNdnhwCur_Line1_ADDR, @Ls_FcrNdnhwCur_Line2_ADDR, @Lc_FcrNdnhwCur_City_ADDR, @Lc_FcrNdnhwCur_State_ADDR, @Lc_FcrNdnhwCur_Zip_ADDR, @Lc_FcrNdnhwCur_ForeignCountry_CODE, @Lc_FcrNdnhwCur_ForeignCountry_NAME, @Lc_FcrNdnhwCur_AddrScrub1_CODE, @Lc_FcrNdnhwCur_AddrScrub2_CODE, @Lc_FcrNdnhwCur_AddrScrub3_CODE, @Lc_FcrNdnhwCur_StateFips_CODE, @Lc_FcrNdnhwCur_TypeAddress_CODE, @Lc_FcrNdnhwCur_Birth_DATE, @Lc_FcrNdnhwCur_Hire_DATE, @Lc_FcrNdnhwCur_FeinIdno_TEXT, @Lc_FcrNdnhwCur_SsnMatch_CODE, @Lc_FcrNdnhwCur_AgencyReporting_NAME, @Lc_FcrNdnhwCur_DodAgencyStatus_CODE, @Lc_FcrNdnhwCur_SeinIdno_TEXT, @Lc_FcrNdnhwCur_StateHire_CODE, @Lc_FcrNdnhwCur_TypeParticipant_CODE, @Lc_FcrNdnhwCur_StateSort_CODE, @Lc_FcrNdnhwCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Process FCR NDNH records 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
	 SAVE TRANSACTION SAVENDNHW4_DETAILS;
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Lc_TypeError_CODE = '';
     
     SET @Ln_Exists_NUMB = 0;
     
     IF ISNUMERIC (@Lc_FcrNdnhwCur_MemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhwCur_MemberSsn_NUMB = @Lc_FcrNdnhwCur_MemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhwCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrNdnhwCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhwCur_MemberMci_IDNO = @Lc_FcrNdnhwCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhwCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrNdnhwCur_FeinIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhwCur_Fein_IDNO = @Lc_FcrNdnhwCur_FeinIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhwCur_Fein_IDNO = @Ln_Zero_NUMB;
		END
		
     SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrNdnhwCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS NVARCHAR(MAX)), '');
     SET @Ls_BateRecord_TEXT = 'Rec_ID = ' + ISNULL(@Lc_FcrNdnhwCur_Rec_ID, '') + ', TypeMatchNdnh_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_TypeMatchNdnh_CODE, '') + ', StateTerr_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_StateTerr_CODE, '') + ', LocSourceRespAgency_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_LocSourceRespAgency_CODE, '') + ', NameSendMatched_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_NameSendMatched_CODE, '') + ', First_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_Middle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_Last_NAME, '') + ', FirstAddl1_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_FirstAddl1_NAME, '') + ', MiAddl1_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_MiAddl1_NAME, '') + ', LastAddl1_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_LastAddl1_NAME, '') + ', FirstAddl2_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_FirstAddl2_NAME, '') + ', MiAddl2_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_MiAddl2_NAME, '') + ', LastAddl2_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_LastAddl2_NAME, '') + ', NameReturned_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_NameReturned_CODE, '') + ', FirstReturned_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_FirstReturned_NAME, '') + ', MiReturned_NAME = ' + ISNULL (@Lc_FcrNdnhwCur_MiReturned_NAME, '') + ', LastReturned_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_LastReturned_NAME, '') + ', MemberReturnedSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', UserField_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_UserField_NAME, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_CountyFips_CODE, '') + ', LocateRequestType_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_LocateRequestType_CODE, '') + ', AddressFormat_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_AddressFormat_CODE, '') + ', OfAddress_DATE = ' + ISNULL(@Lc_FcrNdnhwCur_OfAddress_DATE, '') + ', LocResponse_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_LocResponse_CODE, '') + ', CorrectedMultiSsn_NUMB = ' + ISNULL(@Lc_FcrNdnhwCur_CorrectedMultiSsnNumb_TEXT, 0) + ', Employer_NAME = ' + ISNULL(@Ls_FcrNdnhwCur_Employer_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrNdnhwCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FcrNdnhwCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_Zip_ADDR, '') + ', ForeignCountry_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_ForeignCountry_CODE, '') + ', ForeignCountry_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_ForeignCountry_NAME, '') + ', AddrScrub1_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_AddrScrub1_CODE, '') + ', AddrScrub2_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_AddrScrub2_CODE, '') + ', AddrScrub3_CODE = ' + ISNULL (@Lc_FcrNdnhwCur_AddrScrub3_CODE, '') + ', StateReporting_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_StateFips_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_TypeAddress_CODE, '') + ', Birth_DATE = ' + ISNULL(@Lc_FcrNdnhwCur_Birth_DATE, '') + ', Hire_DATE = ' + ISNULL(@Lc_FcrNdnhwCur_Hire_DATE, '') + ', FederalEin_IDNO = ' + ISNULL(@Lc_FcrNdnhwCur_FeinIdno_TEXT, 0) + ', SsnMatch_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_SsnMatch_CODE, '') + ', AgencyReporting_NAME = ' + ISNULL (@Lc_FcrNdnhwCur_AgencyReporting_NAME, '') + ', DodAgencyStatus_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_DodAgencyStatus_CODE, '') + ', StateEin_IDNO = ' + ISNULL(@Lc_FcrNdnhwCur_SeinIdno_TEXT, 0) + ', StateHire_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_StateHire_CODE, '') + ', TypeParticipant_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_TypeParticipant_CODE, '') + ', StateSort_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_StateSort_CODE, '') + ', Normalization_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_Normalization_CODE, '');
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', CaseMemberStatus_CODE = A';
          
     --check for existance of id_member
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrNdnhwCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'GET MemberMci_IDNO';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrNdnhwCur_Last_NAME, '');
            
       SELECT DISTINCT
              @Ln_MemberMci_IDNO = m.MemberMci_IDNO
         FROM DEMO_Y1 d,
              MSSN_Y1 m
        WHERE m.MemberSsn_NUMB = @Ln_FcrNdnhwCur_MemberSsn_NUMB
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE
          AND d.MemberMci_IDNO = m.MemberMci_IDNO
          AND UPPER (SUBSTRING (d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrNdnhwCur_Last_NAME, 1, 5);

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         --Member not found
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0907_CODE;

         GOTO lx_exception;
        END
       ELSE IF @Li_RowCount_QNTY > 1
        BEGIN
         ---Duplicate record exists
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

         GOTO lx_exception;
        END
      END
     ELSE
      BEGIN
       
       SET @Ln_MemberMci_IDNO = @Ln_FcrNdnhwCur_MemberMci_IDNO;
      END

     SET @Ls_Sql_TEXT = 'CHECK NAME SEND AND NAME RETURNED CODES';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', NameSendMatched_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_NameSendMatched_CODE, '') + ', NameReturned_CODE = ' + ISNULL (@Lc_FcrNdnhwCur_NameReturned_CODE, '') + ', LocResponse_CODE = ' + ISNULL (@Lc_FcrNdnhwCur_LocResponse_CODE, '');

     IF @Lc_FcrNdnhwCur_NameSendMatched_CODE IN (@Lc_NameSendMatch1_CODE, @Lc_NameSendMatch2_CODE, @Lc_NameSendMatch3_CODE)
        AND @Lc_FcrNdnhwCur_NameReturned_CODE = @Lc_NameReturned2_CODE
        AND ISNULL(@Lc_FcrNdnhwCur_LocResponse_CODE, '') = '' -- IS NULL
      BEGIN
      
       SET @Ls_Sql_TEXT = 'CHECK FOR COUNTY_FIPS';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);

       IF @Lc_FcrNdnhwCur_State_ADDR = @Lc_StateInState_CODE
          AND (@Lc_FcrNdnhwCur_CountyFips_CODE < @Lc_CountyFips000_CODE
               AND @Lc_FcrNdnhwCur_CountyFips_CODE > @Lc_CountyFips005_CODE)
        BEGIN
         
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorTw018_CODE;

         GOTO lx_exception;
        END

       SET @Ls_Sql_TEXT = 'CHECK THE FCR NDNH W4 ADDRESS TYPE ';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeAddress_CODE = ' + ISNULL(@Lc_FcrNdnhwCur_TypeAddress_CODE, '');

       IF @Lc_FcrNdnhwCur_TypeAddress_CODE IN (@Lc_AddressEmployer_CODE, @Lc_AddressEmployerOpt_CODE)
        BEGIN
         
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP3';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpEmployer_ID, '') + ', Fein_IDNO = ' + ISNULL(@Lc_FcrNdnhwCur_FeinIdno_TEXT, 0) + ', Employer_NAME = ' + ISNULL(@Ls_FcrNdnhwCur_Employer_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrNdnhwCur_Line1_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_Zip_ADDR, '');
        
         EXECUTE BATCH_COMMON$SP_GET_OTHP
          @Ad_Run_DATE                     = @Ad_Run_DATE,
          @An_Fein_IDNO                    = @Ln_FcrNdnhwCur_Fein_IDNO,
          @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_ID,
          @As_OtherParty_NAME              = @Ls_FcrNdnhwCur_Employer_NAME,
          @Ac_Aka_NAME                     = @Lc_Space_TEXT,
          @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
          @As_Line1_ADDR                   = @Ls_FcrNdnhwCur_Line1_ADDR,
          @As_Line2_ADDR                   = @Ls_FcrNdnhwCur_Line2_ADDR,
          @Ac_City_ADDR                    = @Lc_FcrNdnhwCur_City_ADDR,
          @Ac_Zip_ADDR                     = @Lc_FcrNdnhwCur_Zip_ADDR,
          @Ac_State_ADDR                   = @Lc_FcrNdnhwCur_State_ADDR,
          @Ac_Fips_CODE                    = @Lc_Space_TEXT,
          @Ac_Country_ADDR                 = @Lc_FcrNdnhwCur_ForeignCountry_CODE,
          @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
          @An_Phone_NUMB                   = @Ln_Zero_NUMB,
          @An_Fax_NUMB                     = @Ln_Zero_NUMB,
          @As_Contact_EML                  = @Lc_Space_TEXT,
          @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
          @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
          @An_Sein_IDNO                    = @Ln_Zero_NUMB,
          @Ac_SourceLoc_CODE               = @Lc_LocateSourceNdh_CODE,
          @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
          @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
          @Ac_Normalization_CODE           = @Lc_FcrNdnhwCur_Normalization_CODE,
          @Ac_Process_ID                   = @Lc_ProcessFcrNdnh_ID,
          @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
          @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;
         
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
		
         IF @Ln_OtherParty_IDNO = NULL
             OR @Ln_OtherParty_IDNO = 0 
          BEGIN
           
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0620_CODE;

           GOTO lx_exception;
          END

         SET @Ls_Sql_TEXT = 'BATCH_BASE_VALIDATOR$SF_ISVALIDDATE';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0) + ', Hire_DATE = ' + ISNULL (@Lc_FcrNdnhwCur_Hire_DATE, '') + ', Source_CODE = ' + ISNULL(@Lc_LocateSourceNdh_CODE, '') + ', SourceVerify_CODE = ' + ISNULL(@Lc_SourceVerifiedNdh_CODE, '');
         SET @Ld_Hire_DATE = NULL;
                  
         SET @Ls_Sql_TEXT = 'Hire_DATE FORMAT';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
         SET @Ld_Hire_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_FcrNdnhwCur_Hire_DATE, 112), 1 , 8);

         IF @Ld_Hire_DATE IS NULL
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

           GOTO lx_exception;
          END

         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE3';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0) + ', Source_CODE = ' + ISNULL (@Lc_LocateSourceNdh_CODE, '') + ', SourceVerify_CODE = ' + ISNULL(@Lc_SourceVerifiedNdh_CODE, '');
        
         SET @Ld_BeginEmployment_DATE = NULL;
         SET @Ld_BeginEmployment_DATE = ISNULL(@Ld_Hire_DATE, @Ad_Run_DATE);

         EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
          @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
          @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
          @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
          @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE, 
          @Ad_Status_DATE                = @Ad_Run_DATE,
          @Ac_TypeIncome_CODE            = @Lc_IncomeTypeEmployer_CODE,
          @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, 
          @Ad_Run_DATE                   = @Ad_Run_DATE,
          @Ad_BeginEmployment_DATE       = @Ld_BeginEmployment_DATE,
          @Ad_EndEmployment_DATE         = @Ld_High_DATE,
          @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
          @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
          @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
          @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
          @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
          @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
          @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
          @Ac_SourceLoc_CODE             = @Lc_LocateSourceNdh_CODE,
          @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
          @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
          @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
          @Ad_EligCoverage_DATE          = NULL,
          @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
          @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
          @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
          @Ac_SignedonWorker_ID          = @Lc_BatchRunUser_TEXT,
          @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
          @Ad_PlsLastSearch_DATE         = NULL,
          @Ac_Process_ID                 = @Lc_ProcessFcrNdnh_ID,
          @An_OfficeSignedOn_IDNO        = 0,
          @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

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
		
        END
       
       ELSE IF @Lc_FcrNdnhwCur_TypeAddress_CODE = @Lc_AddressEmployee_CODE
        BEGIN
         
         SET @Ls_Line1_ADDR = @Ls_FcrNdnhwCur_Line1_ADDR;
         SET @Ls_Line2_ADDR = @Ls_FcrNdnhwCur_Line2_ADDR;

         IF LTRIM(RTRIM(ISNULL(@Ls_FcrNdnhwCur_Line2_ADDR, ''))) <> ''
            AND LTRIM(RTRIM(ISNULL(@Ls_FcrNdnhwCur_Line1_ADDR, ''))) = ''-- IS NULL
          BEGIN
           SET @Ls_Line1_ADDR = @Ls_FcrNdnhwCur_Line2_ADDR;
           SET @Ls_Line2_ADDR = @Lc_Space_TEXT;
          END

         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE 3';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', Line1_ADDR = ' + ISNULL (@Ls_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL (@Lc_FcrNdnhwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrNdnhwCur_State_ADDR, '');
                  
         EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
          @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
          @Ad_Run_DATE                         = @Ad_Run_DATE,
          @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
          @Ad_Begin_DATE                       = @Ad_Run_DATE, 
          @Ad_End_DATE                         = @Ld_High_DATE,
          @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
          @As_Line1_ADDR                       = @Ls_Line1_ADDR,
          @As_Line2_ADDR                       = @Ls_Line2_ADDR,
          @Ac_City_ADDR                        = @Lc_FcrNdnhwCur_City_ADDR,
          @Ac_State_ADDR                       = @Lc_FcrNdnhwCur_State_ADDR,
          @Ac_Zip_ADDR                         = @Lc_FcrNdnhwCur_Zip_ADDR,
          @Ac_Country_ADDR                     = @Lc_FcrNdnhwCur_ForeignCountry_CODE,
          @An_Phone_NUMB                       = @Ln_Zero_NUMB,
          @Ac_SourceLoc_CODE                   = @Lc_LocateSourceNdh_CODE,
          @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
          @Ad_Status_DATE                      = @Ad_Run_DATE,
          @Ac_Status_CODE                      = @Lc_VerificationStatusPending_CODE,
          @Ac_SourceVerified_CODE              = @Lc_Space_TEXT,
          @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
          @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
          @Ac_Process_ID                       = @Lc_ProcessFcrNdnh_ID,
          @Ac_SignedonWorker_ID                = @Lc_BatchRunUser_TEXT,
          @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
          @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
          @Ac_Normalization_CODE               = @Lc_FcrNdnhwCur_Normalization_CODE,
          @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
			SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			RAISERROR (50001,16,1);
		  END
		 ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		      AND @Lc_Msg_CODE <> @Lc_ErrorE1089_CODE
			   BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
			   END
		END
	  -- 10827 Start Create Case journal entry RRFCR for all the cases where member is active cp or pf or ncp 
	   IF @Lc_FcrNdnhwCur_TypeAddress_CODE IN (@Lc_AddressEmployer_CODE, @Lc_AddressEmployerOpt_CODE,@Lc_AddressEmployee_CODE)
	    BEGIN
	     -- Add code here to create the RRFCR case journal entry
	     SET @Ls_Sql_TEXT = 'GENERATE TransactionEventSeq_NUMB A';
		 SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Ac_Job_ID;
	
         EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
          @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
          @Ac_Process_ID               = @Ac_Job_ID,
          @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
          @Ac_Note_INDC                = @Lc_Note_INDC,
          @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'GENERATE TransactionEventSeq_NUMB A FAILED';

           RAISERROR(50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'GET ALL ID_CASES FOR MEMBER';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
         DECLARE CaseMember_Cur INSENSITIVE CURSOR FOR
          SELECT b.Case_IDNO
            FROM CMEM_Y1 a,
                 CASE_Y1 b
           WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
             AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT,@Lc_RelationshipCaseClient_TEXT)
             AND b.Case_IDNO = a.Case_IDNO
             AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

         OPEN CaseMember_Cur;

         FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       -- process to generate case journal entries
         WHILE @Li_FetchStatus_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityRrfcr_CODE, '');
                
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
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
               
           FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO;
           SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
          END

         CLOSE CaseMember_Cur;

         DEALLOCATE CaseMember_Cur;
	    END
	  -- 10827 end  
     ELSE
       BEGIN
       
        SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
        SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

        GOTO lx_exception;
       END
      END
     
     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT =  'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_MemberMci_IDNO AS VARCHAR(10)), 0);
             
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
	   	   ROLLBACK TRANSACTION SAVENDNHW4_DETAILS;
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
                
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) ;

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
     SET @Ls_Sql_TEXT = 'UPDATE LFNWD_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhwCur_Seq_IDNO AS VARCHAR), 0);

     UPDATE LFNWD_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrNdnhwCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFNWD_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'COMMIT CHECK ';
     SET @Ls_Sqldata_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR), '');

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
         SET @Ls_DescriptionError_TEXT = 'BATCH RESTART UPDATE FAILED ';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION NDNHW4_DETAILS;  
       BEGIN TRANSACTION NDNHW4_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD PROCESS CHECK';
     SET @Ls_Sqldata_TEXT = 'EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION NDNHW4_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'EXCEPTION THRESHOLD EXCEEDED' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrNdnhw_CUR INTO @Ln_FcrNdnhwCur_Seq_IDNO, @Lc_FcrNdnhwCur_Rec_ID, @Lc_FcrNdnhwCur_TypeMatchNdnh_CODE, @Lc_FcrNdnhwCur_StateTerr_CODE, @Lc_FcrNdnhwCur_LocSourceRespAgency_CODE, @Lc_FcrNdnhwCur_NameSendMatched_CODE, @Lc_FcrNdnhwCur_First_NAME, @Lc_FcrNdnhwCur_Middle_NAME, @Lc_FcrNdnhwCur_Last_NAME, @Lc_FcrNdnhwCur_FirstAddl1_NAME, @Lc_FcrNdnhwCur_MiAddl1_NAME, @Lc_FcrNdnhwCur_LastAddl1_NAME, @Lc_FcrNdnhwCur_FirstAddl2_NAME, @Lc_FcrNdnhwCur_MiAddl2_NAME, @Lc_FcrNdnhwCur_LastAddl2_NAME, @Lc_FcrNdnhwCur_NameReturned_CODE, @Lc_FcrNdnhwCur_FirstReturned_NAME, @Lc_FcrNdnhwCur_MiReturned_NAME, @Lc_FcrNdnhwCur_LastReturned_NAME, @Lc_FcrNdnhwCur_MemberSsnNumb_TEXT, @Lc_FcrNdnhwCur_MemberMciIdno_TEXT, @Lc_FcrNdnhwCur_UserField_NAME, @Lc_FcrNdnhwCur_CountyFips_CODE, @Lc_FcrNdnhwCur_LocateRequestType_CODE, @Lc_FcrNdnhwCur_AddressFormat_CODE, @Lc_FcrNdnhwCur_OfAddress_DATE, @Lc_FcrNdnhwCur_LocResponse_CODE, @Lc_FcrNdnhwCur_CorrectedMultiSsnNumb_TEXT, @Ls_FcrNdnhwCur_Employer_NAME, @Ls_FcrNdnhwCur_Line1_ADDR, @Ls_FcrNdnhwCur_Line2_ADDR, @Lc_FcrNdnhwCur_City_ADDR, @Lc_FcrNdnhwCur_State_ADDR, @Lc_FcrNdnhwCur_Zip_ADDR, @Lc_FcrNdnhwCur_ForeignCountry_CODE, @Lc_FcrNdnhwCur_ForeignCountry_NAME, @Lc_FcrNdnhwCur_AddrScrub1_CODE, @Lc_FcrNdnhwCur_AddrScrub2_CODE, @Lc_FcrNdnhwCur_AddrScrub3_CODE, @Lc_FcrNdnhwCur_StateFips_CODE, @Lc_FcrNdnhwCur_TypeAddress_CODE, @Lc_FcrNdnhwCur_Birth_DATE, @Lc_FcrNdnhwCur_Hire_DATE, @Lc_FcrNdnhwCur_FeinIdno_TEXT, @Lc_FcrNdnhwCur_SsnMatch_CODE, @Lc_FcrNdnhwCur_AgencyReporting_NAME, @Lc_FcrNdnhwCur_DodAgencyStatus_CODE, @Lc_FcrNdnhwCur_SeinIdno_TEXT, @Lc_FcrNdnhwCur_StateHire_CODE, @Lc_FcrNdnhwCur_TypeParticipant_CODE, @Lc_FcrNdnhwCur_StateSort_CODE, @Lc_FcrNdnhwCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrNdnhw_CUR;

   DEALLOCATE FcrNdnhw_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   
   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   COMMIT TRANSACTION NDNHW4_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrNdnhw_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrNdnhw_CUR;

     DEALLOCATE FcrNdnhw_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NDNHW4_DETAILS;
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
