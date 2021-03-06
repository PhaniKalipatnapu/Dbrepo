/****** Object:  StoredProcedure [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_PROCESS_REFUND_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_RELEASE_RECEIPT$SP_PROCESS_REFUND_RECEIPT

Programmer Name 	: IMP Team

Description			: This process retrieves all held receipts from the RCTH_Y1 (RCTH) table
					  and refund them based on their release date or if the UDC Code.

Frequency			: 'DAILY'

Developed On		: 11/29/2011

Called BY			: None

Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_PROCESS_REFUND_RECEIPT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Refund1220_NUMB                   INT = 1220,
          @Lc_StatusFailed_CODE                 CHAR (1) = 'F',
          @Lc_Value_INDC                        CHAR (1) = 'N',
          @Lc_StatusReceiptHeld_CODE            CHAR (1) = 'H',
          @Lc_Yes_INDC                          CHAR (1) = 'Y',
          @Lc_StatusReceiptRefunded_CODE        CHAR (1) = 'R',
          @Lc_Space_TEXT                        CHAR (1) = ' ',
          @Lc_RecipientTypeCpNcp_CODE           CHAR (1) = '1',
          @Lc_CaseRelationshipNcp_CODE          CHAR (1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE    CHAR (1) = 'P',
          @Lc_CaseMemberStatusActive_CODE       CHAR (1) = 'A',
          @Lc_StatusCaseOpen_CODE               CHAR (1) = 'O',
          @Lc_StatusSuccess_CODE                CHAR (1) = 'S',
          @Lc_StatusAbnormalend_CODE            CHAR (1) = 'A',
          @Lc_DhldRegularTypeHold_CODE          CHAR (1) = 'D',
          @Lc_SourceReceiptInterstativdfee_CODE CHAR (2) = 'FF',
          @Lc_ReasonStatusDisburseReady_CODE    CHAR (2) = 'DR',
          @Lc_TypeDisburseRefund_CODE           CHAR (5) = 'REFND',
          @Lc_BateErrorE1424_CODE               CHAR (5) = 'E1424',
          @Lc_Job_ID                            CHAR (7) = 'DEB1010',
          @Lc_Successful_TEXT                   CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                 CHAR (30) = 'BATCH',
          @Ls_Process_NAME                      VARCHAR (100) = 'BATCH_FIN_RELEASE_RECEIPT',
          @Ls_Procedure_NAME                    VARCHAR (4000) = 'SP_REFUND_RECEIPT',
          @Ld_High_DATE                         DATE = '12/31/9999',
          @Ld_Low_DATE                          DATE = '01/01/0001';
  DECLARE @Ln_CommitFreq_QNTY					NUMERIC (5) = 0,
          @Ln_ExceptionThresholdParm_QNTY		NUMERIC (5),
          @Ln_Rowcount_QNTY						NUMERIC (5),
          @Ln_CommitFreqParm_QNTY				NUMERIC (5),
          @Ln_CaseDhld_IDNO						NUMERIC (6),
          @Ln_ProcessRecordsCount_QNTY			NUMERIC (6) = 0,
          @Ln_ProcessedRecordsCountCommit_QNTY	NUMERIC (6) = 0,
          @Ln_Error_NUMB						NUMERIC (11),
          @Ln_ErrorLine_NUMB					NUMERIC (11),
          @Ln_Cursor_QNTY						NUMERIC (11) = 0,
          @Ln_EventGlobalSeq_NUMB				NUMERIC (19),
          @Li_FetchStatus_QNTY					SMALLINT,
          @Lc_Msg_CODE							CHAR (1),
          @Lc_BateError_CODE					CHAR (5),
          @Ls_CursorLoc_TEXT					VARCHAR (200) ='',
          @Ls_Sql_TEXT							VARCHAR (4000),
          @Ls_Sqldata_TEXT						VARCHAR (4000),
          @Ls_ErrorMessage_TEXT					VARCHAR (4000),
          @Ls_DescriptionError_TEXT				VARCHAR (4000),
          @Ls_BateRecord_TEXT					VARCHAR (4000),
          @Ld_Run_DATE							DATE,
          @Ld_LastRun_DATE						DATE,
          @Ld_Start_DATE						DATETIME2;
  DECLARE @Ld_RefundCur_Batch_DATE               DATE,
          @Lc_RefundCur_SourceBatch_CODE         CHAR(3),
          @Ln_RefundCur_Batch_NUMB               NUMERIC(4),
          @Ln_RefundCur_SeqReceipt_NUMB          NUMERIC(6),
          @Lc_RefundCur_SourceReceipt_CODE       CHAR(2),
          @Lc_RefundCur_TypeRemittance_CODE      CHAR(3),
          @Lc_RefundCur_TypePosting_CODE         CHAR(1),
          @Ln_RefundCur_Case_IDNO                NUMERIC(6),
          @Ln_RefundCur_Payor_IDNO               NUMERIC(10),
          @Ln_RefundCur_Receipt_AMNT             NUMERIC(11, 2),
          @Ln_RefundCur_ToDistribute_AMNT        NUMERIC(11, 2),
          @Ln_RefundCur_Fee_AMNT                 NUMERIC(11, 2),
          @Lc_RefundCur_Employer_IDNO            CHAR(9),
          @Lc_RefundCur_Fips_IDNO                CHAR(7),
          @Ld_RefundCur_Check_DATE               DATE,
          @Lc_RefundCur_NoCheck_TEXT             CHAR(20),
          @Ld_RefundCur_Receipt_DATE             DATE,
          @Lc_RefundCur_Tanf_INDC                CHAR(1),
          @Lc_RefundCur_TaxJoint_INDC            CHAR(1),
          @Lc_RefundCur_TaxJoint_NAME            CHAR(35),
          @Lc_RefundCur_StatusReceipt_CODE       CHAR(1),
          @Lc_RefundCur_ReasonStatus_CODE        CHAR(4),
          @Lc_RefundCur_BackOut_INDC             CHAR(1),
          @Lc_RefundCur_ReasonBackOut_CODE       CHAR(2),
          @Ld_RefundCur_Release_DATE             DATE,
          @Ld_RefundCur_Refund_DATE              DATE,
          @Ln_RefundCur_ReferenceIrs_IDNO        NUMERIC(15),
          @Lc_RefundCur_RefundRecipient_ID       CHAR(9),
          @Lc_RefundCur_RefundRecipient_CODE     CHAR(1),
          @Ln_RefundCur_EventGlobalBeginSeq_NUMB NUMERIC(19);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS REFUND RECIPTS';
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
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PARM DATE CHECK VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LasrRun_DATE = ' + CAST(DATEADD(D, 1, @Ld_LastRun_DATE) AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ REFUND RECEIPT';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_Refund1220_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_Value_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_Refund1220_NUMB,
    @Ac_Process_ID              = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    @Ac_Note_INDC               = @Lc_Value_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Fetch the records which are eligible for System Refund	
   -- SNAX,SNCL,SNCC,SNIO,SNJO,SNJW,SNXO,SNNA,SNNO
   SET @Ls_Sql_TEXT = 'SELECT_RCTH_Y1_REFUND_CURSOR_SELECT';
   SET @Ls_Sqldata_TEXT = '';

   DECLARE Refund_CUR INSENSITIVE CURSOR FOR
    SELECT r.Batch_DATE,
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
           r.Tanf_CODE,
           r.TaxJoint_CODE,
           r.TaxJoint_NAME,
           r.StatusReceipt_CODE,
           r.ReasonStatus_CODE,
           r.BackOut_INDC,
           r.ReasonBackOut_CODE,
           r.Release_DATE,
           r.Refund_DATE,
           r.ReferenceIrs_IDNO,
           r.RefundRecipient_ID,
           r.RefundRecipient_CODE,
           r.EventGlobalBeginSeq_NUMB
      FROM RCTH_Y1 r
     WHERE r.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
       AND r.Release_DATE <= @Ld_Run_DATE
       AND r.EndValidity_DATE = @Ld_High_DATE
       -- Exclude Other state Fee receipts  from auto refunds - FF - INTERGOVERNMENTAL IV-D FEE
       AND r.SourceReceipt_CODE <> @Lc_SourceReceiptInterstativdfee_CODE
       -- Automatic Refund indicator should be yes
       AND EXISTS (SELECT 1
                     FROM UCAT_Y1 u
                    WHERE r.ReasonStatus_CODE = u.Udc_CODE
                      AND u.AutomaticRefund_INDC = @Lc_Yes_INDC
                      AND u.EndValidity_DATE = @Ld_High_DATE)
       -- Receipt Should not be backed out  
       AND NOT EXISTS (SELECT 1
                         FROM RCTH_Y1 h
                        WHERE r.Batch_DATE = h.Batch_DATE
                          AND r.SourceBatch_CODE = h.SourceBatch_CODE
                          AND r.Batch_NUMB = h.Batch_NUMB
                          AND r.SeqReceipt_NUMB = h.SeqReceipt_NUMB
                          AND h.BackOut_INDC = @Lc_Yes_INDC
                          AND h.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'RCTH_Y1_REFUND COUNT LOOP STARTS';
   SET @Ls_Sqldata_TEXT = '';

   BEGIN TRANSACTION RefundReceipt;

   SET @Ls_Sql_TEXT = 'OPEN Refund_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Refund_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Refund_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Refund_CUR INTO @Ld_RefundCur_Batch_DATE, @Lc_RefundCur_SourceBatch_CODE, @Ln_RefundCur_Batch_NUMB, @Ln_RefundCur_SeqReceipt_NUMB, @Lc_RefundCur_SourceReceipt_CODE, @Lc_RefundCur_TypeRemittance_CODE, @Lc_RefundCur_TypePosting_CODE, @Ln_RefundCur_Case_IDNO, @Ln_RefundCur_Payor_IDNO, @Ln_RefundCur_Receipt_AMNT, @Ln_RefundCur_ToDistribute_AMNT, @Ln_RefundCur_Fee_AMNT, @Lc_RefundCur_Employer_IDNO, @Lc_RefundCur_Fips_IDNO, @Ld_RefundCur_Check_DATE, @Lc_RefundCur_NoCheck_TEXT, @Ld_RefundCur_Receipt_DATE, @Lc_RefundCur_Tanf_INDC, @Lc_RefundCur_TaxJoint_INDC, @Lc_RefundCur_TaxJoint_NAME, @Lc_RefundCur_StatusReceipt_CODE, @Lc_RefundCur_ReasonStatus_CODE, @Lc_RefundCur_BackOut_INDC, @Lc_RefundCur_ReasonBackOut_CODE, @Ld_RefundCur_Release_DATE, @Ld_RefundCur_Refund_DATE, @Ln_RefundCur_ReferenceIrs_IDNO, @Lc_RefundCur_RefundRecipient_ID, @Lc_RefundCur_RefundRecipient_CODE, @Ln_RefundCur_EventGlobalBeginSeq_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Refund cursor started	
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + CAST(@Ld_RefundCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RefundCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RefundCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RefundCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceReceipt_CODE = ' + @Lc_RefundCur_SourceReceipt_CODE + ', TypeRemittance_CODE = ' + @Lc_RefundCur_TypeRemittance_CODE + ', TypePosting_CODE = ' + @Lc_RefundCur_TypePosting_CODE + ', Case_IDNO = ' + CAST(@Ln_RefundCur_Case_IDNO AS VARCHAR) + ', Payor_IDNO = ' + CAST(@Ln_RefundCur_Payor_IDNO AS VARCHAR) + ', Receipt_AMNT = ' + CAST(@Ln_RefundCur_Receipt_AMNT AS VARCHAR) + ', ToDistribute_AMNT = ' + CAST(@Ln_RefundCur_ToDistribute_AMNT AS VARCHAR) + ', Fee_AMNT = ' + CAST(@Ln_RefundCur_Fee_AMNT AS VARCHAR) + ', Check_DATE = ' + CAST(@Ld_RefundCur_Check_DATE AS VARCHAR) + ', Receipt_DATE = ' + CAST(@Ld_RefundCur_Receipt_DATE AS VARCHAR) + ', TaxJoint_NAME = ' + @Lc_RefundCur_TaxJoint_NAME + ', StatusReceipt_CODE = ' + @Lc_RefundCur_StatusReceipt_CODE + ', ReasonStatus_CODE = ' + @Lc_RefundCur_ReasonStatus_CODE + ', BackOut_INDC = ' + @Lc_RefundCur_BackOut_INDC + ', ReasonBackOut_CODE = ' + @Lc_RefundCur_ReasonBackOut_CODE + ', Release_DATE = ' + CAST(@Ld_RefundCur_Release_DATE AS VARCHAR) + ', Refund_DATE = ' + CAST(@Ld_RefundCur_Refund_DATE AS VARCHAR) + ', RefundRecipient_ID = ' + @Lc_RefundCur_RefundRecipient_ID + ', RefundRecipient_CODE = ' + @Lc_RefundCur_RefundRecipient_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RefundCur_EventGlobalBeginSeq_NUMB AS VARCHAR);
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ln_ProcessRecordsCount_QNTY = @Ln_ProcessRecordsCount_QNTY + 1;
     SET @Ls_CursorLoc_TEXT = @Ls_BateRecord_TEXT;
     SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_RefundCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_RefundCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_RefundCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_RefundCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_RefundCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ld_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ld_RefundCur_Batch_DATE
        AND SourceBatch_CODE = @Lc_RefundCur_SourceBatch_CODE
        AND Batch_NUMB = @Ln_RefundCur_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_RefundCur_SeqReceipt_NUMB
        AND EventGlobalBeginSeq_NUMB = @Ln_RefundCur_EventGlobalBeginSeq_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1_REFUND';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RefundCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_RefundCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_RefundCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_RefundCur_SeqReceipt_NUMB AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_RefundCur_Payor_IDNO AS VARCHAR), '');

    MERGE INTO RCTH_Y1 t USING (SELECT @Ld_RefundCur_Batch_DATE Batch_DATE, @Lc_RefundCur_SourceBatch_CODE SourceBatch_CODE, @Ln_RefundCur_Batch_NUMB Batch_NUMB, @Ln_RefundCur_SeqReceipt_NUMB SeqReceipt_NUMB ) s ON (t.Batch_DATE = s.Batch_DATE AND t.SourceBatch_CODE = s.SourceBatch_CODE AND t.Batch_NUMB = s.Batch_NUMB AND t.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB) WHEN MATCHED THEN UPDATE SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_RefundCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT(Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, SourceReceipt_CODE, TypeRemittance_CODE, TypePosting_CODE, Case_IDNO, PayorMCI_IDNO, Receipt_AMNT, ToDistribute_AMNT, Fee_AMNT, Employer_IDNO, Fips_CODE, Check_DATE, CheckNo_TEXT, Receipt_DATE, Distribute_DATE, Tanf_CODE, TaxJoint_CODE, TaxJoint_NAME, StatusReceipt_CODE, ReasonStatus_CODE, BackOut_INDC, ReasonBackOut_CODE, BeginValidity_DATE, EndValidity_DATE, Release_DATE, Refund_DATE, ReferenceIrs_IDNO, RefundRecipient_ID, RefundRecipient_CODE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB) VALUES( @Ld_RefundCur_Batch_DATE, @Lc_RefundCur_SourceBatch_CODE, @Ln_RefundCur_Batch_NUMB, @Ln_RefundCur_SeqReceipt_NUMB, @Lc_RefundCur_SourceReceipt_CODE, @Lc_RefundCur_TypeRemittance_CODE, @Lc_RefundCur_TypePosting_CODE, @Ln_RefundCur_Case_IDNO, @Ln_RefundCur_Payor_IDNO, @Ln_RefundCur_Receipt_AMNT, @Ln_RefundCur_ToDistribute_AMNT, @Ln_RefundCur_Fee_AMNT, @Lc_RefundCur_Employer_IDNO, @Lc_RefundCur_Fips_IDNO, @Ld_RefundCur_Check_DATE, @Lc_RefundCur_NoCheck_TEXT, @Ld_RefundCur_Receipt_DATE, @Ld_Run_DATE, @Lc_RefundCur_Tanf_INDC, @Lc_RefundCur_TaxJoint_INDC, @Lc_RefundCur_TaxJoint_NAME, @Lc_StatusReceiptRefunded_CODE, @Lc_RefundCur_ReasonStatus_CODE, @Lc_Value_INDC, @Lc_Space_TEXT, @Ld_Run_DATE, @Ld_High_DATE, @Ld_Run_DATE, @Ld_RefundCur_Refund_DATE, @Ln_RefundCur_ReferenceIrs_IDNO, @Ln_RefundCur_Payor_IDNO, @Lc_RecipientTypeCpNcp_CODE, @Ln_EventGlobalSeq_NUMB, 0);

     IF @Ln_RefundCur_Case_IDNO = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_DHLD_CASE_REFUND ACTIVE';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_RefundCur_Payor_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE,'');

       SELECT TOP 1 @Ln_CaseDhld_IDNO = a.Case_IDNO
         FROM CASE_Y1 a,
              CMEM_Y1 c
        WHERE c.MemberMci_IDNO = @Ln_RefundCur_Payor_IDNO
          AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
          AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
          AND a.Case_IDNO = c.Case_IDNO
          AND a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_DHLD_CASE_REFUND IN-ACTIVE';
         SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_RefundCur_Payor_IDNO AS VARCHAR), '');

         SELECT TOP 1 @Ln_CaseDhld_IDNO = a.Case_IDNO
           FROM CASE_Y1 a,
                CMEM_Y1 c
          WHERE c.MemberMci_IDNO = @Ln_RefundCur_Payor_IDNO
            AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
            AND a.Case_IDNO = c.Case_IDNO;
        END
      END
     ELSE
      BEGIN
       SET @Ln_CaseDhld_IDNO = @Ln_RefundCur_Case_IDNO;
      END

     SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1_REFUND';
     SET @Ls_Sqldata_TEXT = '';

    MERGE INTO DHLD_Y1 d USING (SELECT @Ld_RefundCur_Batch_DATE Batch_DATE, @Lc_RefundCur_SourceBatch_CODE SourceBatch_CODE, @Ln_RefundCur_Batch_NUMB Batch_NUMB, @Ln_RefundCur_SeqReceipt_NUMB SeqReceipt_NUMB ) s ON (d.Case_IDNO = @Ln_CaseDhld_IDNO AND d.Batch_DATE = s.Batch_DATE AND d.SourceBatch_CODE = s.SourceBatch_CODE AND d.Batch_NUMB = s.Batch_NUMB AND d.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND d.Transaction_DATE = @Ld_Run_DATE AND d.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE AND d.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB) WHEN MATCHED THEN UPDATE SET Transaction_AMNT = Transaction_AMNT + @Ln_RefundCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT(Case_IDNO, OrderSeq_NUMB, ObligationSeq_NUMB, Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, Transaction_DATE, Release_DATE, Transaction_AMNT, Status_CODE, TypeDisburse_CODE, CheckRecipient_ID, CheckRecipient_CODE, TypeHold_CODE, ReasonStatus_CODE, ProcessOffset_INDC, EventGlobalSupportSeq_NUMB, BeginValidity_DATE, EndValidity_DATE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB, Disburse_DATE, DisburseSeq_NUMB, StatusEscheat_DATE, StatusEscheat_CODE) VALUES(@Ln_CaseDhld_IDNO, 0, 0, @Ld_RefundCur_Batch_DATE, @Lc_RefundCur_SourceBatch_CODE, @Ln_RefundCur_Batch_NUMB, @Ln_RefundCur_SeqReceipt_NUMB, @Ld_Run_DATE, @Ld_Run_DATE, @Ln_RefundCur_ToDistribute_AMNT, @Lc_StatusReceiptRefunded_CODE, @Lc_TypeDisburseRefund_CODE, @Ln_RefundCur_Payor_IDNO, @Lc_RecipientTypeCpNcp_CODE, @Lc_DhldRegularTypeHold_CODE, @Lc_ReasonStatusDisburseReady_CODE, @Lc_Yes_INDC, @Ln_EventGlobalSeq_NUMB, @Ld_Run_DATE, @Ld_High_DATE, @Ln_EventGlobalSeq_NUMB, 0, @Ld_Low_DATE, 0, @Ld_High_DATE, @Lc_Space_TEXT);
	
	 SET @Ls_Sql_TEXT = 'FETCH Refund_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ld_RefundCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_RefundCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_RefundCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_RefundCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceReceipt_CODE = ' + @Lc_RefundCur_SourceReceipt_CODE + ', TypeRemittance_CODE = ' + @Lc_RefundCur_TypeRemittance_CODE + ', TypePosting_CODE = ' + @Lc_RefundCur_TypePosting_CODE + ', Case_IDNO = ' + CAST(@Ln_RefundCur_Case_IDNO AS VARCHAR) + ', Payor_IDNO = ' + CAST(@Ln_RefundCur_Payor_IDNO AS VARCHAR) + ', Receipt_AMNT = ' + CAST(@Ln_RefundCur_Receipt_AMNT AS VARCHAR) + ', ToDistribute_AMNT = ' + CAST(@Ln_RefundCur_ToDistribute_AMNT AS VARCHAR) + ', Fee_AMNT = ' + CAST(@Ln_RefundCur_Fee_AMNT AS VARCHAR) + ', Check_DATE = ' + CAST(@Ld_RefundCur_Check_DATE AS VARCHAR) + ', Receipt_DATE = ' + CAST(@Ld_RefundCur_Receipt_DATE AS VARCHAR) + ', TaxJoint_NAME = ' + @Lc_RefundCur_TaxJoint_NAME + ', StatusReceipt_CODE = ' + @Lc_RefundCur_StatusReceipt_CODE + ', ReasonStatus_CODE = ' + @Lc_RefundCur_ReasonStatus_CODE + ', BackOut_INDC = ' + @Lc_RefundCur_BackOut_INDC + ', ReasonBackOut_CODE = ' + @Lc_RefundCur_ReasonBackOut_CODE + ', Release_DATE = ' + CAST(@Ld_RefundCur_Release_DATE AS VARCHAR) + ', Refund_DATE = ' + CAST(@Ld_RefundCur_Refund_DATE AS VARCHAR) + ', RefundRecipient_ID = ' + @Lc_RefundCur_RefundRecipient_ID + ', RefundRecipient_CODE = ' + @Lc_RefundCur_RefundRecipient_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_RefundCur_EventGlobalBeginSeq_NUMB AS VARCHAR);

     FETCH NEXT FROM Refund_CUR INTO @Ld_RefundCur_Batch_DATE, @Lc_RefundCur_SourceBatch_CODE, @Ln_RefundCur_Batch_NUMB, @Ln_RefundCur_SeqReceipt_NUMB, @Lc_RefundCur_SourceReceipt_CODE, @Lc_RefundCur_TypeRemittance_CODE, @Lc_RefundCur_TypePosting_CODE, @Ln_RefundCur_Case_IDNO, @Ln_RefundCur_Payor_IDNO, @Ln_RefundCur_Receipt_AMNT, @Ln_RefundCur_ToDistribute_AMNT, @Ln_RefundCur_Fee_AMNT, @Lc_RefundCur_Employer_IDNO, @Lc_RefundCur_Fips_IDNO, @Ld_RefundCur_Check_DATE, @Lc_RefundCur_NoCheck_TEXT, @Ld_RefundCur_Receipt_DATE, @Lc_RefundCur_Tanf_INDC, @Lc_RefundCur_TaxJoint_INDC, @Lc_RefundCur_TaxJoint_NAME, @Lc_RefundCur_StatusReceipt_CODE, @Lc_RefundCur_ReasonStatus_CODE, @Lc_RefundCur_BackOut_INDC, @Lc_RefundCur_ReasonBackOut_CODE, @Ld_RefundCur_Release_DATE, @Ld_RefundCur_Refund_DATE, @Ln_RefundCur_ReferenceIrs_IDNO, @Lc_RefundCur_RefundRecipient_ID, @Lc_RefundCur_RefundRecipient_CODE, @Ln_RefundCur_EventGlobalBeginSeq_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Refund_CUR;

   DEALLOCATE Refund_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessRecordsCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessRecordsCount_QNTY;

   COMMIT TRANSACTION RefundReceipt;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION RefundReceipt;
    END
   
   IF CURSOR_STATUS('Local', 'Refund_CUR') IN (0, 1)
    BEGIN
     CLOSE Refund_CUR;

     DEALLOCATE Refund_CUR;
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
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
