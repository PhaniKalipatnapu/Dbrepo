/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S7] (
 @Ad_BatchOrig_DATE       DATE,
 @An_BatchOrig_NUMB       NUMERIC(4, 0),
 @Ac_SourceBatchOrig_CODE CHAR(3),
 @An_SeqReceiptOrig_NUMB  NUMERIC(6, 0),
 @Ac_StatusMatch_CODE     CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_RETRIEVE_S7
  *     DESCRIPTION       : Procedure To Retrieve The StatusMatchCode For Receipt Based On BatchOrigDate,
							SeqReceiptOrigNUMB And EndValidityDate BY Using RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 19-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_StatusMatch_CODE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  --13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - START -
  SELECT TOP 1 @Ac_StatusMatch_CODE = r.StatusMatch_CODE
	FROM RCTR_Y1 r
   WHERE r.BatchOrig_DATE = @Ad_BatchOrig_DATE
	 AND r.SourceBatchOrig_CODE = @Ac_SourceBatchOrig_CODE
	 AND r.BatchOrig_NUMB = @An_BatchOrig_NUMB
	 AND r.SeqReceiptOrig_NUMB = @An_SeqReceiptOrig_NUMB
	 AND r.EndValidity_DATE = @Ld_High_DATE
	 ORDER BY r.Batch_NUMB DESC;
  --13447 - RPOS - CR0384 Reverse and Repost Edits for Reposted Receipts and Refunded Receipts - END -
 END; -- ENd Of Procedure RCTR_RETRIEVE_S7 

GO
