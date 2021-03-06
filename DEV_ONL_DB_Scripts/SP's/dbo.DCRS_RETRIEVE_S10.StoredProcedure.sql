/****** Object:  StoredProcedure [dbo].[DCRS_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[DCRS_RETRIEVE_S10]  
    	(
    		@Ac_CheckRecipient_ID   CHAR(10),
    		@An_RoutingBank_NUMB	NUMERIC(9,0), 
    		@Ac_AccountBankNo_TEXT	CHAR(17),
    		@An_DebitCard_NUMB      NUMERIC(16,0),
            @Ad_Status_DATE         DATE    OUTPUT,  
            @Ac_Status_CODE         CHAR(1) OUTPUT 	 
     	)             
AS

/*
*     PROCEDURE NAME    : DCRS_RETRIEVE_S10
 *     DESCRIPTION       : Sets status code as ACTIVE when Account Number is available if not sets to INACTIVE. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

  SET @Ac_Status_CODE = 'I'; 

      DECLARE
         @Ld_High_DATE          DATE = '12/31/9999',
         @Lc_StatusActive_CODE  CHAR(1)='A';
       
       SELECT @Ac_Status_CODE = @Lc_StatusActive_CODE,
       @Ad_Status_DATE=d.Status_DATE
        FROM DCRS_Y1  d 
        WHERE d.CheckRecipient_ID = @Ac_CheckRecipient_ID
        AND d.RoutingBank_NUMB = @An_RoutingBank_NUMB
        AND d.AccountBankNo_TEXT = @Ac_AccountBankNo_TEXT
        AND d.DebitCard_NUMB = @An_DebitCard_NUMB
        AND d.EndValidity_DATE = @Ld_High_DATE;
                  
END; --End of DCRS_RETRIEVE_S10


GO
