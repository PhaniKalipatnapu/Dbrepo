/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S23](
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4),
 @An_EventGlobalSeq_NUMB NUMERIC(19)
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S23
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
  DECLARE @Li_Zero_NUMB                        SMALLINT     =  0,
		  @Lc_DisburseMediumCpCheck_CODE       CHAR(1)		= 'C',
          @Lc_DisburseMediumDirectDeposit_CODE CHAR(1)		= 'D',
          @Lc_DisburseMediumFipseft_CODE       CHAR(1)		= 'E',
          @Lc_Hyphen_CODE                      CHAR(1)		= '-',
          @Lc_BMediumDisburse_CODE             CHAR(1)		= 'B',
          @Ld_High_DATE                        DATE         = '12/31/9999';
    
  SELECT X.Case_IDNO,
         X.TypeDisburse_CODE,
         x.Batch_DATE,
         x.SourceBatch_CODE,
         x.Batch_NUMB,
         x.SeqReceipt_NUMB,
         SUM(X.Disburse_AMNT) AS Disburse_AMNT,
         X.DescriptionNote_TEXT,
         X.ChkCtrl_NUMB
    FROM (SELECT x.Case_IDNO,
                 x.TypeDisburse_CODE,
                 x.Batch_DATE,
                 x.SourceBatch_CODE,
                 x.Batch_NUMB,
                 x.SeqReceipt_NUMB,
                 ISNULL(x.Disburse_AMNT, @Li_Zero_NUMB) AS Disburse_AMNT,
                 (SELECT UN.DescriptionNote_TEXT
                    FROM UNOT_Y1 UN
                   WHERE UN.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB) AS DescriptionNote_TEXT,
                 (SELECT MAX(CASE
                              WHEN b.MediumDisburse_CODE IN(@Lc_BMediumDisburse_CODE, @Lc_DisburseMediumFipseft_CODE)
                               THEN b.MediumDisburse_CODE + @Lc_Hyphen_CODE + b.Misc_ID
                              WHEN b.MediumDisburse_CODE IN (@Lc_DisburseMediumCpCheck_CODE, @Lc_DisburseMediumDirectDeposit_CODE)
                               THEN b.MediumDisburse_CODE + @Lc_Hyphen_CODE + CONVERT(CHAR(11), b.Check_NUMB)
                             END)
                    FROM DSBC_Y1 a
                         JOIN DSBH_Y1 b
                      ON b.CheckRecipient_ID	= a.CheckRecipientOrig_ID
                     AND b.CheckRecipient_CODE	= a.CheckRecipientOrig_CODE
                     AND b.Disburse_DATE		= a.DisburseOrig_DATE
                     AND b.DisburseSeq_NUMB		= a.DisburseOrigSeq_NUMB
                         JOIN DSBL_Y1 c 
                     ON  c.CheckRecipient_ID	= b.CheckRecipient_ID
                     AND c.CheckRecipient_CODE	= b.CheckRecipient_CODE
                     AND c.Disburse_DATE		= b.Disburse_DATE
                     AND c.DisburseSeq_NUMB		= b.DisburseSeq_NUMB
                   WHERE a.CheckRecipient_ID	= @Ac_CheckRecipient_ID
                     AND a.CheckRecipient_CODE	= @Ac_CheckRecipient_CODE
                     AND a.Disburse_DATE		= @Ad_Disburse_DATE
                     AND a.DisburseSeq_NUMB		= @An_DisburseSeq_NUMB
                     AND b.EndValidity_DATE		= @Ld_High_DATE
                     AND c.Case_IDNO			= x.Case_IDNO
                     AND c.OrderSeq_NUMB		= x.OrderSeq_NUMB
                     AND c.ObligationSeq_NUMB	= x.ObligationSeq_NUMB
                     AND c.Batch_DATE			= x.Batch_DATE
                     AND c.SourceBatch_CODE		= x.SourceBatch_CODE
                     AND c.Batch_NUMB			= x.Batch_NUMB
                     AND c.SeqReceipt_NUMB		= x.SeqReceipt_NUMB
                     AND c.EventGlobalSupportSeq_NUMB = x.EventGlobalSupportSeq_NUMB
                     AND c.TypeDisburse_CODE	= x.TypeDisburse_CODE) AS ChkCtrl_NUMB
            FROM DSBL_Y1  x
           WHERE x.CheckRecipient_ID	= @Ac_CheckRecipient_ID
             AND x.CheckRecipient_CODE	= @Ac_CheckRecipient_CODE
             AND x.Disburse_DATE		= @Ad_Disburse_DATE
             AND x.DisburseSeq_NUMB		= @An_DisburseSeq_NUMB)  X
   GROUP BY X.Case_IDNO,
            X.TypeDisburse_CODE,
            x.Batch_DATE,
            x.SourceBatch_CODE,
            x.Batch_NUMB,
            x.SeqReceipt_NUMB,
            X.DescriptionNote_TEXT,
            X.ChkCtrl_NUMB;
            
 END; --End Of Procedure DSBL_RETRIEVE_S23 


GO
