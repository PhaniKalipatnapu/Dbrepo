/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PASSTHRU_MANUAL_REL_EXCESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_PASSTHRU_MANUAL_REL_EXCESS
Programmer Name 	: IMP Team
Description			: This Procedure PassThru the Money that were held with Futures Hold code and are Manually Released
					  by the Workers
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
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_PASSTHRU_MANUAL_REL_EXCESS]
 @An_Remaining_AMNT        NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE  CHAR (1) = 'S',
           @Lc_StatusFailed_CODE   CHAR (1) = 'F',
           @Lc_TypeBucketC_CODE    CHAR (1) = 'C',
           @Lc_TypeBucketE_CODE    CHAR (1) = 'E',
           @Ls_Procedure_NAME      VARCHAR (100) = 'SP_PASSTHRU_MANUAL_REL_EXCESS';
  DECLARE  @Ln_Obligation_QNTY    NUMERIC (2),
           @Ln_Error_NUMB         NUMERIC (11),
           @Ln_ErrorLine_NUMB     NUMERIC (11),
           @Ls_Sql_TEXT           VARCHAR (100) = '',
           @Ls_Sqldata_TEXT       VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR (4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT ='';
   SET @Ls_Sql_TEXT = 'SELECT_TEXPT_CNT';   
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Obligation_QNTY = COUNT (DISTINCT ISNULL (a.Case_IDNO, '') + ISNULL (CAST (a.OrderSeq_NUMB AS VARCHAR), '') + ISNULL (CAST (a.ObligationSeq_NUMB AS VARCHAR), ''))
     FROM #Texpt_P1 a;

   SET @Ls_Sql_TEXT = 'INSERT #Tpaid_P1';   
   SET @Ls_Sqldata_TEXT = '';

   INSERT #Tpaid_P1
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
   SELECT ROW_NUMBER () OVER (ORDER BY Row_NUMB) AS Seq_IDNO,
          a.TypeBucket_CODE,
          a.PrDistribute_QNTY,
          ROUND ((@An_Remaining_AMNT / @Ln_Obligation_QNTY), 2) + CASE
                                                                   WHEN ROW_NUMBER () OVER (ORDER BY Row_NUMB) = 1
                                                                    THEN @An_Remaining_AMNT - ROUND ((@An_Remaining_AMNT / @Ln_Obligation_QNTY), 2) * @Ln_Obligation_QNTY
                                                                   ELSE 0
                                                                  END AS ArrPaid_AMNT,
          0 AS Rounded_AMNT,
          a.ArrToBePaid_AMNT,
          a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.TypeOrder_CODE,
          a.TypeWelfare_CODE,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB
     FROM (SELECT 0 Row_NUMB,
                  t.TypeBucket_CODE,
                  t.PrDistribute_QNTY,
                  0 AS Rounded_AMNT,
                  t.ArrToBePaid_AMNT,
                  t.Case_IDNO,
                  t.OrderSeq_NUMB,
                  t.ObligationSeq_NUMB,
                  t.CheckRecipient_ID,
                  t.CheckRecipient_CODE,
                  t.TypeOrder_CODE,
                  t.TypeWelfare_CODE,
                  t.Batch_DATE,
                  t.SourceBatch_CODE,
                  t.Batch_NUMB,
                  t.SeqReceipt_NUMB
             FROM #Texpt_P1 t,
                  (SELECT DISTINCT e.Case_IDNO,
                          e.OrderSeq_NUMB,
                          e.ObligationSeq_NUMB,
                          MIN (e.PrDistribute_QNTY) OVER ( PARTITION BY e.Case_IDNO, e.OrderSeq_NUMB, e.ObligationSeq_NUMB) PrDistribute_QNTY
                     FROM #Texpt_P1 e
                    WHERE e.TypeBucket_CODE NOT IN (@Lc_TypeBucketC_CODE, @Lc_TypeBucketE_CODE)) p
            WHERE t.Case_IDNO = p.Case_IDNO
              AND t.OrderSeq_NUMB = p.OrderSeq_NUMB
              AND t.ObligationSeq_NUMB = p.ObligationSeq_NUMB
              AND t.PrDistribute_QNTY = p.PrDistribute_QNTY) a;

   SET @An_Remaining_AMNT = 0;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
