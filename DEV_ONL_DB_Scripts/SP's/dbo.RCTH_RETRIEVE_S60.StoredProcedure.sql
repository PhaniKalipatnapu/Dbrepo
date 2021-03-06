/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S60]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S60] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4, 0),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S60
  *     DESCRIPTION       : Retrieves the even global begin seq for the given receipt number. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @An_EventGlobalBeginSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_EventGlobalBeginSeq_NUMB = MAX(a.EventGlobalBeginSeq_NUMB)
    FROM RCTH_Y1 a
   WHERE a.Batch_DATE = @Ad_Batch_DATE
     AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND a.Batch_NUMB = @An_Batch_NUMB
     AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END -- End of RCTH_RETRIEVE_S60

GO
