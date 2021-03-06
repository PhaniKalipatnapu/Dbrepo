/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_COLLECTION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_COLLECTION   
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
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_COLLECTION] (
		@Ad_Run_DATE				   DATE,
		@Ad_Start_Run_DATE			   DATE,
		@Ad_LastRun_DATE			   DATE,
		@Ac_Msg_CODE                   CHAR(1) OUTPUT,
		@As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE
      @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
      @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
      @Lc_Yes_INDC                           CHAR (1) = 'Y',
      @Lc_No_INDC                            CHAR (1) = 'N',
      @Lc_StatusReceiptIdentified_CODE       CHAR (1) = 'I',
      @Lc_StatusReceiptOthpRefund_CODE       CHAR (1) = 'O',
      @Lc_StatusReceiptHeld_CODE             CHAR (1) = 'H',
      @Lc_StatusReceiptRefund_CODE           CHAR (1) = 'R',
      @Lc_StatusReceiptEscheated_CODE        CHAR (1) = 'E',
      @Lc_StatusReceiptUnidentified_CODE     CHAR (1) = 'U',
	  @Lc_SourceReceiptCD_CODE               CHAR (2) = 'CD',
	  @Lc_SourceReceiptAC_CODE               CHAR (2) = 'AC',
	  @Lc_SourceReceiptAN_CODE               CHAR (2) = 'AN',
	  @Lc_DummyCounty_NUMB                   CHAR (3) = '999',
	  @Lc_TableRCTS_IDNO                     CHAR (4) = 'RCTS',
	  @Ls_Procedure_NAME                     VARCHAR (100) = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_COLLECTION';
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
   --      FINS REPORT -- COLLECTION TAB  CALCULATION                            --
   --------------------------------------------------------------------------------
   -- Collection -- RCTH_Y1 Sourcewise (Consolidated) 
   SET @Ls_Sql_TEXT = 'COLLECTION_CONSOLIDATED';
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
          'COLL-ALL' AS Heading_NAME,
          b.TypeRecord_CODE,
          ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
          ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT r.Value_CODE AS TypeRecord_CODE
             FROM REFM_Y1 r
            WHERE r.Table_ID = @Lc_TableRCTS_IDNO
              AND r.TableSub_ID = @Lc_TableRCTS_IDNO
              AND r.Value_CODE NOT IN (@Lc_SourceReceiptCD_CODE)) AS b
          LEFT OUTER JOIN (SELECT DISTINCT
                                  z.SourceReceipt_CODE AS SourceReceipt_CODE,
                                  COUNT(DISTINCT z.Count_QNTY) AS Count_QNTY,
                                  ISNULL(SUM(z.ToDistribute_AMNT), 0) AS Value_AMNT                                  
                             FROM (SELECT 
                                          a.SourceReceipt_CODE,
                                          ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') AS Count_QNTY,
                                          a.ToDistribute_AMNT AS ToDistribute_AMNT
                                     FROM RCTH_Y1 a
                                    WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                      AND a.EndValidity_DATE > @Ad_Run_DATE
                                      AND
                                      -- Include the Reposted amount in collection (DACSES Receipts) 
                                      (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                        OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                            AND EXISTS (SELECT 1 
                                                          FROM RCTR_Y1 b
                                                         WHERE a.Batch_DATE = b.Batch_DATE
                                                           AND a.Batch_NUMB = b.Batch_NUMB
                                                           AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                           AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                           AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                           AND b.EndValidity_DATE > @Ad_Run_DATE)))
                                      -- To Make sure this is today's RCTH_Y1
                                      AND NOT EXISTS (SELECT 1 
                                                        FROM RCTH_Y1 b
                                                       WHERE a.Batch_DATE = b.Batch_DATE
                                                         AND a.Batch_NUMB = b.Batch_NUMB
                                                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                         AND b.BeginValidity_DATE <= @Ad_LastRun_DATE)
                                      AND (a.BackOut_INDC != @Lc_Yes_INDC
                                            OR (a.BackOut_INDC = @Lc_Yes_INDC
                                                -- If RCTH_Y1 is backed out, original RCTH_Y1 should also be posted today itself.
                                                AND EXISTS (SELECT 1 
                                                              FROM RCTH_Y1 b
                                                             WHERE a.Batch_DATE = b.Batch_DATE
                                                               AND a.Batch_NUMB = b.Batch_NUMB
                                                               AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                               AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                               AND b.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                                   FROM RCTH_Y1 x
                                                                                                  WHERE b.Batch_DATE = x.Batch_DATE
                                                                                                    AND b.Batch_NUMB = x.Batch_NUMB
                                                                                                    AND b.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                                    AND b.SourceBatch_CODE = x.SourceBatch_CODE)
                                                               AND a.BeginValidity_DATE = b.BeginValidity_DATE
                                                               AND b.BackOut_INDC = @Lc_No_INDC)))
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
                                                               RCTH_Y1 d
                                                         -- Checking Repost
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
                                                           AND d.BackOut_INDC = @Lc_No_INDC))))AS z GROUP BY z.SourceReceipt_CODE) AS a
           ON a.SourceReceipt_CODE = b.TypeRecord_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Collection -- Identified  - RCTH_Y1 Source wise
   SET @Ls_Sql_TEXT = 'COLLECTION_IDENTIFIED';
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
          'COLL-IDENTIFIED' AS Heading_NAME,
          b.TypeRecord_CODE,
          ISNULL(z.Count_QNTY, 0) AS Count_QNTY,
          ISNULL(z.Value_AMNT, 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT a.Value_CODE AS TypeRecord_CODE
             FROM REFM_Y1  a
            WHERE a.Table_ID = @Lc_TableRCTS_IDNO
              AND a.TableSub_ID = @Lc_TableRCTS_IDNO
              AND a.Value_CODE NOT IN (@Lc_SourceReceiptCD_CODE)) AS b
          LEFT OUTER JOIN (SELECT  a.SourceReceipt_CODE AS SourceReceipt_CODE,
                                          COUNT( DISTINCT CASE a.StatusReceipt_CODE
                                            WHEN @Lc_StatusReceiptIdentified_CODE
                                             THEN (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))
                                            WHEN @Lc_StatusReceiptOthpRefund_CODE
                                             THEN (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))
                                            WHEN @Lc_StatusReceiptHeld_CODE
                                             THEN (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))
                                            WHEN @Lc_StatusReceiptRefund_CODE
                                             THEN (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))
                                            WHEN @Lc_StatusReceiptEscheated_CODE
                                             THEN
                                             CASE CAST(a.PayorMCI_IDNO AS VARCHAR)
                                              WHEN '0'
                                               THEN '1'
                                              ELSE (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), ''))
                                             END
                                            ELSE '0'
                                           END)  
                                          + 
                                          SUM (DISTINCT CASE a.StatusReceipt_CODE
                                            WHEN @Lc_StatusReceiptIdentified_CODE
                                             THEN 0
                                            WHEN @Lc_StatusReceiptOthpRefund_CODE
                                             THEN 0
                                            WHEN @Lc_StatusReceiptRefund_CODE
                                             THEN 0
                                            WHEN @Lc_StatusReceiptHeld_CODE
                                             THEN 0
                                            WHEN @Lc_StatusReceiptEscheated_CODE
                                             THEN
                                             CASE CAST(a.PayorMCI_IDNO AS VARCHAR)
                                              WHEN '0'
                                               THEN -1
                                              ELSE '0'
                                             END
                                            ELSE '0'
                                           END) 
                                           AS Count_QNTY,
                                          -- exclude rcpt type E PayorMCI_IDNO as NULL 
                                          SUM(CASE a.StatusReceipt_CODE
                                               WHEN @Lc_StatusReceiptIdentified_CODE
                                                THEN a.ToDistribute_AMNT
                                               WHEN @Lc_StatusReceiptOthpRefund_CODE
                                                THEN a.ToDistribute_AMNT
                                               WHEN @Lc_StatusReceiptHeld_CODE
                                                THEN a.ToDistribute_AMNT
                                               WHEN @Lc_StatusReceiptRefund_CODE
                                                THEN a.ToDistribute_AMNT
                                               WHEN @Lc_StatusReceiptEscheated_CODE
                                                THEN
                                                CASE a.PayorMCI_IDNO
                                                 WHEN 0
                                                  THEN 0
                                                 ELSE a.ToDistribute_AMNT
                                                END
                                               ELSE 0
                                              END) 
                                              AS Value_AMNT
                                     FROM RCTH_Y1 a
                                    WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE 
                                      AND a.EndValidity_DATE > @Ad_Run_DATE
                                      AND
                                      -- ACESES VR Fix  
                                      -- Include the Reposted Value_AMNT in collection (ACSES Receipts) 
                                      (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                        OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                            AND EXISTS (SELECT 1 
                                                          FROM RCTR_Y1 b
                                                         WHERE a.Batch_DATE = b.Batch_DATE
                                                           AND a.Batch_NUMB = b.Batch_NUMB
                                                           AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                           AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                           AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                           AND b.EndValidity_DATE > @Ad_Run_DATE)))
                                      AND a.StatusReceipt_CODE != @Lc_StatusReceiptUnidentified_CODE
                                      AND NOT EXISTS (SELECT 1 
                                                        FROM RCTH_Y1 b
                                                       WHERE a.Batch_DATE = b.Batch_DATE
                                                         AND a.Batch_NUMB = b.Batch_NUMB
                                                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                         AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                                      AND (a.BackOut_INDC != @Lc_Yes_INDC
                                            OR (a.BackOut_INDC = @Lc_Yes_INDC
                                                -- If receipt is backed out, original RCTH_Y1 should also be posted today itself.
                                                AND EXISTS (SELECT 1 
                                                              FROM RCTH_Y1 b
                                                             WHERE a.Batch_DATE = b.Batch_DATE
                                                               AND a.Batch_NUMB = b.Batch_NUMB
                                                               AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                               AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                               AND b.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                                   FROM RCTH_Y1 x
                                                                                                  WHERE b.Batch_DATE = x.Batch_DATE
                                                                                                    AND b.Batch_NUMB = x.Batch_NUMB
                                                                                                    AND b.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                                    AND b.SourceBatch_CODE = x.SourceBatch_CODE)
                                                               AND a.BeginValidity_DATE = b.BeginValidity_DATE
                                                               AND b.BackOut_INDC = @Lc_No_INDC)))
                                      -- Check if this receipt is not backed out 
                                      AND NOT EXISTS (SELECT 1 
                                                        FROM RCTH_Y1 b
                                                       WHERE a.Batch_DATE = b.Batch_DATE
                                                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                         AND a.Batch_NUMB = b.Batch_NUMB
                                                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                         AND
                                                         -- Added the BeginValidity_DATE to make sure the query 
                                                         -- fetches the same data even if it is re run 
                                                         b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                         AND b.EndValidity_DATE > @Ad_Run_DATE
                                                         AND b.BackOut_INDC = 'Y')
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
                                                           AND d.BackOut_INDC = @Lc_No_INDC)) ) GROUP BY a.SourceReceipt_CODE 
                                                         ) AS z  
           ON z.SourceReceipt_CODE = b.TypeRecord_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Collection -- Unidentified  - RCTH_Y1 Sourcewise
   SET @Ls_Sql_TEXT = 'COLLECTION_UNIDENTIFIED';
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
          'COLL-UNIDENTIFIED' AS Heading_NAME,
          b.TypeRecord_CODE,
          ISNULL(COUNT(a.rcpt_no) OVER(PARTITION BY b.TypeRecord_CODE), 0) AS Count_QNTY,
          ISNULL(SUM(CAST(a.Value_AMNT AS FLOAT)) OVER(PARTITION BY b.TypeRecord_CODE), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT a.Value_CODE AS TypeRecord_CODE
             FROM REFM_Y1  a
            WHERE a.Table_ID = @Lc_TableRCTS_IDNO
              AND a.TableSub_ID = @Lc_TableRCTS_IDNO
              AND a.Value_CODE NOT IN (@Lc_SourceReceiptCD_CODE)) AS b
          LEFT OUTER JOIN (SELECT a.SourceReceipt_CODE,
                                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rcpt_no,
                                  a.ToDistribute_AMNT AS Value_AMNT
                             FROM RCTH_Y1 a
                            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                              AND a.EndValidity_DATE > @Ad_Run_DATE
                              AND
                              -- Include the Reposted amount in collection 
                              (a.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCD_CODE, @Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                OR (a.SourceReceipt_CODE IN (@Lc_SourceReceiptAC_CODE, @Lc_SourceReceiptAN_CODE)
                                    AND EXISTS (SELECT 1 
                                                  FROM RCTR_Y1 b
                                                 WHERE a.Batch_DATE = b.Batch_DATE
                                                   AND a.Batch_NUMB = b.Batch_NUMB
                                                   AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                   AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                   AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                   AND b.EndValidity_DATE > @Ad_Run_DATE)))
                              AND a.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
                              AND NOT EXISTS (SELECT 1 
                                                FROM RCTH_Y1 b
                                               WHERE a.Batch_DATE = b.Batch_DATE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
                              AND (a.BackOut_INDC != @Lc_Yes_INDC
                                    OR (a.BackOut_INDC = @Lc_Yes_INDC
                                        -- If RCTH_Y1 is backed out, original RCTH_Y1 should also be posted today itself.
                                        AND EXISTS (SELECT 1 
                                                      FROM RCTH_Y1 b
                                                     WHERE a.Batch_DATE = b.Batch_DATE
                                                       AND a.Batch_NUMB = b.Batch_NUMB
                                                       AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                       AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                       AND b.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB) 
                                                                                           FROM RCTH_Y1 x
                                                                                          WHERE b.Batch_DATE = x.Batch_DATE
                                                                                            AND b.Batch_NUMB = x.Batch_NUMB
                                                                                            AND b.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                                                            AND b.SourceBatch_CODE = x.SourceBatch_CODE)
                                                       AND a.BeginValidity_DATE = b.BeginValidity_DATE
                                                       AND b.BackOut_INDC = @Lc_No_INDC)))
                              AND NOT EXISTS
                                      -- Check if this RCTH_Y1 is not backed out
                                      (SELECT 1 
                                         FROM RCTH_Y1 b
                                        WHERE a.Batch_DATE = b.Batch_DATE
                                          AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                          AND a.Batch_NUMB = b.Batch_NUMB
                                          AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                          AND
                                          -- Added the BeginValidity_DATE to make sure the query 
                                          -- fetches the same data even if it is re run 
                                          b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                          AND b.EndValidity_DATE > @Ad_Run_DATE
                                          AND b.BackOut_INDC = 'Y')
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
                                                   AND d.BackOut_INDC = @Lc_No_INDC)))) AS a
           ON a.SourceReceipt_CODE = b.TypeRecord_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Collections - Total
   SET @Ls_Sql_TEXT = 'COLLECTION_TOTAL';
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
           'TOC' AS TypeRecord_CODE,
           SUM(f.Count_QNTY) OVER(PARTITION BY f.Heading_NAME) AS Count_QNTY,
           SUM(f.Value_AMNT) OVER(PARTITION BY f.Heading_NAME) AS Value_AMNT,
           f.County_IDNO
      FROM RFINS_Y1  f
     WHERE f.Generate_DATE = @Ad_Run_DATE
       AND f.Heading_NAME LIKE 'COLL-%');

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
