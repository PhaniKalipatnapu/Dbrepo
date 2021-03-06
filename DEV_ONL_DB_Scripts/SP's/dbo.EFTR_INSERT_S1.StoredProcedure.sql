/****** Object:  StoredProcedure [dbo].[EFTR_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[EFTR_INSERT_S1]  
(
     @Ac_CheckRecipient_ID		 CHAR(10),
     @Ac_CheckRecipient_CODE		 CHAR(1),
     @An_EventGlobalBeginSeq_NUMB		 NUMERIC(19,0),
     @An_RoutingBank_NUMB		 NUMERIC(9,0),
     @Ac_AccountBankNo_TEXT		 CHAR(17),
     @Ac_TypeAccount_CODE		 CHAR(1),
     @Ad_PreNote_DATE			DATE,
     @Ad_FirstTransfer_DATE		DATE,
     @Ac_StatusEft_CODE		 	CHAR(2),
     @Ac_Reason_CODE                      CHAR(5)               
     
     
     )            
AS

/*
 *     PROCEDURE NAME    : EFTR_INSERT_S1
 *     DESCRIPTION       : Insert EFTI information into EFTR_Y1 table.
 *     DEVELOPED BY      : IMP Team.
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
   
   DECLARE
    @Ld_High_DATE  DATE ='12/31/9999',
	@Ld_Current_DATE  DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
	@Li_Zero_NUMB    SMALLINT=0,
	@Lc_Space_TEXT   CHAR(1)=' ';
   
      INSERT EFTR_Y1(
         CheckRecipient_ID, 
         CheckRecipient_CODE, 
         RoutingBank_NUMB, 
         AccountBankNo_TEXT, 
         TypeAccount_CODE, 
         PreNote_DATE, 
         FirstTransfer_DATE, 
         EftStatus_DATE, 
         StatusEft_CODE, 
         Reason_CODE, 
         Function_CODE, 
         Misc_ID, 
         EventGlobalBeginSeq_NUMB, 
         EventGlobalEndSeq_NUMB, 
         BeginValidity_DATE, 
         EndValidity_DATE
         )
      SELECT @Ac_CheckRecipient_ID, 
            @Ac_CheckRecipient_CODE, 
            @An_RoutingBank_NUMB, 
            @Ac_AccountBankNo_TEXT, 
            @Ac_TypeAccount_CODE, 
            @Ad_PreNote_DATE, 
            @Ad_FirstTransfer_DATE, 
            @Ld_Current_DATE, 
            @Ac_StatusEft_CODE, 
            @Ac_Reason_CODE, 
            @Lc_Space_TEXT,
            @Lc_Space_TEXT,
            @An_EventGlobalBeginSeq_NUMB, 
            @Li_Zero_NUMB,
            @Ld_Current_DATE,
            @Ld_High_DATE           
            WHERE NOT EXISTS (SELECT 1 FROM EFTR_Y1 WITH (Readuncommitted ) WHERE  CheckRecipient_ID=@Ac_CheckRecipient_ID AND CheckRecipient_CODE=@Ac_CheckRecipient_CODE );

                  
END;--End of EFTR_INSERT_S1


GO
