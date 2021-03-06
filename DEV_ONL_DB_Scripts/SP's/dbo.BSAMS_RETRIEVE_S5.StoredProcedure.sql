/****** Object:  StoredProcedure [dbo].[BSAMS_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAMS_RETRIEVE_S5] 
(
	@An_Case_IDNO					NUMERIC(6,0),
	@An_TransactionEventSeq_NUMB	NUMERIC(19,0) OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSAMS_RETRIEVE_S5
 *     DESCRIPTION       : This procedure is used to take the sequence number for the given input.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 16-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

   DECLARE @Ld_High_DATE				DATE    = '12/31/9999';
	
	SELECT @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
      FROM BSAMS_Y1  a
     WHERE a.Case_IDNO				  = @An_Case_IDNO
       AND a.EndValidity_DATE		  = @Ld_High_DATE;
       
END  --END OF BSAMS_RETRIEVE_S5


GO
