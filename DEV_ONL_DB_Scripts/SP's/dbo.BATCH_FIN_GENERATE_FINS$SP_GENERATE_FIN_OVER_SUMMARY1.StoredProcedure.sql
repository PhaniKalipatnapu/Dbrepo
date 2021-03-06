/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY1   
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
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY1] (
		@Ad_Run_DATE				   DATE,
		@Ad_Start_Run_DATE			   DATE,
		@Ad_LastRun_DATE			   DATE,
		@Ad_PlusOne_Run_DATE		   DATE,	
		@Ac_Msg_CODE                   CHAR(1) OUTPUT,
		@As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE
	  @Lc_StatusReceiptUnidentified_CODE     CHAR (1) = 'U',
	  @Lc_StatusReceiptHeld_CODE             CHAR (1) = 'H',
	  @Lc_StatusReceiptIdentified_CODE       CHAR (1) = 'I',
	  @Lc_No_INDC                            CHAR (1) = 'N',
	  @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
      @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
      @Lc_Yes_INDC							 CHAR (1) = 'Y',
      @Lc_StatusReceiptRefund_CODE           CHAR (1) = 'R',
      @Lc_StatusBatchUnreconciled_CODE       CHAR (1) = 'U',
      @Lc_StatusReceiptOthpRefund_CODE       CHAR (1) = 'O',
      @Lc_SourceReceiptCD_CODE               CHAR (2) = 'CD',
      @Lc_SourceReceiptAC_CODE               CHAR (2) = 'AC',
      @Lc_SourceReceiptAN_CODE               CHAR (2) = 'AN',
	  @Lc_SourceBatchDirectPayCredit_CODE    CHAR (3) = 'DCR',
	  @Lc_SourceBatchDCS_CODE                CHAR (3) = 'DCS',
	  @Lc_DummyCounty_NUMB                   CHAR (3) = '999',
	  @Lc_HoldReasonStatusSnip_CODE          CHAR (4) = 'SNIP',
	  @Ls_Procedure_NAME                     VARCHAR (100) = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY1',
	  @Ld_Low_DATE                           DATE = '01/01/0001';
  DECLARE
	  @Ln_Error_NUMB                       NUMERIC (11),
      @Ln_ErrorLine_NUMB                   NUMERIC (11),
	  @Li_Rowcount_QNTY                    SMALLINT,
	  @Ls_Sql_TEXT                         VARCHAR (100) = ' ',
	  @Ls_Sqldata_TEXT                     VARCHAR (4000) = ' ',
	  @Ls_ErrorMessage_TEXT                VARCHAR (4000),
	  @Ls_DescriptionError_TEXT            VARCHAR (4000);
  BEGIN TRY
   ------------------------------------- ROW 1  START -----------------------------
   --  Row 1 - LHS - Start
   -- Total Daily Collection
   SET @Ls_Sql_TEXT = 'TOTAL_DAILY_COLLECTION_EXCLUDING_BACKOUT';
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
          fci.Heading_NAME AS Heading_NAME,
          fci.TypeRecord_CODE AS TypeRecord_CODE,
          fci.Count_QNTY,
          fci.Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'TDC' AS TypeRecord_CODE,
                  ISNULL(COUNT(DISTINCT(ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
                  ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
              AND a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE <= @Ad_LastRun_DATE)
              AND a.BackOut_INDC = @Lc_No_INDC
              AND
              -- Exclude Repost Value_AMNT 
              NOT EXISTS (SELECT 1 
                            FROM RCTR_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND
                             -- Fix to consider the begin date also,
                             -- so that the record for the run date alone is fetched 
                             b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                             AND b.EndValidity_DATE > @Ad_Run_DATE)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'REPOST_FROM_PREVIOUS_COLLECTION';
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
          'SUMRY-OVER' AS Heading_NAME,
          'RPP' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'RPP' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              AND a.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptRefund_CODE, 'O')
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              -- A Reposted RCTH_Y1 in RCTH 
              -- B Reposted RCTH_Y1 in RCTR 
              -- C Original Backed out RCTH_Y1 in RCTH 
              -- D First entry of Original RCTH_Y1 in RCTH 
              AND (EXISTS (SELECT 1 
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
                              AND c.BeginValidity_DATE != d.BeginValidity_DATE
                              AND d.BackOut_INDC = @Lc_No_INDC))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RELEASED_FROM_PREVIOUS_COLLECTION';
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
          'SUMRY-OVER' AS Heading_NAME,
          'RLP' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'RLP' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              AND EXISTS (SELECT 1 
                            FROM RCTH_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              -- Unreconciled Value_AMNT should not be included 
              AND NOT EXISTS (SELECT 1 
                                FROM RBAT_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
              -- Do not to include the Reversed Receipts 
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BackOut_INDC = @Lc_Yes_INDC
                                 AND
                                 --RCTH_Y1 should not have been Reversed until today
                                 b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
              -- Included the condition is make sure if we re checking with the last but previous record
              AND EXISTS (SELECT 1 
                            FROM RCTH_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(c.EventGlobalBeginSeq_NUMB) 
                                                                 FROM RCTH_Y1 c
                                                                WHERE a.Batch_DATE = c.Batch_DATE
                                                                  AND a.Batch_NUMB = c.Batch_NUMB
                                                                  AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                  AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                  AND c.BeginValidity_DATE < @Ad_Start_Run_DATE
                                                                  AND
                                                                  -- To check the exactly previous records 
                                                                  c.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                                              -- Checking for Previously Unreconciled receipts also 
                                                              )
                             AND (((b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                    -- SNIP are Identified ones 
                                    AND b.ReasonStatus_CODE != @Lc_HoldReasonStatusSnip_CODE)
                                    OR (b.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE))
                                  AND a.BackOut_INDC = @Lc_No_INDC
                                  AND a.StatusReceipt_CODE IN (@Lc_StatusReceiptIdentified_CODE)
                                  AND a.Distribute_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                   OR (b.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                       AND a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                       AND a.Distribute_DATE = @Ld_Low_DATE
                                       AND a.BackOut_INDC = @Lc_No_INDC)))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'IDENTIFIED_FROM_PREVIOUS_COLLECTION';
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
          'SUMRY-OVER' AS Heading_NAME,
          'IDP' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'IDP' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              -- Do not to include the Reversed Receipts
              AND NOT EXISTS (SELECT 1 
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
              AND NOT EXISTS (SELECT 1 
                                FROM RBAT_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
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
              -- Included the condition is make sure if we re checking with the last but previous record 
              AND EXISTS (SELECT 1 
                            FROM RCTH_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(c.EventGlobalBeginSeq_NUMB) 
                                                                 FROM RCTH_Y1 c
                                                                WHERE a.Batch_DATE = c.Batch_DATE
                                                                  AND a.Batch_NUMB = c.Batch_NUMB
                                                                  AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                  AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                  AND c.BeginValidity_DATE < @Ad_Start_Run_DATE
                                                                  AND
                                                                  -- To check the exactly previous records 
                                                                  c.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                                              -- Include 'O' - Other party refunds - If OTHP refund check is Voided
                                                              -- the RCTH_Y1 is made as Unidentified instead creating DHLD records.
                                                              )
                             AND ((b.StatusReceipt_CODE IN (@Lc_StatusReceiptUnidentified_CODE, @Lc_StatusReceiptOthpRefund_CODE))
                                   -- SNIP are also Identified ones
                                   OR (b.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                                       AND b.ReasonStatus_CODE = @Lc_HoldReasonStatusSnip_CODE)))
              AND a.BackOut_INDC = @Lc_No_INDC
              AND
              -- Previous collection hold Status_CODE receipts needs to be included in 
              -- Identified From Previous Collections (IDP) fix
              a.StatusReceipt_CODE IN (@Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptHeld_CODE)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Introducing UIP to captue Unidentified from previous collection Value_AMNT
   SET @Ls_Sql_TEXT = 'UNIDENTIFIED_FROM_PREVIOUS_COLLECTION';
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
          'SUMRY-OVER' AS Heading_NAME,
          'UIP' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'UIP' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
              AND a.StatusReceipt_CODE = 'U'
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
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND
                                 -- The RCTH_Y1 should not be backed out until today 
                                 b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE
                                 AND b.BackOut_INDC = @Lc_Yes_INDC)
              -- Unreconciled Value_AMNT should not be included 
              AND NOT EXISTS (SELECT 1 
                                FROM RBAT_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND b.StatusBatch_CODE = @Lc_StatusBatchUnreconciled_CODE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE)
              -- Include the RCTH_Y1 only if it was unidentified today  
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND b.BeginValidity_DATE < @Ad_Run_DATE)
              -- A Reposted RCTH_Y1 in RCTH 
              -- B Reposted RCTH_Y1 in RCTR 
              -- C Original Backed out RCTH_Y1 in RCTH 
              -- D First entry of Original RCTH_Y1 in RCTH 
              AND EXISTS (SELECT 1 
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
                             AND d.BackOut_INDC = @Lc_No_INDC)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'UNRECONCILED_REPOSTED_PREVIOUS_DAILY_COLLECTIONS';
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
          'SUMRY-OVER' AS Heading_NAME,
          'URP' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'URP' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              -- Include the RCTH_Y1 which was reposted just today    
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              -- Do not include the Backed out receipts       
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND b.BeginValidity_DATE < @Ad_PlusOne_Run_DATE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE
                                 AND b.BackOut_INDC = 'Y')
              AND EXISTS (SELECT 1 
                            FROM RBAT_Y1 c
                           WHERE a.Batch_DATE = c.Batch_DATE
                             AND a.Batch_NUMB = c.Batch_NUMB
                             AND a.SourceBatch_CODE = c.SourceBatch_CODE
                             AND c.EndValidity_DATE > @Ad_Run_DATE
                             AND c.StatusBatch_CODE = 'U')
              -- A Reposted RCTH_Y1 in RCTH 
              -- B Reposted RCTH_Y1 in RCTR 
              -- C Original Backed out RCTH_Y1 in RCTH 
              -- D First entry of Original RCTH_Y1 in RCTH 
              AND EXISTS (SELECT 1 
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
                             AND d.BackOut_INDC = @Lc_No_INDC)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'UNRECONCILED_FROM_REPOSTED_DAILY_COLLECTIONS';
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
          'SUMRY-OVER' AS Heading_NAME,
          'URT' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'URT' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              AND EXISTS (SELECT 1 
                            FROM RBAT_Y1 c
                           WHERE a.Batch_DATE = c.Batch_DATE
                             AND a.Batch_NUMB = c.Batch_NUMB
                             AND a.SourceBatch_CODE = c.SourceBatch_CODE
                             AND c.EndValidity_DATE > @Ad_Run_DATE
                             AND c.StatusBatch_CODE = 'U')
              -- Previous unreconciled Value_AMNT should not be included here     
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              -- A Reposted RCTH_Y1 in RCTH 
              -- B Reposted RCTH_Y1 in RCTR 
              -- C Original Backed out RCTH_Y1 in RCTH 
              -- D First entry of Original RCTH_Y1 in RCTH 
              AND EXISTS (SELECT 1 
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
                             AND d.BackOut_INDC = @Lc_No_INDC)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'REVERSED_FROM_DAILY_COLLECTIONS';
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
          'SUMRY-OVER' AS Heading_NAME,
          'RVT' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(CAST(fci.ToDistribute_AMNT AS FLOAT)), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'RVT' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT * -1 AS ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              -- TO MAKE SURE THIS IS TODAYS COLLECTION
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              AND a.BackOut_INDC = @Lc_Yes_INDC
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
                                   AND d.BackOut_INDC = @Lc_No_INDC)))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'REPOSTED FROM DAILY COLLECTIONS';
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
          'SUMRY-OVER' AS Heading_NAME,
          'RPT' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(fci.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'RPT' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
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
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              AND a.BackOut_INDC = 'N'
              AND (EXISTS (-- Checking Repost
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
                              AND d.BackOut_INDC = @Lc_No_INDC))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To calculate the Summary for Row 1 - LHS
   SET @Ls_Sql_TEXT = 'ROW 1 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-LHS-1' AS Heading_NAME,
           'ROW-1' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE
                        WHEN a.TypeRecord_CODE IN ('URP', 'URT', 'RVT')
                         THEN a.Count_QNTY * -1
                        ELSE a.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE
                        WHEN a.TypeRecord_CODE IN ('URP', 'URT', 'RVT')
                         THEN a.Value_AMNT * -1
                        ELSE a.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.Heading_NAME = 'SUMRY-OVER'
               AND a.TypeRecord_CODE IN ('TDC', 'RFP', 'RPP', 'RLP',
                                         'IDP', 'URP', 'URT', 'RVT', 'RPT')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 1 - LHS - End
   --  Row 1 - RHS - Start
   SET @Ls_Sql_TEXT = 'HELD FROM DAILY COLLECTION';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'HLT' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.County_IDNO = @Lc_DummyCounty_NUMB
               AND a.Heading_NAME IN ('DIST-HELDCOLL-FULL', 'DIST-HELDCOLL-PART')
               AND a.TypeRecord_CODE = 'HLT') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Including Held from Previous Collection 
   SET @Ls_Sql_TEXT = 'HELD FROM DAILY COLLECTION';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'HLP' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.County_IDNO = @Lc_DummyCounty_NUMB
               AND a.Heading_NAME IN ('DIST-HELDCOLL-FULL', 'DIST-HELDCOLL-PART')
               AND a.TypeRecord_CODE = 'HLP') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'UNIDENTIFIED FROM DAILY COLLECTIONS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '') + ', Heading_NAME = ' + ISNULL('SUMRY-OVER','')+ ', TypeRecord_CODE = ' + ISNULL('UIT','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');;

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT a.Generate_DATE,
          'SUMRY-OVER' AS Heading_NAME,
          'UIT' AS TypeRecord_CODE,
          ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
          ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.County_IDNO = @Lc_DummyCounty_NUMB
      AND a.Heading_NAME = 'COLL-UNIDENTIFIED'
      AND a.TypeRecord_CODE = 'TOC';

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Recoupment from CP collection - Today's Collection 
   SET @Ls_Sql_TEXT = 'CP RECOUPMENT FROM DAILY COLLECTION';
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
          'SUMRY-OVER' AS Heading_NAME,
          'RCT' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (
			SELECT 'SUMRY-OVER' AS Heading_NAME,
					  'RCT' AS TypeRecord_CODE,
					  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
					  SUM(a.Transaction_AMNT) AS Value_AMNT
				  FROM CPFL_Y1 a
				WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
				  AND a.FeeType_CODE = 'NS'
				  AND Transaction_CODE = 'SREC'
                   AND EXISTS (SELECT 1 
								FROM RCTH_Y1 b
							   WHERE a.Batch_DATE = b.Batch_DATE
								 AND a.Batch_NUMB = b.Batch_NUMB
								 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
								 AND a.SourceBatch_CODE = b.SourceBatch_CODE
								 AND b.SourceReceipt_CODE = 'CF')
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
									   AND d.BackOut_INDC = @Lc_No_INDC))) 
									   GROUP BY a.Batch_DATE,a.Batch_NUMB,a.SeqReceipt_NUMB,a.SourceBatch_CODE
				  UNION ALL
			SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'RCT' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.RecOverpay_AMNT + a.RecAdvance_AMNT AS Value_AMNT
             FROM POFL_Y1 a
            WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > 0)
              AND EXISTS (SELECT 1 
                            FROM RCTH_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND b.SourceReceipt_CODE = 'CR')
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
                                   AND d.BackOut_INDC = @Lc_No_INDC)))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Recoupment from CP collection - Previous Collection 
   SET @Ls_Sql_TEXT = 'CP RECOUPMENT FROM PREVIOUS COLLECTION';
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
          'SUMRY-OVER' AS Heading_NAME,
          'RCP' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-OVER' AS Heading_NAME,
                  'RCP' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.RecOverpay_AMNT + a.RecAdvance_AMNT AS Value_AMNT
             FROM POFL_Y1 a
            WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > 0)
              AND EXISTS (SELECT 1 
                            FROM RCTH_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND b.SourceReceipt_CODE = 'CR')
              -- CQINT00028612 - Not to consider refunds from CR receipts. - Start 
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.SourceReceipt_CODE = 'CR'
                                 AND b.StatusReceipt_CODE IN ('O', @Lc_StatusReceiptRefund_CODE))
              --  Not to consider refunds from CR receipts. - End                                                                                               
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
                                       AND b.EndValidity_DATE > @Ad_Start_Run_DATE))
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
                                   AND d.BackOut_INDC = 'N')))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Total CP Recoupment 
   SET @Ls_Sql_TEXT = 'RECOUPMENT FROM CP COLLECTION ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'RCC' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.County_IDNO = @Lc_DummyCounty_NUMB
               AND a.Heading_NAME = 'SUMRY-OVER'
               AND a.TypeRecord_CODE IN ('RCT', 'RCP')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END
    
