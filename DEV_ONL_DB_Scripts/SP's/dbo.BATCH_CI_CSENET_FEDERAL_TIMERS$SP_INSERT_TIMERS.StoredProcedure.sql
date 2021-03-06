/****** Object:  StoredProcedure [dbo].[BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
----------------------------------------------------------------------------------------------------------------------------------
Procedure Name       : BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS
Programmer Name      : IMP Team
Description          : This procedure is used to insert  all the csenet timers associated with other state,case id and function
Frequency            : DAILY
Developed On         :04/04/2011
Called By            : None
Called On            :
-------------------------------------------------------------------------------------------------------------------------------------
Modified By          :
Modified On          :
Version No           :  
----------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_CSENET_FEDERAL_TIMERS$SP_INSERT_TIMERS] (
 @An_TransHeader_IDNO         NUMERIC(12),
 @An_Case_IDNO                NUMERIC(6),
 @An_MajorIntSeq_NUMB         NUMERIC(5) = NULL,
 @An_MinorIntSeq_NUMB         NUMERIC(5) = NULL,
 @An_RespondentMci_IDNO       NUMERIC(10),
 @Ac_Fips_CODE                CHAR(7),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_ActivityMinorOld_CODE    CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Timer_INDC               CHAR(1),
 @Ac_BatchRunUser_TEXT        CHAR(5),
 @Ac_Job_ID                   CHAR(7),
 @Ad_Run_DATE                 DATE,
 @As_Process_NAME             VARCHAR(100),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_ErrorTypeError_CODE    CHAR(1) = 'E',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_Subsystem_CODE         CHAR(3) = 'IN',
          @Lc_MajorActivityCase_CODE CHAR(4) = 'CASE',
          @Lc_ErrorE0133_CODE        CHAR(5) = 'E0113',
          @Ls_Process_NAME           VARCHAR(50) = 'BATCH_CI_CSENET_FEDERAL_TIMERS',
          @Ls_Procedure_NAME         VARCHAR(50) = 'SP_INSERT_TIMERS';
  DECLARE @Ln_Topic_IDNO               NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB           NUMERIC(11) = 0,
          @Ln_Error_NUMB               NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_Msg_CODE                 CHAR(5),
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_Sqldata_TEXT             VARCHAR(4000),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ls_Temp_TEXT                VARCHAR(4000);

  BEGIN TRY
   IF (@Ac_ActivityMinorOld_CODE IS NOT NULL
       AND LTRIM(@Ac_ActivityMinorOld_CODE) != '')
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_ACTION_ALERT';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinorOld_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_UPDATE_ACTION_ALERT
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_MajorIntSeq_NUMB         = @An_MajorIntSeq_NUMB,
      @An_MinorIntSeq_NUMB         = @An_MinorIntSeq_NUMB,
      @An_MemberMci_IDNO           = @An_RespondentMci_IDNO,
      @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
      @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
      @Ac_ActivityMinor_CODE       = @Ac_ActivityMinorOld_CODE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_SignedonWorker_ID        = @Ac_BatchRunUser_TEXT,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   IF @Ac_ActivityMinor_CODE IS NOT NULL
      AND LTRIM(@Ac_ActivityMinor_CODE) != ''
	  AND @An_RespondentMci_IDNO = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT NCP/PF On Case';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');
     SET @An_RespondentMci_IDNO = ISNULL((SELECT TOP 1 MemberMci_IDNO
                                            FROM CMEM_Y1
                                           WHERE Case_IDNO = @An_Case_IDNO
                                             AND CaseRelationship_CODE IN ('A', 'P')
                                             AND CaseMemberStatus_CODE = 'A'), 0);
    END

   IF @An_RespondentMci_IDNO = 0
       OR @Ac_ActivityMinor_CODE IS NULL
       OR LTRIM(@Ac_ActivityMinor_CODE) = ''
    BEGIN
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@An_RespondentMci_IDNO AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE, '');
     SET @Ls_DescriptionError_TEXT = 'NCP/PF - MEMBER ID NOT FOUND';
     SET @Ls_Temp_TEXT = ISNULL(@Ls_Sql_TEXT, '') + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @As_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_StatusFailed_CODE,
      @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_ErrorTypeError_CODE)
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 2';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_RespondentMci_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Ac_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_BatchRunUser_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_Fips_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_MemberMci_IDNO           = @An_RespondentMci_IDNO,
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
      @Ac_ActivityMinor_CODE       = @Ac_ActivityMinor_CODE,
      @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Ac_BatchRunUser_TEXT,
      @Ac_IVDOutOfStateFips_CODE   = @Ac_Fips_CODE,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_StatusSuccess_CODE
         AND @Ln_Topic_IDNO <> 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE DMNR_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '');

       UPDATE DMNR_Y1
          SET ActivityMinorNext_CODE = SUBSTRING(@Ac_Fips_CODE, 1, 2)
        WHERE Case_IDNO = @An_Case_IDNO
          AND Topic_IDNO = @Ln_Topic_IDNO;

       IF @Ac_Timer_INDC = @Lc_Yes_INDC
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CTHB_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '');

         UPDATE CTHB_Y1
            SET Transaction_IDNO = @Ln_Topic_IDNO
          WHERE TransHeader_IDNO = @An_TransHeader_IDNO
            AND IVDOutOfStateFips_CODE = SUBSTRING(@Ac_Fips_CODE, 1, 2);
        END;
      END;

     IF (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE)
         OR @Ln_Topic_IDNO = 0
      BEGIN
       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = @Ls_Procedure_NAME,
        @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = @Ln_Error_NUMB,
        @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = 0,
        @Ac_Error_CODE               = @Lc_ErrorE0133_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;
      END;
    END;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
