/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* --------------------------------------------------------------------------------------------------- 
Procedure Name    : BATCH_ENF_EMON$SP_UPDATE_REVIEW_DATE
Programmer Name   : IMP Team 
Description       : This procedure is used to update the review date
Frequency         : 
Developed On      : 01/05/2012
Called By         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On         : BATCH_COMMON$SP_GENERATE_SEQ
--------------------------------------------------------------------------------------------------- 
Modified By       : 
Modified On       : 
Version No        :  1.0
-------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE]
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @Ad_Run_DATE              DATE,
 @Ac_WorkerUpdate_ID       CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ModifySupportOrder2920_NUMB INT = 2920,
          @Lc_No_CODE                     CHAR(1) = 'N',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_ProcessEMON_ID              CHAR(4) = 'EMON',
          @Ls_Routine_TEXT                VARCHAR(75) = 'BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE',
          @Ld_HighDate_DATE               DATE = '12/31/9999';
  DECLARE @Ln_Rowcount_QNTY            NUMERIC,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Ls_Sql_TEXT                 VARCHAR(300),
          @Ls_Sqldata_TEXT             VARCHAR(3000),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_NextReview_DATE          DATE;

  BEGIN TRY
   -- Selects the Next Review Date
   SET @Ld_NextReview_DATE = CONVERT(DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101);
   -- Update the VSORD with the NEXT REVIEW date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
   SET @Ls_Sqldata_TEXT = ' EventFunctionalSeqUpdate_NUMB = ' + CAST(@Li_ModifySupportOrder2920_NUMB AS VARCHAR(4)) + ', WorkerUpdate_ID = ' + CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(20));

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ModifySupportOrder2920_NUMB,
    @Ac_Process_ID              = @Lc_ProcessEMON_ID,
    @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
    @Ac_Note_INDC               = @Lc_No_CODE,
    @Ac_Worker_ID               = @Ac_WorkerUpdate_ID,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalBeginSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE UPDATE SORD_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2));

   UPDATE SORD_Y1
      SET EndValidity_DATE = @Ad_Run_DATE,
          EventGlobalEndSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB
    WHERE Case_IDNO = @An_Case_IDNO
      AND OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND EndValidity_DATE = @Ld_HighDate_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_UPDATE_SORD_REVIEW_DATE INSERT VSORD';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2)) + ', NextReview_DATE = ' + CAST(@Ld_NextReview_DATE AS VARCHAR (20));

   -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
   INSERT INTO SORD_Y1
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
                LastIrscReferred_DATE,
                LastIrscUpdated_DATE,
                LastIrscReferred_AMNT,
                UnreimMedical_INDC,
                CpMedical_PCT,
                NcpMedical_PCT,
                ParentingTime_PCT,
                NoParentingDays_QNTY,
                DescriptionParentingNotes_TEXT,
                PetitionerAppeared_INDC,
                RespondentAppeared_INDC,
                PetitionerAttorneyAppeared_INDC,
                RespondentAttorneyAppeared_INDC,
                OthersAppeared_INDC,
                PetitionerReceived_INDC,
                RespondentReceived_INDC,
                PetitionerAttorneyReceived_INDC,
                RespondentAttorneyReceived_INDC,
                OthersReceived_INDC,
                PetitionerMailed_INDC,
                RespondentMailed_INDC,
                PetitionerAttorneyMailed_INDC,
                RespondentAttorneyMailed_INDC,
                OthersMailed_INDC,
                PetitionerMailed_DATE,
                RespondentMailed_DATE,
                PetitionerAttorneyMailed_DATE,
                RespondentAttorneyMailed_DATE,
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
                StatusControl_CODE,
                StateControl_CODE,
                OrderControl_ID,
                DirectPay_INDC,
                LastNoticeSent_DATE,
                NextReview_DATE,
                LastReview_DATE,
                ReviewRequested_DATE,
                SourceOrdered_CODE,
                TypeOrder_CODE,
                Judge_ID,
                Commissioner_ID)
   SELECT Case_IDNO,
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
          LastIrscReferred_DATE,
          LastIrscUpdated_DATE,
          LastIrscReferred_AMNT,
          UnreimMedical_INDC,
          CpMedical_PCT,
          NcpMedical_PCT,
          ParentingTime_PCT,
          NoParentingDays_QNTY,
          DescriptionParentingNotes_TEXT,
          PetitionerAppeared_INDC,
          RespondentAppeared_INDC,
          PetitionerAttorneyAppeared_INDC,
          RespondentAttorneyAppeared_INDC,
          OthersAppeared_INDC,
          PetitionerReceived_INDC,
          RespondentReceived_INDC,
          PetitionerAttorneyReceived_INDC,
          RespondentAttorneyReceived_INDC,
          OthersReceived_INDC,
          PetitionerMailed_INDC,
          RespondentMailed_INDC,
          PetitionerAttorneyMailed_INDC,
          RespondentAttorneyMailed_INDC,
          OthersMailed_INDC,
          PetitionerMailed_DATE,
          RespondentMailed_DATE,
          PetitionerAttorneyMailed_DATE,
          RespondentAttorneyMailed_DATE,
          OthersMailed_DATE,
          CoverageMedical_CODE,
          CoverageDrug_CODE,
          CoverageMental_CODE,
          CoverageDental_CODE,
          CoverageVision_CODE,
          CoverageOthers_CODE,
          DescriptionCoverageOthers_TEXT,
          @Ac_WorkerUpdate_ID WorkerUpdate_ID,
          @Ad_Run_DATE BeginValidity_DATE,
          @Ld_HighDate_DATE EndValidity_DATE,
          @Ln_EventGlobalBeginSeq_NUMB EventGlobalBeginSeq_NUMB,
          0 EventGlobalEndSeq_NUMB,
          StatusControl_CODE,
          StateControl_CODE,
          OrderControl_ID,
          DirectPay_INDC,
          LastNoticeSent_DATE,
          DATEADD(MONTH, 30, @Ld_NextReview_DATE) NextReview_DATE,
          @Ld_NextReview_DATE LastReview_DATE,
          ReviewRequested_DATE,
          SourceOrdered_CODE,
          TypeOrder_CODE,
          Judge_ID,
          Commissioner_ID
     FROM SORD_Y1 A
    WHERE A.Case_IDNO = @An_Case_IDNO
      AND A.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND A.EventGlobalEndSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB;
   -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     RAISERROR (50001,16,1);
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
