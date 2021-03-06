/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_VOLUNTARY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_VOLUNTARY
Programmer Name 	: IMP Team
Description			: This Procedure will get executed when there is remaining Money for the Voluntary RCTH_Y1.
					  The Remaining Money will be equally prorated against the Voluntary OBLE_Y1 and Updates the
					  same in the Temporary Table TPAID_Y1
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_VOLUNTARY]
 @An_Remaining_AMNT        NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ac_VoluntaryProcess_INDC CHAR (1) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_TypeOrderVoluntary_CODE  CHAR (1) = 'V',
           @Lc_StatusSuccess_CODE       CHAR (1) = 'S',
           @Lc_Yes_INDC                 CHAR (1) = 'Y',
           @Lc_StatusFailed_CODE        CHAR (1) = 'F',
           @Lc_TypeBucketC_CODE         CHAR (1) = 'C',
           @Ls_Procedure_NAME           VARCHAR (100) = 'SP_PROCESS_VOLUNTARY',
           @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE  @Ln_VoluntaryuntaryObligationSeq_NUMB NUMERIC (2) = 0,
           @Ln_Arr_QNTY                         NUMERIC (3) = 0,
           @Ln_Cursor_QNTY                      NUMERIC (3) = 0,
           @Ln_Dist_AMNT                        NUMERIC (11,2) = 0,
           @Ln_Tot_AMNT                         NUMERIC (11,2) = 0,
           @Ln_Remaining_AMNT                   NUMERIC (11,2) = 0,
           @Ln_Arr_AMNT                         NUMERIC (11,2) = 0,
           @Ln_VoluntaryPaid_AMNT               NUMERIC (11,2) = 0,
           @Ln_VoluntaryUsed_AMNT               NUMERIC (11,2) = 0,
           @Ln_VoluntaryPrevUsed_AMNT           NUMERIC (11,2) = 0,
           @Ln_Error_NUMB                       NUMERIC (11),
           @Ln_ErrorLine_NUMB                   NUMERIC (11),
           @Li_FetchStatus_QNTY                 SMALLINT,
           @Li_Rowcount_QNTY                    SMALLINT,
           @Ls_Sql_TEXT                         VARCHAR (100) = '',
           @Ls_Sqldata_TEXT                     VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT                NVARCHAR (4000);
  DECLARE  @Ln_VoluntaryCur_Case_IDNO           NUMERIC (6),
		   @Ln_VoluntaryCur_OrderSeq_NUMB       NUMERIC (2),
		   @Ln_VoluntaryCur_ObligationSeq_NUMB  NUMERIC (2),
           @Lc_VoluntaryCur_TypeBucket_CODE     CHAR (5),
           @Ln_VoluntaryCur_ArrToBePaid_AMNT    NUMERIC (11,2);
           
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_Sql_TEXT = 'SELECT TEXPT_Y1';   
   SET @Ls_Sqldata_TEXT = 'TypeOrder_CODE = ' + ISNULL(@Lc_TypeOrderVoluntary_CODE,'');

   SELECT @Ln_Arr_AMNT = SUM (t.ArrToBePaid_AMNT),
          @Ln_Arr_QNTY = COUNT (1)
     FROM #Texpt_P1 t
    WHERE t.TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
      AND t.ArrToBePaid_AMNT > 0;

   IF @An_Remaining_AMNT >= @Ln_Arr_AMNT
      AND @Ln_Arr_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_TPAID_VOL1';     
     SET @Ls_Sqldata_TEXT = 'TypeOrder_CODE = ' + @Lc_TypeOrderVoluntary_CODE;

     INSERT INTO #Tpaid_P1
                 (Seq_IDNO,
                  TypeBucket_CODE,
                  PrDistribute_QNTY,
                  ArrPaid_AMNT,
                  Rounded_AMNT,
                  ArrToBePaid_AMNT,
                  Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  TypeOrder_CODE,
                  TypeWelfare_CODE,
                  Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB)
     (SELECT ROW_NUMBER () OVER (ORDER BY b.ROW_NUMB) AS Seq_IDNO,
             TypeBucket_CODE,
             PrDistribute_QNTY,
             ArrToBePaid_AMNT AS ArrPaid_AMNT,
             0 AS Rounded_AMNT,
             ArrToBePaid_AMNT,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             CheckRecipient_ID,
             CheckRecipient_CODE,
             TypeOrder_CODE,
             TypeWelfare_CODE,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB
        FROM #Texpt_P1 t,
             (SELECT 0 AS ROW_NUMB) AS b
       WHERE TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
         AND ArrToBePaid_AMNT > 0);

     -- No need to Handle the Exception here as the Batch can Proceed further even if the
     -- above Insert Fail to insert any record
     SET @An_Remaining_AMNT = @An_Remaining_AMNT - @Ln_Arr_AMNT;
    END
   ELSE IF @Ln_Arr_QNTY > 0
    BEGIN
  
	  DECLARE Voluntary_CUR INSENSITIVE CURSOR FOR
	   SELECT a.Case_IDNO,
			  a.OrderSeq_NUMB,
			  a.ObligationSeq_NUMB,
			  a.TypeBucket_CODE,
			  a.ArrToBePaid_AMNT
		 FROM #Texpt_P1 a
		WHERE a.TypeOrder_CODE = 'V'
		  AND a.ArrToBePaid_AMNT > 0;
      
     SET @Ls_Sql_TEXT = 'OPEN Voluntary_CUR -1';  
     SET @Ls_Sqldata_TEXT = '';
     
     OPEN Voluntary_CUR;

     SET @Ls_Sql_TEXT = 'FETCH Voluntary_CUR -1';     
     SET @Ls_Sqldata_TEXT = '';
     
     FETCH Voluntary_CUR INTO @Ln_VoluntaryCur_Case_IDNO, @Ln_VoluntaryCur_OrderSeq_NUMB, @Ln_VoluntaryCur_ObligationSeq_NUMB, @Lc_VoluntaryCur_TypeBucket_CODE, @Ln_VoluntaryCur_ArrToBePaid_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
