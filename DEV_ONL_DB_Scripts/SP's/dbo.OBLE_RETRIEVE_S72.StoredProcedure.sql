/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S72]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S72] (
     @An_Case_IDNO			 NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @An_MemberMci_IDNO		 NUMERIC(10,0),
     @Ac_TypeDebt_CODE		 CHAR(2),
     @Ac_Fips_CODE		     CHAR(7),
     @Ac_Allocated_INDC		 CHAR(1),
     @Ai_Count_QNTY          INT            OUTPUT
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S72
 *     DESCRIPTION       : This procedure retruns the count of obligation exist for the case id from OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Lc_No_INDC	CHAR(1) = 'N', 
         @Lc_Yes_INDC	CHAR(1) = 'Y', 
         @Ld_High_DATE	DATE	= '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
		 FROM OBLE_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO 
      AND   a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
      AND   a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
      AND   a.Fips_CODE = @Ac_Fips_CODE 
      AND   (( @Ac_Allocated_INDC = @Lc_Yes_INDC 
                AND a.MemberMci_IDNO = @An_MemberMci_IDNO) 
			  OR @Ac_Allocated_INDC = @Lc_No_INDC) 
	  AND   a.EndValidity_DATE =@Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S72 


GO
