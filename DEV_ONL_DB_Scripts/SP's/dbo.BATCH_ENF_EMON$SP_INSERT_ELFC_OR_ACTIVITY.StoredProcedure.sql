/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
Programmer Name :	IMP Team
Description		:	This process either makes an entry in ELFC_Y1 table or sends an informational alert.
Frequency		: 
Developed On	:  01/05/2012
Called By		:  BATCH_ENF_EMON$SP_PROCESS_EMON_WEEKLY
Called On       :  BATCH_COMMON$SP_INSERT_ACTIVITY
--------------------------------------------------------------------------------------------------------------------
Modified By		:
Modified On		:
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY]
 @An_Case_IDNO                NUMERIC(6),
 @An_MemberMci_IDNO           NUMERIC (10),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Subsystem_CODE           CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @An_Topic_IDNO               NUMERIC(10)  OUTPUT,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Success_CODE CHAR(1) = 'S',
          @Lc_Fail_CODE    CHAR(1) = 'F',
          @Lc_Space_TEXT   CHAR(1) = ' ',
          @Ls_Routine_TEXT VARCHAR(75) = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(50),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   BEGIN
    SET @Ls_Sql_TEXT = 'EMON158 : BATCH_COMMON.SP_INSERT_ACTIVITY';
    SET @Ls_Sqldata_TEXT = ' Caseo_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Membermcio_IDNO  = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '') + ', ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Ac_ActivityMinor_CODE + ', Subsystem_CODE = ' + @Ac_Subsystem_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(11)), '') + ', Topic_IDNO = ' + ISNULL(CAST(@An_Topic_IDNO AS VARCHAR(10)), '') + ', WorkerUpdate_ID = ' + @Ac_WorkerUpdate_ID;

    EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
     @An_Case_IDNO                = @An_Case_IDNO,
     @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
     @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
     @Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
     @Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
     @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
     @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
     @An_Topic_IDNO               = @An_Topic_IDNO OUTPUT,
     @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
     @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

    IF @Ac_Msg_CODE != @Lc_Space_TEXT
     BEGIN
      IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) = ''
       BEGIN
        SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + 'EMON158A : BATCH_COMMON.SP_INSERT_ACTIVITY FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
       END
      ELSE
       BEGIN
        SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + 'EMON158B : BATCH_COMMON.SP_INSERT_ACTIVITY FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT + @Lc_Space_TEXT + @As_DescriptionError_TEXT;
       END

      RETURN;
     END
   END

   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_Fail_CODE;

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END


GO
