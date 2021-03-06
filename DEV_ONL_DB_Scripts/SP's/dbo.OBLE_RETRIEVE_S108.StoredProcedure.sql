/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S108]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S108] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_OrderSeq_NUMB      NUMERIC(2, 0),
 @An_ObligationSeq_NUMB NUMERIC(2, 0),
 @An_MemberMci_IDNO     NUMERIC(10, 0) OUTPUT,
 @Ac_TypeDebt_CODE      CHAR(2) OUTPUT,
 @Ac_Fips_CODE          CHAR(7) OUTPUT,
 @Ac_FreqPeriodic_CODE  CHAR(1) OUTPUT,
 @An_Periodic_AMNT      NUMERIC(11, 2) OUTPUT,
 @Ac_Last_NAME          CHAR(20) OUTPUT,
 @Ac_Suffix_NAME        CHAR(4) OUTPUT,
 @Ac_First_NAME         CHAR(16) OUTPUT,
 @Ac_Middle_NAME        CHAR(20) OUTPUT,
 @An_MemberSsn_NUMB     NUMERIC(9, 0) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : OBLE_RETRIEVE_S108
  *     DESCRIPTION       : Retrieves frequency periodic code & amount, member name, member ssn for the given case id.
  *     DEVELOPED BY      :IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_FreqPeriodic_CODE = NULL,
         @An_Periodic_AMNT = NULL,
         @Ac_TypeDebt_CODE = NULL,
         @An_MemberMci_IDNO = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ac_Fips_CODE = NULL;

  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_Ssn_NUMB     NUMERIC(9) = '000000000';

  SELECT @An_MemberMci_IDNO = a.MemberMci_IDNO,
         @Ac_TypeDebt_CODE = a.TypeDebt_CODE,
         @Ac_Fips_CODE = a.Fips_CODE,
         @Ac_FreqPeriodic_CODE = a.FreqPeriodic_CODE,
         @An_Periodic_AMNT = a.Periodic_AMNT,
         @Ac_Last_NAME = d.Last_NAME,
         @Ac_Suffix_NAME = d.Suffix_NAME,
         @Ac_First_NAME = d.First_NAME,
         @Ac_Middle_NAME = d.Middle_NAME,
         @An_MemberSsn_NUMB = ISNULL((SELECT dd.MemberSsn_NUMB
                                        FROM DEMO_Y1 dd
                                       WHERE dd.MemberMci_IDNO = a.MemberMci_IDNO), @Ln_Ssn_NUMB)
    FROM OBLE_Y1 a
         LEFT OUTER JOIN DEMO_Y1 d
          ON d.MemberMci_IDNO = a.MemberMci_IDNO
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
     AND ((a.BeginObligation_DATE <= @Ld_Current_DATE
           AND a.EndObligation_DATE = (SELECT MAX(b.EndObligation_DATE)
                                         FROM OBLE_Y1 b
                                        WHERE b.Case_IDNO = a.Case_IDNO
                                          AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                          AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                          AND b.BeginObligation_DATE <= @Ld_Current_DATE
                                          AND b.EndValidity_DATE = @Ld_High_DATE))
           OR (a.BeginObligation_DATE > @Ld_Current_DATE
               AND a.EndObligation_DATE = (SELECT MIN(b.EndObligation_DATE)
                                             FROM OBLE_Y1 b
                                            WHERE b.Case_IDNO = a.Case_IDNO
                                              AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND b.BeginObligation_DATE > @Ld_Current_DATE
                                              AND b.EndValidity_DATE = @Ld_High_DATE)
               AND NOT EXISTS (SELECT 1
                                 FROM OBLE_Y1 c
                                WHERE c.Case_IDNO = a.Case_IDNO
                                  AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                  AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                  AND c.BeginObligation_DATE <= @Ld_Current_DATE
                                  AND c.EndValidity_DATE = @Ld_High_DATE)))
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End of OBLE_RETRIEVE_S108

GO
