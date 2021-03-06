/****** Object:  StoredProcedure [dbo].[POBLE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POBLE_RETRIEVE_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @An_OrderSeq_NUMB            NUMERIC(2, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @Ai_RowFrom_NUMB             INT=1,
 @Ai_RowTo_NUMB               INT=10
 )
AS
 /*
  *     PROCEDURE NAME    : POBLE_RETRIEVE_S1
  *     DESCRIPTION       : Procedure is used to populate the preview popup while entering a new obligation 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_INDC       CHAR(1) = 'Y',
          @Lc_ObleLevel_CODE CHAR(1) = 'O',
          @Ld_High_DATE      DATE = '12/31/9999';

  SELECT Y.MemberMci_IDNO,
         Y.Last_NAME,
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,
         Y.Birth_DATE,
         Y.Emancipation_DATE,
         Y.Fips_CODE,
         Y.TypeDebt_CODE,
         Y.Arrears_AMNT,
         Y.CheckRecipient_ID,
         Y.Periodic_AMNT,
         Y.FreqPeriodic_CODE,
         Y.BeginObligation_DATE,
         Y.EndObligation_DATE,
         Y.RowCount_NUMB
    FROM (SELECT X.MemberMci_IDNO,
                 X.Last_NAME,
                 X.Suffix_NAME,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.Birth_DATE,
                 X.Emancipation_DATE,
                 X.Fips_CODE,
                 X.TypeDebt_CODE,
                 X.Arrears_AMNT,
                 X.CheckRecipient_ID,
                 X.Periodic_AMNT,
                 X.FreqPeriodic_CODE,
                 X.BeginObligation_DATE,
                 X.EndObligation_DATE,
                 X.ORD_ROWNUM,
                 X.RowCount_NUMB
            FROM (SELECT a.MemberMci_IDNO,
                         b.Last_NAME,
                         b.Suffix_NAME,
                         b.First_NAME,
                         b.Middle_NAME,
                         b.Birth_DATE,
                         b.Emancipation_DATE,
                         a.Fips_CODE,
                         a.TypeDebt_CODE,
                         dbo.BATCH_COMMON$SF_GET_OBLEARREARS(a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, a.TypeDebt_CODE, @Lc_ObleLevel_CODE, @Lc_Yes_INDC) AS Arrears_AMNT,
                         a.CheckRecipient_ID,
                         a.Periodic_AMNT,
                         a.FreqPeriodic_CODE,
                         a.BeginObligation_DATE,
                         a.EndObligation_DATE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.TypeDebt_CODE, a.MemberMci_IDNO, a.Fips_CODE, a.BeginObligation_DATE, a.Periodic_AMNT) AS ORD_ROWNUM
                    FROM POBLE_Y1 a
                         JOIN DEMO_Y1 b
                          ON a.MemberMci_IDNO = b.MemberMci_IDNO
                   WHERE a.Case_IDNO = @An_Case_IDNO
                     AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                     AND a.EventGlobalBeginSeq_NUMB >= @An_EventGlobalBeginSeq_NUMB
                     AND a.EndValidity_DATE = @Ld_High_DATE) X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END; --END OF POBLE_RETRIEVE_S1

GO
