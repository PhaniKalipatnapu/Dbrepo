/****** Object:  StoredProcedure [dbo].[BSACC_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSACC_RETRIEVE_S1] 
(
	 @Ad_Review_DATE		DATE,
     @Ai_RowFrom_NUMB       INT = 1,  
     @Ai_RowTo_NUMB         INT = 10
)
AS
/*
 *     PROCEDURE NAME    : BSACC_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the case closure details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
	DECLARE @Li_Zero_NUMB			SMALLINT = 0,
			@Lc_Yes_INDC			CHAR(1) = 'Y',
			@Ld_High_DATE			DATE = '12/31/9999',
			@Lc_TableCPRO_ID		CHAR(4) = 'CPRO',
			@Lc_TableSubREAS_ID		CHAR(4) = 'REAS';

			 SELECT y.County_IDNO,
					y.County_NAME,
					y.MemberMci_IDNO,
					y.Last_NAME,
					y.Close_DATE,
					y.RsnClosure_CODE,
					y.Notice_DATE,
					y.Compliance_INDC,
					y.DescriptionComments_TEXT,
					y.QuestionC1_INDC,
					y.QuestionC2_INDC,
					y.WorkerReview_ID,
					y.Review_DATE,
					y.Case_IDNO,
					y.WorkerUpdate_ID,
					y.RowCount_NUMB,
					y.ORD_ROWNUM
			   FROM (SELECT x.County_IDNO,
							x.County_NAME,
							x.MemberMci_IDNO,
							x.Last_NAME,
							x.Close_DATE,
							x.RsnClosure_CODE,
							x.Notice_DATE,
							x.Compliance_INDC,
							x.DescriptionComments_TEXT,
							x.QuestionC1_INDC,
							x.QuestionC2_INDC,
							x.WorkerReview_ID,
							x.Review_DATE,
							x.Case_IDNO,
							x.WorkerUpdate_ID,
							X.RowCount_NUMB,
							x.ORD_ROWNUM
					   FROM (SELECT a.County_IDNO,
									a.County_NAME,
									a.MemberMci_IDNO,
									a.Last_NAME,
									b.Close_DATE,
									b.RsnClosure_CODE,
									b.Notice_DATE,
									b.Compliance_INDC,
									b.DescriptionComments_TEXT,
									b.QuestionC1_INDC,
									b.QuestionC2_INDC,
									b.WorkerReview_ID,
									b.Review_DATE,
									b.Case_IDNO,
									b.WorkerUpdate_ID,
									COUNT(b.Case_IDNO) OVER() RowCount_NUMB,
									ROW_NUMBER() OVER(ORDER BY b.Case_IDNO) AS ORD_ROWNUM
							   FROM BSACS_Y1 a  JOIN  BSACC_Y1 b
								 ON a.Case_IDNO			= b.Case_IDNO
								AND a.Review_DATE		= b.Review_DATE
							  WHERE a.Review_DATE		= @Ad_Review_DATE
							    AND a.CaseClosure_INDC  = @Lc_Yes_INDC
								AND b.EndValidity_DATE	= @Ld_High_DATE) X  
				      WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
						    OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)) Y  
		      WHERE (Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB)   
				     OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
	ORDER BY ORD_ROWNUM;
	    
END  -- END OF BSACC_RETRIEVE_S1


GO
