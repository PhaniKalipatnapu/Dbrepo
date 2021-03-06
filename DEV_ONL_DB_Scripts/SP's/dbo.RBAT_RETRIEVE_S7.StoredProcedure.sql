/****** Object:  StoredProcedure [dbo].[RBAT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_RETRIEVE_S7] (
 @Ad_Batch_DATE       DATE,
 @Ac_SourceBatch_CODE CHAR(3),
 @An_Batch_NUMB       NUMERIC(4, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RBAT_RETRIEVE_S7
  *     DESCRIPTION       : Retrieves the record count for the Reconciled batches 
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 23-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_StatusBatchReconciled_CODE CHAR(1) = 'R',
          @Ld_High_DATE                  DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM RBAT_Y1 r
   WHERE r.Batch_DATE = @Ad_Batch_DATE
     AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND r.Batch_NUMB = @An_Batch_NUMB
     AND r.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
     AND r.EndValidity_DATE = @Ld_High_DATE;
 END --End of RBAT_RETRIEVE_S7

GO
