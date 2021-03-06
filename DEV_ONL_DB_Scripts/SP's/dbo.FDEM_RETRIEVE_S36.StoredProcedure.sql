/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S36]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S36](
	@An_Case_IDNO		                NUMERIC(6,0),
	@Ac_File_ID							CHAR(10)
	        )
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S36
 *     DESCRIPTION       : Retrieves the Order_id for the given case_id and file_id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 13-MARCH-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN
           
  DECLARE 
          @Ld_High_DATE DATE         = '12/31/9999',
          @Lc_TypeDoc_CODE CHAR(1)   = 'O';   
                        
  SELECT DISTINCT F.Order_IDNO
	FROM FDEM_Y1 F
   WHERE F.Case_IDNO         = @An_Case_IDNO
     AND F.File_ID           = @Ac_File_ID
     AND F.TypeDoc_CODE      = @Lc_TypeDoc_CODE
	 AND F.EndValidity_DATE  = @Ld_High_DATE;
			
END;--END FDEM_RETRIEVE_S36  



GO
