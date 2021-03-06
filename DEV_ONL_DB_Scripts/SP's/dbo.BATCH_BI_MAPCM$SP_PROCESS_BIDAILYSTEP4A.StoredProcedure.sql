/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4A]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4A
Programmer Name	:	IMP Team.
Description		:	This process loads data from staging tables into BPCAS1_Y1.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4A]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY                      INT = 0,
          @Lc_Space_TEXT                         CHAR(1) = ' ',
          @Lc_CaseStatusOpen_CODE                CHAR(1) = 'O',
          @Lc_CaseStatusClosed_CODE              CHAR(1) = 'C',
          @Lc_Success_CODE                       CHAR(1) = 'S',
          @Lc_Failed_CODE                        CHAR(1) = 'F',
          @Lc_Yes_TEXT							 CHAR(1) = 'Y',
          @Lc_CaseMemberActive_CODE              CHAR(1) = 'A',
          @Lc_StatusAbnormalend_CODE             CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_TEXT           CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT     CHAR(1) = 'P',
          @Lc_ComplianceStatusActive_CODE        CHAR(1) = 'AC',
          @Lc_ComplianceStatusNonCompliance_CODE CHAR(1) = 'NC',
          @Lc_SubsystemEn_TEXT                   CHAR(2) = 'EN',
          @Lc_SubsystemEs_TEXT                   CHAR(2) = 'ES',
          @Lc_County000_TEXT                     CHAR(3) = '000',
          @Lc_RemedyStatusExempt_CODE            CHAR(4) = 'EXMT',
          @Lc_RemedyStatusStart_CODE             CHAR(4) = 'STRT',
          @Lc_MajorActivityCoop_CODE             CHAR(4) = 'COOP',
          @Lc_MajorActivityCclo_CODE             CHAR(4) = 'CCLO',
          @Lc_MajorActivityEmnp_CODE             CHAR(4) = 'EMNP',
          @Lc_MajorActivityEstp_CODE             CHAR(4) = 'ESTP',
          @Lc_MajorActivityVapp_CODE             CHAR(4) = 'VAPP',
          @Lc_MajorActivityMapp_CODE             CHAR(4) = 'MAPP',
          @Lc_MajorActivityObra_CODE             CHAR(4) = 'OBRA',
          @Lc_StatusEnforceWCAP_CODE             CHAR(4) = 'WCAP',
          @Lc_MajorActivityBwnt_CODE             CHAR(4) = 'BWNT',
          @Lc_MajorActivityCsln_CODE             CHAR(4) = 'CSLN',
          @Lc_MajorActivityFidm_CODE             CHAR(4) = 'FIDM',
          @Lc_MajorActivityNmsn_CODE             CHAR(4) = 'NMSN',
          @Lc_MajorActivityImiw_CODE             CHAR(4) = 'IMIW',
          @Lc_MajorActivityCrpt_CODE             CHAR(4) = 'CRPT',
          @Lc_MajorActivityPsoc_CODE             CHAR(4) = 'PSOC',
          @Lc_MajorActivityRlcs_CODE             CHAR(4) = 'RLCS',
          @Lc_MajorActivityRofo_CODE             CHAR(4) = 'ROFO',
          @Lc_MajorActivityGtst_CODE             CHAR(4) = 'GTST',
          @Lc_MajorActivityAren_CODE             CHAR(4) = 'AREN',
          @Lc_MajorActivityLint_CODE             CHAR(4) = 'LINT',
          @Lc_MajorActivityLsnr_CODE             CHAR(4) = 'LSNR',
          @Lc_MajorActivityCrim_CODE             CHAR(4) = 'CRIM',
          @Lc_MajorActivityLien_CODE             CHAR(4) = 'LIEN',
          @Lc_MajorActivitySeqo_CODE             CHAR(4) = 'SEQO',
          @Lc_BatchRunUser_TEXT                  CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                     CHAR(5) = 'E0944',
          @Lc_JobStep4a_IDNO                     CHAR(7) = 'DEB0850',
          @Lc_Successful_TEXT                    CHAR(10) = 'SUCCESSFUL',
          @Lc_Process_NAME                       CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME                     VARCHAR(50) = 'SP_PROCESS_BIDAILYSTEP4A',
          @Ld_Highdate_DATE                      DATE = '12/31/9999',
          @Ld_Lowdate_DATE                       DATE = '01/01/0001';
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
          @Ld_Begin_DATE                  DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4a_IDNO, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobStep4a_IDNO,
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

   SET @Ls_DescriptionError_TEXT = 'STEP:1 UPDATING BPCAS1_Y1';
   SET @Ls_Sql_TEXT = 'DELETE FROM BPCAS1_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4a_IDNO, '');

   DELETE FROM BPCAS1_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPCAS1_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4a_IDNO, '');

   BEGIN TRANSACTION STEP4A;

   INSERT BPCAS1_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           EnforcementActiveAren_CODE,
           EnforcementActiveCsln_CODE,
           EnforcementActiveFidm_CODE,
           EnforcementActiveLsnr_CODE,
           EnforcementActiveNmsn_CODE,
           EstActiveGtst_CODE,
           EstActiveCoop_CODE,
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
           EnforcementActiveImiw_CODE,
           EnforcementActiveCrpt_CODE,
           EnforcementActiveLint_CODE,
           EnforcementActivePsoc_CODE,
           EnforcementActiveCrim_CODE,
           EnforcementActiveLien_CODE,
           EnforcementActiveSeqo_CODE,
           BenchWarrant_CODE,
           Relieftolit_CODE,
           CapiasIssued_CODE,
           DependentCoverage_CODE,
           ReliefsRequested_TEXT,
           ReliefsOrdered_TEXT,
           RevewCompOrdNotMod_CODE,
           EstActiveFacl_CODE,
           PaymentLast_DATE,
           ActiveLicensePayment_CODE,
           EndedLicensePayment_CODE,
           NonCompliantLicensePayment_CODE)
   SELECT DISTINCT
          a.Case_IDNO,
          a.MemberMci_IDNO,
          ISNULL(dmjr.EnforcementActiveAren_CODE, @Ln_Zero_NUMB) AS EnforcementActiveAren_CODE,
          ISNULL(dmjr.EnforcementActiveCsln_CODE, @Ln_Zero_NUMB) AS EnforcementActiveCsln_CODE,
          ISNULL(dmjr.EnforcementActiveFidm_CODE, @Ln_Zero_NUMB) AS EnforcementActiveFidm_CODE,
          ISNULL(dmjr.EnforcementActiveLsnr_CODE, @Ln_Zero_NUMB) AS EnforcementActiveLsnr_CODE,
          ISNULL(dmjr.EnforcementActiveNmsn_CODE, @Ln_Zero_NUMB) AS EnforcementActiveNmsn_CODE,
          ISNULL(dmjr.EstActiveGtst_CODE, @Ln_Zero_NUMB) AS EstActiveGtst_CODE,
          ISNULL(dmjr.EstActiveCoop_CODE, @Ln_Zero_NUMB) AS EstActiveCoop_CODE,
          ISNULL(dmjr.EstActiveCclo_CODE, @Ln_Zero_NUMB) AS EstActiveCclo_CODE,
          ISNULL(dmjr.EstActiveEmnp_CODE, @Ln_Zero_NUMB) AS EstActiveEmnp_CODE,
          ISNULL(dmjr.EstActiveEstp_CODE, @Ln_Zero_NUMB) AS EstActiveEstp_CODE,
          ISNULL(dmjr.EstActiveVapp_CODE, @Ln_Zero_NUMB) AS EstActiveVapp_CODE,
          ISNULL(dmjr.EstActiveMapp_CODE, @Ln_Zero_NUMB) AS EstActiveMapp_CODE,
          ISNULL(dmjr.EstActiveObra_CODE, @Ln_Zero_NUMB) AS EstActiveObra_CODE,
          ISNULL(dmjr.EstActiveRofo_CODE, @Ln_Zero_NUMB) AS EstActiveRofo_CODE,
          ISNULL(dmjr.CaseClosureInitiated_CODE, @Ln_Zero_NUMB) AS CaseClosureInitiated_CODE,
          ISNULL(dmjr.EstActiveRemedy_CODE, @Ln_Zero_NUMB) AS EstActiveRemedy_CODE,
          ISNULL(dmjr.EnforcementActiveRemedy_CODE, @Ln_Zero_NUMB) AS EnforcementActiveRemedy_CODE,
          CASE
		   WHEN (a.ArenExempt_INDC = @Lc_Yes_TEXT 
		         OR a.CrptExempt_INDC = @Lc_Yes_TEXT 
				 OR a.CslnExempt_INDC = @Lc_Yes_TEXT
				 OR a.FidmExempt_INDC = @Lc_Yes_TEXT
				 OR a.ImiwExempt_INDC = @Lc_Yes_TEXT 
				 OR a.LintExempt_INDC = @Lc_Yes_TEXT
				 OR a.LsnrExempt_INDC = @Lc_Yes_TEXT
				 OR a.NmsnExempt_INDC = @Lc_Yes_TEXT
				 OR a.PsocExempt_INDC = @Lc_Yes_TEXT
				 OR a.CrimExempt_INDC = @Lc_Yes_TEXT
				 OR a.LienExempt_INDC = @Lc_Yes_TEXT
				 OR a.SeqoExempt_INDC = @Lc_Yes_TEXT)
			THEN 1
		   ELSE 0
		  END AS EnforcementExemptRemedy_CODE,
		  ISNULL(CASE
		          WHEN (dmjr.EstActiveGtst_CODE = 0
						AND dmjr.EstActiveCoop_CODE = 0
						AND dmjr.EstActiveCclo_CODE = 0
						AND dmjr.EstActiveEmnp_CODE = 0
						AND dmjr.EstActiveEstp_CODE = 0
						AND dmjr.EstActiveVapp_CODE = 0
						AND dmjr.EstActiveMapp_CODE = 0
						AND dmjr.EstActiveObra_CODE = 0
						AND dmjr.EstActiveRofo_CODE = 0)
				   THEN 1
				  ELSE 0
				 END, @Ln_Zero_NUMB) AS EstNoActiveRemedy_CODE,
          ISNULL(dmjr.EnforcementActiveImiw_CODE, @Ln_Zero_NUMB) AS EnforcementActiveImiw_CODE,
          ISNULL(dmjr.EnforcementActiveCrpt_CODE, @Ln_Zero_NUMB) AS EnforcementActiveCrpt_CODE,
          ISNULL(dmjr.EnforcementActiveLint_CODE, @Ln_Zero_NUMB) AS EnforcementActiveLint_CODE,
          ISNULL(dmjr.EnforcementActivePsoc_CODE, @Ln_Zero_NUMB) AS EnforcementActivePsoc_CODE,
          ISNULL(dmjr.EnforcementActiveCrim_CODE, @Ln_Zero_NUMB) AS EnforcementActiveCrim_CODE,
          ISNULL(dmjr.EnforcementActiveLien_CODE, @Ln_Zero_NUMB) AS EnforcementActiveLien_CODE,
          ISNULL(dmjr.EnforcementActiveSeqo_CODE, @Ln_Zero_NUMB) AS EnforcementActiveSeqo_CODE,
          ISNULL(CASE
                  WHEN dmjr.EnforcementActiveBwnt_CODE = 1
                   THEN 1
                  ELSE 0
                 END, 0) AS BenchWarrant_CODE,
          ISNULL(CASE
                  WHEN dmjr.EnforcementActiveRlcs_CODE = 1
                   THEN 1
                  ELSE 0
                 END, 0) AS ReliefToLit_CODE,
          CASE
           WHEN a.StatusEnforce_CODE = @Lc_StatusEnforceWCAP_CODE
            THEN 1
           ELSE 0
          END AS CapiasIssued_CODE,
          @Ln_Zero_NUMB AS DependentCoverage_CODE,
          @Lc_Space_TEXT AS ReliefsRequested_TEXT,
          @Lc_Space_TEXT AS ReliefsOrdered_TEXT,
          @Ln_Zero_NUMB AS RevewCompOrdNotMod_CODE,
          @Ln_Zero_NUMB AS EstActiveFacl_CODE,
          ISNULL(y.Distribute_DATE, @Ld_Lowdate_DATE) AS PaymentLast_DATE,
          -- 13718 - BCASE_Y1 - CR0431 License Suspension Updates 20141112 -START-
          @Ln_Zero_NUMB AS ActiveLicensePayment_CODE,
          @Ln_Zero_NUMB AS EndedLicensePayment_CODE,
          @Ln_Zero_NUMB AS NonCompliantLicensePayment_CODE
          -- 13718 - BCASE_Y1 - CR0431 License Suspension Updates 20141112 -END-          
     FROM (SELECT c.MemberMci_IDNO,		           
                  e.*
             FROM ENSD_Y1 e, 
                  CMEM_Y1 c
            WHERE e.Case_IDNO = c.Case_IDNO
              AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
              AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE) AS a
          LEFT OUTER JOIN (SELECT x.Case_IDNO,
                                  MAX(x.Distribute_DATE) AS Distribute_DATE
                             FROM (SELECT a.Case_IDNO,
                                          a.Distribute_DATE
                                     FROM LSUP_Y1 a
                                    WHERE a.Batch_DATE != @Ld_Lowdate_DATE) AS x
                            GROUP BY x.Case_IDNO) AS y
           ON a.Case_IDNO = y.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.EnforcementActiveAren_CODE AS NUMERIC(1))) AS EnforcementActiveAren_CODE,
                                  MAX(CAST(fci.EnforcementActiveCsln_CODE AS NUMERIC(1))) AS EnforcementActiveCsln_CODE,
                                  MAX(CAST(fci.EnforcementActiveFidm_CODE AS NUMERIC(1))) AS EnforcementActiveFidm_CODE,
                                  MAX(CAST(fci.EnforcementActiveLsnr_CODE AS NUMERIC(1))) AS EnforcementActiveLsnr_CODE,
                                  MAX(CAST(fci.EnforcementActiveNmsn_CODE AS NUMERIC(1))) AS EnforcementActiveNmsn_CODE,
                                  MAX(CAST(fci.EstActiveGtst_CODE AS NUMERIC(1))) AS EstActiveGtst_CODE,
                                  MAX(CAST(fci.EstActiveCoop_CODE AS NUMERIC(1))) AS EstActiveCoop_CODE,
                                  MAX(CAST(fci.EstActiveCclo_CODE AS NUMERIC(1))) AS EstActiveCclo_CODE,
                                  MAX(CAST(fci.EstActiveEmnp_CODE AS NUMERIC(1))) AS EstActiveEmnp_CODE,
                                  MAX(CAST(fci.EstActiveEstp_CODE AS NUMERIC(1))) AS EstActiveEstp_CODE,
                                  MAX(CAST(fci.EstActiveVapp_CODE AS NUMERIC(1))) AS EstActiveVapp_CODE,
                                  MAX(CAST(fci.EstActiveMapp_CODE AS NUMERIC(1))) AS EstActiveMapp_CODE,
                                  MAX(CAST(fci.EstActiveObra_CODE AS NUMERIC(1))) AS EstActiveObra_CODE,
                                  MAX(CAST(fci.EstActiveRofo_CODE AS NUMERIC(1))) AS EstActiveRofo_CODE,
                                  MAX(CAST(fci.CaseClosureInitiated_CODE AS NUMERIC(1))) AS CaseClosureInitiated_CODE,
                                  MAX(CAST(fci.EstActiveRemedy_CODE AS NUMERIC(1))) AS EstActiveRemedy_CODE,
                                  MAX(CAST(fci.EnforcementActiveRemedy_CODE AS NUMERIC(1))) AS EnforcementActiveRemedy_CODE,                                  
                                  MAX(CAST(fci.EnforcementActiveBwnt_CODE AS NUMERIC(1))) AS EnforcementActiveBwnt_CODE,
                                  MAX(CAST(fci.EnforcementActiveRlcs_CODE AS NUMERIC(1))) AS EnforcementActiveRlcs_CODE,
                                  MAX(CAST(fci.EnforcementActiveImiw_CODE AS NUMERIC(1))) AS EnforcementActiveImiw_CODE,
                                  MAX(CAST(fci.EnforcementActiveCrpt_CODE AS NUMERIC(1))) AS EnforcementActiveCrpt_CODE,
                                  MAX(CAST(fci.EnforcementActiveLint_CODE AS NUMERIC(1))) AS EnforcementActiveLint_CODE,
                                  MAX(CAST(fci.EnforcementActivePsoc_CODE AS NUMERIC(1))) AS EnforcementActivePsoc_CODE,
                                  MAX(CAST(fci.EnforcementActiveCrim_CODE AS NUMERIC(1))) AS EnforcementActiveCrim_CODE,
                                  MAX(CAST(fci.EnforcementActiveLien_CODE AS NUMERIC(1))) AS EnforcementActiveLien_CODE,
                                  MAX(CAST(fci.EnforcementActiveSeqo_CODE AS NUMERIC(1))) AS EnforcementActiveSeqo_CODE
                             FROM (SELECT b.Case_IDNO,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityAren_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveAren_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityBwnt_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveBwnt_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityCsln_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveCsln_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityFidm_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveFidm_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityLsnr_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveLsnr_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityNmsn_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveNmsn_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityGtst_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveGtst_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityCoop_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveCoop_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityCclo_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveCclo_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityEmnp_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveEmnp_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityEstp_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveEstp_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityVapp_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveVapp_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityMapp_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveMapp_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityObra_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveObra_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityRofo_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveRofo_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityCclo_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS CaseClosureInitiated_CODE,
                                          CASE
                                           WHEN b.BiSubsystem_CODE = @Lc_SubsystemEs_TEXT
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EstActiveRemedy_CODE,
                                          CASE
                                           WHEN b.BiSubsystem_CODE = @Lc_SubsystemEn_TEXT
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveRemedy_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityRlcs_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveRlcs_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityImiw_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveImiw_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityCrpt_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveCrpt_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityLint_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveLint_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityPsoc_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActivePsoc_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityCrim_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveCrim_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivityLien_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveLien_CODE,
                                          CASE
                                           WHEN b.ActivityMajor_CODE = @Lc_MajorActivitySeqo_CODE
                                                AND b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS EnforcementActiveSeqo_CODE
                                     FROM BPRMDY_Y1 b) AS fci
                            GROUP BY fci.Case_IDNO) AS dmjr
           ON a.Case_IDNO = dmjr.Case_IDNO
          LEFT OUTER JOIN (SELECT DISTINCT
                                  fci.Case_IDNO,
                                  fci.MemberMci_IDNO
                             FROM (SELECT b.Case_IDNO,
                                          b.OrderSeq_NUMB,
                                          b.BiSubsystem_CODE,
                                          b.ActivityMajor_CODE,
                                          b.ActivityMinor_CODE,
                                          b.ActivityOrder_QNTY,
                                          b.Status_CODE,
                                          b.Status_DATE,
                                          b.DaysActivityElapsed_QNTY,
                                          b.BeginExempt_DATE,
                                          b.EndExempt_DATE,
                                          b.MajorIntSeq_NUMB,
                                          b.MinorIntSeq_NUMB,
                                          b.ReasonStatus_CODE,
                                          b.DescriptionActivityMajor_TEXT,
                                          b.DescriptionActivityMinor_TEXT,
                                          b.MemberMci_IDNO,
                                          b.TypeOthpSource_CODE,
                                          b.OthpSource_IDNO,
                                          b.TransactionEventMajorSeq_NUMB,
                                          b.TransactionEventMinorSeq_NUMB,
                                          b.StatusMinor_CODE,
                                          b.StatusMinor_DATE,
                                          ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO, b.MemberMci_IDNO ORDER BY b.MajorIntSeq_NUMB DESC) AS rnm
                                     FROM BPRMDY_Y1 b
                                    WHERE b.Status_CODE = @Lc_RemedyStatusStart_CODE
                                      AND b.StatusMinor_CODE = @Lc_RemedyStatusStart_CODE) AS fci
                            WHERE fci.rnm = 1) AS dmjr2
           ON a.Case_IDNO = dmjr2.Case_IDNO
    WHERE (a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
            OR (a.StatusCase_CODE = @Lc_CaseStatusClosed_CODE
                AND a.StatusCurrent_DATE >= @Ld_Begin_DATE))
      AND a.County_IDNO <> @Lc_County000_TEXT;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT BPCAS1_Y1 FAILED';
     SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_JobStep4a_IDNO,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Li_RowCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     
     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   COMMIT TRANSACTION STEP4A;

   BEGIN TRANSACTION STEP4A;

   SET @Ls_Sql_TEXT = 'UPDATE BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_JobStep4a_IDNO + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_Success_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobStep4a_IDNO,
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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4a_IDNO, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobStep4a_IDNO,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   COMMIT TRANSACTION STEP4A;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION STEP4A;
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
    @Ac_Job_ID                    = @Lc_JobStep4a_IDNO,
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
