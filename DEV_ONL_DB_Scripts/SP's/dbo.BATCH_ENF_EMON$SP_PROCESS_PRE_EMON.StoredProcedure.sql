/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_PRE_EMON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		:	BATCH_ENF_EMON$SP_PROCESS_PRE_EMON
Programmer Name		:	IMP Team
Description			:	This PROCEDURE loads ALL the records TO be processed BY EMON INTO PEMON_Y1. Also it inserts the number OF records TO be processed BY 
						each thread in JRTL_Y1.
Frequency			:
Developed On		:	01/05/2012
Called By			:	None
Called On        	:   BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_UPDATE_PARM_DATE and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_PRE_EMON]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT						CHAR(1)			= ' ',
          @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE					CHAR(1)			= 'F',
          @Lc_RespondInitResponding_CODE		CHAR(1)			= 'R',
          @Lc_StatusCaseOpen_CODE				CHAR(1)			= 'O',
          @Lc_RespManSysSystem_CODE				CHAR(1)			= 'S',
          @Lc_RespManSysBoth_CODE				CHAR(1)			= 'B',
          @Lc_No_INDC							CHAR(1)			= 'N',
          @Lc_Yes_INDC							CHAR(1)			= 'Y',
          @Lc_StatusAbnormalend_CODE			CHAR(1)			= 'A',
          @Lc_FreqWeekly_CODE					CHAR(1)			= 'W',
          @Lc_FreqBiWeekly_CODE					CHAR(1)			= 'B',
          @Lc_FreqMonthly_CODE					CHAR(1)			= 'M',
          @Lc_FreqQuarterly_CODE				CHAR(1)			= 'Q',
          @Lc_FreqAnnualy_CODE					CHAR(1)			= 'A',
          @Lc_StatusReceiptO_CODE				CHAR(1)			= 'O',
          @Lc_StatusReceiptR_CODE				CHAR(1)			= 'R',
          @Lc_SourceReceiptLo_CODE				CHAR(2)			= 'LO',
          -- 13574 ENF-02 was issued incorrectly - Receipt Source included to consider payements - Start
          @Lc_ReceiptSrcEw_CODE					CHAR(2)			= 'EW',
          @Lc_ReceiptSrcQr_CODE					CHAR(2)			= 'QR',
          @Lc_ReceiptSrcUc_CODE					CHAR(2)			= 'UC',
          @Lc_ReceiptSrcWc_CODE					CHAR(2)			= 'WC',
          -- 13574 ENF-02 was issued incorrectly - Receipt Source included to consider payements - End
          @Lc_SourceReceiptAc_CODE				CHAR(2)			= 'AC',
          @Lc_ComplianceTypePa_CODE				CHAR(2)			= 'PA',
          @Lc_PolicyHolderRelationshipSf_CODE	CHAR(2)			= 'SF',
          @Lc_PolicyHolderRelationshipOt_CODE	CHAR(2)			= 'OT',
          @Lc_TableEmon_ID						CHAR(4)			= 'EMON',
          @Lc_TableSubSkip_ID					CHAR(4)			= 'SKIP',
          @Lc_TableConv_ID						CHAR(4)			= 'CONV',
          @Lc_StatusStart_CODE					CHAR(4)			= 'STRT',
          @Lc_ActivityMajorCase_CODE			CHAR(4)			= 'CASE',
          @Lc_ActivityMajorObra_CODE			CHAR(4)			= 'OBRA',
          @Lc_ActivityMajorImiw_CODE			CHAR(4)			= 'IMIW',
          @Lc_ActivityMajorCclo_CODE			CHAR(4)			= 'CCLO',
          @Lc_ActivityMajorLint_CODE			CHAR(4)			= 'LINT',
          @Lc_ActivityMajorNmsn_CODE			CHAR(4)			= 'NMSN',
          @Lc_ActivityMinorMpcoa_CODE			CHAR(5)			= 'MPCOA',
          @Lc_ActivityMinorMonls_CODE			CHAR(5)			= 'MONLS',
          @Lc_ActivityMinorAcnor_CODE			CHAR(5)			= 'ACNOR',
          @Lc_ActivityMinorFcpro_CODE			CHAR(5)			= 'FCPRO',
          @Lc_ActivityMinorMorlp_CODE			CHAR(5)			= 'MORLP',
          @Lc_ActivityMinorMcmoi_CODE			CHAR(5)			= 'MCMOI',
          @Lc_Job_ID							CHAR(7)			= 'DEB0664',
          @Lc_JobEmon_ID						CHAR(7)			= 'DEB0670',
          @Lc_WorkerUpdateConversion_ID			CHAR(15)		= 'CONVERSION',
          @Lc_Successful_TEXT					CHAR(20)		= 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT				CHAR(20)		= 'PARM DATE PROBLEM',
          @Lc_BatchRunUser_TEXT					CHAR(30)		= 'BATCH',
          @Ls_Process_NAME						VARCHAR(100)	= 'BATCH_ENF_EMON',
          @Ls_Routine_TEXT						VARCHAR(4000)	= 'SP_PROCESS_PRE_EMON',
          @Ld_High_DATE							DATE			= '12/31/9999',
          @Ld_Low_DATE							DATE			= '01/01/0001';
          
  DECLARE @Ln_CommitFreqParm_QNTY				NUMERIC(15),
          @Ln_ExceptionThresholdParm_QNTY		NUMERIC(15)		= 0,
          @Ln_TotalCount_NUMB					NUMERIC(15)		= 0,
          @Ln_ThreadCount_NUMB					NUMERIC(15)		= 0,
          @Ln_EndThread_NUMB					NUMERIC(15)		= 0,
          @Ln_BeginThread_NUMB					NUMERIC(15)		= 0,
          @Ln_LoopCount_NUMB					NUMERIC(15)		= 0,
          @Ln_ThreadAvgCount_NUMB				NUMERIC(15)		= 0,
          @Ln_ThreadNextCount_NUMB				NUMERIC(15)		= 0,
          @Ln_Cursor_QNTY						NUMERIC(15)		= 0,
          @Ln_Error_NUMB						NUMERIC(15),
          @Ln_ErrorLine_NUMB					NUMERIC(15),
          @Lc_Msg_CODE							CHAR(5),
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_Sqldata_TEXT						VARCHAR(800),
          @Ls_ListKeyEmon_TEXT					VARCHAR(1000),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_Run_DATE							DATE,
          @Ld_LastRun_DATE						DATE,
          @Ld_Start_DATE						DATETIME2;
  

  BEGIN TRY
   BEGIN TRANSACTION Main_Transaction;

   SET @Ls_Sql_TEXT = ' BATCH_ENF_EMON$SP_PROCESS_PRE_EMON : GET BATCH START TIME';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_PRE_EMON : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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

   SET @Ls_SQL_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SQLData_TEXT = ' Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', LastRun_DATE = ' + ISNULL (CAST (@Ld_LastRun_DATE AS VARCHAR (20)), '');

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_SQL_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT NUMBER OF THREAD FROM PARM_Y1';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobEmon_ID;

   SELECT @Ln_ThreadCount_NUMB = p.Thread_NUMB
     FROM PARM_Y1 p
    WHERE p.Job_ID = @Lc_JobEmon_ID
      AND p.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_ThreadCount_NUMB = 0
       OR @Ln_ThreadCount_NUMB = NULL
    BEGIN
     SET @Ln_ThreadCount_NUMB = 1;
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM  JRTL_Y1';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobEmon_ID;

   DELETE FROM JRTL_Y1
    WHERE Job_ID = @Lc_JobEmon_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'DELETE FROM PEMON_Y1';
   SET @Ls_Sqldata_TEXT =@Lc_Space_TEXT;

   DELETE FROM PEMON_Y1;

   SET @Ls_Sql_TEXT = 'INSERT FOR PEMON_Y1';
   SET @Ls_Sqldata_TEXT = ' ActivityMajor_CODE = ' + @Lc_ActivityMajorImiw_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorMpcoa_CODE;

   INSERT INTO PEMON_Y1
               (RecordRowNumber_NUMB,
                Case_IDNO,
                OrderSeq_NUMB,
                OthpSource_IDNO,
                MemberMci_IDNO,
                ActivityMajor_CODE,
                ActivityMinor_CODE,
                MajorIntSEQ_NUMB,
                MinorIntSeq_NUMB,
                Forum_IDNO,
                Entered_DATE,
                TransactionEventSeq_NUMB,
                Reference_ID,
                Due_DATE,
                Topic_IDNO,
                Schedule_NUMB,
                Process_INDC,
                NcpMci_IDNO,
                TransactionEventDmnrSeq_NUMB)
   SELECT 
	   ROW_NUMBER() OVER(ORDER BY x.NcpMci_IDNO, x.Case_IDNO, x.ActivityMajor_CODE) AS RecordRowNumber_NUMB,
	   x.Case_IDNO,
	   x.OrderSeq_NUMB,
	   x.OthpSource_IDNO,
	   x.MemberMci_IDNO,
	   x.ActivityMajor_CODE,
	   x.ActivityMinor_CODE,
	   x.MajorIntSEQ_NUMB,
	   x.MinorIntSeq_NUMB,
	   x.Forum_IDNO,
	   x.Entered_DATE,
	   x.TransactionEventSeq_NUMB,
	   x.Reference_ID,
	   x.Due_DATE,
	   x.Topic_IDNO,
	   x.Schedule_NUMB,
	   @Lc_No_INDC AS Process_INDC,
	   x.NcpMci_IDNO,
	   x.dmnr_seq_txn_event
     FROM (SELECT x.Case_IDNO,
                  x.OrderSeq_NUMB,
                  x.OthpSource_IDNO,
                  x.MemberMci_IDNO,
                  x.ActivityMajor_CODE,
                  x.ActivityMinor_CODE,
                  x.MajorIntSEQ_NUMB,
                  x.MinorIntSeq_NUMB,
                  x.Forum_IDNO,
                  x.Entered_DATE,
                  x.TransactionEventSeq_NUMB,
                  x.Reference_ID,
                  x.Due_DATE,
                  x.Topic_IDNO,
                  x.Schedule_NUMB,
                  x.NcpMci_IDNO,
                  x.dmnr_seq_txn_event
             FROM (SELECT *
                     FROM (SELECT j.Case_IDNO,
                                  j.OrderSeq_NUMB,
                                  j.OthpSource_IDNO,
                                  j.MemberMci_IDNO,
                                  j.ActivityMajor_CODE,
                                  n.ActivityMinor_CODE,
                                  j.MajorIntSEQ_NUMB,
                                  n.MinorIntSeq_NUMB,
                                  j.Forum_IDNO,
                                  n.Entered_DATE,
                                  j.TransactionEventSeq_NUMB,
                                  j.Reference_ID,
                                  n.Due_DATE,
                                  n.Topic_IDNO,
                                  n.Schedule_NUMB,
                                  j.MemberMci_IDNO AS NcpMci_IDNO,
                                  n.TransactionEventSeq_NUMB AS dmnr_seq_txn_event,
                                  C.RespondInit_CODE,
                                  mso_amnt
                             FROM DMJR_Y1 j,
                                  ENSD_Y1 e,
                                  CASE_Y1 c,
                                  DMNR_Y1 n,
                                  (SELECT DISTINCT
                                          a.ActivityMajor_CODE,
                                          a.ActivityMinor_CODE
                                     FROM ANXT_Y1 a
                                    WHERE a.RespManSys_CODE IN (@Lc_RespManSysSystem_CODE, @Lc_RespManSysBoth_CODE)
                                      AND a.EndValidity_DATE = @Ld_High_DATE) a
                            WHERE j.ActivityMajor_CODE != @Lc_ActivityMajorCase_CODE
                              AND j.Status_CODE = @Lc_StatusStart_CODE
                              AND j.Status_DATE = @Ld_High_DATE
                              AND J.Case_IDNO = e.Case_IDNO
                              AND J.Case_IDNO = C.Case_IDNO
                              AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                              AND N.ActivityMajor_CODE = A.ActivityMajor_CODE
                              AND N.ActivityMinor_CODE = A.ActivityMinor_CODE
                              AND n.Status_CODE = @Lc_StatusStart_CODE
                              AND n.Status_DATE = @Ld_High_DATE
                              AND j.Case_IDNO = n.Case_IDNO
                              AND j.OrderSeq_NUMB = n.OrderSeq_NUMB
                              AND j.MajorIntSEQ_NUMB = n.MajorIntSEQ_NUMB
                              AND (n.WorkerUpdate_ID != @Lc_WorkerUpdateConversion_ID
                                    OR NOT EXISTS (SELECT r.Value_CODE
                                                     FROM REFM_Y1 r
                                                    WHERE r.Table_ID = @Lc_TableEmon_ID
                                                      AND r.TableSub_ID = @Lc_TableConv_ID
                                                      AND r.Value_CODE = j.ActivityMajor_CODE))
                              AND j.ActivityMajor_CODE NOT IN(SELECT r.Value_CODE
                                                                FROM REFM_Y1 r
                                                               WHERE r.Table_ID = @Lc_TableEmon_ID
                                                                 AND r.TableSub_ID = @Lc_TableSubSkip_ID)) J
                    WHERE (-----------1
                          (J.Due_DATE >= @Ld_Run_DATE
                           AND J.ActivityMajor_CODE IN (@Lc_ActivityMajorObra_CODE)
                           AND J.ActivityMinor_CODE IN (@Lc_ActivityMinorMonls_CODE))
                           -----------2
                           OR (J.ActivityMajor_CODE IN(@Lc_ActivityMajorCclo_CODE)
                               AND J.Due_DATE <= @Ld_Run_DATE
                               AND ISNULL((SELECT d.Due_DATE
                                             FROM DMNR_Y1 d
                                            WHERE d.Case_IDNO = j.Case_IDNO
                                              AND d.MajorIntSEQ_NUMB = j.MajorIntSEQ_NUMB
                                              AND d.ActivityMinor_CODE = @Lc_ActivityMinorAcnor_CODE), J.Due_DATE) <= @Ld_Run_DATE)
                           -----------3
                           OR (J.ActivityMajor_CODE IN (@Lc_ActivityMajorCclo_CODE)
                               AND J.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorFcpro_CODE)
                               AND J.RespondInit_CODE = @Lc_RespondInitResponding_CODE
                               AND dbo.BATCH_CM_CASE_CLOSURE_ELIG$SF_FIND_INTERSTATE_REASON_CC (J.Case_IDNO, @Ld_Run_DATE, @Ld_Run_DATE) != @Lc_Space_TEXT)
                           -----------4
                           OR (J.Due_DATE <= @Ld_Run_DATE
                               AND J.ActivityMajor_CODE NOT IN (@Lc_ActivityMajorCclo_CODE)
                               AND (------4.1
                                   J.ActivityMinor_CODE NOT IN (@Lc_ActivityMinorMorlp_CODE, @Lc_ActivityMinorMcmoi_CODE)
                                    ------4.2
                                    OR (J.ActivityMajor_CODE = @Lc_ActivityMajorLint_CODE
                                        AND J.ActivityMinor_CODE = @Lc_ActivityMinorMorlp_CODE
                                        AND EXISTS (SELECT 1
                                                      FROM RCTH_Y1 o
                                                     WHERE (o.PayorMCI_IDNO = j.MemberMci_IDNO
                                                             OR o.Case_IDNO = j.Case_IDNO)
                                                       AND o.Receipt_DATE >= j.Entered_DATE
                                                       AND o.EndValidity_DATE = @Ld_High_DATE
                                                       AND o.SourceReceipt_CODE = @Lc_SourceReceiptLo_CODE
                                                       AND NOT EXISTS (SELECT 1
                                                                         FROM ELRP_Y1 i
                                                                        WHERE o.Batch_DATE = i.BatchOrig_DATE
                                                                          AND o.SourceBatch_CODE = i.SourceBatchOrig_CODE
                                                                          AND o.Batch_NUMB = i.BatchOrig_NUMB
                                                                          AND o.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB)))
                                    ------4.3
                                    OR (J.ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
                                        AND J.ActivityMinor_CODE = @Lc_ActivityMinorMcmoi_CODE
                                        AND (------4.3.1
                                            EXISTS (SELECT COUNT(1)
                                                      FROM SORD_Y1
                                                     WHERE Case_IDNO = j.Case_IDNO
                                                       AND OrderSeq_NUMB = j.OrderSeq_NUMB
                                                       AND EndValidity_DATE = @Ld_High_DATE
                                                       AND @Ld_Run_DATE BETWEEN OrderEffective_DATE AND OrderEnd_DATE
                                                       AND BeginValidity_DATE >= j.Entered_DATE
                                                       AND InsOrdered_CODE = @Lc_No_INDC)
                                             ------4.3.2 
                                             OR EXISTS (SELECT 1
                                                          FROM (SELECT MAX(CASE
                                                                            WHEN BeginValidity_DATE >= Entered_DATE
                                                                             THEN ObligationSeq_NUMB
                                                                            ELSE 0
                                                                           END)greatThanEnteredDateSeq_NUMB,
                                                                       MAX(CASE
                                                                            WHEN BeginValidity_DATE < Entered_DATE
                                                                             THEN ObligationSeq_NUMB
                                                                            ELSE 0
                                                                           END) LessThanEnteredDateSeq_NUMB
                                                                  FROM (SELECT o.BeginValidity_DATE,
                                                                               j.Entered_DATE,
                                                                               ObligationSeq_NUMB
                                                                          FROM OBLE_Y1 o
                                                                         WHERE o.Case_IDNO = j.Case_IDNO
                                                                           AND o.OrderSeq_NUMB = j.OrderSeq_NUMB
                                                                           AND o.EndValidity_DATE = @Ld_High_DATE
                                                                           AND @Ld_Run_DATE BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE) a) a
                                                         WHERE greatThanEnteredDateSeq_NUMB > LessThanEnteredDateSeq_NUMB)
                                             ------4.3.3
                                             OR EXISTS (SELECT 1
                                                          FROM EHIS_Y1
                                                         WHERE MemberMci_IDNO = j.Reference_ID
                                                           AND OthpPartyEmpl_IDNO = j.OthpSource_IDNO
                                                           AND Status_CODE = @Lc_Yes_INDC
                                                           AND (
                                                               ------4.3.3.1
                                                               @Ld_Run_DATE > EndEmployment_DATE
                                                                ------4.3.3.2
                                                                OR (@Ld_Run_DATE BETWEEN BeginEmployment_DATE AND EndEmployment_DATE
                                                                    AND (NOT EXISTS (SELECT 1
                                                                                       FROM MINS_Y1 m
                                                                                      WHERE m.MemberMci_IDNO = j.Reference_ID
                                                                                        AND m.OthpEmployer_IDNO = j.OthpSource_IDNO
                                                                                        AND m.EndValidity_DATE = @Ld_High_DATE
                                                                                        AND @Ld_Run_DATE BETWEEN m.Begin_DATE AND m.End_DATE
                                                                                        AND m.PolicyHolderRelationship_CODE IN (@Lc_PolicyHolderRelationshipSf_CODE, @Lc_PolicyHolderRelationshipOt_CODE)
                                                                                        AND m.EmployerPaid_INDC = @Lc_Yes_INDC)))))
                                             ------4.3.4
                                             OR EXISTS (SELECT 1
                                                          FROM MINS_Y1 i
                                                         WHERE i.MemberMci_IDNO = j.Reference_ID
                                                           AND i.OthpEmployer_IDNO = j.OthpSource_IDNO
                                                           AND @Ld_Run_DATE NOT BETWEEN i.Begin_DATE AND i.End_DATE
                                                           AND i.TransactionEventSeq_NUMB > J.TransactionEventSeq_NUMB)))))
                           --------5
                           OR (J.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
                               AND J.ActivityMinor_CODE IN (@Lc_ActivityMinorMpcoa_CODE)
                               AND J.Due_DATE >= @Ld_Run_DATE
                               AND (
                                   --------5.1
                                   -- Change in obligation
                                   EXISTS (SELECT 1
                                             FROM OBLE_Y1 a
                                            WHERE a.CASE_IDNO = j.Case_IDNO
                                              AND a.OrderSeq_NUMB = j.OrderSeq_NUMB
                                              AND a.BeginValidity_DATE >= J.Entered_DATE
                                              AND a.EndValidity_DATE = @Ld_High_DATE)
                                    --  -- CHANGE IN COMPLIANCE
                                    --------5.2
                                    OR ((SELECT ISNULL(SUM(CASE
                                                            WHEN Freq_CODE = @Lc_FreqWeekly_CODE
                                                             THEN (Compliance_AMNT * 52) / 12
                                                            WHEN Freq_CODE = @Lc_FreqBiWeekly_CODE
                                                             THEN (Compliance_AMNT * 26) / 12
                                                            WHEN Freq_CODE = @Lc_FreqMonthly_CODE
                                                             THEN (Compliance_AMNT * 12) / 12
                                                            WHEN Freq_CODE = @Lc_FreqQuarterly_CODE
                                                             THEN (Compliance_AMNT * 4) / 12
                                                            WHEN Freq_CODE = @Lc_FreqAnnualy_CODE
                                                             THEN (Compliance_AMNT * 1) / 12
                                                            ELSE Compliance_AMNT
                                                           END), Mso_AMNT)
                                           FROM COMP_Y1
                                          WHERE Case_IDNO = j.Case_IDNO
                                            AND OrderSeq_NUMB = j.OrderSeq_NUMB
                                            AND EndValidity_DATE = @Ld_High_DATE
                                            AND @Ld_Run_DATE BETWEEN Effective_DATE AND End_DATE
                                            AND BeginValidity_DATE BETWEEN J.Entered_DATE AND J.Due_DATE
                                            AND TransactionEventSeq_NUMB > J.TransactionEventSeq_NUMB
                                            AND ComplianceType_CODE = @Lc_ComplianceTypePa_CODE
                                            AND ComplianceStatus_CODE = @Lc_SourceReceiptAc_CODE) != Mso_AMNT)
                                    --------5.3
                                    ----EHIS ENDDATED
                                    OR EXISTS (SELECT 1
                                                 FROM EHIS_Y1 eh
                                                WHERE MemberMci_IDNO = j.Reference_ID
                                                  AND eh.OthpPartyEmpl_IDNO = j.OthpSource_IDNO
                                                  AND @Ld_Run_DATE > eh.EndEmployment_DATE
                                                  AND eh.Status_CODE = @Lc_Yes_INDC)
                                    --------5.4
                                    OR EXISTS (SELECT 1
                                                 FROM RCTH_Y1 r
                                                WHERE (r.PayorMCI_IDNO = j.MemberMci_IDNO
                                                        OR r.Case_IDNO = j.Case_IDNO)
                                                  -- 13574 ENF-02 was issued incorrectly - Receipt Source included to consider payements - Start
												  AND r.SourceReceipt_CODE IN (@Lc_ReceiptSrcEw_CODE, @Lc_ReceiptSrcQr_CODE, @Lc_ReceiptSrcUc_CODE, @Lc_ReceiptSrcWc_CODE)
												  AND r.Receipt_DATE BETWEEN j.Entered_DATE AND @Ld_Run_DATE
                                                  AND r.EndValidity_DATE = @Ld_High_DATE
                                                  -- 13574 ENF-02 was issued incorrectly - Receipt Source included to consider payements - End
                                                  AND r.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptR_CODE, @Lc_StatusReceiptO_CODE)
                                                  AND r.Receipt_AMNT > 0
                                                  AND NOT EXISTS (SELECT 1
                                                                    FROM ELRP_Y1 i
                                                                   WHERE r.Batch_DATE = i.BatchOrig_DATE
                                                                     AND r.SourceBatch_CODE = i.SourceBatchOrig_CODE
                                                                     AND r.Batch_NUMB = i.BatchOrig_NUMB
                                                                     AND r.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB))
									OR EXISTS (SELECT 1
                                                    FROM ENSD_Y1 
                                                WHERE Case_IDNO = j.Case_IDNO 
                                                    AND Mso_AMNT = 0 AND FullArrears_AMNT <= 0)                            
                                  )

                              ))) x) x;

   SET @Ls_Sql_TEXT = 'SELECTING COUNT FROM PEMON_Y1';
   SET @Ls_Sqldata_TEXT = ' Total COUNT = ' + ISNULL(CAST(@Ln_TotalCount_NUMB AS VARCHAR(15)), '');

   SELECT @Ln_TotalCount_NUMB = COUNT(1)
     FROM PEMON_Y1 p;

   SET @Ls_Sql_TEXT = 'DIVIDING THE TOTAL RECORDS WITH THE NUMBER OF THREADS';
   SET @Ls_Sqldata_TEXT = ' Total COUNT = ' + ISNULL(CAST(@Ln_TotalCount_NUMB AS VARCHAR(15)), '') + ', Total threads = ' + ISNULL (CAST(@Ln_ThreadCount_NUMB AS VARCHAR(15)), '');
   SET @Ln_ThreadAvgCount_NUMB = (@Ln_TotalCount_NUMB / @Ln_ThreadCount_NUMB);
   SET @Ln_ThreadNextCount_NUMB = @Ln_ThreadAvgCount_NUMB;
   SET @Ls_ListKeyEmon_TEXT = ' TOTAL THREAD COUNT = ' + ISNULL(CAST(@Ln_ThreadCount_NUMB AS VARCHAR(15)), '') + ', TOTAL RECORD COUNT = ' + ISNULL(CAST(@Ln_TotalCount_NUMB AS VARCHAR(15)), '') + ', AVG THREAD COUNT =' + ISNULL(CAST(@Ln_ThreadAvgCount_NUMB AS VARCHAR(15)), '');

   IF @Ln_ThreadCount_NUMB = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO JRTL_Y1';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_JobEmon_ID + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '') + ', TotalCount_NUMB = ' + ISNULL(CAST(@Ln_TotalCount_NUMB AS VARCHAR(15)), '');
     SET @Ls_ListKeyEmon_TEXT = @Ls_ListKeyEmon_TEXT + ' THREAD NUMBER ' + '1' + 'STARTING THREAD VALUE ' + '0' + 'ENDING THREAD VALUE ' + ISNULL(CAST(@Ln_TotalCount_NUMB AS VARCHAR(15)), '');

     INSERT INTO JRTL_Y1
                 (Job_ID,
                  Run_DATE,
                  Thread_NUMB,
                  RecStart_NUMB,
                  RecEnd_NUMB,
                  RestartKey_TEXT,
                  RecRestart_NUMB,
                  ThreadProcess_CODE)
          VALUES (@Lc_JobEmon_ID,--Job_ID
                  @Ld_Run_DATE,--Run_DATE
                  1,--Thread_NUMB
                  1,--RecStart_NUMB
                  @Ln_TotalCount_NUMB,--RecEnd_NUMB
                  ' ',--RestartKey_TEXT
                  1,--RecRestart_NUMB
                  @Lc_No_INDC --ThreadProcess_CODE
     );
    END
   ELSE
    BEGIN
     WHILE @Ln_LoopCount_NUMB != @Ln_ThreadCount_NUMB 
      BEGIN
       SET @Ln_LoopCount_NUMB = @Ln_LoopCount_NUMB + 1;
       SET @Ls_Sql_TEXT = 'SELECT PEMON_Y1';
       SET @Ls_Sqldata_TEXT = ' ThreadNextCount_NUMB = ' + ISNULL(CAST(@Ln_ThreadNextCount_NUMB AS VARCHAR(15)), '');

       SELECT @Ln_EndThread_NUMB = MAX(p.RecordRowNumber_NUMB)
         FROM PEMON_Y1 p
        WHERE p.NcpMci_IDNO IN (SELECT pp.NcpMci_IDNO
                                  FROM PEMON_Y1 pp
                                 WHERE pp.RecordRowNumber_NUMB = @Ln_ThreadNextCount_NUMB);

       IF @Ln_ThreadCount_NUMB = @Ln_LoopCount_NUMB
        BEGIN
         SET @Ln_EndThread_NUMB = @Ln_TotalCount_NUMB;
        END
        
       SET @Ls_Sql_TEXT = 'INSERT JRTL';
       SET @Ls_Sqldata_TEXT = ' LoopCount_NUMB = ' + ISNULL(CAST(@Ln_LoopCount_NUMB AS VARCHAR(15)), '') + ', ThreadNextCount_NUMB = ' + ISNULL(CAST(@Ln_ThreadNextCount_NUMB AS VARCHAR(15)), '');

       --@Ln_BeginThread_NUMB is subtracted with 1 since starting record should be always be lesser than	
       INSERT INTO JRTL_Y1
                   (Job_ID,
                    Run_DATE,
                    Thread_NUMB,
                    RecStart_NUMB,
                    RecEnd_NUMB,
                    RestartKey_TEXT,
                    RecRestart_NUMB,
                    ThreadProcess_CODE)
            VALUES (@Lc_JobEmon_ID,--Job_ID
                    @Ld_Run_DATE,--Run_DATE
                    @Ln_LoopCount_NUMB,--Thread_NUMB
                    @Ln_BeginThread_NUMB,--RecStart_NUMB
                    @Ln_EndThread_NUMB,--RecEnd_NUMB
                    ' ',--RestartKey_TEXT
                    @Ln_BeginThread_NUMB,--RecRestart_NUMB
                    @Lc_No_INDC --ThreadProcess_CODE
       );

       SET @Ls_ListKeyEmon_TEXT = @Ls_ListKeyEmon_TEXT + ' THREAD NUMBER = ' + ISNULL(CAST(@Ln_LoopCount_NUMB AS VARCHAR(15)), '') + ', STARTING THREAD VALUE = ' + ISNULL(CAST(@Ln_BeginThread_NUMB AS VARCHAR(15)), '') + ', ENDING THREAD VALUE = ' + ISNULL(CAST(@Ln_EndThread_NUMB AS VARCHAR(15)), '');
       SET @Ln_BeginThread_NUMB = @Ln_EndThread_NUMB + 1;
       SET @Ln_ThreadNextCount_NUMB = @Ln_EndThread_NUMB + @Ln_ThreadAvgCount_NUMB;

       IF @Ln_ThreadNextCount_NUMB > @Ln_TotalCount_NUMB
        BEGIN
         SET @Ln_ThreadNextCount_NUMB = @Ln_TotalCount_NUMB;
        END
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_PRE_EMON : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(20)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_PRE_EMON  : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
     SET @Ls_Sqldata_TEXT = ' Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(10)), '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_PRE_EMON  :  BATCH_COMMON$SP_BSTL_LOG';

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalCount_NUMB;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Main_Transaction;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION Main_Transaction;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @As_CursorLocation_TEXT       = @Ln_Cursor_QNTY,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalCount_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END

GO
