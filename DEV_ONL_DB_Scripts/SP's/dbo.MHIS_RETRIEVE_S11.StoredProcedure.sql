/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec MHIS_RETRIEVE_S11 @An_MemberMci_IDNO = 256956 , @An_Case_IDNO = 100067
CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S11] (
 @An_MemberMci_IDNO NUMERIC(10 ) = NULL,
 @An_Case_IDNO      NUMERIC(6) = NULL,
 @Ai_RowFrom_NUMB   INT=1,
 @Ai_RowTo_NUMB     INT=10
 )
AS
 /*
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S11
  *     DESCRIPTION       : Retrieves the Members Program assistance History details for the given Case Idno,
                            Member Idno, County Code, WelfareCase Idno, Welfare Idno of the Member,  
                            Support Order Idno, Row From number, Row To number order by Row number.
                           -By Passing Zero in @Ai_RowFrom_NUMB in fetches all rows
  *     DEVELOPED BY      : Imp Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 --begin mhis_retrieve_s11
  DECLARE @Ld_Highdate DATE = '12/31/9999';
  DECLARE @Lc_CPCaseRelationship_CODE     CHAR(1) = 'C',
          @Lc_ActiveCaseMemberStatus_CODE CHAR(1) = 'A';

  WITH Mhis_CTE( MemberMci_IDNO, Case_IDNO, Start_DATE,
   End_DATE, TypeWelfare_CODE, CaseWelfare_IDNO, WelfareMemberMci_IDNO, 
   Reason_CODE, BeginValidity_DATE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB,
    Row_NUMB, RowCount_NUMB )
       AS (SELECT X.MemberMci_IDNO,
                  X.Case_IDNO,
                  X.Start_DATE,
                  X.End_DATE,
                  X.TypeWelfare_CODE,
                  X.CaseWelfare_IDNO,
                  X.WelfareMemberMci_IDNO,
                  X.Reason_CODE,
                  X.BeginValidity_DATE,
                  X.EventGlobalBeginSeq_NUMB,
                  X.EventGlobalEndSeq_NUMB,
                  X.Row_NUMB,
                  X.RowCount_NUMB
             FROM (SELECT M.MemberMci_IDNO,
                          M.Case_IDNO,
                          M.Start_DATE,
                          M.End_DATE,
                          M.TypeWelfare_CODE,
                          M.CaseWelfare_IDNO,
                          M.WelfareMemberMci_IDNO,
                          M.Reason_CODE,
                          M.BeginValidity_DATE,
                          M.EventGlobalBeginSeq_NUMB,
                          M.EventGlobalEndSeq_NUMB,
                          ROW_NUMBER() OVER( ORDER BY M.Case_IDNO ASC, M.start_date DESC) AS Row_NUMB,
                          COUNT(1) OVER() AS RowCount_NUMB
                     FROM MHIS_Y1 M
                    WHERE M.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, M.MemberMci_IDNO)
                      AND M.Case_IDNO = ISNULL(@An_Case_IDNO, M.Case_IDNO)) X
            WHERE ((X.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTO_NUMB)
                OR @Ai_RowFrom_NUMB = 0))
  SELECT CTE.MemberMci_IDNO,
         CTE.Case_IDNO,
         CTE.Start_DATE,
         CTE.End_DATE,
         CTE.TypeWelfare_CODE,
         CTE.CaseWelfare_IDNO,
         CTE.WelfareMemberMci_IDNO,
         CTE.Reason_CODE,
         CP.Last_NAME,
         CP.First_NAME,
         CP.Middle_NAME,
         CP.Suffix_NAME,
         DM.IveParty_IDNO,
         CTE.BeginValidity_DATE,
         CTE.EventGlobalBeginSeq_NUMB,
         CTE.EventGlobalEndSeq_NUMB,
         GL.Worker_ID,
         CTE.RowCount_NUMB
    FROM Mhis_CTE CTE
         JOIN GLEV_Y1 GL
          ON CTE.EventGlobalBeginSeq_NUMB = GL.EventGlobalSeq_NUMB
         JOIN CMEM_Y1 CM
          ON CM.Case_IDNO = CTE.Case_IDNO
         JOIN DEMO_Y1 CP
          ON CM.MemberMci_IDNO = CP.MemberMci_IDNO
          JOIN DEMO_Y1 DM ON DM.MemberMci_IDNO = CTE.MemberMci_IDNO
   WHERE CM.CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
     AND CM.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
   ORDER BY CTE.Row_NUMB;
 END; --END OF MHIS_RETRIEVE_S11

GO
