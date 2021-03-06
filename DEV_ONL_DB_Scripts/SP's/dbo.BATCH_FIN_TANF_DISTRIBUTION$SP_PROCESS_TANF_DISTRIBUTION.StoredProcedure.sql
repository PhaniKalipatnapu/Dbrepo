/****** Object:  StoredProcedure [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_PROCESS_TANF_DISTRIBUTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_TANF_DISTRIBUTION$SP_PROCESS_TANF_DISTRIBUTION
Programmer Name 	: IMP Team
Description			: The BATCH_FIN_TANF_DISTRIBUTION$SP_PROCESS_TANF_DISTRIBUTION process records from the Distribution 
					  Hold (DHLD_Y1) table which have either Daily Disbursement Holds or TANF Holds and processes 
					  payments applied by BATCH_FIN_REG_DISTRIBUTION process towards TANF arrears and uses it to recover 
					  URA arrears.
Frequency			: 'MONTHLY'
Developed On		: 03/24/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_PROCESS_TANF_DISTRIBUTION]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Record type to store the obligations that requires re-assigning of arrears
  CREATE TABLE #AssignArr_P1
   (
     Case_IDNO             NUMERIC(6),
     OrderSeq_NUMB         NUMERIC(2),
     ObligationSeq_NUMB    NUMERIC(2),
     WelfareYearMonth_NUMB NUMERIC(6),
     Row_NUMB              NUMERIC(19) IDENTITY
   );

 -- Defect 13319 - PA arrears in excess of URA not always moving to UDA - Fix -- Start --
  CREATE TABLE #IVACaseCpAssociatedIVDCaseOblg_P1
   (
     Case_IDNO             NUMERIC(6),
     OrderSeq_NUMB         NUMERIC(2),
     ObligationSeq_NUMB    NUMERIC(2),
     WelfareYearMonth_NUMB NUMERIC(6),
     Row_NUMB              NUMERIC(19) IDENTITY
   );   
  -- Defect 13319 - PA arrears in excess of URA not always moving to UDA - Fix -- End --

  CREATE TABLE #EsemHold_P1
   (
     TypeEntity_CODE CHAR (5),
     Entity_ID       CHAR(30),
     Row_NUMB        NUMERIC(19) IDENTITY
   );

  CREATE TABLE #EsemDist_P1
   (
     TypeEntity_CODE CHAR (5),
     Entity_ID       CHAR(30),
     Row_NUMB        NUMERIC(19) IDENTITY
   );

  DECLARE  @Ln_HoldCount_QNTY                  NUMERIC(9) = 1,
           @Ln_DistCount_QNTY                  NUMERIC(9) = 1,
           @Ln_CheckRecipientOsr_IDNO          NUMERIC(9) = 999999980,
           @Li_TanfDistribution1830_NUMB       INT = 1830,
           @Li_TanfDisbursementHold1840_NUMB   INT = 1840,
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_TypeErrorE_CODE				   CHAR(1) = 'E',
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_RecipientTypeOthp_CODE          CHAR(1) = '3',
           @Lc_WelfareTypeTanf_CODE            CHAR(1) = 'A',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_OrderTypeVoluntary_CODE         CHAR(1) = 'V',
           @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_DisbursementStatusRelease_CODE  CHAR(1) = 'R',
           @Lc_RegularHoldD_CODE               CHAR(1) = 'D',
           @Lc_TanfHoldT_CODE                  CHAR(1) = 'T',
           @Lc_DisbursementStatusHeld_CODE     CHAR(1) = 'H',
           @Lc_Grant_INDC                      CHAR(1) = 'N',
           @Lc_TypeErrorWarning_CODE           CHAR(1) = 'W',
		   -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - Start --
		   @Lc_CaseRelationshipC_CODE		   CHAR(1) = 'C',		   
		   @Lc_CaseMemberStatusA_CODE		   CHAR(1) = 'A',
		   -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - End --
           @Lc_ReceiptSrcInterstativdfee_CODE  CHAR(2) = 'FF',
           @Lc_DeStateFips_CODE                CHAR(2) = '10',
           @Lc_ReceiptSrcVoluntary_CODE        CHAR(2) = 'VN',
           @Lc_SourceBatchCheck_CODE           CHAR(3) = ' ',
           @Lc_ReasonStatusDr_CODE             CHAR(4) = 'DR',
           @Lc_ReasonStatusSdnm_CODE           CHAR(4) = 'SDNM',
           @Lc_ReasonStatusSdng_CODE           CHAR(4) = 'SDNG',
           @Lc_ReasonStatusSdux_CODE           CHAR(4) = 'SDUX',
           @Lc_TypeDisbursementGrant_CODE      CHAR(4) = 'GRNT',
           @Lc_TypeDisbursementExcs_CODE       CHAR(4) = 'EXCS',
           @Lc_TypeDisbursementHold_CODE       CHAR(4) = 'HOLD',
           @Lc_TypeDisbursementAhpaa_CODE      CHAR(5) = 'AHPAA',
           @Lc_TypeDisbursementChpaa_CODE      CHAR(5) = 'CHPAA',
           @Lc_TypeDisbursementAzpaa_CODE      CHAR(5) = 'AZPAA',
           @Lc_TypeDisbursementCzpaa_CODE      CHAR(5) = 'CZPAA',
           @Lc_TypeDisbursementPgpaa_CODE      CHAR(5) = 'PGPAA',
           @Lc_TypeDisbursementAgpaa_CODE      CHAR(5) = 'AGPAA',
           @Lc_TypeDisbursementCxpaa_CODE      CHAR(5) = 'CXPAA',
           @Lc_TypeDisbursementAxpaa_CODE      CHAR(5) = 'AXPAA',
           @Lc_EntityRctno_TEXT                CHAR(5) = 'RCTNO',
           @Lc_EntityDthld_TEXT                CHAR(5) = 'DTHLD',
           @Lc_EntityCase_TEXT                 CHAR(5) = 'CASE',
           @Lc_EntityOrder_TEXT                CHAR(5) = 'ORDER',
           @Lc_EntityOble_TEXT                 CHAR(5) = 'OBLE',
           @Lc_EntityDstdt_TEXT                CHAR(5) = 'DSTDT',
           @Lc_EntityWcase_TEXT                CHAR(5) = 'WCASE',
           @Lc_ErrorNoRecordsE0944_CODE        CHAR(5) = 'E0944',
           @Lc_ErrorE1424_CODE				   CHAR(5) = 'E1424',
           @Lc_Job_ID                          CHAR(7) = 'DEB0580',
           @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_ID                 CHAR(30) = 'BATCH',
           @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_TANF_DISTRIBUTION',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS_TANF_DISTRIBUTION',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001',
           @Ld_BatchCheck_DATE                 DATE = '01/01/0001';
  DECLARE  @Ln_Value_NUMB                    NUMERIC(1),
           @Ln_OrderSeq_NUMB                 NUMERIC(2),
           @Ln_ObligationSeq_NUMB            NUMERIC(2),
           @Ln_Batch_NUMB                    NUMERIC(4),
           @Ln_BatchCheck_NUMB               NUMERIC(4) = 0,
           @Ln_CommitFreqParm_QNTY           NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY   NUMERIC(5),
           @Ln_ExceptionThreshold_QNTY       NUMERIC(5) = 0,
           @Ln_CommitFreq_QNTY               NUMERIC(5) = 0,
           @Ln_EsemDistCount_QNTY            NUMERIC(5),
           @Ln_ProcessWelfareYearMonth_NUMB  NUMERIC(6),
           @Ln_ProcessedRecordCount_QNTY     NUMERIC(6) = 0,
           @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
           @Ln_Case_IDNO                     NUMERIC(6),
           @Ln_SeqReceipt_NUMB               NUMERIC(6),
           @Ln_ReceiptWelfareYearMonth_NUMB  NUMERIC(6),
           @Ln_SeqReceiptCheck_NUMB          NUMERIC(6) = 0,
           @Ln_CursorRecordCount_QNTY        NUMERIC(9) = 0,
           @Ln_RecordCount_QNTY              NUMERIC(9),
           @Ln_MemberMci_IDNO                NUMERIC(10),
           @Ln_CpMci_IDNO                    NUMERIC(10),
           @Ln_CaseWelfare_IDNO              NUMERIC(10),
           @Ln_CaseWelfarePrim_IDNO          NUMERIC(10),
           @Ln_Paa_AMNT                      NUMERIC(11,2) = 0,
           @Ln_Arrear_AMNT                   NUMERIC(11,2) = 0,
           @Ln_ArrearApp_AMNT                NUMERIC(11,2) = 0,
           @Ln_ArrearAppTot_AMNT             NUMERIC(11,2) = 0,
           @Ln_ExpandAsst_AMNT               NUMERIC(11,2) = 0,
           @Ln_TransactionCurSup_AMNT        NUMERIC(11,2),
           @Ln_ArrearAppIva_AMNT             NUMERIC(11,2) = 0,
           @Ln_GrantPaidPaa_AMNT             NUMERIC(11,2) = 0,
           @Ln_MtdUrg_AMNT                   NUMERIC(11,2) = 0,
           @Ln_MtdApp_AMNT                   NUMERIC(11,2) = 0,
           @Ln_MtdApp_QNTY                   NUMERIC(11,2) = 0,
           @Ln_MtdAppIva_AMNT                NUMERIC(11,2) = 0,
           @Ln_Error_NUMB                    NUMERIC(11),
           @Ln_ErrorLine_NUMB                NUMERIC(11),
           @Ln_Order_IDNO                    NUMERIC(15),
           @Ln_EventGlobalSeq_NUMB           NUMERIC(19),
           @Ln_EventGlobalHoldSeq_NUMB       NUMERIC(19),
           @Li_FetchStatus_QNTY              SMALLINT,
           @Li_Rowcount_QNTY                 SMALLINT,
           @Lc_Msg_CODE                      CHAR(1),
           @Lc_TypeError_CODE                CHAR(1),
           @Lc_DistWcaseFlag_INDC            CHAR(1),
           @Lc_AssignFlag_INDC               CHAR(1),
           @Lc_WelfareCaseFlag_INDC          CHAR(1),
           @Lc_Wemo_INDC                     CHAR(1),
           @Lc_WemoProcess_INDC              CHAR(1),
           @Lc_TypeWelfare_CODE              CHAR(1),
           @Lc_InsertEsem_INDC               CHAR(1),
           @Lc_AllwemoProcessed_INDC         CHAR(1),
           @Lc_AllwemoCurOpen_INDC           CHAR(1),
           @Lc_TypeOrder_CODE                CHAR(1),
           @Lc_SourceReceipt_CODE            CHAR(2),
           @Lc_SourceBatch_CODE              CHAR(3),
           @Lc_BateError_CODE                CHAR(5),
           @Lc_Fips_CODE                     CHAR(7),
           @Lc_DateProcessMmddyyyy_TEXT      CHAR(30),
           @Lc_Receipt_ID                    CHAR(30),
           @Lc_Oble_TEXT                     CHAR(30),
           @Ls_Sql_TEXT                      VARCHAR(100),
           @Ls_CursorLoc_TEXT                VARCHAR(200),
           @Ls_Sqldata_TEXT                  VARCHAR(1000),
           @Ls_ErrorMessage_TEXT             VARCHAR(2000),
           @Ls_DescriptionError_TEXT         VARCHAR(4000),
           @Ls_BateRecord_TEXT				 VARCHAR(4000) = '',
           @Ld_Run_DATE                      DATE,
           @Ld_Process_DATE                  DATE,
           @Ld_Batch_DATE                    DATE,
           @Ld_Receipt_DATE                  DATE,
           @Ld_Begin_DATE                    DATE,
           @Ld_LastRun_DATE                  DATE,
           @Ld_Create_DATE                   DATETIME2;
  DECLARE  @Ln_AllWemoCur_WemoOrderSeq_NUMB        NUMERIC(2),
           @Ln_AllWemoCur_WemoObligationSeq_NUMB   NUMERIC(2),
           @Ln_TanfCur_OrderSeq_NUMB               NUMERIC(2),
           @Ln_TanfCur_ObligationSeq_NUMB          NUMERIC(2),
           @Ln_TanfCur_Batch_NUMB                  NUMERIC(4),
           @Ln_AssignArrCur_Row_NUMB               NUMERIC(19),
           @Ln_EsemDistCur_Row_NUMB                NUMERIC(19),
           @Ln_AssignArrCur_Case_IDNO              NUMERIC(6),
           @Ln_AllWemoCur_WelfareYearMonth_NUMB    NUMERIC(6),
           @Ln_AllWemoCur_WemoCase_IDNO            NUMERIC(6),
           @Ln_TanfCur_SeqReceipt_NUMB             NUMERIC(6),
           @Ln_TanfCur_Case_IDNO                   NUMERIC(6),
           @Ln_TanfCur_CheckRecipient_IDNO         NUMERIC(10),
           @Ln_AssignArrCur_Order_NUMB             NUMERIC(11,2),
           @Ln_AssignArrCur_Obligation_NUMB        NUMERIC(11,2),
           @Ln_AssignArrCur_Welfare_NUMB           NUMERIC(11,2),
           @Ln_AllWemoCur_ExpandTotAsst_AMNT       NUMERIC(11,2) = 0,
           @Ln_AllWemoCur_RecupTotAsst_AMNT        NUMERIC(11,2) = 0,
           @Ln_AllWemoCur_Urg_AMNT                 NUMERIC(11,2) = 0,
           @Ln_AllWemoCur_MtdAssistExpend_AMNT     NUMERIC(11,2),
           @Ln_AllWemoCur_MtdAssistRecoup_AMNT     NUMERIC(11,2) = 0,
           @Ln_TanfCur_TransactionCurSup_AMNT      NUMERIC(11,2),
           @Ln_TanfCur_TransactionPaa_AMNT         NUMERIC(11,2),
           @Ln_TanfCur_Seq_IDNO                    NUMERIC(19),
           @Ln_TanfCur_EventGlobalSupportSeq_NUMB  NUMERIC(19),
           @Ln_TanfCur_EventGlobalBeginSeq_NUMB    NUMERIC(19),
           @Ln_TanfCur_Unique_IDNO                 NUMERIC(19),
           @Lc_TanfCur_CheckRecipient_CODE         CHAR(1),
           @Lc_TanfCur_TypeHold_CODE               CHAR(1),
           @Lc_TanfCur_SourceBatch_CODE            CHAR(3),
           @Lc_EsemDistCur_TypeEntity_CODE         CHAR(5),
           @Lc_TanfCur_TypeDisburse_CODE           CHAR(5),
           @Lc_TanfCur_CheckRecipient_ID           CHAR(10),
           @Lc_EsemDistCur_Entity_ID               CHAR(30),
           @Ld_TanfCur_Batch_DATE                  DATE,
           @Ld_TanfCur_Receipt_DATE                DATE,
           @Ld_TanfCur_Transaction_DATE            DATE;

  BEGIN TRY
   SET @Ld_Create_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
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
   SET @Lc_DateProcessMmddyyyy_TEXT = REPLACE(CONVERT(VARCHAR(10), @Ld_Process_DATE, 101), '/', '');
   SET @Ln_ProcessWelfareYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_Process_DATE,112),1,6);

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END

   DECLARE Tanf_CUR INSENSITIVE CURSOR FOR
   SELECT CASE a.TypeDisburse_CODE
               WHEN @Lc_TypeDisbursementChpaa_CODE
                THEN 1
               WHEN @Lc_TypeDisbursementAhpaa_CODE
                THEN 2
              END AS Seq_IDNO,
              a.Batch_DATE,
              a.SourceBatch_CODE,
              a.Batch_NUMB,
              a.SeqReceipt_NUMB,
              a.Release_DATE AS Receipt_DATE,
              a.Case_IDNO,
              a.OrderSeq_NUMB,
              a.ObligationSeq_NUMB,
              CASE
               WHEN a.TypeDisburse_CODE = @Lc_TypeDisbursementChpaa_CODE
                THEN a.Transaction_AMNT
               ELSE 0
              END AS TransactionCurSup_AMNT,
              CASE
               WHEN a.TypeDisburse_CODE = @Lc_TypeDisbursementAhpaa_CODE
                THEN a.Transaction_AMNT
               ELSE 0
              END AS TransactionPaa_AMNT,
              a.TypeDisburse_CODE,
              a.EventGlobalSupportSeq_NUMB ,
              a.EventGlobalBeginSeq_NUMB ,
              a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.TypeHold_CODE,
              a.Unique_IDNO,
              a.Transaction_DATE,
              a.CheckRecipient_ID
         FROM DHLD_Y1  a
        WHERE a.TypeHold_CODE IN (@Lc_RegularHoldD_CODE, @Lc_TanfHoldT_CODE)
          AND a.Status_CODE = @Lc_DisbursementStatusHeld_CODE
          AND a.TypeDisburse_CODE IN (@Lc_TypeDisbursementChpaa_CODE, @Lc_TypeDisbursementAhpaa_CODE)
          AND a.Release_DATE <= @Ld_Process_DATE
          AND a.EndValidity_DATE = @Ld_High_DATE    
        ORDER BY Seq_IDNO,
                 a.Batch_DATE,
                 a.SourceBatch_CODE,
                 a.Batch_NUMB,
                 a.SeqReceipt_NUMB;
                 
   SET @Ls_Sql_TEXT = 'OPEN TanfCur - 1';   
   SET @Ls_Sqldata_TEXT = '';
   
   OPEN Tanf_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TanfCur - 1';   
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH Tanf_CUR INTO @Ln_TanfCur_Seq_IDNO, @Ld_TanfCur_Batch_DATE, @Lc_TanfCur_SourceBatch_CODE, @Ln_TanfCur_Batch_NUMB, @Ln_TanfCur_SeqReceipt_NUMB, @Ld_TanfCur_Receipt_DATE, @Ln_TanfCur_Case_IDNO, @Ln_TanfCur_OrderSeq_NUMB, @Ln_TanfCur_ObligationSeq_NUMB, @Ln_TanfCur_TransactionCurSup_AMNT, @Ln_TanfCur_TransactionPaa_AMNT, @Lc_TanfCur_TypeDisburse_CODE, @Ln_TanfCur_EventGlobalSupportSeq_NUMB, @Ln_TanfCur_EventGlobalBeginSeq_NUMB, @Lc_TanfCur_CheckRecipient_ID, @Lc_TanfCur_CheckRecipient_CODE, @Lc_TanfCur_TypeHold_CODE, @Ln_TanfCur_Unique_IDNO, @Ld_TanfCur_Transaction_DATE, @Ln_TanfCur_CheckRecipient_IDNO;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE LOOP -1';   
   SET @Ls_Sqldata_TEXT = '';
   
   BEGIN TRANSACTION TanfDistTran;

--LOOP BEGIN
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN    
    BEGIN TRY
	 SAVE TRANSACTION SaveTanfDistTran;
	 
     SET @Ln_CursorRecordCount_QNTY = @Ln_CursorRecordCount_QNTY + 1;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Lc_InsertEsem_INDC = @Lc_No_INDC;
     SET @Ln_EventGlobalSeq_NUMB = 0;
     SET @Ln_Case_IDNO = @Ln_TanfCur_Case_IDNO;
     SET @Ln_OrderSeq_NUMB = @Ln_TanfCur_OrderSeq_NUMB;
     SET @Ln_ObligationSeq_NUMB = @Ln_TanfCur_ObligationSeq_NUMB;
     SET @Ln_CpMci_IDNO = @Ln_TanfCur_CheckRecipient_IDNO;
     SET @Ln_TransactionCurSup_AMNT = @Ln_TanfCur_TransactionCurSup_AMNT;
     SET @Ln_Paa_AMNT = @Ln_TanfCur_TransactionPaa_AMNT;
     SET @Ld_Batch_DATE = @Ld_TanfCur_Batch_DATE;
     SET @Lc_SourceBatch_CODE = @Lc_TanfCur_SourceBatch_CODE;
     SET @Ln_Batch_NUMB = @Ln_TanfCur_Batch_NUMB;
     SET @Ln_SeqReceipt_NUMB = @Ln_TanfCur_SeqReceipt_NUMB;
     SET @Ld_Receipt_DATE = @Ld_TanfCur_Receipt_DATE;
     SET @Ln_GrantPaidPaa_AMNT = 0;
     SET @Ln_CaseWelfarePrim_IDNO = 0;
     SET @Ls_ErrorMessage_TEXT = '';
     SET @Ln_ReceiptWelfareYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_Receipt_DATE,112),1,6);
      -- UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;

	 SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_TanfCur_Seq_IDNO AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ld_TanfCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_TanfCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_TanfCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_TanfCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ld_TanfCur_Receipt_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_TanfCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + + ISNULL(CAST(@Ln_TanfCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_TanfCur_ObligationSeq_NUMB AS VARCHAR), '') + ', TransactionCurSup_AMNT = ' + ISNULL(CAST(@Ln_TanfCur_TransactionCurSup_AMNT AS VARCHAR), '') + ', TransactionPaa_AMNT = ' + ISNULL(CAST(@Ln_TanfCur_TransactionPaa_AMNT AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_TanfCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE, '') + ', TypeHold_CODE = ' + + ISNULL(@Lc_TanfCur_TypeHold_CODE, '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_TanfCur_Unique_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + + ISNULL(CAST(@Ld_TanfCur_Transaction_DATE AS VARCHAR), '') + ', CheckRecipient_IDNO = ' + + ISNULL(CAST(@Ln_TanfCur_CheckRecipient_IDNO AS VARCHAR), '');
	 
	 SET @Ls_Sql_TEXT = 'DELETE #AssignArr_P1';     
	 SET @Ls_Sqldata_TEXT = '';

     DELETE FROM #AssignArr_P1;

     SET @Ls_CursorLoc_TEXT = 'CursorCount_QNTY = ' + CAST (@Ln_CursorRecordCount_QNTY AS VARCHAR) + ', Unique_IDNO = ' + CAST (@Ln_TanfCur_Unique_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST (@Ln_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + CAST (@Ln_ObligationSeq_NUMB AS VARCHAR) + ', Batch_DATE = ' + CAST (@Ld_TanfCur_Batch_DATE AS VARCHAR) + ', Batch_NUMB = ' + CAST (@Ln_TanfCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST (@Ln_TanfCur_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSupportSeq_NUMB = ' + CAST (@Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR);

     -- Inquire RCTH_Y1 to get the Receipt source associated with the Receipt key
     -- Re-inquire when the Receipt key is changed in the loop, since records are already sorted by the Receipt key
     IF @Ld_BatchCheck_DATE <> @Ld_TanfCur_Batch_DATE
         OR @Lc_SourceBatchCheck_CODE <> @Lc_TanfCur_SourceBatch_CODE
         OR @Ln_BatchCheck_NUMB <> @Ln_TanfCur_Batch_NUMB
         OR @Ln_SeqReceiptCheck_NUMB <> @Ln_TanfCur_SeqReceipt_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_RCTH_Y1 - 1 ';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT TOP 1 @Lc_SourceReceipt_CODE = SourceReceipt_CODE
         FROM RCTH_Y1  a
        WHERE Batch_DATE = @Ld_Batch_DATE
          AND SourceBatch_CODE = @Lc_SourceBatch_CODE
          AND Batch_NUMB = @Ln_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ld_BatchCheck_DATE = @Ld_TanfCur_Batch_DATE;
       SET @Lc_SourceBatchCheck_CODE = @Lc_TanfCur_SourceBatch_CODE;
       SET @Ln_BatchCheck_NUMB = @Ln_TanfCur_Batch_NUMB;
       SET @Ln_SeqReceiptCheck_NUMB = @Ln_TanfCur_SeqReceipt_NUMB;
      END;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_1830';     
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDistribution1830_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_TanfDistribution1830_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;

     -- Disburse the Out of state cost recovery directly to OSR.
     -- this should happen only when it is processed by TANF Distribution program for the first time (TypeHold_CODE = 'D')
     IF @Lc_TanfCur_CheckRecipient_ID = @Ln_CheckRecipientOsr_IDNO
        AND @Lc_SourceReceipt_CODE = @Lc_ReceiptSrcInterstativdfee_CODE
        AND @Lc_TanfCur_TypeHold_CODE = @Lc_RegularHoldD_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT DHLD_OSR ';       
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_TanfCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_TanfCur_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_TanfCur_SourceBatch_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusRelease_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHoldD_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', CheckRecipient_ID = ' + ISNULL(CAST( @Ln_CheckRecipientOsr_IDNO AS VARCHAR ),'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(' ','');

       INSERT DHLD_Y1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               SourceBatch_CODE,
               Transaction_DATE,
               Transaction_AMNT,
               Status_CODE,
               TypeHold_CODE,
               TypeDisburse_CODE,
               ProcessOffset_INDC,
               CheckRecipient_ID,
               CheckRecipient_CODE,
               BeginValidity_DATE,
               EndValidity_DATE,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               EventGlobalSupportSeq_NUMB,
               Release_DATE,
               ReasonStatus_CODE,
               Disburse_DATE,
               DisburseSeq_NUMB,
               StatusEscheat_DATE,
               StatusEscheat_CODE)
       VALUES ( @Ln_TanfCur_Case_IDNO,    --Case_IDNO
                @Ln_TanfCur_OrderSeq_NUMB,    --OrderSeq_NUMB
                @Ln_TanfCur_ObligationSeq_NUMB,    --ObligationSeq_NUMB
                @Ld_TanfCur_Batch_DATE,    --Batch_DATE
                @Ln_TanfCur_Batch_NUMB,    --Batch_NUMB
                @Ln_TanfCur_SeqReceipt_NUMB,    --SeqReceipt_NUMB
                @Lc_TanfCur_SourceBatch_CODE,    --SourceBatch_CODE
                @Ld_Process_DATE,   --Transaction_DATE
                @Ln_Paa_AMNT + @Ln_TransactionCurSup_AMNT,   --Transaction_AMNT
                @Lc_DisbursementStatusRelease_CODE,   --Status_CODE
                @Lc_RegularHoldD_CODE,   --TypeHold_CODE
                CASE
                 WHEN @Ln_Paa_AMNT > 0
                  THEN @Lc_TypeDisbursementAzpaa_CODE
                 WHEN @Ln_TransactionCurSup_AMNT > 0
                  THEN @Lc_TypeDisbursementCzpaa_CODE
                END,   --TypeDisburse_CODE
                @Lc_No_INDC,    --ProcessOffset_INDC
                @Ln_CheckRecipientOsr_IDNO,    --CheckRecipient_ID
                @Lc_RecipientTypeOthp_CODE,    --CheckRecipient_CODE
                @Ld_Process_DATE,    --BeginValidity_DATE
                @Ld_High_DATE,    --EndValidity_DATE
                @Ln_EventGlobalSeq_NUMB,    --EventGlobalBeginSeq_NUMB
                0,    --EventGlobalEndSeq_NUMB
                @Ln_TanfCur_EventGlobalSupportSeq_NUMB,    --EventGlobalSupportSeq_NUMB
                @Ld_Process_DATE,    --Release_DATE
                @Lc_ReasonStatusDr_CODE,    --ReasonStatus_CODE
                @Ld_Low_DATE,    --Disburse_DATE
                0,    --DisburseSeq_NUMB
                @Ld_High_DATE,    --StatusEscheat_DATE
                ' '  --StatusEscheat_CODE
			); 
       GOTO Update_Dhld;
      END;

     -- This is to fetch the Order_IDNO and oble-key for that OBLE_Y1
     SET @Ls_Sql_TEXT = 'SELECT_SORD_Y1_OBLE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_TanfCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Lc_Oble_TEXT = ISNULL (ISNULL (CAST(a.MemberMci_IDNO AS VARCHAR), '') + ISNULL (a.TypeDebt_CODE, '') + ISNULL (a.Fips_CODE, ''), @Lc_Space_TEXT),
                  @Ln_Order_IDNO = ISNULL (b.Order_IDNO, 0),
                  @Lc_TypeOrder_CODE = b.TypeOrder_CODE
       FROM OBLE_Y1 a,
            SORD_Y1 b
      WHERE a.Case_IDNO = @Ln_TanfCur_Case_IDNO
        AND a.OrderSeq_NUMB = @Ln_TanfCur_OrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @Ln_TanfCur_ObligationSeq_NUMB
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.Case_IDNO = b.Case_IDNO
        AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
        AND b.EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Lc_Oble_TEXT = @Lc_Space_TEXT;
       SET @Ln_Order_IDNO = 0;
      END;
	 
	 BEGIN
     ------------< START - Assign ESEM for HOLD and Distribution >--------------
     -- storing values for ESEM insertion
     SET @Ls_Sql_TEXT = 'DELETE #EsemHold_P1';     
     SET @Ls_Sqldata_TEXT = '';

     DELETE FROM #EsemHold_P1;
	 
	 SET @Ls_Sql_TEXT = 'DELETE #EsemDist_P1';     
	 SET @Ls_Sqldata_TEXT = '';

     DELETE FROM #EsemDist_P1;

     SET @Ln_HoldCount_QNTY = 1; -- for hold
     SET @Ln_DistCount_QNTY = 1; -- for Dist
     SET @Lc_Receipt_ID = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ld_TanfCur_Batch_DATE, @Lc_TanfCur_SourceBatch_CODE, @Ln_TanfCur_Batch_NUMB, @Ln_TanfCur_SeqReceipt_NUMB);

     --------------------< START - WELFARE HOLD >--------------------------------
     --Assigning the Entity_ID RCTH_Y1 into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT #EsemHold_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityRctno_TEXT,'')+ ', Entity_ID = ' + ISNULL(@Lc_Receipt_ID,'');

     INSERT INTO #EsemHold_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityRctno_TEXT,   --TypeEntity_CODE
                  @Lc_Receipt_ID  --Entity_ID
			);

     SET @Ln_HoldCount_QNTY = @Ln_HoldCount_QNTY + 1;

     --Assigning the Entity_ID Date Hold into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT DATE #EsemHold_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityDthld_TEXT,'')+ ', Entity_ID = ' + ISNULL(@Lc_DateProcessMmddyyyy_TEXT,'');

     INSERT INTO #EsemHold_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityDthld_TEXT,   --TypeEntity_CODE
                  @Lc_DateProcessMmddyyyy_TEXT  --Entity_ID
		);

     SET @Ln_HoldCount_QNTY = @Ln_HoldCount_QNTY + 1;

     --Assigning the Entity_ID CASE into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT CASE #EsemHold_P1';    
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityCase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'');

     INSERT INTO #EsemHold_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityCase_TEXT,   --TypeEntity_CODE
                  @Ln_Case_IDNO  --Entity_ID
		);

     SET @Ln_HoldCount_QNTY = @Ln_HoldCount_QNTY + 1;

     --Assigning the Entity_ID ORDER into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT ORDER #EsemHold_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityOrder_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_Order_IDNO AS VARCHAR ),'');

     INSERT INTO #EsemHold_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityOrder_TEXT,   --TypeEntity_CODE
                  @Ln_Order_IDNO  --Entity_ID
		);

     SET @Ln_HoldCount_QNTY = @Ln_HoldCount_QNTY + 1;

     --Assigning the Entity_ID OBLE_Y1 into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT OBLE #EsemHold_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityOble_TEXT,'')+ ', Entity_ID = ' + ISNULL(@Lc_Oble_TEXT,'');

     INSERT INTO #EsemHold_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityOble_TEXT,   --TypeEntity_CODE
                  @Lc_Oble_TEXT  --Entity_ID
		);

     SET @Ln_HoldCount_QNTY = @Ln_HoldCount_QNTY + 1;

     ----------------------< END - WELFARE HOLD >--------------------------------
     ----------------------< START - WELFARE DISTRIBUTION >------------------------
     --Assigning the Entity_ID Receipt into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT Receipt #EsemDist_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityRctno_TEXT,'')+ ', Entity_ID = ' + ISNULL(@Lc_Receipt_ID,'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityRctno_TEXT,   --TypeEntity_CODE
                  @Lc_Receipt_ID  --Entity_ID
		);

     SET @Ln_DistCount_QNTY = @Ln_DistCount_QNTY + 1;

     --Assigning the Entity_ID Distribute Date into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT Distribute Date #EsemDist_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityDstdt_TEXT,'')+ ', Entity_ID = ' + ISNULL(@Lc_DateProcessMmddyyyy_TEXT,'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityDstdt_TEXT,   --TypeEntity_CODE
                  @Lc_DateProcessMmddyyyy_TEXT  --Entity_ID
		);

     SET @Ln_DistCount_QNTY = @Ln_DistCount_QNTY + 1;

     --Assigning the Entity_ID CASE into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT Case #EsemDist_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityCase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityCase_TEXT,   --TypeEntity_CODE
                  @Ln_Case_IDNO  --Entity_ID
		);

     SET @Ln_DistCount_QNTY = @Ln_DistCount_QNTY + 1;

     --Assigning the Entity_ID ORDER into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT Order #EsemDist_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityOrder_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_Order_IDNO AS VARCHAR ),'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityOrder_TEXT,   --TypeEntity_CODE
                  @Ln_Order_IDNO  --Entity_ID
		);

     SET @Ln_DistCount_QNTY = @Ln_DistCount_QNTY + 1;

     --Assigning the Entity_ID Obligation into the PLSQL variable
     SET @Ls_Sql_TEXT = 'INSERT Obligation #EsemDist_P1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityOble_TEXT,'')+ ', Entity_ID = ' + ISNULL(@Lc_Oble_TEXT,'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityOble_TEXT,   --TypeEntity_CODE
                  @Lc_Oble_TEXT  --Entity_ID
		);

     SET @Ln_DistCount_QNTY = @Ln_DistCount_QNTY + 1;
     --------------------< END - WELFARE DISTRIBUTION >------------------------
     ------------< END - Assign ESEM for HOLD and Distribution >--------------
     END;
     
     SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Ln_MemberMci_IDNO = MemberMci_IDNO,
                  @Lc_Fips_CODE = Fips_CODE
       FROM OBLE_Y1  a
      WHERE Case_IDNO = @Ln_Case_IDNO
        AND OrderSeq_NUMB = @Ln_OrderSeq_NUMB
        AND ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     IF SUBSTRING (@Lc_Fips_CODE, 1, 2) != @Lc_DeStateFips_CODE
      BEGIN
       SET @Ln_Arrear_AMNT = @Ln_Paa_AMNT + @Ln_TransactionCurSup_AMNT;
       SET @Ln_Paa_AMNT = @Ln_Paa_AMNT + @Ln_TransactionCurSup_AMNT;
       SET @Lc_Wemo_INDC = @Lc_No_INDC;

       GOTO Process_Excess;
      END;

     SET @Lc_WelfareCaseFlag_INDC = @Lc_No_INDC;
     SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'');

     SELECT TOP 1 @Ln_CaseWelfare_IDNO = a.CaseWelfare_IDNO,
                  @Ld_Begin_DATE = a.Start_DATE,
                  @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE
       FROM MHIS_Y1 a
      WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND a.Case_IDNO = @Ln_Case_IDNO
        AND a.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
        AND @Ld_Receipt_DATE BETWEEN a.Start_DATE AND dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (a.End_DATE);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'');

       SELECT TOP 1 @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE
         FROM MHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.Case_IDNO = @Ln_Case_IDNO
          AND @Ld_Receipt_DATE BETWEEN a.Start_DATE AND a.End_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Lc_TypeWelfare_CODE = @Lc_No_INDC;
        END;

       SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1 3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'');

       SELECT TOP 1 @Ln_CaseWelfare_IDNO = a.CaseWelfare_IDNO,
                    @Ld_Begin_DATE = a.Start_DATE
         FROM MHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.Case_IDNO = @Ln_Case_IDNO
          AND a.Start_DATE = (SELECT MAX (b.Start_DATE)
                              FROM MHIS_Y1 b
                             WHERE b.Case_IDNO = @Ln_Case_IDNO
                               AND b.MemberMci_IDNO = @Ln_MemberMci_IDNO
                               AND b.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                               AND b.Start_DATE < @Ld_Receipt_DATE);

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

	   -- Welfare Hold (reason - No Welfare Case)
       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         IF @Lc_TanfCur_TypeHold_CODE != @Lc_RegularHoldD_CODE
          BEGIN
           GOTO NEXT_REC;
          END;
          
		 -- NO IV-A MHIS RECORD FOR DEPENDENT
         SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_1';       	 
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL(CAST( @Ln_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_Paa_AMNT AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TanfHoldT_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisbursementHold_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeld_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusSdnm_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');

         EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
          @An_Case_IDNO                  = @Ln_Case_IDNO,
          @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
          @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
          @Ad_Batch_DATE                 = @Ld_Batch_DATE,
          @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
          @An_Batch_NUMB                 = @Ln_Batch_NUMB,
          @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
          @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
          @An_TransactionCs_AMNT         = @Ln_TransactionCurSup_AMNT,
          @An_TransactionPaa_AMNT        = @Ln_Paa_AMNT,
          @Ac_TypeHold_CODE              = @Lc_TanfHoldT_CODE,
          @Ac_TypeDisburse_CODE          = @Lc_TypeDisbursementHold_CODE,
          @Ac_TypeDisbursementDhld_CODE  = @Lc_TanfCur_TypeDisburse_CODE,
          @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
          @Ac_Status_CODE                = @Lc_DisbursementStatusHeld_CODE,
          @Ac_Reason_CODE                = @Lc_ReasonStatusSdnm_CODE,
          @An_EventGlobalSupportSeq_NUMB = @Ln_TanfCur_EventGlobalSupportSeq_NUMB,
          @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
          @Ac_CheckRecipient_ID          = @Lc_TanfCur_CheckRecipient_ID,
          @Ac_CheckRecipient_CODE        = @Lc_TanfCur_CheckRecipient_CODE,
          @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
          @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Lc_WelfareCaseFlag_INDC = @Lc_No_INDC;

         GOTO Update_Dhld;
        END;
       ELSE
        BEGIN
         SET @Ln_CaseWelfarePrim_IDNO = @Ln_CaseWelfare_IDNO;
         SET @Lc_WelfareCaseFlag_INDC = @Lc_Yes_INDC;
         SET @Ln_Arrear_AMNT = @Ln_Paa_AMNT;
        END;
      END;
     ELSE
      BEGIN
       SET @Ln_CaseWelfarePrim_IDNO = @Ln_CaseWelfare_IDNO;
       SET @Lc_WelfareCaseFlag_INDC = @Lc_Yes_INDC;
       SET @Ln_Arrear_AMNT = @Ln_Paa_AMNT;
      END;

     SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1_WEMO_Y1';     
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Ln_Value_NUMB = 1
       FROM IVMG_Y1 a,
            WEMO_Y1 b
      WHERE b.Case_IDNO = @Ln_Case_IDNO
        AND b.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
        AND b.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
        AND b.EndValidity_DATE = @Ld_High_DATE
        AND b.CaseWelfare_IDNO = a.CaseWelfare_IDNO;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       --For voluntary payments look for IVMG grant,
       --If ivmg grant exists, then create WEMO entries for the month,
       --If no ivmg exists, then place the records on SDNG hold
       SET @Lc_Grant_INDC = @Lc_No_INDC;

       IF @Lc_SourceReceipt_CODE = @Lc_ReceiptSrcVoluntary_CODE
          AND @Lc_TypeOrder_CODE = @Lc_OrderTypeVoluntary_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_LN_NUM_2';         
         SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT TOP 1 @Ln_Value_NUMB = 1
           FROM IVMG_Y1 b
          WHERE b.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
            AND b.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB
            AND b.CpMci_IDNO = @Ln_CpMci_IDNO
            AND b.MtdAssistExpend_AMNT > 0
            AND b.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
                                           FROM IVMG_Y1 c
                                          WHERE c.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                                                AND c.CpMci_IDNO = @Ln_CpMci_IDNO
                                                AND c.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB
                                                AND c.WelfareElig_CODE = b.WelfareElig_CODE)
            --Make sure that there are no current WEMO record exists for that IVA case
            AND NOT EXISTS (SELECT 1
                              FROM WEMO_Y1 d
                             WHERE d.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
							  -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - Start -- 
							  AND d.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
													WHERE b.MemberMci_IDNO = @Ln_CpMci_IDNO
													AND b.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
													AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
							 -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - End -- 	                               
                               AND d.EndValidity_DATE = @Ld_High_DATE);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Lc_Grant_INDC = @Lc_No_INDC;
          END
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_WEMO_VOLUNTARY';           
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'')+ ', ReceiptWelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', ProcessWelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ProcessWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

           EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_WEMO_VOLUNTARY
            @An_Case_IDNO             = @Ln_Case_IDNO,
            @An_OrderSeq_NUMB         = @Ln_OrderSeq_NUMB,
            @An_ObligationSeq_NUMB    = @Ln_ObligationSeq_NUMB,
            @An_CaseWelfare_IDNO      = @Ln_CaseWelfare_IDNO,
            @An_CpMci_IDNO            = @Ln_CpMci_IDNO,
            @An_ReceiptWelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB,
            @An_ProcessWelfareYearMonth_NUMB = @Ln_ProcessWelfareYearMonth_NUMB,
            @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
            @Ad_Process_DATE          = @Ld_Process_DATE OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR (50001,16,1);
            END;

           SET @Lc_Grant_INDC = @Lc_Yes_INDC;
          END;
        END;

       IF @Lc_Grant_INDC = @Lc_No_INDC
        BEGIN
         IF @Lc_TanfCur_TypeHold_CODE != @Lc_RegularHoldD_CODE
          BEGIN
           GOTO NEXT_REC;
          END;

         SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_1';		 -- NO IV-A GRANT 
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL(CAST( @Ln_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_Paa_AMNT AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TanfHoldT_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisbursementHold_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeld_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusSdng_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');

         EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
          @An_Case_IDNO                  = @Ln_Case_IDNO,
          @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
          @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
          @Ad_Batch_DATE                 = @Ld_Batch_DATE,
          @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
          @An_Batch_NUMB                 = @Ln_Batch_NUMB,
          @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
          @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
          @An_TransactionCs_AMNT         = @Ln_TransactionCurSup_AMNT,
          @An_TransactionPaa_AMNT        = @Ln_Paa_AMNT,
          @Ac_TypeHold_CODE              = @Lc_TanfHoldT_CODE,
          @Ac_TypeDisburse_CODE          = @Lc_TypeDisbursementHold_CODE,
          @Ac_TypeDisbursementDhld_CODE  = @Lc_TanfCur_TypeDisburse_CODE,
          @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
          @Ac_Status_CODE                = @Lc_DisbursementStatusHeld_CODE,
          @Ac_Reason_CODE                = @Lc_ReasonStatusSdng_CODE,
          @An_EventGlobalSupportSeq_NUMB = @Ln_TanfCur_EventGlobalSupportSeq_NUMB,
          @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
          @Ac_CheckRecipient_ID          = @Lc_TanfCur_CheckRecipient_ID,
          @Ac_CheckRecipient_CODE        = @Lc_TanfCur_CheckRecipient_CODE,
          @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
          @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Lc_WelfareCaseFlag_INDC = @Lc_No_INDC;

         GOTO Update_Dhld;
        END;
      END;

     IF @Lc_WelfareCaseFlag_INDC = @Lc_Yes_INDC
      BEGIN
       --Start current grant processing
       IF @Ln_TransactionCurSup_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_CG_PROCESS';        
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TanfCur_TypeHold_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');
         EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_CG_PROCESS
          @An_Case_IDNO                  = @Ln_Case_IDNO,
          @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
          @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
          @An_CpMci_IDNO                 = @Ln_CpMci_IDNO,
          @Ad_Batch_DATE                 = @Ld_Batch_DATE,
          @An_Batch_NUMB                 = @Ln_Batch_NUMB,
          @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
          @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
          @An_CaseWelfare_IDNO           = @Ln_CaseWelfare_IDNO,
          @Ac_TypeWelfare_CODE           = @Lc_TypeWelfare_CODE,
          @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
          @An_EventGlobalSupportSeq_NUMB = @Ln_TanfCur_EventGlobalSupportSeq_NUMB,
          @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
          @Ac_TypeDisbursementDhld_CODE  = @Lc_TanfCur_TypeDisburse_CODE,
          @Ac_CheckRecipient_ID          = @Lc_TanfCur_CheckRecipient_ID,
          @Ac_CheckRecipient_CODE        = @Lc_TanfCur_CheckRecipient_CODE,
          @Ac_TypeHold_CODE              = @Lc_TanfCur_TypeHold_CODE,
          @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
          @An_TransactionCurSup_AMNT     = @Ln_TransactionCurSup_AMNT OUTPUT,
          @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END;

         --Process remaining CG money to prior grant of other TANF cases
         SET @Ln_Arrear_AMNT = @Ln_Arrear_AMNT + @Ln_TransactionCurSup_AMNT;
         SET @Ln_Paa_AMNT = @Ln_Paa_AMNT + @Ln_TransactionCurSup_AMNT;
         SET @Ln_TransactionCurSup_AMNT = 0;

         IF @Ln_Arrear_AMNT = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT #EsemDist_P1 - 1';           
           SET @Ls_Sqldata_TEXT = '';

           SELECT @Ln_EsemDistCount_QNTY = COUNT (e.Row_NUMB)
             FROM #EsemDist_P1 e;

           IF @Ln_EsemDistCount_QNTY > 5
            BEGIN

		   DECLARE EsemDist_CUR INSENSITIVE CURSOR FOR
		   SELECT e.TypeEntity_CODE,
					  e.Entity_ID,
					  e.Row_NUMB
				 FROM #EsemDist_P1 e;

             SET @Ls_Sql_TEXT = 'OPEN EsemDist_CUR - 1';             
             SET @Ls_Sqldata_TEXT = '';
             
             OPEN EsemDist_CUR;

             SET @Ls_Sql_TEXT = 'FETCH EsemDist_CUR - 1';            
             SET @Ls_Sqldata_TEXT = '';
             
             FETCH NEXT FROM EsemDist_CUR INTO @Lc_EsemDistCur_TypeEntity_CODE, @Lc_EsemDistCur_Entity_ID, @Ln_EsemDistCur_Row_NUMB;

             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
             SET @Ls_Sql_TEXT = 'WHILE LOOP -2';         
             SET @Ls_Sqldata_TEXT = '';    
             --LOOP BEGIN
             WHILE @Li_FetchStatus_QNTY = 0
              BEGIN
               SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_DIST';               
               SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EsemDistCur_TypeEntity_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDistribution1830_NUMB AS VARCHAR ),'')+ ', Entity_ID = ' + ISNULL(@Lc_EsemDistCur_Entity_ID,'');

               INSERT INTO ESEM_Y1
                           (TypeEntity_CODE,
                            EventGlobalSeq_NUMB,
                            EventFunctionalSeq_NUMB,
                            Entity_ID)
                    VALUES ( @Lc_EsemDistCur_TypeEntity_CODE,    --TypeEntity_CODE
                             @Ln_EventGlobalSeq_NUMB,    --EventGlobalSeq_NUMB
                             @Li_TanfDistribution1830_NUMB,    --EventFunctionalSeq_NUMB
                             @Lc_EsemDistCur_Entity_ID  --Entity_ID
					); 

               SET @Ls_Sql_TEXT = 'FETCH EsemDist_CUR - 2';               
               SET @Ls_Sqldata_TEXT = '';
               
               FETCH EsemDist_CUR INTO @Lc_EsemDistCur_TypeEntity_CODE, @Lc_EsemDistCur_Entity_ID, @Ln_EsemDistCur_Row_NUMB;

               SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
              END;

             CLOSE EsemDist_CUR;

             DEALLOCATE EsemDist_CUR;

             SET @Lc_InsertEsem_INDC = @Lc_Yes_INDC;

             GOTO Update_Dhld;
            END;
           ELSE
            BEGIN
             IF @Lc_TanfCur_TypeHold_CODE = @Lc_RegularHoldD_CODE
              BEGIN
               GOTO Update_Dhld;
              END;
            END;

           GOTO NEXT_REC;
          END;
        END;

       --End current grant processing
       SET @Ls_Sql_TEXT = 'WHILE_LOOP -3';
       SET @Ls_Sqldata_TEXT = '';
       
       SET @Lc_Wemo_INDC = @Lc_No_INDC;

       --This section will be executed for remaining money from cg_process as well as the regular TANF arrears
       WHILE @Ln_Arrear_AMNT > 0
        BEGIN
         SET @Ln_ArrearAppTot_AMNT = 0;
         SET @Ln_ArrearAppIva_AMNT = 0;
         SET @Ln_MtdApp_QNTY = 0;
         SET @Ln_MtdAppIva_AMNT = 0;
         SET @Ln_AllWemoCur_WemoCase_IDNO = @Ln_Case_IDNO;
         SET @Ln_AllWemoCur_WemoOrderSeq_NUMB = @Ln_OrderSeq_NUMB;
         SET @Ln_AllWemoCur_WemoObligationSeq_NUMB = @Ln_ObligationSeq_NUMB;
         SET @Ls_Sql_TEXT = 'SELECT_WEMO_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT @Ln_AllWemoCur_Urg_AMNT = (a.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT),
                @Ln_AllWemoCur_WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB,
                @Ln_AllWemoCur_MtdAssistExpend_AMNT = a.MtdAssistExpend_AMNT,
                @Ln_AllWemoCur_ExpandTotAsst_AMNT = a.LtdAssistExpend_AMNT,
                @Ln_AllWemoCur_MtdAssistRecoup_AMNT = a.MtdAssistRecoup_AMNT,
                @Ln_AllWemoCur_RecupTotAsst_AMNT = a.LtdAssistRecoup_AMNT
           FROM WEMO_Y1 a
          WHERE a.Case_IDNO = @Ln_AllWemoCur_WemoCase_IDNO
            AND a.OrderSeq_NUMB = @Ln_AllWemoCur_WemoOrderSeq_NUMB
            AND a.ObligationSeq_NUMB = @Ln_AllWemoCur_WemoObligationSeq_NUMB
            AND a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
            AND a.EndValidity_DATE = @Ld_High_DATE
            AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB) 
                                             FROM WEMO_Y1 b
                                            WHERE b.Case_IDNO = a.Case_IDNO
                                              AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                              AND b.EndValidity_DATE = @Ld_High_DATE);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ln_AllWemoCur_Urg_AMNT = 0;
           SET @Ln_AllWemoCur_ExpandTotAsst_AMNT = 0;
           SET @Ln_ExpandAsst_AMNT = 0;
           SET @Ln_AllWemoCur_RecupTotAsst_AMNT = 0;
           SET @Lc_Wemo_INDC = @Lc_Yes_INDC;
           SET @Lc_WemoProcess_INDC = @Lc_No_INDC;
          END;

         SET @Lc_AllwemoProcessed_INDC = @Lc_No_INDC;
         SET @Lc_AllwemoCurOpen_INDC = @Lc_No_INDC;
         SET @Ln_MtdUrg_AMNT = @Ln_AllWemoCur_MtdAssistExpend_AMNT - @Ln_AllWemoCur_MtdAssistRecoup_AMNT;

         IF @Ln_MtdUrg_AMNT < 0
          BEGIN
           SET @Ln_MtdUrg_AMNT = 0;
          END;

         IF @Ln_AllWemoCur_Urg_AMNT < 0
          BEGIN
           SET @Ln_AllWemoCur_Urg_AMNT = 0;
          END;

         SET @Ls_Sql_TEXT = 'WHILE LOOP-4';         
         SET @Ls_Sqldata_TEXT = '';
         
         --LOOP BEGIN
         WHILE @Lc_AllwemoProcessed_INDC = @Lc_No_INDC
               AND @Ln_Arrear_AMNT > 0
          BEGIN
           SET @Ln_ArrearAppTot_AMNT = 0;
           SET @Ln_MtdApp_QNTY = 0;
           SET @Lc_WemoProcess_INDC = @Lc_No_INDC;
           SET @Ls_Sql_TEXT = 'WHILE LOOP-5';           
           SET @Ls_Sqldata_TEXT = '';
           
           --LOOP BEGIN
           WHILE @Ln_AllWemoCur_Urg_AMNT > 0
                 AND @Ln_Arrear_AMNT > 0
            BEGIN
             SET @Ln_ArrearApp_AMNT = 0;
             SET @Ln_MtdApp_AMNT = 0;
             SET @Lc_WemoProcess_INDC = @Lc_Yes_INDC;

             IF @Ln_Paa_AMNT > 0
              BEGIN
               IF @Ln_Paa_AMNT > @Ln_AllWemoCur_Urg_AMNT
                BEGIN
                 SET @Ln_Arrear_AMNT = @Ln_Arrear_AMNT - @Ln_AllWemoCur_Urg_AMNT;
                 SET @Ln_ArrearApp_AMNT = @Ln_AllWemoCur_Urg_AMNT;
                 SET @Ln_Paa_AMNT = @Ln_Paa_AMNT - @Ln_AllWemoCur_Urg_AMNT;
                 SET @Ln_MtdApp_AMNT = @Ln_MtdUrg_AMNT;
                 SET @Ln_AllWemoCur_Urg_AMNT = 0;
                 SET @Ln_MtdUrg_AMNT = 0;
                END;
               ELSE
                BEGIN
                 SET @Ln_Arrear_AMNT = @Ln_Arrear_AMNT - @Ln_Paa_AMNT;
                 SET @Ln_ArrearApp_AMNT = @Ln_Paa_AMNT;
                 SET @Ln_AllWemoCur_Urg_AMNT = @Ln_AllWemoCur_Urg_AMNT - @Ln_Paa_AMNT;

                 IF @Ln_Paa_AMNT >= @Ln_MtdUrg_AMNT
                  BEGIN
                   SET @Ln_MtdApp_AMNT = @Ln_MtdUrg_AMNT;
                   SET @Ln_MtdUrg_AMNT = 0;
                  END;
                 ELSE
                  BEGIN
                   SET @Ln_MtdApp_AMNT = @Ln_Paa_AMNT;
                   SET @Ln_MtdUrg_AMNT = @Ln_MtdUrg_AMNT - @Ln_Paa_AMNT;
                  END;

                 SET @Ln_Paa_AMNT = 0;
                END;
			   -- If Applied from CHPAA to Prior grant, mark it as PGPAA, else mark it as AGPAA
               SET @Ls_Sql_TEXT = 'INSERT_LWEL_Y1';               
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Distribute_AMNT = ' + ISNULL(CAST( @Ln_ArrearApp_AMNT AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'');

               INSERT LWEL_Y1
                      (Case_IDNO,
                       OrderSeq_NUMB,
                       ObligationSeq_NUMB,
                       WelfareYearMonth_NUMB,
                       Batch_DATE,
                       Batch_NUMB,
                       SeqReceipt_NUMB,
                       SourceBatch_CODE,
                       CaseWelfare_IDNO,
                       TypeWelfare_CODE,
                       Distribute_DATE,
                       Distribute_AMNT,
                       TypeDisburse_CODE,
                       EventGlobalSeq_NUMB,
                       EventGlobalSupportSeq_NUMB)
               VALUES ( @Ln_AllWemoCur_WemoCase_IDNO,   --Case_IDNO
                        @Ln_AllWemoCur_WemoOrderSeq_NUMB,   --OrderSeq_NUMB
                        @Ln_AllWemoCur_WemoObligationSeq_NUMB,   --ObligationSeq_NUMB
                        @Ln_AllWemoCur_WelfareYearMonth_NUMB,   --WelfareYearMonth_NUMB
                        @Ld_Batch_DATE,   --Batch_DATE
                        @Ln_Batch_NUMB,   --Batch_NUMB
                        @Ln_SeqReceipt_NUMB,   --SeqReceipt_NUMB
                        @Lc_SourceBatch_CODE,   --SourceBatch_CODE
                        @Ln_CaseWelfare_IDNO,   --CaseWelfare_IDNO
                        @Lc_TypeWelfare_CODE,   --TypeWelfare_CODE
                        @Ld_Process_DATE,   --Distribute_DATE
                        @Ln_ArrearApp_AMNT,   --Distribute_AMNT
                        CASE
                         WHEN @Lc_TanfCur_TypeDisburse_CODE = @Lc_TypeDisbursementChpaa_CODE
                          THEN @Lc_TypeDisbursementPgpaa_CODE
                         ELSE @Lc_TypeDisbursementAgpaa_CODE
                        END,   --TypeDisburse_CODE
                        @Ln_EventGlobalSeq_NUMB,   --EventGlobalSeq_NUMB
                        @Ln_TanfCur_EventGlobalSupportSeq_NUMB  --EventGlobalSupportSeq_NUMB
				);

               SET @Li_Rowcount_QNTY = @@ROWCOUNT;

               IF @Li_Rowcount_QNTY = 0
                BEGIN
                 SET @Ls_ErrorMessage_TEXT = 'INSERT_LWEL_Y1 FAILED';
                 RAISERROR (50001,16,1);
                END;

               SET @Ln_GrantPaidPaa_AMNT = @Ln_GrantPaidPaa_AMNT + @Ln_ArrearApp_AMNT;
              END;

             SET @Ln_ArrearAppTot_AMNT = @Ln_ArrearAppTot_AMNT + @Ln_ArrearApp_AMNT;
             SET @Ln_ArrearAppIva_AMNT = @Ln_ArrearAppIva_AMNT + @Ln_ArrearApp_AMNT;
             SET @Ln_MtdApp_QNTY = @Ln_MtdApp_QNTY + @Ln_MtdApp_AMNT;
             SET @Ln_MtdAppIva_AMNT = @Ln_MtdAppIva_AMNT + @Ln_MtdApp_AMNT;
            END;

           IF @Lc_WemoProcess_INDC = @Lc_Yes_INDC
              AND @Ln_ArrearAppTot_AMNT > 0
            BEGIN
             SET @Ls_Sql_TEXT = 'UPDATE_WEMO_Y11';
             SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

             UPDATE WEMO_Y1
                SET MtdAssistRecoup_AMNT = MtdAssistRecoup_AMNT + @Ln_MtdApp_QNTY,
                    TransactionAssistRecoup_AMNT = TransactionAssistRecoup_AMNT + @Ln_ArrearAppTot_AMNT,
                    LtdAssistRecoup_AMNT = LtdAssistRecoup_AMNT + @Ln_ArrearAppTot_AMNT
              WHERE Case_IDNO = @Ln_AllWemoCur_WemoCase_IDNO
                AND OrderSeq_NUMB = @Ln_AllWemoCur_WemoOrderSeq_NUMB
                AND ObligationSeq_NUMB = @Ln_AllWemoCur_WemoObligationSeq_NUMB
                AND CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                AND WelfareYearMonth_NUMB = @Ln_AllWemoCur_WelfareYearMonth_NUMB
                AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB
                AND EndValidity_DATE = @Ld_High_DATE;

             SET @Li_Rowcount_QNTY = @@ROWCOUNT;

             IF @Li_Rowcount_QNTY = 0
              BEGIN
               SET @Ls_Sql_TEXT = 'UPDATE_WEMO_Y12';
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

               UPDATE WEMO_Y1
                  SET EndValidity_DATE = @Ld_Process_DATE,
                      EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
                WHERE Case_IDNO = @Ln_AllWemoCur_WemoCase_IDNO
                  AND OrderSeq_NUMB = @Ln_AllWemoCur_WemoOrderSeq_NUMB
                  AND ObligationSeq_NUMB = @Ln_AllWemoCur_WemoObligationSeq_NUMB
                  AND CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                  AND WelfareYearMonth_NUMB = @Ln_AllWemoCur_WelfareYearMonth_NUMB
                  AND EndValidity_DATE = @Ld_High_DATE;

               SET @Li_Rowcount_QNTY = @@ROWCOUNT;

               IF @Li_Rowcount_QNTY = 0
                BEGIN
                 SET @Ls_ErrorMessage_TEXT = 'UPDATE_WEMO_Y12 FAILED';

                 RAISERROR (50001,16,1);
                END;

               SET @Ls_Sql_TEXT = 'INSERT_WEMO_Y1';
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', MtdAssistExpend_AMNT = ' + ISNULL(CAST( @Ln_AllWemoCur_MtdAssistExpend_AMNT AS VARCHAR ),'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','')+ ', LtdAssistExpend_AMNT = ' + ISNULL(CAST( @Ln_AllWemoCur_ExpandTotAsst_AMNT AS VARCHAR ),'')+ ', TransactionAssistRecoup_AMNT = ' + ISNULL(CAST( @Ln_ArrearAppTot_AMNT AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');

               INSERT WEMO_Y1
                      (Case_IDNO,
                       OrderSeq_NUMB,
                       ObligationSeq_NUMB,
                       CaseWelfare_IDNO,
                       WelfareYearMonth_NUMB,
                       MtdAssistExpend_AMNT,
                       TransactionAssistExpend_AMNT,
                       LtdAssistExpend_AMNT,
                       TransactionAssistRecoup_AMNT,
                       MtdAssistRecoup_AMNT,
                       LtdAssistRecoup_AMNT,
                       BeginValidity_DATE,
                       EndValidity_DATE,
                       EventGlobalBeginSeq_NUMB,
                       EventGlobalEndSeq_NUMB)
               VALUES ( @Ln_AllWemoCur_WemoCase_IDNO,   --Case_IDNO
                        @Ln_AllWemoCur_WemoOrderSeq_NUMB,   --OrderSeq_NUMB
                        @Ln_AllWemoCur_WemoObligationSeq_NUMB,   --ObligationSeq_NUMB
                        @Ln_CaseWelfare_IDNO,   --CaseWelfare_IDNO
                        @Ln_AllWemoCur_WelfareYearMonth_NUMB,   --WelfareYearMonth_NUMB
                        @Ln_AllWemoCur_MtdAssistExpend_AMNT,   --MtdAssistExpend_AMNT
                        0,   --TransactionAssistExpend_AMNT
                        @Ln_AllWemoCur_ExpandTotAsst_AMNT,   --LtdAssistExpend_AMNT
                        @Ln_ArrearAppTot_AMNT,   --TransactionAssistRecoup_AMNT
                        @Ln_AllWemoCur_MtdAssistRecoup_AMNT + @Ln_MtdApp_QNTY,   --MtdAssistRecoup_AMNT
                        @Ln_AllWemoCur_RecupTotAsst_AMNT + @Ln_ArrearAppTot_AMNT,   --LtdAssistRecoup_AMNT
                        @Ld_Process_DATE,   --BeginValidity_DATE
                        @Ld_High_DATE,   --EndValidity_DATE
                        @Ln_EventGlobalSeq_NUMB,   --EventGlobalBeginSeq_NUMB
                        0  --EventGlobalEndSeq_NUMB
					);

               SET @Li_Rowcount_QNTY = @@ROWCOUNT;

               IF @Li_Rowcount_QNTY = 0
                BEGIN
                 SET @Ls_ErrorMessage_TEXT = 'INSERT_WEMO_Y1 FAILED';

                 RAISERROR (50001,16,1);
                END;

               IF @Ln_AllWemoCur_WemoCase_IDNO != @Ln_Case_IDNO
                   OR @Ln_AllWemoCur_WemoOrderSeq_NUMB != @Ln_OrderSeq_NUMB
                   OR @Ln_AllWemoCur_WemoObligationSeq_NUMB != @Ln_ObligationSeq_NUMB
                BEGIN
                 SET @Ls_Sql_TEXT = 'SELECT @Ln_Value_NUMB - 1';
                 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

                 SELECT @Ln_Value_NUMB = 1
                   FROM WELR_Y1 w
                  WHERE w.Case_IDNO = @Ln_AllWemoCur_WemoCase_IDNO
                    AND w.OrderSeq_NUMB = @Ln_AllWemoCur_WemoOrderSeq_NUMB
                    AND w.ObligationSeq_NUMB = @Ln_AllWemoCur_WemoObligationSeq_NUMB
                    AND w.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                    AND w.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

                 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

                 IF @Li_Rowcount_QNTY = 0
                  BEGIN
                   SET @Ls_Sql_TEXT = 'INSERT_WELR_Y1';                   
                   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CaseOrig_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderOrigSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObleOrigSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'');

                   INSERT WELR_Y1
                          (Case_IDNO,
                           OrderSeq_NUMB,
                           ObligationSeq_NUMB,
                           CaseWelfare_IDNO,
                           Distribute_DATE,
                           EventGlobalSeq_NUMB,
                           CaseOrig_IDNO,
                           OrderOrigSeq_NUMB,
                           ObleOrigSeq_NUMB,
                           Batch_DATE,
                           SourceBatch_CODE,
                           Batch_NUMB,
                           SeqReceipt_NUMB,
                           EventGlobalSupportSeq_NUMB)
                   VALUES ( @Ln_AllWemoCur_WemoCase_IDNO,   --Case_IDNO
                            @Ln_AllWemoCur_WemoOrderSeq_NUMB,   --OrderSeq_NUMB
                            @Ln_AllWemoCur_WemoObligationSeq_NUMB,   --ObligationSeq_NUMB
                            @Ln_CaseWelfare_IDNO,   --CaseWelfare_IDNO
                            @Ld_Process_DATE,   --Distribute_DATE
                            @Ln_EventGlobalSeq_NUMB,   --EventGlobalSeq_NUMB
                            @Ln_Case_IDNO,   --CaseOrig_IDNO
                            @Ln_OrderSeq_NUMB,   --OrderOrigSeq_NUMB
                            @Ln_ObligationSeq_NUMB,   --ObleOrigSeq_NUMB
                            @Ld_Batch_DATE,   --Batch_DATE
                            @Lc_SourceBatch_CODE,   --SourceBatch_CODE
                            @Ln_Batch_NUMB,   --Batch_NUMB
                            @Ln_SeqReceipt_NUMB,   --SeqReceipt_NUMB
                            @Ln_TanfCur_EventGlobalSupportSeq_NUMB  --EventGlobalSupportSeq_NUMB
							);

                   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

                   IF @Li_Rowcount_QNTY = 0
                    BEGIN
                     SET @Ls_ErrorMessage_TEXT = 'INSERT_WELR_Y1 FAILED';

                     RAISERROR (50001,16,1);
                    END;
                  END

                END;
              END;
            END;

		-- Defect 13319 - PA arrears in excess of URA not always moving to UDA - Fix -- Start --
         SET @Lc_AssignFlag_INDC = @Lc_No_INDC;
		 SET @Ls_Sql_TEXT = 'SELECT_#AssignArr_P1 - 1';                 
		 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'');

         SELECT @Lc_AssignFlag_INDC = @Lc_Yes_INDC
           FROM #AssignArr_P1 t
          WHERE t.Case_IDNO = @Ln_AllWemoCur_WemoCase_IDNO
            AND t.OrderSeq_NUMB = @Ln_AllWemoCur_WemoOrderSeq_NUMB
            AND t.ObligationSeq_NUMB = @Ln_AllWemoCur_WemoObligationSeq_NUMB;
            
		 SET @Ls_Sql_TEXT = 'SELECT_@Ln_RecordCount_QNTY_#AssignArr_P1 - 1';                 
		 SET @Ls_Sqldata_TEXT = '';

         SELECT @Ln_RecordCount_QNTY = COUNT (t.Row_NUMB)
           FROM #AssignArr_P1 t;

         IF @Lc_AssignFlag_INDC = @Lc_No_INDC
          BEGIN
           SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
		  SET @Ls_Sql_TEXT = 'INSERT_#AssignArr_P1 - 1';                  
		  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'');

          INSERT INTO #AssignArr_P1
                       (Case_IDNO,
                        OrderSeq_NUMB,
                        ObligationSeq_NUMB,
                        WelfareYearMonth_NUMB)
                VALUES ( @Ln_AllWemoCur_WemoCase_IDNO,   --Case_IDNO
                         @Ln_AllWemoCur_WemoOrderSeq_NUMB,   --OrderSeq_NUMB
                         @Ln_AllWemoCur_WemoObligationSeq_NUMB,   --ObligationSeq_NUMB
                         @Ln_AllWemoCur_WelfareYearMonth_NUMB  --WelfareYearMonth_NUMB
						);
          END		
		-- Defect 13319 - PA arrears in excess of URA not always moving to UDA - Fix -- End --

           IF @Ln_Arrear_AMNT > 0
            BEGIN                                
             IF NOT CURSOR_STATUS ('LOCAL', 'AllWemo_CUR') IN (0, 1)
              BEGIN

			   DECLARE AllWemo_CUR INSENSITIVE CURSOR FOR
				   SELECT a.Case_IDNO,
							  a.OrderSeq_NUMB,
							  a.ObligationSeq_NUMB,
							  (a.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT),
							  a.WelfareYearMonth_NUMB,
							  a.MtdAssistExpend_AMNT,
							  a.MtdAssistRecoup_AMNT,
							  a.LtdAssistExpend_AMNT,
							  a.LtdAssistRecoup_AMNT
						 FROM WEMO_Y1 a
						WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
						  -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - Start -- 
						  AND a.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
												WHERE b.MemberMci_IDNO = @Ln_CpMci_IDNO
												AND b.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
												AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
						 -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - End -- 												
						  AND a.EndValidity_DATE = @Ld_High_DATE
						  AND (a.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT) > 0
						  AND a.WelfareYearMonth_NUMB = (SELECT MAX (b.WelfareYearMonth_NUMB) 
														   FROM WEMO_Y1 b
														  WHERE b.Case_IDNO = a.Case_IDNO
															AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
															AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
															AND b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
															AND b.EndValidity_DATE = @Ld_High_DATE);
            
               SET @Ls_Sql_TEXT = 'OPEN AllWemoCur -1';               
               SET @Ls_Sqldata_TEXT = '';
               
               OPEN AllWemo_CUR;

               SET @Lc_AllwemoCurOpen_INDC = @Lc_Yes_INDC;
              END;

             FETCH NEXT FROM AllWemo_CUR INTO @Ln_AllWemoCur_WemoCase_IDNO, @Ln_AllWemoCur_WemoOrderSeq_NUMB, @Ln_AllWemoCur_WemoObligationSeq_NUMB, @Ln_AllWemoCur_Urg_AMNT, @Ln_AllWemoCur_WelfareYearMonth_NUMB, @Ln_AllWemoCur_MtdAssistExpend_AMNT, @Ln_AllWemoCur_MtdAssistRecoup_AMNT, @Ln_AllWemoCur_ExpandTotAsst_AMNT, @Ln_AllWemoCur_RecupTotAsst_AMNT;

             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

             IF @Li_FetchStatus_QNTY <> 0
              BEGIN
               SET @Lc_AllwemoProcessed_INDC = @Lc_Yes_INDC;

               CLOSE AllWemo_CUR;

               DEALLOCATE AllWemo_CUR;

               SET @Lc_AllwemoCurOpen_INDC = @Lc_No_INDC;
              END

             SET @Ln_MtdUrg_AMNT = @Ln_AllWemoCur_MtdAssistExpend_AMNT - @Ln_AllWemoCur_MtdAssistRecoup_AMNT;
            END;
           ELSE
            BEGIN
            IF CURSOR_STATUS ('LOCAL', 'AllWemo_CUR') IN (0, 1)
              BEGIN
               CLOSE AllWemo_CUR;

               DEALLOCATE AllWemo_CUR;

               SET @Lc_AllwemoCurOpen_INDC = @Lc_No_INDC;
              END
            END;
          END;

         IF @Ln_ArrearAppIva_AMNT > 0
          BEGIN
           SET @Ls_Sql_TEXT = 'UPDATE_IVMG_Y1';
           SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'');

           UPDATE IVMG_Y1
              SET MtdAssistRecoup_AMNT = MtdAssistRecoup_AMNT + @Ln_MtdAppIva_AMNT,
                  TransactionAssistRecoup_AMNT = TransactionAssistRecoup_AMNT + @Ln_ArrearAppIva_AMNT,
                  LtdAssistRecoup_AMNT = ISNULL (LtdAssistRecoup_AMNT, 0) + @Ln_ArrearAppIva_AMNT
            WHERE CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
              AND WelfareYearMonth_NUMB = @Ln_AllWemoCur_WelfareYearMonth_NUMB
              AND WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
              AND CpMci_IDNO = @Ln_CpMci_IDNO
              AND EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT_IVMG_Y1';			 
             SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'') + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'') + ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', TypeAdjust_CODE = ' + ISNULL(@Lc_Space_TEXT,'') + ', AdjustLtdFlag_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Defra_AMNT = ' + ISNULL('0','');

             INSERT IVMG_Y1
                    (CaseWelfare_IDNO,
                     WelfareYearMonth_NUMB,
                     WelfareElig_CODE,
                     MtdAssistExpend_AMNT,
                     TransactionAssistExpend_AMNT,
                     LtdAssistExpend_AMNT,
                     TransactionAssistRecoup_AMNT,
                     MtdAssistRecoup_AMNT,
                     LtdAssistRecoup_AMNT,
                     EventGlobalSeq_NUMB,
                     ZeroGrant_INDC,
                     TypeAdjust_CODE,
                     AdjustLtdFlag_INDC,
                     Defra_AMNT,
                     CpMci_IDNO
             )
             (SELECT @Ln_CaseWelfare_IDNO AS CaseWelfare_IDNO,
                     @Ln_AllWemoCur_WelfareYearMonth_NUMB AS WelfareYearMonth_NUMB,
                     @Lc_WelfareTypeTanf_CODE AS WelfareElig_CODE,
                     ISNULL (a.MtdAssistExpend_AMNT, 0) AS MtdAssistExpend_AMNT,
                     0 AS TransactionAssistExpend_AMNT,
                     ISNULL (a.LtdAssistExpend_AMNT, 0) AS LtdAssistExpend_AMNT,
                     ISNULL (@Ln_ArrearAppIva_AMNT, 0) AS TransactionAssistRecoup_AMNT,
                     ISNULL (a.MtdAssistRecoup_AMNT, 0) + @Ln_MtdAppIva_AMNT AS MtdAssistRecoup_AMNT,
                     ISNULL (a.LtdAssistRecoup_AMNT, 0) + ISNULL (@Ln_ArrearAppIva_AMNT, 0) AS LtdAssistRecoup_AMNT,
                     @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                     a.ZeroGrant_INDC,
                     @Lc_Space_TEXT AS TypeAdjust_CODE,
                     @Lc_Space_TEXT AS AdjustLtdFlag_INDC,
                     0 AS Defra_AMNT,
                     a.CpMci_IDNO
                FROM IVMG_Y1 a
               WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO
                 AND a.WelfareYearMonth_NUMB = @Ln_AllWemoCur_WelfareYearMonth_NUMB
                 AND a.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
                 AND a.CpMci_IDNO = @Ln_CpMci_IDNO
                 AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB) 
                                                FROM IVMG_Y1 b
                                               WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                                     AND b.CpMci_IDNO = a.CpMci_IDNO
                                                     AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                                     AND b.WelfareElig_CODE = a.WelfareElig_CODE));
            END;
          END;

         ---------------< START - Storing unique Welfare CASE_ID >---------------
         -- for storing unique entity values for Welf case_id,
         -- Since there can be multiple Welf case_id's for single CASE_ID
         SET @Lc_DistWcaseFlag_INDC = @Lc_No_INDC;
		 SET @Ls_Sql_TEXT = 'SELECT_Ln_N_QNTY_#EsemDist_P1';         
		 SET @Ls_Sqldata_TEXT = '';

         SELECT @Ln_DistCount_QNTY = COUNT (t.Row_NUMB)
           FROM #EsemDist_P1 t;
		 
		 SET @Ls_Sql_TEXT = 'SELECT_@Lc_DistWcaseFlag_INDC_#EsemDist_P1';         
		 SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityWcase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'');

         SELECT @Lc_DistWcaseFlag_INDC = @Lc_Yes_INDC
           FROM #EsemDist_P1 t
          WHERE t.TypeEntity_CODE = @Lc_EntityWcase_TEXT
            AND t.Entity_ID = @Ln_CaseWelfare_IDNO;

         IF @Lc_DistWcaseFlag_INDC = @Lc_No_INDC
          BEGIN
           SET @Ln_DistCount_QNTY = @Ln_DistCount_QNTY + 1;
		   SET @Ls_Sql_TEXT = 'INSERT_#EsemDist_P1 - 2';           
		   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityWcase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'');

           INSERT INTO #EsemDist_P1
                       (TypeEntity_CODE,
                        Entity_ID)
                VALUES ( @Lc_EntityWcase_TEXT,    --TypeEntity_CODE
                         @Ln_CaseWelfare_IDNO  --Entity_ID
						); 
          END;

         -- Insert DHLD Entry per TANF Case id
         IF @Ln_GrantPaidPaa_AMNT > 0
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_GRNT_PAID';          
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL('0','')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_GrantPaidPaa_AMNT AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHoldD_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisbursementGrant_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusRelease_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');

           EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
            @An_Case_IDNO                  = @Ln_Case_IDNO,
            @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
            @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
            @Ad_Batch_DATE                 = @Ld_Batch_DATE,
            @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
            @An_Batch_NUMB                 = @Ln_Batch_NUMB,
            @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
            @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
            @An_TransactionCs_AMNT         = 0,
            @An_TransactionPaa_AMNT        = @Ln_GrantPaidPaa_AMNT,
            @Ac_TypeHold_CODE              = @Lc_RegularHoldD_CODE,
            @Ac_TypeDisburse_CODE          = @Lc_TypeDisbursementGrant_CODE,
            @Ac_TypeDisbursementDhld_CODE  = @Lc_TanfCur_TypeDisburse_CODE,
            @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
            @Ac_Status_CODE                = @Lc_DisbursementStatusRelease_CODE,
            @Ac_Reason_CODE                = @Lc_ReasonStatusDr_CODE,
            @An_EventGlobalSupportSeq_NUMB = @Ln_TanfCur_EventGlobalSupportSeq_NUMB,
            @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
            @Ac_CheckRecipient_ID          = @Lc_TanfCur_CheckRecipient_ID,
            @Ac_CheckRecipient_CODE        = @Lc_TanfCur_CheckRecipient_CODE,
            @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
            @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
            @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR (50001,16,1);
            END;

           SET @Ln_GrantPaidPaa_AMNT = 0;
           -------< START - ESEM Insertion for Welfare Distributed receipts >------
           -- This purpose of this loop is to insert the records in the ESEM Table
           DECLARE EsemDist_CUR INSENSITIVE CURSOR FOR
           SELECT p.TypeEntity_CODE,
                      p.Entity_ID,
                      p.Row_NUMB
                 FROM #EsemDist_P1 p;
           SET @Ls_Sql_TEXT = 'OPEN EsemDist_CUR - 2';           
           SET @Ls_Sqldata_TEXT = '';
           
           OPEN EsemDist_CUR;

           SET @Ls_Sql_TEXT = 'FETCH EsemDist_CUR - 3';           
           SET @Ls_Sqldata_TEXT = '';
           
           FETCH EsemDist_CUR INTO @Lc_EsemDistCur_TypeEntity_CODE, @Lc_EsemDistCur_Entity_ID, @Ln_EsemDistCur_Row_NUMB;

           SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           SET @Ls_Sql_TEXT = 'WHILE LOOP -6';           
           SET @Ls_Sqldata_TEXT = '';
           
           --LOOP BEGIN
           WHILE @Li_FetchStatus_QNTY = 0
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_DIST';
             SET @Ls_Sqldata_TEXT = '';  
             
             IF NOT EXISTS (SELECT 1
                              FROM ESEM_Y1 e
                             WHERE e.TypeEntity_CODE = @Lc_EsemDistCur_TypeEntity_CODE
                               AND e.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB
                               AND e.EventFunctionalSeq_NUMB = @Li_TanfDistribution1830_NUMB
                               AND e.Entity_ID = @Lc_EsemDistCur_Entity_ID)
              BEGIN
			   SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_DIST';               
			   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EsemDistCur_TypeEntity_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDistribution1830_NUMB AS VARCHAR ),'')+ ', Entity_ID = ' + ISNULL(@Lc_EsemDistCur_Entity_ID,'');

               INSERT INTO ESEM_Y1
                           (TypeEntity_CODE,
                            EventGlobalSeq_NUMB,
                            EventFunctionalSeq_NUMB,
                            Entity_ID)
                    VALUES ( @Lc_EsemDistCur_TypeEntity_CODE,    --TypeEntity_CODE
                             @Ln_EventGlobalSeq_NUMB,    --EventGlobalSeq_NUMB
                             @Li_TanfDistribution1830_NUMB,    --EventFunctionalSeq_NUMB
                             @Lc_EsemDistCur_Entity_ID  --Entity_ID
							); 
              END;

             SET @Ls_Sql_TEXT = 'FETCH EsemDist_CUR - 4';             
             SET @Ls_Sqldata_TEXT = '';
             
             FETCH EsemDist_CUR INTO @Lc_EsemDistCur_TypeEntity_CODE, @Lc_EsemDistCur_Entity_ID, @Ln_EsemDistCur_Row_NUMB;

             SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
            END;

           CLOSE EsemDist_CUR;
           DEALLOCATE EsemDist_CUR;

           SET @Lc_InsertEsem_INDC = @Lc_Yes_INDC;
          -------< START - ESEM Insertion for Welfare Distributed receipts >------
          END;

         ---------------< END - Storing unique Welfare CASE_ID >---------------
         -- Select the next latest TANF Case if still money exists
         SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y12';         
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'');

         SELECT TOP 1 @Ln_CaseWelfare_IDNO = CaseWelfare_IDNO,
                      @Ld_Begin_DATE = Start_DATE
           FROM MHIS_Y1 a
          WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
            AND Case_IDNO = @Ln_Case_IDNO
            AND TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
            AND End_DATE = (SELECT MAX (c.End_DATE)
                              FROM MHIS_Y1 c
                             WHERE c.MemberMci_IDNO = @Ln_MemberMci_IDNO
                               AND c.Case_IDNO = @Ln_Case_IDNO
                               AND c.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                               AND c.End_DATE < @Ld_Begin_DATE);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           -- If the welf Case-Seq_IDNO is not found, comes out of the loop
           BREAK;
          END
        END;

		-- Defect 13319 - PA arrears in excess of URA not always moving to UDA - Fix -- Start --
		SET @Ls_Sql_TEXT = 'DELETE #IVACaseCpAssociatedIVDCaseOblg_P1';     
		SET @Ls_Sqldata_TEXT = '';
		
		DELETE #IVACaseCpAssociatedIVDCaseOblg_P1

		SET @Ls_Sql_TEXT = 'INSERT_#IVACaseCpAssociatedIVDCaseOblg_P1 - 1';                  
		SET @Ls_Sqldata_TEXT = '@Ln_CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfare_IDNO AS VARCHAR ),'')+ ', @Ln_AllWemoCur_WemoCase_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'') + ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'');

		INSERT INTO #IVACaseCpAssociatedIVDCaseOblg_P1
				   (Case_IDNO,
					OrderSeq_NUMB,
					ObligationSeq_NUMB,
					WelfareYearMonth_NUMB)
			SELECT DISTINCT Case_IDNO,
					OrderSeq_NUMB,
					ObligationSeq_NUMB,
					WelfareYearMonth_NUMB FROM WEMO_Y1 a
				 WHERE a.CaseWelfare_IDNO = @Ln_CaseWelfare_IDNO                 
				 AND Case_IDNO IN  (SELECT DISTINCT Case_IDNO 
									FROM CMEM_Y1 b 
									WHERE b.MemberMCI_IDNO = (SELECT MemberMCI_IDNO FROM CMEM_Y1 C WHERE C.Case_IDNO = @Ln_AllWemoCur_WemoCase_IDNO AND c.CaseRelationship_CODE = 'C'  AND c.CaseMemberStatus_CODE = 'A')
									AND b.CaseRelationship_CODE = 'C' 
									AND b.CaseMemberStatus_CODE = 'A' 
                                    ) 
                 AND a.WelfareYearMonth_NUMB = @Ln_AllWemoCur_WelfareYearMonth_NUMB
                 AND a.EndValidity_DATE = '12/31/9999';
		
		 SET @Ls_Sql_TEXT = 'INSERT_#AssignArr_P1 - 2';   
		 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WemoObligationSeq_NUMB AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCur_WelfareYearMonth_NUMB AS VARCHAR ),'');

		  INSERT INTO #AssignArr_P1
					   (Case_IDNO,
						OrderSeq_NUMB,
						ObligationSeq_NUMB,
						WelfareYearMonth_NUMB)
			SELECT Case_IDNO,
					OrderSeq_NUMB,
					ObligationSeq_NUMB,
					WelfareYearMonth_NUMB
			FROM #IVACaseCpAssociatedIVDCaseOblg_P1 a
			WHERE NOT EXISTS (SELECT 1 FROM #AssignArr_P1 b 
							 WHERE a.Case_IDNO = b.Case_IDNO
								AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
								AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
								AND a.WelfareYearMonth_NUMB = b.WelfareYearMonth_NUMB);		
		-- Defect 13319 - PA arrears in excess of URA not always moving to UDA - Fix -- End --

       DECLARE AssignArr_Cur INSENSITIVE CURSOR FOR
        SELECT t.Case_IDNO,
               t.OrderSeq_NUMB,
               t.ObligationSeq_NUMB,
               t.WelfareYearMonth_NUMB,
               t.Row_NUMB
          FROM #AssignArr_P1 t;

       --Runs for the no. of times, the Welf Case-Seq_IDNO is for that CASE_ID
       SET @Ls_Sql_TEXT = 'OPEN AssignArr_Cur -1';       
       SET @Ls_Sqldata_TEXT = '';
       
       OPEN AssignArr_Cur;

       SET @Ls_Sql_TEXT = 'OPEN AssignArr_Cur -1';       
       SET @Ls_Sqldata_TEXT = '';
       
       FETCH AssignArr_Cur INTO @Ln_AssignArrCur_Case_IDNO, @Ln_AssignArrCur_Order_NUMB, @Ln_AssignArrCur_Obligation_NUMB, @Ln_AssignArrCur_Welfare_NUMB, @Ln_AssignArrCur_Row_NUMB;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT = 'WHILE LOOP-7';       
       SET @Ls_Sqldata_TEXT = '';
       
       --LOOP BEGIN
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REASSIGN_ARREARS';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AssignArrCur_Case_IDNO AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AssignArrCur_Order_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AssignArrCur_Obligation_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_AssignArrCur_Welfare_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Screen_ID = ' + ISNULL('','')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'');

         EXECUTE BATCH_COMMON$SP_REASSIGN_ARREARS
          @An_Case_IDNO             = @Ln_AssignArrCur_Case_IDNO,
          @An_CpMci_IDNO            = @Ln_CpMci_IDNO,
          @An_OrderSeq_NUMB         = @Ln_AssignArrCur_Order_NUMB,
          @An_ObligationSeq_NUMB    = @Ln_AssignArrCur_Obligation_NUMB,
          @An_SupportYearMonth_NUMB = @Ln_AssignArrCur_Welfare_NUMB,
          @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ac_Screen_ID             = '',
          @Ad_Process_DATE          = @Ld_Process_DATE;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'OPEN AssignArr_Cur -2';     
         SET @Ls_Sqldata_TEXT = '';    
         
         FETCH AssignArr_Cur INTO @Ln_AssignArrCur_Case_IDNO, @Ln_AssignArrCur_Order_NUMB, @Ln_AssignArrCur_Obligation_NUMB, @Ln_AssignArrCur_Welfare_NUMB, @Ln_AssignArrCur_Row_NUMB;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE AssignArr_Cur;

       DEALLOCATE AssignArr_Cur;
      END
     ELSE
      BEGIN
       SET @Ln_Arrear_AMNT = @Ln_Arrear_AMNT + @Ln_TransactionCurSup_AMNT;
      END

     ----------------------< Distribution + Hold - Start>-----------------------
     IF @Ln_Arrear_AMNT = @Ln_TanfCur_TransactionPaa_AMNT + @Ln_TanfCur_TransactionCurSup_AMNT
        AND @Lc_Wemo_INDC = @Lc_Yes_INDC
        AND @Lc_TanfCur_TypeHold_CODE != @Lc_RegularHoldD_CODE
      BEGIN
       GOTO NEXT_REC;
      END
	  -- 1840 - TANF DISBURSEMENT HOLD
     IF @Ln_Arrear_AMNT > 0
        AND @Lc_Wemo_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_1840';       
       SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDisbursementHold1840_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'');

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Li_TanfDisbursementHold1840_NUMB,
        @Ac_Process_ID              = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
        @Ac_Note_INDC               = @Lc_No_INDC,
        @Ac_Worker_ID               = @Lc_BatchRunUser_ID,
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalHoldSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
        
	   -- NO IV-A GRANT	
       SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_2';	   
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL(CAST( @Ln_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_Paa_AMNT AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TanfHoldT_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisbursementHold_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeld_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusSdng_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');

       EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
        @An_Case_IDNO                  = @Ln_Case_IDNO,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
        @An_TransactionCs_AMNT         = @Ln_TransactionCurSup_AMNT,
        @An_TransactionPaa_AMNT        = @Ln_Paa_AMNT,
        @Ac_TypeHold_CODE              = @Lc_TanfHoldT_CODE,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisbursementHold_CODE,
        @Ac_TypeDisbursementDhld_CODE  = @Lc_TanfCur_TypeDisburse_CODE,
        @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
        @Ac_Status_CODE                = @Lc_DisbursementStatusHeld_CODE,
        @Ac_Reason_CODE                = @Lc_ReasonStatusSdng_CODE,
        @An_EventGlobalSupportSeq_NUMB = @Ln_TanfCur_EventGlobalSupportSeq_NUMB,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalHoldSeq_NUMB,
        @Ac_CheckRecipient_ID          = @Lc_TanfCur_CheckRecipient_ID,
        @Ac_CheckRecipient_CODE        = @Lc_TanfCur_CheckRecipient_CODE,
        @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
        @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ln_Arrear_AMNT = 0;
      END

     ----------------------< Distribution + Hold - End >-----------------------
     Process_Excess:

     IF @Ln_Arrear_AMNT > 0
        AND @Lc_Wemo_INDC = @Lc_No_INDC
      BEGIN

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_1840';       
       SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDisbursementHold1840_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'');

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Li_TanfDisbursementHold1840_NUMB,
        @Ac_Process_ID              = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
        @Ac_Note_INDC               = @Lc_No_INDC,
        @Ac_Worker_ID               = @Lc_BatchRunUser_ID,
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalHoldSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      
       IF @Ln_Paa_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_LWEL_Y13';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_CaseWelfarePrim_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Distribute_AMNT = ' + ISNULL(CAST( @Ln_Paa_AMNT AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'');

         INSERT LWEL_Y1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 WelfareYearMonth_NUMB,
                 Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 CaseWelfare_IDNO,
                 TypeWelfare_CODE,
                 Distribute_DATE,
                 Distribute_AMNT,
                 TypeDisburse_CODE,
                 EventGlobalSeq_NUMB,
                 EventGlobalSupportSeq_NUMB)
         VALUES ( @Ln_Case_IDNO,   --Case_IDNO
                  @Ln_OrderSeq_NUMB,   --OrderSeq_NUMB
                  @Ln_ObligationSeq_NUMB,   --ObligationSeq_NUMB
                  ISNULL (@Ln_AllWemoCur_WelfareYearMonth_NUMB, SUBSTRING(CONVERT(VARCHAR(6),@Ld_Process_DATE,112),1,6)),   --WelfareYearMonth_NUMB
                  @Ld_Batch_DATE,   --Batch_DATE
                  @Ln_Batch_NUMB,   --Batch_NUMB
                  @Ln_SeqReceipt_NUMB,   --SeqReceipt_NUMB
                  @Lc_SourceBatch_CODE,   --SourceBatch_CODE
                  @Ln_CaseWelfarePrim_IDNO,   --CaseWelfare_IDNO
                  @Lc_WelfareTypeTanf_CODE,   --TypeWelfare_CODE
                  @Ld_Process_DATE,   --Distribute_DATE
                  @Ln_Paa_AMNT,   --Distribute_AMNT
                  CASE
                   WHEN @Lc_TanfCur_TypeDisburse_CODE = @Lc_TypeDisbursementChpaa_CODE
                    THEN @Lc_TypeDisbursementCxpaa_CODE
                   ELSE @Lc_TypeDisbursementAxpaa_CODE
                  END,   --TypeDisburse_CODE
                  @Ln_EventGlobalHoldSeq_NUMB,    --EventGlobalSeq_NUMB
                  @Ln_TanfCur_EventGlobalSupportSeq_NUMB  --EventGlobalSupportSeq_NUMB
				);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT_LWEL_Y13 FAILED';

           RAISERROR (50001,16,1);
          END

        END
		-- Any payment in excess of un-reimbursed assistance will be placed on disbursement hold by writing into DHLD_Y1 table. 
		-- This will enable the user to analyze the supplemental grants, if any, before releasing the amount for disbursement to the CP. 
		-- For each of the LWEL_Y1 table entries for the "Excess over un-reimbursed grant", a corresponding entry will be made in the DHLD_Y1 table
        -- SDUX - SYSTEM HOLD CLIENT EXCESS OVER URA
       IF @Ln_Paa_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_3';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL('0','')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_Paa_AMNT AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TanfHoldT_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisbursementExcs_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Lc_TanfCur_TypeDisburse_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeld_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusSdux_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_TanfCur_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_TanfCur_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'');

         EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
          @An_Case_IDNO                  = @Ln_Case_IDNO,
          @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
          @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
          @Ad_Batch_DATE                 = @Ld_Batch_DATE,
          @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
          @An_Batch_NUMB                 = @Ln_Batch_NUMB,
          @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
          @Ad_Receipt_DATE               = @Ld_Receipt_DATE,
          @An_TransactionCs_AMNT         = 0,
          @An_TransactionPaa_AMNT        = @Ln_Paa_AMNT,
          @Ac_TypeHold_CODE              = @Lc_TanfHoldT_CODE,
          @Ac_TypeDisburse_CODE          = @Lc_TypeDisbursementExcs_CODE,
          @Ac_TypeDisbursementDhld_CODE  = @Lc_TanfCur_TypeDisburse_CODE,
          @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
          @Ac_Status_CODE                = @Lc_DisbursementStatusHeld_CODE, 
          @Ac_Reason_CODE                = @Lc_ReasonStatusSdux_CODE, 
          @An_EventGlobalSupportSeq_NUMB = @Ln_TanfCur_EventGlobalSupportSeq_NUMB,
          @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalHoldSeq_NUMB, 
          @Ac_CheckRecipient_ID          = @Lc_TanfCur_CheckRecipient_ID,
          @Ac_CheckRecipient_CODE        = @Lc_TanfCur_CheckRecipient_CODE,
          @Ac_SourceReceipt_CODE         = @Lc_SourceReceipt_CODE,
          @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
          @Ad_Process_DATE               = @Ld_Process_DATE OUTPUT;
          
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END

       IF @Lc_InsertEsem_INDC = @Lc_No_INDC
        BEGIN
         DECLARE EsemDist_CUR INSENSITIVE CURSOR FOR
         SELECT p.TypeEntity_CODE,
                    p.Entity_ID,
                    p.Row_NUMB
               FROM #EsemDist_P1 p;
         SET @Ls_Sql_TEXT = 'OPEN EsemDist_CUR	-	3';         
         SET @Ls_Sqldata_TEXT = '';
         
         OPEN EsemDist_CUR;

         SET @Ls_Sql_TEXT = 'FETCH EsemDist_CUR	-	5';         
         SET @Ls_Sqldata_TEXT = '';
         
         FETCH EsemDist_CUR INTO @Lc_EsemDistCur_TypeEntity_CODE, @Lc_EsemDistCur_Entity_ID, @Ln_EsemDistCur_Row_NUMB;

         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         SET @Ls_Sql_TEXT = 'WHILE LOOP -8';    
         SET @Ls_Sqldata_TEXT = '';
             
         --LOOP BEGIN
         WHILE @Li_FetchStatus_QNTY = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_DIST';
           SET @Ls_Sqldata_TEXT = '';
           
           IF NOT EXISTS (SELECT 1
                            FROM ESEM_Y1 e
                           WHERE e.TypeEntity_CODE = @Lc_EsemDistCur_TypeEntity_CODE
                             AND e.EventGlobalSeq_NUMB = @Ln_EventGlobalSeq_NUMB
                             AND e.EventFunctionalSeq_NUMB = @Li_TanfDistribution1830_NUMB
                             AND e.Entity_ID = @Lc_EsemDistCur_Entity_ID)
            BEGIN
             SET @Ls_Sql_TEXT = 'INSERT ESEM_Y1 ';
             SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EsemDistCur_TypeEntity_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDistribution1830_NUMB AS VARCHAR ),'')+ ', Entity_ID = ' + ISNULL(@Lc_EsemDistCur_Entity_ID,'');

             INSERT ESEM_Y1
                         (TypeEntity_CODE,
                          EventGlobalSeq_NUMB,
                          EventFunctionalSeq_NUMB,
                          Entity_ID)
                  VALUES ( @Lc_EsemDistCur_TypeEntity_CODE,    --TypeEntity_CODE
                           @Ln_EventGlobalSeq_NUMB,    --EventGlobalSeq_NUMB
                           @Li_TanfDistribution1830_NUMB,    --EventFunctionalSeq_NUMB
                           @Lc_EsemDistCur_Entity_ID  --Entity_ID
						 ); 
            END;

           SET @Ls_Sql_TEXT = 'FETCH EsemDist_CUR	-	6'; 
           SET @Ls_Sqldata_TEXT = '';     
           
           FETCH EsemDist_CUR INTO @Lc_EsemDistCur_TypeEntity_CODE, @Lc_EsemDistCur_Entity_ID, @Ln_EsemDistCur_Row_NUMB;

           SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
          END

         CLOSE EsemDist_CUR;
         DEALLOCATE EsemDist_CUR;
        END
      END

     UPDATE_DHLD:
	 --Do logical update on a previously held record
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE DHLD_Y11';       
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_TanfCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_TanfCur_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Unique_IDNO = ' + ISNULL(CAST( @Ln_TanfCur_Unique_IDNO AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_TanfCur_Transaction_DATE AS VARCHAR ),'');

       UPDATE DHLD_Y1
          SET EndValidity_DATE = @Ld_Process_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        WHERE Case_IDNO = @Ln_TanfCur_Case_IDNO
          AND OrderSeq_NUMB = @Ln_TanfCur_OrderSeq_NUMB
          AND ObligationSeq_NUMB = @Ln_TanfCur_ObligationSeq_NUMB
          AND Unique_IDNO = @Ln_TanfCur_Unique_IDNO
          AND Transaction_DATE = @Ld_TanfCur_Transaction_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = ' UPDATE_DHLD_Y1 FAILED';

         RAISERROR (50001,16,1);
        END
      END;

     NEXT_REC:
     
    END TRY
    
    BEGIN CATCH
     
     IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SaveTanfDistTran;
       END
     ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
        RAISERROR( 50001 ,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_TypeError_CODE = @Lc_TypeErrorE_CODE;
        SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
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
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_CursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
    
    END CATCH
    
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION TanfDistTran;
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       BEGIN TRANSACTION TanfDistTran;

       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION TanfDistTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH TanfCur - 2';     
     SET @Ls_Sqldata_TEXT = '';
     
     FETCH Tanf_CUR INTO @Ln_TanfCur_Seq_IDNO, @Ld_TanfCur_Batch_DATE, @Lc_TanfCur_SourceBatch_CODE, @Ln_TanfCur_Batch_NUMB, @Ln_TanfCur_SeqReceipt_NUMB, @Ld_TanfCur_Receipt_DATE, @Ln_TanfCur_Case_IDNO, @Ln_TanfCur_OrderSeq_NUMB, @Ln_TanfCur_ObligationSeq_NUMB, @Ln_TanfCur_TransactionCurSup_AMNT, @Ln_TanfCur_TransactionPaa_AMNT, @Lc_TanfCur_TypeDisburse_CODE, @Ln_TanfCur_EventGlobalSupportSeq_NUMB, @Ln_TanfCur_EventGlobalBeginSeq_NUMB, @Lc_TanfCur_CheckRecipient_ID, @Lc_TanfCur_CheckRecipient_CODE, @Lc_TanfCur_TypeHold_CODE, @Ln_TanfCur_Unique_IDNO, @Ld_TanfCur_Transaction_DATE, @Ln_TanfCur_CheckRecipient_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Tanf_CUR;

   DEALLOCATE Tanf_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_CursorRecordCount_QNTY;

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL('0','')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorNoRecordsE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_ErrorNoRecordsE0944_CODE,
      @As_DescriptionError_TEXT	   = @Ls_Sql_TEXT,      
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';   
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Process_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';  
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Create_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Create_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION TanfDistTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TanfDistTran;
    END;

   IF CURSOR_STATUS ('LOCAL', 'EsemDist_CUR') IN (0, 1)
    BEGIN
     CLOSE EsemDist_CUR;

     DEALLOCATE EsemDist_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'AssignArr_Cur') IN (0, 1)
    BEGIN
     CLOSE AssignArr_Cur;

     DEALLOCATE AssignArr_Cur;
    END

   IF CURSOR_STATUS ('LOCAL', 'AllWemo_CUR') IN (0, 1)
    BEGIN
     CLOSE AllWemo_CUR;

     DEALLOCATE AllWemo_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Tanf_CUR') IN (0, 1)
    BEGIN
     CLOSE Tanf_CUR;

     DEALLOCATE Tanf_CUR;
    END

   --Check for Exception information to log the description text based on the error
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
    @Ad_Start_DATE                = @Ld_Create_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
