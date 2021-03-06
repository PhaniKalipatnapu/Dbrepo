/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_MINS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_MINS_UPDATE
Programmer Name		: IMP Team
Description			: This procedure updates the given member insurance details into MINS_Y1 table.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_MINS_UPDATE]
 @An_MemberMci_IDNO                NUMERIC(10),
 @Ad_Run_DATE                      DATE,
 @An_OthpInsurance_IDNO            NUMERIC(9),
 @Ac_InsuranceGroupNo_TEXT         CHAR(25),
 @Ac_PolicyInsNo_TEXT              CHAR(20),
 @Ac_InsSource_CODE                CHAR(3),
 @Ac_DentalIns_INDC                CHAR(1),
 @Ac_MedicalIns_INDC               CHAR(1),
 @Ac_MentalIns_INDC                CHAR(1),
 @Ac_PrescptIns_INDC               CHAR(1),
 @Ac_VisionIns_INDC                CHAR(1),
 @Ac_OtherIns_INDC                 CHAR(1),
 @As_DescriptionOtherIns_TEXT      VARCHAR(50),
 @Ad_Begin_DATE                    DATE,
 @Ac_EmployerPaid_INDC             CHAR(1),
 @An_OthpEmployer_IDNO             NUMERIC(9),
 @An_MedicalMonthlyPremium_AMNT    NUMERIC(11, 2),
 @An_CoPay_AMNT                    NUMERIC(11, 2),
 @Ad_End_DATE                      DATE,
 @Ac_PolicyHolderRelationship_CODE CHAR(2) = ' ',
 @As_PolicyHolder_NAME             VARCHAR(62) = ' ',
 @An_PolicyHolderSsn_NUMB          NUMERIC(9) = 0,
 @Ad_BirthPolicyHolder_DATE        DATE,
 @An_TransactionEventSeq_NUMB      NUMERIC(19) = 0,
 @Ac_Process_ID                    CHAR(10),
 @Ac_Msg_CODE                      CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT         VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE            CHAR = 'F',
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Lc_TypeOthpInsurers_CODE        CHAR(1) = 'I',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_TypePolicy_CODE              CHAR(1) = 'G',
          @Lc_MinsExists_INDC              CHAR(1) = 'N',
          @Lc_DinsChange_TEXT              CHAR(1) = 'N',
          @Lc_RelationshipPolicyOther_CODE CHAR(2) = 'OT',
          @Lc_RelationshipPolicySelf_CODE  CHAR(2) = 'SF',
          @Lc_VerifyStatusConfirmGood_CODE CHAR(2) = 'CG',
          @Lc_VerifyStatusVerPending_CODE  CHAR(2) = 'VP',
          @Lc_InsSourceFederalCases_CODE   CHAR(2) = 'FC',
          @Lc_ErrorE0958_CODE              CHAR(5) = 'E0862',
          @Lc_ErrorE0862_CODE              CHAR(5) = 'E0862',
          @Lc_ErrorE0879_CODE              CHAR(5) = 'E0879',
          @Lc_ErrorE0152_CODE              CHAR(5) = 'E0152',
          @Lc_Successful_TEXT              CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT            CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_COMMON$SP_MINS_UPDATE',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001';
  DECLARE @Ln_Rowcount_QNTY                 NUMERIC,
          @Ln_FetchStatus_QNTY               NUMERIC,
          @Ln_Error_NUMB                    NUMERIC,
          @Ln_Count_NUMB                    NUMERIC(4),
          @Ln_PolicyHolderSsn_NUMB          NUMERIC(9),
          @Ln_ErrorLine_NUMB                NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB      NUMERIC(19),
          @Lc_SpecialNeeds_INDC             CHAR(1),
          @Lc_NonQualified_CODE             CHAR(1),
          @Lc_MedicalIns_INDC               CHAR(1),
          @Lc_DentalIns_INDC                CHAR(1),
          @Lc_MentalIns_INDC                CHAR(1),
          @Lc_VisionIns_INDC                CHAR(1),
          @Lc_PrescptIns_INDC               CHAR(1),
          @Lc_OtherIns_INDC                 CHAR(1),
          @Lc_PolicyHolderRelationship_CODE CHAR(2),
          @Lc_SourceStatus_CODE				CHAR(2),
          @Lc_Msg_CODE                      CHAR(5),
          @Ls_Contact_NAME                  VARCHAR(45),
          @Ls_PolicyHolder_NAME             VARCHAR(62),
          @Ls_Sql_TEXT                      VARCHAR(100) = '',
          @Ls_DescriptionCoverage_TEXT      VARCHAR(160),
          @Ls_Sqldata_TEXT                  VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT             VARCHAR(4000) = '',
          @Ld_BirthPolicyHolder_DATE        DATE,
          @Ld_End_DATE                      DATE,
          @Ld_Begin_DATE                    DATE;
  DECLARE @Ln_DinsCur_MemberMci_IDNO         NUMERIC(10),
          @Ln_DinsCur_OthpInsurance_IDNO     NUMERIC(9),
          @Lc_DinsCur_InsuranceGroupNo_TEXT  CHAR(25),
          @Lc_DinsCur_PolicyInsNo_TEXT       CHAR(20),
          @Ln_DinsCur_ChildMCI_IDNO          NUMERIC(10),
          @Ld_DinsCur_Begin_DATE             DATE,
          @Lc_DinsCur_DentalIns_INDC         CHAR(1),
          @Lc_DinsCur_MedicalIns_INDC        CHAR(1),
          @Lc_DinsCur_MentalIns_INDC         CHAR(1),
          @Lc_DinsCur_PrescptIns_INDC        CHAR(1),
          @Lc_DinsCur_VisionIns_INDC         CHAR(1),
          @Ls_DinsCur_DescriptionOthers_TEXT VARCHAR(50),
          @Ld_DinsCur_End_DATE               DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ad_End_DATE = ISNULL (@Ad_End_DATE, @Ld_High_DATE);
   SET @Ad_BirthPolicyHolder_DATE = ISNULL (@Ad_BirthPolicyHolder_DATE, @Ld_Low_DATE);
   
   IF ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsSource_CODE), @Lc_Space_TEXT) = @Lc_InsSourceFederalCases_CODE
     BEGIN
		SET @Lc_SourceStatus_CODE = @Lc_VerifyStatusVerPending_CODE;
     END 
   ELSE
     BEGIN
		SET @Lc_SourceStatus_CODE = @Lc_VerifyStatusConfirmGood_CODE;
     END   
   
   IF ((dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyInsNo_TEXT) IS NULL
        AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsuranceGroupNo_TEXT) IS NULL)
        OR @An_MemberMci_IDNO = 0
        OR @An_OthpInsurance_IDNO = 0)
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0958_CODE;
     SET @As_DescriptionError_TEXT = 'KEY DATA NOT FOUND';

     RETURN;
    END

   IF @Ad_End_DATE IS NOT NULL
      AND @Ad_End_DATE < @Ad_Run_DATE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0862_CODE;
     SET @As_DescriptionError_TEXT = 'END DATE IS LESS THAN RUN DATE';

     RETURN;
    END

   IF @Ad_End_DATE IS NOT NULL
      AND @Ad_Begin_DATE IS NOT NULL
      AND @Ad_End_DATE < @Ad_Begin_DATE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0879_CODE;
     SET @As_DescriptionError_TEXT = 'END DATE IS LESS THAN BEGIN DATE';

     RETURN;
    END

   BEGIN
    SET @Ls_Sql_TEXT = 'CHECK MINS RECORD EXISTS';
    SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
    
    SELECT @Lc_PolicyHolderRelationship_CODE = m.PolicyHolderRelationship_CODE,
           @Ls_DescriptionCoverage_TEXT = m.DescriptionCoverage_TEXT,
           @Ls_Contact_NAME = m.Contact_NAME,
           @Lc_SpecialNeeds_INDC = m.SpecialNeeds_INDC,
           @Lc_NonQualified_CODE = m.NonQualified_CODE,
           @Ls_PolicyHolder_NAME = m.PolicyHolder_NAME,
           @Ln_PolicyHolderSsn_NUMB = m.PolicyHolderSsn_NUMB,
           @Ld_BirthPolicyHolder_DATE = m.BirthPolicyHolder_DATE,
           @Lc_MedicalIns_INDC = m.MedicalIns_INDC,
           @Lc_DentalIns_INDC = m.DentalIns_INDC,
           @Lc_MentalIns_INDC = m.MentalIns_INDC,
           @Lc_VisionIns_INDC = m.VisionIns_INDC,
           @Lc_PrescptIns_INDC = m.PrescptIns_INDC,
           @Lc_OtherIns_INDC = m.OtherIns_INDC,
           @Ld_End_DATE = m.End_DATE,
           @Ld_Begin_DATE = m.Begin_DATE
      FROM MINS_Y1 m
     WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
       AND m.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
       AND m.InsuranceGroupNo_TEXT = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT)
       AND m.PolicyInsNo_TEXT = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT)
       AND m.EndValidity_DATE = @Ld_High_DATE
       AND m.Begin_DATE = (SELECT MAX (n.Begin_DATE)
                             FROM MINS_Y1 n
                            WHERE n.MemberMci_IDNO = m.MemberMci_IDNO
                              AND n.OthpInsurance_IDNO = m.OthpInsurance_IDNO
                              AND n.PolicyInsNo_TEXT = m.PolicyInsNo_TEXT
                              AND n.InsuranceGroupNo_TEXT = m.InsuranceGroupNo_TEXT
                              AND n.EndValidity_DATE = @Ld_High_DATE);

    SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

    IF @Ln_Rowcount_QNTY = 1
     BEGIN
      IF ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE) <= @Ld_Begin_DATE
       BEGIN
        SET @Ac_Msg_CODE = @Lc_ErrorE0152_CODE;
        SET @As_DescriptionError_TEXT = 'DINS RECORD EXISTS';

        RETURN;
       END

      IF @Lc_MedicalIns_INDC = @Ac_MedicalIns_INDC
         AND @Lc_DentalIns_INDC = @Ac_DentalIns_INDC
         AND @Lc_MentalIns_INDC = @Ac_MentalIns_INDC
         AND @Lc_VisionIns_INDC = @Ac_VisionIns_INDC
         AND @Lc_PrescptIns_INDC = @Ac_PrescptIns_INDC
         AND @Lc_OtherIns_INDC = @Ac_OtherIns_INDC
         AND ISNULL (@Ad_End_DATE, @Ld_High_DATE) <= @Ld_End_DATE
       BEGIN
        SET @Ac_Msg_CODE = @Lc_ErrorE0152_CODE;
        SET @As_DescriptionError_TEXT = 'MINS RECORD EXISTS';

        RETURN;
       END

      IF @Ld_End_DATE >= ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE)
       BEGIN
        SET @Ls_Sql_TEXT = 'UPDATE MINS_Y1 - 1';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', Begin_DATE = ' + ISNULL(CAST( @Ld_Begin_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
        
        UPDATE MINS_Y1
           SET End_DATE = DATEADD (D, -1, ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE))
         WHERE MINS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
           AND MINS_Y1.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
           AND MINS_Y1.InsuranceGroupNo_TEXT = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT)
           AND MINS_Y1.PolicyInsNo_TEXT = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT)
           AND MINS_Y1.Begin_DATE = @Ld_Begin_DATE
           AND MINS_Y1.End_DATE >= ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE)
           AND MINS_Y1.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'UPDATE MINS FAILED';

          RAISERROR (50001,16,1);
         END

        SET @Lc_MinsExists_INDC = @Lc_Yes_INDC;
       END
     END
    ELSE IF @Ln_Rowcount_QNTY = 0
     BEGIN
      SET @Lc_PolicyHolderRelationship_CODE = @Lc_Space_TEXT;
      SET @Ls_Contact_NAME = @Lc_Space_TEXT;
      SET @Lc_SpecialNeeds_INDC = @Lc_Space_TEXT;
      SET @Lc_NonQualified_CODE = @Lc_Space_TEXT;
      SET @Ls_PolicyHolder_NAME = @Lc_Space_TEXT;
      SET @Ln_PolicyHolderSsn_NUMB = 0;
      SET @Ld_BirthPolicyHolder_DATE = @Ld_Low_DATE;
     END
    ELSE IF @Ln_Rowcount_QNTY > 1
     BEGIN
      SET @Ls_ErrorMessage_TEXT = 'TOO MANY ROWS IN MINS';

      RAISERROR (50001,16,1);
     END
   END

   IF @An_TransactionEventSeq_NUMB = 0
       OR @An_TransactionEventSeq_NUMB IS NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
    END

   BEGIN
    SET @Ls_Sql_TEXT = 'CHECK OtherParty_IDNO FOR INSURANCE';
    SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpInsurers_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

    SELECT @Ln_Count_NUMB = 1
      FROM OTHP_Y1 o
     WHERE o.OtherParty_IDNO = @An_OthpInsurance_IDNO
       AND o.TypeOthp_CODE = @Lc_TypeOthpInsurers_CODE
       AND o.EndValidity_DATE = @Ld_High_DATE;

    SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

    IF @Ln_Rowcount_QNTY = 0
     BEGIN
      SET @Ls_ErrorMessage_TEXT = 'RECORD NOT FOUND IN OTHP1';

      RAISERROR (50001,16,1);
     END
   END

   IF @An_OthpEmployer_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'CHECK OtherParty_IDNO FOR EMPLOYER';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST( @An_OthpEmployer_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_Count_NUMB = 1
       FROM OTHP_Y1 o
      WHERE o.OtherParty_IDNO = @An_OthpEmployer_IDNO
        AND o.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'RECORD NOT FOUND IN OTHP2';

       RAISERROR (50001,16,1);
      END
    END

   -- Setting Policy Holder information only if Policy Holder Relation is OT - Other
   IF ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyHolderRelationship_CODE), @Lc_PolicyHolderRelationship_CODE) = @Lc_RelationshipPolicyOther_CODE
    BEGIN
     SET @Ls_PolicyHolder_NAME = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@As_PolicyHolder_NAME), @Ls_PolicyHolder_NAME);

     IF @An_PolicyHolderSsn_NUMB <> 0
      BEGIN
       SET @Ln_PolicyHolderSsn_NUMB = @An_PolicyHolderSsn_NUMB;
      END

     SET @Ld_BirthPolicyHolder_DATE = ISNULL (@Ad_BirthPolicyHolder_DATE, @Ld_BirthPolicyHolder_DATE);
    END
   ELSE
    BEGIN
     SET @Ls_PolicyHolder_NAME = @Lc_Space_TEXT;
     SET @Ln_PolicyHolderSsn_NUMB = 0;
     SET @Ld_BirthPolicyHolder_DATE = @Ld_Low_DATE;
     SET @Lc_PolicyHolderRelationship_CODE = @Lc_RelationshipPolicySelf_CODE;
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO MINS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_SourceStatus_CODE,'')+ ', Status_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', TypePolicy_CODE = ' + ISNULL(@Lc_TypePolicy_CODE,'')+ ', DescriptionCoverage_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', MonthlyPremium_AMNT = ' + ISNULL(CAST( @An_MedicalMonthlyPremium_AMNT AS VARCHAR ),'')+ ', Contact_NAME = ' + ISNULL(@Ls_Contact_NAME,'')+ ', SpecialNeeds_INDC = ' + ISNULL(@Lc_SpecialNeeds_INDC,'')+ ', NonQualified_CODE = ' + ISNULL(@Lc_NonQualified_CODE,'')+ ', PolicyHolder_NAME = ' + ISNULL(@Ls_PolicyHolder_NAME,'')+ ', PolicyHolderSsn_NUMB = ' + ISNULL(CAST( @Ln_PolicyHolderSsn_NUMB AS VARCHAR ),'')+ ', BirthPolicyHolder_DATE = ' + ISNULL(CAST( @Ld_BirthPolicyHolder_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', PolicyAnnivMonth_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

   INSERT MINS_Y1
          (MemberMci_IDNO,
           OthpInsurance_IDNO,
           InsuranceGroupNo_TEXT,
           PolicyInsNo_TEXT,
           Begin_DATE,
           End_DATE,
           InsSource_CODE,
           Status_CODE,
           Status_DATE,
           SourceVerified_CODE,
           PolicyHolderRelationship_CODE,
           TypePolicy_CODE,
           EmployerPaid_INDC,
           DescriptionCoverage_TEXT,
           MonthlyPremium_AMNT,
           Contact_NAME,
           SpecialNeeds_INDC,
           OtherIns_INDC,
           DescriptionOtherIns_TEXT,
           MedicalIns_INDC,
           CoPay_AMNT,
           DentalIns_INDC,
           VisionIns_INDC,
           PrescptIns_INDC,
           MentalIns_INDC,
           OthpEmployer_IDNO,
           NonQualified_CODE,
           PolicyHolder_NAME,
           PolicyHolderSsn_NUMB,
           BirthPolicyHolder_DATE,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           PolicyAnnivMonth_CODE)
   VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
            @An_OthpInsurance_IDNO,--OthpInsurance_IDNO
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT),--InsuranceGroupNo_TEXT
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT),--PolicyInsNo_TEXT
            ISNULL (@Ad_Begin_DATE, @Ad_Run_DATE),--Begin_DATE
            ISNULL (@Ad_End_DATE, @Ld_High_DATE),--End_DATE
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsSource_CODE), @Lc_Space_TEXT),--InsSource_CODE
            @Lc_SourceStatus_CODE,--Status_CODE
            @Ad_Run_DATE,--Status_DATE
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsSource_CODE), @Lc_Space_TEXT),--SourceVerified_CODE
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyHolderRelationship_CODE), @Lc_PolicyHolderRelationship_CODE),--PolicyHolderRelationship_CODE
            @Lc_TypePolicy_CODE,--TypePolicy_CODE
            ISNULL (@Ac_EmployerPaid_INDC, @Lc_Space_TEXT),--EmployerPaid_INDC
            @Lc_Space_TEXT,--DescriptionCoverage_TEXT
            @An_MedicalMonthlyPremium_AMNT,--MonthlyPremium_AMNT
            @Ls_Contact_NAME,--Contact_NAME
            @Lc_SpecialNeeds_INDC,--SpecialNeeds_INDC
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_OtherIns_INDC), @Lc_No_INDC),--OtherIns_INDC
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@As_DescriptionOtherIns_TEXT), @Lc_Space_TEXT),--DescriptionOtherIns_TEXT
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_MedicalIns_INDC), @Lc_No_INDC),--MedicalIns_INDC
            ISNULL (@An_CoPay_AMNT, 0),--CoPay_AMNT
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_DentalIns_INDC), @Lc_No_INDC),--DentalIns_INDC
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_VisionIns_INDC), @Lc_No_INDC),--VisionIns_INDC
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PrescptIns_INDC), @Lc_No_INDC),--PrescptIns_INDC
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_MentalIns_INDC), @Lc_No_INDC),--MentalIns_INDC
            ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@An_OthpEmployer_IDNO), @Lc_Space_TEXT),--OthpEmployer_IDNO
            @Lc_NonQualified_CODE,--NonQualified_CODE
            -- Assigning the derived values
            @Ls_PolicyHolder_NAME,--PolicyHolder_NAME
            @Ln_PolicyHolderSsn_NUMB,--PolicyHolderSsn_NUMB
            @Ld_BirthPolicyHolder_DATE,--BirthPolicyHolder_DATE
            @Ad_Run_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
            @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            @Lc_Space_TEXT); --PolicyAnnivMonth_CODE
   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT MINS FAILED';

     RAISERROR (50001,16,1);
    END

   IF @Lc_MinsExists_INDC = @Lc_Yes_INDC
    BEGIN
     -- Program corrected to insert insurance information with latest begin date
     -- It wont insert insurance record until any change happened in insurance.
     -- cursor to read the dependent insurance details
     DECLARE Dins_CUR INSENSITIVE CURSOR FOR
      SELECT d.MemberMci_IDNO,
             d.OthpInsurance_IDNO,
             d.InsuranceGroupNo_TEXT,
             d.PolicyInsNo_TEXT,
             d.ChildMCI_IDNO,
             d.Begin_DATE,
             d.DentalIns_INDC,
             d.MedicalIns_INDC,
             d.MentalIns_INDC,
             d.PrescptIns_INDC,
             d.VisionIns_INDC,
             d.DescriptionOthers_TEXT,
             d.End_DATE
        FROM DINS_Y1 d
       WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
         AND d.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
         AND d.InsuranceGroupNo_TEXT = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsuranceGroupNo_TEXT), ' ')
         AND d.PolicyInsNo_TEXT = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_PolicyInsNo_TEXT), ' ')
         AND d.End_DATE >= @Ad_Run_DATE
         AND d.EndValidity_DATE = @Ld_High_DATE
         AND d.Begin_DATE = (SELECT MAX (n.Begin_DATE)
                               FROM DINS_Y1 n
                              WHERE n.MemberMci_IDNO = d.MemberMci_IDNO
                                AND n.OthpInsurance_IDNO = d.OthpInsurance_IDNO
                                AND n.PolicyInsNo_TEXT = d.PolicyInsNo_TEXT
                                AND n.InsuranceGroupNo_TEXT = d.InsuranceGroupNo_TEXT
                                AND n.ChildMCI_IDNO = d.ChildMCI_IDNO
                                AND n.EndValidity_DATE = @Ld_High_DATE);

     OPEN Dins_CUR;

     FETCH NEXT FROM Dins_CUR INTO @Ln_DinsCur_MemberMci_IDNO, @Ln_DinsCur_OthpInsurance_IDNO, @Lc_DinsCur_InsuranceGroupNo_TEXT, @Lc_DinsCur_PolicyInsNo_TEXT, @Ln_DinsCur_ChildMCI_IDNO, @Ld_DinsCur_Begin_DATE, @Lc_DinsCur_DentalIns_INDC, @Lc_DinsCur_MedicalIns_INDC, @Lc_DinsCur_MentalIns_INDC, @Lc_DinsCur_PrescptIns_INDC, @Lc_DinsCur_VisionIns_INDC, @Ls_DinsCur_DescriptionOthers_TEXT, @Ld_DinsCur_End_DATE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     BEGIN
      --FETCH EACH RECORD
      WHILE @Ln_FetchStatus_QNTY = 0
       BEGIN
        IF @Ac_DentalIns_INDC = @Lc_No_INDC
           AND @Lc_DinsCur_DentalIns_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Lc_DinsChange_TEXT = @Lc_Yes_INDC;
          SET @Lc_DinsCur_DentalIns_INDC = @Lc_No_INDC;
         END

        IF @Ac_MentalIns_INDC = @Lc_No_INDC
           AND @Lc_DinsCur_MentalIns_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Lc_DinsChange_TEXT = @Lc_Yes_INDC;
          SET @Lc_DinsCur_MentalIns_INDC = @Lc_No_INDC;
         END

        IF @Ac_MedicalIns_INDC = @Lc_No_INDC
           AND @Lc_DinsCur_MedicalIns_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Lc_DinsChange_TEXT = @Lc_Yes_INDC;
          SET @Lc_DinsCur_MedicalIns_INDC = @Lc_No_INDC;
         END

        IF @Ac_PrescptIns_INDC = @Lc_No_INDC
           AND @Lc_DinsCur_PrescptIns_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Lc_DinsChange_TEXT = @Lc_Yes_INDC;
          SET @Lc_DinsCur_PrescptIns_INDC = @Lc_No_INDC;
         END

        IF @Ac_VisionIns_INDC = @Lc_No_INDC
           AND @Lc_DinsCur_VisionIns_INDC = @Lc_Yes_INDC
         BEGIN
          SET @Lc_DinsChange_TEXT = @Lc_Yes_INDC;
          SET @Lc_DinsCur_VisionIns_INDC = @Lc_No_INDC;
         END

        IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@As_DescriptionOtherIns_TEXT) IS NULL
           AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ls_DinsCur_DescriptionOthers_TEXT) IS NOT NULL
         BEGIN
          SET @Lc_DinsChange_TEXT = @Lc_Yes_INDC;
          SET @Ls_DinsCur_DescriptionOthers_TEXT = @Lc_Space_TEXT;
         END

        IF @Lc_DinsChange_TEXT = @Lc_Yes_INDC
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_DINS_UPDATE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_DinsCur_MemberMci_IDNO AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @Ln_DinsCur_OthpInsurance_IDNO AS VARCHAR ),'')+ ', InsuranceGroupNo_TEXT = ' + ISNULL(@Lc_DinsCur_InsuranceGroupNo_TEXT,'')+ ', PolicyInsNo_TEXT = ' + ISNULL(@Lc_DinsCur_PolicyInsNo_TEXT,'')+ ', ChildMCI_IDNO = ' + ISNULL(CAST( @Ln_DinsCur_ChildMCI_IDNO AS VARCHAR ),'')+ ', Begin_DATE = ' + ISNULL(CAST( @Ld_DinsCur_Begin_DATE AS VARCHAR ),'')+ ', InsSource_CODE = ' + ISNULL(@Ac_InsSource_CODE,'')+ ', DentalIns_INDC = ' + ISNULL(@Lc_DinsCur_DentalIns_INDC,'')+ ', MedicalIns_INDC = ' + ISNULL(@Lc_DinsCur_MedicalIns_INDC,'')+ ', MentalIns_INDC = ' + ISNULL(@Lc_DinsCur_MentalIns_INDC,'')+ ', PrescptIns_INDC = ' + ISNULL(@Lc_DinsCur_PrescptIns_INDC,'')+ ', VisionIns_INDC = ' + ISNULL(@Lc_DinsCur_VisionIns_INDC,'')+ ', DescriptionOthers_TEXT = ' + ISNULL(@Ls_DinsCur_DescriptionOthers_TEXT,'')+ ', End_DATE = ' + ISNULL(CAST( @Ld_DinsCur_End_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'');

          EXECUTE BATCH_COMMON$SP_DINS_UPDATE
           @An_MemberMci_IDNO           = @Ln_DinsCur_MemberMci_IDNO,
           @Ad_Run_DATE                 = @Ad_Run_DATE,
           @An_OthpInsurance_IDNO       = @Ln_DinsCur_OthpInsurance_IDNO,
           @Ac_InsuranceGroupNo_TEXT    = @Lc_DinsCur_InsuranceGroupNo_TEXT,
           @Ac_PolicyInsNo_TEXT         = @Lc_DinsCur_PolicyInsNo_TEXT,
           @An_ChildMCI_IDNO            = @Ln_DinsCur_ChildMCI_IDNO,
           @Ad_Begin_DATE               = @Ld_DinsCur_Begin_DATE,
           @Ac_InsSource_CODE           = @Ac_InsSource_CODE,
           @Ac_DentalIns_INDC           = @Lc_DinsCur_DentalIns_INDC,
           @Ac_MedicalIns_INDC          = @Lc_DinsCur_MedicalIns_INDC,
           @Ac_MentalIns_INDC           = @Lc_DinsCur_MentalIns_INDC,
           @Ac_PrescptIns_INDC          = @Lc_DinsCur_PrescptIns_INDC,
           @Ac_VisionIns_INDC           = @Lc_DinsCur_VisionIns_INDC,
           @As_DescriptionOthers_TEXT   = @Ls_DinsCur_DescriptionOthers_TEXT,
           @Ad_End_DATE                 = @Ld_DinsCur_End_DATE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_Process_ID               = @Ac_Process_ID,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        FETCH NEXT FROM Dins_CUR INTO @Ln_DinsCur_MemberMci_IDNO, @Ln_DinsCur_OthpInsurance_IDNO, @Lc_DinsCur_InsuranceGroupNo_TEXT, @Lc_DinsCur_PolicyInsNo_TEXT, @Ln_DinsCur_ChildMCI_IDNO, @Ld_DinsCur_Begin_DATE, @Lc_DinsCur_DentalIns_INDC, @Lc_DinsCur_MedicalIns_INDC, @Lc_DinsCur_MentalIns_INDC, @Lc_DinsCur_PrescptIns_INDC, @Lc_DinsCur_VisionIns_INDC, @Ls_DinsCur_DescriptionOthers_TEXT, @Ld_DinsCur_End_DATE;

        SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
       END
     END

     CLOSE Dins_CUR;

     DEALLOCATE Dins_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Successful_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
	IF CURSOR_STATUS('Local', 'Dins_CUR') IN (0,1)
	  BEGIN
		 CLOSE Dins_CUR;

		 DEALLOCATE Dins_CUR;
	  END
  
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

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
