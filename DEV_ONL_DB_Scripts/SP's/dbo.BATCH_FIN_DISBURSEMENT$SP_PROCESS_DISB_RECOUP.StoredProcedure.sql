/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_PROCESS_DISB_RECOUP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_DISBURSEMENT$SP_PROCESS_DISB_RECOUP
Programmer Name	:	IMP Team.
Description		:	This procedure reads disbursement records that are loaded in the disbursements hold table 
					  (DHLD_Y1) and disburses to CP / FIPS / TANF COUNTies / Medicaid / IVE / Other parties.
						999999963 - NCP NSF FEE RECOVERY - FINANCIAL JOURNAL ENTRY
						999999964 - CP NSF FEE RECOVERY - FINANCIAL JOURNAL ENTRY
						999999977 - IRS FEE RECIPIENT - STATE
						999999978 - DRA FEE RECIPIENT - STATE
						999999980 - OUT OF STATE RECOVERY - FINANCIAL JOURNAL ENTRY
						999999982 - DELAWARE MEDICAID AGENCY
						999999983 - DELAWARE STATE TREASURY
						999999993 - DEPARTMENT OF SERVICES FOR CHILD, YOUTH AND THEIR FAMILIES
						999999994 - DELAWARE DIVISION OF SOCIAL SERVICES
