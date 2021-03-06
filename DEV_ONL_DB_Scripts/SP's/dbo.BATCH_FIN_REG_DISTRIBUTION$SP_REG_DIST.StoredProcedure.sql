/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST
Programmer Name 	: IMP Team
Description			: This Procedure is executed when a RCTH_Y1 is set for distribution process. Distribution also occurs
					  according to the priorities specified in the DBTP_Y1 table. Arrear information are updated in the	 
					  LSUP_Y1 table.
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR_PAID, 
					  BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_VOLUNTARY, 
					  BATCH_FIN_REG_DISTRIBUTION$SP_PASSTHRU_MANUAL_REL_EXCESS
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_REG_DIST]
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4),
 @An_SeqReceipt_NUMB       NUMERIC(6),
 @Ac_SourceReceipt_CODE    CHAR(2),
 @Ad_Receipt_DATE          DATE,
 @An_Receipt_AMNT          NUMERIC(11, 2),
 @Ac_Tanf_CODE             CHAR(1),
 @An_Remaining_AMNT        NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ac_SystemRelease_INDC    CHAR (1) OUTPUT,
 @Ac_ReleasedFrom_CODE     CHAR(4) OUTPUT,
 @Ac_VoluntaryProcess_INDC CHAR (1) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_Space_TEXT                           CHAR (1) = ' ',
           @Lc_StatusFailed_CODE                    CHAR (1) = 'F',
           @Lc_TypeError_CODE                       CHAR (1) = 'E',
           @Lc_No_INDC                              CHAR (1) = 'N',
           @Lc_StatusSuccess_CODE                   CHAR (1) = 'S',
           @Lc_SourceReceiptSpecialCollection_CODE  CHAR (2) = 'SC',
           @Lc_SourceReceiptStateTaxRefund_CODE     CHAR (2) = 'ST',
           @Lc_HoldReasonStatusSnfx_CODE            CHAR (4) = 'SNFX',
           @Lc_HoldReasonStatusSnax_CODE            CHAR (4) = 'SNAX',
           @Lc_HoldReasonStatusShnf_CODE            CHAR (4) = 'SHNF',
           @Ls_Procedure_NAME                       VARCHAR (100) = 'SP_REG_DIST';
  DECLARE  @Ln_Error_NUMB             NUMERIC (11),
           @Ln_ErrorLine_NUMB         NUMERIC (11),
           @Lc_Tanf_CODE              CHAR (1),
           @Ls_Sql_TEXT               VARCHAR (100) = '',
           @Ls_Sqldata_TEXT           VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT      NVARCHAR (4000),
           @Ld_Process_DATE           DATE;
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Process_DATE = @Ad_Run_DATE;

   IF @Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
    BEGIN
     SET @Lc_Tanf_CODE = @Lc_Space_TEXT;
    END
   ELSE
    BEGIN
     SET @Lc_Tanf_CODE = @Ac_Tanf_CODE;
    END

   SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR_PAID';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ad_Receipt_DATE AS VARCHAR ),'')+ ', SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'')+ ', Tanf_CODE = ' + ISNULL(@Lc_Tanf_CODE,'')+ ', Receipt_AMNT = ' + ISNULL(CAST( @An_Receipt_AMNT AS VARCHAR ),'');

   EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR_PAID
    @Ad_Batch_DATE            = @Ad_Batch_DATE,
    @Ac_SourceBatch_CODE      = @Ac_SourceBatch_CODE,
    @An_Batch_NUMB            = @An_Batch_NUMB,
    @An_SeqReceipt_NUMB       = @An_SeqReceipt_NUMB,
    @Ad_Receipt_DATE          = @Ad_Receipt_DATE,
    @Ac_SourceReceipt_CODE    = @Ac_SourceReceipt_CODE,
    @Ac_Tanf_CODE             = @Lc_Tanf_CODE,
    @An_Receipt_AMNT          = @An_Receipt_AMNT,
    @An_Remaining_AMNT        = @An_Remaining_AMNT OUTPUT,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
    @Ad_Process_DATE          = @Ld_Process_DATE OUTPUT;
 
   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   ELSE
    BEGIN
     IF @Ac_Msg_CODE = @Lc_TypeError_CODE
      BEGIN
       RETURN;
      END
    END

   IF @Ac_SourceReceipt_CODE <> @Lc_SourceReceiptSpecialCollection_CODE
      AND @An_Remaining_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_VOLUNTARY STX';
     SET @Ls_Sqldata_TEXT = 'Receipt_AMNT = ' + CAST (@An_Receipt_AMNT AS VARCHAR);

     EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_PROCESS_VOLUNTARY
      @An_Remaining_AMNT        = @An_Remaining_AMNT OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT,
      @Ac_VoluntaryProcess_INDC = @Ac_VoluntaryProcess_INDC OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   -- New Procedure Added
   IF @An_Remaining_AMNT > 0
      AND @Ac_SystemRelease_INDC = @Lc_No_INDC
      AND @Ac_ReleasedFrom_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
      AND
      -- When the Manaul Released Excess hold receipts remaining Value_AMNT is more than the Arrear Balance and the Arrear Balance is
      -- greater than Zero then the Remaining excess money over the Arrears should be placed on Futures Hold
      @An_Receipt_AMNT = @An_Remaining_AMNT
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SP_PASSTHRU_MANUAL_REL_EXCESS';
	 SET @Ls_Sqldata_TEXT = '@An_Remaining_AMNT = ' + CAST (@An_Remaining_AMNT AS VARCHAR);
     EXECUTE BATCH_FIN_REG_DISTRIBUTION$SP_PASSTHRU_MANUAL_REL_EXCESS
      @An_Remaining_AMNT        = @An_Remaining_AMNT OUTPUT,
      @Ac_Msg_CODE              = @Ls_ErrorMessage_TEXT OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
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
