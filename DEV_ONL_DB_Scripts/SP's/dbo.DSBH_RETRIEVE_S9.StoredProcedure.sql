/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S9] (
 @Ac_CheckRecipient_CODE      CHAR(1),
 @Ad_Disburse_DATE            DATE,
 @An_DisburseSeq_NUMB         NUMERIC(4),
 @Ac_CheckRecipient_ID        CHAR(10),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19),
 @An_Case_IDNO                NUMERIC(6) OUTPUT,
 @An_Check_NUMB               NUMERIC(19) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S9
  *     DESCRIPTION       : Retrieves the last disbursement made for the given recipient.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Ld_High_DATE		DATE = '12/31/9999';

  SELECT TOP 1 @An_Check_NUMB = a.Check_NUMB,
               @An_Case_IDNO = b.Case_IDNO
    FROM DSBH_Y1 a,
         DSBL_Y1 b
   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND a.Disburse_DATE = @Ad_Disburse_DATE
     AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
     AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.CheckRecipient_ID = b.CheckRecipient_ID
     AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
     AND a.Disburse_DATE = b.Disburse_DATE
     AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB;
 END


GO
