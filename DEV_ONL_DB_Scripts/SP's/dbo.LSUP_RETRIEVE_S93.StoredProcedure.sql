/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S93]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S93] (
 @An_Case_IDNO           NUMERIC(6),
 @An_EventGlobalSeq_NUMB NUMERIC(19),
 @An_Naa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Paa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Taa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Caa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Upa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Uda_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Ivef_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_Nffc_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_NonIvd_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_Medi_AMNT           NUMERIC(11, 2) OUTPUT
 )
AS
 /*                                                                                              
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S93                                                     
  *     DESCRIPTION       : Procedure To Retrieve The Transcation Ammounts From LSUP_Y1 Based on EventGlobalSeq_NUMB                                                                     
  *     DEVELOPED BY      : IMP Team                                                           
  *     DEVELOPED ON      : 25/11/2011                                                        
  *     MODIFIED BY       :                                                                      
  *     MODIFIED ON       :                                                                      
  *     VERSION NO        : 1                                                                    
 */
 BEGIN
  SELECT @An_Caa_AMNT		= NULL,
         @An_Ivef_AMNT		= NULL,
         @An_Medi_AMNT		= NULL,
         @An_Naa_AMNT		= NULL,
         @An_Nffc_AMNT		= NULL,
         @An_NonIvd_AMNT	= NULL,
         @An_Paa_AMNT		= NULL,
         @An_Taa_AMNT		= NULL,
         @An_Uda_AMNT		= NULL,
         @An_Upa_AMNT		= NULL;

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
    FROM LSUP_Y1 LS
   WHERE LS.Case_IDNO = @An_Case_IDNO
     AND LS.SupportYearMonth_NUMB = (SELECT MAX(c.SupportYearMonth_NUMB)
                                       FROM LSUP_Y1 c
                                      WHERE c.Case_IDNO = @An_Case_IDNO
                                        AND c.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB)
     AND LS.EventGlobalSeq_NUMB   = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                       FROM LSUP_Y1 b
                                      WHERE b.OrderSeq_NUMB = LS.OrderSeq_NUMB
                                        AND b.ObligationSeq_NUMB = LS.ObligationSeq_NUMB
                                        AND b.Case_IDNO = LS.Case_IDNO
                                        AND b.SupportYearMonth_NUMB = LS.SupportYearMonth_NUMB
                                        AND b.EventGlobalSeq_NUMB <= @An_EventGlobalSeq_NUMB);
                                      
 END; --End Of Procedure LSUP_RETRIEVE_S93 


GO
