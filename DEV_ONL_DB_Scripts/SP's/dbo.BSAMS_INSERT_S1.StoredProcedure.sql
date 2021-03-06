/****** Object:  StoredProcedure [dbo].[BSAMS_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAMS_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Review_DATE					DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ad_Order_DATE					DATE,
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@As_DescriptionComments_TEXT	VARCHAR(1000),
	@Ac_QuestionMS1_INDC			CHAR(1),
	@Ac_QuestionMS2_INDC			CHAR(1),
	@Ac_InsOrdered_CODE				CHAR(1),
	@Ac_DpCoverageAvlb_INDC			CHAR(1),
	@Ad_NMSNIssued_DATE				DATE
)
AS
/*
 *     PROCEDURE NAME    : BSAMS_INSERT_S1
 *     DESCRIPTION       : Inserts the medical support component details.
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
			
	 INSERT BSAMS_Y1
			(Case_IDNO,
			Review_DATE,
			WorkerReview_ID,
			CaseWelfare_IDNO,
			Compliance_INDC,
			Order_DATE,
			ComplianceOverride_INDC,
			WorkerUpdate_ID,
			BeginValidity_DATE,
			EndValidity_DATE,
			Update_DTTM,
			TransactionEventSeq_NUMB,
			DescriptionComments_TEXT,
			QuestionMS1_INDC,
			QuestionMS2_INDC,
			InsOrdered_CODE,
			DpCoverageAvlb_INDC,
			NMSNIssued_DATE
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
			@Ad_Review_DATE,				--Review_DATE
			@Lc_Space_TEXT,					--WorkerReview_ID
			@Li_Zero_NUMB,					--CaseWelfare_IDNO
			@Ac_Compliance_INDC,			--Compliance_INDC
			@Ad_Order_DATE,					--Order_DATE
			@Ac_ComplianceOverride_INDC,	--ComplianceOverride_INDC
			@Ac_SignedOnWorker_ID,			--WorkerUpdate_ID
			@Ld_Current_DATE,				--BeginValidity_DATE
			@Ld_High_DATE,					--EndValidity_DATE
			@Ld_Current_DATE,				--Update_DTTM
			@An_TransactionEventSeq_NUMB,	--TransactionEventSeq_NUMB
			@As_DescriptionComments_TEXT,	--DescriptionComments_TEXT
			@Ac_QuestionMS1_INDC,			--QuestionMS1_INDC
			@Ac_QuestionMS2_INDC,			--QuestionMS2_INDC
			@Ac_InsOrdered_CODE,			--InsOrdered_CODE
			@Ac_DpCoverageAvlb_INDC,		--DpCoverageAvlb_INDC
			@Ad_NMSNIssued_DATE				--NMSNIssued_DATE
			);
				
END -- END OF BSAMS_INSERT_S1


GO
