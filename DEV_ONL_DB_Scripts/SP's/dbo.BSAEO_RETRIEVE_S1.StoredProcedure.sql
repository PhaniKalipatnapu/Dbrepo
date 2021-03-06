/****** Object:  StoredProcedure [dbo].[BSAEO_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAEO_RETRIEVE_S1]
(
	 @Ad_Review_DATE		DATE,
     @Ai_RowFrom_NUMB       INT = 1,  
     @Ai_RowTo_NUMB         INT = 10
)
AS
/*
 *     PROCEDURE NAME    : BSAEO_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the enforcement of support order details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	DECLARE @Li_Zero_NUMB			SMALLINT = 0,
			@Lc_Yes_INDC			CHAR(1) = 'Y',
			@Ld_High_DATE			DATE = '12/31/9999';
	
	 SELECT y.Compliance_INDC,
			y.Review_DATE,
			y.WorkerReview_ID,
			y.County_NAME,
			y.County_IDNO,
			y.MemberMci_IDNO,
			y.Last_NAME,
			y.Case_IDNO,
			y.Iiwo_CODE,
			y.IWOrderIssued_DATE,
			y.SOIStatus_DATE,
			y.EmployerWageReceipt_DATE,
			y.NonWageReceipt_DATE,
			y.DescriptionComments_TEXT,
			y.QuestionE1_INDC,
			y.QuestionE2_INDC,
			y.QuestionE3_INDC,
			y.QuestionE4_INDC,
			y.QuestionE5_INDC,
			y.QuestionE6_INDC,
			y.QuestionE7_INDC,
			y.WorkerUpdate_ID,
			y.RowCount_NUMB,
			y.ORD_ROWNUM
	   FROM (SELECT x.Compliance_INDC,
					x.Review_DATE,
					x.WorkerReview_ID,
					x.County_NAME,
					x.County_IDNO,
					x.MemberMci_IDNO,
					x.Last_NAME,
					x.Case_IDNO,
					x.Iiwo_CODE,
					x.IWOrderIssued_DATE,
					x.SOIStatus_DATE,
					x.EmployerWageReceipt_DATE,
					x.NonWageReceipt_DATE,
					x.DescriptionComments_TEXT,
					x.QuestionE1_INDC,
					x.QuestionE2_INDC,
					x.QuestionE3_INDC,
					x.QuestionE4_INDC,
					x.QuestionE5_INDC,
					x.QuestionE6_INDC,
					x.QuestionE7_INDC,
					x.WorkerUpdate_ID,
					x.RowCount_NUMB,
					x.ORD_ROWNUM
			   FROM (SELECT a.Compliance_INDC,
							a.Review_DATE,
							a.WorkerReview_ID,
							b.County_NAME,
							b.County_IDNO,
							b.MemberMci_IDNO,
							b.Last_NAME,
							a.Case_IDNO,
							a.Iiwo_CODE,
							a.IWOrderIssued_DATE,
							a.SOIStatus_DATE,
							a.EmployerWageReceipt_DATE,
							a.NonWageReceipt_DATE,
							a.DescriptionComments_TEXT,
							a.QuestionE1_INDC,
							a.QuestionE2_INDC,
							a.QuestionE3_INDC,
							a.QuestionE4_INDC,
							a.QuestionE5_INDC,
							a.QuestionE6_INDC,
							a.QuestionE7_INDC,
							a.WorkerUpdate_ID,
							COUNT(a.Case_IDNO) OVER() RowCount_NUMB,
							ROW_NUMBER() OVER(ORDER BY a.Case_IDNO) AS ORD_ROWNUM
					   FROM BSAEO_Y1 a JOIN BSACS_Y1 b
						 ON a.Case_IDNO			= b.Case_IDNO
						AND a.Review_DATE		= b.Review_DATE
					  WHERE a.Review_DATE		= @Ad_Review_DATE
					    AND b.Enfsuporder_INDC  = @Lc_Yes_INDC
						AND a.EndValidity_DATE	= @Ld_High_DATE) X  
				      WHERE( X.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
							 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)) Y  
		      WHERE (Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB) 
					 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)  
	ORDER BY ORD_ROWNUM;
	    
END -- END OF BSAEO_RETRIEVE_S1


GO
