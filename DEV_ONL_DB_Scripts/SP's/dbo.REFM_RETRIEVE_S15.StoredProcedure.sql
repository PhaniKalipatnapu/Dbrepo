/****** Object:  StoredProcedure [dbo].[REFM_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[REFM_RETRIEVE_S15] (
 @Ac_Table_ID     CHAR(4),
 @Ac_TableSub_ID  CHAR(4),
 @Ai_RowFrom_NUMB INT,
 @Ai_RowTo_NUMB   INT
 )
AS
 /*
  *     PROCEDURE NAME    : REFM_RETRIEVE_S15
  *     DESCRIPTION       : Retrieve Value Code, Description, and Transaction seqeunce for a Table Idno and Sub Table Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
 
 DECLARE @Li_Zero_NUMB SMALLINT = 0;
 
  SELECT Y.Value_CODE,
         Y.DescriptionValue_TEXT,
         Y.TransactionEventSeq_NUMB,
         Y.RowCount_NUMB
    FROM (SELECT X.Value_CODE,
                 X.DescriptionValue_TEXT,
                 X.TransactionEventSeq_NUMB,
                 X.RowCount_NUMB,
                 X.Rownum_NUMB
            FROM (SELECT R.Value_CODE,
                         R.DescriptionValue_TEXT,
                         R.TransactionEventSeq_NUMB,
                         COUNT (1) OVER () AS RowCount_NUMB,
						 --13712 - REFM - REFM values not in order -START-
                         ROW_NUMBER () OVER ( ORDER BY R.DescriptionValue_TEXT ) AS Rownum_NUMB
						 --13712 - REFM - REFM values not in order -END-
                    FROM REFM_Y1 R
                   WHERE R.Table_ID = @Ac_Table_ID
                     AND R.TableSub_ID = @Ac_TableSub_ID) AS X
           WHERE X.Rownum_NUMB <= @Ai_RowTo_NUMB
              OR @Ai_RowTo_NUMB = @Li_Zero_NUMB) AS Y
   WHERE Y.Rownum_NUMB >= @Ai_RowFrom_NUMB
      OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB;
 
 END; --End Of REFM_RETRIEVE_S15

GO
