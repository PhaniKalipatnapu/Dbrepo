/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_EMPLOYER_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_EMPLOYER_UPDATE
Programmer Name		: IMP Team
Description			: This procedure is used to update the employer information using the employer de - duplicate process.
					    @Ac_Msg_CODE Possible values are
						'S' = Success
						'F' = Fail i.e) ABEND/Exception 
						'D' = Duplicate employer exists E0145 - Duplicate record exists
						'C' = Record is changed or deleted by some other user. E0153 - This record is being added/updated by another user, please refresh screen
						'E' = Address is end dated within six months from current date. E0640 - This employer information is already available for the date
						'X' = Record was verified bad.Applicable to BATCH only - E1094 - Member employment information confirmed as bad
						'K' = No ICAS record present and should be mapped to W0156 - Interstate Case must be added to ISIN Screen
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_EMPLOYER_UPDATE]
 @An_MemberMci_IDNO             NUMERIC(10),
 @An_OthpPartyEmpl_IDNO         NUMERIC(9),
 @Ad_SourceReceived_DATE        DATE,
 @Ac_Status_CODE                CHAR(1),
 @Ad_Status_DATE                DATE,
 @Ac_TypeIncome_CODE            CHAR(2),
 @Ac_SourceLocConf_CODE         CHAR(3),
 @Ad_Run_DATE                   DATE,
 @Ad_BeginEmployment_DATE       DATE,
 @Ad_EndEmployment_DATE         DATE,
 @An_IncomeGross_AMNT           NUMERIC(11, 2),
 @An_IncomeNet_AMNT             NUMERIC(11, 2),
 @Ac_FreqIncome_CODE            CHAR(1),
 @Ac_FreqPay_CODE               CHAR(1),
 @Ac_LimitCcpa_INDC             CHAR(1),
 @Ac_EmployerPrime_INDC         CHAR(1),
 @Ac_InsReasonable_INDC         CHAR(1),
 @Ac_SourceLoc_CODE             CHAR(3),
 @Ac_InsProvider_INDC           CHAR(1),
 @Ac_DpCovered_INDC             CHAR(1),
 @Ac_DpCoverageAvlb_INDC        CHAR(1),
 @Ad_EligCoverage_DATE          DATE,
 @An_CostInsurance_AMNT         NUMERIC(11, 2),
 @Ac_FreqInsurance_CODE         CHAR(1),
 @Ac_DescriptionOccupation_TEXT CHAR(32),
 @Ac_SignedOnWorker_ID          CHAR(30),
 @An_TransactionEventSeq_NUMB   NUMERIC(19),
 @Ad_PlsLastSearch_DATE         DATE,
 @Ac_Process_ID                 CHAR(10),
 @An_OfficeSignedOn_IDNO        NUMERIC(3) = 0,
 @Ac_Msg_CODE                   CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_AddANewEmployer5310_NUMB          INT = 5310,
          @Li_ModifyEmployer5320_NUMB           INT = 5320,
          @Li_AddVerifiedAGoodEmployer5330_NUMB INT = 5330,
          @Li_InvalidateMemberEmployer5340_NUMB INT = 5340,
          @Li_AddVerifiedAGoodAddress5290_NUMB  INT = 5290,
          @Lc_Space_TEXT                        CHAR(1) = ' ',
          @Lc_No_INDC                           CHAR(1) = 'N',
          @Lc_CaseMemberStatusActive_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE          CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE    CHAR(1) = 'P',
          @Lc_VerificationStatusGood_CODE       CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_Yes_INDC                          CHAR(1) = 'Y',
          @Lc_TypeOrderVoluntary_CODE           CHAR(1) = 'V',
          @Lc_NegPosCloseRemedy_TEXT            CHAR(1) = 'N',
          @Lc_CaseRelationshipDp_CODE           CHAR(1) = 'D',
          @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
          @Lc_RespondInitInitiate_TEXT          CHAR(1) = 'I',
          @Lc_RespondInitResponding_TEXT        CHAR(1) = 'R',
          @Lc_NegPosStartRemedy_CODE            CHAR(1) = 'P',
          @Lc_VerStatusPending_CODE             CHAR(1) = 'P',
          @Lc_IwnStatusActive_CODE              CHAR(1) = 'A',
          @Lc_IwnPerSpecific_CODE               CHAR(1) = 'S',
          @Lc_TypeAddressCourtC_CODE            CHAR(1) = 'C',
          @Lc_VerificationStatusBad_ADDR        CHAR(1) = 'B',
          @Lc_TypeOthpE_CODE                    CHAR(1) = 'E',
          @Lc_TypeOthpM_CODE                    CHAR(1) = 'M',
          @Lc_CaseStatusOpen_CODE               CHAR(1) = 'O',
          @Lc_CaseStatusClose_CODE              CHAR(1) = 'C',
          @Lc_ActionP_CODE                      CHAR(1) = 'P',
          @Lc_StatusLocateN_CODE                CHAR(1) = 'N',
          @Lc_StatusLocateL_CODE                CHAR(1) = 'L',
          @Lc_EmployerPrime_INDC                CHAR(1) = 'N',
          @Lc_EmployerPrimeOld_INDC             CHAR(1) = 'N',
          @Lc_TypeIncomeEmployer_CODE           CHAR(2) = 'EM',
          @Lc_TypeIncomeSelfemployed_CODE       CHAR(2) = 'SE',
          @Lc_TypeIncomeMilitary_CODE           CHAR(2) = 'ML',
          @Lc_TypeChangeEe_CODE                 CHAR(2) = 'EE',
          @Lc_RsnStatusCaseUb_CODE              CHAR(2) = 'UB',
          @Lc_RsnStatusCaseUC_CODE              CHAR(2) = 'UC',
          @Lc_TypeChangeNs_CODE                 CHAR(2) = 'NS',
          @Lc_TypeIncomeUnemployment_CODE       CHAR(2) = 'UA',
          @Lc_TypeIncomeDisability_CODE         CHAR(2) = 'DS',
          @Lc_TypeIncomeUnion_CODE              CHAR(2) = 'UN',
          @Lc_TypeChangeIW_CODE                 CHAR(2) = 'IW',
          @Lc_SubsystemEst_CODE                 CHAR(2) = 'ES',
          @Lc_SubsystemEnforcement_CODE         CHAR(3) = 'EN',
          @Lc_SourceFedcaseregistr_CODE         CHAR(3) = 'FCR',
          @Lc_SourceFedParentLoc_CODE           CHAR(3) = 'FPL',
          @Lc_SourceLocNdh_CODE                 CHAR(3) = 'NDH',
          @Lc_SourceLocOsa_CODE                 CHAR(3) = 'OSA',
          @Lc_SourceLocSnh_CODE                 CHAR(3) = 'SNH',
          @Lc_SourceLocDol_CODE                 CHAR(3) = 'DOL',
          @Lc_SourceLocDoc_CODE                 CHAR(3) = 'DOC',
          @Lc_SourceLocDia_CODE                 CHAR(3) = 'DIA',
          @Lc_SourceLocDjs_CODE                 CHAR(3) = 'DJS',
          @Lc_SourceLocPud_CODE                 CHAR(3) = 'PUD',
          @Lc_SourceLocEmp_CODE                 CHAR(3) = 'EMP',
          @Lc_SourceLocUib_CODE                 CHAR(3) = 'UIB',
          @Lc_FunctionMsc_CODE                  CHAR(3) = 'MSC',
          @Lc_FunctionCsp_CODE                  CHAR(3) = 'CSP',
          @Lc_SourceLocDs_CODE                  CHAR(3) = 'DS',
          @Lc_SubsystemLoc_CODE                 CHAR(3) = 'LO',
          @Lc_MajorActivityCase_CODE            CHAR(4) = 'CASE',
          @Lc_RemedyStatusStart_CODE            CHAR(4) = 'STRT',
          @Lc_ActivityMajorEstp_CODE            CHAR(4) = 'ESTP',
          @Lc_ActivityMinorErccl_CODE           CHAR(5) = 'ERCCL',
          @Lc_ActivityMinorGeisv_CODE           CHAR(5) = 'GEISV',
          @Lc_ActivityMinorNopri_CODE           CHAR(5) = 'NOPRI',
          @Lc_ReasonLsemp_CODE                  CHAR(5) = 'LSEMP',
          @Lc_ActivityMinorSaout_CODE           CHAR(5) = 'SAOUT',
          @Lc_ErrorE1094_CODE                   CHAR(5) = 'E1094',
          @Lc_ErrorE0640_CODE                   CHAR(5) = 'E0640',
          @Lc_ErrorE0153_CODE                   CHAR(5) = 'E0153',
          @Lc_ErrorE0145_CODE                   CHAR(5) = 'E0145',
          @Lc_ErrorW0156_CODE                   CHAR(5) = 'W0156',
          @Lc_ErrorE1424_CODE                   CHAR(5) = 'E1424',
          @Lc_MsgW0156_CODE                     CHAR(5) = NULL,
          @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
          @Lc_MemberDyfsCp_IDNO                 CHAR(6) = '999998',
          @Lc_NoticeLoc02_ID                    CHAR(6) = 'LOC-02',
          @Lc_NoticeEnf14_IDNO                  CHAR(6) = 'ENF-14',
          @Ls_Routine_TEXT                      VARCHAR(60) = 'BATCH_COMMON$SP_EMPLOYER_UPDATE',
          @Ls_XmlTextIn_TEXT                    VARCHAR(4000) = ' ',
          @Ld_High_DATE                         DATE = '12/31/9999',
          @Ld_Low_DATE                          DATE = '01/01/0001',
          @Lb_InitiateRemedy_BIT                BIT = 0,
          @Lb_DateOld_BIT                       BIT = 1;
  DECLARE @Ln_RowCount_QNTY                 NUMERIC,
          @Ln_FetchStatus_QNTY              NUMERIC,
          @Ln_Error_NUMB                    NUMERIC,
          @Ln_Zero_NUMB                     NUMERIC(1) = 0,
          @Ln_OrderSeq_NUMB                 NUMERIC(2),
          @Ln_EventFunctionalSeq_NUMB       NUMERIC(4),
          @Ln_Value_QNTY                    NUMERIC(5, 0),
          @Ln_MemberMci_IDNO                NUMERIC(10),
          @Ln_Topic_NUMB                    NUMERIC(10, 0) = 0,
          @Ln_TopicIn_IDNO                  NUMERIC(10, 0) = 0,
          @Ln_NcpMci_IDNO                   NUMERIC(10),
          @Ln_ErrorLine_NUMB                NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB      NUMERIC(19),
          @Ln_TransactionEventSeqLstt_NUMB  NUMERIC(19, 0),
          @Ln_TransactionEventSeqPrime_NUMB NUMERIC(19, 0),
          @Ln_TransactionEventSeqNew_NUMB   NUMERIC(19, 0),
          @Lc_Null_TEXT                     CHAR(1) = '',
          @Lc_Status_CODE                   CHAR(1),
          @Lc_UpdateStatus_CODE             CHAR(1),
          @Lc_CurrentStatus_CODE            CHAR(1),
          @Lc_DpCoverageAvlb_INDC           CHAR(1),
          @Lc_TypeIncome_CODE               CHAR(2),
          @Lc_SourceLocConf_CODE            CHAR(3),
          @Lc_Subsystem_CODE                CHAR(3),
          @Lc_TypeReference_CODE            CHAR(4),
          @Lc_Msg_CODE                      CHAR(5),
          @Lc_ActivityMinor_CODE            CHAR(5),
          @Lc_Notice_ID                     CHAR(8),
          @Lc_OthpPartyPrime_IDNO           CHAR(9),
          @Ls_Sql_TEXT                      VARCHAR(200),
          @Ls_Sqldata_TEXT                  VARCHAR(1000),
          @Ls_ErrorMessage_TEXT             VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT         VARCHAR(4000) = '',
          @Ld_EndEmployment_DATE            DATE,
          @Ld_BeginEmployment_DATE          DATE,
          @Ld_BeginEmploymentPrime_DATE     DATETIME2,
          @Ld_Start_DATE                    DATETIME2,
          @Lb_NoticeGen_BIT                 BIT = 0,
          @Lb_HehisExist_BIT                BIT = 0,
          @Lb_UpdateFlag_BIT                BIT = 0,
          @Lb_VerStatusGood_BIT             BIT;
  DECLARE @Ln_CaseCur_Case_IDNO             NUMERIC(6),
          @Lc_CaseCur_CaseRelationship_CODE CHAR(1),
          @Ln_CaseCur_Application_IDNO      NUMERIC(15),
          @Lc_CaseCur_RespondInit_CODE      CHAR(1),
          @Li_CaseCur_off_order             INT;
  DECLARE @Ln_CaseCloseCur_Case_IDNO NUMERIC(6),
          @Lc_CaseCloseCur_Worker_ID CHAR(30);
  DECLARE @Case_CUR CURSOR;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_ErrorE1424_CODE;
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Status_CODE = @Ac_Status_CODE;

   -- EHIS screen update 
   IF @An_TransactionEventSeq_NUMB <> 0
    BEGIN
     -- This record is being added/updated by another user, please refresh screen
     SET @Ls_Sql_TEXT = 'SELECT EHIS - 1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ad_BeginEmployment_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '');

     SELECT @Lc_UpdateStatus_CODE = a.Status_CODE,
            @Lc_DpCoverageAvlb_INDC = a.DpCoverageAvlb_INDC,
            @Lc_EmployerPrimeOld_INDC = a.EmployerPrime_INDC,
            @Lc_TypeIncome_CODE = a.TypeIncome_CODE
       FROM EHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
        AND a.BeginEmployment_DATE = @Ad_BeginEmployment_DATE
        AND a.EndEmployment_DATE = @Ld_High_DATE
        AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0153_CODE;
       SET @As_DescriptionError_TEXT = 'THIS RECORD IS BEING ADDED/UPDATED BY ANOTHER USER';

       RETURN;
      END

     IF LTRIM(RTRIM(@Lc_Status_CODE)) = ''
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'INVALID Status_CODE CODE';

       RETURN;
      END

     SET @Lb_VerStatusGood_BIT = 0;
     SET @Ls_Sql_TEXT = 'SELECT EHIS - 2';

     -- Existing record verified status check
     IF EXISTS (SELECT 1
                  FROM EHIS_Y1 a
                 WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                   AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
                   AND a.Status_CODE = @Lc_VerificationStatusGood_CODE)
      BEGIN
       SET @Lb_VerStatusGood_BIT = 1;
      END

     -- Check if the cd_status was updated
     IF @Lc_UpdateStatus_CODE <> @Lc_Status_CODE
      BEGIN
       SET @Lb_UpdateFlag_BIT = 1;

       IF @Lc_Status_CODE = @Lc_VerStatusPending_CODE
        BEGIN
         SET @Lb_NoticeGen_BIT = 1;
        END
       ELSE
        BEGIN
         IF @Lc_Status_CODE <> @Lc_VerStatusPending_CODE
          BEGIN
           SET @Lb_NoticeGen_BIT = 0;
          END
        END
      END

     IF @Lb_VerStatusGood_BIT <> 1
        AND @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
        AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) > @Ad_Run_DATE
      BEGIN
       SET @Ln_EventFunctionalSeq_NUMB = @Li_AddVerifiedAGoodEmployer5330_NUMB;
      END
     ELSE
      BEGIN
       IF ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
        BEGIN
         SET @Ln_EventFunctionalSeq_NUMB = @Li_InvalidateMemberEmployer5340_NUMB;
        END
       ELSE
        BEGIN
         SET @Ln_EventFunctionalSeq_NUMB = @Li_ModifyEmployer5320_NUMB;
        END
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT -1';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     -- The program calculate the primary indicator when a new record is added in EHIS 
     IF ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
      BEGIN
       SET @Lc_EmployerPrime_INDC = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_EmployerPrime_INDC), @Lc_No_INDC);
      END
     ELSE
      BEGIN
       IF ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_EmployerPrime_INDC), @Lc_Yes_INDC) <> @Lc_No_INDC
        BEGIN
         SET @Ls_Sql_TEXT = 'PRIMARY EMPLOYER CHECK';

         IF NOT EXISTS (SELECT 1
                          FROM EHIS_Y1 e
                         WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND e.OthpPartyEmpl_IDNO <> @An_OthpPartyEmpl_IDNO
                           AND e.EndEmployment_DATE = @Ld_High_DATE
                           AND e.EmployerPrime_INDC = @Lc_Yes_INDC)
            AND ISNULL(@Ac_TypeIncome_CODE, @Lc_TypeIncome_CODE) IN (@Lc_TypeIncomeEmployer_CODE, @Lc_TypeIncomeSelfemployed_CODE, @Lc_TypeIncomeMilitary_CODE)
          BEGIN
           SET @Lc_EmployerPrime_INDC = @Lc_Yes_INDC;
          END
         ELSE
          BEGIN
           SET @Lc_EmployerPrime_INDC = @Lc_No_INDC;
          END
        END
       ELSE
        SET @Lc_EmployerPrime_INDC = @Lc_No_INDC;
      END

     SET @Ls_Sql_TEXT = ' UPDATE EHIS_Y1 - 1 ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ad_BeginEmployment_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '');

     UPDATE EHIS_Y1
        SET EndEmployment_DATE = ISNULL(@Ad_EndEmployment_DATE, EndEmployment_DATE),
            Status_CODE = UPPER(@Lc_Status_CODE),
            IncomeGross_AMNT = ISNULL(@An_IncomeGross_AMNT, @Ln_Zero_NUMB),
            IncomeNet_AMNT = ISNULL(@An_IncomeNet_AMNT, @Ln_Zero_NUMB),
            DescriptionOccupation_TEXT = ISNULL(@Ac_DescriptionOccupation_TEXT, @Lc_Space_TEXT),
            WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
            SourceReceived_DATE = ISNULL(@Ad_SourceReceived_DATE, SourceReceived_DATE),
            FreqPay_CODE = ISNULL(@Ac_FreqPay_CODE, @Lc_Space_TEXT),
            SourceLoc_CODE = ISNULL(@Ac_SourceLoc_CODE, SourceLoc_CODE),
            SourceLocConf_CODE = ISNULL(@Ac_SourceLocConf_CODE, SourceLocConf_CODE),
            EligCoverage_DATE = ISNULL(@Ad_EligCoverage_DATE, @Ld_Low_DATE),
            DpCovered_INDC = ISNULL(@Ac_DpCovered_INDC, DpCovered_INDC),
            CostInsurance_AMNT = ISNULL(@An_CostInsurance_AMNT, @Ln_Zero_NUMB),
            FreqInsurance_CODE = ISNULL(@Ac_FreqInsurance_CODE, @Lc_Space_TEXT),
            Status_DATE = ISNULL(@Ad_Status_DATE, Status_DATE),
            FreqIncome_CODE = ISNULL(@Ac_FreqIncome_CODE, @Lc_Space_TEXT),
            InsProvider_INDC = ISNULL(@Ac_InsProvider_INDC, InsProvider_INDC),
            DpCoverageAvlb_INDC = ISNULL(@Ac_DpCoverageAvlb_INDC, DpCoverageAvlb_INDC),
            EmployerPrime_INDC = ISNULL(@Lc_EmployerPrime_INDC, EmployerPrime_INDC),
            InsReasonable_INDC = ISNULL(@Ac_InsReasonable_INDC, InsReasonable_INDC),
            LimitCcpa_INDC = ISNULL(@Ac_LimitCcpa_INDC, @Lc_No_INDC),
            PlsLastSearch_DATE = ISNULL(@Ad_PlsLastSearch_DATE, PlsLastSearch_DATE),
            BeginValidity_DATE = @Ad_Run_DATE,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
     OUTPUT deleted.MemberMci_IDNO,
            deleted.OthpPartyEmpl_IDNO,
            deleted.BeginEmployment_DATE,
            deleted.EndEmployment_DATE,
            deleted.TypeIncome_CODE,
            deleted.DescriptionOccupation_TEXT,
            deleted.IncomeNet_AMNT,
            deleted.IncomeGross_AMNT,
            deleted.FreqIncome_CODE,
            deleted.FreqPay_CODE,
            deleted.SourceLoc_CODE,
            deleted.SourceReceived_DATE,
            deleted.Status_CODE,
            deleted.Status_DATE,
            deleted.SourceLocConf_CODE,
            deleted.InsProvider_INDC,
            deleted.CostInsurance_AMNT,
            deleted.FreqInsurance_CODE,
            deleted.DpCoverageAvlb_INDC,
            deleted.EmployerPrime_INDC,
            deleted.DpCovered_INDC,
            deleted.EligCoverage_DATE,
            deleted.InsReasonable_INDC,
            deleted.LimitCcpa_INDC,
            deleted.PlsLastSearch_DATE,
            deleted.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            deleted.WorkerUpdate_ID,
            deleted.Update_DTTM AS Update_DTTM,
            deleted.TransactionEventSeq_NUMB
     INTO HEHIS_Y1
      WHERE EHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
        AND EHIS_Y1.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
        AND EHIS_Y1.BeginEmployment_DATE = @Ad_BeginEmployment_DATE
        AND EHIS_Y1.EndEmployment_DATE = @Ld_High_DATE
        AND EHIS_Y1.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'UPDATE EHIS_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     IF ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
      BEGIN
      /* When a SOI record is end-dated, automatically creates an entry in the VELFC table using the following mapping to close the income withholding 
      and/or NMSN remedies associated with the SOI/member combination */
      /* For CP or NCP  when the SOI End Date is not null and the member is ordered to provide insurance and only End Dated Insurance 
      records exist = trigger the generation of the `COBRA Coverage to the Ordered Party  CS192 to be mailed to the member ordered to provide insurance. */
      /* For CP or NCP  when the SOI End Date is not null and the member is ordered to provide insurance and only End Dated Insurance 
      records exist = trigger the generation of the `Possible Insurance Termination Coverage to the CP  CS194 to be mailed to the CP. */
       -- Cursor selects all the cases for the member
       SET @Case_CUR = CURSOR LOCAL FORWARD_ONLY
       FOR SELECT c.Case_IDNO,
                  m.CaseRelationship_CODE,
                  c.Application_IDNO,
                  c.RespondInit_CODE,
                  /*selecting the cases of member order by cd_office 
                     1) When the CS563, CS014 and CS010 are generated by BATCH then only the most recent 
                        case should populate on the form, irrespective of the county.
                     2) When the CS563, CS014 and CS010 are generated is generated online, then the forms 
                        should populate with the members case from the same county as the logged in worker. 
                        When there is more than one case from the same county as the logged in worker, 
                        the system must select the most recent case of that same county. 
                     3) There should be a Case Journal entry for ALL of the member's cases.
                     4) If the logged in worker does not belong to a county where the member has a case - AOC, 
                        DFD (office 500 or 900) etc.  - then follow the same logic as for the BATCH process.*/
                  CASE
                   WHEN c.Office_IDNO = @An_OfficeSignedOn_IDNO
                    THEN 1
                   ELSE 2
                  END AS off_order
             FROM CASE_Y1 c,
                  CMEM_Y1 m
            WHERE @An_MemberMci_IDNO = m.MemberMci_IDNO
              AND m.CaseMemberStatus_CODE = 'A'
              AND m.CaseRelationship_CODE IN ('C', 'A', 'P')
              AND m.Case_IDNO = c.Case_IDNO
              AND c.StatusCase_CODE = 'O'
            ORDER BY off_order,
                     c.Opened_DATE DESC;
       SET @Ls_Sql_TEXT ='OPEN @Case_CUR -1';

       OPEN @Case_CUR;

       SET @Ls_Sql_TEXT ='FETCH @Case_CUR -1';

       FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE -1';

       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT VSORD1';

         SELECT @Ln_OrderSeq_NUMB = s.OrderSeq_NUMB
           FROM SORD_Y1 s
          WHERE @Ln_CaseCur_Case_IDNO = s.Case_IDNO
            AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE-- Including Tribunal, Administrative, and Judicial Order Types for enforcement eligibility
            AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
            AND s.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ln_OrderSeq_NUMB = 0;
          END

         IF @Ln_OrderSeq_NUMB <> 0
          BEGIN
           -- Added parameters id_reference and cd_type_reference in sp_insert_elfc procedure.
           -- and passed ncp/pf id_member as reference to correct the process
           SET @Ls_Sql_TEXT = 'SELECT VCMEM1';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE, '');

           SELECT @Ln_NcpMci_IDNO = n.MemberMci_IDNO,
                  @Lc_TypeReference_CODE = n.CaseRelationship_CODE
             FROM CMEM_Y1 n
            WHERE n.Case_IDNO = @Ln_CaseCur_Case_IDNO
              AND n.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
              AND EXISTS (SELECT 1
                            FROM CMEM_Y1 m
                           WHERE m.Case_IDNO = n.Case_IDNO
                             AND m.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND m.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE);

           SET @Ln_RowCount_QNTY=@@ROWCOUNT;

           IF @Ln_RowCount_QNTY = 0
            BEGIN
             SET @Ln_NcpMci_IDNO = @An_MemberMci_IDNO;
             SET @Lc_TypeReference_CODE = @Lc_CaseRelationshipNcp_CODE;
            END
           ELSE
            BEGIN
             SET @Lc_TypeReference_CODE = @Lc_CaseRelationshipCp_CODE;
            END

           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NcpMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangeEe_CODE, '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPosCloseRemedy_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', Create_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Reference_ID = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

           EXECUTE BATCH_COMMON$SP_INSERT_ELFC
            @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
            @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
            @An_MemberMci_IDNO           = @Ln_NcpMci_IDNO,
            @An_OthpSource_IDNO          = @An_OthpPartyEmpl_IDNO,
            @Ac_TypeChange_CODE          = @Lc_TypeChangeEe_CODE,
            @Ac_NegPos_CODE              = @Lc_NegPosCloseRemedy_TEXT,
            @Ac_Process_ID               = @Ac_Process_ID,
            @Ad_Create_DATE              = @Ad_Run_DATE,
            @Ac_Reference_ID             = @An_MemberMci_IDNO,
            @Ac_TypeReference_CODE       = @Lc_TypeReference_CODE,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR (50001,16,1);
            END
          END

         SET @Ls_Sql_TEXT ='FETCH @Case_CUR -2';

         FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE @Case_CUR;

       DEALLOCATE @Case_CUR;
      END

     -- When a existing primary employer is end dated then a new employer will made primary based on CR124 
     IF ((ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
          AND @Lc_EmployerPrimeOld_INDC = @Lc_Yes_INDC)
          OR (@Lc_EmployerPrimeOld_INDC = @Lc_Yes_INDC
              AND @Lc_EmployerPrime_INDC = @Lc_No_INDC))
        AND NOT EXISTS (SELECT 1
                          FROM EHIS_Y1 e
                         WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND e.OthpPartyEmpl_IDNO <> @An_OthpPartyEmpl_IDNO
                           AND e.TypeIncome_CODE IN (@Lc_TypeIncomeEmployer_CODE, @Lc_TypeIncomeSelfemployed_CODE, @Lc_TypeIncomeMilitary_CODE)
                           AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
                           AND e.EndEmployment_DATE = @Ld_High_DATE
                           AND e.EmployerPrime_INDC = @Lc_Yes_INDC)
      BEGIN
       SELECT @Lc_OthpPartyPrime_IDNO = f.OthpPartyEmpl_IDNO,
              @Ld_BeginEmploymentPrime_DATE = f.BeginEmployment_DATE,
              @Ln_TransactionEventSeqPrime_NUMB = f.TransactionEventSeq_NUMB
         FROM (SELECT e.OthpPartyEmpl_IDNO,
                      e.BeginEmployment_DATE,
                      e.TransactionEventSeq_NUMB,
                      ROW_NUMBER() OVER( ORDER BY e.BeginEmployment_DATE DESC, e.BeginValidity_DATE, e.TransactionEventSeq_NUMB) AS Row_NUMB
                 FROM EHIS_Y1 e
                WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                  AND e.OthpPartyEmpl_IDNO <> @An_OthpPartyEmpl_IDNO
                  AND e.TypeIncome_CODE IN (@Lc_TypeIncomeEmployer_CODE, @Lc_TypeIncomeSelfemployed_CODE, @Lc_TypeIncomeMilitary_CODE)
                  AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
                  AND e.EndEmployment_DATE = @Ld_High_DATE
                  AND NOT EXISTS (SELECT 1
                                    FROM IWEM_Y1 i
                                   WHERE e.MemberMci_IDNO = i.MemberMci_IDNO
                                     AND e.OthpPartyEmpl_IDNO = i.OthpEmployer_IDNO
                                     AND i.IwnStatus_CODE = @Lc_IwnStatusActive_CODE
                                     AND i.IwnPer_CODE = @Lc_IwnPerSpecific_CODE
                                     AND i.End_DATE = @Ld_High_DATE
                                     AND i.EndValidity_DATE = @Ld_High_DATE)) AS f
        WHERE f.Row_NUMB = 1;

       SET @Ln_RowCount_QNTY=@@ROWCOUNT;

       IF @Ln_RowCount_QNTY != 0
        BEGIN
         --Generating new TransactionEventSeqNew_NUMB to set the selected employer as primary
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT-2';
         SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ModifyEmployer5320_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

         EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
          @An_EventFunctionalSeq_NUMB  = @Li_ModifyEmployer5320_NUMB,
          @Ac_Process_ID               = @Ac_Process_ID,
          @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
          @Ac_Note_INDC                = @Lc_No_INDC,
          @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeqNew_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = ' UPDATE EHIS_Y1 - 2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(@Lc_OthpPartyPrime_IDNO, '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_BeginEmploymentPrime_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqPrime_NUMB AS VARCHAR), '');

         UPDATE EHIS_Y1
            SET EmployerPrime_INDC = @Lc_Yes_INDC,
                BeginValidity_DATE = @Ad_Run_DATE,
                TransactionEventSeq_NUMB = @Ln_TransactionEventSeqNew_NUMB,
                Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
                WorkerUpdate_ID = @Ac_SignedOnWorker_ID
         OUTPUT deleted.MemberMci_IDNO,
                deleted.OthpPartyEmpl_IDNO,
                deleted.BeginEmployment_DATE,
                deleted.EndEmployment_DATE,
                deleted.TypeIncome_CODE,
                deleted.DescriptionOccupation_TEXT,
                deleted.IncomeNet_AMNT,
                deleted.IncomeGross_AMNT,
                deleted.FreqIncome_CODE,
                deleted.FreqPay_CODE,
                deleted.SourceLoc_CODE,
                deleted.SourceReceived_DATE,
                deleted.Status_CODE,
                deleted.Status_DATE,
                deleted.SourceLocConf_CODE,
                deleted.InsProvider_INDC,
                deleted.CostInsurance_AMNT,
                deleted.FreqInsurance_CODE,
                deleted.DpCoverageAvlb_INDC,
                deleted.EmployerPrime_INDC,
                deleted.DpCovered_INDC,
                deleted.EligCoverage_DATE,
                deleted.InsReasonable_INDC,
                deleted.LimitCcpa_INDC,
                deleted.PlsLastSearch_DATE,
                deleted.BeginValidity_DATE,
                @Ad_Run_DATE AS EndValidity_DATE,
                deleted.WorkerUpdate_ID,
                deleted.Update_DTTM AS Update_DTTM,
                deleted.TransactionEventSeq_NUMB
         INTO HEHIS_Y1
          WHERE EHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
            AND EHIS_Y1.OthpPartyEmpl_IDNO = @Lc_OthpPartyPrime_IDNO
            AND EHIS_Y1.BeginEmployment_DATE = @Ld_BeginEmploymentPrime_DATE
            AND EHIS_Y1.EndEmployment_DATE = @Ld_High_DATE
            AND EHIS_Y1.TransactionEventSeq_NUMB = @Ln_TransactionEventSeqPrime_NUMB;

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
           SET @As_DescriptionError_TEXT = 'UPDATE EHIS_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END
      END

     IF @Lc_DpCoverageAvlb_INDC = @Lc_Yes_INDC
        AND @Ac_DpCoverageAvlb_INDC = @Lc_No_INDC
        AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) = @Ld_High_DATE
      BEGIN
       /*
       When a SOI record is end-dated, system automatically creates an entry in the ELFC table
       using the following mapping to close the income withholding and/or NMSN remedies associated
       with the SOI/member combination
       */
       SET @Case_CUR = CURSOR LOCAL FORWARD_ONLY
       FOR SELECT c.Case_IDNO,
                  m.CaseRelationship_CODE,
                  c.Application_IDNO,
                  c.RespondInit_CODE,
                  CASE
                   WHEN c.Office_IDNO = @An_OfficeSignedOn_IDNO
                    THEN 1
                   ELSE 2
                  END AS off_order
             FROM CASE_Y1 c,
                  CMEM_Y1 m
            WHERE @An_MemberMci_IDNO = m.MemberMci_IDNO
              AND m.CaseMemberStatus_CODE = 'A'
              AND m.CaseRelationship_CODE IN ('C', 'A', 'P')
              AND m.Case_IDNO = c.Case_IDNO
              AND c.StatusCase_CODE = 'O'
            ORDER BY off_order,
                     c.Opened_DATE DESC;
       SET @Ls_Sql_TEXT = 'OEPN @Case_CUR -2';

       OPEN @Case_CUR;

       SET @Ls_Sql_TEXT = 'FETCH @Case_CUR -3';

       FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT = 'WHILE -2';

       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         SELECT @Ln_OrderSeq_NUMB = s.OrderSeq_NUMB
           FROM SORD_Y1 s
          WHERE @Ln_CaseCur_Case_IDNO = s.Case_IDNO
            AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE -- Including Tribunal, Administrative, and Judicial Order Types for enforcement eligibility
            AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
            AND s.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ln_OrderSeq_NUMB = 0;
          END

         IF @Ln_OrderSeq_NUMB <> 0
          BEGIN
           -- Added parameters id_reference, cd_type_reference in sp_insert_elfc procedure
           -- and passed NCP id_member as reference to correct the process
           SET @Ls_Sql_TEXT = 'SELECT VCMEM3';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_NcpMci_IDNO = n.MemberMci_IDNO,
                  @Lc_TypeReference_CODE = n.CaseRelationship_CODE
             FROM CMEM_Y1 n
            WHERE n.Case_IDNO = @Ln_CaseCur_Case_IDNO
              AND n.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
              AND EXISTS (SELECT 1
                            FROM CMEM_Y1 m
                           WHERE m.Case_IDNO = n.Case_IDNO
                             AND m.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND m.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE);

           SET @Ln_RowCount_QNTY=@@ROWCOUNT;

           IF @Ln_RowCount_QNTY = 0
            BEGIN
             SET @Lc_TypeReference_CODE = @Lc_CaseRelationshipNcp_CODE;
             SET @Ln_NcpMci_IDNO = @An_MemberMci_IDNO;
            END
           ELSE
            BEGIN
             SET @Lc_TypeReference_CODE = @Lc_CaseRelationshipCp_CODE;
            END

           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NcpMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangeNs_CODE, '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPosCloseRemedy_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', Create_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Reference_ID = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

           EXECUTE BATCH_COMMON$SP_INSERT_ELFC
            @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
            @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
            @An_MemberMci_IDNO           = @Ln_NcpMci_IDNO,
            @An_OthpSource_IDNO          = @An_OthpPartyEmpl_IDNO,
            @Ac_TypeChange_CODE          = @Lc_TypeChangeNs_CODE,
            @Ac_NegPos_CODE              = @Lc_NegPosCloseRemedy_TEXT,
            @Ac_Process_ID               = @Ac_Process_ID,
            @Ad_Create_DATE              = @Ad_Run_DATE,
            @Ac_Reference_ID             = @An_MemberMci_IDNO,
            @Ac_TypeReference_CODE       = @Lc_TypeReference_CODE,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR (50001,16,1);
            END
          END

         SET @Ls_Sql_TEXT = 'FETCH @Case_CUR -4';

         FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE @Case_CUR;

       DEALLOCATE @Case_CUR;
      END
    END
   ELSE IF @An_TransactionEventSeq_NUMB = 0
    BEGIN
     -- The employer exists in EHIS_Y1 with valid status. The process will return duplicate code indicating already valid record exists
     IF EXISTS (SELECT 1
                  FROM EHIS_Y1 A
                 WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
                   AND A.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
                   AND @Ad_Run_DATE BETWEEN A.BeginEmployment_DATE AND A.EndEmployment_DATE
                   AND A.Status_CODE = @Lc_VerificationStatusGood_CODE)
      BEGIN
       --Changed as per the OTHP Change Request 
       --Setting up 'S' instead of E0145 Error Message;
       IF @Ac_SignedOnWorker_ID != @Lc_BatchRunUser_TEXT
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
        END
       ELSE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
        END

       SET @As_DescriptionError_TEXT = 'CONFIRMED GOOD RECORD EXISTS';

       RETURN;
      END
     -- Validation not be adding the same employer to EHIS if the employment record (Member ID + OTHP ID + OTHP Type) already exists on EHIS and is non end dated
     ELSE IF (SELECT COUNT(1)
           FROM EHIS_Y1 A
          WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
            AND A.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
            AND @Ad_Run_DATE BETWEEN A.BeginEmployment_DATE AND A.EndEmployment_DATE) = 1
      BEGIN
       --Changed as per the OTHP Change Request 
       --Setting up 'S' instead of E0640 Error Message;
       IF @Ac_SignedOnWorker_ID != @Lc_BatchRunUser_TEXT
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0640_CODE;
        END
       ELSE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
        END

       SET @As_DescriptionError_TEXT = 'VALID RECORD EXISTS';

       RETURN;
      END
     ELSE
      BEGIN
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT OLD EMPLOYMENT DATE';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '');

        SELECT TOP 1 @Ld_EndEmployment_DATE = e.EndEmployment_DATE,
                     @Lc_CurrentStatus_CODE = e.Status_CODE,
                     @Ld_BeginEmployment_DATE = e.BeginEmployment_DATE
          FROM EHIS_Y1 e
         WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
           AND e.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
           AND e.EndEmployment_DATE = (SELECT MAX(h.EndEmployment_DATE)
                                         FROM EHIS_Y1 h
                                        WHERE h.MemberMci_IDNO = @An_MemberMci_IDNO
                                          AND h.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO);

        -- The employer exists in EHIS_Y1 this process will check if the record as exceeded the time limit
        -- The process will return code 'E' if it is valid record
        SET @Ln_RowCount_QNTY=@@ROWCOUNT;

        IF @Ln_RowCount_QNTY = 0
         BEGIN
          SET @Lb_HehisExist_BIT = 0;
         END
        ELSE
         BEGIN
          SET @Lb_HehisExist_BIT = 1;
         END
       END
      END

     IF @Lb_HehisExist_BIT = 1
        AND @Ld_EndEmployment_DATE > @Ad_Run_DATE
        AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0640_CODE;
       SET @As_DescriptionError_TEXT = 'VALID RECORD EXISTS';

       RETURN;
      END

     SET @Ls_Sql_TEXT = 'VERIFY SOURCE LOCATIONS';

     -- The verified sources
     IF @Ac_SourceLoc_CODE IN (@Lc_SourceFedcaseregistr_CODE, @Lc_SourceFedParentLoc_CODE, @Lc_SourceLocNdh_CODE, @Lc_SourceLocOsa_CODE,
                               @Lc_SourceLocSnh_CODE, @Lc_SourceLocDol_CODE, @Lc_SourceLocDoc_CODE, @Lc_SourceLocDia_CODE,
                               @Lc_SourceLocDjs_CODE, @Lc_SourceLocPud_CODE, @Lc_SourceLocEmp_CODE, @Lc_SourceLocDs_CODE,
                               @Lc_SourceLocUib_CODE, @Lc_FunctionCsp_CODE)
      BEGIN
       IF @Ac_SourceLoc_CODE IN (@Lc_SourceFedcaseregistr_CODE, @Lc_SourceFedParentLoc_CODE, @Lc_SourceLocNdh_CODE)
        BEGIN
         -- For above sources status code will be Pending
         SET @Lc_Status_CODE = @Lc_VerStatusPending_CODE;
        END
       --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -START-
	   ELSE IF @Ac_SourceLoc_CODE IN (@Lc_SourceLocOsa_CODE, @Lc_SourceLocDol_CODE)
        BEGIN
         -- For OSA what ever the status come as input
         SET @Lc_Status_CODE = @Ac_Status_CODE;
        END
       ELSE IF @Ac_SourceLoc_CODE IN (@Lc_SourceLocSnh_CODE, @Lc_SourceLocDoc_CODE, @Lc_SourceLocDia_CODE,
                                      @Lc_SourceLocDjs_CODE, @Lc_SourceLocPud_CODE, @Lc_SourceLocEmp_CODE, 
									  @Lc_SourceLocDs_CODE, @Lc_SourceLocUib_CODE, @Lc_FunctionCsp_CODE)
        BEGIN
         -- For above sources status code will be Confirmed good
         SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
         SET @Lb_NoticeGen_BIT = 0;
        END
		--13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -END-
       IF @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
        BEGIN
         SET @Lc_Status_CODE = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_Status_CODE), @Lc_VerificationStatusGood_CODE);
        END

       IF @Lc_Status_CODE = @Lc_VerStatusPending_CODE
        BEGIN
         SET @Lb_NoticeGen_BIT = 1;
        END

       -- Checks if the record has exceeded the time limit
       IF DATEDIFF(DAY, @Ad_Run_DATE, @Ld_EndEmployment_DATE) > 30
        BEGIN
         SET @Lb_DateOld_BIT = 1;
        END
       ELSE
        BEGIN
         SET @Lb_DateOld_BIT = 0;
        END

       IF @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
          AND @Ac_TypeIncome_CODE = @Lc_TypeIncomeEmployer_CODE
          AND @Ac_SourceLoc_CODE = @Lc_SourceLocDol_CODE
        BEGIN
         IF DATEADD(m, -6, @Ad_Run_DATE) > @Ld_EndEmployment_DATE
          BEGIN
           SET @Lb_DateOld_BIT = 1;
          END
         ELSE
          BEGIN
           SET @Lb_DateOld_BIT = 0;
          END
        END

       --If the employment locate source is ‘FCR’ or ‘NDNH’ and the employer has existed for the member and was end-dated six months or more prior to the batch date, 
       --then the system should load the new employer to EHIS_Y1 with the Status of ‘Verification Pending’
       --If the employment locate source is other than ‘FCR’ or ‘NDNH’  and employer has existed for the member and was end-dated six months or more prior to the batch date, 
       --then the system should load the new employer to EHIS_Y1 with the Status of ‘Confirmed Good’.
       IF @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
          AND @Ac_SourceLoc_CODE IN (@Lc_SourceLocNdh_CODE, @Lc_SourceFedcaseregistr_CODE)
        BEGIN
         IF DATEADD(m, -6, @Ad_Run_DATE) > @Ld_EndEmployment_DATE
          BEGIN
           SET @Lb_DateOld_BIT = 1;
          END
         ELSE
          BEGIN
           SET @Lb_DateOld_BIT = 0;
          END
        END
      END
     ELSE
      BEGIN
       -- The unverified sources which require further check
       -- For this employers the process will generate notice for employer verification process
       SET @Lc_Status_CODE = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_Status_CODE), @Lc_VerStatusPending_CODE);
       SET @Lb_NoticeGen_BIT = 1;

       IF @Lc_Status_CODE != @Lc_VerStatusPending_CODE
        BEGIN
         SET @Lb_NoticeGen_BIT = 0;
        END

       IF DATEADD(m, -6, @Ad_Run_DATE) > @Ld_EndEmployment_DATE
        BEGIN
         SET @Lb_DateOld_BIT = 1;
        END
       ELSE
        BEGIN
         SET @Lb_DateOld_BIT = 0;
        END
      END

     -- This will not allow to update recently end dated EHIS_Y1 record
     IF @Lb_HehisExist_BIT = 1
        AND @Lb_DateOld_BIT = 0
        AND @Lc_CurrentStatus_CODE = @Lc_VerificationStatusBad_ADDR
        AND @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE1094_CODE;
       SET @As_DescriptionError_TEXT = 'RECORD CONFIRMED BAD';

       RETURN;
      END

     IF @Lb_HehisExist_BIT = 1
        AND @Lc_CurrentStatus_CODE = @Lc_VerificationStatusBad_ADDR
        AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT
        AND @Ld_EndEmployment_DATE > @Ad_Run_DATE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE1094_CODE;
       SET @As_DescriptionError_TEXT = 'RECORD CONFIRMED BAD';

       RETURN;
      END

     IF @Lb_HehisExist_BIT = 1
        AND @Lc_CurrentStatus_CODE = @Lc_VerStatusPending_CODE
        AND @Lc_Status_CODE NOT IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusBad_ADDR)
        AND ((@Lb_DateOld_BIT = 0)
              OR (@Ld_EndEmployment_DATE > @Ad_Run_DATE))
      BEGIN
       IF @Ac_SignedOnWorker_ID != @Lc_BatchRunUser_TEXT
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
        END
       ELSE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
        END

       SET @As_DescriptionError_TEXT = 'PENDING RECORD EXISTS';

       RETURN;
      END

     IF @Lb_HehisExist_BIT = 1
        AND @Ld_EndEmployment_DATE > DATEADD(m, -6, @Ad_Run_DATE)
        AND @Lc_CurrentStatus_CODE <> @Lc_VerificationStatusBad_ADDR
        AND @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
      BEGIN
       IF @Ac_SignedOnWorker_ID != @Lc_BatchRunUser_TEXT
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0640_CODE;
        END
       ELSE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
        END

       SET @As_DescriptionError_TEXT = 'RECORD END DATED LESS THAN 6 MONTHS';

       RETURN;
      END

     -- Employer has existed for the member and was end-dated six months or more prior to the batch date
     IF @Lb_HehisExist_BIT = 1
        AND @Lb_DateOld_BIT = 1
        AND @Lc_CurrentStatus_CODE <> @Lc_VerificationStatusBad_ADDR
        AND @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT
      BEGIN
       /*
       If the employment locate source is ‘FCR’ or ‘NDNH’ and the employer has existed for the member and was end-dated six months 
       or more prior to the batch date, then the system should load the new employer to EHIS_Y1 with the Status of 'Verification Pending'
       If the employment locate source is other than 'FCR' or 'NDNH'  and employer has existed for the member and was end-dated six months 
       or more prior to the batch date, then the system should load the new employer to EHIS_Y1 with the Status of 'Confirmed Good'.
       */
       IF @Ac_SourceLoc_CODE IN (@Lc_SourceLocNdh_CODE, @Lc_SourceFedcaseregistr_CODE)
        BEGIN
         SET @Lc_Status_CODE = @Lc_VerStatusPending_CODE;
        END
       --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -START-
	   ELSE IF @Ac_SourceLoc_CODE NOT IN (@Lc_SourceLocDol_CODE)
        BEGIN
         SET @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE;
        END
       --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -END-
	  END

     IF (@Lb_HehisExist_BIT = 0)
         OR (@Lb_HehisExist_BIT = 1
             AND @Lb_DateOld_BIT = 1)
         OR (@Lb_HehisExist_BIT = 1
             AND @Lb_DateOld_BIT = 0)
         OR (@Lb_HehisExist_BIT = 1
             AND @Lb_DateOld_BIT = 0
             AND @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
             AND @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT)
         OR (@Lb_HehisExist_BIT = 1
             AND @Ld_EndEmployment_DATE <= @Ad_Run_DATE
             AND @Ac_SignedOnWorker_ID <> @Lc_BatchRunUser_TEXT)
      BEGIN
       IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
          AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) > @Ad_Run_DATE
        BEGIN
         SET @Ln_EventFunctionalSeq_NUMB = @Li_AddVerifiedAGoodEmployer5330_NUMB;
        END
       ELSE
        BEGIN
         IF ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
          BEGIN
           SET @Ln_EventFunctionalSeq_NUMB = @Li_InvalidateMemberEmployer5340_NUMB;
          END
         ELSE
          BEGIN
           SET @Ln_EventFunctionalSeq_NUMB = @Li_AddANewEmployer5310_NUMB;
          END
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT-3';
       SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @Ac_Worker_ID                = @Ac_SignedOnWorker_ID,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'LOCATION CONFIRMATION SOURCE';

       IF @Lc_Status_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusBad_ADDR)
        BEGIN
         SET @Lc_SourceLocConf_CODE = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_SourceLocConf_CODE), ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT));
        END
       ELSE
        BEGIN
         SET @Lc_SourceLocConf_CODE = @Lc_Space_TEXT;
        END

       IF ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_EmployerPrime_INDC), @Lc_Yes_INDC) <> @Lc_No_INDC
        BEGIN
         SET @Ls_Sql_TEXT = 'PRIMARY EMPLOYER CHECK';

         IF NOT EXISTS (SELECT 1
                          FROM EHIS_Y1 e
                         WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND e.OthpPartyEmpl_IDNO <> @An_OthpPartyEmpl_IDNO
                           AND e.EndEmployment_DATE = @Ld_High_DATE
                           AND e.EmployerPrime_INDC = @Lc_Yes_INDC)
            AND @Ac_TypeIncome_CODE IN (@Lc_TypeIncomeEmployer_CODE, @Lc_TypeIncomeSelfemployed_CODE, @Lc_TypeIncomeMilitary_CODE)
          BEGIN
           SET @Lc_EmployerPrime_INDC = @Lc_Yes_INDC;
          END
         ELSE
          BEGIN
           SET @Lc_EmployerPrime_INDC = @Lc_No_INDC;
          END
        END
       ELSE
        BEGIN
         SET @Lc_EmployerPrime_INDC = @Lc_No_INDC;
        END

       IF (@Lb_HehisExist_BIT = 1
           AND @Lb_DateOld_BIT = 0
           AND (@Ld_BeginEmployment_DATE = @Ad_BeginEmployment_DATE
                 OR @Ld_EndEmployment_DATE >= @Ad_Run_DATE)
           AND @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
           AND @Ac_SignedOnWorker_ID = @Lc_BatchRunUser_TEXT)
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE EHIS_Y1 - 3 ';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_BeginEmployment_DATE AS VARCHAR), '');

         UPDATE EHIS_Y1
            SET EndEmployment_DATE = ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE),
                BeginEmployment_DATE = ISNULL(@Ad_BeginEmployment_DATE, @Ld_BeginEmployment_DATE),
                Status_CODE = @Lc_VerificationStatusGood_CODE,
                IncomeGross_AMNT = ISNULL(@An_IncomeGross_AMNT, 0),
                IncomeNet_AMNT = ISNULL(@An_IncomeNet_AMNT, 0),
                DescriptionOccupation_TEXT = ISNULL(@Ac_DescriptionOccupation_TEXT, @Lc_Space_TEXT),
                WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
                SourceReceived_DATE = ISNULL(@Ad_SourceReceived_DATE, @Ad_Run_DATE),
                FreqPay_CODE = ISNULL(@Ac_FreqPay_CODE, @Lc_Space_TEXT),
                SourceLoc_CODE = ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),
                SourceLocConf_CODE = @Lc_SourceLocConf_CODE,
                EligCoverage_DATE = ISNULL(@Ad_EligCoverage_DATE, @Ld_Low_DATE),
                DpCovered_INDC = ISNULL(@Ac_DpCovered_INDC, @Lc_No_INDC),
                CostInsurance_AMNT = ISNULL(@An_CostInsurance_AMNT, 0),
                FreqInsurance_CODE = ISNULL(@Ac_FreqInsurance_CODE, @Lc_Space_TEXT),
                Status_DATE = ISNULL(@Ad_Status_DATE, @Ad_Run_DATE),
                FreqIncome_CODE = ISNULL(@Ac_FreqIncome_CODE, @Lc_Space_TEXT),
                InsProvider_INDC = ISNULL(@Ac_InsProvider_INDC, @Lc_Yes_INDC),
                DpCoverageAvlb_INDC = ISNULL(@Ac_DpCoverageAvlb_INDC, @Lc_Yes_INDC),
                EmployerPrime_INDC = ISNULL(@Lc_EmployerPrime_INDC, @Ac_EmployerPrime_INDC),
                InsReasonable_INDC = ISNULL(@Ac_InsReasonable_INDC, @Lc_Yes_INDC),
                LimitCcpa_INDC = ISNULL(@Ac_LimitCcpa_INDC, @Lc_No_INDC),
                PlsLastSearch_DATE = ISNULL(@Ad_PlsLastSearch_DATE, @Ld_Low_DATE),
                BeginValidity_DATE = @Ad_Run_DATE,
                TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
         OUTPUT deleted.MemberMci_IDNO,
                deleted.OthpPartyEmpl_IDNO,
                deleted.BeginEmployment_DATE,
                deleted.EndEmployment_DATE,
                deleted.TypeIncome_CODE,
                deleted.DescriptionOccupation_TEXT,
                deleted.IncomeNet_AMNT,
                deleted.IncomeGross_AMNT,
                deleted.FreqIncome_CODE,
                deleted.FreqPay_CODE,
                deleted.SourceLoc_CODE,
                deleted.SourceReceived_DATE,
                deleted.Status_CODE,
                deleted.Status_DATE,
                deleted.SourceLocConf_CODE,
                deleted.InsProvider_INDC,
                deleted.CostInsurance_AMNT,
                deleted.FreqInsurance_CODE,
                deleted.DpCoverageAvlb_INDC,
                deleted.EmployerPrime_INDC,
                deleted.DpCovered_INDC,
                deleted.EligCoverage_DATE,
                deleted.InsReasonable_INDC,
                deleted.LimitCcpa_INDC,
                deleted.PlsLastSearch_DATE,
                deleted.BeginValidity_DATE,
                @Ad_Run_DATE AS EndValidity_DATE,
                deleted.WorkerUpdate_ID,
                deleted.Update_DTTM AS Update_DTTM,
                deleted.TransactionEventSeq_NUMB
         INTO HEHIS_Y1
          WHERE EHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
            AND EHIS_Y1.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
            AND EHIS_Y1.BeginEmployment_DATE = @Ld_BeginEmployment_DATE;

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
           SET @As_DescriptionError_TEXT = 'EHIS_Y1 UPDATE FAILED';

           RAISERROR (50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1 TABLE-3';

         IF EXISTS (SELECT 1
                      FROM EHIS_Y1 e
                     WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                       AND e.OthpPartyEmpl_IDNO = @An_OthpPartyEmpl_IDNO
                       AND e.BeginEmployment_DATE = ISNULL(@Ad_BeginEmployment_DATE, @Ad_Run_DATE))
          BEGIN
           IF @Ac_SignedOnWorker_ID != @Lc_BatchRunUser_TEXT
            BEGIN
             SET @Ac_Msg_CODE = @Lc_ErrorE0640_CODE;
            END
           ELSE
            BEGIN
             SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
            END

           SET @As_DescriptionError_TEXT = 'VALID RECORD EXISTS FOR THE DATE';

           RETURN;
          END

         SET @Ls_Sql_TEXT = 'INSERT INTO EHIS_Y1 TABLE';

         INSERT EHIS_Y1
                (MemberMci_IDNO,
                 OthpPartyEmpl_IDNO,
                 BeginEmployment_DATE,
                 EndEmployment_DATE,
                 TypeIncome_CODE,
                 DescriptionOccupation_TEXT,
                 IncomeNet_AMNT,
                 IncomeGross_AMNT,
                 FreqIncome_CODE,
                 FreqPay_CODE,
                 SourceLoc_CODE,
                 SourceReceived_DATE,
                 Status_CODE,
                 Status_DATE,
                 SourceLocConf_CODE,
                 InsProvider_INDC,
                 CostInsurance_AMNT,
                 FreqInsurance_CODE,
                 DpCoverageAvlb_INDC,
                 EmployerPrime_INDC,
                 DpCovered_INDC,
                 EligCoverage_DATE,
                 InsReasonable_INDC,
                 LimitCcpa_INDC,
                 PlsLastSearch_DATE,
                 BeginValidity_DATE,
                 WorkerUpdate_ID,
                 Update_DTTM,
                 TransactionEventSeq_NUMB)
         VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
                  @An_OthpPartyEmpl_IDNO,--OthpPartyEmpl_IDNO
                  ISNULL(@Ad_BeginEmployment_DATE, @Ad_Run_DATE),--BeginEmployment_DATE
                  ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE),--EndEmployment_DATE
                  ISNULL(@Ac_TypeIncome_CODE, @Lc_Space_TEXT),--TypeIncome_CODE
                  ISNULL(@Ac_DescriptionOccupation_TEXT, @Lc_Space_TEXT),--DescriptionOccupation_TEXT
                  ISNULL(@An_IncomeNet_AMNT, @Ln_Zero_NUMB),--IncomeNet_AMNT
                  ISNULL(@An_IncomeGross_AMNT, @Ln_Zero_NUMB),--IncomeGross_AMNT
                  ISNULL(@Ac_FreqIncome_CODE, @Lc_Space_TEXT),--FreqIncome_CODE
                  ISNULL(@Ac_FreqPay_CODE, @Lc_Space_TEXT),--FreqPay_CODE
                  ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                  ISNULL(@Ad_SourceReceived_DATE, @Ad_Run_DATE),--SourceReceived_DATE
                  ISNULL(@Lc_Status_CODE, @Lc_Space_TEXT),--Status_CODE
                  ISNULL(@Ad_Status_DATE, @Ad_Run_DATE),--Status_DATE
                  @Lc_SourceLocConf_CODE,--SourceLocConf_CODE
                  ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsProvider_INDC), @Lc_Yes_INDC),--InsProvider_INDC
                  ISNULL(@An_CostInsurance_AMNT, @Ln_Zero_NUMB),--CostInsurance_AMNT
                  ISNULL(@Ac_FreqInsurance_CODE, @Lc_Space_TEXT),--FreqInsurance_CODE
                  ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_DpCoverageAvlb_INDC), @Lc_Yes_INDC),--DpCoverageAvlb_INDC
                  ISNULL(@Lc_EmployerPrime_INDC, @Ac_EmployerPrime_INDC),--EmployerPrime_INDC
                  ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_DpCovered_INDC), @Lc_No_INDC),--DpCovered_INDC
                  ISNULL(@Ad_EligCoverage_DATE, @Ld_Low_DATE),--EligCoverage_DATE
                  ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_InsReasonable_INDC), @Lc_Yes_INDC),--InsReasonable_INDC
                  ISNULL(dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_LimitCcpa_INDC), @Lc_No_INDC),--LimitCcpa_INDC
                  ISNULL(@Ad_PlsLastSearch_DATE, @Ld_Low_DATE),--PlsLastSearch_DATE
                  @Ad_Run_DATE,--BeginValidity_DATE
                  @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ln_TransactionEventSeq_NUMB); --TransactionEventSeq_NUMB

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
           SET @As_DescriptionError_TEXT = 'EHIS_Y1 INSERT FAILED';

           RAISERROR (50001,16,1);
          END
        END

       SET @Lb_UpdateFlag_BIT = 1;
      END
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = 'INVALID TransactionEventSeq_NUMB';

     RETURN;
    END

   --Fix for TC_UC-INI-MEM-100 Missing alert generated after LOC-02 generation
   IF EXISTS (SELECT 1
                FROM DMNR_Y1 d,
                     FORM_Y1 f
               WHERE d.ActivityMinor_CODE = @Lc_ActivityMinorGeisv_CODE
                 AND d.AlertPrior_DATE >= @Ad_Run_DATE
                 AND d.AlertPrior_DATE != @Ld_High_DATE
                 AND d.Topic_IDNO = f.Topic_IDNO
                 AND d.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND EXISTS (SELECT 1
                               FROM NRRQ_Y1 r
                              WHERE r.Notice_ID = @Lc_NoticeLoc02_ID
                                AND r.Barcode_NUMB = f.Barcode_NUMB
                                AND CAST(r.Recipient_ID AS NUMERIC) = @An_OthpPartyEmpl_IDNO
                             UNION
                             SELECT 1
                               FROM NMRQ_Y1 r
                              WHERE r.Notice_ID = @Lc_NoticeLoc02_ID
                                AND r.Barcode_NUMB = f.Barcode_NUMB
                                AND CAST(r.Recipient_ID AS NUMERIC) = @An_OthpPartyEmpl_IDNO))
      AND (@Lc_Status_CODE NOT IN (@Lc_No_INDC, @Lc_VerStatusPending_CODE)
            OR (ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE))
    BEGIN
     UPDATE d
        SET AlertPrior_DATE = @Ld_High_DATE,
            WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
            BeginValidity_DATE = @Ad_Run_DATE,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     OUTPUT deleted.Case_IDNO,
            deleted.OrderSeq_NUMB,
            deleted.MajorIntSeq_NUMB,
            deleted.MinorIntSeq_NUMB,
            deleted.MemberMci_IDNO,
            deleted.ActivityMinor_CODE,
            deleted.ActivityMinorNext_CODE,
            deleted.Entered_DATE,
            deleted.Due_DATE,
            deleted.Status_DATE,
            deleted.Status_CODE,
            deleted.ReasonStatus_CODE,
            deleted.Schedule_NUMB,
            deleted.Forum_IDNO,
            deleted.Topic_IDNO,
            deleted.TotalReplies_QNTY,
            deleted.TotalViews_QNTY,
            deleted.PostLastPoster_IDNO,
            deleted.UserLastPoster_ID,
            deleted.LastPost_DTTM,
            deleted.AlertPrior_DATE,
            deleted.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            deleted.WorkerUpdate_ID,
            deleted.Update_DTTM,
            deleted.TransactionEventSeq_NUMB,
            deleted.WorkerDelegate_ID,
            deleted.ActivityMajor_CODE,
            deleted.Subsystem_CODE
     INTO HDMNR_Y1
       FROM DMNR_Y1 d,
            FORM_Y1 f
      WHERE d.ActivityMinor_CODE = @Lc_ActivityMinorGeisv_CODE
        AND d.AlertPrior_DATE >= @Ad_Run_DATE
        AND d.AlertPrior_DATE != @Ld_High_DATE
        AND d.Topic_IDNO = f.Topic_IDNO
        AND d.MemberMci_IDNO = @An_MemberMci_IDNO
        AND EXISTS (SELECT 1
                      FROM NRRQ_Y1 r
                     WHERE r.Notice_ID = @Lc_NoticeLoc02_ID
                       AND r.Barcode_NUMB = f.Barcode_NUMB
                       AND CAST(r.Recipient_ID AS NUMERIC) = @An_OthpPartyEmpl_IDNO
                    UNION
                    SELECT 1
                      FROM NMRQ_Y1 r
                     WHERE r.Notice_ID = @Lc_NoticeLoc02_ID
                       AND r.Barcode_NUMB = f.Barcode_NUMB
                       AND CAST(r.Recipient_ID AS NUMERIC) = @An_OthpPartyEmpl_IDNO);

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'UPDATE DMNR_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END

   IF ISNULL(@Ac_TypeIncome_CODE, @Lc_Space_TEXT) NOT IN (@Lc_TypeIncomeUnemployment_CODE, @Lc_TypeIncomeDisability_CODE, @Lc_TypeIncomeUnion_CODE)
    BEGIN
     IF @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
        AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) > @Ad_Run_DATE
      BEGIN
       IF EXISTS(SELECT 1
                   FROM LSTT_Y1 l
                  WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
                    AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
                    AND l.EndValidity_DATE = @Ld_High_DATE)
        BEGIN
         SET @Lb_InitiateRemedy_BIT = 1;
         SET @Lc_ActivityMinor_CODE = 'LOCAB';
         SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = ' + ISNULL(@Lc_StatusLocateN_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqLstt_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE LSTT_Y1
            SET StatusLocate_CODE = @Lc_StatusLocateL_CODE,
                Employer_INDC = @Lc_Yes_INDC,
                StatusLocate_DATE = @Ad_Run_DATE,
                SourceLoc_CODE = ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),
                BeginLocEmpr_DATE = @Ad_Run_DATE,
                WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
                Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
                BeginValidity_DATE = @Ad_Run_DATE,
                EndValidity_DATE = @Ld_High_DATE,
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
          WHERE MemberMci_IDNO = @An_MemberMci_IDNO
            AND StatusLocate_CODE = @Lc_StatusLocateN_CODE
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
           SET @As_DescriptionError_TEXT = 'UPDATE LSTT_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END
       ELSE
        BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM LSTT_Y1 l
                         WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
                           AND l.EndValidity_DATE = @Ld_High_DATE)
          BEGIN
           SET @Lb_InitiateRemedy_BIT = 1;
           SET @Lc_ActivityMinor_CODE = 'LOCAB';
           SET @Ls_Sql_TEXT = 'INSERT LSTT_Y1 - 1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = ' + ISNULL(@Lc_StatusLocateL_CODE, '') + ', BeginLocate_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Address_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Employer_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Ssn_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', License_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusLocate_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Asset_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginLocAddr_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', BeginLocEmpr_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginLocSsn_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginLocDateOfBirth_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReferLocate_INDC = ' + ISNULL(@Lc_No_INDC, '');

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
                    @Lc_Yes_INDC,--Employer_INDC
                    @Lc_No_INDC,--Ssn_INDC
                    @Lc_Space_TEXT,--License_INDC
                    @Ad_Run_DATE,--StatusLocate_DATE
                    @Lc_Space_TEXT,--Asset_INDC
                    ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                    @Ld_Low_DATE,--BeginLocAddr_DATE
                    @Ad_Run_DATE,--BeginLocEmpr_DATE
                    @Ld_Low_DATE,--BeginLocSsn_DATE
                    @Ld_Low_DATE,--BeginLocDateOfBirth_DATE
                    @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
                    dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                    @Ad_Run_DATE,--BeginValidity_DATE
                    @Ld_High_DATE,--EndValidity_DATE
                    @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                    @Lc_No_INDC); --ReferLocate_INDC

           SET @Ln_RowCount_QNTY=@@ROWCOUNT;

           IF @Ln_RowCount_QNTY = 0
            BEGIN
             SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
             SET @As_DescriptionError_TEXT = 'INSERT LSTT_Y1 - 1 FAILED';

             RAISERROR (50001,16,1);
            END
          END
        END
      END
     ELSE IF (@Lb_VerStatusGood_BIT = 1
         AND @Lc_Status_CODE <> @Lc_VerificationStatusGood_CODE)
         OR (@Lc_Status_CODE = @Lc_VerificationStatusGood_CODE
             AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE)
      BEGIN
       IF NOT EXISTS (SELECT 1
                        FROM EHIS_Y1 e
                       WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                         AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
                         AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                         AND e.TypeIncome_CODE NOT IN (@Lc_TypeIncomeUnemployment_CODE, @Lc_TypeIncomeDisability_CODE, @Lc_TypeIncomeUnion_CODE)
                         AND e.EndEmployment_DATE = @Ld_High_DATE)
          AND NOT EXISTS (SELECT 1
                            FROM AHIS_Y1 a
                           WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
                             AND a.TypeAddress_CODE <> @Lc_TypeAddressCourtC_CODE
                             AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                             AND a.End_DATE = @Ld_High_DATE)
          AND EXISTS (SELECT 1
                        FROM LSTT_Y1 l
                       WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
                         AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
                         AND l.EndValidity_DATE = @Ld_High_DATE)
        BEGIN
         SET @Lc_ActivityMinor_CODE = 'LOCAA';
         SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1 1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = ' + ISNULL(@Lc_StatusLocateL_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeqLstt_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE LSTT_Y1
            SET StatusLocate_CODE = @Lc_StatusLocateN_CODE,
                Employer_INDC = @Lc_No_INDC,
                BeginLocate_DATE = @Ad_Run_DATE,
                StatusLocate_DATE = @Ad_Run_DATE,
                SourceLoc_CODE = ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),
                BeginLocEmpr_DATE = @Ad_Run_DATE,
                WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
                Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
                BeginValidity_DATE = @Ad_Run_DATE,
                EndValidity_DATE = @Ld_High_DATE,
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
          WHERE MemberMci_IDNO = @An_MemberMci_IDNO
            AND StatusLocate_CODE = @Lc_StatusLocateL_CODE
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
           SET @As_DescriptionError_TEXT = 'UPDATE LSTT_Y1 FAILED';

           RAISERROR (50001,16,1);
          END
        END
      END
     ELSE
      BEGIN
       /* Identify NCP-CP's in Un-Located Status System will identify CP's that do not have a verified
          address on decss, or NCP's who do not possess either a verified address or employer on DECSS */
       IF NOT EXISTS (SELECT 1
                        FROM LSTT_Y1 l
                       WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
                         AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
                         AND l.EndValidity_DATE = @Ld_High_DATE
                         AND ((EXISTS (SELECT 1
                                         FROM CMEM_Y1 c
                                        WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
                                          AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                                          AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
                               AND EXISTS (SELECT 1
                                             FROM AHIS_Y1 a
                                            WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                                              AND a.Status_CODE <> @Lc_VerificationStatusGood_CODE
                                              AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE))
                               OR (EXISTS (SELECT 1
                                             FROM CMEM_Y1 cm
                                            WHERE cm.MemberMci_IDNO = @An_MemberMci_IDNO
                                              AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
                                              AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
                                   AND (EXISTS (SELECT 1
                                                  FROM AHIS_Y1 ah
                                                 WHERE ah.MemberMci_IDNO = @An_MemberMci_IDNO
                                                   AND ah.Status_CODE <> @Lc_VerificationStatusGood_CODE
                                                   AND @Ad_Run_DATE BETWEEN ah.Begin_DATE AND ah.End_DATE)
                                         OR (EXISTS (SELECT 1
                                                       FROM EHIS_Y1 e
                                                      WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                                                        AND e.Status_CODE <> @Lc_VerificationStatusGood_CODE
                                                        AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE))))))
          AND NOT EXISTS (SELECT 1
                            FROM LSTT_Y1 l
                           WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND l.StatusLocate_CODE IN (@Lc_StatusLocateL_CODE, @Lc_StatusLocateN_CODE)
                             AND l.EndValidity_DATE = @Ld_High_DATE)
        BEGIN
         SET @Lc_ActivityMinor_CODE = 'LOCAA';
         SET @Ls_Sql_TEXT = 'INSERT LSTT_Y1 - 2';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', StatusLocate_CODE = ' + ISNULL(@Lc_StatusLocateN_CODE, '') + ', BeginLocate_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Address_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Employer_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Ssn_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', License_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusLocate_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Asset_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginLocAddr_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', BeginLocEmpr_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginLocSsn_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginLocDateOfBirth_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReferLocate_INDC = ' + ISNULL(@Lc_No_INDC, '');

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
                  @Lc_StatusLocateN_CODE,--StatusLocate_CODE
                  @Ad_Run_DATE,--BeginLocate_DATE
                  @Lc_No_INDC,--Address_INDC
                  @Lc_No_INDC,--Employer_INDC
                  @Lc_No_INDC,--Ssn_INDC
                  @Lc_Space_TEXT,--License_INDC
                  @Ad_Run_DATE,--StatusLocate_DATE
                  @Lc_Space_TEXT,--Asset_INDC
                  ISNULL(@Ac_SourceLoc_CODE, @Lc_Space_TEXT),--SourceLoc_CODE
                  @Ld_Low_DATE,--BeginLocAddr_DATE
                  @Ad_Run_DATE,--BeginLocEmpr_DATE
                  @Ld_Low_DATE,--BeginLocSsn_DATE
                  @Ld_Low_DATE,--BeginLocDateOfBirth_DATE
                  @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
                  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                  @Ad_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  @Lc_No_INDC); --ReferLocate_INDC

         SET @Ln_RowCount_QNTY=@@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
           SET @As_DescriptionError_TEXT = 'INSERT LSTT_Y1 - 2 FAILED';

           RAISERROR (50001,16,1);
          END
        END
      END
    END

   IF ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
      AND EXISTS (SELECT 1
                    FROM DINS_Y1 d
                   WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND d.End_DATE > @Ad_EndEmployment_DATE
                     AND d.EndValidity_DATE = @Ld_High_DATE
                     AND d.OthpInsurance_IDNO IN (SELECT OthpInsurance_IDNO
                                                    FROM MINS_Y1 m
                                                   WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
                                                     AND m.OthpEmployer_IDNO = @An_OthpPartyEmpl_IDNO
                                                     AND m.End_DATE > @Ad_EndEmployment_DATE
                                                     AND m.EndValidity_DATE = @Ld_High_DATE))
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE DINS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpEmployer_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     UPDATE d
        SET d.End_DATE = @Ad_EndEmployment_DATE,
            d.Status_DATE = @Ad_Run_DATE,
            d.BeginValidity_DATE = @Ad_Run_DATE,
            d.WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
            d.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            d.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
     OUTPUT deleted.MemberMci_IDNO,
            deleted.OthpInsurance_IDNO,
            deleted.InsuranceGroupNo_TEXT,
            deleted.PolicyInsNo_TEXT,
            deleted.ChildMCI_IDNO,
            deleted.Begin_DATE,
            deleted.End_DATE,
            deleted.Status_DATE,
            deleted.MedicalIns_INDC,
            deleted.DentalIns_INDC,
            deleted.VisionIns_INDC,
            deleted.PrescptIns_INDC,
            deleted.MentalIns_INDC,
            deleted.DescriptionOthers_TEXT,
            deleted.Status_CODE,
            deleted.NonQualified_CODE,
            deleted.InsSource_CODE,
            deleted.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            deleted.WorkerUpdate_ID,
            deleted.Update_DTTM,
            deleted.TransactionEventSeq_NUMB
     INTO DINS_Y1
       FROM DINS_Y1 d
      WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
        AND d.End_DATE > @Ad_EndEmployment_DATE
        AND d.EndValidity_DATE = @Ld_High_DATE
        AND d.OthpInsurance_IDNO IN (SELECT OthpInsurance_IDNO
                                       FROM MINS_Y1 m
                                      WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
                                        AND m.OthpEmployer_IDNO = @An_OthpPartyEmpl_IDNO
                                        AND m.End_DATE > @Ad_EndEmployment_DATE
                                        AND m.EndValidity_DATE = @Ld_High_DATE)

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'UPDATE DINS_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END

   IF ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) <= @Ad_Run_DATE
      AND EXISTS (SELECT 1
                    FROM MINS_Y1 m
                   WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND m.OthpEmployer_IDNO = @An_OthpPartyEmpl_IDNO
                     AND m.End_DATE > @Ad_EndEmployment_DATE
                     AND m.EndValidity_DATE = @Ld_High_DATE)
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE MINS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpEmployer_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     UPDATE m
        SET m.End_DATE = @Ad_EndEmployment_DATE,
            m.Status_DATE = @Ad_Run_DATE,
            m.BeginValidity_DATE = @Ad_Run_DATE,
            m.WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
            m.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            m.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
     OUTPUT deleted.MemberMci_IDNO,
            deleted.OthpInsurance_IDNO,
            deleted.InsuranceGroupNo_TEXT,
            deleted.PolicyInsNo_TEXT,
            deleted.Begin_DATE,
            deleted.End_DATE,
            deleted.InsSource_CODE,
            deleted.Status_CODE,
            deleted.Status_DATE,
            deleted.SourceVerified_CODE,
            deleted.PolicyHolderRelationship_CODE,
            deleted.TypePolicy_CODE,
            deleted.EmployerPaid_INDC,
            deleted.DescriptionCoverage_TEXT,
            deleted.MonthlyPremium_AMNT,
            deleted.Contact_NAME,
            deleted.SpecialNeeds_INDC,
            deleted.OtherIns_INDC,
            deleted.DescriptionOtherIns_TEXT,
            deleted.MedicalIns_INDC,
            deleted.CoPay_AMNT,
            deleted.DentalIns_INDC,
            deleted.VisionIns_INDC,
            deleted.PrescptIns_INDC,
            deleted.MentalIns_INDC,
            deleted.OthpEmployer_IDNO,
            deleted.NonQualified_CODE,
            deleted.PolicyHolder_NAME,
            deleted.PolicyHolderSsn_NUMB,
            deleted.BirthPolicyHolder_DATE,
            deleted.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            deleted.WorkerUpdate_ID,
            deleted.Update_DTTM,
            deleted.TransactionEventSeq_NUMB,
            deleted.PolicyAnnivMonth_CODE
     INTO MINS_Y1
       FROM MINS_Y1 m
      WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
        AND m.OthpEmployer_IDNO = @An_OthpPartyEmpl_IDNO
        AND m.End_DATE > @Ad_EndEmployment_DATE
        AND m.EndValidity_DATE = @Ld_High_DATE

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'UPDATE MINS_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END

   IF @Lb_UpdateFlag_BIT = 1
    BEGIN
     IF @Ac_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE
         OR @Lc_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE
      BEGIN
       SET @Lb_NoticeGen_BIT = 0;
      END

     IF ((@Ac_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE
           OR @Lc_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE)
         AND @Lc_Status_CODE = @Lc_VerificationStatusGood_CODE)
      BEGIN
       SET @Lb_NoticeGen_BIT = 1;
      END

     IF @Lb_NoticeGen_BIT = 1
        AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) > @Ad_Run_DATE
      BEGIN
       SET @Ln_TopicIn_IDNO = @Ln_Zero_NUMB;
       SET @Ln_Topic_NUMB = @Ln_Zero_NUMB;

       SELECT @Ln_Value_QNTY = COUNT(1)
         FROM OTHP_Y1 o
        WHERE o.OtherParty_IDNO = @An_OthpPartyEmpl_IDNO
          AND o.TypeOthp_CODE IN (@Lc_TypeOthpE_CODE, @Lc_TypeOthpM_CODE)
          AND o.EndValidity_DATE = @Ld_High_DATE;

       IF @Ln_Value_QNTY > 1
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @As_DescriptionError_TEXT = 'MULTIPLE OTHP RECORDS WITH SAME OtherParty_IDNO';

         RETURN;
        END
       ELSE
        BEGIN
         IF @Ln_Value_QNTY = 1
            AND ((@Ac_TypeIncome_CODE <> @Lc_TypeIncomeSelfemployed_CODE
                  AND @Ac_TypeIncome_CODE IS NOT NULL)
                  OR @Lc_TypeIncome_CODE IS NOT NULL)
          BEGIN
           SET @Case_CUR =CURSOR LOCAL FORWARD_ONLY
           FOR SELECT c.Case_IDNO,
                      m.CaseRelationship_CODE,
                      c.Application_IDNO,
                      c.RespondInit_CODE,
                      CASE
                       WHEN c.Office_IDNO = @An_OfficeSignedOn_IDNO
                        THEN 1
                       ELSE 2
                      END AS off_order
                 FROM CASE_Y1 c,
                      CMEM_Y1 m
                WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
                  AND m.CaseMemberStatus_CODE = 'A'
                  AND m.CaseRelationship_CODE IN ('A', 'P')
                  AND m.Case_IDNO = c.Case_IDNO
                  AND c.StatusCase_CODE = 'O'
                  AND ((@Ac_TypeIncome_CODE != @Lc_TypeIncomeMilitary_CODE
                        AND @Ac_TypeIncome_CODE IS NOT NULL
                        AND NOT EXISTS (SELECT 1
                                          FROM LSTT_Y1 l
                                         WHERE l.MemberMci_IDNO = m.MemberMci_IDNO
                                           AND l.EndValidity_DATE = @Ld_High_DATE
                                           AND l.StatusLocate_CODE = 'L')
                        AND NOT EXISTS (SELECT 1
                                          FROM SORD_Y1 s
                                         WHERE s.Case_IDNO = c.Case_IDNO))
                        OR ((@Ac_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE
                              OR @Lc_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE)
                            --Bug 13218 The form ENF-14 (CP Military Insurance) should generated manually. Start
                            AND c.TypeCase_CODE != 'H'
                            --Bug 13218 The form ENF-14 (CP Military Insurance) should generated manually. End
                            AND 1 = (SELECT COUNT(1)
                                       FROM SORD_Y1 s
                                      WHERE s.Case_IDNO = c.Case_IDNO
                                        AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                                        AND s.EndValidity_DATE = @Ld_High_DATE
                                        AND NOT EXISTS (SELECT 1
                                                          FROM NMRQ_Y1 n
                                                         WHERE n.Case_IDNO = c.Case_IDNO
                                                           AND n.Notice_ID = @Lc_NoticeEnf14_IDNO
                                                           AND n.Request_DTTM >= @Ad_BeginEmployment_DATE)
                                        AND NOT EXISTS (SELECT 1
                                                          FROM NRRQ_Y1 r
                                                         WHERE r.Case_IDNO = c.Case_IDNO
                                                           AND r.Notice_ID = @Lc_NoticeEnf14_IDNO
                                                           AND r.Request_DTTM >= @Ad_BeginEmployment_DATE)
                                        AND EXISTS (SELECT 1
                                                      FROM CMEM_Y1 c
                                                     WHERE c.Case_IDNO = c.Case_IDNO
                                                       AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                                                       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
                                        AND EXISTS (SELECT 1
                                                      FROM CMEM_Y1 d
                                                     WHERE d.Case_IDNO = c.Case_IDNO
                                                       AND d.MemberMci_IDNO <> @Lc_MemberDyfsCp_IDNO
                                                       AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                       AND d.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE))))
                ORDER BY off_order,
                         c.Opened_DATE DESC;
           SET @Ls_Sql_TEXT ='OPEN @Case_CUR -3';

           OPEN @Case_CUR;

           SET @Ls_Sql_TEXT ='FETCH @Case_CUR -3';

           FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

           SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
           SET @Ls_Sql_TEXT ='WHILE -3';

           WHILE @Ln_FetchStatus_QNTY = 0
            BEGIN
             IF @Ac_TypeIncome_CODE != @Lc_TypeIncomeMilitary_CODE
                AND @Ac_TypeIncome_CODE IS NOT NULL
              BEGIN
               SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorGeisv_CODE;
               SET @Lc_Subsystem_CODE = @Lc_SubsystemLoc_CODE;

               IF @Ln_TopicIn_IDNO = @Ln_Zero_NUMB
                BEGIN
                 SET @Lc_Notice_ID = @Lc_NoticeLoc02_ID;
                END
               ELSE
                BEGIN
                 SET @Lc_Notice_ID = @Lc_Space_TEXT;
                END
              END
             ELSE
              BEGIN
               IF @Ac_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE
                   OR @Lc_TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE
                BEGIN
                 SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorNopri_CODE;
                 SET @Lc_Subsystem_CODE = @Lc_SubsystemEnforcement_CODE;
                 SET @Lc_Notice_ID = @Lc_NoticeEnf14_IDNO;
                 SET @Ln_TopicIn_IDNO = 0;
                END
              END

             SET @Ls_XmlTextIn_TEXT = @Lc_Space_TEXT;
             SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 1';
             SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '');

             EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
              @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
              @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
              @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
              @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
              @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
              @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
              @Ad_Run_DATE                 = @Ad_Run_DATE,
              @Ac_Notice_ID                = @Lc_Notice_ID,
              @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
              @Ac_Job_ID                   = @Ac_Process_ID,
              @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
              @An_OthpSource_IDNO          = @An_OthpPartyEmpl_IDNO,
              @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

             IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
              BEGIN
               SET @Ac_Msg_CODE = @Lc_Msg_CODE;
               SET @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT;

               RETURN;
              END

             SET @Ln_TopicIn_IDNO = @Ln_Topic_NUMB;
             SET @Ls_Sql_TEXT ='FETCH @Case_CUR -3';

             FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

             SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
            END

           CLOSE @Case_CUR;

           DEALLOCATE @Case_CUR;
          END
        END
      END

     SET @Ln_TopicIn_IDNO = @Ln_Zero_NUMB;
     SET @Ln_Topic_NUMB = @Ln_Zero_NUMB;
    END

   --Cursor for Remedy, CSPR and Located,UN-Located CJNR  
   SET @Case_CUR = CURSOR LOCAL FORWARD_ONLY
   FOR SELECT c.Case_IDNO,
              m.CaseRelationship_CODE,
              c.Application_IDNO,
              c.RespondInit_CODE,
              CASE
               WHEN c.Office_IDNO = @An_OfficeSignedOn_IDNO
                THEN 1
               ELSE 2
              END AS off_order
         FROM CASE_Y1 c,
              CMEM_Y1 m
        WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
          AND m.CaseMemberStatus_CODE = 'A'
          AND m.CaseRelationship_CODE IN ('C', 'A', 'P')
          AND m.Case_IDNO = c.Case_IDNO
          AND c.StatusCase_CODE = 'O'
        ORDER BY off_order,
                 c.Opened_DATE DESC;
   SET @Ls_Sql_TEXT ='OPEN @Case_CUR -4';

   OPEN @Case_CUR;

   SET @Ls_Sql_TEXT ='FETCH @Case_CUR -7';

   FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT ='WHILE -4';

   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     IF @Lb_UpdateFlag_BIT = 1
        AND ISNULL(@Ad_EndEmployment_DATE, @Ld_High_DATE) > @Ad_Run_DATE
        AND @Lc_CaseCur_CaseRelationship_CODE IN ('A', 'P')
      BEGIN
       -- If the Verified By is OSA, it should not trigger a notice back to the same state.  
       IF @Lc_CaseCur_RespondInit_CODE IN (@Lc_RespondInitInitiate_TEXT, @Lc_RespondInitResponding_TEXT)
          AND @Ac_SourceLoc_CODE != @Lc_SourceLocOsa_CODE
          AND (dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_TypeIncome_CODE) = @Lc_TypeIncomeEmployer_CODE
                OR dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ac_TypeIncome_CODE) = @Lc_TypeIncomeMilitary_CODE)
        BEGIN
         SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Lc_FunctionMsc_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionP_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonLsemp_CODE, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Generated_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Form_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', FormWeb_URL = ' + ISNULL(@Lc_Space_TEXT, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', CaseFormer_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsCarrier_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsPolicyNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Hearing_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Dismissal_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', GeneticTest_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', PfNoShow_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Attachment_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', File_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearComputed_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', TotalArrearsOwed_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', TotalInterestOwed_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '');

         EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
          @An_Case_IDNO                    = @Ln_CaseCur_Case_IDNO,
          @An_RespondentMci_IDNO           = @Ln_Zero_NUMB,
          @Ac_Function_CODE                = @Lc_FunctionMsc_CODE,
          @Ac_Action_CODE                  = @Lc_ActionP_CODE,
          @Ac_Reason_CODE                  = @Lc_ReasonLsemp_CODE,
          @Ac_IVDOutOfStateFips_CODE       = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateCountyFips_CODE = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
          @Ac_IVDOutOfStateCase_ID         = @Lc_Space_TEXT,
          @Ad_Generated_DATE               = @Ad_Run_DATE,
          @Ac_Form_ID                      = @Lc_Space_TEXT,
          @As_FormWeb_URL                  = @Lc_Space_TEXT,
          @An_TransHeader_IDNO             = @Ln_Zero_NUMB,
          @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
          @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
          @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
          @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
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
          @Ac_SignedOnWorker_ID            = @Ac_SignedOnWorker_ID,
          @Ad_Update_DTTM                  = @Ld_Start_DATE,
          @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT        = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ac_Msg_CODE = @Lc_MsgW0156_CODE;
           SET @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT;

           RAISERROR (50001,16,1);
          END
         ELSE
          BEGIN
           IF @Lc_Msg_CODE = @Lc_ErrorW0156_CODE
            BEGIN
             SET @Lc_MsgW0156_CODE = @Lc_ErrorW0156_CODE;
            END
          END
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangeIW_CODE, '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPosStartRemedy_CODE, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', Create_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Reference_ID = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_CaseCur_CaseRelationship_CODE, '') + ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

       EXECUTE BATCH_COMMON$SP_INSERT_ELFC
        @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
        @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO          = @An_OthpPartyEmpl_IDNO,
        @Ac_TypeChange_CODE          = @Lc_TypeChangeIW_CODE,
        @Ac_NegPos_CODE              = @Lc_NegPosStartRemedy_CODE,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_Create_DATE              = @Ad_Run_DATE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_Reference_ID             = @An_MemberMci_IDNO,
        @Ac_TypeReference_CODE       = @Lc_CaseCur_CaseRelationship_CODE,
        @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     IF @Lb_InitiateRemedy_BIT = 1
        AND @Lc_CaseCur_CaseRelationship_CODE IN ('A', 'P')
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

       SET @Ln_OrderSeq_NUMB = ISNULL((SELECT TOP 1 s.OrderSeq_NUMB
                                         FROM SORD_Y1 s
                                        WHERE @Ln_CaseCur_Case_IDNO = s.Case_IDNO
                                          AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                                          AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
                                          AND s.EndValidity_DATE = @Ld_High_DATE), 0)
       SET @Ls_Sql_TEXT = 'BATCH_ENF_ELFC$SP_INITIATE_REMEDY';
       SET @Ls_Sqldata_TEXT = 'TypeChange_CODE = ' + ISNULL(@Lc_Null_TEXT, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeOthpSource_CODE = ' + ISNULL(@Lc_CaseCur_CaseRelationship_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEst_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reference_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '');

       EXECUTE BATCH_ENF_ELFC$SP_INITIATE_REMEDY
        @Ac_TypeChange_CODE          = @Lc_Null_TEXT,
        @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
        @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO          = @An_MemberMci_IDNO,
        @Ac_TypeOthpSource_CODE      = @Lc_CaseCur_CaseRelationship_CODE,
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

     IF @Lc_ActivityMinor_CODE IN ('LOCAA', 'LOCAB')
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY7 ';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', LN_SEQ_TXN_EVENT = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_Majoractivitycase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
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

     SET @Ls_Sql_TEXT ='FETCH @Case_CUR -8';

     FETCH NEXT FROM @Case_CUR INTO @Ln_CaseCur_Case_IDNO, @Lc_CaseCur_CaseRelationship_CODE, @Ln_CaseCur_Application_IDNO, @Lc_CaseCur_RespondInit_CODE, @Li_CaseCur_off_order;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE @Case_CUR;

   DEALLOCATE @Case_CUR;

   /* 	The system will update the solicited and unsolicited employment for NCP on cases that are closed with unable to locate reason codes. The system will  
   		generate the alert ‘employer received on a case closed for Unable to Locate’ */
   IF NOT EXISTS(SELECT 1
                   FROM CMEM_Y1 a,
                        CASE_Y1 b
                  WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                    AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                    AND a.Case_IDNO = b.Case_IDNO
                    AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE)
    BEGIN
     DECLARE CaseCloseCur INSENSITIVE CURSOR FOR
      SELECT b.Case_IDNO,
             b.Worker_ID
        FROM CMEM_Y1 a,
             CASE_Y1 b
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
         AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND a.CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
         AND a.Case_IDNO = b.Case_IDNO
         AND b.RsnStatusCase_CODE IN(@Lc_RsnStatusCaseUb_CODE, @Lc_RsnStatusCaseUC_CODE)
         AND b.StatusCase_CODE = @Lc_CaseStatusClose_CODE;

     SET @Ls_Sql_TEXT = 'OPEN CaseCloseCur';

     OPEN CaseCloseCur;

     SET @Ls_Sql_TEXT = 'FETCH CaseCloseCur - 1';

     FETCH NEXT FROM CaseCloseCur INTO @Ln_CaseCloseCur_Case_IDNO, @Lc_CaseCloseCur_Worker_ID;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 2';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorErccl_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemLoc_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_CaseCloseCur_Worker_ID, '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_CaseCloseCur_Case_IDNO,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorErccl_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
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

   SET @Ac_Msg_CODE = ISNULL(@Lc_MsgW0156_CODE, @Lc_StatusSuccess_CODE);
   SET @As_DescriptionError_TEXT = @Lc_Null_TEXT;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'CaseCloseCur') IN (0, 1)
    BEGIN
     CLOSE CaseCloseCur;

     DEALLOCATE CaseCloseCur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
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
