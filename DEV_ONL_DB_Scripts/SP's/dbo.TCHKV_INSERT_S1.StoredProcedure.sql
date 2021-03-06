/****** Object:  StoredProcedure [dbo].[TCHKV_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TCHKV_INSERT_S1]
 @An_Check_NUMB          NUMERIC(19),
 @Ad_Disburse_DATE       DATE,
 @Ac_StatusCheck_CODE    CHAR(2),
 @An_Disburse_AMNT       NUMERIC(11, 2),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_Worker_ID           CHAR(30),
 @An_CheckReplace_NUMB   NUMERIC(13),
 @Ac_MediumDisburse_CODE CHAR(1)
AS
 /*
  *     PROCEDURE NAME    : TCHKV_INSERT_S1
  *     DESCRIPTION       : Adds the disbursement tracking details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  INSERT TCHKV_Y1
         (Check_NUMB,
          Disburse_DATE,
          StatusCheck_CODE,
          Disburse_AMNT,
          CheckRecipient_ID,
          CheckRecipient_CODE,
          Worker_ID,
          CheckReplace_NUMB,
          MediumDisburse_CODE)
  VALUES ( @An_Check_NUMB,
           @Ad_Disburse_DATE,
           @Ac_StatusCheck_CODE,
           @An_Disburse_AMNT,
           @Ac_CheckRecipient_ID,
           @Ac_CheckRecipient_CODE,
           @Ac_Worker_ID,
           @An_CheckReplace_NUMB,
           @Ac_MediumDisburse_CODE);
 END


GO
