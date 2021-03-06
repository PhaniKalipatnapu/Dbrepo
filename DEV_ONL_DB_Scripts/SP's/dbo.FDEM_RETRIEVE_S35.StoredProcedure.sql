/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FDEM_RETRIEVE_S35]  (
	@An_Case_IDNO		                NUMERIC(6,0),
	@An_Order_IDNO						NUMERIC(15,0),
	@Ac_File_ID							CHAR(10),	
	@An_Petition_IDNO                   NUMERIC(7,0)    OUTPUT
	        )
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S35
 *     DESCRIPTION       : Check Whether the valid petition number is exist or not.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MARCH-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

BEGIN
      SET @An_Petition_IDNO = NULL;
      
  DECLARE @Ld_High_DATE DATE     = '12/31/9999';   
                        
  SELECT @An_Petition_IDNO = F.Petition_IDNO
	FROM FDEM_Y1 F
   WHERE F.Case_IDNO         = @An_Case_IDNO
     AND F.File_ID           = @Ac_File_ID
	 AND F.Order_IDNO        = @An_Order_IDNO
	 AND F.EndValidity_DATE  = @Ld_High_DATE;
			
END;--END FDEM_RETRIEVE_S35  

GO
