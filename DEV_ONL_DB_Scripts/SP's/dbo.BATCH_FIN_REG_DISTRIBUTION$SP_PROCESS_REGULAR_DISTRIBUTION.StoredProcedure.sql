/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_REGULAR_DISTRIBUTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_REGULAR_DISTRIBUTION
Programmer Name 	: IMP Team
Description			: This is the Driver Procedure that calls all the corresponding sub-procedures for the Distribution Process
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: None
Called On			: BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE,BATCH_FIN_REG_DISTRIBUTION$SF_HELD_MONEY_RELEASE_DATE,
					  BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH,BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST, 
					  BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_LSUP,BATCH_FIN_REG_DISTRIBUTION$SP_GET_REMAIN_MONEY_REAS_CODE, 
					  BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD,BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_REGULAR_DISTRIBUTION]
 @An_Thread_NUMB NUMERIC (5)
AS
 BEGIN
  SET NOCOUNT ON;

  -- TOWED_Y1
  CREATE TABLE #Towed_P1
   (
     Case_IDNO           NUMERIC(6) NOT NULL,
     OrderSeq_NUMB       NUMERIC(2) NOT NULL,
     ObligationSeq_NUMB  NUMERIC(2) NOT NULL,
     TypeBucket_CODE     CHAR(5) NOT NULL,
     PrDistribute_QNTY   NUMERIC(5) NULL,
     ArrToBePaid_AMNT    NUMERIC(11, 2) NULL,
     CheckRecipient_ID   CHAR(10) NULL,
     CheckRecipient_CODE CHAR(1) NULL,
     Batch_DATE          DATE NULL,
     SourceBatch_CODE    CHAR(3) NULL,
     Batch_NUMB          NUMERIC(4) NULL,
     SeqReceipt_NUMB     NUMERIC(6) NULL,
     TypeOrder_CODE      CHAR(1) NULL,
     TypeWelfare_CODE    CHAR(1) NULL,
     MonthSupport_AMNT   NUMERIC(11, 2) NULL,
     MemberMci_IDNO      NUMERIC(10) NULL,
     TypeDebt_CODE       CHAR(2) NULL,
     Fips_CODE           CHAR(7) NULL,
     ExptOrig_AMNT       NUMERIC(11, 2) NULL,
     PRIMARY KEY (Case_IDNO, OrderSeq_NUMB, ObligationSeq_NUMB, TypeBucket_CODE)
   );

  -- TPAID_Y1
  CREATE TABLE #Tpaid_P1
   (
     Seq_IDNO            NUMERIC(19) NULL,
     Case_IDNO           NUMERIC(6) NOT NULL,
     OrderSeq_NUMB       NUMERIC(2) NOT NULL,
     ObligationSeq_NUMB  NUMERIC(2) NOT NULL,
     TypeBucket_CODE     CHAR(5) NOT NULL,
     PrDistribute_QNTY   NUMERIC(5) NULL,
     ArrPaid_AMNT        NUMERIC(11, 2) NULL,
     Rounded_AMNT        NUMERIC(11, 2) NULL,
     ArrToBePaid_AMNT    NUMERIC(11, 2) NULL,
     CheckRecipient_ID   CHAR(10) NULL,
     CheckRecipient_CODE CHAR(1) NULL,
     Batch_DATE          DATE NULL,
     SourceBatch_CODE    CHAR(3) NULL,
     Batch_NUMB          NUMERIC(4) NULL,
     SeqReceipt_NUMB     NUMERIC(6) NULL,
     ObleFound_INDC      CHAR(1) NULL,
     TypeOrder_CODE      CHAR(1) NULL,
     TypeWelfare_CODE    CHAR(1) NULL,
     TypeDebt_CODE       CHAR(2) NULL,
     LsupInsert_INDC     CHAR(1) NULL,
     PRIMARY KEY (Case_IDNO, OrderSeq_NUMB, ObligationSeq_NUMB, TypeBucket_CODE)
   );

  -- TTOWD_Y1
  CREATE TABLE #Ttowd_P1
   (
     Case_IDNO           NUMERIC(6) NOT NULL,
     OrderSeq_NUMB       NUMERIC(2) NOT NULL,
     ObligationSeq_NUMB  NUMERIC(2) NOT NULL,
     TypeBucket_CODE     CHAR(5) NOT NULL,
     PrDistribute_QNTY   NUMERIC(5) NULL,
     ArrToBePaid_AMNT    NUMERIC(11, 2) NULL,
     CheckRecipient_ID   CHAR(10) NULL,
     CheckRecipient_CODE CHAR(1) NULL,
     Batch_DATE          DATE NULL,
     SourceBatch_CODE    CHAR(3) NULL,
     Batch_NUMB          NUMERIC(4) NULL,
     SeqReceipt_NUMB     NUMERIC(6) NULL,
     TypeOrder_CODE      CHAR(1) NULL,
     TypeWelfare_CODE    CHAR(1) NULL,
     MonthSupport_AMNT   NUMERIC(11, 2) NULL,
     MemberMci_IDNO      NUMERIC(10) NULL,
     TypeDebt_CODE       CHAR(2) NULL,
     Fips_CODE           CHAR(7) NULL,
     ExptOrig_AMNT       NUMERIC(11, 2) NULL
   );

  -- TTPAD_Y1
  CREATE TABLE #Ttpad_P1
   (
     Seq_IDNO            NUMERIC(19) NULL,
     Case_IDNO           NUMERIC(6) NULL,
     OrderSeq_NUMB       NUMERIC(2) NULL,
     ObligationSeq_NUMB  NUMERIC(2) NULL,
     TypeBucket_CODE     CHAR(5) NULL,
     PrDistribute_QNTY   NUMERIC(5) NULL,
     ArrPaid_AMNT        NUMERIC(11, 2) NULL,
     Rounded_AMNT        NUMERIC(11, 2) NULL,
     ArrToBePaid_AMNT    NUMERIC(11, 2) NULL,
     CheckRecipient_ID   CHAR(10) NULL,
     CheckRecipient_CODE CHAR(1) NULL,
     Batch_DATE          DATE NULL,
     SourceBatch_CODE    CHAR(3) NULL,
     Batch_NUMB          NUMERIC(4) NULL,
     SeqReceipt_NUMB     NUMERIC(6) NULL,
     ObleFound_INDC      CHAR(1) NULL,
     TypeOrder_CODE      CHAR(1) NULL,
     TypeWelfare_CODE    CHAR(1) NULL,
     TypeDebt_CODE       CHAR(2) NULL,
     LsupInsert_INDC     CHAR(1) NULL
   );

  -- TEXPT_Y1
  CREATE TABLE #Texpt_P1
   (
     Case_IDNO           NUMERIC(6) NOT NULL,
     OrderSeq_NUMB       NUMERIC(2) NOT NULL,
     ObligationSeq_NUMB  NUMERIC(2) NOT NULL,
     TypeBucket_CODE     CHAR(5) NOT NULL,
     PrDistribute_QNTY   NUMERIC(5) NULL,
     ArrToBePaid_AMNT    NUMERIC(11, 2) NULL,
     CheckRecipient_ID   CHAR(10) NULL,
     CheckRecipient_CODE CHAR(1) NULL,
     Batch_DATE          DATE NULL,
     SourceBatch_CODE    CHAR(3) NULL,
     Batch_NUMB          NUMERIC(4) NULL,
     SeqReceipt_NUMB     NUMERIC(6) NULL,
     Expt_AMNT           NUMERIC(11, 2) NULL,
     TypeOrder_CODE      CHAR(1) NULL,
     TypeWelfare_CODE    CHAR(1) NULL,
     MonthSupport_AMNT   NUMERIC(11, 2) NULL,
     MemberMci_IDNO      NUMERIC(10) NULL,
     TypeDebt_CODE       CHAR(2) NULL,
     PRIMARY KEY (Case_IDNO, OrderSeq_NUMB, ObligationSeq_NUMB, TypeBucket_CODE)
   );

  -- TPRTL_Y1
  CREATE TABLE #Tprtl_P1
   (
     PrDistribute_QNTY   NUMERIC(5) NOT NULL,
     PrArrToBePaid_AMNT  NUMERIC(11, 2) NULL,
     CumArrToBePaid_AMNT NUMERIC(11, 2) NULL,
     Case_IDNO           NUMERIC(6) NOT NULL,
     PRIMARY KEY (Case_IDNO, PrDistribute_QNTY)
   );

  -- TCORD_Y1
  CREATE TABLE #Tcord_P1
   (
     Case_IDNO      NUMERIC(6) NULL,
     Order_IDNO     NUMERIC(15) NULL,
     OrderSeq_NUMB  NUMERIC(2) NULL,
     OrderType_CODE CHAR(1) NULL,
     CaseType_CODE  CHAR(1) NULL
   );

  -- TBUMP_Y1
  CREATE TABLE #Tbump_P1
   (
     Case_IDNO           NUMERIC(6) NOT NULL,
     OrderSeq_NUMB       NUMERIC(2) NOT NULL,
     ObligationSeq_NUMB  NUMERIC(2) NOT NULL,
     TypeBucket_CODE     CHAR(5) NOT NULL,
     PrDistribute_QNTY   NUMERIC(5) NULL,
     ArrToBePaid_AMNT    NUMERIC(11, 2) NULL,
     CheckRecipient_ID   CHAR(10) NULL,
     CheckRecipient_CODE CHAR(1) NULL,
     Batch_DATE          DATE NULL,
     SourceBatch_CODE    CHAR(3) NULL,
     Batch_NUMB          NUMERIC(4) NULL,
     SeqReceipt_NUMB     NUMERIC(6) NULL,
     Expt_AMNT           NUMERIC(11, 2) NULL,
     TypeOrder_CODE      CHAR(1) NULL,
     TypeWelfare_CODE    CHAR(1) NULL,
     MonthSupport_AMNT   NUMERIC(11, 2) NULL,
     MemberMci_IDNO      NUMERIC(10) NULL,
     TypeDebt_CODE       CHAR(2) NULL
   );

  -- TCARR_Y1
  CREATE TABLE #Tcarr_P1
   (
     Case_IDNO         NUMERIC(6) NULL,
     TypeBucket_CODE   CHAR(5) NULL,
     Arrear_AMNT       NUMERIC(11, 2) NULL,
     Receipt_AMNT      NUMERIC(11, 2) NULL,
     PrDistribute_QNTY NUMERIC(5) NULL
   );

  CREATE TABLE #Rcth_P1
   (
     Batch_DATE               DATE,
     SourceBatch_CODE         CHAR(3),
     Batch_NUMB               NUMERIC(4),
     SeqReceipt_NUMB          NUMERIC(6),
     SourceReceipt_CODE       CHAR(2),
     TypeRemittance_CODE      CHAR(3),
     TypePosting_CODE         CHAR(1),
     Case_IDNO                NUMERIC(6),
     PayorMCI_IDNO            NUMERIC(10),
     Receipt_AMNT             NUMERIC(11, 2),
     ToDistribute_AMNT        NUMERIC(11, 2),
     Fee_AMNT                 NUMERIC(11, 2),
     Employer_IDNO            NUMERIC(9),
     Fips_CODE                CHAR(7),
     Check_DATE               DATE,
     CheckNo_TEXT             CHAR(18),
     Receipt_DATE             DATE,
     Distribute_DATE          DATE,
     Tanf_CODE                CHAR(1),
     TaxJoint_CODE            CHAR(1),
     TaxJoint_NAME            CHAR(35),
     StatusReceipt_CODE       CHAR(1),
     ReasonStatus_CODE        CHAR(4),
     BackOut_INDC             CHAR(1),
     ReasonBackOut_CODE       CHAR(2),
     Refund_DATE              DATE,
     Release_DATE             DATE,
     ReferenceIrs_IDNO        NUMERIC(15),
     RefundRecipient_ID       CHAR(10),
     RefundRecipient_CODE     CHAR(1),
     BeginValidity_DATE       DATE,
     EndValidity_DATE         DATE,
     EventGlobalBeginSeq_NUMB NUMERIC(19),
     EventGlobalEndSeq_NUMB   NUMERIC(19)
   );

  DECLARE  @Li_ReleaseAHeldReceipt1430_NUMB         INT = 1430,
           @Lc_Space_TEXT                           CHAR (1) = ' ',
           @Lc_No_INDC                              CHAR (1) = 'N',
           @Lc_Yes_INDC                             CHAR (1) = 'Y',           
           @Lc_StatusFailed_CODE                    CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE                   CHAR (1) = 'S',
           @Lc_CaseRelationshipNcp_CODE             CHAR (1) = 'A',
           @Lc_CaseRelationshipPutFather_CODE       CHAR (1) = 'P',
           @Lc_CaseMemberStatusActive_CODE          CHAR (1) = 'A',
           @Lc_TypePostingPayor_CODE                CHAR (1) = 'P',
           @Lc_TypePostingCase_CODE                 CHAR (1) = 'C',
           @Lc_StatusReceiptHeld_CODE               CHAR (1) = 'H',
           @Lc_StatusReceiptIdentified_CODE         CHAR (1) = 'I',
           @Lc_StatusAbnormalend_CODE               CHAR (1) = 'A',
           @Lc_TypeErrorE_CODE                      CHAR (1) = 'E',
           @Lc_IrsCertAdd_CODE						CHAR (1) = 'A',
           @Lc_IrsCertMod_CODE						CHAR (1) = 'M',     
           @Lc_StatusReceipt_CODE                   CHAR (1) = ' ',
           @Lc_ThreadProcess_CODE                   CHAR (1) = 'L',
           @Lc_SourceReceiptSpecialCollection_CODE  CHAR (2) = 'SC',
           @Lc_SourceReceiptNR_CODE					CHAR (2) = 'NR',
           @Lc_SourceReceipt_CODE                   CHAR (2) = ' ',
           @Lc_HoldReasonStatusSnfx_CODE            CHAR (4) = 'SNFX',
           @Lc_HoldReasonStatusSnax_CODE            CHAR (4) = 'SNAX',
           @Lc_HoldReasonStatusSnbn_CODE            CHAR (4) = 'SNBN',
           @Lc_HoldReasonStatusSnix_CODE            CHAR (4) = 'SNIX',
           @Lc_HoldReasonStatusSnjx_CODE            CHAR (4) = 'SNJX',
           @Lc_HoldReasonStatusSnin_CODE            CHAR (4) = 'SNIN',
           @Lc_HoldReasonStatusSnjn_CODE            CHAR (4) = 'SNJN',
           @Lc_HoldReasonStatusSnio_CODE            CHAR (4) = 'SNIO',
           @Lc_HoldReasonStatusSnjo_CODE            CHAR (4) = 'SNJO',
           @Lc_HoldReasonStatusSnxo_CODE            CHAR (4) = 'SNXO',
           @Lc_HoldReasonStatusSnjw_CODE            CHAR (4) = 'SNJW',                      
           @Lc_ErrorE1424_CODE                      CHAR (5) = 'E1424',
           @Lc_PreDistJob_ID                        CHAR (7) = 'DEB1270',
           @Lc_Job_ID								CHAR (7) = 'DEB0560',
           @Lc_ProcessRrel_ID                       CHAR (10) = 'DEB0550',
           @Lc_Successful_TEXT                      CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT                    CHAR (30) = 'BATCH',
           @Ls_Process_NAME							VARCHAR (100) = 'BATCH_FIN_REG_DISTRIBUTION',
           @Ls_Procedure_NAME                       VARCHAR (100) = 'SP_PROCESS_REGULAR_DISTRIBUTION',
           @Ls_Err0003_TEXT							VARCHAR (100) = 'REACHED EXCEPTION THRESHOLD',
           @Ld_High_DATE                            DATE = '12/31/9999',
           @Ld_Low_DATE                             DATE = '01/01/0001';
  DECLARE  @Ln_RowCount_QNTY               NUMERIC = 0,
           @Ln_Batch_NUMB                  NUMERIC (4),
           @Ln_CommitFreqParm_QNTY         NUMERIC (5),
           @Ln_ExceptionThresholdParm_QNTY NUMERIC (5),
           @Ln_CommitFreq_QNTY             NUMERIC (5) = 0,
           @Ln_ExceptionThreshold_QNTY     NUMERIC (5) = 0,
           @Ln_SeqReceipt_NUMB             NUMERIC (6),
           @Ln_Case_IDNO                   NUMERIC (6),
           @Ln_ProcessedRecordCount_QNTY   NUMERIC (6) = 0,
           @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
           @Ln_PdistNotProcessRecord_QNTY  NUMERIC (9) = 0,   
           @Ln_JrtlNotProcessThread_QNTY   NUMERIC(15) = 0,
           @Ln_PayorMCI_IDNO               NUMERIC (10),
           @Ln_CursorRecordCount_QNTY      NUMERIC (10) = 0,
           @Ln_Certified_AMNT              NUMERIC (11,2),
           @Ln_Receipt_AMNT                NUMERIC (11,2),
           @Ln_Remaining_AMNT              NUMERIC (11,2),
           @Ln_Temp_Remaining_AMNT         NUMERIC (11,2),
           @Ln_Error_NUMB                  NUMERIC (11),
           @Ln_ErrorLine_NUMB              NUMERIC (11),
           @Ln_NsfRecoup_AMNT              NUMERIC (11,2) = 0,
           @Ln_DhldNsfRecoup_AMNT          NUMERIC (11,2) = 0,
           @Ln_RemainingTemp_AMNT          NUMERIC (11,2),
           @Ln_RecStart_NUMB               NUMERIC (15),
           @Ln_RecRestart_NUMB             NUMERIC (15),
           @Ln_RecEnd_NUMB                 NUMERIC (15),
           @Ln_Record_NUMB                 NUMERIC (15) = 0,
           @Ln_EventGlobalReceiptSeq_NUMB  NUMERIC (19),
           @Ln_EventGlobalSeq_NUMB         NUMERIC (19),
           @Ln_EventGlobalSeqRrel_NUMB     NUMERIC (19),
           @Li_FetchStatus_QNTY            SMALLINT,
           @Lc_ProcFailException_INDC      CHAR (1),
           @Lc_CertifiedExcess_INDC        CHAR (1),
           @Lc_VoluntaryProcess_INDC       CHAR (1),
           @Lc_SystemRelease_INDC          CHAR (1),
           @Lc_NsfExcess_INDC              CHAR (1),
           @Lc_N4dFlag_INDC                CHAR (1),
           @Lc_Tanf_CODE                   CHAR (1),
           @Lc_TaxJoint_CODE               CHAR (1),
           @Lc_TypePosting_CODE            CHAR (1),
           @Lc_TypePostingOriginal_CODE    CHAR (1),
           @Lc_RcptToProcess_CODE          CHAR (1),
           @Lc_Msg_CODE                    CHAR (1),
           @Lc_LsupFound_TEXT              CHAR (1),
           @Lc_ProcessFlag_INDC            CHAR (1),
           @Lc_SourceBatch_CODE            CHAR (3),
           @Lc_ReleasedFrom_CODE           CHAR (4),
           @Lc_ReasonStatus_CODE           CHAR (4),
           @Lc_BateError_CODE              CHAR(18),
           @Lc_Receipt_TEXT                CHAR (30),
           @Ls_Sql_TEXT                    VARCHAR (100),
           @Ls_CursorLoc_TEXT              VARCHAR (200),
           @Ls_RestartKey_TEXT             VARCHAR (200),
           @Ls_Sqldata_TEXT                VARCHAR (1000),
           @Ls_ErrorMessage_TEXT           VARCHAR (4000),
           @Ls_BateRecord_TEXT             VARCHAR (4000),           
           @Ls_DescriptionError_TEXT       VARCHAR (4000),
           @Ld_Run_DATE                    DATE,
           @Ld_Process_DATE                DATE,
           @Ld_Release_DATE                DATE,
           @Ld_Batch_DATE                  DATE,
           @Ld_Receipt_DATE                DATE,
           @Ld_LastRun_DATE                DATE,
           @Ld_ReceiptOrig_DATE            DATE,
           @Ld_Create_DATE                 DATETIME2;
  DECLARE @Ln_RcthCur_RecordRowNumber_NUMB     NUMERIC(15),
          @Ld_RcthCur_Batch_DATE               DATE,
          @Lc_RcthCur_SourceBatch_CODE         CHAR(3),
          @Ln_RcthCur_Batch_NUMB               NUMERIC(4),
          @Ln_RcthCur_SeqReceipt_NUMB          NUMERIC(6),
          @Lc_RcthCur_SourceReceipt_CODE       CHAR(2),
          @Lc_RcthCur_TypePosting_CODE         CHAR(1),
          @Ln_RcthCur_Case_IDNO                NUMERIC(6),
          @Ln_RcthCur_PayorMCI_IDNO            NUMERIC(10),
          @Ln_RcthCur_ToDistribute_AMNT        NUMERIC(11, 2),
          @Ld_RcthCur_Receipt_DATE             DATE,
          @Ln_RcthCur_Check_NUMB               NUMERIC(19),
          @Lc_RcthCur_Tanf_CODE                CHAR(1),
          @Lc_RcthCur_TaxJoint_CODE            CHAR(1),
          @Ln_RcthCur_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Lc_RcthCur_ReleasedFrom_CODE        CHAR(4),
          @Lc_RcthCur_AutomaticRelease_INDC    CHAR(1),
          @Lc_RcthCur_Process_INDC             CHAR(1),
          @Lc_RcthCur_Priority_NUMB            NUMERIC(1);
  BEGIN TRY

   SET @Ld_Create_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_ProcFailException_INDC = @Lc_No_INDC;
   SET @Ls_ErrorMessage_TEXT = '';
   SET @Ls_RestartKey_TEXT = '';

     -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'');

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

   SET @Ld_Process_DATE = @Ld_Run_DATE;
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';  
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISTPRE : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', PreDistJob_ID = ' + ISNULL(@Lc_PreDistJob_ID,'');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_PreDistJob_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Lc_ProcFailException_INDC = @Lc_No_INDC;
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISTGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Thread_NUMB = ' + ISNULL(CAST( @An_Thread_NUMB AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_GET_THREAD_DETAILS
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_Thread_NUMB           = @An_Thread_NUMB,
    @An_RecRestart_NUMB       = @Ln_RecRestart_NUMB OUTPUT,
    @An_RecEnd_NUMB           = @Ln_RecEnd_NUMB OUTPUT,
    @An_RecStart_NUMB         = @Ln_RecStart_NUMB OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Lc_ProcFailException_INDC = @Lc_No_INDC;
     RAISERROR (50001,16,1);
    END

   -- Generate the Sequence Number for the RREL (Release Receipt Job)
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReleaseAHeldReceipt1430_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRrel_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ReleaseAHeldReceipt1430_NUMB,
    @Ac_Process_ID              = @Lc_ProcessRrel_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqRrel_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;
     RAISERROR (50001,16,1);
    END

   DECLARE Rcth_CUR INSENSITIVE CURSOR FOR
   SELECT p.RecordRowNumber_NUMB,
              p.Batch_DATE,
              p.SourceBatch_CODE,
              p.Batch_NUMB,
              p.SeqReceipt_NUMB,
              p.SourceReceipt_CODE,
              p.TypePosting_CODE,
              p.Case_IDNO,
              p.PayorMCI_IDNO,
              p.ToDistribute_AMNT,
              p.Receipt_DATE,
              p.Check_NUMB,
              p.Tanf_CODE,
              p.TaxJoint_CODE,
              p.EventGlobalBeginSeq_NUMB,
              p.ReleasedFrom_CODE,
              p.AutomaticRelease_INDC,
              p.Process_CODE,
              (CASE WHEN SourceReceipt_CODE <> @Lc_SourceReceiptNR_CODE THEN 1 ELSE 2 END) Priority_Numb
         FROM PDIST_Y1 p
        WHERE p.RecordRowNumber_NUMB >= @Ln_RecRestart_NUMB
          AND p.RecordRowNumber_NUMB <= @Ln_RecEnd_NUMB
          AND p.Process_CODE = @Lc_No_INDC
          ORDER BY
			 p.PayorMCI_IDNO,
			 Priority_Numb,
             p.Receipt_DATE,
             p.Batch_DATE,
             p.SourceBatch_CODE,
             p.Batch_NUMB,
             p.SeqReceipt_NUMB;

    -- Fetching Record From RCTH_Y1 Table Using Receipt Key 
   BEGIN TRANSACTION RegDistTran -- 1

   SET @Ls_Sql_TEXT = 'OPEN Rcth_CUR';
   SET @Ls_Sqldata_TEXT = '';
   
   OPEN Rcth_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Rcth_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH NEXT FROM Rcth_CUR INTO @Ln_RcthCur_RecordRowNumber_NUMB, @Ld_RcthCur_Batch_DATE, @Lc_RcthCur_SourceBatch_CODE, @Ln_RcthCur_Batch_NUMB, @Ln_RcthCur_SeqReceipt_NUMB, @Lc_RcthCur_SourceReceipt_CODE, @Lc_RcthCur_TypePosting_CODE, @Ln_RcthCur_Case_IDNO, @Ln_RcthCur_PayorMCI_IDNO, @Ln_RcthCur_ToDistribute_AMNT, @Ld_RcthCur_Receipt_DATE, @Ln_RcthCur_Check_NUMB, @Lc_RcthCur_Tanf_CODE, @Lc_RcthCur_TaxJoint_CODE, @Ln_RcthCur_EventGlobalBeginSeq_NUMB, @Lc_RcthCur_ReleasedFrom_CODE, @Lc_RcthCur_AutomaticRelease_INDC, @Lc_RcthCur_Process_INDC,@Lc_RcthCur_Priority_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Loop Started	
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
     SAVE TRANSACTION SaveRegDistTran
     SET @Ln_Receipt_AMNT = 0;
     SET @Ln_Remaining_AMNT = 0;
     SET @Ld_Batch_DATE = @Ld_RcthCur_Batch_DATE;
     SET @Lc_SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE;
     SET @Ln_Batch_NUMB = @Ln_RcthCur_Batch_NUMB;
     SET @Ln_SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB;
     SET @Ln_Case_IDNO = @Ln_RcthCur_Case_IDNO;
     SET @Ln_PayorMCI_IDNO = @Ln_RcthCur_PayorMCI_IDNO;
     SET @Ln_Receipt_AMNT = @Ln_RcthCur_ToDistribute_AMNT;
     SET @Lc_CertifiedExcess_INDC = @Lc_No_INDC;
     SET @Ln_Certified_AMNT = 0;
     SET @Lc_VoluntaryProcess_INDC = @Lc_No_INDC;
     SET @Lc_SystemRelease_INDC = @Lc_RcthCur_AutomaticRelease_INDC;
     SET @Lc_ReleasedFrom_CODE = @Lc_RcthCur_ReleasedFrom_CODE;
     SET @Ln_NsfRecoup_AMNT = 0;
     SET @Ln_DhldNsfRecoup_AMNT = 0;
     SET @Ln_RowCount_QNTY = 0;
     SET @Lc_NsfExcess_INDC = @Lc_No_INDC;
     SET @Ln_Record_NUMB = @Ln_RcthCur_RecordRowNumber_NUMB;
     SET @Lc_ProcessFlag_INDC = @Lc_Space_TEXT;
     SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
     -- UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
     SET @Ls_ErrorMessage_TEXT = '';
     SET @Lc_Msg_CODE = '';
     SET @Lc_ProcFailException_INDC = '';
          
     SET @Ls_BateRecord_TEXT = 'RecordRowNumber = ' + ISNULL (CAST(@Ln_RcthCur_RecordRowNumber_NUMB AS VARCHAR), '') + 'Batch_DATE = ' + ISNULL (CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_Batch_NUMB AS VARCHAR), '')  + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ',SourceReceipt_CODE = ' + ISNULL (@Lc_RcthCur_SourceReceipt_CODE, '') + ',TypePosting_CODE= ' + ISNULL (@Lc_RcthCur_TypePosting_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_RcthCur_Case_IDNO AS VARCHAR), '')  + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_RcthCur_PayorMCI_IDNO AS VARCHAR), '')  + ', ToDistribute_AMNT = ' + ISNULL (CAST(@Ln_RcthCur_ToDistribute_AMNT AS VARCHAR), '')  + ', Receipt_DATE = ' + ISNULL (CAST(@Ld_RcthCur_Receipt_DATE AS VARCHAR), '') + ', Check_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_Check_NUMB AS VARCHAR), '') + ', Tanf_CODE = ' + ISNULL (@Lc_RcthCur_Tanf_CODE , '') + ', TaxJoint_CODE = ' + ISNULL (@Lc_RcthCur_TaxJoint_CODE , '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', ReleasedFrom_CODE = ' + ISNULL (@Lc_RcthCur_ReleasedFrom_CODE , '') + ', AutomaticRelease_INDC = ' + ISNULL (@Lc_RcthCur_AutomaticRelease_INDC , '') + ', Process_INDC = ' + ISNULL (@Lc_RcthCur_Process_INDC , '') + + ', Priority_Numb = ' + ISNULL (CAST(@Lc_RcthCur_Priority_NUMB AS VARCHAR), '');
	/*
	Hold Code	Description
	SNFX		SYSTEM HOLD - FUTURES
	SNAX		ARREARS PAID IN FULL - ARREARS ONLY CASE
	SNIN		NO CERTIFICATION SPC INDIVIDUAL - WITH ARREARS
	SNIO		NO CERTIFICATION SPC INDIVIDUAL - WITHOUT ARREARS
	SNJN		NO CERTIFICATION SPC JOINT - WITH ARREARS
	SNJO		NO CERTIFICATION SPC JOINT - WITHOUT ARREARS
	SNIX		SPC INDIVIDUAL EXCESS - WITH ARREARS
	SNJX		SPC JOINT EXCESS - WITH ARREARS
	SNXO		SPC INDIVIDUAL EXCESS - WITHOUT ARREARS
	SNJW		SPC JOINT EXCESS - WITHOUT ARREARS
	*/
     -- If receipt Identified from SNFX/SNAX then the ld_dt_receipt should be Current Date
     -- else Original receipt Date
     IF @Lc_RcthCur_ReleasedFrom_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE, @Lc_HoldReasonStatusSnix_CODE, @Lc_HoldReasonStatusSnjx_CODE,@Lc_HoldReasonStatusSnin_CODE,@Lc_HoldReasonStatusSnjn_CODE, @Lc_HoldReasonStatusSnio_CODE, @Lc_HoldReasonStatusSnjo_CODE, @Lc_HoldReasonStatusSnxo_CODE, @Lc_HoldReasonStatusSnjw_CODE, @Lc_HoldReasonStatusSnbn_CODE)
      BEGIN
       SET @Ld_Receipt_DATE = @Ld_Process_DATE;
      END
     ELSE
      BEGIN
       SET @Ld_Receipt_DATE = @Ld_RcthCur_Receipt_DATE;
      END

     SET @Ld_ReceiptOrig_DATE = @Ld_RcthCur_Receipt_DATE;
     SET @Lc_TypePostingOriginal_CODE = @Lc_RcthCur_TypePosting_CODE;
     SET @Lc_TypePosting_CODE = @Lc_RcthCur_TypePosting_CODE;
     SET @Lc_Tanf_CODE = @Lc_RcthCur_Tanf_CODE;
     SET @Lc_TaxJoint_CODE = @Lc_RcthCur_TaxJoint_CODE;
     SET @Lc_SourceReceipt_CODE = @Lc_RcthCur_SourceReceipt_CODE;
     SET @Ln_EventGlobalReceiptSeq_NUMB = @Ln_RcthCur_EventGlobalBeginSeq_NUMB;
     SET @Lc_RcptToProcess_CODE = @Lc_Yes_INDC;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_CursorLoc_TEXT = 'CURSOR_RECORD_COUNT = ' + ISNULL (CAST (@Ln_CursorRecordCount_QNTY AS VARCHAR), '') + ', CASE_IDNO =' + ISNULL (CAST(@Ln_RcthCur_Case_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL (CAST(CONVERT(VARCHAR(10), @Ld_RcthCur_Batch_DATE, 101) AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + + ', An_Thread_NUMB = ' + ISNULL (CAST (@An_Thread_NUMB AS VARCHAR), '');
     SET @Lc_Receipt_TEXT = ISNULL (CAST(REPLACE(CONVERT(VARCHAR(10), @Ld_Batch_DATE, 101), '/', '') AS VARCHAR), '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (@Lc_SourceBatch_CODE, '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (RIGHT( REPLICATE('0', 4) + CAST(@Ln_Batch_NUMB AS VARCHAR), 4), '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (SUBSTRING (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), 1, 3), '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (SUBSTRING (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), 4, 3), '');

     SET @Ln_Remaining_AMNT = @Ln_Receipt_AMNT;
     SET @Lc_LsupFound_TEXT = @Lc_No_INDC;

     --Added to validate distribution code based on TypePosting_CODE -- Note :- This is only for validation
     IF @Ln_RcthCur_Case_IDNO = 0
      BEGIN
       SET @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE;
      END
     ELSE
      BEGIN
       IF @Lc_TypePostingOriginal_CODE = @Lc_TypePostingPayor_CODE
          AND @Lc_RcthCur_ReleasedFrom_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
        BEGIN
         SET @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE;
        END
       ELSE
        BEGIN
         SET @Lc_TypePosting_CODE = @Lc_TypePostingCase_CODE;
        END
      END

     -- ALL Validation before distribution done in this procedure
     -- 1) Obligation check
     -- 2) Log support check
     -- 3) Distribution Hold check
     SET @Lc_N4dFlag_INDC = @Lc_No_INDC;
     SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE';
     SET @Ls_Sqldata_TEXT = 'TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_TaxJoint_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');
     
     EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE
      @Ac_TypePosting_CODE      = @Lc_TypePosting_CODE,
      @An_Case_IDNO             = @Ln_Case_IDNO,
      @An_PayorMCI_IDNO         = @Ln_PayorMCI_IDNO,
      @Ac_TaxJoint_CODE         = @Lc_TaxJoint_CODE,
      @Ad_Receipt_DATE          = @Ld_Receipt_DATE,
      @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE,
      @Ac_RcptToProcess_INDC    = @Lc_RcptToProcess_CODE OUTPUT,
      @Ac_StatusReceipt_CODE    = @Lc_StatusReceipt_CODE OUTPUT,
      @Ac_ReasonStatus_CODE     = @Lc_ReasonStatus_CODE OUTPUT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
      @Ac_ReleasedFrom_CODE     = @Lc_ReleasedFrom_CODE OUTPUT,
      @Ac_IrsCertAdd_CODE       = @Lc_IrsCertAdd_CODE OUTPUT,
      @Ac_IrsCertMod_CODE       = @Lc_IrsCertMod_CODE OUTPUT,
      @Ad_Process_DATE          = @Ld_Process_DATE OUTPUT,
      @Ac_N4dFlag_INDC          = @Lc_N4dFlag_INDC OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;
       RAISERROR (50001,16,1);
      END

     IF @Lc_RcptToProcess_CODE = @Lc_No_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SF_HELD_MONEY_RELEASE_DATE';     
       SET @Ls_Sqldata_TEXT = 'ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'');
         
       SET @Ld_Release_DATE = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_HELD_MONEY_RELEASE_DATE (@Lc_ReasonStatus_CODE, @Ld_Process_DATE);
       SET @Ln_RemainingTemp_AMNT = @Ln_Remaining_AMNT;
       
       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH - 1';       
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePostingOriginal_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_Receipt_AMNT AS VARCHAR ),'')+ ', Remaining_AMNT = ' + ISNULL(CAST( @Ln_RemainingTemp_AMNT AS VARCHAR ),'')+ ', EventGlobalReceiptSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalReceiptSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', ReleaseIn_DATE = ' + ISNULL(CAST( @Ld_Release_DATE AS VARCHAR ),'');

       EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH
        @Ad_Batch_DATE                 = @Ld_Batch_DATE,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
        @An_Case_IDNO                  = @Ln_Case_IDNO,
        @An_PayorMCI_IDNO              = @Ln_PayorMCI_IDNO,
        @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
        @Ac_TypePosting_CODE           = @Lc_TypePostingOriginal_CODE,
        @Ac_ReasonStatus_CODE          = @Lc_ReasonStatus_CODE,
        @An_Receipt_AMNT               = @Ln_Receipt_AMNT,
        @An_Remaining_AMNT             = @Ln_RemainingTemp_AMNT,
        @An_EventGlobalReceiptSeq_NUMB = @Ln_EventGlobalReceiptSeq_NUMB,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
        @Ad_ReleaseIn_DATE             = @Ld_Release_DATE,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
        @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT,
        @Ac_ReleasedFrom_CODE          = @Lc_ReleasedFrom_CODE OUTPUT,
        @Ad_Release_DATE               = @Ld_Release_DATE OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;

         RAISERROR (50001,16,1);
        END

       GOTO Next_Rec;
      END
     ELSE IF @Lc_RcptToProcess_CODE = @Lc_Yes_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_Receipt_AMNT AS VARCHAR ),'')+ ', Tanf_CODE = ' + ISNULL(@Lc_Tanf_CODE,'');

       EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST
        @Ad_Batch_DATE            = @Ld_Batch_DATE,
        @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB            = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,
        @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE,
        @Ad_Receipt_DATE          = @Ld_Receipt_DATE,
        @An_Receipt_AMNT          = @Ln_Receipt_AMNT,
        @Ac_Tanf_CODE             = @Lc_Tanf_CODE,
        @An_Remaining_AMNT        = @Ln_Remaining_AMNT OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
        @Ac_SystemRelease_INDC    = @Lc_SystemRelease_INDC OUTPUT,
        @Ac_ReleasedFrom_CODE     = @Lc_ReleasedFrom_CODE OUTPUT,
        @Ac_VoluntaryProcess_INDC = @Lc_VoluntaryProcess_INDC OUTPUT,
        @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT;
        
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;

         RAISERROR (50001,16,1);
        END
       -- When there is an Error in Loading the TOWED_Y1 Table the Return Code is 'E'
       -- so check for the TOWED_Y1 Fail Reason and hold the receipt with that UDC Code
       ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
         SET @Lc_RcptToProcess_CODE = @Lc_No_INDC;
         SET @Ln_Receipt_AMNT = @Ln_Remaining_AMNT;
		 SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_GET_VOWED_FAIL_REASON_CODE';
		 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_TaxJoint_CODE,'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'');

         EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_GET_VOWED_FAIL_REASON_CODE
          @An_Case_IDNO             = @Ln_Case_IDNO,
          @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE,
          @Ac_TaxJoint_CODE         = @Lc_TaxJoint_CODE,
          @Ad_Process_DATE          = @Ld_Process_DATE,
          @Ac_ReasonStatus_CODE     = @Lc_ReasonStatus_CODE OUTPUT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ld_Release_DATE = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_HELD_MONEY_RELEASE_DATE (@Lc_ReasonStatus_CODE, @Ld_Process_DATE);
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
          AND (@Ln_Remaining_AMNT = 0
                OR @Ln_Remaining_AMNT != @Ln_RcthCur_ToDistribute_AMNT)
          AND @Lc_RcthCur_ReleasedFrom_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
          AND @Lc_RcthCur_AutomaticRelease_INDC = @Lc_Yes_INDC
        BEGIN
         -- Update the Held Record Released the Release receipt the receipt was Distributed by
         -- the Distribution Program
         SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1 _RREL';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_RcthCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

         UPDATE RCTH_Y1
            SET EndValidity_DATE = @Ld_Process_DATE,
                EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqRrel_NUMB
          WHERE Batch_DATE = @Ld_RcthCur_Batch_DATE
            AND SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
            AND Batch_NUMB = @Ln_RcthCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
            AND EventGlobalBeginSeq_NUMB = @Ln_RcthCur_EventGlobalBeginSeq_NUMB;

         SET @Ls_Sql_TEXT = 'INSERT #Rcth_P1';         
		 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Lc_RcthCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_RcthCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST(@Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '');

         INSERT INTO #Rcth_P1
                     (Batch_DATE,
                      SourceBatch_CODE,
                      Batch_NUMB,
                      SeqReceipt_NUMB,
                      SourceReceipt_CODE,
                      TypeRemittance_CODE,
                      TypePosting_CODE,
                      Case_IDNO,
                      PayorMCI_IDNO,
                      Receipt_AMNT,
                      ToDistribute_AMNT,
                      Fee_AMNT,
                      Employer_IDNO,
                      Fips_CODE,
                      Check_DATE,
                      CheckNo_TEXT,
                      Receipt_DATE,
                      Distribute_DATE,
                      Tanf_CODE,
                      TaxJoint_CODE,
                      TaxJoint_NAME,
                      StatusReceipt_CODE,
                      ReasonStatus_CODE,
                      BackOut_INDC,
                      ReasonBackOut_CODE,
                      Refund_DATE,
                      Release_DATE,
                      ReferenceIrs_IDNO,
                      RefundRecipient_ID,
                      RefundRecipient_CODE,
                      BeginValidity_DATE,
                      EndValidity_DATE,
                      EventGlobalBeginSeq_NUMB,
                      EventGlobalEndSeq_NUMB)
         SELECT Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceReceipt_CODE,
                TypeRemittance_CODE,
                TypePosting_CODE,
                Case_IDNO,
                PayorMCI_IDNO,
                Receipt_AMNT,
                ToDistribute_AMNT,
                Fee_AMNT,
                Employer_IDNO,
                Fips_CODE,
                Check_DATE,
                CheckNo_TEXT,
                Receipt_DATE,
                Distribute_DATE,
                Tanf_CODE,
                TaxJoint_CODE,
                TaxJoint_NAME,
                StatusReceipt_CODE,
                ReasonStatus_CODE,
                BackOut_INDC,
                ReasonBackOut_CODE,
                Refund_DATE,
                Release_DATE,
                ReferenceIrs_IDNO,
                RefundRecipient_ID,
                RefundRecipient_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB
           FROM RCTH_Y1  r
          WHERE r.Batch_DATE = @Ld_RcthCur_Batch_DATE
            AND r.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
            AND r.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
            AND r.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
            AND r.EventGlobalBeginSeq_NUMB = @Ln_RcthCur_EventGlobalBeginSeq_NUMB;

         SET @Ls_Sql_TEXT = 'MERGE_INSERT_RCTH_Y1 ';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_RcthCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRrel_NUMB AS VARCHAR ),'') + ', StatusReceipt_CODE = ' + @Lc_StatusReceiptIdentified_CODE;
         -- Insert a New Record in receipt  though it has been done by the Release receipt Program         
         IF (SELECT 1
               FROM RCTH_Y1  t
              WHERE t.Batch_DATE = @Ld_RcthCur_Batch_DATE
                AND t.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
                AND t.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
                AND t.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
                AND t.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeqRrel_NUMB) > 0
          BEGIN
           SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 - MERGE';           
           SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_RcthCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRrel_NUMB AS VARCHAR ),'');

           UPDATE RCTH_Y1
              SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_RcthCur_ToDistribute_AMNT
            WHERE Batch_DATE = @Ld_RcthCur_Batch_DATE
              AND SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
              AND Batch_NUMB = @Ln_RcthCur_Batch_NUMB
              AND SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
              AND StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
              AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeqRrel_NUMB;
          END
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 - MERGE';           
           SET @Ls_Sqldata_TEXT = 'Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRrel_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'');

           INSERT INTO RCTH_Y1
                       (Batch_DATE,
                        SourceBatch_CODE,
                        Batch_NUMB,
                        SeqReceipt_NUMB,
                        SourceReceipt_CODE,
                        TypeRemittance_CODE,
                        TypePosting_CODE,
                        Case_IDNO,
                        PayorMCI_IDNO,
                        Receipt_AMNT,
                        ToDistribute_AMNT,
                        Fee_AMNT,
                        Employer_IDNO,
                        Fips_CODE,
                        Check_DATE,
                        CheckNo_TEXT,
                        Receipt_DATE,
                        Distribute_DATE,
                        Tanf_CODE,
                        TaxJoint_CODE,
                        TaxJoint_NAME,
                        StatusReceipt_CODE,
                        ReasonStatus_CODE,
                        BackOut_INDC,
                        ReasonBackOut_CODE,
                        Refund_DATE,
                        Release_DATE,
                        ReferenceIrs_IDNO,
                        RefundRecipient_ID,
                        RefundRecipient_CODE,
                        BeginValidity_DATE,
                        EndValidity_DATE,
                        EventGlobalBeginSeq_NUMB,
                        EventGlobalEndSeq_NUMB)
           SELECT p.Batch_DATE,
                  p.SourceBatch_CODE,
                  p.Batch_NUMB,
                  p.SeqReceipt_NUMB,
                  p.SourceReceipt_CODE,
                  p.TypeRemittance_CODE,
                  p.TypePosting_CODE,
                  p.Case_IDNO,
                  p.PayorMCI_IDNO,
                  p.Receipt_AMNT,
                  p.ToDistribute_AMNT,
                  p.Fee_AMNT,
                  p.Employer_IDNO,
                  p.Fips_CODE,
                  p.Check_DATE,
                  p.CheckNo_TEXT,
                  p.Receipt_DATE,
                  @Ld_Low_DATE AS Distribute_DATE,-- Distribute_DATE
                  p.Tanf_CODE,
                  p.TaxJoint_CODE,
                  p.TaxJoint_NAME,
                  @Lc_StatusReceiptIdentified_CODE AS StatusReceipt_CODE,-- StatusReceipt_CODE
                  p.ReasonStatus_CODE,
                  @Lc_No_INDC AS BackOut_INDC,-- BackOut_INDC
                  @Lc_Space_TEXT AS ReasonBackOut_CODE,-- ReasonBackOut_CODE	
                  p.Refund_DATE,
                  @Ld_Process_DATE AS Release_DATE,-- Release_DATE                                               
                  p.ReferenceIrs_IDNO,
                  p.RefundRecipient_ID,
                  p.RefundRecipient_CODE,
                  @Ld_Process_DATE AS BeginValidity_DATE,-- BeginValidity_DATE  
                  @Ld_High_DATE AS EndValidity_DATE,-- EndValidity_DATE    
                  @Ln_EventGlobalSeqRrel_NUMB AS EventGlobalBeginSeq_NUMB,-- EventGlobalBeginSeq_NUMB
                  0 AS EventGlobalEndSeq_NUMB -- EventGlobalEndSeq_NUMB 
             FROM #Rcth_P1 p;
          END

         SET @Ln_EventGlobalReceiptSeq_NUMB = @Ln_EventGlobalSeqRrel_NUMB;
         SET @Ls_Sql_TEXT = 'DELETE_PRREL_1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_RcthCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

         DELETE PRREL_Y1
          WHERE Batch_DATE = @Ld_RcthCur_Batch_DATE
            AND SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
            AND Batch_NUMB = @Ln_RcthCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
            AND EventGlobalBeginSeq_NUMB = @Ln_RcthCur_EventGlobalBeginSeq_NUMB;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
          AND @Ln_Remaining_AMNT = @Ln_RcthCur_ToDistribute_AMNT
          AND @Lc_RcthCur_ReleasedFrom_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
          AND @Lc_RcthCur_AutomaticRelease_INDC = @Lc_Yes_INDC
        BEGIN
         SET @Ls_Sql_TEXT = 'DELETE_PRREL_2';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_RcthCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_RcthCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_RcthCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

         DELETE PRREL_Y1
          WHERE Batch_DATE = @Ld_RcthCur_Batch_DATE
            AND SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
            AND Batch_NUMB = @Ln_RcthCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
            AND EventGlobalBeginSeq_NUMB = @Ln_RcthCur_EventGlobalBeginSeq_NUMB;

         GOTO Next_Rec;
        END

       -- Processing the NIVD Money before inserting the Record in Log Support
       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_LSUP';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', ReceiptOrig_DATE = ' + ISNULL(CAST( @Ld_ReceiptOrig_DATE AS VARCHAR ),'');

       EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_LSUP
        @Ad_Batch_DATE            = @Ld_Batch_DATE,
        @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB            = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,
        @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE,
        @Ac_TypePosting_CODE      = @Lc_TypePosting_CODE,
        @An_PayorMCI_IDNO         = @Ln_PayorMCI_IDNO,
        @Ad_Receipt_DATE          = @Ld_Receipt_DATE,
        @Ad_ReceiptOrig_DATE      = @Ld_ReceiptOrig_DATE,
        @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
        @Ad_Process_DATE          = @Ld_Process_DATE OUTPUT,
        @Ac_ReleasedFrom_CODE     = @Lc_ReleasedFrom_CODE OUTPUT,
        @Ac_VoluntaryProcess_INDC = @Lc_VoluntaryProcess_INDC OUTPUT,
        @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;
         RAISERROR (50001,16,1);
        END

       IF @Ln_Remaining_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_GET_REMAIN_MONEY_REAS_CODE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', TypePostingOriginal_CODE = ' + ISNULL(@Lc_TypePostingOriginal_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_TaxJoint_CODE,'') + ', Receipt_DATE = ' + ISNULL(CAST(@Ld_Receipt_DATE AS VARCHAR),'');

         EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_GET_REMAIN_MONEY_REAS_CODE
          @An_Case_IDNO                = @Ln_Case_IDNO,
          @An_PayorMCI_IDNO            = @Ln_PayorMCI_IDNO,
          @Ac_TypePosting_CODE         = @Lc_TypePosting_CODE,
          @Ac_TypePostingOriginal_CODE = @Lc_TypePostingOriginal_CODE,
          @Ac_SourceReceipt_CODE       = @Lc_SourceReceipt_CODE,
          @Ac_TaxJoint_CODE            = @Lc_TaxJoint_CODE,
          @Ad_Receipt_DATE             = @Ld_Receipt_DATE,
          @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ad_Process_DATE             = @Ld_Process_DATE OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;

           RAISERROR (50001,16,1);
          END

         SET @Ld_Release_DATE = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_HELD_MONEY_RELEASE_DATE (@Lc_ReasonStatus_CODE, @Ld_Process_DATE);
        END

       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

       EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD
        @Ad_Batch_DATE            = @Ld_Batch_DATE,
        @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB            = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,
        @Ad_Receipt_DATE          = @Ld_Receipt_DATE,
        @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE,
        @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
        @Ad_Process_DATE          = @Ld_Process_DATE OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH - 2';
	   SET @Ln_Temp_Remaining_AMNT = @Ln_Remaining_AMNT;
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePostingOriginal_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_Receipt_AMNT AS VARCHAR ),'')+ ', Remaining_AMNT = ' + ISNULL(CAST( @Ln_Temp_Remaining_AMNT AS VARCHAR ),'')+ ', EventGlobalReceiptSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalReceiptSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', ReleaseIn_DATE = ' + ISNULL(CAST( @Ld_Release_DATE AS VARCHAR ),'');

       EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH
        @Ad_Batch_DATE                 = @Ld_Batch_DATE,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
        @An_Case_IDNO                  = @Ln_Case_IDNO,
        @An_PayorMCI_IDNO              = @Ln_PayorMCI_IDNO,
        @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
        @Ac_TypePosting_CODE           = @Lc_TypePostingOriginal_CODE,
        @Ac_ReasonStatus_CODE          = @Lc_ReasonStatus_CODE,
        @An_Receipt_AMNT               = @Ln_Receipt_AMNT,
        @An_Remaining_AMNT             = @Ln_Temp_Remaining_AMNT,
        @An_EventGlobalReceiptSeq_NUMB = @Ln_EventGlobalReceiptSeq_NUMB,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
        @Ad_ReleaseIn_DATE             = @Ld_Release_DATE,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
        @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT,
        @Ac_ReleasedFrom_CODE          = @Lc_ReleasedFrom_CODE OUTPUT,
        @Ad_Release_DATE               = @Ld_Release_DATE OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;
         RAISERROR (50001,16,1);
        END
      END

     NEXT_REC:
	 SET @Ls_Sql_TEXT = 'DELETE #Towed_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Towed_P1;
     
	 SET @Ls_Sql_TEXT = 'DELETE #Tpaid_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Tpaid_P1;
     
	 SET @Ls_Sql_TEXT = 'DELETE #Ttpad_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Ttpad_P1;
     
	 SET @Ls_Sql_TEXT = 'DELETE #Texpt_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Texpt_P1;
     
	 SET @Ls_Sql_TEXT = 'DELETE #Tprtl_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Tprtl_P1;
     
     SET @Ls_Sql_TEXT = 'DELETE #Tcord_P1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE #Tcord_P1;
     
	 SET @Ls_Sql_TEXT = 'DELETE #Tbump_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Tbump_P1;
     
     SET @Ls_Sql_TEXT = 'DELETE #Tcarr_P1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE #Tcarr_P1;
     
	 SET @Ls_Sql_TEXT = 'DELETE #Ttowd_P1';
	 SET @Ls_Sqldata_TEXT = '';

     DELETE #Ttowd_P1;

     SET @Ls_Sql_TEXT = 'DELETE #Rcth_P1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE #Rcth_P1;

     SET @Lc_ProcessFlag_INDC = @Lc_Yes_INDC;
     SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG';
     SET @Ls_Sqldata_TEXT = 'RecordRow_NUMB = ' + ISNULL(CAST( @Ln_Record_NUMB AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_ProcessFlag_INDC,'');

     EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG
      @An_RecordRow_NUMB        = @Ln_Record_NUMB,
      @Ac_Process_INDC          = @Lc_ProcessFlag_INDC,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;

       RAISERROR (50001,16,1);
      END      
      END TRY
      BEGIN CATCH 
	  IF @Lc_ProcFailException_INDC = '' 
	  BEGIN
		 SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;
	  END 
      IF XACT_STATE() = 1
        BEGIN
           ROLLBACK TRANSACTION SaveRegDistTran;
        END
      ELSE
        BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
            RAISERROR( 50001 ,16,1);
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

      SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateError_CODE = ' + @Lc_BateError_CODE + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;
	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_CursorRecordCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
             
      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END 

		 SET @Ls_Sql_TEXT = 'ExceptionThresholdCountCheck';
		 SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

		 IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
		  BEGIN
			  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CREATE_RCTH_HOLD-SNER';
			  SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'') + ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

			  EXECUTE BATCH_COMMON$SP_CREATE_RCTH_HOLD
				@Ad_Batch_DATE               = @Ld_Batch_DATE,
				@Ac_SourceBatch_CODE         = @Lc_SourceBatch_CODE,
				@An_Batch_NUMB               = @Ln_Batch_NUMB,
				@An_SeqReceipt_NUMB          = @Ln_SeqReceipt_NUMB,
				@Ad_Run_DATE                 = @Ld_Run_DATE,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

			  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			   BEGIN
				RAISERROR (50001,16,1);
			   END     
		  END

       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG';
       SET @Ls_Sqldata_TEXT = 'RecordRow_NUMB = ' + ISNULL(CAST( @Ln_Record_NUMB AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_StatusAbnormalend_CODE,'');
	   EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG
		@An_RecordRow_NUMB        = @Ln_Record_NUMB,
		@Ac_Process_INDC          = @Lc_StatusAbnormalend_CODE,
		@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Lc_ProcFailException_INDC = @Lc_Yes_INDC;

       RAISERROR (50001,16,1);
      END    
		   
      END CATCH

     IF @Ln_CommitFreqParm_QNTY <> 0
      BEGIN
       IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
                
         SET @Ls_RestartKey_TEXT = @Ls_CursorLoc_TEXT;
         
		 SET @Ls_Sql_TEXT = 'JRTL_Y1 UPDATE ';  
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Thread_NUMB = ' + ISNULL(CAST( @An_Thread_NUMB AS VARCHAR ),'');

         UPDATE JRTL_Y1
            SET RecRestart_NUMB = @Ln_Record_NUMB + 1,
                RestartKey_TEXT = @Ls_RestartKey_TEXT
           FROM JRTL_Y1 AS a
          WHERE a.Job_ID = @Lc_Job_ID
            AND a.Run_DATE = @Ld_Run_DATE
            AND a.Thread_NUMB = @An_Thread_NUMB;

         COMMIT TRANSACTION RegDistTran -- 1
         SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
         BEGIN TRANSACTION RegDistTran -- 2
         SET @Ln_CommitFreq_QNTY = 0;
        END
      END
           
     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
           
	  IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION RegDistTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = @Ls_Err0003_TEXT + '-' + @Ls_DescriptionError_TEXT;
       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'FETCH Rcth_CUR- 2';     
     SET @Ls_Sqldata_TEXT = '';
     
     FETCH NEXT FROM Rcth_CUR INTO @Ln_RcthCur_RecordRowNumber_NUMB, @Ld_RcthCur_Batch_DATE, @Lc_RcthCur_SourceBatch_CODE, @Ln_RcthCur_Batch_NUMB, @Ln_RcthCur_SeqReceipt_NUMB, @Lc_RcthCur_SourceReceipt_CODE, @Lc_RcthCur_TypePosting_CODE, @Ln_RcthCur_Case_IDNO, @Ln_RcthCur_PayorMCI_IDNO, @Ln_RcthCur_ToDistribute_AMNT, @Ld_RcthCur_Receipt_DATE, @Ln_RcthCur_Check_NUMB, @Lc_RcthCur_Tanf_CODE, @Lc_RcthCur_TaxJoint_CODE, @Ln_RcthCur_EventGlobalBeginSeq_NUMB, @Lc_RcthCur_ReleasedFrom_CODE, @Lc_RcthCur_AutomaticRelease_INDC, @Lc_RcthCur_Process_INDC,@Lc_RcthCur_Priority_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Rcth_CUR;

   DEALLOCATE Rcth_CUR;

	SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'SELECT PDIST_Y1 COUNT';   
   SET @Ls_Sqldata_TEXT = 'Process_CODE = ' + ISNULL(@Lc_No_INDC,'');

   SELECT @Ln_PdistNotProcessRecord_QNTY = COUNT (1)
     FROM PDIST_Y1 p
    WHERE p.Process_CODE = @Lc_No_INDC;
    
   SET @Ls_Sql_TEXT = 'SELECT JRTL_Y1 COUNT';   
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'') + ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'') + ', ThreadProcess_CODE = ' + ISNULL(@Lc_No_INDC,'');

   SELECT @Ln_JrtlNotProcessThread_QNTY = COUNT (1)
     FROM JRTL_Y1 p
    WHERE Job_ID = @Lc_Job_ID
	  AND Run_DATE = @Ld_Run_DATE
	  AND ThreadProcess_CODE = @Lc_No_INDC;

   --PARM date will be updated only if all the threads are completed.
   --The above check determines whether all records are processed thro the thread
   IF @Ln_PdistNotProcessRecord_QNTY = 0 AND @Ln_JrtlNotProcessThread_QNTY = 0
    BEGIN
     -- Update the daily_date field for this procedure in PARM_Y1 table with the pd_dt_run value
     SET @Ls_Sql_TEXT = 'DIST020 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'');

     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID                = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG UPDATE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Create_DATE AS VARCHAR ),'') + ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrorMessage_TEXT,'') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'') + ', RecRestart_NUMB = ' + ISNULL(CAST(@Ln_Record_NUMB AS VARCHAR),'')+ ', Thread_NUMB = ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR),'') + ', RestartKey_TEXT = ' + ISNULL(@Ls_RestartKey_TEXT,'')+ ', ThreadProcess_CODE = ' + ISNULL(@Lc_Yes_INDC,'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Create_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @An_RecRestart_NUMB			= @Ln_Record_NUMB,
    @An_Thread_NUMB				= @An_Thread_NUMB,
    @As_RestartKey_TEXT			= @Ls_RestartKey_TEXT,
    @Ac_ThreadProcess_CODE		= @Lc_Yes_INDC;

   COMMIT TRANSACTION RegDistTran -- 2
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION RegDistTran
    END

   IF CURSOR_STATUS ('LOCAL', 'Rcth_CUR') IN (0, 1)
    BEGIN
     CLOSE Rcth_CUR;

     DEALLOCATE Rcth_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB = 50001
    BEGIN
     IF (@Lc_ProcFailException_INDC = @Lc_Yes_INDC)
      BEGIN
       UPDATE JRTL_Y1
          SET RestartKey_TEXT = ISNULL (@Ls_RestartKey_TEXT, RestartKey_TEXT),
              ThreadProcess_CODE = @Lc_StatusAbnormalend_CODE
        WHERE Thread_NUMB = @An_Thread_NUMB
          AND ThreadProcess_CODE = @Lc_ThreadProcess_CODE
          AND Job_ID = @Lc_Job_ID
          AND Run_DATE = @Ld_Run_DATE;
      END

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Create_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY,
    @An_RecRestart_NUMB			= 0,
    @An_Thread_NUMB				= @An_Thread_NUMB,
    @As_RestartKey_TEXT			= @Ls_RestartKey_TEXT,
    @Ac_ThreadProcess_CODE		= @Lc_StatusAbnormalend_CODE;

   EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_PDIST_UPDATE_FLAG
    @An_RecordRow_NUMB        = @Ln_Record_NUMB,
    @Ac_Process_INDC          = @Lc_StatusAbnormalend_CODE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
