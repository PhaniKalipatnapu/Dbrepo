/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S7] (
 @Ac_CategoryForm_CODE      CHAR(3),
 @As_DescriptionNotice_TEXT VARCHAR(100),
 @Ac_SearchOption_CODE      CHAR(1),
 @Ai_RowFrom_NUMB           INT = 1,
 @Ai_RowTo_NUMB             INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve the Notice details and Category Code for respective Category Form,Notice Description and Batch Online.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 27-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_Percentage_TEXT             CHAR(1) = '%',
          @Lc_SearchOptionContains_CODE   CHAR(1) = 'C',
          @Lc_SearchOptionEndsLike_CODE   CHAR(1) = 'L',
          @Lc_SearchOptionExact_CODE      CHAR(1) = 'E',
          @Lc_SearchOptionSoundsLike_CODE CHAR(1) = 'D',
          @Lc_SearchOptionStartsLike_CODE CHAR(1) = 'S',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_BatchOnlineN_CODE           CHAR(1) = 'N';

  SELECT Y.Notice_ID,
         Y.Category_CODE,
         Y.DescriptionNotice_TEXT,
         Y.RowCount_NUMB
    FROM (SELECT X.Category_CODE,
                 X.Notice_ID,
                 X.DescriptionNotice_TEXT,
                 X.Row_NUMB,
                 X.RowCount_NUMB
            FROM (SELECT N.Category_CODE,
                         N.Notice_ID,
                         N.DescriptionNotice_TEXT,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY N.Notice_ID) AS Row_NUMB
                    FROM NREF_Y1 N
                   WHERE ((@Ac_SearchOption_CODE = @Lc_SearchOptionExact_CODE
                           AND N.DescriptionNotice_TEXT = @As_DescriptionNotice_TEXT)
                           OR (@Ac_SearchOption_CODE = @Lc_SearchOptionStartsLike_CODE
                               AND N.DescriptionNotice_TEXT LIKE @As_DescriptionNotice_TEXT + @Lc_Percentage_TEXT)
                           OR (@Ac_SearchOption_CODE = @Lc_SearchOptionEndsLike_CODE
                               AND N.DescriptionNotice_TEXT LIKE @Lc_Percentage_TEXT + @As_DescriptionNotice_TEXT)
                           OR (@Ac_SearchOption_CODE = @Lc_SearchOptionSoundsLike_CODE
                               AND SOUNDEX(N.DescriptionNotice_TEXT) = SOUNDEX(@As_DescriptionNotice_TEXT))
                           OR (@Ac_SearchOption_CODE = @Lc_SearchOptionContains_CODE
                               AND N.DescriptionNotice_TEXT LIKE @Lc_Percentage_TEXT + @As_DescriptionNotice_TEXT + @Lc_Percentage_TEXT))
                     AND N.CategoryForm_CODE = @Ac_CategoryForm_CODE
                     AND N.EndValidity_DATE = @Ld_High_DATE
                     AND N.BatchOnline_CODE = @Lc_BatchOnlineN_CODE) AS X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Row_NUMB;
 END; -- End of NREF_RETRIEVE_S7


GO
