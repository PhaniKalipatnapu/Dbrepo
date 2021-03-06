/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S22](
 @An_Application_IDNO      NUMERIC(15, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S22
  *     DESCRIPTION       : gets the Member Id for the given Application Id where Member Type is Custodial Parent and end date validity is high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseNcp_CODE CHAR(1) = 'A',
          @Lc_RelationshipCasePf_CODE  CHAR(1) = 'P',
		  @Ld_High_DATE DATE = '12/31/9999';

  SELECT m.MemberMci_IDNO
    FROM APCM_Y1 m
   WHERE m.Application_IDNO = @An_Application_IDNO
     AND ( ( @Ac_CaseRelationship_CODE IS NOT NULL AND m.CaseRelationship_CODE = @Ac_CaseRelationship_CODE ) OR
	       ( @Ac_CaseRelationship_CODE IS NULL     AND m.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE,@Lc_RelationshipCasePf_CODE)))
     AND m.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCM_RETRIEVE_S22


GO
