/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S5](
 @Ad_IssueFrom_DATE DATE,
 @Ad_IssueTo_DATE   DATE
 )
AS
 /*    
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S5    
  *     DESCRIPTION       : Retrieves the disbursement register summary.     
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-OCT-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Lc_CheckRecipient1_CODE			CHAR(1)		= '1',
		  @Lc_CheckRecipient2_CODE			CHAR(1)		= '2',
		  @Lc_CheckRecipient3_CODE			CHAR(1)		= '3',
		  @Lc_CheckRecipient4_CODE			CHAR(1)		= '4',
		  @Lc_CheckRecipient5_CODE			CHAR(1)		= '5',
		  @Lc_CheckRecipient6_CODE			CHAR(1)		= '6',
		  @Lc_StatusCheckOutstanding_CODE   CHAR(2)		= 'OU',
          @Lc_StatusCheckTransferEft_CODE   CHAR(2)		= 'TR',
          @Lc_SourceReceiptCr_CODE          CHAR(2)		= 'CR',
          @Lc_SourceReceiptCf_CODE          CHAR(2)		= 'CF',
          @Lc_TypeDisburseRefund_CODE       CHAR(5)		= 'REFND',
          @Lc_TypeDisburseRothp_CODE        CHAR(5)		= 'ROTHP',
          @Lc_TypeDisburseNormal_CODE       CHAR(6)		= 'NORMAL',
          @Lc_CheckRecipientOtherParty_CODE CHAR(10)	= '999999900',
          @Ld_High_DATE                     DATE		= '12/31/9999';
          

  SELECT d.CheckRecipient_CODE,
         d.MediumDisburse_CODE,
         d.StatusCheck_CODE,
         d.DisbursementType_CODE,
         SUM (d.Disburse_AMNT) TotalDisburse_AMNT,
         COUNT (DISTINCT(d.Misc_ID + CONVERT(CHAR(10), d.case_idno))) MiscCount_QNTY
    FROM (SELECT CASE
                  WHEN d.CheckRecipient_CODE = @Lc_CheckRecipient1_CODE
                       AND r.SourceReceipt_CODE IN (@Lc_SourceReceiptCr_CODE, @Lc_SourceReceiptCf_CODE)
                       AND d1.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                   THEN @Lc_CheckRecipient4_CODE
                  WHEN d.CheckRecipient_CODE = @Lc_CheckRecipient1_CODE
                       AND R.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCr_CODE, @Lc_SourceReceiptCf_CODE)
                       AND d1.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                   THEN @Lc_CheckRecipient5_CODE
                  WHEN d.CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
                       AND d.CheckRecipient_ID > @Lc_CheckRecipientOtherParty_CODE
                       AND d1.TypeDisburse_CODE IN (@Lc_TypeDisburseRefund_CODE, @Lc_TypeDisburseRothp_CODE)
                   THEN @Lc_CheckRecipient6_CODE
                  ELSE d.CheckRecipient_CODE
                 END CheckRecipient_CODE,
                 d.MediumDisburse_CODE,
                 d.StatusCheck_CODE,
                 CASE d1.TypeDisburse_CODE
                  WHEN @Lc_TypeDisburseRefund_CODE
                   THEN @Lc_TypeDisburseRefund_CODE
                  WHEN @Lc_TypeDisburseRothp_CODE
                   THEN @Lc_TypeDisburseRothp_CODE
                  ELSE @Lc_TypeDisburseNormal_CODE
                 END AS DisbursementType_CODE,
                 d1.Disburse_AMNT,
                 d.Misc_ID,
                 d1.Case_IDNO
            FROM DSBH_Y1 d
                 JOIN DSBL_Y1 d1
                  ON(d.CheckRecipient_ID = d1.CheckRecipient_ID
                     AND d.CheckRecipient_CODE = d1.CheckRecipient_CODE
                     AND d.Disburse_DATE = d1.Disburse_DATE
                     AND d.DisburseSeq_NUMB = d1.DisburseSeq_NUMB
                     AND d.EventGlobalBeginSeq_NUMB = d1.EventGlobalSeq_NUMB)
                 JOIN RCTH_Y1 r
                  ON(d1.Batch_DATE = r.Batch_DATE
                     AND d1.SourceBatch_CODE = r.SourceBatch_CODE
                     AND d1.Batch_NUMB = r.Batch_NUMB
                     AND d1.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                     AND r.EventGlobalBeginSeq_NUMB = d1.EventGlobalSupportSeq_NUMB)
           WHERE d.Issue_DATE BETWEEN @Ad_IssueFrom_DATE AND @Ad_IssueTo_DATE
             AND d.StatusCheck_CODE IN (@Lc_StatusCheckOutstanding_CODE, @Lc_StatusCheckTransferEft_CODE)
             AND r.EndValidity_DATE = @Ld_High_DATE) d
   GROUP BY d.CheckRecipient_CODE,
            d.MediumDisburse_CODE,
            d.StatusCheck_CODE,
            d.DisbursementType_CODE;
 END; --End Of DSBH_RETRIEVE_S5  

GO
