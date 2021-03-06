/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S17] (
 @Ac_Notice_ID         CHAR(8),
 @Ac_CategoryForm_CODE CHAR(3),
 @Ac_TypeNotice_CODE   CHAR(1),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve Notice details for a Notice,Category Form and Type Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_BatchOnline_CODE CHAR(1) = 'C';

  SELECT X.Notice_ID,
         X.TransactionEventSeq_NUMB,
         X.CategoryForm_CODE,
         X.TypeNotice_CODE,
         X.TypeEnvelope_CODE,
         X.AddressHierarchy_CODE,
         X.DescriptionNotice_TEXT,
         X.NoticeVersion_NUMB,
         X.RowCount_NUMB
    FROM (SELECT N.Notice_ID,
                 N.DescriptionNotice_TEXT,
                 N1.NoticeVersion_NUMB,
                 N.CategoryForm_CODE,
                 N.TypeNotice_CODE,
                 N.TypeEnvelope_CODE,
                 N.AddressHierarchy_CODE,
                 N.TransactionEventSeq_NUMB,
                 COUNT(1) OVER () AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY N.Notice_ID ) AS Row_Num
            FROM NREF_Y1 N
                 JOIN NVER_Y1 N1
                  ON N.Notice_ID = N1.Notice_ID
           WHERE N.BatchOnline_CODE <> @Lc_BatchOnline_CODE
             AND N.Notice_ID = ISNULL(@Ac_Notice_ID, N.Notice_ID)
             AND N.CategoryForm_CODE = ISNULL(@Ac_CategoryForm_CODE, N.CategoryForm_CODE)
             AND N.TypeNotice_CODE = ISNULL(@Ac_TypeNotice_CODE, N.TypeNotice_CODE)
             AND N1.NoticeVersion_NUMB = (SELECT MAX(N2.NoticeVersion_NUMB)
                                            FROM NVER_Y1 N2
                                           WHERE N2.Notice_ID = N.Notice_ID
                                             AND CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN N2.Effective_DATE AND N2.End_DATE)
             AND N.EndValidity_DATE = @Ld_High_DATE) AS X
   WHERE X.Row_Num <= @Ai_RowTo_NUMB
     AND X.Row_Num >= @Ai_RowFrom_NUMB
   ORDER BY Row_Num;
 END; -- End Of NREF_RETRIEVE_S17

GO
