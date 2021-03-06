/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BITABLES5C]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BITABLES5C
Programmer Name	:	IMP Team.
Description		:	This process loads the data from staging tables into BI tables, mainly BiCase_T1 table.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BITABLES5C]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_CountyICRCentral_NUMB NUMERIC(2) = 99,
          @Li_RowCount_QNTY         INT = 0,
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_Failed_CODE           CHAR(1) = 'F',
          @Lc_Success_CODE          CHAR(1) = 'S',
          @Lc_TypeError_CODE        CHAR(1) = 'E',
          @Lc_Empty_TEXT            CHAR(1) = '',
          @Lc_BateError_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                CHAR(7) = 'DEB1420',
          @Lc_Process_NAME          CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME        VARCHAR(50) = 'SP_PROCESS_BITABLES5C',
          @Ld_Lowdate_DATE          DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BCASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BCASE_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BCASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BCASE_Y1
          (Case_IDNO,
           County_IDNO,
           Opened_DATE,
           StatusCase_CODE,
           AsstCase_CODE,
           CaseCategory_CODE,
           TypeCase_CODE,
           MemberMci_IDNO,
           First_NAME,
           Last_NAME,
           Birth_DATE,
           AgeNcp_QNTY,
           Office_IDNO,
           DelinquencyPeriod_QNTY,
           TotalObligations_QNTY,
           Arrear_AMNT,
           DurationNoAddr_QNTY,
           DurationNoEmpl_QNTY,
           DurationNoDob_QNTY,
           DurationNoSsn_QNTY,
           Collection_AMNT,
           DirectPay_AMNT,
           AgeCase_QNTY,
           CpAddress_CODE,
           PaternityEst_CODE,
           StatusOrder_CODE,
           Mso_AMNT,
           CpArrear_AMNT,
           IvaArrear_AMNT,
           TotalOwed_AMNT,
           TotalPaid_AMNT,
           AppMtdCs_AMNT,
           AppMtdArrears_AMNT,
           CpRecoupBal_AMNT,
           DistributeHold_AMNT,
           DisbursementHold_AMNT,
           Worker_ID,
           ObligationPeriod_QNTY,
           RespondInit_CODE,
           CdBankruptcy13_CODE,
           EnforcementActiveCrpt_CODE,
           EnforcementActiveImiw_CODE,
           EnforcementActiveLint_CODE,
           EnforcementActivePsoc_CODE,
           EnforcementActiveAren_CODE,
           EnforcementActiveCsln_CODE,
           EnforcementActiveFidm_CODE,
           EnforcementActiveLsnr_CODE,
           EnforcementActiveNmsn_CODE,
           EnforcementActiveCrim_CODE,
           EnforcementActiveLien_CODE,
           EnforcementActiveSeqo_CODE,
           EstActiveGtst_CODE,
           EstActiveCclo_CODE,
           EstActiveEmnp_CODE,
           EstActiveEstp_CODE,
           EstActiveVapp_CODE,
           EstActiveMapp_CODE,
           EstActiveObra_CODE,
           EstActiveRofo_CODE,
           CaseClosureInitiated_CODE,
           EstActiveRemedy_CODE,
           EnforcementActiveRemedy_CODE,
           EnforcementExemptRemedy_CODE,
           EstNoActiveRemedy_CODE,
           Complaint_DATE,
           EnforcementExemptAren_CODE,
           EnforcementExemptCrpt_CODE,
           EnforcementExemptCsln_CODE,
           EnforcementExemptFidm_CODE,
           EnforcementExemptImiw_CODE,
           EnforcementExemptLint_CODE,
           EnforcementExemptLsnr_CODE,
           EnforcementExemptNmsn_CODE,
           EnforcementExemptPsoc_CODE,
           EnforcementExemptCrim_CODE,
           EnforcementExemptLien_CODE,
           EnforcementExemptSeqo_CODE,
           NcpLocLocated_CODE,
           NcpLocNotLocated_CODE,
           NcpLocNotApplicable_CODE,
           ChildUpTo18_CODE,
           Child19To23_CODE,
           ChildOver24_CODE,
           MemberStatusActive_CODE,
           MemberStatusInactive_CODE,
           NoSsnCp_CODE,
           NoSsnNcp_CODE,
           NoSsnDep_CODE,
           PatStsDisestablished_CODE,
           PatStsEstablished_CODE,
           PatStsNotAnIssue_CODE,
           PatStsToBeEstablished_CODE,
           PatStsUnknown_CODE,
           DepOrderStsEmancipation_CODE,
           DepOrderStsCourtOrder_CODE,
           DepOrderStsNotCrtOrd_CODE,
           IntLocReqPendCp_CODE,
           IntLocReqPendNcp_CODE,
           Delinquency_CODE,
           NcpAddress_CODE,
           NcpEmployment_CODE,
           NcpResiAddress_CODE,
           CpResiAddress_CODE,
           CpMci_IDNO,
           FirstCp_NAME,
           LastCp_NAME,
           NonCoop_CODE,
           GoodCause_CODE,
           Restricted_CODE,
           AppRetd_DATE,
           SourceRfrl_CODE,
           TransactionEventSeq_NUMB,
           RsnStatusCase_CODE,
           OrderEffective_DATE,
           OrderIssued_DATE,
           Payback_AMNT,
           FreqPayback_CODE,
           OpenIW_CODE,
           BenchWarrant_CODE,
           Relieftolit_CODE,
           CurrentExemptions_TEXT,
           PaymentLast_DATE,
           DebtTypes_TEXT,
           Charges_TEXT,
           Frequencies_TEXT,
           CaseWelfareIvae_ID,
           TypeWelfare_CODE,
           StatusLocate_CODE,
           Ura_AMNT,
           ReliefsRequested_TEXT,
           ReliefsOrdered_TEXT,
           FederalTax_CODE,
           PassportDenial_CODE,
           MultiStateFidm_CODE,
           Insurance_CODE,
           Vendor_CODE,
           Retirement_CODE,
           Salary_CODE,
           InsAvailableReasonable_CODE,
           InsAvailableUnreason_CODE,
           ChildLess17_CODE,
           FamilyViolence_INDC,
           File_ID,
           County_NAME,
           ExptdProcessAge03Month_CODE,
           ExptdProcessAge06Month_CODE,
           ExptdProcessAge09Month_CODE,
           ExptdProcessAge12Month_CODE,
           ExptdProcessAgeOvr1Y1_CODE,
           CpOrdered_CODE,
           NcpOrdered_CODE,
           BothOrdered_CODE,
           BothOrderedConditional_CODE,
           CpOnlyConditional_CODE,
           NcpOnlyConditional_CODE,
           Notordered_CODE,
           ControllingOrdDe_CODE,
           ControllingOrdOt_CODE,
           CpProviding_CODE,
           NcpProviding_CODE,
           OtherProviding_CODE,
           ChildSupport_CODE,
           MedicalSupport_CODE,
           SpousalSupport_CODE,
           GeneticTest_CODE,
           NcpNsfFee_CODE,
           ExpectToPayIndc_CODE,
           CpCourtAddr_CODE,
           CpMailingAddrGood_CODE,
           CpMailingAddrBad_CODE,
           CpMailingAddrPending_CODE,
           CpResidentialAddrGood_CODE,
           CpResidentialAddrBad_CODE,
           CpResidentialAddrPend_CODE,
           CpEmploymentAddrGood_CODE,
           CpEmploymentAddrBad_CODE,
           CpEmploymentAddrPend_CODE,
           CpEmployment_CODE,
           NcpCourtAddr_CODE,
           NcpMailingAddrGood_CODE,
           NcpMailingAddrBad_CODE,
           NcpMailingAddrPending_CODE,
           NcpResidentialAddrGood_CODE,
           NcpResidentialAddrBad_CODE,
           NcpResidentialAddrPend_CODE,
           NcpEmploymentAddrGood_CODE,
           NcpEmploymentAddrBad_CODE,
           NcpEmploymentAddrPend_CODE,
           CdBankruptcy07_CODE,
           ActiveDependent_CODE,
           MediumDisburse_CODE,
           DependentCount_QNTY,
           NcpNsfBalance_AMNT,
           NcpNsf_CODE,
           DentalIns_QNTY,
           MedicalIns_QNTY,
           VisionIns_QNTY,
           MentalIns_QNTY,
           PrescptIns_QNTY,
           Workers_NAME,
           RangeAgeCase_QNTY,
           RangeArrear_AMNT,
           Mso_CODE,
           Collection_INDC,
           Create_DATE,
           Doc_NAME,
           MonthsMso_QNTY,
           MonthsNoMso_QNTY,
           MonthsCollection_QNTY,
           MonthsNoCollection_QNTY,
           WarrantStatus_TEXT,
           InsuranceNotAvailable_CODE,
           DependentCoverage_CODE,
           TypeEstablish_CODE,
           NcpIncome_AMNT,
           MemberOther_ID,
           LastOther_NAME,
           FirstOther_NAME,
           DurationNoMailAddr_QNTY,
           DurationNoResiAddr_QNTY,
           DurationNoCpMailAddr_QNTY,
           DurationNoCpResiAddr_QNTY,
           NotSatisfied_CODE,
           NotSatisfiedPartialCol_CODE,
           NotSatisfiedNoCol_CODE,
           Satisfied_CODE,
           WokerSubordinate_CODE,
           Casebar_NUMB,
           RangeObligationPeriod_QNTY,
           MilitaryStatus_CODE,
           PetitionFile_DATE,
           EstActiveCoop_CODE,
           ActiveLicensePayment_CODE,
           EndedLicensePayment_CODE,
           NonCompliantLicensePayment_CODE,
           CapiasIssued_CODE,
           InsOrdered_CODE,
           Fips_CODE,
           ArrearPayment_CODE,
           Incarcerated_CODE,
           DaysElapsedExptd_QNTY)
   SELECT DISTINCT
          a.Case_IDNO,
          b.County_IDNO,
          b.Opened_DATE,
          b.StatusCase_CODE,
          b.AsstCase_CODE,
          b.CaseCategory_CODE,
          b.TypeCase_CODE,
          a.MemberMci_IDNO,
          b.First_NAME,
          b.Last_NAME,
          b.Birth_DATE,
          b.AgeNcp_QNTY,
          b.Office_IDNO,
          d.DelinquencyPeriod_QNTY,
          c.TotalObligations_QNTY,
          b.Arrear_AMNT,
          b.DurationNoAddr_QNTY,
          b.DurationNoEmpl_QNTY,
          b.DurationNoDob_QNTY,
          b.DurationNoSsn_QNTY,
          d.Collection_AMNT,
          d.DirectPay_AMNT,
          b.AgeCase_QNTY,
          b.CpAddress_CODE,
          c.PaternityEst_CODE,
          b.StatusOrder_CODE,
          c.Mso_AMNT,
          c.CpArrear_AMNT,
          c.IvaArrear_AMNT,
          c.TotalOwed_AMNT,
          c.TotalPaid_AMNT,
          c.AppMtdCs_AMNT,
          c.AppMtdArrears_AMNT,
          c.CpRecoupBal_AMNT,
          c.DistributeHold_AMNT,
          c.DisbursementHold_AMNT,
          b.Worker_ID,
          d.ObligationPeriod_QNTY,
          b.RespondInit_CODE,
          c.CdBankruptcy13_CODE,
          a.EnforcementActiveCrpt_CODE,
          a.EnforcementActiveImiw_CODE,
          a.EnforcementActiveLint_CODE,
          a.EnforcementActivePsoc_CODE,
          a.EnforcementActiveAren_CODE,
          a.EnforcementActiveCsln_CODE,
          a.EnforcementActiveFidm_CODE,
          a.EnforcementActiveLsnr_CODE,
          a.EnforcementActiveNmsn_CODE,
          a.EnforcementActiveCrim_CODE,
          a.EnforcementActiveLien_CODE,
          a.EnforcementActiveSeqo_CODE,
          a.EstActiveGtst_CODE,
          a.EstActiveCclo_CODE,
          a.EstActiveEmnp_CODE,
          a.EstActiveEstp_CODE,
          a.EstActiveVapp_CODE,
          a.EstActiveMapp_CODE,
          a.EstActiveObra_CODE,
          a.EstActiveRofo_CODE,
          a.CaseClosureInitiated_CODE,
          a.EstActiveRemedy_CODE,
          a.EnforcementActiveRemedy_CODE,
          a.EnforcementExemptRemedy_CODE,
          a.EstNoActiveRemedy_CODE,
          b.Complaint_DATE,
          b.EnforcementExemptAren_CODE,
          b.EnforcementExemptCrpt_CODE,
          b.EnforcementExemptCsln_CODE,
          b.EnforcementExemptFidm_CODE,
          b.EnforcementExemptImiw_CODE,
          b.EnforcementExemptLint_CODE,
          b.EnforcementExemptLsnr_CODE,
          b.EnforcementExemptNmsn_CODE,
          b.EnforcementExemptPsoc_CODE,
          b.EnforcementExemptCrim_CODE,
          b.EnforcementExemptLien_CODE,
          b.EnforcementExemptSeqo_CODE,
          c.NcpLocLocated_CODE,
          c.NcpLocNotLocated_CODE,
          1 AS NcpLocNotApplicable_CODE,
          c.ChildUpTo18_CODE,
          c.Child19To23_CODE,
          c.ChildOver24_CODE,
          c.MemberStatusActive_CODE,
          c.MemberStatusInactive_CODE,
          c.NoSsnCp_CODE,
          c.NoSsnNcp_CODE,
          c.NoSsnDep_CODE,
          c.PatStsDisestablished_CODE,
          c.PatStsEstablished_CODE,
          c.PatStsNotAnIssue_CODE,
          c.PatStsToBeEstablished_CODE,
          c.PatStsUnknown_CODE,
          c.DepOrderStsEmancipation_CODE,
          c.DepOrderStsCourtOrder_CODE,
          c.DepOrderStsNotCrtOrd_CODE,
          CASE
           WHEN c.IntLocReqPendNcp_CODE IN (1, 3)
            THEN 1
           ELSE 0
          END IntLocReqPendCp_CODE,
          CASE
           WHEN c.IntLocReqPendNcp_CODE IN (1, 2)
            THEN 1
           ELSE 0
          END IntLocReqPendNcp_CODE,
          b.Delinquency_CODE,
          b.NcpAddress_CODE,
          ISNULL(b.NcpEmployment_CODE, 0) AS NcpEmployment_CODE,
          b.NcpResiAddress_CODE,
          b.CpResiAddress_CODE,
          b.CpMci_IDNO,
          b.FirstCp_NAME,
          b.LastCp_NAME,
          b.NonCoop_CODE,
          b.GoodCause_CODE,
          b.Restricted_CODE,
          b.AppRetd_DATE,
          b.SourceRfrl_CODE,
          b.TransactionEventSeq_NUMB,
          b.RsnStatusCase_CODE,
          b.OrderEffective_DATE,
          b.OrderIssued_DATE,
          b.Payback_AMNT,
          b.FreqPayback_CODE,
          c.OpenIW_CODE,
          a.BenchWarrant_CODE,
          a.Relieftolit_CODE,
          ISNULL(CASE
                  WHEN LTRIM(RTRIM(b.CurrentExemptions_TEXT)) != @Lc_Empty_TEXT
                   THEN
                   CASE
                    WHEN RIGHT(RTRIM(REPLACE(b.CurrentExemptions_TEXT, @Lc_Space_TEXT, @Lc_Empty_TEXT)), 1) = ','
                     THEN LEFT(REPLACE(b.CurrentExemptions_TEXT, @Lc_Space_TEXT, @Lc_Empty_TEXT), LEN(REPLACE(b.CurrentExemptions_TEXT, @Lc_Space_TEXT, '')) - 1)
                    ELSE REPLACE(b.CurrentExemptions_TEXT, @Lc_Space_TEXT, @Lc_Empty_TEXT)
                   END
                 END, @Lc_Space_TEXT) AS CurrentExemptions_TEXT,
          a.PaymentLast_DATE,
          c.DebtTypes_TEXT,
          c.Charges_TEXT,
          c.Frequencies_TEXT,
          b.CaseWelfareIvae_ID,
          b.TypeWelfare_CODE,
          c.StatusLocate_CODE,
          c.Ura_AMNT,
          d.ReliefsRequested_TEXT,
          d.ReliefsOrdered_TEXT,
          c.FederalTax_CODE,
          c.PassportDenial_CODE,
          c.MultiStateFidm_CODE,
          c.Insurance_CODE,
          c.Vendor_CODE,
          c.Retirement_CODE,
          c.Salary_CODE,
          c.InsAvailableReasonable_CODE,
          c.InsAvailableUnreason_CODE,
          c.ChildLess17_CODE,
          ISNULL(b.FamilyViolence_INDC, @Lc_Empty_TEXT) AS FamilyViolence_INDC,
          b.File_ID,
          b.County_NAME,
          c.ExptdProcessAge03Month_CODE,
          c.ExptdProcessAge06Month_CODE,
          c.ExptdProcessAge09Month_CODE,
          c.ExptdProcessAge12Month_CODE,
          c.ExptdProcessAgeOvr1Y1_CODE,
          d.CpOrdered_CODE,
          d.NcpOrdered_CODE,
          d.BothOrdered_CODE,
          d.BothOrderedConditional_CODE,
          d.CpOnlyConditional_CODE,
          d.NcpOnlyConditional_CODE,
          d.Notordered_CODE,
          d.ControllingOrdDe_CODE,
          d.ControllingOrdOt_CODE,
          c.CpProviding_CODE,
          c.NcpProviding_CODE,
          c.OtherProviding_CODE,
          c.ChildSupport_CODE,
          c.MedicalSupport_CODE,
          c.SpousalSupport_CODE,
          c.GeneticTest_CODE,
          c.NcpNsfFee_CODE,
          c.ExpectToPayIndc_CODE,
          b.CpCourtAddrIndc_CODE,
          b.CpMailingAddrGood_CODE,
          b.CpMailingAddrBad_CODE,
          b.CpMailingAddrPending_CODE,
          b.CpResidentialAddrGood_CODE,
          b.CpResidentialAddrBad_CODE,
          b.CpResidentialAddrPend_CODE,
          b.CpEmploymentAddrGood_CODE,
          b.CpEmploymentAddrBad_CODE,
          b.CpEmploymentAddrPend_CODE,
          b.CpEmployment_CODE,
          b.NcpCourtAddrIndc_CODE,
          b.NcpMailingAddrGood_CODE,
          b.NcpMailingAddrBad_CODE,
          b.NcpMailingAddrPending_CODE,
          b.NcpResidentialAddrGood_CODE,
          b.NcpResidentialAddrBad_CODE,
          b.NcpResidentialAddrPend_CODE,
          d.NcpEmploymentAddrGood_CODE,
          d.NcpEmploymentAddrBad_CODE,
          d.NcpEmploymentAddrPend_CODE,
          c.CdBankruptcy07_CODE,
          c.ActiveDependent_CODE,
          c.MediumDisburse_CODE,
          c.DependentCount_QNTY,
          c.NcpNsfBalance_AMNT,
          c.NcpNsf_CODE,
          c.DentalIns_QNTY,
          c.MedicalIns_QNTY,
          c.VisionIns_QNTY,
          c.MentalIns_QNTY,
          c.PrescptIns_QNTY,
          b.Workers_NAME,
          b.RangeAgeCase_QNTY,
          b.RangeArrear_AMNT,
          d.Mso_CODE,
          d.Collection_INDC,
          b.Create_DATE,
          c.Doc_NAME,
          d.MonthsMso_QNTY,
          d.MonthsNoMso_QNTY,
          d.MonthsCollection_QNTY,
          d.MonthsNoCollection_QNTY,
          @Lc_Space_TEXT AS WarrantStatus_TEXT,
          ISNULL(b.InsuranceNotAvailable_CODE, @Ln_Zero_NUMB) AS InsuranceNotAvailable_CODE,
          c.DependentCoverage_CODE,
          d.TypeEstablish_CODE,
          d.NcpIncome_AMNT,
          d.MemberOther_ID,
          d.LastOther_NAME,
          d.FirstOther_NAME,
          d.DurationNoMailAddr_QNTY,
          d.DurationNoResiAddr_QNTY,
          d.DurationNoCpMailAddr_QNTY,
          d.DurationNoCpResiAddr_QNTY,
          d.NotSatisfied_CODE,
          d.NotSatisfiedPartialCol_CODE,
          d.NotSatisfiedNoCol_CODE,
          d.Satisfied_CODE,
          d.WokerSubordinate_CODE,
          d.Casebar_NUMB,
          d.RangeObligationPeriod_QNTY,
          ISNULL(c.MilitaryStatus_CODE, 0) AS MilitaryStatus_CODE,
          ISNULL((SELECT MAX(f.Filed_DATE)
                    FROM FDEM_Y1 f
                   WHERE f.Case_IDNO = a.Case_IDNO
                   GROUP BY f.Case_IDNO), @Ld_Lowdate_DATE) AS PetitionFile_DATE,
          a.EstActiveCoop_CODE,
          a.ActiveLicensePayment_CODE,
          a.EndedLicensePayment_CODE,
          a.NonCompliantLicensePayment_CODE,
          a.CapiasIssued_CODE,
          @Lc_Space_TEXT AS InsOrdered_CODE,
          b.Fips_CODE,
          c.ArrearPayment_CODE,
          ISNULL(c.Incarcerated_CODE, @Ln_Zero_NUMB) AS Incarcerated_CODE,
          c.NoDaysElapsedExptd_QNTY AS DaysElapsedExptd_QNTY
     FROM BPCAS1_Y1 a,
          BPCAS2_Y1 b,
          BPCAS3_Y1 c,
          BPCAS4_Y1 d
    WHERE a.Case_IDNO = b.Case_IDNO
      AND a.MemberMci_IDNO = b.MemberMci_IDNO
      AND b.Case_IDNO = c.Case_IDNO
      AND b.MemberMci_IDNO = c.MemberMci_IDNO
      AND c.Case_IDNO = d.Case_IDNO
      AND c.MemberMci_IDNO = d.MemberMci_IDNO
      AND b.County_IDNO NOT IN (@Ln_CountyICRCentral_NUMB);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END   

   SET @Ls_Sql_TEXT = 'DELETE FROM BCASH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BCASH_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BCASH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BCASH_Y1
          (Case_IDNO,
           SupportYearMonth_NUMB,
           EndOfMonth_DATE,
           YearMonth_NUMB,
           Orderby_NUMB,
           CpArrear_AMNT,
           IvaArrear_AMNT,
           AppCs_AMNT,
           AppCpArr_AMNT,
           AppIvaArr_AMNT,
           Mso_AMNT,
           UnpaidMso_AMNT,
           UndistCollection_AMNT,
           UndistCollectionMonth_AMNT,
           IveArrear_AMNT)
   SELECT a.Case_IDNO,
          a.SupportYearMonth_NUMB,
          a.EndOfMonth_DATE,
          a.YearMonth_NUMB,
          a.Orderby_NUMB,
          a.CpArrear_AMNT,
          a.IvaArrear_AMNT,
          a.AppCs_AMNT,
          a.AppCpArr_AMNT,
          a.AppIvaArr_AMNT,
          a.Mso_AMNT,
          a.UnpaidMso_AMNT,
          a.UndistCollection_AMNT,
          a.UndistCollectionMonth_AMNT,
          a.IveArrear_AMNT
     FROM BPCASH_Y1 a
    WHERE a.CpArrear_AMNT != @Ln_Zero_NUMB
       OR a.IvaArrear_AMNT != @Ln_Zero_NUMB
       OR a.AppCs_AMNT != @Ln_Zero_NUMB
       OR a.AppCpArr_AMNT != @Ln_Zero_NUMB
       OR a.AppIvaArr_AMNT != @Ln_Zero_NUMB
       OR a.Mso_AMNT != @Ln_Zero_NUMB
       OR a.UnpaidMso_AMNT != @Ln_Zero_NUMB
       OR a.UndistCollection_AMNT != @Ln_Zero_NUMB
       OR a.UndistCollectionMonth_AMNT != @Ln_Zero_NUMB;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;
   
   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @Ls_Sql_TEXT = 'DELETE FROM BUSRL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BUSRL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BUSRL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BUSRL_Y1
          (Worker_ID,
           County_IDNO,
           Role_ID,
           Effective_DATE,
           Expire_DATE,
           AlphaRangeFrom_CODE,
           AlphaRangeTo_CODE,
           WorkerSub_ID,
           Supervisor_ID)
   SELECT a.Worker_ID,
          a.County_IDNO,
          a.Role_ID,
          a.Effective_DATE,
          a.Expire_DATE,
          a.AlphaRangeFrom_CODE,
          a.AlphaRangeTo_CODE,
          a.WorkerSub_ID,
          a.Supervisor_ID
     FROM BPUSRL_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BOFIC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BOFIC_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BOFIC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BOFIC_Y1
          (Office_IDNO,
           Office_NAME,
           County_IDNO,
           OtherParty_IDNO,
           CourtLocation_CODE,
           StartOffice_DTTM,
           CloseOffice_DTTM)
   SELECT a.Office_IDNO,
          a.Office_NAME,
          a.County_IDNO,
          a.OtherParty_IDNO,
          a.CourtLocation_CODE,
          a.StartOffice_DTTM,
          a.CloseOffice_DTTM
     FROM BPOFIC_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BROLE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BROLE_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BROLE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BROLE_Y1
          (Role_ID,
           Role_NAME,
           RoleSpecialist_CODE,
           Effective_DATE,
           Expire_DATE,
           ProfileXml_TEXT,
           StateRole_CODE,
           SupervisorRole_CODE)
   SELECT a.Role_ID,
          a.Role_NAME,
          a.RoleSpecialist_CODE,
          a.Effective_DATE,
          a.Expire_DATE,
          a.ProfileXml_TEXT,
          a.StateRole_CODE,
          a.SupervisorRole_CODE
     FROM BPROLE_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BAMJR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BAMJR_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BAMJR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BAMJR_Y1
          (ActivityMajor_CODE,
           BiSubsystem_CODE,
           DescriptionActivity_TEXT,
           PrActivityMajorInd_NUMB,
           Ahis_INDC,
           Ehis_INDC,
           Ssn_INDC,
           Plic_INDC,
           Ssi_INDC,
           AhisCp_INDC,
           AhisNcp_INDC,
           Bankruptcy07_CODE,
           Bankruptcy13_CODE,
           FinAsset_INDC,
           NonFinAsset_INDC,
           Incarceration_INDC,
           Stop_INDC,
           TypeOthpSource_CODE)
   SELECT a.ActivityMajor_CODE,
          a.BiSubsystem_CODE,
          a.DescriptionActivity_TEXT,
          a.PrActivityMajorInd_NUMB,
          a.Ahis_INDC,
          a.Ehis_INDC,
          a.Ssn_INDC,
          a.Plic_INDC,
          a.Ssi_INDC,
          a.AhisCp_INDC,
          a.AhisNcp_INDC,
          a.Bankruptcy07_CODE,
          a.Bankruptcy13_CODE,
          a.FinAsset_INDC,
          a.NonFinAsset_INDC,
          a.Incarceration_INDC,
          a.Stop_INDC,
          a.TypeOthpSource_CODE
     FROM BPAMJR_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BPCCNT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPCCNT_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPCCNT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPCCNT_Y1
          (County_IDNO,
           CountyCount_QNTY,
           TotalCount_QNTY,
           County_NAME)
   SELECT a.County_IDNO,
          COUNT(a.County_IDNO) CountyCount_QNTY,
          SUM(COUNT(a.County_IDNO)) OVER() TotalCount_QNTY,
          a.County_NAME
     FROM BCASE_Y1 a
    GROUP BY a.County_IDNO,
             a.County_NAME;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BCCNT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BCCNT_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BCCNT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BCCNT_Y1
          (County_IDNO,
           CountyCount_QNTY,
           TotalCount_QNTY,
           County_NAME)
   SELECT a.County_IDNO,
          a.CountyCount_QNTY,
          a.TotalCount_QNTY,
          a.County_NAME
     FROM BPCCNT_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + (SELECT COUNT(*)
                                                        FROM (SELECT Case_IDNO
                                                                FROM BCASE_Y1
                                                              UNION
                                                              SELECT Case_IDNO
                                                                FROM BCASH_Y1) AS t);   
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_Failed_CODE;
   SET @An_RecordCount_NUMB = 0;
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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END 

GO
