/****** Object:  StoredProcedure [dbo].[DCRS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCRS_INSERT_S1] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_RoutingBank_NUMB         NUMERIC(9, 0),
 @Ac_AccountBankNo_TEXT       CHAR(17),
 @An_DebitCard_NUMB           NUMERIC(16, 0),
 @Ac_Status_CODE              CHAR(1),
 @Ac_Reason_CODE              CHAR(2)
 )
AS
 /*
 *     PROCEDURE NAME    : DCRS_INSERT_S1
  *     DESCRIPTION       : Inserts new record into the debit card recipients.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB    SMALLINT = 0,
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_Yes_INDC     CHAR(1) = 'Y',
          @Ld_High_DATE    DATE = '12/31/9999';

  INSERT DCRS_Y1
         (CheckRecipient_ID,
          RoutingBank_NUMB,
          AccountBankNo_TEXT,
          DebitCard_NUMB,
          Status_DATE,
          Status_CODE,
          Reason_CODE,
          ManualInitFlag_INDC,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE)
  VALUES ( @Ac_CheckRecipient_ID,
           @An_RoutingBank_NUMB,
           @Ac_AccountBankNo_TEXT,
           @An_DebitCard_NUMB,
           @Ld_Current_DATE,
           @Ac_Status_CODE,
           @Ac_Reason_CODE,
           @Lc_Yes_INDC,
           @An_EventGlobalBeginSeq_NUMB,
           @Li_Zero_NUMB,
           @Ld_Current_DATE,
           @Ld_High_DATE );
 END; --End of DCRS_INSERT_S1

GO
