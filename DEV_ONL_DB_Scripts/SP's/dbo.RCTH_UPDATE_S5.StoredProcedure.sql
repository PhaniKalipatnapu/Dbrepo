/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_UPDATE_S5] (
 @Ac_SourceReceipt_CODE     CHAR(2),
 @An_Case_IDNO              NUMERIC(6, 0),
 @An_PayorMCI_IDNO          NUMERIC(10, 0),
 @Ac_ReasonStatus_CODE      CHAR(4),
 @An_EventGlobalEndSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_UPDATE_S5
  *     DESCRIPTION       : Updates the receipts details in RCTH_Y1.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB            NUMERIC(10),
          @Lc_StatusReceiptHeld_CODE       CHAR(1) = 'H',
          @Lc_StatusReceiptIdentified_CODE CHAR(1) = 'I',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001',
          @Ld_Current_DATE                 DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_SourceReceiptHoldDH_CODE     CHAR(2) = 'DH',
		  @Li_Zero_NUMB					   INT = 0;

  UPDATE RCTH_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
         EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
   WHERE PayorMCI_IDNO = @An_PayorMCI_IDNO
     AND Case_IDNO = CASE @An_Case_IDNO 
					   WHEN @Li_Zero_NUMB
					    THEN Case_IDNO 
					   ELSE @An_Case_IDNO
					  END
     AND SourceReceipt_CODE = CASE @Ac_SourceReceipt_CODE
                               WHEN @Lc_SourceReceiptHoldDH_CODE
                                THEN SourceReceipt_CODE
                               ELSE @Ac_SourceReceipt_CODE
                              END
     AND Distribute_DATE = @Ld_Low_DATE
     AND EndValidity_DATE = @Ld_High_DATE
     AND (StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
           OR (StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
               AND ReasonStatus_CODE = @Ac_ReasonStatus_CODE));

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF RCTH_UPDATE_S5

GO
