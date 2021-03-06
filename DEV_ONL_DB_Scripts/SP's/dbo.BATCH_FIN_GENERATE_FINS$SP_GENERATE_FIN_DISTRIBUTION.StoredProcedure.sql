/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DISTRIBUTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DISTRIBUTION   
Programmer Name 	: IMP Team
Description			: This Proecdure generates the data to populate all the Collection, Distribution and
					  Disbursement details necessary for Financial Summary (FINS) Report into RFINS_Y1 table  
Frequency			: 'DAILY'
Developed On		: 11/29/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DISTRIBUTION] (
		@Ad_Run_DATE				   DATE,
		@Ad_Start_Run_DATE			   DATE,
		@Ad_PlusOne_Run_DATE		   DATE,
		@Ac_Msg_CODE                   CHAR(1) OUTPUT,
		@As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE
	  @Li_ManuallyDistributeReceipt1810_NUMB INT = 1810,
      @Li_ReceiptDistributed1820_NUMB        INT = 1820,
      @Li_ReceiptReversed1250_NUMB           INT = 1250,
      @Lc_StatusReceiptOthpRefund_CODE       CHAR (1) = 'O',
	  @Lc_StatusReceiptHeld_CODE             CHAR (1) = 'H',
	  @Lc_StatusBatchUnreconciled_CODE       CHAR (1) = 'U',
	  @Lc_StatusReceiptIdentified_CODE       CHAR (1) = 'I',
	  @Lc_Yes_INDC                           CHAR (1) = 'Y',
      @Lc_No_INDC                            CHAR (1) = 'N',
      @Lc_StatusReceiptUnidentified_CODE     CHAR (1) = 'U',
      @Lc_TypeRecordOriginal_CODE            CHAR (1) = 'O',
      @Lc_Today_CODE                         CHAR (1) = 'T',
      @Lc_Previous_CODE                      CHAR (1) = 'P',
      @Lc_TypeHoldAddress_CODE               CHAR (1) = 'A',
      @Lc_StatusReceiptRefund_CODE           CHAR (1) = 'R',
      @Lc_FundRecipientCpNcp_CODE            CHAR (1) = '1',
      @Lc_FundRecipientFIPS_CODE             CHAR (1) = '2',
      @Lc_CheckRecipientOthp_CODE            CHAR (1) = '3',
      @Lc_TypeHoldCP_CODE                    CHAR (1) = 'P',
      @Lc_TypeHoldIVE_CODE                   CHAR (1) = 'E',
      @Lc_TypeHoldTanfT_CODE                 CHAR (1) = 'T',
      @Lc_TypeHoldCheck_CODE                 CHAR (1) = 'C',
      @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
      @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
      @Lc_SourceReceiptCD_CODE               CHAR (2) = 'CD',
	  @Lc_SourceReceiptAC_CODE               CHAR (2) = 'AC',
      @Lc_SourceReceiptAN_CODE               CHAR (2) = 'AN',
      @Lc_SourceBatchDirectPayCredit_CODE    CHAR (3) = 'DCR',
      @Lc_SourceBatchDCS_CODE                CHAR (3) = 'DCS',
	  @Lc_DummyCounty_NUMB                   CHAR (3) = '999',
	  @Lc_TableFINS_IDNO                     CHAR (4) = 'FINS',
	  @Lc_TableSubRCTH_IDNO                  CHAR (4) = 'RCTH',
	  @Lc_TransactionCHWP_CODE               CHAR (4) = 'CHWP',
	  @Lc_HoldReasonStatusSncl_CODE          CHAR (4) = 'SNCL',
	  @Lc_HoldReasonStatusSncc_CODE          CHAR (4) = 'SNCC',
	  @Lc_HoldReasonStatusSnax_CODE          CHAR (4) = 'SNAX',
	  @Lc_HoldReasonStatusSnfx_CODE          CHAR (4) = 'SNFX',
	  @Lc_HoldReasonStatusMnmh_CODE          CHAR (4) = 'MNMH',
	  @Lc_HoldReasonStatusShnd_CODE          CHAR (4) = 'SHND',
	  @Lc_HoldReasonStatusShth_CODE          CHAR (4) = 'SHTH',
	  @Lc_HoldReasonStatusSnno_CODE          CHAR (4) = 'SNNO',
	  @Lc_HoldReasonStatusSnna_CODE          CHAR (4) = 'SNNA',
	  @Lc_HoldReasonStatusSnpo_CODE          CHAR (4) = 'SNPO',
	  @Lc_HoldReasonStatusSnin_CODE          CHAR (4) = 'SNIN',
	  @Lc_HoldReasonStatusSnjn_CODE          CHAR (4) = 'SNJN',
	  @Lc_HoldReasonStatusSnio_CODE          CHAR (4) = 'SNIO',
      @Lc_HoldReasonStatusSnjo_CODE          CHAR (4) = 'SNJO',
      @Lc_HoldReasonStatusSnjw_CODE          CHAR (4) = 'SNJW',
      @Lc_HoldReasonStatusSnjt_CODE          CHAR (4) = 'SNJT',
      @Lc_HoldReasonStatusSnix_CODE          CHAR (4) = 'SNIX',
      @Lc_HoldReasonStatusSnxo_CODE          CHAR (4) = 'SNXO',
      @Lc_HoldReasonStatusSnjx_CODE          CHAR (4) = 'SNJX',
      @Lc_HoldReasonStatusShru_CODE          CHAR (4) = 'SHRU',
      @Lc_HoldReasonStatusSnbn_CODE          CHAR (4) = 'SNBN',
      @Lc_HoldReasonStatusSnjm_CODE          CHAR (4) = 'SNJM',
      @Lc_HoldReasonStatusSnqr_CODE          CHAR (4) = 'SNQR',
      @Lc_HoldReasonStatusSnwc_CODE          CHAR (4) = 'SNWC',
      @Lc_HoldReasonStatusSnle_CODE          CHAR (4) = 'SNLE',
      @Lc_HoldReasonStatusSnsq_CODE          CHAR (4) = 'SNSQ',
      @Lc_HoldReasonStatusSnsn_CODE          CHAR (4) = 'SNSN',
      @Lc_HoldReasonStatusSnru_CODE          CHAR (4) = 'SNRU',
      @Lc_HoldReasonStatusQdro_CODE          CHAR (4) = 'QDRO',
      @Lc_HoldReasonStatusCsln_CODE          CHAR (4) = 'CSLN',
      @Lc_HoldReasonStatusSnip_CODE          CHAR (4) = 'SNIP',
      @Lc_TableSubREFT_IDNO                  CHAR (4) = 'REFT',
      @Lc_TableSubDHLH_IDNO                  CHAR (4) = 'DHLH',
      @Lc_TypeDisburseRefund_CODE            CHAR (5) = 'REFND',
      @Lc_TypeDisburseOthp_CODE              CHAR (5) = 'ROTHP',
      @Lc_RefundRecipientOfficeIVA_ID		 CHAR (9) = '999999994',
      @Lc_RefundRecipientOfficeIVE_ID		 CHAR (9) = '999999993',
      @Lc_CheckRecipientTreasury_ID			 CHAR (9) = '999999983',
      @Lc_CheckRecipientMEDI_ID			     CHAR (9) = '999999982',
      @Lc_CheckRecipientDra_ID				 CHAR (9) = '999999978',	
      @Lc_CheckRecipientSpc_ID				 CHAR (9) = '999999977',
      @Lc_CheckRecipientCpNsf_ID			 CHAR (9) = '999999964',	
      @Lc_CheckRecipientNcpNsf_ID			 CHAR (9) = '999999963',	
      @Lc_CheckRecipientGt_ID				 CHAR (9) = '999999976',
      @Lc_CheckRecipientOSR_ID				 CHAR (9) = '999999980',
      @Ls_Procedure_NAME                     VARCHAR (100) = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DISTRIBUTION',
      @Ld_Low_DATE                           DATE = '01/01/0001',
      @Ld_High_DATE                          DATE = '12/31/9999';
  DECLARE
	  @Ln_Error_NUMB                       NUMERIC (11),
      @Ln_ErrorLine_NUMB                   NUMERIC (11),
	  @Li_Rowcount_QNTY                    SMALLINT,
	  @Ls_Sql_TEXT                         VARCHAR (100) = ' ',
	  @Ls_Sqldata_TEXT                     VARCHAR (4000) = ' ',
	  @Ls_ErrorMessage_TEXT                VARCHAR (4000),
	  @Ls_DescriptionError_TEXT            VARCHAR (4000);	 
BEGIN TRY
   --------------------------------------------------------------------------------
   --      FINS REPORT -- DISTRIBUTION TAB  CALCULATION                          --
   --------------------------------------------------------------------------------
   --------------------------------------- Daily Held Collections - Table --------------------------------
   -- Full Held -- Today's Collection
   SET @Ls_Sql_TEXT = 'DAILY_HELD_FULL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Heading_NAME = ' + 'DIST-HELDCOLL-FULL' + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '') + ', County_IDNO = ' + CAST(@Lc_DummyCounty_NUMB AS VARCHAR);
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          @Ad_Run_DATE AS Generate_DATE,
          'DIST-HELDCOLL-FULL' AS Heading_NAME,
          b.RecordType_CODE,
          SUM(CASE CASE
                    WHEN ((a.Receipt_AMNT - a.ToDistribute_AMNT) IS NULL)
                     THEN 2
                    ELSE (a.Receipt_AMNT - a.ToDistribute_AMNT)
                   END
               WHEN 0
                THEN 1
               ELSE 0
              END) OVER(PARTITION BY b.RecordType_CODE) AS Count_QNTY,
          SUM(CASE CASE
                    WHEN ((a.Receipt_AMNT - a.ToDistribute_AMNT) IS NULL)
                     THEN 2
                    ELSE (a.Receipt_AMNT - a.ToDistribute_AMNT)
                   END
               WHEN 0
                THEN ISNULL(a.ToDistribute_AMNT, 0)
               ELSE 0
              END) OVER(PARTITION BY b.RecordType_CODE) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT r.Value_CODE AS RecordType_CODE
             FROM REFM_Y1 r
            WHERE r.Table_ID = @Lc_TableFINS_IDNO
              AND r.TableSub_ID = @Lc_TableSubRCTH_IDNO) AS b
          LEFT OUTER JOIN (SELECT CASE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSncl_CODE, @Lc_HoldReasonStatusSncc_CODE)
                                    THEN @Lc_HoldReasonStatusSncl_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnax_CODE, @Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusMnmh_CODE, @Lc_HoldReasonStatusShnd_CODE, @Lc_HoldReasonStatusShth_CODE)
                                    THEN a.ReasonStatus_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnno_CODE, @Lc_HoldReasonStatusSnna_CODE, @Lc_HoldReasonStatusSnpo_CODE)
                                    THEN @Lc_HoldReasonStatusSnno_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnin_CODE, @Lc_HoldReasonStatusSnjn_CODE, @Lc_HoldReasonStatusSnio_CODE, @Lc_HoldReasonStatusSnjo_CODE,
                                                                @Lc_HoldReasonStatusSnjw_CODE, @Lc_HoldReasonStatusSnjt_CODE, @Lc_HoldReasonStatusSnix_CODE, @Lc_HoldReasonStatusSnxo_CODE,
                                                                @Lc_HoldReasonStatusSnjx_CODE, @Lc_HoldReasonStatusSnsn_CODE)
                                    THEN @Lc_HoldReasonStatusSnin_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusShru_CODE)
                                    THEN @Lc_HoldReasonStatusSnru_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnbn_CODE, @Lc_HoldReasonStatusSnjm_CODE)
                                    THEN @Lc_HoldReasonStatusSnbn_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnqr_CODE)
                                    THEN @Lc_HoldReasonStatusQdro_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnwc_CODE, @Lc_HoldReasonStatusSnle_CODE)
                                    THEN @Lc_HoldReasonStatusCsln_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnsq_CODE)
                                    THEN @Lc_HoldReasonStatusSnsq_CODE
                                   ELSE 'OTH'
                                  END AS TypeRecord_CODE,
                                  --IRS Joint Hold is not included yet
                                  a.Receipt_AMNT,
                                  a.ToDistribute_AMNT
                             FROM RCTH_Y1 a
                            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                              AND a.EndValidity_DATE > @Ad_Run_DATE
                              AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                    OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                        AND EXISTS (SELECT 1 
                                                      FROM RCTR_Y1 b
                                                     WHERE a.Batch_DATE = b.Batch_DATE
                                                       AND a.Batch_NUMB = b.Batch_NUMB
                                                       AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                       AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                       AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                       AND b.EndValidity_DATE > @Ad_Run_DATE)))
                              AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                              AND NOT EXISTS (SELECT 1 
                                                FROM RCTH_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                              AND NOT EXISTS (SELECT 1 
                                                FROM RCTH_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                 AND b.BackOut_INDC = @Lc_Yes_INDC
                                                 AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
                              AND NOT EXISTS (-- Unreconciled Value_AMNT should not be included
                                             SELECT 1 
                                                FROM RBAT_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
                              -- A Reposted RCTH_Y1 in RCTH 
                              -- B Reposted RCTH_Y1 in RCTR 
                              -- C Original Backed out RCTH_Y1 in RCTH 
                              -- D First entry of Original RCTH_Y1 in RCTH 
                              AND ((NOT EXISTS (SELECT 1 
                                                  FROM RCTR_Y1 b
                                                 WHERE a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND b.EndValidity_DATE > @Ad_Run_DATE))
                                    OR (EXISTS (SELECT 1 
                                                  FROM RCTR_Y1 b,
                                                       RCTH_Y1 c,
                                                       RCTH_Y1 d -- Checking Repost
                                                 WHERE a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND b.EndValidity_DATE > @Ad_Run_DATE
                                                   AND b.BatchOrig_DATE = c.Batch_DATE
                                                   AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                   AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                   AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                   AND c.EndValidity_DATE > @Ad_Run_DATE
                                                   AND c.BackOut_INDC = @Lc_Yes_INDC
                                                   AND b.BatchOrig_DATE = d.Batch_DATE
                                                   AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                   AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                   AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                   AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                       FROM RCTH_Y1 x
                                                                                      WHERE d.Batch_DATE = x.Batch_DATE
                                                                                        AND d.Batch_NUMB = x.Batch_NUMB
                                                                                        AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                        AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                   AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                                   AND d.BackOut_INDC = @Lc_No_INDC)))) AS a
           ON a.TypeRecord_CODE = b.RecordType_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Full Held -- Today's Collection -- Total
   SET @Ls_Sql_TEXT = 'DAILY_HELD_FULL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-HELDCOLL-FULL' AS Heading_NAME,
           'HLT' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.amt,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(f.Count_QNTY) AS Count_QNTY,
                   SUM(f.Value_AMNT) AS amt
              FROM RFINS_Y1  f
             WHERE f.Generate_DATE = @Ad_Run_DATE
               AND f.Heading_NAME = 'DIST-HELDCOLL-FULL') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Full Held -- Previous Collection -- Total
   SET @Ls_Sql_TEXT = 'PREVIOUS_HELD_FULL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-HELDCOLL-FULL','')+ ', TypeRecord_CODE = ' + ISNULL('HLP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-HELDCOLL-FULL' AS Heading_NAME,
           'HLP' AS TypeRecord_CODE,
           ISNULL(SUM(CASE (a.Receipt_AMNT - a.ToDistribute_AMNT)
                       WHEN 0
                        THEN 1
                       ELSE 0
                      END), 0) AS Count_QNTY,
           ISNULL(SUM(CASE (a.Receipt_AMNT - a.ToDistribute_AMNT)
                       WHEN 0
                        THEN a.ToDistribute_AMNT
                       ELSE 0
                      END), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND a.EndValidity_DATE > @Ad_Run_DATE
       AND (a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
             OR (a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                 AND a.Distribute_DATE = @Ld_Low_DATE
                 AND NOT EXISTS (SELECT 1 
                                   FROM RBAT_Y1 b
                                  WHERE a.Batch_DATE = b.Batch_DATE
                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                    AND a.Batch_NUMB = b.Batch_NUMB
                                    AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                -- Future Releases(doesn't include Identified Unreconciled))
                                )))
       AND
       -- Unreconciled Value_AMNT should not be included 
       NOT EXISTS (SELECT 1 
                     FROM RBAT_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                      AND b.EndValidity_DATE > @Ad_Run_DATE)
       -- A Reposted RCTH_Y1 in RCTH 
       -- B Reposted RCTH_Y1 in RCTR 
       -- C Original Backed out RCTH_Y1 in RCTH 
       -- D First entry of Original RCTH_Y1 in RCTH 
       AND
       -- Receipts which was identified and reconciled on today and it went to hold.  
       -- Both the receipts are not included in Held From Previous Collections (HLP) 
       -- and this Value_AMNT is acCOUNTed in Released From Previous Collections (RLP)
       (EXISTS (SELECT 1 
                  FROM RCTH_Y1 b
                 WHERE a.Batch_DATE = b.Batch_DATE
                   AND a.Batch_NUMB = b.Batch_NUMB
                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                   AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
         OR EXISTS (SELECT 1 
                      FROM RCTR_Y1 b,
                           RCTH_Y1 c,
                           RCTH_Y1 d -- Checking Repost
                     WHERE a.Batch_DATE = b.Batch_DATE
                       AND a.Batch_NUMB = b.Batch_NUMB
                       AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                       AND a.SourceBatch_CODE = b.SourceBatch_CODE
                       AND b.EndValidity_DATE > @Ad_Run_DATE
                       AND b.BatchOrig_DATE = c.Batch_DATE
                       AND b.BatchOrig_NUMB = c.Batch_NUMB
                       AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                       AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                       AND c.EndValidity_DATE > @Ad_Run_DATE
                       AND c.BackOut_INDC = @Lc_Yes_INDC
                       AND b.BatchOrig_DATE = d.Batch_DATE
                       AND b.BatchOrig_NUMB = d.Batch_NUMB
                       AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                       AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                       AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                           FROM RCTH_Y1 x
                                                          WHERE d.Batch_DATE = x.Batch_DATE
                                                            AND d.Batch_NUMB = x.Batch_NUMB
                                                            AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                            AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                       AND c.BeginValidity_DATE != d.BeginValidity_DATE
                       AND d.BackOut_INDC = @Lc_No_INDC))
       -- Do not include previously held Receipts
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                          AND
                          -- SNIP are also Identified ones
                          b.ReasonStatus_CODE != @Lc_HoldReasonStatusSnip_CODE
                          AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(c.EventGlobalBeginSeq_NUMB) 
                                                              FROM RCTH_Y1 c
                                                             WHERE c.Batch_DATE = b.Batch_DATE
                                                               AND c.SourceBatch_CODE = b.SourceBatch_CODE
                                                               AND c.Batch_NUMB = b.Batch_NUMB
                                                               AND c.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                               AND c.BeginValidity_DATE < @Ad_Start_Run_DATE
                                                               AND
                                                               -- To Get the Last but Previous record  
                                                               c.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE))
       -- Latest RCTH_Y1 shouldn't have been backed out
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                          AND b.EndValidity_DATE > @Ad_Run_DATE
                          AND b.BackOut_INDC = @Lc_Yes_INDC));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Partial Held -- Today's Collection
   SET @Ls_Sql_TEXT = 'DAILY_HELD_PARTIAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          @Ad_Run_DATE AS Generate_DATE,
          'DIST-HELDCOLL-PART' AS Heading_NAME,
          b.RecordType_CODE,
          SUM(CASE ISNULL((a.Receipt_AMNT - a.ToDistribute_AMNT), 0)
               WHEN 0
                THEN 0
               ELSE 1
              END) OVER(PARTITION BY b.RecordType_CODE) AS Count_QNTY,
          SUM(CASE ISNULL((a.Receipt_AMNT - a.ToDistribute_AMNT), 0)
               WHEN 0
                THEN 0
               ELSE ISNULL(a.ToDistribute_AMNT, 0)
              END) OVER(PARTITION BY b.RecordType_CODE) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT r.Value_CODE AS RecordType_CODE
             FROM REFM_Y1 r
            WHERE r.Table_ID = @Lc_TableFINS_IDNO
              AND r.TableSub_ID = @Lc_TableSubRCTH_IDNO) AS b
          LEFT OUTER JOIN (SELECT CASE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSncl_CODE, @Lc_HoldReasonStatusSncc_CODE)
                                    THEN @Lc_HoldReasonStatusSncl_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnax_CODE, @Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusMnmh_CODE, @Lc_HoldReasonStatusShnd_CODE, @Lc_HoldReasonStatusShth_CODE)
                                    THEN a.ReasonStatus_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnno_CODE, @Lc_HoldReasonStatusSnna_CODE, @Lc_HoldReasonStatusSnpo_CODE)
                                    THEN @Lc_HoldReasonStatusSnno_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnin_CODE, @Lc_HoldReasonStatusSnjn_CODE, @Lc_HoldReasonStatusSnio_CODE, @Lc_HoldReasonStatusSnjo_CODE,
                                                                @Lc_HoldReasonStatusSnjw_CODE, @Lc_HoldReasonStatusSnjt_CODE, @Lc_HoldReasonStatusSnix_CODE, @Lc_HoldReasonStatusSnxo_CODE,
                                                                @Lc_HoldReasonStatusSnjx_CODE, @Lc_HoldReasonStatusSnsn_CODE)
                                    THEN @Lc_HoldReasonStatusSnin_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusShru_CODE)
                                    THEN @Lc_HoldReasonStatusSnru_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnbn_CODE, @Lc_HoldReasonStatusSnjm_CODE)
                                    THEN @Lc_HoldReasonStatusSnbn_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnqr_CODE)
                                    THEN @Lc_HoldReasonStatusQdro_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnwc_CODE, @Lc_HoldReasonStatusSnle_CODE)
                                    THEN @Lc_HoldReasonStatusCsln_CODE
                                   WHEN a.ReasonStatus_CODE IN (@Lc_HoldReasonStatusSnsq_CODE)
                                    THEN @Lc_HoldReasonStatusSnsq_CODE
                                   ELSE 'OTH'
                                  END AS TypeRecord_CODE,
                                  --IRS Joint Hold is not included yet
                                  a.Receipt_AMNT,
                                  a.ToDistribute_AMNT
                             FROM RCTH_Y1 a
                            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                              AND a.EndValidity_DATE > @Ad_Run_DATE
                              AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                    OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                        AND EXISTS (SELECT 1 
                                                      FROM RCTR_Y1 b
                                                     WHERE a.Batch_DATE = b.Batch_DATE
                                                       AND a.Batch_NUMB = b.Batch_NUMB
                                                       AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                       AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                       AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                       AND b.EndValidity_DATE > @Ad_Run_DATE)))
                              AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                              AND NOT EXISTS (SELECT 1 
                                                FROM RCTH_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                              AND NOT EXISTS (SELECT 1 
                                                FROM RBAT_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
                              -- Unreconciled amount should not be included
                              AND NOT EXISTS (SELECT 1 
                                                FROM RCTH_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                 AND b.BackOut_INDC = @Lc_Yes_INDC
                                                 AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
                              -- A Reposted RCTH_Y1 in RCTH 
                              -- B Reposted RCTH_Y1 in RCTR 
                              -- C Original Backed out RCTH_Y1 in RCTH 
                              -- D First entry of Original RCTH_Y1 in RCTH 
                              AND ((NOT EXISTS (SELECT 1 
                                                  FROM RCTR_Y1 b
                                                 WHERE a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND b.EndValidity_DATE > @Ad_Run_DATE))
                                    OR (EXISTS (SELECT 1 
                                                  FROM RCTR_Y1 b,
                                                       RCTH_Y1 c,
                                                       RCTH_Y1 d -- Checking Repost
                                                 WHERE a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND b.EndValidity_DATE > @Ad_Run_DATE
                                                   AND b.BatchOrig_DATE = c.Batch_DATE
                                                   AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                   AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                   AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                   AND c.EndValidity_DATE > @Ad_Run_DATE
                                                   AND c.BackOut_INDC = @Lc_Yes_INDC
                                                   AND b.BatchOrig_DATE = d.Batch_DATE
                                                   AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                   AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                   AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                   AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                       FROM RCTH_Y1 x
                                                                                      WHERE d.Batch_DATE = x.Batch_DATE
                                                                                        AND d.Batch_NUMB = x.Batch_NUMB
                                                                                        AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                        AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                   AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                                   AND d.BackOut_INDC = @Lc_No_INDC)))) AS a
           ON a.TypeRecord_CODE = b.RecordType_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Partial Held -- Today's Collection -- Total
   SET @Ls_Sql_TEXT = 'DAILY_HELD_PARTIAL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Heading_NAME = ' + 'DIST-HELDCOLL-PART' + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '') + ', County_IDNO = ' + CAST(@Lc_DummyCounty_NUMB AS VARCHAR);

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-HELDCOLL-PART' AS Heading_NAME,
           'HLT' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(r.Count_QNTY) AS Count_QNTY,
                   SUM(r.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1  r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'DIST-HELDCOLL-PART') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Partial Held -- Previous Collection - Total
   SET @Ls_Sql_TEXT = 'PREVIOUS_HELD_PARTIAL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-HELDCOLL-PART','')+ ', TypeRecord_CODE = ' + ISNULL('HLP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-HELDCOLL-PART' AS Heading_NAME,
           'HLP' AS TypeRecord_CODE,
           ISNULL(SUM(CASE (a.Receipt_AMNT - a.ToDistribute_AMNT)
                       WHEN 0
                        THEN 0
                       ELSE 1
                      END), 0) AS Count_QNTY,
           ISNULL(SUM(CASE ISNULL((a.Receipt_AMNT - a.ToDistribute_AMNT), 0)
                       WHEN 0
                        THEN 0
                       ELSE ISNULL(a.ToDistribute_AMNT, 0)
                      END), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.EndValidity_DATE > @Ad_Run_DATE
       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND (a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
             OR (a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                 AND a.Distribute_DATE = @Ld_Low_DATE
                 AND
                 -- Unreconciled Value_AMNT should not be included 
                 NOT EXISTS (SELECT 1 
                               FROM RBAT_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND
       -- Unreconciled Value_AMNT should not be included 
       NOT EXISTS (SELECT 1 
                     FROM RBAT_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                      AND b.EndValidity_DATE > @Ad_Run_DATE)
       -- A Reposted RCTH_Y1 in RCTH 
       -- B Reposted RCTH_Y1 in RCTR 
       -- C Original Backed out RCTH_Y1 in RCTH 
       -- D First entry of Original RCTH_Y1 in RCTH 
       AND
       -- Receipts which was identified and reconciled on today and it went to hold.  
       -- Both the receipts are not included in Held From Previous Collections (HLP) 
       -- and this Value_AMNT is acCOUNTed in Released From Previous Collections (RLP)
       (EXISTS (SELECT 1 
                  FROM RCTH_Y1 b
                 WHERE a.Batch_DATE = b.Batch_DATE
                   AND a.Batch_NUMB = b.Batch_NUMB
                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                   AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
         OR EXISTS (SELECT 1 
                      FROM RCTR_Y1 b,
                           RCTH_Y1 c,
                           RCTH_Y1 d -- Checking Repost
                     WHERE a.Batch_DATE = b.Batch_DATE
                       AND a.Batch_NUMB = b.Batch_NUMB
                       AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                       AND a.SourceBatch_CODE = b.SourceBatch_CODE
                       AND b.EndValidity_DATE > @Ad_Run_DATE
                       AND b.BatchOrig_DATE = c.Batch_DATE
                       AND b.BatchOrig_NUMB = c.Batch_NUMB
                       AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                       AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                       AND c.EndValidity_DATE > @Ad_Run_DATE
                       AND c.BackOut_INDC = @Lc_Yes_INDC
                       AND b.BatchOrig_DATE = d.Batch_DATE
                       AND b.BatchOrig_NUMB = d.Batch_NUMB
                       AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                       AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                       AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                           FROM RCTH_Y1 x
                                                          WHERE d.Batch_DATE = x.Batch_DATE
                                                            AND d.Batch_NUMB = x.Batch_NUMB
                                                            AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                            AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                       AND c.BeginValidity_DATE != d.BeginValidity_DATE
                       AND d.BackOut_INDC = @Lc_No_INDC))
       AND
       -- Do not include previously held Receipts
       NOT EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                      AND
                      -- SNIP are also Identified ones
                      b.ReasonStatus_CODE != @Lc_HoldReasonStatusSnip_CODE
                      AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(c.EventGlobalBeginSeq_NUMB) 
                                                          FROM RCTH_Y1 c
                                                         WHERE c.Batch_DATE = b.Batch_DATE
                                                           AND c.SourceBatch_CODE = b.SourceBatch_CODE
                                                           AND c.Batch_NUMB = b.Batch_NUMB
                                                           AND c.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                           AND c.BeginValidity_DATE < @Ad_Start_Run_DATE
                                                           AND 
                                                           -- To Get the Last but Previous record  
                                                           c.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE))
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                          AND b.EndValidity_DATE > @Ad_Run_DATE
                          AND b.BackOut_INDC = @Lc_Yes_INDC));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Daily Held Collection  -- Total
   SET @Ls_Sql_TEXT = 'DAILY_HELD_FULL_PARTIAL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL('TTL','');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           r.Generate_DATE,
           r.Heading_NAME,
           'TTL' AS TypeRecord_CODE,
           ISNULL(SUM(r.Count_QNTY) OVER(PARTITION BY r.Heading_NAME), 0) AS Count_QNTY,
           ISNULL(SUM(r.Value_AMNT) OVER(PARTITION BY r.Heading_NAME), 0) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME LIKE 'DIST-HELDCOLL%'
       AND r.TypeRecord_CODE IN ('HLT', 'HLP'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --------------------------------------- Distribution Processed - Table --------------------------------
   --Undistributed due to Hold -- Today's Collection
   SET @Ls_Sql_TEXT = 'UNDIST_DUE_TO_HOLD_DAILY';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-PROC-PREV','')+ ', TypeRecord_CODE = ' + ISNULL('UHP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-PROC-TOD' AS Heading_NAME,
           'UHT' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')), 0) AS Count_QNTY,
           ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.EndValidity_DATE > @Ad_Run_DATE
       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND (a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
            AND a.Distribute_DATE = @Ld_Low_DATE)
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
       -- Latest RCTH_Y1 shouldn't have been backed out
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                          AND b.EndValidity_DATE > @Ad_Run_DATE
                          AND b.BackOut_INDC = 'Y'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Undistributed due to Hold -- Previous Collection
   SET @Ls_Sql_TEXT = 'UNDIST_DUE_TO_HOLD_PREVIOUS';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-PROC-PREV','')+ ', TypeRecord_CODE = ' + ISNULL('UHP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-PROC-PREV' AS Heading_NAME,
           'UHP' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')), 0) AS Count_QNTY,
           ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.EndValidity_DATE > @Ad_Run_DATE
       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND (a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
            AND a.Distribute_DATE = @Ld_Low_DATE)
       AND EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
       AND
       -- Do not include previously held Receipts
       NOT EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                      AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(c.EventGlobalBeginSeq_NUMB) 
                                                          FROM RCTH_Y1 c
                                                         WHERE c.Batch_DATE = b.Batch_DATE
                                                           AND c.SourceBatch_CODE = b.SourceBatch_CODE
                                                           AND c.Batch_NUMB = b.Batch_NUMB
                                                           AND c.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                           AND c.BeginValidity_DATE < @Ad_Start_Run_DATE
                                                           AND c.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE))
       AND
       -- Latest RCTH_Y1 shouldn't have been backed out
       NOT EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                      AND b.EndValidity_DATE > @Ad_Run_DATE
                      AND b.BackOut_INDC = 'Y'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Undistributed due to Unidentified -- Today's Collection
   SET @Ls_Sql_TEXT = 'UNDIST_DUE_TO_UNIDENTIFIED_DAILY';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-PROC-TOD','')+ ', TypeRecord_CODE = ' + ISNULL('UUT','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-PROC-TOD' AS Heading_NAME,
           'UUT' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')), 0) AS Count_QNTY,
           ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.EndValidity_DATE > @Ad_Run_DATE
       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND (a.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
            AND a.Distribute_DATE = @Ld_Low_DATE)
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE)
       AND
       -- Latest RCTH_Y1 shouldn't have been backed out
       NOT EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                      AND b.EndValidity_DATE > @Ad_Run_DATE
                      AND b.BackOut_INDC = 'Y'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Undistributed due to Unidentified -- Previous Collection
   SET @Ls_Sql_TEXT = 'UNDIST_DUE_TO_UNIDENTIFIED_PREVIOUS';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-PROC-PREV','')+ ', TypeRecord_CODE = ' + ISNULL('UUP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-PROC-PREV' AS Heading_NAME,
           'UUP' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')), 0) AS Count_QNTY,
           ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a
     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.EndValidity_DATE > @Ad_Run_DATE
       AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
             OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND (a.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
            AND a.Distribute_DATE = @Ld_Low_DATE)
       AND EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
       AND
       -- Latest RCTH_Y1 shouldn't have been backed out
       NOT EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                      AND b.EndValidity_DATE > @Ad_Run_DATE
                      AND b.BackOut_INDC = 'Y'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Distribution Processed  - Today's Collection --
   SET @Ls_Sql_TEXT = 'DIST_PROCESS_FROM_TODAY_COLL';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-PROC-TOD','')+ ', TypeRecord_CODE = ' + ISNULL('DTT','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-PROC-TOD' AS Heading_NAME,
           'DTT' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(a.TransactionNaa_AMNT + a.TransactionTaa_AMNT + a.TransactionPaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUda_AMNT + a.TransactionUpa_AMNT + a.TransactionIvef_AMNT + a.TransactionMedi_AMNT + a.TransactionFuture_AMNT + a.TransactionNffc_AMNT + a.TransactionNonIvd_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM CASE_Y1 x,
           LSUP_Y1 a
     WHERE x.Case_IDNO = a.Case_IDNO
       AND a.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDirectPayCredit_CODE, @Lc_SourceBatchDCS_CODE)
             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND
       -- To exclude Non-Cash Backouts
       (a.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB)
         OR (a.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB
             AND EXISTS (SELECT 1 
                           FROM RCTH_Y1 b
                          WHERE a.Batch_DATE = b.Batch_DATE
                            AND a.Batch_NUMB = b.Batch_NUMB
                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                            AND a.Distribute_DATE = b.BeginValidity_DATE
                            AND b.BackOut_INDC = @Lc_No_INDC
                            AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND ((NOT EXISTS (SELECT 1 
                           FROM RCTR_Y1 b
                          WHERE a.Batch_DATE = b.Batch_DATE
                            AND a.Batch_NUMB = b.Batch_NUMB
                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                            AND b.EndValidity_DATE > @Ad_Run_DATE))
             OR (EXISTS (SELECT 1 
                           FROM RCTR_Y1 b,
                                RCTH_Y1 c,
                                RCTH_Y1 d -- Checking Repost
                          WHERE a.Batch_DATE = b.Batch_DATE
                            AND a.Batch_NUMB = b.Batch_NUMB
                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                            AND b.EndValidity_DATE > @Ad_Run_DATE
                            AND b.BatchOrig_DATE = c.Batch_DATE
                            AND b.BatchOrig_NUMB = c.Batch_NUMB
                            AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                            AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                            AND c.EndValidity_DATE > @Ad_Run_DATE
                            AND c.BackOut_INDC = @Lc_Yes_INDC
                            AND b.BatchOrig_DATE = d.Batch_DATE
                            AND b.BatchOrig_NUMB = d.Batch_NUMB
                            AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                            AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                            AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                FROM RCTH_Y1 x
                                                               WHERE d.Batch_DATE = x.Batch_DATE
                                                                 AND d.Batch_NUMB = x.Batch_NUMB
                                                                 AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                 AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                            AND c.BeginValidity_DATE = d.BeginValidity_DATE
                            AND d.BackOut_INDC = @Lc_No_INDC)))
       AND NOT EXISTS (SELECT 1 
                         FROM RCTH_Y1 b
                        WHERE a.Batch_DATE = b.Batch_DATE
                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                          AND a.Batch_NUMB = b.Batch_NUMB
                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                          AND b.BeginValidity_DATE < @Ad_Start_Run_DATE));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Distribution Processed  - Previous Collection --
   SET @Ls_Sql_TEXT = 'DIST_PROCESS_FROM_PREV_COLL';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DIST-PROC-PREV','')+ ', TypeRecord_CODE = ' + ISNULL('DTP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'DIST-PROC-PREV' AS Heading_NAME,
           'DTP' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(a.TransactionNaa_AMNT + a.TransactionTaa_AMNT + a.TransactionPaa_AMNT + a.TransactionCaa_AMNT + a.TransactionUda_AMNT + a.TransactionUpa_AMNT + a.TransactionIvef_AMNT + a.TransactionMedi_AMNT + a.TransactionFuture_AMNT + a.TransactionNffc_AMNT + a.TransactionNonIvd_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM CASE_Y1 x,
           LSUP_Y1 a
     WHERE x.Case_IDNO = a.Case_IDNO
       AND a.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND a.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDirectPayCredit_CODE, @Lc_SourceBatchDCS_CODE)
             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                 AND EXISTS (SELECT 1 
                               FROM RCTR_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND (a.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB)
             -- 1810 -- Manual Distribution
             -- 1820 -- Batch Distribution
             OR (a.EventFunctionalSeq_NUMB = @Li_ReceiptReversed1250_NUMB
                 -- Distributed and Backed out today itself
                 AND EXISTS (SELECT 1 
                               FROM RCTH_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND a.Distribute_DATE = b.BeginValidity_DATE
                                AND b.BackOut_INDC = @Lc_No_INDC
                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
       AND
       -- Unreconciled Value_AMNT should not be included 
       NOT EXISTS (SELECT 1 
                     FROM RBAT_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                      AND b.EndValidity_DATE > @Ad_Run_DATE)
       AND
       -- Do not to include the Reversed Receipts
       NOT EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND b.BackOut_INDC = 'Y'
                      AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                      AND b.EndValidity_DATE > @Ad_Run_DATE)
       -- A Reposted RCTH_Y1 in RCTH 
       -- B Reposted RCTH_Y1 in RCTR 
       -- C Original Backed out RCTH_Y1 in RCTH 
       -- D First entry of Original RCTH_Y1 in RCTH 
       AND ((EXISTS (SELECT 1 
                       FROM RCTH_Y1 b
                      WHERE a.Batch_DATE = b.Batch_DATE
                        AND a.Batch_NUMB = b.Batch_NUMB
                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                        AND b.BeginValidity_DATE < @Ad_Start_Run_DATE))
             OR (EXISTS (SELECT 1 
                           FROM RCTR_Y1 b,
                                RCTH_Y1 c,
                                RCTH_Y1 d -- Checking Repost
                          WHERE a.Batch_DATE = b.Batch_DATE
                            AND a.Batch_NUMB = b.Batch_NUMB
                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                            AND b.EndValidity_DATE > @Ad_Run_DATE
                            AND b.BatchOrig_DATE = c.Batch_DATE
                            AND b.BatchOrig_NUMB = c.Batch_NUMB
                            AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                            AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                            AND c.EndValidity_DATE > @Ad_Run_DATE
                            AND c.BackOut_INDC = @Lc_Yes_INDC
                            AND b.BatchOrig_DATE = d.Batch_DATE
                            AND b.BatchOrig_NUMB = d.Batch_NUMB
                            AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                            AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                            AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                FROM RCTH_Y1 x
                                                               WHERE d.Batch_DATE = x.Batch_DATE
                                                                 AND d.Batch_NUMB = x.Batch_NUMB
                                                                 AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                 AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                            AND c.BeginValidity_DATE != d.BeginValidity_DATE
                            AND d.BackOut_INDC = @Lc_No_INDC))));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Refund - Today's Collection --
   SET @Ls_Sql_TEXT = 'TODAY_REFUNDS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (-- Included DISTINCT to avoid UNIQUE KEY CONSTRAINT ERROR
   SELECT DISTINCT
          z.Generate_DATE AS Generate_DATE,
          z.Heading_NAME AS Heading_NAME,
          z.TypeRecord_CODE AS TypeRecord_CODE,
          CASE z.Value_AMNT
          WHEN 0 THEN 0 
          ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) 
          END AS Count_QNTY,
          z.Value_AMNT,
          z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DIST-PROC-TOD-REF' AS Heading_NAME,
                   b.RecordType_CODE AS TypeRecord_CODE,
                   CASE ISNULL(SUM(a.ToDistribute_AMNT) , 0)
                   WHEN 0 THEN 0 ELSE COUNT(b.RecordType_CODE) END
                   AS Count_QNTY, 	
                   ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
                   @Lc_DummyCounty_NUMB AS County_IDNO
              FROM (SELECT ISNULL(LTRIM(RTRIM(r.Value_CODE)), '') + ISNULL(@Lc_Today_CODE, '') AS RecordType_CODE
                      FROM REFM_Y1 r
                     WHERE r.Table_ID = @Lc_TableFINS_IDNO
                       AND r.TableSub_ID = @Lc_TableSubREFT_IDNO) AS b
                   LEFT OUTER JOIN (SELECT CASE
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                  AND fci.SourceReceipt_CODE IN ('CR', 'CF'))
                                             THEN 'CPT'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                  AND fci.SourceReceipt_CODE NOT IN ('CR', 'CF'))
                                             THEN 'NCPT'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientFIPS_CODE)
                                             THEN 'FPIT'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                  AND fci.RefundRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID))
                                             THEN 'OFIT'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptOthpRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientFIPS_CODE)
                                             THEN 'FPUT'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptOthpRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                  AND fci.RefundRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID))
                                             THEN 'OFUT'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptOthpRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                  AND fci.RefundRecipient_ID NOT IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID))
                                             THEN 'OTUT'
                                            ELSE 'OTHR'
                                           END AS TypeRecord_CODE,
                                           fci.StatusReceipt_CODE,
                                           fci.RefundRecipient_CODE,
                                           fci.Batch_DATE,
                                           fci.ToDistribute_AMNT,
                                           fci.SourceBatch_CODE,
                                           fci.Batch_NUMB,
                                           fci.SeqReceipt_NUMB,
                                           fci.RefundRecipient_ID
                                      FROM (SELECT a.StatusReceipt_CODE,
                                                   a.RefundRecipient_CODE,
                                                   a.Batch_DATE,
                                                   a.SourceBatch_CODE,
                                                   a.Batch_NUMB,
                                                   a.SeqReceipt_NUMB,
                                                   a.SourceReceipt_CODE,
                                                   a.RefundRecipient_ID,
                                                   a.ToDistribute_AMNT
                                              FROM RCTH_Y1 a
                                             WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                               AND a.EndValidity_DATE > @Ad_Run_DATE
                                               AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                                     OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                                         AND EXISTS (SELECT 1 
                                                                       FROM RCTR_Y1 b
                                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
                                               AND
                                               -- Refunded / Other Party Refunded
                                               a.StatusReceipt_CODE IN (@Lc_StatusReceiptRefund_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                               AND a.RefundRecipient_CODE IN (@Lc_FundRecipientCpNcp_CODE, @Lc_FundRecipientFIPS_CODE, @Lc_CheckRecipientOthp_CODE)
                                               AND
                                               -- 1 - NCP , 2 - FIPS, 3- Other Party
                                               NOT EXISTS (SELECT 1 
                                                             FROM RCTH_Y1 b
                                                            WHERE a.Batch_DATE = b.Batch_DATE
                                                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                              AND a.Batch_NUMB = b.Batch_NUMB
                                                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                              AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                               AND NOT EXISTS (SELECT 1 
                                                                 FROM RCTH_Y1 b
                                                                WHERE a.Batch_DATE = b.Batch_DATE
                                                                  AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                  AND a.Batch_NUMB = b.Batch_NUMB
                                                                  AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                  AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                                                  AND b.EndValidity_DATE > @Ad_Run_DATE
                                                                  AND b.BackOut_INDC = @Lc_Yes_INDC)
                                               -- A Reposted RCTH_Y1 in RCTH
                                               -- B Reposted RCTH_Y1 in RCTR
                                               -- C Original Backed out RCTH_Y1 in RCTH
                                               -- D First entry of Original RCTH_Y1 in RCTH
                                               AND ((NOT EXISTS (SELECT 1 
                                                                   FROM RCTR_Y1 b
                                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                    AND b.EndValidity_DATE > @Ad_Run_DATE))
                                                     OR (EXISTS (-- Checking Repost
                                                                SELECT 1 
                                                                   FROM RCTR_Y1 b,
                                                                        RCTH_Y1 c,
                                                                        RCTH_Y1 d
                                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                                        FROM RCTH_Y1 x
                                                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                                    AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                                                    AND d.BackOut_INDC = @Lc_No_INDC)))) AS fci) AS a
                    ON a.TypeRecord_CODE = b.RecordType_CODE
                    GROUP BY b.RecordType_CODE) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Refund - Today's Collection -- Total
   SET @Ls_Sql_TEXT = 'TODAY_REFUNDS_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           r.Generate_DATE,
           r.Heading_NAME,
           'RFT' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME = 'DIST-PROC-TOD-REF');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Refund - Previous Collection --
   SET @Ls_Sql_TEXT = 'PREVIOUS_REFUNDS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
