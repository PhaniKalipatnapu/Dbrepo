/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD
Programmer Name 	: IMP Team
Description			: This Procedure inserts the Distributed RCTH_Y1 to the DHLD_Y1 (DHLD_Y1) Table
					  for the Disbursement Batch to pick these RCTH_Y1 for Disbursing.
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ad_Receipt_DATE          DATE,
 @Ac_SourceReceipt_CODE    CHAR(2),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT                           CHAR (1) = ' ',
           @Lc_Yes_INDC                             CHAR (1) = 'Y',
           @Lc_TypeRecordOriginal_CODE              CHAR (1) = 'O',
           @Lc_StatusSuccess_CODE                   CHAR (1) = 'S',
           @Lc_TypeWelfareNonTanf_CODE              CHAR (1) = 'N',
           @Lc_TypeWelfareMedicaid_CODE             CHAR (1) = 'M',
           @Lc_TypeWelfareFosterCare_CODE           CHAR (1) = 'J',
           @Lc_TypeWelfareNonIvd_CODE               CHAR (1) = 'H',
           @Lc_RecipientTypeOthp_CODE               CHAR (1) = '3',
           @Lc_TypeWelfareTanf_CODE                 CHAR (1) = 'A',
           @Lc_TypeWelfareNonIve_CODE               CHAR (1) = 'F',
           @Lc_StatusFailed_CODE                    CHAR (1) = 'F',
           @Lc_HoldDisbursement_CODE                CHAR (1) = 'H',
           @Lc_HoldDisbursementType_CODE            CHAR (1) = 'D',
           @Lc_ReleaseDisbursement_CODE             CHAR (1) = 'R',
           @Lc_SourceReceiptSpecialCollection_CODE  CHAR (2) = 'SC',
           @Lc_SourceReceiptInterstativdfee_CODE    CHAR (2) = 'FF',
           @Lc_DisbursementStatusSdtb_CODE          CHAR (4) = 'SDTB',
           @Lc_DisbursementStatusSddr_CODE          CHAR (4) = 'SDDR',
           @Lc_TypeDisburseAhpaa_CODE               CHAR (5) = 'AHPAA',
           @Lc_TypeDisburseAhtaa_CODE               CHAR (5) = 'AHTAA',
           @Lc_TypeDisburseAhcaa_CODE               CHAR (5) = 'AHCAA',
           @Lc_TypeDisburseAhive_CODE               CHAR (5) = 'AHIVE',
           @Lc_TypeDisburseAznaa_CODE               CHAR (5) = 'AZNAA',
           @Lc_TypeDisburseAzuda_CODE               CHAR (5) = 'AZUDA',
           @Lc_TypeDisburseAzupa_CODE               CHAR (5) = 'AZUPA',
           @Lc_TypeDisburseAznfc_CODE               CHAR (5) = 'AZNFC',
           @Lc_TypeDisburseAzniv_CODE               CHAR (5) = 'AZNIV',
           @Lc_TypeDisburseAzmed_CODE               CHAR (5) = 'AZMED',
           @Lc_TypeDisburseCzmed_CODE               CHAR (5) = 'CZMED',
           @Lc_TypeDisburseCznaa_CODE               CHAR (5) = 'CZNAA',
           @Lc_TypeDisburseCznfc_CODE               CHAR (5) = 'CZNFC',
           @Lc_TypeDisburseCzniv_CODE               CHAR (5) = 'CZNIV',
           @Lc_TypeDisburseAzcaa_CODE               CHAR (5) = 'AZCAA',
           @Lc_TypeDisburseChpaa_CODE               CHAR (5) = 'CHPAA',
           @Lc_TypeDisburseChive_CODE               CHAR (5) = 'CHIVE',
           @Lc_CheckRecipientMedi_ID                CHAR (10) = '999999982',
           @Lc_CheckRecipientIve_ID                 CHAR (10) = '999999993',
           @Lc_InterstateRecoveryRecp_ID            CHAR (10) = '999999980',
           @Ls_Procedure_NAME                       VARCHAR (100) = 'BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_DHLD',
           @Ld_High_DATE                            DATE = '12/31/9999',
           @Ld_Low_DATE                             DATE = '01/01/0001';
  DECLARE  @Ln_Error_NUMB         NUMERIC (11),
           @Ln_ErrorLine_NUMB     NUMERIC (11),
           @Ls_Sql_TEXT           VARCHAR (100) = '',
           @Ls_Sqldata_TEXT       VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR (4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = '';

   IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 1';     --001
	 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');
     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionPaa_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAhpaa_CODE AS TypeDisburse_CODE,
            @Lc_HoldDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSdtb_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionPaa_AMNT > 0;

     --002
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 2';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionTaa_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAhtaa_CODE AS TypeDisburse_CODE,
            @Lc_HoldDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSdtb_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionTaa_AMNT > 0;

     --003
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 3';     
	 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionCaa_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAhcaa_CODE AS TypeDisburse_CODE,
            @Lc_HoldDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSdtb_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionCaa_AMNT > 0;

     --004
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 4';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionIvef_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAhive_CODE AS TypeDisburse_CODE,
            --@Lc_ReleaseDisbursement_CODE, @Lc_HoldDisbursementType_CODE,
            -- IRS Money distributed towards the Foster Care Arrears should stay on Disbursement hold until the
            -- FC Distribution runs in the middle of the Month
            @Lc_HoldDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Receipt_DATE) + 1 AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSdtb_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionIvef_AMNT > 0;

     --005
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 5';     
	 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionNaa_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAznaa_CODE AS TypeDisburse_CODE,
            @Lc_ReleaseDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionNaa_AMNT > 0;

     --006
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 6';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionUda_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAzuda_CODE AS TypeDisburse_CODE,
            @Lc_ReleaseDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionUda_AMNT > 0;

     --007
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 7';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionUpa_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAzupa_CODE AS TypeDisburse_CODE,
            @Lc_ReleaseDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionUpa_AMNT > 0;

     --008
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 8';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionNffc_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAznfc_CODE AS TypeDisburse_CODE,
            @Lc_ReleaseDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionNffc_AMNT > 0;

     --009
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 9';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionNonIvd_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAzniv_CODE AS TypeDisburse_CODE,
            @Lc_ReleaseDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionNonIvd_AMNT > 0;

     --010
     SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1  - IR - 10';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

     INSERT INTO DHLD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  Batch_DATE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  SourceBatch_CODE,
                  Transaction_DATE,
                  Transaction_AMNT,
                  TypeDisburse_CODE,
                  Status_CODE,
                  TypeHold_CODE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  Release_DATE,
                  ProcessOffset_INDC,
                  ReasonStatus_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  EventGlobalSupportSeq_NUMB,
                  Disburse_DATE,
                  DisburseSeq_NUMB,
                  StatusEscheat_DATE,
                  StatusEscheat_CODE)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            @Ad_Process_DATE AS Transaction_DATE,
            a.TransactionMedi_AMNT AS Transaction_AMNT,
            @Lc_TypeDisburseAzmed_CODE AS TypeDisburse_CODE,
            @Lc_ReleaseDisbursement_CODE AS Status_CODE,
            @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
            ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT) AS CheckRecipient_ID,
            ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT) AS CheckRecipient_CODE,
            @Ad_Receipt_DATE AS Release_DATE,
            @Lc_Yes_INDC AS ProcessOffset_INDC,
            @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
            @Ld_Low_DATE AS Disburse_DATE,
            0 AS DisburseSeq_NUMB,
            @Ld_Low_DATE AS StatusEscheat_DATE,
            @Lc_Space_TEXT AS StatusEscheat_CODE
       FROM LSUP_Y1 a
      WHERE a.Batch_DATE = @Ad_Batch_DATE
        AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND a.Batch_NUMB = @An_Batch_NUMB
        AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
        AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
        AND a.TransactionMedi_AMNT > 0;

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @As_DescriptionError_TEXT = '';

     RETURN;
    END

   -- 001
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 1';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionCurSup_AMNT AS Transaction_AMNT,
          CASE SIGN (a.TransactionMedi_AMNT)
           WHEN 1
            THEN @Lc_TypeDisburseCzmed_CODE
           ELSE
            CASE a.TypeWelfare_CODE
             WHEN @Lc_TypeWelfareNonTanf_CODE
              THEN @Lc_TypeDisburseCznaa_CODE
             WHEN @Lc_TypeWelfareMedicaid_CODE
              THEN @Lc_TypeDisburseCznaa_CODE
             WHEN @Lc_TypeWelfareFosterCare_CODE
              THEN @Lc_TypeDisburseCznfc_CODE
             WHEN @Lc_TypeWelfareNonIvd_CODE
              THEN @Lc_TypeDisburseCzniv_CODE
            END
          END AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE SIGN (a.TransactionMedi_AMNT)
           WHEN 1
            THEN @Lc_CheckRecipientMedi_ID
           ELSE
            CASE a.TypeWelfare_CODE
             WHEN @Lc_TypeWelfareNonTanf_CODE
              THEN
              CASE @Ac_SourceReceipt_CODE
               WHEN @Lc_SourceReceiptInterstativdfee_CODE
                THEN @Lc_InterstateRecoveryRecp_ID
               ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
              END
             WHEN @Lc_TypeWelfareMedicaid_CODE
              THEN
              CASE @Ac_SourceReceipt_CODE
               WHEN @Lc_SourceReceiptInterstativdfee_CODE
                THEN @Lc_InterstateRecoveryRecp_ID
               ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
              END
             WHEN @Lc_TypeWelfareFosterCare_CODE
              THEN @Lc_CheckRecipientIve_ID
             WHEN @Lc_TypeWelfareNonIvd_CODE
              THEN
              CASE @Ac_SourceReceipt_CODE
               WHEN @Lc_SourceReceiptInterstativdfee_CODE
                THEN @Lc_InterstateRecoveryRecp_ID
               ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
              END
            END
          END AS CheckRecipient_ID,
          CASE SIGN (a.TransactionMedi_AMNT)
           WHEN 1
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE
            CASE @Ac_SourceReceipt_CODE
             WHEN @Lc_SourceReceiptInterstativdfee_CODE
              THEN @Lc_RecipientTypeOthp_CODE
             ELSE
              CASE a.TypeWelfare_CODE
               WHEN @Lc_TypeWelfareNonTanf_CODE
                THEN ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
               WHEN @Lc_TypeWelfareMedicaid_CODE
                THEN ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
               WHEN @Lc_TypeWelfareFosterCare_CODE
                THEN @Lc_RecipientTypeOthp_CODE
               WHEN @Lc_TypeWelfareNonIvd_CODE
                THEN ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
              END
            END
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.TransactionCurSup_AMNT > 0
      AND (a.TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareFosterCare_CODE, @Lc_TypeWelfareNonIvd_CODE)
            OR a.TransactionMedi_AMNT > 0);

   --002
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 2';   
   SET @Ls_Sqldata_TEXT = 'Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_TypeDisburseAznaa_CODE,'')+ ', Status_CODE = ' + ISNULL(@Lc_ReleaseDisbursement_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_HoldDisbursementType_CODE,'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_DisbursementStatusSddr_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionNaa_AMNT - CASE
                                   WHEN a.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                                    THEN a.TransactionCurSup_AMNT
                                   WHEN (a.TypeWelfare_CODE = @Lc_TypeWelfareMedicaid_CODE)
                                        AND (o.TypeDebt_CODE <> 'MS')
                                    THEN a.TransactionCurSup_AMNT
                                   ELSE 0
                                  END AS Transaction_AMNT,
          @Lc_TypeDisburseAznaa_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a,
          OBLE_Y1 o
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.Case_IDNO = o.Case_IDNO
      AND a.OrderSeq_NUMB = o.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = o.ObligationSeq_NUMB
      AND o.EndValidity_DATE = @Ld_High_DATE
      AND o.BeginObligation_DATE = (SELECT MAX (BeginObligation_DATE)
                                      FROM OBLE_Y1 e
                                     WHERE e.Case_IDNO = o.Case_IDNO
                                       AND e.OrderSeq_NUMB = o.OrderSeq_NUMB
                                       AND e.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                       AND e.BeginObligation_DATE <= dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Process_DATE)
                                       --AND e.BeginObligation_DATE <= DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@Ad_Process_DATE)+1,0))
                                       AND e.EndValidity_DATE = @Ld_High_DATE)
      AND (a.TransactionNaa_AMNT - CASE
                                    WHEN a.TypeWelfare_CODE = @Lc_TypeWelfareNonTanf_CODE
                                     THEN a.TransactionCurSup_AMNT
                                    WHEN a.TypeWelfare_CODE = @Lc_TypeWelfareMedicaid_CODE
                                         AND (o.TypeDebt_CODE <> 'MS')
                                     THEN a.TransactionCurSup_AMNT
                                    WHEN a.TypeWelfare_CODE = @Lc_TypeWelfareNonIvd_CODE
                                     THEN a.TransactionCurSup_AMNT
                                    WHEN a.TypeWelfare_CODE = @Lc_TypeWelfareFosterCare_CODE
                                     THEN a.TransactionCurSup_AMNT
                                    ELSE 0
                                   END) > 0;

   --003
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 3';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionUpa_AMNT AS Transaction_AMNT,
          @Lc_TypeDisburseAzupa_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.TransactionUpa_AMNT > 0;

   --004
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 4';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionUda_AMNT AS Transaction_AMNT,
          @Lc_TypeDisburseAzuda_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.TransactionUda_AMNT > 0;

   --005
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 5';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          (a.TransactionMedi_AMNT - TransactionCurSup_AMNT) AS Transaction_AMNT,
          @Lc_TypeDisburseAzmed_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          @Lc_CheckRecipientMedi_ID AS CheckRecipient_ID,
          @Lc_RecipientTypeOthp_CODE AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND (a.TransactionMedi_AMNT - TransactionCurSup_AMNT) > 0;

   --006
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 6';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionCaa_AMNT AS Transaction_AMNT,
          @Lc_TypeDisburseAzcaa_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.TransactionCaa_AMNT > 0;

   --007
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 7';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareFosterCare_CODE
            THEN a.TransactionNffc_AMNT - a.TransactionCurSup_AMNT
           ELSE a.TransactionNffc_AMNT
          END AS Transaction_AMNT,
          @Lc_TypeDisburseAznfc_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          @Lc_CheckRecipientIve_ID AS CheckRecipient_ID,
          @Lc_RecipientTypeOthp_CODE AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareFosterCare_CODE
            THEN a.TransactionNffc_AMNT - a.TransactionCurSup_AMNT
           ELSE a.TransactionNffc_AMNT
          END > 0;

   --008
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 8';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareNonIvd_CODE
            THEN a.TransactionNonIvd_AMNT - TransactionCurSup_AMNT
           ELSE a.TransactionNonIvd_AMNT
          END AS Transaction_AMNT,
          @Lc_TypeDisburseAzniv_CODE AS TypeDisburse_CODE,
          @Lc_ReleaseDisbursement_CODE AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          @Lc_DisbursementStatusSddr_CODE AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareNonIvd_CODE
            THEN a.TransactionNonIvd_AMNT - TransactionCurSup_AMNT
           ELSE a.TransactionNonIvd_AMNT
          END > 0;

   --009
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 9';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionCurSup_AMNT AS Transaction_AMNT,
          CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareTanf_CODE
            THEN @Lc_TypeDisburseChpaa_CODE
           WHEN @Lc_TypeWelfareNonIve_CODE
            THEN @Lc_TypeDisburseChive_CODE
          END AS TypeDisburse_CODE,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_ReleaseDisbursement_CODE
           ELSE @Lc_HoldDisbursement_CODE
          END AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareNonIve_CODE
            THEN dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Receipt_DATE) + 1
           ELSE @Ad_Receipt_DATE
          END AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_DisbursementStatusSddr_CODE
           ELSE @Lc_DisbursementStatusSdtb_CODE
          END AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.TransactionMedi_AMNT = 0
      AND CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareTanf_CODE
            THEN a.TransactionCurSup_AMNT
           WHEN @Lc_TypeWelfareNonIve_CODE
            THEN a.TransactionCurSup_AMNT
           ELSE 0
          END > 0;

   --010
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 10';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionPaa_AMNT - CASE a.TypeWelfare_CODE
                                   WHEN @Lc_TypeWelfareTanf_CODE
                                    THEN a.TransactionCurSup_AMNT
                                   ELSE 0
                                  END AS Transaction_AMNT,
          @Lc_TypeDisburseAhpaa_CODE AS TypeDisburse_CODE,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_ReleaseDisbursement_CODE
           ELSE @Lc_HoldDisbursement_CODE
          END AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Receipt_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_DisbursementStatusSddr_CODE
           ELSE @Lc_DisbursementStatusSdtb_CODE
          END AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareTanf_CODE
            THEN a.TransactionPaa_AMNT - a.TransactionCurSup_AMNT
           ELSE a.TransactionPaa_AMNT
          END > 0;

   --011
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 11';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionTaa_AMNT AS Transaction_AMNT,
          @Lc_TypeDisburseAhtaa_CODE AS TypeDisburse_CODE,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_ReleaseDisbursement_CODE
           ELSE @Lc_HoldDisbursement_CODE
          END AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          @Ad_Receipt_DATE AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_DisbursementStatusSddr_CODE
           ELSE @Lc_DisbursementStatusSdtb_CODE
          END AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND a.TransactionTaa_AMNT > 0;

   --012
   SET @Ls_Sql_TEXT = ' INSERT_DHLD_Y1 2 - 12';   
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR),'') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL (SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6), '') + ', TypeRecord_CODE = ' + @Lc_TypeRecordOriginal_CODE + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                TypeDisburse_CODE,
                Status_CODE,
                TypeHold_CODE,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                Release_DATE,
                ProcessOffset_INDC,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.Batch_DATE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          a.SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          a.TransactionIvef_AMNT - CASE a.TypeWelfare_CODE
                                    WHEN @Lc_TypeWelfareNonIve_CODE
                                     THEN a.TransactionCurSup_AMNT
                                    ELSE 0
                                   END AS Transaction_AMNT,
          @Lc_TypeDisburseAhive_CODE AS TypeDisburse_CODE,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_ReleaseDisbursement_CODE
           ELSE @Lc_HoldDisbursement_CODE
          END AS Status_CODE,
          @Lc_HoldDisbursementType_CODE AS TypeHold_CODE,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_InterstateRecoveryRecp_ID
           ELSE ISNULL (a.CheckRecipient_ID, @Lc_Space_TEXT)
          END AS CheckRecipient_ID,
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_RecipientTypeOthp_CODE
           ELSE ISNULL (a.CheckRecipient_CODE, @Lc_Space_TEXT)
          END AS CheckRecipient_CODE,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Ad_Receipt_DATE
           ELSE dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Receipt_DATE) + 1
          END AS Release_DATE,
          @Lc_Yes_INDC AS ProcessOffset_INDC,
          -- Interstate IVD Fee RCTH_Y1 distributed towards OSR Check Recipient need not wait for
          -- the Foster Care Distribution to run and can be released immediately
          CASE @Ac_SourceReceipt_CODE
           WHEN @Lc_SourceReceiptInterstativdfee_CODE
            THEN @Lc_DisbursementStatusSddr_CODE
           ELSE @Lc_DisbursementStatusSdtb_CODE
          END AS ReasonStatus_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          a.EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          a.EventGlobalSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_Low_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
     FROM LSUP_Y1 a
    WHERE a.Batch_DATE = @Ad_Batch_DATE
      AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND a.Batch_NUMB = @An_Batch_NUMB
      AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
      AND a.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
      AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
      AND CASE a.TypeWelfare_CODE
           WHEN @Lc_TypeWelfareNonIve_CODE
            THEN a.TransactionIvef_AMNT - a.TransactionCurSup_AMNT
           ELSE a.TransactionIvef_AMNT
          END > 0;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  
  END CATCH
 END


GO
