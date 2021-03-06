/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO
Programmer Name		 : IMP Team
Description			 : The procedure updates member SSN , DT_BIRTH in DEMO_Y1.
Frequency			 : Daily
Developed On		 : 04/07/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_PERSON_ACK_DETAILS
Called On			 : BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_DEMO]
 @Ad_Run_DATE              DATE,
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_MemberSsn_NUMB        NUMERIC(9),
 @Ad_Birth_DATE            DATE,
 @Ad_Deceased_DATE         DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE		 CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE		 CHAR(1) = 'S',
           @Lc_Note_INDC				 CHAR(1) = 'N',
           @Lc_Job_ID					 CHAR(7) = 'DEB0480',
           @Lc_BatchRunUser_TEXT		 CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME			 VARCHAR(60) = 'SP_UPDATE_DEMO';
  DECLARE  @Ln_EventFunctionalSeq_NUMB   NUMERIC(4,0) = 0,
           @Ln_Error_NUMB                NUMERIC(11),
           @Ln_ErrorLine_NUMB            NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB  NUMERIC(19),
           @Li_RowCount_QNTY             SMALLINT,
           @Lc_Space_TEXT                CHAR(1) = '',
           @Lc_Msg_CODE                  CHAR(1),
           @Ls_Sql_TEXT                  VARCHAR(100),
           @Ls_Sqldata_TEXT              VARCHAR(1000),
           @Ls_DescriptionError_TEXT     VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT         VARCHAR(4000),
           @Ls_ErrorDesc_TEXT            VARCHAR(4000),
           @Ld_Start_DATE                DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_ErrorDesc_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'INSERT INTO HDEMO_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0);
   
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
           FileLastDivorce_ID,
           TribalAffiliations_CODE,
           FormerMci_IDNO,
           StateDivorce_CODE,
           CityDivorce_NAME,
           StateMarriage_CODE,
           CityMarriage_NAME,
           IveParty_IDNO)
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
          d.FileLastDivorce_ID,
          d.TribalAffiliations_CODE,
          d.FormerMci_IDNO,
          d.StateDivorce_CODE,
          d.CityDivorce_NAME,
          d.StateMarriage_CODE,
          d.CityMarriage_NAME,
          d.IveParty_IDNO
     FROM DEMO_Y1 d
    WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorDesc_TEXT = 'INSERT FAILED - HDEMO_Y1';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 3';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0);

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorDesc_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorDesc_TEXT = 'SEQ_TXN_EVENT FAILED IN DEMO UPDATE';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0);

   UPDATE DEMO_Y1 
      SET MemberSsn_NUMB = @An_MemberSsn_NUMB,
          Birth_DATE = @Ad_Birth_DATE,
          Deceased_DATE = @Ad_Deceased_DATE,
          BeginValidity_DATE = @Ad_Run_DATE,
          WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          Update_DTTM = @Ld_Start_DATE
    WHERE DEMO_Y1.MemberMci_IDNO = @An_MemberMci_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorDesc_TEXT = 'UPDATE DEMO_Y1 - FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  
  END CATCH
 END


GO
