/****** Object:  StoredProcedure [dbo].[DSBC_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBC_RETRIEVE_S1] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ai_Count_QNTY         SMALLINT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBC_RETRIEVE_S1
  *     DESCRIPTION       : Checks if the corresponding check has already gone through P1 or not.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET  @Ai_Count_QNTY  = NULL;

  DECLARE @Ld_Highdate                               DATE = '31-DEC-9999',
          @Lc_ReturnFromPostOffice_ReasonStatus_CODE CHAR(2) = 'RP',
          @Lc_Void_ReissueStatusCheck_CODE           CHAR(2) = 'VR';

  SELECT TOP 1  @Ai_Count_QNTY  = 1
    FROM DSBC_Y1 a,
         DSBH_Y1 b
   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND a.Disburse_DATE = @Ad_Disburse_DATE
     AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
     AND b.CheckRecipient_ID = a.CheckRecipientOrig_ID
     AND b.CheckRecipient_CODE = a.CheckRecipientOrig_CODE
     AND b.Disburse_DATE = a.DisburseOrig_DATE
     AND b.DisburseSeq_NUMB = a.DisburseOrigSeq_NUMB
     AND b.StatusCheck_CODE = @Lc_Void_ReissueStatusCheck_CODE
     AND b.ReasonStatus_CODE = @Lc_ReturnFromPostOffice_ReasonStatus_CODE
     AND b.EndValidity_DATE = @Ld_Highdate;
 END


GO
