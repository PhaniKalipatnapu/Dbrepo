/****** Object:  StoredProcedure [dbo].[RC157_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RC157_RETRIEVE_S2](
 @An_SupportYearMonth_NUMB NUMERIC(6, 0),
 @Ad_BeginFiscal_DATE      DATE,
 @Ad_EndFiscal_DATE        DATE,
 @Ac_TypeReport_CODE       CHAR(1),
 @An_County_IDNO           NUMERIC(3, 0),
 @Ac_Worker_ID             CHAR(30),
 @Ac_TypeAsst_CODE         CHAR(1),
 @Ai_RowFrom_NUMB          INT = 1,
 @Ai_RowTo_NUMB            INT = 10
 )
AS
 /*  
 *     PROCEDURE NAME    : RC157_RETRIEVE_S2
 *     DESCRIPTION       : Retrieves the details of the cases displayed on the report for line 1a
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 27-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
          @Li_Zero_NUMB SMALLINT = 0;

  SELECT D.Worker_ID,
         D.Case_IDNO,
         D.TypeAsst_CODE,
         D.StatusCase_CODE,
         D.CaseCategory_CODE,
         D.RespondInit_CODE,
         D.County_IDNO,
         D.RowCount_NUMB
    FROM (SELECT C.Worker_ID,
                 C.Case_IDNO,
                 C.TypeAsst_CODE,
                 C.StatusCase_CODE,
                 C.CaseCategory_CODE,
                 C.RespondInit_CODE,
                 C.County_IDNO,
                 C.RowCount_NUMB,
                 C.ORD_ROWNUM AS Row_num
            FROM (SELECT a.Worker_ID,
                         a.Case_IDNO,
                         b.TypeAsst_CODE,
                         b.StatusCase_CODE,
                         b.CaseCategory_CODE,
                         b.RespondInit_CODE,
                         a.County_IDNO,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Case_IDNO) AS ORD_ROWNUM
                    FROM RC157_Y1 a
                         JOIN RASST_Y1 b
                          ON (a.Case_IDNO = b.Case_IDNO)
                   WHERE a.BeginFiscaL_DATE = @Ad_BeginFiscal_DATE
                     AND a.EndFiscaL_DATE = @Ad_EndFiscal_DATE
                     AND a.TypeReport_CODE = @Ac_TypeReport_CODE
                     AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                     AND a.Line1a_INDC = @Lc_Yes_INDC
                     AND b.TypeAsst_CODE = ISNULL(@Ac_TypeAsst_CODE, b.TypeAsst_CODE)
                     AND a.County_IDNO = ISNULL(@An_County_IDNO, a.County_IDNO)
                     AND a.Worker_ID = ISNULL(@Ac_Worker_ID, a.Worker_ID)) C
           WHERE C.ORD_ROWNUM <= @Ai_RowTo_NUMB
              OR @Ai_RowTo_NUMB = @Li_Zero_NUMB) D
   WHERE D.Row_num >= @Ai_RowFrom_NUMB
      OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB;
 END; --- End of RC157_RETRIEVE_S2

GO
