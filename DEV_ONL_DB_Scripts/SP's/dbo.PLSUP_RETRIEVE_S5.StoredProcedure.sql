/****** Object:  StoredProcedure [dbo].[PLSUP_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLSUP_RETRIEVE_S5] (
 @An_Case_IDNO           NUMERIC(6, 0),
 @An_OrderSeq_NUMB       NUMERIC(2, 0),
 @An_ObligationSeq_NUMB  NUMERIC(2, 0),
 @An_EventGlobalSeq_NUMB NUMERIC(19, 0),
 @Ai_RowFrom_NUMB        INT=1,
 @Ai_RowTo_NUMB          INT=10
 )
AS
 /*
  *     PROCEDURE NAME    : PLSUP_RETRIEVE_S5
  *     DESCRIPTION       : Procedure is  used  to populate the preview popup while modifying an existing obligation.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Conversion9999_NUMB		  INT = 9999,
          @Li_Zero_NUMB                   SMALLINT =0,
          @Lc_ArrColumn_CODE              CHAR(1) = 'A',
          @Lc_MsoColumn_CODE              CHAR(1) = 'M';

  SELECT Y.SupportYearMonth_NUMB,
         Y.TypeWelfare_CODE,
         Y.ModifiedMso_AMNT,
         Y.OweTotCurSup_AMNT,
         Y.AdjustMso_AMNT,
         Y.AdjustArrears_AMNT,
         Y.AssignedArrears_AMNT,
         Y.UnassignedArrears_AMNT,
         Y.Caa_AMNT,
         Y.Ivef_AMNT,
         Y.Nffc_AMNT,
         Y.NonIvd_AMNT,
         Y.Medi_AMNT,
         Y.TotalArrears_AMNT,
         Y.RowCount_NUMB
    FROM (SELECT X.SupportYearMonth_NUMB,
                 X.TypeWelfare_CODE,
                 X.ModifiedMso_AMNT,
                 X.OweTotCurSup_AMNT,
                 X.AdjustMso_AMNT,
                 X.AdjustArrears_AMNT,
                 X.AssignedArrears_AMNT,
                 X.UnassignedArrears_AMNT,
                 X.Caa_AMNT,
                 X.Ivef_AMNT,
                 X.Nffc_AMNT,
                 X.NonIvd_AMNT,
                 X.Medi_AMNT,
                 X.TotalArrears_AMNT,
                 X.ORD_ROWNUM AS ORD_ROWNUM,
                 X.RowCount_NUMB
            FROM (SELECT a.SupportYearMonth_NUMB,
                         a.TypeWelfare_CODE,
                         (a.MtdCurSupOwed_AMNT - a.AppTotCurSup_AMNT) AS ModifiedMso_AMNT,
                         a.OweTotCurSup_AMNT,
                         dbo.BATCH_COMMON$SF_GET_CURRENT_AMOUNTS(a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB, @An_EventGlobalSeq_NUMB, @Lc_MsoColumn_CODE) AS AdjustMso_AMNT,
                         dbo.BATCH_COMMON$SF_GET_CURRENT_AMOUNTS(a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.SupportYearMonth_NUMB, @An_EventGlobalSeq_NUMB, @Lc_ArrColumn_CODE) AS AdjustArrears_AMNT,
                         ((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT)) AS AssignedArrears_AMNT,
                         ((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT)) AS UnassignedArrears_AMNT,
                         (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) AS Caa_AMNT,
                         (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) AS Ivef_AMNT,
                         (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) AS Nffc_AMNT,
                         (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) AS NonIvd_AMNT,
                         (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) AS Medi_AMNT,
                         (((a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT) + (a.OweTotNonIvd_AMNT - a.AppTotNonIvd_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT)) - a.AppTotFuture_AMNT) AS TotalArrears_AMNT,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.SupportYearMonth_NUMB DESC) AS ORD_ROWNUM
                    FROM PLSUP_Y1 a
                   WHERE a.Case_IDNO = @An_Case_IDNO
                     AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                     AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
                     AND a.SupportYearMonth_NUMB >= (SELECT ISNULL(MIN(b.SupportYearMonth_NUMB), @Li_Zero_NUMB)
                                                       FROM LSUP_Y1 b
                                                      WHERE a.Case_IDNO = b.Case_IDNO
                                                        AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                        AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                                        AND b.EventFunctionalSeq_NUMB = @Li_Conversion9999_NUMB)
                     AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                                    FROM PLSUP_Y1 b
                                                   WHERE b.Case_IDNO = a.Case_IDNO
                                                     AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                     AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                     AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB)) X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END; --End of PLSUP_RETRIEVE_S5

GO
