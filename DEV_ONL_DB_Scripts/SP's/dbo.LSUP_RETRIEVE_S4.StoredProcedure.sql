/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S4]
    (
     @An_Case_IDNO		              NUMERIC(6,0),
     @An_OrderSeq_NUMB		          NUMERIC(2,0),
     @An_ObligationSeq_NUMB		      NUMERIC(2,0),
     @An_SupportYearMonth_NUMB		  NUMERIC(6,0),
     @Ac_Exists_INDC			      CHAR(1)        OUTPUT,
     @Ac_TypeWelfare_CODE		      CHAR(1)		 OUTPUT,
	 @An_OweTotCurSup_AMNT	          NUMERIC(11,2)	 OUTPUT,
	 @An_AppTotCurSup_AMNT	          NUMERIC(11,2)	 OUTPUT,
	 @An_TransactionExptPay_AMNT      NUMERIC(11,2)	 OUTPUT,
	 @An_OweTotExptPay_AMNT	          NUMERIC(11,2)	 OUTPUT,
	 @An_AppTotExptPay_AMNT	          NUMERIC(11,2)	 OUTPUT,
     @An_CurSupToPay_AMNT             NUMERIC(11,2)  OUTPUT,
     @An_OweTotNaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotNaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_OweTotPaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotPaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_OweTotTaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotTaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_OweTotCaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotCaa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_OweTotUpa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotUpa_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_OweTotUda_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotUda_AMNT               NUMERIC(11,2)  OUTPUT,
     @An_AppTotIvef_AMNT              NUMERIC(11,2)  OUTPUT,
     @An_OweTotIvef_AMNT              NUMERIC(11,2)  OUTPUT,
     @An_OweTotMedi_AMNT              NUMERIC(11,2)  OUTPUT,
     @An_AppTotMedi_AMNT              NUMERIC(11,2)  OUTPUT,
     @An_OweTotNffc_AMNT              NUMERIC(11,2)  OUTPUT,
     @An_AppTotNffc_AMNT              NUMERIC(11,2)  OUTPUT,
     @An_OweTotNonIvd_AMNT            NUMERIC(11,2)  OUTPUT,
     @An_AppTotNonIvd_AMNT            NUMERIC(11,2)  OUTPUT,
     @An_AppTotFuture_AMNT            NUMERIC(11,2)  OUTPUT,
     @An_TotArrears_AMNT			  NUMERIC(22,2)  OUTPUT,
     @An_UnPaidMso_AMNT				  NUMERIC(11,2)  OUTPUT,
     @An_MtdAccrual_AMNT                 NUMERIC(11,2)  OUTPUT,
     @An_EventGlobalSeq_NUMB          NUMERIC(19,0)  OUTPUT
     )
