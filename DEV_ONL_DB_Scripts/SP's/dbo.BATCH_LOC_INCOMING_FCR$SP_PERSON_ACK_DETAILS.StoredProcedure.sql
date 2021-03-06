/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS
Programmer Name		 : IMP Team
Description			 : The process reads the FCR Acknowledge Person/Member details
                       and once the matching member is found Acknowledge
                       details are Updates FADT_Y1 and FPRJ_Y1 tables.
                       In addition to that FCR verified SSN is updated in system.
Frequency			 : Daily
Developed On		 : 04/07/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT
					   BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
					   BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS]
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

    DECLARE  @Lc_ErrorTypeError_CODE				CHAR(1) = 'E',
           @Lc_StatusNoDataFound_CODE				CHAR(1) = 'N',
           @Lc_StatusFailed_CODE					CHAR(1) = 'F',
           @Lc_VerificationStatusBad_CODE			CHAR(1) = 'B',
           @Lc_VerificationStatusGood_CODE			CHAR(1) = 'Y',
           @Lc_TypePrimarySsn_CODE					CHAR(1) = 'P',
           @Lc_TypeSecondarySsn_CODE				CHAR(1) = 'S',
           @Lc_Yes_INDC								CHAR(1) = 'Y',
           @Lc_ProcessY_INDC						CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE					CHAR(1) = 'S',
           @Lc_ActionAdd_CODE						CHAR(1) = 'A',
           @Lc_ResponseAdd_CODE						CHAR(1) = 'A',
           @Lc_ActionChange_CODE					CHAR(1) = 'C',
           @Lc_ResponseChange_CODE					CHAR(1) = 'C',
           @Lc_ActionDelete_CODE					CHAR(1) = 'D',
           @Lc_ResponseDelete_CODE					CHAR(1) = 'D',
           @Lc_ResponseAddHold_CODE					CHAR(1) = 'P',
           @Lc_ResponseChangeHold_CODE				CHAR(1) = 'H',
           @Lc_ResponseDeleteHold_CODE				CHAR(1) = 'X',
           @Lc_ResponseAddReject_CODE				CHAR(1) = 'R',
           @Lc_ResponseChangeReject_CODE			CHAR(1) = 'E',
           @Lc_ResponseDeleteReject_CODE			CHAR(1) = 'F',
           @Lc_ValidityVerifiedSsn_CODE				CHAR(1) = 'V',
           @Lc_ValidityCorrectedSsn_CODE			CHAR(1) = 'C',
           @Lc_ValidityAlternateSsn_CODE			CHAR(1) = 'E',
           @Lc_ValidityProvidedSsn_CODE				CHAR(1) = 'P',
           @Lc_ValidityIrsSsn_CODE					CHAR(1) = 'S',
           @Lc_ValidityMultipleSsn_CODE				CHAR(1) = 'R',
           @Lc_TypeErrorF_CODE						CHAR(1) = 'F',
           @Lc_ErrorE0892_CODE						CHAR(5) = 'E0892',
           @Lc_AcknowledgeAccept_CODE				CHAR(5) = 'AAAAA',
           @Lc_AcknowledgeHold_CODE					CHAR(5) = 'HOLDS',
           @Lc_AcknowledgeReject_CODE				CHAR(5) = 'REJCT',
           @Lc_ErrorI0076_CODE						CHAR(5) = 'I0076',
           @Lc_ErrorE0899_CODE						CHAR(5) = 'E0899',
           @Lc_BateErrorE1424_CODE					CHAR(5) = 'E1424',
           @Lc_DateFormatYyyymmdd_TEXT				CHAR(8) = 'YYYYMMDD',
           @Lc_MemberSsn000000000_TEXT				CHAR(9) = '000000000',
           @Ls_Procedure_NAME						VARCHAR(60) = 'SP_PERSON_ACK_DETAILS',
           @Ld_High_DATE							DATE = '12/31/9999',
           @Ld_Low_DATE								DATE = '01/01/0001';
  DECLARE  @Ln_Exists_NUMB							NUMERIC(1) = 0,
           @Ln_Zero_NUMB							NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY						NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY				NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY			NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY		NUMERIC(6) = 0,
           @Ln_MemberSsn_NUMB						NUMERIC(9) = 0,
           @Ln_MemberSsnDemo_NUMB					NUMERIC(9) = 0,
           @Ln_TempSsn_NUMB							NUMERIC(9) = 0,
           @Ln_Cur_QNTY								NUMERIC(10,0) = 0,
           @Ln_Error_NUMB							NUMERIC(11),
           @Ln_ErrorLine_NUMB						NUMERIC(11),
           @Li_FetchStatus_QNTY						SMALLINT,
           @Li_RowCount_QNTY						SMALLINT,
           @Lc_Space_TEXT							CHAR(1) = '',
           @Lc_ResponseFcr_CODE						CHAR(1) = '',
           @Lc_TypeError_CODE						CHAR(1) = '',
           @Lc_Msg_CODE								CHAR(5),
           @Lc_BateError_CODE						CHAR(5) = '',
           @Ls_Sql_TEXT								VARCHAR(100),
           @Ls_CursorLoc_TEXT						VARCHAR(200),
           @Ls_Sqldata_TEXT							VARCHAR(1000),
           @Ls_ErrorDesc_TEXT						VARCHAR(4000),
           @Ls_DescriptionError_TEXT				VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT					VARCHAR(4000),
           @Ls_BateRecord_TEXT						VARCHAR(4000) = '',
           @Ld_Birth_DATE							DATE,
           @Ld_Deceased_DATE						DATE,
           @Ld_Temp_DATE							DATE, 
           @Ld_BirthSsa_DATE						DATE;   

  DECLARE @Ln_FcrMemAckCur_Seq_IDNO					NUMERIC(19),
          @Lc_FcrMemAckCur_Rec_ID					CHAR(2),
          @Lc_FcrMemAckCur_Action_CODE				CHAR(1),
          @Lc_FcrMemAckCur_CaseIdno_TEXT			CHAR(6),
          @Lc_FcrMemAckCur_FcrReserved_CODE			CHAR(2),
          @Lc_FcrMemAckCur_UserFieldName_TEXT		CHAR(15),
          @Lc_FcrMemAckCur_CountyIdno_TEXT			CHAR(3),
          @Lc_FcrMemAckCur_TypeLocRequest_CODE		CHAR(2),
          @Lc_FcrMemAckCur_BundleResult_INDC		CHAR(1),
          @Lc_FcrMemAckCur_TypeParticipant_CODE		CHAR(2),
          @Lc_FcrMemAckCur_FamilyViolence_CODE		CHAR(2),
          @Lc_FcrMemAckCur_MemberMciIdno_TEXT		CHAR(10),
          @Lc_FcrMemAckCur_MemberSex_CODE			CHAR(1),
          @Lc_FcrMemAckCur_BirthDate_TEXT			CHAR(8),
          @Lc_FcrMemAckCur_MemberSsnNumb_TEXT		CHAR(9),
          @Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT CHAR(9),
          @Lc_FcrMemAckCur_FirstName_TEXT			CHAR(16),
          @Lc_FcrMemAckCur_MiddleName_TEXT			CHAR(16),
          @Lc_FcrMemAckCur_LastName_TEXT			CHAR(30),
          @Lc_FcrMemAckCur_BirthCityName_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_BirthStCountry_CODE		CHAR(4),
          @Lc_FcrMemAckCur_FirstFatherName_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_MiFatherName_TEXT		CHAR(1),
          @Lc_FcrMemAckCur_LastFatherName_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_FirstMotherName_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_MiMotherName_TEXT		CHAR(1),
          @Lc_FcrMemAckCur_LastMotherName_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_IrsU1SsnNumb_TEXT		CHAR(9),
          @Lc_FcrMemAckCur_Additional1SsnNumb_TEXT	CHAR(9),
          @Lc_FcrMemAckCur_Additional2SsnNumb_TEXT	CHAR(9),
          @Lc_FcrMemAckCur_FirstAlias1Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_MiAlias1Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_LastAlias1Name_TEXT		CHAR(30),
          @Lc_FcrMemAckCur_FirstAlias2Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_MiAlias2Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_LastAlias2Name_TEXT		CHAR(30),
          @Lc_FcrMemAckCur_FirstAlias3Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_MiAlias3Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_LastAlias3Name_TEXT		CHAR(30),
          @Lc_FcrMemAckCur_FirstAlias4Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_MiAlias4Name_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_LastAlias4Name_TEXT		CHAR(30),
          @Lc_FcrMemAckCur_NewMemberMciIdno_TEXT	CHAR(10),
          @Lc_FcrMemAckCur_Irs1099_INDC				CHAR(1),
          @Lc_FcrMemAckCur_LocateSource1_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource2_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource3_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource4_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource5_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource6_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource7_CODE		CHAR(3),
          @Lc_FcrMemAckCur_LocateSource8_CODE		CHAR(3),
          @Lc_FcrMemAckCur_Enumeration_CODE			CHAR(1),
          @Lc_FcrMemAckCur_CorrectSsnNumb_TEXT		CHAR(9),
          @Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT	CHAR(9),
          @Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT	CHAR(9),
          @Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT	CHAR(9),
          @Lc_FcrMemAckCur_DateBirthSsa_INDC		CHAR(1),
          @Lc_FcrMemAckCur_BatchNumb_TEXT			CHAR(6),
          @Lc_FcrMemAckCur_DeathDate_TEXT			CHAR(8),
          @Lc_FcrMemAckCur_ZipLastResiSsa_CODE		CHAR(5),
          @Lc_FcrMemAckCur_ZipOfPaymentSsa_CODE		CHAR(5),
          @Lc_FcrMemAckCur_PrimarySsnNumb_TEXT		CHAR(9),
          @Lc_FcrMemAckCur_FirstPrimaryName_TEXT	CHAR(16),
          @Lc_FcrMemAckCur_MiPrimaryName_TEXT		CHAR(16),
          @Lc_FcrMemAckCur_LastPrimaryName_TEXT		CHAR(30),
          @Lc_FcrMemAckCur_Acknowledge_CODE			CHAR(5),
          @Lc_FcrMemAckCur_Error1_CODE				CHAR(5),
          @Lc_FcrMemAckCur_Error2_CODE				CHAR(5),
          @Lc_FcrMemAckCur_Error3_CODE				CHAR(5),
          @Lc_FcrMemAckCur_Error4_CODE				CHAR(5),
          @Lc_FcrMemAckCur_Error5_CODE				CHAR(5),
		  @Ln_FcrMemAckCur_Case_IDNO			  NUMERIC(6),
		  @Ln_FcrMemAckCur_County_IDNO			  NUMERIC(3),
		  @Ln_FcrMemAckCur_MemberMci_IDNO		  NUMERIC(10),
		  @Ld_FcrMemAckCur_Birth_DATE			  DATE,
		  @Ln_FcrMemAckCur_MemberSsn_NUMB		  NUMERIC(9),
		  @Ln_FcrMemAckCur_PreviousMemberSsn_NUMB NUMERIC(9),
		  @Ln_FcrMemAckCur_CorrectSsn_NUMB		  NUMERIC(9),
		  @Ln_FcrMemAckCur_Multiple1Ssn_NUMB	  NUMERIC(9),
		  @Ln_FcrMemAckCur_Multiple2Ssn_NUMB	  NUMERIC(9),
		  @Ln_FcrMemAckCur_Multiple3Ssn_NUMB	  NUMERIC(9),
		  @Ln_FcrMemAckCur_PrimarySsn_NUMB		  NUMERIC(9);          
  DECLARE FcrMemAck_CUR INSENSITIVE CURSOR FOR 
   SELECT m.Seq_IDNO,
          m.Rec_ID,
          m.Action_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.Case_IDNO, '')))) = 0
            THEN '0'
           ELSE m.Case_IDNO
          END AS Case_IDNO,
          m.FcrReserved_CODE,
          m.UserField_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.CountyFips_CODE, '')))) = 0
            THEN '0'
           ELSE m.CountyFips_CODE
          END AS CountyFips_CODE,
          m.TypeLocRequest_CODE,
          m.BundleResult_INDC,
          m.TypeParticipant_CODE,
          m.FamilyViolence_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.MemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE m.MemberMci_IDNO
          END AS MemberMci_IDNO,
          m.MemberSex_CODE,
          m.Birth_DATE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.MemberSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.MemberSsn_NUMB
          END AS MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.PreviousMemberSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.PreviousMemberSsn_NUMB
          END AS PreviousMemberSsn_NUMB,
          m.First_NAME,
          m.Middle_NAME,
          m.Last_NAME,
          m.BirthCity_NAME,
          m.BirthStCountry_CODE,
          m.FirstFather_NAME,
          m.MiddleFather_NAME,
          m.LastFather_NAME,
          m.FirstMother_NAME,
          m.MiddleMother_NAME,
          m.LastMother_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.IrsU1Ssn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.IrsU1Ssn_NUMB
          END AS IrsU1Ssn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.Additional1Ssn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.Additional1Ssn_NUMB
          END AS Additional1Ssn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.Additional2Ssn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.Additional2Ssn_NUMB
          END AS Additional2Ssn_NUMB,
          m.FirstAlias1_NAME,
          m.MiddleAlias1_NAME,
          m.LastAlias1_NAME,
          m.FirstAlias2_NAME,
          m.MiddleAlias2_NAME,
          m.LastAlias2_NAME,
          m.FirstAlias3_NAME,
          m.MiddleAlias3_NAME,
          m.LastAlias3_NAME,
          m.FirstAlias4_NAME,
          m.MiddleAlias4_NAME,
          m.LastAlias4_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.NewMemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE m.NewMemberMci_IDNO
          END AS NewMemberMci_IDNO,
          m.Irs1099_INDC,
          m.LocateSource1_CODE,
          m.LocateSource2_CODE,
          m.LocateSource3_CODE,
          m.LocateSource4_CODE,
          m.LocateSource5_CODE,
          m.LocateSource6_CODE,
          m.LocateSource7_CODE,
          m.LocateSource8_CODE,
          m.Enumeration_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.CorrectedSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.CorrectedSsn_NUMB
          END AS CorrectedSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.Multiple1Ssn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.Multiple1Ssn_NUMB
          END AS Multiple1Ssn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.Multiple2Ssn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.Multiple2Ssn_NUMB
          END AS Multiple2Ssn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.Multiple3Ssn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.Multiple3Ssn_NUMB
          END AS Multiple3Ssn_NUMB,
          m.DateBirthSsa_INDC,
          m.Batch_NUMB,
          m.Death_DATE,
          m.ZipLastResiSsa_CODE,
          m.ZipOfPaymentSsa_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(m.PrimarySsn_NUMB, '')))) = 0
            THEN '0'
           ELSE m.PrimarySsn_NUMB
          END AS PrimarySsn_NUMB,
          m.FirstPrimary_NAME,
          m.MiddlePrimary_NAME,
          m.LastPrimary_NAME,
          m.Acknowledge_CODE,
          m.Error1_CODE,
          m.Error2_CODE,
          m.Error3_CODE,
          m.Error4_CODE,
          m.Error5_CODE
         
     FROM LFPAD_Y1 m
    WHERE m.Process_INDC = 'N'
    ORDER BY Batch_NUMB;
  
  BEGIN TRY
   BEGIN TRANSACTION PERSONACK_DETAILS;
  
   SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL (@An_CommitFreq_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL (@An_ExceptionThreshold_QNTY, 0);
   SET @Ln_Cur_QNTY = 0;
   SET @Ln_CommitFreq_QNTY = 0;
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_ErrorDesc_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = 0;
   SET @Ls_Sql_TEXT = 'OPENING FcrMemAck_CUR CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');
  
   OPEN FcrMemAck_CUR;

   SET @Ls_Sql_TEXT = 'FETCHING FcrMemAck_CUR CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');
   
   FETCH NEXT FROM FcrMemAck_CUR INTO @Ln_FcrMemAckCur_Seq_IDNO, @Lc_FcrMemAckCur_Rec_ID, @Lc_FcrMemAckCur_Action_CODE, @Lc_FcrMemAckCur_CaseIdno_TEXT, @Lc_FcrMemAckCur_FcrReserved_CODE, @Lc_FcrMemAckCur_UserFieldName_TEXT, @Lc_FcrMemAckCur_CountyIdno_TEXT, @Lc_FcrMemAckCur_TypeLocRequest_CODE, @Lc_FcrMemAckCur_BundleResult_INDC, @Lc_FcrMemAckCur_TypeParticipant_CODE, @Lc_FcrMemAckCur_FamilyViolence_CODE, @Lc_FcrMemAckCur_MemberMciIdno_TEXT, @Lc_FcrMemAckCur_MemberSex_CODE, @Lc_FcrMemAckCur_BirthDate_TEXT, @Lc_FcrMemAckCur_MemberSsnNumb_TEXT, @Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT, @Lc_FcrMemAckCur_FirstName_TEXT, @Lc_FcrMemAckCur_MiddleName_TEXT, @Lc_FcrMemAckCur_LastName_TEXT, @Lc_FcrMemAckCur_BirthCityName_TEXT, @Lc_FcrMemAckCur_BirthStCountry_CODE, @Lc_FcrMemAckCur_FirstFatherName_TEXT, @Lc_FcrMemAckCur_MiFatherName_TEXT, @Lc_FcrMemAckCur_LastFatherName_TEXT, @Lc_FcrMemAckCur_FirstMotherName_TEXT, @Lc_FcrMemAckCur_MiMotherName_TEXT, @Lc_FcrMemAckCur_LastMotherName_TEXT, @Lc_FcrMemAckCur_IrsU1SsnNumb_TEXT, @Lc_FcrMemAckCur_Additional1SsnNumb_TEXT, @Lc_FcrMemAckCur_Additional2SsnNumb_TEXT, @Lc_FcrMemAckCur_FirstAlias1Name_TEXT, @Lc_FcrMemAckCur_MiAlias1Name_TEXT, @Lc_FcrMemAckCur_LastAlias1Name_TEXT, @Lc_FcrMemAckCur_FirstAlias2Name_TEXT, @Lc_FcrMemAckCur_MiAlias2Name_TEXT, @Lc_FcrMemAckCur_LastAlias2Name_TEXT, @Lc_FcrMemAckCur_FirstAlias3Name_TEXT, @Lc_FcrMemAckCur_MiAlias3Name_TEXT, @Lc_FcrMemAckCur_LastAlias3Name_TEXT, @Lc_FcrMemAckCur_FirstAlias4Name_TEXT, @Lc_FcrMemAckCur_MiAlias4Name_TEXT, @Lc_FcrMemAckCur_LastAlias4Name_TEXT, @Lc_FcrMemAckCur_NewMemberMciIdno_TEXT, @Lc_FcrMemAckCur_Irs1099_INDC, @Lc_FcrMemAckCur_LocateSource1_CODE, @Lc_FcrMemAckCur_LocateSource2_CODE, @Lc_FcrMemAckCur_LocateSource3_CODE, @Lc_FcrMemAckCur_LocateSource4_CODE, @Lc_FcrMemAckCur_LocateSource5_CODE, @Lc_FcrMemAckCur_LocateSource6_CODE, @Lc_FcrMemAckCur_LocateSource7_CODE, @Lc_FcrMemAckCur_LocateSource8_CODE, @Lc_FcrMemAckCur_Enumeration_CODE, @Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, @Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT, @Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT, @Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT, @Lc_FcrMemAckCur_DateBirthSsa_INDC, @Lc_FcrMemAckCur_BatchNumb_TEXT, @Lc_FcrMemAckCur_DeathDate_TEXT, @Lc_FcrMemAckCur_ZipLastResiSsa_CODE, @Lc_FcrMemAckCur_ZipOfPaymentSsa_CODE, @Lc_FcrMemAckCur_PrimarySsnNumb_TEXT, @Lc_FcrMemAckCur_FirstPrimaryName_TEXT, @Lc_FcrMemAckCur_MiPrimaryName_TEXT, @Lc_FcrMemAckCur_LastPrimaryName_TEXT, @Lc_FcrMemAckCur_Acknowledge_CODE, @Lc_FcrMemAckCur_Error1_CODE, @Lc_FcrMemAckCur_Error2_CODE, @Lc_FcrMemAckCur_Error3_CODE, @Lc_FcrMemAckCur_Error4_CODE, @Lc_FcrMemAckCur_Error5_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVEPERSONACK_DETAILS;
    
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Lc_ResponseFcr_CODE = '';
     SET @Ls_CursorLoc_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '') + ', CURSOR_COUNT = ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Ln_Exists_NUMB = 0;
     SET @Ls_BateRecord_TEXT = 'Rec_ID = ' + ISNULL(@Lc_FcrMemAckCur_Rec_ID, '') + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', FcrReserved_CODE = ' + ISNULL(@Lc_FcrMemAckCur_FcrReserved_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_FcrMemAckCur_UserFieldName_TEXT, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_FcrMemAckCur_CountyIdno_TEXT, 0) + ', TypeLocRequest_CODE = ' + ISNULL(@Lc_FcrMemAckCur_TypeLocRequest_CODE, '') + ', BundleResult_INDC = ' + ISNULL(@Lc_FcrMemAckCur_BundleResult_INDC, '') + ', TypeParticipant_CODE = ' + ISNULL (@Lc_FcrMemAckCur_TypeParticipant_CODE, '') + ', FamilyViolence_CODE = ' + ISNULL (@Lc_FcrMemAckCur_FamilyViolence_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSex_CODE = ' + ISNULL(@Lc_FcrMemAckCur_MemberSex_CODE, '') + ', Birth_DATE = ' + ISNULL(@Lc_FcrMemAckCur_BirthDate_TEXT, '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_MemberSsnNumb_TEXT, 0) + ', PreviousMemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT, '') + ', First_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstName_TEXT, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiddleName_TEXT, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrMemAckCur_LastName_TEXT, '') + ', BirthCity_NAME = ' + ISNULL(@Lc_FcrMemAckCur_BirthCityName_TEXT, '') + ', BirthStCountry_CODE = ' + ISNULL(@Lc_FcrMemAckCur_BirthStCountry_CODE, '') + ', FirstFather_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstFatherName_TEXT, '') + ', MiFather_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiFatherName_TEXT, '') + ', LastFather_NAME = ' + ISNULL(@Lc_FcrMemAckCur_LastFatherName_TEXT, '') + ', FirstMother_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstMotherName_TEXT, '') + ', MiMother_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiMotherName_TEXT, '') + ', LastMother_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastMotherName_TEXT, '') + ', IrsU1Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_IrsU1SsnNumb_TEXT, 0) + ', Additional1Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Additional1SsnNumb_TEXT, 0) + ', Additional2Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Additional2SsnNumb_TEXT, 0) + ', FirstAlias1_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstAlias1Name_TEXT, '') + ', MiAlias1_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias1Name_TEXT, '') + ', LastAlias1_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias1Name_TEXT, '') + ', FirstAlias2_NAME = ' + ISNULL (@Lc_FcrMemAckCur_FirstAlias2Name_TEXT, '') + ', MiAlias2_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias2Name_TEXT, '') + ', LastAlias2_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias2Name_TEXT, '') + ', FirstAlias3_NAME = ' + ISNULL (@Lc_FcrMemAckCur_FirstAlias3Name_TEXT, '') + ', MiAlias3_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias3Name_TEXT, '') + ', LastAlias3_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias3Name_TEXT, '') + ', FirstAlias4_NAME = ' + ISNULL (@Lc_FcrMemAckCur_FirstAlias4Name_TEXT, '') + ', MiAlias4_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias4Name_TEXT, '') + ', LastAlias4_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias4Name_TEXT, '') + ', NewMemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_NewMemberMciIdno_TEXT, 0) + ', Irs1099_INDC = ' + ISNULL(@Lc_FcrMemAckCur_Irs1099_INDC, '') + ', LocateSource1_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource1_CODE, '') + ', LocateSource2_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource2_CODE, '') + ', LocateSource3_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource3_CODE, '') + ', LocateSource4_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource4_CODE, '') + ', LocateSource5_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource5_CODE, '') + ', LocateSource6_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource6_CODE, '') + ', LocateSource7_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource7_CODE, '') + ', LocateSource8_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource8_CODE, '') + ', Enumeration_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Enumeration_CODE, '') + ', SSN_CORRECT = ' + ISNULL(@Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, 0) + ', Multiple1Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT, 0) + ', Multiple2Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT, 0) + ', Multiple3Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT, 0) + ', DateBirthSsa_INDC = ' + ISNULL(@Lc_FcrMemAckCur_DateBirthSsa_INDC, '') + ', Batch_NUMB = ' + ISNULL (@Lc_FcrMemAckCur_BatchNumb_TEXT, '') + ', Death_DATE = ' + ISNULL(@Lc_FcrMemAckCur_DeathDate_TEXT, '') + ', ZipLastResiSsa_CODE = ' + ISNULL(@Lc_FcrMemAckCur_ZipLastResiSsa_CODE, '') + ', ZipOfPaymentSsa_CODE = ' + ISNULL (@Lc_FcrMemAckCur_ZipOfPaymentSsa_CODE, '') + ', PrimarySsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_PrimarySsnNumb_TEXT, 0) + ', FirstPrimary_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstPrimaryName_TEXT, '') + ', MiPrimary_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiPrimaryName_TEXT, '') + ', LastPrimary_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastPrimaryName_TEXT, '') + ', Acknowledge_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Acknowledge_CODE, '') + ', Error1_CODE = ' + ISNULL (@Lc_FcrMemAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error5_CODE, '');

     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN FADT_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '');
          
     IF ISNUMERIC(@Lc_FcrMemAckCur_CaseIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrMemAckCur_Case_IDNO = @Lc_FcrMemAckCur_CaseIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrMemAckCur_Case_IDNO = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_FcrMemAckCur_MemberMciIdno_TEXT) = 1
		BEGIN 
			SET @Ln_FcrMemAckCur_MemberMci_IDNO = @Lc_FcrMemAckCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrMemAckCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
	IF ISNUMERIC (@Lc_FcrMemAckCur_MemberSsnNumb_TEXT) = 1 
		BEGIN 
			SET @Ln_FcrMemAckCur_MemberSsn_NUMB = @Lc_FcrMemAckCur_MemberSsnNumb_TEXT;
		END
	ELSE
		BEGIN
			SET @Ln_FcrMemAckCur_MemberSsn_NUMB = @Ln_Zero_NUMB;
		END
	IF ISNUMERIC (@Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT) = 1 
		BEGIN 
			SET @Ln_FcrMemAckCur_PreviousMemberSsn_NUMB = @Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT;
		END
	ELSE
		BEGIN
			SET @Ln_FcrMemAckCur_PreviousMemberSsn_NUMB = @Ln_Zero_NUMB;
		END
	
	SET @Ln_FcrMemAckCur_County_IDNO	= @Lc_FcrMemAckCur_CountyIdno_TEXT;
	
	SET @Ln_FcrMemAckCur_CorrectSsn_NUMB = @Lc_FcrMemAckCur_CorrectSsnNumb_TEXT;
	SET @Ln_FcrMemAckCur_Multiple1Ssn_NUMB = @Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT;
	SET @Ln_FcrMemAckCur_Multiple2Ssn_NUMB = @Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT ;
	SET @Ln_FcrMemAckCur_Multiple3Ssn_NUMB = @Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT;
	SET @Ln_FcrMemAckCur_PrimarySsn_NUMB   = @Lc_FcrMemAckCur_PrimarySsnNumb_TEXT;
	    
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM FADT_Y1 f
      WHERE f.Case_IDNO = @Ln_FcrMemAckCur_Case_IDNO
        AND f.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT2';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '');
       SET @Ld_FcrMemAckCur_Birth_DATE = SUBSTRING(CONVERT(VARCHAR(8), @Lc_FcrMemAckCur_BirthDate_TEXT, 112), 1 , 8);
       IF @Ld_FcrMemAckCur_Birth_DATE IS NULL
		 BEGIN
			SET  @Ld_FcrMemAckCur_Birth_DATE = @Ld_Low_DATE;
		 END
	      
       EXECUTE BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT
        @An_Case_IDNO             = @Ln_FcrMemAckCur_Case_IDNO,
        @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
        @Ac_Action_CODE           = @Lc_FcrMemAckCur_Action_CODE,
        @Ac_TypeTrans_CODE        = @Lc_FcrMemAckCur_Rec_ID,
        @Ac_TypeCase_CODE         = @Lc_Space_TEXT,
        @An_County_IDNO           = @Ln_FcrMemAckCur_County_IDNO,
        @Ac_Order_INDC            = @Lc_Space_TEXT,
        @An_MemberSsn_NUMB        = @Ln_FcrMemAckCur_MemberSsn_NUMB,
        @Ad_Birth_DATE            = @Ld_FcrMemAckCur_Birth_DATE,
        @Ac_Last_NAME             = @Lc_FcrMemAckCur_LastName_TEXT,
        @Ac_First_NAME            = @Lc_FcrMemAckCur_FirstName_TEXT,
        @An_Batch_NUMB            = @Lc_FcrMemAckCur_BatchNumb_TEXT,
        @Ac_TypeParticipant_CODE  = @Lc_FcrMemAckCur_TypeParticipant_CODE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0892_CODE;

         -- Add record to the BATE_Y1 table and continue the process
         GOTO lx_exception;
        END
       ELSE
        BEGIN
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           
           RAISERROR(50001,16,1);
          END
        END
      END

     SET @Ls_Sql_TEXT = 'SET ACKNOWLEGDE FLAG';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');

     IF @Lc_FcrMemAckCur_Acknowledge_CODE = @Lc_AcknowledgeAccept_CODE
      BEGIN
       IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionAdd_CODE
        BEGIN
         SET @Lc_ResponseFcr_CODE = @Lc_ResponseAdd_CODE;
        END
       ELSE IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionChange_CODE
        BEGIN
         SET @Lc_ResponseFcr_CODE = @Lc_ResponseChange_CODE;
        END
       ELSE
        BEGIN
         IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionDelete_CODE
          BEGIN
           SET @Lc_ResponseFcr_CODE = @Lc_ResponseDelete_CODE;
          END
        END
      END
     ELSE
      BEGIN
       IF @Lc_FcrMemAckCur_Acknowledge_CODE = @Lc_AcknowledgeHold_CODE
        BEGIN
         IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionAdd_CODE
          BEGIN
           SET @Lc_ResponseFcr_CODE = @Lc_ResponseAddHold_CODE;
          END
         ELSE
          BEGIN
           IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionChange_CODE
            BEGIN
             SET @Lc_ResponseFcr_CODE = @Lc_ResponseChangeHold_CODE;
            END
           ELSE
            BEGIN
             IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionDelete_CODE
              BEGIN
               SET @Lc_ResponseFcr_CODE = @Lc_ResponseDeleteHold_CODE;
              END
            END
          END
        END
       ELSE
        BEGIN
         IF @Lc_FcrMemAckCur_Acknowledge_CODE = @Lc_AcknowledgeReject_CODE
          BEGIN
           IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionAdd_CODE
            BEGIN
             SET @Lc_ResponseFcr_CODE = @Lc_ResponseAddReject_CODE;
            END
           ELSE
            BEGIN
             IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionChange_CODE
              BEGIN
               SET @Lc_ResponseFcr_CODE = @Lc_ResponseChangeReject_CODE;
              END
             ELSE
              BEGIN
               IF @Lc_FcrMemAckCur_Action_CODE = @Lc_ActionDelete_CODE
                BEGIN
                 SET @Lc_ResponseFcr_CODE = @Lc_ResponseDeleteReject_CODE;
                END
              END
            END

           SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS2';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT,  0) + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '') + ', Error1_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error1_CODE, '');

           EXECUTE BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS
            @Ad_Run_DATE              = @Ad_Run_DATE,
            @An_Case_IDNO             = @Ln_FcrMemAckCur_Case_IDNO,
            @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
            @Ac_Action_CODE           = @Lc_FcrMemAckCur_Action_CODE,
            @Ac_Error1_CODE           = @Lc_FcrMemAckCur_Error1_CODE,
            @Ac_Error2_CODE           = @Lc_FcrMemAckCur_Error2_CODE,
            @Ac_Error3_CODE           = @Lc_FcrMemAckCur_Error3_CODE,
            @Ac_Error4_CODE           = @Lc_FcrMemAckCur_Error4_CODE,
            @Ac_Error5_CODE           = @Lc_FcrMemAckCur_Error5_CODE,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
            
             RAISERROR(50001,16,1);
            END
          END
        END
      END

     SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS2';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Response_CODE = ' + ISNULL(@Lc_ResponseFcr_CODE, '');

     EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @An_Case_IDNO             = @Ln_FcrMemAckCur_Case_IDNO,
      @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
      @Ac_Response_CODE         = @Lc_ResponseFcr_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       RAISERROR(50001,16,1);
      END

     --FCR Provided SSN - Update Process.
     /*
     -- FCR provided validity code for SSN verification.
     --------------------------------------------------------------------
     -- V -Verified  - The SSN and Name combination submitted was verified by the SSA SSN verification routines
     -- C -Corrected - The SSN submitted for this person was corrected
     -- E -Alternate - The SSN and Name combination submitted for this person could not be verified or corrected but the additional person data provided identified an SSN for this person
     -- P -Provided  - The SSN was not submitted, but the additional person data submitted identified an SSN for this person without manual intervention and is provided; or the SSN provided did not verify but an SSN was identified using SSA's alpha search
     -- S -Irs       - The IRS-U SSN submitted allowed the SSN to be identified using the IRS information
     -- R -Multiple  - The person data submitted identified multiple possible SSNs for the person and the provided SSN was selected via the Requires Manual Review process
     -- Space - The SSN provided could not be verified or there was no SSN provided and one could not be identified using the information submitted. See the fields Error Code 1 through Error Code 5 for a more specific explanation of the condition.
     */
     
     IF @Lc_FcrMemAckCur_Acknowledge_CODE = @Lc_AcknowledgeAccept_CODE
      BEGIN
       
       SET @Ln_MemberSsn_NUMB = @Ln_Zero_NUMB; 
       SET @Ls_Sql_TEXT = 'SELECT FROM DEMO_Y1 1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Last_NAME = ' + ISNULL(@Lc_FcrMemAckCur_LastName_TEXT, '');
      
       SELECT @Ln_MemberSsnDemo_NUMB = d.MemberSsn_NUMB,
              @Ld_Birth_DATE = d.Birth_DATE,
              @Ld_Deceased_DATE = d.Deceased_DATE
         FROM DEMO_Y1 d
        WHERE d.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         -- member record not found 
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorI0076_CODE;

         GOTO lx_exception;
        END

       SET @Ls_Sql_TEXT = 'CHECK FOR FCR PROVIDED MemberSsn_NUMB AND DT_BIRTH1';
       SET @Ls_Sqldata_TEXT = 'CD_ENUMERATION_FCR = ' + ISNULL(@Lc_FcrMemAckCur_Enumeration_CODE, '') + ', SSN_CORRECT = ' + ISNULL(@Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, 0) + ', DateBirthSsa_INDC = ' + ISNULL(@Lc_FcrMemAckCur_DateBirthSsa_INDC, '') + ', Birth_DATE = ' + ISNULL (@Lc_FcrMemAckCur_BirthDate_TEXT, '');

       IF (@Lc_FcrMemAckCur_Enumeration_CODE = @Lc_ValidityVerifiedSsn_CODE
           AND @Ln_FcrMemAckCur_CorrectSsn_NUMB = 0)
        BEGIN
         IF @Ln_FcrMemAckCur_PrimarySsn_NUMB = @Ln_FcrMemAckCur_MemberSsn_NUMB
            AND @Ln_FcrMemAckCur_MemberSsn_NUMB != 0 
          BEGIN
           SET @Ln_MemberSsn_NUMB = @Ln_FcrMemAckCur_MemberSsn_NUMB;
           SET @Ln_Exists_NUMB = 0;
           SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB-V IN MSSN_Y1 WITH OTHER MEMBER';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_MemberSsnNumb_TEXT, 0);

           SELECT @Ln_Exists_NUMB = COUNT(1)
             FROM MSSN_Y1
            WHERE MSSN_Y1.MemberMci_IDNO != @Ln_FcrMemAckCur_MemberMci_IDNO
              AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_MemberSsn_NUMB
              AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE
              AND MSSN_Y1.Enumeration_CODE != @Lc_VerificationStatusBad_CODE;

           IF @Ln_Exists_NUMB > 0
            BEGIN
             SET @Lc_BateError_CODE = @Lc_ErrorE0899_CODE;
             SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

             GOTO lx_exception;
            
            END

           SET @Ln_Exists_NUMB = 0;
           SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB-V IN MSSN_Y1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_MemberSsnNumb_TEXT, 0);

           SELECT @Ln_Exists_NUMB = COUNT(1)
             FROM MSSN_Y1
            WHERE MSSN_Y1.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO
              AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_MemberSsn_NUMB
              AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE
              AND MSSN_Y1.Enumeration_CODE = @Lc_VerificationStatusGood_CODE;

           IF (@Ln_Exists_NUMB = 0
               AND @Lc_FcrMemAckCur_Enumeration_CODE = @Lc_ValidityVerifiedSsn_CODE
               AND LTRIM(RTRIM(@Ln_MemberSsn_NUMB)) != 0
               AND @Ln_FcrMemAckCur_CorrectSsn_NUMB = 0)
            BEGIN
             SET @Ln_MemberSsn_NUMB = @Ln_FcrMemAckCur_MemberSsn_NUMB;
             SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN-1';
             SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + CAST(@Ln_FcrMemAckCur_MemberSsn_NUMB AS VARCHAR);

             EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
              @Ad_Run_DATE              = @Ad_Run_DATE,
              @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
              @An_MemberSsn_NUMB        = @Ln_MemberSsn_NUMB,
              @Ac_TypePrimarySsn_CODE   = @Lc_TypePrimarySsn_CODE,
              @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
             
             IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
              BEGIN
               
               SET @Lc_BateError_CODE = @Lc_Msg_CODE;
               RAISERROR(50001,16,1);
              END
            END
          END
        END
       ELSE
        BEGIN
         IF (@Lc_FcrMemAckCur_Enumeration_CODE IN (@Lc_ValidityCorrectedSsn_CODE, @Lc_ValidityAlternateSsn_CODE, @Lc_ValidityProvidedSsn_CODE, @Lc_ValidityIrsSsn_CODE, @Lc_ValidityMultipleSsn_CODE)
             AND @Ln_FcrMemAckCur_CorrectSsn_NUMB != 0)
          BEGIN
           
           SET @Ln_Exists_NUMB = 0;
           SET @Ln_MemberSsn_NUMB = @Ln_FcrMemAckCur_CorrectSsn_NUMB;
           SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF SSN1 IN MSSN_Y1 WITH OTHER MEMBER';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB: ' + ISNULL(@Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, 0);

           SELECT @Ln_Exists_NUMB = COUNT(1)
             FROM MSSN_Y1
            WHERE MSSN_Y1.MemberMci_IDNO != @Ln_FcrMemAckCur_MemberMci_IDNO
              AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_CorrectSsn_NUMB
              AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE
              AND MSSN_Y1.Enumeration_CODE != @Lc_VerificationStatusBad_CODE;

           IF @Ln_Exists_NUMB > 0
            BEGIN
             SET @Lc_BateError_CODE = @Lc_ErrorE0899_CODE;
             SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

             GOTO lx_exception;
            
            END

           SET @Ln_Exists_NUMB = 0;
           SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB-V IN MSSN_Y1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, 0);
           
           SELECT @Ln_Exists_NUMB = COUNT(1)
             FROM MSSN_Y1
            WHERE MSSN_Y1.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO
              AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_CorrectSsn_NUMB
              AND MSSN_Y1.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
              AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE;

           IF @Ln_Exists_NUMB = 0
              AND LTRIM(RTRIM(@Ln_MemberSsn_NUMB)) != 0 
            BEGIN
             SET @Ln_MemberSsn_NUMB = @Ln_FcrMemAckCur_CorrectSsn_NUMB;

             SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN-2';
             SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + CAST(@Ln_MemberSsn_NUMB AS VARCHAR);

             EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
              @Ad_Run_DATE              = @Ad_Run_DATE,
              @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
              @An_MemberSsn_NUMB        = @Ln_MemberSsn_NUMB,
              @Ac_TypePrimarySsn_CODE   = @Lc_TypePrimarySsn_CODE,
              @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
             
             IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
              BEGIN
              
			   SET @Lc_BateError_CODE = @Lc_Msg_CODE;
               RAISERROR(50001,16,1);
              END
            END

           IF (@Lc_FcrMemAckCur_Enumeration_CODE = @Lc_ValidityMultipleSsn_CODE)
              AND @Ln_FcrMemAckCur_Multiple1Ssn_NUMB != 0 
            BEGIN
             SET @Ln_Exists_NUMB = 0;
             SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF SSN2 IN MSSN_Y1 WITH OTHER MEMBER';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT, 0);

             SELECT @Ln_Exists_NUMB = COUNT(1)
               FROM MSSN_Y1
              WHERE MSSN_Y1.MemberMci_IDNO != @Ln_FcrMemAckCur_MemberMci_IDNO
                AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_Multiple1Ssn_NUMB
                AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE
                AND MSSN_Y1.Enumeration_CODE != @Lc_VerificationStatusBad_CODE;

             IF @Ln_Exists_NUMB > 0
              BEGIN
               SET @Lc_BateError_CODE = @Lc_ErrorE0899_CODE;
               SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

               GOTO lx_exception;
              
              END

             SET @Ln_Exists_NUMB = 0;
             SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB-V IN MSSN_Y1';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT, 0);

             SELECT @Ln_Exists_NUMB = COUNT(1)
               FROM MSSN_Y1
              WHERE MSSN_Y1.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO
                AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_Multiple1Ssn_NUMB
                AND MSSN_Y1.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
                AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE;

             IF @Ln_Exists_NUMB = 0
              BEGIN
               SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN-3';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FcrMemAckCur_MemberMci_IDNO AS VARCHAR) + 'MemberSsn_NUMB = ' + CAST(@Ln_FcrMemAckCur_Multiple1Ssn_NUMB AS VARCHAR);

               EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
                @Ad_Run_DATE              = @Ad_Run_DATE,
                @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
                @An_MemberSsn_NUMB        = @Ln_FcrMemAckCur_Multiple1Ssn_NUMB,
                @Ac_TypePrimarySsn_CODE   = @Lc_TypeSecondarySsn_CODE,
                @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
                @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

               IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                BEGIN
                 SET @Lc_BateError_CODE = @Lc_Msg_CODE;
                 RAISERROR(50001,16,1);
                END
              END
            END

           IF (@Lc_FcrMemAckCur_Enumeration_CODE = @Lc_ValidityMultipleSsn_CODE)
              AND @Ln_FcrMemAckCur_Multiple2Ssn_NUMB != 0 
            BEGIN
             SET @Ln_Exists_NUMB = 0;
             SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF SSN3 IN MSSN_Y1 WITH OTHER MEMBER';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT, 0);

             SELECT @Ln_Exists_NUMB = COUNT(1)
               FROM MSSN_Y1
              WHERE MSSN_Y1.MemberMci_IDNO != @Ln_FcrMemAckCur_MemberMci_IDNO
                AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_Multiple2Ssn_NUMB
                AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE
                AND MSSN_Y1.Enumeration_CODE != @Lc_VerificationStatusBad_CODE;

             IF @Ln_Exists_NUMB > 0
              BEGIN
               SET @Lc_BateError_CODE = @Lc_ErrorE0899_CODE;
               SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

               GOTO lx_exception;
              END

             SET @Ln_Exists_NUMB = 0;
             SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB-V IN MSSN_Y1';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT, 0);

             SELECT @Ln_Exists_NUMB = COUNT(1)
               FROM MSSN_Y1
              WHERE MSSN_Y1.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO
                AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_Multiple2Ssn_NUMB
                AND MSSN_Y1.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
                AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE;

             IF @Ln_Exists_NUMB = 0
              BEGIN
               SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN-4';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FcrMemAckCur_MemberMci_IDNO AS VARCHAR); 

               EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
                @Ad_Run_DATE              = @Ad_Run_DATE,
                @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
                @An_MemberSsn_NUMB        = @Ln_FcrMemAckCur_Multiple2Ssn_NUMB,
                @Ac_TypePrimarySsn_CODE   = @Lc_TypeSecondarySsn_CODE,
                @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
                @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

               IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                BEGIN
                 SET @Lc_BateError_CODE = @Lc_Msg_CODE;
                 RAISERROR(50001,16,1);
                END
              END
            END

           IF (@Lc_FcrMemAckCur_Enumeration_CODE = @Lc_ValidityMultipleSsn_CODE)
              AND @Ln_FcrMemAckCur_Multiple3Ssn_NUMB != 0 
            BEGIN
             SET @Ln_Exists_NUMB = 0;
             SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF SSN4 IN MSSN_Y1 WITH OTHER MEMBER';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT, 0);

             SELECT @Ln_Exists_NUMB = COUNT(1)
               FROM MSSN_Y1
              WHERE MSSN_Y1.MemberMci_IDNO != @Ln_FcrMemAckCur_MemberMci_IDNO
                AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_Multiple3Ssn_NUMB
                AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE
                AND MSSN_Y1.Enumeration_CODE != @Lc_VerificationStatusBad_CODE;

             IF @Ln_Exists_NUMB > 0
              BEGIN
               SET @Lc_BateError_CODE = @Lc_ErrorE0899_CODE;
               SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

               GOTO lx_exception;
              END

             SET @Ln_Exists_NUMB = 0;
             SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB-V IN MSSN_Y1';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT, 0);

             SELECT @Ln_Exists_NUMB = COUNT(1)
               FROM MSSN_Y1
              WHERE MSSN_Y1.MemberMci_IDNO = @Ln_FcrMemAckCur_MemberMci_IDNO
                AND MSSN_Y1.MemberSsn_NUMB = @Ln_FcrMemAckCur_Multiple3Ssn_NUMB
                AND MSSN_Y1.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
                AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE;

             IF @Ln_Exists_NUMB = 0
              BEGIN
               SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN-5';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FcrMemAckCur_MemberMci_IDNO AS VARCHAR) + 'MemberSsn_NUMB = ' + CAST(@Ln_FcrMemAckCur_Multiple3Ssn_NUMB AS VARCHAR);

               EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
                @Ad_Run_DATE              = @Ad_Run_DATE,
                @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
                @An_MemberSsn_NUMB        = @Ln_FcrMemAckCur_Multiple3Ssn_NUMB,
                @Ac_TypePrimarySsn_CODE   = @Lc_TypeSecondarySsn_CODE,
                @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
                @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
               
               IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                BEGIN
                 
				 SET @Lc_BateError_CODE = @Lc_Msg_CODE;
                 RAISERROR(50001,16,1);
                END
              END
            END
          END
        END

       SET @Ln_MemberSsn_NUMB = @Ln_Zero_NUMB; 
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$FN_GET_VERIFIED_SSN_ITIN';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0);
       SET @Ln_MemberSsn_NUMB = dbo.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN(@Ln_FcrMemAckCur_MemberMci_IDNO);

       IF @Ln_MemberSsn_NUMB = @Lc_MemberSsn000000000_TEXT
        BEGIN
         SET @Ln_MemberSsn_NUMB = @Ln_MemberSsnDemo_NUMB;
        END

       SET @Ld_BirthSsa_DATE = @Ld_Low_DATE;
       SET @Ls_Sql_TEXT = 'DT_BIRTH_SSA';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0);
      
       SET @Ld_BirthSsa_DATE = @Ld_FcrMemAckCur_Birth_DATE;
       IF @Ld_BirthSsa_DATE = @Ld_Low_DATE 
        BEGIN
         SET @Ld_BirthSsa_DATE = @Ld_Birth_DATE;
        END

       IF ((@Ln_MemberSsn_NUMB <> @Ln_MemberSsnDemo_NUMB)
            OR (@Ld_FcrMemAckCur_Birth_DATE <> @Ld_Low_DATE 
                AND @Ld_BirthSsa_DATE <> @Ld_Birth_DATE
                AND @Lc_FcrMemAckCur_DateBirthSsa_INDC = @Lc_Yes_INDC
                AND @Ld_Birth_DATE = @Ld_Low_DATE))
        BEGIN
         IF @Ld_Birth_DATE <> @Ld_Low_DATE
          BEGIN
           SET @Ld_BirthSsa_DATE = @Ld_Birth_DATE;
          END

         SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO 1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, 0) + ', Birth_DATE = ' + ISNULL(CAST(@Ld_BirthSsa_DATE AS VARCHAR(10)), '');
         SET @Ln_TempSsn_NUMB = ISNULL(LTRIM(RTRIM(@Ln_MemberSsn_NUMB)), @Ln_MemberSsnDemo_NUMB);
         SET @Ld_Temp_DATE = ISNULL(@Ld_BirthSsa_DATE, @Ld_Birth_DATE);

         EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
          @Ad_Run_DATE              = @Ad_Run_DATE,
          @An_MemberMci_IDNO        = @Ln_FcrMemAckCur_MemberMci_IDNO,
          @An_MemberSsn_NUMB        = @Ln_TempSsn_NUMB,
          @Ad_Birth_DATE            = @Ld_Temp_DATE,
          @Ad_Deceased_DATE         = @Ld_Deceased_DATE,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
         
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           
           RAISERROR(50001,16,1);
          END
        END
      END
     ELSE
      BEGIN
       IF @Lc_FcrMemAckCur_Acknowledge_CODE = @Lc_AcknowledgeReject_CODE
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_TypeErrorF_CODE;
         SET @Lc_BateError_CODE = ISNULL(@Lc_FcrMemAckCur_Error1_CODE, @Lc_FcrMemAckCur_Error2_CODE);
        END
      END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
              
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-2 ';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '') + ', Acknowledge_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Acknowledge_CODE, '') + ', Error1_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error5_CODE, '');
       SET @Ls_BateRecord_TEXT = 'Rec_ID = ' + ISNULL(@Lc_FcrMemAckCur_Rec_ID, '') + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', FcrReserved_CODE = ' + ISNULL(@Lc_FcrMemAckCur_FcrReserved_CODE, '') + ', UserField_NAME = ' + ISNULL(@Lc_FcrMemAckCur_UserFieldName_TEXT, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_FcrMemAckCur_CountyIdno_TEXT, 0) + ', TypeLocRequest_CODE = ' + ISNULL(@Lc_FcrMemAckCur_TypeLocRequest_CODE, '') + ', BundleResult_INDC = ' + ISNULL(@Lc_FcrMemAckCur_BundleResult_INDC, '') + ', TypeParticipant_CODE = ' + ISNULL (@Lc_FcrMemAckCur_TypeParticipant_CODE, '') + ', FamilyViolence_CODE = ' + ISNULL (@Lc_FcrMemAckCur_FamilyViolence_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', MemberSex_CODE = ' + ISNULL(@Lc_FcrMemAckCur_MemberSex_CODE, '') + ', Birth_DATE = ' + ISNULL(@Lc_FcrMemAckCur_BirthDate_TEXT, '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_MemberSsnNumb_TEXT, 0) + ', PreviousMemberSsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT, '') + ', First_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstName_TEXT, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiddleName_TEXT, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrMemAckCur_LastName_TEXT, '') + ', BirthCity_NAME = ' + ISNULL(@Lc_FcrMemAckCur_BirthCityName_TEXT, '') + ', BirthStCountry_CODE = ' + ISNULL(@Lc_FcrMemAckCur_BirthStCountry_CODE, '') + ', FirstFather_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstFatherName_TEXT, '') + ', MiFather_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiFatherName_TEXT, '') + ', LastFather_NAME = ' + ISNULL(@Lc_FcrMemAckCur_LastFatherName_TEXT, '') + ', FirstMother_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstMotherName_TEXT, '') + ', MiMother_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiMotherName_TEXT, '') + ', LastMother_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastMotherName_TEXT, '') + ', IrsU1Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_IrsU1SsnNumb_TEXT, 0) + ', Additional1Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Additional1SsnNumb_TEXT, 0) + ', Additional2Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Additional2SsnNumb_TEXT, 0) + ', FirstAlias1_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstAlias1Name_TEXT, '') + ', MiAlias1_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias1Name_TEXT, '') + ', LastAlias1_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias1Name_TEXT, '') + ', FirstAlias2_NAME = ' + ISNULL (@Lc_FcrMemAckCur_FirstAlias2Name_TEXT, '') + ', MiAlias2_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias2Name_TEXT, '') + ', LastAlias2_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias2Name_TEXT, '') + ', FirstAlias3_NAME = ' + ISNULL (@Lc_FcrMemAckCur_FirstAlias3Name_TEXT, '') + ', MiAlias3_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias3Name_TEXT, '') + ', LastAlias3_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias3Name_TEXT, '') + ', FirstAlias4_NAME = ' + ISNULL (@Lc_FcrMemAckCur_FirstAlias4Name_TEXT, '') + ', MiAlias4_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiAlias4Name_TEXT, '') + ', LastAlias4_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastAlias4Name_TEXT, '') + ', NewMemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_NewMemberMciIdno_TEXT, 0) + ', Irs1099_INDC = ' + ISNULL(@Lc_FcrMemAckCur_Irs1099_INDC, '') + ', LocateSource1_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource1_CODE, '') + ', LocateSource2_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource2_CODE, '') + ', LocateSource3_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource3_CODE, '') + ', LocateSource4_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource4_CODE, '') + ', LocateSource5_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource5_CODE, '') + ', LocateSource6_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource6_CODE, '') + ', LocateSource7_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource7_CODE, '') + ', LocateSource8_CODE = ' + ISNULL(@Lc_FcrMemAckCur_LocateSource8_CODE, '') + ', Enumeration_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Enumeration_CODE, '') + ', SSN_CORRECT = ' + ISNULL(@Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, 0) + ', Multiple1Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT, 0) + ', Multiple2Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT, 0) + ', Multiple3Ssn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT, 0) + ', DateBirthSsa_INDC = ' + ISNULL(@Lc_FcrMemAckCur_DateBirthSsa_INDC, '') + ', Batch_NUMB = ' + ISNULL (@Lc_FcrMemAckCur_BatchNumb_TEXT, '') + ', Death_DATE = ' + ISNULL(@Lc_FcrMemAckCur_DeathDate_TEXT, '') + ', ZipLastResiSsa_CODE = ' + ISNULL(@Lc_FcrMemAckCur_ZipLastResiSsa_CODE, '') + ', ZipOfPaymentSsa_CODE = ' + ISNULL (@Lc_FcrMemAckCur_ZipOfPaymentSsa_CODE, '') + ', PrimarySsn_NUMB = ' + ISNULL(@Lc_FcrMemAckCur_PrimarySsnNumb_TEXT, 0) + ', FirstPrimary_NAME = ' + ISNULL(@Lc_FcrMemAckCur_FirstPrimaryName_TEXT, '') + ', MiPrimary_NAME = ' + ISNULL(@Lc_FcrMemAckCur_MiPrimaryName_TEXT, '') + ', LastPrimary_NAME = ' + ISNULL (@Lc_FcrMemAckCur_LastPrimaryName_TEXT, '') + ', Acknowledge_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Acknowledge_CODE, '') + ', Error1_CODE = ' + ISNULL (@Lc_FcrMemAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error5_CODE, '');
          
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @As_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
	   	   ROLLBACK TRANSACTION SAVEPERSONACK_DETAILS;
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
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_MemberMciIdno_TEXT, 0) + ', Case_IDNO = ' + ISNULL(@Lc_FcrMemAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Action_CODE, '') + ', Acknowledge_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Acknowledge_CODE, '') + ', Error1_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrMemAckCur_Error5_CODE, '');

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
     -- Update the process indicator to 'Y'  
     
     SET @Ls_Sql_TEXT = 'UPDATE LFPAD_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_FcrMemAckCur_Seq_IDNO AS VARCHAR);

     UPDATE LFPAD_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrMemAckCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
      
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LFPAD_Y1';

       RAISERROR(50001,16,1);
      END

     -- Commit logic was commented to  check later whether to commit in the main procedure or sub procedure 
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');

     IF @An_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @An_CommitFreq_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');

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

       COMMIT TRANSACTION PERSONACK_DETAILS; 
       BEGIN TRANSACTION PERSONACK_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION PERSONACK_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END
     
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     FETCH NEXT FROM FcrMemAck_CUR INTO @Ln_FcrMemAckCur_Seq_IDNO, @Lc_FcrMemAckCur_Rec_ID, @Lc_FcrMemAckCur_Action_CODE, @Lc_FcrMemAckCur_CaseIdno_TEXT, @Lc_FcrMemAckCur_FcrReserved_CODE, @Lc_FcrMemAckCur_UserFieldName_TEXT, @Lc_FcrMemAckCur_CountyIdno_TEXT, @Lc_FcrMemAckCur_TypeLocRequest_CODE, @Lc_FcrMemAckCur_BundleResult_INDC, @Lc_FcrMemAckCur_TypeParticipant_CODE, @Lc_FcrMemAckCur_FamilyViolence_CODE, @Lc_FcrMemAckCur_MemberMciIdno_TEXT, @Lc_FcrMemAckCur_MemberSex_CODE, @Lc_FcrMemAckCur_BirthDate_TEXT, @Lc_FcrMemAckCur_MemberSsnNumb_TEXT, @Lc_FcrMemAckCur_PreviousMemberSsnNumb_TEXT, @Lc_FcrMemAckCur_FirstName_TEXT, @Lc_FcrMemAckCur_MiddleName_TEXT, @Lc_FcrMemAckCur_LastName_TEXT, @Lc_FcrMemAckCur_BirthCityName_TEXT, @Lc_FcrMemAckCur_BirthStCountry_CODE, @Lc_FcrMemAckCur_FirstFatherName_TEXT, @Lc_FcrMemAckCur_MiFatherName_TEXT, @Lc_FcrMemAckCur_LastFatherName_TEXT, @Lc_FcrMemAckCur_FirstMotherName_TEXT, @Lc_FcrMemAckCur_MiMotherName_TEXT, @Lc_FcrMemAckCur_LastMotherName_TEXT, @Lc_FcrMemAckCur_IrsU1SsnNumb_TEXT, @Lc_FcrMemAckCur_Additional1SsnNumb_TEXT, @Lc_FcrMemAckCur_Additional2SsnNumb_TEXT, @Lc_FcrMemAckCur_FirstAlias1Name_TEXT, @Lc_FcrMemAckCur_MiAlias1Name_TEXT, @Lc_FcrMemAckCur_LastAlias1Name_TEXT, @Lc_FcrMemAckCur_FirstAlias2Name_TEXT, @Lc_FcrMemAckCur_MiAlias2Name_TEXT, @Lc_FcrMemAckCur_LastAlias2Name_TEXT, @Lc_FcrMemAckCur_FirstAlias3Name_TEXT, @Lc_FcrMemAckCur_MiAlias3Name_TEXT, @Lc_FcrMemAckCur_LastAlias3Name_TEXT, @Lc_FcrMemAckCur_FirstAlias4Name_TEXT, @Lc_FcrMemAckCur_MiAlias4Name_TEXT, @Lc_FcrMemAckCur_LastAlias4Name_TEXT, @Lc_FcrMemAckCur_NewMemberMciIdno_TEXT, @Lc_FcrMemAckCur_Irs1099_INDC, @Lc_FcrMemAckCur_LocateSource1_CODE, @Lc_FcrMemAckCur_LocateSource2_CODE, @Lc_FcrMemAckCur_LocateSource3_CODE, @Lc_FcrMemAckCur_LocateSource4_CODE, @Lc_FcrMemAckCur_LocateSource5_CODE, @Lc_FcrMemAckCur_LocateSource6_CODE, @Lc_FcrMemAckCur_LocateSource7_CODE, @Lc_FcrMemAckCur_LocateSource8_CODE, @Lc_FcrMemAckCur_Enumeration_CODE, @Lc_FcrMemAckCur_CorrectSsnNumb_TEXT, @Lc_FcrMemAckCur_Multiple1SsnNumb_TEXT, @Lc_FcrMemAckCur_Multiple2SsnNumb_TEXT, @Lc_FcrMemAckCur_Multiple3SsnNumb_TEXT, @Lc_FcrMemAckCur_DateBirthSsa_INDC, @Lc_FcrMemAckCur_BatchNumb_TEXT, @Lc_FcrMemAckCur_DeathDate_TEXT, @Lc_FcrMemAckCur_ZipLastResiSsa_CODE, @Lc_FcrMemAckCur_ZipOfPaymentSsa_CODE, @Lc_FcrMemAckCur_PrimarySsnNumb_TEXT, @Lc_FcrMemAckCur_FirstPrimaryName_TEXT, @Lc_FcrMemAckCur_MiPrimaryName_TEXT, @Lc_FcrMemAckCur_LastPrimaryName_TEXT, @Lc_FcrMemAckCur_Acknowledge_CODE, @Lc_FcrMemAckCur_Error1_CODE, @Lc_FcrMemAckCur_Error2_CODE, @Lc_FcrMemAckCur_Error3_CODE, @Lc_FcrMemAckCur_Error4_CODE, @Lc_FcrMemAckCur_Error5_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END
   
   CLOSE FcrMemAck_CUR;

   DEALLOCATE FcrMemAck_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   
   COMMIT TRANSACTION PERSONACK_DETAILS;
  
  END TRY

  BEGIN CATCH
  
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   IF CURSOR_STATUS ('local', 'FcrMemAck_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrMemAck_CUR;

     DEALLOCATE FcrMemAck_CUR;
    END
   
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PERSONACK_DETAILS;
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
