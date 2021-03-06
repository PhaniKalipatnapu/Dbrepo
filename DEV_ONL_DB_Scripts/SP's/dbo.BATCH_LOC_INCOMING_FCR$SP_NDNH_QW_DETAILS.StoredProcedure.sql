/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_NDNH_QW_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure  Name	     : BATCH_LOC_INCOMING_FCR$SP_NDNH_QW_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the Quarterly Wage details
                       from the temporary load table LFNQW_Y1 and updates
                       the employment information in EHIS_Y1 table.
                       In addition, the details will also be moved to FCRQ_Y1 table
Frequency			 : Daily
Developed On		 : 04/10/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				       BATCH_COMMON$SP_GET_OTHP
				       BATCH_COMMON$SP_EMPLOYER_UPDATE
				       BATCH_COMMON$SP_BATE_LOG
				       BATCH_COMMON$SP_BATCH_RESTART_UPDATE
-----------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_NDNH_QW_DETAILS]
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

  DECLARE  @Lc_Note_INDC							CHAR(1) = 'N',
           @Lc_StatusCaseMemberActive_CODE			CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE			CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE					CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE					CHAR(1) = 'E',
           @Lc_ProcessY_INDC						CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE					CHAR(1) = 'S',
           @Lc_NameSendMatch1_CODE					CHAR(1) = '1',
           @Lc_NameSendMatch2_CODE					CHAR(1) = '2',
           @Lc_NameSendMatch3_CODE					CHAR(1) = '3',
           @Lc_TypeOthpEmployer_CODE				CHAR(1) = 'E',
           @Lc_VerificationStatusPending_CODE		CHAR(1) = 'P',
           @Lc_IncomeTypeEmployer_CODE				CHAR(2) = 'EM',
           @Lc_LocResp39_CODE						CHAR(2) = '39',
           @Lc_LocResp46_CODE						CHAR(2) = '46',
           @Lc_LocateSourceNdh_CODE					CHAR(3) = 'NDH',
           @Lc_SourceVerifiedNdh_CODE				CHAR(3) = 'NDH',
           @Lc_ErrorE0907_CODE						CHAR(5) = 'E0907',
           @Lc_ErrorE0145_CODE						CHAR(5) = 'E0145',
           @Lc_ErrorE0620_CODE						CHAR(5) = 'E0620',
           @Lc_ErrorE0640_CODE                      CHAR(5) = 'E0640',
           @Lc_ErrorE1177_CODE						CHAR(5) = 'E1177',
           @Lc_BateErrorE1424_CODE					CHAR(5) = 'E1424',
           @Lc_Job_ID								CHAR(7) = 'DEB0480',
           @Lc_ProcessFcrNdnh_ID					CHAR(8) = 'FQW_NDNH',
           @Lc_BatchRunUser_TEXT					CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME						VARCHAR(60) = 'SP_NDNH_QW_DETAILS',
           @Ls_BateRecord_TEXT						VARCHAR(4000) = ' ',
           @Ld_High_DATE							DATE = '12/31/9999';
  DECLARE  @Ln_Zero_NUMB							NUMERIC(1) = 0,
           @Ln_Exists_NUMB							NUMERIC(2) = 0,
           @Ln_CommitFreq_QNTY						NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY				NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY			NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY		NUMERIC(6) = 0,
           @Ln_OtherParty_IDNO						NUMERIC(9) = 0,
           @Ln_EventFunctionalSeq_NUMB				NUMERIC(10) = 0,
           @Ln_Cur_QNTY								NUMERIC(10,0) = 0,
           @Ln_MemberMci_IDNO						NUMERIC(10),
           @Ln_Error_NUMB							NUMERIC(11),
           @Ln_ErrorLine_NUMB						NUMERIC(11),
           @Ln_Wage_AMNT							NUMERIC(11,2) = 0,
           @Ln_TransactionEventSeq_NUMB				NUMERIC(19),
           @Li_FetchStatus_QNTY						SMALLINT,
           @Li_RowCount_QNTY						SMALLINT,
           @Lc_Space_TEXT							CHAR(1) = '',
           @Lc_TypeError_CODE						CHAR(1) = '',
           @Lc_LocRespSpace_CODE					CHAR(2) = '',
           @Lc_Msg_CODE								CHAR(5) = '',
           @Lc_BateError_CODE						CHAR(5) = '',
           @Ls_Sql_TEXT								VARCHAR(100),
           @Ls_CursorLoc_TEXT						VARCHAR(200),
           @Ls_Sqldata_TEXT							VARCHAR(1000),
           @Ls_DescriptionError_TEXT				VARCHAR(4000),
           @Ls_ErrorMessage_TEXT					VARCHAR(4000);
           
  DECLARE
  FcrNdnhQw_CUR INSENSITIVE CURSOR FOR
   SELECT q.Seq_IDNO,
          q.Rec_ID,
          LTRIM(RTRIM(q.TypeMatchNdnh_CODE)) AS TypeMatchNdnh_CODE,
          q.StateTerr_CODE,
          q.LocSourceRespAgency_CODE,
          q.NameSendMatched_CODE,
          q.First_NAME,
          q.Middle_NAME,
          q.Last_NAME,
          q.FirstAddl1_NAME,
          q.MiddleAddl1_NAME,
          q.LastAddl1_NAME,
          q.FirstAddl2_NAME,
          q.MiddleAddl2_NAME,
          q.LastAddl2_NAME,
          q.NameReturned_CODE,
          q.FirstReturned_NAME,
          q.MiddleReturned_NAME,
          q.LastReturned_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(q.MemberReturnedSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE q.MemberReturnedSsn_NUMB
          END AS MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(q.MemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE q.MemberMci_IDNO
          END AS MemberMci_IDNO,
          q.UserField_NAME,
          q.CountyFips_CODE,
          q.LocateRequestType_CODE,
          q.AddressFormat_CODE,
          q.OfAddress_DATE,
          q.LocResponse_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(q.CorrectedMultiSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE q.CorrectedMultiSsn_NUMB
          END AS CorrectedMultiSsn_NUMB,
          q.Employer_NAME,
          LTRIM(RTRIM(q.Line1_ADDR)) AS Line1_ADDR,
          LTRIM(RTRIM(q.Line2_ADDR)) AS Line2_ADDR,
          LTRIM(RTRIM(q.City_ADDR)) AS City_ADDR,
          q.State_ADDR,
          LTRIM(RTRIM(q.Zip_ADDR)) AS Zip_ADDR,
          q.ForeignCountry_CODE,
          q.ForeignCountry_NAME,
          q.AddrScrub1_CODE,
          q.AddrScrub2_CODE,
          q.AddrScrub3_CODE,
          LTRIM(RTRIM(q.StateReporting_CODE)) AS StateReporting_CODE,
          q.TypeAddress_CODE,
          LTRIM(RTRIM(q.Wage_AMNT)) AS Wage_AMNT,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(q.FederalEin_IDNO, '')))) = 0
            THEN '0'
           ELSE q.FederalEin_IDNO
          END AS Fein_IDNO,
          q.SsnMatch_CODE,
          LTRIM(RTRIM(q.QtrReporting_CODE)) AS QtrReporting_CODE,
          LTRIM(RTRIM(q.AgencyReporting_NAME)) AS AgencyReporting_NAME,
          q.DodAgencyStatus_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(q.StateEin_IDNO, '')))) = 0
            THEN '0'
           ELSE q.StateEin_IDNO
          END AS Sein_IDNO,
          q.TypeParticipant_CODE,
          q.StateSort_CODE,
          q.Normalization_CODE
     FROM LFNQW_Y1 Q
    WHERE q.Process_INDC = 'N';
    
  DECLARE @Ln_FcrNdnhQwCur_Seq_IDNO						NUMERIC(19),
          @Lc_FcrNdnhQwCur_Rec_ID						CHAR(2),
          @Lc_FcrNdnhQwCur_TypeMatchNdnh_CODE			CHAR(1),
          @Lc_FcrNdnhQwCur_StateTerr_CODE				CHAR(2),
          @Lc_FcrNdnhQwCur_LocSourceRespAgency_CODE		CHAR(3),
          @Lc_FcrNdnhQwCur_NameSendMatched_CODE			CHAR(1),
          @Lc_FcrNdnhQwCur_First_NAME					CHAR(16),
          @Lc_FcrNdnhQwCur_Middle_NAME					CHAR(16),
          @Lc_FcrNdnhQwCur_Last_NAME					CHAR(30),
          @Lc_FcrNdnhQwCur_FirstAddl1_NAME				CHAR(16),
          @Lc_FcrNdnhQwCur_MiAddl1_NAME					CHAR(16),
          @Lc_FcrNdnhQwCur_LastAddl1_NAME				CHAR(30),
          @Lc_FcrNdnhQwCur_FirstAddl2_NAME				CHAR(16),
          @Lc_FcrNdnhQwCur_MiAddl2_NAME					CHAR(16),
          @Lc_FcrNdnhQwCur_LastAddl2_NAME				CHAR(30),
          @Lc_FcrNdnhQwCur_NameReturned_CODE			CHAR(1),
          @Lc_FcrNdnhQwCur_FirstReturned_NAME			CHAR(16),
          @Lc_FcrNdnhQwCur_MiReturned_NAME				CHAR(16),
          @Lc_FcrNdnhQwCur_LastReturned_NAME			CHAR(30),
          @Lc_FcrNdnhQwCur_MemberSsnNumb_TEXT			CHAR(9),
          @Lc_FcrNdnhQwCur_MemberMciIdno_TEXT			CHAR(10),
          @Lc_FcrNdnhQwCur_UserField_NAME				CHAR(15),
          @Lc_FcrNdnhQwCur_CountyFips_CODE				CHAR(3),
          @Lc_FcrNdnhQwCur_LocateRequestType_CODE		CHAR(2),
          @Lc_FcrNdnhQwCur_AddressFormat_CODE			CHAR(1),
          @Lc_FcrNdnhQwCur_OfAddress_DATE				CHAR(8),
          @Lc_FcrNdnhQwCur_LocResponse_CODE				CHAR(2),
          @Lc_FcrNdnhQwCur_CorrectedMultiSsnNumb_TEXT	CHAR(9),
          @Ls_FcrNdnhQwCur_Employer_NAME				VARCHAR(45),
          @Ls_FcrNdnhQwCur_Line1_ADDR					VARCHAR(50),
          @Ls_FcrNdnhQwCur_Line2_ADDR					VARCHAR(50),
          @Lc_FcrNdnhQwCur_City_ADDR					CHAR(28),
          @Lc_FcrNdnhQwCur_State_ADDR					CHAR(2),
          @Lc_FcrNdnhQwCur_Zip_ADDR						CHAR(10),
          @Lc_FcrNdnhQwCur_ForeignCountry_CODE			CHAR(2),
          @Lc_FcrNdnhQwCur_ForeignCountry_NAME			CHAR(25),
          @Lc_FcrNdnhQwCur_AddrScrub1_CODE				CHAR(2),
          @Lc_FcrNdnhQwCur_AddrScrub2_CODE				CHAR(2),
          @Lc_FcrNdnhQwCur_AddrScrub3_CODE				CHAR(2),
          @Lc_FcrNdnhQwCur_StateReporting_CODE			CHAR(2),
          @Lc_FcrNdnhQwCur_TypeAddress_CODE				CHAR(1),
          @Lc_FcrNdnhQwCur_Wage_AMNT					CHAR(11),
          @Lc_FcrNdnhQwCur_FeinIdnio_TEXT				CHAR(9),
          @Lc_FcrNdnhQwCur_SsnMatch_CODE				CHAR(1),
          @Lc_FcrNdnhQwCur_QtrReporting_CODE			CHAR(5),
          @Lc_FcrNdnhQwCur_AgencyReporting_NAME			CHAR(9),
          @Lc_FcrNdnhQwCur_DodAgencyStatus_CODE			CHAR(1),
          @Lc_FcrNdnhQwCur_SeinIdno_TEXT				CHAR(12),
          @Lc_FcrNdnhQwCur_TypeParticipant_CODE			CHAR(2),
          @Lc_FcrNdnhQwCur_StateSort_CODE				CHAR(2),
          @Lc_FcrNdnhQwCur_Normalization_CODE			CHAR(1),
          
          @Ln_FcrNdnhQwCur_MemberSsn_NUMB				NUMERIC(9),
          @Ln_FcrNdnhQwCur_MemberMci_IDNO				NUMERIC(10),
          @Ln_FcrNdnhQwCur_Fein_IDNO					NUMERIC(9),
          @Ln_FcrNdnhQwCur_Sein_IDNO					NUMERIC(12);

  BEGIN TRY
   BEGIN TRANSACTION NDNHQW_DETAILS;

   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL(@An_ExceptionThreshold_QNTY, 0);
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL(@An_CommitFreq_QNTY, 0);
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_ErrorMessage_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_CommitFreq_QNTY = @Ln_Zero_NUMB;
   SET @Ln_Cur_QNTY = 0;
   
   OPEN FcrNdnhQw_CUR;

   SET @Ls_Sql_TEXT = 'FcrNdnhQw_CUR CURSOR FETCH ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM FcrNdnhQw_CUR INTO @Ln_FcrNdnhQwCur_Seq_IDNO, @Lc_FcrNdnhQwCur_Rec_ID, @Lc_FcrNdnhQwCur_TypeMatchNdnh_CODE, @Lc_FcrNdnhQwCur_StateTerr_CODE, @Lc_FcrNdnhQwCur_LocSourceRespAgency_CODE, @Lc_FcrNdnhQwCur_NameSendMatched_CODE, @Lc_FcrNdnhQwCur_First_NAME, @Lc_FcrNdnhQwCur_Middle_NAME, @Lc_FcrNdnhQwCur_Last_NAME, @Lc_FcrNdnhQwCur_FirstAddl1_NAME, @Lc_FcrNdnhQwCur_MiAddl1_NAME, @Lc_FcrNdnhQwCur_LastAddl1_NAME, @Lc_FcrNdnhQwCur_FirstAddl2_NAME, @Lc_FcrNdnhQwCur_MiAddl2_NAME, @Lc_FcrNdnhQwCur_LastAddl2_NAME, @Lc_FcrNdnhQwCur_NameReturned_CODE, @Lc_FcrNdnhQwCur_FirstReturned_NAME, @Lc_FcrNdnhQwCur_MiReturned_NAME, @Lc_FcrNdnhQwCur_LastReturned_NAME, @Lc_FcrNdnhQwCur_MemberSsnNumb_TEXT, @Lc_FcrNdnhQwCur_MemberMciIdno_TEXT, @Lc_FcrNdnhQwCur_UserField_NAME, @Lc_FcrNdnhQwCur_CountyFips_CODE, @Lc_FcrNdnhQwCur_LocateRequestType_CODE, @Lc_FcrNdnhQwCur_AddressFormat_CODE, @Lc_FcrNdnhQwCur_OfAddress_DATE, @Lc_FcrNdnhQwCur_LocResponse_CODE, @Lc_FcrNdnhQwCur_CorrectedMultiSsnNumb_TEXT, @Ls_FcrNdnhQwCur_Employer_NAME, @Ls_FcrNdnhQwCur_Line1_ADDR, @Ls_FcrNdnhQwCur_Line2_ADDR, @Lc_FcrNdnhQwCur_City_ADDR, @Lc_FcrNdnhQwCur_State_ADDR, @Lc_FcrNdnhQwCur_Zip_ADDR, @Lc_FcrNdnhQwCur_ForeignCountry_CODE, @Lc_FcrNdnhQwCur_ForeignCountry_NAME, @Lc_FcrNdnhQwCur_AddrScrub1_CODE, @Lc_FcrNdnhQwCur_AddrScrub2_CODE, @Lc_FcrNdnhQwCur_AddrScrub3_CODE, @Lc_FcrNdnhQwCur_StateReporting_CODE, @Lc_FcrNdnhQwCur_TypeAddress_CODE, @Lc_FcrNdnhQwCur_Wage_AMNT, @Lc_FcrNdnhQwCur_FeinIdnio_TEXT, @Lc_FcrNdnhQwCur_SsnMatch_CODE, @Lc_FcrNdnhQwCur_QtrReporting_CODE, @Lc_FcrNdnhQwCur_AgencyReporting_NAME, @Lc_FcrNdnhQwCur_DodAgencyStatus_CODE, @Lc_FcrNdnhQwCur_SeinIdno_TEXT, @Lc_FcrNdnhQwCur_TypeParticipant_CODE, @Lc_FcrNdnhQwCur_StateSort_CODE, @Lc_FcrNdnhQwCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process FCR qw records 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVENDNHQW_DETAILS;
    
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Lc_TypeError_CODE = '';
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     
     SET @Ln_Exists_NUMB = 0;
     
     IF ISNUMERIC (@Lc_FcrNdnhQwCur_MemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhQwCur_MemberSsn_NUMB = @Lc_FcrNdnhQwCur_MemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhQwCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrNdnhQwCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhQwCur_MemberMci_IDNO = @Lc_FcrNdnhQwCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhQwCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrNdnhQwCur_FeinIdnio_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhQwCur_Fein_IDNO = @Lc_FcrNdnhQwCur_FeinIdnio_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhQwCur_Fein_IDNO = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrNdnhQwCur_SeinIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhQwCur_Sein_IDNO = @Lc_FcrNdnhQwCur_SeinIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhQwCur_Sein_IDNO = @Ln_Zero_NUMB;
		END
		
     SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrNdnhQwCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), 0);
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcrNdnhQwCur_Rec_ID, '') + ', TypeMatchNdnh_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_TypeMatchNdnh_CODE, '') + ', StateTerr_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_StateTerr_CODE, '') + ', LocSourceRespAgency_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_LocSourceRespAgency_CODE, '') + ', NameSendMatched_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_NameSendMatched_CODE, '') + ', First_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_Middle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_Last_NAME, '') + ', FirstAddl1_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_FirstAddl1_NAME, '') + ', MiAddl1_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_MiAddl1_NAME, '') + ', LastAddl1_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_LastAddl1_NAME, '') + ', FirstAddl2_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_FirstAddl2_NAME, '') + ', MiAddl2_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_MiAddl2_NAME, '') + ', LastAddl2_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_LastAddl2_NAME, '') + ', NameReturned_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_NameReturned_CODE, '') + ', FirstReturned_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_FirstReturned_NAME, '') + ', MiReturned_NAME = ' + ISNULL (@Lc_FcrNdnhQwCur_MiReturned_NAME, '') + ', LastReturned_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_LastReturned_NAME, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', UserField_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_UserField_NAME, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_CountyFips_CODE, '') + ', LocateRequestType_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_LocateRequestType_CODE, '') + ', AddressFormat_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_AddressFormat_CODE, '') + ', OfAddress_DATE = ' + ISNULL(@Lc_FcrNdnhQwCur_OfAddress_DATE, '') + ', LocResponse_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_LocResponse_CODE, '') + ', CorrectedMultiSsn_NUMB = ' + ISNULL(@Lc_FcrNdnhQwCur_CorrectedMultiSsnNumb_TEXT, 0) + ', Employer_NAME = ' + ISNULL(@Ls_FcrNdnhQwCur_Employer_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrNdnhQwCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FcrNdnhQwCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrNdnhQwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrNdnhQwCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrNdnhQwCur_Zip_ADDR, '') + ', ForeignCountry_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_ForeignCountry_CODE, '') + ', ForeignCountry_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_ForeignCountry_NAME, '') + ', AddrScrub1_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_AddrScrub1_CODE, '') + ', AddrScrub2_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_AddrScrub2_CODE, '') + ', AddrScrub3_CODE = ' + ISNULL (@Lc_FcrNdnhQwCur_AddrScrub3_CODE, '') + ', StateReporting_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_StateReporting_CODE, '') + ', TypeAddress_CODE = ' + ISNULL (@Lc_FcrNdnhQwCur_TypeAddress_CODE, '') + ', Wage_AMNT = ' + ISNULL(@Lc_FcrNdnhQwCur_Wage_AMNT, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Fein_IDNO AS VARCHAR (9)), 0) + ', SsnMatch_CODE = ' + ISNULL (@Lc_FcrNdnhQwCur_SsnMatch_CODE, '') + ', QtrReporting_CODE = ' + ISNULL (@Lc_FcrNdnhQwCur_QtrReporting_CODE, '') + ', AgencyReporting_NAME = ' + ISNULL (@Lc_FcrNdnhQwCur_AgencyReporting_NAME, '') + ', DodAgencyStatus_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_DodAgencyStatus_CODE, '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Sein_IDNO AS VARCHAR(12)), 0) + ', TypeParticipant_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_TypeParticipant_CODE, '') + ', StateSort_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_StateSort_CODE, '') + ', Normalization_CODE = ' + ISNULL (@Lc_FcrNdnhQwCur_Normalization_CODE, '');
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', CaseMemberStatus_CODE = A';
     
     --check for existance of id_member
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrNdnhQwCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'GET MemberMci_IDNO';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrNdnhQwCur_Last_NAME, '');
       
       SELECT DISTINCT
              @Ln_MemberMci_IDNO = m.MemberMci_IDNO
         FROM DEMO_Y1 d,
              MSSN_Y1 m
        WHERE m.MemberSsn_NUMB = @Ln_FcrNdnhQwCur_MemberSsn_NUMB
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE
          AND d.MemberMci_IDNO = m.MemberMci_IDNO
          AND UPPER (SUBSTRING (d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrNdnhQwCur_Last_NAME, 1, 5);

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         ----Member not found
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
       
       SET @Ln_MemberMci_IDNO = @Ln_FcrNdnhQwCur_MemberMci_IDNO;
      END

     SET @Ls_Sql_TEXT = 'CHECK NAME MATCHED AND LOCATE RESPONSE ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeMatchNdnh_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_TypeMatchNdnh_CODE, '') + ', NameSendMatched_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_NameSendMatched_CODE, '') + ', LocResponse_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_LocResponse_CODE, '');

     IF @Lc_FcrNdnhQwCur_TypeMatchNdnh_CODE IS NOT NULL
        AND @Lc_FcrNdnhQwCur_NameSendMatched_CODE IN (@Lc_NameSendMatch1_CODE, @Lc_NameSendMatch2_CODE, @Lc_NameSendMatch3_CODE)
        AND @Lc_FcrNdnhQwCur_LocResponse_CODE IN (@Lc_LocResp39_CODE, @Lc_LocResp46_CODE, @Lc_LocRespSpace_CODE)
      BEGIN
       
       SET @Ls_Sql_TEXT = 'SELECT FROM FCRQ_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Fein_IDNO AS VARCHAR(9)), 0) + ', QtrReporting_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_QtrReporting_CODE, '');
       SET @Ln_Exists_NUMB = 0;
      
       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM FCRQ_Y1 f
        WHERE f.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND f.Fein_IDNO = @Ln_FcrNdnhQwCur_Fein_IDNO
          AND f.QtrReporting_CODE = @Lc_FcrNdnhQwCur_QtrReporting_CODE;

       IF @Ln_Exists_NUMB = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT 1';
         SET @Ls_Sqldata_TEXT = 'CONVERT Wage_AMNT = ' + ISNULL(@Lc_FcrNdnhQwCur_Wage_AMNT, '');
         SET @Ln_Wage_AMNT = dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN(@Lc_FcrNdnhQwCur_Wage_AMNT) / 100;
                  
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

         SET @Ls_Sql_TEXT = 'INSERT INTO FCRQ_Y1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', StateFips_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_StateReporting_CODE, '') + ', Wage_AMNT = ' + ISNULL(CAST(@Ln_Wage_AMNT AS VARCHAR(12)), '');
                 
         INSERT FCRQ_Y1
                (MemberMci_IDNO,
                 StateReporting_CODE,
                 TypeAddress_CODE,
                 Wage_AMNT,
                 Fein_IDNO,
                 SsnMatch_CODE,
                 QtrReporting_CODE,
                 AgencyReporting_NAME,
                 DodStatus_CODE,
                 Sein_IDNO,
                 TypeParticipant_CODE,
                 WorkerUpdate_ID,
                 Transaction_DATE,
                 Update_DTTM,
                 TransactionEventSeq_NUMB)
         VALUES ( @Ln_MemberMci_IDNO, -- MemberMci_IDNO
                  ISNULL(@Lc_FcrNdnhQwCur_StateReporting_CODE, @Lc_Space_TEXT), -- StateReporting_CODE
                  @Lc_FcrNdnhQwCur_TypeAddress_CODE, -- TypeAddress_CODE
                  @Ln_Wage_AMNT,  -- Wage_AMNT
                  ISNULL(@Ln_FcrNdnhQwCur_Fein_IDNO, @Ln_Zero_NUMB), -- Fein_IDNO
                  @Lc_FcrNdnhQwCur_SsnMatch_CODE, -- SsnMatch_CODE
                  ISNULL(@Lc_FcrNdnhQwCur_QtrReporting_CODE, @Lc_Space_TEXT), -- QtrReporting_CODE
                  ISNULL(@Lc_FcrNdnhQwCur_AgencyReporting_NAME, @Lc_Space_TEXT), -- AgencyReporting_NAME
                  @Lc_FcrNdnhQwCur_DodAgencyStatus_CODE, -- DodStatus_CODE
                  ISNULL(@Ln_FcrNdnhQwCur_Sein_IDNO, @Ln_Zero_NUMB), -- Sein_IDNO
                  @Lc_FcrNdnhQwCur_TypeParticipant_CODE, -- TypeParticipant_CODE
                  @Lc_BatchRunUser_TEXT, -- WorkerUpdate_ID
                  @Ad_Run_DATE, -- Transaction_DATE
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), -- Update_DTTM
                  @Ln_TransactionEventSeq_NUMB); -- TransactionEventSeq_NUMB

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT INTO FCRQ_Y1 FAILED';

           RAISERROR(50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'CONVERT Wage_AMNT = ' + ISNULL(@Lc_FcrNdnhQwCur_Wage_AMNT, '');
         SET @Ln_Wage_AMNT = dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN(@Lc_FcrNdnhQwCur_Wage_AMNT) / 100;
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Fein_IDNO AS VARCHAR(9)), 0) + ', QtrReporting_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_QtrReporting_CODE, '') + ', Wage_AMNT = ' + ISNULL(CAST(@Ln_Wage_AMNT AS VARCHAR(12)), '');
         SET @Ln_Exists_NUMB = 0;
        
         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM FCRQ_Y1 f
          WHERE f.MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND f.Fein_IDNO = @Ln_FcrNdnhQwCur_Fein_IDNO
            AND f.QtrReporting_CODE = @Lc_FcrNdnhQwCur_QtrReporting_CODE
            AND f.Wage_AMNT = @Ln_Wage_AMNT;

         IF @Ln_Exists_NUMB = 0
          BEGIN
                      
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 2';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
           
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

           SET @Ls_Sql_TEXT = 'UPDATE FCRQ_Y1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Fein_IDNO AS VARCHAR(9)), 0) + ', QtrReporting_CODE = ' + ISNULL(@Lc_FcrNdnhQwCur_QtrReporting_CODE, '') + ', Wage_AMNT = ' + ISNULL(CAST(@Ln_Wage_AMNT AS VARCHAR(12)), '');
           
           UPDATE FCRQ_Y1
              SET Wage_AMNT = @Ln_Wage_AMNT,
                  WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                  Transaction_DATE = @Ad_Run_DATE,
                  Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
                  TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
            WHERE FCRQ_Y1.MemberMci_IDNO = @Ln_MemberMci_IDNO
              AND FCRQ_Y1.Fein_IDNO = @Ln_FcrNdnhQwCur_Fein_IDNO
              AND FCRQ_Y1.QtrReporting_CODE = @Lc_FcrNdnhQwCur_QtrReporting_CODE;

           SET @Li_RowCount_QNTY = @@ROWCOUNT;

           IF @Li_RowCount_QNTY = 0
            BEGIN
             SET @Ls_ErrorMessage_TEXT = 'UPDATE FCRQ_Y1 FAILED';

             RAISERROR(50001,16,1);
            END
          END
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeOthp_CODE = ' + ISNULL (@Lc_TypeOthpEmployer_CODE, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Fein_IDNO AS VARCHAR(9)), 0) + ', Employer_NAME = ' + ISNULL(@Ls_FcrNdnhQwCur_Employer_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrNdnhQwCur_Line1_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrNdnhQwCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrNdnhQwCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrNdnhQwCur_Zip_ADDR, '');
       
       EXECUTE BATCH_COMMON$SP_GET_OTHP
        @Ad_Run_DATE                     = @Ad_Run_DATE,
        @An_Fein_IDNO                    = @Ln_FcrNdnhQwCur_Fein_IDNO,
        @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_CODE,
        @As_OtherParty_NAME              = @Ls_FcrNdnhQwCur_Employer_NAME,
        @Ac_Aka_NAME                     = @Lc_Space_TEXT,
        @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
        @As_Line1_ADDR                   = @Ls_FcrNdnhQwCur_Line1_ADDR,
        @As_Line2_ADDR                   = @Ls_FcrNdnhQwCur_Line2_ADDR,
        @Ac_City_ADDR                    = @Lc_FcrNdnhQwCur_City_ADDR,
        @Ac_Zip_ADDR                     = @Lc_FcrNdnhQwCur_Zip_ADDR,
        @Ac_State_ADDR                   = @Lc_FcrNdnhQwCur_State_ADDR,
        @Ac_Fips_CODE                    = @Lc_Space_TEXT,
        @Ac_Country_ADDR                 = @Lc_FcrNdnhQwCur_ForeignCountry_CODE,
        @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
        @An_Phone_NUMB                   = @Ln_Zero_NUMB,
        @An_Fax_NUMB                     = @Ln_Zero_NUMB,
        @As_Contact_EML                  = @Lc_Space_TEXT,
        @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
        @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
        @An_Sein_IDNO                    = @Ln_Zero_NUMB,
        @Ac_SourceLoc_CODE               = @Lc_LocateSourceNdh_CODE,
        @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
        @An_DchCarrier_IDNO              = @Ln_ZERO_NUMB,
        @Ac_Normalization_CODE           = @Lc_FcrNdnhQwCur_Normalization_CODE,
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
	  
       IF @Ln_OtherParty_IDNO = @Ln_Zero_NUMB
        BEGIN
         
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0620_CODE;

         GOTO lx_exception;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);
       
       EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
        @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
        @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
        @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
        @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE, 
        @Ad_Status_DATE                = @Ad_Run_DATE,
        @Ac_TypeIncome_CODE            = @Lc_IncomeTypeEmployer_CODE,
        @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, 
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @Ad_BeginEmployment_DATE       = NULL,
        @Ad_EndEmployment_DATE         = @Ld_High_DATE,
        @An_IncomeGross_AMNT           = @Ln_Wage_AMNT,
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
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
			SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			RAISERROR (50001,16,1);
		  END
	     ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
	            AND @Lc_Msg_CODE NOT IN (@Lc_ErrorE0145_CODE, @Lc_ErrorE0640_CODE)
			   BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
			   END
	  
      END
     ELSE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1177_CODE;

       GOTO lx_exception;
      END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
                   
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 6';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

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
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO BATE-8 FAILED FOR ';

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
	   	   ROLLBACK TRANSACTION SAVENDNHQW_DETAILS;
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
     SET @Ls_Sql_TEXT = 'UPDATE LFNQW_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhQwCur_Seq_IDNO AS VARCHAR), 0);

     UPDATE LFNQW_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrNdnhQwCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LFNQW_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK ';
     SET @Ls_Sqldata_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');

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
         SET @Ls_ErrorMessage_TEXT = 'BATCH RESTART UPDATE FAILED ';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION NDNHQW_DETAILS; 
       BEGIN TRANSACTION NDNHQW_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK ';
     SET @Ls_Sqldata_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION NDNHQW_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrNdnhQw_CUR INTO @Ln_FcrNdnhQwCur_Seq_IDNO, @Lc_FcrNdnhQwCur_Rec_ID, @Lc_FcrNdnhQwCur_TypeMatchNdnh_CODE, @Lc_FcrNdnhQwCur_StateTerr_CODE, @Lc_FcrNdnhQwCur_LocSourceRespAgency_CODE, @Lc_FcrNdnhQwCur_NameSendMatched_CODE, @Lc_FcrNdnhQwCur_First_NAME, @Lc_FcrNdnhQwCur_Middle_NAME, @Lc_FcrNdnhQwCur_Last_NAME, @Lc_FcrNdnhQwCur_FirstAddl1_NAME, @Lc_FcrNdnhQwCur_MiAddl1_NAME, @Lc_FcrNdnhQwCur_LastAddl1_NAME, @Lc_FcrNdnhQwCur_FirstAddl2_NAME, @Lc_FcrNdnhQwCur_MiAddl2_NAME, @Lc_FcrNdnhQwCur_LastAddl2_NAME, @Lc_FcrNdnhQwCur_NameReturned_CODE, @Lc_FcrNdnhQwCur_FirstReturned_NAME, @Lc_FcrNdnhQwCur_MiReturned_NAME, @Lc_FcrNdnhQwCur_LastReturned_NAME, @Lc_FcrNdnhQwCur_MemberSsnNumb_TEXT, @Lc_FcrNdnhQwCur_MemberMciIdno_TEXT, @Lc_FcrNdnhQwCur_UserField_NAME, @Lc_FcrNdnhQwCur_CountyFips_CODE, @Lc_FcrNdnhQwCur_LocateRequestType_CODE, @Lc_FcrNdnhQwCur_AddressFormat_CODE, @Lc_FcrNdnhQwCur_OfAddress_DATE, @Lc_FcrNdnhQwCur_LocResponse_CODE, @Lc_FcrNdnhQwCur_CorrectedMultiSsnNumb_TEXT, @Ls_FcrNdnhQwCur_Employer_NAME, @Ls_FcrNdnhQwCur_Line1_ADDR, @Ls_FcrNdnhQwCur_Line2_ADDR, @Lc_FcrNdnhQwCur_City_ADDR, @Lc_FcrNdnhQwCur_State_ADDR, @Lc_FcrNdnhQwCur_Zip_ADDR, @Lc_FcrNdnhQwCur_ForeignCountry_CODE, @Lc_FcrNdnhQwCur_ForeignCountry_NAME, @Lc_FcrNdnhQwCur_AddrScrub1_CODE, @Lc_FcrNdnhQwCur_AddrScrub2_CODE, @Lc_FcrNdnhQwCur_AddrScrub3_CODE, @Lc_FcrNdnhQwCur_StateReporting_CODE, @Lc_FcrNdnhQwCur_TypeAddress_CODE, @Lc_FcrNdnhQwCur_Wage_AMNT, @Lc_FcrNdnhQwCur_FeinIdnio_TEXT, @Lc_FcrNdnhQwCur_SsnMatch_CODE, @Lc_FcrNdnhQwCur_QtrReporting_CODE, @Lc_FcrNdnhQwCur_AgencyReporting_NAME, @Lc_FcrNdnhQwCur_DodAgencyStatus_CODE, @Lc_FcrNdnhQwCur_SeinIdno_TEXT, @Lc_FcrNdnhQwCur_TypeParticipant_CODE, @Lc_FcrNdnhQwCur_StateSort_CODE, @Lc_FcrNdnhQwCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrNdnhQw_CUR;

   DEALLOCATE FcrNdnhQw_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;

   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   -- Transaction ends 
  
   COMMIT TRANSACTION NDNHQW_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrNdnhQw_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrNdnhQw_CUR;

     DEALLOCATE FcrNdnhQw_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NDNHQW_DETAILS;
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
