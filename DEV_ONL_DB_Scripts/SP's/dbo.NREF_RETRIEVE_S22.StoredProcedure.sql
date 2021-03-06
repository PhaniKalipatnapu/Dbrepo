/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S22] (
 @Ac_Notice_ID         CHAR(8),
 @Ac_CategoryForm_CODE CHAR(3),
 @Ac_TypeNotice_CODE   CHAR(1),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S22
  *     DESCRIPTION       : Retrieve Notice's details for a Notice,Category Form,Date which must be after Effective Date and before End Date, and Notice Type thats common between two tables.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Notice_ID,
         Y.TransactionEventSeq_NUMB,
         Y.NoticeVersion_NUMB,
         Y.CategoryForm_CODE,
         Y.TypeNotice_CODE,
         Y.DescriptionNotice_TEXT,
         Y.BeginValidity_DATE,
         Y.EndValidity_DATE,
         Y.RowCount_NUMB
    FROM (SELECT X.TransactionEventSeq_NUMB,
                 X.Notice_ID,
                 X.CategoryForm_CODE,
                 X.TypeNotice_CODE,
                 X.DescriptionNotice_TEXT,
                 X.NoticeVersion_NUMB,
                 X.BeginValidity_DATE,
                 X.EndValidity_DATE,
                 X.ORD_ROWNUM AS ROW_NUM,
                 COUNT(1) OVER () AS RowCount_NUMB
            FROM (SELECT DISTINCT
                         N1.TransactionEventSeq_NUMB,
                         N.Notice_ID,
                         N.CategoryForm_CODE,
                         N.TypeNotice_CODE,
                         N.DescriptionNotice_TEXT,
                         N1.NoticeVersion_NUMB,
                         N.BeginValidity_DATE,
                         N.EndValidity_DATE,
                         ROW_NUMBER() OVER ( ORDER BY N.Notice_ID ) AS ORD_ROWNUM
                    FROM NREF_Y1 N
                         JOIN NVER_Y1 N1
                          ON N.Notice_ID = N1.Notice_ID
                   WHERE N.Notice_ID = ISNULL(LTRIM(RTRIM(@Ac_Notice_ID)), N.Notice_ID)
                     AND N.CategoryForm_CODE = ISNULL(LTRIM(RTRIM(@Ac_CategoryForm_CODE)), N.CategoryForm_CODE)
                     AND N.TypeNotice_CODE = ISNULL(LTRIM(RTRIM(@Ac_TypeNotice_CODE)), N.TypeNotice_CODE)
                     AND N.EndValidity_DATE = @Ld_High_DATE
                     AND CONVERT(DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN N1.Effective_DATE AND N1.End_DATE) AS X) AS Y
   WHERE Y.Row_Num >= @Ai_RowFrom_NUMB
     AND Y.Row_Num <= @Ai_RowTo_NUMB
   ORDER BY Row_Num;
 END; -- End Of NREF_RETRIEVE_S22


GO
