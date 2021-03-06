/****** Object:  StoredProcedure [dbo].[ACEN_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ACEN_RETRIEVE_S5] (
 @An_Case_IDNO    NUMERIC(6, 0),
 @Ai_RowFrom_NUMB INT=1,
 @Ai_RowTo_NUMB   INT=10
 )
AS
 /*
 *     PROCEDURE NAME    : ACEN_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve Active Enforcement details for a Case ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT Y.StatusEnforce_CODE,
         Y.ReasonStatus_CODE,
         Y.BeginValidity_DATE,
         Y.EndValidity_DATE,
         Y.WorkerUpdate_ID,
         Y.BeginExempt_DATE,
         Y.EndExempt_DATE,
         Y.RowCount_NUMB
    FROM (SELECT X.BeginValidity_DATE,
                 X.EndValidity_DATE,
                 X.StatusEnforce_CODE,
                 X.ReasonStatus_CODE,
                 X.WorkerUpdate_ID,
                 X.BeginExempt_DATE,
                 X.EndExempt_DATE,
                 X.RowCount_NUMB,
                 X.Row_Numb
            FROM (SELECT a.BeginValidity_DATE,
                         a.EndValidity_DATE,
                         a.StatusEnforce_CODE,
                         a.ReasonStatus_CODE,
                         a.WorkerUpdate_ID,
                         a.Update_DTTM,
                         a.BeginExempt_DATE,
                         a.EndExempt_DATE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER ( ORDER BY a.Update_DTTM DESC ) AS Row_Numb
                    FROM ACEN_Y1 a
                   WHERE a.Case_IDNO = @An_Case_IDNO) AS X
           WHERE X.Row_Numb <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.Row_Numb >= @Ai_RowFrom_NUMB;
 END; --End of ACEN_RETRIEVE_S5


GO
