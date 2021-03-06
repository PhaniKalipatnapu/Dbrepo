/****** Object:  StoredProcedure [dbo].[BSARO_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSARO_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,
	@Ad_CourtOrder_DATE				DATE,
	@Ad_Effective_DATE				DATE,
	@Ad_RecentNotice_DATE			DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@As_DescriptionComments_TEXT	VARCHAR(1000),
	@Ac_QuestionR1_INDC				CHAR(1),
	@Ac_QuestionR2_INDC				CHAR(1),
	@Ac_QuestionR3_INDC				CHAR(1),
	@Ac_QuestionR4_INDC				CHAR(1)
)
AS
/*
 *     PROCEDURE NAME    : BSARO_INSERT_S1
 *     DESCRIPTION       : Inserts the review and adjustment of order component details.
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

	 INSERT BSARO_Y1
		    (Case_IDNO,
			Review_DATE,
			WorkerReview_ID,
			CaseWelfare_IDNO,
			CourtOrder_DATE,
			Effective_DATE,
			RecentNotice_DATE,
			Compliance_INDC,
			ComplianceOverride_INDC,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			DescriptionComments_TEXT,
			QuestionR1_INDC,
			QuestionR2_INDC,
			QuestionR3_INDC,
			QuestionR4_INDC
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
			@Ad_Review_DATE,				--Review_DATE
			@Lc_Space_TEXT,					--WorkerReview_ID
			@Li_Zero_NUMB,					--CaseWelfare_IDNO
			@Ad_CourtOrder_DATE,			--CourtOrder_DATE
			@Ad_Effective_DATE,				--Effective_DATE
			@Ad_RecentNotice_DATE,			--RecentNotice_DATE
			@Ac_Compliance_INDC,			--Compliance_INDC
			@Ac_ComplianceOverride_INDC,	--ComplianceOverride_INDC
			@Ac_SignedOnWorker_ID,			--WorkerUpdate_ID
			@Ld_Current_DATE,				--BeginValidity_DATE
			@Ld_High_DATE,					--EndValidity_DATE
			@Ld_Current_DATE,				--Update_DTTM
			@An_TransactionEventSeq_NUMB,	--TransactionEventSeq_NUMB
			@As_DescriptionComments_TEXT,	--DescriptionComments_TEXT
			@Ac_QuestionR1_INDC,			--QuestionR1_INDC
			@Ac_QuestionR2_INDC,			--QuestionR2_INDC
			@Ac_QuestionR3_INDC,			--QuestionR3_INDC
			@Ac_QuestionR4_INDC				--QuestionR4_INDC
			);
				
END -- END OF BSARO_INSERT_S1


GO
