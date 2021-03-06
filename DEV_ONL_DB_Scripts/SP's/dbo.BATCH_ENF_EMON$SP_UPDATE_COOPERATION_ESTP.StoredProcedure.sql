/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* --------------------------------------------------------------------------------------------------- 
Procedure Name    : BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP
Programmer Name   : IMP Team 
Description       : This procedure is used to update cooperation estp
Frequency         : 
Developed On      : 01/05/2012
Called By         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On         : BATCH_COMMON$SP_UPDATE_CASE_DETAILS, BATCH_ENF_ELFC$SP_INITIATE_REMEDY
-------------------------------------------------------------------------------------------------------
Modified By       : 
Modified On       : 
Version No        :  1.0
-------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC (10),
 @An_OthpSource_IDNO          NUMERIC(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ac_Process_ID               CHAR (10),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_NonCoopFailed_CODE           CHAR(1) = 'P',
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_TypeCaseNonPa_CODE           CHAR(1) = 'N',
          @Lc_TypeCasePaTanf_CODE          CHAR(1) = 'A',
          @Lc_TypeOthpSourceNcp_CODE       CHAR(1) = 'A',
          @Lc_SubsystemCaseManagement_CODE CHAR(2) = 'CM',
          @Lc_StatusStart_CODE             CHAR(4) = 'STRT',
          @Lc_ActivityMajorCclo_CODE       CHAR(4) = 'CCLO',
          @Ls_Routine_TEXT                 VARCHAR(100) = 'BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP';
  DECLARE @Ln_Count_NUMB            NUMERIC(6) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_TypeCase_CODE         CHAR(1),
          @Lc_GoodCause_CODE        CHAR(1),
          @Lc_StatusCase_CODE       CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(300),
          @Ls_Sqldata_TEXT          VARCHAR(3000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_GoodCause_DATE        DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP SELECT CASE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));

   SELECT @Lc_TypeCase_CODE = A.TypeCase_CODE
     FROM CASE_Y1 A
    WHERE Case_IDNO = @An_Case_IDNO;

   /* If the the Case Type is A i.e. PA TANF the system updates the Cooperation field on CCRT to F i.e. FAILED TO COOPERATE W/O GOOD CAUSE and 
      sets the Cooperation Date to the current system date. */
   IF @Lc_TypeCase_CODE = @Lc_TypeCasePaTanf_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP SELECT CASE_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));

     SELECT @Lc_StatusCase_CODE = A.StatusCase_CODE,
            @Lc_GoodCause_CODE = A.GoodCause_CODE,
            @Ld_GoodCause_DATE = A.GoodCause_DATE
       FROM CASE_Y1 A
      WHERE Case_IDNO = @An_Case_IDNO;

     -- UPDATING CASE TABLE
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_CASE_DETAILS';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', WorkerUpdate_ID = ' + CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30));

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

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE IF @Lc_TypeCase_CODE = @Lc_TypeCaseNonPa_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP SELECT DMJR_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));

     SELECT @Ln_Count_NUMB = COUNT(1)
       FROM DMJR_Y1 j
      WHERE j.Case_IDNO = @An_Case_IDNO
        AND j.OrderSeq_NUMB IN(0, @An_OrderSeq_NUMB)
        -- CCLO will not be initiated if any of the Case closure chain is Active 
        AND j.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
        AND j.OthpSource_IDNO = @An_MemberMci_IDNO
        AND j.Status_CODE = @Lc_StatusStart_CODE;

     IF @Ln_Count_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_ENF_ELFC$SP_INITIATE_REMEDY';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', Process_ID = ' + CAST(@Ac_Process_ID AS VARCHAR(10)) + ', WorkerUpdate_ID = ' + CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30));

       EXEC BATCH_ENF_ELFC$SP_INITIATE_REMEDY
        @Ac_TypeChange_CODE          = NULL,
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO          = @An_MemberMci_IDNO,
        @Ac_TypeOthpSource_CODE      = @Lc_TypeOthpSourceNcp_CODE,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCclo_CODE,
        @Ac_Subsystem_CODE           = @Lc_SubsystemCaseManagement_CODE,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeReference_CODE       = @Lc_Space_TEXT,
        @Ac_Reference_ID             = @Lc_Space_TEXT,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
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
