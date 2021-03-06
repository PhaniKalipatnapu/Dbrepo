/****** Object:  StoredProcedure [dbo].[DHLD_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_INSERT_S1] (
 @An_Case_IDNO                  NUMERIC(6, 0),
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4, 0),
 @An_SeqReceipt_NUMB            NUMERIC(6, 0),
 @Ac_TypeDisburse_CODE          CHAR(5),
 @An_Transaction_AMNT           NUMERIC(11, 2),
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR(1),
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19, 0),
 @An_EventGlobalBeginSeq_NUMB   NUMERIC(19, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_INSERT_S1  
  *     DESCRIPTION       : Inserts the values into the LogDisbursementHold table  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 28-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 DECLARE @Ld_High_DATE             DATE ='12/31/9999',
         @Li_Zero_NUMB             SMALLINT =0,
         @Ld_Current_DATE          DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Lc_StatusRefunded_CODE   CHAR(1)='R',
         @Lc_ReasonStatusDR_CODE   CHAR(2)='DR',
         @Lc_ProcessOffsetYes_INDC CHAR(1)='Y',
         @Ld_Low_DATE              DATE ='01/01/0001',
         @Lc_Space_TEXT            CHAR(1)= ' ',
         @Lc_TypeHoldD_CODE        CHAR(1)='D';

 BEGIN
  INSERT DHLD_Y1
         (Case_IDNO,
          OrderSeq_NUMB,
          ObligationSeq_NUMB,
          Batch_DATE,
          SourceBatch_CODE,
          Batch_NUMB,
          SeqReceipt_NUMB,
          Transaction_DATE,
          Release_DATE,
          TypeDisburse_CODE,
          Transaction_AMNT,
          Status_CODE,
          TypeHold_CODE,
          ProcessOffset_INDC,
          CheckRecipient_ID,
          CheckRecipient_CODE,
          ReasonStatus_CODE,
          EventGlobalSupportSeq_NUMB,
          EventGlobalBeginSeq_NUMB,
          EventGlobalEndSeq_NUMB,
          BeginValidity_DATE,
          EndValidity_DATE,
          Disburse_DATE,
          DisburseSeq_NUMB,
          StatusEscheat_DATE,
          StatusEscheat_CODE)
  VALUES ( @An_Case_IDNO,
           @Li_Zero_NUMB,
           @Li_Zero_NUMB,
           @Ad_Batch_DATE,
           @Ac_SourceBatch_CODE,
           @An_Batch_NUMB,
           @An_SeqReceipt_NUMB,
           @Ld_Current_DATE,
           @Ld_Current_DATE,
           @Ac_TypeDisburse_CODE,
           @An_Transaction_AMNT,
           @Lc_StatusRefunded_CODE,
           @Lc_TypeHoldD_CODE,
           @Lc_ProcessOffsetYes_INDC,
           @Ac_CheckRecipient_ID,
           @Ac_CheckRecipient_CODE,
           @Lc_ReasonStatusDR_CODE,
           @An_EventGlobalSupportSeq_NUMB,
           @An_EventGlobalBeginSeq_NUMB,
           @Li_Zero_NUMB,
           @Ld_Current_DATE,
           @Ld_High_DATE,
           @Ld_Low_DATE,
           @Li_Zero_NUMB,
           @Ld_High_DATE,
           @Lc_Space_TEXT);
 END; --End of DHLD_INSERT_S1     

GO
