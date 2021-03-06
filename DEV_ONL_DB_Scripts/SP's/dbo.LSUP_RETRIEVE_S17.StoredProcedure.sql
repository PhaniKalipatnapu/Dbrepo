/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S17](
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S17
  *     DESCRIPTION       : retrieves the Internal order sequence number created for a support order, Obligation sequence number, Member Id, type of debt, FIPS (Federal Information Processing Standard) code of the state, Unassigned During Assistance arrears amount owed, Never Assigned Arrears amount owed, Non IV-D amount owed, Medicaid amount owed, Non Federal Foster Care amount owed, Global Event sequence number for the given Case Id where effective start date for the obligation is equal to highest effective start date for the obligation, Global Event sequence number is equal to highest Global Event sequence number and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_SupportYearMonth_NUMB NUMERIC(6) = YEAR(@Ld_Current_DATE) * 100 + MONTH(@Ld_Current_DATE);

  SELECT O.OrderSeq_NUMB,
         O.ObligationSeq_NUMB,
         O.MemberMci_IDNO,
         O.TypeDebt_CODE,
         O.Fips_CODE,
         (L.OweTotUda_AMNT - L.AppTotUda_AMNT) AS DifferUda_AMNT,
         (L.OweTotNaa_AMNT - L.AppTotNaa_AMNT) AS DifferNaa_AMNT,
         (L.OweTotNonIvd_AMNT - L.AppTotNonIvd_AMNT) AS DifferNonIvd_AMNT,
         (L.OweTotMedi_AMNT - L.AppTotMedi_AMNT) AS DifferMedi_AMNT,
         (L.OweTotNffc_AMNT - L.AppTotNffc_AMNT) AS DifferNffc_AMNT,
         L.EventGlobalSeq_NUMB
    FROM OBLE_Y1 O
         JOIN LSUP_Y1 L
          ON L.Case_IDNO = O.Case_IDNO
             AND L.OrderSeq_NUMB = O.OrderSeq_NUMB
             AND L.ObligationSeq_NUMB = O.ObligationSeq_NUMB
   WHERE O.Case_IDNO = @An_Case_IDNO
     AND O.EndValidity_DATE = @Ld_High_DATE
     AND O.BeginObligation_DATE = (SELECT MAX(O1.BeginObligation_DATE)
                                     FROM OBLE_Y1 O1
                                    WHERE O1.Case_IDNO = O.Case_IDNO
                                      AND O1.OrderSeq_NUMB = O.OrderSeq_NUMB
                                      AND O1.ObligationSeq_NUMB = O.ObligationSeq_NUMB
                                      AND O1.BeginObligation_DATE <= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
                                      AND O1.EndValidity_DATE = @Ld_High_DATE)
     AND L.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
     AND L.EventGlobalSeq_NUMB = (SELECT MAX(L1.EventGlobalSeq_NUMB)
                                    FROM LSUP_Y1 L1
                                   WHERE L.Case_IDNO = L1.Case_IDNO
                                     AND L.OrderSeq_NUMB = L1.OrderSeq_NUMB
                                     AND L.ObligationSeq_NUMB = L1.ObligationSeq_NUMB
                                     AND L.SupportYearMonth_NUMB = L1.SupportYearMonth_NUMB);
 END; -- End of LSUP_RETRIEVE_S17


GO
