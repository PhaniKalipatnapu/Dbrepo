/****** Object:  StoredProcedure [dbo].[BSAEO_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAEO_UPDATE_S1] 
(
	@An_Case_IDNO					NUMERIC(6,0),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_QuestionE1_INDC				CHAR(1),
	@Ac_QuestionE2_INDC				CHAR(1),
	@Ac_QuestionE3_INDC				CHAR(1),
	@Ac_QuestionE4_INDC				CHAR(1),
	@Ac_QuestionE5_INDC				CHAR(1),
	@Ac_QuestionE6_INDC				CHAR(1),
	@Ac_QuestionE7_INDC				CHAR(1),
	@Ac_WorkerReview_ID				CHAR(30),
	@As_DescriptionComments_TEXT	VARCHAR(1000)
)
AS
/*
 *     PROCEDURE NAME    : BSAEO_UPDATE_S1
 *     DESCRIPTION       : This procedure is used to updates the Enforcement of support order.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 20-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

	 UPDATE BSAEO_Y1
		SET Compliance_INDC				= @Ac_Compliance_INDC,
			ComplianceOverride_INDC		= @Ac_ComplianceOverride_INDC,
			DescriptionComments_TEXT	= @As_DescriptionComments_TEXT,
			WorkerReview_ID				= @Ac_WorkerReview_ID,
			QuestionE1_INDC				= @Ac_QuestionE1_INDC,
			QuestionE2_INDC				= @Ac_QuestionE2_INDC,
			QuestionE3_INDC				= @Ac_QuestionE3_INDC,
			QuestionE4_INDC				= @Ac_QuestionE4_INDC,
			QuestionE5_INDC				= @Ac_QuestionE5_INDC,
			QuestionE6_INDC				= @Ac_QuestionE6_INDC,
			QuestionE7_INDC				= @Ac_QuestionE7_INDC
	  WHERE Case_IDNO					= @An_Case_IDNO 
	    AND TransactionEventSeq_NUMB	= @An_TransactionEventSeq_NUMB;
	
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10) ;
	      		  
	    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
	      
	 SELECT @Ln_RowsAffected_NUMB;  

END  -- END OF BSAEO_UPDATE_S1
GO
