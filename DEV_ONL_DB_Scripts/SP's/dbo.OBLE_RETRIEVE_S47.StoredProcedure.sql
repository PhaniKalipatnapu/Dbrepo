/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S47] (
     @An_Case_IDNO				NUMERIC(6,0),
     @An_OrderSeq_NUMB			NUMERIC(2,0),
     @Ac_TypeDebt_CODE			CHAR(2),
     @Ac_Fips_CODE				CHAR(7),
     @An_ExpectToPay_AMNT		NUMERIC(11,2)	 OUTPUT,
     @Ac_CheckRecipient_ID		CHAR(10)		 OUTPUT,
     @Ac_CheckRecipient_CODE	CHAR(1)			 OUTPUT
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S47
 *     DESCRIPTION       : This procedure returns the check recipient id,amnt and amnt to pay from OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SELECT @Ac_CheckRecipient_CODE = NULL,
			 @An_ExpectToPay_AMNT = NULL,
			 @Ac_CheckRecipient_ID = NULL;

      DECLARE
         @Ld_High_DATE		DATE = '12/31/9999',
         @Ld_Current_DATE   DATE =DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
      SELECT TOP 1 @Ac_CheckRecipient_ID = a.CheckRecipient_ID, 
                   @Ac_CheckRecipient_CODE = a.CheckRecipient_CODE, 
                   @An_ExpectToPay_AMNT = a.ExpectToPay_AMNT
        FROM OBLE_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO 
		AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
		AND a.Fips_CODE = @Ac_Fips_CODE 
		AND((a.BeginObligation_DATE <= @Ld_Current_DATE 
			 AND a.EndObligation_DATE =
					 (SELECT MAX(b.EndObligation_DATE)
						FROM OBLE_Y1 b
					  WHERE b.Case_IDNO = a.Case_IDNO 
					  AND   b.OrderSeq_NUMB = a.OrderSeq_NUMB 
					  AND   b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
					  AND   b.BeginObligation_DATE <= @Ld_Current_DATE 
					  AND   b.EndValidity_DATE = @Ld_High_DATE) )
		 OR(a.BeginObligation_DATE > @Ld_Current_DATE 
			    AND a.EndObligation_DATE = 
					( SELECT MIN(e.EndObligation_DATE)
						FROM OBLE_Y1 e
					  WHERE e.Case_IDNO = a.Case_IDNO 
					  AND   e.OrderSeq_NUMB = a.OrderSeq_NUMB 
					  AND   e.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
					  AND   e.EndValidity_DATE = @Ld_High_DATE 
					  AND   e.BeginObligation_DATE > @Ld_Current_DATE) )	 ) 
	AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S47


GO
