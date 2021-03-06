/****** Object:  StoredProcedure [dbo].[BSAOE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAOE_RETRIEVE_S2] 
(
	@An_Case_IDNO					NUMERIC(6,0),	
	@Ai_Count_QNTY   				INT  	OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : BSAOE_RETRIEVE_S2
 *     DESCRIPTION       : Checks whether the record exist or not in Establishment of paternity and support order.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 20-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN

	   SET @Ai_Count_QNTY = NULL;
   DECLARE @Ld_High_DATE				DATE    = '12/31/9999';

	SELECT @Ai_Count_QNTY = COUNT (1)
      FROM BSAOE_Y1  a
     WHERE a.Case_IDNO				  = @An_Case_IDNO
       AND a.TransactionEventSeq_NUMB = (SELECT a.TransactionEventSeq_NUMB
										   FROM BSAOE_Y1  a
										  WHERE a.Case_IDNO				  = @An_Case_IDNO
										    AND a.EndValidity_DATE		  = @Ld_High_DATE);
       
END  --END OF BSAOE_RETRIEVE_S2


GO
