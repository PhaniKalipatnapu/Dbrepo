/****** Object:  StoredProcedure [dbo].[EFTR_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EFTR_UPDATE_S1] (
 @Ac_CheckRecipient_ID      CHAR(10),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : EFTR_UPDATE_S1
  *     DESCRIPTION       : Logically deletes the valid record for the given check recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CheckRecipientCpNcp_CODE CHAR(1) = '1',
          @Ld_High_DATE                DATE = '12/31/9999',
          @Ld_Current_DATE             DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_Zero_TEXT                CHAR(1) = '0',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Ld_Low_DATE                 DATE ='01/01/0001',
          @Lc_StatusEx_CODE            CHAR(2) = 'EX';

  UPDATE EFTR_Y1
     SET EventGlobalBeginSeq_NUMB = @An_EventGlobalEndSeq_NUMB,
         RoutingBank_NUMB = @Lc_Zero_TEXT,
         AccountBankNo_TEXT = @Lc_Zero_TEXT,
         TypeAccount_CODE = @Lc_Space_TEXT,
         PreNote_DATE = @Ld_Low_DATE,
         FirstTransfer_DATE = @Ld_Low_DATE,
         EftStatus_DATE = @Ld_Current_DATE,
         StatusEft_CODE = @Lc_StatusEx_CODE,
         Reason_CODE = @Lc_Space_TEXT,
         Function_CODE = @Lc_Space_TEXT,
         Misc_ID = @Lc_Space_TEXT,
         BeginValidity_DATE = @Ld_Current_DATE
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
         Deleted.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE
  INTO EFTR_Y1
   WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of EFTR_UPDATE_S1

GO
