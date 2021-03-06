/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S31]  

AS
/*
 *     PROCEDURE NAME    : OFIC_RETRIEVE_S31
 *     DESCRIPTION       : This procedure returns the otherparty ID and Office name from OFIC_Y1.
 *     DEVELOPED BY      : IMC Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
        DECLARE
           @Li_Six_NUMB                INT = 6,
           @Lc_OfficeLikeCwa_CODE      CHAR(5) = 'OFF%6',
           @Ld_High_DATE    		   DATE  = '12/31/9999';
        
        SELECT a.OtherParty_IDNO , 
               a.Office_NAME 
          FROM  OFIC_Y1 a
        WHERE a.OtherParty_IDNO LIKE @Lc_OfficeLikeCwa_CODE 
          AND a.TypeOffice_CODE  = @Li_Six_NUMB 
		  AND a.EndValidity_DATE = @Ld_High_DATE;
		  
END;--End of OFIC_RETRIEVE_S31


GO
