/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S122]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S122](
 @An_Case_IDNO               NUMERIC(6),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ai_RowFrom_NUMB            INT          = 1,
 @Ai_RowTo_NUMB              INT          = 10
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S122
  *     DESCRIPTION       : Procdure to retrieves the participant name associated 
                            with the obligation and obligation details for a case
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26/11/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  WITH Oble_CTE
       AS (SELECT X.Order_IDNO,
                  X.File_ID,  
                  X.OrderSeq_NUMB,
                  X.ObligationSeq_NUMB,
                  X.TypeDebt_CODE,
                  X.MemberMci_IDNO,
                  X.Fips_CODE,
                  X.Periodic_AMNT,
                  X.TypeWelfare_CODE,
                  X.SupportYearMonth_NUMB,
                  X.Row_NUMB,
                  X.RowCount_NUMB
             FROM (SELECT s.Order_IDNO,
                          s.File_ID,
                          o.OrderSeq_NUMB,
                          o.ObligationSeq_NUMB,
                          o.TypeDebt_CODE,
                          o.MemberMci_IDNO,
                          o.Fips_CODE,
                          LS.TransactionCurSup_AMNT AS Periodic_AMNT,
                          LS.TypeWelfare_CODE,
                          LS.SupportYearMonth_NUMB,
                          COUNT(1) OVER() AS RowCount_NUMB,
                          ROW_NUMBER() OVER( ORDER BY LS.SupportYearMonth_NUMB DESC) AS Row_NUMB
                     FROM OBLE_Y1 o
                          JOIN SORD_Y1 s
                           ON s.Case_IDNO = o.Case_IDNO
                              AND s.OrderSeq_NUMB = o.OrderSeq_NUMB
                          LEFT OUTER JOIN (SELECT LS.Case_IDNO,
                                                  LS.OrderSeq_NUMB,
                                                  LS.ObligationSeq_NUMB,
                                                  LS.SupportYearMonth_NUMB,
                                                  LS.TypeWelfare_CODE,
                                                  LS.TransactionCurSup_AMNT
                                             FROM LSUP_Y1 LS
                                            WHERE LS.Case_IDNO = @An_Case_IDNO
                                              AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                                              AND LS.EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB) AS LS
                           ON o.Case_IDNO = LS.Case_IDNO
                              AND o.OrderSeq_NUMB = LS.OrderSeq_NUMB
                              AND o.ObligationSeq_NUMB = LS.ObligationSeq_NUMB
                    WHERE o.Case_IDNO = @An_Case_IDNO
                      AND o.BeginObligation_DATE = (SELECT MAX(f.BeginObligation_DATE)
                                                      FROM OBLE_Y1  f
                                                     WHERE f.Case_IDNO = o.Case_IDNO
                                                       AND f.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                       AND f.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                       AND f.EndValidity_DATE = @Ld_High_DATE)
                      AND o.EndValidity_DATE = @Ld_High_DATE
                      AND s.EndValidity_DATE = @Ld_High_DATE) X
            WHERE X.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB)
  SELECT Y.Order_IDNO,
         Y.File_ID,
         Y.TypeDebt_CODE,
         Y.MemberMci_IDNO,
         Y.Fips_CODE,
         D.Last_NAME,
         D.Suffix_NAME,
         D.First_NAME,
         D.Middle_NAME,
         Y.Periodic_AMNT,
         dbo.BATCH_COMMON$SF_OBLE_ARREARS(@An_Case_IDNO, Y.OrderSeq_NUMB, Y.ObligationSeq_NUMB, @An_EventGlobalSeq_NUMB) AS Arrears_AMNT,
         Y.TypeWelfare_CODE,
         Y.SupportYearMonth_NUMB,
         (SELECT N.DescriptionNote_TEXT
            FROM UNOT_Y1 N
           WHERE N.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB) AS DescriptionNote_TEXT,
         Y.RowCount_NUMB
    FROM Oble_CTE Y
         JOIN DEMO_Y1 D
          ON Y.MemberMci_IDNO = D.MemberMci_IDNO
   ORDER BY Y.Row_NUMB;
   
 END; --End Of Procedure OBLE_RETRIEVE_S122 


GO
