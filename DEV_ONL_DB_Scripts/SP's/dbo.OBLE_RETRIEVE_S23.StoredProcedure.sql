/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S23] (
 @An_Case_IDNO         NUMERIC(6, 0),
 @An_OrderSeq_NUMB     NUMERIC(2, 0),
 @Ac_TypeDebt_CODE     CHAR(2),
 @Ac_FreqPeriodic_CODE CHAR(1) OUTPUT,
 @An_Support_AMNT      NUMERIC(11, 2) OUTPUT,
 @Ac_Exists_INDC       CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S23
  *     DESCRIPTION       : Retrieve Spousal Support Frequency and Spousal Support Amount for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_FreqPeriodic_CODE = NULL,
         @An_Support_AMNT = NULL,
         @Ac_Exists_INDC = NULL;

  DECLARE @Li_Zero_NUMB        INT			= 0,
          @Lc_Annual_TEXT      CHAR(1)		= 'A',
          @Lc_Daily_TEXT       CHAR(1)		= 'D',
          @Lc_Monthly_TEXT     CHAR(1)		= 'M',
          @Lc_OnRequest_TEXT   CHAR(1)		= 'O',
          @Lc_Quarterly_TEXT   CHAR(1)		= 'Q',
          @Lc_Semimonthly_TEXT CHAR(1)		= 'S',
          @Lc_Space_TEXT       CHAR(1)		= ' ',
          @Lc_Weekly_TEXT      CHAR(1)		= 'W',
          @Lc_Yes_INDC         CHAR(1)		= 'Y',
          @Lc_No_INDC          CHAR(1)		= 'N',
          @Lc_Biweekly_TEXT    CHAR(1)		= 'B',
          @Ld_High_DATE        DATE			= '12/31/9999',
          @Ld_System_DATE      DATE			= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ac_FreqPeriodic_CODE = Y.FreqPeriodic_CODE,
         @An_Support_AMNT = CASE Y.FreqPeriodic_CODE
                             WHEN @Lc_Daily_TEXT
                              THEN (Y.Monthly_AMNT * 12) / 365
                             WHEN @Lc_Weekly_TEXT
                              THEN (Y.Monthly_AMNT * 12) / 52
                             WHEN @Lc_Monthly_TEXT
                              THEN Y.Monthly_AMNT
                             WHEN @Lc_Biweekly_TEXT
                              THEN (Y.Monthly_AMNT * 12) / 26
                             WHEN @Lc_Semimonthly_TEXT
                              THEN (Y.Monthly_AMNT * 12) / 24
                             WHEN @Lc_Quarterly_TEXT
                              THEN (Y.Monthly_AMNT * 3)
                             WHEN @Lc_Annual_TEXT
                              THEN (Y.Monthly_AMNT * 12)
                             ELSE 0
                            END,
         @Ac_Exists_INDC = CASE
                            WHEN Y.RowCount_NUMB = 1
                             THEN @Lc_Yes_INDC
                            ELSE @Lc_No_INDC
                           END
    FROM (SELECT ISNULL(MAX(CASE
                             WHEN X.Periodic_AMNT > @Li_Zero_NUMB AND X.EndObligation_DATE >= @Ld_System_DATE
                              THEN X.FreqPeriodic_CODE
                             ELSE @Lc_Space_TEXT
                            END), @Lc_Space_TEXT) AS FreqPeriodic_CODE,
                 ISNULL (SUM (CASE
                               WHEN X.Periodic_AMNT > @Li_Zero_NUMB AND X.EndObligation_DATE >= @Ld_System_DATE
                                THEN
                                CASE X.FreqPeriodic_CODE
                                 WHEN @Lc_Daily_TEXT
                                  THEN (X.Periodic_AMNT * 365) / 12
                                 WHEN @Lc_Weekly_TEXT
                                  THEN (X.Periodic_AMNT * 52) / 12
                                 WHEN @Lc_Monthly_TEXT
                                  THEN (X.Periodic_AMNT * 12) / 12
                                 WHEN @Lc_Biweekly_TEXT
                                  THEN (X.Periodic_AMNT * 26) / 12
                                 WHEN @Lc_Semimonthly_TEXT
                                  THEN (X.Periodic_AMNT * 24) / 12
                                 WHEN @Lc_Quarterly_TEXT
                                  THEN (X.Periodic_AMNT * 4) / 12
                                 WHEN @Lc_Annual_TEXT
                                  THEN X.Periodic_AMNT / 12
                                 ELSE X.Periodic_AMNT
                                END
                               ELSE 0
                              END), 0) AS Monthly_AMNT,
                 ISNULL(MAX(CASE
                             WHEN X.FreqPeriodic_CODE IS NULL
                              THEN 0
                             ELSE 1
                            END), 0) AS RowCount_NUMB
            FROM OBLE_Y1 X
           WHERE X.Case_IDNO = @An_Case_IDNO
             AND X.OrderSeq_NUMB = @An_OrderSeq_NUMB
             AND X.TypeDebt_CODE = @Ac_TypeDebt_CODE
             AND X.EndValidity_DATE = @Ld_High_DATE
             AND X.FreqPeriodic_CODE != @Lc_OnRequest_TEXT
             AND ((X.BeginObligation_DATE <= @Ld_System_DATE
                   AND X.EndObligation_DATE = (SELECT MAX(b.EndObligation_DATE)
                                                 FROM OBLE_Y1 b
                                                WHERE b.Case_IDNO = X.Case_IDNO
                                                  AND b.OrderSeq_NUMB = X.OrderSeq_NUMB
                                                  AND b.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                                  AND b.BeginObligation_DATE <= @Ld_System_DATE
                                                  AND b.EndValidity_DATE = @Ld_High_DATE))
                   OR (X.BeginObligation_DATE > @Ld_System_DATE
                       AND X.EndObligation_DATE = (SELECT MIN(b.EndObligation_DATE)
                                                     FROM OBLE_Y1 b
                                                    WHERE b.Case_IDNO = X.Case_IDNO
                                                      AND b.OrderSeq_NUMB = X.OrderSeq_NUMB
                                                      AND b.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                                      AND b.BeginObligation_DATE > @Ld_System_DATE
                                                      AND b.EndValidity_DATE = @Ld_High_DATE)
                       AND NOT EXISTS (SELECT 1
                                         FROM OBLE_Y1 c
                                        WHERE c.Case_IDNO = X.Case_IDNO
                                          AND c.OrderSeq_NUMB = X.OrderSeq_NUMB
                                          AND c.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                          AND c.BeginObligation_DATE <= @Ld_System_DATE
                                          AND c.EndValidity_DATE = @Ld_High_DATE))))AS Y;
 END; --End of OBLE_RETRIEVE_S23 


GO
