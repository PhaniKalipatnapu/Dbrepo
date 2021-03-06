/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S92]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S92]  
	(
	 @An_Case_IDNO		      NUMERIC(6,0),
	 @An_OrderSeq_NUMB		  NUMERIC(2,0),
	 @An_ObligationSeq_NUMB	  NUMERIC(2,0),
     @Ad_BeginObligation_DATE DATE
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S92
 *     DESCRIPTION       : This procedure returns the periodic amount from OBLE_Y1 for amount validation purpose while modification.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
	   DECLARE @Ld_High_DATE	DATE  = '12/31/9999';
        
        SELECT FLOOR(O.Periodic_AMNT) AS Periodic_AMNT
	      FROM OBLE_Y1 O
	 	 WHERE O.Case_IDNO = @An_Case_IDNO 
		   AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		   AND O.ObligationSeq_NUMB != @An_ObligationSeq_NUMB 
		   AND @Ad_BeginObligation_DATE BETWEEN O.BeginObligation_DATE AND O.EndObligation_DATE 
		   AND O.EndValidity_DATE = @Ld_High_DATE;
		                  
END; -- END OF OBLE_RETRIEVE_S92


GO
