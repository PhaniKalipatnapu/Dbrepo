/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_SDER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_INSERT_SDER
Programmer Name 	: IMP Team
Description			: Procedure to create Dhold with SDER reason
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_INSERT_SDER] (
 @An_Remaining_AMNT             NUMERIC(11, 2) OUTPUT,
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @An_Case_IDNO                  NUMERIC(6),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @Ad_Batch_DATE                 DATE,
 @An_Batch_NUMB                 NUMERIC(4),
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @Ad_Disburse_DATE              DATE,
 @An_DisburseSeq_NUMB           NUMERIC(4),
 @An_EventGlobalSeq_NUMB        NUMERIC (19),
 @Ad_Run_DATE                   DATE,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
		  @Lc_StatusFailed_CODE  CHAR(1) = 'F',
		  @Lc_StatusH_CODE		 CHAR (1) = 'H',
		  @Lc_TypeHoldD_CODE	 CHAR (1) = 'D',
          @Lc_No_TEXT            CHAR (1) = 'N',
	      @Lc_Space_TEXT         CHAR(1) = ' ',          
		  @Lc_ReasonStatusSder_CODE  CHAR (4) = 'SDER',
          @Ls_Procedure_NAME     VARCHAR (100) = 'SP_INSERT_SDER',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC (11),
          @Ln_ErrorLine_NUMB        NUMERIC (11),
          @Ln_RowCount_QNTY         NUMERIC (19),
          @Ls_Sql_TEXT              VARCHAR (100) = '',
          @Ls_SqlData_TEXT          VARCHAR (1000),
          @Ls_ErrorMessage_TEXT     VARCHAR (4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1_IRS_HOLD';
   SET @Ls_SqlData_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE,'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @An_Remaining_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusH_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_TypeHoldD_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSder_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_TEXT,'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ad_Disburse_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL(CAST( @An_DisburseSeq_NUMB AS VARCHAR ),'')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');

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
   VALUES ( @Ac_CheckRecipient_ID,--CheckRecipient_ID
            @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
            @An_Case_IDNO,--Case_IDNO
            @An_OrderSeq_NUMB,--OrderSeq_NUMB
            @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
            @Ad_Batch_DATE,--Batch_DATE
            @Ac_SourceBatch_CODE,--SourceBatch_CODE
            @An_Batch_NUMB,--Batch_NUMB
            @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
            @An_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
            @Ac_TypeDisburse_CODE,--TypeDisburse_CODE
            @An_Remaining_AMNT,--Transaction_AMNT
            @Lc_StatusH_CODE,--Status_CODE
            @Lc_TypeHoldD_CODE,--TypeHold_CODE
            @Lc_ReasonStatusSder_CODE,--ReasonStatus_CODE
            @Lc_No_TEXT,--ProcessOffset_INDC
            @Ad_Run_DATE,--Transaction_DATE
            @Ld_High_DATE,--Release_DATE
            @Ad_Run_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
            0,--EventGlobalEndSeq_NUMB
            @Ad_Disburse_DATE,--Disburse_DATE
            @An_DisburseSeq_NUMB, --DisburseSeq_NUMB
            @Ld_High_DATE,--StatusEscheat_DATE
            @Lc_Space_TEXT --StatusEscheat_CODE
   );

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1_IRS_HOLD FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
