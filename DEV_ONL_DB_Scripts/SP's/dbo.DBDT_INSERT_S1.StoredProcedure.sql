/****** Object:  StoredProcedure [dbo].[DBDT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DBDT_INSERT_S1]  
(
   		
		@An_DebitCard_NUMB  numeric(16, 0) OUTPUT
         
     
     
     )            
AS

/*
 *     PROCEDURE NAME    : DBDT_INSERT_S1
 *     DESCRIPTION       : Insert mci information into mci table.
 *     DEVELOPED BY      : IMP Team.
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
   
   DECLARE
    @Ld_High_DATE  DATE ='12/31/9999',
	@Ld_Current_DATE  DATE = getdate(),--dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
	@Li_Zero_NUMB    SMALLINT=0,
	@Lc_Space_TEXT   CHAR(1)=' ';
   
    INSERT INTO DBDT_Y1 DEFAULT VALUES  			
	SET @An_DebitCard_NUMB = @@IDENTITY;
				
 END; --End of PLIC_INSERT_S1.    



GO
