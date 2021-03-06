/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S46]  
	(
	 @An_Case_IDNO			 NUMERIC(6,0),
	 @An_OrderSeq_NUMB		 NUMERIC(2,0),
	 @An_ObligationSeq_NUMB	 NUMERIC(2,0)                   
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S46
 *     DESCRIPTION       : Retrieve the perodic amt,frequency mode, begin and end obligation details from OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

		DECLARE
			 @Ld_High_DATE	DATE = '12/31/9999';
        
        SELECT O.Periodic_AMNT, 
			   O.FreqPeriodic_CODE, 
			   O.BeginObligation_DATE, 
			   ISNULL(O.EndObligation_DATE, @Ld_High_DATE) AS EndObligation_DATE, 
			   O.ReasonChange_CODE
			FROM OBLE_Y1 O
		WHERE O.Case_IDNO			= @An_Case_IDNO 
		AND   O.OrderSeq_NUMB		= @An_OrderSeq_NUMB 
		AND   O.ObligationSeq_NUMB  = @An_ObligationSeq_NUMB 
		AND   O.EndValidity_DATE	= @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S46


GO
