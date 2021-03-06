/****** Object:  StoredProcedure [dbo].[INCM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INCM_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT =1,
 @Ai_RowTo_NUMB     INT =10
 )
AS
 /*
 *     PROCEDURE NAME    : INCM_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Income Expense details for a Member Idno and Income Type Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE= '12/31/9999';

  SELECT Y.SourceIncome_CODE,
         Y.TransactionEventSeq_NUMB,
         Y.Income_AMNT,
         Y.FreqIncome_CODE,
         Y.OtherParty_IDNO,
         Y.Begin_DATE,
         Y.End_DATE,
         (SELECT o.OtherParty_NAME
            FROM OTHP_Y1 o
           WHERE o.OtherParty_IDNO = Y.OtherParty_IDNO
             AND o.EndValidity_DATE = @Ld_High_DATE) AS OtherParty_NAME,
         Y.TypeIncome_CODE,
         RowCount_NUMB
    FROM (SELECT X.Income_AMNT,
                 X.FreqIncome_CODE,
                 X.SourceIncome_CODE,
                 X.OtherParty_IDNO,
                 X.Begin_DATE,
                 X.End_DATE,
                 X.TransactionEventSeq_NUMB,
                 X.TypeIncome_CODE,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT a.Income_AMNT,
                         a.FreqIncome_CODE,
                         a.SourceIncome_CODE,
                         a.OtherParty_IDNO,
                         a.Begin_DATE,
                         a.End_DATE,
                         a.TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                         a.TypeIncome_CODE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Update_DTTM DESC) AS ORD_ROWNUM
                    FROM INCM_Y1 a
                   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND a.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.row_num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; --End of INCM_RETRIEVE_S1


GO
