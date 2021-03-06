/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ADDRESS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_ADDRESS_UPDATE
Programmer Name		: IMP Team
Description			: This procedure receives member's addresses and de-duplicates the addresses with existing 
					  addresses in AHIS_Y1 and updates addresses in AHIS_Y1. Member addresses are normalized by 
					  the common address normalize before passing the address to this process.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ADDRESS_UPDATE]
 @An_MemberMci_IDNO                   NUMERIC(10),
 @Ad_Run_DATE                         DATE,
 @Ac_TypeAddress_CODE                 CHAR(1) = 'M',
 @Ad_Begin_DATE                       DATE,
 @Ad_End_DATE                         DATE,
 @Ac_Attn_ADDR                        CHAR(40) = ' ',
 @As_Line1_ADDR                       VARCHAR(50),
 @As_Line2_ADDR                       VARCHAR(50) = ' ',
 @Ac_City_ADDR                        CHAR(28),
 @Ac_State_ADDR                       CHAR(2),
 @Ac_Zip_ADDR                         CHAR(15),
 @Ac_Country_ADDR                     CHAR(2) = 'US',
 @An_Phone_NUMB                       NUMERIC(15) = 0,
 @Ac_SourceLoc_CODE                   CHAR(3),
 @Ad_SourceReceived_DATE              DATE,
 @Ad_Status_DATE                      DATE,
 @Ac_Status_CODE                      CHAR(1),
 @Ac_SourceVerified_CODE              CHAR(3),
 @As_DescriptionComments_TEXT         VARCHAR(1000),
 @As_DescriptionServiceDirection_TEXT VARCHAR(1000),
 @Ac_Process_ID                       CHAR(10),
 @Ac_SignedOnWorker_ID                CHAR(30),
 @An_TransactionEventSeq_NUMB         NUMERIC(19),
 @An_OfficeSignedOn_IDNO              NUMERIC(3) = 0,
 @Ac_Normalization_CODE               CHAR(1),
 @Ac_CcrtMemberAddress_CODE           CHAR(1) = '',
 @Ac_CcrtCaseRelationship_CODE        CHAR(1) = '',
 @Ac_Msg_CODE                         CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT            VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_TopicIn_IDNO                     NUMERIC(10, 0) = 0,
          @Ln_MemberMci595_IDNO                NUMERIC(10) = 999995, --Bug13703
          @Li_AddVerifiedAGoodAddress5290_NUMB INT = 5290,
          @Li_InvalidateMemberAddress5300_NUMB INT = 5300,
          @Li_ModifyAddress5280_NUMB           INT = 5280,
          @Li_AddAddress5270_NUMB              INT = 5270,
          @Lc_Space_TEXT                       CHAR(1) = ' ',
          @Lc_StatusCaseMemberActive_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE          CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE   CHAR(1) = 'P',
          @Lc_CaseStatusOpen_CODE              CHAR(1) = 'O',
          @Lc_CaseStatusClose_CODE             CHAR(1) = 'C',
          @Lc_Yes_INDC                         CHAR(1) = 'Y',
          @Lc_VerificationStatusGood_CODE      CHAR(1) = 'Y',
          @Lc_VerificationStatusPending_CODE   CHAR(1) = 'P',
          @Lc_TypeAddressCourtC_CODE           CHAR(1) = 'C',
          @Lc_TypeAddressMailM_CODE            CHAR(1) = 'M',
          @Lc_TypeAddressMailR_CODE            CHAR(1) = 'R',
          @Lc_No_INDC                          CHAR(1) = 'N',
          @Lc_StatusFailed_CODE                CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
          @Lc_RespondInitInitiate_CODE         CHAR(1) = 'I',
          @Lc_RespondInitResponding_CODE       CHAR(1) = 'R',
          @Lc_RespondInitNonInterstate_TEXT    CHAR(1) = 'N',
          @Lc_VerificationStatusBad_CODE       CHAR(1) = 'B',
          @Lc_WelfareTypeNonTanf_CODE          CHAR(1) = 'N',
          @Lc_TypeOffice5_CODE                 CHAR(1) = '5',
          @Lc_WelfareTypeTanf_CODE             CHAR(1) = 'A',
          @Lc_OrderTypeVoluntary_CODE          CHAR(1) = 'V',
          @Lc_ErrorE0606_CODE                  CHAR(5) = 'E0606',
          @Lc_ErrorE0702_CODE                  CHAR(5) = 'E0702',
          @Lc_ErrorE0542_CODE                  CHAR(5) = 'E0542',
          @Lc_ErrorE0520_CODE                  CHAR(5) = 'E0520',
          @Lc_ErrorE0145_CODE                  CHAR(5) = 'E0145',
          @Lc_ErrorE1089_CODE                  CHAR(5) = 'E1089',
          @Lc_ErrorE0153_CODE                  CHAR(5) = 'E0153',
          @Lc_ErrorE0997_CODE                  CHAR(5) = 'E0997',
          @Lc_ErrorE1424_CODE                  CHAR(5) = 'E1424',
          @Lc_ErrorE0026_CODE                  CHAR(5) = 'E0026', --Bug13703
          @Lc_UnnormalizedU_TEXT               CHAR(1) = 'U',
          @Lc_VerStatusPending_ADDR            CHAR(1) = 'P',
          @Lc_TypeOthpE_IDNO                   CHAR(1) = 'E',
          @Lc_ActionP_CODE                     CHAR(1) = 'P',
          @Lc_MsgW0156_CODE                    CHAR(5) = 'W0156',
          @Lc_MsgK_CODE                        CHAR(5) = NULL,
          @Lc_StatusLocateN_CODE               CHAR(1) = 'N',
          @Lc_StatusLocateL_CODE               CHAR(1) = 'L',
          @Lc_State_ADDR                       CHAR(2) = '',
          @Lc_Country_ADDR                     CHAR(2) = '',
          @Lc_CountryUs_CODE                   CHAR(2) = 'US',
          @Lc_StateInState_CODE                CHAR(2) = 'DE',
          @Lc_DebtTypeGeneticTest_CODE         CHAR(2) = 'GT',
          @Lc_IncomeTypeUnemployment_CODE      CHAR(2) = 'UA',
          @Lc_IncomeTypeDisability_CODE        CHAR(2) = 'DS',
          @Lc_IncomeTypeUnion_CODE             CHAR(2) = 'UN',
          @Lc_SubsystemIn_CODE                 CHAR(2) = 'IN',
          @Lc_SubsystemLoc_CODE                CHAR(2) = 'LO',
          @Lc_SubsystemEst_CODE                CHAR(3) = 'ES',
          @Lc_RsnStatusCaseUb_CODE             CHAR(2) = 'UB',
          @Lc_RsnStatusCaseUC_CODE             CHAR(2) = 'UC',
          @Lc_SourceLocOsa_CODE                CHAR(3) = 'OSA',
          @Lc_SourceLocFam_CODE                CHAR(3) = 'FAM',
          @Lc_SourceLocCoa_CODE                CHAR(3) = 'COA',
          @Lc_SourceLocPop_CODE                CHAR(3) = 'POP',
          @Lc_FunctionMsc_CODE                 CHAR(3) = 'MSC',
          @Lc_MajorActivityCase_CODE           CHAR(4) = 'CASE',
          @Lc_RemedyStatusStart_CODE           CHAR(4) = 'STRT',
          @Lc_TableStat_IDNO                   CHAR(4) = 'STAT',
          @Lc_TableSubStat_IDNO                CHAR(4) = 'STAT',
          @Lc_ActivityMajorEstp_CODE           CHAR(4) = 'ESTP',
          @Lc_ReasonLsout_CODE                 CHAR(5) = 'LSOUT',
          @Lc_ProcessFacts_IDNO                CHAR(5) = 'FACTS',
          @Lc_ActivityMinorGpmla_CODE          CHAR(5) = 'GPMLA',
          @Lc_ActivityMinorArccl_CODE          CHAR(5) = 'ARCCL',
          @Lc_ReasonLsadr_CODE                 CHAR(5) = 'LSADR',
          @Lc_ActivityMinorLsout_CODE          CHAR(5) = 'LSOUT',
          @Lc_ActivityMinorSaout_CODE          CHAR(5) = 'SAOUT',
          @Lc_MinorActivityCmasw_CODE          CHAR(5) = 'CMASW',
          @Lc_ActivityMinorGlnwf_CODE          CHAR(5) = 'GLNWF',
          @Lc_MinorActivityLocab_CODE          CHAR(5) = 'LOCAB',
          @Lc_MinorActivityLocaa_CODE          CHAR(5) = 'LOCAA',
          @Lc_ActivityMinorRunca_CODE          CHAR(5) = 'RUNCA',
          @Lc_ActivityMinorRcona_CODE          CHAR(5) = 'RCONA',
          @Lc_DateFormatYyyymm_TEXT            CHAR(6) = 'YYYYMM',
          @Lc_NoticeCsm04_IDNO                 CHAR(8) = 'CSM-04',
          @Lc_Zip_ADDR                         CHAR(15) = '',
          @Lc_RegNotAlphanumeric_TEXT          CHAR(22) = '[^[:ALPHA:][:DIGIT:]]',
          @Lc_RegCity_TEXT                     CHAR(26) = '[^[:ALPHA:][:DIGIT:]-. '']',
          @Lc_City_ADDR                        CHAR(28) = '',
          @Lc_BatchRunUser_TEXT                CHAR(30) = 'BATCH',
          --@Lc_FamisRunUser_TEXT                CHAR(30) = 'FAMIS', --Bug-13593
          @Lc_RegNotSpecialchar_TEXT           CHAR(30) = '[^[:ALPHA:][:DIGIT:]-#./ ,'']',
          @Ls_Line1_ADDR                       VARCHAR(50) = '',
          @Ls_Line2_ADDR                       VARCHAR(50) = '',
          @Ls_Procedure_NAME                   VARCHAR(100) = 'BATCH_COMMON$SP_ADDRESS_UPDATE',
          @Ls_XmlTextIn_TEXT                   VARCHAR(4000) = ' ',
          @Ld_High_DATE                        DATE = '12/31/9999',
          @Ld_Low_DATE                         DATE = '01/01/0001';
  DECLARE @Ln_FetchStatus_QNTY                      NUMERIC,
          @Ln_EventFunctionalSeq_NUMB               NUMERIC(4),
          @Ln_Zero_NUMB							    NUMERIC = 0,
          @Ln_IncomingTypeAddressCgCountRecord_QNTY NUMERIC = 0,
          @Ln_CcrtMailAddress_QNTY                  NUMERIC(5) = 0,
          @Ln_CcrtResidentialAddress_QNTY           NUMERIC(5) = 0,
          @Ln_RowCount_QNTY                         NUMERIC(7),
          @Ln_MemberMci_IDNO                        NUMERIC(10),
          @Ln_CountRecord_QNTY                      NUMERIC(10) = 0,
          @Ln_CountRecordCcrt_QNTY                  NUMERIC(10) = 0,
          @Ln_CountRecordPending_QNTY               NUMERIC(10) = 0,
          @Ln_Court_QNTY                            NUMERIC(10) = 0,
          @Ln_nTanfCount_NUMB                       NUMERIC(10) = 0,
          @Ln_Csm04NcpMemberMci_IDNO                NUMERIC(10),
          @Ln_Topic_NUMB                            NUMERIC(10, 0),
          @Ln_Arrears_AMNT                          NUMERIC(11, 2) = 0,
          @Ln_Obligation_AMNT                       NUMERIC(11, 2) = 0,
          @Ln_Error_NUMB                            NUMERIC(11),
          @Ln_ErrorLine_NUMB                        NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB              NUMERIC(19) = 0,
          @Ln_TransactionEventDemoSeq_NUMB          NUMERIC(19, 0),
          @Ln_TransactionEventLsttSeq_NUMB          NUMERIC(19, 0),
          @Lc_Null_TEXT                             CHAR(1) = '',
          @Lc_Msg_CODE                              CHAR(5),
          @Lc_Status_CODE                           CHAR(1),
          @Lc_Subsystem_CODE                        CHAR(3) = '',
          @Lc_CcrtCaseRelationship_CODE             CHAR(1) = '',
          @Lc_ActivityMajorRmdy_CODE                CHAR(4),
          @Lc_Reason_CODE                           CHAR(5),
          @Lc_ActivityMinor_CODE                    CHAR(5),
          @Lc_Notice_ID                             CHAR(8),
          @Ls_Sql_TEXT                              VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                          VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT                     VARCHAR(2000),
          @Ls_ErrorDesc_TEXT                        VARCHAR(4000),
          @Ld_End_DATE                              DATE,
          @Ld_Temp_DATE                             DATETIME2,
          @Lb_AhisExist_BIT                         BIT,
          @Lb_EhisExist_BIT                         BIT,
          @Lb_LsttExist_BIT                         BIT,
          @Lb_VerStatusGood_BIT                     BIT,
          @Lb_LsttInsert_BIT                        BIT,
          @Lb_Cs563Generated_BIT                    BIT = 0,
          @Lb_GenerateSaout_BIT                     BIT = 0;
  DECLARE @Ln_CaseCur_Case_IDNO             NUMERIC(6),
          @Ln_CaseCur_Application_IDNO      NUMERIC(15),
          @Lc_CaseCur_CaseRelationship_CODE CHAR(1);
  DECLARE @Ln_MemberCur_OfficeOrder_NUMB      NUMERIC(1),
          @Ln_MemberCur_Case_IDNO             NUMERIC(6),
          @Ln_MemberCur_MemberMci_IDNO        NUMERIC(10),
          @Lc_MemberCur_CaseRelationship_CODE CHAR(1),
          @Lc_MemberCur_RespondInit_CODE      CHAR(1);
  DECLARE @Ln_CaseCloseCur_Case_IDNO NUMERIC(6),
          @Lc_CaseCloseCur_Worker_ID CHAR(30);
  DECLARE @Ln_OpenCasesCur_Case_IDNO NUMERIC(6);
  DECLARE MemberCur INSENSITIVE CURSOR FOR
   SELECT a.Case_IDNO,
          a.MemberMci_IDNO,
          a.CaseRelationship_CODE,
          b.RespondInit_CODE,
          CASE
           WHEN b.Office_IDNO = @An_OfficeSignedOn_IDNO
            THEN 1
           ELSE 2
          END AS off_order
     FROM CMEM_Y1 a,
          CASE_Y1 b
    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
      AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
      AND a.Case_IDNO = b.Case_IDNO
      AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
    ORDER BY off_order,
             b.Opened_DATE DESC;
  DECLARE CaseCur INSENSITIVE CURSOR FOR
   SELECT a.Case_IDNO,
          a.CaseRelationship_CODE,
          b.Application_IDNO
     FROM CMEM_Y1 a,
          CASE_Y1 b
    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
      AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
      AND a.Case_IDNO = b.Case_IDNO
      AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_ErrorE1424_CODE;
   SET @As_DescriptionError_TEXT = '';

