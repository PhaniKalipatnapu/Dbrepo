/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CREATE_RCTH_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CREATE_RCTH_HOLD
Programmer Name		: IMP Team
Description			: This procedure is used create receipt hold record using input receipt (Batch_DATE, SourceBatch_CODE, 
					  Batch_NUMB, SeqReceipt_NUMB)
Frequency			:
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CREATE_RCTH_HOLD]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusReceiptIdentified_CODE CHAR(1) = 'I',
          @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_ReasonStatusSner_CODE        CHAR(4) = 'SNER',
          @Lc_Worker_ID					   CHAR(5) = 'DECSS',          
          @Lc_Process_ID                   CHAR(10) = 'EMERGENCY',
          @Ls_Procedure_NAME               VARCHAR(60) = 'BATCH_COMMON$SP_CREATE_RCTH_HOLD',
          @Ld_Low_DATE                     DATE = '01/01/0001',
          @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_RowCount_QNTY         NUMERIC,
          @Ln_Value_QNTY            NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB   NUMERIC(19),
          @Lc_Msg_CODE              CHAR(1) = '',
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_Value_QNTY = COUNT (1)
     FROM RCTH_Y1 A
    WHERE A.Batch_DATE = @Ad_Batch_DATE
      AND A.Batch_NUMB = @An_Batch_NUMB
      AND A.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND A.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND A.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
      AND A.Distribute_DATE = @Ld_Low_DATE
      AND A.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Value_QNTY = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
     SET @Ls_Sqldata_TEXT = 'Process_ID = ' + ISNULL (@Lc_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR (10)), '') + ', INDICATOR NOTE = ' + CAST (@Lc_No_INDC AS VARCHAR (1)) + ', WORKER ID = ' + @Lc_Worker_ID;

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = 0,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_Worker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ad_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
      WHERE RCTH_Y1.Batch_DATE = @Ad_Batch_DATE
        AND RCTH_Y1.Batch_NUMB = @An_Batch_NUMB
        AND RCTH_Y1.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND RCTH_Y1.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND RCTH_Y1.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
        AND RCTH_Y1.Distribute_DATE = @Ld_Low_DATE
        AND RCTH_Y1.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 - SNER HOLD';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ad_Batch_DATE AS VARCHAR) + ', Batch_NUMB = ' + CAST(@An_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@An_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Ac_SourceBatch_CODE +', StatusReceipt_CODE = ' + @Lc_StatusReceiptIdentified_CODE +', Distribute_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) +', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR); 

     INSERT RCTH_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             Case_IDNO,
             PayorMCI_IDNO,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Fee_AMNT,
             Employer_IDNO,
             Fips_CODE,
             Check_DATE,
             CheckNo_Text,
             Receipt_DATE,
             Distribute_DATE,
             Tanf_CODE,
             TaxJoint_CODE,
             TaxJoint_NAME,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             BackOut_INDC,
             ReasonBackOut_CODE,
             Refund_DATE,
             Release_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB)
     SELECT A.Batch_DATE,--Batch_DATE
            A.SourceBatch_CODE,--SourceBatch_CODE
            A.Batch_NUMB,--Batch_NUMB
            A.SeqReceipt_NUMB,--SeqReceipt_NUMB
            A.SourceReceipt_CODE,--SourceReceipt_CODE
            A.TypeRemittance_CODE,--TypeRemittance_CODE
            A.TypePosting_CODE,--TypePosting_CODE
            A.Case_IDNO,--Case_IDNO
            A.PayorMCI_IDNO,--PayorMCI_IDNO
            A.Receipt_AMNT,--Receipt_AMNT
            A.ToDistribute_AMNT,--ToDistribute_AMNT
            A.Fee_AMNT,--Fee_AMNT
            A.Employer_IDNO,--Employer_IDNO
            A.Fips_CODE,--Fips_CODE
            A.Check_DATE,--Check_DATE
            A.CheckNo_Text,--CheckNo_Text
            A.Receipt_DATE,--Receipt_DATE
            A.Distribute_DATE,--Distribute_DATE
            A.Tanf_CODE,--Tanf_CODE
            A.TaxJoint_CODE,--TaxJoint_CODE
            A.TaxJoint_NAME,--TaxJoint_NAME
            @Lc_StatusReceiptHeld_CODE AS StatusReceipt_CODE,
            @Lc_ReasonStatusSner_CODE AS ReasonStatus_CODE,
            A.BackOut_INDC,--BackOut_INDC
            A.ReasonBackOut_CODE,--ReasonBackOut_CODE
            A.Refund_DATE,--Refund_DATE
            @Ld_High_DATE AS Release_DATE,
            A.ReferenceIrs_IDNO,--ReferenceIrs_IDNO
            A.RefundRecipient_ID,--RefundRecipient_ID
            A.RefundRecipient_CODE,--RefundRecipient_CODE
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB
       FROM RCTH_Y1 A
      WHERE A.Batch_DATE = @Ad_Batch_DATE
        AND A.Batch_NUMB = @An_Batch_NUMB
        AND A.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND A.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND A.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
        AND A.Distribute_DATE = @Ld_Low_DATE
        AND A.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_No_INDC;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
    IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

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
