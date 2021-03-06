/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S40]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S40]  
	(
	 @An_Case_IDNO		NUMERIC(6,0),
	 @An_OrderSeq_NUMB	NUMERIC(2,0),
     @Ac_TypeDebt_CODE	CHAR(2),
     @Ac_Fips_CODE		CHAR(7)               
    )
AS

/*
 *     PROCEDURE NAME   : OBLE_RETRIEVE_S40
 *     DESCRIPTION      : This procedure returns the obligation info from OBLE_Y1
 *     DEVELOPED BY     : IMP Team
 *     DEVELOPED ON     : 27-NOV-2011
 *     MODIFIED BY      : 
 *     MODIFIED ON      : 
 *     VERSION NO       : 1
*/
   BEGIN

	DECLARE
		@Ld_High_DATE DATE  = '12/31/9999';
        
	SELECT DISTINCT a.Case_IDNO , 
					a.OrderSeq_NUMB , 
					a.ObligationSeq_NUMB , 
					a.MemberMci_IDNO 
		FROM OBLE_Y1 a
    WHERE a.Case_IDNO		 = @An_Case_IDNO 
      AND a.OrderSeq_NUMB	 = @An_OrderSeq_NUMB 
      AND a.TypeDebt_CODE	 = @Ac_TypeDebt_CODE 
      AND a.Fips_CODE		 = @Ac_Fips_CODE 
      AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END; -- END OF OBLE_RETRIEVE_S40


GO
