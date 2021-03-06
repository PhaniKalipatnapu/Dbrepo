/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S6](
     @Ad_Batch_DATE		DATE, 
     @Ac_SourceBatch_CODE		 CHAR(3),  
     @An_Batch_NUMB              NUMERIC(4,0),  
     @An_SeqReceipt_NUMB		 NUMERIC(6,0) 
     )  
AS 
/*  
 *     PROCEDURE NAME    : DSBH_RETRIEVE_S6  
 *     DESCRIPTION       : It Retrives the Disbursment Cheque Details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  BEGIN 
      
      DECLARE
         @Lc_MediumDisburseB_CODE	CHAR(1)	= 'B', 
		 @Lc_MediumDisburseE_CODE	CHAR(1)	= 'E', 	
		 @Lc_StatusCheckCa_CODE     CHAR(2)	= 'CA',           
         @Lc_StatusCheckOu_CODE     CHAR(2)	= 'OU',           
         @Lc_StatusCheckP2_CODE     CHAR(2)	= 'P2',           
         @Lc_StatusCheckPs_CODE     CHAR(2)	= 'PS',           
         @Lc_StatusCheckSe_CODE     CHAR(2)	= 'SE',           
         @Lc_StatusCheckSn_CODE     CHAR(2)	= 'SN',           
         @Lc_StatusCheckTr_CODE     CHAR(2)	= 'TR',           
         @Lc_StatusCheckVn_CODE     CHAR(2)	= 'VN',
         @Ld_High_DATE            	DATE	= '12/31/9999';           
                                                                     
     SELECT  l.CheckRecipient_ID ,  
         l.Disburse_DATE ,   
         l.Case_IDNO ,
         SUM(l.Disburse_AMNT) AS Disburse_AMNT,  
         dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(h.CheckRecipient_ID, h.CheckRecipient_CODE) AS RecipientName_TEXT,
         CASE WHEN h.MediumDisburse_CODE IN (@Lc_MediumDisburseB_CODE, @Lc_MediumDisburseE_CODE)
				THEN CAST(h.Misc_ID AS NUMERIC(11)) 
				ELSE h.Check_NUMB
		 END Check_NUMB,
         h.StatusCheck_CODE , 
         h.ReasonStatus_CODE,
         h.Misc_ID
     FROM DSBL_Y1 l
		JOIN DSBH_Y1 h 
          ON l.CheckRecipient_ID = h.CheckRecipient_ID 
          AND l.CheckRecipient_CODE = h.CheckRecipient_CODE 
          AND l.Disburse_DATE = h.Disburse_DATE 
          AND l.DisburseSeq_NUMB = h.DisburseSeq_NUMB  
     WHERE l.Batch_DATE = @Ad_Batch_DATE 
       AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE 
       AND l.Batch_NUMB = @An_Batch_NUMB 
       AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
       AND h.EndValidity_DATE = @Ld_High_DATE 
       AND  h.StatusCheck_CODE IN (  @Lc_StatusCheckOu_CODE, @Lc_StatusCheckVn_CODE,@Lc_StatusCheckSn_CODE, @Lc_StatusCheckTr_CODE,@Lc_StatusCheckCa_CODE,@Lc_StatusCheckP2_CODE,@Lc_StatusCheckSe_CODE,@Lc_StatusCheckPs_CODE )  
      GROUP BY   
         l.Disburse_DATE,   
         l.Case_IDNO,   
         l.CheckRecipient_ID,   
         dbo.BATCH_COMMON$SF_GET_RECIPIENT_NAME(h.CheckRecipient_ID, h.CheckRecipient_CODE),
         h.MediumDisburse_CODE,
         h.Check_NUMB,
         h.Misc_ID, 
         h.StatusCheck_CODE,   
         h.ReasonStatus_CODE;
         
  END; --End of DSBH_RETRIEVE_S6 
  

GO
