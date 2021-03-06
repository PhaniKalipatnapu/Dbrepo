/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S9] (
 @An_CpMci_IDNO		 NUMERIC(10, 0),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S9
  *     DESCRIPTION       : Check if given Member is Cp.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN
	
	SET @Ai_Count_QNTY = NULL;
	
	DECLARE @Lc_WelfareEligIva_CODE		CHAR(1) = 'A';
	DECLARE @Lc_CaseRelationshipCp_CODE	CHAR(1) = 'C';
        
	SELECT @Ai_Count_QNTY = COUNT(1)
	FROM IVMG_Y1 I JOIN CMEM_Y1 C
		ON I.CpMci_IDNO = C.MemberMci_IDNO
	WHERE I.CpMci_IDNO = @An_CpMci_IDNO
		AND I.WelfareElig_CODE IN ( @Lc_WelfareEligIva_CODE )
		AND C.CaseRelationship_CODE IN ( @Lc_CaseRelationshipCp_CODE );  
                  
END;-- End of IVMG_RETRIEVE_S9

GO
