/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S43] (
	  @An_Case_IDNO			 NUMERIC(6,0),
	  @An_OrderSeq_NUMB		 NUMERIC(2,0)
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S43
 *     DESCRIPTION       : Retrieve the frequency periodic code from OBLE_Y1 for Case ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
        DECLARE
           @Lc_OneTime_CODE		CHAR(1) = 'O',
           @Ld_High_DATE		DATE	= '12/31/9999';
           
 		SELECT DISTINCT O.FreqPeriodic_CODE  
			FROM OBLE_Y1 O
		WHERE O.Case_IDNO = @An_Case_IDNO 
		  AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		  AND O.FreqPeriodic_CODE != @Lc_OneTime_CODE 
		  AND O.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S43


GO
