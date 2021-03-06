/****** Object:  StoredProcedure [dbo].[FCSUM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FCSUM_RETRIEVE_S1](
 @An_Case_IDNO    NUMERIC(6, 0),
 @Ad_From_DATE    DATE,
 @Ad_To_DATE      DATE,
 @Ai_RowFrom_NUMB SMALLINT,
 @Ai_RowTo_NUMB   SMALLINT
 )
AS
 /*
  *     PROCEDURE NAME    : FCSUM_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen case event summary details for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-08-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT A.Summary_DATE,
         A.SummaryType_CODE,
         A.SupportObligation_AMNT,
         A.CurrentSupport1_AMNT,
         A.Afdc_AMNT,
         A.ApplicationFees_AMNT,
         A.CurrentSupport2_AMNT,
         A.SpousalSupport1_AMNT,
         A.ForsterCareArr_AMNT,
         A.OutOfStateArr_AMNT,
         A.MedicalSupport1_AMNT,
         A.CurrentSupport3_AMNT,
         A.SpousalSupport_AMNT,
         A.MedicalSupport_AMNT,
         A.VoluntarySupport_AMNT,
         A.MedicalArrears_AMNT,
         A.CurrentSupport4_AMNT,
         A.Sub1Arrears_AMNT,
         A.MedicalSupport2_AMNT,
         A.CurrentSupport5_AMNT,
         A.CurrentSupport6_AMNT,
         A.SpousalSupport2_AMNT,
         A.Undistributed_AMNT,
         A.RowCount_NUMB
    FROM (SELECT f.Summary_DATE,
                 f.SummaryType_CODE,
                 f.SupportObligation_AMNT,
                 f.CurrentSupport1_AMNT,
                 f.Afdc_AMNT,
                 f.ApplicationFees_AMNT,
                 f.CurrentSupport2_AMNT,
                 f.SpousalSupport1_AMNT,
                 f.ForsterCareArr_AMNT,
                 f.OutOfStateArr_AMNT,
                 f.MedicalSupport1_AMNT,
                 f.CurrentSupport3_AMNT,
                 f.SpousalSupport_AMNT,
                 f.MedicalSupport_AMNT,
                 f.VoluntarySupport_AMNT,
                 f.MedicalArrears_AMNT,
                 f.CurrentSupport4_AMNT,
                 f.Sub1Arrears_AMNT,
                 f.MedicalSupport2_AMNT,
                 f.CurrentSupport5_AMNT,
                 f.CurrentSupport6_AMNT,
                 f.SpousalSupport2_AMNT,
                 f.Undistributed_AMNT,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY f.Summary_DATE ) AS ROWNUM
            FROM FCSUM_Y1 f
           WHERE f.Case_IDNO = @An_Case_IDNO
             AND f.Summary_DATE >= @Ad_From_DATE
             AND f.Summary_DATE <= @Ad_To_DATE) AS A
   WHERE A.ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END;


GO
