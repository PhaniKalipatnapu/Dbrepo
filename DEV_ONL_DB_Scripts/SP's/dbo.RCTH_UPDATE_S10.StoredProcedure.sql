/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_UPDATE_S10] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4, 0),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @Ac_SourceReceipt_CODE       CHAR(2),
 @Ac_TypeRemittance_CODE      CHAR(3),
 @Ac_TypePosting_CODE         CHAR(1),
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_PayorMCI_IDNO            NUMERIC(10, 0),
 @An_Receipt_AMNT             NUMERIC(11, 2),
 @An_ToDistribute_AMNT        NUMERIC(11, 2),
 @An_Fee_AMNT                 NUMERIC(11, 2),
 @An_Employer_IDNO            NUMERIC(9, 0),
 @Ac_Fips_CODE                CHAR(7),
 @Ad_Check_DATE               DATE,
 @Ac_CheckNo_TEXT             CHAR(18),
 @Ad_Receipt_DATE             DATE,
 @Ac_Tanf_CODE                CHAR(1),
 @Ac_TaxJoint_CODE            CHAR(1),
 @Ac_TaxJoint_NAME            CHAR(35),
 @Ac_ReasonStatus_CODE        CHAR(4),
 @Ad_Refund_DATE              DATE,
 @An_ReferenceIrs_IDNO        NUMERIC(15, 0),
 @Ac_RefundRecipient_ID       CHAR(10),
 @Ac_RefundRecipient_CODE     CHAR(1),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_EventGlobalEndSeq_NUMB   NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_UPDATE_S10
  *     DESCRIPTION       : Updates the end validity date in the Receipts table for held receipts.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 28-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB          NUMERIC(10),
          @Ld_Current_DATE               DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE                  DATE = '12/31/9999',
          @Ld_Low_DATE                   DATE = '01/01/0001',
          @Lc_StatusReceiptHeld_CODE     CHAR(1)='H',
          @Lc_Space_TEXT                 CHAR(1)=' ',
          @Lc_No_INDC                    CHAR(1)='N',
          @Lc_StatusReceiptRefunded_CODE CHAR(1)='R',
          @Li_Zero_NUMB                  SMALLINT = 0;

  UPDATE RCTH_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
         EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
  OUTPUT @Ad_Batch_DATE,
         @Ac_SourceBatch_CODE,
         @An_Batch_NUMB,
         @An_SeqReceipt_NUMB,
         @Ac_SourceReceipt_CODE,
         @Ac_TypeRemittance_CODE,
         @Ac_TypePosting_CODE,
         @An_Case_IDNO,
         @An_PayorMCI_IDNO,
         @An_Receipt_AMNT,
         @An_ToDistribute_AMNT,
         @An_Fee_AMNT,
         @An_Employer_IDNO,
         @Ac_Fips_CODE,
         @Ad_Check_DATE,
         @Ac_CheckNo_TEXT,
         @Ad_Receipt_DATE,
         @Ld_Current_DATE AS Distribute_DATE,
         @Ac_Tanf_CODE,
         @Ac_TaxJoint_CODE,
         @Ac_TaxJoint_NAME,
         @Lc_StatusReceiptRefunded_CODE AS StatusReceipt_CODE,
         @Ac_ReasonStatus_CODE,
         @Lc_No_INDC AS BackOut_INDC,
         @Lc_Space_TEXT AS ReasonBackOut_CODE,
         @Ad_Refund_DATE,
         @Ld_Current_DATE AS Release_DATE,
         @An_ReferenceIrs_IDNO,
         @Ac_RefundRecipient_ID,
         @Ac_RefundRecipient_CODE,
         @Ld_Current_DATE AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @An_EventGlobalEndSeq_NUMB AS EventGlobalBeginSeq_NUMB,
         @Li_Zero_NUMB AS EventGlobalEndSeq_NUMB
  INTO RCTH_Y1
   WHERE Batch_DATE = @Ad_Batch_DATE
     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND Batch_NUMB = @An_Batch_NUMB
     AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
     AND Distribute_DATE = @Ld_Low_DATE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- END OF RCTH_UPDATE_S10

GO
