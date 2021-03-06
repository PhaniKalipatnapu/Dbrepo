/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REPORTS$SP_PROCESS_DHRR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REPORTS$SP_PROCESS_DHRR
Programmer Name 	: IMP Team
Description			: The procedure BATCH_FIN_COLLECTIONS$SP_PROCESS_DHRR takes held receipts data from RCTH_Y1
					  and loads into table RDHRR_Y1 Table.
Frequency			: 'DAILY'
Developed On		: 10/19/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REPORTS$SP_PROCESS_DHRR]
AS
 BEGIN
  SET NOCOUNT ON;
 DECLARE @Lc_Space_TEXT                   CHAR(1) = ' ',
         @Lc_StatusFailed_CODE            CHAR(1) = 'F',
         @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
         @Lc_StatusAbnormalend_CODE       CHAR(1) = 'A',
         @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
         @Lc_StatusReceiptIdentified_CODE CHAR(1) = 'I',
         @Lc_BackOut_INDC                 CHAR(1) = 'Y',
         @Lc_Job_ID                       CHAR(7) = 'DEB0910',
         @Lc_Successful_TEXT              CHAR(20) = 'SUCCESSFUL',
         @Lc_BatchRunUser_TEXT            CHAR(30) = 'BATCH',
         @Lc_Parmdateproblem_TEXT         CHAR(30) = 'PARM DATE PROBLEM',
         @Ls_Process_NAME                 VARCHAR(100) = 'BATCH_FIN_REPORTS',
         @Ls_Procedure_NAME               VARCHAR(100) = 'SP_PROCESS_DHRR',
         @Ld_Low_DATE                     DATE = '01/01/0001';
 DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
         @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
         @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
         @Ln_Error_NUMB                  NUMERIC(11),
         @Ln_ErrorLine_NUMB              NUMERIC(11),
         @Lc_Null_TEXT                   CHAR(1) = '',
         @Lc_Msg_CODE                    CHAR(1),
         @Ls_Sql_TEXT                    VARCHAR(100),
         @Ls_Sqldata_TEXT                VARCHAR(1000),
         @Ls_DescriptionError_TEXT       VARCHAR(4000),
         @Ls_ErrorMessage_TEXT           VARCHAR(4000),
         @Ld_Run_DATE                    DATE,
         @Ld_LastRun_DATE                DATE,
         @Ld_BeginValidity_DATE          DATE,
         @Ld_RunStart_DATE               DATE,
         @Ld_Start_DATE                  DATETIME2;
  BEGIN TRY
   SET NOCOUNT ON;

   BEGIN TRAN DhrrTran;

   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
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
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --Job Run Date validation
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_Parmdateproblem_TEXT;

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DELETE RDHRR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM RDHRR_Y1;
   
   SET @Ls_Sql_TEXT = 'SELECT RDHRR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ld_BeginValidity_DATE = ISNULL (MAX (r.BeginValidity_DATE), @Ld_Low_DATE)
     FROM RDHRR_Y1 r;

   IF @Ld_BeginValidity_DATE = @Ld_Low_DATE
    BEGIN
     SET @Ld_RunStart_DATE = @Ld_BeginValidity_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_RunStart_DATE = DATEADD (D, 1, @Ld_LastRun_DATE);
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO RDHRR_Y1';
   SET @Ls_Sqldata_TEXT = '';	 
   INSERT RDHRR_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           SourceReceipt_CODE,
           TypePosting_CODE,
           Case_IDNO,
           PayorMCI_IDNO,
           Receipt_AMNT,
           ToDistribute_AMNT,
           Receipt_DATE,
           Distribute_DATE,
           StatusReceipt_CODE,
           ReasonStatus_CODE,
           BackOut_INDC,
           BeginValidity_DATE,
           EndValidity_DATE,
           Release_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB,
           Worker_ID,
           County_IDNO,
           MemberSsn_NUMB,
           First_NAME,
           Last_NAME,
           Middle_NAME,
           DescriptionReason_TEXT,
           OtherCounty_IDNO,
           Transaction_CODE)
   --	HELD RECIPTS
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceReceipt_CODE,
          a.TypePosting_CODE,
          a.Case_IDNO,
          a.PayorMCI_IDNO,
          a.Receipt_AMNT,
          a.ToDistribute_AMNT,
          a.Receipt_DATE,
          a.Distribute_DATE,
          a.StatusReceipt_CODE,
          a.ReasonStatus_CODE,
          a.BackOut_INDC,
          a.BeginValidity_DATE,
          a.EndValidity_DATE,
          a.Release_DATE,
          a.EventGlobalBeginSeq_NUMB,
          a.EventGlobalEndSeq_NUMB,
          ISNULL(c.Worker_ID, ' ') AS Worker_ID,
          ISNULL(c.County_IDNO, 0) AS County_IDNO,
          b.MemberSsn_NUMB AS MemberSsn_NUMB,
          b.First_NAME,
          b.Last_NAME,
          b.Middle_NAME,
          @Lc_Null_TEXT AS DescriptionReason_TEXT,
          0 AS OtherCounty_IDNO,
          @Lc_Space_TEXT AS Transaction_CODE
     FROM RCTH_Y1 a
          LEFT OUTER JOIN CASE_Y1 c
           ON a.Case_IDNO = c.Case_IDNO,
          DEMO_Y1 b
    WHERE a.BeginValidity_DATE BETWEEN @Ld_RunStart_DATE AND @Ld_Run_DATE
      AND ((a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE)
            OR (a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                AND (a.BeginValidity_DATE > a.Batch_DATE
                      OR a.BackOut_INDC = @Lc_BackOut_INDC)))
      AND a.PayorMCI_IDNO = b.MemberMci_IDNO
   UNION ALL
   --	RELEASED RECEIPTS
   SELECT a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceReceipt_CODE,
          a.TypePosting_CODE,
          a.Case_IDNO,
          a.PayorMCI_IDNO,
          a.Receipt_AMNT,
          a.ToDistribute_AMNT,
          a.Receipt_DATE,
          a.Distribute_DATE,
          a.StatusReceipt_CODE,
          a.ReasonStatus_CODE,
          a.BackOut_INDC,
          a.BeginValidity_DATE,
          a.EndValidity_DATE,
          a.Release_DATE,
          a.EventGlobalBeginSeq_NUMB,
          a.EventGlobalEndSeq_NUMB,
          ISNULL(c.Worker_ID, ' ') AS Worker_ID,
          ISNULL(c.County_IDNO, 0) AS County_IDNO,
          b.MemberSsn_NUMB AS MemberSsn_NUMB,
          b.First_NAME,
          b.Last_NAME,
          b.Middle_NAME,
          @Lc_Null_TEXT AS DescriptionReason_TEXT,
          0 AS OtherCounty_IDNO,
          @Lc_Space_TEXT AS Transaction_CODE
     FROM (SELECT r.Batch_DATE,
                  r.SourceBatch_CODE,
                  r.Batch_NUMB,
                  r.SeqReceipt_NUMB,
                  r.SourceReceipt_CODE,
                  r.TypeRemittance_CODE,
                  r.TypePosting_CODE,
                  r.Case_IDNO,
                  r.PayorMCI_IDNO,
                  r.Receipt_AMNT,
                  r.ToDistribute_AMNT,
                  r.Fee_AMNT,
                  r.Employer_IDNO,
                  r.Fips_CODE,
                  r.Check_DATE,
                  r.CheckNo_TEXT,
                  r.Receipt_DATE,
                  r.Distribute_DATE,
                  r.Tanf_CODE,
                  r.TaxJoint_CODE,
                  r.TaxJoint_NAME,
                  r.StatusReceipt_CODE,
                  r.ReasonStatus_CODE,
                  r.BackOut_INDC,
                  r.ReasonBackOut_CODE,
                  r.Refund_DATE,
                  r.Release_DATE,
                  r.ReferenceIrs_IDNO,
                  r.RefundRecipient_ID,
                  r.RefundRecipient_CODE,
                  r.BeginValidity_DATE,
                  r.EndValidity_DATE,
                  r.EventGlobalBeginSeq_NUMB,
                  r.EventGlobalEndSeq_NUMB
             FROM RCTH_Y1 r
            WHERE EXISTS (SELECT 1
                            FROM RBAT_Y1 b
                           WHERE r.Batch_DATE = b.Batch_DATE
                             AND r.SourceBatch_CODE = b.SourceBatch_CODE
                             AND r.Batch_NUMB = b.Batch_NUMB
                             AND b.BeginValidity_DATE > b.Batch_DATE
                             AND b.BeginValidity_DATE BETWEEN @Ld_RunStart_DATE AND @Ld_Run_DATE)
              AND r.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
              AND ((@Ld_RunStart_DATE = @Ld_Low_DATE
                    AND r.BeginValidity_DATE = r.Batch_DATE)
                    OR (@Ld_RunStart_DATE <> @Ld_Low_DATE
                        AND r.BeginValidity_DATE < @Ld_RunStart_DATE))) AS a
          LEFT OUTER JOIN CASE_Y1 c
           ON a.Case_IDNO = c.Case_IDNO,
          DEMO_Y1 b
    WHERE a.PayorMCI_IDNO = b.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'UPDATE RDHRR_Y1 - 1 - REASON CODE - FOR RELEASED RECEIPTS';
   SET @Ls_Sqldata_TEXT = 'StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'');
   UPDATE RDHRR_Y1
      SET ReasonStatus_CODE = ISNULL ((SELECT TOP 1 x.ReasonStatus_CODE
                                         --All the held receipts that are already available in RDHRR_Y1 and RCTH_Y1 can be avoided in this update.
                                         FROM RDHRR_Y1 x
                                        WHERE a.Batch_DATE = x.Batch_DATE
                                          AND a.Batch_NUMB = x.Batch_NUMB
                                          AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                          AND a.SourceBatch_CODE = x.SourceBatch_CODE
                                          AND x.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                          AND a.ToDistribute_AMNT <= x.ToDistribute_AMNT
                                          AND x.BeginValidity_DATE < a.BeginValidity_DATE), @Lc_Space_TEXT)
     FROM RDHRR_Y1 a
    WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
      AND a.BeginValidity_DATE BETWEEN @Ld_RunStart_DATE AND @Ld_Run_DATE;

   --Bulk update for County_IDNO and Worker_ID columns
   SET @Ls_Sql_TEXT = 'UPDATE RDHRR_Y1 - 2 - County_IDNO';
   SET @Ls_Sqldata_TEXT = '';
   UPDATE RDHRR_Y1
      SET County_IDNO = b.County_IDNO
     FROM RDHRR_Y1 a,
          (SELECT a.NcpPf_IDNO,
                  MAX (a.County_IDNO) County_IDNO
             FROM ENSD_Y1 a
            GROUP BY a.NcpPf_IDNO
           HAVING COUNT (DISTINCT a.County_IDNO) = 1) b
    WHERE a.Worker_ID = ' '
      AND a.PayorMCI_IDNO = b.NcpPf_IDNO;

   SET @Ls_Sql_TEXT = 'UPDATE RDHRR_Y1 - 3 - Worker_ID';
   SET @Ls_Sqldata_TEXT = '';
   UPDATE RDHRR_Y1
      SET Worker_ID = b.WorkerCase_ID
     FROM RDHRR_Y1 a,
          (SELECT a.NcpPf_IDNO,
                  MAX(a.WorkerCase_ID) WorkerCase_ID
             FROM ENSD_Y1 a
            GROUP BY a.NcpPf_IDNO
           HAVING COUNT (DISTINCT a.WorkerCase_ID) = 1) b
    WHERE a.Worker_ID = ' '
      AND a.PayorMCI_IDNO = b.NcpPf_IDNO;

   SET @Ls_Sql_TEXT = 'SELECT RDHRR_Y1';
   SET @Ls_Sqldata_TEXT = '';
   SELECT @Ln_ProcessedRecordCount_QNTY = COUNT(1)
     FROM RDHRR_Y1 a;

   -- Job Run Date update in VPARM table
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRAN DhrrTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DhrrTran;
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END

GO
