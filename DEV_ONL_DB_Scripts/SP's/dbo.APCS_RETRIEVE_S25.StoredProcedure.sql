/****** Object:  StoredProcedure [dbo].[APCS_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_RETRIEVE_S25](
	 @An_Application_IDNO      NUMERIC(15),
	 @Ac_CaseRelationship_CODE CHAR(1),
	 @An_TransHeader_IDNO	   NUMERIC(12),
	 @Ac_StateFips_CODE		   CHAR(2),
	 @Ad_Transaction_DATE	   DATE,	 
	 @Ac_Exists_INDC           CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCS_RETRIEVE_S25
  *     DESCRIPTION       : sets the ICOR indicator to 'N' if records exists for the given unique application ID, unique transaction header Id, Local-FIPs-State code, and transaction date where case relation member is Non Custodial Parent and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_INDC                  CHAR(1) = 'Y',
  		  @Lc_No_INDC                   CHAR(1) = 'N',
          @Ld_High_DATE                 DATE 	= '12/31/9999',
          @Lc_CaseRelationshipNcp_CODE 	CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE 	CHAR(1) = 'P';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM APCS_Y1 A
	     JOIN  APCM_Y1 B
		 ON  a.Application_IDNO = b.Application_IDNO
   WHERE a.Application_IDNO = @An_Application_IDNO
   	 AND a.TransHeader_IDNO = @An_TransHeader_IDNO
   	 AND a.StateFips_CODE = @Ac_StateFips_CODE
   	 AND a.Transaction_DATE = @Ad_Transaction_DATE
   	 AND ((@Ac_CaseRelationship_CODE IS NOT NULL AND b.CaseRelationship_CODE = @Ac_CaseRelationship_CODE)
   	 	 OR (@Ac_CaseRelationship_CODE IS NULL AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPf_CODE)))
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCS_RETRIEVE_S25


GO
