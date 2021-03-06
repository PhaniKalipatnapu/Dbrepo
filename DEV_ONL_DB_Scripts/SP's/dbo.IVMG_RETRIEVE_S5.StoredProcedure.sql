/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S5] (
 @An_CpMci_IDNO				NUMERIC(10, 0),
 @An_CaseWelfare_IDNO		NUMERIC(10, 0) = NULL,
 @An_WelfareYearMonth_NUMB	NUMERIC(6, 0),
 @Ac_WelfareElig_CODE		CHAR(1),
 @Ai_RowFrom_NUMB			INT,
 @Ai_RowTo_NUMB				INT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S5
  *     DESCRIPTION       : Retrieves the TANF grant information or Foster Care board payment information associated with a given member or a case.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_WelfareEligIva_CODE CHAR(1) = 'A',
		  @Lc_WelfareEligIve_CODE CHAR(1) = 'F',
          @Ln_Zero_NUMB                            NUMERIC(1) = 0;

   SELECT CaseWelfare_IDNO,
         WelfareYearMonth_NUMB,
         WelfareElig_CODE,
         MtdAssistExpend_AMNT,
         LtdAssistExpend_AMNT,
         MtdAssistRecoup_AMNT,
         LtdAssistRecoup_AMNT,
         UraBalances_AMNT,
         ReceiptsApplToArr_AMNT,
         AppPriorMonthBal_AMNT,
         Defra_AMNT,
         CpMci_IDNO,
         Event_DTTM,
         Y.Worker_ID,
         RowCount_NUMB
    FROM(SELECT X.CaseWelfare_IDNO,
                X.WelfareYearMonth_NUMB,
                X.WelfareElig_CODE,
                X.MtdAssistExpend_AMNT,
                X.LtdAssistExpend_AMNT,
                X.MtdAssistRecoup_AMNT,
                X.LtdAssistRecoup_AMNT,
                X.UraBalances_AMNT,
                X.ReceiptsApplToArr_AMNT,
                X.AppPriorMonthBal_AMNT,
                X.Defra_AMNT,
                X.CpMci_IDNO,
                X.Event_DTTM,
                X.Worker_ID,
                X.ORD_ROWNUM AS rnm,
                X.RowCount_NUMB
           FROM(SELECT A.CaseWelfare_IDNO,
                       A.WelfareYearMonth_NUMB,
                       A.WelfareElig_CODE,
                       A.MtdAssistExpend_AMNT,
                       A.LtdAssistExpend_AMNT,
                       dbo.BATCH_COMMON$SF_GET_LWEL(@An_CpMci_IDNO, 'CG', A.WelfareYearMonth_NUMB, A.CaseWelfare_IDNO) AS MtdAssistRecoup_AMNT,
                       A.LtdAssistRecoup_AMNT,
                       (A.LtdAssistExpend_AMNT - a.LtdAssistRecoup_AMNT) AS UraBalances_AMNT,
                       dbo.BATCH_COMMON$SF_GET_LWEL(@An_CpMci_IDNO, 'AG', A.WelfareYearMonth_NUMB, A.CaseWelfare_IDNO) AS ReceiptsApplToArr_AMNT,
                       dbo.BATCH_COMMON$SF_GET_LWEL(@An_CpMci_IDNO, 'PG', A.WelfareYearMonth_NUMB, A.CaseWelfare_IDNO) AS AppPriorMonthBal_AMNT,
                       A.Defra_AMNT,
                       A.CpMci_IDNO,
                       G.Event_DTTM,
                       G.Worker_ID,
                       COUNT(1) OVER() AS RowCount_NUMB,
                       ROW_NUMBER() OVER( ORDER BY WelfareYearMonth_NUMB DESC, CaseWelfare_IDNO) AS ORD_ROWNUM
                  FROM IVMG_Y1 A,
                       GLEV_Y1 G
                 WHERE((A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                        AND A.WelfareElig_CODE = @Lc_WelfareEligIve_CODE)
                        OR (A.CpMci_IDNO =  @An_CpMci_IDNO  
                            AND A.CaseWelfare_IDNO IN (SELECT DISTINCT I.CaseWelfare_IDNO 
														FROM IVMG_Y1 I
														WHERE I.CpMci_IDNO = @An_CpMci_IDNO
														AND I.CaseWelfare_IDNO = ISNULL(@An_CaseWelfare_IDNO, I.CaseWelfare_IDNO)
														AND I.WelfareElig_CODE IN ( @Lc_WelfareEligIva_CODE ))))
                  AND A.WelfareYearMonth_NUMB <= @An_WelfareYearMonth_NUMB
                  AND A.EventGlobalSeq_NUMB = (SELECT MAX(B.EventGlobalSeq_NUMB)
                                                 FROM IVMG_Y1 B
                                                WHERE B.CaseWelfare_IDNO = A.CaseWelfare_IDNO
                                                  AND B.WelfareElig_CODE = A.WelfareElig_CODE
												  AND B.CpMci_IDNO = A.CpMci_IDNO
                                                  AND B.WelfareYearMonth_NUMB = A.WelfareYearMonth_NUMB)
                  AND G.EventGlobalSeq_NUMB = A.EventGlobalSeq_NUMB) AS X
          WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;

 END; -- End of IVMG_RETRIEVE_S5

GO
