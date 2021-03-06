/****** Object:  StoredProcedure [dbo].[LWEL_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LWEL_RETRIEVE_S21](
 @Ad_Batch_DATE          DATE,
 @Ac_SourceBatch_CODE    CHAR(3),
 @An_Batch_NUMB          NUMERIC(4,0),
 @An_SeqReceipt_NUMB     NUMERIC(6,0),
 @An_EventGlobalSeq_NUMB NUMERIC(19,0)
 )
AS
 /*
  *     PROCEDURE NAME    : LWEL_RETRIEVE_S21
  *     DESCRIPTION       : This Procedure is used to populate data for 'TANF Distribution Details'. 
                            The TANF Distribution Details pop-up view displays the IV-A distribution of a receipt.
                            Details displayed include the receipt, the TANF Referral Number, the obligation to
                            which the receipt was distributed, the IV-A month, the disbursement type and the
                            amount distributed.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 12/10/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT DISTINCT LW.CaseWelfare_IDNO
    FROM LWEL_Y1 LW
   WHERE LW.Batch_DATE = @Ad_Batch_DATE
     AND LW.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND LW.Batch_NUMB = @An_Batch_NUMB
     AND LW.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND LW.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;
     
 END; --End Of Procedure LWEL_RETRIEVE_S21 


GO
