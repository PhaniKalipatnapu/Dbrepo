/****** Object:  StoredProcedure [dbo].[SORD_UPDATE_S57]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SORD_UPDATE_S57]
(
	 @An_Case_IDNO					NUMERIC(6),
     @Ac_File_ID					CHAR(10),
     @Ac_SignedOnWorker_ID			CHAR(30),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19),
     @Ac_FileOld_ID					CHAR(10)
)
AS

/*
 *     PROCEDURE NAME    : SORD_UPDATE_S57
 *     DESCRIPTION       : Updating New File_ID in Support Order table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-DEC-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
   BEGIN
		-- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
		DECLARE
			 @Li_Zero_NUMB					SMALLINT	= 0,
			 @Ld_High_DATE 					DATE		= '12/31/9999';
		DECLARE
			 @Ln_RowsAffected_NUMB  		NUMERIC(10),
			 @Ld_Current_DATE				DATE		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      UPDATE SORD_Y1
         SET File_ID = @Ac_File_ID,
         	 WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         	 BeginValidity_DATE = @Ld_Current_DATE,
         	 EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB,
         	 EventGlobalEndSeq_NUMB = @Li_Zero_NUMB
      OUTPUT Deleted.Case_IDNO,
			 Deleted.OrderSeq_NUMB,
			 Deleted.Order_IDNO,
			 Deleted.File_ID,
			 Deleted.OrderEnt_DATE,
			 Deleted.OrderIssued_DATE,
			 Deleted.OrderEffective_DATE,
			 Deleted.OrderEnd_DATE,
			 Deleted.ReasonStatus_CODE,
			 Deleted.StatusOrder_CODE,
			 Deleted.StatusOrder_DATE,
			 Deleted.InsOrdered_CODE,
			 Deleted.MedicalOnly_INDC,
			 Deleted.Iiwo_CODE,
			 Deleted.NoIwReason_CODE,
			 Deleted.IwoInitiatedBy_CODE,
			 Deleted.GuidelinesFollowed_INDC,
			 Deleted.DeviationReason_CODE,
			 Deleted.DescriptionDeviationOthers_TEXT,
			 Deleted.OrderOutOfState_ID,
			 Deleted.CejStatus_CODE,
			 Deleted.CejFips_CODE,
			 Deleted.IssuingOrderFips_CODE,
			 Deleted.Qdro_INDC,
			 Deleted.UnreimMedical_INDC,
			 Deleted.CpMedical_PCT,
			 Deleted.NcpMedical_PCT,
			 Deleted.ParentingTime_PCT,
			 Deleted.NoParentingDays_QNTY,
			 Deleted.PetitionerAppeared_INDC,
			 Deleted.RespondentAppeared_INDC,
			 Deleted.OthersAppeared_INDC,
			 Deleted.PetitionerReceived_INDC,
			 Deleted.RespondentReceived_INDC,
			 Deleted.OthersReceived_INDC,
			 Deleted.PetitionerMailed_INDC,
			 Deleted.RespondentMailed_INDC,
			 Deleted.OthersMailed_INDC,
			 Deleted.PetitionerMailed_DATE,
			 Deleted.RespondentMailed_DATE,
			 Deleted.OthersMailed_DATE,
			 Deleted.CoverageMedical_CODE,
			 Deleted.CoverageDrug_CODE,
			 Deleted.CoverageMental_CODE,
			 Deleted.CoverageDental_CODE,
			 Deleted.CoverageVision_CODE,
			 Deleted.CoverageOthers_CODE,
			 Deleted.DescriptionCoverageOthers_TEXT,
			 Deleted.WorkerUpdate_ID,
			 Deleted.BeginValidity_DATE,
			 @Ld_Current_DATE AS EndValidity_DATE,
			 Deleted.EventGlobalBeginSeq_NUMB,
			 @An_EventGlobalBeginSeq_NUMB AS EventGlobalEndSeq_NUMB,
			 Deleted.DescriptionParentingNotes_TEXT,
			 Deleted.LastIrscReferred_DATE,
			 Deleted.LastIrscUpdated_DATE,
			 Deleted.LastIrscReferred_AMNT,
			 Deleted.StatusControl_CODE,
			 Deleted.StateControl_CODE,
			 Deleted.OrderControl_ID,
			 Deleted.PetitionerAttorneyAppeared_INDC,
			 Deleted.RespondentAttorneyAppeared_INDC,
			 Deleted.PetitionerAttorneyReceived_INDC,
			 Deleted.RespondentAttorneyReceived_INDC,
			 Deleted.PetitionerAttorneyMailed_INDC,
			 Deleted.RespondentAttorneyMailed_INDC,
			 Deleted.PetitionerAttorneyMailed_DATE,
			 Deleted.RespondentAttorneyMailed_DATE,
			 Deleted.TypeOrder_CODE,
			 Deleted.ReviewRequested_DATE,
			 Deleted.NextReview_DATE,
			 Deleted.LastReview_DATE,
			 Deleted.LastNoticeSent_DATE,
			 Deleted.DirectPay_INDC,
			 Deleted.SourceOrdered_CODE,
			 Deleted.Judge_ID,
			 Deleted.Commissioner_ID
	  INTO SORD_Y1 ( 
						Case_IDNO,
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
						SourceOrdered_CODE,
						Judge_ID,
						Commissioner_ID
    				)
      WHERE Case_IDNO = @An_Case_IDNO
      	AND File_ID = @Ac_FileOld_ID
      	AND EndValidity_DATE = @Ld_High_DATE;
	  -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END

          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
       SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;

END; --END OF SORD_UPDATE_S57


GO
