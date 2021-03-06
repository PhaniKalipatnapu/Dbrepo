/****** Object:  StoredProcedure [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DIBURSEMENT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DIBURSEMENT   

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
CREATE PROCEDURE [dbo].[BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DIBURSEMENT] (
		@Ad_Run_DATE				   DATE,
		@Ad_Start_Run_DATE			   DATE,
		@Ac_Msg_CODE                   CHAR(1) OUTPUT,
		@As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT)
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE
	  @Lc_FundRecipientCpNcp_CODE            CHAR (1) = '1',
      @Lc_FundRecipientFIPS_CODE             CHAR (1) = '2',
      @Lc_CheckRecipientOthp_CODE            CHAR (1) = '3',
      @Lc_StatusReceiptHeld_CODE             CHAR (1) = 'H',
      @Lc_StatusReleased_CODE                CHAR (1) = 'R',
      @Lc_TypeHoldCheck_CODE                 CHAR (1) = 'C',
      @Lc_StatusReceiptRefund_CODE           CHAR (1) = 'R',
      @Lc_MediumDisburseFipsEft_CODE         CHAR (1) = 'E',
      @Lc_MediumDisburseSVC_CODE             CHAR (1) = 'B',
      @Lc_MediumDisburseCpCheck_CODE         CHAR (1) = 'C',
      @Lc_StatusSuccess_CODE                 CHAR (1) = 'S',
      @Lc_StatusFailed_CODE                  CHAR (1) = 'F',
      @Lc_DummyCounty_NUMB                   CHAR (3) = '999',
      @Lc_SourceBatchDCS_CODE                CHAR (3) = 'DCS',
      @Lc_TableCHKS_IDNO                     CHAR (4) = 'CHKS',
      @Lc_TableFINS_IDNO                     CHAR (4) = 'FINS',
      @Lc_TableSubDISB_ID                    CHAR (4) = 'DISB',
      @Lc_TypeDisburseRefund_CODE            CHAR (5) = 'REFND',
	  @Lc_TypeDisburseOthp_CODE              CHAR (5) = 'ROTHP',
	  @Lc_RefundRecipientOfficeIVA_ID		 CHAR (9) = '999999994',
      @Lc_RefundRecipientOfficeIVE_ID		 CHAR (9) = '999999993',
      @Lc_CheckRecipientTreasury_ID			 CHAR (9) = '999999983',
      @Lc_CheckRecipientIVE_ID				 CHAR (9) = '999999993',
      @Lc_CheckRecipientMEDI_ID				 CHAR (9) = '999999982',
      @Lc_CheckRecipientOSR_ID				 CHAR (9) = '999999980',
      @Lc_CheckRecipientDra_ID				 CHAR (9) = '999999978',	
      @Lc_CheckRecipientSpc_ID				 CHAR (9) = '999999977',
      @Lc_CheckRecipientCpNsf_ID			 CHAR (9) = '999999964',	
      @Lc_CheckRecipientNcpNsf_ID			 CHAR (9) = '999999963',	
      @Lc_CheckRecipientGt_ID				 CHAR (9) = '999999976',
      @Ls_Procedure_NAME                     VARCHAR (100) = 'BATCH_FIN_GENERATE_FINS$SP_GENERATE_FIN_DIBURSEMENT',
	  @Ld_Low_DATE						     DATE = '01/01/0001',
	  @Ld_High_DATE                          DATE = '12/31/9999';
  DECLARE
	  @Ln_Error_NUMB                       NUMERIC (11),
      @Ln_ErrorLine_NUMB                   NUMERIC (11),
      @Li_Rowcount_QNTY                    SMALLINT,
      @Lc_BegCheck_NUMB                    CHAR (11),
      @Lc_EndCheck_NUMB                    CHAR (11),
	  @Ls_Sql_TEXT                         VARCHAR (100) = ' ',
	  @Ls_Sqldata_TEXT                     VARCHAR (4000) = ' ',
	  @Ls_ErrorMessage_TEXT                VARCHAR (4000),
	  @Ls_DescriptionError_TEXT            VARCHAR (4000);	
  BEGIN TRY
--------------------------------------------------------------------------------
   --      FINS REPORT -- DISBURSEMENT TAB  CALCULATION                          --
   --------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_CP';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           x.Generate_DATE,
           x.Heading_NAME,
           x.TypeRecord_CODE,
           x.Count_QNTY,
           x.Value_AMNT,
           x.County_IDNO
      FROM (SELECT DISTINCT
                   z.Generate_DATE AS Generate_DATE,
                   z.Heading_NAME AS Heading_NAME,
                   z.TypeRecord_CODE AS TypeRecord_CODE,
                   CASE z.Value_AMNT 
                   WHEN 0 THEN 0
                   ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.CheckRecipient_CODE) 
                   END AS Count_QNTY,
                   z.Value_AMNT AS Value_AMNT,
                   z.County_IDNO AS County_IDNO,
                   z.CheckRecipient_CODE AS CheckRecipient_CODE
              FROM (SELECT DISTINCT
                           @Ad_Run_DATE AS Generate_DATE,
                           'DISB-PROC' AS Heading_NAME,
                           'CP' AS TypeRecord_CODE,
                           ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                           SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                           b.County_IDNO,
                           a.CheckRecipient_CODE AS CheckRecipient_CODE
                      FROM COPT_Y1 b
                           LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                                   x.County_IDNO,
                                                   a.CheckRecipient_CODE,
                                                   b.Misc_ID,
                                                   a.CheckRecipient_ID,
                                                   a.Disburse_DATE,
                                                   a.DisburseSeq_NUMB
                                              FROM DSBL_Y1 a,
                                                   CASE_Y1 x,
                                                   DSBH_Y1 b
                                             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                               AND a.Batch_DATE != @Ld_Low_DATE
                                               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                               AND b.EndValidity_DATE > @Ad_Run_DATE
                                               AND
                                               --  To exclude Demand Checks
                                               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                               AND a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                               AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                               AND a.Disburse_DATE = b.Disburse_DATE
                                               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                               AND
                                               -- Excluding OSR Value_AMNT 
                                               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                               AND a.Case_IDNO = x.Case_IDNO) AS a
                            ON a.County_IDNO = b.County_IDNO) AS z) AS x);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_CP-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'CP' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               --  To exclude Demand Checks
               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND
               -- Excluding OSR Value_AMNT 
               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FIPS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   (SELECT DISTINCT
           x.Generate_DATE,
           x.Heading_NAME,
           x.TypeRecord_CODE,
           x.Count_QNTY,
           x.Value_AMNT,
           x.County_IDNO
      FROM (SELECT DISTINCT
                   z.Generate_DATE AS Generate_DATE,
                   z.Heading_NAME AS Heading_NAME,
                   z.TypeRecord_CODE AS TypeRecord_CODE,
                   CASE z.Value_AMNT 
                   WHEN 0 THEN 0
                   ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.CheckRecipient_CODE) 
                   END AS Count_QNTY,
                   z.Value_AMNT AS Value_AMNT,
                   z.County_IDNO AS County_IDNO,
                   z.CheckRecipient_CODE AS CheckRecipient_CODE
              FROM (SELECT DISTINCT
                           @Ad_Run_DATE AS Generate_DATE,
                           'DISB-PROC' AS Heading_NAME,
                           'FIPS' AS TypeRecord_CODE,
                           ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                           SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                           b.County_IDNO,
                           a.CheckRecipient_CODE AS CheckRecipient_CODE
                      FROM COPT_Y1 b
                           LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                                   x.County_IDNO,
                                                   a.CheckRecipient_CODE,
                                                   b.Misc_ID,
                                                   a.CheckRecipient_ID,
                                                   a.Disburse_DATE,
                                                   a.DisburseSeq_NUMB
                                              FROM DSBL_Y1 a,
                                                   CASE_Y1 x,
                                                   DSBH_Y1 b
                                             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                               AND b.EndValidity_DATE > @Ad_Run_DATE
                                               AND a.Batch_DATE != @Ld_Low_DATE
                                               AND
                                               --  To exclude Demand Checks
                                               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                               AND a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                               AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                               AND a.Disburse_DATE = b.Disburse_DATE
                                               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                               AND
                                               -- Excluding OSR Value_AMNT 
                                               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                               AND a.Case_IDNO = x.Case_IDNO) AS a
                            ON a.County_IDNO = b.County_IDNO) AS z) AS x);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FINS-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'FIPS' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               --  To exclude Demand Checks
               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND
               -- Excluding OSR Value_AMNT 
               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_REFUND';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'REF' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.CheckRecipient_CODE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND
                                       --  To exclude Demand Checks 
                                       a.TypeDisburse_CODE IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND
                                       -- Excluding OSR Value_AMNT 
                                       a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND a.Case_IDNO = x.Case_IDNO) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_REFUND-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'REF' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               --  To exclude Demand Checks
               a.TypeDisburse_CODE IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND
               -- Excluding OSR Value_AMNT 
               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- IVA 
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_IVA';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'IVA' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.CheckRecipient_CODE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND
                                       --  To exclude Refund
                                       a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.CheckRecipient_ID = @Lc_RefundRecipientOfficeIVA_ID
                                       ) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- IVA 
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_IVA-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'IVA' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               --  To exclude Refund 
               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                AND a.CheckRecipient_ID = @Lc_RefundRecipientOfficeIVA_ID
               ) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FOSTER_CARE';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'IVE' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.CheckRecipient_CODE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND
                                       --  To exclude Refund  
                                       a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       --'OFFICE009' - DEPARTMENT OF SERVICES FOR CHILD, YOUTH AND THEIR FAMILIES
                                       AND a.CheckRecipient_ID = @Lc_CheckRecipientIVE_ID
                                       AND
                                       -- Central-Dyfs Central Office (DYFS)  
                                       a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.Case_IDNO = x.Case_IDNO) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FOSTER_CARE-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'IVE' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               --  To exclude Refund
               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND a.CheckRecipient_ID = @Lc_CheckRecipientIVE_ID
               AND
               -- Central-Dyfs Central Office (DYFS) 
               a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_MEDICAID';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'MED' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.CheckRecipient_CODE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND
                                       --  To exclude Refund
                                       a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND
                                       -- Central-Div. Of Med. Asst. (MEDI) 
                                       a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.CheckRecipient_ID = @Lc_CheckRecipientMEDI_ID) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_MEDICAID-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'MED' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND
               --  To exclude Refund 
               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               -- Central-Div. Of Med. Asst. (MEDI) 
               a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND a.CheckRecipient_ID = @Lc_CheckRecipientMEDI_ID) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_ESIU';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'ES' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.CheckRecipient_CODE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND
                                       --  To exclude Refund 
                                       a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.CheckRecipient_ID = @Lc_CheckRecipientTreasury_ID
                                   -- Central-Department of the Treasury
                                   ) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_ESIU-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'ES' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.CheckRecipient_CODE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.Disburse_DATE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND
               --  To exclude Refund
               a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND a.CheckRecipient_ID = @Lc_CheckRecipientTreasury_ID
           -- Central-Department of the Treasury
           ) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Calculate NJD --COUNTywise       
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FROM_LOWDATE - COUNTYWISE';
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
           'DED' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME = 'DISB-PROC'
       AND r.TypeRecord_CODE IN ('CP', 'FIPS', 'REF', 'IVA',
                                        'IVE', 'MED', 'ES'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FROM_TODAY';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'DBT' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.Disburse_DATE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                                 AND EXISTS (SELECT 1 
                                                               FROM RCTR_Y1 c
                                                              WHERE a.Batch_DATE = c.Batch_DATE
                                                                AND a.Batch_NUMB = c.Batch_NUMB
                                                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                AND c.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                AND c.EndValidity_DATE > @Ad_Run_DATE)))
                                       AND
                                       -- Excluding OSR Value_AMNT 
                                       a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND NOT EXISTS (-- Excluding Void Reissue / Stop Reissue /  Reject EFT
                                                      SELECT 1 
                                                         FROM DSBC_Y1 x,
                                                              DSBH_Y1 y
                                                        -- B current check number 
                                                        -- Y Old Check Number 
                                                        WHERE a.Disburse_DATE = x.Disburse_DATE
                                                          AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                          AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                                          AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                          AND y.Disburse_DATE = x.DisburseOrig_DATE
                                                          AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                                                          AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                                                          AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE
                                                          AND y.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                                                          AND y.EndValidity_DATE > @Ad_Run_DATE)
                                       AND NOT EXISTS (SELECT 1 
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
                                                          AND b.Transaction_DATE < @Ad_Start_Run_DATE
                                                          AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)
                                       AND NOT EXISTS (SELECT 1 
                                                         FROM RCTH_Y1 c
                                                        WHERE a.Batch_DATE = c.Batch_DATE
                                                          AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                          AND a.Batch_NUMB = c.Batch_NUMB
                                                          AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                          AND c.BeginValidity_DATE < @Ad_Start_Run_DATE)) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FROM_TODAY-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'DBT' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.Disburse_DATE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                         AND EXISTS (SELECT 1 
                                       FROM RCTR_Y1 c
                                      WHERE a.Batch_DATE = c.Batch_DATE
                                        AND a.Batch_NUMB = c.Batch_NUMB
                                        AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                        AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                        AND c.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                        AND c.EndValidity_DATE > @Ad_Run_DATE)))
               AND
               -- Excluding OSR Value_AMNT 
               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
               AND
               -- Excluding Void Reissue / Stop Reissue /  Reject EFT 
               NOT EXISTS (SELECT 1 
                             FROM DSBC_Y1 x,
                                  DSBH_Y1 y
                            -- B current check number 
                            -- Y Old Check Number
                            WHERE a.Disburse_DATE = x.Disburse_DATE
                              AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                              AND a.CheckRecipient_ID = x.CheckRecipient_ID
                              AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                              AND y.Disburse_DATE = x.DisburseOrig_DATE
                              AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                              AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                              AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE
                              AND y.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                              AND y.EndValidity_DATE > @Ad_Run_DATE)
               AND NOT EXISTS (SELECT 1 
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
                                  AND b.Transaction_DATE < @Ad_Start_Run_DATE
                                  AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)
               AND NOT EXISTS (SELECT 1 
                                 FROM RCTH_Y1 c
                                WHERE a.Batch_DATE = c.Batch_DATE
                                  AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                  AND a.Batch_NUMB = c.Batch_NUMB
                                  AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                  AND c.BeginValidity_DATE < @Ad_Start_Run_DATE)) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Disbursed from Previous Collections
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FROM_PREV';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'DBP' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.Disburse_DATE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                                 AND EXISTS (SELECT 1 
                                                               FROM RCTR_Y1 c
                                                              WHERE a.Batch_DATE = c.Batch_DATE
                                                                AND a.Batch_NUMB = c.Batch_NUMB
                                                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                AND c.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                AND c.EndValidity_DATE > @Ad_Run_DATE)))
                                       AND
                                       -- Excluding OSR Value_AMNT 
                                       a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND
                                       -- Excluding Void Reissue / Stop Reissue /  Reject EFT 
                                       NOT EXISTS (SELECT 1 
                                                     FROM DSBC_Y1 x,
                                                          DSBH_Y1 y
                                                    -- B current check number 
                                                    -- Y Old Check Number 
                                                    WHERE a.Disburse_DATE = x.Disburse_DATE
                                                      AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                      AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                                      AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                      AND y.Disburse_DATE = x.DisburseOrig_DATE
                                                      AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                                                      AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                                                      AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE
                                                      AND y.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                                                      AND y.EndValidity_DATE > @Ad_Run_DATE)
                                       AND NOT EXISTS (SELECT 1 
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
                                       AND EXISTS (SELECT 1 
                                                     FROM RCTH_Y1 c
                                                    WHERE a.Batch_DATE = c.Batch_DATE
                                                      AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                      AND a.Batch_NUMB = c.Batch_NUMB
                                                      AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                      AND c.BeginValidity_DATE < @Ad_Start_Run_DATE)) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Disbursed from Previous Collections
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_FROM_PREV-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'DBP' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(CAST(fci.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.Disburse_DATE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                         AND EXISTS (SELECT 1 
                                       FROM RCTR_Y1 c
                                      WHERE a.Batch_DATE = c.Batch_DATE
                                        AND a.Batch_NUMB = c.Batch_NUMB
                                        AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                        AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                        AND c.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                        AND c.EndValidity_DATE > @Ad_Run_DATE)))
               AND
               -- Excluding OSR Value_AMNT 
               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
               AND
               -- Excluding Void Reissue / Stop Reissue /  Reject EFT
               NOT EXISTS (SELECT 1 
                             FROM DSBC_Y1 x,
                                  DSBH_Y1 y
                            -- B current check number 
                            -- Y Old Check Number 
                            WHERE a.Disburse_DATE = x.Disburse_DATE
                              AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                              AND a.CheckRecipient_ID = x.CheckRecipient_ID
                              AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                              AND y.Disburse_DATE = x.DisburseOrig_DATE
                              AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                              AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                              AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE
                              AND y.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                              AND y.EndValidity_DATE > @Ad_Run_DATE)
               AND NOT EXISTS (SELECT 1 
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
               AND EXISTS (SELECT 1 
                             FROM RCTH_Y1 c
                            WHERE a.Batch_DATE = c.Batch_DATE
                              AND a.SourceBatch_CODE = c.SourceBatch_CODE
                              AND a.Batch_NUMB = c.Batch_NUMB
                              AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                              AND c.BeginValidity_DATE < @Ad_Start_Run_DATE)) AS fci);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_RELEASE FROM HOLD';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   -- Changed the Code RDH to DRH 
                   'DRH' AS TypeRecord_CODE,
                   ISNULL(CAST(a.CheckRecipient_ID AS VARCHAR), '') + ISNULL(a.CheckRecipient_CODE, '') + ISNULL(CAST(a.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(a.DisburseSeq_NUMB AS VARCHAR), '')AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.Disburse_DATE,
                                           b.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                                             OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                                                 AND EXISTS (SELECT 1 
                                                               FROM RCTR_Y1 c
                                                              WHERE a.Batch_DATE = c.Batch_DATE
                                                                AND a.Batch_NUMB = c.Batch_NUMB
                                                                AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                                AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                                                AND c.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                AND c.EndValidity_DATE > @Ad_Run_DATE)))
                                       AND
                                       -- Excluding OSR Value_AMNT 
                                       a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND
                                       -- Excluding Void Reissue / Stop Reissue /  Reject EFT
                                       NOT EXISTS (SELECT 1 
                                                     FROM DSBC_Y1 x,
                                                          DSBH_Y1 y
                                                    -- B current check number 
                                                    -- Y Old Check Number 
                                                    WHERE a.Disburse_DATE = x.Disburse_DATE
                                                      AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                      AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                                      AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                      AND y.Disburse_DATE = x.DisburseOrig_DATE
                                                      AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                                                      AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                                                      AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE
                                                      AND y.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                                                      AND y.EndValidity_DATE > @Ad_Run_DATE)
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
                                                      AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB)) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_RELEASE FROM HOLD-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           -- Changed the Code RDH to DRH 
           'DRH' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(fci.CheckRecipient_ID AS VARCHAR), '') + ISNULL(fci.CheckRecipient_CODE, '') + ISNULL(CAST(fci.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(fci.DisburseSeq_NUMB AS VARCHAR), '')) AS Count_QNTY,
           ISNULL(SUM(fci.Value_AMNT), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   a.Disburse_DATE,
                   b.Misc_ID,
                   a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.DisburseSeq_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND (a.SourceBatch_CODE NOT IN (@Lc_SourceBatchDCS_CODE)
                     OR (a.SourceBatch_CODE IN (@Lc_SourceBatchDCS_CODE)
                         AND EXISTS (SELECT 1 
                                       FROM RCTR_Y1 c
                                      WHERE a.Batch_DATE = c.Batch_DATE
                                        AND a.Batch_NUMB = c.Batch_NUMB
                                        AND a.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                        AND a.SourceBatch_CODE = c.SourceBatch_CODE
                                        AND c.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                        AND c.EndValidity_DATE > @Ad_Run_DATE)))
               AND
               -- Excluding OSR Value_AMNT 
               a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
               AND
               -- Excluding Void Reissue / Stop Reissue /  Reject EFT 
               NOT EXISTS (SELECT 1 
                             FROM DSBC_Y1 x,
                                  DSBH_Y1 y
                            -- B current check number 
                            -- Y Old Check Number 
                            WHERE a.Disburse_DATE = x.Disburse_DATE
                              AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                              AND a.CheckRecipient_ID = x.CheckRecipient_ID
                              AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                              AND y.Disburse_DATE = x.DisburseOrig_DATE
                              AND y.DisburseSeq_NUMB = x.DisburseOrigSeq_NUMB
                              AND y.CheckRecipient_ID = x.CheckRecipientOrig_ID
                              AND y.CheckRecipient_CODE = x.CheckRecipientOrig_CODE
                              AND y.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                              AND y.EndValidity_DATE > @Ad_Run_DATE)
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

   -- VOID RESISSUE / STOP REISSUE / REJECT EFT - DISBURSED -- STATEWISE
   SET @Ls_Sql_TEXT = 'DISB_CHKS_VDR_STR_RET-STATEWISE';
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
           ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE)
           END  AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   CASE e.Value_CODE
                    WHEN 'VR'
                     THEN 'VDR'
                    WHEN 'SR'
                     THEN 'STR'
                    WHEN 'RE'
                     THEN 'RET'
                   END AS TypeRecord_CODE,
                   ISNULL(CAST(d.CheckRecipient_ID AS VARCHAR), '') + ISNULL(d.CheckRecipient_CODE, '') + ISNULL(CAST(d.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(d.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(d.Value_AMNT, 0)) OVER(PARTITION BY d.TypeRecord_CODE) AS Value_AMNT,
                   @Lc_DummyCounty_NUMB AS County_IDNO
              FROM (SELECT r.Value_CODE
                      FROM REFM_Y1 r
                     WHERE r.Table_ID = @Lc_TableCHKS_IDNO
                       AND r.TableSub_ID = @Lc_TableCHKS_IDNO
                       AND r.Value_CODE IN ('VR', 'SR', 'RE')) AS e
                   LEFT OUTER JOIN (SELECT CASE
                                            WHEN d.SourceBatch_CODE = @Lc_SourceBatchDCS_CODE
                                             THEN 'VR'
                                            ELSE (-- To select one dsbc record when checks are combined into single check 
                                                 SELECT TOP 1 CASE c.StatusCheck_CODE
                                                               WHEN 'VN'
                                                                THEN 'VR'
                                                               WHEN 'SN'
                                                                THEN 'SR'
                                                               ELSE c.StatusCheck_CODE
                                                              END
                                                    FROM DSBC_Y1 b,
                                                         DSBH_Y1 c
                                                   WHERE a.Disburse_DATE = b.Disburse_DATE
                                                     AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                                     AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                                     AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                                     AND c.Disburse_DATE = b.DisburseOrig_DATE
                                                     AND c.DisburseSeq_NUMB = b.DisburseOrigSeq_NUMB
                                                     AND c.CheckRecipient_ID = b.CheckRecipientOrig_ID
                                                     AND c.CheckRecipient_CODE = b.CheckRecipientOrig_CODE
                                                     AND c.StatusCheck_CODE IN('VR', 'SR', 'RE', 'VN', 'SN')
                                                     AND c.EndValidity_DATE > @Ad_Run_DATE)
                                           END AS TypeRecord_CODE,
                                           a.Misc_ID,
                                           d.Disburse_AMNT AS Value_AMNT,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBH_Y1 a,
                                           DSBL_Y1 d
                                     -- A current check number 
                                     -- C Old Check Number 
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND
                                       -- Check the Status_CODE of last but previous record   
                                       a.EventGlobalBeginSeq_NUMB = (SELECT MAX(x.EventGlobalBeginSeq_NUMB) 
                                                                       FROM DSBH_Y1 x
                                                                      WHERE a.Disburse_DATE = x.Disburse_DATE
                                                                        AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                                        AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                                                        AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                                        AND x.BeginValidity_DATE <= @Ad_Run_DATE)
                                       AND a.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.Disburse_DATE = d.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                       AND a.CheckRecipient_ID = d.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = d.CheckRecipient_CODE
                                       AND
                                       -- Done for ACS receipts. - Start
                                       ((d.SourceBatch_CODE = @Lc_SourceBatchDCS_CODE
                                         AND NOT EXISTS (SELECT 1
                                                           FROM RCTR_Y1 b
                                                          WHERE d.Batch_DATE = b.Batch_DATE
                                                            AND d.Batch_NUMB = b.Batch_NUMB
                                                            AND d.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                            AND d.SourceBatch_CODE = b.SourceBatch_CODE
                                                            AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                            AND b.EndValidity_DATE > @Ad_Run_DATE))
                                         OR ((d.SourceBatch_CODE != @Lc_SourceBatchDCS_CODE)
                                              OR (d.SourceBatch_CODE = @Lc_SourceBatchDCS_CODE
                                                  AND EXISTS (SELECT 1
                                                                FROM RCTR_Y1 b
                                                               WHERE d.Batch_DATE = b.Batch_DATE
                                                                 AND d.Batch_NUMB = b.Batch_NUMB
                                                                 AND d.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                 AND d.SourceBatch_CODE = b.SourceBatch_CODE
                                                                 AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                 AND b.EndValidity_DATE > @Ad_Run_DATE))
                                                 AND EXISTS (SELECT 1
                                                               FROM DSBC_Y1 b,
                                                                    DSBH_Y1 c
                                                              WHERE a.Disburse_DATE = b.Disburse_DATE
                                                                AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                                                AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                                                AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                                                AND c.Disburse_DATE = b.DisburseOrig_DATE
                                                                AND c.DisburseSeq_NUMB = b.DisburseOrigSeq_NUMB
                                                                AND c.CheckRecipient_ID = b.CheckRecipientOrig_ID
                                                                AND c.CheckRecipient_CODE = b.CheckRecipientOrig_CODE
                                                                AND c.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                                                                AND c.EndValidity_DATE > @Ad_Run_DATE)))) AS d
                    -- Done for ACS receipts. - End
                    ON d.TypeRecord_CODE = e.Value_CODE) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- VOID RESISSUE / STOP REISSUE / REJECT EFT - DISBURSED -- COUNTYWISE 
   SET @Ls_Sql_TEXT = 'DISB_CHKS_VDR_STR_RET-COUNTYWISE';
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
           COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   CASE e.Value_CODE
                    WHEN 'VR'
                     THEN 'VDR'
                    WHEN 'SR'
                     THEN 'STR'
                    WHEN 'RE'
                     THEN 'RET'
                   END AS TypeRecord_CODE,
                   ISNULL(CAST(d.CheckRecipient_ID AS VARCHAR), '') + ISNULL(d.CheckRecipient_CODE, '') + ISNULL(CAST(d.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(d.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(d.Value_AMNT, 0)) OVER(PARTITION BY d.TypeRecord_CODE, e.County_IDNO) AS Value_AMNT,
                   e.County_IDNO AS County_IDNO
              FROM (SELECT r.Value_CODE,
                           c.County_IDNO
                      FROM REFM_Y1 r,
                           COPT_Y1 c
                     WHERE r.Table_ID = 'CHKS'
                       AND r.TableSub_ID = 'CHKS'
                       AND r.Value_CODE IN ('VR', 'SR', 'RE')) AS e
                   LEFT OUTER JOIN (SELECT CASE
                                            WHEN d.SourceBatch_CODE = @Lc_SourceBatchDCS_CODE
                                             THEN 'VR'
                                            ELSE (-- To select one dsbc record when checks are combined into single check 
                                                 SELECT TOP 1 CASE c.StatusCheck_CODE
                                                               WHEN 'VN'
                                                                THEN 'VR'
                                                               WHEN 'SN'
                                                                THEN 'SR'
                                                               ELSE c.StatusCheck_CODE
                                                              END
                                                    FROM DSBC_Y1 b,
                                                         DSBH_Y1 c
                                                   WHERE a.Disburse_DATE = b.Disburse_DATE
                                                     AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                                     AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                                     AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                                     AND c.Disburse_DATE = b.DisburseOrig_DATE
                                                     AND c.DisburseSeq_NUMB = b.DisburseOrigSeq_NUMB
                                                     AND c.CheckRecipient_ID = b.CheckRecipientOrig_ID
                                                     AND c.CheckRecipient_CODE = b.CheckRecipientOrig_CODE
                                                     AND c.StatusCheck_CODE IN('VR', 'SR', 'RE', 'VN', 'SN')
                                                     AND c.EndValidity_DATE > @Ad_Run_DATE)
                                           END AS TypeRecord_CODE,
                                           a.Misc_ID,
                                           a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           a.CheckRecipient_ID,
                                           d.CheckRecipient_CODE,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBH_Y1 a,
                                           DSBL_Y1 d,
                                           CASE_Y1 x
                                     -- A current check number 
                                     -- C Old Check Number
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND
                                       -- Check the Status_CODE of last but previous record   
                                       a.EventGlobalBeginSeq_NUMB = (SELECT MAX(x.EventGlobalBeginSeq_NUMB) 
                                                                       FROM DSBH_Y1 x
                                                                      WHERE a.Disburse_DATE = x.Disburse_DATE
                                                                        AND a.DisburseSeq_NUMB = x.DisburseSeq_NUMB
                                                                        AND a.CheckRecipient_ID = x.CheckRecipient_ID
                                                                        AND a.CheckRecipient_CODE = x.CheckRecipient_CODE
                                                                        AND x.BeginValidity_DATE <= @Ad_Run_DATE)
                                       AND a.EndValidity_DATE > @Ad_Run_DATE
                                       AND
                                       -- Done for ACS receipts. - Start
                                       ((d.SourceBatch_CODE = @Lc_SourceBatchDCS_CODE
                                         AND NOT EXISTS (SELECT 1
                                                           FROM RCTR_Y1 b
                                                          WHERE d.Batch_DATE = b.Batch_DATE
                                                            AND d.Batch_NUMB = b.Batch_NUMB
                                                            AND d.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                            AND d.SourceBatch_CODE = b.SourceBatch_CODE
                                                            AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                            AND b.EndValidity_DATE > @Ad_Run_DATE))
                                         OR ((d.SourceBatch_CODE != @Lc_SourceBatchDCS_CODE)
                                              OR (d.SourceBatch_CODE = @Lc_SourceBatchDCS_CODE
                                                  AND EXISTS (SELECT 1
                                                                FROM RCTR_Y1 b
                                                               WHERE d.Batch_DATE = b.Batch_DATE
                                                                 AND d.Batch_NUMB = b.Batch_NUMB
                                                                 AND d.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                 AND d.SourceBatch_CODE = b.SourceBatch_CODE
                                                                 AND b.BeginValidity_DATE <= @Ad_Start_Run_DATE
                                                                 AND b.EndValidity_DATE > @Ad_Run_DATE))
                                                 AND EXISTS (SELECT 1
                                                               FROM DSBC_Y1 b,
                                                                    DSBH_Y1 c
                                                              WHERE a.Disburse_DATE = b.Disburse_DATE
                                                                AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                                                AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                                                AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                                                AND c.Disburse_DATE = b.DisburseOrig_DATE
                                                                AND c.DisburseSeq_NUMB = b.DisburseOrigSeq_NUMB
                                                                AND c.CheckRecipient_ID = b.CheckRecipientOrig_ID
                                                                AND c.CheckRecipient_CODE = b.CheckRecipientOrig_CODE
                                                                AND c.StatusCheck_CODE IN ('VR', 'SR', 'RE', 'VN', 'SN')
                                                                AND c.EndValidity_DATE > @Ad_Run_DATE)))
                                       -- Done for ACS receipts. - End     
                                       AND a.Disburse_DATE = d.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                       AND a.CheckRecipient_ID = d.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = d.CheckRecipient_CODE
                                       AND d.Case_IDNO = x.Case_IDNO) AS d
                    ON d.County_IDNO = e.County_IDNO
                       AND d.TypeRecord_CODE = e.Value_CODE) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Djsbussement Prccessed  -- Total -- COUNTywise 
   SET @Ls_Sql_TEXT = 'DISB_PROC_TOTAL-COUNTYWISE';
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
           'TTL' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME = 'DISB-PROC'
       AND r.TypeRecord_CODE IN ('DBT', 'DBP',
                                        -- Changed the Code RDH to DRH
                                        'DRH', 'VDR',
                                        'STR', 'RET'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Placed on Disbursement Hold
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
          'DISB-PROC' AS Heading_NAME,
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

   -- New Held Disbursement Daily - COUNTYWISE 
   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_TDH-COUNTYWISE';
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
          'DISB-PROC' AS Heading_NAME,
          'TDH' AS TypeRecord_CODE,
          ISNULL(COUNT(a.Transaction_AMNT) OVER(PARTITION BY b.County_IDNO), 0) AS Count_QNTY,
          ISNULL(SUM(a.Transaction_AMNT) OVER(PARTITION BY b.County_IDNO), 0) AS Value_AMNT,
          b.County_IDNO AS County_IDNO
     FROM COPT_Y1 b
          LEFT OUTER JOIN (SELECT a.Transaction_AMNT,
                                  a.Case_IDNO,
                                  a.CheckRecipient_ID,
                                  x.County_IDNO
                             FROM DHLD_Y1 a,
                                  CASE_Y1 x
                            WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                              AND a.Transaction_AMNT > 0
                              AND a.EndValidity_DATE > @Ad_Run_DATE
                              AND a.Case_IDNO = x.Case_IDNO
                              AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
                              AND
                              -- Corrected this query to sync the Result_TEXT with DIHR 
                              NOT EXISTS (SELECT 1 
                                            FROM RCTH_Y1 b
                                           WHERE a.Batch_DATE = b.Batch_DATE
                                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                             AND a.Batch_NUMB = b.Batch_NUMB
                                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                             AND a.Transaction_DATE = b.BeginValidity_DATE
                                             AND b.BackOut_INDC = 'Y')
                              AND NOT EXISTS (SELECT 1 
                                                FROM DHLD_Y1 b
                                               WHERE a.Case_IDNO = b.Case_IDNO
                                                 AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                 AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                 AND a.Batch_DATE = b.Batch_DATE
                                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                 AND a.Batch_NUMB = b.Batch_NUMB
                                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                 AND (b.Status_CODE = @Lc_StatusReceiptHeld_CODE
                                                       OR (b.Status_CODE = @Lc_StatusReceiptRefund_CODE
                                                           AND b.TypeHold_CODE = 'C'))
                                                 AND b.TypeDisburse_CODE = a.TypeDisburse_CODE
                                                 AND b.EndValidity_DATE <= a.EndValidity_DATE
                                                 AND b.Transaction_AMNT = a.Transaction_AMNT
                                                 AND b.Transaction_DATE < a.Transaction_DATE
                                                 AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(d.EventGlobalBeginSeq_NUMB) 
                                                                                     FROM DHLD_Y1 d
                                                                                    WHERE d.Case_IDNO = a.Case_IDNO
                                                                                      AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                                                      AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                                                      AND d.Batch_DATE = a.Batch_DATE
                                                                                      AND d.SourceBatch_CODE = a.SourceBatch_CODE
                                                                                      AND d.Batch_NUMB = a.Batch_NUMB
                                                                                      AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                                                      AND d.TypeDisburse_CODE = a.TypeDisburse_CODE
                                                                                      AND d.EndValidity_DATE <= a.EndValidity_DATE
                                                                                      AND d.Transaction_AMNT = a.Transaction_AMNT
                                                                                      AND d.Transaction_DATE < a.Transaction_DATE)
                                                 AND NOT EXISTS (SELECT 1 
                                                                   FROM DSBL_Y1 b,
                                                                        DSBH_Y1  h
                                                                  WHERE a.Case_IDNO = b.Case_IDNO
                                                                    AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                                    AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                                    AND a.Batch_DATE = b.Batch_DATE
                                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                    AND a.TypeDisburse_CODE = b.TypeDisburse_CODE
                                                                    AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB
                                                                    AND a.EventGlobalBeginSeq_NUMB = h.EventGlobalBeginSeq_NUMB
                                                                    AND b.CheckRecipient_ID = h.CheckRecipient_ID
                                                                    AND b.CheckRecipient_CODE = h.CheckRecipient_CODE
                                                                    AND b.Disburse_DATE = h.Disburse_DATE
                                                                    AND b.DisburseSeq_NUMB = h.DisburseSeq_NUMB
                                                                    AND h.StatusCheck_CODE IN ('VN', 'SN', 'VR', 'SR', 'RE')
                                                                    AND h.StatusCheck_DATE = a.Transaction_DATE
                                                                    AND h.EndValidity_DATE > @Ad_Run_DATE))
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
                                                  AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB))) AS a
           ON a.County_IDNO = b.County_IDNO;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_ALL_HOLD_TDH-STATEWISE';
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
          'DISB-PROC' AS Heading_NAME,
          'TDH' AS TypeRecord_CODE,
          COUNT(fci.Transaction_AMNT) AS Count_QNTY,
          ISNULL(SUM(fci.Transaction_AMNT), 0) AS Value_AMNT,
          @Lc_DummyCounty_NUMB AS County_IDNO
     FROM (SELECT a.Transaction_AMNT,
                  a.Case_IDNO,
                  a.CheckRecipient_ID
             FROM DHLD_Y1 a
            WHERE a.Transaction_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.Transaction_AMNT > 0
              AND a.EndValidity_DATE > @Ad_Run_DATE
              AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
              AND
              -- Corrected this query to sync the Result_TEXT with DIHR 
              NOT EXISTS (SELECT 1 
                            FROM RCTH_Y1 b
                           WHERE a.Batch_DATE = b.Batch_DATE
                             AND a.SourceBatch_CODE = b.SourceBatch_CODE
                             AND a.Batch_NUMB = b.Batch_NUMB
                             AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND a.Transaction_DATE = b.BeginValidity_DATE
                             AND b.BackOut_INDC = 'Y')
              AND NOT EXISTS (SELECT 1 
                                FROM DHLD_Y1 b
                               WHERE a.Case_IDNO = b.Case_IDNO
                                 AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                 AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                 AND a.Batch_DATE = b.Batch_DATE
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                 AND a.Batch_NUMB = b.Batch_NUMB
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND (b.Status_CODE = @Lc_StatusReceiptHeld_CODE
                                       OR (b.Status_CODE = @Lc_StatusReceiptRefund_CODE
                                           AND b.TypeHold_CODE = 'C'))
                                 AND b.TypeDisburse_CODE = a.TypeDisburse_CODE
                                 AND b.EndValidity_DATE <= a.EndValidity_DATE
                                 AND b.Transaction_AMNT = a.Transaction_AMNT
                                 AND b.Transaction_DATE < a.Transaction_DATE
                                 AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX(d.EventGlobalBeginSeq_NUMB) 
                                                                     FROM DHLD_Y1 d
                                                                    WHERE d.Case_IDNO = a.Case_IDNO
                                                                      AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                                      AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                                      AND d.Batch_DATE = a.Batch_DATE
                                                                      AND d.SourceBatch_CODE = a.SourceBatch_CODE
                                                                      AND d.Batch_NUMB = a.Batch_NUMB
                                                                      AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                                      AND d.TypeDisburse_CODE = a.TypeDisburse_CODE
                                                                      AND d.EndValidity_DATE <= a.EndValidity_DATE
                                                                      AND d.Transaction_AMNT = a.Transaction_AMNT
                                                                      AND d.Transaction_DATE < a.Transaction_DATE)
                                 AND NOT EXISTS (SELECT 1 
                                                   FROM DSBL_Y1 b,
                                                        DSBH_Y1  h
                                                  WHERE a.Case_IDNO = b.Case_IDNO
                                                    AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                    AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                    AND a.Batch_DATE = b.Batch_DATE
                                                    AND a.SourceBatch_CODE = b.SourceBatch_CODE
                                                    AND a.Batch_NUMB = b.Batch_NUMB
                                                    AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                    AND a.TypeDisburse_CODE = b.TypeDisburse_CODE
                                                    AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSupportSeq_NUMB
                                                    AND a.EventGlobalBeginSeq_NUMB = h.EventGlobalBeginSeq_NUMB
                                                    AND b.CheckRecipient_ID = h.CheckRecipient_ID
                                                    AND b.CheckRecipient_CODE = h.CheckRecipient_CODE
                                                    AND b.Disburse_DATE = h.Disburse_DATE
                                                    AND b.DisburseSeq_NUMB = h.DisburseSeq_NUMB
                                                    AND h.StatusCheck_CODE IN ('VN', 'SN', 'VR', 'SR', 'RE')
                                                    AND h.StatusCheck_DATE = a.Transaction_DATE
                                                    AND h.EndValidity_DATE > @Ad_Run_DATE))
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
                                  AND a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB))) AS fci;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Change the OSR COUNT 
   SET @Ls_Sql_TEXT = 'DISB_PROCESS_OSR';
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
           COUNT(z.Count_QNTY) OVER() AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-PROC' AS Heading_NAME,
                   'OSR' AS TypeRecord_CODE,
                   ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '') AS Count_QNTY,
                   SUM(ISNULL(a.Value_AMNT, 0)) OVER(PARTITION BY b.County_IDNO) AS Value_AMNT,
                   b.County_IDNO
              FROM COPT_Y1 b
                   LEFT OUTER JOIN (SELECT a.Disburse_AMNT AS Value_AMNT,
                                           x.County_IDNO,
                                           b.Misc_ID,
                                           a.Disburse_DATE,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.DisburseSeq_NUMB,
                                           a.Batch_DATE,
                                           a.Batch_NUMB,
                                           a.SeqReceipt_NUMB,
                                           a.SourceBatch_CODE
                                      FROM DSBL_Y1 a,
                                           CASE_Y1 x,
                                           DSBH_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.Batch_DATE != @Ld_Low_DATE
                                       AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND b.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.Case_IDNO = x.Case_IDNO
                                       AND a.CheckRecipient_ID = @Lc_CheckRecipientOSR_ID) AS a
                    ON a.County_IDNO = b.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_PROCESS_OSR-STATEWISE';
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
           'DISB-PROC' AS Heading_NAME,
           'OSR' AS TypeRecord_CODE,
           COUNT(DISTINCT ISNULL(CAST(a.Batch_DATE AS VARCHAR), '') + ISNULL(CAST(a.Batch_NUMB AS VARCHAR), '') + ISNULL(CAST(a.SeqReceipt_NUMB AS VARCHAR), '') + ISNULL(a.SourceBatch_CODE, '')) AS Count_QNTY,
           ISNULL(SUM(CAST(a.Value_AMNT AS FLOAT)), 0) AS Value_AMNT,
           @Lc_DummyCounty_NUMB AS County_IDNO
      FROM (SELECT a.Disburse_AMNT AS Value_AMNT,
                   b.Misc_ID,
                   a.Disburse_DATE,
                   a.CheckRecipient_ID,
                   a.CheckRecipient_CODE,
                   a.DisburseSeq_NUMB,
                   a.Batch_DATE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.SourceBatch_CODE
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND a.Batch_DATE != @Ld_Low_DATE
               AND b.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
               AND b.EndValidity_DATE > @Ad_Run_DATE
               AND a.CheckRecipient_ID = b.CheckRecipient_ID
               AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
               AND a.Disburse_DATE = b.Disburse_DATE
               AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
               AND a.CheckRecipient_ID = @Lc_CheckRecipientOSR_ID) AS a);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

	-- To  Calculate Fee details
   SET @Ls_Sql_TEXT = 'DISB_PROCESS FEE RECOVERY';
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
           'DISB-PROC' AS Heading_NAME,
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
    
   SET @Ls_Sql_TEXT = 'DISB-PROC - FEE SUB TOTAL ';
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
      AND a.Heading_NAME = 'DISB-PROC'
      AND a.TypeRecord_CODE IN ('DRF', 'SCF', 'NSF','NCF', 'GTF');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END
   --------------------------------------Disbursement Generated --------------------------------
   SET @Ls_Sql_TEXT = 'CHECK_NUMBER';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   SELECT @Lc_BegCheck_NUMB = CAST(ISNULL(MIN(fci.Check_NUMB), 0) AS VARCHAR),
          @Lc_EndCheck_NUMB = CAST(ISNULL(MAX(fci.Check_NUMB), '999') AS VARCHAR)
     FROM (SELECT a.Check_NUMB
             FROM DSBH_Y1 a
            WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
              AND a.EndValidity_DATE > @Ad_Run_DATE) AS fci
    WHERE fci.Check_NUMB IS NOT NULL
      AND fci.Check_NUMB != 0;

   SET @Ls_Sql_TEXT = 'DISB_GEN1';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Heading_NAME = ' + ISNULL('DISB-GENR','')+ ', TypeRecord_CODE = ' + ISNULL('BEGCK','')+ ', Count_QNTY = ' + ISNULL(@Lc_BegCheck_NUMB,'')+ ', Value_AMNT = ' + ISNULL('0','')+ ', County_IDNO = ' + ISNULL(@Lc_DummyCounty_NUMB,'');

   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
  VALUES ( @Ad_Run_DATE,   --Generate_DATE
            'DISB-GENR',   --Heading_NAME
            'BEGCK',   --TypeRecord_CODE
            @Lc_BegCheck_NUMB,   --Count_QNTY
            0,   --Value_AMNT
            @Lc_DummyCounty_NUMB  --County_IDNO
);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DISB_GEN2';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   VALUES ( @Ad_Run_DATE,   --Generate_DATE
            'DISB-GENR',   --Heading_NAME
            'ENDCK',   --TypeRecord_CODE
            @Lc_EndCheck_NUMB,   --Count_QNTY
            0,   --Value_AMNT
            @Lc_DummyCounty_NUMB  --County_IDNO
);
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Populates the whole list of Disbursement Genereated Table -- County Wise
   SET @Ls_Sql_TEXT = 'DISB_GEN_TABLE';
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
           ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) 
           END AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   CASE
                    WHEN g.TypeRecord_CODE IN ('DIR', 'SVC', 'EFT', 'EFF')
                     THEN 'DISB-GENR'
                    ELSE 'DISB-GENR-CHK'
                   END AS Heading_NAME,
                   g.TypeRecord_CODE,
                   ISNULL(CAST(d.CheckRecipient_ID AS VARCHAR), '') + ISNULL(d.CheckRecipient_CODE, '') + ISNULL(CAST(d.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(d.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(d.Value_AMNT, 0)) OVER(PARTITION BY d.TypeRecord_CODE, d.County_IDNO) AS Value_AMNT,
                   g.County_IDNO
              FROM (SELECT r.Value_CODE AS TypeRecord_CODE,
                           c.County_IDNO
                      FROM REFM_Y1 r,
                           COPT_Y1 c
                     WHERE r.Table_ID = @Lc_TableFINS_IDNO
                       AND r.TableSub_ID = @Lc_TableSubDISB_ID) AS g
                   LEFT OUTER JOIN (SELECT CASE
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseFipsEft_CODE
                                             THEN 'DIR'
                                            -- Direct Deposit
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseFipsEft_CODE
                                             THEN 'EFF'
                                            -- Electronic Fund Transfer - FIPS
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseFipsEft_CODE
                                             THEN 'EFT'
                                            -- Electronic Fund Transfer - Agency
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseSVC_CODE
                                             THEN 'SVC'
                                            -- Store Value Card
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                             THEN 'CHK'
                                            -- CP -- Check
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                             THEN 'CHQ'
                                            -- FIPS -- Check
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                                 AND a.CheckRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'CHA'
                                            -- Agencies Check 
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                             THEN 'FPI'
                                            -- Refund to FIPS Identified
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseOthp_CODE
                                             THEN 'FPU'
                                            -- Refund to FIPS  Unidentified
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                                 AND NOT EXISTS (SELECT 1
                                                                   FROM RCTH_Y1 r
                                                                  WHERE r.Batch_DATE = b.Batch_DATE
                                                                    AND r.SourceBatch_CODE = b.SourceBatch_CODE
                                                                    AND r.Batch_NUMB = b.Batch_NUMB
                                                                    AND r.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                    AND r.SourceReceipt_CODE IN ('CR', 'CF')
                                                                    AND r.EndValidity_DATE = @Ld_High_DATE)
                                             THEN 'NCP'
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                                 AND EXISTS (SELECT 1
                                                               FROM RCTH_Y1 r
                                                              WHERE r.Batch_DATE = b.Batch_DATE
                                                                AND r.SourceBatch_CODE = b.SourceBatch_CODE
                                                                AND r.Batch_NUMB = b.Batch_NUMB
                                                                AND r.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                AND r.SourceReceipt_CODE IN ('CR', 'CF')
                                                                AND r.EndValidity_DATE = @Ld_High_DATE)
                                             THEN 'CCP'
                                            -- Refund to NCP Identified
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 --land
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseOthp_CODE
                                                 --AND a.CheckRecipient_ID NOT LIKE @Lc_RefundRecipientOfficeIVA_ID
                                                 AND a.CheckRecipient_ID NOT IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'OTU'
                                            -- Refund to Other party Unidentified
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                                 AND a.CheckRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'OFI'
                                            -- Refund to county identified
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseOthp_CODE
                                                 AND a.CheckRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'OFU'
                                            -- Refund to county Unidentified
                                            ELSE 'OTH'
                                           END AS TypeRecord_CODE,
                                           b.Disburse_AMNT AS Value_AMNT,
                                           c.County_IDNO,
                                           a.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBH_Y1 a,
                                           DSBL_Y1 b,
                                           CASE_Y1 c
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND
                                       -- Excluding OSR Value_AMNT 
                                       a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND b.Case_IDNO = c.Case_IDNO) AS d
                    ON d.TypeRecord_CODE = g.TypeRecord_CODE
                       AND d.County_IDNO = g.County_IDNO) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- Populates the whole list of Disbursement Genereated Table -- Statewise
   SET @Ls_Sql_TEXT = 'DISB_GEN_TABLE-STATEWISE';
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
           ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) 
           END AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   CASE
                    WHEN g.TypeRecord_CODE IN ('DIR', 'SVC', 'EFT', 'EFF')
                     THEN 'DISB-GENR'
                    ELSE 'DISB-GENR-CHK'
                   END AS Heading_NAME,
                   g.TypeRecord_CODE,
                   -- Considering the key fields instead of Misc_ID
                   ISNULL(CAST(d.CheckRecipient_ID AS VARCHAR), '') + ISNULL(d.CheckRecipient_CODE, '') + ISNULL(CAST(d.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(d.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(d.Value_AMNT, 0)) OVER(PARTITION BY d.TypeRecord_CODE) AS Value_AMNT,
                   @Lc_DummyCounty_NUMB AS County_IDNO
              FROM (SELECT r.Value_CODE AS TypeRecord_CODE
                      FROM REFM_Y1 r
                     WHERE r.Table_ID = @Lc_TableFINS_IDNO
                       AND r.TableSub_ID = @Lc_TableSubDISB_ID) AS g
                   LEFT OUTER JOIN (SELECT CASE
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseFipsEft_CODE
                                             THEN 'DIR'
                                            -- Direct Deposit
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseFipsEft_CODE
                                             THEN 'EFF'
                                            -- Electronic Fund Transfer - FIPS
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseFipsEft_CODE
                                             THEN 'EFT'
                                            -- Electronic Fund Transfer - Agency
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseSVC_CODE
                                             THEN 'SVC'
                                            -- Store Value Card
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                             THEN 'CHK'
                                            -- CP -- Check
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                             THEN 'CHQ'
                                            -- FIPS -- Check
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseOthp_CODE)
                                                 AND a.CheckRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'CHA'
                                            -- Agencies Check 
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                             THEN 'FPI'
                                            -- Refund to FIPS Identified
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientFIPS_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseOthp_CODE
                                             THEN 'FPU'
                                            -- Refund to FIPS  Unidentified
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                                 AND NOT EXISTS (SELECT 1
                                                                   FROM RCTH_Y1 r
                                                                  WHERE r.Batch_DATE = b.Batch_DATE
                                                                    AND r.SourceBatch_CODE = b.SourceBatch_CODE
                                                                    AND r.Batch_NUMB = b.Batch_NUMB
                                                                    AND r.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                    AND r.SourceReceipt_CODE IN ('CR', 'CF')
                                                                    AND r.EndValidity_DATE = @Ld_High_DATE)
                                             THEN 'NCP'
                                            -- Refund to Other party Identified
                                            WHEN a.CheckRecipient_CODE = @Lc_FundRecipientCpNcp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                                 AND EXISTS (SELECT 1
                                                               FROM RCTH_Y1 r
                                                              WHERE r.Batch_DATE = b.Batch_DATE
                                                                AND r.SourceBatch_CODE = b.SourceBatch_CODE
                                                                AND r.Batch_NUMB = b.Batch_NUMB
                                                                AND r.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                                                AND r.SourceReceipt_CODE IN ('CR', 'CF')
                                                                AND r.EndValidity_DATE = @Ld_High_DATE)
                                             THEN 'CCP'
                                            -- Refund to Other party Identified   
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseOthp_CODE
                                                 AND a.CheckRecipient_ID NOT IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'OTU'
                                            -- Refund to Other party Unidentified
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                                                 AND a.CheckRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'OFI'
                                            -- Refund to COUNTy identified
                                            WHEN a.CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
                                                 AND a.MediumDisburse_CODE = @Lc_MediumDisburseCpCheck_CODE
                                                 AND b.TypeDisburse_CODE = @Lc_TypeDisburseOthp_CODE
                                                 AND a.CheckRecipient_ID IN (@Lc_RefundRecipientOfficeIVA_ID,@Lc_RefundRecipientOfficeIVE_ID,@Lc_CheckRecipientTreasury_ID, @Lc_CheckRecipientMEDI_ID)
                                             THEN 'OFU'
                                            -- Refund to county Unidentified
                                            ELSE 'OTH'
                                           END AS TypeRecord_CODE,
                                           b.Disburse_AMNT AS Value_AMNT,
                                           a.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBH_Y1 a,
                                           DSBL_Y1 b
                                     WHERE a.Disburse_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.EndValidity_DATE > @Ad_Run_DATE
                                       AND a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND
                                       -- Excluding OSR Value_AMNT 
                                       a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)) AS d
                    ON d.TypeRecord_CODE = g.TypeRecord_CODE) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- TOTAL DISBURSEMENT GENERATED TODAY -- COUNTywise
   SET @Ls_Sql_TEXT = 'DISB_GENERATED_TODAY_TOTAL-COUNTYWISE';
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
           'DISB-GENR' AS Heading_NAME,
           'TDG' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME LIKE 'DISB-GENR%'
       AND r.TypeRecord_CODE NOT IN ('BEGCK', 'ENDCK'));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --  Disbursement Generated -- CHECK - Sub Total 
   SET @Ls_Sql_TEXT = 'DISB_GENERATED_CHECK_SUBTOTAL';
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
           'DISB-GENR-CHK' AS Heading_NAME,
           'STL' AS TypeRecord_CODE,
           SUM(r.Count_QNTY) OVER(PARTITION BY r.County_IDNO) AS Count_QNTY,
           SUM(r.Value_AMNT) OVER(PARTITION BY r.County_IDNO) AS Value_AMNT,
           r.County_IDNO
      FROM RFINS_Y1 r
     WHERE r.Generate_DATE = @Ad_Run_DATE
       AND r.Heading_NAME = 'DISB-GENR-CHK');

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- CHECK / EFT / STORED VALUE CARD DAILY ACTIVITY
   SET @Ls_Sql_TEXT = 'DISB_CHKS_ALL_CHECK_STATUS';
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
           ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) END 
           AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-ACTY' AS Heading_NAME,
                   e.Value_CODE AS TypeRecord_CODE,
                   ISNULL(CAST(d.CheckRecipient_ID AS VARCHAR), '') + ISNULL(d.CheckRecipient_CODE, '') + ISNULL(CAST(d.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(d.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(d.Value_AMNT, 0)) OVER(PARTITION BY d.TypeRecord_CODE, e.County_IDNO) AS Value_AMNT,
                   e.County_IDNO
              FROM (SELECT r.Value_CODE,
                           c.County_IDNO
                      FROM REFM_Y1 r,
                           COPT_Y1 c
                     WHERE r.Table_ID = @Lc_TableCHKS_IDNO
                       AND r.TableSub_ID = @Lc_TableCHKS_IDNO) AS e
                   LEFT OUTER JOIN (SELECT b.Disburse_AMNT AS Value_AMNT,
                                           a.StatusCheck_CODE AS TypeRecord_CODE,
                                           c.County_IDNO,
                                           a.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBH_Y1 a,
                                           DSBL_Y1 b,
                                           CASE_Y1 c
                                     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND b.Case_IDNO = c.Case_IDNO
                                       AND a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND a.EndValidity_DATE > @Ad_Run_DATE
                                       AND
                                       -- Check if the Status_CODE is Changed from previous one 
                                       NOT EXISTS (SELECT 1 
                                                     FROM DSBH_Y1 c
                                                    WHERE a.CheckRecipient_ID = c.CheckRecipient_ID
                                                      AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                                                      AND a.Disburse_DATE = c.Disburse_DATE
                                                      AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
                                                      AND a.StatusCheck_CODE = c.StatusCheck_CODE
                                                      AND c.EventGlobalEndSeq_NUMB = a.EventGlobalBeginSeq_NUMB)) AS d
                    ON d.County_IDNO = e.County_IDNO
                       AND d.TypeRecord_CODE = e.Value_CODE) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   -- CHECK / EFT / STORED VALUE CARD DAILY ACTIVITY
   SET @Ls_Sql_TEXT = 'DISB_CHKS_ALL_CHECK_STATUS-STATEWISE';
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
		   'DISB-ACTY' AS Heading_NAME,
           z.TypeRecord_CODE,
           CASE z.Value_AMNT
           WHEN 0 THEN 0
           ELSE COUNT(z.Count_QNTY) OVER(PARTITION BY z.TypeRecord_CODE) END 
           AS Count_QNTY,
           z.Value_AMNT,
           z.County_IDNO
      FROM (SELECT DISTINCT
                   @Ad_Run_DATE AS Generate_DATE,
                   'DISB-ACTY' AS Heading_NAME,
                   e.Value_CODE AS TypeRecord_CODE,
                   ISNULL(CAST(d.CheckRecipient_ID AS VARCHAR), '') + ISNULL(d.CheckRecipient_CODE, '') + ISNULL(CAST(d.Disburse_DATE AS VARCHAR), '') + ISNULL(CAST(d.DisburseSeq_NUMB AS VARCHAR), '') AS Count_QNTY,
                   SUM(ISNULL(d.Value_AMNT, 0)) OVER(PARTITION BY d.TypeRecord_CODE) AS Value_AMNT,
                   @Lc_DummyCounty_NUMB AS County_IDNO
              FROM (SELECT r.Value_CODE
                      FROM REFM_Y1 r
                     WHERE r.Table_ID = @Lc_TableCHKS_IDNO
                       AND r.TableSub_ID = @Lc_TableCHKS_IDNO) AS e
                   LEFT OUTER JOIN (SELECT b.Disburse_AMNT AS Value_AMNT,
                                           a.StatusCheck_CODE AS TypeRecord_CODE,
                                           a.Misc_ID,
                                           a.CheckRecipient_ID,
                                           a.CheckRecipient_CODE,
                                           a.Disburse_DATE,
                                           a.DisburseSeq_NUMB
                                      FROM DSBH_Y1 a,
                                           DSBL_Y1 b
                                     WHERE a.BeginValidity_DATE BETWEEN @Ad_Start_Run_DATE AND @Ad_Run_DATE
                                       AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                       AND a.Disburse_DATE = b.Disburse_DATE
                                       AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                       AND a.CheckRecipient_ID NOT IN (@Lc_CheckRecipientOSR_ID ,@Lc_CheckRecipientDra_ID,@Lc_CheckRecipientSpc_ID,@Lc_CheckRecipientCpNsf_ID,@Lc_CheckRecipientNcpNsf_ID,@Lc_CheckRecipientGt_ID)
                                       AND a.EndValidity_DATE > @Ad_Run_DATE
                                       AND
                                       -- Check if the Status_CODE is Changed from previous one                   
                                       NOT EXISTS (SELECT 1 
                                                     FROM DSBH_Y1 c
                                                    WHERE a.CheckRecipient_ID = c.CheckRecipient_ID
                                                      AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                                                      AND a.Disburse_DATE = c.Disburse_DATE
                                                      AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
                                                      AND a.StatusCheck_CODE = c.StatusCheck_CODE
                                                      AND c.EventGlobalEndSeq_NUMB = a.EventGlobalBeginSeq_NUMB)) AS d
                    ON d.TypeRecord_CODE = e.Value_CODE) AS z);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');

     RAISERROR(50001,16,1);
    END

   --------------------------------------------------------------------------------
   --      FINS REPORT -- OVERALL SUMMARY TAB  CALCULATION                       --
   --------------------------------------------------------------------------------
   -- To get the precalculated value
   SET @Ls_Sql_TEXT = 'ASSIGN PRE-CALCULATED VALUES - OVER ALL SUMMARY ';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Start_Run_DATE = ' + ISNULL(CAST(@Ad_Start_Run_DATE AS VARCHAR), '');
   INSERT RFINS_Y1
          (Generate_DATE,
           Heading_NAME,
           TypeRecord_CODE,
           Count_QNTY,
           Value_AMNT,
           County_IDNO)
   SELECT DISTINCT
          z.Generate_DATE,
          z.Heading_NAME,
          z.TypeRecord_CODE,
          CASE z.Value_AMNT 
          WHEN 0 THEN 0
          ELSE SUM(z.Count_QNTY) OVER (PARTITION BY z.Heading_NAME, z.TypeRecord_CODE) 
          END AS Count_QNTY,
          z.Value_AMNT,
          z.County_IDNO
     FROM (SELECT DISTINCT
                  a.Generate_DATE,
                  'SUMRY-OVER' AS Heading_NAME,
                  a.TypeRecord_CODE,
                  CASE
                   WHEN (a.Heading_NAME LIKE 'DISB%')
                    THEN (SELECT DISTINCT
                                 a.Count_QNTY)
                   ELSE a.Count_QNTY
                  END AS Count_QNTY,
                  SUM(a.Value_AMNT) OVER(PARTITION BY a.Heading_NAME, a.TypeRecord_CODE) AS Value_AMNT,
                  @Lc_DummyCounty_NUMB AS County_IDNO
             FROM RFINS_Y1 a
            WHERE a.Generate_DATE = @Ad_Run_DATE
              AND a.County_IDNO = @Lc_DummyCounty_NUMB
              AND ((a.Heading_NAME = 'DIST-PROC-PREV-REF'
                    AND a.TypeRecord_CODE = 'RFP')
                    OR (a.Heading_NAME = 'DIST-PROC-TOD-REF'
                        AND a.TypeRecord_CODE = 'RFT')
                    OR
                   -- refund to NCP/OTHP/FIPS/COUNTY from previous collections
                   (a.Heading_NAME = 'DIST-PROC-TOD'
                    AND a.TypeRecord_CODE = 'DTT')
                    OR
                   -- distributed from daily collections
                   (a.Heading_NAME = 'DIST-PROC-PREV'
                    AND a.TypeRecord_CODE = 'DTP')
                    OR (a.Heading_NAME = 'DISB-PROC'
                        AND
                        --distributed from previous collections
                        a.TypeRecord_CODE = 'DED'
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    OR (a.Heading_NAME = 'DISB-GENR'
                        AND
                        -- Disbursement Processed
                        a.TypeRecord_CODE = 'TDG'
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    OR
                   -- Total Disbursement Generated  
                   -- Including "VOID REISSUE" "STOP REISSUE" "REJECTED EFT"
                   -- Changed the Code RDH to DRH 
                   (a.Heading_NAME = 'DISB-PROC'
                    AND a.TypeRecord_CODE IN ('VDR', 'STR', 'RET', 'DRH'))
                    -- Release From Disbursement Hold
                    OR (a.Heading_NAME = 'DISB-PROC'
                        AND a.TypeRecord_CODE = 'ES')
                    -- Escheatment
                    OR (a.Heading_NAME = 'DISB-GENR'
                        AND a.TypeRecord_CODE = 'DIR'
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    -- Direct Deposit
                    OR (a.Heading_NAME = 'DISB-GENR'
                        AND a.TypeRecord_CODE IN ('EFT', 'EFF')
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    -- Electronic Fund Transfer
                    OR (a.Heading_NAME = 'DISB-GENR'
                        AND a.TypeRecord_CODE = 'SVC'
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    OR (-- Stored Value Card
                       a.Heading_NAME = 'DISB-GENR-CHK'
                       AND a.TypeRecord_CODE IN ('CHK', 'CHQ', 'CHA', 'FPI',
                                                 'FPU', 'NCP',
                                                 'CCP', 'OTU',
                                                 'OFI', 'OFU')
                       AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    -- Checks 
                    OR (a.Heading_NAME = 'DISB-PROC'
                        AND a.TypeRecord_CODE = 'DBT')
                    -- Disbursement From Daily Collections
                    OR (a.Heading_NAME = 'DISB-PROC'
                        AND a.TypeRecord_CODE = 'DBP')
                    -- Disbursement From Previous Collections
                    OR (a.Heading_NAME = 'DIST-DISB-TOD'
                        AND a.TypeRecord_CODE = 'DHT'
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    -- From Daily Collection
                    OR (a.Heading_NAME = 'DIST-DISB-PREV'
                        AND a.TypeRecord_CODE = 'DHP'
                        AND a.County_IDNO = @Lc_DummyCounty_NUMB)
                    -- From Previous Collection
                    OR (a.Heading_NAME = 'DISB-PROC'
                        AND a.TypeRecord_CODE = 'OSR')
                        -- Interstate Cost Recovery  
                    OR (a.Heading_NAME = 'DISB-PROC'
                        AND a.TypeRecord_CODE = 'FER')
                        -- Fee recovery
                    
                  )) AS z;

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
