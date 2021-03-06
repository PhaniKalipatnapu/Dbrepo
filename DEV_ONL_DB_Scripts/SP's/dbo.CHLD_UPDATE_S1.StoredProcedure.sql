/****** Object:  StoredProcedure [dbo].[CHLD_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CHLD_UPDATE_S1] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @An_EventGlobalEndSeq_NUMB   NUMERIC(19, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_Sequence_NUMB            NUMERIC(11, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : CHLD_UPDATE_S1  
  *     DESCRIPTION       : Updates the endvalidity date, event global end sequence number in the Cphold table.  
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 20-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_Current_DATE      DATE = dbo. BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE CHLD_Y1
     SET EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         EndValidity_DATE = @Ld_Current_DATE
   WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND Sequence_NUMB = @An_Sequence_NUMB
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of CHLD_UPDATE_S1       

GO
