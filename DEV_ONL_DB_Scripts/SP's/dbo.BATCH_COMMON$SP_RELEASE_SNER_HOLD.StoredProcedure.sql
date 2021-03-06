/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_RELEASE_SNER_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_RELEASE_SNER_HOLD
Programmer Name		: IMP Team
Description			: This procedure is used release 'SNER' - RCTH hold record using input 
					  receipt number (Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB)
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_RELEASE_SNER_HOLD]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ac_Process_ID            CHAR(10),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ReleaseAHeldReceipt1430_NUMB INT = 1430,
          @Lc_StatusSuccess_CODE           CHAR = 'S',
          @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
          @Lc_No_INDC                      CHAR(1) = 'N',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_StatusReceiptIdentified_CODE CHAR(1) = 'I',
          @Lc_ReasonStatusSner_CODE        CHAR(4) = 'SNER',
          @Lc_Worker_ID					   CHAR(5) = 'DECSS',
          @Lc_JobDaily_ID				   CHAR(5) = 'DAILY',          
          @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_COMMON$SP_RELEASE_SNER_HOLD',
          @Ld_Low_DATE                     DATE = '01/01/0001',
          @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Error_NUMB            NUMERIC,
          @Ln_Value_QNTY            NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB   NUMERIC(19),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '',
          @Ld_Run_DATE              DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'JobDaily_ID = ' + ISNULL (CAST(@Lc_JobDaily_ID AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL (CAST(@Ld_High_DATE AS VARCHAR), '');
	
	SELECT @Ld_Run_DATE = Run_DATE
	FROM PARM_Y1 a
	WHERE a.Job_ID = @Lc_JobDaily_ID
	  AND a.EndValidity_DATE = @Ld_High_DATE;
	
     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'DAILY JOB RUN DATE SELECT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END	
   
   SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSner_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_Value_QNTY = COUNT (1)
     FROM RCTH_Y1 r
    WHERE r.Batch_DATE = @Ad_Batch_DATE
      AND r.Batch_NUMB = @An_Batch_NUMB
      AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND r.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
      AND r.ReasonStatus_CODE = @Lc_ReasonStatusSner_CODE
      AND r.Distribute_DATE = @Ld_Low_DATE
      AND r.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Value_QNTY = 1
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReleaseAHeldReceipt1430_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_Worker_ID,'');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReleaseAHeldReceipt1430_NUMB,
      @Ac_Process_ID              = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
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
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSner_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ld_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ad_Batch_DATE
        AND Batch_NUMB = @An_Batch_NUMB
        AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
        AND ReasonStatus_CODE = @Lc_ReasonStatusSner_CODE
        AND Distribute_DATE = @Ld_Low_DATE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 - SNER RELEASE';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + CAST(@Ad_Batch_DATE AS VARCHAR) + ', Batch_NUMB = ' + CAST(@An_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@An_SeqReceipt_NUMB AS VARCHAR) + ', SourceBatch_CODE = ' + @Ac_SourceBatch_CODE + ', StatusReceipt_CODE = ' + @Lc_StatusReceiptHeld_CODE + ', ReasonStatus_CODE = ' + @Lc_ReasonStatusSner_CODE + ', Distribute_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR) + ', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR);

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
     SELECT r.Batch_DATE,--Batch_DATE
            r.SourceBatch_CODE,--SourceBatch_CODE
            r.Batch_NUMB,--Batch_NUMB
            r.SeqReceipt_NUMB,--SeqReceipt_NUMB
            r.SourceReceipt_CODE,--SourceReceipt_CODE
            r.TypeRemittance_CODE,--TypeRemittance_CODE
            r.TypePosting_CODE,--TypePosting_CODE
            r.Case_IDNO,--Case_IDNO
            r.PayorMCI_IDNO,--PayorMCI_IDNO
            r.Receipt_AMNT,--Receipt_AMNT
            r.ToDistribute_AMNT,--ToDistribute_AMNT
            r.Fee_AMNT,--Fee_AMNT
            r.Employer_IDNO,--Employer_IDNO
            r.Fips_CODE,--Fips_CODE
            r.Check_DATE,--Check_DATE
            r.CheckNo_Text,--CheckNo_Text
            r.Receipt_DATE,--Receipt_DATE
            r.Distribute_DATE,--Distribute_DATE
            r.Tanf_CODE,--Tanf_CODE
            r.TaxJoint_CODE,--TaxJoint_CODE
            r.TaxJoint_NAME,--TaxJoint_NAME
            @Lc_StatusReceiptIdentified_CODE AS StatusReceipt_CODE,
            @Lc_ReasonStatusSner_CODE AS ReasonStatus_CODE,
            r.BackOut_INDC,--BackOut_INDC
            r.ReasonBackOut_CODE,--ReasonBackOut_CODE
            r.Refund_DATE,--Refund_DATE
            @Ld_Run_DATE AS Release_DATE,
            r.ReferenceIrs_IDNO,--ReferenceIrs_IDNO
            r.RefundRecipient_ID,--RefundRecipient_ID
            r.RefundRecipient_CODE,--RefundRecipient_CODE
            @Ld_Run_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB
       FROM RCTH_Y1 r
      WHERE r.Batch_DATE = @Ad_Batch_DATE
        AND r.Batch_NUMB = @An_Batch_NUMB
        AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND r.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
        AND r.ReasonStatus_CODE = @Lc_ReasonStatusSner_CODE
        AND r.Distribute_DATE = @Ld_Low_DATE
        AND r.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_No_INDC;
     
	 IF @Ln_Value_QNTY = 0
	 BEGIN		     
	  SET @As_DescriptionError_TEXT = 'No Record Found in RCTH_Y1 table. Input Values: ' + @Ls_Sqldata_TEXT
	 END
	 
	 IF @Ln_Value_QNTY > 0
	 BEGIN		     
	  SET @As_DescriptionError_TEXT = 'More than one Records Found in RCTH_Y1 table. Records Count = ' + CAST(@Ln_Value_QNTY AS VARCHAR) + '. Input Values: ' + @Ls_Sqldata_TEXT
	 END     
	 
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
