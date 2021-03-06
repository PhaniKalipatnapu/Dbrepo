/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S99]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S99](
 @An_Case_IDNO               NUMERIC(6),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ai_RowFrom_NUMB            INT          = 1,
 @Ai_RowTo_NUMB              INT          = 10
 )
AS
 /*                                                                                                                                                                                     
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S99                                                                                                                                            
  *     DESCRIPTION       : Procedure to Retrieves the participant name associated with the obligation 
                            and obligation details associated with the support order for a case                                                                                                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                                                                                  
  *     DEVELOPED ON      : 11/26/2011                                                                                                                                                
  *     MODIFIED BY       :                                                                                                                                                             
  *     MODIFIED ON       :                                                                                                                                                             
  *     VERSION NO        : 1                                                                                                                                                           
 */
 BEGIN
  DECLARE @Ld_High_DATE      DATE    = '12/31/9999';

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
                          O.OrderSeq_NUMB,
                          O.ObligationSeq_NUMB,
                          o.TypeDebt_CODE,
                          o.MemberMci_IDNO,
                          o.Fips_CODE,
                          LS.TransactionCurSup_AMNT AS Periodic_AMNT,
                          LS.TypeWelfare_CODE,
                          LS.SupportYearMonth_NUMB,
                          COUNT(1) OVER() AS RowCount_NUMB,
                          ROW_NUMBER() OVER( ORDER BY LS.SupportYearMonth_NUMB) AS Row_NUMB
                     FROM LSUP_Y1 LS
                          JOIN OBLE_Y1 o
                           ON o.Case_IDNO = LS.Case_IDNO
                              AND o.OrderSeq_NUMB = LS.OrderSeq_NUMB
                              AND o.ObligationSeq_NUMB = LS.ObligationSeq_NUMB
                          JOIN SORD_Y1 s
                           ON s.Case_IDNO = o.Case_IDNO
                              AND s.OrderSeq_NUMB = o.OrderSeq_NUMB
                    WHERE LS.Case_IDNO = @An_Case_IDNO
                      AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                      AND LS.EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB
                      AND o.BeginObligation_DATE = (SELECT MAX(f.BeginObligation_DATE)
                                                      FROM OBLE_Y1 f
                                                     WHERE f.Case_IDNO = LS.Case_IDNO
                                                       AND f.OrderSeq_NUMB = LS.OrderSeq_NUMB
                                                       AND f.ObligationSeq_NUMB = LS.ObligationSeq_NUMB
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
         Y.RowCount_NUMB
    FROM Oble_CTE Y
         LEFT OUTER JOIN DEMO_Y1 D
          ON Y.MemberMci_IDNO = D.MemberMci_IDNO
   ORDER BY Row_NUMB;
   
 END; --End Of Procedure LSUP_RETRIEVE_S99 


GO
