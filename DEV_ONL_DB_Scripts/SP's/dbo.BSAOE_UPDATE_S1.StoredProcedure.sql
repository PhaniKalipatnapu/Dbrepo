/****** Object:  StoredProcedure [dbo].[BSAOE_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAOE_UPDATE_S1] 
(
	@An_Case_IDNO					NUMERIC(6,0),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0),
	@Ac_Compliance_INDC				CHAR(1),
	@Ac_ComplianceOverride_INDC		CHAR(1),
	@Ac_QuestionOE1_INDC			CHAR(1),
	@Ac_QuestionOE2_INDC			CHAR(1),
	@Ac_QuestionOE3_INDC			CHAR(1),
    @Ac_QuestionOE4_INDC			CHAR(1),
	@Ac_WorkerReview_ID				CHAR(30),
	@As_DescriptionComments_TEXT	VARCHAR(1000)
)
AS
/*
 *     PROCEDURE NAME    : BSAOE_UPDATE_S1
 *     DESCRIPTION       : This procedure is used to updates the establishment of paternity and support order.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 20-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

	 UPDATE BSAOE_Y1
		SET Compliance_INDC				= @Ac_Compliance_INDC,
			ComplianceOverride_INDC		= @Ac_ComplianceOverride_INDC,
			DescriptionComments_TEXT	= @As_DescriptionComments_TEXT,
			WorkerReview_ID				= @Ac_WorkerReview_ID,
			QuestionOE1_INDC			= @Ac_QuestionOE1_INDC,
			QuestionOE2_INDC			= @Ac_QuestionOE2_INDC,
			QuestionOE3_INDC			= @Ac_QuestionOE3_INDC,
			QuestionOE4_INDC			= @Ac_QuestionOE4_INDC
	  WHERE Case_IDNO					= @An_Case_IDNO 
	    AND TransactionEventSeq_NUMB	= @An_TransactionEventSeq_NUMB;
	
	DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
	      		  
	    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
	      
	 SELECT @Ln_RowsAffected_NUMB;  

END  -- END OF BSAOE_UPDATE_S1
GO
