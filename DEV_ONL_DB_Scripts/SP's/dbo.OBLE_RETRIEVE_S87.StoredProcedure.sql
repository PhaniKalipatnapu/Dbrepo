/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S87]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S87]  (
	 @An_Case_IDNO			 NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @Ac_TypeDebt_CODE		 CHAR(2),
     @Ac_Fips_CODE			 CHAR(7)
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S87
 *     DESCRIPTION       : This procedure returns the frequency periodic code from OBLE_Y1 table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN
      DECLARE
         @Lc_Onetime_CODE   CHAR(1) = 'O',
         @Ld_High_DATE		DATE	= '12/31/9999';
        
		 SELECT DISTINCT O.FreqPeriodic_CODE 
			FROM OBLE_Y1 O
		  WHERE O.Case_IDNO			= @An_Case_IDNO 
			AND O.OrderSeq_NUMB		= @An_OrderSeq_NUMB 
			AND O.TypeDebt_CODE		!= @Ac_TypeDebt_CODE 
			AND O.Fips_CODE			!= @Ac_Fips_CODE 
			AND O.FreqPeriodic_CODE != @Lc_Onetime_CODE 
			AND O.EndValidity_DATE	= @Ld_High_DATE;
              
END; --END OF OBLE_RETRIEVE_S87


GO