--Bug13703-ADD-BEGIN
	IF @An_MemberMci_IDNO = @Ln_MemberMci595_IDNO
	BEGIN
		SET @Ac_Msg_CODE = @Lc_ErrorE0026_CODE;
		SET @As_DescriptionError_TEXT = 'Update not allowed for MCI 999995 - UNIDENTIFIED ABSENT PARENT';

		RETURN;
	END
--Bug13703-ADD-END
      
   SET @Lc_State_ADDR = UPPER (ISNULL(LTRIM(RTRIM(@Ac_State_ADDR)), ' '));
   SET @Lc_Country_ADDR = UPPER (ISNULL (LTRIM(RTRIM(@Ac_Country_ADDR)), 'US'));
   SET @Lc_Zip_ADDR = UPPER (ISNULL (LTRIM(RTRIM(@Ac_Zip_ADDR)), ' '));
   SET @Lc_City_ADDR = ISNULL (LTRIM(RTRIM(dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@Ac_City_ADDR, @Lc_RegCity_TEXT, ''))), @Lc_Space_TEXT);
   SET @Ls_Line1_ADDR = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@As_Line1_ADDR, @Lc_RegNotSpecialchar_TEXT, ''), @Lc_Space_TEXT);
   SET @Ls_Line2_ADDR = ISNULL (LTRIM(RTRIM (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@As_Line2_ADDR, @Lc_RegNotSpecialchar_TEXT, ''))), @Lc_Space_TEXT);

   IF @Lc_Country_ADDR = @Lc_Space_TEXT
    BEGIN
     SET @Lc_Country_ADDR ='US';
    END

   IF @Ad_End_DATE = '1900-01-01'
       OR @Ad_End_DATE = @Ld_Low_DATE
       OR @Ad_End_DATE = ''
    BEGIN
     SET @Ad_End_DATE = @Ld_High_DATE;
    END

   IF @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
    BEGIN
     /*
     Check whether the Incoming Address Line 1 is empty or not. If Address Line 1 is empty, return the error message 
     'E0606 - INVALID ADDRESS'. Otherwise, proceed to the next step.
     */
     IF ISNULL(LTRIM(RTRIM(@Ls_Line1_ADDR)), '') = ''
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0606_CODE;
       SET @As_DescriptionError_TEXT = 'INVALID ADDRESS';

       RETURN;
      END

     /*
     Check whether the Incoming Address City is empty or not. If the Address City is empty, return the error message 
     E0702 - INVALID CITY. Otherwise, proceed to the next step.
     */
     IF ISNULL(LTRIM(RTRIM(@Lc_City_ADDR)), '') = ''
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0702_CODE;
       SET @As_DescriptionError_TEXT = 'INVALID CITY';

       RETURN;
      END

     /*
     Check whether the Incoming Address State is empty or not. If the Address State is empty, return the error message 
     'E0542 - INVALID STATE'. Otherwise, proceed to the next step.
     */
     IF ISNULL(LTRIM(RTRIM(@Ac_State_ADDR)), '') = ''
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0542_CODE;
       SET @As_DescriptionError_TEXT = 'INVALID STATE';

       RETURN;
      END

     /*
     Check whether the Incoming Address Country is 'US' or not. If the Address Country is 'US', 
     check the Address State is a valid state in Reference REFM_Y1. table
     */
     IF @Lc_Country_ADDR = @Lc_CountryUs_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT VREFM1';

       SELECT @Ln_CountRecord_QNTY = COUNT (1)
         FROM REFM_Y1 AS r
        WHERE r.Table_ID = @Lc_TableStat_IDNO
          AND r.TableSub_ID = @Lc_TableSubStat_IDNO
          AND r.Value_CODE = @Lc_State_ADDR;

       IF @Ln_CountRecord_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0542_CODE;
         SET @As_DescriptionError_TEXT = 'INVALID STATE';

         RETURN;
        END
      END

     /*
     Check whether the Address Zip is empty or not. If the Address Zip is empty, return the error 
     message as 'E0520 - INVALID ZIP'. Otherwise, proceed to the next step.
     */
     IF ISNULL(LTRIM(RTRIM(@Ac_Zip_ADDR)), '') = ''
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0520_CODE;
       SET @As_DescriptionError_TEXT = 'INVALID ZIP';

       RETURN;
      END
    END

   -- To remove hyphen in the zip code when country is US 
   IF @Lc_Country_ADDR = @Lc_CountryUs_CODE
    BEGIN
     SET @Lc_Zip_ADDR = REPLACE(@Lc_Zip_ADDR, '-', '');
    END

   -- To add validation for Zip_ADDR
   IF @Lc_Country_ADDR = @Lc_CountryUs_CODE
      AND ((LEN (@Lc_Zip_ADDR) NOT IN (5, 9))
            OR (dbo.BATCH_COMMON$SF_ISVALIDNUMERIC (@Lc_Zip_ADDR) <> @Lc_Yes_INDC))
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0520_CODE;
     SET @As_DescriptionError_TEXT = 'INVALID ZIP';

     RETURN;
    END

   SET @Ld_End_DATE = ISNULL (LTRIM(RTRIM (CONVERT(VARCHAR(10), @Ad_End_DATE, 101))), @Ld_High_DATE);
   SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1 - DUPLICATE CHECK';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', AD_DT_RUN = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '');

   SELECT @Ln_CountRecord_QNTY = COUNT (1)
     FROM AHIS_Y1 a
    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
      AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
      AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
      AND a.End_DATE = @Ld_High_DATE
      AND (@An_TransactionEventSeq_NUMB = 0
            OR a.TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB)
      AND ISNULL (LTRIM(RTRIM(a.Line1_ADDR)), @Lc_Space_TEXT) = @Ls_Line1_ADDR
      AND ISNULL (LTRIM(RTRIM(a.Line2_ADDR)), @Lc_Space_TEXT) = @Ls_Line2_ADDR
      AND ISNULL (LTRIM(RTRIM(a.City_ADDR)), @Lc_Space_TEXT) = @Lc_City_ADDR
      AND ISNULL (LTRIM(RTRIM(a.State_ADDR)), @Lc_Space_TEXT) = @Lc_State_ADDR
      AND SUBSTRING (ISNULL (LTRIM(RTRIM (a.Zip_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Lc_Zip_ADDR, 1, 5)
      AND CASE
           WHEN ISNULL(LTRIM(RTRIM (a.Country_ADDR)), @Lc_Space_TEXT) = ''
            THEN @Lc_CountryUs_CODE
           ELSE ISNULL(LTRIM(RTRIM (a.Country_ADDR)), @Lc_Space_TEXT)
          END = @Lc_Country_ADDR;

   IF @Ln_CountRecord_QNTY > 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
     SET @As_DescriptionError_TEXT = 'NO CHANGE IN ADDRESS';

     -- Program return 'X' for batches if duplicate address is received
     IF @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE1089_CODE;
      END

     RETURN;
    END

   -- To check first 8 characters of address line1 for batch addresses
   SET @Ls_Sql_TEXT = ' SELECT AHIS_Y1 - DUPLICATE ACSES CHECK';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + +ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), 0) + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', AD_DT_RUN = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '');

   /*
   If member has an existing address in AHIS_Y1, match the first eight characters of the incoming Address Line 1 
   and the first five characters of the of the incoming Address Zip to the existing address first eight characters 
   of the Address Line 1 and the first five character of the Address Zip. If the match occurs, skip performing 
   any address update and return an error message of 'E0145 - DUPLICATE ADDRESS'. 
   If no match is found, proceed to the below step.
   */
   IF @Ac_SignedOnWorker_ID IN (@Lc_BatchRunUser_TEXT, @Lc_ProcessFacts_IDNO)
      AND @Ac_TypeAddress_CODE <> @Lc_TypeAddressCourtC_CODE
    BEGIN
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM AHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
        AND a.End_DATE = @Ld_High_DATE
        AND (@An_TransactionEventSeq_NUMB = 0
              OR a.TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB)
        AND (SUBSTRING (ISNULL (LTRIM(RTRIM (a.Line1_ADDR)), @Lc_Space_TEXT), 1, 8) = SUBSTRING (@Ls_Line1_ADDR, 1, 8)
              OR SUBSTRING (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (a.Line1_ADDR, @Lc_RegNotAlphanumeric_TEXT, ''), @Lc_Space_TEXT), 1, 8) = SUBSTRING (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@Ls_Line1_ADDR, @Lc_RegNotAlphanumeric_TEXT, ''), @Lc_Space_TEXT), 1, 8))
        -- To compare only first 8 characters-- of addr_line1 and first five characters of zip code.
        AND SUBSTRING (ISNULL (LTRIM(RTRIM(a.Zip_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Lc_Zip_ADDR, 1, 5);

     IF @Ln_CountRecord_QNTY > 0
      BEGIN
       -- Program returns X code for batches if duplicate address is received
       SET @Ac_Msg_CODE = @Lc_ErrorE1089_CODE;
       SET @As_DescriptionError_TEXT = 'NO CHANGE IN ADDRESS';

       IF @Ac_SignedOnWorker_ID = @Lc_ProcessFacts_IDNO
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
        END

       RETURN;
      END
    END

   -- All the FAMIS address records are validated for De-dup like interface
   IF @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
      AND @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
    BEGIN
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM AHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
        AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
        AND a.End_DATE = @Ld_High_DATE
        AND (@An_TransactionEventSeq_NUMB = 0
              OR a.TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB)
        AND (SUBSTRING (ISNULL (LTRIM(RTRIM (a.Line1_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Ls_Line1_ADDR, 1, 5)
              OR SUBSTRING (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (a.Line1_ADDR, @Lc_RegNotAlphanumeric_TEXT, ''), @Lc_Space_TEXT), 1, 5) = SUBSTRING (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@Ls_Line1_ADDR, @Lc_RegNotAlphanumeric_TEXT, ''), @Lc_Space_TEXT), 1, 5))
        -- Fixing the program as per CR130 to compare only first 5 characters-- of addr_line1 and first five characters of zip code.
        AND SUBSTRING (ISNULL (LTRIM(RTRIM(a.Zip_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Lc_Zip_ADDR, 1, 5)
        AND SUBSTRING (ISNULL (LTRIM(RTRIM(a.State_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Lc_State_ADDR, 1, 5)
        AND SUBSTRING (ISNULL (LTRIM(RTRIM(a.City_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Lc_City_ADDR, 1, 5);

     IF @Ln_CountRecord_QNTY > 0
      BEGIN
       -- Program returns X code for batches if duplicate address is received
       SET @Ac_Msg_CODE = @Lc_ErrorE1089_CODE;
       SET @As_DescriptionError_TEXT = 'NO CHANGE IN ADDRESS';

       RETURN;
      END
    END

   -- AHIS screen update validation
   IF @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
      AND @An_TransactionEventSeq_NUMB <> 0
    BEGIN
     -- This record is being added/updated by another user, please refresh screen
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM AHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
        AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     IF @Ln_CountRecord_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0153_CODE;
       SET @As_DescriptionError_TEXT = 'THIS RECORD IS BEING ADDED/UPDATED BY ANOTHER USER';

       RETURN;
      END

     SET @Lb_VerStatusGood_BIT = 0;

     -- Checking Confirmed good address exist with the given address type and transaction event sequence
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM AHIS_Y1 b
      WHERE b.MemberMci_IDNO = @An_MemberMci_IDNO
        AND b.TypeAddress_CODE = @Ac_TypeAddress_CODE
        AND b.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
        AND b.Status_CODE = @Lc_VerificationStatusGood_CODE;

     IF @Ln_CountRecord_QNTY >= 1
      BEGIN
       SET @Lb_VerStatusGood_BIT = 1;
      END
    END

   SET @Lc_Status_CODE = @Ac_Status_CODE;
   SET @Ls_Sql_TEXT = ' SELECT AHIS_Y1 - LAST ONE YEAR END DATE CHECK';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', AD_DT_RUN = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '');

   /*
   	If there is no non-end-dated existing address residing on the member's AHIS record, 
   	perform a match to all end-dated addresses that appear based on the first eight characters 
   	of Address Line 1 and the first five characters of Address Zip. Skip the address update if 
   	the address matches with an existing end-dated address that was end-dated within one year 
   	from the current date, and return error message 'E0997 - ADDRESS IS END DATED WITHIN ONE YEAR FROM CURRENT DATE'.
   */
   IF @Ac_SignedOnWorker_ID IN (@Lc_BatchRunUser_TEXT, @Lc_ProcessFacts_IDNO)
      AND @Ac_TypeAddress_CODE <> @Lc_TypeAddressCourtC_CODE --13105
    BEGIN
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM AHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND -- To check first 8 characters of Address Line 1
        (SUBSTRING (ISNULL (LTRIM(RTRIM(a.Line1_ADDR)), @Lc_Space_TEXT), 1, 8) = SUBSTRING (@Ls_Line1_ADDR, 1, 8)
          OR SUBSTRING (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (Line1_ADDR, @Lc_RegNotAlphanumeric_TEXT, ''), @Lc_Space_TEXT), 1, 8) = SUBSTRING (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@Ls_Line1_ADDR, @Lc_RegNotAlphanumeric_TEXT, ''), @Lc_Space_TEXT), 1, 8))
        -- To check five characters of Address Zip
        AND SUBSTRING (ISNULL (LTRIM(RTRIM(a.Zip_ADDR)), @Lc_Space_TEXT), 1, 5) = SUBSTRING (@Lc_Zip_ADDR, 1, 5)
        --To include records which are end dated today--AND ad_dt_run NOT BETWEEN dt_begin AND dt_end
        AND a.End_DATE BETWEEN DATEADD (m, -12, @Ad_Run_DATE) AND @Ad_Run_DATE
        AND a.End_DATE <> @Ld_High_DATE;

     IF @Ln_CountRecord_QNTY > 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0997_CODE;
       SET @As_DescriptionError_TEXT = 'ADDRESS IS END DATED WITHIN ONE YEAR FROM CURRENT DATE';

       RETURN;
      END
    END

   IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
      AND @Ld_End_DATE > @Ad_Run_DATE
    BEGIN
     SET @Ln_EventFunctionalSeq_NUMB = @Li_AddVerifiedAGoodAddress5290_NUMB;
    END
   ELSE IF @Ld_End_DATE <= @Ad_Run_DATE
    BEGIN
     SET @Ln_EventFunctionalSeq_NUMB = @Li_InvalidateMemberAddress5300_NUMB;
    END
   ELSE IF @An_TransactionEventSeq_NUMB <> 0
      AND @Ld_End_DATE > @Ad_Run_DATE
    BEGIN
     SET @Ln_EventFunctionalSeq_NUMB = @Li_ModifyAddress5280_NUMB;
    END
   ELSE
    BEGIN
     SET @Ln_EventFunctionalSeq_NUMB = @Li_AddAddress5270_NUMB;
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
    @Ac_Process_ID               = @Ac_Process_ID,
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ln_TransactionEventDemoSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

   -- AHIS screen update
   IF @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
      AND @An_TransactionEventSeq_NUMB <> 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT HAHIS_Y1 - 1';
     SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@An_TransactionEventSeq_NUMB AS VARCHAR), '');

     -- This record is being added/updated by another user, please refresh screen  
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM HAHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
        AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     IF @Ln_CountRecord_QNTY = 1
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0153_CODE;
       SET @As_DescriptionError_TEXT = 'THIS RECORD IS BEING ADDED/UPDATED BY ANOTHER USER';

       RETURN;
      END

     /* Move Current Address to History */
     INSERT HAHIS_Y1
            (MemberMci_IDNO,
             TypeAddress_CODE,
             Begin_DATE,
             End_DATE,
             Attn_ADDR,
             Line1_ADDR,
             Line2_ADDR,
             City_ADDR,
             State_ADDR,
             Zip_ADDR,
             Country_ADDR,
             SourceLoc_CODE,
             SourceReceived_DATE,
             Status_CODE,
             Status_DATE,
             SourceVerified_CODE,
             DescriptionComments_TEXT,
             DescriptionServiceDirection_TEXT,
             PlsLoad_DATE,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             Normalization_CODE)
     SELECT a.MemberMci_IDNO,
            a.TypeAddress_CODE,
            a.Begin_DATE,
            a.End_DATE,
            a.Attn_ADDR,
            a.Line1_ADDR,
            a.Line2_ADDR,
            a.City_ADDR,
            a.State_ADDR,
            a.Zip_ADDR,
            a.Country_ADDR,
            a.SourceLoc_CODE,
            a.SourceReceived_DATE,
            a.Status_CODE,
            a.Status_DATE,
            a.SourceVerified_CODE,
            a.DescriptionComments_TEXT,
            a.DescriptionServiceDirection_TEXT,
            a.PlsLoad_DATE,
            a.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            a.WorkerUpdate_ID,
            a.Update_DTTM,
            a.TransactionEventSeq_NUMB,
            a.Normalization_CODE
       FROM AHIS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
        AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
        AND NOT EXISTS(SELECT 1
                         FROM HAHIS_Y1 a WITH(READUNCOMMITTED)
                        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                          AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
                          AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB)

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT HAHIS_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     IF LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, ''))) <> 'Y'
      BEGIN
       SET @Ac_SourceVerified_CODE = '';
      END

     IF @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
        AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
        AND @Ac_Process_ID = 'CCRT'
      BEGIN
       SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
       SET @Ac_SourceVerified_CODE = 'T'; --13104
      END

     SET @Ls_Sql_TEXT = ' UPDATE HAHIS_Y1 - 1';
     SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@An_TransactionEventSeq_NUMB AS VARCHAR), '');

     /* Update Address  */
     UPDATE AHIS_Y1
        SET Begin_DATE = ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE),
            End_DATE = @Ld_End_DATE,
            Attn_ADDR = ISNULL (@Ac_Attn_ADDR, @Lc_Space_TEXT),
            --CR0398-Bug13551-CHANGE-BEGIN
            Line1_ADDR = UPPER(@Ls_Line1_ADDR),
            Line2_ADDR = UPPER(@Ls_Line2_ADDR),
            City_ADDR = UPPER(@Lc_City_ADDR),
            State_ADDR = UPPER(@Lc_State_ADDR),
            Zip_ADDR = UPPER(@Lc_Zip_ADDR),
            Country_ADDR = UPPER(@Lc_Country_ADDR),
            --CR0398-Bug13551-CHANGE-END
            SourceLoc_CODE = ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT),
            SourceReceived_DATE = ISNULL (@Ad_SourceReceived_DATE, @Ld_Low_DATE),
            Status_CODE = ISNULL (@Lc_Status_CODE, @Lc_Space_TEXT),
            Status_DATE = ISNULL (@Ad_Status_DATE, @Ad_Run_DATE),
            SourceVerified_CODE = ISNULL (@Ac_SourceVerified_CODE, @Lc_Space_TEXT),
            DescriptionComments_TEXT = ISNULL (@As_DescriptionComments_TEXT, @Lc_Space_TEXT),
            DescriptionServiceDirection_TEXT = ISNULL (@As_DescriptionServiceDirection_TEXT, @Lc_Space_TEXT),
            Normalization_CODE = CASE
                                  WHEN ISNULL(LTRIM(RTRIM(@Ac_Normalization_CODE)), '') = ''
                                   THEN @Lc_UnnormalizedU_TEXT
                                  ELSE LTRIM(RTRIM(@Ac_Normalization_CODE))
                                 END,
            BeginValidity_DATE = @Ad_Run_DATE,
            WorkerUpdate_ID = ISNULL (@Ac_SignedOnWorker_ID, @Lc_Space_TEXT),
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
      WHERE MemberMci_IDNO = @An_MemberMci_IDNO
        AND TypeAddress_CODE = @Ac_TypeAddress_CODE
        AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE AHIS_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     -- Change Start	
     -- TO check Confirmed Good address Exist for the member
     IF @Ac_TypeAddress_CODE <> @Lc_TypeAddressCourtC_CODE
      BEGIN
       SELECT @Ln_CountRecord_QNTY = COUNT (1)
         FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE;

       SELECT @Ln_IncomingTypeAddressCgCountRecord_QNTY = COUNT (1)
         FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
          AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE;
      END

     -- TO check Last Known Court Address Exist for the member
     SELECT @Ln_Court_QNTY = COUNT (1)
       FROM AHIS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
        AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
        AND a.End_DATE = @Ld_High_DATE;

     IF @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
        AND @Ac_Process_ID <> 'CCRT'
      BEGIN
       SET @Lc_Status_CODE = ISNULL (@Lc_Status_CODE, @Lc_Space_TEXT);
      END
     ELSE IF @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
        AND @Ac_Process_ID = 'CCRT'
      BEGIN
       -- CCRT Change Start
       -- To check address exist
       SELECT @Ln_CountRecordCcrt_QNTY = COUNT (1)
         FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE;

       -- To check pending address exist
       SELECT @Ln_CountRecordPending_QNTY = COUNT (1)
         FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.Status_CODE = @Lc_VerificationStatusPending_CODE
          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE;

       -- TO check Confirmed good mailing address
       SELECT @Ln_CcrtMailAddress_QNTY = COUNT (1)
         FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
          AND a.TypeAddress_CODE = @Lc_TypeAddressMailM_CODE
          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
          AND a.End_DATE = @Ld_High_DATE;

       -- TO check Confirmed good Residential address
       SELECT @Ln_CcrtResidentialAddress_QNTY = COUNT (1)
         FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
          AND a.TypeAddress_CODE = @Lc_TypeAddressMailR_CODE
          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
          AND a.End_DATE = @Ld_High_DATE;

       IF @Ac_CcrtCaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
        BEGIN
         IF @Ln_CountRecordCcrt_QNTY = 0 OR @Ln_IncomingTypeAddressCgCountRecord_QNTY = 0
          BEGIN
           -- First Address - Member is CP ,No Existing address in AHIS then add as Confirm Good Address with Address Type from CCRT
           SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
          END
         ELSE IF @Ln_CountRecord_QNTY = 0
            AND @Ln_CountRecordPending_QNTY > 0
          BEGIN
           -- First Good Address - Member is CP ,No Confirmed Good matching address type Address and has Pending Address of Type then add as Confirm Good Address with Address Type from CCRT
           SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
          END
         --ELSE IF @Ln_CountRecord_QNTY > 0 
         ELSE IF @Ln_IncomingTypeAddressCgCountRecord_QNTY > 0
          BEGIN
           -- Second Good Address - Member is CP,Has Confirmed Good address type Address Add as Verification Pending  with Address Type from CCRT
           SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
          END
        END
       ELSE IF @Ac_CcrtCaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
        BEGIN
         IF @Ac_CcrtMemberAddress_CODE = 'Y'
            AND @Ln_CountRecordCcrt_QNTY = 0
          BEGIN
           -- First Address (Current OR Last Known)  - Member is NCP ,No Existing address in AHIS then add as Confirm Good Address with Address Type from CCRT
           SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
          END

         IF @Ac_CcrtMemberAddress_CODE = 'N'
            AND @Ln_CountRecordCcrt_QNTY = 0
          BEGIN
           -- First Address (Current OR Last Known)  - Member is NCP ,No Existing address in AHIS then add as Confirm Good Address with Address Type from CCRT
           SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
          END
         ELSE IF @Ac_CcrtMemberAddress_CODE = 'Y'
            AND @Ac_TypeAddress_CODE = 'M'
            AND @Ln_CcrtMailAddress_QNTY = 0
            AND @Ln_CcrtResidentialAddress_QNTY > 0
          BEGIN
           -- First Good Address(Current, Mail)  - Member is NCP ,No Confirmed Good Mail address type Address,Confirmed Good Residential address type Address 
           -- then add as Pending Address with Mail Address Type from CCRT.
           SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
          END
         ELSE IF @Ac_CcrtMemberAddress_CODE = 'Y'
            AND @Ac_TypeAddress_CODE = 'R'
            AND @Ln_CcrtMailAddress_QNTY > 0
            AND @Ln_CcrtResidentialAddress_QNTY = 0
          BEGIN
           -- First Good Address(Current, Residential)  - Member is NCP ,Confirmed Good Mail address type Address,No confirmed Good Residential Address 
           -- then add as Pending Address with Mail Address Type from CCRT.
           SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
          END
         ELSE IF @Ac_CcrtMemberAddress_CODE = 'N'
            AND @Ln_CountRecord_QNTY = 0
            AND @Ln_CountRecordPending_QNTY > 0
          BEGIN
           -- First Good Address(Last Known)  - Member is NCP , No Confirmed Good Address of Type,Has Pending Address of Type
           -- then add as Pending Address with Mail Address Type from CCRT.
           SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
          END
         ELSE IF @Ac_CcrtMemberAddress_CODE IN ('N', 'Y')
            AND (@Ln_CcrtMailAddress_QNTY > 0
                  OR @Ln_CcrtResidentialAddress_QNTY > 0)
          BEGIN
           -- Second Good Address(Current,Last Known)  - Member is NCP , Has Confirmed Good matching address type Address
           -- then add a Verification pending  matching address type Address
           SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
          END
        END
      -- CCRT Change End
      END
     --If a confirmed good address exists,  addresses from all interfaces, (except NCOA addressed received in FCR batch) 
     --will be loaded to LPRO for the worker to manually add to AHIS
     ELSE IF (@Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
         AND (@Ln_CountRecord_QNTY = 0
               OR @Ln_IncomingTypeAddressCgCountRecord_QNTY = 0))
         -- If there is no last known court address, add this as a confirmed good address
         OR (@Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
             AND @Ln_Court_QNTY = 0) -- @Ac_SignedOnWorker_ID = FAMS 
      BEGIN
       -- If no confirmed good address exists, the address will be loaded to AHIS as confirmed good
       SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
      END