AS
/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S4
 *     DESCRIPTION       :Procedure to allow the user to do arrears adjustment
                           for the amounts excluding the current support. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

      SELECT @Ac_Exists_INDC ='N',
             @An_CurSupToPay_AMNT = 0,
			 @An_OweTotCaa_AMNT = 0,
			 @An_OweTotIvef_AMNT = 0,
			 @An_OweTotMedi_AMNT = 0,
			 @An_OweTotNaa_AMNT = 0,
			 @An_OweTotNffc_AMNT = 0,
			 @An_OweTotNonIvd_AMNT = 0,
			 @An_OweTotPaa_AMNT = 0,
			 @An_OweTotTaa_AMNT = 0,
			 @An_OweTotUda_AMNT = 0,
			 @An_OweTotUpa_AMNT = 0,
			 @An_AppTotCaa_AMNT = 0,
			 @An_AppTotFuture_AMNT = 0,
			 @An_AppTotIvef_AMNT = 0,
			 @An_AppTotMedi_AMNT = 0,
			 @An_AppTotNaa_AMNT = 0,
			 @An_AppTotNffc_AMNT = 0,
			 @An_AppTotNonIvd_AMNT = 0,
			 @An_AppTotPaa_AMNT = 0,
			 @An_AppTotTaa_AMNT = 0,
			 @An_AppTotUda_AMNT = 0,
			 @An_AppTotUpa_AMNT = 0,
			 @An_TotArrears_AMNT = 0,
			 @An_UnPaidMso_AMNT = 0,
			 @Ac_TypeWelfare_CODE = NULL,
			 @An_OweTotCurSup_AMNT = 0,	    
			 @An_AppTotCurSup_AMNT = 0,	    
			 @An_TransactionExptPay_AMNT = 0,
			 @An_OweTotExptPay_AMNT	= 0,    
			 @An_AppTotExptPay_AMNT	= 0,    
			 @An_MtdAccrual_AMNT = 0,
			 @An_EventGlobalSeq_NUMB = NULL;

     DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
             @Li_Zero_NUMB SMALLINT = 0;

      SELECT @An_TransactionExptPay_AMNT = a.TransactionExptPay_AMNT, 
			 @An_OweTotExptPay_AMNT = a.OweTotExptPay_AMNT, 
			 @An_AppTotExptPay_AMNT = a.AppTotExptPay_AMNT, 
			 @An_MtdAccrual_AMNT = a.MtdCurSupOwed_AMNT, 
			 @An_OweTotCurSup_AMNT = a.OweTotCurSup_AMNT, 
			 @An_AppTotCurSup_AMNT = a.AppTotCurSup_AMNT, 
			 @Ac_Exists_INDC = @Lc_Yes_INDC,
             @An_OweTotPaa_AMNT = a.OweTotPaa_AMNT, 
			 @An_AppTotPaa_AMNT = a.AppTotPaa_AMNT, 
			 @An_OweTotTaa_AMNT = a.OweTotTaa_AMNT, 
			 @An_AppTotTaa_AMNT = a.AppTotTaa_AMNT, 
			 @An_OweTotNaa_AMNT = a.OweTotNaa_AMNT, 
			 @An_AppTotNaa_AMNT = a.AppTotNaa_AMNT, 
			 @An_OweTotCaa_AMNT = a.OweTotCaa_AMNT, 
			 @An_AppTotCaa_AMNT = a.AppTotCaa_AMNT, 
			 @An_OweTotUda_AMNT = a.OweTotUda_AMNT, 
			 @An_AppTotUda_AMNT = a.AppTotUda_AMNT, 
			 @An_OweTotUpa_AMNT = a.OweTotUpa_AMNT, 
			 @An_AppTotUpa_AMNT = a.AppTotUpa_AMNT, 
			 @An_OweTotIvef_AMNT = a.OweTotIvef_AMNT, 
			 @An_AppTotIvef_AMNT = a.AppTotIvef_AMNT, 
			 @An_OweTotMedi_AMNT = a.OweTotMedi_AMNT, 
			 @An_AppTotMedi_AMNT = a.AppTotMedi_AMNT, 
			 @An_OweTotNffc_AMNT = a.OweTotNffc_AMNT, 
			 @An_AppTotNffc_AMNT = a.AppTotNffc_AMNT, 
			 @An_OweTotNonIvd_AMNT = a.OweTotNonIvd_AMNT, 
			 @An_AppTotNonIvd_AMNT = a.AppTotNonIvd_AMNT, 
			 @An_AppTotFuture_AMNT = a.AppTotFuture_AMNT, 
			 @An_CurSupToPay_AMNT = (a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT), 
			 @An_UnPaidMso_AMNT = ISNULL((a.MtdCurSupOwed_AMNT - a.AppTotCurSup_AMNT), @Li_Zero_NUMB), 
			 @An_TotArrears_AMNT =    ( ((ISNULL(a.OweTotNaa_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotNaa_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotPaa_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotPaa_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotTaa_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotTaa_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotCaa_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotCaa_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotUpa_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotUpa_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotUda_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotUda_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotIvef_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotIvef_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotNffc_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotNffc_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotNonIvd_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotNonIvd_AMNT, @Li_Zero_NUMB)) + (ISNULL(a.OweTotMedi_AMNT, @Li_Zero_NUMB) - ISNULL(a.AppTotMedi_AMNT, @Li_Zero_NUMB)) - ISNULL(a.AppTotFuture_AMNT, @Li_Zero_NUMB)) - (a.OweTotCurSup_AMNT - a.AppTotCurSup_AMNT)), 
			 @Ac_TypeWelfare_CODE = a.TypeWelfare_CODE,
			 @An_EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB 
        FROM LSUP_Y1  a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
         AND a.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB 
         AND a.EventGlobalSeq_NUMB = 
						 (
							SELECT MAX(b.EventGlobalSeq_NUMB) 
							  FROM LSUP_Y1  b
							 WHERE b.Case_IDNO = a.Case_IDNO 
							   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
							   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
							   AND b.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB
						 );

END; --End of LSUP_RETRIEVE_S4


GO
