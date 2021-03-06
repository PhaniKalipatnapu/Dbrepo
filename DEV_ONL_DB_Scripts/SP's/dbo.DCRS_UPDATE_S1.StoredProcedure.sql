/****** Object:  StoredProcedure [dbo].[DCRS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCRS_UPDATE_S1] (
 @Ac_CheckRecipient_ID      CHAR(10),
 @An_RoutingBank_NUMB       NUMERIC(9, 0),
 @Ac_AccountBankNo_TEXT     CHAR(17),
 @An_DebitCard_NUMB         NUMERIC(16, 0),
 @Ac_Status_CODE            CHAR(1),
 @Ac_Reason_CODE            CHAR(2),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : DCRS_UPDATE_S1
  *     DESCRIPTION       : Logically deletes the valid record for the given check recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DCRS_Y1
     SET Status_DATE = @Ld_Current_DATE,
         Status_CODE = @Ac_Status_CODE,
         Reason_CODE = @Ac_Reason_CODE,
         RoutingBank_NUMB = @An_RoutingBank_NUMB,
         AccountBankNo_TEXT = @Ac_AccountBankNo_TEXT,
         DebitCard_NUMB = @An_DebitCard_NUMB,
         EventGlobalBeginSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         BeginValidity_DATE = @Ld_Current_DATE
  OUTPUT Deleted.CheckRecipient_ID,
         Deleted.RoutingBank_NUMB,
         Deleted.AccountBankNo_TEXT,
         Deleted.Status_DATE,
         Deleted.Status_CODE,
         Deleted.Reason_CODE,
         Deleted.ManualInitFlag_INDC,
         Deleted.EventGlobalBeginSeq_NUMB,
         @An_EventGlobalEndSeq_NUMB AS EventGlobalEndSeq_NUMB,
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         Deleted.DebitCard_NUMB
  INTO DCRS_Y1
   WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End of DCRS_UPDATE_S1

GO
