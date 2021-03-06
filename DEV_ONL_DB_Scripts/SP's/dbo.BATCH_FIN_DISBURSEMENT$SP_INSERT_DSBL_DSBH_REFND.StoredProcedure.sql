/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH_REFND]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH_REFND
Programmer Name 	: IMP Team
Description			: Procedure to create refund records in DSBH_Y1 and DSBL_Y1.
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On			: None
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_DSBL_DSBH_REFND]
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @Ac_MediumDisburse_CODE   CHAR (1),
 @An_Disburse_AMNT         NUMERIC (11, 2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT,
 @An_EventGlobalSeq_NUMB   NUMERIC(19) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Disbursement2245_NUMB               INT = 2245,
          @Lc_Space_TEXT                          CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE                  CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                   CHAR(1) = 'F',
          @Lc_MediumDisburseCheck_CODE            CHAR(1) = 'C',
          @Lc_MediumDisburseEft_CODE              CHAR(1) = 'E',
          @Lc_MediumDisburseSvc_CODE              CHAR(1) = 'B',
          @Lc_DisburseStatusCheckOutstanding_CODE CHAR(2) = 'OU',
          @Lc_DisburseStatusCheckTransferEft_CODE CHAR(2) = 'TR',
          @Lc_TypeEntityRctno_CODE                CHAR(30) = 'RCTNO',
          @Lc_TypeEntityCase_CODE                 CHAR(30) = 'CASE',
          @Lc_TypeEntityRcpid_CODE                CHAR(30) = 'RCPID',
          @Lc_TypeEntityRcpcd_CODE                CHAR(30) = 'RCPCD',
          @Lc_TypeEntityDisdt_CODE                CHAR(30) = 'DISDT',
          @Lc_TypeEntityDiseq_CODE                CHAR(30) = 'DISEQ',
          @Ls_Procedure_NAME                      VARCHAR(100) = 'SP_INSERT_DSBL_DSBH_REFND',
          @Ld_Low_DATE                            DATE = '01/01/0001',
          @Ld_High_DATE                           DATE = '12/31/9999';
  DECLARE @Ln_DisburseSeq_NUMB    NUMERIC(4),
          @Ln_Value_QNTY          NUMERIC(5),
          @Ln_Case_IDNO           NUMERIC(6),
          @Ln_Error_NUMB          NUMERIC(11),
          @Ln_ErrorLine_NUMB      NUMERIC(11),
          @Li_Rowcount_QNTY       SMALLINT,
          @Lc_CheckRecipient_CODE CHAR(1),
          @Lc_StatusCheck_CODE    CHAR(2),
          @Lc_CheckRecipient_ID   CHAR(10),
          @Lc_ReceiptNo_TEXT      CHAR(30),
          @Ls_Sql_TEXT            VARCHAR(100) = '',
          @Ls_Sqldata_TEXT        VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT   VARCHAR(4000),
          @Ld_Issue_DATE          DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_Sql_TEXT = 'SELECT_DSBH_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   SELECT @Ln_DisburseSeq_NUMB = ISNULL (MAX (DisburseSeq_NUMB), 0) + 1
     FROM DSBH_Y1 a
    WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND Disburse_DATE = @Ad_Run_DATE;

   IF @Ac_MediumDisburse_CODE = @Lc_MediumDisburseCheck_CODE
    BEGIN
     SET @Lc_StatusCheck_CODE = @Lc_DisburseStatusCheckOutstanding_CODE;
     SET @Ld_Issue_DATE = @Ld_Low_DATE;
    END;
   ELSE
    BEGIN
     IF @Ac_MediumDisburse_CODE IN (@Lc_MediumDisburseEft_CODE, @Lc_MediumDisburseSvc_CODE)
      BEGIN
       SET @Lc_StatusCheck_CODE = @Lc_DisburseStatusCheckTransferEft_CODE;
       SET @Ld_Issue_DATE = @Ld_Low_DATE;
      END;
    END;

   SET @Ls_Sql_TEXT = 'INSERT_DSBH_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', MediumDisburse_CODE = ' + ISNULL(@Ac_MediumDisburse_CODE, '') + ', Disburse_AMNT = ' + ISNULL(CAST(@An_Disburse_AMNT AS VARCHAR), '') + ', Check_NUMB = ' + ISNULL('0', '') + ', StatusCheck_CODE = ' + ISNULL(@Lc_StatusCheck_CODE, '') + ', StatusCheck_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL('0', '') + ', Issue_DATE = ' + ISNULL(CAST(@Ld_Issue_DATE AS VARCHAR), '') + ', Misc_ID = ' + ISNULL('', '');

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
           @An_Disburse_AMNT,--Disburse_AMNT
           0,--Check_NUMB
           @Lc_StatusCheck_CODE,--StatusCheck_CODE
           @Ad_Run_DATE,--StatusCheck_DATE
           @Lc_Space_TEXT,--ReasonStatus_CODE
           @Ad_Run_DATE,--BeginValidity_DATE
           @Ld_High_DATE,--EndValidity_DATE
           @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
           0,--EventGlobalEndSeq_NUMB
           @Ld_Issue_DATE,--Issue_DATE
           @Lc_Space_TEXT --Misc_ID
   );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_DSBH_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT_DSBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Disburse_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DisburseSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '');

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
      FROM #Tlhld_P1 t);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_DSBL_Y1 FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'SELECT_#Tlhld_P1';
   SET @Ls_Sqldata_TEXT = '';

   SELECT TOP 1 @Ln_Value_QNTY = COUNT (1)
     FROM #Tlhld_P1 a
    WHERE a.Disburse_DATE <> @Ld_Low_DATE;

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

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_DSBC_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'INSERT_PESEM_DSBL_DSBH';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_Case_IDNO = t.Case_IDNO,
          @Lc_ReceiptNo_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (t.Batch_DATE, t.SourceBatch_CODE, t.Batch_NUMB, t.SeqReceipt_NUMB),
          @Lc_CheckRecipient_ID = t.CheckRecipient_ID,
          @Lc_CheckRecipient_CODE = t.CheckRecipient_CODE
     FROM #Tlhld_P1 t;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_DSBL_DSBH FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT_PESEM_DSBL_DSBH';
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
   SELECT CAST(@Ln_DisburseSeq_NUMB AS VARCHAR),
          @An_EventGlobalSeq_NUMB,
          @Lc_TypeEntityDiseq_CODE,
          @Li_Disbursement2245_NUMB;

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
 END;


GO
