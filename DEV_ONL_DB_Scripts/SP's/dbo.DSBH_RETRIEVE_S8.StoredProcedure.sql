/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S8] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_MediumDisburse_CODE CHAR(1) OUTPUT,
 @Ad_StatusCheck_DATE    DATE OUTPUT,
 @An_Disburse_AMNT       NUMERIC(11, 2) OUTPUT,
 @Ac_StatusCheck_CODE    CHAR(2) OUTPUT,
 @An_Check_NUMB          NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S8
  *     DESCRIPTION       : Retrieves the check details for the recipient.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 07-FEB-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

  DECLARE @Lc_MediumDisburseB_CODE	CHAR(1)	= 'B', 
		  @Lc_MediumDisburseE_CODE	CHAR(1)	= 'E', 	
		  @Ld_High_DATE             DATE	= '12/31/9999';

  SELECT @An_Check_NUMB = CASE WHEN a.MediumDisburse_CODE IN (@Lc_MediumDisburseB_CODE, @Lc_MediumDisburseE_CODE)
								THEN CAST(a.Misc_ID AS NUMERIC(11)) 
								ELSE a.Check_NUMB
						   END,
		 @Ac_StatusCheck_CODE = a.StatusCheck_CODE,
         @Ad_StatusCheck_DATE = a.StatusCheck_DATE,
         @Ac_MediumDisburse_CODE = a.MediumDisburse_CODE,
         @An_Disburse_AMNT = a.Disburse_AMNT
    FROM DSBH_Y1 a
   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND a.Disburse_DATE = @Ad_Disburse_DATE
     AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END


GO
