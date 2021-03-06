/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4C]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4C
Programmer Name	:	IMP Team.
Description		:	This process loads data from staging tables into BPCAS3_Y1.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4C]
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE @Li_RowCount_QNTY                  INT = 0,
		  @Lc_Zero_TEXT						 CHAR(1) = '0',
          @Lc_Space_TEXT                     CHAR(1) = ' ',          
          @Lc_No_TEXT                        CHAR(1) = 'N',
          @Lc_Yes_TEXT                       CHAR(1) = 'Y',
          @Lc_NotOrderedSupport_TEXT         CHAR(1) = 'N',
          @Lc_StatusAbnormalend_CODE         CHAR(1) = 'A',
          @Lc_CaseMemberActive_CODE          CHAR(1) = 'A', 
          @Lc_InsuranceNotOrdered_TEXT		 CHAR(1) = 'N',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_StatusCaseMemberA1_CODE        CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_TEXT       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT CHAR(1) = 'P',          
          @Lc_RelationshipCaseCp_TEXT        CHAR(1) = 'C',
          @Lc_RelationshipCaseDep_TEXT       CHAR(1) = 'D',
          @Lc_RelationshipCaseNcpAndCp_TEXT	 CHAR(1) = 'B',
          @Lc_TypeCaseNonIVD_CODE			 CHAR(1) = 'H',
          @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_CaseStatusClosed_CODE          CHAR(1) = 'C',
          @Lc_ExptdProcessMet_CODE			 CHAR(1) = 'M',
          @Lc_ExptdProcessNotMet_CODE		 CHAR(1) = 'N',
          @Lc_Success_CODE                   CHAR(1) = 'S',
          @Lc_Failed_CODE                    CHAR(1) = 'F',
          @Lc_InsOrderedNcpCpPutFather_CODE	 CHAR(1) = 'B',	
          @Lc_DisbMediumDirectDeposit_TEXT   CHAR(1) = 'D',
          @Lc_InsOrderedCp_CODE			     CHAR(1) = 'C',
          @Lc_InsOrderedNcp_CODE			 CHAR(1) = 'A',
          @Lc_InsOrderedPutFather_CODE		 CHAR(1) = 'P',          
          @Lc_StatusLocateL1_CODE            CHAR(1) = 'L',          
          @Lc_SsnB1_TEXT                     CHAR(1) = 'B',
          @Lc_SsnP1_TEXT                     CHAR(1) = 'P',
          @Lc_IwnStatusActive_CODE           CHAR(1) = 'A',
          @Lc_ProvidingMemberA1_TEXT         CHAR(1) = 'A',
          @Lc_ProvidingMemberC1_TEXT         CHAR(1) = 'C',
          @Lc_ProvidingMemberT1_TEXT         CHAR(1) = 'T',
          @Lc_PaternityEstD_TEXT             CHAR(1) = 'D',
          @Lc_PaternityEstE_TEXT             CHAR(1) = 'E',
          @Lc_PaternityEstN_TEXT             CHAR(1) = 'N',
          @Lc_PaternityEstT_TEXT             CHAR(1) = 'T',
          @Lc_PaternityEstU_TEXT             CHAR(1) = 'U',
          @Lc_ActionRequest_TEXT			 CHAR(1) = 'R',
          @Lc_ActionProvide_TEXT			 CHAR(1) = 'P',
          @Lc_ServiceResultNegative_CODE	 CHAR(1) = 'N',
          @Lc_ServiceResultPositive_CODE	 CHAR(1) = 'P',
          @Lc_FsrtTable_CODE				 CHAR(1) = 'F',
          @Lc_SordTable_CODE				 CHAR(1) = 'S',
          @Lc_DmjrDmnrTable_CODE			 CHAR(1) = 'D',
          @Lc_IncomeTypeActiveMilitary_TEXT  CHAR(2) = 'ML',
          @Lc_IncomeTypeMilitaryReserve_TEXT CHAR(2) = 'MR',
          @Lc_DebtTypeChildSupp_CODE         CHAR(2) = 'CS',
          @Lc_DebtTypeMedicalSupp_CODE       CHAR(2) = 'MS',
          @Lc_DebtTypeSpousalSupp_CODE		 CHAR(2) = 'SS',
          @Lc_DebtTypeGeneticTest_CODE       CHAR(2) = 'GT',
          @Lc_DebtTypeNcpNsfFee_CODE         CHAR(2) = 'NF',
          @Lc_DebtTypeIntChildSupp_CODE      CHAR(2) = 'CI',
          @Lc_DebtTypeIntMedicalSupp_CODE    CHAR(2) = 'MI',
          @Lc_DebtTypeIntSpousalSupp_CODE    CHAR(2) = 'SI',
          @Lc_DebtTypeIntCashMedical_CODE    CHAR(2) = 'HI',
          @Lc_DebtTypeIntAlimony_CODE        CHAR(2) = 'AI',  
          @Lc_ReasonStatusCi_CODE			 CHAR(2) = 'CI',
          @Lc_ReasonStatusRp_CODE			 CHAR(2) = 'RP',
          @Lc_ReasonStatusDb_CODE			 CHAR(2) = 'DB',
          @Lc_ChildSupport_CODE				 CHAR(2) = 'CS',        
          @Lc_MedicalSupport_CODE			 CHAR(2) = 'MS',
          @Lc_StatusCg_CODE                  CHAR(2) = 'CG',
          @Lc_Bankruptcy07_TEXT              CHAR(2) = '07',
          @Lc_Bankruptcy13_TEXT              CHAR(2) = '13',
          @Lc_County000_TEXT                 CHAR(3) = '000',
          @Lc_FunctionQuickLocate_TEXT	     CHAR(3) = 'LO1',
          @Lc_TableCcrt_IDNO                 CHAR(4) = 'CCRT',
          @Lc_TableSubFido_IDNO              CHAR(4) = 'FIDO',
          @Lc_StatusComplete_CODE			 CHAR(4) = 'COMP',
          @Lc_StatusStart_CODE			     CHAR(4) = 'STRT',
          @Lc_ActivityMajorEstp_CODE		 CHAR(4) = 'ESTP',
          @Lc_ActivityMajorCase_CODE		 CHAR(4) = 'CASE',
          @Lc_ActivityMajorRofo_CODE		 CHAR(4) = 'ROFO',
          @Lc_ActivityMinorAordd_CODE		 CHAR(5) = 'AORDD',          
          @Lc_ActivityMinorAnddi_CODE		 CHAR(5) = 'ANDDI', 
          @Lc_ActivityMinorRopdp_CODE	     CHAR(5) = 'ROPDP', 
          @Lc_ActivityMinorFamup_CODE		 CHAR(5) = 'FAMUP', 
          @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                 CHAR(5) = 'E0944',
          @Lc_JobStep4c_IDNO                 CHAR(7) = 'DEB1380',
          @Lc_Successful_TEXT                CHAR(10) = 'SUCCESSFUL',
          @Lc_Process_NAME                   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME                 VARCHAR(50) = 'SP_PROCESS_BIDAILYSTEP4C',
          @Ld_Highdate_DATE                  DATE = '12/31/9999',
          @Ld_Lowdate_DATE                   DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
		  @Ln_Two_NUMB					  NUMERIC(1) = 2,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT	      VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),          
          @Ld_Begin_DATE                  DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
          
  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4c_IDNO, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobStep4c_IDNO,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
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

   SELECT @Ld_Begin_DATE = MIN(a.Begin_DATE)
     FROM BPDATE_Y1 a;  

   SET @Ls_DescriptionError_TEXT = 'STEP:1 UPDATING BPCAS3_Y1';
   SET @Ls_Sql_TEXT = 'DELETE FROM BPCAS3_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4c_IDNO, '');

   DELETE FROM BPCAS3_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPCAS3_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4c_IDNO, '');
   
   BEGIN TRANSACTION STEP4C;

   INSERT BPCAS3_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           TotalObligations_QNTY,
           DebtTypes_TEXT,
           Charges_TEXT,
           Frequencies_TEXT,
           PaternityEst_CODE,
           NcpLocLocated_CODE,
           NcpLocNotLocated_CODE,           
           ChildUpto18_CODE,
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
           IntLocReqPendNcp_CODE, 
           StatusLocate_CODE,
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
           ActiveDependent_CODE,
           MediumDisburse_CODE,
           DependentCount_QNTY,
           NcpNsfBalance_AMNT,
           NcpNsf_CODE,
           Doc_NAME,
           ExptdProcessAge03Month_CODE,
           ExptdProcessAge06Month_CODE,
           ExptdProcessAge09Month_CODE,
           ExptdProcessAge12Month_CODE,
           ExptdProcessAgeOvr1Y1_CODE,
           DentalIns_QNTY,
           MedicalIns_QNTY,
           VisionIns_QNTY,
           MentalIns_QNTY,
           PrescptIns_QNTY,
           OpenIW_CODE,
           CpArrear_AMNT,
           IvaArrear_AMNT,
           TotalOwed_AMNT,
           TotalPaid_AMNT,
           Mso_AMNT,
           DisbursementHold_AMNT,
           CpRecoupBal_AMNT,
           ChildSupport_CODE,
           MedicalSupport_CODE,
           SpousalSupport_CODE,
           GeneticTest_CODE,
           NcpNsfFee_CODE,
           ExpectToPayIndc_CODE,
           InterestOnChildSupport_CODE,
           InterestOnMedicalSupp_CODE,
           InterestOnSpousalSupp_CODE,
           InterestOnCashMedical_CODE,
           InterestOnAlimony_CODE,
           Ura_AMNT,
           AppMtdCs_AMNT,
           AppMtdArrears_AMNT,
           DistributeHold_AMNT,
           DependentCoverage_CODE,
           CpProviding_CODE,
           NcpProviding_CODE,
           OtherProviding_CODE,
           CdBankruptcy07_CODE,
           CdBankruptcy13_CODE,
           MilitaryStatus_CODE,
           CpCourtAddr_CODE,
           NcpCourtAddr_CODE,
           NoDaysElapsedExptd_QNTY,
           CdBankruptcy11_CODE,
           Dep010_CODE,
           Dep1118_CODE,
           Dep2534_CODE,
           Dep3544_CODE,
           Dep4554_CODE,
           Dep5565_CODE,
           ChildOver65_CODE,
           NcpStatusActive_CODE,
           NcpStatusInactive_CODE,
           NcpStatusDeceased_CODE,
           CpStatusActive_CODE,
           CpStatusInactive_CODE,
           CpStatusDeceased_CODE,
           ChildStatusActive_CODE,
           ChildStatusInactive_CODE,
           ChildStatusDeceased_CODE,
           NcpStatusExcluded_CODE,
           BeginChildCoverage_DATE,
           BeginValidityCp_DATE,
           DeceasedCp_DATE,
           BeginValidityNcp_DATE,
           DeceasedNcp_DATE,
           ResultsReceivedNcp_DATE,
           FileBankruptcy_DATE,
           ProofFiling_DATE,
           BeginBankruptcy_DATE,
           EndBankruptcy_DATE,
           Dismissed_DATE,
           Discharge_DATE,
           FederalOffsetExclusion_DATE,
           CpLocLocated_CODE,
           CpLocNotLocated_CODE,
           ArrearPayment_CODE,
           Incarcerated_CODE)
   SELECT DISTINCT
          a.Case_IDNO,
          a.MemberMci_IDNO,
          ISNULL(ob.TotalObligations_QNTY, @Ln_Zero_NUMB) AS TotalObligations_QNTY,
          ISNULL(ob.DebtTypes_TEXT, @Lc_Space_TEXT) AS DebtTypes_TEXT,
          ISNULL(ob.Charges_TEXT, @Lc_Space_TEXT) AS Charges_TEXT,
          ISNULL(ob.Frequencies_CODE, @Lc_Space_TEXT) AS Frequencies_CODE,
          CASE
           WHEN dep.PaternityEst_INDC = @Lc_Yes_TEXT
            THEN 1
           ELSE 0
          END AS PaternityEst_CODE,          
          ISNULL(mem.NcpLocLocated_CODE, @Ln_Zero_NUMB) AS NcpLocLocated_CODE, 
          CASE
           WHEN mem.NcpLocLocated_CODE = 1
            THEN @Ln_Zero_NUMB
           ELSE 1
          END AS NcpLocNotLocated_CODE,           
          ISNULL(mem.ChildUpto18_CODE, @Ln_Zero_NUMB) AS ChildUpto18_CODE,
          ISNULL(mem.Child19To23_CODE, @Ln_Zero_NUMB) AS Child19To23_CODE,
          ISNULL(mem.ChildOver24_CODE, @Ln_Zero_NUMB) AS ChildOver24_CODE,
          ISNULL(mem.MemberStatusActive_CODE, @Ln_Zero_NUMB) AS MemberStatusActive_CODE,
          CASE
           WHEN mem.MemberStatusActive_CODE = 1
            THEN @Ln_Zero_NUMB
           ELSE 1
          END AS MemberStatusInactive_CODE,
          ISNULL(mem.NoSsnCp_CODE, @Ln_Zero_NUMB) AS NoSsnCp_CODE,
          ISNULL(mem.NoSsnNcp_CODE, @Ln_Zero_NUMB) AS NoSsnNcp_CODE,
          ISNULL(mem.NoSsnDep_CODE, @Ln_Zero_NUMB) AS NoSsnDep_CODE,
          ISNULL(mem.PatStsDisestablished_CODE, @Ln_Zero_NUMB) AS PatStsDisestablished_CODE,
          ISNULL(mem.PatStsEstablished_CODE, @Ln_Zero_NUMB) AS PatStsEstablished_CODE,
          ISNULL(mem.PatStsNotAnIssue_CODE, @Ln_Zero_NUMB) AS PatStsNotAnIssue_CODE,
          ISNULL(mem.PatStsToBeEstablished_CODE, @Ln_Zero_NUMB) AS PatStsToBeEstablished_CODE,
          ISNULL(mem.PatStsUnknown_CODE, @Ln_Zero_NUMB) AS PatStsUnknown_CODE,          
          ISNULL(mem.DepOrderStsEmancipation_CODE, @Ln_Zero_NUMB) AS DepOrderStsEmancipation_CODE,
		  ISNULL(mem.DepOrderStsCourtOrder_CODE, @Ln_Zero_NUMB) AS DepOrderStsCourtOrder_CODE, 
		  ISNULL(mem.DepOrderStsNotCrtOrd_CODE, @Ln_Zero_NUMB) AS DepOrderStsNotCrtOrd_CODE,
          CASE 
			WHEN mem.IntLocReqPendNcp_CODE = 1 AND mem.IntLocReqPendCp_CODE = 1 THEN 1 
			WHEN mem.IntLocReqPendNcp_CODE = 1 AND mem.IntLocReqPendCp_CODE = 0 THEN 2 
			WHEN mem.IntLocReqPendNcp_CODE = 0 AND mem.IntLocReqPendCp_CODE = 1 THEN 3 
			ELSE @Ln_Zero_NUMB
		  END AS IntLocReqPendNcp_CODE, 
          ISNULL(CASE 
                  WHEN mem.StatusLocate_CODE = 1 
                   THEN @Lc_StatusLocateL1_CODE
                  ELSE @Lc_No_TEXT
                 END, @Lc_No_TEXT) AS StatusLocate_CODE,
          ISNULL(mem.FederalTax_CODE, @Ln_Zero_NUMB) AS FederalTax_CODE,
          ISNULL(mem.PassportDenial_CODE, @Ln_Zero_NUMB) AS PassportDenial_CODE,
          ISNULL(mem.MultiStateFidm_CODE, @Ln_Zero_NUMB) AS MultiStateFidm_CODE,
          ISNULL(mem.Insurance_CODE, @Ln_Zero_NUMB) AS Insurance_CODE,
          ISNULL(mem.Vendor_CODE, @Ln_Zero_NUMB) AS Vendor_CODE,
          ISNULL(mem.Retirement_CODE, @Ln_Zero_NUMB) AS Retirement_CODE,
          ISNULL(mem.Salary_CODE, @Ln_Zero_NUMB) AS Salary_CODE,
          ISNULL(mem.InsAvailableReasonable_CODE, @Ln_Zero_NUMB) AS InsAvailableReasonable_CODE,
          ISNULL(mem.InsAvailableUnreason_CODE, @Ln_Zero_NUMB) AS InsAvailableUnreason_CODE,
          ISNULL(mem.ChildLess17_CODE, @Ln_Zero_NUMB) AS ChildLess17_CODE,
          ISNULL(CASE 
                  WHEN mem.ActiveDependent_CODE = 1 
                   THEN @Lc_Yes_TEXT
                  ELSE @Lc_No_TEXT
                 END, @Lc_No_TEXT) AS ActiveDependent_CODE,
          ISNULL(CASE 
                  WHEN mem.MediumDisburse_CODE = 1 
                   THEN @Lc_DisbMediumDirectDeposit_TEXT
                  ELSE @Lc_Space_TEXT
                 END, @Lc_Space_TEXT) AS MediumDisburse_CODE,
          ISNULL(mem.DependentCount_QNTY, @Ln_Zero_NUMB) AS DependentCount_QNTY,
          ISNULL(mem.NcpNsfBalance_AMNT, @Ln_Zero_NUMB) AS NcpNsfBalance_AMNT,
          ISNULL(CASE 
                  WHEN mem.MediumDisburse_CODE = 1 
                   THEN @Lc_Yes_TEXT
                  ELSE @Lc_No_TEXT
                 END, @Lc_Space_TEXT) AS NcpNsf_CODE,
          ISNULL(fdem.SourceDoc_CODE, @Lc_No_TEXT) AS Doc_NAME,
          ISNULL(age_process.ExptdProcessAge03Month_CODE, @Ln_Zero_NUMB) AS ExptdProcessAge03Month_CODE,
          ISNULL(age_process.ExptdProcessAge06Month_CODE, @Ln_Zero_NUMB) AS ExptdProcessAge06Month_CODE,
          ISNULL(age_process.ExptdProcessAge09Month_CODE, @Ln_Zero_NUMB) AS ExptdProcessAge09Month_CODE,
          ISNULL(age_process.ExptdProcessAge12Month_CODE, @Ln_Zero_NUMB) AS ExptdProcessAge12Month_CODE,
          ISNULL(age_process.ExptdProcessAgeOvr1Y1_CODE, @Ln_Zero_NUMB) AS ExptdProcessAgeOvr1Y1_CODE,
          ISNULL(mem_dins.DentalIns_QNTY, @Ln_Zero_NUMB) AS DentalIns_QNTY,
          ISNULL(mem_dins.MedicalIns_QNTY, @Ln_Zero_NUMB) AS MedicalIns_QNTY,
          ISNULL(mem_dins.VisionIns_QNTY, @Ln_Zero_NUMB) AS VisionIns_QNTY,
          ISNULL(mem_dins.MentalIns_QNTY, @Ln_Zero_NUMB) AS MentalIns_QNTY,
          ISNULL(mem_dins.PrescptIns_QNTY, @Ln_Zero_NUMB) AS PrescptIns_QNTY,
          ISNULL(CASE
                  WHEN iwem.IwnStatus_CODE = @Lc_Yes_TEXT
                   THEN @Lc_Yes_TEXT
                  ELSE @Lc_No_TEXT
                 END, @Lc_No_TEXT) AS OpenIW_CODE,
          ISNULL(lsup.CpArrear_AMNT, @Ln_Zero_NUMB) AS CpArrear_AMNT,
          ISNULL(lsup.IvaArrear_AMNT, @Ln_Zero_NUMB) AS IvaArrear_AMNT,
          ISNULL(lsup.TotalOwed_AMNT, @Ln_Zero_NUMB) AS TotalOwed_AMNT,
          ISNULL(lsup.TotalPaid_AMNT, @Ln_Zero_NUMB) AS TotalPaid_AMNT,
          ISNULL(a.Mso_AMNT, @Ln_Zero_NUMB) AS Mso_AMNT,
          ISNULL(dhld.DisbursementHold_AMNT, @Ln_Zero_NUMB) AS DisbursementHold_AMNT,
          ISNULL(pofl.CpRecoupBal_AMNT, @Ln_Zero_NUMB) AS CpRecoupBal_AMNT,
          ISNULL(oble.ChildSupport_CODE, @Ln_Zero_NUMB) AS ChildSupport_CODE,
          ISNULL(oble.MedicalSupport_CODE, @Ln_Zero_NUMB) AS MedicalSupport_CODE,
          ISNULL(oble.SpousalSupport_CODE, @Ln_Zero_NUMB) AS SpousalSupport_CODE,
          ISNULL(oble.GeneticTest_CODE, @Ln_Zero_NUMB) AS GeneticTest_CODE,
          ISNULL(oble.NcpNsfFee_CODE, @Ln_Zero_NUMB) AS NcpNsfFee_CODE,
          CASE
           WHEN a.ExpectToPay_AMNT > 0
            THEN 1
            ELSE 0
          END AS ExpectToPayIndc_CODE,
          ISNULL(oble.InterestOnChildSupport_CODE, @Ln_Zero_NUMB) AS InterestOnChildSupport_CODE,
          ISNULL(oble.InterestOnMedicalSupp_CODE, @Ln_Zero_NUMB) AS InterestOnMedicalSupp_CODE,
          ISNULL(oble.InterestOnSpousalSupp_CODE, @Ln_Zero_NUMB) AS InterestOnSpousalSupp_CODE,
          ISNULL(oble.InterestOnCashMedical_CODE, @Ln_Zero_NUMB) AS InterestOnCashMedical_CODE,
          ISNULL(oble.InterestOnAlimony_CODE, @Ln_Zero_NUMB) AS InterestOnAlimony_CODE,
          ISNULL(oble.Ura_AMNT, @Ln_Zero_NUMB) AS Ura_AMNT,
          ISNULL(appl.AppMtdCs_AMNT, @Ln_Zero_NUMB) AS AppMtdCs_AMNT,
          ISNULL(appl.AppMtdArrears_AMNT, @Ln_Zero_NUMB) AS AppMtdArrears_AMNT,
          ISNULL(appl.DistributeHold_AMNT, @Ln_Zero_NUMB) AS DistributeHold_AMNT,
          ISNULL(CASE WHEN EXISTS (SELECT 1 
									 FROM SORD_Y1 s 
									WHERE s.Case_IDNO = a.Case_IDNO
									  AND s.InsOrdered_CODE <> @Lc_NotOrderedSupport_TEXT)
					THEN
					 CASE
					  WHEN minsBoth.InsOrdered_CODE IN (@Lc_RelationshipCaseNcpAndCp_TEXT)
					   THEN
						CASE
						 WHEN minsBoth.DependentCoverage_CODE = 1 
						  THEN @Lc_Yes_TEXT
						 WHEN minsBoth.DependentCoverage_CODE = 0
						  THEN @Lc_No_TEXT
						 ELSE @Lc_No_TEXT
						END
					  WHEN minsNcpCp.InsOrdered_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT, @Lc_RelationshipCaseCp_TEXT)
					   THEN
						CASE
						 WHEN minsNcpCp.DependentCoverage_CODE = 1 
						  THEN @Lc_Yes_TEXT
						 WHEN minsNcpCp.DependentCoverage_CODE = 0
						  THEN @Lc_No_TEXT
						 ELSE @Lc_No_TEXT
						END
					  ELSE @Lc_No_TEXT
					 END
                 END, @Lc_Space_TEXT) AS DependentCoverage_CODE,
          ISNULL(medi.CpProviding_CODE, @Ln_Two_NUMB) AS CpProviding_CODE,
          ISNULL(medi.NcpProviding_CODE, @Ln_Two_NUMB) AS NcpProviding_CODE,
          ISNULL(medi.OtherProviding_CODE, @Ln_Two_NUMB) AS OtherProviding_CODE,
          ISNULL(bank_stg.CdBankruptcy07_CODE, @Ln_Zero_NUMB) AS CdBankruptcy07_CODE,
          ISNULL(bank_stg.CdBankruptcy13_CODE, @Ln_Zero_NUMB) AS CdBankruptcy13_CODE,
          ISNULL((SELECT DISTINCT y.TypeIncome_CODE
                    FROM EHIS_Y1 y
                   WHERE y.MemberMci_IDNO = a.MemberMci_IDNO
                     AND y.TypeIncome_CODE IN (@Lc_IncomeTypeActiveMilitary_TEXT, @Lc_IncomeTypeMilitaryReserve_TEXT)
                     AND y.EndEmployment_DATE = @Ld_Highdate_DATE), 0) AS MilitaryStatus_CODE,
          @Ln_Zero_NUMB AS CpCourtAddr_CODE,
          @Ln_Zero_NUMB AS NcpCourtAddr_CODE,
          @Ln_Zero_NUMB AS NoDaysElapsedExptd_QNTY,
          @Ln_Zero_NUMB AS CdBankruptcy11_CODE, 
          @Ln_Zero_NUMB AS Dep010_CODE, 
          @Ln_Zero_NUMB AS Dep1118_CODE, 
          @Ln_Zero_NUMB AS Dep2534_CODE, 
          @Ln_Zero_NUMB AS Dep3544_CODE, 
          @Ln_Zero_NUMB AS Dep4554_CODE, 
          @Ln_Zero_NUMB AS Dep5565_CODE, 
          @Ln_Zero_NUMB AS ChildOver65_CODE, 
          @Ln_Zero_NUMB AS NcpStatusActive_CODE, 
          @Ln_Zero_NUMB AS NcpStatusInactive_CODE, 
          @Ln_Zero_NUMB AS NcpStatusDeceased_CODE, 
          @Ln_Zero_NUMB AS CpStatusActive_CODE, 
          @Ln_Zero_NUMB AS CpStatusInactive_CODE, 
          @Ln_Zero_NUMB AS CpStatusDeceased_CODE, 
          @Ln_Zero_NUMB AS ChildStatusActive_CODE, 
          @Ln_Zero_NUMB AS ChildStatusInactive_CODE, 
          @Ln_Zero_NUMB AS ChildStatusDeceased_CODE, 
          @Ln_Zero_NUMB AS NcpStatusExcluded_CODE, 
          @Lc_Space_TEXT AS BeginChildCoverage_DATE, 
          @Lc_Space_TEXT AS BeginValidityCp_DATE, 
          @Lc_Space_TEXT AS DeceasedCp_DATE, 
          @Lc_Space_TEXT AS BeginValidityNcp_DATE, 
          @Lc_Space_TEXT AS DeceasedNcp_DATE, 
          @Lc_Space_TEXT AS ResultsReceivedNcp_DATE, 
          @Lc_Space_TEXT AS FileBankruptcy_DATE, 
          @Lc_Space_TEXT AS ProofFiling_DATE, 
          @Lc_Space_TEXT AS BeginBankruptcy_DATE, 
          @Lc_Space_TEXT AS EndBankruptcy_DATE, 
          @Lc_Space_TEXT AS Dismissed_DATE, 
          @Lc_Space_TEXT AS Discharge_DATE, 
          @Lc_Space_TEXT AS FederalOffsetExclusion_DATE, 
          @Ln_Zero_NUMB AS CpLocLocated_CODE, 
          @Ln_Zero_NUMB AS CpLocNotLocated_CODE, 
          CASE
           WHEN a.ExpectToPay_AMNT > 0
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS ArrearPayment_CODE,
          CASE
           WHEN EXISTS (SELECT DISTINCT 1
                          FROM MDET_Y1 z
                         WHERE z.MemberMci_IDNO = a.MemberMci_IDNO
                           AND z.Release_DATE > @Ld_Start_DATE)
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS Incarcerated_CODE
     FROM (SELECT c.MemberMci_IDNO,	
                  e.*
             FROM ENSD_Y1 e, 
                  CMEM_Y1 c
            WHERE e.Case_IDNO = c.Case_IDNO
              AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
              AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE) AS a
          LEFT OUTER JOIN 
          (
             SELECT 
                fci.Case_IDNO, 
                SUM(CAST(fci.TotalObligations_QNTY AS NUMERIC(1))) AS TotalObligations_QNTY, 
                MIN(fci.BeginObligation_DATE) AS MinBeginObligation_DATE, 
                (SELECT STUFF((SELECT ',' + x.TypeDebt_CODE FROM OBLE_Y1 x WHERE x.Case_IDNO = fci.Case_IDNO FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(250)'), 1, 1, '')) AS DebtTypes_TEXT, 
                (SELECT STUFF((SELECT ',' + CAST(x.Periodic_AMNT AS VARCHAR) FROM OBLE_Y1 x WHERE x.Case_IDNO = fci.Case_IDNO FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(250)'), 1, 1, '')) AS Charges_TEXT, 
                (SELECT STUFF((SELECT ',' + x.FreqPeriodic_CODE FROM OBLE_Y1 x WHERE x.Case_IDNO = fci.Case_IDNO FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(250)'), 1, 1, '')) AS Frequencies_CODE
             FROM 
                (
                   SELECT 
                      b.Case_IDNO, 
                      CASE 
                         WHEN @Ld_Run_DATE BETWEEN b.BeginObligation_DATE AND b.EndObligation_DATE AND b.Periodic_AMNT > 0 THEN 1
                         ELSE 0
                      END AS TotalObligations_QNTY, 
                      b.BeginObligation_DATE, 
                      b.TypeDebt_CODE, 
                      b.Periodic_AMNT, 
                      b.FreqPeriodic_CODE
                   FROM OBLE_Y1 b
                   WHERE b.EndValidity_DATE = @Ld_Highdate_DATE
                )  AS fci
             GROUP BY fci.Case_IDNO
          )  AS ob 
          ON a.Case_IDNO = ob.Case_IDNO 
          LEFT OUTER JOIN (SELECT b.Case_IDNO,
                                  MIN(c.PaternityEst_INDC) AS PaternityEst_INDC
                             FROM CMEM_Y1 b,
                                  MPAT_Y1 c
                            WHERE b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                              AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                              AND c.MemberMci_IDNO = b.MemberMci_IDNO
                            GROUP BY b.Case_IDNO) AS dep
           ON a.Case_IDNO = dep.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO, 
                                  MAX(CAST(fci.NcpLocLocated_CODE AS NUMERIC(1))) AS NcpLocLocated_CODE,                                  
                                  MAX(CAST(fci.ChildUpto18_CODE AS NUMERIC(1))) AS ChildUpto18_CODE,
                                  MAX(CAST(fci.Child19To23_CODE AS NUMERIC(1))) AS Child19To23_CODE,
                                  MAX(CAST(fci.ChildOver24_CODE AS NUMERIC(1))) AS ChildOver24_CODE,
                                  MAX(CAST(fci.MemberStatusActive_CODE AS NUMERIC(1))) AS MemberStatusActive_CODE,                                  
                                  MAX(CAST(fci.NoSsnCp_CODE AS NUMERIC(1))) AS NoSsnCp_CODE,
                                  MAX(CAST(fci.NoSsnNcp_CODE AS NUMERIC(1))) AS NoSsnNcp_CODE,
                                  MAX(CAST(fci.NoSsnDep_CODE AS NUMERIC(1))) AS NoSsnDep_CODE,
                                  MAX(CAST(fci.PatStsDisestablished_CODE AS NUMERIC(1))) AS PatStsDisestablished_CODE,
                                  MAX(CAST(fci.PatStsEstablished_CODE AS NUMERIC(1))) AS PatStsEstablished_CODE,
                                  MAX(CAST(fci.PatStsNotAnIssue_CODE AS NUMERIC(1))) AS PatStsNotAnIssue_CODE,
                                  MAX(CAST(fci.PatStsToBeEstablished_CODE AS NUMERIC(1))) AS PatStsToBeEstablished_CODE,
                                  MAX(CAST(fci.PatStsUnknown_CODE AS NUMERIC(1))) AS PatStsUnknown_CODE,                                  
                                  MAX(CAST(fci.IntLocReqPendCp_CODE AS NUMERIC(1))) AS IntLocReqPendCp_CODE,
                                  MAX(CAST(fci.IntLocReqPendNcp_CODE AS NUMERIC(1))) AS IntLocReqPendNcp_CODE,
                                  MAX(CAST(fci.StatusLocate_CODE AS NUMERIC(1))) AS StatusLocate_CODE, 
                                  MAX(CAST(fci.FederalTax_CODE AS NUMERIC(1))) AS FederalTax_CODE,
                                  MAX(CAST(fci.PassportDenial_CODE AS NUMERIC(1))) AS PassportDenial_CODE,
                                  MAX(CAST(fci.MultiStateFidm_CODE AS NUMERIC(1))) AS MultiStateFidm_CODE,
                                  MAX(CAST(fci.Insurance_CODE AS NUMERIC(1))) AS Insurance_CODE,
                                  MAX(CAST(fci.Vendor_CODE AS NUMERIC(1))) AS Vendor_CODE,
                                  MAX(CAST(fci.Retirement_CODE AS NUMERIC(1))) AS Retirement_CODE,
                                  MAX(CAST(fci.Salary_CODE AS NUMERIC(1))) AS Salary_CODE,
                                  MAX(CAST(fci.InsAvailableReasonable_CODE AS NUMERIC(1))) AS InsAvailableReasonable_CODE,
                                  MAX(CAST(fci.InsAvailableUnreason_CODE AS NUMERIC(1))) AS InsAvailableUnreason_CODE,
                                  MAX(CAST(fci.ChildLess17_CODE AS NUMERIC(1))) AS ChildLess17_CODE,
                                  MAX(CAST(fci.FamilyViolence_INDC AS NUMERIC(1))) AS FamilyViolence_INDC,
                                  MAX(CAST(fci.ActiveDependent_CODE AS NUMERIC(1))) AS ActiveDependent_CODE, 
                                  MAX(CAST(fci.MediumDisburse_CODE AS NUMERIC(1))) AS MediumDisburse_CODE, 
                                  SUM(fci.DependentCount_QNTY) AS DependentCount_QNTY, 
                                  SUM(fci.NcpNsfBalance_AMNT) AS NcpNsfBalance_AMNT,
                                  MAX(CAST(fci.NcpNsf_CODE AS NUMERIC(1))) AS NcpNsf_CODE, 
                                  MAX(CAST(fci.DepOrderStsEmancipation_CODE AS NUMERIC(1))) AS DepOrderStsEmancipation_CODE,
                                  MAX(CAST(fci.DepOrderStsCourtOrder_CODE AS NUMERIC(1))) AS DepOrderStsCourtOrder_CODE,
                                  MAX(CAST(fci.DepOrderStsNotCrtOrd_CODE AS NUMERIC(1))) AS DepOrderStsNotCrtOrd_CODE
                             FROM (SELECT b.Case_IDNO, 
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND b.StatusLocate_CODE = @Lc_StatusLocateL1_CODE
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS NcpLocLocated_CODE,                                          
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.Age_QNTY BETWEEN 0 AND 18
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS ChildUpto18_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.Age_QNTY BETWEEN 19 AND 23
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS Child19To23_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.Age_QNTY > 23
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS ChildOver24_CODE,
                                          CASE
                                           WHEN (SELECT COUNT(1) 
                                                   FROM BPMEMB_Y1 m 
                                                  WHERE m.Case_IDNO = b.Case_IDNO
                                                    AND m.CaseMemberStatus_CODE != @Lc_StatusCaseMemberA1_CODE) = 0
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS MemberStatusActive_CODE,                                          
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND b.Ssn_CODE IN (@Lc_SsnB1_TEXT, @Lc_SsnP1_TEXT)
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS NoSsnCp_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND b.Ssn_CODE IN (@Lc_SsnB1_TEXT, @Lc_SsnP1_TEXT)
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS NoSsnNcp_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND b.Ssn_CODE IN (@Lc_SsnB1_TEXT, @Lc_SsnP1_TEXT)
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS NoSsnDep_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND (SELECT x.StatusEstablish_CODE 
                                                       FROM MPAT_Y1 x
                                                      WHERE x.MemberMci_IDNO = b.MemberMci_IDNO) = @Lc_PaternityEstD_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS PatStsDisestablished_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND (SELECT x.StatusEstablish_CODE 
                                                       FROM MPAT_Y1 x
                                                      WHERE x.MemberMci_IDNO = b.MemberMci_IDNO) = @Lc_PaternityEstE_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS PatStsEstablished_CODE,
                                          CASE
                                            WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                 AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                 AND (SELECT x.StatusEstablish_CODE 
                                                       FROM MPAT_Y1 x
                                                      WHERE x.MemberMci_IDNO = b.MemberMci_IDNO) = @Lc_PaternityEstN_TEXT
                                             THEN 1
                                            ELSE @Ln_Zero_NUMB
                                           END AS PatStsNotAnIssue_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND (SELECT x.StatusEstablish_CODE 
                                                       FROM MPAT_Y1 x
                                                      WHERE x.MemberMci_IDNO = b.MemberMci_IDNO) = @Lc_PaternityEstT_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS PatStsToBeEstablished_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND (SELECT x.StatusEstablish_CODE 
                                                       FROM MPAT_Y1 x
                                                      WHERE x.MemberMci_IDNO = b.MemberMci_IDNO) = @Lc_PaternityEstU_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS PatStsUnknown_CODE,                                          
                                          CASE
                                           WHEN EXISTS (SELECT DISTINCT 1
                                                          FROM CTHB_Y1 z
                                                         WHERE z.Case_IDNO = b.Case_IDNO
                                                           AND z.Function_CODE = @Lc_FunctionQuickLocate_TEXT
                                                           AND z.Action_CODE IN (@Lc_ActionRequest_TEXT, @Lc_ActionProvide_TEXT))
                                                AND b.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS IntLocReqPendCp_CODE,
                                          CASE
                                           WHEN EXISTS (SELECT DISTINCT 1
                                                          FROM CTHB_Y1 z
                                                         WHERE z.Case_IDNO = b.Case_IDNO
                                                           AND z.Function_CODE = @Lc_FunctionQuickLocate_TEXT
                                                           AND z.Action_CODE IN (@Lc_ActionRequest_TEXT, @Lc_ActionProvide_TEXT))
                                                AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS IntLocReqPendNcp_CODE,                                          
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                            THEN CASE
												  WHEN b.StatusLocate_CODE = @Lc_StatusLocateL1_CODE THEN 1
												  ELSE 0
												 END												  
                                           ELSE 0
                                          END AS StatusLocate_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludeIrs_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS FederalTax_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludePas_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS PassportDenial_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludeFin_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS MultiStateFidm_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludeIns_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS Insurance_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludeVen_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS Vendor_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludeRet_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS Retirement_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.ExcludeSal_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS Salary_CODE,
                                          CASE
                                           WHEN b.InsResonable_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS InsAvailableReasonable_CODE,
                                          CASE
                                           WHEN b.InsResonable_CODE = @Lc_No_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS InsAvailableUnreason_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.Age_QNTY < 17
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS ChildLess17_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT, @Lc_RelationshipCaseCp_TEXT)
                                                AND b.FamilyViolenceIndc_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS FamilyViolence_INDC,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS ActiveDependent_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
                                            THEN CASE
												  WHEN b.MediumDisburse_CODE = @Lc_DisbMediumDirectDeposit_TEXT THEN 1
												  ELSE 0
												 END												  
                                           ELSE 0
                                          END AS MediumDisburse_CODE,
                                          CASE
                                           WHEN b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                            THEN 1
                                           ELSE @Ln_Zero_NUMB
                                          END AS DependentCount_QNTY,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                            THEN b.NcpNsfBalance_AMNT
                                           ELSE @Ln_Zero_NUMB
                                          END AS NcpNsfBalance_AMNT,
                                          CASE
                                           WHEN b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                                                AND b.NcpNsf_CODE = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS NcpNsf_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND EXISTS (SELECT DISTINCT 1
																FROM DEMO_Y1 g
															   WHERE g.MemberMci_IDNO = b.MemberMci_IDNO		            
																 AND g.Emancipation_DATE NOT IN (@Ld_Lowdate_DATE, @Ld_Highdate_DATE)
																 AND g.Emancipation_DATE <= @Ld_Run_DATE																 										 
																 AND EXISTS(SELECT DISTINCT 1 
																			  FROM OBLE_Y1 j 
																			 WHERE j.MemberMci_IDNO = b.MemberMci_IDNO)
																 AND EXISTS(SELECT DISTINCT 1 
																			  FROM OBLE_Y1 j 
																			 WHERE j.MemberMci_IDNO = b.MemberMci_IDNO 																	   
																			   AND j.Case_IDNO = b.Case_IDNO
																			   AND j.EndObligation_DATE <= @Ld_Run_DATE))
											THEN 1
										   ELSE 0
										  END AS DepOrderStsEmancipation_CODE,
                                          CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND EXISTS (SELECT DISTINCT 1 
															  FROM (SELECT  l.Case_IDNO,
																			x.MemberMci_IDNO,
																			(((ISNULL(l.OweTotNaa_AMNT, 0) - ISNULL(l.AppTotNaa_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotPaa_AMNT, 0) - ISNULL(l.AppTotPaa_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotTaa_AMNT, 0) - ISNULL(l.AppTotTaa_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotCaa_AMNT, 0) - ISNULL(l.AppTotCaa_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotUpa_AMNT, 0) - ISNULL(l.AppTotUpa_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotUda_AMNT, 0) - ISNULL(l.AppTotUda_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotIvef_AMNT, 0) - ISNULL(l.AppTotIvef_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotNffc_AMNT, 0) - ISNULL(l.AppTotNffc_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotNonIvd_AMNT, 0) - ISNULL(l.AppTotNonIvd_AMNT, 0))
																			 + 
																			(ISNULL(l.OweTotMedi_AMNT, 0) - ISNULL(l.AppTotMedi_AMNT, 0))
																			 - 
																			ISNULL(l.AppTotFuture_AMNT, 0)) - (l.OweTotCurSup_AMNT - l.AppTotCurSup_AMNT)) AS TotalArrears_AMNT 
																		FROM LSUP_Y1 l, OBLE_Y1 x
																	   WHERE l.Case_IDNO = b.Case_IDNO 									 
																		 AND l.SupportYearMonth_NUMB = (SELECT MAX (c.SupportYearMonth_NUMB)
																										  FROM LSUP_Y1 c
																										 WHERE c.Case_IDNO = l.Case_IDNO
																										   AND c.OrderSeq_NUMB = l.OrderSeq_NUMB
																										   AND c.ObligationSeq_NUMB = l.ObligationSeq_NUMB)
																		 AND l.EventGlobalSeq_NUMB = (SELECT MAX (d.EventGlobalSeq_NUMB)
																										FROM LSUP_Y1 d
																									   WHERE d.Case_IDNO = l.Case_IDNO
																										 AND d.OrderSeq_NUMB = l.OrderSeq_NUMB
																										 AND d.ObligationSeq_NUMB = l.ObligationSeq_NUMB
																										 AND d.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB)                                    
																		 AND x.TypeDebt_CODE IN (@Lc_ChildSupport_CODE, @Lc_MedicalSupport_CODE)
																		 AND @Ld_Run_DATE BETWEEN x.BeginObligation_DATE AND x.EndObligation_DATE
																		 AND x.EndValidity_DATE = @Ld_Highdate_DATE
																		 AND x.Case_IDNO = l.Case_IDNO
																		 AND x.OrderSeq_NUMB = l.OrderSeq_NUMB
																		 AND x.ObligationSeq_NUMB = l.ObligationSeq_NUMB
																		 AND x.MemberMci_IDNO = b.MemberMci_IDNO) y
															 WHERE y.MemberMci_IDNO = b.MemberMci_IDNO
															   AND y.Case_IDNO = b.Case_IDNO
															   AND y.TotalArrears_AMNT > 0)
											THEN 1
										   ELSE 0
										  END AS DepOrderStsCourtOrder_CODE,
										 CASE
                                           WHEN b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
                                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberA1_CODE
                                                AND EXISTS (SELECT DISTINCT 1
															  FROM (SELECT DISTINCT 
															               g.MemberMci_IDNO															                 
															          FROM DEMO_Y1 g
															         WHERE g.MemberMci_IDNO = b.MemberMci_IDNO																	
																	   AND (NOT EXISTS(SELECT DISTINCT 1 FROM SORD_Y1 x WHERE x.Case_IDNO = b.Case_IDNO)
																	        OR NOT EXISTS (SELECT DISTINCT 1 
																							 FROM OBLE_Y1 j 
																							WHERE j.MemberMci_IDNO = b.MemberMci_IDNO 																			  				  
																							  AND j.Case_IDNO = b.Case_IDNO
																							  AND j.EndObligation_DATE >= @Ld_Run_DATE))) x
															  WHERE x.MemberMci_IDNO = b.MemberMci_IDNO)
											THEN 1
										   ELSE 0
										  END DepOrderStsNotCrtOrd_CODE
                                     FROM BPMEMB_Y1 b) AS fci                                    
                            GROUP BY fci.Case_IDNO) AS mem
           ON a.Case_IDNO = mem.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  fci.SourceDoc_CODE
                             FROM (SELECT ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.TransactionEventSeq_NUMB ASC) AS rnm,
                                          b.Case_IDNO,
                                          b.SourceDoc_CODE
                                     FROM FDEM_Y1 b
                                    WHERE b.SourceDoc_CODE IN (SELECT z.Value_CODE
                                                                 FROM REFM_Y1 z
                                                                WHERE z.Table_ID = @Lc_TableCcrt_IDNO
                                                                  AND z.TableSub_ID = @Lc_TableSubFido_IDNO)
                                      AND b.EndValidity_DATE = @Ld_Highdate_DATE) AS fci
                            WHERE fci.rnm = 1
                          ) AS fdem
           ON a.Case_IDNO = fdem.Case_IDNO
          LEFT OUTER JOIN ((SELECT fci.Case_IDNO,								  
                                  CASE 
                                   WHEN SUBSTRING(fci.ExptdProcessAge_CODE, 1, 1) = @Lc_FsrtTable_CODE
                                    THEN CASE
                                          WHEN MAX(CAST(fci.ExptdProcessAge03Month_CODE AS NUMERIC(1))) = 1 
											THEN @Lc_Zero_TEXT
										  ELSE @Lc_ExptdProcessNotMet_CODE
										 END
                                   ELSE CASE 
										 WHEN MAX(CAST(fci.ExptdProcessAge03Month_CODE AS NUMERIC(1))) = 1
										  THEN @Lc_ExptdProcessMet_CODE
										 ELSE @Lc_ExptdProcessNotMet_CODE
										END 
                                  END AS ExptdProcessAge03Month_CODE,                                  
                                  CASE 
                                   WHEN SUBSTRING(fci.ExptdProcessAge_CODE, 1, 1) = @Lc_FsrtTable_CODE
                                    THEN CASE
                                          WHEN MAX(CAST(fci.ExptdProcessAge06Month_CODE AS NUMERIC(1))) = 1 
											THEN @Lc_Zero_TEXT
										  ELSE @Lc_ExptdProcessNotMet_CODE
										 END
                                   ELSE CASE 
										 WHEN MAX(CAST(fci.ExptdProcessAge06Month_CODE AS NUMERIC(1))) = 1
										  THEN @Lc_ExptdProcessMet_CODE
										 ELSE @Lc_ExptdProcessNotMet_CODE
										END 
                                  END AS ExptdProcessAge06Month_CODE,                                  
                                  CASE 
                                   WHEN SUBSTRING(fci.ExptdProcessAge_CODE, 1, 1) = @Lc_FsrtTable_CODE
                                    THEN CASE
                                          WHEN MAX(CAST(fci.ExptdProcessAge09Month_CODE AS NUMERIC(1))) = 1 
											THEN @Lc_Zero_TEXT
										  ELSE @Lc_ExptdProcessNotMet_CODE
										 END
                                   ELSE CASE 
										 WHEN MAX(CAST(fci.ExptdProcessAge09Month_CODE AS NUMERIC(1))) = 1
										  THEN @Lc_ExptdProcessMet_CODE
										 ELSE @Lc_ExptdProcessNotMet_CODE
										END 
                                  END AS ExptdProcessAge09Month_CODE,                                  
                                  CASE 
                                   WHEN SUBSTRING(fci.ExptdProcessAge_CODE, 1, 1) = @Lc_FsrtTable_CODE
                                    THEN CASE
                                          WHEN MAX(CAST(fci.ExptdProcessAge12Month_CODE AS NUMERIC(1))) = 1 
											THEN @Lc_Zero_TEXT
										  ELSE @Lc_ExptdProcessNotMet_CODE
										 END
                                   ELSE CASE 
										 WHEN MAX(CAST(fci.ExptdProcessAge12Month_CODE AS NUMERIC(1))) = 1
										  THEN @Lc_ExptdProcessMet_CODE
										 ELSE @Lc_ExptdProcessNotMet_CODE
										END 
                                  END AS ExptdProcessAge12Month_CODE,                                  
                                  CASE 
                                   WHEN SUBSTRING(fci.ExptdProcessAge_CODE, 1, 1) = @Lc_FsrtTable_CODE
                                    THEN CASE
                                          WHEN MAX(CAST(fci.ExptdProcessAgeOvr1Y1_CODE AS NUMERIC(1))) = 1 
											THEN @Lc_Zero_TEXT
										  ELSE @Lc_ExptdProcessNotMet_CODE
										 END
                                   ELSE CASE 
										 WHEN MAX(CAST(fci.ExptdProcessAgeOvr1Y1_CODE AS NUMERIC(1))) = 1
										  THEN @Lc_ExptdProcessMet_CODE
										 ELSE @Lc_ExptdProcessNotMet_CODE
										END 
                                  END AS ExptdProcessAgeOvr1Y1_CODE,
                                  fci.ExptdProcessAge_CODE
                             FROM (SELECT b.Case_IDNO,										   
                                          CASE
                                           WHEN CAST(SUBSTRING(b.ExptdProcessAge_CODE, 2, LEN(b.ExptdProcessAge_CODE)-1) AS NUMERIC) <= 3
                                            THEN 1
                                           ELSE 0
                                          END AS ExptdProcessAge03Month_CODE,
                                          CASE
                                           WHEN CAST(SUBSTRING(b.ExptdProcessAge_CODE, 2, LEN(b.ExptdProcessAge_CODE)-1) AS NUMERIC) <= 6
                                            THEN 1
                                           ELSE 0
                                          END AS ExptdProcessAge06Month_CODE,
                                          CASE
                                           WHEN CAST(SUBSTRING(b.ExptdProcessAge_CODE, 2, LEN(b.ExptdProcessAge_CODE)-1) AS NUMERIC) <= 9
                                            THEN 1
                                           ELSE 0
                                          END AS ExptdProcessAge09Month_CODE,
                                          CASE
                                           WHEN CAST(SUBSTRING(b.ExptdProcessAge_CODE, 2, LEN(b.ExptdProcessAge_CODE)-1) AS NUMERIC) <= 12
                                            THEN 1
                                           ELSE 0
                                          END AS ExptdProcessAge12Month_CODE,
                                          CASE
                                           WHEN CAST(SUBSTRING(b.ExptdProcessAge_CODE, 2, LEN(b.ExptdProcessAge_CODE)-1) AS NUMERIC) <= 36
                                            THEN 1
                                           ELSE 0
                                          END AS ExptdProcessAgeOvr1Y1_CODE,
                                          b.ExptdProcessAge_CODE
                                     FROM (SELECT xy.Case_IDNO,
                                                  xy.ExptdProcessAge_CODE
                                             FROM (SELECT e.Case_IDNO,
                                                          CASE
                                                           WHEN EXISTS (SELECT 1
                                                                          FROM SORD_Y1 z
                                                                         WHERE z.OrderEnt_DATE BETWEEN DATEADD(YEAR, -1, @Ld_Run_DATE) AND @Ld_Run_DATE
                                                                           AND z.Case_IDNO = e.Case_IDNO)
                                                            THEN (SELECT @Lc_SordTable_CODE + CAST(ABS(DATEDIFF(MM, 
																												(SELECT MIN(y.OrderIssued_DATE)
																												   FROM SORD_Y1 y
																												  WHERE y.Case_IDNO = s.Case_IDNO), 
																												MAX(x.Service_DATE))) AS VARCHAR)
																    FROM SORD_Y1 s,
																		 FSRT_Y1 x,
																		 CASE_Y1 c
																   WHERE s.Case_IDNO = e.Case_IDNO
																	 AND x.Case_IDNO = s.Case_IDNO
																	 AND s.Case_IDNO = c.Case_IDNO
																	 AND s.EndValidity_DATE = @Ld_Highdate_DATE
																	 AND s.OrderEnt_DATE BETWEEN DATEADD(YEAR, -1, @Ld_Run_DATE) AND @Ld_Run_DATE
																	 AND x.Service_DATE BETWEEN c.Opened_DATE AND (SELECT MIN(y.OrderIssued_DATE)
																													 FROM SORD_Y1 y
																													WHERE y.Case_IDNO = s.Case_IDNO)
																	 AND x.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE
																   GROUP BY s.Case_IDNO, s.OrderIssued_DATE)
														   ELSE CASE
																 WHEN EXISTS (SELECT 1 
																				FROM DMNR_Y1 n, CASE_Y1 c, DMJR_Y1 j, FSRT_Y1 x
																			   WHERE x.Case_IDNO = c.Case_IDNO
																			     AND j.Case_IDNO = x.Case_IDNO
																				 AND n.Case_IDNO = j.Case_IDNO
																				 AND j.Case_IDNO = e.Case_IDNO
																				 AND x.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE
																				 AND n.ActivityMajor_CODE = j.ActivityMajor_CODE
																				 AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
																				 AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
																				 AND ((j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
																					   AND n.Status_CODE = @Lc_StatusComplete_CODE
																					   AND n.ActivityMinor_CODE = @Lc_ActivityMinorAnddi_CODE
																					   AND n.ReasonStatus_CODE = @Lc_ReasonStatusDb_CODE
																					   AND n.MinorIntSeq_NUMB = (SELECT MAX(d.MinorIntSeq_NUMB)
																												   FROM DMNR_Y1 d
																												  WHERE d.Case_IDNO = j.Case_IDNO
																												    AND d.ActivityMajor_CODE = j.ActivityMajor_CODE
																												    AND d.OrderSeq_NUMB = j.OrderSeq_NUMB
																												    AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
																												    AND d.ActivityMinor_CODE = n.ActivityMinor_CODE)
																					   AND x.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE)
																			         OR (j.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
																				         AND j.Status_CODE = @Lc_StatusComplete_CODE
																				         AND n.ActivityMinor_CODE = @Lc_ActivityMinorRopdp_CODE
																				         AND x.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE)))
														   
																  THEN (SELECT @Lc_DmjrDmnrTable_CODE + CAST(ABS(DATEDIFF(MM, MAX(x.Service_DATE), n.Entered_DATE)) AS VARCHAR)
																		  FROM DMJR_Y1 j,
																			   DMNR_Y1 n,
																			   FSRT_Y1 x,
																			   CASE_Y1 c
																		 WHERE c.Case_IDNO = e.Case_IDNO
																		   AND x.Case_IDNO = c.Case_IDNO
																		   AND j.Case_IDNO = x.Case_IDNO
																		   AND n.Case_IDNO = j.Case_IDNO
																		   AND n.ActivityMajor_CODE = j.ActivityMajor_CODE
																		   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
																		   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
																		   AND ((j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
																				  AND n.Status_CODE = @Lc_StatusComplete_CODE
																				  AND n.ActivityMinor_CODE = @Lc_ActivityMinorAnddi_CODE
																				  AND n.ReasonStatus_CODE = @Lc_ReasonStatusDb_CODE
																				  AND n.MinorIntSeq_NUMB = (SELECT MAX(d.MinorIntSeq_NUMB)
																											  FROM DMNR_Y1 d
																											 WHERE d.Case_IDNO = j.Case_IDNO
																											   AND d.ActivityMajor_CODE = j.ActivityMajor_CODE
																											   AND d.OrderSeq_NUMB = j.OrderSeq_NUMB
																											   AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
																											   AND d.ActivityMinor_CODE = n.ActivityMinor_CODE)
																				  AND x.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE)
																				 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
																					 AND j.Status_CODE = @Lc_StatusComplete_CODE
																					 AND n.ActivityMinor_CODE = @Lc_ActivityMinorRopdp_CODE
																					 AND x.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE))
																		   AND x.Service_DATE BETWEEN c.Opened_DATE AND (SELECT MIN(y.Entered_DATE)
																														   FROM DMNR_Y1 y
																														  WHERE y.Case_IDNO = n.Case_IDNO
																															AND y.OrderSeq_NUMB = j.OrderSeq_NUMB
																															AND y.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
																															AND y.ActivityMajor_CODE = j.ActivityMajor_CODE
																															AND y.Status_CODE = j.Status_CODE
																															AND y.ActivityMinor_CODE = n.ActivityMinor_CODE)
																		GROUP BY n.Entered_DATE)
																 ELSE (SELECT @Lc_FsrtTable_CODE + CAST(ABS(DATEDIFF(MM, MAX(f.Service_DATE), @Ld_Run_DATE)) AS VARCHAR)
																		 FROM CASE_Y1 c, FSRT_Y1 f
																	    WHERE f.Case_IDNO = e.Case_IDNO
																	      AND c.Case_IDNO = f.Case_IDNO
																		  AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
																		  AND c.TypeCase_CODE <> @Lc_TypeCaseNonIVD_CODE
																		  AND f.ServiceResult_CODE = @Lc_ServiceResultPositive_CODE
																		  AND NOT EXISTS(SELECT 1 
																						   FROM SORD_Y1 s 
																						  WHERE s.Case_IDNO = f.Case_IDNO)
																		GROUP BY c.Opened_DATE)
															    END
														END AS ExptdProcessAge_CODE
													 FROM ENSD_Y1 e,
														  FSRT_Y1 f
													WHERE f.Case_IDNO = e.Case_IDNO
												    GROUP BY e.Case_IDNO) AS xy
											WHERE xy.ExptdProcessAge_CODE IS NOT NULL) b) AS fci
                            GROUP BY fci.Case_IDNO, fci.ExptdProcessAge_CODE)) AS age_process
           ON a.Case_IDNO = age_process.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  SUM(CAST(fci.DentalIns_QNTY AS NUMERIC(1))) AS DentalIns_QNTY,
                                  SUM(CAST(fci.MedicalIns_QNTY AS NUMERIC(1))) AS MedicalIns_QNTY,
                                  SUM(CAST(fci.VisionIns_QNTY AS NUMERIC(1))) AS VisionIns_QNTY,
                                  SUM(CAST(fci.MentalIns_QNTY AS NUMERIC(1))) AS MentalIns_QNTY,
                                  SUM(CAST(fci.PrescptIns_QNTY AS NUMERIC(1))) AS PrescptIns_QNTY
                             FROM (SELECT b.Case_IDNO,
                                          b.MemberMci_IDNO,
                                          c.OthpInsurance_IDNO,
                                          CASE
                                           WHEN c.DentalIns_INDC = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS DentalIns_QNTY,
                                          CASE
                                           WHEN c.MedicalIns_INDC = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS MedicalIns_QNTY,
                                          CASE
                                           WHEN c.VisionIns_INDC = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS VisionIns_QNTY,
                                          CASE
                                           WHEN c.MentalIns_INDC = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS MentalIns_QNTY,
                                          CASE
                                           WHEN c.PrescptIns_INDC = @Lc_Yes_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS PrescptIns_QNTY
                                     FROM BPMEMB_Y1 b,
                                          DINS_Y1 c
                                    WHERE b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                      AND @Ld_Run_DATE BETWEEN c.Begin_DATE AND c.End_DATE
                                      AND b.MemberMci_IDNO = c.ChildMCI_IDNO
                                      AND c.Status_CODE = @Lc_StatusCg_CODE
                                      AND c.EndValidity_DATE = @Ld_Highdate_DATE
                                      AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT) AS fci
                            GROUP BY fci.Case_IDNO) AS mem_dins
           ON a.Case_IDNO = mem_dins.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(fci.IwnStatus_CODE) AS IwnStatus_CODE
                             FROM (SELECT z.Case_IDNO,
                                          @Lc_Yes_TEXT AS IwnStatus_CODE
                                     FROM IWEM_Y1 z
                                    WHERE z.EndValidity_DATE = @Ld_Highdate_DATE
                                      AND z.IwnStatus_CODE = @Lc_IwnStatusActive_CODE) AS fci
                            GROUP BY fci.Case_IDNO) AS iwem
           ON a.Case_IDNO = iwem.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  fci.DisbursementHold_AMNT
                             FROM (SELECT z.Case_IDNO,
                                          z.OrderSeq_NUMB,
                                          z.ObligationSeq_NUMB,
                                          z.Transaction_DATE,
                                          z.Batch_DATE,
                                          z.SourceBatch_CODE,
                                          z.Batch_NUMB,
                                          z.SeqReceipt_NUMB,
                                          z.TypeHold_CODE,
                                          z.Transaction_AMNT,
                                          z.Unique_IDNO,
                                          z.ReasonStatus_CODE,
                                          z.PayorMCI_IDNO,
                                          z.Receipt_DATE,
                                          z.EventGlobalSupportSeq_NUMB,
                                          ROW_NUMBER() OVER(PARTITION BY z.Case_IDNO ORDER BY z.Case_IDNO DESC) AS rnm,
                                          SUM(z.Transaction_AMNT) OVER(PARTITION BY z.Case_IDNO) AS DisbursementHold_AMNT
                                     FROM BPDHLD_Y1 z) AS fci
                            WHERE fci.rnm = 1) AS dhld
           ON a.Case_IDNO = dhld.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  fci.CpRecoupBal_AMNT
                             FROM (SELECT z.Case_IDNO,
                                          z.CheckRecipient_IDNO,
                                          z.CheckRecipient_CODE,
                                          z.OrderSeq_NUMB,
                                          z.ObligationSeq_NUMB,
                                          z.Unique_IDNO,
                                          z.Transaction_DATE,
                                          ROW_NUMBER() OVER(PARTITION BY z.Case_IDNO ORDER BY z.Unique_IDNO DESC) AS rnm,
                                          SUM(z.CpRecoupBal_AMNT) AS CpRecoupBal_AMNT
                                     FROM BPPOFL_Y1 z
                                    GROUP BY z.Case_IDNO,
                                             z.CheckRecipient_IDNO,
                                             z.CheckRecipient_CODE,
                                             z.OrderSeq_NUMB,
                                             z.ObligationSeq_NUMB,
                                             z.Unique_IDNO,
                                             z.Transaction_DATE) AS fci
                            WHERE fci.rnm = 1) AS pofl
           ON a.Case_IDNO = pofl.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.ChildSupport_CODE AS NUMERIC(1))) AS ChildSupport_CODE,
                                  MAX(CAST(fci.MedicalSupport_CODE AS NUMERIC(1))) AS MedicalSupport_CODE,
                                  MAX(CAST(fci.SpousalSupport_CODE AS NUMERIC(1))) AS SpousalSupport_CODE,
                                  MAX(CAST(fci.GeneticTest_CODE AS NUMERIC(1))) AS GeneticTest_CODE,
                                  MAX(CAST(fci.NcpNsfFee_CODE AS NUMERIC(1))) AS NcpNsfFee_CODE,                                  
                                  MAX(CAST(fci.InterestOnChildSupport_CODE AS NUMERIC(1))) AS InterestOnChildSupport_CODE,
                                  MAX(CAST(fci.InterestOnMedicalSupp_CODE AS NUMERIC(1))) AS InterestOnMedicalSupp_CODE,
                                  MAX(CAST(fci.InterestOnSpousalSupp_CODE AS NUMERIC(1))) AS InterestOnSpousalSupp_CODE,
                                  MAX(CAST(fci.InterestOnCashMedical_CODE AS NUMERIC(1))) AS InterestOnCashMedical_CODE,
                                  MAX(CAST(fci.InterestOnAlimony_CODE AS NUMERIC(1))) AS InterestOnAlimony_CODE,
                                  SUM(fci.Ura_AMNT) AS Ura_AMNT
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeChildSupp_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS ChildSupport_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS MedicalSupport_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeSpousalSupp_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS SpousalSupport_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS GeneticTest_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeNcpNsfFee_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpNsfFee_CODE,                                          
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeIntChildSupp_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS InterestOnChildSupport_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeIntMedicalSupp_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS InterestOnMedicalSupp_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeIntSpousalSupp_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS InterestOnSpousalSupp_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeIntCashMedical_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS InterestOnCashMedical_CODE,
                                          CASE
                                           WHEN b.TypeDebt_CODE = @Lc_DebtTypeIntAlimony_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS InterestOnAlimony_CODE,
                                          b.Ura_AMNT
                                     FROM BPOBLE_Y1 b
                                  ) AS fci
                            GROUP BY fci.Case_IDNO) AS oble
           ON a.Case_IDNO = oble.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  SUM(fci.CpArrear_AMNT) AS CpArrear_AMNT,
                                  SUM(fci.IvaArrear_AMNT) AS IvaArrear_AMNT,
                                  SUM(fci.TotalOwed_AMNT) AS TotalOwed_AMNT,
                                  SUM(fci.TotalPaid_AMNT) AS TotalPaid_AMNT,
                                  SUM(fci.Mso_AMNT) AS Mso_AMNT
                             FROM (SELECT z.Case_IDNO,
                                          z.SupportYearMonth_NUMB,
                                          z.TanfArrear_AMNT,
                                          z.NonTanfArrear_AMNT,
                                          z.IvefArrear_AMNT,
                                          z.MedicAidArrear_AMNT,
                                          z.NonIvdArrear_AMNT,
                                          z.NffcArrear_AMNT,
                                          z.NffmArrear_AMNT,
                                          z.OrderSeq_NUMB,
                                          z.ObligationSeq_NUMB,
                                          z.TypeDebt_CODE,
                                          z.Distribute_DATE,
                                          z.Batch_DATE,
                                          z.SourceBatch_CODE,
                                          z.Batch_NUMB,
                                          z.SeqReceipt_NUMB,
                                          z.TypeRecord_CODE,
                                          z.EventGlobalSeq_NUMB,                                          
                                          z.CpArrear_AMNT,
                                          z.IvA1Arrear_AMNT AS IvaArrear_AMNT,
                                          z.TotalOwed_AMNT,
                                          z.TotalPaid_AMNT,
                                          z.OweTotCurSup_AMNT AS Mso_AMNT
                                     FROM BPLSUP_Y1 z) AS fci
                                    GROUP BY fci.Case_IDNO) AS lsup
           ON a.Case_IDNO = lsup.Case_IDNO           
          LEFT OUTER JOIN (SELECT fci.Case_IDNO, 
                                  fci.AppMtdCs_AMNT, 
                                  fci.AppMtdArrears_AMNT, 
                                  fci.DistributeHold_AMNT
						     FROM (SELECT z.Case_IDNO,
										  SUM(z.AppMtdCs_AMNT) OVER (PARTITION BY z.Case_IDNO, z.SupportYearMonth_NUMB) AS AppMtdCs_AMNT,
										  SUM((z.AppMtdIvaArr_AMNT + z.AppMtdCpArr_AMNT)) OVER (PARTITION BY z.Case_IDNO,z.SupportYearMonth_NUMB) AS AppMtdArrears_AMNT,
										  SUM(z.Held_AMNT) OVER (PARTITION BY z.Case_IDNO ) AS DistributeHold_AMNT,                                  
										  ROW_NUMBER () OVER (PARTITION BY z.Case_IDNO ORDER BY z.SupportYearMonth_NUMB DESC) rnm
								     FROM BPAPPL_Y1 z
								  ) AS fci  
							WHERE  rnm = 1) AS appl           
           ON a.Case_IDNO = appl.Case_IDNO
          LEFT OUTER JOIN (SELECT x.Case_IDNO, x.InsOrdered_CODE, MIN(x.DependentCoverage_CODE) AS DependentCoverage_CODE
							 FROM ( SELECT s.Case_IDNO, s.InsOrdered_CODE, c.MemberMci_IDNO, d.ChildMci_IDNO,
										   CASE WHEN s.CoverageMedical_CODE <= d.MedicalIns_CODE 
													 AND s.CoverageDrug_CODE <= d.PrescptIns_CODE
													 AND s.CoverageMental_CODE <= d.MentalIns_CODE
													 AND s.CoverageDental_CODE <= d.DentalIns_CODE
													 ANd s.CoverageVision_CODE <= d.VisionIns_CODE
													 AND s.CoverageOthers_CODE = d.DescriptionOthers_TEXT
												THEN 1
											 ELSE 0
											END DependentCoverage_CODE
									  FROM (SELECT b.Case_IDNO, b.InsOrdered_CODE, 
										      CAST((CASE WHEN b.CoverageMedical_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageMedical_CODE,
										      CAST((CASE WHEN b.CoverageDrug_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageDrug_CODE,
										      CAST((CASE WHEN b.CoverageMental_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageMental_CODE,
										      CAST((CASE WHEN b.CoverageDental_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageDental_CODE,
										      CAST((CASE WHEN b.CoverageVision_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageVision_CODE,
										      LTRIM(RTRIM(b.CoverageOthers_CODE)) AS CoverageOthers_CODE
										     FROM SORD_Y1 b
									        WHERE b.EndValidity_DATE = @Ld_Highdate_DATE
										      AND b.OrderEnd_DATE = @Ld_Highdate_DATE
										      AND b.InsOrdered_CODE <> @Lc_No_TEXT) AS S,
									       (SELECT m.MemberMci_IDNO, d.ChildMci_IDNO, 
										       CAST((CASE WHEN MAX(d.MedicalIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) MedicalIns_CODE,
										       CAST((CASE WHEN MAX(d.PrescptIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) PrescptIns_CODE,
										       CAST((CASE WHEN MAX(d.MentalIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) MentalIns_CODE,
										       CAST((CASE WHEN MAX(d.DentalIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) DentalIns_CODE,
										       CAST((CASE WHEN MAX(d.VisionIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) VisionIns_CODE,
										       LTRIM(RTRIM(d.DescriptionOthers_TEXT)) AS DescriptionOthers_TEXT
										      FROM MINS_Y1 m, DINS_Y1 d
									         WHERE m.MemberMci_IDNO = d.MemberMci_IDNO
										      AND m.PolicyInsNo_TEXT = d.PolicyInsNo_TEXT
									         GROUP BY m.MemberMci_IDNO, d.ChildMci_IDNO, d.DescriptionOthers_TEXT) AS D,
									        CMEM_Y1 C
									 WHERE s.Case_IDNO = c.Case_IDNO
									   AND c.MemberMci_IDNO = d.MemberMci_IDNO
									   AND s.InsOrdered_CODE = c.CaseRelationship_CODE
									   AND d.ChildMci_IDNO IN (SELECT f.MemberMci_IDNO 
																 FROM CMEM_Y1 f
																WHERE f.Case_IDNO = c.Case_IDNO
																 AND f.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
																 AND f.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)) AS x
							GROUP BY x.Case_IDNO, x.InsOrdered_CODE) AS minsNcpCp
           ON a.Case_IDNO = minsNcpCp.Case_IDNO
          LEFT OUTER JOIN (SELECT x.Case_IDNO, x.InsOrdered_CODE, MIN(x.DependentCoverage_CODE) AS DependentCoverage_CODE
							 FROM ( SELECT s.Case_IDNO, s.InsOrdered_CODE, c.MemberMci_IDNO, d.ChildMci_IDNO,
										   CASE WHEN s.CoverageMedical_CODE <= d.MedicalIns_CODE 
													 AND s.CoverageDrug_CODE <= d.PrescptIns_CODE
													 AND s.CoverageMental_CODE <= d.MentalIns_CODE
													 AND s.CoverageDental_CODE <= d.DentalIns_CODE
													 ANd s.CoverageVision_CODE <= d.VisionIns_CODE
													 AND s.CoverageOthers_CODE = d.DescriptionOthers_TEXT
												THEN 1
											 ELSE 0
											END DependentCoverage_CODE
									  FROM (SELECT b.Case_IDNO, b.InsOrdered_CODE, 
										      CAST((CASE WHEN b.CoverageMedical_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageMedical_CODE,
										      CAST((CASE WHEN b.CoverageDrug_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageDrug_CODE,
										      CAST((CASE WHEN b.CoverageMental_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageMental_CODE,
										      CAST((CASE WHEN b.CoverageDental_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageDental_CODE,
										      CAST((CASE WHEN b.CoverageVision_CODE IN (@Lc_No_TEXT, @Lc_Space_TEXT) THEN 0 ELSE 1 END) AS NUMERIC) CoverageVision_CODE,
										      LTRIM(RTRIM(b.CoverageOthers_CODE)) AS CoverageOthers_CODE
										     FROM SORD_Y1 b
									        WHERE b.EndValidity_DATE = @Ld_Highdate_DATE 
										      AND b.OrderEnd_DATE = @Ld_Highdate_DATE 
										      AND b.InsOrdered_CODE <> @Lc_No_TEXT) AS S,
									       (SELECT m.MemberMci_IDNO, d.ChildMci_IDNO, 
										       CAST((CASE WHEN MAX(d.MedicalIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) MedicalIns_CODE,
										       CAST((CASE WHEN MAX(d.PrescptIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) PrescptIns_CODE,
										       CAST((CASE WHEN MAX(d.MentalIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) MentalIns_CODE,
										       CAST((CASE WHEN MAX(d.DentalIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) DentalIns_CODE,
										       CAST((CASE WHEN MAX(d.VisionIns_INDC) = @Lc_Yes_TEXT THEN 1 ELSE 0 END) AS NUMERIC) VisionIns_CODE,
										       LTRIM(RTRIM(d.DescriptionOthers_TEXT)) AS DescriptionOthers_TEXT
										      FROM MINS_Y1 m, DINS_Y1 d
									         WHERE m.MemberMci_IDNO = d.MemberMci_IDNO
										      AND m.PolicyInsNo_TEXT = d.PolicyInsNo_TEXT
									         GROUP BY m.MemberMci_IDNO, d.ChildMci_IDNO, d.DescriptionOthers_TEXT) AS D,
									        CMEM_Y1 C
									 WHERE s.Case_IDNO = c.Case_IDNO
									   AND c.MemberMci_IDNO = d.MemberMci_IDNO
									   AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT, @Lc_RelationshipCaseCp_TEXT)
									   AND d.ChildMci_IDNO IN (SELECT f.MemberMci_IDNO 
																 FROM CMEM_Y1 f
																WHERE f.Case_IDNO = c.Case_IDNO
																 AND f.CaseRelationship_CODE = @Lc_RelationshipCaseDep_TEXT
																 AND f.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)) AS x
							GROUP BY x.Case_IDNO, x.InsOrdered_CODE) AS minsBoth
           ON a.Case_IDNO = minsBoth.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.CpProviding_CODE AS NUMERIC(1))) AS CpProviding_CODE,
                                  MAX(CAST(fci.NcpProviding_CODE AS NUMERIC(1))) AS NcpProviding_CODE,
                                  MAX(CAST(fci.OtherProviding_CODE AS NUMERIC(1))) AS OtherProviding_CODE
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.ProvidingMember_CODE = @Lc_ProvidingMemberC1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CpProviding_CODE,
                                          CASE
                                           WHEN b.ProvidingMember_CODE = @Lc_ProvidingMemberA1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS NcpProviding_CODE,
                                          CASE
                                           WHEN b.ProvidingMember_CODE = @Lc_ProvidingMemberT1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS OtherProviding_CODE
                                     FROM BPMEDM_Y1 b) AS fci
                            GROUP BY fci.Case_IDNO) AS medi
           ON a.Case_IDNO = medi.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.CdBankruptcy07_CODE AS NUMERIC(1))) AS CdBankruptcy07_CODE,
                                  MAX(CAST(fci.CdBankruptcy13_CODE AS NUMERIC(1))) AS CdBankruptcy13_CODE
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.Bankruptcy_CODE = @Lc_Bankruptcy07_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CdBankruptcy07_CODE,
                                          CASE
                                           WHEN b.Bankruptcy_CODE = @Lc_Bankruptcy13_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CdBankruptcy13_CODE
                                     FROM BPBKTY_Y1 b) AS fci
                            GROUP BY fci.Case_IDNO) AS bank_stg
           ON a.Case_IDNO = bank_stg.Case_IDNO
    WHERE (a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
            OR (a.StatusCase_CODE = @Lc_CaseStatusClosed_CODE
                AND a.StatusCurrent_DATE >= @Ld_Begin_DATE))
      AND a.County_IDNO <> @Lc_County000_TEXT
   OPTION (RECOMPILE);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT BPCAS3_Y1 FAILED';
     SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_JobStep4c_IDNO,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Li_RowCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   COMMIT TRANSACTION STEP4C;

   BEGIN TRANSACTION STEP4C;

   SET @Ls_Sql_TEXT = 'UPDATE BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_JobStep4c_IDNO + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_Success_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;	

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_JobStep4c_IDNO,
    @As_Process_NAME          = @Lc_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_Success_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;
    
   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4c_IDNO, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobStep4c_IDNO,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   COMMIT TRANSACTION STEP4C;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION STEP4C;
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
     @Ad_Run_DATE              = @Ld_Run_DATE,
     @Ad_Start_DATE            = @Ld_Start_DATE,
     @Ac_Job_ID                = @Lc_JobStep4c_IDNO,
     @As_Process_NAME          = @Lc_Process_NAME,
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
     @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
     @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
     @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT,
     @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
     @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
     @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   
   RAISERROR(@Ls_DescriptionError_TEXT, 16, 1);
  END CATCH
 END 

GO
