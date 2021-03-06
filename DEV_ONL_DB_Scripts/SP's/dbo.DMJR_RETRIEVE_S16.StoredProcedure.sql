/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S16] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @Ac_ActivityMajor_CODE CHAR(4),
 @Ai_RowFrom_NUMB       INT = 1,
 @Ai_RowTo_NUMB         INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S16
  *     DESCRIPTION       : Retrieve Remedy Exempt history information for a Case ID and Major Activity code.
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusExempt_CODE CHAR(4) = 'EXMT',
          @Ld_Low_DATE          DATE = '01/01/0001';

  SELECT Y.ReasonStatus_CODE,
         Y.BeginExempt_DATE,
         Y.EndExempt_DATE,
         Y.WorkerUpdate_ID,
         Y.RowCount_NUMB
    FROM (SELECT X.BeginExempt_DATE,
                 X.EndExempt_DATE,
                 X.ReasonStatus_CODE,
                 X.WorkerUpdate_ID,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT a.BeginExempt_DATE,
                         a.EndExempt_DATE,
                         a.ReasonStatus_CODE,
                         a.WorkerUpdate_ID,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Update_DTTM DESC ) AS ORD_ROWNUM
                    FROM (SELECT D.BeginExempt_DATE,
                                 D.EndExempt_DATE,
                                 D.ReasonStatus_CODE,
                                 D.WorkerUpdate_ID,
                                 D.Update_DTTM
                            FROM DMJR_Y1 D
                           WHERE D.Case_IDNO = @An_Case_IDNO
                             AND D.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                             AND D.Status_CODE = @Lc_StatusExempt_CODE
                             AND (D.BeginExempt_DATE != @Ld_Low_DATE
                                   OR CONVERT (DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN D.BeginExempt_DATE AND D.EndExempt_DATE)
                          UNION ALL
                          SELECT H.BeginExempt_DATE,
                                 H.EndExempt_DATE,
                                 H.ReasonStatus_CODE,
                                 H.WorkerUpdate_ID,
                                 H.Update_DTTM
                            FROM HDMJR_Y1 H
                           WHERE H.Case_IDNO = @An_Case_IDNO
                             AND H.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                             AND H.Status_CODE = @Lc_StatusExempt_CODE) AS a) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.row_num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; --END OF DMJR_RETRIEVE_S16

GO
