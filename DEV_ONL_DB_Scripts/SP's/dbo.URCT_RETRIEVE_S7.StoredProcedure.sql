/****** Object:  StoredProcedure [dbo].[URCT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[URCT_RETRIEVE_S7] (
 @Ad_Batch_DATE       DATE,
 @An_Batch_NUMB       NUMERIC(4, 0),
 @An_SeqReceipt_NUMB  NUMERIC(6, 0),
 @Ac_SourceBatch_CODE CHAR(3)
 )
AS
 /*  
  *     PROCEDURE NAME    : URCT_RETRIEVE_S7 
  *     DESCRIPTION       : Retrieve depositor and bank details for an unidentified receipt.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Lc_ReasonStatusUsrp_CODE          CHAR(4) = 'USRP';

  SELECT a.EventGlobalBeginSeq_NUMB,
         a.SourceReceipt_CODE,
         a.Payor_NAME,
         a.PayorLine1_ADDR,
         a.PayorLine2_ADDR,
         a.PayorCity_ADDR,
         a.PayorState_ADDR,
         a.PayorZip_ADDR,
         a.PayorCountry_ADDR,
         a.Bank_NAME,
         a.Bank1_ADDR,
         a.Bank2_ADDR,
         a.BankCity_ADDR,
         a.BankState_ADDR,
         a.BankZip_ADDR,
         a.Bank_IDNO,
         a.BankAcct_NUMB,
         a.Remarks_TEXT,
         a.UnidentifiedMemberMci_IDNO,
         a.UnidentifiedSsn_NUMB,
         a.ReasonStatus_CODE,
         a.ReasonBackOut_CODE,
         a.RefundRecipient_CODE,
         a.RefundRecipient_ID,
         a.OtherParty_IDNO,
         a.OtherParty_NAME,
         a.Worker_ID
    FROM (SELECT g.Worker_ID,
                 u.SourceReceipt_CODE,
                 u.Remarks_TEXT,
                 u.UnidentifiedMemberMci_IDNO,
                 u.UnidentifiedSsn_NUMB,
                 r.ReasonStatus_CODE,
                 u.Payor_NAME,
                 u.PayorLine1_ADDR,
                 u.PayorLine2_ADDR,
                 u.PayorCity_ADDR,
                 u.PayorState_ADDR,
                 u.PayorZip_ADDR,
                 u.PayorCountry_ADDR,
                 o.OtherParty_IDNO,
                 o.OtherParty_NAME,
                 u.Bank_IDNO,
                 u.BankAcct_NUMB,
                 u.Bank_NAME,
                 u.Bank1_ADDR,
                 u.Bank2_ADDR,
                 u.BankCity_ADDR,
                 u.BankState_ADDR,
                 u.BankZip_ADDR,
                 r.ReasonBackOut_CODE,
                 r.RefundRecipient_CODE,
                 r.RefundRecipient_ID,
                 u.EventGlobalBeginSeq_NUMB,
                 ROW_NUMBER() OVER( ORDER BY u.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
            FROM RCTH_Y1 r
                 JOIN URCT_Y1 u
                  ON u.Batch_DATE = r.Batch_DATE
                     AND u.SourceBatch_CODE = r.SourceBatch_CODE
                     AND u.Batch_NUMB = r.Batch_NUMB
                     AND u.SeqReceipt_NUMB = r.SeqReceipt_NUMB
                 LEFT OUTER JOIN OTHP_Y1 o
                  ON o.OtherParty_IDNO = u.OtherParty_IDNO
                 JOIN GLEV_Y1 g
                  ON g.EventGlobalSeq_NUMB = r.EventGlobalBeginSeq_NUMB
           WHERE r.Batch_DATE = @Ad_Batch_DATE
             AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
             AND r.Batch_NUMB = @An_Batch_NUMB
             AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
             AND r.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
             AND r.ReasonStatus_CODE = @Lc_ReasonStatusUsrp_CODE
             AND r.Distribute_DATE = @Ld_Low_DATE
             AND u.Batch_DATE = @Ad_Batch_DATE
             AND u.SourceBatch_CODE = @Ac_SourceBatch_CODE
             AND u.Batch_NUMB = @An_Batch_NUMB
             AND u.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
             AND r.EndValidity_DATE = @Ld_High_DATE
             AND u.EndValidity_DATE = @Ld_High_DATE) AS a;
 END -- End of URCT_RETRIEVE_S7

GO
