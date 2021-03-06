/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_WEEKLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_WEEKLY
Programmer Name		: IMP Team
Description			: This process reads records from ELFC_Y1 table and initiates/closes remedies based on the eligibility criteria.
Frequency			: 'WEEKLY'
Developed On		: 06/29/2011
Called BY			: None
Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_WEEKLY]
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Lc_StatusSuccess_CODE                       CHAR(1)			= 'S',
           @Lc_Space_TEXT                               CHAR(1)			= ' ',
           @Lc_Zero_TEXT								CHAR(1)			= '0',
           @Lc_StatusCaseOpen_CODE                      CHAR(1)			= 'O',
           @Lc_TypeCaseNonIvd_CODE                      CHAR(1)			= 'H',
           @Lc_TypeCasePaTanf_CODE						CHAR(1)			= 'A',
           @Lc_TypeCaseNonPa_CODE						CHAR(1)			= 'N',
           @Lc_TypeCaseIveFosterCare_CODE				CHAR(1)			= 'F',
		   @Lc_TypeCaseNonFederalFosterCare_CODE		CHAR(1)			= 'J',
           @Lc_RespondInitInstate_CODE                  CHAR(1)			= 'N',
           @Lc_OrderTypeVoluntary_CODE                  CHAR(1)			= 'V',
           @Lc_Yes_INDC                                 CHAR(1)			= 'Y',
           @Lc_No_INDC                                  CHAR(1)			= 'N',
           @Lc_StatusActive_CODE                        CHAR(1)			= 'A',
           @Lc_Percentage_TEXT                          CHAR(1)			= '%',
           @Lc_CaseMemberStatusActive_CODE              CHAR(1)			= 'A',
           @Lc_CaseRelationshipNcp_CODE                 CHAR(1)			= 'A',
           @Lc_CaseRelationshipPf_CODE                  CHAR(1)			= 'P',
           @Lc_CaseRelationshipDp_CODE                  CHAR(1)			= 'D',
           @Lc_StatusAbnormalend_CODE                   CHAR(1)			= 'A',
           @Lc_NegPosPositive_CODE                      CHAR(1)			= 'P',
           @Lc_RespondInitRespondingState_CODE          CHAR(1)			= 'R',
           @Lc_RespondInitRespondingTribal_CODE         CHAR(1)			= 'S',
           @Lc_RespondInitRespondingInternational_CODE  CHAR(1)			= 'Y',
           @Lc_StatusLocateNotLocated_CODE				CHAR(1)			= 'N',
           @Lc_InsOrderedNotOrdered_CODE				CHAR(1)			= 'N',
           @Lc_CaseCharging_CODE                        CHAR(1)			= 'C',
           @Lc_StatusConfirmedGood_CODE					CHAR(1)			= 'Y',
           @Lc_InStateFips_CODE                         CHAR(2)			= '10',
           @Lc_TypeChangeLt_CODE                        CHAR(2)			= 'LT',
           @Lc_TypeChangeRa_CODE                        CHAR(2)			= 'RA',
           @Lc_TypeChangeRn_CODE                        CHAR(2)			= 'RN',
           @Lc_TypeChangeRe_CODE                        CHAR(2)			= 'RE',
           @Lc_TypeChangeRm_CODE                        CHAR(2)			= 'RM',
           @Lc_TypeChangeLi_CODE                        CHAR(2)			= 'LI',
           @Lc_CaseCatgryMedonly_CODE                   CHAR(2)			= 'MO',
           @Lc_CaseCategoryFullServices_CODE			CHAR(2)			= 'FS',
           @Lc_EftrStatusActive_CODE                    CHAR(2)			= 'AC',
           @Lc_TypeChangeCc_CODE						CHAR(2)			= 'CC',
           @Lc_TypeChangeCl_CODE						CHAR(2)			= 'CL',
           @Lc_TypeChangeEm_CODE						CHAR(2)			= 'EM',
           @Lc_TypeChangeLo_CODE						CHAR(2)			= 'LO',
           @Lc_AssetIns_CODE							CHAR(3)			= 'INS',
           @Lc_RemedyStatusStart_CODE                   CHAR(4)			= 'STRT',
           @Lc_ActivityMajorLint_CODE                   CHAR(4)			= 'LINT',
           @Lc_ActivityMajorCclo_CODE                   CHAR(4)			= 'CCLO',
           @Lc_ActivityMajorEmnp_CODE                   CHAR(4)			= 'EMNP',
           @Lc_ActivityMajorObra_CODE                   CHAR(4)			= 'OBRA',
           @Lc_ActivityMajorMapp_CODE                   CHAR(4)			= 'MAPP',
           @Lc_ActivityMajorLien_CODE                   CHAR(4)			= 'LIEN',
           @Lc_ActivityMajorCsln_CODE                   CHAR(4)			= 'CSLN',
           @Lc_ActivityMinorLocaa_CODE					CHAR(5)			= 'LOCAA',
           @Lc_ReasonErfso_CODE                         CHAR(5)			= 'ERFSO',
           @Lc_ReasonErfsm_CODE                         CHAR(5)			= 'ERFSM',
           @Lc_ReasonErfss_CODE                         CHAR(5)			= 'ERFSS',
           @Lc_Job_ID                                   CHAR(7)			= 'DEB5410',
           @Lc_Successful_INDC                          CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT                        CHAR(30)		= 'BATCH',
           @Ls_Routine_TEXT                             VARCHAR(100)	= 'SP_PROCESS_CHECK_ELIGIBILITY_WEEKLY',
           @Ls_Package_NAME                             VARCHAR(100)	= 'BATCH_ENF_ELFC',
           @Ld_High_DATE                                DATE			= '12/31/9999',
           @Ld_Low_DATE                                 DATE			= '01/01/0001',
           @Ld_Start_DTTM                               DATETIME2		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_CommitFreqParm_QNTY						NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY				NUMERIC(5),
           @Ln_ErrorLine_NUMB							NUMERIC(10),
           @Ln_Error_NUMB								NUMERIC(10),
           @Ln_ObraCount_NUMB							NUMERIC(11)		= 0,
           @Ln_LintCount_NUMB							NUMERIC(11)		= 0,
           @Ln_LienCount_NUMB							NUMERIC(11)		= 0,
           @Ln_LocaaCount_NUMB							NUMERIC(11)		= 0,
           @Ln_TotalRecordCount_NUMB					NUMERIC(11)		= 0,
           @Lc_Msg_CODE									CHAR(1),
           @Ls_Sql_TEXT									VARCHAR(100),
           @Ls_SqlData_TEXT								VARCHAR(1000),
           @Ls_DescriptionError_TEXT					VARCHAR(4000),
           @Ld_Run_DATE									DATE,
           @Ld_LastRun_DATE								DATE;

  DECLARE @Ls_CursorLoc_TEXT VARCHAR(200);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job ID = ' + @Lc_Job_ID;

   -- Fetching date run, date last run, commit freq, exception threshold details
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CHECKING BATCH LAST RUN DATE';
   SET @Ls_SqlData_TEXT = 'Last Run Date = ' + ISNULL(CAST(@Ld_LastRun_DATE AS CHAR(10)), @Lc_Space_TEXT) + ', Run Date = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sql_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_SqlData_TEXT = @Ls_SqlData_TEXT;
     RAISERROR (50001,16,1);
    END

   
   BEGIN TRANSACTION ElfcWeeklyTran;

   SET @Ls_Sql_TEXT = 'INSERT ELFC_Y1 :- RA, RE, RM and RN Triggers for OBRA Activity';

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
          fci.TypeChange_CODE,
          fci.MemberMci_IDNO,
          fci.NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_Start_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB,--@Ln_TransactionEventSeq_NUMB, 
          @Lc_Space_TEXT AS TypeReference_CODE,
          @Lc_Space_TEXT AS Reference_ID
     FROM (SELECT a.MemberMci_IDNO,
                  a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.TypeChange_CODE,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE
             FROM (SELECT a.Case_IDNO,
                          a.OrderSeq_NUMB,
                          a.MemberMci_IDNO,
                          CASE
                           -- Current Assistance cases
                           WHEN a.TypeCase_CODE = @Lc_TypeCasePaTanf_CODE
                            THEN @Lc_TypeChangeRa_CODE
                           -- Foster Casre cases
                           WHEN a.TypeCase_CODE IN (@Lc_TypeCaseIveFosterCare_CODE, @Lc_TypeCaseNonFederalFosterCare_CODE)
                            THEN @Lc_TypeChangeRe_CODE
                           -- Medicaid only cases
                           WHEN a.TypeCase_CODE = @Lc_TypeCaseNonPa_CODE
                                AND a.CaseCategory_CODE = @Lc_CaseCatgryMedonly_CODE
                            THEN @Lc_TypeChangeRm_CODE
                           -- Case Type is Non Public Assistance
                           WHEN a.TypeCase_CODE = @Lc_TypeCaseNonPa_CODE
                                AND a.CaseCategory_CODE = @Lc_CaseCategoryFullServices_CODE
                                AND a.InsOrdered_CODE = @Lc_InsOrderedNotOrdered_CODE
                            THEN @Lc_TypeChangeRn_CODE
                          END AS TypeChange_CODE
                     FROM (SELECT a.Case_IDNO,
                                  a.OrderSeq_NUMB,
                                  a.NcpPf_IDNO AS MemberMci_IDNO,
                                  a.CaseCategory_CODE,
                                  a.TypeCase_CODE,
                                  s.InsOrdered_CODE
                             FROM ENSD_Y1 a
                                  INNER JOIN SORD_Y1 s
                                   ON a.Case_IDNO = s.Case_IDNO
                                      AND a.OrderSeq_NUMB = s.OrderSeq_NUMB
                                      AND s.EndValidity_DATE = @Ld_High_DATE
                            -- Open Case
                            WHERE a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                                  -- IV-D Case
                                  AND a.TypeCase_CODE != @Lc_TypeCaseNonIvd_CODE
                                  -- Charging Obligation
                                  AND a.CaseChargingArrears_CODE = @Lc_CaseCharging_CODE
                                  AND a.NcpPf_IDNO != 0
                                  -- Non Voluntary Orders
                                  AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                                  -- Active support order
                                  AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                                  /* Current System Date is 2 and half years from last court order date establishing child support 
                                  or modification of child support date or last review and adjust date */
                                  AND s.NextReview_DATE <= @Ld_Run_DATE
                                  -- DE has CEJ
                                  AND (a.CejFips_CODE LIKE ISNULL(@Lc_InStateFips_CODE, @Lc_Space_TEXT) + @Lc_Percentage_TEXT
                                       AND a.CejStatus_CODE = @Lc_StatusActive_CODE)
                                  -- At least one dependant is active on the Case and the value of the Date of Death field is null
                                  AND EXISTS (SELECT 1
                                                FROM DEMO_Y1 d
                                               WHERE d.MemberMci_IDNO IN (SELECT c.MemberMci_IDNO
                                                                            FROM CMEM_Y1 c
                                                                           WHERE c.Case_IDNO = a.Case_IDNO
                                                                             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                                             AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE)
                                                 AND d.Deceased_DATE = @Ld_Low_DATE)
                                  -- OBRA and CCLO chains are not in active mode
                                  AND NOT EXISTS (SELECT 1
                                                    FROM DMJR_Y1 j
                                                   WHERE j.Case_IDNO = a.Case_IDNO
                                                     AND (j.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                           OR j.OrderSeq_NUMB = 0)
                                                      AND (	  (j.OthpSource_IDNO = a.NcpPf_IDNO AND j.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE)
														   OR j.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
														 )
                                                     AND j.ActivityMajor_CODE IN (@Lc_ActivityMajorObra_CODE, @Lc_ActivityMajorCclo_CODE)
                                                     AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)
                                  -- No Active Case Closure amd EMAN chain NCP as a source
                                  AND NOT EXISTS (SELECT 1
                                                    FROM ELFC_Y1 b
                                                   WHERE b.Case_IDNO = a.Case_IDNO
                                                     AND (b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                           OR b.OrderSeq_NUMB = 0)
                                        			 AND (	  (b.MemberMci_IDNO = a.NcpPf_IDNO AND b.TypeChange_CODE = @Lc_TypeChangeEm_CODE)
														   OR b.TypeChange_CODE = @Lc_TypeChangeCc_CODE
														 )
                                                     AND b.TypeChange_CODE IN (@Lc_TypeChangeCc_CODE, @Lc_TypeChangeEm_CODE)
                                                     AND b.Process_DATE = @Ld_High_DATE)
                                  -- EMNP chain are not in active mode
                                  AND NOT EXISTS (SELECT 1
                                                    FROM DMJR_Y1 j
                                                   WHERE j.Case_IDNO = a.Case_IDNO
                                                     AND j.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                     AND j.MemberMci_IDNO = a.NcpPf_IDNO
                                                     AND j.ActivityMajor_CODE = @Lc_ActivityMajorEmnp_CODE
                                                     AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)
                                  -- MAPP chain with Reference Type as OBRA does not in active mode
                                  AND NOT EXISTS (SELECT 1
                                                    FROM DMJR_Y1 j
                                                   WHERE j.Case_IDNO = a.Case_IDNO
                                                     AND (j.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                           OR j.OrderSeq_NUMB = 0)
                                                     AND j.MemberMci_IDNO = a.NcpPf_IDNO
                                                     AND j.TypeReference_CODE = @Lc_ActivityMajorObra_CODE
                                                     AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                                     AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)) AS a) AS a
            WHERE a.TypeChange_CODE IS NOT NULL
           EXCEPT
           SELECT i.MemberMci_IDNO,
                  i.Case_IDNO,
                  i.OrderSeq_NUMB,
                  i.TypeChange_CODE,
                  i.NegPos_CODE
             FROM ELFC_Y1 i
            WHERE i.Process_DATE = @Ld_High_DATE
              AND i.TypeChange_CODE IN (@Lc_TypeChangeRa_CODE, @Lc_TypeChangeRe_CODE, @Lc_TypeChangeRm_CODE, @Lc_TypeChangeRn_CODE)) AS fci;

   SET @Ln_ObraCount_NUMB = @@ROWCOUNT;
   
   SET @Ls_Sql_TEXT = 'INSERT ELFC_Y1 :- LT Triggers for LINT Activity';

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
          fci.TypeChange_CODE,
          fci.MemberMci_IDNO,
          fci.NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_Start_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB,--@Ln_TransactionEventSeq_NUMB, 
          @Lc_Space_TEXT AS TypeReference_CODE,
          @Lc_Space_TEXT AS Reference_ID
     FROM (SELECT a.MemberMci_IDNO,
                  a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.TypeChange_CODE,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE
             FROM (SELECT a.Case_IDNO,
                          a.OrderSeq_NUMB,
                          a.NcpPf_IDNO AS MemberMci_IDNO,
                          @Lc_TypeChangeLt_CODE AS TypeChange_CODE
                     FROM ENSD_Y1 a
                    -- Open Case
                    WHERE a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                          -- IV-D Case
                          AND a.TypeCase_CODE != @Lc_TypeCaseNonIvd_CODE
                          AND a.NcpPf_IDNO != 0
						  -- Confirmed good primary SSN exists
						  AND a.NcpPfSsn_NUMB != 0
                          -- NCP is located
                          AND a.VerifiedNcpAddrExist_INDC = @Lc_Yes_INDC
						  -- CP is Located OR has Active Direct Deposit OR First State Family card
						  AND (		a.VerCpAddrExist_INDC = @Lc_Yes_INDC
								OR	EXISTS(SELECT 1
											 FROM EFTR_Y1
											WHERE CheckRecipient_ID = a.CpMci_IDNO
											  AND StatusEft_CODE = @Lc_EftrStatusActive_CODE
											  AND EndValidity_DATE = @Ld_High_DATE)
								OR	EXISTS(SELECT 1
											 FROM DCRS_Y1
											WHERE CheckRecipient_ID = a.CpMci_IDNO
											  AND Status_CODE = @Lc_StatusActive_CODE
											  AND EndValidity_DATE = @Ld_High_DATE)
							  )
                          -- Case is not exempt from enforcement
                          AND a.CaseExempt_INDC = @Lc_No_INDC
                          -- LINT remedy is not exempt
                          AND a.LintExempt_INDC = @Lc_No_INDC
                          -- Non voluntary order
                          AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                          -- Active support order
                          AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                          -- ARrears greater than or equal to 150 dollars
                          AND a.Arrears_AMNT >= 150
						  -- Arrears are greater than 1 month current support (Delinquent on one month obligation)
                          AND a.Arrears_AMNT > a.Mso_AMNT
                          AND EXISTS ( SELECT 1
										 FROM ACEN_Y1 c
										WHERE c.Case_IDNO = a.Case_IDNO
										  -- 13570 End Validity Condition added	- Start
										  AND c.EndValidity_DATE = @Ld_High_DATE
										  -- 13570 End Validity Condition added	- End
										  AND c.StatusEnforce_CODE = @Lc_StatusCaseOpen_CODE )
                          -- No Active Case Closure chain NCP as a source
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 e
                                           WHERE e.Case_IDNO = a.Case_IDNO
                                             AND e.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                             AND e.Status_CODE = @Lc_RemedyStatusStart_CODE)
                          -- No Active Case Closure chain NCP as a source
                          AND NOT EXISTS (SELECT 1
                                            FROM ELFC_Y1 b
                                           WHERE b.Case_IDNO = a.Case_IDNO
                                             AND b.TypeChange_CODE = @Lc_TypeChangeCc_CODE
                                             AND b.Process_DATE = @Ld_High_DATE)
                          -- LINT chain is not in active mode
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 j
                                           WHERE j.Case_IDNO = a.Case_IDNO
                                             AND j.OrderSeq_NUMB = a.OrderSeq_NUMB
                                             AND j.OthpSource_IDNO = a.NcpPf_IDNO
                                             AND j.ActivityMajor_CODE = @Lc_ActivityMajorLint_CODE
                                             AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)) AS a
            WHERE a.TypeChange_CODE IS NOT NULL
           EXCEPT
           SELECT i.MemberMci_IDNO,
                  i.Case_IDNO,
                  i.OrderSeq_NUMB,
                  i.TypeChange_CODE,
                  i.NegPos_CODE
             FROM ELFC_Y1 i
            WHERE i.Process_DATE = @Ld_High_DATE
              AND i.TypeChange_CODE = @Lc_TypeChangeLt_CODE) AS fci;

   SET @Ln_LintCount_NUMB = @@ROWCOUNT;
   
   SET @Ls_Sql_TEXT = 'INSERT ELFC_Y1 :- LI Triggers for LIEN Activity';

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
          fci.TypeChange_CODE,
          fci.OthpSource_IDNO,--fci.MemberMci_IDNO, 
          fci.NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_Start_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB,--@Ln_TransactionEventSeq_NUMB, 
          fci.TypeReference_CODE,--@Lc_Space_TEXT,
          fci.Reference_ID --@Lc_Space_TEXT
     FROM (SELECT a.MemberMci_IDNO,
                  a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.TypeChange_CODE,
                  a.OthpSource_IDNO,
                  a.TypeReference_CODE,
                  a.Reference_ID,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE
             FROM (SELECT a.Case_IDNO,
                          a.OrderSeq_NUMB,
                          a.NcpPf_IDNO AS MemberMci_IDNO,
                          @Lc_TypeChangeLi_CODE AS TypeChange_CODE,
                          f.OthpInsFin_IDNO AS OthpSource_IDNO,
                          f.Asset_CODE AS TypeReference_CODE,
                          f.AccountAssetNo_TEXT AS Reference_ID
                     FROM ENSD_Y1 a
                          INNER JOIN ASFN_Y1 f
                           ON a.NcpPf_IDNO = f.MemberMci_IDNO
                              AND f.Status_CODE = @Lc_StatusConfirmedGood_CODE
                              AND f.EndValidity_DATE =  @Ld_High_DATE
                              AND f.Asset_CODE = @Lc_AssetIns_CODE
                              --Not to initiate LIEN activity chain when no claim number exists
                              AND (f.AccountAssetNo_TEXT <> @Lc_Space_TEXT AND f.AccountAssetNo_TEXT <> @Lc_Zero_TEXT)
                    -- Open Case
                    WHERE a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                          -- IV-D Case
                          AND a.TypeCase_CODE != @Lc_TypeCaseNonIvd_CODE
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
                          AND a.NcpPf_IDNO != 0
                          -- Confirmed good primary SSN exists
                          AND a.NcpPfSsn_NUMB != 0
                          -- Non voluntary orders
                          AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                          -- Active support order
                          AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                          -- Arrears are greater than or equal to 500 dollars
                          AND a.ArrearsCsMs_AMNT >= 500
                          -- No voluntary payments received in the last 60 days
                          AND a.LastRegularPaymentReceived_DATE < DATEADD(D, -60, @Ld_Run_DATE)
                          -- System Date is greater than or equal to the initial support court order date plus 45 calendar days 
                          AND a.CourtOrderIssuedOrg_DATE < DATEADD(D, -45, @Ld_Run_DATE)
                          -- Case is not exempt from enforcement
                          AND a.CaseExempt_INDC = @Lc_No_INDC
                          -- LIEN remedy is not exempt
                          AND a.LienExempt_INDC = @Lc_No_INDC
                          -- Member is not in active chapter 13 bankruptcy
                          AND (a.Bankruptcy13_INDC = @Lc_No_INDC
                                OR (a.Bankruptcy13_INDC = @Lc_Yes_INDC
                                    AND ((a.Dismissed_DATE != @Ld_Low_DATE
                                          AND @Ld_Run_DATE > a.Dismissed_DATE)
                                          OR (a.Discharge_DATE != @Ld_Low_DATE
                                              AND @Ld_Run_DATE > a.Discharge_DATE))))
                          AND EXISTS ( SELECT 1
										 FROM ACEN_Y1 c
										WHERE c.Case_IDNO = a.Case_IDNO
										  -- 13570 End Validity Condition added	- Start
										  AND c.EndValidity_DATE = @Ld_High_DATE
										  -- 13570 End Validity Condition added	- End
										  AND c.StatusEnforce_CODE = @Lc_StatusCaseOpen_CODE )
                          -- LIEN and CSLN chain is not in active mode
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 D
                                           WHERE D.Case_IDNO = a.Case_IDNO
                                             AND D.OrderSeq_NUMB = a.OrderSeq_NUMB
                                             AND D.MemberMci_IDNO = a.NcpPf_IDNO
                                             AND D.OthpSource_IDNO = f.OthpInsFin_IDNO
                                             AND D.Reference_ID = f.AccountAssetNo_TEXT
                                             AND D.ActivityMajor_CODE IN (@Lc_ActivityMajorLien_CODE, @Lc_ActivityMajorCsln_CODE)
                                             AND D.Status_CODE = @Lc_RemedyStatusStart_CODE)
                          -- Case Closure chain is not in active mode
                          AND NOT EXISTS (SELECT 1
                                            FROM DMJR_Y1 j
                                           WHERE j.Case_IDNO = a.Case_IDNO
                                             AND j.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                             AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)
                          -- No Active Case Closure and CSLN chain NCP as a source
                          AND NOT EXISTS (SELECT 1
                                            FROM ELFC_Y1 b
                                           WHERE b.Case_IDNO = a.Case_IDNO
                                             AND (	 b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                  OR b.OrderSeq_NUMB = 0)
                                             AND (	 (b.MemberMci_IDNO = a.NcpPf_IDNO AND b.TypeChange_CODE = @Lc_TypeChangeCl_CODE)
											      OR b.TypeChange_CODE IN (@Lc_TypeChangeCc_CODE)
												 )
                                             AND b.Process_DATE = @Ld_High_DATE)) AS a
            WHERE a.TypeChange_CODE IS NOT NULL
           EXCEPT
           SELECT i.MemberMci_IDNO,
                  i.Case_IDNO,
                  i.OrderSeq_NUMB,
                  i.TypeChange_CODE,
                  i.OthpSource_IDNO,
                  i.TypeReference_CODE,
                  i.Reference_ID,
                  i.NegPos_CODE
             FROM ELFC_Y1 i
            WHERE i.Process_DATE = @Ld_High_DATE
              AND i.TypeChange_CODE = @Lc_TypeChangeLi_CODE) AS fci;

   SET @Ln_LienCount_NUMB = @@ROWCOUNT;
   
   SET @Ls_Sql_TEXT = 'INSERT ELFC_Y1 :- LO Triggers for LOCAA Alert';
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
   SELECT c.MemberMci_IDNO,
          c.Case_IDNO,
          a.OrderSeq_NUMB,
          @Lc_Job_ID AS Process_ID,
          @Lc_TypeChangeLo_CODE AS TypeChange_CODE,
          0 AS OthpSource_IDNO, 
          @Lc_NegPosPositive_CODE AS NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_Start_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB,
          @Lc_Space_TEXT AS TypeReference_CODE,
          @Lc_Space_TEXT AS Reference_ID
	 FROM ENSD_Y1 a 
	 JOIN CMEM_Y1 c
      ON c.Case_IDNO = a.Case_IDNO
     AND a.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE 
     AND a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPf_CODE)
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
	JOIN LSTT_Y1 l
	  ON l.MemberMci_IDNO = c.MemberMci_IDNO 
     AND l.EndValidity_DATE = @Ld_High_DATE
     AND l.StatusLocate_CODE = @Lc_StatusLocateNotLocated_CODE
   WHERE NOT EXISTS ( SELECT 1
					    FROM DMNR_Y1 d
					   WHERE d.Case_IDNO = c.Case_IDNO
					     AND d.ActivityMinor_CODE = @Lc_ActivityMinorLocaa_CODE
					     AND d.MemberMci_IDNO = c.MemberMci_IDNO
					     AND d.Entered_DATE > DATEADD(d,-60, @Ld_Run_DATE) )
	 AND NOT EXISTS ( SELECT 1
						 FROM ELFC_Y1 e
						WHERE e.Case_IDNO = c.Case_IDNO
						  AND e.MemberMci_IDNO = c.MemberMci_IDNO
						  AND e.TypeChange_CODE = @Lc_TypeChangeLo_CODE
						  AND e.Process_DATE = @Ld_High_DATE );
					    
	SET @Ln_LocaaCount_NUMB = @@ROWCOUNT;				    

   COMMIT TRANSACTION ElfcWeeklyTran;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT) + ', Run DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR (50001,16,1);
    END

	/*Record Count*/
	SET @Ln_TotalRecordCount_NUMB = ISNULL(@Ln_ObraCount_NUMB,0) 
								  + ISNULL(@Ln_LintCount_NUMB,0)  
								  + ISNULL(@Ln_LienCount_NUMB,0)
								  + ISNULL(@Ln_LocaaCount_NUMB,0); 

   SET @Ls_CursorLoc_TEXT = ' OBRA : ' + CAST(ISNULL(@Ln_ObraCount_NUMB,0) AS VARCHAR)
						  + ' LINT : ' + CAST(ISNULL(@Ln_LintCount_NUMB,0) AS VARCHAR)
						  + ' LIEN : ' + CAST(ISNULL(@Ln_LienCount_NUMB,0) AS VARCHAR)
						  + ' LOCAA : ' + CAST(ISNULL(@Ln_LocaaCount_NUMB,0) AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
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
     ROLLBACK TRANSACTION ElfcWeeklyTran;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   --Check for Exception information to log the description text based on the error
   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
