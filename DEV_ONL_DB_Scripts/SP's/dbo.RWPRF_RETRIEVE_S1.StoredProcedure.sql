/****** Object:  StoredProcedure [dbo].[RWPRF_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RWPRF_RETRIEVE_S1](
 @Ad_BeginFiscal_DATE DATE,
 @Ad_EndFiscal_DATE   DATE,
 @An_County_IDNO      NUMERIC(3, 0),
 @Ac_Worker_ID        CHAR(30),
 @Ai_RowFrom_NUMB     INT = 1,
 @Ai_RowTo_NUMB       INT = 10
 )
AS
 /*    
 *     PROCEDURE NAME    : RWPRF_RETRIEVE_S1  
 *     DESCRIPTION       : Retrieves the worker performance measures details.  
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 27-JAN-2012    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT = 0;

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
         D.RowCount_NUMB
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
                 C.RowCount_NUMB,
                 C.ORD_ROWNUM AS Row_num
            FROM (SELECT W.Worker_ID,
                         SUM(W.TotalCases_NUMB) AS TotalCases_NUMB,
                         AVG(W.SupportOrder_PCT) AS SupportOrder_PCT,
                         AVG(W.FederalSupportOrder_PCT) FederalSupportOrder_PCT,
                         AVG(W.PaternityEstablishment_PCT) AS PaternityEstablishment_PCT,
                         AVG(W.FederalPaternityEstablishment_PCT) AS FederalPaternityEstablishment_PCT,
                         AVG(W.CollectionCurrency_PCT) AS CollectionCurrency_PCT,
                         AVG(W.FederalCollectionCurrency_PCT) AS FederalCollectionCurrency_PCT,
                         AVG(W.CollectionArrear_PCT) AS CollectionArrear_PCT,
                         AVG(W.FederalCollectionArrear_PCT) AS FederalCollectionArrear_PCT,
                         AVG(W.MedicalSupport_PCT) AS MedicalSupport_PCT,
                         AVG(W.FederalMedicalSupport_PCT) AS FederalMedicalSupport_PCT,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY W.Worker_ID) AS ORD_ROWNUM
                    FROM RWPRF_Y1 W
                   WHERE W.Begin_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                     AND W.County_IDNO = ISNULL(@An_County_IDNO, W.County_IDNO)
                     AND W.Worker_ID = ISNULL(@Ac_Worker_ID, W.Worker_ID)
                   GROUP BY W.Worker_ID) C
           WHERE C.ORD_ROWNUM <= @Ai_RowTo_NUMB
              OR @Ai_RowTo_NUMB = @Li_Zero_NUMB) D
   WHERE D.Row_num >= @Ai_RowFrom_NUMB
      OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB;
 END; --- End of RWPRF_RETRIEVE_S1  


GO
