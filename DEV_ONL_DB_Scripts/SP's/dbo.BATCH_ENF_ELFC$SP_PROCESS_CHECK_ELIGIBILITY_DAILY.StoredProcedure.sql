/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_DAILY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_DAILY
Programmer Name		: IMP Team
Description			: This process reads records from ELFC_Y1 table and initiates/closes remedies based on the
					  eligibility criteria.
Frequency			: 'DAILY'
Developed On		: 04/06/2011
Called BY			: None
Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_DAILY]
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Lc_StatusSuccess_CODE						CHAR(1)				= 'S',
           @Lc_Space_TEXT                               CHAR(1)				= ' ',
           @Lc_CaseStatusOpen_CODE                      CHAR(1)				= 'O',
           @Lc_CaseTypeNonIvd_CODE                      CHAR(1)				= 'H',
           @Lc_CaseMemberStatusActive_CODE              CHAR(1)				= 'A',
           @Lc_CaseRelationshipNcp_CODE                 CHAR(1)				= 'A',
           @Lc_CaseRelationshipCp_CODE                  CHAR(1)				= 'C',
           @Lc_CaseRelationshipPf_CODE                  CHAR(1)				= 'P',
           @Lc_CaseRelationshipDependent_CODE           CHAR(1)				= 'D',
           @Lc_Yes_INDC                                 CHAR(1)				= 'Y',
           @Lc_No_INDC                                  CHAR(1)				= 'N',
           @Lc_CaseCharging_CODE                        CHAR(1)				= 'C',
           @Lc_CaseArrearsOnly_CODE                     CHAR(1)				= 'A',
           @Lc_OrderTypeVoluntary_CODE                  CHAR(1)				= 'V',
           @Lc_RespondInitInstate_CODE					CHAR(1)				= 'N',
           @Lc_RespondInitInitiate_CODE                 CHAR(1)				= 'I',
           @Lc_RespondInitInitiateIntrnl_CODE           CHAR(1)				= 'C',
           @Lc_RespondInitInitiateTribal_CODE           CHAR(1)				= 'T',
           @Lc_NegPosPositive_CODE                      CHAR(1)				= 'P',
           @Lc_StatusAbnormalend_CODE                   CHAR(1)				= 'A',
           @Lc_TypeAddressC_CODE                        CHAR(1)				= 'C',
           @Lc_TypeAddressM_CODE                        CHAR(1)				= 'M',
           @Lc_StatusY_CODE                             CHAR(1)				= 'Y',
           @Lc_StatusP_CODE                             CHAR(1)				= 'P',
           @Lc_InsOrderedA_CODE                         CHAR(1)				= 'A',
           @Lc_InsOrderedB_CODE                         CHAR(1)				= 'B',
           @Lc_InsOrderedC_CODE                         CHAR(1)				= 'C',
           @Lc_InsOrderedD_CODE                         CHAR(1)				= 'D',
           @Lc_InsOrderedN_CODE                         CHAR(1)				= 'N',
           @Lc_InsOrderedO_CODE                         CHAR(1)				= 'O',
           @Lc_InsOrderedU_CODE                         CHAR(1)				= 'U',
           @Lc_IiwoC_CODE                               CHAR(1)				= 'C',
           @Lc_IiwoI_CODE                               CHAR(1)				= 'I',
           @Lc_IiwoN_CODE								CHAR(1)				= 'N',
           @Lc_IiwoA_CODE								CHAR(1)				= 'A',
           @Lc_IiwoS_CODE								CHAR(1)				= 'S',
           @Lc_LicenseStatusActive_CODE					CHAR(1)				= 'A',
           @Lc_LicenseStatusR_CODE                      CHAR(1)				= 'R',
           @Lc_TypeOthpG_CODE                           CHAR(1)				= 'G',
           @Lc_RespondInitRespondingState_CODE          CHAR(1)				= 'R',
           @Lc_RespondInitRespondingTribal_CODE         CHAR(1)				= 'S',
           @Lc_RespondInitRespondingInternational_CODE  CHAR(1)				= 'Y',
           @Lc_ReasonStatusCi_CODE                      CHAR(2)				= 'CI',
           @Lc_ReasonStatusDc_CODE						CHAR(2)				= 'DC',
           @Lc_TypeChangeCa_CODE                        CHAR(2)				= 'CA',
           @Lc_TypeChangeCc_CODE                        CHAR(2)				= 'CC',
           @Lc_TypeChangeEm_CODE                        CHAR(2)				= 'EM',
           @Lc_TypeChangeEp_CODE                        CHAR(2)				= 'EP',
           @Lc_TypeChangeIw_CODE                        CHAR(2)				= 'IW',
           @Lc_TypeChangeLs_CODE                        CHAR(2)				= 'LS',
           @Lc_TypeChangeMp_CODE                        CHAR(2)				= 'MP',
           @Lc_TypeChangeNm_CODE                        CHAR(2)				= 'NM',
           @Lc_TypeReferencePt_CODE                     CHAR(2)				= 'PT',
           @Lc_StateInState_CODE                        CHAR(2)				= 'DE',
           @Lc_TypeLicenseDr_CODE						CHAR(2)				= 'DR',
           @Lc_StatusCg_CODE                            CHAR(2)				= 'CG',
           -- 13718 - EMON - CR0431 License Suspension Updates - REMOVED -
           @Lc_CaseCategoryPa_CODE						CHAR(2)				= 'PA',
           @Lc_CaseCategoryPc_CODE                      CHAR(2)				= 'PC',
           @Lc_CaseCategoryDp_CODE                      CHAR(2)				= 'DP',
           @Lc_TypeDebtCs_CODE                          CHAR(2)				= 'CS',
           @Lc_TypeDebtMs_CODE                          CHAR(2)				= 'MS',
           @Lc_TypeIncomeEm_CODE                        CHAR(2)				= 'EM',
           @Lc_TypeIncomeCs_CODE                        CHAR(2)				= 'CS',
           @Lc_TypeIncomeDs_CODE                        CHAR(2)				= 'DS',
           @Lc_TypeIncomeMb_CODE                        CHAR(2)				= 'MB',
           @Lc_TypeIncomeMl_CODE                        CHAR(2)				= 'ML',
           @Lc_TypeIncomeMr_CODE                        CHAR(2)				= 'MR',
           @Lc_TypeIncomeRt_CODE                        CHAR(2)				= 'RT',
           @Lc_TypeIncomeSe_CODE                        CHAR(2)				= 'SE',
           @Lc_TypeIncomeSs_CODE                        CHAR(2)				= 'SS',
           @Lc_TypeIncomeUi_CODE                        CHAR(2)				= 'UI',
           @Lc_TypeIncomeUn_CODE                        CHAR(2)				= 'UN',
           @Lc_TypeIncomeVp_CODE                        CHAR(2)				= 'VP',
           @Lc_TypeIncomeWc_CODE                        CHAR(2)				= 'WC',
           @Lc_StatusEnforceWcap_CODE                   CHAR(4)				= 'WCAP',
           @Lc_StatusEnforceUdoc_CODE                   CHAR(4)				= 'UDOC',
           @Lc_StatusEnforceUgna_CODE                   CHAR(4)				= 'UNGA',
           @Lc_RemedyStatusStart_CODE                   CHAR(4)				= 'STRT',
           @Lc_ActivityMajorCclo_CODE                   CHAR(4)				= 'CCLO',
           @Lc_ActivityMajorEmnp_CODE                   CHAR(4)				= 'EMNP',
           @Lc_ActivityMajorImiw_CODE                   CHAR(4)				= 'IMIW',
           @Lc_ActivityMajorLsnr_CODE                   CHAR(4)				= 'LSNR',
           @Lc_ActivityMajorCpls_CODE					CHAR(4)				= 'CPLS',
           @Lc_ActivityMajorMapp_CODE                   CHAR(4)				= 'MAPP',
           @Lc_ActivityMajorNmsn_CODE                   CHAR(4)				= 'NMSN',
           @Lc_BatchRunUser_TEXT                        CHAR(5)				= 'BATCH',
           @Lc_ActivityMinorFamup_CODE                  CHAR(5)				= 'FAMUP',
           @Lc_ReasonErfso_CODE                         CHAR(5)				= 'ERFSO',
           @Lc_ReasonErfsm_CODE                         CHAR(5)				= 'ERFSM',
           @Lc_ReasonErfss_CODE                         CHAR(5)				= 'ERFSS',
           @Lc_Job_ID                                   CHAR(7)				= 'DEB0660',
           @Lc_Successful_INDC                          CHAR(20)			= 'SUCCESSFUL',
           @Lc_Routine_TEXT                             CHAR(40)			= 'SP_PROCESS_CHECK_ELIGIBILITY_DAILY',
           @Ls_Package_NAME                             VARCHAR(100)		= 'BATCH_ENF_ELFC',
           @Ld_High_DATE                                DATE				= '12/31/9999',
           @Ld_Low_DATE                                 DATE				= '01/01/0001';

  DECLARE @Ln_CommitFreqParm_QNTY						NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY				NUMERIC(5),
          @Ln_Error_NUMB								NUMERIC(10),
          @Ln_ErrorLine_NUMB							NUMERIC(10),
          @Ln_EmanCount_NUMB							NUMERIC(10),
		  @Ln_MappCount_NUMB							NUMERIC(10),
          @Ln_LsnrCount_NUMB							NUMERIC(10),
          @Ln_ImiwCount_NUMB							NUMERIC(10),
          @Ln_NmsnCount_NUMB							NUMERIC(10),
          @Ln_TotalRecordCount_NUMB						NUMERIC(10)			= 0,
          @Lc_Msg_CODE									CHAR(5),
          @Ls_Sql_TEXT									VARCHAR(100),
          @Ls_Sqldata_TEXT								VARCHAR(1000),
          @Ls_DescriptionError_TEXT						VARCHAR(4000),
          @Ld_Run_DATE									DATE,
          @Ld_LastRun_DATE								DATE,
          @Ld_System_DTTM								DATETIME2			= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
          
  DECLARE @Ls_CursorLoc_TEXT VARCHAR(200);

  BEGIN TRY
   -- Initiating the Batch start Date and Time
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID  = ' + @Lc_Job_ID;

   -- Fetching date run, date last run, commit freq, exception threshold details
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   --Date Run Validation
   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECKING BATCH LAST RUN DATE';
   SET @Ls_Sqldata_TEXT = ' DT_LAST_RUN = ' + CAST(@Ld_LastRun_DATE AS CHAR(10)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   --Last Run Date Validation
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sql_TEXT = 'PARM DATE PROBLEM';
      SET @Ls_Sqldata_TEXT = @Ls_Sqldata_TEXT;
     RAISERROR (50001,16,1);
    END

    BEGIN TRANSACTION ElfcDailyTran;

   SET @Ls_Sql_TEXT = 'EMNP - EMANCIPATION(EMNP)';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

  INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
   SELECT fci.MemberMci_IDNO,
          fci.Case_IDNO,
          fci.OrderSeq_NUMB,
          @Lc_Job_ID AS Process_ID,
          TypeChange_CODE,
          fci.OthpSource_IDNO,
          @Lc_NegPosPositive_CODE AS NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_System_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB, 
          @Lc_Space_TEXT AS TypeReference_CODE,
          @Lc_Space_TEXT AS Reference_ID
     FROM (SELECT fci.MemberMci_IDNO,
                  fci.Case_IDNO,
                  fci.OrderSeq_NUMB,
				  fci.OthpSource_IDNO,
				  CASE (SELECT MAX(m.Birth_DATE) 
					     FROM DEMO_Y1 m
						WHERE m.MemberMci_IDNO IN ( SELECT c.MemberMci_IDNO FROM CMEM_Y1 c 
													 WHERE c.Case_IDNO = fci.Case_IDNO
													   AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
													   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
					  WHEN fci.Birth_DATE
						THEN @Lc_TypeChangeEm_CODE
					  ELSE @Lc_TypeChangeEp_CODE
				  END  AS TypeChange_CODE
             FROM (SELECT fci.Case_IDNO,
                          fci.OrderSeq_NUMB,
                          fci.MemberMci_IDNO,
						  fci.OthpSource_IDNO,
                          fci.Birth_DATE,
                          CASE
                           WHEN (LTRIM(RTRIM(fci.Emancipation_DATE))		= ''
                                  OR fci.Emancipation_DATE IN (@Ld_Low_DATE, @Ld_High_DATE))
                                AND DATEADD(D, -180, DATEADD(m, 216, fci.Birth_DATE)) BETWEEN DATEADD(D, -5, @Ld_LastRun_DATE) AND @Ld_Run_DATE
                            THEN 1
                           WHEN (LTRIM(RTRIM(fci.Emancipation_DATE)) <> ''
                                 AND fci.Emancipation_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE))
                                AND ((DATEADD(D, -180, fci.Emancipation_DATE) BETWEEN DATEADD(D, -5, @Ld_LastRun_DATE) AND @Ld_Run_DATE)
                                      OR ((@Ld_Run_DATE BETWEEN DATEADD(D, -180, fci.Emancipation_DATE) AND fci.Emancipation_DATE)
                                          AND (fci.BeginValidity_DATE BETWEEN DATEADD(D, -5, @Ld_LastRun_DATE) AND @Ld_Run_DATE)))
                            THEN 1
                           ELSE 0
                          END AS ind_eligible
                     FROM (SELECT e.Case_IDNO,
                                  e.OrderSeq_NUMB,
								  e.NcpPf_IDNO AS MemberMci_IDNO,
                                  m.MemberMci_IDNO AS OthpSource_IDNO,
                                  d.Birth_DATE,
                                  d.Emancipation_DATE,
                                  d.BeginValidity_DATE
                             FROM ENSD_Y1 e
                                  INNER JOIN CMEM_Y1 m
                                   ON m.Case_IDNO = e.Case_IDNO
                                      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                      AND m.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
                                      AND EXISTS (SELECT 1
                                                    FROM OBLE_Y1 o
                                                   WHERE o.Case_IDNO = m.Case_IDNO
                                                     AND o.MemberMci_IDNO = m.MemberMci_IDNO
                                                     AND o.EndValidity_DATE = @Ld_High_DATE
                                                     AND @Ld_Run_DATE BETWEEN o.BeginObligation_DATE AND EndObligation_DATE
                                                     AND o.TypeDebt_CODE IN (@Lc_TypeDebtCs_CODE, @Lc_TypeDebtMs_CODE)
                                                     AND o.Periodic_AMNT > 0)
                                  INNER JOIN DEMO_Y1 d
                                   ON m.MemberMci_IDNO = d.MemberMci_IDNO
                            WHERE e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                  AND e.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                                  AND e.CaseCategory_CODE NOT IN (@Lc_CaseCategoryPa_CODE, @Lc_CaseCategoryPc_CODE)
                                  AND e.RespondInit_CODE NOT IN(@Lc_RespondInitInitiateIntrnl_CODE, @Lc_RespondInitInitiate_CODE, @Lc_RespondInitInitiateTribal_CODE)
                                  AND e.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                                  AND @Ld_Run_DATE BETWEEN e.OrderEffective_DATE AND e.OrderEnd_DATE
                                  AND EXISTS (SELECT 1
                                                FROM SORD_Y1 s
                                               WHERE e.Case_IDNO = s.Case_IDNO
                                                 AND e.OrderSeq_NUMB = s.OrderSeq_NUMB
                                                 AND s.StateControl_CODE = @Lc_StateInState_CODE
                                                 AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
                                                 AND s.EndValidity_DATE = @Ld_High_DATE)
                                  AND NOT EXISTS (SELECT 1
                                                    FROM DMJR_Y1 a
                                                   WHERE a.Case_IDNO = e.Case_IDNO
                                                     AND ( a.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
														   OR 
														    ( a.OthpSource_IDNO = m.MemberMci_IDNO
															AND a.ActivityMajor_CODE = @Lc_ActivityMajorEmnp_CODE)
														  )
                                                     AND a.Status_CODE = @Lc_RemedyStatusStart_CODE)
                                  AND NOT EXISTS (SELECT 1
                                                    FROM ELFC_Y1 a
                                                   WHERE a.Case_IDNO = e.Case_IDNO
                                                     AND a.Process_DATE = @Ld_High_DATE
                                                     AND ( a.TypeChange_CODE = @Lc_TypeChangeCc_CODE
														OR
														  ( a.TypeChange_CODE IN (@Lc_TypeChangeEm_CODE, @Lc_TypeChangeEp_CODE)
															AND a.OthpSource_IDNO = m.MemberMci_IDNO
															AND a.MemberMci_IDNO = e.NcpPf_IDNO ))
												  )
							) AS fci) AS fci 
            WHERE fci.ind_eligible = 1 ) AS fci;

   SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @@ROWCOUNT;

   COMMIT TRANSACTION ElfcDailyTran;

   BEGIN TRANSACTION ElfcDailyTran;

   SET @Ls_Sql_TEXT = 'MAPP - MOTION AND PETITION PROCESS(CONTEMPT)';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

  INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
   SELECT fci.NcpPf_IDNO,
          fci.Case_IDNO,
          fci.OrderSeq_NUMB,
          @Lc_Job_ID AS Process_ID,
          fci.TypeChange_CODE,
          fci.NcpPf_IDNO,
          fci.NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_System_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB,
          @Lc_TypeReferencePt_CODE AS TypeReference_CODE, 
          @Lc_Space_TEXT AS Reference_ID
     FROM (SELECT fci.NcpPf_IDNO,
                  fci.Case_IDNO,
                  fci.OrderSeq_NUMB,
                  @Lc_TypeChangeMp_CODE AS TypeChange_CODE,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE
             FROM (SELECT e.NcpPf_IDNO,
                          e.Case_IDNO,
                          e.OrderSeq_NUMB,
                          e.OrderIssued_DATE,
                          e.LastRegularPaymentReceived_DATE,
                          (SELECT COUNT(1)
                             FROM DMNR_Y1 j
                            WHERE j.Case_IDNO = e.Case_IDNO
                              AND j.MemberMci_IDNO = e.NcpPf_IDNO
                              AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                              AND j.ActivityMinor_CODE = @Lc_ActivityMinorFamup_CODE
                              AND j.ReasonStatus_CODE = @Lc_ReasonStatusCi_CODE
                              AND EXISTS (SELECT 1
                                            FROM DMJR_Y1 m
                                           WHERE Case_IDNO = j.Case_IDNO
                                             AND MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                                             AND OthpSource_IDNO = e.NcpPf_IDNO)) Motion_Count_NUMB
                     FROM ENSD_Y1 e
                    WHERE e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          AND e.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                          AND e.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                          -- Cases are not eleigible to start with Enforcement Status WCAP, UGNA and UDOC.
                          AND e.StatusEnforce_CODE NOT IN (@Lc_StatusEnforceWcap_CODE,@Lc_StatusEnforceUgna_CODE,@Lc_StatusEnforceUdoc_CODE)
                          -- NCP should not be currently incarcerated or in past 60 days incarcerated.
                          AND ( (e.Incarceration_DATE = @Ld_Low_DATE 
								  AND e.Institutionalized_DATE = @Ld_Low_DATE
								 )
                                OR e.Released_DATE < DATEADD(D, -60, @Ld_Run_DATE) 
                               )
                          AND @Ld_Run_DATE BETWEEN e.OrderEffective_DATE AND e.OrderEnd_DATE
                          -- In Charging and Arrear Only Cases, Arrear amount should be greater than or equal to 1500 and 5000 respectively.
                          AND (( e.CaseChargingArrears_CODE = @Lc_CaseCharging_CODE
									AND e.Arrears_AMNT >= 1500
								)
					  		OR ( e.CaseChargingArrears_CODE = @Lc_CaseArrearsOnly_CODE
									AND e.Arrears_AMNT >= 5000
								)
							  )
                          -- Case is not Initiating interstate OR if the case is Initiating interstate the referral type is not Registration for Modification only
                          AND (e.RespondInit_CODE = @Lc_RespondInitInstate_CODE
                                OR (e.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
									   AND NOT EXISTS(SELECT 1
														FROM ICAS_Y1 x
													   WHERE x.Case_IDNO = e.Case_IDNO
														 AND x.RespondInit_CODE = e.RespondInit_CODE
														 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
														 AND x.EndValidity_DATE=@Ld_High_DATE)))
                          -- Arrears are greater than 1 month current support
                          AND e.Arrears_AMNT > e.Mso_AMNT
                          -- NCP is not in active chapter 13 bankruptcy
                          AND (e.Bankruptcy13_INDC = @Lc_No_INDC
                                OR (e.Bankruptcy13_INDC = @Lc_Yes_INDC
                                    AND ((e.Dismissed_DATE != @Ld_Low_DATE
                                          AND @Ld_Run_DATE > e.Dismissed_DATE)
                                          OR (e.Discharge_DATE != @Ld_Low_DATE
                                              AND @Ld_Run_DATE > e.Discharge_DATE))))
                          -- Case is not Exempted from Enforcement
                          AND e.CaseExempt_INDC = @Lc_No_INDC
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 a
                                           WHERE a.Case_IDNO = e.Case_IDNO
                                             AND ( a.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                                   OR 
                                                   (a.OthpSource_IDNO = e.NcpPf_IDNO
													 AND a.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
													 AND a.TypeReference_CODE = @Lc_TypeReferencePt_CODE)
												  )
                                             AND a.Status_CODE = @Lc_RemedyStatusStart_CODE)
                          -- MAPP chain must not initiate again for 60 days if Worker disapproved with reason DC already.
                          AND NOT EXISTS (SELECT 1
                                            FROM DMNR_Y1 a
                                           WHERE a.Case_IDNO = e.Case_IDNO
                                             AND a.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
											 AND a.ReasonStatus_CODE = @Lc_ReasonStatusDc_CODE
											 AND a.Status_DATE >= DATEADD(D, -60, @Ld_Run_DATE))
                          AND NOT EXISTS (SELECT 1
                                            FROM ELFC_Y1 a
                                           WHERE a.Case_IDNO = e.Case_IDNO
                                             AND a.Process_DATE = @Ld_High_DATE
                                             AND ( a.TypeChange_CODE = @Lc_TypeChangeCc_CODE
													OR
												   (a.TypeChange_CODE = @Lc_TypeChangeMp_CODE
													AND a.OthpSource_IDNO = e.NcpPf_IDNO
													AND a.MemberMci_IDNO = e.NcpPf_IDNO
												   )))) AS fci
            WHERE CASE
                   -- NCP has not previously been found in Contempt at least once
                   WHEN fci.Motion_Count_NUMB = 0
                        AND fci.OrderIssued_DATE < DATEADD(D, -90, @Ld_Run_DATE)
                        AND fci.OrderIssued_DATE != @Ld_Low_DATE
                        AND fci.LastRegularPaymentReceived_DATE < DATEADD(D, -30, @Ld_Run_DATE)
                    THEN 1
                   -- NCP has previously been found in Contempt at least once
                   WHEN fci.Motion_Count_NUMB = 1
                        AND fci.OrderIssued_DATE < DATEADD(D, -120, @Ld_Run_DATE)
                        AND fci.OrderIssued_DATE != @Ld_Low_DATE
                        AND fci.LastRegularPaymentReceived_DATE < DATEADD(D, -60, @Ld_Run_DATE)
                    THEN 1
                   ELSE 0
                  END = 1 ) AS fci;

   SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @@ROWCOUNT;

   COMMIT TRANSACTION ElfcDailyTran;

   BEGIN TRANSACTION ElfcDailyTran;

   SET @Ls_Sql_TEXT = 'LSNR - LICENSE SUSPENSION OR CPLS - CAPIAS LICENSE SUSPENSION';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
    SELECT e.NcpPf_IDNO,
          e.Case_IDNO,
          e.OrderSeq_NUMB,
          @Lc_Job_ID AS Process_ID,
          e.TypeChange_CODE,
          e.OthpLicAgent_IDNO,
          @Lc_NegPosPositive_CODE AS NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
		  @Ld_High_DATE AS Process_DATE,
		  @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
		  @Ld_System_DTTM AS Update_DTTM,
		  0 AS TransactionEventSeq_NUMB,
		  e.TypeLicense_CODE,
		  e.LicenseNo_TEXT
     FROM (SELECT e.NcpPf_IDNO,
                  e.Case_IDNO,
                  e.OrderSeq_NUMB,
                  CASE WHEN e.CourtOrderIssuedOrg_DATE <= DATEADD(D, -45, @Ld_Run_DATE)
						AND e.Arrears_AMNT >= 3500
						-- 13160 - CR0347 License Suspension Changes - Start
						AND e.LastIdenPaymentReceived_DATE < DATEADD(D, -60, @Ld_Run_DATE)
						-- 13160 - CR0347 License Suspension Changes - End
						AND (e.Bankruptcy13_INDC = @Lc_No_INDC
							  OR (	(e.Dismissed_DATE != @Ld_Low_DATE
										AND @Ld_Run_DATE > e.Dismissed_DATE)
								 OR (e.Discharge_DATE != @Ld_Low_DATE
										AND @Ld_Run_DATE > e.Discharge_DATE)))
						AND e.Deceased_DATE = @Ld_Low_DATE
						AND ((e.Incarceration_DATE = @Ld_Low_DATE
							  AND e.Institutionalized_DATE = @Ld_Low_DATE)
							  OR @Ld_Run_DATE > e.Released_DATE)
					THEN @Lc_TypeChangeLs_CODE
					ELSE @Lc_TypeChangeCa_CODE
				  END TypeChange_CODE,
                  p.OthpLicAgent_IDNO,
                  p.LicenseNo_TEXT,
                  p.TypeLicense_CODE
             FROM ENSD_Y1 e
             JOIN PLIC_Y1 p
               ON p.MemberMci_IDNO = e.NcpPf_IDNO
              -- 13627 - License Suspension eligibility should not require an active license for DMV - Start
              AND ( p.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
					OR p.LicenseStatus_CODE = @Lc_LicenseStatusActive_CODE)
			  -- 13627 - License Suspension eligibility should not require an active license for DMV - End
              AND p.IssuingState_CODE = @Lc_StateInState_CODE
              AND p.Status_CODE = @Lc_StatusCg_CODE
              AND p.EndValidity_DATE = @Ld_High_DATE
              AND @Ld_Run_DATE BETWEEN p.IssueLicense_DATE AND p.ExpireLicense_DATE
              AND EXISTS (SELECT 1
							FROM AHIS_Y1 h
						   WHERE h.MemberMci_IDNO = p.MemberMci_IDNO
							 AND @Ld_Run_DATE BETWEEN h.Begin_DATE AND h.End_DATE
							 AND h.Status_CODE = @Lc_StatusY_CODE
							 AND h.TypeAddress_CODE IN (@Lc_TypeAddressC_CODE, @Lc_TypeAddressM_CODE))
            WHERE e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
              AND e.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
              AND e.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
              -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Starts
              --Not to initiate LSNR activity chain when no Licence Number exists
              AND LTRIM(RTRIM(p.LicenseNo_TEXT)) <> ''                          
              AND e.CaseExempt_INDC = @Lc_No_INDC
              -- LSNR is not Exempt
              AND e.LsnrExempt_INDC = @Lc_No_INDC
              AND ( (e.StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE
						AND e.OrderEnd_DATE = @Ld_Low_DATE)
					OR
					(@Ld_Run_DATE BETWEEN e.OrderEffective_DATE AND e.OrderEnd_DATE
					  AND EXISTS ( SELECT 1
									 FROM ACEN_Y1 a
									WHERE a.Case_IDNO = e.Case_IDNO
									  -- 13570 End Validity Condition added	- Start
									  AND a.EndValidity_DATE = @Ld_High_DATE
									  -- 13570 End Validity Condition added	- End
									  AND a.StatusEnforce_CODE = @Lc_CaseStatusOpen_CODE )
					  AND ( e.StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE
							 OR ( e.CourtOrderIssuedOrg_DATE <= DATEADD(D, -45, @Ld_Run_DATE)
									AND e.Arrears_AMNT >= 3500
									-- 13160 - CR0347 License Suspension Changes - Start
									AND e.LastIdenPaymentReceived_DATE < DATEADD(D, -60, @Ld_Run_DATE)
									-- 13160 - CR0347 License Suspension Changes - End
									-- NCP is not in active chapter 13 bankruptcy
									AND (e.Bankruptcy13_INDC = @Lc_No_INDC
										  OR (	(e.Dismissed_DATE != @Ld_Low_DATE
													AND @Ld_Run_DATE > e.Dismissed_DATE)
											 OR (e.Discharge_DATE != @Ld_Low_DATE
													AND @Ld_Run_DATE > e.Discharge_DATE)
											)
										)
									AND e.Deceased_DATE = @Ld_Low_DATE
									AND ((e.Incarceration_DATE = @Ld_Low_DATE
											AND e.Institutionalized_DATE = @Ld_Low_DATE)
										  OR @Ld_Run_DATE > e.Released_DATE)
								 )
							)
					)
				)
				-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Ends
              /* Case is not Initiating interstate OR if the case is Initiating interstate the referral type is not 
              Registration for Modification only */
              AND (e.RespondInit_CODE = @Lc_RespondInitInstate_CODE
                    OR (e.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
						   AND NOT EXISTS(SELECT 1
											FROM ICAS_Y1 x
										   WHERE x.Case_IDNO = e.Case_IDNO
											 AND x.RespondInit_CODE = e.RespondInit_CODE
											 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
											 AND x.EndValidity_DATE=@Ld_High_DATE)))
			  -- 13718 - EMON - CR0431 License Suspension Updates - REMOVED -
			  AND NOT EXISTS (SELECT 1
                                  FROM DMJR_Y1 a
                                 WHERE a.Case_IDNO = e.Case_IDNO
                                   AND ( a.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
										 OR
										 ( a.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE, @Lc_ActivityMajorCpls_CODE)
											AND a.OthpSource_IDNO = p.OthpLicAgent_IDNO
											AND a.Reference_ID = p.LicenseNo_TEXT
											AND a.TypeReference_CODE = p.TypeLicense_CODE 
										  )
										)
                                   AND a.Status_CODE = @Lc_RemedyStatusStart_CODE)
                AND NOT EXISTS (SELECT 1
                                  FROM ELFC_Y1 a
                                 WHERE a.Case_IDNO = e.Case_IDNO
                                   AND a.Process_DATE = @Ld_High_DATE
                                     AND ( a.TypeChange_CODE = @Lc_TypeChangeCc_CODE
											OR
										   ( 
											 a.TypeChange_CODE IN (@Lc_TypeChangeLs_CODE, @Lc_TypeChangeCa_CODE)
												AND a.OthpSource_IDNO = p.OthpLicAgent_IDNO
												AND a.MemberMci_IDNO = e.NcpPf_IDNO
												AND a.Reference_ID = p.LicenseNo_TEXT
												AND a.TypeReference_CODE = p.TypeLicense_CODE
										   )
										  )
								 ) 
		  )  AS e;

   SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @@ROWCOUNT;

   COMMIT TRANSACTION ElfcDailyTran;

   BEGIN TRANSACTION ElfcDailyTran;

   SET @Ls_Sql_TEXT = 'IMIW - INCOME WITHHOLDING';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
			SELECT fci.NcpPf_IDNO,
                  fci.Case_IDNO,
                  fci.OrderSeq_NUMB,
                  @Lc_Job_ID AS Process_ID,
                  @Lc_TypeChangeIw_CODE AS TypeChange_CODE,
                  fci.OthpPartyEmpl_IDNO AS OthpSource_IDNO,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE,
                  @Ld_Run_DATE AS Create_DATE,
				  @Ld_High_DATE AS Process_DATE,
				  @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				  @Ld_System_DTTM AS Update_DTTM,
				  0 AS TransactionEventSeq_NUMB,
                  fci.CaseRelationship_CODE AS TypeReference_CODE,
                  CAST(fci.MemberMci_IDNO AS CHAR) AS Reference_ID
             FROM (SELECT a.NcpPf_IDNO,
                          a.Case_IDNO,
                          a.OrderSeq_NUMB,
                          e.OthpPartyEmpl_IDNO,
                          a.NcpPf_IDNO AS MemberMci_IDNO,
                          @Lc_CaseRelationshipNcp_CODE AS CaseRelationship_CODE
                     FROM ENSD_Y1 a
                     JOIN EHIS_Y1 e
                       ON a.NcpPf_IDNO = e.MemberMci_IDNO
                      AND e.Status_CODE IN (@Lc_StatusY_CODE,@Lc_StatusP_CODE)
                      AND e.EndEmployment_DATE > @Ld_Run_DATE
					  AND e.BeginEmployment_DATE <= @Ld_Run_DATE
                     JOIN OTHP_Y1 o
                       ON e.OthpPartyEmpl_IDNO = o.OtherParty_IDNO
                      AND o.EndValidity_DATE = @Ld_High_DATE
                    -- Open Case
                    WHERE a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          --	Case type is not Non IV-D Direct Pay (Allowed only for OX reason)
                          AND (	( a.TypeCase_CODE = @Lc_CaseTypeNonIvd_CODE 
									AND a.Iiwo_CODE IN (@Lc_IiwoC_CODE, @Lc_IiwoI_CODE)
									AND a.CaseCategory_CODE != @Lc_CaseCategoryDp_CODE
								) 
								-- Allowed for both reason OX and EW reason
								OR a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
							   )
                          -- Income Withholding Type is set to C - Court Ordered (I and S are not in the DSD, but asked the Manish to discuss with State and include)
                          AND ( a.Iiwo_CODE IN (@Lc_IiwoC_CODE, @Lc_IiwoI_CODE)
								OR
								-- Included for Initiated Income with holding.
								a.Iiwo_CODE IN (@Lc_IiwoN_CODE, @Lc_IiwoS_CODE,@Lc_IiwoA_CODE)
								  -- For cases with a charging obligation, arrears are equal to or greater than the amount of current support due for one month, including CS, MS, and SS. 
								  AND (	( a.CaseChargingArrears_CODE = @Lc_CaseCharging_CODE
											AND a.Arrears_AMNT >= a.Mso_AMNT
										)
									 -- For arrears only cases, a payback amount exists and no payment made to the case in the last 30 calendar days
					  				 OR ( a.CaseChargingArrears_CODE = @Lc_CaseArrearsOnly_CODE
					  						AND DATEADD(D, 30, a.LastIdenPaymentReceived_DATE) < @Ld_Run_DATE
					  						AND a.ExpectToPay_AMNT > 0
										)
									  )
								  -- The system date is equal to or greater than the court order issue date plus 45 calendar days
								  AND a.OrderIssued_DATE <= DATEADD(D, -45, @Ld_Run_DATE)
								)
                          -- Non voluntary orders
                          AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                          -- Active Support Order
                          AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                          -- Valid order for support/or arrears exist
                          AND (a.Mso_AMNT > 0
                                OR  ( a.ExpectToPay_AMNT > 0 AND a.FullArrears_AMNT > 0 ))
                          -- No CCPA limit (Commented as per mail communication with BAs)
                          AND e.LimitCcpa_INDC != @Lc_Yes_INDC
                          /* Case is not Initiating interstate OR if the case is Initiating interstate the referral type is not 
                          Registration for Modification only */
                          AND (a.RespondInit_CODE = @Lc_RespondInitInstate_CODE
                                OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
									   AND NOT EXISTS(SELECT 1
														FROM ICAS_Y1 x
													   WHERE x.Case_IDNO = a.Case_IDNO
														 AND x.RespondInit_CODE = a.RespondInit_CODE
														 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
														 AND x.EndValidity_DATE=@Ld_High_DATE)))
                          -- Case is not Exempt from enforcement
                          AND a.CaseExempt_INDC = @Lc_No_INDC
                          -- Case is not Exempt from IMIW
                          AND a.ImiwExempt_INDC = @Lc_No_INDC
                          -- Source Of Income Type as required
                          AND ((e.TypeIncome_CODE IN (@Lc_TypeIncomeEm_CODE, @Lc_TypeIncomeCs_CODE, @Lc_TypeIncomeMb_CODE, @Lc_TypeIncomeMl_CODE,
                                                      @Lc_TypeIncomeMr_CODE, @Lc_TypeIncomeRt_CODE, @Lc_TypeIncomeSe_CODE, @Lc_TypeIncomeSs_CODE,
                                                      @Lc_TypeIncomeUn_CODE, @Lc_TypeIncomeVp_CODE, @Lc_TypeIncomeWc_CODE))
                                OR (e.TypeIncome_CODE IN (@Lc_TypeIncomeUi_CODE, @Lc_TypeIncomeDs_CODE)
                                    AND o.State_ADDR != @Lc_StateInState_CODE)
                                OR (o.TypeOthp_CODE = @Lc_TypeOthpG_CODE
                                    AND o.PpaEiwn_INDC = @Lc_Yes_INDC))
                          AND EXISTS ( SELECT 1
										 FROM ACEN_Y1 c
										WHERE c.Case_IDNO = a.Case_IDNO
										  -- 13570 End Validity Condition added	- Start
										  AND c.EndValidity_DATE = @Ld_High_DATE
										  -- 13570 End Validity Condition added	- End
										  AND c.StatusEnforce_CODE = @Lc_CaseStatusOpen_CODE )
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 b
                                           WHERE b.Case_IDNO = a.Case_IDNO
                                             AND ( b.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
												OR ( b.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
													AND b.OthpSource_IDNO = e.OthpPartyEmpl_IDNO
													AND b.Reference_ID = CAST(a.NcpPf_IDNO AS CHAR) )
                                               )
                                             AND b.Status_CODE = @Lc_RemedyStatusStart_CODE)
                          AND NOT EXISTS (SELECT 1
                                          FROM ELFC_Y1 l
                                         WHERE l.Case_IDNO = a.Case_IDNO
                                           AND l.Process_DATE = @Ld_High_DATE
                                             AND ( l.TypeChange_CODE = @Lc_TypeChangeCc_CODE
													OR
												   ( 
													 l.TypeChange_CODE = @Lc_TypeChangeIw_CODE
													AND l.OthpSource_IDNO = e.OthpPartyEmpl_IDNO
													AND l.MemberMci_IDNO = a.NcpPf_IDNO
												   ))) ) AS fci;

   SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @@ROWCOUNT;

   COMMIT TRANSACTION ElfcDailyTran;

   BEGIN TRANSACTION ElfcDailyTran;

   SET @Ls_Sql_TEXT = 'NMSN - NATIONAL MEDICAL SUPPORT NOTICE';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
	SELECT fci.MemberMci_IDNO,
                  fci.Case_IDNO,
                  fci.OrderSeq_NUMB,
                  @Lc_Job_ID AS Process_ID,
                  @Lc_TypeChangeNm_CODE AS TypeChange_CODE,
                  fci.OthpPartyEmpl_IDNO AS OthpSource_IDNO,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE,
                  @Ld_Run_DATE AS Create_DATE,
				  @Ld_High_DATE AS Process_DATE,
				  @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				  @Ld_System_DTTM AS Update_DTTM,
				  0 AS TransactionEventSeq_NUMB,
				  fci.CaseRelationship_CODE AS TypeReference_CODE,
                  fci.Reference_ID
             FROM (SELECT m.MemberMci_IDNO,
                          a.Case_IDNO,
                          a.OrderSeq_NUMB,
                          e.OthpPartyEmpl_IDNO,
                          m.MemberMci_IDNO AS Reference_ID,
                          m.CaseRelationship_CODE
                     FROM ENSD_Y1 a
                          INNER JOIN CMEM_Y1 m
                           ON a.Case_IDNO = m.Case_IDNO
						     -- Case Member Status is active
                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          INNER JOIN EHIS_Y1 e
                           ON m.MemberMci_IDNO = e.MemberMci_IDNO
                           -- Confirmed Good Employer exists
							AND e.Status_CODE = @Lc_StatusY_CODE
						   -- Primary Employer for non-military employer and primary/secondary employers for military employer
							AND ( (e.TypeIncome_CODE != @Lc_TypeIncomeMl_CODE 
									AND e.EmployerPrime_INDC = @Lc_Yes_INDC)
                          			OR ( e.TypeIncome_CODE = @Lc_TypeIncomeMl_CODE
                          				 AND m.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
                          				) 	
                          	    )
							  AND e.EndEmployment_DATE > @Ld_Run_DATE
							  AND e.BeginEmployment_DATE <= @Ld_Run_DATE
                          INNER JOIN OTHP_Y1 o
                           ON e.OthpPartyEmpl_IDNO = o.OtherParty_IDNO
                              AND o.EndValidity_DATE = @Ld_High_DATE
                              -- 13558 - OTHP Insurance Provided Indicator considered for NMSN Check Eligibility - Start
                              AND o.InsuranceProvided_INDC = @Lc_Yes_INDC
                              -- 13558 - OTHP Insurance Provided Indicator considered for NMSN Check Eligibility - End
                    -- Open Case
                    WHERE a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          -- IV-D Case
                          AND a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                          -- Non Voluntary orders
                          AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                          -- Active support order
                          AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                          /* Case is not Initiating interstate OR if the case is Initiating interstate the referral type is not 
                          Registration for Modification only */
                          AND (a.RespondInit_CODE = @Lc_RespondInitInstate_CODE
                                OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
									   AND NOT EXISTS(SELECT 1
														FROM ICAS_Y1 x
													   WHERE x.Case_IDNO = a.Case_IDNO
														 AND x.RespondInit_CODE = a.RespondInit_CODE
														 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
														 AND x.EndValidity_DATE=@Ld_High_DATE)))
                          -- Medical Insurance is ordered
                          AND a.InsOrdered_CODE NOT IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
                          -- Case Member relation ship code is NCP, PF or CP
                          AND ( ( a.InsOrdered_CODE IN (@Lc_InsOrderedB_CODE, @Lc_InsOrderedD_CODE)
									AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipCp_CODE)  )
							 OR ( a.InsOrdered_CODE IN (@Lc_InsOrderedA_CODE, @Lc_InsOrderedU_CODE)
                                    AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE) )
                             OR ( a.InsOrdered_CODE IN (@Lc_InsOrderedC_CODE, @Lc_InsOrderedO_CODE)
                                    AND m.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE ))
						   -- Ordered party is not providing coverage to atleast one child on the order - should exists
						   AND EXISTS ( SELECT 1
											 FROM CMEM_Y1 dm, DEMO_Y1 do
											WHERE dm.Case_IDNO = a.Case_IDNO
											  AND dm.MemberMci_IDNO = do.MemberMci_IDNO
											  AND dm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
											  AND dm.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
											  AND (do.Emancipation_DATE IN (@Ld_Low_DATE, @Ld_High_DATE)
													OR do.Emancipation_DATE > @Ld_Run_DATE )
											  AND NOT EXISTS (SELECT 1
																FROM DINS_Y1 di
																JOIN MINS_Y1 mi
																  ON mi.MemberMci_IDNO = di.MemberMci_IDNO
															     AND mi.Status_CODE = @Lc_StatusCg_CODE
															     AND mi.EndValidity_DATE = @Ld_High_DATE
															     AND @Ld_Run_DATE BETWEEN mi.Begin_DATE AND mi.End_DATE
															     AND mi.OthpInsurance_IDNO = di.OthpInsurance_IDNO
																 AND mi.InsuranceGroupNo_TEXT = di.InsuranceGroupNo_TEXT
																 AND mi.PolicyInsNo_TEXT = di.PolicyInsNo_TEXT 
															   WHERE di.ChildMci_IDNO = dm.MemberMci_IDNO 
																 AND @Ld_Run_DATE BETWEEN di.Begin_DATE AND di.End_DATE
																 AND di.EndValidity_DATE = @Ld_High_DATE
																 AND (   ((a.CoverageMedical_CODE NOT IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																						AND di.MedicalIns_INDC = @Lc_Yes_INDC)
																				OR	(a.CoverageMedical_CODE IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.MedicalIns_INDC <> @Lc_Yes_INDC))
																		   AND (	(a.CoverageMental_CODE NOT IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.MentalIns_INDC = @Lc_Yes_INDC)
																				 OR
																					(a.CoverageMental_CODE IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.MentalIns_INDC <> @Lc_Yes_INDC)
																				)
																			AND (	(a.CoverageDental_CODE NOT IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.DentalIns_INDC = @Lc_Yes_INDC)
																				  OR
																					(a.CoverageDental_CODE IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.DentalIns_INDC <> @Lc_Yes_INDC)
																				)
																			AND (	(a.CoverageDrug_CODE NOT IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.PrescptIns_INDC = @Lc_Yes_INDC)
																				OR
																					(a.CoverageDrug_CODE IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.PrescptIns_INDC <> @Lc_Yes_INDC)
																				)
																			AND (	(a.CoverageVision_CODE NOT IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.VisionIns_INDC = @Lc_Yes_INDC)
																				 OR
																					(a.CoverageVision_CODE IN (@Lc_Space_TEXT, @Lc_InsOrderedN_CODE)
																					AND di.VisionIns_INDC <> @Lc_Yes_INDC)
																				)
																	 )
																  AND di.MemberMci_IDNO = (CASE WHEN a.InsOrdered_CODE IN (@Lc_InsOrderedB_CODE, @Lc_InsOrderedD_CODE)
																								THEN di.MemberMci_IDNO
																								ELSE m.MemberMci_IDNO
																							END)
															 )
										)
									 
                          -- Employer provides Insurance (Insurance available indicator)
                          AND e.InsProvider_INDC != @Lc_No_INDC
                          -- Employer providing insurance before the system date (Eligible coverage date is blank or <= system date)
                          AND e.EligCoverage_DATE <= @Ld_Run_DATE
                          -- Employer provides Insurance for the dependents (Dependent Coverage available indicator)
                          AND e.DpCoverageAvlb_INDC != @Lc_No_INDC
                          -- Reasonable Cost indicator is set
                          AND (e.InsReasonable_INDC = @Lc_Yes_INDC
                                OR (e.InsReasonable_INDC = @Lc_No_INDC
                                    AND a.InsOrdered_CODE IN (@Lc_InsOrderedD_CODE, @Lc_InsOrderedO_CODE, @Lc_InsOrderedU_CODE)))
                          -- No CCPA limit (Commented as per mail communication with BAs)
                          AND e.LimitCcpa_INDC != @Lc_Yes_INDC
                          -- Employement type is either pension plan or union or employer or the employer receives Electronic NMSN
                          AND (o.Enmsn_INDC != @Lc_Yes_INDC
                                OR (o.Enmsn_INDC = @Lc_Yes_INDC
                                    AND o.SendShort_INDC = @Lc_Yes_INDC))
                          -- Case is not Exempt from Enforcement
                          AND a.CaseExempt_INDC = @Lc_No_INDC
                          -- Case is not Exempt from NMSN
                          AND a.NmsnExempt_INDC = @Lc_No_INDC
                          AND EXISTS ( SELECT 1
										 FROM ACEN_Y1 c
										WHERE c.Case_IDNO = a.Case_IDNO
										  -- 13570 End Validity Condition added	- Start
										  AND c.EndValidity_DATE = @Ld_High_DATE
										  -- 13570 End Validity Condition added	- End
										  AND c.StatusEnforce_CODE = @Lc_CaseStatusOpen_CODE )
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 b
                                           WHERE b.Case_IDNO = a.Case_IDNO
                                             AND ( b.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
												OR ( b.ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
													AND b.Reference_ID = m.MemberMci_IDNO
													AND b.OthpSource_IDNO = e.OthpPartyEmpl_IDNO )
												) 
                                            AND b.Status_CODE = @Lc_RemedyStatusStart_CODE)
                          AND NOT EXISTS (SELECT 1
                                            FROM ELFC_Y1 b
                                           WHERE b.Case_IDNO = a.Case_IDNO
											  AND b.Process_DATE = @Ld_High_DATE
                                              AND ( b.TypeChange_CODE = @Lc_TypeChangeCc_CODE
													OR
												   ( 
													 b.TypeChange_CODE = @Lc_TypeChangeNm_CODE
													AND b.OthpSource_IDNO = e.OthpPartyEmpl_IDNO
													AND b.MemberMci_IDNO = a.NcpPf_IDNO
													AND b.TypeReference_CODE = m.CaseRelationship_CODE
													AND CAST(b.Reference_ID AS NUMERIC(10))				= m.MemberMci_IDNO
												   ))) ) AS fci;

   SET @Ln_TotalRecordCount_NUMB = @Ln_TotalRecordCount_NUMB + @@ROWCOUNT;

   COMMIT TRANSACTION ElfcDailyTran;
   
   --Update the daily_date field for this procedure in vparm table with the pd_dt_run value
   SET @Ls_Sql_TEXT = 'ELFC007 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))		= ''
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
      END
     ELSE
      SET @Ls_Sql_TEXT = 'ELFC008 : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_CursorLoc_TEXT = 'Total Record Count : ' + CAST( @Ln_TotalRecordCount_NUMB AS CHAR);

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_System_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Lc_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalRecordCount_NUMB;
  END TRY

  BEGIN CATCH
  
   --Rollback the Transaction 		
  
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ElfcDailyTran;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   --Check for Exception information to log the description text based on the error
   
   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_System_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Lc_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
