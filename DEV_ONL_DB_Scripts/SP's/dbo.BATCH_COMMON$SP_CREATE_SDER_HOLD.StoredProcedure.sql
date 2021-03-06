/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CREATE_SDER_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CREATE_SDER_HOLD
Programmer Name		: IMP Team
Description			: This procedure will create SDER hold in DHLD_Y1 table
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CREATE_SDER_HOLD]
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @An_Unique_IDNO           NUMERIC(19),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT             CHAR (1) = ' ',
		  @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_StatusReceiptHeld_CODE CHAR(1) = 'H',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_DhldTypeHoldD_IDNO     CHAR(1) = 'D',
          @Lc_DhldTypeHoldC_IDNO     CHAR(1) = 'C',
          @Lc_ReasonStatusSr_CODE    CHAR(2) = 'SR',
          @Lc_ReasonStatusSder_CODE  CHAR(4) = 'SDER',
          @Lc_Worker_ID				 CHAR(5) = 'DECSS',
          @Lc_JobFreqDaily_ID        CHAR(7) = 'DAILY',
          @Lc_Process_ID			 CHAR(10) = 'EMERGENCY',
          @Ls_Procedure_NAME         VARCHAR(60) = 'BATCH_COMMON$SP_CREATE_SDER_HOLD',
          @Ld_Low_DATE               DATE = '01/01/0001',
          @Ld_High_DATE              DATE = '12/31/9999';
          
  DECLARE @Ln_Error_NUMB              NUMERIC,
          @Ln_RowCount_QNTY           NUMERIC,
          @Ln_CommitFreq_QNTY         NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY NUMERIC(5),
          @Ln_Value_QNTY              NUMERIC(5) = 0,
          @Ln_ErrorLine_NUMB          NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB     NUMERIC(19),
          @Lc_TypeHold_CODE           CHAR(1),
          @Lc_Msg_CODE                CHAR(1),
          @Lc_ReasonStatus_CODE       CHAR(4),
          @Ls_Sql_TEXT                VARCHAR(100) = '',
          @Ls_Sqldata_TEXT            VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT   VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                DATE,
          @Ld_LastRun_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobFreqDaily_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'SELECT DHLD_Y1 ';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Unique_IDNO = ' + ISNULL (CAST (@An_Unique_IDNO AS NVARCHAR (9)), '');

   SELECT @Ln_Value_QNTY = COUNT (1)
     FROM DHLD_Y1 v
		WHERE v.CheckRecipient_ID = @Ac_CheckRecipient_ID
		  AND v.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
		  AND v.Unique_IDNO = @An_Unique_IDNO
		  AND v.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Value_QNTY = 1
    BEGIN
	   SET @Ls_Sql_TEXT = 'SELECT DHLD_Y1 FOR TypeHold_CODE, ReasonStatus_CODE ';
	   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Unique_IDNO = ' + ISNULL (CAST (@An_Unique_IDNO AS NVARCHAR (9)), '');

	   SELECT @Lc_TypeHold_CODE = v.TypeHold_CODE,
			  @Lc_ReasonStatus_CODE = v.ReasonStatus_CODE
		 FROM DHLD_Y1 v
		WHERE v.CheckRecipient_ID = @Ac_CheckRecipient_ID
		  AND v.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
		  AND v.Unique_IDNO = @An_Unique_IDNO
		  AND v.EndValidity_DATE = @Ld_High_DATE;

	   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
	   SET @Ls_Sqldata_TEXT = 'Process_ID = ' + ISNULL (@Lc_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS NVARCHAR (10)), '');

	   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
		@An_EventFunctionalSeq_NUMB = 0,
		@Ac_Process_ID              = @Lc_Process_ID,
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

	   SET @Ls_Sql_TEXT = 'INSERT DHLD_Y1';
	   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL (@Lc_ReasonStatusSder_CODE, '') + ', Status_CODE = ' + ISNULL (@Lc_StatusReceiptHeld_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS NVARCHAR (9)), '');

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
			  @Lc_StatusReceiptHeld_CODE AS Status_CODE,
			  d.TypeHold_CODE,--TypeHold_CODE
			  @Lc_ReasonStatusSder_CODE AS ReasonStatus_CODE,
			  d.ProcessOffset_INDC,--ProcessOffset_INDC
			  @Ld_Run_DATE AS Transaction_DATE,
			  @Ld_High_DATE AS Release_DATE,
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
		  AND d.EndValidity_DATE = @Ld_High_DATE;

	   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Unique_IDNO = ' + ISNULL (CAST (@An_Unique_IDNO AS NVARCHAR (9)), '');

	   IF (@Lc_TypeHold_CODE = @Lc_DhldTypeHoldD_IDNO
			OR (@Lc_TypeHold_CODE = @Lc_DhldTypeHoldC_IDNO
				AND @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSr_CODE))
		BEGIN
		 SET @Ls_Sql_TEXT = 'DELETE FROM DHLD_Y1';

		 DELETE DHLD_Y1
		   FROM DHLD_Y1 d
		  WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
			AND d.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
			AND d.Unique_IDNO = @An_Unique_IDNO
			AND d.EndValidity_DATE = @Ld_High_DATE;

		 SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ls_ErrorMessage_TEXT = 'DHLD_Y1 DELETE FAILED';

		   RAISERROR (50001,16,1);
		  END
		END
	   ELSE
		BEGIN
		 SET @Ls_Sql_TEXT = 'UPDATE DHLD_Y1_1';

		 UPDATE DHLD_Y1
			SET EndValidity_DATE = @Ld_Run_DATE,
				EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
		   FROM DHLD_Y1 a
		  WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
			AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
			AND a.Unique_IDNO = @An_Unique_IDNO
			AND a.EndValidity_DATE = @Ld_High_DATE;

		 SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		 IF @Ln_RowCount_QNTY = 0
		  BEGIN
		   SET @Ls_ErrorMessage_TEXT = 'UPDATE DHLD_Y1_1 FAILED';

		   RAISERROR (50001,16,1);
		  END
		END

	   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END
  ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_No_INDC;
     SET @As_DescriptionError_TEXT = 'No Record Found in DHLD_Y1 table.'
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
