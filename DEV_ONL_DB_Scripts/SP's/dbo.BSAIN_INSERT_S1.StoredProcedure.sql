/****** Object:  StoredProcedure [dbo].[BSAIN_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAIN_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@Ac_RespondInit_CODE			CHAR(1),
	@As_DescriptionComments_TEXT	VARCHAR(1000),
	@Ac_QuestionIN1_INDC			CHAR(1),
	@Ac_QuestionIN2_INDC			CHAR(1),
	@Ac_QuestionIN3_INDC			CHAR(1),
	@Ac_QuestionIN4_INDC			CHAR(1),
	@Ac_QuestionIN5_INDC			CHAR(1)
)
AS
/*
 *     PROCEDURE NAME    : BSAIN_INSERT_S1
 *     DESCRIPTION       : Inserts the Intergovernmental services component details.
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

	 INSERT BSAIN_Y1
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
			RespondInit_CODE,
			DescriptionComments_TEXT,
			QuestionIN1_INDC,
			QuestionIN2_INDC,
			QuestionIN3_INDC,
			QuestionIN4_INDC,
			QuestionIN5_INDC
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
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
			@Ac_RespondInit_CODE,			--RespondInit_CODE
			@As_DescriptionComments_TEXT,	--DescriptionComments_TEXT
			@Ac_QuestionIN1_INDC,			--QuestionIN1_INDC
			@Ac_QuestionIN2_INDC,			--QuestionIN2_INDC
			@Ac_QuestionIN3_INDC,			--QuestionIN3_INDC
			@Ac_QuestionIN4_INDC,			--QuestionIN4_INDC
			@Ac_QuestionIN5_INDC			--QuestionIN5_INDC
			);
				
END -- END OF BSAIN_INSERT_S1


GO
