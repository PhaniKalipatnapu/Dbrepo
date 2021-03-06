/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ
Programmer Name		: IMP Team
Description			: Procedure to update payback information while entering or modifying obligations
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

CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @An_OrderSeq_NUMB         NUMERIC(2, 0),
 @Ac_Fips_CODE			   CHAR(7),
 @An_Payback_AMNT          NUMERIC(11, 2),
 @An_ExpectToPay_AMNT      NUMERIC(11, 2),
 @Ac_FreqPayback_CODE      CHAR(1),
 @Ac_TypePayback_CODE      CHAR(1),
 @Ac_ExpectToPay_CODE      CHAR(1),
 @An_EventGlobalSeq_NUMB   NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID     CHAR(30),
 @Ac_TypeDebt_CODE         CHAR(2) = ' ',
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_FunctionalUpdaatePayback_NUMB INT = 1100,
          @Li_Zero_NUMB                     INT = 0,
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_SubsystemFm_CODE              CHAR(3) = 'FM',
          @Lc_ProcessOwiz_IDNO              CHAR(4) = 'OWIZ',
          @Lc_MajorActivityCase_CODE        CHAR(4) = 'CASE',
          @Lc_MinorActivityUpayb_CODE       CHAR(5) = 'UPAYB',
          @Ls_Routine_TEXT                  VARCHAR(400) = 'BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ',
          @Ld_Run_DATE                      DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
  DECLARE @Ln_Error_NUMB               NUMERIC,
          @Ln_Topic_IDNO               NUMERIC(10),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_TypeDebt_CODE            CHAR(2),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000);
  DECLARE @Ls_Sql_TEXT     VARCHAR(400) = '',
          @Ls_Sqldata_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_ErrorMessage_TEXT = '';
   SET @Ls_Routine_TEXT = 'BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ ';
   SET @Lc_TypeDebt_CODE = @Ac_TypeDebt_CODE;
   SET @An_ExpectToPay_AMNT =ISNULL(@An_ExpectToPay_AMNT, 0);
   SET @Ac_ExpectToPay_CODE =ISNULL(@Ac_ExpectToPay_CODE, @Lc_Space_TEXT);
   
   --13014 - OWIZ - SORD Next Review Date and Last Review Date update removed -REMOVED-
   
   SET @An_Payback_AMNT =ISNULL(@An_Payback_AMNT, 0);
   SET @Ac_TypePayback_CODE =ISNULL(@Ac_TypePayback_CODE, @Lc_Space_TEXT);
   SET @Ac_FreqPayback_CODE =ISNULL(@Ac_FreqPayback_CODE, @Lc_Space_TEXT);
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PRORATE_PAYBACK ';   
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', Fips_CODE = ' + ISNULL(@Ac_Fips_CODE,'')+ ', TypeDebt_CODE = ' + ISNULL(@Ac_TypeDebt_CODE,'')+ ', Payback_AMNT = ' + ISNULL(CAST( @An_Payback_AMNT AS VARCHAR ),'')+ ', PaybackType_CODE = ' + ISNULL(@Ac_TypePayback_CODE,'')+ ', PaybackFreq_TEXT = ' + ISNULL(@Ac_FreqPayback_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Process_Date = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON_OWIZ$SP_SPLIT_PAYBACK
    @An_Case_IDNO                = @An_Case_IDNO,
    @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
    @Ac_Fips_CODE				 = @Ac_Fips_CODE,
    @Ac_TypeDebt_CODE			 = @Ac_TypeDebt_CODE,
    @An_Payback_AMNT			 = @An_Payback_AMNT,
    @Ac_PaybackType_CODE		 = @Ac_TypePayback_CODE,
    @Ac_PaybackFreq_TEXT		 = @Ac_FreqPayback_CODE,  
    @An_EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB, 
    @Ad_Process_Date             = @Ad_Run_DATE, 
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessOwiz_IDNO,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_FunctionalUpdaatePayback_NUMB AS VARCHAR ),'');
 
  --Entry should be only in case jorunel when paybcak amount changes happens only.
  IF @Ac_ExpectToPay_CODE <> @Ac_TypePayback_CODE 
		 OR @An_ExpectToPay_AMNT <> @An_Payback_AMNT
   BEGIN		 
   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
    @Ac_Process_ID              = @Lc_ProcessOwiz_IDNO,
    @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @An_EventFunctionalSeq_NUMB = @Li_FunctionalUpdaatePayback_NUMB,
    @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY1 ';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Li_Zero_NUMB AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityUpayb_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemFm_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', Msg_CODE = ' + ISNULL(@Ac_Msg_CODE,'')+ ', Topic_IDNO = ' + ISNULL(CAST( @Ln_Topic_IDNO AS VARCHAR ),'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_ErrorMessage_TEXT,'');

   EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
    @An_Case_IDNO                = @An_Case_IDNO,
    @An_MemberMci_IDNO           = @Li_Zero_NUMB,
    @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
    @Ac_ActivityMinor_CODE       = @Lc_MinorActivityUpayb_CODE,
    @Ac_Subsystem_CODE           = @Lc_SubsystemFm_CODE,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
    @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE,
    @An_Topic_IDNO               = @Ln_Topic_IDNO,
    @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   END
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
