/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S92]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S92](
 @An_Case_IDNO           NUMERIC(6, 0),
 @Ad_Event_DATE          DATE,
 @An_EventGlobalSeq_NUMB NUMERIC(19, 0),
 @An_Caa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Ivef_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_Medi_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_Naa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Nffc_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_NonIvd_AMNT         NUMERIC(11, 2) OUTPUT,
 @An_Paa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Taa_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Uda_AMNT            NUMERIC(11, 2) OUTPUT,
 @An_Upa_AMNT            NUMERIC(11, 2) OUTPUT
 )
AS
 /*                                                                                                           
  *     PROCEDURE NAME   : LSUP_RETRIEVE_S92                                                                  
  *     DESCRIPTION      : Procedure To Retrieve The Sum Of Transcation Ammounts From LSUP_Y1                                                                                  
  *     DEVELOPED BY     : IMP Team                                                                        
  *     DEVELOPED ON     : 25/11/2011                                                                 
  *     MODIFIED BY      :                                                                                   
  *     MODIFIED ON      :                                                                                   
  *     VERSION NO       : 1                                                                                 
 */
 BEGIN
  SELECT @An_Caa_AMNT		= NULL,
         @An_Ivef_AMNT		= NULL,
         @An_Medi_AMNT	    = NULL,
         @An_Naa_AMNT		= NULL,
         @An_Nffc_AMNT		= NULL,
         @An_NonIvd_AMNT	= NULL,
         @An_Paa_AMNT		= NULL,
         @An_Taa_AMNT		= NULL,
         @An_Uda_AMNT       = NULL,
         @An_Upa_AMNT		= NULL;

  DECLARE 
         @Ln_EventFunction_NUMB         NUMERIC(4) = 1095,
         @Ln_EventSupportYearMonth_NUMB NUMERIC(6) = YEAR(@Ad_Event_DATE) * 100 + MONTH(@Ad_Event_DATE);

  SELECT @An_Naa_AMNT    = SUM(LS.TransactionNaa_AMNT),
         @An_Paa_AMNT    = SUM(LS.TransactionPaa_AMNT),
         @An_Taa_AMNT    = SUM(LS.TransactionTaa_AMNT),
         @An_Caa_AMNT    = SUM(LS.TransactionCaa_AMNT),
         @An_Upa_AMNT    = SUM(LS.TransactionUpa_AMNT),
         @An_Uda_AMNT    = SUM(LS.TransactionUda_AMNT),
         @An_Ivef_AMNT   = SUM(LS.TransactionIvef_AMNT),
         @An_Medi_AMNT	 = SUM(LS.TransactionMedi_AMNT),
         @An_Nffc_AMNT   = SUM(LS.TransactionNffc_AMNT),
         @An_NonIvd_AMNT = SUM(LS.TransactionNonIvd_AMNT)
    FROM LSUP_Y1 LS
   WHERE LS.Case_IDNO				= @An_Case_IDNO
     AND LS.EventGlobalSeq_NUMB		= @An_EventGlobalSeq_NUMB
     AND LS.EventFunctionalSeq_NUMB != @Ln_EventFunction_NUMB
     AND LS.SupportYearMonth_NUMB   = @Ln_EventSupportYearMonth_NUMB;
     
 END; -- END Of Procedure LSUP_RETRIEVE_S92                                                                                                         

GO
