/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S90]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S90] (
     @An_Case_IDNO		 NUMERIC(6,0), 
	 @An_OrderSeq_NUMB	 NUMERIC(2,0)
)
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S90
 *     DESCRIPTION       : Procedure retruns the debt type for the non allocated obligation modification.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
      DECLARE @Lc_No_INDC	CHAR(1) = 'N', 
              @Ld_High_DATE	DATE	= '12/31/9999';
        
       SELECT DISTINCT a.TypeDebt_CODE, 
					   a.Fips_CODE  
	     FROM OBLE_Y1  a 
	          JOIN 
	          ORDB_Y1  b
		   ON b.Case_IDNO	  = a.Case_IDNO       
          AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
          AND b.TypeDebt_CODE = a.TypeDebt_CODE  
        WHERE a.Case_IDNO = @An_Case_IDNO 
          AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
          AND a.EndValidity_DATE = @Ld_High_DATE 
          AND b.Allocated_INDC = @Lc_No_INDC 
          AND b.EndValidity_DATE = @Ld_High_DATE
      ORDER BY TypeDebt_CODE;
                  
END; --END OF OBLE_RETRIEVE_S90


GO
