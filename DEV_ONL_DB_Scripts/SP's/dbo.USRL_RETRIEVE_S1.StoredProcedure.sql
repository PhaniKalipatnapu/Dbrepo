/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
 *     PROCEDURE NAME    : USRL_RETRIEVE_S1   
 *     DESCRIPTION       : Retrieve User Office Role details for a Role Idno and a common Office and Worker Idno between two tables.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 08-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S1](
 @An_Office_IDNO  NUMERIC(3),
 @Ac_Role_ID      CHAR(10),
 @Ai_RowFrom_NUMB INT,
 @Ai_RowTo_NUMB   INT
 )
AS
 BEGIN
  DECLARE @Li_Zero_NUMB       INT = 0,
          @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Systemdate_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT Y.Worker_ID,
         Y.Role_ID,
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.AlphaRangeFrom_CODE,
         Y.AlphaRangeTo_CODE,
         Y.CasesAssigned_QNTY,
         Y.TransactionEventSeq_NUMB,
         Y.RowCount_NUMB
    FROM (SELECT X.Worker_ID,
                 X.Role_ID,
                 X.Last_NAME,
                 X.Suffix_NAME,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.AlphaRangeFrom_CODE,
                 X.AlphaRangeTo_CODE,
                 X.CasesAssigned_QNTY,
                 X.TransactionEventSeq_NUMB,
                 X.Row_NUMB,
                 X.RowCount_NUMB
            FROM (SELECT b.Worker_ID,
                         b.Role_ID,
                         a.Last_NAME,
                         a.Suffix_NAME,
                         a.First_NAME,
                         a.Middle_NAME,
                         b.AlphaRangeFrom_CODE,
                         b.AlphaRangeTo_CODE,
                         b.CasesAssigned_QNTY,
                         b.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY b.Worker_ID) AS Row_NUMB
                    FROM USEM_Y1 a
                         JOIN USRL_Y1 b
                          ON a.Worker_ID = b.Worker_ID
                         JOIN UASM_Y1 c
                          ON b.Office_IDNO = c.Office_IDNO
                             AND b.Worker_ID = c.Worker_ID
                   WHERE c.Office_IDNO = @An_Office_IDNO
                     AND b.Role_ID = @Ac_Role_ID
                     AND c.Effective_DATE <= @Ld_Systemdate_DTTM
                     AND b.Expire_DATE > @Ld_Systemdate_DTTM
                     AND c.Expire_DATE > @Ld_Systemdate_DTTM
                     AND b.EndValidity_DATE = @Ld_High_DATE
                     AND c.EndValidity_DATE = @Ld_High_DATE
                     AND a.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE (X.Row_NUMB <= @Ai_RowTo_NUMB)
              OR (@Ai_RowTo_NUMB = @Li_Zero_NUMB)) Y
   WHERE (Y.Row_NUMB >= @Ai_RowFrom_NUMB
       OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB)
   ORDER BY Y.Row_NUMB;
 END


GO
