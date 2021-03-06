/****** Object:  StoredProcedure [dbo].[BSAEP_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAEP_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,	
	@Ad_Service_DATE				DATE,
	@Ad_Disposition_DATE			DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_Compliance_CODE				CHAR(2),	
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@As_DescriptionComments_TEXT	VARCHAR(1000),
	@Ac_QuestionEP1_INDC			CHAR(1),
	@Ac_QuestionEP2_INDC			CHAR(1),
	@Ad_CaseCreation_DATE			DATE,
	@Ac_ComplianceOverride_INDC		CHAR(1)
)
AS
/*
 *     PROCEDURE NAME    : BSAEP_INSERT_S1
 *     DESCRIPTION       : Inserts the expedited process component details.
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

	 INSERT BSAEP_Y1
		    (Case_IDNO,
			Review_DATE,
			WorkerReview_ID,
			CaseWelfare_IDNO,
			Service_DATE,
			Disposition_DATE,
			Compliance_INDC,
			Compliance_CODE,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			DescriptionComments_TEXT,
			QuestionEP1_INDC,
			QuestionEP2_INDC,
			CaseCreation_DATE,
			ComplianceOverride_INDC
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
			@Ad_Review_DATE,				--Review_DATE
			@Lc_Space_TEXT,					--WorkerReview_ID
			@Li_Zero_NUMB,					--CaseWelfare_IDNO
			@Ad_Service_DATE,				--Service_DATE
			@Ad_Disposition_DATE,			--Disposition_DATE
			@Ac_Compliance_INDC,			--Compliance_INDC
			@Ac_Compliance_CODE,			--Compliance_CODE
			@Ac_SignedOnWorker_ID,			--WorkerUpdate_ID
			@Ld_Current_DATE,				--BeginValidity_DATE
			@Ld_High_DATE,					--EndValidity_DATE
			@Ld_Current_DATE,				--Update_DTTM
			@An_TransactionEventSeq_NUMB,	--TransactionEventSeq_NUMB
			@As_DescriptionComments_TEXT,	--DescriptionComments_TEXT
			@Ac_QuestionEP1_INDC,			--QuestionEP1_INDC
			@Ac_QuestionEP2_INDC,			--QuestionEP2_INDC
			@Ad_CaseCreation_DATE,			--CaseCreation_DATE
			@Ac_ComplianceOverride_INDC		--ComplianceOverride_INDC
			);
				
END -- END OF BSAEP_INSERT_S1 


GO
