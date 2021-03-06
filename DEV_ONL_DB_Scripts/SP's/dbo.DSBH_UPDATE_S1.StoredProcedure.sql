/****** Object:  StoredProcedure [dbo].[DSBH_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_UPDATE_S1] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @Ac_CheckRecipient_CODE      CHAR(1),
 @Ad_Disburse_DATE            DATE,
 @An_DisburseSeq_NUMB         NUMERIC(4),
 @Ac_StatusCheck_CODE         CHAR(2),
 @Ac_ReasonStatus_CODE        CHAR(2),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19),
 @An_EventGlobalEndSeq_NUMB   NUMERIC(19)
 )
AS
 /*  
  *     PROCEDURE NAME    : DSBH_UPDATE_S1  
  *     DESCRIPTION       : Updates disbursement details for the given recipient.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02/19/2012  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Li_Zero_NUMB			INT				= 0,
		  @Ld_High_DATE			DATE			= '12/31/9999';
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_Current_DATE      DATE			= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DSBH_Y1
     SET EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         EndValidity_DATE = @Ld_Current_DATE
	OUTPUT	DELETED.CheckRecipient_ID, 
			DELETED.CheckRecipient_CODE, 
			DELETED.Disburse_DATE, 
			DELETED.DisburseSeq_NUMB, 
			DELETED.MediumDisburse_CODE, 
			DELETED.Disburse_AMNT, 
			DELETED.Check_NUMB, 
			@Ac_StatusCheck_CODE, 
			@Ld_Current_DATE, 
			@Ac_ReasonStatus_CODE, 
			@An_EventGlobalEndSeq_NUMB, 
			@Li_Zero_NUMB, 
			@Ld_Current_DATE, 
			DELETED.EndValidity_DATE, 
			DELETED.Issue_DATE, 
			DELETED.Misc_ID
		INTO DSBH_Y1 
   WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND Disburse_DATE = @Ad_Disburse_DATE
     AND DisburseSeq_NUMB = @An_DisburseSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE
     AND EXISTS ( SELECT 1
				   FROM DSBH_Y1 a WITH(READUNCOMMITTED) 
				  WHERE a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
					 AND a.Disburse_DATE = @Ad_Disburse_DATE
					 AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
					 AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
					 AND a.EndValidity_DATE = @Ld_High_DATE )

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END


GO
