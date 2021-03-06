/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_UPDATE_S7] (
 @An_PayorMCI_IDNO            NUMERIC(10, 0),
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_ReasonStatus_CODE        CHAR(4),
 @Ad_Release_DATE             DATE,
 @Ac_TypeHold_CODE            CHAR(1),
 @Ad_BeginValidity_DATE       DATE,
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_UPDATE_S7
  *     DESCRIPTION       : Updates Release Date, Reason Status code and status receipt code in Receipts table. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-SEP-2011
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
          @Lc_TypeHoldPostingCase_CODE     CHAR(1) = 'C';

  UPDATE RCTH_Y1
     SET Release_DATE = @Ad_Release_DATE,
         ReasonStatus_CODE = @Ac_ReasonStatus_CODE,
         StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
   WHERE PayorMCI_IDNO = @An_PayorMCI_IDNO
     AND Case_IDNO = CASE @Ac_TypeHold_CODE
                      WHEN @Lc_TypeHoldPostingCase_CODE
                       THEN @An_Case_IDNO
                      ELSE NULL
                     END
     AND StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
     AND Distribute_DATE = @Ld_Low_DATE
     AND BeginValidity_DATE = @Ad_BeginValidity_DATE
     AND EndValidity_DATE = @Ld_High_DATE
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF RCTH_UPDATE_S7

GO
