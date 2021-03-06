/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
---------------------------------------------------------------------
---------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS  
Programmer Name		 : IMP Team
Description			 : The procedure reads the the Insurance Match 
                       details from the temporary tables LoadFcrInsMatchPart1Details_T1,
                       LoadFcrInsMatchPart2Details_T1 and look for matched NCP's to update the AHIS_Y1 and ASFN_Y1. Adds othp 
                      information for Insurance company and attorney information, If not exists in the othp. 
Frequency			 : Daily
Developed On		 : 04/18/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_ADDRESS_UPDATE
                       BATCH_COMMON$SP_GET_OTHP
                       BATCH_COMMON$SP_EMPLOYER_UPDATE
                       BATCH_LOC_INCOMING_FCR$SP_UPDATE_ASFN
                       BATCH_COMMON$SP_INSERT_ELFC
                       BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS]
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

  DECLARE  @Ln_Exists_NUMB                      NUMERIC(2) = 0,
           @Lc_VerificationStatusPending_CODE   CHAR = 'P',
           @Lc_No_INDC                          CHAR(1) = 'N',
           @Lc_UnnormalizedU_INDC               CHAR(1) = 'U',
           @Lc_VerificationStatusGood_CODE      CHAR(1) = 'Y',
           @Lc_TypeOthpInsurance_CODE           CHAR(1) = 'I',
           @Lc_TypeOthpAttorney_CODE            CHAR(1) = 'A',
           @Lc_RelationshipCaseNcp_TEXT         CHAR(1) = 'A',
           @Lc_RelationshipCasePf_TEXT          CHAR(1) = 'P',
           @Lc_StatusCaseO_CODE                 CHAR(1) = 'O',
           @Lc_StatusEnforceO_CODE              CHAR(1) = 'O',
           @Lc_ProcessY_INDC                    CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE                CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE              CHAR(1) = 'E',
           @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
           @Lc_MsgD1_CODE                       CHAR(1) = 'D',
           @Lc_NegPosStartRemedy_CODE           CHAR(1) = 'P',
           @Lc_CaseMemberStatusA_CODE           CHAR(1) = 'A',
           @Lc_TypeAddressM_CODE                CHAR(1) = 'M',
           @Lc_InmCountry_CODE                  CHAR(2) = 'US',
           @Lc_WorkerComp_CODE                  CHAR(2) = '05',
           @Lc_PersonelInjury_CODE              CHAR(2) = '06',
           @Lc_IncomePersonelInjury_CODE        CHAR(2) = 'PI',
           @Lc_IncomeWorkercomp_CODE            CHAR(2) = 'WC',
           @Lc_TypeChangeLien_CODE              CHAR(2) = 'LI',
           @Lc_SubsystemLoc_CODE			    CHAR(3) = 'LO',
           @Lc_LocateSourceInsuranceMatch_CODE  CHAR(3) = 'OCS',
           @Lc_SourceFedcaseregistr_CODE        CHAR(3) = 'FCR',
           @Lc_LocateSourceInm_CODE             CHAR(3) = 'INM',
           @Lc_AssetIns_CODE                    CHAR(3) = 'INS',
           @Lc_MajorActivityCase_CODE		    CHAR(4) = 'CASE',
           @Lc_MinorActivityRrfcr_CODE		    CHAR(5) = 'RRFCR',
           @Lc_ErrorE0887_CODE                  CHAR(5) = 'E0887',
           @Lc_ErrorE0145_CODE                  CHAR(5) = 'E0145',
           @Lc_ErrorE0960_CODE                  CHAR(5) = 'E0960',
           @Lc_ErrorE1089_CODE                  CHAR(5) = 'E1089',
           @Lc_ErrorE0620_CODE                  CHAR(5) = 'E0620',
           @Lc_BateErrorE1424_CODE              CHAR(5) = 'E1424',
           @Lc_ProcessFcrInsmatch_ID            CHAR(8) = 'FCR_IM',
           @Lc_BatchRunUser_TEXT                CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                   VARCHAR(60) = 'SP_INSMATCH_DETAILS',
           @Ld_High_DATE                        DATE = '12/31/9999',
           @Ld_Low_DATE                         DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB						NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY					NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY			NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY		NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY	NUMERIC(6) = 0,
           @Ln_OtherParty_IDNO					NUMERIC(9) = 0,
           @Ln_OtherPartyAttorney_IDNO			NUMERIC(9) = 0,
           @Ln_Cur_QNTY							NUMERIC(10,0) = 0,
           @Ln_MemberMci_IDNO					NUMERIC(10) =0,
           @Ln_Topic_IDNO					    NUMERIC(10) = 0,
           @Ln_Error_NUMB						NUMERIC(11),
           @Ln_ErrorLine_NUMB					NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB			NUMERIC(19) = 0,
           @Li_FetchStatus_QNTY					SMALLINT,
           @Li_RowCount_QNTY					SMALLINT,
           @Lc_Space_TEXT						CHAR(1) = '',
           @Lc_TypeError_CODE					CHAR(1) = '',
           @Lc_Msg_CODE							CHAR(5),
           @Lc_BateError_CODE					CHAR(5) = '',
           @Ls_Attorney_NAME					VARCHAR(50),
           @Ls_Sql_TEXT							VARCHAR(100),
           @Ls_CursorLoc_TEXT					VARCHAR(200),
           @Ls_Sqldata_TEXT						VARCHAR(1000),
           @Ls_BateRecord_TEXT					VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT			VARCHAR(4000),
           @Ls_ErrorMessage_TEXT				VARCHAR(4000);
         
  DECLARE InsMatch_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO AS Seq1_ID,
          a.Rec_ID,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.InsMatchObligorSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE a.InsMatchObligorSsn_NUMB
          END AS InsMatchObligorSsn_NUMB,
          a.RecordCreation_DATE,
          a.RecordSequence_NUMB,
          a.SubRecord_NUMB,
          a.Case_IDNO,
          a.ObligorFirst_NAME,
          a.ObligorFirst_NAME,
          a.MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.Tin_IDNO, '')))) = 0
            THEN '0'
           ELSE a.Tin_IDNO
          END AS Tin_IDNO,
          a.Processed_DATE,
          a.ClaimUpdate_CODE,
          a.Insurer_NAME,
          a.InsContactFirst_NAME,
          a.InsContactLast_NAME,
          a.InsPhone_NUMB,
          a.InsPhoneExt_NUMB,
          a.InsFax_NUMB,
          a.InsEmail_ADDR,
          a.InsLine1_ADDR,
          a.InsLine2_ADDR,
          a.InsCity_ADDR,
          a.InsState_ADDR,
          a.InsZip_ADDR,
          a.InsForeignAddr_CODE,
          a.ForeignCountry_NAME,
          a.InsAddrScrub1_CODE,
          a.InsAddrScrub2_CODE,
          a.InsAddrScrub3_CODE,
          a.InsClaim_NUMB,
          a.ClaimType_CODE,
          a.ClaimState_CODE,
          a.ClaimLoss_DATE,
          a.ClaimBeneficiary_INDC,
          a.ClaimReport_DATE,
          a.ClaimStatus_CODE,
          a.ClaimFreq_CODE,
          a.ObligorMatch_CODE,
          a.SsnVerification_CODE,
          a.ClaimantFirst_NAME,
          a.ClaimantMiddle_NAME,
          a.ClaimantLast_NAME,
          a.MemberItin_IDNO,
          a.ClaimantBirth_DATE,
          a.ClaimantMemberSex_CODE,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.ClaimantHomePhone_NUMB, '')))) = 0
            THEN '0'
           ELSE a.ClaimantHomePhone_NUMB
          END AS ClaimantHomePhone_NUMB,
          a.ClaimantWorkPhone_NUMB,
          a.ClaimantWorkPhoneExt_NUMB,
          a.ClaimantCellPhone_NUMB,
          a.DriverLicense_NUMB,
          a.LicenseState_CODE,
          a.Occupation_TEXT,
          a.ProfLicense_NUMB,
          a.ClaimantForeignAddr_CODE,
          a.ClaimantCountry_ADDR,
          a.ClaimantAddrScrub1_CODE,
          a.ClaimantAddrScrub2_CODE,
          a.ClaimantAddrScrub3_CODE,
          a.SortState_CODE,
          a.Normalization_CODE,
          a.ClaimantLine1_ADDR,
          a.ClaimantLine2_ADDR,
          a.ClaimantCity_ADDR,
          a.ClaimantState_ADDR,
          a.ClaimantZip_ADDR,
          a.InsuranceNormalization_CODE,
          b.AttorneyFirst_NAME,
          b.AttorneyLast_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(b.AttorneyPhone_NUMB, '')))) = 0
            THEN '0'
           ELSE b.AttorneyPhone_NUMB
          END AS AttorneyPhone_NUMB,
          b.AttorneyPhoneExt_NUMB,
          b.AttorneyLine1_ADDR,
          b.AttorneyLine2_ADDR,
          b.AttorneyCity_ADDR,
          b.AttorneyState_ADDR,
          b.AttorneyZip_ADDR,
          b.AttorneyForeignAddr_CODE,
          b.AttorneyCountry_ADDR,
          b.AttorneyAddrScrub1_CODE,
          b.AttorneyAddrScrub2_CODE,
          b.AttorneyAddrScrub3_CODE,
          b.TpaCompany_NAME,
          b.TpaContactFirst_NAME,
          b.TpaContactLast_NAME,
          b.TpaPhone_NUMB,
          b.TpaPhoneExt_NUMB,
          b.TpaLine1_ADDR,
          b.TpaLine2_ADDR,
          b.TpaCity_ADDR,
          b.TpaState_ADDR,
          b.TpaZip_ADDR,
          b.TpaForeignAddr_CODE,
          b.TpaCountry_NAME,
          b.TpaAddrScrub1_CODE,
          b.TpaAddrScrub2_CODE,
          b.TpaAddrScrub3_CODE,
          b.Employer_NAME,
          b.EmployerPhone_NUMB,
          b.EmployerPhoneExt_NUMB,
          b.EmployerLine1_ADDR,
          b.EmployerLine2_ADDR,
          b.EmployerCity_ADDR,
          b.EmployerState_ADDR,
          b.EmployerZip_ADDR,
          b.EmployerForeignAddr_CODE,
          b.EmployerCountry_NAME,
          b.EmployerAddrScrub1_CODE,
          b.EmployerAddrScrub2_CODE,
          b.EmployerAddrScrub3_CODE,
          b.Normalization_CODE,
          b.Seq_IDNO AS Seq2_ID
     FROM LFIMD_Y1 a,
          LFIMA_Y1 b
    WHERE a.Rec_ID = b.Rec_ID
      AND A.InsMatchObligorSsn_NUMB = B.InsMatchObligorSsn_NUMB
      AND a.RecordCreation_DATE = b.RecordCreation_DATE
      AND a.RecordSequence_NUMB = b.RecordSequence_NUMB
      AND a.Process_INDC = @Lc_No_INDC
      AND b.Process_INDC = @Lc_No_INDC;
  DECLARE @Ln_InsMatchCur_aSeq_IDNO                    NUMERIC(19),
          @Lc_InsMatchCur_aInsRec_ID                   CHAR(2),
          @Lc_InsMatchCur_aInsMatchObligorSsnNumb_TEXT CHAR(9),
          @Lc_InsMatchCur_aRecordCreation_DATE         CHAR(8),
          @Lc_InsMatchCur_aRecordSequence_NUMB         CHAR(3),
          @Lc_InsMatchCur_aSubRecord_NUMB              CHAR(1),
          @Lc_InsMatchCur_aCase_IDNO                   CHAR(10),
          @Lc_InsMatchCur_aObligorFirst_NAME           CHAR(16),
          @Lc_InsMatchCur_aObligorLast_NAME            CHAR(20),
          @Lc_InsMatchCur_aMemberSsnNumb_TEXT          CHAR(9),
          @Lc_InsMatchCur_aTinNumb_TEXT                CHAR(9),
          @Lc_InsMatchCur_aProcessed_DATE              CHAR(8),
          @Lc_InsMatchCur_aClaimUpdate_INDC            CHAR(1),
          @Ls_InsMatchCur_aInsurer_NAME                VARCHAR(45),
          @Lc_InsMatchCur_aInsContactFirst_NAME        CHAR(20),
          @Lc_InsMatchCur_aInsContactLast_NAME         CHAR(30),
          @Lc_InsMatchCur_aInsPhone_NUMB               CHAR(10),
          @Lc_InsMatchCur_aInsPhoneExt_NUMB            CHAR(6),
          @Lc_InsMatchCur_aInsFax_NUMB                 CHAR(10),
          @Lc_InsMatchCur_aInsEmail_ADDR               CHAR(40),
          @Lc_InsMatchCur_aInsLine1_ADDR               CHAR(40),
          @Lc_InsMatchCur_aInsLine2_ADDR               CHAR(40),
          @Lc_InsMatchCur_aInsCity_ADDR                CHAR(30),
          @Lc_InsMatchCur_aInsState_ADDR               CHAR(2),
          @Lc_InsMatchCur_aInsZip_ADDR                 CHAR(15),
          @Lc_InsMatchCur_aInsForeignAddr_INDC         CHAR(1),
          @Lc_InsMatchCur_aForeignCountry_NAME         CHAR(25),
          @Lc_InsMatchCur_aInsAddrScrub1_CODE          CHAR(2),
          @Lc_InsMatchCur_aInsAddrScrub2_CODE          CHAR(2),
          @Lc_InsMatchCur_aInsAddrScrub3_CODE          CHAR(2),
          @Lc_InsMatchCur_aInsClaim_NUMB               CHAR(30),
          @Lc_InsMatchCur_aClaimType_CODE              CHAR(2),
          @Lc_InsMatchCur_aClaimState_CODE             CHAR(2),
          @Lc_InsMatchCur_aClaimLoss_DATE              CHAR(8),
          @Lc_InsMatchCur_aClaimBeneficiary_INDC       CHAR(1),
          @Lc_InsMatchCur_aClaimReport_DATE            CHAR(8),
          @Lc_InsMatchCur_aClaimStatus_CODE            CHAR(1),
          @Lc_InsMatchCur_aClaimFreq_CODE              CHAR(1),
          @Lc_InsMatchCur_aObligorMatch_CODE           CHAR(2),
          @Lc_InsMatchCur_aSsnVerification_CODE        CHAR(1),
          @Lc_InsMatchCur_aClaimantFirst_NAME          CHAR(20),
          @Lc_InsMatchCur_aClaimantMi_NAME             CHAR(16),
          @Lc_InsMatchCur_aClaimantLast_NAME           CHAR(30),
          @Lc_InsMatchCur_aMemberItin_NUMB             CHAR(9),
          @Lc_InsMatchCur_aClaimantBirth_DATE          CHAR(8),
          @Lc_InsMatchCur_aClaimantMemberSex_CODE      CHAR(1),
          @Lc_InsMatchCur_aClaimantHomePhoneNumb_TEXT  CHAR(10),
          @Lc_InsMatchCur_aClaimant_WorkPhone_NUMB     CHAR(10),
          @Lc_InsMatchCur_aClaimantWorkPhoneExt_NUMB   CHAR(6),
          @Lc_InsMatchCur_aClaimantCellPhone_NUMB      CHAR(10),
          @Lc_InsMatchCur_aDriverLicense_NUMB          CHAR(20),
          @Lc_InsMatchCur_aLicenseState_CODE           CHAR(2),
          @Lc_InsMatchCur_aOccupation_TEXT             CHAR(40),
          @Lc_InsMatchCur_aProfLicense_NUMB            CHAR(15),
          @Lc_InsMatchCur_aClaimantForeignAddr_INDC    CHAR(1),
          @Lc_InsMatchCur_aClaimantCountry_NAME        CHAR(25),
          @Lc_InsMatchCur_aClaimantAddrScrub1_CODE     CHAR(2),
          @Lc_InsMatchCur_aClaimantAddrScrub2_CODE     CHAR(2),
          @Lc_InsMatchCur_aClaimantAddrScrub3_CODE     CHAR(2),
          @Lc_InsMatchCur_aSortState_CODE              CHAR(2),
          @Lc_InsMatchCur_aNormalization_CODE          CHAR(1),
          @Ls_InsMatchCur_aClaimantLine1_ADDR          VARCHAR(50),
          @Ls_InsMatchCur_aClaimantLine2_ADDR          VARCHAR(50),
          @Lc_InsMatchCur_aClaimantCity_ADDR           CHAR(30),
          @Lc_InsMatchCur_aClaimantState_ADDR          CHAR(2),
          @Lc_InsMatchCur_aClaimantZip_ADDR            CHAR(10),
          @Lc_InsMatchCur_aInsuranceNormalization_CODE CHAR(1),
          @Lc_InsMatchCur_bAttorneyFirst_NAME          CHAR(20),
          @Lc_InsMatchCur_bAttorneyLast_NAME           CHAR(30),
          @Lc_InsMatchCur_bAttorneyPhoneNumb_TEXT      CHAR(10),
          @Lc_InsMatchCur_bAttorneyPhoneExt_NUMB       CHAR(6),
          @Lc_InsMatchCur_bAttorneyLine1_ADDR          CHAR(40),
          @Lc_InsMatchCur_bAttorneyLine2_ADDR          CHAR(40),
          @Lc_InsMatchCur_bAttorneyCity_ADDR           CHAR(30),
          @Lc_InsMatchCur_bAttorneyState_ADDR          CHAR(2),
          @Lc_InsMatchCur_bAttorneyZip_ADDR            CHAR(15),
          @Lc_InsMatchCur_bAttorneyForeignAddr_INDC    CHAR(1),
          @Lc_InsMatchCur_bAttorneyCountry_NAME        CHAR(25),
          @Lc_InsMatchCur_bAttorneyAddrScrub1_CODE     CHAR(2),
          @Lc_InsMatchCur_bAttorneyAddrScrub2_CODE     CHAR(2),
          @Lc_InsMatchCur_bAttorneyAddrScrub3_CODE     CHAR(2),
          @Lc_InsMatchCur_bTpaCompany_NAME             CHAR(40),
          @Lc_InsMatchCur_bTpaContactFirst_NAME        CHAR(20),
          @Lc_InsMatchCur_bTpaContactLast_NAME         CHAR(30),
          @Lc_InsMatchCur_bTpaPhone_NUMB               CHAR(10),
          @Lc_InsMatchCur_bTpaPhoneExt_NUMB            CHAR(6),
          @Lc_InsMatchCur_bTpaLine1_ADDR               CHAR(40),
          @Lc_InsMatchCur_bTpaLine2_ADDR               CHAR(40),
          @Lc_InsMatchCur_bTpaCity_ADDR                CHAR(30),
          @Lc_InsMatchCur_bTpaState_ADDR               CHAR(2),
          @Lc_InsMatchCur_bTpaZip_ADDR                 CHAR(15),
          @Lc_InsMatchCur_bTpaForeignAddr_INDC         CHAR(1),
          @Lc_InsMatchCur_bTpaCountry_NAME             CHAR(25),
          @Lc_InsMatchCur_bTpaAddrScrub1_CODE          CHAR(2),
          @Lc_InsMatchCur_bTpaAddrScrub2_CODE          CHAR(2),
          @Lc_InsMatchCur_bTpaAddrScrub3_CODE          CHAR(2),
          @Lc_InsMatchCur_bEmployer_NAME               CHAR(40),
          @Lc_InsMatchCur_bEmployerPhone_NUMB          CHAR(10),
          @Lc_InsMatchCur_bEmployerPhoneExt_NUMB       CHAR(6),
          @Lc_InsMatchCur_bEmployerLine1_ADDR          CHAR(40),
          @Lc_InsMatchCur_bEmployerLine2_ADDR          CHAR(40),
          @Lc_InsMatchCur_bEmployerCity_ADDR           CHAR(30),
          @Lc_InsMatchCur_bEmployerState_ADDR          CHAR(2),
          @Lc_InsMatchCur_bEmployerZip_ADDR            CHAR(15),
          @Lc_InsMatchCur_bEmployerForeignAddr_INDC    CHAR(1),
          @Lc_InsMatchCur_bEmployerCountry_NAME        CHAR(25),
          @Lc_InsMatchCur_bEmployerAddrScrub1_CODE     CHAR(2),
          @Lc_InsMatchCur_bEmployerAddrScrub2_CODE     CHAR(2),
          @Lc_InsMatchCur_bEmployerAddrScrub3_CODE     CHAR(2),
          @Lc_InsMatchCur_bNormalization_CODE          CHAR(1),
          @Ln_InsMatchCur_bSeq_IDNO                    NUMERIC(19),
          
          @Ln_InsMatchCur_aInsMatchObligorSsn_NUMB     NUMERIC(9),
          @Ln_InsMatchCur_aTin_NUMB					   NUMERIC(9),
          @Ln_InsMatchCur_aClaimantHomePhone_NUMB	   NUMERIC(10),
          @Ln_InsMatchCur_bAttorneyPhone_NUMB		   NUMERIC(10);
 
  -- Cursor variables
  DECLARE @Ln_OpenCasesCur_Case_IDNO     NUMERIC(6),
          @Ln_OpenCasesCur_OrderSeq_NUMB NUMERIC(5, 2);

  BEGIN TRY
   BEGIN TRANSACTION INSMATCH_DETAILS;

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
   SET @Ls_Sql_TEXT = 'INSURANCE MATCH  LOC OPEN CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN InsMatch_CUR;

   SET @Ls_Sql_TEXT = 'INSURANCE MATCH  LOC FETCH CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
  
   FETCH NEXT FROM InsMatch_CUR INTO @Ln_InsMatchCur_aSeq_IDNO, @Lc_InsMatchCur_aInsRec_ID, @Lc_InsMatchCur_aInsMatchObligorSsnNumb_TEXT, @Lc_InsMatchCur_aRecordCreation_DATE, @Lc_InsMatchCur_aRecordSequence_NUMB, @Lc_InsMatchCur_aSubRecord_NUMB, @Lc_InsMatchCur_aCase_IDNO, @Lc_InsMatchCur_aObligorFirst_NAME, @Lc_InsMatchCur_aObligorLast_NAME, @Lc_InsMatchCur_aMemberSsnNumb_TEXT, @Lc_InsMatchCur_aTinNumb_TEXT, @Lc_InsMatchCur_aProcessed_DATE, @Lc_InsMatchCur_aClaimUpdate_INDC, @Ls_InsMatchCur_aInsurer_NAME, @Lc_InsMatchCur_aInsContactFirst_NAME, @Lc_InsMatchCur_aInsContactLast_NAME, @Lc_InsMatchCur_aInsPhone_NUMB, @Lc_InsMatchCur_aInsPhoneExt_NUMB, @Lc_InsMatchCur_aInsFax_NUMB, @Lc_InsMatchCur_aInsEmail_ADDR, @Lc_InsMatchCur_aInsLine1_ADDR, @Lc_InsMatchCur_aInsLine2_ADDR, @Lc_InsMatchCur_aInsCity_ADDR, @Lc_InsMatchCur_aInsState_ADDR, @Lc_InsMatchCur_aInsZip_ADDR, @Lc_InsMatchCur_aInsForeignAddr_INDC, @Lc_InsMatchCur_aForeignCountry_NAME, @Lc_InsMatchCur_aInsAddrScrub1_CODE, @Lc_InsMatchCur_aInsAddrScrub2_CODE, @Lc_InsMatchCur_aInsAddrScrub3_CODE, @Lc_InsMatchCur_aInsClaim_NUMB, @Lc_InsMatchCur_aClaimType_CODE, @Lc_InsMatchCur_aClaimState_CODE, @Lc_InsMatchCur_aClaimLoss_DATE, @Lc_InsMatchCur_aClaimBeneficiary_INDC, @Lc_InsMatchCur_aClaimReport_DATE, @Lc_InsMatchCur_aClaimStatus_CODE, @Lc_InsMatchCur_aClaimFreq_CODE, @Lc_InsMatchCur_aObligorMatch_CODE, @Lc_InsMatchCur_aSsnVerification_CODE, @Lc_InsMatchCur_aClaimantFirst_NAME, @Lc_InsMatchCur_aClaimantMi_NAME, @Lc_InsMatchCur_aClaimantLast_NAME, @Lc_InsMatchCur_aMemberItin_NUMB, @Lc_InsMatchCur_aClaimantBirth_DATE, @Lc_InsMatchCur_aClaimantMemberSex_CODE, @Lc_InsMatchCur_aClaimantHomePhoneNumb_TEXT, @Lc_InsMatchCur_aClaimant_WorkPhone_NUMB, @Lc_InsMatchCur_aClaimantWorkPhoneExt_NUMB, @Lc_InsMatchCur_aClaimantCellPhone_NUMB, @Lc_InsMatchCur_aDriverLicense_NUMB, @Lc_InsMatchCur_aLicenseState_CODE, @Lc_InsMatchCur_aOccupation_TEXT, @Lc_InsMatchCur_aProfLicense_NUMB, @Lc_InsMatchCur_aClaimantForeignAddr_INDC, @Lc_InsMatchCur_aClaimantCountry_NAME, @Lc_InsMatchCur_aClaimantAddrScrub1_CODE, @Lc_InsMatchCur_aClaimantAddrScrub2_CODE, @Lc_InsMatchCur_aClaimantAddrScrub3_CODE, @Lc_InsMatchCur_aSortState_CODE, @Lc_InsMatchCur_aNormalization_CODE, @Ls_InsMatchCur_aClaimantLine1_ADDR, @Ls_InsMatchCur_aClaimantLine2_ADDR, @Lc_InsMatchCur_aClaimantCity_ADDR, @Lc_InsMatchCur_aClaimantState_ADDR, @Lc_InsMatchCur_aClaimantZip_ADDR, @Lc_InsMatchCur_aInsuranceNormalization_CODE, @Lc_InsMatchCur_bAttorneyFirst_NAME, @Lc_InsMatchCur_bAttorneyLast_NAME, @Lc_InsMatchCur_bAttorneyPhoneNumb_TEXT, @Lc_InsMatchCur_bAttorneyPhoneExt_NUMB, @Lc_InsMatchCur_bAttorneyLine1_ADDR, @Lc_InsMatchCur_bAttorneyLine2_ADDR, @Lc_InsMatchCur_bAttorneyCity_ADDR, @Lc_InsMatchCur_bAttorneyState_ADDR, @Lc_InsMatchCur_bAttorneyZip_ADDR, @Lc_InsMatchCur_bAttorneyForeignAddr_INDC, @Lc_InsMatchCur_bAttorneyCountry_NAME, @Lc_InsMatchCur_bAttorneyAddrScrub1_CODE, @Lc_InsMatchCur_bAttorneyAddrScrub2_CODE, @Lc_InsMatchCur_bAttorneyAddrScrub3_CODE, @Lc_InsMatchCur_bTpaCompany_NAME, @Lc_InsMatchCur_bTpaContactFirst_NAME, @Lc_InsMatchCur_bTpaContactLast_NAME, @Lc_InsMatchCur_bTpaPhone_NUMB, @Lc_InsMatchCur_bTpaPhoneExt_NUMB, @Lc_InsMatchCur_bTpaLine1_ADDR, @Lc_InsMatchCur_bTpaLine2_ADDR, @Lc_InsMatchCur_bTpaCity_ADDR, @Lc_InsMatchCur_bTpaState_ADDR, @Lc_InsMatchCur_bTpaZip_ADDR, @Lc_InsMatchCur_bTpaForeignAddr_INDC, @Lc_InsMatchCur_bTpaCountry_NAME, @Lc_InsMatchCur_bTpaAddrScrub1_CODE, @Lc_InsMatchCur_bTpaAddrScrub2_CODE, @Lc_InsMatchCur_bTpaAddrScrub3_CODE, @Lc_InsMatchCur_bEmployer_NAME, @Lc_InsMatchCur_bEmployerPhone_NUMB, @Lc_InsMatchCur_bEmployerPhoneExt_NUMB, @Lc_InsMatchCur_bEmployerLine1_ADDR, @Lc_InsMatchCur_bEmployerLine2_ADDR, @Lc_InsMatchCur_bEmployerCity_ADDR, @Lc_InsMatchCur_bEmployerState_ADDR, @Lc_InsMatchCur_bEmployerZip_ADDR, @Lc_InsMatchCur_bEmployerForeignAddr_INDC, @Lc_InsMatchCur_bEmployerCountry_NAME, @Lc_InsMatchCur_bEmployerAddrScrub1_CODE, @Lc_InsMatchCur_bEmployerAddrScrub2_CODE, @Lc_InsMatchCur_bEmployerAddrScrub3_CODE, @Lc_InsMatchCur_bNormalization_CODE, @Ln_InsMatchCur_bSeq_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- If data found in the load table, process the data in the loop
   -- Process FCR insurance match records
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
	 SAVE TRANSACTION SAVEINSMATCH_DETAILS;
    
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     IF ISNUMERIC (@Lc_InsMatchCur_aInsMatchObligorSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_InsMatchCur_aInsMatchObligorSsn_NUMB = @Lc_InsMatchCur_aInsMatchObligorSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_InsMatchCur_aInsMatchObligorSsn_NUMB = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_InsMatchCur_aTinNumb_TEXT) = 1
		BEGIN
			SET @Ln_InsMatchCur_aTin_NUMB = @Lc_InsMatchCur_aTinNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_InsMatchCur_aTin_NUMB = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_InsMatchCur_aClaimantHomePhoneNumb_TEXT) = 1
		BEGIN
			SET @Ln_InsMatchCur_aClaimantHomePhone_NUMB = @Lc_InsMatchCur_aClaimantHomePhoneNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_InsMatchCur_aClaimantHomePhone_NUMB = @Ln_Zero_NUMB;
		END
		
	 IF ISNUMERIC (@Lc_InsMatchCur_bAttorneyPhoneNumb_TEXT) = 1
		BEGIN
			SET @Ln_InsMatchCur_bAttorneyPhone_NUMB = @Lc_InsMatchCur_bAttorneyPhoneNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_InsMatchCur_bAttorneyPhone_NUMB = @Ln_Zero_NUMB;
		END
	 	
     SET @Ln_TransactionEventSeq_NUMB = 0;
     SET @Ln_OtherPartyAttorney_IDNO  = 0;
     SET @Ln_OtherParty_IDNO          = 0;
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Ls_Attorney_NAME = @Lc_Space_TEXT;
     
     SET @Ls_CursorLoc_TEXT = 'NcpSsn_NUMB: ' + ISNULL(CAST(@Ln_InsMatchCur_aInsMatchObligorSsn_NUMB AS VARCHAR(9)), 0) + ' Case_IDNO: ' + ISNULL(@Lc_InsMatchCur_aCase_IDNO, '') + ' First_NAME: ' + ISNULL(@Lc_InsMatchCur_aObligorFirst_NAME, '') + ' Last_NAME: ' + ISNULL(@Lc_InsMatchCur_aObligorLast_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_InsMatchCur_aInsRec_ID, '') + ', InsMatchedObligor_SSN = ' + ISNULL(CAST(@Ln_InsMatchCur_aInsMatchObligorSsn_NUMB AS VARCHAR(9)), 0) + ', RecordCreation_DATE = ' + ISNULL(@Lc_InsMatchCur_aRecordCreation_DATE, '') + ', RecordSequence_NUMB = ' + ISNULL(@Lc_InsMatchCur_aRecordSequence_NUMB, '') + ', SubRecord_NUMB = ' + ISNULL (@Lc_InsMatchCur_aSubRecord_NUMB, '') + ', Case_IDNO = ' + ISNULL(@Lc_InsMatchCur_aCase_IDNO, '') + ', ObligorFirst_NAME = ' + ISNULL(@Lc_InsMatchCur_aObligorFirst_NAME, '') + ', ObligorLast_NAME = ' + ISNULL (@Lc_InsMatchCur_aObligorLast_NAME, '') + ', ObligorMember_SSN = ' + ISNULL(@Lc_InsMatchCur_aMemberSsnNumb_TEXT, '') + ', TinOrEin_IDNO = ' + ISNULL(CAST(@Ln_InsMatchCur_aTin_NUMB AS VARCHAR(9)), 0) + ', Processed_DATE = ' + ISNULL(@Lc_InsMatchCur_aProcessed_DATE, '') + ', ClaimUpdate_INDC = ' + ISNULL(@Lc_InsMatchCur_aClaimUpdate_INDC, '') + ', Insure_NAME = ' + ISNULL (@Ls_InsMatchCur_aInsurer_NAME, '') + ', InsContactFirst_NAME = ' + ISNULL(@Lc_InsMatchCur_aInsContactFirst_NAME, '') + ', InsContactLast_NAME = ' + ISNULL(@Lc_InsMatchCur_aInsContactLast_NAME, '') + ', InsPhone_NUMB = ' + ISNULL(@Lc_InsMatchCur_aInsPhone_NUMB, '') + ', InsPhoneExt_NUMB = ' + ISNULL(@Lc_InsMatchCur_aInsPhoneExt_NUMB, '') + ', InsFax_NUMB = ' + ISNULL (@Lc_InsMatchCur_aInsFax_NUMB, '') + ', InsEmail_ADDR = ' + ISNULL(@Lc_InsMatchCur_aInsEmail_ADDR, '') + ', InsLine1_ADDR = ' + ISNULL(@Lc_InsMatchCur_aInsLine1_ADDR, '') + ', InsLine2_ADDR = ' + ISNULL(@Lc_InsMatchCur_aInsLine2_ADDR, '') + ', InsCity_ADDR = ' + ISNULL(@Lc_InsMatchCur_aInsCity_ADDR, '') + ', InsState_ADDR = ' + ISNULL(@Lc_InsMatchCur_aInsState_ADDR, '') + ', InsZip_ADDR = ' + ISNULL(@Lc_InsMatchCur_aInsZip_ADDR, '') + ', ForeignAddress_INDC = ' + ISNULL(@Lc_InsMatchCur_aInsForeignAddr_INDC, '') + ', ForeignCountry_NAME = ' + ISNULL(@Lc_InsMatchCur_aForeignCountry_NAME, '') + ', InsaddScrub1_CODE = ' + ISNULL(@Lc_InsMatchCur_aInsAddrScrub1_CODE, '') + ', InsaddScrub2_CODE = ' + ISNULL(@Lc_InsMatchCur_aInsAddrScrub2_CODE, '') + ', InsaddScrub3_CODE = ' + ISNULL(@Lc_InsMatchCur_aInsAddrScrub3_CODE, '') + ', InsClaim_NUMB = ' + ISNULL(@Lc_InsMatchCur_aInsClaim_NUMB, '') + ', InsClaimType_CODE = ' + ISNULL (@Lc_InsMatchCur_aClaimType_CODE, '') + ', InsClaimSt_CODE = ' + ISNULL(@Lc_InsMatchCur_aClaimState_CODE, '') + ', InsClaimLoss_DATE = ' + ISNULL (@Lc_InsMatchCur_aClaimLoss_DATE, '') + ', ClaimBeneficiary_INDC = ' + ISNULL (@Lc_InsMatchCur_aClaimBeneficiary_INDC, '') + ', ClaimReport_DATE = ' + ISNULL (@Lc_InsMatchCur_aClaimReport_DATE, '') + ', ClaimStatus_CODE = ' + ISNULL(@Lc_InsMatchCur_aClaimStatus_CODE, '') + ', ClaimFrequency_CODE = ' + ISNULL (@Lc_InsMatchCur_aClaimFreq_CODE, '') + ', ObligorMatch_CODE = ' + ISNULL (@Lc_InsMatchCur_aObligorMatch_CODE, '') + ', SSNVerification_CODE = ' + ISNULL (@Lc_InsMatchCur_aSsnVerification_CODE, '') + ', ClaimantFirst_NAME = ' + ISNULL(@Lc_InsMatchCur_aClaimantFirst_NAME, '') + ', ClaimantMiddle_NAME = ' + ISNULL (@Lc_InsMatchCur_aClaimantMi_NAME, '') + ', ClaimantLast_NAME = ' + ISNULL(@Lc_InsMatchCur_aClaimantLast_NAME, '') + ', ClaimantItin_NUMB = ' + ISNULL(@Lc_InsMatchCur_aMemberItin_NUMB, '') + ', ClaimantBirth_DATE = ' + ISNULL (@Lc_InsMatchCur_aClaimantBirth_DATE, '') + ', ClaimantSex_CODE = ' + ISNULL(@Lc_InsMatchCur_aClaimantMemberSex_CODE, '') + ', ClaimantHomePhone_NUMB = ' + ISNULL(@Lc_InsMatchCur_aClaimantHomePhoneNumb_TEXT, 0) + ', ClaimantWorkPhone_NUMB = ' + ISNULL(@Lc_InsMatchCur_aClaimant_WorkPhone_NUMB, '') + ', ClaimantWorkPhoneExt_NUMB = ' + ISNULL(@Lc_InsMatchCur_aClaimantWorkPhoneExt_NUMB, '') + ', ClaimantCellPhone_NUMB = ' + ISNULL(@Lc_InsMatchCur_aClaimantCellPhone_NUMB, '') + ', DriversLicenseNo_TEXT = ' + ISNULL(@Lc_InsMatchCur_aDriverLicense_NUMB, '') + ', LicenseState_CODE = ' + ISNULL(@Lc_InsMatchCur_aLicenseState_CODE, '') + ', Occupation_DESC = ' + ISNULL (@Lc_InsMatchCur_aOccupation_TEXT, '') + ', ProfLicenseNo_TEXT = ' + ISNULL (@Lc_InsMatchCur_aProfLicense_NUMB, '') + ', ClaimantForeignaddr_INDC = ' + ISNULL(@Lc_InsMatchCur_aClaimantForeignAddr_INDC, '') + ', ClaimantCountry_NAME = ' + ISNULL(@Lc_InsMatchCur_aClaimantCountry_NAME, '') + ', ClaimantAddr_Scrub1_INDC = ' + ISNULL(@Lc_InsMatchCur_aClaimantAddrScrub1_CODE, '') + ', ClaimantAddr_Scrub2_INDC = ' + ISNULL(@Lc_InsMatchCur_aClaimantAddrScrub2_CODE, '') + ', ClaimantAddr_Scrub3_INDC = ' + ISNULL(@Lc_InsMatchCur_aClaimantAddrScrub3_CODE, '') + ', SortState_Code = ' + ISNULL (@Lc_InsMatchCur_aSortState_CODE, '');
     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR SSN IN DEMO_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_InsMatchCur_aInsMatchObligorSsn_NUMB AS VARCHAR(9)), 0);
      
     SELECT 
     DISTINCT
     @Ln_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE d.MemberSsn_NUMB = @Ln_InsMatchCur_aInsMatchObligorSsn_NUMB;
     
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;
         
     IF @Li_Rowcount_QNTY = 0
      BEGIN
       -- Member not found in the demo table 
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0960_CODE; 

       GOTO lx_exception;
      
      END
     
     SET @Ls_Sql_TEXT = 'CHECK THE MEMBER IS AN NCP ON THE CASE';
     -- Check the member is an NCP role in any case  
     
     SET @Ls_Sqldata_TEXT = 'NcpSsn_NUMB = ' + ISNULL(CAST(@Ln_InsMatchCur_aInsMatchObligorSsn_NUMB AS VARCHAR(9)), 0) + ', Case_IDNO = ' + ISNULL(@Lc_InsMatchCur_aCase_IDNO, '') + ', First_NAME = ' + ISNULL(@Lc_InsMatchCur_aObligorFirst_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_InsMatchCur_aObligorLast_NAME, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);

     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND c.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_TEXT; 
     IF @Ln_Exists_NUMB = 0
      BEGIN
       -- No open case found to process
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0887_CODE; 

       GOTO lx_exception;
      
      END

     SET @Ls_Attorney_NAME = LTRIM(RTRIM(@Lc_InsMatchCur_bAttorneyFirst_NAME)) + ' ' + LTRIM(RTRIM(@Lc_InsMatchCur_bAttorneyLast_NAME));
     -- Do the address update for the member 
          
     SET @Ls_Sql_TEXT = 'CALLING ADDRESS UPDATE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', AddressType_CODE = ' + @Lc_TypeAddressM_CODE;

     EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
      @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
      @Ad_Run_DATE                         = @Ad_Run_DATE,
      @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
      @Ad_Begin_DATE                       = @Ad_Run_DATE,
      @Ad_End_DATE                         = @Ld_High_DATE,
      @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
      @As_Line1_ADDR                       = @Ls_InsMatchCur_aClaimantLine1_ADDR,
      @As_Line2_ADDR                       = @Ls_InsMatchCur_aClaimantLine2_ADDR,
      @Ac_City_ADDR                        = @Lc_InsMatchCur_aClaimantCity_ADDR,
      @Ac_State_ADDR                       = @Lc_InsMatchCur_aClaimantState_ADDR,
      @Ac_Zip_ADDR                         = @Lc_InsMatchCur_aClaimantZip_ADDR,
      @Ac_Country_ADDR                     = ' ',
      @An_Phone_NUMB                       = @Ln_InsMatchCur_aClaimantHomePhone_NUMB,
      @Ac_SourceLoc_CODE                   = @Lc_SourceFedcaseregistr_CODE, 
      @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
      @Ad_Status_DATE                      = @Ad_Run_DATE,
      @Ac_Status_CODE                      = @Lc_VerificationStatusPending_CODE,
      @Ac_SourceVerified_CODE              = @Lc_Space_TEXT,
      @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
      @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
      @Ac_Process_ID                       = @Lc_ProcessFcrInsmatch_ID,
      @Ac_SignedonWorker_ID                = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
      @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
      @Ac_Normalization_CODE               = @Lc_InsMatchCur_aNormalization_CODE,
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
	
     --Get other party ID for the insurance company using TIN number from OTHP_Y1 table
     --If the insurance match for Workers compensation, get the attorney othp by using the attorney name and type as A
     
     IF @Lc_InsMatchCur_aClaimType_CODE = @Lc_WorkerComp_CODE 
       
      BEGIN
      
       IF @Ls_Attorney_NAME <> ' '
        BEGIN
		 SET @Ls_Sql_TEXT = 'CALLING GET_OTHP';
		 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', Attorney_NAME = ' + ISNULL(@Ls_Attorney_NAME, '');

         EXECUTE BATCH_COMMON$SP_GET_OTHP
          @Ad_Run_DATE                     = @Ad_Run_DATE,
          @An_Fein_IDNO                    = @Ln_InsMatchCur_aTin_NUMB,
          @Ac_TypeOthp_CODE                = @Lc_TypeOthpAttorney_CODE,
          @As_OtherParty_NAME              = @Ls_Attorney_NAME,
          @Ac_Aka_NAME                     = @Lc_Space_TEXT,
          @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
          @As_Line1_ADDR                   = @Lc_InsMatchCur_bAttorneyLine1_ADDR,
          @As_Line2_ADDR                   = @Lc_InsMatchCur_bAttorneyLine2_ADDR,
          @Ac_City_ADDR                    = @Lc_InsMatchCur_bAttorneyCity_ADDR,
          @Ac_Zip_ADDR                     = @Lc_InsMatchCur_bAttorneyZip_ADDR,
          @Ac_State_ADDR                   = @Lc_InsMatchCur_bAttorneyState_ADDR,
          @Ac_Fips_CODE                    = @Lc_Space_TEXT,
          @Ac_Country_ADDR                 = @Lc_InmCountry_CODE,
          @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
          @An_Phone_NUMB                   = @Ln_InsMatchCur_bAttorneyPhone_NUMB,
          @An_Fax_NUMB                     = @Ln_Zero_NUMB,
          @As_Contact_EML                  = @Lc_Space_TEXT,
          @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
          @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
          @An_Sein_IDNO                    = @Ln_Zero_NUMB,
          @Ac_SourceLoc_CODE               = @Lc_SourceFedcaseregistr_CODE, 
          @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
          @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
          @Ac_Normalization_CODE           = @Lc_UnnormalizedU_INDC,
          @Ac_Process_ID                   = @Lc_ProcessFcrInsmatch_ID,
          @An_OtherParty_IDNO              = @Ln_OtherPartyAttorney_IDNO OUTPUT,
          @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
			SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			RAISERROR (50001,16,1);
		  END
	
        END
      
       SET @Ls_Sql_TEXT = 'CALLING GET_OTHP';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', Insurer_NAME = ' + ISNULL(@Ls_InsMatchCur_aInsurer_NAME, '');
       EXECUTE BATCH_COMMON$SP_GET_OTHP
        @Ad_Run_DATE                     = @Ad_Run_DATE,
        @An_Fein_IDNO                    = @Ln_InsMatchCur_aTin_NUMB,
        @Ac_TypeOthp_CODE                = @Lc_TypeOthpInsurance_CODE,
        @As_OtherParty_NAME              = @Ls_InsMatchCur_aInsurer_NAME,
        @Ac_Aka_NAME                     = @Lc_Space_TEXT,
        @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
        @As_Line1_ADDR                   = @Lc_InsMatchCur_aInsLine1_ADDR,
        @As_Line2_ADDR                   = @Lc_InsMatchCur_aInsLine2_ADDR,
        @Ac_City_ADDR                    = @Lc_InsMatchCur_aInsCity_ADDR,
        @Ac_Zip_ADDR                     = @Lc_InsMatchCur_aInsZip_ADDR,
        @Ac_State_ADDR                   = @Lc_InsMatchCur_aInsState_ADDR,
        @Ac_Fips_CODE                    = @Lc_Space_TEXT,
        @Ac_Country_ADDR                 = @Lc_InmCountry_CODE,
        @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
        @An_Phone_NUMB                   = @Ln_Zero_NUMB,
        @An_Fax_NUMB                     = @Ln_Zero_NUMB,
        @As_Contact_EML                  = @Lc_Space_TEXT,
        @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
        @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
        @An_Sein_IDNO                    = @Ln_Zero_NUMB,
        @Ac_SourceLoc_CODE               = @Lc_SourceFedcaseregistr_CODE, 
        @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
        @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
        @Ac_Normalization_CODE           = @Lc_InsMatchCur_aInsuranceNormalization_CODE,
        @Ac_Process_ID                   = @Lc_ProcessFcrInsmatch_ID,
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
	  
       -- Other party id not found in DECSS
       IF @Ln_OtherParty_IDNO = @Ln_Zero_NUMB 
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'OtherParty_IDNO NOT FOUND/SPACES';
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0620_CODE;

         GOTO lx_exception;
        
        END

       SET @Ls_Sql_TEXT = 'CALLING EMPLOYER UPDATE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), 0);
       EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
        @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
        @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
        @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
        @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE,
        @Ad_Status_DATE                = @Ad_Run_DATE,
        @Ac_TypeIncome_CODE            = @Lc_IncomeWorkercomp_CODE,
        @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, 
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @Ad_BeginEmployment_DATE       = @Ad_Run_DATE,
        @Ad_EndEmployment_DATE         = @Ld_High_DATE,
        @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
        @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
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
        @Ac_Process_ID                 = @Lc_ProcessFcrInsmatch_ID,
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
      
       SET @Ls_Sql_TEXT = 'CALLING ASFN UPDATE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), 0);
       EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_ASFN
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @An_OtherParty_IDNO          = @Ln_OtherParty_IDNO,
        @An_OthpAtty_IDNO            = @Ln_OtherPartyAttorney_IDNO,
        @Ad_Response_DATE            = @Lc_InsMatchCur_aProcessed_DATE,
        @Ac_AcctAssetNo_TEXT         = @Lc_InsMatchCur_aInsClaim_NUMB,
        @An_ValueAsset_AMNT          = @Ln_Zero_NUMB,
        @Ac_AcctType_CODE            = @Lc_IncomeWorkercomp_CODE , 
        @Ac_Asset_CODE               = @Lc_AssetIns_CODE,
        @As_AcctLegalTitle_TEXT      = @Lc_Space_TEXT,
        @Ac_IndJointAccount_TEXT     = @Lc_Space_TEXT,
        @Ac_AcctLocState_CODE        = @Lc_InsMatchCur_aClaimState_CODE,
        @Ac_SourceLoc_CODE           = @Lc_LocateSourceInsuranceMatch_CODE,
        @Ac_NameAcctPrimaryNo_TEXT   = @Lc_Space_TEXT,
        @Ac_NameAcctSecondaryNo_TEXT = @Lc_Space_TEXT,
        -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -START-
        @Ad_ClaimLoss_DATE			 = @Lc_InsMatchCur_aClaimLoss_DATE,
        -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -END-
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
           
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         -- Member assest update failed 
         SET @Ls_DescriptionError_TEXT = 'MEMBER ASFN UPDATE FAILED FOR ';

         RAISERROR(50001,16,1);
        
        END
       ELSE
       -- DUPLICATE FIN ASSET EXISTS FOR MEMBER'
       IF @Lc_Msg_CODE = @Lc_MsgD1_CODE
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

         GOTO lx_exception;
        END

       -- Create a ELFC Trigger records for all the enforcement cases the member was active NCP
       -- Declare cursor for open enforcement cases for the member NCP
       DECLARE OpenCases_CUR INSENSITIVE CURSOR FOR
        SELECT a.Case_IDNO,
               c.OrderSeq_NUMB
          FROM CMEM_Y1 a,
               CASE_Y1 b,
               ACEN_Y1 c
         WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
           AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePf_TEXT)
           AND a.Case_IDNO = b.Case_IDNO
           AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE
           AND c.Case_IDNO = b.Case_IDNO
           AND c.StatusEnforce_CODE = @Lc_StatusEnforceO_CODE
           AND C.EndValidity_DATE = @Ld_High_DATE;

       OPEN OpenCases_CUR;
      
       FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO, @Ln_OpenCasesCur_OrderSeq_NUMB;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	   -- Create ELFC triggers for enforcement cases where the member is active  
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         -- Calling insert elfc process
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
         
         SET @Ls_SqlData_TEXT = '@Ln_OpenCasesCur_Case_IDNO = ' + CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR(6));

         EXECUTE BATCH_COMMON$SP_INSERT_ELFC
          @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OpenCasesCur_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @An_OthpSource_IDNO          = @Ln_OtherParty_IDNO,
          @Ac_TypeChange_CODE          = @Lc_TypeChangeLien_CODE,
          @Ac_NegPos_CODE              = @Lc_NegPosStartRemedy_CODE,
          @Ac_Process_ID               = @Lc_ProcessFcrInsmatch_ID,
          @Ad_Create_DATE              = @Ad_Run_DATE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_TypeReference_CODE       = @Lc_AssetIns_CODE, 
          @Ac_Reference_ID             = @Lc_InsMatchCur_aInsClaim_NUMB,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
          						
           SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

           RAISERROR (50001,16,1);
          END;

         -- 10827 Create Case journal entry RRFCR for all the cases where member is active cp or pf or ncp 
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
         -- 10827
         FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO, @Ln_OpenCasesCur_OrderSeq_NUMB;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE OpenCases_CUR;

       DEALLOCATE OpenCases_CUR;
      END
     ELSE
     --If the insurance match for personal injury, get the othp  ID by using Insurance company name and type as I
     IF @Lc_InsMatchCur_aClaimType_CODE = @Lc_PersonelInjury_CODE  
      BEGIN
       SET @Ls_Sql_TEXT = 'CALLING GET_OTHP';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', InsuranceCompany_NAME = ' + ISNULL(@Ls_Attorney_NAME, '');
       EXECUTE BATCH_COMMON$SP_GET_OTHP
        @Ad_Run_DATE                     = @Ad_Run_DATE,
        @An_Fein_IDNO                    = @Ln_InsMatchCur_aTin_NUMB,
        @Ac_TypeOthp_CODE                = @Lc_TypeOthpInsurance_CODE,
        @As_OtherParty_NAME              = @Ls_InsMatchCur_aInsurer_NAME,
        @Ac_Aka_NAME                     = @Lc_Space_TEXT,
        @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
        @As_Line1_ADDR                   = @Lc_InsMatchCur_aInsLine1_ADDR,
        @As_Line2_ADDR                   = @Lc_InsMatchCur_aInsLine2_ADDR,
        @Ac_City_ADDR                    = @Lc_InsMatchCur_aInsCity_ADDR,
        @Ac_Zip_ADDR                     = @Lc_InsMatchCur_aInsZip_ADDR,
        @Ac_State_ADDR                   = @Lc_InsMatchCur_aInsState_ADDR,
        @Ac_Fips_CODE                    = @Lc_Space_TEXT,
        @Ac_Country_ADDR                 = @Lc_InmCountry_CODE,
        @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
        @An_Phone_NUMB                   = @Ln_Zero_NUMB,
        @An_Fax_NUMB                     = @Ln_Zero_NUMB,
        @As_Contact_EML                  = @Lc_Space_TEXT,
        @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
        @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
        @An_Sein_IDNO                    = @Ln_Zero_NUMB,
        @Ac_SourceLoc_CODE               = @Lc_SourceFedcaseregistr_CODE, 
        @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
        @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
        @Ac_Normalization_CODE           = @Lc_InsMatchCur_aInsuranceNormalization_CODE,
        @Ac_Process_ID                   = @Lc_ProcessFcrInsmatch_ID,
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
	  
       -- Other party id not found in DECSS
       IF @Ln_OtherParty_IDNO = @Ln_Zero_NUMB 
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'OtherParty_IDNO NOT FOUND/SPACES';
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0620_CODE;

         GOTO lx_exception;
        
        END
     
       SET @Ls_Sql_TEXT = 'CALLING EMPLOYER UPDATE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), 0);
       EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
        @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
        @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
        @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
        @Ac_Status_CODE                = @Lc_VerificationStatusPending_CODE,
        @Ad_Status_DATE                = @Ad_Run_DATE,
        @Ac_TypeIncome_CODE            = @Lc_IncomePersonelInjury_CODE,
        @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT, 
        @Ad_Run_DATE                   = @Ad_Run_DATE,
        @Ad_BeginEmployment_DATE       = @Ad_Run_DATE,
        @Ad_EndEmployment_DATE         = @Ld_High_DATE,
        @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
        @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
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
        @An_TransactionEventSeq_NUMB   = 0,
        @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
        @Ac_Process_ID                 = @Lc_ProcessFcrInsmatch_ID,
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
	      
       SET @Ls_Sql_TEXT = 'CALLING ASFN UPDATE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), 0);
       EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_ASFN
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @An_OtherParty_IDNO          = @Ln_OtherParty_IDNO,
        @An_OthpAtty_IDNO            = @Ln_Zero_NUMB,
        @Ad_Response_DATE            = @Lc_InsMatchCur_aProcessed_DATE,
        @Ac_AcctAssetNo_TEXT         = @Lc_InsMatchCur_aInsClaim_NUMB,
        @An_ValueAsset_AMNT          = @Ln_Zero_NUMB,
        @Ac_AcctType_CODE            = @Lc_IncomePersonelInjury_CODE, 
        @Ac_Asset_CODE               = @Lc_AssetIns_CODE,
        @As_AcctLegalTitle_TEXT      = @Lc_Space_TEXT,
        @Ac_IndJointAccount_TEXT     = @Lc_Space_TEXT,
        @Ac_AcctLocState_CODE        = @Lc_InsMatchCur_aClaimState_CODE,
        @Ac_SourceLoc_CODE           = @Lc_LocateSourceInsuranceMatch_CODE,
        @Ac_NameAcctPrimaryNo_TEXT   = @Lc_Space_TEXT,
        @Ac_NameAcctSecondaryNo_TEXT = @Lc_Space_TEXT,
        -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -START-
        @Ad_ClaimLoss_DATE			 = @Lc_InsMatchCur_aClaimLoss_DATE,
        -- 13512 - Incoming FCR insurance match process to map calim loss date to ASFN_Y1 table -END-
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       -- Member assest update failed   
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'MEMBER ASSET UPDATE FAILED ';
         RAISERROR(50001,16,1);
        
        END
       ELSE
       -- Duplicate record exists
       IF @Lc_Msg_CODE = @Lc_MsgD1_CODE
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

         GOTO lx_exception;
        END

       -- Create a ELFC Trigger records for all the enforcement cases the member was an active NCP
       -- Declare cursor for open enforcement cases for the member NCP
       DECLARE OpenCases_CUR INSENSITIVE CURSOR FOR
        SELECT a.Case_IDNO,
               c.OrderSeq_NUMB
          FROM CMEM_Y1 a,
               CASE_Y1 b,
               ACEN_Y1 c
         WHERE A.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
           AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePf_TEXT)
           AND a.Case_IDNO = b.Case_IDNO
           AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE
           AND c.Case_IDNO = b.Case_IDNO
           AND c.StatusEnforce_CODE = @Lc_StatusEnforceO_CODE
           AND C.EndValidity_DATE = @Ld_High_DATE;

       OPEN OpenCases_CUR;

       FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO, @Ln_OpenCasesCur_OrderSeq_NUMB;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       -- Insert ELFC records for enforcement cases where the member is active
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         -- Calling insert elfc process
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';

         SET @Ls_SqlData_TEXT = '@Ln_OpenCasesCur_Case_IDNO = ' + CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR(6));

         EXECUTE BATCH_COMMON$SP_INSERT_ELFC
          @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OpenCasesCur_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @An_OthpSource_IDNO          = @Ln_OtherParty_IDNO,
          @Ac_TypeChange_CODE          = @Lc_TypeChangeLien_CODE,
          @Ac_NegPos_CODE              = @Lc_NegPosStartRemedy_CODE,
          @Ac_Process_ID               = @Lc_ProcessFcrInsmatch_ID,
          @Ad_Create_DATE              = @Ad_Run_DATE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_TypeReference_CODE       = @Lc_AssetIns_CODE,
          @Ac_Reference_ID             = @Lc_InsMatchCur_aInsClaim_NUMB,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
          					
           SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

           RAISERROR (50001,16,1);
          END;

           -- 10827 Create Case journal entry RRFCR for all the cases where member is active cp or pf or ncp 
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
         -- 10827
         FETCH NEXT FROM OpenCases_CUR INTO @Ln_OpenCasesCur_Case_IDNO, @Ln_OpenCasesCur_OrderSeq_NUMB;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE OpenCases_CUR;

       DEALLOCATE OpenCases_CUR;
      END
        
     -- Check for any exception to write the record inot BATE_Y1 table            
     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Ac_Job_ID , ''); 
             
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

       -- Insert into BATE_Y1 table failed 
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO BATE 10 FAILED FOR ';

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
		IF XACT_STATE() = 1
	     BEGIN
	   	   ROLLBACK TRANSACTION SAVEINSMATCH_DETAILS;
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
     
     -- Processed record count will be incremented by 2, because two records are processed one each from LFIMD_Y1 and LFIMA_Y1 tables for the insurance match
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 2 ;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATE LFIMD_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_InsMatchCur_aSeq_IDNO AS VARCHAR), '');
    
     UPDATE LFIMD_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_InsMatchCur_aSeq_IDNO;

     -- Check the update success              
     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LoadFcrInsMatchPart1Details_T1';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE LFIMA_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_InsMatchCur_bSeq_IDNO AS VARCHAR(20));

     UPDATE LFIMA_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_InsMatchCur_bSeq_IDNO;

     -- Check the update success or failure   
     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LoadFcrInsMatchPart2Details_T1';

       RAISERROR(50001,16,1);
      END
     
     -- Check for commit, if commit frequency quantity is reached 
     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK ';
     SET @Ls_Sqldata_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(15)), '');

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

       -- Check for status of restart update sp
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'BATCH RESTART UPDATE FAILED ';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION INSMATCH_DETAILS; 
       BEGIN TRANSACTION INSMATCH_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     -- Check the exception threshold is reached, before raising error 
     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(15)), '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION INSMATCH_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM InsMatch_CUR INTO @Ln_InsMatchCur_aSeq_IDNO, @Lc_InsMatchCur_aInsRec_ID, @Lc_InsMatchCur_aInsMatchObligorSsnNumb_TEXT, @Lc_InsMatchCur_aRecordCreation_DATE, @Lc_InsMatchCur_aRecordSequence_NUMB, @Lc_InsMatchCur_aSubRecord_NUMB, @Lc_InsMatchCur_aCase_IDNO, @Lc_InsMatchCur_aObligorFirst_NAME, @Lc_InsMatchCur_aObligorLast_NAME, @Lc_InsMatchCur_aMemberSsnNumb_TEXT, @Lc_InsMatchCur_aTinNumb_TEXT, @Lc_InsMatchCur_aProcessed_DATE, @Lc_InsMatchCur_aClaimUpdate_INDC, @Ls_InsMatchCur_aInsurer_NAME, @Lc_InsMatchCur_aInsContactFirst_NAME, @Lc_InsMatchCur_aInsContactLast_NAME, @Lc_InsMatchCur_aInsPhone_NUMB, @Lc_InsMatchCur_aInsPhoneExt_NUMB, @Lc_InsMatchCur_aInsFax_NUMB, @Lc_InsMatchCur_aInsEmail_ADDR, @Lc_InsMatchCur_aInsLine1_ADDR, @Lc_InsMatchCur_aInsLine2_ADDR, @Lc_InsMatchCur_aInsCity_ADDR, @Lc_InsMatchCur_aInsState_ADDR, @Lc_InsMatchCur_aInsZip_ADDR, @Lc_InsMatchCur_aInsForeignAddr_INDC, @Lc_InsMatchCur_aForeignCountry_NAME, @Lc_InsMatchCur_aInsAddrScrub1_CODE, @Lc_InsMatchCur_aInsAddrScrub2_CODE, @Lc_InsMatchCur_aInsAddrScrub3_CODE, @Lc_InsMatchCur_aInsClaim_NUMB, @Lc_InsMatchCur_aClaimType_CODE, @Lc_InsMatchCur_aClaimState_CODE, @Lc_InsMatchCur_aClaimLoss_DATE, @Lc_InsMatchCur_aClaimBeneficiary_INDC, @Lc_InsMatchCur_aClaimReport_DATE, @Lc_InsMatchCur_aClaimStatus_CODE, @Lc_InsMatchCur_aClaimFreq_CODE, @Lc_InsMatchCur_aObligorMatch_CODE, @Lc_InsMatchCur_aSsnVerification_CODE, @Lc_InsMatchCur_aClaimantFirst_NAME, @Lc_InsMatchCur_aClaimantMi_NAME, @Lc_InsMatchCur_aClaimantLast_NAME, @Lc_InsMatchCur_aMemberItin_NUMB, @Lc_InsMatchCur_aClaimantBirth_DATE, @Lc_InsMatchCur_aClaimantMemberSex_CODE, @Lc_InsMatchCur_aClaimantHomePhoneNumb_TEXT, @Lc_InsMatchCur_aClaimant_WorkPhone_NUMB, @Lc_InsMatchCur_aClaimantWorkPhoneExt_NUMB, @Lc_InsMatchCur_aClaimantCellPhone_NUMB, @Lc_InsMatchCur_aDriverLicense_NUMB, @Lc_InsMatchCur_aLicenseState_CODE, @Lc_InsMatchCur_aOccupation_TEXT, @Lc_InsMatchCur_aProfLicense_NUMB, @Lc_InsMatchCur_aClaimantForeignAddr_INDC, @Lc_InsMatchCur_aClaimantCountry_NAME, @Lc_InsMatchCur_aClaimantAddrScrub1_CODE, @Lc_InsMatchCur_aClaimantAddrScrub2_CODE, @Lc_InsMatchCur_aClaimantAddrScrub3_CODE, @Lc_InsMatchCur_aSortState_CODE, @Lc_InsMatchCur_aNormalization_CODE, @Ls_InsMatchCur_aClaimantLine1_ADDR, @Ls_InsMatchCur_aClaimantLine2_ADDR, @Lc_InsMatchCur_aClaimantCity_ADDR, @Lc_InsMatchCur_aClaimantState_ADDR, @Lc_InsMatchCur_aClaimantZip_ADDR, @Lc_InsMatchCur_aInsuranceNormalization_CODE, @Lc_InsMatchCur_bAttorneyFirst_NAME, @Lc_InsMatchCur_bAttorneyLast_NAME, @Lc_InsMatchCur_bAttorneyPhoneNumb_TEXT, @Lc_InsMatchCur_bAttorneyPhoneExt_NUMB, @Lc_InsMatchCur_bAttorneyLine1_ADDR, @Lc_InsMatchCur_bAttorneyLine2_ADDR, @Lc_InsMatchCur_bAttorneyCity_ADDR, @Lc_InsMatchCur_bAttorneyState_ADDR, @Lc_InsMatchCur_bAttorneyZip_ADDR, @Lc_InsMatchCur_bAttorneyForeignAddr_INDC, @Lc_InsMatchCur_bAttorneyCountry_NAME, @Lc_InsMatchCur_bAttorneyAddrScrub1_CODE, @Lc_InsMatchCur_bAttorneyAddrScrub2_CODE, @Lc_InsMatchCur_bAttorneyAddrScrub3_CODE, @Lc_InsMatchCur_bTpaCompany_NAME, @Lc_InsMatchCur_bTpaContactFirst_NAME, @Lc_InsMatchCur_bTpaContactLast_NAME, @Lc_InsMatchCur_bTpaPhone_NUMB, @Lc_InsMatchCur_bTpaPhoneExt_NUMB, @Lc_InsMatchCur_bTpaLine1_ADDR, @Lc_InsMatchCur_bTpaLine2_ADDR, @Lc_InsMatchCur_bTpaCity_ADDR, @Lc_InsMatchCur_bTpaState_ADDR, @Lc_InsMatchCur_bTpaZip_ADDR, @Lc_InsMatchCur_bTpaForeignAddr_INDC, @Lc_InsMatchCur_bTpaCountry_NAME, @Lc_InsMatchCur_bTpaAddrScrub1_CODE, @Lc_InsMatchCur_bTpaAddrScrub2_CODE, @Lc_InsMatchCur_bTpaAddrScrub3_CODE, @Lc_InsMatchCur_bEmployer_NAME, @Lc_InsMatchCur_bEmployerPhone_NUMB, @Lc_InsMatchCur_bEmployerPhoneExt_NUMB, @Lc_InsMatchCur_bEmployerLine1_ADDR, @Lc_InsMatchCur_bEmployerLine2_ADDR, @Lc_InsMatchCur_bEmployerCity_ADDR, @Lc_InsMatchCur_bEmployerState_ADDR, @Lc_InsMatchCur_bEmployerZip_ADDR, @Lc_InsMatchCur_bEmployerForeignAddr_INDC, @Lc_InsMatchCur_bEmployerCountry_NAME, @Lc_InsMatchCur_bEmployerAddrScrub1_CODE, @Lc_InsMatchCur_bEmployerAddrScrub2_CODE, @Lc_InsMatchCur_bEmployerAddrScrub3_CODE, @Lc_InsMatchCur_bNormalization_CODE,
     
     @Ln_InsMatchCur_bSeq_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE InsMatch_CUR;

   DEALLOCATE InsMatch_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  
   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   
   COMMIT TRANSACTION INSMATCH_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   -- Check for any updates and rollback them
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION INSMATCH_DETAILS;
    END;

   -- Set the message code to status failed
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   -- Check the cursor is open, if open close and deallocate the cursor
   IF CURSOR_STATUS ('local', 'InsMatch_CUR') IN (0, 1)
    BEGIN
     CLOSE InsMatch_CUR;

     DEALLOCATE InsMatch_CUR;
    END;
   
   IF CURSOR_STATUS ('local', 'OpenCases_CUR') IN (0, 1)
    BEGIN
     CLOSE OpenCases_CUR;

     DEALLOCATE OpenCases_CUR;
    END;
   --Set Error Description
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   -- If not user defined error, capture the error message into loca variable 
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   -- Call the error routine 	
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  
  END CATCH;
 END;


GO
