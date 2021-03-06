/****** Object:  StoredProcedure [dbo].[ORDB_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ORDB_RETRIEVE_S4] (
     @An_Case_IDNO		 NUMERIC(6,0),
     @An_OrderSeq_NUMB	 NUMERIC(2,0),
     @Ac_TypeDebt_CODE	 CHAR(2),
     @Ac_Allocated_INDC	 CHAR(1)	     OUTPUT,
     @An_Order_AMNT		 NUMERIC(11,2)	 OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : ORDB_RETRIEVE_S4
 *     DESCRIPTION       : This procedure returns the periodic amt and allocated indication for case ID .
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SELECT @Ac_Allocated_INDC = NULL,
             @An_Order_AMNT		= NULL;

      DECLARE 
			  @Li_Zero_NUMB     SMALLINT = 0,
			  @Ld_High_DATE		DATE = '12/31/9999';

       SELECT @An_Order_AMNT		= ISNULL(a.Order_AMNT, @Li_Zero_NUMB), 
              @Ac_Allocated_INDC = a.Allocated_INDC
        FROM ORDB_Y1 a
       WHERE a.Case_IDNO		= @An_Case_IDNO 
         AND a.OrderSeq_NUMB	= @An_OrderSeq_NUMB 
         AND a.TypeDebt_CODE	= @Ac_TypeDebt_CODE 
         AND a.EndValidity_DATE = @Ld_High_DATE;

END;--END OF ORDB_RETRIEVE_S4


GO