--13529 - CR0394 Update Member Address with FCR MSFIDM Account Holder Address -START-
     IF @Ac_SourceLoc_CODE NOT IN ('IRS', 'FID', 'FCR', 'NDH', 'FPL', 'MSF')
--13529 - CR0394 Update Member Address with FCR MSFIDM Account Holder Address -END-     
        AND ((@Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
              AND (@Ln_CountRecord_QNTY = 0
                    OR @Ln_IncomingTypeAddressCgCountRecord_QNTY = 0))
              OR (@Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
                  AND @An_TransactionEventSeq_NUMB = 0))
      BEGIN
       --If there is a last known court address, then end date that address and add the incoming address as a confirmed good address.
       IF @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
          AND @Ln_Court_QNTY = 1
        BEGIN
         SET @Ls_Sql_TEXT = ' INSERT HAHIS_Y1 - 2';
         SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@An_TransactionEventSeq_NUMB AS VARCHAR), '');

         /* Move Current Address to History For FAMIS*/
         INSERT HAHIS_Y1
                (MemberMci_IDNO,
                 TypeAddress_CODE,
                 Begin_DATE,
                 End_DATE,
                 Attn_ADDR,
                 Line1_ADDR,
                 Line2_ADDR,
                 City_ADDR,
                 State_ADDR,
                 Zip_ADDR,
                 Country_ADDR,
                 SourceLoc_CODE,
                 SourceReceived_DATE,
                 Status_CODE,
                 Status_DATE,
                 SourceVerified_CODE,
                 DescriptionComments_TEXT,
                 DescriptionServiceDirection_TEXT,
                 PlsLoad_DATE,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 WorkerUpdate_ID,
                 Update_DTTM,
                 TransactionEventSeq_NUMB,
                 Normalization_CODE)
         SELECT a.MemberMci_IDNO,
                a.TypeAddress_CODE,
                a.Begin_DATE,
                a.End_DATE,
                a.Attn_ADDR,
                a.Line1_ADDR,
                a.Line2_ADDR,
                a.City_ADDR,
                a.State_ADDR,
                a.Zip_ADDR,
                a.Country_ADDR,
                a.SourceLoc_CODE,
                a.SourceReceived_DATE,
                a.Status_CODE,
                a.Status_DATE,
                a.SourceVerified_CODE,
                a.DescriptionComments_TEXT,
                a.DescriptionServiceDirection_TEXT,
                a.PlsLoad_DATE,
                a.BeginValidity_DATE,
                @Ad_Run_DATE AS EndValidity_DATE,
                a.WorkerUpdate_ID,
                a.Update_DTTM,
                a.TransactionEventSeq_NUMB,
                a.Normalization_CODE
           FROM AHIS_Y1 AS a
          WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
            AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
            AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
            AND a.End_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT HAHIS_Y1 - 2 FAILED';

           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = ' UPDATE HAHIS_Y1 - 2';
         SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@An_TransactionEventSeq_NUMB AS VARCHAR), '');

         /* Update Address For FAMIS */
         UPDATE AHIS_Y1
            SET End_DATE = ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE),
                WorkerUpdate_ID = ISNULL (@Ac_SignedOnWorker_ID, @Lc_Space_TEXT), --Bug-13593
                Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
          WHERE MemberMci_IDNO = @An_MemberMci_IDNO
            AND TypeAddress_CODE = @Ac_TypeAddress_CODE
            AND @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
            AND End_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'UPDATE AHIS_Y1 FOR FAMIS FAILED';

           RAISERROR (50001,16,1);
          END

         IF @Ac_SourceLoc_CODE = 'NCA'
            AND (UPPER(LTRIM(RTRIM(ISNULL(@Ac_Status_CODE, '')))) = 'Y'
                 AND UPPER(LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, '')))) = 'Y')
          BEGIN
           --SET @Ac_Status_CODE = @Lc_VerificationStatusGood_CODE;
           SET @Ac_SourceVerified_CODE = 'O';
          END

         IF LTRIM(RTRIM(ISNULL(@Ac_Status_CODE, ''))) <> 'Y'
            AND LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, ''))) <> 'Y'
          BEGIN
           SET @Ac_SourceVerified_CODE = '';
          END

         IF @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
            AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
            AND @Ac_Process_ID = 'CCRT'
          BEGIN
           SELECT @Ac_Status_CODE = @Lc_VerificationStatusGood_CODE,
                  @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;

           SET @Ac_SourceVerified_CODE = 'T'; --13104
          END

         SET @Ls_Sql_TEXT = ' INSERT AHIS_Y1 FAMIS';
         SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', LC_CD_STATUS = ' + ISNULL (@Lc_Status_CODE, '');

         INSERT AHIS_Y1
                (MemberMci_IDNO,
                 TypeAddress_CODE,
                 Begin_DATE,
                 End_DATE,
                 Attn_ADDR,
                 Line1_ADDR,
                 Line2_ADDR,
                 City_ADDR,
                 State_ADDR,
                 Zip_ADDR,
                 Country_ADDR,
                 SourceLoc_CODE,
                 SourceReceived_DATE,
                 Status_CODE,
                 Status_DATE,
                 SourceVerified_CODE,
                 DescriptionComments_TEXT,
                 DescriptionServiceDirection_TEXT,
                 PlsLoad_DATE,
                 BeginValidity_DATE,
                 WorkerUpdate_ID,
                 Update_DTTM,
                 TransactionEventSeq_NUMB,
                 Normalization_CODE)
         VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
                  @Ac_TypeAddress_CODE,--TypeAddress_CODE
                  ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE),--Begin_DATE
                  @Ld_End_DATE,--End_DATE
                  ISNULL (@Ac_Attn_ADDR, @Lc_Space_TEXT),--Attn_ADDR
                  --CR0398-Bug13551-CHANGE-BEGIN
                  UPPER(@Ls_Line1_ADDR),--Line1_ADDR 
                  UPPER(@Ls_Line2_ADDR),--Line2_ADDR
                  UPPER(@Lc_City_ADDR),--City_ADDR
                  UPPER(@Lc_State_ADDR),--State_ADDR
                  UPPER(@Lc_Zip_ADDR),--Zip_ADDR
                  UPPER(@Lc_Country_ADDR),--Country_ADDR
                  --CR0398-Bug13551-CHANGE-END
                  ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                  ISNULL (@Ad_SourceReceived_DATE, @Ad_Run_DATE),--SourceReceived_DATE
                  ISNULL (@Ac_Status_CODE, @Lc_Status_CODE),--Status_CODE
                  @Ad_Run_DATE,--Status_DATE
                  ISNULL (@Ac_SourceVerified_CODE, @Lc_Space_TEXT),--SourceVerified_CODE
                  ISNULL (@As_DescriptionComments_TEXT, @Lc_Space_TEXT),--DescriptionComments_TEXT
                  ISNULL (@As_DescriptionServiceDirection_TEXT, @Lc_Space_TEXT),--DescriptionServiceDirection_TEXT
                  @Ld_High_DATE,--PlsLoad_DATE
                  @Ad_Run_DATE,--BeginValidity_DATE
                  ISNULL (@Ac_SignedOnWorker_ID, @Lc_Space_TEXT),--WorkerUpdate_ID --Bug-13593
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  CASE
                   WHEN ISNULL(LTRIM(RTRIM(@Ac_Normalization_CODE)), '') = ''
                    THEN @Lc_UnnormalizedU_TEXT
                   ELSE LTRIM(RTRIM(@Ac_Normalization_CODE))
                  END ); --Normalization_CODE
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT AHIS_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END
       ELSE
        BEGIN
         --Bug-13593
         --IF @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
         --   AND @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
         --   AND @Ln_Court_QNTY = 0
         -- BEGIN
         --  SET @Ac_SignedOnWorker_ID = @Lc_FamisRunUser_TEXT;
         -- END

         IF @Ac_SourceLoc_CODE = 'NCA'
            AND UPPER(LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, '')))) = 'Y'
          BEGIN
           --SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
           SET @Ac_SourceVerified_CODE = 'O';
          END

         IF LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, ''))) <> 'Y'
          BEGIN
           SET @Ac_SourceVerified_CODE = '';
          END

         IF @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
            AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
            AND @Ac_Process_ID = 'CCRT'
          BEGIN
           SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
           SET @Ac_SourceVerified_CODE = 'T'; --13104
          END

         SET @Ls_Sql_TEXT = ' INSERT AHIS_Y1 ';
         SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL (@Ac_TypeAddress_CODE, '') + ', LC_CD_STATUS = ' + ISNULL (@Lc_Status_CODE, '');

         INSERT AHIS_Y1
                (MemberMci_IDNO,
                 TypeAddress_CODE,
                 Begin_DATE,
                 End_DATE,
                 Attn_ADDR,
                 Line1_ADDR,
                 Line2_ADDR,
                 City_ADDR,
                 State_ADDR,
                 Zip_ADDR,
                 Country_ADDR,
                 SourceLoc_CODE,
                 SourceReceived_DATE,
                 Status_CODE,
                 Status_DATE,
                 SourceVerified_CODE,
                 DescriptionComments_TEXT,
                 DescriptionServiceDirection_TEXT,
                 PlsLoad_DATE,
                 BeginValidity_DATE,
                 WorkerUpdate_ID,
                 Update_DTTM,
                 TransactionEventSeq_NUMB,
                 Normalization_CODE)
         VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
                  @Ac_TypeAddress_CODE,--TypeAddress_CODE
                  ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE),--Begin_DATE
                  @Ld_End_DATE,--End_DATE
                  ISNULL (@Ac_Attn_ADDR, @Lc_Space_TEXT),--Attn_ADDR
                  --CR0398-Bug13551-CHANGE-BEGIN
                  UPPER(@Ls_Line1_ADDR),--Line1_ADDR
                  UPPER(@Ls_Line2_ADDR),--Line2_ADDR
                  UPPER(@Lc_City_ADDR),--City_ADDR
                  UPPER(@Lc_State_ADDR),--State_ADDR
                  UPPER(@Lc_Zip_ADDR),--Zip_ADDR
                  UPPER(@Lc_Country_ADDR),--Country_ADDR
                  --CR0398-Bug13551-CHANGE-END
                  ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                  ISNULL (@Ad_SourceReceived_DATE, @Ad_Run_DATE),--SourceReceived_DATE
                  ISNULL (@Lc_Status_CODE, @Lc_Space_TEXT),--Status_CODE
                  @Ad_Run_DATE,--Status_DATE
                  ISNULL (@Ac_SourceVerified_CODE, @Lc_Space_TEXT),--SourceVerified_CODE
                  ISNULL (@As_DescriptionComments_TEXT, @Lc_Space_TEXT),--DescriptionComments_TEXT
                  ISNULL (@As_DescriptionServiceDirection_TEXT, @Lc_Space_TEXT),--DescriptionServiceDirection_TEXT
                  @Ld_High_DATE,--PlsLoad_DATE
                  @Ad_Run_DATE,--BeginValidity_DATE
                  ISNULL (@Ac_SignedOnWorker_ID, @Lc_Space_TEXT),--WorkerUpdate_ID
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  CASE
                   WHEN ISNULL(LTRIM(RTRIM(@Ac_Normalization_CODE)), '') = ''
                    THEN @Lc_UnnormalizedU_TEXT
                   ELSE LTRIM(RTRIM(@Ac_Normalization_CODE))
                  END); --Normalization_CODE
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT AHIS_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END
      END
     ELSE
      BEGIN
       -- If a confirmed good address exists,  addresses from all interfaces, (except NCOA addressed received in FCR batch) 
       -- will be loaded to LPRO for the worker to manually add to AHIS.
       /*
       	The Status will be set to Confirmed Good if the member does not have any Confirmed Good mailing address or 
       	residential address, unless the source is from IRS, FIDM, FCR, MSF or NDNH.   If the Source is from IRS, FIDM, FCR, MSF or NDNH, 
       	the Status will be set to Pending Verification.
       */
       SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;

       IF @Ac_SourceLoc_CODE IN ('IRS', 'FID')
        BEGIN
         SET @Lc_Status_CODE = ISNULL (@Ac_Status_CODE, @Lc_Space_TEXT);
        END
