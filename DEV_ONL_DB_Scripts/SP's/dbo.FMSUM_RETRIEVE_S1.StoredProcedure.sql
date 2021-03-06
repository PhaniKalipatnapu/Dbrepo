/****** Object:  StoredProcedure [dbo].[FMSUM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FMSUM_RETRIEVE_S1](
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ad_From_DATE      DATE,
 @Ad_To_DATE        DATE,
 @Ai_RowFrom_NUMB   SMALLINT,
 @Ai_RowTo_NUMB     SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FMSUM_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen member event summary details for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-08-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.Summary_DATE,
         A.SummaryType_CODE,
         A.PartArrears_AMNT,
         A.ClientUra_AMNT,
         A.ArrearsRecoupment_AMNT,
         A.RowCount_NUMB
    FROM (SELECT f.Summary_DATE,
                 f.SummaryType_CODE,
                 f.PartArrears_AMNT,
                 f.ClientUra_AMNT,
                 f.ArrearsRecoupment_AMNT,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.Summary_DATE ) AS ROWNUM
            FROM FMSUM_Y1 f
           WHERE f.MemberMci_IDNO = @An_MemberMci_IDNO
             AND f.Summary_DATE >= @Ad_From_DATE
             AND f.Summary_DATE <= @Ad_To_DATE) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
