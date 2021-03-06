/****** Object:  StoredProcedure [dbo].[BSAXT_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSAXT_RETRIEVE_S6] 
AS 
/*
 *     PROCEDURE NAME    : BSAXT_RETRIEVE_S6
 *     DESCRIPTION       : Get Statistical Analysis Chart Details
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
	DECLARE @Li_One_NUMB								INT     = 1,
			@Li_Zero_NUMB								INT     = 0,
			@Li_Hundred_NUMB							INT		= 100,
			@Ld_High_DATE								DATE    = '12/31/9999',
			@Lc_Yes_INDC								CHAR(1) = 'Y',
			@Lc_FederalMinimumStandardCACL_TEXT			CHAR(2) = '90',
			@Lc_FederalMinimumStandardESTP_TEXT			CHAR(2) = '75',
			@Lc_FederalMinimumStandardMEDI_TEXT			CHAR(2) = '75',
			@Lc_FederalMinimumStandardENFT_TEXT			CHAR(2) = '75',
			@Lc_FederalMinimumStandardDISB_TEXT			CHAR(2) = '75',
			@Lc_FederalMinimumStandardEXPD6Month_TEXT	CHAR(2) = '75',
			@Lc_FederalMinimumStandardEXPD12Month_TEXT	CHAR(2) = '90',
			@Lc_FederalMinimumStandardRWAD_TEXT			CHAR(2) = '75',
			@Lc_FederalMinimumStandardINST_TEXT			CHAR(2) = '75',
			@Lc_TypeComponentCACL_CODE					CHAR(4) = 'CC',
			@Lc_TypeComponentESTP_CODE					CHAR(4) = 'EP',
			@Lc_TypeComponentMEDI_CODE					CHAR(4) = 'MS',
			@Lc_TypeComponentENFT_CODE					CHAR(4) = 'EN',
			@Lc_TypeComponentDISB_CODE					CHAR(4) = 'DC',
			@Lc_TypeComponentEXPD_CODE					CHAR(4) = 'EX',
			@Lc_TypeComponentRWAD_CODE					CHAR(4) = 'RA',
			@Lc_TypeComponentINST_CODE					CHAR(4) = 'IS',
			@Ls_CaseClosure_TEXT						VARCHAR(50) = 'Case Closure',
			@Ls_Establishment_TEXT						VARCHAR(50) = 'Establishment',
			@Ls_Enforcement_TEXT						VARCHAR(50) = 'Enforcement',
			@Ls_Disbursement_TEXT						VARCHAR(50) = 'Disbursement',
			@Ls_Medical_TEXT							VARCHAR(50) = 'Medical',
			@Ls_ReviewAndAdjustment_TEXT				VARCHAR(50) = 'Review and Adjustment',
			@Ls_IntergovernmentalServices_TEXT			VARCHAR(50) = 'Intergovernmental Services',
			@Ls_SixMonthExpeditedProcess_TEXT			VARCHAR(50) = 'Expedited Process (6 Months)',
			@Ls_TwelveMonthExpeditedProcess_TEXT		VARCHAR(50) = 'Expedited Process (12 Months)';	
			
			WITH cacl_CTE AS
                (SELECT @Ls_CaseClosure_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY,
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY,
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardCACL_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSACC_Y1 a JOIN BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
							AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentCACL_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentCACL_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE))c
                                     GROUP BY c.EfficiencyRate_NUMB) ,
              
               Estp_CTE AS
                (SELECT @Ls_Establishment_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY,
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY,
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardESTP_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSAOE_Y1 a JOIN BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentESTP_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b 
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentESTP_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE)) c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                          
              Medi_CTE AS
              (SELECT   @Ls_Medical_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardMEDI_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO, 
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSAMS_Y1 a JOIN BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentMEDI_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE = @Lc_TypeComponentMEDI_CODE
                                          AND b.StateWideSummary_INDC = @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE = @Ld_High_DATE)) c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                          
              Enft_CTE AS
                (SELECT @Ls_Enforcement_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardENFT_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO, 
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSAEO_Y1 a JOIN BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentENFT_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentENFT_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE))c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                          
              Disb_CTE AS
                (SELECT @Ls_Disbursement_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardDISB_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSADC_Y1 a JOIN BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentDISB_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentDISB_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE))c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                         
              Expd_6mon_CTE AS
                (SELECT @Ls_SixMonthExpeditedProcess_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardEXPD6Month_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.QuestionEP1_INDC  = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSAEP_Y1 a  JOIN  BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentEXPD_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentEXPD_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE)) c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                          
              Expd_12mon_CTE AS
                (SELECT @Ls_TwelveMonthExpeditedProcess_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardEXPD12Month_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.QuestionEP2_INDC  = @Lc_Yes_INDC  AND a.QuestionEP1_INDC <> @Lc_Yes_INDC
									 THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSAEP_Y1 a  JOIN  BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentEXPD_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentEXPD_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE)) c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                          
              Rwad_CTE AS
                (SELECT @Ls_ReviewAndAdjustment_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardRWAD_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSARO_Y1 a JOIN  BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentRWAD_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentRWAD_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE)) c
                                     GROUP BY c.EfficiencyRate_NUMB),
                                          
              Inst_CTE AS
                (SELECT @Ls_IntergovernmentalServices_TEXT AS Component_NAME,
						COUNT(c.Case_IDNO) AS CaseReviewed_QNTY, 
                        SUM(c.Compliance_INDC) AS CaseCompliance_QNTY, 
                        ROUND((SUM(c.Compliance_INDC) * @Li_Hundred_NUMB ) / COUNT(c.Case_IDNO), @Li_One_NUMB ) AS EfficiencyRate_NUMB,
                        @Lc_FederalMinimumStandardINST_TEXT AS FederalMinimumStandard_NUMB,
                        c.EfficiencyRate_NUMB AS PreviousYearEfficiencyRate_NUMB
                   FROM (SELECT a.Case_IDNO,
                                CASE
                                   WHEN a.Compliance_INDC = @Lc_Yes_INDC THEN @Li_One_NUMB
                                   ELSE @Li_Zero_NUMB
                                END AS Compliance_INDC,
                                d.EfficiencyRate_NUMB
                           FROM BSAIN_Y1 a JOIN  BSAXT_Y1 d
                             ON a.EndValidity_DATE = @Ld_High_DATE
                            AND d.EndValidity_DATE = @Ld_High_DATE
                            AND d.TypeComponent_CODE = @Lc_TypeComponentINST_CODE
                            AND EXISTS(SELECT 1
                                         FROM BSASW_Y1 b
                                        WHERE b.TypeComponent_CODE		= @Lc_TypeComponentINST_CODE
                                          AND b.StateWideSummary_INDC	= @Lc_Yes_INDC
                                          AND b.StatusRequest_DATE		= @Ld_High_DATE)) c
                                     GROUP BY c.EfficiencyRate_NUMB)
         
         SELECT B.Component_NAME,
                ISNULL(a.CaseReviewed_QNTY, @Li_Zero_NUMB) CaseReviewed_QNTY,
				ISNULL(a.CaseCompliance_QNTY, @Li_Zero_NUMB) CaseCompliance_QNTY, 
				ISNULL(a.EfficiencyRate_NUMB, @Li_Zero_NUMB) EfficiencyRate_NUMB,
				ISNULL(a.FederalMinimumStandard_NUMB, @Li_Zero_NUMB) FederalMinimumStandard_NUMB,
				ISNULL(a.PreviousYearEfficiencyRate_NUMB, @Li_Zero_NUMB) PreviousYearEfficiencyRate_NUMB
		   FROM (SELECT a.Component_NAME,
						a.CaseReviewed_QNTY,
						a.CaseCompliance_QNTY, 
						a.EfficiencyRate_NUMB,
						a.FederalMinimumStandard_NUMB,
						a.PreviousYearEfficiencyRate_NUMB
				   FROM Cacl_CTE a
				 UNION
				 SELECT b.Component_NAME,
						b.CaseReviewed_QNTY,
						b.CaseCompliance_QNTY, 
						b.EfficiencyRate_NUMB,
						b.FederalMinimumStandard_NUMB,
						b.PreviousYearEfficiencyRate_NUMB
				   FROM Estp_CTE b
				 UNION
				 SELECT d.Component_NAME,
						d.CaseReviewed_QNTY,
						d.CaseCompliance_QNTY, 
						d.EfficiencyRate_NUMB,
						d.FederalMinimumStandard_NUMB,
						d.PreviousYearEfficiencyRate_NUMB
				   FROM Enft_CTE d
				 UNION
				 SELECT e.Component_NAME,
						e.CaseReviewed_QNTY,
						e.CaseCompliance_QNTY, 
						e.EfficiencyRate_NUMB,
						e.FederalMinimumStandard_NUMB,
						e.PreviousYearEfficiencyRate_NUMB
				   FROM Disb_CTE e
				 UNION
				 SELECT c.Component_NAME,
						c.CaseReviewed_QNTY,
						c.CaseCompliance_QNTY, 
						c.EfficiencyRate_NUMB,
						c.FederalMinimumStandard_NUMB,
						c.PreviousYearEfficiencyRate_NUMB
				   FROM Medi_CTE c
				 UNION
				 SELECT h.Component_NAME,
						h.CaseReviewed_QNTY,
						h.CaseCompliance_QNTY, 
						h.EfficiencyRate_NUMB,
						h.FederalMinimumStandard_NUMB,
						h.PreviousYearEfficiencyRate_NUMB
				   FROM Rwad_CTE h
				 UNION
				 SELECT i.Component_NAME,
						i.CaseReviewed_QNTY,
						i.CaseCompliance_QNTY, 
						i.EfficiencyRate_NUMB,
						i.FederalMinimumStandard_NUMB,
						i.PreviousYearEfficiencyRate_NUMB
				   FROM Inst_CTE i
				 UNION
				 SELECT f.Component_NAME,
						f.CaseReviewed_QNTY,
						f.CaseCompliance_QNTY, 
						f.EfficiencyRate_NUMB,
						f.FederalMinimumStandard_NUMB,
						f.PreviousYearEfficiencyRate_NUMB
				   FROM Expd_6mon_CTE f
				 UNION
				 SELECT g.Component_NAME,
						g.CaseReviewed_QNTY,
						g.CaseCompliance_QNTY, 
						g.EfficiencyRate_NUMB,
						g.FederalMinimumStandard_NUMB,
						g.PreviousYearEfficiencyRate_NUMB
				   FROM Expd_12mon_CTE g) A RIGHT OUTER JOIN (SELECT @Ls_CaseClosure_TEXT AS Component_NAME
															   UNION 
															  SELECT @Ls_Establishment_TEXT 
															   UNION 
															  SELECT @Ls_Enforcement_TEXT
															   UNION
															  SELECT @Ls_Disbursement_TEXT
															   UNION 
															  SELECT @Ls_Medical_TEXT
															   UNION 
															  SELECT @Ls_ReviewAndAdjustment_TEXT
															   UNION
															  SELECT @Ls_IntergovernmentalServices_TEXT
															   UNION 
															  SELECT @Ls_SixMonthExpeditedProcess_TEXT
															   UNION
															  SELECT @Ls_TwelveMonthExpeditedProcess_TEXT ) B
					 ON A.Component_NAME = B.Component_NAME;
		           
END	-- END OF BSAXT_RETRIEVE_S6 


GO
