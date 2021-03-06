/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S58]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S58] (
	 @An_Case_IDNO		     NUMERIC(6,0),
	 @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @An_ObligationSeq_NUMB	 NUMERIC(2,0)                    
     )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S58
 *     DESCRIPTION       : Procedure is used to populate obligation info for allocation indication NO in modify obligation screen.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      DECLARE
           @Ld_High_DATE	 DATE= '12/31/9999';
                            
        SELECT a.BeginObligation_DATE, 
			   a.EndObligation_DATE,                
			   a.Periodic_AMNT, 
			   a.FreqPeriodic_CODE, 
			   a.ReasonChange_CODE 
			FROM OBLE_Y1 a
		WHERE a.Case_IDNO = @An_Case_IDNO 
		  AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		  AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
		  AND a.EndValidity_DATE = @Ld_High_DATE
        ORDER BY BeginObligation_DATE, a.EndObligation_DATE;
                  
END; --END OF OBLE_RETRIEVE_S58


GO
