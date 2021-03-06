/****** Object:  StoredProcedure [dbo].[BSAOE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAOE_RETRIEVE_S1]
(
	 @Ad_Review_DATE		DATE,
     @Ai_RowFrom_NUMB       INT = 1,  
     @Ai_RowTo_NUMB         INT = 10
)
AS
/*
 *     PROCEDURE NAME    : BSAOE_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the establishment of paternity and child support order details.
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
			y.Open_DATE,
			y.Order_DATE,
			y.Service_DATE,
			y.County_IDNO,
			y.MemberMci_IDNO,
			y.Last_NAME,
			y.Case_IDNO,
			y.StatusLocate_DATE,
			y.UnsuccessfulService_CODE,
			y.UnsuccessfulService_DATE,
			y.DescriptionComments_TEXT,
			y.QuestionOE1_INDC,
			y.QuestionOE2_INDC,
			y.QuestionOE3_INDC,
			y.QuestionOE4_INDC,
			y.WorkerUpdate_ID,
			y.RowCount_NUMB, 
			y.ORD_ROWNUM
	   FROM (SELECT x.Compliance_INDC, 
					x.Review_DATE,
					x.WorkerReview_ID,
					x.County_NAME,
					x.Open_DATE,
					x.Order_DATE,
					x.Service_DATE,
					x.County_IDNO,
					x.MemberMci_IDNO,
					x.Last_NAME,
					x.Case_IDNO,
					x.StatusLocate_DATE,
					x.UnsuccessfulService_CODE,
					x.UnsuccessfulService_DATE,
					x.DescriptionComments_TEXT,
					x.QuestionOE1_INDC,
					x.QuestionOE2_INDC,
					x.QuestionOE3_INDC,
					x.QuestionOE4_INDC,
					x.WorkerUpdate_ID,
					x.RowCount_NUMB,
					x.ORD_ROWNUM
			   FROM (SELECT a.Compliance_INDC, 
							a.Review_DATE,
							a.WorkerReview_ID,
							b.County_NAME,
							a.Open_DATE,
							a.Order_DATE,
							a.Service_DATE,
							b.County_IDNO,
							b.MemberMci_IDNO,
							b.Last_NAME,
							a.Case_IDNO,
							a.StatusLocate_DATE,
							a.UnsuccessfulService_CODE,
							a.UnsuccessfulService_DATE,
							a.DescriptionComments_TEXT,
							a.QuestionOE1_INDC,
							a.QuestionOE2_INDC,
							a.QuestionOE3_INDC,
							a.QuestionOE4_INDC,
							a.WorkerUpdate_ID,
							COUNT(a.Case_IDNO) OVER() RowCount_NUMB,
							ROW_NUMBER() OVER(ORDER BY a.Case_IDNO) AS ORD_ROWNUM
					   FROM BSAOE_Y1 a JOIN BSACS_Y1 b
						 ON a.Case_IDNO			= b.Case_IDNO
						AND a.Review_DATE		= b.Review_DATE
					  WHERE a.Review_DATE		= @Ad_Review_DATE
					    AND b.Establishment_INDC = @Lc_Yes_INDC
						AND a.EndValidity_DATE	= @Ld_High_DATE) X  
			   WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
					 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)) Y  
		 WHERE (Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB) 
				 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)  
	ORDER BY ORD_ROWNUM;
	    
END -- END OF BSAOE_RETRIEVE_S1


GO
