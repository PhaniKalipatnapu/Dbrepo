/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S15]
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ac_CheckRecipient_ID   CHAR(10)
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S15
  *     DESCRIPTION       : Retrieves the Disbursement Details
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB				INT		= 0,
		  @Lc_MediumDisburseB_CODE	CHAR(1)	= 'B', 
		  @Lc_MediumDisburseE_CODE	CHAR(1)	= 'E', 	
		  @Ld_High_DATE				DATE	= '12/31/9999';

  SELECT a.MediumDisburse_CODE,
         CASE WHEN a.MediumDisburse_CODE IN (@Lc_MediumDisburseB_CODE, @Lc_MediumDisburseE_CODE)
			THEN CAST(a.Misc_ID AS NUMERIC(11))
			ELSE a.Check_NUMB
		 END Check_NUMB,
         a.StatusCheck_DATE AS Disburse_DATE,
         a.StatusCheck_CODE,
         a.Disburse_AMNT,
		 ISNULL((SELECT TOP 1 b.Check_NUMB
			   FROM DSBC_Y1 AS x,
					DSBH_Y1 AS b
			 WHERE x.CheckRecipientOrig_ID = a.CheckRecipient_ID
				AND x.CheckRecipientOrig_CODE = a.CheckRecipient_CODE
				AND x.DisburseOrig_DATE =a.Disburse_DATE
				AND x.DisburseOrigSeq_NUMB = a.DisburseSeq_NUMB
				AND b.CheckRecipient_ID = x.CheckRecipient_ID
				AND b.CheckRecipient_CODE = x.CheckRecipient_CODE
				AND b.Disburse_DATE = x.Disburse_DATE
				AND b.DisburseSeq_NUMB = x.DisburseSeq_NUMB
				AND b.EndValidity_DATE =  @Ld_High_DATE
				AND b.Check_NUMB != @Li_Zero_NUMB	
		 ), @Li_Zero_NUMB) AS CheckReplace_NUMB,
         a.DisburseSeq_NUMB,
         b.Worker_ID,
         a.CheckRecipient_ID,
         a.CheckRecipient_CODE
    FROM DSBH_Y1 a,
         GLEV_Y1 b
   WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND a.Disburse_DATE = @Ad_Disburse_DATE
     AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalSeq_NUMB;
 END


GO
