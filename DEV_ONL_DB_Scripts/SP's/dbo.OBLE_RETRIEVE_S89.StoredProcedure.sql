/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S89]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S89]  
	(
	 @An_Case_IDNO				NUMERIC(6,0),
     @An_OrderSeq_NUMB			NUMERIC(2,0),
     @Ac_TypeDebt_CODE			CHAR(2),
     @Ac_Fips_CODE				CHAR(7),
     @Ai_Count_QNTY				INT		    OUTPUT
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S89
 *     DESCRIPTION       : This procedure returns the number of obligation exist in the OBLE_Y1 for CASE ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

        SET @Ai_Count_QNTY = NULL;

        DECLARE
			 @Ld_High_DATE DATE  = '12/31/9999';
        
        SELECT @Ai_Count_QNTY = COUNT(1)
			FROM ( SELECT DISTINCT a.ObligationSeq_NUMB
						FROM OBLE_Y1 a
				   WHERE a.Case_IDNO = @An_Case_IDNO 
				     AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
				     AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
				     AND a.Fips_CODE = @Ac_Fips_CODE 
				     AND NOT EXISTS (SELECT 1 
										FROM OBLE_Y1  b
									WHERE a.Case_IDNO = b.Case_IDNO 
									  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB 
									  AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB 
									  AND b.EndValidity_DATE =@Ld_High_DATE)
				) X;

                  
END;--END OF OBLE_RETRIEVE_S89


GO
