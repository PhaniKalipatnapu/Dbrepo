/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S41] (
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE CHAR(1),
 @Ac_TypeDebt_CODE         CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S41
  *     DESCRIPTION       : Retrieve the Obligation Info that to be display in the Obligation grid for Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 15-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseCp_CODE        CHAR(1) = 'C',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Current_DATE                   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT d.Last_NAME,
         d.Suffix_NAME,
         d.First_NAME,
         d.Middle_NAME,
         a.MemberMci_IDNO,
         a.Fips_CODE,
         d.Birth_DATE,
         a.BeginObligation_DATE,
         a.EndObligation_DATE,
         a.FreqPeriodic_CODE,
         a.Periodic_AMNT,
         b.SupportYearMonth_NUMB,
         b.MtdCurSupOwed_AMNT,
         b.AppTotCurSup_AMNT,
         ((b.OweTotNaa_AMNT + b.OweTotTaa_AMNT + b.OweTotPaa_AMNT + b.OweTotCaa_AMNT + b.OweTotUda_AMNT + b.OweTotUpa_AMNT + b.OweTotIvef_AMNT + b.OweTotNffc_AMNT + b.OweTotNonIvd_AMNT + b.OweTotMedi_AMNT) - (b.AppTotNaa_AMNT + b.AppTotTaa_AMNT + b.AppTotPaa_AMNT + b.AppTotCaa_AMNT + b.AppTotUda_AMNT + b.AppTotUpa_AMNT + b.AppTotIvef_AMNT + b.AppTotNffc_AMNT + b.AppTotNonIvd_AMNT + b.AppTotMedi_AMNT + b.AppTotFuture_AMNT)) AS Arrears_AMNT,
         DBO.BATCH_COMMON$SF_GET_ALLOCATED_IND(a.Case_IDNO, a.OrderSeq_NUMB, a.TypeDebt_CODE) AS Allocated_INDC,
         a.ObligationSeq_NUMB,
         a.TypeDebt_CODE,
         DBO.BATCH_COMMON$SF_GET_NOTES(a.EventGlobalBeginSeq_NUMB) AS DescriptionNote_TEXT
    FROM OBLE_Y1 a
         JOIN CMEM_Y1 c
          ON a.Case_IDNO = c.Case_IDNO
         JOIN DEMO_Y1 d
          ON d.MemberMci_IDNO = a.MemberMci_IDNO
         JOIN LSUP_Y1 b
          ON b.Case_IDNO = a.Case_IDNO
             AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
             AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
   WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
     AND ((@Ac_CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE
           AND c.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE)
           OR (@Ac_CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
               AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)))
     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
     AND a.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE, a.TypeDebt_CODE)
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND ((a.BeginObligation_DATE <= @Ld_Current_DATE
           AND a.EndObligation_DATE = (SELECT MAX(d.EndObligation_DATE)
                                         FROM OBLE_Y1 d
                                        WHERE d.Case_IDNO = a.Case_IDNO
                                          AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                          AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                          AND d.BeginObligation_DATE <= @Ld_Current_DATE
                                          AND d.EndValidity_DATE = @Ld_High_DATE))
           OR (a.BeginObligation_DATE > @Ld_Current_DATE
               AND a.EndObligation_DATE = (SELECT MIN(d.EndObligation_DATE)
                                             FROM OBLE_Y1 d
                                            WHERE d.Case_IDNO = a.Case_IDNO
                                              AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND d.BeginObligation_DATE > @Ld_Current_DATE
                                              AND d.EndValidity_DATE = @Ld_High_DATE)
               AND NOT EXISTS (SELECT 1
                                 FROM OBLE_Y1 d
                                WHERE d.Case_IDNO = a.Case_IDNO
                                  AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                  AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                  AND d.BeginObligation_DATE <= @Ld_Current_DATE
                                  AND d.EndValidity_DATE = @Ld_High_DATE)))
     AND b.SupportYearMonth_NUMB = (SELECT MAX(c.SupportYearMonth_NUMB)
                                      FROM LSUP_Y1 c
                                     WHERE c.Case_IDNO = b.Case_IDNO
                                       AND c.OrderSeq_NUMB = b.OrderSeq_NUMB
                                       AND c.ObligationSeq_NUMB = b.ObligationSeq_NUMB)
     AND b.EventGlobalSeq_NUMB = (SELECT MAX(d.EventGlobalSeq_NUMB)
                                    FROM LSUP_Y1 d
                                   WHERE d.Case_IDNO = b.Case_IDNO
                                     AND d.OrderSeq_NUMB = b.OrderSeq_NUMB
                                     AND d.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                     AND d.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB)
   ORDER BY a.TypeDebt_CODE,
            a.BeginObligation_DATE ASC;
 END; -- End of LSUP_RETRIEVE_S41

GO
