/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S42]  
( 
     @An_Case_IDNO		     NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @Ac_Exists_INDC         CHAR(1) OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S42
 *     DESCRIPTION       : This Procedure returns the existance of support order in SORD_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 26-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      SET @Ac_Exists_INDC  = 'N';

      DECLARE
         @Lc_Yes_INDC      CHAR(1)  = 'Y', 
         @Ld_High_DATE     DATE		= '12/31/9999';
        
      SELECT @Ac_Exists_INDC  ='Y'
        FROM SORD_Y1  a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.DirectPay_INDC = @Lc_Yes_INDC 
         AND a.EndValidity_DATE = @Ld_High_DATE;

                  
END;--END OF SORD_RETRIEVE_S42  


GO
