/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$XSL_LOADER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$XSL_LOADER
Programmer Name		: IMP Team
Description			: To load xsl data into the NVER table.
Frequency			:
Developed On		: 04/12/2011
Called By			: 
Called On			: BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$XSL_LOADER] (
 @Ac_Notice_ID             CHAR(8),
 @An_NoticeVersion_NUMB    NUMERIC(5),
 @As_XslTemplate_TEXT      VARCHAR(MAX),
 @An_Total_QNTY            NUMERIC(10) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_Note_INDC          CHAR(1) = 'N',
          @Lc_WorkerUpdate_ID    CHAR(10) = 'BATCH',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_COMMON$XSL_LOADER',
          @Ld_High_DATE          DATE = '12/31/9999',
          @Ld_Current_DTTM       DATETIME2(0) = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Lc_Space_TEXT               CHAR = '',
          @Lc_Msg_CODE                 CHAR(1),
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_Sql_TEXT                 VARCHAR(1000),
          @Ls_Sqldata_TEXT             VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', Process_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Current_DTTM AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '');

   EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_WorkerUpdate_ID,
    @Ac_Process_ID               = @Lc_Space_TEXT,
    @Ad_EffectiveEvent_DATE      = @Ld_Current_DTTM,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'UPDATE NVER	1';
   SET @Ls_Sqldata_TEXT = 'NoticeVersion_NUMB = ' + ISNULL(CAST(@An_NoticeVersion_NUMB AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE NVER_Y1
      SET XslTemplate_TEXT = @As_XslTemplate_TEXT,
          WorkerUpdate_ID = @Lc_WorkerUpdate_ID,
          TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
          Update_DTTM = @Ld_Current_DTTM
    WHERE Notice_ID = UPPER(@Ac_Notice_ID)
      AND NoticeVersion_NUMB = @An_NoticeVersion_NUMB
      AND End_DATE = @Ld_High_DATE;

   SET @An_Total_QNTY = @@ROWCOUNT;

   IF (@An_Total_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE NVER	2';
     SET @Ls_Sqldata_TEXT = 'End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     UPDATE NVER_Y1
        SET End_DATE = @Ld_Current_DTTM
      WHERE Notice_ID = UPPER(@Ac_Notice_ID)
        AND NoticeVersion_NUMB < @An_NoticeVersion_NUMB
        AND End_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = 'INSERT NVER';
     SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL(@Ac_Notice_ID, '') + ', NoticeVersion_NUMB = ' + ISNULL(CAST(@An_NoticeVersion_NUMB AS VARCHAR), '') + ', XslTemplate_TEXT = ' + ISNULL(@As_XslTemplate_TEXT, '') + ', Effective_DATE = ' + ISNULL(CAST(@Ld_Current_DTTM AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Current_DTTM AS VARCHAR), '');

     INSERT INTO NVER_Y1
                 (Notice_ID,
                  NoticeVersion_NUMB,
                  XslTemplate_TEXT,
                  Effective_DATE,
                  End_DATE,
                  WorkerUpdate_ID,
                  TransactionEventSeq_NUMB,
                  Update_DTTM)
          VALUES ( @Ac_Notice_ID,--Notice_ID
                   @An_NoticeVersion_NUMB,--NoticeVersion_NUMB
                   @As_XslTemplate_TEXT,--XslTemplate_TEXT
                   @Ld_Current_DTTM,--Effective_DATE
                   @Ld_High_DATE,--End_DATE
                   @Lc_WorkerUpdate_ID,--WorkerUpdate_ID
                   @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                   @Ld_Current_DTTM --Update_DTTM
     );

     SET @An_Total_QNTY = @@ROWCOUNT;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = ' ';
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
 END;


GO
