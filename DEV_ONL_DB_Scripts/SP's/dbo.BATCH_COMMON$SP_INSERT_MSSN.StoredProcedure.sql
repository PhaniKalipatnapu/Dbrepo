/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_MSSN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_MSSN
Programmer Name		: IMP Team
Description			: This procedure is used to update SSN
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_MSSN] (
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_MemberSsn_NUMB        NUMERIC(9),
 @Ac_Enumeration_CODE      CHAR(1),
 @Ac_TypePrimary_CODE      CHAR(1) = NULL,
 @Ad_BeginValidity_DATE    DATE,
 @Ac_Process_ID            CHAR(10),
 @Ac_WorkerUpdate_ID       CHAR(30),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_SsnTypePrimary_CODE   CHAR(1) = 'P',
          @Lc_SsnTypeSecondary_CODE CHAR(1) = 'S',
          @Lc_SsnTypeItin_CODE      CHAR(1) = 'I',
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSucess_CODE     CHAR(1) = 'S',
          @Lc_ConfirmedGood_CODE    CHAR(1) = 'Y',
          @Lc_VerifiPending_CODE    CHAR(1) = 'P',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_COMMON$SP_INSERT_MSSN',
          @Ld_High_DATE             DATE = '12/31/9999',
          @Ld_Current_DATE          DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_RowsCount_QNTY           NUMERIC,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_Primary_CODE             CHAR(1),
          @Lc_Msg_CODE                 CHAR(1),
          @Ls_Sql_TEXT                 VARCHAR(200),
          @Ls_Sqldata_TEXT             VARCHAR(2000),
          @Ls_ErrorMessage_TEXT        VARCHAR(2000);

  BEGIN TRY
   IF (NOT EXISTS (SELECT TOP 1 *
                     FROM MSSN_Y1 a
                    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND a.MemberSsn_NUMB = @An_MemberSsn_NUMB
                      AND a.EndValidity_DATE = @Ld_High_DATE))
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR MemberSsn_NUMB ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ' FAILED';
	 SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_BeginValidity_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL('N','')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');
	 
     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_BeginValidity_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_TypePrimary_CODE IS NULL
      BEGIN
       IF (EXISTS (SELECT TOP 1 *
                     FROM MSSN_Y1 a
                    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND a.TypePrimary_CODE = @Lc_SsnTypePrimary_CODE
                      AND a.EndValidity_DATE = @Ld_High_DATE))
        BEGIN
         SET @Lc_Primary_CODE = @Lc_SsnTypeSecondary_CODE;
        END;
       ELSE
        BEGIN
         SET @Lc_Primary_CODE = @Lc_SsnTypePrimary_CODE;
        END;
      END
     ELSE
      BEGIN
       SET @Lc_Primary_CODE = @Ac_TypePrimary_CODE;
      END;

     SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR MemberSsn_NUMB';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', MemberSsn_NUMB = ' + ISNULL(CAST( @An_MemberSsn_NUMB AS VARCHAR ),'')+ ', Enumeration_CODE = ' + ISNULL(@Ac_Enumeration_CODE,'')+ ', TypePrimary_CODE = ' + ISNULL(@Lc_Primary_CODE,'')+ ', SourceVerify_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_DATE = ' + ISNULL(CAST( @Ad_BeginValidity_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_BeginValidity_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'');

     INSERT MSSN_Y1
            (MemberMci_IDNO,
             MemberSsn_NUMB,
             Enumeration_CODE,
             TypePrimary_CODE,
             SourceVerify_CODE,
             Status_DATE,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             TransactionEventSeq_NUMB,
             Update_DTTM)
     VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
              @An_MemberSsn_NUMB,--MemberSsn_NUMB
              @Ac_Enumeration_CODE,--Enumeration_CODE
              @Lc_Primary_CODE,--TypePrimary_CODE
              @Lc_Space_TEXT,--SourceVerify_CODE
              @Ad_BeginValidity_DATE,--Status_DATE
              @Ad_BeginValidity_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
              @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()); --Update_DTTM
     SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO MSSN_Y1 FOR THE MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), ' ') + ' FAILED ';

       RAISERROR(50001,16,1);
      END;
    END;

   IF (@Lc_Primary_CODE = @Lc_SsnTypePrimary_CODE
       AND @Ac_Enumeration_CODE = @Lc_ConfirmedGood_CODE)
       OR (((@Lc_Primary_CODE = @Lc_SsnTypePrimary_CODE
             AND @Ac_Enumeration_CODE = @Lc_VerifiPending_CODE)
             OR (@Lc_Primary_CODE = @Lc_SsnTypeItin_CODE
                 AND @Ac_Enumeration_CODE = @Lc_ConfirmedGood_CODE))
           AND NOT EXISTS (SELECT 1
                             FROM DEMO_Y1
                            WHERE MemberMci_IDNO = @An_MemberMci_IDNO
                              AND MemberSsn_NUMB <> 0))
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1 FOR MemberSsn_NUMB ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ' FAILED';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_BeginValidity_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL('N','')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_BeginValidity_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

	 SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
	 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'');
	 
     UPDATE DEMO_Y1
        SET MemberSsn_NUMB = @An_MemberSsn_NUMB,
            BeginValidity_DATE = @Ld_Current_DATE,
            WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Current_DATE
     OUTPUT Deleted.MemberMci_IDNO,
            Deleted.Individual_IDNO,
            Deleted.Last_NAME,
            Deleted.First_NAME,
            Deleted.Middle_NAME,
            Deleted.Suffix_NAME,
            Deleted.Title_NAME,
            Deleted.FullDisplay_NAME,
            Deleted.MemberSex_CODE,
            Deleted.MemberSsn_NUMB,
            Deleted.Birth_DATE,
            Deleted.Emancipation_DATE,
            Deleted.LastMarriage_DATE,
            Deleted.LastDivorce_DATE,
            Deleted.BirthCity_NAME,
            Deleted.BirthState_CODE,
            Deleted.BirthCountry_CODE,
            Deleted.DescriptionHeight_TEXT,
            Deleted.DescriptionWeightLbs_TEXT,
            Deleted.Race_CODE,
            Deleted.ColorHair_CODE,
            Deleted.ColorEyes_CODE,
            Deleted.FacialHair_INDC,
            Deleted.Language_CODE,
            Deleted.TypeProblem_CODE,
            Deleted.Deceased_DATE,
            Deleted.CerDeathNo_TEXT,
            Deleted.LicenseDriverNo_TEXT,
            Deleted.AlienRegistn_ID,
            Deleted.WorkPermitNo_TEXT,
            Deleted.BeginPermit_DATE,
            Deleted.EndPermit_DATE,
            Deleted.HomePhone_NUMB,
            Deleted.WorkPhone_NUMB,
            Deleted.CellPhone_NUMB,
            Deleted.Fax_NUMB,
            Deleted.Contact_EML,
            Deleted.Spouse_NAME,
            Deleted.Graduation_DATE,
            Deleted.EducationLevel_CODE,
            Deleted.Restricted_INDC,
            Deleted.Military_ID,
            Deleted.MilitaryBranch_CODE,
            Deleted.MilitaryStatus_CODE,
            Deleted.MilitaryBenefitStatus_CODE,
            Deleted.SecondFamily_INDC,
            Deleted.MeansTestedInc_INDC,
            Deleted.SsIncome_INDC,
            Deleted.VeteranComps_INDC,
            Deleted.Disable_INDC,
            Deleted.Assistance_CODE,
            Deleted.DescriptionIdentifyingMarks_TEXT,
            Deleted.Divorce_INDC,
            Deleted.BeginValidity_DATE,
            @Ld_Current_DATE AS EndValidity_DATE,
            Deleted.WorkerUpdate_ID,
            Deleted.TransactionEventSeq_NUMB,
            Deleted.Update_DTTM,
            Deleted.TypeOccupation_CODE,
            Deleted.CountyBirth_IDNO,
            Deleted.MotherMaiden_NAME,
            Deleted.FileLastDivorce_ID,
            Deleted.TribalAffiliations_CODE,
            Deleted.FormerMci_IDNO,
            Deleted.StateDivorce_CODE,
            Deleted.CityDivorce_NAME,
            Deleted.StateMarriage_CODE,
            Deleted.CityMarriage_NAME,
            Deleted.IveParty_IDNO
     INTO HDEMO_Y1
      WHERE DEMO_Y1.MemberMci_IDNO = @An_MemberMci_IDNO;

     SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE DEMO_Y1 FOR MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ' FAILED';

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSucess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
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

  END CATCH;
 END;


GO
