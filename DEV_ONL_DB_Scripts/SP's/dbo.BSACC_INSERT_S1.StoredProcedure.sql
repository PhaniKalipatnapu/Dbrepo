/****** Object:  StoredProcedure [dbo].[BSACC_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSACC_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),			
	@Ac_RsnClosure_CODE				CHAR(2),
	@Ad_StatusCurrent_DATE			DATE,
	@Ad_Notice_DATE					DATE,
	@Ad_Review_DATE					DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@Ac_QuestionC1_INDC				CHAR(1),
	@Ac_QuestionC2_INDC				CHAR(1),
	@As_DescriptionComments_TEXT	VARCHAR(1000)
)
AS
/*
 *     PROCEDURE NAME    : BSACC_INSERT_S1
 *     DESCRIPTION       : Inserts the Case Closure component details.
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
			
	 INSERT BSACC_Y1
			(Case_IDNO,
			RsnClosure_CODE,
			Close_DATE,
			Notice_DATE,
			Review_DATE,
			CaseWelfare_IDNO,
			WorkerReview_ID,
			Compliance_INDC,
			ComplianceOverride_INDC,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			QuestionC1_INDC,
			QuestionC2_INDC,
			DescriptionComments_TEXT	
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
			@Ac_RsnClosure_CODE,			--RsnClosure_CODE
			@Ad_StatusCurrent_DATE,			--Close_DATE
			@Ad_Notice_DATE,				--Notice_DATE
			@Ad_Review_DATE,				--Review_DATE
			@Li_Zero_NUMB,					--CaseWelfare_IDNO
			@Lc_Space_TEXT,					--WorkerReview_ID
			@Ac_Compliance_INDC,			--Compliance_INDC
			@Ac_ComplianceOverride_INDC,	--ComplianceOverride_INDC
			@Ac_SignedOnWorker_ID,			--WorkerUpdate_ID
			@Ld_Current_DATE,				--BeginValidity_DATE
			@Ld_High_DATE,					--EndValidity_DATE
			@Ld_Current_DATE,				--Update_DTTM
			@An_TransactionEventSeq_NUMB,	--TransactionEventSeq_NUMB	
			@Ac_QuestionC1_INDC,			--QuestionC1_INDC
			@Ac_QuestionC2_INDC,			--QuestionC2_INDC
			@As_DescriptionComments_TEXT	--DescriptionComments_TEXT	
			);
				
END -- END OF BSACC_INSERT_S1


GO
