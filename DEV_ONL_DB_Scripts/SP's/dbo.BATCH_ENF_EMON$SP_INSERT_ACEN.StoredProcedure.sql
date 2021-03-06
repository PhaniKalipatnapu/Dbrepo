/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_INSERT_ACEN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_EMON$SP_INSERT_ACEN
Programmer Name :	IMP Team
Description		:	 This procedure inserts a record in FSACEN_Y1 table.
Frequency		: 
Developed On	:	01/05/2012
Called By		:	None
Called On		: 
--------------------------------------------------------------------------------------------------------------------
Modified By		:
Modified On		:
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_INSERT_ACEN]
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @Ad_BeginEnforcement_DATE    DATE,
 @Ad_Run_DATE                 DATE,
 @Ac_WorkerSignedOn_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_TransactionEventSeq_NUMB NUMERIC(19);
  DECLARE @Lc_Success_CODE              CHAR(1) = 'S',
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_EnfOpenStatusEnforce_CODE CHAR(1) = 'O',
          @Lc_EnfSIReasonStatus_CODE    CHAR(2) = 'SI',
          @Ls_Routine_TEXT              VARCHAR(75) = 'BATCH_ENF_EMON$SP_INSERT_ACEN',
          @Ld_HighDate_DATE             DATE = '12/31/9999',
          @Ld_LowDate_DATE              DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(50),
          @Ls_SqlData_TEXT          VARCHAR(400),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'EMON160 : GENERATE SEQ_TXN_EVENT';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Ac_WorkerSignedOn_ID,
    @Ac_Process_ID               = 'CPRO',
    @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
    @Ac_Note_INDC                = ' ',
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE <> @Lc_Success_CODE
    BEGIN
     SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + 'EMON160A : SP_GENERATE_SEQ_TXN_EVENT FAILED' + @Lc_Space_TEXT + @Ls_SqlData_TEXT + @Lc_Space_TEXT + @As_DescriptionError_TEXT;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'EMON161 : UPDATE VACEN';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(6)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(19)), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(20)), '');

   UPDATE ACEN_Y1
      SET EndValidity_DATE = @Ad_Run_DATE
    WHERE Case_IDNO = @An_Case_IDNO
      AND OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'VACEN UPDATE FAILED' + @Lc_Space_TEXT + @Ls_SqlData_TEXT;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'EMON162 : INSERT VACEN';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(5)), '') + ', StatusEnforce_CODE = ' + @Lc_EnfOpenStatusEnforce_CODE + ', ReasonStatus_CODE = ' + @Lc_EnfSIReasonStatus_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR(11)), '') + ', BeginEnforcement_DATE = ' + ISNULL(CAST(@Ad_BeginEnforcement_DATE AS VARCHAR (20)), '');

   INSERT INTO ACEN_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                BeginEnforcement_DATE,
                StatusEnforce_CODE,
                ReasonStatus_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                WorkerUpdate_ID,
                Update_DTTM,
                TransactionEventSeq_NUMB,
                BeginExempt_DATE,
                EndExempt_DATE)
        VALUES (@An_Case_IDNO,--Case_IDNO
                @An_OrderSeq_NUMB,--OrderSeq_NUMB
                @Ad_BeginEnforcement_DATE,--BeginEnforcement_DATE
                @Lc_EnfOpenStatusEnforce_CODE,--StatusEnforce_CODE
                @Lc_EnfSIReasonStatus_CODE,--ReasonStatus_CODE	
                DATEADD(DAY, 1, @Ad_Run_DATE),--BeginValidity_DATE
                @Ld_HighDate_DATE,--EndValidity_DATE
                @Ac_WorkerSignedOn_ID,--WorkerUpdate_ID
                dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                @Ld_LowDate_DATE,--BeginExempt_DATE
                @Ld_HighDate_DATE); --EndExempt_DATE

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'VACEN INSERT FAILED' + @Lc_Space_TEXT + @Ls_SqlData_TEXT;

     RETURN;
    END

   SET @Ac_Msg_CODE = @Lc_Success_CODE;
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
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END


GO
