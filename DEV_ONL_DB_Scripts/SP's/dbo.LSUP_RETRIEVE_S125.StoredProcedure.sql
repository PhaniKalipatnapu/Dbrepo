/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S125]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S125]
  (
     @An_Case_IDNO            NUMERIC(6,0),  
     @An_OrderSeq_NUMB        NUMERIC(2,0),  
     @An_ObligationSeq_NUMB   NUMERIC(2,0),
     @An_MtdCurSupOwed_AMNT   NUMERIC(11,2) OUTPUT,
     @An_Arrears_AMNT		  NUMERIC(11,2)	OUTPUT
  )
AS  
  
/*  
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S125  
 *     DESCRIPTION       : Procedure to retrieve the MSO amount for the Obligation
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 24-FEB-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/ 
BEGIN
       SELECT @An_MtdCurSupOwed_AMNT = NULL,
			  @An_Arrears_AMNT		 = NULL;
       
	SELECT @An_MtdCurSupOwed_AMNT = a.MtdCurSupOwed_AMNT,
		   @An_Arrears_AMNT = ((a.OweTotNaa_AMNT + a.OweTotTaa_AMNT + a.OweTotPaa_AMNT + a.OweTotCaa_AMNT + a.OweTotUda_AMNT + a.OweTotUpa_AMNT + a.OweTotIvef_AMNT + a.OweTotNffc_AMNT + a.OweTotNonIvd_AMNT + a.OweTotMedi_AMNT) - (  a.AppTotNaa_AMNT + a.AppTotTaa_AMNT + a.AppTotPaa_AMNT + a.AppTotCaa_AMNT + a.AppTotUda_AMNT + a.AppTotUpa_AMNT + a.AppTotIvef_AMNT + a.AppTotNffc_AMNT + a.AppTotNonIvd_AMNT + a.AppTotMedi_AMNT + a.AppTotFuture_AMNT))
	  FROM LSUP_Y1 a
	 WHERE a.Case_IDNO = @An_Case_IDNO   
	   AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB   
	   AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB   
	   AND a.SupportYearMonth_NUMB = ( SELECT MAX(b.SupportYearMonth_NUMB)  
										 FROM LSUP_Y1 b  
										WHERE a.Case_IDNO = b.Case_IDNO   
										  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB   
										  AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB )  
	   AND a.EventGlobalSeq_NUMB =  ( SELECT MAX(b.EventGlobalSeq_NUMB)  
									    FROM LSUP_Y1 b  
									   WHERE a.Case_IDNO = b.Case_IDNO   
									     AND a.OrderSeq_NUMB = b.OrderSeq_NUMB   
									     AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB   
									     AND a.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB);  
									     
END;--End of LSUP_RETRIEVE_S125


GO