--loop started
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;

       IF @Ln_Arr_QNTY = @Ln_Cursor_QNTY
        BEGIN
         SET @Ln_VoluntaryPaid_AMNT = @An_Remaining_AMNT - @Ln_VoluntaryUsed_AMNT;
         SET @Ln_VoluntaryPrevUsed_AMNT = @Ln_VoluntaryUsed_AMNT;
         SET @Ln_VoluntaryUsed_AMNT = 0;
        END
       ELSE
        BEGIN
         SET @Ln_VoluntaryPaid_AMNT = ROUND ((@Ln_VoluntaryCur_ArrToBePaid_AMNT / @Ln_Arr_AMNT) * @An_Remaining_AMNT, 2);
         SET @Ln_VoluntaryPrevUsed_AMNT = @Ln_VoluntaryUsed_AMNT;
         SET @Ln_VoluntaryUsed_AMNT = @Ln_VoluntaryPaid_AMNT + @Ln_VoluntaryUsed_AMNT;
        END

       IF @Ln_VoluntaryUsed_AMNT > @An_Remaining_AMNT
        BEGIN
         IF @Ln_VoluntaryPrevUsed_AMNT >= @An_Remaining_AMNT
          BEGIN
           SET @Ln_VoluntaryPaid_AMNT = 0;
           SET @An_Remaining_AMNT = 0;
          END
         ELSE IF @Ln_VoluntaryPrevUsed_AMNT < @An_Remaining_AMNT
          BEGIN
           SET @Ln_VoluntaryPaid_AMNT = @An_Remaining_AMNT - @Ln_VoluntaryPrevUsed_AMNT;
           SET @An_Remaining_AMNT = 0;
          END
        END

       SET @Ls_Sql_TEXT = 'INSERT_TPAID_VOL2';	   
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_VoluntaryCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_VoluntaryCur_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + CAST(@Ln_VoluntaryCur_ObligationSeq_NUMB AS VARCHAR) + ', TypeBucket_CODE = ' + @Lc_VoluntaryCur_TypeBucket_CODE + ', TypeOrder_CODE = ' + @Lc_TypeOrderVoluntary_CODE;

       INSERT INTO #Tpaid_P1
                   (Seq_IDNO,
                    TypeBucket_CODE,
                    PrDistribute_QNTY,
                    ArrPaid_AMNT,
                    Rounded_AMNT,
                    ArrToBePaid_AMNT,
                    Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    CheckRecipient_ID,
                    CheckRecipient_CODE,
                    TypeOrder_CODE,
                    TypeWelfare_CODE,
                    Batch_DATE,
                    SourceBatch_CODE,
                    Batch_NUMB,
                    SeqReceipt_NUMB)
       (SELECT ROW_NUMBER () OVER (ORDER BY b.ROW_NUMB) AS Seq_IDNO,
               TypeBucket_CODE,
               PrDistribute_QNTY,
               @Ln_VoluntaryPaid_AMNT AS ArrPaid_AMNT,
               0 AS Rounded_AMNT,
               ArrToBePaid_AMNT,
               Case_IDNO,
               OrderSeq_NUMB,
               ObligationSeq_NUMB,
               CheckRecipient_ID,
               CheckRecipient_CODE,
               TypeOrder_CODE,
               TypeWelfare_CODE,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB
          FROM #Texpt_P1 t,
               (SELECT 0 AS ROW_NUMB) b
         WHERE Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
           AND OrderSeq_NUMB = @Ln_VoluntaryCur_OrderSeq_NUMB
           AND ObligationSeq_NUMB = @Ln_VoluntaryCur_ObligationSeq_NUMB
           AND TypeBucket_CODE = @Lc_VoluntaryCur_TypeBucket_CODE
           AND TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
           AND ArrToBePaid_AMNT > 0);

       -- No need to Handle the Exception here as the Batch can Proceed further even if the
       -- above Insert Fail to insert any record
       SET @Ls_Sql_TEXT = 'FETCH Voluntary_CUR -2';       
       SET @Ls_Sqldata_TEXT = '';
       
       FETCH Voluntary_CUR INTO @Ln_VoluntaryCur_Case_IDNO, @Ln_VoluntaryCur_OrderSeq_NUMB, @Ln_VoluntaryCur_ObligationSeq_NUMB, @Lc_VoluntaryCur_TypeBucket_CODE, @Ln_VoluntaryCur_ArrToBePaid_AMNT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE Voluntary_CUR;

     DEALLOCATE Voluntary_CUR;

     SET @An_Remaining_AMNT = 0;
    END

   SET @Ls_Sql_TEXT = 'SELECT @Ln_VoluntaryuntaryObligationSeq_NUMB';   
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_VoluntaryuntaryObligationSeq_NUMB = COUNT (1)
     FROM (SELECT DISTINCT
                  a.Case_IDNO,
                  a.OrderSeq_NUMB,
                  a.ObligationSeq_NUMB
             FROM #Texpt_P1 a,
                  OBLE_Y1 b
            WHERE a.TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
              AND b.Case_IDNO = a.Case_IDNO
              AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
              AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
              AND b.EndValidity_DATE = @Ld_High_DATE) AS c;

   IF @Ln_VoluntaryuntaryObligationSeq_NUMB = 0
       OR @An_Remaining_AMNT = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

     RETURN;
    END

   SET @Ln_Dist_AMNT = ROUND ((@An_Remaining_AMNT / @Ln_VoluntaryuntaryObligationSeq_NUMB), 2);
   SET @Ln_Tot_AMNT = @Ln_Dist_AMNT * @Ln_VoluntaryuntaryObligationSeq_NUMB;
   SET @Ln_Remaining_AMNT = @An_Remaining_AMNT - @Ln_Tot_AMNT;
   SET @Ls_Sql_TEXT = 'UPDATE_TPAID_VOL';

   SET @Ls_Sqldata_TEXT = 'TypeOrder_CODE = ' + ISNULL(@Lc_TypeOrderVoluntary_CODE,'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_TypeBucketC_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   UPDATE #Tpaid_P1
      SET ArrPaid_AMNT = a.ArrPaid_AMNT + @Ln_Dist_AMNT
     FROM #Tpaid_P1 AS a
    WHERE a.TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
      AND a.TypeBucket_CODE = @Lc_TypeBucketC_CODE
      AND EXISTS (SELECT 1
                    FROM OBLE_Y1 b
                   WHERE b.Case_IDNO = a.Case_IDNO
                     AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                     AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                     -- Voluntary Payment should be a passthru even when there are no Current OBLE_Y1
                     --AND pd_dt_process BETWEEN b.BeginObligation_DATE
                     --                      AND b.EndObligation_DATE
                     AND b.EndValidity_DATE = @Ld_High_DATE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY > 0
    BEGIN
     SET @Ac_VoluntaryProcess_INDC = @Lc_Yes_INDC;
    END

   SET @Ls_Sql_TEXT = 'INSERT_TPAID_VOL3';

   SET @Ls_Sqldata_TEXT = 'TypeBucketC_CODE = ' + @Lc_TypeBucketC_CODE  + ', TypeOrderVoluntary_CODE = ' + @Lc_TypeOrderVoluntary_CODE + ', ArrPaid_AMNT = ' + ISNULL(CAST( @Ln_Dist_AMNT AS VARCHAR ),'')+ ', Rounded_AMNT = ' + ISNULL(CAST( 0 AS VARCHAR ),'');

   INSERT INTO #Tpaid_P1
               (Seq_IDNO,
                TypeBucket_CODE,
                PrDistribute_QNTY,
                ArrPaid_AMNT,
                Rounded_AMNT,
                ArrToBePaid_AMNT,
                Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                TypeOrder_CODE,
                TypeWelfare_CODE,
                Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB)
   (SELECT ROW_NUMBER () OVER (ORDER BY Row_NUMB) AS Seq_IDNO,
           TypeBucket_CODE,
           PrDistribute_QNTY,
           @Ln_Dist_AMNT AS ArrPaid_AMNT,
           0 AS Rounded_AMNT,
           ArrToBePaid_AMNT,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeOrder_CODE,
           TypeWelfare_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB
      FROM #Texpt_P1 a,
           (SELECT 0 AS Row_NUMB) AS Dual
     WHERE TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
       AND TypeBucket_CODE = @Lc_TypeBucketC_CODE
       AND NOT EXISTS (SELECT 1
                         FROM #Tpaid_P1 b
                        WHERE b.Case_IDNO = a.Case_IDNO
                          AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                          AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                          AND b.TypeBucket_CODE = @Lc_TypeBucketC_CODE
                          AND b.TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE)
       AND EXISTS (SELECT 1
                     FROM OBLE_Y1 b
                    WHERE b.Case_IDNO = a.Case_IDNO
                      AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                      AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                      AND b.EndValidity_DATE = @Ld_High_DATE));

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY > 0
    BEGIN
     SET @Ac_VoluntaryProcess_INDC = @Lc_Yes_INDC;
    END

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record
   --To Adjust CENT
   IF @Ln_Remaining_AMNT < 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE_TPAID_VOL_LESS';

     SET @Ls_Sqldata_TEXT = 'TypeOrder_CODE = ' + ISNULL(@Lc_TypeOrderVoluntary_CODE,'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_TypeBucketC_CODE,'');

     UPDATE TOP (1) #Tpaid_P1
        SET ArrPaid_AMNT = ArrPaid_AMNT + @Ln_Remaining_AMNT
      WHERE TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
        AND TypeBucket_CODE = @Lc_TypeBucketC_CODE
        AND ArrPaid_AMNT > 0;
    END

   --To Adjust CENT issue.
   IF @Ln_Remaining_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE_TPAID_VOL_HIGH';

     SET @Ls_Sqldata_TEXT = 'TypeOrder_CODE = ' + ISNULL(@Lc_TypeOrderVoluntary_CODE,'')+ ', TypeBucket_CODE = ' + ISNULL(@Lc_TypeBucketC_CODE,'');

     UPDATE TOP (1) #Tpaid_P1
        SET ArrPaid_AMNT = ArrPaid_AMNT + @Ln_Remaining_AMNT
      WHERE TypeOrder_CODE = @Lc_TypeOrderVoluntary_CODE
        AND TypeBucket_CODE = @Lc_TypeBucketC_CODE;
    END

   SET @An_Remaining_AMNT = 0;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'Voluntary_CUR') IN (0, 1)
    BEGIN
     CLOSE Voluntary_CUR;

     DEALLOCATE Voluntary_CUR;
    END

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
