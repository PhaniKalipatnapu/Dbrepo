/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_DELETE_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_DELETE_RECEIPT

Programmer Name		: IMP Team

Description			: This procedure is used delete the receipt

Frequency			: 

Developed On		: 04/12/2011

Called By			: None

Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_DELETE_RECEIPT](
 @Ad_Batch_DATE              DATE,
 @Ac_SourceBatch_CODE        CHAR(3),
 @An_Batch_NUMB              NUMERIC(4),
 @An_SeqReceipt_NUMB         NUMERIC(6),
 @Ac_StatusReceipt_CODE      CHAR(1),
 @An_EventGlobalRcthSeq_NUMB NUMERIC(19),
 @An_EventGlobalUrctSeq_NUMB NUMERIC(19),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE             CHAR = 'S',
          @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_COMMON$SP_DELETE_RECEIPT',
          @Ld_High_DATE                      DATE = '12/31/9999';
          
  DECLARE @Ln_RowCount_QNTY            NUMERIC(7),
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_Sqldata_TEXT             VARCHAR(200),
          @Ls_ErrorMessage_TEXT        VARCHAR(2000),
          @Ld_System_DATE              DATETIME2;

  BEGIN TRY
   SET @Ld_System_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ln_EventGlobalBeginSeq_NUMB = (SELECT a.EventGlobalBeginSeq_NUMB
                                         FROM RCTH_Y1 a
                                        WHERE a.Batch_DATE = @Ad_Batch_DATE
                                          AND a.Batch_NUMB = @An_Batch_NUMB
                                          AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                                          AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
                                          AND a.EndValidity_DATE = @Ld_High_DATE);

   IF @An_EventGlobalRcthSeq_NUMB <> @Ln_EventGlobalBeginSeq_NUMB
    BEGIN
     RAISERROR(50001,16,1);
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 FAILED';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalRcthSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ld_System_DATE,
            EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ad_Batch_DATE
        AND Batch_NUMB = @An_Batch_NUMB
        AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND EventGlobalBeginSeq_NUMB = @An_EventGlobalRcthSeq_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   -- If receipt is Un identified
   IF @Ac_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
    BEGIN
     SET @Ln_EventGlobalBeginSeq_NUMB = (SELECT a.EventGlobalBeginSeq_NUMB
                                           FROM URCT_Y1 a
                                          WHERE a.Batch_DATE = @Ad_Batch_DATE
                                            AND a.Batch_NUMB = @An_Batch_NUMB
                                            AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                                            AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
                                            AND a.IdentificationStatus_CODE = 'U'
                                            AND a.EndValidity_DATE = @Ld_High_DATE);

     IF @An_EventGlobalUrctSeq_NUMB <> @Ln_EventGlobalBeginSeq_NUMB
      BEGIN
       RAISERROR(50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE_URCT_V1 FAILED 2';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       UPDATE URCT_Y1
          SET EndValidity_DATE = @Ld_System_DATE,
              EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
        WHERE Batch_DATE = @Ad_Batch_DATE
          AND Batch_NUMB = @An_Batch_NUMB
          AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
          AND SourceBatch_CODE = @Ac_SourceBatch_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         RAISERROR(50001,16,1);
        END
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE_URCT_V1 FAILED 3';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', IdentificationStatus_CODE = ' + ISNULL(@Ac_StatusReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE URCT_Y1
        SET EndValidity_DATE = @Ld_System_DATE,
            EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ad_Batch_DATE
        AND Batch_NUMB = @An_Batch_NUMB
        AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND IdentificationStatus_CODE = @Ac_StatusReceipt_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;
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
