/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S67]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S67] (
 @An_CpMci_IDNO		 NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S67
  *     DESCRIPTION       : Retrieves the CaseWelfareIdno for a given member.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN

	DECLARE @Lc_CaseRelationshipCp_CODE		CHAR(1) = 'C',
			@Lc_WelfareEligIva_CODE			CHAR(1) = 'A';
        
	SELECT DISTINCT m.CaseWelfare_IDNO 
	FROM MHIS_Y1 m, CMEM_Y1 c
	WHERE m.MemberMci_IDNO = @An_CpMci_IDNO
		AND m.MemberMci_IDNO = c.MemberMci_IDNO
		AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
		AND m.TypeWelfare_CODE = @Lc_WelfareEligIva_CODE;  
                  
END;-- End of MHIS_RETRIEVE_S67

GO
