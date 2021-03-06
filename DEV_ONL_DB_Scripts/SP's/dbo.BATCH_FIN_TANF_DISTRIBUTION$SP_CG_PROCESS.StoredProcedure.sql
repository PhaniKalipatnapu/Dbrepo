/****** Object:  StoredProcedure [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_CG_PROCESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_TANF_DISTRIBUTION$SP_CG_PROCESS
Programmer Name 	: IMP Team
Description			: Process the CHPAA record and apply to the current TANF.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_CG_PROCESS]
 @An_Case_IDNO                  NUMERIC(6),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @An_CpMci_IDNO                 NUMERIC(10),
 @Ad_Batch_DATE                 DATE,
 @An_Batch_NUMB                 NUMERIC(4),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_CaseWelfare_IDNO           NUMERIC(10),
 @Ac_TypeWelfare_CODE           CHAR(1),
 @Ad_Receipt_DATE               DATE,
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @Ac_TypeDisbursementDhld_CODE  CHAR (5),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @Ac_TypeHold_CODE              CHAR(1),
 @Ac_SourceReceipt_CODE         CHAR(2),
 @An_TransactionCurSup_AMNT     NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE               DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_No_INDC                         CHAR (1) = 'N',
           @Lc_StatusSuccess_CODE              CHAR (1) = 'S',
           @Lc_Yes_INDC                        CHAR (1) = 'Y',
           @Lc_StatusFailed_CODE               CHAR (1) = 'F',
           @Lc_WelfareTypeTanf_CODE            CHAR (1) = 'A',
           @Lc_Space_TEXT                      CHAR (1) = ' ',
           @Lc_RegularHold_CODE                CHAR (1) = 'D',
           @Lc_TanfHold_CODE                   CHAR (1) = 'T',
           @Lc_DisbursementStatusHeld_CODE     CHAR (1) = 'H',
           @Lc_DisbursementStatusRelease_CODE  CHAR (1) = 'R',
		   -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - Start --
		   @Lc_CaseRelationshipC_CODE		   CHAR(1) = 'C',		   
		   @Lc_CaseMemberStatusA_CODE		   CHAR(1) = 'A',
		   -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - End --           
           @Lc_ReasonStatusDr_CODE             CHAR (2) = 'DR',
           @Lc_DisbursementTypeHold_CODE       CHAR (4) = 'HOLD',
           @Lc_ReasonStatusSdng_CODE           CHAR (4) = 'SDNG',
           @Lc_DisbursementTypeGrant_CODE      CHAR (4) = 'GRNT',
           @Lc_TypeDisbursementCgpaa_CODE      CHAR (5) = 'CGPAA',
           @Lc_EntityWcase_TEXT                CHAR (5) = 'WCASE',
           @Ls_Sql_TEXT                        VARCHAR (100) = ' ',
           @Ls_Procedure_NAME                  VARCHAR (100) = 'SP_CG_PROCESS',
           @Ls_Sqldata_TEXT                    VARCHAR (1000) = ' ',
           @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE  @Ln_Value_NUMB                    NUMERIC (1),
           @Ln_ReceiptWelfareYearMonth_NUMB  NUMERIC (6),
           @Ln_ProcessWelfareYearMonth_NUMB  NUMERIC (6),
           @Ln_EsemDistCount_QNTY            NUMERIC (9),
           @Ln_AssignArrearCount_QNTY        NUMERIC (9) = 0,
           @Ln_Error_NUMB                    NUMERIC (11),
           @Ln_ErrorLine_NUMB                NUMERIC (11),
           @Ln_PaidCg_AMNT                   NUMERIC (11,2) = 0,
           @Ln_PaidCgTot_AMNT                NUMERIC (11,2) = 0,
           @Ln_MtdGrant_AMNT                 NUMERIC (11,2) = 0,
           @Ln_PaidPgTot_AMNT                NUMERIC (11,2) = 0,
           @Ln_LtdGrant_AMNT                 NUMERIC (11,2) = 0,
           @Li_FetchStatus_QNTY              SMALLINT,
           @Li_Rowcount_QNTY                 SMALLINT,
           @Lc_DistWcaseFlag_INDC            CHAR (1),
           @Lc_AllwemoCurOpen_INDC           CHAR (1),
           @Lc_AllwemoProcs_INDC             CHAR (1),
           @Lc_AssignFlag_INDC               CHAR (1),
           @Ls_ErrorMessage_TEXT             VARCHAR (2000),
           @Ls_DescriptionError_TEXT         VARCHAR (4000);
  DECLARE  @Ln_AllWemoCurCase_IDNO				 NUMERIC (6),	
		   @Ln_AllWemoCurOrderSeq_NUMB			 NUMERIC (2),
           @Ln_AllWemoCurObligationSeq_NUMB		 NUMERIC (2),
           @Ln_AllWemoCurMtdAssistExpend_AMNT    NUMERIC (11,2),
           @Ln_AllWemoCurExpandTotAsst_AMNT      NUMERIC (11,2),
           @Ln_AllWemoCurRecupTotAsst_AMNT       NUMERIC (11,2);
          
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ln_ReceiptWelfareYearMonth_NUMB = CAST (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6) AS NUMERIC);
   SET @Ln_ProcessWelfareYearMonth_NUMB = CAST (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6) AS NUMERIC);
   SET @Ln_AllWemoCurCase_IDNO = @An_Case_IDNO;
   SET @Ln_AllWemoCurOrderSeq_NUMB = @An_OrderSeq_NUMB;
   SET @Ln_AllWemoCurObligationSeq_NUMB = @An_ObligationSeq_NUMB;
   SET @Ln_PaidCgTot_AMNT = 0;
   SET @Lc_AllwemoCurOpen_INDC = @Lc_No_INDC;
   SET @Lc_AllwemoProcs_INDC = @Lc_No_INDC;
   SET @Ls_Sql_TEXT = 'SELECT @Ln_Value_NUMB';   
   SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'');

   SELECT TOP 1 @Ln_Value_NUMB = 1
     FROM WEMO_Y1 a,
          IVMG_Y1 b
    WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
      AND a.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB
      AND b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
      AND b.CpMci_IDNO = @An_CpMci_IDNO
      AND b.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB
      AND EndValidity_DATE = @Ld_High_DATE
      AND b.MtdAssistExpend_AMNT > 0
      AND EventGlobalSeq_NUMB = (SELECT MAX (EventGlobalSeq_NUMB)
                                   FROM IVMG_Y1 c
                                  WHERE c.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                                        AND c.CpMci_IDNO = @An_CpMci_IDNO
                                        AND c.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB
                                        AND c.WelfareElig_CODE = b.WelfareElig_CODE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     IF @Ac_TypeHold_CODE != @Lc_RegularHold_CODE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
       SET @An_TransactionCurSup_AMNT = 0;
       RETURN;
      END
      
	 -- NO IV-A GRANT 
     SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_CG';     
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ad_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL(CAST( @An_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL('0','')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TanfHold_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_DisbursementTypeHold_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Ac_TypeDisbursementDhld_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeld_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusSdng_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'');

     EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
      @An_Case_IDNO                  = @An_Case_IDNO,
      @An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB         = @An_ObligationSeq_NUMB,
      @Ad_Batch_DATE                 = @Ad_Batch_DATE,
      @Ac_SourceBatch_CODE           = @Ac_SourceBatch_CODE,
      @An_Batch_NUMB                 = @An_Batch_NUMB,
      @An_SeqReceipt_NUMB            = @An_SeqReceipt_NUMB,
      @Ad_Receipt_DATE               = @Ad_Receipt_DATE,
      @An_TransactionCs_AMNT         = @An_TransactionCurSup_AMNT,
      @An_TransactionPaa_AMNT        = 0,
      @Ac_TypeHold_CODE              = @Lc_TanfHold_CODE,
      @Ac_TypeDisburse_CODE          = @Lc_DisbursementTypeHold_CODE,
      @Ac_TypeDisbursementDhld_CODE  = @Ac_TypeDisbursementDhld_CODE,
      @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
      @Ac_Status_CODE                = @Lc_DisbursementStatusHeld_CODE,
      @Ac_Reason_CODE                = @Lc_ReasonStatusSdng_CODE,
      @An_EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB,
      @An_EventGlobalSeq_NUMB        = @An_EventGlobalSeq_NUMB,
      @Ac_CheckRecipient_ID          = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE        = @Ac_CheckRecipient_CODE,
      @Ac_SourceReceipt_CODE         = @Ac_SourceReceipt_CODE,
      @Ac_Msg_CODE                   = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
      @Ad_Process_DATE               = @Ad_Process_DATE OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @An_TransactionCurSup_AMNT = 0;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'WHILE LOOP -1';   
   SET @Ls_Sqldata_TEXT = '';
   
   --Loop Begin
   WHILE @Lc_AllwemoProcs_INDC = @Lc_No_INDC
         AND @An_TransactionCurSup_AMNT > 0
    BEGIN
     SET @Ln_MtdGrant_AMNT = 0;
     SET @Ln_PaidCg_AMNT = 0;
     SET @Ls_Sql_TEXT = 'SELECT_WEMO_OBlx_MTH_RECEIPT';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_MtdGrant_AMNT = (a.MtdAssistExpend_AMNT - a.MtdAssistRecoup_AMNT)
       FROM WEMO_Y1 a
      WHERE a.Case_IDNO = @Ln_AllWemoCurCase_IDNO
        AND a.OrderSeq_NUMB = @Ln_AllWemoCurOrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @Ln_AllWemoCurObligationSeq_NUMB
        AND a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
        AND a.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ln_MtdGrant_AMNT = 0;
      END

     IF @Ln_MtdGrant_AMNT > 0 AND @Ln_ReceiptWelfareYearMonth_NUMB != @Ln_ProcessWelfareYearMonth_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_WEMO_WEMO_Y1_MTH_PROCESS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ProcessWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT @Ln_LtdGrant_AMNT = (a.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT)
         FROM WEMO_Y1 a
        WHERE a.Case_IDNO = @Ln_AllWemoCurCase_IDNO
          AND a.OrderSeq_NUMB = @Ln_AllWemoCurOrderSeq_NUMB
          AND a.ObligationSeq_NUMB = @Ln_AllWemoCurObligationSeq_NUMB
          AND a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
          AND a.WelfareYearMonth_NUMB = @Ln_ProcessWelfareYearMonth_NUMB
          AND a.EndValidity_DATE = @Ld_High_DATE;

       IF @Ln_LtdGrant_AMNT < @Ln_MtdGrant_AMNT
        BEGIN
         SET @Ln_MtdGrant_AMNT = @Ln_LtdGrant_AMNT;
        END

       IF @Ln_MtdGrant_AMNT < 0
        BEGIN
         SET @Ln_MtdGrant_AMNT = 0;
        END
      END

     IF @Ln_MtdGrant_AMNT > 0 AND @An_TransactionCurSup_AMNT > 0
     BEGIN
      IF @Ln_MtdGrant_AMNT >= @An_TransactionCurSup_AMNT
       BEGIN
        SET @Ln_PaidCg_AMNT = @An_TransactionCurSup_AMNT;
        SET @An_TransactionCurSup_AMNT = 0;
       END
      ELSE
       BEGIN
        SET @Ln_PaidCg_AMNT = @Ln_MtdGrant_AMNT;
        SET @An_TransactionCurSup_AMNT = @An_TransactionCurSup_AMNT - @Ln_PaidCg_AMNT;
       END
	 END
	 
     SET @Ln_PaidCgTot_AMNT = @Ln_PaidCgTot_AMNT + @Ln_PaidCg_AMNT;

     IF @Ln_PaidCg_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_LWEL_Y1_CG';	   
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Ac_TypeWelfare_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Distribute_AMNT = ' + ISNULL(CAST( @Ln_PaidCg_AMNT AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisbursementCgpaa_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'');

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
       VALUES (@Ln_AllWemoCurCase_IDNO,    --Case_IDNO
               @Ln_AllWemoCurOrderSeq_NUMB,    --OrderSeq_NUMB
               @Ln_AllWemoCurObligationSeq_NUMB,   --ObligationSeq_NUMB
               @Ln_ReceiptWelfareYearMonth_NUMB,   --WelfareYearMonth_NUMB
               @Ad_Batch_DATE,   --Batch_DATE
               @An_Batch_NUMB,   --Batch_NUMB
               @An_SeqReceipt_NUMB,   --SeqReceipt_NUMB
               @Ac_SourceBatch_CODE,   --SourceBatch_CODE
               @An_CaseWelfare_IDNO,   --CaseWelfare_IDNO
               @Ac_TypeWelfare_CODE,   --TypeWelfare_CODE
               @Ad_Process_DATE,   --Distribute_DATE
               @Ln_PaidCg_AMNT,   --Distribute_AMNT
               @Lc_TypeDisbursementCgpaa_CODE,   --TypeDisburse_CODE
               @An_EventGlobalSeq_NUMB,   --EventGlobalSeq_NUMB
               @An_EventGlobalSupportSeq_NUMB  --EventGlobalSupportSeq_NUMB
);

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_LWEL_Y12 FAILED';

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE_WEMO_Y13_1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       UPDATE WEMO_Y1
          SET TransactionAssistRecoup_AMNT = WEMO_Y1.TransactionAssistRecoup_AMNT + @Ln_PaidCg_AMNT,
              MtdAssistRecoup_AMNT = WEMO_Y1.MtdAssistRecoup_AMNT + CASE WEMO_Y1.WelfareYearMonth_NUMB
                                                                     WHEN @Ln_ReceiptWelfareYearMonth_NUMB
                                                                      THEN @Ln_PaidCg_AMNT
                                                                     ELSE 0
                                                                    END,
              LtdAssistRecoup_AMNT = WEMO_Y1.LtdAssistRecoup_AMNT + @Ln_PaidCg_AMNT
        WHERE Case_IDNO = @Ln_AllWemoCurCase_IDNO
          AND OrderSeq_NUMB = @Ln_AllWemoCurOrderSeq_NUMB
          AND ObligationSeq_NUMB = @Ln_AllWemoCurObligationSeq_NUMB
          AND CaseWelfare_IDNO = @An_CaseWelfare_IDNO
          AND WelfareYearMonth_NUMB BETWEEN @Ln_ReceiptWelfareYearMonth_NUMB AND @Ln_ProcessWelfareYearMonth_NUMB
          AND EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE_WEMO_Y13';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         UPDATE WEMO_Y1
            SET EndValidity_DATE = @Ad_Process_DATE,
                EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
          WHERE Case_IDNO = @Ln_AllWemoCurCase_IDNO
            AND OrderSeq_NUMB = @Ln_AllWemoCurOrderSeq_NUMB
            AND ObligationSeq_NUMB = @Ln_AllWemoCurObligationSeq_NUMB
            AND CaseWelfare_IDNO = @An_CaseWelfare_IDNO
            AND WelfareYearMonth_NUMB BETWEEN @Ln_ReceiptWelfareYearMonth_NUMB AND @Ln_ProcessWelfareYearMonth_NUMB
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'UPDATE_WEMO_Y13_CG FAILED';

           RAISERROR (50001,16,1);
          END

         SET @Ls_Sql_TEXT = 'INSERT_WEMO_Y1_CG';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','')+ ', TransactionAssistRecoup_AMNT = ' + ISNULL(CAST( @Ln_PaidCg_AMNT AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','');

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
         (SELECT @Ln_AllWemoCurCase_IDNO AS Case_IDNO,
                 @Ln_AllWemoCurOrderSeq_NUMB AS OrderSeq_NUMB,
                 @Ln_AllWemoCurObligationSeq_NUMB AS ObligationSeq_NUMB,
                 @An_CaseWelfare_IDNO AS CaseWelfare_IDNO,
                 a.WelfareYearMonth_NUMB,
                 a.MtdAssistExpend_AMNT,
                 0 AS TransactionAssistExpend_AMNT,
                 a.LtdAssistExpend_AMNT AS LtdAssistExpend_AMNT,
                 @Ln_PaidCg_AMNT AS TransactionAssistRecoup_AMNT,
                 a.MtdAssistRecoup_AMNT + CASE a.WelfareYearMonth_NUMB
                                           WHEN @Ln_ReceiptWelfareYearMonth_NUMB
                                            THEN @Ln_PaidCg_AMNT
                                           ELSE 0
                                          END AS MtdAssistRecoup_AMNT,
                 a.LtdAssistRecoup_AMNT + @Ln_PaidCg_AMNT AS LtdAssistRecoup_AMNT,
                 @Ad_Process_DATE AS BeginValidity_DATE,
                 @Ld_High_DATE AS EndValidity_DATE,
                 @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
                 0 AS EventGlobalEndSeq_NUMB
            FROM WEMO_Y1 a
           WHERE a.Case_IDNO = @Ln_AllWemoCurCase_IDNO
             AND a.OrderSeq_NUMB = @Ln_AllWemoCurOrderSeq_NUMB
             AND a.ObligationSeq_NUMB = @Ln_AllWemoCurObligationSeq_NUMB
             AND a.WelfareYearMonth_NUMB BETWEEN @Ln_ReceiptWelfareYearMonth_NUMB AND @Ln_ProcessWelfareYearMonth_NUMB
             AND a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
             AND a.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT_WEMO_Y1_CG FAILED';

           RAISERROR (50001,16,1);
          END
        END
		-- Log the Case-Obligations details in WELR table when money is distributed to one Case_obligation and it was used to recoup grant money from another Case-Obligation.
       IF @Ln_AllWemoCurCase_IDNO != @An_Case_IDNO
           OR @Ln_AllWemoCurOrderSeq_NUMB != @An_OrderSeq_NUMB
           OR @Ln_AllWemoCurObligationSeq_NUMB != @An_ObligationSeq_NUMB
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_VWELR1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CaseOrig_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderOrigSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObleOrigSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'');

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
         VALUES (@Ln_AllWemoCurCase_IDNO,    --Case_IDNO
                 @Ln_AllWemoCurOrderSeq_NUMB,   --OrderSeq_NUMB
                 @Ln_AllWemoCurObligationSeq_NUMB,   --ObligationSeq_NUMB
                 @An_CaseWelfare_IDNO,   --CaseWelfare_IDNO
                 @Ad_Process_DATE,   --Distribute_DATE
                 @An_EventGlobalSeq_NUMB,   --EventGlobalSeq_NUMB
                 @An_Case_IDNO,   --CaseOrig_IDNO
                 @An_OrderSeq_NUMB,   --OrderOrigSeq_NUMB
                 @An_ObligationSeq_NUMB,   --ObleOrigSeq_NUMB
                 @Ad_Batch_DATE,   --Batch_DATE
                 @Ac_SourceBatch_CODE,   --SourceBatch_CODE
                 @An_Batch_NUMB,   --Batch_NUMB
                 @An_SeqReceipt_NUMB,   --SeqReceipt_NUMB
                 @An_EventGlobalSupportSeq_NUMB  --EventGlobalSupportSeq_NUMB
);

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT_VWELR FAILED';

           RAISERROR (50001,16,1);
          END
        END

       SET @Lc_AssignFlag_INDC = @Lc_No_INDC;
	   SET @Ls_Sql_TEXT = 'SELECT_#AssignArr_P1';       
	   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'');

       SELECT TOP 1 @Lc_AssignFlag_INDC = @Lc_Yes_INDC
         FROM #AssignArr_P1 a
        WHERE a.Case_IDNO = @Ln_AllWemoCurCase_IDNO
          AND a.OrderSeq_NUMB = @Ln_AllWemoCurOrderSeq_NUMB
          AND a.ObligationSeq_NUMB = @Ln_AllWemoCurObligationSeq_NUMB;

	   SET @Ls_Sql_TEXT = 'SELECT_@Ln_AssignArrearCount_QNTY';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_AssignArrearCount_QNTY = COUNT (1) + 1
         FROM #AssignArr_P1 a;

       IF @Lc_AssignFlag_INDC = @Lc_No_INDC
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_#AssignArr_P1';         
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_AllWemoCurCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_AllWemoCurObligationSeq_NUMB AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_ReceiptWelfareYearMonth_NUMB AS VARCHAR ),'');

         INSERT INTO #AssignArr_P1
                     (Case_IDNO,
                      OrderSeq_NUMB,
                      ObligationSeq_NUMB,
                      WelfareYearMonth_NUMB)
              VALUES (@Ln_AllWemoCurCase_IDNO,    --Case_IDNO
                      @Ln_AllWemoCurOrderSeq_NUMB,    --OrderSeq_NUMB
                      @Ln_AllWemoCurObligationSeq_NUMB,    --ObligationSeq_NUMB
                      @Ln_ReceiptWelfareYearMonth_NUMB  --WelfareYearMonth_NUMB
					); 
        END
      END

     IF @An_TransactionCurSup_AMNT > 0
      BEGIN
       IF NOT CURSOR_STATUS ('Local', 'AllWemo_CUR') IN (0, 1)
        BEGIN
		
		DECLARE AllWemo_CUR INSENSITIVE CURSOR FOR
		 SELECT a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB,
                a.MtdAssistExpend_AMNT,
                a.LtdAssistExpend_AMNT,
                a.LtdAssistRecoup_AMNT
           FROM WEMO_Y1 a
          WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
			  -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - Start -- 
			  AND a.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
									WHERE b.MemberMci_IDNO = @An_CpMci_IDNO
									  AND b.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
									  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
			 -- Defect 13351 - Multiple CPs on IV-A case -TANF Distribution batch recovering URA from all associated cases not just cases for the CP+IV-A combination - Fix - End --          
            AND a.EndValidity_DATE = @Ld_High_DATE
            AND (a.MtdAssistExpend_AMNT - a.MtdAssistRecoup_AMNT) > 0
            AND a.WelfareYearMonth_NUMB = @Ln_ReceiptWelfareYearMonth_NUMB;
            
         SET @Ls_Sql_TEXT = 'OPEN_CUR AllWemo_CUR';         
         SET @Ls_Sqldata_TEXT = '';
         
         OPEN AllWemo_CUR;

         SET @Lc_AllwemoCurOpen_INDC = @Lc_Yes_INDC;
        END

       SET @Ls_Sql_TEXT = 'FETCH_CUR AllWemo_CUR';  
       SET @Ls_Sqldata_TEXT = '';     
       
       FETCH AllWemo_CUR INTO @Ln_AllWemoCurCase_IDNO, @Ln_AllWemoCurOrderSeq_NUMB, @Ln_AllWemoCurObligationSeq_NUMB, @Ln_AllWemoCurMtdAssistExpend_AMNT, @Ln_AllWemoCurExpandTotAsst_AMNT, @Ln_AllWemoCurRecupTotAsst_AMNT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

       IF @Li_FetchStatus_QNTY <> 0
        BEGIN
         SET @Lc_AllwemoProcs_INDC = @Lc_Yes_INDC;

         CLOSE AllWemo_CUR;

         DEALLOCATE AllWemo_CUR;
        END
      END
     ELSE
      BEGIN
       IF @Lc_AllwemoCurOpen_INDC = @Lc_Yes_INDC
        BEGIN
         IF CURSOR_STATUS ('Local', 'AllWemo_CUR') IN (0, 1)
          BEGIN
           CLOSE AllWemo_CUR;

           DEALLOCATE AllWemo_CUR;
          END
        END
      END
    END

   IF @Ln_PaidCgTot_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD_3';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ad_Receipt_DATE AS VARCHAR ),'')+ ', TransactionCs_AMNT = ' + ISNULL(CAST( @Ln_PaidCgTot_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL('0','')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHold_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_DisbursementTypeGrant_CODE,'')+ ', TypeDisbursementDhld_CODE = ' + ISNULL(@Ac_TypeDisbursementDhld_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusRelease_CODE,'')+ ', Reason_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'');

     EXECUTE BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
      @An_Case_IDNO                  = @An_Case_IDNO,
      @An_OrderSeq_NUMB              = @An_OrderSeq_NUMB,
      @An_ObligationSeq_NUMB         = @An_ObligationSeq_NUMB,
      @Ad_Batch_DATE                 = @Ad_Batch_DATE,
      @Ac_SourceBatch_CODE           = @Ac_SourceBatch_CODE,
      @An_Batch_NUMB                 = @An_Batch_NUMB,
      @An_SeqReceipt_NUMB            = @An_SeqReceipt_NUMB,
      @Ad_Receipt_DATE               = @Ad_Receipt_DATE,
      @An_TransactionCs_AMNT         = @Ln_PaidCgTot_AMNT,
      @An_TransactionPaa_AMNT        = 0,
      @Ac_TypeHold_CODE              = @Lc_RegularHold_CODE,
      @Ac_TypeDisburse_CODE          = @Lc_DisbursementTypeGrant_CODE,
      @Ac_TypeDisbursementDhld_CODE  = @Ac_TypeDisbursementDhld_CODE,
      @Ac_ProcessOffset_INDC         = @Lc_Yes_INDC,
      @Ac_Status_CODE                = @Lc_DisbursementStatusRelease_CODE,
      @Ac_Reason_CODE                = @Lc_ReasonStatusDr_CODE,
      @An_EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB,
      @An_EventGlobalSeq_NUMB        = @An_EventGlobalSeq_NUMB,
      @Ac_CheckRecipient_ID          = @Ac_CheckRecipient_ID,
      @Ac_CheckRecipient_CODE        = @Ac_CheckRecipient_CODE,
      @Ac_SourceReceipt_CODE         = @Ac_SourceReceipt_CODE,
      @Ac_Msg_CODE                   = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT      = @Ls_ErrorMessage_TEXT OUTPUT,
      @Ad_Process_DATE               = @Ad_Process_DATE OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Lc_DistWcaseFlag_INDC = @Lc_No_INDC;
   
   SET @Ls_Sql_TEXT = 'SELECT_#EsemDist_P1';   
   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityWcase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'');

   SELECT TOP 1 @Lc_DistWcaseFlag_INDC = @Lc_Yes_INDC
     FROM #EsemDist_P1 e
    WHERE e.TypeEntity_CODE = @Lc_EntityWcase_TEXT
      AND e.Entity_ID = @An_CaseWelfare_IDNO;

   SET @Ls_Sql_TEXT = 'SELECT @Ln_EsemDistCount_QNTY';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_EsemDistCount_QNTY = COUNT (1) + 1
     FROM #EsemDist_P1 e;

   IF @Lc_DistWcaseFlag_INDC = @Lc_No_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT #EsemDist_P1 -1';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityWcase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityWcase_TEXT,   --TypeEntity_CODE
                  @An_CaseWelfare_IDNO  --Entity_ID
					);
    END

   IF @Ln_PaidCgTot_AMNT > 0
       OR @Ln_PaidPgTot_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_VIVMG';     
     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL('0','')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', TypeAdjust_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', AdjustLtdFlag_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Defra_AMNT = ' + ISNULL('0','')+ ', CpMci_IDNO = ' + ISNULL(CAST( @An_CpMci_IDNO AS VARCHAR ),'');

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
     (SELECT @An_CaseWelfare_IDNO AS CaseWelfare_IDNO,
             a.WelfareYearMonth_NUMB,
             @Lc_WelfareTypeTanf_CODE AS WelfareElig_CODE,
             a.MtdAssistExpend_AMNT,
             0 AS TransactionAssistExpend_AMNT,
             a.LtdAssistExpend_AMNT,
             @Ln_PaidCgTot_AMNT + CASE @Ln_ProcessWelfareYearMonth_NUMB
                                   WHEN a.WelfareYearMonth_NUMB
                                    THEN @Ln_PaidPgTot_AMNT
                                   ELSE 0
                                  END AS TransactionAssistRecoup_AMNT,
             a.MtdAssistRecoup_AMNT + CASE @Ln_ReceiptWelfareYearMonth_NUMB
                                       WHEN a.WelfareYearMonth_NUMB
                                        THEN
                                        CASE SIGN (a.MtdAssistExpend_AMNT - (a.MtdAssistRecoup_AMNT + @Ln_PaidCgTot_AMNT))
                                         WHEN -1
                                          THEN a.MtdAssistExpend_AMNT - a.MtdAssistRecoup_AMNT
                                         ELSE @Ln_PaidCgTot_AMNT
                                        END
                                       ELSE 0
                                      END AS MtdAssistRecoup_AMNT,
             a.LtdAssistRecoup_AMNT + @Ln_PaidCgTot_AMNT + CASE @Ln_ProcessWelfareYearMonth_NUMB
                                                            WHEN a.WelfareYearMonth_NUMB
                                                             THEN @Ln_PaidPgTot_AMNT
                                                            ELSE 0
                                                           END AS LtdAssistRecoup_AMNT,
             @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
             a.ZeroGrant_INDC,
             @Lc_Space_TEXT AS TypeAdjust_CODE,
             @Lc_Space_TEXT AS AdjustLtdFlag_INDC,
             0 AS Defra_AMNT,
             @An_CpMci_IDNO AS CpMci_IDNO
        FROM IVMG_Y1 a
       WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
         AND a.WelfareYearMonth_NUMB BETWEEN @Ln_ReceiptWelfareYearMonth_NUMB AND @Ln_ProcessWelfareYearMonth_NUMB
         AND a.WelfareElig_CODE = @Lc_WelfareTypeTanf_CODE
         AND a.CpMci_IDNO = @An_CpMci_IDNO
         AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB) 
                                        FROM IVMG_Y1 b
                                       WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                         AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                         AND b.CpMci_IDNO = @An_CpMci_IDNO
                                         AND b.WelfareElig_CODE = a.WelfareElig_CODE));
    END

   SET @Lc_DistWcaseFlag_INDC = @Lc_No_INDC;
   SET @Ls_Sql_TEXT = 'INSERT #EsemDist_P1 -2';   
   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityWcase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'');

   SELECT TOP 1 @Lc_DistWcaseFlag_INDC = @Lc_Yes_INDC
     FROM #EsemDist_P1 e
    WHERE e.TypeEntity_CODE = @Lc_EntityWcase_TEXT
      AND e.Entity_ID = @An_CaseWelfare_IDNO;

   SET @Ls_Sql_TEXT = 'INSERT #EsemDist_P1 -3';   
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_EsemDistCount_QNTY = COUNT (1) + 1
     FROM #EsemDist_P1 e;

   IF @Lc_DistWcaseFlag_INDC = @Lc_No_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT #EsemDist_P1 -2';     
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EntityWcase_TEXT,'')+ ', Entity_ID = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'');

     INSERT INTO #EsemDist_P1
                 (TypeEntity_CODE,
                  Entity_ID)
          VALUES (@Lc_EntityWcase_TEXT,   --TypeEntity_CODE
                  @An_CaseWelfare_IDNO  --Entity_ID
				);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('Local', 'AllWemo_CUR') IN (0, 1)
    BEGIN
     CLOSE AllWemo_CUR;

     DEALLOCATE AllWemo_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
   
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
