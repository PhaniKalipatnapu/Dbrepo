/****** Object:  StoredProcedure [dbo].[RECP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RECP_UPDATE_S1] (
 @Ac_CheckRecipient_CODE	CHAR(1),
 @Ac_CheckRecipient_ID		CHAR(10),
 @An_EventGlobalEndSeq_NUMB	NUMERIC(19,0)
 )      
AS
 /*
  *     PROCEDURE NAME    : RECP_UPDATE_S1
  *     DESCRIPTION       : Update the recoupment percentage and it will be set across all cases at the same level.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
  		  @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),	
  		  @Ln_RowsAffected_NUMB	NUMERIC(10);
   
      UPDATE RECP_Y1
         SET EndValidity_DATE = @Ld_Current_DATE,   
             EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB 
       WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
         AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
         AND EndValidity_DATE = @Ld_High_DATE;
      
    SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

	SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB; 

END;  --END OF RECP_UPDATE_S1

GO
