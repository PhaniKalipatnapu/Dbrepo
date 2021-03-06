/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_UPDATE_TRANSACTION_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_UPDATE_TRANSACTION_DATA
Programmer Name	:	IMP Team.
Description		:	This procedure is used to update the CSENET data in Transaction table.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_UPDATE_TRANSACTION_DATA] (
 @An_Transaction_IDNO             NUMERIC(12),
 @Ad_Transaction_DATE             DATE,
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3),
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2),
 @Ac_Reason_CODE                  CHAR(5),
 @Ac_Enumeration_CODE             CHAR(1),
 @Ai_RowCount_NUMB                INT,
 @Ac_JobProcess_IDNO              CHAR(7),
 @Ac_BatchRunUser_TEXT            CHAR(30),
 @Ad_Run_DATE                     DATE,
 @Ac_SourceLoc_CODE               CHAR(3),
 @Ac_TranStatus_CODE              CHAR(2),
 @Ac_Msg_CODE                     CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT        VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Sequence_NUMB             NUMERIC(11) = 1,
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_ConfirmedGood_CODE        CHAR(1) = 'Y',
          @Lc_ErrorTypeInformation_CODE CHAR(1) = 'I',
          @Lc_SourceVerifiedByI_CODE    CHAR(1) = 'I',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_No_INDC                   CHAR(1) = 'N',
          @Lc_StatusPending_CODE        CHAR(1) = 'P',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_OrderTypeEmployer_CODE    CHAR(1) = 'E',
          @Lc_RelationshipCaseCp_TEXT   CHAR(1) = 'C',
          @Lc_RelationshipCaseDp_TEXT   CHAR(1) = 'D',
          @Lc_CaseStatusOpen_CODE       CHAR(1) = 'O',
          @Lc_TypeAddressM_CODE         CHAR(1) = 'M',
          @Lc_TypeAddressR_CODE         CHAR(1) = 'R',
          @Lc_TypeIncomeEm_CODE         CHAR(2) = 'EM',
          @Lc_SourceLoc_CODE            CHAR(3) = 'OSA',
          @Lc_FarProvidstatusupdat_CODE CHAR(5) = 'GSPUD',
          @Lc_ErrorAddNotsuccess_TEXT   CHAR(5) = 'E0113',
          @Lc_ErrorUpdatefailed_CODE    CHAR(5) = 'E0001',
          @Lc_ErrorE1089_CODE           CHAR(5) = 'E1089',
          @Lc_ErrorUpdateFailed_INDC    CHAR(5) = 'E0001',
          @Lc_WorkerUpdate_ID           CHAR(5) = 'BATCH',
          @Ls_Process_NAME              VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE',
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_UPDATE_TRANSACTION_DATA',
          @Ld_Low_DATE                  DATE = '01/01/0001',
          @Ld_High_DATE                 DATE = '12/31/9999',
          @Ld_Update_DTTM               DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_FetchStatus_QNTY             NUMERIC,
          @Ln_Case_IDNO                    NUMERIC(6) = 0,
          @Ln_PhoneExtensionCount_NUMB     NUMERIC(6),
          @Ln_NcpMemberSsn_NUMB            NUMERIC(9) = 0,
          @Ln_NcpAliasSsn1_NUMB            NUMERIC(9) = 0,
          @Ln_NcpAliasSsn2_NUMB            NUMERIC(9) = 0,
          @Ln_EmployerEin_ID               NUMERIC(9),
          @Ln_OtherParty_IDNO              NUMERIC(9),
          @Ln_MemberMci_IDNO               NUMERIC(10),
          @Ln_EmployerPhone_NUMB           NUMERIC(10),
          @Ln_ContactPhone_NUMB            NUMERIC(10, 0) = 0,
          @Ln_Value_QNTY                   NUMERIC(10) = 0,
          @Ln_Error_NUMB                   NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB               NUMERIC(11) = 0,
          @Ln_HomePhone_NUMB               NUMERIC(15),
          @Ln_WorkPhone_NUMB               NUMERIC(15),
          @Ln_ContactFax_NUMB              NUMERIC(15) = 0,
          @Ln_TransactionEventSeq_NUMB     NUMERIC(19) = 0,
          @Ln_TransactionEventSeqOld_NUMB  NUMERIC(19) = 0,
          @Li_CaseData_QNTY                INT = 0,
          @Li_Ncp_QNTY                     INT = 0,
          @Li_NcpLoc_QNTY                  INT = 0,
          @Li_Participant_QNTY             INT = 0,
          @Li_RowCount_QNTY                INT = 0,
          @Li_Zero_NUMB                    SMALLINT = 0,
          @Lc_SsnMatch_CODE                CHAR(1) = '',
          @Lc_NameMatch_INDC               CHAR(1) = '',
          @Lc_ExactMatch_INDC              CHAR(1) = '',
          @Lc_MultMatch_INDC               CHAR(1) = '',
          @Lc_NcpRace_CODE                 CHAR(1) = '',
          @Lc_NcpMemberSex_TEXT            CHAR(1) = '',
          @Lc_ConfirmedResidential_INDC    CHAR(1) = '',
          @Lc_ConfirmedMailing_INDC        CHAR(1) = '',
          @Lc_TypeCase_CODE                CHAR(1) = '',
          @Lc_StatusCase_CODE              CHAR(1) = '',
          @Lc_NondisclosureFinding_INDC    CHAR(1) = '',
          @Lc_Action_CODE                  CHAR(1) = '',
          @Lc_Normalization_CODE           CHAR(1) = '',
          @Lc_MailNormalization_CODE       CHAR(1) = '',
          @Lc_ErrorType_CODE               CHAR(1) = '',
          @Lc_Empty_TEXT                   CHAR(1) = '',
          @Lc_EmployerConfirmed_INDC       CHAR(1),
          @Lc_ResidentialState_CODE        CHAR(2) = '',
          @Lc_MailingState_CODE            CHAR(2) = '',
          @Lc_EmployerState_ADDR           CHAR(2) = '',
          @Lc_IVDOutOfStateFips_CODE       CHAR(2) = '',
          @Lc_IVDOutOfStateOfficeFips_CODE CHAR(2) = '',
          @Lc_PaymentState_ADDR            CHAR(2) = '',
          @Lc_ContactState_ADDR            CHAR(2) = '',
          @Lc_NcpSuffix_NAME               CHAR(3) = '',
          @Lc_NcpAlias1Suffix_NAME         CHAR(3) = '',
          @Lc_NcpAlias2Suffix_NAME         CHAR(3) = '',
          @Lc_NcpAlias3Suffix_NAME         CHAR(3) = '',
          @Lc_IVDOutOfStateCountyFips_CODE CHAR(3) = '',
          @Lc_ContactSuffix_NAME           CHAR(3) = '',
          @Lc_Function_CODE                CHAR(3) = '',
          @Lc_Msg_CODE                     CHAR(5) = '',
          @Lc_Reason_CODE                  CHAR(5) = '',
          @Lc_Fips_CODE                    CHAR(7),
          @Lc_ResidentialZip_ADDR          CHAR(9) = '',
          @Lc_MailingZip_TEXT              CHAR(9) = '',
          @Lc_EmployerEin_ID               CHAR(9) = '',
          @Lc_EmployerZip_ADDR             CHAR(9) = '',
          @Lc_PaymentZip_ADDR              CHAR(9) = '',
          @Lc_ContactZip_ADDR              CHAR(9) = '',
          @Lc_NcpPlaceOfBirth_TEXT         CHAR(15) = '',
          @Lc_IVDOutOfStateCase_ID         CHAR(15) = '',
          @Lc_NcpFirst_NAME                CHAR(16) = '',
          @Lc_NcpMiddle_NAME               CHAR(16) = '',
          @Lc_NcpAlias1First_NAME          CHAR(16) = '',
          @Lc_NcpAlias1Middle_NAME         CHAR(16) = '',
          @Lc_NcpAlias2First_NAME          CHAR(16) = '',
          @Lc_NcpAlias2Middle_NAME         CHAR(16) = '',
          @Lc_NcpAlias3First_NAME          CHAR(16) = '',
          @Lc_NcpAlias3Middle_NAME         CHAR(16) = '',
          @Lc_ContactFirst_NAME            CHAR(16) = '',
          @Lc_ContactMiddle_NAME           CHAR(16) = '',
          @Lc_RespondingFile_ID            CHAR(17) = '',
          @Lc_ResidentialCity_ADDR         CHAR(18) = '',
          @Lc_MailingCity_TEXT             CHAR(18) = '',
          @Lc_EmployerCity_ADDR            CHAR(18) = '',
          @Lc_PaymentCity_ADDR             CHAR(18) = '',
          @Lc_ContactCity_ADDR             CHAR(18) = '',
          @Lc_NcpLast_NAME                 CHAR(21) = '',
          @Lc_NcpAlias1Last_NAME           CHAR(21) = '',
          @Lc_NcpAlias2Last_NAME           CHAR(21) = '',
          @Lc_NcpAlias3Last_NAME           CHAR(21) = '',
          @Lc_ContactLast_NAME             CHAR(21) = '',
          @Lc_ResidentialLine1_ADDR        CHAR(25) = '',
          @Lc_ResidentialLine2_ADDR        CHAR(25) = '',
          @Lc_MailingLine1_ADDR            CHAR(25) = '',
          @Lc_MailingLine2_ADDR            CHAR(25) = '',
          @Lc_EmployerLine1_ADDR           CHAR(25) = '',
          @Lc_EmployerLine2_ADDR           CHAR(25) = '',
          @Lc_PaymentLine1_ADDR            CHAR(25) = '',
          @Lc_PaymentLine2_ADDR            CHAR(25) = '',
          @Lc_ContactLine1_ADDR            CHAR(25) = '',
          @Lc_ContactLine2_ADDR            CHAR(25) = '',
          @Ls_Employer_NAME                VARCHAR(60) = '',
          @Ls_Contact_EML                  VARCHAR(100),
          @Ls_Sql_TEXT                     VARCHAR(200) = '',
          @Ls_DescriptionError_TEXT        VARCHAR(1000) = '',
          @Ls_Sqldata_TEXT                 VARCHAR(2000) = '',
          @Ls_Temp_TEXT                    VARCHAR(8000) = '',
          @Ld_EffectiveResidential_DATE    DATE,
          @Ld_EndResidential_DATE          DATE,
          @Ld_EffectiveMailing_DATE        DATE,
          @Ld_EndMailing_DATE              DATE,
          @Ld_EffectiveEmployer_DATE       DATE,
          @Ld_EndEmployer_DATE             DATE,
          @Ld_NcpBirth_DATE                DATE;
  DECLARE @Lc_RecCPDPCur_First_NAME                CHAR(16),
          @Lc_RecCPDPCur_Last_NAME                 CHAR(20),
          @Lc_RecCPDPCur_Middle_NAME               CHAR(20),
          @Lc_RecCPDPCur_Suffix_NAME               CHAR(4),
          @Ld_RecCPDPCur_Birth_DATE                DATE,
          @Lc_RecCPDPCur_Race_CODE                 CHAR(1),
          @Lc_RecCPDPCur_MemberSex_CODE            CHAR(1),
          @Ln_RecCPDPCur_MemberSsn_NUMB            NUMERIC(9),
          @Lc_RecCPDPCur_PlaceOfBirth_NAME         CHAR(25),
          @Lc_RecCPDPCur_ParticipantLine1_ADDR     CHAR(25),
          @Lc_RecCPDPCur_ParticipantLine2_ADDR     CHAR(25),
          @Lc_RecCPDPCur_ParticipantCity_ADDR      CHAR(18),
          @Lc_RecCPDPCur_ParticipantState_ADDR     CHAR(2),
          @Lc_RecCPDPCur_ParticipantZip_ADDR       CHAR(9),
          @Lc_RecCPDPCur_PartNormalization_CODE    CHAR(2),
          @Lc_RecCPDPCur_Relationship_CODE         CHAR(1),
          @Lc_RecCPDPCur_ConfirmedAddress_INDC     CHAR(1),
          @Lc_RecCPDPCur_ChildPaternityStatus_CODE CHAR(1),
          @Ln_RecCPDPCur_WorkPhone_NUMB            NUMERIC(10),
          @Ls_RecCPDPCur_Employer_NAME             VARCHAR(60),
          @Lc_RecCPDPCur_EmployerLine1_ADDR        CHAR(25),
          @Lc_RecCPDPCur_EmployerLine2_ADDR        CHAR(25),
          @Lc_RecCPDPCur_EmployerCity_ADDR         CHAR(18),
          @Lc_RecCPDPCur_EmployerState_ADDR        CHAR(2),
          @Lc_RecCPDPCur_EmployerZip_ADDR          CHAR(9),
          @Lc_RecCPDPCur_EmployerEin_ID            CHAR(9),
          @Lc_RecCPDPCur_ConfirmedEmployer_INDC    CHAR(1);

  BEGIN TRY
   SET @Lc_Fips_CODE = @Ac_IVDOutOfStateFips_CODE + @Ac_IVDOutOfStateCountyFips_CODE + @Ac_IVDOutOfStateOfficeFips_CODE;
   SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_UPDATE_TRANSACTION_DATA';
   SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

   SELECT @Li_CaseData_QNTY = a.CaseData_QNTY,
          @Li_Ncp_QNTY = a.Ncp_QNTY,
          @Li_NcpLoc_QNTY = a.NcpLoc_QNTY,
          @Li_Participant_QNTY = a.Participant_QNTY,
          @Lc_Function_CODE = a.Function_CODE,
          @Lc_Action_CODE = a.Action_CODE,
          @Lc_Reason_CODE = a.Reason_CODE
     FROM CTHB_Y1 a
    WHERE a.Transaction_IDNO = @An_Transaction_IDNO
      AND a.Transaction_DATE = @Ad_Transaction_DATE
      AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;

   IF @Li_Ncp_QNTY > @Li_Zero_NUMB
      AND @Li_NcpLoc_QNTY > @Li_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT NCP DATA';
     SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

     SELECT @Lc_NcpFirst_NAME = a.First_NAME,
            @Lc_NcpLast_NAME = a.Last_NAME,
            @Lc_NcpMiddle_NAME = a.Middle_NAME,
            @Lc_NcpSuffix_NAME = a.Suffix_NAME,
            @Ln_NcpMemberSsn_NUMB = a.MemberSsn_NUMB,
            @Ld_NcpBirth_DATE = a.Birth_DATE,
            @Lc_NcpRace_CODE = a.Race_CODE,
            @Lc_NcpMemberSex_TEXT = a.MemberSex_CODE,
            @Lc_NcpPlaceOfBirth_TEXT = a.PlaceOfBirth_NAME,
            @Ln_NcpAliasSsn1_NUMB = a.Alias1Ssn_NUMB,
            @Ln_NcpAliasSsn2_NUMB = a.Alias2Ssn_NUMB
       FROM CNCB_Y1 a,
            CTHB_Y1 d
      WHERE d.Transaction_IDNO = @An_Transaction_IDNO
        AND a.TransHeader_IDNO = d.TransHeader_IDNO
        AND a.Transaction_DATE = @Ad_Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;

     SET @Ls_Sql_TEXT = ' CALL BATCH_COMMON$SP_MEMBER_CLEARENCE ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpMemberSsn_NUMB AS VARCHAR), '') + ', First_NAME = ' + ISNULL(@Lc_NcpFirst_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_NcpLast_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_NcpMiddle_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_NcpMemberSex_TEXT, '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_NcpBirth_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_MEMBER_CLEARENCE
      @An_MemberMci_IDNO        = @Li_Zero_NUMB,
      @An_MemberSsn_NUMB        = @Ln_NcpMemberSsn_NUMB,
      @Ac_First_NAME            = @Lc_NcpFirst_NAME,
      @Ac_Last_NAME             = @Lc_NcpLast_NAME,
      @Ac_Middle_NAME           = @Lc_NcpMiddle_NAME,
      @Ac_MemberSex_CODE        = @Lc_NcpMemberSex_TEXT,
      @Ad_Birth_DATE            = @Ld_NcpBirth_DATE,
      @An_MemberMciOut_IDNO     = @Ln_MemberMci_IDNO OUTPUT,
      @Ac_MemberSsnMatch_INDC   = @Lc_SsnMatch_CODE OUTPUT,
      @Ac_NameMatch_INDC        = @Lc_NameMatch_INDC OUTPUT,
      @Ac_ExactMatch_INDC       = @Lc_ExactMatch_INDC OUTPUT,
      @Ac_MultMatch_INDC        = @Lc_MultMatch_INDC OUTPUT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'MEMBER CLEARENCE';
       SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
        @An_Line_NUMB                = @Ai_RowCount_NUMB,
        @Ac_Error_CODE               = 'E0759',
        @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;

       SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;
      END;

     IF (@Ln_MemberMci_IDNO <> @Li_Zero_NUMB)
      BEGIN
       SET @Ls_Sql_TEXT = ' SELECT FROM CNLB_Y1 ';
       SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

       SELECT @Lc_ResidentialLine1_ADDR = a.ResidentialLine1_ADDR,
              @Lc_ResidentialLine2_ADDR = a.ResidentialLine2_ADDR,
              @Lc_ResidentialCity_ADDR = a.ResidentialCity_ADDR,
              @Lc_ResidentialState_CODE = a.ResidentialState_ADDR,
              @Lc_ResidentialZip_ADDR = a.ResidentialZip_ADDR,
              @Lc_MailingLine1_ADDR = a.MailingLine1_ADDR,
              @Lc_MailingLine2_ADDR = a.MailingLine2_ADDR,
              @Lc_MailingCity_TEXT = a.MailingCity_ADDR,
              @Lc_MailingState_CODE = a.MailingState_ADDR,
              @Lc_MailingZip_TEXT = a.MailingZip_ADDR,
              @Ld_EffectiveResidential_DATE = a.EffectiveResidential_DATE,
              @Ld_EndResidential_DATE = CASE CAST(a.EndResidential_DATE AS DATETIME2)
                                         WHEN @Ld_Low_DATE
                                          THEN @Ld_High_DATE
                                         ELSE CAST(a.EndResidential_DATE AS DATETIME2)
                                        END,
              @Lc_ConfirmedResidential_INDC = a.ResidentialConfirmed_CODE,
              @Ld_EffectiveMailing_DATE = a.EffectiveMailing_DATE,
              @Ld_EndMailing_DATE = CASE CAST(a.EndMailing_DATE AS DATETIME2)
                                     WHEN @Ld_Low_DATE
                                      THEN @Ld_High_DATE
                                     ELSE CAST(a.EndMailing_DATE AS DATETIME2)
                                    END,
              @Lc_ConfirmedMailing_INDC = a.MailingConfirmed_CODE,
              @Lc_EmployerEin_ID = a.EmployerEin_ID,
              @Ls_Employer_NAME = a.Employer_NAME,
              @Lc_EmployerLine1_ADDR = a.EmployerLine1_ADDR,
              @Lc_EmployerLine2_ADDR = a.EmployerLine2_ADDR,
              @Lc_EmployerCity_ADDR = a.EmployerCity_ADDR,
              @Lc_EmployerState_ADDR = a.EmployerState_ADDR,
              @Lc_EmployerZip_ADDR = a.EmployerZip_ADDR,
              @Ln_EmployerPhone_NUMB = CAST((CASE LTRIM(a.EmployerPhone_NUMB)
                                              WHEN @Lc_Empty_TEXT
                                               THEN '0'
                                              ELSE a.EmployerPhone_NUMB
                                             END) AS NUMERIC),
              @Ld_EffectiveEmployer_DATE = a.EffectiveEmployer_DATE,
              @Ld_EndEmployer_DATE = CASE CAST(a.EndEmployer_DATE AS DATETIME2)
                                      WHEN @Ld_Low_DATE
                                       THEN @Ld_High_DATE
                                      ELSE CAST(a.EndEmployer_DATE AS DATETIME2)
                                     END,
              @Lc_EmployerConfirmed_INDC = CASE LTRIM(RTRIM(a.EmployerConfirmed_INDC))
                                            WHEN @Lc_Empty_TEXT
                                             THEN @Lc_StatusPending_CODE
                                            ELSE a.EmployerConfirmed_INDC
                                           END,
              @Ln_HomePhone_NUMB = CAST((CASE LTRIM(a.HomePhone_NUMB)
                                          WHEN @Lc_Empty_TEXT
                                           THEN '0'
                                          ELSE a.HomePhone_NUMB
                                         END) AS NUMERIC),
              @Ln_WorkPhone_NUMB = CAST((CASE LTRIM(a.WorkPhone_NUMB)
                                          WHEN @Lc_Empty_TEXT
                                           THEN '0'
                                          ELSE a.WorkPhone_NUMB
                                         END) AS NUMERIC),
              @Lc_NcpAlias1First_NAME = a.Alias1First_NAME,
              @Lc_NcpAlias1Middle_NAME = a.Alias1Middle_NAME,
              @Lc_NcpAlias1Last_NAME = a.Alias1Last_NAME,
              @Lc_NcpAlias1Suffix_NAME = a.Alias1Suffix_NAME,
              @Lc_NcpAlias2First_NAME = a.Alias2First_NAME,
              @Lc_NcpAlias2Middle_NAME = a.Alias2Middle_NAME,
              @Lc_NcpAlias2Last_NAME = a.Alias2Last_NAME,
              @Lc_NcpAlias2Suffix_NAME = a.Alias2Suffix_NAME,
              @Lc_NcpAlias3First_NAME = a.Alias3First_NAME,
              @Lc_NcpAlias3Middle_NAME = a.Alias3Middle_NAME,
              @Lc_NcpAlias3Last_NAME = a.Alias3Last_NAME,
              @Lc_NcpAlias3Suffix_NAME = a.Alias3Suffix_NAME,
              @Lc_Normalization_CODE = SUBSTRING(b.ResNormalization_CODE, 1, 1),
              @Lc_MailNormalization_CODE = SUBSTRING(b.MailNormalization_CODE, 1, 1)
         FROM CNLB_Y1 a,
              LNLBL_Y1 b,
              CTHB_Y1 d
        WHERE d.Transaction_IDNO = @An_Transaction_IDNO
          AND a.TransHeader_IDNO = d.TransHeader_IDNO
          AND a.Transaction_DATE = @Ad_Transaction_DATE
          AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
          AND LTRIM(d.Transaction_IDNO) <> @Lc_Empty_TEXT
          AND b.TransHeader_IDNO = d.Transaction_IDNO
          AND b.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE;

       IF @Lc_ConfirmedResidential_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC, @Lc_ConfirmedGood_CODE, @Lc_Space_TEXT)
          AND LTRIM(@Lc_ResidentialLine1_ADDR) <> @Lc_Empty_TEXT
          AND @Ld_EndResidential_DATE > @Ad_Run_DATE
        BEGIN
         SET @Ls_Sql_TEXT = 'RESIDENTIAL ADDRESS UPDATE';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressR_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_EffectiveResidential_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_ResidentialLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Lc_ResidentialLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_ResidentialCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_ResidentialState_CODE, '') + ', Zip_ADDR = ' + ISNULL(@Lc_ResidentialZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusPending_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedByI_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', SignedonWorker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', OfficeSignedon_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_Normalization_CODE, '');

         EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
          @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
          @Ad_Run_DATE                         = @Ad_Run_DATE,
          @Ac_TypeAddress_CODE                 = @Lc_TypeAddressR_CODE,
          @Ad_Begin_DATE                       = @Ld_EffectiveResidential_DATE,
          @Ad_End_DATE                         = @Ld_High_DATE,
          @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
          @As_Line1_ADDR                       = @Lc_ResidentialLine1_ADDR,
          @As_Line2_ADDR                       = @Lc_ResidentialLine2_ADDR,
          @Ac_City_ADDR                        = @Lc_ResidentialCity_ADDR,
          @Ac_State_ADDR                       = @Lc_ResidentialState_CODE,
          @Ac_Zip_ADDR                         = @Lc_ResidentialZip_ADDR,
          @Ac_Country_ADDR                     = @Lc_Space_TEXT,
          @An_Phone_NUMB                       = @Li_Zero_NUMB,
          @Ac_SourceLoc_CODE                   = @Lc_SourceLoc_CODE,
          @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
          @Ad_Status_DATE                      = @Ad_Run_DATE,
          @Ac_Status_CODE                      = @Lc_StatusPending_CODE,
          @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedByI_CODE,
          @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
          @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
          @Ac_Process_ID                       = @Ac_JobProcess_IDNO,
          @Ac_SignedonWorker_ID                = @Ac_BatchRunUser_TEXT,
          @An_TransactionEventSeq_NUMB         = 0,
          @An_OfficeSignedon_IDNO              = @Li_Zero_NUMB,
          @Ac_Normalization_CODE               = @Lc_Normalization_CODE,
          @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_Msg_CODE,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       IF @Lc_ConfirmedMailing_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC, @Lc_ConfirmedGood_CODE, @Lc_Space_TEXT)
          AND LTRIM(@Lc_MailingLine1_ADDR) <> @Lc_Empty_TEXT
          AND @Ld_EndMailing_DATE > @Ad_Run_DATE
        BEGIN
         SET @Ls_Sql_TEXT = 'MAILING ADDRESS UPDATE';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressM_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_EffectiveMailing_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_MailingLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Lc_MailingLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_MailingCity_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_MailingState_CODE, '') + ', Zip_ADDR = ' + ISNULL(@Lc_MailingZip_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusPending_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedByI_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', SignedonWorker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_Normalization_CODE, '');

         EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
          @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
          @Ad_Run_DATE                         = @Ad_Run_DATE,
          @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
          @Ad_Begin_DATE                       = @Ld_EffectiveMailing_DATE,
          @Ad_End_DATE                         = @Ld_High_DATE,
          @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
          @As_Line1_ADDR                       = @Lc_MailingLine1_ADDR,
          @As_Line2_ADDR                       = @Lc_MailingLine2_ADDR,
          @Ac_City_ADDR                        = @Lc_MailingCity_TEXT,
          @Ac_State_ADDR                       = @Lc_MailingState_CODE,
          @Ac_Zip_ADDR                         = @Lc_MailingZip_TEXT,
          @Ac_Country_ADDR                     = @Lc_Space_TEXT,
          @An_Phone_NUMB                       = @Li_Zero_NUMB,
          @Ac_SourceLoc_CODE                   = @Lc_SourceLoc_CODE,
          @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
          @Ad_Status_DATE                      = @Ad_Run_DATE,
          @Ac_Status_CODE                      = @Lc_StatusPending_CODE,
          @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedByI_CODE,
          @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
          @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
          @Ac_Process_ID                       = @Ac_JobProcess_IDNO,
          @Ac_SignedonWorker_ID                = @Ac_BatchRunUser_TEXT,
          @An_TransactionEventSeq_NUMB         = 0,
          @An_OfficeSignedOn_IDNO              = @Li_Zero_NUMB,
          @Ac_Normalization_CODE               = @Lc_Normalization_CODE,
          @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_Msg_CODE,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       IF @Lc_EmployerConfirmed_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC, @Lc_ConfirmedGood_CODE, @Lc_Space_TEXT, @Lc_StatusPending_CODE)
          AND LTRIM(@Ls_Employer_NAME) <> @Lc_Empty_TEXT
          AND LTRIM(@Lc_EmployerLine1_ADDR) <> @Lc_Empty_TEXT
          AND @Ld_EndEmployer_DATE > @Ad_Run_DATE
        BEGIN
         SET @Ls_Sql_TEXT = 'FETCH THE OTHER PARTY Seq_IDNO FOR THE EMPLOYER';
         SET @Ls_Temp_TEXT = @Lc_EmployerZip_ADDR;
         SET @Ln_EmployerEin_ID = CAST((CASE @Lc_EmployerEin_ID
                                         WHEN @Lc_Empty_TEXT
                                          THEN '0'
                                         ELSE @Lc_EmployerEin_ID
                                        END) AS NUMERIC);
         SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_EmployerEin_ID AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_OrderTypeEmployer_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_Employer_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_EmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Lc_EmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_EmployerCity_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Ls_Temp_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_EmployerState_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_EmployerPhone_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '');

         EXECUTE BATCH_COMMON$SP_GET_OTHP
          @Ad_Run_DATE                     = @Ad_Run_DATE,
          @An_Fein_IDNO                    = @Ln_EmployerEin_ID,
          @Ac_TypeOthp_CODE                = @Lc_OrderTypeEmployer_CODE,
          @As_OtherParty_NAME              = @Ls_Employer_NAME,
          @Ac_Aka_NAME                     = @Lc_Space_TEXT,
          @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
          @As_Line1_ADDR                   = @Lc_EmployerLine1_ADDR,
          @As_Line2_ADDR                   = @Lc_EmployerLine2_ADDR,
          @Ac_City_ADDR                    = @Lc_EmployerCity_ADDR,
          @Ac_Zip_ADDR                     = @Ls_Temp_TEXT,
          @Ac_State_ADDR                   = @Lc_EmployerState_ADDR,
          @Ac_Fips_CODE                    = @Lc_Space_TEXT,
          @Ac_Country_ADDR                 = @Lc_Space_TEXT,
          @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
          @An_Phone_NUMB                   = @Ln_EmployerPhone_NUMB,
          @An_Fax_NUMB                     = @Li_Zero_NUMB,
          @As_Contact_EML                  = @Lc_Space_TEXT,
          @An_ReferenceOthp_IDNO           = @Li_Zero_NUMB,
          @An_BarAtty_NUMB                 = @Li_Zero_NUMB,
          @An_Sein_IDNO                    = @Li_Zero_NUMB,
          @Ac_SourceLoc_CODE               = @Lc_SourceLoc_CODE,
          @Ac_WorkerUpdate_ID              = @Lc_WorkerUpdate_ID,
          @An_DchCarrier_IDNO              = @Ln_MemberMci_IDNO,
          @Ac_Normalization_CODE           = @Lc_No_INDC,
          @Ac_Process_ID                   = @Ac_JobProcess_IDNO,
          @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
          @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

         IF (@Lc_Msg_CODE != @Lc_StatusSuccess_CODE)
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_Msg_CODE,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
         ELSE IF (@Lc_Msg_CODE = @Lc_StatusSuccess_CODE)
          BEGIN
           SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_EMPLOYER_UPDATE ';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_EmployerConfirmed_INDC, '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeEm_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceVerifiedByI_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_EffectiveEmployer_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '');

           EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
            @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
            @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
            @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
            @Ac_Status_CODE                = @Lc_EmployerConfirmed_INDC,
            @Ad_Status_DATE                = @Ad_Run_DATE,
            @Ac_TypeIncome_CODE            = @Lc_TypeIncomeEm_CODE,
            @Ac_SourceLocConf_CODE         = @Lc_SourceVerifiedByI_CODE,
            @Ad_Run_DATE                   = @Ad_Run_DATE,
            @Ad_BeginEmployment_DATE       = @Ld_EffectiveEmployer_DATE,
            @Ad_EndEmployment_DATE         = @Ld_High_DATE,
            @An_IncomeGross_AMNT           = @Li_Zero_NUMB,
            @An_IncomeNet_AMNT             = @Li_Zero_NUMB,
            @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
            @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
            @Ac_LimitCcpa_INDC             = @Lc_No_INDC,
            @Ac_EmployerPrime_INDC         = @Lc_No_INDC,
			--Defect 13583 Incoming CSNet batch is not updating the Reasonable Cost field for employment records Start
            @Ac_InsReasonable_INDC         = @Lc_Yes_INDC,
			--Defect 13583 Incoming CSNet batch is not updating the Reasonable Cost field for employment records End
            @Ac_SourceLoc_CODE             = @Lc_SourceLoc_CODE,
            @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
            @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
            @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
            @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
            @An_CostInsurance_AMNT         = @Li_Zero_NUMB,
            @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
            @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
            @Ac_SignedonWorker_ID          = @Lc_WorkerUpdate_ID,
            @An_TransactionEventSeq_NUMB   = 0,
            @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
            @Ac_Process_ID                 = @Ac_JobProcess_IDNO,
            @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
            BEGIN
             SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

             EXECUTE BATCH_COMMON$SP_BATE_LOG
              @As_Process_NAME             = @Ls_Process_NAME,
              @As_Procedure_NAME           = @Ls_Procedure_NAME,
              @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
              @Ad_Run_DATE                 = @Ad_Run_DATE,
              @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
              @An_Line_NUMB                = @Ai_RowCount_NUMB,
              @Ac_Error_CODE               = @Lc_Msg_CODE,
              @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
              @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR(50001,16,1);
              END;
            END;
          END;
        END;

       SET @Ls_Sql_TEXT = ' UPDATE DEMO_Y1 - NCP ';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', BirthCity_NAME = ' + ISNULL(@Lc_NcpPlaceOfBirth_TEXT, '') + ', HomePhone_NUMB = ' + ISNULL(CAST(@Ln_HomePhone_NUMB AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_WorkPhone_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_NcpBirth_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Process_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

       EXECUTE BATCH_COMMON$SP_UPDATE_DEMO
        @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
        @Ac_BirthCity_NAME        = @Lc_NcpPlaceOfBirth_TEXT,
        @An_HomePhone_NUMB        = @Ln_HomePhone_NUMB,
        @An_WorkPhone_NUMB        = @Ln_WorkPhone_NUMB,
        @Ad_Birth_DATE            = @Ld_NcpBirth_DATE,
        @Ac_Process_ID            = @Ac_JobProcess_IDNO,
        @Ad_Process_DATE          = @Ad_Run_DATE,
        @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
        @Ac_Msg_CODE              = @Ls_DescriptionError_TEXT OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
          @An_Line_NUMB                = @Ai_RowCount_NUMB,
          @Ac_Error_CODE               = @Lc_ErrorUpdatefailed_CODE,
          @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;
        END;

       IF @Ln_NcpMemberSsn_NUMB != 0
          AND NOT EXISTS (SELECT 1
                            FROM MSSN_Y1
                           WHERE EndValidity_DATE = @Ld_High_DATE
                             AND MemberSsn_NUMB = @Ln_NcpMemberSsn_NUMB
                             AND MemberMci_IDNO != @Ln_MemberMci_IDNO
                             AND Enumeration_CODE NOT IN ('B'))
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 FOR MemberSsn_NUMB INSERT';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpMemberSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Ac_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_INSERT_MSSN
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @An_MemberSsn_NUMB        = @Ln_NcpMemberSsn_NUMB,
          @Ac_Enumeration_CODE      = @Ac_Enumeration_CODE,
          @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       IF @Ln_NcpAliasSsn1_NUMB != 0
          AND NOT EXISTS (SELECT 1
                            FROM MSSN_Y1
                           WHERE EndValidity_DATE = @Ld_High_DATE
                             AND MemberSsn_NUMB = @Ln_NcpAliasSsn1_NUMB
                             AND MemberMci_IDNO != @Ln_MemberMci_IDNO
                             AND Enumeration_CODE NOT IN ('B'))
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 ALIAS SSN1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpAliasSsn1_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Ac_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_INSERT_MSSN
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @An_MemberSsn_NUMB        = @Ln_NcpAliasSsn1_NUMB,
          @Ac_Enumeration_CODE      = @Ac_Enumeration_CODE,
          @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       IF @Ln_NcpAliasSsn2_NUMB != 0
          AND NOT EXISTS (SELECT 1
                            FROM MSSN_Y1
                           WHERE EndValidity_DATE = @Ld_High_DATE
                             AND MemberSsn_NUMB = @Ln_NcpAliasSsn2_NUMB
                             AND MemberMci_IDNO != @Ln_MemberMci_IDNO
                             AND Enumeration_CODE NOT IN ('B'))
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 Alias SSN2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_NcpAliasSsn2_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Ac_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_INSERT_MSSN
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @An_MemberSsn_NUMB        = @Ln_NcpAliasSsn2_NUMB,
          @Ac_Enumeration_CODE      = @Ac_Enumeration_CODE,
          @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       SET @Ln_Sequence_NUMB = 0;

       IF (LTRIM(@Lc_NcpAlias1First_NAME) <> @Lc_Empty_TEXT
            OR LTRIM(@Lc_NcpAlias1Last_NAME) <> @Lc_Empty_TEXT)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT AKAX_Y1 ALIAS NAME1';
         SET @Ln_Sequence_NUMB = @Ln_Sequence_NUMB + 1;
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', LastAlias_NAME = ' + ISNULL(@Lc_NcpAlias1Last_NAME, '') + ', FirstAlias_NAME = ' + ISNULL(@Lc_NcpAlias1First_NAME, '') + ', MiAlias_NAME = ' + ISNULL(@Lc_NcpAlias1Middle_NAME, '') + ', MaidenAlias_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', SuffixAlias_NAME = ' + ISNULL(@Lc_NcpAlias1Suffix_NAME, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Source_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_INSERT_AKAX
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @Ac_LastAlias_NAME        = @Lc_NcpAlias1Last_NAME,
          @Ac_FirstAlias_NAME       = @Lc_NcpAlias1First_NAME,
          @Ac_MiAlias_NAME          = @Lc_NcpAlias1Middle_NAME,
          @Ac_MaidenAlias_NAME      = @Lc_Space_TEXT,
          @Ac_SuffixAlias_NAME      = @Lc_NcpAlias1Suffix_NAME,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ac_Source_CODE           = @Lc_SourceLoc_CODE,
          @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       IF (LTRIM(@Lc_NcpAlias2First_NAME) <> @Lc_Empty_TEXT
            OR LTRIM(@Lc_NcpAlias2Last_NAME) <> @Lc_Empty_TEXT)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT AKAX_Y1 ALIAS NAME2';
         SET @Ln_Sequence_NUMB = @Ln_Sequence_NUMB + 1;
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', LastAlias_NAME = ' + ISNULL(@Lc_NcpAlias2Last_NAME, '') + ', FirstAlias_NAME = ' + ISNULL(@Lc_NcpAlias2First_NAME, '') + ', MiAlias_NAME = ' + ISNULL(@Lc_NcpAlias2Middle_NAME, '') + ', MaidenAlias_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', SuffixAlias_NAME = ' + ISNULL(@Lc_NcpAlias2Suffix_NAME, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Source_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_INSERT_AKAX
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @Ac_LastAlias_NAME        = @Lc_NcpAlias2Last_NAME,
          @Ac_FirstAlias_NAME       = @Lc_NcpAlias2First_NAME,
          @Ac_MiAlias_NAME          = @Lc_NcpAlias2Middle_NAME,
          @Ac_MaidenAlias_NAME      = @Lc_Space_TEXT,
          @Ac_SuffixAlias_NAME      = @Lc_NcpAlias2Suffix_NAME,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ac_Source_CODE           = @Lc_SourceLoc_CODE,
          @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;

       IF (LTRIM(@Lc_NcpAlias3First_NAME) <> @Lc_Empty_TEXT
            OR LTRIM(@Lc_NcpAlias3Last_NAME) <> @Lc_Empty_TEXT)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT AKAX_Y1 Alias Name3';
         SET @Ln_Sequence_NUMB = @Ln_Sequence_NUMB + 1;
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', LastAlias_NAME = ' + ISNULL(@Lc_NcpAlias3Last_NAME, '') + ', FirstAlias_NAME = ' + ISNULL(@Lc_NcpAlias3First_NAME, '') + ', MiAlias_NAME = ' + ISNULL(@Lc_NcpAlias3Middle_NAME, '') + ', MaidenAlias_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', SuffixAlias_NAME = ' + ISNULL(@Lc_NcpAlias3Suffix_NAME, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Source_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_INSERT_AKAX
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @Ac_LastAlias_NAME        = @Lc_NcpAlias3Last_NAME,
          @Ac_FirstAlias_NAME       = @Lc_NcpAlias3First_NAME,
          @Ac_MiAlias_NAME          = @Lc_NcpAlias3Middle_NAME,
          @Ac_MaidenAlias_NAME      = @Lc_Space_TEXT,
          @Ac_SuffixAlias_NAME      = @Lc_NcpAlias3Suffix_NAME,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ac_Source_CODE           = @Lc_SourceLoc_CODE,
          @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;
      END;
    END;

   IF (@Li_Participant_QNTY > @Li_Zero_NUMB)
    BEGIN
     SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;
     SET @Lc_SsnMatch_CODE = @Lc_Space_TEXT;
     SET @Lc_ExactMatch_INDC = @Lc_Space_TEXT;
     SET @Ls_Sql_TEXT = 'CP/DEPENDENT CURSOR';
     SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

     DECLARE RecCPDP_CUR INSENSITIVE CURSOR FOR
      SELECT DISTINCT
             a.First_NAME,
             SUBSTRING(a.Last_NAME, 1, 20) AS Last_NAME,
             a.Middle_NAME,
             a.Suffix_NAME,
             a.Birth_DATE,
             a.Race_CODE,
             a.MemberSex_CODE,
             a.MemberSsn_NUMB,
             a.PlaceOfBirth_NAME,
             a.ParticipantLine1_ADDR,
             a.ParticipantLine2_ADDR,
             a.ParticipantCity_ADDR,
             a.ParticipantState_ADDR,
             a.ParticipantZip_ADDR,
             b.PartNormalization_CODE,
             a.Relationship_CODE,
             a.ConfirmedAddress_INDC,
             a.ChildPaternityStatus_CODE,
             a.WorkPhone_NUMB,
             a.Employer_NAME,
             a.EmployerLine1_ADDR,
             a.EmployerLine2_ADDR,
             a.EmployerCity_ADDR,
             a.EmployerState_ADDR,
             a.EmployerZip_ADDR,
             a.EinEmployer_ID,
             CASE LTRIM(RTRIM(a.ConfirmedEmployer_INDC))
              WHEN @Lc_Empty_TEXT
               THEN @Lc_StatusPending_CODE
              ELSE a.ConfirmedEmployer_INDC
             END
        FROM CPTB_Y1 a,
             LPBLK_Y1 b,
             CTHB_Y1 d
       WHERE d.Transaction_IDNO = @An_Transaction_IDNO
         AND a.TransHeader_IDNO = d.TransHeader_IDNO
         AND a.Transaction_DATE = @Ad_Transaction_DATE
         AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
         AND a.Relationship_CODE IN (@Lc_RelationshipCaseCp_TEXT, @Lc_RelationshipCaseDp_TEXT)
         AND b.TransHeader_IDNO = d.Transaction_IDNO
         AND b.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE
         AND a.BlockSeq_NUMB = b.BlockSeq_NUMB;

     OPEN RecCPDP_CUR;

     FETCH NEXT FROM RecCPDP_CUR INTO @Lc_RecCPDPCur_First_NAME, @Lc_RecCPDPCur_Last_NAME, @Lc_RecCPDPCur_Middle_NAME, @Lc_RecCPDPCur_Suffix_NAME, @Ld_RecCPDPCur_Birth_DATE, @Lc_RecCPDPCur_Race_CODE, @Lc_RecCPDPCur_MemberSex_CODE, @Ln_RecCPDPCur_MemberSsn_NUMB, @Lc_RecCPDPCur_PlaceOfBirth_NAME, @Lc_RecCPDPCur_ParticipantLine1_ADDR, @Lc_RecCPDPCur_ParticipantLine2_ADDR, @Lc_RecCPDPCur_ParticipantCity_ADDR, @Lc_RecCPDPCur_ParticipantState_ADDR, @Lc_RecCPDPCur_ParticipantZip_ADDR, @Lc_RecCPDPCur_PartNormalization_CODE, @Lc_RecCPDPCur_Relationship_CODE, @Lc_RecCPDPCur_ConfirmedAddress_INDC, @Lc_RecCPDPCur_ChildPaternityStatus_CODE, @Ln_RecCPDPCur_WorkPhone_NUMB, @Ls_RecCPDPCur_Employer_NAME, @Lc_RecCPDPCur_EmployerLine1_ADDR, @Lc_RecCPDPCur_EmployerLine2_ADDR, @Lc_RecCPDPCur_EmployerCity_ADDR, @Lc_RecCPDPCur_EmployerState_ADDR, @Lc_RecCPDPCur_EmployerZip_ADDR, @Lc_RecCPDPCur_EmployerEin_ID, @Lc_RecCPDPCur_ConfirmedEmployer_INDC;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     -- Update the information of CP and Dependent 
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;
       SET @Lc_SsnMatch_CODE = @Lc_Empty_TEXT;
       SET @Lc_NameMatch_INDC = @Lc_Empty_TEXT;
       SET @Lc_ExactMatch_INDC = @Lc_Empty_TEXT;
       SET @Lc_MultMatch_INDC = @Lc_Empty_TEXT;
       SET @Lc_Msg_CODE = @Lc_Empty_TEXT;
       SET @Ls_DescriptionError_TEXT = @Lc_Empty_TEXT;
       SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_MEMBER_CLEARENCE ';
       SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_RecCPDPCur_MemberSsn_NUMB AS VARCHAR), '') + ', First_NAME = ' + ISNULL(@Lc_RecCPDPCur_First_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_RecCPDPCur_Last_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_RecCPDPCur_Middle_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_RecCPDPCur_MemberSex_CODE, '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_RecCPDPCur_Birth_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_MEMBER_CLEARENCE
        @An_MemberMci_IDNO        = 0,
        @An_MemberSsn_NUMB        = @Ln_RecCPDPCur_MemberSsn_NUMB,
        @Ac_First_NAME            = @Lc_RecCPDPCur_First_NAME,
        @Ac_Last_NAME             = @Lc_RecCPDPCur_Last_NAME,
        @Ac_Middle_NAME           = @Lc_RecCPDPCur_Middle_NAME,
        @Ac_MemberSex_CODE        = @Lc_RecCPDPCur_MemberSex_CODE,
        @Ad_Birth_DATE            = @Ld_RecCPDPCur_Birth_DATE,
        @An_MemberMciOut_IDNO     = @Ln_MemberMci_IDNO OUTPUT,
        @Ac_MemberSsnMatch_INDC   = @Lc_SsnMatch_CODE OUTPUT,
        @Ac_NameMatch_INDC        = @Lc_NameMatch_INDC OUTPUT,
        @Ac_ExactMatch_INDC       = @Lc_ExactMatch_INDC OUTPUT,
        @Ac_MultMatch_INDC        = @Lc_MultMatch_INDC OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
          @An_Line_NUMB                = @Ai_RowCount_NUMB,
          @Ac_Error_CODE               = 'E0222',
          @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;

         SET @Ln_MemberMci_IDNO = @Li_Zero_NUMB;
        END;

       IF (@Ln_MemberMci_IDNO != 0)
        BEGIN
         IF @Lc_RecCPDPCur_Relationship_CODE = @Lc_RelationshipCaseCp_TEXT
            AND @Lc_RecCPDPCur_ConfirmedAddress_INDC IN (@Lc_Yes_INDC, @Lc_ConfirmedGood_CODE)
            AND LTRIM(@Lc_RecCPDPCur_ParticipantLine1_ADDR) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ls_Sql_TEXT = 'RESIDENTIAL ADDRESS FOR CP UPDATE';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressR_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_RecCPDPCur_ParticipantLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Lc_RecCPDPCur_ParticipantLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_RecCPDPCur_ParticipantCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_RecCPDPCur_ParticipantState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_RecCPDPCur_ParticipantZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusPending_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedByI_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', SignedonWorker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', OfficeSignedon_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_Normalization_CODE, '');

           EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
            @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
            @Ad_Run_DATE                         = @Ad_Run_DATE,
            @Ac_TypeAddress_CODE                 = @Lc_TypeAddressR_CODE,
            @Ad_Begin_DATE                       = @Ad_Run_DATE,
            @Ad_End_DATE                         = @Ld_High_DATE,
            @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
            @As_Line1_ADDR                       = @Lc_RecCPDPCur_ParticipantLine1_ADDR,
            @As_Line2_ADDR                       = @Lc_RecCPDPCur_ParticipantLine2_ADDR,
            @Ac_City_ADDR                        = @Lc_RecCPDPCur_ParticipantCity_ADDR,
            @Ac_State_ADDR                       = @Lc_RecCPDPCur_ParticipantState_ADDR,
            @Ac_Zip_ADDR                         = @Lc_RecCPDPCur_ParticipantZip_ADDR,
            @Ac_Country_ADDR                     = @Lc_Space_TEXT,
            @An_Phone_NUMB                       = @Li_Zero_NUMB,
            @Ac_SourceLoc_CODE                   = @Lc_SourceLoc_CODE,
            @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
            @Ad_Status_DATE                      = @Ad_Run_DATE,
            @Ac_Status_CODE                      = @Lc_StatusPending_CODE,
            @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedByI_CODE,
            @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
            @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
            @Ac_Process_ID                       = @Ac_JobProcess_IDNO,
            @Ac_SignedonWorker_ID                = @Ac_BatchRunUser_TEXT,
            @An_TransactionEventSeq_NUMB         = 0,
            @An_OfficeSignedon_IDNO              = @Li_Zero_NUMB,
            @Ac_Normalization_CODE               = @Lc_Normalization_CODE,
            @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
            BEGIN
             SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

             EXECUTE BATCH_COMMON$SP_BATE_LOG
              @As_Process_NAME             = @Ls_Process_NAME,
              @As_Procedure_NAME           = @Ls_Procedure_NAME,
              @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
              @Ad_Run_DATE                 = @Ad_Run_DATE,
              @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
              @An_Line_NUMB                = @Ai_RowCount_NUMB,
              @Ac_Error_CODE               = @Lc_Msg_CODE,
              @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
              @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR(50001,16,1);
              END;
            END;
          END;

         IF @Lc_RecCPDPCur_ConfirmedEmployer_INDC IN (@Lc_Yes_INDC, @Lc_No_INDC, @Lc_ConfirmedGood_CODE, @Lc_Space_TEXT, @Lc_StatusPending_CODE)
            AND LTRIM(@Ls_RecCPDPCur_Employer_NAME) <> @Lc_Empty_TEXT
            AND LTRIM(@Lc_RecCPDPCur_EmployerLine1_ADDR) <> @Lc_Empty_TEXT
          BEGIN
           SET @Ln_EmployerEin_ID = CAST((CASE @Lc_RecCPDPCur_EmployerEin_ID
                                           WHEN @Lc_Empty_TEXT
                                            THEN '0'
                                           ELSE @Lc_RecCPDPCur_EmployerEin_ID
                                          END) AS NUMERIC);
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP FOR CP';
           SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_EmployerEin_ID AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_OrderTypeEmployer_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_RecCPDPCur_Employer_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_RecCPDPCur_EmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Lc_RecCPDPCur_EmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_RecCPDPCur_EmployerCity_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_RecCPDPCur_EmployerZip_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_RecCPDPCur_EmployerState_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '');

           EXECUTE BATCH_COMMON$SP_GET_OTHP
            @Ad_Run_DATE                     = @Ad_Run_DATE,
            @An_Fein_IDNO                    = @Ln_EmployerEin_ID,
            @Ac_TypeOthp_CODE                = @Lc_OrderTypeEmployer_CODE,
            @As_OtherParty_NAME              = @Ls_RecCPDPCur_Employer_NAME,
            @Ac_Aka_NAME                     = @Lc_Space_TEXT,
            @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
            @As_Line1_ADDR                   = @Lc_RecCPDPCur_EmployerLine1_ADDR,
            @As_Line2_ADDR                   = @Lc_RecCPDPCur_EmployerLine2_ADDR,
            @Ac_City_ADDR                    = @Lc_RecCPDPCur_EmployerCity_ADDR,
            @Ac_Zip_ADDR                     = @Lc_RecCPDPCur_EmployerZip_ADDR,
            @Ac_State_ADDR                   = @Lc_RecCPDPCur_EmployerState_ADDR,
            @Ac_Fips_CODE                    = @Lc_Space_TEXT,
            @Ac_Country_ADDR                 = @Lc_Space_TEXT,
            @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
            @An_Phone_NUMB                   = @Li_Zero_NUMB,
            @An_Fax_NUMB                     = @Li_Zero_NUMB,
            @As_Contact_EML                  = @Lc_Space_TEXT,
            @An_ReferenceOthp_IDNO           = @Li_Zero_NUMB,
            @An_BarAtty_NUMB                 = @Li_Zero_NUMB,
            @An_Sein_IDNO                    = @Li_Zero_NUMB,
            @Ac_SourceLoc_CODE               = @Lc_SourceLoc_CODE,
            @Ac_WorkerUpdate_ID              = @Lc_WorkerUpdate_ID,
            @An_DchCarrier_IDNO              = @Ln_MemberMci_IDNO,
            @Ac_Normalization_CODE           = @Lc_No_INDC,
            @Ac_Process_ID                   = @Ac_JobProcess_IDNO,
            @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
            @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
            BEGIN
             SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

             EXECUTE BATCH_COMMON$SP_BATE_LOG
              @As_Process_NAME             = @Ls_Process_NAME,
              @As_Procedure_NAME           = @Ls_Procedure_NAME,
              @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
              @Ad_Run_DATE                 = @Ad_Run_DATE,
              @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
              @An_Line_NUMB                = @Ai_RowCount_NUMB,
              @Ac_Error_CODE               = @Lc_Msg_CODE,
              @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
              @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR(50001,16,1);
              END;
            END;
           ELSE IF (@Lc_Msg_CODE = @Lc_StatusSuccess_CODE)
            BEGIN
             SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_EMPLOYER_UPDATE -2';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_RecCPDPCur_ConfirmedEmployer_INDC, '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeEm_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceVerifiedByI_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '');

             EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
              @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
              @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
              @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
              @Ac_Status_CODE                = @Lc_RecCPDPCur_ConfirmedEmployer_INDC,
              @Ad_Status_DATE                = @Ad_Run_DATE,
              @Ac_TypeIncome_CODE            = @Lc_TypeIncomeEm_CODE,
              @Ac_SourceLocConf_CODE         = @Lc_SourceVerifiedByI_CODE,
              @Ad_Run_DATE                   = @Ad_Run_DATE,
              @Ad_BeginEmployment_DATE       = @Ad_Run_DATE,
              @Ad_EndEmployment_DATE         = @Ld_High_DATE,
              @An_IncomeGross_AMNT           = @Li_Zero_NUMB,
              @An_IncomeNet_AMNT             = @Li_Zero_NUMB,
              @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
              @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
              @Ac_LimitCcpa_INDC             = @Lc_No_INDC,
              @Ac_EmployerPrime_INDC         = @Lc_No_INDC,
			  --Defect 13583 Incoming CSNet batch is not updating the Reasonable Cost field for employment records Start
              @Ac_InsReasonable_INDC         = @Lc_Yes_INDC,
			  --Defect 13583 Incoming CSNet batch is not updating the Reasonable Cost field for employment records End
              @Ac_SourceLoc_CODE             = @Lc_SourceLoc_CODE,
              @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
              @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
              @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
              @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
              @An_CostInsurance_AMNT         = @Li_Zero_NUMB,
              @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
              @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
              @Ac_SignedonWorker_ID          = @Lc_WorkerUpdate_ID,
              @An_TransactionEventSeq_NUMB   = 0,
              @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
              @Ac_Process_ID                 = @Ac_JobProcess_IDNO,
              @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
              BEGIN
               SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

               EXECUTE BATCH_COMMON$SP_BATE_LOG
                @As_Process_NAME             = @Ls_Process_NAME,
                @As_Procedure_NAME           = @Ls_Procedure_NAME,
                @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
                @Ad_Run_DATE                 = @Ad_Run_DATE,
                @Ac_TypeError_CODE           = @Lc_ErrorType_CODE,
                @An_Line_NUMB                = @Ai_RowCount_NUMB,
                @Ac_Error_CODE               = @Lc_Msg_CODE,
                @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
                @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
                @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

               IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                BEGIN
                 RAISERROR(50001,16,1);
                END;
              END;
            END;
          END;

         SET @Ls_Sql_TEXT = 'UPDATE DEMO_Y1 - CP/DP';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', BirthCity_NAME = ' + ISNULL(@Lc_RecCPDPCur_PlaceOfBirth_NAME, '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_RecCPDPCur_WorkPhone_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_RecCPDPCur_Birth_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Process_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_UPDATE_DEMO
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @Ac_BirthCity_NAME        = @Lc_RecCPDPCur_PlaceOfBirth_NAME,
          @An_HomePhone_NUMB        = 0,
          @An_WorkPhone_NUMB        = @Ln_RecCPDPCur_WorkPhone_NUMB,
          @Ad_Birth_DATE            = @Ld_RecCPDPCur_Birth_DATE,
          @Ac_Process_ID            = @Ac_JobProcess_IDNO,
          @Ad_Process_DATE          = @Ad_Run_DATE,
          @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = 'UPDATE DEMO_Y1 FAILED' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorUpdateFailed_INDC,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;

         IF @Ln_RecCPDPCur_MemberSsn_NUMB != 0
            AND NOT EXISTS (SELECT 1
                              FROM MSSN_Y1
                             WHERE EndValidity_DATE = @Ld_High_DATE
                               AND MemberSsn_NUMB = @Ln_RecCPDPCur_MemberSsn_NUMB
                               AND MemberMci_IDNO != @Ln_MemberMci_IDNO
                               AND Enumeration_CODE NOT IN ('B'))
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT MSSN_Y1 - CP MemberSsn_NUMB';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_RecCPDPCur_MemberSsn_NUMB AS VARCHAR), '') + ', Enumeration_CODE = ' + ISNULL(@Ac_Enumeration_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

           EXECUTE BATCH_COMMON$SP_INSERT_MSSN
            @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
            @An_MemberSsn_NUMB        = @Ln_RecCPDPCur_MemberSsn_NUMB,
            @Ac_Enumeration_CODE      = @Ac_Enumeration_CODE,
            @Ad_BeginValidity_DATE    = @Ad_Run_DATE,
            @Ac_Process_ID            = @Ac_JobProcess_IDNO,
            @Ac_WorkerUpdate_ID       = @Ac_BatchRunUser_TEXT,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

             EXECUTE BATCH_COMMON$SP_BATE_LOG
              @As_Process_NAME             = @Ls_Process_NAME,
              @As_Procedure_NAME           = @Ls_Procedure_NAME,
              @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
              @Ad_Run_DATE                 = @Ad_Run_DATE,
              @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
              @An_Line_NUMB                = @Ai_RowCount_NUMB,
              @Ac_Error_CODE               = @Lc_ErrorUpdateFailed_INDC,
              @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
              @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR(50001,16,1);
              END;
            END;
          END;
        END;

       FETCH NEXT FROM RecCPDP_CUR INTO @Lc_RecCPDPCur_First_NAME, @Lc_RecCPDPCur_Last_NAME, @Lc_RecCPDPCur_Middle_NAME, @Lc_RecCPDPCur_Suffix_NAME, @Ld_RecCPDPCur_Birth_DATE, @Lc_RecCPDPCur_Race_CODE, @Lc_RecCPDPCur_MemberSex_CODE, @Ln_RecCPDPCur_MemberSsn_NUMB, @Lc_RecCPDPCur_PlaceOfBirth_NAME, @Lc_RecCPDPCur_ParticipantLine1_ADDR, @Lc_RecCPDPCur_ParticipantLine2_ADDR, @Lc_RecCPDPCur_ParticipantCity_ADDR, @Lc_RecCPDPCur_ParticipantState_ADDR, @Lc_RecCPDPCur_ParticipantZip_ADDR, @Lc_RecCPDPCur_PartNormalization_CODE, @Lc_RecCPDPCur_Relationship_CODE, @Lc_RecCPDPCur_ConfirmedAddress_INDC, @Lc_RecCPDPCur_ChildPaternityStatus_CODE, @Ln_RecCPDPCur_WorkPhone_NUMB, @Ls_RecCPDPCur_Employer_NAME, @Lc_RecCPDPCur_EmployerLine1_ADDR, @Lc_RecCPDPCur_EmployerLine2_ADDR, @Lc_RecCPDPCur_EmployerCity_ADDR, @Lc_RecCPDPCur_EmployerState_ADDR, @Lc_RecCPDPCur_EmployerZip_ADDR, @Lc_RecCPDPCur_EmployerEin_ID, @Lc_RecCPDPCur_ConfirmedEmployer_INDC;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     IF CURSOR_STATUS('LOCAL', 'RecCPDP_CUR') IN (0, 1)
      BEGIN
       CLOSE RecCPDP_CUR;

       DEALLOCATE RecCPDP_CUR;
      END;
    END;

   IF (@Li_CaseData_QNTY > @Li_Zero_NUMB)
    BEGIN
     SET @Ls_Sql_TEXT = 'INTERSTATE_CASE UPDATE';
     SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

     SELECT @Lc_IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE,
            @Lc_IVDOutOfStateCountyFips_CODE = a.IVDOutOfStateCountyFips_CODE,
            @Lc_IVDOutOfStateOfficeFips_CODE = a.IVDOutOfStateOfficeFips_CODE,
            @Lc_IVDOutOfStateCase_ID = a.IVDOutOfStateCase_ID,
            @Ln_Case_IDNO = a.Case_IDNO,
            @Lc_Reason_CODE = a.Reason_CODE,
            @Ln_MemberMci_IDNO = b.MemberMci_IDNO
       FROM CTHB_Y1 a,
            CNCB_Y1 b
      WHERE a.Transaction_IDNO = @An_Transaction_IDNO
        AND a.Transaction_DATE = @Ad_Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
        AND b.TransHeader_IDNO = a.TransHeader_IDNO;

     SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

     SELECT @Lc_TypeCase_CODE = a.TypeCase_CODE,
            @Lc_StatusCase_CODE = a.StatusCase_CODE,
            @Lc_PaymentLine1_ADDR = a.PaymentLine1_ADDR,
            @Lc_PaymentLine2_ADDR = a.PaymentLine2_ADDR,
            @Lc_PaymentCity_ADDR = a.PaymentCity_ADDR,
            @Lc_PaymentState_ADDR = a.PaymentState_ADDR,
            @Lc_PaymentZip_ADDR = a.PaymentZip_ADDR,
            @Lc_ContactLast_NAME = a.Last_NAME,
            @Lc_ContactFirst_NAME = a.First_NAME,
            @Lc_ContactMiddle_NAME = a.Middle_NAME,
            @Lc_ContactSuffix_NAME = a.Suffix_NAME,
            @Lc_ContactLine1_ADDR = a.PaymentLine1_ADDR,
            @Lc_ContactLine2_ADDR = a.PaymentLine2_ADDR,
            @Lc_ContactCity_ADDR = a.PaymentCity_ADDR,
            @Lc_ContactState_ADDR = a.PaymentState_ADDR,
            @Lc_ContactZip_ADDR = a.PaymentZip_ADDR,
            @Ln_ContactPhone_NUMB = a.ContactPhone_NUMB,
            @Ln_ContactFax_NUMB = a.Fax_NUMB,
            @Ls_Contact_EML = a.Contact_EML,
            @Ln_PhoneExtensionCount_NUMB = a.PhoneExtensionCount_NUMB,
            @Lc_RespondingFile_ID = a.RespondingFile_ID,
            @Lc_NondisclosureFinding_INDC = a.NondisclosureFinding_INDC
       FROM CSDB_Y1 a,
            CTHB_Y1 d
      WHERE d.Transaction_IDNO = @An_Transaction_IDNO
        AND a.TransHeader_IDNO = d.TransHeader_IDNO
        AND a.Transaction_DATE = @Ad_Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;

     IF @Ac_Reason_CODE = @Lc_FarProvidstatusupdat_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT STATUS CHANGE';
       SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(CAST(@An_Transaction_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '');

       SELECT @Lc_StatusCase_CODE = a.StatusChange_CODE
         FROM CFOB_Y1 a,
              CTHB_Y1 d
        WHERE d.Transaction_IDNO = @An_Transaction_IDNO
          AND a.TransHeader_IDNO = d.TransHeader_IDNO
          AND a.Transaction_DATE = @Ad_Transaction_DATE
          AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;
      END;

     SET @Ls_Sql_TEXT = 'SELECT @Ln_Value_QNTY FROM FIPS_Y1';
     SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_Value_QNTY = COUNT(1)
       FROM FIPS_Y1 a
      WHERE a.Fips_CODE = ((CASE LTRIM(RTRIM(@Lc_IVDOutOfStateFips_CODE))
                             WHEN @Lc_Empty_TEXT
                              THEN '00'
                             WHEN '0'
                              THEN '00'
                             ELSE @Lc_IVDOutOfStateFips_CODE
                            END) + (CASE LTRIM(RTRIM(@Lc_IVDOutOfStateCountyFips_CODE))
                                     WHEN @Lc_Empty_TEXT
                                      THEN '000'
                                     WHEN '0'
                                      THEN '000'
                                     ELSE @Lc_IVDOutOfStateCountyFips_CODE
                                    END) + (CASE LTRIM(RTRIM(@Lc_IVDOutOfStateOfficeFips_CODE))
                                             WHEN @Lc_Empty_TEXT
                                              THEN '00'
                                             WHEN '0'
                                              THEN '00'
                                             ELSE @Lc_IVDOutOfStateOfficeFips_CODE
                                            END))
        AND a.EndValidity_DATE = @Ld_High_DATE;

     IF (@Ln_Value_QNTY > 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT Valid Record Count FROM ICAS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Li_RowCount_QNTY = COUNT(1)
         FROM ICAS_Y1 a
        WHERE a.Case_IDNO = @Ln_Case_IDNO
          AND a.Status_CODE = @Lc_CaseStatusOpen_CODE
          AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Ls_Sql_TEXT = 'SELECT TRANSACTION EVENT SEQ FROM ICAS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ln_TransactionEventSeqOld_NUMB = a.TransactionEventSeq_NUMB
         FROM ICAS_Y1 a
        WHERE a.Case_IDNO = @Ln_Case_IDNO
          AND a.Status_CODE = @Lc_CaseStatusOpen_CODE
          AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
          AND a.EndValidity_DATE = @Ld_High_DATE;

       IF (@Li_RowCount_QNTY = 1
           AND @Ln_TransactionEventSeqOld_NUMB != 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
         SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

         EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
          @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
          @Ac_Process_ID               = @Ac_JobProcess_IDNO,
          @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
          @Ac_Note_INDC                = @Lc_No_INDC,
          @An_EventFunctionalSeq_NUMB  = 0,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;

         SET @Ls_Sql_TEXT = 'UPDATE ICAS_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqOld_NUMB AS VARCHAR), '');

         UPDATE ICAS_Y1
            SET EndValidity_DATE = @Ad_Run_DATE
         OUTPUT deleted.Case_IDNO,
                (CASE LTRIM(@Lc_IVDOutOfStateCase_ID)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.IVDOutOfStateCase_ID
                  ELSE @Lc_IVDOutOfStateCase_ID
                 END) AS IVDOutOfStateCase_ID,
                deleted.IVDOutOfStateFips_CODE,
                (CASE LTRIM(@Lc_IVDOutOfStateOfficeFips_CODE)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.IVDOutOfStateOfficeFips_CODE
                  ELSE @Lc_IVDOutOfStateOfficeFips_CODE
                 END) AS IVDOutOfStateOfficeFips_CODE,
                (CASE LTRIM(@Lc_IVDOutOfStateCountyFips_CODE)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.IVDOutOfStateCountyFips_CODE
                  ELSE @Lc_IVDOutOfStateCountyFips_CODE
                 END) AS IVDOutOfStateCountyFips_CODE,
                deleted.Status_CODE,
                deleted.Effective_DATE,
                deleted.End_DATE,
                deleted.RespondInit_CODE,
                deleted.ControlByCrtOrder_INDC,
                deleted.ContOrder_DATE,
                deleted.ContOrder_ID,
                (CASE LTRIM(@Lc_RespondingFile_ID)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.IVDOutOfStateFile_ID
                  ELSE @Lc_RespondingFile_ID
                 END) AS IVDOutOfStateFile_ID,
                deleted.Petitioner_NAME,
                (CASE LTRIM(@Lc_ContactFirst_NAME)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.ContactFirst_NAME
                  ELSE @Lc_ContactFirst_NAME
                 END) AS ContactFirst_NAME,
                deleted.Respondent_NAME,
                (CASE LTRIM(@Lc_ContactLast_NAME)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.ContactLast_NAME
                  ELSE @Lc_ContactLast_NAME
                 END) AS ContactLast_NAME,
                (CASE LTRIM(@Lc_ContactMiddle_NAME)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.ContactMiddle_NAME
                  ELSE @Lc_ContactMiddle_NAME
                 END) AS ContactMiddle_NAME,
                (CASE @Ln_ContactPhone_NUMB
                  WHEN 0
                   THEN deleted.PhoneContact_NUMB
                  ELSE @Ln_ContactPhone_NUMB
                 END) AS PhoneContact_NUMB,
                deleted.Referral_DATE,
                (CASE LTRIM(@Ls_Contact_EML)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.Contact_EML
                  ELSE @Ls_Contact_EML
                 END) AS Contact_EML,
                (CASE @Ln_ContactFax_NUMB
                  WHEN 0
                   THEN deleted.FaxContact_NUMB
                  ELSE @Ln_ContactFax_NUMB
                 END) AS FaxContact_NUMB,
                deleted.File_ID,
                deleted.County_IDNO,
                (CASE LTRIM(@Lc_TypeCase_CODE)
                  WHEN @Lc_Empty_TEXT
                   THEN deleted.IVDOutOfStateTypeCase_CODE
                  ELSE @Lc_TypeCase_CODE
                 END) AS IVDOutOfStateTypeCase_CODE,
                deleted.Create_DATE,
                deleted.Worker_ID,
                @Ld_Update_DTTM AS Update_DTTM,
                @Lc_WorkerUpdate_ID AS WorkerUpdate_ID,
                @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                @Ld_High_DATE AS EndValidity_DATE,
                @Ad_Run_DATE AS BeginValidity_DATE,
                deleted.Reason_CODE,
                deleted.RespondentMci_IDNO,
                deleted.PetitionerMci_IDNO,
                deleted.DescriptionComments_TEXT
         INTO ICAS_Y1
          WHERE Case_IDNO = @Ln_Case_IDNO
            AND Status_CODE = @Lc_CaseStatusOpen_CODE
            AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
            AND EndValidity_DATE = @Ld_High_DATE
            AND TransactionEventSeq_NUMB = @Ln_TransactionEventSeqOld_NUMB;

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = @Li_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = ' UPDATE ICAS_Y1 FAILED';
           SET @Ls_Temp_TEXT = @Ls_Sql_TEXT + ' ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorUpdatefailed_CODE,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT INTO BATE FAILED FOR ''' + @Ls_Sql_TEXT + '''. ERROR : ' + @Ls_DescriptionError_TEXT;

             RAISERROR(50001,16,1);
            END;

           RAISERROR(50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'SP_INSERT_CASE_CLOSURE';
         SET @Lc_Fips_CODE = @Ac_IVDOutOfStateFips_CODE + @Ac_IVDOutOfStateCountyFips_CODE + @Ac_IVDOutOfStateOfficeFips_CODE;
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TranStatus_CODE = ' + ISNULL(@Ac_TranStatus_CODE, '') + ', JobProcess_IDNO = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Ac_BatchRunUser_TEXT, '');

         EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_CASECLOSURE
          @An_Case_IDNO             = @Ln_Case_IDNO,
          @Ac_Fips_CODE             = @Lc_Fips_CODE,
          @Ac_Reason_CODE           = @Ac_Reason_CODE,
          @Ad_Run_DATE              = @Ad_Run_DATE,
          @Ac_TranStatus_CODE       = @Ac_TranStatus_CODE,
          @Ac_JobProcess_IDNO       = @Ac_JobProcess_IDNO,
          @Ac_BatchRunUser_TEXT     = @Ac_BatchRunUser_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Temp_TEXT = 'INSERT INTO ELFC_Y1 FAILED ' + @Ls_DescriptionError_TEXT;

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @Ls_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
            @An_Line_NUMB                = @Ai_RowCount_NUMB,
            @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_TEXT,
            @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;
          END;
        END;
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'RecCPDP_CUR') IN (0, 1)
    BEGIN
     CLOSE RecCPDP_CUR;

     DEALLOCATE RecCPDP_CUR;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
