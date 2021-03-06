/****** Object:  StoredProcedure [dbo].[ORDB_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORDB_RETRIEVE_S2] (
     @An_Case_IDNO			   NUMERIC(6,0),
     @An_OrderSeq_NUMB         NUMERIC(2,0),
     @Ac_TypeDebt_CODE		   CHAR(2),
     @Ac_Allocated_INDC		   CHAR(1)		OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : ORDB_RETRIEVE_S2
 *     DESCRIPTION       : This procedure is returns the allocation indication from ORDB_Y1 for a case.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	  SET @Ac_Allocated_INDC = NULL;

      DECLARE 
		 @Ld_High_DATE	DATE = '12/31/9999';
        
      SELECT @Ac_Allocated_INDC = a.Allocated_INDC
        FROM ORDB_Y1  a
      WHERE a.Case_IDNO		    = @An_Case_IDNO 
        AND a.OrderSEQ_NUMB 	= @An_OrderSeq_NUMB 
        AND a.TypeDebt_CODE		= @Ac_TypeDebt_CODE 
        AND a.EndValidity_DATE  = @Ld_High_DATE;

END;--End of ORDB_RETRIEVE_S2  


GO
