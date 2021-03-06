/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_DINS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_DINS_UPDATE
Programmer Name		: IMP Team
Description			:  This procedure updates the given dependant insurance details into DINS_Y1 table.
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_DINS_UPDATE]
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @An_OthpInsurance_IDNO       NUMERIC(9),
 @Ac_InsuranceGroupNo_TEXT    CHAR(25),
 @Ac_PolicyInsNo_TEXT         CHAR(20),
 @An_ChildMCI_IDNO            NUMERIC(10),
 @Ad_Begin_DATE               DATE,
 @Ac_InsSource_CODE           CHAR(3),
 @Ac_DentalIns_INDC           CHAR(1),
 @Ac_MedicalIns_INDC          CHAR(1),
 @Ac_MentalIns_INDC           CHAR(1),
 @Ac_PrescptIns_INDC          CHAR(1),
 @Ac_VisionIns_INDC           CHAR(1),
 @As_DescriptionOthers_TEXT   VARCHAR(50),
 @Ad_End_DATE                 DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19) = 0,
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Ln_One_NUMB                      NUMERIC(1) = 1,
           @Lc_CaseMemberStatusActive_CODE   CHAR(1) = 'A',
           @Lc_CaseRelationshipD_CODE        CHAR(1) = 'D',
           @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
           @Lc_RespondInitInitiate_CODE      CHAR(1) = 'I',
           @Lc_RespondInitResponding_CODE    CHAR(1) = 'R',
           @Lc_RelationshipCaseNcp_CODE      CHAR(1) = 'A',
           @Lc_RelationshipCaseCp_CODE       CHAR(1) = 'C',
           @Lc_Space_TEXT                    CHAR(1) = ' ',
           @Lc_No_INDC                       CHAR(1) = 'N',
           @Lc_Yes_INDC                      CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE             CHAR(1) = 'F',
           @Lc_TypeOrderVoluntary_CODE       CHAR(1) = 'V',
           @Lc_NegPosCloseRemedy_CODE        CHAR(1) = 'N',
           @Lc_ActionProvide_CODE            CHAR(1) = 'P',
           @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
           @Lc_VerifyStatusConfirmGood_CODE  CHAR(2) = 'CG',
           @Lc_VerifyStatusVerPending_CODE   CHAR(2) = 'VP',
           @Lc_TypeChangeDe_CODE             CHAR(2) = 'DE',
           @Lc_InsSourceFederalCases_CODE    CHAR(2) = 'FC',
           @Lc_FunctionManagestcases_CODE    CHAR(3) = 'MSC',
           @Lc_ErrorE0879_CODE               CHAR(5) = 'E0879',
           @Lc_ErrorE0958_CODE               CHAR(5) = 'E0958',
           @Lc_ErrorE0862_CODE               CHAR(5) = 'E0862',
           @Lc_ErrorE1170_CODE               CHAR(5) = 'E1170',
           @Lc_ErrorE1169_CODE               CHAR(5) = 'E1169',
           @Lc_ErrorE0152_CODE               CHAR(5) = 'E0152',
           @Lc_ReasonGsmad_CODE              CHAR(5) = 'GSMAD',
           @Lc_ProcessMdin_ID                CHAR(10) = 'MDIN',
           @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT             CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                VARCHAR(50) = 'BATCH_COMMON$SP_DINS_UPDATE',
           @Ld_High_DATE                     DATE = '12/31/9999',
           @Ld_Low_DATE                      DATE = '01/01/0001';
  DECLARE  @Ln_Rowcount_QNTY             NUMERIC,
           @Ln_FetchStatus_QNTY          NUMERIC,
           @Ln_Zero_NUMB                 NUMERIC(1) = 0,
           @Ln_OrderSeq_NUMB             NUMERIC(2),
           @Ln_ChildInsCovered_NUMB      NUMERIC(3),
           @Ln_Error_NUMB                NUMERIC(11),
           @Ln_ErrorLine_NUMB            NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB  NUMERIC(19),
           @Lc_NonQualified_CODE         CHAR(1),
           @Lc_MedicalIns_INDC           CHAR(1),
           @Lc_DentalIns_INDC            CHAR(1),
           @Lc_MentalIns_INDC            CHAR(1),
           @Lc_VisionIns_INDC            CHAR(1),
           @Lc_PrescptIns_INDC           CHAR(1),
           @Lc_StatusOld_CODE            CHAR(2),
           @Lc_SourceStatus_CODE		 CHAR(2),
           @Lc_InsSource_CODE            CHAR(3),
           @Lc_Msg_CODE                  CHAR(5),
           @Lc_OthpInsurance_IDNO        CHAR(9),
           @Ls_DescriptionOtherIns_TEXT  VARCHAR(50),
           @Ls_Sql_TEXT                  VARCHAR(1000),
           @Ls_Sqldata_TEXT              VARCHAR(4000),
           @Ls_ErrorMessage_TEXT         VARCHAR(4000),
           @Ls_Temp_TEXT                 VARCHAR(8000),
           @Ld_End_DATE                  DATE,
           @Ld_Begin_DATE                DATE,
           @Ld_Temp_DATE                 DATETIME2;

  DECLARE @Ln_CaseCur_Case_IDNO             NUMERIC(6),
          @Lc_CaseCur_CaseRelationship_CODE CHAR(1);
  
  DECLARE Case_CUR INSENSITIVE CURSOR FOR
   SELECT DISTINCT
          a.Case_IDNO,
          a.CaseRelationship_CODE
     FROM CMEM_Y1 a,
          CASE_Y1 b
    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
      AND a.Case_IDNO = b.Case_IDNO
      AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCaseCp_CODE)
      AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
  -- cursor to loop for all cases  for csenet processing
  DECLARE CsenetCase_CUR INSENSITIVE CURSOR FOR
   SELECT a.Case_IDNO
     FROM CMEM_Y1 a,
          CASE_Y1 b
    WHERE a.MemberMci_IDNO = @An_ChildMCI_IDNO
      AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND a.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
      AND a.Case_IDNO = b.Case_IDNO
      AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND b.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitResponding_CODE);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ad_End_DATE = ISNULL(@Ad_End_DATE, @Ld_High_DATE);

   IF ISNULL (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_InsSource_CODE), @Lc_Space_TEXT) = @Lc_InsSourceFederalCases_CODE
     BEGIN
		SET @Lc_SourceStatus_CODE = @Lc_VerifyStatusVerPending_CODE;
     END 
   ELSE
     BEGIN
		SET @Lc_SourceStatus_CODE = @Lc_VerifyStatusConfirmGood_CODE;
     END 
   
   IF (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PolicyInsNo_TEXT) IS NULL
       AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsuranceGroupNo_TEXT) IS NULL)
       OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@An_MemberMci_IDNO) IS NULL
       OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@An_OthpInsurance_IDNO) IS NULL
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

   -- Program corrected to insert insurance information with latest begin date
   -- It wont insert insurance record until any change happened in insurance.
   BEGIN
    SET @Ls_Sql_TEXT = 'CHECK MINS RECORD EXISTS'; 
    SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
    
    SELECT @Lc_MedicalIns_INDC = m.MedicalIns_INDC,
           @Lc_DentalIns_INDC = m.DentalIns_INDC,
           @Lc_MentalIns_INDC = m.MentalIns_INDC,
           @Lc_VisionIns_INDC = m.VisionIns_INDC,
           @Lc_PrescptIns_INDC = m.PrescptIns_INDC,
           @Ls_DescriptionOtherIns_TEXT = m.DescriptionOtherIns_TEXT
      FROM MINS_Y1 m
     WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
       AND m.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
       AND m.InsuranceGroupNo_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT)
       AND m.PolicyInsNo_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT)
       AND m.End_DATE >= @Ad_Run_DATE
       AND m.EndValidity_DATE = @Ld_High_DATE
       AND m.Begin_DATE = (SELECT MAX(n.Begin_DATE)
                             FROM MINS_Y1 n
                            WHERE n.MemberMci_IDNO = m.MemberMci_IDNO
                              AND n.OthpInsurance_IDNO = m.OthpInsurance_IDNO
                              AND n.InsuranceGroupNo_TEXT = m.InsuranceGroupNo_TEXT
                              AND n.PolicyInsNo_TEXT = m.PolicyInsNo_TEXT
                              AND n.EndValidity_DATE = @Ld_High_DATE);

    SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

    IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
     BEGIN
      SET @Ac_Msg_CODE = @Lc_ErrorE1169_CODE;
      SET @As_DescriptionError_TEXT = 'MINS RECORD DO NOT EXISTS';

      RETURN;
     END

    IF @Ln_Rowcount_QNTY > @Ln_One_NUMB
     BEGIN
      SET @Ls_ErrorMessage_TEXT = 'TOO MANY ROWS IN MINS';
      
      RAISERROR(50001,16,1);
     END

    IF @Ac_InsSource_CODE <> 'ME'
       AND ((@Lc_DentalIns_INDC = @Lc_No_INDC
             AND @Ac_DentalIns_INDC = @Lc_Yes_INDC)
             OR (@Lc_MentalIns_INDC = @Lc_No_INDC
                 AND @Ac_MentalIns_INDC = @Lc_Yes_INDC)
             OR (@Lc_MedicalIns_INDC = @Lc_No_INDC
                 AND @Ac_MedicalIns_INDC = @Lc_Yes_INDC)
             OR (@Lc_PrescptIns_INDC = @Lc_No_INDC
                 AND @Ac_PrescptIns_INDC = @Lc_Yes_INDC)
             OR (@Lc_VisionIns_INDC = @Lc_No_INDC
                 AND @Ac_VisionIns_INDC = @Lc_Yes_INDC)
             OR (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ls_DescriptionOtherIns_TEXT) IS NULL
                 AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@As_DescriptionOthers_TEXT) IS NOT NULL))
     BEGIN
      SET @Ac_Msg_CODE = @Lc_ErrorE1170_CODE;
      SET @As_DescriptionError_TEXT = 'INCONSISTENCY WITH MINS INSURANCE ';

      RETURN;
     END
   END

   BEGIN
    SET @Ls_Sql_TEXT = 'CHECK DINS RECORD EXISTS';
    SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', ChildMCI_IDNO = ' + ISNULL(CAST( @An_ChildMCI_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
    
    SELECT @Lc_NonQualified_CODE = d.NonQualified_CODE,
           @Lc_InsSource_CODE = d.InsSource_CODE,
           @Lc_StatusOld_CODE = d.Status_CODE,
           @Lc_MedicalIns_INDC = d.MedicalIns_INDC,
           @Lc_DentalIns_INDC = d.DentalIns_INDC,
           @Lc_MentalIns_INDC = d.MentalIns_INDC,
           @Lc_VisionIns_INDC = d.VisionIns_INDC,
           @Lc_PrescptIns_INDC = d.PrescptIns_INDC,
           @Ld_End_DATE = d.End_DATE,
           @Ld_Begin_DATE = d.Begin_DATE
      FROM DINS_Y1 d
     WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
       AND d.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
       AND d.InsuranceGroupNo_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT)
       AND d.PolicyInsNo_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT)
       AND d.ChildMCI_IDNO = @An_ChildMCI_IDNO
       AND d.EndValidity_DATE = @Ld_High_DATE
       AND d.Begin_DATE = (SELECT MAX(n.Begin_DATE)
                             FROM DINS_Y1 n
                            WHERE n.MemberMci_IDNO = d.MemberMci_IDNO
                              AND n.OthpInsurance_IDNO = d.OthpInsurance_IDNO
                              AND n.PolicyInsNo_TEXT = d.PolicyInsNo_TEXT
                              AND n.InsuranceGroupNo_TEXT = d.InsuranceGroupNo_TEXT
                              AND n.ChildMCI_IDNO = d.ChildMCI_IDNO
                              AND n.EndValidity_DATE = @Ld_High_DATE);

    SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

    IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
     BEGIN
      SET @Lc_NonQualified_CODE = @Lc_Space_TEXT;
      SET @Lc_InsSource_CODE = @Lc_Space_TEXT;
      SET @Lc_StatusOld_CODE = @Lc_Space_TEXT;
     END

    IF @Ln_Rowcount_QNTY > @Ln_One_NUMB
     BEGIN
      SET @Ls_ErrorMessage_TEXT = 'TOO MANY ROWS IN DINS';
      
      RAISERROR(50001,16,1);
     END

    -- Inorder to avoid processing the record which is present in DINS_Y1
    IF (ISNULL(@Ad_Begin_DATE, @Ad_Run_DATE) <= @Ld_Begin_DATE)
       AND @Ac_InsSource_CODE <> 'ME'
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
       AND ISNULL(@Ad_End_DATE, @Ld_High_DATE) <= @Ld_End_DATE
       AND @Ac_InsSource_CODE <> 'ME'
     BEGIN
      SET @Ac_Msg_CODE = @Lc_ErrorE0152_CODE;
      SET @As_DescriptionError_TEXT = 'DINS RECORD EXISTS';

      RETURN;
     END

    IF @Ld_End_DATE >= ISNULL(@Ad_Begin_DATE, @Ad_Run_DATE)
     BEGIN
      SET @Ls_Sql_TEXT = 'UPDATE DINS_Y1 - 1';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', ChildMCI_IDNO = ' + ISNULL(CAST( @An_ChildMCI_IDNO AS VARCHAR ),'')+ ', Begin_DATE = ' + ISNULL(CAST( @Ld_Begin_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      
      UPDATE DINS_Y1
         SET End_DATE = DATEADD(D, -1, ISNULL(@Ad_Begin_DATE, @Ad_Run_DATE))
       WHERE DINS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
         AND DINS_Y1.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
         AND DINS_Y1.InsuranceGroupNo_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT)
         AND DINS_Y1.PolicyInsNo_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT)
         AND DINS_Y1.ChildMCI_IDNO = @An_ChildMCI_IDNO
         AND DINS_Y1.Begin_DATE = @Ld_Begin_DATE
         AND DINS_Y1.End_DATE >= ISNULL(@Ad_Begin_DATE, @Ad_Run_DATE)
         AND DINS_Y1.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE DINS FAILED';
        
        RAISERROR(50001,16,1);
       END
     END
   END

   IF @An_TransactionEventSeq_NUMB = 0
       OR @An_TransactionEventSeq_NUMB IS NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
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
       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO DINS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpInsurance_IDNO = ' + ISNULL(CAST( @An_OthpInsurance_IDNO AS VARCHAR ),'')+ ', ChildMCI_IDNO = ' + ISNULL(CAST( @An_ChildMCI_IDNO AS VARCHAR ),'')+ ', Status_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_SourceStatus_CODE,'')+ ', NonQualified_CODE = ' + ISNULL(@Lc_NonQualified_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'');

   INSERT DINS_Y1
          (MemberMci_IDNO,
           OthpInsurance_IDNO,
           InsuranceGroupNo_TEXT,
           PolicyInsNo_TEXT,
           ChildMCI_IDNO,
           Begin_DATE,
           End_DATE,
           Status_DATE,
           MedicalIns_INDC,
           DentalIns_INDC,
           VisionIns_INDC,
           PrescptIns_INDC,
           MentalIns_INDC,
           DescriptionOthers_TEXT,
           Status_CODE,
           NonQualified_CODE,
           InsSource_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB)
   VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
            @An_OthpInsurance_IDNO,--OthpInsurance_IDNO
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsuranceGroupNo_TEXT), @Lc_Space_TEXT),--InsuranceGroupNo_TEXT
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT),--PolicyInsNo_TEXT
            @An_ChildMCI_IDNO,--ChildMCI_IDNO
            ISNULL(@Ad_Begin_DATE, @Ad_Run_DATE),--Begin_DATE
            ISNULL(@Ad_End_DATE, @Ld_High_DATE),--End_DATE
            @Ad_Run_DATE,--Status_DATE
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_MedicalIns_INDC), @Lc_No_INDC),--MedicalIns_INDC
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_DentalIns_INDC), @Lc_No_INDC),--DentalIns_INDC
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_VisionIns_INDC), @Lc_No_INDC),--VisionIns_INDC
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PrescptIns_INDC), @Lc_No_INDC),--PrescptIns_INDC
            ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_MentalIns_INDC), @Lc_No_INDC),--MentalIns_INDC
            ISNULL(@As_DescriptionOthers_TEXT, @Lc_Space_TEXT),--DescriptionOthers_TEXT
            @Lc_SourceStatus_CODE,--Status_CODE
            @Lc_NonQualified_CODE,--NonQualified_CODE
            ISNULL(@Ac_InsSource_CODE, @Lc_Space_TEXT),--InsSource_CODE
            @Ad_Run_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
            @Ln_TransactionEventSeq_NUMB); --TransactionEventSeq_NUMB
            
   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT DINS FAILED';
     
     RAISERROR(50001,16,1);
    END

   OPEN Case_CUR;

   FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   --FETCH EACH RECORD
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'CHECK ALL DEPENDENTS COVERED';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseCur_Case_IDNO AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipD_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_ChildInsCovered_NUMB = COUNT(1)
       FROM CMEM_Y1 m
      WHERE m.Case_IDNO = @Ln_CaseCur_Case_IDNO
        AND m.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
        AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
        AND NOT EXISTS (SELECT 1
                          FROM DINS_Y1 d
                         WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND d.ChildMCI_IDNO = m.MemberMci_IDNO
                           AND d.End_DATE >= @Ad_Run_DATE
                           AND d.EndValidity_DATE = @Ld_High_DATE);

     IF @Ln_ChildInsCovered_NUMB = @Ln_Zero_NUMB
      BEGIN
        SET @Ls_Sql_TEXT = 'GET OrderSeq_NUMB';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseCur_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

        SELECT @Ln_OrderSeq_NUMB = s.OrderSeq_NUMB
          FROM SORD_Y1 s
         WHERE s.Case_IDNO = @Ln_CaseCur_Case_IDNO
           AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
           AND @Ad_Run_DATE BETWEEN s.OrderIssued_DATE AND s.OrderEnd_DATE
           AND s.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
         BEGIN
          SET @Ln_OrderSeq_NUMB = 0;
         END

       IF @Ln_OrderSeq_NUMB > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpSource_IDNO = ' + ISNULL('0','')+ ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangeDe_CODE,'')+ ', NegPos_CODE = ' + ISNULL(@Lc_NegPosCloseRemedy_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessMdin_ID,'')+ ', Create_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Reference_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

         EXECUTE BATCH_COMMON$SP_INSERT_ELFC
          @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
          @An_OthpSource_IDNO          = 0,
          @Ac_TypeChange_CODE          = @Lc_TypeChangeDe_CODE,
          @Ac_NegPos_CODE              = @Lc_NegPosCloseRemedy_CODE,
          @Ac_Process_ID               = @Lc_ProcessMdin_ID,
          @Ad_Create_DATE              = @Ad_Run_DATE,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
          @Ac_Reference_ID             = @Lc_Space_TEXT,
          @Ac_TypeReference_CODE       = @Lc_Space_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END
        END
      END

     FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Case_CUR;

   DEALLOCATE Case_CUR;

   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Lc_StatusOld_CODE) IS NULL
       OR @Lc_StatusOld_CODE != @Lc_VerifyStatusConfirmGood_CODE
    BEGIN
     OPEN CsenetCase_CUR;

     FETCH NEXT FROM CsenetCase_CUR INTO @Ln_CaseCur_Case_IDNO;

	 SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
	 
	 --FETCH EACH RECORD
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Temp_TEXT = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_PolicyInsNo_TEXT), @Lc_Space_TEXT);
       SET @Ld_Temp_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
       SET @Lc_OthpInsurance_IDNO = CAST(@An_OthpInsurance_IDNO AS VARCHAR);

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseCur_Case_IDNO AS VARCHAR ),'')+ ', RespondentMci_IDNO = ' + ISNULL('0','')+ ', Function_CODE = ' + ISNULL(@Lc_FunctionManagestcases_CODE,'')+ ', Action_CODE = ' + ISNULL(@Lc_ActionProvide_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonGsmad_CODE,'')+ ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Generated_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Form_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', FormWeb_URL = ' + ISNULL(@Lc_Space_TEXT,'')+ ', TransHeader_IDNO = ' + ISNULL('0','')+ ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CaseFormer_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', InsCarrier_NAME = ' + ISNULL(@Lc_OthpInsurance_IDNO,'')+ ', InsPolicyNo_TEXT = ' + ISNULL(@Ls_Temp_TEXT,'')+ ', Hearing_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Dismissal_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', GeneticTest_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', PfNoShow_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Attachment_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', File_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ArrearComputed_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', TotalArrearsOwed_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', TotalInterestOwed_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Update_DTTM = ' + ISNULL(CAST( @Ld_Temp_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'');
      
       EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
        @An_Case_IDNO                    = @Ln_CaseCur_Case_IDNO,
        @An_RespondentMci_IDNO           = 0,
        @Ac_Function_CODE                = @Lc_FunctionManagestcases_CODE,
        @Ac_Action_CODE                  = @Lc_ActionProvide_CODE,
        @Ac_Reason_CODE                  = @Lc_ReasonGsmad_CODE,
        @Ac_IVDOutOfStateFips_CODE       = @Lc_Space_TEXT,
        @Ac_IVDOutOfStateCountyFips_CODE = @Lc_Space_TEXT,
        @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
        @Ac_IVDOutOfStateCase_ID         = @Lc_Space_TEXT,
        @Ad_Generated_DATE               = @Ad_Run_DATE,
        @Ac_Form_ID                      = @Lc_Space_TEXT,
        @As_FormWeb_URL                  = @Lc_Space_TEXT,
        @An_TransHeader_IDNO             = 0,
        @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
        @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
        @Ac_InsCarrier_NAME              = @Lc_OthpInsurance_IDNO,
        @Ac_InsPolicyNo_TEXT             = @Ls_Temp_TEXT,
        @Ad_Hearing_DATE                 = @Ld_Low_DATE,
        @Ad_Dismissal_DATE               = @Ld_Low_DATE,
        @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
        @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
        @Ac_Attachment_INDC              = @Lc_No_INDC,
        @Ac_File_ID                      = @Lc_Space_TEXT,
        @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
        @An_TotalArrearsOwed_AMNT        = @Ln_Zero_NUMB,
        @An_TotalInterestOwed_AMNT       = @Ln_Zero_NUMB,
        @Ac_Process_ID                   = @Ac_Process_ID,
        @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
        @Ac_SignedonWorker_ID            = @Lc_BatchRunUser_TEXT,
        @Ad_Update_DTTM                  = @Ld_Temp_DATE,
        @An_TransactionEventSeq_NUMB     = @Ln_TransactionEventSeq_NUMB,
        @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT        = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       FETCH NEXT FROM CsenetCase_CUR INTO @Ln_CaseCur_Case_IDNO;

	    SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

      END

     CLOSE CsenetCase_CUR;

     DEALLOCATE CsenetCase_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Successful_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF CURSOR_STATUS ('LOCAL', 'Case_CUR') IN (0, 1)
    BEGIN
     CLOSE Case_CUR;

     DEALLOCATE Case_CUR;
    END
   
   IF CURSOR_STATUS ('LOCAL', 'CsenetCase_CUR') IN (0, 1)
    BEGIN
     CLOSE CsenetCase_CUR;

     DEALLOCATE CsenetCase_CUR;
    END
    
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
