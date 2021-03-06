/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S126]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S126]
  (
     @An_Case_IDNO						NUMERIC(6,0),
     @An_MonthlyCurrentSupport_AMNT		NUMERIC(11,2) OUTPUT,
     @An_MonthlyArrears_AMNT			NUMERIC(11,2) OUTPUT,
     @An_TotalArrearsOwed_AMNT			NUMERIC(11,2) OUTPUT,
     @An_TotalNcpFee_AMNT				NUMERIC(11,2) OUTPUT,
     @An_TotalAssigned_AMNT				NUMERIC(11,2) OUTPUT
  )
AS  
  
/*  
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S126  
 *     DESCRIPTION       : Procedure to retrieve the MSO amount for the Obligation
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 24-FEB-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/ 
BEGIN
	SELECT @An_MonthlyCurrentSupport_AMNT	= NULL,
			@An_MonthlyArrears_AMNT			= NULL,
			@An_TotalArrearsOwed_AMNT		= NULL,
			@An_TotalNcpFee_AMNT			= NULL,
			@An_TotalAssigned_AMNT			= NULL;
			
	DECLARE @Lc_TypeWelfareA_CODE		CHAR(1) = 'A',
			@Lc_TypeDebtGT_CODE			CHAR(2) = 'GT',
			@Lc_TypeDebtNF_CODE			CHAR(2) = 'NF',
			@Ld_High_DATE				DATE = '12/31/9999',	
			@Ln_SupportYearMonth_NUMB	NUMERIC = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(GetDate(),'YYYYMM' ) AS NUMERIC);	
       
	SELECT @An_MonthlyCurrentSupport_AMNT = ISNULL(SUM(MtdCurSupOwed_AMNT),0),
			@An_MonthlyArrears_AMNT = ISNULL(SUM(OweTotExptPay_AMNT),0),   
			@An_TotalArrearsOwed_AMNT = ISNULL(SUM(TotalArrearsOwed_AMNT),0),
			@An_TotalNcpFee_AMNT = ISNULL(SUM(TotalNcpFee_AMNT),0),
			@An_TotalAssigned_AMNT = ISNULL(SUM(TotalAssigned_AMNT),0)                          
	FROM (SELECT MtdCurSupOwed_AMNT AS MtdCurSupOwed_AMNT,
			OweTotExptPay_AMNT AS OweTotExptPay_AMNT,
			CASE WHEN TypeDebt_CODE NOT IN (@Lc_TypeDebtGT_CODE,@Lc_TypeDebtNF_CODE)
				THEN Arrear_AMNT - UnPaidCurrentSupport_AMNT 
				ELSE 0 
				END  TotalArrearsOwed_AMNT,
			CASE WHEN TypeDebt_CODE IN (@Lc_TypeDebtGT_CODE,@Lc_TypeDebtNF_CODE) 
				THEN Arrear_AMNT - UnPaidCurrentSupport_AMNT 
				ELSE 0 
				END  TotalNcpFee_AMNT,
			CASE WHEN TypeWelfare_CODE = @Lc_TypeWelfareA_CODE
				THEN Assigned_AMNT - UnPaidCurrentSupport_AMNT 
				ELSE Assigned_AMNT
				END  TotalAssigned_AMNT   
			FROM (SELECT (OweTotNaa_AMNT - AppTotNaa_AMNT
					+ OweTotPaa_AMNT - AppTotPaa_AMNT
					+ OweTotTaa_AMNT - AppTotTaa_AMNT
					+ OweTotCaa_AMNT - AppTotCaa_AMNT
					+ OweTotUpa_AMNT - AppTotUpa_AMNT
					+ OweTotUda_AMNT - AppTotUda_AMNT
					+ OweTotIvef_AMNT - AppTotIvef_AMNT
					+ OweTotMedi_AMNT - AppTotMedi_AMNT
					+ OweTotNffc_AMNT - AppTotNffc_AMNT
					+ OweTotNonIvd_AMNT - AppTotNonIvd_AMNT) AS Arrear_AMNT,
					(OweTotCurSup_AMNT  - AppTotCurSup_AMNT
					+ (CASE WHEN MtdCurSupOwed_AMNT < AppTotCurSup_AMNT THEN
						AppTotCurSup_AMNT - MtdCurSupOwed_AMNT
						ELSE 0
						END)) AS UnPaidCurrentSupport_AMNT,
					MtdCurSupOwed_AMNT,
					OweTotExptPay_AMNT,
					( OweTotPaa_AMNT - AppTotPaa_AMNT
						+ OweTotTaa_AMNT - AppTotTaa_AMNT
						+ OweTotMedi_AMNT - AppTotMedi_AMNT ) AS Assigned_AMNT,
					B.TypeDebt_CODE,       
					A.TypeWelfare_CODE   
					FROM LSUP_Y1 A, OBLE_Y1 B
					WHERE A.Case_IDNO = @An_Case_IDNO
						AND A.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
						AND A.EventGlobalSeq_NUMB = (SELECT MAX(EventGlobalSeq_NUMB)
													FROM LSUP_Y1 C
													WHERE C.Case_IDNO = @An_Case_IDNO
														AND C.OrderSeq_NUMB = a.OrderSeq_NUMB
														AND C.ObligationSeq_NUMB = a.ObligationSeq_NUMB
														AND C.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB)
														AND A.Case_IDNO = B.Case_IDNO
														AND A.OrderSeq_NUMB = B.OrderSeq_NUMB
														AND A.ObligationSeq_NUMB = B.ObligationSeq_NUMB
														AND B.EndValidity_DATE = @Ld_High_DATE
														AND B.EndObligation_DATE = (SELECT MAX(EndObligation_DATE)
																				FROM OBLE_Y1 D
																				WHERE D.Case_IDNO = @An_Case_IDNO
																				AND D.OrderSeq_NUMB = A.OrderSeq_NUMB
																				AND D.ObligationSeq_NUMB = A.ObligationSeq_NUMB
																				AND D.EndValidity_DATE = @Ld_High_DATE ) ) AS T) AS A
									     
END;--End of LSUP_RETRIEVE_S126


GO
