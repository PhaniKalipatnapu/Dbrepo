/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S74]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S74] (
	 @An_Case_IDNO				NUMERIC(6,0),
	 @An_OrderSeq_NUMB			NUMERIC(2,0),
     @Ad_BeginObligation_DATE	DATE,
     @An_EventGlobalSeq_NUMB	NUMERIC(19,0),
     @Ac_TypeDebt_CODE			CHAR(2),  
     @Ac_Fips_CODE				CHAR(7)        
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S74
 *     DESCRIPTION       : This procedure retruns the Obligation info from OBLE_Y1 for Case. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

     DECLARE
         @Ld_High_DATE		DATE = '12/31/9999',
         @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT DISTINCT O.Case_IDNO,
					    O.OrderSeq_NUMB,
					    O.ObligationSeq_NUMB,
					    O.MemberMci_IDNO
			FROM OBLE_Y1 O
		WHERE O.Case_IDNO = @An_Case_IDNO 
		AND   O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		AND   O.TypeDebt_CODE = @Ac_TypeDebt_CODE 
		AND   O.Fips_CODE = @Ac_Fips_CODE 
		AND   O.BeginObligation_DATE >= @Ad_BeginObligation_DATE 
		AND  (( O.EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB 
				  AND O.EndValidity_DATE = @Ld_Current_DATE) 
			  OR (O.EndValidity_DATE = @Ld_High_DATE 
				 AND O.EventGlobalBeginSeq_NUMB != @An_EventGlobalSeq_NUMB) 
			  OR (O.EndValidity_DATE = @Ld_High_DATE 
				 AND O.EventGlobalBeginSeq_NUMB = @An_EventGlobalSeq_NUMB))
      ORDER BY ObligationSeq_NUMB;
                  
END; --END OF OBLE_RETRIEVE_S74


GO
