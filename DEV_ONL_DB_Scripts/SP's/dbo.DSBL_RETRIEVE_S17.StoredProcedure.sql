/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S17]  (

     @An_Case_IDNO		 NUMERIC(6,0),
     @Ac_Flag_INDC                          CHAR(1)     OUTPUT
     )
AS
 /*    
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S17    
  *     DESCRIPTION       : Checks if the type of recipient for whom the disbursement is made is either another party or a FIPS associated with the given case.
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-FEB-2011
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
   BEGIN

      SET @Ac_Flag_INDC = NULL;

      DECLARE
         @Lc_FipsCheckRecipient_CODE   CHAR(1) = '2', 
         @Lc_OthpCheckRecipient_CODE   CHAR(1) = '3', 
         @Lc_StatusSuccess_INDC       CHAR(1) = 'Y';
        
        SELECT TOP 1 @Ac_Flag_INDC = @Lc_StatusSuccess_INDC
      FROM DSBL_Y1 D
      WHERE D.CheckRecipient_CODE IN ( @Lc_FipsCheckRecipient_CODE, @Lc_OthpCheckRecipient_CODE ) 
      
       AND D.Case_IDNO = @An_Case_IDNO;

                  
END


GO
