/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_CREATE_FCR_TRANSACTIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_CREATE_FCR_TRANSACTIONS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_CREATE_FCR_TRANSACTIONS batch process is to 
					  extract the case and member details from the system database, format and load the data 
					  into temporary case extract and member extract tables. Based on the locate status of NCPs, 
					  additional member records are inserted into the member extract and query extract tables. 
					  Finally extracts all new address, pending address and recently end-dated addresses and 
					  sends the data to National Change of Address (NCOA).
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_CREATE_FCR_TRANSACTIONS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                         CHAR = ' ',
          @Lc_Zero_TEXT                          CHAR = '0',
          @Lc_TypeWarning_CODE                   CHAR = 'W',
          @Lc_CaseMemberStatusA_CODE             CHAR = 'A',
          @Lc_CaseRelationshipA_CODE             CHAR = 'A',
          @Lc_CaseRelationshipP_CODE             CHAR = 'P',
          @Lc_StatusSuccess_CODE                 CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                  CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE             CHAR(1) = 'A',
          @Lc_ProcessFlagPersonLocate_INDC       CHAR(1) = 'L',
          @Lc_TypeActionQueryRequest_CODE        CHAR(1) = 'F',
          @Lc_NcoaTypeActionV_CODE               CHAR(1) = 'V',
          @Lc_StatusP_CODE                       CHAR(1) = 'P',
          @Lc_StatusLocateN_CODE                 CHAR(1) = 'N',
          @Lc_ActionA_CODE                       CHAR(1) = 'A',
          @Lc_EnumerationY_CODE                  CHAR(1) = 'Y',
          @Lc_Yes_INDC                           CHAR(1) = 'Y',
          @Lc_TypePrimaryP_CODE                  CHAR(1) = 'P',
          @Lc_TypePrimaryS_CODE                  CHAR(1) = 'S',
          @Lc_TypePrimaryT_CODE                  CHAR(1) = 'T',
          @Lc_StatusCaseO_CODE                   CHAR(1) = 'O',
          @Lc_TypeCaseH_CODE                     CHAR(1) = 'H',
          @Lc_RespondInitI_CODE                  CHAR(1) = 'I',
          @Lc_TransTypeCaseAdd_CODE              CHAR(2) = 'CA',
          @Lc_TransTypeCaseChange_CODE           CHAR(2) = 'CC',
          @Lc_TransTypeCaseDelete_CODE           CHAR(2) = 'CD',
          @Lc_TransTypePersonAdd_CODE            CHAR(2) = 'PA',
          @Lc_TransTypePersonChange_CODE         CHAR(2) = 'PC',
          @Lc_TransTypePersonDelete_CODE         CHAR(2) = 'PD',
          @Lc_TransTypePersonMerge_CODE          CHAR(2) = 'PM',
          @Lc_TransTypePersonLocate_CODE         CHAR(2) = 'PL',
          @Lc_RecFcrQuery_ID                     CHAR(2) = 'FR',
          @Lc_NcoaRecNc_IDNO                     CHAR(2) = 'NC',
          @Lc_NcoaStateFips10_CODE               CHAR(2) = '10',
          @Lc_CountryUs_CODE                     CHAR(2) = 'US',
          @Lc_SubsystemLoc_CODE                  CHAR(3) = 'LO',
          @Lc_ActivityMajorCase_CODE             CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO                 CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT                  CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE                CHAR(5) = 'E0944',
          @Lc_ActivityMinorStfcr_CODE            CHAR(5) = 'STFCR',
          @Lc_Job_ID                             CHAR(7) = 'DEB5380',
          @Lc_DateFormatYyyymmdd_TEXT            CHAR(8) = 'YYYYMMDD',
          @Lc_Notice_ID                          CHAR(8) = NULL,
          @Lc_Successful_TEXT                    CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT               CHAR(30) = 'PARM DATE PROBLEM',
          @Lc_WorkerDelegate_ID                  CHAR(30) = ' ',
          @Lc_Reference_ID                       CHAR(30) = ' ',
          @Ls_Procedure_NAME                     VARCHAR(100) = 'SP_EXTRACT_CREATE_FCR_TRANSACTIONS',
          @Ls_Process_NAME                       VARCHAR(100) = 'BATCH_LOC_OUTGOING_FCR',
          @Ls_NoteDescriptionQuerySubmitted_TEXT VARCHAR(4000) = 'QUERY REQUEST SUBMITTED TO FCR',
          @Ls_XmlIn_TEXT                         VARCHAR(4000) = ' ',
          @Ld_High_DATE                          DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_Batch_NUMB                  NUMERIC(6) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_MajorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_TransKeyRecCount_QNTY       NUMERIC(10, 0) = 0,
          @Ln_PersonLocateRecCount_QNTY   NUMERIC(10, 0) = 0,
          @Ln_FcrQueryRecCount_QNTY       NUMERIC(10, 0) = 0,
          @Ln_NcoaRecCount_QNTY           NUMERIC(10) = 0,
          @Ln_Schedule_NUMB               NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10),
          @Ln_TopicIn_IDNO                NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_Periodic_AMNT               NUMERIC(11, 2) = 0,
          @Ln_ExpectToPay_AMNT            NUMERIC(11, 2) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Empty_TEXT                  CHAR = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_Note_INDC                   CHAR(1) = '',
          @Lc_CountyFips_CODE             CHAR(3),
          @Lc_BateError_CODE              CHAR(5),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Lc_TranskeyCur_TransType_CODE CHAR(2),
          @Ln_TranskeyCur_Case_IDNO      NUMERIC(6),
          @Ln_TranskeyCur_MemberMci_IDNO NUMERIC(10) = 0,
          @Ln_MemberCur_Case_IDNO        NUMERIC(6),
          @Ln_MemberCur_MemberMci_IDNO   NUMERIC(10),
          @Ln_RecordCur_Case_IDNO        NUMERIC(6),
          @Ln_RecordCur_County_IDNO      NUMERIC(3),
          @Ln_RecordCur_Office_IDNO      NUMERIC(3),
          @Ln_RecordCur_MemberMci_IDNO   NUMERIC(10),
          @Ln_RecordCur_MemberSsn_NUMB   NUMERIC(9);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_CREATE_FCR_TRANSACTIONS';

   BEGIN TRANSACTION TXN_CREATE_FCR_TRANSACTIONS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --BATCH_LOC_OUTGOING_FCR-trans_keys cursor to select identified FCR transaction keys 
   DECLARE Transkey_CUR INSENSITIVE CURSOR FOR
    SELECT A.TransType_CODE,
           A.Case_IDNO,
           A.MemberMci_IDNO
      FROM PFTRK_Y1 A
     ORDER BY A.TransType_CODE;
   --BATCH_LOC_OUTGOING_FCR-locate_member cursor to select members that are not located
   DECLARE Member_CUR INSENSITIVE CURSOR FOR
    /*BATCH_LOC_OUTGOING_FCR
    '	ValidateNCPs from the member history table havingat least one open IV-D case in the CASE_Y1 table 
    	and active in locate (Exclude NCPs already considered for participanttransaction process in the current run 
    	or in the past 90 days). 
              */
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO
      FROM CMEM_Y1 a,
           CASE_Y1 b
     WHERE a.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
       AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND a.Case_IDNO = b.Case_IDNO
       AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE
       AND b.RespondInit_CODE <> @Lc_RespondInitI_CODE
       AND b.TypeCase_CODE <> @Lc_TypeCaseH_CODE
       --active in locate
       AND EXISTS (SELECT 1
                     FROM LSTT_Y1 c
                    WHERE a.MemberMci_IDNO = c.MemberMci_IDNO
                      AND c.StatusLocate_CODE = @Lc_StatusLocateN_CODE
                      AND c.EndValidity_DATE = @Ld_High_DATE)
       --Exclude NCPs already considered for participanttransaction process in the past 90 days
       AND NOT EXISTS (SELECT 1
                         FROM FADT_Y1 d
                        WHERE a.MemberMci_IDNO = d.MemberMci_IDNO
                          AND a.Case_IDNO = d.Case_IDNO
                          AND d.Transmitted_DATE >= DATEADD(D, -90, @Ld_Run_DATE))
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 g
                        WHERE a.MemberMci_IDNO = g.MemberMci_IDNO
                          AND a.Case_IDNO = g.Case_IDNO
                          AND g.Action_CODE = @Lc_ActionA_CODE
                          AND g.Error1_CODE <> 'PE007')
       --Exclude NCPs already considered for participanttransaction process in the current run
       AND NOT EXISTS (SELECT 1
                         FROM PFTRK_Y1 e
                        WHERE a.MemberMci_IDNO = e.MemberMci_IDNO
                          AND a.Case_IDNO = e.Case_IDNO)
     ORDER BY a.Case_IDNO,
              a.MemberMci_IDNO;
   --BATCH_LOC_OUTGOING_FCR-FCR Query record cursor 
   DECLARE Record_CUR INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.County_IDNO,
           a.Office_IDNO,
           b.MemberMci_IDNO,
           s.MemberSsn_NUMB
      FROM CASE_Y1 a,
           CMEM_Y1 b,
           --Get member verified SSN from vmssn
           /*BATCH_LOC_OUTGOING_FCR
           '	Skip the NCPs who do not don'thave a verified SSN. Access SSN database table by using SSN from DEMO_Y1 table.
           */
           (SELECT n.MemberSsn_NUMB,
                   n.MemberMci_IDNO
              FROM (SELECT n.MemberSsn_NUMB,
                           n.MemberMci_IDNO,
                           ROW_NUMBER() OVER(PARTITION BY n.MemberMci_IDNO ORDER BY n.TypePrimary_CODE) AS rnm
                      FROM MSSN_Y1 n
                     WHERE n.Enumeration_CODE = @Lc_EnumerationY_CODE
                       AND n.TypePrimary_CODE IN (@Lc_TypePrimaryP_CODE, @Lc_TypePrimaryS_CODE, @Lc_TypePrimaryT_CODE)
                       AND n.EndValidity_DATE = @Ld_High_DATE) n
             WHERE n.rnm = 1) s
     WHERE
     /*BATCH_LOC_OUTGOING_FCR
     having at least one open intergovernmental or responding IV-D case in the CASE_Y1 table
     */
     a.StatusCase_CODE = @Lc_StatusCaseO_CODE
    AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
    AND a.RespondInit_CODE <> @Lc_RespondInitI_CODE
    AND b.Case_IDNO = a.Case_IDNO
    AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
    AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
    AND b.MemberMci_IDNO = s.MemberMci_IDNO
    --BATCH_LOC_OUTGOING_FCR-active in locate
    AND EXISTS (SELECT 1
               FROM LSTT_Y1 l
              WHERE b.MemberMci_IDNO = l.MemberMci_IDNO
                AND l.StatusLocate_CODE = @Lc_StatusLocateN_CODE
                AND l.EndValidity_DATE = @Ld_High_DATE)
    --BATCH_LOC_OUTGOING_FCR-has not been submitted to FCR query in past 90 days
    AND NOT EXISTS (SELECT 1
                   FROM FADT_Y1 d
                  WHERE b.MemberMci_IDNO = d.MemberMci_IDNO
                    AND a.Case_IDNO = d.Case_IDNO
                    AND d.Transmitted_DATE >= DATEADD(D, -90, @Ld_Run_DATE))
    AND NOT EXISTS (SELECT 1
                   FROM PFTRK_Y1 e
                  WHERE b.MemberMci_IDNO = e.MemberMci_IDNO
                    AND a.Case_IDNO = e.Case_IDNO)
    /*BATCH_LOC_OUTGOING_FCR
    	Skip the NCP who have a regular payment(s) in last 35 calendar days
    */
    AND NOT EXISTS (SELECT 1
                   FROM RCTH_Y1 r
                  WHERE b.MemberMci_IDNO = r.PayorMCI_IDNO
                    AND r.Receipt_DATE >= DATEADD(D, -35, @Ld_Run_DATE)
                    AND r.SourceReceipt_CODE NOT IN ('ST', 'FD', 'SQ', 'WC',
                                                     'SC', 'PM', 'NR', 'CR')
                    AND r.EndValidity_DATE = @Ld_High_DATE
                    AND NOT EXISTS (SELECT 1
                                      FROM RCTH_Y1 c
                                     WHERE r.Batch_DATE = c.Batch_DATE
                                       AND r.SourceBatch_CODE = c.SourceBatch_CODE
                                       AND r.Batch_NUMB = c.Batch_NUMB
                                       AND r.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                       AND c.BackOut_INDC = @Lc_Yes_INDC
                                       AND c.EndValidity_DATE = @Ld_High_DATE));

   /*BATCH_LOC_OUTGOING_FCR
   o	Delete all the records from temporary tables for case, member, query and NCOA table
   */
   SET @Ls_Sql_TEXT = 'DELETE FROM EFCAS_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EFCAS_Y1;

   /*BATCH_LOC_OUTGOING_FCR
   o	Delete all the records from temporary tables for case, member, query and NCOA table
   */
   SET @Ls_Sql_TEXT = 'DELETE FROM EFMEM_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EFMEM_Y1;

   /*BATCH_LOC_OUTGOING_FCR
   o	Delete all the records from temporary tables for case, member, query and NCOA table
   */
   SET @Ls_Sql_TEXT = 'DELETE FROM EFQRY_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EFQRY_Y1;

   /*BATCH_LOC_OUTGOING_FCR
   o	Delete all the records from temporary tables for case, member, query and NCOA table
   */
   SET @Ls_Sql_TEXT = 'DELETE FROM EFNCA_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM EFNCA_Y1;

   --Get Batch number
   SET @Ls_Sql_TEXT = 'GET Batch_NUMB FORM FADT_Y1';
   SET @Ls_SqlData_TEXT = 'Transmitted_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '');

   SELECT @Ln_Batch_NUMB = (ISNULL(MAX(a.Batch_NUMB), 0) + 1)
     FROM FADT_Y1 a
    WHERE a.Transmitted_DATE = @Ld_LastRun_DATE;

   --Get the last submitted batch number from fadt
   IF @Ln_Batch_NUMB = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'GET THE LAST SUBMITTED BATCH NUMBER FROM FADT_Y1';
     SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '');

     SELECT @Ln_Batch_NUMB = (ISNULL(MAX(a.Batch_NUMB), 0) + 1)
       FROM FADT_Y1 a
      WHERE a.Transmitted_DATE = (SELECT TOP 1 MAX(x.EffectiveRun_DATE)
                                    FROM BSTL_Y1 x
                                   WHERE x.Job_ID = @Lc_Job_ID
                                     AND x.Status_CODE = @Lc_StatusSuccess_CODE);
    END

   --Generate Sequence 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FOR CASE/MEMBER RECORDS';
   SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Transkey_CUR';

   OPEN Transkey_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Transkey_CUR - 1';

   FETCH NEXT FROM Transkey_CUR INTO @Lc_TranskeyCur_TransType_CODE, @Ln_TranskeyCur_Case_IDNO, @Ln_TranskeyCur_MemberMci_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Transkey_CUR';

   --process case and member records...
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_TransKeyRecCount_QNTY = @Ln_TransKeyRecCount_QNTY + 1;
     SET @Ls_CursorLocation_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@Ln_TranskeyCur_Case_IDNO, '') AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(ISNULL(@Ln_TranskeyCur_MemberMci_IDNO, '') AS VARCHAR) + ', Transkey - CURSOR COUNT = ' + CAST(ISNULL(@Ln_TransKeyRecCount_QNTY, '') AS VARCHAR);
     SET @Ls_Sql_TEXT = 'CHECK WHETHER TRANS TYPE IS CASE';

     IF @Lc_TranskeyCur_TransType_CODE IN (@Lc_TransTypeCaseAdd_CODE, @Lc_TransTypeCaseChange_CODE, @Lc_TransTypeCaseDelete_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_LOC_OUTGOING_FCR$SP_PROCESS_CASE';
       SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransType_CODE = ' + ISNULL(@Lc_TranskeyCur_TransType_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TranskeyCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_TranskeyCur_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       EXECUTE BATCH_LOC_OUTGOING_FCR$SP_PROCESS_CASE
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TransType_CODE           = @Lc_TranskeyCur_TransType_CODE,
        @An_Case_IDNO                = @Ln_TranskeyCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_TranskeyCur_MemberMci_IDNO,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
        @An_Batch_NUMB               = @Ln_Batch_NUMB,
        @Ac_Job_ID                   = @Lc_Job_ID;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR(50001,16,1);
        END
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'CHECK WHETHER TRANS TYPE IS MEMBER';

       IF @Lc_TranskeyCur_TransType_CODE IN (@Lc_TransTypePersonAdd_CODE, @Lc_TransTypePersonChange_CODE, @Lc_TransTypePersonDelete_CODE, @Lc_TransTypePersonMerge_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON';
         SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', TransType_CODE = ' + ISNULL(@Lc_TranskeyCur_TransType_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TranskeyCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_TranskeyCur_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

         EXECUTE BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_Process_INDC             = @Lc_Space_TEXT,
          @Ac_TransType_CODE           = @Lc_TranskeyCur_TransType_CODE,
          @An_Case_IDNO                = @Ln_TranskeyCur_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_TranskeyCur_MemberMci_IDNO,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
          @An_Batch_NUMB               = @Ln_Batch_NUMB,
          @Ac_Job_ID                   = @Lc_Job_ID;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

           RAISERROR(50001,16,1);
          END
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Transkey_CUR - 2';

     FETCH NEXT FROM Transkey_CUR INTO @Lc_TranskeyCur_TransType_CODE, @Ln_TranskeyCur_Case_IDNO, @Ln_TranskeyCur_MemberMci_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'Transkey_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE Transkey_CUR';

     CLOSE Transkey_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Transkey_CUR';

     DEALLOCATE Transkey_CUR;
    END

   --Generate Sequence 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FOR MEMBER LOCATE RECORDS';
   SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Member_CUR';

   OPEN Member_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Member_CUR - 1';

   FETCH NEXT FROM Member_CUR INTO @Ln_MemberCur_Case_IDNO, @Ln_MemberCur_MemberMci_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Member_CUR';

   --process member locate records
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_PersonLocateRecCount_QNTY = @Ln_PersonLocateRecCount_QNTY + 1;
     SET @Ls_CursorLocation_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@Ln_MemberCur_Case_IDNO, '') AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(ISNULL(@Ln_MemberCur_MemberMci_IDNO, '') AS VARCHAR) + ', Member Locate Record - CURSOR COUNT = ' + CAST(ISNULL(@Ln_PersonLocateRecCount_QNTY, '') AS VARCHAR);
     SET @Ls_Sql_TEXT = 'BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON FOR LOCATE';
     SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessFlagPersonLocate_INDC, '') + ', TransType_CODE = ' + ISNULL(@Lc_TransTypePersonLocate_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_MemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberCur_MemberMci_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     EXECUTE BATCH_LOC_OUTGOING_FCR$SP_PROCESS_PERSON
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_Process_INDC             = @Lc_ProcessFlagPersonLocate_INDC,
      @Ac_TransType_CODE           = @Lc_TransTypePersonLocate_CODE,
      @An_Case_IDNO                = @Ln_MemberCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_MemberCur_MemberMci_IDNO,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
      @An_Batch_NUMB               = @Ln_Batch_NUMB,
      @Ac_Job_ID                   = @Lc_Job_ID;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Member_CUR - 2';

     FETCH NEXT FROM Member_CUR INTO @Ln_MemberCur_Case_IDNO, @Ln_MemberCur_MemberMci_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'Member_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE Member_CUR';

     CLOSE Member_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Member_CUR';

     DEALLOCATE Member_CUR;
    END

   --Generate Sequence 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FOR FCR QUERY RECORDS';
   SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN Record_CUR';

   OPEN Record_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Record_CUR - 1';

   FETCH NEXT FROM Record_CUR INTO @Ln_RecordCur_Case_IDNO, @Ln_RecordCur_County_IDNO, @Ln_RecordCur_Office_IDNO, @Ln_RecordCur_MemberMci_IDNO, @Ln_RecordCur_MemberSsn_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Record_CUR';

   --process fcr query records...
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_FcrQueryRecCount_QNTY = @Ln_FcrQueryRecCount_QNTY + 1;
     SET @Ls_CursorLocation_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@Ln_RecordCur_Case_IDNO, '') AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(ISNULL(@Ln_RecordCur_MemberMci_IDNO, '') AS VARCHAR) + ', FCR Query Record - CURSOR COUNT = ' + CAST(ISNULL(@Ln_FcrQueryRecCount_QNTY, '') AS VARCHAR);
     SET @Ln_Periodic_AMNT = 0;
     SET @Ln_ExpectToPay_AMNT = 0;
     SET @Lc_CountyFips_CODE = @Lc_Space_TEXT;
     SET @Ls_Sql_TEXT = 'GET COUNTY FIPS CODE FROM COUNTY ID';

     IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(@Ln_RecordCur_County_IDNO) IS NOT NULL
      BEGIN
       SET @Lc_CountyFips_CODE = (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(@Ln_RecordCur_County_IDNO AS VARCHAR))), 3));
      END

     --Get sum of amt_periodic and expect_to_pay from voble;    
     /*BATCH_LOC_OUTGOING_FCR
     '	Skip the NCPs who do not have acharge amount and no arrears pay back amount in any of the IV-D cases i.e.:
     	o	SUM(Periodic Amount) = Zero
     	o	SUM(Expect to Pay) = Zero
     */
     SET @Ls_Sql_TEXT = 'SELECT FORM OBLE_Y1';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_RecordCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_Periodic_AMNT = SUM(o.Periodic_AMNT),
            @Ln_ExpectToPay_AMNT = SUM(o.ExpectToPay_AMNT)
       FROM OBLE_Y1 o
      WHERE o.Case_IDNO = @Ln_RecordCur_Case_IDNO
        AND @Ld_Run_DATE BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE
        AND o.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Periodic_AMNT > 0
         OR @Ln_ExpectToPay_AMNT > 0
      BEGIN
       /*BATCH_LOC_OUTGOING_FCR
       	Insert NCP details into the EFQRY_Y1 table.
       */
       SET @Ls_Sql_TEXT = 'INSERT INTO EFQRY_Y1';
       SET @Ls_SqlData_TEXT = 'Rec_ID = ' + ISNULL(@Lc_RecFcrQuery_ID, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_TypeActionQueryRequest_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_RecordCur_Case_IDNO AS VARCHAR), '') + ', CountyFips_CODE = ' + ISNULL(@Lc_CountyFips_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RecordCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_RecordCur_MemberSsn_NUMB AS VARCHAR), '');

       INSERT EFQRY_Y1
              (Rec_ID,
               TypeAction_CODE,
               Case_IDNO,
               UserField_NAME,
               CountyFips_CODE,
               MemberMci_IDNO,
               MemberSsn_NUMB)
       VALUES ( @Lc_RecFcrQuery_ID,--Rec_ID
                @Lc_TypeActionQueryRequest_CODE,--TypeAction_CODE
                @Ln_RecordCur_Case_IDNO,--Case_IDNO
                CONVERT(VARCHAR(8), @Ld_Run_DATE, 112),--UserField_NAME
                @Lc_CountyFips_CODE,--CountyFips_CODE
                @Ln_RecordCur_MemberMci_IDNO,--MemberMci_IDNO
                @Ln_RecordCur_MemberSsn_NUMB --MemberSsn_NUMB
       );

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO EFQRY_Y1 FAILED';

         RAISERROR (50001,16,1);
        END;

       --make a case journal entry
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 4';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_RecordCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RecordCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemLoc_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_RecordCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_RecordCur_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorStfcr_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
        @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
        @Ac_Reference_ID             = @Lc_Reference_ID,
        @Ac_Notice_ID                = @Lc_Notice_ID,
        @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @As_Xml_TEXT                 = @Ls_XmlIn_TEXT,
        @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
        @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
        @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END;

       --Notes added for corresponding case journal entry
       SET @Ls_Sql_TEXT = 'BATCH_COMMON_NOTE$SP_CREATE_NOTE - 4';
       SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_RecordCur_Case_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', DescriptionNote_TEXT = ' + ISNULL(@Ls_NoteDescriptionQuerySubmitted_TEXT, '') + ', Category_CODE = ' + ISNULL(@Lc_SubsystemLoc_CODE, '') + ', Subject_CODE = ' + ISNULL(@Lc_ActivityMinorStfcr_CODE, '') + ', WorkerSignedOn_IDNO = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '');

       EXECUTE BATCH_COMMON_NOTE$SP_CREATE_NOTE
        @Ac_Case_IDNO                = @Ln_RecordCur_Case_IDNO,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @As_DescriptionNote_TEXT     = @Ls_NoteDescriptionQuerySubmitted_TEXT,
        @Ac_Category_CODE            = @Lc_SubsystemLoc_CODE,
        @Ac_Subject_CODE             = @Lc_ActivityMinorStfcr_CODE,
        @As_WorkerSignedOn_IDNO      = @Lc_BatchRunUser_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END;
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Record_CUR - 2';

     FETCH NEXT FROM Record_CUR INTO @Ln_RecordCur_Case_IDNO, @Ln_RecordCur_County_IDNO, @Ln_RecordCur_Office_IDNO, @Ln_RecordCur_MemberMci_IDNO, @Ln_RecordCur_MemberSsn_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'Record_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE Record_CUR';

     CLOSE Record_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE Record_CUR';

     DEALLOCATE Record_CUR;
    END

   /*BATCH_LOC_OUTGOING_FCR-NCOA Address Extract Process
   All new addresses added to DACSES with a date received greater than last run date.
   Members new US addresses added to the system
   Member US addresses end-dated since last run of this program      
   */
   SET @Ls_Sql_TEXT = 'INSERT INTO EFNCA_Y1';
   SET @Ls_SqlData_TEXT = 'Rec_ID = ' + ISNULL(@Lc_NcoaRecNc_IDNO, '') + ', TypeAction_CODE = ' + ISNULL(@Lc_NcoaTypeActionV_CODE, '') + ', StateFips_CODE = ' + ISNULL(@Lc_NcoaStateFips10_CODE, '');

   INSERT EFNCA_Y1
          (Rec_ID,
           TypeAction_CODE,
           StateFips_CODE,
           First_NAME,
           Middle_NAME,
           Last_NAME,
           Line1_ADDR,
           Line2_ADDR,
           City_ADDR,
           State_ADDR,
           Zip_ADDR,
           MemberSsn_NUMB,
           MemberMci_IDNO,
           UserField_NAME)
   SELECT @Lc_NcoaRecNc_IDNO AS Rec_ID,
          @Lc_NcoaTypeActionV_CODE AS TypeAction_CODE,
          @Lc_NcoaStateFips10_CODE AS StateFips_CODE,
          SUBSTRING(ISNULL(M.First_NAME, REPLICATE(' ', 16)), 1, 16) AS First_NAME,
          SUBSTRING(ISNULL(M.Middle_NAME, REPLICATE(' ', 16)), 1, 16) AS Middle_NAME,
          SUBSTRING(ISNULL(M.Last_NAME, REPLICATE(' ', 30)), 1, 30) AS Last_NAME,
          SUBSTRING(ISNULL(X.Line1_ADDR, REPLICATE(' ', 40)), 1, 40) AS Line1_ADDR,
          SUBSTRING(ISNULL(X.Line2_ADDR, REPLICATE(' ', 40)), 1, 40) AS Line2_ADDR,
          SUBSTRING(ISNULL(X.City_ADDR, REPLICATE(' ', 20)), 1, 20) AS City_ADDR,
          SUBSTRING(ISNULL(X.State_ADDR, REPLICATE(' ', 2)), 1, 2) AS State_ADDR,
          SUBSTRING(REPLACE(ISNULL(X.Zip_ADDR, REPLICATE(' ', 9)), '-', ''), 1, 9) AS Zip_ADDR,
          ISNULL(M.MemberSsn_NUMB, 0) AS MemberSsn_NUMB,
          X.MemberMci_IDNO,
          CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) AS UserField_NAME
     FROM AHIS_Y1 X,
          DEMO_Y1 M
    WHERE X.Country_ADDR = @Lc_CountryUs_CODE
      AND ((X.End_DATE = @Ld_High_DATE
            AND X.SourceReceived_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
            AND X.SourceReceived_DATE <> @Ld_High_DATE)
            OR (X.End_DATE <> @Ld_High_DATE
                AND X.Status_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
                AND X.Status_DATE <> @Ld_High_DATE))
      AND X.Status_CODE = @Lc_StatusP_CODE
      AND M.MemberMci_IDNO = X.MemberMci_IDNO
      AND EXISTS(SELECT 1
                   FROM CMEM_Y1 A
                  WHERE A.MemberMci_IDNO = M.MemberMci_IDNO
                    AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                    AND EXISTS(SELECT 1
                                 FROM CASE_Y1 B
                                WHERE B.Case_IDNO = A.Case_IDNO
                                  AND B.StatusCase_CODE = @Lc_StatusCaseO_CODE));

   SET @Ln_NcoaRecCount_QNTY = @@ROWCOUNT;
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_ProcessedRecordCount_QNTY = SUM(ISNULL(A.RecordCount_QNTY, 0))
     FROM (SELECT COUNT(1) AS RecordCount_QNTY
             FROM EFCAS_Y1
           UNION ALL
           SELECT COUNT(1) AS RecordCount_QNTY
             FROM EFMEM_Y1
           UNION ALL
           SELECT COUNT(1) AS RecordCount_QNTY
             FROM EFQRY_Y1
           UNION ALL
           SELECT COUNT(1) AS RecordCount_QNTY
             FROM EFNCA_Y1) A;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
     SET @Ls_SqlData_TEXT = '';

     SELECT @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE,
            @Ls_ErrorMessage_TEXT = 'NO RECORD(S) TO PROCESS';

     SET @Ls_SqlData_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', ErrorMessage_TEXT = ' + ISNULL(@Ls_ErrorMessage_TEXT, '') + ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', Sqldata_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '') + ', Error_NUMB = ' + ISNULL(CAST(@Ln_Error_NUMB AS VARCHAR), '') + ', ErrorLine_NUMB = ' + ISNULL(CAST(@Ln_ErrorLine_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_CREATE_FCR_TRANSACTIONS';

   COMMIT TRANSACTION TXN_CREATE_FCR_TRANSACTIONS;

   SET @Ls_Sql_TEXT = 'EXTRACT DATA AND CREATE FCR INPUT FILE';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '');

   EXECUTE BATCH_LOC_OUTGOING_FCR$SP_GENERATE_FCR_FILE
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @As_File_NAME             = @Ls_File_NAME,
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @An_Batch_NUMB            = @Ln_Batch_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_CREATE_FCR_TRANSACTIONS';

   BEGIN TRANSACTION TXN_CREATE_FCR_TRANSACTIONS;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_CREATE_FCR_TRANSACTIONS';

   COMMIT TRANSACTION TXN_CREATE_FCR_TRANSACTIONS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_CREATE_FCR_TRANSACTIONS;
    END

   IF CURSOR_STATUS('LOCAL', 'Transkey_CUR') IN (0, 1)
    BEGIN
     CLOSE Transkey_CUR;

     DEALLOCATE Transkey_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'Member_CUR') IN (0, 1)
    BEGIN
     CLOSE Member_CUR;

     DEALLOCATE Member_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'Record_CUR') IN (0, 1)
    BEGIN
     CLOSE Record_CUR;

     DEALLOCATE Record_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
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
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
