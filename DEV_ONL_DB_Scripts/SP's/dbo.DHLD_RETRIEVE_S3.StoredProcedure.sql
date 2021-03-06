/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S3] (
 @An_Case_IDNO                  NUMERIC(6, 0),
 @An_OrderSeq_NUMB              NUMERIC(2, 0),
 @An_ObligationSeq_NUMB         NUMERIC(2, 0),
 @An_Unique_IDNO                NUMERIC(19, 0),
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4, 0),
 @An_SeqReceipt_NUMB            NUMERIC(6, 0),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19, 0),
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19, 0),
 @An_Transaction_AMNT           NUMERIC(11, 2) OUTPUT,
 @Ac_TypeHold_CODE              CHAR(1) OUTPUT,
 @Ac_ReasonStatus_CODE          CHAR(4) OUTPUT,
 @Ad_Disburse_DATE              DATE OUTPUT,
 @An_DisburseSeq_NUMB           NUMERIC(4, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S3
  *     DESCRIPTION       : Retrieves LogDisbursementHold Details for the given Recipient ID
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_TypeHold_CODE = NULL,
         @Ad_Disburse_DATE = NULL,
         @An_Transaction_AMNT = NULL,
         @An_DisburseSeq_NUMB = NULL,
         @Ac_ReasonStatus_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_TypeHold_CODE = D.TypeHold_CODE,
         @An_Transaction_AMNT = D.Transaction_AMNT,
         @Ad_Disburse_DATE = D.Disburse_DATE,
         @An_DisburseSeq_NUMB = D.DisburseSeq_NUMB,
         @Ac_ReasonStatus_CODE = D.ReasonStatus_CODE
    FROM DHLD_Y1 D
   WHERE D.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND D.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND D.Case_IDNO = ISNULL(@An_Case_IDNO, D.Case_IDNO)
     AND D.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND D.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
     AND D.Batch_DATE = @Ad_Batch_DATE
     AND D.Batch_NUMB = @An_Batch_NUMB
     AND D.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND D.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND D.TypeDisburse_CODE = @Ac_TypeDisburse_CODE
     AND D.Unique_IDNO = @An_Unique_IDNO
     AND D.EndValidity_DATE = @Ld_High_DATE
     AND D.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND D.EventGlobalSupportSeq_NUMB = ISNULL(@An_EventGlobalSupportSeq_NUMB, D.EventGlobalSupportSeq_NUMB);
 END; --END of DHLD_RETRIEVE_S3

GO
