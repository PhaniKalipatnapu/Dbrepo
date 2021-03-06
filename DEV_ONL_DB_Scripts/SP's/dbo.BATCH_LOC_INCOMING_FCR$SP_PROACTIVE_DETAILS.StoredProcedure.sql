/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_PROACTIVE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_PROACTIVE_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the Proactive response details from
                       the intermediate table and match with DECSS database
                       to get Other State's Case ID. If not found then generates
                       CSNET CSI Transaction.
Frequency			 : Daily
Developed On		 : 04/08/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_INSERT_PENDING_REQUEST
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_PROACTIVE_DETAILS]
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

    DECLARE  @Lc_ValueN_INDC						CHAR(1) = 'N',
           @Lc_StatusCaseMemberActive_CODE			CHAR(1) = 'A',
           @Lc_ActionRequest_CODE					CHAR(1) = 'R',
           @Lc_StatusFailed_CODE					CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE					CHAR(1) = 'E',
           @Lc_ProcessY_INDC						CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE					CHAR(1) = 'S',
           @Lc_ActionQueryResponse_CODE				CHAR(1) = 'F',
           @Lc_ActionProactiveCase_CODE				CHAR(1) = 'C',
           @Lc_ActionProactivePerson_CODE			CHAR(1) = 'P',
           @Lc_CaseTypeMatchedF_CODE                CHAR(1) = 'F',
           @Lc_CaseTypeMatchedN_CODE                CHAR(1) = 'N',    
           @Lc_ReqStatusPending_CODE				CHAR(2) = 'PN',
           @Lc_ProMatch3orlessPersons_TEXT			CHAR(2) = 'MA',
           @Lc_ProMatchmorethan3Persons_TEXT		CHAR(2) = 'MM',
           @Lc_FunctionCasesummary_CODE				CHAR(3) = 'CSI',
           @Lc_ErrorE0891_CODE						CHAR(5) = 'E0891',
           @Lc_ErrorE0143_CODE						CHAR(5) = 'E0143',
           @Lc_FarRequestIvdinfo_CODE				CHAR(5) = 'FRINF',
           @Lc_FarRequestNonIvdinfo_CODE			CHAR(5) = 'FRNNF',
           @Lc_ErrorE0152_CODE						CHAR(5) = 'E0152',
           @Lc_ErrorE1176_CODE						CHAR(5) = 'E1176',
           @Lc_BateErrorE1424_CODE					CHAR(5) = 'E1424',
           @Lc_BatchRunUser_TEXT					CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME						VARCHAR(60) = 'SP_PROACTIVE_DETAILS',
           @Ld_High_DATE							DATE = '12/31/9999',
           @Ld_Low_DATE								DATE = '01/01/0001';
  DECLARE  @Ln_Exists_NUMB							NUMERIC(1) = 0,
		   @Ln_Zero_NUMB							NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY						NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY				NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY			NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY		NUMERIC(6) = 0,
           @Ln_Cur_QNTY								NUMERIC(10,0) = 0,
           @Ln_Error_NUMB							NUMERIC(11),
           @Ln_ErrorLine_NUMB						NUMERIC(11),
           @Li_FetchStatus_QNTY						SMALLINT,
           @Li_RowCount_QNTY						SMALLINT,
           @Lc_Space_TEXT							CHAR(1) = '',
           @Lc_TypeError_CODE						CHAR(1) = '',
           @Lc_Msg_CODE								CHAR(5) = '',
           @Lc_BateError_CODE						CHAR(5) = '',
           @Lc_Reason_CODE                          CHAR(5) = '',
           @Ls_Sql_TEXT								VARCHAR(100),
           @Ls_CursorLoc_TEXT						VARCHAR(200),
           @Ls_Sqldata_TEXT							VARCHAR(1000),
           @Ls_ErrorMessage_TEXT					VARCHAR(4000),
           @Ls_BateRecord_TEXT						VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT				VARCHAR(4000),
           @Ld_Start_DATE							DATETIME2;

  DECLARE @Ln_FcrProRespCur_Seq_IDNO                  NUMERIC(19),
          @Lc_FcrProRespCur_Rec_ID                    CHAR(2),
          @Lc_FcrProRespCur_TerritoryFips_CODE        CHAR(2),
          @Lc_FcrProRespCur_TypeAction_CODE           CHAR(1),
          @Lc_FcrProRespCur_UserFieldName_TEXT        CHAR(15),
          @Lc_FcrProRespCur_CountyFips_CODE           CHAR(3),
          @Lc_FcrProRespCur_BatchNumb_TEXT            CHAR(6),
          @Lc_FcrProRespCur_FirstName_TEXT            CHAR(16),
          @Lc_FcrProRespCur_MiddleName_TEXT           CHAR(16),
          @Lc_FcrProRespCur_LastName_TEXT             CHAR(30),
          @Lc_FcrProRespCur_ssnsubmitted_NUMB         CHAR(9),
          @Lc_FcrProRespCur_MemberMciIdno_TEXT        CHAR(10),
          @Lc_FcrProRespCur_CaseSubmittedIdno_TEXT    CHAR(6),
          @Lc_FcrProRespCur_Response_CODE             CHAR(2),
          @Lc_FcrProRespCur_CaseMatched_ID            CHAR(15),
          @Lc_FcrProRespCur_IVDOutOfStateFips_CODE    CHAR(2),
          @Lc_FcrProRespCur_TypeCaseMatched_CODE      CHAR(1),
          @Lc_FcrProRespCur_CountyFcrMatchedIdno_TEXT CHAR(3),
          @Lc_FcrProRespCur_RegistrationMatchedDate_TEXT CHAR(8),
          @Lc_FcrProRespCur_OrderCaseMatched_INDC     CHAR(1),
          @Lc_FcrProRespCur_PartTypeMatched_CODE      CHAR(2),
          @Lc_FcrProRespCur_MatchedMemberMciIdno_TEXT CHAR(15),
          @Lc_FcrProRespCur_DeathMatchedDate_TEXT     CHAR(8),
          @Lc_FcrProRespCur_F1AddtlMatched1Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_M1AddtlMatched1Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_L1AddtlMatched1Name_TEXT  CHAR(30),
          @Lc_FcrProRespCur_F1AddtlMatched2Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_M1AddtlMatched2Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_L1AddtlMatched2Name_TEXT  CHAR(30),
          @Lc_FcrProRespCur_F1AddtlMatched3Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_M1AddtlMatched3Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_L1AddtlMatched3Nmae_TEXT  CHAR(30),
          @Lc_FcrProRespCur_F1AddtlMatched4Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_M1AddtlMatched4Name_TEXT  CHAR(16),
          @Lc_FcrProRespCur_L1AddtlMatched4Nmae_TEXT  CHAR(30),
          @Lc_FcrProRespCur_MemberAssociated1Ssn_NUMB CHAR(9),
          @Lc_FcrProRespCur_F1Associated1Name_TEXT    CHAR(16),
          @Lc_FcrProRespCur_M1Associated1Name_TEXT    CHAR(16),
          @Lc_FcrProRespCur_L1Associated1Name_TEXT    CHAR(30),
          @Lc_FcrProRespCur_MemberSexAssociated1_CODE CHAR(1),
          @Lc_FcrProRespCur_TypePartAssociated1_CODE  CHAR(2),
          @Lc_FcrProRespCur_MemberMciAssociated1Idno_TEXT CHAR(15),
          @Lc_FcrProRespCur_BirthAssociated1Date_TEXT CHAR(8),
          @Lc_FcrProRespCur_DeathAssociated1Date_TEXT CHAR(8),
          @Lc_FcrProRespCur_MemberAssociated2Ssn_NUMB CHAR(9),
          @Lc_FcrProRespCur_F1Associated2Name_TEXT    CHAR(16),
          @Lc_FcrProRespCur_M1Associated2Name_TEXT    CHAR(16),
          @Lc_FcrProRespCur_L1Associated2Name_TEXT    CHAR(30),
          @Lc_FcrProRespCur_MemberSexAssociated2_CODE CHAR(1),
          @Lc_FcrProRespCur_TypePartAssociated2_CODE  CHAR(2),
          @Lc_FcrProRespCur_MemberMciAssociated2_IDNO CHAR(15),
          @Lc_FcrProRespCur_BirthAssociated2Date_TEXT CHAR(8),
          @Lc_FcrProRespCur_DeathAssociated2Date_TEXT CHAR(8),
          @Lc_FcrProRespCur_MemberAssociated3Ssn_NUMB CHAR(9),
          @Lc_FcrProRespCur_F1Associated3Name_TEXT    CHAR(16),
          @Lc_FcrProRespCur_M1Associated3Name_TEXT    CHAR(16),
          @Lc_FcrProRespCur_L1Associated3Name_TEXT    CHAR(30),
          @Lc_FcrProRespCur_MemberSexAssociated3_CODE CHAR(1),
          @Lc_FcrProRespCur_TypePartAssociated3_CODE  CHAR(2),
          @Lc_FcrProRespCur_MemberMciAssociated3_IDNO CHAR(15),
          @Lc_FcrProRespCur_BirthAssociated3Date_TEXT CHAR(8),
          @Lc_FcrProRespCur_DeathAssociated3Date_TEXT CHAR(8),
          
          @Ln_FcrProRespCur_MemberMci_IDNO			  NUMERIC(10),
          @Ln_FcrProRespCur_CaseSubmitted_IDNO		  NUMERIC(6);
          
  DECLARE
  -- FCR Proactive response cursor
  FcrProResp_CUR INSENSITIVE CURSOR FOR
   SELECT p.Seq_IDNO,
          p.Rec_ID,
          p.TerritoryFips_CODE,
          p.TypeAction_CODE,
          p.UserField_NAME,
          p.CountyFips_CODE,
          p.Batch_NUMB,
          p.First_NAME,
          p.Middle_NAME,
          LTRIM(RTRIM(p.Last_NAME)),
          LTRIM(RTRIM(p.MatchedSubmittedSsn_NUMB)), 
          ISNULL(LTRIM(RTRIM(p.MemberMci_IDNO)), '0'), 
          ISNULL (LTRIM(RTRIM(p.CaseSubmitted_IDNO)), '0'),
          LTRIM(RTRIM(p.Response_CODE)), 
          LTRIM(RTRIM(p.CaseMatched_IDNO)),
          LTRIM(RTRIM(p.StateCaseMatched_CODE)), 
          LTRIM(RTRIM(p.TypeCaseMatched_CODE)), 
          LTRIM(RTRIM(p.CountyFcrMatched_IDNO)), 
          p.RegistrationMatched_DATE,
          p.OrderCaseMatched_INDC,
          LTRIM(RTRIM(p.TypeParticipantMatched_CODE)), 
          p.MatchedMemberMci_IDNO,
          p.DeathMatched_DATE,
          p.F1AddtlMatched1_NAME,
          p.M1AddtlMatched1_NAME,
          p.L1AddtlMatched1_NAME,
          p.F1AddtlMatched2_NAME,
          p.M1AddtlMatched2_NAME,
          p.L1AddtlMatched2_NAME,
          p.F1AddtlMatched3_NAME,
          p.M1AddtlMatched3_NAME,
          p.L1AddtlMatched3_NAME,
          p.F1AddtlMatched4_NAME,
          p.M1AddtlMatched4_NAME,
          p.L1AddtlMatched4_NAME,
          p.MemberAssociated1Ssn_NUMB,
          p.F1Associated1_NAME,
          p.M1Associated1_NAME,
          p.L1Associated1_NAME,
          p.MemberSexAssociated1_CODE,
          p.TypePartAssociated1_CODE,
          p.MemberMciAssociated1_IDNO,
          p.BirthAssociated1_DATE,
          p.DeathAssociated1_DATE,
          p.MemberAssociated2Ssn_NUMB,
          p.F1Associated2_NAME,
          p.M1Associated2_NAME,
          p.L1Associated2_NAME,
          p.MemberSexAssociated2_CODE,
          p.TypePartAssociated2_CODE,
          p.MemberMciAssociated2_IDNO,
          p.BirthAssociated2_DATE,
          p.DeathAssociated2_DATE,
          p.MemberAssociated3Ssn_NUMB,
          p.F1Associated3_NAME,
          p.M1Associated3_NAME,
          p.L1Associated3_NAME,
          p.MemberSexAssociated3_CODE,
          p.TypePartAssociated3_CODE,
          p.MemberMciAssociated3_IDNO,
          p.BirthAssociated3_DATE,
          p.DeathAssociated3_DATE
     FROM LFPDE_Y1 p
    WHERE p.Process_INDC = 'N'
    ORDER BY Batch_NUMB;
  
  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Lc_TypeError_CODE = '';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @An_CommitFreq_QNTY = ISNULL (@An_CommitFreq_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL (@An_ExceptionThreshold_QNTY, 0);
   SET @Ln_Cur_QNTY = 0;
   SET @Ln_CommitFreq_QNTY = 0;
   SET @Ln_ExceptionThreshold_QNTY = 0;
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ls_ErrorMessage_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = 0;

   BEGIN TRANSACTION PROACTIVE_DETAILS;
   
   OPEN FcrProResp_CUR;

   FETCH NEXT FROM FcrProResp_CUR INTO @Ln_FcrProRespCur_Seq_IDNO, @Lc_FcrProRespCur_Rec_ID, @Lc_FcrProRespCur_TerritoryFips_CODE, @Lc_FcrProRespCur_TypeAction_CODE, @Lc_FcrProRespCur_UserFieldName_TEXT, @Lc_FcrProRespCur_CountyFips_CODE, @Lc_FcrProRespCur_BatchNumb_TEXT, @Lc_FcrProRespCur_FirstName_TEXT, @Lc_FcrProRespCur_MiddleName_TEXT, @Lc_FcrProRespCur_LastName_TEXT, @Lc_FcrProRespCur_ssnsubmitted_NUMB, @Lc_FcrProRespCur_MemberMciIdno_TEXT,
      @Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, @Lc_FcrProRespCur_Response_CODE, @Lc_FcrProRespCur_CaseMatched_ID, @Lc_FcrProRespCur_IVDOutOfStateFips_CODE, @Lc_FcrProRespCur_TypeCaseMatched_CODE, @Lc_FcrProRespCur_CountyFcrMatchedIdno_TEXT, @Lc_FcrProRespCur_RegistrationMatchedDate_TEXT, @Lc_FcrProRespCur_OrderCaseMatched_INDC, @Lc_FcrProRespCur_PartTypeMatched_CODE, @Lc_FcrProRespCur_MatchedMemberMciIdno_TEXT, @Lc_FcrProRespCur_DeathMatchedDate_TEXT, @Lc_FcrProRespCur_F1AddtlMatched1Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched1Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched1Name_TEXT, @Lc_FcrProRespCur_F1AddtlMatched2Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched2Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched2Name_TEXT, @Lc_FcrProRespCur_F1AddtlMatched3Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched3Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched3Nmae_TEXT, @Lc_FcrProRespCur_F1AddtlMatched4Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched4Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched4Nmae_TEXT, @Lc_FcrProRespCur_MemberAssociated1Ssn_NUMB, @Lc_FcrProRespCur_F1Associated1Name_TEXT, @Lc_FcrProRespCur_M1Associated1Name_TEXT, @Lc_FcrProRespCur_L1Associated1Name_TEXT, @Lc_FcrProRespCur_MemberSexAssociated1_CODE, @Lc_FcrProRespCur_TypePartAssociated1_CODE, @Lc_FcrProRespCur_MemberMciAssociated1Idno_TEXT, @Lc_FcrProRespCur_BirthAssociated1Date_TEXT, @Lc_FcrProRespCur_DeathAssociated1Date_TEXT, @Lc_FcrProRespCur_MemberAssociated2Ssn_NUMB, @Lc_FcrProRespCur_F1Associated2Name_TEXT, @Lc_FcrProRespCur_M1Associated2Name_TEXT, @Lc_FcrProRespCur_L1Associated2Name_TEXT, @Lc_FcrProRespCur_MemberSexAssociated2_CODE, @Lc_FcrProRespCur_TypePartAssociated2_CODE, @Lc_FcrProRespCur_MemberMciAssociated2_IDNO, @Lc_FcrProRespCur_BirthAssociated2Date_TEXT, @Lc_FcrProRespCur_DeathAssociated2Date_TEXT, @Lc_FcrProRespCur_MemberAssociated3Ssn_NUMB, @Lc_FcrProRespCur_F1Associated3Name_TEXT, @Lc_FcrProRespCur_M1Associated3Name_TEXT, @Lc_FcrProRespCur_L1Associated3Name_TEXT, @Lc_FcrProRespCur_MemberSexAssociated3_CODE, @Lc_FcrProRespCur_TypePartAssociated3_CODE, @Lc_FcrProRespCur_MemberMciAssociated3_IDNO, @Lc_FcrProRespCur_BirthAssociated3Date_TEXT, @Lc_FcrProRespCur_DeathAssociated3Date_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Process the proactive match records 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVEPROACTIVE_DETAILS;
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Lc_TypeError_CODE = '';
     SET @Ls_CursorLoc_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciIdno_TEXT, 0) + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '') + ', CURSOR_COUNT = ' + ISNULL (CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
     SET @Ln_Exists_NUMB = 0;
     
     IF ISNUMERIC(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrProRespCur_CaseSubmitted_IDNO = @Lc_FcrProRespCur_CaseSubmittedIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrProRespCur_CaseSubmitted_IDNO = @Ln_Zero_NUMB;
		END
	
	 IF ISNUMERIC (@Lc_FcrProRespCur_MemberMciIdno_TEXT) = 1 
		BEGIN
			SET @Ln_FcrProRespCur_MemberMci_IDNO = 	@Lc_FcrProRespCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN
			SET @Ln_FcrProRespCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
		
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcrProRespCur_Rec_ID, '') + ', TerritoryFips_CODE = ' + ISNULL(@Lc_FcrProRespCur_TerritoryFips_CODE, '') + ', TypeAction_CODE = ' + ISNULL (@Lc_FcrProRespCur_TypeAction_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_FcrProRespCur_UserFieldName_TEXT, '') + ', CountyFips_CODE = ' + ISNULL (@Lc_FcrProRespCur_CountyFips_CODE, '') + ', Batch_NUMB = ' + ISNULL(@Lc_FcrProRespCur_BatchNumb_TEXT, 0) + ', First_NAME = ' + ISNULL(@Lc_FcrProRespCur_FirstName_TEXT, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrProRespCur_MiddleName_TEXT, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrProRespCur_LastName_TEXT, '') + ', MatchedSubmittedSsn_NUMB = ' + ISNULL(@Lc_FcrProRespCur_ssnsubmitted_NUMB, '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciIdno_TEXT, 0) + ', CaseSubmitted_IDNO =  ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', Response_CODE = ' + ISNULL(@Lc_FcrProRespCur_Response_CODE, '') + ', CaseMatched_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '') + ', StateCaseMatched_CODE = ' + ISNULL(@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '') + ', TypeCaseMatched_CODE = ' + ISNULL(@Lc_FcrProRespCur_TypeCaseMatched_CODE, '') + ', CountyFcrMatched_CODE = ' + ISNULL(@Lc_FcrProRespCur_CountyFcrMatchedIdno_TEXT, '') + ', RegistrationMatched_DATE = ' + ISNULL(@Lc_FcrProRespCur_RegistrationMatchedDate_TEXT, '') + ', OrderCaseMatched_INDC = ' + ISNULL(@Lc_FcrProRespCur_OrderCaseMatched_INDC, '') + ', CD_TYPE_PART_MATCHD = ' + ISNULL (@Lc_FcrProRespCur_PartTypeMatched_CODE, '') + ', MatchedMemberMci_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MatchedMemberMciIdno_TEXT, '') + ', DeathMatched_DATE = ' + ISNULL (@Lc_FcrProRespCur_DeathMatchedDate_TEXT, '') + ', F1AddtlMatched1_NAME = ' + ISNULL(@Lc_FcrProRespCur_F1AddtlMatched1Name_TEXT, '') + ', M1AddtlMatched1_NAME = ' + ISNULL (@Lc_FcrProRespCur_M1AddtlMatched1Name_TEXT, '') + ', L1AddtlMatched1_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1AddtlMatched1Name_TEXT, '') + ', F1AddtlMatched2_NAME = ' + ISNULL (@Lc_FcrProRespCur_F1AddtlMatched2Name_TEXT, '') + ', M1AddtlMatched2_NAME = ' + ISNULL (@Lc_FcrProRespCur_M1AddtlMatched2Name_TEXT, '') + ', L1AddtlMatched2_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1AddtlMatched2Name_TEXT, '') + ', F1AddtlMatched3_NAME = ' + ISNULL (@Lc_FcrProRespCur_F1AddtlMatched3Name_TEXT, '') + ', M1AddtlMatched3_NAME = ' + ISNULL (@Lc_FcrProRespCur_M1AddtlMatched3Name_TEXT, '') + ', L1AddtlMatched3_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1AddtlMatched3Nmae_TEXT, '') + ', F1AddtlMatched4_NAME = ' + ISNULL (@Lc_FcrProRespCur_F1AddtlMatched4Name_TEXT, '') + ', M1AddtlMatched4_NAME = ' + ISNULL (@Lc_FcrProRespCur_M1AddtlMatched4Name_TEXT, '') + ', L1AddtlMatched4_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1AddtlMatched4Nmae_TEXT, '') + ', MemberAssociated1Ssn_NUMB = ' + ISNULL(@Lc_FcrProRespCur_MemberAssociated1Ssn_NUMB, '') + ', F1Associated1_NAME = ' + ISNULL(@Lc_FcrProRespCur_F1Associated1Name_TEXT, '') + ', M1Associated1_NAME =  ' + ISNULL (@Lc_FcrProRespCur_M1Associated1Name_TEXT, '') + ', L1Associated1_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1Associated1Name_TEXT, '') + ', MemberSexAssociated1_CODE = ' + ISNULL(@Lc_FcrProRespCur_MemberSexAssociated1_CODE, '') + ', TypePartAssociated1_CODE = ' + ISNULL(@Lc_FcrProRespCur_TypePartAssociated1_CODE, '') + ', MemberMciAssociated1_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciAssociated1Idno_TEXT, '') + ', BirthAssociated1_DATE = ' + ISNULL(@Lc_FcrProRespCur_BirthAssociated1Date_TEXT, '') + ', DeathAssociated1_DATE = ' + ISNULL(@Lc_FcrProRespCur_DeathAssociated1Date_TEXT, '') + ', MemberAssociated2Ssn_NUMB = ' + ISNULL(@Lc_FcrProRespCur_MemberAssociated2Ssn_NUMB, '') + ', F1Associated2_NAME = ' + ISNULL(@Lc_FcrProRespCur_F1Associated2Name_TEXT, '') + ', M1Associated2_NAME = ' + ISNULL (@Lc_FcrProRespCur_M1Associated2Name_TEXT, '') + ', L1Associated2_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1Associated2Name_TEXT, '') + ', MemberSexAssociated2_CODE = ' + ISNULL(@Lc_FcrProRespCur_MemberSexAssociated2_CODE, '') + ', TypePartAssociated2_CODE = ' + ISNULL(@Lc_FcrProRespCur_TypePartAssociated2_CODE, '') + ', MemberMciAssociated2_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciAssociated2_IDNO, '') + ', BirthAssociated2_DATE = ' + ISNULL(@Lc_FcrProRespCur_BirthAssociated2Date_TEXT, '') + ', DeathAssociated2_DATE = ' + ISNULL(@Lc_FcrProRespCur_DeathAssociated2Date_TEXT, '') + ', MemberAssociated3Ssn_NUMB = ' + ISNULL(@Lc_FcrProRespCur_MemberAssociated3Ssn_NUMB, '') + ', F1Associated3_NAME = ' + ISNULL(@Lc_FcrProRespCur_F1Associated3Name_TEXT, '') + ', M1Associated3_NAME = ' + ISNULL (@Lc_FcrProRespCur_M1Associated3Name_TEXT, '') + ', L1Associated3_NAME = ' + ISNULL (@Lc_FcrProRespCur_L1Associated3Name_TEXT, '') + ', MemberSexAssociated3_CODE = ' + ISNULL(@Lc_FcrProRespCur_MemberSexAssociated3_CODE, '') + ', TypePartAssociated3_CODE = ' + ISNULL(@Lc_FcrProRespCur_TypePartAssociated3_CODE, '') + ', MemberMciAssociated3_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciAssociated3_IDNO, '') + ', BirthAssociated3_DATE = ' + ISNULL(@Lc_FcrProRespCur_BirthAssociated3Date_TEXT, '') + ', DeathAssociated3_DATE = ' + ISNULL(@Lc_FcrProRespCur_DeathAssociated3Date_TEXT, '');

     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF Case_IDNO IN CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0);
          
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CASE_Y1 c
      WHERE c.Case_IDNO = @Ln_FcrProRespCur_CaseSubmitted_IDNO;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0891_CODE;

       GOTO lx_exception;
      END

     SET @Ls_Sql_TEXT = 'CHECK FOR PROACTIVE RESPONSE CODES';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', TypeAction_CODE = ' + ISNULL(@Lc_FcrProRespCur_TypeAction_CODE, '') + ', Response_CODE = ' + ISNULL(@Lc_FcrProRespCur_Response_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL (@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '') + ', CD_TYPE_CASE_MATCHED = ' + ISNULL(@Lc_FcrProRespCur_TypeCaseMatched_CODE, '') + ', CD_COUNTY_FCR_MATCHED = ' + ISNULL(@Lc_FcrProRespCur_CountyFcrMatchedIdno_TEXT, '');
     
     IF (@Lc_FcrProRespCur_TypeAction_CODE IN (@Lc_ActionQueryResponse_CODE, @Lc_ActionProactiveCase_CODE, @Lc_ActionProactivePerson_CODE)
         AND @Lc_FcrProRespCur_Response_CODE IN (@Lc_ProMatch3orlessPersons_TEXT, @Lc_ProMatchmorethan3Persons_TEXT)
         AND ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '') <> ''
         AND ISNULL(@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '') <> ''
         AND ISNULL(@Lc_FcrProRespCur_TypeCaseMatched_CODE, '') <> '')
         
      BEGIN
       SET @Ln_Exists_NUMB = 0;
       SET @Lc_Reason_CODE = @Lc_Space_TEXT;
       IF @Lc_FcrProRespCur_TypeCaseMatched_CODE = @Lc_CaseTypeMatchedN_CODE
		BEGIN 
		  SET @Lc_Reason_CODE = @Lc_FarRequestNonIvdinfo_CODE;
		END 
	   ELSE
	    BEGIN 
	      SET @Lc_Reason_CODE = @Lc_FarRequestIvdinfo_CODE;
	    END 
       SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF Case_IDNO IN ICAS_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL (@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '');
              
       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM ICAS_Y1 i
        WHERE i.Case_IDNO = @Ln_FcrProRespCur_CaseSubmitted_IDNO
          AND i.IVDOutOfStateCase_ID = @Lc_FcrProRespCur_CaseMatched_ID
          AND i.IVDOutOfStateFips_CODE = @Lc_FcrProRespCur_IVDOutOfStateFips_CODE
          AND i.EndValidity_DATE = @Ld_High_DATE;

       IF @Ln_Exists_NUMB = 0
        BEGIN
         SET @Ln_Exists_NUMB = 0;
         SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF Case_IDNO, MemberMci_IDNO IN CMEM_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciIdno_TEXT, 0) + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '');

         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM CMEM_Y1 c
          WHERE c.Case_IDNO = @Ln_FcrProRespCur_CaseSubmitted_IDNO
            AND c.MemberMci_IDNO = @Ln_FcrProRespCur_MemberMci_IDNO
            AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

         IF @Ln_Exists_NUMB = 0
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0143_CODE;

           GOTO lx_exception;
          
          END

         SET @Ln_Exists_NUMB = 0;
         SET @Ls_Sql_TEXT = 'CHECK FOR PENDING REQUEST IN CSPR_Y1 FOR Case_IDNO';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', Function_CODE = ' + ISNULL(@Lc_FunctionCasesummary_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionRequest_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Reason_CODE, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusPending_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '');
         
         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM CSPR_Y1 c
          WHERE c.Case_IDNO = @Ln_FcrProRespCur_CaseSubmitted_IDNO
            AND c.Function_CODE = @Lc_FunctionCasesummary_CODE
            AND c.Action_CODE = @Lc_ActionRequest_CODE
            AND c.Reason_CODE = @Lc_Reason_CODE
            AND c.StatusRequest_CODE = @Lc_ReqStatusPending_CODE
            AND c.IVDOutOfStateFips_CODE = @Lc_FcrProRespCur_IVDOutOfStateFips_CODE
            AND c.IVDOutOfStateCase_ID = @Lc_FcrProRespCur_CaseMatched_ID
            AND c.EndValidity_DATE = @Ld_High_DATE;

         IF (@Ln_Exists_NUMB > 0)
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0152_CODE;

           GOTO lx_exception;
          
          END

         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_FcrProRespCur_CaseMatched_ID, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL (@Lc_FcrProRespCur_IVDOutOfStateFips_CODE, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusPending_CODE, '') + ', Function_CODE = ' + ISNULL (@Lc_FunctionCasesummary_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionRequest_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Reason_CODE, '');
        
         EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
          @An_Case_IDNO                    = @Ln_FcrProRespCur_CaseSubmitted_IDNO,
          @An_RespondentMci_IDNO           = @Ln_ZERO_NUMB,
          @Ac_Function_CODE                = @Lc_FunctionCasesummary_CODE,
          @Ac_Action_CODE                  = @Lc_ActionRequest_CODE,
          @Ac_Reason_CODE                  = @Lc_Reason_CODE,
          @Ac_IVDOutOfStateFips_CODE       = @Lc_FcrProRespCur_IVDOutOfStateFips_CODE,
          @Ac_IVDOutOfStateCountyFips_CODE = @Lc_FcrProRespCur_CountyFcrMatchedIdno_TEXT,
          @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateCase_ID         = @Lc_FcrProRespCur_CaseMatched_ID,
          @Ad_Generated_DATE               = @Ad_Run_DATE,
          @Ac_Form_ID                      = @Lc_Space_TEXT,
          @As_FormWeb_URL                  = @Lc_Space_TEXT,
          @An_TransHeader_IDNO             = @Ln_ZERO_NUMB,
          @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
          @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
          @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
          @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
          @Ad_Hearing_DATE                 = @Ld_Low_DATE,
          @Ad_Dismissal_DATE               = @Ld_Low_DATE,
          @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
          @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
          @Ac_Attachment_INDC              = @Lc_ValueN_INDC,
          @Ac_File_ID                      = @Lc_Space_TEXT,
          @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
          @An_TotalArrearsOwed_AMNT        = @Ln_ZERO_NUMB,
          @An_TotalInterestOwed_AMNT       = @Ln_ZERO_NUMB,
          @Ac_Process_ID                   = @Lc_Space_TEXT,
          @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
          @Ac_SignedonWorker_ID              = @Lc_BatchRunUser_TEXT,
          @Ad_Update_DTTM                  = @Ld_Start_DATE,
          @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;
         
         IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
          BEGIN
           
           RAISERROR(50001,16,1);
          END
        END
      END
     ELSE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1176_CODE;

       GOTO lx_exception;
      END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
      
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciIdno_TEXT, 0) + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '');
             
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
         
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO BATE-3 FAILED FOR';

         RAISERROR(50001,16,1);
        END;
       
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
	   	   ROLLBACK TRANSACTION SAVEPROACTIVE_DETAILS;
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
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrProRespCur_MemberMciIdno_TEXT, 0) + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '');

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
	
     SET @Ls_Sql_TEXT = 'UPDATE LFPDE_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     UPDATE LFPDE_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrProRespCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LFPDE_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
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
        
         SET @Ls_ErrorMessage_TEXT = 'BATCH RESTART UPDATE FAILED';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION PROACTIVE_DETAILS; 
       BEGIN TRANSACTION PROACTIVE_DETAILS;  
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION PROACTIVE_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     FETCH NEXT FROM FcrProResp_CUR INTO @Ln_FcrProRespCur_Seq_IDNO, @Lc_FcrProRespCur_Rec_ID, @Lc_FcrProRespCur_TerritoryFips_CODE, @Lc_FcrProRespCur_TypeAction_CODE, @Lc_FcrProRespCur_UserFieldName_TEXT, @Lc_FcrProRespCur_CountyFips_CODE, @Lc_FcrProRespCur_BatchNumb_TEXT, @Lc_FcrProRespCur_FirstName_TEXT, @Lc_FcrProRespCur_MiddleName_TEXT, @Lc_FcrProRespCur_LastName_TEXT, @Lc_FcrProRespCur_ssnsubmitted_NUMB, @Lc_FcrProRespCur_MemberMciIdno_TEXT, @Lc_FcrProRespCur_CaseSubmittedIdno_TEXT, @Lc_FcrProRespCur_Response_CODE, @Lc_FcrProRespCur_CaseMatched_ID, @Lc_FcrProRespCur_IVDOutOfStateFips_CODE, @Lc_FcrProRespCur_TypeCaseMatched_CODE, @Lc_FcrProRespCur_CountyFcrMatchedIdno_TEXT, @Lc_FcrProRespCur_RegistrationMatchedDate_TEXT, @Lc_FcrProRespCur_OrderCaseMatched_INDC, @Lc_FcrProRespCur_PartTypeMatched_CODE, @Lc_FcrProRespCur_MatchedMemberMciIdno_TEXT, @Lc_FcrProRespCur_DeathMatchedDate_TEXT, @Lc_FcrProRespCur_F1AddtlMatched1Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched1Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched1Name_TEXT, @Lc_FcrProRespCur_F1AddtlMatched2Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched2Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched2Name_TEXT, @Lc_FcrProRespCur_F1AddtlMatched3Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched3Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched3Nmae_TEXT, @Lc_FcrProRespCur_F1AddtlMatched4Name_TEXT, @Lc_FcrProRespCur_M1AddtlMatched4Name_TEXT, @Lc_FcrProRespCur_L1AddtlMatched4Nmae_TEXT, @Lc_FcrProRespCur_MemberAssociated1Ssn_NUMB, @Lc_FcrProRespCur_F1Associated1Name_TEXT, @Lc_FcrProRespCur_M1Associated1Name_TEXT, @Lc_FcrProRespCur_L1Associated1Name_TEXT, @Lc_FcrProRespCur_MemberSexAssociated1_CODE, @Lc_FcrProRespCur_TypePartAssociated1_CODE, @Lc_FcrProRespCur_MemberMciAssociated1Idno_TEXT, @Lc_FcrProRespCur_BirthAssociated1Date_TEXT, @Lc_FcrProRespCur_DeathAssociated1Date_TEXT, @Lc_FcrProRespCur_MemberAssociated2Ssn_NUMB, @Lc_FcrProRespCur_F1Associated2Name_TEXT, @Lc_FcrProRespCur_M1Associated2Name_TEXT, @Lc_FcrProRespCur_L1Associated2Name_TEXT, @Lc_FcrProRespCur_MemberSexAssociated2_CODE, @Lc_FcrProRespCur_TypePartAssociated2_CODE, @Lc_FcrProRespCur_MemberMciAssociated2_IDNO, @Lc_FcrProRespCur_BirthAssociated2Date_TEXT, @Lc_FcrProRespCur_DeathAssociated2Date_TEXT, @Lc_FcrProRespCur_MemberAssociated3Ssn_NUMB, @Lc_FcrProRespCur_F1Associated3Name_TEXT, @Lc_FcrProRespCur_M1Associated3Name_TEXT, @Lc_FcrProRespCur_L1Associated3Name_TEXT, @Lc_FcrProRespCur_MemberSexAssociated3_CODE, @Lc_FcrProRespCur_TypePartAssociated3_CODE, @Lc_FcrProRespCur_MemberMciAssociated3_IDNO, @Lc_FcrProRespCur_BirthAssociated3Date_TEXT, @Lc_FcrProRespCur_DeathAssociated3Date_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrProResp_CUR;

   DEALLOCATE FcrProResp_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   
   -- Transaction ends 
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
   
   COMMIT TRANSACTION PROACTIVE_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrProResp_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrProResp_CUR;

     DEALLOCATE FcrProResp_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PROACTIVE_DETAILS;
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
