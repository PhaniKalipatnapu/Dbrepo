/****** Object:  StoredProcedure [dbo].[DEFT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEFT_RETRIEVE_S1] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_AccountBankNo_TEXT  CHAR(17) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DEFT_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves account number, status code, status date, reason code for the given check recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-FEB -2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_AccountBankNo_TEXT = NULL;

  SELECT TOP 1 @Ac_AccountBankNo_TEXT = D.AccountBankNo_TEXT
    FROM DEFT_Y1 D
   WHERE D.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND D.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND D.Disburse_DATE = @Ad_Disburse_DATE
     AND D.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;
 END


GO
