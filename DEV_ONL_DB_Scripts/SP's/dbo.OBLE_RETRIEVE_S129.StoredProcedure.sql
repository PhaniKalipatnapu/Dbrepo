/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S129]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S129]
(
	 @An_Case_IDNO					NUMERIC(6),
	 @An_Arrears_AMNT				NUMERIC(11, 2)	OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S129
  *     DESCRIPTION       : Procedure to check current support obligation on the case and arrears amount.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-JAN-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
		 SET @An_Arrears_AMNT = 0;

		 DECLARE @Ld_High_DATE                 DATE = '12/31/9999',
				 @Ld_System_DATE               DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

		SELECT @An_Arrears_AMNT = SUM(CAST(a.Naa_AMNT AS FLOAT) + CAST(a.Paa_AMNT AS FLOAT) + CAST(a.Taa_AMNT AS FLOAT) + CAST(a.Caa_AMNT AS FLOAT) + CAST(a.Upa_AMNT AS FLOAT) + CAST(a.Uda_AMNT AS FLOAT) + CAST(a.Ivef_AMNT AS FLOAT) + CAST(a.Medi_AMNT AS FLOAT) + CAST(a.Nffc_AMNT AS FLOAT) + CAST(a.Nivd_AMNT AS FLOAT) - CAST(a.Cur_Sup_AMNT AS FLOAT))
		FROM ( SELECT ISNULL((l.OweTotNaa_AMNT - l.AppTotNaa_AMNT), 0)  Naa_AMNT,
						   ISNULL((l.OweTotPaa_AMNT - l.AppTotPaa_AMNT), 0)  Paa_AMNT,
						   ISNULL((l.OweTotTaa_AMNT - l.AppTotTaa_AMNT), 0)  Taa_AMNT,
						   ISNULL((l.OweTotCaa_AMNT - l.AppTotCaa_AMNT), 0)  Caa_AMNT,
						   ISNULL((l.OweTotUpa_AMNT - l.AppTotUpa_AMNT), 0)  Upa_AMNT,
						   ISNULL((l.OweTotUda_AMNT - l.AppTotUda_AMNT), 0)  Uda_AMNT,
						   ISNULL((l.OweTotIvef_AMNT - l.AppTotIvef_AMNT), 0)  Ivef_AMNT,
						   ISNULL((l.OweTotMedi_AMNT - l.AppTotMedi_AMNT), 0)  Medi_AMNT,
						   ISNULL((l.OweTotNffc_AMNT - l.AppTotNffc_AMNT), 0)  Nffc_AMNT,
						   ISNULL((l.OweTotNonIvd_AMNT - l.AppTotNonIvd_AMNT), 0)  Nivd_AMNT,
						   ISNULL((l.OweTotCurSup_AMNT - l.AppTotCurSup_AMNT), 0)  Cur_Sup_AMNT
				FROM LSUP_Y1 l
				WHERE l.Case_IDNO = @An_Case_IDNO
				AND l.SupportYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ld_System_DATE,112),1,6)  
				AND l.EventGlobalSeq_NUMB = (SELECT MAX(l2.EventGlobalSeq_NUMB) 
													FROM LSUP_Y1 l2
												   WHERE l2.Case_IDNO = l.Case_IDNO
													 AND l2.OrderSeq_NUMB = l.OrderSeq_NUMB
													 AND l2.ObligationSeq_NUMB = l.ObligationSeq_NUMB
													 AND l2.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB) 	
				AND NOT EXISTS ( SELECT 1
							  FROM OBLE_Y1 o
							 WHERE o.Case_IDNO = l.Case_IDNO
							   AND o.EndValidity_DATE = @Ld_High_DATE
							   AND o.EndObligation_DATE > @Ld_System_DATE ) ) a

     
 END;	--End of OBLE_RETRIEVE_S129

GO
