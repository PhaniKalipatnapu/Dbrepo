/****** Object:  StoredProcedure [dbo].[EFTR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EFTR_RETRIEVE_S1]  
(
     
     @Ac_CheckRecipient_ID			CHAR(10),
     @Ac_CheckRecipient_CODE		CHAR(1),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)	 OUTPUT,
     @An_RoutingBank_NUMB			NUMERIC(9,0)	 OUTPUT,
     @Ac_AccountBankNo_TEXT			CHAR(17)	 OUTPUT,
     @Ac_TypeAccount_CODE			CHAR(1)	 OUTPUT,
     @Ad_PreNote_DATE				DATE	 OUTPUT,
     @Ad_FirstTransfer_DATE			DATE	 OUTPUT,
     @Ad_EftStatus_DATE				DATE	 OUTPUT,
     @Ac_StatusEft_CODE				CHAR(2)	 OUTPUT,
     @Ac_Reason_CODE                CHAR(5)            OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : EFTR_RETRIEVE_S1
 *     DESCRIPTION       : It Retrieve the Electronic Fund Transfer Information for the corresponding CheckRecipient ID and CheckRecipient CODE.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
   
SELECT
       @Ad_EftStatus_DATE = NULL,

       @Ad_FirstTransfer_DATE = NULL,

       @Ad_PreNote_DATE = NULL,

       @An_EventGlobalBeginSeq_NUMB = NULL,

       @Ac_Reason_CODE = NULL,

       @Ac_StatusEft_CODE = NULL,

      @Ac_AccountBankNo_TEXT = NULL,

       @An_RoutingBank_NUMB = NULL,

       @Ac_TypeAccount_CODE = NULL;

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999'; 
        
    SELECT @An_EventGlobalBeginSeq_NUMB = E.EventGlobalBeginSeq_NUMB,
         @An_RoutingBank_NUMB = E.RoutingBank_NUMB, 
         @Ac_AccountBankNo_TEXT = E.AccountBankNo_TEXT, 
         @Ac_TypeAccount_CODE = E.TypeAccount_CODE, 
         @Ad_PreNote_DATE = E.PreNote_DATE, 
         @Ad_FirstTransfer_DATE = E.FirstTransfer_DATE, 
         @Ad_EftStatus_DATE = E.EftStatus_DATE, 
         @Ac_StatusEft_CODE = E.StatusEft_CODE, 
         @Ac_Reason_CODE =E.Reason_CODE
      FROM EFTR_Y1 E
      WHERE E.CheckRecipient_ID = @Ac_CheckRecipient_ID 
      AND  E.CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
      AND  E.EndValidity_DATE = @Ld_High_DATE;

                  
END;--End of EFTR_RETRIEVE_S1


GO
