/****** Object:  StoredProcedure [dbo].[CPFL_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPFL_RETRIEVE_S4] (
 @An_Case_IDNO				NUMERIC(6),
 @An_EventGlobalSeq_NUMB	NUMERIC(19)
 )
AS
/*
 *     PROCEDURE NAME    : CPFL_RETRIEVE_S4
 *     DESCRIPTION       : Retrieveing the Fee Recovery Details for Fee Tab.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 17-JUN-2014
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

	DECLARE @Lc_TransactionSrec_CODE	CHAR(4)	= 'SREC';                

	SELECT c.Case_IDNO,
		c.AssessedYear_NUMB,
		c.FeeType_CODE,
		0 Assessed_AMNT,
		SUM(c.Transaction_AMNT) AS Paid_AMNT,
		0 AS Waived_AMNT
	 FROM CPFL_Y1 c
	WHERE c.Case_IDNO = @An_Case_IDNO
	  AND c.Transaction_CODE = @Lc_TransactionSrec_CODE
	  AND c.EventGlobalSeq_NUMB=@An_EventGlobalSeq_NUMB
	GROUP BY c.Case_IDNO, c.AssessedYear_NUMB, c.FeeType_CODE;
	 
END;--End Of CPFL_RETRIEVE_S4


GO
