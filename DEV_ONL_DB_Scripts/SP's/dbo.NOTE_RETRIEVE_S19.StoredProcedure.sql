/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S19] (
 @An_Case_IDNO    NUMERIC(6, 0),
 @Ai_RowFrom_NUMB INT = 1,
 @Ai_RowTo_NUMB   INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S19
  *     DESCRIPTION       : GET THE Description Note Details for related case
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CategorySp_CODE CHAR(2) = 'SP',
          @Ld_High_DATE       DATE = '12/31/9999';
          
  SELECT Y.Start_DATE,
         Y.WorkerCreated_ID,
         Y.DescriptionNote_TEXT,
         Y.RowCount_NUMB
   FROM (SELECT X.Start_DATE,
                X.WorkerCreated_ID,
                X.DescriptionNote_TEXT,
                X.ORD_ROWNUM,
                X.RowCount_NUMB
           FROM (SELECT N.Start_DATE,
                        N.WorkerCreated_ID,
                        N.DescriptionNote_TEXT,
                        COUNT (1) OVER() AS RowCount_NUMB,
                        ROW_NUMBER () OVER (ORDER BY N.Update_DTTM DESC) AS ORD_ROWNUM
                   FROM NOTE_Y1 N
                  WHERE N.Category_CODE = @Lc_CategorySp_CODE
                    AND N.EndValidity_DATE = @Ld_High_DATE
                    AND N.Case_IDNO = @An_Case_IDNO
                    AND N.Post_IDNO = (SELECT MAX (b.Post_IDNO)  
                                          FROM NOTE_Y1 b  
                                         WHERE N.Topic_IDNO = b.Topic_IDNO  
                                           AND N.Case_IDNO = b.Case_IDNO  
                                           AND b.EndValidity_DATE = @Ld_High_DATE)) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY Y.ORD_ROWNUM;  
 END; --End Of NOTE_RETRIEVE_S19 


GO
