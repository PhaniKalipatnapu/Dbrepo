/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S73]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S73](
	 @An_Case_IDNO				NUMERIC(6,0),
	 @An_OrderSeq_NUMB		    NUMERIC(2,0),
	 @An_ObligationSeq_NUMB		NUMERIC(2,0),
	 @Ad_BeginObligation_DATE	DATE,
	 @Ac_TypeDebt_CODE		    CHAR(2),
	 @Ac_Fips_CODE				CHAR(7),
     @Ac_Allocated_INDC			CHAR(1),
     @Ad_EndObligation_DATE		DATE	 OUTPUT
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S73
 *     DESCRIPTION       : This procedure returns the end obligation date from OBLE_Y1 for case 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SET @Ad_EndObligation_DATE = NULL;

      DECLARE
         @Lc_No_INDC		CHAR(1) = 'N', 
         @Lc_Yes_INDC		CHAR(1) = 'Y', 
         @Ld_High_DATE		DATE	= '12/31/9999';
        
      SELECT @Ad_EndObligation_DATE = MAX(O.EndObligation_DATE)
		FROM OBLE_Y1 O
      WHERE O.Case_IDNO = @An_Case_IDNO 
      AND   O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
      AND ((@Ac_Allocated_INDC = @Lc_Yes_INDC 
			   AND O.ObligationSeq_NUMB = @An_ObligationSeq_NUMB) 
			 OR(@Ac_Allocated_INDC = @Lc_No_INDC 
				  AND O.TypeDebt_CODE = @Ac_TypeDebt_CODE 
				  AND O.Fips_CODE = @Ac_Fips_CODE)) 
	  AND O.BeginObligation_DATE < @Ad_BeginObligation_DATE 
	  AND O.EndValidity_DATE = @Ld_High_DATE;
                  
END;--END OF OBLE_RETRIEVE_S73


GO
