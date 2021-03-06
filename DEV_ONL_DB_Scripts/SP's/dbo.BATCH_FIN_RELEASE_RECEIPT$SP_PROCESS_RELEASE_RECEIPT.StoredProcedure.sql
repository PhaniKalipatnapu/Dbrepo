/****** Object:  StoredProcedure [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_PROCESS_RELEASE_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_RELEASE_RECEIPT$SP_PROCESS_RELEASE_RECEIPT
Programmer Name 	: IMP Team
Description			: The process BATCH_FIN_RELEASE_RECEIPT releases receipts based on
					  the modifications on the hold instructions from the Manual Hold Instructions HLDI screen.
					  It also releases held receipts based on UCAT attribute that were on systematic holds.
					  If there are other current hold instructions, the release of one hold instruction
					  does not guarantee release of collection. The receipt may once again go on hold but
					  for a different reason.
Frequency			: 'DAILY'
Developed On		: 11/29/2011
Called BY			: None
Called On			: BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS,BATCH_FIN_RELEASE_RECEIPT$SF_GET_CASEPAYOR_ARREARS,
					  BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO,BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT,
					  BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT,BATCH_FIN_COLLECTIONS$SP_CR_RECEIPT_PROCESS
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_PROCESS_RELEASE_RECEIPT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ReceiptOnHold1420_NUMB              INT = 1420,
          @Li_ReleaseAHeldReceipt1430_NUMB        INT = 1430,
          @Lc_StatusReceiptHeld_CODE              CHAR (1) = 'H',
          @Lc_StatusReceiptIdentified_CODE        CHAR (1) = 'I',
          @Lc_Yes_INDC                            CHAR (1) = 'Y',
          @Lc_StatusFailed_CODE                   CHAR (1) = 'F',
          @Lc_Value_INDC                          CHAR (1) = 'N',
          @Lc_Processed_INDC                      CHAR (1) = 'N',
          @Lc_TypePostingCase_CODE                CHAR (1) = 'C',
          @Lc_TypeOrderVoluntary_CODE             CHAR (1) = 'V',
          @Lc_TypePostingPayor_CODE               CHAR (1) = 'P',
          @Lc_CaseRelationshipNcp_CODE            CHAR (1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE      CHAR (1) = 'P',
          @Lc_CaseRelationshipExcluded_CODE       CHAR (1) = 'X',
          @Lc_CaseMemberStatusActive_CODE         CHAR (1) = 'A',
          @Lc_Space_TEXT                          CHAR (1) = ' ',
          @Lc_CaseStatusOpen_CODE                 CHAR (1) = 'O',
          @Lc_CaseTypeNonIvd_CODE                 CHAR (1) = 'H',
          @Lc_StatusSuccess_CODE                  CHAR (1) = 'S',
          @Lc_StatusAbnormalend_CODE              CHAR (1) = 'A',
          @Lc_IrsividualFiling_INDC               CHAR (1) = 'I',
          @Lc_IrsJointFiling_TEXT                 CHAR (1) = 'J',
          @Lc_TypeErrorW_CODE					  CHAR (1) = 'W',
          @Lc_RespondInitN_CODE                   CHAR (1) = 'N',
          @Lc_RespondInitY_CODE                   CHAR (1) = 'Y',
          @Lc_RespondInitR_CODE                   CHAR (1) = 'R',
          @Lc_RespondInitS_CODE                   CHAR (1) = 'S',                              
          @Lc_SourceReceiptSpecialCollection_CODE CHAR (2) = 'SC',
          @Lc_SourceReceiptEmployerWage_CODE      CHAR (2) = 'EW',
          @Lc_SourceReceiptUnemplComp_CODE        CHAR (2) = 'UC',
          @Lc_SourceReceiptDisabilityIns_CODE     CHAR (2) = 'DB',
          @Lc_SourceReceiptStateTaxRefund_CODE    CHAR (2) = 'ST',
          @Lc_SourceReceiptDh_CODE                CHAR (2) = 'DH',
          @Lc_SourceReceiptCpRecoupment_CODE      CHAR (2) = 'CR',
          @Lc_SourceReceiptCpFee_CODE			  CHAR (2) = 'CF',
          @Lc_SourceReceiptQdro_CODE              CHAR (2) = 'QR',
          @Lc_ReceiptSrcSequestrationLevySQ_CODE  CHAR (2) = 'SQ',
          @Lc_SourceReceiptVoluntary_CODE         CHAR (2) = 'VN',
          @Lc_PrevSourceBatch_CODE                CHAR (3) = ' ',
          @Lc_HoldReasonStatusSnax_CODE           CHAR (4) = 'SNAX',
          @Lc_HoldReasonStatusShcr_CODE           CHAR (4) = 'SHCR',
          @Lc_HoldReasonStatusShcp_CODE			  CHAR (4) = 'SHCP',	
          @Lc_HoldReasonStatusSnfx_CODE           CHAR (4) = 'SNFX',
          @Lc_HoldReasonStatusShnd_CODE           CHAR (4) = 'SHND',
          @Lc_HoldReasonStatusSnna_CODE           CHAR (4) = 'SNNA',
          @Lc_HoldReasonStatusSnno_CODE           CHAR (4) = 'SNNO',
          @Lc_HoldReasonStatusSncl_CODE           CHAR (4) = 'SNCL',
          @Lc_HoldReasonStatusSnpo_CODE           CHAR (4) = 'SNPO',
          @Lc_HoldReasonStatusSnbn_CODE           CHAR (4) = 'SNBN',
          @Lc_HoldReasonStatusSnle_CODE           CHAR (4) = 'SNLE',
          @Lc_HoldReasonStatusSnqr_CODE           CHAR (4) = 'SNQR',
          @Lc_HoldReasonStatusSnsq_CODE			  CHAR (4) = 'SNSQ',
          @Lc_HoldReasonStatusSnwg_CODE			  CHAR (4) = 'SNWG',
          @Lc_ActivityMajorFidm_CODE              CHAR (4) = 'FIDM',
          @Lc_ActivityMajorSeqo_CODE              CHAR (4) = 'SEQO',            
          @Lc_RemedyStatusStart_CODE              CHAR (4) = 'STRT',
          @Lc_RemedyStatusComp_CODE               CHAR (4) = 'COMP',
          @Lc_HoldReasonStatusSnwc_CODE           CHAR (4) = 'SNWC',
          @Lc_ActivityMajorCsln_CODE              CHAR (4) = 'CSLN',
          @Lc_HoldReasonStatusSncc_CODE           CHAR (4) = 'SNCC',
          @Lc_HoldReasonStatusSnin_CODE           CHAR (4) = 'SNIN',
          @Lc_HoldReasonStatusSnio_CODE           CHAR (4) = 'SNIO',
          @Lc_HoldReasonStatusSnjn_CODE           CHAR (4) = 'SNJN',
          @Lc_HoldReasonStatusSnjo_CODE           CHAR (4) = 'SNJO',
          @Lc_HoldStateNoCert_CODE                CHAR (4) = 'SNSN',
          @Lc_HoldReasonStatusShcs_CODE			  CHAR (4) = 'SHCS',
          @Lc_ActivityMajorImiw_CODE			  CHAR (4) = 'IMIW',
          @Lc_StatusExmt_CODE					  CHAR (4) = 'EXMT',          
          @Lc_ActivityMinorMorfd_CODE             CHAR (5) = 'MORFD',
          @Lc_ActivityMinorRfins_CODE             CHAR (5) = 'RFINS',
          @Lc_ActivityMinorRsifc_CODE             CHAR (5) = 'RSIFC',
          @Lc_BateErrorE1424_CODE                 CHAR (5) = 'E1424',
          @Lc_NoRecordsToProcess_CODE             CHAR(5) = 'E0944',
          @Lc_Job_ID                              CHAR (7) = 'DEB0550',
          @Lc_Successful_TEXT                     CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                   CHAR (30) = 'BATCH',
          @Ls_Procedure_NAME                      VARCHAR (100) = 'SP_PROCESS_RELEASE_RECEIPT',
          @Ls_Process_NAME                        VARCHAR (100) = 'BATCH_FIN_RELEASE_RECEIPT',
          @Ld_Low_DATE                            DATE = '01/01/0001',
          @Ld_High_DATE                           DATE = '12/31/9999',
          @Ld_PrevBatch_DATE                      DATE = '01/01/0001';
  DECLARE @Ln_Holiday_NUMB				  NUMERIC (3) = 0,
		  @Ln_PrevBatch_NUMB              NUMERIC (4) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC (5),
          @Ln_CommitFreqParm_QNTY         NUMERIC (5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC (5),
          @Ln_PrevSeqReceipt_NUMB         NUMERIC (6) = 0,
          @Ln_PrevCase_IDNO               NUMERIC (6) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC (6) = 0,
          @Ln_CursorSnfxCur_QNTY          NUMERIC (7) = 0,
          @Ln_CursorHoldCur_QNTY		  NUMERIC (7) = 0,
          @Ln_CursorCrReceipt_QNTY		  NUMERIC (7) = 0,
          @Ln_CursorCfReceipt_QNTY		  NUMERIC (7) = 0,
          @Ln_PrevPayor_IDNO              NUMERIC (10) = 0,
          @Ln_Arrear_AMNT                 NUMERIC (11, 2) = 0,
          @Ln_Error_NUMB                  NUMERIC (11),
          @Ln_ErrorLine_NUMB              NUMERIC (11),
          @Ln_Rowcount_QNTY               NUMERIC (11),
          @Ln_EventGlobalSeqHold_NUMB     NUMERIC (19),
          @Ln_EventGlobalSeq_NUMB         NUMERIC (19),
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_Msg_CODE                    CHAR (5),
          @Lc_BateError_CODE              CHAR (5),
          @Ls_CursorLoc_TEXT              VARCHAR (200),
          @Ls_Sql_TEXT                    VARCHAR (4000),
          @Ls_Sqldata_TEXT                VARCHAR (4000),
          @Ls_ErrorMessage_TEXT           VARCHAR (4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR (4000),
          @Ls_BateRecord_TEXT             VARCHAR (4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Release_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ld_SnfxCur_Batch_DATE               DATE,
          @Lc_SnfxCur_SourceBatch_CODE         CHAR(3),
          @Ln_SnfxCur_Batch_NUMB               NUMERIC(4),
          @Ln_SnfxCur_SeqReceipt_NUMB          NUMERIC(6),
          @Lc_SnfxCur_SourceReceipt_CODE       CHAR(2),
          @Lc_SnfxCur_TypeRemittance_CODE      CHAR(3),
          @Lc_SnfxCur_TypePosting_CODE         CHAR(1),
          @Ln_SnfxCur_Case_IDNO                NUMERIC(6),
          @Ln_SnfxCur_Payor_IDNO               NUMERIC(10),
          @Ln_SnfxCur_Receipt_AMNT             NUMERIC(11, 2),
          @Ln_SnfxCur_ToDistribute_AMNT        NUMERIC(11, 2),
          @Ln_SnfxCur_Fee_AMNT                 NUMERIC(11, 2),
          @Ln_SnfxCur_Employer_IDNO            NUMERIC(9),
          @Lc_SnfxCur_Fips_CODE                CHAR(7),
          @Ld_SnfxCur_Check_DATE               DATE,
          @Lc_SnfxCur_CheckNo_TEXT             CHAR(18),
          @Ld_SnfxCur_Receipt_DATE             DATE,
          @Lc_SnfxCur_Tanf_CODE                CHAR(1),
          @Lc_SnfxCur_TaxJoint_CODE            CHAR(1),
          @Lc_SnfxCur_TaxJoint_NAME            CHAR(35),
          @Lc_SnfxCur_StatusReceipt_CODE       CHAR(1),
          @Lc_SnfxCur_ReasonStatus_CODE        CHAR(4),
          @Lc_SnfxCur_BackOut_INDC             CHAR(1),
          @Lc_SnfxCur_ReasonBackOut_CODE       CHAR(2),
          @Ld_SnfxCur_Release_DATE             DATE,
          @Ld_SnfxCur_Refund_DATE              DATE,
          @Lc_SnfxCur_ReferenceIrs_IDNO        CHAR(15),
          @Lc_SnfxCur_RefundRecipient_ID       CHAR(10),
          @Lc_SnfxCur_RefundRecipient_CODE     CHAR(1),
          @Ln_SnfxCur_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Lc_SnfxCur_Processed_INDC           CHAR(4);
  DECLARE @Ld_CrReceiptCur_Batch_DATE               DATE,
          @Ln_CrReceiptCur_Batch_NUMB               NUMERIC(4),
          @Ln_CrReceiptCur_SeqReceipt_NUMB          NUMERIC(6),
          @Lc_CrReceiptCur_SourceBatch_CODE         CHAR(3),
          @Ln_CrReceiptCur_Case_IDNO                NUMERIC(6),
          @Ln_CrReceiptCur_PayorMCI_IDNO            NUMERIC(10),
          @Ln_CrReceiptCur_ToDistribute_AMNT        NUMERIC(11, 2),
          @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Ld_CrReceiptCur_Receipt_DATE             DATE;

  BEGIN TRY
   SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   /*
   Get the run date and last run date from PARM_Y1 (Parameters table) and validate that the batch 
   program was not executed for the run date by ensuring that the run date is different from the 
   last run date in the PARM table.  Otherwise, an error message to that effect will be written 
   into Batch Status Log (BSTL) Screen/Batch Status Log (BSTL_Y1) table and terminate the process.
   */
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
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(DATEADD(D, 1, @Ld_LastRun_DATE) AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   -- Generate Hold Sequence Event Global	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 1';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR), '') + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + @Lc_Value_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
    @Ac_Process_ID              = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    @Ac_Note_INDC               = @Lc_Value_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqHold_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Move all the Receipt which are with the Hold "SNFX - System hold futures" to "SNAX - Arrears paid in full" if there is no Arrears
   DECLARE Snfx_CUR INSENSITIVE CURSOR FOR
    SELECT f.Batch_DATE,
           f.SourceBatch_CODE,
           f.Batch_NUMB,
           f.SeqReceipt_NUMB,
           f.SourceReceipt_CODE,
           f.TypeRemittance_CODE,
           f.TypePosting_CODE,
           f.Case_IDNO,
           f.PayorMCI_IDNO,
           f.Receipt_AMNT,
           f.ToDistribute_AMNT,
           f.Fee_AMNT,
           f.Employer_IDNO,
           f.Fips_CODE,
           f.Check_DATE,
           f.CheckNo_Text,
           f.Receipt_DATE,
           f.Tanf_CODE,
           f.TaxJoint_CODE,
           f.TaxJoint_NAME,
           f.StatusReceipt_CODE,
           f.ReasonStatus_CODE,
           f.BackOut_INDC,
           f.ReasonBackOut_CODE,
           f.Release_DATE,
           f.Refund_DATE,
           f.ReferenceIrs_IDNO,
           f.RefundRecipient_ID,
           f.RefundRecipient_CODE,
           f.EventGlobalBeginSeq_NUMB,
           @Lc_Processed_INDC
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.SourceReceipt_CODE,
                   a.TypeRemittance_CODE,
                   a.TypePosting_CODE,
                   a.Case_IDNO,
                   a.PayorMCI_IDNO,
                   a.Receipt_AMNT,
                   a.ToDistribute_AMNT,
                   a.Fee_AMNT,
                   a.Employer_IDNO,
                   a.Fips_CODE,
                   a.Check_DATE,
                   a.CheckNo_Text,
                   a.Receipt_DATE,
                   a.Tanf_CODE,
                   a.TaxJoint_CODE,
                   a.TaxJoint_NAME,
                   a.StatusReceipt_CODE,
                   a.ReasonStatus_CODE,
                   a.BackOut_INDC,
                   a.ReasonBackOut_CODE,
                   a.Release_DATE,
                   a.Refund_DATE,
                   a.ReferenceIrs_IDNO,
                   a.RefundRecipient_ID,
                   a.RefundRecipient_CODE,
                   a.EventGlobalBeginSeq_NUMB,
                   CASE
                    WHEN ((a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnfx_CODE) 
                          AND ((a.TypePosting_CODE = @Lc_TypePostingCase_CODE
                                AND ((a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                      AND dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(a.Case_IDNO, @Ld_Run_DATE) <= 0
                                      AND NOT EXISTS (SELECT 1
                                                        FROM OBLE_Y1 o
                                                       WHERE o.Case_IDNO = a.Case_IDNO
                                                         AND o.EndValidity_DATE = @Ld_High_DATE
                                                         AND o.Periodic_AMNT > 0
                                                         AND CAST(DATEADD(d,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @Ld_Run_DATE)+1,0))) AS DATE) BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE))
                                      OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                          AND EXISTS (SELECT 1
                                                        FROM SORD_Y1 s
                                                       WHERE a.Case_IDNO = s.Case_IDNO
                                                         AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                                                         AND s.EndValidity_DATE = @Ld_High_DATE
                                                         AND dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(s.Case_IDNO, @Ld_Run_DATE) <= 0
                                                         AND NOT EXISTS (SELECT 1
                                                                           FROM OBLE_Y1 o
                                                                          WHERE o.Case_IDNO = s.Case_IDNO
                                                                            AND o.EndValidity_DATE = @Ld_High_DATE
                                                                            AND o.Periodic_AMNT > 0
                                                                            AND CAST(DATEADD(d,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @Ld_Run_DATE)+1,0))) AS DATE) BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE)))))
                                OR (a.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                                    AND EXISTS (SELECT 1
                                                  FROM CMEM_Y1 m,
                                                       SORD_Y1 s
                                                 WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                   AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                   AND m.Case_IDNO = s.Case_IDNO
                                                   AND s.EndValidity_DATE = @Ld_High_DATE
                                                   AND dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(s.Case_IDNO, @Ld_Run_DATE) <= 0
                                                   AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                         OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                             AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)))
                                    AND NOT EXISTS (SELECT 1
                                                      FROM OBLE_Y1 o,
                                                           CMEM_Y1 b
                                                     WHERE b.MemberMci_IDNO = a.PayorMCI_IDNO
                                                       AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                       AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                       AND o.Case_IDNO = b.Case_IDNO
                                                       AND o.EndValidity_DATE = @Ld_High_DATE
                                                       AND o.Periodic_AMNT > 0
                                                       AND CAST(DATEADD(d,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, @Ld_Run_DATE)+1,0))) AS DATE) BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE))))
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_Processed_INDC
                   END ind_flag
              FROM RCTH_Y1 a
             WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
               AND a.EndValidity_DATE = @Ld_High_DATE
               AND a.Distribute_DATE = @Ld_Low_DATE
               AND EXISTS (SELECT 1
                             FROM UCAT_Y1 u
                            WHERE a.ReasonStatus_CODE = u.Udc_CODE
                              AND u.AutomaticRelease_INDC = @Lc_Yes_INDC
                              AND u.EndValidity_DATE = @Ld_High_DATE)) f
     WHERE f.ind_flag = @Lc_Yes_INDC;
   -- Query changed to fetch CR receipts with Identified
   DECLARE CrReceipt_CUR INSENSITIVE CURSOR FOR
    SELECT a.Batch_DATE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.SourceBatch_CODE,
           a.Case_IDNO,
           a.PayorMCI_IDNO,
           a.ToDistribute_AMNT,
           a.EventGlobalBeginSeq_NUMB,
           a.Receipt_DATE
      FROM RCTH_Y1 a
     WHERE a.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupment_CODE
       AND ((a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
             AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusShcr_CODE)
             OR (a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE))
       AND a.Release_DATE <= @Ld_Run_DATE
       AND a.Distribute_DATE = @Ld_Low_DATE
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND NOT EXISTS (SELECT 1
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BackOut_INDC = @Lc_Yes_INDC
                          AND b.EndValidity_DATE = @Ld_High_DATE)
       AND NOT EXISTS (SELECT 1 
						FROM RBAT_Y1 b
						WHERE a.Batch_DATE = b.Batch_DATE AND 
                        a.SourceBatch_CODE = b.SourceBatch_CODE AND 
                        a.Batch_NUMB = b.Batch_NUMB AND 
                        b.StatusBatch_CODE = 'U' AND 
                        b.EndValidity_DATE = @Ld_High_DATE);
   -- Query changed to fetch CF receipts with Identified
   DECLARE CfReceipt_CUR INSENSITIVE CURSOR FOR
    SELECT a.Batch_DATE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.SourceBatch_CODE,
           a.Case_IDNO,
           a.PayorMCI_IDNO,
           a.ToDistribute_AMNT,
           a.EventGlobalBeginSeq_NUMB,
           a.Receipt_DATE
      FROM RCTH_Y1 a
     WHERE a.SourceReceipt_CODE = @Lc_SourceReceiptCpFee_CODE
       AND ((a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
             AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusShcp_CODE)
             OR (a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE))
       AND a.Release_DATE <= @Ld_Run_DATE
       AND a.Distribute_DATE = @Ld_Low_DATE
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND NOT EXISTS (SELECT 1
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BackOut_INDC = @Lc_Yes_INDC
                          AND b.EndValidity_DATE = @Ld_High_DATE)
       AND NOT EXISTS (SELECT 1 
						FROM RBAT_Y1 b
						WHERE a.Batch_DATE = b.Batch_DATE AND 
                        a.SourceBatch_CODE = b.SourceBatch_CODE AND 
                        a.Batch_NUMB = b.Batch_NUMB AND 
                        b.StatusBatch_CODE = 'U' AND 
                        b.EndValidity_DATE = @Ld_High_DATE);                   	
   BEGIN TRANSACTION ReleaseReceipt;
   SET @Ls_Sql_TEXT = 'OPEN Snfx_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Snfx_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Snfx_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Snfx_CUR INTO @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_SnfxCur_StatusReceipt_CODE, @Lc_SnfxCur_ReasonStatus_CODE, @Lc_SnfxCur_BackOut_INDC, @Lc_SnfxCur_ReasonBackOut_CODE, @Ld_SnfxCur_Release_DATE, @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ln_SnfxCur_EventGlobalBeginSeq_NUMB, @Lc_SnfxCur_Processed_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    -- SNFX cursor started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
       SET @Ln_CursorSnfxCur_QNTY = @Ln_CursorSnfxCur_QNTY + 1;
       SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SnfxCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceReceipt_CODE = ' + @Lc_SnfxCur_SourceReceipt_CODE + ', TypeRemittance_CODE = ' + @Lc_SnfxCur_TypeRemittance_CODE + ', TypePosting_CODE = ' + @Lc_SnfxCur_TypePosting_CODE + ', Case_IDNO = ' + CAST(@Ln_SnfxCur_Case_IDNO AS VARCHAR) + ', Payor_IDNO = ' + CAST(@Ln_SnfxCur_Payor_IDNO AS VARCHAR) + ', Receipt_AMNT = ' + CAST(@Ln_SnfxCur_Receipt_AMNT AS VARCHAR) + ', ToDistribute_AMNT = ' + CAST(@Ln_SnfxCur_ToDistribute_AMNT AS VARCHAR) + ', Fee_AMNT = ' + CAST(@Ln_SnfxCur_Fee_AMNT AS VARCHAR) + ', Employer_IDNO = ' + CAST (@Ln_SnfxCur_Employer_IDNO AS VARCHAR) + ', Fips_CODE = ' + @Lc_SnfxCur_Fips_CODE + ', Check_DATE = ' + CAST(@Ld_SnfxCur_Check_DATE AS VARCHAR) + ', CheckNo_Text = ' + @Lc_SnfxCur_CheckNo_Text + ', Receipt_DATE = ' + CAST(@Ld_SnfxCur_Receipt_DATE AS VARCHAR) + ', Tanf_CODE = ' + @Lc_SnfxCur_Tanf_CODE + ', TaxJoint_CODE = ' + @Lc_SnfxCur_TaxJoint_CODE + ', TaxJoint_NAME = ' + @Lc_SnfxCur_TaxJoint_NAME + ', StatusReceipt_CODE = ' + @Lc_SnfxCur_StatusReceipt_CODE + ', ReasonStatus_CODE = ' + @Lc_SnfxCur_ReasonStatus_CODE + ', BackOut_INDC = ' + @Lc_SnfxCur_BackOut_INDC + ', ReasonBackOut_CODE = ' + @Lc_SnfxCur_ReasonBackOut_CODE + ', Release_DATE = ' + CAST(@Ld_SnfxCur_Release_DATE AS VARCHAR) + ', Refund_DATE = ' + CAST(@Ld_SnfxCur_Refund_DATE AS VARCHAR) + ', ReferenceIrs_IDNO = ' + @Lc_SnfxCur_ReferenceIrs_IDNO + ', RefundRecipient_ID = ' + @Lc_SnfxCur_RefundRecipient_ID + ', RefundRecipient_CODE = ' + @Lc_SnfxCur_RefundRecipient_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', Processed_INDC = ' + @Lc_SnfxCur_Processed_INDC;
       -- Update all the Records to SNAX that has been fetched in the Above
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNFX';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');
       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC;

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnax_CODE;
        END

       IF @Lc_SnfxCur_Processed_INDC NOT IN (@Lc_Processed_INDC)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1_SNAX';
         SET @Ls_Sqldata_TEXT = ' Batch_DATE = ' + ISNULL(CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR), '') + ', ReleasedFrom_CODE = ' + ISNULL(@Lc_SnfxCur_ReasonStatus_CODE, '') + ', HELD FOR = ' + ISNULL(@Lc_SnfxCur_Processed_INDC, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeqHold_NUMB AS VARCHAR), '');

        MERGE INTO RCTH_Y1 t USING (SELECT @Ld_SnfxCur_Batch_DATE Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB SeqReceipt_NUMB ) s ON ( t.Batch_DATE = s.Batch_DATE AND t.SourceBatch_CODE = s.SourceBatch_CODE AND t.Batch_NUMB = s.Batch_NUMB AND t.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND t.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB ) WHEN MATCHED THEN UPDATE SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_SnfxCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT ( Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, SourceReceipt_CODE, TypeRemittance_CODE, TypePosting_CODE, Case_IDNO, PayorMCI_IDNO, Receipt_AMNT, ToDistribute_AMNT, Fee_AMNT, Employer_IDNO, Fips_CODE, Check_DATE, CheckNo_Text, Receipt_DATE, Distribute_DATE, Tanf_CODE, TaxJoint_CODE, TaxJoint_NAME, StatusReceipt_CODE, ReasonStatus_CODE, BackOut_INDC, ReasonBackOut_CODE, Release_DATE, Refund_DATE, ReferenceIrs_IDNO, RefundRecipient_ID, RefundRecipient_CODE, BeginValidity_DATE, EndValidity_DATE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB) VALUES ( @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Ld_Low_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_SnfxCur_StatusReceipt_CODE, @Lc_SnfxCur_Processed_INDC, @Lc_Processed_INDC, @Lc_Space_TEXT,
        -- To check if the System Refund or Release indicator set
        -- for the UDC code
        (SELECT CASE WHEN ( AutomaticRelease_INDC = @Lc_Yes_INDC OR AutomaticRefund_INDC = @Lc_Yes_INDC ) THEN CASE NumDaysRefund_QNTY WHEN 0 THEN DATEADD(D, NumDaysHold_QNTY, @Ld_Run_DATE) ELSE DATEADD(D, NumDaysRefund_QNTY, @Ld_Run_DATE) END ELSE @Ld_High_DATE END FROM UCAT_Y1 WHERE Udc_CODE = @Lc_SnfxCur_Processed_INDC AND EndValidity_DATE = @Ld_High_DATE), @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ld_Run_DATE, @Ld_High_DATE, @Ln_EventGlobalSeqHold_NUMB, 0);
        END
      
      SET @Ls_Sql_TEXT = 'FETCH Snfx_CUR - 2';
      SET @Ls_Sqldata_TEXT = '';

      FETCH NEXT FROM Snfx_CUR INTO @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_SnfxCur_StatusReceipt_CODE, @Lc_SnfxCur_ReasonStatus_CODE, @Lc_SnfxCur_BackOut_INDC, @Lc_SnfxCur_ReasonBackOut_CODE, @Ld_SnfxCur_Release_DATE, @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ln_SnfxCur_EventGlobalBeginSeq_NUMB, @Lc_SnfxCur_Processed_INDC;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Snfx_CUR;

   DEALLOCATE Snfx_CUR;
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorSnfxCur_QNTY;
   
   SET @Ln_Holiday_NUMB = 0
   SET @Ls_Sql_TEXT = 'SELECT_STATE_HOLIDAY_COUNT FROM SHOL_Y1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   SELECT @Ln_Holiday_NUMB = COUNT(1) 
    FROM SHOL_Y1  s
    WHERE s.Holiday_DATE BETWEEN @Ld_Run_DATE AND DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0));
    
   /*
   This process retrieves all valid held receipts from the Receipt History (RHIS) Screen/RECEIPT (RCTH_Y1) 
   table and checks whether the hold code is still valid, if not the receipt is released.  A valid held 
   receipt is a receipt record with status = 'H' (held) associated with a UDC code specified in the UDC 
   Code Attributes (UCAT_Y1) table.	
   */
   SET @Ls_Sql_TEXT = 'SELECT_RCTH_Y1_ALL_HOLD';
   SET @Ls_Sqldata_TEXT = '';

   DECLARE Hold_CUR INSENSITIVE CURSOR FOR
    SELECT f.Batch_DATE,
           f.SourceBatch_CODE,
           f.Batch_NUMB,
           f.SeqReceipt_NUMB,
           f.SourceReceipt_CODE,
           f.TypeRemittance_CODE,
           f.TypePosting_CODE,
           f.Case_IDNO,
           f.PayorMCI_IDNO,
           f.Receipt_AMNT,
           f.ToDistribute_AMNT,
           f.Fee_AMNT,
           f.Employer_IDNO,
           f.Fips_CODE,
           f.Check_DATE,
           f.CheckNo_Text,
           f.Receipt_DATE,
           f.Tanf_CODE,
           f.TaxJoint_CODE,
           f.TaxJoint_NAME,
           f.StatusReceipt_CODE,
           f.ReasonStatus_CODE,
           f.BackOut_INDC,
           f.ReasonBackOut_CODE,
           f.Release_DATE,
           f.Refund_DATE,
           f.ReferenceIrs_IDNO,
           f.RefundRecipient_ID,
           f.RefundRecipient_CODE,
           f.EventGlobalBeginSeq_NUMB,
           @Lc_Processed_INDC
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.SourceReceipt_CODE,
                   a.TypeRemittance_CODE,
                   a.TypePosting_CODE,
                   a.Case_IDNO,
                   a.PayorMCI_IDNO,
                   a.Receipt_AMNT,
                   a.ToDistribute_AMNT,
                   a.Fee_AMNT,
                   a.Employer_IDNO,
                   a.Fips_CODE,
                   a.Check_DATE,
                   a.CheckNo_Text,
                   a.Receipt_DATE,
                   a.Tanf_CODE,
                   a.TaxJoint_CODE,
                   a.TaxJoint_NAME,
                   a.StatusReceipt_CODE,
                   a.ReasonStatus_CODE,
                   a.BackOut_INDC,
                   a.ReasonBackOut_CODE,
                   a.Release_DATE,
                   a.Refund_DATE,
                   a.ReferenceIrs_IDNO,
                   a.RefundRecipient_ID,
                   a.RefundRecipient_CODE,
                   a.EventGlobalBeginSeq_NUMB,
                   CASE
                    --Hold Reason : SHND – Invalid Receipt Source for Non-IV-D Case
                    --Conditions to Release : Change in IVD Case Type to other than Non IV-D
                    WHEN (a.ReasonStatus_CODE = @Lc_HoldReasonStatusShnd_CODE
                          AND (EXISTS (SELECT 1
                                         FROM CMEM_Y1 m,
                                              CASE_Y1 c
                                        WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                OR (m.Case_IDNO = a.Case_IDNO
                                                    AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                          AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                          AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                          AND m.Case_IDNO = c.Case_IDNO
                                          AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                          AND c.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE)
                                OR EXISTS (SELECT 1
                                             FROM HIMS_Y1 h
                                            WHERE a.SourceReceipt_CODE = h.SourceReceipt_CODE
                                              AND h.DistNonIvd_INDC = @Lc_Yes_INDC
                                              AND h.EndValidity_DATE = @Ld_High_DATE)))
                          -- Hold Reason : SNNA – NCP Not Active	
                          -- Conditions to Release : If NCP is active.                  
                          OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnna_CODE
                              AND EXISTS (SELECT 1
                                            FROM CMEM_Y1 m
                                           WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                   OR (m.Case_IDNO = a.Case_IDNO
                                                       AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                             AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
                          -- Hold Reason : SNNO – No Obligation  	
                          -- Conditions to Release : When the Obligation is created (not for Voluntary Receipts)                                   
                          --						   Check whether OBLE_Y1 Exists for the Case/Member
                          OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnno_CODE
                              AND EXISTS (SELECT 1
                                            FROM OBLE_Y1 o,
                                                 SORD_Y1 s,
                                                 CMEM_Y1 m,
                                                 CASE_Y1 c
                                           WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                   OR (m.Case_IDNO = a.Case_IDNO
                                                       AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                             AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                             AND
                                             -- To Check for the Existense of the obligation only on the Open Cases
                                             m.Case_IDNO = c.Case_IDNO
                                             AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                             AND m.Case_IDNO = o.Case_IDNO
                                             AND o.EndValidity_DATE = @Ld_High_DATE
                                             AND o.Case_IDNO = s.Case_IDNO
                                             AND s.EndValidity_DATE = @Ld_High_DATE
                                             AND ((a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                   AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)
                                                   OR a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE))))
                          -- Hold Reason : SNCL –Case Closed  	
                          -- Conditions to Release : Release if the case reopens or a new case is entered for the NCP.                                   
                          OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSncl_CODE
                              AND EXISTS (SELECT 1
                                            FROM CMEM_Y1 m,
                                                 CASE_Y1 s
                                           WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                   OR (m.Case_IDNO = a.Case_IDNO
                                                       AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                             AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                             AND m.Case_IDNO = s.Case_IDNO
                                             AND s.StatusCase_CODE = @Lc_CaseStatusOpen_CODE))
                          -- Hold Reason : SNPO – Future Dated Obligation  	
                          -- Conditions to Release : When Obligation's effective date reaches current date.                                                      
                          -- Check whether OBLE_Y1 Exists for the Case/Member for the Processing Date 
                          OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnpo_CODE
                              AND EXISTS (SELECT 1
                                            FROM CMEM_Y1 m,
                                                 OBLE_Y1 o,
                                                 SORD_Y1 s
                                           WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                   OR (m.Case_IDNO = a.Case_IDNO
                                                       AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                             AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                             AND m.Case_IDNO = o.Case_IDNO
                                             AND o.EndValidity_DATE = @Ld_High_DATE
                                             AND o.Case_IDNO = s.Case_IDNO
                                             AND s.EndValidity_DATE = @Ld_High_DATE
                                             AND CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(o.BeginObligation_DATE)-1),o.BeginObligation_DATE),101) >= CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(a.Receipt_DATE)-1),a.Receipt_DATE),101)
                                             AND ((a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                   AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)
                                                   OR a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE))))
                          -- Hold Reason : SNBN – System Hold Bond Payment
                          -- Conditions to Release : Release at the end of the month if unpaid MSO exists	                           
                          OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnbn_CODE
                              -- Check whether the Processing Date is Last Day of the Month
                              -- and there exists an Unpaid MSO
                              -- to release the Bond Receipts on Prior Friday when the Last Day of the Month 
                              -- Falls on a Weekend 
                              -- Calculate the difference in month's from '1900-01-01'
								--Get the DateTime of Now: GETDATE() -- 2013-12-13 10:50:00.667
								--Calculate the difference in month's from '1900-01-01': DATEDIFF(m, 0, GETDATE()) -- 1367
								--Add the difference to '1900-01-01' plus one extra month: DATEADD(m, DATEDIFF(m, 0, GETDATE())+1, 0) -- 2014-01-01 00:00:00.000
								--Remove one second: DATEADD(s, -1, DATEADD(m, DATEDIFF(m, 0, GETDATE())+1, 0)) -- 2013-12-31 23:59:59.000
								--SELECT GETDATE() Current_Date, DATEDIFF(m, 0, GETDATE())	,DATEADD(m, DATEDIFF(m, 0, GETDATE())+1, 0), DATEADD(s, -1, DATEADD(m, DATEDIFF(m, 0, GETDATE())+1, 0))
                              -- Start 
                              AND CAST(@Ld_Run_DATE AS DATE) =  CASE
															  WHEN UPPER(DATENAME (WEEKDAY,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0)))) = 'SATURDAY'
															   THEN CAST(DATEADD(dd,-(1 + @Ln_Holiday_NUMB),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0))) AS DATE)
															  WHEN UPPER(DATENAME (WEEKDAY,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0)))) = 'SUNDAY'
															   THEN CAST(DATEADD(dd,-(2 + @Ln_Holiday_NUMB),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0))) AS DATE)
															  ELSE CAST(DATEADD(dd,-(@Ln_Holiday_NUMB),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0))) AS DATE)
															 END
                              -- End 
                              AND (SELECT SUM(l.MtdCurSupOwed_AMNT - l.AppTotCurSup_AMNT)
                                     FROM LSUP_Y1 l,
                                          CMEM_Y1 m
                                    WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                            AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                            OR (m.Case_IDNO = a.Case_IDNO
                                                AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                      AND m.Case_IDNO = l.Case_IDNO
                                      AND l.SupportYearMonth_NUMB = (SELECT MAX(p.SupportYearMonth_NUMB)
                                                                       FROM LSUP_Y1 p
                                                                      WHERE p.Case_IDNO = l.Case_IDNO
                                                                        AND p.OrderSeq_NUMB = l.OrderSeq_NUMB
                                                                        AND p.ObligationSeq_NUMB = l.ObligationSeq_NUMB)
                                      AND l.EventGlobalSeq_NUMB = (SELECT MAX(s.EventGlobalSeq_NUMB)
                                                                     FROM LSUP_Y1 s
                                                                    WHERE s.Case_IDNO = l.Case_IDNO
                                                                      AND s.OrderSeq_NUMB = l.OrderSeq_NUMB
                                                                      AND s.ObligationSeq_NUMB = l.ObligationSeq_NUMB
                                                                      AND s.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB)) > 0)
                          -- Hold Reason : SNLE – System Hold FIDM 	
                          -- Conditions to Release : Based on activity chain	                                                                      
                          OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnle_CODE
                              -- Check whether Activity has been resolved for all the Cases of the Payor
                              AND (SELECT SUM(CASE
                                               WHEN n.ActivityMinor_CODE = @Lc_ActivityMinorMorfd_CODE
                                                THEN 0
                                               ELSE 1
                                              END) release_ind
                                     FROM CMEM_Y1 m,
                                          DMNR_Y1 n
                                    WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
                                      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                      AND m.Case_IDNO = n.Case_IDNO
                                      AND n.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
                                      AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
                                      AND n.MinorIntSeq_NUMB = (SELECT MAX(b.MinorIntSeq_NUMB)
                                                                  FROM DMNR_Y1 b
                                                                 WHERE n.Case_IDNO = b.Case_IDNO
                                                                   AND n.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                                   AND n.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB)) = 0)
                          -- Hold Reason : SNQR – System Hold Potential QDRO  	
                          -- Conditions to Release : If for EW, UC and DB receipt sources there are NO cases with a QDRO indicator
						  -- If for QR receipt source there are cases with a QDRO indicator
						  OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnqr_CODE
							  AND a.SourceReceipt_CODE IN (@Lc_SourceReceiptEmployerWage_CODE, @Lc_SourceReceiptUnemplComp_CODE, @Lc_SourceReceiptDisabilityIns_CODE)
							  -- If for EW, UC and DB receipt sources there are NO cases with a QDRO indicator
							  AND NOT EXISTS (SELECT 1 
														FROM CMEM_Y1 C,SORD_Y1 s 
													WHERE a.PayorMci_IDNO = C.MemberMci_IDNO
													AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
													AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
													AND c.Case_IDNO = s.Case_IDNO
													AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
													AND s.EndValidity_DATE = @Ld_High_DATE
													AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
													AND s.Qdro_INDC = @Lc_Yes_INDC))
								  -- If for QR receipt source there are cases with a QDRO indicator
								  OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnqr_CODE
									  AND a.SourceReceipt_CODE = @Lc_SourceReceiptQdro_CODE
									  AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE
									  AND EXISTS (SELECT 1
														FROM SORD_Y1 s
													   WHERE a.Case_IDNO = s.Case_IDNO
														 AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
														 AND s.EndValidity_DATE = @Ld_High_DATE
														 AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
														 AND s.Qdro_INDC = @Lc_Yes_INDC))
								  OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnqr_CODE
									  AND a.SourceReceipt_CODE = @Lc_SourceReceiptQdro_CODE
									  AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE 
									  AND EXISTS (SELECT 1 
														FROM CMEM_Y1 C,SORD_Y1 s 
													WHERE a.PayorMci_IDNO = C.MemberMci_IDNO
													AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
													AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
													AND c.Case_IDNO = s.Case_IDNO
													AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
													AND s.EndValidity_DATE = @Ld_High_DATE
													AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
													AND s.Qdro_INDC = @Lc_Yes_INDC))
								-- Hold Reason : SNSQ – System Hold Potential QDRO  	
								-- Conditions to Release : If the receipt source is 'SQ-SEQUESTRATION LEVY', the batch process checks if the at least one 
								-- of the Payor's cases has an active Sequestration Order Activity chain exists in active state.
								-- If for SQ receipt source there are cases with an active Sequestration Order Activity chain exists in active state
								  OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnsq_CODE
									  AND a.SourceReceipt_CODE = @Lc_ReceiptSrcSequestrationLevySQ_CODE
									  AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE
									  AND EXISTS (SELECT 1
														FROM DMJR_Y1 n
													   WHERE a.Case_IDNO = n.Case_IDNO
														 AND n.ActivityMajor_CODE = @Lc_ActivityMajorSeqo_CODE
														 AND n.Status_CODE IN (@Lc_RemedyStatusStart_CODE, @Lc_RemedyStatusComp_CODE)))
								  OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnsq_CODE
									  AND a.SourceReceipt_CODE = @Lc_ReceiptSrcSequestrationLevySQ_CODE
									  AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE 
									  AND EXISTS (SELECT 1 
														FROM CMEM_Y1 m,DMJR_Y1 n 
													WHERE m.MemberMci_IDNO = n.MemberMci_IDNO
													AND m.MemberMci_IDNO = a.PayorMCI_IDNO
													AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
													AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
													AND m.Case_IDNO = n.Case_IDNO
													AND n.ActivityMajor_CODE = @Lc_ActivityMajorSeqo_CODE
													AND n.Status_CODE IN (@Lc_RemedyStatusStart_CODE, @Lc_RemedyStatusComp_CODE))
													)	
							-- SNWG - WAGE RECEIVED - ALL CASES ARE INITIATING												
							-- Conditions to Release : Wage receipt (EW) will be relased if all the NCP’s cases are not Initiating
							OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnwg_CODE
									  AND a.SourceReceipt_CODE = @Lc_SourceReceiptEmployerWage_CODE
									  AND EXISTS (SELECT 1 
														FROM CMEM_Y1 m,
														CASE_Y1 b
												  WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
													AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
													AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
													AND m.Case_IDNO = b.Case_IDNO
													AND b.RespondInit_CODE  IN (@Lc_RespondInitN_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitR_CODE,@Lc_RespondInitS_CODE)
													AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE)
													)		
																									
                             OR (a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnwc_CODE
                              -- Hold Reason : SNWC – System Hold CSLN
                              -- Conditions to Release : Based on activity chain .
                              AND (SELECT SUM(CASE
                                               WHEN n.ActivityMinor_CODE IN (@Lc_ActivityMinorRfins_CODE, @Lc_ActivityMinorRsifc_CODE)
                                                THEN 0
                                               ELSE 1
                                              END) release_ind
                                     FROM CMEM_Y1 m,
                                          DMNR_Y1 n
                                    WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
                                      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                      AND m.Case_IDNO = n.Case_IDNO
                                      AND n.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
                                      AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
                                      AND n.MinorIntSeq_NUMB = (SELECT MAX(b.MinorIntSeq_NUMB)
                                                                  FROM DMNR_Y1 b
                                                                 WHERE n.Case_IDNO = b.Case_IDNO
                                                                   AND n.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                                   AND n.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB)) = 0)
                          OR (a.Release_DATE <= @Ld_Run_DATE
                              -- Hold Reason : For all other other than below UDC Codes that have the system release indicator set as 'Y'.
                              -- Conditions to Release : Check whether the release date is as of the processing date.
                              AND a.ReasonStatus_CODE NOT IN (@Lc_HoldReasonStatusShnd_CODE, @Lc_HoldReasonStatusSnna_CODE, @Lc_HoldReasonStatusSnno_CODE, @Lc_HoldReasonStatusSncl_CODE,
                                                              @Lc_HoldReasonStatusSnpo_CODE, @Lc_HoldReasonStatusSnbn_CODE, @Lc_HoldReasonStatusSnle_CODE, @Lc_HoldReasonStatusSnwc_CODE,
                                                              @Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE, @Lc_HoldReasonStatusSnqr_CODE,@Lc_HoldReasonStatusSnsq_CODE,
                                                              @Lc_HoldReasonStatusSnwg_CODE)
                              AND EXISTS (SELECT 1
                                            FROM UCAT_Y1 u
                                           WHERE u.Udc_CODE = a.ReasonStatus_CODE
                                             AND u.AutomaticRelease_INDC = @Lc_Yes_INDC
                                             AND u.AutomaticRefund_INDC = @Lc_Processed_INDC
                                             AND u.EndValidity_DATE = @Ld_High_DATE))
                          -- Hold Reason : SNFX – System hold futures, SNAX – Arrears paid in full – arrears only case	
                          -- Conditions to Release : Monthly support order charges
                          -- SNAX – Arrears paid in full – arrears only case	
                          -- Conditions to Release : Release when balances exist.
                          OR ((a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)) AND a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptEmployerWage_CODE,@Lc_SourceReceiptUnemplComp_CODE,@Lc_SourceReceiptDisabilityIns_CODE)
                              -- Check whether exists any Arrears for the Case/Payor
                              AND ((a.TypePosting_CODE = @Lc_TypePostingCase_CODE
                                    AND ((a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                          AND (dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(a.Case_IDNO, @Ld_Run_DATE) > 0
                                                -- Calculate the Unpaid MSO for the Case
                                                OR dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO(a.Case_IDNO) > 0))
                                          OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                              AND EXISTS (SELECT 1
                                                            FROM SORD_Y1 s
                                                           WHERE a.Case_IDNO = s.Case_IDNO
                                                             AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                                                             AND s.EndValidity_DATE = @Ld_High_DATE
                                                             AND (dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(a.Case_IDNO, @Ld_Run_DATE) > 0
                                                                   -- Calculate the Unpaid MSO for the Case
                                                                   OR dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO(a.Case_IDNO) > 0))))
                                       AND EXISTS (SELECT 1 
														FROM CASE_Y1 c
													   WHERE c.Case_IDNO = a.Case_IDNO
								   						AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE ))
                                    OR (a.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                                        AND EXISTS (SELECT 1
                                                      FROM CMEM_Y1 m,
                                                           SORD_Y1 s,
                                                           CASE_Y1 c
                                                     WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                       AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                       AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                       AND m.Case_IDNO = s.Case_IDNO
                                                       AND m.Case_IDNO = c.Case_IDNO
                                                       AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE 
                                                       AND s.EndValidity_DATE = @Ld_High_DATE
                                                       AND (dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(m.Case_IDNO, @Ld_Run_DATE) > 0
                                                             -- Added to calculate the Unpaid MSO for the Case
                                                             OR dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO(m.Case_IDNO) > 0)
                                                       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                                 AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE))))))
                                                                 
                                                                 
                      OR ((a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)) AND a.SourceReceipt_CODE IN (@Lc_SourceReceiptEmployerWage_CODE,@Lc_SourceReceiptUnemplComp_CODE,@Lc_SourceReceiptDisabilityIns_CODE)
                              -- Check whether exists any Arrears for the Case/Payor
                              AND ((a.TypePosting_CODE = @Lc_TypePostingCase_CODE
                                    AND ((a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                          AND (dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(a.Case_IDNO, @Ld_Run_DATE) > 0
                                                -- Calculate the Unpaid MSO for the Case
                                                OR dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO(a.Case_IDNO) > 0))
                                          OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                              AND EXISTS (SELECT 1
                                                            FROM SORD_Y1 s
                                                           WHERE a.Case_IDNO = s.Case_IDNO
                                                             AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
                                                             AND s.EndValidity_DATE = @Ld_High_DATE
                                                             AND (dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(a.Case_IDNO, @Ld_Run_DATE) > 0
                                                                   -- Calculate the Unpaid MSO for the Case
                                                                   OR dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO(a.Case_IDNO) > 0))))
                                       AND EXISTS (SELECT 1 
														FROM CASE_Y1 c
													   WHERE c.Case_IDNO = a.Case_IDNO
								   						AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE 
								   						AND NOT EXISTS (SELECT 1
                                                                    FROM  DMJR_Y1 b 
                                                                   WHERE  b.Case_IDNO = c.Case_IDNO 
                                                                     AND  b.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE 
                                                                     AND  b.Status_CODE = @Lc_StatusExmt_CODE
                                                                     AND @Ld_Run_DATE BETWEEN BeginExempt_DATE AND EndExempt_DATE)

								   						))
                                    OR (a.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                                        AND EXISTS (SELECT 1
                                                      FROM CMEM_Y1 m,
                                                           SORD_Y1 s,
                                                           CASE_Y1 c
                                                     WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                       AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                       AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                       AND m.Case_IDNO = s.Case_IDNO
                                                       AND m.Case_IDNO = c.Case_IDNO
                                                       AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE 
                                                       AND NOT EXISTS (SELECT 1
                                                                    FROM  DMJR_Y1 b 
                                                                   WHERE  b.Case_IDNO = c.Case_IDNO 
                                                                     AND  b.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE 
                                                                     AND  b.Status_CODE = @Lc_StatusExmt_CODE
                                                                     AND @Ld_Run_DATE BETWEEN BeginExempt_DATE AND EndExempt_DATE)
                                                       AND s.EndValidity_DATE = @Ld_High_DATE
                                                       AND (dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_LATEST_ARREARS(m.Case_IDNO, @Ld_Run_DATE) > 0
                                                             -- Added to calculate the Unpaid MSO for the Case
                                                             OR dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_UNPAID_MSO(m.Case_IDNO) > 0)
                                                       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                                 AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE))))))                                           
                                                                 
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_Processed_INDC
                   END ind_flag
              FROM RCTH_Y1 a
             WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
               AND (a.SourceReceipt_CODE <> @Lc_SourceReceiptVoluntary_CODE
                     -- Voluntary Receipts that are held with the UDC Code other than SNNO should be released by this Process
                     OR (a.SourceReceipt_CODE = @Lc_SourceReceiptVoluntary_CODE
                         AND a.ReasonStatus_CODE <> @Lc_HoldReasonStatusSnno_CODE))
               -- 'CR','CF' receipt types processing 
               AND a.ReasonStatus_CODE NOT IN (@Lc_HoldReasonStatusShcr_CODE,@Lc_HoldReasonStatusShcp_CODE)
               AND a.EndValidity_DATE = @Ld_High_DATE
               AND a.Distribute_DATE = @Ld_Low_DATE
               AND EXISTS (SELECT 1
                             FROM UCAT_Y1 u
                            WHERE a.ReasonStatus_CODE = u.Udc_CODE
                              AND u.AutomaticRelease_INDC = @Lc_Yes_INDC
                              AND u.EndValidity_DATE = @Ld_High_DATE)) f
     WHERE f.ind_flag = @Lc_Yes_INDC;

   SET @Ls_Sql_TEXT = 'DELETE_TMP_RELEASE_RECEIPT';
   SET @Ls_Sqldata_TEXT = '';

   DELETE PRREL_Y1;

   SET @Ls_Sql_TEXT = 'OPEN Hold_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Hold_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Hold_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Hold_CUR INTO @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_SnfxCur_StatusReceipt_CODE, @Lc_SnfxCur_ReasonStatus_CODE, @Lc_SnfxCur_BackOut_INDC, @Lc_SnfxCur_ReasonBackOut_CODE, @Ld_SnfxCur_Release_DATE, @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ln_SnfxCur_EventGlobalBeginSeq_NUMB, @Lc_SnfxCur_Processed_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   
   BEGIN
    -- Hold Cursor started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
       SET @Ln_CursorHoldCur_QNTY = @Ln_CursorHoldCur_QNTY + 1;
       SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SnfxCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceReceipt_CODE = ' + @Lc_SnfxCur_SourceReceipt_CODE + ', TypeRemittance_CODE = ' + @Lc_SnfxCur_TypeRemittance_CODE + ', TypePosting_CODE = ' + @Lc_SnfxCur_TypePosting_CODE + ', Case_IDNO = ' + CAST(@Ln_SnfxCur_Case_IDNO AS VARCHAR) + ', Payor_IDNO = ' + CAST(@Ln_SnfxCur_Payor_IDNO AS VARCHAR) + ', Receipt_AMNT = ' + CAST(@Ln_SnfxCur_Receipt_AMNT AS VARCHAR) + ', ToDistribute_AMNT = ' + CAST(@Ln_SnfxCur_ToDistribute_AMNT AS VARCHAR) + ', Fee_AMNT = ' + CAST(@Ln_SnfxCur_Fee_AMNT AS VARCHAR) + ', Employer_IDNO = ' + CAST (@Ln_SnfxCur_Employer_IDNO AS VARCHAR) + ', Fips_CODE = ' + @Lc_SnfxCur_Fips_CODE + ', Check_DATE = ' + CAST(@Ld_SnfxCur_Check_DATE AS VARCHAR) + ', CheckNo_Text = ' + @Lc_SnfxCur_CheckNo_Text + ', Receipt_DATE = ' + CAST(@Ld_SnfxCur_Receipt_DATE AS VARCHAR) + ', Tanf_CODE = ' + @Lc_SnfxCur_Tanf_CODE + ', TaxJoint_CODE = ' + @Lc_SnfxCur_TaxJoint_CODE + ', TaxJoint_NAME = ' + @Lc_SnfxCur_TaxJoint_NAME + ', StatusReceipt_CODE = ' + @Lc_SnfxCur_StatusReceipt_CODE + ', ReasonStatus_CODE = ' + @Lc_SnfxCur_ReasonStatus_CODE + ', BackOut_INDC = ' + @Lc_SnfxCur_BackOut_INDC + ', ReasonBackOut_CODE = ' + @Lc_SnfxCur_ReasonBackOut_CODE + ', Release_DATE = ' + CAST(@Ld_SnfxCur_Release_DATE AS VARCHAR) + ', Refund_DATE = ' + CAST(@Ld_SnfxCur_Refund_DATE AS VARCHAR) + ', ReferenceIrs_IDNO = ' + @Lc_SnfxCur_ReferenceIrs_IDNO + ', RefundRecipient_ID = ' + @Lc_SnfxCur_RefundRecipient_ID + ', RefundRecipient_CODE = ' + @Lc_SnfxCur_RefundRecipient_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', Processed_INDC = ' + @Lc_SnfxCur_Processed_INDC;
       /*
       Check whether the case is closed, if so put it on "SNCL - Cases Closed" 
       if it is an IRS Receipt then put it on "SNCC - IRS Hold Case Closed" hold.
       */
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNCL_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'');

       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND NOT EXISTS (SELECT 1
                            FROM CASE_Y1 s
                           WHERE @Ln_SnfxCur_Case_IDNO = s.Case_IDNO
                             AND @Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingCase_CODE
                             AND s.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          UNION ALL
                          SELECT 1
                            FROM CMEM_Y1 c,
                                 CASE_Y1 s
                           WHERE @Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingPayor_CODE
                             AND c.MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                             AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                             AND c.Case_IDNO = s.Case_IDNO
                             AND s.StatusCase_CODE = @Lc_CaseStatusOpen_CODE);

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnax_CODE;

         IF @Lc_SnfxCur_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
          BEGIN
           SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSncc_CODE;
          END
         ELSE
          BEGIN
           SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSncl_CODE;
          END
        END

       -- Check whether the NCP is active, if not put it on "SNNA - NCP Not Active" hold.	
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNNA_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'');

       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND EXISTS (SELECT 1
                        FROM CMEM_Y1 m
                       WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                         AND @Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingPayor_CODE
                         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                         AND CaseMemberStatus_CODE NOT IN (@Lc_CaseMemberStatusActive_CODE, @Lc_CaseRelationshipExcluded_CODE)
                         AND NOT EXISTS (SELECT 1
                                           FROM CMEM_Y1 x
                                          WHERE m.MemberMci_IDNO = x.MemberMci_IDNO
                                            AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                            AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
                      UNION ALL
                      SELECT 1
                        FROM CMEM_Y1 m
                       WHERE Case_IDNO = @Ln_SnfxCur_Case_IDNO
						 AND MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                         AND @Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingCase_CODE
                         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                         AND CaseMemberStatus_CODE NOT IN (@Lc_CaseMemberStatusActive_CODE, @Lc_CaseRelationshipExcluded_CODE));

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnna_CODE;
        END

       -- Check whether there exists any obligation for the NCP/Case, if not, put it on "SNNO - No Obligation."
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNNO_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND ((@Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingPayor_CODE
                AND NOT EXISTS (SELECT 1
                                  FROM CMEM_Y1 m,
                                       OBLE_Y1 o,
                                       SORD_Y1 s
                                 WHERE m.MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                   AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                   AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                   AND m.Case_IDNO = s.Case_IDNO
                                   AND s.EndValidity_DATE = @Ld_High_DATE
                                   AND ((@Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                         AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)
                                         OR @Lc_SnfxCur_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE))
                                   AND s.Case_IDNO = o.Case_IDNO
                                   AND o.EndValidity_DATE = @Ld_High_DATE))
                OR (@Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingCase_CODE
                    AND NOT EXISTS (SELECT 1
                                      FROM OBLE_Y1 o,
                                           SORD_Y1 s
                                     WHERE o.Case_IDNO = @Ln_SnfxCur_Case_IDNO
                                       AND o.Case_IDNO = s.Case_IDNO
                                       AND s.EndValidity_DATE = @Ld_High_DATE
                                       AND ((@Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                             AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)
                                             OR @Lc_SnfxCur_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE))
                                       AND s.Case_IDNO = o.Case_IDNO
                                       AND o.EndValidity_DATE = @Ld_High_DATE)));

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnno_CODE;
        END
        
	   /* SNQR held receipts with Posting type “P” in RCTH table and check case level hold 
	   (SHCS - CASE SPECIFIC RECEIPT HOLD) in HIMS_Y1 table for the ‘QR’ receipt source. If there is a 
	   hold instruction for QR receipt source, then place the receipt on ‘SHCS’ hold for the number 
	   of calendar days identified in the (HIMS_Y1, UCAT_Y1) table
	   */
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNQR_SHCS_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_HoldReasonStatusSnqr_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceiptQdro_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePostingPayor_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Qdro_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

       UPDATE a
       SET a.EndValidity_DATE = @Ld_Run_DATE,
		   a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
       FROM RCTH_Y1 a
        WHERE a.Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND a.SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND a.Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND a.SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND a.EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnqr_CODE
          AND a.SourceReceipt_CODE = @Lc_SourceReceiptQdro_CODE
          AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE
          AND EXISTS (SELECT 1 FROM CMEM_Y1 C,SORD_Y1 s 
					  WHERE a.PayorMci_IDNO = C.MemberMci_IDNO
						AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
						AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
						AND c.Case_IDNO = s.Case_IDNO
						AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
						AND s.EndValidity_DATE = @Ld_High_DATE
						AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
						AND s.Qdro_INDC = @Lc_Yes_INDC)
		AND EXISTS (SELECT 1 FROM HIMS_Y1 h
					WHERE h.SourceReceipt_CODE = @Lc_SourceReceiptQdro_CODE
					  AND h.CaseHold_INDC = @Lc_Yes_INDC
					  AND h.EndValidity_DATE = @Ld_High_DATE);
																                             
       
       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusShcs_CODE;
        END
		              
               
       /* 
	   If Sequestration Order Activity chain exists in active state exists for any of the Payor's cases then the SQ receipt is 
	   put on 'SHCS - CASE SPECIFIC RECEIPT HOLD' hold
	   */
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNSQ_SHCS_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_HoldReasonStatusSnqr_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceiptQdro_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePostingPayor_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Qdro_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
	   
	   UPDATE a
       SET a.EndValidity_DATE = @Ld_Run_DATE,
		   a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
       FROM RCTH_Y1 a
        WHERE a.Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND a.SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND a.Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND a.SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND a.EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnsq_CODE
          AND a.SourceReceipt_CODE = @Lc_ReceiptSrcSequestrationLevySQ_CODE
          AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE
          AND EXISTS (SELECT 1
						 FROM CMEM_Y1 m,
							  DMJR_Y1 n
						WHERE m.MemberMci_IDNO = a.PayorMCI_IDNO
						  AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
						  AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
						  AND m.Case_IDNO = n.Case_IDNO
						  AND n.ActivityMajor_CODE = @Lc_ActivityMajorSeqo_CODE
						  AND n.Status_CODE IN (@Lc_RemedyStatusStart_CODE, @Lc_RemedyStatusComp_CODE))
		
       
       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusShcs_CODE;
        END        
                		
       -- Check whether there exists a future obligation for the NCP/Case, if so put it on "SNPO - Future Dated Obligation."	
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNPO_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND ((@Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingPayor_CODE
                AND DATEADD(d,1, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0))) <= (SELECT MIN (BeginObligation_DATE)
                                                                                                                   FROM OBLE_Y1 o,
                                                                                                                        SORD_Y1 s,
                                                                                                                        CMEM_Y1 m
                                                                                                                  WHERE m.MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                                                                                                    AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                                                                                    AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                                                                                    AND m.Case_IDNO = o.Case_IDNO
                                                                                                                    AND o.EndValidity_DATE = @Ld_High_DATE
                                                                                                                    AND o.Case_IDNO = s.Case_IDNO
                                                                                                                    AND s.EndValidity_DATE = @Ld_High_DATE
                                                                                                                    AND ((@Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                                                                                          AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)
                                                                                                                          OR @Lc_SnfxCur_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE))))
                OR (@Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingCase_CODE
                    AND DATEADD(d,1, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ld_Run_DATE)+1,0))) <= (SELECT MIN (BeginObligation_DATE)
                                                                                                                       FROM OBLE_Y1 o,
                                                                                                                            SORD_Y1 s
                                                                                                                      WHERE o.Case_IDNO = @Ln_SnfxCur_Case_IDNO
                                                                                                                        AND o.EndValidity_DATE = @Ld_High_DATE
                                                                                                                        AND o.Case_IDNO = s.Case_IDNO
                                                                                                                        AND s.EndValidity_DATE = @Ld_High_DATE
                                                                                                                        AND ((@Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                                                                                                                              AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE)
                                                                                                                              OR @Lc_SnfxCur_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)))));

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnpo_CODE;
        END
       /*
       Check whether there exists certification for the case if it is an IRS receipt, if not put
       it on "SNIN - No Certification SPC Individual with arrears' or 'SNIO - No Certification SPC IRS Individual without arrears' 
       if it is an IRS Individual Receipt or "SNJN - No Certification SPC IRS Joint with arrears" 
       and 'SNJO - No Certification SPC Joint without arrears' if it's an IRS Joint Receipt."
       */
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SNIN_SNSN_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', RejectInd_INDC = ' + ISNULL(@Lc_Processed_INDC,'')+ ', RejectInd_INDC = ' + ISNULL(@Lc_Processed_INDC,'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', RejectInd_INDC = ' + ISNULL(@Lc_Processed_INDC,'')+ ', RejectInd_INDC = ' + ISNULL(@Lc_Processed_INDC,'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'');

       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          -- To refer IFMS_Y1 and ISTX_Y1 to identify whether the Case is Certified for IRS and State Tax Receipts 
          -- instead of CASE_Y1 - Intercept_CODE
          AND @Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
          AND ((@Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingPayor_CODE
                AND ((@Lc_SnfxCur_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
                      AND NOT EXISTS (SELECT 1
                                        FROM FEDH_Y1 f
                                       WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                         AND TypeTransaction_CODE IN ('A', 'M')
                                         AND SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                         AND RejectInd_INDC = @Lc_Processed_INDC
                                         AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                                           FROM FEDH_Y1 h
                                                                          WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                            AND h.SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                                                            AND TypeTransaction_CODE IN ('A', 'M')
                                                                            AND RejectInd_INDC = @Lc_Processed_INDC
                                                                            AND f.TypeArrear_CODE = h.TypeArrear_CODE)
                                      UNION
                                      SELECT 1
                                        FROM HFEDH_Y1 f
                                       WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                         AND TypeTransaction_CODE IN ('A', 'M')
                                         AND SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                         AND RejectInd_INDC = @Lc_Processed_INDC
                                         AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                                           FROM HFEDH_Y1 h
                                                                          WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                            AND h.SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                                                            AND TypeTransaction_CODE IN ('A', 'M')
                                                                            AND RejectInd_INDC = @Lc_Processed_INDC
                                                                            AND f.TypeArrear_CODE = h.TypeArrear_CODE)))
                      OR (@Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptStateTaxRefund_CODE)
                          AND NOT EXISTS (SELECT 1
                                            FROM SLST_Y1 f
                                           WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                             AND TypeTransaction_CODE IN ('L', 'P')
                                             AND SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                             AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                                               FROM SLST_Y1 h
                                                                              WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                                AND h.TypeTransaction_CODE IN ('L', 'P')
                                                                                AND h.SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE)))))
                OR (@Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingCase_CODE
                    AND ((@Lc_SnfxCur_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
                          AND NOT EXISTS (SELECT 1
                                            FROM IFMS_Y1 f
                                           WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                             AND Case_IDNO = @Ln_SnfxCur_Case_IDNO
                                             AND TypeTransaction_CODE IN ('A', 'M')
                                             AND SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                             AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                                               FROM IFMS_Y1 h
                                                                              WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                                AND f.Case_IDNO = h.Case_IDNO
                                                                                AND h.SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                                                                AND TypeTransaction_CODE IN ('A', 'M')
                                                                                AND f.TypeArrear_CODE = h.TypeArrear_CODE)
                                          UNION
                                          SELECT 1
                                            FROM HIFMS_Y1 f
                                           WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                             AND Case_IDNO = @Ln_SnfxCur_Case_IDNO
                                             AND TypeTransaction_CODE IN ('A', 'M')
                                             AND SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                             AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                                               FROM HIFMS_Y1 h
                                                                              WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                                AND f.Case_IDNO = h.Case_IDNO
                                                                                AND h.SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                                                                AND TypeTransaction_CODE IN ('A', 'M')
                                                                                AND f.TypeArrear_CODE = h.TypeArrear_CODE)))
                          OR (@Lc_SnfxCur_SourceReceipt_CODE IN (@Lc_SourceReceiptStateTaxRefund_CODE)
                              AND NOT EXISTS (SELECT 1
                                                FROM ISTX_Y1 f
                                               WHERE MemberMci_IDNO = @Ln_SnfxCur_Payor_IDNO
                                                 AND Case_IDNO = @Ln_SnfxCur_Case_IDNO
                                                 AND TypeTransaction_CODE IN ('L', 'P')
                                                 AND SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE
                                                 AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                                                   FROM SLST_Y1 h
                                                                                  WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                                    AND h.TypeTransaction_CODE IN ('L', 'P')
                                                                                    AND h.SubmitLast_DATE < @Ld_SnfxCur_Receipt_DATE))))));

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_RELEASE_RECEIPT$SF_GET_CASEPAYOR_ARREARS';
         SET @Ls_Sqldata_TEXT = 'Payor_IDNO = ' + CAST(@Ln_SnfxCur_Payor_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_SnfxCur_Case_IDNO AS VARCHAR) + ', TypePosting_CODE = ' + @Lc_SnfxCur_TypePosting_CODE + ', @Ld_Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
         SET @Ln_Arrear_AMNT = dbo.BATCH_FIN_RELEASE_RECEIPT$SF_GET_CASEPAYOR_ARREARS(@Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Case_IDNO, @Lc_SnfxCur_TypePosting_CODE, @Ld_Run_DATE);
         IF @Lc_SnfxCur_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
          BEGIN
           IF @Lc_SnfxCur_TaxJoint_CODE = @Lc_IrsividualFiling_INDC
            BEGIN
             IF @Ln_Arrear_AMNT > 0
              BEGIN
               SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnin_CODE;
              END
             ELSE
              BEGIN
               SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnio_CODE;
              END
            END
           ELSE
            BEGIN
             IF @Lc_SnfxCur_TaxJoint_CODE = @Lc_IrsJointFiling_TEXT
              BEGIN
               IF @Ln_Arrear_AMNT > 0
                BEGIN
                 SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnjn_CODE;
                END
               ELSE
                BEGIN
                 SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnjo_CODE;
                END
              END
             ELSE
              BEGIN
               IF @Ln_Arrear_AMNT > 0
                BEGIN
                 SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnin_CODE;
                END
               ELSE
                BEGIN
                 SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusSnio_CODE;
                END
              END
            END
          END
         ELSE
          BEGIN
           SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldStateNoCert_CODE;
          END
        END

       -- Change in IVD Case Type to other than Non IV-D	
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_SHND';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SnfxCur_SourceReceipt_CODE,'')+ ', DistNonIvd_INDC = ' + ISNULL(@Lc_Processed_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeNonIvd_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'');

       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND EXISTS (SELECT 1
                        FROM HIMS_Y1 h
                       WHERE h.SourceReceipt_CODE = @Lc_SnfxCur_SourceReceipt_CODE
                         AND h.DistNonIvd_INDC = @Lc_Processed_INDC
                         AND h.EndValidity_DATE = @Ld_High_DATE)
          AND (SELECT SUM (CASE
                            WHEN c.TypeCase_CODE = @Lc_CaseTypeNonIvd_CODE
                             THEN 0
                            ELSE 1
                           END)
                 FROM CMEM_Y1 m,
                      CASE_Y1 c
                WHERE ((@Ln_SnfxCur_Payor_IDNO = m.MemberMci_IDNO
                        AND @Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                        OR (@Ln_SnfxCur_Case_IDNO = m.Case_IDNO
                            AND @Lc_SnfxCur_TypePosting_CODE = @Lc_TypePostingCase_CODE))
                  AND m.Case_IDNO = c.Case_IDNO
                  AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                  AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                  AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE) = 0;

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Lc_SnfxCur_Processed_INDC = @Lc_HoldReasonStatusShnd_CODE;
        END

       -- Check for DISH Hold	
       SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_DISH_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', CasePayorMCI_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Payor_IDNO AS VARCHAR ),'')+ ', CasePayorMCI_IDNO = ' + ISNULL(CAST( @Ln_SnfxCur_Case_IDNO AS VARCHAR ),'')+ ', SourceHold_CODE = ' + ISNULL(@Lc_SourceReceiptDh_CODE,'')+ ', SourceHold_CODE = ' + ISNULL(@Lc_SnfxCur_SourceReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       UPDATE RCTH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB
        WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
          AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
          AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB
          AND @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC
          AND EXISTS (SELECT 1
                        FROM (SELECT CASE d.SourceHold_CODE
                                      WHEN @Lc_SourceReceiptDh_CODE
                                       THEN 2
                                      ELSE 1
                                     END priority,
                                     d.Expiration_DATE,
                                     d.ReasonHold_CODE Udc_CODE
                                FROM DISH_Y1 d
                               WHERE ( (d.CasePayorMCI_IDNO = @Ln_SnfxCur_Payor_IDNO
										AND TypeHold_CODE = @Lc_TypePostingPayor_CODE)
                                       OR (d.CasePayorMCI_IDNO = @Ln_SnfxCur_Case_IDNO
											AND TypeHold_CODE = @Lc_TypePostingCase_CODE
											)
                                       )
                                 AND @Lc_SnfxCur_ReasonStatus_CODE <> d.ReasonHold_CODE
                                 AND (d.SourceHold_CODE = @Lc_SourceReceiptDh_CODE
                                       OR d.SourceHold_CODE = @Lc_SnfxCur_SourceReceipt_CODE)
                                 AND d.Effective_DATE <= @Ld_Run_DATE
                                 AND d.Expiration_DATE > @Ld_Run_DATE
                                 AND d.EndValidity_DATE = @Ld_High_DATE) fci);

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 1
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_RCTH_Y1_DISH_HOLD - 1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SnfxCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceReceipt_CODE = ' + @Lc_SnfxCur_SourceReceipt_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', Processed_INDC = ' + @Lc_Processed_INDC;
         SELECT @Lc_SnfxCur_Processed_INDC = Udc_CODE
           FROM (SELECT TOP (1) f.Udc_CODE
                   FROM (SELECT TOP 1 CASE d.SourceHold_CODE
                                       WHEN @Lc_SourceReceiptDh_CODE
                                        THEN 2
                                       ELSE 1
                                      END priority,
                                      d.Expiration_DATE,
                                      d.ReasonHold_CODE Udc_CODE
                           FROM DISH_Y1 d
                           WHERE ( (d.CasePayorMCI_IDNO = @Ln_SnfxCur_Payor_IDNO
									AND TypeHold_CODE = @Lc_TypePostingPayor_CODE)
                                   OR (d.CasePayorMCI_IDNO = @Ln_SnfxCur_Case_IDNO
										AND TypeHold_CODE = @Lc_TypePostingCase_CODE
										)
                                   )
                            AND @Lc_SnfxCur_ReasonStatus_CODE <> d.ReasonHold_CODE
                            AND (d.SourceHold_CODE = @Lc_SourceReceiptDh_CODE
                                  OR d.SourceHold_CODE = @Lc_SnfxCur_SourceReceipt_CODE)
                            AND d.Effective_DATE <= @Ld_Run_DATE
                            AND d.Expiration_DATE > @Ld_Run_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                          ORDER BY priority DESC,
                                   d.Expiration_DATE DESC) f) fci
          WHERE @Lc_SnfxCur_Processed_INDC = @Lc_Processed_INDC;
        END

       SET @Ln_Arrear_AMNT = 0;

       IF @Lc_SnfxCur_Processed_INDC NOT IN (@Lc_Processed_INDC)
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_VUCAT';
         SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_SnfxCur_Processed_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         -- To check if the System Refund or Release indicator set
         -- for the UDC code - Start
         SELECT @Ld_Release_DATE = CASE
                                    WHEN (u.AutomaticRelease_INDC = @Lc_Yes_INDC
                                           OR u.AutomaticRefund_INDC = @Lc_Yes_INDC)
                                     THEN
                                     CASE u.NumDaysRefund_QNTY
                                      WHEN 0
                                       THEN DATEADD(d, u.NumDaysHold_QNTY, @Ld_Run_DATE)
                                      ELSE DATEADD(d, u.NumDaysRefund_QNTY, @Ld_Run_DATE)
                                     END
                                    ELSE @Ld_High_DATE
                                   END
           FROM UCAT_Y1 u
          WHERE u.Udc_CODE = @Lc_SnfxCur_Processed_INDC
            AND u.EndValidity_DATE = @Ld_High_DATE;

         -- To check if the System Refund or Release indicator set
         -- for the UDC code - End
         SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1_HOLD';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR), '') + ', ReleasedFrom_CODE = ' + ISNULL(@Lc_SnfxCur_ReasonStatus_CODE, '') + ', HELD FOR = ' + ISNULL(@Lc_SnfxCur_Processed_INDC, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeqHold_NUMB AS VARCHAR), '');

        MERGE INTO RCTH_Y1 t USING (SELECT @Ld_SnfxCur_Batch_DATE Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB SeqReceipt_NUMB )s ON ( t.Batch_DATE = s.Batch_DATE AND t.SourceBatch_CODE = s.SourceBatch_CODE AND t.Batch_NUMB = s.Batch_NUMB AND t.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND t.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeqHold_NUMB) WHEN MATCHED THEN UPDATE SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_SnfxCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT ( Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, SourceReceipt_CODE, TypeRemittance_CODE, TypePosting_CODE, Case_IDNO, PayorMCI_IDNO, Receipt_AMNT, ToDistribute_AMNT, Fee_AMNT, Employer_IDNO, Fips_CODE, Check_DATE, CheckNo_Text, Receipt_DATE, Distribute_DATE, Tanf_CODE, TaxJoint_CODE, TaxJoint_NAME, StatusReceipt_CODE, ReasonStatus_CODE, BackOut_INDC, ReasonBackOut_CODE, BeginValidity_DATE, EndValidity_DATE, Release_DATE, Refund_DATE, ReferenceIrs_IDNO, RefundRecipient_ID, RefundRecipient_CODE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB) VALUES ( @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Ld_Low_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_SnfxCur_StatusReceipt_CODE, @Lc_SnfxCur_Processed_INDC, @Lc_Processed_INDC, @Lc_Space_TEXT, @Ld_Run_DATE, @Ld_High_DATE, @Ld_Release_DATE, @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ln_EventGlobalSeqHold_NUMB, 0 );
        END

       SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1_RELEASE';
       SET @Ls_Sqldata_TEXT = 'Processed_INDC = ' + @Lc_SnfxCur_Processed_INDC + ', ReasonStatus_CODE = ' + @Lc_SnfxCur_ReasonStatus_CODE;

       IF @Lc_SnfxCur_Processed_INDC IN (@Lc_Processed_INDC)
          AND @Lc_SnfxCur_ReasonStatus_CODE NOT IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
        BEGIN
         -- To Generate and Update the Receipts based on the Receipt/Case/Payor Combination 
         IF @Ld_SnfxCur_Batch_DATE <> @Ld_PrevBatch_DATE
             OR @Lc_SnfxCur_SourceBatch_CODE <> @Lc_PrevSourceBatch_CODE
             OR @Ln_SnfxCur_Batch_NUMB <> @Ln_PrevBatch_NUMB
             OR @Ln_SnfxCur_SeqReceipt_NUMB <> @Ln_PrevSeqReceipt_NUMB
             OR @Ln_SnfxCur_Payor_IDNO <> @Ln_PrevPayor_IDNO
             OR @Ln_SnfxCur_Case_IDNO <> @Ln_PrevCase_IDNO
          BEGIN
           -- Generate the EventGlobalSeq_NUMB
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 2';
           SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReleaseAHeldReceipt1430_NUMB AS VARCHAR), '') + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + @Lc_Value_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT; 
           EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
            @An_EventFunctionalSeq_NUMB = @Li_ReleaseAHeldReceipt1430_NUMB,
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

           SET @Ld_PrevBatch_DATE = @Ld_SnfxCur_Batch_DATE;
           SET @Lc_PrevSourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE;
           SET @Ln_PrevBatch_NUMB = @Ln_SnfxCur_Batch_NUMB;
           SET @Ln_PrevSeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB;
           SET @Ln_PrevPayor_IDNO = @Ln_SnfxCur_Payor_IDNO;
           SET @Ln_PrevCase_IDNO = @Ln_SnfxCur_Case_IDNO;
          END

         SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_RELEASE';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_SnfxCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_SnfxCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

         UPDATE RCTH_Y1
            SET EndValidity_DATE = @Ld_Run_DATE,
                EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
          WHERE Batch_DATE = @Ld_SnfxCur_Batch_DATE
            AND SourceBatch_CODE = @Lc_SnfxCur_SourceBatch_CODE
            AND Batch_NUMB = @Ln_SnfxCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_SnfxCur_SeqReceipt_NUMB
            AND EventGlobalBeginSeq_NUMB = @Ln_SnfxCur_EventGlobalBeginSeq_NUMB;

         -- End
         SET @Ls_Sql_TEXT = 'MERGE_RCTH_Y1_RELEASE';
         SET @Ls_Sqldata_TEXT = ' Batch_DATE = ' + ISNULL(CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR), '') + ', ReleasedFrom_CODE = ' + ISNULL(@Lc_SnfxCur_ReasonStatus_CODE, '') + ', HELD FOR  = ' + ISNULL(@Lc_SnfxCur_Processed_INDC, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

        MERGE INTO RCTH_Y1 t USING (SELECT @Ld_SnfxCur_Batch_DATE Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB SeqReceipt_NUMB )s ON ( t.Batch_DATE = s.Batch_DATE AND t.SourceBatch_CODE = s.SourceBatch_CODE AND t.Batch_NUMB = s.Batch_NUMB AND t.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND t.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB) WHEN MATCHED THEN UPDATE SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_SnfxCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT ( Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, SourceReceipt_CODE, TypeRemittance_CODE, TypePosting_CODE, Case_IDNO, PayorMCI_IDNO, Receipt_AMNT, ToDistribute_AMNT, Fee_AMNT, Employer_IDNO, Fips_CODE, Check_DATE, CheckNo_Text, Receipt_DATE, Distribute_DATE, Tanf_CODE, TaxJoint_CODE, TaxJoint_NAME, StatusReceipt_CODE, ReasonStatus_CODE, BackOut_INDC, ReasonBackOut_CODE, BeginValidity_DATE, EndValidity_DATE, Release_DATE, Refund_DATE, ReferenceIrs_IDNO, RefundRecipient_ID, RefundRecipient_CODE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB) VALUES ( @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Ld_Low_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_StatusReceiptIdentified_CODE, @Lc_SnfxCur_ReasonStatus_CODE, @Lc_Processed_INDC, @Lc_Space_TEXT, @Ld_Run_DATE, @Ld_High_DATE, @Ld_Run_DATE, @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ln_EventGlobalSeq_NUMB, 0 );
        END

       --  To Insert the Released receipts from SNAX, SNEX, SNFX into Temporary Table,
       --  so that when the Distribution Program Distributes it then they can be re-inserted into the RCTH
       --  as Identified otherwise they can remain as such (on hold)
       IF @Lc_SnfxCur_Processed_INDC IN (@Lc_Processed_INDC)
          AND @Lc_SnfxCur_ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'MERGE_PRREL_Y1_RELEASE';
         SET @Ls_Sqldata_TEXT = ' Batch_DATE = ' + ISNULL(CAST(@Ld_SnfxCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SnfxCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SnfxCur_SeqReceipt_NUMB AS VARCHAR), '') + ', ReleasedFrom_CODE = ' + ISNULL(@Lc_SnfxCur_ReasonStatus_CODE, '') + ', HELD FOR = ' + ISNULL(@Lc_SnfxCur_Processed_INDC, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeqHold_NUMB AS VARCHAR), '');

        MERGE INTO PRREL_Y1 t USING (SELECT @Ld_SnfxCur_Batch_DATE Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB SeqReceipt_NUMB ) AS s ON ( t.Batch_DATE = s.Batch_DATE AND t.SourceBatch_CODE = s.SourceBatch_CODE AND t.Batch_NUMB = s.Batch_NUMB AND t.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB) WHEN MATCHED THEN UPDATE SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_SnfxCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT (Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, SourceReceipt_CODE, TypePosting_CODE, Case_IDNO, PayorMCI_IDNO, ToDistribute_AMNT, Receipt_DATE, Check_NUMB, Tanf_CODE, TaxJoint_CODE, ReasonStatus_CODE, EventGlobalBeginSeq_NUMB) VALUES ( @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_ToDistribute_AMNT, @Ld_SnfxCur_Receipt_DATE, 0, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_ReasonStatus_CODE, @Ln_SnfxCur_EventGlobalBeginSeq_NUMB);
        END
      
      SET @Ls_Sql_TEXT = 'FETCH Hold_CUR - 2';
      SET @Ls_Sqldata_TEXT = '';

      FETCH NEXT FROM Hold_CUR INTO @Ld_SnfxCur_Batch_DATE, @Lc_SnfxCur_SourceBatch_CODE, @Ln_SnfxCur_Batch_NUMB, @Ln_SnfxCur_SeqReceipt_NUMB, @Lc_SnfxCur_SourceReceipt_CODE, @Lc_SnfxCur_TypeRemittance_CODE, @Lc_SnfxCur_TypePosting_CODE, @Ln_SnfxCur_Case_IDNO, @Ln_SnfxCur_Payor_IDNO, @Ln_SnfxCur_Receipt_AMNT, @Ln_SnfxCur_ToDistribute_AMNT, @Ln_SnfxCur_Fee_AMNT, @Ln_SnfxCur_Employer_IDNO, @Lc_SnfxCur_Fips_CODE, @Ld_SnfxCur_Check_DATE, @Lc_SnfxCur_CheckNo_Text, @Ld_SnfxCur_Receipt_DATE, @Lc_SnfxCur_Tanf_CODE, @Lc_SnfxCur_TaxJoint_CODE, @Lc_SnfxCur_TaxJoint_NAME, @Lc_SnfxCur_StatusReceipt_CODE, @Lc_SnfxCur_ReasonStatus_CODE, @Lc_SnfxCur_BackOut_INDC, @Lc_SnfxCur_ReasonBackOut_CODE, @Ld_SnfxCur_Release_DATE, @Ld_SnfxCur_Refund_DATE, @Lc_SnfxCur_ReferenceIrs_IDNO, @Lc_SnfxCur_RefundRecipient_ID, @Lc_SnfxCur_RefundRecipient_CODE, @Ln_SnfxCur_EventGlobalBeginSeq_NUMB, @Lc_SnfxCur_Processed_INDC;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Hold_CUR;

   DEALLOCATE Hold_CUR;
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorSnfxCur_QNTY + @Ln_CursorHoldCur_QNTY;
   	
   SET @Ls_Sql_TEXT = 'BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT';
   SET @Ls_Sqldata_TEXT = '';

   EXECUTE BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
    @Ac_Job_ID                = @Lc_Job_ID OUTPUT,
    @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
    @Ad_Process_DATE          = @Ld_Run_DATE OUTPUT,
    @Ad_Create_DATE           = @Ld_Start_DATE OUTPUT,
    @As_Process_NAME          = @Ls_Process_NAME OUTPUT;
    
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
    
   -- 'CR' RCTH_Y1 type processing1	
   -- CrReceipt_CUR
   SET @Ls_Sql_TEXT = 'OPEN CrReceipt_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN CrReceipt_CUR;

   SET @Ls_Sql_TEXT = 'FETCH CrReceipt_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM CrReceipt_CUR INTO @Ld_CrReceiptCur_Batch_DATE, @Ln_CrReceiptCur_Batch_NUMB, @Ln_CrReceiptCur_SeqReceipt_NUMB, @Lc_CrReceiptCur_SourceBatch_CODE, @Ln_CrReceiptCur_Case_IDNO, @Ln_CrReceiptCur_PayorMCI_IDNO, @Ln_CrReceiptCur_ToDistribute_AMNT, @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB, @Ld_CrReceiptCur_Receipt_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   	
   BEGIN
   -- CR receipt cursor started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
       SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + CAST(@Ld_CrReceiptCur_Batch_DATE AS VARCHAR) + ', Batch_NUMB = ' + CAST(@Ln_CrReceiptCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_CrReceiptCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_CrReceiptCur_SourceBatch_CODE + ', Case_IDNO = ' + CAST(@Ln_CrReceiptCur_Case_IDNO AS VARCHAR) + ', PayorMCI_IDNO = ' + CAST(@Ln_CrReceiptCur_PayorMCI_IDNO AS VARCHAR) + ', ToDistribute_AMNT = ' + CAST(@Ln_CrReceiptCur_ToDistribute_AMNT AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', Receipt_DATE = ' + CAST(@Ld_CrReceiptCur_Receipt_DATE AS VARCHAR);
       SET @Ln_CursorCrReceipt_QNTY = @Ln_CursorCrReceipt_QNTY + 1;
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
       SET @Ls_CursorLoc_TEXT = 'CR_RECEIPT - CURSOR COUNT = ' + ISNULL(CAST(@Ln_CursorCrReceipt_QNTY AS VARCHAR), '');
       SET @Ls_Sql_TEXT = 'BATCH_FIN_COLLECTIONS$SP_CR_RECEIPT_PROCESS';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_CrReceiptCur_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_CrReceiptCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_CrReceiptCur_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_CrReceiptCur_SourceBatch_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CrReceiptCur_Case_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_CrReceiptCur_PayorMCI_IDNO AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ld_CrReceiptCur_Receipt_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ToDistribute_AMNT = ' + ISNULL(CAST(@Ln_CrReceiptCur_ToDistribute_AMNT AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_FIN_COLLECTIONS$SP_CR_RECEIPT_PROCESS
        @Ad_Batch_DATE               = @Ld_CrReceiptCur_Batch_DATE,
        @An_Batch_NUMB               = @Ln_CrReceiptCur_Batch_NUMB,
        @An_SeqReceipt_NUMB          = @Ln_CrReceiptCur_SeqReceipt_NUMB,
        @Ac_SourceBatch_CODE         = @Lc_CrReceiptCur_SourceBatch_CODE,
        @An_Case_IDNO                = @Ln_CrReceiptCur_Case_IDNO,
        @An_PayorMCI_IDNO            = @Ln_CrReceiptCur_PayorMCI_IDNO,
        @An_Identified_AMNT          = @Ln_CrReceiptCur_ToDistribute_AMNT,
        @An_EventGlobalBeginSeq_NUMB = @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB,
        @Ad_Receipt_DATE             = @Ld_CrReceiptCur_Receipt_DATE,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_Job_ID					 = @Lc_Job_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
     
      SET @Ls_Sql_TEXT = 'FETCH CrReceipt_CUR - 2';
      SET @Ls_Sqldata_TEXT = '';

      FETCH NEXT FROM CrReceipt_CUR INTO @Ld_CrReceiptCur_Batch_DATE, @Ln_CrReceiptCur_Batch_NUMB, @Ln_CrReceiptCur_SeqReceipt_NUMB, @Lc_CrReceiptCur_SourceBatch_CODE, @Ln_CrReceiptCur_Case_IDNO, @Ln_CrReceiptCur_PayorMCI_IDNO, @Ln_CrReceiptCur_ToDistribute_AMNT, @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB, @Ld_CrReceiptCur_Receipt_DATE;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE CrReceipt_CUR;

   DEALLOCATE CrReceipt_CUR;
   
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorSnfxCur_QNTY + @Ln_CursorHoldCur_QNTY + @Ln_CursorCrReceipt_QNTY;
   -- Start --
   -- 'CF' RCTH_Y1 type processing1	
   -- CfReceipt_CUR
   SET @Ls_Sql_TEXT = 'OPEN CfReceipt_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN CfReceipt_CUR;

   SET @Ls_Sql_TEXT = 'FETCH CfReceipt_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM CfReceipt_CUR INTO @Ld_CrReceiptCur_Batch_DATE, @Ln_CrReceiptCur_Batch_NUMB, @Ln_CrReceiptCur_SeqReceipt_NUMB, @Lc_CrReceiptCur_SourceBatch_CODE, @Ln_CrReceiptCur_Case_IDNO, @Ln_CrReceiptCur_PayorMCI_IDNO, @Ln_CrReceiptCur_ToDistribute_AMNT, @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB, @Ld_CrReceiptCur_Receipt_DATE;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   BEGIN
   -- Cf receipt cursor started	
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
       SET @Ls_BateRecord_TEXT = 'Batch_DATE = ' + CAST(@Ld_CrReceiptCur_Batch_DATE AS VARCHAR) + ', Batch_NUMB = ' + CAST(@Ln_CrReceiptCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_CrReceiptCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_CrReceiptCur_SourceBatch_CODE + ', Case_IDNO = ' + CAST(@Ln_CrReceiptCur_Case_IDNO AS VARCHAR) + ', PayorMCI_IDNO = ' + CAST(@Ln_CrReceiptCur_PayorMCI_IDNO AS VARCHAR) + ', ToDistribute_AMNT = ' + CAST(@Ln_CrReceiptCur_ToDistribute_AMNT AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', Receipt_DATE = ' + CAST(@Ld_CrReceiptCur_Receipt_DATE AS VARCHAR);
       SET @Ln_CursorCfReceipt_QNTY = @Ln_CursorCfReceipt_QNTY + 1;
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
       SET @Ls_CursorLoc_TEXT = 'CR_RECEIPT - CURSOR COUNT = ' + ISNULL(CAST(@Ln_CursorCfReceipt_QNTY AS VARCHAR), '');
       SET @Ls_Sql_TEXT = 'BATCH_FIN_COLLECTIONS$SP_CR_RECEIPT_PROCESS';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_CrReceiptCur_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_CrReceiptCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_CrReceiptCur_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_CrReceiptCur_SourceBatch_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CrReceiptCur_Case_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_CrReceiptCur_PayorMCI_IDNO AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ld_CrReceiptCur_Receipt_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ToDistribute_AMNT = ' + ISNULL(CAST(@Ln_CrReceiptCur_ToDistribute_AMNT AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '');
       EXECUTE BATCH_FIN_COLLECTIONS$SP_CF_RECEIPT_PROCESS
        @Ad_Batch_DATE               = @Ld_CrReceiptCur_Batch_DATE,
        @An_Batch_NUMB               = @Ln_CrReceiptCur_Batch_NUMB,
        @An_SeqReceipt_NUMB          = @Ln_CrReceiptCur_SeqReceipt_NUMB,
        @Ac_SourceBatch_CODE         = @Lc_CrReceiptCur_SourceBatch_CODE,
        @An_Case_IDNO                = @Ln_CrReceiptCur_Case_IDNO,
        @An_PayorMCI_IDNO            = @Ln_CrReceiptCur_PayorMCI_IDNO,
        @An_Identified_AMNT          = @Ln_CrReceiptCur_ToDistribute_AMNT,
        @An_EventGlobalBeginSeq_NUMB = @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB,
        @Ad_Receipt_DATE             = @Ld_CrReceiptCur_Receipt_DATE,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_Job_ID					 = @Lc_Job_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      
      SET @Ls_Sql_TEXT = 'FETCH CfReceipt_CUR - 2';
      SET @Ls_Sqldata_TEXT = '';

      FETCH NEXT FROM CfReceipt_CUR INTO @Ld_CrReceiptCur_Batch_DATE, @Ln_CrReceiptCur_Batch_NUMB, @Ln_CrReceiptCur_SeqReceipt_NUMB, @Lc_CrReceiptCur_SourceBatch_CODE, @Ln_CrReceiptCur_Case_IDNO, @Ln_CrReceiptCur_PayorMCI_IDNO, @Ln_CrReceiptCur_ToDistribute_AMNT, @Ln_CrReceiptCur_EventGlobalBeginSeq_NUMB, @Ld_CrReceiptCur_Receipt_DATE;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE CfReceipt_CUR;

   DEALLOCATE CfReceipt_CUR;
   
	IF @Ln_CursorSnfxCur_QNTY = 0 AND @Ln_CursorHoldCur_QNTY = 0 AND @Ln_CursorCrReceipt_QNTY = 0 AND @Ln_CursorCfReceipt_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorW_CODE + ', Line_NUMB = ' + CAST(@Ln_CursorSnfxCur_QNTY AS VARCHAR) + ', Error_CODE  = ' + @Lc_NoRecordsToProcess_CODE + ', Sqldata_TEXT = ' + @Ls_Sqldata_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
      @An_Line_NUMB                = @Ln_CursorSnfxCur_QNTY,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   
   -- SNFX Hold Alert for Case Worker IF the hold amount greater than or equal to
   -- 2 month MSO then those case workers should get this alert. - Strt
   SET @Ls_Sql_TEXT = 'BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT - SNFX HOLD ALERT FOR 2 MONTH MSO';
   SET @Ls_Sqldata_TEXT = '';

   EXECUTE BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT
    @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
    @Ac_Job_ID                = @Lc_Job_ID OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;
    
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
    
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorSnfxCur_QNTY + @Ln_CursorHoldCur_QNTY + @Ln_CursorCrReceipt_QNTY + @Ln_CursorCfReceipt_QNTY;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION ReleaseReceipt;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ReleaseReceipt;
    END

   IF CURSOR_STATUS('Local', 'Snfx_CUR') IN (0, 1)
    BEGIN
     CLOSE Snfx_CUR;

     DEALLOCATE Snfx_CUR;
    END

   IF CURSOR_STATUS('Local', 'Hold_CUR') IN (0, 1)
    BEGIN
     CLOSE Hold_CUR;

     DEALLOCATE Hold_CUR;
    END

   IF CURSOR_STATUS('Local', 'CrReceipt_CUR') IN (0, 1)
    BEGIN
     CLOSE CrReceipt_CUR;

     DEALLOCATE CrReceipt_CUR;
    END
   
   IF CURSOR_STATUS('Local', 'CfReceipt_CUR') IN (0, 1)
    BEGIN
     CLOSE CfReceipt_CUR;

     DEALLOCATE CfReceipt_CUR;
    END
   	
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;

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
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
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
