/****** Object:  StoredProcedure [dbo].[BSADC_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSADC_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,
	@Ad_Receipt_DATE				DATE,
	@Ac_Source_CODE					CHAR(2),
	@Ad_Disbursement_DATE			DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@Ac_QuestionD1_INDC				CHAR(1),
	@As_DescriptionComments_TEXT	VARCHAR(1000)
)
AS
/*
 *     PROCEDURE NAME    : BSADC_INSERT_S1
 *     DESCRIPTION       : Inserts the disbursement collection component details.
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

	 INSERT BSADC_Y1
		    (Case_IDNO,
			Review_DATE,
			WorkerReview_ID,
			CaseWelfare_IDNO,
			Receipt_DATE,
			Source_CODE,
			Disbursement_DATE,
			Compliance_INDC,
			ComplianceOverride_INDC,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			QuestionD1_INDC,
			DescriptionComments_TEXT
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
			@Ad_Review_DATE,				--Review_DATE
			@Lc_Space_TEXT,					--WorkerReview_ID
			@Li_Zero_NUMB,					--CaseWelfare_IDNO
			@Ad_Receipt_DATE,				--Receipt_DATE
			@Ac_Source_CODE,				--Source_CODE
			@Ad_Disbursement_DATE,			--Disbursement_DATE
			@Ac_Compliance_INDC,			--Compliance_INDC
			@Ac_ComplianceOverride_INDC,	--ComplianceOverride_INDC
			@Ac_SignedOnWorker_ID,			--WorkerUpdate_ID
			@Ld_Current_DATE,				--BeginValidity_DATE
			@Ld_High_DATE,					--EndValidity_DATE
			@Ld_Current_DATE,				--Update_DTTM
			@An_TransactionEventSeq_NUMB,	--TransactionEventSeq_NUMB
			@Ac_QuestionD1_INDC,			--QuestionD1_INDC
			@As_DescriptionComments_TEXT	--DescriptionComments_TEXT
			);
				
END -- END OF BSADC_INSERT_S1


GO
