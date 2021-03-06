/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S59]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S59] (
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_OrderSeq_NUMB NUMERIC(2, 0),
 @Ac_TypeDebt_CODE CHAR(2),
 @Ac_Fips_CODE     CHAR(7)
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S59
  *     DESCRIPTION       : Procedure is used to populate obligation info for allocated indication Yes in modify obligation screen.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 15-DEC2-011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB  SMALLINT = 0,
          @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT X.BeginObligation_DATE,
         X.EndObligation_DATE,
         X.Periodic_AMNT,
         X.FreqPeriodic_CODE,
         X.ReasonChange_CODE
    FROM(SELECT TOP (100) PERCENT a.BeginObligation_DATE,
                                  a.EndObligation_DATE,
                                  ISNULL(SUM(a.Periodic_AMNT), @Li_Zero_NUMB) AS Periodic_AMNT,
                                  CASE COUNT(DISTINCT a.FreqPeriodic_CODE)
                                   WHEN 1
                                    THEN MAX(a.FreqPeriodic_CODE)
                                   ELSE @Lc_Space_TEXT
                                  END AS FreqPeriodic_CODE,
                                  MAX(a.ReasonChange_CODE) AS ReasonChange_CODE
           FROM OBLE_Y1 a
          WHERE a.Case_IDNO = @An_Case_IDNO
            AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
            AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE
            AND a.Fips_CODE = @Ac_Fips_CODE
            AND a.EndValidity_DATE = @Ld_High_DATE
          GROUP BY a.BeginObligation_DATE,
                   a.EndObligation_DATE
          ORDER BY a.BeginObligation_DATE) X;
 END; --END OF OBLE_RETRIEVE_S59 

GO
