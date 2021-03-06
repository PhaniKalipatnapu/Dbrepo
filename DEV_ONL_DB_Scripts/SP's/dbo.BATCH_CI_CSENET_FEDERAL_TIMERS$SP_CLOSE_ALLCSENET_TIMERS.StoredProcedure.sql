/****** Object:  StoredProcedure [dbo].[BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to close all the CSENET timers associated with other state,case id and function
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_CSENET_FEDERAL_TIMERS$SP_CLOSE_ALLCSENET_TIMERS] (
 @An_TransHeader_IDNO       NUMERIC(12),
 @Ad_Transaction_DATE       DATETIME2(0),
 @Ac_Message_ID             CHAR(11),
 @An_Case_IDNO              NUMERIC(6),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Function_CODE          CHAR(3),
 @Ac_RespondInit_CODE       CHAR(1),
 @Ad_Run_DATE               DATETIME2(0),
 @Ac_Job_ID                 CHAR(7),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_InitiateState_CODE                CHAR(1) = 'I',
          @Lc_InitiateInternational_CODE        CHAR(1) = 'C',
          @Lc_InitiateTribal_CODE               CHAR(1) = 'T',
          @Lc_RespondingState_CODE              CHAR(1) = 'R',
          @Lc_RespondingInternational_CODE      CHAR(1) = 'Y',
          @Lc_RespondingTribal_CODE             CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                 CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                CHAR(1) = 'S',
          @Lc_Enforcement_Minor_CODE            CHAR(1) = 'N',
          @Lc_Establishment_Minor_CODE          CHAR(1) = 'S',
          @Lc_Paternity_Minor_CODE              CHAR(1) = 'P',
          @Lc_Subsystem_CODE                    CHAR(2) = 'IN',
          @Lc_FunctionEnforcement_CODE          CHAR(3) = 'ENF',
          @Lc_FunctionEstablishment_CODE        CHAR(3) = 'EST',
          @Lc_FunctionPaternity_CODE            CHAR(3) = 'PAT',
          @Lc_RemedyStatusStart_CODE            CHAR(4) = 'STRT',
          @Lc_ActivityMajorCASE_CODE            CHAR(4) = 'CASE',
          @Lc_BatchRunUser_TEXT                 CHAR(5) = 'BATCH',
          @Lc_InitiateActivityMinorCox11_CODE   CHAR(5) = 'COX11',
          @Lc_InitiateActivityMinorCax20_CODE   CHAR(5) = 'CAX20',
          @Lc_InitiateActivityMinorCox90_CODE   CHAR(5) = 'COX90',
          @Lc_InitiateActivityMinorCxr30_CODE   CHAR(5) = 'CXR30',
          @Lc_InitiateActivityMinorCxi30_CODE   CHAR(5) = 'CXI30',
          @Lc_RespondingActivityMinorCix30_CODE CHAR(5) = 'CIX30',
          @Lc_RespondingActivityMinorCix90_CODE CHAR(5) = 'CIX90',
          @Lc_RespondingActivityMinorCx090_CODE CHAR(5) = 'CX090',
          @Lc_RespondingActivityMinorCx180_CODE CHAR(5) = 'CX180',
          @Lc_RespondingActivityMinorSx180_CODE CHAR(5) = 'SX180',
          @Ls_Procedure_NAME                    VARCHAR(100) = 'SP_CLOSE_ALLCSENET_TIMERS';
  DECLARE @Ln_FetchStatus_QNTY         NUMERIC(10, 0),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_Error_NUMB               INT,
          @Li_ErrorLine_NUMB           INT,
          @Lc_MinorReplacement_CODE    CHAR(1),
          @Lc_Msg_CODE                 CHAR(5),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ls_Sql_TEXT                 VARCHAR(4000),
          @Ls_Sqldata_TEXT             VARCHAR(4000);
  DECLARE @Lc_ActCur_ActivityMinor_CODE CHAR(5),
          @Ln_ActCur_MemberMci_IDNO     NUMERIC(10);
  DECLARE @Lc_EnActCur_ActivityMinor_CODE CHAR(5),
          @Lc_EnActCur_MemberMci_IDNO     CHAR(10);

  BEGIN TRY
   IF (@Ac_RespondInit_CODE = @Lc_InitiateState_CODE
        OR @Ac_RespondInit_CODE = @Lc_InitiateInternational_CODE
        OR @Ac_RespondInit_CODE = @Lc_InitiateTribal_CODE)
    BEGIN
     IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      BEGIN
       SET @Lc_MinorReplacement_CODE = @Lc_Enforcement_Minor_CODE;
      END;
     ELSE IF @Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
      BEGIN
       SET @Lc_MinorReplacement_CODE = @Lc_Establishment_Minor_CODE;
      END;
     ELSE IF @Ac_Function_CODE = @Lc_FunctionPaternity_CODE
      BEGIN
       SET @Lc_MinorReplacement_CODE = @Lc_Paternity_Minor_CODE;
      END;

     IF (@Ac_Function_CODE != @Lc_FunctionEnforcement_CODE
         AND @Ac_Function_CODE != @Lc_FunctionEstablishment_CODE
         AND @Ac_Function_CODE != @Lc_FunctionPaternity_CODE)
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

       RETURN;
      END;

     SET @Lc_InitiateActivityMinorCox11_CODE = REPLACE(@Lc_InitiateActivityMinorCox11_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Lc_InitiateActivityMinorCax20_CODE = REPLACE(@Lc_InitiateActivityMinorCax20_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Lc_InitiateActivityMinorCox90_CODE = REPLACE(@Lc_InitiateActivityMinorCox90_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Lc_InitiateActivityMinorCxr30_CODE = REPLACE(@Lc_InitiateActivityMinorCxr30_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Ls_Sql_TEXT = 'ACTIVITY CURSOR';

     DECLARE Act_CUR INSENSITIVE CURSOR FOR
      SELECT DISTINCT
             a.ActivityMinor_CODE,
             a.MemberMci_IDNO
        FROM DMNR_Y1 a
       WHERE a.ActivityMinor_CODE IN (@Lc_InitiateActivityMinorCox11_CODE, @Lc_InitiateActivityMinorCax20_CODE, @Lc_InitiateActivityMinorCox90_CODE, @Lc_InitiateActivityMinorCxr30_CODE)
         AND a.ActivityMinorNext_CODE = @Ac_IVDOutOfStateFips_CODE
         AND a.Case_IDNO = @An_Case_IDNO
         AND a.Status_CODE = @Lc_RemedyStatusStart_CODE;

     OPEN Act_CUR;

     FETCH NEXT FROM Act_CUR INTO @Lc_ActCur_ActivityMinor_CODE, @Ln_ActCur_MemberMci_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     -- Activity cursor to update action alert
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Ac_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = 'N',
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_ACTION_ALERT';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActCur_ActivityMinor_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_UPDATE_ACTION_ALERT
        @An_Case_IDNO                = @An_Case_IDNO,
        @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCASE_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActCur_ActivityMinor_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_SignedonWorker_ID        = @Lc_BatchRunUser_TEXT,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
        BEGIN
         RAISERROR(50001,16,1);
        END;

       FETCH NEXT FROM Act_CUR INTO @Lc_ActCur_ActivityMinor_CODE, @Ln_ActCur_MemberMci_IDNO;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     IF CURSOR_STATUS('LOCAL', 'Act_CUR') IN (0, 1)
      BEGIN
       CLOSE Act_CUR;

       DEALLOCATE Act_CUR;
      END;
    END
   ELSE IF (@Ac_RespondInit_CODE = @Lc_RespondingState_CODE
        OR @Ac_RespondInit_CODE = @Lc_RespondingInternational_CODE
        OR @Ac_RespondInit_CODE = @Lc_RespondingTribal_CODE)
    BEGIN
     IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      BEGIN
       SET @Lc_MinorReplacement_CODE = @Lc_Enforcement_Minor_CODE;
      END
     ELSE IF @Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
      BEGIN
       SET @Lc_MinorReplacement_CODE = @Lc_Establishment_Minor_CODE;
      END
     ELSE IF @Ac_Function_CODE = @Lc_FunctionPaternity_CODE
      BEGIN
       SET @Lc_MinorReplacement_CODE = @Lc_Paternity_Minor_CODE;
      END;

     IF (@Ac_Function_CODE != @Lc_FunctionEnforcement_CODE
         AND @Ac_Function_CODE != @Lc_FunctionEstablishment_CODE
         AND @Ac_Function_CODE != @Lc_FunctionPaternity_CODE)
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

       RETURN;
      END;

     SET @Lc_RespondingActivityMinorCix30_CODE = REPLACE(@Lc_RespondingActivityMinorCix30_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Lc_RespondingActivityMinorCix90_CODE = REPLACE(@Lc_RespondingActivityMinorCix90_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Lc_RespondingActivityMinorCx090_CODE = REPLACE(@Lc_RespondingActivityMinorCx090_CODE, 'X', @Lc_MinorReplacement_CODE);
     SET @Lc_RespondingActivityMinorCx180_CODE = REPLACE(@Lc_RespondingActivityMinorCx180_CODE, 'X', @Lc_MinorReplacement_CODE);

     DECLARE EnAct_CUR INSENSITIVE CURSOR FOR
      SELECT DISTINCT
             a.ActivityMinor_CODE,
             a.MemberMci_IDNO
        FROM DMNR_Y1 a
       WHERE a.ActivityMinor_CODE IN (@Lc_RespondingActivityMinorCix30_CODE, @Lc_RespondingActivityMinorCix90_CODE, @Lc_RespondingActivityMinorCx090_CODE, @Lc_RespondingActivityMinorCx180_CODE)
         AND a.ActivityMinorNext_CODE = @Ac_IVDOutOfStateFips_CODE
         AND a.Case_IDNO = @An_Case_IDNO
         AND a.Status_CODE = @Lc_RemedyStatusStart_CODE;

     OPEN EnAct_CUR;

     FETCH NEXT FROM EnAct_CUR INTO @Lc_EnActCur_ActivityMinor_CODE, @Lc_EnActCur_MemberMci_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     -- Update action alert for timers
     WHILE @Ln_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 2';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Ac_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = 'N',
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_ACTION_ALERT';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_EnActCur_ActivityMinor_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_UPDATE_ACTION_ALERT
        @An_Case_IDNO                = @An_Case_IDNO,
        @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCASE_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_EnActCur_ActivityMinor_CODE,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
        @Ac_SignedonWorker_ID        = @Lc_BatchRunUser_TEXT,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
        BEGIN
         RAISERROR(50001,16,1);
        END;

       FETCH NEXT FROM EnAct_CUR INTO @Lc_EnActCur_ActivityMinor_CODE, @Lc_EnActCur_MemberMci_IDNO;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     IF CURSOR_STATUS('LOCAL', 'EnAct_CUR') IN (0, 1)
      BEGIN
       CLOSE EnAct_CUR;

       DEALLOCATE EnAct_CUR;
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('LOCAL', 'Act_CUR') IN (0, 1)
    BEGIN
     CLOSE Act_CUR;

     DEALLOCATE Act_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'EnAct_CUR') IN (0, 1)
    BEGIN
     CLOSE EnAct_CUR;

     DEALLOCATE EnAct_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