Frequency		:	'DAILY'
Developed On	:	1/31/2012
Called By		:	NONE
Called On		:	BATCH_FIN_DISBURSEMENT$SP_RESET,BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY,BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS,
					  BATCH_FIN_DISBURSEMENT$SP_GET_DTLS_FOR_ORIGINAL_RCPT,BATCH_FIN_DISBURSEMENT$SP_RECOUP_PERCENT,
					  BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD,BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD,
					  BATCH_FIN_DISBURSEMENT$SP_CHANGE_RECEIPT_STATUS,BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH,
					  BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH_REFND
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_PROCESS_DISB_RECOUP]
AS
 BEGIN
  SET NOCOUNT ON;

  CREATE TABLE #Tlhld_P1
   (
     Case_IDNO                  NUMERIC(6),
     OrderSeq_NUMB              NUMERIC(2),
     ObligationSeq_NUMB         NUMERIC(2),
     Batch_DATE                 DATE,
     SourceBatch_CODE           CHAR(3),
     Batch_NUMB                 NUMERIC(4),
     SeqReceipt_NUMB            NUMERIC(6),
     Transaction_AMNT           NUMERIC(11, 2),
     TypeDisburse_CODE          CHAR(5),
     CheckRecipient_ID          CHAR(10),
     CheckRecipient_CODE        CHAR(1),
     DisburseSubSeq_NUMB        NUMERIC(6),
     EventGlobalSupportSeq_NUMB NUMERIC(19),
     Disburse_DATE              DATE,
     DisburseSeq_NUMB           NUMERIC(4),
     StatusEscheat_DATE         DATE,
     StatusEscheat_CODE         CHAR(2)
   );

  DECLARE @Li_Disbursement2245_NUMB           INT = 2245,
          @Li_Escheated2280_NUMB              INT = 2280,
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_RecipientTypeCpNcp_CODE         CHAR(1) = '1',
          @Lc_CheckRecipientCpNcp_CODE		  CHAR(1) = '1',
          @Lc_CheckRecipientFips_CODE		  CHAR(1) = '2',
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_No_INDC                         CHAR(1) = 'N',
          @Lc_Yes_INDC                        CHAR(1) = 'Y',
          @Lc_RecipientTypeOthp_CODE          CHAR(1) = '3',
          @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
          @Lc_DsbhMediumDisburseCheck_CODE    CHAR(1) = 'C',
          @Lc_DhldTypeHoldP_CODE              CHAR(1) = 'P',
          @Lc_DhldTypeHoldD_CODE              CHAR(1) = 'D',
          @Lc_DhldTypeHoldC_CODE              CHAR(1) = 'C',
          @Lc_CpDeceInstInca_CODE             CHAR(1) = 'N',
          @Lc_StatusR_CODE					  CHAR(1) = 'R',
          @Lc_TypeErrorE_CODE				  CHAR(1) = 'E',
          @Lc_SourceReceiptCpRecoupment_CODE  CHAR(2) = 'CR',
          @Lc_ReasonStatusSr_CODE             CHAR(2) = 'SR',
          @Lc_SourceReceiptSc_CODE			  CHAR(2) = 'SC',
          @Lc_SourceReceiptCf_CODE			  CHAR(2) = 'CF',
          @Lc_SourceReceiptNr_CODE			  CHAR(2) = 'NR',
          @Lc_FeeTypeDrafee_CODE              CHAR(2) = 'DR',
          @Lc_FeeTypeIrsfee_CODE              CHAR(2) = 'SC',
          @Lc_RecoupmentTypeNsf_CODE		  CHAR(3) = 'NSF',
          @Lc_TypeDisburseRefnd_CODE          CHAR(5) = 'REFND',
          @Lc_TypeDisburseROthp_CODE          CHAR(5) = 'ROTHP',
          @Lc_ErrorE1424_CODE				  CHAR(5) = 'E1424',
          @Lc_Job_ID                          CHAR(7) = 'DEB0620',
          @Lc_CheckRecipientTaxofffee_ID      CHAR(9) = '999999977',
          @Lc_CheckRecipientCpdrafee_ID       CHAR(9) = '999999978',
          @Lc_CheckRecipientTreas999999983_ID CHAR(9) = '999999983',
          @Lc_CheckRecipientOsr999999980_ID   CHAR(9) = '999999980',
          @Lc_CheckRecipientCpnsffee_ID       CHAR(9) = '999999964',
          @Lc_CheckRecipientNcpnsffee_ID      CHAR(9) = '999999963',
          @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
          @Lc_NoRecordsProcessed_TEXT         CHAR(40) = 'NO RECORDS PROCESSED',
          @Ls_ParmDateProblem_TEXT            VARCHAR(100) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_DISBURSEMENT',
          @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_PROCESS_DISB_RECOUP',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE @Ln_RecCount_QNTY               NUMERIC(1),
          @Ln_OrderSeq_NUMB               NUMERIC(2),
          @Ln_ObligationSeq_NUMB          NUMERIC(2),
          @Ln_Batch_NUMB                  NUMERIC(4),
          @Ln_DisburseSeq_NUMB            NUMERIC(4),
		  @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_DisbursementAllowed_NUMB    NUMERIC(5, 2),
          @Ln_Case_IDNO                   NUMERIC(6),
          @Ln_SeqReceipt_NUMB             NUMERIC(6),
          @Ln_Disburse_QNTY               NUMERIC(6) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
		  @Ln_ProcessedRecordsCountCommit_QNTY NUMERIC (6) = 0,
          @Ln_RegCursorRecordCount_QNTY   NUMERIC(9) = 0,
          @Ln_RefundCursorRecordCount_QNTY NUMERIC(9) = 0,
          @Ln_CRCursorRecordCount_QNTY    NUMERIC(9) = 0,
          @Ln_StPendTotOffset_AMNT        NUMERIC(11, 2),
          @Ln_StAssessTotOverpay_AMNT     NUMERIC(11, 2),
          @Ln_StRecTotAdvance_AMNT        NUMERIC(11, 2),
          @Ln_StRecTotOverpay_AMNT        NUMERIC(11, 2),
          @Ln_StTotBalOvpy_AMNT           NUMERIC(11, 2),
          @Ln_Remaining_AMNT              NUMERIC(11, 2) = 0,
          @Ln_TotDisburse_AMNT            NUMERIC(11, 2) = 0,
          @Ln_Disbursed_AMNT              NUMERIC(11, 2) = 0,
          @Ln_OdOrigRcpt_AMNT             NUMERIC(11, 2) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TotIrsFee_AMNT              NUMERIC(11, 2),
          @Ln_TotDraFee_AMNT              NUMERIC(11, 2),
          @Ln_Fee_AMNT                    NUMERIC(11, 2),
          @Ln_OffsetEligIrs_AMNT          NUMERIC(11, 2) = 0,
          @Ln_OffsetFeeIrs_AMNT           NUMERIC(11, 2) = 0,
          @Ln_DraFee_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_DisbEligYtdDra_AMNT         NUMERIC(11, 2) = 0,
          @Ln_EventGlobalSupportSeq_NUMB  NUMERIC(19),
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Li_Rowcount_QNTY               INT,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_ChldChkRecipient_CODE       CHAR(1),
          @Lc_CheckRecipient_CODE         CHAR(1),
          @Lc_PoflCheckRecipient_CODE     CHAR(1),
          @Lc_MediumDisburse_CODE         CHAR(1),
          @Lc_AddrEftChk_INDC             CHAR(1),
          @Lc_RecoupmentPayee_CODE        CHAR(1),
          @Lc_SourceReceipt_CODE          CHAR(2),
          @Lc_SourceBatch_CODE            CHAR(3),
          @Lc_RecoupmentType_CODE         CHAR(3),
          @Lc_ReasonStatusNew_CODE        CHAR(4),
          @Lc_ReasonStatusOld_CODE        CHAR(4),
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_Reason_CODE                 CHAR(5),
          @Lc_TypeDisburse_CODE           CHAR(5),
          @Lc_ChldChkRecipient_ID         CHAR(10),
          @Lc_CheckRecipient_ID           CHAR(10),
          @Lc_PoflCheckRecipient_ID       CHAR(10),
          @Lc_BateError_CODE              CHAR(18),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Expire_DATE                 DATE,
          @Ld_Run_DATE                    DATE,
          @Ld_Batch_DATE                  DATE,
          @Ld_Disburse_DATE               DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Lb_ChldExists_BIT              BIT,
          @Lb_ChldQueried_BIT             BIT,
          @Lb_RecpQueried_BIT             BIT;
  DECLARE @Lc_DhldCur_CheckRecipient_ID          CHAR(10),
          @Lc_DhldCur_CheckRecipient_CODE        CHAR(1),
          @Ln_DhldCur_Case_IDNO                  NUMERIC(6),
          @Ln_DhldCur_OrderSeq_NUMB              NUMERIC(2),
          @Ln_DhldCur_ObligationSeq_NUMB         NUMERIC(2),
          @Ld_DhldCur_Batch_DATE                 DATE,
          @Lc_DhldCur_SourceBatch_CODE           CHAR(3),
          @Ln_DhldCur_Batch_NUMB                 NUMERIC(4),
          @Ln_DhldCur_SeqReceipt_NUMB            NUMERIC(6),
          @Lc_DhldCur_TypeDisburse_CODE          CHAR(5),
          @Ld_DhldCur_Transaction_DATE           DATE,
          @Ln_DhldCur_Transaction_AMNT           NUMERIC(11, 2),
          @Lc_DhldCur_Status_CODE                CHAR(1),
          @Lc_DhldCur_TypeHold_CODE              CHAR(1),
          @Lc_DhldCur_ProcessOffset_INDC         CHAR(1),
          @Lc_DhldCur_ReasonStatus_CODE          CHAR(4),
          @Lc_DhldCur_ReasonStatusOld_CODE       CHAR(4),
          @Ln_DhldCur_EventGlobalSupportSeq_NUMB NUMERIC(19),
          @Ln_DhldCur_Unique_IDNO                NUMERIC(19),
          @Ld_DhldCur_Disburse_DATE              DATE,
          @Ln_DhldCur_DisburseSeq_NUMB           NUMERIC(4),
          @Lc_DhldCur_TypeRecoupment_CODE        CHAR(3),
          @Ln_DhldCur_Row_NUMB                   NUMERIC (5),
          @Ln_DhldCur_Count_QNTY                 NUMERIC(11),
          @Lc_DhldCur_SourceReceipt_CODE         CHAR(2);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_CursorLocation_TEXT = @Lc_Space_TEXT;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'SELECT_RSTL_Y1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_RecCount_QNTY = 1
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     -- When executed for the first time on a given day, DELETE PESEM_Y1
     SET @Ls_Sql_TEXT = 'DELETE FROM PESEM_Y1';
     SET @Ls_SqlData_TEXT = '';
     DELETE FROM PESEM_Y1;

     SET @Ls_Sql_TEXT = 'INSERT_RSTL_Y1';
     SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(@Lc_Space_TEXT, '');

     INSERT RSTL_Y1
            (Job_ID,
             Run_DATE,
             RestartKey_TEXT)
     VALUES (@Lc_Job_ID,--Job_ID
             @Ld_Run_DATE,--Run_DATE
             @Lc_Space_TEXT --RestartKey_TEXT
     );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_RSTL_Y1 FAILED';

       RAISERROR (50001,16,1);
      END
    END;

   SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_GET_FEE_DETAILS';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_FIN_DISBURSEMENT$SP_GET_FEE_DETAILS
    @An_OffsetEligIrs_AMNT    = @Ln_OffsetEligIrs_AMNT OUTPUT,
    @An_OffsetFeeIrs_AMNT     = @Ln_OffsetFeeIrs_AMNT OUTPUT,
    @An_DraFee_AMNT           = @Ln_DraFee_AMNT OUTPUT,
    @An_DisbEligYtdDra_AMNT   = @Ln_DisbEligYtdDra_AMNT OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RESET BEFORE CR';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_FIN_DISBURSEMENT$SP_RESET
    @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT OUTPUT,
    @An_Disburse_QNTY         = @Ln_Disburse_QNTY OUTPUT,
    @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
    @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @Ab_RecpQueried_BIT       = @Lb_RecpQueried_BIT OUTPUT,
    @Ab_ChldQueried_BIT       = @Lb_ChldQueried_BIT OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- BEGIN TRANSACTION
   BEGIN TRANSACTION DisbTran;

   -- First cursor for CP recoupments
   SET @Ls_Sql_TEXT = 'Defining CURSOR Dhld_CUR';
   SET @Ls_SqlData_TEXT = '';

   DECLARE DhldCPRecoup_CUR INSENSITIVE CURSOR FOR
    SELECT f.CheckRecipient_ID,
           f.CheckRecipient_CODE,
           f.Case_IDNO,
           f.OrderSeq_NUMB,
           f.ObligationSeq_NUMB,
           f.Batch_DATE,
           f.SourceBatch_CODE,
           f.Batch_NUMB,
           f.SeqReceipt_NUMB,
           f.TypeDisburse_CODE,
           f.Transaction_DATE,
           f.Transaction_AMNT,
           f.Status_CODE,
           f.TypeHold_CODE,
           f.ProcessOffset_INDC,
           f.ReasonStatus_CODE,
           f.EventGlobalSupportSeq_NUMB,
           f.Unique_IDNO,
           f.Disburse_DATE,
           f.DisburseSeq_NUMB,
           f.type_recoupment,
           f.rn,
           f.Count_QNTY
      FROM (SELECT a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ObligationSeq_NUMB,
                   a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.TypeDisburse_CODE,
                   a.Transaction_DATE,
                   a.Transaction_AMNT,
                   a.Status_CODE,
                   a.TypeHold_CODE,
                   a.ProcessOffset_INDC,
                   a.ReasonStatus_CODE,
                   a.EventGlobalSupportSeq_NUMB,
                   a.Unique_IDNO,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB,
                   @Lc_SourceReceiptCpRecoupment_CODE AS type_recoupment,
                   ROW_NUMBER () OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE ORDER BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Case_IDNO, a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB) AS rn,
                   COUNT (1) OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE) AS Count_QNTY
              FROM DHLD_Y1 a
             WHERE a.Release_DATE <= @Ld_Run_DATE
               AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
               AND a.Status_CODE = @Lc_StatusR_CODE
               AND a.EndValidity_DATE = @Ld_High_DATE
               AND EXISTS (SELECT 1
                             FROM RCTH_Y1 b
                            WHERE a.Batch_DATE = b.Batch_DATE
                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                              AND a.Batch_NUMB = b.Batch_NUMB
                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                              AND b.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupment_CODE
                              AND b.EndValidity_DATE = @Ld_High_DATE)) AS f
     ORDER BY f.CheckRecipient_ID,
              f.CheckRecipient_CODE,
              f.rn,
              f.Count_QNTY;

   SET @Ls_Sql_TEXT = 'OPEN CURSOR Dhld_CUR';
   SET @Ls_SqlData_TEXT = '';

   OPEN DhldCPRecoup_CUR;

   SET @Ls_Sql_TEXT = 'FETCH DhldCPRecoup_CUR 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM DhldCPRecoup_CUR INTO @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Lc_DhldCur_TypeDisburse_CODE, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_Status_CODE, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Lc_DhldCur_TypeRecoupment_CODE, @Ln_DhldCur_Row_NUMB, @Ln_DhldCur_Count_QNTY;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- CP Recoupment cursor proces
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SaveCRDisbTran
     SET @Ln_Case_IDNO = @Ln_DhldCur_Case_IDNO;
     SET @Ln_OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;
     SET @Ln_ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB;
     SET @Ld_Batch_DATE = @Ld_DhldCur_Batch_DATE;
     SET @Ln_Batch_NUMB = @Ln_DhldCur_Batch_NUMB;
     SET @Ln_SeqReceipt_NUMB = @Ln_DhldCur_SeqReceipt_NUMB;
     SET @Lc_SourceBatch_CODE = @Lc_DhldCur_SourceBatch_CODE;
     SET @Lc_TypeDisburse_CODE = @Lc_DhldCur_TypeDisburse_CODE;
     SET @Lc_CheckRecipient_ID = @Lc_DhldCur_CheckRecipient_ID;
     SET @Lc_CheckRecipient_CODE = @Lc_DhldCur_CheckRecipient_CODE;
     SET @Ln_EventGlobalSupportSeq_NUMB = @Ln_DhldCur_EventGlobalSupportSeq_NUMB;
     SET @Ld_Disburse_DATE = @Ld_DhldCur_Disburse_DATE;
     SET @Ln_DisburseSeq_NUMB = @Ln_DhldCur_DisburseSeq_NUMB;
     SET @Lc_ReasonStatusNew_CODE = @Lc_DhldCur_ReasonStatus_CODE;
     SET @Lc_ReasonStatusOld_CODE = @Lc_Space_TEXT;
     SET @Ln_CRCursorRecordCount_QNTY = @Ln_CRCursorRecordCount_QNTY + 1;
     SET @Ln_Remaining_AMNT = @Ln_DhldCur_Transaction_AMNT;
     -- UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
     SET @Ls_CursorLocation_TEXT = 'DhldCPRecoup_CUR-Count = ' + ISNULL (CAST (@Ln_CRCursorRecordCount_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '') + ', Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL (CAST (@Ln_DhldCur_Unique_IDNO AS VARCHAR), '');
	 SET @Ls_BateRecord_TEXT = 'CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '')+ ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL (@Lc_DhldCur_TypeDisburse_CODE, '') + ', Transaction_DATE = ' + ISNULL (CAST (@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Transaction_AMNT = ' + ISNULL (CAST(@Ln_DhldCur_Transaction_AMNT AS VARCHAR), '') + 	', Status_CODE = ' + ISNULL (@Lc_DhldCur_Status_CODE, '') + ', TypeHold_CODE = ' + ISNULL (@Lc_DhldCur_TypeHold_CODE, '') + ', ProcessOffset_INDC = ' + ISNULL (@Lc_DhldCur_ProcessOffset_INDC, '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_DhldCur_ReasonStatus_CODE, '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL (CAST (@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL (CAST (@Ld_DhldCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_DisburseSeq_NUMB AS VARCHAR), '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_DhldCur_ReasonStatus_CODE, '') +  ', Row_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_Row_NUMB AS VARCHAR), '') +  ', Count_QNTY = ' + ISNULL (CAST (@Ln_DhldCur_Count_QNTY AS VARCHAR), '');
	 
     --First row for the recipient
     IF @Ln_DhldCur_Row_NUMB = 1
      BEGIN
       --Resetting Values for the new recipient
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RESET CR';
       SET @Ls_SqlData_TEXT = '';

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_RESET
        @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT OUTPUT,
        @An_Disburse_QNTY         = @Ln_Disburse_QNTY OUTPUT,
        @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
        @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @Ab_RecpQueried_BIT       = @Lb_RecpQueried_BIT OUTPUT,
        @Ab_ChldQueried_BIT       = @Lb_ChldQueried_BIT OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       -- Generate New global event sequence when the check recipient changes
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ CR';
       SET @Ls_SqlData_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Disbursement2245_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Li_Disbursement2245_NUMB,
        @Ac_Process_ID              = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
        @Ac_Note_INDC               = @Lc_No_INDC,
        @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY CR ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', TypeRecoupment_CODE  = ' + ISNULL (@Lc_DhldCur_TypeRecoupment_CODE, '') + ', CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '');

     EXECUTE BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY
      @Ac_TypeRecoupment_CODE        = @Lc_DhldCur_TypeRecoupment_CODE,
      @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
      @An_OdOrigRcpt_AMNT            = @Ln_OdOrigRcpt_AMNT OUTPUT,
      @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
      @Ac_PoflChkRecipient_ID        = @Lc_PoflCheckRecipient_ID OUTPUT,
      @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
      @Ac_PoflChkRecipient_CODE      = @Lc_PoflCheckRecipient_CODE OUTPUT,
      @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
      @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
      @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
      @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
      @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
      @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
      @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
      @An_StPendTotOffset_AMNT       = @Ln_StPendTotOffset_AMNT OUTPUT,
      @An_StAssessTotOverpay_AMNT    = @Ln_StAssessTotOverpay_AMNT OUTPUT,
      @An_StRecTotAdvance_AMNT       = @Ln_StRecTotAdvance_AMNT OUTPUT,
      @An_StRecTotOverpay_AMNT       = @Ln_StRecTotOverpay_AMNT OUTPUT,
      @An_StTotBalOvpy_AMNT          = @Ln_StTotBalOvpy_AMNT OUTPUT,
      @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
      @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
      @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
      @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
      @Ad_Disburse_DATE              = @Ld_Run_DATE OUTPUT,
      @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
      @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     IF @Ld_DhldCur_Transaction_DATE = @Ld_Run_DATE
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE_DHLD_Y1 CR';
       SET @Ls_SqlData_TEXT = 'Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '');

       DELETE DHLD_Y1
        WHERE Transaction_DATE = @Ld_DhldCur_Transaction_DATE
          AND Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND Unique_IDNO = @Ln_DhldCur_Unique_IDNO
          AND ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'DELETE_DHLD_Y1 CR FAILED';

         RAISERROR (50001,16,1);
        END;
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE_DHLD_Y1 CR';
       SET @Ls_SqlData_TEXT = 'Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '');

       UPDATE DHLD_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        WHERE Transaction_DATE = @Ld_DhldCur_Transaction_DATE
          AND Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND Unique_IDNO = @Ln_DhldCur_Unique_IDNO
          AND ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE_DHLD_Y1 CR FAILED';

         RAISERROR (50001,16,1);
        END;
      END
     END TRY
     BEGIN CATCH 
      IF XACT_STATE() = 1
        BEGIN
           ROLLBACK TRANSACTION SaveCRDisbTran;
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
	  SET @Ls_Sql_TEXT = 'DhldCPRecoup_CUR-BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_CRCursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_CRCursorRecordCount_QNTY,
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

		 IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
		  BEGIN
			  SET @Ls_Sql_TEXT = 'DhldCPRecoup_CUR-BATCH_COMMON$SP_CREATE_SDER_HOLD-SDER';
			  SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID  = ' + ISNULL(@Lc_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE,'') + ', Unique_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Unique_IDNO AS VARCHAR ),'');

			  EXECUTE BATCH_COMMON$SP_CREATE_SDER_HOLD
				@Ac_CheckRecipient_ID        = @Lc_CheckRecipient_ID,
				@Ac_CheckRecipient_CODE      = @Lc_CheckRecipient_CODE,
				@An_Unique_IDNO              = @Ln_DhldCur_Unique_IDNO,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;
				
			  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
				RAISERROR (50001,16,1);
			   END
		  END
      END CATCH

     IF @Ln_DhldCur_Row_NUMB = @Ln_DhldCur_Count_QNTY
      BEGIN
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

       IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
          AND @Ln_CommitFreqParm_QNTY > 0
        BEGIN
         COMMIT TRANSACTION DisbTran;
		 SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY; 	
         BEGIN TRANSACTION DisbTran;

         SET @Ln_CommitFreq_QNTY = 0;
        END;
	 END;
	 
     SET @Ls_Sql_TEXT = 'DhldCPRecoup_CUR-EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION DisbTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CRCursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'FETCH DhldCPRecoup_CUR 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM DhldCPRecoup_CUR INTO @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Lc_DhldCur_TypeDisburse_CODE, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_Status_CODE, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Lc_DhldCur_TypeRecoupment_CODE, @Ln_DhldCur_Row_NUMB, @Ln_DhldCur_Count_QNTY;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE DhldCPRecoup_CUR;

   DEALLOCATE DhldCPRecoup_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CRCursorRecordCount_QNTY;
   -- Resetting Values for the new recipient
   SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RESET BEFORE REG_DISB';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_FIN_DISBURSEMENT$SP_RESET
    @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT OUTPUT,
    @An_Disburse_QNTY         = @Ln_Disburse_QNTY OUTPUT,
    @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
    @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @Ab_RecpQueried_BIT       = @Lb_RecpQueried_BIT OUTPUT,
    @Ab_ChldQueried_BIT       = @Lb_ChldQueried_BIT OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Second cursor for other than Refund records, NCP Recoupment receipts and CP Recoupments
   SET @Ls_Sql_TEXT = 'REG DISBURSEMENT - Defining CURSOR dhld_Cur';
   SET @Ls_SqlData_TEXT = '';

   DECLARE Dhld_Cur INSENSITIVE CURSOR FOR
    SELECT f.CheckRecipient_ID,
           f.CheckRecipient_CODE,
           f.Case_IDNO,
           f.OrderSeq_NUMB,
           f.ObligationSeq_NUMB,
           f.Batch_DATE,
           f.SourceBatch_CODE,
           f.Batch_NUMB,
           f.SeqReceipt_NUMB,
           f.TypeDisburse_CODE,
           f.Transaction_DATE,
           f.Transaction_AMNT,
           f.Status_CODE,
           f.TypeHold_CODE,
           f.ProcessOffset_INDC,
           f.ReasonStatus_CODE,
           f.EventGlobalSupportSeq_NUMB,
           f.Unique_IDNO,
           f.Disburse_DATE,
           f.DisburseSeq_NUMB,
           f.ReasonStatusOld_CODE,
           f.SourceReceipt_CODE,
           f.rn,
           f.Count_QNTY
      FROM (SELECT a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ObligationSeq_NUMB,
                   a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.TypeDisburse_CODE,
                   a.Transaction_DATE,
                   a.Transaction_AMNT,
                   a.Status_CODE,
                   a.TypeHold_CODE,
                   a.ProcessOffset_INDC,
                   a.ReasonStatus_CODE,
                   a.EventGlobalSupportSeq_NUMB,
                   a.Unique_IDNO,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB,
                   ISNULL((SELECT TOP 1 ReasonStatus_CODE
                             FROM DHLD_Y1 d
                            WHERE a.Case_IDNO = d.Case_IDNO
                              AND a.OrderSeq_NUMB = d.OrderSeq_NUMB
                              AND a.ObligationSeq_NUMB = d.ObligationSeq_NUMB
                              AND a.Batch_DATE = d.Batch_DATE
                              AND a.Batch_NUMB = d.Batch_NUMB
                              AND a.SourceBatch_CODE = d.SourceBatch_CODE
                              AND a.SeqReceipt_NUMB = d.SeqReceipt_NUMB
                              AND a.EventGlobalBeginSeq_NUMB = d.EventGlobalEndSeq_NUMB), ' ') AS ReasonStatusOld_CODE,
                   (SELECT TOP 1 SourceReceipt_CODE
                      FROM RCTH_Y1 z
                     WHERE a.Batch_DATE = z.Batch_DATE
                       AND a.Batch_NUMB = z.Batch_NUMB
                       AND a.SourceBatch_CODE = z.SourceBatch_CODE
                       AND a.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                       AND z.EndValidity_DATE = @Ld_High_DATE) AS SourceReceipt_CODE,
                   CASE
                    WHEN a.CheckRecipient_CODE IN (@Lc_CheckRecipientCpNcp_CODE, @Lc_CheckRecipientFips_CODE)
                     THEN ROW_NUMBER () OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Case_IDNO, a.Disburse_DATE, a.DisburseSeq_NUMB ORDER BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Disburse_DATE, a.DisburseSeq_NUMB, a.Case_IDNO, a.EventGlobalBeginSeq_NUMB)
                    ELSE ROW_NUMBER () OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Disburse_DATE, a.DisburseSeq_NUMB ORDER BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Disburse_DATE, a.DisburseSeq_NUMB, a.Case_IDNO, a.EventGlobalBeginSeq_NUMB)
                   END AS rn,
                   CASE
                    WHEN a.CheckRecipient_CODE IN (@Lc_CheckRecipientCpNcp_CODE, @Lc_CheckRecipientFips_CODE)
                     THEN COUNT (1) OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Case_IDNO, a.Disburse_DATE, a.DisburseSeq_NUMB)
                    ELSE COUNT (1) OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Disburse_DATE, a.DisburseSeq_NUMB)
                   END AS Count_QNTY
              FROM DHLD_Y1 a
             WHERE a.Release_DATE <= @Ld_Run_DATE
               AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
               AND a.Status_CODE = @Lc_StatusR_CODE
               AND a.EndValidity_DATE = @Ld_High_DATE
               AND NOT EXISTS (SELECT 1
                                 FROM RCTH_Y1 b
                                WHERE a.Batch_DATE = b.Batch_DATE
                                  AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                  AND a.Batch_NUMB = b.Batch_NUMB
                                  AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                  AND b.SourceReceipt_CODE = @Lc_SourceReceiptCpRecoupment_CODE
                                  AND b.EndValidity_DATE = @Ld_High_DATE)) AS f
     ORDER BY f.CheckRecipient_ID,
              f.CheckRecipient_CODE,
              f.Disburse_DATE,
              f.DisburseSeq_NUMB,
              f.Case_IDNO,
              f.rn,
              f.Count_QNTY;

   SET @Ls_Sql_TEXT = 'OPEN CURSOR dhld_Cur 1';
   SET @Ls_SqlData_TEXT = '';

   OPEN Dhld_Cur;

   SET @Ls_Sql_TEXT = 'FETCH dhld_Cur 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM Dhld_Cur INTO @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Lc_DhldCur_TypeDisburse_CODE, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_Status_CODE, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Lc_DhldCur_ReasonStatusOld_CODE, @Lc_DhldCur_SourceReceipt_CODE, @Ln_DhldCur_Row_NUMB, @Ln_DhldCur_Count_QNTY;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- DHLD Cursor process
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
    SAVE TRANSACTION SaveMainDisbTran
     SET @Ln_Case_IDNO = @Ln_DhldCur_Case_IDNO;
     SET @Ln_OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;
     SET @Ln_ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB;
     SET @Ld_Batch_DATE = @Ld_DhldCur_Batch_DATE;
     SET @Ln_Batch_NUMB = @Ln_DhldCur_Batch_NUMB;
     SET @Ln_SeqReceipt_NUMB = @Ln_DhldCur_SeqReceipt_NUMB;
     SET @Lc_SourceBatch_CODE = @Lc_DhldCur_SourceBatch_CODE;
     SET @Lc_TypeDisburse_CODE = @Lc_DhldCur_TypeDisburse_CODE;
     SET @Lc_CheckRecipient_ID = @Lc_DhldCur_CheckRecipient_ID;
     SET @Lc_CheckRecipient_CODE = @Lc_DhldCur_CheckRecipient_CODE;
     SET @Ln_EventGlobalSupportSeq_NUMB = @Ln_DhldCur_EventGlobalSupportSeq_NUMB;
     SET @Ld_Disburse_DATE = @Ld_DhldCur_Disburse_DATE;
     SET @Ln_DisburseSeq_NUMB = @Ln_DhldCur_DisburseSeq_NUMB;
     SET @Lc_ReasonStatusNew_CODE = @Lc_DhldCur_ReasonStatus_CODE;
     SET @Lc_ReasonStatusOld_CODE = @Lc_DhldCur_ReasonStatusOld_CODE;
     SET @Ln_RegCursorRecordCount_QNTY = @Ln_RegCursorRecordCount_QNTY + 1;
     SET @Ln_Remaining_AMNT = @Ln_DhldCur_Transaction_AMNT;
     SET @Ls_CursorLocation_TEXT = 'Dhld_Cur-Count = ' + ISNULL (CAST (@Ln_RegCursorRecordCount_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '') + ', Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL (CAST (@Ln_DhldCur_Unique_IDNO AS VARCHAR), '');

	 -- UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
	 SET @Ls_BateRecord_TEXT = 'CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '')+ ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL (@Lc_DhldCur_TypeDisburse_CODE, '') + ', Transaction_DATE = ' + ISNULL (CAST (@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Transaction_AMNT = ' + ISNULL (CAST(@Ln_DhldCur_Transaction_AMNT AS VARCHAR), '') + ', Status_CODE = ' + ISNULL (@Lc_DhldCur_Status_CODE, '') + ', TypeHold_CODE = ' + ISNULL (@Lc_DhldCur_TypeHold_CODE, '') + ', ProcessOffset_INDC = ' + ISNULL (@Lc_DhldCur_ProcessOffset_INDC, '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_DhldCur_ReasonStatus_CODE, '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL (CAST (@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL (CAST (@Ld_DhldCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_DisburseSeq_NUMB AS VARCHAR), '') + ', ReasonStatusOld_CODE = ' + ISNULL (@Lc_ReasonStatusOld_CODE, '') + ', SourceReceipt_CODE = ' + ISNULL (@Lc_DhldCur_SourceReceipt_CODE, '') +   ', Row_NUMB = ' + ISNULL (CAST (@Ln_DhldCur_Row_NUMB AS VARCHAR), '') + ', Count_QNTY = ' + ISNULL (CAST (@Ln_DhldCur_Count_QNTY AS VARCHAR), '');
 
     -- First row for the recipient
     IF @Ln_DhldCur_Row_NUMB = 1
      BEGIN
       -- Resetting Values for the new recipient
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RESET REG_DISB NEW_RCPT';
       SET @Ls_SqlData_TEXT = '';

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_RESET
        @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT OUTPUT,
        @An_Disburse_QNTY         = @Ln_Disburse_QNTY OUTPUT,
        @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
        @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @Ab_RecpQueried_BIT       = @Lb_RecpQueried_BIT OUTPUT,
        @Ab_ChldQueried_BIT       = @Lb_ChldQueried_BIT OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ln_TotIrsFee_AMNT = 0;
       SET @Ln_TotDraFee_AMNT = 0;

       IF @Lc_CheckRecipient_ID = @Lc_CheckRecipientTreas999999983_ID
        BEGIN
         -- Generate New global event sequence when the check recipient changes
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ REG_DISB GF';
         SET @Ls_SqlData_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Escheated2280_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_Escheated2280_NUMB,
          @Ac_Process_ID              = @Lc_Job_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END;
       ELSE
        BEGIN
         -- Generate New global event sequence when the check recipient changes
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ REG_DISB';
         SET @Ls_SqlData_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Disbursement2245_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_Disbursement2245_NUMB,
          @Ac_Process_ID              = @Lc_Job_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END;

      /* --------------------------------------------------------------------------------
      OTHP Seq_IDNO's for In-state Agencies 
      OFFICE007 - DMA - Divsion of Medical Assistance - DECSS - 999999982
      OFFICE009 - IVE - DYFS - DECSS - 999999993
      OFFICE016, OFFICE036, OFFICE056...OFFICE416 - COUNTy TANF Agencies - DTA - DECSS - 999999994
      OFFICE008 - GENERAL FUND - DECSS - 999999983
      */
       --------------------------------------------------------------------------------
       --Start of Address Check:
       SET @Ls_Sql_TEXT = 'ADDRESS CHECK ';
       SET @Ls_SqlData_TEXT = '';

       IF @Lc_CheckRecipient_ID IN (@Lc_CheckRecipientOsr999999980_ID, @Lc_CheckRecipientCpnsffee_ID, @Lc_CheckRecipientNcpnsffee_ID)
        BEGIN
         SET @Lc_AddrEftChk_INDC = @Lc_Yes_INDC;
         SET @Lc_MediumDisburse_CODE = @Lc_DsbhMediumDisburseCheck_CODE;
        END;
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS REG_DISB';
         SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'') + ', CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL (@Lc_TypeDisburse_CODE, '');

         EXECUTE BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS
          @Ad_Batch_DATE            = @Ld_Batch_DATE,
          @An_Batch_NUMB            = @Ln_Batch_NUMB,
          @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE,
          @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,         
          @Ac_MediumDisburse_CODE   = @Lc_MediumDisburse_CODE OUTPUT,
          @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
          @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @Ac_CheckRecipient_CODE   = @Lc_CheckRecipient_CODE OUTPUT,
          @Ac_TypeDisburse_CODE     = @Lc_TypeDisburse_CODE OUTPUT,
          @Ac_CheckRecipient_ID     = @Lc_CheckRecipient_ID OUTPUT,
          @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
          @Ac_ReasonStatusOld_CODE  = @Lc_ReasonStatusOld_CODE OUTPUT,
          @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END;
      -- End of Address Check
      END;

     -- End of "First row for the recipient"
     -- If money is released from SNJT (disbursement hold), batch should not check again...
     -- IRS joint tax money will be on hold only when it comes to disbursement first time.
     -- IRS Joint Hold...
     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_TypeHold_CODE = @Lc_DhldTypeHoldD_CODE
        AND @Lc_DhldCur_SourceReceipt_CODE = @Lc_SourceReceiptSc_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_CHECK_IRS_HOLD REG_DISB ';
       SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburse_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', ChldCheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', Remaining_AMNT = ' + ISNULL(CAST(@Ln_Remaining_AMNT AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_CHECK_IRS_HOLD
        @Ad_Batch_DATE                 = @Ld_Batch_DATE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @Ad_Run_DATE                   = @Ld_Run_DATE,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE,
        @An_Case_IDNO                  = @Ln_Case_IDNO,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB,
        @Ac_ChldCheckRecipient_ID      = @Lc_CheckRecipient_ID,
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;

     SET @Ln_Fee_AMNT = 0;

     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_SourceReceipt_CODE = @Lc_SourceReceiptSc_CODE
        AND @Lc_CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY IRS REG_DISB ';
       SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeIrsfee_CODE, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburse_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', OffsetFeeIrs_AMNT = ' + ISNULL(CAST(@Ln_OffsetFeeIrs_AMNT AS VARCHAR), '') + ', OffsetEligIrs_AMNT = ' + ISNULL(CAST(@Ln_OffsetEligIrs_AMNT AS VARCHAR), '') + ', DraFee_AMNT = ' + ISNULL(CAST(@Ln_DraFee_AMNT AS VARCHAR), '') + ', DisbYtdEligDra_AMNT = ' + ISNULL(CAST(@Ln_DisbEligYtdDra_AMNT AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY
        @Ad_Batch_DATE                 = @Ld_Batch_DATE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE,
        @Ac_FeeType_CODE               = @Lc_FeeTypeIrsfee_CODE,
        @Ac_Job_ID                     = @Lc_Job_ID,
        @An_Case_IDNO                  = @Ln_Case_IDNO,
        @Ad_Run_DATE                   = @Ld_Run_DATE,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB,
        @An_OffsetFeeIrs_AMNT          = @Ln_OffsetFeeIrs_AMNT,
        @An_OffsetEligIrs_AMNT         = @Ln_OffsetEligIrs_AMNT,
        @An_DraFee_AMNT                = @Ln_DraFee_AMNT,
        @An_DisbYtdEligDra_AMNT        = @Ln_DisbEligYtdDra_AMNT,
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @An_Fee_AMNT                   = @Ln_Fee_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;

     SET @Ln_TotIrsFee_AMNT = @Ln_TotIrsFee_AMNT + @Ln_Fee_AMNT;
     SET @Ln_Fee_AMNT = 0;
     SET @Ln_OdOrigRcpt_AMNT = 0;

     IF @Ln_Remaining_AMNT > 0
      BEGIN
       SET @Lc_RecoupmentPayee_CODE = '';
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_GET_DTLS_FOR_ORIGINAL_RCPT';
       SET @Ls_SqlData_TEXT = 'BatchIn_DATE = ' + ISNULL(CAST(@Ld_Batch_DATE AS VARCHAR), '') + ', BatchIn_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', SourceBatchIn_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_GET_DTLS_FOR_ORIGINAL_RCPT
        @Ad_BatchIn_DATE          = @Ld_Batch_DATE,
        @An_BatchIn_NUMB          = @Ln_Batch_NUMB,
        @Ac_SourceBatchIn_CODE    = @Lc_SourceBatch_CODE,
        @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,
        @An_OdOrigRcpt_AMNT       = @Ln_OdOrigRcpt_AMNT OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @Ac_CheckRecipient_ID     = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_CheckRecipient_CODE   = @Lc_CheckRecipient_CODE OUTPUT,
        @Ac_TypeDisburse_CODE     = @Lc_TypeDisburse_CODE OUTPUT,
        @An_Case_IDNO             = @Ln_Case_IDNO OUTPUT,
        @Ad_Batch_DATE            = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB            = @Ln_Batch_NUMB OUTPUT,
        @Ac_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     IF @Ln_Remaining_AMNT > 0
        AND @Lc_CheckRecipient_CODE <> @Lc_RecipientTypeOthp_CODE
        AND @Lc_DhldCur_ProcessOffset_INDC = @Lc_Yes_INDC
        AND @Lc_DhldCur_SourceReceipt_CODE <> @Lc_SourceReceiptNr_CODE
      BEGIN
       IF @Ln_Remaining_AMNT - @Ln_OdOrigRcpt_AMNT > 0
        BEGIN
         SET @Ln_Remaining_AMNT = @Ln_Remaining_AMNT - @Ln_OdOrigRcpt_AMNT;
         SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RECOUP_PERCENT REG_DISB';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '');

         EXECUTE BATCH_FIN_DISBURSEMENT$SP_RECOUP_PERCENT
          @An_Disbursed_AMNT           = @Ln_Disbursed_AMNT OUTPUT,
          @An_Remaining_AMNT           = @Ln_Remaining_AMNT OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @Ab_RecpQueried_BIT          = @Lb_RecpQueried_BIT OUTPUT,
          @Ac_CheckRecipient_ID        = @Lc_CheckRecipient_ID OUTPUT,
          @Ac_CheckRecipient_CODE      = @Lc_CheckRecipient_CODE OUTPUT,
          @An_Case_IDNO                = @Ln_Case_IDNO OUTPUT,
          @An_DisbursementAllowed_NUMB = @Ln_DisbursementAllowed_NUMB OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         SET @Ln_Remaining_AMNT = @Ln_Remaining_AMNT + @Ln_OdOrigRcpt_AMNT;
         SET @Lb_RecpQueried_BIT = 1;
        END;
      END;

     -- Overpayment recovery process...
     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_ProcessOffset_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT NSF REG_DISB';
       SET @Ls_SqlData_TEXT = '';

       SELECT @Lc_RecoupmentType_CODE = CASE @Lc_DhldCur_SourceReceipt_CODE
                                         WHEN @Lc_SourceReceiptNr_CODE
                                          THEN @Lc_RecoupmentTypeNsf_CODE
                                         ELSE @Lc_Space_TEXT
                                        END

       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY REG_DISB';
       SET @Ls_SqlData_TEXT = 'TypeRecoupment_CODE = ' + ISNULL(@Lc_RecoupmentType_CODE, '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY
        @Ac_TypeRecoupment_CODE        = @Lc_RecoupmentType_CODE,
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @An_OdOrigRcpt_AMNT            = @Ln_OdOrigRcpt_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @Ac_PoflChkRecipient_ID        = @Lc_PoflCheckRecipient_ID OUTPUT,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_PoflChkRecipient_CODE      = @Lc_PoflCheckRecipient_CODE OUTPUT,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
        @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
        @An_StPendTotOffset_AMNT       = @Ln_StPendTotOffset_AMNT OUTPUT,
        @An_StAssessTotOverpay_AMNT    = @Ln_StAssessTotOverpay_AMNT OUTPUT,
        @An_StRecTotAdvance_AMNT       = @Ln_StRecTotAdvance_AMNT OUTPUT,
        @An_StRecTotOverpay_AMNT       = @Ln_StRecTotOverpay_AMNT OUTPUT,
        @An_StTotBalOvpy_AMNT          = @Ln_StTotBalOvpy_AMNT OUTPUT,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
        @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
        @Ad_Disburse_DATE              = @Ld_Run_DATE OUTPUT,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;

     SET @Ln_Remaining_AMNT = @Ln_Disbursed_AMNT + @Ln_Remaining_AMNT;
     SET @Ln_Disbursed_AMNT = 0;

     -- Check for any CP hold. Do not check CHLD, when the money has been currently released from CP Hold
     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_TypeHold_CODE != @Lc_DhldTypeHoldP_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD REG_DISB ';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST (@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (CAST (@Lc_CheckRecipient_CODE AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @Ab_ChldQueried_BIT            = @Lb_ChldQueried_BIT OUTPUT,
        @Ac_ChldChkRecipient_ID        = @Lc_ChldChkRecipient_ID OUTPUT,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_ChldChkRecipient_CODE      = @Lc_ChldChkRecipient_CODE OUTPUT,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
        @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
        @Ad_Expire_DATE                = @Ld_Expire_DATE OUTPUT,
        @Ac_Reason_CODE                = @Lc_Reason_CODE OUTPUT,
        @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
        @Ab_ChldExists_BIT             = @Lb_ChldExists_BIT OUTPUT,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE OUTPUT,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Lb_ChldQueried_BIT = 1;
      END

     -- The final step is to see if the check recipient has a valid address
     -- If not put the money on address hold
     IF @Ln_Remaining_AMNT > 0
        AND @Lc_AddrEftChk_INDC = @Lc_No_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD REG_DISB ';
       SET @Ls_SqlData_TEXT = 'CpDeceInstInca_CODE = ' + ISNULL(@Lc_CpDeceInstInca_CODE, '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @Ac_CpDeceInstInca_CODE        = @Lc_CpDeceInstInca_CODE,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
        @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
        @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE OUTPUT,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCf_CODE, @Lc_SourceReceiptCpRecoupment_CODE)
        AND @Lc_CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
        -- No need to recover DRA fee from VR Disbursement
        AND @Ld_Disburse_DATE = @Ld_Low_DATE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY DRA REG_DISB ';
       SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeDrafee_CODE, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburse_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', OffsetFeeIrs_AMNT = ' + ISNULL(CAST(@Ln_OffsetFeeIrs_AMNT AS VARCHAR), '') + ', OffsetEligIrs_AMNT = ' + ISNULL(CAST(@Ln_OffsetEligIrs_AMNT AS VARCHAR), '') + ', DraFee_AMNT = ' + ISNULL(CAST(@Ln_DraFee_AMNT AS VARCHAR), '') + ', DisbYtdEligDra_AMNT = ' + ISNULL(CAST(@Ln_DisbEligYtdDra_AMNT AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_FEE_RECOVERY
        @Ad_Batch_DATE                 = @Ld_Batch_DATE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE,
        @Ac_FeeType_CODE               = @Lc_FeeTypeDrafee_CODE,
        @Ac_Job_ID                     = @Lc_Job_ID,
        @An_Case_IDNO                  = @Ln_Case_IDNO,
        @Ad_Run_DATE                   = @Ld_Run_DATE,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB,
        @An_OffsetFeeIrs_AMNT          = @Ln_OffsetFeeIrs_AMNT,
        @An_OffsetEligIrs_AMNT         = @Ln_OffsetEligIrs_AMNT,
        @An_DraFee_AMNT                = @Ln_DraFee_AMNT,
        @An_DisbYtdEligDra_AMNT        = @Ln_DisbEligYtdDra_AMNT,
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @An_Fee_AMNT                   = @Ln_Fee_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;

     SET @Ln_TotDraFee_AMNT = @Ln_TotDraFee_AMNT + @Ln_Fee_AMNT;

     -- Remaining money should be disbursed. This record will be inserted into #Tlhld_P1.
     -- #Tlhld_P1 records are later grouped together to write into DSBH_Y1 and DSBL_Y1 when the recipient changes
     IF @Ln_Remaining_AMNT > 0
      BEGIN
       SET @Ln_TotDisburse_AMNT = @Ln_TotDisburse_AMNT + @Ln_Remaining_AMNT;
       SET @Ln_Disburse_QNTY = @Ln_Disburse_QNTY + 1;
       SET @Ls_Sql_TEXT = 'INSERT_TLHLD REG_DISB';
       SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', DisburseSubSeq_NUMB = ' + ISNULL(CAST(@Ln_Disburse_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburse_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@Ln_Remaining_AMNT AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '');
       INSERT #Tlhld_P1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               DisburseSubSeq_NUMB,
               Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               EventGlobalSupportSeq_NUMB,
               TypeDisburse_CODE,
               Transaction_AMNT,
               Disburse_DATE,
               DisburseSeq_NUMB,
               StatusEscheat_DATE,
               StatusEscheat_CODE)
       VALUES (@Lc_CheckRecipient_ID,--CheckRecipient_ID
               @Lc_CheckRecipient_CODE,--CheckRecipient_CODE
               @Ln_Disburse_QNTY,--DisburseSubSeq_NUMB
               @Ln_Case_IDNO,--Case_IDNO
               @Ln_OrderSeq_NUMB,--OrderSeq_NUMB
               @Ln_ObligationSeq_NUMB,--ObligationSeq_NUMB
               @Ld_Batch_DATE,--Batch_DATE
               @Lc_SourceBatch_CODE,--SourceBatch_CODE
               @Ln_Batch_NUMB,--Batch_NUMB
               @Ln_SeqReceipt_NUMB,--SeqReceipt_NUMB
               @Ln_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
               @Lc_TypeDisburse_CODE,--TypeDisburse_CODE
               @Ln_Remaining_AMNT,--Transaction_AMNT
               @Ld_Disburse_DATE,--Disburse_DATE
               @Ln_DisburseSeq_NUMB,--DisburseSeq_NUMB
               @Ld_High_DATE,--StatusEscheat_DATE
               @Lc_Space_TEXT --StatusEscheat_CODE
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_TLHLD REG_DISB FAILED';

         RAISERROR (50001,16,1);
        END;
      END;
	
     -- Regular disbursement records and re-issued records are be deleted from DHLD
     -- Check whether ReasonStatus_CODE is 'SR' if check hold record released from DHLD
     IF (@Lc_DhldCur_TypeHold_CODE = @Lc_DhldTypeHoldD_CODE
          OR (@Lc_DhldCur_TypeHold_CODE = @Lc_DhldTypeHoldC_CODE
              AND @Lc_DhldCur_ReasonStatus_CODE = @Lc_ReasonStatusSr_CODE))
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE_DHLD_Y1 REG_DISB';
       SET @Ls_SqlData_TEXT = 'Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '');

       DELETE DHLD_Y1
        WHERE Transaction_DATE = @Ld_DhldCur_Transaction_DATE
          AND Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND Unique_IDNO = @Ln_DhldCur_Unique_IDNO
          AND ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'DELETE_DHLD_Y1 REG_DISB FAILED';

         RAISERROR (50001,16,1);
        END;
      END;
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE_DHLD_Y1 REG_DISB';
       SET @Ls_SqlData_TEXT = 'Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '');

       UPDATE DHLD_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
         FROM DHLD_Y1 AS a
        WHERE a.Transaction_DATE = @Ld_DhldCur_Transaction_DATE
          AND a.Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND a.Unique_IDNO = @Ln_DhldCur_Unique_IDNO
          AND a.ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND a.OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE_DHLD_Y1 REG_DISB FAILED';

         RAISERROR (50001,16,1);
        END;
      END;

     --When reaching the last DHLD record for the recipient insert into DSBL/DSBH
     IF @Ln_DhldCur_Row_NUMB = @Ln_DhldCur_Count_QNTY
      BEGIN
       IF @Ln_TotDisburse_AMNT > 0
        BEGIN
         --Insert into DSBL and DSBH so that the money can be disbursed to the recipient
         SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH REG_DISB 1';
         SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', Disburse_QNTY = ' + ISNULL(CAST(@Ln_Disburse_QNTY AS VARCHAR), '') + ', MediumDisburse_CODE = ' + ISNULL(@Lc_MediumDisburse_CODE, '') + ', TotDisburse_AMNT = ' + ISNULL(CAST(@Ln_TotDisburse_AMNT AS VARCHAR), '');

         EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH
          @An_Case_IDNO             = @Ln_Case_IDNO,
          @Ac_CheckRecipient_ID     = @Lc_CheckRecipient_ID,
          @Ac_CheckRecipient_CODE   = @Lc_CheckRecipient_CODE,
          @Ac_MediumDisburse_CODE   = @Lc_MediumDisburse_CODE,
          @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
          @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END;

       IF @Ln_TotIrsFee_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH IRS FEE 1';
         SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL('0', '') + ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientTaxofffee_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE, '') + ', Disburse_QNTY = ' + ISNULL('0', '') + ', MediumDisburse_CODE = ' + ISNULL(@Lc_DsbhMediumDisburseCheck_CODE, '') + ', TotDisburse_AMNT = ' + ISNULL(CAST(@Ln_TotIrsFee_AMNT AS VARCHAR), '');

         EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH
          @An_Case_IDNO             = 0,
          @Ac_CheckRecipient_ID     = @Lc_CheckRecipientTaxofffee_ID,
          @Ac_CheckRecipient_CODE   = @Lc_RecipientTypeOthp_CODE,
          @Ac_MediumDisburse_CODE   = @Lc_DsbhMediumDisburseCheck_CODE,
          @An_TotDisburse_AMNT      = @Ln_TotIrsFee_AMNT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
          @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END

       IF @Ln_TotDraFee_AMNT > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH REG_DISB DRA';
         SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL('0','')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientCpdrafee_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', MediumDisburse_CODE = ' + ISNULL(@Lc_DsbhMediumDisburseCheck_CODE,'')+ ', TotDisburse_AMNT = ' + ISNULL(CAST( @Ln_TotDraFee_AMNT AS VARCHAR ),'');

         EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH
          @An_Case_IDNO             = 0,
          @Ac_CheckRecipient_ID     = @Lc_CheckRecipientCpdrafee_ID,
          @Ac_CheckRecipient_CODE   = @Lc_RecipientTypeOthp_CODE,
          @Ac_MediumDisburse_CODE   = @Lc_DsbhMediumDisburseCheck_CODE,
          @An_TotDisburse_AMNT      = @Ln_TotDraFee_AMNT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
          @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END;
       END;   
     END TRY
     BEGIN CATCH 
      IF XACT_STATE() = 1
        BEGIN
           ROLLBACK TRANSACTION SaveMainDisbTran;
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
	  SET @Ls_Sql_TEXT = 'Dhld_Cur-BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_RegCursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_RegCursorRecordCount_QNTY,
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

		 IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
		  BEGIN
		  SET @Ls_Sql_TEXT = 'Dhld_Cur-BATCH_COMMON$SP_CREATE_SDER_HOLD-SDER';
		  SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID  = ' + ISNULL(@Lc_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE,'') + ', Unique_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Unique_IDNO AS VARCHAR ),'');
		  EXECUTE BATCH_COMMON$SP_CREATE_SDER_HOLD
			@Ac_CheckRecipient_ID        = @Lc_CheckRecipient_ID,
			@Ac_CheckRecipient_CODE      = @Lc_CheckRecipient_CODE,
			@An_Unique_IDNO              = @Ln_DhldCur_Unique_IDNO,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

		  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		   BEGIN
			RAISERROR (50001,16,1);
		   END
		  END
      END CATCH

       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

       IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
          AND @Ln_CommitFreqParm_QNTY > 0
        BEGIN
         COMMIT TRANSACTION DisbTran;

         BEGIN TRANSACTION DisbTran;
		 SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;
         SET @Ln_CommitFreq_QNTY = 0;
        END;

	 SET @Ls_Sql_TEXT = 'Dhld_Cur-EXCEPTION THRESHOLD CHECK';
	 SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
	 IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
	  BEGIN
	   COMMIT TRANSACTION DisbTran;
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CRCursorRecordCount_QNTY + @Ln_RegCursorRecordCount_QNTY;
	   SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
	   RAISERROR (50001,16,1);
	  END

     FETCH NEXT FROM Dhld_Cur INTO @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Lc_DhldCur_TypeDisburse_CODE, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_Status_CODE, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Lc_DhldCur_ReasonStatusOld_CODE, @Lc_DhldCur_SourceReceipt_CODE, @Ln_DhldCur_Row_NUMB, @Ln_DhldCur_Count_QNTY;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Dhld_Cur;

   DEALLOCATE Dhld_Cur;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_RegCursorRecordCount_QNTY;
   --Start Refunds
   --Resetting Values for the new recipient
   SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RESET BEFORE REFND';
   SET @Ls_SqlData_TEXT = '';

   EXECUTE BATCH_FIN_DISBURSEMENT$SP_RESET
    @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT OUTPUT,
    @An_Disburse_QNTY         = @Ln_Disburse_QNTY OUTPUT,
    @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
    @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @Ab_RecpQueried_BIT       = @Lb_RecpQueried_BIT OUTPUT,
    @Ab_ChldQueried_BIT       = @Lb_ChldQueried_BIT OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Third cursor for Refund records
   SET @Ls_Sql_TEXT = 'REFND DISBURSEMENT '; 
   SET @Ls_SqlData_TEXT = '';

   DECLARE DhldRefund_Cur INSENSITIVE CURSOR FOR
    SELECT f.CheckRecipient_ID,
           f.CheckRecipient_CODE,
           f.Case_IDNO,
           f.OrderSeq_NUMB,
           f.ObligationSeq_NUMB,
           f.Batch_DATE,
           f.SourceBatch_CODE,
           f.Batch_NUMB,
           f.SeqReceipt_NUMB,
           f.TypeDisburse_CODE,
           f.Transaction_DATE,
           f.Transaction_AMNT,
           f.Status_CODE,
           f.TypeHold_CODE,
           f.ProcessOffset_INDC,
           f.ReasonStatus_CODE,
           f.EventGlobalSupportSeq_NUMB,
           f.Unique_IDNO,
           f.Disburse_DATE,
           f.DisburseSeq_NUMB,
           f.SourceReceipt_CODE,
           f.rn,
           f.Count_QNTY
      FROM (SELECT a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ObligationSeq_NUMB,
                   a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.TypeDisburse_CODE,
                   a.Transaction_DATE,
                   a.Transaction_AMNT,
                   a.Status_CODE,
                   a.TypeHold_CODE,
                   a.ProcessOffset_INDC,
                   a.ReasonStatus_CODE,
                   a.EventGlobalSupportSeq_NUMB,
                   a.Unique_IDNO,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB,
                   (SELECT TOP 1 SourceReceipt_CODE
                      FROM RCTH_Y1 z
                     WHERE a.Batch_DATE = z.Batch_DATE
                       AND a.Batch_NUMB = z.Batch_NUMB
                       AND a.SourceBatch_CODE = z.SourceBatch_CODE
                       AND a.SeqReceipt_NUMB = z.SeqReceipt_NUMB
                       AND z.EndValidity_DATE = @Ld_High_DATE
                   ) SourceReceipt_CODE,
                   ROW_NUMBER () OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Batch_DATE, a.Batch_NUMB, a.SourceBatch_CODE, a.SeqReceipt_NUMB, a.Disburse_DATE, a.DisburseSeq_NUMB ORDER BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Batch_DATE, a.Batch_NUMB, a.SourceBatch_CODE, a.SeqReceipt_NUMB, a.Disburse_DATE, a.DisburseSeq_NUMB, a.EventGlobalBeginSeq_NUMB) AS rn,
                   COUNT (1) OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.Batch_DATE, a.Batch_NUMB, a.SourceBatch_CODE, a.SeqReceipt_NUMB, a.Disburse_DATE, a.DisburseSeq_NUMB) AS Count_QNTY
              FROM DHLD_Y1 a
             WHERE a.Release_DATE <= @Ld_Run_DATE
               AND a.TypeDisburse_CODE IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
               AND a.Status_CODE = @Lc_StatusR_CODE
               AND a.EndValidity_DATE = @Ld_High_DATE) AS f
     ORDER BY f.CheckRecipient_ID,
              f.CheckRecipient_CODE,
              f.Batch_DATE,
              f.Batch_NUMB,
              f.SourceBatch_CODE,
              f.SeqReceipt_NUMB,
              f.Disburse_DATE,
              f.DisburseSeq_NUMB,
              f.rn,
              f.Count_QNTY;

   SET @Ls_Sql_TEXT = 'OPEN CURSOR DhldRefund_Cur';
   SET @Ls_SqlData_TEXT = '';

   OPEN DhldRefund_Cur;

   SET @Ls_Sql_TEXT = 'FETCH CURSOR DhldRefund_Cur 1';
   SET @Ls_SqlData_TEXT = '';

   FETCH NEXT FROM DhldRefund_Cur INTO @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Lc_DhldCur_TypeDisburse_CODE, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_Status_CODE, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Lc_DhldCur_SourceReceipt_CODE, @Ln_DhldCur_Row_NUMB, @Ln_DhldCur_Count_QNTY;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Refund record process
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SaveRefundDisbTran
     SET @Ln_Case_IDNO = @Ln_DhldCur_Case_IDNO;
     SET @Ln_OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;
     SET @Ln_ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB;
     SET @Ld_Batch_DATE = @Ld_DhldCur_Batch_DATE;
     SET @Ln_Batch_NUMB = @Ln_DhldCur_Batch_NUMB;
     SET @Ln_SeqReceipt_NUMB = @Ln_DhldCur_SeqReceipt_NUMB;
     SET @Lc_SourceBatch_CODE = @Lc_DhldCur_SourceBatch_CODE;
     SET @Lc_TypeDisburse_CODE = @Lc_DhldCur_TypeDisburse_CODE;
     SET @Lc_CheckRecipient_ID = @Lc_DhldCur_CheckRecipient_ID;
     SET @Lc_CheckRecipient_CODE = @Lc_DhldCur_CheckRecipient_CODE;
     SET @Ln_EventGlobalSupportSeq_NUMB = @Ln_DhldCur_EventGlobalSupportSeq_NUMB;
     SET @Ld_Disburse_DATE = @Ld_DhldCur_Disburse_DATE;
     SET @Ln_DisburseSeq_NUMB = @Ln_DhldCur_DisburseSeq_NUMB;
     SET @Lc_ReasonStatusNew_CODE = @Lc_DhldCur_ReasonStatus_CODE;
     SET @Lc_ReasonStatusOld_CODE = @Lc_Space_TEXT;
     SET @Ln_RefundCursorRecordCount_QNTY = @Ln_RefundCursorRecordCount_QNTY + 1;
     SET @Ln_Remaining_AMNT = @Ln_DhldCur_Transaction_AMNT;
     SET @Lc_SourceReceipt_CODE = @Lc_DhldCur_SourceReceipt_CODE;
     SET @Ls_CursorLocation_TEXT = 'DhldRefund_Cur-Count = ' + ISNULL (CAST (@Ln_RefundCursorRecordCount_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '') + ', Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL (CAST (@Ln_DhldCur_Unique_IDNO AS VARCHAR), '');

     IF @Ln_DhldCur_Row_NUMB = 1 --First row for the recipient
      BEGIN
       --Resetting Values for the new recipient
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_RESET REFND';
       SET @Ls_SqlData_TEXT = '';

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_RESET
        @An_TotDisburse_AMNT      = @Ln_TotDisburse_AMNT OUTPUT,
        @An_Disburse_QNTY         = @Ln_Disburse_QNTY OUTPUT,
        @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
        @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @Ab_RecpQueried_BIT       = @Lb_RecpQueried_BIT OUTPUT,
        @Ab_ChldQueried_BIT       = @Lb_ChldQueried_BIT OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       -- Generate New global event sequence when the check recipient changes
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ REFUND';
       SET @Ls_SqlData_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Disbursement2245_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Li_Disbursement2245_NUMB,
        @Ac_Process_ID              = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
        @Ac_Note_INDC               = @Lc_No_INDC,
        @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       --Start of Address Check
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS REFND';
       SET @Ls_SqlData_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'') + ', CheckRecipient_ID = ' + ISNULL (@Lc_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL (@Lc_TypeDisburse_CODE, '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_CHECK_ADDRESS
        @Ad_Batch_DATE            = @Ld_Batch_DATE,
        @An_Batch_NUMB            = @Ln_Batch_NUMB,
        @Ac_SourceBatch_CODE      = @Lc_SourceBatch_CODE,
        @An_SeqReceipt_NUMB       = @Ln_SeqReceipt_NUMB,
        @Ac_MediumDisburse_CODE   = @Lc_MediumDisburse_CODE OUTPUT,
        @Ac_CdEftChk_INDC         = @Lc_AddrEftChk_INDC OUTPUT,
        @Ac_CpDeceInstInca_CODE   = @Lc_CpDeceInstInca_CODE OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @Ac_CheckRecipient_CODE   = @Lc_CheckRecipient_CODE OUTPUT,
        @Ac_TypeDisburse_CODE     = @Lc_TypeDisburse_CODE OUTPUT,
        @Ac_CheckRecipient_ID     = @Lc_CheckRecipient_ID OUTPUT,
        @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
        @Ac_ReasonStatusOld_CODE  = @Lc_ReasonStatusOld_CODE OUTPUT,
        @Ac_SourceReceipt_CODE    = @Lc_SourceReceipt_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      -- End of Address Check
      END 
     SET @Ln_OdOrigRcpt_AMNT = 0;

     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_ProcessOffset_INDC = @Lc_Yes_INDC
        AND @Lc_TypeDisburse_CODE = @Lc_TypeDisburseRefnd_CODE
      --Recoupment will occur for NCP and Agency refunds
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY REFND';
       SET @Ls_Sqldata_TEXT = 'TypeRecoupment_CODE = ' + ISNULL(@Lc_Space_TEXT,'') + ', Batch_DATE = ' + ISNULL (CAST (@Ld_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Lc_SourceBatch_CODE, '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_OVPY_RECOVERY
        @Ac_TypeRecoupment_CODE        = @Lc_Space_TEXT,
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @An_OdOrigRcpt_AMNT            = @Ln_OdOrigRcpt_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @Ac_PoflChkRecipient_ID        = @Lc_PoflCheckRecipient_ID OUTPUT,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_PoflChkRecipient_CODE      = @Lc_PoflCheckRecipient_CODE OUTPUT,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
        @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
        @An_StPendTotOffset_AMNT       = @Ln_StPendTotOffset_AMNT OUTPUT,
        @An_StAssessTotOverpay_AMNT    = @Ln_StAssessTotOverpay_AMNT OUTPUT,
        @An_StRecTotAdvance_AMNT       = @Ln_StRecTotAdvance_AMNT OUTPUT,
        @An_StRecTotOverpay_AMNT       = @Ln_StRecTotOverpay_AMNT OUTPUT,
        @An_StTotBalOvpy_AMNT          = @Ln_StTotBalOvpy_AMNT OUTPUT,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
        @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE OUTPUT,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;

     SET @Ln_Remaining_AMNT = @Ln_Disbursed_AMNT + @Ln_Remaining_AMNT;
     SET @Ln_Disbursed_AMNT = 0;

     -- Check for any CP hold. Do not check CHLD, when the money has been currently released from CP Hold
     IF @Ln_Remaining_AMNT > 0
        AND @Lc_DhldCur_TypeHold_CODE != @Lc_DhldTypeHoldP_CODE
        AND @Lc_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD REFND';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST (@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (CAST (@Lc_CheckRecipient_CODE AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '');

       EXECUTE BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @Ab_ChldQueried_BIT            = @Lb_ChldQueried_BIT OUTPUT,
        @Ac_ChldChkRecipient_ID        = @Lc_ChldChkRecipient_ID OUTPUT,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_ChldChkRecipient_CODE      = @Lc_ChldChkRecipient_CODE OUTPUT,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
        @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
        @Ad_Expire_DATE                = @Ld_Expire_DATE OUTPUT,
        @Ac_Reason_CODE                = @Lc_Reason_CODE OUTPUT,
        @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
        @Ab_ChldExists_BIT             = @Lb_ChldExists_BIT OUTPUT,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE OUTPUT,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Lb_ChldQueried_BIT = 1;
      END;

     -- The final step is to see if the check recipient has a valid address
     -- If not put the money on address hold
     IF @Ln_Remaining_AMNT > 0
        AND @Lc_AddrEftChk_INDC = @Lc_No_INDC
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD REFND';
       SET @Ls_Sqldata_TEXT = 'CpDeceInstInca_CODE = ' + ISNULL(@Lc_CpDeceInstInca_CODE,'') + ', Case_IDNO = ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST (@Lc_CheckRecipient_ID AS VARCHAR), '') + ' CheckRecipient_CODE = ' + +ISNULL (CAST (@Lc_CheckRecipient_CODE AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL (CAST (@Ln_ObligationSeq_NUMB AS VARCHAR), '');
       EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_ADHOLD
        @An_Remaining_AMNT             = @Ln_Remaining_AMNT OUTPUT,
        @Ac_CpDeceInstInca_CODE        = @Lc_CpDeceInstInca_CODE,
        @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
        @Ac_CheckRecipient_ID          = @Lc_CheckRecipient_ID OUTPUT,
        @Ac_CheckRecipient_CODE        = @Lc_CheckRecipient_CODE OUTPUT,
        @An_Case_IDNO                  = @Ln_Case_IDNO OUTPUT,
        @An_OrderSeq_NUMB              = @Ln_OrderSeq_NUMB OUTPUT,
        @An_ObligationSeq_NUMB         = @Ln_ObligationSeq_NUMB OUTPUT,
        @Ad_Batch_DATE                 = @Ld_Batch_DATE OUTPUT,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE OUTPUT,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB OUTPUT,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB OUTPUT,
        @An_EventGlobalSupportSeq_NUMB = @Ln_EventGlobalSupportSeq_NUMB OUTPUT,
        @Ac_TypeDisburse_CODE          = @Lc_TypeDisburse_CODE OUTPUT,
        @Ad_Run_DATE                   = @Ld_Run_DATE OUTPUT,
        @An_EventGlobalSeq_NUMB        = @Ln_EventGlobalSeq_NUMB OUTPUT,
        @Ad_Disburse_DATE              = @Ld_Disburse_DATE OUTPUT,
        @An_DisburseSeq_NUMB           = @Ln_DisburseSeq_NUMB OUTPUT,
        @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END;

     -- Remaining money should be disbursed. This record will be inserted into #Tlhld_P1.
     -- #Tlhld_P1 records are later grouped together to write into DSBH_Y1 and DSBL_Y1 when the recipient changes
     IF @Ln_Remaining_AMNT > 0
      BEGIN
       SET @Ln_TotDisburse_AMNT = @Ln_TotDisburse_AMNT + @Ln_Remaining_AMNT;
       SET @Ln_Disburse_QNTY = @Ln_Disburse_QNTY + 1;
       SET @Ls_Sql_TEXT = 'INSERT_TLHLD REFND';
       SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', DisburseSubSeq_NUMB = ' + ISNULL(CAST(@Ln_Disburse_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ld_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburse_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@Ln_Remaining_AMNT AS VARCHAR), '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

       INSERT #Tlhld_P1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               DisburseSubSeq_NUMB,
               Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               EventGlobalSupportSeq_NUMB,
               TypeDisburse_CODE,
               Transaction_AMNT,
               Disburse_DATE,
               DisburseSeq_NUMB,
               StatusEscheat_DATE,
               StatusEscheat_CODE)
       VALUES (@Lc_CheckRecipient_ID,--CheckRecipient_ID
               @Lc_CheckRecipient_CODE,--CheckRecipient_CODE
               @Ln_Disburse_QNTY,--DisburseSubSeq_NUMB
               @Ln_Case_IDNO,--Case_IDNO
               @Ln_OrderSeq_NUMB,--OrderSeq_NUMB
               @Ln_ObligationSeq_NUMB,--ObligationSeq_NUMB
               @Ld_Batch_DATE,--Batch_DATE
               @Lc_SourceBatch_CODE,--SourceBatch_CODE
               @Ln_Batch_NUMB,--Batch_NUMB
               @Ln_SeqReceipt_NUMB,--SeqReceipt_NUMB
               @Ln_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
               @Lc_TypeDisburse_CODE,--TypeDisburse_CODE
               @Ln_Remaining_AMNT,--Transaction_AMNT
               @Ld_Disburse_DATE,--Disburse_DATE
               @Ln_DisburseSeq_NUMB,--DisburseSeq_NUMB
               @Ld_High_DATE,--StatusEscheat_DATE
               @Lc_Space_TEXT --StatusEscheat_CODE
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_TLHLD REFND FAILED';

         RAISERROR (50001,16,1);
        END;
      END;

     --DSBV re-issue records should also be deleted from DHLD along with the regular
     -- Check whether ReasonStatus_CODE is 'or 'SR' if check hold record released from DHLD
     IF (@Lc_DhldCur_TypeHold_CODE = @Lc_DhldTypeHoldD_CODE
          OR (@Lc_DhldCur_TypeHold_CODE = @Lc_DhldTypeHoldC_CODE
              AND @Lc_DhldCur_ReasonStatus_CODE = @Lc_ReasonStatusSr_CODE))
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE_DHLD_Y1 REFND';
       SET @Ls_SqlData_TEXT = 'Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '');

       DELETE DHLD_Y1
        WHERE Transaction_DATE = @Ld_DhldCur_Transaction_DATE
          AND Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND Unique_IDNO = @Ln_DhldCur_Unique_IDNO
          AND ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'DELETE_DHLD_Y1 REFND FAILED';

         RAISERROR (50001,16,1);
        END;
      END;
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE_DHLD_Y1 REFND';
       SET @Ls_SqlData_TEXT = 'Transaction_DATE = ' + ISNULL(CAST(@Ld_DhldCur_Transaction_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', Unique_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '');

       UPDATE DHLD_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
         FROM DHLD_Y1 AS a
        WHERE a.Transaction_DATE = @Ld_DhldCur_Transaction_DATE
          AND a.Case_IDNO = @Ln_DhldCur_Case_IDNO
          AND a.Unique_IDNO = @Ln_DhldCur_Unique_IDNO
          AND a.ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
          AND a.OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE_DHLD_Y1 REFND FAILED';

         RAISERROR (50001,16,1);
        END;
      END;

     --When reaching the last DHLD record for the recipient insert into DSBL/DSBH
     IF @Ln_DhldCur_Row_NUMB = @Ln_DhldCur_Count_QNTY
      BEGIN
       IF @Ln_TotDisburse_AMNT > 0
        BEGIN
         --Insert into DSBL and DSBH so that the money can be disbursed to the recipient.
         --Diff for Refnd. Not to include $1 hold
         SET @Ls_Sql_TEXT = 'BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH_REFND REFND';
         SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE, '') + ', MediumDisburse_CODE = ' + ISNULL(@Lc_MediumDisburse_CODE, '') + ', Disburse_AMNT = ' + ISNULL(CAST(@Ln_TotDisburse_AMNT AS VARCHAR), '');

         EXECUTE BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH_REFND
          @Ac_CheckRecipient_ID     = @Lc_CheckRecipient_ID,
          @Ac_CheckRecipient_CODE   = @Lc_CheckRecipient_CODE,
          @Ac_MediumDisburse_CODE   = @Lc_MediumDisburse_CODE,
          @An_Disburse_AMNT         = @Ln_TotDisburse_AMNT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @Ad_Run_DATE              = @Ld_Run_DATE OUTPUT,
          @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END
        END;
      END TRY 
      BEGIN CATCH
      IF XACT_STATE() = 1
        BEGIN
           ROLLBACK TRANSACTION SaveRefundDisbTran;
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
	  SET @Ls_Sql_TEXT = 'DhldRefund_Cur-BATCH_COMMON$SP_BATE_LOG-Exception';
	  SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST(@Ln_RefundCursorRecordCount_QNTY AS VARCHAR),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_RefundCursorRecordCount_QNTY,
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

		 IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
		  BEGIN
		  SET @Ls_Sql_TEXT = 'DhldRefund_Cur-BATCH_COMMON$SP_CREATE_SDER_HOLD-SDER';
		  SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID  = ' + ISNULL(@Lc_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipient_CODE,'') + ', Unique_IDNO = ' + ISNULL(CAST( @Ln_DhldCur_Unique_IDNO AS VARCHAR ),'');

		  EXECUTE BATCH_COMMON$SP_CREATE_SDER_HOLD
			@Ac_CheckRecipient_ID        = @Lc_CheckRecipient_ID,
			@Ac_CheckRecipient_CODE      = @Lc_CheckRecipient_CODE,
			@An_Unique_IDNO              = @Ln_DhldCur_Unique_IDNO,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;
			
		  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		   BEGIN
			RAISERROR (50001,16,1);
		   END
		  END      
      
      END CATCH
      
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

       IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
          AND @Ln_CommitFreqParm_QNTY > 0
        BEGIN
         COMMIT TRANSACTION DisbTran;

         BEGIN TRANSACTION DisbTran;

         SET @Ln_CommitFreq_QNTY = 0;
        END;
      
     SET @Ls_Sql_TEXT = 'DhldRefund_Cur-EXCEPTION THRESHOLD CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION DisbTran;
       SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_CRCursorRecordCount_QNTY + @Ln_RegCursorRecordCount_QNTY + @Ln_RefundCursorRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END
      
     --When the recipient changes
     SET @Ls_Sql_TEXT = 'FETCH CURSOR DhldRefund_Cur 2';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM DhldRefund_Cur INTO @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Lc_DhldCur_TypeDisburse_CODE, @Ld_DhldCur_Transaction_DATE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_Status_CODE, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB, @Lc_DhldCur_SourceReceipt_CODE, @Ln_DhldCur_Row_NUMB, @Ln_DhldCur_Count_QNTY;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   --End Refunds
   CLOSE DhldRefund_Cur;

   DEALLOCATE DhldRefund_Cur;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_RefundCursorRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'RECORDS_PROCESSED';
   SET @Ls_SqlData_TEXT = '';

   IF @Ln_CRCursorRecordCount_QNTY + @Ln_RegCursorRecordCount_QNTY + @Ln_RefundCursorRecordCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_NoRecordsProcessed_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Bulk Insert into ESEM_Y1
   SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT ESEM_Y1
          (TypeEntity_CODE,
           EventGlobalSeq_NUMB,
           EventFunctionalSeq_NUMB,
           Entity_ID)
   SELECT DISTINCT
          a.TypeEntity_CODE,
          a.EventGlobalSeq_NUMB,
          a.EventFunctionalSeq_NUMB,
          a.Entity_ID
     FROM PESEM_Y1 a
     WHERE NOT EXISTS (SELECT 1 FROM ESEM_Y1 b WHERE a.TypeEntity_CODE = b.TypeEntity_CODE AND a.EventGlobalSeq_NUMB = b.EventGlobalSeq_NUMB AND a.EventFunctionalSeq_NUMB = b.EventFunctionalSeq_NUMB AND a.Entity_ID = b.Entity_ID)
    ORDER BY a.EventGlobalSeq_NUMB,
             a.EventFunctionalSeq_NUMB,
             a.TypeEntity_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_ESEM_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   --ESEM Insert End
   SET @Ls_Sql_TEXT = 'DELETE_RSTL_Y1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE RSTL_Y1
    WHERE Job_ID = @Lc_Job_ID;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'DELETE_RSTL_Y1 FAILED';

     RAISERROR (50001,16,1);
    END

   -- PARM table Update
   SET @Ls_Sql_TEXT = 'UPDATE_PARM_Y1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_CursorLocation_TEXT = 'REG DISB = ' + ISNULL (CAST (@Ln_RegCursorRecordCount_QNTY AS VARCHAR), '0') + ', REFND DISB = ' + ISNULL (CAST (@Ln_RefundCursorRecordCount_QNTY AS VARCHAR), '0') +  ', CR DISB = ' + ISNULL (CAST (@Ln_CRCursorRecordCount_QNTY AS VARCHAR), '0');

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION DisbTran;
  END TRY
  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DisbTran;
    END

   IF CURSOR_STATUS ('LOCAL', 'DhldCPRecoup_CUR') IN (0, 1)
    BEGIN
     CLOSE DhldCPRecoup_CUR;

     DEALLOCATE DhldCPRecoup_CUR;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Dhld_Cur') IN (0, 1)
    BEGIN
     CLOSE Dhld_Cur;

     DEALLOCATE Dhld_Cur;
    END;

   IF CURSOR_STATUS ('LOCAL', 'DhldRefund_Cur') IN (0, 1)
    BEGIN
     CLOSE DhldRefund_Cur;

     DEALLOCATE DhldRefund_Cur;
    END;

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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
