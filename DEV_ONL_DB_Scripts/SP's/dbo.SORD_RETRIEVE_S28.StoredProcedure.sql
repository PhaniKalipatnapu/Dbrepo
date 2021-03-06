/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S28]  (
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ac_File_ID		 CHAR(10),
     @Ac_Exists_INDC     CHAR(1)	OUTPUT
)
AS	
		
/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S28
 *     DESCRIPTION       : This procedure is used to check the obligation exist for the case in SORD_Y1. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SET @Ac_Exists_INDC   = 'N';

     DECLARE @Ld_High_DATE  DATE = '12/31/9999';
        
      SELECT @Ac_Exists_INDC   = 'Y'
        FROM OBLE_Y1   a
             JOIN SORD_Y1   b
         ON  b.Case_IDNO		= a.Case_IDNO 
         AND b.OrderSeq_NUMB	= a.OrderSeq_NUMB  
       WHERE a.Case_IDNO		= @An_Case_IDNO 
         AND b.File_ID			= ISNULL(@Ac_File_ID,b.File_ID) 
         AND a.EndValidity_DATE = @Ld_High_DATE 
         AND b.EndValidity_DATE = @Ld_High_DATE;
                  
END;-- End of SORD_RETRIEVE_S28


GO
