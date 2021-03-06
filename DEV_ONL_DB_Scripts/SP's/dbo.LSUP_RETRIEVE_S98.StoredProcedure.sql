/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S98]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S98](
 @An_Case_IDNO               NUMERIC(6),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ai_RowFrom_NUMB            INT = 1,
 @Ai_RowTo_NUMB              INT = 10
 )
AS
 /*                                                                                                                                                                                                               
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S98                                                                                                                                                                      
  *     DESCRIPTION       : Procedure To Retrieves the participant name associated 
                            with the obligation and obligation details associated 
                            with the support order for a case 
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                            
  *     DEVELOPED ON      : 26/11/2011                                                                                                                                                                          
  *     MODIFIED BY       :                                                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                                                     
 */
 BEGIN
  DECLARE @Lc_TypeRecord_CODE CHAR(1) = 'O',
          @Ld_High_DATE       DATE    = '12/31/9999';

  WITH Oble_CTE
       AS (SELECT X.OrderSeq_NUMB,
                  X.Order_IDNO,
                  X.ObligationSeq_NUMB,
                  X.TypeDebt_CODE,
                  X.MemberMci_IDNO,
                  X.Fips_CODE,
                  X.TransactionCurSup_AMNT,
                  X.TransactionNaa_AMNT,
                  X.TransactionPaa_AMNT,
                  X.TransactionTaa_AMNT,
                  X.TransactionCaa_AMNT,
                  X.TransactionUpa_AMNT,
                  X.TransactionUda_AMNT,
                  X.TransactionIvef_AMNT,
                  X.TransactionMedi_AMNT,
                  X.TransactionNffc_AMNT,
                  X.TransactionNonIvd_AMNT,
                  X.TypeWelfare_CODE,
                  X.SupportYearMonth_NUMB,
                  X.Row_Numb,
                  X.RowCount_NUMB
             FROM (SELECT S.OrderSeq_NUMB,
                          s.Order_IDNO,
                          O.ObligationSeq_NUMB,
                          o.TypeDebt_CODE,
                          o.MemberMci_IDNO,
                          o.Fips_CODE,
                          LS.TransactionCurSup_AMNT,
                          LS.TransactionNaa_AMNT,
                          LS.TransactionPaa_AMNT,
                          LS.TransactionTaa_AMNT,
                          LS.TransactionCaa_AMNT,
                          LS.TransactionUpa_AMNT,
                          LS.TransactionUda_AMNT,
                          LS.TransactionIvef_AMNT,
                          LS.TransactionMedi_AMNT,
                          LS.TransactionNffc_AMNT,
                          LS.TransactionNonIvd_AMNT,
                          LS.TypeWelfare_CODE,
                          Ls.SupportYearMonth_NUMB,
                          COUNT(1) OVER() AS RowCount_Numb,
                          ROW_NUMBER() OVER( ORDER BY LS.SupportYearMonth_NUMB) AS Row_Numb
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
                      AND LS.TypeRecord_CODE = @Lc_TypeRecord_CODE
                      AND o.BeginObligation_DATE = (SELECT MAX(f.BeginObligation_DATE)
                                                      FROM OBLE_Y1  f
                                                     WHERE f.Case_IDNO = LS.Case_IDNO
                                                       AND f.OrderSeq_NUMB = LS.OrderSeq_NUMB
                                                       AND f.ObligationSeq_NUMB = LS.ObligationSeq_NUMB
                                                       AND f.EndValidity_DATE = @Ld_High_DATE)
                      AND o.EndValidity_DATE = @Ld_High_DATE
                      AND s.EndValidity_DATE = @Ld_High_DATE) X
            WHERE X.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB)
  SELECT Y.Order_IDNO,
         d.Last_NAME,
         d.Suffix_NAME,
         d.First_NAME,
         d.Middle_NAME,
         (Y.TransactionCurSup_AMNT + Y.TransactionNaa_AMNT + Y.TransactionPaa_AMNT + Y.TransactionTaa_AMNT + Y.TransactionCaa_AMNT + Y.TransactionUpa_AMNT + Y.TransactionUda_AMNT + Y.TransactionIvef_AMNT + Y.TransactionMedi_AMNT + Y.TransactionNffc_AMNT + Y.TransactionNonIvd_AMNT) AS Periodic_AMNT,
         Y.TypeWelfare_CODE,
         Y.SupportYearMonth_NUMB,
         dbo.BATCH_COMMON$SF_OBLE_ARREARS(@An_Case_IDNO, Y.OrderSeq_NUMB, Y.ObligationSeq_NUMB, @An_EventGlobalSeq_NUMB) AS Arrears_AMNT,
         (SELECT u.DescriptionNote_TEXT
            FROM UNOT_Y1 u
           WHERE u.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB) AS DescriptionNote_TEXT,
         Y.RowCount_NUMB
    FROM Oble_CTE Y
         LEFT OUTER JOIN DEMO_Y1 D
          ON Y.MemberMci_IDNO = D.MemberMci_IDNO
   ORDER BY Row_NUMB;
   
 END; --End Of Procedure LSUP_RETRIEVE_S98 


GO
