/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_RELEASE_SDER_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_RELEASE_SDER_HOLD
Programmer Name		: IMP Team
Description			: This procedure is used release 'SDER - SYSTEM ABEND HOLD - BATCH ERROR' - Disbursement hold record using
					  input values (CheckRecipient_ID, CheckRecipient_CODE, Unique_IDNO)
Frequency			: 
Developed On		: 04/09/2014
Called By			:
Called On			:
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
-------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_RELEASE_SDER_HOLD]
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @An_Unique_IDNO           NUMERIC(19),
 @Ac_Process_ID            CHAR(10),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT 
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ReleaseAHeldReceipt1430_NUMB INT = 1430,
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_No_INDC                      CHAR(1) = 'N',  
          @Lc_StatusReceiptHeld_CODE	   CHAR(1) = 'H',        
          @Lc_StatusR_CODE				   CHAR(1) = 'R',
          @Lc_TypeHoldP_CODE			   CHAR(1) = 'P',
          @Lc_Space_TEXT				   CHAR(1) = ' ',
          @Lc_ReasonStatusSDER_CODE        CHAR(4) = 'SDER',
          @Lc_Worker_ID					   CHAR(5) = 'DECSS',
          @Lc_JobDaily_ID				   CHAR(5) = 'DAILY',
          @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_COMMON$SP_RELEASE_SDER_HOLD',
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

   SET @Ls_Sql_TEXT = 'SELECT DHLD_Y1';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Unique_IDNO = ' + ISNULL (CAST (@An_Unique_IDNO AS VARCHAR (19)), '') + ', Status_CODE = ' + ISNULL (@Lc_StatusReceiptHeld_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_ReasonStatusSDER_CODE, '');

   SELECT @Ln_Value_QNTY = COUNT (1)
     FROM DHLD_Y1 a
	WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
	  AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
	  AND a.Unique_IDNO = @An_Unique_IDNO
	  AND a.Status_CODE = @Lc_StatusReceiptHeld_CODE
	  AND a.ReasonStatus_CODE = @Lc_ReasonStatusSDER_CODE		  
	  AND a.EndValidity_DATE = @Ld_High_DATE;

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
   
   SET @Ls_Sql_TEXT = 'UPDATE DHLD_Y1 ';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Unique_IDNO = ' + ISNULL (CAST (@An_Unique_IDNO AS VARCHAR (19)), '') + ', Status_CODE = ' + ISNULL (@Lc_StatusReceiptHeld_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_ReasonStatusSDER_CODE, '');

	 UPDATE DHLD_Y1
		SET EndValidity_DATE = @Ld_Run_DATE,
			EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
	  WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
	  AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
	  AND Unique_IDNO = @An_Unique_IDNO
	  AND Status_CODE = @Lc_StatusReceiptHeld_CODE
	  AND ReasonStatus_CODE = @Lc_ReasonStatusSDER_CODE		  
	  AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
   
     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT DHLD_Y1 - SDER RELEASE';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Unique_IDNO = ' + ISNULL (CAST (@An_Unique_IDNO AS VARCHAR (19)), '') + ', Status_CODE = ' + ISNULL (@Lc_StatusReceiptHeld_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_ReasonStatusSDER_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR (19)), '');
     
      INSERT DHLD_Y1
			  (CheckRecipient_ID,
			   CheckRecipient_CODE,
			   Case_IDNO,
			   OrderSeq_NUMB,
			   ObligationSeq_NUMB,
			   Batch_DATE,
			   SourceBatch_CODE,
			   Batch_NUMB,
			   SeqReceipt_NUMB,
			   EventGlobalSupportSeq_NUMB,
			   TypeDisburse_CODE,
			   Transaction_AMNT,
			   Status_CODE,
			   TypeHold_CODE,
			   ReasonStatus_CODE,
			   ProcessOffset_INDC,
			   Transaction_DATE,
			   Release_DATE,
			   BeginValidity_DATE,
			   EndValidity_DATE,
			   EventGlobalBeginSeq_NUMB,
			   EventGlobalEndSeq_NUMB,
			   Disburse_DATE,
			   DisburseSeq_NUMB,
			   StatusEscheat_DATE,
			   StatusEscheat_CODE)
	   SELECT d.CheckRecipient_ID,--CheckRecipient_ID
			  d.CheckRecipient_CODE,--CheckRecipient_CODE
			  d.Case_IDNO,--Case_IDNO
			  d.OrderSeq_NUMB,--OrderSeq_NUMB
			  d.ObligationSeq_NUMB,--ObligationSeq_NUMB
			  d.Batch_DATE,--Batch_DATE
			  d.SourceBatch_CODE,--SourceBatch_CODE
			  d.Batch_NUMB,--Batch_NUMB
			  d.SeqReceipt_NUMB,--SeqReceipt_NUMB
			  d.EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
			  d.TypeDisburse_CODE,--TypeDisburse_CODE
			  d.Transaction_AMNT,--Transaction_AMNT
			  @Lc_StatusR_CODE AS Status_CODE,
			  @Lc_TypeHoldP_CODE AS TypeHold_CODE,
			  @Lc_ReasonStatusSder_CODE AS ReasonStatus_CODE,
			  d.ProcessOffset_INDC,--ProcessOffset_INDC
			  @Ld_Run_DATE AS Transaction_DATE,
			  @Ld_Run_DATE AS Release_DATE,
			  @Ld_Run_DATE AS BeginValidity_DATE,
			  @Ld_High_DATE AS EndValidity_DATE,
			  @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
			  0 AS EventGlobalEndSeq_NUMB,
			  d.Disburse_DATE,--Disburse_DATE
			  d.DisburseSeq_NUMB, --DisburseSeq_NUMB
			  @Ld_Low_DATE AS StatusEscheat_DATE,
			  @Lc_Space_TEXT AS StatusEscheat_CODE
		 FROM DHLD_Y1 d
		WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
		  AND d.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
		  AND d.Unique_IDNO = @An_Unique_IDNO
		  AND d.Status_CODE = @Lc_StatusReceiptHeld_CODE
		  AND d.ReasonStatus_CODE = @Lc_ReasonStatusSDER_CODE				  
		  AND d.EndValidity_DATE = @Ld_Run_DATE
		  AND d.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

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
	  SET @As_DescriptionError_TEXT = 'No Record Found in DHLD_Y1 table. Input Values: ' + @Ls_Sqldata_TEXT
	 END
	 
	 IF @Ln_Value_QNTY > 0
	 BEGIN		     
	  SET @As_DescriptionError_TEXT = 'More than one Records Found in DHLD_Y1 table. Records Count = ' + CAST(@Ln_Value_QNTY AS VARCHAR) + '. Input Values: ' + @Ls_Sqldata_TEXT
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
