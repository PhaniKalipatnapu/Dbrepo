/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_CREATE_DISB_HOLD_INSTR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_CREATE_DISB_HOLD_INSTR
Programmer Name		: IMP Team
Description			: This procedure is used for Disbursement hold instruction creation.
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_CREATE_DISB_HOLD_INSTR]
 @Ac_CheckRecipient_ID     CHAR(10),
 @Ac_CheckRecipient_CODE   CHAR(1),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_ReasonHold_CODE       CHAR(4),
 @As_DescriptionNote_TEXT  VARCHAR(4000),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_DisbursementHoldInstruction1980_NUMB NUMERIC = 1980,
          @Lc_CaseRelationshipCp_CODE              CHAR(1) = 'C',
          @Lc_No_INDC                              CHAR(1) = 'N',
          @Lc_StatusFailed_CODE                    CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
          @Lc_EntityAction_TEXT                    CHAR(3) = 'ADD',
          @Lc_WorkerInstate_IDNO                   CHAR(6) = 'DACSES',
          @Lc_ProcessHldi_IDNO                     CHAR(10) = 'HLDI',
          @Ls_Routine_TEXT                         VARCHAR(60) = 'BATCH_COMMON$SP_CREATE_DISB_HOLD_INSTR',
          @Ld_High_DATE                            DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB          NUMERIC,
          @Ln_Zero_NUMB           NUMERIC(1) = 0,
          @Ln_Temp_Case_IDNO      NUMERIC(6),
          @Ln_ErrorLine_NUMB      NUMERIC(11),
          @Ln_Count_QNTY          NUMERIC(11) = 0,
          @Ln_Seq_NUMB            NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB NUMERIC(19),
          @Li_Rowcount_QNTY       SMALLINT,
          @Lc_Msg_CODE            CHAR(1) = '',
          @Ls_Sql_TEXT            VARCHAR(100) = '',
          @Ls_Sqldata_TEXT        VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT   VARCHAR(4000) = '',
          @Ld_Temp_DATE           DATETIME2(0);

  BEGIN TRY
   SET @As_DescriptionError_TEXT = '';
   SET @Ac_Msg_CODE = '';

   IF @An_Case_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CheckRecipient_ID IS CP 1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE,'');

     SELECT @Ln_Count_QNTY = COUNT (1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ac_CheckRecipient_ID
        AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (c.Case_IDNO) = @An_Case_IDNO
        AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;

     IF @Ln_Count_QNTY != @Ln_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT VCHLD1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT @Ln_Count_QNTY = COUNT (1)
         FROM CHLD_Y1 c
        WHERE c.CheckRecipient_ID = @Ac_CheckRecipient_ID
          AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (c.Case_IDNO) = @An_Case_IDNO
          AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND DATEADD (D, -1, c.Expiration_DATE)
          AND c.EndValidity_DATE = @Ld_High_DATE;
      END
     ELSE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'SELECT CheckRecipient_ID IS NOT CP 1 FAILED';

       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     IF @An_Case_IDNO = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT CheckRecipient_ID IS CP 2';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipCp_CODE,'');

       SELECT @Ln_Count_QNTY = COUNT (1)
         FROM CMEM_Y1 c
        WHERE c.MemberMci_IDNO = @Ac_CheckRecipient_ID
          AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE;

       IF @Ln_Count_QNTY != @Ln_Zero_NUMB
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT VCHLD2';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         SELECT @Ln_Count_QNTY = COUNT (1)
           FROM CHLD_Y1 c
          WHERE c.CheckRecipient_ID = @Ac_CheckRecipient_ID
            AND dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (c.Case_IDNO) IS NULL
            AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND DATEADD (D, -1, c.Expiration_DATE)
            AND c.EndValidity_DATE = @Ld_High_DATE;
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'SELECT CheckRecipient_ID IS NOT CP 2 FAILED';

         RAISERROR (50001,16,1);
        END
      END
    END

   IF @Ln_Count_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ld_Temp_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
     
     SET @Ls_Sql_TEXT = 'GENERATE Seq_IDNO';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Ln_DisbursementHoldInstruction1980_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessHldi_IDNO,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Temp_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_WorkerInstate_IDNO,'');
     
     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Ln_DisbursementHoldInstruction1980_NUMB,
      @Ac_Process_ID              = @Lc_ProcessHldi_IDNO,
      @Ad_EffectiveEvent_DATE     = @Ld_Temp_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_WorkerInstate_IDNO,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'SELECT CHLD_Y1 Sequence_NUMB';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'');

     SELECT @Ln_Seq_NUMB = (ISNULL (MAX (c.Sequence_NUMB), 0) + 1)
       FROM CHLD_Y1 c
      WHERE c.CheckRecipient_ID = @Ac_CheckRecipient_ID;

     SET @Ln_Temp_Case_IDNO = @An_Case_IDNO;
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX';
     SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Ln_DisbursementHoldInstruction1980_NUMB AS VARCHAR ),'')+ ', EntityCase_IDNO = ' + ISNULL(CAST( @Ln_Temp_Case_IDNO AS VARCHAR ),'')+ ', EntityCheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', EntityCheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', EntityRshld_IDNO = ' + ISNULL(@Ac_ReasonHold_CODE,'')+ ', EntityActn_IDNO = ' + ISNULL(@Lc_EntityAction_TEXT,'');
     
     EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
      @An_EventGlobalSeq_NUMB       = @Ln_EventGlobalSeq_NUMB,
      @An_EventFunctionalSeq_NUMB   = @Ln_DisbursementHoldInstruction1980_NUMB,
      @An_EntityCase_IDNO           = @Ln_Temp_Case_IDNO,
      @Ac_EntityCheckRecipient_ID   = @Ac_CheckRecipient_ID,
      @Ac_EntityCheckRecipient_CODE = @Ac_CheckRecipient_CODE,
      @Ac_EntityRshld_IDNO          = @Ac_ReasonHold_CODE,
      @Ac_EntityActn_IDNO           = @Lc_EntityAction_TEXT,
      @Ac_Msg_CODE                  = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT CHLD_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', Sequence_NUMB = ' + ISNULL(CAST( @Ln_Seq_NUMB AS VARCHAR ),'')+ ', ReasonHold_CODE = ' + ISNULL(@Ac_ReasonHold_CODE,'')+ ', Effective_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Expiration_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'');

     INSERT CHLD_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Sequence_NUMB,
             ReasonHold_CODE,
             Effective_DATE,
             Expiration_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             Case_IDNO)
     VALUES (@Ac_CheckRecipient_ID,--CheckRecipient_ID
             @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
             @Ln_Seq_NUMB,--Sequence_NUMB
             @Ac_ReasonHold_CODE,--ReasonHold_CODE
             @Ad_Run_DATE,--Effective_DATE
             @Ld_High_DATE,--Expiration_DATE
             @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
             @Ln_Zero_NUMB,--EventGlobalEndSeq_NUMB
             dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--BeginValidity_DATE
             @Ld_High_DATE,--EndValidity_DATE
             @An_Case_IDNO); --Case_IDNO
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT CHLD_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT UNOT_Y1';
     SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'')+ ', EventGlobalApprovalSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'');

     INSERT UNOT_Y1
            (EventGlobalSeq_NUMB,
             DescriptionNote_TEXT,
             EventGlobalApprovalSeq_NUMB)
     VALUES ( @Ln_EventGlobalSeq_NUMB,-- EventGlobalSeq_NUMB
              @As_DescriptionNote_TEXT,-- DescriptionNote_TEXT
              @Ln_Zero_NUMB); -- EventGlobalApprovalSeq_NUMB
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT UNOT_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = 'RECORD ALREADY EXISTS IN CHLD_Y1';
    END
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
    
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
