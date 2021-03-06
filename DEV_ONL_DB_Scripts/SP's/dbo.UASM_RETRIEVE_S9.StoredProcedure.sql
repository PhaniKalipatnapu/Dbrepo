/****** Object:  StoredProcedure [dbo].[UASM_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UASM_RETRIEVE_S9] (
 @Ac_Worker_ID    CHAR(30) = NULL,
 @Ai_RowFrom_NUMB INT = 1,
 @Ai_RowTo_NUMB   INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : UASM_RETRIEVE_S9
  *     DESCRIPTION       : Retrieve Office Code, Office Name, Description Code, Work Phone number, Date 
  *						   from which worker effectively assigned to the office, Date on which the worker 
  *						   association with that office will Expire and Unique Sequence Number for a Unique Worker ID, 
  *						   County Code and Unique Office code for each office in user office is equal to the 
  *						   Unique Office Code in user reference.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/14/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Office_IDNO,
         O.Office_NAME,
         Y.WorkPhone_NUMB,
         Y.Effective_DATE,
         Y.Expire_DATE,
         Y.TransactionEventSeq_NUMB,
         Y.RowCount_NUMB
    FROM (SELECT X.Office_IDNO,
                 X.WorkPhone_NUMB,
                 X.Effective_DATE,
                 X.Expire_DATE,
                 X.TransactionEventSeq_NUMB,
                 X.Row_NUMB,
                 X.RowCount_NUMB
            FROM (SELECT a.Office_IDNO,
                         a.WorkPhone_NUMB,
                         a.Effective_DATE,
                         a.Expire_DATE,
                         a.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Office_IDNO) AS Row_NUMB
                    FROM UASM_Y1 a
                   WHERE a.Worker_ID = ISNULL(@Ac_Worker_ID, a.Worker_ID)
                     AND a.EndValidity_DATE = @Ld_High_DATE) X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) Y
         JOIN OFIC_Y1 O
          ON Y.Office_IDNO = O.Office_IDNO
   WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Row_NUMB;
 END


GO
