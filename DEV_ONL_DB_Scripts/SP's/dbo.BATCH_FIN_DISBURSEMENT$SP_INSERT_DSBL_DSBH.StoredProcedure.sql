/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH
Programmer Name 	: IMP Team
Description			: Procedure to create refund records in DSBH_Y1 and DSBL_Y1.
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On			: BATCH_COMMON$SP_INSERT_PENDING_REQUEST
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH]
 @An_Case_IDNO             NUMERIC(6),
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @Ac_MediumDisburse_CODE   CHAR (1),
 @An_TotDisburse_AMNT      NUMERIC (11, 2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT,
 @An_EventGlobalSeq_NUMB   NUMERIC(19) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Disbursement2245_NUMB               INT = 2245,
          @Lc_RecipientTypeOthp_CODE              CHAR(1) = '3',
          @Lc_Space_TEXT                          CHAR(1) = ' ',
          @Lc_StatusCaseOpen_CODE                 CHAR(1) = 'O',
          @Lc_RespondInitInitiate_CODE            CHAR(1) = 'I',
          @Lc_No_INDC                             CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE                  CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                   CHAR(1) = 'F',
          @Lc_DsbhMediumDisburseCheck_CODE        CHAR(1) = 'C',
          @Lc_DsbhMediumDisburseEft_CODE          CHAR(1) = 'E',
          @Lc_DsbhMediumDisburseSvc_CODE          CHAR(1) = 'B',
          @Lc_ActionProvide_CODE                  CHAR (1) = 'P',
          @Lc_DisburseStatusCashed_CODE           CHAR(2) = 'CA',
          @Lc_DisburseStatusOutstanding_CODE      CHAR(2) = 'OU',
          @Lc_DisburseStatusTransferEft_CODE      CHAR(2) = 'TR',
          @Lc_SourceReceiptSpecialCollection_CODE CHAR(2) = 'SC',
          @Lc_SourceReceiptHomesteadRebate_CODE   CHAR(2) = 'SH',
          @Lc_SourceReceiptSaverRebate_CODE       CHAR(2) = 'SS',
          @Lc_SourceReceiptStateTaxRefund_CODE    CHAR(2) = 'ST',
          @Lc_FunctionCollections_CODE            CHAR(3) = 'COL',
          @Lc_ReasonCitax_CODE                    CHAR(5) = 'CITAX',
          @Lc_Job_ID                              CHAR(7) = 'DEB0620',
          @Lc_CheckRecipientTaxofffee999999977_ID CHAR(9) = '999999977',
          @Lc_CheckRecipientCpdrafee999999978_ID  CHAR(9) = '999999978',
          @Lc_CheckRecipientGtfee999999976_ID     CHAR(9) = '999999976',
          @Lc_CheckRecipientCpNsffee999999964_ID  CHAR(9) = '999999964',
          @Lc_CheckRecipientNcpNsffee999999963_ID CHAR(9) = '999999963',
          @Lc_CheckRecipientOsr999999980_ID       CHAR(9) = '999999980',
          @Lc_CheckRecipientGf_ID                 CHAR(9) = '999999983',
          @Lc_TypeEntityRctno_CODE                CHAR(30) = 'RCTNO',
          @Lc_TypeEntityCase_CODE                 CHAR(30) = 'CASE',
          @Lc_TypeEntityRcpid_CODE                CHAR(30) = 'RCPID',
          @Lc_TypeEntityRcpcd_CODE                CHAR(30) = 'RCPCD',
          @Lc_TypeEntityDisdt_CODE                CHAR(30) = 'DISDT',
          @Lc_TypeEntityDiseq_CODE                CHAR(30) = 'DISEQ',
          @Lc_BatchRunUser_TEXT                   CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME                      VARCHAR(100) = 'SP_INSERT_DSBL_DSBH',
          @Ld_High_DATE                           DATE = '12/31/9999',
          @Ld_Low_DATE                            DATE = '01/01/0001';
  DECLARE @Ln_DisburseSeq_NUMB         NUMERIC(4),
          @Ln_Value_QNTY               NUMERIC(5),
          @Ln_Case_IDNO                NUMERIC(6),
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Ln_EventGlobalSeq_NUMB      NUMERIC(19),
          @Li_RowCount_QNTY            SMALLINT,
          @Lc_Msg_CODE                 CHAR(1),
          @Lc_CheckRecipient_CODE      CHAR(1),
          @Lc_StatusCheck_CODE         CHAR(2),
          @Lc_CheckRecipient_ID        CHAR(10),
          @Lc_ReceiptNo_TEXT           CHAR(30),
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_Sqldata_TEXT             VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(4000),
          @Ld_Issue_DATE               DATE,
          @Ld_System_DATE          DATETIME2(0);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ac_CheckRecipient_ID = LTRIM(RTRIM(@Ac_CheckRecipient_ID));

   SET @Ls_Sql_TEXT = 'SELECT_DSBH_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   SELECT @Ln_DisburseSeq_NUMB = ISNULL (MAX (d.DisburseSeq_NUMB), 0)
     FROM DSBH_Y1 d
    WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND d.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND d.Disburse_DATE = @Ad_Run_DATE;

   SET @Ls_Sql_TEXT = 'DETERMINING STATUS CHECK';
   SET @Ls_Sqldata_TEXT = '';

   IF @Ac_MediumDisburse_CODE = @Lc_DsbhMediumDisburseCheck_CODE
    BEGIN
     IF @Ac_CheckRecipient_ID IN(@Lc_CheckRecipientOsr999999980_ID, @Lc_CheckRecipientTaxofffee999999977_ID, @Lc_CheckRecipientCpdrafee999999978_ID, @Lc_CheckRecipientGtfee999999976_ID,
                                 @Lc_CheckRecipientCpNsffee999999964_ID, @Lc_CheckRecipientNcpNsffee999999963_ID)
        AND @Ac_CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
      BEGIN
       SET @Lc_StatusCheck_CODE = @Lc_DisburseStatusCashed_CODE;
       SET @Ld_Issue_DATE = @Ad_Run_DATE;
      END;
     ELSE
      BEGIN
       SET @Lc_StatusCheck_CODE = @Lc_DisburseStatusOutstanding_CODE;
       SET @Ld_Issue_DATE = @Ld_Low_DATE;
      END;
    END
   ELSE
    BEGIN
     IF @Ac_MediumDisburse_CODE IN (@Lc_DsbhMediumDisburseEft_CODE, @Lc_DsbhMediumDisburseSvc_CODE)
      BEGIN
       SET @Lc_StatusCheck_CODE = @Lc_DisburseStatusTransferEft_CODE;
       SET @Ld_Issue_DATE = @Ld_Low_DATE;
      END;
    END;

   SET @Ln_EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;

   IF @Ac_CheckRecipient_ID IN (@Lc_CheckRecipientTaxofffee999999977_ID, @Lc_CheckRecipientCpdrafee999999978_ID, @Lc_CheckRecipientGtfee999999976_ID, @Lc_CheckRecipientCpNsffee999999964_ID, @Lc_CheckRecipientNcpNsffee999999963_ID)
      AND @Ln_DisburseSeq_NUMB = 0
    BEGIN -- Generate New global event sequence when the check recipient changes
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ FEE';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_Disbursement2245_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_Disbursement2245_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   IF @Ac_CheckRecipient_ID IN (@Lc_CheckRecipientTaxofffee999999977_ID, @Lc_CheckRecipientCpdrafee999999978_ID, @Lc_CheckRecipientGtfee999999976_ID, @Lc_CheckRecipientCpNsffee999999964_ID, @Lc_CheckRecipientNcpNsffee999999963_ID)
      AND @Ln_DisburseSeq_NUMB != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE DSBH_Y1 FEE';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     UPDATE DSBH_Y1
        SET Disburse_AMNT = Disburse_AMNT + @An_TotDisburse_AMNT
      WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
        AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
        AND Disburse_DATE = @Ad_Run_DATE;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE DSBH_Y1 FEE FAILED';

       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ln_DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB + 1;
     SET @Ls_Sql_TEXT = 'INSERT_DSBH_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', MediumDisburse_CODE = ' + ISNULL(@Ac_MediumDisburse_CODE, '') + ', Disburse_AMNT = ' + ISNULL(CAST(@An_TotDisburse_AMNT AS VARCHAR), '') + ', Check_NUMB = ' + ISNULL(CAST(0 AS VARCHAR), '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_StatusCheck_CODE, '') + ', StatusCheck_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL('0', '') + ', Issue_DATE = ' + ISNULL(CAST(@Ld_Issue_DATE AS VARCHAR), '') + ', Misc_ID = ' + ISNULL('', '');

     INSERT DSBH_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             MediumDisburse_CODE,
             Disburse_AMNT,
             Check_NUMB,
             StatusCheck_CODE,
             StatusCheck_DATE,
             ReasonStatus_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             Issue_DATE,
             Misc_ID)
     VALUES (@Ac_CheckRecipient_ID,--CheckRecipient_ID
             @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
             @Ad_Run_DATE,--Disburse_DATE
             @Ln_DisburseSeq_NUMB,--DisburseSeq_NUMB
             @Ac_MediumDisburse_CODE,--MediumDisburse_CODE
             @An_TotDisburse_AMNT,--Disburse_AMNT
             0,--Check_NUMB
             @Lc_StatusCheck_CODE,--StatusCheck_CODE
             @Ad_Run_DATE,--StatusCheck_DATE
             @Lc_Space_TEXT,--ReasonStatus_CODE
             @Ad_Run_DATE,--BeginValidity_DATE
             @Ld_High_DATE,--EndValidity_DATE
             @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
             0,--EventGlobalEndSeq_NUMB
             @Ld_Issue_DATE,--Issue_DATE
             '' --Misc_ID
     );

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_DSBH_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;
    END

   SET @Ls_Sql_TEXT = 'INSERT_DSBL';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '');

   INSERT DSBL_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Disburse_DATE,
           DisburseSeq_NUMB,
           DisburseSubSeq_NUMB,
           Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           EventGlobalSupportSeq_NUMB,
           TypeDisburse_CODE,
           Disburse_AMNT,
           EventGlobalSeq_NUMB)
   (SELECT t.CheckRecipient_ID,
           t.CheckRecipient_CODE,
           @Ad_Run_DATE AS Disburse_DATE,
           @Ln_DisburseSeq_NUMB AS DisburseSeq_NUMB,
           t.DisburseSubSeq_NUMB,
           t.Case_IDNO,
           t.OrderSeq_NUMB,
           t.ObligationSeq_NUMB,
           t.Batch_DATE,
           t.SourceBatch_CODE,
           t.Batch_NUMB,
           t.SeqReceipt_NUMB,
           t.EventGlobalSupportSeq_NUMB,
           t.TypeDisburse_CODE,
           t.Transaction_AMNT,
           @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB
      FROM #Tlhld_P1 t
     WHERE t.CheckRecipient_ID = @Ac_CheckRecipient_ID
       AND t.CheckRecipient_CODE = @Ac_CheckRecipient_CODE);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_DSBL FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'SELECT_TLHLD';
   SET @Ls_Sqldata_TEXT = '';

   SELECT TOP 1 @Ln_Value_QNTY = COUNT (1)
     FROM #Tlhld_P1 t
    WHERE t.Disburse_DATE <> @Ld_Low_DATE;

   IF @Ln_Value_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_DSBC_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalOrigSeq_NUMB = ' + ISNULL('0', '');

     INSERT DSBC_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             EventGlobalSeq_NUMB,
             CheckRecipientOrig_ID,
             CheckRecipientOrig_CODE,
             DisburseOrig_DATE,
             DisburseOrigSeq_NUMB,
             EventGlobalOrigSeq_NUMB)
     SELECT DISTINCT
            @Ac_CheckRecipient_ID AS CheckRecipient_ID,
            @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,
            @Ad_Run_DATE AS Disburse_DATE,
            @Ln_DisburseSeq_NUMB AS DisburseSeq_NUMB,
            @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
            t.CheckRecipient_ID,
            t.CheckRecipient_CODE,
            t.Disburse_DATE,
            t.DisburseSeq_NUMB,
            0 AS EventGlobalOrigSeq_NUMB
       FROM #Tlhld_P1 t
      WHERE t.Disburse_DATE <> @Ld_Low_DATE;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_DSBC_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;
    END

   -- There should not be an elog entry for OSR recipient..
   IF @Ac_CheckRecipient_ID NOT IN (@Lc_CheckRecipientOsr999999980_ID, @Lc_CheckRecipientTaxofffee999999977_ID, @Lc_CheckRecipientCpdrafee999999978_ID, @Lc_CheckRecipientGtfee999999976_ID,
                                    @Lc_CheckRecipientCpNsffee999999964_ID, @Lc_CheckRecipientNcpNsffee999999963_ID)
    BEGIN
     IF @Ac_CheckRecipient_ID != @Lc_CheckRecipientGf_ID
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_PESEM_DSBL_DSBH DISB';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_Case_IDNO = t.Case_IDNO,
              @Lc_ReceiptNo_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (t.Batch_DATE, t.SourceBatch_CODE, t.Batch_NUMB, t.SeqReceipt_NUMB),
              @Lc_CheckRecipient_ID = t.CheckRecipient_ID,
              @Lc_CheckRecipient_CODE = t.CheckRecipient_CODE
         FROM #Tlhld_P1 t;

       SET @Ls_Sql_TEXT = 'INSERT_PESEM_DSBL_DSBH DISB - 2';
       SET @Ls_Sqldata_TEXT = '';

       INSERT INTO PESEM_Y1
                   (Entity_ID,
                    EventGlobalSeq_NUMB,
                    TypeEntity_CODE,
                    EventFunctionalSeq_NUMB)
       SELECT @Lc_ReceiptNo_TEXT,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRctno_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT CAST(@Ln_Case_IDNO AS VARCHAR),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityCase_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT @Lc_CheckRecipient_ID,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRcpid_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT @Lc_CheckRecipient_CODE,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRcpcd_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityDisdt_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT CAST (@Ln_DisburseSeq_NUMB AS VARCHAR),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityDiseq_CODE,
              @Li_Disbursement2245_NUMB;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_DSBL_DSBH DISB - 2 FAILED';

         RAISERROR (50001,16,1);
        END;
      END;
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_PESEM_DSBL_DSBH ESCHEAT';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_Case_IDNO = t.Case_IDNO,
              @Lc_ReceiptNo_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (t.Batch_DATE, t.SourceBatch_CODE, t.Batch_NUMB, t.SeqReceipt_NUMB),
              @Lc_CheckRecipient_ID = t.CheckRecipient_ID,
              @Lc_CheckRecipient_CODE = t.CheckRecipient_CODE
         FROM #Tlhld_P1 t;

       SET @Ls_Sql_TEXT = 'INSERT_PESEM_DSBL_DSBH ESCHEAT';
       SET @Ls_Sqldata_TEXT = '';

       INSERT INTO PESEM_Y1
                   (Entity_ID,
                    EventGlobalSeq_NUMB,
                    TypeEntity_CODE,
                    EventFunctionalSeq_NUMB)
       SELECT @Lc_ReceiptNo_TEXT,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRctno_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT CAST(@Ln_Case_IDNO AS VARCHAR),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityCase_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT @Lc_CheckRecipient_ID,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRcpid_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT @Lc_CheckRecipient_CODE,
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityRcpcd_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT REPLACE(CONVERT(VARCHAR(10), @Ad_Run_DATE, 101), '/', ''),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityDisdt_CODE,
              @Li_Disbursement2245_NUMB
       UNION ALL
       SELECT CAST (@Ln_DisburseSeq_NUMB AS VARCHAR),
              @An_EventGlobalSeq_NUMB,
              @Lc_TypeEntityDiseq_CODE,
              @Li_Disbursement2245_NUMB;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_DSBL_DSBH ESCHEAT FAILED';

         RAISERROR (50001,16,1);
        END;
      END;
    END

   -- To Check the IRS record exists or not and the case is interstate case or not
   SET @Ls_Sql_TEXT = 'SELECT TOP 1 FROM #Tlhld_P1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_CODE = ' + ISNULL('1', '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_RespondInitInitiate_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT TOP 1 @Ln_Value_QNTY = COUNT (1)
     FROM #Tlhld_P1 a,
          CASE_Y1 b
    WHERE CheckRecipient_CODE = 1
      AND a.Case_IDNO = @An_Case_IDNO
      AND b.Case_IDNO = a.Case_IDNO
      AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND b.RespondInit_CODE = @Lc_RespondInitInitiate_CODE
      AND EXISTS (SELECT 1
                    FROM RCTH_Y1 c
                   WHERE c.SourceBatch_CODE = a.SourceBatch_CODE
                     AND c.Batch_DATE = a.Batch_DATE
                     AND c.Batch_NUMB = a.Batch_NUMB
                     AND c.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                     AND c.SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptHomesteadRebate_CODE, @Lc_SourceReceiptSaverRebate_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
                     AND c.EndValidity_DATE = @Ld_High_DATE);

   IF (@Ln_Value_QNTY > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ld_System_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

     SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', RespondentMci_IDNO = 0 ' + ', Function_CODE = ' + @Lc_FunctionCollections_CODE + ', Action_CODE = ' + @Lc_ActionProvide_CODE + ', Reason_CODE = ' + @Lc_ReasonCitax_CODE + ', IVDOutOfStateFips_CODE = ' + @Lc_Space_TEXT + ', IVDOutOfStateCountyFips_CODE = ' + @Lc_Space_TEXT + ', IVDOutOfStateOfficeFips_CODE = ' + @Lc_Space_TEXT + ', IVDOutOfStateCase_ID = ' + @Lc_Space_TEXT + ', Generated_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Form_ID = 0 ' + ', FormWeb_URL = ' + @Lc_Space_TEXT + ', TransHeader_IDNO = 0 ' + ', DescriptionComments_TEXT = ' + @Lc_Space_TEXT + ', CaseFormer_ID = ' + @Lc_Space_TEXT + ', InsCarrier_NAME = ' + @Lc_Space_TEXT + ', InsPolicyNo_TEXT = ' + @Lc_Space_TEXT + ', Hearing_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', Dismissal_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', GeneticTest_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', PfNoShow_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', Attachment_INDC = ' + @Lc_No_INDC + ', File_ID = ' + @Lc_Space_TEXT + ', ArrearComputed_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', TotalArrearsOwed_AMNT = ' + CAST(0 AS VARCHAR) + ', TotalInterestOwed_AMNT = ' + CAST(0 AS VARCHAR) + ', Process_ID  = ' + @Lc_Job_ID + ', BeginValidity_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', SignedonWorker_ID = ' + @Lc_BatchRunUser_TEXT + ', Update_DTTM = ' + CAST(@Ld_System_DATE AS VARCHAR) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);
     EXECUTE BATCH_COMMON$SP_INSERT_PENDING_REQUEST
      @An_Case_IDNO                    = @An_Case_IDNO,
      @An_RespondentMci_IDNO           = 0,
      @Ac_Function_CODE                = @Lc_FunctionCollections_CODE,
      @Ac_Action_CODE                  = @Lc_ActionProvide_CODE,
      @Ac_Reason_CODE                  = @Lc_ReasonCitax_CODE,
      @Ac_IVDOutOfStateFips_CODE       = @Lc_Space_TEXT,
      @Ac_IVDOutOfStateCountyFips_CODE = @Lc_Space_TEXT,
      @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_Space_TEXT,
      @Ac_IVDOutOfStateCase_ID         = @Lc_Space_TEXT,
      @Ad_Generated_DATE               = @Ad_Run_DATE,
      @Ac_Form_ID                      = 0,
      @As_FormWeb_URL                  = @Lc_Space_TEXT,
      @An_TransHeader_IDNO             = 0,
      @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
      @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
      @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
      @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
      @Ad_Hearing_DATE                 = @Ld_Low_DATE,
      @Ad_Dismissal_DATE               = @Ld_Low_DATE,
      @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
      @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
      @Ac_Attachment_INDC              = @Lc_No_INDC,
      @Ac_File_ID                      = @Lc_Space_TEXT,
      @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
      @An_TotalArrearsOwed_AMNT        = 0,
      @An_TotalInterestOwed_AMNT       = 0,
      @Ac_Process_ID                   = @Lc_Job_ID,
      @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
      @Ac_SignedonWorker_ID            = @Lc_BatchRunUser_TEXT,
      @Ad_Update_DTTM                  = @Ld_System_DATE,
      @An_TransactionEventSeq_NUMB     = @Ln_TransactionEventSeq_NUMB,
      @Ac_Msg_CODE                     = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT        = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END;

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
  END CATCH;
 END


GO
