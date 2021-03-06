/****** Object:  StoredProcedure [dbo].[BSUP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSUP_RETRIEVE_S1] (
 @An_Case_IDNO    	NUMERIC(6, 0),
 @Ai_RowFrom_NUMB	INT = 1,
 @Ai_RowTo_NUMB   	INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : BSUP_RETRIEVE_S1
  *     DESCRIPTION       : This procedure is used to used to view current and historical billing suppression and override dates and reasons.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN

  SELECT X.TypeAction_CODE,
         X.Begin_DATE,
         X.End_DATE,
         X.Reason_CODE,
         X.BeginValidity_DATE,         
         X.EventGlobalBeginSeq_NUMB,
         X.Worker_ID,
         X.ORD_ROWNUM,
         X.RowCount_NUMB
    FROM (SELECT Y.TypeAction_CODE,
                 Y.Begin_DATE,
                 Y.End_DATE,
                 Y.Reason_CODE,
                 Y.BeginValidity_DATE,
                 Y.EventGlobalBeginSeq_NUMB,
                 Y.Worker_ID,
                 Y.ORD_ROWNUM, 
                 Y.RowCount_NUMB
            FROM (SELECT a.TypeAction_CODE,
                         a.Begin_DATE,
                         a.End_DATE,
                         a.Reason_CODE, 
                         a.BeginValidity_DATE,
                         a.EventGlobalBeginSeq_NUMB,
                         g.Worker_ID,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Begin_DATE DESC,a.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                    FROM BSUP_Y1 a 
                         JOIN 
                         GLEV_Y1 g
                      ON g.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB
                   WHERE a.Case_IDNO = @An_Case_IDNO ) Y
           WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB) X
   WHERE X.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END; --END OF BSUP_RETRIEVE_S1
 

GO
