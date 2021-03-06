/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S60]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S60] (
 @Ac_Worker_ID    CHAR(30),
 @An_Office_IDNO  NUMERIC(3) = NULL,
 @Ai_RowFrom_NUMB INT = 1,
 @Ai_RowTo_NUMB   INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : USRL_RETRIEVE_S60
  *     DESCRIPTION       : Retrieve User Office Roles for a Unique Office Code, Worker ID where Worker ID 
  *                         in User Roles is equal to Worker ID in Role reference date end validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/11/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  WITH UserRole_CTE (Office_IDNO, Role_ID, Role_NAME, WorkerSub_ID, Supervisor_ID, AlphaRangeFrom_CODE, AlphaRangeTo_CODE, Effective_DATE, Expire_DATE, TransactionEventSeq_NUMB, RowCount_NUMB, Row_NUMB, CasesAssigned_QNTY)
       AS (SELECT Y.Office_IDNO,
                  Y.Role_ID,
                  Y.Role_NAME,
                  Y.WorkerSub_ID,
                  Y.Supervisor_ID,
                  Y.AlphaRangeFrom_CODE,
                  Y.AlphaRangeTo_CODE,
                  Y.Effective_DATE,
                  Y.Expire_DATE,
                  Y.TransactionEventSeq_NUMB,
                  Y.RowCount_NUMB,
                  Y.Row_NUMB,
                  Y.CasesAssigned_QNTY
             FROM (SELECT X.Office_IDNO,
                          X.Role_ID,
                          X.Role_NAME,
                          X.WorkerSub_ID,
                          X.Supervisor_ID,
                          X.AlphaRangeFrom_CODE,
                          X.AlphaRangeTo_CODE,
                          X.Effective_DATE,
                          X.Expire_DATE,
                          X.TransactionEventSeq_NUMB,
                          X.RowCount_NUMB,
                          X.Row_NUMB,
                          X.CasesAssigned_QNTY
                     FROM (SELECT a.Office_IDNO,
                                  a.Role_ID,
                                  b.Role_NAME,
                                  a.WorkerSub_ID,
                                  a.Supervisor_ID,
                                  a.AlphaRangeFrom_CODE,
                                  a.AlphaRangeTo_CODE,
                                  a.Effective_DATE,
                                  a.Expire_DATE,
                                  a.TransactionEventSeq_NUMB,
                                  COUNT(1) OVER() AS RowCount_NUMB,
                                  a.CasesAssigned_QNTY,
                                  ROW_NUMBER() OVER( ORDER BY a.Role_ID) AS Row_NUMB
                             FROM USRL_Y1 a
                                  JOIN ROLE_Y1 b
                                   ON a.Role_ID = b.Role_ID
                            WHERE a.Worker_ID = @Ac_Worker_ID
                              AND a.Office_IDNO = ISNULL(@An_Office_IDNO, a.Office_IDNO)
                              AND a.EndValidity_DATE = @Ld_High_DATE
                              AND b.EndValidity_DATE = @Ld_High_DATE ) X
                    WHERE (X.Row_NUMB <= @Ai_RowTo_NUMB OR @Ai_RowTo_NUMB = 0) ) Y
            WHERE (Y.Row_NUMB >= @Ai_RowFrom_NUMB OR @Ai_RowFrom_NUMB = 0) )
  SELECT CTE.Office_IDNO,
         CTE.Role_ID,
         CTE.Role_NAME,
         CTE.WorkerSub_ID,
         SUB.First_NAME AS SubstituteFirst_NAME,
         SUB.Last_NAME AS SubstituteLast_NAME,
         SUB.Middle_NAME AS SubstituteMiddle_NAME,
         CTE.Supervisor_ID,
         CO.First_NAME AS SupervisorFirst_NAME,
         CO.Last_NAME AS SupervisorLast_NAME,
         CO.Middle_NAME AS SupervisorMiddle_NAME,
         CTE.AlphaRangeFrom_CODE,
         CTE.AlphaRangeTo_CODE,
         CTE.Effective_DATE,
         CTE.Expire_DATE,
         CTE.RowCount_NUMB,
         CTE.CasesAssigned_QNTY,
         CTE.TransactionEventSeq_NUMB,
         CTE.Row_NUMB
    FROM UserRole_CTE CTE
         JOIN ROLE_Y1 R
          ON CTE.Role_ID = R.Role_ID
         LEFT OUTER JOIN USEM_Y1 CO
          ON CO.Worker_ID = CTE.Supervisor_ID
         LEFT OUTER JOIN USEM_Y1 SUB
          ON SUB.Worker_ID = CTE.WorkerSub_ID
   WHERE R.EndValidity_DATE = @Ld_High_DATE
     AND ISNULL(CO.EndValidity_DATE, @Ld_High_DATE) = @Ld_High_DATE
     AND ISNULL(SUB.EndValidity_DATE, @Ld_High_DATE) = @Ld_High_DATE
   ORDER BY Row_NUMB;
 END


GO
