/****** Object:  StoredProcedure [dbo].[RCTH_UPDATE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_UPDATE_S6] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4, 0),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_ToDistribute_AMNT        NUMERIC(11, 2),
 @Ac_StatusReceipt_CODE       CHAR(1),
 @Ac_ReasonStatus_CODE        CHAR(4)
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_UPDATE_S6
  *     DESCRIPTION       : Updates ToDistribute amount in the RCTH_Y1 table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_High_DATE         DATE = '12/31/9999';

  UPDATE RCTH_Y1
     SET ToDistribute_AMNT = ToDistribute_AMNT + @An_ToDistribute_AMNT
   WHERE Batch_DATE = @Ad_Batch_DATE
     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND Batch_NUMB = @An_Batch_NUMB
     AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND StatusReceipt_CODE = @Ac_StatusReceipt_CODE
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND ReasonStatus_CODE = @Ac_ReasonStatus_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF RCTH_UPDATE_S6

GO
