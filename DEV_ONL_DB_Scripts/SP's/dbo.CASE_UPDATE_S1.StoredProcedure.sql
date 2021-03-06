/****** Object:  StoredProcedure [dbo].[CASE_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_UPDATE_S1]
(
	@An_Case_IDNO                NUMERIC(6),
	@Ac_StatusEnforce_CODE       CHAR(4),
	@An_TransactionEventSeq_NUMB NUMERIC(19, 0),
	@Ac_SignedOnWorker_ID        CHAR(30)
)
AS
/*  
 *     PROCEDURE NAME    : CASE_UPDATE_S1  
 *     DESCRIPTION       : Update the Enforcement status code, Worker Id, Transaction sequence, Begin Validity Date for a Case Idno.
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 10-FEB-2015  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/
BEGIN
	DECLARE
		@Ln_RowsAffected_NUMB   INT,
		@Ld_Current_DTTM		DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	UPDATE CASE_Y1
		SET 
			StatusEnforce_CODE = @Ac_StatusEnforce_CODE,
			BeginValidity_DATE = @Ld_Current_DTTM,
			WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
			TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
			Update_DTTM = @Ld_Current_DTTM
		OUTPUT 
			DELETED.Case_IDNO,
			DELETED.StatusCase_CODE,
			DELETED.TypeCase_CODE,
			DELETED.RsnStatusCase_CODE,
			DELETED.RespondInit_CODE,
			DELETED.SourceRfrl_CODE,
			DELETED.Opened_DATE,
			DELETED.Marriage_DATE,
			DELETED.Divorced_DATE,
			DELETED.StatusCurrent_DATE,
			DELETED.AprvIvd_DATE,
			DELETED.County_IDNO,
			DELETED.Office_IDNO,
			DELETED.AssignedFips_CODE,
			DELETED.GoodCause_CODE,
			DELETED.GoodCause_DATE,
			DELETED.Restricted_INDC,
			DELETED.MedicalOnly_INDC,
			DELETED.Jurisdiction_INDC,
			DELETED.IvdApplicant_CODE,
			DELETED.Application_IDNO,
			DELETED.AppSent_DATE,
			DELETED.AppReq_DATE,
			DELETED.AppRetd_DATE,
			DELETED.CpRelationshipToNcp_CODE,
			DELETED.Worker_ID,
			DELETED.AppSigned_DATE,
			DELETED.ClientLitigantRole_CODE,
			DELETED.DescriptionComments_TEXT,
			DELETED.NonCoop_CODE,
			DELETED.NonCoop_DATE,
			DELETED.BeginValidity_DATE,
			@Ld_Current_DTTM AS EndValidity_DATE,
			DELETED.WorkerUpdate_ID,
			DELETED.TransactionEventSeq_NUMB,
			DELETED.Update_DTTM,
			DELETED.Referral_DATE,
			DELETED.CaseCategory_CODE,
			DELETED.File_ID,
			DELETED.ApplicationFee_CODE,
			DELETED.FeePaid_DATE,
			DELETED.ServiceRequested_CODE,
			DELETED.StatusEnforce_CODE,
			DELETED.FeeCheckNo_TEXT,
			DELETED.ReasonFeeWaived_CODE,
			DELETED.Intercept_CODE
		INTO HCASE_Y1
		WHERE Case_IDNO = @An_Case_IDNO;

	SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

	SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of CASE_UPDATE_S1

GO
