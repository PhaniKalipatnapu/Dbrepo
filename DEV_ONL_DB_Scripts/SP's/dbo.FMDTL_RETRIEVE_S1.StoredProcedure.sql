/****** Object:  StoredProcedure [dbo].[FMDTL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FMDTL_RETRIEVE_S1](
 @An_MemberMci_IDNO       NUMERIC(10, 0),
 @Ad_From_DATE            DATE,
 @Ad_To_DATE              DATE,
 @Ac_TransactionType_CODE CHAR(4),
 @Ai_RowFrom_NUMB         SMALLINT,
 @Ai_RowTo_NUMB           SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FMDTL_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen case member account statement details for a given member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-16-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.DetailHeader_TEXT,
         A.Transaction_DATE,
         A.TransactionType_CODE,
         A.DetailNotes_TEXT,
         A.FromAccount_NUMB,
         A.ToAccount_NUMB,
         A.ToType_CODE,
         A.ToAccount_NAME,
         A.FromSubAccount_CODE,
         A.TransactionApplied_AMNT,
         A.TransactionRemaining_AMNT,
         A.PermArrears_AMNT,
         A.CondArrears_AMNT,
         A.TempArrears_AMNT,
         A.NeverArrears_AMNT,
         A.UadArrears_AMNT,
         A.UapArrears_AMNT,
         A.RowCount_NUMB
    FROM (SELECT f.DetailHeader_TEXT,
                 f.Transaction_DATE,
                 f.TransactionType_CODE,
                 f.DetailNotes_TEXT,
                 f.FromAccount_NUMB,
                 f.ToAccount_NUMB,
                 f.ToType_CODE,
                 f.ToAccount_NAME,
                 f.FromSubAccount_CODE,
                 f.TransactionApplied_AMNT,
                 f.TransactionRemaining_AMNT,
                 f.PermArrears_AMNT,
                 f.CondArrears_AMNT,
                 f.TempArrears_AMNT,
                 f.NeverArrears_AMNT,
                 f.UadArrears_AMNT,
                 f.UapArrears_AMNT,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.Transaction_DATE ) AS ROWNUM
            FROM FMDTL_Y1 f
           WHERE f.MemberMci_IDNO = @An_MemberMci_IDNO
             AND f.Transaction_DATE >= @Ad_From_DATE
             AND f.Transaction_DATE <= @Ad_To_DATE
             AND f.TransactionType_CODE = ISNULL(@Ac_TransactionType_CODE, f.TransactionType_CODE)) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