--13529 - CR0394 Update Member Address with FCR MSFIDM Account Holder Address -START-        
       ELSE IF @Ac_SourceLoc_CODE IN ('FCR', 'NDH', 'FPL', 'MSF')
--13529 - CR0394 Update Member Address with FCR MSFIDM Account Holder Address -END-       
        BEGIN
         SET @Lc_Status_CODE = @Lc_VerificationStatusPending_CODE;
         SET @Ac_SourceVerified_CODE = '';
        END
       ELSE IF @Ac_SourceLoc_CODE = 'NCA'
          AND UPPER(LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, '')))) = 'Y'
        BEGIN
         --SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
         SET @Ac_SourceVerified_CODE = 'O';
        END
       ELSE
        BEGIN
         SET @Lc_Status_CODE = ISNULL (@Lc_Status_CODE, @Lc_Space_TEXT);
        END

       IF LTRIM(RTRIM(ISNULL(@Lc_Status_CODE, ''))) <> 'Y'
        BEGIN
         SET @Ac_SourceVerified_CODE = '';
        END

       IF @Ac_TypeAddress_CODE = @Lc_TypeAddressCourtC_CODE
          AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
          AND @Ac_Process_ID = 'CCRT'
        BEGIN
         SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
         SET @Ac_SourceVerified_CODE = 'T'; --13104
        END

       INSERT AHIS_Y1
              (MemberMci_IDNO,
               TypeAddress_CODE,
               Begin_DATE,
               End_DATE,
               Attn_ADDR,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               Country_ADDR,
               SourceLoc_CODE,
               SourceReceived_DATE,
               Status_CODE,
               Status_DATE,
               SourceVerified_CODE,
               DescriptionComments_TEXT,
               DescriptionServiceDirection_TEXT,
               PlsLoad_DATE,
               BeginValidity_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               TransactionEventSeq_NUMB,
               Normalization_CODE)
       VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
                @Ac_TypeAddress_CODE,--TypeAddress_CODE
                ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE),--Begin_DATE
                @Ld_End_DATE,--End_DATE
                ISNULL (@Ac_Attn_ADDR, @Lc_Space_TEXT),--Attn_ADDR
                --CR0398-Bug13551-CHANGE-BEGIN
                UPPER(@Ls_Line1_ADDR),--Line1_ADDR
                UPPER(@Ls_Line2_ADDR),--Line2_ADDR
                UPPER(@Lc_City_ADDR),--City_ADDR
                UPPER(@Lc_State_ADDR),--State_ADDR
                UPPER(@Lc_Zip_ADDR),--Zip_ADDR
                UPPER(@Lc_Country_ADDR),--Country_ADDR
                --CR0398-Bug13551-CHANGE-END
                ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                ISNULL (@Ad_SourceReceived_DATE, @Ad_Run_DATE),--SourceReceived_DATE
                ISNULL (@Lc_Status_CODE, @Lc_Space_TEXT),--Status_CODE
                @Ad_Run_DATE,--Status_DATE
                ISNULL (@Ac_SourceVerified_CODE, @Lc_Space_TEXT),--SourceVerified_CODE
                ISNULL (@As_DescriptionComments_TEXT, @Lc_Space_TEXT),--DescriptionComments_TEXT
                ISNULL (@As_DescriptionServiceDirection_TEXT, @Lc_Space_TEXT),--DescriptionServiceDirection_TEXT
                @Ld_High_DATE,--PlsLoad_DATE
                @Ad_Run_DATE,--BeginValidity_DATE
                ISNULL (@Ac_SignedOnWorker_ID, @Lc_Space_TEXT),--WorkerUpdate_ID
                dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                CASE
                 WHEN ISNULL(LTRIM(RTRIM(@Ac_Normalization_CODE)), '') = ''
                  THEN @Lc_UnnormalizedU_TEXT
                 ELSE LTRIM(RTRIM(@Ac_Normalization_CODE))
                END); --Normalization_CODE
       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT LPAD_Y1 FAILED';

         RAISERROR (50001,16,1);
        END
      END
    -- Change End	
    END

   /*
     When the verification status of a member address is set to Confirmed as Good and the member has at least one
     open case, DACSES automatically sets the value of the Locate Status field recorded at the member level and
     displayed in the header on member-based screens to 'Located'.
     
     When the member address is confirmed as good:
   And the member in 'Unlocated' Status in Locate status LSTT_Y1,  end date the 'Unlocated'
   Status entry record  and create at 'Located' Status entry record in LSTT_Y1.
   */
   IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
      AND @Ld_End_DATE > @Ad_Run_DATE
      --13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -START-
      AND UPPER(LTRIM(RTRIM(ISNULL(@Ac_TypeAddress_CODE, '')))) <> @Lc_TypeAddressCourtC_CODE
      --13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -END-
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = N';

     BEGIN
      -- LSTT_Y1 Not Located record exists checking
      SELECT @Ln_TransactionEventLsttSeq_NUMB = l.TransactionEventSeq_NUMB
        FROM LSTT_Y1 l
       WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
         AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
         AND l.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ln_CountRecord_QNTY = 0;
       END
      ELSE
       BEGIN
        SET @Ln_CountRecord_QNTY = 1;
       END
     END

     IF @Ln_CountRecord_QNTY > 0
      BEGIN
       -- If NOT LOCATED record is exist in LSTT_Y1 then, change it to LOCATED.
       SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = N';

       UPDATE LSTT_Y1
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE MemberMci_IDNO = @An_MemberMci_IDNO
          AND StatusLocate_CODE = @Lc_StatusLocateN_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LSTT_Y1 FAILED';

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'INSERT LSTT_Y1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = L';

       INSERT LSTT_Y1
              (MemberMci_IDNO,
               StatusLocate_CODE,
               BeginLocate_DATE,
               Address_INDC,
               Employer_INDC,
               Ssn_INDC,
               License_INDC,
               StatusLocate_DATE,
               Asset_INDC,
               SourceLoc_CODE,
               BeginLocAddr_DATE,
               BeginLocEmpr_DATE,
               BeginLocSsn_DATE,
               BeginLocDateOfBirth_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               BeginValidity_DATE,
               EndValidity_DATE,
               TransactionEventSeq_NUMB,
               ReferLocate_INDC)
       SELECT l.MemberMci_IDNO,
              @Lc_StatusLocateL_CODE AS StatusLocate_CODE,
              l.BeginLocate_DATE,
              l.Address_INDC,
              l.Employer_INDC,
              l.Ssn_INDC,
              l.License_INDC,
              @Ad_Run_DATE AS StatusLocate_DATE,
              l.Asset_INDC,
              ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT) AS SourceLoc_CODE,
              @Ad_Run_DATE AS BeginLocate_DATE,
              l.BeginLocEmpr_DATE,
              l.BeginLocSsn_DATE,
              l.BeginLocDateOfBirth_DATE,
              @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
              @Ad_Run_DATE AS BeginValidity_DATE,
              @Ld_High_DATE AS EndValidity_DATE,
              @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
              l.ReferLocate_INDC
         FROM LSTT_Y1 AS l
        WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
          AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
          AND l.TransactionEventSeq_NUMB = @Ln_TransactionEventLsttSeq_NUMB
          AND l.EndValidity_DATE = @Ad_Run_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT LSTT_Y1 FAILED';

         RAISERROR (50001,16,1);
        END
      END
     ELSE -- Insert LOCATED address in LSTT_Y1 table
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 - 2';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = N';

       -- LSTT_Y1 Located record exists checking
       SELECT @Ln_CountRecord_QNTY = COUNT (1)
         FROM LSTT_Y1 l
        WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
          AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
          AND --  LOCATED
          l.EndValidity_DATE = @Ld_High_DATE;

       IF @Ln_CountRecord_QNTY = 0
        BEGIN
         -- If LOCATED record is not exist in LSTT_Y1 then, insert new record with LOCATED.
         SET @Ls_Sql_TEXT = 'INSERT LSTT_Y1';
         SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = L';

         INSERT LSTT_Y1
                (MemberMci_IDNO,
                 StatusLocate_CODE,
                 BeginLocate_DATE,
                 Address_INDC,
                 Employer_INDC,
                 Ssn_INDC,
                 License_INDC,
                 StatusLocate_DATE,
                 Asset_INDC,
                 SourceLoc_CODE,
                 BeginLocAddr_DATE,
                 BeginLocEmpr_DATE,
                 BeginLocSsn_DATE,
                 BeginLocDateOfBirth_DATE,
                 WorkerUpdate_ID,
                 Update_DTTM,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 TransactionEventSeq_NUMB,
                 ReferLocate_INDC)
         VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
                  @Lc_StatusLocateL_CODE,--StatusLocate_CODE
                  @Ad_Run_DATE,--BeginLocate_DATE
                  @Lc_No_INDC,--Address_INDC
                  @Lc_No_INDC,--Employer_INDC
                  @Lc_No_INDC,--Ssn_INDC
                  @Lc_Space_TEXT,--License_INDC
                  @Ad_Run_DATE,--StatusLocate_DATE
                  @Lc_Space_TEXT,--Asset_INDC
                  ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                  @Ad_Run_DATE,--BeginLocAddr_DATE
                  @Ld_Low_DATE,--BeginLocEmpr_DATE
                  @Ld_Low_DATE,--BeginLocSsn_DATE
                  @Ld_Low_DATE,--BeginLocDateOfBirth_DATE
                  @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ad_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  @Lc_No_INDC); --ReferLocate_INDC
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT LSTT_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END
      END
    END

   SET @Ln_TopicIn_IDNO = 0;
   SET @Ln_Topic_NUMB = 0;
   SET @Lb_Cs563Generated_BIT = 0;
   SET @Ls_Sql_TEXT = 'OPEN MemberCur';

   OPEN MemberCur;

   SET @Ls_Sql_TEXT = 'FETCH MemberCur - 1';

   FETCH NEXT FROM MemberCur INTO @Ln_MemberCur_Case_IDNO, @Ln_MemberCur_MemberMci_IDNO, @Lc_MemberCur_CaseRelationship_CODE, @Lc_MemberCur_RespondInit_CODE, @Ln_MemberCur_OfficeOrder_NUMB;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    WHILE @Ln_FetchStatus_QNTY = 0
     BEGIN
      IF @Lc_Country_ADDR = @Lc_CountryUs_CODE
       BEGIN
        /* CSM-04 --- Letter sent to CP when IV-A referral contains different mailing address than DCSE has on record. */
        IF (@Lc_Status_CODE = @Lc_VerStatusPending_ADDR
            AND @Lc_MemberCur_CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
            AND @Ac_SourceVerified_CODE = @Lc_CaseRelationshipCp_CODE
            AND @Ac_SourceLoc_CODE = 'IVA')
         BEGIN
          SET @Lc_Notice_ID = @Lc_NoticeCsm04_IDNO;
          SET @Ln_TopicIn_IDNO = 0;
          SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorGpmla_CODE;

          -- While adding pending address for CP (Member should not be a NCP for any other case(s)), AHIS screen is showing NO MATCHING RECORDS FOUND error message
          -- If the worker manually updated the address on AHIS, the system should use the login office of the worker to generate the Notice with the appropriate return addresses.
          IF @Ac_SignedOnWorker_ID NOT IN (@Lc_BatchRunUser_TEXT, 'FACTS')
           BEGIN
            SET @Ls_XmlTextIn_TEXT = '<INPUT_PARAMETERS><CD_OFFICE_SIGNED>' + ISNULL (CAST(@An_OfficeSignedOn_IDNO AS VARCHAR), '') + '</CD_OFFICE_SIGNED></INPUT_PARAMETERS>';
           END
          ELSE
           BEGIN
            SET @Ls_XmlTextIn_TEXT = @Lc_Space_TEXT;
           END

          SET @Ln_Csm04NcpMemberMci_IDNO = ISNULL((SELECT TOP 1 c.MemberMci_IDNO
                                                     FROM CMEM_Y1 c
                                                    WHERE c.Case_IDNO = @Ln_MemberCur_Case_IDNO
                                                      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                      AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                                      AND EXISTS(SELECT 1
                                                                   FROM CMEM_Y1 cm
                                                                  WHERE cm.Case_IDNO = c.Case_IDNO
                                                                    AND cm.CaseRelationship_CODE = 'D'
                                                                    AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)), 0);

          IF @Ln_Csm04NcpMemberMci_IDNO != 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY1';
            SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_Csm04NcpMemberMci_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL (@Lc_Notice_ID, '') + ', ActivityMajor_CODE = ' + ISNULL (@Lc_Majoractivitycase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL (@Lc_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + @Lc_SubsystemLoc_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + '' + ', SignedOnWorker_ID = ' + @Ac_SignedOnWorker_ID + ', Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + @Lc_Notice_ID + ', @An_TopicIn_IDNO = ' + ISNULL (CAST (@Ln_Topic_NUMB AS VARCHAR), '') + ', Xml_TEXT = ' + @Ls_XmlTextIn_TEXT;

            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
             @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_Csm04NcpMemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
             @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = '',
             @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
             @Ad_Run_DATE                 = @Ad_Run_DATE,
             @Ac_Notice_ID                = @Lc_Notice_ID,
             @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
             @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
             @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_ErrorDesc_TEXT OUTPUT;

            IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
             BEGIN
              SET @Ac_Msg_CODE = @Lc_Msg_CODE;
              SET @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT;

              RETURN;
             END

            SET @Ln_TopicIn_IDNO = @Ln_Topic_NUMB;
           END
         END
       END

      /*
       When an NCP address is added or updated and the address source is other than Interstate or CSENet,
       and the case is marked Interstate Initiating or Responding, the trigger to automatically generate a
       CSENet transmittal to the other state's IV-D agency is "MSC P LSADR and the IV-D Case ID."
       */
      IF @Lc_MemberCur_CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND @Ac_SourceLoc_CODE <> @Lc_SourceLocOsa_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1,CASE_Y1';
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

        -- Added condition to check the case is initiating or responding
        IF @Lc_MemberCur_RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitResponding_CODE)
         BEGIN
          IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
             AND @Ld_End_DATE = @Ld_High_DATE
           BEGIN
            IF @Lc_State_ADDR = @Lc_StateInState_CODE
             BEGIN
              SET @Lc_Reason_CODE = @Lc_ReasonLsadr_CODE;
             -- Added condition to check the case is initiating
             END
            ELSE IF @Lc_MemberCur_RespondInit_CODE = @Lc_RespondInitInitiate_CODE
             BEGIN
              SET @Lc_Reason_CODE = @Lc_ReasonLsout_CODE;
             -- Added condition to check the case is responding
             END
            ELSE
             BEGIN
              SET @Lc_Reason_CODE = @Lc_ReasonLsout_CODE;
              -- Added restriction to generate the alert if AHIS/EHIS do not have
              -- NCP confirmed good address
              SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1,EHIS_Y1';
              SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

              SELECT @Ln_CountRecord_QNTY = SUM (fci.Count_NUMB)
                FROM (SELECT COUNT (1) AS Count_NUMB
                        FROM AHIS_Y1 a
                       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                         AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
                         AND @Ad_Run_DATE >= a.Begin_DATE
                         AND @Ad_Run_DATE < a.End_DATE
                         AND a.State_ADDR = @Lc_StateInState_CODE
                         AND a.SourceLoc_CODE <> @Lc_SourceLocOsa_CODE
                      UNION
                      SELECT COUNT (1) AS Count_NUMB
                        FROM EHIS_Y1 e
                       WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                         AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
                         AND @Ad_Run_DATE >= e.BeginEmployment_DATE
                         AND @Ad_Run_DATE < e.EndEmployment_DATE
                         AND --LSOUT alert should only generate if
                         --AHIS has confirmed good out-of-state address and no confirmed AHIS record
                         --(mailing, residential and secondary address ),  AND there is No confirmed EHIS in any state.
                         EXISTS (SELECT 1
                                   FROM OTHP_Y1 o
                                  WHERE e.OthpPartyEmpl_IDNO = o.OtherParty_IDNO
                                    AND o.TypeOthp_CODE = @Lc_TypeOthpE_IDNO
                                    AND o.EndValidity_DATE = @Ld_High_DATE)) AS fci;

              IF @Ln_CountRecord_QNTY = 0
               BEGIN
                -- To generate worker alert for Confirmed good Interstate Address.
                /*
                An DACSES batch program triggers alert to the Worker - Out of State address
                record associated with an NCP if the verification status stored on AHIS
                is set to Verified Good and the member has at least one open case.
                */
                SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorLsout_CODE;
                SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY9';
                SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', LS_CD_ACTIVITY_MINOR = ' + ISNULL (@Lc_ActivityMinor_CODE, '') + ', LN_SEQ_TXN_EVENT = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

                EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
                 @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
                 @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
                 @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
                 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
                 @Ac_Subsystem_CODE           = @Lc_SubsystemIn_CODE,
                 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 @Ac_WorkerUpdate_ID          = '',
                 @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
                 @Ad_Run_DATE                 = @Ad_Run_DATE,
                 @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
                 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                 @As_DescriptionError_TEXT    = @Ls_ErrorDesc_TEXT OUTPUT;

                IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                 BEGIN
                  SET @Ac_Msg_CODE = @Lc_Msg_CODE;
                  SET @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT;

                  RETURN;
                 END
               END
             END

			--13708 - Do not attempt to create the CSENet trigger if there is no ICAS record -START-
			IF EXISTS(SELECT 1
				 FROM ICAS_Y1 i
				WHERE i.Case_IDNO = @Ln_MemberCur_Case_IDNO
				  AND i.RespondentMci_IDNO = @An_MemberMci_IDNO
				  AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
				  AND i.EndValidity_DATE = @Ld_High_DATE)
			BEGIN
			--13708 - Do not attempt to create the CSENet trigger if there is no ICAS record -END-	  
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
            SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '');
            SET @Ld_Temp_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

            EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
             @Ad_Generated_DATE               = @Ad_Run_DATE,
             @An_Case_IDNO                    = @Ln_MemberCur_Case_IDNO,
             @An_RespondentMci_IDNO           = @An_MemberMci_IDNO,
             @Ac_IVDOutOfStateFips_CODE       = @Lc_Space_TEXT,
             @Ac_IVDOutOfStateCountyFips_CODE = @Lc_Space_TEXT,
             @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
             @Ac_IVDOutOfStateCase_ID         = @Lc_Space_TEXT,
             @Ac_Form_ID                      = 0,
             @As_FormWeb_URL                  = @Lc_Space_TEXT,
             @An_TransHeader_IDNO             = 0,
             @Ac_Function_CODE                = @Lc_FunctionMsc_CODE,
             @Ac_Action_CODE                  = @Lc_ActionP_CODE,
             @Ac_Reason_CODE                  = @Lc_Reason_CODE,
             @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
             @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
             @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
             @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
             @Ad_Hearing_DATE                 = @Ld_Low_DATE,
             @Ad_Dismissal_DATE               = @Ld_Low_DATE,
             @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
             @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
             @Ac_Attachment_INDC              = @Lc_No_INDC,
             @Ac_SignedonWorker_ID            = @Ac_SignedOnWorker_ID,
             @Ad_Update_DTTM                  = @Ld_Temp_DATE,
             @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
             @Ac_File_ID                      = @Lc_Space_TEXT,
             @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
             @An_TotalArrearsOwed_AMNT        = 0,
             @An_TotalInterestOwed_AMNT       = 0,
             @Ac_Process_ID                   = @Ac_Process_ID,
             @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT        = @Ls_ErrorMessage_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR (50001,16,1);
             END
            ELSE
             BEGIN
              IF @Lc_Msg_CODE = @Lc_MsgW0156_CODE
               BEGIN
                SET @Lc_MsgK_CODE = @Lc_MsgW0156_CODE;
               END
             END
			--13708 - Do not attempt to create the CSENet trigger if there is no ICAS record -START-
			END
			--13708 - Do not attempt to create the CSENet trigger if there is no ICAS record -END-
           END
         END
        ELSE
         BEGIN
          -- To generate action alert SAOUT - 'Instate Case - NCP confirmed out of state' to the worker
          -- if case is N - Instate Case, AND NCP has verified AHIS in another state AND no verified EHIS.
          -- (either in DE or in another state) ;AND No voluntary payments in 2 MSO.
          IF @Lc_MemberCur_RespondInit_CODE = @Lc_RespondInitNonInterstate_TEXT
           BEGIN
            -- Additional condition added to turn off the action alert SAOUT- End
            IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
               AND @Ld_End_DATE = @Ld_High_DATE
             BEGIN
              IF @Lc_State_ADDR <> @Lc_StateInState_CODE
               BEGIN
                -- Minor Activity SAOUT - Instate Case - NCP Confirmed Out of State action alert
                SET @Lb_GenerateSaout_BIT = 0;
                -- Added restriction to generate the alert if NCP do not have
                -- confirmed good employemnt in EHIS
                SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1,EHIS_Y1';
                SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

                SELECT @Ln_CountRecord_QNTY = SUM (fci.Count_NUMB)
                  FROM (SELECT COUNT (1) AS Count_NUMB
                          FROM AHIS_Y1 a
                         WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
                           AND @Ad_Run_DATE >= a.Begin_DATE
                           AND @Ad_Run_DATE < a.End_DATE
                           AND a.State_ADDR = @Lc_StateInState_CODE
                           AND a.SourceLoc_CODE <> @Lc_SourceLocOsa_CODE
                        UNION
                        SELECT COUNT (1) AS Count_NUMB
                          FROM EHIS_Y1 e
                         WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
                           AND @Ad_Run_DATE >= e.BeginEmployment_DATE
                           AND @Ad_Run_DATE < e.EndEmployment_DATE) AS fci;

                IF @Ln_CountRecord_QNTY = 0
                 BEGIN
                  SET @Lb_GenerateSaout_BIT = 0;
                  --Check for open SORD
                  SET @Ls_Sql_TEXT = 'SELECT SORD_Y1';

                  SELECT @Ln_CountRecord_QNTY = COUNT (1)
                    FROM SORD_Y1 a
                   WHERE a.Case_IDNO = @Ln_MemberCur_Case_IDNO
                     AND @Ad_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                     AND a.EndValidity_DATE = @Ld_High_DATE;

                  IF @Ln_CountRecord_QNTY > 0
                   BEGIN
                    --Check for the Payments in last 45 days
                    SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1';

                    SELECT @Ln_CountRecord_QNTY = COUNT (1)
                      FROM RCTH_Y1 r
                     WHERE r.PayorMCI_IDNO = @An_MemberMci_IDNO
                       AND r.Receipt_DATE >= DATEADD (D, -45, @Ad_Run_DATE)
                       AND r.EndValidity_DATE = @Ld_High_DATE
                       AND NOT EXISTS (SELECT 1
                                         FROM RCTH_Y1 c
                                        WHERE r.Batch_DATE = c.Batch_DATE
                                          AND r.SourceBatch_CODE = c.SourceBatch_CODE
                                          AND r.Batch_NUMB = c.Batch_NUMB
                                          AND r.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                          AND c.BackOut_INDC = @Lc_Yes_INDC
                                          AND c.EndValidity_DATE = @Ld_High_DATE);

                    IF @Ln_CountRecord_QNTY = 0
                     BEGIN
                      SET @Ls_Sql_TEXT = 'BATCH_COMMON$FN_GET_ARREARS';
                      --Get Arrears
                      SET @Ln_Arrears_AMNT = dbo.BATCH_COMMON$SF_GET_ARREARS (@Ln_MemberCur_Case_IDNO, CONVERT(VARCHAR(6), @Ad_Run_DATE, 112));
                      --Check for Current support
                      SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1';

                      SELECT @Ln_CountRecord_QNTY = COUNT (1)
                        FROM OBLE_Y1 b
                       WHERE b.Case_IDNO = @Ln_MemberCur_Case_IDNO
                         AND b.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                         AND b.Periodic_AMNT > 0
                         AND @Ad_Run_DATE BETWEEN b.BeginObligation_DATE AND b.EndObligation_DATE
                         AND b.EndValidity_DATE = @Ld_High_DATE;

                      IF @Ln_CountRecord_QNTY > 0
                       BEGIN
                        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GET_OBLIGATION_AMT';
                        --Get 2 months MSO
                        SET @Ln_Obligation_AMNT = dbo.BATCH_COMMON$SF_GET_OBLIGATION_AMT (@Ln_MemberCur_Case_IDNO, @Ad_Run_DATE) * 2;

                        IF @Ln_Arrears_AMNT > @Ln_Obligation_AMNT
                         BEGIN
                          SET @Lb_GenerateSaout_BIT = 1;
                         END
                       END
                      ELSE
                       BEGIN
                        IF @Ln_Arrears_AMNT > 500
                         BEGIN
                          SET @Lb_GenerateSaout_BIT = 1;
                         END
                       END
                     END
                   END
                  ELSE
                   BEGIN
                    SET @Lb_GenerateSaout_BIT = 1;
                   END

                  IF @Lb_GenerateSaout_BIT = 1
                   BEGIN
                    /*
                    An DACSES batch program triggers alert to the Worker - Out of State address
                    record associated with an NCP if the verification status stored on AHIS
                    is set to Verified Good and the member has at least one open case.
                    */
                    SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorSaout_CODE;
                    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY10';
                    SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', LS_CD_ACTIVITY_MINOR = ' + ISNULL (@Lc_ActivityMinor_CODE, '') + ', LN_SEQ_TXN_EVENT = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

                    EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
                     @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
                     @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
                     @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
                     @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
                     @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
                     @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                     @Ac_WorkerUpdate_ID          = '',
                     @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
                     @Ad_Run_DATE                 = @Ad_Run_DATE,
                     @An_Topic_IDNO               = @Ln_TopicIn_IDNO,
                     @Ac_Msg_CODE                 = @Lc_Msg_CODE,
                     @As_DescriptionError_TEXT    = @Ls_ErrorDesc_TEXT;

                    IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                     BEGIN
                      SET @Ac_Msg_CODE = @Lc_Msg_CODE;
                      SET @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT;

                      RETURN;
                     END
                   END
                 END
               END
             END
           END
         END
       END

      /*
       When the status of an address is set to Confirmed Good and the Establishment Type is set to Paternity
       to be Established, remedy can be initiated by using BATCH_ENF_ELFC.SP_INITIATE_REMEDY.
       
      	And the Verification Status of an NCP address is set to Confirmed Good, and the Establishment Type 
      	is set to Paternity to be Established or Order Needs to be Established, an entry is written into 
      	the enforcement locate interface (ELFC_Y1) table to initiate Paternity Establishment or Order needs 
      	to be Established remedy activities. The appropriate follow on activities are initiated by the 
      	batch program that processes the ELFC trigger.
       */
      IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
         AND @Ld_End_DATE > @Ad_Run_DATE
         AND @Lc_MemberCur_CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
       BEGIN
        IF @Ln_TransactionEventSeq_NUMB = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 2';
          SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

          EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
           @Ac_Process_ID               = @Ac_Process_ID,
           @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
           @Ac_Note_INDC                = @Lc_No_INDC,
           @An_EventFunctionalSeq_NUMB  = @Li_AddVerifiedAGoodAddress5290_NUMB,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        SET @Ls_Sql_TEXT = 'BATCH_ENF_ELFC$SP_INITIATE_REMEDY';
        SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

        EXECUTE BATCH_ENF_ELFC$SP_INITIATE_REMEDY
         @Ac_TypeChange_CODE          = @Lc_Null_TEXT,
         @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
         @An_OrderSeq_NUMB            = 0,
         @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
         @An_OthpSource_IDNO          = @An_MemberMci_IDNO,
         @Ac_TypeOthpSource_CODE      = @Lc_MemberCur_CaseRelationship_CODE,
         @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorEstp_CODE,
         @Ac_Subsystem_CODE           = @Lc_SubsystemEst_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
         @Ad_Run_DATE                 = @Ad_Run_DATE,
         @Ac_TypeReference_CODE       = @Lc_Space_TEXT,
         @Ac_Reference_ID             = @Lc_Space_TEXT,
         @Ac_Process_ID               = @Ac_Process_ID,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          RAISERROR (50001,16,1)
         END
       END

      SET @Ls_Sql_TEXT = 'FETCH MemberCur - 2';

      FETCH NEXT FROM MemberCur INTO @Ln_MemberCur_Case_IDNO, @Ln_MemberCur_MemberMci_IDNO, @Lc_MemberCur_CaseRelationship_CODE, @Lc_MemberCur_RespondInit_CODE, @Ln_MemberCur_OfficeOrder_NUMB;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE MemberCur;

   DEALLOCATE MemberCur;

   SET @Ln_TopicIn_IDNO = 0;
   SET @Ln_Topic_NUMB = 0;
   SET @Ls_Sql_TEXT = 'OPEN CaseCur';

   OPEN CaseCur;

   SET @Ls_Sql_TEXT = 'FETCH CaseCur - 1';

   FETCH NEXT FROM CaseCur INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    WHILE @Ln_FetchStatus_QNTY = 0
     BEGIN
      /*
      When the verification status (Status_CODE of AHIS_Y1) of an address record is set to Confirmed as Good and
      bench warrant exists in active status for the member, an activity is written into DMNR_Y1 which automatically
      triggers an alert to the Sheriff role in the county of issuance regarding new address information.
      */
      IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
         AND @Ld_End_DATE > @Ad_Run_DATE
       BEGIN
        IF @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
           AND @Lc_CaseCur_CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE, @Lc_CaseRelationshipCp_CODE)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY5 ';

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
           @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivityCmasw_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = '',
           @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
           @Ad_Run_DATE                 = @Ad_Run_DATE,
           @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
       END

      SET @Ls_Sql_TEXT = 'FETCH CaseCur - 2';

      FETCH NEXT FROM CaseCur INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE CaseCur;

   DEALLOCATE CaseCur;

