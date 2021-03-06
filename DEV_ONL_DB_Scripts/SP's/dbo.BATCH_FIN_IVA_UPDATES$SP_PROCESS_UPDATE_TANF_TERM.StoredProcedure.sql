/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_TANF_TERM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_TANF_TERM
Programmer Name   :	Imp Team
Description       :	This  process reads the temporary table and compares the incoming TANF termination records 
					and updates Member Welfare History table, MHIS_Y1, for following conditions:  
						a)current TANF is terminated and the members are not eligible for TANF or Medicaid, or
						b)current TANF is terminated and the members are eligible for Medicaid, or 
						c)current TANF is terminated and the members are eligible for Purchase of care.
Frequency         :	MONTHLY
Developed On      :	2/16/2011
Called BY         :	None
Called On		  :	
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_TANF_TERM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_TypeWelfareM_CODE       CHAR(1) = 'M',
          @Lc_TypeWelfareN_CODE       CHAR(1) = 'N',
          @Lc_ProgramTanf_CODE        CHAR(1) = 'A',
          @Lc_ProgramMedicaid_CODE    CHAR(1) = 'M',
          @Lc_ProgramCc_CODE          CHAR(1) = 'C',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_IndNote_TEXT            CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE         CHAR(1) = 'E',
          @Lc_ProcessY_INDC           CHAR(1) = 'Y',
          @Lc_ProcessN_INDC           CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE     CHAR(1) = 'O',
          @Lc_MemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipD_CODE  CHAR(1) = 'D',
          @Lc_CaseRelationshipCp_CODE CHAR(1) = 'C',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_Subsystem_CODE          CHAR(3) = 'CI',
          @Lc_ActivityMajor_CODE      CHAR(4) = 'CASE',
          @Lc_TypeReference_CODE      CHAR(4) = ' ',
          @Lc_Msg_CODE                CHAR(5) = ' ',
          @Lc_ActivityMinorNopri_CODE CHAR(5) = 'NOPRI',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_ErrorE1424_CODE		  CHAR(5) = 'E1424',
          @Lc_BateError_CODE          CHAR(5) = '',
          @Lc_Job_ID                  CHAR(7) = 'DEB8114',
          @Lc_Notice_ID               CHAR(8) = 'CSM-09',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0001_TEXT            CHAR(30) = 'INSERT NOT SUCCESSFUL',          
          @Lc_Err0002_TEXT            CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_WorkerDelegate_ID       CHAR(30) = ' ',
          @Lc_Reference_ID            CHAR(30) = ' ',
          @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_PROCESS_UPDATE_TANF_TERM',
          @Ls_CursorLocation_TEXT     VARCHAR(200) = ' ',
          @Ls_Sql_TEXT                VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT       VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT   VARCHAR(4000) = ' ',
          @Ls_BateRecord_TEXT         VARCHAR(4000) = ' ',
          @Ls_BateRecord1_TEXT        VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT            VARCHAR(5000) = ' ',
          @Ls_XmlTextIn_TEXT          VARCHAR(8000) = ' ',
          @Ld_High_DATE               DATE = '12/31/9999',
          @Ld_Low_DATE                DATE = '01/01/0001';
  DECLARE @Ln_TopicIn_IDNO                NUMERIC = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_Zero_NUMB                   NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB            NUMERIC(5) = 0,
		  @Ln_MhisStartYyyymm_DATE        NUMERIC(6) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_OthpLocation_IDNO           NUMERIC(9) = 0,
          @Ln_OrderSeq_NUMB               NUMERIC(9) = 0,
          @Ln_OthpSource_IDNO             NUMERIC(9) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10)= 0,
          @Ln_Schedule_NUMB               NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowsCount_QNTY              SMALLINT,
          @Lc_TypeWelfare_CODE            CHAR(1) = '',
          @Lc_ReasonStatus_CODE           CHAR(2) = '',
          @Lc_OthStateFips_CODE           CHAR(2) = '',
          @Lc_Schedule_Worker_IDNO        CHAR(30) = '',
          @Ls_Schedule_Member_IDNO        VARCHAR(100) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_MhisStart_DATE              DATE,
          @Ld_BeginSch_DTTM               DATETIME2,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE IvaTfTerm_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.CaseWelfare_IDNO,
          a.CpMci_IDNO,
          a.NcpMci_IDNO,
          a.ChildMci_IDNO,
          a.Program_CODE,
          a.SubProgram_CODE,
          a.AgSequence_NUMB,
          a.ChildEligibility_DATE,
          a.WelfareCaseCounty_IDNO
     FROM LTNFT_Y1 a 
    WHERE a.Process_INDC = @Lc_ProcessN_INDC;
  DECLARE @Ln_IvaTfTermCur_Seq_IDNO                   NUMERIC(19),
          @Lc_IvaTfTermCur_CaseWelfareIdno_TEXT       CHAR(10),
          @Lc_IvaTfTermCur_CpMciIdno_TEXT             CHAR(10),
          @Lc_IvaTfTermCur_NcpMciIdno_TEXT            CHAR(10),
          @Lc_IvaTfTermCur_ChildMciIdno_TEXT          CHAR(10),
          @Lc_IvaTfTermCur_Program_CODE               CHAR(3),
          @Lc_IvaTfTermCur_SubProgram_CODE            CHAR(1),
          @Lc_IvaTfTermCur_AgSequenceNumb_TEXT        CHAR(4),
          @Lc_IvaTfTermCur_ChildEligibilityDate_TEXT  CHAR(8),
          @Lc_IvaTfTermCur_WelfareCaseCountyIdno_TEXT CHAR(3);
  DECLARE @Ln_MhisCaseCur_Case_IDNO NUMERIC(6);
  DECLARE @Ln_IvaTfTermCurCaseWelfare_IDNO      NUMERIC(10),
          @Ln_IvaTfTermCurCpMci_IDNO            NUMERIC(10),
          @Ln_IvaTfTermCurChildMci_IDNO         NUMERIC(10),
          @Ld_IvaTfTermCurChildEligibility_DATE DATE;
  DECLARE @Ln_IvaSplitIvmgCurCaseWelfare_IDNO   NUMERIC(10),
		  @Ln_IvaSplitIvmgCurCpMci_IDNO			NUMERIC(10);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVATFTERM_PROCESS;

   CREATE TABLE #IvaSplitIvmg_P1
    (
      CaseWelfare_IDNO NUMERIC(10),
      CpMci_IDNO  NUMERIC(10)
    );

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'JOB_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN IvaTfTerm_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN IvaTfTerm_CUR;

   SET @Ls_Sql_TEXT = 'FETCH IvaTfTerm_CUR';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM IvaTfTerm_CUR INTO @Ln_IvaTfTermCur_Seq_IDNO, @Lc_IvaTfTermCur_CaseWelfareIdno_TEXT, @Lc_IvaTfTermCur_CpMciIdno_TEXT, @Lc_IvaTfTermCur_NcpMciIdno_TEXT, @Lc_IvaTfTermCur_ChildMciIdno_TEXT, @Lc_IvaTfTermCur_Program_CODE, @Lc_IvaTfTermCur_SubProgram_CODE, @Lc_IvaTfTermCur_AgSequenceNumb_TEXT, @Lc_IvaTfTermCur_ChildEligibilityDate_TEXT, @Lc_IvaTfTermCur_WelfareCaseCountyIdno_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   -- Fetch each record to process.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_BateRecord_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_IvaTfTermCur_Seq_IDNO AS VARCHAR)) + ', Welfare Case Idno = ' + @Lc_IvaTfTermCur_CaseWelfareIdno_TEXT + ', Cp Member Mci = ' + @Lc_IvaTfTermCur_CpMciIdno_TEXT + ', Ncp Member Mci = ' + @Lc_IvaTfTermCur_NcpMciIdno_TEXT + ', Child Member Mci = ' + @Lc_IvaTfTermCur_ChildMciIdno_TEXT + ', Program Code = ' + @Lc_IvaTfTermCur_Program_CODE + ', Sub Program Code = ' + @Lc_IvaTfTermCur_SubProgram_CODE + ', Ag Sequence Number = ' + @Lc_IvaTfTermCur_AgSequenceNumb_TEXT + ', Child Eligibility Date = ' + @Lc_IvaTfTermCur_ChildEligibilityDate_TEXT + ', Count Idno = ' + @Lc_IvaTfTermCur_WelfareCaseCountyIdno_TEXT;
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'IVA Tanf Termination - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      SAVE TRANSACTION SAVEIVATFTERM_PROCESS;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_IvaTfTermCur_CaseWelfareIdno_TEXT))) = 1
         AND ISNUMERIC(LTRIM(RTRIM(@Lc_IvaTfTermCur_ChildMciIdno_TEXT))) = 1
         AND ISNUMERIC(ISNULL(LTRIM(RTRIM(@Lc_IvaTfTermCur_CpMciIdno_TEXT)), 0)) = 1
         AND ISDATE(@Lc_IvaTfTermCur_ChildEligibilityDate_TEXT) = 1
       BEGIN
        SET @Ln_IvaTfTermCurCaseWelfare_IDNO = CAST(@Lc_IvaTfTermCur_CaseWelfareIdno_TEXT AS NUMERIC);
        SET @Ln_IvaTfTermCurCpMci_IDNO = CAST(@Lc_IvaTfTermCur_CpMciIdno_TEXT AS NUMERIC);
        SET @Ln_IvaTfTermCurChildMci_IDNO = CAST(@Lc_IvaTfTermCur_ChildMciIdno_TEXT AS NUMERIC);
        SET @Ld_IvaTfTermCurChildEligibility_DATE = CAST(@Lc_IvaTfTermCur_ChildEligibilityDate_TEXT AS DATE);

        IF SUBSTRING(@Lc_IvaTfTermCur_Program_CODE, 1, 1) IN (@Lc_ProgramTanf_CODE, @Lc_ProgramCc_CODE)
         BEGIN
          SET @Lc_TypeWelfare_CODE = @Lc_TypeWelfareN_CODE;
         END
        ELSE IF SUBSTRING(@Lc_IvaTfTermCur_Program_CODE, 1, 1) = @Lc_ProgramMedicaid_CODE
         BEGIN
          SET @Lc_TypeWelfare_CODE = @Lc_TypeWelfareM_CODE;
         END

	    SET @Ld_MhisStart_DATE = DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, @Ld_IvaTfTermCurChildEligibility_DATE)) - 1), DATEADD(MONTH, 1, @Ld_IvaTfTermCurChildEligibility_DATE));
	    SET @Ln_MhisStartYyyymm_DATE = CAST(CONVERT(VARCHAR(6),@Ld_MhisStart_DATE, 112) AS NUMERIC);

        IF EXISTS(SELECT 1
                    FROM MHIS_Y1 m,
                         CMEM_Y1 c,
                         CASE_Y1 s,
                         CMEM_Y1 a
                   WHERE CaseWelfare_IDNO = @Ln_IvaTfTermCurCaseWelfare_IDNO
                     AND m.MemberMci_IDNO = @Ln_IvaTfTermCurChildMci_IDNO
					 AND m.MemberMci_IDNO = c.MemberMci_IDNO
                     AND DATEADD(DAY,-1, @Ld_MhisStart_DATE) BETWEEN m.Start_DATE AND m.End_DATE
                     AND m.TypeWelfare_CODE = @Lc_ProgramTanf_CODE
                     AND m.Case_IDNO = s.Case_IDNO
                     AND m.Case_IDNO = c.Case_IDNO
                     AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                     AND c.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
                     AND c.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                     AND c.Case_IDNO = a.Case_IDNO
                     AND a.MemberMci_IDNO = @Ln_IvaTfTermCurCpMci_IDNO
                     AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                     AND a.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE)
         BEGIN
          DECLARE MhisCase_Cur INSENSITIVE CURSOR FOR
           SELECT DISTINCT
                  m.Case_IDNO
             FROM MHIS_Y1 m,
                  CMEM_Y1 c,
                  CASE_Y1 s,
                  CMEM_Y1 a
            WHERE m.CaseWelfare_IDNO = @Ln_IvaTfTermCurCaseWelfare_IDNO
              AND m.MemberMci_IDNO = @Ln_IvaTfTermCurChildMci_IDNO
              AND m.MemberMci_IDNO = c.MemberMci_IDNO
			  AND DATEADD(DAY,-1, @Ld_MhisStart_DATE) BETWEEN m.Start_DATE AND m.End_DATE
              AND m.TypeWelfare_CODE = @Lc_ProgramTanf_CODE
              AND m.Case_IDNO = s.Case_IDNO
              AND m.Case_IDNO = c.Case_IDNO
              AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
              AND c.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
              AND c.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
              AND c.Case_IDNO = a.Case_IDNO
              AND a.MemberMci_IDNO = @Ln_IvaTfTermCurCpMci_IDNO
              AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
              AND a.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE;

          SET @Ls_Sql_TEXT = 'OPEN MhisCase_Cur';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

          OPEN MhisCase_Cur;

          SET @Ls_Sql_TEXT = 'FETCH MhisCase_Cur - 1';
          SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

          FETCH NEXT FROM MhisCase_Cur INTO @Ln_MhisCaseCur_Case_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

          -- fetch each case
          WHILE (@Li_FetchStatus_QNTY = 0)
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS FOR CHILD';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Case Idno = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR) + ', Child Mci = ' + CAST(@Ln_IvaTfTermCurChildMci_IDNO AS VARCHAR) + ', Welfare Case Idno = ' + CAST(@Ln_IvaTfTermCurCaseWelfare_IDNO AS VARCHAR) + ', Run Date = ' + CAST(@Ld_MhisStart_DATE AS VARCHAR) + ', Mhis Start Date = ' + CAST(@Ld_MhisStart_DATE AS VARCHAR) + ', Welfare Type Code = ' + @Lc_TypeWelfare_CODE;

            EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
             @Ad_Run_DATE              = @Ld_MhisStart_DATE,
             @Ad_Start_DATE            = @Ld_MhisStart_DATE,
             @Ac_Job_ID                = @Lc_Job_ID,
             @An_Case_IDNO             = @Ln_MhisCaseCur_Case_IDNO,
             @An_MemberMci_IDNO        = @Ln_IvaTfTermCurChildMci_IDNO,
             @An_CaseWelfare_IDNO      = @Ln_IvaTfTermCurCaseWelfare_IDNO,
             @Ac_TypeWelfare_CODE      = @Lc_TypeWelfare_CODE,
             @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR(50001,16,1);
             END

            SET @Ls_Sql_TEXT = 'CHECK FOR CP TYPE CHANGE';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

            IF NOT EXISTS (SELECT 1
                             FROM MHIS_Y1 m
                            WHERE m.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                              AND m.MemberMci_IDNO IN (SELECT DISTINCT
                                                              MemberMci_IDNO
                                                         FROM CMEM_Y1
                                                        WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                                                          AND CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
                                                          AND CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE)
                              AND End_DATE = @Ld_High_DATE
                              AND TypeWelfare_CODE <> @Lc_TypeWelfare_CODE
                              )
               AND EXISTS (SELECT 1
                             FROM CASE_Y1 c
                            WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                              AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
               AND EXISTS (SELECT 1
                             FROM MHIS_Y1 m
                            WHERE m.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                              AND m.MemberMci_IDNO = @Ln_IvaTfTermCurCpMci_IDNO
							  AND m.TypeWelfare_CODE = @Lc_ProgramTanf_CODE
                              AND m.CaseWelfare_IDNO = @Ln_IvaTfTermCurCaseWelfare_IDNO
                              AND @Ld_Run_DATE BETWEEN m.Start_DATE AND m.End_DATE)
             BEGIN
              SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS FOR CP ';
              SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Case Idno = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR) + ', Cp Mci = ' + CAST(@Ln_IvaTfTermCurCpMci_IDNO AS VARCHAR) + ', Welfare Case Idno = ' + CAST(@Ln_IvaTfTermCurCaseWelfare_IDNO AS VARCHAR) + ', Run Date = ' + CAST(@Ld_MhisStart_DATE AS VARCHAR) + ', Mhis Start Date = ' + CAST(@Ld_MhisStart_DATE AS VARCHAR) + ', Welfare Type Code = ' + @Lc_TypeWelfare_CODE;

              EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
               @Ad_Run_DATE              = @Ld_MhisStart_DATE,
               @Ad_Start_DATE            = @Ld_MhisStart_DATE,
               @Ac_Job_ID                = @Lc_Job_ID,
               @An_Case_IDNO             = @Ln_MhisCaseCur_Case_IDNO,
               @An_MemberMci_IDNO        = @Ln_IvaTfTermCurCpMci_IDNO,
               @An_CaseWelfare_IDNO      = @Ln_IvaTfTermCurCaseWelfare_IDNO,
               @Ac_TypeWelfare_CODE      = @Lc_TypeWelfare_CODE,
               @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
               @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
               
              IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
               BEGIN
                RAISERROR(50001,16,1);
               END

              IF EXISTS (SELECT 1
                           FROM CASE_Y1
                          WHERE Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                            AND TypeCase_CODE = @Lc_TypeWelfareN_CODE)
               BEGIN
                SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
                SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', IndNote_TEXT = ' + @Lc_IndNote_TEXT + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

				EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT  
				 @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				 @Ac_Process_ID               = @Lc_Job_ID,
				 @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
				 @Ac_Note_INDC                = @Lc_IndNote_TEXT,
				 @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
				 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
				 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

                IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                 BEGIN
                  RAISERROR (50001,16,1);
                 END

                SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
                SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_IvaTfTermCurCpMci_IDNO AS VARCHAR) + ', ActivityMajor_CODE = ' + @Lc_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorNopri_CODE + ', ReasonStatus_CODE = ' + @Lc_ReasonStatus_CODE + ', DescriptionNote_TEXT = ' + @Lc_Space_TEXT + ', Subsystem_CODE = ' + @Lc_Subsystem_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', WorkerDelegate_ID = ' + @Lc_WorkerDelegate_ID + ', SignedonWorker_ID = ' + @Lc_Space_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeReference_CODE = ' + @Lc_TypeReference_CODE + ', Reference_ID = ' + @Lc_Reference_ID + ', Notice_ID = ' + @Lc_Notice_ID + ', TopicIn_IDNO = ' + CAST(@Ln_TopicIn_IDNO AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', XmlTextIn_TEXT = ' + @Ls_XmlTextIn_TEXT + ', MajorIntSeq_NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + ', MinorIntSeq_NUMB = ' + CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR) + ', Schedule_NUMB = ' + CAST(@Ln_Schedule_NUMB AS VARCHAR) + ', Schedule_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + CAST(@Ln_OthpLocation_IDNO AS VARCHAR) + ', Schedule_Worker_IDNO = ' + @Lc_Schedule_Worker_IDNO + ', Schedule_Member_IDNO = ' + @Ls_Schedule_Member_IDNO + ', OthpSource_IDNO = ' + CAST(@Ln_OthpSource_IDNO AS VARCHAR) + ', OthStateFips_CODE = ' + @Lc_OthStateFips_CODE + ', Schedule_NUMB = ' + CAST(@Ln_Schedule_NUMB AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_OrderSeq_NUMB AS VARCHAR);

                EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
                 @An_Case_IDNO                = @Ln_MhisCaseCur_Case_IDNO,
                 @An_MemberMci_IDNO           = @Ln_IvaTfTermCurCpMci_IDNO,
                 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
                 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNopri_CODE,
                 @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
                 @As_DescriptionNote_TEXT     = @Lc_Space_TEXT,
                 @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
                 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
                 @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
                 @Ac_SignedonWorker_ID        = @Lc_Space_TEXT,
                 @Ad_Run_DATE                 = @Ld_MhisStart_DATE,
                 @Ac_TypeReference_CODE       = @Lc_TypeReference_CODE,
                 @Ac_Reference_ID             = @Lc_Reference_ID,
                 @Ac_Notice_ID                = @Lc_Notice_ID,
                 @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
                 @Ac_Job_ID                   = @Lc_Job_ID,
                 @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
                 @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
                 @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
                 @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
                 @Ad_Schedule_DATE            = @Ld_Low_DATE,
                 @Ad_BeginSch_DTTM            = @Ld_BeginSch_DTTM,
                 @An_OthpLocation_IDNO        = @Ln_OthpLocation_IDNO,
                 @Ac_ScheduleWorker_ID        = @Lc_Schedule_Worker_IDNO,
                 @As_ScheduleListMemberMci_ID = @Ls_Schedule_Member_IDNO,
                 @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
                 @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
                 @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
                 @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
                 @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
                 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
                 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

                IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
                 BEGIN
                   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - BATCH_COMMON$SP_INSERT_ACTIVITY ISSUE';
				   SET @Ls_Sqldata_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_IvaTfTermCur_Seq_IDNO AS VARCHAR)) + ', Welfare Case Idno = ' + @Lc_IvaTfTermCur_CaseWelfareIdno_TEXT + ', Case_IDNO = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR) + ', Cp Member Mci = ' + @Lc_IvaTfTermCur_CpMciIdno_TEXT + ', Ncp Member Mci = ' + @Lc_IvaTfTermCur_NcpMciIdno_TEXT + ', Child Member Mci = ' + @Lc_IvaTfTermCur_ChildMciIdno_TEXT;
				   SET @Ls_BateRecord1_TEXT = 'Error record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT + ', Case_IDNO = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR);

				   EXECUTE BATCH_COMMON$SP_BATE_LOG
					@As_Process_NAME             = @Ls_Process_NAME,
					@As_Procedure_NAME           = @Ls_Procedure_NAME,
					@Ac_Job_ID                   = @Lc_Job_ID,
					@Ad_Run_DATE                 = @Ld_Run_DATE,
					@Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
					@An_Line_NUMB                = @Ln_RestartLine_NUMB,
					@Ac_Error_CODE               = @Lc_Msg_CODE,
					@As_DescriptionError_TEXT    = @Ls_BateRecord1_TEXT,
					@As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
					@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
					@As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

				   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					BEGIN
					 RAISERROR (50001,16,1);
					END                
                 END;
               END
             END

            FETCH NEXT FROM MhisCase_Cur INTO @Ln_MhisCaseCur_Case_IDNO;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END

          CLOSE MhisCase_Cur;

          DEALLOCATE MhisCase_Cur;

	   IF NOT EXISTS (SELECT 1 
						FROM #IvaSplitIvmg_P1 a
					   WHERE CaseWelfare_IDNO = @Ln_IvaTfTermCurCaseWelfare_IDNO
						 AND CpMci_IDNO = @Ln_IvaTfTermCurCpMci_IDNO)
		BEGIN
            SET @Ls_Sql_TEXT = 'INSERT INTO #IvaSplitIvmg_P1';
            SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + CAST(@Ln_IvaTfTermCurCaseWelfare_IDNO AS VARCHAR) + ', CpMci_IDNO = ' + CAST(@Ln_IvaTfTermCurCpMci_IDNO AS VARCHAR);
            		
			INSERT INTO #IvaSplitIvmg_P1
				(
				 CaseWelfare_IDNO,
				 CpMci_IDNO
				)
			VALUES (@Ln_IvaTfTermCurCaseWelfare_IDNO, 
					@Ln_IvaTfTermCurCpMci_IDNO)
			
			 SET @Li_RowsCount_QNTY = @@ROWCOUNT;

			 IF @Li_RowsCount_QNTY = 0
			  BEGIN
			   SET @Ls_DescriptionError_TEXT = @Lc_Err0001_TEXT;
			   
			   RAISERROR (50001,16,1);
			  END			
		END
       END
      END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEIVATFTERM_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       IF CURSOR_STATUS ('LOCAL', 'MhisCase_Cur') IN (0, 1)
        BEGIN
         CLOSE MhisCase_Cur;

         DEALLOCATE MhisCase_Cur;
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

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_ErrorE1424_CODE)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_IvaTfTermCur_Seq_IDNO AS VARCHAR)) + ', Welfare Case Idno = ' + @Lc_IvaTfTermCur_CaseWelfareIdno_TEXT + ', Cp Member Mci = ' + @Lc_IvaTfTermCur_CpMciIdno_TEXT + ', Ncp Member Mci = ' + @Lc_IvaTfTermCur_NcpMciIdno_TEXT + ', Child Member Mci = ' + @Lc_IvaTfTermCur_ChildMciIdno_TEXT;
       SET @Ls_BateRecord_TEXT = 'Error record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
         SET @Ls_DescriptionError_TEXT = @Ls_BateRecord_TEXT;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LTNFT_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IvaTfTermCur_Seq_IDNO AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     UPDATE LTNFT_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_IvaTfTermCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM IvaTfTerm_CUR INTO @Ln_IvaTfTermCur_Seq_IDNO, @Lc_IvaTfTermCur_CaseWelfareIdno_TEXT, @Lc_IvaTfTermCur_CpMciIdno_TEXT, @Lc_IvaTfTermCur_NcpMciIdno_TEXT, @Lc_IvaTfTermCur_ChildMciIdno_TEXT, @Lc_IvaTfTermCur_Program_CODE, @Lc_IvaTfTermCur_SubProgram_CODE, @Lc_IvaTfTermCur_AgSequenceNumb_TEXT, @Lc_IvaTfTermCur_ChildEligibilityDate_TEXT, @Lc_IvaTfTermCur_WelfareCaseCountyIdno_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE IvaTfTerm_CUR;

   DEALLOCATE IvaTfTerm_CUR;

  SET @Ls_Sql_TEXT = 'IvaSplitIvmg_CUR CURSOR STARTS - 1';
  SET @Ls_Sqldata_TEXT = '';

  DECLARE IvaSplitIvmg_CUR INSENSITIVE CURSOR FOR
		SELECT CaseWelfare_IDNO,
			   CpMci_IDNO	  
		  FROM #IvaSplitIvmg_P1
		  ORDER BY CaseWelfare_IDNO,
				   CpMci_IDNO

          SET @Ls_Sql_TEXT = 'OPEN IvaSplitIvmg_CUR';
          SET @Ls_Sqldata_TEXT = '';

          OPEN IvaSplitIvmg_CUR;

          SET @Ls_Sql_TEXT = 'FETCH IvaSplitIvmg_CUR - 1';
          SET @Ls_Sqldata_TEXT = '';

          FETCH NEXT FROM IvaSplitIvmg_CUR INTO @Ln_IvaSplitIvmgCurCaseWelfare_IDNO, @Ln_IvaSplitIvmgCurCpMci_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

          -- fetch each case
          WHILE (@Li_FetchStatus_QNTY = 0)
           BEGIN		  
				SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG';
                SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + CAST(@Ln_IvaSplitIvmgCurCaseWelfare_IDNO AS VARCHAR) + 'CpMci_IDNO = ' + CAST(@Ln_IvaSplitIvmgCurCpMci_IDNO AS VARCHAR) + 'WelfareYearMonth_NUMB = ' + CAST(@Ln_MhisStartYyyymm_DATE AS VARCHAR) + 'SignedOnWorker_ID = ' + @Lc_Space_TEXT + 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
				
				EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG
						@An_CaseWelfare_IDNO          = @Ln_IvaSplitIvmgCurCaseWelfare_IDNO,
						@An_CpMci_IDNO                = @Ln_IvaSplitIvmgCurCpMci_IDNO,
						@An_WelfareYearMonth_NUMB     = @Ln_MhisStartYyyymm_DATE,
						@Ac_SignedOnWorker_ID         = @Lc_BatchRunUser_TEXT,
						@Ad_Run_DATE                  = @Ld_Run_DATE,
						@Ac_Job_ID					  = @Lc_Job_ID,
						@Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
						@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT OUTPUT;

				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				  BEGIN
					RAISERROR (50001,16,1);
				  END;
				  
				FETCH NEXT FROM IvaSplitIvmg_CUR INTO @Ln_IvaSplitIvmgCurCaseWelfare_IDNO, @Ln_IvaSplitIvmgCurCpMci_IDNO;

				SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;				  
			END
			
		  CLOSE IvaSplitIvmg_CUR;

          DEALLOCATE IvaSplitIvmg_CUR;


   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE #IvaSplitIvmg_P1 - 1';
   SET @Ls_Sqldata_TEXT =' Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #IvaSplitIvmg_P1;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION IVATFTERM_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVATFTERM_PROCESS;
    END
   
   IF OBJECT_ID('tempdb..#IvaSplitIvmg_P1') IS NOT NULL
    BEGIN
     DROP TABLE #IvaSplitIvmg_P1;
    END
   
   IF CURSOR_STATUS ('LOCAL', 'IvaTfTerm_CUR') IN (0, 1)
    BEGIN
     CLOSE IvaTfTerm_CUR;

     DEALLOCATE IvaTfTerm_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'IvaSplitIvmg_CUR') IN (0, 1)
    BEGIN
     CLOSE IvaSplitIvmg_CUR;

     DEALLOCATE IvaSplitIvmg_CUR;
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
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
