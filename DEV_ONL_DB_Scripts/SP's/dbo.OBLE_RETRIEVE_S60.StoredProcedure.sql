/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S60]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S60]  (
	 @An_Case_IDNO				NUMERIC(6,0),
	 @An_OrderSeq_NUMB			NUMERIC(2,0),
     @Ad_BeginObligation_DATE	DATE,
     @Ac_TypeDebt_CODE			CHAR(2),
	 @Ac_Fips_CODE				CHAR(7)               
	)
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S60
 *     DESCRIPTION       : Retrieve members for a given period to display Participants field in the grid for non allocated modification. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
	   DECLARE @Ld_High_DATE DATE  = '12/31/9999';
        
        SELECT DISTINCT O.MemberMci_IDNO,O.Periodic_AMNT
	      FROM OBLE_Y1 O
		 WHERE O.Case_IDNO = @An_Case_IDNO 
		   AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		   AND O.TypeDebt_CODE = @Ac_TypeDebt_CODE 
		   AND O.Fips_CODE = @Ac_Fips_CODE 
		   AND O.BeginObligation_DATE = @Ad_BeginObligation_DATE 
		   AND O.EndValidity_DATE =@Ld_High_DATE
		ORDER BY O.Periodic_AMNT;
                  
END; --END OF OBLE_RETRIEVE_S60


GO
