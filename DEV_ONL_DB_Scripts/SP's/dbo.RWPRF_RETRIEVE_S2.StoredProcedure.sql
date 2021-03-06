/****** Object:  StoredProcedure [dbo].[RWPRF_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RWPRF_RETRIEVE_S2](
 @Ad_BeginFiscal_DATE DATE,
 @Ad_EndFiscal_DATE   DATE,
 @An_County_IDNO      NUMERIC(3, 0),
 @Ac_Worker_ID        CHAR(30),
 @Ai_RowFrom_NUMB     INT = 1,
 @Ai_RowTo_NUMB       INT = 10
 )
AS
 /*    
 *     PROCEDURE NAME    : RWPRF_RETRIEVE_S2  
 *     DESCRIPTION       : Retrieves the worker performance measures details with total.  
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 07-12-2012     
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Li_Zero_NUMB			SMALLINT = 0,
		  @Lc_TypeReportI_CODE	CHAR(1) = 'I',
  		  @Lc_Yes_TEXT			CHAR(1) = 'Y',
          @Lc_No_TEXT			CHAR(1) = 'N',
          @Lc_OrderbyA_CODE		CHAR(1) ='A',
          @Lc_OrderbyB_CODE		CHAR(1) ='B',
          @Lc_All_CODE			CHAR(3) ='ALL';

  SELECT D.Worker_ID,
         D.TotalCases_NUMB,
         D.SupportOrder_PCT,
         D.FederalSupportOrder_PCT,
         D.PaternityEstablishment_PCT,
         D.FederalPaternityEstablishment_PCT,
         D.CollectionCurrency_PCT,
         D.FederalCollectionCurrency_PCT,
         D.CollectionArrear_PCT,
         D.FederalCollectionArrear_PCT,
         D.MedicalSupport_PCT,
         D.FederalMedicalSupport_PCT,
         D.RowCount_NUMB,
         D.OrderbyA_CODE
    FROM (SELECT E.Worker_ID,
                 E.TotalCases_NUMB,
                 E.SupportOrder_PCT,
                 E.FederalSupportOrder_PCT,
                 E.PaternityEstablishment_PCT,
                 E.FederalPaternityEstablishment_PCT,
                 E.CollectionCurrency_PCT,
                 E.FederalCollectionCurrency_PCT,
                 E.CollectionArrear_PCT,
                 E.FederalCollectionArrear_PCT,
                 E.MedicalSupport_PCT,
                 E.FederalMedicalSupport_PCT,
                 E.RowCount_NUMB,
                 E.ORD_ROWNUM AS Row_num,
                 E.ORDERBYA AS OrderbyA_CODE
            FROM (SELECT C.Worker_ID,
                         CAST(C.TotalCases_NUMB AS INT) AS TotalCases_NUMB,
                         CAST(C.SupportOrder_PCT AS INT) AS SupportOrder_PCT,
                         CAST(C.FederalSupportOrder_PCT AS INT) AS FederalSupportOrder_PCT,
                         CAST(C.PaternityEstablishment_PCT AS INT) AS PaternityEstablishment_PCT,
                         CAST(C.FederalPaternityEstablishment_PCT AS INT) AS FederalPaternityEstablishment_PCT,
                         CAST(C.CollectionCurrency_PCT AS INT) AS CollectionCurrency_PCT,
                         CAST(C.FederalCollectionCurrency_PCT AS INT) AS FederalCollectionCurrency_PCT,
                         CAST(C.CollectionArrear_PCT AS INT) AS CollectionArrear_PCT,
                         CAST(C.FederalCollectionArrear_PCT AS INT) AS FederalCollectionArrear_PCT,
                         CAST(C.MedicalSupport_PCT AS INT) AS MedicalSupport_PCT,
                         CAST(C.FederalMedicalSupport_PCT AS INT) AS FederalMedicalSupport_PCT,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY C.Worker_ID) AS ORD_ROWNUM,
                         C.ORDERBYA
                    FROM (SELECT @Lc_All_CODE AS Worker_ID,
								(SELECT SUM(a.TotalCases_NUMB) FROM RWPRF_Y1 a WHERE a.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND a.County_IDNO = ISNULL(@An_County_IDNO, a.County_IDNO)) AS TotalCases_NUMB, 		
								CAST(ROUND((SUM(CAST(CASE x.Line2_INDC WHEN @Lc_Yes_TEXT THEN 1 WHEN @Lc_No_TEXT THEN 0 END AS NUMERIC(1)))*100) /
										SUM(CAST(CASE x.Line1_INDC WHEN @Lc_Yes_TEXT THEN 1 WHEN @Lc_No_TEXT THEN 0 END AS NUMERIC(1))), 0) AS INT) AS SupportOrder_PCT,
								(SELECT AVG(F.FederalSupportOrder_PCT) FROM RWPRF_Y1 F WHERE F.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND F.County_IDNO = ISNULL(@An_County_IDNO, F.County_IDNO)) AS FederalSupportOrder_PCT,	   
								
								(SELECT 
										CASE WHEN ISNULL(B.Line5_NUMB,0) = 0 THEN 0
										ELSE CAST(ROUND((B.Line6_NUMB / B.Line5_NUMB), 0) AS INT) 
										END PaternityEstablishment_PCT
									FROM (SELECT (
													SELECT SUM(CAST(CASE d.Line6_INDC  WHEN @Lc_Yes_TEXT THEN 1 WHEN @Lc_No_TEXT THEN 0 END AS NUMERIC(1)))*100
													FROM RD157_Y1 d
													WHERE d.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
														AND d.EndFiscal_DATE = @Ad_EndFiscal_DATE
														AND d.County_IDNO = ISNULL(@An_County_IDNO, d.County_IDNO)
														AND d.TypeReport_CODE = @Lc_TypeReportI_CODE
												) AS Line6_NUMB,
												(
													SELECT
													SUM(CAST(CASE a.Line5_INDC WHEN @Lc_Yes_TEXT THEN 1 WHEN @Lc_No_TEXT THEN 0 END AS NUMERIC(1)))
													FROM RD157_Y1 a
													WHERE a.BeginFiscal_DATE = DATEADD(YEAR, -1,@Ad_BeginFiscal_DATE)
														AND a.EndFiscal_DATE = DATEADD(YEAR, -1, @Ad_EndFiscal_DATE)
														AND a.County_IDNO = ISNULL(@An_County_IDNO, a.County_IDNO)
														AND a.TypeReport_CODE = @Lc_TypeReportI_CODE) AS Line5_NUMB
										) B
									) AS PaternityEstablishment_PCT,
								
								(SELECT AVG(H.FederalPaternityEstablishment_PCT) FROM RWPRF_Y1 H WHERE H.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND H.County_IDNO = ISNULL(@An_County_IDNO, H.County_IDNO)) AS FederalPaternityEstablishment_PCT,	     						       
								(SELECT CAST(ROUND((y.Line25_AMNT * 100) / CAST(z.Line24_AMNT AS DECIMAL),0) AS INT) 			   
									FROM (
										SELECT SUM(r.Trans_AMNT) Line24_AMNT
										FROM R2426_Y1 r
										WHERE r.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
											AND r.EndFiscal_DATE = @Ad_EndFiscal_DATE
											AND r.TypeReport_CODE = @Lc_TypeReportI_CODE
											AND r.County_IDNO = ISNULL(@An_County_IDNO, r.County_IDNO)
											AND r.Line_NUMB = 24) z,
										(SELECT SUM(s.Trans_AMNT) Line25_AMNT
										FROM R2527_Y1 s
										WHERE s.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
											AND s.EndFiscal_DATE = @Ad_EndFiscal_DATE
											AND s.County_IDNO = ISNULL(@An_County_IDNO, s.County_IDNO)
											AND s.TypeReport_CODE = @Lc_TypeReportI_CODE
											AND s.Line_NUMB = 25) y) AS CollectionCurrency_PCT,		
								(SELECT AVG(C.FederalCollectionCurrency_PCT) FROM RWPRF_Y1 C WHERE C.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND C.County_IDNO = ISNULL(@An_County_IDNO, C.County_IDNO)) AS FederalCollectionCurrency_PCT,	   
								CAST(ROUND((SUM(CAST(CASE x.Line29_INDC WHEN @Lc_Yes_TEXT THEN 1 WHEN @Lc_No_TEXT THEN 0 END AS NUMERIC(1)))*100) /
										  SUM(CAST(CASE x.Line28_INDC  WHEN @Lc_Yes_TEXT THEN 1 WHEN @Lc_No_TEXT THEN 0 END AS NUMERIC(1))), 0) AS INT) AS CollectionArrear_PCT,	    
								(SELECT AVG(D.FederalCollectionArrear_PCT) FROM RWPRF_Y1 D WHERE D.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND D.County_IDNO = ISNULL(@An_County_IDNO, D.County_IDNO)) AS FederalCollectionArrear_PCT,	   
								(SELECT AVG(W.MedicalSupport_PCT) FROM RWPRF_Y1 W WHERE W.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND W.County_IDNO = ISNULL(@An_County_IDNO, W.County_IDNO)) AS MedicalSupport_PCT,
								(SELECT AVG(P.FederalMedicalSupport_PCT) FROM RWPRF_Y1 P WHERE P.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE AND P.County_IDNO = ISNULL(@An_County_IDNO, P.County_IDNO)) AS FederalMedicalSupport_PCT,
								@Lc_OrderbyA_CODE AS ORDERBYA
							FROM RC157_Y1 x
							WHERE x.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
							AND x.EndFiscal_DATE = @Ad_EndFiscal_DATE
							AND x.County_IDNO = ISNULL(@An_County_IDNO, x.County_IDNO)
							AND x.TypeReport_CODE = @Lc_TypeReportI_CODE
                          UNION
                          SELECT W.Worker_ID AS Worker_ID,
                                 SUM(W.TotalCases_NUMB) AS TotalCases_NUMB,
                                 AVG(W.SupportOrder_PCT) AS SupportOrder_PCT,
                                 AVG(W.FederalSupportOrder_PCT) AS FederalSupportOrder_PCT,
                                 AVG(W.PaternityEstablishment_PCT) AS PaternityEstablishment_PCT,
                                 AVG(W.FederalPaternityEstablishment_PCT) AS FederalPaternityEstablishment_PCT,
                                 AVG(W.CollectionCurrency_PCT) AS CollectionCurrency_PCT,
                                 AVG(W.FederalCollectionCurrency_PCT) AS FederalCollectionCurrency_PCT,
                                 AVG(W.CollectionArrear_PCT) AS CollectionArrear_PCT,
                                 AVG(W.FederalCollectionArrear_PCT) AS FederalCollectionArrear_PCT,
                                 AVG(W.MedicalSupport_PCT) AS MedicalSupport_PCT,
                                 AVG(W.FederalMedicalSupport_PCT) AS FederalMedicalSupport_PCT,
                                 @Lc_OrderbyB_CODE AS ORDERBYB
                            FROM RWPRF_Y1 W
                           WHERE W.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                             AND W.County_IDNO = ISNULL(@An_County_IDNO, W.County_IDNO)
                             AND W.Worker_ID = ISNULL(@Ac_Worker_ID, W.Worker_ID)
                           GROUP BY W.WORKER_ID) C) E
           WHERE E.ORD_ROWNUM <= @Ai_RowTo_NUMB
              OR @Ai_RowTo_NUMB = @Li_Zero_NUMB) D
   WHERE D.Row_num >= @Ai_RowFrom_NUMB
      OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB
   ORDER BY D.OrderbyA_CODE ASC;
 END; --- End of RWPRF_RETRIEVE_S2  


GO
