/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S119]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S119](  
     @An_Case_IDNO					NUMERIC(6),
     @An_OrderSeq_NUMB				NUMERIC(2),
     @An_ObligationSeq_NUMB			NUMERIC(2),
     @An_SupportYearMonth_NUMB		NUMERIC(6),
     @An_EventGlobalSeq_NUMB		NUMERIC(19),
     @An_Naa_AMNT                   NUMERIC(11,2)    OUTPUT,
     @An_Paa_AMNT					NUMERIC(11,2)	 OUTPUT,
     @An_Taa_AMNT					NUMERIC(11,2)	 OUTPUT,
     @An_Caa_AMNT					NUMERIC(11,2)	 OUTPUT,
     @An_Upa_AMNT                   NUMERIC(11,2)    OUTPUT,
     @An_Uda_AMNT                   NUMERIC(11,2)    OUTPUT,
     @An_Ivef_AMNT					NUMERIC(11,2)	 OUTPUT,
     @An_Nffc_AMNT                  NUMERIC(11,2)    OUTPUT,
     @An_NonIvd_AMNT                NUMERIC(11,2)    OUTPUT,
     @An_Medi_AMNT                  NUMERIC(11,2)    OUTPUT
      )
AS
/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S119
 *     DESCRIPTION       : This procedure is used to populate the data for Arrears Before
                           Case Category Change pop up and used to fill the data for the grid details.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN

    SELECT  @An_Naa_AMNT	= NULL ,
			@An_Paa_AMNT	= NULL ,
			@An_Taa_AMNT	= NULL ,
			@An_Caa_AMNT	= NULL ,
			@An_Upa_AMNT	= NULL ,
			@An_Uda_AMNT	= NULL ,
			@An_Ivef_AMNT	= NULL ,
			@An_Nffc_AMNT	= NULL ,
			@An_NonIvd_AMNT = NULL ,
			@An_Medi_AMNT	= NULL ;

      SELECT @An_Naa_AMNT    = SUM(s.OweTotNaa_AMNT - s.AppTotNaa_AMNT), 
         @An_Paa_AMNT    = SUM(s.OweTotPaa_AMNT - s.AppTotPaa_AMNT), 
         @An_Taa_AMNT    = SUM(s.OweTotTaa_AMNT - s.AppTotTaa_AMNT), 
         @An_Caa_AMNT    = SUM(s.OweTotCaa_AMNT - s.AppTotCaa_AMNT), 
         @An_Upa_AMNT    = SUM(s.OweTotUpa_AMNT - s.AppTotUpa_AMNT), 
         @An_Uda_AMNT    = SUM(s.OweTotUda_AMNT - s.AppTotUda_AMNT), 
         @An_Ivef_AMNT   = SUM(s.OweTotIvef_AMNT - s.AppTotIvef_AMNT), 
         @An_Medi_AMNT   = SUM(s.OweTotMedi_AMNT - s.AppTotMedi_AMNT), 
         @An_Nffc_AMNT   = SUM(s.OweTotNffc_AMNT - s.AppTotNffc_AMNT), 
         @An_NonIvd_AMNT = SUM(s.OweTotNonIvd_AMNT - s.AppTotNonIvd_AMNT) 
       FROM LSUP_Y1   s
      WHERE s.Case_IDNO  = @An_Case_IDNO 
        AND s.OrderSeq_NUMB = @An_OrderSeq_NUMB 
        AND s.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
        AND s.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB 
        AND s.EventGlobalSeq_NUMB = 
           (SELECT MAX(b.EventGlobalSeq_NUMB) 
            FROM LSUP_Y1   b
            WHERE b.Case_IDNO = s.Case_IDNO 
              AND b.OrderSeq_NUMB = s.OrderSeq_NUMB 
              AND b.ObligationSeq_NUMB = s.ObligationSeq_NUMB 
              AND b.SupportYearMonth_NUMB = s.SupportYearMonth_NUMB 
              AND b.EventGlobalSeq_NUMB < @An_EventGlobalSeq_NUMB);

END; --End Of Procedure LSUP_RETRIEVE_S119 


GO
