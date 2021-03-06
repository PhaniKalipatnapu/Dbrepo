/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S5] (
 @Ac_Notice_ID         CHAR(8),
 @Ac_CategoryForm_CODE CHAR(3),
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : NREF_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve the Notice Idno, Description, and Category Code for Notice Idno, Category Form Code, and Batch Online Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Lc_BatchOnlineN_CODE CHAR(1) = 'N';

  SELECT Y.Notice_ID,
         Y.DescriptionNotice_TEXT,
         Y.Category_CODE,
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
                         ROW_NUMBER() OVER( ORDER BY N.Notice_ID ) AS Row_NUMB
                    FROM NREF_Y1 N
                   WHERE N.Notice_ID = @Ac_Notice_ID
                     AND N.CategoryForm_CODE = @Ac_CategoryForm_CODE
                     AND N.EndValidity_DATE = @Ld_High_DATE
                     AND N.BatchOnline_CODE = @Lc_BatchOnlineN_CODE) AS X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Row_NUMB;
 END; -- End of NREF_RETRIEVE_S5


GO
