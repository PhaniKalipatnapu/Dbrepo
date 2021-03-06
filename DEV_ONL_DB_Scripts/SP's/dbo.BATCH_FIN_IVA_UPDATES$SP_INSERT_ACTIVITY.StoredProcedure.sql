/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY
Programmer Name	:	IMP Team.
Description		:	This process re-opens closed cases and/or adds child to existing case and/or changes childs/cp's program type.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS,
					BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS,
					BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE
Called On		:	BATCH_COMMON$SP_INSERT_ACTIVITY
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_ACTIVITY] (
 @Ad_Run_DATE                 DATE,
 @Ac_Job_ID                   CHAR(7),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Subsystem_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19) = 0,
 @An_Line_NUMB                NUMERIC(5) = 0,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_FetchStatus_QNTY         SMALLINT = 0,
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_TypeErrorE_CODE          CHAR(1) = 'E',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_IndNote_TEXT             CHAR(1) = 'N',
          @Lc_Msg_CODE                 CHAR(5) = ' ',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_Notice_ID                CHAR(8),
          @Lc_ActivityMinorCcrcm_CODE  CHAR(5) = 'CCRCM',
          @Ls_DescriptionComments_TEXT VARCHAR(60) = 'CASE REOPENED BY IV-A REFERRAL BATCH',
          @Ls_DescriptionNote_TEXT     VARCHAR(4000),
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_INSERT_ACTIVITY',
          @Ls_Sql_TEXT                 VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT    VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT             VARCHAR(5000) = ' ';
  DECLARE @Ln_Topic_IDNO               NUMERIC,
          @Ln_ErrorLine_NUMB           NUMERIC(11) = 0,
          @Ln_Error_NUMB               NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0;
  --CURSOR VARIABLE DECLARATION:
  DECLARE @Ln_AlertCaseCur_Case_IDNO          NUMERIC(6),
          @Ln_AlertCaseCur_MemberMci_IDNO     NUMERIC(10),
          @Ln_AlertCaseCur_ActivityMajor_CODE CHAR(4),
          @Ln_AlertCaseCur_ActivityMinor_CODE CHAR(5),
          @Ln_AlertCaseCur_Subsystem_CODE     CHAR(2);

  BEGIN TRY
   DECLARE AlertCase_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           b.Case_IDNO,
           b.MemberMci_IDNO,
           b.ActivityMajor_CODE,
           b.ActivityMinor_CODE,
           b.Subsystem_CODE
      FROM ##InsertActivity_P1 b;

   SET @Ls_Sql_TEXT = 'OPEN AlertCase_CUR';

   OPEN AlertCase_CUR;

   SET @Ls_Sql_TEXT = 'FETCH AlertCase_CUR - 1';

   FETCH NEXT FROM AlertCase_CUR INTO @Ln_AlertCaseCur_Case_IDNO, @Ln_AlertCaseCur_MemberMci_IDNO, @Ln_AlertCaseCur_ActivityMajor_CODE, @Ln_AlertCaseCur_ActivityMinor_CODE, @Ln_AlertCaseCur_Subsystem_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --Create alerts
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

     IF @Ln_TransactionEventSeq_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Ac_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = @Lc_IndNote_TEXT,
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     IF @Ln_AlertCaseCur_ActivityMinor_CODE = @Lc_ActivityMinorCcrcm_CODE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = @Ls_DescriptionComments_TEXT;
      END
     ELSE
      BEGIN
       SET @Ls_DescriptionNote_TEXT = NULL;
      END

     IF @Ln_AlertCaseCur_ActivityMinor_CODE = 'NOPRI'
      BEGIN
       SET @Lc_Notice_ID = 'CSI-14';
      END
     ELSE
      BEGIN
       SET @Lc_Notice_ID = NULL;
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_AlertCaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AlertCaseCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Ac_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_AlertCaseCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_AlertCaseCur_MemberMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Ln_AlertCaseCur_ActivityMajor_CODE,
      @Ac_ActivityMinor_CODE       = @Ln_AlertCaseCur_ActivityMinor_CODE,
      @Ac_Subsystem_CODE           = @Ln_AlertCaseCur_Subsystem_CODE,
      @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
      @Ac_Notice_ID                = @Lc_Notice_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @An_Line_NUMB,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     FETCH NEXT FROM AlertCase_CUR INTO @Ln_AlertCaseCur_Case_IDNO, @Ln_AlertCaseCur_MemberMci_IDNO, @Ln_AlertCaseCur_ActivityMajor_CODE, @Ln_AlertCaseCur_ActivityMinor_CODE, @Ln_AlertCaseCur_Subsystem_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE AlertCase_CUR;

   DEALLOCATE AlertCase_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --CLOSE & DEALLOCATE CURSORS
   IF CURSOR_STATUS ('LOCAL', 'AlertCase_CUR') IN (0, 1)
    BEGIN
     CLOSE AlertCase_CUR;

     DEALLOCATE AlertCase_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = ISNULL(@Lc_Msg_CODE, @Lc_StatusFailed_CODE);
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
