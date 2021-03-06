/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S103]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S103]  
(
     @An_Case_IDNO			 NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @Ac_Exists_INDC         CHAR(1) OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S103
 *     DESCRIPTION       : This procedure is returns the existance of the obligation in OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

           SET @Ac_Exists_INDC = 'Y';
      
       DECLARE 
			   @Lc_No_INDC		CHAR(1) = 'N',
               @Ld_High_DATE	DATE = '12/31/9999',
               @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT @Ac_Exists_INDC = @Lc_No_INDC
         WHERE NOT EXISTS (
							SELECT 1 
								FROM OBLE_Y1  b
						    WHERE b.Case_IDNO = @An_Case_IDNO 
						      AND b.OrderSeq_NUMB = @An_OrderSeq_NUMB 
							  AND b.EndObligation_DATE > @Ld_Current_DATE 
							  AND b.EndValidity_DATE = @Ld_High_DATE
						);
							 
END;--End of OBLE_RETRIEVE_S103


GO
