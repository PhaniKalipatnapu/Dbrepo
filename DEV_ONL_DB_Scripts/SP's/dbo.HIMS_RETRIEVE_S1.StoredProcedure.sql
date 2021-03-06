/****** Object:  StoredProcedure [dbo].[HIMS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HIMS_RETRIEVE_S1] (
 @Ai_RowFrom_NUMB INT =1,
 @Ai_RowTo_NUMB   INT =10
 )
AS
 /*
 *     PROCEDURE NAME    : HIMS_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves  Hold Instruction Details for the High Date
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT X.SourceReceipt_CODE,
         X.TransactionEventSeq_NUMB,
         X.DistNonIvd_INDC,
         X.CaseHold_INDC,
         row_count AS RowCount_NUMB
    FROM (SELECT X.SourceReceipt_CODE,
                 X.DistNonIvd_INDC,
                 X.CaseHold_INDC,
                 X.TransactionEventSeq_NUMB,
                 X.row_count,
                 X.ORD_ROWNUM AS rnum
            FROM (SELECT H.SourceReceipt_CODE,
                         H.DistNonIvd_INDC,
                         H.CaseHold_INDC,
                         H.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS row_count,
                         ROW_NUMBER() OVER( ORDER BY H.SourceReceipt_CODE) AS ORD_ROWNUM
                    FROM HIMS_Y1 H
                   WHERE H.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS X
   WHERE X.rnum >= @Ai_RowFrom_NUMB
   ORDER BY RNUM;
 END; --END of HIMS_RETRIEVE_S1

GO
