/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S18](
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4,0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19,0),
 @Ac_MediumDisburse_CODE CHAR(1)		OUTPUT,
 @Ad_StatusCheck_DATE    DATE			OUTPUT,
 @Ac_StatusCheck_CODE    CHAR(2)		OUTPUT,
 @An_Disburse_AMNT       NUMERIC(11,2)  OUTPUT,
 @An_Check_NUMB          NUMERIC(19,0)  OUTPUT,
 @Ac_Recipient_NAME      CHAR(40)		OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S18
  *     DESCRIPTION       : This Procedure populates data for Disbursement View Details pop-up view displays
                            the disbursement details of the check, EFT and Stored Value Card and disbursement
                            status by Funds Recipient ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/09/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  DECLARE @Lc_MediumDisburseB_CODE	CHAR(1)	= 'B', 
		  @Lc_MediumDisburseE_CODE	CHAR(1)	= 'E'; 	
		 

  SELECT @An_Check_NUMB			 = CASE WHEN DIH.MediumDisburse_CODE IN (@Lc_MediumDisburseB_CODE, @Lc_MediumDisburseE_CODE)
										THEN CAST(DIH.Misc_ID AS NUMERIC(11)) 
										ELSE DIH.Check_NUMB
								   END,
         @Ac_Recipient_NAME		 = dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(@Ac_CheckRecipient_ID, @Ac_CheckRecipient_CODE),
         @Ac_StatusCheck_CODE	 = DIH.StatusCheck_CODE,
         @Ad_StatusCheck_DATE	 = DIH.Issue_DATE,
         @Ac_MediumDisburse_CODE = DIH.MediumDisburse_CODE,
         @An_Disburse_AMNT		 = DIH.Disburse_AMNT
    FROM DSBH_Y1 DIH
   WHERE DIH.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND DIH.CheckRecipient_ID		  = @Ac_CheckRecipient_ID
     AND DIH.CheckRecipient_CODE      = @Ac_CheckRecipient_CODE
     AND DIH.DisburseSeq_NUMB         = @An_DisburseSeq_NUMB
     AND DIH.Disburse_DATE            = @Ad_Disburse_DATE;
     
 END; --End Of Procedure DSBH_RETRIEVE_S18 


GO
