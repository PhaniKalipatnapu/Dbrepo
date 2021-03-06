/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_FPLS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_FPLS_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the FPLS details from the temporary table LOAD_FCR_LOCATE_FPLS_DETAILS
                       and update the member's address and Date of Death Information in the system.
                       In addition, the member's employment information in EHIS_Y1 will also be updated
Frequency			 : Daily
Developed On		 : 04/08/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On		     : BATCH_LOC_INCOMING_FCR$SP_GET_FORMATTED_ADDRESS
					   BATCH_COMMON$SP_GET_OTHP 
					   BATCH_COMMON$SP_EMPLOYER_UPDATE
					   BATCH_COMMON$SP_ADDRESS_UPDATE
					   BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
					   BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
					   BATCH_COMMON$SP_INSERT_ACTIVITY
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_INSERT_PENDING_REQUEST
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE 
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_FPLS_DETAILS]
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

  DECLARE  @Lc_StatusCaseMemberActive_CODE			CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE			CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE					CHAR(1) = 'F',
           @Lc_Yes_INDC								CHAR(1) = 'Y',
           @Lc_ProcessY_INDC						CHAR(1) = 'Y',
           @Lc_Mailing_ADDR							CHAR(1) = 'M',
           @Lc_VerificationStatusPending_CODE		CHAR(1) = 'P',
           @Lc_RelationshipCaseNcp_TEXT				CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_TEXT		CHAR(1) = 'P',
           @Lc_RelationshipCaseClient_TEXT			CHAR(1) = 'C',
           @Lc_CaseStatusOpen_CODE					CHAR(1) = 'O',
           @Lc_ErrorTypeError_CODE					CHAR(1) = 'E',
           @Lc_StatusSuccess_CODE					CHAR(1) = 'S',
           @Lc_AddressEmployer_INDC					CHAR(1) = '1',
           @Lc_StatusEmploymentActive_CODE			CHAR(1) = 'A',
           @Lc_StatusEmploymentVacation_CODE		CHAR(1) = 'V',
           @Lc_AddressEmployee_INDC					CHAR(1) = '2',
           @Lc_TypeOthpEmployer_CODE				CHAR(1) = 'E',
           @Lc_ActionP1_CODE						CHAR(1) = 'P',
           @Lc_MemberAddress_INDC					CHAR(1) = 'N',
           @Lc_Employment_INDC						CHAR(1) = 'N',
           @Lc_Note_INDC							CHAR(1) = 'N',
           @Lc_IncomeTypeEmployer_CODE				CHAR(2) = 'EM',
           @Lc_LocResp39_CODE						CHAR(2) = '39',
           @Lc_LocResp30_CODE						CHAR(2) = '30',
           @Lc_LocResp40_CODE						CHAR(2) = '40',
           @Lc_LocResp02_CODE						CHAR(2) = '02',
           @Lc_LocResp05_CODE						CHAR(2) = '05',
           @Lc_SourceFedcaseregistr_CODE			CHAR(3) = 'FCR',
           @Lc_LocRespAgencyDod_TEXT				CHAR(3) = 'A01',
           @Lc_LocRespAgencyFbi_TEXT				CHAR(3) = 'A02',
           @Lc_LocRespAgencyNsa_TEXT                CHAR(3) = 'A03',
           @Lc_LocRespAgencyFederal_TEXT			CHAR(3) = 'B01',
           @Lc_LocRespAgencyIrs_TEXT				CHAR(3) = 'C01',
           @Lc_LocRespAgencyMember_TEXT				CHAR(3) = 'E03',
           @Lc_LocRespAgencyDva_TEXT				CHAR(3) = 'F01',
           @Lc_LocateSourceFpl_CODE					CHAR(3) = 'FPL',
           @Lc_SourceVerifiedEmp_CODE				CHAR(3) = 'EMP',
           @Lc_SubsystemLoc_CODE					CHAR(3) = 'LO',
           @Lc_FunctionMsc_CODE						CHAR(3) = 'MSC',
           @Lc_MajorActivityCase_CODE				CHAR(4) = 'CASE',
           @Lc_Value_CODE							CHAR(5) = 'N',
           @Lc_ErrorE0058_CODE						CHAR(5) = 'E0058',
           @Lc_ErrorE0145_CODE						CHAR(5) = 'E0145',
           @Lc_ErrorE0907_CODE						CHAR(5) = 'E0907',
           @Lc_ErrorE1089_CODE                      CHAR(5) = 'E1089',
           @Lc_ErrorE1176_CODE						CHAR(5) = 'E1176',
           @Lc_ErrorE1175_CODE						CHAR(5) = 'E1175',
           @Lc_ErrorE0620_CODE						CHAR(5) = 'E0620',
           @Lc_BateErrorE1424_CODE					CHAR(5) = 'E1424',
           @Lc_MinorActivityLuapd_CODE				CHAR(5) = 'LUAPD',
           @Lc_MinorActivityRrfcr_CODE			    CHAR(5) = 'RRFCR',
           @Lc_ReasonLuapd_CODE						CHAR(5) = 'LUAPD',
           @Lc_BateError_CODE						CHAR(5) = ' ',
           @Lc_DateFormatYyyymmdd_TEXT				CHAR(8) = 'YYYYMMDD',
           @Lc_ProcessFcrFpls_ID					CHAR(8) = 'FCR_FPLS',
           @Lc_BatchRunUser_TEXT					CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME						VARCHAR(60) = 'SP_FPLS_DETAILS',
           @Ls_ErrordescFplsLoc_TEXT				VARCHAR(100) = 'LOCATE SOURCE RESP CODE -E01 - RESPONSE FROM SOCIAL SECURITY ADMINISTRATION',
           @Ld_High_DATE							DATE = '12/31/9999',
           @Ld_Low_DATE								DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB							NUMERIC(1) = 0,
           @Ln_Exists_NUMB							NUMERIC(2) = 0,
           @Ln_CommitFreq_QNTY						NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY				NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY			NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY		NUMERIC(6) = 0,
           @Ln_OtherParty_IDNO						NUMERIC(9) = 0,
           @Ln_Fein_IDNO							NUMERIC(9) = 0,
           @Ln_MemberSsn_NUMB						NUMERIC(9) = 0,
           @Ln_Cur_QNTY								NUMERIC(10,0),
           @Ln_MemberMci_IDNO						NUMERIC(10) = 0,
           @Ln_Topic_IDNO							NUMERIC(10) = 0,
           @Ln_EventFunctionalSeq_NUMB				NUMERIC(10) = 0,
           @Ln_Income_AMNT							NUMERIC(11,2) = 0,
           @Ln_Error_NUMB							NUMERIC(11),
           @Ln_ErrorLine_NUMB						NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB				NUMERIC(19),
           @Li_FetchStatus_QNTY						SMALLINT,
           @Li_RowCount_QNTY						SMALLINT,
           @Lc_Space_TEXT							CHAR(1) = '',
           @Lc_TypeError_CODE						CHAR(1) = '',
           @Lc_ActiveReserveDva_TEXT				CHAR(1)  = '',
           @Lc_Msg_CODE								CHAR(5),
           @Lc_IndStatusDod_CODE					CHAR(1),
           @Lc_IndApoPfoInd_TEXT					CHAR(1),
           @Lc_IndFbi_ADDR							CHAR(1),
           @Lc_HelthBenefitFbi_TEXT					CHAR(1),
           @Lc_StatusEmployerFbi_CODE				CHAR(1),
           @Lc_IndEmployerFbi_TEXT					CHAR(1),
           @Lc_IndFederal_ADDR						CHAR(1),
           @Lc_HelthBenefitFederal_TEXT				CHAR(1),
           @Lc_StatusEmployerFederal_CODE			CHAR(1),
           @Lc_IndEmployerFederal_TEXT				CHAR(1),
           @Lc_Ind2ndIrs_NAME						CHAR(1),
           @Lc_IndBenefitDva_TEXT					CHAR(1),
           @Lc_IndSuspenseDva_TEXT					CHAR(1),
           @Lc_IndIncarceDva_TEXT					CHAR(1),
           @Lc_IndRetPayDva_TEXT					CHAR(1),
           @Lc_LocRespSpace_CODE					CHAR(2) = '',
           @Lc_Temp4_TEXT							CHAR(2),
           @Lc_Country_ADDR							CHAR(2),
           @Lc_AgencyDod_CODE						CHAR(4),
           @Lc_DodPaygrade_CODE						CHAR(4),
           @Lc_SubmittingOficeDod_TEXT				CHAR(4),
           @Lc_YearTaxIrs_TEXT						CHAR(4),
           @Lc_AmountSalaryDod_TEXT					CHAR(6),
           @Lc_ControlIrs_NAME						CHAR(6),
           @Lc_AmountBenefitMember_TEXT				CHAR(6),
           @Lc_AmountOfAwardDva_TEXT				CHAR(6),
           @Lc_AmountSalaryFbi_TEXT					CHAR(7),
           @Lc_AmountSalaryFederal_TEXT				CHAR(7),
           @Lc_DateBirthDod_TEXT					CHAR(8),
           @Lc_DateEmpTermFbi_TEXT					CHAR(8),
           @Lc_DateDodFbi_TEXT						CHAR(8),
           @Lc_DateDohFbi_TEXT						CHAR(8),
           @Lc_DateEmpTermFederal_TEXT				CHAR(8),
           @Lc_DateDodFederal_TEXT					CHAR(8),
           @Lc_DateDohFederal_TEXT					CHAR(8),
           @Lc_DodMember_TEXT						CHAR(8),
           @Lc_DodDva_TEXT							CHAR(8),
           @Lc_DateEfftDva_TEXT						CHAR(8),
           @Lc_AgcyReportingFederal_TEXT			CHAR(9),
           @Lc_FeinFederal_IDNO						CHAR(9),
           @Lc_FeinNsa_IDNO						    CHAR(9),
           @Lc_MemberSsnIrs_TEXT					CHAR(9),
           @Lc_Temp5_TEXT							CHAR(10),
           @Lc_Temp3_TEXT							CHAR(28),
           @Ls_Temp_TEXT							VARCHAR(50),
           @Ls_Temp2_TEXT							VARCHAR(50),
           @Ls_Irs2_NAME							VARCHAR(62),
           @Ls_Sql_TEXT								VARCHAR(100),
           @Ls_CursorLoc_TEXT						VARCHAR(200),
           @Ls_Sqldata_TEXT							VARCHAR(1000),
           @Ls_BateRecord_TEXT						VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT					VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT				VARCHAR(4000),
           @Ls_DescriptionRecord_TEXT				VARCHAR(4000),
           @Ld_BeginEmployment_DATE					DATE,
           @Ld_Deceased_DATE						DATE,
           @Ld_Birth_DATE							DATE,
           @Ld_DeceasedFpls_DATE					DATE,
           @Ld_BirthFpls_DATE						DATE,
           @Ld_TempBirthFpls_DATE					DATE,
           @Ld_TempDeathFpls_DATE					DATE,
           @Ld_Update_DTTM							DATETIME2;

  DECLARE @Ln_FcrFplsLocCur_Seq_IDNO                NUMERIC(19),
          @Lc_FcrFplsLocCur_Rec_ID                  CHAR(2),
          @Lc_FcrFplsLocCur_StateTerr_CODE          CHAR(2),
          @Lc_FcrFplsLocCur_LocSourceResp_CODE      CHAR(3),
          @Lc_FcrFplsLocCur_NameSent_CODE           CHAR(1),
          @Lc_FcrFplsLocCur_First_NAME              CHAR(16),
          @Lc_FcrFplsLocCur_Middle_NAME             CHAR(16),
          @Lc_FcrFplsLocCur_Last_NAME               CHAR(30),
          @Lc_FcrFplsLocCur_FirstAddl1_NAME         CHAR(16),
          @Lc_FcrFplsLocCur_MiAddl1_NAME            CHAR(16),
          @Lc_FcrFplsLocCur_LastAddl1_NAME          CHAR(30),
          @Lc_FcrFplsLocCur_FirstAddl2_NAME         CHAR(16),
          @Lc_FcrFplsLocCur_MiAddl2_NAME            CHAR(16),
          @Lc_FcrFplsLocCur_LastAddl2_NAME          CHAR(30),
          @Lc_FcrFplsLocCur_NameReturned_CODE       CHAR(1),
          @Ls_FcrFplsLocCur_Returned_NAME           VARCHAR(62),
          @Lc_FcrFplsLocCur_MemberSsnNumb_TEXT      CHAR(9),
          @Lc_FcrFplsLocCur_MemberMciIdno_TEXT      CHAR(10),
          @Lc_FcrFplsLocCur_UserField_NAME          CHAR(15),
          @Lc_FcrFplsLocCur_CountyFips_CODE         CHAR(3),
          @Lc_FcrFplsLocCur_LocReqType_CODE         CHAR(2),
          @Lc_FcrFplsLocCur_AddrLocDate_CODE        CHAR(1),
          @Lc_FcrFplsLocCur_LocAddress_DATE         CHAR(8),
          @Lc_FcrFplsLocCur_LocStatusResp_CODE      CHAR(2),
          @Ls_FcrFplsLocCur_Employer_NAME           VARCHAR(45),
          @Lc_FcrFplsLocCur_AddrFormat_INDC         CHAR(1),
          @Ls_FcrFplsLocCur_Returned_ADDR           VARCHAR(234),
          @Lc_FcrFplsLocCur_AddrScrub1_CODE         CHAR(2),
          @Lc_FcrFplsLocCur_AddrScrub2_CODE         CHAR(2),
          @Lc_FcrFplsLocCur_AddrScrub3_CODE         CHAR(2),
          @Ls_FcrFplsLocCur_FcrDodData_TEXT         VARCHAR(212),
          @Lc_FcrFplsLocCur_FcrReservedFuture1_CODE CHAR(2),
          @Lc_FcrFplsLocCur_FcrReservedFuture2_CODE CHAR(2),
          @Lc_FcrFplsLocCur_FcrReservedFuture3_CODE CHAR(2),
          @Lc_FcrFplsLocCur_FcrSortState_CODE       CHAR(2),
          @Ls_FcrFplsLocCur_Line1_ADDR              VARCHAR(50),
          @Ls_FcrFplsLocCur_Line2_ADDR              VARCHAR(50),
          @Lc_FcrFplsLocCur_City_ADDR               CHAR(28),
          @Lc_FcrFplsLocCur_State_ADDR              CHAR(2),
          @Lc_FcrFplsLocCur_Zip_ADDR                CHAR(15),
          @Lc_FcrFplsLocCur_Normalization_CODE      CHAR(1),
          
          @Ln_CaseMemberCur_Case_IDNO               NUMERIC(6),
          @Ln_FcrFplsLocCur_MemberSsn_NUMB			NUMERIC(9),
          @Ln_FcrFplsLocCur_MemberMci_IDNO			NUMERIC(10);
  DECLARE FcrFplsLoc_CUR INSENSITIVE CURSOR FOR
   SELECT f.Seq_IDNO,
          f.Rec_ID,
          f.StateTerr_CODE,
          LTRIM(RTRIM(f.LocSourceResp_CODE)) AS LocSourceResp_CODE,
          f.NameSent_CODE,
          f.First_NAME,
          f.Middle_NAME,
          f.Last_NAME,
          f.FirstAddl1_NAME,
          f.MiddleAddl1_NAME,
          f.LastAddl1_NAME,
          f.FirstAddl2_NAME,
          f.MiddleAddl2_NAME,
          f.LastAddl2_NAME,
          f.NameReturned_CODE,
          f.Returned_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(f.MemberSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE f.MemberSsn_NUMB
          END AS MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(f.MemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE f.MemberMci_IDNO
          END AS MemberMci_IDNO,
          f.UserField_NAME,
          f.CountyFips_CODE,
          f.LocReqType_CODE,
          LTRIM(RTRIM(f.AddrLocDate_CODE)) AS AddrLocDate_CODE,
          LTRIM(RTRIM(f.LocAddress_DATE)) AS LocAddress_DATE,
          f.LocStatusResp_CODE,
          f.Employer_NAME AS Employer_NAME,
          LTRIM(RTRIM(f.AddrLocFmt_CODE)) AS ind_addr_format,
          f.Returned_ADDR,
          f.AddrScrub1_CODE,
          f.AddrScrub2_CODE,
          f.AddrScrub3_CODE,
          f.FcrDodData_TEXT,
          f.FcrReservedFuture1_CODE,
          f.FcrReservedFuture2_CODE,
          f.FcrReservedFuture3_CODE,
          f.FcrSortState_CODE,
          f.Line1_ADDR,
          f.Line2_ADDR,
          f.City_ADDR,
          f.State_ADDR,
          f.Zip_ADDR,
          f.Normalization_CODE
     FROM LFLFP_Y1 f
    WHERE f.Process_INDC = 'N';
  
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
  
   BEGIN TRANSACTION FPLS_DETAILS;

   OPEN FcrFplsLoc_CUR;

   FETCH NEXT FROM FcrFplsLoc_CUR INTO @Ln_FcrFplsLocCur_Seq_IDNO, @Lc_FcrFplsLocCur_Rec_ID, @Lc_FcrFplsLocCur_StateTerr_CODE, @Lc_FcrFplsLocCur_LocSourceResp_CODE, @Lc_FcrFplsLocCur_NameSent_CODE, @Lc_FcrFplsLocCur_First_NAME, @Lc_FcrFplsLocCur_Middle_NAME, @Lc_FcrFplsLocCur_Last_NAME, @Lc_FcrFplsLocCur_FirstAddl1_NAME, @Lc_FcrFplsLocCur_MiAddl1_NAME, @Lc_FcrFplsLocCur_LastAddl1_NAME, @Lc_FcrFplsLocCur_FirstAddl2_NAME, @Lc_FcrFplsLocCur_MiAddl2_NAME, @Lc_FcrFplsLocCur_LastAddl2_NAME, @Lc_FcrFplsLocCur_NameReturned_CODE, @Ls_FcrFplsLocCur_Returned_NAME, @Lc_FcrFplsLocCur_MemberSsnNumb_TEXT, @Lc_FcrFplsLocCur_MemberMciIdno_TEXT, @Lc_FcrFplsLocCur_UserField_NAME, @Lc_FcrFplsLocCur_CountyFips_CODE, @Lc_FcrFplsLocCur_LocReqType_CODE, @Lc_FcrFplsLocCur_AddrLocDate_CODE, @Lc_FcrFplsLocCur_LocAddress_DATE, @Lc_FcrFplsLocCur_LocStatusResp_CODE, @Ls_FcrFplsLocCur_Employer_NAME, @Lc_FcrFplsLocCur_AddrFormat_INDC, @Ls_FcrFplsLocCur_Returned_ADDR, @Lc_FcrFplsLocCur_AddrScrub1_CODE, @Lc_FcrFplsLocCur_AddrScrub2_CODE, @Lc_FcrFplsLocCur_AddrScrub3_CODE, @Ls_FcrFplsLocCur_FcrDodData_TEXT, @Lc_FcrFplsLocCur_FcrReservedFuture1_CODE, @Lc_FcrFplsLocCur_FcrReservedFuture2_CODE, @Lc_FcrFplsLocCur_FcrReservedFuture3_CODE, @Lc_FcrFplsLocCur_FcrSortState_CODE, @Ls_FcrFplsLocCur_Line1_ADDR, @Ls_FcrFplsLocCur_Line2_ADDR, @Lc_FcrFplsLocCur_City_ADDR, @Lc_FcrFplsLocCur_State_ADDR, @Lc_FcrFplsLocCur_Zip_ADDR, @Lc_FcrFplsLocCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Process fpls records from FCR
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
	 SAVE TRANSACTION SAVEFPLS_DETAILS;
   
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Ln_Exists_NUMB = 0;
     SET @Lc_MemberAddress_INDC = @Lc_Value_CODE;
     SET @Lc_Employment_INDC = @Lc_Value_CODE;
     SET @Ln_Income_AMNT = 0;
     SET @Lc_DateDodFbi_TEXT = @Lc_Space_TEXT;
     SET @Lc_TypeError_CODE  = @Lc_Space_TEXT;
     SET @Lc_BateError_CODE =  @Lc_Space_TEXT;
     SET @Lc_DateDodFederal_TEXT = @Lc_Space_TEXT;
     SET @Lc_DodMember_TEXT = @Lc_Space_TEXT;
     SET @Lc_DodDva_TEXT = @Lc_Space_TEXT;
     SET @Lc_DateBirthDod_TEXT = @Lc_Space_TEXT;
     SET @Ld_BeginEmployment_DATE = @Lc_Space_TEXT;
     SET @Ln_Fein_IDNO = @Ln_Zero_NUMB;
               
     IF ISNUMERIC (@Lc_FcrFplsLocCur_MemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrFplsLocCur_MemberSsn_NUMB = @Lc_FcrFplsLocCur_MemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrFplsLocCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrFplsLocCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrFplsLocCur_MemberMci_IDNO = @Lc_FcrFplsLocCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrFplsLocCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
     
     SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrFplsLocCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), 0);
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcrFplsLocCur_Rec_ID, '') + ', StateTerr_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_StateTerr_CODE, '') + ', LocSourceResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocSourceResp_CODE, '') + ', NameSent_CODE = ' + ISNULL (@Lc_FcrFplsLocCur_NameSent_CODE, '') + ', First_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_Middle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_Last_NAME, '') + ', FirstAddl1_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_FirstAddl1_NAME, '') + ', MiAddl1_NAME = ' + ISNULL (@Lc_FcrFplsLocCur_MiAddl1_NAME, '') + ', LastAddl1_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_LastAddl1_NAME, '') + ', FirstAddl2_NAME = ' + ISNULL (@Lc_FcrFplsLocCur_FirstAddl2_NAME, '') + ', MiAddl2_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_MiAddl2_NAME, '') + ', LastAddl2_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_LastAddl2_NAME, '') + ', NameReturned_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_NameReturned_CODE, '') + ', Returned_NAME = ' + ISNULL(@Ls_FcrFplsLocCur_Returned_NAME, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', UserField_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_UserField_NAME, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_CountyFips_CODE, '') + ', LocReqType_CODE = ' + ISNULL (@Lc_FcrFplsLocCur_LocReqType_CODE, '') + ', AddrLocDate_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_AddrLocDate_CODE, '') + ', LocAddress_DATE = ' + ISNULL(@Lc_FcrFplsLocCur_LocAddress_DATE, '') + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '') + ', Employer_NAME = ' + ISNULL(@Ls_FcrFplsLocCur_Employer_NAME, '') + ', IND_ADDR_FORMAT = ' + ISNULL(@Lc_FcrFplsLocCur_AddrFormat_INDC, '') + ', Returned_ADDR = ' + ISNULL(@Ls_FcrFplsLocCur_Returned_ADDR, '') + ', AddrScrub1_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_AddrScrub1_CODE, '') + ', AddrScrub2_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_AddrScrub2_CODE, '') + ', AddrScrub3_CODE = ' + ISNULL (@Lc_FcrFplsLocCur_AddrScrub3_CODE, '') + ', FcrDodData_TEXT = ' + ISNULL (@Ls_FcrFplsLocCur_FcrDodData_TEXT, '') + ', FcrReservedFuture1_CODE = ' + ISNULL (@Lc_FcrFplsLocCur_FcrReservedFuture1_CODE, '') + ', FcrReservedFuture2_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_FcrReservedFuture2_CODE, '') + ', FcrReservedFuture3_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_FcrReservedFuture3_CODE, '') + ', FcrSortState_CODE = ' + ISNULL (@Lc_FcrFplsLocCur_FcrSortState_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrFplsLocCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FcrFplsLocCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_Zip_ADDR, '') + ', Normalization_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_Normalization_CODE, '');
     -- Check for the existence of the member MCI number
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberMci_IDNO AS VARCHAR(10)), 0);
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrFplsLocCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
             
	   SET @Ls_Sql_TEXT = 'SELECT MemberMci_IDNO DEMO_Y1,MSSN_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberSsn_NUMB AS VARCHAR(10)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_Last_NAME, '');
       
       SELECT  @Li_RowCount_QNTY = COUNT(DISTINCT m.MemberMci_IDNO)
         FROM DEMO_Y1 d,
              MSSN_Y1 m
        WHERE m.MemberSsn_NUMB = @Ln_FcrFplsLocCur_MemberSsn_NUMB
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE
          AND d.MemberMci_IDNO = m.MemberMci_IDNO
          AND UPPER (SUBSTRING(d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrFplsLocCur_Last_NAME, 1, 5);

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
         SET @Ls_Sql_TEXT = 'GET MCI NUMBER FROM DEMO AND MSSN USING SSN AND FIRST FIVE CHARACTERS OF LAST NAME';
		 SET @Ls_Sqldata_TEXT = 'SSN = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + 'LAST NAME = ' + ISNULL(@Lc_FcrFplsLocCur_Last_NAME, '');
         SELECT 
		   DISTINCT @Ln_MemberMci_IDNO = m.MemberMci_IDNO
           FROM DEMO_Y1 d,
                MSSN_Y1 m
           WHERE m.MemberSsn_NUMB = @Ln_FcrFplsLocCur_MemberSsn_NUMB
            AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
            AND m.EndValidity_DATE = @Ld_High_DATE
            AND d.MemberMci_IDNO = m.MemberMci_IDNO
            AND UPPER (SUBSTRING(d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrFplsLocCur_Last_NAME, 1, 5);
        END
      END
     ELSE
      BEGIN
      
       SET @Ln_MemberMci_IDNO = @Ln_FcrFplsLocCur_MemberMci_IDNO;
      END
     
     SET @Ls_Sql_TEXT = 'DERIVE LOC_SOURCE_RESP DATA';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '');
     SET @Ld_BeginEmployment_DATE = @Ld_Low_DATE;
     SET @Ln_Fein_IDNO = @Ln_Zero_NUMB;
     
     IF @Lc_FcrFplsLocCur_LocSourceResp_CODE = @Lc_LocRespAgencyDod_TEXT
      BEGIN
       SET @Lc_IndStatusDod_CODE = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 1, 1);
       SET @Lc_AgencyDod_CODE = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 2, 4);
       SET @Lc_DodPaygrade_CODE = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 6, 4);
       SET @Lc_AmountSalaryDod_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 10, 6);
       SET @Lc_DateBirthDod_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 16, 8);
       SET @Lc_SubmittingOficeDod_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 24, 4);
       SET @Lc_IndApoPfoInd_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 28, 1);

       IF @Lc_FcrFplsLocCur_LocStatusResp_CODE IN (@Lc_LocRespSpace_CODE, @Lc_LocResp39_CODE)
          AND LTRIM(RTRIM(@Lc_IndStatusDod_CODE)) IS NOT NULL
        BEGIN
         
         SET @Ls_Sql_TEXT = 'FPLS_DOD';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '') + ', Employer_NAME = ' + ISNULL(@Ls_FcrFplsLocCur_Employer_NAME, '');

         IF (LTRIM(RTRIM(@Ls_FcrFplsLocCur_Employer_NAME)) = '')
          BEGIN
           -- Set Address indicator for member address update
           
           SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
          END
         ELSE
          BEGIN
           --Insufficient information 
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE1176_CODE;

           GOTO lx_exception;
          END
        END
       ELSE
        BEGIN
         --Locate Source Response Agency Code: A01 - Response from DOD
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

         GOTO lx_exception;
        END
      END
     ELSE
      BEGIN
       IF @Lc_FcrFplsLocCur_LocSourceResp_CODE IN (@Lc_LocRespAgencyFbi_TEXT, @Lc_LocRespAgencyNsa_TEXT)
        BEGIN
        
         SET @Lc_IndFbi_ADDR = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 1, 1);
         SET @Lc_AmountSalaryFbi_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 2, 7);
         SET @Lc_HelthBenefitFbi_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 9, 1);
         SET @Lc_StatusEmployerFbi_CODE = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 10, 1);
         SET @Lc_IndEmployerFbi_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 11, 1);
         SET @Lc_DateEmpTermFbi_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 12, 8);
         SET @Lc_DateDodFbi_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 20, 8);
         SET @Lc_DateDohFbi_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 28, 8);
         SET @Lc_FeinNsa_IDNO    = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 36, 9);

         IF @Lc_FcrFplsLocCur_LocStatusResp_CODE IN (@Lc_LocRespSpace_CODE, @Lc_LocResp39_CODE, @Lc_LocResp30_CODE, @Lc_LocResp40_CODE, @Lc_LocResp02_CODE)
          BEGIN
           SET @Ls_Sql_TEXT = 'FPLS_FBI';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '') + ', IND_ADDR_FBI = ' + ISNULL (@Lc_IndFbi_ADDR, '');

           IF @Lc_IndFbi_ADDR = @Lc_AddressEmployer_INDC
              AND @Lc_StatusEmployerFbi_CODE IN (@Lc_StatusEmploymentActive_CODE, @Lc_StatusEmploymentVacation_CODE)
              AND LTRIM(RTRIM(@Lc_IndEmployerFbi_TEXT)) IS NOT NULL
            BEGIN
             
             SET @Ln_Income_AMNT = dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN(@Lc_AmountSalaryFbi_TEXT);
             IF @Lc_FcrFplsLocCur_LocSourceResp_CODE = @Lc_LocRespAgencyFbi_TEXT
                BEGIN 
				 SET @Ln_Fein_IDNO = @Ln_Zero_NUMB;
				END
			 ELSE
			    BEGIN 
			     SET @Ln_Fein_IDNO =  CASE
                                       WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_FeinNsa_IDNO, '')))) = 0
                                       THEN 0
                                       ELSE @Lc_FeinNsa_IDNO
                                      END;	 
                END
             SET @Ld_BeginEmployment_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateDohFbi_TEXT, 112), 1 , 8)
             --Set employment indicator for member employer update
             SET @Lc_Employment_INDC = @Lc_Yes_INDC;
            END

           IF @Lc_IndFbi_ADDR = @Lc_AddressEmployee_INDC
            BEGIN
             --Set Addess indicator for member address update
             
             SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
            END
          END
         ELSE
          BEGIN
           -- Locate Source Response Agency Code A02 - Response from FBI 
           
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

           GOTO lx_exception;
          
          END
        END
       ELSE
        BEGIN
         IF @Lc_FcrFplsLocCur_LocSourceResp_CODE = @Lc_LocRespAgencyFederal_TEXT
          BEGIN
           
           SET @Lc_IndFederal_ADDR = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 1, 1);
           SET @Lc_AmountSalaryFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 2, 7);
           SET @Lc_HelthBenefitFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 9, 1);
           SET @Lc_StatusEmployerFederal_CODE = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 10, 1);
           SET @Lc_IndEmployerFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 11, 1);
           SET @Lc_DateEmpTermFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 12, 8);
           SET @Lc_DateDodFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 20, 8);
           SET @Lc_DateDohFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 28, 8);
           SET @Lc_AgcyReportingFederal_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 36, 9);
           SET @Lc_FeinFederal_IDNO = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 45, 9);

           IF @Lc_FcrFplsLocCur_LocStatusResp_CODE IN (@Lc_LocRespSpace_CODE, @Lc_LocResp39_CODE)
            BEGIN
             SET @Ls_Sql_TEXT = 'FPLS_FED';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '') + ', IND_ADDR_FED = ' + ISNULL (@Lc_IndFederal_ADDR, '');

             IF @Lc_IndFederal_ADDR = @Lc_AddressEmployer_INDC
                AND @Lc_StatusEmployerFederal_CODE IN (@Lc_StatusEmploymentActive_CODE, @Lc_StatusEmploymentVacation_CODE)
                AND LTRIM(RTRIM(@Lc_IndEmployerFederal_TEXT)) IS NOT NULL
              BEGIN
               
               SET @Ln_Income_AMNT = dbo.BATCH_COMMON$SF_CONVERT_AMT_SIGN(@Lc_AmountSalaryFederal_TEXT);

               SET @Ln_Fein_IDNO = CASE
                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_FeinFederal_IDNO, '')))) = 0
                                     THEN 0
                                    ELSE @Lc_FeinFederal_IDNO
                                   END;
               SET @Ld_BeginEmployment_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateDohFederal_TEXT, 112), 1 , 8);

               --Set employment indicator for member employer update
               
               SET @Lc_Employment_INDC = @Lc_Yes_INDC;
              END

             IF @Lc_IndFederal_ADDR = @Lc_AddressEmployee_INDC
              BEGIN
               --Set Addess indicator for member address update
             
               SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
              END
            END
           ELSE
            BEGIN
             --Locate Source Response Agency Code: B01 - Response from FED 
             
             SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
             SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

             GOTO lx_exception;
            END
          END
         ELSE
          BEGIN
           IF @Lc_FcrFplsLocCur_LocSourceResp_CODE = @Lc_LocRespAgencyIrs_TEXT
            BEGIN
             
             SET @Lc_ControlIrs_NAME = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 1, 6);
             SET @Lc_MemberSsnIrs_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 7, 9);
             SET @Lc_YearTaxIrs_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 16, 4);
             SET @Lc_Ind2ndIrs_NAME = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 20, 1);
             SET @Ls_Irs2_NAME = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 21, 62);
             SET @Ls_Sql_TEXT = 'FPLS_IRS';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '');

             IF @Lc_FcrFplsLocCur_LocStatusResp_CODE IN (@Lc_LocResp05_CODE, @Lc_LocResp39_CODE, @Lc_LocResp40_CODE, @Lc_LocRespSpace_CODE)
              BEGIN
               --Set Addess indicator for member address update
               IF LTRIM(RTRIM(ISNULL (@Ls_FcrFplsLocCur_Employer_NAME, ''))) = ' ' --IS NULL
                BEGIN
                 SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
                END
              END
             ELSE
              BEGIN
               --Locate Source Response Agency Code: C01 - Response from IRS
               SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
               SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

               GOTO lx_exception;
              END
            END
           ELSE
            BEGIN
             IF @Lc_FcrFplsLocCur_LocSourceResp_CODE = @Lc_LocRespAgencyMember_TEXT
              BEGIN
               
               SET @Lc_AmountBenefitMember_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 1, 6);
               SET @Lc_DodMember_TEXT = SUBSTRING(@Ls_FcrFplsLocCur_FcrDodData_TEXT, 7, 8);
               SET @Ls_Sql_TEXT = 'FPLS_MBR';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '');

               IF @Lc_FcrFplsLocCur_LocStatusResp_CODE IN (@Lc_LocResp39_CODE, @Lc_LocRespSpace_CODE)
                BEGIN
                 --Set Addess indicator for member address update.
                 
                 SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
                END
               ELSE
                BEGIN
                 --Locate Source Response Agency Code: E03 - Response from MBR
                 SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
                 SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

                 GOTO lx_exception;
                END
              END
             ELSE
              BEGIN
               IF @Lc_FcrFplsLocCur_LocSourceResp_CODE = @Lc_LocRespAgencyDva_TEXT
                BEGIN
                
                 SET @Lc_IndBenefitDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 1, 1);
                 SET @Lc_DodDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 2, 8);
                 SET @Lc_DateEfftDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 10, 8);
                 SET @Lc_AmountOfAwardDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 18, 6);
                 SET @Lc_IndSuspenseDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 24, 1);
                 SET @Lc_IndIncarceDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 25, 1);
                 SET @Lc_IndRetPayDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 26, 1);
                 SET @Lc_ActiveReserveDva_TEXT = SUBSTRING (@Ls_FcrFplsLocCur_FcrDodData_TEXT, 27, 1);
                 SET @Ls_Sql_TEXT = 'FPLS_DVA';
                 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocStatusResp_CODE = ' + ISNULL(@Lc_FcrFplsLocCur_LocStatusResp_CODE, '');

                 IF @Lc_FcrFplsLocCur_LocStatusResp_CODE IN (@Lc_LocResp39_CODE, @Lc_LocRespSpace_CODE)
                  BEGIN
                   --Set Addess indicator for member address update
                  
                   SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
                  END
                 ELSE
                  BEGIN
                   --Locate Source Response Agency Code: F01 - Response from DVA
                   
                   SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
                   SET @Lc_BateError_CODE = @Lc_ErrorE1175_CODE;

                   GOTO lx_exception;
                  END
                END
               ELSE
                BEGIN
                 --Locate Source Response Agency Code: E01 - Response from Social Security Administration
                 
                 SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
                 SET @Lc_BateError_CODE = @Lc_ErrorE0058_CODE;
                 SET @Ls_DescriptionRecord_TEXT = @Ls_ErrordescFplsLoc_TEXT;

                 GOTO lx_exception;
                END
              END
            END
          END
        END
      END

     SET @Ls_Sql_TEXT = 'BEFORE CHECKING EMPLOYER UPDATE ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);

     IF @Lc_Employment_INDC = @Lc_Yes_INDC
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeOthp_CODE = ' + ISNULL (@Lc_TypeOthpEmployer_CODE, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Fein_IDNO AS VARCHAR(9)), 0) + ', OtherParty_NAME = ' + ISNULL(@Ls_FcrFplsLocCur_Employer_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcrFplsLocCur_Line1_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_Zip_ADDR, '');
       SET @Ls_Temp_TEXT = LTRIM(RTRIM(@Ls_FcrFplsLocCur_Line1_ADDR));
       SET @Ls_Temp2_TEXT = LTRIM(RTRIM(@Ls_FcrFplsLocCur_Line2_ADDR));
       SET @Lc_Temp3_TEXT = LTRIM(RTRIM(@Lc_FcrFplsLocCur_City_ADDR));
       SET @Lc_Temp4_TEXT = LTRIM(RTRIM(@Lc_FcrFplsLocCur_State_ADDR));
       SET @Lc_Temp5_TEXT = LTRIM(RTRIM(@Lc_FcrFplsLocCur_Zip_ADDR));
       -- Get other party id number 
      
       EXECUTE BATCH_COMMON$SP_GET_OTHP
        @Ad_Run_DATE                     = @Ad_Run_DATE,
        @An_Fein_IDNO                    = @Ln_Fein_IDNO,
        @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_CODE,
        @As_OtherParty_NAME              = @Ls_FcrFplsLocCur_Employer_NAME,
        @Ac_Aka_NAME                     = @Lc_Space_TEXT,
        @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
        @As_Line1_ADDR                   = @Ls_Temp_TEXT,
        @As_Line2_ADDR                   = @Ls_Temp2_TEXT,
        @Ac_City_ADDR                    = @Lc_Temp3_TEXT,
        @Ac_Zip_ADDR                     = @Lc_Temp5_TEXT,
        @Ac_State_ADDR                   = @Lc_Temp4_TEXT,
        @Ac_Fips_CODE                    = @Lc_Space_TEXT,
        @Ac_Country_ADDR                 = @Lc_Space_TEXT,
        @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
        @An_Phone_NUMB                   = @Ln_ZERO_NUMB,
        @An_Fax_NUMB                     = @Ln_ZERO_NUMB,
        @As_Contact_EML                  = @Lc_Space_TEXT,
        @An_ReferenceOthp_IDNO           = @Ln_ZERO_NUMB,
        @An_BarAtty_NUMB                 = @Ln_ZERO_NUMB,
        @An_Sein_IDNO                    = @Ln_ZERO_NUMB,
        @Ac_SourceLoc_CODE               = @Lc_LocateSourceFpl_CODE,
        @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
        @An_DchCarrier_IDNO              = @Ln_ZERO_NUMB,
        @Ac_Normalization_CODE           = @Lc_FcrFplsLocCur_Normalization_CODE,
        @Ac_Process_ID                   = @Lc_Space_TEXT,
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
	  
       --Check for valid other_party id 
       IF @Ln_OtherParty_IDNO = @Ln_Zero_NUMB
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0620_CODE;

         GOTO lx_exception;
        END

       -- --Update member employment details
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);

       --SELECT 'before calling epmpl update ';
       
       EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
        @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
        @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
        @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
        @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE, -- as per Mike (Bug 6229)@Lc_Space_TEXT,
        @Ad_Status_DATE                = @Ad_Run_DATE,
        @Ac_TypeIncome_CODE            = @Lc_IncomeTypeEmployer_CODE,
        @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, --  as per Mike (Bug 6229)@Lc_SourceVerifiedEmp_CODE,
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @Ad_BeginEmployment_DATE       = @Ld_BeginEmployment_DATE,
        @Ad_EndEmployment_DATE         = @Ld_High_DATE,
        @An_IncomeGross_AMNT           = @Ln_Income_AMNT,
        @An_IncomeNet_AMNT             = 0,
        @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
        @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
        @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
        @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
        @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
        @Ac_SourceLoc_CODE             = @Lc_SourceFedcaseregistr_CODE,
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
        @Ac_Process_ID                 = @Lc_ProcessFcrFpls_ID,
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

     IF @Lc_MemberAddress_INDC = @Lc_Yes_INDC
      BEGIN
      
       SET @Ls_Temp_TEXT = LTRIM(RTRIM(@Ls_FcrFplsLocCur_Line1_ADDR));
       SET @Ls_Temp2_TEXT = LTRIM(RTRIM(@Ls_FcrFplsLocCur_Line2_ADDR));
       SET @Lc_Temp3_TEXT = LTRIM(RTRIM(@Lc_FcrFplsLocCur_City_ADDR));
       SET @Lc_Temp5_TEXT = LTRIM(RTRIM(@Lc_FcrFplsLocCur_Zip_ADDR));
       SET @Lc_Temp4_TEXT = LTRIM(RTRIM(@Lc_FcrFplsLocCur_State_ADDR));
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE 1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Line1_ADDR = ' + ISNULL(@Ls_FcrFplsLocCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FcrFplsLocCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcrFplsLocCur_Zip_ADDR, '');

       -- Update NCP address  details 
      
       EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
        @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
        @Ad_Run_DATE                         = @Ad_Run_DATE,
        @Ac_TypeAddress_CODE                 = @Lc_Mailing_ADDR,
        @Ad_Begin_DATE                       = @Ad_Run_DATE,
        @Ad_End_DATE                         = @Ld_High_DATE,
        @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
        @As_Line1_ADDR                       = @Ls_Temp_TEXT,
        @As_Line2_ADDR                       = @Ls_Temp2_TEXT,
        @Ac_City_ADDR                        = @Lc_Temp3_TEXT,
        @Ac_State_ADDR                       = @Lc_Temp4_TEXT,
        @Ac_Zip_ADDR                         = @Lc_Temp5_TEXT,
        @Ac_Country_ADDR                     = @Lc_Country_ADDR,
        @An_Phone_NUMB                       = @Ln_Zero_NUMB,
        @Ac_SourceLoc_CODE                   = @Lc_LocateSourceFpl_CODE,
        @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
        @Ad_Status_DATE                      = @Ad_Run_DATE,
        @Ac_Status_CODE                      = @Lc_VerificationStatusPending_CODE,
        @Ac_SourceVerified_CODE              = @Lc_Space_TEXT,
        @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
        @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
        @Ac_Process_ID                       = @Lc_ProcessFcrFpls_ID,
        @Ac_SignedonWorker_ID                = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
        @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
        @Ac_Normalization_CODE               = @Lc_FcrFplsLocCur_Normalization_CODE,
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
     
     -- Bug 10827, if address or employer information is received in the incoming FPLS record
     -- create a RRFCR case journal entry for all the cases where the member is active
     IF @Lc_MemberAddress_INDC = @Lc_Yes_INDC
     OR @Lc_Employment_INDC = @Lc_Yes_INDC
       BEGIN
		SET @Ls_Sql_TEXT = 'GENERATE TransactionEventSeq_NUMB B';
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
          SET @Ls_ErrorMessage_TEXT = 'GENERATE TransactionEventSeq_NUMB B FAILED';

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
          @Ac_WorkerUpdate_ID		   = @Lc_BatchRunUser_TEXT,
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
     -- End of 10827 Bug  
     SET @Ld_DeceasedFpls_DATE = NULL;
     
     IF LTRIM(RTRIM(ISNULL(@Lc_DateDodFbi_TEXT, ''))) <> ' ' 
      BEGIN
       SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_DateDodFbi_TEXT;
       IF ISDATE(LTRIM(RTRIM(@Lc_DateDodFbi_TEXT))) <> 1
		BEGIN 
           SET @Lc_DateDodFbi_TEXT = ''
		END
	   ELSE
	    BEGIN
		 SET @Ld_DeceasedFpls_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateDodFbi_TEXT, 112), 1 , 8);
		END
      END
     ELSE IF LTRIM(RTRIM(ISNULL(@Lc_DateDodFederal_TEXT, ''))) <> ' ' 
      BEGIN
       SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_DateDodFederal_TEXT;
       IF ISDATE(LTRIM(RTRIM(@Lc_DateDodFederal_TEXT))) <> 1
		BEGIN 
           SET @Lc_DateDodFederal_TEXT = ''
		END
	   ELSE
	    BEGIN
		 SET @Ld_DeceasedFpls_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateDodFederal_TEXT, 112), 1 , 8);
		END
      END
     ELSE IF LTRIM(RTRIM(ISNULL(@Lc_DodMember_TEXT, ''))) <> ' ' 
      BEGIN
       SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_DodMember_TEXT;
       IF ISDATE(LTRIM(RTRIM(@Lc_DodMember_TEXT))) <> 1
		BEGIN 
           SET @Lc_DodMember_TEXT = ''
		END
	   ELSE
        BEGIN
		 SET @Ld_DeceasedFpls_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DodMember_TEXT, 112), 1 , 8);
		END
      END
     ELSE IF LTRIM(RTRIM(ISNULL(@Lc_DodDva_TEXT, ''))) <> ' ' 
      BEGIN
       SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
	   SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_DodDva_TEXT;
       IF ISDATE(LTRIM(RTRIM(@Lc_DodDva_TEXT))) <> 1
		BEGIN 
           SET @Lc_DodDva_TEXT = ''
		END
	   ELSE
	    BEGIN
		 SET @Ld_DeceasedFpls_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DodDva_TEXT, 112), 1 , 8) ;
		END
      END

     SET @Ld_BirthFpls_DATE = NULL;
     
     SET @Ls_Sql_TEXT = 'BatchDate_TEXT - Conversion';
     SET @Ls_Sqldata_TEXT = 'BatchDate_TEXT = ' + @Lc_DateBirthDod_TEXT;
     IF ISDATE(LTRIM(RTRIM(@Lc_DateBirthDod_TEXT))) <> 1
      BEGIN 
            SET @Lc_DateBirthDod_TEXT = ''
      END
                        

     IF LTRIM(RTRIM(ISNULL(@Lc_DateBirthDod_TEXT, ' '))) <> ' ' 
      BEGIN
       SET @Ld_BirthFpls_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateBirthDod_TEXT, 112), 1 , 8) ;
      END

     SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1 2';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
     
     SELECT @Ld_Deceased_DATE = d.Deceased_DATE,
            @Ld_Birth_DATE = d.Birth_DATE,
            @Ln_MemberSsn_NUMB = d.MemberSsn_NUMB
       FROM DEMO_Y1 d
      WHERE d.MemberMci_IDNO = @Ln_MemberMci_IDNO;

     IF (@Ld_Deceased_DATE = @Ld_Low_DATE
         AND @Ld_DeceasedFpls_DATE <> ' ')
         OR (@Ld_Birth_DATE = @Ld_Low_DATE
             AND @Ld_BirthFpls_DATE <> ' ')
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO 2';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Birth_DATE = ' + ISNULL(CAST(@Ld_BirthFpls_DATE AS VARCHAR(10)), '') + ', Deceased_DATE = ' + ISNULL(CAST(@Ld_DeceasedFpls_DATE AS VARCHAR(10)), '');
       SET @Ld_TempBirthFpls_DATE = ISNULL(@Ld_BirthFpls_DATE, @Ld_Birth_DATE);
       SET @Ld_TempDeathFpls_DATE = ISNULL(@Ld_DeceasedFpls_DATE, @Ld_Deceased_DATE);

       EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
        @An_MemberSsn_NUMB        = @Ln_MemberSsn_NUMB,
        @Ad_Birth_DATE            = @Ld_TempBirthFpls_DATE,
        @Ad_Deceased_DATE         = @Ld_TempDeathFpls_DATE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO 2 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     IF @Ld_DeceasedFpls_DATE IS NOT NULL
        AND @Ld_Deceased_DATE = @Ld_Low_DATE
      BEGIN
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
           AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
           AND b.Case_IDNO = a.Case_IDNO
           AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

       OPEN CaseMember_Cur;

       FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       -- process to generate case journal entries
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL (CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityLuapd_CODE, '');
         
         -- LUAPD Member NCP found deceased 
         -- Generate alert to the case worker 
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_MinorActivityLuapd_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID		   = @Lc_BatchRunUser_TEXT,
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
		
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST2';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '');
         
         SET @Ld_Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

         EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
          @An_Case_IDNO                    = @Ln_CaseMemberCur_Case_IDNO,
          @An_RespondentMci_IDNO           = 0,
          @Ac_Function_CODE                = @Lc_FunctionMsc_CODE,
          @Ac_Action_CODE                  = @Lc_ActionP1_CODE,
          @Ac_Reason_CODE                  = @Lc_ReasonLuapd_CODE,
          @Ac_IVDOutOfStateFips_CODE       = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateCountyFips_CODE = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateCase_ID         = @Lc_Space_TEXT,
          @Ad_Generated_DATE               = @Ad_Run_DATE,
          @Ac_Form_ID                      = @Lc_Space_TEXT,
          @As_FormWeb_URL                  = @Lc_Space_TEXT,
          @An_TransHeader_IDNO             = 0,
          @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
          @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
          @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
          @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
          @Ad_Hearing_DATE                 = @Ld_Low_DATE,
          @Ad_Dismissal_DATE               = @Ld_Low_DATE,
          @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
          @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
          @Ac_Attachment_INDC              = @Lc_Value_CODE,
          @Ac_File_ID                      = @Lc_Space_TEXT,
          @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
          @An_TotalArrearsOwed_AMNT        = 0,
          @An_TotalInterestOwed_AMNT       = 0,
          @Ac_Process_ID                   = @Lc_Space_TEXT,
          @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
          @Ac_SignedonWorker_ID            = @Lc_BatchRunUser_TEXT,
          @Ad_Update_DTTM                  = @Ld_Update_DTTM,
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
		

         FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE CaseMember_Cur;

       DEALLOCATE CaseMember_Cur;
      END

     -- Local exception section which writes into BATE_Y1 tables
     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrFplsLocCur_Last_NAME, '') + ', CURSOR_COUNT = ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), 0);
                     
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
         
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO BATE-4 FAILED FOR ';

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
		IF CURSOR_STATUS ('local', 'CaseMember_Cur') IN (0, 1)
		 BEGIN
		  CLOSE CaseMember_Cur;
		  DEALLOCATE CaseMember_Cur;
		 END
		SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
		IF XACT_STATE() = 1
	     BEGIN
	   	   ROLLBACK TRANSACTION SAVEFPLS_DETAILS;
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
                
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrFplsLocCur_MemberMciIdno_TEXT, 0) ;

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
     
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATE LFLFP_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrFplsLocCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LFLFP_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrFplsLocCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFLFP_Y1';

       RAISERROR(50001,16,1);
      END

     -- Check for the commit frequency  
     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT: ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID  = ' + ISNULL(@Ac_Job_ID, '');

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

       COMMIT TRANSACTION FPLS_DETAILS; 
       BEGIN TRANSACTION FPLS_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION FPLS_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrFplsLoc_CUR INTO @Ln_FcrFplsLocCur_Seq_IDNO, @Lc_FcrFplsLocCur_Rec_ID, @Lc_FcrFplsLocCur_StateTerr_CODE, @Lc_FcrFplsLocCur_LocSourceResp_CODE, @Lc_FcrFplsLocCur_NameSent_CODE, @Lc_FcrFplsLocCur_First_NAME, @Lc_FcrFplsLocCur_Middle_NAME, @Lc_FcrFplsLocCur_Last_NAME, @Lc_FcrFplsLocCur_FirstAddl1_NAME, @Lc_FcrFplsLocCur_MiAddl1_NAME, @Lc_FcrFplsLocCur_LastAddl1_NAME, @Lc_FcrFplsLocCur_FirstAddl2_NAME, @Lc_FcrFplsLocCur_MiAddl2_NAME, @Lc_FcrFplsLocCur_LastAddl2_NAME, @Lc_FcrFplsLocCur_NameReturned_CODE, @Ls_FcrFplsLocCur_Returned_NAME, @Lc_FcrFplsLocCur_MemberSsnNumb_TEXT, @Lc_FcrFplsLocCur_MemberMciIdno_TEXT, @Lc_FcrFplsLocCur_UserField_NAME, @Lc_FcrFplsLocCur_CountyFips_CODE, @Lc_FcrFplsLocCur_LocReqType_CODE, @Lc_FcrFplsLocCur_AddrLocDate_CODE, @Lc_FcrFplsLocCur_LocAddress_DATE, @Lc_FcrFplsLocCur_LocStatusResp_CODE, @Ls_FcrFplsLocCur_Employer_NAME, @Lc_FcrFplsLocCur_AddrFormat_INDC, @Ls_FcrFplsLocCur_Returned_ADDR, @Lc_FcrFplsLocCur_AddrScrub1_CODE, @Lc_FcrFplsLocCur_AddrScrub2_CODE, @Lc_FcrFplsLocCur_AddrScrub3_CODE, @Ls_FcrFplsLocCur_FcrDodData_TEXT, @Lc_FcrFplsLocCur_FcrReservedFuture1_CODE, @Lc_FcrFplsLocCur_FcrReservedFuture2_CODE, @Lc_FcrFplsLocCur_FcrReservedFuture3_CODE, @Lc_FcrFplsLocCur_FcrSortState_CODE, @Ls_FcrFplsLocCur_Line1_ADDR, @Ls_FcrFplsLocCur_Line2_ADDR, @Lc_FcrFplsLocCur_City_ADDR, @Lc_FcrFplsLocCur_State_ADDR, @Lc_FcrFplsLocCur_Zip_ADDR, @Lc_FcrFplsLocCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrFplsLoc_CUR;

   DEALLOCATE FcrFplsLoc_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   -- Transaction ends 
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
   
   COMMIT TRANSACTION FPLS_DETAILS;
  END TRY

  BEGIN CATCH
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   IF CURSOR_STATUS ('local', 'FcrFplsLoc_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrFplsLoc_CUR;

     DEALLOCATE FcrFplsLoc_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FPLS_DETAILS;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
