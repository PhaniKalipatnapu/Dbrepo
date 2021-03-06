/****** Object:  StoredProcedure [dbo].[EMSG_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMSG_RETRIEVE_S1] (
 @Ac_Error_CODE            CHAR(18),
 @As_DescriptionError_TEXT VARCHAR(300),
 @Ac_TypeError_CODE        CHAR(1),
 @Ac_SearchOption_CODE     CHAR(1),
 @Ai_RowFrom_NUMB          INT = 1,
 @Ai_RowTo_NUMB            INT = 10
 )
AS
 /*                                                                                                                                                                          
  *     Procedure Name    : EMSG_RETRIEVE_S1                                                                                                                                 
  *     Description       : Retrieves Error Code and other information for the given Error Type, Error ID and Error Description                                              
  *     Developed By      : IMP Team                                                                                                                                         
  *     Developed On      : 03-AUG-2011                                                                                                                                      
  *     Modified By       :                                                                                                                                                  
  *     Modified On       :                                                                                                                                                  
  *     Version No        : 1                                                                                                                                                
 */
 BEGIN
  DECLARE @Lc_Percentage_PCT            CHAR(1) = '%',
          @Lc_SearchTypeContains_CODE   CHAR(1) = 'C',
          @Lc_SearchTypeEndsLike_CODE   CHAR(1) = 'L',
          @Lc_SearchTypeExact_CODE      CHAR(1) = 'E',
          @Lc_SearchTypeSoundsLike_CODE CHAR(1) = 'D',
          @Lc_SearchTypeStartsLike_CODE CHAR(1) = 'S';

  SELECT Y.Error_CODE,
         Y.DescriptionError_TEXT,
         Y.TypeError_CODE,
         Y.Update_DTTM,
         Y.WorkerUpdate_ID,
         Y.TransactionEventSeq_NUMB,
         Y.RowCount_NUMB
    FROM (SELECT X.Error_CODE,
                 X.DescriptionError_TEXT,
                 X.TypeError_CODE,
                 X.WorkerUpdate_ID,
                 X.Update_DTTM,
                 X.TransactionEventSeq_NUMB,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM
            FROM (SELECT E.Error_CODE,
                         E.DescriptionError_TEXT,
                         E.TypeError_CODE,
                         E.WorkerUpdate_ID,
                         E.Update_DTTM,
                         E.TransactionEventSeq_NUMB,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER () OVER ( ORDER BY E.Error_CODE ) AS ORD_ROWNUM
                    FROM EMSG_Y1 E
                   WHERE E.TypeError_CODE = @Ac_TypeError_CODE
                     AND ((@Ac_Error_CODE IS NULL
                           AND E.ERROR_CODE = E.ERROR_CODE)
                           OR (@Ac_Error_CODE IS NOT NULL
                               AND E.ERROR_CODE = @Ac_Error_CODE))
                     AND (@As_DescriptionError_TEXT IS NULL
                           OR (@As_DescriptionError_TEXT IS NOT NULL
                               AND ((@Ac_SearchOption_CODE = @Lc_SearchTypeExact_CODE
                                     AND E.DescriptionError_TEXT = @As_DescriptionError_TEXT)
                                     OR (@Ac_SearchOption_CODE = @Lc_SearchTypeStartsLike_CODE
                                         AND E.DescriptionError_TEXT LIKE @As_DescriptionError_TEXT + @Lc_Percentage_PCT)
                                     OR (@Ac_SearchOption_CODE = @Lc_SearchTypeEndsLike_CODE
                                         AND E.DescriptionError_TEXT LIKE @Lc_Percentage_PCT + @As_DescriptionError_TEXT)
                                     OR (@Ac_SearchOption_CODE = @Lc_SearchTypeContains_CODE
                                         AND E.DescriptionError_TEXT LIKE @Lc_Percentage_PCT + @As_DescriptionError_TEXT + @Lc_Percentage_PCT)
                                     OR (@Ac_SearchOption_CODE = @Lc_SearchTypeSoundsLike_CODE
                                         AND SOUNDEX(E.DescriptionError_TEXT) = SOUNDEX(@As_DescriptionError_TEXT)))))) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END; --End of EMSG_RETRIEVE_S1                                                                                                                                              

GO
