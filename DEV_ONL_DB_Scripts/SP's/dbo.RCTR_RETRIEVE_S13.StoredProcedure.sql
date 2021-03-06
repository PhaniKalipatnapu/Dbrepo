/****** Object:  StoredProcedure [dbo].[RCTR_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTR_RETRIEVE_S13] (
 @Ad_Batch_DATE       DATE,
 @An_Batch_NUMB       NUMERIC(4, 0),
 @Ac_SourceBatch_CODE CHAR(3),
 @Ac_Exists_INDC      CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTR_RETRIEVE_S13
  *     DESCRIPTION       : Procedure To Check The Reposted Receipt, By Using RCTR_Y1
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 13-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Exists_INDC = 'N';

  DECLARE @Ld_High_DATE                DATE = '12/31/9999',
          @Lc_StatusMatchOverride_CODE CHAR(1) = 'V',
          @Lc_StatusMatchApproved_CODE CHAR(1) = 'A',
          @Lc_StatusNoMatch_CODE       CHAR(1) = 'N',
          @Lc_StatusMatch_CODE         CHAR(1) = 'M',
          @Lc_Yes_INDC                 CHAR(1) = 'Y';

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM RCTR_Y1 a
   WHERE a.Batch_DATE = @Ad_Batch_DATE
     AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND a.Batch_NUMB = @An_Batch_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND a.StatusMatch_CODE IN(@Lc_StatusNoMatch_CODE, @Lc_StatusMatch_CODE)
     AND NOT EXISTS (SELECT 1
                       FROM RCTR_Y1 b
                      WHERE b.BatchOrig_DATE = a.BatchOrig_DATE
                        AND b.SourceBatchOrig_CODE = a.SourceBatchOrig_CODE
                        AND b.BatchOrig_NUMB = a.BatchOrig_NUMB
                        AND b.SeqReceiptOrig_NUMB = a.SeqReceiptOrig_NUMB
                        AND (b.StatusMatch_CODE = @Lc_StatusMatchOverride_CODE
                              OR b.StatusMatch_CODE = @Lc_StatusMatchApproved_CODE)
                        AND b.EndValidity_DATE = @Ld_High_DATE);
 END; --End Of Procedure RCTR_RETRIEVE_S13

GO
