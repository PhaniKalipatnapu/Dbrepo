/****** Object:  StoredProcedure [dbo].[BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE
 Programmer Name	: IMP Team
 Description		: The procedure is used to make the pending recoupment to active
 Frequency			: 
 Developed On		: 4/12/2011
 Called By			: BATCH_FIN_CP_RECOUP_NOTICE$SP_PROCESS_GENERATE_CP_RECOUP_NOTICE
 Called On			:
 -------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 1.0
-------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE]
 @Ac_CheckRecipient_ID     CHAR(10),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @An_Batch_NUMB            NUMERIC(4),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ad_Batch_DATE            DATE,
 @Ad_Run_DATE              DATE,
 @Ac_CheckRecipient_CODE   CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT          CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
          @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_No_INDC             CHAR(1) = 'N',
          @Lc_TypeRecoupment_CODE CHAR(1) = 'R',
          @Lc_Transaction_CODE    CHAR(4) = 'APPE',
          @Lc_Err0001_TEXT        CHAR(25) = 'INSERT NOT SUCCESSFUL',
          @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_SET_RECOUP_ACTIVE',
          @Ls_Sql_TEXT            VARCHAR(100) = ' ',
          @Ls_Sqldata_TEXT        VARCHAR(1000) = ' ',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ln_RowCount_QNTY         NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_AssessTotOverpay_AMNT NUMERIC(11, 2),
          @Ln_RecTotOverpay_AMNT    NUMERIC(11, 2),
          @Ln_PendTotOffset_AMNT    NUMERIC(11, 2),
          @Ln_Transaction_AMNT      NUMERIC(11, 2),
          @Li_FetchStatus_QNTY      SMALLINT,
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';
  DECLARE @Lc_PoflCur_CheckRecipient_ID    CHAR(10),
          @Lc_PoflCur_CheckRecipient_CODE  CHAR(1),
          @Ln_PoflCur_Case_IDNO            NUMERIC(6),
          @Ld_PoflCur_Batch_DATE           DATE,
          @Lc_PoflCur_SourceBatch_CODE     CHAR(3),
          @Ln_PoflCur_Batch_NUMB           NUMERIC(4),
          @Ln_PoflCur_SeqReceipt_NUMB      NUMERIC(6),
          @Ln_PoflCur_Transaction_AMNT     NUMERIC(11, 2),
          @Lc_PoflCur_RecoupmentPayee_CODE CHAR(1);

  BEGIN TRY
   DECLARE Pofl_CUR INSENSITIVE CURSOR FOR
    SELECT a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.Case_IDNO,
           a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           SUM (a.PendOffset_AMNT) AS Transaction_AMNT,
           a.RecoupmentPayee_CODE
      FROM POFL_Y1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.CheckRecipient_ID = @Ac_CheckRecipient_ID
       AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
       AND a.Batch_DATE = @Ad_Batch_DATE
       AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
       AND a.Batch_NUMB = @An_Batch_NUMB
       AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     GROUP BY a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.Case_IDNO,
              a.Batch_DATE,
              a.SourceBatch_CODE,
              a.Batch_NUMB,
              a.SeqReceipt_NUMB,
              a.RecoupmentPayee_CODE;

   SET @Ls_Sql_TEXT = 'OPEN POFL_CUR';
   SET @Ls_Sqldata_TEXT ='';

   OPEN Pofl_CUR;

   SET @Ls_Sql_TEXT = 'FETCH POFL_CUR -1';
   SET @Ls_Sqldata_TEXT ='';

   FETCH NEXT FROM Pofl_CUR INTO @Lc_PoflCur_CheckRecipient_ID, @Lc_PoflCur_CheckRecipient_CODE, @Ln_PoflCur_Case_IDNO, @Ld_PoflCur_Batch_DATE, @Lc_PoflCur_SourceBatch_CODE, @Ln_PoflCur_Batch_NUMB, @Ln_PoflCur_SeqReceipt_NUMB, @Ln_PoflCur_Transaction_AMNT, @Lc_PoflCur_RecoupmentPayee_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE - 1';
   SET @Ls_Sqldata_TEXT = '';

   --pending recoupment to active recoupment
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_POFL_CALL1 ';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_PoflCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_PoflCur_CheckRecipient_CODE, '') + ', _RecoupmentPayee_CODE = ' + ISNULL (@Lc_PoflCur_RecoupmentPayee_CODE, '') + ', TypeRecoupment_CODE = ' + @Lc_TypeRecoupment_CODE;

     SELECT @Ln_AssessTotOverpay_AMNT = b.AssessTotOverpay_AMNT,
            @Ln_RecTotOverpay_AMNT = b.RecTotOverpay_AMNT,
            @Ln_PendTotOffset_AMNT = b.PendTotOffset_AMNT
       FROM (SELECT a.AssessTotOverpay_AMNT,
                    a.RecTotOverpay_AMNT,
                    a.PendTotOffset_AMNT,
                    ROW_NUMBER () OVER ( PARTITION BY a.CheckRecipient_ID, a.CheckRecipient_CODE, a.TypeRecoupment_CODE, a.RecoupmentPayee_CODE ORDER BY a.Unique_IDNO DESC) AS rnk
               FROM POFL_Y1 a
              WHERE a.CheckRecipient_ID = @Lc_PoflCur_CheckRecipient_ID
                AND a.CheckRecipient_CODE = @Lc_PoflCur_CheckRecipient_CODE
                AND a.TypeRecoupment_CODE = @Lc_TypeRecoupment_CODE
                AND a.RecoupmentPayee_CODE = @Lc_PoflCur_RecoupmentPayee_CODE) AS b
      WHERE b.rnk = 1;

     SET @Ln_Transaction_AMNT = @Ln_PendTotOffset_AMNT - @Ln_PoflCur_Transaction_AMNT;

     IF @Ln_Transaction_AMNT < 0
      BEGIN
       SET @Ln_Transaction_AMNT = @Ln_PendTotOffset_AMNT;
      END
     ELSE
      BEGIN
       SET @Ln_Transaction_AMNT = @Ln_PoflCur_Transaction_AMNT;
      END
	
	IF @Ln_Transaction_AMNT>0
	BEGIN 
     SET @Ls_Sql_TEXT = 'INSERT_POFL_Y1 ';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST (@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', TypeRecoupment_CODE = ' + @Lc_TypeRecoupment_CODE + ', RecoupmentPayee_CODE = ' + @Lc_PoflCur_RecoupmentPayee_CODE + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Transaction_AMNT = ' + CAST(@Ln_Transaction_AMNT AS VARCHAR) + ', PendTotOffset_AMNT = ' + CAST(@Ln_PendTotOffset_AMNT AS VARCHAR) + ', AssessTotOverpay_AMNT = ' + CAST(@Ln_AssessTotOverpay_AMNT AS VARCHAR) + ', RecTotOverpay_AMNT = ' + CAST(@Ln_RecTotOverpay_AMNT AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_PoflCur_Batch_DATE AS VARCHAR) + ', Batch_NUMB = ' + CAST(@Ln_PoflCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_PoflCur_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_PoflCur_SourceBatch_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@An_EventGlobalSeq_NUMB AS VARCHAR) + ', CheckRecipient_ID = ' + @Lc_PoflCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_PoflCur_CheckRecipient_CODE + ', Case_IDNO = ' + CAST(@Ln_PoflCur_Case_IDNO AS VARCHAR) + ', Space_TEXT = ' + @Lc_Space_TEXT + ', Transaction_CODE = ' + @Lc_Transaction_CODE;

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
             EventGlobalSupportSeq_NUMB)
     VALUES ( @Lc_PoflCur_CheckRecipient_ID,--CheckRecipient_ID
              @Lc_PoflCur_CheckRecipient_CODE,--CheckRecipient_CODE
              @Ln_PoflCur_Case_IDNO,--Case_IDNO
              @Lc_TypeRecoupment_CODE,--TypeRecoupment_CODE
              @Lc_PoflCur_RecoupmentPayee_CODE,--RecoupmentPayee_CODE
              0,--OrderSeq_NUMB
              0,--ObligationSeq_NUMB
              @Ad_Run_DATE,--Transaction_DATE
              @Lc_Space_TEXT,--TypeDisburse_CODE
              @Ln_Transaction_AMNT * -1,--PendOffset_AMNT
              @Ln_PendTotOffset_AMNT - @Ln_Transaction_AMNT,--PendTotOffset_AMNT
              @Ln_Transaction_AMNT,--AssessOverpay_AMNT
              @Ln_AssessTotOverpay_AMNT + @Ln_Transaction_AMNT,--AssessTotOverpay_AMNT
              @Lc_Space_TEXT,--Reason_CODE
              0,--RecAdvance_AMNT
              0,--RecTotAdvance_AMNT
              0,--RecOverpay_AMNT
              @Ln_RecTotOverpay_AMNT,--RecTotOverpay_AMNT
              @Ld_PoflCur_Batch_DATE,--Batch_DATE
              @Ln_PoflCur_Batch_NUMB,--Batch_NUMB
              @Ln_PoflCur_SeqReceipt_NUMB,--SeqReceipt_NUMB
              @Lc_PoflCur_SourceBatch_CODE,--SourceBatch_CODE
              @Lc_Transaction_CODE,--Transaction_CODE
              @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
              @An_EventGlobalSeq_NUMB ); --EventGlobalSupportSeq_NUMB
     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Lc_Err0001_TEXT;

       RAISERROR (50001,16,1);
      END
	END;
     SET @Ln_RowCount_QNTY = 0;
     SET @Ls_Sql_TEXT = 'SELECT RECP_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_PoflCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_PoflCur_CheckRecipient_CODE, '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

     SELECT @Ln_RowCount_QNTY = COUNT(1)
       FROM RECP_Y1 a
      WHERE a.CheckRecipient_ID = @Lc_PoflCur_CheckRecipient_ID
        AND a.CheckRecipient_CODE = @Lc_PoflCur_CheckRecipient_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       --When the system date reaches the 91st calendar day from the date of the original notice (FIN-36 Notice of Overpayment of Support), the pending recoupment balance will automatically be moved to an active recoupment balance. The percentage per disbursement amount will automatically be set to 10%. 
       SET @Ls_Sql_TEXT = 'INSERT RECP_Y1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Lc_PoflCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', CheckRecipient_CODE = ' + @Lc_PoflCur_CheckRecipient_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', No_INDC = ' + @Lc_No_INDC;

       INSERT RECP_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Recoupment_PCT,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               BeginValidity_DATE,
               EndValidity_DATE,
               CpResponse_INDC)
       VALUES ( @Lc_PoflCur_CheckRecipient_ID,--CheckRecipient_ID
                @Lc_PoflCur_CheckRecipient_CODE,--CheckRecipient_CODE
                10,--Recoupment_PCT
                @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                0,--EventGlobalEndSeq_NUMB
                @Ad_Run_DATE,--BeginValidity_DATE
                @Ld_High_DATE,--EndValidity_DATE
                @Lc_No_INDC--CpResponse_INDC
       );

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Lc_Err0001_TEXT;

         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH POFL_CUR -1';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Pofl_CUR INTO @Lc_PoflCur_CheckRecipient_ID, @Lc_PoflCur_CheckRecipient_CODE, @Ln_PoflCur_Case_IDNO, @Ld_PoflCur_Batch_DATE, @Lc_PoflCur_SourceBatch_CODE, @Ln_PoflCur_Batch_NUMB, @Ln_PoflCur_SeqReceipt_NUMB, @Ln_PoflCur_Transaction_AMNT, @Lc_PoflCur_RecoupmentPayee_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Pofl_CUR;

   DEALLOCATE Pofl_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'Pofl_CUR') IN (0, 1)
    BEGIN
     CLOSE Pofl_CUR;

     DEALLOCATE Pofl_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
