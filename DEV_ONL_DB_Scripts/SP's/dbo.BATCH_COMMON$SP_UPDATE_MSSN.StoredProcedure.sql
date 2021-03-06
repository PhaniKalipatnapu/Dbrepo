/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_MSSN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_MSSN
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_MSSN] (
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_MemberSsn_NUMB           NUMERIC(9),
 @Ac_Enumeration_CODE         CHAR(1),
 @Ac_TypePrimary_CODE         CHAR(1) = NULL,
 @Ac_SourceVerify_CODE        CHAR(3) = '',
 @Ad_Run_DATE                 DATE,
 @Ac_Process_ID               CHAR(10),
 @Ac_WorkerUpdate_ID          CHAR(30) = NULL,
 @Ac_SignedOnWorker_ID        CHAR(30) = NULL,
 @An_TransactionEventSeq_NUMB NUMERIC(19) = 0,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_MemberSsnAdded5230_NUMB     INT = 5230,
           @Li_MemberSsnModified5240_NUMB  INT = 5240,
           @Lc_SsnTypePrimary_CODE         CHAR(1) = 'P',
           @Lc_SsnTypeSecondary_CODE       CHAR(1) = 'S',
           @Lc_SsnTypeItin_CODE            CHAR(1) = 'I',
           @Lc_Space_TEXT                  CHAR(1) = ' ',
           @Lc_StatusFailed_CODE           CHAR(1) = 'F',
           @Lc_StatusSucess_CODE           CHAR(1) = 'S',
           @Lc_ConfirmedGood_CODE          CHAR(1) = 'Y',
           @Lc_VerifiPending_CODE          CHAR(1) = 'P',
           @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
           @Lc_BatchRunUser_ID             CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_COMMON$SP_UPDATE_MSSN',
           @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE  @Ln_SsnCount_QNTY             NUMERIC(5),
           @Ln_RowsCount_QNTY            NUMERIC(5),
           @Ln_VefifiedMemberSsn_NUMB    NUMERIC(9),
           @Ln_Error_NUMB                NUMERIC(11),
           @Ln_ErrorLine_NUMB            NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB  NUMERIC(19) = 0,
           @Lc_Primary_CODE              CHAR(1),
           @Lc_Enumeration_CODE          CHAR(1),
           @Lc_EnumerationOld_CODE       CHAR(1),
           @Lc_Msg_CODE                  CHAR(5),
           @Ls_Sql_TEXT                  VARCHAR(200),
           @Ls_Sqldata_TEXT              VARCHAR(2000),
           @Ls_ErrorMessage_TEXT         VARCHAR(2000),
           @Ld_Current_DTTM              DATETIME2;

  BEGIN TRY
   SET @Ac_SignedonWorker_ID = LTRIM(RTRIM(@Ac_SignedonWorker_ID));
   SET @Ld_Current_DTTM = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   IF (@Ac_SignedonWorker_ID IS NOT NULL
       AND @Ac_SignedonWorker_ID != '')
    BEGIN
     SET @Ac_WorkerUpdate_ID = @Ac_SignedonWorker_ID;
    END

   IF @An_TransactionEventSeq_NUMB = 0
    BEGIN
     IF (EXISTS (SELECT TOP 1 a.MemberMci_IDNO
                   FROM MSSN_Y1 a
                  WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                    AND a.MemberSsn_NUMB = @An_MemberSsn_NUMB
                    AND a.Enumeration_CODE = @Lc_ConfirmedGood_CODE
                    AND a.EndValidity_DATE = @Ld_High_DATE))
      BEGIN
       /*SSN ALREADY EXISTS IN THE SYSTEM*/
       SET @Ac_Msg_CODE = 'E0899';

       RETURN;
      END
      
      /*Confirmed Good SSN Already exists*/
	  IF (EXISTS (SELECT TOP 1 a.MemberMci_IDNO
						FROM MSSN_Y1 a
						WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
						  AND a.Enumeration_CODE = @Lc_ConfirmedGood_CODE
						  AND a.TypePrimary_CODE = @Ac_TypePrimary_CODE
						  AND a.EndValidity_DATE = @Ld_High_DATE))
		BEGIN
				/*SSN ALREADY EXISTS IN THE SYSTEM*/
				SET @Ac_Msg_CODE = 'E0900';
			RETURN;
		END


     IF @Ac_Process_ID = @Lc_BatchRunUser_ID
      BEGIN
       ---CHECKS THE SSN HIERARCHY TO GET SSN TYPE
       SET @Ls_Sql_TEXT = 'CHECKS THE SSN HIERARCHY TO GET SSN TYPE 1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Enumeration_CODE = ' + ISNULL(@Lc_ConfirmedGood_CODE,'')+ ', TypePrimary_CODE = ' + ISNULL(@Lc_SsnTypePrimary_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT @Ln_SsnCount_QNTY = COUNT(a.MemberMci_IDNO)
         FROM MSSN_Y1 a
        WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
          AND a.Enumeration_CODE = @Lc_ConfirmedGood_CODE
          AND a.TypePrimary_CODE = @Lc_SsnTypePrimary_CODE
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Lc_Enumeration_CODE = @Ac_Enumeration_CODE;
       SET @Lc_Primary_CODE = @Lc_SsnTypePrimary_CODE;

       IF @Ln_SsnCount_QNTY > 0
           OR @Ac_TypePrimary_CODE = @Lc_SsnTypeSecondary_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'CHECKS THE SSN HIERARCHY TO GET SSN TYPE 2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Enumeration_CODE = ' + ISNULL(@Lc_ConfirmedGood_CODE,'')+ ', TypePrimary_CODE = ' + ISNULL(@Lc_SsnTypeSecondary_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT @Ln_SsnCount_QNTY = COUNT(a.MemberMci_IDNO)
           FROM MSSN_Y1 a
          WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
            AND a.Enumeration_CODE = @Lc_ConfirmedGood_CODE
            AND a.TypePrimary_CODE = @Lc_SsnTypeSecondary_CODE
            AND a.EndValidity_DATE = @Ld_High_DATE;

         SET @Lc_Enumeration_CODE = @Lc_ConfirmedGood_CODE;
         SET @Lc_Primary_CODE = @Lc_SsnTypeSecondary_CODE;

         IF @Ln_SsnCount_QNTY > 0
          BEGIN
           SET @Ls_Sql_TEXT = 'CHECKS THE SSN HIERARCHY TO GET SSN TYPE 3';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Enumeration_CODE = ' + ISNULL(@Lc_ConfirmedGood_CODE,'')+ ', TypePrimary_CODE = ' + ISNULL(@Lc_SsnTypeItin_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

           SELECT @Ln_SsnCount_QNTY = COUNT(a.MemberMci_IDNO)
             FROM MSSN_Y1 a
            WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
              AND a.Enumeration_CODE = @Lc_ConfirmedGood_CODE
              AND a.TypePrimary_CODE = @Lc_SsnTypeItin_CODE
              AND a.EndValidity_DATE = @Ld_High_DATE;

           SET @Lc_Enumeration_CODE = @Lc_ConfirmedGood_CODE;
           SET @Lc_Primary_CODE = @Lc_SsnTypeItin_CODE;

           IF @Ln_SsnCount_QNTY > 0
            BEGIN
             SET @Lc_Enumeration_CODE = @Lc_VerifiPending_CODE;
             SET @Lc_Primary_CODE = @Ac_TypePrimary_CODE;
            END
          END
        END
      END
     ELSE
      BEGIN
       /* Used the same input agrument for online screen*/
       SET @Lc_Enumeration_CODE = @Ac_Enumeration_CODE;
       SET @Lc_Primary_CODE = @Ac_TypePrimary_CODE;
      END

     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF SSN';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', MemberSsn_NUMB = ' + ISNULL(CAST( @An_MemberSsn_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Ln_SsnCount_QNTY = 1,
                  @Lc_EnumerationOld_CODE = a.Enumeration_CODE
       FROM MSSN_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.MemberSsn_NUMB = @An_MemberSsn_NUMB
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowsCount_QNTY = 0
      BEGIN
       SET @Ln_SsnCount_QNTY = 0;
       SET @Lc_EnumerationOld_CODE = ' ';
      END;

     IF((@Ln_SsnCount_QNTY = 1
         AND (@Lc_EnumerationOld_CODE = @Lc_VerifiPending_CODE
              AND @Lc_Enumeration_CODE = @Lc_ConfirmedGood_CODE))
         OR @Ln_SsnCount_QNTY = 0)
      BEGIN
       IF @Ln_SsnCount_QNTY = 1
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE MSSN 1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', MemberSsn_NUMB = ' + ISNULL(CAST( @An_MemberSsn_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         UPDATE a
            SET a.EndValidity_DATE = @Ad_Run_DATE
           FROM MSSN_Y1 a
          WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
            AND a.MemberSsn_NUMB = @An_MemberSsn_NUMB
            AND a.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowsCount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'UPDATE MSSN_Y1 1 FAILED';

           RAISERROR(50001,16,1);
          END;
        END

       SET @Ls_Sql_TEXT = 'GENERATE SEQ';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL('N','')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_MemberSsnAdded5230_NUMB AS VARCHAR ),'');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = 'N',
        @An_EventFunctionalSeq_NUMB  = @Li_MemberSsnAdded5230_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       --Primary SSN is not availabe we can add the new SSN as Primary
       -- otherwise add it as Secondary	
       SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', MemberSsn_NUMB = ' + ISNULL(CAST( @An_MemberSsn_NUMB AS VARCHAR ),'')+ ', Enumeration_CODE = ' + ISNULL(@Lc_Enumeration_CODE,'')+ ', TypePrimary_CODE = ' + ISNULL(@Lc_Primary_CODE,'')+ ', Status_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Update_DTTM = ' + ISNULL(CAST( @Ld_Current_DTTM AS VARCHAR ),'');

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
                @Lc_Enumeration_CODE,--Enumeration_CODE
                @Lc_Primary_CODE,--TypePrimary_CODE
                ISNULL(@Ac_SourceVerify_CODE, @Lc_Space_TEXT),--SourceVerify_CODE
                @Ad_Run_DATE,--Status_DATE
                @Ad_Run_DATE,--BeginValidity_DATE
                @Ld_High_DATE,--EndValidity_DATE
                @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
                @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                @Ld_Current_DTTM); --Update_DTTM
       SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowsCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO MSSN_Y1 FAILED';

         RAISERROR(50001,16,1);
        END;
      END
    END
   ELSE IF @An_TransactionEventSeq_NUMB > 0 -- Update MSSN 
    BEGIN
     IF (SELECT COUNT(1)
           FROM MSSN_Y1 a
          WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
			--13726 - DEMO - Multiple records with same transaction event seq number updated - START
			AND a.MemberSsn_NUMB = @An_MemberSsn_NUMB
			--13726 - DEMO - Multiple records with same transaction event seq number updated - END
            AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
            AND a.EndValidity_DATE = @Ld_High_DATE) = 0
      BEGIN
       -- This record is being added/updated by another user, please refresh screen
       SET @Ac_Msg_CODE = 'E0153';

       RETURN;
      END

     -- Generating new transaction event for update
     SET @Ls_Sql_TEXT = 'GENERATE SEQ 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL('N','')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_MemberSsnModified5240_NUMB AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = @Li_MemberSsnModified5240_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     ---Updating MSSN
     SET @Ls_Sql_TEXT = 'UPDATE MSSN_Y1 2';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE MSSN_Y1
        SET Enumeration_CODE = @Ac_Enumeration_CODE,
            TypePrimary_CODE = @Ac_TypePrimary_CODE,
            SourceVerify_CODE = @Ac_SourceVerify_CODE,
            BeginValidity_DATE = @Ad_Run_DATE,
            WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Current_DTTM
     OUTPUT DELETED.MemberMci_IDNO,
            DELETED.MemberSsn_NUMB,
            DELETED.Enumeration_CODE,
            DELETED.TypePrimary_CODE,
            DELETED.SourceVerify_CODE,
            DELETED.Status_DATE,
            DELETED.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            DELETED.WorkerUpdate_ID,
            DELETED.TransactionEventSeq_NUMB,
            DELETED.Update_DTTM
     INTO MSSN_Y1
      WHERE MemberMci_IDNO = @An_MemberMci_IDNO
		--13726 - DEMO - Multiple records with same transaction event seq number updated - START
		AND MemberSsn_NUMB = @An_MemberSsn_NUMB
		--13726 - DEMO - Multiple records with same transaction event seq number updated - END
        AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowsCount_QNTY = 0
      BEGIN
      
       SET @Ls_ErrorMessage_TEXT = 'UPDATE MSSN_Y1 2 FAILED';

       RAISERROR(50001,16,1);
      END;
    END

   -- Update DEMO with Vefified SSN 	
   IF @Ln_TransactionEventSeq_NUMB > 0
    BEGIN
     -- Getting Vefified SSN
     SET @Ln_VefifiedMemberSsn_NUMB = DBO.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN(@An_MemberMci_IDNO);

     --Updating SSN in DEMO table
     IF NOT EXISTS (SELECT a.MemberMci_IDNO
                      FROM DEMO_Y1 a
                     WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                       AND a.MemberSsn_NUMB = @Ln_VefifiedMemberSsn_NUMB)
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'');

       UPDATE DEMO_Y1
          SET MemberSsn_NUMB = @Ln_VefifiedMemberSsn_NUMB,
              BeginValidity_DATE = @Ad_Run_DATE,
              WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
              TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              Update_DTTM = @Ld_Current_DTTM
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
              @Ad_Run_DATE AS EndValidity_DATE,
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
         SET @Ls_ErrorMessage_TEXT = 'UPDATE DEMO_Y1 FAILED';

         RAISERROR(50001,16,1);
        END;
      END;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSucess_CODE;
   SET @As_DescriptionError_TEXT = ' ';
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
