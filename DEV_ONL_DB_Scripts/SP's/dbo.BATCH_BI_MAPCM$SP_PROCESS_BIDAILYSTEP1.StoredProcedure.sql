/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP1
Programmer Name	:	IMP Team.
Description		:	This process loads current date information, county details, and case details into staging table.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP1]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_DaysInyear_NUMB        NUMERIC(6, 2) = 365.25,
          @Li_RowCount_QNTY          INT = 0,
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_No_TEXT                CHAR(1) = 'N',
          @Lc_CaseStatusOpen_CODE    CHAR(1) = 'O',
          @Lc_CaseStatusClosed_CODE  CHAR(1) = 'C',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_TypeEstablish_CODE     CHAR(1) = 'O',
          @Lc_StatusOrderActive_CODE CHAR(1) = 'A',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_DateFormatDd_TEXT      CHAR(2) = 'DD',
          @Lc_County000_TEXT         CHAR(3) = '000',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_JobStep1_IDNO          CHAR(7) = 'DEB0810',
          @Lc_Successful_TEXT        CHAR(10) = 'SUCCESSFUL',
          @Lc_Process_NAME           CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Step1Routine1_TEXT     VARCHAR(50) = 'BATCH_BI_MAPCM$SP_PROCESS_BIDATE',
          @Ls_Step1Routine2_TEXT     VARCHAR(50) = 'BATCH_BI_MAPCM$SP_PROCESS_BIDECOUNTIES',
          @Ls_Process_NAME           VARCHAR(50) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME         VARCHAR(50) = 'SP_PROCESS_BIDAILYSTEP1',
          @Ld_Lowdate_DATE           DATE = '01/01/0001',
          @Ld_Highdate_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_NextProcess_NUMB            NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_TotalRecordCount_NUMB		  NUMERIC(6) = 0,        
          @Ln_RecordCount_NUMB		      NUMERIC(6),     
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),          
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_RestartKey_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Begin_DATE                  DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobStep1_IDNO,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CHECK';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECK RESTART KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

   SELECT @Ls_RestartKey_TEXT = a.RestartKey_TEXT
     FROM RSTL_Y1 a
    WHERE a.Job_ID = @Lc_JobStep1_IDNO
      AND a.Run_DATE = @Ld_Run_DATE;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF(@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ln_NextProcess_NUMB = 1;
    END

   BEGIN TRANSACTION STEP1;

   IF (@Ln_NextProcess_NUMB = 1
        OR @Ls_RestartKey_TEXT = @Ls_Step1Routine1_TEXT)
    BEGIN
     SET @Ln_RecordCount_NUMB = 0;
     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_BI_MAPCM$SP_PROCESS_BIDATE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

     EXECUTE BATCH_BI_MAPCM$SP_PROCESS_BIDATE    
      @Ln_RecordCount_NUMB OUTPUT, 
      @Lc_Msg_CODE OUTPUT,
      @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       SET @Ls_DescriptionError_TEXT = ISNULL(@Ls_Step1Routine1_TEXT, '') + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
       SET @Ln_NextProcess_NUMB = 0;

       RAISERROR(50001,16,1);
      END
     
     SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @Ln_RecordCount_NUMB; 
    END

   IF (@Ln_NextProcess_NUMB = 1
        OR @Ls_RestartKey_TEXT = @Ls_Step1Routine2_TEXT)
    BEGIN
     SET @Ln_RecordCount_NUMB = 0;
     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_BI_MAPCM$SP_PROCESS_BIDECOUNTIES';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

     EXECUTE BATCH_BI_MAPCM$SP_PROCESS_BIDECOUNTIES     
      @Ln_RecordCount_NUMB OUTPUT,  
      @Lc_Msg_CODE OUTPUT,
      @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       SET @Ls_DescriptionError_TEXT = ISNULL(@Ls_Step1Routine2_TEXT, '') + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
       SET @Ln_NextProcess_NUMB = 0;

       RAISERROR(50001,16,1);
      END
     
     SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @Ln_RecordCount_NUMB;  
    END

   IF (@Ln_NextProcess_NUMB = 1
        OR @Ls_RestartKey_TEXT = @Ls_Procedure_NAME)
    BEGIN
     SET @Ln_RecordCount_NUMB = 0;
     SET @Ls_Sql_TEXT = 'BATCH BEGIN DATE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

     SELECT @Ld_Begin_DATE = MIN(a.Begin_DATE)
       FROM BPDATE_Y1 a;

     SET @Ls_Sql_TEXT = 'DELETE FROM BPCASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

     DELETE FROM BPCASE_Y1;

     SET @Ls_Sql_TEXT = 'INSERT INTO BPCASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '');

     INSERT INTO BPCASE_Y1
                 (PatStsEstablished_CODE,
                  Case_IDNO,
                  County_IDNO,
                  Opened_DATE,
                  StatusCase_CODE,
                  AsstCase_CODE,
                  TypeCase_CODE,
                  MemberMci_IDNO,
                  First_NAME,
                  Last_NAME,
                  Birth_DATE,
                  AgeNcp_QNTY,
                  DelinquencyPeriod_QNTY,
                  TotalObligations_QNTY,
                  Arrear_AMNT,
                  DurationNoAddr_QNTY,
                  DurationNoEmpl_QNTY,
                  Collection_AMNT,
                  TypeEstablish_CODE,
                  NcpIncome_AMNT,
                  AgeCase_QNTY,
                  CpAddress_CODE,
                  StatusOrder_CODE,
                  Mso_AMNT,
                  CpArrear_AMNT,
                  IvaArrear_AMNT,
                  Worker_ID,
                  ObligationPeriod_QNTY,
                  RespondInit_CODE,
                  CpEmployment_CODE,
                  Delinquency_CODE,
                  DependentCoverage_CODE,
                  AppMtdCs_AMNT,
                  CpMci_IDNO,
                  FirstCp_NAME,
                  LastCp_NAME,
                  Mso_CODE,
                  Collection_INDC,
                  MonthsMso_QNTY,
                  MonthsNoMso_QNTY,
                  MonthsCollection_QNTY,
                  MonthsNoCollection_QNTY,
                  MemberOther_ID,
                  LastOther_NAME,
                  FirstOther_NAME,
                  GoodCause_CODE,
                  DurationNoDob_QNTY,
                  DurationNoSsn_QNTY,
                  DurationNoMailAddr_QNTY,
                  DurationNoResiAddr_QNTY,
                  DurationNoCpMailAddr_QNTY,
                  DurationNoCpResiAddr_QNTY,
                  ActiveDependent_CODE,
                  NcpAddress_CODE,
                  NcpEmployment_CODE,
                  NcpResiAddress_CODE,
                  CpResiAddress_CODE,
                  NonCoop_CODE,
                  TotalOwed_AMNT,
                  TotalPaid_AMNT,
                  Restricted_CODE,
                  AppRetd_DATE,
                  Create_DATE,
                  Doc_NAME,
                  SourceRfrl_CODE,
                  PaternityEst_CODE,
                  TransactionEventSeq_NUMB,
                  CaseCategory_CODE,
                  RsnStatusCase_CODE,
                  OrderEffective_DATE,
                  OrderIssued_DATE,
                  Payback_AMNT,
                  FreqPayback_CODE,
                  OpenIW_CODE,
                  BenchWarrant_CODE,
                  ReliefToLit_CODE,
                  CurrentExemptions_TEXT,
                  PaymentLast_DATE,
                  DebtTypes_TEXT,
                  Charges_TEXT,
                  Frequencies_TEXT,
                  DistributeHold_AMNT,
                  DisbursementHold_AMNT,
                  MediumDisburse_CODE,
                  DirectPay_AMNT,
                  AppMtdArrears_AMNT,
                  CpRecoupBal_AMNT,
                  NcpNsfBalance_AMNT,
                  NcpNsf_CODE,
                  CaseWelfareIvae_ID,
                  TypeWelfare_CODE,
                  StatusLocate_CODE,
                  Ura_AMNT,
                  ReliefsRequested_TEXT,
                  ReliefsOrdered_TEXT,
                  Complaint_DATE,
                  File_ID,
                  NcpLocLocated_CODE,
                  NcpLocNotLocated_CODE,
                  NcpLocNotApplicable_CODE,
                  Child19To23_CODE,
                  ChildOver24_CODE,
                  MemberStatusActive_CODE,
                  MemberStatusInactive_CODE,
                  NoSsnCp_CODE,
                  NoSsnNcp_CODE,
                  DepOrderStsEmancipation_CODE,
                  DepOrderStsCourtOrder_CODE,
                  DepOrderStsNotCrtOrd_CODE,
                  CdBankruptcy07_CODE,
                  CdBankruptcy13_CODE,
                  CpMailingAddrGood_CODE,
                  CpMailingAddrBad_CODE,
                  CpMailingAddrPending_CODE,
                  CpResidentialAddrGood_CODE,
                  CpResidentialAddrBad_CODE,
                  CpResidentialAddrPend_CODE,
                  CpEmploymentAddrGood_CODE,
                  CpEmploymentAddrBad_CODE,
                  CpEmploymentAddrPend_CODE,
                  IntLocReqPendCp_CODE,
                  IntLocReqPendNcp_CODE,
                  NcpMailingAddrGood_CODE,
                  NcpMailingAddrBad_CODE,
                  NcpMailingAddrPending_CODE,
                  NcpResidentialAddrGood_CODE,
                  NcpResidentialAddrBad_CODE,
                  NcpResidentialAddrPend_CODE,
                  NcpEmploymentAddrGood_CODE,
                  NcpEmploymentAddrPend_CODE,
                  NcpEmploymentAddrBad_CODE,
                  EstActiveEstp_CODE,
                  EstActiveGtst_CODE,
                  EstActiveRofo_CODE,
                  EstNoActiveRemedy_CODE,
                  ExptdProcessAge03Month_CODE,
                  ExptdProcessAge06Month_CODE,
                  ExptdProcessAge09Month_CODE,
                  ExptdProcessAge12Month_CODE,
                  ExptdProcessAgeOvr1Y1_CODE,
                  ControllingOrdDE_CODE,
                  ControllingOrdOt_CODE,
                  CaseClosureInitiated_CODE,
                  FederalTax_CODE,
                  PassportDenial_CODE,
                  MultiStateFidm_CODE,
                  Insurance_CODE,
                  Vendor_CODE,
                  Retirement_CODE,
                  Salary_CODE,
                  EnforcementActiveAren_CODE,
                  EnforcementActiveCrpt_CODE,
                  EnforcementActiveCsln_CODE,
                  EnforcementActiveFidm_CODE,
                  EnforcementActiveImiw_CODE,
                  EnforcementActiveLint_CODE,
                  EnforcementActiveLsnr_CODE,
                  EnforcementActiveNmsn_CODE,
                  EnforcementActivePsoc_CODE,
                  EnforcementExemptAren_CODE,
                  EnforcementExemptCrpt_CODE,
                  EnforcementExemptCsln_CODE,
                  EnforcementExemptFidm_CODE,
                  EnforcementExemptImiw_CODE,
                  EnforcementExemptLint_CODE,
                  EnforcementExemptLsnr_CODE,
                  EnforcementExemptNmsn_CODE,
                  EnforcementExemptPsoc_CODE,
                  CpOrdered_CODE,
                  NcpOrdered_CODE,
                  Notordered_CODE,
                  InsuranceNotAvailable_CODE,
                  InsAvailableReasonable_CODE,
                  InsAvailableUnreason_CODE,
                  CpProviding_CODE,
                  NcpProviding_CODE,
                  ChildSupport_CODE,
                  MedicalSupport_CODE,
                  SpousalSupport_CODE,
                  GeneticTest_CODE,
                  InterestOnChildSupport_CODE,
                  InterestOnMedicalSupp_CODE,
                  InterestOnSpousalSupp_CODE,
                  InterestOnCashMedical_CODE,
                  InterestOnAlimony_CODE,
                  NotSatisfied_CODE,
                  NotSatisfiedPartialCol_CODE,
                  NotSatisfiedNoCol_CODE,
                  Satisfied_CODE,
                  WokerSubordinate_CODE,
                  Casebar_NUMB,
                  EstActiveRemedy_CODE,
                  EnforcementActiveRemedy_CODE,
                  EnforcementExemptRemedy_CODE,
                  OtherProviding_CODE,
                  RangeAgeCase_QNTY,
                  RangeArrear_AMNT,
                  RangeObligationPeriod_QNTY,
                  EstActiveFacl_CODE,
                  County_NAME,
                  ChildLess17_CODE,
                  Workers_NAME,
                  DependentCount_QNTY,
                  DentalIns_QNTY,
                  MedicalIns_QNTY,
                  VisionIns_QNTY,
                  MentalIns_QNTY,
                  PrescptIns_QNTY,
                  WarrantStatus_TEXT,
                  Fips_CODE,
                  ArrearPayment_CODE,
                  ActiveLicensePayment_CODE,
                  EndedLicensePayment_CODE,
                  NonCompliantLicensePayment_CODE,
                  CapiasIssued_CODE,
                  BothOrdered_CODE,
                  BothOrderedConditional_CODE,
                  CpCourtAddr_CODE,
                  CpOnlyConditional_CODE,
                  ChildUpto18_CODE,
                  EnforcementActiveCrim_CODE,
                  EnforcementActiveLien_CODE,
                  EnforcementActiveSeqo_CODE,
                  EnforcementExemptCrim_CODE,
                  EnforcementExemptLien_CODE,
                  EnforcementExemptSeqo_CODE,
                  EstActiveCoop_CODE,
                  EstActiveCclo_CODE,
                  EstActiveEmnp_CODE,
                  EstActiveMapp_CODE,
                  EstActiveObra_CODE,
                  EstActiveVapp_CODE,
                  ExpectToPayIndc_CODE,
                  MilitaryStatus_CODE,
                  NcpCourtAddr_CODE,
                  NcpNsfFee_CODE,
                  NcpOnlyConditional_CODE,
                  NoSsnDep_CODE,
                  PatStsDisestablished_CODE,
                  PatStsNotAnIssue_CODE,
                  PatStsUnknown_CODE,
                  PatStsToBeEstablished_CODE,
                  FamilyViolence_INDC,
                  Incarcerated_CODE)
     SELECT @Lc_Space_TEXT AS PatStsEstablished_CODE,
            a.Case_IDNO,
            a.County_IDNO,
            a.Opened_DATE,
            a.StatusCase_CODE,
            @Lc_Space_TEXT AS AsstCase_CODE,
            a.TypeCase_CODE,
            b.NcpPf_IDNO,
            b.FirstNcp_NAME,
            b.LastNcp_NAME,
            b.BirthNcp_DATE,
            CASE
             WHEN b.BirthNcp_DATE IN (@Ld_Lowdate_DATE, @Ld_Highdate_DATE)
              THEN 0
             WHEN b.BirthNcp_DATE IS NULL
              THEN 0
             ELSE CAST(ABS(DATEDIFF(DD, b.BirthNcp_DATE, @Ld_Run_DATE) / @Ln_DaysInyear_NUMB) AS NUMERIC)
            END AS AgeNcp_QNTY,
            @Ln_Zero_NUMB AS DelinquencyPeriod_QNTY,
            @Ln_Zero_NUMB AS TotalObligations_QNTY,
            @Ln_Zero_NUMB AS Arrear_AMNT,
            @Ln_Zero_NUMB AS DurationNoAddr_QNTY,
            @Ln_Zero_NUMB AS DurationNoEmpl_QNTY,
            @Ln_Zero_NUMB AS Collection_AMNT,
            @Lc_TypeEstablish_CODE AS TypeEstablish_CODE,
            @Ln_Zero_NUMB AS NcpIncome_AMNT,
            @Ln_Zero_NUMB AS AgeCase_QNTY,
            @Lc_No_TEXT AS CpAddress_CODE,
            @Lc_StatusOrderActive_CODE AS StatusOrder_CODE,
            @Ln_Zero_NUMB AS Mso_AMNT,
            @Ln_Zero_NUMB AS CpArrear_AMNT,
            @Ln_Zero_NUMB AS IvaArrear_AMNT,
            a.Worker_ID,
            @Ln_Zero_NUMB AS ObligationPeriod_QNTY,
            a.RespondInit_CODE,
            @Lc_Space_TEXT AS CpEmployment_CODE,
            @Lc_No_TEXT AS Delinquency_CODE,
            @Lc_No_TEXT AS DependentCoverage_CODE,
            @Ln_Zero_NUMB AS AppMtdCs_AMNT,
            b.CpMci_IDNO,
            b.FirstCp_NAME,
            b.LastCp_NAME,
            @Lc_No_TEXT AS Mso_CODE,
            @Lc_No_TEXT AS Collection_INDC,
            @Ln_Zero_NUMB AS MonthsMso_QNTY,
            @Ln_Zero_NUMB AS MonthsNoMso_QNTY,
            @Ln_Zero_NUMB AS MonthsCollection_QNTY,
            @Ln_Zero_NUMB AS MonthsNoCollection_QNTY,
            @Lc_Space_TEXT AS MemberOther_ID,
            @Lc_Space_TEXT AS LastOther_NAME,
            @Lc_Space_TEXT AS FirstOther_NAME,
            a.GoodCause_CODE,
            @Ln_Zero_NUMB AS DurationNoDob_QNTY,
            @Ln_Zero_NUMB AS DurationNoSsn_QNTY,
            @Ln_Zero_NUMB AS DurationNoMailAddr_QNTY,
            @Ln_Zero_NUMB AS DurationNoResiAddr_QNTY,
            @Ln_Zero_NUMB AS DurationNoCpMailAddr_QNTY,
            @Ln_Zero_NUMB AS DurationNoCpResiAddr_QNTY,
            @Lc_Space_TEXT AS ActiveDependent_CODE,
            @Lc_No_TEXT AS NcpAddress_CODE,
            @Lc_No_TEXT AS NcpEmployment_CODE,
            @Lc_No_TEXT AS NcpResiAddress_CODE,
            @Lc_No_TEXT AS CpResiAddress_CODE,
            a.NonCoop_CODE,
            @Ln_Zero_NUMB AS TotalOwed_AMNT,
            @Ln_Zero_NUMB AS TotalPaid_AMNT,
            a.Restricted_INDC,
            a.AppRetd_DATE AS AppRetd_DATE,
            @Ld_Highdate_DATE AS Create_DATE,
            @Lc_Space_TEXT AS Doc_NAME,
            a.SourceRfrl_CODE,
            @Lc_Space_TEXT AS PaternityEst_CODE,
            a.TransactionEventSeq_NUMB,
            a.CaseCategory_CODE,
            a.RsnStatusCase_CODE,
            @Lc_Space_TEXT AS OrderEffective_DATE,
            @Lc_Space_TEXT AS OrderIssued_DATE,
            @Ln_Zero_NUMB AS Payback_AMNT,
            @Lc_Space_TEXT AS FreqPayback_CODE,
            @Lc_Space_TEXT AS OpenIW_CODE,
            @Lc_Space_TEXT AS BenchWarrant_CODE,
            @Lc_Space_TEXT AS ReliefToLit_CODE,
            @Lc_Space_TEXT AS CurrentExemptions_TEXT,
            @Lc_Space_TEXT AS PaymentLast_DATE,
            @Lc_Space_TEXT AS DebtTypes_TEXT,
            @Lc_Space_TEXT AS Charges_TEXT,
            @Lc_Space_TEXT AS Frequencies_TEXT,
            @Ln_Zero_NUMB AS DistributeHold_AMNT,
            @Ln_Zero_NUMB AS DisbursementHold_AMNT,
            @Lc_Space_TEXT AS MediumDisburse_CODE,
            @Ln_Zero_NUMB AS DirectPay_AMNT,
            @Ln_Zero_NUMB AS AppMtdArrears_AMNT,
            @Ln_Zero_NUMB AS CpRecoupBal_AMNT,
            @Ln_Zero_NUMB AS NcpNsfBalance_AMNT,
            @Lc_Space_TEXT AS NcpNsf_CODE,
            b.CaseWelfare_IDNO AS CaseWelfareIvae_ID,
            b.TypeCase_CODE AS TypeWelfare_CODE,
            @Lc_Space_TEXT AS StatusLocate_CODE,
            @Ln_Zero_NUMB AS Ura_AMNT,
            @Lc_Space_TEXT AS ReliefsRequested_TEXT,
            @Lc_Space_TEXT AS ReliefsOrdered_TEXT,
            @Lc_Space_TEXT AS Complaint_DATE,
            @Lc_Space_TEXT AS File_ID,
            @Lc_Space_TEXT AS NcpLocLocated_CODE,
            @Lc_Space_TEXT AS NcpLocNotLocated_CODE,
            @Lc_Space_TEXT AS NcpLocNotApplicable_CODE,
            @Lc_Space_TEXT AS Child19To23_CODE,
            @Lc_Space_TEXT AS ChildOver24_CODE,
            @Lc_Space_TEXT AS MemberStatusActive_CODE,
            @Lc_Space_TEXT AS MemberStatusInactive_CODE,
            @Lc_Space_TEXT AS NoSsnCp_CODE,
            @Lc_Space_TEXT AS NoSsnNcp_CODE,
            @Lc_Space_TEXT AS DepOrderStsEmancipation_CODE,
            @Lc_Space_TEXT AS DepOrderStsCourtOrder_CODE,
            @Lc_Space_TEXT AS DepOrderStsNotCrtOrd_CODE,
            @Lc_Space_TEXT AS CdBankruptcy07_CODE,
            @Lc_Space_TEXT AS CdBankruptcy13_CODE,
            @Lc_Space_TEXT AS CpMailingAddrGood_CODE,
            @Lc_Space_TEXT AS CpMailingAddrBad_CODE,
            @Lc_Space_TEXT AS CpMailingAddrPending_CODE,
            @Lc_Space_TEXT AS CpResidentialAddrGood_CODE,
            @Lc_Space_TEXT AS CpResidentialAddrBad_CODE,
            @Lc_Space_TEXT AS CpResidentialAddrPend_CODE,
            @Lc_Space_TEXT AS CpEmploymentAddrGood_CODE,
            @Lc_Space_TEXT AS CpEmploymentAddrBad_CODE,
            @Lc_Space_TEXT AS CpEmploymentAddrPend_CODE,
            @Lc_Space_TEXT AS IntLocReqPendCp_CODE,
            @Lc_Space_TEXT AS IntLocReqPendNcp_CODE,
            @Lc_Space_TEXT AS NcpMailingAddrGood_CODE,
            @Lc_Space_TEXT AS NcpMailingAddrBad_CODE,
            @Lc_Space_TEXT AS NcpMailingAddrPending_CODE,
            @Lc_Space_TEXT AS NcpResidentialAddrGood_CODE,
            @Lc_Space_TEXT AS NcpResidentialAddrBad_CODE,
            @Lc_Space_TEXT AS NcpResidentialAddrPend_CODE,
            @Lc_Space_TEXT AS NcpEmploymentAddrGood_CODE,
            @Lc_Space_TEXT AS NcpEmploymentAddrPend_CODE,
            @Lc_Space_TEXT AS NcpEmploymentAddrBad_CODE,
            @Lc_Space_TEXT AS EstActiveEstp_CODE,
            @Lc_Space_TEXT AS EstActiveGtst_CODE,
            @Lc_Space_TEXT AS EstActiveRofo_CODE,
            @Lc_Space_TEXT AS EstNoActiveRemedy_CODE,
            @Lc_Space_TEXT AS ExptdProcessAge03Month_CODE,
            @Lc_Space_TEXT AS ExptdProcessAge06Month_CODE,
            @Lc_Space_TEXT AS ExptdProcessAge09Month_CODE,
            @Lc_Space_TEXT AS ExptdProcessAge12Month_CODE,
            @Lc_Space_TEXT AS ExptdProcessAgeOvr1Y1_CODE,
            @Lc_Space_TEXT AS ControllingOrdDE_CODE,
            @Lc_Space_TEXT AS ControllingOrdOt_CODE,
            @Lc_Space_TEXT AS CaseClosureInitiated_CODE,
            @Lc_Space_TEXT AS FederalTax_CODE,
            @Lc_Space_TEXT AS PassportDenial_CODE,
            @Lc_Space_TEXT AS MultiStateFidm_CODE,
            @Lc_Space_TEXT AS Insurance_CODE,
            @Lc_Space_TEXT AS Vendor_CODE,
            @Lc_Space_TEXT AS Retirement_CODE,
            @Lc_Space_TEXT AS Salary_CODE,
            @Lc_Space_TEXT AS EnforcementActiveAren_CODE,
            @Lc_Space_TEXT AS EnforcementActiveCrpt_CODE,
            @Lc_Space_TEXT AS EnforcementActiveCsln_CODE,
            @Lc_Space_TEXT AS EnforcementActiveFidm_CODE,
            @Lc_Space_TEXT AS EnforcementActiveImiw_CODE,
            @Lc_Space_TEXT AS EnforcementActiveLint_CODE,
            @Lc_Space_TEXT AS EnforcementActiveLsnr_CODE,
            @Lc_Space_TEXT AS EnforcementActiveNmsn_CODE,
            @Lc_Space_TEXT AS EnforcementActivePsoc_CODE,
            @Lc_Space_TEXT AS EnforcementExemptAren_CODE,
            @Lc_Space_TEXT AS EnforcementExemptCrpt_CODE,
            @Lc_Space_TEXT AS EnforcementExemptCsln_CODE,
            @Lc_Space_TEXT AS EnforcementExemptFidm_CODE,
            @Lc_Space_TEXT AS EnforcementExemptImiw_CODE,
            @Lc_Space_TEXT AS EnforcementExemptLint_CODE,
            @Lc_Space_TEXT AS EnforcementExemptLsnr_CODE,
            @Lc_Space_TEXT AS EnforcementExemptNmsn_CODE,
            @Lc_Space_TEXT AS EnforcementExemptPsoc_CODE,
            @Lc_Space_TEXT AS CpOrdered_CODE,
            @Lc_Space_TEXT AS NcpOrdered_CODE,
            @Lc_Space_TEXT AS Notordered_CODE,
            @Lc_Space_TEXT AS InsuranceNotAvailable_CODE,
            @Lc_Space_TEXT AS InsAvailableReasonable_CODE,
            @Lc_Space_TEXT AS InsAvailableUnreason_CODE,
            @Lc_Space_TEXT AS CpProviding_CODE,
            @Lc_Space_TEXT AS NcpProviding_CODE,
            @Lc_Space_TEXT AS ChildSupport_CODE,
            @Lc_Space_TEXT AS MedicalSupport_CODE,
            @Lc_Space_TEXT AS SpousalSupport_CODE,
            @Lc_Space_TEXT AS GeneticTest_CODE,
            @Lc_Space_TEXT AS InterestOnChildSupport_CODE,
            @Lc_Space_TEXT AS InterestOnMedicalSupp_CODE,
            @Lc_Space_TEXT AS InterestOnSpousalSupp_CODE,
            @Lc_Space_TEXT AS InterestOnCashMedical_CODE,
            @Lc_Space_TEXT AS InterestOnAlimony_CODE,
            @Lc_Space_TEXT AS NotSatisfied_CODE,
            @Lc_Space_TEXT AS NotSatisfiedPartialCol_CODE,
            @Lc_Space_TEXT AS NotSatisfiedNoCol_CODE,
            @Lc_Space_TEXT AS Satisfied_CODE,
            @Lc_Space_TEXT AS WokerSubordinate_CODE,
            @Ln_Zero_NUMB AS Casebar_NUMB,
            @Lc_Space_TEXT AS EstActiveRemedy_CODE,
            @Lc_Space_TEXT AS EnforcementActiveRemedy_CODE,
            @Lc_Space_TEXT AS EnforcementExemptRemedy_CODE,
            @Lc_Space_TEXT AS OtherProviding_CODE,
            @Ln_Zero_NUMB AS RangeAgeCase_QNTY,
            @Ln_Zero_NUMB AS RangeArrear_AMNT,
            @Ln_Zero_NUMB AS RangeObligationPeriod_QNTY,
            @Lc_Space_TEXT AS EstActiveFacl_CODE,
            @Lc_Space_TEXT AS County_NAME,
            @Lc_Space_TEXT AS ChildLess17_CODE,
            @Lc_Space_TEXT AS Workers_NAME,
            @Ln_Zero_NUMB AS DependentCount_QNTY,
            @Ln_Zero_NUMB AS DentalIns_QNTY,
            @Ln_Zero_NUMB AS MedicalIns_QNTY,
            @Ln_Zero_NUMB AS VisionIns_QNTY,
            @Ln_Zero_NUMB AS MentalIns_QNTY,
            @Ln_Zero_NUMB AS PrescptIns_QNTY,
            @Lc_Space_TEXT AS WarrantStatus_TEXT,
            @Lc_Space_TEXT AS Fips_CODE,
            @Lc_Space_TEXT AS ArrearPayment_CODE,
            @Lc_Space_TEXT AS ActiveLicensePayment_CODE,
            @Lc_Space_TEXT AS EndedLicensePayment_CODE,
            @Lc_Space_TEXT AS NonCompliantLicensePayment_CODE,
            CASE
             WHEN a.StatusEnforce_CODE = 'WCAP'
              THEN 1
             ELSE 0
            END AS CapiasIssued_CODE,
            @Lc_Space_TEXT AS BothOrdered_CODE,
            @Lc_Space_TEXT AS BothOrderedConditional_CODE,
            @Lc_Space_TEXT AS CpCourtAddr_CODE,
            @Lc_Space_TEXT AS CpOnlyConditional_CODE,
            @Lc_Space_TEXT AS ChildUpto18_CODE,
            @Lc_Space_TEXT AS EnforcementActiveCrim_CODE,
            @Lc_Space_TEXT AS EnforcementActiveLien_CODE,
            @Lc_Space_TEXT AS EnforcementActiveSeqo_CODE,
            @Lc_Space_TEXT AS EnforcementExemptCrim_CODE,
            @Lc_Space_TEXT AS EnforcementExemptLien_CODE,
            @Lc_Space_TEXT AS EnforcementExemptSeqo_CODE,
            @Lc_Space_TEXT AS EstActiveCoop_CODE,
            @Lc_Space_TEXT AS EstActiveCclo_CODE,
            @Lc_Space_TEXT AS EstActiveEmnp_CODE,
            @Lc_Space_TEXT AS EstActiveMapp_CODE,
            @Lc_Space_TEXT AS EstActiveObra_CODE,
            @Lc_Space_TEXT AS EstActiveVapp_CODE,
            @Lc_Space_TEXT AS ExpectToPayIndc_CODE,
            @Lc_Space_TEXT AS MilitaryStatus_CODE,
            @Lc_Space_TEXT AS NcpCourtAddr_CODE,
            @Lc_Space_TEXT AS NcpNsfFee_CODE,
            @Lc_Space_TEXT AS NcpOnlyConditional_CODE,
            @Lc_Space_TEXT AS NoSsnDep_CODE,
            @Lc_Space_TEXT AS PatStsDisestablished_CODE,
            @Lc_Space_TEXT AS PatStsNotAnIssue_CODE,
            @Lc_Space_TEXT AS PatStsUnknown_CODE,
            @Lc_Space_TEXT AS PatStsToBeEstablished_CODE,
            @Lc_Space_TEXT AS FamilyViolence_INDC,
            @Lc_Space_TEXT AS Incarcerated_CODE
       FROM CASE_Y1 a,
            ENSD_Y1 b
      WHERE (a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
              OR (a.StatusCase_CODE = @Lc_CaseStatusClosed_CODE
                  AND a.StatusCurrent_DATE >= @Ld_Begin_DATE))
        AND a.County_IDNO <> @Lc_County000_TEXT
        AND a.Case_IDNO = b.Case_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF (@Li_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_JobStep1_IDNO,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_Zero_NUMB,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
        @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END
     
     SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @Li_RowCount_QNTY;
    END

   COMMIT TRANSACTION STEP1;

   BEGIN TRANSACTION STEP1;
      
   SET @Ls_Sql_TEXT = 'UPDATE BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_JobStep1_IDNO + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;
   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobStep1_IDNO,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalRecordCount_NUMB;
   
   SET @Ls_Sql_TEXT = 'DELETE FROM RSTL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE RSTL_Y1
    WHERE Job_ID = @Lc_JobStep1_IDNO
      AND Run_DATE = @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep1_IDNO, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobStep1_IDNO,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   COMMIT TRANSACTION STEP1;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION STEP1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobStep1_IDNO,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END 

GO
