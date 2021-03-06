/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO
Programmer Name	:	IMP Team.
Description		:	Insert values in Member Demographics.
Frequency		:	
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		:	BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO] (
 @An_MemberMci_IDNO                   NUMERIC(10, 0),
 @An_Individual_IDNO                  NUMERIC(8, 0) = 0,
 @Ac_Last_NAME                        CHAR(20) = ' ',
 @Ac_First_NAME                       CHAR(16) = ' ',
 @Ac_Middle_NAME                      CHAR(20) = ' ',
 @Ac_Suffix_NAME                      CHAR(4) = ' ',
 @Ac_Title_NAME                       CHAR(8) = ' ',
 @As_FullDisplay_NAME                 VARCHAR(60) = ' ',
 @Ac_MemberSex_CODE                   CHAR(1) = ' ',
 @An_MemberSsn_NUMB                   NUMERIC(9, 0) = 0,
 @Ad_Birth_DATE                       DATE = '01/01/0001',
 @Ad_Emancipation_DATE                DATE = '01/01/0001',
 @Ad_LastMarriage_DATE                DATE = '01/01/0001',
 @Ad_LastDivorce_DATE                 DATE = '01/01/0001',
 @Ac_BirthCity_NAME                   CHAR(28) = ' ',
 @Ac_BirthState_CODE                  CHAR(2) = ' ',
 @Ac_BirthCountry_CODE                CHAR(2) = ' ',
 @Ac_DescriptionHeight_TEXT           CHAR(3) = ' ',
 @Ac_DescriptionWeightLbs_TEXT        CHAR(3) = ' ',
 @Ac_Race_CODE                        CHAR(1) = ' ',
 @Ac_ColorHair_CODE                   CHAR(3) = ' ',
 @Ac_ColorEyes_CODE                   CHAR(3) = ' ',
 @Ac_FacialHair_INDC                  CHAR(1) = ' ',
 @Ac_Language_CODE                    CHAR(3) = ' ',
 @Ac_TypeProblem_CODE                 CHAR(3) = ' ',
 @Ad_Deceased_DATE                    DATE = '01/01/0001',
 @Ac_CerDeathNo_TEXT                  CHAR(9) = ' ',
 @Ac_LicenseDriverNo_TEXT             CHAR(25) = ' ',
 @Ac_AlienRegistn_ID                  CHAR(10) = ' ',
 @Ac_WorkPermitNo_TEXT                CHAR(10) = ' ',
 @Ad_BeginPermit_DATE                 DATE = '01/01/0001',
 @Ad_EndPermit_DATE                   DATE = '01/01/0001',
 @An_HomePhone_NUMB                   NUMERIC(15, 0) = 0,
 @An_WorkPhone_NUMB                   NUMERIC(15, 0) = 0,
 @An_CellPhone_NUMB                   NUMERIC(15, 0) = 0,
 @An_Fax_NUMB                         NUMERIC(15, 0) = 0,
 @As_Contact_EML                      VARCHAR(100) = ' ',
 @Ac_Spouse_NAME                      CHAR(40) = ' ',
 @Ad_Graduation_DATE                  DATE = '01/01/0001',
 @Ac_EducationLevel_CODE              CHAR(2) = ' ',
 @Ac_Restricted_INDC                  CHAR(1) = ' ',
 @Ac_Military_ID                      CHAR(10) = ' ',
 @Ac_MilitaryBranch_CODE              CHAR(2) = ' ',
 @Ac_MilitaryStatus_CODE              CHAR(2) = ' ',
 @Ac_MilitaryBenefitStatus_CODE       CHAR(2) = ' ',
 @Ac_SecondFamily_INDC                CHAR(1) = ' ',
 @Ac_MeansTestedInc_INDC              CHAR(1) = ' ',
 @Ac_SsIncome_INDC                    CHAR(1) = ' ',
 @Ac_VeteranComps_INDC                CHAR(1) = ' ',
 @Ac_Assistance_CODE                  CHAR(3) = ' ',
 @Ac_DescriptionIdentifyingMarks_TEXT CHAR(40) = ' ',
 @Ac_Divorce_INDC                     CHAR(1) = ' ',
 @Ac_WorkerUpdate_ID                  CHAR(30),
 @An_TransactionEventSeq_NUMB         NUMERIC(19, 0),
 @Ac_Disable_INDC                     CHAR(1) = ' ',
 @Ac_TypeOccupation_CODE              CHAR(3) = ' ',
 @An_CountyBirth_IDNO                 NUMERIC(3, 0) = 0,
 @Ac_MotherMaiden_NAME                CHAR(30) = ' ',
 @Ac_FileLastDivorce_ID               CHAR(15) = ' ',
 @Ac_StateMarriage_CODE               CHAR(2) = ' ',
 @Ac_StateDivorce_CODE                CHAR(2) = ' ',
 @An_IveParty_IDNO                    NUMERIC(10) = 0,
 @Ac_Msg_CODE                         CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT            VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --	Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_Zero_NUMB             SMALLINT = 0,
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_DEMO',
          @Ls_Sql_TEXT              VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT          VARCHAR(5000) = ' ',
          @Ld_Systemdatetime_DTTM   DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Rowcount_QNTY  NUMERIC,
          @Ln_Error_NUMB     NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB NUMERIC(11) = 0;

  BEGIN TRY
   IF @An_MemberSsn_NUMB != 0
      AND EXISTS (SELECT 1
                    FROM MSSN_Y1
                   WHERE EndValidity_DATE = '12/31/9999'
                     AND MemberSsn_NUMB = @An_MemberSsn_NUMB
                     AND MemberMci_IDNO != @An_MemberMci_IDNO
                     AND Enumeration_CODE NOT IN ('B'))
    BEGIN
     SET @An_MemberSsn_NUMB = 0;
    END

   SET @Ls_Sql_TEXT = 'INSERT DEMO_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Individual_IDNO = ' + ISNULL(CAST(@An_Individual_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Ac_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ac_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ac_Middle_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Ac_Suffix_NAME, '') + ', Title_NAME = ' + ISNULL(@Ac_Title_NAME, '') + ', FullDisplay_NAME = ' + ISNULL(@As_FullDisplay_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Ac_MemberSex_CODE, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ad_Birth_DATE AS VARCHAR), '') + ', Emancipation_DATE = ' + ISNULL(CAST(@Ad_Emancipation_DATE AS VARCHAR), '') + ', LastMarriage_DATE = ' + ISNULL(CAST(@Ad_LastMarriage_DATE AS VARCHAR), '') + ', LastDivorce_DATE = ' + ISNULL(CAST(@Ad_LastDivorce_DATE AS VARCHAR), '') + ', BirthCity_NAME = ' + ISNULL(@Ac_BirthCity_NAME, '') + ', BirthState_CODE = ' + ISNULL(@Ac_BirthState_CODE, '') + ', BirthCountry_CODE = ' + ISNULL(@Ac_BirthCountry_CODE, '') + ', DescriptionHeight_TEXT = ' + ISNULL(@Ac_DescriptionHeight_TEXT, '') + ', DescriptionWeightLbs_TEXT = ' + ISNULL(@Ac_DescriptionWeightLbs_TEXT, '') + ', Race_CODE = ' + ISNULL(@Ac_Race_CODE, '') + ', ColorHair_CODE = ' + ISNULL(@Ac_ColorHair_CODE, '') + ', ColorEyes_CODE = ' + ISNULL(@Ac_ColorEyes_CODE, '') + ', FacialHair_INDC = ' + ISNULL(@Ac_FacialHair_INDC, '') + ', Language_CODE = ' + ISNULL(@Ac_Language_CODE, '') + ', TypeProblem_CODE = ' + ISNULL(@Ac_TypeProblem_CODE, '') + ', Deceased_DATE = ' + ISNULL(CAST(@Ad_Deceased_DATE AS VARCHAR), '') + ', CerDeathNo_TEXT = ' + ISNULL(@Ac_CerDeathNo_TEXT, '') + ', LicenseDriverNo_TEXT = ' + ISNULL(@Ac_LicenseDriverNo_TEXT, '') + ', AlienRegistn_ID = ' + ISNULL(@Ac_AlienRegistn_ID, '') + ', WorkPermitNo_TEXT = ' + ISNULL(@Ac_WorkPermitNo_TEXT, '') + ', BeginPermit_DATE = ' + ISNULL(CAST(@Ad_BeginPermit_DATE AS VARCHAR), '') + ', EndPermit_DATE = ' + ISNULL(CAST(@Ad_EndPermit_DATE AS VARCHAR), '') + ', HomePhone_NUMB = ' + ISNULL(CAST(@An_HomePhone_NUMB AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@An_WorkPhone_NUMB AS VARCHAR), '') + ', CellPhone_NUMB = ' + ISNULL(CAST(@An_CellPhone_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@An_Fax_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@As_Contact_EML, '') + ', Spouse_NAME = ' + ISNULL(@Ac_Spouse_NAME, '') + ', Graduation_DATE = ' + ISNULL(CAST(@Ad_Graduation_DATE AS VARCHAR), '') + ', EducationLevel_CODE = ' + ISNULL(@Ac_EducationLevel_CODE, '') + ', Restricted_INDC = ' + ISNULL(@Ac_Restricted_INDC, '') + ', Military_ID = ' + ISNULL(@Ac_Military_ID, '') + ', MilitaryBranch_CODE = ' + ISNULL(@Ac_MilitaryBranch_CODE, '') + ', MilitaryStatus_CODE = ' + ISNULL(@Ac_MilitaryStatus_CODE, '') + ', MilitaryBenefitStatus_CODE = ' + ISNULL(@Ac_MilitaryBenefitStatus_CODE, '') + ', SecondFamily_INDC = ' + ISNULL(@Ac_SecondFamily_INDC, '') + ', MeansTestedInc_INDC = ' + ISNULL(@Ac_MeansTestedInc_INDC, '') + ', SsIncome_INDC = ' + ISNULL(@Ac_SsIncome_INDC, '') + ', VeteranComps_INDC = ' + ISNULL(@Ac_VeteranComps_INDC, '') + ', Assistance_CODE = ' + ISNULL(@Ac_Assistance_CODE, '') + ', DescriptionIdentifyingMarks_TEXT = ' + ISNULL(@Ac_DescriptionIdentifyingMarks_TEXT, '') + ', Divorce_INDC = ' + ISNULL(@Ac_Divorce_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Systemdatetime_DTTM AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Systemdatetime_DTTM AS VARCHAR), '') + ', Disable_INDC = ' + ISNULL(@Ac_Disable_INDC, '') + ', TypeOccupation_CODE = ' + ISNULL(@Ac_TypeOccupation_CODE, '') + ', CountyBirth_IDNO = ' + ISNULL(CAST(@An_CountyBirth_IDNO AS VARCHAR), '') + ', MotherMaiden_NAME = ' + ISNULL(@Ac_MotherMaiden_NAME, '') + ', FileLastDivorce_ID = ' + ISNULL(@Ac_FileLastDivorce_ID, '') + ', TribalAffiliations_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FormerMci_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', StateMarriage_CODE = ' + ISNULL(@Ac_StateMarriage_CODE, '') + ', StateDivorce_CODE = ' + ISNULL(@Ac_StateDivorce_CODE, '') + ', IveParty_IDNO = ' + ISNULL(CAST(@An_IveParty_IDNO AS VARCHAR), '') + ', CityDivorce_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', CityMarriage_NAME = ' + ISNULL(@Lc_Space_TEXT, '');

   INSERT DEMO_Y1
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
           Assistance_CODE,
           DescriptionIdentifyingMarks_TEXT,
           Divorce_INDC,
           BeginValidity_DATE,
           WorkerUpdate_ID,
           TransactionEventSeq_NUMB,
           Update_DTTM,
           Disable_INDC,
           TypeOccupation_CODE,
           CountyBirth_IDNO,
           MotherMaiden_NAME,
           FileLastDivorce_ID,
           TribalAffiliations_CODE,
           FormerMci_IDNO,
           StateMarriage_CODE,
           StateDivorce_CODE,
           IveParty_IDNO,
           CityDivorce_NAME,
           CityMarriage_NAME)
   VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
            @An_Individual_IDNO,--Individual_IDNO
            @Ac_Last_NAME,--Last_NAME
            @Ac_First_NAME,--First_NAME
            @Ac_Middle_NAME,--Middle_NAME
            @Ac_Suffix_NAME,--Suffix_NAME
            @Ac_Title_NAME,--Title_NAME
            @As_FullDisplay_NAME,--FullDisplay_NAME
            @Ac_MemberSex_CODE,--MemberSex_CODE
            @An_MemberSsn_NUMB,--MemberSsn_NUMB
            @Ad_Birth_DATE,--Birth_DATE
            @Ad_Emancipation_DATE,--Emancipation_DATE
            @Ad_LastMarriage_DATE,--LastMarriage_DATE
            @Ad_LastDivorce_DATE,--LastDivorce_DATE
            @Ac_BirthCity_NAME,--BirthCity_NAME
            @Ac_BirthState_CODE,--BirthState_CODE
            @Ac_BirthCountry_CODE,--BirthCountry_CODE
            @Ac_DescriptionHeight_TEXT,--DescriptionHeight_TEXT
            @Ac_DescriptionWeightLbs_TEXT,--DescriptionWeightLbs_TEXT
            @Ac_Race_CODE,--Race_CODE
            @Ac_ColorHair_CODE,--ColorHair_CODE
            @Ac_ColorEyes_CODE,--ColorEyes_CODE
            @Ac_FacialHair_INDC,--FacialHair_INDC
            @Ac_Language_CODE,--Language_CODE
            @Ac_TypeProblem_CODE,--TypeProblem_CODE
            @Ad_Deceased_DATE,--Deceased_DATE
            @Ac_CerDeathNo_TEXT,--CerDeathNo_TEXT
            @Ac_LicenseDriverNo_TEXT,--LicenseDriverNo_TEXT
            @Ac_AlienRegistn_ID,--AlienRegistn_ID
            @Ac_WorkPermitNo_TEXT,--WorkPermitNo_TEXT
            @Ad_BeginPermit_DATE,--BeginPermit_DATE
            @Ad_EndPermit_DATE,--EndPermit_DATE
            @An_HomePhone_NUMB,--HomePhone_NUMB
            @An_WorkPhone_NUMB,--WorkPhone_NUMB
            @An_CellPhone_NUMB,--CellPhone_NUMB
            @An_Fax_NUMB,--Fax_NUMB
            @As_Contact_EML,--Contact_EML
            @Ac_Spouse_NAME,--Spouse_NAME
            @Ad_Graduation_DATE,--Graduation_DATE
            @Ac_EducationLevel_CODE,--EducationLevel_CODE
            @Ac_Restricted_INDC,--Restricted_INDC
            @Ac_Military_ID,--Military_ID
            @Ac_MilitaryBranch_CODE,--MilitaryBranch_CODE
            @Ac_MilitaryStatus_CODE,--MilitaryStatus_CODE
            @Ac_MilitaryBenefitStatus_CODE,--MilitaryBenefitStatus_CODE
            @Ac_SecondFamily_INDC,--SecondFamily_INDC
            @Ac_MeansTestedInc_INDC,--MeansTestedInc_INDC
            @Ac_SsIncome_INDC,--SsIncome_INDC
            @Ac_VeteranComps_INDC,--VeteranComps_INDC
            @Ac_Assistance_CODE,--Assistance_CODE
            @Ac_DescriptionIdentifyingMarks_TEXT,--DescriptionIdentifyingMarks_TEXT
            @Ac_Divorce_INDC,--Divorce_INDC
            @Ld_Systemdatetime_DTTM,--BeginValidity_DATE
            @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
            @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            @Ld_Systemdatetime_DTTM,--Update_DTTM
            @Ac_Disable_INDC,--Disable_INDC
            @Ac_TypeOccupation_CODE,--TypeOccupation_CODE
            @An_CountyBirth_IDNO,--CountyBirth_IDNO
            @Ac_MotherMaiden_NAME,--MotherMaiden_NAME
            @Ac_FileLastDivorce_ID,--FileLastDivorce_ID
            @Lc_Space_TEXT,--TribalAffiliations_CODE
            @Li_Zero_NUMB,--FormerMci_IDNO
            @Ac_StateMarriage_CODE,--StateMarriage_CODE
            @Ac_StateDivorce_CODE,--StateDivorce_CODE
            @An_IveParty_IDNO,--IveParty_IDNO
            @Lc_Space_TEXT,--CityDivorce_NAME
            @Lc_Space_TEXT--CityMarriage_NAME
   );

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Li_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
