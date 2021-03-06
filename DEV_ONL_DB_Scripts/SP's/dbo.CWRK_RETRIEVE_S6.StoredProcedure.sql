/****** Object:  StoredProcedure [dbo].[CWRK_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 *     PROCEDURE NAME    : CWRK_RETRIEVE_S6
 *     DESCRIPTION       : Get the caseworker details for a case.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

CREATE PROCEDURE [dbo].[CWRK_RETRIEVE_S6](
 @An_Case_IDNO    NUMERIC(6),
 @Ai_RowFrom_NUMB INT,
 @Ai_RowTo_NUMB   INT
 )
AS
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Worker_ID,
         Y.Office_IDNO,
         OI.Office_NAME,
         Y.Role_ID,
         R.Role_NAME,
         Y.Effective_DATE,
         Y.End_DATE,
         Y.Update_DTTM,
         Y.WorkerUpdate_ID,
         Y.Row_NUMB,
         Y.RowCount_NUMB
    FROM (SELECT X.Worker_ID,
                 X.Office_IDNO,
                 X.Role_ID,
                 X.Effective_DATE,
                 X.End_DATE,
                 X.Update_DTTM,
                 X.WorkerUpdate_ID,
                 X.Row_NUMB,
                 X.RowCount_NUMB
            FROM (SELECT a.Worker_ID,
                         a.Office_IDNO,
                         a.Role_ID,
                         a.Effective_DATE AS Effective_DATE,
                         a.Expire_DATE AS End_DATE,
                         a.Update_DTTM,
                         a.WorkerUpdate_ID,
                         a.transactioneventseq_numb,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Expire_DATE DESC, a.Update_DTTM DESC) AS Row_NUMB
                    FROM CWRK_Y1 a
                   WHERE a.Case_IDNO = @An_Case_IDNO) X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) Y
         JOIN OFIC_Y1 OI
          ON Y.Office_IDNO = OI.Office_IDNO
         JOIN ROLE_Y1 R
          ON Y.Role_ID = R.Role_ID
             AND R.EndValidity_DATE = @Ld_High_DATE
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB 
   ORDER BY Row_NUMB;
 END


GO
