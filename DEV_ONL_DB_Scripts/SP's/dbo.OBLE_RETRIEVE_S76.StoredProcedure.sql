/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S76]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S76] (
     @An_Case_IDNO					NUMERIC(6,0),
     @An_OrderSeq_NUMB				NUMERIC(2,0),
     @An_ObligationSeq_NUMB			NUMERIC(2,0),
     @Ad_BeginObligation_DATE		DATE,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)            
)
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S76
 *     DESCRIPTION       : This procedure returns the periodic code and its frequency,reason change from OBLE_Y1 for the case.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      DECLARE
         @Ld_High_DATE DATE  = '12/31/9999';
        
      SELECT a.Periodic_AMNT , 
			 a.FreqPeriodic_CODE , 
			 a.BeginObligation_DATE, 
			 a.EndObligation_DATE , 
			 a.ReasonChange_CODE 
        FROM OBLE_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
         AND a.BeginObligation_DATE >= @Ad_BeginObligation_DATE
         AND(( a.EndValidity_DATE = @Ld_High_DATE 
				 AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB) 
			OR(a.EndValidity_DATE = @Ld_High_DATE 
				 AND a.EventGlobalBeginSeq_NUMB != @An_EventGlobalBeginSeq_NUMB)
            )
      ORDER BY BeginObligation_DATE;
                  
END;-- End of OBLE_RETRIEVE_S76


GO
