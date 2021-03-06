/****** Object:  StoredProcedure [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD
Programmer Name 	: IMP Team
Description			: Insert the DHLD records based on the Status code and Disbursement Type 
Frequency			: 'MONTHLY'
Developed On		: 03/24/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_TANF_DISTRIBUTION$SP_INSERT_DHLD]
 @An_Case_IDNO                  NUMERIC(6),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ad_Receipt_DATE               DATE,
 @An_TransactionCs_AMNT         NUMERIC (11, 2),
 @An_TransactionPaa_AMNT        NUMERIC(11, 2),
 @Ac_TypeHold_CODE              CHAR(1),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @Ac_TypeDisbursementDhld_CODE  CHAR (5),
 @Ac_ProcessOffset_INDC         CHAR(1),
 @Ac_Status_CODE                CHAR(1),
 @Ac_Reason_CODE                CHAR(5),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @Ac_SourceReceipt_CODE         CHAR(2),
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR (4000) OUTPUT,
 @Ad_Process_DATE               DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Ln_CheckRecipientDSS999999994_IDNO  NUMERIC(10) = 999999994,
           @Li_TanfDisbursementHold1840_NUMB    INT = 1840,
           @Lc_RecipientTypeOthp_CODE           CHAR(1) = '3',
           @Lc_Space_TEXT                       CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
           @Lc_StatusFailed_CODE                CHAR(1) = 'F',
           @Lc_DisbursementStatusHeld_CODE      CHAR(1) = 'H',
           @Lc_SourceReceiptNsfRecoupment_CODE  CHAR(2) = 'NR',
           @Lc_TypeDisbursementHold_CODE        CHAR(4) = 'HOLD',
           @Lc_TypeDisbursementGrant_CODE       CHAR(4) = 'GRNT',
           @Lc_TypeDisbursementPrnt_CODE        CHAR(4) = 'PRNT',
           @Lc_TypeDisbursementExcs_CODE        CHAR(4) = 'EXCS',
           @Lc_TypeDisbursementChpaa_CODE       CHAR(5) = 'CHPAA',
           @Lc_DisbursementTypeCgpaa_CODE       CHAR(5) = 'CGPAA',
           @Lc_TypeDisbursementPgpaa_CODE       CHAR(5) = 'PGPAA',
           @Lc_TypeDisbursementCxpaa_CODE       CHAR(5) = 'CXPAA',
           @Lc_TypeDisbursementAgpaa_CODE       CHAR(5) = 'AGPAA',
           @Lc_TypeDisbursementAhpaa_CODE       CHAR(5) = 'AHPAA',
           @Lc_DisbursementTypeAxpaa_CODE       CHAR(5) = 'AXPAA',
           @Ls_Sql_TEXT                         VARCHAR(100) = ' ',
           @Ls_Procedure_NAME                   VARCHAR(100) = 'SP_INSERT_DHLD',
           @Ls_Sqldata_TEXT                     VARCHAR(1000) = ' ',
           @Ld_High_DATE                        DATE = '12/31/9999',
           @Ld_Low_DATE                         DATE = '01/01/0001';
  DECLARE  @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Li_FetchStatus_QNTY       SMALLINT,
           @Ls_ErrorMessage_TEXT      VARCHAR(2000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);
  DECLARE  @Lc_EsemHoldCur_TypeEntity_CODE  CHAR (5),
		   @Lc_EsemHoldCur_Entity_ID        CHAR (30),
		   @Ln_EsemHoldCur_Row_NUMB         NUMERIC (19);
  BEGIN TRY
   SET @Ac_Msg_CODE = '';

   IF @Ac_Status_CODE = @Lc_DisbursementStatusHeld_CODE
    BEGIN
  
   DECLARE EsemHold_Cur INSENSITIVE CURSOR FOR
   SELECT e.TypeEntity_CODE,
          e.Entity_ID,
          e.Row_NUMB
     FROM #EsemHold_P1 e;
     
     SET @Ls_Sql_TEXT = 'OPEN EsemHold_Cur-1';   
     SET @Ls_Sqldata_TEXT = '';  
     
     OPEN EsemHold_Cur;

     SET @Ls_Sql_TEXT = 'FETCH  EsemHold_Cur-1';     
     SET @Ls_Sqldata_TEXT = '';
     
     FETCH NEXT FROM EsemHold_Cur INTO @Lc_EsemHoldCur_TypeEntity_CODE, @Lc_EsemHoldCur_Entity_ID, @Ln_EsemHoldCur_Row_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'WHILE LOOP -1';	 
     SET @Ls_Sqldata_TEXT = '';
     
     -- TO INSERT IN ESEM_Y1 table
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1_HOLD_1840';
       SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL(@Lc_EsemHoldCur_TypeEntity_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_TanfDisbursementHold1840_NUMB AS VARCHAR ),'')+ ', Entity_ID = ' + ISNULL(@Lc_EsemHoldCur_Entity_ID,'');

       INSERT INTO ESEM_Y1
                   (TypeEntity_CODE,
                    EventGlobalSeq_NUMB,
                    EventFunctionalSeq_NUMB,
                    Entity_ID)
            VALUES (@Lc_EsemHoldCur_TypeEntity_CODE,    --TypeEntity_CODE
                    @An_EventGlobalSeq_NUMB,    --EventGlobalSeq_NUMB
                    @Li_TanfDisbursementHold1840_NUMB,    --EventFunctionalSeq_NUMB
                    @Lc_EsemHoldCur_Entity_ID  --Entity_ID
			); 

       SET @Ls_Sql_TEXT = 'FETCH  EsemHold_Cur-2';       
       SET @Ls_Sqldata_TEXT = '';
       
       FETCH NEXT FROM EsemHold_Cur INTO @Lc_EsemHoldCur_TypeEntity_CODE, @Lc_EsemHoldCur_Entity_ID, @Ln_EsemHoldCur_Row_NUMB;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END
	 CLOSE EsemHold_Cur;

     DEALLOCATE EsemHold_Cur;  
     
     SET @Ls_Sql_TEXT = 'DELETE #EsemHold_P1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE FROM #EsemHold_P1;
    END;

   SET @Ls_Sql_TEXT = 'INSERT_DHLD_CS';   
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @An_TransactionCs_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Ac_Status_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Ac_ProcessOffset_INDC,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Ac_Reason_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                Status_CODE,
                TypeHold_CODE,
                TypeDisburse_CODE,
                ProcessOffset_INDC,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Release_DATE,
                ReasonStatus_CODE,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   (SELECT @An_Case_IDNO AS Case_IDNO,
           @An_OrderSeq_NUMB AS OrderSeq_NUMB,
           @An_ObligationSeq_NUMB AS ObligationSeq_NUMB,
           @Ad_Batch_DATE AS Batch_DATE,
           @An_Batch_NUMB AS Batch_NUMB,
           @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
           @Ac_SourceBatch_CODE AS SourceBatch_CODE,
           @Ad_Process_DATE AS Transaction_DATE,
           @An_TransactionCs_AMNT AS Transaction_AMNT,
           @Ac_Status_CODE AS Status_CODE,
           @Ac_TypeHold_CODE AS TypeHold_CODE,
           CASE @Ac_TypeDisburse_CODE
            WHEN @Lc_TypeDisbursementHold_CODE
             THEN @Lc_TypeDisbursementChpaa_CODE
            WHEN @Lc_TypeDisbursementGrant_CODE
             THEN @Lc_DisbursementTypeCgpaa_CODE
            WHEN @Lc_TypeDisbursementPrnt_CODE
             THEN @Lc_TypeDisbursementPgpaa_CODE
            WHEN @Lc_TypeDisbursementExcs_CODE
             THEN @Lc_TypeDisbursementCxpaa_CODE
           END AS TypeDisburse_CODE,
           @Ac_ProcessOffset_INDC AS ProcessOffset_INDC,
           CASE
            WHEN @Ac_SourceReceipt_CODE = @Lc_SourceReceiptNsfRecoupment_CODE
             THEN @Ac_CheckRecipient_ID
            ELSE
             CASE @Ac_TypeDisburse_CODE
              WHEN @Lc_TypeDisbursementHold_CODE
               THEN @Ac_CheckRecipient_ID
              WHEN @Lc_TypeDisbursementGrant_CODE
               THEN
             -- Only possible values starting with OFFICE are OFFICE%6 (CWA offices), All CWA offices (Office number ending with 6) payments will be sent to DSS - 999999994 - DELAWARE DIVISION OF SOCIAL SERVICES.
             @Ln_CheckRecipientDSS999999994_IDNO
              WHEN @Lc_TypeDisbursementPrnt_CODE
               THEN @Ln_CheckRecipientDSS999999994_IDNO
              WHEN @Lc_TypeDisbursementExcs_CODE
               THEN @Ac_CheckRecipient_ID
             END
           END AS CheckRecipient_ID,
           CASE
            WHEN @Ac_SourceReceipt_CODE = @Lc_SourceReceiptNsfRecoupment_CODE
             THEN @Ac_CheckRecipient_CODE
            ELSE
             CASE @Ac_TypeDisburse_CODE
              WHEN @Lc_TypeDisbursementHold_CODE
               THEN @Ac_CheckRecipient_CODE
              WHEN @Lc_TypeDisbursementGrant_CODE
               THEN @Lc_RecipientTypeOthp_CODE
              WHEN @Lc_TypeDisbursementPrnt_CODE
               THEN @Lc_RecipientTypeOthp_CODE
              WHEN @Lc_TypeDisbursementExcs_CODE
               THEN @Ac_CheckRecipient_CODE
             END
           END AS CheckRecipient_CODE,
           @Ad_Process_DATE AS BeginValidity_DATE,
           @Ld_High_DATE AS EndValidity_DATE,
           @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
           0 AS EventGlobalEndSeq_NUMB,
           @An_EventGlobalSupportSeq_NUMB AS EventGlobalSupportSeq_NUMB,
           CASE @Ac_TypeDisburse_CODE
            WHEN @Lc_TypeDisbursementHold_CODE
             THEN @Ad_Receipt_DATE
            ELSE @Ad_Process_DATE
           END AS Release_DATE,
           @Ac_Reason_CODE AS ReasonStatus_CODE,
           @Ld_Low_DATE AS Disburse_DATE,
           0 AS DisburseSeq_NUMB,
           @Ld_High_DATE AS StatusEscheat_DATE,
           @Lc_Space_TEXT AS StatusEscheat_CODE
     WHERE @An_TransactionCs_AMNT > 0);

   SET @Ls_Sql_TEXT = 'INSERT_DHLD_PA';   
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @An_TransactionPaa_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Ac_Status_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Ac_ProcessOffset_INDC,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Ac_Reason_CODE,'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

   INSERT INTO DHLD_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                Batch_DATE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                SourceBatch_CODE,
                Transaction_DATE,
                Transaction_AMNT,
                Status_CODE,
                TypeHold_CODE,
                TypeDisburse_CODE,
                ProcessOffset_INDC,
                CheckRecipient_ID,
                CheckRecipient_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                Release_DATE,
                ReasonStatus_CODE,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
   SELECT @An_Case_IDNO AS Case_IDNO,
          @An_OrderSeq_NUMB AS OrderSeq_NUMB,
          @An_ObligationSeq_NUMB AS ObligationSeq_NUMB,
          @Ad_Batch_DATE AS Batch_DATE,
          @An_Batch_NUMB AS Batch_NUMB,
          @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
          @Ac_SourceBatch_CODE AS SourceBatch_CODE,
          @Ad_Process_DATE AS Transaction_DATE,
          @An_TransactionPaa_AMNT AS Transaction_AMNT,
          @Ac_Status_CODE AS Status_CODE,
          @Ac_TypeHold_CODE AS TypeHold_CODE,
          CASE @Ac_TypeDisburse_CODE
           WHEN @Lc_TypeDisbursementGrant_CODE
            THEN
            CASE
             WHEN @Ac_TypeDisbursementDhld_CODE = @Lc_TypeDisbursementChpaa_CODE
              THEN @Lc_TypeDisbursementPgpaa_CODE
             ELSE @Lc_TypeDisbursementAgpaa_CODE
            END
           WHEN @Lc_TypeDisbursementHold_CODE
            THEN
            CASE
             WHEN @Ac_TypeDisbursementDhld_CODE = @Lc_TypeDisbursementChpaa_CODE
              THEN @Lc_TypeDisbursementChpaa_CODE
             ELSE @Lc_TypeDisbursementAhpaa_CODE
            END
           WHEN @Lc_TypeDisbursementExcs_CODE
            THEN
            CASE
             WHEN @Ac_TypeDisbursementDhld_CODE = @Lc_TypeDisbursementChpaa_CODE
              THEN @Lc_TypeDisbursementCxpaa_CODE
             ELSE @Lc_DisbursementTypeAxpaa_CODE
            END
          END AS TypeDisburse_CODE,
          @Ac_ProcessOffset_INDC AS ProcessOffset_INDC,
          CASE
           WHEN @Ac_SourceReceipt_CODE = @Lc_SourceReceiptNsfRecoupment_CODE
            THEN @Ac_CheckRecipient_ID
           ELSE
            CASE @Ac_TypeDisburse_CODE
             WHEN @Lc_TypeDisbursementGrant_CODE
              THEN
            -- Only possible values starting with OFFICE are OFFICE%6 (CWA offices), All CWA offices (Office number ending with 6) payments will be sent to DSS - 999999994 - DELAWARE DIVISION OF SOCIAL SERVICES.
            @Ln_CheckRecipientDSS999999994_IDNO
             WHEN @Lc_TypeDisbursementHold_CODE
              THEN @Ac_CheckRecipient_ID
             WHEN @Lc_TypeDisbursementExcs_CODE
              THEN @Ac_CheckRecipient_ID
            END
          END AS CheckRecipient_ID,
          CASE
           WHEN @Ac_SourceReceipt_CODE = @Lc_SourceReceiptNsfRecoupment_CODE
            THEN @Ac_CheckRecipient_CODE
           ELSE
            CASE @Ac_TypeDisburse_CODE
             WHEN @Lc_TypeDisbursementGrant_CODE
              THEN @Lc_RecipientTypeOthp_CODE
             WHEN @Lc_TypeDisbursementHold_CODE
              THEN @Ac_CheckRecipient_CODE
             WHEN @Lc_TypeDisbursementExcs_CODE
              THEN @Ac_CheckRecipient_CODE
            END
          END AS CheckRecipient_CODE,
          @Ad_Process_DATE AS BeginValidity_DATE,
          @Ld_High_DATE AS EndValidity_DATE,
          @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
          0 AS EventGlobalEndSeq_NUMB,
          @An_EventGlobalSupportSeq_NUMB AS EventGlobalSupportSeq_NUMB,
          @Ad_Process_DATE AS Release_DATE,
          @Ac_Reason_CODE AS ReasonStatus_CODE,
          @Ld_Low_DATE AS Disburse_DATE,
          0 AS DisburseSeq_NUMB,
          @Ld_High_DATE AS StatusEscheat_DATE,
          @Lc_Space_TEXT AS StatusEscheat_CODE
    WHERE @An_TransactionPaa_AMNT > 0;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
    IF CURSOR_STATUS ('LOCAL', 'EsemHold_Cur') IN (0, 1)
	  BEGIN
	   CLOSE EsemHold_Cur;

	   DEALLOCATE EsemHold_Cur;
	  END
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

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
