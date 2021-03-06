/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4B]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4B
Programmer Name	:	IMP Team.
Description		:	This process loads data from staging tables into BPCAS2_Y1.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4B]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_DaysInYear_NUMB                   NUMERIC(6, 2) = 365.25,
          @Li_RowCount_QNTY                     INT = 0,
          @Li_DaysInMonth_NUMB                  INT = 30,
          @Lc_Space_TEXT                        CHAR(1) = ' ',
          @Lc_CaseMemberActive_CODE             CHAR(1) = 'A',
          @Lc_CaseTypeNonIvd_CODE               CHAR(1) = 'H',
          @Lc_CaseTypePaTanf_CODE               CHAR(1) = 'A',
          @Lc_CaseTypeIveFosterCare_CODE        CHAR(1) = 'F',
          @Lc_CaseTypeNonFederalFosterCare_CODE CHAR(1) = 'J',
          @Lc_CaseRelationshipCp_CODE           CHAR(1) = 'C',
          @Lc_CaseRelationshipDep_CODE          CHAR(1) = 'D',
          @Lc_RelationshipCaseNcp_TEXT          CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT    CHAR(1) = 'P',
          @Lc_PrimarySsn_TEXT                   CHAR(1) = 'P',
          @Lc_AsstCaseCurrentAssitance_CODE     CHAR(1) = 'C',
          @Lc_AsstCaseFormerAssitance_CODE      CHAR(1) = 'F',
          @Lc_AsstCaseNeverAssitance_CODE       CHAR(1) = 'N',
          @Lc_No_TEXT                           CHAR(1) = 'N',
          @Lc_StatusAbnormalend_CODE            CHAR(1) = 'A',
          @Lc_VerificationStatusGood_CODE       CHAR(1) = 'Y',
          @Lc_VerificationStatusPending_CODE    CHAR(1) = 'P',
          @Lc_VerificationStatusBad_CODE        CHAR(1) = 'B',
          @Lc_Yes_TEXT                          CHAR(1) = 'Y',
          @Lc_Comma_TEXT                        CHAR(1) = ',',
          @Lc_CaseStatusOpen_CODE               CHAR(1) = 'O',
          @Lc_CaseStatusClosed_CODE             CHAR(1) = 'C',
          @Lc_Success_CODE                      CHAR(1) = 'S',
          @Lc_Failed_CODE                       CHAR(1) = 'F',
          @Lc_ActionB1_TEXT                     CHAR(1) = 'B',
          @Lc_ActionP1_TEXT                     CHAR(1) = 'P',
          @Lc_ActionY1_TEXT                     CHAR(1) = 'Y',
          @Lc_TypeM1_ADDR                       CHAR(1) = 'M',
          @Lc_TypeR1_ADDR                       CHAR(1) = 'R',
          @Lc_TypeC1_ADDR                       CHAR(1) = 'C',
          @Lc_StatusOrderActive_CODE            CHAR(1) = 'A',
          @Lc_StatusCaseMemberActive_CODE       CHAR(1) = 'A',
          @Lc_Adoption_CODE                     CHAR(1) = 'A',
          @Lc_ChildBornOfRapeIncest_CODE        CHAR(1) = 'R',
          @Lc_HarmToChild_CODE                  CHAR(1) = 'K',
          @Lc_HarmToCp_CODE                     CHAR(1) = 'C',
          @Lc_GoodFaithGranted_CODE             CHAR(1) = 'G',
          @Lc_Cooperation_CODE                  CHAR(1) = 'O',
          @Lc_FailedToProvideInformation_CODE   CHAR(1) = 'P',
          @Lc_FailedToAppear_CODE               CHAR(1) = 'H',
          @Lc_IncomeTypeActiveMilitary_TEXT     CHAR(2) = 'ML',
          @Lc_IncomeTypeMilitaryReserve_TEXT    CHAR(2) = 'MR',
          @Lc_DirectPaymentCredit_TEXT          CHAR(2) = 'CD',
          @Lc_County000_TEXT                    CHAR(3) = '000',
          @Lc_MajorActivityCrpt_CODE            CHAR(4) = 'CRPT',
          @Lc_MajorActivityCsln_CODE            CHAR(4) = 'CSLN',
          @Lc_MajorActivityFidm_CODE            CHAR(4) = 'FIDM',
          @Lc_MajorActivityImiw_CODE            CHAR(4) = 'IMIW',
          @Lc_MajorActivityNmsn_CODE            CHAR(4) = 'NMSN',
          @Lc_MajorActivityPsoc_CODE            CHAR(4) = 'PSOC',
          @Lc_MajorActivityAren_CODE            CHAR(4) = 'AREN',
          @Lc_MajorActivityLint_CODE            CHAR(4) = 'LINT',
          @Lc_MajorActivityLsnr_CODE            CHAR(4) = 'LSNR',
          @Lc_MajorActivityCrim_CODE            CHAR(4) = 'CRIM',
          @Lc_MajorActivityLien_CODE            CHAR(4) = 'LIEN',
          @Lc_MajorActivitySeqo_CODE            CHAR(4) = 'SEQO',
          @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                    CHAR(5) = 'E0944',
          @Lc_JobStep4b_IDNO                    CHAR(7) = 'DEB1370',
          @Lc_Successful_TEXT                   CHAR(10) = 'SUCCESSFUL',
          @Lc_Process_NAME                      CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME                    VARCHAR(50) = 'SP_PROCESS_BIDAILYSTEP4B',
          @Ld_Highdate_DATE                     DATE = '12/31/9999',
          @Ld_Lowdate_DATE                      DATE = '01/01/0001',
          @Ld_Jan1900_DATE                      DATE = '01/01/1900';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ld_Maxdate_DATE                DATE,
          @Ld_Begin_DATE                  DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4b_IDNO, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobStep4b_IDNO,
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

   SELECT @Ld_Maxdate_DATE = MAX(a.End_DATE),
          @Ld_Begin_DATE = MIN(a.Begin_DATE)
     FROM BPDATE_Y1 a;

   SET @Ls_DescriptionError_TEXT = 'STEP:1 UPDATING BPCAS2_Y1';
   SET @Ls_Sql_TEXT = 'DELETE FROM BPCAS2_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4b_IDNO, '');

   DELETE FROM BPCAS2_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPCAS2_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4b_IDNO, '');

   BEGIN TRANSACTION STEP4B;

   INSERT BPCAS2_Y1
          (Case_IDNO,
           County_IDNO,
           Opened_DATE,
           Create_DATE,
           StatusCase_CODE,
           AsstCase_CODE,
           CaseCategory_CODE,
           TypeCase_CODE,
           FamilyViolence_INDC,
           MemberMci_IDNO,
           First_NAME,
           Last_NAME,
           Birth_DATE,
           AgeNcp_QNTY,
           Office_IDNO,
           Arrear_AMNT,
           DurationNoAddr_QNTY,
           DurationNoEmpl_QNTY,
           AgeCase_QNTY,
           CpAddress_CODE,
           StatusOrder_CODE,
           Worker_ID,
           RespondInit_CODE,
           CpEmployment_CODE,
           Delinquency_CODE,
           CpMci_IDNO,
           FirstCp_NAME,
           LastCp_NAME,
           GoodCause_CODE,
           DurationNoDob_QNTY,
           DurationNoSsn_QNTY,
           NcpAddress_CODE,
           NcpEmployment_CODE,
           NcpResiAddress_CODE,
           CpResiAddress_CODE,
           NonCoop_CODE,
           Restricted_CODE,
           AppRetd_DATE,
           SourceRfrl_CODE,
           TransactionEventSeq_NUMB,
           RsnStatusCase_CODE,
           OrderEffective_DATE,
           OrderIssued_DATE,
           Payback_AMNT,
           FreqPayback_CODE,
           CurrentExemptions_TEXT,
           CaseWelfareIvae_ID,
           TypeWelfare_CODE,
           Complaint_DATE,
           File_ID,
           CpCourtAddrIndc_CODE,
           CpMailingAddrGood_CODE,
           CpMailingAddrBad_CODE,
           CpMailingAddrPending_CODE,
           CpResidentialAddrGood_CODE,
           CpResidentialAddrBad_CODE,
           CpResidentialAddrPend_CODE,
           CpEmploymentAddrGood_CODE,
           CpEmploymentAddrBad_CODE,
           CpEmploymentAddrPend_CODE,
           NcpCourtAddrIndc_CODE,
           NcpMailingAddrGood_CODE,
           NcpMailingAddrBad_CODE,
           NcpMailingAddrPending_CODE,
           NcpResidentialAddrGood_CODE,
           NcpResidentialAddrBad_CODE,
           NcpResidentialAddrPend_CODE,
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
           RangeAgeCase_QNTY,
           RangeArrear_AMNT,
           County_NAME,
           Workers_NAME,
           InsuranceNotAvailable_CODE,
           ApplicationFee_CODE,
           FeePaid_DATE,
           InstTypeCp_CODE,
           InstTypeNcp_CODE,
           InstStatusCp_CODE,
           InstStatusNcp_CODE,
           InstStatusCp_DATE,
           InstStatusNcp_DATE,
           FileType_CODE,
           Fips_CODE,
           TanfCounty_TEXT,
           VenueCounty_IDNO,
           DescriptionCompliance_TEXT,
           StatusRpp_CODE,
           StatusRpp_DATE)        
   SELECT DISTINCT
          a.Case_IDNO,
          a.County_IDNO,
          c.Opened_DATE,
          c.Opened_DATE AS Create_DATE,
          a.StatusCase_CODE,
          CASE
           WHEN c.TypeCase_CODE = @Lc_CaseTypeNonIvd_CODE
            THEN @Lc_Space_TEXT
           WHEN c.TypeCase_CODE IN (@Lc_CaseTypePaTanf_CODE, @Lc_CaseTypeIveFosterCare_CODE, @Lc_CaseTypeNonFederalFosterCare_CODE)
            THEN @Lc_AsstCaseCurrentAssitance_CODE
           WHEN EXISTS(SELECT DISTINCT
                              1
                         FROM MHIS_Y1 z
                        WHERE z.Case_IDNO = c.Case_IDNO
                          AND z.TypeWelfare_CODE IN (@Lc_CaseTypePaTanf_CODE, @Lc_CaseTypeIveFosterCare_CODE, @Lc_CaseTypeNonFederalFosterCare_CODE)
                          AND z.MemberMci_IDNO IN (SELECT MemberMci_IDNO
                                                     FROM CMEM_Y1 y
                                                    WHERE y.Case_IDNO = c.Case_IDNO
                                                      AND y.CaseRelationship_CODE IN (@Lc_CaseRelationshipDep_CODE, @Lc_CaseRelationshipCp_CODE)
                                                      AND y.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE))
            THEN @Lc_AsstCaseFormerAssitance_CODE
           ELSE @Lc_AsstCaseNeverAssitance_CODE
          END AS AsstCase_CODE,
          a.CaseCategory_CODE,
          a.TypeCase_CODE,
          ISNULL((SELECT z.FamilyViolence_INDC
                    FROM CMEM_Y1 z
                   WHERE z.MemberMci_IDNO = a.MemberMci_IDNO
                     AND z.Case_IDNO = a.Case_IDNO
                     AND z.TransactionEventSeq_NUMB IN (SELECT MAX(TransactionEventSeq_NUMB)
                                                          FROM CMEM_Y1 b
                                                         WHERE b.MemberMci_IDNO = z.MemberMci_IDNO
                                                           AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                                           AND b.Case_IDNO = z.Case_IDNO)), @Lc_No_TEXT) AS FamilyViolence_INDC,
          a.MemberMci_IDNO,
          a.First_NAME,
          a.Last_NAME,
          a.Birth_DATE,
          CASE
           WHEN a.Birth_DATE IN (@Ld_Lowdate_DATE, @Ld_Highdate_DATE)
            THEN 0
           WHEN a.Birth_DATE IS NULL
            THEN 0
           ELSE CAST(ABS(DATEDIFF(DD, a.Birth_DATE, @Ld_Run_DATE) / @Ln_DaysInyear_NUMB) AS NUMERIC)
          END AS AgeNcp_QNTY,
          a.County_IDNO AS Office_IDNO,
          a.Arrears_AMNT AS Arrear_AMNT,
          ISNULL(CASE
                  WHEN ahis.MemberMci_IDNO IS NOT NULL
                   THEN
                   CASE
                    WHEN ahis.DurationNoAddr_QNTY <= 0
                     THEN 0
                    WHEN ahis.DurationNoAddr_QNTY > 12
                     THEN 13
                    ELSE CAST(ahis.DurationNoAddr_QNTY AS NUMERIC(2))
                   END
                  ELSE
                   CASE
                    WHEN ahis.DurationNoAddr_QNTY > 12
                     THEN 13
                    ELSE CAST(ahis.DurationNoAddr_QNTY AS NUMERIC(2))
                   END
                 END, -1) AS DurationNoAddr_QNTY,
          ISNULL(CASE
                  WHEN ehis.MemberMci_IDNO IS NOT NULL
                   THEN
                   CASE
                    WHEN ehis.DurationNoEmpl_QNTY <= 0
                     THEN 0
                    WHEN ehis.DurationNoEmpl_QNTY > 12
                     THEN 13
                    ELSE CAST(ehis.DurationNoEmpl_QNTY AS NUMERIC(2))
                   END
                  ELSE
                   CASE
                    WHEN (ABS(DATEDIFF(DD, c.Opened_DATE, @Ld_Run_DATE)) / @Li_DaysInMonth_NUMB) <= 0
                     THEN 0
                    WHEN (ABS(DATEDIFF(DD, c.Opened_DATE, @Ld_Run_DATE)) / @Li_DaysInMonth_NUMB) > 12
                     THEN 13
                    ELSE (ABS(DATEDIFF(DD, c.Opened_DATE, @Ld_Run_DATE)) / @Li_DaysInMonth_NUMB)
                   END
                 END, -1) AS DurationNoEmpl_QNTY,
          ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) AS AgeCase_QNTY,
          a.VerCpAddrExist_INDC AS CpAddress_CODE,
          @Lc_StatusOrderActive_CODE AS StatusOrder_CODE,
          c.Worker_ID AS Worker_ID,
          a.RespondInit_CODE,
          ISNULL(ehis_cp.CpEmployment_CODE, @Lc_Space_TEXT) AS CpEmployment_CODE,
          @Lc_No_TEXT AS Delinquency_CODE,
          a.CpMci_IDNO,
          a.FirstCp_NAME,
          a.LastCp_NAME,
          CASE
           WHEN c.NonCoop_CODE IN (@Lc_Cooperation_CODE, @Lc_FailedToProvideInformation_CODE, @Lc_FailedToAppear_CODE, @Lc_GoodFaithGranted_CODE)
            THEN c.NonCoop_CODE
           WHEN c.GoodCause_CODE IN (@Lc_Adoption_CODE, @Lc_ChildBornOfRapeIncest_CODE, @Lc_HarmToChild_CODE, @Lc_HarmToCp_CODE)
            THEN c.GoodCause_CODE
           ELSE @Lc_Space_TEXT
          END AS GoodCause_CODE,
          ISNULL(CASE
                  WHEN ((ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) = @Ln_Zero_NUMB)
                        AND (a.Birth_DATE IN (@Ld_Highdate_DATE, @Ld_Jan1900_DATE, @Ld_Lowdate_DATE)))
                   THEN 1
                  ELSE
                   CASE
                    WHEN ((ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) > 12)
                          AND (a.Birth_DATE IN (@Ld_Highdate_DATE, @Ld_Jan1900_DATE, @Ld_Lowdate_DATE)))
                     THEN 13
                    ELSE
                     CASE
                      WHEN a.Birth_DATE IN (@Ld_Highdate_DATE, @Ld_Jan1900_DATE, @Ld_Lowdate_DATE)
                       THEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB)
                     END
                   END
                 END, -1) AS DurationNoDob_QNTY,
          ISNULL(CASE
                  WHEN a.MemberSsn_NUMB = @Ln_Zero_NUMB
                   THEN
                   CASE
                    WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) = @Ln_Zero_NUMB
                     THEN 1
                    ELSE
                     CASE
                      WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) > 12
                       THEN 13
                      ELSE ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB)
                     END
                   END
                 END, -1) AS DurationNoSsn_QNTY,
          ISNULL(CASE
                  WHEN ahis_stg.NcpMailingAddrGood_CODE = 1
                   THEN @Lc_VerificationStatusGood_CODE
                  WHEN ahis_stg.NcpMailingAddrPending_CODE = 1
                   THEN @Lc_VerificationStatusPending_CODE
                  WHEN ahis_stg.NcpMailingAddrBad_CODE = 1
                   THEN @Lc_VerificationStatusBad_CODE
                 END, @Lc_No_TEXT) AS NcpAddress_CODE,
          ISNULL((SELECT DISTINCT
                         1
                    FROM EHIS_Y1 y
                   WHERE y.MemberMci_IDNO = a.MemberMci_IDNO
                     AND y.TypeIncome_CODE IN (@Lc_IncomeTypeActiveMilitary_TEXT, @Lc_IncomeTypeMilitaryReserve_TEXT)), 0) AS NcpEmployment_CODE,
          @Lc_No_TEXT AS NcpResiAddress_CODE,
          @Lc_No_TEXT AS CpResiAddress_CODE,
          c.NonCoop_CODE,
          c.Restricted_INDC AS Restricted_CODE,
          c.AppRetd_DATE,
          c.SourceRfrl_CODE,
          c.TransactionEventSeq_NUMB,
          a.RsnStatusCase_CODE,
          a.OrderEffective_DATE,
          a.OrderIssued_DATE,
          a.ExpectToPay_AMNT AS Payback_AMNT,
          a.FreqPayback_CODE,
          ISNULL(RTRIM(ISNULL(CASE
                               WHEN a.ArenExempt_INDC = @Lc_Yes_TEXT
                                THEN ISNULL(@Lc_MajorActivityAren_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                              END, '') + ISNULL(CASE
                                                 WHEN a.CrptExempt_INDC = @Lc_Yes_TEXT
                                                  THEN ISNULL(@Lc_MajorActivityCrpt_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                END, '') + ISNULL(CASE
                                                                   WHEN a.CslnExempt_INDC = @Lc_Yes_TEXT
                                                                    THEN ISNULL(@Lc_MajorActivityCsln_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                  END, '') + ISNULL(CASE
                                                                                     WHEN a.FidmExempt_INDC = @Lc_Yes_TEXT
                                                                                      THEN ISNULL(@Lc_MajorActivityFidm_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                    END, '') + ISNULL(CASE
                                                                                                       WHEN a.ImiwExempt_INDC = @Lc_Yes_TEXT
                                                                                                        THEN ISNULL(@Lc_MajorActivityImiw_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                      END, '') + ISNULL(CASE
                                                                                                                         WHEN a.LintExempt_INDC = @Lc_Yes_TEXT
                                                                                                                          THEN ISNULL(@Lc_MajorActivityLint_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                        END, '') + ISNULL(CASE
                                                                                                                                           WHEN a.LsnrExempt_INDC = @Lc_Yes_TEXT
                                                                                                                                            THEN ISNULL(@Lc_MajorActivityLsnr_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                                          END, '') + ISNULL(CASE
                                                                                                                                                             WHEN a.NmsnExempt_INDC = @Lc_Yes_TEXT
                                                                                                                                                              THEN ISNULL(@Lc_MajorActivityNmsn_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                                                            END, '') + ISNULL(CASE
                                                                                                                                                                               WHEN a.PsocExempt_INDC = @Lc_Yes_TEXT
                                                                                                                                                                                THEN ISNULL(@Lc_MajorActivityPsoc_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                                                                              END, '') + ISNULL(CASE
                                                                                                                                                                                                 WHEN a.CrimExempt_INDC = @Lc_Yes_TEXT
                                                                                                                                                                                                  THEN ISNULL(@Lc_MajorActivityCrim_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                                                                                                END, '') + ISNULL(CASE
                                                                                                                                                                                                                   WHEN a.LienExempt_INDC = @Lc_Yes_TEXT
                                                                                                                                                                                                                    THEN ISNULL(@Lc_MajorActivityLien_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                                                                                                                  END, '') + ISNULL(CASE
                                                                                                                                                                                                                                     WHEN a.SeqoExempt_INDC = @Lc_Yes_TEXT
                                                                                                                                                                                                                                      THEN ISNULL(@Lc_MajorActivitySeqo_CODE, '') + ISNULL(@Lc_Comma_TEXT, '')
                                                                                                                                                                                                                                    END, '')), @Lc_Space_TEXT) AS CurrentExemptions_TEXT,
          a.CaseWelfare_IDNO AS CaseWelfareIvae_ID,
          a.TypeCase_CODE AS TypeWelfare_CODE,
          ISNULL(c.AppSigned_DATE, NULL) AS Complaint_DATE,
          a.File_ID,
          ISNULL(ahis_cp.CpCourtAddrIndc_CODE, @Ln_Zero_NUMB) AS CpCourtAddrIndc_CODE,
          ISNULL(ahis_cp.CpMailingAddrGood_CODE, @Ln_Zero_NUMB) AS CpMailingAddrGood_CODE,
          ISNULL(ahis_cp.CpMailingAddrBad_CODE, @Ln_Zero_NUMB) AS CpMailingAddrBad_CODE,
          ISNULL(ahis_cp.CpMailingAddrPending_CODE, @Ln_Zero_NUMB) AS CpMailingAddrPending_CODE,
          ISNULL(ahis_cp.CpResidentialAddrGood_CODE, @Ln_Zero_NUMB) AS CpResidentialAddrGood_CODE,
          ISNULL(ahis_cp.CpResidentialAddrBad_CODE, @Ln_Zero_NUMB) AS CpResidentialAddrBad_CODE,
          ISNULL(ahis_cp.CpResidentialAddrPend_CODE, @Ln_Zero_NUMB) AS CpResidentialAddrPend_CODE,
          ISNULL(ehis_cp.CpEmploymentAddrGood_CODE, @Ln_Zero_NUMB) AS CpEmploymentAddrGood_CODE,
          ISNULL(ehis_cp.CpEmploymentAddrBad_CODE, @Ln_Zero_NUMB) AS CpEmploymentAddrBad_CODE,
          ISNULL(ehis_cp.CpEmploymentAddrPend_CODE, @Ln_Zero_NUMB) AS CpEmploymentAddrPend_CODE,
          ISNULL(ahis_stg.NcpCourtAddrIndc_CODE, @Ln_Zero_NUMB) AS NcpCourtAddrIndc_CODE,
          ISNULL(ahis_stg.NcpMailingAddrGood_CODE, @Ln_Zero_NUMB) AS NcpMailingAddrGood_CODE,
          ISNULL(ahis_stg.NcpMailingAddrBad_CODE, @Ln_Zero_NUMB) AS NcpMailingAddrBad_CODE,
          ISNULL(ahis_stg.NcpMailingAddrPending_CODE, @Ln_Zero_NUMB) AS NcpMailingAddrPending_CODE,
          ISNULL(ahis_stg.NcpResidentialAddrGood_CODE, @Ln_Zero_NUMB) AS NcpResidentialAddrGood_CODE,
          ISNULL(ahis_stg.NcpResidentialAddrBad_CODE, @Ln_Zero_NUMB) AS NcpResidentialAddrBad_CODE,
          ISNULL(ahis_stg.NcpResidentialAddrPend_CODE, @Ln_Zero_NUMB) AS NcpResidentialAddrPend_CODE,
          CASE a.ArenExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptAren_CODE,
          CASE a.CrptExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptCrpt_CODE,
          CASE a.CslnExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptCsln_CODE,
          CASE a.FidmExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptFidm_CODE,
          CASE a.ImiwExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptImiw_CODE,
          CASE a.LintExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptLint_CODE,
          CASE a.LsnrExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptLsnr_CODE,
          CASE a.NmsnExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptNmsn_CODE,
          CASE a.PsocExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptPsoc_CODE,
          CASE a.CrimExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptCrim_CODE,
          CASE a.LienExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptLien_CODE,
          CASE a.SeqoExempt_INDC
           WHEN @Lc_Yes_TEXT
            THEN 1
           ELSE @Ln_Zero_NUMB
          END AS EnforcementExemptSeqo_CODE,
          CASE
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) BETWEEN @Ln_Zero_NUMB AND 3
            THEN 1
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) BETWEEN 4 AND 6
            THEN 2
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) BETWEEN 7 AND 9
            THEN 3
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) BETWEEN 10 AND 12
            THEN 4
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) BETWEEN 13 AND 24
            THEN 5
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) BETWEEN 25 AND 36
            THEN 6
           WHEN ABS(DATEDIFF(DD, @Ld_Run_DATE, c.Opened_DATE) / @Li_DaysInMonth_NUMB) > 36
            THEN 7
          END AS RangeAgeCase_QNTY,
          CAST(CASE
                WHEN a.ArrearsReg_AMNT <= @Ln_Zero_NUMB
                 THEN 1
                WHEN a.ArrearsReg_AMNT > @Ln_Zero_NUMB
                     AND a.ArrearsReg_AMNT <= 500
                 THEN 2
                WHEN a.ArrearsReg_AMNT > 500
                     AND a.ArrearsReg_AMNT <= 1000
                 THEN 3
                WHEN a.ArrearsReg_AMNT > 1000
                     AND a.ArrearsReg_AMNT <= 2500
                 THEN 4
                WHEN a.ArrearsReg_AMNT > 2500
                     AND a.ArrearsReg_AMNT <= 5000
                 THEN 5
                WHEN a.ArrearsReg_AMNT > 5000
                     AND a.ArrearsReg_AMNT <= 7500
                 THEN 6
                WHEN a.ArrearsReg_AMNT > 7500
                     AND a.ArrearsReg_AMNT <= 10000
                 THEN 7
                WHEN a.ArrearsReg_AMNT > 10000
                     AND a.ArrearsReg_AMNT <= 25000
                 THEN 8
                WHEN a.ArrearsReg_AMNT > 25000
                     AND a.ArrearsReg_AMNT <= 50000
                 THEN 9
                WHEN a.ArrearsReg_AMNT > 50000
                 THEN 10
               END AS NUMERIC(11)) AS RangeArrear_AMNT,
          (SELECT z.County_NAME
             FROM BCONT_Y1 z
            WHERE z.County_IDNO = a.County_IDNO) AS County_NAME,
          a.WorkerCase_ID AS Workers_NAME,
          ISNULL(ehis.InsuranceNotAvailable_CODE, @Ln_Zero_NUMB) AS InsuranceNotAvailable_CODE,
          @Ln_Zero_NUMB AS ApplicationFee_CODE,
          @Lc_Space_TEXT AS FeePaid_DATE,
          @Ln_Zero_NUMB AS InstTypeCp_CODE,
          @Ln_Zero_NUMB AS InstTypeNcp_CODE,
          @Ln_Zero_NUMB AS InstStatusCp_CODE,
          @Ln_Zero_NUMB AS InstStatusNcp_CODE,
          @Lc_Space_TEXT AS InstStatusCp_DATE,
          @Lc_Space_TEXT AS InstStatusNcp_DATE,
          @Ln_Zero_NUMB AS FileType_CODE,
          @Ln_Zero_NUMB AS Fips_CODE,
          @Lc_Space_TEXT AS TanfCounty_TEXT,
          @Ln_Zero_NUMB AS VenueCounty_IDNO,
          @Lc_Space_TEXT AS DescriptionCompliance_TEXT,
          @Ln_Zero_NUMB AS StatusRpp_CODE,
          @Lc_Space_TEXT AS StatusRpp_DATE
     FROM (SELECT DISTINCT
                  c.MemberMci_IDNO,
                  ISNULL(CASE 
				          WHEN EXISTS (SELECT 1
				  			             FROM MSSN_Y1 x 
								        WHERE x.MemberMci_IDNO = d.MemberMci_IDNO
								          AND x.TypePrimary_CODE = @Lc_PrimarySsn_TEXT
								          AND x.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
								          AND x.EndValidity_DATE = @Ld_Highdate_DATE)
					       THEN (SELECT MemberSsn_NUMB
							       FROM MSSN_Y1 x 
						          WHERE x.MemberMci_IDNO = d.MemberMci_IDNO
						            AND x.TypePrimary_CODE = @Lc_PrimarySsn_TEXT
							        AND x.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
							        AND x.EndValidity_DATE = @Ld_Highdate_DATE)
				          ELSE CASE
								WHEN EXISTS (SELECT 1
											   FROM MSSN_Y1 m
											  WHERE m.MemberMci_IDNO = c.MemberMci_IDNO
                                                AND m.TypePrimary_CODE = @Lc_PrimarySsn_TEXT
                                                AND m.Enumeration_CODE = @Lc_VerificationStatusPending_CODE 
                                                AND m.EndValidity_DATE = @Ld_Highdate_DATE)                            
							     THEN (SELECT MAX(m.MemberSsn_NUMB) AS MemberSsn_NUMB
                                         FROM MSSN_Y1 m
                                        WHERE m.MemberMci_IDNO = c.MemberMci_IDNO
                                          AND m.TypePrimary_CODE = @Lc_PrimarySsn_TEXT
                                          AND m.Enumeration_CODE = @Lc_VerificationStatusPending_CODE 
                                          AND m.EndValidity_DATE = @Ld_Highdate_DATE
                                          AND m.TransactionEventSeq_NUMB = (SELECT MAX(x.TransactionEventSeq_NUMB)
                                                                              FROM MSSN_Y1 x
                                                                             WHERE x.MemberMci_IDNO = m.MemberMci_IDNO
                                                                               AND x.TypePrimary_CODE = @Lc_PrimarySsn_TEXT
                                                                               AND x.Enumeration_CODE = @Lc_VerificationStatusPending_CODE
                                                                               AND x.EndValidity_DATE = @Ld_Highdate_DATE))
								ELSE @Ln_Zero_NUMB
							  END
                         END, @Ln_Zero_NUMB) AS MemberSsn_NUMB,
                  d.First_NAME,
                  d.Last_NAME,
                  d.Birth_DATE,
                  e.*
             FROM ENSD_Y1 e,
                  CMEM_Y1 c,                  
                  DEMO_Y1 d
            WHERE e.Case_IDNO = c.Case_IDNO              
              AND d.MemberMci_IDNO = c.MemberMci_IDNO
              AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
              AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE) AS a
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  fci.EndOfMonth_DATE,
                                  CAST(ABS(DATEDIFF(MM, fci.EndOfMonth_DATE, @Ld_Maxdate_DATE)) AS NUMERIC(9)) AS DeliquencyPeriod_NUMB,
                                  fci.Collection_AMNT,
                                  fci.DirectPay_AMNT
                             FROM (SELECT z.Case_IDNO,
                                          z.EndOfMonth_DATE,
                                          z.Receipt_AMNT,
                                          z.OrderSeq_NUMB,
                                          z.ObligationSeq_NUMB,
                                          z.Batch_DATE,
                                          z.SourceBatch_CODE,
                                          z.Batch_NUMB,
                                          z.SeqReceipt_NUMB,
                                          z.SourceReceipt_CODE,
                                          z.PayorMCI_IDNO,
                                          z.ToDistribute_AMNT,
                                          z.StatusReceipt_CODE,
                                          z.Receipt_DATE,
                                          ROW_NUMBER() OVER(PARTITION BY z.Case_IDNO ORDER BY z.EndOfMonth_DATE DESC) AS rnm,
                                          SUM(z.Receipt_AMNT) OVER(PARTITION BY z.Case_IDNO, z.EndOfMonth_DATE) AS Collection_AMNT,
                                          (SUM(CASE
                                                WHEN z.SourceReceipt_CODE = @Lc_DirectPaymentCredit_TEXT
                                                 THEN z.ToDistribute_AMNT
                                                ELSE 0
                                               END) OVER (PARTITION BY Case_IDNO)) AS DirectPay_AMNT
                                     FROM BPRCTH_Y1 z) AS fci
                            WHERE fci.rnm = 1) AS r
           ON a.Case_IDNO = r.Case_IDNO
          LEFT OUTER JOIN (SELECT b.MemberMci_IDNO,
                                  MAX(b.End_DATE) AS End_DATE,
                                  ABS(DATEDIFF(DD, @Ld_Run_DATE, MAX(b.Begin_DATE)) / 30) AS DurationNoAddr_QNTY
                             FROM AHIS_Y1 b
                            WHERE b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                              AND b.Status_CODE IN (@Lc_VerificationStatusBad_CODE, @Lc_VerificationStatusPending_CODE)
                              AND @Ld_Run_DATE BETWEEN b.Begin_DATE AND b.End_DATE
                              AND b.MemberMci_IDNO NOT IN (SELECT c.MemberMci_IDNO
                                                             FROM AHIS_Y1 c
                                                            WHERE c.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                              AND c.Status_CODE = @Lc_Yes_TEXT
                                                              AND c.MemberMci_IDNO = b.MemberMci_IDNO
                                                              AND @Ld_Run_DATE BETWEEN c.Begin_DATE AND c.End_DATE)
                            GROUP BY b.MemberMci_IDNO) AS ahis
           ON a.MemberMci_IDNO = ahis.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT DISTINCT
                                  b.MemberMci_IDNO,
                                  CASE
                                   WHEN EXISTS(SELECT DISTINCT
                                                      1
                                                 FROM EHIS_Y1 h
                                                WHERE h.EndEmployment_DATE > @Ld_Run_DATE
                                                  AND h.MemberMci_IDNO = b.MemberMci_IDNO)
                                    THEN
                                    CASE
                                     WHEN NOT EXISTS(SELECT DISTINCT
                                                            1
                                                       FROM EHIS_Y1 h
                                                      WHERE h.EndEmployment_DATE > @Ld_Run_DATE
                                                        AND h.MemberMci_IDNO = b.MemberMci_IDNO
                                                        AND h.Status_CODE = @Lc_VerificationStatusGood_CODE)
                                      THEN (ABS(DATEDIFF(DD, (SELECT MIN(h.BeginEmployment_DATE)
                                                                FROM EHIS_Y1 h
                                                               WHERE h.EndEmployment_DATE > @Ld_Run_DATE
                                                                 AND h.MemberMci_IDNO = b.MemberMci_IDNO), @Ld_Run_DATE)) / @Li_DaysInMonth_NUMB)
                                    END
                                   ELSE (ABS(DATEDIFF(DD, (SELECT MAX(h.EndEmployment_DATE)
                                                             FROM EHIS_Y1 h
                                                            WHERE h.EndEmployment_DATE < @Ld_Run_DATE
                                                              AND h.MemberMci_IDNO = b.MemberMci_IDNO), @Ld_Run_DATE)) / @Li_DaysInMonth_NUMB)
                                  END AS DurationNoEmpl_QNTY,
                                  ISNULL((SELECT DISTINCT
                                                 1
                                            FROM EHIS_Y1 h
                                           WHERE h.InsProvider_INDC = @Lc_No_TEXT
                                             AND h.MemberMci_IDNO = b.MemberMci_IDNO), 0) AS InsuranceNotAvailable_CODE
                             FROM EHIS_Y1 b) AS ehis
           ON a.MemberMci_IDNO = ehis.MemberMci_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.CpCourtAddrIndc_CODE AS NUMERIC(1))) AS CpCourtAddrIndc_CODE,
                                  MAX(CAST(fci.CpMailingAddrGood_CODE AS NUMERIC(1))) AS CpMailingAddrGood_CODE,
                                  MAX(CAST(fci.CpMailingAddrBad_CODE AS NUMERIC(1))) AS CpMailingAddrBad_CODE,
                                  MAX(CAST(fci.CpMailingAddrPending_CODE AS NUMERIC(1))) AS CpMailingAddrPending_CODE,
                                  MAX(CAST(fci.CpResidentialAddrGood_CODE AS NUMERIC(1))) AS CpResidentialAddrGood_CODE,
                                  MAX(CAST(fci.CpResidentialAddrBad_CODE AS NUMERIC(1))) AS CpResidentialAddrBad_CODE,
                                  MAX(CAST(fci.CpResidentialAddrPend_CODE AS NUMERIC(1))) AS CpResidentialAddrPend_CODE
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeC1_ADDR
                                            THEN 1
                                           ELSE 0
                                          END AS CpCourtAddrIndc_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                AND b.Action_CODE = @Lc_ActionY1_TEXT
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS CpMailingAddrGood_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                AND b.Action_CODE = @Lc_ActionB1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CpMailingAddrBad_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                AND b.Action_CODE = @Lc_ActionP1_TEXT
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS CpMailingAddrPending_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeR1_ADDR
                                                AND b.Action_CODE = @Lc_ActionY1_TEXT
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS CpResidentialAddrGood_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeR1_ADDR
                                                AND b.Action_CODE = @Lc_ActionB1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CpResidentialAddrBad_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeR1_ADDR
                                                AND b.Action_CODE = @Lc_ActionP1_TEXT
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS CpResidentialAddrPend_CODE
                                     FROM BPAHSC_Y1 b) AS fci
                            GROUP BY fci.Case_IDNO) AS ahis_cp
           ON a.Case_IDNO = ahis_cp.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.CpEmploymentAddrGood_CODE AS NUMERIC(1))) AS CpEmploymentAddrGood_CODE,
                                  MAX(CAST(fci.CpEmploymentAddrBad_CODE AS NUMERIC(1))) AS CpEmploymentAddrBad_CODE,
                                  MAX(CAST(fci.CpEmploymentAddrPend_CODE AS NUMERIC(1))) AS CpEmploymentAddrPend_CODE,
                                  MAX(fci.CpEmployment_CODE) AS CpEmployment_CODE
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_Yes_TEXT
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EhisEnd_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS CpEmploymentAddrGood_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_ActionB1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CpEmploymentAddrBad_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_ActionP1_TEXT
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EhisEnd_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS CpEmploymentAddrPend_CODE,
                                          b.Action_CODE AS CpEmployment_CODE
                                     FROM BPEHSC_Y1 b) AS fci
                            GROUP BY fci.Case_IDNO) AS ehis_cp
           ON a.Case_IDNO = ehis_cp.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.NcpCourtAddrIndc_CODE AS NUMERIC(1))) AS NcpCourtAddrIndc_CODE,
                                  MAX(CAST(fci.NcpMailingAddrGood_CODE AS NUMERIC(1))) AS NcpMailingAddrGood_CODE,
                                  MAX(CAST(fci.NcpMailingAddrBad_CODE AS NUMERIC(1))) AS NcpMailingAddrBad_CODE,
                                  MAX(CAST(fci.NcpMailingAddrPending_CODE AS NUMERIC(1))) AS NcpMailingAddrPending_CODE,
                                  MAX(CAST(fci.NcpResidentialAddrGood_CODE AS NUMERIC(1))) AS NcpResidentialAddrGood_CODE,
                                  MAX(CAST(fci.NcpResidentialAddrBad_CODE AS NUMERIC(1))) AS NcpResidentialAddrBad_CODE,
                                  MAX(CAST(fci.NcpResidentialAddrPend_CODE AS NUMERIC(1))) AS NcpResidentialAddrPend_CODE,
                                  MAX(fci.NcpAddress_CODE) AS NcpAddress_CODE
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeC1_ADDR
                                            THEN 1
                                           ELSE 0
                                          END AS NcpCourtAddrIndc_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_Yes_TEXT
                                                AND b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpMailingAddrGood_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_ActionB1_TEXT
                                                AND b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                            THEN 1
                                           ELSE 0
                                          END AS NcpMailingAddrBad_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_ActionP1_TEXT
                                                AND b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpMailingAddrPending_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_Yes_TEXT
                                                AND b.TypeAddress_CODE = @Lc_TypeR1_ADDR
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpResidentialAddrGood_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_ActionB1_TEXT
                                                AND b.TypeAddress_CODE = @Lc_TypeR1_ADDR
                                            THEN 1
                                           ELSE 0
                                          END AS NcpResidentialAddrBad_CODE,
                                          CASE
                                           WHEN b.Action_CODE = @Lc_ActionP1_TEXT
                                                AND b.TypeAddress_CODE = @Lc_TypeR1_ADDR
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpResidentialAddrPend_CODE,
                                          CASE
                                           WHEN b.TypeAddress_CODE = @Lc_TypeM1_ADDR
                                                AND b.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND b.EndAhis_DATE > @Ld_Run_DATE
                                            THEN b.Action_CODE
                                           ELSE @Lc_Space_TEXT
                                          END AS NcpAddress_CODE
                                     FROM BPAHIS_Y1 b) AS fci
                            GROUP BY fci.Case_IDNO) AS ahis_stg
           ON a.Case_IDNO = ahis_stg.Case_IDNO,
          CASE_Y1 c
    WHERE (a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
            OR (a.StatusCase_CODE = @Lc_CaseStatusClosed_CODE
                AND a.StatusCurrent_DATE >= @Ld_Begin_DATE))
      AND a.County_IDNO <> @Lc_County000_TEXT
      AND a.Case_IDNO = c.Case_IDNO;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT BPCAS2_Y1 FAILED';
     SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_JobStep4b_IDNO,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Li_RowCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   COMMIT TRANSACTION STEP4B;

   BEGIN TRANSACTION STEP4B;

   SET @Ls_Sql_TEXT = 'UPDATE BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_JobStep4b_IDNO + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_Success_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobStep4b_IDNO,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_Success_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4b_IDNO, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobStep4b_IDNO,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   COMMIT TRANSACTION STEP4B;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION STEP4B;
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
    @Ac_Job_ID                    = @Lc_JobStep4b_IDNO,
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