--13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -START-
IF UPPER(LTRIM(RTRIM(ISNULL(@Ac_TypeAddress_CODE, '')))) <> @Lc_TypeAddressCourtC_CODE
BEGIN
--13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -END-
   IF (@Lb_VerStatusGood_BIT = 1
       AND @Lc_Status_CODE <> @Lc_VerificationStatusGood_CODE)
       OR (@Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
           AND @Ld_End_DATE <= @Ad_Run_DATE)
    BEGIN
     SET @Lb_LsttExist_BIT = 1;

     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 - 3';
      SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

      SELECT @Ln_MemberMci_IDNO = l.MemberMci_IDNO,
             @Ln_TransactionEventLsttSeq_NUMB = l.TransactionEventSeq_NUMB
        FROM LSTT_Y1 l
       WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
         AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
         AND l.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Lb_LsttExist_BIT = 0;
       END
      ELSE
       BEGIN
        SET @Lb_LsttExist_BIT = 1;
       END
     END

     -- Checking EHIS_Y1 if confirmed good record exists
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1 ';
      SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

      SELECT TOP 1 @Ln_MemberMci_IDNO = MemberMci_IDNO
        FROM EHIS_Y1 e
       WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
         AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
         AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
         -- Not considering unemployment/union as locate sources
         AND e.TypeIncome_CODE NOT IN (@Lc_IncomeTypeUnemployment_CODE, @Lc_IncomeTypeDisability_CODE, @Lc_IncomeTypeUnion_CODE)
         AND e.EndEmployment_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Lb_EhisExist_BIT = 0;
       END
      ELSE
       BEGIN
        SET @Lb_EhisExist_BIT = 1;
       END
     END

     -- Checking AHIS_Y1 if confirmed good record exists
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1 ';
      SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

      SELECT TOP 1 @Ln_MemberMci_IDNO = MemberMci_IDNO
        FROM AHIS_Y1 a
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
         AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
         AND a.TypeAddress_CODE <> @Lc_TypeAddressCourtC_CODE
         AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
         AND a.End_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Lb_AhisExist_BIT = 0;
       END
      ELSE
       BEGIN
        SET @Lb_AhisExist_BIT = 1;
       END
     END

     IF @Lb_EhisExist_BIT = 0
        AND @Lb_AhisExist_BIT = 0
        AND @Lb_LsttExist_BIT = 1
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1 1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = N';

       UPDATE LSTT_Y1
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE MemberMci_IDNO = @An_MemberMci_IDNO
          AND StatusLocate_CODE = @Lc_StatusLocateL_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LSTT_Y1 FAILED';

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'INSERT LSTT_Y1 1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = L';

       INSERT LSTT_Y1
              (MemberMci_IDNO,
               --  NOT LOCATED StatusLocate_CODE
               StatusLocate_CODE,
               BeginLocate_DATE,
               Address_INDC,
               Employer_INDC,
               Ssn_INDC,
               License_INDC,
               StatusLocate_DATE,
               Asset_INDC,
               SourceLoc_CODE,
               BeginLocAddr_DATE,
               BeginLocEmpr_DATE,
               BeginLocSsn_DATE,
               BeginLocDateOfBirth_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               BeginValidity_DATE,
               EndValidity_DATE,
               TransactionEventSeq_NUMB,
               ReferLocate_INDC)
       SELECT l.MemberMci_IDNO,
              @Lc_StatusLocateN_CODE AS StatusLocate_CODE,
              @Ad_Run_DATE AS BeginLocate_DATE,
              l.Address_INDC,
              l.Employer_INDC,
              l.Ssn_INDC,
              l.License_INDC,
              @Ad_Run_DATE AS StatusLocate_DATE,
              l.Asset_INDC,
              ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT) AS SourceLoc_CODE,
              @Ad_Run_DATE AS BeginLocAddr_DATE,
              l.BeginLocEmpr_DATE,
              l.BeginLocSsn_DATE,
              l.BeginLocDateOfBirth_DATE,
              @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
              @Ad_Run_DATE AS BeginValidity_DATE,
              @Ld_High_DATE AS EndValidity_DATE,
              @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
              l.ReferLocate_INDC
         FROM LSTT_Y1 AS l
        WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
          AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
          --  LOCATED
          AND l.TransactionEventSeq_NUMB = @Ln_TransactionEventLsttSeq_NUMB
          AND l.EndValidity_DATE = @Ad_Run_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT LSTT_Y1 FAILED';

         RAISERROR (50001,16,1);
        END
      END
    END
   ELSE
    BEGIN
     SET @Lb_LsttInsert_BIT = 0;
     /*
     Identify NCP-CP's in Un-Located Status System will identify CP's that do not have a verified
     address on DACSES, or NCP's who do not possess either a verified address or employer on DACSES
     */
     SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 - 4';
     SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = N';

     -- LSTT_Y1 Not Located record exists checking
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM LSTT_Y1 l
      WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
        AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
        AND --  NOT LOCATED
        l.EndValidity_DATE = @Ld_High_DATE
        AND ((EXISTS (SELECT 1
                        FROM CMEM_Y1 c
                       WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
                         AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                         AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
              AND EXISTS (SELECT 1
                            FROM AHIS_Y1 a
                           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND a.Status_CODE <> @Lc_VerificationStatusGood_CODE
                             AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE))
              OR (EXISTS (SELECT 1
                            FROM CMEM_Y1 c
                           WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                             AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
                  AND (EXISTS (SELECT 1
                                 FROM AHIS_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                                  AND a.Status_CODE <> @Lc_VerificationStatusGood_CODE
                                  AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE)
                        OR (EXISTS (SELECT 1
                                      FROM EHIS_Y1 e
                                     WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                                       AND e.Status_CODE <> @Lc_VerificationStatusGood_CODE
                                       AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE)))));

     IF @Ln_CountRecord_QNTY = 0
      BEGIN
       SET @Lb_LsttInsert_BIT = 1;
      END

     SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 - 5';
     SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = L,N';

     -- LSTT_Y1 Located record exists checking
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM LSTT_Y1 l
      WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
        AND l.StatusLocate_CODE IN (@Lc_StatusLocateL_CODE, @Lc_StatusLocateN_CODE)
        AND l.EndValidity_DATE = @Ld_High_DATE;

     /*
     Identify NCP-CP's in Un-Located Status System will identify CP's that do not have a verified
     address on DACSES, or NCP's who do not possess either a verified address or employer on DACSES
     */
     IF @Lb_LsttInsert_BIT = 1
        AND @Ln_CountRecord_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT LSTT_Y1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = N';

       INSERT LSTT_Y1
              (MemberMci_IDNO,
               StatusLocate_CODE,
               BeginLocate_DATE,
               Address_INDC,
               Employer_INDC,
               Ssn_INDC,
               License_INDC,
               StatusLocate_DATE,
               Asset_INDC,
               SourceLoc_CODE,
               BeginLocAddr_DATE,
               BeginLocEmpr_DATE,
               BeginLocSsn_DATE,
               BeginLocDateOfBirth_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               BeginValidity_DATE,
               EndValidity_DATE,
               TransactionEventSeq_NUMB,
               ReferLocate_INDC)
       VALUES (@An_MemberMci_IDNO,--MemberMci_IDNO
               @Lc_StatusLocateN_CODE,--StatusLocate_CODE
               @Ad_Run_DATE,--BeginLocate_DATE
               @Lc_No_INDC,--Address_INDC
               @Lc_No_INDC,--Employer_INDC
               @Lc_No_INDC,--Ssn_INDC
               @Lc_Space_TEXT,--License_INDC
               @Ad_Run_DATE,--StatusLocate_DATE
               @Lc_Space_TEXT,--Asset_INDC
               ISNULL (@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
               @Ad_Run_DATE,--BeginLocAddr_DATE
               @Ld_Low_DATE,--BeginLocEmpr_DATE
               @Ld_Low_DATE,--BeginLocSsn_DATE
               @Ld_Low_DATE,--BeginLocDateOfBirth_DATE
               @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
               dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
               @Ad_Run_DATE,--BeginValidity_DATE
               @Ld_High_DATE,--EndValidity_DATE
               @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
               @Lc_No_INDC); --ReferLocate_INDC
       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT LSTT_Y1 FAILED';

         RAISERROR (50001,16,1);
        END
      END
    END

   DECLARE MemberCur INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO,
           a.CaseRelationship_CODE,
           b.RespondInit_CODE,
           CASE
            WHEN b.Office_IDNO = @An_OfficeSignedOn_IDNO
             THEN 1
            ELSE 2
           END AS off_order
      FROM CMEM_Y1 a,
           CASE_Y1 b
     WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
       AND a.CaseMemberStatus_CODE = 'A'
       AND a.CaseRelationship_CODE IN ('C', 'A', 'P')
       AND a.Case_IDNO = b.Case_IDNO
       AND b.StatusCase_CODE = 'O'
     ORDER BY off_order,
              b.Opened_DATE DESC;

   SET @Ls_Sql_TEXT = 'OPEN MemberCur';

   OPEN MemberCur;

   SET @Ls_Sql_TEXT = 'FETCH MemberCur - 1';

   FETCH NEXT FROM MemberCur INTO @Ln_MemberCur_Case_IDNO, @Ln_MemberCur_MemberMci_IDNO, @Lc_MemberCur_CaseRelationship_CODE, @Lc_MemberCur_RespondInit_CODE, @Ln_MemberCur_OfficeOrder_NUMB;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    WHILE @Ln_FetchStatus_QNTY = 0
     -- To generate information alert LOCAB when locate status changes to located
     BEGIN
      IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
         AND @Ld_End_DATE > @Ad_Run_DATE
         AND @Lc_MemberCur_CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 ';
        SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

        SELECT @Ln_CountRecord_QNTY = COUNT (1)
          FROM LSTT_Y1 l
         WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
           AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
           AND l.EndValidity_DATE = @Ld_High_DATE
           AND l.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

        IF @Ln_CountRecord_QNTY > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY7 ';
          SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', LN_SEQ_TXN_EVENT = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
           @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivityLocab_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = '',
           @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
           @Ad_Run_DATE                 = @Ad_Run_DATE,
           @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
       END

      -- To generate information alert LOCAA when locate status changes to not located
      IF (@Lc_Status_CODE <> @Lc_VerificationStatusGood_CODE
           OR @Ld_End_DATE <= @Ad_Run_DATE)
         AND @Lc_MemberCur_CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1 ';
        SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

        SELECT @Ln_CountRecord_QNTY = COUNT (1)
          FROM LSTT_Y1 l
         WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
           AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
           AND l.EndValidity_DATE = @Ld_High_DATE
           AND l.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

        IF @Ln_CountRecord_QNTY > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY8 ';
          SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', LN_SEQ_TXN_EVENT = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
           @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivityLocaa_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = '',
           @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
           @Ad_Run_DATE                 = @Ad_Run_DATE,
           @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
       END

      SET @Ls_Sql_TEXT = 'FETCH MemberCur - 2';

      FETCH NEXT FROM MemberCur INTO @Ln_MemberCur_Case_IDNO, @Ln_MemberCur_MemberMci_IDNO, @Lc_MemberCur_CaseRelationship_CODE, @Lc_MemberCur_RespondInit_CODE, @Ln_MemberCur_OfficeOrder_NUMB;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE MemberCur;

   DEALLOCATE MemberCur;
--13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -START-
END
--13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -END-

   IF @Ac_SourceLoc_CODE IN (@Lc_SourceLocFam_CODE, @Lc_SourceLocCoa_CODE, @Lc_SourceLocPop_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = ' SELECT DEMO_Y1 - PHONE NO EXISTANCE CHECKING';
     SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

     -- Phone no existence checking for the member
     SELECT @Ln_CountRecord_QNTY = COUNT (1)
       FROM DEMO_Y1 d
      WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
        AND d.HomePhone_NUMB = 0;

     IF @Ln_CountRecord_QNTY > 0
        AND @An_Phone_NUMB <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT HDEMO_Y1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');

       INSERT HDEMO_Y1
              (MemberMci_IDNO,
               Individual_IDNO,
               Last_NAME,
               First_NAME,
               Middle_NAME,
               Suffix_NAME,
               Title_NAME,
               FullDisplay_NAME,
               MemberSex_CODE,
               MemberSsn_NUMB,
               Birth_DATE,
               Emancipation_DATE,
               LastMarriage_DATE,
               LastDivorce_DATE,
               BirthCity_NAME,
               BirthState_CODE,
               BirthCountry_CODE,
               DescriptionHeight_TEXT,
               DescriptionWeightLbs_TEXT,
               Race_CODE,
               ColorHair_CODE,
               ColorEyes_CODE,
               FacialHair_INDC,
               Language_CODE,
               TypeProblem_CODE,
               Deceased_DATE,
               CerDeathNo_TEXT,
               LicenseDriverNo_TEXT,
               AlienRegistn_ID,
               WorkPermitNo_TEXT,
               BeginPermit_DATE,
               EndPermit_DATE,
               HomePhone_NUMB,
               WorkPhone_NUMB,
               CellPhone_NUMB,
               Fax_NUMB,
               Contact_EML,
               Spouse_NAME,
               Graduation_DATE,
               EducationLevel_CODE,
               Restricted_INDC,
               Military_ID,
               MilitaryBranch_CODE,
               MilitaryStatus_CODE,
               MilitaryBenefitStatus_CODE,
               SecondFamily_INDC,
               MeansTestedInc_INDC,
               SsIncome_INDC,
               VeteranComps_INDC,
               Disable_INDC,
               Assistance_CODE,
               DescriptionIdentifyingMarks_TEXT,
               Divorce_INDC,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               TransactionEventSeq_NUMB,
               Update_DTTM,
               TypeOccupation_CODE,
               CountyBirth_IDNO,
               MotherMaiden_NAME,
               FileLastDivorce_ID)
       SELECT d.MemberMci_IDNO,
              d.Individual_IDNO,
              d.Last_NAME,
              d.First_NAME,
              d.Middle_NAME,
              d.Suffix_NAME,
              d.Title_NAME,
              d.FullDisplay_NAME,
              d.MemberSex_CODE,
              d.MemberSsn_NUMB,
              d.Birth_DATE,
              d.Emancipation_DATE,
              d.LastMarriage_DATE,
              d.LastDivorce_DATE,
              d.BirthCity_NAME,
              d.BirthState_CODE,
              d.BirthCountry_CODE,
              d.DescriptionHeight_TEXT,
              d.DescriptionWeightLbs_TEXT,
              d.Race_CODE,
              d.ColorHair_CODE,
              d.ColorEyes_CODE,
              d.FacialHair_INDC,
              d.Language_CODE,
              d.TypeProblem_CODE,
              d.Deceased_DATE,
              d.CerDeathNo_TEXT,
              d.LicenseDriverNo_TEXT,
              d.AlienRegistn_ID,
              d.WorkPermitNo_TEXT,
              d.BeginPermit_DATE,
              d.EndPermit_DATE,
              d.HomePhone_NUMB,
              d.WorkPhone_NUMB,
              d.CellPhone_NUMB,
              d.Fax_NUMB,
              d.Contact_EML,
              d.Spouse_NAME,
              d.Graduation_DATE,
              d.EducationLevel_CODE,
              d.Restricted_INDC,
              d.Military_ID,
              d.MilitaryBranch_CODE,
              d.MilitaryStatus_CODE,
              d.MilitaryBenefitStatus_CODE,
              d.SecondFamily_INDC,
              d.MeansTestedInc_INDC,
              d.SsIncome_INDC,
              d.VeteranComps_INDC,
              d.Disable_INDC,
              d.Assistance_CODE,
              d.DescriptionIdentifyingMarks_TEXT,
              d.Divorce_INDC,
              d.BeginValidity_DATE,
              @Ad_Run_DATE AS EndValidity_DATE,
              d.WorkerUpdate_ID,
              d.TransactionEventSeq_NUMB,
              d.Update_DTTM,
              d.TypeOccupation_CODE,
              d.CountyBirth_IDNO,
              d.MotherMaiden_NAME,
              d.FileLastDivorce_ID
         FROM DEMO_Y1 d
        WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT HDEMO_Y1 FAILED';

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '');

       UPDATE DEMO_Y1
          SET HomePhone_NUMB = @An_Phone_NUMB,
              BeginValidity_DATE = @Ad_Run_DATE,
              WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
              TransactionEventSeq_NUMB = @Ln_TransactionEventDemoSeq_NUMB,
              Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
        WHERE DEMO_Y1.MemberMci_IDNO = @An_MemberMci_IDNO;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE DEMO FAILED';

         RAISERROR (50001,16,1);
        END
      END
    END

   /* 	The system will update the solicited and unsolicited addresses for NCP on cases that are closed with unable to locate reason codes. 
    The system will  generate the alert â€˜Address received on a case closed for Unable to Locateâ€™  */
   IF NOT EXISTS(SELECT 1
                   FROM CMEM_Y1 a,
                        CASE_Y1 b
                  WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                    AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                    AND a.Case_IDNO = b.Case_IDNO
                    AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE)
    BEGIN
     DECLARE CaseCloseCur INSENSITIVE CURSOR FOR
      SELECT b.Case_IDNO,
             b.Worker_ID
        FROM CMEM_Y1 a,
             CASE_Y1 b
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
         AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
         AND a.CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND a.Case_IDNO = b.Case_IDNO
         AND b.RsnStatusCase_CODE IN(@Lc_RsnStatusCaseUb_CODE, @Lc_RsnStatusCaseUC_CODE)
         AND b.StatusCase_CODE = @Lc_CaseStatusClose_CODE

     SET @Ls_Sql_TEXT = 'OPEN CaseCloseCur';

     OPEN CaseCloseCur;

     SET @Ls_Sql_TEXT = 'FETCH CaseCloseCur - 1';

     FETCH NEXT FROM CaseCloseCur INTO @Ln_CaseCloseCur_Case_IDNO, @Lc_CaseCloseCur_Worker_ID;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY11';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_CaseCloseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@An_TransactionEventSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_CaseCloseCur_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorArccl_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
        @Ac_WorkerDelegate_ID        = @Lc_CaseCloseCur_Worker_ID,
        @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'FETCH CaseCloseCur - 2';

       FETCH NEXT FROM CaseCloseCur INTO @Ln_CaseCloseCur_Case_IDNO, @Lc_CaseCloseCur_Worker_ID;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE CaseCloseCur;

     DEALLOCATE CaseCloseCur;
    END

   /* Case Journal Entries based on cr document CR0369v.2
   9.	FCR NDNH, FCR FPLS, FCR SVES, FCR Insurance match, FCR MSFIDM, DELJIS, DPR, DOR, DOR locate, family court, cell phone, PUDM (incoming) - Unconfirmed Address Received â€“ RUNCA 
   10.	FCR_NCOA, DELJIS, DPR, DOR, DOR locate, family court, cell phone, PUDM (incoming) -Confirmed Address Received - RCONA
   *** NOTE *** : Cell Phone and PUDM batches took care of this Case Journal entry in their code and so not implemented here.
   */
   IF UPPER(LTRIM(RTRIM(@Ac_SignedOnWorker_ID))) = @Lc_BatchRunUser_TEXT
    BEGIN
     SELECT @Lc_ActivityMinor_CODE = ISNULL((SELECT TOP 1 CASE
                                                     WHEN UPPER(LTRIM(RTRIM(A.Status_CODE))) = @Lc_VerificationStatusPending_CODE
                                                          AND ((UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'DEB8086'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DOC')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'FUI_NDNH'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'NDH')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'FW4_NDNH'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'NDH')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'FCR_FPLS'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'FPL')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'FCR_SVES'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'FCR')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'FCR_IM'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'FCR')
                                                                --13529 - CR0394 Update Member Address with FCR MSFIDM Account Holder Address -START-
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'MS_FIDM'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'MSF')
                                                                --13529 - CR0394 Update Member Address with FCR MSFIDM Account Holder Address -END-
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'BATCH'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DOR')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'DEB8040'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DOR')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'DEB8098'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DPR'))
                                                      THEN @Lc_ActivityMinorRunca_CODE
                                                     WHEN UPPER(LTRIM(RTRIM(A.Status_CODE))) = @Lc_VerificationStatusGood_CODE
                                                          AND ((UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'DEB8086'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DOC')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'FCR_NCOA'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'NCA')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'BATCH'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DOR')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'DEB8040'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DOR')
                                                                OR (UPPER(LTRIM(RTRIM(@Ac_Process_ID))) = 'DEB8098'
                                                                    AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = 'DPR'))
                                                      THEN @Lc_ActivityMinorRcona_CODE
                                                     ELSE ''
                                                    END
                                               FROM AHIS_Y1 A
                                              WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
                                                AND A.TypeAddress_CODE = @Ac_TypeAddress_CODE
                                                AND A.BeginValidity_DATE = @Ad_Run_DATE
                                                AND UPPER(LTRIM(RTRIM(A.SourceLoc_CODE))) = UPPER(LTRIM(RTRIM(@Ac_SourceLoc_CODE)))
                                              ORDER BY A.TransactionEventSeq_NUMB DESC), '')

     IF UPPER(LTRIM(RTRIM(@Lc_ActivityMinor_CODE))) IN (@Lc_ActivityMinorRcona_CODE, @Lc_ActivityMinorRunca_CODE)
      BEGIN
       DECLARE OpenCasesCur INSENSITIVE CURSOR FOR
        SELECT DISTINCT
               b.Case_IDNO
          FROM CMEM_Y1 a,
               CASE_Y1 b
         WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
           AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
           AND a.Case_IDNO = b.Case_IDNO
           AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
           AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE

       SET @Ls_Sql_TEXT = 'OPEN OpenCasesCur';

       OPEN OpenCasesCur;

       SET @Ls_Sql_TEXT = 'FETCH OpenCasesCur - 1';

       FETCH NEXT FROM OpenCasesCur INTO @Ln_OpenCasesCur_Case_IDNO;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY12';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_OpenCasesCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@An_TransactionEventSeq_NUMB AS VARCHAR), '');

         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @Ln_OpenCasesCur_Case_IDNO,
          @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
          @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'FETCH OpenCasesCur - 2';

         FETCH NEXT FROM OpenCasesCur INTO @Ln_OpenCasesCur_Case_IDNO;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE OpenCasesCur;

       DEALLOCATE OpenCasesCur;
      END
    END

	/* Added for Bug 13556 */
	IF EXISTS
	(
		SELECT 1
		FROM LSTT_Y1 A
		WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
		AND A.BeginValidity_DATE = @Ad_Run_DATE
		AND A.EndValidity_DATE = '12/31/9999'
		AND 
		(
			(
				(
					A.Address_INDC = 'N'
					AND EXISTS(SELECT 1 FROM AHIS_Y1 X
					WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
					AND X.TypeAddress_CODE IN ('M', 'R')
					AND X.Status_CODE = 'Y'
					AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE)
				)
				OR
				(
					A.Address_INDC = 'Y'
					AND NOT EXISTS(SELECT 1 FROM AHIS_Y1 X
					WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
					AND X.TypeAddress_CODE IN ('M', 'R')
					AND X.Status_CODE = 'Y'
					AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE)
				)
			)
		)
	)
	--13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -START-
	AND UPPER(LTRIM(RTRIM(ISNULL(@Ac_TypeAddress_CODE, '')))) <> @Lc_TypeAddressCourtC_CODE
	--13689 - Do not affect the locate status of a member if the Incoming Address is a Court Address -END-
	BEGIN
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - UPDATE LSTT_Y1 - Address Indicator';
		SET @Ls_SqlData_TEXT = '';

		EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
		@Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
		@Ac_Process_ID               = @Ac_Process_ID,
		@Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
		@Ac_Note_INDC                = @Lc_No_INDC,
		@An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
		@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
		@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

		IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END
		
		SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1 to set Address Indicator';
		SET @Ls_SqlData_TEXT = ''

		UPDATE A
		SET Address_INDC = CASE
					   WHEN EXISTS(SELECT 1
									 FROM AHIS_Y1 X
									WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
									  AND X.TypeAddress_CODE IN ('M', 'R')
									  AND X.Status_CODE = 'Y'
									  AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE)
						THEN 'Y'
					   ELSE 'N'
					  END,
			WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
			Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			BeginValidity_DATE = @Ad_Run_DATE,
			EndValidity_DATE = '12/31/9999',
			TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
		OUTPUT deleted.MemberMci_IDNO,
			deleted.StatusLocate_CODE,
			deleted.BeginLocate_DATE,
			deleted.Address_INDC,
			deleted.Employer_INDC,
			deleted.Ssn_INDC,
			deleted.License_INDC,
			deleted.StatusLocate_DATE,
			deleted.Asset_INDC,
			deleted.SourceLoc_CODE,
			deleted.BeginLocAddr_DATE,
			deleted.BeginLocEmpr_DATE,
			deleted.BeginLocSsn_DATE,
			deleted.BeginLocDateOfBirth_DATE,
			deleted.WorkerUpdate_ID,
			deleted.Update_DTTM,
			deleted.BeginValidity_DATE,
			@Ad_Run_DATE AS EndValidity_DATE,
			deleted.TransactionEventSeq_NUMB,
			deleted.ReferLocate_INDC
		INTO LSTT_Y1
		FROM LSTT_Y1 A
		WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
		AND A.BeginValidity_DATE = @Ad_Run_DATE
		AND A.EndValidity_DATE = '12/31/9999'
		AND 
		(
			(
				(
					A.Address_INDC = 'N'
					AND EXISTS(SELECT 1 FROM AHIS_Y1 X
					WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
					AND X.TypeAddress_CODE IN ('M', 'R')
					AND X.Status_CODE = 'Y'
					AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE)
				)
				OR
				(
					A.Address_INDC = 'Y'
					AND NOT EXISTS(SELECT 1 FROM AHIS_Y1 X
					WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
					AND X.TypeAddress_CODE IN ('M', 'R')
					AND X.Status_CODE = 'Y'
					AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE)
				)
			)
		)
	END
	
   SET @Ac_Msg_CODE = ISNULL (@Lc_MsgK_CODE, @Lc_StatusSuccess_CODE);
   SET @As_DescriptionError_TEXT = @Lc_Null_TEXT;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'MemberCur') IN (0, 1)
    BEGIN
     CLOSE MemberCur;

     DEALLOCATE MemberCur;
    END

   IF CURSOR_STATUS ('LOCAL', 'OpenCasesCur') IN (0, 1)
    BEGIN
     CLOSE OpenCasesCur;

     DEALLOCATE OpenCasesCur;
    END

   IF CURSOR_STATUS ('LOCAL', 'CaseCloseCur') IN (0, 1)
    BEGIN
     CLOSE CaseCloseCur;

     DEALLOCATE CaseCloseCur;
    END

   IF CURSOR_STATUS ('LOCAL', 'CaseCur') IN (0, 1)
    BEGIN
     CLOSE CaseCur;

     DEALLOCATE CaseCur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ln_ErrorLine_NUMB = ERROR_LINE();
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
