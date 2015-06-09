/****** Object:  StoredProcedure [dbo].[BSARO_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSARO_RETRIEVE_S1]
(
	 @Ad_Review_DATE		DATE,
     @Ai_RowFrom_NUMB       INT = 1,  
     @Ai_RowTo_NUMB         INT = 10
)
AS
/*
 *     PROCEDURE NAME    : BSARO_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the review and adjustment of order details.
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
			y.CourtOrder_DATE,
			y.Effective_DATE,
			y.RecentNotice_DATE,
			y.County_IDNO,
			y.MemberMci_IDNO,
			y.Last_NAME,
			y.Case_IDNO,
			y.DescriptionComments_TEXT,
			y.QuestionR1_INDC,
			y.QuestionR2_INDC,
			y.QuestionR3_INDC,
			y.QuestionR4_INDC,
			y.WorkerUpdate_ID,
			y.RowCount_NUMB,
			y.ORD_ROWNUM
	   FROM (SELECT x.Compliance_INDC, 
					x.Review_DATE,
					x.WorkerReview_ID,
					x.County_NAME,
					x.CourtOrder_DATE,
					x.Effective_DATE,
					x.RecentNotice_DATE,
					x.County_IDNO,
					x.MemberMci_IDNO,
					x.Last_NAME,
					x.Case_IDNO,
					x.DescriptionComments_TEXT,
					x.QuestionR1_INDC,
					x.QuestionR2_INDC,
					x.QuestionR3_INDC,
					x.QuestionR4_INDC,
					x.WorkerUpdate_ID,
					x.RowCount_NUMB,
					x.ORD_ROWNUM
			   FROM (SELECT a.Compliance_INDC, 
							a.Review_DATE,
							a.WorkerReview_ID,
							b.County_NAME,
							a.CourtOrder_DATE,
							a.Effective_DATE,
							a.RecentNotice_DATE,
							b.County_IDNO,
							b.MemberMci_IDNO,
							b.Last_NAME,
							a.Case_IDNO,
							a.DescriptionComments_TEXT,
							a.QuestionR1_INDC,
							a.QuestionR2_INDC,
							a.QuestionR3_INDC,
							a.QuestionR4_INDC,
							a.WorkerUpdate_ID,
							COUNT(a.Case_IDNO) OVER() RowCount_NUMB,
							ROW_NUMBER() OVER(ORDER BY a.Case_IDNO) AS ORD_ROWNUM
					   FROM BSARO_Y1 a JOIN BSACS_Y1 b
						 ON a.Case_IDNO			= b.Case_IDNO
						AND a.Review_DATE		= b.Review_DATE
					  WHERE a.Review_DATE		= @Ad_Review_DATE
					    AND b.ReviewAdjustment_INDC = @Lc_Yes_INDC
						AND a.EndValidity_DATE	= @Ld_High_DATE) X  
			   WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
					 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)) Y  
		 WHERE (Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB) 
				 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB) 
	ORDER BY ORD_ROWNUM;
	    
END -- END OF BSARO_RETRIEVE_S1


GO
