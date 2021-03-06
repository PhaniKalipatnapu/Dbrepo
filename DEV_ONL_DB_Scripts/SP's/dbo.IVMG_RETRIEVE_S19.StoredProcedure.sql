/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S19] (
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @Ac_WelfareElig_CODE      CHAR(1),
 @An_WelfareYearMonth_NUMB NUMERIC(6)		OUTPUT,
 @An_LtdAssistExpend_AMNT  NUMERIC(11, 2)	OUTPUT,
 @An_LtdAssistRecoup_AMNT  NUMERIC(11, 2)	OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S19
  *     DESCRIPTION       : Retrieves the Total To Date expend and recoup amount for the maximum Welfare month/year available to the given Welfare case, Welfare eligibility.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 30-OCT-2014
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_WelfareYearMonth_NUMB = NULL;
  SET @An_LtdAssistExpend_AMNT	= NULL;
  SET @An_LtdAssistRecoup_AMNT	= NULL;


	SELECT @An_WelfareYearMonth_NUMB = i.WelfareYearMonth_NUMB,
		@An_LtdAssistExpend_AMNT = i.LtdAssistExpend_AMNT,
		@An_LtdAssistRecoup_AMNT = i.LtdAssistRecoup_AMNT
	FROM IVMG_Y1 i
	WHERE i.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
		AND i.WelfareElig_CODE = @Ac_WelfareElig_CODE
		AND i.WelfareYearMonth_NUMB = ( SELECT MAX( WelfareYearMonth_NUMB )
										FROM IVMG_Y1 v
										WHERE v.CaseWelfare_IDNO = i.CaseWelfare_IDNO
										AND v.WelfareElig_CODE = i.WelfareElig_CODE )
		AND i.EventGlobalSeq_NUMB = ( SELECT MAX( EventGlobalSeq_NUMB )
										FROM IVMG_Y1 m
										WHERE m.CaseWelfare_IDNO = i.CaseWelfare_IDNO
										AND m.WelfareElig_CODE = i.WelfareElig_CODE 
										AND m.WelfareYearMonth_NUMB = i.WelfareYearMonth_NUMB )

 END; -- End of IVMG_RETRIEVE_S19


GO
