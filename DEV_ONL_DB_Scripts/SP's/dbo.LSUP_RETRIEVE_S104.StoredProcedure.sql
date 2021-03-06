/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S104]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S104](
 @An_Case_IDNO               NUMERIC(6),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_SupportYearMonth_NUMB   NUMERIC(6),
 @An_EventGlobalSeq_NUMB     NUMERIC(19)
 )
AS
 /*                                                                                                                                              
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S104                                                                                                    
  *     DESCRIPTION       : This Procedure is used to populates the data for the obligation details pop up for the case given.                                                                                                                    
  *     DEVELOPED BY      : IMP Team                                                                                                            
  *     DEVELOPED ON      : 11/11/2011                                                                                                       
  *     MODIFIED BY       :                                                                                                                      
  *     MODIFIED ON       :                                                                                                                      
  *     VERSION NO        : 1                                                                                                                    
  */
 BEGIN
  DECLARE @Li_DraConversionProcess9997_NUMB		 INT     =  9997,
          @Li_Zero_NUMB                          SMALLINT=  0,
          @Lc_No_INDC							 CHAR(1) = 'N',
          @Lc_TypeWelfareFosterCare_CODE		 CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE			 CHAR(1) = 'M',
          @Lc_TypeWelfareNonIvd_CODE			 CHAR(1) = 'H',
          @Lc_TypeWelfareNonIve_CODE			 CHAR(1) = 'F',
          @Lc_TypeWelfareTanf_CODE				 CHAR(1) = 'A',
          @Lc_TypeDebit_CODE                     CHAR(3) = 'DS',
          @Lc_Na_CODE                            CHAR(8) = 'NA',
          @Lc_Ta_CODE                            CHAR(8) = 'TA',
          @Lc_Pa_CODE                            CHAR(8) = 'PA',
          @Lc_Ca_CODE                            CHAR(8) = 'CA',
          @Lc_Uda_CODE                           CHAR(8) = 'UDA',
          @Lc_Upa_CODE                           CHAR(8) = 'UPA',
          @Lc_Ivef_CODE                          CHAR(8) = 'IVEF',
          @Lc_Medi_CODE                          CHAR(8) = 'MEDI',
          @Lc_Nffc_CODE                          CHAR(8) = 'NFFC',
          @Lc_NonIvd_CODE                        CHAR(8) = 'NIVD',
          @Lc_CurrentSupport_TEXT                CHAR(20)= 'Current Support',
          @Ld_High_DATE							 DATE    = '12/31/9999';
          
  WITH OBAA_CTE
       AS (
          SELECT @Lc_CurrentSupport_TEXT AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         LS.TransactionCurSup_AMNT AS Distribute_AMNT,
                         ISNULL(n.DescriptionNote_TEXT, '') AS DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1 LS
                         LEFT OUTER JOIN UNOT_Y1 n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB
                         JOIN OBLE_Y1 o
                          ON LS.Case_IDNO = o.Case_IDNO
                             AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                             AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                         JOIN SORD_Y1 s
                          ON LS.Case_IDNO = s.Case_IDNO
                             AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND LS.TransactionCurSup_AMNT != @Li_Zero_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1 b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.TypeWelfare_CODE,
                    X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Na_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         ISNULL(LS.TransactionNaa_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE
                                                              WHEN @Lc_TypeDebit_CODE
                                                               THEN @Li_Zero_NUMB
                                                              ELSE
                                                               CASE LS.TypeWelfare_CODE
                                                                WHEN @Lc_No_INDC
                                                                 THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                                WHEN @Lc_TypeWelfareMedicaid_CODE
                                                                 THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                                ELSE @Li_Zero_NUMB
                                                               END
                                                             END AS Distribute_AMNT,
                         n.DescriptionNote_TEXT AS DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB AS SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND ISNULL(LS.TransactionNaa_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE
                                                              WHEN @Lc_TypeDebit_CODE
                                                               THEN @Li_Zero_NUMB
                                                              ELSE
                                                               CASE LS.TypeWelfare_CODE
                                                                WHEN @Lc_No_INDC
                                                                 THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                                WHEN @Lc_TypeWelfareMedicaid_CODE
                                                                 THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                                ELSE @Li_Zero_NUMB
                                                               END
                                                             END != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1  b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Ta_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT),
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         LS.TransactionTaa_AMNT AS Distribute_AMNT,
                         n.DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND LS.TransactionTaa_AMNT != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1 b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Pa_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         ISNULL(LS.TransactionPaa_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                              WHEN @Lc_TypeWelfareTanf_CODE
                                                               THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                              ELSE @Li_Zero_NUMB
                                                             END AS Distribute_AMNT,
                         n.DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND ISNULL(LS.TransactionPaa_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                              WHEN @Lc_TypeWelfareTanf_CODE
                                                               THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                              ELSE @Li_Zero_NUMB
                                                             END != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1  b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Ca_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         LS.TransactionCaa_AMNT AS Distribute_AMNT,
                         n.DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND LS.TransactionCaa_AMNT != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE) 
                                                     FROM OBLE_Y1  b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Upa_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT),
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         LS.TransactionUpa_AMNT AS Distribute_AMNT,
                         n.DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND LS.TransactionUpa_AMNT != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1  b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Uda_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         LS.TransactionUda_AMNT AS Distribute_AMNT,
                         n.DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND LS.TransactionUda_AMNT != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1 b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Ivef_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         ISNULL(LS.TransactionIvef_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                               WHEN @Lc_TypeWelfareNonIve_CODE
                                                                THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                               ELSE @Li_Zero_NUMB
                                                              END AS Distribute_AMNT,
                         n.DescriptionNote_TEXT AS DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB AS SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND ISNULL(LS.TransactionIvef_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                               WHEN @Lc_TypeWelfareNonIve_CODE
                                                                THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                               ELSE @Li_Zero_NUMB
                                                              END != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                     FROM OBLE_Y1 b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Medi_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         ISNULL(LS.TransactionMedi_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE
                                                               WHEN @Lc_TypeDebit_CODE
                                                                THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                               ELSE @Li_Zero_NUMB
                                                              END AS Distribute_AMNT,
                         n.DescriptionNote_TEXT ,
                         LS.SupportYearMonth_NUMB 
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1  o,
                         SORD_Y1  s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND ISNULL(LS.TransactionMedi_AMNT, @Li_Zero_NUMB) - CASE o.TypeDebt_CODE
                                                               WHEN @Lc_TypeDebit_CODE
                                                                THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                               ELSE @Li_Zero_NUMB
                                                              END != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE) 
                                                     FROM OBLE_Y1  b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
          UNION ALL
          SELECT @Lc_Nffc_CODE AS BucketAdjust_CODE,
                 X.Order_IDNO,
                 X.MemberMci_IDNO,
                 X.TypeDebt_CODE,
                 X.Fips_CODE,
                 X.TypeWelfare_CODE,
                 SUM(X.Distribute_AMNT),
                 X.DescriptionNote_TEXT,
                 X.SupportYearMonth_NUMB
            FROM (SELECT s.Order_IDNO,
                         o.MemberMci_IDNO,
                         o.TypeDebt_CODE,
                         o.Fips_CODE,
                         LS.TypeWelfare_CODE,
                         ISNULL(LS.TransactionNffc_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                               WHEN @Lc_TypeWelfareFosterCare_CODE
                                                                THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                               ELSE @Li_Zero_NUMB
                                                              END AS Distribute_AMNT,
                         n.DescriptionNote_TEXT,
                         LS.SupportYearMonth_NUMB
                    FROM LSUP_Y1  LS
                         LEFT OUTER JOIN UNOT_Y1  n
                          ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                         OBLE_Y1 o,
                         SORD_Y1 s
                   WHERE LS.Case_IDNO = @An_Case_IDNO
                     AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                     AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                           AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                           OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                     AND ISNULL(LS.TransactionNffc_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                               WHEN @Lc_TypeWelfareFosterCare_CODE
                                                                THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                               ELSE @Li_Zero_NUMB
                                                              END != @Li_Zero_NUMB
                     AND LS.Case_IDNO = o.Case_IDNO
                     AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                     AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                     AND LS.Case_IDNO = s.Case_IDNO
                     AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                     AND s.EndValidity_DATE = @Ld_High_DATE
                     AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE) 
                                                     FROM OBLE_Y1  b
                                                    WHERE b.Case_IDNO = o.Case_IDNO
                                                      AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND o.EndValidity_DATE = @Ld_High_DATE)  X
           GROUP BY X.Order_IDNO,
                    X.MemberMci_IDNO,
                    X.TypeDebt_CODE,
                    X.Fips_CODE,
                    X.TypeWelfare_CODE,
                    X.DescriptionNote_TEXT,
                    X.SupportYearMonth_NUMB
           UNION ALL
           SELECT @Lc_NonIvd_CODE AS BucketAdjust_CODE,
                  X.Order_IDNO,
                  X.MemberMci_IDNO,
                  X.TypeDebt_CODE,
                  X.Fips_CODE,
                  X.TypeWelfare_CODE,
                  SUM(X.Distribute_AMNT) AS Distribute_AMNT,
                  X.DescriptionNote_TEXT,
                  X.SupportYearMonth_NUMB
             FROM (SELECT s.Order_IDNO,
                          o.MemberMci_IDNO,
                          o.TypeDebt_CODE,
                          o.Fips_CODE,
                          LS.TypeWelfare_CODE,
                          ISNULL(LS.TransactionNonIvd_AMNT, @Li_Zero_NUMB) - CASE LS.TypeWelfare_CODE
                                                                  WHEN @Lc_TypeWelfareNonIvd_CODE
                                                                   THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                                  ELSE @Li_Zero_NUMB
                                                                 END AS Distribute_AMNT,
                          n.DescriptionNote_TEXT ,
                          LS.SupportYearMonth_NUMB 
                     FROM LSUP_Y1  LS
                          LEFT OUTER JOIN UNOT_Y1  n
                           ON n.EventGlobalSeq_NUMB = LS.EventGlobalSeq_NUMB,
                          OBLE_Y1  o,
                          SORD_Y1  s
                    WHERE LS.Case_IDNO = @An_Case_IDNO
                      AND LS.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
                      AND ((LS.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                            AND @An_EventFunctionalSeq_NUMB <> @Li_DraConversionProcess9997_NUMB)
                            OR @An_EventFunctionalSeq_NUMB = @Li_DraConversionProcess9997_NUMB)
                      AND (ISNULL(LS.TransactionNonIvd_AMNT, @Li_Zero_NUMB) - (CASE LS.TypeWelfare_CODE
                                                                    WHEN @Lc_TypeWelfareNonIvd_CODE
                                                                     THEN ISNULL(LS.TransactionCurSup_AMNT, @Li_Zero_NUMB)
                                                                    ELSE @Li_Zero_NUMB
                                                                   END)) != @Li_Zero_NUMB
                      AND LS.Case_IDNO = o.Case_IDNO
                      AND LS.OrderSeq_NUMB = o.OrderSeq_NUMB
                      AND LS.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                      AND LS.Case_IDNO = s.Case_IDNO
                      AND LS.OrderSeq_NUMB = s.OrderSeq_NUMB
                      AND s.EndValidity_DATE = @Ld_High_DATE
                      AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                                      FROM OBLE_Y1  b
                                                     WHERE b.Case_IDNO = o.Case_IDNO
                                                       AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                       AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                       AND b.EndValidity_DATE = @Ld_High_DATE)
                      AND o.EndValidity_DATE = @Ld_High_DATE)  X
            GROUP BY X.Order_IDNO,
                     X.MemberMci_IDNO,
                     X.TypeDebt_CODE,
                     X.Fips_CODE,
                     X.TypeWelfare_CODE,
                     X.DescriptionNote_TEXT,
                     X.SupportYearMonth_NUMB)
  SELECT Y.BucketAdjust_CODE,
         Y.Order_IDNO,
         Y.MemberMci_IDNO,
         Y.TypeDebt_CODE,
         Y.Fips_CODE,
         Y.TypeWelfare_CODE,
         Y.Distribute_AMNT,
         Y.DescriptionNote_TEXT,
         Y.SupportYearMonth_NUMB,
         d.Last_NAME,
         d.Suffix_NAME,
         d.First_NAME,
         d.Middle_NAME
    FROM OBAA_CTE Y
         JOIN DEMO_Y1 D
          ON Y.MemberMci_IDNO = D.MemberMci_IDNO
   ORDER BY SupportYearMonth_NUMB,
            Order_IDNO,
            MemberMci_IDNO,
            TypeDebt_CODE,
            Fips_CODE,
            TypeWelfare_CODE,
            DescriptionNote_TEXT;
            
 END; --End Of Procedure LSUP_RETRIEVE_S104 


GO
