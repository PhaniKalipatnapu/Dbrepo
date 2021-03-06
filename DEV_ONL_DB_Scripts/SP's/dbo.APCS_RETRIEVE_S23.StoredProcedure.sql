/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S23]
(
	 @An_CaseWelfare_IDNO 		NUMERIC(10) ,
	 @Ac_CaseRelationship_CODE  CHAR(1),
	 @Ac_Exists_INDC      		CHAR(1) OUTPUT
 )

AS
 /*
 *     PROCEDURE NAME    : APCS_RETRIEVE_S23
  *     DESCRIPTION       : sets the ICOR indicator to 'N' if records exists for the input Welfare Case Id where welfare type of the member is medicaid, fostercare, temporary assistant for needy family, non-temporary assistant for needy family, non IVE, and case member type is dependent and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  
  DECLARE @Lc_Yes_INDC                   CHAR(1) = 'Y',
  	 	  @Lc_No_INDC                    CHAR(1) = 'N',
          @Lc_RelationshipCaseNcp_CODE   CHAR(1) = 'A',
          @Lc_RelationshipCasePf_CODE    CHAR(1) = 'P',
          @Lc_TypeWelfareFosterCare_CODE CHAR(1) = 'J',
          @Lc_TypeWelfareMedicaid_CODE   CHAR(1) = 'M',
          @Lc_TypeWelfareNonIve_CODE     CHAR(1) = 'F',
          @Lc_TypeWelfareNonTanf_CODE    CHAR(1) = 'N',
          @Lc_TypeWelfareTanf_CODE       CHAR(1) = 'A',
          @Ld_High_DATE                  DATE 	 = '12/31/9999';
 
  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM APCS_Y1 a
	    JOIN
         APCM_Y1  b
      ON  a.Application_IDNO = b.Application_IDNO
   WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
     AND a.TypeWelfare_CODE IN (@Lc_TypeWelfareMedicaid_CODE, @Lc_TypeWelfareNonTanf_CODE, @Lc_TypeWelfareFosterCare_CODE, @Lc_TypeWelfareNonIve_CODE, @Lc_TypeWelfareTanf_CODE)
     AND ((@Ac_CaseRelationship_CODE IS NULL AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE,@Lc_RelationshipCasePf_CODE))
     OR (@Ac_CaseRelationship_CODE IS NOT NULL AND b.CaseRelationship_CODE = @Ac_CaseRelationship_CODE))   
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCS_RETRIEVE_S23


GO
