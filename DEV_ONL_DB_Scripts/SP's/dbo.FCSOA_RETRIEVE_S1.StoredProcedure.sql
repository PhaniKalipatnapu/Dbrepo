/****** Object:  StoredProcedure [dbo].[FCSOA_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FCSOA_RETRIEVE_S1](
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_OrderSeq_NUMB NUMERIC(3, 0),
 @Ai_RowFrom_NUMB  SMALLINT,
 @Ai_RowTo_NUMB    SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FCSOA_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen case support order accounts for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 17th-May-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.ObligationType_CODE,
         A.FrequencyDue_AMNT,
         A.OrderArrears_AMNT,
         A.OrderArrearsAdj_AMNT,
         A.Account_NUMB,
         A.RowCount_NUMB
    FROM (SELECT f.ObligationType_CODE,
                 f.FrequencyDue_AMNT,
                 f.OrderArrears_AMNT,
                 f.OrderArrearsAdj_AMNT,
                 f.Account_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.ObligationType_CODE ) AS ROWNUM
            FROM FCSOA_Y1 f
           WHERE f.Case_IDNO = @An_Case_IDNO
             AND f.OrderSeq_NUMB = @An_OrderSeq_NUMB) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
