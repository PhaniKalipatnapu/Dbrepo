/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S96]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S96] (
 @An_Case_IDNO   NUMERIC(6),
 @An_Naa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_Paa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_Taa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_Caa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_Upa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_Uda_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_Ivef_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_Nffc_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_NonIvd_AMNT NUMERIC(11, 2) OUTPUT,
 @An_Medi_AMNT   NUMERIC(11, 2) OUTPUT
 )
AS
 /*                                                                           
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S96                                  
  *     DESCRIPTION       : Procedure To Retrieves the applied arrears for the given case                                                  
  *     DEVELOPED BY      : IMP Team                                        
  *     DEVELOPED ON      : 26/11/2011                                      
  *     MODIFIED BY       :                                                   
  *     MODIFIED ON       :                                                   
  *     VERSION NO        : 1                                                 
 */
 BEGIN
  SELECT @An_Caa_AMNT	 = NULL,
         @An_Ivef_AMNT	 = NULL,
         @An_Medi_AMNT	 = NULL,
         @An_Naa_AMNT	 = NULL,
         @An_Nffc_AMNT	 = NULL,
         @An_NonIvd_AMNT = NULL,
         @An_Paa_AMNT    = NULL,
         @An_Taa_AMNT    = NULL,
         @An_Uda_AMNT    = NULL,
         @An_Upa_AMNT    = NULL;
         
  DECLARE
         @Ln_OrderSeq_NUMB NUMERIC(2) = 99,
         @Li_One_NUMB      INT        = 1;

  WITH Lsup_CTE
       AS (SELECT LS.OweTotNaa_AMNT,
                  LS.AppTotNaa_AMNT,
                  LS.OweTotPaa_AMNT,
                  LS.AppTotPaa_AMNT,
                  LS.OweTotTaa_AMNT,
                  LS.AppTotTaa_AMNT,
                  LS.OweTotCaa_AMNT,
                  LS.AppTotCaa_AMNT,
                  LS.OweTotUpa_AMNT,
                  LS.AppTotUpa_AMNT,
                  LS.OweTotUda_AMNT,
                  LS.AppTotUda_AMNT,
                  LS.OweTotIvef_AMNT,
                  LS.AppTotIvef_AMNT,
                  LS.OweTotMedi_AMNT,
                  LS.AppTotMedi_AMNT,
                  LS.OweTotNffc_AMNT,
                  LS.AppTotNffc_AMNT,
                  LS.OweTotNonIvd_AMNT,
                  LS.AppTotNonIvd_AMNT,
                  ROW_NUMBER() OVER( PARTITION BY LS.Case_IDNO, LS.OrderSeq_NUMB, LS.ObligationSeq_NUMB ORDER BY LS.SupportYearMonth_NUMB DESC, LS.EventGlobalSeq_NUMB DESC) Row_NUMB
             FROM LSUP_Y1 LS
            WHERE LS.Case_IDNO = @An_Case_IDNO
              AND LS.OrderSeq_NUMB != @Ln_OrderSeq_NUMB)
  SELECT @An_Naa_AMNT    = SUM(LS.OweTotNaa_AMNT - LS.AppTotNaa_AMNT),
         @An_Paa_AMNT    = SUM(LS.OweTotPaa_AMNT - LS.AppTotPaa_AMNT),
         @An_Taa_AMNT    = SUM(LS.OweTotTaa_AMNT - LS.AppTotTaa_AMNT),
         @An_Caa_AMNT    = SUM(LS.OweTotCaa_AMNT - LS.AppTotCaa_AMNT),
         @An_Upa_AMNT    = SUM(LS.OweTotUpa_AMNT - LS.AppTotUpa_AMNT),
         @An_Uda_AMNT    = SUM(LS.OweTotUda_AMNT - LS.AppTotUda_AMNT),
         @An_Ivef_AMNT   = SUM(LS.OweTotIvef_AMNT - LS.AppTotIvef_AMNT),
         @An_Medi_AMNT   = SUM(LS.OweTotMedi_AMNT - LS.AppTotMedi_AMNT),
         @An_Nffc_AMNT   = SUM(LS.OweTotNffc_AMNT - LS.AppTotNffc_AMNT),
         @An_NonIvd_AMNT = SUM(LS.OweTotNonIvd_AMNT - LS.AppTotNonIvd_AMNT)
    FROM Lsup_CTE LS
   WHERE Row_NUMB = @Li_One_NUMB;

 END; --End Of Procedure LSUP_RETRIEVE_S96 


GO
