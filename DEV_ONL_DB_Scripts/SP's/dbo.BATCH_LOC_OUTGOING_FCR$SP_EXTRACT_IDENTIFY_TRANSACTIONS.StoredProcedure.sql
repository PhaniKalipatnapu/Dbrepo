/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_IDENTIFY_TRANSACTIONS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_IDENTIFY_TRANSACTIONS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_IDENTIFY_TRANSACTIONS batch process is to 
					  identify all new case records, new member records, updated case records, updated member records 
					  and merged member records since the last FCR run.
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
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_FCR$SP_EXTRACT_IDENTIFY_TRANSACTIONS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_CaseMemberStatusA_CODE     CHAR = 'A',
          @Lc_CaseMemberStatusI_CODE     CHAR = 'I',
          @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_StatusAbnormalEnd_CODE     CHAR(1) = 'A',
          @Lc_TypeError_CODE             CHAR(1) = 'E',
          @Lc_Zero_TEXT                  CHAR(1) = '0',
          @Lc_StatusCaseO_CODE           CHAR(1) = 'O',
          @Lc_StatusCaseC_CODE           CHAR(1) = 'C',
          @Lc_TypeCaseH_CODE             CHAR(1) = 'H',
          @Lc_ActionA_CODE               CHAR(1) = 'A',
          @Lc_ActionC_CODE               CHAR(1) = 'C',
          @Lc_ActionD_CODE               CHAR(1) = 'D',
          @Lc_RejectR_CODE               CHAR(1) = 'R',
          @Lc_TypeOrderV_CODE            CHAR(1) = 'V',
          @Lc_No_INDC                    CHAR(1) = 'N',
          @Lc_EnumerationY_CODE          CHAR(1) = 'Y',
          @Lc_EnumerationP_CODE          CHAR(1) = 'P',
          @Lc_StatusMergeM_CODE          CHAR(1) = 'M',
          @Lc_TypePrimaryP_CODE          CHAR(1) = 'P',
          @Lc_TransTypeCaseAdd_CODE      CHAR(2) = 'CA',
          @Lc_TransTypeCaseChange_CODE   CHAR(2) = 'CC',
          @Lc_TransTypeCaseDelete_CODE   CHAR(2) = 'CD',
          @Lc_TransTypePersonAdd_CODE    CHAR(2) = 'PA',
          @Lc_TransTypePersonChange_CODE CHAR(2) = 'PC',
          @Lc_TransTypePersonDelete_CODE CHAR(2) = 'PD',
          @Lc_TransTypePersonMerge_CODE  CHAR(2) = 'PM',
          @Lc_TypeTransFc_CODE           CHAR(2) = 'FC',
          @Lc_TypeTransFp_CODE           CHAR(2) = 'FP',
          @Lc_TypeDebtCs_CODE            CHAR(2) = 'CS',
          @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE        CHAR(5) = 'E0944',
          @Lc_Job_ID                     CHAR(7) = 'DEB5290',
          @Lc_Successful_TEXT            CHAR(20) = 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT       CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME             VARCHAR(100) = 'SP_EXTRACT_IDENTIFY_TRANSACTIONS',
          @Ls_Process_NAME               VARCHAR(100) = 'BATCH_LOC_OUTGOING_FCR',
          @Ld_High_DATE                  DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Mmrg_QNTY                   NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10),
          @Ln_Case_QNTY                   NUMERIC(10) = 0,
          @Ln_Member_QNTY                 NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowCount_QNTY               SMALLINT,
          @Lc_Empty_TEXT                  CHAR = '',
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_BateError_CODE              CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Lc_FtrkCaseCur_Case_IDNO               CHAR(6),
          @Lc_FtrkCaseCur_TransType_CODE          CHAR(2),
          @Lc_FtrkMemberCur_Case_IDNO             CHAR(6),
          @Lc_FtrkMemberCur_MemberMci_IDNO        CHAR(10),
          @Lc_FtrkMemberCur_TransType_CODE        CHAR(2),
          @Ln_FtrkMmrgCur_MemberMciPrimary_IDNO   NUMERIC(10),
          @Ln_FtrkMmrgCur_MemberMciSecondary_IDNO NUMERIC(10),
          @Lc_FtrkMmrgCur_TransType_CODE          CHAR(2),
          @Lc_FtrkMmrgCur_Case_IDNO               CHAR(6);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_IDENTIFY_TRANSACTIONS';

   BEGIN TRANSACTION TXN_IDENTIFY_TRANSACTIONS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Cursor to identify  actions (Add/change/Delete) taken by worker/system against Case          
   DECLARE FtrkCase_CUR INSENSITIVE CURSOR FOR
    /*
    Get the Cases created (or) changed(from NIVD to IVD) after last run date
    if case is added after the last run of FCR extract keys process
    */
    SELECT a.Case_IDNO,
           @Lc_TransTypeCaseAdd_CODE AS TransType_CODE
      FROM CASE_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND (NOT EXISTS (SELECT 1
                          FROM HCASE_Y1 b
                         WHERE a.Case_IDNO = b.Case_IDNO
                           AND b.BeginValidity_DATE <= @Ld_LastRun_DATE)
             OR EXISTS (SELECT 1
                          FROM HCASE_Y1 c
                         WHERE a.Case_IDNO = c.Case_IDNO
                           AND (a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
                                AND c.TypeCase_CODE = @Lc_TypeCaseH_CODE)
                           AND c.TransactionEventSeq_NUMB = (SELECT MAX(d.TransactionEventSeq_NUMB)
                                                               FROM HCASE_Y1 d
                                                              WHERE c.Case_IDNO = d.Case_IDNO
                                                                AND d.BeginValidity_DATE <= @Ld_LastRun_DATE)))
    UNION ALL
    /*
    Get the Cases created after last run date was rejected by FCR
    if case which was sent as an ADD was rejected by FCR after the last run of FCR
    */
    SELECT c.Case_IDNO,
           @Lc_TransTypeCaseAdd_CODE AS TransType_CODE
      FROM CASE_Y1 c
     WHERE c.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND c.WorkerUpdate_ID <> 'CONVERSION'
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND TypeTrans_CODE = @Lc_TypeTransFc_CODE
                      AND (a.MemberMci_IDNO = @Ln_Zero_NUMB
                            OR LEN(LTRIM(RTRIM(ISNULL(a.MemberMci_IDNO, '')))) = 0)
                      AND DATEDIFF(D, Transmitted_DATE, @Ld_LastRun_DATE) = 0)
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE c.Case_IDNO = r.Case_IDNO
                      AND (r.MemberMci_IDNO = @Ln_Zero_NUMB
                            OR LEN(LTRIM(RTRIM(ISNULL(r.MemberMci_IDNO, '')))) = 0)
                      AND r.Action_CODE = @Lc_ActionA_CODE
                      AND DATEDIFF(D, Transmitted_DATE, @Ld_LastRun_DATE) = 0
                      AND Received_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE)
    UNION ALL
    /*
    Get the Cases that are not on FCR and was rejected by FCR 
    */
    SELECT r.Case_IDNO,
           @Lc_TransTypeCaseAdd_CODE AS TransType_CODE
      FROM FPRJ_Y1 r
     WHERE r.Received_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND (r.MemberMci_IDNO = @Ln_Zero_NUMB
             OR LEN(LTRIM(RTRIM(ISNULL(r.MemberMci_IDNO, '')))) = 0)
       AND r.Error1_CODE = 'PE002'
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE r.Case_IDNO = a.Case_IDNO
                      AND r.MemberMci_IDNO = a.MemberMci_IDNO
                      AND a.TypeTrans_CODE = @Lc_TypeTransFc_CODE
                      AND (a.MemberMci_IDNO = @Ln_Zero_NUMB
                            OR LEN(LTRIM(RTRIM(ISNULL(a.MemberMci_IDNO, '')))) = 0))
       AND EXISTS(SELECT 1
                    FROM CASE_Y1 c
                   WHERE c.Case_IDNO = r.Case_IDNO
                     AND c.StatusCase_CODE = @Lc_StatusCaseO_CODE)
    UNION ALL
    /*
    if case was sent as a delete earlier but the case is open in DACSES
    */
    SELECT c.Case_IDNO,
           @Lc_TransTypeCaseAdd_CODE AS TransType_CODE
      FROM CASE_Y1 c
     WHERE c.StatusCase_CODE = @Lc_StatusCaseO_CODE
       AND c.WorkerUpdate_ID <> 'CONVERSION'
       AND BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 x
                    WHERE x.Case_IDNO = c.Case_IDNO
                      AND (x.MemberMci_IDNO = @Ln_Zero_NUMB
                            OR LEN(LTRIM(RTRIM(ISNULL(x.MemberMci_IDNO, '')))) = 0)
                      AND x.TypeTrans_CODE = @Lc_TypeTransFc_CODE
                      AND x.Action_CODE = @Lc_ActionD_CODE
                      AND x.StatusCase_CODE = @Lc_StatusCaseC_CODE
                      AND x.Transmitted_DATE = @Ld_LastRun_DATE
                      AND NOT EXISTS (SELECT 1
                                        FROM FPRJ_Y1 y
                                       WHERE y.Case_IDNO = x.Case_IDNO
                                         AND y.MemberMci_IDNO = x.MemberMci_IDNO
                                         AND y.Action_CODE = x.Action_CODE
                                         AND y.Reject_CODE = @Lc_RejectR_CODE
                                         AND y.Transmitted_DATE = x.Transmitted_DATE))
    UNION ALL
    /*
    Get the Non-IVD Cases having child support order established after last run date
    */
    SELECT DISTINCT
           b.Case_IDNO,
           @Lc_TransTypeCaseAdd_CODE AS TransType_CODE
      FROM OBLE_Y1 b
     WHERE b.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND EXISTS(SELECT 1
                    FROM GLEV_Y1 X
                   WHERE X.EventGlobalSeq_NUMB = B.EventGlobalBeginSeq_NUMB
                     AND X.Worker_ID <> 'CONVERSION')
       AND b.TypeDebt_CODE = @Lc_TypeDebtCs_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE
       AND NOT EXISTS (SELECT 1
                         FROM OBLE_Y1 o
                        WHERE o.Case_IDNO = b.Case_IDNO
                          AND o.BeginValidity_DATE <= @Ld_LastRun_DATE
                          AND o.TypeDebt_CODE = b.TypeDebt_CODE)
       AND EXISTS (SELECT 1
                     FROM CASE_Y1 c
                    WHERE b.Case_IDNO = c.Case_IDNO
                      AND c.StatusCase_CODE = @Lc_StatusCaseO_CODE
                      AND c.TypeCase_CODE = @Lc_TypeCaseH_CODE)
    UNION ALL
    /*
    Get the Cases from vcase where county or case type changes (IVD to Non-IVD) happend after last run date
    if County Code was changed on the case and no rejects were received from FCR 
    if Case Type was changed on the case and no rejects were received from FCR
    */
    SELECT a.Case_IDNO,
           @Lc_TransTypeCaseChange_CODE AS TransType_CODE
      FROM CASE_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND EXISTS (SELECT 1
                     FROM HCASE_Y1 b
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND ((a.County_IDNO <> b.County_IDNO)
                            OR ((a.TypeCase_CODE <> b.TypeCase_CODE)
                                AND a.TypeCase_CODE = @Lc_TypeCaseH_CODE
                                AND b.TypeCase_CODE <> @Lc_TypeCaseH_CODE))
                      AND b.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(c.TransactionEventSeq_NUMB)
                                                          FROM HCASE_Y1 c
                                                         WHERE b.Case_IDNO = c.Case_IDNO
                                                           AND c.BeginValidity_DATE <= @Ld_LastRun_DATE))
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 r
                        WHERE a.Case_IDNO = r.Case_IDNO
                          AND (r.MemberMci_IDNO = @Ln_Zero_NUMB
                                OR LEN(LTRIM(RTRIM(ISNULL(r.MemberMci_IDNO, '')))) = 0))
    UNION ALL
    /*
    Get the Cases from vcase where change transaction was rejected by FCR
    if Case Status, County Code or Case Type were changed and a reject was received from FCR 
    for the Change Transaction sent
    */
    SELECT c.Case_IDNO,
           @Lc_TransTypeCaseChange_CODE AS TransType_CODE
      FROM CASE_Y1 c
     WHERE c.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND c.WorkerUpdate_ID <> 'CONVERSION'
       AND EXISTS (SELECT 1
                     FROM HCASE_Y1 b
                    WHERE c.Case_IDNO = b.Case_IDNO
                      AND ((c.StatusCase_CODE <> b.StatusCase_CODE)
                            OR (c.County_IDNO <> b.County_IDNO)
                            OR (c.TypeCase_CODE <> b.TypeCase_CODE))
                      AND b.EndValidity_DATE = c.BeginValidity_DATE
                      AND b.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(d.TransactionEventSeq_NUMB)
                                                          FROM HCASE_Y1 d
                                                         WHERE b.Case_IDNO = d.Case_IDNO
                                                           AND b.BeginValidity_DATE <= @Ld_LastRun_DATE))
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND (a.MemberMci_IDNO = @Ln_Zero_NUMB
                            OR LEN(LTRIM(RTRIM(ISNULL(a.MemberMci_IDNO, '')))) = 0)
                      AND a.Transmitted_DATE = @Ld_LastRun_DATE
                      AND a.TypeTrans_CODE = @Lc_TypeTransFc_CODE
                      AND a.Action_CODE = @Lc_ActionC_CODE
                      AND a.StatusCase_CODE = c.StatusCase_CODE
                      AND a.County_IDNO = c.County_IDNO
                      AND a.TypeCase_CODE = c.TypeCase_CODE)
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE c.Case_IDNO = r.Case_IDNO
                      AND (r.MemberMci_IDNO = @Ln_Zero_NUMB
                            OR LEN(LTRIM(RTRIM(ISNULL(r.MemberMci_IDNO, '')))) = 0)
                      AND r.Action_CODE = @Lc_ActionC_CODE
                      AND r.Reject_CODE = @Lc_RejectR_CODE
                      AND r.Transmitted_DATE = @Ld_LastRun_DATE
                      AND r.Received_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE)
    UNION ALL
    /*
    Get the cases if child suport Order added after last run
    if an order was entered/changed 
    */
    SELECT s.Case_IDNO,
           @Lc_TransTypeCaseChange_CODE AS TransType_CODE
      FROM SORD_Y1 s
     WHERE s.BeginValidity_DATE > @Ld_LastRun_DATE
       AND s.WorkerUpdate_ID <> 'CONVERSION'
       AND s.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
       AND s.EndValidity_DATE = @Ld_High_DATE
       AND (EXISTS (SELECT 1
                      FROM FADT_Y1 x
                     WHERE x.Case_IDNO = s.Case_IDNO
                       AND x.MemberMci_IDNO = 0
                       AND x.Order_INDC = @Lc_No_INDC)
             OR EXISTS(SELECT 1
                         FROM SORD_Y1 p
                        WHERE p.Case_IDNO = s.Case_IDNO
                          AND p.OrderSeq_NUMB = s.OrderSeq_NUMB
                          AND p.EventGlobalBeginSeq_NUMB = (SELECT TOP 1 MAX(q.EventGlobalBeginSeq_NUMB)
                                                              FROM SORD_Y1 q
                                                             WHERE q.Case_IDNO = q.Case_IDNO
                                                               AND q.OrderSeq_NUMB = q.OrderSeq_NUMB
                                                               AND q.BeginValidity_DATE <= @Ld_LastRun_DATE
                                                               AND q.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
                                                               AND q.EndValidity_DATE <> @Ld_High_DATE)))
    UNION ALL
    --Get the Cases Closed after last run date
    /*
    o	Set transaction type as 'CD' 'Case Delete if the case was changed to closed from the date of last FCR run.
    */
    SELECT a.Case_IDNO,
           @Lc_TransTypeCaseDelete_CODE AS TransType_CODE
      FROM CASE_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND a.StatusCase_CODE = @Lc_StatusCaseC_CODE
       AND EXISTS (SELECT 1
                     FROM HCASE_Y1 b
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND a.StatusCase_CODE <> b.StatusCase_CODE
                      AND b.EndValidity_DATE = a.BeginValidity_DATE
                      AND b.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(c.TransactionEventSeq_NUMB)
                                                          FROM HCASE_Y1 c
                                                         WHERE b.Case_IDNO = c.Case_IDNO
                                                           AND c.BeginValidity_DATE <= @Ld_LastRun_DATE));
   --Cursor to identify  actions (Add/change/Delete) taken by worker/system against Member.
   DECLARE FtrkMember_CUR INSENSITIVE CURSOR FOR
    --Get the Members added after last run date
    /*
    	if the member was added after the last FCR run date
    */
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO,
           @Lc_TransTypePersonAdd_CODE AS TransType_CODE
      FROM CMEM_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND NOT EXISTS (SELECT 1
                         FROM HCMEM_Y1 b
                        WHERE a.Case_IDNO = b.Case_IDNO
                          AND a.MemberMci_IDNO = b.MemberMci_IDNO
                          AND b.BeginValidity_DATE <= @Ld_LastRun_DATE)
       AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND EXISTS (SELECT 1
                     FROM CASE_Y1 x
                    WHERE x.Case_IDNO = a.Case_IDNO
                      AND x.StatusCase_CODE = @Lc_StatusCaseO_CODE)
    UNION ALL
    --Get the Members added after last run date was rejected by FCR
    /*
    	if member was sent as ADD was rejected by FCR
    */
    SELECT c.Case_IDNO,
           c.MemberMci_IDNO,
           @Lc_TransTypePersonAdd_CODE AS TransType_CODE
      FROM CMEM_Y1 c
     WHERE c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND EXISTS (SELECT 1
                     FROM CASE_Y1 x
                    WHERE x.Case_IDNO = c.Case_IDNO
                      AND x.StatusCase_CODE = @Lc_StatusCaseO_CODE)
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND a.Action_CODE = @Lc_ActionA_CODE
                      AND a.TypeTrans_CODE = @Lc_TypeTransFp_CODE)
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE c.Case_IDNO = r.Case_IDNO
                      AND c.MemberMci_IDNO = r.MemberMci_IDNO
                      AND r.Action_CODE = @Lc_ActionA_CODE
                      AND r.Reject_CODE = @Lc_RejectR_CODE
                      AND r.Received_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE)
    UNION ALL
    /*
    Get the Members from vfadt where member delete submitted last week because of changes in member name, dt_birth
    */
    /*
    ?	if member was previouslysent to FCR as a DELETE transaction type but member is active on the case 
    */
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO,
           @Lc_TransTypePersonAdd_CODE AS TransType_CODE
      FROM FADT_Y1 a
     WHERE a.Transmitted_DATE = @Ld_LastRun_DATE
       AND a.Action_CODE = @Lc_ActionD_CODE
       AND a.TypeTrans_CODE = @Lc_TypeTransFp_CODE
       AND EXISTS (SELECT 1
                     FROM CMEM_Y1 c
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 r
                        WHERE a.Case_IDNO = r.Case_IDNO
                          AND a.MemberMci_IDNO = r.MemberMci_IDNO)
    UNION ALL
    /*
    Get the Members from vfadt where member add submitted last week because of changes in member name, dt_birth was rejected by FCR.
    */
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO,
           @Lc_TransTypePersonAdd_CODE AS TransType_CODE
      FROM FADT_Y1 a
     WHERE a.Transmitted_DATE = @Ld_LastRun_DATE
       AND a.Action_CODE = @Lc_ActionA_CODE
       AND a.TypeTrans_CODE = @Lc_TypeTransFp_CODE
       AND EXISTS (SELECT 1
                     FROM CMEM_Y1 c
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
       AND EXISTS (SELECT 1
                     FROM HDEMO_Y1 x
                    WHERE x.MemberMci_IDNO = a.MemberMci_IDNO
                      AND (x.Birth_DATE <> a.Birth_DATE
                            OR x.Last_NAME <> a.Last_NAME
                            OR x.First_NAME <> a.First_NAME)
                      AND EndValidity_DATE <= @Ld_LastRun_DATE)
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE a.Case_IDNO = r.Case_IDNO
                      AND a.MemberMci_IDNO = r.MemberMci_IDNO
                      AND r.Action_CODE = @Lc_ActionA_CODE
                      AND r.Transmitted_DATE = @Ld_LastRun_DATE
                      AND r.Reject_CODE = @Lc_RejectR_CODE)
    UNION ALL
    --Get the Members if relation case changes after last run date
    /*
    	if member relation in member history table was changed and no reject was received from FCR on aprevious change
    */
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO,
           @Lc_TransTypePersonChange_CODE AS TransType_CODE
      FROM CMEM_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND EXISTS (SELECT 1
                     FROM HCMEM_Y1 b
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND a.MemberMci_IDNO = b.MemberMci_IDNO
                      AND b.CaseRelationship_CODE <> a.CaseRelationship_CODE
                      AND b.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(c.TransactionEventSeq_NUMB)
                                                          FROM HCMEM_Y1 c
                                                         WHERE b.Case_IDNO = c.Case_IDNO
                                                           AND b.MemberMci_IDNO = c.MemberMci_IDNO
                                                           AND c.BeginValidity_DATE <= @Ld_LastRun_DATE))
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 y
                    WHERE y.Case_IDNO = a.Case_IDNO
                      AND y.MemberMci_IDNO = a.MemberMci_IDNO
                      AND y.TypeTrans_CODE = @Lc_TypeTransFp_CODE
                      AND y.Action_CODE = @Lc_ActionC_CODE
                      AND y.Transmitted_DATE <= @Ld_LastRun_DATE)
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 x
                        WHERE x.Case_IDNO = a.Case_IDNO
                          AND x.MemberMci_IDNO = a.MemberMci_IDNO
                          AND x.Action_CODE = @Lc_ActionC_CODE
                          AND x.Reject_CODE = @Lc_RejectR_CODE
                          AND x.Transmitted_DATE <= @Ld_LastRun_DATE)
    UNION ALL
    /* 
    Get the Members if relation case changes after last run date was rejected by FCR
    */
    /*
    ?	if the member relation in member history table was changed, there is a record in audit table 
    	and there is a reject record for FCR for change transaction
    */
    SELECT c.Case_IDNO,
           c.MemberMci_IDNO,
           @Lc_TransTypePersonChange_CODE AS TransType_CODE
      FROM CMEM_Y1 c
     WHERE c.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND c.WorkerUpdate_ID <> 'CONVERSION'
       AND EXISTS (SELECT 1
                     FROM HCMEM_Y1 b
                    WHERE c.Case_IDNO = b.Case_IDNO
                      AND c.MemberMci_IDNO = b.MemberMci_IDNO
                      AND b.CaseRelationship_CODE <> c.CaseRelationship_CODE
                      AND b.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(a.TransactionEventSeq_NUMB)
                                                          FROM HCMEM_Y1 a
                                                         WHERE b.Case_IDNO = a.Case_IDNO
                                                           AND b.MemberMci_IDNO = a.MemberMci_IDNO
                                                           AND a.BeginValidity_DATE <= @Ld_LastRun_DATE))
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND a.TypeTrans_CODE = @Lc_TypeTransFp_CODE
                      AND a.Action_CODE = @Lc_ActionC_CODE
                      AND a.Transmitted_DATE <= @Ld_LastRun_DATE)
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE c.Case_IDNO = r.Case_IDNO
                      AND c.MemberMci_IDNO = r.MemberMci_IDNO
                      AND r.Action_CODE = @Lc_ActionC_CODE
                      AND r.Reject_CODE = @Lc_RejectR_CODE
                      AND r.Transmitted_DATE <= @Ld_LastRun_DATE)
    UNION ALL
    --Member new SSN was added in VMSSN after last run date
    /*
    	if anew SSN was added for the member in the SSN table
    */
    SELECT b.Case_IDNO,
           b.MemberMci_IDNO,
           @Lc_TransTypePersonChange_CODE AS TransType_CODE
      FROM MSSN_Y1 a,
           CMEM_Y1 b
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND a.Enumeration_CODE IN (@Lc_EnumerationY_CODE, @Lc_EnumerationP_CODE)
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND b.MemberMci_IDNO = a.MemberMci_IDNO
       AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND NOT EXISTS (SELECT 1
                         FROM MSSN_Y1 c
                        WHERE a.MemberMci_IDNO = c.MemberMci_IDNO
                          AND a.MemberSsn_NUMB = c.MemberSsn_NUMB
                          AND c.BeginValidity_DATE <= @Ld_LastRun_DATE)
    UNION ALL
    --Get the Members if alias name information added/changed after last run date.
    /*
    	if a new alias name was added for the member 
    */
    SELECT c.Case_IDNO,
           c.MemberMci_IDNO,
           @Lc_TransTypePersonChange_CODE AS TransType_CODE
      FROM AKAX_Y1 k,
           CMEM_Y1 c
     WHERE k.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND k.WorkerUpdate_ID <> 'CONVERSION'
       AND k.EndValidity_DATE = @Ld_High_DATE
       AND c.MemberMci_IDNO = k.MemberMci_IDNO
       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND NOT EXISTS (SELECT 1
                         FROM AKAX_Y1 a
                        WHERE a.MemberMci_IDNO = k.MemberMci_IDNO
                          AND UPPER(LTRIM(RTRIM(k.LastAlias_NAME))) + '_' + UPPER(LTRIM(RTRIM(k.FirstAlias_NAME))) = UPPER(LTRIM(RTRIM(a.LastAlias_NAME))) + '_' + UPPER(LTRIM(RTRIM(a.FirstAlias_NAME)))
                          AND a.BeginValidity_DATE <= @Ld_LastRun_DATE)
    UNION ALL
    /*
    	•	FCR batch process will send the FV status change update to FCR immediately. The update will be sent to FCR even if this is the only change for the member between the last batch run and this batch run. 
    	•	The update will be sent when FV status changes from Yes-to-No and also when the status changes from No-to-YES.
    	•	If FV status changes for the CP on the case, the batch process will send the same FV status change update  for all the dependents on the case. 
    	•	If the FV status changes multiple times during the period, the batch process will send the most recent update as the current FV status to the FCR.  
    
    	*** Provided the case and member is already submitted to FCR ***
    */
    SELECT DISTINCT
           C.Case_IDNO,
           C.MemberMci_IDNO,
           @Lc_TransTypePersonChange_CODE AS TransType_CODE
      FROM DMNR_Y1 A,
           CMEM_Y1 B,
           CMEM_Y1 C
     WHERE A.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND A.WorkerUpdate_ID <> 'CONVERSION'
       AND A.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                           FROM DMNR_Y1 X
                                          WHERE X.Case_IDNO = A.Case_IDNO
                                            AND X.MemberMci_IDNO = A.MemberMci_IDNO
                                            AND X.BeginValidity_DATE = A.BeginValidity_DATE
                                            AND X.WorkerUpdate_ID = A.WorkerUpdate_ID
                                            AND X.ActivityMinor_CODE IN ('FVREM', 'FVYES'))
       AND B.Case_IDNO = A.Case_IDNO
       AND B.MemberMci_IDNO = A.MemberMci_IDNO
       AND B.CaseMemberStatus_CODE = 'A'
       AND C.Case_IDNO = A.Case_IDNO
       AND C.CaseMemberStatus_CODE = 'A'
       AND ((B.CaseRelationship_CODE IN ('A', 'P')
             AND C.MemberMci_IDNO = B.MemberMci_IDNO
             AND C.CaseRelationship_CODE IN ('A', 'P'))
             OR (B.CaseRelationship_CODE = 'C'
                 AND C.CaseRelationship_CODE IN ('C', 'D'))
             OR (B.CaseRelationship_CODE = 'D'
                 AND C.CaseRelationship_CODE = 'D'))
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 X
                    WHERE X.Case_IDNO = C.Case_IDNO
                      AND X.MemberMci_IDNO = C.MemberMci_IDNO
                      AND X.Action_CODE IN ('A', 'C')
                      AND X.TypeTrans_CODE IN ('FP')
                      AND X.Transmitted_DATE = (SELECT TOP 1 MAX(Y.Transmitted_DATE)
                                                  FROM FADT_Y1 Y
                                                 WHERE Y.Case_IDNO = X.Case_IDNO
                                                   AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                   AND Y.Transmitted_DATE < @Ld_Run_DATE)
                      AND NOT EXISTS (SELECT 1
                                        FROM FPRJ_Y1 Y
                                       WHERE Y.Case_IDNO = X.Case_IDNO
                                         AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                         AND Y.Action_CODE = X.Action_CODE
                                         AND Y.Reject_CODE = 'R'
                                         AND Y.Transmitted_DATE = X.Transmitted_DATE
                                         AND Y.Received_DATE >= Y.Transmitted_DATE))
    UNION ALL
    --Get the Members from vcmem where member status closed after last run date.
    SELECT a.Case_IDNO,
           a.MemberMci_IDNO,
           @Lc_TransTypePersonDelete_CODE AS TransType_CODE
      FROM CMEM_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusI_CODE
       AND EXISTS (SELECT 1
                     FROM HCMEM_Y1 b
                    WHERE a.Case_IDNO = b.Case_IDNO
                      AND a.MemberMci_IDNO = b.MemberMci_IDNO
                      AND b.CaseMemberStatus_CODE <> a.CaseMemberStatus_CODE
                      AND b.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(c.TransactionEventSeq_NUMB)
                                                          FROM HCMEM_Y1 c
                                                         WHERE b.Case_IDNO = c.Case_IDNO
                                                           AND b.MemberMci_IDNO = c.MemberMci_IDNO
                                                           AND c.BeginValidity_DATE <= @Ld_LastRun_DATE))
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 r
                        WHERE a.Case_IDNO = r.Case_IDNO
                          AND a.MemberMci_IDNO = r.MemberMci_IDNO)
    UNION ALL
    --Get the Members from vcmem where member change was rejected by FCR
    SELECT c.Case_IDNO,
           c.MemberMci_IDNO,
           @Lc_TransTypePersonDelete_CODE AS TransType_CODE
      FROM CMEM_Y1 c
     WHERE c.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND c.WorkerUpdate_ID <> 'CONVERSION'
       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusI_CODE
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND c.CaseMemberStatus_CODE <> a.CaseMemberStatus_CODE)
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE c.Case_IDNO = r.Case_IDNO
                      AND c.MemberMci_IDNO = r.MemberMci_IDNO
                      AND r.Action_CODE = @Lc_ActionC_CODE)
    UNION ALL
    /*
    Get the Members if SSN, dt_birth, name_first, name_last  
    information changes happened after last run date.
    */
    /*
    ?	if member's date of birth or last name or first name was changed in the DEMO_Y1  table 
    	and no reject recordsexist in the FPRJ_Y1  table.
    */
    SELECT c.Case_IDNO,
           c.MemberMci_IDNO,
           @Lc_TransTypePersonDelete_CODE AS TransType_CODE
      FROM DEMO_Y1 d,
           CMEM_Y1 c
     WHERE d.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND d.WorkerUpdate_ID <> 'CONVERSION'
       AND c.MemberMci_IDNO = d.MemberMci_IDNO
       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND EXISTS (SELECT 1
                     FROM HDEMO_Y1 a
                    WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND ((dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.MemberSsn_NUMB) IS NOT NULL
                            AND (d.MemberSsn_NUMB <> a.MemberSsn_NUMB))
                            OR (d.Birth_DATE <> a.Birth_DATE)
                            OR (d.Last_NAME <> a.Last_NAME)
                            OR (d.First_NAME <> a.First_NAME))
                      AND a.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(b.TransactionEventSeq_NUMB)
                                                          FROM HDEMO_Y1 b
                                                         WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                                                           AND b.BeginValidity_DATE <= @Ld_LastRun_DATE))
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 r
                        WHERE c.Case_IDNO = r.Case_IDNO
                          AND c.MemberMci_IDNO = r.MemberMci_IDNO)
    UNION ALL
    /*
    Get the Members if SSN, dt_birth, name_first, name_last  
    information changes happened after last run date and there is reject.
    */
    /*
    ?	if member's date of birth or last name or first name was changed in the DEMO_Y1 table 
    and a reject record exists in the FPRJ_Y1 table for the change transaction 
    */
    SELECT c.Case_IDNO,
           c.MemberMci_IDNO,
           @Lc_TransTypePersonDelete_CODE AS TransType_CODE
      FROM DEMO_Y1 d,
           CMEM_Y1 c
     WHERE d.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND d.WorkerUpdate_ID <> 'CONVERSION'
       AND c.MemberMci_IDNO = d.MemberMci_IDNO
       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND EXISTS (SELECT 1
                     FROM FADT_Y1 a
                    WHERE c.Case_IDNO = a.Case_IDNO
                      AND c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND ((dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.MemberSsn_NUMB) IS NOT NULL
                            AND (d.MemberSsn_NUMB <> a.MemberSsn_NUMB))
                            OR (d.Birth_DATE <> a.Birth_DATE)
                            OR (d.Last_NAME <> a.Last_NAME)
                            OR (d.First_NAME <> a.First_NAME)))
       AND EXISTS (SELECT 1
                     FROM FPRJ_Y1 r
                    WHERE c.Case_IDNO = r.Case_IDNO
                      AND c.MemberMci_IDNO = r.MemberMci_IDNO
                      AND r.Action_CODE <> @Lc_ActionA_CODE)
    UNION ALL
    --Get the members if verified SSN was removed from VMSSN 
    /*
    	if member's verified SSN was removed from the SSN table and no reject recordsexist in the FPRJ_Y1 table
    */
    SELECT b.Case_IDNO,
           b.MemberMci_IDNO,
           @Lc_TransTypePersonDelete_CODE AS TransType_CODE
      FROM MSSN_Y1 a,
           CMEM_Y1 b
     WHERE a.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND a.WorkerUpdate_ID <> 'CONVERSION'
       AND a.Enumeration_CODE NOT IN (@Lc_EnumerationY_CODE, @Lc_EnumerationP_CODE)
       AND a.TypePrimary_CODE = @Lc_TypePrimaryP_CODE
       AND b.MemberMci_IDNO = a.MemberMci_IDNO
       AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
       AND EXISTS (SELECT 1
                     FROM MSSN_Y1 m
                    WHERE m.MemberMci_IDNO = a.MemberMci_IDNO
                      AND m.MemberSsn_NUMB = a.MemberSsn_NUMB
                      AND m.EndValidity_DATE <> @Ld_High_DATE
                      AND m.Enumeration_CODE = @Lc_EnumerationY_CODE
                      AND m.TypePrimary_CODE = @Lc_TypePrimaryP_CODE
                      AND m.BeginValidity_DATE <= @Ld_LastRun_DATE)
       --no reject recordsexist in the FPRJ_Y1 table
       AND NOT EXISTS (SELECT 1
                         FROM FPRJ_Y1 x
                        WHERE x.MemberMci_IDNO = a.MemberMci_IDNO
                          AND x.Reject_CODE = @Lc_RejectR_CODE);
   --cursor to select member merge details
   DECLARE FtrkMmrg_CUR INSENSITIVE CURSOR FOR
    /*
    o	Set transaction type as 'PM' 'Participant Merge from member merge table 
    where validity begin date is between last run date and current run date.
    */
    SELECT m.MemberMciPrimary_IDNO,
           m.MemberMciSecondary_IDNO,
           @Lc_TransTypePersonMerge_CODE AS TransType_CODE,
           c.Case_IDNO
      FROM MMRG_Y1 m,
           CMEM_Y1 c
     WHERE m.BeginValidity_DATE BETWEEN DATEADD(D, 1, @Ld_LastRun_DATE) AND @Ld_Run_DATE
       AND m.WorkerUpdate_ID <> 'CONVERSION'
       AND m.StatusMerge_CODE = @Lc_StatusMergeM_CODE
       AND m.EndValidity_DATE = @Ld_High_DATE
       AND c.MemberMci_IDNO = m.MemberMciPrimary_IDNO
       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE;

   SET @Ls_Sql_TEXT = 'DELETE FROM PFTRK_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM PFTRK_Y1;

   SET @Ls_Sql_TEXT = 'OPEN FtrkCase_CUR';

   OPEN FtrkCase_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FtrkCase_CUR - 1';

   FETCH NEXT FROM FtrkCase_CUR INTO @Lc_FtrkCaseCur_Case_IDNO, @Lc_FtrkCaseCur_TransType_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FtrkCase_CUR';

   --insert case add/change/delete records into pftrk_y1
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Case_QNTY = @Ln_Case_QNTY + 1;
     SET @Ls_Sql_TEXT = 'INSERT CASE ADD/CHANGE/DELETE RECORDS INTO PFTRK_Y1';
     SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_FtrkCaseCur_TransType_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_FtrkCaseCur_Case_IDNO, '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_Zero_TEXT, '');

     INSERT INTO PFTRK_Y1
                 (TransType_CODE,
                  Case_IDNO,
                  MemberMci_IDNO)
          VALUES (@Lc_FtrkCaseCur_TransType_CODE,--TransType_CODE
                  @Lc_FtrkCaseCur_Case_IDNO,--Case_IDNO
                  @Lc_Zero_TEXT --MemberMci_IDNO
     );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT CASE ADD/CHANGE/DELETE RECORDS INTO PFTRK_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FtrkCase_CUR - 2';

     FETCH NEXT FROM FtrkCase_CUR INTO @Lc_FtrkCaseCur_Case_IDNO, @Lc_FtrkCaseCur_TransType_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FtrkCase_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FtrkCase_CUR';

     CLOSE FtrkCase_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FtrkCase_CUR';

     DEALLOCATE FtrkCase_CUR;
    END

   SET @Ls_Sql_TEXT = 'OPEN FtrkMember_CUR';

   OPEN FtrkMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FtrkMember_CUR - 1';

   FETCH NEXT FROM FtrkMember_CUR INTO @Lc_FtrkMemberCur_Case_IDNO, @Lc_FtrkMemberCur_MemberMci_IDNO, @Lc_FtrkMemberCur_TransType_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FtrkMember_CUR';

   --insert member add/change/delete records into pftrk_y1
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Member_QNTY = @Ln_Member_QNTY + 1;
     SET @Ls_Sql_TEXT = 'INSERT MEMBER ADD/CHANGE/DELETE RECORDS INTO PFTRK_Y1';
     SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_FtrkMemberCur_TransType_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_FtrkMemberCur_Case_IDNO, '') + ', MemberMci_IDNO = ' + ISNULL(@Lc_FtrkMemberCur_MemberMci_IDNO, '');

     INSERT INTO PFTRK_Y1
                 (TransType_CODE,
                  Case_IDNO,
                  MemberMci_IDNO)
          VALUES (@Lc_FtrkMemberCur_TransType_CODE,--TransType_CODE
                  @Lc_FtrkMemberCur_Case_IDNO,--Case_IDNO
                  @Lc_FtrkMemberCur_MemberMci_IDNO --MemberMci_IDNO
     );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT MEMBER ADD/CHANGE/DELETE RECORDS INTO PFTRK_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FtrkMember_CUR - 2';

     FETCH NEXT FROM FtrkMember_CUR INTO @Lc_FtrkMemberCur_Case_IDNO, @Lc_FtrkMemberCur_MemberMci_IDNO, @Lc_FtrkMemberCur_TransType_CODE;

     SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FtrkMember_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FtrkMember_CUR';

     CLOSE FtrkMember_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FtrkMember_CUR';

     DEALLOCATE FtrkMember_CUR;
    END

   SET @Ls_Sql_TEXT = 'OPEN FtrkMmrg_CUR';

   OPEN FtrkMmrg_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FtrkMmrg_CUR - 1';

   FETCH NEXT FROM FtrkMmrg_CUR INTO @Ln_FtrkMmrgCur_MemberMciPrimary_IDNO, @Ln_FtrkMmrgCur_MemberMciSecondary_IDNO, @Lc_FtrkMmrgCur_TransType_CODE, @Lc_FtrkMmrgCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FtrkMmrg_CUR';

   --insert member merge records into pftrk_y1
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Mmrg_QNTY = @Ln_Mmrg_QNTY + 1;
     SET @Ls_Sql_TEXT = 'INSERT MEMBER MERGE RECORDS INTO PFTRK_Y1';
     SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_FtrkMmrgCur_TransType_CODE, '') + ', Case_IDNO = ' + ISNULL(@Lc_FtrkMmrgCur_Case_IDNO, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FtrkMmrgCur_MemberMciSecondary_IDNO AS VARCHAR), '');

     INSERT INTO PFTRK_Y1
                 (TransType_CODE,
                  Case_IDNO,
                  MemberMci_IDNO)
          VALUES (@Lc_FtrkMmrgCur_TransType_CODE,--TransType_CODE
                  @Lc_FtrkMmrgCur_Case_IDNO,--Case_IDNO
                  @Ln_FtrkMmrgCur_MemberMciSecondary_IDNO --MemberMci_IDNO
     );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT MEMBER MERGE RECORDS INTO PFTRK_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FtrkMmrg_CUR - 2';

     FETCH NEXT FROM FtrkMmrg_CUR INTO @Ln_FtrkMmrgCur_MemberMciPrimary_IDNO, @Ln_FtrkMmrgCur_MemberMciSecondary_IDNO, @Lc_FtrkMmrgCur_TransType_CODE, @Lc_FtrkMmrgCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FtrkMmrg_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FtrkMmrg_CUR';

     CLOSE FtrkMmrg_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FtrkMmrg_CUR';

     DEALLOCATE FtrkMmrg_CUR;
    END

   --Delete Case Add/Change Transactions if the case is closed. - 
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE CASE ADD/CHANGE TRANSACTIONS IF THE CASE IS CLOSED';
   SET @Ls_SqlData_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseC_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE IN (@Lc_TransTypeCaseAdd_CODE, @Lc_TransTypeCaseChange_CODE)
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND b.StatusCase_CODE = @Lc_StatusCaseC_CODE);

   --Delete Case Delete Transactions if the case is not closed. - 
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE CASE DELETE TRANSACTIONS IF THE CASE IS NOT CLOSED';
   SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_TransTypeCaseDelete_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE = @Lc_TransTypeCaseDelete_CODE
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND b.StatusCase_CODE <> @Lc_StatusCaseC_CODE);

  /*
  Delete Case Change Transactions if there is a Case Add transaction in pftrk - 
  */
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE CASE CHANGE TRANSACTIONS IF THERE IS A CASE ADD TRANSACTION IN PFTRK';
   SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_TransTypeCaseChange_CODE, '') + ', TransType_CODE = ' + ISNULL(@Lc_TransTypeCaseAdd_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE = @Lc_TransTypeCaseChange_CODE
      AND EXISTS (SELECT 1
                    FROM PFTRK_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND b.TransType_CODE = @Lc_TransTypeCaseAdd_CODE);

  /* 
  Delete Person Add/Change transactions if the member is not active or there is no open case. - 
  */
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE PERSON ADD/CHANGE TRANSACTIONS IF THE MEMBER IS NOT ACTIVE OR THERE IS NO OPEN CASE';
   SET @Ls_SqlData_TEXT = 'CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusA_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseO_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE IN (@Lc_TransTypePersonAdd_CODE, @Lc_TransTypePersonChange_CODE)
      AND (NOT EXISTS (SELECT 1
                         FROM CMEM_Y1 b
                        WHERE a.Case_IDNO = b.Case_IDNO
                          AND a.MemberMci_IDNO = b.MemberMci_IDNO
                          AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
            OR NOT EXISTS (SELECT 1
                             FROM CASE_Y1 b
                            WHERE a.Case_IDNO = b.Case_IDNO
                              AND b.StatusCase_CODE = @Lc_StatusCaseO_CODE));

  /*  
  Delete Person Change/Delete/Merge transactions if there is Person Add transaction and member is active - 
  */
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE PERSON CHANGE/DELETE/MERGE TRANSACTIONS IF THERE IS PERSON ADD TRANSACTION AND MEMBER IS ACTIVE';
   SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_TransTypePersonAdd_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusA_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE IN (@Lc_TransTypePersonChange_CODE, @Lc_TransTypePersonDelete_CODE, @Lc_TransTypePersonMerge_CODE)
      AND EXISTS (SELECT 1
                    FROM PFTRK_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND b.TransType_CODE = @Lc_TransTypePersonAdd_CODE)
      AND EXISTS (SELECT 1
                    FROM CMEM_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE);

  /*  
  Delete Person Add/Change/Delete/Merge transactions if there is a Case Add transaction. - 
  */
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   Delete Person Add/Change/Delete/Merge transactions if there is a Case Add transaction. - 
   */
   SET @Ls_Sql_TEXT = 'DELETE PERSON ADD/CHANGE/DELETE/MERGE TRANSACTIONS IF THERE IS A CASE ADD TRANSACTION';
   SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_TransTypeCaseAdd_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE IN (@Lc_TransTypePersonAdd_CODE, @Lc_TransTypePersonChange_CODE, @Lc_TransTypePersonDelete_CODE, @Lc_TransTypePersonMerge_CODE)
      AND EXISTS (SELECT 1
                    FROM PFTRK_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND ISNULL(b.MemberMci_IDNO, 0) = 0
                     AND b.TransType_CODE = @Lc_TransTypeCaseAdd_CODE);

   --Delete the duplicate records - 
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE THE DUPLICATE RECORDS FROM PFTRK_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE B
     FROM (SELECT ROW_NUMBER() OVER(PARTITION BY A.TransType_CODE, A.Case_IDNO, A.MemberMci_IDNO ORDER BY (SELECT 1)) AS Row_NUMB,
                  A.TransType_CODE,
                  A.Case_IDNO,
                  A.MemberMci_IDNO
             FROM PFTRK_Y1 A) B
    WHERE B.Row_NUMB > 1;

   --Delete the member change transactions if member delete transaction exists - 
   /*
   '	Validate records fromthe PFTRK_Y1 table created in the first process
   */
   SET @Ls_Sql_TEXT = 'DELETE THE MEMBER CHANGE TRANSACTIONS IF MEMBER DELETE TRANSACTION EXISTS';
   SET @Ls_SqlData_TEXT = 'TransType_CODE = ' + ISNULL(@Lc_TransTypePersonChange_CODE, '') + ', TransType_CODE = ' + ISNULL(@Lc_TransTypePersonDelete_CODE, '');

   DELETE PFTRK_Y1
     FROM PFTRK_Y1 a
    WHERE a.TransType_CODE = @Lc_TransTypePersonChange_CODE
      AND EXISTS (SELECT 1
                    FROM PFTRK_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND b.TransType_CODE = @Lc_TransTypePersonDelete_CODE);

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO PROCESS FROM PFTRK_Y1';
   SET @Ls_SqlData_TEXT = '';

   SELECT @Ln_RecordCount_QNTY = COUNT(1)
     FROM PFTRK_Y1 A;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_RecordCount_QNTY;

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
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_SqlData_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_IDENTIFY_TRANSACTIONS';

   COMMIT TRANSACTION TXN_IDENTIFY_TRANSACTIONS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_IDENTIFY_TRANSACTIONS;
    END;

   IF CURSOR_STATUS('LOCAL', 'FtrkCase_CUR') IN (0, 1)
    BEGIN
     CLOSE FtrkCase_CUR;

     DEALLOCATE FtrkCase_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'FtrkMember_CUR') IN (0, 1)
    BEGIN
     CLOSE FtrkMember_CUR;

     DEALLOCATE FtrkMember_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'FtrkMmrg_CUR') IN (0, 1)
    BEGIN
     CLOSE FtrkMmrg_CUR;

     DEALLOCATE FtrkMmrg_CUR;
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
