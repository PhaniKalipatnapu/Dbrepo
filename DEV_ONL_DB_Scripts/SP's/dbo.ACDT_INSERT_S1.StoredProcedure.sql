/****** Object:  StoredProcedure [dbo].[ACDT_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ACDT_INSERT_S1]  (
   		
		@An_AccountBankNo_TEXT  numeric(16, 0) OUTPUT
      
     )            
AS

/*
 *     PROCEDURE NAME    : ACDT_INSERT_S1
 *     DESCRIPTION       : 
 *     DEVELOPED BY      : IMP Team.
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
   
      
    
      
      INSERT INTO [ACDT_Y1] DEFAULT VALUES
     			
				SET @An_AccountBankNo_TEXT = @@IDENTITY;
				
 END; --End of PLIC_INSERT_S1.    



GO
