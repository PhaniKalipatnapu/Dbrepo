/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S80]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Not Matching With Oracle
CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S80](
 @An_Case_IDNO           NUMERIC(6),
 @An_CurrentBalance_AMNT NUMERIC(11, 2) OUTPUT
 )
AS
 /*                                                                                                
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S80                                                       
  *     DESCRIPTION       : Procedure To Retrieves the support log current balance amount for a case                                                                      
  *     DEVELOPED BY      : IMP TEAM                                                            
  *     DEVELOPED ON      : 11/23/2011                                                            
  *     MODIFIED BY       :                                                                        
  *     MODIFIED ON       :                                                                        
  *     VERSION NO        : 1                                                                      
 */
 BEGIN
  SET @An_CurrentBalance_AMNT = NULL;
 
  DECLARE
         @Ln_OrderSeq_NUMB NUMERIC(2) = 99;

  SELECT @An_CurrentBalance_AMNT = SUM((LS.OweTotNaa_AMNT    - LS.AppTotNaa_AMNT)   + 
                                       (LS.OweTotPaa_AMNT    - LS.AppTotPaa_AMNT)   + 
                                       (LS.OweTotTaa_AMNT    - LS.AppTotTaa_AMNT)   + 
                                       (LS.OweTotCaa_AMNT    - LS.AppTotCaa_AMNT)   + 
                                       (LS.OweTotUpa_AMNT    - LS.AppTotUpa_AMNT)   + 
                                       (LS.OweTotUda_AMNT    - LS.AppTotUda_AMNT)   + 
                                       (LS.OweTotIvef_AMNT   - LS.AppTotIvef_AMNT)  + 
                                       (LS.OweTotMedi_AMNT   - LS.AppTotMedi_AMNT)  + 
                                       (LS.OweTotNffc_AMNT   - LS.AppTotNffc_AMNT)  + 
                                       (LS.OweTotNonIvd_AMNT - LS.AppTotNonIvd_AMNT)+ 
                                        -LS.AppTotFuture_AMNT)
    FROM LSUP_Y1 LS
   WHERE LS.Case_IDNO = @An_Case_IDNO
     AND LS.OrderSeq_NUMB != @Ln_OrderSeq_NUMB
     AND LS.SupportYearMonth_NUMB = (SELECT MAX(c.SupportYearMonth_NUMB)
                                       FROM LSUP_Y1 c
                                      WHERE LS.OrderSeq_NUMB = c.OrderSeq_NUMB
                                        AND LS.ObligationSeq_NUMB = c.ObligationSeq_NUMB
                                        AND LS.Case_IDNO = c.Case_IDNO)
     AND LS.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                     FROM LSUP_Y1 b
                                    WHERE LS.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB
                                      AND LS.OrderSeq_NUMB = b.OrderSeq_NUMB
                                      AND LS.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                      AND LS.Case_IDNO = b.Case_IDNO);
                                      
 END; --End Of Procedure LSUP_RETRIEVE_S80


GO