-- To calculate the Summary for Row 1 - RHS
   SET @Ls_Sql_TEXT = 'ROW 1 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-1' AS Heading_NAME,
           'ROW-1' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(r.Count_QNTY) AS Count_QNTY,
                   SUM(r.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('HLT', 'DTT', 'DTP', 'UIT',
                                                'RFT', 'RFP', 'HLP',
                                                -- Deduct Unidentified from Previous Collection (UIP) 
                                                'UIP',
                                                -- Recoupment from CP collection
                                                'RCC')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 1 - RHS - End
   --  Row 1 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 1 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-1' AS Heading_NAME,
           'DIF-1' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-1'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-1'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-1', 'SUMRY-OVER-RHS-1')
               AND r.TypeRecord_CODE = 'ROW-1') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 1  ENDS  -----------------------------
   ------------------------------------- ROW 2  START -----------------------------
   --  Row 2 - LHS - Start
   -- To calculate the Summary for Row 2 - LHS
   SET @Ls_Sql_TEXT = 'ROW 2 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT a.Generate_DATE,
           'SUMRY-OVER-LHS-2' AS Heading_NAME,
           'ROW-2' AS TypeRecord_CODE,
           ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
           ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
           a.County_IDNO
      FROM RFINS_Y1 a
     WHERE a.Generate_DATE = @Ad_Run_DATE
       AND a.Heading_NAME = 'SUMRY-OVER'
       AND a.TypeRecord_CODE = 'TDC');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 2 - LHS - Ends
   --  Row 2 - RHS - Start
   -- To calculate the Summary for Row 2 - RHS
   SET @Ls_Sql_TEXT = 'ROW 2 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-2' AS Heading_NAME,
           'ROW-2' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.TypeRecord_CODE
                        WHEN 'RPT'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.TypeRecord_CODE
                        WHEN 'RPT'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('HLT', 'DTT', 'UIT', 'RFT',
                                                'URT', 'RVT', 'RPT',
                                                -- Recoupment from CP collection 
                                                'RCT')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 2 - RHS - End
   --  Row 2 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 2 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-2' AS Heading_NAME,
           'DIF-2' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-2'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-2'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-2', 'SUMRY-OVER-RHS-2')
               AND r.TypeRecord_CODE = 'ROW-2') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 2  ENDS  -----------------------------
   ------------------------------------- ROW 3  START -----------------------------
   --  Row 3 - LHS - Start
   -- To calculate the Summary for Row 3 - LHS
   SET @Ls_Sql_TEXT = 'ROW 3 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT a.Generate_DATE,
           'SUMRY-OVER-LHS-3' AS Heading_NAME,
           'ROW-3' AS TypeRecord_CODE,
           ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
           ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
           a.County_IDNO
      FROM RFINS_Y1 a
     WHERE a.Generate_DATE = @Ad_Run_DATE
       AND a.Heading_NAME = 'SUMRY-OVER'
       AND
       a.TypeRecord_CODE = 'DED');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 3 - LHS - Ends
   --  Row 3 - RHS - Start
   -- To calculate the Summary for Row 3 - RHS
   SET @Ls_Sql_TEXT = 'ROW 3 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-3' AS Heading_NAME,
           'ROW-3' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(r.Count_QNTY) AS Count_QNTY,
                   SUM(r.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('CHK', 'CHQ', 'DIR', 'EFT',
                                                'SVC', 'EFF', 'CHA', 'FPI',
                                                'FPU', 'NCP',
                                                'CCP',
                                                'OTU', 'OFI', 'OFU')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 3 - RHS - End
   --  Row 3 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 3 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-3' AS Heading_NAME,
           'DIF-3' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-3'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-3'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-3', 'SUMRY-OVER-RHS-3')
               AND r.TypeRecord_CODE = 'ROW-3') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 3  ENDS  -----------------------------
    
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
