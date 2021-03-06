/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_AKAX]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_AKAX
Programmer Name		: IMP Team
Description			: This procedure is used to insert Alias information
Frequency			: DAILY
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_AKAX]
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_LastAlias_NAME        CHAR(20),
 @Ac_FirstAlias_NAME       CHAR(15),
 @Ac_MiAlias_NAME          CHAR(20),
 @Ac_MaidenAlias_NAME      CHAR(20),
 @Ac_SuffixAlias_NAME      CHAR(4),
 @Ac_Process_ID            CHAR(10),
 @Ac_Source_CODE           CHAR(2),
 @Ad_BeginValidity_DATE    DATE,
 @Ac_WorkerUpdate_ID       CHAR(30),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_TypeAliasAlsoKnownAs_CODE CHAR(1) = 'A',
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Ls_Routine_TEXT              VARCHAR(60) = 'BATCH_COMMON$SP_INSERT_AKAX',
          @Ld_High_DATE                 DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB               NUMERIC,
          @Ln_Rowcount_QNTY            NUMERIC,
          @Ln_Sequence_NUMB            NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_Msg_CODE                 CHAR(1),
          @Ls_Sql_TEXT                 VARCHAR(200),
          @Ls_Sqldata_TEXT             VARCHAR(2000),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = '';

  BEGIN TRY
   IF (NOT EXISTS (SELECT TOP 1 *
                     FROM AKAX_Y1 a
                    WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND a.FirstAlias_NAME = ISNULL(@Ac_FirstAlias_NAME, @Lc_Space_TEXT)
                      AND a.LastAlias_NAME = ISNULL(@Ac_LastAlias_NAME, @Lc_Space_TEXT)
                      AND a.EndValidity_DATE = @Ld_High_DATE))
    BEGIN
     SET @Ls_Sql_TEXT = ' BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT ';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_BeginValidity_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL('N', '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_BeginValidity_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'SELECT Sequence_NUMB FROM AKAX_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_Sequence_NUMB = (ISNULL(MAX(a.Sequence_NUMB), 0) + 1)
       FROM AKAX_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = 'INSERT AKAX_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeAlias_CODE = ' + ISNULL(@Lc_TypeAliasAlsoKnownAs_CODE, '') + ', TitleAlias_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Source_CODE = ' + ISNULL(@Ac_Source_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_BeginValidity_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Sequence_NUMB = ' + ISNULL(CAST(@Ln_Sequence_NUMB AS VARCHAR), '');

     INSERT AKAX_Y1
            (MemberMci_IDNO,
             TypeAlias_CODE,
             LastAlias_NAME,
             FirstAlias_NAME,
             MiddleAlias_NAME,
             TitleAlias_NAME,
             MaidenAlias_NAME,
             SuffixAlias_NAME,
             Source_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             Update_DTTM,
             WorkerUpdate_ID,
             TransactionEventSeq_NUMB,
             Sequence_NUMB)
     VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
              @Lc_TypeAliasAlsoKnownAs_CODE,--TypeAlias_CODE
              SUBSTRING(@Ac_LastAlias_NAME, 1, 20),--LastAlias_NAME
              SUBSTRING(@Ac_FirstAlias_NAME, 1, 15),--FirstAlias_NAME
              SUBSTRING(@Ac_MiAlias_NAME, 1, 20),--MiddleAlias_NAME
              @Lc_Space_TEXT,--TitleAlias_NAME
              ISNULL(@Ac_MaidenAlias_NAME, @Lc_Space_TEXT),--MaidenAlias_NAME
              ISNULL(@Ac_SuffixAlias_NAME, @Lc_Space_TEXT),--SuffixAlias_NAME
              @Ac_Source_CODE,--Source_CODE
              @Ad_BeginValidity_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
              @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
              @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
              @Ln_Sequence_NUMB); --Sequence_NUMB

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO AKAX FAILED';

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
  END CATCH;
 END;


GO
