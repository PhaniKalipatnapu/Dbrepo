/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_BACKOUT_PROCESS_RREP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
----------------------------------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_COMMON$SP_BACKOUT_PROCESS_RREP
 Programmer Name	: IMP Team
 Description		: This SP is used to reverse the receipt for the all complete
					  list of valid receipts which have not been reversed and inquired
					  for the Payor DCN / Date Range option, the Case ID / Date Range or
					  the Receipt /Trans option given. 
 Frequency			:
 Developed On		: 04/12/2011
 Called By			: RREP
 Called On			:
----------------------------------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No		    :  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_BACKOUT_PROCESS_RREP] (
 @Ac_Session_ID            CHAR(30),
 @Ac_Sval_INDC             CHAR(1),
 @Ac_ReasonBackOut_CODE    CHAR(2),
 @As_DateRange_TEXT        VARCHAR(4000),
 @Ac_Process_ID            CHAR(10),
 @As_Notes_TEXT            VARCHAR(2000),
 @Ad_Process_DATE          DATE,
 @Ac_SignedOnWorker_ID     CHAR(30),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  CREATE TABLE [#RrepWelfare_P1]
   (
     [CaseWelfare_IDNO]      [NUMERIC](10, 0) NOT NULL,
     [WelfareYearMonth_NUMB] [NUMERIC](6, 0) NOT NULL,
     [MtdRecoupTanf_AMNT]    [NUMERIC](11, 2) NOT NULL,
     [LtdRecoupTanf_AMNT]    [NUMERIC](11, 2) NOT NULL,
     [MtdRecoupFc_AMNT]      [NUMERIC](11, 2) NOT NULL,
     [LtdRecoupFc_AMNT]      [NUMERIC](11, 2) NOT NULL
   );

  CREATE TABLE [#RrepOffsetOverride_P1]
   (
     [Case_IDNO]            [NUMERIC](6, 0),
     [CheckRecipient_ID]    [CHAR](10),
     [CheckRecipient_CODE]  [CHAR](1),
     [RecOvpyOrig_AMNT]     [NUMERIC](11, 2),
     [PaidToCpOrig_AMNT]    [NUMERIC](11, 2),
     [TypeDisburse_CODE]    [CHAR](5),
     [TypeRecoupment_CODE]  [CHAR](1),
     [RecoupmentPayee_CODE] [CHAR](1),
   );

  CREATE TABLE [#RrepProrate_P1]
   (
     [WelfareYearMonth_NUMB]    [NUMERIC] (6, 0),
     [Case_IDNO]                [NUMERIC](6, 0),
     [OrderSeq_NUMB]            [NUMERIC](2, 0),
     [ObligationSeq_NUMB]       [NUMERIC](2, 0),
     [CaseWelfare_IDNO]         [NUMERIC](10, 0),
     [ArrToBePaid_AMNT]         [NUMERIC](11, 2),
     [PerMemberProrated_AMNT]   [NUMERIC](11, 2),
     [PerMemberRecoupment_AMNT] [NUMERIC](11, 2),
     [MemberUnreimbGrant_AMNT]  [NUMERIC](11, 2)
   );

  CREATE TABLE [#RrepPaidRecoup_P1]
   (
     [WelfareYearMonth_NUMB] [NUMERIC] (6, 0),
     [Case_IDNO]             [NUMERIC](6, 0),
     [OrderSeq_NUMB]         [NUMERIC](2, 0),
     [ObligationSeq_NUMB]    [NUMERIC](2, 0),
     [CaseWelfare_IDNO]      [NUMERIC](10, 0),
     [ArrPaid_AMNT]          [NUMERIC](11, 2),
     [Rounded_AMNT]          [NUMERIC](11, 2),
     [RoundedRecoup_AMNT]    [NUMERIC](11, 2),
     [ArrToBePaid_AMNT]      [NUMERIC](11, 2),
     [ArrRecoupMtd_AMNT]     [NUMERIC](11, 2)
   );

  CREATE TABLE [#RrepCpFeeTrans_P1]
   (
     [MemberMci_IDNO]    [NUMERIC](10, 0),
     [Case_IDNO]         [NUMERIC](6, 0),
     [FeeType_CODE]      [CHAR](2),
     [Transaction_CODE]  [CHAR](4),
     [Transaction_AMNT]  [NUMERIC](11, 2),
     [AssessedYear_NUMB] [NUMERIC](4, 0)
   );

  DECLARE  @Li_RrepReversalRepost1260_NUMB               INT = 1260,
           @Li_ReceiptReversed1250_NUMB                  INT = 1250,
           @Li_RePostAReceipt1310_NUMB                   INT = 1310,
		   @Li_RefundAReceipt1220_NUMB                   INT = 1220,
           @Li_ObligationCreation1010_NUMB               INT = 1010,
           @Li_CircularRuleRecord1070_NUMB				 INT = 1070,
		   @Li_ManuallyDistributeReceipt1810_NUMB		 INT = 1810,
	   	   @Li_ReceiptDistributed1820_NUMB				 INT = 1820,
	   	   @Li_DirectPayCredit1040_NUMB					 INT = 1040,
           @Lc_Space_TEXT                                CHAR(1) = ' ',
           @Lc_Hyphen_TEXT                               CHAR(1) = '-',
           @Lc_TypeRecordOriginal_CODE                   CHAR(1) = 'O',
           @Lc_Yes_INDC                                  CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE                         CHAR(1) = 'F',
           @Lc_CaseRelationshipNcp_CODE                  CHAR(1) = 'A',
           @Lc_CaseRelationshipPf_CODE                   CHAR(1) = 'P',
           @Lc_No_INDC                                   CHAR(1) = 'N',
           @Lc_StatusReceiptUnidentified_CODE            CHAR(1) = 'U',
           @Lc_StatusReceiptIdentified_CODE              CHAR(1) = 'I',
		   @Lc_StatusReceiptRefund_CODE					 CHAR(1) = 'R',
           @Lc_TypeWelfareTanf_CODE                      CHAR(1) = 'A',
           @Lc_TypeRecoupmentRegular_CODE                CHAR(1) = 'R',
           @Lc_RecoupmentPayeeState_CODE                 CHAR(1) = 'S',
           @Lc_ActiveRecoupmentA_CODE                    CHAR(1) = 'A',
		   @Lc_PendingRecoupmentP_CODE                   CHAR(1) = 'P',
		   @Lc_StatusMatchApproved_CODE					 CHAR(1) = 'A',
           @Lc_StatusBatchReconciled_CODE				 CHAR(1) = 'R',
           @Lc_RecipientTypeFips_CODE                    CHAR(1) = '2',
           @Lc_TypeWelfareNonTanf_CODE                   CHAR(1) = 'N',
           @Lc_TypeWelfareMedicaid_CODE                  CHAR(1) = 'M',
           @Lc_TypeRecordPrior_CODE                      CHAR(1) = 'P',
           @Lc_CaseRelationshipCp_CODE                   CHAR(1) = 'C',
           @Lc_CaseMemberStatusActive_CODE               CHAR(1) = 'A',
           @Lc_StatusCaseMemberInactive_CODE             CHAR(1) = 'I',
           @Lc_RecipientTypeOthp_CODE                    CHAR(1) = '3',
           @Lc_TypeOthpFeeRecipient1_CODE                CHAR(1) = '1',
           @Lc_TypePostingCase_CODE                      CHAR(1) = 'C',
           @Lc_TypePostingPayor_CODE                     CHAR(1) = 'P',
           @Lc_StatusSuccess_CODE                        CHAR(1) = 'S',
           @Lc_RecipientTypeCpNcp_CODE                   CHAR(1) = '1',
           @Lc_FreqPeriodicOneTime_CODE                  CHAR(1) = 'O',
           @Lc_CaseStatusOpen_CODE                       CHAR(1) = 'O',
           @Lc_CaseRelationshipDp_CODE                   CHAR(1) = 'D',
           @Lc_DebtTypeMedicaid_CODE                     CHAR(2) = 'DS',
           @Lc_DebtTypeIntMedicaid_CODE                  CHAR(2) = 'DI',
           @Lc_DebtTypeCashMedical_CODE                  CHAR(2) = 'CM',
           @Lc_DebtTypeIntCashMedical_CODE               CHAR(2) = 'HI',
           @Lc_InStateFips_CODE                          CHAR(2) = '10',
           @Lc_DisburseStatusOutstanding_CODE            CHAR(2) = 'OU',
           @Lc_DisburseStatusTransferEft_CODE            CHAR(2) = 'TR',
           @Lc_DisburseStatusCashed_CODE                 CHAR(2) = 'CA',
           @Lc_ValueDp_CODE                              CHAR(2) = 'DP',
           @Lc_ValueCp_CODE                              CHAR(2) = 'CP',
           @Lc_ValueFp_CODE                              CHAR(2) = 'FP',
           @Lc_ValueMp_CODE                              CHAR(2) = 'MP',
           @Lc_ValuePp_CODE                              CHAR(2) = 'PP',
           @Lc_ValueSp_CODE                              CHAR(2) = 'SP',
           @Lc_ValueAf_CODE                              CHAR(2) = 'AF',
           @Lc_ValueBf_CODE                              CHAR(2) = 'BF',
           @Lc_ValueCf_CODE                              CHAR(2) = 'CF',
           @Lc_ValueMf_CODE                              CHAR(2) = 'MF',
           @Lc_SourceReceiptBailBa_CODE                  CHAR(2) = 'BA',
           @Lc_SourceReceiptBondBn_CODE                  CHAR(2) = 'BN',
           @Lc_SourceReceiptCpRecoupmentCr_CODE          CHAR(2) = 'CR',
           @Lc_SourceReceiptCpFeePaymentCf_CODE          CHAR(2) = 'CF',
           @Lc_SourceReceiptLumpSumLs_CODE               CHAR(2) = 'LS',
           @Lc_SourceReceiptPurgePaymentPm_CODE          CHAR(2) = 'PM',
           @Lc_SourceReceiptNsfRecoupmentNr_CODE         CHAR(2) = 'NR',
           @Lc_SourceReceiptQdroPaymentQr_CODE           CHAR(2) = 'QR',
           @Lc_SourceReceiptRegularRe_CODE               CHAR(2) = 'RE',
           @Lc_SourceReceiptVoluntaryVn_CODE             CHAR(2) = 'VN',
           @Lc_SourceReceiptAdmnOffsetRetirementAr_CODE  CHAR(2) = 'AR',
           @Lc_SourceReceiptAdmnOffsetSalaryAs_CODE      CHAR(2) = 'AS',
           @Lc_SourceReceiptAdmnOffsetVendorPymtAv_CODE  CHAR(2) = 'AV',
           @Lc_SourceReceiptSpcFullCollectionFc_CODE     CHAR(2) = 'FC',
           @Lc_SourceReceiptSpecialCollectionSc_CODE     CHAR(2) = 'SC',
           @Lc_SourceReceiptStateTaxOffsetSt_CODE        CHAR(2) = 'ST',
           @Lc_TypeDebtNf_CODE                           CHAR(2) = 'NF',
           @Lc_FeeTypeNs_CODE                            CHAR(2) = 'NS',
           @Lc_FeeTypeDr_CODE                            CHAR(2) = 'DR',
           @Lc_ReasonBackOutAccountClosedAc_CODE         CHAR(2) = 'AC',
           @Lc_ReasonBackOutNsfNf_CODE                   CHAR(2) = 'NF',
           @Lc_ReasonBackOutReferToMakerRm_CODE          CHAR(2) = 'RM',
           @Lc_ReasonBackOutStopPaymentSp_CODE           CHAR(2) = 'SP',
           @Lc_ReasonBackOutUnlocatedAcctUa_CODE         CHAR(2) = 'UA',
           @Lc_ChildSrcDirectPayCredit_CODE              CHAR(3) = 'DCR',
           @Lc_TypeRemittanceChk_CODE                    CHAR(3) = 'CHK',
           @Lc_Case_TEXT                                 CHAR(4) = 'CASE',
           @Lc_Rrep_TEXT                                 CHAR(4) = 'RREP',
           @Lc_Crec_TEXT                                 CHAR(4) = 'CREC',
           @Lc_TransactionSrec_CODE                      CHAR(4) = 'SREC',
           @Lc_TransactionRdcr_CODE                      CHAR(4) = 'RDCR',
           @Lc_TransactionAsmt_CODE                      CHAR(4) = 'ASMT',
           @Lc_TransactionRdca_CODE                      CHAR(4) = 'RDCA',
           @Lc_TransactionBkrc_CODE                      CHAR(4) = 'BKRC',
           @Lc_TransactionBkpe_CODE                      CHAR(4) = 'BKPE',
           @Lc_TypeDisburseCgpaa_CODE                    CHAR(5) = 'CGPAA',
           @Lc_TypeDisburseAgive_CODE                    CHAR(5) = 'AGIVE',
           @Lc_TypeDisburseCgive_CODE                    CHAR(5) = 'CGIVE',
           @Lc_TypeDisbursePgpaa_CODE                    CHAR(5) = 'PGPAA',
           @Lc_TypeDisburseAgpaa_CODE                    CHAR(5) = 'AGPAA',
           @Lc_TypeDisburseAgtaa_CODE                    CHAR(5) = 'AGTAA',
           @Lc_TypeDisburseAgcaa_CODE                    CHAR(5) = 'AGCAA',
           @Lc_TypeDisburseRefund_CODE                   CHAR(5) = 'REFND',
           @Lc_TypeDisburseRothp_CODE                    CHAR(5) = 'ROTHP',
           @Lc_Dtrng_TEXT                                CHAR(5) = 'DTRNG',
           @Lc_Rcode_TEXT                                CHAR(5) = 'RCODE',
           @Lc_Revr_TEXT                                 CHAR(5) = 'REVR',
		   @Lc_BatchRunUser_TEXT						 CHAR(6) = 'BATCH',
           @Lc_DeFips_CODE                               CHAR(7) = '1000000',
           @Lc_CheckRecipientStateNrFee_CODE             CHAR(9) = '999999963',
           @Lc_ReceiptBackedOut_TEXT                     CHAR(30) = 'RCTH_Y1 BACKED OUT',
           @Ls_Routine_TEXT                              VARCHAR(100) = 'BATCH_COMMON$SP_BACKOUT_PROCESS_RREP',
		   @Ls_RefundUnotDescription_TEXT				 VARCHAR(100) ='Refund that was reversed, reposted and recouped by the system',
           @Ld_Low_DATE                                  DATE = '01/01/0001',
           @Ld_High_DATE                                 DATE = '12/31/9999';
  DECLARE  @Ln_RowCount_QNTY                     NUMERIC,
           @Ln_FetchStatus_QNTY                  NUMERIC,
           @Ln_OrderSeq_NUMB                     NUMERIC(2),
           @Ln_ObligationSeq_NUMB                NUMERIC(2),
           @Ln_OrderPrevseq_NUMB                 NUMERIC(2),
           @Ln_ObligationPrevseq_NUMB            NUMERIC(2),
           @Ln_Batch_NUMB                        NUMERIC(4),
           @Ln_Case_IDNO                         NUMERIC(6),
           @Ln_CasePrev_IDNO                     NUMERIC(6),
           @Ln_SupportYearMonth_NUMB             NUMERIC(6),
           @Ln_SupportYearMonthCur_NUMB          NUMERIC(6),
           @Ln_SeqReceipt_NUMB                   NUMERIC(6),
           @Ln_CpflCpNf_Case_IDNO                NUMERIC(6),
           @Ln_PayorMCI_IDNO                     NUMERIC(10),
           @Ln_CasePayorMCI_IDNO                 NUMERIC(10),
           @Ln_AdjustPaa_AMNT                    NUMERIC(11,2),
           @Ln_AdjustNaa_AMNT                    NUMERIC(11,2),
           @Ln_AdjustTaa_AMNT                    NUMERIC(11,2),
           @Ln_AdjustCaa_AMNT                    NUMERIC(11,2),
           @Ln_AdjustUda_AMNT                    NUMERIC(11,2),
           @Ln_AdjustUpa_AMNT                    NUMERIC(11,2),
           @Ln_TransactionPaa_AMNT               NUMERIC(11,2),
           @Ln_AdjustNffc_AMNT                   NUMERIC(11,2),
           @Ln_AdjustNonIvd_AMNT                 NUMERIC(11,2),
           @Ln_OweTotPaa_AMNT                    NUMERIC(11,2),
           @Ln_AppTotPaa_AMNT                    NUMERIC(11,2),
           @Ln_TransactionNaa_AMNT               NUMERIC(11,2),
           @Ln_OweTotNaa_AMNT                    NUMERIC(11,2),
           @Ln_AppTotNaa_AMNT                    NUMERIC(11,2),
           @Ln_TransactionTaa_AMNT               NUMERIC(11,2),
           @Ln_OweTotTaa_AMNT                    NUMERIC(11,2),
           @Ln_AppTotTaa_AMNT                    NUMERIC(11,2),
           @Ln_TransactionCaa_AMNT               NUMERIC(11,2),
           @Ln_OweTotCaa_AMNT                    NUMERIC(11,2),
           @Ln_AppTotCaa_AMNT                    NUMERIC(11,2),
           @Ln_TransactionUda_AMNT               NUMERIC(11,2),
           @Ln_OweTotUda_AMNT                    NUMERIC(11,2),
           @Ln_AppTotUda_AMNT                    NUMERIC(11,2),
           @Ln_TransactionUpa_AMNT               NUMERIC(11,2),
           @Ln_OweTotUpa_AMNT                    NUMERIC(11,2),
           @Ln_AppTotUpa_AMNT                    NUMERIC(11,2),
           @Ln_TransactionCurSup_AMNT            NUMERIC(11,2),
           @Ln_OweTotCurSup_AMNT                 NUMERIC(11,2),
           @Ln_AppTotCurSup_AMNT                 NUMERIC(11,2),
           @Ln_TransactionExptPay_AMNT           NUMERIC(11,2),
           @Ln_OweTotExptPay_AMNT                NUMERIC(11,2),
           @Ln_AppTotExptPay_AMNT                NUMERIC(11,2),
           @Ln_TransactionMedi_AMNT              NUMERIC(11,2),
           @Ln_OweTotMedi_AMNT                   NUMERIC(11,2),
           @Ln_AppTotMedi_AMNT                   NUMERIC(11,2),
           @Ln_TransactionIvef_AMNT              NUMERIC(11,2),
           @Ln_OweTotIvef_AMNT                   NUMERIC(11,2),
           @Ln_AppTotIvef_AMNT                   NUMERIC(11,2),
           @Ln_OweTotNffc_AMNT                   NUMERIC(11,2),
           @Ln_AppTotNffc_AMNT                   NUMERIC(11,2),
           @Ln_TransactionNffc_AMNT              NUMERIC(11,2),
           @Ln_OweTotNonIvd_AMNT                 NUMERIC(11,2),
           @Ln_AppTotNonIvd_AMNT                 NUMERIC(11,2),
           @Ln_TransactionNonIvd_AMNT            NUMERIC(11,2),
           @Ln_TransactionFuture_AMNT            NUMERIC(11,2),
           @Ln_AppTotFuture_AMNT                 NUMERIC(11,2),
           @Ln_MtdCurSupOwed_AMNT                NUMERIC(11,2),
           @Ln_Refund_AMNT                       NUMERIC(11,2) = 0,
		   @Ln_ReceiptNew_AMNT                       NUMERIC(11,2) = 0,
		   @Ln_AssessTotOverpay_AMNT             NUMERIC(11,2),
           @Ln_RecTotOverpay_AMNT                NUMERIC(11,2),
           @Ln_PendTotOffset_AMNT                NUMERIC(11,2),
           @Ln_PendOffset_AMNT                   NUMERIC(11,2),
           @Ln_AssessOverpay_AMNT                NUMERIC(11,2),
           @Ln_ArrPaaCirc_AMNT                   NUMERIC(11,2),
           @Ln_ArrNaaCirc_AMNT                   NUMERIC(11,2),
           @Ln_ArrTaaCirc_AMNT                   NUMERIC(11,2),
           @Ln_ArrCaaCirc_AMNT                   NUMERIC(11,2),
           @Ln_ArrUdaCirc_AMNT                   NUMERIC(11,2),
           @Ln_ArrUpaCirc_AMNT                   NUMERIC(11,2),
           @Ln_ErrorLine_NUMB                    NUMERIC(11),
           @Ln_Error_NUMB						 NUMERIC(11),
           @Ln_CpflPendTransaction_AMNT          NUMERIC(11,2) = 0,
           @Ln_CpflAssessedTot_AMNT              NUMERIC(11,2) = 0,
           @Ln_CpflRecoveredTot_AMNT             NUMERIC(11,2) = 0,
           @Ln_CpflRecoveredTotDr_AMNT           NUMERIC(11,2) = 0,
           @Ln_EventGloablSeqBackOut_NUMB        NUMERIC(19,0),
           @Ln_EventGlobalSeqGrant_NUMB          NUMERIC(19,0),
           @Ln_EventGlobalSeq_NUMB               NUMERIC(19),
           @Ln_EventGlobalBeginSeqLockRcth_NUMB  NUMERIC(19,0),
           @Ln_EventGlobalSeqBrep_NUMB           NUMERIC(19,0),
           @Ln_EventGlobalSeqRcthBackOut_NUMB    NUMERIC(19,0),
           @Ln_EventGlobalSeqLsupBackOut_NUMB    NUMERIC(19,0),
           @Ln_EventGlobalSeqRep_NUMB            NUMERIC(19,0),
		   @Ln_EventGlobalSeqCp_NUMB             NUMERIC(19,0),
           @Ln_EventGlobalRefundSeq_NUMB         NUMERIC(19),
           @Ln_EventGlobalSeqLsupGrant_NUMB      NUMERIC(19,0),
           @Ln_EventGlobalSeqBackOutLsup_NUMB    NUMERIC(19,0),
           @Lc_TypeWelfare_CODE                  CHAR(1),
           @Lc_TypeRecord_CODE                   CHAR(1),
           @Lc_DesnPoint_TEXT                    CHAR(1),
           @Lc_Refund_INDC                       CHAR(1),
           @Lc_RePost_INDC                       CHAR(1),
           @Lc_TypeRecoupment_CODE               CHAR(1),
           @Lc_RecoupmentPayee_CODE              CHAR(1),
           @Lc_CpflInsertFlag_INDC               CHAR(1),
           @Lc_TypeDebt_CODE                     CHAR(2),
           @Lc_SourceReceipt_CODE                CHAR(2),
           @Lc_SourceBatch_CODE                  CHAR(3),
           @Lc_TypeRemittance_CODE               CHAR(3),
           @Lc_Transaction_CODE                  CHAR(4),
           @Lc_CpflTransaction_CODE              CHAR(4),
		   @Lc_ReasonStatus_CODE				 CHAR(4),
           @Lc_TypeReversal_CODE                 CHAR(5),
           @Lc_Fips_CODE                         CHAR(7),
           @Lc_PoflCheckRecipient_CODE           CHAR(9),
           @Lc_PoflCheckRecipient_ID             CHAR(10),
           @Lc_Process_ID                        CHAR(10),
		   @Lc_CheckNo_TEXT						 CHAR(19),
		   @Lc_Receipt_TEXT						 CHAR(30),
           @Ls_Sql_TEXT                          VARCHAR(100),
           @Ls_Sqldata_TEXT                      VARCHAR(500),
           @Ls_ErrorMessage_TEXT                 VARCHAR(4000),
           @Ld_Receipt_DATE                      DATE,
           @Ld_BatchOrig_DATE                    DATE,
           @Ld_Process_DATE                      DATE;

  DECLARE @Ld_PRrepCur_BatchOrig_DATE            DATE,
          @Lc_PRrepCur_SourceBatch_CODE          CHAR(3),
          @Ln_PRrepCur_Batch_NUMB                NUMERIC(4),
          @Ln_PRrepCur_SeqReceipt_NUMB           NUMERIC(6),
          @Ld_PRrepCur_Receipt_DATE              DATE,
          @Ln_PRrepCur_Receipt_AMNT              NUMERIC(11, 2),
          @Lc_PRrepCur_SourceReceipt_CODE        CHAR(2),
          @Lc_PRrepCur_Distd_INDC                CHAR(1),
          @Lc_PRrepCur_Refund_INDC               CHAR(1),
          @Lc_PRrepCur_RePost_INDC               CHAR(1),
          @Lc_PRrepCur_ClosedCase_INDC           CHAR(1),
          @Lc_PRrepCur_MultiCase_INDC            CHAR(1),
          @Ln_PRrepCur_Refund_AMNT               NUMERIC(11, 2),
          @Ln_PRrepCur_CasePayorMCI_IDNO         NUMERIC(10),
          @Ln_PRrepCur_CasePayorMCIReposted_IDNO NUMERIC(10),
          @Ln_PRrepCur_EventGlobalBeginSeq_NUMB  NUMERIC(19),
          @Ln_PRrepCur_PayorMCI_IDNO             NUMERIC(10),
          @Ln_PRrepCur_RepostedPayorMci_IDNO     NUMERIC(10);
  DECLARE @Ln_LsupCur_Case_IDNO               NUMERIC(6),
          @Ln_LsupCur_OrderSeq_NUMB           NUMERIC(2),
          @Ln_LsupCur_ObligationSeq_NUMB      NUMERIC(2),
          @Ln_LsupCur_SupportYearMonth_NUMB   NUMERIC(6),
          @Ln_LsupCur_TransactionCurSup_AMNT  NUMERIC(11, 2),
          @Ln_LsupCur_TransactionExptPay_AMNT NUMERIC(11, 2),
          @Ln_LsupCur_TransactionNaa_AMNT     NUMERIC(11, 2),
          @Ln_LsupCur_TransactionTaa_AMNT     NUMERIC(11, 2),
          @Ln_LsupCur_TransactionPaa_AMNT     NUMERIC(11, 2),
          @Ln_LsupCur_TransactionCaa_AMNT     NUMERIC(11, 2),
          @Ln_LsupCur_TransactionUpa_AMNT     NUMERIC(11, 2),
          @Ln_LsupCur_TransactionUda_AMNT     NUMERIC(11, 2),
          @Ln_LsupCur_TransactionIvef_AMNT    NUMERIC(11, 2),
          @Ln_LsupCur_TransactionMedi_AMNT    NUMERIC(11, 2),
          @Ln_LsupCur_TransactionFuture_AMNT  NUMERIC(11, 2),
          @Ln_LsupCur_TransactionNffc_AMNT    NUMERIC(11, 2),
          @Ln_LsupCur_TransactionNonIvd_AMNT  NUMERIC(11, 2);

  DECLARE @Lc_ReciptCur_CheckRecipient_ID	  CHAR(10),
		  @Lc_ReciptCur_CheckRecipient_CODE   CHAR(1),
		  @Ln_ReceiptCur_Case_IDNO            NUMERIC(6),
		  @Lc_ReceiptCur_TypeDisburse_CODE    CHAR(5),
		  @Lc_ReceiptCur_TypeRecoupment_CODE  CHAR(1),
		  @Lc_ReceiptCur_RecoupmentPayee_CODE CHAR(1),
		  @Ln_ReceiptCur_RecOverpay_AMNT      NUMERIC(11, 2),
		  @Ln_ReceiptCur_AssessOverpay_AMNT   NUMERIC(11, 2);

   DECLARE @Ln_NfObleCase_IDNO             NUMERIC(6),
           @Ln_NfObleOrderSeq_NUMB         NUMERIC(2),
           @Ln_NfObleObligationSeq_NUMB    NUMERIC(2),
           @Ln_NfObleMemberMciDp_NUMB      NUMERIC(10),
           @Ln_NfObleSupportYearMonth_NUMB NUMERIC(6);
   
   DECLARE @Ln_CpflCur_MemberMci_IDNO    NUMERIC(10),
		   @Ln_CpflCur_Case_IDNO         NUMERIC(6),
		   @Lc_CpflCur_FeeType_CODE      CHAR(2),
		   @Lc_CpflCur_Transaction_CODE  CHAR(4),
		   @Ln_CpflCur_Transaction_AMNT  NUMERIC(11, 2),
		   @Ln_CpflCur_AssessedYear_NUMB NUMERIC(4);
           
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'DELETE_RrepWelfare_P1';
   SET @Ls_Sqldata_TEXT  = '';
   
   DELETE #RrepWelfare_P1;

   SET @Ls_Sql_TEXT = 'DELETE_RrepOffsetOverride_P1';
   SET @Ls_Sqldata_TEXT  = '';

   DELETE #RrepOffsetOverride_P1;

   SET @Ls_Sql_TEXT = 'DELETE_RrepProrate_P1';
   SET @Ls_Sqldata_TEXT  = '';

   DELETE #RrepProrate_P1;

   SET @Ls_Sql_TEXT = 'DELETE_RrepPaidRecoup_P1';
   SET @Ls_Sqldata_TEXT  = '';

   DELETE #RrepPaidRecoup_P1;

   SET @Ls_Sql_TEXT = 'DELETE_RrepCpFeeTrans_P1';
   SET @Ls_Sqldata_TEXT  = '';

   DELETE #RrepCpFeeTrans_P1;

   SET @Ld_Process_DATE = ISNULL(@Ad_Process_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Lc_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ FOR RREP';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + CAST(@Li_RrepReversalRepost1260_NUMB AS VARCHAR) + ', Process_ID = ' + @Lc_Process_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Process_DATE AS VARCHAR) + ', Note_INDC = ' + @Lc_Yes_INDC + ', Worker_ID = ' +  @Ac_SignedOnWorker_ID;
   
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_RrepReversalRepost1260_NUMB,
    @Ac_Process_ID              = @Lc_Process_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
    @Ac_Note_INDC               = @Lc_Yes_INDC,
    @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqBrep_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT_RESF_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_ID = ' + ISNULL(@Lc_Rrep_TEXT,'')+ ', Reason_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE,'');

   SELECT @Lc_TypeReversal_CODE = a.Type_CODE
     FROM RESF_Y1 a
    WHERE a.Process_ID = @Lc_Rrep_TEXT
      AND a.Reason_CODE = @Ac_ReasonBackOut_CODE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Lc_TypeReversal_CODE = @Lc_Space_TEXT;
    END

   SET @Ls_Sql_TEXT = 'INSERT_VUNOT';
   SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBrep_NUMB AS VARCHAR ),'')+ ', EventGlobalApprovalSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'');

   INSERT UNOT_Y1
          (EventGlobalSeq_NUMB,
           DescriptionNote_TEXT,
           EventGlobalApprovalSeq_NUMB)
   VALUES ( @Ln_EventGlobalSeqBrep_NUMB,--EventGlobalSeq_NUMB
            ISNULL(@Ac_ReasonBackOut_CODE, '') + ISNULL(@Lc_Hyphen_TEXT, '') + ISNULL(SUBSTRING(@As_Notes_TEXT, 1, 3997), ''),
            --DescriptionNote_TEXT
            0 --EventGlobalApprovalSeq_NUMB
   );

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1 ';
   SET @Ls_Sqldata_TEXT = '';

   INSERT ESEM_Y1
          (Entity_ID,
           TypeEntity_CODE,
           EventFunctionalSeq_NUMB,
           EventGlobalSeq_NUMB)
   SELECT ISNULL(CAST(z.Case_IDNO AS VARCHAR), ''),
          ISNULL(@Lc_Case_TEXT, @Lc_Space_TEXT),
          @Li_RrepReversalRepost1260_NUMB,
          @Ln_EventGlobalSeqBrep_NUMB
     FROM (SELECT a.CasePayorMCI_IDNO AS Case_IDNO
             FROM PRREP_Y1 a
                  JOIN CASE_Y1 b
                   ON b.Case_IDNO = a.CasePayorMCI_IDNO
            WHERE a.Session_ID = @Ac_Session_ID
              AND a.BackOut_INDC = @Lc_Yes_INDC
              AND a.SourceReceipt_CODE IN (SELECT SourceReceipt_CODE
                                             FROM HIMS_Y1 h
                                            WHERE h.EndValidity_DATE = @Ld_High_DATE
                                              AND h.TypePosting_CODE = @Lc_TypePostingCase_CODE)
           UNION
           SELECT c.Case_IDNO AS Case_IDNO
             FROM CMEM_Y1 c
                  JOIN (SELECT DISTINCT
                               a.CasePayorMCI_IDNO
                          FROM PRREP_Y1 a
                               JOIN HIMS_Y1 b
                                ON a.SourceReceipt_CODE = b.SourceReceipt_CODE
                         WHERE a.Session_ID = @Ac_Session_ID
                           AND a.BackOut_INDC = @Lc_Yes_INDC
                           AND b.EndValidity_DATE = @Ld_High_DATE
                           AND b.TypePosting_CODE = @Lc_TypePostingPayor_CODE
                           AND b.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpRecoupmentCr_CODE, @Lc_SourceReceiptCpFeePaymentCf_CODE)) AS d
                   ON c.MemberMci_IDNO = d.CasePayorMCI_IDNO
            WHERE c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
           UNION
           SELECT c.Case_IDNO AS Case_IDNO
             FROM CMEM_Y1 c
                  JOIN (SELECT DISTINCT
                               a.CasePayorMCI_IDNO
                          FROM PRREP_Y1 a
                         WHERE a.Session_ID = @Ac_Session_ID
                           AND a.BackOut_INDC = @Lc_Yes_INDC
                           AND a.SourceReceipt_CODE IN (@Lc_SourceReceiptCpRecoupmentCr_CODE, @Lc_SourceReceiptCpFeePaymentCf_CODE)) AS d
                   ON c.MemberMci_IDNO = d.CasePayorMCI_IDNO
            WHERE c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE) AS z
   UNION ALL
   SELECT ISNULL(@As_DateRange_TEXT, @Lc_Space_TEXT),
          @Lc_Dtrng_TEXT,
          @Li_RrepReversalRepost1260_NUMB,
          @Ln_EventGlobalSeqBrep_NUMB
   UNION ALL
   SELECT a.Value_CODE,
          @Lc_Rcode_TEXT,
          @Li_RrepReversalRepost1260_NUMB,
          @Ln_EventGlobalSeqBrep_NUMB
     FROM REFM_Y1 a
    WHERE a.Table_ID = @Lc_Crec_TEXT
      AND a.TableSub_ID = @Lc_Revr_TEXT
      AND a.Value_CODE = @Ac_ReasonBackOut_CODE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'SELECT_TMP_RREP ';
   SET @Ls_Sqldata_TEXT = 'Session_ID = ' + ISNULL(@Ac_Session_ID, '');

   RECEIPT_LABEL:

   DECLARE PRrep_Cur INSENSITIVE CURSOR FOR
    SELECT a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.Receipt_DATE,
           a.Receipt_AMNT,
           a.SourceReceipt_CODE,
           a.Distd_INDC,
           a.Refund_INDC,
           a.RePost_INDC,
           a.ClosedCase_INDC,
           a.MultiCase_INDC,
           a.Refund_AMNT,
           dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (a.CasePayorMCI_IDNO),
           dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.CasePayorMCIReposted_IDNO),
           a.EventGlobalBeginSeq_NUMB,
           a.PayorMCI_IDNO,
           a.RepostedPayorMci_IDNO
      FROM PRREP_Y1 a
     WHERE a.Session_ID = @Ac_Session_ID
       AND a.BackOut_INDC = @Lc_Yes_INDC
       AND a.ClosedCase_INDC = @Lc_No_INDC
     ORDER BY a.Receipt_DATE;

   OPEN PRrep_Cur;

   FETCH NEXT FROM PRrep_Cur INTO @Ld_PRrepCur_BatchOrig_DATE, @Lc_PRrepCur_SourceBatch_CODE, @Ln_PRrepCur_Batch_NUMB, @Ln_PRrepCur_SeqReceipt_NUMB, @Ld_PRrepCur_Receipt_DATE, @Ln_PRrepCur_Receipt_AMNT, @Lc_PRrepCur_SourceReceipt_CODE, @Lc_PRrepCur_Distd_INDC, @Lc_PRrepCur_Refund_INDC, @Lc_PRrepCur_RePost_INDC, @Lc_PRrepCur_ClosedCase_INDC, @Lc_PRrepCur_MultiCase_INDC, @Ln_PRrepCur_Refund_AMNT, @Ln_PRrepCur_CasePayorMCI_IDNO, @Ln_PRrepCur_CasePayorMCIReposted_IDNO, @Ln_PRrepCur_EventGlobalBeginSeq_NUMB, @Ln_PRrepCur_PayorMCI_IDNO, @Ln_PRrepCur_RepostedPayorMci_IDNO;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   -- FETCH EACH RECORD
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ld_BatchOrig_DATE = @Ld_PRrepCur_BatchOrig_DATE;
     SET @Lc_SourceBatch_CODE = @Lc_PRrepCur_SourceBatch_CODE;
     SET @Ln_Batch_NUMB = @Ln_PRrepCur_Batch_NUMB;
     SET @Ln_SeqReceipt_NUMB = @Ln_PRrepCur_SeqReceipt_NUMB;
     SET @Ld_Receipt_DATE = @Ld_PRrepCur_Receipt_DATE;
     SET @Lc_Refund_INDC = @Lc_PRrepCur_Refund_INDC;
     SET @Ln_CasePayorMCI_IDNO = @Ln_PRrepCur_CasePayorMCI_IDNO;
     SET @Lc_RePost_INDC = @Lc_PRrepCur_RePost_INDC;
     SET @Ln_PayorMCI_IDNO = @Ln_PRrepCur_PayorMCI_IDNO;
     SET @Ln_EventGlobalSeqRep_NUMB = NULL;
     SET @Ln_EventGlobalRefundSeq_NUMB = NULL;

     IF @Lc_Refund_INDC = @Lc_Yes_INDC
        AND @Ln_PayorMCI_IDNO = @Ln_PRrepCur_RepostedPayorMci_IDNO
      BEGIN
       SET @Ln_Refund_AMNT = @Ln_PRrepCur_Refund_AMNT;
      END
     ELSE
      BEGIN
       SET @Ln_Refund_AMNT = 0;
       SET @Lc_Refund_INDC = @Lc_No_INDC;
      END

     SET @Ls_Sql_TEXT = 'SELECT_RCTH_Y1_LOCK';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_EventGlobalBeginSeqLockRcth_NUMB = MAX(a.EventGlobalBeginSeq_NUMB)
       FROM RCTH_Y1 a
      WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
        AND a.Batch_NUMB = @Ln_Batch_NUMB
        AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_PRrepCur_EventGlobalBeginSeq_NUMB != @Ln_EventGlobalBeginSeqLockRcth_NUMB
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Lc_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
     
     SET @Ls_Sql_TEXT = 'GEN_SEQ FOR BACKOUT1';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptReversed1250_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
     
     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqRcthBackOut_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_DT_DISTRIBUTE';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET Distribute_DATE = @Ld_Process_DATE
      WHERE Batch_DATE = @Ld_BatchOrig_DATE
        AND Batch_NUMB = @Ln_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND Distribute_DATE = @Ld_Low_DATE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END

     SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1';
	 SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+', Batch_NUMB = ' + CAST(@Ln_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + CAST(@Lc_SourceBatch_CODE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_PRrepCur_EventGlobalBeginSeq_NUMB AS VARCHAR);

     INSERT RCTH_Y1
            (Batch_DATE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceBatch_CODE,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             Refund_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_CODE,
             RefundRecipient_ID,
             PayorMCI_IDNO,
             Case_IDNO,
             Employer_IDNO,
             Fips_CODE,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Receipt_DATE,
             Distribute_DATE,
             Check_DATE,
             CheckNo_Text,
             TaxJoint_CODE,
             Tanf_CODE,
             BackOut_INDC,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             TaxJoint_NAME,
             Fee_AMNT,
             BeginValidity_DATE,
             EndValidity_DATE,
             ReasonBackOut_CODE,
             Release_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB)
     SELECT a.Batch_DATE,
            a.Batch_NUMB,
            a.SeqReceipt_NUMB,
            a.SourceBatch_CODE,
            a.SourceReceipt_CODE,
            a.TypeRemittance_CODE,
            a.TypePosting_CODE,
            a.Refund_DATE,
            a.ReferenceIrs_IDNO,
            a.RefundRecipient_CODE,
            a.RefundRecipient_ID,
            a.PayorMCI_IDNO,
            a.Case_IDNO,
            a.Employer_IDNO,
            a.Fips_CODE,
            (a.Receipt_AMNT * -1) AS Receipt_AMNT,--Receipt_AMNT 
            (a.Receipt_AMNT * -1) AS ToDistribute_AMNT,--ToDistribute_AMNT 
            a.Receipt_DATE,
            @Ld_Process_DATE AS Distribute_DATE,--Distribute_DATE 
            a.Check_DATE,
            a.CheckNo_TEXT,
            a.TaxJoint_CODE,
            a.Tanf_CODE,
            @Lc_Yes_INDC AS BackOut_INDC,--BackOut_INDC 
            CASE a.StatusReceipt_CODE
             WHEN @Lc_StatusReceiptUnidentified_CODE
              THEN @Lc_StatusReceiptUnidentified_CODE
             ELSE @Lc_StatusReceiptIdentified_CODE
            END AS StatusReceipt_CODE,--StatusReceipt_CODE
            @Lc_Space_TEXT AS ReasonStatus_CODE,--ReasonStatus_CODE 			
            a.TaxJoint_NAME,
            a.Fee_AMNT,
            @Ld_Process_DATE AS BeginValidity_DATE,--BeginValidity_DATE  
            a.EndValidity_DATE,
            ISNULL(@Ac_ReasonBackOut_CODE, @Lc_Space_TEXT) AS ReasonBackOut_CODE,--ReasonBackOut_CODE 
            @Ld_Process_DATE AS Release_DATE,--Release_DATE 
            @Ln_EventGlobalSeqRcthBackOut_NUMB AS EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0 AS EventGlobalEndSeq_NUMB --EventGlobalEndSeq_NUMB
       FROM RCTH_Y1 a
      WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
        AND a.Batch_NUMB = @Ln_Batch_NUMB
        AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.EventGlobalBeginSeq_NUMB = @Ln_PRrepCur_EventGlobalBeginSeq_NUMB;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       
       RAISERROR(50001,16,1);
      END

     IF (@Ln_PRrepCur_CasePayorMCI_IDNO IS NULL
          OR @Ln_PRrepCur_CasePayorMCI_IDNO = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE_URCT_Y1';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       UPDATE URCT_Y1
          SET EndValidity_DATE = @Ld_Process_DATE,
              Remarks_TEXT = @Lc_ReceiptBackedOut_TEXT
        WHERE Batch_DATE = @Ld_BatchOrig_DATE
          AND SourceBatch_CODE = @Lc_SourceBatch_CODE
          AND Batch_NUMB = @Ln_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         RAISERROR(50001,16,1);
        END
      END

     NF_OBLIGATION:

     --NF Obligation process 	
     IF @Lc_PRrepCur_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpRecoupmentCr_CODE, @Lc_SourceReceiptCpFeePaymentCf_CODE, @Lc_SourceReceiptAdmnOffsetRetirementAr_CODE, @Lc_SourceReceiptAdmnOffsetSalaryAs_CODE,
                                                @Lc_SourceReceiptAdmnOffsetVendorPymtAv_CODE, @Lc_SourceReceiptSpcFullCollectionFc_CODE, @Lc_SourceReceiptSpecialCollectionSc_CODE, @Lc_SourceReceiptStateTaxOffsetSt_CODE)
        AND @Ac_ReasonBackOut_CODE IN (@Lc_ReasonBackOutAccountClosedAc_CODE, @Lc_ReasonBackOutNsfNf_CODE, @Lc_ReasonBackOutReferToMakerRm_CODE, @Lc_ReasonBackOutStopPaymentSp_CODE, @Lc_ReasonBackOutUnlocatedAcctUa_CODE)
      BEGIN

       SET @Ls_Sql_TEXT = 'SELECT_CMEM_CASE_SORD_CMEM_DEMO_Y11 ';
       SET @Ls_Sqldata_TEXT = 'PayorMci_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS NVARCHAR(10)), '') + ', SourceReceipt_CODE = ' + ISNULL(@Lc_PRrepCur_SourceReceipt_CODE, '') + ', ReasonBackOut_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE, '');

       --Get Youngest Child of Payor's FirstOpened Case in Open status		
       SELECT @Ln_NfObleCase_IDNO = Case_IDNO,
              @Ln_NfObleMemberMciDp_NUMB = MemberMci_IDNO
         FROM (SELECT b.Case_IDNO,
                      c.Opened_DATE,
                      f.MemberMci_IDNO,
                      f.Birth_DATE,
                      ROW_NUMBER() OVER (ORDER BY c.Opened_DATE, f.Birth_DATE DESC) AS rnk
                 FROM CMEM_Y1 b
                      JOIN CASE_Y1 c
                       ON b.Case_IDNO = c.Case_IDNO
                      JOIN SORD_Y1 d
                       ON c.Case_IDNO = d.Case_IDNO
                      JOIN CMEM_Y1 e
                       ON d.Case_IDNO = e.Case_IDNO
                      JOIN DEMO_Y1 f
                       ON e.MemberMci_IDNO = f.MemberMci_IDNO
                WHERE b.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                  AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                  AND @Ld_Process_DATE BETWEEN d.OrderEffective_DATE AND d.OrderEnd_DATE
                  AND d.EndValidity_DATE = @Ld_High_DATE
                  AND e.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                  AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) a
        WHERE rnk = 1;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY > 0
          AND @Ln_NfObleCase_IDNO > 0
        BEGIN
         --Get new Obligation Sequence number
         SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1_NF ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @ln_NfObleCase_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT @Ln_NfObleObligationSeq_NUMB = ISNULL (MAX (Obligationseq_NUMB), 0) + 1,
                @Ln_NfObleOrderSeq_NUMB = ISNULL (MIN (OrderSeq_NUMB), 1)
           FROM OBLE_Y1 o
          WHERE o.Case_IDNO = @Ln_NfObleCase_IDNO
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Ls_Sql_TEXT = 'INSERT_OBLE_Y1_NF ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @ln_NfObleCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_NfObleOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_NfObleObligationSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_NfObleMemberMciDp_NUMB AS VARCHAR ),'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_TypeDebtNf_CODE,'')+ ', Fips_CODE = ' + ISNULL(@Lc_DeFips_CODE,'')+ ', FreqPeriodic_CODE = ' + ISNULL(@Lc_FreqPeriodicOneTime_CODE,'')+ ', Periodic_AMNT = ' + ISNULL('25','')+ ', ExpectToPay_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', ExpectToPay_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ReasonChange_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndObligation_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', AccrualLast_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', AccrualNext_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientStateNrFee_CODE,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         INSERT OBLE_Y1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 MemberMci_IDNO,
                 TypeDebt_CODE,
                 Fips_CODE,
                 FreqPeriodic_CODE,
                 Periodic_AMNT,
                 ExpectToPay_AMNT,
                 ExpectToPay_CODE,
                 ReasonChange_CODE,
                 BeginObligation_DATE,
                 EndObligation_DATE,
                 AccrualLast_DATE,
                 AccrualNext_DATE,
                 CheckRecipient_ID,
                 CheckRecipient_CODE,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB,
                 BeginValidity_DATE,
                 EndValidity_DATE)
          SELECT  @Ln_NfObleCase_IDNO AS Case_IDNO, 
                  @Ln_NfObleOrderSeq_NUMB AS OrderSeq_NUMB, 
                  @Ln_NfObleObligationSeq_NUMB AS ObligationSeq_NUMB, 
                  @Ln_NfObleMemberMciDp_NUMB AS MemberMci_IDNO, 
                  @Lc_TypeDebtNf_CODE AS TypeDebt_CODE, 
                  @Lc_DeFips_CODE AS Fips_CODE, 
                  @Lc_FreqPeriodicOneTime_CODE AS FreqPeriodic_CODE, 
                  25 AS Periodic_AMNT, 
                  0 AS ExpectToPay_AMNT, 
                  @Lc_Space_TEXT AS ExpectToPay_CODE, 
                  @Lc_Space_TEXT AS ReasonChange_CODE, 
                  @Ld_Process_DATE AS BeginObligation_DATE, 							 
                  @Ld_Process_DATE AS EndObligation_DATE, 
                  @Ld_Low_DATE AS AccrualLast_DATE, 
                  @Ld_Low_DATE AS AccrualNext_DATE, 
                  @Lc_CheckRecipientStateNrFee_CODE AS CheckRecipient_ID,--( NR FEE RECIPIENT - STATE)
                  @Lc_RecipientTypeOthp_CODE AS CheckRecipient_CODE, 
                  @Ln_EventGlobalSeqRcthBackOut_NUMB AS EventGlobalBeginSeq_NUMB,
                  0 AS EventGlobalEndSeq_NUMB,
                  @Ld_Process_DATE AS BeginValidity_DATE,
                  @Ld_High_DATE AS EndValidity_DATE;
                  
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
           
           RAISERROR(50001,16,1);
          END

         SET @Ln_NfObleSupportYearMonth_NUMB = CONVERT(CHAR(6), @Ld_Process_DATE, 112);

         SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1_NF ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_NfObleCase_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_NfObleOrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_NfObleObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_NfObleSupportYearMonth_NUMB AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfareNonTanf_CODE,'')+ ', MtdCurSupOwed_AMNT = ' + ISNULL('0','')+ ', TransactionCurSup_AMNT = ' + ISNULL('0','')+ ', OweTotCurSup_AMNT = ' + ISNULL('0','')+ ', AppTotCurSup_AMNT = ' + ISNULL('0','')+ ', TransactionExptPay_AMNT = ' + ISNULL('0','')+ ', OweTotExptPay_AMNT = ' + ISNULL('0','')+ ', AppTotExptPay_AMNT = ' + ISNULL('0','')+ ', TransactionNaa_AMNT = ' + ISNULL('25','')+ ', OweTotNaa_AMNT = ' + ISNULL('25','')+ ', AppTotNaa_AMNT = ' + ISNULL('0','')+ ', TransactionTaa_AMNT = ' + ISNULL('0','')+ ', OweTotTaa_AMNT = ' + ISNULL('0','')+ ', AppTotTaa_AMNT = ' + ISNULL('0','')+ ', TransactionPaa_AMNT = ' + ISNULL('0','')+ ', OweTotPaa_AMNT = ' + ISNULL('0','')+ ', AppTotPaa_AMNT = ' + ISNULL('0','')+ ', TransactionCaa_AMNT = ' + ISNULL('0','')+ ', OweTotCaa_AMNT = ' + ISNULL('0','')+ ', AppTotCaa_AMNT = ' + ISNULL('0','')+ ', TransactionUpa_AMNT = ' + ISNULL('0','')+ ', OweTotUpa_AMNT = ' + ISNULL('0','')+ ', AppTotUpa_AMNT = ' + ISNULL('0','')+ ', TransactionUda_AMNT = ' + ISNULL('0','')+ ', OweTotUda_AMNT = ' + ISNULL('0','')+ ', AppTotUda_AMNT = ' + ISNULL('0','')+ ', TransactionIvef_AMNT = ' + ISNULL('0','')+ ', OweTotIvef_AMNT = ' + ISNULL('0','')+ ', AppTotIvef_AMNT = ' + ISNULL('0','')+ ', TransactionMedi_AMNT = ' + ISNULL('0','')+ ', OweTotMedi_AMNT = ' + ISNULL('0','')+ ', AppTotMedi_AMNT = ' + ISNULL('0','')+ ', TransactionNffc_AMNT = ' + ISNULL('0','')+ ', OweTotNffc_AMNT = ' + ISNULL('0','')+ ', AppTotNffc_AMNT = ' + ISNULL('0','')+ ', TransactionNonIvd_AMNT = ' + ISNULL('0','')+ ', OweTotNonIvd_AMNT = ' + ISNULL('0','')+ ', AppTotNonIvd_AMNT = ' + ISNULL('0','')+ ', TransactionFuture_AMNT = ' + ISNULL('0','')+ ', AppTotFuture_AMNT = ' + ISNULL('0','')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_PRrepCur_Receipt_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ObligationCreation1010_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientStateNrFee_CODE,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'');

         INSERT LSUP_Y1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 SupportYearMonth_NUMB,
                 TypeWelfare_CODE,
                 MtdCurSupOwed_AMNT,
                 TransactionCurSup_AMNT,
                 OweTotCurSup_AMNT,
                 AppTotCurSup_AMNT,
                 TransactionExptPay_AMNT,
                 OweTotExptPay_AMNT,
                 AppTotExptPay_AMNT,
                 TransactionNaa_AMNT,
                 OweTotNaa_AMNT,
                 AppTotNaa_AMNT,
                 TransactionTaa_AMNT,
                 OweTotTaa_AMNT,
                 AppTotTaa_AMNT,
                 TransactionPaa_AMNT,
                 OweTotPaa_AMNT,
                 AppTotPaa_AMNT,
                 TransactionCaa_AMNT,
                 OweTotCaa_AMNT,
                 AppTotCaa_AMNT,
                 TransactionUpa_AMNT,
                 OweTotUpa_AMNT,
                 AppTotUpa_AMNT,
                 TransactionUda_AMNT,
                 OweTotUda_AMNT,
                 AppTotUda_AMNT,
                 TransactionIvef_AMNT,
                 OweTotIvef_AMNT,
                 AppTotIvef_AMNT,
                 TransactionMedi_AMNT,
                 OweTotMedi_AMNT,
                 AppTotMedi_AMNT,
                 TransactionNffc_AMNT,
                 OweTotNffc_AMNT,
                 AppTotNffc_AMNT,
                 TransactionNonIvd_AMNT,
                 OweTotNonIvd_AMNT,
                 AppTotNonIvd_AMNT,
                 TransactionFuture_AMNT,
                 AppTotFuture_AMNT,
                 Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 Receipt_DATE,
                 Distribute_DATE,
                 TypeRecord_CODE,
                 EventGlobalSeq_NUMB,
                 EventFunctionalSeq_NUMB,
                 CheckRecipient_ID,
                 CheckRecipient_CODE)
         SELECT  @Ln_NfObleCase_IDNO AS Case_IDNO,
                 @Ln_NfObleOrderSeq_NUMB AS OrderSeq_NUMB,
                 @Ln_NfObleObligationSeq_NUMB AS ObligationSeq_NUMB,
                 @Ln_NfObleSupportYearMonth_NUMB AS SupportYearMonth_NUMB,
                 @Lc_TypeWelfareNonTanf_CODE AS TypeWelfare_CODE,
                 0 AS MtdCurSupOwed_AMNT,
                 0 AS TransactionCurSup_AMNT,
                 0 AS OweTotCurSup_AMNT,
                 0 AS AppTotCurSup_AMNT,
                 0 AS TransactionExptPay_AMNT,
                 0 AS OweTotExptPay_AMNT,
                 0 AS AppTotExptPay_AMNT,
                 25 AS TransactionNaa_AMNT,
                 25 AS OweTotNaa_AMNT,
                 0 AS AppTotNaa_AMNT,
                 0 AS TransactionTaa_AMNT,
                 0 AS OweTotTaa_AMNT,
                 0 AS AppTotTaa_AMNT,
                 0 AS TransactionPaa_AMNT,
                 0 AS OweTotPaa_AMNT,
                 0 AS AppTotPaa_AMNT ,
                 0 AS TransactionCaa_AMNT ,
                 0 AS OweTotCaa_AMNT ,
                 0 AS AppTotCaa_AMNT ,
                 0 AS TransactionUpa_AMNT ,
                 0 AS OweTotUpa_AMNT ,
                 0 AS AppTotUpa_AMNT ,
                 0 AS TransactionUda_AMNT ,
                 0 AS OweTotUda_AMNT ,
                 0 AS AppTotUda_AMNT ,
                 0 AS TransactionIvef_AMNT ,
                 0 AS OweTotIvef_AMNT ,
                 0 AS AppTotIvef_AMNT ,
                 0 AS TransactionMedi_AMNT ,
                 0 AS OweTotMedi_AMNT ,
                 0 AS AppTotMedi_AMNT ,
                 0 AS TransactionNffc_AMNT ,
                 0 AS OweTotNffc_AMNT ,
                 0 AS AppTotNffc_AMNT ,
                 0 AS TransactionNonIvd_AMNT ,
                 0 AS OweTotNonIvd_AMNT ,
                 0 AS AppTotNonIvd_AMNT ,
                 0 AS TransactionFuture_AMNT ,
                 0 AS AppTotFuture_AMNT ,
                 @Ld_BatchOrig_DATE AS Batch_DATE ,
                 @Ln_Batch_NUMB AS Batch_NUMB ,
                 @Ln_SeqReceipt_NUMB AS SeqReceipt_NUMB ,
                 @Lc_SourceBatch_CODE AS SourceBatch_CODE, 
                 @Ld_PRrepCur_Receipt_DATE AS Receipt_DATE, 
                 @Ld_Process_DATE AS Distribute_DATE ,
                 @Lc_Space_TEXT AS TypeRecord_CODE ,
                 @Ln_EventGlobalSeqRcthBackOut_NUMB AS EventGlobalSeq_NUMB ,
                 @Li_ObligationCreation1010_NUMB AS EventFunctionalSeq_NUMB ,
                 @Lc_CheckRecipientStateNrFee_CODE AS CheckRecipient_ID ,
                 @Lc_RecipientTypeOthp_CODE AS CheckRecipient_CODE;
                 
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           RAISERROR(50001,16,1);
          END
        END
      END

     IF @Lc_PRrepCur_Distd_INDC = @Lc_No_INDC
      BEGIN
       IF @Ln_PRrepCur_Refund_AMNT > 0
        BEGIN
         GOTO process_offset;
        END
       ELSE
        BEGIN
         GOTO cp_nsf_fee; --process_repost;
        END
      END

     SET @Lc_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ FOR GRANT1';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptReversed1250_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
     
     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqGrant_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     BACKOUT_LABEL:

     DECLARE Lsup_Cur INSENSITIVE CURSOR FOR
      SELECT a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             a.SupportYearMonth_NUMB,
             SUM(a.TransactionCurSup_AMNT) * -1 AS TransactionCurSup_AMNT,
             SUM(a.TransactionExptPay_AMNT) * -1 AS TransactionExptPay_AMNT,
             SUM(a.TransactionNaa_AMNT) * -1 AS TransactionNaa_AMNT,
             SUM(a.TransactionTaa_AMNT) * -1 AS TransactionTaa_AMNT,
             SUM(a.TransactionPaa_AMNT) * -1 AS TransactionPaa_AMNT,
             SUM(a.TransactionCaa_AMNT) * -1 AS TransactionCaa_AMNT,
             SUM(a.TransactionUpa_AMNT) * -1 AS TransactionUpa_AMNT,
             SUM(a.TransactionUda_AMNT) * -1 AS TransactionUda_AMNT,
             SUM(a.TransactionIvef_AMNT) * -1 AS TransactionIvef_AMNT,
             SUM(a.TransactionMedi_AMNT) * -1 AS TransactionMedi_AMNT,
             SUM(a.TransactionFuture_AMNT) * -1 AS TransactionFuture_AMNT,
             SUM(a.TransactionNffc_AMNT) * -1 AS TransactionNffc_AMNT,
             SUM(a.TransactionNonIvd_AMNT) * -1 AS TransactionNonIvd_AMNT
        FROM LSUP_Y1 a
       WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
         AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
         AND a.Batch_NUMB = @Ln_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
         AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
         AND a.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_DirectPayCredit1040_NUMB)
       GROUP BY a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB,
                a.SupportYearMonth_NUMB
       ORDER BY a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB,
                a.SupportYearMonth_NUMB;

     OPEN Lsup_Cur;

     FETCH NEXT FROM Lsup_Cur INTO @Ln_LsupCur_Case_IDNO, @Ln_LsupCur_OrderSeq_NUMB, @Ln_LsupCur_ObligationSeq_NUMB, @Ln_LsupCur_SupportYearMonth_NUMB, @Ln_LsupCur_TransactionCurSup_AMNT, @Ln_LsupCur_TransactionExptPay_AMNT, @Ln_LsupCur_TransactionNaa_AMNT, @Ln_LsupCur_TransactionTaa_AMNT, @Ln_LsupCur_TransactionPaa_AMNT, @Ln_LsupCur_TransactionCaa_AMNT, @Ln_LsupCur_TransactionUpa_AMNT, @Ln_LsupCur_TransactionUda_AMNT, @Ln_LsupCur_TransactionIvef_AMNT, @Ln_LsupCur_TransactionMedi_AMNT, @Ln_LsupCur_TransactionFuture_AMNT, @Ln_LsupCur_TransactionNffc_AMNT, @Ln_LsupCur_TransactionNonIvd_AMNT;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
	 -- FETCH EACH RECORD
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_Case_IDNO = @Ln_LsupCur_Case_IDNO;
       SET @Ln_OrderSeq_NUMB = @Ln_LsupCur_OrderSeq_NUMB;
       SET @Ln_ObligationSeq_NUMB = @Ln_LsupCur_ObligationSeq_NUMB;
       SET @Ln_TransactionCurSup_AMNT = @Ln_LsupCur_TransactionCurSup_AMNT;
       SET @Ln_TransactionExptPay_AMNT = @Ln_LsupCur_TransactionExptPay_AMNT;
       SET @Ld_Receipt_DATE = @Ld_PRrepCur_Receipt_DATE;
       SET @Lc_TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE;

       IF (@Ln_Case_IDNO = @Ln_CasePrev_IDNO
           AND @Ln_OrderSeq_NUMB = @Ln_OrderPrevseq_NUMB
           AND @Ln_ObligationSeq_NUMB = @Ln_ObligationPrevseq_NUMB)
        BEGIN
         SET @Lc_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
         SET @Ls_Sql_TEXT = 'GEN_SEQ FOR BACKOUT2';
         SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptReversed1250_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
         
         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB,
          @Ac_Process_ID              = @Lc_Process_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqLsupBackOut_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END

         SET @Lc_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
         SET @Ls_Sql_TEXT = 'GEN_SEQ FOR GRANT2';
         SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptReversed1250_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');

         EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
          @An_EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB,
          @Ac_Process_ID              = @Lc_Process_ID,
          @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
          @Ac_Note_INDC               = @Lc_No_INDC,
          @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
          @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqLsupGrant_NUMB OUTPUT,
          @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ln_EventGlobalSeqLsupBackOut_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB;
         SET @Ln_EventGlobalSeqLsupGrant_NUMB = @Ln_EventGlobalSeqGrant_NUMB;
        END

       SET @Ls_Sql_TEXT = 'SELECT_VOBLE 1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT TOP 1 @Lc_TypeDebt_CODE = a.TypeDebt_CODE,
                    @Lc_Fips_CODE = a.Fips_CODE
         FROM OBLE_Y1 a
        WHERE a.Case_IDNO = @Ln_Case_IDNO
          AND a.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
          AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Lc_DesnPoint_TEXT = @Lc_No_INDC;
       SET @Ln_SupportYearMonth_NUMB = @Ln_LsupCur_SupportYearMonth_NUMB;
       SET @Ln_SupportYearMonthCur_NUMB = CONVERT(VARCHAR(6), @Ld_Process_DATE, 112);
	   -- FETCH EACH RECORD
       WHILE @Ln_SupportYearMonth_NUMB <= @Ln_SupportYearMonthCur_NUMB
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1 1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonth_NUMB AS VARCHAR ),'');

         SELECT @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE,
                @Ln_MtdCurSupOwed_AMNT = a.MtdCurSupOwed_AMNT,
                @Ln_OweTotCurSup_AMNT = a.OweTotCurSup_AMNT,
                @Ln_AppTotCurSup_AMNT = a.AppTotCurSup_AMNT,
                @Ln_OweTotExptPay_AMNT = a.OweTotExptPay_AMNT,
                @Ln_AppTotExptPay_AMNT = a.AppTotExptPay_AMNT,
                @Ln_OweTotNaa_AMNT = a.OweTotNaa_AMNT,
                @Ln_AppTotNaa_AMNT = a.AppTotNaa_AMNT,
                @Ln_OweTotTaa_AMNT = a.OweTotTaa_AMNT,
                @Ln_AppTotTaa_AMNT = a.AppTotTaa_AMNT,
                @Ln_OweTotPaa_AMNT = a.OweTotPaa_AMNT,
                @Ln_AppTotPaa_AMNT = a.AppTotPaa_AMNT,
                @Ln_OweTotCaa_AMNT = a.OweTotCaa_AMNT,
                @Ln_AppTotCaa_AMNT = a.AppTotCaa_AMNT,
                @Ln_OweTotUpa_AMNT = a.OweTotUpa_AMNT,
                @Ln_AppTotUpa_AMNT = a.AppTotUpa_AMNT,
                @Ln_OweTotUda_AMNT = a.OweTotUda_AMNT,
                @Ln_AppTotUda_AMNT = a.AppTotUda_AMNT,
                @Ln_OweTotIvef_AMNT = a.OweTotIvef_AMNT,
                @Ln_AppTotIvef_AMNT = a.AppTotIvef_AMNT,
                @Ln_OweTotMedi_AMNT = a.OweTotMedi_AMNT,
                @Ln_AppTotMedi_AMNT = a.AppTotMedi_AMNT,
                @Ln_AppTotFuture_AMNT = a.AppTotFuture_AMNT,
                @Ln_EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB,
                @Ln_OweTotNffc_AMNT = a.OweTotNffc_AMNT,
                @Ln_AppTotNffc_AMNT = a.AppTotNffc_AMNT,
                @Ln_OweTotNonIvd_AMNT = a.OweTotNonIvd_AMNT,
                @Ln_AppTotNonIvd_AMNT = a.AppTotNonIvd_AMNT
           FROM LSUP_Y1 a
          WHERE a.Case_IDNO = @Ln_Case_IDNO
            AND a.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
            AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
            AND a.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
            AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) AS EventGlobalSeq_NUMB
                                           FROM LSUP_Y1 b
                                          WHERE b.Case_IDNO = a.Case_IDNO
                                            AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                            AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                            AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);
         
         -- Defect 13587 - Reversal or Negative special collections adjustment action which is increasing the case arrears issue - Fix - Start -- 
         -- Moved @Ln_RowCount_QNTY variable assignment after the SELECT statement instead of after the below given 11 variables value assignment
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;
         -- Defect 13587 - Reversal or Negative special collections adjustment action which is increasing the case arrears issue - Fix - End -- 
         
         SET @Ln_TransactionNaa_AMNT = @Ln_LsupCur_TransactionNaa_AMNT;
         SET @Ln_TransactionTaa_AMNT = @Ln_LsupCur_TransactionTaa_AMNT;
         SET @Ln_TransactionCaa_AMNT = @Ln_LsupCur_TransactionCaa_AMNT;
         SET @Ln_TransactionUpa_AMNT = @Ln_LsupCur_TransactionUpa_AMNT;
         SET @Ln_TransactionUda_AMNT = @Ln_LsupCur_TransactionUda_AMNT;
         SET @Ln_TransactionPaa_AMNT = @Ln_LsupCur_TransactionPaa_AMNT;
         SET @Ln_TransactionIvef_AMNT = @Ln_LsupCur_TransactionIvef_AMNT;
         SET @Ln_TransactionMedi_AMNT = @Ln_LsupCur_TransactionMedi_AMNT;
         SET @Ln_TransactionFuture_AMNT = @Ln_LsupCur_TransactionFuture_AMNT;
         SET @Ln_TransactionNffc_AMNT = @Ln_LsupCur_TransactionNffc_AMNT;
         SET @Ln_TransactionNonIvd_AMNT = @Ln_LsupCur_TransactionNonIvd_AMNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ln_TransactionNaa_AMNT = 0;
           SET @Ln_TransactionTaa_AMNT = 0;
           SET @Ln_TransactionCaa_AMNT = 0;
           SET @Ln_TransactionUpa_AMNT = 0;
           SET @Ln_TransactionUda_AMNT = 0;
           SET @Ln_TransactionPaa_AMNT = 0;
           SET @Ln_TransactionIvef_AMNT = 0;
           SET @Ln_TransactionMedi_AMNT = 0;
           SET @Ln_TransactionFuture_AMNT = 0;
           SET @Ln_TransactionNffc_AMNT = 0;
           SET @Ln_TransactionNonIvd_AMNT = 0;
           
           SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1 2';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'');

           SELECT @Lc_TypeWelfare_CODE = a.TypeWelfare_CODE,
                  @Ln_MtdCurSupOwed_AMNT = 0,
                  @Ln_OweTotCurSup_AMNT = 0,
                  @Ln_AppTotCurSup_AMNT = 0,
                  @Ln_OweTotExptPay_AMNT = 0,
                  @Ln_AppTotExptPay_AMNT = 0,
                  @Ln_OweTotNaa_AMNT = a.OweTotNaa_AMNT,
                  @Ln_AppTotNaa_AMNT = a.AppTotNaa_AMNT,
                  @Ln_OweTotTaa_AMNT = a.OweTotTaa_AMNT,
                  @Ln_AppTotTaa_AMNT = a.AppTotTaa_AMNT,
                  @Ln_OweTotPaa_AMNT = a.OweTotPaa_AMNT,
                  @Ln_AppTotPaa_AMNT = a.AppTotPaa_AMNT,
                  @Ln_OweTotCaa_AMNT = a.OweTotCaa_AMNT,
                  @Ln_AppTotCaa_AMNT = a.AppTotCaa_AMNT,
                  @Ln_OweTotUpa_AMNT = a.OweTotUpa_AMNT,
                  @Ln_AppTotUpa_AMNT = a.AppTotUpa_AMNT,
                  @Ln_OweTotUda_AMNT = a.OweTotUda_AMNT,
                  @Ln_AppTotUda_AMNT = a.AppTotUda_AMNT,
                  @Ln_OweTotIvef_AMNT = a.OweTotIvef_AMNT,
                  @Ln_AppTotIvef_AMNT = a.AppTotIvef_AMNT,
                  @Ln_OweTotMedi_AMNT = a.OweTotMedi_AMNT,
                  @Ln_AppTotMedi_AMNT = a.AppTotMedi_AMNT,
                  @Ln_AppTotFuture_AMNT = a.AppTotFuture_AMNT,
                  @Ln_EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB,
                  @Ln_OweTotNffc_AMNT = a.OweTotNffc_AMNT,
                  @Ln_AppTotNffc_AMNT = a.AppTotNffc_AMNT,
                  @Ln_OweTotNonIvd_AMNT = a.OweTotNonIvd_AMNT,
                  @Ln_AppTotNonIvd_AMNT = a.AppTotNonIvd_AMNT
             FROM LSUP_Y1 a
            WHERE a.Case_IDNO = @Ln_Case_IDNO
              AND a.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
              AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
              AND a.SupportYearMonth_NUMB = (SELECT MAX(b.SupportYearMonth_NUMB) AS SupportYearMonth_NUMB
                                               FROM LSUP_Y1 b
                                              WHERE b.Case_IDNO = a.Case_IDNO
                                                AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                AND b.SupportYearMonth_NUMB <= @Ln_SupportYearMonth_NUMB)
              AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) AS EventGlobalSeq_NUMB
                                             FROM LSUP_Y1 b
                                            WHERE b.Case_IDNO = a.Case_IDNO
                                              AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);
          END

         SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1 ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE,'')+ ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST( @Ln_MtdCurSupOwed_AMNT AS VARCHAR ),'')+ ', TransactionCurSup_AMNT = ' + ISNULL(CAST( @Ln_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', OweTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_OweTotCurSup_AMNT AS VARCHAR ),'')+ ', TransactionExptPay_AMNT = ' + ISNULL(CAST( @Ln_TransactionExptPay_AMNT AS VARCHAR ),'')+ ', OweTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_OweTotExptPay_AMNT AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionNaa_AMNT AS VARCHAR ),'')+ ', OweTotNaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotNaa_AMNT AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionTaa_AMNT AS VARCHAR ),'')+ ', OweTotTaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotTaa_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionPaa_AMNT AS VARCHAR ),'')+ ', OweTotPaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotPaa_AMNT AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionCaa_AMNT AS VARCHAR ),'')+ ', OweTotCaa_AMNT = ' + ISNULL(CAST( @Ln_OweTotCaa_AMNT AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_TransactionUpa_AMNT AS VARCHAR ),'')+ ', OweTotUpa_AMNT = ' + ISNULL(CAST( @Ln_OweTotUpa_AMNT AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_TransactionUda_AMNT AS VARCHAR ),'')+ ', OweTotUda_AMNT = ' + ISNULL(CAST( @Ln_OweTotUda_AMNT AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL(CAST( @Ln_TransactionIvef_AMNT AS VARCHAR ),'')+ ', OweTotIvef_AMNT = ' + ISNULL(CAST( @Ln_OweTotIvef_AMNT AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL(CAST( @Ln_TransactionMedi_AMNT AS VARCHAR ),'')+ ', OweTotMedi_AMNT = ' + ISNULL(CAST( @Ln_OweTotMedi_AMNT AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Ln_TransactionNffc_AMNT AS VARCHAR ),'')+ ', OweTotNffc_AMNT = ' + ISNULL(CAST( @Ln_OweTotNffc_AMNT AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Ln_TransactionNonIvd_AMNT AS VARCHAR ),'')+ ', OweTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_OweTotNonIvd_AMNT AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_PRrepCur_Receipt_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecord_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqLsupBackOut_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptReversed1250_NUMB AS VARCHAR ),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

         INSERT LSUP_Y1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 SupportYearMonth_NUMB,
                 TypeWelfare_CODE,
                 MtdCurSupOwed_AMNT,
                 TransactionCurSup_AMNT,
                 OweTotCurSup_AMNT,
                 AppTotCurSup_AMNT,
                 TransactionExptPay_AMNT,
                 OweTotExptPay_AMNT,
                 AppTotExptPay_AMNT,
                 TransactionNaa_AMNT,
                 OweTotNaa_AMNT,
                 AppTotNaa_AMNT,
                 TransactionTaa_AMNT,
                 OweTotTaa_AMNT,
                 AppTotTaa_AMNT,
                 TransactionPaa_AMNT,
                 OweTotPaa_AMNT,
                 AppTotPaa_AMNT,
                 TransactionCaa_AMNT,
                 OweTotCaa_AMNT,
                 AppTotCaa_AMNT,
                 TransactionUpa_AMNT,
                 OweTotUpa_AMNT,
                 AppTotUpa_AMNT,
                 TransactionUda_AMNT,
                 OweTotUda_AMNT,
                 AppTotUda_AMNT,
                 TransactionIvef_AMNT,
                 OweTotIvef_AMNT,
                 AppTotIvef_AMNT,
                 TransactionMedi_AMNT,
                 OweTotMedi_AMNT,
                 AppTotMedi_AMNT,
                 TransactionNffc_AMNT,
                 OweTotNffc_AMNT,
                 AppTotNffc_AMNT,
                 TransactionNonIvd_AMNT,
                 OweTotNonIvd_AMNT,
                 AppTotNonIvd_AMNT,
                 TransactionFuture_AMNT,
                 AppTotFuture_AMNT,
                 Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 Receipt_DATE,
                 Distribute_DATE,
                 TypeRecord_CODE,
                 EventGlobalSeq_NUMB,
                 EventFunctionalSeq_NUMB,
                 CheckRecipient_ID,
                 CheckRecipient_CODE)
           SELECT @Ln_Case_IDNO AS Case_IDNO,
                  @Ln_OrderSeq_NUMB AS OrderSeq_NUMB ,
                  @Ln_ObligationSeq_NUMB AS ObligationSeq_NUMB ,
                  @Ln_SupportYearMonth_NUMB AS SupportYearMonth_NUMB,
                  @Lc_TypeWelfare_CODE AS TypeWelfare_CODE ,
                  @Ln_MtdCurSupOwed_AMNT AS MtdCurSupOwed_AMNT,
                  @Ln_TransactionCurSup_AMNT AS TransactionCurSup_AMNT ,
                  @Ln_OweTotCurSup_AMNT AS OweTotCurSup_AMNT ,
                  @Ln_AppTotCurSup_AMNT + @Ln_TransactionCurSup_AMNT AS AppTotCurSup_AMNT ,
                  @Ln_TransactionExptPay_AMNT AS TransactionExptPay_AMNT ,
                  @Ln_OweTotExptPay_AMNT AS OweTotExptPay_AMNT ,
                  @Ln_AppTotExptPay_AMNT + @Ln_TransactionExptPay_AMNT AS AppTotExptPay_AMNT ,
                  @Ln_TransactionNaa_AMNT AS TransactionNaa_AMNT ,
                  @Ln_OweTotNaa_AMNT AS OweTotNaa_AMNT ,
                  @Ln_AppTotNaa_AMNT + @Ln_TransactionNaa_AMNT AS AppTotNaa_AMNT ,
                  @Ln_TransactionTaa_AMNT AS TransactionTaa_AMNT ,
                  @Ln_OweTotTaa_AMNT AS OweTotTaa_AMNT ,
                  @Ln_AppTotTaa_AMNT + @Ln_TransactionTaa_AMNT AS AppTotTaa_AMNT ,
                  @Ln_TransactionPaa_AMNT AS TransactionPaa_AMNT ,
                  @Ln_OweTotPaa_AMNT AS OweTotPaa_AMNT ,
                  @Ln_AppTotPaa_AMNT + @Ln_TransactionPaa_AMNT AS AppTotPaa_AMNT ,
                  @Ln_TransactionCaa_AMNT AS TransactionCaa_AMNT ,
                  @Ln_OweTotCaa_AMNT AS OweTotCaa_AMNT ,
                  @Ln_AppTotCaa_AMNT + @Ln_TransactionCaa_AMNT AS AppTotCaa_AMNT ,
                  @Ln_TransactionUpa_AMNT AS TransactionUpa_AMNT ,
                  @Ln_OweTotUpa_AMNT AS OweTotUpa_AMNT ,
                  @Ln_AppTotUpa_AMNT + @Ln_TransactionUpa_AMNT AS AppTotUpa_AMNT ,
                  @Ln_TransactionUda_AMNT AS TransactionUda_AMNT ,
                  @Ln_OweTotUda_AMNT AS OweTotUda_AMNT ,
                  @Ln_AppTotUda_AMNT + @Ln_TransactionUda_AMNT AS AppTotUda_AMNT ,
                  @Ln_TransactionIvef_AMNT AS TransactionIvef_AMNT ,
                  @Ln_OweTotIvef_AMNT AS OweTotIvef_AMNT ,
                  @Ln_AppTotIvef_AMNT + @Ln_TransactionIvef_AMNT AS AppTotIvef_AMNT ,
                  @Ln_TransactionMedi_AMNT AS TransactionMedi_AMNT ,
                  @Ln_OweTotMedi_AMNT AS OweTotMedi_AMNT ,
                  @Ln_AppTotMedi_AMNT + @Ln_TransactionMedi_AMNT AS AppTotMedi_AMNT ,
                  @Ln_TransactionNffc_AMNT AS TransactionNffc_AMNT ,
                  @Ln_OweTotNffc_AMNT AS OweTotNffc_AMNT ,
                  @Ln_AppTotNffc_AMNT + @Ln_TransactionNffc_AMNT AS AppTotNffc_AMNT ,
                  @Ln_TransactionNonIvd_AMNT AS TransactionNonIvd_AMNT ,
                  @Ln_OweTotNonIvd_AMNT AS OweTotNonIvd_AMNT ,
                  @Ln_AppTotNonIvd_AMNT + @Ln_TransactionNonIvd_AMNT AS AppTotNonIvd_AMNT ,
                  ISNULL(@Ln_TransactionFuture_AMNT, 0) AS TransactionFuture_AMNT ,
                  ISNULL(@Ln_AppTotFuture_AMNT, 0) + @Ln_TransactionFuture_AMNT AS AppTotFuture_AMNT ,
                  @Ld_BatchOrig_DATE AS Batch_DATE ,
                  @Ln_Batch_NUMB AS Batch_NUMB ,
                  @Ln_SeqReceipt_NUMB AS SeqReceipt_NUMB ,
                  @Lc_SourceBatch_CODE AS SourceBatch_CODE, 
                  @Ld_PRrepCur_Receipt_DATE AS Receipt_DATE, 
                  @Ld_Process_DATE AS Distribute_DATE ,
                  @Lc_TypeRecord_CODE AS TypeRecord_CODE ,
                  @Ln_EventGlobalSeqLsupBackOut_NUMB AS EventGlobalSeq_NUMB ,
                  @Li_ReceiptReversed1250_NUMB AS EventFunctionalSeq_NUMB ,
                  @Lc_Space_TEXT AS CheckRecipient_ID ,
                  @Lc_Space_TEXT AS CheckRecipient_CODE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
          END

         SET @Ln_AppTotCurSup_AMNT = @Ln_AppTotCurSup_AMNT + @Ln_TransactionCurSup_AMNT;
         SET @Ln_AppTotExptPay_AMNT = @Ln_AppTotExptPay_AMNT + @Ln_TransactionExptPay_AMNT;
         SET @Ln_AppTotNaa_AMNT = @Ln_AppTotNaa_AMNT + @Ln_TransactionNaa_AMNT;
         SET @Ln_AppTotTaa_AMNT = @Ln_AppTotTaa_AMNT + @Ln_TransactionTaa_AMNT;
         SET @Ln_AppTotPaa_AMNT = @Ln_AppTotPaa_AMNT + @Ln_TransactionPaa_AMNT;
         SET @Ln_AppTotCaa_AMNT = @Ln_AppTotCaa_AMNT + @Ln_TransactionCaa_AMNT;
         SET @Ln_AppTotUpa_AMNT = @Ln_AppTotUpa_AMNT + @Ln_TransactionUpa_AMNT;
         SET @Ln_AppTotUda_AMNT = @Ln_AppTotUda_AMNT + @Ln_TransactionUda_AMNT;
         SET @Ln_AppTotIvef_AMNT = @Ln_AppTotIvef_AMNT + @Ln_TransactionIvef_AMNT;
         SET @Ln_AppTotMedi_AMNT = @Ln_AppTotMedi_AMNT + @Ln_TransactionMedi_AMNT;
         SET @Ln_AppTotNffc_AMNT = @Ln_AppTotNffc_AMNT + @Ln_TransactionNffc_AMNT;
         SET @Ln_AppTotNonIvd_AMNT = @Ln_AppTotNonIvd_AMNT + @Ln_TransactionNonIvd_AMNT;
         SET @Ln_AppTotFuture_AMNT = ISNULL(@Ln_AppTotFuture_AMNT, 0) + @Ln_TransactionFuture_AMNT;
         SET @Ln_TransactionCurSup_AMNT = 0;
         SET @Ln_TransactionExptPay_AMNT = 0;
         SET @Ln_TransactionPaa_AMNT = 0;
         SET @Ln_TransactionTaa_AMNT = 0;
         SET @Ln_TransactionCaa_AMNT = 0;
         SET @Ln_TransactionUda_AMNT = 0;
         SET @Ln_TransactionUpa_AMNT = 0;
         SET @Ln_TransactionNaa_AMNT = 0;
         SET @Ln_TransactionIvef_AMNT = 0;
         SET @Ln_TransactionMedi_AMNT = 0;
         SET @Ln_TransactionNffc_AMNT = 0;
         SET @Ln_TransactionNonIvd_AMNT = 0;
         SET @Ln_TransactionFuture_AMNT = 0;
         SET @Ln_AdjustPaa_AMNT = 0;
         SET @Ln_AdjustTaa_AMNT = 0;
         SET @Ln_AdjustCaa_AMNT = 0;
         SET @Ln_AdjustUda_AMNT = 0;
         SET @Ln_AdjustUpa_AMNT = 0;
         SET @Ln_AdjustNaa_AMNT = 0;
         SET @Ln_AdjustNffc_AMNT = 0;
         SET @Ln_AdjustNonIvd_AMNT = 0;

         IF (@Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT) > 0
          BEGIN
           SET @Ln_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT + (@Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT);
           SET @Ln_TransactionUpa_AMNT = (@Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT) * -1;
          END

         IF (@Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT) > 0
          BEGIN
           SET @Ln_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT + (@Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT);
           SET @Ln_TransactionTaa_AMNT = (@Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT) * -1;
          END

         IF (@Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT) > 0
          BEGIN
           SET @Ln_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT + (@Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT);
           SET @Ln_TransactionCaa_AMNT = (@Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT) * -1;
          END

         IF @Lc_TypeDebt_CODE NOT IN (@Lc_DebtTypeMedicaid_CODE, @Lc_DebtTypeIntMedicaid_CODE, @Lc_DebtTypeCashMedical_CODE, @Lc_DebtTypeIntCashMedical_CODE,
                                      @Lc_ValueDp_CODE, @Lc_ValueCp_CODE, @Lc_ValueFp_CODE, @Lc_ValueMp_CODE,
                                      @Lc_ValuePp_CODE, @Lc_ValueSp_CODE, @Lc_ValueAf_CODE, @Lc_ValueBf_CODE,
                                      @Lc_ValueCf_CODE, @Lc_ValueMf_CODE)
            AND SUBSTRING(@Lc_Fips_CODE, 1, 2) = @Lc_InStateFips_CODE
            AND @Lc_TypeWelfare_CODE IN (@Lc_TypeWelfareTanf_CODE, @Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE)
          BEGIN
           SET @Ln_ArrPaaCirc_AMNT = @Ln_OweTotPaa_AMNT - @Ln_AppTotPaa_AMNT + @Ln_TransactionPaa_AMNT;
           SET @Ln_ArrUdaCirc_AMNT = @Ln_OweTotUda_AMNT - @Ln_AppTotUda_AMNT + @Ln_TransactionUda_AMNT;
           SET @Ln_ArrNaaCirc_AMNT = @Ln_OweTotNaa_AMNT - @Ln_AppTotNaa_AMNT + @Ln_TransactionNaa_AMNT;
           SET @Ln_ArrCaaCirc_AMNT = @Ln_OweTotCaa_AMNT - @Ln_AppTotCaa_AMNT + @Ln_TransactionCaa_AMNT;
           SET @Ln_ArrUpaCirc_AMNT = @Ln_OweTotUpa_AMNT - @Ln_AppTotUpa_AMNT + @Ln_TransactionUpa_AMNT;
           SET @Ln_ArrTaaCirc_AMNT = @Ln_OweTotTaa_AMNT - @Ln_AppTotTaa_AMNT + @Ln_TransactionTaa_AMNT;

           IF @Ln_SupportYearMonth_NUMB = CONVERT(VARCHAR(6), @Ld_Process_DATE, 112)
            BEGIN
            IF @Lc_TypeWelfare_CODE = @Lc_TypeWelfareTanf_CODE
             BEGIN
              SET @Ln_ArrPaaCirc_AMNT = @Ln_ArrPaaCirc_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
             END
            ELSE
             BEGIN
              IF @Lc_TypeWelfare_CODE IN (@Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareMedicaid_CODE)
               BEGIN
                SET @Ln_ArrNaaCirc_AMNT = @Ln_ArrNaaCirc_AMNT - (@Ln_OweTotCurSup_AMNT - @Ln_AppTotCurSup_AMNT);
               END
             END
			END
           IF (@Ln_ArrPaaCirc_AMNT < 0
                OR @Ln_ArrUdaCirc_AMNT < 0
                OR @Ln_ArrNaaCirc_AMNT < 0
                OR @Ln_ArrCaaCirc_AMNT < 0
                OR @Ln_ArrUpaCirc_AMNT < 0
                OR @Ln_ArrTaaCirc_AMNT < 0)
            BEGIN
             SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CIRCULAR_RULE';
             SET @Ls_Sqldata_TEXT = '';
             
             EXECUTE BATCH_COMMON$SP_CIRCULAR_RULE
              @An_ArrPaa_AMNT         = @Ln_ArrPaaCirc_AMNT OUTPUT,
              @An_TransactionPaa_AMNT = @Ln_TransactionPaa_AMNT OUTPUT,
              @An_ArrUda_AMNT         = @Ln_ArrUdaCirc_AMNT OUTPUT,
              @An_TransactionUda_AMNT = @Ln_TransactionUda_AMNT OUTPUT,
              @An_ArrNaa_AMNT         = @Ln_ArrNaaCirc_AMNT OUTPUT,
              @An_TransactionNaa_AMNT = @Ln_TransactionNaa_AMNT OUTPUT,
              @An_ArrCaa_AMNT         = @Ln_ArrCaaCirc_AMNT OUTPUT,
              @An_TransactionCaa_AMNT = @Ln_TransactionCaa_AMNT OUTPUT,
              @An_ArrUpa_AMNT         = @Ln_ArrUpaCirc_AMNT OUTPUT,
              @An_TransactionUpa_AMNT = @Ln_TransactionUpa_AMNT OUTPUT,
              @An_ArrTaa_AMNT         = @Ln_ArrTaaCirc_AMNT OUTPUT,
              @An_TransactionTaa_AMNT = @Ln_TransactionTaa_AMNT OUTPUT;
            END
          END

         IF (@Ln_TransactionPaa_AMNT <> 0
              OR @Ln_TransactionTaa_AMNT <> 0
              OR @Ln_TransactionCaa_AMNT <> 0
              OR @Ln_TransactionUda_AMNT <> 0
              OR @Ln_TransactionUpa_AMNT <> 0
              OR @Ln_TransactionNaa_AMNT <> 0)
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y11 ';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @Ln_ObligationSeq_NUMB AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_TypeWelfare_CODE,'')+ ', MtdCurSupOwed_AMNT = ' + ISNULL(CAST( @Ln_MtdCurSupOwed_AMNT AS VARCHAR ),'')+ ', TransactionCurSup_AMNT = ' + ISNULL(CAST( @Ln_TransactionCurSup_AMNT AS VARCHAR ),'')+ ', OweTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_OweTotCurSup_AMNT AS VARCHAR ),'')+ ', AppTotCurSup_AMNT = ' + ISNULL(CAST( @Ln_AppTotCurSup_AMNT AS VARCHAR ),'')+ ', TransactionExptPay_AMNT = ' + ISNULL(CAST( @Ln_TransactionExptPay_AMNT AS VARCHAR ),'')+ ', OweTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_OweTotExptPay_AMNT AS VARCHAR ),'')+ ', AppTotExptPay_AMNT = ' + ISNULL(CAST( @Ln_AppTotExptPay_AMNT AS VARCHAR ),'')+ ', TransactionNaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionNaa_AMNT AS VARCHAR ),'')+ ', AppTotNaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotNaa_AMNT AS VARCHAR ),'')+ ', TransactionTaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionTaa_AMNT AS VARCHAR ),'')+ ', AppTotTaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotTaa_AMNT AS VARCHAR ),'')+ ', TransactionPaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionPaa_AMNT AS VARCHAR ),'')+ ', AppTotPaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotPaa_AMNT AS VARCHAR ),'')+ ', TransactionCaa_AMNT = ' + ISNULL(CAST( @Ln_TransactionCaa_AMNT AS VARCHAR ),'')+ ', AppTotCaa_AMNT = ' + ISNULL(CAST( @Ln_AppTotCaa_AMNT AS VARCHAR ),'')+ ', TransactionUpa_AMNT = ' + ISNULL(CAST( @Ln_TransactionUpa_AMNT AS VARCHAR ),'')+ ', AppTotUpa_AMNT = ' + ISNULL(CAST( @Ln_AppTotUpa_AMNT AS VARCHAR ),'')+ ', TransactionUda_AMNT = ' + ISNULL(CAST( @Ln_TransactionUda_AMNT AS VARCHAR ),'')+ ', AppTotUda_AMNT = ' + ISNULL(CAST( @Ln_AppTotUda_AMNT AS VARCHAR ),'')+ ', TransactionIvef_AMNT = ' + ISNULL('0','')+ ', OweTotIvef_AMNT = ' + ISNULL(CAST( @Ln_OweTotIvef_AMNT AS VARCHAR ),'')+ ', AppTotIvef_AMNT = ' + ISNULL(CAST( @Ln_AppTotIvef_AMNT AS VARCHAR ),'')+ ', TransactionMedi_AMNT = ' + ISNULL('0','')+ ', OweTotMedi_AMNT = ' + ISNULL(CAST( @Ln_OweTotMedi_AMNT AS VARCHAR ),'')+ ', AppTotMedi_AMNT = ' + ISNULL(CAST( @Ln_AppTotMedi_AMNT AS VARCHAR ),'')+ ', TransactionNffc_AMNT = ' + ISNULL(CAST( @Ln_TransactionNffc_AMNT AS VARCHAR ),'')+ ', AppTotNffc_AMNT = ' + ISNULL(CAST( @Ln_AppTotNffc_AMNT AS VARCHAR ),'')+ ', TransactionNonIvd_AMNT = ' + ISNULL(CAST( @Ln_TransactionNonIvd_AMNT AS VARCHAR ),'')+ ', AppTotNonIvd_AMNT = ' + ISNULL(CAST( @Ln_AppTotNonIvd_AMNT AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL('0','')+ ', SeqReceipt_NUMB = ' + ISNULL('0','')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqLsupGrant_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_CircularRuleRecord1070_NUMB AS VARCHAR),'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

           INSERT LSUP_Y1
                  (Case_IDNO,
                   OrderSeq_NUMB,
                   ObligationSeq_NUMB,
                   SupportYearMonth_NUMB,
                   TypeWelfare_CODE,
                   MtdCurSupOwed_AMNT,
                   TransactionCurSup_AMNT,
                   OweTotCurSup_AMNT,
                   AppTotCurSup_AMNT,
                   TransactionExptPay_AMNT,
                   OweTotExptPay_AMNT,
                   AppTotExptPay_AMNT,
                   TransactionNaa_AMNT,
                   OweTotNaa_AMNT,
                   AppTotNaa_AMNT,
                   TransactionTaa_AMNT,
                   OweTotTaa_AMNT,
                   AppTotTaa_AMNT,
                   TransactionPaa_AMNT,
                   OweTotPaa_AMNT,
                   AppTotPaa_AMNT,
                   TransactionCaa_AMNT,
                   OweTotCaa_AMNT,
                   AppTotCaa_AMNT,
                   TransactionUpa_AMNT,
                   OweTotUpa_AMNT,
                   AppTotUpa_AMNT,
                   TransactionUda_AMNT,
                   OweTotUda_AMNT,
                   AppTotUda_AMNT,
                   TransactionIvef_AMNT,
                   OweTotIvef_AMNT,
                   AppTotIvef_AMNT,
                   TransactionMedi_AMNT,
                   OweTotMedi_AMNT,
                   AppTotMedi_AMNT,
                   TransactionNffc_AMNT,
                   OweTotNffc_AMNT,
                   AppTotNffc_AMNT,
                   TransactionNonIvd_AMNT,
                   OweTotNonIvd_AMNT,
                   AppTotNonIvd_AMNT,
                   TransactionFuture_AMNT,
                   AppTotFuture_AMNT,
                   Batch_DATE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   SourceBatch_CODE,
                   Receipt_DATE,
                   Distribute_DATE,
                   TypeRecord_CODE,
                   EventGlobalSeq_NUMB,
                   EventFunctionalSeq_NUMB,
                   CheckRecipient_ID,
                   CheckRecipient_CODE)
             SELECT @Ln_Case_IDNO AS Case_IDNO ,
                    @Ln_OrderSeq_NUMB AS OrderSeq_NUMB ,
                    @Ln_ObligationSeq_NUMB AS ObligationSeq_NUMB ,
                    @Ln_SupportYearMonth_NUMB AS SupportYearMonth_NUMB ,
                    @Lc_TypeWelfare_CODE AS TypeWelfare_CODE ,
                    @Ln_MtdCurSupOwed_AMNT AS MtdCurSupOwed_AMNT ,
                    @Ln_TransactionCurSup_AMNT AS TransactionCurSup_AMNT ,
                    @Ln_OweTotCurSup_AMNT AS OweTotCurSup_AMNT ,
                    @Ln_AppTotCurSup_AMNT AS AppTotCurSup_AMNT ,
                    @Ln_TransactionExptPay_AMNT AS TransactionExptPay_AMNT ,
                    @Ln_OweTotExptPay_AMNT AS OweTotExptPay_AMNT ,
                    @Ln_AppTotExptPay_AMNT AS AppTotExptPay_AMNT ,
                    @Ln_TransactionNaa_AMNT AS TransactionNaa_AMNT, 
                    @Ln_OweTotNaa_AMNT + @Ln_TransactionNaa_AMNT AS OweTotNaa_AMNT ,
                    @Ln_AppTotNaa_AMNT AS AppTotNaa_AMNT ,
                    @Ln_TransactionTaa_AMNT AS TransactionTaa_AMNT ,
                    @Ln_OweTotTaa_AMNT + @Ln_TransactionTaa_AMNT AS OweTotTaa_AMNT ,
                    @Ln_AppTotTaa_AMNT AS AppTotTaa_AMNT ,
                    @Ln_TransactionPaa_AMNT AS TransactionPaa_AMNT ,
                    @Ln_OweTotPaa_AMNT + @Ln_TransactionPaa_AMNT AS OweTotPaa_AMNT ,
                    @Ln_AppTotPaa_AMNT AS AppTotPaa_AMNT ,
                    @Ln_TransactionCaa_AMNT AS TransactionCaa_AMNT ,
                    @Ln_OweTotCaa_AMNT + @Ln_TransactionCaa_AMNT AS OweTotCaa_AMNT ,
                    @Ln_AppTotCaa_AMNT AS AppTotCaa_AMNT ,
                    @Ln_TransactionUpa_AMNT AS TransactionUpa_AMNT ,
                    @Ln_OweTotUpa_AMNT + @Ln_TransactionUpa_AMNT AS OweTotUpa_AMNT ,
                    @Ln_AppTotUpa_AMNT AS AppTotUpa_AMNT ,
                    @Ln_TransactionUda_AMNT AS TransactionUda_AMNT ,
                    @Ln_OweTotUda_AMNT + @Ln_TransactionUda_AMNT AS OweTotUda_AMNT ,
                    @Ln_AppTotUda_AMNT AS AppTotUda_AMNT ,
                    0 AS TransactionIvef_AMNT ,
                    @Ln_OweTotIvef_AMNT AS OweTotIvef_AMNT ,
                    @Ln_AppTotIvef_AMNT AS AppTotIvef_AMNT ,
                    0 AS TransactionMedi_AMNT ,
                    @Ln_OweTotMedi_AMNT AS OweTotMedi_AMNT ,
                    @Ln_AppTotMedi_AMNT AS AppTotMedi_AMNT ,
                    @Ln_TransactionNffc_AMNT AS TransactionNffc_AMNT ,
                    @Ln_OweTotNffc_AMNT + @Ln_TransactionNffc_AMNT AS OweTotNffc_AMNT ,
                    @Ln_AppTotNffc_AMNT AS AppTotNffc_AMNT ,
                    @Ln_TransactionNonIvd_AMNT AS TransactionNonIvd_AMNT ,
                    @Ln_OweTotNonIvd_AMNT + @Ln_TransactionNonIvd_AMNT AS OweTotNonIvd_AMNT ,
                    @Ln_AppTotNonIvd_AMNT AS AppTotNonIvd_AMNT ,
                    ISNULL(@Ln_TransactionFuture_AMNT, 0) AS TransactionFuture_AMNT ,
                    ISNULL(@Ln_AppTotFuture_AMNT, 0) AS AppTotFuture_AMNT ,
                    @Ld_Low_DATE AS Batch_DATE ,
                    0 AS Batch_NUMB ,
                    0 AS SeqReceipt_NUMB ,
                    @Lc_Space_TEXT AS SourceBatch_CODE ,
                    @Ld_Low_DATE AS Receipt_DATE ,
                    @Ld_Process_DATE AS Distribute_DATE ,
                    @Lc_Space_TEXT AS TypeRecord_CODE ,
                    @Ln_EventGlobalSeqLsupGrant_NUMB AS EventGlobalSeq_NUMB ,
                    @Li_CircularRuleRecord1070_NUMB AS EventFunctionalSeq_NUMB ,
                    @Lc_Space_TEXT AS CheckRecipient_ID ,
                    @Lc_Space_TEXT AS CheckRecipient_CODE;
                    
           SET @Ln_RowCount_QNTY = @@ROWCOUNT;

           IF @Ln_RowCount_QNTY = 0
            BEGIN
             RAISERROR(50001,16,1);
            END
          END

         SET @Ln_SupportYearMonth_NUMB = CONVERT(VARCHAR(6), (DATEADD(M, 1, CONVERT(VARCHAR(8), CAST(@Ln_SupportYearMonth_NUMB AS VARCHAR) + '01', 112))), 112);
         SET @Lc_TypeRecord_CODE = @Lc_TypeRecordPrior_CODE;
        END

       SET @Ln_CasePrev_IDNO = @Ln_Case_IDNO;
       SET @Ln_OrderPrevseq_NUMB = @Ln_OrderSeq_NUMB;
       SET @Ln_ObligationPrevseq_NUMB = @Ln_ObligationSeq_NUMB;

       FETCH NEXT FROM Lsup_Cur INTO @Ln_LsupCur_Case_IDNO, @Ln_LsupCur_OrderSeq_NUMB, @Ln_LsupCur_ObligationSeq_NUMB, @Ln_LsupCur_SupportYearMonth_NUMB, @Ln_LsupCur_TransactionCurSup_AMNT, @Ln_LsupCur_TransactionExptPay_AMNT, @Ln_LsupCur_TransactionNaa_AMNT, @Ln_LsupCur_TransactionTaa_AMNT, @Ln_LsupCur_TransactionPaa_AMNT, @Ln_LsupCur_TransactionCaa_AMNT, @Ln_LsupCur_TransactionUpa_AMNT, @Ln_LsupCur_TransactionUda_AMNT, @Ln_LsupCur_TransactionIvef_AMNT, @Ln_LsupCur_TransactionMedi_AMNT, @Ln_LsupCur_TransactionFuture_AMNT, @Ln_LsupCur_TransactionNffc_AMNT, @Ln_LsupCur_TransactionNonIvd_AMNT;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     IF CURSOR_STATUS('Local', 'Lsup_Cur') IN (0, 1)
      BEGIN
       CLOSE Lsup_Cur;

       DEALLOCATE Lsup_Cur;
      END

     IF @Lc_SourceBatch_CODE = @Lc_ChildSrcDirectPayCredit_CODE
      BEGIN
       GOTO PROCESS_ELOG;
      END

     SET @Ls_Sql_TEXT = 'INSERT_TRREP';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ld_BatchOrig_DATE AS VARCHAR) +  ', Batch_NUMB = ' +  CAST(@Ln_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SourceBatch_CODE+ ', TypeDisburse_CODE IN ( ' + @Lc_TypeDisburseCgpaa_CODE +', ' + @Lc_TypeDisbursePgpaa_CODE+', ' + @Lc_TypeDisburseAgpaa_CODE +', ' + @Lc_TypeDisburseAgtaa_CODE+', ' + @Lc_TypeDisburseAgcaa_CODE+', ' + @Lc_TypeDisburseAgive_CODE+', ' + @Lc_TypeDisburseCgive_CODE +')';

     INSERT #RrepWelfare_P1
            (CaseWelfare_IDNO,
             WelfareYearMonth_NUMB,
             MtdRecoupTanf_AMNT,
             LtdRecoupTanf_AMNT,
             MtdRecoupFc_AMNT,
             LtdRecoupFc_AMNT)
     SELECT a.CaseWelfare_IDNO,
            a.WelfareYearMonth_NUMB,
            SUM(CASE
                 WHEN a.TypeDisburse_CODE IN (@Lc_TypeDisburseCgpaa_CODE)
                  THEN a.Distribute_AMNT
                 ELSE 0
                END) AS MtdRecoupTanf_AMNT,
            SUM(CASE
                 WHEN a.TypeDisburse_CODE IN (@Lc_TypeDisburseCgpaa_CODE, @Lc_TypeDisburseAgive_CODE, @Lc_TypeDisburseCgive_CODE)
                  THEN 0
                 ELSE a.Distribute_AMNT
                END) AS LtdRecoupTanf_AMNT,
            SUM(CASE
                 WHEN a.TypeDisburse_CODE IN (@Lc_TypeDisburseCgive_CODE)
                  THEN a.Distribute_AMNT
                 ELSE 0
                END) AS MtdRecoupFc_AMNT,
            SUM(CASE
                 WHEN a.TypeDisburse_CODE IN (@Lc_TypeDisburseAgive_CODE)
                  THEN a.Distribute_AMNT
                 ELSE 0
                END) AS LtdRecoupFc_AMNT
       FROM LWEL_Y1 a
      WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
        AND a.Batch_NUMB = @Ln_Batch_NUMB
        AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND a.TypeDisburse_CODE IN (@Lc_TypeDisburseCgpaa_CODE, @Lc_TypeDisbursePgpaa_CODE, @Lc_TypeDisburseAgpaa_CODE, @Lc_TypeDisburseAgtaa_CODE,
                                    @Lc_TypeDisburseAgcaa_CODE, @Lc_TypeDisburseAgive_CODE, @Lc_TypeDisburseCgive_CODE)
      GROUP BY a.CaseWelfare_IDNO,
               a.WelfareYearMonth_NUMB
     HAVING SUM(a.Distribute_AMNT) > 0;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END

     SET @Ls_Sql_TEXT = 'INSERT_VLWEL ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CONVERT(VARCHAR(10), @Ld_BatchOrig_DATE, 101), '') + ', SRCE_BATCH = ' + ISNULL(@Lc_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_Batch_NUMB AS NVARCHAR(4)), '') + ', SEQ_RCPT = ' + ISNULL(CAST(@Ln_SeqReceipt_NUMB AS VARCHAR), '');

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
     SELECT a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             a.WelfareYearMonth_NUMB,
             @Ld_BatchOrig_DATE AS Batch_DATE,
             @Ln_Batch_NUMB AS Batch_NUMB,
             @Ln_SeqReceipt_NUMB AS SeqReceipt_NUMB,
             @Lc_SourceBatch_CODE AS SourceBatch_CODE,
             a.CaseWelfare_IDNO,
             @Lc_Space_TEXT AS TypeWelfare_CODE,
             @Ld_Process_DATE AS Distribute_DATE,
             SUM(a.Distribute_AMNT) * -1 AS Distribute_AMNT,
             a.TypeDisburse_CODE,
             @Ln_EventGlobalSeqRcthBackOut_NUMB AS EventGlobalSeq_NUMB,
             @Ln_EventGlobalSeqRcthBackOut_NUMB AS EventGlobalSupportSeq_NUMB
        FROM LWEL_Y1 a
       WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
         AND a.Batch_NUMB = @Ln_Batch_NUMB
         AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
         AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
       GROUP BY a.Case_IDNO,
                a.OrderSeq_NUMB,
                a.ObligationSeq_NUMB,
                a.CaseWelfare_IDNO,
                a.TypeDisburse_CODE,
                a.WelfareYearMonth_NUMB
      HAVING SUM(a.Distribute_AMNT) > 0;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END

     PROCESS_OFFSET:

     SET @Ls_Sql_TEXT = 'UPDATE_DHLD_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE DHLD_Y1
        SET EndValidity_DATE = @Ld_Process_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB
      WHERE Batch_DATE = @Ld_BatchOrig_DATE
        AND SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND Batch_NUMB = @Ln_Batch_NUMB
        AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      END

     RECOUPMENT:

     IF @Lc_SourceBatch_CODE <> @Lc_ChildSrcDirectPayCredit_CODE
      BEGIN
       SET @Ln_EventGlobalSeqBackOutLsup_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB;
       SET @Ln_EventGloablSeqBackOut_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB;
       
       SET @Ls_Sql_TEXT = 'DELETE_RrepOffsetOverride_P1';
       SET @Ls_Sqldata_TEXT = '';

       DELETE #RrepOffsetOverride_P1;

       SET @Lc_TypeRecoupment_CODE = @Lc_TypeRecoupmentRegular_CODE;
       SET @Lc_RecoupmentPayee_CODE = @Lc_RecoupmentPayeeState_CODE;
       
       SET @Ls_Sql_TEXT = 'INSERT_RrepOffsetOverride_P1';
       SET @Ls_Sqldata_TEXT = '';

       INSERT #RrepOffsetOverride_P1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Case_IDNO,
               RecOvpyOrig_AMNT,
               PaidToCpOrig_AMNT,
               TypeDisburse_CODE,
               TypeRecoupment_CODE,
               RecoupmentPayee_CODE)
       SELECT CASE
               WHEN (a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                     AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE)
                THEN @Ln_PayorMCI_IDNO
               WHEN (a.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                     AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseRothp_CODE))
                THEN (SELECT TOP 1 c.MemberMci_IDNO
                        FROM CMEM_Y1 c
                       WHERE c.Case_IDNO = a.Case_IDNO
                         AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                         AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                          OR (CaseMemberStatus_CODE = @Lc_StatusCaseMemberInactive_CODE
                              AND NOT EXISTS (SELECT 1
                                                FROM CMEM_Y1 c1
                                               WHERE c1.Case_IDNO = a.Case_IDNO
                                                 AND c1.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                                                 AND c1.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)))
               ELSE a.CheckRecipient_ID
              END AS CheckRecipient_ID,--CheckRecipient_ID
              CASE a.CheckRecipient_CODE
               WHEN @Lc_RecipientTypeFips_CODE
                THEN @Lc_RecipientTypeCpNcp_CODE
               ELSE a.CheckRecipient_CODE
              END AS CheckRecipient_CODE,--CheckRecipient_CODE
              a.Case_IDNO,--Case_IDNO
              0 AS RecOverpay_AMNT,--RecOvpyOrig_AMNT 
              a.Disburse_AMNT,--PaidToCpOrig_AMNT
              --Active recoupment created for
              CASE --Agencies
               WHEN a.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
                THEN @Lc_ActiveRecoupmentA_CODE
               ----Fips													
               --NCP refunds
               WHEN a.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                THEN @Lc_ActiveRecoupmentA_CODE
               --For others create Pending Recoupment 		      
               ELSE @Lc_PendingRecoupmentP_CODE
              END AS TypeDisburse_CODE,--TypeDisburse_CODE
              @Lc_TypeRecoupment_CODE,--TypeRecoupment_CODE  
              @Lc_RecoupmentPayee_CODE --RecoupmentPayee_CODE
         FROM DSBL_Y1 a
              LEFT OUTER JOIN CASE_Y1 b
               ON a.Case_IDNO = b.Case_IDNO
        WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
          AND a.Batch_NUMB = @Ln_Batch_NUMB
          AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
          AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
          AND EXISTS (SELECT 1
                        FROM DSBH_Y1 b
                       WHERE b.CheckRecipient_ID = a.CheckRecipient_ID
                         AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
                         AND b.Disburse_DATE = a.Disburse_DATE
                         AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB
                         AND b.EndValidity_DATE = @Ld_High_DATE
                         AND b.StatusCheck_CODE IN (@Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusCashed_CODE))
          AND NOT EXISTS (SELECT 1
                            FROM OTHP_Y1 c
                           WHERE a.CheckRecipient_ID = c.OtherParty_IDNO
                             AND c.TypeOthp_CODE = @Lc_TypeOthpFeeRecipient1_CODE
                             AND c.EndValidity_DATE = @Ld_High_DATE)
       UNION ALL
       SELECT a.CheckRecipient_ID,--CheckRecipient_ID 
              a.CheckRecipient_CODE,--CheckRecipient_CODE 
              a.Case_IDNO,--Case_IDNO 
              a.RecOverpay_AMNT,--RecOvpyOrig_AMNT 
              0 AS Disburse_AMNT,--PaidToCpOrig_AMNT 
              @Lc_Space_TEXT AS TypeDisburse_CODE,--TypeDisburse_CODE 
              a.TypeRecoupment_CODE,--TypeRecoupment_CODE
              a.RecoupmentPayee_CODE --RecoupmentPayee_CODE
         FROM POFL_Y1 a
        WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
          AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
          AND a.Batch_NUMB = @Ln_Batch_NUMB
          AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB;

       DECLARE Receipt_Cur INSENSITIVE CURSOR FOR
        SELECT a.CheckRecipient_ID,
               a.CheckRecipient_CODE,
               a.Case_IDNO,
               a.TypeDisburse_CODE,
               a.TypeRecoupment_CODE,
               a.RecoupmentPayee_CODE,
               SUM(a.RecOvpyOrig_AMNT) AS RecOverpay_AMNT,
               SUM(a.PaidToCpOrig_AMNT) AS AssessOverpay_AMNT
          FROM #RrepOffsetOverride_P1 a
         GROUP BY a.CheckRecipient_ID,
                  a.CheckRecipient_CODE,
                  a.Case_IDNO,
                  a.TypeDisburse_CODE,
                  a.TypeRecoupment_CODE,
                  a.RecoupmentPayee_CODE
        HAVING SUM(a.RecOvpyOrig_AMNT) > 0
                OR SUM(a.PaidToCpOrig_AMNT) > 0;

       OPEN Receipt_Cur;

       FETCH NEXT FROM Receipt_Cur INTO @Lc_ReciptCur_CheckRecipient_ID, @Lc_ReciptCur_CheckRecipient_CODE, @Ln_ReceiptCur_Case_IDNO, @Lc_ReceiptCur_TypeDisburse_CODE, @Lc_ReceiptCur_TypeRecoupment_CODE, @Lc_ReceiptCur_RecoupmentPayee_CODE, @Ln_ReceiptCur_RecOverpay_AMNT, @Ln_ReceiptCur_AssessOverpay_AMNT;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

       --fetch each record
       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         SET @Lc_PoflCheckRecipient_ID = @Lc_ReciptCur_CheckRecipient_ID;
         SET @Lc_PoflCheckRecipient_CODE = @Lc_ReciptCur_CheckRecipient_CODE;
         
         SET @Ls_Sql_TEXT = 'SELECT_POFL_Y11 ';
         SET @Ls_Sqldata_TEXT = 'ICheckRecipient_IDD_CHECK_RECP = ' + ISNULL(@Lc_PoflCheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_PoflCheckRecipient_CODE, '') + ', TypeRecoupment_CODE = ' + ISNULL(@Lc_ReceiptCur_TypeRecoupment_CODE, '') + ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_ReceiptCur_RecoupmentPayee_CODE, '');

         SELECT @Ln_AssessTotOverpay_AMNT = b.AssessTotOverpay_AMNT,
                @Ln_RecTotOverpay_AMNT = b.RecTotOverpay_AMNT,
                @Ln_PendTotOffset_AMNT = b.PendTotOffset_AMNT
           FROM (SELECT a.AssessTotOverpay_AMNT,
                        a.RecTotOverpay_AMNT,
                        a.PendTotOffset_AMNT,
                        ROW_NUMBER() OVER (PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE ORDER BY a.Unique_IDNO DESC) AS rnk
                   FROM POFL_Y1 a
                  WHERE a.CheckRecipient_ID = @Lc_PoflCheckRecipient_ID
                    AND a.CheckRecipient_CODE = @Lc_PoflCheckRecipient_CODE
                    AND a.TypeRecoupment_CODE = @Lc_ReceiptCur_TypeRecoupment_CODE 
                    AND a.RecoupmentPayee_CODE = @Lc_ReceiptCur_RecoupmentPayee_CODE
                ) b
          WHERE b.rnk = 1;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ln_AssessTotOverpay_AMNT = 0;
           SET @Ln_RecTotOverpay_AMNT = 0;
           SET @Ln_PendTotOffset_AMNT = 0;
          END

         SET @Ln_PendOffset_AMNT = 0;
         SET @Ln_AssessOverpay_AMNT = 0;

         IF @Lc_ReceiptCur_TypeDisburse_CODE = @Lc_ActiveRecoupmentA_CODE
          BEGIN
           SET @Ln_AssessOverpay_AMNT = @Ln_ReceiptCur_AssessOverpay_AMNT;
           SET @Ln_PendOffset_AMNT = 0;
           SET @Lc_Transaction_CODE = @Lc_TransactionBkrc_CODE;
          END
         ELSE
          BEGIN
           SET @Ln_AssessOverpay_AMNT = 0;
           SET @Ln_PendOffset_AMNT = @Ln_ReceiptCur_AssessOverpay_AMNT;
           SET @Lc_Transaction_CODE = @Lc_TransactionBkpe_CODE;
          END

         SET @Ls_Sql_TEXT = 'INSERT_POFL_Y1 ';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_PoflCheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_PoflCheckRecipient_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_ReceiptCur_Case_IDNO AS VARCHAR ),'')+ ', TypeRecoupment_CODE = ' + ISNULL(@Lc_ReceiptCur_TypeRecoupment_CODE,'')+ ', RecoupmentPayee_CODE = ' + ISNULL(@Lc_ReceiptCur_RecoupmentPayee_CODE,'')+ ', OrderSeq_NUMB = ' + ISNULL('0','')+ ', ObligationSeq_NUMB = ' + ISNULL('0','')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PendOffset_AMNT = ' + ISNULL(CAST( @Ln_PendOffset_AMNT AS VARCHAR ),'')+ ', AssessOverpay_AMNT = ' + ISNULL(CAST( @Ln_AssessOverpay_AMNT AS VARCHAR ),'')+ ', Reason_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE,'')+ ', RecAdvance_AMNT = ' + ISNULL('0','')+ ', RecTotAdvance_AMNT = ' + ISNULL('0','')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Transaction_CODE = ' + ISNULL(@Lc_Transaction_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGloablSeqBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBackOutLsup_NUMB AS VARCHAR ),'');

         INSERT POFL_Y1
                (CheckRecipient_ID,
                 CheckRecipient_CODE,
                 Case_IDNO,
                 TypeRecoupment_CODE,
                 RecoupmentPayee_CODE,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 Transaction_DATE,
                 TypeDisburse_CODE,
                 PendOffset_AMNT,
                 PendTotOffset_AMNT,
                 AssessOverpay_AMNT,
                 AssessTotOverpay_AMNT,
                 Reason_CODE,
                 RecAdvance_AMNT,
                 RecTotAdvance_AMNT,
                 RecOverpay_AMNT,
                 RecTotOverpay_AMNT,
                 Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 Transaction_CODE,
                 EventGlobalSeq_NUMB,
                 EventGlobalSupportSeq_NUMB
         )
         VALUES ( @Lc_PoflCheckRecipient_ID,--CheckRecipient_ID 
                  @Lc_PoflCheckRecipient_CODE,--CheckRecipient_CODE 
                  @Ln_ReceiptCur_Case_IDNO,--Case_IDNO 
                  @Lc_ReceiptCur_TypeRecoupment_CODE,--TypeRecoupment_CODE 
                  @Lc_ReceiptCur_RecoupmentPayee_CODE,--RecoupmentPayee_CODE 
                  0,--OrderSeq_NUMB 
                  0,--ObligationSeq_NUMB 
                  @Ld_Process_DATE,--Transaction_DATE 
                  @Lc_Space_TEXT,--TypeDisburse_CODE 
                  @Ln_PendOffset_AMNT,--PendOffset_AMNT 
                  @Ln_PendTotOffset_AMNT + @Ln_PendOffset_AMNT,--PendTotOffset_AMNT 
                  @Ln_AssessOverpay_AMNT,--AssessOverpay_AMNT 
                  @Ln_AssessTotOverpay_AMNT + @Ln_AssessOverpay_AMNT,--AssessTotOverpay_AMNT 
                  @Ac_ReasonBackOut_CODE,--Reason_CODE 
                  0,--RecAdvance_AMNT 
                  0,--RecTotAdvance_AMNT 
                  @Ln_ReceiptCur_RecOverpay_AMNT * -1,--RecOverpay_AMNT 
                  @Ln_RecTotOverpay_AMNT + @Ln_ReceiptCur_RecOverpay_AMNT * -1,--RecTotOverpay_AMNT 
                  @Ld_BatchOrig_DATE,--Batch_DATE 
                  @Ln_Batch_NUMB,--Batch_NUMB 
                  @Ln_SeqReceipt_NUMB,--SeqReceipt_NUMB 
                  @Lc_SourceBatch_CODE,--SourceBatch_CODE 
                  @Lc_Transaction_CODE,--Transaction_CODE 
                  @Ln_EventGloablSeqBackOut_NUMB,--EventGlobalSeq_NUMB 
                  @Ln_EventGlobalSeqBackOutLsup_NUMB --EventGlobalSupportSeq_NUMB 
         );

         FETCH NEXT FROM Receipt_Cur INTO @Lc_ReciptCur_CheckRecipient_ID, @Lc_ReciptCur_CheckRecipient_CODE, @Ln_ReceiptCur_Case_IDNO, @Lc_ReceiptCur_TypeDisburse_CODE, @Lc_ReceiptCur_TypeRecoupment_CODE, @Lc_ReceiptCur_RecoupmentPayee_CODE, @Ln_ReceiptCur_RecOverpay_AMNT, @Ln_ReceiptCur_AssessOverpay_AMNT;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       IF CURSOR_STATUS('Local', 'Receipt_Cur') IN (0, 1)
        BEGIN
         CLOSE Receipt_Cur;

         DEALLOCATE Receipt_Cur;
        END

       CP_FEE_PROCESS:

       --CP Fee Processing 	
       SET @Ls_Sql_TEXT = 'DELETE_RrepCpFeeTrans_P1';
       SET @Ls_Sqldata_TEXT = '';

       DELETE #RrepCpFeeTrans_P1;

       SET @Ls_Sql_TEXT = 'INSERT RrepCpFeeTrans_P1 ';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ld_BatchOrig_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_Batch_NUMB AS VARCHAR)+ ', SeqReceipt_NUMB = ' + CAST(@Ln_SeqReceipt_NUMB AS VARCHAR);

       INSERT INTO #RrepCpFeeTrans_P1
                   (MemberMci_IDNO,
                    Case_IDNO,
                    FeeType_CODE,
                    Transaction_CODE,
                    Transaction_AMNT,
                    AssessedYear_NUMB)
       SELECT a.MemberMci_IDNO,
              a.Case_IDNO,
              a.FeeType_CODE,
              a.Transaction_CODE,
              a.Transaction_AMNT,
              a.AssessedYear_NUMB
         FROM CPFL_Y1 a
        WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
          AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
          AND a.Batch_NUMB = @Ln_Batch_NUMB
          AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB;

       SET @Lc_CpflInsertFlag_INDC = @Lc_Yes_INDC;
       SET @Lc_CpflTransaction_CODE = @Lc_Space_TEXT;

       DECLARE Cpfl_Cur INSENSITIVE CURSOR FOR
        SELECT a.MemberMci_IDNO,
               a.Case_IDNO,
               a.FeeType_CODE,
               a.Transaction_CODE,
               SUM(a.Transaction_AMNT) AS Transaction_AMNT,
               MAX(a.AssessedYear_NUMB) AS AssessedYear_NUMB
          FROM #RrepCpFeeTrans_P1 a
         GROUP BY a.MemberMci_IDNO,
                  a.Case_IDNO,
                  a.FeeType_CODE,
                  a.Transaction_CODE
        HAVING SUM(Transaction_AMNT) > 0
         ORDER BY Transaction_CODE DESC;

       OPEN Cpfl_Cur;

       FETCH NEXT FROM Cpfl_Cur INTO @Ln_CpflCur_MemberMci_IDNO, @Ln_CpflCur_Case_IDNO, @Lc_CpflCur_FeeType_CODE, @Lc_CpflCur_Transaction_CODE, @Ln_CpflCur_Transaction_AMNT, @Ln_CpflCur_AssessedYear_NUMB;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
	   -- fetch each record
       WHILE @Ln_FetchStatus_QNTY = 0
        BEGIN
         SET @Lc_CpflInsertFlag_INDC = @Lc_Yes_INDC;
         SET @Lc_CpflTransaction_CODE = @Lc_Space_TEXT;
         
         SET @Ls_Sql_TEXT = 'SELECT_CPFL_Y11 ';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CpflCur_MemberMci_IDNO AS NVARCHAR), '') + ', FeeType_CODE = ' + ISNULL(@Lc_CpflCur_FeeType_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CpflCur_Case_IDNO AS NVARCHAR), '');

         SELECT @Ln_CpflAssessedTot_AMNT = b.AssessedTot_AMNT,
                @Ln_CpflRecoveredTot_AMNT = b.RecoveredTot_AMNT,
                @Ln_CpflPendTransaction_AMNT = b.Transaction_AMNT
           FROM (SELECT a.RecoveredTot_AMNT,
                        a.AssessedTot_AMNT,
                        a.Transaction_AMNT,
                        a.AssessedYear_NUMB,
                        ROW_NUMBER() OVER (PARTITION BY a.MemberMci_IDNO, a.Case_IDNO, a.FeeType_CODE ORDER BY a.Unique_IDNO DESC) AS rnk
                   FROM CPFL_Y1 a
                  WHERE a.MemberMci_IDNO = @Ln_CpflCur_MemberMci_IDNO
                    AND a.Case_IDNO = @Ln_CpflCur_Case_IDNO
                    AND a.FeeType_CODE = @Lc_CpflCur_FeeType_CODE) b
          WHERE b.rnk = 1;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ln_CpflAssessedTot_AMNT = 0;
           SET @Ln_CpflRecoveredTot_AMNT = 0;
           SET @Ln_CpflPendTransaction_AMNT = 0;
          END

         IF @Lc_CpflCur_Transaction_CODE = @Lc_TransactionSrec_CODE
          BEGIN
           SET @Ln_CpflPendTransaction_AMNT = @Ln_CpflCur_Transaction_AMNT * (-1);
           SET @Ln_CpflRecoveredTot_AMNT = @Ln_CpflRecoveredTot_AMNT + @Ln_CpflPendTransaction_AMNT;
           SET @Lc_CpflTransaction_CODE = @Lc_TransactionRdcr_CODE;
          END
         ELSE IF @Lc_CpflCur_Transaction_CODE = @Lc_TransactionAsmt_CODE
          BEGIN
           IF @Lc_CpflCur_FeeType_CODE = @Lc_FeeTypeDr_CODE
            BEGIN
             SET @Ls_Sql_TEXT = 'SELECT_CPFL_Y12 ';
             SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CpflCur_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_CpflCur_Case_IDNO AS VARCHAR ),'')+ ', FeeType_CODE = ' + ISNULL(@Lc_CpflCur_FeeType_CODE,'')+ ', Transaction_CODE = ' + ISNULL(@Lc_TransactionSrec_CODE,'');

             SELECT @Ln_CpflRecoveredTotDr_AMNT = SUM(Transaction_AMNT)
               FROM CPFL_Y1 a
              WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
                AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
                AND a.Batch_NUMB = @Ln_Batch_NUMB
                AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
                AND a.MemberMci_IDNO = @Ln_CpflCur_MemberMci_IDNO
                AND a.Case_IDNO = @Ln_CpflCur_Case_IDNO
                AND a.FeeType_CODE = @Lc_CpflCur_FeeType_CODE
                AND a.Transaction_CODE = @Lc_TransactionSrec_CODE;

             IF @Ln_CpflRecoveredTotDr_AMNT < @Ln_CpflCur_Transaction_AMNT
              BEGIN
               SET @Lc_CpflInsertFlag_INDC = @Lc_No_INDC;
              END
            END

           SET @Ln_CpflPendTransaction_AMNT = @Ln_CpflCur_Transaction_AMNT * (-1);
           SET @Ln_CpflAssessedTot_AMNT = @Ln_CpflAssessedTot_AMNT + @Ln_CpflPendTransaction_AMNT; -- 0;
           SET @Lc_CpflTransaction_CODE = @Lc_TransactionRdca_CODE;
          END

         IF @Lc_CpflInsertFlag_INDC = @Lc_Yes_INDC
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_CPFL_Y1 ';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CpflCur_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_CpflCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL('0','')+ ', ObligationSeq_NUMB = ' + ISNULL('0','')+ ', FeeType_CODE = ' + ISNULL(@Lc_CpflCur_FeeType_CODE,'')+ ', Transaction_CODE = ' + ISNULL(@Lc_CpflTransaction_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', AssessedYear_NUMB = ' + ISNULL(CAST( @Ln_CpflCur_AssessedYear_NUMB AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_CpflPendTransaction_AMNT AS VARCHAR ),'')+ ', AssessedTot_AMNT = ' + ISNULL(CAST( @Ln_CpflAssessedTot_AMNT AS VARCHAR ),'')+ ', RecoveredTot_AMNT = ' + ISNULL(CAST( @Ln_CpflRecoveredTot_AMNT AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGloablSeqBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBackOutLsup_NUMB AS VARCHAR ),'');

           INSERT CPFL_Y1
                  (MemberMci_IDNO,
                   Case_IDNO,
                   OrderSeq_NUMB,
                   ObligationSeq_NUMB,
                   FeeType_CODE,
                   Transaction_CODE,
                   Transaction_DATE,
                   AssessedYear_NUMB,
                   Transaction_AMNT,
                   AssessedTot_AMNT,
                   RecoveredTot_AMNT,
                   TypeDisburse_CODE,
                   Batch_DATE,
                   SourceBatch_CODE,
                   Batch_NUMB,
                   SeqReceipt_NUMB,
                   EventGlobalSeq_NUMB,
                   EventGlobalSupportSeq_NUMB)
           VALUES ( @Ln_CpflCur_MemberMci_IDNO,--MemberMci_IDNO					
           @Ln_CpflCur_Case_IDNO,--Case_IDNO						
           0,--OrderSeq_NUMB					
           0,--ObligationSeq_NUMB				
           @Lc_CpflCur_FeeType_CODE,--FeeType_CODE						
           @Lc_CpflTransaction_CODE,--Transaction_CODE					
           @Ld_Process_DATE,--Transaction_DATE
           @Ln_CpflCur_AssessedYear_NUMB,--AssessedYear_NUMB				
           @Ln_CpflPendTransaction_AMNT,--Transaction_AMNT					
           @Ln_CpflAssessedTot_AMNT,--AssessedTot_AMNT				
           @Ln_CpflRecoveredTot_AMNT,--RecoveredTot_AMNT						
           @Lc_Space_TEXT,--TypeDisburse_CODE					
           @Ld_BatchOrig_DATE,--Batch_DATE 
           @Lc_SourceBatch_CODE,--SourceBatch_CODE 
           @Ln_Batch_NUMB,--Batch_NUMB 
           @Ln_SeqReceipt_NUMB,--SeqReceipt_NUMB 
           @Ln_EventGloablSeqBackOut_NUMB,--EventGlobalSeq_NUMB 
           @Ln_EventGlobalSeqBackOutLsup_NUMB ); --EventGlobalSupportSeq_NUMB 
          END

         FETCH NEXT FROM Cpfl_Cur INTO @Ln_CpflCur_MemberMci_IDNO, @Ln_CpflCur_Case_IDNO, @Lc_CpflCur_FeeType_CODE, @Lc_CpflCur_Transaction_CODE, @Ln_CpflCur_Transaction_AMNT, @Ln_CpflCur_AssessedYear_NUMB;

         SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       IF CURSOR_STATUS('Local', 'Cpfl_Cur') IN (0, 1)
        BEGIN
         CLOSE Cpfl_Cur;

         DEALLOCATE Cpfl_Cur;
        END
      END

     CP_NSF_FEE:

     IF @Lc_SourceBatch_CODE <> @Lc_ChildSrcDirectPayCredit_CODE
      BEGIN
       --CP NSF Fee (NS) Assesssment --Start --
       IF @Lc_PRrepCur_SourceReceipt_CODE IN (@Lc_SourceReceiptCpFeePaymentCf_CODE, @Lc_SourceReceiptCpRecoupmentCr_CODE)
          AND @Ac_ReasonBackOut_CODE IN (@Lc_ReasonBackOutAccountClosedAc_CODE, @Lc_ReasonBackOutNsfNf_CODE, @Lc_ReasonBackOutReferToMakerRm_CODE, @Lc_ReasonBackOutStopPaymentSp_CODE, @Lc_ReasonBackOutUnlocatedAcctUa_CODE)
        BEGIN
         SET @Ln_CpflCpNf_Case_IDNO = 0;
         SET @Ls_Sql_TEXT = 'SELECT_CPFL_Y11 ';
         SET @Ls_Sqldata_TEXT = 'rnk = ' + ISNULL('1','');
         
         SELECT @Ln_CpflCpNf_Case_IDNO = Case_IDNO
           FROM (SELECT b.Case_IDNO,
                        c.Opened_DATE,
                        ROW_NUMBER() OVER (ORDER BY c.Opened_DATE ) AS rnk
                   FROM CMEM_Y1 b
                        JOIN CASE_Y1 c
                         ON b.Case_IDNO = c.Case_IDNO
                        JOIN SORD_Y1 d
                         ON c.Case_IDNO = d.Case_IDNO
                  WHERE b.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                    AND b.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                    AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                    AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                    AND @Ld_Process_DATE BETWEEN d.OrderEffective_DATE AND d.OrderEnd_DATE
                    AND d.EndValidity_DATE = @Ld_High_DATE) a
          WHERE rnk = 1;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF (@Ln_RowCount_QNTY = 0)
          BEGIN
           SET @Ln_CpflCpNf_Case_IDNO = 0;
          END
			
         SET @Ls_Sql_TEXT = 'SELECT_CPFL_Y11 ';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CpflCur_MemberMci_IDNO AS NVARCHAR), '') + ', FeeType_CODE = ' + ISNULL(@Lc_CpflCur_FeeType_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CpflCur_Case_IDNO AS NVARCHAR), '');			
         
         SELECT @Ln_CpflAssessedTot_AMNT = b.AssessedTot_AMNT,
                @Ln_CpflRecoveredTot_AMNT = b.RecoveredTot_AMNT,
                @Ln_CpflPendTransaction_AMNT = b.Transaction_AMNT
           FROM (SELECT a.RecoveredTot_AMNT,
                        a.AssessedTot_AMNT,
                        a.Transaction_AMNT,
                        ROW_NUMBER() OVER (PARTITION BY a.MemberMci_IDNO, 
                        a.FeeType_CODE ORDER BY a.Unique_IDNO DESC) AS rnk
                   FROM CPFL_Y1 a
                  WHERE a.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                        AND a.FeeType_CODE = @Lc_FeeTypeNs_CODE) b
          WHERE b.rnk = 1;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ln_CpflPendTransaction_AMNT = 25;
           SET @Ln_CpflAssessedTot_AMNT = 25;
           SET @Ln_CpflRecoveredTot_AMNT = 0;
          END
         ELSE
          BEGIN
           SET @Ln_CpflPendTransaction_AMNT = 25;
           SET @Ln_CpflAssessedTot_AMNT = @Ln_CpflAssessedTot_AMNT + @Ln_CpflPendTransaction_AMNT;
          END

         SET @Ls_Sql_TEXT = 'INSERT_CPFL_Y1 ';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_CpflCpNf_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL('0','')+ ', ObligationSeq_NUMB = ' + ISNULL('0','')+ ', FeeType_CODE = ' + ISNULL(@Lc_FeeTypeNs_CODE,'')+ ', Transaction_CODE = ' + ISNULL(@Lc_TransactionAsmt_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_CpflPendTransaction_AMNT AS VARCHAR ),'')+ ', AssessedTot_AMNT = ' + ISNULL(CAST( @Ln_CpflAssessedTot_AMNT AS VARCHAR ),'')+ ', RecoveredTot_AMNT = ' + ISNULL(CAST( @Ln_CpflRecoveredTot_AMNT AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'');

         INSERT CPFL_Y1
                (MemberMci_IDNO,
                 Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 FeeType_CODE,
                 Transaction_CODE,
                 Transaction_DATE,
                 AssessedYear_NUMB,
                 Transaction_AMNT,
                 AssessedTot_AMNT,
                 RecoveredTot_AMNT,
                 TypeDisburse_CODE,
                 Batch_DATE,
                 SourceBatch_CODE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 EventGlobalSeq_NUMB,
                 EventGlobalSupportSeq_NUMB)
         VALUES ( @Ln_PayorMCI_IDNO,--MemberMci_IDNO					
         @Ln_CpflCpNf_Case_IDNO,--Case_IDNO						
         0,--OrderSeq_NUMB					
         0,--ObligationSeq_NUMB				
         @Lc_FeeTypeNs_CODE,--FeeType_CODE						
         @Lc_TransactionAsmt_CODE,--Transaction_CODE					
         @Ld_Process_DATE,--Transaction_DATE
         YEAR (@Ld_Process_DATE),--AssessedYear_NUMB				
         @Ln_CpflPendTransaction_AMNT,--Transaction_AMNT					
         @Ln_CpflAssessedTot_AMNT,--AssessedTot_AMNT				
         @Ln_CpflRecoveredTot_AMNT,--RecoveredTot_AMNT						
         @Lc_Space_TEXT,--TypeDisburse_CODE					
         @Ld_BatchOrig_DATE,--Batch_DATE 
         @Lc_SourceBatch_CODE,--SourceBatch_CODE 
         @Ln_Batch_NUMB,--Batch_NUMB 
         @Ln_SeqReceipt_NUMB,--SeqReceipt_NUMB 
         @Ln_EventGlobalSeqRcthBackOut_NUMB,--EventGlobalSeq_NUMB 
         @Ln_EventGlobalSeqRcthBackOut_NUMB ); --EventGlobalSupportSeq_NUMB 
         
         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
           RAISERROR(50001,16,1);
          END
        END
      END

     PROCESS_REPOST:

     SET @Lc_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_RePostAReceipt1310_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
     
     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_RePostAReceipt1310_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqRep_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       RAISERROR(50001,16,1);
      END
		
	  --Bug 13447 : CR0384 - Reposting and recovering the partially refunded receipt with refund amount as receipt amou -START 
		
		  SET @Ls_Sql_TEXT = 'SELECT DSBL_Y1 -1';
		  SET @Ls_Sqldata_TEXT = 'BatchOrig_DATE = '+  CAST(@Ld_BatchOrig_DATE AS VARCHAR) + ' , SourceBatch_CODE = '+  @Lc_SourceBatch_CODE  +  ' , SeqReceipt_NUMB = '+ CAST(@Ln_SeqReceipt_NUMB AS VARCHAR) + ' , High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +' , DisburseStatusOutstanding_CODE = '+ @Lc_DisburseStatusOutstanding_CODE +' , DisburseStatusCashed_CODE = '+ @Lc_DisburseStatusCashed_CODE + ' , DisburseStatusOutstanding_CODE = '+ @Lc_DisburseStatusOutstanding_CODE  + ' , DisburseStatusCashed_CODE = '+ @Lc_DisburseStatusCashed_CODE
		-- Select disbursed REFUND amount
		SELECT @Ln_PRrepCur_Refund_AMNT = ISNULL(SUM(l.Disburse_AMNT),0)
		FROM DSBL_Y1 l, DSBH_Y1 h
		WHERE l.Batch_DATE = @Ld_BatchOrig_DATE 
            AND l.SourceBatch_CODE  = @Lc_SourceBatch_CODE
            AND l.Batch_NUMB = @Ln_Batch_NUMB
            AND l.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
            AND l.CheckRecipient_ID = h.CheckRecipient_ID 
            AND l.CheckRecipient_CODE = h.CheckRecipient_CODE 
            AND l.Disburse_DATE = h.Disburse_DATE
            AND l.DisburseSeq_NUMB = h.DisburseSeq_NUMB
			AND l.TypeDisburse_CODE IN( @Lc_TypeDisburseRefund_CODE )		   
			AND h.EndValidity_DATE=@Ld_High_DATE
			AND StatusCheck_CODE IN ( @Lc_DisburseStatusOutstanding_CODE ,@Lc_DisburseStatusCashed_CODE)AND StatusCheck_CODE IN ( @Lc_DisburseStatusOutstanding_CODE ,@Lc_DisburseStatusCashed_CODE)

			SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		  SET @Ln_PRrepCur_Refund_AMNT =0
		  END

     IF (@Lc_PRrepCur_RePost_INDC = @Lc_Yes_INDC 
	
	 And ( @Ln_PRrepCur_Refund_AMNT=0
	 OR @Ln_PRrepCur_Receipt_AMNT-  @Ln_PRrepCur_Refund_AMNT=0
	 )
 
    AND @Ac_ReasonBackOut_CODE NOT IN (@Lc_ReasonBackOutAccountClosedAc_CODE, @Lc_ReasonBackOutNsfNf_CODE, @Lc_ReasonBackOutReferToMakerRm_CODE, @Lc_ReasonBackOutStopPaymentSp_CODE, @Lc_ReasonBackOutUnlocatedAcctUa_CODE))
      BEGIN
       SET @Ac_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REPOST_PROCESS_RREP';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_PRrepCur_Receipt_AMNT AS VARCHAR ),'')+ ', Sval_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Refund_INDC = ' + ISNULL(@Lc_Refund_INDC,'')+ ', Refund_AMNT = ' + ISNULL(CAST( @Ln_Refund_AMNT AS VARCHAR ),'')+ ', CasePayorMCIReposted_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_CasePayorMCIReposted_IDNO AS VARCHAR ),'')+ ', RepostedPayorMci_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_RepostedPayorMci_IDNO AS VARCHAR ),'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EventGlobalBackOutSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRep_NUMB AS VARCHAR ),'');

       EXECUTE BATCH_COMMON$SP_REPOST_PROCESS_RREP
        @Ad_Batch_DATE                 = @Ld_BatchOrig_DATE,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @An_Receipt_AMNT               = @Ln_PRrepCur_Receipt_AMNT,
        @Ac_Sval_INDC                  = @Lc_No_INDC,
        @Ac_Refund_INDC                = @Lc_No_INDC,
        @An_Refund_AMNT                = 0,
        @An_CasePayorMCIReposted_IDNO  = @Ln_PRrepCur_CasePayorMCIReposted_IDNO,
        @An_RepostedPayorMci_IDNO      = @Ln_PRrepCur_RepostedPayorMci_IDNO,
        @Ac_ReasonBackOut_CODE         = @Ac_ReasonBackOut_CODE,
        @Ac_Process_ID                 = @Ac_Process_ID,
        @Ac_SignedOnWorker_ID          = @Ac_SignedOnWorker_ID,
        @Ad_Process_DATE               = @Ld_Process_DATE,
        @An_EventGlobalBackOutSeq_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB,
        @An_EventGlobalBeginSeq_NUMB   = @Ln_EventGlobalSeqRep_NUMB,
        @An_EventGlobalRefundSeq_NUMB  = @Ln_EventGlobalRefundSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                   = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         RAISERROR(50001,16,1);
        END
      END

	IF @Ln_PRrepCur_Refund_AMNT>0 AND   @Ln_PRrepCur_Receipt_AMNT-  @Ln_PRrepCur_Refund_AMNT>0 AND @Ac_SignedOnWorker_ID<> @Lc_BatchRunUser_TEXT
      BEGIN
       SET @Ac_Process_ID = ISNULL(@Ac_Process_ID, @Lc_Space_TEXT);
	  -- Reposting the partially refunded receipt with refund amount as receipt amount
	   
	    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ -3'
	 SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_RePostAReceipt1310_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
	 -- New EventGlobalSeq_NUMB is generated to repost the refunded receipt
	  EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqRep_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

	   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REPOST_PROCESS_RREP - 2';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_PRrepCur_Refund_AMNT AS VARCHAR ),'')+ ', Sval_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', CasePayorMCIReposted_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_CasePayorMCIReposted_IDNO AS VARCHAR ),'')+ ', RepostedPayorMci_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_RepostedPayorMci_IDNO AS VARCHAR ),'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EventGlobalBackOutSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'');
	   --Creating new receipt by reposting the orginal receipt with refund amount as receipt amount for recovering the refunded amount
       EXECUTE BATCH_COMMON$SP_REPOST_PROCESS_RREP
        @Ad_Batch_DATE                 = @Ld_BatchOrig_DATE,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @An_Receipt_AMNT               = @Ln_PRrepCur_Refund_AMNT,
        @Ac_Sval_INDC                  = @Lc_No_INDC,
        @Ac_Refund_INDC                = @Lc_No_INDC,
        @An_Refund_AMNT                = 0,
        @An_CasePayorMCIReposted_IDNO  = @Ln_PRrepCur_CasePayorMCIReposted_IDNO,
        @An_RepostedPayorMci_IDNO      = @Ln_PRrepCur_RepostedPayorMci_IDNO,
        @Ac_ReasonBackOut_CODE         = @Ac_ReasonBackOut_CODE,
        @Ac_Process_ID                 = @Ac_Process_ID,
        @Ac_SignedOnWorker_ID          = @Ac_SignedOnWorker_ID,
        @Ad_Process_DATE               = @Ld_Process_DATE,
        @An_EventGlobalBackOutSeq_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB,
        @An_EventGlobalBeginSeq_NUMB   = @Ln_EventGlobalSeqRep_NUMB,
        --To avoid BATCH_COMMON$SP_RECEIPT_ON_HOLD procedure call when @Ac_NcpRefundRecoverReceipt_INDC value is 'Y' i.e No need to check hold instructions when posting new receipt to recover NCP Refund amount
        @Ac_NcpRefundRecoverReceipt_INDC = @Lc_Yes_INDC,
        @An_EventGlobalRefundSeq_NUMB  = @Ln_EventGlobalRefundSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                   = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         RAISERROR(50001,16,1);
        END
	
	
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ -3'
	 SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_RePostAReceipt1310_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
	 -- New EventGlobalSeq_NUMB is generated to repost the refunded receipt with the amount distributed to cp (Receipt_AMNT-Refund_AMNT)
	  EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeqCp_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

	   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         RAISERROR(50001,16,1);
        END
		
     SET @Ln_ReceiptNew_AMNT=  @Ln_PRrepCur_Receipt_AMNT-  @Ln_PRrepCur_Refund_AMNT
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REPOST_PROCESS_RREP - 3';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @Ln_PRrepCur_Refund_AMNT AS VARCHAR ),'')+ ', Sval_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', CasePayorMCIReposted_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_CasePayorMCIReposted_IDNO AS VARCHAR ),'')+ ', RepostedPayorMci_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_RepostedPayorMci_IDNO AS VARCHAR ),'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Ac_ReasonBackOut_CODE,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EventGlobalBackOutSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'');
	   --Reposting receipt with amount distributed to CP (Receipt_AMNT-Refund_AMNT)
       EXECUTE BATCH_COMMON$SP_REPOST_PROCESS_RREP
        @Ad_Batch_DATE                 = @Ld_BatchOrig_DATE,
        @Ac_SourceBatch_CODE           = @Lc_SourceBatch_CODE,
        @An_Batch_NUMB                 = @Ln_Batch_NUMB,
        @An_SeqReceipt_NUMB            = @Ln_SeqReceipt_NUMB,
        @An_Receipt_AMNT               = @Ln_ReceiptNew_AMNT,
        @Ac_Sval_INDC                  = @Lc_No_INDC,
        @Ac_Refund_INDC                = @Lc_No_INDC,
        @An_Refund_AMNT                = 0,
        @An_CasePayorMCIReposted_IDNO  = @Ln_PRrepCur_CasePayorMCIReposted_IDNO,
        @An_RepostedPayorMci_IDNO      = @Ln_PRrepCur_RepostedPayorMci_IDNO,
        @Ac_ReasonBackOut_CODE         = @Ac_ReasonBackOut_CODE,
        @Ac_Process_ID                 = @Ac_Process_ID,
        @Ac_SignedOnWorker_ID          = @Ac_SignedOnWorker_ID,
        @Ad_Process_DATE               = @Ld_Process_DATE,
        @An_EventGlobalBackOutSeq_NUMB = @Ln_EventGlobalSeqRcthBackOut_NUMB,
        @An_EventGlobalBeginSeq_NUMB   = @Ln_EventGlobalSeqCp_NUMB,
        @An_EventGlobalRefundSeq_NUMB  = @Ln_EventGlobalRefundSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                   = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT      = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         RAISERROR(50001,16,1);
        END
		
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ -3'
	 SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_RePostAReceipt1310_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');
	 -- New EventGlobalSeq_NUMB is generated to logically update the status to R-Refund for the new receipt created for recovering the refund amount 
	  EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_RefundAReceipt1220_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalRefundSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;
		
	 IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         RAISERROR(50001,16,1);
        END	
		-- Approving the new receipt created for recovering the refunded amount
		SET @Ls_Sql_TEXT = 'UPDATE RCTR -1'
		SET @Ls_Sqldata_TEXT = 'Process_DATE = '+ CAST(@Ld_Process_DATE AS VARCHAR)+', Batch_NUMB = '+ CAST(@Ln_Batch_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SourceBatch_CODE + ', SeqReceipt_NUMB = '+ CAST(@Ln_SeqReceipt_NUMB AS VARCHAR) + ', Refund_AMNT = ' +  CAST(@Ln_PRrepCur_Refund_AMNT AS VARCHAR) +  ', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', EventGlobalSeqRcthBackOut_NUMB = '+  CAST(@Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR);
		
		UPDATE r
			SET r.StatusMatch_CODE=@Lc_StatusMatchApproved_CODE
		FROM RCTR_Y1 r, RCTH_Y1 a
		WHERE 
			 r.BatchOrig_DATE=@Ld_BatchOrig_DATE 
		 AND r.BatchOrig_NUMB = @Ln_Batch_NUMB 
		 AND r.SourceBatchOrig_CODE=  @Lc_SourceBatch_CODE 
		 AND r.SeqReceiptOrig_NUMB = @Ln_SeqReceipt_NUMB
		 AND r.ReceiptCurrent_AMNT=@Ln_PRrepCur_Refund_AMNT 
		 AND r.EndValidity_DATE=@Ld_High_DATE
		 AND r.EventGlobalBeginSeq_NUMB=@Ln_EventGlobalSeqRep_NUMB
		 and r.Batch_DATE=a.Batch_DATE
		 AND r.Batch_NUMB=a.Batch_NUMB
		 AND r.SourceBatch_CODE=a.SourceBatch_CODE
		 AND r.SeqReceipt_NUMB=a.SeqReceipt_NUMB
		 AND a.EndValidity_DATE=@Ld_High_DATE

		
       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		  SET @As_DescriptionError_TEXT ='UPDATE RCTR_Y1 failed while changing StatusMatch_CODE  to A-Approved'
		   RAISERROR(50001,16,1);
		  END
	
		SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 -2'
		SET @Ls_Sqldata_TEXT = 'Process_DATE = '+ CAST(@Ld_Process_DATE AS VARCHAR)+', Batch_NUMB = '+ CAST(@Ln_Batch_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SourceBatch_CODE + ', SeqReceipt_NUMB = '+ CAST(@Ln_SeqReceipt_NUMB AS VARCHAR) + ', Refund_AMNT = ' +  CAST(@Ln_PRrepCur_Refund_AMNT AS VARCHAR) +  ', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', EventGlobalSeqRcthBackOut_NUMB = '+  CAST(@Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR);
		-- logically delete new receipt created for revovering the refunded amount
		UPDATE a
			SET  EventGlobalEndSeq_NUMB =@Ln_EventGlobalRefundSeq_NUMB,
				a.EndValidity_DATE=@Ld_Process_DATE
		FROM RCTR_Y1 r, RCTH_Y1 a
		WHERE 
			 r.BatchOrig_DATE=@Ld_BatchOrig_DATE 
		 AND r.BatchOrig_NUMB = @Ln_Batch_NUMB 
		 AND r.SourceBatchOrig_CODE=  @Lc_SourceBatch_CODE 
		 AND r.SeqReceiptOrig_NUMB = @Ln_SeqReceipt_NUMB
		 AND r.ReceiptCurrent_AMNT=@Ln_PRrepCur_Refund_AMNT 
		 AND r.EndValidity_DATE=@Ld_High_DATE
		 AND r.EventGlobalBeginSeq_NUMB=@Ln_EventGlobalSeqRep_NUMB
		 and r.Batch_DATE=a.Batch_DATE
		 AND r.Batch_NUMB=a.Batch_NUMB
		 AND r.SourceBatch_CODE=a.SourceBatch_CODE
		 AND r.SeqReceipt_NUMB=a.SeqReceipt_NUMB
		 AND a.EndValidity_DATE=@Ld_High_DATE
		  
		 SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		  SET @As_DescriptionError_TEXT ='UPDATE RCTH_Y1 failed while changing Distribute_DATE to Process_DATE'
		   RAISERROR(50001,16,1);
		  END
		
		SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 -1'
		SET @Ls_Sqldata_TEXT = 'Process_DATE = '+ CAST(@Ld_Process_DATE AS VARCHAR) +', StatusReceiptRefund_CODE = '+ @Lc_StatusReceiptRefund_CODE + ', RecipientTypeCpNcp_CODE = '+ @Lc_RecipientTypeCpNcp_CODE  + ', High_DATE = '+  CAST(@Ld_High_DATE AS VARCHAR)
		--Insert new  receipt for logically updating the status to R-Refund
		
		INSERT RCTH_Y1
		(
		Batch_DATE,
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
		)
		SELECT
		r.Batch_DATE,
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
		@Ld_Process_DATE AS Distribute_DATE,
		r.Tanf_CODE,
		r.TaxJoint_CODE,
		r.TaxJoint_NAME,	
		@Lc_StatusReceiptRefund_CODE AS StatusReceipt_CODE,
		(
		SELECT TOP 1 ReasonStatus_CODE
		FROM
		(
		SELECT  ReasonStatus_CODE ,MAX(a.EventGlobalBeginSeq_NUMB) EventGlobalBeginSeq_NUMB
		FROM RCTR_Y1 c, RCTH_Y1 a
		WHERE 
			 c.Batch_DATE=r.Batch_DATE 
		 AND c.Batch_NUMB = r.Batch_NUMB 
		 AND c.SourceBatch_CODE=  r.SourceBatch_CODE 
		 AND c.SeqReceipt_NUMB = r.SeqReceipt_NUMB
		 AND c.EndValidity_DATE=@Ld_High_DATE
		 AND c.EventGlobalBeginSeq_NUMB=@Ln_EventGlobalSeqRep_NUMB
		 and c.BatchOrig_DATE=a.Batch_DATE
		 AND c.BatchOrig_NUMB=a.Batch_NUMB
		 AND c.SourceBatchOrig_CODE=a.SourceBatch_CODE
		 AND c.SeqReceiptOrig_NUMB=a.SeqReceipt_NUMB
		 AND a.EndValidity_DATE=@Ld_High_DATE
		 AND a.StatusReceipt_CODE= @Lc_StatusReceiptRefund_CODE
		 GROUP BY ReasonStatus_CODE 
		 HAVING SUM(DISTINCT ReceiptCurrent_AMNT) =@Ln_PRrepCur_Refund_AMNT
		 ) g
		 ORDER BY EventGlobalBeginSeq_NUMB DESC
		) AS ReasonStatus_CODE,
		r.BackOut_INDC,
		r.ReasonBackOut_CODE,
		@Ld_Process_DATE AS Refund_DATE,
		r.Release_DATE,
		r.ReferenceIrs_IDNO,
		r.PayorMCI_IDNO AS RefundRecipient_ID,
		@Lc_RecipientTypeCpNcp_CODE AS RefundRecipient_CODE,
		@Ld_Process_DATE AS BeginValidity_DATE,
		@Ld_High_DATE AS EndValidity_DATE,
		r.EventGlobalEndSeq_NUMB AS EventGlobalBeginSeq_NUMB,
		0 AS EventGlobalEndSeq_NUMB
		FROM RCTH_Y1 r
		WHERE 
		r.EventGlobalEndSeq_NUMB =@Ln_EventGlobalRefundSeq_NUMB 
		AND r.EndValidity_DATE=@Ld_Process_DATE
		
		  SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		  SET @As_DescriptionError_TEXT ='INSERT RCTH_Y1 failed while record with refund status'
		   RAISERROR(50001,16,1);
		  END
		
		SET @Ls_Sql_TEXT = 'INSERT UNOT_Y1 -2';
		SET @Ls_Sqldata_TEXT ='EventGlobalSeqRep_NUMB = '+ CAST( @Ln_EventGlobalSeqRep_NUMB AS VARCHAR) +' , EventGlobalSeqRcthBackOut_NUMB = ' + CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR) +' , RefundUnotDescription_TEXT = '+@Ls_RefundUnotDescription_TEXT;
		INSERT UNOT_Y1
          (EventGlobalSeq_NUMB,
           DescriptionNote_TEXT,
           EventGlobalApprovalSeq_NUMB)
		VALUES ( @Ln_EventGlobalSeqRep_NUMB,--EventGlobalSeq_NUMB
            @Ls_RefundUnotDescription_TEXT,    --DescriptionNote_TEXT
            @Ln_EventGlobalRefundSeq_NUMB --EventGlobalApprovalSeq_NUMB
   );

		SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		  SET @As_DescriptionError_TEXT ='Insert UNOT_Y1 failed while inserting description for refund'
		   RAISERROR(50001,16,1);
		  END

		SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 -1'
		SET @Ls_Sqldata_TEXT ='EventGlobalSeqRep_NUMB = '+ CAST( @Ln_EventGlobalSeqRep_NUMB AS VARCHAR) +' , CaseRelationshipNcp_CODE = '+ @Lc_CaseRelationshipNcp_CODE +' , CaseRelationshipPf_CODE = '+ @Lc_CaseRelationshipPf_CODE + ' , CaseMemberStatusActive_CODE = ' +@Lc_CaseMemberStatusActive_CODE;
		-- Retrive data for Refund entry in ENTITY_MATRIX
		SELECT 
			@Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO( r.Batch_DATE, r.SourceBatch_CODE, r.Batch_NUMB, r.SeqReceipt_NUMB),
			@Ld_Receipt_DATE = r.Receipt_DATE,
			@Ln_Case_IDNO = (
				SELECT TOP 1 Case_IDNO FROM
				(
				SELECT c.Case_IDNO ,StatusCase_CODE,a.Opened_DATE,
				CASE WHEN EXISTS(
				SELECT 1 FROM LSUP_Y1 l
				WHERE l.Batch_DATE=r.Batch_DATE
				AND l.Batch_NUMB=r.Batch_NUMB
				AND l.SourceBatch_CODE=r.SourceBatch_CODE
				AND l.SeqReceipt_NUMB=r.SeqReceipt_NUMB
				AND l.Case_IDNO=c.Case_IDNO
				) THEN 1 ELSE 0 END Distribute_INDC
				FROM CMEM_Y1 c, CASE_Y1 a
				WHERE c.MemberMCI_IDNO=r.PayorMCI_IDNO
				AND  c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
                  AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
				  AND c.Case_IDNO=a.Case_IDNO
				  ) AS a
					--If NCP has a open case and a closed case then most reasent open case should be selected
					ORDER BY a.Distribute_INDC DESC ,  a.StatusCase_CODE DESC,a.Opened_DATE DESC
			),
			@Lc_CheckNo_TEXT = r.CheckNo_TEXT,
			@Ln_PayorMCI_IDNO = r.PayorMCI_IDNO, 
			@Lc_ReasonStatus_CODE =r.ReasonStatus_CODE
			FROM RCTH_Y1 r
			WHERE r.EventGlobalBeginSeq_NUMB =@Ln_EventGlobalRefundSeq_NUMB

			 SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		  SET @As_DescriptionError_TEXT ='SELECT RCTH_Y1 failed while retriving data for ENTITY_MATRIX'
		   RAISERROR(50001,16,1);
		  END

		  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX - 1'
		  SET @Ls_Sqldata_TEXT = 'EventGlobalSeqRep_NUMB = '+ CAST(@Ln_EventGlobalSeqRep_NUMB AS VARCHAR) + ' , RefundAReceipt1220_NUMB = '+ CAST( @Li_RefundAReceipt1220_NUMB AS VARCHAR) +' , Receipt_TEXT = '+ @Lc_Receipt_TEXT +' , Receipt_DATE = '+ CAST(@Ld_Receipt_DATE AS VARCHAR) +' , Case_IDNO = '+  CAST(@Ln_Case_IDNO AS VARCHAR) + ' , PayorMCI_IDNO = '+ CAST(@Ln_PayorMCI_IDNO AS VARCHAR)+ ' , CheckNo_TEXT = '+  @Lc_CheckNo_TEXT;
		
		 -- Refund entry in ELOG for receipt created for recovering refund amount
		 EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
        @An_EventGlobalSeq_NUMB			= @Ln_EventGlobalRefundSeq_NUMB,
        @An_EventFunctionalSeq_NUMB		= @Li_RefundAReceipt1220_NUMB,
		@Ac_EntityCheckRecipient_ID		= @Ln_PayorMCI_IDNO,
		@Ac_EntityCheckRecipient_CODE	= @Lc_RecipientTypeCpNcp_CODE,	 
        @Ac_EntityReceipt_ID			= @Lc_Receipt_TEXT,
        @Ad_EntityReceipt_DATE			= @Ld_Receipt_DATE,
        @An_EntityCase_IDNO				= @Ln_Case_IDNO,
        @An_EntityPayor_IDNO			= @Ln_PayorMCI_IDNO,
        @Ac_EntityCheckNo_TEXT			= @Lc_CheckNo_TEXT,
		@Ac_EntityRefundReasonStatus_CODE = @Lc_ReasonStatus_CODE,
        @Ac_Msg_CODE					= @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT		= @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX RefundAReceipt1220 FAILED';

         RAISERROR(50001,16,1);
		END
		SET @Ls_Sql_TEXT = 'UPDATE RBAT_Y1 -1'
		SET @Ls_Sqldata_TEXT = 'Process_DATE = '+ CAST(@Ld_Process_DATE AS VARCHAR)+', Batch_NUMB = '+ CAST(@Ln_Batch_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_SourceBatch_CODE + ', SeqReceipt_NUMB = '+ CAST(@Ln_SeqReceipt_NUMB AS VARCHAR) + ', Refund_AMNT = ' +  CAST(@Ln_PRrepCur_Refund_AMNT AS VARCHAR) +  ', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', EventGlobalSeqRcthBackOut_NUMB = '+  CAST(@Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR);
		-- changing StatusBatch_CODE of RBAT record for the new receipt to R-Reconciled
		UPDATE a
			SET a.StatusBatch_CODE=@Lc_StatusBatchReconciled_CODE
		FROM RCTR_Y1 r,  RBAT_Y1 a
		WHERE 
			 r.BatchOrig_DATE=@Ld_BatchOrig_DATE 
		 AND r.BatchOrig_NUMB = @Ln_Batch_NUMB 
		 AND r.SourceBatchOrig_CODE=  @Lc_SourceBatch_CODE 
		 AND r.SeqReceiptOrig_NUMB = @Ln_SeqReceipt_NUMB
		 AND r.ReceiptCurrent_AMNT=@Ln_PRrepCur_Refund_AMNT 
		 AND r.EndValidity_DATE=@Ld_High_DATE
		 AND r.EventGlobalBeginSeq_NUMB=@Ln_EventGlobalSeqRep_NUMB
		 and r.Batch_DATE=a.Batch_DATE
		 AND r.Batch_NUMB=a.Batch_NUMB
		 AND r.SourceBatch_CODE=a.SourceBatch_CODE
		 AND a.EndValidity_DATE=@Ld_High_DATE
		 
       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		  SET @As_DescriptionError_TEXT ='UPDATE RBAT_Y1 failed while changing StatusBatch_CODE  to R-Reconciled'
		   RAISERROR(50001,16,1);
		  END
				   
		 SET @Ls_Sql_TEXT = 'INSERT POFL_Y1 -2'  
		 SET @Ls_Sqldata_TEXT = 'TransactionSrec_CODE = '+  @Lc_TransactionSrec_CODE +', EventGlobalSeqRcthBackOut_NUMB = '+ CAST(@Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR);
		   -- recovering the refunded amount by using the new receipt
		   INSERT POFL_Y1
                (CheckRecipient_ID,
                 CheckRecipient_CODE,
                 Case_IDNO,
                 TypeRecoupment_CODE,
                 RecoupmentPayee_CODE,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 Transaction_DATE,
                 TypeDisburse_CODE,
                 PendOffset_AMNT,
                 PendTotOffset_AMNT,
                 AssessOverpay_AMNT,
                 AssessTotOverpay_AMNT,
                 Reason_CODE,
                 RecAdvance_AMNT,
                 RecTotAdvance_AMNT,
                 RecOverpay_AMNT,
                 RecTotOverpay_AMNT,
                 Batch_DATE,
                 Batch_NUMB,
                 SeqReceipt_NUMB,
                 SourceBatch_CODE,
                 Transaction_CODE,
                 EventGlobalSeq_NUMB,
                 EventGlobalSupportSeq_NUMB
         )
         
		 SELECT p.CheckRecipient_ID ,
		 p.CheckRecipient_CODE,
		 p.Case_IDNO,
		 p.TypeRecoupment_CODE,
		 p.RecoupmentPayee_CODE,
		 p.OrderSeq_NUMB,
		 p.ObligationSeq_NUMB,
		 p.Transaction_DATE,
		 p.TypeDisburse_CODE,
		 0 PendOffset_AMNT,
		 p.PendTotOffset_AMNT,
		 0 AssessOverpay_AMNT,
		 p.AssessTotOverpay_AMNT,
		 p.Reason_CODE,
		 p.RecAdvance_AMNT,
		 p.RecTotAdvance_AMNT,
		 p.AssessOverpay_AMNT RecOverpay_AMNT,
		 p.RecTotOverpay_AMNT+p.AssessOverpay_AMNT  RecTotOverpay_AMNT,
		 r.Batch_DATE,
		 r.Batch_NUMB,
		 r.SeqReceipt_NUMB,
		 r.SourceBatch_CODE,
		 @Lc_TransactionSrec_CODE Transaction_CODE,
		 @Ln_EventGlobalRefundSeq_NUMB EventGlobalSeq_NUMB,
		 @Ln_EventGlobalSeqRep_NUMB EventGlobalSupportSeq_NUMB
		 FROM RCTH_Y1 r, POFL_Y1 p
		 WHERE 
		  r.EndValidity_DATE=@Ld_High_DATE
		 AND r.EventGlobalBeginSeq_NUMB=@Ln_EventGlobalRefundSeq_NUMB
		 AND p.EventGlobalSeq_NUMB=@Ln_EventGlobalSeqRcthBackOut_NUMB
		 AND p.Transaction_CODE=@Lc_TransactionBkrc_CODE
		 AND P.Batch_DATE=@Ld_BatchOrig_DATE 
		 AND p.Batch_NUMB = @Ln_Batch_NUMB 
		 AND p.SourceBatch_CODE=  @Lc_SourceBatch_CODE 
		 AND p.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
		 AND p.CheckRecipient_ID= CAST(@Ln_PRrepCur_RepostedPayorMci_IDNO AS VARCHAR)
		
	 SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	  SET @As_DescriptionError_TEXT ='INSERT POFL_Y1 failed for recovering the refund amount'
       RAISERROR(50001,16,1);
      END
				
      END
	 --Bug 13447 : CR0384 - Reposting and recovering the partially refunded receipt with refund amount as receipt amou -END
     PROCESS_ELOG:

     SET @Ls_Sql_TEXT = 'INSERT_ELOG_RREP ';
     SET @Ls_Sqldata_TEXT = 'EventGlobalRrepSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBrep_NUMB AS VARCHAR ),'')+ ', EventGlobalBackOutSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqRcthBackOut_NUMB AS VARCHAR ),'')+ ', BatchOrig_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', SourceBatchOrig_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', BatchOrig_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceiptOrig_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', RePost_INDC = ' + ISNULL(@Lc_PRrepCur_RePost_INDC,'')+ ', Refund_INDC = ' + ISNULL(@Lc_Refund_INDC,'')+ ', MultiCase_INDC = ' + ISNULL(@Lc_PRrepCur_MultiCase_INDC,'')+ ', ClosedCase_INDC = ' + ISNULL(@Lc_PRrepCur_ClosedCase_INDC,'')+ ', EventGlobalRefundSeq_NUMB = ' + ISNULL('0','') + ', MultiCounty_INDC = ' + ISNULL(@Lc_Yes_INDC,'');

     INSERT ELRP_Y1
            (EventGlobalRrepSeq_NUMB,
             EventGlobalBackOutSeq_NUMB,
             EventGlobalRePostSeq_NUMB,
             BatchOrig_DATE,
             SourceBatchOrig_CODE,
             BatchOrig_NUMB,
             SeqReceiptOrig_NUMB,
             RePost_INDC,
             Refund_INDC,
             MultiCase_INDC,
             ClosedCase_INDC,
             EventGlobalRefundSeq_NUMB,
             MultiCounty_INDC)
     VALUES ( @Ln_EventGlobalSeqBrep_NUMB,--EventGlobalRrepSeq_NUMB 
              @Ln_EventGlobalSeqRcthBackOut_NUMB,--EventGlobalBackOutSeq_NUMB 
              ISNULL(@Ln_EventGlobalSeqRep_NUMB, 0),--EventGlobalRePostSeq_NUMB 
              @Ld_BatchOrig_DATE,--BatchOrig_DATE 
              @Lc_SourceBatch_CODE,--SourceBatchOrig_CODE 
              @Ln_Batch_NUMB,--BatchOrig_NUMB 
              @Ln_SeqReceipt_NUMB,--SeqReceiptOrig_NUMB 
              @Lc_PRrepCur_RePost_INDC,--RePost_INDC 
              @Lc_Refund_INDC,--Refund_INDC 
              @Lc_PRrepCur_MultiCase_INDC,--MultiCase_INDC 
              @Lc_PRrepCur_ClosedCase_INDC,--ClosedCase_INDC 
              0,--EventGlobalRefundSeq_NUMB 
              @Lc_Yes_INDC); --MultiCounty_INDC

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

       RAISERROR(50001,16,1);
      END

     --BCHK entry for the receipts 
     --Insert BCHK for TypeRemittance 'CHK' and SourceReceipt in (BA  BAIL, BN - Bond, CR  CP Recoupment, CF  CP FEE PAYMENT, 
     --LS  LUMP SUM, PM  Purge Payment, NR  NSF RECOUPMENT, QR  QDRO PAYMENT, Re  REGULAR, VN - VOLUNTARY) and
     --NSF Reason backout in (AC - ACCOUNT CLOSED, NF - NON SUFFICIENT FUNDS, RM - REFER TO MAKER, SP - STOP PAYMENT, UA  UNLOCATED ACCOUNT)
     SET @Ls_Sql_TEXT = 'SELECT_RCTH_FOR_BCHK ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_BatchOrig_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_SourceBatch_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT TOP 1 @Lc_SourceReceipt_CODE = a.SourceReceipt_CODE,
                  @Lc_TypeRemittance_CODE = a.TypeRemittance_CODE
       FROM RCTH_Y1 a
      WHERE a.Batch_DATE = @Ld_BatchOrig_DATE
        AND a.Batch_NUMB = @Ln_Batch_NUMB
        AND a.SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
        AND a.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     IF (@Lc_TypeRemittance_CODE = @Lc_TypeRemittanceChk_CODE
         AND @Lc_SourceReceipt_CODE IN (@Lc_SourceReceiptBailBa_CODE, @Lc_SourceReceiptBondBn_CODE,
                                        @Lc_SourceReceiptLumpSumLs_CODE, @Lc_SourceReceiptPurgePaymentPm_CODE,
                                        @Lc_SourceReceiptNsfRecoupmentNr_CODE, @Lc_SourceReceiptQdroPaymentQr_CODE, @Lc_SourceReceiptRegularRe_CODE, @Lc_SourceReceiptVoluntaryVn_CODE)
         AND @Ac_ReasonBackOut_CODE IN (@Lc_ReasonBackOutAccountClosedAc_CODE, @Lc_ReasonBackOutNsfNf_CODE, @Lc_ReasonBackOutReferToMakerRm_CODE, @Lc_ReasonBackOutStopPaymentSp_CODE, @Lc_ReasonBackOutUnlocatedAcctUa_CODE))
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_BCHK ';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_PRrepCur_PayorMCI_IDNO AS VARCHAR ),'')+ ', BadCheck_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', CountBadCheck_QNTY = ' + ISNULL('1','')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_PRrepCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

       INSERT INTO BCHK_Y1
                   (MemberMci_IDNO,
                    BadCheck_INDC,
                    CountBadCheck_QNTY,
                    EventGlobalSeq_NUMB)
             SELECT @Ln_PRrepCur_PayorMCI_IDNO AS MemberMci_IDNO,
                    @Lc_Yes_INDC AS BadCheck_INDC,
                    1 AS CountBadCheck_QNTY,
                    @Ln_PRrepCur_EventGlobalBeginSeq_NUMB AS EventGlobalSeq_NUMB;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         RAISERROR(50001,16,1);
        END
      END

     FETCH NEXT FROM PRrep_Cur INTO @Ld_PRrepCur_BatchOrig_DATE, @Lc_PRrepCur_SourceBatch_CODE, @Ln_PRrepCur_Batch_NUMB, @Ln_PRrepCur_SeqReceipt_NUMB, @Ld_PRrepCur_Receipt_DATE, @Ln_PRrepCur_Receipt_AMNT, @Lc_PRrepCur_SourceReceipt_CODE, @Lc_PRrepCur_Distd_INDC, @Lc_PRrepCur_Refund_INDC, @Lc_PRrepCur_RePost_INDC, @Lc_PRrepCur_ClosedCase_INDC, @Lc_PRrepCur_MultiCase_INDC, @Ln_PRrepCur_Refund_AMNT, @Ln_PRrepCur_CasePayorMCI_IDNO, @Ln_PRrepCur_CasePayorMCIReposted_IDNO, @Ln_PRrepCur_EventGlobalBeginSeq_NUMB, @Ln_PRrepCur_PayorMCI_IDNO, @Ln_PRrepCur_RepostedPayorMci_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('Local', 'PRrep_Cur') IN (0, 1)
    BEGIN
     CLOSE PRrep_Cur;

     DEALLOCATE PRrep_Cur;
    END

   SET @Ls_Sql_TEXT = 'INSERT_PRORATE ';
   SET @Ls_Sqldata_TEXT = '';
   
   INSERT #RrepProrate_P1
          (CaseWelfare_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           WelfareYearMonth_NUMB,
           ArrToBePaid_AMNT,
           PerMemberProrated_AMNT,
           PerMemberRecoupment_AMNT,
           MemberUnreimbGrant_AMNT)
   SELECT aa.CaseWelfare_IDNO,
          aa.Case_IDNO,
          aa.OrderSeq_NUMB,
          aa.ObligationSeq_NUMB,
          MAX(aa.WelfareYearMonth_NUMB) AS WelfareYearMonth_NUMB,
          MAX(CAST(aa.amt_ltd_recoup AS NUMERIC(11, 2))) AS ArrToBePaid_AMNT,
          MAX(CAST(aa.amt_mtd_recoup AS NUMERIC(11, 2))) AS PerMemberProrated_AMNT,
          SUM(CASE aa.WelfareYearMonth_NUMB
               WHEN bb.WelfareYearMonth_NUMB
                THEN bb.MtdRecoupTanf_AMNT
               ELSE 0
              END) AS PerMemberRecoupment_AMNT,
          SUM(CASE aa.WelfareYearMonth_NUMB
               WHEN bb.WelfareYearMonth_NUMB
                THEN bb.LtdRecoupTanf_AMNT
               ELSE bb.LtdRecoupTanf_AMNT + bb.MtdRecoupTanf_AMNT
              END) AS MemberUnreimbGrant_AMNT
     FROM (SELECT a.CaseWelfare_IDNO,
                  a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.ObligationSeq_NUMB,
                  a.WelfareYearMonth_NUMB,
                  a.LtdAssistRecoup_AMNT - a.MtdAssistRecoup_AMNT AS amt_ltd_recoup,
                  a.MtdAssistRecoup_AMNT AS amt_mtd_recoup
             FROM WEMO_Y1 a
                  JOIN (SELECT a.CaseWelfare_IDNO,
                               MIN(a.WelfareYearMonth_NUMB) AS WelfareYearMonth_NUMB
                          FROM #RrepWelfare_P1 a
                         WHERE a.MtdRecoupTanf_AMNT > 0
                            OR a.LtdRecoupTanf_AMNT > 0
                         GROUP BY a.CaseWelfare_IDNO) b
                   ON a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
            WHERE a.WelfareYearMonth_NUMB >= b.WelfareYearMonth_NUMB
              AND a.EndValidity_DATE = @Ld_High_DATE) aa
          JOIN #RrepWelfare_P1 bb
           ON aa.CaseWelfare_IDNO = bb.CaseWelfare_IDNO
    WHERE bb.WelfareYearMonth_NUMB <= aa.WelfareYearMonth_NUMB
    GROUP BY aa.CaseWelfare_IDNO,
             aa.Case_IDNO,
             aa.OrderSeq_NUMB,
             aa.ObligationSeq_NUMB,
             aa.WelfareYearMonth_NUMB;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'INSERT_RrepPaidRecoup_P1 ';
   SET @Ls_Sqldata_TEXT = '';

   INSERT #RrepPaidRecoup_P1
          (RoundedRecoup_AMNT,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CaseWelfare_IDNO,
           WelfareYearMonth_NUMB,
           ArrPaid_AMNT,
           ArrToBePaid_AMNT,
           ArrRecoupMtd_AMNT,
           Rounded_AMNT)
   SELECT z.ROWNUM AS RoundedRecoup_AMNT,
          z.Case_IDNO,
          z.OrderSeq_NUMB,
          z.ObligationSeq_NUMB,
          z.CaseWelfare_IDNO,
          z.WelfareYearMonth_NUMB,
          dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID(z.MemberUnreimbGrant_AMNT, z.total_arrear, z.ArrToBePaid_AMNT) AS ArrPaid_AMNT,
          z.MemberUnreimbGrant_AMNT AS ArrToBePaid_AMNT,
          dbo.BATCH_COMMON$SF_CAL_ARREAR_PAID(z.PerMemberRecoupment_AMNT, z.total_arrear_mtd, z.PerMemberProrated_AMNT) AS ArrRecoupMtd_AMNT,
          z.PerMemberRecoupment_AMNT AS Rounded_AMNT
     FROM (SELECT y.Case_IDNO,
                  y.OrderSeq_NUMB,
                  y.ObligationSeq_NUMB,
                  y.CaseWelfare_IDNO,
                  y.WelfareYearMonth_NUMB,
                  y.MemberUnreimbGrant_AMNT,
                  y.total_arrear,
                  y.ArrToBePaid_AMNT,
                  y.PerMemberRecoupment_AMNT,
                  y.total_arrear_mtd,
                  y.PerMemberProrated_AMNT,
                  ROW_NUMBER() OVER( ORDER BY y.xcolumn) AS ROWNUM
             FROM (SELECT x.Case_IDNO,
                          x.OrderSeq_NUMB,
                          x.ObligationSeq_NUMB,
                          x.CaseWelfare_IDNO,
                          x.WelfareYearMonth_NUMB,
                          x.MemberUnreimbGrant_AMNT,
                          x.total_arrear,
                          x.ArrToBePaid_AMNT,
                          x.PerMemberRecoupment_AMNT,
                          x.total_arrear_mtd,
                          x.PerMemberProrated_AMNT,
                          0 AS xcolumn
                     FROM (SELECT b.WelfareYearMonth_NUMB,
                                  b.Case_IDNO,
                                  b.OrderSeq_NUMB,
                                  b.ObligationSeq_NUMB,
                                  b.CaseWelfare_IDNO,
                                  b.ArrToBePaid_AMNT,
                                  b.PerMemberProrated_AMNT,
                                  b.PerMemberRecoupment_AMNT,
                                  b.MemberUnreimbGrant_AMNT,
                                  SUM(b.ArrToBePaid_AMNT) OVER(PARTITION BY b.CaseWelfare_IDNO, b.WelfareYearMonth_NUMB ) AS total_arrear,--
                                  SUM(b.PerMemberProrated_AMNT) OVER(PARTITION BY b.CaseWelfare_IDNO, b.WelfareYearMonth_NUMB ) AS total_arrear_mtd --
                             FROM #RrepProrate_P1 b) x) y) z;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   --CENT Adjustment	
   SET @Ls_Sql_TEXT = 'UPDATE_RrepPaidRecoup_P1 1 ';
   SET @Ls_Sqldata_TEXT = '';
   
   UPDATE #RrepPaidRecoup_P1
      SET ArrPaid_AMNT = a.ArrPaid_AMNT + a.ArrToBePaid_AMNT - (SELECT SUM(b.ArrPaid_AMNT)
                                                                  FROM #RrepPaidRecoup_P1 b
                                                                 WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                                                   AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                                                 GROUP BY b.CaseWelfare_IDNO,
                                                                          b.WelfareYearMonth_NUMB)
     FROM #RrepPaidRecoup_P1 a
    WHERE a.RoundedRecoup_AMNT = (SELECT MIN(c.RoundedRecoup_AMNT)
                                    FROM #RrepPaidRecoup_P1 c
                                   WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                     AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                     AND c.ArrPaid_AMNT > 0)
      AND a.ArrPaid_AMNT > 0;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'UPDATE_RrepPaidRecoup_P1 2 ';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE #RrepPaidRecoup_P1
      SET ArrRecoupMtd_AMNT = a.ArrRecoupMtd_AMNT + a.Rounded_AMNT - (SELECT SUM(b.ArrRecoupMtd_AMNT)
                                                                        FROM #RrepPaidRecoup_P1 b
                                                                       WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                                                         AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                                                       GROUP BY b.CaseWelfare_IDNO,
                                                                                b.WelfareYearMonth_NUMB)
     FROM #RrepPaidRecoup_P1 a
    WHERE a.RoundedRecoup_AMNT = (SELECT MIN (c.RoundedRecoup_AMNT)
                                    FROM #RrepPaidRecoup_P1 c
                                   WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                     AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                     AND c.ArrRecoupMtd_AMNT > 0)
      AND a.ArrRecoupMtd_AMNT > 0;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   -- Adjust WEMO for TANF Cases
   SET @Ls_Sql_TEXT = 'INSERT_VWEMO ';
   SET @Ls_Sqldata_TEXT = 'TransactionAssistExpend_AMNT = ' + ISNULL('0','') + ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBrep_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','') ;

   INSERT WEMO_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CaseWelfare_IDNO,
           WelfareYearMonth_NUMB,
           TransactionAssistExpend_AMNT,
           MtdAssistExpend_AMNT,
           LtdAssistExpend_AMNT,
           TransactionAssistRecoup_AMNT,
           MtdAssistRecoup_AMNT,
           LtdAssistRecoup_AMNT,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.CaseWelfare_IDNO,
          a.WelfareYearMonth_NUMB,
          0 AS TransactionAssistExpend_AMNT,--TransactionAssistExpend_AMNT
          a.MtdAssistExpend_AMNT,
          a.LtdAssistExpend_AMNT,
          (aa.ArrPaid_AMNT + aa.ArrRecoupMtd_AMNT) * -1 AS TransactionAssistRecoup_AMNT,--TransactionAssistRecoup_AMNT
          a.MtdAssistRecoup_AMNT - aa.ArrRecoupMtd_AMNT AS MtdAssistRecoup_AMNT,--MtdAssistRecoup_AMNT
          a.LtdAssistRecoup_AMNT - aa.ArrPaid_AMNT - aa.ArrRecoupMtd_AMNT AS LtdAssistRecoup_AMNT,--LtdAssistRecoup_AMNT
          @Ld_Process_DATE AS BeginValidity_DATE,--BeginValidity_DATE
          @Ld_High_DATE AS EndValidity_DATE,--EndValidity_DATE
          @Ln_EventGlobalSeqBrep_NUMB AS EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
          0 AS EventGlobalEndSeq_NUMB --EventGlobalEndSeq_NUMB
     FROM WEMO_Y1 a
          JOIN (SELECT a.Case_IDNO,
                       a.OrderSeq_NUMB,
                       a.ObligationSeq_NUMB,
                       a.CaseWelfare_IDNO,
                       a.WelfareYearMonth_NUMB,
                       a.ArrPaid_AMNT,
                       a.ArrRecoupMtd_AMNT
                  FROM #RrepPaidRecoup_P1 a
                 WHERE a.ArrPaid_AMNT != 0
                    OR a.ArrRecoupMtd_AMNT != 0) aa
           ON a.Case_IDNO = aa.Case_IDNO
              AND a.OrderSeq_NUMB = aa.OrderSeq_NUMB
              AND a.ObligationSeq_NUMB = aa.ObligationSeq_NUMB
              AND a.WelfareYearMonth_NUMB = aa.WelfareYearMonth_NUMB
              AND a.CaseWelfare_IDNO = aa.CaseWelfare_IDNO
    WHERE a.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'UPDATE_VWEMO ';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   UPDATE W
      SET EndValidity_DATE = @Ld_Process_DATE,
          EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeqBrep_NUMB
     FROM WEMO_Y1 W
    WHERE EXISTS (SELECT Case_IDNO,
                         OrderSeq_NUMB,
                         ObligationSeq_NUMB,
                         CaseWelfare_IDNO,
                         WelfareYearMonth_NUMB
                    FROM #RrepPaidRecoup_P1 T
                   WHERE (ArrPaid_AMNT != 0
                           OR ArrRecoupMtd_AMNT != 0)
                     AND W.Case_IDNO = T.Case_IDNO
                     AND W.OrderSeq_NUMB = T.OrderSeq_NUMB
                     AND W.ObligationSeq_NUMB = T.ObligationSeq_NUMB
                     AND W.CaseWelfare_IDNO = T.CaseWelfare_IDNO
                     AND W.WelfareYearMonth_NUMB = T.WelfareYearMonth_NUMB)
      AND EventGlobalBeginSeq_NUMB != @Ln_EventGlobalSeqBrep_NUMB
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'INSERT_VIVMG_TANF ';
   SET @Ls_Sqldata_TEXT = 'TransactionAssistExpend_AMNT = ' + ISNULL('0','') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBrep_NUMB AS VARCHAR ),'');

   INSERT IVMG_Y1
          (CaseWelfare_IDNO,
           WelfareYearMonth_NUMB,
           WelfareElig_CODE,
           TransactionAssistExpend_AMNT,
           MtdAssistExpend_AMNT,
           LtdAssistExpend_AMNT,
           TransactionAssistRecoup_AMNT,
           MtdAssistRecoup_AMNT,
           LtdAssistRecoup_AMNT,
           TypeAdjust_CODE,
           EventGlobalSeq_NUMB,
           ZeroGrant_INDC,
           AdjustLtdFlag_INDC,
           Defra_AMNT,
           CpMci_IDNO)
   SELECT a.CaseWelfare_IDNO,
          a.WelfareYearMonth_NUMB,
          a.WelfareElig_CODE,
          0 AS TransactionAssistExpend_AMNT,
          a.MtdAssistExpend_AMNT,
          a.LtdAssistExpend_AMNT,
          (CAST(aa.amt_mtd_recoup AS NUMERIC(11, 2)) + CAST(aa.amt_ltd_recoup AS NUMERIC(11, 2))) * -1 AS TransactionAssistRecoup_AMNT,
          a.MtdAssistRecoup_AMNT - CAST(aa.amt_mtd_recoup AS NUMERIC(11, 2)) AS MtdAssistRecoup_AMNT,
          a.LtdAssistRecoup_AMNT - CAST(aa.amt_mtd_recoup AS NUMERIC(11, 2)) - CAST(aa.amt_ltd_recoup AS NUMERIC(11, 2)) AS LtdAssistRecoup_AMNT,
          a.TypeAdjust_CODE,
          @Ln_EventGlobalSeqBrep_NUMB AS EventGlobalSeq_NUMB,
          a.ZeroGrant_INDC,
          a.AdjustLtdFlag_INDC,
          a.Defra_AMNT,
          a.CpMci_IDNO
     FROM IVMG_Y1 a
          JOIN (SELECT DISTINCT
                       a.CaseWelfare_IDNO,
                       a.WelfareYearMonth_NUMB,
                       a.PerMemberRecoupment_AMNT AS amt_mtd_recoup,
                       a.MemberUnreimbGrant_AMNT AS amt_ltd_recoup
                  FROM #RrepProrate_P1 a) aa
           ON a.CaseWelfare_IDNO = aa.CaseWelfare_IDNO
              AND a.WelfareYearMonth_NUMB = aa.WelfareYearMonth_NUMB
    WHERE a.EventGlobalSeq_NUMB = (SELECT MAX(a.EventGlobalSeq_NUMB)
                                     FROM IVMG_Y1 a
                                    WHERE a.CaseWelfare_IDNO = aa.CaseWelfare_IDNO
                                      AND a.WelfareYearMonth_NUMB = aa.WelfareYearMonth_NUMB);

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'INSERT_VIVMG_FC ';
   SET @Ls_Sqldata_TEXT = 'TransactionAssistExpend_AMNT = ' + ISNULL('0','') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeqBrep_NUMB AS VARCHAR ),'');

   INSERT IVMG_Y1
          (CaseWelfare_IDNO,
           WelfareYearMonth_NUMB,
           WelfareElig_CODE,
           TransactionAssistExpend_AMNT,
           MtdAssistExpend_AMNT,
           LtdAssistExpend_AMNT,
           TransactionAssistRecoup_AMNT,
           MtdAssistRecoup_AMNT,
           LtdAssistRecoup_AMNT,
           TypeAdjust_CODE,
           EventGlobalSeq_NUMB,
           ZeroGrant_INDC,
           AdjustLtdFlag_INDC,
           Defra_AMNT,
           CpMci_IDNO)
   SELECT x.CaseWelfare_IDNO,
          x.WelfareYearMonth_NUMB,
          x.WelfareElig_CODE,
          0 AS TransactionAssistExpend_AMNT,
          x.MtdAssistExpend_AMNT,
          x.LtdAssistExpend_AMNT,
          (CAST(cc.amt_mtd_recoup AS NUMERIC(11, 2)) + CAST(cc.amt_ltd_recoup AS NUMERIC(11, 2))) * -1 AS TransactionAssistRecoup_AMNT,
          x.MtdAssistRecoup_AMNT - CAST(cc.amt_mtd_recoup AS NUMERIC(11, 2)) AS MtdAssistRecoup_AMNT,
          x.LtdAssistRecoup_AMNT - CAST(cc.amt_mtd_recoup AS NUMERIC(11, 2)) - CAST(cc.amt_ltd_recoup AS NUMERIC(11, 2)) AS LtdAssistRecoup_AMNT,
          x.TypeAdjust_CODE,
          @Ln_EventGlobalSeqBrep_NUMB AS EventGlobalSeq_NUMB,
          x.ZeroGrant_INDC,
          ISNULL(x.AdjustLtdFlag_INDC, @Lc_No_INDC) AS AdjustLtdFlag_INDC,
          x.Defra_AMNT,
          x.CpMci_IDNO
     FROM IVMG_Y1 x,
          (SELECT aa.CaseWelfare_IDNO,
                  aa.WelfareYearMonth_NUMB,
                  aa.max_seg,
                  SUM(CASE aa.WelfareYearMonth_NUMB
                       WHEN bb.WelfareYearMonth_NUMB
                        THEN bb.MtdRecoupFc_AMNT
                       ELSE 0
                      END) AS amt_mtd_recoup,
                  SUM(CASE aa.WelfareYearMonth_NUMB
                       WHEN bb.WelfareYearMonth_NUMB
                        THEN bb.LtdRecoupFc_AMNT
                       ELSE bb.LtdRecoupFc_AMNT + bb.MtdRecoupFc_AMNT
                      END) AS amt_ltd_recoup
             FROM (SELECT a.CaseWelfare_IDNO,
                          a.WelfareYearMonth_NUMB,
                          MAX(a.EventGlobalSeq_NUMB) AS max_seg
                     FROM IVMG_Y1 a
                          JOIN (SELECT a.CaseWelfare_IDNO,
                                       MIN(a.WelfareYearMonth_NUMB) AS WelfareYearMonth_NUMB
                                  FROM #RrepWelfare_P1 a
                                 WHERE a.MtdRecoupFc_AMNT > 0
                                    OR a.LtdRecoupFc_AMNT > 0
                                 GROUP BY a.CaseWelfare_IDNO) b
                           ON a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
                    WHERE a.WelfareYearMonth_NUMB >= b.WelfareYearMonth_NUMB
                    GROUP BY a.CaseWelfare_IDNO,
                             a.WelfareYearMonth_NUMB) aa
                  JOIN #RrepWelfare_P1 bb
                   ON aa.CaseWelfare_IDNO = bb.CaseWelfare_IDNO
            WHERE bb.WelfareYearMonth_NUMB <= aa.WelfareYearMonth_NUMB
            GROUP BY aa.CaseWelfare_IDNO,
                     aa.WelfareYearMonth_NUMB,
                     aa.max_seg) cc
    WHERE x.CaseWelfare_IDNO = cc.CaseWelfare_IDNO
      AND x.WelfareYearMonth_NUMB = cc.WelfareYearMonth_NUMB
      AND x.EventGlobalSeq_NUMB = cc.max_seg;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ls_Sql_TEXT = 'DELETE_PRREP';
   SET @Ls_Sqldata_TEXT = 'Session_ID ' + ISNULL(@Ac_Session_ID, '');
 
   DELETE PRREP_Y1
    WHERE Session_ID = @Ac_Session_ID;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ls_Sql_TEXT = 'DELETE_PRREP_FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   IF CURSOR_STATUS('Local', 'Lsup_Cur') IN (0, 1)
    BEGIN
     CLOSE Lsup_Cur;

     DEALLOCATE Lsup_Cur;
    END

   IF CURSOR_STATUS('Local', 'Receipt_Cur') IN (0, 1)
    BEGIN
     CLOSE Receipt_Cur;

     DEALLOCATE Receipt_Cur;
    END

   IF CURSOR_STATUS('Local', 'Cpfl_Cur') IN (0, 1)
    BEGIN
     CLOSE Cpfl_Cur;

     DEALLOCATE Cpfl_Cur;
    END

   IF CURSOR_STATUS('Local', 'PRrep_Cur') IN (0, 1)
    BEGIN
     CLOSE PRrep_Cur;

     DEALLOCATE PRrep_Cur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @As_DescriptionError_TEXT;
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
