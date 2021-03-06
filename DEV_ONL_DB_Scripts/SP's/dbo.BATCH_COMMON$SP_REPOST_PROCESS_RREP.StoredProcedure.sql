/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_REPOST_PROCESS_RREP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------------------------------------------------------
 Procedure Name   : BATCH_COMMON$SP_REPOST_PROCESS_RREP
 Programmer Name  : IMP Team
 Description      : Procedure is used to process the repost receipt
 Frequency        :
 Developed On     :	04/12/2011
 Called By        :
 Called On        :
---------------------------------------------------------------------------------------------------------
 Modified By      :
 Modified On      :
 Version No       :  
---------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_REPOST_PROCESS_RREP] (
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @An_Receipt_AMNT               NUMERIC(11, 2),
 @Ac_Sval_INDC                  CHAR(1),
 @Ac_Refund_INDC                CHAR(1),
 @An_Refund_AMNT                NUMERIC(11, 2),
 @An_CasePayorMCIReposted_IDNO  NUMERIC(10),
 @An_RepostedPayorMci_IDNO      NUMERIC(10),
 @Ac_ReasonBackOut_CODE         CHAR(2),
 @Ac_Process_ID                 CHAR(10),
 @Ac_SignedOnWorker_ID          CHAR(30),
 @Ad_Process_DATE               DATE,
 @An_EventGlobalBackOutSeq_NUMB NUMERIC(19),
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19, 0),
 --Bug 13447 : CR0384 -- Added parameter @Ac_NcpRefundRecoverReceipt_INDC for not to check receipt on hold procedure when value is 'Y'  - START
 @Ac_NcpRefundRecoverReceipt_INDC CHAR(1) ='N',
 --Bug 13447 : CR0384 -- Added parameter @Ac_NcpRefundRecoverReceipt_INDC for not to check receipt on hold procedure when value is 'Y'  - End
 @An_EventGlobalRefundSeq_NUMB  NUMERIC(19) OUTPUT,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Li_Refund1220_NUMB                 INT = 1220,
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_StatusBatchUnReconciled_CODE    CHAR(1) = 'U',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_StatusReceiptIdentified_CODE    CHAR(1) = 'I',
           @Lc_StatusReceiptUnidentified_CODE  CHAR(1) = 'U',
           @Lc_StatusConChkFail_CODE           CHAR(1) = 'L',
           @Lc_StringZero_TEXT                 CHAR(1) = '0',
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_TypePostingPayor_CODE           CHAR(1) = 'P',
           @Lc_CaseRelationshipCp_CODE         CHAR(1) = 'C',
           @Lc_CaseRelationshipNcp_CODE        CHAR(1) = 'A',
           @Lc_CaseRelationshipPutFather_CODE  CHAR(1) = 'P',
           @Lc_StatusReceiptRefunded_CODE      CHAR(1) = 'R',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusR_CODE                    CHAR(1) = 'R',
           @Lc_TypeHoldD_CODE                  CHAR(1) = 'D',
           @Lc_StatusC_CODE                    CHAR(1) = 'C',
           @Lc_StatusMatchM_CODE               CHAR(1) = 'M',
           @Lc_StatusCheckCashed_CODE          CHAR(2) = 'CA',
           @Lc_StatusCheckOu_CODE              CHAR(2) = 'OU',
           @Lc_StatusCheckTr_CODE              CHAR(2) = 'TR',
           @Lc_StatusCheckPs_CODE              CHAR(2) = 'PS',
           @Lc_SourceReceiptCpFeePayment_CODE  CHAR(2) = 'CF',
           @Lc_SourceReceiptCpRecoupment_CODE  CHAR(2) = 'CR',
           @Lc_Value001_TEXT                   CHAR(3) = '001',
           @Lc_Case_TEXT                       CHAR(4) = 'CASE',
           @Lc_TypeDisburseRefund_CODE         CHAR(5) = 'REFND',
           @Lc_TypeEntityRctno_CODE            CHAR(30) = 'RCTNO',
           @Ls_Routine_TEXT                    VARCHAR(60) = 'BATCH_COMMON$SP_REPOST_PROCESS_RREP',
           @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE  @Ln_RowCount_QNTY              NUMERIC(6),
           @Ln_FetchStatus_QNTY           NUMERIC(6),
           @Ln_Batch_NUMB                 NUMERIC(6),
           @Ln_NewSeqReceipt_NUMB         NUMERIC(6),
           @Ln_DhldCase_IDNO              NUMERIC(6),
           @Ln_Employer_IDNO              NUMERIC(9),
           @Ln_PayorOrig_IDNO             NUMERIC(10),
           @Ln_RepostedPayorMci_IDNO      NUMERIC(10),
           @Ln_Fee_AMNT                   NUMERIC(11,2),
           @Ln_ErrorLine_NUMB             NUMERIC(11),
           @Ln_Temp_NUMB                  NUMERIC(11,2),
           @Ln_ReferenceIrs_IDNO          NUMERIC(15),
           @Ln_EventGlobalRefundSeq_NUMB  NUMERIC(19),
           @Li_Error_NUMB                 INT,
           @Lc_TypePosting_CODE           CHAR(1),
           @Lc_StatusReceipt_CODE         CHAR(1),
           @Lc_TaxJoint_CODE              CHAR(1),
           @Lc_Tanf_CODE                  CHAR(1),
           @Lc_RefundRecipient_CODE       CHAR(1),
           @Lc_SourceReceipt_CODE         CHAR(2),
           @Lc_TypeRemittance_CODE        CHAR(3),
           @Lc_Fips_CODE                  CHAR(7),
           @Lc_RefundRecipient_ID         CHAR(10),
           @Lc_CheckNo_TEXT               CHAR(19),
           @Lc_Worker_ID                  CHAR(30),
           @Lc_Receipt_TEXT               CHAR(30),
           @Lc_TaxJoint_NAME              CHAR(35),
           @Ls_Sql_TEXT                   VARCHAR(100),
           @Ls_Sqldata_TEXT               VARCHAR(500),
           @Ls_ErrorMessage_TEXT          VARCHAR(4000),
           @Ld_Receipt_DATE               DATE,
           @Ld_Check_DATE                 DATE,
           @Ld_Refund_DATE                DATE,
           @Ld_Process_DATE               DATE;

  DECLARE @Ln_CaseCur_Case_IDNO NUMERIC(6);
  DECLARE @Ln_DisburseCur_Disburse_AMNT       NUMERIC(11, 2),
		  @Lc_DisburseCur_CheckRecipient_ID   CHAR(10),
		  @Lc_DisburseCur_CheckRecipient_CODE CHAR(1);
  BEGIN TRY
   SET @An_EventGlobalRefundSeq_NUMB = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Worker_ID = @Ac_SignedOnWorker_ID;
   SET @Ld_Process_DATE = ISNULL(@Ad_Process_DATE, CONVERT(VARCHAR(10), dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101));
   
   SET @Ls_Sql_TEXT = 'SELECT_VRCTH - 1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBackOutSeq_NUMB AS VARCHAR ),'');

   SELECT TOP 1 @Ln_PayorOrig_IDNO = ss.PayorMCI_IDNO,
                @Ld_Receipt_DATE = ss.Receipt_DATE,
                @Lc_TypeRemittance_CODE = ss.TypeRemittance_CODE,
                @Ln_Employer_IDNO = ss.Employer_IDNO,
                @Lc_Fips_CODE = ss.Fips_CODE,
                @Lc_CheckNo_Text = ss.CheckNo_Text,
                @Ld_Check_DATE = ss.Check_DATE,
                @Lc_TaxJoint_CODE = ss.TaxJoint_CODE,
                @Lc_Tanf_CODE = ss.Tanf_CODE,
                @Lc_TaxJoint_NAME = ss.TaxJoint_NAME,
                @Lc_SourceReceipt_CODE = ss.SourceReceipt_CODE,
                @Ld_Refund_DATE = ss.Refund_DATE,
                @Ln_ReferenceIrs_IDNO = ss.ReferenceIrs_IDNO,
                @Lc_RefundRecipient_CODE = ss.RefundRecipient_CODE,
                @Lc_RefundRecipient_ID = ss.RefundRecipient_ID,
                @Ln_Fee_AMNT = ss.Fee_AMNT
     FROM RCTH_Y1 ss
    WHERE ss.Batch_DATE = @Ad_Batch_DATE
      AND ss.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND ss.Batch_NUMB = @An_Batch_NUMB
      AND ss.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND ss.EventGlobalBeginSeq_NUMB = @An_EventGlobalBackOutSeq_NUMB;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO B/O REC IN RCTH_Y1 ' + ISNULL(CONVERT(VARCHAR(10), @Ad_Batch_DATE, 101), '') + ISNULL(@Ac_SourceBatch_CODE, '') + ISNULL(CAST(@An_Batch_NUMB AS NVARCHAR(4)), '') + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT Seq_IDNO BATCH';
   SET @Ls_Sqldata_TEXT = ' ';

   EXECUTE BATCH_COMMON$SP_GET_BATCH_NUMB_SEQ_CBAT 
	@An_Batch_NUMB = @Ln_Batch_NUMB OUTPUT,
	@Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
	@As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

	IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
	BEGIN
		RAISERROR(50001,16,1);
	END
   SET @Ls_Sql_TEXT = 'INSERT_VRBAT1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ControlReceipt_AMNT = ' + ISNULL(CAST( @An_Receipt_AMNT AS VARCHAR ),'')+ ', ActualReceipt_AMNT = ' + ISNULL(CAST( @An_Receipt_AMNT AS VARCHAR ),'')+ ', StatusBatch_CODE = ' + ISNULL(@Lc_StatusBatchUnReconciled_CODE,'')+ ', RePost_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

   INSERT RBAT_Y1
          (Batch_DATE,
           Batch_NUMB,
           SourceBatch_CODE,
           SourceReceipt_CODE,
           Receipt_DATE,
           TypeRemittance_CODE,
           CtControlReceipt_QNTY,
           CtActualReceipt_QNTY,
           CtControlTrans_QNTY,
           CtActualTrans_QNTY,
           ControlReceipt_AMNT,
           ActualReceipt_AMNT,
           StatusBatch_CODE,
           RePost_INDC,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB)
   VALUES ( @Ld_Process_DATE,--Batch_DATE
            @Ln_Batch_NUMB,--Batch_NUMB
            @Ac_SourceBatch_CODE,--SourceBatch_CODE
            @Lc_SourceReceipt_CODE,--SourceReceipt_CODE
            @Ld_Process_DATE,--Receipt_DATE
            @Lc_Space_TEXT,--TypeRemittance_CODE
            1,--CtControlReceipt_QNTY
            1,--CtActualReceipt_QNTY
            1,--CtControlTrans_QNTY
            1,--CtActualTrans_QNTY
            @An_Receipt_AMNT,--ControlReceipt_AMNT
            @An_Receipt_AMNT,--ActualReceipt_AMNT
            @Lc_StatusBatchUnReconciled_CODE,--StatusBatch_CODE
            @Lc_Yes_INDC,--RePost_INDC
            @Ld_Process_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0); --EventGlobalEndSeq_NUMB

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT INTO RBAT1 FAILED';

     RAISERROR(50001,16,1);
    END

   IF (@An_CasePayorMCIReposted_IDNO IS NOT NULL
       AND @An_CasePayorMCIReposted_IDNO > 0)
    BEGIN
     SET @Lc_TypePosting_CODE = dbo.BATCH_COMMON_GETS$SF_GET_POSTING_TYPE(@Lc_SourceReceipt_CODE);
     SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_TypePosting_CODE = @Lc_Space_TEXT;
     SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
    END

   IF (@An_Receipt_AMNT - @An_Refund_AMNT) > 0
    BEGIN
     SET @Ln_Temp_NUMB = (@An_Receipt_AMNT - @An_Refund_AMNT);
     SET @Ls_Sql_TEXT = 'SPKG_PROCESS_RECEIPT$SP_INSERT_RECEIPT ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', CasePayorMCI_IDNO = ' + ISNULL(CAST( @An_CasePayorMCIReposted_IDNO AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceipt_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_Temp_NUMB AS VARCHAR ),'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_TypeRemittance_CODE,'')+ ', Employer_IDNO = ' + ISNULL(CAST( @Ln_Employer_IDNO AS VARCHAR ),'')+ ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE,'')+ ', Check_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', CheckNo_TEXT = ' + ISNULL(@Lc_CheckNo_TEXT,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_TaxJoint_CODE,'')+ ', Tanf_CODE = ' + ISNULL(@Lc_Tanf_CODE,'')+ ', TaxJoint_NAME = ' + ISNULL(@Lc_TaxJoint_NAME,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'')+ ', Fee_AMNT = ' + ISNULL(CAST( @Ln_Fee_AMNT AS VARCHAR ),'')+ ', Screen_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');

     EXECUTE BATCH_COMMON$SP_INSERT_RECEIPT
      @Ad_Batch_DATE               = @Ld_Process_DATE,
      @Ac_SourceBatch_CODE         = @Ac_SourceBatch_CODE,
      @An_Batch_NUMB               = @Ln_Batch_NUMB,
      @Ac_TypePosting_CODE         = @Lc_TypePosting_CODE,
      @An_CasePayorMCI_IDNO        = @An_CasePayorMCIReposted_IDNO,
      @Ac_SourceReceipt_CODE       = @Lc_SourceReceipt_CODE,
      @Ac_StatusReceipt_CODE       = @Lc_StatusReceipt_CODE,
      @Ac_ReasonStatus_CODE        = @Lc_Space_TEXT,
      @Ad_Receipt_DATE             = @Ld_Receipt_DATE,
      @An_Receipt_AMNT             = @Ln_Temp_NUMB,
      @Ac_TypeRemittance_CODE      = @Lc_TypeRemittance_CODE,
      @An_Employer_IDNO            = @Ln_Employer_IDNO,
      @Ac_Fips_CODE                = @Lc_Fips_CODE,
      @Ad_Check_DATE               = @Ld_Process_DATE,
      @Ac_CheckNo_TEXT             = @Lc_CheckNo_TEXT,
      @Ac_TaxJoint_CODE            = @Lc_TaxJoint_CODE,
      @Ac_Tanf_CODE                = @Lc_Tanf_CODE,
      @Ac_TaxJoint_NAME            = @Lc_TaxJoint_NAME,
      @An_EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB,
      @An_Fee_AMNT                 = @Ln_Fee_AMNT,
      @Ac_Screen_ID                = @Ac_Process_ID,
      @As_DescriptionNote_TEXT     = @Lc_Space_TEXT,
      @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
      --Bug 13447 : CR0384 -- To avoid BATCH_COMMON$SP_RECEIPT_ON_HOLD procedure call when @Ac_NcpRefundRecoverReceipt_INDC value is 'Y' i.e No need to check hold instructions when posting new receipt to recover NCP Refund amount - START
	  @Ac_NcpRefundRecoverReceipt_INDC = @Ac_NcpRefundRecoverReceipt_INDC,
      --Bug 13447 : CR0384 -- To avoid BATCH_COMMON$SP_RECEIPT_ON_HOLD procedure call when @Ac_NcpRefundRecoverReceipt_INDC value is 'Y' i.e No need to check hold instructions when posting new receipt to recover NCP Refund amount - END
	  @An_NewSeqReceipt_NUMB       = @Ln_NewSeqReceipt_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
     ELSE
      BEGIN
       IF @Ac_Msg_CODE = @Lc_StatusConChkFail_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_GENERATE_RECEIPT';
     SET @Ls_Sqldata_TEXT = 'Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_NewSeqReceipt_NUMB = ISNULL(RIGHT(REPLICATE('0', 3) + ISNULL(CAST(MAX(SUBSTRING(CAST (a.SeqReceipt_NUMB AS VARCHAR), 1, 3)) + 1 AS VARCHAR), 1), 3), '') + ISNULL(@Lc_Value001_TEXT, '')
       FROM RCTH_Y1 a
      WHERE a.Batch_NUMB = @Ln_Batch_NUMB
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_DATE = @Ld_Process_DATE
        AND a.EndValidity_DATE = @Ld_High_DATE;
    END

   --------------------------------------------------------------------------------------------
   -- Refund the Amount owed to Payor
   --------------------------------------------------------------------------------------------
   IF (@Ac_Refund_INDC = @Lc_Yes_INDC
       AND @An_Refund_AMNT > 0
       AND (@An_RepostedPayorMci_IDNO IS NOT NULL
            AND @An_RepostedPayorMci_IDNO > 0))
    BEGIN
     SET @Ln_RepostedPayorMci_IDNO = @An_RepostedPayorMci_IDNO;
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_1220';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_Refund1220_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_Refund1220_NUMB,
      @Ac_Process_ID              = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalRefundSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;
      
     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @An_EventGlobalRefundSeq_NUMB = @Ln_EventGlobalRefundSeq_NUMB;

     IF @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
       SET @Ln_DhldCase_IDNO = 0;
       
       IF @Lc_SourceReceipt_CODE IN (@Lc_SourceReceiptCpFeePayment_CODE, @Lc_SourceReceiptCpRecoupment_CODE)
        BEGIN
         DECLARE Case_CUR INSENSITIVE CURSOR FOR
          SELECT DISTINCT
                 g.Case_IDNO
            FROM CMEM_Y1 g
                 JOIN CASE_Y1 h
                  ON g.Case_IDNO = h.Case_IDNO
           WHERE g.MemberMci_IDNO = @Ln_RepostedPayorMci_IDNO
             AND g.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;
        END
       ELSE
        BEGIN
         DECLARE Case_CUR INSENSITIVE CURSOR FOR
          SELECT DISTINCT
                 g.Case_IDNO
            FROM CMEM_Y1 g
                 JOIN CASE_Y1 h
                  ON g.Case_IDNO = h.Case_IDNO
           WHERE g.MemberMci_IDNO = @Ln_RepostedPayorMci_IDNO
             AND (g.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
                   OR (g.CaseRelationship_CODE = @Lc_CaseRelationshipPutFather_CODE
                       AND NOT EXISTS (SELECT 1
                                         FROM CMEM_Y1 m
                                        WHERE m.Case_IDNO = g.Case_IDNO
                                          AND m.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE)));
        END

       OPEN Case_CUR;

       FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
	
       -- Fetch each record
       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         IF @Ln_DhldCase_IDNO = 0
          BEGIN
           SET @Ln_DhldCase_IDNO = @Ln_CaseCur_Case_IDNO;
          END
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = ' INSERT ESEM_Y1 - 1';
           SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalRefundSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_Case_TEXT,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_Refund1220_NUMB AS VARCHAR ),'');
           
           INSERT ESEM_Y1
                  (Entity_ID,
                   EventGlobalSeq_NUMB,
                   TypeEntity_CODE,
                   EventFunctionalSeq_NUMB)
           VALUES ( ISNULL(@Ln_CaseCur_Case_IDNO, @Lc_Space_TEXT),--Entity_ID
                    @Ln_EventGlobalRefundSeq_NUMB,--EventGlobalSeq_NUMB
                    @Lc_Case_TEXT,--TypeEntity_CODE
                    @Li_Refund1220_NUMB ); --EventFunctionalSeq_NUMB                       
           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF @Ln_RowCount_QNTY = 0
            BEGIN
             SET @Ls_ErrorMessage_TEXT = ' INSERT ESEM_Y1 FAILED ';

             RAISERROR(50001,16,1);
            END
          END

         FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       IF CURSOR_STATUS('Local', 'Case_Cur') IN (0, 1)
        BEGIN
         CLOSE Case_CUR;

         DEALLOCATE Case_CUR;
		END
      END
     ELSE
      BEGIN
       SET @Ln_DhldCase_IDNO = @An_CasePayorMCIReposted_IDNO;
      END

     SET @Lc_Receipt_TEXT = ISNULL(REPLACE(CONVERT(VARCHAR(10), @Ld_Process_DATE, 101), '/', ''), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ac_SourceBatch_CODE, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RIGHT(REPLICATE(@Lc_StringZero_TEXT, 4) + CAST(@Ln_Batch_NUMB AS VARCHAR), 4), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(SUBSTRING(CAST(@Ln_NewSeqReceipt_NUMB AS VARCHAR), 1, 3), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(SUBSTRING(CAST(@Ln_NewSeqReceipt_NUMB AS VARCHAR), 4, 3), '');
     
     SET @Ls_Sql_TEXT = 'INSERT ESEM_Y1 REFUND - 2';
     SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalRefundSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctno_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_Refund1220_NUMB AS VARCHAR ),'');

     INSERT ESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     SELECT @Lc_Space_TEXT AS Entity_ID,--Entity_ID
            @Ln_EventGlobalRefundSeq_NUMB AS EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
            @Lc_TypeEntityRctno_CODE AS TypeEntity_CODE,--TypeEntity_CODE
            @Li_Refund1220_NUMB AS EventFunctionalSeq_NUMB; --EventFunctionalSeq_NUMB
            
     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT ESEM_Y1 REFUND - 2 FAILED';
       
       RAISERROR(50001,16,1);
      END

     IF @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
       SET @Ln_DhldCase_IDNO = 0;
      END

     DECLARE Disburse_CUR INSENSITIVE CURSOR FOR
      SELECT l.Disburse_AMNT AS amt,
             l.CheckRecipient_ID,
             l.CheckRecipient_CODE
        FROM DSBH_Y1 h,
             DSBL_Y1 l
       WHERE l.Batch_DATE = @Ad_Batch_DATE
         AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE
         AND l.Batch_NUMB = @An_Batch_NUMB
         AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
         AND l.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
         AND h.CheckRecipient_ID = l.CheckRecipient_ID
         AND h.CheckRecipient_CODE = l.CheckRecipient_CODE
         AND h.Disburse_DATE = l.Disburse_DATE
         AND h.DisburseSeq_NUMB = l.DisburseSeq_NUMB
         AND h.StatusCheck_CODE IN (@Lc_StatusCheckCashed_CODE, @Lc_StatusCheckOu_CODE, @Lc_StatusCheckTr_CODE, @Lc_StatusCheckPs_CODE)
         AND h.EndValidity_DATE = @Ld_High_DATE
      UNION ALL
      SELECT a.Transaction_AMNT AS amt,
             a.CheckRecipient_ID,
             a.CheckRecipient_CODE
        FROM DHLD_Y1 a
       WHERE a.Batch_DATE = @Ad_Batch_DATE
         AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
         AND a.Batch_NUMB = @An_Batch_NUMB
         AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
         AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
         AND a.EventGlobalEndSeq_NUMB = @An_EventGlobalBackOutSeq_NUMB
      UNION ALL
      SELECT SUM(a.RecOverpay_AMNT) AS amt,
             a.CheckRecipient_ID,
             a.CheckRecipient_CODE
        FROM POFL_Y1 a
       WHERE a.Batch_DATE = @Ad_Batch_DATE
         AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
         AND a.Batch_NUMB = @An_Batch_NUMB
         AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
         AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
         AND a.RecOverpay_AMNT <> 0
         AND a.EventGlobalSeq_NUMB <> @An_EventGlobalBackOutSeq_NUMB
       GROUP BY a.CheckRecipient_ID,
                a.CheckRecipient_CODE
      HAVING SUM(a.RecOverpay_AMNT) > 0;

     OPEN Disburse_CUR;

     FETCH NEXT FROM Disburse_CUR INTO @Ln_DisburseCur_Disburse_AMNT, @Lc_DisburseCur_CheckRecipient_ID, @Lc_DisburseCur_CheckRecipient_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

	 --FETCH EACH RECORD
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Lc_RefundRecipient_ID = @Lc_DisburseCur_CheckRecipient_ID;
       SET @Lc_RefundRecipient_CODE = @Lc_DisburseCur_CheckRecipient_CODE;
       
       SET @Ls_Sql_TEXT = 'INSERT DHLD_Y1 -1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_DhldCase_IDNO AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_NUMB AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_DisburseCur_Disburse_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusR_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburseRefund_CODE,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_DisburseCur_CheckRecipient_ID,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TypeHoldD_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_DisburseCur_CheckRecipient_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalRefundSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalRefundSeq_NUMB AS VARCHAR ),'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');
       
       INSERT DHLD_Y1
              (Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               Transaction_DATE,
               Release_DATE,
               Transaction_AMNT,
               Status_CODE,
               TypeDisburse_CODE,
               CheckRecipient_ID,
               TypeHold_CODE,
               ReasonStatus_CODE,
               CheckRecipient_CODE,
               ProcessOffset_INDC,
               EventGlobalSupportSeq_NUMB,
               BeginValidity_DATE,
               EndValidity_DATE,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               Disburse_DATE,
               StatusEscheat_DATE,
               DisburseSeq_NUMB,
               StatusEscheat_CODE)
       VALUES ( @Ln_DhldCase_IDNO,--Case_IDNO
                0,--OrderSeq_NUMB
                0,--ObligationSeq_NUMB
                @Ld_Process_DATE,--Batch_DATE
                @Ac_SourceBatch_CODE,--SourceBatch_CODE
                @Ln_Batch_NUMB,--Batch_NUMB
                @Ln_NewSeqReceipt_NUMB,--SeqReceipt_NUMB
                CONVERT(VARCHAR(10), dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101),--Transaction_DATE
                @Ld_Process_DATE,--Release_DATE
                @Ln_DisburseCur_Disburse_AMNT,--Transaction_AMNT
                @Lc_StatusR_CODE,--Status_CODE
                @Lc_TypeDisburseRefund_CODE,--TypeDisburse_CODE	
                @Lc_DisburseCur_CheckRecipient_ID,--CheckRecipient_ID
                @Lc_TypeHoldD_CODE,--TypeHold_CODE
                @Lc_Space_TEXT,--ReasonStatus_CODE
                @Lc_DisburseCur_CheckRecipient_CODE,--CheckRecipient_CODE
                @Lc_Yes_INDC,--ProcessOffset_INDC
                @Ln_EventGlobalRefundSeq_NUMB,--EventGlobalSupportSeq_NUMB	
                @Ld_Process_DATE,--BeginValidity_DATE
                @Ld_High_DATE,--EndValidity_DATE
                @Ln_EventGlobalRefundSeq_NUMB,--EventGlobalBeginSeq_NUMB
                0,--EventGlobalEndSeq_NUMB
                @Ld_High_DATE,--Disburse_DATE
                @Ld_High_DATE,--StatusEscheat_DATE
                0,--DisburseSeq_NUMB
                @Lc_Space_TEXT); --StatusEscheat_CODE
                
       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        END

       FETCH NEXT FROM Disburse_CUR INTO @Ln_DisburseCur_Disburse_AMNT, @Lc_DisburseCur_CheckRecipient_ID, @Lc_DisburseCur_CheckRecipient_CODE;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     IF CURSOR_STATUS('Local', 'Disburse_Cur') IN (0, 1)
      BEGIN
       CLOSE Disburse_Cur;

       DEALLOCATE Disburse_Cur;
      END     
      
     SET @Ls_Sql_TEXT = 'INSERT_VRCTH3';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE,'')+ ', TypeRemittance_CODE = ' + ISNULL(@Lc_TypeRemittance_CODE,'')+ ', TypePosting_CODE = ' + ISNULL(@Lc_TypePosting_CODE,'')+ ', PayorMCI_IDNO = ' + ISNULL(CAST( @Ln_RepostedPayorMci_IDNO AS VARCHAR ),'')+ ', Refund_DATE = ' + ISNULL(CAST( @Ld_Refund_DATE AS VARCHAR ),'')+ ', ReferenceIrs_IDNO = ' + ISNULL(CAST( @Ln_ReferenceIrs_IDNO AS VARCHAR ),'')+ ', RefundRecipient_CODE = ' + ISNULL(@Lc_RefundRecipient_CODE,'')+ ', RefundRecipient_ID = ' + ISNULL(@Lc_RefundRecipient_ID,'')+ ', Employer_IDNO = ' + ISNULL(CAST( @Ln_Employer_IDNO AS VARCHAR ),'')+ ', Fips_CODE = ' + ISNULL(@Lc_Fips_CODE,'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @An_Receipt_AMNT AS VARCHAR ),'')+ ', ToDistribute_AMNT = ' + ISNULL(CAST( @An_Refund_AMNT AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Receipt_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Check_DATE = ' + ISNULL(CAST( @Ld_Check_DATE AS VARCHAR ),'')+ ', CheckNo_TEXT = ' + ISNULL(@Lc_CheckNo_TEXT,'')+ ', TaxJoint_CODE = ' + ISNULL(@Lc_TaxJoint_CODE,'')+ ', Tanf_CODE = ' + ISNULL(@Lc_Tanf_CODE,'')+ ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusR_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalRefundSeq_NUMB AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Fee_AMNT = ' + ISNULL(CAST( @Ln_Fee_AMNT AS VARCHAR ),'')+ ', TaxJoint_NAME = ' + ISNULL(@Lc_TaxJoint_NAME,'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

     INSERT RCTH_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             PayorMCI_IDNO,
             Refund_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_CODE,
             RefundRecipient_ID,
             Case_IDNO,
             Employer_IDNO,
             Fips_CODE,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Receipt_DATE,
             Distribute_DATE,
             Check_DATE,
             CheckNo_TEXT,
             TaxJoint_CODE,
             Tanf_CODE,
             BackOut_INDC,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             Release_DATE,
             Fee_AMNT,
             TaxJoint_NAME,
             ReasonBackOut_CODE)
     VALUES ( @Ld_Process_DATE,--Batch_DATE
              @Ac_SourceBatch_CODE,--SourceBatch_CODE
              @Ln_Batch_NUMB,--Batch_NUMB
              @Ln_NewSeqReceipt_NUMB,--SeqReceipt_NUMB
              @Lc_SourceReceipt_CODE,--SourceReceipt_CODE
              @Lc_TypeRemittance_CODE,--TypeRemittance_CODE
              @Lc_TypePosting_CODE,--TypePosting_CODE
              @Ln_RepostedPayorMci_IDNO,--PayorMCI_IDNO
              @Ld_Refund_DATE,--Refund_DATE
              @Ln_ReferenceIrs_IDNO,--ReferenceIrs_IDNO
              @Lc_RefundRecipient_CODE,--RefundRecipient_CODE
              @Lc_RefundRecipient_ID,--RefundRecipient_ID
              CASE @Lc_TypePosting_CODE
               WHEN @Lc_StatusC_CODE
                THEN @An_CasePayorMCIReposted_IDNO
               ELSE 0
              END,--Case_IDNO
              @Ln_Employer_IDNO,--Employer_IDNO
              @Lc_Fips_CODE,--Fips_CODE
              @An_Receipt_AMNT,--Receipt_AMNT
              @An_Refund_AMNT,--ToDistribute_AMNT
              @Ld_Receipt_DATE,--Receipt_DATE
              @Ld_Process_DATE,--Distribute_DATE
              @Ld_Check_DATE,--Check_DATE
              @Lc_CheckNo_TEXT,--CheckNo_TEXT
              @Lc_TaxJoint_CODE,--TaxJoint_CODE
              @Lc_Tanf_CODE,--Tanf_CODE
              @Lc_No_INDC,--BackOut_INDC
              @Lc_StatusR_CODE,--StatusReceipt_CODE
              @Lc_Space_TEXT,--ReasonStatus_CODE
              @Ld_Process_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              @Ln_EventGlobalRefundSeq_NUMB,--EventGlobalBeginSeq_NUMB
              0,--EventGlobalEndSeq_NUMB
              @Ld_Process_DATE,--Release_DATE
              @Ln_Fee_AMNT,--Fee_AMNT
              @Lc_TaxJoint_NAME,--TaxJoint_NAME
              @Lc_Space_TEXT); --ReasonBackOut_CODE
     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO RCTH_Y1 FAILED';
       
       RAISERROR(50001,16,1);
      END
      
     SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'') + ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_NUMB AS VARCHAR ),'') + ', EventGlobalBeginSeq_NUMB >= ' + CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR);
     UPDATE RCTH_Y1
        SET Receipt_AMNT = @An_Receipt_AMNT
      WHERE Batch_DATE = @Ld_Process_DATE
        AND SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND Batch_NUMB = @Ln_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_NewSeqReceipt_NUMB
        AND EventGlobalBeginSeq_NUMB >= @An_EventGlobalBeginSeq_NUMB;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED';

       RAISERROR(50001,16,1);
      END
    END

   IF (@An_Receipt_AMNT - @An_Refund_AMNT) > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB >= ' + CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', StatusReceipt_CODE != ' + @Lc_StatusReceiptRefunded_CODE;
     
     SELECT @An_EventGlobalBeginSeq_NUMB = MAX(a.EventGlobalBeginSeq_NUMB)
       FROM RCTH_Y1 a
      WHERE a.Batch_DATE = @Ld_Process_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @Ln_Batch_NUMB
        AND a.SeqReceipt_NUMB = @Ln_NewSeqReceipt_NUMB
        AND a.EventGlobalBeginSeq_NUMB >= @An_EventGlobalBeginSeq_NUMB
        AND a.StatusReceipt_CODE != @Lc_StatusReceiptRefunded_CODE;
    END
   ELSE
    BEGIN
     SET @An_EventGlobalBeginSeq_NUMB = @Ln_EventGlobalRefundSeq_NUMB;
    END

   SET @Ls_Sql_TEXT = 'INSERT RCTR_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_NewSeqReceipt_NUMB AS VARCHAR ),'')+ ', BatchOrig_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', BatchOrig_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceiptOrig_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', StatusMatch_CODE = ' + ISNULL(@Lc_StatusMatchM_CODE,'')+ ', RePost_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', ReasonRePost_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE,'')+ ', ReceiptCurrent_AMNT = ' + ISNULL(CAST( @An_Receipt_AMNT AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

   INSERT RCTR_Y1
          (Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           BatchOrig_DATE,
           BatchOrig_NUMB,
           SeqReceiptOrig_NUMB,
           SourceBatchOrig_CODE,
           StatusMatch_CODE,
           RePost_DATE,
           ReasonRePost_CODE,
           ReceiptCurrent_AMNT,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB)
   VALUES ( @Ld_Process_DATE,--Batch_DATE
            @Ac_SourceBatch_CODE,--SourceBatch_CODE
            @Ln_Batch_NUMB,--Batch_NUMB
            @Ln_NewSeqReceipt_NUMB,--SeqReceipt_NUMB
            @Ad_Batch_DATE,--BatchOrig_DATE
            @An_Batch_NUMB,--BatchOrig_NUMB
            @An_SeqReceipt_NUMB,--SeqReceiptOrig_NUMB
            ISNULL(LTRIM(RTRIM(@Ac_SourceBatch_CODE)), ''),--SourceBatchOrig_CODE
            @Lc_StatusMatchM_CODE,--StatusMatch_CODE
            @Ld_Process_DATE,--RePost_DATE
            @Ac_ReasonBackOut_CODE,--ReasonRePost_CODE
            @An_Receipt_AMNT,--ReceiptCurrent_AMNT
            @Ld_Process_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0); --EventGlobalEndSeq_NUMB

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT INTO RCTR FAILED';
     RAISERROR(50001,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_REPOST_TRIP_ADDRESS';
   SET @Ls_Sqldata_TEXT = 'BatchOrig_DATE = ' + CAST(@Ad_Batch_DATE AS VARCHAR )+ ', SourceBatchOrig_CODE = ' + @Ac_SourceBatch_CODE+ ', BatchOrig_NUMB = ' + CAST( @An_Batch_NUMB AS VARCHAR )+ ', SeqReceiptOrig_NUMB = ' + CAST( @An_SeqReceipt_NUMB AS VARCHAR )
									+'Batch_DATE = ' + CAST( @Ld_Process_DATE AS VARCHAR )+ ', SourceBatch_CODE = ' + @Ac_SourceBatch_CODE+ ', Batch_NUMB = ' + CAST( @Ln_Batch_NUMB AS VARCHAR )+ ', SeqReceipt_NUMB = ' + CAST( @Ln_NewSeqReceipt_NUMB AS VARCHAR );

   EXEC BATCH_COMMON$SP_INSERT_REPOST_TRIP_ADDRESS
   @Ad_Batch_DATE               = @Ld_Process_DATE,
   @Ac_SourceBatch_CODE         = @Ac_SourceBatch_CODE,
   @An_Batch_NUMB               = @Ln_Batch_NUMB,
   @An_SeqReceipt_NUMB          = @Ln_NewSeqReceipt_NUMB,
   @Ad_BatchOrig_DATE           = @Ad_Batch_DATE,
   @Ac_SourceBatchOrig_CODE     = @Ac_SourceBatch_CODE,
   @An_BatchOrig_NUMB           = @An_Batch_NUMB,
   @An_SeqReceiptOrig_NUMB      = @An_SeqReceipt_NUMB,
   @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
   @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

	IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
	BEGIN
	   RAISERROR(50001,16,1);
	END
    
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('Local', 'Case_CUR') IN (0, 1)
    BEGIN
     CLOSE Case_CUR;

     DEALLOCATE Case_CUR;
    END

   IF CURSOR_STATUS('Local', 'Disburse_CUR') IN (0, 1)
    BEGIN
     CLOSE Disburse_CUR;

     DEALLOCATE Disburse_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Li_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   
  END CATCH
 END


GO
