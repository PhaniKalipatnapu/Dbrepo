/****** Object:  StoredProcedure [dbo].[EMQW_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMQW_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT=1,
 @Ai_RowTo_NUMB     INT=10
 )
AS
 /*
 *     PROCEDURE NAME     : EMQW_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve State's Quarterly Wage details for a Member Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT Y.Fein_IDNO,
         Y.Employer_NAME,
         Y.MatchCode_DATE,
         Y.Sein_IDNO,
         Y.Line1_ADDR,
         Y.Line2_ADDR,
         Y.City_ADDR,
         Y.State_ADDR,
         Y.Zip_ADDR,
         Y.Wage_AMNT,
         Y.RowCount_NUMB
    FROM (SELECT X.MatchCode_DATE,
                 X.Fein_IDNO,
                 X.Sein_IDNO,
                 X.Employer_NAME,
                 X.Line1_ADDR,
                 X.Line2_ADDR,
                 X.City_ADDR,
                 X.State_ADDR,
                 X.Zip_ADDR,
                 X.Wage_AMNT,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT E.MatchCode_DATE,
                         E.Fein_IDNO,
                         E.Sein_IDNO,
                         E.Employer_NAME,
                         E.Line1_ADDR,
                         E.Line2_ADDR,
                         E.City_ADDR,
                         E.State_ADDR,
                         E.Zip_ADDR,
                         E.Wage_AMNT,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY E.Sein_IDNO) AS ORD_ROWNUM
                    FROM EMQW_Y1 E
                   WHERE E.MemberMci_IDNO = @An_MemberMci_IDNO) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.row_num >= @Ai_RowFrom_NUMB
   ORDER BY ROW_NUM;
 END; --End of EMQW_RETRIEVE_S1

GO
