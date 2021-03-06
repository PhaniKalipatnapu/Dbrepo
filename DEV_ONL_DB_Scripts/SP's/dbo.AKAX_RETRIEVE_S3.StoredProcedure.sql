/****** Object:  StoredProcedure [dbo].[AKAX_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_RETRIEVE_S3] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Sequence_NUMB  NUMERIC(11, 0),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : AKAX_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Member's Alias Name History details from Member Alias Names table for Unique Number Assigned by the System to the Member and sequence number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.TypeAlias_CODE,
         Y.LastAlias_NAME,
         Y.FirstAlias_NAME,
         Y.MiddleAlias_NAME,
         Y.TitleAlias_NAME,
         Y.SuffixAlias_NAME,
         Y.Source_CODE,
         Y.Update_DTTM,
         Y.WorkerUpdate_ID,
         Y.RowCount_NUMB
    FROM (SELECT X.LastAlias_NAME,
                 X.SuffixAlias_NAME,
                 X.FirstAlias_NAME,
                 X.MiddleAlias_NAME,
                 X.TypeAlias_CODE,
                 X.TitleAlias_NAME,
                 X.Source_CODE,
                 X.WorkerUpdate_ID,
                 X.Update_DTTM,
                 X.RowCount_NUMB,
                 X.Rownum_NUMB
            FROM (SELECT A.LastAlias_NAME,
                         A.FirstAlias_NAME,
                         A.MiddleAlias_NAME,
                         A.SuffixAlias_NAME,
                         A.TitleAlias_NAME,
                         A.Source_CODE,
                         A.TypeAlias_CODE,
                         A.WorkerUpdate_ID,
                         A.Update_DTTM,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER ( ORDER BY A.TransactionEventSeq_NUMB DESC ) AS Rownum_NUMB
                    FROM AKAX_Y1 A
                   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND A.Sequence_NUMB = @An_Sequence_NUMB
                     AND A.EndValidity_DATE != @Ld_High_DATE) AS X
           WHERE X.Rownum_NUMB <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Rownum_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Rownum_NUMB;
 END; -- END of AKAX_RETRIEVE_S3


GO
