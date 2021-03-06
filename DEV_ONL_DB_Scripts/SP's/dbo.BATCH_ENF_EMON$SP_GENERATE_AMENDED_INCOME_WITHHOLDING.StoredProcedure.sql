/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_GENERATE_AMENDED_INCOME_WITHHOLDING]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* --------------------------------------------------------------------------------------------------- 
Procedure Name    : BATCH_ENF_EMON$SP_GENERATE_AMENDED_INCOME_WITHHOLDING
Programmer Name   : IMP Team 
Description       : This procedure is used for generate amended income withholding
Frequency         : 
Developed On      : 01/05/2012
Called By         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On         : BATCH_ENF_EMON$SP_INSERT_IWEM
--------------------------------------------------------------------------------------------------- 
Modified By       : 
Modified On       : 
Version No        :  1.0
-------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_GENERATE_AMENDED_INCOME_WITHHOLDING] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC (10),
 @An_OthpSource_IDNO          NUMERIC(9),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_StatusFail_CODE       CHAR(1) = 'F',
          @Lc_IwnStatusActive_CODE  CHAR(1) = 'A',
          @Lc_IwnStatusPending_CODE CHAR(1) = 'P',
          @Ls_Routine_TEXT          VARCHAR(75) = 'BATCH_ENF_EMON$SP_GENERATE_AMENDED_INCOME_WITHHOLDING',
          @Ld_High_DATE             DATE = '12/31/9999';
  DECLARE @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(300),
          @Ls_Sqldata_TEXT          VARCHAR(3000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = ' BATCH_ENF_EMON$SP_GENERATE_AMENDED_INCOME_WITHHOLDING UPDATE IWEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(@An_OthpSource_IDNO AS VARCHAR(10));

   UPDATE IWEM_Y1
      SET End_DATE = @Ad_Run_DATE
    WHERE Case_IDNO = @An_Case_IDNO
      AND MemberMci_IDNO = @An_MemberMci_IDNO
      AND OthpEmployer_IDNO = @An_OthpSource_IDNO
      AND IwnStatus_CODE IN (@Lc_IwnStatusActive_CODE, @Lc_IwnStatusPending_CODE)
      AND End_DATE = @Ld_High_DATE
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_ELFC$SP_INSERT_IWEM';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(5)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(@An_OthpSource_IDNO AS VARCHAR(10)) + ', WorkerUpdate_ID  = ' + CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(30));

   EXEC BATCH_ENF_EMON$SP_INSERT_IWEM
    @An_Case_IDNO                = @An_Case_IDNO,
    @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
    @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
    @An_OthpSource_IDNO          = @An_OthpSource_IDNO,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
    @Ad_Run_DATE                 = @Ad_Run_DATE,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFail_CODE;

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
