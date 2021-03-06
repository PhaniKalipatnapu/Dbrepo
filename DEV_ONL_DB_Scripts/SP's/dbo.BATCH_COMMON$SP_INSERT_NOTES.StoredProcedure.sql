/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_NOTES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_NOTES

Programmer Name		: IMP Team

Description			: Procedure used to insert records in UNOT_Y1 table

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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_NOTES] (
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @As_DescriptionNote_TEXT  VARCHAR(4000),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Routine_TEXT       VARCHAR(60) = 'BATCH_COMMON$SP_INSERT_NOTES';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'INSERT UNOT_Y1 ';
   SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalApprovalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', DescriptionNote_TEXT = ' + @As_DescriptionNote_TEXT;

   INSERT UNOT_Y1
          (EventGlobalSeq_NUMB,
           EventGlobalApprovalSeq_NUMB,
           DescriptionNote_TEXT)
   VALUES( @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
           @An_EventGlobalSeq_NUMB,--EventGlobalApprovalSeq_NUMB
           @As_DescriptionNote_TEXT); --DescriptionNote_TEXT
           
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
