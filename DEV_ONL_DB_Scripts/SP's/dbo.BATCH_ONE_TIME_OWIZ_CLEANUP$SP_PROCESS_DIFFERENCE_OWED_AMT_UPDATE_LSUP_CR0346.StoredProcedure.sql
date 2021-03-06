/****** Object:  StoredProcedure [dbo].[BATCH_ONE_TIME_OWIZ_CLEANUP$SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ONE_TIME_OWIZ_CLEANUP$SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346
Programmer Name 	: IMP Team
Description			: The procedure BATCH_ONE_TIME_OWIZ_CLEANUP$SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346 takes data 
					 (Prorated amount for 30067 obligations) from the ProratedOwedAmt_T1 and insert into LSUP table.
Frequency			: ONE_TIME
Developed On		: 11/07/2013
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ONE_TIME_OWIZ_CLEANUP$SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346]
 @An_Case_IDNO                  NUMERIC(6),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @Ad_ObligationEnd_DATE         DATE,
 @Ad_Run_DATE					DATE,
 @Ac_Msg_CODE					CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT		VARCHAR(4000) OUTPUT
 
AS
 BEGIN
 
  SET NOCOUNT ON;
  
  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_TypeErrorE_CODE        CHAR(1) = 'E',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ErrorE1424_CODE        CHAR(5) = 'E1424',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ONE_TIME_OWIZ_CLEANUP',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_PROCESS_DIFFERENCE_OWED_AMT_UPDATE_LSUP_CR0346';
  DECLARE @Ln_SupportYearMonth_NUMB		  NUMERIC(6) = 0,	
		  @Ln_SupportYearMonthPrevious_NUMB NUMERIC(6) = 201312,
	      @Ln_SupportYearMonthNew_NUMB	  NUMERIC(6) = 201401,
          @Ln_RecordCount_QNTY			  NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
		  @Ln_Defect12879_UpdatedProratedOwed_AMNT  NUMERIC (11,2) = 0,
		  @Ln_Difference_AMNT			  NUMERIC (11,2) = 0,
          @Ln_TransactionCurSup_AMNT      NUMERIC (11,2) = 0,
          @Ln_MtdCurSupOwed_AMNT_AMNT     NUMERIC (11,2) = 0,
          @Ln_TransactionNaa_AMNT         NUMERIC (11,2) = 0,
          @Ln_TransactionPaa_AMNT         NUMERIC (11,2) = 0,
          @Ln_TransactionUda_AMNT         NUMERIC (11,2) = 0,
          @Ln_TransactionIvef_AMNT        NUMERIC (11,2) = 0,
          @Ln_TransactionNffc_AMNT        NUMERIC (11,2) = 0,
          @Ln_TransactionNonIvd_AMNT      NUMERIC (11,2) = 0,
          @Ln_TransactionMedi_AMNT        NUMERIC (11,2) = 0, 
          @Ln_Naa_BucketArrear_AMNT       NUMERIC (11,2) = 0,
          @Ln_Paa_BucketArrear_AMNT       NUMERIC (11,2) = 0,
          @Ln_Uda_BucketArrear_AMNT       NUMERIC (11,2) = 0,
          @Ln_Ivef_BucketArrear_AMNT      NUMERIC (11,2) = 0,
          @Ln_Nffc_BucketArrear_AMNT      NUMERIC (11,2) = 0,
          @Ln_NonIvd_BucketArrear_AMNT    NUMERIC (11,2) = 0,
          @Ln_Medi_BucketArrear_AMNT      NUMERIC (11,2) = 0,                    
          @Li_Rowcount_QNTY               SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Bucket_NAME				  CHAR(4),
          @Lc_Defect12879_Adjust_Bucket_NAME CHAR(4),	
          @Lc_BateError_CODE              CHAR(18),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
	
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = ' ';
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   -- UNKNOWN EXCEPTION IN BATCH
   SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
   SET @Ln_Difference_AMNT = 0;
   SET @Lc_Bucket_NAME = '';
   
	IF @Ad_ObligationEnd_DATE = '12/31/2013'
	BEGIN
		SET @Ln_SupportYearMonthPrevious_NUMB = 201312;
		SET @Ln_SupportYearMonthNew_NUMB = 201401;
	END
	ELSE IF @Ad_ObligationEnd_DATE = '01/31/2014'
	BEGIN
		SET @Ln_SupportYearMonthPrevious_NUMB = 201401;
		SET @Ln_SupportYearMonthNew_NUMB = 201402;
	END
	ELSE IF @Ad_ObligationEnd_DATE = '02/28/2014'
	BEGIN
		SET @Ln_SupportYearMonthPrevious_NUMB = 201402;
		SET @Ln_SupportYearMonthNew_NUMB = 201403;
	END
	ELSE
	BEGIN
		SET @Ls_ErrorMessage_TEXT = 'Obligation End is not in 12/31/2013, 01/31/2014, 02/28/2014';
		RAISERROR (50001,16,1);
	END
   
    -- Difference Amount between Defect1287 Adjusted Prorated Owed Amount and OWIZ Script LSUP Prorated Negative Amount Update Section - Start -- 
	SET @Ls_Sql_TEXT = 'SELECT Oble12879ProratedOwedAmt_T1-1';     
	SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')

   SELECT @Ln_Defect12879_UpdatedProratedOwed_AMNT = a.ProratedOwed_AMNT,
		  @Lc_Defect12879_Adjust_Bucket_NAME = Bucket_NAME
     FROM Oble12879ProratedOwedAmt_T1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY <> 0
      BEGIN

		SET @Ls_Sql_TEXT = 'SELECT LSUP-1';     
		SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'') + ',SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonthPrevious_NUMB AS VARCHAR ),'')

	   SELECT @Ln_TransactionCurSup_AMNT = a.TransactionCurSup_AMNT,
			  @Ln_TransactionNaa_AMNT = a.TransactionNaa_AMNT,
			  @Ln_TransactionPaa_AMNT = a.TransactionPaa_AMNT,
			  @Ln_TransactionUda_AMNT = a.TransactionUda_AMNT,
			  @Ln_TransactionIvef_AMNT = a.TransactionIvef_AMNT,
			  @Ln_TransactionNffc_AMNT = a.TransactionNffc_AMNT,
			  @Ln_TransactionNonIvd_AMNT = a.TransactionNonIvd_AMNT,
			  @Ln_TransactionMedi_AMNT = a.TransactionMedi_AMNT, 
			  @Lc_Bucket_NAME = CASE WHEN a.TransactionCurSup_AMNT = a.TransactionNaa_AMNT THEN 'NAA'
									 WHEN a.TransactionCurSup_AMNT = a.TransactionPaa_AMNT THEN 'PAA'
									 WHEN a.TransactionCurSup_AMNT = a.TransactionUda_AMNT THEN 'UDA'
									 WHEN a.TransactionCurSup_AMNT = a.TransactionIvef_AMNT THEN 'IVEF'
									 WHEN a.TransactionCurSup_AMNT = a.TransactionNffc_AMNT THEN 'NFFC'
									 WHEN a.TransactionCurSup_AMNT = a.TransactionNonIvd_AMNT THEN 'NIVD'
									 WHEN a.TransactionCurSup_AMNT = a.TransactionMedi_AMNT THEN 'MEDI'
									 ELSE 'MULT'-- Arrear amount reduced from more than one bucket
									 END,
				@Ln_Naa_BucketArrear_AMNT = (OweTotNaa_AMNT - AppTotNaa_AMNT),
				@Ln_Paa_BucketArrear_AMNT = (OweTotPaa_AMNT - AppTotPaa_AMNT),
				@Ln_Uda_BucketArrear_AMNT = (OweTotUda_AMNT - AppTotUda_AMNT),
				@Ln_Ivef_BucketArrear_AMNT = (OweTotIvef_AMNT - AppTotIvef_AMNT),
				@Ln_Nffc_BucketArrear_AMNT = (OweTotNffc_AMNT - AppTotNffc_AMNT),
				@Ln_NonIvd_BucketArrear_AMNT = (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT),				
				@Ln_Medi_BucketArrear_AMNT = (OweTotMedi_AMNT - AppTotMedi_AMNT)									    
		 FROM LSUP_Y1 a
		WHERE a.Case_IDNO = @An_Case_IDNO
		  AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
		  AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
		  AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
		  AND SupportYearMonth_NUMB = @Ln_SupportYearMonthPrevious_NUMB;		
		
	     SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   
		 IF @Li_Rowcount_QNTY <> 0
		  BEGIN

			IF @Ln_Defect12879_UpdatedProratedOwed_AMNT <> ((@Ln_TransactionCurSup_AMNT) * -1)
			BEGIN
				
				-- Get the difference amount from LSUP between Defect1287 Adjusted Prorated Owed Amount and OWIZ Script LSUP Prorated Negative Amount
				SET @Ln_Difference_AMNT = @Ln_Defect12879_UpdatedProratedOwed_AMNT - ((@Ln_TransactionCurSup_AMNT) * -1)

				 SET @Ls_Sql_TEXT = 'UPDATE LSUP_Y1-DifferenceAmount-1';
				 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')

				 UPDATE LSUP_Y1
					SET  TransactionNaa_AMNT = CASE WHEN @Lc_Bucket_NAME = 'NAA' THEN TransactionNaa_AMNT - @Ln_Difference_AMNT ELSE TransactionNaa_AMNT END,
						 OweTotNaa_AMNT	= CASE WHEN @Lc_Bucket_NAME = 'NAA' THEN OweTotNaa_AMNT - @Ln_Difference_AMNT ELSE OweTotNaa_AMNT END,
						 TransactionPaa_AMNT = CASE WHEN @Lc_Bucket_NAME = 'PAA' THEN TransactionPaa_AMNT - @Ln_Difference_AMNT ELSE TransactionPaa_AMNT END,
						 OweTotPaa_AMNT	= CASE WHEN @Lc_Bucket_NAME = 'PAA' THEN OweTotPaa_AMNT - @Ln_Difference_AMNT ELSE OweTotPaa_AMNT END,
						 TransactionUda_AMNT = CASE WHEN @Lc_Bucket_NAME = 'UDA' THEN TransactionUda_AMNT - @Ln_Difference_AMNT ELSE TransactionUda_AMNT END,
						 OweTotUda_AMNT	= CASE WHEN @Lc_Bucket_NAME = 'UDA' THEN OweTotUda_AMNT - @Ln_Difference_AMNT ELSE OweTotUda_AMNT END,
						 TransactionIvef_AMNT = CASE WHEN @Lc_Bucket_NAME = 'IVEF' THEN TransactionIvef_AMNT - @Ln_Difference_AMNT ELSE TransactionIvef_AMNT END,
						 OweTotIvef_AMNT	= CASE WHEN @Lc_Bucket_NAME = 'IVEF' THEN OweTotIvef_AMNT - @Ln_Difference_AMNT ELSE OweTotIvef_AMNT END,
						 TransactionNffc_AMNT = CASE WHEN @Lc_Bucket_NAME = 'NFFC' THEN TransactionNffc_AMNT - @Ln_Difference_AMNT ELSE TransactionNffc_AMNT END,
						 OweTotNffc_AMNT = CASE WHEN @Lc_Bucket_NAME = 'NFFC' THEN OweTotNffc_AMNT - @Ln_Difference_AMNT ELSE OweTotNffc_AMNT END,
						 TransactionNonIvd_AMNT = CASE WHEN @Lc_Bucket_NAME = 'NIVD' THEN TransactionNonIvd_AMNT - @Ln_Difference_AMNT ELSE TransactionNonIvd_AMNT END,
						 OweTotNonIvd_AMNT	= CASE WHEN @Lc_Bucket_NAME = 'NIVD' THEN OweTotNonIvd_AMNT - @Ln_Difference_AMNT ELSE OweTotNonIvd_AMNT END,
						 TransactionMedi_AMNT = CASE WHEN @Lc_Bucket_NAME = 'MEDI' THEN TransactionMedi_AMNT - @Ln_Difference_AMNT ELSE TransactionMedi_AMNT END,
						 OweTotMedi_AMNT	= CASE WHEN @Lc_Bucket_NAME = 'MEDI' THEN OweTotMedi_AMNT - @Ln_Difference_AMNT ELSE OweTotMedi_AMNT END
				  WHERE Case_IDNO = @An_Case_IDNO
					AND OrderSeq_NUMB = @An_OrderSeq_NUMB
					AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
					AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
					AND SupportYearMonth_NUMB IN (@Ln_SupportYearMonthPrevious_NUMB, @Ln_SupportYearMonthNew_NUMB)

			 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

			 IF @Li_Rowcount_QNTY <> 2
			  BEGIN
			   SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

			   RAISERROR (50001,16,1);
			  END
			 
			 -- Scenario 1: Cent Adjustment Between Case Oblgtions - Fixed in OWIZ Online Code.
			 
			 -- Scenario 2: Two Cents Adjustment Between Case Oblgtions - Fixed in OWIZ Online Code.
			 			 
			 -- Scenario 3: Multiple Buckets Positive Arrear
			 -- If Arrear amount reduced from more than one bucket then update the Difference Amount in arrear amount exists bucket.
			 -- For Ex: For Case 304928 OWIZ Script is reduced total 103.71 (-85.46 From NAA, -18.25 From UDA) reduced from NAA, UDA buckets 201312.
			 -- After reducing the -85.46 From NAA bucket OweTotNaa_AMNT is 1029.68 and AppTotNaa_AMNT is 1029.68 and 
			 -- After reducing the -18.25 From UDA bucket OweTotUda_AMNT is 471.26 and AppTotUda_AMNT is 9.99
			 -- Since there is no arrear balance in NAA bucket, difference amount (110.14 - 103.71 = 6.31) will be reduced from UDA bucekt.
			 -- Note: Defect1287 Adjusted Prorated Owed Amount = 110.14, Arrear Adjusted in December and January 2014 amount is  103.71 without BATCH_ONE_TIME_OWIZ_CLEANUP script.
			 
			 -- Scenario 4: Multiple Buckets Negative Arrear
			 -- If Arrear amount reduced from more than one bucket then update the Difference Amount in negative arrear amount bucket.
			 -- For Ex: For Case 146541 OWIZ Script is reduced total 164.56 (-83.23 From NAA, -81.33 From PAA) reduced from NAA, PAA buckets 201312.
			 -- After reducing the -81.33 From PAA bucket OweTotNaa_AMNT is 709.65 and AppTotNaa_AMNT is 709.65.
			 -- Since no other bucket has postive arrear, remaining 83.23 reduced in NAA bucket.
			 -- After reducing the -83.23 From NAA bucket OweTotUda_AMNT is -83.23 and AppTotUda_AMNT is -83.23
			 -- Since there is no arrear balance in PAA bucket, difference amount (168.49 - 164.56 = 3.93) will be reduced from NAA bucekt.
			 -- Note: Defect1287 Adjusted Prorated Owed Amount = 168.49, Arrear Adjusted in December and January 2014 amount is  164.56  without BATCH_ONE_TIME_OWIZ_CLEANUP script.
			 
			 -- Scenario 5: Periodic Amount is changed to Zero
			 -- If Obligation Periodic Amount is changed as 0 then OWIZ script won't insert 201312 month record i.e.) It will only insert one record for 201401.
			 -- This script will insert 201312 month record and Adjust Defect1287 Adjusted Prorated Owed Amount in 201312, 201401 records.
			 -- For Ex: For Case 312489 OWIZ Script is only added 201401 record. 
			 -- This script will create 201312 month record, Adjust Defect1287 Adjusted Prorated Owed Amount 149.59 amount in 201312, 201401 records
			 IF @Lc_Bucket_NAME = 'MULT'
			 BEGIN

				 SET @Ls_Sql_TEXT = 'UPDATE LSUP_Y1-DifferenceAmount-2-MultiBucket';
				 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')

				 UPDATE LSUP_Y1
					SET  TransactionNaa_AMNT = CASE WHEN @Ln_TransactionNaa_AMNT < 0 AND (@Ln_Naa_BucketArrear_AMNT > 0 OR @Ln_Naa_BucketArrear_AMNT < 0) THEN TransactionNaa_AMNT - @Ln_Difference_AMNT ELSE TransactionNaa_AMNT END,
						 OweTotNaa_AMNT	= CASE WHEN @Ln_TransactionNaa_AMNT < 0 AND (@Ln_Naa_BucketArrear_AMNT > 0 OR @Ln_Naa_BucketArrear_AMNT < 0) THEN OweTotNaa_AMNT - @Ln_Difference_AMNT ELSE OweTotNaa_AMNT END,
						 TransactionPaa_AMNT = CASE WHEN @Ln_TransactionPaa_AMNT < 0 AND (@Ln_Paa_BucketArrear_AMNT > 0 OR @Ln_Paa_BucketArrear_AMNT < 0) THEN TransactionPaa_AMNT - @Ln_Difference_AMNT ELSE TransactionPaa_AMNT END,
						 OweTotPaa_AMNT	= CASE WHEN @Ln_TransactionPaa_AMNT < 0 AND (@Ln_Paa_BucketArrear_AMNT > 0 OR @Ln_Paa_BucketArrear_AMNT < 0) THEN OweTotPaa_AMNT - @Ln_Difference_AMNT ELSE OweTotPaa_AMNT END,
						 TransactionUda_AMNT = CASE WHEN @Ln_TransactionUda_AMNT < 0 AND (@Ln_Uda_BucketArrear_AMNT > 0 OR @Ln_Uda_BucketArrear_AMNT < 0) THEN TransactionUda_AMNT - @Ln_Difference_AMNT ELSE TransactionUda_AMNT END,
						 OweTotUda_AMNT	= CASE WHEN @Ln_TransactionUda_AMNT < 0 AND (@Ln_Uda_BucketArrear_AMNT > 0 OR @Ln_Uda_BucketArrear_AMNT < 0) THEN OweTotUda_AMNT - @Ln_Difference_AMNT ELSE OweTotUda_AMNT END,
						 TransactionIvef_AMNT = CASE WHEN @Ln_TransactionIvef_AMNT < 0 AND (@Ln_Ivef_BucketArrear_AMNT > 0 OR @Ln_Ivef_BucketArrear_AMNT < 0) THEN TransactionIvef_AMNT - @Ln_Difference_AMNT ELSE TransactionIvef_AMNT END,
						 OweTotIvef_AMNT	= CASE WHEN @Ln_TransactionIvef_AMNT < 0 AND (@Ln_Ivef_BucketArrear_AMNT > 0 OR @Ln_Ivef_BucketArrear_AMNT < 0) THEN OweTotIvef_AMNT - @Ln_Difference_AMNT ELSE OweTotIvef_AMNT END,
						 TransactionNffc_AMNT = CASE WHEN @Ln_TransactionNffc_AMNT < 0 AND (@Ln_Nffc_BucketArrear_AMNT > 0 OR @Ln_Nffc_BucketArrear_AMNT < 0) THEN TransactionNffc_AMNT - @Ln_Difference_AMNT ELSE TransactionNffc_AMNT END,
						 OweTotNffc_AMNT = CASE WHEN @Ln_TransactionNffc_AMNT < 0 AND (@Ln_Nffc_BucketArrear_AMNT > 0 OR @Ln_Nffc_BucketArrear_AMNT < 0) THEN OweTotNffc_AMNT - @Ln_Difference_AMNT ELSE OweTotNffc_AMNT END,
						 TransactionNonIvd_AMNT = CASE WHEN @Ln_TransactionNonIvd_AMNT < 0 AND (@Ln_NonIvd_BucketArrear_AMNT > 0 OR @Ln_NonIvd_BucketArrear_AMNT < 0) THEN TransactionNonIvd_AMNT - @Ln_Difference_AMNT ELSE TransactionNonIvd_AMNT END,
						 OweTotNonIvd_AMNT	= CASE WHEN @Ln_TransactionNonIvd_AMNT < 0 AND (@Ln_NonIvd_BucketArrear_AMNT > 0 OR @Ln_NonIvd_BucketArrear_AMNT < 0) THEN OweTotNonIvd_AMNT - @Ln_Difference_AMNT ELSE OweTotNonIvd_AMNT END,
						 TransactionMedi_AMNT = CASE WHEN @Ln_TransactionMedi_AMNT < 0 AND (@Ln_Medi_BucketArrear_AMNT > 0 OR @Ln_Medi_BucketArrear_AMNT < 0) THEN TransactionMedi_AMNT - @Ln_Difference_AMNT ELSE TransactionMedi_AMNT END,
						 OweTotMedi_AMNT	= CASE WHEN @Ln_TransactionMedi_AMNT < 0 AND (@Ln_Medi_BucketArrear_AMNT > 0 OR @Ln_Medi_BucketArrear_AMNT < 0) THEN OweTotMedi_AMNT - @Ln_Difference_AMNT ELSE OweTotMedi_AMNT END
				  WHERE Case_IDNO = @An_Case_IDNO
					AND OrderSeq_NUMB = @An_OrderSeq_NUMB
					AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
					AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
					AND SupportYearMonth_NUMB IN (@Ln_SupportYearMonthPrevious_NUMB, @Ln_SupportYearMonthNew_NUMB)

			 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

			 IF @Li_Rowcount_QNTY <> 2
			  BEGIN
			   SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

			   RAISERROR (50001,16,1);
			  END
			 END
			END 
		  END
		 ELSE 
		 -- If Obligation Periodic Amount is changed as 0 then OWIZ script won't insert 201312 month record i.e.) It will only insert one record for 201401.
		 -- This script will insert 201312 month record and Adjust Defect1287 Adjusted Prorated Owed Amount in 201312, 201401 records.
		 BEGIN
			SET @Ls_Sql_TEXT = 'SELECT LSUP-2';     
			SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')

		   SELECT @Ln_RecordCount_QNTY  = COUNT(1)									    
			 FROM LSUP_Y1 a
			WHERE a.Case_IDNO = @An_Case_IDNO
			  AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
			  AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
			  AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;		
			
			 SET @Li_Rowcount_QNTY = @@ROWCOUNT;
	   
			 IF @Ln_RecordCount_QNTY = 1
			  BEGIN
				
				SET @Ls_Sql_TEXT = 'INSERT LSUP-1';     
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ',SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonthPrevious_NUMB AS VARCHAR ),'')
					 
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
						 TransactionNffc_AMNT,
						 OweTotNffc_AMNT,
						 AppTotNffc_AMNT,
						 TransactionNonIvd_AMNT,
						 OweTotNonIvd_AMNT,
						 AppTotNonIvd_AMNT,
						 TransactionMedi_AMNT,
						 OweTotMedi_AMNT,
						 AppTotMedi_AMNT,
						 TransactionFuture_AMNT,
						 AppTotFuture_AMNT,
						 CheckRecipient_ID,
						 CheckRecipient_CODE,
						 Batch_DATE,
						 Batch_NUMB,
						 SeqReceipt_NUMB,
						 SourceBatch_CODE,
						 Receipt_DATE,
						 Distribute_DATE,
						 TypeRecord_CODE,
						 EventGlobalSeq_NUMB,
						 EventFunctionalSeq_NUMB)
				 (SELECT Case_IDNO,
						 OrderSeq_NUMB,
						 ObligationSeq_NUMB,
						 SupportYearMonth_NUMB,
						 TypeWelfare_CODE,
						 MtdCurSupOwed_AMNT,
						 0 AS TransactionCurSup_AMNT,
						 OweTotCurSup_AMNT,
						 AppTotCurSup_AMNT,
						 0 AS TransactionExptPay_AMNT,
						 OweTotExptPay_AMNT,
						 AppTotExptPay_AMNT,
						 0 - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NAA' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS TransactionNaa_AMNT,
						 OweTotNaa_AMNT - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NAA' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS OweTotNaa_AMNT,
						 AppTotNaa_AMNT,
						 0 AS TransactionTaa_AMNT,
						 OweTotTaa_AMNT,
						 AppTotTaa_AMNT,
						 0 - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'PAA' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS TransactionPaa_AMNT,
						 OweTotPaa_AMNT - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'PAA' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS OweTotPaa_AMNT,
						 AppTotPaa_AMNT,
						 0 AS TransactionCaa_AMNT,
						 OweTotCaa_AMNT,
						 AppTotCaa_AMNT,
						 0 AS TransactionUpa_AMNT,
						 OweTotUpa_AMNT,
						 AppTotUpa_AMNT,
						 0 AS TransactionUda_AMNT,
						 OweTotUda_AMNT,
						 AppTotUda_AMNT,
						 0 - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'IVEF' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS TransactionIvef_AMNT,
						 OweTotIvef_AMNT - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'IVEF' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS OweTotIvef_AMNT,
						 AppTotIvef_AMNT,
						 0 - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NFFC' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS TransactionNffc_AMNT,
						 OweTotNffc_AMNT - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NFFC' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS OweTotNffc_AMNT,
						 AppTotNffc_AMNT,
						 0 - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NIVD' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS TransactionNonIvd_AMNT,
						 OweTotNonIvd_AMNT - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NIVD' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS OweTotNonIvd_AMNT,
						 AppTotNonIvd_AMNT,
						 0 - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'MEDI' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS TransactionMedi_AMNT,
						 OweTotMedi_AMNT - (CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'MEDI' THEN @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE 0 END) AS OweTotMedi_AMNT,
						 AppTotMedi_AMNT,
						 0 AS TransactionFuture_AMNT,
						 AppTotFuture_AMNT,
						 CheckRecipient_ID,
						 CheckRecipient_CODE,
						 '01/01/0001' AS Batch_DATE,
						 0 AS Batch_NUMB,
						 0 AS SeqReceipt_NUMB,
						 '' AS SourceBatch_CODE,
						 '01/01/0001' Receipt_DATE,
						 @Ad_Run_DATE AS Distribute_DATE,
						 '' AS TypeRecord_CODE,
						 @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
						 1020 AS EventFunctionalSeq_NUMB
					FROM LSUP_Y1 a
				   WHERE a.Case_IDNO = @An_Case_IDNO
					 AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
					 AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
					 AND a.SupportYearMonth_NUMB = @Ln_SupportYearMonthPrevious_NUMB
					 AND a.EventGlobalSeq_NUMB = (SELECT MAX (c.EventGlobalSeq_NUMB)
													FROM LSUP_Y1 c
												   WHERE c.Case_IDNO = a.Case_IDNO
													 AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
													 AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
													 AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB));	
				 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

				 IF @Li_Rowcount_QNTY = 0
				  BEGIN
				   SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

				   RAISERROR (50001,16,1);
				  END

				 SET @Ls_Sql_TEXT = 'UPDATE LSUP_Y1-Defect12879_UpdatedProratedOwed_AMNT';
				 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonthNew_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'') + ', Defect12879_Adjust_Bucket_NAME = ' + ISNULL(CAST( @Lc_Defect12879_Adjust_Bucket_NAME AS VARCHAR ),'')  + ', Defect12879_UpdatedProratedOwed_AMNT = ' + ISNULL(CAST( @Ln_Defect12879_UpdatedProratedOwed_AMNT AS VARCHAR ),'')

				 UPDATE LSUP_Y1
					SET  TransactionNaa_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NAA' THEN TransactionNaa_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionNaa_AMNT END,
						 OweTotNaa_AMNT	= CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NAA' THEN OweTotNaa_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotNaa_AMNT END,
						 TransactionPaa_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'PAA' THEN TransactionPaa_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionPaa_AMNT END,
						 OweTotPaa_AMNT	= CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'PAA' THEN OweTotPaa_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotPaa_AMNT END,
						 TransactionUda_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'UDA' THEN TransactionUda_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionUda_AMNT END,
						 OweTotUda_AMNT	= CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'UDA' THEN OweTotUda_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotUda_AMNT END,
						 TransactionIvef_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'IVEF' THEN TransactionIvef_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionIvef_AMNT END,
						 OweTotIvef_AMNT	= CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'IVEF' THEN OweTotIvef_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotIvef_AMNT END,
						 TransactionNffc_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NFFC' THEN TransactionNffc_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionNffc_AMNT END,
						 OweTotNffc_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NFFC' THEN OweTotNffc_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotNffc_AMNT END,
						 TransactionNonIvd_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NIVD' THEN TransactionNonIvd_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionNonIvd_AMNT END,
						 OweTotNonIvd_AMNT	= CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'NIVD' THEN OweTotNonIvd_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotNonIvd_AMNT END,
						 TransactionMedi_AMNT = CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'MEDI' THEN TransactionMedi_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE TransactionMedi_AMNT END,
						 OweTotMedi_AMNT	= CASE WHEN @Lc_Defect12879_Adjust_Bucket_NAME = 'MEDI' THEN OweTotMedi_AMNT - @Ln_Defect12879_UpdatedProratedOwed_AMNT ELSE OweTotMedi_AMNT END
				  WHERE Case_IDNO = @An_Case_IDNO
					AND OrderSeq_NUMB = @An_OrderSeq_NUMB
					AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
					AND SupportYearMonth_NUMB = @Ln_SupportYearMonthNew_NUMB					
					AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;

					
				 SET @Li_Rowcount_QNTY = @@ROWCOUNT;
								
				 IF @Li_Rowcount_QNTY = 0
				  BEGIN
				   SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

				   RAISERROR (50001,16,1);
				  END
			  												 											 
			  END 
						 
		 END
      END
      -- Difference Amount between Defect1287 Adjusted Prorated Owed Amount and OWIZ Script LSUP Prorated Negative Amount Update Section - End --
      
      -- MSO Amount (OWIZ Script Reduced Amount) Update Section - Start --
      IF EXISTS(SELECT 1
				 FROM LSUP_Y1 a
				WHERE a.Case_IDNO = @An_Case_IDNO
				  AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
				  AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
				  AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
				  AND SupportYearMonth_NUMB = @Ln_SupportYearMonthPrevious_NUMB)
      BEGIN
			   SET @Ls_Sql_TEXT = 'SELECT LSUP-2';     
			   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'') + ',SupportYearMonth_NUMB = ' + ISNULL(CAST( @Ln_SupportYearMonthPrevious_NUMB AS VARCHAR ),'')

			   SELECT @Ln_TransactionCurSup_AMNT = ((a.TransactionCurSup_AMNT) * -1),
					  @Ln_MtdCurSupOwed_AMNT_AMNT = a.MtdCurSupOwed_AMNT
				 FROM LSUP_Y1 a
				WHERE a.Case_IDNO = @An_Case_IDNO
				  AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
				  AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
				  AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
				  AND SupportYearMonth_NUMB = @Ln_SupportYearMonthPrevious_NUMB;		
				
				 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

				 IF @Li_Rowcount_QNTY = 0
				  BEGIN
					SET @Ls_ErrorMessage_TEXT = 'MSO AMOUNT SELECT NOT SUCCESSFUL';
					RAISERROR (50001,16,1);
				  END		

				 SET @Ls_Sql_TEXT = 'UPDATE LSUP_Y1-MSOAmount';
				 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'') + ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')
				
				 -- Making TransactionCurSup_AMNT as 0 for 201312. So that ELOG screen Obligation modification popup will $0.00 in both 201312, 201401 months periodic amount as 0 in detail (grid) section  	
				 UPDATE LSUP_Y1
					SET  TransactionCurSup_AMNT = 0,
						 OweTotCurSup_AMNT = @Ln_TransactionCurSup_AMNT + @Ln_MtdCurSupOwed_AMNT_AMNT,
						 MtdCurSupOwed_AMNT = @Ln_TransactionCurSup_AMNT + @Ln_MtdCurSupOwed_AMNT_AMNT
				  WHERE Case_IDNO = @An_Case_IDNO
					AND OrderSeq_NUMB = @An_OrderSeq_NUMB
					AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
					AND EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
					AND SupportYearMonth_NUMB = @Ln_SupportYearMonthPrevious_NUMB

			 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

			 IF @Li_Rowcount_QNTY <> 1
			  BEGIN
			   SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

			   RAISERROR (50001,16,1);
			  END
			END
      -- MSO Amount (OWIZ Script Reduced Amount) Update Section - End --
      
      SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH

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

	SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   RAISERROR (@As_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
