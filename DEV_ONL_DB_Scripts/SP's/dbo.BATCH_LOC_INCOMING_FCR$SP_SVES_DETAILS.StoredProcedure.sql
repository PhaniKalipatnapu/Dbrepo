/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_SVES_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure  Name	     : BATCH_LOC_INCOMING_FCR$SP_SVES_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the SVES (State Verification Exchange System)
                       Title II and Title XVI details from
                       the temporary table and update the member's residential
                       address, Date of Birth, Date of Death and
                       employment information.
Frequency			 : Daily
Developed On		 : 04/08/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
					   BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
					   BATCH_COMMON$SP_INSERT_ACTIVITY
					   BATCH_COMMON$SP_INSERT_PENDING_REQUEST
					   BATCH_COMMON$SP_EMPLOYER_UPDATE
					   BATCH_COMMON$SP_ADDRESS_UPDATE
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
					   BATCH_COMMON$SP_BATE_LOG
					   
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_SVES_DETAILS]
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

  DECLARE  @Lc_ValueN_CODE							CHAR(1) = 'N',
           @Lc_Note_INDC							CHAR(1) = 'N',
           @Lc_StatusCaseMemberActive_CODE			CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE			CHAR(1) = 'Y',
           @Lc_Yes_INDC								CHAR(1) = 'Y',
           @Lc_ProcessY_INDC						CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE					CHAR(1) = 'F',
           @Lc_RelationshipCaseNcp_TEXT				CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_TEXT		CHAR(1) = 'P',
           @Lc_CaseStatusOpen_CODE					CHAR(1) = 'O',
           @Lc_TypeAddressM_CODE					CHAR(1) = 'M',
           @Lc_VerificationStatusPending_CODE		CHAR(1) = 'P',
           @Lc_ErrorTypeError_CODE					CHAR(1) = 'E',
           @Lc_StatusSuccess_CODE					CHAR(1) = 'S',
           @Lc_ActionP1_CODE						CHAR(1) = 'P',
           @Lc_MemberAddress_INDC					CHAR(1) = 'N',
           @Lc_Employment_INDC						CHAR(1) = 'N',
           @Lc_TypeOthpSsa_CODE						CHAR(1) = '9',
           @Lc_IndScrubGa_CODE						CHAR(2) = 'GA',
           @Lc_IndScrubCh_CODE						CHAR(2) = 'CH',
           @Lc_SubsystemLoc_CODE					CHAR(2) = 'LO',
           @Lc_IncomeTypeSs_CODE					CHAR(2) = 'SS',
           @Lc_SourceFedcaseregistr_CODE			CHAR(3) = 'FCR',
           @Lc_SourceVerifiedPpa_CODE				CHAR(3) = 'PPA',
           @Lc_LocRespAgencySvesii_TEXT				CHAR(3) = 'E05',
           @Lc_LocRespAgencySvesxvi_TEXT			CHAR(3) = 'E06',
           @Lc_FunctionMsc_CODE						CHAR(3) = 'MSC',
           @Lc_MajorActivityCase_CODE				CHAR(4) = 'CASE',
           @Lc_ErrorE0907_CODE						CHAR(5) = 'E0907',
           @Lc_ErrorE0145_CODE						CHAR(5) = 'E0145',
           @Lc_ErrorE0958_CODE						CHAR(5) = 'E0958',
           @Lc_ErrorE1177_CODE						CHAR(5) = 'E1177',
           @Lc_ErrorE0058_CODE						CHAR(5) = 'E0058',
           @Lc_MinorActivityLuapd_CODE				CHAR(5) = 'LUAPD',
           @Lc_MinorActivityRrfcr_CODE				CHAR(5) = 'RRFCR',
           @Lc_ReasonLuapd_CODE						CHAR(5) = 'LUAPD',
           @Lc_ErrorE0540_CODE						CHAR(5) = 'E0540',
           @Lc_ErrorE1089_CODE						CHAR(5) = 'E1089',
           @Lc_BateErrorE1424_CODE					CHAR(5) = 'E1424',
           @Lc_Job_ID								CHAR(7) = 'DEB0480',
           @Lc_DateFormatYyyymmdd_TEXT				CHAR(8) = 'YYYYMMDD',
           @Lc_ProcessFcrSves_ID					CHAR(8) = 'FCR_SVES',
           @Lc_BatchRunUser_TEXT					CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME						VARCHAR(60) = 'SP_SVES_DETAILS',
           @Ls_ErrordescSveslocFailed_TEXT			VARCHAR(100) = 'LOCATE SOURCE RESP CODE -E10 - SVES LOCATE NOT FOUND THE MEMBER INFO',
           @Ls_BateRecord_TEXT						VARCHAR(4000) = ' ',
           @Ld_High_DATE							DATE = '12/31/9999',
           @Ld_Low_DATE								DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB							NUMERIC(1) = 0,
           @Ln_Exists_NUMB							NUMERIC(2) = 0,
           @Ln_CommitFreq_QNTY						NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY				NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY			NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY		NUMERIC(6) = 0,
           @Ln_BenefitSves2_AMNT					NUMERIC(6),
           @Ln_Temp1_AMNT							NUMERIC(6,2),
           @Ln_Temp2_AMNT							NUMERIC(6,2),
           @Ln_OtherParty_IDNO						NUMERIC(9),
           @Ln_MemberSsn_NUMB						NUMERIC(9),
           @Ln_Topic_IDNO							NUMERIC(10) = 0,
           @Ln_EventFunctionalSeq_NUMB				NUMERIC(10) = 0,
           @Ln_Cur_QNTY								NUMERIC(10,0) = 0,
           @Ln_MemberMci_IDNO						NUMERIC(10),
           @Ln_Error_NUMB							NUMERIC(11),
           @Ln_ErrorLine_NUMB						NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB				NUMERIC(19),
           @Li_FetchStatus_QNTY						SMALLINT,
           @Li_RowCount_QNTY						SMALLINT,
           @Lc_Space_TEXT							CHAR(1) = '',
           @Lc_TypeError_CODE						CHAR(1) = '',
           @Lc_MidSves2_NAME						CHAR(1),
           @Lc_SexSves2_CODE						CHAR(1),
           @Lc_MidSves16_NAME						CHAR(1),
           @Lc_SexSves16_CODE						CHAR(1),
           @Lc_RaceSves16_CODE						CHAR(1),
           @Lc_DodSves16_CODE						CHAR(1),
           @Lc_StatePayeeSves16_CODE				CHAR(2),
           @Lc_IndScrub1Sves16_TEXT					CHAR(2),
           @Lc_IndScrub2Sves16_TEXT					CHAR(2),
           @Lc_IndScrub3Sves16_TEXT					CHAR(2),
           @Lc_ResCitySves2_CODE					CHAR(3),
           @Lc_Msg_CODE								CHAR(5),
           @Lc_BateError_CODE						CHAR(5) = '',
           @Lc_CurrentEntCymSves2_TEXT				CHAR(6),
           @Lc_SuspTermCymSves2_CODE				CHAR(6),
           @Lc_OthSves16_NAME						CHAR(6),
           @Lc_DateOfBirthCymdSves2_TEXT			CHAR(8),
           @Lc_DodCymdSves2_TEXT					CHAR(8),
           @Lc_DateOfBirthCymdSves16_TEXT			CHAR(8),
           @Lc_DodCymdSves16_TEXT					CHAR(8),
           @Lc_LastRedetCymdSves16_TEXT				CHAR(8),
           @Lc_DenialCymdSves16_TEXT				CHAR(8),
           @Lc_ZipPayeeSves16_TEXT					CHAR(9),
           @Lc_FirstSves2_NAME						CHAR(10),
           @Lc_FirstSves16_NAME						CHAR(10),
           @Lc_LastSves2_NAME						CHAR(12),
           @Lc_CityPayeeSves16_TEXT					CHAR(16),
           @Lc_LastSves16_NAME						CHAR(19),
           @Lc_1PayeeSves16_ADDR					CHAR(40),
           @Lc_2PayeeSves16_ADDR					CHAR(40),
           @Lc_3PayeeSves16_ADDR					CHAR(40),
           @Ls_Line1_ADDR							VARCHAR(50),
           @Ls_Line2_ADDR							VARCHAR(50),
           @Ls_Sql_TEXT								VARCHAR(100),
           @Ls_CursorLoc_TEXT						VARCHAR(200),
           @Ls_Sqldata_TEXT							VARCHAR(1000),
           @Ls_DescriptionError_TEXT				VARCHAR(4000),
           @Ls_ErrorMessage_TEXT					VARCHAR(4000),
           @Ls_DescriptionRecord_TEXT				VARCHAR(4000),
           @Ld_TempBirth_DATE						DATE,
           @Ld_TempDeath_DATE						DATE,
           @Ld_BirthSves_DATE						DATE,
           @Ld_DeceasedSves_DATE					DATE,
           @Ld_Birth_DATE							DATE,
           @Ld_Deceased_DATE						DATE,
           @Ld_Update_DTTM							DATETIME2(0);

  DECLARE FcrSvesLoc_CUR INSENSITIVE CURSOR FOR
   SELECT d.Seq_IDNO,
          d.Rec_ID,
          d.StateTerritory_CODE,
          d.LocSourceResp_CODE,
          d.Data1Sves_TEXT,
          LTRIM(RTRIM(d.Line1_ADDR)) AS Line1_ADDR,
          LTRIM(RTRIM(d.Line2_ADDR)) AS Line2_ADDR,
          LTRIM(RTRIM(d.City_ADDR)) AS City_ADDR,
          d.State_ADDR,
          LTRIM(RTRIM(d.Zip_ADDR)) AS Zip_ADDR,
          d.AddrScrub1_CODE,
          d.AddrScrub2_CODE,
          d.AddrScrub3_CODE,
          d.FirstSubmitted_NAME,
          d.MiddleSubmitted_NAME,
          d.LastSubmitted_NAME AS Last_NAME,
          d.BirthSubmitted_DATE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(d.SubmittedMemberSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE d.SubmittedMemberSsn_NUMB
          END AS MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(d.SubmittedMemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE d.SubmittedMemberMci_IDNO
          END AS MemberMci_IDNO,
          LTRIM(RTRIM(d.CountyFips_CODE)) AS CountyFips_CODE,
          d.MultiSsn_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(d.MultiSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE d.MultiSsn_NUMB
          END AS MultiSsn_NUMB,
          d.Data2Sves_TEXT,
          d.Data3Sves_TEXT,
          d.Normalization_CODE
     FROM LFSDE_Y1  d
    WHERE d.Process_INDC = 'N';
    
  DECLARE @Ln_FcrSvesLocCur_Seq_IDNO            NUMERIC(19),
          @Lc_FcrSvesLocCur_Rec_ID              CHAR(2),
          @Lc_FcrSvesLocCur_StateTerritory_CODE CHAR(2),
          @Lc_FcrSvesLocCur_LocSourceResp_CODE  CHAR(3),
          @Ls_FcrSvesLocCur_Data1Sves_TEXT      VARCHAR(55),
          @Ls_FcrSvesLocCur_Line1_ADDR          VARCHAR(50),
          @Ls_FcrSvesLocCur_Line2_ADDR          VARCHAR(50),
          @Lc_FcrSvesLocCur_City_ADDR           CHAR(28),
          @Lc_FcrSvesLocCur_State_ADDR          CHAR(2),
          @Lc_FcrSvesLocCur_Zip_ADDR            CHAR(10),
          @Lc_FcrSvesLocCur_AddrScrub1_CODE     CHAR(2),
          @Lc_FcrSvesLocCur_AddrScrub2_CODE     CHAR(2),
          @Lc_FcrSvesLocCur_AddrScrub3_CODE     CHAR(2),
          @Lc_FcrSvesLocCur_FirstSubmitted_NAME CHAR(12),
          @Lc_FcrSvesLocCur_MiSubmitted_NAME    CHAR(1),
          @Lc_FcrSvesLocCur_Last_NAME           CHAR(19),
          @Lc_FcrSvesLocCur_BirthSubmitted_DATE CHAR(8),
          @Lc_FcrSvesLocCur_MemberSsnNumb_TEXT  CHAR(9),
          @Lc_FcrSvesLocCur_MemberMciIdno_TEXT  CHAR(10),
          @Lc_FcrSvesLocCur_CountyFips_CODE     CHAR(3),
          @Lc_FcrSvesLocCur_MultiSsn_CODE       CHAR(1),
          @Lc_FcrSvesLocCur_MultiSsnNumb_TEXT   CHAR(9),
          @Ls_FcrSvesLocCur_Data2Sves_TEXT      VARCHAR(189),
          @Lc_FcrSvesLocCur_Data3Sves_TEXT      CHAR(16),
          @Lc_FcrSvesLocCur_Normalization_CODE  CHAR(1),
          
          @Ln_FcrSvesLocCur_MemberSsn_NUMB      NUMERIC(9),
          @Ln_FcrSvesLocCur_MemberMci_IDNO		NUMERIC(10);
  DECLARE @Ln_NcpCaseCur_Case_IDNO NUMERIC(6);  

  BEGIN TRY
   BEGIN TRANSACTION SVES_DETAILS;

   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL(@An_ExceptionThreshold_QNTY, 0);
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL(@An_CommitFreq_QNTY, 0);
   SET @Ln_CommitFreq_QNTY = @Ln_Zero_NUMB;
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = 0;
   
   OPEN FcrSvesLoc_CUR;

   FETCH NEXT FROM FcrSvesLoc_CUR INTO @Ln_FcrSvesLocCur_Seq_IDNO, @Lc_FcrSvesLocCur_Rec_ID, @Lc_FcrSvesLocCur_StateTerritory_CODE, @Lc_FcrSvesLocCur_LocSourceResp_CODE, @Ls_FcrSvesLocCur_Data1Sves_TEXT, @Ls_FcrSvesLocCur_Line1_ADDR, @Ls_FcrSvesLocCur_Line2_ADDR, @Lc_FcrSvesLocCur_City_ADDR, @Lc_FcrSvesLocCur_State_ADDR, @Lc_FcrSvesLocCur_Zip_ADDR, @Lc_FcrSvesLocCur_AddrScrub1_CODE, @Lc_FcrSvesLocCur_AddrScrub2_CODE, @Lc_FcrSvesLocCur_AddrScrub3_CODE, @Lc_FcrSvesLocCur_FirstSubmitted_NAME, @Lc_FcrSvesLocCur_MiSubmitted_NAME, @Lc_FcrSvesLocCur_Last_NAME, @Lc_FcrSvesLocCur_BirthSubmitted_DATE, @Lc_FcrSvesLocCur_MemberSsnNumb_TEXT, @Lc_FcrSvesLocCur_MemberMciIdno_TEXT, @Lc_FcrSvesLocCur_CountyFips_CODE, @Lc_FcrSvesLocCur_MultiSsn_CODE, @Lc_FcrSvesLocCur_MultiSsnNumb_TEXT, @Ls_FcrSvesLocCur_Data2Sves_TEXT, @Lc_FcrSvesLocCur_Data3Sves_TEXT, @Lc_FcrSvesLocCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process SVES detail records
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVESVES_DETAILS;
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     
     SET @Ln_Exists_NUMB = 0;
     SET @Lc_MemberAddress_INDC = @Lc_ValueN_CODE;
     SET @Lc_Employment_INDC = @Lc_ValueN_CODE;
     SET @Ls_Line1_ADDR = @Lc_Space_TEXT;
     SET @Ls_Line2_ADDR = @Lc_Space_TEXT;
     SET @Ls_DescriptionRecord_TEXT = @Lc_Space_TEXT;
     SET @Lc_DateOfBirthCymdSves2_TEXT = NULL;
     SET @Lc_DateOfBirthCymdSves16_TEXT = NULL;
     SET @Lc_DodCymdSves2_TEXT = NULL;
     SET @Lc_DodCymdSves16_TEXT = NULL;
     SET @Ln_BenefitSves2_AMNT = 0;
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     
     IF ISNUMERIC (@Lc_FcrSvesLocCur_MemberSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrSvesLocCur_MemberSsn_NUMB = @Lc_FcrSvesLocCur_MemberSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrSvesLocCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
	
     IF ISNUMERIC (@Lc_FcrSvesLocCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrSvesLocCur_MemberMci_IDNO =  @Lc_FcrSvesLocCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrSvesLocCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END	
     
     SET @Ls_CursorLoc_TEXT = 'MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' Last_NAME: ' + ISNULL(@Lc_FcrSvesLocCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), 0);
     SET @Ls_BateRecord_TEXT = ' Rec_ID: ' + ISNULL(@Lc_FcrSvesLocCur_Rec_ID, '') + ' StateTerritory_CODE: ' + ISNULL(@Lc_FcrSvesLocCur_StateTerritory_CODE, '') + ' LocSourceResp_CODE: ' + ISNULL(@Lc_FcrSvesLocCur_LocSourceResp_CODE, '') + ' Data1Sves_TEXT: ' + ISNULL (@Ls_FcrSvesLocCur_Data1Sves_TEXT, '') + ' Line1_ADDR: ' + ISNULL(@Ls_FcrSvesLocCur_Line1_ADDR, '') + ' Line2_ADDR: ' + ISNULL(@Ls_FcrSvesLocCur_Line2_ADDR, '') + ' City_ADDR: ' + ISNULL(@Lc_FcrSvesLocCur_City_ADDR, '') + ' State_ADDR: ' + ISNULL(@Lc_FcrSvesLocCur_State_ADDR, '') + ' Zip_ADDR: ' + ISNULL(@Lc_FcrSvesLocCur_Zip_ADDR, '') + ' AddrScrub1_CODE: ' + ISNULL(@Lc_FcrSvesLocCur_AddrScrub1_CODE, '') + ' AddrScrub2_CODE: ' + ISNULL (@Lc_FcrSvesLocCur_AddrScrub2_CODE, '') + ' AddrScrub3_CODE: ' + ISNULL (@Lc_FcrSvesLocCur_AddrScrub3_CODE, '') + ' FirstSubmitted_NAME: ' + ISNULL (@Lc_FcrSvesLocCur_FirstSubmitted_NAME, '') + ' MiSubmitted_NAME: ' + ISNULL(@Lc_FcrSvesLocCur_MiSubmitted_NAME, '') + ' LastSubmitted_NAME: ' + ISNULL(@Lc_FcrSvesLocCur_Last_NAME, '') + ' BirthSubmitted_DATE: ' + ISNULL(@Lc_FcrSvesLocCur_BirthSubmitted_DATE, '') + ' SubmittedMemberSsn_NUMB: ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ' SubmittedMemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' CountyFips_CODE: ' + ISNULL(@Lc_FcrSvesLocCur_CountyFips_CODE, '') + ' MultiSsn_CODE: ' + ISNULL(@Lc_FcrSvesLocCur_MultiSsn_CODE, '') + ' MultiSsn_NUMB: ' + ISNULL(@Lc_FcrSvesLocCur_MultiSsnNumb_TEXT, 0) + ' Data2Sves_TEXT: ' + ISNULL(@Ls_FcrSvesLocCur_Data2Sves_TEXT, '') + ' Data3Sves_TEXT: ' + ISNULL(@Lc_FcrSvesLocCur_Data3Sves_TEXT, '') + ' Normalization_CODE: ' + ISNULL(@Lc_FcrSvesLocCur_Normalization_CODE, '');
     
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + + ', CaseMemberStatus_CODE = A';

     -- check for existance of id_member
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrSvesLocCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrSvesLocCur_Last_NAME, '');

       SELECT @Li_RowCount_QNTY = COUNT(DISTINCT m.MemberMci_IDNO)
         FROM DEMO_Y1  d,
              MSSN_Y1  m
        WHERE m.MemberSsn_NUMB = @Ln_FcrSvesLocCur_MemberSsn_NUMB
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE
          AND d.MemberMci_IDNO = m.MemberMci_IDNO
          AND UPPER(SUBSTRING(d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrSvesLocCur_Last_NAME, 1, 5);

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
         -- Get member MCI number 
         SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrSvesLocCur_MemberSsn_NUMB AS VARCHAR(9)), 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrSvesLocCur_Last_NAME, '');
         SELECT DISTINCT
                @Ln_MemberMci_IDNO = m.MemberMci_IDNO
           FROM DEMO_Y1 d,
                MSSN_Y1 m
          WHERE m.MemberSsn_NUMB = @Ln_FcrSvesLocCur_MemberSsn_NUMB
            AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
            AND m.EndValidity_DATE = @Ld_High_DATE
            AND d.MemberMci_IDNO = m.MemberMci_IDNO
            AND UPPER (SUBSTRING(d.Last_NAME, 1, 5)) = SUBSTRING(@Lc_FcrSvesLocCur_Last_NAME, 1, 5);
        END
      END
     ELSE
      BEGIN
       
       SET @Ln_MemberMci_IDNO = @Ln_FcrSvesLocCur_MemberMci_IDNO;
      END

     SET @Ls_Sql_TEXT = 'LOCATE SOURCE RESPONSE TYPE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocSourceResp_CODE = ' + ISNULL(@Lc_FcrSvesLocCur_LocSourceResp_CODE, '');

     IF @Lc_FcrSvesLocCur_LocSourceResp_CODE = @Lc_LocRespAgencySvesii_TEXT
      BEGIN
       
       SET @Lc_FirstSves2_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 1, 10);
       SET @Lc_MidSves2_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 11, 1);
       SET @Lc_LastSves2_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 12, 12);
       SET @Lc_SexSves2_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 24, 1);
       SET @Lc_DateOfBirthCymdSves2_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 25, 8);
       SET @Lc_DodCymdSves2_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 33, 8);
       SET @Lc_ResCitySves2_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 15, 3);
       SET @Lc_CurrentEntCymSves2_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 33, 6);
       SET @Lc_SuspTermCymSves2_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 39, 6);

       SET @Ln_BenefitSves2_AMNT = CAST(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 45, 6)) AS NUMERIC(6));

       IF @Ln_BenefitSves2_AMNT IS NULL
        BEGIN
         SET @Ln_BenefitSves2_AMNT = 0;
        END

       SET @Ls_Sql_TEXT = 'SET ADDRESS AND EMPLOYER UPDATE FLAGS';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocSourceResp_CODE = ' + ISNULL(@Lc_FcrSvesLocCur_LocSourceResp_CODE, '') + ', CD_SUSP_TERM_CYM_SVES2 = ' + ISNULL(@Lc_SuspTermCymSves2_CODE, '') + ', AMT_BENEFIT_SVES2 = ' + ISNULL(CAST(@Ln_BenefitSves2_AMNT AS VARCHAR(10)), '') + ', AddrScrub1_CODE = ' + ISNULL(@Lc_FcrSvesLocCur_AddrScrub1_CODE, '');

       IF LTRIM(RTRIM(ISNULL(@Lc_SuspTermCymSves2_CODE, ''))) = ' '
          AND @Ln_BenefitSves2_AMNT > 0
          AND LTRIM(RTRIM(@Lc_FcrSvesLocCur_AddrScrub1_CODE)) IN (@Lc_IndScrubGa_CODE, @Lc_IndScrubCh_CODE)
        BEGIN
         SET @Ls_Line1_ADDR = @Ls_FcrSvesLocCur_Line1_ADDR;
         SET @Ls_Line2_ADDR = @Ls_FcrSvesLocCur_Line2_ADDR;
         SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
         SET @Lc_Employment_INDC = @Lc_Yes_INDC;
        END
       ELSE
        BEGIN
         --Key data is not found
         
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0958_CODE;
         SET @Ls_DescriptionRecord_TEXT = 'SVES TITLE II ';

         GOTO lx_exception;
        END
      END
     ELSE IF @Lc_FcrSvesLocCur_LocSourceResp_CODE = @Lc_LocRespAgencySvesxvi_TEXT
      BEGIN
       SET @Lc_OthSves16_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 1, 6);
       SET @Lc_FirstSves16_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 7, 10);
       SET @Lc_MidSves16_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 17, 1);
       SET @Lc_LastSves16_NAME = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 18, 19);
       SET @Lc_SexSves16_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 37, 1);
       SET @Lc_RaceSves16_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 38, 1);
       SET @Lc_DateOfBirthCymdSves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 39, 8);
       SET @Lc_DodCymdSves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 47, 8);
       SET @Lc_DodSves16_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data1Sves_TEXT, 55, 1);
       SET @Lc_1PayeeSves16_ADDR = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 12, 40);
       SET @Lc_2PayeeSves16_ADDR = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 52, 40);
       SET @Lc_3PayeeSves16_ADDR = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 92, 40);
       SET @Lc_CityPayeeSves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 132, 16);
       SET @Lc_StatePayeeSves16_CODE = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 148, 2);
       SET @Lc_ZipPayeeSves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 150, 9);
       SET @Lc_IndScrub1Sves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 159, 2);
       SET @Lc_IndScrub2Sves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 161, 2);
       SET @Lc_IndScrub3Sves16_TEXT = SUBSTRING(@Ls_FcrSvesLocCur_Data2Sves_TEXT, 163, 2);
       SET @Lc_LastRedetCymdSves16_TEXT = SUBSTRING(@Lc_FcrSvesLocCur_Data3Sves_TEXT, 1, 8);
       SET @Lc_DenialCymdSves16_TEXT = SUBSTRING(@Lc_FcrSvesLocCur_Data3Sves_TEXT, 9, 8);
       SET @Ls_Sql_TEXT = 'SVES TITLE XVI - RESPONSE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', LocSourceResp_CODE = ' + ISNULL(@Lc_FcrSvesLocCur_LocSourceResp_CODE, '') + ', DENIAL_CYMD_SVES16 = ' + ISNULL (@Lc_DenialCymdSves16_TEXT, '') + ', AddrScrub1_CODE = ' + ISNULL(@Lc_FcrSvesLocCur_AddrScrub1_CODE, '');
       SET @Lc_DenialCymdSves16_TEXT = ' ';

       IF LTRIM(RTRIM(ISNULL(@Lc_DenialCymdSves16_TEXT, ''))) = ''
          AND (LTRIM(RTRIM(@Lc_FcrSvesLocCur_AddrScrub1_CODE))) IN (@Lc_IndScrubGa_CODE, @Lc_IndScrubCh_CODE)
        BEGIN
         SET @Ls_Line1_ADDR = @Ls_FcrSvesLocCur_Line1_ADDR;
         SET @Ls_Line2_ADDR = @Ls_FcrSvesLocCur_Line2_ADDR;

         IF (ISNULL(@Ls_FcrSvesLocCur_Line1_ADDR, '')) = ''
            AND LTRIM(RTRIM(ISNULL(@Lc_2PayeeSves16_ADDR, ''))) <> '' 
          BEGIN
           SET @Ls_Line1_ADDR = @Lc_2PayeeSves16_ADDR;
           SET @Ls_Line2_ADDR = @Lc_2PayeeSves16_ADDR;
          END

         SET @Lc_MemberAddress_INDC = @Lc_Yes_INDC;
        END
       ELSE
        BEGIN
         --Invalid referal
         
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1177_CODE;
         SET @Ls_DescriptionRecord_TEXT = 'SVES TITLE XVI ';

         GOTO lx_exception;
        
        END
      END
     ELSE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0058_CODE;
       SET @Ls_DescriptionRecord_TEXT = @Ls_ErrordescSveslocFailed_TEXT;

       GOTO lx_exception;
      
      END

     SET @Ld_BirthSves_DATE = NULL;
     
     IF LTRIM(RTRIM(ISNULL(@Lc_DateOfBirthCymdSves2_TEXT, ''))) <> ' ' 
      BEGIN
       
       SET @Ld_BirthSves_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateOfBirthCymdSves2_TEXT, 112), 1 , 8) ;
      END
     ELSE
      BEGIN
       IF LTRIM(RTRIM(ISNULL(@Lc_DateOfBirthCymdSves16_TEXT, ''))) <> '' 
        BEGIN
         
         SET @Ld_BirthSves_DATE =  SUBSTRING(CONVERT(VARCHAR(8), @Lc_DateOfBirthCymdSves16_TEXT, 112), 1 , 8);
        END
      END

     SET @Ld_DeceasedSves_DATE = NULL;
     
     IF LTRIM(RTRIM(ISNULL(@Lc_DodCymdSves2_TEXT, ''))) <> '' 
      BEGIN
       
       SET @Ld_DeceasedSves_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DodCymdSves2_TEXT, 112), 1 , 8) ;
      END
     ELSE
      BEGIN
       IF LTRIM(RTRIM(ISNULL(@Lc_DodCymdSves16_TEXT, ''))) <> '' 
        BEGIN
         
         SET @Ld_DeceasedSves_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_DodCymdSves16_TEXT, 112), 1 , 8) ;
        END
      END

     SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1 3';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
          
     SELECT @Ld_Birth_DATE = d.Birth_DATE,
            @Ld_Deceased_DATE = d.Deceased_DATE,
            @Ln_MemberSsn_NUMB = d.MemberSsn_NUMB
       FROM DEMO_Y1 d
      WHERE d.MemberMci_IDNO = @Ln_MemberMci_IDNO;
    
     IF (@Ld_Birth_DATE = @Ld_Low_DATE
         AND @Ld_BirthSves_DATE <> ''
          OR (@Ld_Deceased_DATE = @Ld_Low_DATE
              AND @Ld_DeceasedSves_DATE <> ''))
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO 3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Birth_DATE = ' + ISNULL(CAST(@Ld_BirthSves_DATE AS VARCHAR(10)), '') + ', Deceased_DATE = ' + ISNULL(CAST(@Ld_DeceasedSves_DATE AS VARCHAR(10)), '');
       
       SET @Ld_TempBirth_DATE = ISNULL(@Ld_BirthSves_DATE, @Ld_Birth_DATE);
       
       SET @Ld_TempDeath_DATE = ISNULL(@Ld_DeceasedSves_DATE, @Ld_Deceased_DATE);
 
       EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
        @An_MemberSsn_NUMB        = @Ln_MemberSsn_NUMB,
        @Ad_Birth_DATE            = @Ld_TempBirth_DATE,
        @Ad_Deceased_DATE         = @Ld_TempDeath_DATE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         
         RAISERROR(50001,16,1);
        END
      END

     IF @Ld_Deceased_DATE = @Ld_Low_DATE
        AND (ISNULL(@Ld_DeceasedSves_DATE, '')) <> ''
      BEGIN
       SET @Ls_Sql_TEXT = 'GENERATE TransactionEventSeq_NUMB A';
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
        
         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'GET ALL CASE IDS FOR MEMBER';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
              
       DECLARE NcpCase_CUR INSENSITIVE CURSOR FOR
         
        SELECT a.Case_IDNO
          FROM CMEM_Y1  a,
               CASE_Y1  b
         WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
           AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
           AND b.Case_IDNO = a.Case_IDNO
           AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

       OPEN NcpCase_CUR; 

       FETCH NEXT FROM NcpCase_CUR 
       INTO @Ln_NcpCaseCur_Case_IDNO;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

       -- Create case journal entry
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NcpCaseCur_Case_IDNO AS VARCHAR(6)), 0) + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityLuapd_CODE, '');
        
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @Ln_NcpCaseCur_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_MinorActivityLuapd_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
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
		
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST 3';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_NcpCaseCur_Case_IDNO AS VARCHAR(6)), 0);
         SET @Ld_Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

         EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
          @An_Case_IDNO                    = @Ln_NcpCaseCur_Case_IDNO,
          @An_RespondentMci_IDNO           = @Ln_MemberMci_IDNO,
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
          @An_TransHeader_IDNO             = @Ln_Zero_NUMB,
          @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
          @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
          @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
          @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
          @Ad_Hearing_DATE                 = @Ld_Low_DATE,
          @Ad_Dismissal_DATE               = @Ld_Low_DATE,
          @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
          @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
          @Ac_Attachment_INDC              = @Lc_ValueN_CODE,
          @Ac_File_ID                      = @Lc_Space_TEXT,
          @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
          @An_TotalArrearsOwed_AMNT        = @Ln_Zero_NUMB,
          @An_TotalInterestOwed_AMNT       = @Ln_Zero_NUMB,
          @Ac_Process_ID                   = @Lc_Space_TEXT,
          @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
          @Ac_SignedonWorker_ID            = @Lc_BatchRunUser_TEXT,
          @Ad_Update_DTTM                  = @Ld_Update_DTTM,
          @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
          
           RAISERROR(50001,16,1);
          END

         FETCH NEXT FROM NcpCase_CUR 
         INTO @Ln_NcpCaseCur_Case_IDNO; 

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE NcpCase_CUR; 
       DEALLOCATE NcpCase_CUR; 
      END

     -- Update member SSA 
     -- Social Security benefit information in EHIS_Y1 . 
    
     IF @Lc_Employment_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'Employment upate ';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', TypeOthp_CODE = E - SSA Agency';
        
       SELECT TOP 1 @Ln_OtherParty_IDNO = OtherParty_IDNO
         FROM OTHP_Y1 o
        WHERE o.TypeOthp_CODE = @Lc_TypeOthpSsa_CODE
          AND LTRIM(RTRIM(o.County_IDNO)) = (SELECT TOP 1 LTRIM(RTRIM(County_IDNO))
                                                      FROM CASE_Y1 b,
                                                           CMEM_Y1 c
                                                     WHERE b.Case_IDNO = c.Case_IDNO
                                                     AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                                     AND c.MemberMci_IDNO = @Ln_MemberMci_IDNO
                                                     AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
          AND o.EndValidity_DATE = @Ld_High_DATE;
          
       SET @Li_RowCount_QNTY = @@ROWCOUNT;
              
       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'Record NOT found IN OTHP_Y1 TABLE';
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0540_CODE;

         GOTO lx_exception;
        END
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);
       SET @Ln_Temp1_AMNT = @Ln_BenefitSves2_AMNT / 100;
       SET @Ln_Temp2_AMNT = @Ln_BenefitSves2_AMNT / 100;

       EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
        @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
        @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
        @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
        @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE, 
        @Ad_Status_DATE                = @Ad_Run_DATE,
        @Ac_TypeIncome_CODE            = @Lc_IncomeTypeSs_CODE,
        @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, 
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @Ad_BeginEmployment_DATE       = NULL,
        @Ad_EndEmployment_DATE         = @Ld_High_DATE,
        @An_IncomeGross_AMNT           = @Ln_Temp1_AMNT,
        @An_IncomeNet_AMNT             = @Ln_Temp2_AMNT,
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
        @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
        @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
        @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
        @Ac_SignedonWorker_ID          = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
        @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
        @Ac_Process_ID                 = @Lc_ProcessFcrSves_ID,
        @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
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
	
     ----Update NCP address details.
     IF @Lc_MemberAddress_INDC = @Lc_Yes_INDC
      BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE 4';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Line1_ADDR = ' + ISNULL(@Ls_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL (@Lc_FcrSvesLocCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_FcrSvesLocCur_State_ADDR, '');
      
       EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
        @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
        @Ad_Run_DATE                         = @Ad_Run_DATE,
        @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
        @Ad_Begin_DATE                       = @Ad_Run_DATE,
        @Ad_End_DATE                         = @Ld_High_DATE,
        @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
        @As_Line1_ADDR                       = @Ls_Line1_ADDR,
        @As_Line2_ADDR                       = @Ls_Line2_ADDR,
        @Ac_City_ADDR                        = @Lc_FcrSvesLocCur_City_ADDR,
        @Ac_State_ADDR                       = @Lc_FcrSvesLocCur_State_ADDR,
        @Ac_Zip_ADDR                         = @Lc_FcrSvesLocCur_Zip_ADDR,
        @Ac_Country_ADDR                     = @Lc_Space_TEXT,
        @An_Phone_NUMB                       = @Ln_Zero_NUMB,
        @Ac_SourceLoc_CODE                   = @Lc_SourceFedcaseregistr_CODE,
        @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
        @Ad_Status_DATE                      = @Ad_Run_DATE,
        @Ac_Status_CODE                      = @Lc_VerificationStatusPending_CODE,
        @Ac_SourceVerified_CODE              = @Lc_Space_TEXT,
        @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
        @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
        @Ac_Process_ID                       = @Lc_ProcessFcrSves_ID,
        @Ac_SignedonWorker_ID                = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
        @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
        @Ac_Normalization_CODE               = @Lc_FcrSvesLocCur_Normalization_CODE,
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
	-- 10827 Create Case journal entry RRFCR for all the cases where member is active  
	 IF @Lc_Employment_INDC = @Lc_Yes_INDC 
	 OR @Lc_MemberAddress_INDC = @Lc_Yes_INDC
	  BEGIN 
	    SET @Ls_Sql_TEXT = 'GENERATE TransactionEventSeq_NUMB B';
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
        
          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'GET ALL CASE IDS FOR MEMBER';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
              
        DECLARE CaseMember_Cur INSENSITIVE CURSOR FOR
         
        SELECT a.Case_IDNO
          FROM CMEM_Y1  a,
               CASE_Y1  b
         WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
           AND b.Case_IDNO = a.Case_IDNO
           AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

        OPEN CaseMember_Cur; 

        FETCH NEXT FROM CaseMember_Cur 
        INTO @Ln_NcpCaseCur_Case_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

       -- Create case journal entry
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NcpCaseCur_Case_IDNO AS VARCHAR(6)), 0) + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityLuapd_CODE, '');
        
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @Ln_NcpCaseCur_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_MinorActivityRrfcr_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
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
	     FETCH NEXT FROM CaseMember_Cur INTO @Ln_NcpCaseCur_Case_IDNO;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	    END
	   
	   CLOSE CaseMember_Cur; 
	   DEALLOCATE CaseMember_Cur;
	  END  
	-- 10827
	
     -- Local exception section which writes into BATE_Y1 tables
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
		IF CURSOR_STATUS ('local', 'NcpCase_CUR') IN (0, 1)
         BEGIN
           CLOSE NcpCase_CUR;
           DEALLOCATE NcpCase_CUR;
         END
        
        -- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	     BEGIN
	   	   ROLLBACK TRANSACTION SAVESVES_DETAILS;
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
	
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1 ;
     SET @Ls_Sql_TEXT = 'UPDATE LFSDE_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrSvesLocCur_Seq_IDNO AS VARCHAR), '0');

     UPDATE LFSDE_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrSvesLocCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFSDE_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

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

       COMMIT TRANSACTION SVES_DETAILS; 
       BEGIN TRANSACTION SVES_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END
     
     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION SVES_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrSvesLoc_CUR INTO @Ln_FcrSvesLocCur_Seq_IDNO, @Lc_FcrSvesLocCur_Rec_ID, @Lc_FcrSvesLocCur_StateTerritory_CODE, @Lc_FcrSvesLocCur_LocSourceResp_CODE, @Ls_FcrSvesLocCur_Data1Sves_TEXT, @Ls_FcrSvesLocCur_Line1_ADDR, @Ls_FcrSvesLocCur_Line2_ADDR, @Lc_FcrSvesLocCur_City_ADDR, @Lc_FcrSvesLocCur_State_ADDR, @Lc_FcrSvesLocCur_Zip_ADDR, @Lc_FcrSvesLocCur_AddrScrub1_CODE, @Lc_FcrSvesLocCur_AddrScrub2_CODE, @Lc_FcrSvesLocCur_AddrScrub3_CODE, @Lc_FcrSvesLocCur_FirstSubmitted_NAME, @Lc_FcrSvesLocCur_MiSubmitted_NAME, @Lc_FcrSvesLocCur_Last_NAME, @Lc_FcrSvesLocCur_BirthSubmitted_DATE, @Lc_FcrSvesLocCur_MemberSsnNumb_TEXT, @Lc_FcrSvesLocCur_MemberMciIdno_TEXT, @Lc_FcrSvesLocCur_CountyFips_CODE, @Lc_FcrSvesLocCur_MultiSsn_CODE, @Lc_FcrSvesLocCur_MultiSsnNumb_TEXT, @Ls_FcrSvesLocCur_Data2Sves_TEXT, @Lc_FcrSvesLocCur_Data3Sves_TEXT, @Lc_FcrSvesLocCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrSvesLoc_CUR;

   DEALLOCATE FcrSvesLoc_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   -- Transaction ends 
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
  
   COMMIT TRANSACTION SVES_DETAILS;
  END TRY

  BEGIN CATCH
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
  
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrSvesLoc_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrSvesLoc_CUR;

     DEALLOCATE FcrSvesLoc_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION SVES_DETAILS;
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
