/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S93]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S93](
		 @An_Case_IDNO		  NUMERIC(6,0),
		 @An_OrderSeq_NUMB	  NUMERIC(2,0),
		 @Ac_TypeDebt_CODE	  CHAR(2),
		 @Ac_Fips_CODE		  CHAR(7)               
		)
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S93
 *     DESCRIPTION       : This procedure returns default active members from OBLE_Y1 while new obligation entry.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		 DECLARE
         @Ld_High_DATE	DATE  = '12/31/9999';
        
		 SELECT DISTINCT a.MemberMci_IDNO  
			FROM OBLE_Y1 a
		 WHERE a.Case_IDNO = @An_Case_IDNO 
		 AND   a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		 AND   a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
		 AND   a.Fips_CODE = @Ac_Fips_CODE 
		 AND   a.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S93


GO