--Land
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
                   'DIST-PROC-PREV-REF' AS Heading_NAME,
                   b.RecordType_CODE AS TypeRecord_CODE,
                   CASE ISNULL(SUM(a.ToDistribute_AMNT) , 0)
                   WHEN 0 THEN 0 ELSE COUNT(b.RecordType_CODE) END
                   AS Count_QNTY, 
                   ISNULL(SUM(a.ToDistribute_AMNT) , 0) AS Value_AMNT,
                   @Lc_DummyCounty_NUMB AS County_IDNO
              FROM (SELECT ISNULL(LTRIM(RTRIM(r.Value_CODE)), '') + ISNULL(@Lc_Previous_CODE, '') AS RecordType_CODE
                      FROM REFM_Y1 r
                     WHERE r.Table_ID = @Lc_TableFINS_IDNO
                       AND r.TableSub_ID = @Lc_TableSubREFT_IDNO) AS b
                   LEFT OUTER JOIN (SELECT CASE
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                  AND fci.SourceReceipt_CODE IN ('CR', 'CF'))
                                             THEN 'CPP'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                  AND fci.SourceReceipt_CODE NOT IN ('CR', 'CF'))
                                             THEN 'NCPP'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientFIPS_CODE)
                                             THEN 'FPIP'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                  AND fci.RefundRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID))
                                             THEN 'OFIP'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptOthpRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_FundRecipientFIPS_CODE)
                                             THEN 'FPUP'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptOthpRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                  AND fci.RefundRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID))
                                             THEN 'OFUP'
                                            WHEN (fci.StatusReceipt_CODE = @Lc_StatusReceiptOthpRefund_CODE
                                                  AND fci.RefundRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                  AND fci.RefundRecipient_ID NOT IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID))
                                             THEN 'OTUP'
                                            ELSE 'OTHR'
                                           END AS TypeRecord_CODE,
                                           fci.StatusReceipt_CODE,
                                           fci.RefundRecipient_CODE,
                                           fci.Batch_DATE,
                                           fci.ToDistribute_AMNT,
                                           fci.SourceBatch_CODE,
                                           fci.Batch_NUMB,
                                           fci.SeqReceipt_NUMB,
                                           fci.RefundRecipient_ID
                                      FROM (SELECT a.StatusReceipt_CODE,
                                                   a.RefundRecipient_CODE,
                                                   a.Batch_DATE,
                                                   a.SourceBatch_CODE,
                                                   a.Batch_NUMB,
                                                   a.SeqReceipt_NUMB,
                                                   a.SourceReceipt_CODE,
                                                   a.RefundRecipient_ID,
                                                   a.ToDistribute_AMNT
                                              FROM RCTH_Y1 a
                                             WHERE 
                                             a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                               AND a.EndValidity_DATE > @Ad_Run_DATE
                                               AND (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                                     OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                                         AND EXISTS (SELECT 1 
                                                                       FROM RCTR_Y1 b
                                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
                                               AND a.StatusReceipt_CODE IN (@Lc_StatusReceiptRefund_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                               AND a.RefundRecipient_CODE IN (@Lc_FundRecipientCpNcp_CODE, @Lc_FundRecipientFIPS_CODE, @Lc_CheckRecipientOthp_CODE)
                                               AND NOT EXISTS (SELECT 1 
                                                                 FROM RCTH_Y1 b
                                                                WHERE a.Batch_DATE = b.Batch_DATE
                                                                  AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                  AND a.Batch_NUMB = b.Batch_NUMB
                                                                  AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                  AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                                                  AND b.EndValidity_DATE > @Ad_Run_DATE
                                                                  AND b.BackOut_INDC = @Lc_Yes_INDC)
                                               -- A Reposted RCTH_Y1 in RCTH 
                                               -- B Reposted RCTH_Y1 in RCTR 
                                               -- C Original Backed out RCTH_Y1 in RCTH 
                                               -- D First entry of Original RCTH_Y1 in RCTH 
                                               AND ((EXISTS (SELECT 1 
                                                               FROM RCTH_Y1 b
                                                              WHERE a.Batch_DATE = b.Batch_DATE
                                                                AND a.Batch_NUMB = b.Batch_NUMB
                                                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                                     AND NOT EXISTS (SELECT 1 
                                                                       FROM RCTR_Y1 b
                                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                        AND
                                                                        -- Check to make sure the RCTH_Y1 is not reposted again
                                                                        -- On the same day 
                                                                        b.BeginValidity_DATE >= @Ad_Start_Run_DATE
                                                                        AND b.EndValidity_DATE > @Ad_Run_DATE))
                                                     OR (EXISTS (SELECT 1 
                                                                   FROM RCTR_Y1 b,
                                                                        RCTH_Y1 c,
                                                                        RCTH_Y1 d -- Checking Repost
                                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                                        FROM RCTH_Y1 x
                                                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                                    AND c.BeginValidity_DATE != d.BeginValidity_DATE
                                                                    AND d.BackOut_INDC = @Lc_No_INDC)))) AS fci) AS a
                    ON a.TypeRecord_CODE = b.RecordType_CODE
                    GROUP BY b.RecordType_CODE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --Refund - Previous Collection -- Total
   SET @Ls_Sql_TEXT = 'PREV_REFUNDS_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           r.Generate_DATE,
           r.Heading_NAME,
           'RFP' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME = 'DIST-PROC-PREV-REF');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  OVER PAYMENT RECOVERY HERE -- RECC 
   -- ONLY ASSESMENT CONSIDERED (NOT ADVANCE) 
   -- Start  
   -- Include Pending Recoupment also    
   SET @Ls_Sql_TEXT = 'TODAY_RECOUPMENT_CREATED';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           z.Generate_DATE AS Generate_DATE,
           z.Heading_NAME,
           z.TypeRecord_CODE,
           CASE z.Value_AMNT
           WHEN 0 THEN 0
           ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.County_IDNO) 
           END AS Count_QNTY,
           z.Value_AMNT AS Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DIST-RECU-TOD' AS Heading_NAME,
                   'RECC' AS TypeRecord_CODE,
                   ISNULL(ISNULL(CAST(d.Batch_DATE AS VARCHAR), '') + ISNULL(d.SourceBatch_CODE, '') + ISNULL(CAST(d.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(d.SeqReceipt_NUMB AS VARCHAR), ''), 0) AS Count_QNTY,
                   ISNULL(SUM(CAST(d.AssessOverpay_AMNT AS FLOAT) + CAST(d.PendOffset_AMNT AS FLOAT)) OVER(PARTITION BY c.County_IDNO), 0) AS Value_AMNT,
                   c.County_IDNO AS County_IDNO
              FROM COPT_Y1 c
                   LEFT OUTER JOIN (SELECT a.Batch_DATE,
                                           a.SourceBatch_CODE,
                                           a.Batch_NUMB,
                                           a.SeqReceipt_NUMB,
                                           ISNULL(a.AssessOverpay_AMNT, 0) AS AssessOverpay_AMNT,
                                           b.County_IDNO,
                                           ISNULL(a.PendOffset_AMNT, 0) AS PendOffset_AMNT
                                      FROM POFL_Y1 a,
                                           CASE_Y1 b
                                     WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND (a.AssessOverpay_AMNT + a.PendOffset_AMNT > 0)
                                       AND a.Case_IDNO = b.Case_IDNO) AS d
                    ON d.County_IDNO = c.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  OVER PAYMENT RECOVERY HERE -- RECC --STATEWISE
   -- ONLY ASSESMENT CONSIDERED (NOT ADVANCE)
   SET @Ls_Sql_TEXT = 'TODAY_RECOUPMENT_CREATED-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-RECU-TOD' AS Heading_NAME,
           'RECC' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(a.AssessOverpay_AMNT), 0) + ISNULL(SUM(a.PendOffset_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM POFL_Y1 a
     WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
       AND (a.AssessOverpay_AMNT + a.PendOffset_AMNT > 0));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- End
   -- BOTH ADVANCE AND OVERPAYMENT  ARE CONSIDERED
   SET @Ls_Sql_TEXT = 'TODAY_RECOUPMENT';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           z.Generate_DATE AS Generate_DATE,
           z.Heading_NAME,
           z.TypeRecord_CODE,
           CASE z.Value_AMNT
           WHEN 0 THEN 0 
           ELSE COUNT(z.COUNT) OVER(PARTITION BY z.County_IDNO) 
           END AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DIST-RECU-TOD' AS Heading_NAME,
                   'REC' AS TypeRecord_CODE,
                   ISNULL(ISNULL(CAST(f.Batch_DATE AS VARCHAR), '') + ISNULL(f.SourceBatch_CODE, '') + ISNULL(CAST(f.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(f.SeqReceipt_NUMB AS VARCHAR), ''), 0) AS COUNT,
                   ISNULL(SUM(CAST(f.Value_AMNT AS FLOAT)) OVER(PARTITION BY g.County_IDNO), 0) AS Value_AMNT,
                   g.County_IDNO AS County_IDNO
              FROM COPT_Y1 g
                   LEFT OUTER JOIN (SELECT a.Batch_DATE,
                                           a.SourceBatch_CODE,
                                           a.Batch_NUMB,
                                           a.SeqReceipt_NUMB,
                                           (a.RecOverpay_AMNT + a.RecAdvance_AMNT) AS Value_AMNT,
                                           e.County_IDNO
                                      FROM POFL_Y1 a,
                                           CASE_Y1 e
                                     WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Case_IDNO = e.Case_IDNO
                                       AND
                                       -- VOID-REPLACED RECOUPED RCTH_Y1(CHWP) should not acCOUNT in Recovered Towards Recoupment (RECT/RECP) line fix
                                       a.Transaction_CODE <> @Lc_TransactionCHWP_CODE
                                       AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > 0)
                                       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                                 AND EXISTS (SELECT 1 
                                                               FROM RCTR_Y1 b
                                                              WHERE a.Batch_DATE = b.Batch_DATE
                                                                AND a.Batch_NUMB = b.Batch_NUMB
                                                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
                                       AND NOT EXISTS (SELECT 1 
                                                         FROM RCTH_Y1 b
                                                        WHERE a.Batch_DATE = b.Batch_DATE
                                                          AND a.Batch_NUMB = b.Batch_NUMB
                                                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                          AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                       AND ((NOT EXISTS (SELECT 1 
                                                           FROM RCTR_Y1 b
                                                          WHERE a.Batch_DATE = b.Batch_DATE
                                                            AND a.Batch_NUMB = b.Batch_NUMB
                                                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                            AND b.EndValidity_DATE > @Ad_Run_DATE))
                                             OR (EXISTS (-- Checking Repost
                                                        SELECT 1 
                                                           FROM RCTR_Y1 b,
                                                                RCTH_Y1 c,
                                                                RCTH_Y1 d
                                                          WHERE a.Batch_DATE = b.Batch_DATE
                                                            AND a.Batch_NUMB = b.Batch_NUMB
                                                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                            AND b.EndValidity_DATE > @Ad_Run_DATE
                                                            AND b.BatchOrig_DATE = c.Batch_DATE
                                                            AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                            AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                            AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                            AND c.EndValidity_DATE > @Ad_Run_DATE
                                                            AND c.BackOut_INDC = @Lc_Yes_INDC
                                                            AND b.BatchOrig_DATE = d.Batch_DATE
                                                            AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                            AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                            AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                            AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                                FROM RCTH_Y1 x
                                                                                               WHERE d.Batch_DATE = x.Batch_DATE
                                                                                                 AND d.Batch_NUMB = x.Batch_NUMB
                                                                                                 AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                                 AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                            AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                                            AND d.BackOut_INDC = @Lc_No_INDC)))) AS f
                    ON f.County_IDNO = g.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- BOTH ADVANCE AND OVERPAYMENT  ARE CONSIDERED
   SET @Ls_Sql_TEXT = 'TODAY_RECOUPMENT-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-RECU-TOD' AS Heading_NAME,
           'REC' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT(ISNULL(CAST(fci.Batch_DATE AS VARCHAR), '') + ISNULL(fci.SourceBatch_CODE, '') + ISNULL(CAST(fci.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(fci.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Batch_DATE AS Batch_DATE,
                   a.SourceBatch_CODE AS SourceBatch_CODE,
                   a.Batch_NUMB AS Batch_NUMB,
                   a.SeqReceipt_NUMB AS SeqReceipt_NUMB,
                   (a.RecOverpay_AMNT + a.RecAdvance_AMNT) AS Value_AMNT
              FROM POFL_Y1 a
             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND
               -- VOID-REPLACED RECOUPED RCTH_Y1(CHWP) should not acCOUNT in Recovered Towards Recoupment (RECT/RECP) line fix
               a.Transaction_CODE <> @Lc_TransactionCHWP_CODE
               AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > 0)
               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                         AND EXISTS (SELECT 1 
                                       FROM RCTR_Y1 b
                                      WHERE a.Batch_DATE = b.Batch_DATE
                                        AND a.Batch_NUMB = b.Batch_NUMB
                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
               AND NOT EXISTS (SELECT 1 
                                 FROM RCTH_Y1 b
                                WHERE a.Batch_DATE = b.Batch_DATE
                                  AND a.Batch_NUMB = b.Batch_NUMB
                                  AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                  AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                  AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
               AND ((NOT EXISTS (SELECT 1 
                                   FROM RCTR_Y1 b
                                  WHERE a.Batch_DATE = b.Batch_DATE
                                    AND a.Batch_NUMB = b.Batch_NUMB
                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                    AND b.EndValidity_DATE > @Ad_Run_DATE))
                     OR (EXISTS (-- Checking Repost
                                SELECT 1 
                                   FROM RCTR_Y1 b,
                                        RCTH_Y1 c,
                                        RCTH_Y1 d
                                  WHERE a.Batch_DATE = b.Batch_DATE
                                    AND a.Batch_NUMB = b.Batch_NUMB
                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                        FROM RCTH_Y1 x
                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                    AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                    AND d.BackOut_INDC = @Lc_No_INDC)))) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'TODAY_DEFICIT_REDUCTION_ACT_FEE,SPECIAL_COLLECTION_FEE,CP_NSF_FEE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
	INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-RECOUP' AS Heading_NAME,
           b.TypeRecord_CODE,
           ISNULL(a.Count_QNTY,0) AS Count_QNTY,
           ISNULL(a.Value_AMNT,0.00) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT @Lc_CheckRecipientDra_ID AS CheckRecipient_ID,'DRF' AS TypeRecord_CODE UNION
			SELECT @Lc_CheckRecipientSpc_ID AS CheckRecipient_ID,'SCF' AS TypeRecord_CODE UNION
			SELECT @Lc_CheckRecipientCpNsf_ID AS CheckRecipient_ID,'NSF' AS TypeRecord_CODE UNION
			SELECT @Lc_CheckRecipientNcpNsf_ID AS CheckRecipient_ID,'NCF' AS TypeRecord_CODE UNION
			SELECT @Lc_CheckRecipientGt_ID AS CheckRecipient_ID,'GTF' AS TypeRecord_CODE 
			) AS b
	LEFT OUTER JOIN (SELECT SUM(a.Disburse_AMNT) AS Value_AMNT,
							COUNT(DISTINCT ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
							   a.CheckRecipient_ID AS CheckRecipient_ID
						  FROM DSBL_Y1 a,
							   DSBH_Y1 b
						 WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
						   AND a.Batch_DATE != @Ld_Low_DATE
						   AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
						   AND b.EndValidity_DATE > @Ad_Run_DATE
						   --  To exclude Demand Checks
						   AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
						   AND a.CheckRecipient_CODE = 3
						   AND a.CheckRecipient_ID IN (@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
						   AND a.CheckRecipient_ID = b.CheckRecipient_ID
						   AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
						   AND a.Disburse_DATE = b.Disburse_DATE
						   AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
						   -- Excluding OSR Amount 
						   AND a.CheckRecipient_ID <> @Lc_CheckRecipientOSR_ID 
						   GROUP BY a.CheckRecipient_ID ) AS a
           ON a.CheckRecipient_ID = b.CheckRecipient_ID;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'SUMRY-RECOUP - FEE SUB TOTAL ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          a.Generate_DATE,
          a.Heading_NAME,
          'FER' AS TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Heading_NAME), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME = 'SUMRY-RECOUP'
      AND a.TypeRecord_CODE IN ('DRF', 'SCF', 'NSF','NCF', 'GTF');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --OVER PAYMENT RECOVERY PREVIOUS HERE -- RECP  --confirm
   -- BOTH ADVANCE AND OVERPAYMENT  ARE CONSIDERED
   SET @Ls_Sql_TEXT = 'PREVIOUS_RECOUPMENT';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           z.Generate_DATE AS Generate_DATE,
           z.Heading_NAME AS Heading_NAME,
           z.TypeRecord_CODE,
           CASE z.Value_AMNT
           WHEN 0 THEN 0
           ELSE COUNT(z.COUNT) OVER(PARTITION BY z.County_IDNO) 
           END AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DIST-RECU-PREV' AS Heading_NAME,
                   'RECP' AS TypeRecord_CODE,
                   ISNULL(ISNULL(CAST(d.Batch_DATE AS VARCHAR), '') + ISNULL(d.SourceBatch_CODE, '') + ISNULL(CAST(d.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(d.SeqReceipt_NUMB AS VARCHAR), ''), 0) AS COUNT,
                   ISNULL(SUM(CAST(d.Value_AMNT AS FLOAT)) OVER(PARTITION BY e.County_IDNO), 0) AS Value_AMNT,
                   e.County_IDNO AS County_IDNO
              FROM COPT_Y1 e
                   LEFT OUTER JOIN (SELECT a.Batch_DATE,
                                           a.SourceBatch_CODE,
                                           a.Batch_NUMB,
                                           a.SeqReceipt_NUMB,
                                           (a.RecOverpay_AMNT + a.RecAdvance_AMNT) AS Value_AMNT,
                                           c.County_IDNO
                                      FROM POFL_Y1 a,
                                           CASE_Y1 c
                                     WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Case_IDNO = c.Case_IDNO
                                       AND
                                       -- VOID-REPLACED RECOUPED RCTH_Y1(CHWP) should not account in Recovered Towards Recoupment (RECT/RECP) line fix
                                       a.Transaction_CODE <> @Lc_TransactionCHWP_CODE
                                       AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > 0)
                                       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                                 AND EXISTS (SELECT 1 
                                                               FROM RCTR_Y1 b
                                                              WHERE a.Batch_DATE = b.Batch_DATE
                                                                AND a.Batch_NUMB = b.Batch_NUMB
                                                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                AND b.EndValidity_DATE > @Ad_Run_DATE)))
                                       -- A Reposted RCTH_Y1 in RCTH 
                                       -- B Reposted RCTH_Y1 in RCTR 
                                       -- C Original Backed out RCTH_Y1 in RCTH 
                                       -- D First entry of Original RCTH_Y1 in RCTH 
                                       AND ((EXISTS (SELECT 1 
                                                       FROM RCTH_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.BeginValidity_DATE < @Ad_Start_Run_DATE))
                                             OR (EXISTS (SELECT 1 
                                                           FROM RCTR_Y1 b,
                                                                RCTH_Y1 c,
                                                                RCTH_Y1 d -- Checking Repost
                                                          WHERE a.Batch_DATE = b.Batch_DATE
                                                            AND a.Batch_NUMB = b.Batch_NUMB
                                                            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                            AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                            AND b.EndValidity_DATE > @Ad_Run_DATE
                                                            AND b.BatchOrig_DATE = c.Batch_DATE
                                                            AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                            AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                            AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                            AND c.EndValidity_DATE > @Ad_Run_DATE
                                                            AND c.BackOut_INDC = 'Y'
                                                            AND b.BatchOrig_DATE = d.Batch_DATE
                                                            AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                            AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                            AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                            AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                                FROM RCTH_Y1 x
                                                                                               WHERE d.Batch_DATE = x.Batch_DATE
                                                                                                 AND d.Batch_NUMB = x.Batch_NUMB
                                                                                                 AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                                 AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                            AND c.BeginValidity_DATE != d.BeginValidity_DATE
                                                            AND d.BackOut_INDC = 'N')))) AS d
                    ON d.County_IDNO = e.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --OVER PAYMENT RECOVERY PREVIOUS HERE -- RECP--STATEWISE
   -- BOTH ADVANCE AND OVERPAYMENT  ARE CONSIDERED
   SET @Ls_Sql_TEXT = 'PREVIOUS_RECOUPMENT-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-RECU-PREV' AS Heading_NAME,
           'RECP' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT(ISNULL(CAST(fci.Batch_DATE AS VARCHAR), '') + ISNULL(fci.SourceBatch_CODE, '') + ISNULL(CAST(fci.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(fci.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   (a.RecOverpay_AMNT + a.RecAdvance_AMNT) AS Value_AMNT
              FROM POFL_Y1 a
             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND
               -- VOID-REPLACED RECOUPED RCTH_Y1(CHWP) should not acCOUNT in Recovered Towards Recoupment (RECT/RECP) line fix
               a.Transaction_CODE <> @Lc_TransactionCHWP_CODE
               AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > 0)
               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                         AND EXISTS (SELECT 1 
                                       FROM RCTR_Y1 b
                                      WHERE a.Batch_DATE = b.Batch_DATE
                                        AND a.Batch_NUMB = b.Batch_NUMB
                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
               -- A Reposted RCTH_Y1 in RCTH 
               -- B Reposted RCTH_Y1 in RCTR 
               -- C Original Backed out RCTH_Y1 in RCTH 
               -- D First entry of Original RCTH_Y1 in RCTH 
               AND ((EXISTS (SELECT 1 
                               FROM RCTH_Y1 b
                              WHERE a.Batch_DATE = b.Batch_DATE
                                AND a.Batch_NUMB = b.Batch_NUMB
                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                AND b.BeginValidity_DATE < @Ad_Start_Run_DATE))
                     OR (EXISTS (SELECT 1 
                                   FROM RCTR_Y1 b,
                                        RCTH_Y1 c,
                                        RCTH_Y1 d -- Checking Repost
                                  WHERE a.Batch_DATE = b.Batch_DATE
                                    AND a.Batch_NUMB = b.Batch_NUMB
                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                    AND c.BackOut_INDC = 'Y'
                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                        FROM RCTH_Y1 x
                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                    AND c.BeginValidity_DATE != d.BeginValidity_DATE
                                    AND d.BackOut_INDC = 'N')))) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -------------------------------------------------------------------------------
   -- Start 
   -- use UCAT_Y1 table to get the TypeHold_CODE
   -- DISTRIBUTION RELEASED FROM DISBURSEMENT HOLD - TODAY -- COUNTywise
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_TODAY_COLL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-DISB-TOD' AS Heading_NAME,
           b.RecordType_CODE,
           ISNULL(COUNT(a.Transaction_AMNT) OVER(PARTITION BY b.RecordType_CODE, b.County_IDNO), 0) AS Count_QNTY,
           ISNULL(SUM(a.Transaction_AMNT) OVER(PARTITION BY b.RecordType_CODE, b.County_IDNO), 0) AS Value_AMNT,
           b.County_IDNO AS County_IDNO
      FROM (SELECT ISNULL(LTRIM(RTRIM(r.Value_CODE)), '') + ISNULL(@Lc_Today_CODE, '') AS RecordType_CODE,
                   c.County_IDNO
              FROM REFM_Y1 r,
                   COPT_Y1 c
             WHERE r.Table_ID = @Lc_TableFINS_IDNO
               AND r.TableSub_ID = @Lc_TableSubDHLH_IDNO) AS b
           LEFT OUTER JOIN (SELECT CASE
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldAddress_CODE)
                                     THEN 'ADHT'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCP_CODE)
                                     THEN 'CPHT'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldIVE_CODE, @Lc_TypeHoldTanfT_CODE)
                                     THEN 'IVHT'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCheck_CODE)
                                     THEN 'MSLT'
                                    ELSE 'OTHT'
                                   END AS TypeRecord_CODE,
                                   a.Transaction_AMNT,
                                   x.County_IDNO AS County_IDNO,
                                   a.Case_IDNO,
                                   a.CheckRecipient_ID
                              FROM DHLD_Y1 a,
                                   CASE_Y1 x,
                                   UCAT_Y1 u
                             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                               AND a.Transaction_AMNT > 0
                               AND a.EndValidity_DATE > @Ad_Run_DATE
                               AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
                               AND a.Case_IDNO = x.Case_IDNO
                               AND a.ReasonStatus_CODE = u.Udc_CODE
                               AND u.EndValidity_DATE = @Ld_High_DATE
                               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                         AND EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
                               -- A Reposted RCTH_Y1 in RCTH 
                               -- B Reposted RCTH_Y1 in RCTR 
                               -- C Original Backed out RCTH_Y1 in RCTH 
                               -- D First entry of Original RCTH_Y1 in RCTH 
                               AND ((NOT EXISTS (SELECT 1 
                                                   FROM RCTH_Y1 b
                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                     AND NOT EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE))
                                     OR (EXISTS (SELECT 1 
                                                   FROM RCTR_Y1 b,
                                                        RCTH_Y1 c,
                                                        RCTH_Y1 d -- Checking Repost
                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                        FROM RCTH_Y1 x
                                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                    AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                                    AND d.BackOut_INDC = @Lc_No_INDC)))
                               AND
                               -- Do not include the RCTH_Y1 if this is Void No Reissue / Stop No Reissue 
                               NOT EXISTS (SELECT 1 
                                             FROM DSBH_Y1 x
                                            WHERE a.Disburse_DATE = x.Disburse_DATE
                                              AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                              AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                              AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                              AND x.StatusCheck_CODE IN ('RE', 'VN', 'SN')
                                              AND x.BeginValidity_DATE = a.Transaction_DATE
                                              AND a.EventGlobalBeginSeq_NUMB = x.EventGlobalBeginSeq_NUMB
                                              AND x.EndValidity_DATE > @Ad_Run_DATE)
                               AND EXISTS (-- Consider the RCTH_Y1 only if it is distributed on that day 
                                          SELECT 1 
                                             FROM RCTH_Y1 b
                                            WHERE a.Batch_DATE = b.Batch_DATE
                                              AND a.Batch_NUMB = b.Batch_NUMB
                                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                              AND b.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                              AND b.EndValidity_DATE > @Ad_Run_DATE)
                               AND
                               -- Including REFUND condition also
                               (a.TypeDisburse_CODE IN ('REFND', 'ROTHP')
                                 OR EXISTS (SELECT 1 
                                              FROM LSUP_Y1 b
                                             WHERE a.Case_IDNO = b.Case_IDNO
                                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                               AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                               AND a.Batch_DATE = b.Batch_DATE
                                               AND a.Batch_NUMB = b.Batch_NUMB
                                               AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                               AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                               AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB
                                               AND a.Transaction_DATE = b.Distribute_DATE))) AS a
            ON a.TypeRecord_CODE = b.RecordType_CODE
               AND a.County_IDNO = b.County_IDNO);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- DISTRIBUTION RELEASED FROM DISBURSEMENT HOLD - PREVIOUS -- COUNTywise
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_PREVIOUS_COLL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-DISB-PREV' AS Heading_NAME,
           b.RecordType_CODE,
           ISNULL(COUNT(a.Transaction_AMNT) OVER(PARTITION BY a.TypeRecord_CODE, a.County_IDNO), 0) AS Count_QNTY,
           ISNULL(SUM(a.Transaction_AMNT) OVER(PARTITION BY a.TypeRecord_CODE, a.County_IDNO), 0) AS Value_AMNT,
           b.County_IDNO AS County_IDNO
      FROM (SELECT ISNULL(LTRIM(RTRIM(r.Value_CODE)), '') + ISNULL(@Lc_Previous_CODE, '') AS RecordType_CODE,
                   c.County_IDNO
              FROM REFM_Y1 r,
                   COPT_Y1 c
             WHERE r.Table_ID = @Lc_TableFINS_IDNO
               AND r.TableSub_ID = @Lc_TableSubDHLH_IDNO) AS b
           LEFT OUTER JOIN (SELECT CASE
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldAddress_CODE)
                                     THEN 'ADHP'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCP_CODE)
                                     THEN 'CPHP'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldIVE_CODE, @Lc_TypeHoldTanfT_CODE)
                                     THEN 'IVHP'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCheck_CODE)
                                     THEN 'MSLP'
                                    ELSE 'OTHP'
                                   END AS TypeRecord_CODE,
                                   a.Transaction_AMNT,
                                   x.County_IDNO AS County_IDNO,
                                   a.Case_IDNO,
                                   a.CheckRecipient_ID
                              FROM DHLD_Y1 a,
                                   CASE_Y1 x,
                                   UCAT_Y1 u
                             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                               AND a.Transaction_AMNT > 0
                               AND a.EndValidity_DATE > @Ad_Run_DATE
                               AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
                               AND a.Case_IDNO = x.Case_IDNO
                               AND a.ReasonStatus_CODE = u.Udc_CODE
                               AND u.EndValidity_DATE = @Ld_High_DATE
                               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                         AND EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
                               -- A Reposted RCTH_Y1 in RCTH 
                               -- B Reposted RCTH_Y1 in RCTR 
                               -- C Original Backed out RCTH_Y1 in RCTH 
                               -- D First entry of Original RCTH_Y1 in RCTH 
                               AND ((EXISTS (SELECT 1 
                                               FROM RCTH_Y1 b
                                              WHERE a.Batch_DATE = b.Batch_DATE
                                                AND a.Batch_NUMB = b.Batch_NUMB
                                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                     AND NOT EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE))
                                     OR (EXISTS (SELECT 1 
                                                   FROM RCTR_Y1 b,
                                                        RCTH_Y1 c,
                                                        RCTH_Y1 d -- Checking Repost
                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                        FROM RCTH_Y1 x
                                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                    AND c.BeginValidity_DATE != d.BeginValidity_DATE
                                                    AND d.BackOut_INDC = @Lc_No_INDC)))
                               -- Do not include the RCTH_Y1 if this is Void No Reissue / Stop No Reissue 
                               AND NOT EXISTS (SELECT 1 
                                                 FROM DSBH_Y1 x
                                                WHERE a.Disburse_DATE = x.Disburse_DATE
                                                  AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                  AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                                  AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                  AND x.StatusCheck_CODE IN ('RE', 'VN', 'SN')
                                                  AND x.BeginValidity_DATE = a.Transaction_DATE
                                                  AND a.EventGlobalBeginSeq_NUMB = x.EventGlobalBeginSeq_NUMB
                                                  AND x.EndValidity_DATE > @Ad_Run_DATE)
                               -- Consider the RCTH_Y1 only if it is distributed on that day 
                               AND EXISTS (SELECT 1 
                                             FROM RCTH_Y1 b
                                            WHERE a.Batch_DATE = b.Batch_DATE
                                              AND a.Batch_NUMB = b.Batch_NUMB
                                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                              AND b.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                              AND b.EndValidity_DATE > @Ad_Run_DATE)
                               AND
                               --Including REFUND condition also 
                               (a.TypeDisburse_CODE IN ('REFND', 'ROTHP')
                                 OR EXISTS (SELECT 1 
                                              FROM LSUP_Y1 b
                                             WHERE a.Case_IDNO = b.Case_IDNO
                                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                               AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                               AND a.Batch_DATE = b.Batch_DATE
                                               AND a.Batch_NUMB = b.Batch_NUMB
                                               AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                               AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                               AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB
                                               AND a.Transaction_DATE = b.Distribute_DATE))) AS a
            ON a.TypeRecord_CODE = b.RecordType_CODE
               AND a.County_IDNO = b.County_IDNO);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -------------------------------------------------------------------------------
   -- DISTRIBUTION RELEASED FROM DISBURSEMENT HOLD - TODAY -- Statewise
   -------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_TODAY_COLL-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-DISB-TOD' AS Heading_NAME,
           b.RecordType_CODE,
           ISNULL(COUNT(a.Transaction_AMNT) OVER(PARTITION BY b.RecordType_CODE), 0) AS Count_QNTY,
           ISNULL(SUM(a.Transaction_AMNT) OVER(PARTITION BY b.RecordType_CODE), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT ISNULL(LTRIM(RTRIM(r.Value_CODE)), '') + ISNULL(@Lc_Today_CODE, '') AS RecordType_CODE
              FROM REFM_Y1 r
             WHERE r.Table_ID = @Lc_TableFINS_IDNO
               AND r.TableSub_ID = @Lc_TableSubDHLH_IDNO) AS b
           LEFT OUTER JOIN (SELECT CASE
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldAddress_CODE)
                                     THEN 'ADHT'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCP_CODE)
                                     THEN 'CPHT'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldIVE_CODE, @Lc_TypeHoldTanfT_CODE)
                                     THEN 'IVHT'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCheck_CODE)
                                     THEN 'MSLT'
                                    ELSE 'OTHT'
                                   END AS TypeRecord_CODE,
                                   a.Transaction_AMNT,
                                   a.Case_IDNO,
                                   a.CheckRecipient_ID
                              FROM DHLD_Y1 a,
                                   UCAT_Y1 u
                             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                               AND a.Transaction_AMNT > 0
                               AND a.EndValidity_DATE > @Ad_Run_DATE
                               AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
                               AND a.ReasonStatus_CODE = u.Udc_CODE
                               AND u.EndValidity_DATE = @Ld_High_DATE
                               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                         AND EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
                               -- A Reposted RCTH_Y1 in RCTH 
                               -- B Reposted RCTH_Y1 in RCTR 
                               -- C Original Backed out RCTH_Y1 in RCTH 
                               -- D First entry of Original RCTH_Y1 in RCTH 
                               AND ((NOT EXISTS (SELECT 1 
                                                   FROM RCTH_Y1 b
                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                     AND NOT EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE))
                                     OR (EXISTS (SELECT 1 
                                                   FROM RCTR_Y1 b,
                                                        RCTH_Y1 c,
                                                        RCTH_Y1 d -- Checking Repost
                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                        FROM RCTH_Y1 x
                                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                    AND c.BeginValidity_DATE = d.BeginValidity_DATE
                                                    AND d.BackOut_INDC = @Lc_No_INDC)))
                               AND
                               -- Do not include the RCTH_Y1 if this is Void No Reissue / Stop No Reissue 
                               NOT EXISTS (SELECT 1 
                                             FROM DSBH_Y1 x
                                            WHERE a.Disburse_DATE = x.Disburse_DATE
                                              AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                              AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                              AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                              AND x.StatusCheck_CODE IN ('RE', 'VN', 'SN')
                                              AND x.BeginValidity_DATE = a.Transaction_DATE
                                              AND a.EventGlobalBeginSeq_NUMB = x.EventGlobalBeginSeq_NUMB
                                              AND x.EndValidity_DATE > @Ad_Run_DATE)
                               AND
                               -- Consider the RCTH_Y1 only if it is distributed on that day 
                               EXISTS (SELECT 1 
                                         FROM RCTH_Y1 b
                                        WHERE a.Batch_DATE = b.Batch_DATE
                                          AND a.Batch_NUMB = b.Batch_NUMB
                                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                          AND b.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                          AND b.EndValidity_DATE > @Ad_Run_DATE)
                               AND (a.TypeDisburse_CODE IN ('REFND', 'ROTHP')
                                     OR EXISTS (SELECT 1 
                                                  FROM LSUP_Y1 b
                                                 WHERE a.Case_IDNO = b.Case_IDNO
                                                   AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                   AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                   AND a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB
                                                   AND a.Transaction_DATE = b.Distribute_DATE))) AS a
            ON a.TypeRecord_CODE = b.RecordType_CODE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- DISTRIBUTION RELEASED FROM DISBURSEMENT HOLD - PREVIOUS -- Statewise
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_PREVIOUS_COLL-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'DIST-DISB-PREV' AS Heading_NAME,
           b.RecordType_CODE,
           ISNULL(COUNT(a.Transaction_AMNT) OVER(PARTITION BY a.TypeRecord_CODE), 0) AS Count_QNTY,
           ISNULL(SUM(a.Transaction_AMNT) OVER(PARTITION BY a.TypeRecord_CODE), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT ISNULL(LTRIM(RTRIM(r.Value_CODE)), '') + ISNULL(@Lc_Previous_CODE, '') AS RecordType_CODE
              FROM REFM_Y1 r
             WHERE r.Table_ID = @Lc_TableFINS_IDNO
               AND r.TableSub_ID = @Lc_TableSubDHLH_IDNO) AS b
           LEFT OUTER JOIN (SELECT CASE
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldAddress_CODE)
                                     THEN 'ADHP'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCP_CODE)
                                     THEN 'CPHP'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldIVE_CODE, @Lc_TypeHoldTanfT_CODE)
                                     THEN 'IVHP'
                                    WHEN u.TypeHold_CODE IN (@Lc_TypeHoldCheck_CODE)
                                     THEN 'MSLP'
                                    ELSE 'OTHP'
                                   END AS TypeRecord_CODE,
                                   a.Transaction_AMNT,
                                   a.Case_IDNO,
                                   a.CheckRecipient_ID
                              FROM DHLD_Y1 a,
                                   UCAT_Y1 u
                             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                               AND a.Transaction_AMNT > 0
                               AND a.EndValidity_DATE > @Ad_Run_DATE
                               AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
                               AND a.ReasonStatus_CODE = u.Udc_CODE
                               AND u.EndValidity_DATE = @Ld_High_DATE
                               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                         AND EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE)))
                               -- A Reposted RCTH_Y1 in RCTH 
                               -- B Reposted RCTH_Y1 in RCTR 
                               -- C Original Backed out RCTH_Y1 in RCTH 
                               -- D First entry of Original RCTH_Y1 in RCTH 
                               AND ((EXISTS (SELECT 1 
                                               FROM RCTH_Y1 b
                                              WHERE a.Batch_DATE = b.Batch_DATE
                                                AND a.Batch_NUMB = b.Batch_NUMB
                                                AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                     AND NOT EXISTS (SELECT 1 
                                                       FROM RCTR_Y1 b
                                                      WHERE a.Batch_DATE = b.Batch_DATE
                                                        AND a.Batch_NUMB = b.Batch_NUMB
                                                        AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                        AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                        AND b.EndValidity_DATE > @Ad_Run_DATE))
                                     OR (EXISTS (SELECT 1 
                                                   FROM RCTR_Y1 b,
                                                        RCTH_Y1 c,
                                                        RCTH_Y1 d -- Checking Repost
                                                  WHERE a.Batch_DATE = b.Batch_DATE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                    AND b.BatchOrig_DATE = c.Batch_DATE
                                                    AND b.BatchOrig_NUMB = c.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = c.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = c.SourceBatch_CODE
                                                    AND c.EndValidity_DATE > @Ad_Run_DATE
                                                    AND c.BackOut_INDC = @Lc_Yes_INDC
                                                    AND b.BatchOrig_DATE = d.Batch_DATE
                                                    AND b.BatchOrig_NUMB = d.Batch_NUMB
                                                    AND b.SeqReceiptOrig_NUMB = d.SeqReceipt_NUMB
                                                    AND b.SourceBatchOrig_CODE = d.SourceBatch_CODE
                                                    AND d.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                        FROM RCTH_Y1 x
                                                                                       WHERE d.Batch_DATE = x.Batch_DATE
                                                                                         AND d.Batch_NUMB = x.Batch_NUMB
                                                                                         AND d.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                         AND d.SourceBatch_CODE = x.SourceBatch_CODE)
                                                    AND c.BeginValidity_DATE != d.BeginValidity_DATE
                                                    AND d.BackOut_INDC = @Lc_No_INDC)))
                               AND
                               -- Do not include the RCTH_Y1 if this is Void No Reissue / Stop No Reissue 
                               NOT EXISTS (SELECT 1 
                                             FROM DSBH_Y1 x
                                            WHERE a.Disburse_DATE = x.Disburse_DATE
                                              AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                              AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                              AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                              AND x.StatusCheck_CODE IN ('RE', 'VN', 'SN')
                                              AND x.BeginValidity_DATE = a.Transaction_DATE
                                              AND a.EventGlobalBeginSeq_NUMB = x.EventGlobalBeginSeq_NUMB
                                              AND x.EndValidity_DATE > @Ad_Run_DATE)
                               AND EXISTS (-- Consider the RCTH_Y1 only if it is distributed on that day 
                                          SELECT 1 
                                             FROM RCTH_Y1 b
                                            WHERE a.Batch_DATE = b.Batch_DATE
                                              AND a.Batch_NUMB = b.Batch_NUMB
                                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                              AND b.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                              AND b.EndValidity_DATE > @Ad_Run_DATE)
                               AND (a.TypeDisburse_CODE IN ('REFND', 'ROTHP')
                                     OR EXISTS (SELECT 1 
                                                  FROM LSUP_Y1 b
                                                 WHERE a.Case_IDNO = b.Case_IDNO
                                                   AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                   AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                   AND a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB
                                                   AND a.Transaction_DATE = b.Distribute_DATE))) AS a
            ON a.TypeRecord_CODE = b.RecordType_CODE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- DISTRIBUTION RELEASED FROM DISBURSEMENT HOLD - TOTAL
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_TODAY_COLL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           f.Generate_DATE,
           f.Heading_NAME,
           'DHT' AS TypeRecord_CODE,
           SUM(f.Count_QNTY) OVER(PARTITION BY f.County_IDNO) AS Count_QNTY,
           SUM(f.Value_AMNT) OVER(PARTITION BY f.County_IDNO) AS Value_AMNT,
           f.County_IDNO
      FROM RFINS_Y1  f
     WHERE f.Generate_DATE = @Ad_Run_DATE
       AND f.County_IDNO != @Lc_DummyCounty_NUMB
       AND f.Heading_NAME LIKE 'DIST-DISB-TOD');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- DISTRIBUTION RELEASED FROM DISBURSEMENT HOLD - TOTAL
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_PREVIOUS_COLL_TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           f.Generate_DATE,
           f.Heading_NAME,
           'DHP' AS TypeRecord_CODE,
           SUM(f.Count_QNTY) OVER(PARTITION BY f.County_IDNO) AS Count_QNTY,
           SUM(f.Value_AMNT) OVER(PARTITION BY f.County_IDNO) AS Value_AMNT,
           f.County_IDNO
      FROM RFINS_Y1  f
     WHERE f.Generate_DATE = @Ad_Run_DATE
       AND f.County_IDNO != @Lc_DummyCounty_NUMB
       AND f.Heading_NAME LIKE 'DIST-DISB-PREV');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_TODAY_COLL_TOTAL-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL('DHT','');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           r.Generate_DATE,
           r.Heading_NAME,
           'DHT' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.County_IDNO = @Lc_DummyCounty_NUMB
       AND r.Heading_NAME LIKE 'DIST-DISB-TOD');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Placed on Disbursement Hold
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_PREVIOUS_COLL_TOTAL-STATEWISE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL('DHP','');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           r.Generate_DATE,
           r.Heading_NAME,
           'DHP' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.County_IDNO = @Lc_DummyCounty_NUMB
       AND r.Heading_NAME LIKE 'DIST-DISB-PREV');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_FROM_TODAY_COLL_DBH';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          @Ad_Run_DATE AS Generate_DATE,
          'DIST-DISB' AS Heading_NAME,
          'DBH' AS TypeRecord_CODE,
          SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
          SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
          r.County_IDNO
     FROM RFINS_Y1 r
    WHERE r.Generate_DATE = @Ad_Run_DATE
      AND r.Heading_NAME LIKE 'DIST-DISB%'
      AND r.TypeRecord_CODE IN ('DHT', 'DHP');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END
    
SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
END TRY
  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   -- Check for Exception information to log the description text based on the error		
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
