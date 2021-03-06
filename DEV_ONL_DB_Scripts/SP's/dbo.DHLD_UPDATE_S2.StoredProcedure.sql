/****** Object:  StoredProcedure [dbo].[DHLD_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_UPDATE_S2] (
 @An_Case_IDNO              NUMERIC(6),
 @Ac_CheckRecipient_ID		CHAR(10),
 @Ac_ReasonStatus_CODE      CHAR(4),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19)
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_UPDATE_S2  
  *     DESCRIPTION       : Updates DHLD_Y1 for the given Disbursement Hold instruction. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 28-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB				NUMERIC(10),
          @Lc_CheckRecipientCpNcp_CODE		CHAR(1)		= '1',
          @Lc_StatusHeld_CODE				CHAR(1)		= 'H',
          @Lc_StatusReady_CODE				CHAR(1)		= 'R',
          @Ld_High_DATE						DATE		= '12/31/9999',
          @Ld_Current_DATE					DATE		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
          

  UPDATE DHLD_Y1
     SET EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         EndValidity_DATE = @Ld_Current_DATE
   WHERE Case_IDNO = @An_Case_IDNO
	 AND CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND CheckRecipient_CODE  = @Lc_CheckRecipientCpNcp_CODE
     AND EndValidity_DATE = @Ld_High_DATE
     AND (Status_CODE = @Lc_StatusReady_CODE
           OR (Status_CODE = @Lc_StatusHeld_CODE
               AND ReasonStatus_CODE = @Ac_ReasonStatus_CODE));

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of   DHLD_UPDATE_S2

GO
