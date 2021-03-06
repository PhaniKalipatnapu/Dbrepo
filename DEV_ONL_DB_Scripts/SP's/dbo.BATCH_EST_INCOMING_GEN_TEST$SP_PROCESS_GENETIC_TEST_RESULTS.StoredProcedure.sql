/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS
Programmer Name		: Protech Solutions, Inc.
Description			: The purpose of this procedure is to update the genetic test results.
Frequency			: DAILY
Developed On		: 26-MAR-2012
Called By			: 
Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT, BATCH_COMMON$SP_BSTL_LOG 
					  and BATCH_COMMON$SP_UPDATE_PARM_DATE
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS]
AS
 DECLARE @Li_Zero_NUMB							INT				= 0,
         @Ln_OtherPartyLabCorpAmerica_IDNO		NUMERIC(9)		= 999999957,
         @Lc_Null_TEXT							CHAR(1)			= '',
         @Lc_No_INDC							CHAR(1)			= 'N',
         @Lc_StatusFailed_CODE					CHAR(1)			= 'F',
         @Lc_Space_TEXT							CHAR(1)			= ' ',
         @Lc_StatusCaseOpen_CODE				CHAR(1)			= 'O',
         @Lc_CaseMemberStatusActive_CODE		CHAR(1)			= 'A',
         @Lc_CaseRelationshipNcp_CODE			CHAR(1)			= 'A',
         @Lc_CaseRelationshipPf_CODE			CHAR(1)			= 'P',
         @Lc_CaseRelationshipDependent_CODE		CHAR(1)			= 'D',
         @Lc_Yes_INDC							CHAR(1)			= 'Y',
         @Lc_TypeTestDna_CODE					CHAR(1)			= 'D',
         @Lc_TestResultInclusion_CODE			CHAR(1)			= 'I',
         @Lc_TypeErrorE_CODE					CHAR(1)			= 'E',
         @Lc_TestResultExcluded_CODE			CHAR(1)			= 'X',
         @Lc_TypeErrorW_CODE					CHAR(1)			= 'W',
         @Lc_SuccessStatus_CODE					CHAR(1)			= 'S',
         @Ac_StatusAbend_CODE					CHAR(1)			= 'A',
         @Lc_TestResultScheduled_CODE			CHAR(1)			= 'S',
         @Lc_SubsystemEstablishment_CODE		CHAR(2)			= 'ES',
         @Lc_LocationStateDe_CODE				CHAR(2)			= 'DE',
         @Lc_ActivityMajorCase_CODE				CHAR(4)			= 'CASE',
         @Lc_ErrorBate_CODE						CHAR(5)			= 'E0944',
         @Lc_ErrorBateE1424_CODE				CHAR(5)			= 'E1424',
         @Lc_ActivityMinorGtsta_CODE			CHAR(5)			= 'GTSTA',
         @Lc_BatchRunUser_TEXT					CHAR(30)		= 'BATCH',
         @Lc_Job_ID								CHAR(7)			= 'DEB1260',
         @Lc_Successful_TEXT					CHAR(20)		= 'SUCCESSFUL',
         @Ls_OtherParty_NAME					VARCHAR(60)		= 'LabCorp America',
         @Ls_Process_NAME						VARCHAR(100)	= 'BATCH_EST_INCOMING_GEN_TEST',
         @Ls_Routine_TEXT						VARCHAR(60)		= 'SP_PROCESS_GENETIC_TEST_RESULTS',
         @Ld_Low_DATE							DATE			= '01/01/0001',
         @Ld_High_DATE							DATE			= '12/31/9999';
         
 DECLARE @Ln_Exception_QNTY						NUMERIC(5)		= 0,
         @Ln_ExceptionThreshold_QNTY			NUMERIC(5),
         @Ln_CommitFreqParm_QNTY				NUMERIC(5),
         @Ln_ExceptionThresholdParm_QNTY		NUMERIC(5),
         @Ln_ProcessRecordsCount_QNTY			NUMERIC(6)		= 0,
         @Ln_ProcessedRecordsCountCommit_QNTY	NUMERIC(6)		= 0,
         @Ln_Row_NUMB							NUMERIC(10)		= 0,
         @Ln_Cursor_QNTY						NUMERIC(10)		= 0,
         @Ln_Error_NUMB							NUMERIC(10),
         @Ln_ErrorLine_NUMB						NUMERIC(10),
         @Ln_ChildMemberMci_IDNO				NUMERIC(10),
         @Ln_Topic_IDNO							NUMERIC(10),
         @Ln_Schedule_NUMB						NUMERIC(10),
         @Ln_Topic_NUMB							NUMERIC(10),
         @Ln_TransactionEventSeq_NUMB			NUMERIC(19),
         @Ln_RowCount_NUMB						NUMERIC(19)		= 0,
         @Ln_TransactionEventSeqOld_NUMB		NUMERIC(19)		= 0,
         @Lc_Msg_CODE							CHAR(5),
         @Lc_Error_CODE							CHAR(5),
         @Lc_MemberMciFather_IDNO				CHAR(10),
         @Ls_Sql_TEXT							VARCHAR(100)	= NULL,
         @Ls_CursorLoc_TEXT						VARCHAR(200),
         @Ls_SqlData_TEXT						VARCHAR(1000)	= NULL,
         @Ls_DescriptionError_TEXT				VARCHAR(4000),
         @Ld_Run_DATE							DATETIME,
         @Ld_Start_DATE							DATETIME2,
         @Ld_LastRun_DATE						DATETIME2

 BEGIN
  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'TO GET BATCH DETAILS';

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS1';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   DECLARE @GeneticCur$Case_IDNO            CHAR(6),
           @GeneticCur$FirstMother_NAME     CHAR(15),
           @GeneticCur$LastMother_NAME      CHAR(20),
           @GeneticCur$MiMother_NAME        CHAR(20),
           @GeneticCur$FirstFather_NAME     CHAR(15),
           @GeneticCur$LastFather_NAME      CHAR(20),
           @GeneticCur$MiFather_NAME        CHAR(20),
           @GeneticCur$ChildFirst_NAME      CHAR(15),
           @GeneticCur$ChildLast_NAME       CHAR(20),
           @GeneticCur$ChildMiddle_NAME     CHAR(20),
           @GeneticCur$ResultsReceived_DATE DATETIME2,
           @GeneticCur$Probability_PCT      NUMERIC(4, 2),
           @GeneticCur$File_ID              CHAR(15),
           @GeneticCur$Process_INDC         CHAR(1),
           @GeneticCur$Row_NUMB             NUMERIC(19, 0)
   DECLARE LoadGtst_Cur INSENSITIVE CURSOR FOR
    SELECT L.Case_IDNO,
           L.FirstMother_NAME,
           L.LastMother_NAME,
           L.MiddleMother_NAME,
           L.FirstFather_NAME,
           L.LastFather_NAME,
           L.MiddleFather_NAME,
           L.ChildFirst_NAME,
           L.ChildLast_NAME,
           L.ChildMiddle_NAME,
           L.ResultsReceived_DATE,
           L.Probability_PCT,
           L.File_ID,
           L.Process_INDC,
           L.Seq_IDNO AS Sequence_NUMB
      FROM LGRES_Y1 L
     WHERE L.Process_INDC = @Lc_No_INDC;

   BEGIN TRANSACTION GTSTStatus;

   SET @Ls_Sql_TEXT = 'Open Cursor';
   SET @Ls_SqlData_TEXT = '';

   OPEN LoadGtst_Cur

   SET @Ls_Sql_TEXT = 'Fetch Cursor ';

   FETCH NEXT FROM LoadGtst_Cur INTO @GeneticCur$Case_IDNO, @GeneticCur$FirstMother_NAME, @GeneticCur$LastMother_NAME, @GeneticCur$MiMother_NAME, @GeneticCur$FirstFather_NAME, @GeneticCur$LastFather_NAME, @GeneticCur$MiFather_NAME, @GeneticCur$ChildFirst_NAME, @GeneticCur$ChildLast_NAME, @GeneticCur$ChildMiddle_NAME, @GeneticCur$ResultsReceived_DATE, @GeneticCur$Probability_PCT, @GeneticCur$File_ID, @GeneticCur$Process_INDC, @GeneticCur$Row_NUMB;

   -- Cursor loop Started
   WHILE @@FETCH_STATUS = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION GtstStatusSave;

      SET @Lc_Error_CODE = @Lc_ErrorBateE1424_CODE;
      SET @Ln_Row_NUMB = @Ln_Row_NUMB + 1;
      SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@GeneticCur$Case_IDNO AS CHAR), '') + ' File_ID = ' + ISNULL(@GeneticCur$File_ID, '') + ' FirstMother_NAME = ' + ISNULL(@GeneticCur$FirstMother_NAME, '') + ' LastMother_NAME = ' + ISNULL(@GeneticCur$LastMother_NAME, '') + ' MiddleMother_NAME = ' + ISNULL(@GeneticCur$MiMother_NAME, '') + ' FirstFather_NAME = ' + ISNULL(@GeneticCur$FirstFather_NAME, '') + ' LastFather_NAME = ' + ISNULL(@GeneticCur$LastFather_NAME, '') + ' MiddleFather_NAME = ' + ISNULL(@GeneticCur$MiFather_NAME, '') + ' ChildFirst_NAME = ' + ISNULL(@GeneticCur$ChildFirst_NAME, '') + ' ChildLast_NAME = ' + ISNULL(@GeneticCur$ChildLast_NAME, '') + ' ChildMiddle_NAME = ' + ISNULL(@GeneticCur$ChildMiddle_NAME, '') + ' ResultsReceived_DATE = ' + CAST(@GeneticCur$ResultsReceived_DATE AS CHAR(10)) + ' Probability_PCT = ' + ISNULL(CAST(@GeneticCur$Probability_PCT AS CHAR), '0') + ' Process_INDC = ' + ISNULL(@GeneticCur$Process_INDC, '');
      SET @Ls_Sql_TEXT = 'Generate TransactionEventSeq_NUMB';
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;

      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
       @Ac_Note_INDC                = @Lc_No_INDC,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'Generate TransactionEventSeq_NUMB Failed';

        RAISERROR(50001,16,1);
       END

      IF ISNUMERIC(@GeneticCur$Case_IDNO) = 1
         AND @GeneticCur$Case_IDNO != 0
       BEGIN
        -- 13363 - LabCorp - CR0410 LabCorp and Family Court Changes to Increase Success Rate Middle name is excluded - START
        SET @Ls_Sql_TEXT = 'SELECT CASE_Y1';

        SELECT @Ln_RowCount_NUMB = COUNT(*)
          FROM CASE_Y1 c
         WHERE c.Case_IDNO = @GeneticCur$Case_IDNO;

        IF @Ln_RowCount_NUMB = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'Invalid Case ID';
          SET @Lc_Error_CODE = 'E0008';
          RAISERROR(50001,16,1);
         END
         
         SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 - Check Status';
         
         SELECT @Ln_RowCount_NUMB = COUNT(*)
          FROM CASE_Y1 c
         WHERE c.Case_IDNO = @GeneticCur$Case_IDNO
           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
           
         IF @Ln_RowCount_NUMB = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'Case is not open';
          SET @Lc_Error_CODE = 'E0073';
          RAISERROR(50001,16,1);
         END
       END
      ELSE
       BEGIN
		IF RTRIM(LTRIM(@GeneticCur$File_ID)) IS NOT NULL
           AND RTRIM(LTRIM(@GeneticCur$File_ID)) != ''
         BEGIN
          SELECT @GeneticCur$Case_IDNO = MAX(c.Case_IDNO)
            FROM CASE_Y1 c
           WHERE (c.Case_IDNO IN (SELECT DISTINCT D.Case_IDNO
                                    FROM FDEM_Y1 D
                                   WHERE D.File_ID = @GeneticCur$File_ID
                                     AND D.EndValidity_DATE = @Ld_High_DATE
                                  )
                   OR C.Case_IDNO IN (SELECT m.Case_IDNO
                                        FROM CMEM_Y1 m
                                       WHERE m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                                         AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                         AND m.MemberMci_IDNO IN (SELECT d.MemberMci_IDNO
                                                                    FROM DEMO_Y1 d
                                                                   WHERE d.First_NAME = @GeneticCur$FirstFather_NAME
                                                                     AND d.Last_NAME = @GeneticCur$LastFather_NAME)
                                         AND CASE_IDNO IN (SELECT c.Case_IDNO
                                                             FROM CMEM_Y1 c
                                                            WHERE c.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
                                                              AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                              AND c.MemberMci_IDNO IN (SELECT d.MemberMci_IDNO
                                                                                         FROM DEMO_Y1 d
                                                                                        WHERE d.First_NAME = @GeneticCur$ChildFirst_NAME
																						  AND d.Last_NAME = @GeneticCur$ChildLast_NAME)
                                                            )
                                       )
                  )
              AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE

          IF @@ROWCOUNT = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'Invalid File Number';
            SET @Lc_Error_CODE = 'E0529';
            RAISERROR(50001,16,1);
           END
         END
        ELSE
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'Invalid File Number';
          SET @Lc_Error_CODE = 'E0529';
          RAISERROR(50001,16,1);
         END
       END

      SET @Ls_Sql_TEXT = 'SELECT FatherMemberMci_IDNO FROM CMEM_Y1,DEMO_Y1';

      BEGIN
       SELECT @Lc_MemberMciFather_IDNO = c.MemberMci_IDNO
         FROM CMEM_Y1 c
              JOIN DEMO_Y1 d
               ON c.MemberMci_IDNO = d.MemberMci_IDNO
                  AND d.First_NAME = @GeneticCur$FirstFather_NAME
                  AND d.Last_NAME = @GeneticCur$LastFather_NAME
        WHERE c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
          AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
          AND c.Case_IDNO = @GeneticCur$Case_IDNO;

       IF @@ROWCOUNT = 0
        BEGIN
         SET @Lc_MemberMciFather_IDNO = NULL;
        END
      END

      SET @Ls_Sql_TEXT = 'SELECT ChildMemberMci_IDNO FROM CMEM_Y1,DEMO_Y1';

      BEGIN
       SELECT @Ln_ChildMemberMci_IDNO = c.MemberMci_IDNO
         FROM CMEM_Y1 AS c,
              DEMO_Y1 AS d
        WHERE c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
          AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
          AND c.Case_IDNO = @GeneticCur$Case_IDNO
          AND c.MemberMci_IDNO = d.MemberMci_IDNO
          AND d.First_NAME = @GeneticCur$ChildFirst_NAME
          AND d.Last_NAME = @GeneticCur$ChildLast_NAME;

       IF @@ROWCOUNT = 0
        BEGIN
         SET @Ln_ChildMemberMci_IDNO = NULL;
        END
      END

      IF @Ln_ChildMemberMci_IDNO IS NOT NULL
         AND @Lc_MemberMciFather_IDNO IS NOT NULL
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT GTST_Y1';

        SELECT @Ln_Schedule_NUMB = a.Schedule_NUMB,
               @Ln_TransactionEventSeqOld_NUMB = a.TransactionEventSeq_NUMB
          FROM GTST_Y1 AS a
         WHERE a.MemberMci_IDNO = @Ln_ChildMemberMci_IDNO
           AND a.Case_IDNO = @GeneticCur$Case_IDNO
           AND a.TestResult_CODE = @Lc_TestResultScheduled_CODE
           AND a.EndValidity_DATE = @Ld_High_DATE
           AND EXISTS (SELECT 1 AS expr
                         FROM GTST_Y1 AS b
                        WHERE b.Case_IDNO = a.Case_IDNO
                          AND b.Schedule_NUMB = a.Schedule_NUMB
                          AND b.MemberMci_IDNO = @Lc_MemberMciFather_IDNO
                          AND b.EndValidity_DATE = @Ld_High_DATE);

        IF @@ROWCOUNT = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'Appointment not found';
          SET @Lc_Error_CODE = 'E0012';
          RAISERROR(50001,16,1);
         END
         -- 13363 - LabCorp - CR0410 LabCorp and Family Court Changes to Increase Success Rate Middle name is excluded - END
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'Invalid Member';
        SET @Lc_Error_CODE = 'E1379';
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'UPDATE GTST_Y1';
      SET @Ls_SqlData_TEXT = @Ls_SqlData_TEXT + ' MemberMci_IDNO = ' + CAST(@Ln_ChildMemberMci_IDNO AS CHAR) + ' Schedule_NUMB = ' + CAST(@Ln_Schedule_NUMB AS CHAR) + ' TransactionEventSeqOld_NUMB = ' + CAST(@Ln_TransactionEventSeqOld_NUMB AS CHAR) + ' TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS CHAR);

      UPDATE GTST_Y1
         SET EndValidity_DATE = CONVERT(DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
       WHERE TransactionEventSeq_NUMB = @Ln_TransactionEventSeqOld_NUMB
         AND MemberMci_IDNO = @Ln_ChildMemberMci_IDNO
         AND Schedule_NUMB = @Ln_Schedule_NUMB
         AND Case_IDNO = @GeneticCur$Case_IDNO
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;

      IF @Ln_RowCount_NUMB = @Li_Zero_NUMB
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE GTST_Y1 FAILED';
        SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
        RAISERROR(50001,16,1);
       END

      SET @Ln_RowCount_NUMB = 0;
      SET @Ls_Sql_TEXT = 'INSERT GTST_Y1';

      INSERT GTST_Y1
             (Case_IDNO,
              MemberMci_IDNO,
              Schedule_NUMB,
              Test_DATE,
              Test_AMNT,
              OthpLocation_IDNO,
              PaidBy_NAME,
              BeginValidity_DATE,
              EndValidity_DATE,
              WorkerUpdate_ID,
              Update_DTTM,
              TransactionEventSeq_NUMB,
              Lab_NAME,
              LocationState_CODE,
              Location_NAME,
              CountyLocation_IDNO,
              TypeTest_CODE,
              ResultsReceived_DATE,
              TestResult_CODE,
              Probability_PCT)
      SELECT g.Case_IDNO,
             g.MemberMci_IDNO,
             g.Schedule_NUMB,
             g.Test_DATE,
             g.Test_AMNT,
             g.OthpLocation_IDNO,
             g.PaidBy_NAME,
             CONVERT(DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
             @Ld_High_DATE,
             @Lc_BatchRunUser_TEXT,
             dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
             @Ln_TransactionEventSeq_NUMB,
             @Ls_OtherParty_NAME,
             @Lc_LocationStateDe_CODE,
             g.Location_NAME,
             g.CountyLocation_IDNO,
             g.TypeTest_CODE,
             @GeneticCur$ResultsReceived_DATE,
             CASE
              WHEN @GeneticCur$Probability_PCT >= 99.00
               THEN @Lc_TestResultInclusion_CODE
              ELSE @Lc_TestResultExcluded_CODE
             END,
             @GeneticCur$Probability_PCT
        FROM GTST_Y1 g
       WHERE g.MemberMci_IDNO = @Ln_ChildMemberMci_IDNO
         AND g.Case_IDNO = @GeneticCur$Case_IDNO
         AND g.Schedule_NUMB = @Ln_Schedule_NUMB
         AND g.TransactionEventSeq_NUMB = @Ln_TransactionEventSeqOld_NUMB;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;

      IF @Ln_RowCount_NUMB = @Li_Zero_NUMB
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'INSERT VGTST FAILED';
        SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
        RAISERROR(50001,16,1);
       END

      SET @Ln_RowCount_NUMB = 0;
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
      SET @Ls_Sqldata_TEXT = @Ls_Sqldata_TEXT + ', FatherMemberMci_IDNO = ' + CAST(@Lc_MemberMciFather_IDNO AS CHAR) + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorGtsta_CODE + ', Subsystem_CODE = ' + @Lc_SubsystemEstablishment_CODE;

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @GeneticCur$Case_IDNO,
       @An_MemberMci_IDNO           = @Lc_MemberMciFather_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorGtsta_CODE,
       @Ac_Subsystem_CODE           = @Lc_SubsystemEstablishment_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
      -- Committable transaction checking and Rolling back Savepoint
      IF XACT_STATE()		= 1
       BEGIN
        ROLLBACK TRANSACTION GtstStatusSave
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
        RAISERROR( 50001,16,1);
       END

      -- Check for Exception information to log the description text based on the error
      SET @Ln_Error_NUMB = ERROR_NUMBER ();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

      IF @Ln_Error_NUMB <> 50001
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

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Routine_TEXT,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_Error_CODE,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      -- Checking if error type is 'E' then increment the threshold count
      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
       END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LGRES_Y1';

     UPDATE LGRES_Y1
        SET Process_INDC = @Lc_Yes_INDC
       FROM LGRES_Y1 AS lo
      WHERE lo.Seq_IDNO = @GeneticCur$Row_NUMB;

     SET @Ln_RowCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowCount_NUMB = @Li_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE LGRES_Y1 FAILED';
       SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
       RAISERROR(50001,16,1);
      END

     SET @Ln_RowCount_NUMB = 0;
     SET @Ln_ProcessRecordsCount_QNTY = @Ln_ProcessRecordsCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK';
     SET @Ls_SqlData_TEXT = 'Cursor_QNTY = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS CHAR), '') + ', CommitFreqParm_QNTY = ' + ISNULL(CAST(@Ln_CommitFreqParm_QNTY AS CHAR), '');

     IF @Ln_Cursor_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION GtstStatus;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       BEGIN TRANSACTION GtstStatus;
       SET @Ln_Cursor_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'THRESHOLD COUNT CHECK';
     SET @Ls_SqlData_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_Exception_QNTY AS CHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS CHAR);

     IF @Ln_Exception_QNTY > @Ln_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION GtstStatus;
       SET @Ls_DescriptionError_TEXT = 'EXCEPTION LIMIT REACHED THE THRESHOLD';
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'Fetch Cursor in loop';
     FETCH NEXT FROM LoadGtst_Cur INTO @GeneticCur$Case_IDNO, @GeneticCur$FirstMother_NAME, @GeneticCur$LastMother_NAME, @GeneticCur$MiMother_NAME, @GeneticCur$FirstFather_NAME, @GeneticCur$LastFather_NAME, @GeneticCur$MiFather_NAME, @GeneticCur$ChildFirst_NAME, @GeneticCur$ChildLast_NAME, @GeneticCur$ChildMiddle_NAME, @GeneticCur$ResultsReceived_DATE, @GeneticCur$Probability_PCT, @GeneticCur$File_ID, @GeneticCur$Process_INDC, @GeneticCur$Row_NUMB
    END

   CLOSE LoadGtst_Cur;

   /* if not having any record(s) to process then
        NO RECORD(S) TO PROCESS message logging in BATE_Y1 table */
   IF @Ln_ProcessRecordsCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Package_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Routine_TEXT + ', Job_ID = ' + @Lc_Job_ID + ', RunParm_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + CAST(@Ln_Row_NUMB AS VARCHAR) + ', Error_CODE = ' + @Lc_ErrorBate_CODE + ', Sql_data = ' + ISNULL(@Ls_SqlData_TEXT, ' ');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Routine_TEXT,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
      @An_Line_NUMB                = @Ln_ProcessRecordsCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorBate_CODE,
      @As_DescriptionError_TEXT    = @Ls_SqlData_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   DEALLOCATE LoadGtst_Cur;

   SET @Ls_Sql_TEXT = 'BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS3';
   SET @Ls_SqlData_TEXT = 'ID_JOB: ' + ISNULL(@Lc_Job_ID, '') + ' DT_RUN: ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(MAX)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_SuccessStatus_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_EST_INCOMING_GEN_TEST$SP_PROCESS_GENETIC_TEST_RESULTS4';

     RAISERROR(50001,16,1);
    END

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Null_TEXT,
    @Ac_Status_CODE               = @Lc_SuccessStatus_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessRecordsCount_QNTY;

   SET @Lc_Msg_CODE = @Lc_SuccessStatus_CODE;

   COMMIT TRANSACTION GtstStatus;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION GtstStatus;
    END

   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS('LOCAL', 'LoadGtst_Cur') IN (0, 1)
    BEGIN
     CLOSE LoadGtst_Cur;
     DEALLOCATE LoadGtst_Cur;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

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
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Ac_StatusAbend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
