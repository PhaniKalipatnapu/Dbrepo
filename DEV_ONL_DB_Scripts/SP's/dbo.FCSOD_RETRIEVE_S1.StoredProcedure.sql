/****** Object:  StoredProcedure [dbo].[FCSOD_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FCSOD_RETRIEVE_S1](
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_OrderSeq_NUMB NUMERIC(3, 0),
 @Ai_RowFrom_NUMB  SMALLINT,
 @Ai_RowTo_NUMB    SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FCSOD_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen case support order dependents for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17th-May-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.MemberMci_IDNO,
         A.ChildFull_NAME,
         A.RowCount_NUMB
    FROM (SELECT f.MemberMci_IDNO,
                 f.ChildFull_NAME,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.MemberMci_IDNO ) AS ROWNUM
            FROM FCSOD_Y1 f
           WHERE f.Case_IDNO = @An_Case_IDNO
             AND f.OrderSeq_NUMB = @An_OrderSeq_NUMB) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
