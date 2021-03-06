/****** Object:  StoredProcedure [dbo].[EFTR_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EFTR_INSERT_S2] (
 @Ac_CheckRecipient_ID        CHAR(10),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : EFTR_INSERT_S2
  *     DESCRIPTION       : Insert EFTI information into EFTR_Y1 table.
  *     DEVELOPED BY      : IMP Team.
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CheckRecipient_CODE  CHAR(1) = '1',
          @Lc_StatusEftExempt_CODE CHAR(2) = 'EX',
          @Ld_Current_DATE         DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Li_Zero_NUMB            SMALLINT=0,
          @Lc_Zero_TEXT            CHAR(1)='0',
          @Lc_Space_TEXT           CHAR(1)=' ',
          @Ld_High_DATE            DATE ='12/31/9999',
          @Ld_Low_DATE             DATE ='01/01/0001';

  INSERT EFTR_Y1
         (CheckRecipient_ID,
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
          EndValidity_DATE)
  VALUES ( @Ac_CheckRecipient_ID,
           @Lc_CheckRecipient_CODE,
           @Li_Zero_NUMB,
           @Lc_Zero_TEXT,
           @Lc_Space_TEXT,
           @Ld_Low_DATE,
           @Ld_Low_DATE,
           @Ld_Current_DATE,
           @Lc_StatusEftExempt_CODE,
           @Lc_Space_TEXT,
           @Lc_Space_TEXT,
           @Lc_Space_TEXT,
           @An_EventGlobalBeginSeq_NUMB,
           @Li_Zero_NUMB,
           @Ld_Current_DATE,
           @Ld_High_DATE );
 END; --End of EFTR_INSERT_S2

GO
