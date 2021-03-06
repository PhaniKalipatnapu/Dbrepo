/****** Object:  StoredProcedure [dbo].[EFTR_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[EFTR_UPDATE_S2]  
(
  
     @Ac_CheckRecipient_ID			CHAR(10),
     @Ac_CheckRecipient_CODE		CHAR(1),
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @An_RoutingBank_NUMB			NUMERIC(9,0),
     @Ac_AccountBankNo_TEXT			CHAR(17),
     @Ac_TypeAccount_CODE			CHAR(1),
     @Ad_PreNote_DATE				DATE,
     @Ad_FirstTransfer_DATE			DATE,
     @Ac_StatusEft_CODE				CHAR(2),
     @Ac_Reason_CODE                CHAR(5)               ,
     @An_EventGlobalEndSeq_NUMB		NUMERIC(19,0)
 )
          
AS

/*
 *     PROCEDURE NAME    : EFTR_UPDATE_S2
 *     DESCRIPTION       : This procedure is used to save  the EFTI information into veftr table.It is only used when the worker needs to manually update  the current Electronic
                    	   Funds Transfer disbursements status for a FIPS or Other Agency.  The majority of EFT processing is automated and updates to the existing status are generally entered
                    	   by the system during the application batch processing, however, sometimes manual processing is necessary. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
   
   DECLARE 
    @Ld_High_DATE  DATE ='12/31/9999',
	@Ld_Current_DATE  DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
	@Lc_Space_TEXT   CHAR(1)=' '; 
   
      UPDATE EFTR_Y1
         SET RoutingBank_NUMB = @An_RoutingBank_NUMB,
			AccountBankNo_TEXT = @Ac_AccountBankNo_TEXT,
			TypeAccount_CODE = @Ac_TypeAccount_CODE,
			PreNote_DATE  = @Ad_PreNote_DATE,
			FirstTransfer_DATE = @Ad_FirstTransfer_DATE,
			EftStatus_DATE  = @Ld_Current_DATE,
			StatusEft_CODE =@Ac_StatusEft_CODE,
			Reason_CODE   =@Ac_Reason_CODE,
			Function_CODE =@Lc_Space_TEXT,
			Misc_ID = @Lc_Space_TEXT,
			BeginValidity_DATE  = @Ld_Current_DATE,
         	EventGlobalBeginSeq_NUMB = @An_EventGlobalEndSeq_NUMB
     OUTPUT Deleted.CheckRecipient_ID,
			Deleted.CheckRecipient_CODE,
			Deleted.RoutingBank_NUMB,
			Deleted.AccountBankNo_TEXT,
			Deleted.TypeAccount_CODE,
			Deleted.PreNote_DATE,
			Deleted.FirstTransfer_DATE,
			Deleted.EftStatus_DATE,
			Deleted.StatusEft_CODE,
			Deleted.Reason_CODE,
			Deleted.Function_CODE,
			Deleted.Misc_ID,
			Deleted.EventGlobalBeginSeq_NUMB,
			@An_EventGlobalEndSeq_NUMB AS EventGlobalEndSeq_NUMB,
			Deleted. BeginValidity_DATE, 
			@Ld_Current_DATE AS EndValidity_DATE
			
		INTO 
		  EFTR_Y1
      WHERE 
		  CheckRecipient_ID = @Ac_CheckRecipient_ID 
	  AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
	  AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB 
	  AND EndValidity_DATE = @Ld_High_DATE;
      
      
         
      
     DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;   
                                                      
    SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
   
END;--End of EFTR_UPDATE_S2


GO
