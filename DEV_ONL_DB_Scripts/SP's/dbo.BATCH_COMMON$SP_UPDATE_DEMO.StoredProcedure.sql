/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_DEMO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_DEMO
Programmer Name		: IMP Team
Description			: This procedure is used to Update Demo Informations
Frequency			: DAILY
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_DEMO] (
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_BirthCity_NAME        CHAR(28) = '',
 @An_HomePhone_NUMB        NUMERIC(15) = 0,
 @An_CellPhone_NUMB        NUMERIC(15) = 0,
 @An_WorkPhone_NUMB        NUMERIC(15) = 0,
 @Ad_Birth_DATE            DATE = '0001/01/01',
 @Ac_Process_ID            CHAR(10),
 @Ad_Process_DATE          DATE,
 @Ac_WorkerUpdate_ID       CHAR(30),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR = 'S',
          @Lc_StatusFailed_CODE  CHAR = 'F',
          @Lc_Yes_INDC           CHAR = 'Y',
          @Ld_Low_DATE           DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB               NUMERIC,
          @Ln_RowCount_QNTY            NUMERIC,
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_HomePhone_NUMB           NUMERIC(15),
          @Ln_CellPhone_NUMB           NUMERIC(15),
          @Ln_WorkPhone_NUMB           NUMERIC(15),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_Msg_CODE                 CHAR(1),
          @Lc_UpdateFlag_INDC          CHAR(1),
          @Lc_BirthCity_NAME           CHAR(28),
          @Ls_Routine_TEXT             VARCHAR(60) = '',
          @Ls_Sql_TEXT                 VARCHAR(200),
          @Ls_Sqldata_TEXT             VARCHAR(1000),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = '',
          @Ld_Birth_DATE               DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'');

   SELECT @Lc_BirthCity_NAME = a.BirthCity_NAME,
          @Ln_HomePhone_NUMB = a.HomePhone_NUMB,
          @Ln_CellPhone_NUMB = a.CellPhone_NUMB,
          @Ln_WorkPhone_NUMB = a.WorkPhone_NUMB,
          @Ld_Birth_DATE = a.Birth_DATE
     FROM DEMO_Y1 a
    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO;

   IF ((@Lc_BirthCity_NAME IS NULL
         OR @Lc_BirthCity_NAME = '')
       AND @Ac_BirthCity_NAME IS NOT NULL)
    BEGIN
     SET @Lc_BirthCity_NAME = @Ac_BirthCity_NAME;
     SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
    END;

   IF ((@Ln_HomePhone_NUMB = 0)
       AND @An_HomePhone_NUMB <> 0)
    BEGIN
     SET @Ln_HomePhone_NUMB = @An_HomePhone_NUMB;
     SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
    END;

   IF ((@Ln_WorkPhone_NUMB = 0)
       AND @An_WorkPhone_NUMB <> 0)
    BEGIN
     SET @Ln_WorkPhone_NUMB = @An_WorkPhone_NUMB;
     SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
    END;

   IF ((@Ln_CellPhone_NUMB <> @An_CellPhone_NUMB)
       AND @An_CellPhone_NUMB <> 0)
    BEGIN
     SET @Ln_CellPhone_NUMB = @An_CellPhone_NUMB;
     SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
    END;

   IF ((@Ld_Birth_DATE IS NULL
         OR @Ld_Birth_DATE = @Ld_Low_DATE)
       AND @Ad_Birth_DATE IS NOT NULL)
    BEGIN
     SET @Ld_Birth_DATE = @Ad_Birth_DATE;
     SET @Lc_UpdateFlag_INDC = @Lc_Yes_INDC;
    END;

   IF (@Lc_UpdateFlag_INDC = @Lc_Yes_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT HDEMO_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR);
     
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
             MotherMaiden_NAME,
             TypeOccupation_CODE,
             CountyBirth_IDNO,
             FileLastDivorce_ID,
             IveParty_IDNO,
             FacialHair_INDC,
             TribalAffiliations_CODE,
             FormerMci_IDNO,
             StateDivorce_CODE,
             CityDivorce_NAME,
             StateMarriage_CODE,
             CityMarriage_NAME)
     SELECT a.MemberMci_IDNO,
            a.Individual_IDNO,
            a.Last_NAME,
            a.First_NAME,
            a.Middle_NAME,
            a.Suffix_NAME,
            a.Title_NAME,
            a.FullDisplay_NAME,
            a.MemberSex_CODE,
            a.MemberSsn_NUMB,
            a.Birth_DATE,
            a.Emancipation_DATE,
            a.LastMarriage_DATE,
            a.LastDivorce_DATE,
            a.BirthCity_NAME,
            a.BirthState_CODE,
            a.BirthCountry_CODE,
            a.DescriptionHeight_TEXT,
            a.DescriptionWeightLbs_TEXT,
            a.Race_CODE,
            a.ColorHair_CODE,
            a.ColorEyes_CODE,
            a.Language_CODE,
            a.TypeProblem_CODE,
            a.Deceased_DATE,
            a.CerDeathNo_TEXT,
            a.LicenseDriverNo_TEXT,
            a.AlienRegistn_ID,
            a.WorkPermitNo_TEXT,
            a.BeginPermit_DATE,
            a.EndPermit_DATE,
            a.HomePhone_NUMB,
            a.WorkPhone_NUMB,
            a.CellPhone_NUMB,
            a.Fax_NUMB,
            a.Contact_EML,
            a.Spouse_NAME,
            a.Graduation_DATE,
            a.EducationLevel_CODE,
            a.Restricted_INDC,
            a.Military_ID,
            a.MilitaryBranch_CODE,
            a.MilitaryStatus_CODE,
            a.MilitaryBenefitStatus_CODE,
            a.SecondFamily_INDC,
            a.MeansTestedInc_INDC,
            a.SsIncome_INDC,
            a.VeteranComps_INDC,
            a.Disable_INDC,
            a.Assistance_CODE,
            a.DescriptionIdentifyingMarks_TEXT,
            a.Divorce_INDC,
            a.BeginValidity_DATE,
            @Ad_Process_DATE AS EndValidity_DATE,
            a.WorkerUpdate_ID,
            a.TransactionEventSeq_NUMB,
            a.Update_DTTM,
            a.MotherMaiden_NAME,
            a.TypeOccupation_CODE,
            a.CountyBirth_IDNO,
            a.FileLastDivorce_ID,
            a.IveParty_IDNO,
            a.FacialHair_INDC,
            a.TribalAffiliations_CODE,
            a.FormerMci_IDNO,
            a.StateDivorce_CODE,
            a.CityDivorce_NAME,
            a.StateMarriage_CODE,
            a.CityMarriage_NAME
       FROM DEMO_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO HDEMO FAILED';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL('N','')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Process_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);

       RETURN;
      END;

     SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1 ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR);

     UPDATE DEMO_Y1
        SET BirthCity_NAME = @Lc_BirthCity_NAME,
            HomePhone_NUMB = @Ln_HomePhone_NUMB,
            WorkPhone_NUMB = @Ln_WorkPhone_NUMB,
            CellPhone_NUMB = @Ln_CellPhone_NUMB,
            Birth_DATE = @Ld_Birth_DATE,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
            BeginValidity_DATE = @Ad_Process_DATE,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
      WHERE MemberMci_IDNO = @An_MemberMci_IDNO;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO DEMO FAILED';

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
  END CATCH;
 END;


GO
