/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* --------------------------------------------------------------------------------------------------- 
Procedure Name    : BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP
Programmer Name   : IMP Team 
Description       : This Procedure is used to update the Case details
Frequency         : 
Developed On      : 01/05/2012
Called By         : None
Called On         :
-------------------------------------------------------------------------------------------------------
Modified By       :
Modified On       : 
Version No        :  1.0
-------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP] (
 @An_Case_IDNO                NUMERIC(6),
 @Ac_TypeOthpSource_CODE      CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_CaseTypePaTanf_CODE   CHAR(1) = 'A',
          @Lc_NonCoopFailed_CODE    CHAR(1) = 'P',
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_TypeOthpSourceCp_CODE CHAR(1) = 'C',
          @Ls_Routine_TEXT          VARCHAR(100) = 'BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP';
  DECLARE @Ln_Error_NUMB      NUMERIC (11),
          @Ln_ErrorLine_NUMB  NUMERIC (11),
          @Lc_GoodCause_CODE  CHAR(1),
          @Lc_StatusCase_CODE CHAR(1),
          @Lc_TypeCase_CODE   CHAR(1),
          @Ld_GoodCause_DATE  DATE;
  DECLARE @Ls_Sql_TEXT              VARCHAR(300),
          @Ls_Sqldata_TEXT          VARCHAR(3000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP SELECT CASE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));

   SELECT @Lc_TypeCase_CODE = A.TypeCase_CODE
     FROM CASE_Y1 A
    WHERE A.Case_IDNO = @An_Case_IDNO;

   IF (@Ac_TypeOthpSource_CODE = @Lc_TypeOthpSourceCp_CODE
       AND @Lc_CaseTypePaTanf_CODE = @Lc_TypeCase_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP SELECT CASE_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));

     SELECT @Lc_StatusCase_CODE = A.StatusCase_CODE,
            @Lc_GoodCause_CODE = A.GoodCause_CODE,
            @Ld_GoodCause_DATE = A.GoodCause_DATE
       FROM CASE_Y1 A
      WHERE Case_IDNO = @An_Case_IDNO;

     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_GOODCAUSE_VAPP BACTH_COMMON$SP_UPDATE_CASE_DETAILS';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', WorkerUpdate_ID = ' + CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30));

     EXEC BATCH_COMMON$SP_UPDATE_CASE_DETAILS
      @An_Case_IDNO                = @An_Case_IDNO,
      @Ac_StatusCase_CODE          = @Lc_StatusCase_CODE,
      @Ac_GoodCause_CODE           = @Lc_GoodCause_CODE,
      @Ac_NonCoop_CODE             = @Lc_NonCoopFailed_CODE,
      @Ad_NonCoop_DATE             = @Ad_Run_DATE,
      @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

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
