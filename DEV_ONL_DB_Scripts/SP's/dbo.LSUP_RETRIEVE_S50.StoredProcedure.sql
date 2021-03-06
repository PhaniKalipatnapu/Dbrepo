/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S50]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[LSUP_RETRIEVE_S50] (
     @An_Case_IDNO			 NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @Ac_TypeDebt_CODE		 CHAR(2),
     @Ac_Fips_CODE			 CHAR(7),
     @An_Arrears_AMNT		 NUMERIC(11,2)	 OUTPUT
 )    
AS
/*
 *     PROCEDURE NAME     : LSUP_RETRIEVE_S50
 *     DESCRIPTION        : Procedure returns the arrear amount to populate in the header of modification at debt level.
 *     DEVELOPED BY       : IMP Team
 *     DEVELOPED ON       : 15-DEC-2011
 *     MODIFIED BY        : 
 *     MODIFIED ON        : 
 *     VERSION NO         : 1
*/
   BEGIN
      SET @An_Arrears_AMNT = NULL;
      
      DECLARE
         @Ld_High_DATE DATE  = '12/31/9999';
        
        SELECT @An_Arrears_AMNT = SUM(((
					 a.OweTotNaa_AMNT
					  + 
					 a.OweTotTaa_AMNT
					  + 
					 a.OweTotPaa_AMNT
					  + 
					 a.OweTotCaa_AMNT
					  + 
					 a.OweTotUda_AMNT
					  + 
					 a.OweTotUpa_AMNT
					  + 
					 a.OweTotIvef_AMNT
					  + 
					 a.OweTotNffc_AMNT
					  + 
					 a.OweTotNonIvd_AMNT
					  + 
					 a.OweTotMedi_AMNT) - (
					 a.AppTotNaa_AMNT
					  + 
					 a.AppTotTaa_AMNT
					  + 
					 a.AppTotPaa_AMNT
					  + 
					 a.AppTotCaa_AMNT
					  + 
					 a.AppTotUda_AMNT
					  + 
					 a.AppTotUpa_AMNT
					  + 
					 a.AppTotIvef_AMNT
					  + 
					 a.AppTotNffc_AMNT
					  + 
					 a.AppTotNonIvd_AMNT
					  + 
					 a.AppTotMedi_AMNT
					  + 
					 a.AppTotFuture_AMNT)))
        FROM LSUP_Y1  a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB IN  
         				 (
							SELECT DISTINCT b.ObligationSeq_NUMB
							  FROM OBLE_Y1  b
							 WHERE b.Case_IDNO = a.Case_IDNO 
							   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
							   AND b.TypeDebt_CODE = @Ac_TypeDebt_CODE
							   AND b.Fips_CODE = @Ac_Fips_CODE 
							   AND b.EndValidity_DATE = @Ld_High_DATE
						 ) 
         AND a.SupportYearMonth_NUMB = 
						 (
							SELECT MAX(c.SupportYearMonth_NUMB) 
							  FROM LSUP_Y1  c
							 WHERE c.Case_IDNO = a.Case_IDNO 
							   AND c.OrderSeq_NUMB = a.OrderSeq_NUMB 
							   AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
						 ) 
         AND a.EventGlobalSeq_NUMB = 
						 (
							SELECT MAX(d.EventGlobalSeq_NUMB) 
							  FROM LSUP_Y1  d
							 WHERE d.Case_IDNO = a.Case_IDNO 
							   AND d.OrderSeq_NUMB = a.OrderSeq_NUMB 
							   AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
							   AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB
						 );

  END;--End of LSUP_RETRIEVE_S50 


GO
