/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_MEDICAID_TERM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_MEDICAID_TERM
Programmer Name   :	Imp Team
Description       :	This process reads the data from the temporary table and updates the Monthly Grant Modification
					IV-A GRANT (IVMG_Y1) table.
Frequency		  : 					
Developed On      :	2/15/2011
Called BY         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_MEDICAID_TERM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_TypeWelfareM_CODE       CHAR(1) = 'M',
          @Lc_TypeWelfareN_CODE       CHAR(1) = 'N',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_TypeWelfareNonTanf_CODE CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE         CHAR(1) = 'E',
          @Lc_ProcessY_INDC           CHAR(1) = 'Y',
          @Lc_ProcessN_INDC           CHAR(1) = 'N',
          @Lc_CaseRelationshipCp_CODE CHAR(1) = 'C',
          @Lc_StatusCaseOpen_CODE     CHAR(1) = 'O',
          @Lc_MemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_CaseRelationshipD_CODE  CHAR(1) = 'D',
          @Lc_Subsystem_CODE          CHAR(3) = 'CI',
          @Lc_ActivityMajor_CODE      CHAR(4) = 'CASE',
          @Lc_TypeReference_CODE      CHAR(4) = ' ',
          @Lc_ActivityMinorNopri_CODE CHAR(5) = 'NOPRI',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_ErrorE1424_CODE         CHAR(5) = 'E1424',
          @Lc_Job_ID                  CHAR(7) = 'DEB8112',
          @Lc_Notice_ID               CHAR(8) = 'CSM-09',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Lc_Reference_ID            CHAR(30) = ' ',
          @Lc_WorkerDelegate_ID       CHAR(30) = ' ',
          @Lc_Err0002_TEXT            CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_PROCESS_UPDATE_MEDICAID_TERM',
          @Ls_XmlTextIn_TEXT          VARCHAR(8000) = ' ',
          @Ld_Low_DATE                DATE = '01/01/0001',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ln_TopicIn_IDNO                NUMERIC = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_OrderSeq_NUMB               NUMERIC(9) = 0,
          @Ln_OthpSource_IDNO             NUMERIC(9) = 0,
          @Ln_OthpLocation_IDNO           NUMERIC(9) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10) = 0,
          @Ln_Schedule_NUMB               NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowsCount_QNTY              SMALLINT,
          @Lc_IndNote_TEXT                CHAR(1) = '',
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_ReasonStatus_CODE           CHAR(2) = '',
          @Lc_OthStateFips_CODE           CHAR(2) = '',
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_BateError_CODE              CHAR(5) = '',
          @Lc_Schedule_Worker_IDNO        CHAR(30) = '',
          @Ls_Schedule_Member_IDNO        VARCHAR(100) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ls_BateRecord1_TEXT            VARCHAR(4000) = '',
          @Ls_Sqldata_TEXT                VARCHAR(5000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_MhisStart_DATE              DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_BeginSch_DTTM               DATETIME2;
  DECLARE IvaMTerm_CUR INSENSITIVE CURSOR FOR
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
     FROM LMAOT_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC;
  DECLARE @Ln_IvaMTermCur_Seq_IDNO                   NUMERIC(19),
          @Lc_IvaMTermCur_CaseWelfareIdno_TEXT       CHAR(10),
          @Lc_IvaMTermCur_CpMciIdno_TEXT             CHAR(10),
          @Lc_IvaMTermCur_NcpMciIdno_TEXT            CHAR(10),
          @Lc_IvaMTermCur_ChildMciIdno_TEXT          CHAR(10),
          @Lc_IvaMTermCur_Program_CODE               CHAR(3),
          @Lc_IvaMTermCur_SubProgram_CODE            CHAR(1),
          @Lc_IvaMTermCur_AgSequenceNumb_TEXT        CHAR(4),
          @Lc_IvaMTermCur_ChildEligibilityDate_TEXT  CHAR(8),
          @Lc_IvaMTermCur_WelfareCaseCountyIdno_TEXT CHAR(3);
  DECLARE @Ln_MhisCaseCur_Case_IDNO NUMERIC(6);
  DECLARE @Ln_IvaMTermCurCaseWelfare_IDNO      NUMERIC(10),
          @Ln_IvaMTermCurCpMci_IDNO            NUMERIC(10),
          @Ln_IvaMTermCurChildMci_IDNO         NUMERIC(10),
          @Ld_IvaMTermCurChildEligibility_DATE DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION IVAMTERM_PROCESS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
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

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND r.Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LINE NUMBER = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN IvaMTerm_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   OPEN IvaMTerm_CUR;

   SET @Ls_Sql_TEXT = 'FETCH IvaMTerm_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   FETCH NEXT FROM IvaMTerm_CUR INTO @Ln_IvaMTermCur_Seq_IDNO, @Lc_IvaMTermCur_CaseWelfareIdno_TEXT, @Lc_IvaMTermCur_CpMciIdno_TEXT, @Lc_IvaMTermCur_NcpMciIdno_TEXT, @Lc_IvaMTermCur_ChildMciIdno_TEXT, @Lc_IvaMTermCur_Program_CODE, @Lc_IvaMTermCur_SubProgram_CODE, @Lc_IvaMTermCur_AgSequenceNumb_TEXT, @Lc_IvaMTermCur_ChildEligibilityDate_TEXT, @Lc_IvaMTermCur_WelfareCaseCountyIdno_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   -- Fetch each record to process
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_BateRecord_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_IvaMTermCur_Seq_IDNO AS VARCHAR)) + ', Welfare Case Idno = ' + @Lc_IvaMTermCur_CaseWelfareIdno_TEXT + ', Cp Member Mci = ' + @Lc_IvaMTermCur_CpMciIdno_TEXT + ', Ncp Member Mci = ' + @Lc_IvaMTermCur_NcpMciIdno_TEXT + ', Child Member Mci = ' + @Lc_IvaMTermCur_ChildMciIdno_TEXT + ', Program Code = ' + @Lc_IvaMTermCur_Program_CODE + ', Sub Program Code = ' + @Lc_IvaMTermCur_SubProgram_CODE + ', Ag Sequence Number = ' + @Lc_IvaMTermCur_AgSequenceNumb_TEXT + ', Child Eligibility Date = ' + @Lc_IvaMTermCur_ChildEligibilityDate_TEXT + ', Case County Idno = ' + @Lc_IvaMTermCur_WelfareCaseCountyIdno_TEXT;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'IVA Medicaid Termination - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVESIVAMTERM_PROCESS;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_IvaMTermCur_CaseWelfareIdno_TEXT))) = 1
         AND ISNUMERIC(LTRIM(RTRIM(@Lc_IvaMTermCur_ChildMciIdno_TEXT))) = 1
         AND ISNUMERIC(LTRIM(RTRIM(@Lc_IvaMTermCur_CpMciIdno_TEXT))) = 1
         AND ISNUMERIC(LTRIM(RTRIM(@Lc_IvaMTermCur_NcpMciIdno_TEXT))) = 1
         AND ISDATE(@Lc_IvaMTermCur_ChildEligibilityDate_TEXT) = 1
       BEGIN
        SET @Ln_IvaMTermCurCaseWelfare_IDNO = CAST(@Lc_IvaMTermCur_CaseWelfareIdno_TEXT AS NUMERIC);
        SET @Ln_IvaMTermCurCpMci_IDNO = CAST(@Lc_IvaMTermCur_CpMciIdno_TEXT AS NUMERIC);
        SET @Ln_IvaMTermCurChildMci_IDNO = CAST(@Lc_IvaMTermCur_ChildMciIdno_TEXT AS NUMERIC);
        SET @Ld_IvaMTermCurChildEligibility_DATE = CAST(@Lc_IvaMTermCur_ChildEligibilityDate_TEXT AS DATE);

        IF EXISTS(SELECT 1
                    FROM MHIS_Y1 m,
                         CMEM_Y1 c,
                         CASE_Y1 s,
                         CMEM_Y1 a
                   WHERE m.CaseWelfare_IDNO = @Ln_IvaMTermCurCaseWelfare_IDNO
                     AND m.MemberMci_IDNO = @Ln_IvaMTermCurChildMci_IDNO
                     AND m.MemberMci_IDNO = c.MemberMci_IDNO
                     AND @Ld_Run_DATE BETWEEN m.Start_DATE AND m.End_DATE
                     AND m.TypeWelfare_CODE = @Lc_TypeWelfareM_CODE
                     AND m.Case_IDNO = s.Case_IDNO
                     AND m.Case_IDNO = c.Case_IDNO
                     AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                     AND c.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
                     AND c.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
                     AND c.Case_IDNO = a.Case_IDNO
                     AND a.MemberMci_IDNO = @Ln_IvaMTermCurCpMci_IDNO
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
            WHERE m.CaseWelfare_IDNO = @Ln_IvaMTermCurCaseWelfare_IDNO
              AND m.MemberMci_IDNO = @Ln_IvaMTermCurChildMci_IDNO
              AND m.MemberMci_IDNO = c.MemberMci_IDNO
              AND @Ld_Run_DATE BETWEEN m.Start_DATE AND m.End_DATE
              AND m.TypeWelfare_CODE = @Lc_TypeWelfareM_CODE
              AND m.Case_IDNO = s.Case_IDNO
              AND m.Case_IDNO = c.Case_IDNO
              AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
              AND c.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
              AND c.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
              AND c.Case_IDNO = a.Case_IDNO
              AND a.MemberMci_IDNO = @Ln_IvaMTermCurCpMci_IDNO
              AND a.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
              AND a.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE;

           SET @Ld_MhisStart_DATE = DATEADD (DAY, 1, @Ld_IvaMTermCurChildEligibility_DATE);
           SET @Ls_Sql_TEXT = 'OPEN MhisCase_Cur';
           SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID;

           OPEN MhisCase_Cur;

           SET @Ls_Sql_TEXT = 'FETCH MhisCase_Cur - 1';
           SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID;

           FETCH NEXT FROM MhisCase_Cur INTO @Ln_MhisCaseCur_Case_IDNO;

           SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

           --fetch each child records
           WHILE @Li_FetchStatus_QNTY = 0
            BEGIN
             SET @Ls_Sql_TEXT = 'BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS FOR CHILD';
             SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_MhisStart_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_IvaMTermCurChildMci_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_IvaMTermCurCaseWelfare_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfareN_CODE, '');

             EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
              @Ad_Run_DATE              = @Ld_Run_DATE,
              @Ad_Start_DATE            = @Ld_MhisStart_DATE,
              @Ac_Job_ID                = @Lc_Job_ID,
              @An_Case_IDNO             = @Ln_MhisCaseCur_Case_IDNO,
              @An_MemberMci_IDNO        = @Ln_IvaMTermCurChildMci_IDNO,
              @An_CaseWelfare_IDNO      = @Ln_IvaMTermCurCaseWelfare_IDNO,
              @Ac_TypeWelfare_CODE      = @Lc_TypeWelfareN_CODE,
              @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR (50001,16,1);
              END

             SET @Ls_Sql_TEXT = 'CHECK FOR CP TYPE CHANGE';
             SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID;

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
                               AND TypeWelfare_CODE <> @Lc_TypeWelfareNonTanf_CODE)
               AND EXISTS (SELECT 1
                             FROM CASE_Y1 c
                            WHERE c.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                              AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)                               
                AND EXISTS (SELECT 1
                              FROM MHIS_Y1 m
                             WHERE m.Case_IDNO = @Ln_MhisCaseCur_Case_IDNO
                               AND m.MemberMci_IDNO = @Ln_IvaMTermCurCpMci_IDNO
                               AND m.End_DATE = @Ld_High_DATE
                               AND m.TypeWelfare_CODE <> @Lc_TypeWelfareNonTanf_CODE)
              BEGIN
               SET @Ls_Sql_TEXT = 'EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS FOR CP ';
               SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_MhisStart_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_IvaMTermCurCpMci_IDNO AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_IvaMTermCurCaseWelfare_IDNO AS VARCHAR), '') + ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfareN_CODE, '');

               EXECUTE BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
                @Ad_Run_DATE              = @Ld_Run_DATE,
                @Ad_Start_DATE            = @Ld_MhisStart_DATE,
                @Ac_Job_ID                = @Lc_Job_ID,
                @An_Case_IDNO             = @Ln_MhisCaseCur_Case_IDNO,
                @An_MemberMci_IDNO        = @Ln_IvaMTermCurCpMci_IDNO,
                @An_CaseWelfare_IDNO      = @Ln_IvaMTermCurCaseWelfare_IDNO,
                @Ac_TypeWelfare_CODE      = @Lc_TypeWelfareN_CODE,
                @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
                @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

               IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                BEGIN
                 RAISERROR(50001,16,1);
                END

               SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
               SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(0 AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

			   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT  
				 @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				 @Ac_Process_ID               = @Lc_Job_ID,
				 @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
				 @Ac_Note_INDC                = @Lc_IndNote_TEXT,
				 @An_EventFunctionalSeq_NUMB  = 0,
				 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
				 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

               IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
                BEGIN
                 RAISERROR (50001,16,1);
                END

               SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_IvaMTermCurCpMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorNopri_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Ls_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '');

               EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
                @An_Case_IDNO                = @Ln_MhisCaseCur_Case_IDNO,
                @An_MemberMci_IDNO           = @Ln_IvaMTermCurCpMci_IDNO,
                @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
                @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNopri_CODE,
                @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
                @As_DescriptionNote_TEXT     = @Lc_Space_TEXT,
                @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
                @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
                @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
                @Ac_SignedonWorker_ID        = @Lc_Space_TEXT,
                @Ad_Run_DATE                 = @Ld_Run_DATE,
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
				   SET @Ls_Sqldata_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_IvaMTermCur_Seq_IDNO AS VARCHAR)) + ', Welfare Case Idno = ' + @Lc_IvaMTermCur_CaseWelfareIdno_TEXT + ', Case_IDNO = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR) + ', Cp Member Mci = ' + @Lc_IvaMTermCur_CpMciIdno_TEXT + ', Ncp Member Mci = ' + @Lc_IvaMTermCur_NcpMciIdno_TEXT + ', Child Member Mci = ' + @Lc_IvaMTermCur_ChildMciIdno_TEXT + @Ls_Sqldata_TEXT;
				   SET @Ls_BateRecord1_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT + ', Case_IDNO = ' + CAST(@Ln_MhisCaseCur_Case_IDNO AS VARCHAR);

				   IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_Space_TEXT)
					BEGIN
					 SET @Lc_Msg_CODE = @Lc_BateError_CODE;
					END

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

             FETCH NEXT FROM MhisCase_Cur INTO @Ln_MhisCaseCur_Case_IDNO;

             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
            END

           CLOSE MhisCase_Cur;

           DEALLOCATE MhisCase_Cur;
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVESIVAMTERM_PROCESS;
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

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_IvaMTermCur_Seq_IDNO AS VARCHAR)) + ', Welfare Case Idno = ' + @Lc_IvaMTermCur_CaseWelfareIdno_TEXT + ', Cp Member Mci = ' + @Lc_IvaMTermCur_CpMciIdno_TEXT + ', Ncp Member Mci = ' + @Lc_IvaMTermCur_NcpMciIdno_TEXT + ', Child Member Mci = ' + @Lc_IvaMTermCur_ChildMciIdno_TEXT;
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
         SET @Ls_DescriptionError_TEXT = @Ls_BateRecord_TEXT;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LMAOT_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IvaMTermCur_Seq_IDNO AS VARCHAR);

     UPDATE LMAOT_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_IvaMTermCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowsCount_QNTY;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowsCount_QNTY;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', RESTART_KEY = ' + ISNULL (CAST (@Ln_RecordCount_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       COMMIT TRANSACTION IVAMTERM_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       BEGIN TRANSACTION IVAMTERM_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION IVAMTERM_PROCESS;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM IvaMTerm_CUR INTO @Ln_IvaMTermCur_Seq_IDNO, @Lc_IvaMTermCur_CaseWelfareIdno_TEXT, @Lc_IvaMTermCur_CpMciIdno_TEXT, @Lc_IvaMTermCur_NcpMciIdno_TEXT, @Lc_IvaMTermCur_ChildMciIdno_TEXT, @Lc_IvaMTermCur_Program_CODE, @Lc_IvaMTermCur_SubProgram_CODE, @Lc_IvaMTermCur_AgSequenceNumb_TEXT, @Lc_IvaMTermCur_ChildEligibilityDate_TEXT, @Lc_IvaMTermCur_WelfareCaseCountyIdno_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

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

   CLOSE IvaMTerm_CUR;

   DEALLOCATE IvaMTerm_CUR;

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

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION IVAMTERM_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVAMTERM_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'IvaMTerm_CUR') IN (0, 1)
    BEGIN
     CLOSE IvaMTerm_CUR;

     DEALLOCATE IvaMTerm_CUR;
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
