/****** Object:  StoredProcedure [dbo].[PRCA_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRCA_RETRIEVE_S1](
 @An_WelfareCaseCounty_IDNO  NUMERIC(3,0),
 @Ad_From_DATE		         DATE,
 @Ad_To_DATE		         DATE, 
 @Ai_RowFrom_NUMB            INT =1,
 @Ai_RowTo_NUMB              INT =10 
)     
AS

/*
 *     PROCEDURE NAME    : PRCA_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the IV-A pending referrals case details.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 02-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

    DECLARE @Lc_No_TEXT	              CHAR(1) = 'N',
		    @Lc_Yes_TEXT	          CHAR(1) = 'Y',
		    @Li_Zero_NUMB             INT     =  0,
		    @Lc_WelfareTypeM_CODE     CHAR(1) = 'M',
            @Lc_WelfareTypeA_CODE     CHAR(1) = 'A',
			@Lc_WelfareTypeN_CODE     CHAR(1) = 'N',
		    @Lc_ReferralProcessD_CODE CHAR(1) = 'D',
		    @Ld_High_DATE             DATE    = '12/31/9999';		   
		   
	SELECT X.CaseWelfare_IDNO,
		   X.AgSequence_NUMB,   
		   X.ReferralReceived_DATE,
		   X.WelfareCaseCounty_IDNO,
		   X.ReasonForPending_CODE,
		   X.TransactionEventSeq_NUMB,
		   X.CaseCreate_INDC,         
		   X.RowCount_NUMB
	FROM (SELECT b.ReferralReceived_DATE,
			     b.WelfareCaseCounty_IDNO,
			     b.CaseWelfare_IDNO,
			     b.AgSequence_NUMB,
			     b.ReasonForPending_CODE,
			     b.TransactionEventSeq_NUMB,
			CASE b.Application_IDNO
                           WHEN 0 THEN @Lc_Yes_TEXT
                           ELSE @Lc_No_TEXT 
                            END AS 
				CaseCreate_INDC,                     
			COUNT(1) OVER() AS RowCount_NUMB, 
			ROW_NUMBER() OVER(
				ORDER BY b.ReferralReceived_DATE DESC) AS Row_NUMB
			FROM PRCA_Y1 b
		  WHERE b.WelfareCaseCounty_IDNO = @An_WelfareCaseCounty_IDNO
			AND b.ReferralReceived_DATE >= ISNULL(@Ad_From_DATE,b.ReferralReceived_DATE)
			AND b.ReferralReceived_DATE <= ISNULL(@Ad_To_DATE,b.ReferralReceived_DATE)
			AND b.ReferralProcess_CODE != @Lc_ReferralProcessD_CODE
		)  AS X
	WHERE (X.Row_NUMB <= @Ai_RowTo_NUMB 
	   OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)
	   AND (X.Row_NUMB >= @Ai_RowFrom_NUMB 
	   OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB) ;
         
END; --End of PRCA_RETRIEVE_S1


GO
