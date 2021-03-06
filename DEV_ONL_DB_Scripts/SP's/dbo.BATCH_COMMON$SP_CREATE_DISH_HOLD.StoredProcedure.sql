/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CREATE_DISH_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CREATE_DISH_HOLD

Programmer Name		: IMP Team

Description			: This procedure is used create DISH hold record using input CasePayorMCI_IDNO, TypeHold_CODE, Effective_DATE

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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CREATE_DISH_HOLD]
 @An_CasePayorMCI_IDNO     NUMERIC(10),
 @Ac_TypeHold_CODE         CHAR(1),
 @Ad_Effective_DATE        DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC             CHAR(1) = 'N',
          @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
          @Lc_SourceHoldDh_CODE   CHAR(2) = 'DH',
          @Lc_ReasonHoldMnfn_CODE CHAR(4) = 'MNFN',
          @Lc_Process_ID          CHAR(10) = 'EMERGENCY',
          @Lc_WorkerInstate_IDNO  CHAR(30) = 'DACSES',
          @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_CREATE_DISH_HOLD',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB          NUMERIC,
          @Ln_Value_QNTY          NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB      NUMERIC(11),
          @Ln_Sequence_NUMB       NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB NUMERIC(19),
          @Li_RowCount_QNTY       INT,
          @Lc_Msg_CODE            CHAR(1),
          @Ls_Sql_TEXT            VARCHAR(100),
          @Ls_Sqldata_TEXT        VARCHAR(1000),
          @Ls_ErrorMessage_TEXT   VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'SELECT DISH_Y1';
   SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST( @An_CasePayorMCI_IDNO AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_Value_QNTY = COUNT (1)
     FROM DISH_Y1 d
    WHERE d.CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
      AND d.TypeHold_CODE = @Ac_TypeHold_CODE
      AND @Ad_Effective_DATE BETWEEN d.Effective_DATE AND d.Expiration_DATE
      AND d.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Value_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL('0','')+ ', Process_ID = ' + ISNULL(@Lc_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Effective_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_WorkerInstate_IDNO,'');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = 0,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Effective_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_WorkerInstate_IDNO,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'ASSIGN Sequence_NUMB ';
     SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST( @An_CasePayorMCI_IDNO AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     
     SELECT @Ln_Sequence_NUMB = ISNULL (MAX (d.Sequence_NUMB) + 1, 1)
       FROM DISH_Y1 d
      WHERE d.CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
        AND d.TypeHold_CODE = @Ac_TypeHold_CODE
        AND d.EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = ' INSERT_DISH_Y1 ';
     SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST( @An_CasePayorMCI_IDNO AS VARCHAR ),'')+ ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE,'')+ ', SourceHold_CODE = ' + ISNULL(@Lc_SourceHoldDh_CODE,'')+ ', ReasonHold_CODE = ' + ISNULL(@Lc_ReasonHoldMnfn_CODE,'')+ ', Effective_DATE = ' + ISNULL(CAST( @Ad_Effective_DATE AS VARCHAR ),'')+ ', Expiration_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Sequence_NUMB = ' + ISNULL(CAST( @Ln_Sequence_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Effective_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     INSERT DISH_Y1
            (CasePayorMCI_IDNO,
             TypeHold_CODE,
             SourceHold_CODE,
             ReasonHold_CODE,
             Effective_DATE,
             Expiration_DATE,
             Sequence_NUMB,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE)
     VALUES (@An_CasePayorMCI_IDNO,--CasePayorMCI_IDNO
             @Ac_TypeHold_CODE,--TypeHold_CODE
             @Lc_SourceHoldDh_CODE,--SourceHold_CODE
             @Lc_ReasonHoldMnfn_CODE,--ReasonHold_CODE
             @Ad_Effective_DATE,--Effective_DATE
             @Ld_High_DATE,--Expiration_DATE
             @Ln_Sequence_NUMB,--Sequence_NUMB
             @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
             0,--EventGlobalEndSeq_NUMB
             @Ad_Effective_DATE,--BeginValidity_DATE
             @Ld_High_DATE); --EndValidity_DATE
     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_No_INDC;
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
