/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_NDNH_UIB_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_NDNH_UIB_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the Quarterly Wage details
                       from the temporary table LOAD_FCR_UIB_DETAILS and updates
                       the employment information in EHIS_Y1 table.
                       In addition, the details will also be moved to FCRQ_Y1 table
Frequency			 : Daily
Developed On		 : 04/10/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_ADDRESS_UPDATE
					   BATCH_COMMON$SP_EMPLOYER_UPDATE
					   BATCH_COMMON$SP_BATE_LOG 
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_NDNH_UIB_DETAILS]
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

  DECLARE  @Ln_Benefit_AMNT                    NUMERIC(11,2) = 0,
           @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE     CHAR(1) = 'Y',
           @Lc_TypeAddressM_CODE               CHAR(1) = 'M',
           @Lc_VerificationStatusPending_CODE  CHAR(1) = 'P',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE             CHAR(1) = 'E',
           @Lc_ProcessY_INDC                   CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_NameSendMatch1_CODE             CHAR(1) = '1',
           @Lc_NameSendMatch2_CODE             CHAR(1) = '2',
           @Lc_NameSendMatch3_CODE             CHAR(1) = '3',
           @Lc_TypeOthpUnemplAgency_CODE       CHAR(1) = 'X',
           @Lc_InStateFips_CODE                CHAR(2) = '10',
           @Lc_StateInState_CODE               CHAR(2) = 'DE',
           @Lc_LocResp39_CODE                  CHAR(2) = '39',
           @Lc_LocResp46_CODE                  CHAR(2) = '46',
           @Lc_LocRespSpace_CODE               CHAR(2) = ' ',
           @Lc_IncomeTypeUi_CODE               CHAR(2) = 'UI',
           @Lc_LocateSourceNdh_CODE            CHAR(3) = 'NDH',
           @Lc_SourceVerifiedNdh_CODE          CHAR(3) = 'NDH',
           @Lc_ErrorE0907_CODE                 CHAR(5) = 'E0907',
           @Lc_ErrorE0145_CODE                 CHAR(5) = 'E0145',
           @Lc_ErrorE0540_CODE                 CHAR(5) = 'E0540',
           @Lc_ErrorE1089_CODE                 CHAR(5) = 'E1089',
           @Lc_ErrorE1177_CODE                 CHAR(5) = 'E1177',
           @Lc_BateErrorE1424_CODE             CHAR(5) = 'E1424',
           @Lc_ProcessFcrNdnh_ID               CHAR(8) = 'FUI_NDNH',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR(60) = 'SP_NDNH_UIB_DETAILS',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB					   NUMERIC(1) = 0,
           @Ln_Exists_NUMB					   NUMERIC(2) = 0,
           @Ln_CommitFreq_QNTY				   NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY		   NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY	   NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
           @Ln_OtherParty_IDNO				   NUMERIC(9),
           @Ln_Cur_QNTY						   NUMERIC(10,0) = 0,
           @Ln_MemberMci_IDNO				   NUMERIC(10),
           @Ln_Error_NUMB					   NUMERIC(11),
           @Ln_ErrorLine_NUMB				   NUMERIC(11),
           @Li_FetchStatus_QNTY				   SMALLINT,
           @Li_RowCount_QNTY				   SMALLINT,
           @Lc_Space_TEXT					   CHAR(1) = '',
           @Lc_TypeError_CODE				   CHAR(1) = '',
           @Lc_Msg_CODE						   CHAR(5),
           @Lc_BateError_CODE				   CHAR(5) = '',
           @Ls_Sql_TEXT						   VARCHAR(100),
           @Ls_CursorLoc_TEXT				   VARCHAR(200),
           @Ls_Sqldata_TEXT					   VARCHAR(1000),
           @Ls_BateRecord_TEXT				   VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT		   VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			   VARCHAR(4000);
         
  DECLARE FcrNdnhUI_CUR INSENSITIVE CURSOR FOR
   SELECT u.Seq_IDNO,
          u.Rec_ID,
          u.TypeMatchNdnh_CODE,
          u.StateTerr_CODE,
          u.LocSourceRespAgency_CODE,
          u.NameSendMatched_CODE,
          u.First_NAME,
          u.Middle_NAME,
          u.Last_NAME,
          u.FirstAddl1_NAME,
          u.MiddleAddl1_NAME,
          u.LastAddl1_NAME,
          u.FirstAddl2_NAME,
          u.MiddleAddl2_NAME,
          u.LastAddl2_NAME,
          u.NameReturned_CODE,
          u.FirstReturned_NAME,
          u.MiddleReturned_NAME,
          u.LastReturned_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(u.MemberReturnedSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE u.MemberReturnedSsn_NUMB
          END AS MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(u.MemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE u.MemberMci_IDNO
          END AS MemberMci_IDNO,
          u.UserField_NAME,
          u.CountyFips_CODE,
          u.LocateRequestType_CODE,
          u.AddressFormat_CODE,
          u.OfAddress_DATE,
          u.LocResponse_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(u.CorrectedMultiSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE u.CorrectedMultiSsn_NUMB
          END AS CorrectedMultiSsn_NUMB,
          u.Employer_NAME,
          LTRIM(RTRIM(u.Line1_ADDR)) AS Line1_ADDR,
          LTRIM(RTRIM(u.Line2_ADDR)) AS Line2_ADDR,
          LTRIM(RTRIM(u.City_ADDR)) AS City_ADDR,
          LTRIM(RTRIM(u.State_ADDR)) AS State_ADDR,
          LTRIM(RTRIM(u.Zip_ADDR)) AS Zip_ADDR,
          LTRIM(RTRIM(u.ForeignCountry_CODE)) AS ForeignCountry_CODE,
          u.ForeignCountry_NAME,
          u.AddrScrub1_CODE,
          u.AddrScrub2_CODE,
          u.AddrScrub3_CODE,
          u.StateReporting_CODE,
          LTRIM(RTRIM(u.Benefit_AMNT)) AS Benefit_AMNT,
          u.SsnMatch_CODE,
          u.QtrReporting_CODE,
          u.TypeParticipant_CODE,
          u.StateSort_CODE,
          u.Normalization_CODE
     FROM LFNUI_Y1 u
    WHERE u.Process_INDC = 'N'
    ORDER BY Seq_IDNO;
    
  DECLARE @Ln_FcrNdnhUiCur_Seq_IDNO                 NUMERIC(19),
          @Lc_FcrNdnhUiCur_Rec_ID                   CHAR(2),
          @Lc_FcrNdnhUiCur_TypeMatchNdnh_CODE       CHAR(1),
          @Lc_FcrNdnhUiCur_StateTerr_CODE           CHAR(2),
          @Lc_FcrNdnhUiCur_LocSourceRespAgency_CODE CHAR(3),
          @Lc_FcrNdnhUiCur_NameSendMatched_CODE     CHAR(1),
          @Lc_FcrNdnhUiCur_First_NAME               CHAR(16),
          @Lc_FcrNdnhUiCur_Middle_NAME              CHAR(16),
          @Lc_FcrNdnhUiCur_Last_NAME                CHAR(30),
          @Lc_FcrNdnhUiCur_FirstAddl1_NAME          CHAR(16),
          @Lc_FcrNdnhUiCur_MiAddl1_NAME             CHAR(16),
          @Lc_FcrNdnhUiCur_LastAddl1_NAME           CHAR(30),
          @Lc_FcrNdnhUiCur_FirstAddl2_NAME          CHAR(16),
          @Lc_FcrNdnhUiCur_MiAddl2_NAME             CHAR(16),
          @Lc_FcrNdnhUiCur_LastAddl2_NAME           CHAR(30),
          @Lc_FcrNdnhUiCur_NameReturned_CODE        CHAR(1),
          @Lc_FcrNdnhUiCur_FirstReturned_NAME       CHAR(16),
          @Lc_FcrNdnhUiCur_MiReturned_NAME          CHAR(16),
          @Lc_FcrNdnhUiCur_LastReturned_NAME        CHAR(30),
          @Lc_FcrNdnhUiCur_MemberSsnNumb_TEXT       CHAR(9),
          @Lc_FcrNdnhUiCur_MemberMciIdno_TEXT       CHAR(10),
          @Lc_FcrNdnhUiCur_UserField_NAME           CHAR(15),
          @Lc_FcrNdnhUiCur_CountyFips_CODE          CHAR(3),
          @Lc_FcrNdnhUiCur_LocateRequestType_CODE   CHAR(2),
          @Lc_FcrNdnhUiCur_AddressFormat_CODE       CHAR(1),
          @Lc_FcrNdnhUiCur_OfAddress_DATE           CHAR(8),
          @Lc_FcrNdnhUiCur_LocResponse_CODE         CHAR(2),
          @Lc_FcrNdnhUiCur_CorrectedMultiSsnNumb_TEXT CHAR(9),
          @Ls_FcrNdnhUiCur_Employer_NAME            VARCHAR(45),
          @Ls_FcrNdnhUiCur_Line1_ADDR               VARCHAR(50),
          @Ls_FcrNdnhUiCur_Line2_ADDR               VARCHAR(50),
          @Lc_FcrNdnhUiCur_City_ADDR                CHAR(28),
          @Lc_FcrNdnhUiCur_State_ADDR               CHAR(2),
          @Lc_FcrNdnhUiCur_Zip_ADDR                 CHAR(10),
          @Lc_FcrNdnhUiCur_ForeignCountry_CODE      CHAR(2),
          @Lc_FcrNdnhUiCur_ForeignCountry_NAME      CHAR(25),
          @Lc_FcrNdnhUiCur_AddrScrub1_CODE          CHAR(2),
          @Lc_FcrNdnhUiCur_AddrScrub2_CODE          CHAR(2),
          @Lc_FcrNdnhUiCur_AddrScrub3_CODE          CHAR(2),
          @Lc_FcrNdnhUiCur_StateReporting_CODE      CHAR(2),
          @Lc_FcrNdnhUiCur_Benefit_AMNT             CHAR(11),
          @Lc_FcrNdnhUiCur_SsnMatch_CODE            CHAR(1),
          @Lc_FcrNdnhUiCur_QtrReporting_CODE        CHAR(5),
          @Lc_FcrNdnhUiCur_TypeParticipant_CODE     CHAR(2),
          @Lc_FcrNdnhUiCur_StateSort_CODE           CHAR(2),
          @Lc_FcrNdnhUiCur_Normalization_CODE       CHAR(1),
          
          @Ln_FcrNdnhUiCur_MemberSsn_NUMB           NUMERIC(9),
          @Ln_FcrNdnhUiCur_MemberMci_IDNO			NUMERIC(10);

  BEGIN TRY
   BEGIN TRANSACTION NDNHUI_DETAILS;

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
   
   OPEN FcrNdnhUI_CUR;

   SET @Ls_Sql_TEXT = 'FETCH CURSOR FcrNdnhUI_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM FcrNdnhUI_CUR INTO @Ln_FcrNdnhUiCur_Seq_IDNO, @Lc_FcrNdnhUiCur_Rec_ID, @Lc_FcrNdnhUiCur_TypeMatchNdnh_CODE, @Lc_FcrNdnhUiCur_StateTerr_CODE, @Lc_FcrNdnhUiCur_LocSourceRespAgency_CODE, @Lc_FcrNdnhUiCur_NameSendMatched_CODE, @Lc_FcrNdnhUiCur_First_NAME, @Lc_FcrNdnhUiCur_Middle_NAME, @Lc_FcrNdnhUiCur_Last_NAME, @Lc_FcrNdnhUiCur_FirstAddl1_NAME, @Lc_FcrNdnhUiCur_MiAddl1_NAME, @Lc_FcrNdnhUiCur_LastAddl1_NAME, @Lc_FcrNdnhUiCur_FirstAddl2_NAME, @Lc_FcrNdnhUiCur_MiAddl2_NAME, @Lc_FcrNdnhUiCur_LastAddl2_NAME, @Lc_FcrNdnhUiCur_NameReturned_CODE, @Lc_FcrNdnhUiCur_FirstReturned_NAME, @Lc_FcrNdnhUiCur_MiReturned_NAME, @Lc_FcrNdnhUiCur_LastReturned_NAME, @Lc_FcrNdnhUiCur_MemberSsnNumb_TEXT, @Lc_FcrNdnhUiCur_MemberMciIdno_TEXT, @Lc_FcrNdnhUiCur_UserField_NAME, @Lc_FcrNdnhUiCur_CountyFips_CODE, @Lc_FcrNdnhUiCur_LocateRequestType_CODE, @Lc_FcrNdnhUiCur_AddressFormat_CODE, @Lc_FcrNdnhUiCur_OfAddress_DATE, @Lc_FcrNdnhUiCur_LocResponse_CODE, @Lc_FcrNdnhUiCur_CorrectedMultiSsnNumb_TEXT, @Ls_FcrNdnhUiCur_Employer_NAME, @Ls_FcrNdnhUiCur_Line1_ADDR, @Ls_FcrNdnhUiCur_Line2_ADDR, @Lc_FcrNdnhUiCur_City_ADDR, @Lc_FcrNdnhUiCur_State_ADDR, @Lc_FcrNdnhUiCur_Zip_ADDR, @Lc_FcrNdnhUiCur_ForeignCountry_CODE, @Lc_FcrNdnhUiCur_ForeignCountry_NAME, @Lc_FcrNdnhUiCur_AddrScrub1_CODE, @Lc_FcrNdnhUiCur_AddrScrub2_CODE, @Lc_FcrNdnhUiCur_AddrScrub3_CODE, @Lc_FcrNdnhUiCur_StateReporting_CODE, @Lc_FcrNdnhUiCur_Benefit_AMNT, @Lc_FcrNdnhUiCur_SsnMatch_CODE, @Lc_FcrNdnhUiCur_QtrReporting_CODE, @Lc_FcrNdnhUiCur_TypeParticipant_CODE, @Lc_FcrNdnhUiCur_StateSort_CODE, @Lc_FcrNdnhUiCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process NDNH UI records from FCR
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
	 SAVE TRANSACTION SAVENDNHUI_DETAILS;
    
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Ln_Exists_NUMB = 0;
     
     IF ISNUMERIC (@Lc_FcrNdnhUiCur_MemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhUiCur_MemberSsn_NUMB = @Lc_FcrNdnhUiCur_MemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhUiCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrNdnhUiCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrNdnhUiCur_MemberMci_IDNO = @Lc_FcrNdnhUiCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNdnhUiCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
	
	 SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
	 SET @Ls_BateRecord_TEXT = ' Rec_ID: ' + ISNULL(@Lc_FcrNdnhUiCur_Rec_ID, '') + ' TypeMatchNdnh_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_TypeMatchNdnh_CODE, '') + ' StateTerr_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_StateTerr_CODE, '') + ' LocSourceRespAgency_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_LocSourceRespAgency_CODE, '') + ' NameSendMatched_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_NameSendMatched_CODE, '') + ' First_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_First_NAME, '') + ' Middle_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_Middle_NAME, '') + ' Last_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_Last_NAME, '') + ' FirstAddl1_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_FirstAddl1_NAME, '') + ' MiAddl1_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_MiAddl1_NAME, '') + ' LastAddl1_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_LastAddl1_NAME, '') + ' FirstAddl2_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_FirstAddl2_NAME, '') + ' MiAddl2_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_MiAddl2_NAME, '') + ' LastAddl2_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_LastAddl2_NAME, '') + ' NameReturned_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_NameReturned_CODE, '') + ' FirstReturned_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_FirstReturned_NAME, '') + ' MiReturned_NAME: ' + ISNULL (@Lc_FcrNdnhUiCur_MiReturned_NAME, '') + ' LastReturned_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_LastReturned_NAME, '') + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' UserField_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_UserField_NAME, '') + ' CountyFips_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_CountyFips_CODE, '') + ' LocateRequestType_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_LocateRequestType_CODE, '') + ' AddressFormat_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_AddressFormat_CODE, '') + ' OfAddress_DATE: ' + ISNULL(@Lc_FcrNdnhUiCur_OfAddress_DATE, '') + ' LocResponse_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_LocResponse_CODE, '') + ' CorrectedMultiSsn_NUMB: ' + ISNULL(@Lc_FcrNdnhUiCur_CorrectedMultiSsnNumb_TEXT, 0) + ' Employer_NAME: ' + ISNULL(@Ls_FcrNdnhUiCur_Employer_NAME, '') + ' Line1_ADDR: ' + ISNULL(@Ls_FcrNdnhUiCur_Line1_ADDR, '') + ' Line2_ADDR: ' + ISNULL(@Ls_FcrNdnhUiCur_Line2_ADDR, '') + ' City_ADDR: ' + ISNULL(@Lc_FcrNdnhUiCur_City_ADDR, '') + ' State_ADDR: ' + ISNULL(@Lc_FcrNdnhUiCur_State_ADDR, '') + ' Zip_ADDR: ' + ISNULL(@Lc_FcrNdnhUiCur_Zip_ADDR, '') + ' ForeignCountry_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_ForeignCountry_CODE, '') + ' ForeignCountry_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_ForeignCountry_NAME, '') + ' AddrScrub1_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_AddrScrub1_CODE, '') + ' AddrScrub2_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_AddrScrub2_CODE, '') + ' AddrScrub3_CODE: ' + ISNULL (@Lc_FcrNdnhUiCur_AddrScrub3_CODE, '') + ' StateReporting_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_StateReporting_CODE, '') + ' Benefit_AMNT: ' + ISNULL(@Lc_FcrNdnhUiCur_Benefit_AMNT, '') + ' SsnMatch_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_SsnMatch_CODE, '') + ' QtrReporting_CODE: ' + ISNULL (@Lc_FcrNdnhUiCur_QtrReporting_CODE, '') + ' TypeParticipant_CODE: ' + ISNULL (@Lc_FcrNdnhUiCur_TypeParticipant_CODE, '') + ' StateSort_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_StateSort_CODE, '') + ' Normalization_CODE: ' + ISNULL(@Lc_FcrNdnhUiCur_Normalization_CODE, '');
	 SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrNdnhUiCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
     SET @Ln_Exists_NUMB = 0;	
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' CaseMemberStatus_CODE = A';
          
     --check for existance of id_member
    
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrNdnhUiCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'GET MemberMci_IDNO';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrNdnhUiCur_Last_NAME, '');
              
       SELECT DISTINCT
              @Ln_MemberMci_IDNO = m.MemberMci_IDNO
         FROM DEMO_Y1 d,
              MSSN_Y1 m
        WHERE m.MemberSsn_NUMB = @Ln_FcrNdnhUiCur_MemberSsn_NUMB
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE
          AND d.MemberMci_IDNO = m.MemberMci_IDNO
          AND UPPER (SUBSTRING (d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrNdnhUiCur_Last_NAME, 1, 5);

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
       
       SET @Ln_MemberMci_IDNO = @Ln_FcrNdnhUiCur_MemberMci_IDNO;
      END
     
     SET @Ls_Sql_TEXT = 'CHECKING UI LOCATE RESPONSE CODES';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);

     IF @Lc_FcrNdnhUiCur_NameSendMatched_CODE IN (@Lc_NameSendMatch1_CODE, @Lc_NameSendMatch2_CODE, @Lc_NameSendMatch3_CODE)
        AND @Lc_FcrNdnhUiCur_LocResponse_CODE IN (@Lc_LocResp39_CODE, @Lc_LocResp46_CODE, @Lc_LocRespSpace_CODE)
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE 2';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Line1_ADDR = ' + ISNULL(@Ls_FcrNdnhUiCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL (@Ls_FcrNdnhUiCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrNdnhUiCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrNdnhUiCur_State_ADDR, '');

       EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
        @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
        @Ad_Run_DATE                         = @Ad_Run_DATE,
        @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
        @Ad_Begin_DATE                       = @Ad_Run_DATE,
        @Ad_End_DATE                         = @Ld_High_DATE,
        @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
        @As_Line1_ADDR                       = @Ls_FcrNdnhUiCur_Line1_ADDR,
        @As_Line2_ADDR                       = @Ls_FcrNdnhUiCur_Line2_ADDR,
        @Ac_City_ADDR                        = @Lc_FcrNdnhUiCur_City_ADDR,
        @Ac_State_ADDR                       = @Lc_FcrNdnhUiCur_State_ADDR,
        @Ac_Zip_ADDR                         = @Lc_FcrNdnhUiCur_Zip_ADDR,
        @Ac_Country_ADDR                     = @Lc_FcrNdnhUiCur_ForeignCountry_NAME,
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
        @Ac_Normalization_CODE               = @Lc_FcrNdnhUiCur_Normalization_CODE,
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
	  
       SET @Ls_Sql_TEXT = 'SLECT_VOTHP_UIB_DE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeOthp_CODE = ' + ISNULL (@Lc_TypeOthpUnemplAgency_CODE, '') + ', ReferenceOthp_IDNO = ' + ISNULL(@Lc_FcrNdnhUiCur_StateReporting_CODE, '');
	   	   
       IF @Lc_FcrNdnhUiCur_StateReporting_CODE = @Lc_InStateFips_CODE
        BEGIN
         
         SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
           FROM OTHP_Y1 o
          WHERE o.TypeOthp_CODE = @Lc_TypeOthpUnemplAgency_CODE
            AND o.State_ADDR = @Lc_StateInState_CODE
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;
         
         IF @Li_RowCount_QNTY = 0
          BEGIN
           --Record not found in OTHP'
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0540_CODE;

           GOTO lx_exception;
          END
        END
       ELSE
        BEGIN
         
         SET @Ls_Sql_TEXT = 'OTHP TABLE READ FOR OTHP ID NUMBER';
         SET @Ls_Sqldata_TEXT = 'TypeAgency_CODE = ' + ISNULL(@Lc_TypeOthpUnemplAgency_CODE, '') + ', ReferenceOthp_IDNO = ' + ISNULL(@Lc_FcrNdnhUiCur_StateReporting_CODE, '');
         SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
           FROM OTHP_Y1 o
          WHERE o.TypeOthp_CODE = @Lc_TypeOthpUnemplAgency_CODE
            AND o.ReferenceOthp_IDNO LIKE ISNULL(@Lc_FcrNdnhUiCur_StateReporting_CODE, '') + '%'
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
          BEGIN
           --Record not found in OTHP'
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0540_CODE;

           GOTO lx_exception;
          END
        END
       
       SET @Ln_Benefit_AMNT = dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN(@Lc_FcrNdnhUiCur_Benefit_AMNT) / 100;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);
            
       EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
        @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
        @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
        @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
        @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE, 
        @Ad_Status_DATE                = @Ad_Run_DATE,
        @Ac_TypeIncome_CODE            = @Lc_IncomeTypeUi_CODE,
        @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, 
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @Ad_BeginEmployment_DATE       = NULL,
        @Ad_EndEmployment_DATE         = @Ld_High_DATE,
        @An_IncomeGross_AMNT           = @Ln_Benefit_AMNT,
        @An_IncomeNet_AMNT             = 0,
        @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
        @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
        @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
        @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
        @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
        @Ac_SourceLoc_CODE             = @Lc_LocateSourceNdh_CODE,
        @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
        @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
        @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
        @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
        @An_CostInsurance_AMNT         = 0,
        @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
        @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
        @Ac_SignedonWorker_ID          = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB   = 0,
        @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
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
     ELSE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1177_CODE;

       GOTO lx_exception;
      END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
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
	   	   ROLLBACK TRANSACTION SAVENDNHUI_DETAILS;
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
     SET @Ls_Sql_TEXT = 'UPDATE LFNUI_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrNdnhUiCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LFNUI_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrNdnhUiCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFSDE_Y1';
    
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK';
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
         SET @Ls_DescriptionError_TEXT = 'BATCH RESTART UPDATE FAILED ';
         
         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION NDNHUI_DETAILS; 
       BEGIN TRANSACTION NDNHUI_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION NDNHUI_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');
      
       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrNdnhUI_CUR INTO @Ln_FcrNdnhUiCur_Seq_IDNO, @Lc_FcrNdnhUiCur_Rec_ID, @Lc_FcrNdnhUiCur_TypeMatchNdnh_CODE, @Lc_FcrNdnhUiCur_StateTerr_CODE, @Lc_FcrNdnhUiCur_LocSourceRespAgency_CODE, @Lc_FcrNdnhUiCur_NameSendMatched_CODE, @Lc_FcrNdnhUiCur_First_NAME, @Lc_FcrNdnhUiCur_Middle_NAME, @Lc_FcrNdnhUiCur_Last_NAME, @Lc_FcrNdnhUiCur_FirstAddl1_NAME, @Lc_FcrNdnhUiCur_MiAddl1_NAME, @Lc_FcrNdnhUiCur_LastAddl1_NAME, @Lc_FcrNdnhUiCur_FirstAddl2_NAME, @Lc_FcrNdnhUiCur_MiAddl2_NAME, @Lc_FcrNdnhUiCur_LastAddl2_NAME, @Lc_FcrNdnhUiCur_NameReturned_CODE, @Lc_FcrNdnhUiCur_FirstReturned_NAME, @Lc_FcrNdnhUiCur_MiReturned_NAME, @Lc_FcrNdnhUiCur_LastReturned_NAME, @Lc_FcrNdnhUiCur_MemberSsnNumb_TEXT, @Lc_FcrNdnhUiCur_MemberMciIdno_TEXT, @Lc_FcrNdnhUiCur_UserField_NAME, @Lc_FcrNdnhUiCur_CountyFips_CODE, @Lc_FcrNdnhUiCur_LocateRequestType_CODE, @Lc_FcrNdnhUiCur_AddressFormat_CODE, @Lc_FcrNdnhUiCur_OfAddress_DATE, @Lc_FcrNdnhUiCur_LocResponse_CODE, @Lc_FcrNdnhUiCur_CorrectedMultiSsnNumb_TEXT, @Ls_FcrNdnhUiCur_Employer_NAME, @Ls_FcrNdnhUiCur_Line1_ADDR, @Ls_FcrNdnhUiCur_Line2_ADDR, @Lc_FcrNdnhUiCur_City_ADDR, @Lc_FcrNdnhUiCur_State_ADDR, @Lc_FcrNdnhUiCur_Zip_ADDR, @Lc_FcrNdnhUiCur_ForeignCountry_CODE, @Lc_FcrNdnhUiCur_ForeignCountry_NAME, @Lc_FcrNdnhUiCur_AddrScrub1_CODE, @Lc_FcrNdnhUiCur_AddrScrub2_CODE, @Lc_FcrNdnhUiCur_AddrScrub3_CODE, @Lc_FcrNdnhUiCur_StateReporting_CODE, @Lc_FcrNdnhUiCur_Benefit_AMNT, @Lc_FcrNdnhUiCur_SsnMatch_CODE, @Lc_FcrNdnhUiCur_QtrReporting_CODE, @Lc_FcrNdnhUiCur_TypeParticipant_CODE, @Lc_FcrNdnhUiCur_StateSort_CODE, @Lc_FcrNdnhUiCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrNdnhUI_CUR;

   DEALLOCATE FcrNdnhUI_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   
   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';

   COMMIT TRANSACTION NDNHUI_DETAILS;
  END TRY

  BEGIN CATCH
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrNdnhUI_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrNdnhUI_CUR;

     DEALLOCATE FcrNdnhUI_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NDNHUI_DETAILS;
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
