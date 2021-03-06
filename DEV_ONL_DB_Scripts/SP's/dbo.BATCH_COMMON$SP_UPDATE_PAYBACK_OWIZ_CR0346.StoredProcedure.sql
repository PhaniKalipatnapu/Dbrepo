/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ_CR0346]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ_CR0346
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

CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ_CR0346] (
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
          @Lc_Yes_INDC                      CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_RevwUpdate_CODE               CHAR(1) = 'N',
          @Lc_ReasEc_CODE                   CHAR(2) = 'EC',
          @Lc_ReasOm_CODE                   CHAR(2) = 'OM',
          @Lc_ReasCc_CODE                   CHAR(2) = 'CC',
          @Lc_ReasPt_CODE                   CHAR(2) = 'PT',
          @Lc_ReasSc_CODE                   CHAR(2) = 'SC',
          @Lc_DebtTypeChildSupp_CODE        CHAR(2) = 'CS',
          @Lc_DebtTypeMedicalSupp_CODE      CHAR(2) = 'MS',
          @Lc_SubsystemFm_CODE              CHAR(3) = 'FM',
          @Lc_ProcessOwiz_IDNO              CHAR(4) = 'OWIZ',
          @Lc_MajorActivityCase_CODE        CHAR(4) = 'CASE',
          @Lc_MinorActivityUpayb_CODE       CHAR(5) = 'UPAYB',
          @Ls_Routine_TEXT                  VARCHAR(400) = 'BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ_CR0346',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Run_DATE                      DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
  DECLARE @Ln_RowCount_QNTY            NUMERIC,
          @Ln_Error_NUMB               NUMERIC,
          @Ln_Value_QNTY               NUMERIC(4) = 0,
          @Ln_Topic_IDNO               NUMERIC(10),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_TypeDebt_CODE            CHAR(2),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000),
          @Ld_BeginObligation_DATE     DATE,
          @Ld_NextReview_DATE          DATE,
          @Ld_LastReview_DATE          DATE;
  DECLARE @Ls_Sql_TEXT     VARCHAR(400) = '',
          @Ls_Sqldata_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_ErrorMessage_TEXT = '';
   SET @Ls_Routine_TEXT = 'BATCH_COMMON$SP_UPDATE_PAYBACK_OWIZ_CR0346 ';
   SET @Lc_TypeDebt_CODE = @Ac_TypeDebt_CODE;
    SET @An_ExpectToPay_AMNT =ISNULL(@An_ExpectToPay_AMNT, 0);
   SET @Ac_ExpectToPay_CODE =ISNULL(@Ac_ExpectToPay_CODE, @Lc_Space_TEXT);

   IF @Lc_TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1 COUNT';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'');

     SELECT @Ln_Value_QNTY = COUNT(1)
       FROM OBLE_Y1 O
      WHERE O.Case_IDNO = @An_Case_IDNO
        AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND O.EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB
        AND O.ReasonChange_CODE IN (@Lc_ReasEc_CODE, @Lc_ReasOm_CODE, @Lc_ReasCc_CODE, @Lc_ReasPt_CODE,
                                    @Lc_ReasSc_CODE, @Lc_Space_TEXT);

     IF @Ln_Value_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1 BeginObligation_DATE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeChildSupp_CODE,'');

       SELECT @Ld_BeginObligation_DATE = MAX(x.BeginObligation_DATE)
         FROM OBLE_Y1 X
        WHERE X.Case_IDNO = @An_Case_IDNO
          AND X.OrderSeq_NUMB = @An_OrderSeq_NUMB
          AND X.EndValidity_DATE = @Ld_High_DATE
          AND X.TypeDebt_CODE = @Lc_DebtTypeChildSupp_CODE;

       IF @Ld_BeginObligation_DATE IS NOT NULL
        BEGIN
         SET @Ld_NextReview_DATE = DATEADD(m, 30, @Ld_BeginObligation_DATE);
         SET @Ld_LastReview_DATE = @Ld_BeginObligation_DATE;
        END
       ELSE
        BEGIN
		 SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1 BeginObligation_DATE 2';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeMedicalSupp_CODE,'');

         SELECT @Ld_BeginObligation_DATE = MAX(x.BeginObligation_DATE)
           FROM OBLE_Y1 X
          WHERE X.Case_IDNO = @An_Case_IDNO
            AND X.OrderSeq_NUMB = @An_OrderSeq_NUMB
            AND X.EndValidity_DATE = @Ld_High_DATE
            AND X.TypeDebt_CODE = @Lc_DebtTypeMedicalSupp_CODE;

         IF @Ld_BeginObligation_DATE IS NOT NULL
          BEGIN
           SET @Ld_NextReview_DATE = DATEADD(m, 30, @Ld_BeginObligation_DATE);
           SET @Ld_LastReview_DATE = @Ld_BeginObligation_DATE;
          END
        END
      END
	 SET @Ls_Sql_TEXT = 'SELECT SORD_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Lc_RevwUpdate_CODE = CASE
                                   WHEN COUNT(1) > 0
                                    THEN @Lc_Yes_INDC
                                   ELSE @Lc_No_INDC
                                  END
       FROM SORD_Y1 S
      WHERE S.Case_IDNO = @An_Case_IDNO
        AND S.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND S.EndValidity_DATE = @Ld_High_DATE
        AND (S.NextReview_DATE != @Ld_NextReview_DATE
             AND @Ld_NextReview_DATE > @Ld_Run_DATE);
    END
  
   IF @Lc_RevwUpdate_CODE = @Lc_Yes_INDC 
		OR @Ac_ExpectToPay_CODE <> @Ac_TypePayback_CODE 
		 OR @An_ExpectToPay_AMNT <> @An_Payback_AMNT
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE SORD_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE SORD_Y1
        SET EndValidity_DATE = @Ld_Run_DATE,
            EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
      WHERE Case_IDNO = @An_Case_IDNO
        AND OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT SORD_Y1';
     SET @Ls_Sqldata_TEXT = 'WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'');

     INSERT SORD_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             Order_IDNO,
             File_ID,
             OrderEnt_DATE,
             OrderIssued_DATE,
             OrderEffective_DATE,
             OrderEnd_DATE,
             ReasonStatus_CODE,
             StatusOrder_CODE,
             StatusOrder_DATE,
             InsOrdered_CODE,
             MedicalOnly_INDC,
             Iiwo_CODE,
             NoIwReason_CODE,
             IwoInitiatedBy_CODE,
             GuidelinesFollowed_INDC,
             DeviationReason_CODE,
             DescriptionDeviationOthers_TEXT,
             OrderOutOfState_ID,
             CejStatus_CODE,
             CejFips_CODE,
             IssuingOrderFips_CODE,
             Qdro_INDC,
             UnreimMedical_INDC,
             CpMedical_PCT,
             NcpMedical_PCT,
             ParentingTime_PCT,
             NoParentingDays_QNTY,
             PetitionerAppeared_INDC,
             RespondentAppeared_INDC,
             OthersAppeared_INDC,
             PetitionerReceived_INDC,
             RespondentReceived_INDC,
             OthersReceived_INDC,
             PetitionerMailed_INDC,
             RespondentMailed_INDC,
             OthersMailed_INDC,
             PetitionerMailed_DATE,
             RespondentMailed_DATE,
             OthersMailed_DATE,
             CoverageMedical_CODE,
             CoverageDrug_CODE,
             CoverageMental_CODE,
             CoverageDental_CODE,
             CoverageVision_CODE,
             CoverageOthers_CODE,
             DescriptionCoverageOthers_TEXT,
             WorkerUpdate_ID,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             DescriptionParentingNotes_TEXT,
             LastIrscReferred_DATE,
             LastIrscUpdated_DATE,
             LastIrscReferred_AMNT,
             StatusControl_CODE,
             StateControl_CODE,
             OrderControl_ID,
             PetitionerAttorneyAppeared_INDC,
             RespondentAttorneyAppeared_INDC,
             PetitionerAttorneyReceived_INDC,
             RespondentAttorneyReceived_INDC,
             PetitionerAttorneyMailed_INDC,
             RespondentAttorneyMailed_INDC,
             PetitionerAttorneyMailed_DATE,
             RespondentAttorneyMailed_DATE,
             TypeOrder_CODE,
             ReviewRequested_DATE,
             NextReview_DATE,
             LastReview_DATE,
             LastNoticeSent_DATE,
             DirectPay_INDC,
             SourceOrdered_CODE
     )
     (SELECT A.Case_IDNO,
             A.OrderSeq_NUMB,
             A.Order_IDNO,
             A.File_ID,
             A.OrderEnt_DATE,
             A.OrderIssued_DATE,
             A.OrderEffective_DATE,
             A.OrderEnd_DATE,
             A.ReasonStatus_CODE,
             A.StatusOrder_CODE,
             A.StatusOrder_DATE,
             A.InsOrdered_CODE,
             A.MedicalOnly_INDC,
             A.Iiwo_CODE,
             A.NoIwReason_CODE,
             A.IwoInitiatedBy_CODE,
             A.GuidelinesFollowed_INDC,
             A.DeviationReason_CODE,
             A.DescriptionDeviationOthers_TEXT,
             A.OrderOutOfState_ID,
             A.CejStatus_CODE,
             A.CejFips_CODE,
             A.IssuingOrderFips_CODE,
             A.Qdro_INDC,
             A.UnreimMedical_INDC,
             A.CpMedical_PCT,
             A.NcpMedical_PCT,
             A.ParentingTime_PCT,
             A.NoParentingDays_QNTY,
             A.PetitionerAppeared_INDC,
             A.RespondentAppeared_INDC,
             A.OthersAppeared_INDC,
             A.PetitionerReceived_INDC,
             A.RespondentReceived_INDC,
             A.OthersReceived_INDC,
             A.PetitionerMailed_INDC,
             A.RespondentMailed_INDC,
             A.OthersMailed_INDC,
             A.PetitionerMailed_DATE,
             A.RespondentMailed_DATE,
             A.OthersMailed_DATE,
             A.CoverageMedical_CODE,
             A.CoverageDrug_CODE,
             A.CoverageMental_CODE,
             A.CoverageDental_CODE,
             A.CoverageVision_CODE,
             A.CoverageOthers_CODE,
             A.DescriptionCoverageOthers_TEXT,
             @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
             @Ld_Run_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             A.DescriptionParentingNotes_TEXT,
             A.LastIrscReferred_DATE,
             A.LastIrscUpdated_DATE,
             A.LastIrscReferred_AMNT,
             A.StatusControl_CODE,
             A.StateControl_CODE,
             A.OrderControl_ID,
             A.PetitionerAttorneyAppeared_INDC,
             A.RespondentAttorneyAppeared_INDC,
             A.PetitionerAttorneyReceived_INDC,
             A.RespondentAttorneyReceived_INDC,
             A.PetitionerAttorneyMailed_INDC,
             A.RespondentAttorneyMailed_INDC,
             A.PetitionerAttorneyMailed_DATE,
             A.RespondentAttorneyMailed_DATE,
             A.TypeOrder_CODE,
             A.ReviewRequested_DATE,
             CASE
              WHEN @Lc_RevwUpdate_CODE = @Lc_Yes_INDC
               THEN ISNULL(@Ld_NextReview_DATE, A.NextReview_DATE)
              ELSE A.NextReview_DATE
             END AS NextReview_DATE,
             CASE
              WHEN @Lc_RevwUpdate_CODE = @Lc_Yes_INDC
               THEN ISNULL(@Ld_LastReview_DATE, A.LastReview_DATE)
              ELSE A.LastReview_DATE
             END AS LastReview_DATE,
             A.LastNoticeSent_DATE,
             A.DirectPay_INDC,
             A.SourceOrdered_CODE
        FROM SORD_Y1 A
       WHERE A.Case_IDNO = @An_Case_IDNO
         AND A.OrderSeq_NUMB = @An_OrderSeq_NUMB
         AND A.EndValidity_DATE = @Ld_Run_DATE
         AND A.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB);

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @An_Payback_AMNT =ISNULL(@An_Payback_AMNT, 0);
   SET @Ac_TypePayback_CODE =ISNULL(@Ac_TypePayback_CODE, @Lc_Space_TEXT);
   SET @Ac_FreqPayback_CODE =ISNULL(@Ac_FreqPayback_CODE, @Lc_Space_TEXT);
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_PRORATE_PAYBACK_CR0346 ';   
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', Fips_CODE = ' + ISNULL(@Ac_Fips_CODE,'')+ ', TypeDebt_CODE = ' + ISNULL(@Ac_TypeDebt_CODE,'')+ ', Payback_AMNT = ' + ISNULL(CAST( @An_Payback_AMNT AS VARCHAR ),'')+ ', PaybackType_CODE = ' + ISNULL(@Ac_TypePayback_CODE,'')+ ', PaybackFreq_TEXT = ' + ISNULL(@Ac_FreqPayback_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', Process_Date = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

   EXECUTE BATCH_COMMON_OWIZ$SP_SPLIT_PAYBACK_CR0346
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
