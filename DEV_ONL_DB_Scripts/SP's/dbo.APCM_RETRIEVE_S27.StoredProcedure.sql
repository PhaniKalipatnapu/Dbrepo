/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S27](
 @An_Application_IDNO         NUMERIC(15),
 @Ac_CpRelationshipToNcp_CODE CHAR(3) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S27
  *     DESCRIPTION       : Retrieve CP Relationship with NCP for an Application ID and Member Type is Putative Father and NCP.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_CpRelationshipToNcp_CODE = NULL;

  DECLARE @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Ld_High_DATE                      DATE = '12/31/9999';

  SELECT @Ac_CpRelationshipToNcp_CODE = AC.CpRelationshipToNcp_CODE
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.EndValidity_DATE = @Ld_High_DATE
     AND AC.CaseRelationship_CODE IN (@Lc_RelationshipCasePutFather_CODE, @Lc_RelationshipCaseNcp_CODE);
 END; --End of APCM_RETRIEVE_S27


GO
