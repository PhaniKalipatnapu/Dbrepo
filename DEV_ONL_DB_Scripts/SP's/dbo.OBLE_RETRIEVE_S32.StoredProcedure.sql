/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S32]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S32] (
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_OrderSeq_NUMB NUMERIC(2, 0),
 @Ac_TypeDebt_CODE CHAR(2),
 @Ac_File_ID       CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S32
  *     DESCRIPTION       : Retrieve the obligation info that to be display in Obigation grid for FILE_ID.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 15-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

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
         b.MtdCurSupOwed_AMNT,
         b.SupportYearMonth_NUMB,
         b.AppTotCurSup_AMNT,
         ((b.OweTotNaa_AMNT + b.OweTotTaa_AMNT + b.OweTotPaa_AMNT + b.OweTotCaa_AMNT + b.OweTotUda_AMNT + b.OweTotUpa_AMNT + b.OweTotIvef_AMNT + b.OweTotNffc_AMNT + b.OweTotNonIvd_AMNT + b.OweTotMedi_AMNT) - (b.AppTotNaa_AMNT + b.AppTotTaa_AMNT + b.AppTotPaa_AMNT + b.AppTotCaa_AMNT + b.AppTotUda_AMNT + b.AppTotUpa_AMNT + b.AppTotIvef_AMNT + b.AppTotNffc_AMNT + b.AppTotNonIvd_AMNT + b.AppTotMedi_AMNT + b.AppTotFuture_AMNT)) AS Arrears_AMNT,
         DBO.BATCH_COMMON$SF_GET_ALLOCATED_IND(a.Case_IDNO, a.OrderSeq_NUMB, a.TypeDebt_CODE) AS AllocatedInd_INDC,
         a.ObligationSeq_NUMB,
         a.TypeDebt_CODE,
         dbo.BATCH_COMMON$SF_GET_NOTES(a.EventGlobalBeginSeq_NUMB) AS Notes_TEXT
    FROM SORD_Y1 s
         JOIN OBLE_Y1 a
          ON a.Case_IDNO = s.Case_IDNO
             AND a.OrderSeq_NUMB = s.OrderSeq_NUMB
         JOIN LSUP_Y1 b
          ON b.Case_IDNO = a.Case_IDNO
             AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
             AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
         JOIN DEMO_Y1 d
          ON d.MemberMci_IDNO = a.MemberMci_IDNO
   WHERE S.File_ID = ISNULL(@Ac_File_ID, s.File_ID)
     AND s.OrderSeq_NUMB = ISNULL(@An_OrderSeq_NUMB, s.OrderSeq_NUMB)
     AND s.Case_IDNO = ISNULL(@An_Case_IDNO, s.Case_IDNO)
     AND a.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE, a.TypeDebt_CODE)
     AND S.EndValidity_DATE = @Ld_High_DATE
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
 END; --END OF OBLE_RETRIEVE_S32

GO
