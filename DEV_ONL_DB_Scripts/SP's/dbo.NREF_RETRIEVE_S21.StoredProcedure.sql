/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S21] (
 @Ac_CategoryForm_CODE      CHAR(3),
 @Ac_TypeNotice_CODE        CHAR(1),
 @As_DescriptionNotice_TEXT VARCHAR(100),
 @Ac_SearchType_CODE        CHAR(1),
 @Ai_RowFrom_NUMB           INT =1,
 @Ai_RowTo_NUMB             INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S21
  *     DESCRIPTION       : Retrieve Notice's details for a respective Category Form and Notice Type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Percentage_PCT            CHAR(1) = '%',
          @Lc_SearchTypeContains_CODE   CHAR(1) = 'C',
          @Lc_SearchTypeEndsLike_CODE   CHAR(1) = 'L',
          @Lc_SearchTypeExact_CODE      CHAR(1) = 'E',
          @Lc_SearchTypeSoundsLike_CODE CHAR(1) = 'D',
          @Lc_SearchTypeStartsLike_CODE CHAR(1) = 'S',
          @Ld_High_DATE                 DATE = '12/31/9999';

  SELECT X.Notice_ID,
         X.TransactionEventSeq_NUMB,
         X.NoticeVersion_NUMB,
         X.CategoryForm_CODE,
         X.TypeNotice_CODE,
         X.DescriptionNotice_TEXT,
         X.BeginValidity_DATE,
         X.EndValidity_DATE,
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
                 ROW_NUMBER() OVER ( ORDER BY N.Notice_ID ) AS Row_Num
            FROM NREF_Y1 N
                 JOIN NVER_Y1 N1
                  ON N.Notice_ID = N1.Notice_ID
           WHERE N.CategoryForm_CODE = ISNULL(@Ac_CategoryForm_CODE, N.CategoryForm_CODE)
             AND N.TypeNotice_CODE = ISNULL(@Ac_TypeNotice_CODE, N.TypeNotice_CODE)
             AND N.EndValidity_DATE = @Ld_High_DATE
             AND CONVERT(DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN N1.Effective_DATE AND N1.End_DATE
             AND ((@Ac_SearchType_CODE = @Lc_SearchTypeExact_CODE
                   AND N.DescriptionNotice_TEXT = @As_DescriptionNotice_TEXT)
                   OR (@Ac_SearchType_CODE = @Lc_SearchTypeStartsLike_CODE
                       AND N.DescriptionNotice_TEXT LIKE ISNULL(@As_DescriptionNotice_TEXT, '') + @Lc_Percentage_PCT)
                   OR (@Ac_SearchType_CODE = @Lc_SearchTypeEndsLike_CODE
                       AND N.DescriptionNotice_TEXT LIKE @Lc_Percentage_PCT + ISNULL(@As_DescriptionNotice_TEXT, ''))
                   OR (@Ac_SearchType_CODE = @Lc_SearchTypeSoundsLike_CODE
                       AND dbo.BATCH_COMMON_SCALAR$SF_GETSOUNDEX(N.DescriptionNotice_TEXT) = dbo.BATCH_COMMON_SCALAR$SF_GETSOUNDEX(@As_DescriptionNotice_TEXT))
                   OR (@Ac_SearchType_CODE = @Lc_SearchTypeContains_CODE
                       AND N.DescriptionNotice_TEXT LIKE @Lc_Percentage_PCT + ISNULL(@As_DescriptionNotice_TEXT, '') + @Lc_Percentage_PCT))) AS X
   WHERE X.Row_Num >= @Ai_RowFrom_NUMB
     AND X.Row_Num <= @Ai_RowTo_NUMB
   ORDER BY Row_Num;
 END; -- End Of NREF_RETRIEVE_S21 

GO
