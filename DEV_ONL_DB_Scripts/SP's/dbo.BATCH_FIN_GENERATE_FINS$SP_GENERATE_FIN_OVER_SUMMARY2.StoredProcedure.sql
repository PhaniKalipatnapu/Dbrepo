/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY2   

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
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY2] (
		@Ad_Run_DATE				   DATE,
		@Ad_Start_Run_DATE			   DATE,
		@Ac_Msg_CODE                   CHAR(1) OUTPUT,
		@As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE
	  @Lc_StatusReceiptUnidentified_CODE     CHAR (1) = 'U',
	  @Lc_StatusReceiptHeld_CODE             CHAR (1) = 'H',
	  @Lc_StatusReceiptIdentified_CODE       CHAR (1) = 'I',
	  @Lc_StatusReleased_CODE                CHAR (1) = 'R',
	  @Lc_TypeHoldCheck_CODE                 CHAR (1) = 'C',
	  @Lc_No_INDC                            CHAR (1) = 'N',
	  @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
      @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
      @Lc_Yes_INDC							 CHAR (1) = 'Y',
      @Lc_StatusReceiptEscheated_CODE		 CHAR (1) = 'E',
      @Lc_SourceReceiptInterstatIVDFee_CODE  CHAR (2) = 'FF',
      @Lc_AddressSubTypeSPC_CODE             CHAR (3) = 'SPC',
	  @Lc_SourceBatchDirectPayCredit_CODE    CHAR (3) = 'DCR',
	  @Lc_SourceBatchDCS_CODE                CHAR (3) = 'DCS',
	  @Lc_DummyCounty_NUMB                   CHAR (3) = '999',
	  @Lc_TableRCTB_ID                       CHAR (4) = 'RCTB',
	  @Lc_IrsNadjJobDeb9070_ID               CHAR (7) = 'DEB9070',
	  @Lc_CheckRecipientTreasury_ID			 CHAR (9) = '999999983',
	  @Lc_BatchRunUser_TEXT                  CHAR (30) = 'BATCH',
	  @Ls_Procedure_NAME                     VARCHAR (100) = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_OVER_SUMMARY2';
  DECLARE
	  @Ln_BateNadj_QNTY                    NUMERIC(5) = 0,
	  @Ln_Error_NUMB                       NUMERIC (11),
      @Ln_ErrorLine_NUMB                   NUMERIC (11),
	  @Ln_AdjustBateNadj_AMNT              NUMERIC (11, 2) = 0,
	  @Li_Rowcount_QNTY                    SMALLINT,
	  @Ls_Sql_TEXT                         VARCHAR (100) = ' ',
	  @Ls_Sqldata_TEXT                     VARCHAR (4000) = ' ',
	  @Ls_ErrorMessage_TEXT                VARCHAR (4000),
	  @Ls_DescriptionError_TEXT            VARCHAR (4000);
  BEGIN TRY
   ------------------------------------- ROW 4  START -----------------------------
   --  Row 4 - LHS - Start
   -- To calculate the Summary for Row 4 - LHS
   SET @Ls_Sql_TEXT = 'ROW 4 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT a.Generate_DATE,
           'SUMRY-OVER-LHS-4' AS Heading_NAME,
           'ROW-4' AS TypeRecord_CODE,
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

   --  Row 4 - LHS - Ends
   --  Row 4 - RHS - Start
   -- To calculate the Summary for Row 4 - RHS
   SET @Ls_Sql_TEXT = 'ROW 4 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-4' AS Heading_NAME,
           'ROW-4' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(r.Count_QNTY) AS Count_QNTY,
                   SUM(r.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 r 
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('DBT', 'DBP',
                                                'DRH', 'VDR',
                                                'STR', 'RET')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 4 - RHS - End
   --  Row 4 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 4 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-4' AS Heading_NAME,
           'DIF-4' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-4'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-4'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-4', 'SUMRY-OVER-RHS-4')
               AND r.TypeRecord_CODE = 'ROW-4') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 4  ENDS  -----------------------------
   ------------------------------------- ROW 5  START -----------------------------
   --  Row 5 - LHS - Start
   -- To calculate the Summary for Row 5 - LHS
   SET @Ls_Sql_TEXT = 'ROW 5 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT a.Generate_DATE,
           'SUMRY-OVER-LHS-5' AS Heading_NAME,
           'ROW-5' AS TypeRecord_CODE,
           ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
           ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
           a.County_IDNO
      FROM RFINS_Y1 a
     WHERE a.Generate_DATE = @Ad_Run_DATE
       AND a.Heading_NAME = 'SUMRY-OVER'
       AND a.TypeRecord_CODE = 'DTT');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 5 - LHS - Ends
   --  Row 5 - RHS - Start
   -- To calculate the Summary for Row 5 - RHS
   SET @Ls_Sql_TEXT = 'ROW 5 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-5' AS Heading_NAME,
           'ROW-5' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE
                        WHEN r.TypeRecord_CODE IN ('TDC', 'RPT')
                         THEN r.Count_QNTY
                        ELSE r.Count_QNTY * -1
                       END) AS Count_QNTY,
                   SUM(CASE
                        WHEN r.TypeRecord_CODE IN ('TDC', 'RPT')
                         THEN r.Value_AMNT
                        ELSE r.Value_AMNT * -1
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('HLT', 'TDC', 'UIT', 'RFT',
                                                'URT', 'RVT',
                                                -- Recoupment from CP collection 
                                                'RPT',
                                                'RCT'
                                               )) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 5 - RHS - End
   --  Row 5 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 5 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-5' AS Heading_NAME,
           'DIF-5' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-5'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-5'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-5', 'SUMRY-OVER-RHS-5')
               AND r.TypeRecord_CODE = 'ROW-5') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 5  ENDS  -----------------------------
   ------------------------------------- ROW 6  START -----------------------------
   --  Row 6 - LHS - Start
   -- To calculate the Summary for Row 6 - LHS
   SET @Ls_Sql_TEXT = 'ROW 6 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT a.Generate_DATE,
           'SUMRY-OVER-LHS-6' AS Heading_NAME,
           'ROW-6' AS TypeRecord_CODE,
           ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
           ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
           a.County_IDNO
      FROM RFINS_Y1 a
     WHERE a.Generate_DATE = @Ad_Run_DATE
       AND a.Heading_NAME = 'SUMRY-OVER'
       AND a.TypeRecord_CODE = 'DTP');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 6 - LHS - Ends
   --  Row 6 - RHS - Start
   -- To Calculate Escheatment On Unidentified
   -- Identified and Escheated Record in RCTH which was unidentified earlier
   SET @Ls_Sql_TEXT = 'ESCHEATMENT ON UNIDENTIFIED';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '') + ', Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('SUMRY-OVER','')+ ', TypeRecord_CODE = ' + ISNULL('ESU','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'ESU' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')), 0) AS Count_QNTY,
           ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM RCTH_Y1 a,
           DSBL_Y1  c
     WHERE c.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
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
       AND a.EndValidity_DATE > @Ad_Run_DATE
       -- BUG12932 - Changing (ESU) query to populate Escheated values correctly on the Summary and Overall Summary Tabs - Start
       AND a.StatusReceipt_CODE = @Lc_StatusReceiptEscheated_CODE
       -- BUG12932 - Changing (ESU) query to populate Escheated values correctly on the Summary and Overall Summary Tabs - End
       AND a.Batch_DATE = c.Batch_DATE
       AND a.SourceBatch_CODE = c.SourceBatch_CODE
       AND a.Batch_NUMB = c.Batch_NUMB
       AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
       AND c.CheckRecipient_ID = @Lc_CheckRecipientTreasury_ID
       AND EXISTS (SELECT 1 
                     FROM RCTH_Y1 b
                    WHERE a.Batch_DATE = b.Batch_DATE
                      AND a.SourceBatch_CODE = b.SourceBatch_CODE
                      AND a.Batch_NUMB = b.Batch_NUMB
                      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                      AND b.BeginValidity_DATE < @Ad_Start_Run_DATE
                      AND b.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To calculate the Summary for Row 6 - RHS
   ---- Start 
   -- Deduct Unidentified from Previous Collection (UIP)  
   --  -- Start 
   -- Deduct Recoupment from CP collection (RCP)      
   SET @Ls_Sql_TEXT = 'ROW 6 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-6' AS Heading_NAME,
           'ROW-6' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE
                        WHEN a.TypeRecord_CODE IN ('RLP', 'RPP', 'IDP')
                         THEN a.Count_QNTY
                        ELSE a.Count_QNTY * -1
                       END) AS Count_QNTY,
                   SUM(CASE
                        WHEN a.TypeRecord_CODE IN ('RLP', 'RPP', 'IDP')
                         THEN a.Value_AMNT
                        ELSE a.Value_AMNT * -1
                       END) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.Heading_NAME = 'SUMRY-OVER'
               -- BUG12932 - Removed ESU from Line 6 RHS Sub Total - Start
               AND a.TypeRecord_CODE IN ('RLP', 'RPP', 'IDP',
                                         'URP', 'HLP', 'UIP',
                                         'RCP',
                                         'RCP')) AS fci);
			   -- BUG12932 - Removed ESU from Line 6 RHS Sub Total - End	

   -- EndsSET @
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 6 - RHS - End 
   --  Row 6 - DIFFERENCE 
   SET @Ls_Sql_TEXT = 'ROW 6 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-6' AS Heading_NAME,
           'DIF-6' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-6'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-6'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-6', 'SUMRY-OVER-RHS-6')
               AND r.TypeRecord_CODE = 'ROW-6') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 6  ENDS  -----------------------------
   ------------------------------------- ROW 7  START -----------------------------
   -- Calculate Recoupment Value_AMNT 
   SET @Ls_Sql_TEXT = 'RECOVERED TOWARDS RECOUPMENT';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'REC' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.County_IDNO = @Lc_DummyCounty_NUMB
               AND a.Heading_NAME IN ('DIST-RECU-PREV', 'DIST-RECU-TOD')
               AND a.TypeRecord_CODE IN ('RECP', 'REC')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  -- Start 
   -- RRH - Recoupment - Release from Disbursment Hold 
   SET @Ls_Sql_TEXT = 'RECOUPMENT - RELEASE FROM DISBURSMENT HOLD';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'RRH' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT (ISNULL(CAST(fci.Batch_DATE AS VARCHAR), '') + ISNULL(fci.SourceBatch_CODE, '') + ISNULL(CAST(fci.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(fci.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.RecOverpay_AMNT + a.RecAdvance_AMNT AS Value_AMNT
              FROM POFL_Y1 a
             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
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
               AND EXISTS (SELECT 1 
                             FROM DHLD_Y1 b
                            WHERE a.Case_IDNO = b.Case_IDNO
                              AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                              AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                              AND a.Batch_DATE = b.Batch_DATE
                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                              AND a.Batch_NUMB = b.Batch_NUMB
                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                              AND (b.Status_CODE = @Lc_StatusReceiptHeld_CODE
                                    -- Dollar hold will have 'H' Status_CODE only
                                    -- Check hold will have 'R' Status_CODE   
                                    OR (b.Status_CODE = @Lc_StatusReleased_CODE
                                        AND b.TypeHold_CODE = @Lc_TypeHoldCheck_CODE))
                              AND b.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                              AND b.Transaction_DATE < @Ad_Run_DATE
                              AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

	SET @Ls_Sql_TEXT = 'FEE RECOVERY - RELEASE FROM DISBURSMENT HOLD';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'FRH' AS TypeRecord_CODE,
           ISNULL(COUNT(DISTINCT (ISNULL(CAST(fci.Batch_DATE AS VARCHAR), '') + ISNULL(fci.SourceBatch_CODE, '') + ISNULL(CAST(fci.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(fci.SeqReceipt_NUMB AS VARCHAR), ''))), 0) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   SUM(a.Transaction_AMNT) AS Value_AMNT
              FROM CPFL_Y1 a
             WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
			   AND a.Transaction_CODE = 'SREC'
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
               AND EXISTS (SELECT 1 
                             FROM DHLD_Y1 b
                            WHERE a.Case_IDNO = b.Case_IDNO
                              AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                              AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                              AND a.Batch_DATE = b.Batch_DATE
                              AND a.SourceBatch_CODE = b.SourceBatch_CODE
                              AND a.Batch_NUMB = b.Batch_NUMB
                              AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                              AND (b.Status_CODE = @Lc_StatusReceiptHeld_CODE
                                    -- Dollar hold will have 'H' Status_CODE only
                                    -- Check hold will have 'R' Status_CODE   
                                    OR (b.Status_CODE = @Lc_StatusReleased_CODE
                                        AND b.TypeHold_CODE = @Lc_TypeHoldCheck_CODE))
                              AND b.EndValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                              AND b.Transaction_DATE < @Ad_Run_DATE
                              AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)
                      GROUP BY a.Batch_DATE,a.Batch_NUMB,a.SeqReceipt_NUMB,a.SourceBatch_CODE        
                        ) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'TOTAL RELEASE FROM DISBURSMENT HOLD';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'RDH' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.County_IDNO = @Lc_DummyCounty_NUMB
               AND ((a.Heading_NAME = 'SUMRY-OVER'
                     AND a.TypeRecord_CODE = 'RRH')
                     OR (a.Heading_NAME = 'SUMRY-OVER'
                         AND a.TypeRecord_CODE = 'FRH')
                     OR (a.Heading_NAME = 'DISB-PROC'
                         AND a.TypeRecord_CODE = 'DRH'))) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 7 - LHS - Start
   -- To calculate the Summary for Row 7 - LHS 
   SET @Ls_Sql_TEXT = 'ROW 7 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT a.Generate_DATE,
           'SUMRY-OVER-LHS-7' AS Heading_NAME,
           'ROW-7' AS TypeRecord_CODE,
            ISNULL(a.Count_QNTY, 0) AS Count_QNTY,
            ISNULL(a.Value_AMNT, 0) AS Value_AMNT,
           a.County_IDNO
      FROM RFINS_Y1 a
     WHERE a.Generate_DATE = @Ad_Run_DATE
       AND a.Heading_NAME = 'SUMRY-OVER'
       AND a.TypeRecord_CODE = 'TDG');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 7 - LHS - Ends
   --  Row 7 - RHS - Start
   -- To calculate the Summary for Row 7 - RHS
   SET @Ls_Sql_TEXT = 'ROW 7 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-7' AS Heading_NAME,
           'ROW-7' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE
                        WHEN r.TypeRecord_CODE IN ('DHT', 'DHP', 'REC', 'OSR' , 'FER')
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE
                        WHEN r.TypeRecord_CODE IN ('DHT', 'DHP', 'REC', 'OSR', 'FER')
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('DTT', 'DTP', 'RFT', 'RFP',
                                                'RDH', 'VDR', 'STR', 'RET',
                                                'DHT', 'DHP', 'REC', 'OSR',
                                                -- Recoupment from CP collection 
                                                'FER',
                                                --Fee recovery
                                                'RCC',
                                                -- BUG12932 - Added ESU from Line 7 RHS Sub Total - Start
                                                'ESU'
                                                -- BUG12932 - Added ESU from Line 7 RHS Sub Total - End
                                               )) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 7 - RHS - End
   --  Row 7 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 7 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-7' AS Heading_NAME,
           'DIF-7' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-7'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-7'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-7', 'SUMRY-OVER-RHS-7')
               AND r.TypeRecord_CODE = 'ROW-7') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 7  ENDS  -----------------------------
   ------------------------------------- ROW 8  START -----------------------------
   --  Row 8 - LHS - Start
   --  To Calculate Total Distributed Collections
   SET @Ls_Sql_TEXT = 'TOTAL DISTRIBUTED COLLECTIONS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'TDT' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.amt,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS amt
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.Heading_NAME IN ('DIST-PROC-TOD', 'DIST-PROC-PREV')
               AND a.TypeRecord_CODE IN ('DTT', 'DTP')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  To Calculate Total Disbursed Reissues
   SET @Ls_Sql_TEXT = 'TOTAL DISBURSED REISSUES';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'DBR' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.amt,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS amt
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.Heading_NAME = 'SUMRY-OVER'
               AND a.TypeRecord_CODE IN ('VDR', 'STR', 'RET')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To calculate the Summary for Row 8 - LHS
   SET @Ls_Sql_TEXT = 'ROW 8 - LHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-LHS-8' AS Heading_NAME,
           'ROW-8' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (-- Refund amount to be Added  
           SELECT SUM(r.Count_QNTY) AS Count_QNTY,
                  SUM(r.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('TDT',
                                                'RDH', 'RFT', 'RFP',
                                                -- BUG12932 - Changed Line 8 LHS Sub Total ES TO ESU -Start
                                                'ESU', 
                                                -- BUG12932 - Changed Line 8 LHS Sub Total ES TO ESU -End
                                                'DBR',
                                                'RCC')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 8 - LHS - Ends
   --  Row 8 - RHS - Start
   --  To Calculate Total Disbursement Hold
   SET @Ls_Sql_TEXT = 'TOTAL DISBURSEMENT HOLD';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER' AS Heading_NAME,
           'DBH' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.amt,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(a.Count_QNTY) AS Count_QNTY,
                   SUM(a.Value_AMNT) AS amt
              FROM RFINS_Y1 a
             WHERE a.Generate_DATE = @Ad_Run_DATE
               AND a.County_IDNO = @Lc_DummyCounty_NUMB
               AND a.Heading_NAME IN ('DIST-DISB-TOD', 'DIST-DISB-PREV')
               AND a.TypeRecord_CODE IN ('DHT', 'DHP')) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To calculate the Summary for Row 8 - RHS
   SET @Ls_Sql_TEXT = 'ROW 8 - RHS - SUB TOTAL';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-RHS-8' AS Heading_NAME,
           'ROW-8' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(r.Count_QNTY) AS Count_QNTY,
                   SUM(r.Value_AMNT) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-OVER'
               AND r.TypeRecord_CODE IN ('DBH', 'TDG', 'REC', 'OSR', 'FER')) AS fci);
			   
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Row 8 - RHS - End
   --  Row 8 - DIFFERENCE
   SET @Ls_Sql_TEXT = 'ROW 8 - DIFFERENCE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-OVER-DIFF-8' AS Heading_NAME,
           'DIF-8' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-8'
                         THEN r.Count_QNTY * -1
                        ELSE r.Count_QNTY
                       END) AS Count_QNTY,
                   SUM(CASE r.Heading_NAME
                        WHEN 'SUMRY-OVER-RHS-8'
                         THEN r.Value_AMNT * -1
                        ELSE r.Value_AMNT
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME IN ('SUMRY-OVER-LHS-8', 'SUMRY-OVER-RHS-8')
               AND r.TypeRecord_CODE = 'ROW-8') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   ------------------------------------- ROW 8  ENDS  -----------------------------
   --------------------------------------------------------------------------------
   --      FINS REPORT -- SUMMARY TAB  CALCULATION                               --
   --------------------------------------------------------------------------------
   -- Identified / Unidentified / Held Receipts - Deposit Sourcewise
   SET @Ls_Sql_TEXT = 'SUMRY-COLL-DEP';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('SUMRY-COLL-DEP','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT @Ad_Run_DATE AS Generate_DATE,
          'SUMRY-COLL-DEP' AS Heading_NAME,
          x.Value_CODE,
          ISNULL(b.Count_QNTY, 0) AS Count_QNTY,
          ISNULL(b.Value_AMNT, 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM REFM_Y1 x
          LEFT OUTER JOIN (SELECT DISTINCT
                                  z.SourceBatch_CODE AS SourceBatch_CODE,
                                  COUNT(z.Count_QNTY) OVER(PARTITION BY z.SourceBatch_CODE) AS Count_QNTY,
                                  z.Value_AMNT AS Value_AMNT
                             FROM (SELECT DISTINCT
                                          a.SourceBatch_CODE AS SourceBatch_CODE,
                                          ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') AS Count_QNTY,
                                          ISNULL(SUM(a.ToDistribute_AMNT) OVER(PARTITION BY a.SourceBatch_CODE), 0) AS Value_AMNT
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
                                            -- Checking Repost
                                            OR (EXISTS (SELECT 1 
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
                                                           AND d.BackOut_INDC = @Lc_No_INDC)))) AS z) AS b
           ON b.SourceBatch_CODE = x.Value_CODE
    WHERE x.Table_ID = @Lc_TableRCTB_ID
      AND x.TableSub_ID = @Lc_TableRCTB_ID;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SUMRY-COLL-DEP - TOTAL DAILY COLLECTION';
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
          'TOC' AS TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Heading_NAME), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME = 'SUMRY-COLL-DEP';

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Correcting the Formula to Derive Total Distirbuted Collection
   -- To get the precalculated value
   SET @Ls_Sql_TEXT = 'ASSIGN PRE-CALCULATED VALUES - SUMRY-COLL-DIST ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Heading_NAME = ' + ISNULL('SUMRY-COLL-DIST','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          a.Generate_DATE,
          'SUMRY-COLL-DIST' AS Heading_NAME,
          a.TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Heading_NAME, a.TypeRecord_CODE), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME, a.TypeRecord_CODE), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.County_IDNO = @Lc_DummyCounty_NUMB
      AND ((a.Heading_NAME = 'SUMRY-OVER'
            AND a.TypeRecord_CODE = 'RPP')
            -- Repost From Previous Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'RLP')
            -- Released From Previous Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'IDP')
            -- Identified From Previous Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'URP')
            --Unreconciled Reposted Previous Daily Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'URT')
            --Unreconciled From Reposted Daily Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'RVT')
            -- Reversed From Daily Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'RPT')
            -- Reposted From Daily Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'UIT')
            -- Unidentified From Daily Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'HLT')
            -- Held From Daily Collections
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'RFT')
            -- Refund From Daily Collections 
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'UIP')
            -- Unidentified from Previous Collection
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'HLP')
            -- Held From Previous Collections 
            OR (a.Heading_NAME = 'SUMRY-OVER'
                AND a.TypeRecord_CODE = 'ESU')
          -- Escheatment On Unidentified         
          );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --- RPP + RLP + IDP - UIP - HLP - ESU - URP 
   SET @Ls_Sql_TEXT = 'SUMRY-COLL-DIST - SUB TOTAL ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL('STL','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

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
          'STL' AS TypeRecord_CODE,
          ISNULL(SUM(CASE
                      WHEN a.TypeRecord_CODE NOT IN ('RLP', 'RPP', 'IDP')
                       THEN a.Count_QNTY * -1
                      ELSE a.Count_QNTY
                     END) OVER(PARTITION BY a.Heading_NAME), 0) AS Count_QNTY,
          ISNULL(SUM(CASE
                      WHEN a.TypeRecord_CODE NOT IN ('RLP', 'RPP', 'IDP')
                       THEN a.Value_AMNT * -1
                      ELSE a.Value_AMNT
                     END) OVER(PARTITION BY a.Heading_NAME), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME = 'SUMRY-COLL-DIST'
      AND a.TypeRecord_CODE IN ('RPP', 'RLP', 'IDP', 'URP',
                                'UIP', 'HLP', 'ESU');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- TOC + RPP + RLP + IDP - UIP - HLP - ESU - URP - RFT - UIT - URT - HLT 
   -- TOC + STL - RFT - UIT - URT - HLT 
   SET @Ls_Sql_TEXT = 'SUMRY-COLL-DIST - TOTAL DISTRIBUTED COLLECTIONS ';
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
          'SUMRY-COLL-DIST' AS Heading_NAME,
          'TDT' AS TypeRecord_CODE,
          ISNULL(SUM(CASE
                      WHEN a.TypeRecord_CODE NOT IN ('TOC', 'STL')
                       THEN a.Count_QNTY * -1
                      ELSE a.Count_QNTY
                     END) OVER(), 0) AS Count_QNTY,
          ISNULL(SUM(CASE
                      WHEN a.TypeRecord_CODE NOT IN ('TOC', 'STL')
                       THEN a.Value_AMNT * -1
                      ELSE a.Value_AMNT
                     END) OVER(), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME IN ('SUMRY-COLL-DIST', 'SUMRY-COLL-DEP')
      AND a.TypeRecord_CODE IN ('TOC', 'RFT', 'UIT', 'URT',
                                'HLT', 'STL');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To get the precalculated value
   SET @Ls_Sql_TEXT = 'ASSIGN PRE-CALCULATED VALUES - DISBURSEMENTS GENERATED ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          z.Generate_DATE AS Generate_DATE,
          z.Heading_NAME,
          z.TypeRecord_CODE,
          SUM(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) AS Count_QNTY,
          z.Value_AMNT AS Value_AMNT,
          z.County_IDNO
     FROM (SELECT DISTINCT
                  a.Generate_DATE,
                  CASE a.Heading_NAME
                   WHEN 'DISB-GENR-CHK'
                    THEN 'SUMRY-DISBGEN-CHK'
                   WHEN 'DISB-GENR'
                    THEN 'SUMRY-DISBGEN'
                  END AS Heading_NAME,
                  a.TypeRecord_CODE AS TypeRecord_CODE,
                  SUM(a.Count_QNTY) OVER(PARTITION BY a.TypeRecord_CODE) AS Count_QNTY,
                  ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME, a.TypeRecord_CODE), 0) AS Value_AMNT,
                  @Lc_DummyCounty_NUMB AS County_IDNO
             FROM RFINS_Y1 a
            WHERE a.Generate_DATE = @Ad_Run_DATE
              AND a.Heading_NAME IN ('DISB-GENR', 'DISB-GENR-CHK')
              AND a.County_IDNO = @Lc_DummyCounty_NUMB
              AND a.TypeRecord_CODE NOT IN ('BEGCK', 'ENDCK')) AS z;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To Calculate SDU value
   SET @Ls_Sql_TEXT = 'SDU - SUMRY-COL-SDU ';
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
          'SUMRY-COL-SDU' AS Heading_NAME,
          'SDU' AS TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME = 'SUMRY-COLL-DEP'
      AND
      -- NSF Cashless ,SDU Collections Total,COUNTy Cash
      a.TypeRecord_CODE IN ('NSF', 'SDU', 'CNC');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To get the precalculated value
   
   SET @Ls_Sql_TEXT = 'ASSIGN PRE-CALCULATED VALUES - SUMRY-COL-SDU ';
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
          'SUMRY-COL-SDU' AS Heading_NAME,
          'NSF' AS TypeRecord_CODE,
          0 AS Count_QNTY,
          0 AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
     WHERE a.Generate_DATE = @Ad_Run_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To  Calculate Collection OSR
   SET @Ls_Sql_TEXT = 'OSR - SUMRY-COL-SDU ';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('SUMRY-COL-SDU','')+ ', TypeRecord_CODE = ' + ISNULL('OSR','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          @Ad_Run_DATE AS Generate_DATE,
          'SUMRY-COL-SDU' AS Heading_NAME,
          'OSR' AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')), 0) AS Count_QNTY,
          ISNULL(SUM(a.ToDistribute_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RCTH_Y1 a
    WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
      AND a.EndValidity_DATE > @Ad_Run_DATE
      AND a.SourceReceipt_CODE = @Lc_SourceReceiptInterstatIVDFee_CODE
      AND NOT EXISTS (SELECT 1 
                        FROM RCTH_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
      -- FINS should not consider reposted recovery receipts in FINS Summary tab Interstate Cost Recovery (OSR) fix 
      AND NOT EXISTS (SELECT 1 
                        FROM RCTR_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END
	
-- Calculte SDU DUE  
   SET @Ls_Sql_TEXT = 'SUMRY-COL-SDU - DUE  ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-COL-SDU' AS Heading_NAME,
           'DUE' AS TypeRecord_CODE,
           a.Count_QNTY,
           a.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE f.TypeRecord_CODE
                        WHEN 'SDU'
                         THEN f.Count_QNTY
                        ELSE f.Count_QNTY * -1
                       END) AS Count_QNTY,
                   SUM(CASE f.TypeRecord_CODE
                        WHEN 'SDU'
                         THEN f.Value_AMNT
                        ELSE f.Value_AMNT * -1
                       END) AS Value_AMNT
              FROM RFINS_Y1  f
             WHERE f.Generate_DATE = @Ad_Run_DATE
               AND f.Heading_NAME = 'SUMRY-COL-SDU') AS a);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To Calculate IRS value
   SET @Ls_Sql_TEXT = 'IRS - SUMRY-COL-SPC ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          @Ad_Run_DATE AS Generate_DATE,
          'SUMRY-COL-SPC' AS Heading_NAME,
          @Lc_AddressSubTypeSPC_CODE AS TypeRecord_CODE,
          ISNULL(COUNT(DISTINCT fci.rec_no), 0) AS Count_QNTY,
          ISNULL(SUM(CAST(fci.ToDistribute_AMNT AS FLOAT)), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-COL-SPC' AS Heading_NAME,
                  @Lc_AddressSubTypeSPC_CODE AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  a.ToDistribute_AMNT AS ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
              AND a.SourceReceipt_CODE != 'CD'
              AND a.SourceBatch_CODE = @Lc_AddressSubTypeSPC_CODE
              AND a.BackOut_INDC = 'N'
              AND
              -- To make sure if the receipts are today's receipts 
              a.Batch_NUMB BETWEEN 7000 AND 7499
              AND NOT EXISTS (SELECT 1 
                                FROM RCTH_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND b.BeginValidity_DATE < @Ad_Start_Run_DATE)
              -- This amount should not include the reposted Value_AMNT  
              AND NOT EXISTS (SELECT 1 
                                FROM RCTR_Y1 b
                               WHERE a.Batch_DATE = b.Batch_DATE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                 AND b.EndValidity_DATE > @Ad_Run_DATE)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

    /*
     To Calculate Negative Adjustments value 
     FINS program change to get IRS negative adjustment exception amount and count from 
     NAEX_Y1 (NAEX_Y1) table instead of BATE_Y1 table. 
     IRS Negative Adjustment line in the IRS section - All positive and negative records in a given file 
     need to be included on FINS for the date that the file is processed implementation
     Including amount of the negative adjustment includes any that would fall into the BATE (prior ACSES receipts)
     because the negative still will have to be removed from the collection amount 
    */
   SET @Ls_Sql_TEXT = 'ADJ - SUMRY-COL-SPC 1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   SELECT @Ln_BateNadj_QNTY = ISNULL(COUNT(1), 0),
          @Ln_AdjustBateNadj_AMNT = ISNULL(SUM(n.Adjust_AMNT), 0)
     FROM NAEX_Y1 n
    WHERE n.Received_DATE = @Ad_Run_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ln_BateNadj_QNTY = 0;
     SET @Ln_AdjustBateNadj_AMNT = 0;
    END
   ELSE
    BEGIN
     SET @Ln_BateNadj_QNTY = 0;
     SET @Ln_AdjustBateNadj_AMNT = 0;
    END
   
   SET @Ls_Sql_TEXT = 'ADJ - SUMRY-COL-SPC - 2';	
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('SUMRY-COL-SPC','')+ ', TypeRecord_CODE = ' + ISNULL('ADJ','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');	
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          @Ad_Run_DATE AS Generate_DATE,
          'SUMRY-COL-SPC' AS Heading_NAME,
          'ADJ' AS TypeRecord_CODE,
          (ISNULL(COUNT(DISTINCT fci.rec_no), 0) + @Ln_BateNadj_QNTY) AS Count_QNTY,
          (ISNULL(SUM(CAST(fci.ToDistribute_AMNT AS FLOAT)), 0) + @Ln_AdjustBateNadj_AMNT) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT 'SUMRY-COL-SPC' AS Heading_NAME,
                  'ADJ' AS TypeRecord_CODE,
                  (ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '')) AS rec_no,
                  (a.ToDistribute_AMNT + ISNULL((-- including Repost amount
                                                SELECT SUM(c.ToDistribute_AMNT) 
                                                   FROM RCTR_Y1 b,
                                                        RCTH_Y1 c
                                                  WHERE a.Batch_DATE = b.BatchOrig_DATE
                                                    AND a.Batch_NUMB = b.BatchOrig_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceiptOrig_NUMB
                                                    AND a.SourceBatch_CODE = b.SourceBatchOrig_CODE
                                                    AND b.EndValidity_DATE > @Ad_Run_DATE
                                                    AND b.Batch_DATE = c.Batch_DATE
                                                    AND b.Batch_NUMB = c.Batch_NUMB
                                                    AND b.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                    AND b.SourceBatch_CODE = c.SourceBatch_CODE
                                                    AND c.BeginValidity_DATE = @Ad_Run_DATE
                                                    AND c.BackOut_INDC = @Lc_No_INDC
                                                    AND EXISTS (SELECT 1 
                                                                  FROM GLEV_Y1  d
                                                                 WHERE c.EventGlobalBeginSeq_NUMB = d.EventGlobalSeq_NUMB
                                                                   AND d.Worker_ID = @Lc_BatchRunUser_TEXT
                                                                   AND d.Process_ID = @Lc_IrsNadjJobDeb9070_ID)), 0)) * -1 AS ToDistribute_AMNT
             FROM RCTH_Y1 a
            WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE
              AND a.SourceReceipt_CODE != 'CD'
              AND a.SourceBatch_CODE = @Lc_AddressSubTypeSPC_CODE
              AND a.ReasonBackOut_CODE = 'NI'
              AND a.BackOut_INDC = 'Y'
              --  Commented today's collection condition  
              -- - Start --
              -- The IRS Negative Adjustments field is only populated by Negative adjustments 
              -- processed by BATCH and receipts which are reversed by worker through 
              -- RREP screen with "NI - NEGATIVE SPECIAL COLLECTIONS ADJUSTMENT"reason 
              -- should not populate in FINS IRS Negative Adjustments field.
              AND EXISTS (SELECT 1 
                            FROM GLEV_Y1 b
                           WHERE a.EventGlobalBeginSeq_NUMB = b.EventGlobalSeq_NUMB
                             AND b.Worker_ID = @Lc_BatchRunUser_TEXT)) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Calulate IRS DUE     
   SET @Ls_Sql_TEXT = 'SUMRY-COL-SPC - DUE  ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT @Ad_Run_DATE AS Generate_DATE,
           'SUMRY-COL-SPC' AS Heading_NAME,
           'DUE' AS TypeRecord_CODE,
           fci.Count_QNTY,
           fci.Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT SUM(CASE
                        WHEN (r.TypeRecord_CODE = @Lc_AddressSubTypeSPC_CODE)
                         THEN r.Count_QNTY
                        ELSE r.Count_QNTY * -1
                       END) AS Count_QNTY,
                   SUM(CASE
                        WHEN (r.TypeRecord_CODE = @Lc_AddressSubTypeSPC_CODE)
                         THEN r.Value_AMNT
                        ELSE r.Value_AMNT * -1
                       END) AS Value_AMNT
              FROM RFINS_Y1 r
             WHERE r.Generate_DATE = @Ad_Run_DATE
               AND r.Heading_NAME = 'SUMRY-COL-SPC') AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ASSIGN PRE-CALCULATED VALUES - SUMMARY HELD ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          fci.Generate_DATE,
          fci.Heading_NAME,
          fci.TypeRecord_CODE,
          ISNULL(SUM(fci.Count_QNTY) OVER(PARTITION BY fci.TypeRecord_CODE), 0) AS Count_QNTY,
          ISNULL(SUM(fci.Value_AMNT) OVER(PARTITION BY fci.TypeRecord_CODE), 0) AS Value_AMNT,
          fci.County_IDNO
     FROM (SELECT a.Generate_DATE,
                  'SUMRY-HELD' AS Heading_NAME,
                  SUBSTRING(a.TypeRecord_CODE, 1, 3) AS TypeRecord_CODE,
                  a.Count_QNTY,
                  a.Value_AMNT,
                  @Lc_DummyCounty_NUMB AS County_IDNO
             FROM RFINS_Y1 a
            WHERE a.Generate_DATE = @Ad_Run_DATE
              AND a.County_IDNO = @Lc_DummyCounty_NUMB
              AND ((a.Heading_NAME IN ('DIST-DISB-TOD', 'DIST-DISB-PREV')
                    AND a.TypeRecord_CODE NOT IN ('DHT', 'DHP'))
                    OR (a.Heading_NAME = 'SUMRY-OVER'
                        AND a.TypeRecord_CODE = 'DHH'))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SUMRY-HELD - SUB TOTAL ';
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
          'TOH' AS TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Heading_NAME), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME = 'SUMRY-HELD'
      AND a.TypeRecord_CODE IN ('ADH', 'CPH', 'IVH',
                                'MSL', 'OTH'
                               );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- To get the precalculated value
   SET @Ls_Sql_TEXT = 'ASSIGN PRE-CALCULATED VALUES - SUMRY-RECOUP ';
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
          'SUMRY-RECOUP' AS Heading_NAME,
          a.TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Heading_NAME, a.TypeRecord_CODE), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME, a.TypeRecord_CODE), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND
      -- Intergovernmental Cost Recovery
      ((a.Heading_NAME = 'SUMRY-OVER'
        AND a.TypeRecord_CODE = 'OSR')
        -- Interstate Cost Recovery
        OR (a.Heading_NAME = 'SUMRY-OVER'
            AND a.TypeRecord_CODE = 'REC')
      );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SUMRY-RECOUP - SUB TOTAL ';
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
          'RET' AS TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Heading_NAME), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME = 'SUMRY-RECOUP'
      AND
      a.TypeRecord_CODE IN ('OSR', 'REC');
      
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SUMRY-DISBGEN - TOTAL ';
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
          'SUMRY-DISBGEN' AS Heading_NAME,
          'TTL' AS TypeRecord_CODE,
          ISNULL(SUM(a.Count_QNTY) OVER(PARTITION BY a.Generate_DATE), 0) AS Count_QNTY,
          ISNULL(SUM(a.Value_AMNT) OVER(PARTITION BY a.Generate_DATE), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM RFINS_Y1 a
    WHERE a.Generate_DATE = @Ad_Run_DATE
      AND a.Heading_NAME IN ('SUMRY-DISBGEN', 'SUMRY-HELD', 'SUMRY-RECOUP')
      AND a.TypeRecord_CODE IN ('TDG', 'TOH', 'RET' , 'FER');
	  
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
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
