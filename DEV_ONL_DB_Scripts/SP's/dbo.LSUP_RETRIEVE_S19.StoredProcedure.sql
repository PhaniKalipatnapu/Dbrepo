/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S19](
 @An_Case_IDNO            NUMERIC(6, 0),
 @An_AssignedArrears_AMNT NUMERIC(11, 2) OUTPUT,
 @An_Arrears_AMNT		  NUMERIC(11,2)  OUTPUT,
 @Ad_ArrearComputed_DATE  DATE	         OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S19
  *     DESCRIPTION       : Retrieve Assigned Arrears Amount for a Case Idno, Adjust or Applied Year-Month, and Global Event sequence.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  SELECT 
       @An_AssignedArrears_AMNT = NULL,
       @An_Arrears_AMNT = NULL,
       @Ad_ArrearComputed_DATE = NULL;
  
  DECLARE
       	@Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @An_AssignedArrears_AMNT = ISNULL((SUM(l.OweTotPaa_AMNT + l.OweTotCaa_AMNT + l.OweTotTaa_AMNT) - SUM(l.AppTotPaa_AMNT + l.AppTotCaa_AMNT + l.AppTotTaa_AMNT)),0),
    @An_Arrears_AMNT = ROUND(ISNULL(SUM(
                  ISNULL((l.OweTotNaa_AMNT - l.AppTotNaa_AMNT),0) + 
                  ISNULL((l.OweTotPaa_AMNT - l.AppTotPaa_AMNT),0) + 
                  ISNULL((l.OweTotTaa_AMNT - l.AppTotTaa_AMNT),0) + 
                  ISNULL((l.OweTotCaa_AMNT - l.AppTotCaa_AMNT),0) + 
                  ISNULL((l.OweTotUpa_AMNT - l.AppTotUpa_AMNT),0) + 
                  ISNULL((l.OweTotUda_AMNT - l.AppTotUda_AMNT),0) + 
                  ISNULL((l.OweTotIvef_AMNT - l.AppTotIvef_AMNT),0) + 
                  ISNULL((l.OweTotNffc_AMNT - l.AppTotNffc_AMNT),0) + 
                  ISNULL((l.OweTotMedi_AMNT - l.AppTotMedi_AMNT),0) + 
                  ISNULL((l.OweTotNonIvd_AMNT - l.AppTotNonIvd_AMNT),0) 
                   ), 0), 2),
       @Ad_ArrearComputed_DATE = @Ld_Current_DATE  
    FROM LSUP_Y1 l
   WHERE l.Case_IDNO = @An_Case_IDNO
     AND l.SupportYearMonth_NUMB = (SELECT MAX(L1.SupportYearMonth_NUMB) 
                                      FROM LSUP_Y1   L1
                                     WHERE L1.Case_IDNO = l.Case_IDNO
                                       AND L1.OrderSeq_NUMB = l.OrderSeq_NUMB
                                       AND L1.ObligationSeq_NUMB = l.ObligationSeq_NUMB)
     AND l.EventGlobalSeq_NUMB = (SELECT MAX(L2.EventGlobalSeq_NUMB) 
                                    FROM LSUP_Y1   L2
                                   WHERE L2.Case_IDNO = l.Case_IDNO
                                     AND L2.OrderSeq_NUMB = l.OrderSeq_NUMB
                                     AND L2.ObligationSeq_NUMB = l.ObligationSeq_NUMB
                                     AND L2.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB);
 END; --End of LSUP_RETRIEVE_S19


GO
