/****** Object:  StoredProcedure [dbo].[DHLD_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_UPDATE_S1] (
 @An_Case_IDNO                  NUMERIC(6, 0),
 @An_OrderSeq_NUMB              NUMERIC(2, 0),
 @An_ObligationSeq_NUMB         NUMERIC(2, 0),
 @An_Unique_IDNO                NUMERIC(19, 0),
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4, 0),
 @An_SeqReceipt_NUMB            NUMERIC(6, 0),
 @Ad_Release_DATE               DATE,
 @Ac_TypeDisburse_CODE          CHAR(5),
 @An_Transaction_AMNT           NUMERIC(11, 2),
 @Ac_Status_CODE                CHAR(1),
 @Ac_TypeHold_CODE              CHAR(1),
 @Ac_ProcessOffset_INDC         CHAR(1),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @Ac_ReasonStatus_CODE          CHAR(4),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19, 0),
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19, 0),
 @An_EventGlobalEndSeq_NUMB     NUMERIC(19, 0),
 @Ad_Disburse_DATE              DATE,
 @An_DisburseSeq_NUMB           NUMERIC(4, 0)
 )
AS
 /*  
 *     PROCEDURE NAME    : DHLD_UPDATE_S1  
 *     DESCRIPTION       : Updtae the changes made to the details inquired for release disbursement hold details
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_Current_DATE      DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE='12/31/9999';

  UPDATE DHLD_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
         EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
  OUTPUT Deleted.Case_IDNO AS Case_IDNO,
         Deleted.OrderSeq_NUMB AS OrderSeq_NUMB,
         Deleted.ObligationSeq_NUMB AS ObligationSeq_NUMB,
         @Ad_Batch_DATE AS Batch_DATE,
         @Ac_SourceBatch_CODE AS SourceBatch_CODE,
         @An_Batch_NUMB AS Batch_NUMB,
         @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
         @Ld_Current_DATE AS Transaction_DATE,
         @Ad_Release_DATE AS Release_DATE,
         @Ac_TypeDisburse_CODE AS TypeDisburse_CODE,
         @An_Transaction_AMNT AS Transaction_AMNT,
         @Ac_Status_CODE AS Status_CODE,
         @Ac_TypeHold_CODE AS TypeHold_CODE,
         @Ac_ProcessOffset_INDC AS ProcessOffset_INDC,
         @Ac_CheckRecipient_ID AS CheckRecipient_ID,
         @Ac_CheckRecipient_CODE AS CheckRecipient_CODE,
         @Ac_ReasonStatus_CODE AS ReasonStatus_CODE,
         @An_EventGlobalSupportSeq_NUMB AS EventGlobalSupportSeq_NUMB,
         @An_EventGlobalEndSeq_NUMB AS EventGlobalBeginSeq_NUMB,
         0 AS EventGlobalEndSeq_NUMB,
         @Ld_Current_DATE AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @Ad_Disburse_DATE AS Disburse_DATE,
         @An_DisburseSeq_NUMB AS DisburseSeq_NUMB,
         Deleted.StatusEscheat_DATE AS StatusEscheat_DATE,
         Deleted.StatusEscheat_CODE AS StatusEscheat_CODE
  INTO DHLD_Y1
   WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND Case_IDNO = ISNULL(@An_Case_IDNO, Case_IDNO)
     AND OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
     AND Batch_DATE = @Ad_Batch_DATE
     AND Batch_NUMB = @An_Batch_NUMB
     AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND TypeDisburse_CODE = @Ac_TypeDisburse_CODE
     AND Unique_IDNO = @An_Unique_IDNO
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE
     AND EventGlobalSupportSeq_NUMB = @An_EventGlobalSupportSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of   DHLD_UPDATE_S1



GO
