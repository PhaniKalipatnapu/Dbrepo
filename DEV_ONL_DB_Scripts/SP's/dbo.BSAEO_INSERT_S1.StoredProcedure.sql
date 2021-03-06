/****** Object:  StoredProcedure [dbo].[BSAEO_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAEO_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@As_DescriptionComments_TEXT	VARCHAR(1000),
	@Ac_QuestionE1_INDC				CHAR(1),
	@Ac_QuestionE2_INDC				CHAR(1),
	@Ac_QuestionE3_INDC				CHAR(1),
	@Ac_QuestionE4_INDC				CHAR(1),
	@Ac_QuestionE5_INDC				CHAR(1),
	@Ac_QuestionE6_INDC				CHAR(1),
	@Ac_QuestionE7_INDC				CHAR(1),
	@Ac_Iiwo_CODE					CHAR(2),
	@Ad_IWOrderIssued_DATE			DATE,
	@Ad_SOIStatus_DATE				DATE,
	@Ad_EmployerWageReceipt_DATE	DATE,
	@Ad_NonWageReceipt_DATE			DATE
)
AS
/*
 *     PROCEDURE NAME    : BSAEO_INSERT_S1
 *     DESCRIPTION       : Inserts the Enforcement Support Order component details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

	DECLARE @Lc_Space_TEXT				CHAR(1) = ' ',
			@Li_Zero_NUMB				SMALLINT = 0,
			@Ld_High_DATE				DATE = '12/31/9999',
			@Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
			
	 INSERT BSAEO_Y1
			(Case_IDNO,
			Review_DATE,
			WorkerReview_ID,
			CaseWelfare_IDNO,
			Compliance_INDC,
			ComplianceOverride_INDC,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			DescriptionComments_TEXT,
			QuestionE1_INDC,
			QuestionE2_INDC,
			QuestionE3_INDC,
			QuestionE4_INDC,
			QuestionE5_INDC,
			QuestionE6_INDC,
			QuestionE7_INDC,
			Iiwo_CODE,
			IWOrderIssued_DATE,
			SOIStatus_DATE,
			EmployerWageReceipt_DATE,
			NonWageReceipt_DATE
			)
	 VALUES(@An_Case_IDNO,					--Case_IDNO
			@Ad_Review_DATE,				--Review_DATE
			@Lc_Space_TEXT,					--WorkerReview_ID
			@Li_Zero_NUMB,					--CaseWelfare_IDNO
			@Ac_Compliance_INDC,			--Compliance_INDC
			@Ac_ComplianceOverride_INDC,	--ComplianceOverride_INDC
			@Ac_SignedOnWorker_ID,			--WorkerUpdate_ID
			@Ld_Current_DATE,				--BeginValidity_DATE
			@Ld_High_DATE,					--EndValidity_DATE
			@Ld_Current_DATE,				--Update_DTTM
			@An_TransactionEventSeq_NUMB,	--TransactionEventSeq_NUMB
			@As_DescriptionComments_TEXT,	--DescriptionComments_TEXT
			@Ac_QuestionE1_INDC,			--QuestionE1_INDC
			@Ac_QuestionE2_INDC,			--QuestionE2_INDC
			@Ac_QuestionE3_INDC,			--QuestionE3_INDC
			@Ac_QuestionE4_INDC,			--QuestionE4_INDC
			@Ac_QuestionE5_INDC,			--QuestionE5_INDC
			@Ac_QuestionE6_INDC,			--QuestionE6_INDC
			@Ac_QuestionE7_INDC,			--QuestionE7_INDC
			@Ac_Iiwo_CODE,					--Iiwo_CODE
			@Ad_IWOrderIssued_DATE,			--IWOrderIssued_DATE
			@Ad_SOIStatus_DATE,				--SOIStatus_DATE
			@Ad_EmployerWageReceipt_DATE,	--EmployerWageReceipt_DATE
			@Ad_NonWageReceipt_DATE			--NonWageReceipt_DATE
			);
				
END -- END OF BSAEO_INSERT_S1


GO
