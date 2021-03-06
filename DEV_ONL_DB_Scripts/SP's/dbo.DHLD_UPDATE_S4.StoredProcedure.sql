/****** Object:  StoredProcedure [dbo].[DHLD_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_UPDATE_S4] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ad_Release_DATE             DATE,
 @Ac_CheckRecipient_ID        CHAR(10),
 @Ac_ReasonStatus_CODE        CHAR(4),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_UPDATE_S4  
  *     DESCRIPTION       : Updates the Disbursement Hold Status for the given Case IDNO   
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 24-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_Current_DATE      DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10),
          @Lc_StatusHeld_CODE   CHAR(1) = 'H',
          @Lc_StatusReady_CODE  CHAR(1) = 'R',
          @Ld_High_DATE         DATE ='12/31/9999';

  UPDATE DHLD_Y1
     SET Release_DATE = @Ad_Release_DATE,
         Status_CODE = @Lc_StatusHeld_CODE,
         ReasonStatus_CODE = @Ac_ReasonStatus_CODE
   WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND Case_IDNO = @An_Case_IDNO
     AND Status_CODE = @Lc_StatusReady_CODE
     AND BeginValidity_DATE = @Ld_Current_DATE
     AND EndValidity_DATE = @Ld_High_DATE
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of   DHLD_UPDATE_S4

GO
