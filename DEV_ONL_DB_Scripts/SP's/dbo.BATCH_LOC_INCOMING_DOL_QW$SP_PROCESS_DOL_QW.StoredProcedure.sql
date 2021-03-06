/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DOL_QW$SP_PROCESS_DOL_QW]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 -----------------------------------------------------------------------------------------------------------------------------------------------
 Procedure Name    : BATCH_LOC_INCOMING_DOL_QW$SP_PROCESS_DOL_QW
 Programmer Name   : IMP Team.
 Description       : The Delaware update file from DOL processes and loads NCP and CP quarterly wage information received from DOL to DACSES. 
					 This process occurs in two steps. The first step loads the data from the interface file to a temporary quarterly wage-holding table.
					 The second step reads the temporary table and matches the information to a DACSES member withby SSN and name. 
					 If the information matches with a DACSES NCP or CP then DACSESsystem is updated.  
 Frequency         : QUARTERLY
 Developed On      : 
 Called By         : None
 Called On         : 
 ---------------------------------------------------------------------------------------------------------------------------------------------                    
 Modified By       :
 Modified On       :
 Version No        : 1.0
 ----------------------------------------------------------------------------------------------------------------------------------------------
 */
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DOL_QW$SP_PROCESS_DOL_QW]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_FetchStatus_QNTY         INT = 0,
          @Li_RowCount_QNTY            INT = 0,
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE   CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE      CHAR(1) = 'O',
          @Lc_StatusCaseClosed_CODE    CHAR(1) = 'C',
          @Lc_TypeErrorE_CODE          CHAR(1) = 'E',
          --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -START-
          @Lc_Status_CODE			   CHAR(1) = 'N',
          --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -END-
          @Lc_TypePrimaryItin_CODE     CHAR(1) = 'I',
          @Lc_MemberStatusA_CODE       CHAR(1) = 'A',
          @Lc_MemberStatusP_CODE	   CHAR(1) = 'P',
          @Lc_TypeOthp_CODE            CHAR(1) = 'E',
          @Lc_Normalization_CODE       CHAR(1) = 'N',
          @Lc_TypePrimary_CODE         CHAR(1) = 'P',
          @Lc_Yes_INDC                 CHAR(1) = 'Y',
          @Lc_No_INDC                  CHAR(1) = 'N',
          @Lc_CaseRelationshipNcp_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipCp_CODE  CHAR(1) = 'C',
          @Lc_CaseRelationshipPuf_CODE CHAR(1) = 'P',
          @Lc_TypeCaseNonIVD_CODE      CHAR(1) = 'H',
          @Lc_ConfirmedGood_CODE	   CHAR(1) = 'Y',
          @Lc_ConfirmedPending_CODE	   CHAR(1) = 'P',
          @Lc_SsnPrimary_CODE		   CHAR(1) = 'P',
          @Lc_SsnItin_CODE		 	   CHAR(1) = 'I',
          @Lc_SourceLocConfA_CODE	   CHAR(1) = 'A',
          @Lc_SubsystemCM_CODE         CHAR(2) = 'CM',
          @Lc_TypeIncomeEM_CODE        CHAR(2) = 'EM',
          @Lc_Country_ADDR             CHAR(2) = 'US',
          @Lc_ReasonStatusUB_CODE      CHAR(2) = 'UB',
          @Lc_ReasonStatusUC_CODE      CHAR(2) = 'UC',
          @Lc_ReasonStatusSy_CODE      CHAR(2) = 'SY',
          @Lc_ReasonStatusBi_CODE      CHAR(2) = 'BI',
          @Lc_SourceLocDol_CODE        CHAR(3) = 'DOL',
          @Lc_RefmValue_CODE           CHAR(4) = 'STAT',
          @Lc_ActivityMajorCASE_CODE   CHAR(4) = 'CASE',
          @Lc_StatusStrt_CODE          CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE          CHAR(4) = 'COMP',
          @Lc_ActivityMinorRQWDL_CODE  CHAR(5) = 'RQWDL',
          @Lc_ErrorE0944_CODE          CHAR(5) = 'E0944',
          @Lc_ErrorE1901_CODE          CHAR(5) = 'E1901',
          @Lc_ErrorE1094_CODE          CHAR(5) = 'E1094',
          @Lc_ErrorE0640_CODE          CHAR(5) = 'E0640',
          @Lc_ErrorE0620_CODE          CHAR(5) = 'E0620',
          @Lc_ErrorE1405_CODE          CHAR(5) = 'E1405',
          @Lc_ErrorE0043_CODE          CHAR(5) = 'E0043',
          @Lc_ErrorE0071_CODE          CHAR(5) = 'E0071',
          @Lc_ErrorE1424_CODE          CHAR(5) = 'E1424',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_Job_ID                   CHAR(7) = 'DEB6080',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT             CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_LOC_INCOMING_DOL_QW',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_PROCESS_DOL_QW',
          @Ld_High_DATE                DATE = '12/31/9999',
          @Ld_Low_DATE                 DATE = '01/01/0001';
  DECLARE @Ln_Increment_NUMB              NUMERIC(1) = 0,
          @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_YearQtrNumb_NUMB            NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5),
          @Ln_RestartLine_NUMB            NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_FeinIdno_NUMB               NUMERIC(9),
          @Ln_OtherParty_IDNO             NUMERIC(9),
          @Ln_MemberMci_IDNO              NUMERIC(10) = 0,
          @Ln_CountExists_NUMB            NUMERIC(10),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_EmployeeWage_AMNT           NUMERIC(11, 0),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_RowsCount_NUMB              NUMERIC(11),
          @Ln_ExcpThreshold_QNTY          NUMERIC(11),
          @Ln_SeinIdno_NUMB               NUMERIC(12),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_BateError_CODE              CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLoc_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Lc_ProcessDolCur_Seq_IDNO                   CHAR(19),
          @Lc_ProcessDolCur_Record_ID                  CHAR(2),
          @Lc_ProcessDolCur_MemberSsnNumb_TEXT         CHAR(9),
          @Lc_ProcessDolCur_EmployeeFirst_NAME         CHAR(16),
          @Lc_ProcessDolCur_EmployeeMiddle_NAME        CHAR(16),
          @Lc_ProcessDolCur_EmployeeLast_NAME          CHAR(30),
          @Lc_ProcessDolCur_EmployeeWageAmnt_TEXT      CHAR(11),
          @Lc_ProcessDolCur_YearQtrNumb_TEXT           CHAR(5),
          @Lc_ProcessDolCur_FeinIdno_TEXT              CHAR(9),
          @Lc_ProcessDolCur_SeinIdno_TEXT              CHAR(12),
          @Lc_ProcessDolCur_Employer_NAME              CHAR(45),
          @Lc_ProcessDolCur_LocationNormalization_CODE CHAR(1),
          @Lc_ProcessDolCur_EmployerLine1_ADDR         CHAR(50),
          @Lc_ProcessDolCur_EmployerLine2_ADDR         CHAR(50),
          @Lc_ProcessDolCur_EmployerCity_ADDR          CHAR(28),
          @Lc_ProcessDolCur_EmployerState_ADDR         CHAR(2),
          @Lc_ProcessDolCur_EmployerZip1_ADDR          CHAR(15),
          @Lc_ProcessDolCur_Process_INDC               CHAR(1);
  DECLARE @Ln_ProcessDolCurMemberSsn_NUMB NUMERIC(9);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'ASSINING BATCH START TIME';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST (@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END;
   
   SET @Ln_Increment_NUMB = 1;
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION DOLQW_PROCESS;

   SET @Ls_Sql_TEXT = 'UPDATING THE PROCESS INDICATOR TO "Y" - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE L
      SET PROCESS_INDC = @Lc_Yes_INDC
    FROM LSQWA_Y1 L
    WHERE NOT EXISTS (SELECT 1
					    FROM DEMO_Y1 d, MSSN_Y1 m
				       WHERE m.MemberSsn_NUMB = l.MemberSsn_NUMB
				         AND ((m.Enumeration_CODE IN (@Lc_ConfirmedGood_CODE, @Lc_ConfirmedPending_CODE)
				               AND TypePrimary_CODE = @Lc_SsnPrimary_CODE)
				              OR (m.Enumeration_CODE = @Lc_ConfirmedGood_CODE
				                  AND TypePrimary_CODE = @Lc_SsnItin_CODE))
				         AND m.EndValidity_DATE = @Ld_High_DATE
				         AND d.MemberMci_IDNO = m.MemberMci_IDNO
				         AND SUBSTRING(d.Last_NAME, 1, 5) = SUBSTRING(l.Last_NAME, 1, 5))
	   AND (MemberSsn_NUMB NOT IN (SELECT MemberSsn_NUMB
                                    FROM DEMO_Y1)
           OR MemberSsn_NUMB IN (SELECT MemberSsn_NUMB
                                   FROM DEMO_Y1
                                  GROUP BY MemberSsn_NUMB
                                  HAVING COUNT(1) > 1)
           OR ISNUMERIC(LTRIM(RTRIM(MemberSsn_NUMB))) = 0
           OR EmployerState_ADDR NOT IN (SELECT VALUE_CODE
                                           FROM REFM_Y1 r
                                          WHERE r.Table_ID = @Lc_RefmValue_CODE
                                            AND r.TableSub_ID = @Lc_RefmValue_CODE)
           OR EmployerLINE1_ADDR = '');

   SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT
   SET @Ls_Sql_TEXT = 'UPDATING THE PROCESS INDICATOR TO "Y" - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   UPDATE L
      SET PROCESS_INDC = @Lc_Yes_INDC
     FROM LSQWA_Y1 L WITH (NOLOCK)
    WHERE NOT EXISTS (SELECT DISTINCT
                             1
                        FROM CMEM_Y1 m
                             INNER JOIN CASE_Y1 c
                              ON m.Case_IDNO = c.Case_IDNO
                             INNER JOIN DEMO_Y1 d
                              ON m.MemberMci_IDNO = d.MemberMci_IDNO
                       WHERE d.MemberSsn_NUMB = CAST(l.MemberSsn_NUMB AS NUMERIC)
                         AND m.CaseMemberStatus_CODE IN (@Lc_MemberStatusA_CODE, @Lc_MemberStatusP_CODE)
                         AND c.TypeCase_CODE != @Lc_TypeCaseNonIVD_CODE
                         AND ((c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                               AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipPuf_CODE))
                               OR (c.StatusCase_CODE = @Lc_StatusCaseClosed_CODE
                                   AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPuf_CODE)
                                   AND c.RsnStatusCase_CODE IN (@Lc_ReasonStatUsUB_CODE, @Lc_ReasonStatusUC_CODE))))
      AND l.PROCESS_INDC = @Lc_No_INDC;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @@ROWCOUNT;

   COMMIT TRANSACTION DOLQW_PROCESS;

   BEGIN TRANSACTION DOLQW_PROCESS;

   DECLARE ProcessDol_CUR INSENSITIVE CURSOR FOR
    SELECT l.Seq_IDNO,
           l.Rec_ID,
           l.MemberSsn_NUMB,
           l.First_NAME,
           l.Middle_NAME,
           l.Last_NAME,
           l.Wage_AMNT,
           l.YearQtr_NUMB,
           l.Fein_IDNO,
           l.Sein_IDNO,
           l.Employer_NAME,
           l.LocationNormalization_CODE,
           l.EmployerLine1_ADDR,
           l.EmployerLine2_ADDR,
           l.EmployerCity_ADDR,
           l.EmployerState_ADDR,
           l.EmployerZip1_ADDR,
           l.Process_INDC
      FROM LSQWA_Y1 l
     WHERE l.Process_INDC = @Lc_No_INDC
     ORDER BY l.Seq_IDNO;

   SET @Ls_Sql_TEXT = 'Process Record Count';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   OPEN ProcessDol_CUR;

   SET @Ls_Sql_TEXT = 'FETCH ProcessDol_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   FETCH NEXT FROM ProcessDol_CUR INTO @Lc_ProcessDolCur_Seq_IDNO, @Lc_ProcessDolCur_Record_ID, @Lc_ProcessDolCur_MemberSsnNumb_TEXT, @Lc_ProcessDolCur_EmployeeFirst_NAME, @Lc_ProcessDolCur_EmployeeMiddle_NAME, @Lc_ProcessDolCur_EmployeeLast_NAME, @Lc_ProcessDolCur_EmployeeWageAmnt_TEXT, @Lc_ProcessDolCur_YearQtrNumb_TEXT, @Lc_ProcessDolCur_FeinIdno_TEXT, @Lc_ProcessDolCur_SeinIdno_TEXT, @Lc_ProcessDolCur_Employer_NAME, @Lc_ProcessDolCur_LocationNormalization_CODE, @Lc_ProcessDolCur_EmployerLine1_ADDR, @Lc_ProcessDolCur_EmployerLine2_ADDR, @Lc_ProcessDolCur_EmployerCity_ADDR, @Lc_ProcessDolCur_EmployerState_ADDR, @Lc_ProcessDolCur_EmployerZip1_ADDR, @Lc_ProcessDolCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY = -1
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Check for eligible members
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ln_MemberMci_IDNO = 0;
      SET @Ls_BateRecord_TEXT = 'Record_ID = ' + ISNULL(@Lc_ProcessDolCur_Record_ID, @Lc_Space_TEXT) + ', MemberSsnNumb_TEXT=' + ISNULL(@Lc_ProcessDolCur_MemberSsnNumb_TEXT, @Lc_Space_TEXT) + +', EmployeeFirst_NAME = ' + ISNULL(@Lc_ProcessDolCur_EmployeeFirst_NAME, @Lc_Space_TEXT) + ', EmployeeMiddle_NAME = ' + ISNULL(@Lc_ProcessDolCur_EmployeeMiddle_NAME, @Lc_Space_TEXT) + ', EmployeeLast_NAME = ' + ISNULL(@Lc_ProcessDolCur_EmployeeLast_NAME, @Lc_Space_TEXT) + ', EmployeeWageAmnt = ' + ISNULL(@Lc_ProcessDolCur_EmployeeWageAmnt_TEXT, @Lc_Space_TEXT) + ', YearQtrNumb = ' + ISNULL(@Lc_ProcessDolCur_YearQtrNumb_TEXT, @Lc_Space_TEXT) + ', FeinIdno = ' + ISNULL(@Lc_ProcessDolCur_FeinIdno_TEXT, @Lc_Space_TEXT) + ', SeinIdno = ' + ISNULL(@Lc_ProcessDolCur_SeinIdno_TEXT, @Lc_Space_TEXT) + ', Employer_NAME = ' + ISNULL(@Lc_ProcessDolCur_Employer_NAME, @Lc_Space_TEXT) + ', LocationNormalization_CODE = ' + ISNULL(@Lc_ProcessDolCur_LocationNormalization_CODE, @Lc_Space_TEXT) + ', EmployerLine1_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerLine1_ADDR, @Lc_Space_TEXT) + ', EmployerLine2_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerLine2_ADDR, @Lc_Space_TEXT) + ', EmployerCity_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerCity_ADDR, @Lc_Space_TEXT) + ', EmployerState_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerState_ADDR, @Lc_Space_TEXT) + ', EmployerZip1_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerZip1_ADDR, @Lc_Space_TEXT) + ', Process_INDC = ' + ISNULL(@Lc_ProcessDolCur_Process_INDC, @Lc_Space_TEXT);
      SET @Li_RowCount_QNTY = @Li_RowCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLoc_TEXT ='DOL - CURSOR COUNT - ' + CAST (@Li_RowCount_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Member SSN = ' + @Lc_ProcessDolCur_MemberSsnNumb_TEXT;
      SET @Ln_ProcessDolCurMemberSsn_NUMB = CAST(@Lc_ProcessDolCur_MemberSsnNumb_TEXT AS NUMERIC);
      SET @Ls_Sql_TEXT = 'Get Member Count';
      SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(@Lc_ProcessDolCur_MemberSsnNumb_TEXT, '');

      SELECT @Ln_MemberMci_IDNO = d.MemberMci_IDNO
        FROM DEMO_Y1 D
       WHERE D.MemberSsn_NUMB = @Ln_ProcessDolCurMemberSsn_NUMB;

      IF NOT EXISTS (SELECT DISTINCT
                            1
                       FROM CMEM_Y1 m
                            INNER JOIN CASE_Y1 c
                             ON m.Case_IDNO = c.Case_IDNO
                      WHERE m.MemberMci_IDNO = @Ln_MemberMci_IDNO
                        AND m.CaseMemberStatus_CODE IN (@Lc_MemberStatusA_CODE, @Lc_MemberStatusP_CODE)
                        AND c.TypeCase_CODE != @Lc_TypeCaseNonIVD_CODE
                        AND ((c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                              AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipPuf_CODE))
                              OR (c.StatusCase_CODE = @Lc_StatusCaseClosed_CODE
                                  AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPuf_CODE)
                                  AND c.RsnStatusCase_CODE IN (@Lc_ReasonStatUsUB_CODE, @Lc_ReasonStatusUC_CODE))))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;
        SET @Ln_MemberMci_IDNO = 0;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_YearQtrNumb_NUMB = CAST(@Lc_ProcessDolCur_YearQtrNumb_TEXT AS NUMERIC);
        SET @Ln_SeinIdno_NUMB = CAST(@Lc_ProcessDolCur_SeinIdno_TEXT AS NUMERIC);
        SET @Ln_EmployeeWage_AMNT = CAST(@Lc_ProcessDolCur_EmployeeWageAmnt_TEXT AS NUMERIC);
        SET @Ln_FeinIdno_NUMB = CAST(@Lc_ProcessDolCur_FeinIdno_TEXT AS NUMERIC);
        SET @Ln_SeinIdno_NUMB = CAST(@Lc_ProcessDolCur_SeinIdno_TEXT AS NUMERIC);
        SET @Ls_Sql_TEXT = 'Check for record exists in EMQW_Y1';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', YearQtr_NUMB = ' + ISNULL(@Lc_ProcessDolCur_YearQtrNumb_TEXT, '') + ', Sein_IDNO = ' + ISNULL(@Lc_ProcessDolCur_SeinIdno_TEXT, '') + ', Wage_AMNT = ' + ISNULL(@Lc_ProcessDolCur_EmployeeWageAmnt_TEXT, '');

        SELECT @Ln_CountExists_NUMB = COUNT (1)
          FROM EMQW_Y1 e
         WHERE E.MemberMci_IDNO = @Ln_MemberMci_IDNO
           AND E.YearQtr_NUMB = @Ln_YearQtrNumb_NUMB
           AND E.Sein_IDNO = @Ln_SeinIdno_NUMB
           AND E.Wage_AMNT = @Ln_EmployeeWage_AMNT;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
        SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

        EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_No_INDC,
         @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END

        IF (@Ln_CountExists_NUMB = 0 
			 AND (SUBSTRING(@Lc_ProcessDolCur_YearQtrNumb_TEXT, 1, 1) >= 1
                   AND SUBSTRING(@Lc_ProcessDolCur_YearQtrNumb_TEXT, 1, 1) <= 4))
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT EMQW_Y1';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_ProcessDolCur_MemberSsnNumb_TEXT, '') + ', MatchCode_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(@Lc_ProcessDolCur_FeinIdno_TEXT, '') + ', Sein_IDNO = ' + ISNULL(@Lc_ProcessDolCur_SeinIdno_TEXT, '') + ', Wage_AMNT = ' + ISNULL(@Lc_ProcessDolCur_EmployeeWageAmnt_TEXT, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

          INSERT INTO EMQW_Y1
                      (MemberMci_IDNO,
                       YearQtr_NUMB,
                       MemberSsn_NUMB,
                       Employer_NAME,
                       Last_NAME,
                       Middle_NAME,
                       First_NAME,
                       MatchCode_DATE,
                       Fein_IDNO,
                       Sein_IDNO,
                       Line1_ADDR,
                       Line2_ADDR,
                       City_ADDR,
                       State_ADDR,
                       Zip_ADDR,
                       Wage_AMNT,
                       WorkerUpdate_ID,
                       Transaction_DATE,
                       Update_DTTM,
                       TransactionEventSeq_NUMB)
               VALUES ( @Ln_MemberMci_IDNO,--MemberMci_IDNO
                        ISNULL (@Ln_YearQtrNumb_NUMB, @Ln_Zero_NUMB),--YearQtr_NUMB
                        @Lc_ProcessDolCur_MemberSsnNumb_TEXT,--MemberSsn_NUMB
                        ISNULL (@Lc_ProcessDolCur_Employer_NAME, @Lc_Space_TEXT),--Employer_NAME
                        ISNULL (@Lc_ProcessDolCur_EmployeeLast_NAME, @Lc_Space_TEXT),--Last_NAME
                        ISNULL (@Lc_ProcessDolCur_EmployeeMiddle_NAME, @Lc_Space_TEXT),--Middle_NAME
                        ISNULL (@Lc_ProcessDolCur_EmployeeFirst_NAME, @Lc_Space_TEXT),--First_NAME
                        @Ld_Run_DATE,--MatchCode_DATE
                        @Ln_FeinIdno_NUMB,--Fein_IDNO
                        @Ln_SeinIdno_NUMB,--Sein_IDNO
                        ISNULL (@Lc_ProcessDolCur_EmployerLine1_ADDR, @Lc_Space_TEXT),--Line1_ADDR
                        ISNULL (@Lc_ProcessDolCur_EmployerLine2_ADDR, @Lc_Space_TEXT),--Line2_ADDR
                        ISNULL (@Lc_ProcessDolCur_EmployerCity_ADDR, @Lc_Space_TEXT),--City_ADDR
                        ISNULL (@Lc_ProcessDolCur_EmployerState_ADDR, @Lc_Space_TEXT),--State_ADDR
                        ISNULL (@Lc_ProcessDolCur_EmployerZip1_ADDR, @Lc_Space_TEXT),--Zip_ADDR
                        @Ln_EmployeeWage_AMNT,--Wage_AMNT
                        @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                        @Ld_Run_DATE,--Transaction_DATE
                        @Ld_Start_DATE,--Update_DTTM
                        @Ln_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
          );
         END

		SAVE TRANSACTION SAVEDOLQW_PROCESS;

        SET @Ls_Sql_TEXT ='CHECK FOR REPORTING PEROID';
        SET @Ls_Sqldata_TEXT ='YearQtrNumb_TEXT = ' + @Lc_ProcessDolCur_YearQtrNumb_TEXT;

        IF SUBSTRING(@Lc_ProcessDolCur_YearQtrNumb_TEXT, 1, 1) < 1
            OR SUBSTRING(@Lc_ProcessDolCur_YearQtrNumb_TEXT, 1, 1) > 4
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorE0043_CODE;

          RAISERROR (50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
          SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(@Lc_ProcessDolCur_FeinIdno_TEXT, '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Lc_ProcessDolCur_Employer_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerCity_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerZip1_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_ProcessDolCur_EmployerState_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDol_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_Normalization_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '');
          SET @Ln_FeinIdno_NUMB= CAST(@Lc_ProcessDolCur_FeinIdno_TEXT AS NUMERIC);

          EXECUTE BATCH_COMMON$SP_GET_OTHP
           @Ad_Run_DATE                     = @Ld_Run_DATE,
           @An_Fein_IDNO                    = @Ln_FeinIdno_NUMB,
           @Ac_TypeOthp_CODE                = @Lc_TypeOthp_CODE,
           @As_OtherParty_NAME              = @Lc_ProcessDolCur_Employer_NAME,
           @Ac_Aka_NAME                     = @Lc_Space_TEXT,
           @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
           @As_Line1_ADDR                   = @Lc_ProcessDolCur_EmployerLine1_ADDR,
           @As_Line2_ADDR                   = @Lc_ProcessDolCur_EmployerLine2_ADDR,
           @Ac_City_ADDR                    = @Lc_ProcessDolCur_EmployerCity_ADDR,
           @Ac_Zip_ADDR                     = @Lc_ProcessDolCur_EmployerZip1_ADDR,
           @Ac_State_ADDR                   = @Lc_ProcessDolCur_EmployerState_ADDR,
           @Ac_Fips_CODE                    = @Lc_Space_TEXT,
           @Ac_Country_ADDR                 = @Lc_Country_ADDR,
           @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
           @An_Phone_NUMB                   = @Ln_Zero_NUMB,
           @An_Fax_NUMB                     = @Ln_Zero_NUMB,
           @As_Contact_EML                  = @Lc_Space_TEXT,
           @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
           @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
           @An_Sein_IDNO                    = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE               = @Lc_SourceLocDol_CODE,
           @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
           @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
           @Ac_Normalization_CODE           = @Lc_Normalization_CODE,
           @Ac_Process_ID                   = @Lc_Job_ID,
           @An_OtherParty_IDNO              = @Ln_OtherParty_IDNO OUTPUT,
           @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Lc_BateError_Code = @Lc_ErrorE0071_CODE;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            SET @Lc_BateError_Code = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END

          IF @Ln_OtherParty_IDNO != 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
            --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -START-
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Status_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeEM_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceLocConfA_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', IncomeNet_AMNT = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocDol_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + @Lc_Space_TEXT + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');
            --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -END-

            EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
             @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
             @An_OthpPartyEmpl_IDNO         = @Ln_OtherParty_IDNO,
             @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
             --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -START-
             @Ac_Status_CODE                = @Lc_Status_CODE, 
             --13682 - Per CR0427, pass N to prevent the start of the IMIW activity chain for the employer record. -END-
             @Ad_Status_DATE                = @Ld_Run_DATE,
             @Ac_TypeIncome_CODE            = @Lc_TypeIncomeEM_CODE, 
             @Ac_SourceLocConf_CODE         = @Lc_SourceLocConfA_CODE, 
             @Ad_Run_DATE                   = @Ld_Run_DATE,
             @Ad_BeginEmployment_DATE       = @Ld_Run_DATE,
             @Ad_EndEmployment_DATE         = @Ld_High_DATE,
             @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
             @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
             @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
             @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
             @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
             @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
             @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
             @Ac_SourceLoc_CODE             = @Lc_SourceLocDol_CODE,
             @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
             @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
             @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
             @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
             @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
             @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
             @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
             @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
             @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
             @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
             @Ac_Process_ID                 = @Lc_Job_ID,
             @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
             @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE IN (@Lc_ErrorE0620_CODE, @Lc_ErrorE0640_CODE, @Lc_ErrorE1901_CODE, @Lc_ErrorE1094_CODE)
             BEGIN
              SET @Lc_BateError_Code = @Lc_Msg_CODE;

              RAISERROR (50001,16,1);
             END

            SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
            SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Increment_NUMB = ' + CAST(@Ln_Increment_NUMB AS VARCHAR) + ', ActivityMajorCase_CODE = ' + @Lc_ActivityMajorCase_CODE + ', SubsystemLo_CODE = ' + @Lc_SubsystemCM_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', ReasonStatusBi_CODE = ' + @Lc_ReasonStatusBi_CODE + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

            INSERT DMJR_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    MajorIntSEQ_NUMB,
                    MemberMci_IDNO,
                    ActivityMajor_CODE,
                    Subsystem_CODE,
                    TypeOthpSource_CODE,
                    OthpSource_IDNO,
                    Entered_DATE,
                    Status_DATE,
                    Status_CODE,
                    ReasonStatus_CODE,
                    BeginExempt_DATE,
                    EndExempt_DATE,
                    TotalTopics_QNTY,
                    PostLastPoster_IDNO,
                    UserLastPoster_ID,
                    SubjectLastPoster_TEXT,
                    LastPost_DTTM,
                    BeginValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB,
                    TypeReference_CODE,
                    Reference_ID)
            SELECT DISTINCT
                   b.Case_IDNO,
                   0 AS OrderSeq_NUMB,
                   (SELECT ISNULL(MAX(c.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
                      FROM DMJR_Y1 c
                     WHERE c.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
                   0 AS MemberMci_IDNO,
                   @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
                   @Lc_SubsystemCM_CODE AS Subsystem_CODE,
                   @Lc_Space_TEXT AS TypeOthpSource_CODE,
                   0 AS OthpSource_IDNO,
                   @Ld_Run_DATE AS Entered_DATE,
                   @Ld_High_DATE AS Status_DATE,
                   @Lc_StatusStrt_CODE AS Status_CODE,
                   @Lc_ReasonStatusBi_CODE AS ReasonStatus_CODE,
                   @Ld_Low_DATE AS BeginExempt_DATE,
                   @Ld_Low_DATE AS EndExempt_DATE,
                   0 AS TotalTopics_QNTY,
                   0 AS PostLastPoster_IDNO,
                   @Lc_Space_TEXT AS UserLastPoster_ID,
                   @Lc_Space_TEXT AS SubjectLastPoster_TEXT,
                   @Ld_Low_DATE AS LastPost_DTTM,
                   @Ld_Run_DATE AS BeginValidity_DATE,
                   @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                   @Ld_Start_DATE AS UPDATE_DTTM,
                   @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                   @Lc_Space_TEXT AS TypeReference_CODE,
                   @Lc_Space_TEXT AS Reference_ID
              FROM (SELECT a.Case_IDNO,
                           a.MemberMci_IDNO
                      FROM CMEM_Y1 a
                           INNER JOIN CASE_Y1 b
                            ON a.Case_IDNO = b.Case_IDNO
                     WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
                       AND a.CaseMemberStatus_CODE = @Lc_MemberStatusA_CODE
                       AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE) a,
                   CMEM_Y1 b,
                   CASE_Y1 s
             WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
               AND a.Case_IDNO = b.Case_IDNO
               AND b.Case_IDNO = s.Case_IDNO
               AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
               AND NOT EXISTS (SELECT 1
                                 FROM DMJR_Y1 d
                                WHERE b.Case_IDNO = d.Case_IDNO
                                  AND d.Subsystem_CODE = @Lc_SubsystemCM_CODE
                                  AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
                                  AND d.Status_CODE = @Lc_StatusStrt_CODE);

            SET @Ls_Sql_TEXT = 'DELETE ITOPC_Y1';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

            DELETE FROM ITOPC_Y1;

            SET @Ls_Sql_TEXT = 'INSERT ITOPC_Y1';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

            INSERT INTO ITOPC_Y1
                        (Entered_DATE)
                 VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
            );

            SET @Ls_Sql_TEXT = 'DELETE ITOPC_Y1';
            SET @Ls_SqlData_TEXT = '';

            SELECT @Ln_SeqUnique_IDNO = a.Seq_IDNO
              FROM ITOPC_Y1 a;

            SET @Ls_Sql_TEXT = 'INSERT CJNR_Y1';
            SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorRQWDL_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', StatusComplete_CODE = ' + @Lc_StatusComp_CODE + ', ReasonStatusSy_CODE = ' + @Lc_ReasonStatusSy_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', SubsystemLo_CODE = ' + @Lc_SubsystemCM_CODE + ', ActivityMajorCase_CODE = ' + @Lc_ActivityMajorCase_CODE + ', StatusStart_CODE = ' + @Lc_StatusStrt_CODE;

            INSERT CJNR_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    MajorIntSEQ_NUMB,
                    MinorIntSeq_NUMB,
                    MemberMci_IDNO,
                    ActivityMinor_CODE,
                    ActivityMinorNext_CODE,
                    Entered_DATE,
                    Due_DATE,
                    Status_DATE,
                    Status_CODE,
                    ReasonStatus_CODE,
                    Schedule_NUMB,
                    Forum_IDNO,
                    Topic_IDNO,
                    TotalReplies_QNTY,
                    TotalViews_QNTY,
                    PostLastPoster_IDNO,
                    UserLastPoster_ID,
                    LastPost_DTTM,
                    AlertPrior_DATE,
                    BeginValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB,
                    WorkerDelegate_ID,
                    Subsystem_CODE,
                    ActivityMajor_CODE)
            SELECT a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.MajorIntSEQ_NUMB,
                   a.MinorIntSeq_NUMB,
                   a.MemberMci_IDNO,
                   a.ActivityMinor_CODE,
                   a.ActivityMinorNext_CODE,
                   a.Entered_DATE,
                   a.Due_DATE,
                   a.Status_DATE,
                   a.Status_CODE,
                   a.ReasonStatus_CODE,
                   a.Schedule_NUMB,
                   a.Forum_IDNO,
                   a.Topic_IDNO,
                   a.NoTotalReplies_QNTY,
                   a.NoTotalViews_QNTY,
                   a.PostLastPoster_IDNO,
                   a.UserLastPoster_ID,
                   a.LastPost_DTTM,
                   a.AlertPrior_DATE,
                   a.BeginValidity_DATE,
                   a.WorkerUpdate_ID,
                   a.Update_DTTM,
                   a.TransactionEventSeq_NUMB,
                   a.WorkerDelegate_ID,
                   a.Subsystem_CODE,
                   a.ActivityMajor_CODE
              FROM (SELECT b.Case_IDNO AS Case_IDNO,
                           0 AS OrderSeq_NUMB,
                           d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
                           ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
                                     FROM UDMNR_V1 x
                                    WHERE d.Case_IDNO = x.Case_IDNO
                                      AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.Case_IDNO) AS MinorIntSeq_NUMB,
                           b.MemberMci_IDNO AS MemberMci_IDNO,
                           @Lc_ActivityMinorRQWDL_CODE AS ActivityMinor_CODE,
                           @Lc_Space_TEXT AS ActivityMinorNext_CODE,
                           @Ld_Run_DATE AS Entered_DATE,
                           @Ld_Run_DATE AS Due_DATE,
                           @Ld_Run_DATE AS Status_DATE,
                           @Lc_StatusComp_CODE AS Status_CODE,
                           @Lc_ReasonStatusSy_CODE AS ReasonStatus_CODE,
                           0 AS Schedule_NUMB,
                           d.Forum_IDNO,
                           @Ln_SeqUnique_IDNO AS Topic_IDNO,
                           0 AS NoTotalReplies_QNTY,
                           0 AS NoTotalViews_QNTY,
                           0 AS PostLastPoster_IDNO,
                           @Lc_BatchRunUser_TEXT AS UserLastPoster_ID,
                           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS LastPost_DTTM,
                           @Ld_Run_DATE AS AlertPrior_DATE,
                           @Ld_Run_DATE AS BeginValidity_DATE,
                           @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                           dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
                           @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                           @Lc_Space_TEXT AS WorkerDelegate_ID,
                           @Lc_SubsystemCM_CODE AS Subsystem_CODE,
                           @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
                      FROM CMEM_Y1 b,
                           DMJR_Y1 d,
                           (SELECT a.Case_IDNO,
                                   a.MemberMci_IDNO
                              FROM CMEM_Y1 a
                                   INNER JOIN CASE_Y1 b
                                    ON a.Case_IDNO = b.Case_IDNO
                             WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
                               AND a.CaseMemberStatus_CODE = @Lc_MemberStatusA_CODE
                               AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE) a,
                           CASE_Y1 s
                     WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                       AND a.Case_IDNO = b.Case_IDNO
                       AND b.Case_IDNO = d.Case_IDNO
                       AND b.Case_IDNO = s.Case_IDNO
                       AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                       AND d.Subsystem_CODE = @Lc_SubsystemCM_CODE
                       AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
                       AND d.Status_CODE = @Lc_StatusStrt_CODE) a;
           END
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEDOLQW_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       IF CURSOR_STATUS ('LOCAL', 'CaseMember_CUR') IN (0, 1)
        BEGIN
         CLOSE CaseMember_CUR;

         DEALLOCATE CaseMember_CUR;
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

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
       SET @Ls_Sqldata_TEXT = 'Member SSN = ' + RTRIM(CAST(@Lc_ProcessDolCur_MemberSsnNumb_TEXT AS VARCHAR));
       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     END CATCH

     SET @Ls_Sql_TEXT ='UPDATE LSQWA_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(@Lc_ProcessDolCur_Seq_IDNO, '') + ', ProcessY_INDC = ' + @Lc_Yes_INDC;

     UPDATE LSQWA_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Seq_IDNO = @Lc_ProcessDolCur_Seq_IDNO;

     SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowsCount_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_ProcessedRecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       COMMIT TRANSACTION DOLQW_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       BEGIN TRANSACTION DOLQW_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT='ExcpThreshold_QNTY = ' + CAST(@Ln_ExcpThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExcpThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;

       COMMIT TRANSACTION DOLQW_PROCESS;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH ProcessDol_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM ProcessDol_CUR INTO @Lc_ProcessDolCur_Seq_IDNO, @Lc_ProcessDolCur_Record_ID, @Lc_ProcessDolCur_MemberSsnNumb_TEXT, @Lc_ProcessDolCur_EmployeeFirst_NAME, @Lc_ProcessDolCur_EmployeeMiddle_NAME, @Lc_ProcessDolCur_EmployeeLast_NAME, @Lc_ProcessDolCur_EmployeeWageAmnt_TEXT, @Lc_ProcessDolCur_YearQtrNumb_TEXT, @Lc_ProcessDolCur_FeinIdno_TEXT, @Lc_ProcessDolCur_SeinIdno_TEXT, @Lc_ProcessDolCur_Employer_NAME, @Lc_ProcessDolCur_LocationNormalization_CODE, @Lc_ProcessDolCur_EmployerLine1_ADDR, @Lc_ProcessDolCur_EmployerLine2_ADDR, @Lc_ProcessDolCur_EmployerCity_ADDR, @Lc_ProcessDolCur_EmployerState_ADDR, @Lc_ProcessDolCur_EmployerZip1_ADDR, @Lc_ProcessDolCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE ProcessDol_CUR;

   DEALLOCATE ProcessDol_CUR;

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                 = @Ld_Run_DATE,
    @Ad_Start_DATE               = @Ld_Start_DATE,
    @Ac_Job_ID                   = @Lc_Job_ID,
    @As_Process_NAME             = @Ls_Process_NAME,
    @As_Procedure_NAME           = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT      = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT        = @Lc_Successful_TEXT,
    @As_ListKey_TEXT             = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE              = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY= @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION DOLQW_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DOLQW_PROCESS;
    END

   IF CURSOR_STATUS ('local', 'ProcessDol_CUR') IN (0, 1)
    BEGIN
     CLOSE ProcessDol_CUR;

     DEALLOCATE ProcessDol_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
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
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
