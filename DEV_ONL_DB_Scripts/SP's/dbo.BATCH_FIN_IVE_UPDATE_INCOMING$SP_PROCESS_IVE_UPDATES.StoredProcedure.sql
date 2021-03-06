/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_UPDATE_INCOMING$SP_PROCESS_IVE_UPDATES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_IVE_UPDATE_INCOMING$SP_PROCESS_IVE_UPDATES
Programmer Name   :	IMP Team
Description       :	This process reads the data from the temporary table and generates alerts to the workers.
Frequency         : Daily
Developed On      :	08/10/2011
Called BY         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS2,
						BATCH_COMMON$SP_BATE_LOG,  
						BATCH_COMMON$SP_BSTL_LOG,
						BATCH_COMMON$SP_INSERT_ACTIVITY
--------------------------------------------------------------------------------------------------------------------			
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_UPDATE_INCOMING$SP_PROCESS_IVE_UPDATES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_IndNote_TEXT                  CHAR(1) = 'N',
          @Lc_TypeError_IDNO                CHAR(1) = 'E',
          @Lc_ProcessY_INDC                 CHAR(1) = 'Y',
          @Lc_ProcessN_INDC                 CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_IveCaseF_CODE					CHAR(1) = 'F',
          @Lc_IveCaseJ_CODE					CHAR(1) = 'J',
          @Lc_TypeCaseNivd_CODE             CHAR(1) = 'H',
          @Lc_MemeberStatusActive_CODE		CHAR(1) = 'A',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE       CHAR(1) = 'P',
          @Lc_Dependent_CODE                CHAR(1) = 'D',
          @Lc_ApplicationStatusDeleted_CODE CHAR(1) = 'D',
          @Lc_ApplicationStatusPending_CODE CHAR(1) = 'F',
          @Lc_TprYes_INDC                   CHAR(1) = 'Y',
          @Lc_TypeErrorE_CODE               CHAR(1) = 'E',
          @Lc_Subsystem_CODE                CHAR(3) = 'CM',
          @Lc_NcpRelationFather_CODE        CHAR(3) = 'FTR',
          @Lc_NcpRelationMother_CODE        CHAR(3) = 'MTR',
          @Lc_ActivityMajor_CODE            CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO            CHAR(4) = ' ',
          @Lc_ErrorE0944_CODE               CHAR(5) = 'E0944',
          @Lc_ErrorE0085_CODE               CHAR(5) = 'E0085',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_ErrorE1405_CODE               CHAR(5) = 'E1405',
          @Lc_ErrorE0001_CODE               CHAR(5) = 'E0001',
          @Lc_ErrorE1424_CODE               CHAR(5) = 'E1424',
          @Lc_ActivityMinorMorit_CODE       CHAR(5) = 'MORIT',
          @Lc_ActivityMinorFarit_CODE       CHAR(5) = 'FARIT',
          @Lc_ActivityMinorChrfc_CODE       CHAR(5) = 'CHRFC',
          @Lc_ActivityMinorFcdrc_CODE       CHAR(5) = 'FCDRC',
          @Lc_Job_ID                        CHAR(7) = 'DEB0400',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_WorkerDelegate_ID             CHAR(30) = ' ',
          @Lc_Reference_ID                  CHAR(30) = ' ',
          @Ls_ParmDateProblem_TEXT          VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_FIN_IVE_UPDATE_INCOMING',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_IVE_UPDATES',
          @Ls_XmlTextIn_TEXT                VARCHAR(8000) = ' ',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_TopicIn_IDNO                NUMERIC(1) = 0,
          @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_OthpSource_IDNO             NUMERIC(9) = 0,
          @Ln_OthpLocation_IDNO           NUMERIC(9) = 0,
          @Ln_Schedule_NUMB               NUMERIC(10) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10) = 0,
          @Ln_EventFunctionalSeq_NUMB     NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_MotherMemberMci_IDNO        NUMERIC(10) = 0,
          @Ln_FatherMemberMci_IDNO        NUMERIC(10) = 0,
          @Ln_MotherCaseApplication_IDNO  NUMERIC(10) = 0,
          @Ln_FatherCaseApplication_IDNO  NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowsCount_QNTY              SMALLINT,
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_OthStateFips_CODE           CHAR(2) = '',
          @Lc_ReasonStatus_CODE           CHAR(2) = '',
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_BateError_CODE              CHAR(5) = '',
          @Lc_ActivityMinorMother_CODE    CHAR(5) = '',
          @Lc_ActivityMinorFather_CODE    CHAR(5) = '',
          @Lc_Notice_ID                   CHAR(8) = '',
          @Lc_Schedule_Member_IDNO        CHAR(10) = '',
          @Lc_Schedule_Worker_IDNO        CHAR(30) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionNoteMother_TEXT  VARCHAR(4000) = '',
          @Ls_DescriptionNoteFather_TEXT  VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ls_Sqldata_TEXT                VARCHAR(5000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_BeginSch_DTTM               DATETIME2,
          @Lb_FatherCaseProcess_BIT       BIT = 0,
          @Lb_ChildRemovalDate_BIT        BIT = 0,
          @Lb_MotherCaseProcess_BIT       BIT = 0;
  DECLARE @Ln_IveUpdateCur_Seq_IDNO                   NUMERIC(9),
          @Lc_IveUpdateCur_Rec_ID                     CHAR(1),
          @Lc_IveUpdateCur_MemberMciIdno_TEXT         CHAR(10),
          @Lc_IveUpdateCur_IvePartyIdno_TEXT          CHAR(10),
          @Lc_IveUpdateCur_MotherCaseIdno_TEXT        CHAR(10),
          @Lc_IveUpdateCur_FatherCaseIdno_TEXT        CHAR(10),
          @Lc_IveUpdateCur_RemovalDate_TEXT           CHAR(8),
          @Lc_IveUpdateCur_DeterminationDate_TEXT     CHAR(8),
          @Lc_IveUpdateCur_Determination_CODE         CHAR(1),
          @Lc_IveUpdateCur_MotherTprIndc_TEXT         CHAR(1),
          @Lc_IveUpdateCur_MotherTprDecisionDate_TEXT CHAR(8),
          @Lc_IveUpdateCur_FatherTprIndc_TEXT         CHAR(1),
          @Lc_IveUpdateCur_FatherTprDecisionDate_TEXT CHAR(8),
          @Lc_IveUpdateCur_Worker_NAME                CHAR(40),
          @Lc_IveUpdateCur_WorkPhoneNumb_TEXT         CHAR(10),
          @Lc_IveUpdateCur_Parent_NAME                CHAR(40),
          @Lc_IveUpdateCur_ParentIvePartyIdno_TEXT    CHAR(10),
          @Lc_IveUpdateCur_MemberSsnNumb_TEXT         CHAR(9),
          @Lc_IveUpdateCur_BirthDate_TEXT             CHAR(8);
  DECLARE @Ln_IveUpdateCurMemberMci_IDNO NUMERIC(10),
          @Ln_IveUpdateMotherCase_IDNO   NUMERIC(10),
          @Ln_IveUpdateFatherCase_IDNO   NUMERIC(10),
          @Ld_IveUpdateCurRemoval_DATE   DATE;
  DECLARE IveUpdate_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Rec_ID,
          a.MemberMci_IDNO,
          a.IveParty_IDNO,
          a.MotherCase_IDNO,
          a.FatherCase_IDNO,
          a.Removal_DATE,
          a.Determination_DATE,
          a.Determination_CODE,
          a.MotherTpr_INDC,
          a.MotherTprDecision_DATE,
          a.FatherTpr_INDC,
          a.FatherTprDecision_DATE,
          a.Worker_NAME,
          a.WorkPhone_NUMB,
          a.Parent_NAME,
          a.ParentIveParty_IDNO,
          a.MemberSsn_NUMB,
          a.Birth_DATE
     FROM LFIVE_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC;
    
  BEGIN TRY
   BEGIN TRANSACTION IVEUPDATE_PROCESS;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
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
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 a
    WHERE Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', NO_LINE = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   -- Cursor starts 		
   SET @Ls_Sql_TEXT = 'OPEN IveUpdate_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   OPEN IveUpdate_CUR;

   SET @Ls_Sql_TEXT = 'FETCH IveUpdate_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   FETCH NEXT FROM IveUpdate_CUR INTO @Ln_IveUpdateCur_Seq_IDNO, @Lc_IveUpdateCur_Rec_ID, @Lc_IveUpdateCur_MemberMciIdno_TEXT, @Lc_IveUpdateCur_IvePartyIdno_TEXT, @Lc_IveUpdateCur_MotherCaseIdno_TEXT, @Lc_IveUpdateCur_FatherCaseIdno_TEXT, @Lc_IveUpdateCur_RemovalDate_TEXT, @Lc_IveUpdateCur_DeterminationDate_TEXT, @Lc_IveUpdateCur_Determination_CODE, @Lc_IveUpdateCur_MotherTprIndc_TEXT, @Lc_IveUpdateCur_MotherTprDecisionDate_TEXT, @Lc_IveUpdateCur_FatherTprIndc_TEXT, @Lc_IveUpdateCur_FatherTprDecisionDate_TEXT, @Lc_IveUpdateCur_Worker_NAME, @Lc_IveUpdateCur_WorkPhoneNumb_TEXT, @Lc_IveUpdateCur_Parent_NAME, @Lc_IveUpdateCur_ParentIvePartyIdno_TEXT, @Lc_IveUpdateCur_MemberSsnNumb_TEXT, @Lc_IveUpdateCur_BirthDate_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Cursor will process rach unprocessed records.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVEIVEUPDATE_PROCESS;

      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lb_ChildRemovalDate_BIT = 0;
      SET @Lb_MotherCaseProcess_BIT = 0;
      SET @Lb_FatherCaseProcess_BIT = 0;
      SET @Ln_TransactionEventSeq_NUMB = 0;
	  SET @Lc_ActivityMinorMother_CODE = '';
	  SET @Lc_ActivityMinorFather_CODE = '';
      SET @Ls_DescriptionNoteMother_TEXT = '';
      SET @Ls_DescriptionNoteFather_TEXT = '';
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'IveUpdate - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'Sequence Idno = ' + CAST(@Ln_IveUpdateCur_Seq_IDNO AS VARCHAR) + ', Record Id = ' + @Lc_IveUpdateCur_Rec_ID + ', Child Member MCI = ' + @Lc_IveUpdateCur_MemberMciIdno_TEXT + ', Child IVE Party Idno = ' + @Lc_IveUpdateCur_IvePartyIdno_TEXT + ', Mother Case Idno = ' + @Lc_IveUpdateCur_MotherCaseIdno_TEXT + ', Father Case Idno = ' + @Lc_IveUpdateCur_FatherCaseIdno_TEXT + ', Child Removal Date = ' + @Lc_IveUpdateCur_RemovalDate_TEXT + ', Determination Date = ' + @Lc_IveUpdateCur_DeterminationDate_TEXT + ', Determination Code = ' + @Lc_IveUpdateCur_Determination_CODE + ', Mother Termination Indicator = ' + @Lc_IveUpdateCur_MotherTprIndc_TEXT + ', Mother Termination Decision Date = ' + @Lc_IveUpdateCur_MotherTprDecisionDate_TEXT + ', Father Termination Indicator = ' + @Lc_IveUpdateCur_FatherTprIndc_TEXT + ', Father Termination Decision Date = ' + @Lc_IveUpdateCur_FatherTprDecisionDate_TEXT + ', Worker Name = ' + @Lc_IveUpdateCur_Worker_NAME + ', Work Phone Number = ' + @Lc_IveUpdateCur_WorkPhoneNumb_TEXT + ', Parent Name = ' + @Lc_IveUpdateCur_Parent_NAME + ', Parent IVE Party Idno = ' + @Lc_IveUpdateCur_ParentIvePartyIdno_TEXT + ', Mother Member SSN = ' + @Lc_IveUpdateCur_MemberSsnNumb_TEXT + ', Mother Birth Date = ' + @Lc_IveUpdateCur_BirthDate_TEXT;

      IF ISNUMERIC(@Lc_IveUpdateCur_MemberMciIdno_TEXT) = 1
       BEGIN
        SET @Ln_IveUpdateCurMemberMci_IDNO = CAST(@Lc_IveUpdateCur_MemberMciIdno_TEXT AS NUMERIC);

        IF LEN(LTRIM(RTRIM(@Lc_IveUpdateCur_MotherCaseIdno_TEXT))) > 0
         BEGIN
          IF ISNUMERIC(@Lc_IveUpdateCur_MotherCaseIdno_TEXT) = 1
           BEGIN
            SET @Ln_IveUpdateMotherCase_IDNO = CAST(@Lc_IveUpdateCur_MotherCaseIdno_TEXT AS NUMERIC);
            
            IF EXISTS(SELECT 1 
						FROM CASE_Y1 c
					   WHERE c.Case_IDNO = @Ln_IveUpdateMotherCase_IDNO
					     AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
					     AND c.TypeCase_CODE IN (@Lc_IveCaseJ_CODE, @Lc_IveCaseF_CODE))
             BEGIN					     
				SET @Ln_MotherMemberMci_IDNO = ISNULL((SELECT TOP 1 MemberMci_IDNO
					                                     FROM CMEM_Y1 m
						                                WHERE m.CaseRelationship_CODE  IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
						                                  AND m.CaseMemberStatus_CODE = @Lc_MemeberStatusActive_CODE
							                              AND m.Case_IDNO = @Ln_IveUpdateMotherCase_IDNO), @Ln_Zero_NUMB);
			 END
			ELSE
			 BEGIN
				SET @Ln_MotherMemberMci_IDNO = 0;
				SET @Ln_IveUpdateMotherCase_IDNO = 0
			 END 							                              
           END
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
            SET @Ln_IveUpdateMotherCase_IDNO = ISNULL((SELECT TOP 1 Case_IDNO
                                                         FROM CMEM_Y1 a
                                                        WHERE a.CaseRelationship_CODE = @Lc_Dependent_CODE
                                                          AND a.MemberMci_IDNO = @Ln_IveUpdateCurMemberMci_IDNO
                                                          AND a.CaseMemberStatus_CODE = @Lc_MemeberStatusActive_CODE
                                                          AND a.NcpRelationshipToChild_CODE = @Lc_NcpRelationMother_CODE
                                                          AND EXISTS (SELECT 1
                                                                        FROM Case_Y1 s
                                                                       WHERE s.Case_IDNO = a.Case_IDNO
                                                                         AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                                                                         AND s.TypeCase_CODE IN (@Lc_IveCaseJ_CODE, @Lc_IveCaseF_CODE))), 0);

     
            IF @Ln_IveUpdateMotherCase_IDNO <> 0
             BEGIN
              SET @Ln_MotherMemberMci_IDNO = ISNULL((SELECT TOP 1 MemberMci_IDNO
                                                       FROM CMEM_Y1 m
                                                      WHERE m.CaseRelationship_CODE  IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                                                        AND m.CaseMemberStatus_CODE = @Lc_MemeberStatusActive_CODE
                                                        AND m.Case_IDNO = @Ln_IveUpdateMotherCase_IDNO), 0);
             END
            ELSE
             BEGIN
              SET @Ln_MotherMemberMci_IDNO = 0;
             END
         END

        IF LEN(LTRIM(RTRIM(@Lc_IveUpdateCur_FatherCaseIdno_TEXT))) > 0
         BEGIN
          IF ISNUMERIC(@Lc_IveUpdateCur_FatherCaseIdno_TEXT) = 1
           BEGIN
            SET @Ln_IveUpdateFatherCase_IDNO = CAST(@Lc_IveUpdateCur_FatherCaseIdno_TEXT AS NUMERIC);
            
            IF EXISTS(SELECT 1 
						FROM CASE_Y1 c
					   WHERE c.Case_IDNO = @Ln_IveUpdateFatherCase_IDNO
					     AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
						 AND c.TypeCase_CODE IN (@Lc_IveCaseJ_CODE, @Lc_IveCaseF_CODE))
			 BEGIN			 
				SET @Ln_FatherMemberMci_IDNO = ISNULL((SELECT TOP 1 MemberMci_IDNO
														 FROM CMEM_Y1 m
														WHERE m.CaseRelationship_CODE  IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
														  AND m.CaseMemberStatus_CODE = @Lc_MemeberStatusActive_CODE
														  AND m.Case_IDNO = @Ln_IveUpdateFatherCase_IDNO), @Ln_Zero_NUMB);
			 END
			ELSE
			 BEGIN 
			   SET @Ln_FatherMemberMci_IDNO = 0;
			   SET @Ln_IveUpdateFatherCase_IDNO = 0;
			 END														  
           END
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
          SET @Ln_IveUpdateFatherCase_IDNO = ISNULL((SELECT TOP 1 Case_IDNO
                                             FROM CMEM_Y1 a
                                            WHERE a.CaseRelationship_CODE = @Lc_Dependent_CODE
                                              AND a.MemberMci_IDNO = @Ln_IveUpdateCurMemberMci_IDNO
                                              AND a.CaseMemberStatus_CODE = @Lc_MemeberStatusActive_CODE
                                              AND a.NcpRelationshipToChild_CODE = @Lc_NcpRelationFather_CODE
                                              AND EXISTS (SELECT 1
                                                            FROM Case_Y1 s
                                                           WHERE s.Case_IDNO = a.Case_IDNO
                                                             AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                                                             AND s.TypeCase_CODE IN (@Lc_IveCaseJ_CODE, @Lc_IveCaseF_CODE))), 0);
            IF @Ln_IveUpdateFatherCase_IDNO <> 0
             BEGIN
              SET @Ln_FatherMemberMci_IDNO = ISNULL((SELECT TOP 1 MemberMci_IDNO
                                                       FROM CMEM_Y1 m
                                                      WHERE m.CaseRelationship_CODE  IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                                                        AND m.CaseMemberStatus_CODE = @Lc_MemeberStatusActive_CODE
                                                        AND m.Case_IDNO = @Ln_IveUpdateFatherCase_IDNO), 0);
             END
            ELSE
             BEGIN
              SET @Ln_FatherMemberMci_IDNO = 0;
             END
         END

        IF LEN(LTRIM(RTRIM(@Lc_IveUpdateCur_RemovalDate_TEXT))) > 0 
         BEGIN
          IF ISDATE(@Lc_IveUpdateCur_RemovalDate_TEXT) = 1
           BEGIN
            SET @Lb_ChildRemovalDate_BIT = 1;
            SET @Ld_IveUpdateCurRemoval_DATE =  CONVERT(DATE, @Lc_IveUpdateCur_RemovalDate_TEXT, 112);
           END
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

            RAISERROR (50001,16,1);
           END
         END
       END
      ELSE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Member MCI Idno = ' + @Lc_IveUpdateCur_MemberMciIdno_TEXT;

      IF NOT EXISTS (SELECT 1
                       FROM CASE_Y1 c
                      WHERE c.Case_IDNO IN (@Ln_IveUpdateMotherCase_IDNO, @Ln_IveUpdateFatherCase_IDNO)
                        AND c.TypeCase_CODE IN (@Lc_IveCaseJ_CODE, @Lc_IveCaseF_CODE)
                        AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
         AND NOT EXISTS (SELECT 1
                           FROM APCM_Y1 d
                          WHERE d.CaseRelationship_CODE = @Lc_Dependent_CODE
                            AND d.MemberMci_IDNO = @Ln_IveUpdateCurMemberMci_IDNO
                            AND @Ld_Run_DATE BETWEEN d.BeginValidity_DATE AND d.EndValidity_DATE
                            AND EXISTS (SELECT 1
                                          FROM APCS_Y1 c
                                         WHERE d.Application_IDNO = c.Application_IDNO
                                           AND c.ApplicationStatus_CODE = @Lc_ApplicationStatusPending_CODE))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;

        RAISERROR (50001,16,1);
       END

      IF @Lb_ChildRemovalDate_BIT = 1
       BEGIN
        IF @Ln_MotherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateMotherCase_IDNO <> 0
         BEGIN
          SET @Lc_ActivityMinorMother_CODE = @Lc_ActivityMinorChrfc_CODE;
          SET @Lb_MotherCaseProcess_BIT = 1;
          SET @Ls_DescriptionNoteMother_TEXT = 'TERMINATED CHILD MCI : ' + CAST (@Lc_IveUpdateCur_MemberMciIdno_TEXT AS VARCHAR) + ' FROM THE CASE IDNO : ' + CAST(@Ln_IveUpdateMotherCase_IDNO AS VARCHAR);
         END
        ELSE
         BEGIN
          SET @Lb_MotherCaseProcess_BIT = 0;
         END

        IF @Ln_FatherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateFatherCase_IDNO <> 0
         BEGIN
          SET @Lc_ActivityMinorFather_CODE = @Lc_ActivityMinorChrfc_CODE;
          SET @Lb_FatherCaseProcess_BIT = 1;
          SET @Ls_DescriptionNoteFather_TEXT = 'TERMINATED CHILD MCI : ' + CAST (@Lc_IveUpdateCur_MemberMciIdno_TEXT AS VARCHAR) + ' FROM THE CASE IDNO : ' + CAST(@Ln_IveUpdateFatherCase_IDNO AS VARCHAR);
         END
        ELSE
         BEGIN
          SET @Lb_FatherCaseProcess_BIT = 0;
         END
       END
      ELSE
       BEGIN
        IF @Lc_IveUpdateCur_MotherTprIndc_TEXT = @Lc_TprYes_INDC
           AND @Ln_MotherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateMotherCase_IDNO <> 0
         BEGIN
          SET @Lc_ActivityMinorMother_CODE = @Lc_ActivityMinorMorit_CODE;
          SET @Lb_MotherCaseProcess_BIT = 1;
         END
        ELSE
         BEGIN
          SET @Lb_MotherCaseProcess_BIT = 0;
         END

        IF @Lc_IveUpdateCur_FatherTprIndc_TEXT = @Lc_TprYes_INDC
           AND @Ln_FatherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateFatherCase_IDNO <> 0
         BEGIN
          SET @Lb_FatherCaseProcess_BIT = 1;
          SET @Lc_ActivityMinorFather_CODE = @Lc_ActivityMinorFarit_CODE;
         END
        ELSE
         BEGIN
          SET @Lb_FatherCaseProcess_BIT = 0;
         END
       END

      IF @Lb_MotherCaseProcess_BIT = 1
          OR @Lb_FatherCaseProcess_BIT = 1
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
        SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

		EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT  
		 @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
		 @Ac_Process_ID               = @Lc_Job_ID,
		 @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
		 @Ac_Note_INDC                = @Lc_IndNote_TEXT,
		 @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
		 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
		 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
		 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
		 
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        IF @Lb_MotherCaseProcess_BIT = 1
           AND @Ln_MotherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateMotherCase_IDNO <> 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY -1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IveUpdateMotherCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MotherMemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorMother_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_IveUpdateMotherCase_IDNO,
           @An_MemberMci_IDNO           = @Ln_MotherMemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorMother_CODE,
           @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
           @As_DescriptionNote_TEXT		= @Ls_DescriptionNoteMother_TEXT,
           @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
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
           @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
           @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
           @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
           @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
           @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
           @An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        IF @Lb_FatherCaseProcess_BIT = 1
           AND @Ln_FatherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateFatherCase_IDNO <> 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY -2';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IveUpdateFatherCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FatherMemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFather_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_IveUpdateFatherCase_IDNO,
           @An_MemberMci_IDNO           = @Ln_FatherMemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorFather_CODE,
           @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
           @As_DescriptionNote_TEXT		= @Ls_DescriptionNoteFather_TEXT,
           @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
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
           @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
           @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
           @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
           @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
           @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
           @An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
       END

	  IF LEN(LTRIM(RTRIM(@Lc_IveUpdateCur_DeterminationDate_TEXT))) > 0
				AND ISDATE(@Lc_IveUpdateCur_DeterminationDate_TEXT) = 1
       BEGIN
        IF @Ln_TransactionEventSeq_NUMB = 0
          BEGIN
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 2';
			SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

			EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT  
			 @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
			 @Ac_Process_ID               = @Lc_Job_ID,
			 @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
			 @Ac_Note_INDC                = @Lc_IndNote_TEXT,
			 @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
			 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
			 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
			 
			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			 BEGIN
			  RAISERROR (50001,16,1);
			 END
         END
    
        IF @Ln_MotherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateMotherCase_IDNO <> 0
         BEGIN
		  SET @Ls_DescriptionNoteMother_TEXT = 'TERMINATED CHILD MCI : ' + CAST (@Lc_IveUpdateCur_MemberMciIdno_TEXT AS VARCHAR) + ' FROM THE CASE IDNO : ' + CAST(@Ln_IveUpdateMotherCase_IDNO AS VARCHAR) + ', IV-E Worker Name : ' + @Lc_IveUpdateCur_Worker_NAME + ', IV-E Worker Phone Number : ' + @Lc_IveUpdateCur_WorkPhoneNumb_TEXT;
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 3';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IveUpdateMotherCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MotherMemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFcdrc_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_IveUpdateMotherCase_IDNO,
           @An_MemberMci_IDNO           = @Ln_MotherMemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorFcdrc_CODE,
           @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
           @As_DescriptionNote_TEXT		= @Ls_DescriptionNoteMother_TEXT,
           @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
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
           @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
           @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
           @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
           @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
           @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
           @An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        IF @Ln_FatherMemberMci_IDNO <> 0
           AND @Ln_IveUpdateFatherCase_IDNO <> 0
         BEGIN
		  SET @Ls_DescriptionNoteFather_TEXT = 'TERMINATED CHILD MCI : ' + CAST (@Lc_IveUpdateCur_MemberMciIdno_TEXT AS VARCHAR) + ' FROM THE CASE IDNO : ' + CAST(@Ln_IveUpdateFatherCase_IDNO AS VARCHAR) + ', IV-E Worker Name : ' + @Lc_IveUpdateCur_Worker_NAME + ', IV-E Worker Phone Number : ' + @Lc_IveUpdateCur_WorkPhoneNumb_TEXT;
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 4';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_IveUpdateFatherCase_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FatherMemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFcdrc_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_IveUpdateFatherCase_IDNO,
           @An_MemberMci_IDNO           = @Ln_FatherMemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorFcdrc_CODE,
           @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
           @As_DescriptionNote_TEXT		= @Ls_DescriptionNoteFather_TEXT,
           @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
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
           @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
           @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
           @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
           @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
           @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
           @An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END	 

	END 

      IF @Lb_ChildRemovalDate_BIT = 1
          OR (@Ln_IveUpdateFatherCase_IDNO = 0
              AND @Ln_IveUpdateMotherCase_IDNO = 0)
       BEGIN
        SET @Ls_Sql_TEXT = 'END DATE CHILD FROM APCM_Y1 ';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_IveUpdateCurMemberMci_IDNO AS VARCHAR), '') + ', Application_IDNO = ' + ISNULL(CAST(@Ln_MotherCaseApplication_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_Dependent_CODE, '');

        UPDATE c
           SET c.EndValidity_DATE = ISNULL(@Ld_IveUpdateCurRemoval_DATE, @Ld_Run_DATE)
          FROM APCM_Y1 c
         WHERE c.MemberMci_IDNO = @Ln_IveUpdateCurMemberMci_IDNO
           AND c.CaseRelationship_CODE = @Lc_Dependent_CODE
           AND @Ld_Run_DATE BETWEEN BeginValidity_DATE AND EndValidity_DATE
           AND EXISTS (SELECT 1
                         FROM APCS_Y1 a
                        WHERE a.Application_IDNO = c.Application_IDNO
                          AND a.ApplicationStatus_CODE = @Lc_ApplicationStatusPending_CODE
                          AND @Ld_Run_DATE BETWEEN a.BeginValidity_DATE AND a.EndValidity_DATE);

        SET @Ls_Sql_TEXT = 'UPADATE APCS_Y1 PENDING APPLICATION TO DELETED IF NO ACTIVE KIDS IN APPLICATION';
        SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@Ln_FatherCaseApplication_IDNO AS VARCHAR), '') + ', ApplicationStatus_CODE = ' + ISNULL(@Lc_ApplicationStatusPending_CODE, '');

        UPDATE a
           SET a.ApplicationStatus_CODE = @Lc_ApplicationStatusDeleted_CODE,
               a.EndValidity_DATE = ISNULL(@Ld_IveUpdateCurRemoval_DATE, @Ld_Run_DATE)
          FROM APCS_Y1 a
         WHERE a.ApplicationStatus_CODE = @Lc_ApplicationStatusPending_CODE
           AND @Ld_Run_DATE BETWEEN a.BeginValidity_DATE AND a.EndValidity_DATE
           AND EXISTS (SELECT 1
                         FROM APCM_Y1 c
                        WHERE a.Application_IDNO = c.Application_IDNO
                          AND c.MemberMci_IDNO = @Ln_IveUpdateCurMemberMci_IDNO
                          AND c.CaseRelationship_CODE = @Lc_Dependent_CODE
                          AND c.EndValidity_DATE = @Ld_IveUpdateCurRemoval_DATE
                          AND NOT EXISTS (SELECT 1
                                            FROM APCM_Y1 d
                                           WHERE d.Application_IDNO = c.Application_IDNO
                                             AND d.CaseRelationship_CODE = @Lc_Dependent_CODE
                                             AND d.MemberMci_IDNO <> @Ln_IveUpdateCurMemberMci_IDNO
                                             AND @Ld_Run_DATE BETWEEN d.BeginValidity_DATE AND d.EndValidity_DATE))
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEIVEUPDATE_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
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

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Child Member Mci = ' + RTRIM(@Lc_IveUpdateCur_MemberMciIdno_TEXT);
       SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_IDNO,
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

     SET @Ls_Sql_TEXT = 'UPDATE LFIVE_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IveUpdateCur_Seq_IDNO AS VARCHAR);

     UPDATE LFIVE_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_IveUpdateCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Lc_BateError_CODE = @Lc_ErrorE0001_CODE;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY = @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = ' JOB_ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS NVARCHAR (MAX)), '') + ', RESTART_KEY = ' + ISNULL (CAST (@Ln_RecordCount_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       COMMIT TRANSACTION IVEUPDATE_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;

       BEGIN TRANSACTION IVEUPDATE_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

       COMMIT TRANSACTION IVEUPDATE_PROCESS;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT RECORD FROM CURSOR';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM IveUpdate_CUR INTO @Ln_IveUpdateCur_Seq_IDNO, @Lc_IveUpdateCur_Rec_ID, @Lc_IveUpdateCur_MemberMciIdno_TEXT, @Lc_IveUpdateCur_IvePartyIdno_TEXT, @Lc_IveUpdateCur_MotherCaseIdno_TEXT, @Lc_IveUpdateCur_FatherCaseIdno_TEXT, @Lc_IveUpdateCur_RemovalDate_TEXT, @Lc_IveUpdateCur_DeterminationDate_TEXT, @Lc_IveUpdateCur_Determination_CODE, @Lc_IveUpdateCur_MotherTprIndc_TEXT, @Lc_IveUpdateCur_MotherTprDecisionDate_TEXT, @Lc_IveUpdateCur_FatherTprIndc_TEXT, @Lc_IveUpdateCur_FatherTprDecisionDate_TEXT, @Lc_IveUpdateCur_Worker_NAME, @Lc_IveUpdateCur_WorkPhoneNumb_TEXT, @Lc_IveUpdateCur_Parent_NAME, @Lc_IveUpdateCur_ParentIvePartyIdno_TEXT, @Lc_IveUpdateCur_MemberSsnNumb_TEXT, @Lc_IveUpdateCur_BirthDate_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE IveUpdate_CUR;

   DEALLOCATE IveUpdate_CUR;

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_IDNO, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_IDNO,
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
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

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

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION IVEUPDATE_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVEUPDATE_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'IveUpdate_CUR') IN (0, 1)
    BEGIN
     CLOSE IveUpdate_CUR;

     DEALLOCATE IveUpdate_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
  END CATCH
 END


GO
