/****** Object:  StoredProcedure [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_CASE_CLOSURE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_CASE_CLOSURE]
 @An_Thread_NUMB NUMERIC(15, 0)
AS
 /*--------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_CASE_CLOSURE
 Programmer Name	: IMP Team
 Description		: The process SP_PROCESS_CASE_CLOSURE is to identify all cases that are eligible for case closure
                        and insert a record into VELFC to initiate the Case Closure Activity Chain.	
 Frequency			: 'DAILY'
 Developed On		: 04/06/2011
 Called BY			: BATCH_COMMON$SP_INSERT_ELFC
 Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK, BATCH_COMMON$SP_GET_THREAD_DETAILS,
					  BATCH_COMMON$SP_INSERT_ELFC, BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG, BATCH_COMMON$SP_BATE_LOG
					  and BATCH_COMMON$SP_BSTL_LOG.
 --------------------------------------------------------------------------------------------------------------------
 Modified BY		:
 Modified On		:
 Version No			: 1.0
 --------------------------------------------------------------------------------------------------------------------*/
 BEGIN
 
  CREATE TABLE #CaseClosureReason_P1
  (
    Case_IDNO        NUMERIC(6),
    MajorIntSeq_NUMB NUMERIC(5),
    Reference_ID     CHAR(30)
  );
  
  SET NOCOUNT ON;

  DECLARE  @Li_Error_NUMB									INT				= NULL,
           @Li_ErrorLine_NUMB								INT				= NULL,
           @Lc_Yes_INDC										CHAR(1)			= 'Y',
           @Lc_StatusAbnormalend_CODE						CHAR(1)			= 'A',
           @Lc_No_INDC										CHAR(1)			= 'N',
           @Lc_StatusFailed_CODE							CHAR(1)			= 'F',
           @Lc_StatusSuccess_CODE							CHAR(1)			= 'S',
           @Lc_TypeErrorE_CODE								CHAR(1)			= 'E',
           @Lc_Space_TEXT									CHAR(1)			= ' ',
           @Lc_RespondInitResponding_CODE					CHAR(1)			= 'R',
           @Lc_RespondInitRespondingTribal_CODE				CHAR(1)			= 'S',
		   @Lc_RespondInitRespondingInternational_CODE		CHAR(1)			= 'Y',
           @Lc_NegPosStartRemedy_CODE						CHAR(1)			= 'P',
           @Lc_CaseMemberStatusActive_CODE					CHAR(1)			= 'A',
           @Lc_CaseRelationshipNCP_CODE						CHAR(1)			= 'A',
           @Lc_CaseRelationshipPF_CODE						CHAR(1)			= 'P',
           @Lc_ErrorTypeInformation_CODE					CHAR(1)			= 'I',
           @Lc_GoodCauseApproved_CODE						CHAR(1)			= 'A',
           @Lc_TypeCaseNonPa_CODE							CHAR(1)			= 'N',
           @Lc_IndnCoop_CODE								CHAR(1)			= 'N',
           @Lc_ThreadLocked_INDC							CHAR(1)			= 'L',
           @Lc_CaseTypeNonFederalFosterCare_CODE			CHAR(1)			= 'J',
           @Lc_CaseTypeNonIvd_CODE							CHAR(1)			= 'H',
           @Lc_ReasonStatusPb_CODE							CHAR(2)			= 'PB',
           @Lc_ReasonStatusFn_CODE							CHAR(2)			= 'FN',
           @Lc_ReasonStatusPc_CODE							CHAR(2)			= 'PC',
           @Lc_ReasonStatusPk_CODE							CHAR(2)			= 'PK',
           @Lc_ReasonStatusUc_CODE							CHAR(2)			= 'UC',
           @Lc_ReasonStatusUb_CODE							CHAR(2)			= 'UB',
           @Lc_ReasonStatusIk_CODE							CHAR(2)			= 'IK',
           @Lc_ReasonStatusGv_CODE							CHAR(2)			= 'GV',
           @Lc_ReasonStatusUv_CODE							CHAR(2)			= 'UV',
           @Lc_ReasonStatusDi_CODE							CHAR(2)			= 'DI',
           @Lc_ReasonStatusNh_CODE							CHAR(2)			= 'NH',
           @Lc_ReasonStatusIi_CODE							CHAR(2)			= 'II',
           @Lc_TypeChangeCc_CODE							CHAR(2)			= 'CC',
           @Lc_ReasonStatusPq_CODE							CHAR(2)			= 'PQ',
           @Lc_ReasonStatusDd_CODE							CHAR(2)			= 'DD',
           @Lc_ReasonStatusPa_CODE							CHAR(2)			= 'PA',
           @Lc_ActivityMajorCCLO_CODE						CHAR(4)			= 'CCLO',
           @Lc_RemedyStatusComplete_CODE					CHAR(4)			= 'COMP',
           @Lc_ActivityMinorAwjda_CODE						CHAR(5)			= 'AWJDA',
           @Lc_ActivityMinorWorev_CODE						CHAR(5)			= 'WOREV',
           @Lc_ActivityMinorRsacc_CODE						CHAR(5)			= 'RSACC',
           @Lc_ErrorE0944_CODE								CHAR(5)			= 'E0944',
           @Lc_Job_ID										CHAR(7)			= 'DEB5270',
           @Lc_JobCclr_ID									CHAR(7)			= 'DEB5440',
           @Lc_Successful_TEXT								CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_ID								CHAR(30)		= 'BATCH',
           @Lc_Parmdateproblem_TEXT							CHAR(30)		= 'PARM DATE PROBLEM',
           @Lc_Proc_NAME									CHAR(30)		= 'BATCH_CM_CASE_CLOSURE_ELIG',
           @Ls_Procedure_Name								CHAR(30)		= 'SP_PROCESS_CASE_CLOSURE',
           @Ls_Process_NAME									VARCHAR(100)	= 'BATCH_CM_CASE_CLOSURE_ELIG',
           @Ls_Temp_TEXT									VARCHAR(4000),
           @Ld_Low_DATE										DATE			= '01/01/0001';
           
  DECLARE  @Ln_Exception_INDC								NUMERIC(2)		= 0,
           @Ln_CommitFreqParm_QNTY							NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY					NUMERIC(5),
           @Ln_ExceptionThreshold_QNTY						NUMERIC(5),
           @Ln_CommitFreq_QNTY								NUMERIC(5)		= 0,
           @Ln_NcpDeceased_QNTY								NUMERIC(5)		= 0,
           @Ln_Cursor_QNTY									NUMERIC(10)		= 0,
           @Ln_CaseEligible_NUMB							NUMERIC(10)		= 0,
           @Ln_IndEligibleCc_NUMB							NUMERIC(10),
           @Ln_RowCount_QNTY								NUMERIC(11)		= 0,
           @Ln_TmpUpdate_QNTY								NUMERIC(11,2),
           @Ln_RecStart_NUMB								NUMERIC(15),
           @Ln_RecRestart_NUMB								NUMERIC(15),
           @Ln_RecEnd_NUMB									NUMERIC(15),
           @Ln_ParamCaseclosureCurAsInRecStart_NUMB			NUMERIC(15),
           @Ln_Record_NUMB									NUMERIC(15),
           @Ln_ParamCaseclosureCurAsInRecEnd_NUMB			NUMERIC(15),
           @Ln_TransactionEventSeq_NUMB						NUMERIC(19),
           @Li_FetchStatus_BIT								SMALLINT,
           @Li_Zero_NUMB									SMALLINT,
           @Lc_CaseClosureReason_CODE						CHAR(2),
           @Lc_Msg_CODE										CHAR(3),
           @Ls_Sql_TEXT										VARCHAR(100),
           @Ls_CursorLoc_TEXT								VARCHAR(200),
           @Ls_RestartKey_TEXT								VARCHAR(200),
           @Ls_Sqldata_TEXT									VARCHAR(1000),
           @Ls_DescriptionError_TEXT						VARCHAR(4000),
           @Ls_DescriptionException_TEXT					VARCHAR(4000),
           @Ld_RunParm_DATE									DATE,
           @Ld_LastRunParm_DATE								DATETIME2,
           @Ld_RunLess1Year_DATE							DATETIME2,
           @Ld_Start_DATE									DATETIME2;

  DECLARE  @Ln_CaseCloseCUR_OrderSeq_NUMB					NUMERIC(5)			= 0,
		   @Ln_CaseCloseCUR_RowNumber_NUMB					NUMERIC(15, 2), 
		   @Ln_CaseCloseCUR_Case_IDNO						NUMERIC(6),
		   @Ln_CaseCloseCUR_MemberMci_IDNO					NUMERIC(10),
		   @Lc_CaseCloseCUR_RespondInit_CODE				CHAR(1),
		   @Lc_CaseCloseCUR_NonCoop_CODE					CHAR(1),
		   @Lc_CaseCloseCUR_GoodCause_CODE					CHAR(1),
		   @Lc_CaseCloseCUR_TypeCase_CODE					CHAR(1) ,
		   @Lc_CaseCloseCUR_RsnStatusCase_CODE				CHAR(2),
		   @Lc_CaseCloseCUR_Process_INDC					CHAR(1)				= '',
		   @Ld_CaseCloseCUR_Deceased_DATE					DATETIME2;
		   

  BEGIN TRY
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ln_ExceptionThreshold_QNTY = 0;
   SET @Li_Zero_NUMB = 0;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' JOB_ID = ' + ISNULL(@Lc_Job_ID,'');
   
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_RunParm_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRunParm_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ln_Exception_INDC = 1;

     RAISERROR(50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRunParm_DATE) > @Ld_RunParm_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_Parmdateproblem_TEXT;
     SET @Ln_Exception_INDC = 1;

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '') + ', Job_ID = ' + ISNULL(@Lc_JobCclr_ID, '');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_RunParm_DATE,
    @Ac_Job_ID                = @Lc_JobCclr_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'CCLRPRE : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '') + ', Job_ID = ' + ISNULL(@Lc_JobCclr_ID, '');
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_GET_THREAD_DETAILS CCLRGETTHRD';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '') + ', Thread_NUMB = ' + CAST(@An_Thread_NUMB AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_GET_THREAD_DETAILS
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_RunParm_DATE,
    @An_Thread_NUMB           = @An_Thread_NUMB,
    @An_RecRestart_NUMB       = @Ln_RecRestart_NUMB OUTPUT,
    @An_RecEnd_NUMB           = @Ln_RecEnd_NUMB OUTPUT,
    @An_RecStart_NUMB         = @Ln_RecStart_NUMB OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'CCLRGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS FAILED';
	 SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '') + ', Thread_NUMB = ' + CAST(@An_Thread_NUMB AS VARCHAR);
	 
     RAISERROR(50001,16,1);
    END

   SET @Ld_RunLess1Year_DATE = DATEADD(m, -12, @Ld_RunParm_DATE);
   SET @Ln_ParamCaseclosureCurAsInRecStart_NUMB = @Ln_RecRestart_NUMB;
   SET @Ln_ParamCaseclosureCurAsInRecEnd_NUMB = @Ln_RecEnd_NUMB;

   BEGIN TRANSACTION Case_Closure_Main_Transaction;

   DECLARE CaseClose_CUR INSENSITIVE CURSOR FOR
    SELECT p.RecordRowNumber_NUMB,
           p.Case_IDNO,
           p.MemberMci_IDNO,
           p.RespondInit_CODE,
           p.Deceased_DATE,
           p.RsnStatusCase_CODE,
           p.NonCoop_CODE,
           p.GoodCause_CODE,
           p.TypeCase_CODE,
           p.OrderSeq_NUMB,
           p.Process_INDC
      FROM PCCLR_Y1 p
     WHERE p.RecordRowNumber_NUMB >= @Ln_ParamCaseclosureCurAsInRecStart_NUMB
       AND p.RecordRowNumber_NUMB <= @Ln_ParamCaseclosureCurAsInRecEnd_NUMB
       AND p.Process_INDC = @Lc_No_INDC
     ORDER BY p.RecordRowNumber_NUMB;

   INSERT INTO #CaseClosureReason_P1
     (	Case_IDNO,
		MajorIntSeq_NUMB,
		Reference_ID)
   SELECT a.Case_IDNO,
          a.MajorIntSeq_NUMB,
          a.Reference_ID
     FROM DMJR_Y1 a
    WHERE a.Status_CODE = @Lc_RemedyStatusComplete_CODE
      AND a.ActivityMajor_CODE = @Lc_ActivityMajorCCLO_CODE
      AND a.Status_DATE >= DATEADD(D, -90, @Ld_RunParm_DATE)
      AND EXISTS (SELECT 1
                    FROM DMNR_Y1 b
                   WHERE b.Case_IDNO = a.Case_IDNO
                     AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                     AND b.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
                     AND b.ActivityMinor_CODE IN (@Lc_ActivityMinorWorev_CODE, @Lc_ActivityMinorAwjda_CODE, @Lc_ActivityMinorRsacc_CODE)
                     AND b.ReasonStatus_CODE = @Lc_ReasonStatusDd_CODE);

   OPEN CaseClose_CUR;

   BEGIN
    FETCH NEXT FROM CaseClose_CUR INTO @Ln_CaseCloseCUR_RowNumber_NUMB, @Ln_CaseCloseCUR_Case_IDNO, @Ln_CaseCloseCUR_MemberMci_IDNO, @Lc_CaseCloseCUR_RespondInit_CODE, @Ld_CaseCloseCUR_Deceased_DATE, @Lc_CaseCloseCUR_RsnStatusCase_CODE, @Lc_CaseCloseCUR_NonCoop_CODE, @Lc_CaseCloseCUR_GoodCause_CODE, @Lc_CaseCloseCUR_TypeCase_CODE, @Ln_CaseCloseCUR_OrderSeq_NUMB, @Lc_CaseCloseCUR_Process_INDC;

    SET @Li_FetchStatus_BIT = @@FETCH_STATUS;

	/*CaseClose_CUR cursor count*/
    WHILE @Li_FetchStatus_BIT = 0
     BEGIN
	  BEGIN TRY
	  SAVE TRANSACTION Case_Closure_Cursor_Transaction;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLoc_TEXT = 'CASE CLOSURE - CURSOR_COUNT - ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR(200)), '');
      SET @Ln_Record_NUMB = @Ln_CaseCloseCUR_RowNumber_NUMB;
      
      SET @Ls_RestartKey_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_CaseCloseCUR_OrderSeq_NUMB AS VARCHAR(5)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_MemberMci_IDNO AS VARCHAR(10)), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_CaseCloseCUR_TypeCase_CODE, '');
      SET @Lc_CaseClosureReason_CODE = @Lc_Space_TEXT;
      SET @Ln_IndEligibleCc_NUMB = 0;
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_NO_ORDER_NCP_DECEASED';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --NCP OR PUTATIVE FATHER IS DECEASED – Order-- .
        ---- Ncp Deceased Count, if the system date is one year after the date of death for the last or only Active NCP or Putative Father on the case----
	  SELECT @Ln_NcpDeceased_QNTY = COUNT(1)
		FROM DEMO_Y1 AS g
	   WHERE g.MemberMci_IDNO IN (SELECT MemberMci_IDNO 
									 FROM CMEM_Y1 c 
									WHERE c.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO 
									  AND c.CaseRelationship_CODE in (@Lc_CaseRelationshipNCP_CODE,@Lc_CaseRelationshipPF_CODE)
									  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
		 AND ((g.Deceased_DATE <> @Ld_Low_DATE AND g.Deceased_DATE > @Ld_RunLess1Year_DATE) OR g.Deceased_DATE = @Ld_Low_DATE);
		 
      IF @Ln_IndEligibleCc_NUMB = 0
		 AND @Ln_CaseCloseCUR_OrderSeq_NUMB <> 0
		 AND @Ln_NcpDeceased_QNTY = 0
        
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusPb_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 1';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
	  
	   BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

	  SET @Ls_Sql_TEXT = 'NO ACTIVE ORDER AND NCP IS DECEASED MORE THAN ONE YEAR';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');
		
      --NCP OR PUTATIVE FATHER IS DECEASED – No Order
      --select the case as eligible for closure in the next batch run, if the last or only Active NCP or Putative Father on the case is deceased
      SELECT @Ln_NcpDeceased_QNTY = COUNT(1)
		FROM DEMO_Y1 AS g
	   WHERE g.MemberMci_IDNO IN (SELECT MemberMci_IDNO 
									 FROM CMEM_Y1 c 
									WHERE c.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO 
									  AND c.CaseRelationship_CODE in (@Lc_CaseRelationshipNCP_CODE,@Lc_CaseRelationshipPF_CODE)
									  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
		 AND ((g.Deceased_DATE <> @Ld_Low_DATE AND g.Deceased_DATE > @Ld_RunParm_DATE) OR g.Deceased_DATE = @Ld_Low_DATE);
		 
      IF @Ln_IndEligibleCc_NUMB = 0
         AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0
         AND @Ln_NcpDeceased_QNTY = 0
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusFn_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 2';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');
	
      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      SET @Ls_Sql_TEXT = 'GOOD CAUSE DETERMINATION- IV-D AGENCY CANNOT PROCEED';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --Good Cause Determination- IV-D Agency Cannot Proceed
      IF @Ln_IndEligibleCc_NUMB = 0
         AND @Lc_CaseCloseCUR_GoodCause_CODE = @Lc_GoodCauseApproved_CODE
         AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusGv_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 3';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      --Include the cases for which the NCP not located within three years.
      ---TODO: Need to discuss the Locate status condition
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_NCP_NOT_LOCATED';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      IF @Ln_IndEligibleCc_NUMB = 0 
		 AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0 
         AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_NCP_NOT_LOCATED (@Ln_CaseCloseCUR_Case_IDNO, @Ld_RunParm_DATE)			= @Lc_Yes_INDC
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusUb_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 4';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
	  --SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	  --   IF @Ln_RowCount_QNTY > 0
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      --Include all the cases when the Initiating State has failed to take a necessary action using the following conditions.
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_INITI_STATE_FAILED ';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      IF @Lc_CaseCloseCUR_RespondInit_CODE IN(@Lc_RespondInitResponding_CODE,@Lc_RespondInitRespondingTribal_CODE,@Lc_RespondInitRespondingInternational_CODE)
       BEGIN
        IF @Ln_IndEligibleCc_NUMB = 0
           AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_INITI_STATE_FAILED (@Ln_CaseCloseCUR_Case_IDNO, @Ld_RunParm_DATE)= @Lc_Yes_INDC
         BEGIN
          SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusIi_CODE;
          SET @Ln_IndEligibleCc_NUMB = 1;
         END
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 5';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)

       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      /*Include all the cases as eligible for case closure which are no currently charging
           Child Support or Medical Support and arrears is greater than zero and under $500.00
           and there are no payments in 1 years.*/
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_ARREARS_LESS_500';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_Case_IDNO AS VARCHAR(6)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_MemberMci_IDNO AS VARCHAR(10)), '') + ', PD_DT_RUN = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(20)), '');

      IF @Ln_IndEligibleCc_NUMB = 0
         AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_ARREARS_LESS_500 (@Ln_CaseCloseCUR_Case_IDNO, @Ln_CaseCloseCUR_MemberMci_IDNO, @Ld_RunParm_DATE)			= @Lc_Yes_INDC
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusNh_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 6';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)

       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      --Include the cases which has the last or the only child is 23 years old and Paternity is not established
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CHILD_PATER_NOT_EST';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      IF @Ln_IndEligibleCc_NUMB = 0 
         AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0
         AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CHILD_PATER_NOT_EST (@Ln_CaseCloseCUR_Case_IDNO, @Ld_RunParm_DATE)			= @Lc_Yes_INDC
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusPc_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 7';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)

	   BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      --Include the cases for which the Paternity can not be established since Putative Father was excluded by Genetic Testing
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_PF_EXCLUDED';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      IF @Ln_IndEligibleCc_NUMB = 0 
         AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_PF_EXCLUDED (@Ln_CaseCloseCUR_Case_IDNO, @Ln_CaseCloseCUR_MemberMci_IDNO)			= @Lc_Yes_INDC
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusPk_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 8';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 9';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 10';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      --Include the case when One year has passed since case was created and NCP has no confirmed DOB or SSN or Address or employer
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_NCP_NO_CONFIRMED';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      IF @Ln_IndEligibleCc_NUMB = 0
		 AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0 
		 AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_NCP_NO_CONFIRMED (@Ln_CaseCloseCUR_Case_IDNO, @Ln_CaseCloseCUR_MemberMci_IDNO, @Ld_RunParm_DATE)			= @Lc_Yes_INDC
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusUc_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 11';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
	   BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      --NON-TANF CP has an unverified residential and mailing address and employer address for 60 days and no support order exists 
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CP_ADDRESS_UNVERIFIED';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      IF @Ln_IndEligibleCc_NUMB = 0
		 AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0 
         AND @Lc_CaseCloseCUR_TypeCase_CODE = @Lc_TypeCaseNonPa_CODE
         AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CP_ADDRESS_UNVERIFIED (@Ln_CaseCloseCUR_Case_IDNO, @Ld_RunParm_DATE)= @Lc_Yes_INDC
       BEGIN
        SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusUv_CODE;
        SET @Ln_IndEligibleCc_NUMB = 1;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 12';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
	   BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      SET @Ls_Sql_TEXT = 'ELIGIBLITY FOR 90 DAYS 13';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

      --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

	 SELECT @Ln_CaseEligible_NUMB = COUNT(1)
			FROM CASE_Y1 AS a
		WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
		  AND a.Opened_DATE < @Ld_RunLess1Year_DATE
     
     ----Paternity - Biological Father is Unknown
     /*No Support Order, NCP/Putative Father MCI is equal to 0000999995 (Unknown), 
		Member Status Reason field on CCRT is equal to ‘U-Member Unidentified’, and one (1) year has passed since case creation*/
	 IF @Ln_IndEligibleCc_NUMB = 0
		AND @Ln_CaseCloseCUR_OrderSeq_NUMB = 0
		AND EXISTS (SELECT 1 
					 FROM CMEM_Y1 c 
					WHERE c.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO 
					  AND c.MemberMci_IDNO = 999995	
					  AND c.CaseRelationship_CODE in (@Lc_CaseRelationshipNCP_CODE,@Lc_CaseRelationshipPF_CODE)
					  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
					  AND NOT EXISTS (SELECT 1 
									FROM CMEM_Y1 m
								   WHERE m.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
									 AND m.CaseRelationship_CODE in (@Lc_CaseRelationshipNCP_CODE,@Lc_CaseRelationshipPF_CODE)
									 AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
									 AND m.MemberMci_IDNO != c.MemberMci_IDNO ))
		AND @Ln_CaseEligible_NUMB > 0 
		BEGIN
			SET @Lc_CaseClosureReason_CODE = @Lc_ReasonStatusPq_CODE;
			SET @Ln_IndEligibleCc_NUMB = 1;
		END
		
	 --- The case will NOT be selected as eligible for closure for the same closure reason for at least 90 days
      IF EXISTS(SELECT 1
        FROM #CaseClosureReason_P1 a
       WHERE a.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO
         AND a.Reference_ID = @Lc_CaseClosureReason_CODE)		
		BEGIN
			SET @Ln_IndEligibleCc_NUMB = 0;
		END         

      /*sf_check_crec_elig_case_close function is used below to check before closing any case
      whether any open POFL_Y1 (CREC) balance exists or not. If VPOFL cp recoupment balance exists for
      CP of the case involved only in one case, then  sf_check_crec_elig_case_close function return
      'N' to not to allow case closure */
      SET @Ls_Sql_TEXT = 'BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CREC_ELIG_CASE_CLOSE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_Case_IDNO AS VARCHAR(6)), '');

      IF @Ln_IndEligibleCc_NUMB = 1
         AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_CHECK_CREC_ELIG_CASE_CLOSE (@Ln_CaseCloseCUR_Case_IDNO)			= @Lc_Yes_INDC
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 1;
       END
      ELSE
       BEGIN
        SET @Ln_IndEligibleCc_NUMB = 0;
       END

      IF @Ln_IndEligibleCc_NUMB <> 0
       BEGIN
        -- Newly generated seq_txn_event will be used in ELFC insert
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
	    SET @Ls_Sqldata_TEXT = 'User_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '') + ', Note_INDC = ' + @Lc_No_INDC + ', EventFunctionalSeq_NUMB = ' +  CAST(@Li_Zero_NUMB AS VARCHAR);

        EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_ID,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_RunParm_DATE,
         @Ac_Note_INDC                = @Lc_No_INDC,
         @An_EventFunctionalSeq_NUMB  = @Li_Zero_NUMB,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ln_Exception_INDC = 1;

          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_INSERT_ELFC';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_CaseCloseCUR_OrderSeq_NUMB AS VARCHAR(5)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseCloseCUR_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + CAST(@Li_Zero_NUMB AS VARCHAR) + ', TypeChange_CODE = ' + @Lc_TypeChangeCc_CODE + ', NegPos_CODE = ' + ISNULL(@Lc_NegPosStartRemedy_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Create_DATE = ' + CAST(@Ld_RunParm_DATE AS VARCHAR(10)) + ', Reference_ID = ' + @Lc_CaseClosureReason_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', WorkerUpdate_ID = ' + @Lc_BatchRunUser_ID;

		IF @Ln_CaseCloseCUR_MemberMci_IDNO = 0
			BEGIN
				SELECT TOP 1 @Ln_CaseCloseCUR_MemberMci_IDNO =  MemberMci_IDNO 
					FROM CMEM_Y1 c 
					WHERE c.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO 
					  AND c.MemberMci_IDNO	<> 0000999995
					  AND c.CaseRelationship_CODE in (@Lc_CaseRelationshipNCP_CODE,@Lc_CaseRelationshipPF_CODE)
					  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
			END
			
		IF @Ln_CaseCloseCUR_MemberMci_IDNO = 0 OR @Ln_CaseCloseCUR_MemberMci_IDNO IS NULL 
			BEGIN
				SELECT TOP 1 @Ln_CaseCloseCUR_MemberMci_IDNO =  MemberMci_IDNO 
					FROM CMEM_Y1 c 
					WHERE c.Case_IDNO = @Ln_CaseCloseCUR_Case_IDNO 
					  AND c.MemberMci_IDNO	= 0000999995
					  AND c.CaseRelationship_CODE in (@Lc_CaseRelationshipNCP_CODE,@Lc_CaseRelationshipPF_CODE)
					  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
			END

        EXECUTE BATCH_COMMON$SP_INSERT_ELFC
         @An_Case_IDNO                = @Ln_CaseCloseCUR_Case_IDNO,
         @An_OrderSeq_NUMB            = @Ln_CaseCloseCUR_OrderSeq_NUMB,
         @An_MemberMci_IDNO           = @Ln_CaseCloseCUR_MemberMci_IDNO,
         @An_OthpSource_IDNO          = @Li_Zero_NUMB,
         @Ac_TypeChange_CODE          = @Lc_TypeChangeCc_CODE,
         @Ac_NegPos_CODE              = @Lc_NegPosStartRemedy_CODE,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_Create_DATE              = @Ld_RunParm_DATE,
         @Ac_Reference_ID             = @Lc_CaseClosureReason_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_ID,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ln_Exception_INDC = 1;

          RAISERROR(50001,16,1);
         END
       END

      --Update the process indicator in PCCLR table
      SET @Ls_Sql_TEXT = 'EXEC BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG';
      SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB = ' + CAST(@Ln_Record_NUMB AS VARCHAR) + ', Process_INDC = ' + @Lc_Yes_INDC;

      EXECUTE BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG
       @An_RecordRowNumber_NUMB  = @Ln_Record_NUMB,
       @Ac_Process_INDC          = @Lc_Yes_INDC,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'CCLR02Z : BATCH_CM_CASE_CLOSURE.SP_CASE_CLOSURE_TMP_UPD FAILED';
        SET @Ls_Sqldata_TEXT = 'RecordRowNumber_NUMB = ' + CAST(@Ln_Record_NUMB AS VARCHAR) + ', Process_INDC = ' + @Lc_Yes_INDC;

        SET @Ln_Exception_INDC = 1;

        RAISERROR(50001,16,1);
       END
      
	END TRY
	BEGIN CATCH
		
		IF XACT_STATE() = 1
			BEGIN
			   ROLLBACK TRANSACTION Case_Closure_Cursor_Transaction;
			END
		ELSE
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
				RAISERROR( 50001 ,16,1);
			END
		
		SAVE TRANSACTION Case_Closure_Cursor_Transaction;
				
		SET @Li_Error_NUMB = ERROR_NUMBER ();
		SET @Li_ErrorLine_NUMB = ERROR_LINE ();						
		IF @Li_Error_NUMB <> 50001
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
			END
		
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
						  @As_Procedure_NAME        = @Ls_Procedure_Name,
						  @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
						  @As_Sql_TEXT              = @Ls_Sql_TEXT,
						  @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
						  @An_Error_NUMB            = @Li_Error_NUMB,
						  @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
						  @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
						  
		EXECUTE BATCH_COMMON$SP_BATE_LOG
						  @As_Process_NAME             = @Ls_Process_NAME,
						  @As_Procedure_NAME           = @Lc_Proc_NAME,
						  @Ac_Job_ID                   = @Lc_Job_ID,
						  @Ad_Run_DATE                 = @Ld_RunParm_DATE,
						  @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
						  @An_Line_NUMB                = @Ln_Cursor_QNTY,
						  @Ac_Error_CODE               = @Lc_Msg_CODE,
						  @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
						  @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
						  @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						  @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

		IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				SELECT @Lc_Msg_CODE,@Ls_DescriptionError_TEXT
				RAISERROR (50001,16,1);
			END
		ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
			BEGIN
				SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
			END	
	END CATCH
				
	-- When the commit frequency is attained, Commit the transaction completed until now and Reset the commit count
	  IF @Ln_CommitFreqParm_QNTY <> 0
		 AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
		BEGIN
			SET @Ls_Sql_TEXT = 'JRTL_Y1 UPDATE ';
			SET @Ls_Sqldata_TEXT = 'JOB_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(20)), '') + ', THREAD_NO = ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(15)), '');

			UPDATE JRTL_Y1
			SET RecRestart_NUMB = @Ln_Record_NUMB + 1,
			   RestartKey_TEXT = @Ls_RestartKey_TEXT
			FROM JRTL_Y1 AS a
			WHERE a.Job_ID = @Lc_Job_ID
			AND a.Run_DATE = @Ld_RunParm_DATE
			AND a.Thread_NUMB = @An_Thread_NUMB;

			IF @@TRANCOUNT > 0
			BEGIN
				COMMIT TRANSACTION Case_Closure_Main_Transaction;
				BEGIN TRANSACTION Case_Closure_Main_Transaction;
			END
			SET @Ln_CommitFreq_QNTY = 0;
		END
					
	--If the Erroneous Exceptions are more than the threshold, then we need to abend the program. The commit will ensure that the records processed so far without any problems are committed. Also the exception entries are committed so that it will be easy to determine the error records.	
	IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
	   AND @Ln_ExceptionThresholdParm_QNTY > 0
		 BEGIN
			  COMMIT TRANSACTION Case_Closure_Main_Transaction;
			  SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD REACHED';
			  SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '');			  
			  SET @Ln_ExceptionThreshold_QNTY = 0;
			  RAISERROR (50001,16,1);
		END
			
	FETCH NEXT FROM CaseClose_CUR INTO @Ln_CaseCloseCUR_RowNumber_NUMB, @Ln_CaseCloseCUR_Case_IDNO, @Ln_CaseCloseCUR_MemberMci_IDNO, @Lc_CaseCloseCUR_RespondInit_CODE, @Ld_CaseCloseCUR_Deceased_DATE, @Lc_CaseCloseCUR_RsnStatusCase_CODE, @Lc_CaseCloseCUR_NonCoop_CODE, @Lc_CaseCloseCUR_GoodCause_CODE, @Lc_CaseCloseCUR_TypeCase_CODE, @Ln_CaseCloseCUR_OrderSeq_NUMB, @Lc_CaseCloseCUR_Process_INDC;
	SET @Li_FetchStatus_BIT = @@FETCH_STATUS;
	END
   END

   CLOSE CaseClose_CUR;

   DEALLOCATE CaseClose_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   IF (@Ln_Cursor_QNTY = 0)
    BEGIN
   
     SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Package_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Lc_Proc_NAME + ', Job_ID = ' + @Lc_Job_ID + ', RunParm_DATE = ' + CAST(@Ld_RunParm_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_ErrorTypeInformation_CODE +  ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorE0944_CODE + ', Sql_data = ' + @Ls_Sqldata_TEXT;
    
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Lc_Proc_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_RunParm_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeInformation_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sqldata_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ln_Exception_INDC = 1;

       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'CCLR03Z : SELECT PCCLR_Y1';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   
     --- Commit the transaction before getting the count from PCCLR_Y1 table
     IF @@TRANCOUNT > 0
		BEGIN
		 COMMIT TRANSACTION Case_Closure_Main_Transaction;
		END

   SELECT @Ln_TmpUpdate_QNTY = COUNT(1)
     FROM PCCLR_Y1 p
    WHERE p.Process_INDC = @Lc_No_INDC;

   IF @Ln_TmpUpdate_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_UPDATE_PARM_DATE CCLR020';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');

     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_RunParm_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'CCLR020A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_RunParm_DATE AS VARCHAR(10)), '');
       
       SET @Ln_Exception_INDC = 1;

       RAISERROR(50001,16,1);
      END
    END
   

   SET @Ls_Temp_TEXT = 'THREAD NO ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(15)), '');

   SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_RunParm_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Lc_Proc_NAME + ', CursorLocation_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ListKey_TEXT = ' + @Lc_Successful_TEXT +  ', DescriptionError_TEXT = ' + @Ls_Temp_TEXT + ', Status_CODE  = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_ID + ', ProcessedRecordCount_QNTY = ' + CAST(@An_Thread_NUMB AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_RunParm_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_Name,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Case_Closure_Main_Transaction;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION Case_Closure_Main_Transaction;
    END
    
   IF CURSOR_STATUS('Local', 'CaseClose_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseClose_CUR;
     DEALLOCATE CaseClose_CUR;
    END

   --- Updating JRTL to ThreadProcess_CODE 'A' to restart the job again
     UPDATE JRTL_Y1
		SET  ThreadProcess_CODE = @Lc_StatusAbnormalend_CODE
		FROM JRTL_Y1 AS a
		WHERE a.Job_ID = @Lc_Job_ID
		AND ThreadProcess_CODE = @Lc_ThreadLocked_INDC
		AND a.Run_DATE = @Ld_RunParm_DATE
		AND a.Thread_NUMB = @An_Thread_NUMB;

   IF ERROR_NUMBER()			= 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'THREAD NO ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(15)), '') + @Lc_Space_TEXT + @Ls_DescriptionError_TEXT;

     IF @Ln_Exception_INDC = 0
      BEGIN
       
       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
          @As_Procedure_NAME        = @Ls_Procedure_Name,
          @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
          @As_Sql_TEXT              = @Ls_Sql_TEXT,
          @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
          @An_Error_NUMB            = @Li_Error_NUMB,
          @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
          
       EXECUTE BATCH_COMMON$SP_BSTL_LOG
        @Ad_Run_DATE                  = @Ld_RunParm_DATE,
        @Ad_Start_DATE                = @Ld_Start_DATE,
        @Ac_Job_ID                    = @Lc_Job_ID,
        @As_Process_NAME              = @Ls_Process_NAME,
        @As_Procedure_NAME            = @Ls_Procedure_Name,
        @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
        @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
        @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
        @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
        @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
        @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
        @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;
      END
     ELSE
      BEGIN
       EXECUTE BATCH_COMMON$SP_BSTL_LOG
        @Ad_Run_DATE                  = @Ld_RunParm_DATE,
        @Ad_Start_DATE                = @Ld_Start_DATE,
        @Ac_Job_ID                    = @Lc_Job_ID,
        @As_Process_NAME              = @Ls_Process_NAME,
        @As_Procedure_NAME            = @Lc_Proc_NAME,
        @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
        @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
        @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
        @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
        @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
        @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
        @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

       EXECUTE BATCH_CM_CASE_CLOSURE_ELIG$SP_PCCLR_UPDATE_FLAG
        @An_RecordRowNumber_NUMB  = @Ln_Record_NUMB,
        @Ac_Process_INDC          = @Lc_StatusAbnormalend_CODE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      END

     RAISERROR (@Ls_DescriptionError_TEXT,16,1);
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionException_TEXT = 'THREAD NO ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(15)), '') + ' ' + ISNULL(SUBSTRING(ERROR_MESSAGE(), 1, 100), '');

     EXECUTE BATCH_COMMON$SP_BSTL_LOG
      @Ad_Run_DATE                  = @Ld_RunParm_DATE,
      @Ad_Start_DATE                = @Ld_Start_DATE,
      @Ac_Job_ID                    = @Lc_Job_ID,
      @As_Process_NAME              = @Ls_Process_NAME,
      @As_Procedure_NAME            = @Lc_Proc_NAME,
      @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
      @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
      @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
      @As_DescriptionError_TEXT     = @Ls_DescriptionException_TEXT,
      @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
      @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
      @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

     RAISERROR (@Ls_DescriptionError_TEXT,16,1);
    END
  END CATCH
 END

GO
