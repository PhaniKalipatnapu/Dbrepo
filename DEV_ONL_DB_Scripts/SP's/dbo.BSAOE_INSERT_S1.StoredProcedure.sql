/****** Object:  StoredProcedure [dbo].[BSAOE_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAOE_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_Open_DATE					DATE,
	@Ad_Order_DATE					DATE,
	@Ad_Service_DATE				DATE,
	@Ad_Review_DATE					DATE,
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_SignedOnWorker_ID			CHAR(30),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@As_DescriptionComments_TEXT	VARCHAR(1000),
	@Ac_QuestionOE1_INDC			CHAR(1),
	@Ac_QuestionOE2_INDC			CHAR(1),
	@Ac_QuestionOE3_INDC			CHAR(1),
	@Ac_QuestionOE4_INDC			CHAR(1),
	@Ad_StatusLocate_DATE			DATE,
	@Ac_UnsuccessfulService_CODE	CHAR(1),
	@Ad_UnsuccessfulService_DATE	DATE
)
AS
/*
 *     PROCEDURE NAME    : BSAOE_INSERT_S1
 *     DESCRIPTION       : Inserts the establishment component details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

    DECLARE @Lc_Space_TEXT				CHAR(1) = ' ',
			@Li_Zero_NUMB				SMALLINT = 0,
			@Ld_High_DATE				DATE = '12/31/9999',
		    @Ld_Current_DATE			DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

	 INSERT BSAOE_Y1
		    (Case_IDNO,
			Open_DATE,
			Order_DATE,
			Service_DATE,
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
			DescriptionComments_TEXT,
			QuestionOE1_INDC,
			QuestionOE2_INDC,
			QuestionOE3_INDC,
			QuestionOE4_INDC,
			StatusLocate_DATE,
			UnsuccessfulService_CODE,
			UnsuccessfulService_DATE
			)
	 VALUES (@An_Case_IDNO,					--Case_IDNO
			@Ad_Open_DATE,					--Open_DATE
			@Ad_Order_DATE,					--Order_DATE
			@Ad_Service_DATE,				--Service_DATE
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
			@As_DescriptionComments_TEXT,	--DescriptionComments_TEXT
			@Ac_QuestionOE1_INDC,			--QuestionOE1_INDC
			@Ac_QuestionOE2_INDC,			--QuestionOE2_INDC
			@Ac_QuestionOE3_INDC,			--QuestionOE3_INDC
			@Ac_QuestionOE4_INDC,			--QuestionOE4_INDC
			@Ad_StatusLocate_DATE,			--StatusLocate_DATE
			@Ac_UnsuccessfulService_CODE,	--UnsuccessfulService_CODE
			@Ad_UnsuccessfulService_DATE	--UnsuccessfulService_DATE
			);
			
END	-- END OF BSAOE_INSERT_S1


GO
