/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S124]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S124]
(
	 @An_Case_IDNO					NUMERIC(6, 0),
	 @An_OrderSeq_NUMB				NUMERIC(2, 0),
	 @Ac_Fips_CODE					CHAR(7),
	 @Ac_TypeDebt_CODE				CHAR(2),
	 @Ac_ExpectToPay_CODE			CHAR(1)			OUTPUT,
	 @Ac_FreqPeriodic_CODE			CHAR(1)			OUTPUT,
	 @Ad_BeginObligation_DATE		DATE			OUTPUT,
	 @Ad_BeginValidity_DATE			DATE			OUTPUT,
	 @An_Payback_AMNT				NUMERIC(11, 2)	OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S124
  *     DESCRIPTION       : Procedure to populate the payback information block in Enter / Modify screen functions
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-JAN-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
		  SELECT @Ac_FreqPeriodic_CODE = NULL,
				 @An_Payback_AMNT = NULL,
				 @Ad_BeginObligation_DATE = NULL,
				 @Ac_ExpectToPay_CODE = NULL,
				 @Ad_BeginValidity_DATE = NULL;

		 DECLARE @Li_Zero_NUMB                 SMALLINT = 0,
				 @Lc_Annual_CODE               CHAR(1) = 'A',
				 @Lc_Daily_CODE                CHAR(1) = 'O',
				 @Lc_Monthly_CODE              CHAR(1) = 'M',
				 @Lc_OnRequest_CODE            CHAR(1) = 'O',
				 @Lc_Quarterly_CODE            CHAR(1) = 'Q',
				 @Lc_Semimonthly_CODE          CHAR(1) = 'S',
				 @Lc_Space_CODE                CHAR(1) = ' ',
				 @Lc_Weekly_CODE               CHAR(1) = 'W',
				 @Lc_Biweekly_CODE             CHAR(1) = 'B',
				 @Ld_High_DATE                 DATE = '12/31/9999',
				 @Ld_System_DATE               DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

		  SELECT @Ad_BeginObligation_DATE = Y.BeginObligation_DATE,
				 @Ad_BeginValidity_DATE = Y.BeginValidity_DATE,
				 @Ac_ExpectToPay_CODE = Y.ExpectToPay_CODE,
				 @Ac_FreqPeriodic_CODE = Y.FreqPeriodic_CODE,
				 @An_Payback_AMNT = CASE Y.FreqPeriodic_CODE
											WHEN @Lc_Daily_CODE
											 THEN (Y.Monthly_AMNT * 12) / 365
											WHEN @Lc_Weekly_CODE
											 THEN (Y.Monthly_AMNT * 12) / 52
											WHEN @Lc_Monthly_CODE
											 THEN Y.Monthly_AMNT
											WHEN @Lc_Biweekly_CODE
											 THEN (Y.Monthly_AMNT * 12) / 26
											WHEN @Lc_Semimonthly_CODE
											 THEN (Y.Monthly_AMNT * 12) / 24
											WHEN @Lc_Quarterly_CODE
											 THEN (Y.Monthly_AMNT * 3)
											WHEN @Lc_Annual_CODE
											 THEN (Y.Monthly_AMNT * 12)
											ELSE 0
										   END
			FROM (SELECT CASE MAX (CASE X.FreqPeriodic_CODE
									WHEN @Lc_Daily_CODE
									 THEN 365
									WHEN @Lc_Weekly_CODE
									 THEN 52
									WHEN @Lc_Monthly_CODE
									 THEN 12
									WHEN @Lc_Biweekly_CODE
									 THEN 26
									WHEN @Lc_Semimonthly_CODE
									 THEN 24
									WHEN @Lc_Quarterly_CODE
									 THEN 4
									WHEN @Lc_Annual_CODE
									 THEN 1
									ELSE 0
								   END)
						  WHEN 365
						   THEN @Lc_Daily_CODE
						  WHEN 52
						   THEN @Lc_Weekly_CODE
						  WHEN 12
						   THEN @Lc_Monthly_CODE
						  WHEN 26
						   THEN @Lc_Biweekly_CODE
						  WHEN 24
						   THEN @Lc_Semimonthly_CODE
						  WHEN 4
						   THEN @Lc_Quarterly_CODE
						  WHEN 1
						   THEN @Lc_Annual_CODE
						  WHEN 0
						   THEN @Lc_Space_CODE
						 END AS FreqPeriodic_CODE,
						 ISNULL (SUM (CASE X.FreqPeriodic_CODE
									   WHEN @Lc_Daily_CODE
										THEN (X.ExpectToPay_AMNT * 365) / 12
									   WHEN @Lc_Weekly_CODE
										THEN (X.ExpectToPay_AMNT * 52) / 12
									   WHEN @Lc_Monthly_CODE
										THEN (X.ExpectToPay_AMNT * 12) / 12
									   WHEN @Lc_Biweekly_CODE
										THEN (X.ExpectToPay_AMNT * 26) / 12
									   WHEN @Lc_Semimonthly_CODE
										THEN (X.ExpectToPay_AMNT * 24) / 12
									   WHEN @Lc_Quarterly_CODE
										THEN (X.ExpectToPay_AMNT * 4) / 12
									   WHEN @Lc_Annual_CODE
										THEN X.ExpectToPay_AMNT / 12
									   ELSE X.ExpectToPay_AMNT
									  END), @Li_Zero_NUMB) AS Monthly_AMNT,
				  MIN(X.BeginObligation_DATE) AS BeginObligation_DATE,
				  MAX(X.BeginValidity_DATE) AS BeginValidity_DATE,
				  MIN(X.ExpectToPay_CODE) AS ExpectToPay_CODE
			 FROM OBLE_Y1 X
		    WHERE X.Case_IDNO = @An_Case_IDNO
			  AND X.OrderSeq_NUMB = @An_OrderSeq_NUMB
			  AND X.Fips_CODE = ISNULL(@Ac_Fips_CODE,X.Fips_CODE)
			  AND X.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE,X.TypeDebt_CODE)
			  AND X.EndValidity_DATE = @Ld_High_DATE			 
		     AND   (     (     X.BeginObligation_DATE <= @Ld_System_DATE   
                 AND X.EndObligation_DATE =   
                        (  
                      SELECT MAX(b.EndObligation_DATE)  
                        FROM OBLE_Y1 b  
                       WHERE b.Case_IDNO = X.Case_IDNO   
                         AND b.OrderSeq_NUMB = X.OrderSeq_NUMB   
                         AND b.ObligationSeq_NUMB = X.ObligationSeq_NUMB   
                         AND b.BeginObligation_DATE <= @Ld_System_DATE   
                         AND b.EndValidity_DATE = @Ld_High_DATE  
                      )        
                 )   
                OR  (    X.BeginObligation_DATE > @Ld_System_DATE   
                     AND X.EndObligation_DATE =   
                        (  
                       SELECT MIN(b.EndObligation_DATE)  
                         FROM OBLE_Y1 b  
                        WHERE b.Case_IDNO = X.Case_IDNO   
                          AND b.OrderSeq_NUMB = X.OrderSeq_NUMB   
                          AND b.ObligationSeq_NUMB = X.ObligationSeq_NUMB   
                          AND b.BeginObligation_DATE > @Ld_System_DATE   
                          AND b.EndValidity_DATE = @Ld_High_DATE  
                         )   
                  AND NOT EXISTS   
                                (  
                      SELECT 1   
                        FROM OBLE_Y1 c  
                       WHERE c.Case_IDNO = X.Case_IDNO   
                         AND c.OrderSeq_NUMB = X.OrderSeq_NUMB   
                         AND c.ObligationSeq_NUMB = X.ObligationSeq_NUMB   
                         AND c.BeginObligation_DATE <= @Ld_System_DATE   
                         AND c.EndValidity_DATE = @Ld_High_DATE  
                                 )  
                 )  
                   )
			  AND X.ExpectToPay_AMNT > @Li_Zero_NUMB)   Y ;
     
 END;--End of OBLE_RETRIEVE_S124

GO
